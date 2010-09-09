From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 09 Sep 2010 05:18:32 +0000
Subject: [BUGGY PATCH] fix siglock
Message-Id: <4c886e2828821bfa88@agluck-desktop.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

When ia64 converted to using ticket locks, an inline implementation
of trylock/unlock in fsys.S was missed.  This was not noticed because
in most circumstances it simply resulted in using the slow path because
the siglock was apparently not available (under old spinlock rules).

Problems occur when the ticket spinlock has value 0x0 (when first
initialised, or when it wraps around). At this point the fsys.S
code acquires the lock (changing the 0x0 to 0x1. If another process
attempts to get the lock at this point, it will change the value from
0x1 to 0x2 (using new ticket lock rules). Then the fsys.S code will
free the lock using old spinlock rules by writing 0x0 to it. From
here a variety of bad things can happen.

---

This is an almost-there patch, I've goofed someplace in dropping
the new __ticket_try_spinlock or __ticket_spin_unlock code into
fsys.S so the kernel doesn't boot :-(  Maybe I messed up on which
registers were safe to use? Or just failed when renaming.

diff --git a/arch/ia64/kernel/fsys.S b/arch/ia64/kernel/fsys.S
index 3567d54..08d0969 100644
--- a/arch/ia64/kernel/fsys.S
+++ b/arch/ia64/kernel/fsys.S
@@ -420,23 +420,33 @@ EX(.fail_efault, ld8 r14=[r33])			// r14 <- *set
 	;;
 
 	RSM_PSR_I(p0, r18, r19)			// mask interrupt delivery
-	mov ar.ccv=0
 	andcm r14=r14,r17			// filter out SIGKILL & SIGSTOP
 
 #ifdef CONFIG_SMP
-	mov r17=1
+	ld4.acq r17=[r31]			// __ticket_spin_trylock(r31)
 	;;
-	cmpxchg4.acq r18=[r31],r17,ar.ccv	// try to acquire the lock
-	mov r8=EINVAL			// default to EINVAL
+	extr r3=r17,17,15
+	addp4 r18=r17,r0
 	;;
-	ld8 r3=[r2]			// re-read current->blocked now that we hold the lock
-	cmp4.ne p6,p0=r18,r0
-(p6)	br.cond.spnt.many .lock_contention
+	xor r18=r17,r3
 	;;
-#else
+	extr.u r14=r18,0,15
+	;;
+	cmp.eq p0,p7=0,r14
+(p7)	br.cond.spnt.many .lock_contention
+	mov.m ar.ccv=r17
+	;;
+	adds r19=1,r17
+	;;
+	cmpxchg4.acq r3=[r31],r19,ar.ccv
+	;;
+	cmp4.eq p0,p7=r3,r17
+(p7)	br.cond.spnt.many .lock_contention
+	;;
+#endif
+
 	ld8 r3=[r2]			// re-read current->blocked now that we hold the lock
 	mov r8=EINVAL			// default to EINVAL
-#endif
 	add r18=IA64_TASK_PENDING_OFFSET+IA64_SIGPENDING_SIGNAL_OFFSET,r16
 	add r19=IA64_TASK_SIGNAL_OFFSET,r16
 	cmp4.eq p6,p0=SIG_BLOCK,r32
@@ -490,7 +500,13 @@ EX(.fail_efault, ld8 r14=[r33])			// r14 <- *set
 (p6)	br.cond.spnt.few 1b			// yes -> retry
 
 #ifdef CONFIG_SMP
-	st4.rel [r31]=r0			// release the lock
+	adds	r31=2,r31
+	;;
+	ld2.bias r8=[r31]
+	mov r3e534;;
+	adds r2=2,r8;;				// bump now-serving
+	and r8=r3,r3;;				// mask out guard bit
+	st2.rel [r31]=r8			// release the lock
 #endif
 	SSM_PSR_I(p0, p9, r31)
 	;;
