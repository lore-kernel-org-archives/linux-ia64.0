From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 09 Sep 2010 16:56:02 +0000
Subject: [PATCH] fix siglock
Message-Id: <4c8911a2302651c5f3@agluck-desktop.sc.intel.com>
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

This patch boots ... just started the stress test - running for ten
minutes (means nothing, it usually fails at about 1 hour for me).

diff --git a/arch/ia64/kernel/fsys.S b/arch/ia64/kernel/fsys.S
index 3567d54..a6c4695 100644
--- a/arch/ia64/kernel/fsys.S
+++ b/arch/ia64/kernel/fsys.S
@@ -424,14 +424,26 @@ EX(.fail_efault, ld8 r14=[r33])			// r14 <- *set
 	andcm r14=r14,r17			// filter out SIGKILL & SIGSTOP
 
 #ifdef CONFIG_SMP
-	mov r17=1
-	;;
-	cmpxchg4.acq r18=[r31],r17,ar.ccv	// try to acquire the lock
+	// __ticket_spin_trylock(r31)
+	ld4 r17=[r31]
 	mov r8=EINVAL			// default to EINVAL
 	;;
+	extr r9=r17,17,15
+	;;
+	xor r18=r17,r9
+	adds r19=1,r17
+	;;
+	extr.u r18=r18,0,15
+	;;
+	cmp.eq p0,p7=0,r18
+(p7)	br.cond.spnt.many .lock_contention
+	mov.m ar.ccv=r17
+	;;
+	cmpxchg4.acq r9=[r31],r19,ar.ccv
+	;;
+	cmp4.eq p0,p7=r9,r17
+(p7)	br.cond.spnt.many .lock_contention
 	ld8 r3=[r2]			// re-read current->blocked now that we hold the lock
-	cmp4.ne p6,p0=r18,r0
-(p6)	br.cond.spnt.many .lock_contention
 	;;
 #else
 	ld8 r3=[r2]			// re-read current->blocked now that we hold the lock
@@ -490,7 +502,17 @@ EX(.fail_efault, ld8 r14=[r33])			// r14 <- *set
 (p6)	br.cond.spnt.few 1b			// yes -> retry
 
 #ifdef CONFIG_SMP
-	st4.rel [r31]=r0			// release the lock
+	// __ticket_spin_unlock(r31)
+	adds r31=2,r31
+	;;
+	ld2.bias r2=[r31]
+	mov r3e534
+	;;
+	adds r2=2,r2
+	;;
+	and r3=r3,r2
+	;;
+	st2.rel [r31]=r3
 #endif
 	SSM_PSR_I(p0, p9, r31)
 	;;
