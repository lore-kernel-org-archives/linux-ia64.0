From: Keith Owens <kaos@sgi.com>
Date: Thu, 08 Apr 2004 03:19:37 +0000
Subject: [patch] 2.6.5 Improve interrupt handling on contended spinlocks
Message-Id: <4198.1081394377@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

spin_lock_irqsave() on a contended lock leaves interrupts disabled
while waiting for the lock.  If the interrupts were enabled before
spin_lock_irqsave then this has the nasty side effect of preventing
interrupt handling while waiting for the lock.  Change the contention
path to enable interrupts if it is safe to do so, allowing the cpu to
process interrupts while waiting for the lock.


= Change mainline code to use _raw_spin_lock_flags() on architectures
   that support it.  No effective change for anything except ia64.

Index: linux/include/linux/spinlock.h
--- linux.orig/include/linux/spinlock.h	Thu Apr  8 12:16:26 2004
+++ linux/include/linux/spinlock.h	Thu Apr  8 12:47:35 2004
@@ -184,6 +184,12 @@
 
 #endif /* !SMP */
 
+#ifdef __HAVE_ARCH_RAW_SPIN_LOCK_FLAGS
+#define _raw_spin_lock(lock) _raw_spin_lock_flags(lock, 0)
+#else
+#define _raw_spin_lock_flags(lock, flags) do { (void)flags; _raw_spin_lock(lock); } while(0)
+#endif
+
 /*
  * Define the various spin_lock and rw_lock methods.  Note we define these
  * regardless of whether CONFIG_SMP or CONFIG_PREEMPT are set. The various
@@ -257,7 +263,7 @@
 do { \
 	local_irq_save(flags); \
 	preempt_disable(); \
-	_raw_spin_lock(lock); \
+	_raw_spin_lock_flags(lock, flags); \
 } while (0)
 
 #define spin_lock_irq(lock) \


= Pass the previous flags to the contention path using r27, also
   reserve p14 for the contention code.

Index: linux/include/asm-ia64/spinlock.h
--- linux.orig/include/asm-ia64/spinlock.h	Thu Apr  8 12:16:26 2004
+++ linux/include/asm-ia64/spinlock.h	Thu Apr  8 12:47:35 2004
@@ -32,10 +32,12 @@
  * carefully coded to touch only those registers that spin_lock() marks "clobbered".
  */
 
-#define IA64_SPINLOCK_CLOBBERS "ar.ccv", "ar.pfs", "p14", "r28", "r29", "r30", "b6", "memory"
+#define IA64_SPINLOCK_CLOBBERS "ar.ccv", "ar.pfs", "p14", "p15", "r27", "r28", "r29", "r30", "b6", "memory"
+
+#define __HAVE_ARCH_RAW_SPIN_LOCK_FLAGS
 
 static inline void
-_raw_spin_lock (spinlock_t *lock)
+_raw_spin_lock_flags (spinlock_t *lock, unsigned long flags)
 {
 	register volatile unsigned int *ptr asm ("r31") = &lock->lock;
 
@@ -50,9 +52,10 @@
 		      "cmpxchg4.acq r30 = [%1], r30, ar.ccv\n\t"
 		      "movl r29 = ia64_spinlock_contention_pre3_4;;\n\t"
 		      "cmp4.ne p14, p0 = r30, r0\n\t"
-		      "mov b6 = r29;;\n"
+		      "mov b6 = r29;;\n\t"
+		      "mov r27=%2\n\t"
 		      "(p14) br.cond.spnt.many b6"
-		      : "=r"(ptr) : "r"(ptr) : IA64_SPINLOCK_CLOBBERS);
+		      : "=r"(ptr) : "r"(ptr), "r" (flags) : IA64_SPINLOCK_CLOBBERS);
 # else
 	asm volatile ("{\n\t"
 		      "  mov ar.ccv = r0\n\t"
@@ -60,29 +63,32 @@
 		      "  mov r30 = 1;;\n\t"
 		      "}\n\t"
 		      "cmpxchg4.acq r30 = [%1], r30, ar.ccv;;\n\t"
-		      "cmp4.ne p14, p0 = r30, r0\n"
+		      "cmp4.ne p14, p0 = r30, r0\n\t"
+		      "mov r27=%2\n\t"
 		      "(p14) brl.cond.spnt.many ia64_spinlock_contention_pre3_4;;"
-		      : "=r"(ptr) : "r"(ptr) : IA64_SPINLOCK_CLOBBERS);
+		      : "=r"(ptr) : "r"(ptr), "r" (flags) : IA64_SPINLOCK_CLOBBERS);
 # endif /* CONFIG_MCKINLEY */
 #else
 # ifdef CONFIG_ITANIUM
 	/* don't use brl on Itanium... */
 	/* mis-declare, so we get the entry-point, not it's function descriptor: */
 	asm volatile ("mov r30 = 1\n\t"
+		      "mov r27=%2\n\t"
 		      "mov ar.ccv = r0;;\n\t"
 		      "cmpxchg4.acq r30 = [%0], r30, ar.ccv\n\t"
 		      "movl r29 = ia64_spinlock_contention;;\n\t"
 		      "cmp4.ne p14, p0 = r30, r0\n\t"
-		      "mov b6 = r29;;\n"
+		      "mov b6 = r29;;\n\t"
 		      "(p14) br.call.spnt.many b6 = b6"
-		      : "=r"(ptr) : "r"(ptr) : IA64_SPINLOCK_CLOBBERS);
+		      : "=r"(ptr) : "r"(ptr), "r" (flags) : IA64_SPINLOCK_CLOBBERS);
 # else
 	asm volatile ("mov r30 = 1\n\t"
+		      "mov r27=%2\n\t"
 		      "mov ar.ccv = r0;;\n\t"
 		      "cmpxchg4.acq r30 = [%0], r30, ar.ccv;;\n\t"
 		      "cmp4.ne p14, p0 = r30, r0\n\t"
 		      "(p14) brl.call.spnt.many b6=ia64_spinlock_contention;;"
-		      : "=r"(ptr) : "r"(ptr) : IA64_SPINLOCK_CLOBBERS);
+		      : "=r"(ptr) : "r"(ptr), "r" (flags) : IA64_SPINLOCK_CLOBBERS);
 # endif /* CONFIG_MCKINLEY */
 #endif
 }


