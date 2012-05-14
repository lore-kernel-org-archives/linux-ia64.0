From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 14 May 2012 22:00:12 +0000
Subject: RE: [PATCH] Liberate the signal layer from IA64 assembler
Message-Id: <3908561D78D1C84285E8C5FCA982C28F192EEF5D@ORSMSX104.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1337031869-14718-1-git-send-email-andi@firstfloor.org>
In-Reply-To: <1337031869-14718-1-git-send-email-andi@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <andi@firstfloor.org>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Fleming, Matt" <matt.fleming@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

Adding Cc: linux-ia64

-----Original Message-----
From: Andi Kleen [mailto:andi@firstfloor.org] 
Sent: Monday, May 14, 2012 2:44 PM
To: viro@zeniv.linux.org.uk
Cc: linux-kernel@vger.kernel.org; Andi Kleen; Luck, Tony; Fleming, Matt
Subject: [PATCH] Liberate the signal layer from IA64 assembler

Currently IA64 has a assembler implementation of sigrtprocmask.
Having a single architecture implement this in assembler language
is a serious maintenance problem that inhibits further evolution of the
signal subsystem.  Everyone who wants to do deep changes to signals
would need to learn that assembler language.

Whatever performance improvements IA64 gets from this it cannot be worth
the price in maintainability.

We have some locking problems in signal that need to be fixed,
but this roadblock needs to be removed first.

So just disable the special assembler IA64 implementation and fall back to a
normal syscall there.

Speaking for myself only.

Cc: tony.luck@intel.com
Cc: matt.fleming@intel.com
Signed-off-by: Andi Kleen <andi@firstfloor.org>
---
 arch/ia64/kernel/fsys.S |  171 +----------------------------------------------
 1 files changed, 1 insertions(+), 170 deletions(-)

