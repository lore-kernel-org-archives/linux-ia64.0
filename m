From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 16 Sep 2010 20:23:14 +0000
Subject: [IA64 PATCH for v2.6.32 to v2.6.35] ia64: fix siglock in fsys_rt_sigprocmask
Message-Id: <4c927cb2184948077a@agluck-desktop.sc.intel.com>
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

Fix to use the new ticket lock algorithm.

Cc: Petr Tesarik <ptesarik@suse.cz>
Signed-off-by: Tony Luck <tony.luck@intel.com>

---

This went upstream in two pieces - there was a bug in the first attempt
(my code), the second (by Petr) fixes the bug (and also makes the code
much prettier).  Patch below is the combination of both so we don't
make a bisection trap for people to fall into. If this violates stable
rules, then feel free to just cherry pick the two commits.

commit f574c843191728d9407b766a027f779dcd27b272
    [IA64] fix siglock
commit 2d2b6901649a62977452be85df53eda2412def24
    [IA64] Optimize ticket spinlocks in fsys_rt_sigprocmask


diff --git a/arch/ia64/kernel/fsys.S b/arch/ia64/kernel/fsys.S
index 3567d54..331d42b 100644
--- a/arch/ia64/kernel/fsys.S
+++ b/arch/ia64/kernel/fsys.S
@@ -420,22 +420,31 @@ EX(.fail_efault, ld8 r14=[r33])			// r14 <- *set
 	;;
 
 	RSM_PSR_I(p0, r18, r19)			// mask interrupt delivery
-	mov ar.ccv=0
 	andcm r14=r14,r17			// filter out SIGKILL & SIGSTOP
+	mov r8=EINVAL			// default to EINVAL
 
 #ifdef CONFIG_SMP
-	mov r17=1
+	// __ticket_spin_trylock(r31)
+	ld4 r17=[r31]
 	;;
-	cmpxchg4.acq r18=[r31],r17,ar.ccv	// try to acquire the lock
-	mov r8=EINVAL			// default to EINVAL
+	mov.m ar.ccv=r17
+	extr.u r9=r17,17,15
+	adds r19=1,r17
+	extr.u r18=r17,0,15
+	;;
+	cmp.eq p6,p7=r9,r18
 	;;
+(p6)	cmpxchg4.acq r9=[r31],r19,ar.ccv
+(p6)	dep.z r20=r19,1,15		// next serving ticket for unlock
+(p7)	br.cond.spnt.many .lock_contention
+	;;
+	cmp4.eq p0,p7=r9,r17
+	adds r31=2,r31
+(p7)	br.cond.spnt.many .lock_contention
 	ld8 r3=[r2]			// re-read current->blocked now that we hold the lock
-	cmp4.ne p6,p0=r18,r0
-(p6)	br.cond.spnt.many .lock_contention
 	;;
 #else
 	ld8 r3=[r2]			// re-read current->blocked now that we hold the lock
-	mov r8=EINVAL			// default to EINVAL
 #endif
 	add r18=IA64_TASK_PENDING_OFFSET+IA64_SIGPENDING_SIGNAL_OFFSET,r16
 	add r19=IA64_TASK_SIGNAL_OFFSET,r16
@@ -490,7 +499,9 @@ EX(.fail_efault, ld8 r14=[r33])			// r14 <- *set
 (p6)	br.cond.spnt.few 1b			// yes -> retry
 
 #ifdef CONFIG_SMP
-	st4.rel [r31]=r0			// release the lock
+	// __ticket_spin_unlock(r31)
+	st2.rel [r31]=r20
+	mov r20=0					// i must not leak kernel bits...
 #endif
 	SSM_PSR_I(p0, p9, r31)
 	;;
@@ -512,7 +523,8 @@ EX(.fail_efault, (p15) st8 [r34]=r3)
 
 .sig_pending:
 #ifdef CONFIG_SMP
-	st4.rel [r31]=r0			// release the lock
+	// __ticket_spin_unlock(r31)
+	st2.rel [r31]=r20			// release the lock
 #endif
 	SSM_PSR_I(p0, p9, r17)
 	;;
