From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 29 Jun 2004 18:42:47 +0000
Subject: Re: Fw: [Bugme-new] [Bug 2885] New: realtime process can't preempt low priority process in kernel
Message-Id: <16609.47143.757854.874764@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040614002931.00b846a4.akpm@osdl.org>
In-Reply-To: <20040614002931.00b846a4.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Peter,

Can you confirm that this patch also works for you?  It's your patch with
the following changes:

 o Consolidate code into a single #ifdef CONFIG_PREEMPT.
 o Replace unconditional "cmp.eq.unc" with "cmp.eq".
 o Cleanup/correct comment.
 o Sync up code in ia64_leave_kernel with ia64_leave_syscall.

Rest should be the same.

Two questions though: first, the code will call notify_resume_user
when returning to kernel-level execution if preempt_count is 0 and
current_thread_info()->need_resched() is 0.  Is this really what you
had in mind?

Second, isn't preempt_count necessarily 0 when returning to
user-level?  If so, it should be possible to simplify the
CONFIG_PREEMPT code a bit more.

Thanks,

	--david

>>>>> On Tue, 22 Jun 2004 09:57:43 +1000, Peter Chubb <peterc@gelato.unsw.edu.au> said:

  Peter> Here's a patch to fix OSDL BugMe 2885: IA64 preemption
  Peter> support.

  Peter> There is one small change in semantics: when returning from a
  Peter> preemption, the preemption flag will *not* be rechecked.
  Peter> Otherwise, I found that it was easy to get into a livelock
  Peter> situation where no forward progress was made.

---------------------------------------------------------------------------
ia64: Fix OSDL BugMe report 2885: realtime process can't preempt low priority process in kernel

Rearranged code to make it work. There were two problems:

 1. The preempt flag was being tested only if code was leaving for
    user space (the logic should be: test for RESCHEDULE if we're
    switching to a kernel thread, test everything if switching to a
    user thread)

 2. The check of the user space flags was being repeated even if the
    work had been done.

There is one small change in semantics: when returning from a
preemption, the preemption flag will *not* be rechecked.  Otherwise, I
found that it was easy to get into a livelock situation where no
forward progress was made.

=== arch/ia64/kernel/entry.S 1.60 vs edited ==--- 1.60/arch/ia64/kernel/entry.S	Wed Jun 16 21:12:18 2004
+++ edited/arch/ia64/kernel/entry.S	Tue Jun 29 11:17:02 2004
@@ -663,25 +663,31 @@
 	PT_REGS_UNWIND_INFO(0)
 	/*
 	 * work.need_resched etc. mustn't get changed by this CPU before it returns to
-	 * user- or fsys-mode, hence we disable interrupts early on:
+	 * user- or fsys-mode, hence we disable interrupts early on.
+	 *
+	 * p6 controls whether current_thread_info()->flags needs to be check for
+	 * extra work.  We always check for extra work when returning to user-level.
+	 * With CONFIG_PREEMPT, we also check for extra work when the preempt_count
+	 * is 0.  After extra work processing has been completed, execution
+	 * resumes at .work_processed_syscall with p6 set to 1 if the extra-work-check
+	 * needs to be redone.
 	 */
 #ifdef CONFIG_PREEMPT
 	rsm psr.i				// disable interrupts
-#else
-(pUStk)	rsm psr.i
-#endif
 	cmp.eq pLvSys,p0=r0,r0			// pLvSys=1: leave from syscall
-(pUStk)	cmp.eq.unc p6,p0=r0,r0			// p6 <- pUStk
-.work_processed_syscall:
-#ifdef CONFIG_PREEMPT
 (pKStk) adds r20=TI_PRE_COUNT+IA64_TASK_SIZE,r13
 	;;
 	.pred.rel.mutex pUStk,pKStk
 (pKStk) ld4 r21=[r20]			// r21 <- preempt_count
 (pUStk)	mov r21=0			// r21 <- 0
 	;;
-(p6)	cmp.eq.unc p6,p0=r21,r0		// p6 <- p6 && (r21 = 0)
-#endif /* CONFIG_PREEMPT */
+	cmp.eq p6,p0=r21,r0		// p6 <- pUStk || (preempt_count = 0)
+#else /* !CONFIG_PREEMPT */
+(pUStk)	rsm psr.i
+	cmp.eq pLvSys,p0=r0,r0		// pLvSys=1: leave from syscall
+(pUStk)	cmp.eq.unc p6,p0=r0,r0		// p6 <- pUStk
+#endif
+.work_processed_syscall:
 	adds r16=PT(LOADRS)+16,r12
 	adds r17=PT(AR_BSPSTORE)+16,r12
 	adds r18=TI_FLAGS+IA64_TASK_SIZE,r13
@@ -776,26 +782,31 @@
 	PT_REGS_UNWIND_INFO(0)
 	/*
 	 * work.need_resched etc. mustn't get changed by this CPU before it returns to
-	 * user- or fsys-mode, hence we disable interrupts early on:
+	 * user- or fsys-mode, hence we disable interrupts early on.
+	 *
+	 * p6 controls whether current_thread_info()->flags needs to be check for
+	 * extra work.  We always check for extra work when returning to user-level.
+	 * With CONFIG_PREEMPT, we also check for extra work when the preempt_count
+	 * is 0.  After extra work processing has been completed, execution
+	 * resumes at .work_processed_syscall with p6 set to 1 if the extra-work-check
+	 * needs to be redone.
 	 */
 #ifdef CONFIG_PREEMPT
 	rsm psr.i				// disable interrupts
-#else
-(pUStk)	rsm psr.i
-#endif
 	cmp.eq p0,pLvSys=r0,r0			// pLvSys=0: leave from kernel
-(pUStk)	cmp.eq.unc p6,p0=r0,r0			// p6 <- pUStk
-	;;
-.work_processed_kernel:
-#ifdef CONFIG_PREEMPT
-	adds r20=TI_PRE_COUNT+IA64_TASK_SIZE,r13
+(pKStk)	adds r20=TI_PRE_COUNT+IA64_TASK_SIZE,r13
 	;;
 	.pred.rel.mutex pUStk,pKStk
 (pKStk)	ld4 r21=[r20]			// r21 <- preempt_count
 (pUStk)	mov r21=0			// r21 <- 0
 	;;
-(p6)	cmp.eq.unc p6,p0=r21,r0		// p6 <- p6 && (r21 = 0)
-#endif /* CONFIG_PREEMPT */
+	cmp.eq p6,p0=r21,r0		// p6 <- pUStk || (preempt_count = 0)
+#else
+(pUStk)	rsm psr.i
+	cmp.eq p0,pLvSys=r0,r0		// pLvSys=0: leave from kernel
+(pUStk)	cmp.eq.unc p6,p0=r0,r0		// p6 <- pUStk
+#endif
+.work_processed_kernel:
 	adds r17=TI_FLAGS+IA64_TASK_SIZE,r13
 	;;
 (p6)	ld4 r31=[r17]				// load current_thread_info()->flags