diff --git a/arch/ia64/kernel/fsys.S b/arch/ia64/kernel/fsys.S
index cc26eda..5bd6e2b 100644
--- a/arch/ia64/kernel/fsys.S
+++ b/arch/ia64/kernel/fsys.S
@@ -372,175 +372,6 @@ ENTRY(fsys_clock_gettime)
 END(fsys_clock_gettime)
 
 /*
- * long fsys_rt_sigprocmask (int how, sigset_t *set, sigset_t *oset, size_t sigsetsize).
- */
-#if _NSIG_WORDS != 1
-# error Sorry, fsys_rt_sigprocmask() needs to be updated for _NSIG_WORDS != 1.
-#endif
-ENTRY(fsys_rt_sigprocmask)
-	.prologue
-	.altrp b6
-	.body
-
-	add r2=IA64_TASK_BLOCKED_OFFSET,r16
-	add r9=TI_FLAGS+IA64_TASK_SIZE,r16
-	cmp4.ltu p6,p0=SIG_SETMASK,r32
-
-	cmp.ne p15,p0=r0,r34			// oset != NULL?
-	tnat.nz p8,p0=r34
-	add r31=IA64_TASK_SIGHAND_OFFSET,r16
-	;;
-	ld8 r3=[r2]				// read/prefetch current->blocked
-	ld4 r9=[r9]
-	tnat.nz.or p6,p0=r35
-
-	cmp.ne.or p6,p0=_NSIG_WORDS*8,r35
-	tnat.nz.or p6,p0=r32
-(p6)	br.spnt.few .fail_einval		// fail with EINVAL
-	;;
-#ifdef CONFIG_SMP
-	ld8 r31=[r31]				// r31 <- current->sighand
-#endif
-	and r9=TIF_ALLWORK_MASK,r9
-	tnat.nz.or p8,p0=r33
-	;;
-	cmp.ne p7,p0=0,r9
-	cmp.eq p6,p0=r0,r33			// set = NULL?
-	add r31=IA64_SIGHAND_SIGLOCK_OFFSET,r31	// r31 <- current->sighand->siglock
-(p8)	br.spnt.few .fail_efault		// fail with EFAULT
-(p7)	br.spnt.many fsys_fallback_syscall	// got pending kernel work...
-(p6)	br.dpnt.many .store_mask		// -> short-circuit to just reading the signal mask
-
-	/* Argh, we actually have to do some work and _update_ the signal mask: */
-
-EX(.fail_efault, probe.r.fault r33, 3)		// verify user has read-access to *set
-EX(.fail_efault, ld8 r14=[r33])			// r14 <- *set
-	mov r17=(1 << (SIGKILL - 1)) | (1 << (SIGSTOP - 1))
-	;;
-
-	RSM_PSR_I(p0, r18, r19)			// mask interrupt delivery
-	andcm r14=r14,r17			// filter out SIGKILL & SIGSTOP
-	mov r8=EINVAL			// default to EINVAL
-
-#ifdef CONFIG_SMP
-	// __ticket_spin_trylock(r31)
-	ld4 r17=[r31]
-	;;
-	mov.m ar.ccv=r17
-	extr.u r9=r17,17,15
-	adds r19=1,r17
-	extr.u r18=r17,0,15
-	;;
-	cmp.eq p6,p7=r9,r18
-	;;
-(p6)	cmpxchg4.acq r9=[r31],r19,ar.ccv
-(p6)	dep.z r20=r19,1,15		// next serving ticket for unlock
-(p7)	br.cond.spnt.many .lock_contention
-	;;
-	cmp4.eq p0,p7=r9,r17
-	adds r31=2,r31
-(p7)	br.cond.spnt.many .lock_contention
-	ld8 r3=[r2]			// re-read current->blocked now that we hold the lock
-	;;
-#else
-	ld8 r3=[r2]			// re-read current->blocked now that we hold the lock
-#endif
-	add r18=IA64_TASK_PENDING_OFFSET+IA64_SIGPENDING_SIGNAL_OFFSET,r16
-	add r19=IA64_TASK_SIGNAL_OFFSET,r16
-	cmp4.eq p6,p0=SIG_BLOCK,r32
-	;;
-	ld8 r19=[r19]			// r19 <- current->signal
-	cmp4.eq p7,p0=SIG_UNBLOCK,r32
-	cmp4.eq p8,p0=SIG_SETMASK,r32
-	;;
-	ld8 r18=[r18]			// r18 <- current->pending.signal
-	.pred.rel.mutex p6,p7,p8
-(p6)	or r14=r3,r14			// SIG_BLOCK
-(p7)	andcm r14=r3,r14		// SIG_UNBLOCK
-
-(p8)	mov r14=r14			// SIG_SETMASK
-(p6)	mov r8=0			// clear error code
-	// recalc_sigpending()
-	add r17=IA64_SIGNAL_GROUP_STOP_COUNT_OFFSET,r19
-
-	add r19=IA64_SIGNAL_SHARED_PENDING_OFFSET+IA64_SIGPENDING_SIGNAL_OFFSET,r19
-	;;
-	ld4 r17=[r17]		// r17 <- current->signal->group_stop_count
-(p7)	mov r8=0		// clear error code
-
-	ld8 r19=[r19]		// r19 <- current->signal->shared_pending
-	;;
-	cmp4.gt p6,p7=r17,r0	// p6/p7 <- (current->signal->group_stop_count > 0)?
-(p8)	mov r8=0		// clear error code
-
-	or r18=r18,r19		// r18 <- current->pending | current->signal->shared_pending
-	;;
-	// r18 <- (current->pending | current->signal->shared_pending) & ~current->blocked:
-	andcm r18=r18,r14
-	add r9=TI_FLAGS+IA64_TASK_SIZE,r16
-	;;
-
-(p7)	cmp.ne.or.andcm p6,p7=r18,r0		// p6/p7 <- signal pending
-	mov r19=0					// i must not leak kernel bits...
-(p6)	br.cond.dpnt.many .sig_pending
-	;;
-
-1:	ld4 r17=[r9]				// r17 <- current->thread_info->flags
-	;;
-	mov ar.ccv=r17
-	and r18=~_TIF_SIGPENDING,r17		// r18 <- r17 & ~(1 << TIF_SIGPENDING)
-	;;
-
-	st8 [r2]=r14				// update current->blocked with new mask
-	cmpxchg4.acq r8=[r9],r18,ar.ccv		// current->thread_info->flags <- r18
-	;;
-	cmp.ne p6,p0=r17,r8			// update failed?
-(p6)	br.cond.spnt.few 1b			// yes -> retry
-
-#ifdef CONFIG_SMP
-	// __ticket_spin_unlock(r31)
-	st2.rel [r31]=r20
-	mov r20=0					// i must not leak kernel bits...
-#endif
-	SSM_PSR_I(p0, p9, r31)
-	;;
-
-	srlz.d					// ensure psr.i is set again
-	mov r18=0					// i must not leak kernel bits...
-
-.store_mask:
-EX(.fail_efault, (p15) probe.w.fault r34, 3)	// verify user has write-access to *oset
-EX(.fail_efault, (p15) st8 [r34]=r3)
-	mov r2=0					// i must not leak kernel bits...
-	mov r3=0					// i must not leak kernel bits...
-	mov r8=0				// return 0
-	mov r9=0					// i must not leak kernel bits...
-	mov r14=0					// i must not leak kernel bits...
-	mov r17=0					// i must not leak kernel bits...
-	mov r31=0					// i must not leak kernel bits...
-	FSYS_RETURN
-
-.sig_pending:
-#ifdef CONFIG_SMP
-	// __ticket_spin_unlock(r31)
-	st2.rel [r31]=r20			// release the lock
-#endif
-	SSM_PSR_I(p0, p9, r17)
-	;;
-	srlz.d
-	br.sptk.many fsys_fallback_syscall	// with signal pending, do the heavy-weight syscall
-
-#ifdef CONFIG_SMP
-.lock_contention:
-	/* Rather than spinning here, fall back on doing a heavy-weight syscall.  */
-	SSM_PSR_I(p0, p9, r17)
-	;;
-	srlz.d
-	br.sptk.many fsys_fallback_syscall
-#endif
-END(fsys_rt_sigprocmask)
-
-/*
  * fsys_getcpu doesn't use the third parameter in this implementation. It reads
  * current_thread_info()->cpu and corresponding node in cpu_to_node_map.
  */
@@ -916,7 +747,7 @@ paravirt_fsyscall_table:
 	data8 0				// sigaltstack
 	data8 0				// rt_sigaction
 	data8 0				// rt_sigpending
-	data8 fsys_rt_sigprocmask	// rt_sigprocmask
+	data8 0				// rt_sigprocmask
 	data8 0				// rt_sigqueueinfo	// 1180
 	data8 0				// rt_sigreturn
 	data8 0				// rt_sigsuspend
-- 
1.7.7.6

