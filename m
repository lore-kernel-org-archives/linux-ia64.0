From: Ingo Molnar <mingo@elte.hu>
Date: Thu, 20 Jan 2005 18:22:27 +0000
Subject: [patch, BK-curr] nonintrusive spin-polling loop in kernel/spinlock.c
Message-Id: <20050120182227.GA26985@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050120023445.GA3475@taniwha.stupidest.org> <20050119190104.71f0a76f.akpm@osdl.org> <20050120031854.GA8538@taniwha.stupidest.org> <16879.29449.734172.893834@wombat.chubb.wattle.id.au> <Pine.LNX.4.58.0501200747230.8178@ppc970.osdl.org> <20050120160839.GA13067@elte.hu> <Pine.LNX.4.58.0501200823010.8178@ppc970.osdl.org> <20050120164038.GA15874@elte.hu> <Pine.LNX.4.58.0501200947440.8178@ppc970.osdl.org> <20050120175313.GA22782@elte.hu>
In-Reply-To: <20050120175313.GA22782@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@osdl.org>
Cc: Peter Chubb <peterc@gelato.unsw.edu.au>, Chris Wedgwood <cw@f00f.org>, Andrew Morton <akpm@osdl.org>, paulus@samba.org, linux-kernel@vger.kernel.org, tony.luck@intel.com, dsw@gelato.unsw.edu.au, benh@kernel.crashing.org, linux-ia64@vger.kernel.org, hch@infradead.org, wli@holomorphy.com, jbarnes@sgi.com


this patch, against BK-curr, implements a nonintrusive spin-polling loop
for the SMP+PREEMPT spinlock/rwlock variants, using the new *_can_lock()
primitives. (The patch also adds *_can_lock() to the UP branch of
spinlock.h, for completeness.)

build- and boot-tested on x86 SMP+PREEMPT and SMP+!PREEMPT.

	Ingo

Signed-off-by: Ingo Molnar <mingo@elte.hu>

--- linux/kernel/spinlock.c.orig
+++ linux/kernel/spinlock.c
@@ -174,7 +174,7 @@ EXPORT_SYMBOL(_write_lock);
  */
 
 #define BUILD_LOCK_OPS(op, locktype)					\
-void __lockfunc _##op##_lock(locktype *lock)				\
+void __lockfunc _##op##_lock(locktype##_t *lock)			\
 {									\
 	preempt_disable();						\
 	for (;;) {							\
@@ -183,14 +183,15 @@ void __lockfunc _##op##_lock(locktype *l
 		preempt_enable();					\
 		if (!(lock)->break_lock)				\
 			(lock)->break_lock = 1;				\
-		cpu_relax();						\
+		while (!op##_can_lock(lock) && (lock)->break_lock)	\
+			cpu_relax();					\
 		preempt_disable();					\
 	}								\
 }									\
 									\
 EXPORT_SYMBOL(_##op##_lock);						\
 									\
-unsigned long __lockfunc _##op##_lock_irqsave(locktype *lock)		\
+unsigned long __lockfunc _##op##_lock_irqsave(locktype##_t *lock)	\
 {									\
 	unsigned long flags;						\
 									\
@@ -204,7 +205,8 @@ unsigned long __lockfunc _##op##_lock_ir
 		preempt_enable();					\
 		if (!(lock)->break_lock)				\
 			(lock)->break_lock = 1;				\
-		cpu_relax();						\
+		while (!op##_can_lock(lock) && (lock)->break_lock)	\
+			cpu_relax();					\
 		preempt_disable();					\
 	}								\
 	return flags;							\
@@ -212,14 +214,14 @@ unsigned long __lockfunc _##op##_lock_ir
 									\
 EXPORT_SYMBOL(_##op##_lock_irqsave);					\
 									\
-void __lockfunc _##op##_lock_irq(locktype *lock)			\
+void __lockfunc _##op##_lock_irq(locktype##_t *lock)			\
 {									\
 	_##op##_lock_irqsave(lock);					\
 }									\
 									\
 EXPORT_SYMBOL(_##op##_lock_irq);					\
 									\
-void __lockfunc _##op##_lock_bh(locktype *lock)				\
+void __lockfunc _##op##_lock_bh(locktype##_t *lock)			\
 {									\
 	unsigned long flags;						\
 									\
@@ -244,9 +246,9 @@ EXPORT_SYMBOL(_##op##_lock_bh)
  *         _[spin|read|write]_lock_irqsave()
  *         _[spin|read|write]_lock_bh()
  */
-BUILD_LOCK_OPS(spin, spinlock_t);
-BUILD_LOCK_OPS(read, rwlock_t);
-BUILD_LOCK_OPS(write, rwlock_t);
+BUILD_LOCK_OPS(spin, spinlock);
+BUILD_LOCK_OPS(read, rwlock);
+BUILD_LOCK_OPS(write, rwlock);
 
 #endif /* CONFIG_PREEMPT */
 
--- linux/include/linux/spinlock.h.orig
+++ linux/include/linux/spinlock.h
@@ -221,6 +221,8 @@ typedef struct {
 #define _raw_read_unlock(lock)	do { (void)(lock); } while(0)
 #define _raw_write_lock(lock)	do { (void)(lock); } while(0)
 #define _raw_write_unlock(lock)	do { (void)(lock); } while(0)
+#define read_can_lock(lock)	(((void)(lock), 1))
+#define write_can_lock(lock)	(((void)(lock), 1))
 #define _raw_read_trylock(lock) ({ (void)(lock); (1); })
 #define _raw_write_trylock(lock) ({ (void)(lock); (1); })
 