= If interrupts were enabled before entering the contention path,
   reenable them while waiting for the lock to become free.

Index: linux/arch/ia64/kernel/head.S
--- linux.orig/arch/ia64/kernel/head.S	Thu Apr  8 12:16:26 2004
+++ linux/arch/ia64/kernel/head.S	Thu Apr  8 13:12:46 2004
@@ -866,12 +866,14 @@
 	 * Inputs:
 	 *   ar.pfs - saved CFM of caller
 	 *   ar.ccv - 0 (and available for use)
+	 *   r27    - flags from spin_lock_irqsave or 0.  Must be preserved.
 	 *   r28    - available for use.
 	 *   r29    - available for use.
 	 *   r30    - available for use.
 	 *   r31    - address of lock, available for use.
 	 *   b6     - return address
 	 *   p14    - available for use.
+	 *   p15    - used to track flag status.
 	 *
 	 * If you patch this code to use more registers, do not forget to update
 	 * the clobber lists for spin_lock() in include/asm-ia64/spinlock.h.
@@ -885,22 +887,27 @@
 	.save rp, r28
 	.body
 	nop 0
-	nop 0
+	tbit.nz p15,p0=r27,IA64_PSR_I_BIT
 	.restore sp		// pop existing prologue after next insn
 	mov b6 = r28
 	.prologue
 	.save ar.pfs, r0
 	.altrp b6
 	.body
+	;;
+(p15)	ssm psr.i		// reenable interrupts if they were on
+	;;
+(p15)	srlz.d
 .wait:
 	// exponential backoff, kdb, lockmeter etc. go in here
 	hint @pause
 	ld4 r30=[r31]		// don't use ld4.bias; if it's contended, we won't write the word
 	nop 0
 	;;
-	cmp4.eq p14,p0=r30,r0
-(p14)	br.cond.sptk.few b6	// lock is now free, try to acquire
-	br.cond.sptk.few .wait
+	cmp4.ne p14,p0=r30,r0
+(p14)	br.cond.sptk.few .wait
+(p15)	rsm psr.i		// disable interrupts if we reenabled them
+	br.cond.sptk.few b6	// lock is now free, try to acquire
 	.global ia64_spinlock_contention_pre3_4_end	// for kernprof
 ia64_spinlock_contention_pre3_4_end:
 END(ia64_spinlock_contention_pre3_4)
@@ -911,14 +918,21 @@
 	.prologue
 	.altrp b6
 	.body
+	tbit.nz p15,p0=r27,IA64_PSR_I_BIT
+	;;
 .wait:
+(p15)	ssm psr.i		// reenable interrupts if they were on
+	;;
+(p15)	srlz.d
+.wait2:
 	// exponential backoff, kdb, lockmeter etc. go in here
 	hint @pause
 	ld4 r30=[r31]		// don't use ld4.bias; if it's contended, we won't write the word
 	;;
 	cmp4.ne p14,p0=r30,r0
 	mov r30 = 1
-(p14)	br.cond.sptk.few .wait
+(p14)	br.cond.sptk.few .wait2
+(p15)	rsm psr.i		// disable interrupts if we reenabled them
 	;;
 	cmpxchg4.acq r30=[r31], r30, ar.ccv
 	;;

