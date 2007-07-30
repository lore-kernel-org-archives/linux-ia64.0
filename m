From: Stephane Eranian <eranian@hpl.hp.com>
Date: Mon, 30 Jul 2007 09:30:34 +0000
Subject: [PATCH] remove unused TIF_NOTIFY_RESUME (take 2)
Message-Id: <20070730093034.GD25162@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070523095743.GC28832@frankl.hpl.hp.com>
In-Reply-To: <20070523095743.GC28832@frankl.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Stephane Eranian <eranian@hpl.hp.com>, ak@suse.de, akpm@linux-foundation.org, linux-ia64@vger.kernel.org, tony.luck@intel.com

Hello,

This following patch removes the TIF_NOTIFY_RESUME flag for thread_info. It is unused
on all but the IA-64 architecture. This is take 2 of this patch. In this version,
The definition is removed but no re-numbering of the TIF flags is done to minimize
the possibility of errors and reduce the size of the patch.

For IA-64, we ran out of low-order bits (first 7 bits). Adding a bit for perfmon
would cause important code rescheduling changes in the kernel entry/exit path. Instead,
we replace TIF_NOTIFY_RESUME with TIF_PERFMON_WORK. This way we get very close to what the
new perfmon code base is doing.


thread_info: remove unused TIF_NOTIFY_RESUME, add TIF_PERFMON_WORK to IA-64

Signed-off-by: Stephane Eranian <eranian@hpl.hp.com>

diff --git a/arch/arm/kernel/entry-common.S b/arch/arm/kernel/entry-common.S
index c589dc3..33e6cc2 100644
--- a/arch/arm/kernel/entry-common.S
+++ b/arch/arm/kernel/entry-common.S
@@ -46,7 +46,7 @@ fast_work_pending:
 work_pending:
 	tst	r1, #_TIF_NEED_RESCHED
 	bne	work_resched
-	tst	r1, #_TIF_NOTIFY_RESUME | _TIF_SIGPENDING
+	tst	r1, #_TIF_SIGPENDING
 	beq	no_work_pending
 	mov	r0, sp				@ 'regs'
 	mov	r2, why				@ 'syscall'
diff --git a/arch/arm26/kernel/entry.S b/arch/arm26/kernel/entry.S
index 91496cc..7ffcc6e 100644
--- a/arch/arm26/kernel/entry.S
+++ b/arch/arm26/kernel/entry.S
@@ -194,7 +194,7 @@ fast_work_pending:
 work_pending:
 	tst	r1, #_TIF_NEED_RESCHED
 	bne	work_resched
-	tst	r1, #_TIF_NOTIFY_RESUME | _TIF_SIGPENDING
+	tst	r1, #_TIF_SIGPENDING
 	beq	no_work_pending
 	mov	r0, sp				@ 'regs'
 	mov	r2, why				@ 'syscall'
diff --git a/arch/ia64/kernel/perfmon.c b/arch/ia64/kernel/perfmon.c
index b7133ca..af49b8f 100644
--- a/arch/ia64/kernel/perfmon.c
+++ b/arch/ia64/kernel/perfmon.c
@@ -361,9 +361,6 @@ typedef struct pfm_context {
 #define ctx_fl_no_msg		ctx_flags.no_msg
 #define ctx_fl_can_restart	ctx_flags.can_restart
 
-#define PFM_SET_WORK_PENDING(t, v)	do { (t)->thread.pfm_needs_checking = v; } while(0);
-#define PFM_GET_WORK_PENDING(t)		(t)->thread.pfm_needs_checking
-
 /*
  * global information about all sessions
  * mostly used to synchronize between system wide and per-process
@@ -591,13 +588,13 @@ pfm_set_task_notify(struct task_struct *task)
 	struct thread_info *info;
 
 	info = (struct thread_info *) ((char *) task + IA64_TASK_SIZE);
-	set_bit(TIF_NOTIFY_RESUME, &info->flags);
+	set_bit(TIF_PERFMON_WORK, &info->flags);
 }
 
 static inline void
 pfm_clear_task_notify(void)
 {
-	clear_thread_flag(TIF_NOTIFY_RESUME);
+	clear_thread_flag(TIF_PERFMON_WORK);
 }
 
 static inline void
@@ -3728,7 +3725,7 @@ pfm_restart(pfm_context_t *ctx, void *arg, int count, struct pt_regs *regs)
 
 		ctx->ctx_fl_trap_reason = PFM_TRAP_REASON_RESET;
 
-		PFM_SET_WORK_PENDING(task, 1);
+		set_ti_thread_flag(task_thread_info(task), TIF_PERFMON_WORK);
 
 		pfm_set_task_notify(task);
 
@@ -4609,7 +4606,7 @@ pfm_context_unload(pfm_context_t *ctx, void *arg, int count, struct pt_regs *reg
 	task->thread.pfm_context  = NULL;
 	ctx->ctx_task             = NULL;
 
-	PFM_SET_WORK_PENDING(task, 0);
+	clear_ti_thread_flag(task_thread_info(task), TIF_PERFMON_WORK);
 
 	ctx->ctx_fl_trap_reason  = PFM_TRAP_REASON_NONE;
 	ctx->ctx_fl_can_restart  = 0;
@@ -5085,7 +5082,7 @@ pfm_handle_work(void)
 
 	PROTECT_CTX(ctx, flags);
 
-	PFM_SET_WORK_PENDING(current, 0);
+	clear_thread_flag(TIF_PERFMON_WORK);
 
 	pfm_clear_task_notify();
 
@@ -5449,7 +5446,7 @@ pfm_overflow_handler(struct task_struct *task, pfm_context_t *ctx, u64 pmc0, str
 			/*
 			 * set the perfmon specific checking pending work for the task
 			 */
-			PFM_SET_WORK_PENDING(task, 1);
+			set_ti_thread_flag(task_thread_info(task), TIF_PERFMON_WORK);
 
 			/*
 			 * when coming from ctxsw, current still points to the
@@ -5464,9 +5461,8 @@ pfm_overflow_handler(struct task_struct *task, pfm_context_t *ctx, u64 pmc0, str
 		must_notify = 1;
 	}
 
-	DPRINT_ovfl(("owner [%d] pending=%ld reason=%u ovfl_pmds=0x%lx ovfl_notify=0x%lx masked=%d\n",
+	DPRINT_ovfl(("owner [%d] reason=%u ovfl_pmds=0x%lx ovfl_notify=0x%lx masked=%d\n",
 			GET_PMU_OWNER() ? GET_PMU_OWNER()->pid : -1,
-			PFM_GET_WORK_PENDING(task),
 			ctx->ctx_fl_trap_reason,
 			ovfl_pmds,
 			ovfl_notify,
@@ -5884,7 +5880,7 @@ pfm_force_cleanup(pfm_context_t *ctx, struct pt_regs *regs)
 	/*
 	 * disconnect the task from the context and vice-versa
 	 */
-	PFM_SET_WORK_PENDING(task, 0);
+	clear_ti_thread_flag(task_thread_info(task), TIF_PERFMON_WORK);
 
 	task->thread.pfm_context  = NULL;
 	task->thread.flags       &= ~IA64_THREAD_PM_VALID;
@@ -6864,7 +6860,7 @@ pfm_inherit(struct task_struct *task, struct pt_regs *regs)
 	 */
 	thread->pfm_context = NULL;
 
-	PFM_SET_WORK_PENDING(task, 0);
+	clear_ti_thread_flag(task_thread_info(task), TIF_PERFMON_WORK);
 
 	/*
 	 * the psr bits are already set properly in copy_threads()
diff --git a/arch/ia64/kernel/process.c b/arch/ia64/kernel/process.c
index 4158906..ede2da2 100644
--- a/arch/ia64/kernel/process.c
+++ b/arch/ia64/kernel/process.c
@@ -165,7 +165,7 @@ do_notify_resume_user (sigset_t *unused, struct sigscratch *scr, long in_syscall
 	}
 
 #ifdef CONFIG_PERFMON
-	if (current->thread.pfm_needs_checking)
+	if (test_thread_flag(TIF_PERFMON_WORK))
 		pfm_handle_work();
 #endif
 
diff --git a/arch/powerpc/kernel/entry_64.S b/arch/powerpc/kernel/entry_64.S
index 2b66d53..9ef28da 100644
--- a/arch/powerpc/kernel/entry_64.S
+++ b/arch/powerpc/kernel/entry_64.S
@@ -546,7 +546,6 @@ END_FW_FTR_SECTION_IFSET(FW_FEATURE_ISERIES)
 	rfid
 	b	.	/* prevent speculative execution */
 
-/* Note: this must change if we start using the TIF_NOTIFY_RESUME bit */
 do_work:
 #ifdef CONFIG_PREEMPT
 	andi.	r0,r3,MSR_PR	/* Returning to user mode? */
diff --git a/arch/x86_64/kernel/entry.S b/arch/x86_64/kernel/entry.S
index 830cfc6..1d232e5 100644
--- a/arch/x86_64/kernel/entry.S
+++ b/arch/x86_64/kernel/entry.S
@@ -282,7 +282,7 @@ sysret_careful:
 sysret_signal:
 	TRACE_IRQS_ON
 	sti
-	testl $(_TIF_SIGPENDING|_TIF_NOTIFY_RESUME|_TIF_SINGLESTEP|_TIF_MCE_NOTIFY),%edx
+	testl $(_TIF_SIGPENDING|_TIF_SINGLESTEP|_TIF_MCE_NOTIFY),%edx
 	jz    1f
 
 	/* Really a signal */
@@ -375,7 +375,7 @@ int_very_careful:
 	jmp int_restore_rest
 	
 int_signal:
-	testl $(_TIF_NOTIFY_RESUME|_TIF_SIGPENDING|_TIF_SINGLESTEP|_TIF_MCE_NOTIFY),%edx
+	testl $(_TIF_SIGPENDING|_TIF_SINGLESTEP|_TIF_MCE_NOTIFY),%edx
 	jz 1f
 	movq %rsp,%rdi		# &ptregs -> arg1
 	xorl %esi,%esi		# oldset -> arg2
@@ -599,7 +599,7 @@ retint_careful:
 	jmp retint_check
 	
 retint_signal:
-	testl $(_TIF_SIGPENDING|_TIF_NOTIFY_RESUME|_TIF_SINGLESTEP|_TIF_MCE_NOTIFY),%edx
+	testl $(_TIF_SIGPENDING|_TIF_SINGLESTEP|_TIF_MCE_NOTIFY),%edx
 	jz    retint_swapgs
 	TRACE_IRQS_ON
 	sti
diff --git a/include/asm-alpha/thread_info.h b/include/asm-alpha/thread_info.h
index 48a22e3..beadb49 100644
--- a/include/asm-alpha/thread_info.h
+++ b/include/asm-alpha/thread_info.h
@@ -67,7 +67,6 @@ register struct thread_info *__current_thread_info __asm__("$8");
  * TIF_SYSCALL_TRACE is known to be 0 via blbs.
  */
 #define TIF_SYSCALL_TRACE	0	/* syscall trace active */
-#define TIF_NOTIFY_RESUME	1	/* resumption notification requested */
 #define TIF_SIGPENDING		2	/* signal pending */
 #define TIF_NEED_RESCHED	3	/* rescheduling necessary */
 #define TIF_POLLING_NRFLAG	4	/* poll_idle is polling NEED_RESCHED */
@@ -79,15 +78,13 @@ register struct thread_info *__current_thread_info __asm__("$8");
 #define TIF_RESTORE_SIGMASK	10	/* restore signal mask in do_signal */
 
 #define _TIF_SYSCALL_TRACE	(1<<TIF_SYSCALL_TRACE)
-#define _TIF_NOTIFY_RESUME	(1<<TIF_NOTIFY_RESUME)
 #define _TIF_SIGPENDING		(1<<TIF_SIGPENDING)
 #define _TIF_NEED_RESCHED	(1<<TIF_NEED_RESCHED)
 #define _TIF_POLLING_NRFLAG	(1<<TIF_POLLING_NRFLAG)
 #define _TIF_RESTORE_SIGMASK	(1<<TIF_RESTORE_SIGMASK)
 
 /* Work to do on interrupt/exception return.  */
-#define _TIF_WORK_MASK		(_TIF_NOTIFY_RESUME	\
-				 | _TIF_SIGPENDING	\
+#define _TIF_WORK_MASK		( _TIF_SIGPENDING	\
 				 | _TIF_NEED_RESCHED)
 
 /* Work to do on any return to userspace.  */
diff --git a/include/asm-arm/thread_info.h b/include/asm-arm/thread_info.h
index 69c65d5..b2b5453 100644
--- a/include/asm-arm/thread_info.h
+++ b/include/asm-arm/thread_info.h
@@ -134,13 +134,11 @@ extern void iwmmxt_task_switch(struct thread_info *);
 /*
  * thread information flags:
  *  TIF_SYSCALL_TRACE	- syscall trace active
- *  TIF_NOTIFY_RESUME	- resumption notification requested
  *  TIF_SIGPENDING	- signal pending
  *  TIF_NEED_RESCHED	- rescheduling necessary
  *  TIF_USEDFPU		- FPU was used by this task this quantum (SMP)
  *  TIF_POLLING_NRFLAG	- true if poll_idle() is polling TIF_NEED_RESCHED
  */
-#define TIF_NOTIFY_RESUME	0
 #define TIF_SIGPENDING		1
 #define TIF_NEED_RESCHED	2
 #define TIF_SYSCALL_TRACE	8
@@ -149,7 +147,6 @@ extern void iwmmxt_task_switch(struct thread_info *);
 #define TIF_MEMDIE		18
 #define TIF_FREEZE		19
 
-#define _TIF_NOTIFY_RESUME	(1 << TIF_NOTIFY_RESUME)
 #define _TIF_SIGPENDING		(1 << TIF_SIGPENDING)
 #define _TIF_NEED_RESCHED	(1 << TIF_NEED_RESCHED)
 #define _TIF_SYSCALL_TRACE	(1 << TIF_SYSCALL_TRACE)
diff --git a/include/asm-arm26/thread_info.h b/include/asm-arm26/thread_info.h
index 9b367eb..e36aab1 100644
--- a/include/asm-arm26/thread_info.h
+++ b/include/asm-arm26/thread_info.h
@@ -110,13 +110,11 @@ extern void free_thread_info(struct thread_info *);
 /*
  * thread information flags:
  *  TIF_SYSCALL_TRACE	- syscall trace active
- *  TIF_NOTIFY_RESUME	- resumption notification requested
  *  TIF_SIGPENDING	- signal pending
  *  TIF_NEED_RESCHED	- rescheduling necessary
  *  TIF_USEDFPU		- FPU was used by this task this quantum (SMP)
  *  TIF_POLLING_NRFLAG	- true if poll_idle() is polling TIF_NEED_RESCHED
  */
-#define TIF_NOTIFY_RESUME	0
 #define TIF_SIGPENDING		1
 #define TIF_NEED_RESCHED	2
 #define TIF_SYSCALL_TRACE	8
@@ -124,7 +122,6 @@ extern void free_thread_info(struct thread_info *);
 #define TIF_POLLING_NRFLAG	17
 #define TIF_MEMDIE		18
 
-#define _TIF_NOTIFY_RESUME	(1 << TIF_NOTIFY_RESUME)
 #define _TIF_SIGPENDING		(1 << TIF_SIGPENDING)
 #define _TIF_NEED_RESCHED	(1 << TIF_NEED_RESCHED)
 #define _TIF_SYSCALL_TRACE	(1 << TIF_SYSCALL_TRACE)
diff --git a/include/asm-avr32/thread_info.h b/include/asm-avr32/thread_info.h
index a2e606d..8265896 100644
--- a/include/asm-avr32/thread_info.h
+++ b/include/asm-avr32/thread_info.h
@@ -74,7 +74,6 @@ static inline struct thread_info *current_thread_info(void)
  * - other flags in MSW
  */
 #define TIF_SYSCALL_TRACE       0       /* syscall trace active */
-#define TIF_NOTIFY_RESUME       1       /* resumption notification requested */
 #define TIF_SIGPENDING          2       /* signal pending */
 #define TIF_NEED_RESCHED        3       /* rescheduling necessary */
 #define TIF_POLLING_NRFLAG      4       /* true if poll_idle() is polling
@@ -87,7 +86,6 @@ static inline struct thread_info *current_thread_info(void)
 #define TIF_USERSPACE		31      /* true if FS sets userspace */
 
 #define _TIF_SYSCALL_TRACE	(1 << TIF_SYSCALL_TRACE)
-#define _TIF_NOTIFY_RESUME	(1 << TIF_NOTIFY_RESUME)
 #define _TIF_SIGPENDING		(1 << TIF_SIGPENDING)
 #define _TIF_NEED_RESCHED	(1 << TIF_NEED_RESCHED)
 #define _TIF_POLLING_NRFLAG	(1 << TIF_POLLING_NRFLAG)
diff --git a/include/asm-blackfin/thread_info.h b/include/asm-blackfin/thread_info.h
index 34d3c2e..1f31080 100644
--- a/include/asm-blackfin/thread_info.h
+++ b/include/asm-blackfin/thread_info.h
@@ -118,7 +118,6 @@ static inline struct thread_info *current_thread_info(void)
  * thread information flag bit numbers
  */
 #define TIF_SYSCALL_TRACE	0	/* syscall trace active */
-#define TIF_NOTIFY_RESUME	1	/* resumption notification requested */
 #define TIF_SIGPENDING		2	/* signal pending */
 #define TIF_NEED_RESCHED	3	/* rescheduling necessary */
 #define TIF_POLLING_NRFLAG	4	/* true if poll_idle() is polling
@@ -129,7 +128,6 @@ static inline struct thread_info *current_thread_info(void)
 
 /* as above, but as bit values */
 #define _TIF_SYSCALL_TRACE	(1<<TIF_SYSCALL_TRACE)
-#define _TIF_NOTIFY_RESUME	(1<<TIF_NOTIFY_RESUME)
 #define _TIF_SIGPENDING		(1<<TIF_SIGPENDING)
 #define _TIF_NEED_RESCHED	(1<<TIF_NEED_RESCHED)
 #define _TIF_POLLING_NRFLAG	(1<<TIF_POLLING_NRFLAG)
diff --git a/include/asm-cris/thread_info.h b/include/asm-cris/thread_info.h
index 7ad853c..061d8c7 100644
--- a/include/asm-cris/thread_info.h
+++ b/include/asm-cris/thread_info.h
@@ -79,14 +79,12 @@ struct thread_info {
  * - other flags in MSW
  */
 #define TIF_SYSCALL_TRACE	0	/* syscall trace active */
-#define TIF_NOTIFY_RESUME	1	/* resumption notification requested */
 #define TIF_SIGPENDING		2	/* signal pending */
 #define TIF_NEED_RESCHED	3	/* rescheduling necessary */
 #define TIF_POLLING_NRFLAG	16	/* true if poll_idle() is polling TIF_NEED_RESCHED */
 #define TIF_MEMDIE		17
 
 #define _TIF_SYSCALL_TRACE	(1<<TIF_SYSCALL_TRACE)
-#define _TIF_NOTIFY_RESUME	(1<<TIF_NOTIFY_RESUME)
 #define _TIF_SIGPENDING		(1<<TIF_SIGPENDING)
 #define _TIF_NEED_RESCHED	(1<<TIF_NEED_RESCHED)
 #define _TIF_POLLING_NRFLAG	(1<<TIF_POLLING_NRFLAG)
diff --git a/include/asm-frv/thread_info.h b/include/asm-frv/thread_info.h
index d881f51..d1adad4 100644
--- a/include/asm-frv/thread_info.h
+++ b/include/asm-frv/thread_info.h
@@ -108,7 +108,6 @@ register struct thread_info *__current_thread_info asm("gr15");
  * - other flags in MSW
  */
 #define TIF_SYSCALL_TRACE	0	/* syscall trace active */
-#define TIF_NOTIFY_RESUME	1	/* resumption notification requested */
 #define TIF_SIGPENDING		2	/* signal pending */
 #define TIF_NEED_RESCHED	3	/* rescheduling necessary */
 #define TIF_SINGLESTEP		4	/* restore singlestep on return to user mode */
@@ -119,7 +118,6 @@ register struct thread_info *__current_thread_info asm("gr15");
 #define TIF_FREEZE		18	/* freezing for suspend */
 
 #define _TIF_SYSCALL_TRACE	(1 << TIF_SYSCALL_TRACE)
-#define _TIF_NOTIFY_RESUME	(1 << TIF_NOTIFY_RESUME)
 #define _TIF_SIGPENDING		(1 << TIF_SIGPENDING)
 #define _TIF_NEED_RESCHED	(1 << TIF_NEED_RESCHED)
 #define _TIF_SINGLESTEP		(1 << TIF_SINGLESTEP)
diff --git a/include/asm-h8300/thread_info.h b/include/asm-h8300/thread_info.h
index aee4009..d347a06 100644
--- a/include/asm-h8300/thread_info.h
+++ b/include/asm-h8300/thread_info.h
@@ -86,7 +86,6 @@ static inline struct thread_info *current_thread_info(void)
  * thread information flag bit numbers
  */
 #define TIF_SYSCALL_TRACE	0	/* syscall trace active */
-#define TIF_NOTIFY_RESUME	1	/* resumption notification requested */
 #define TIF_SIGPENDING		2	/* signal pending */
 #define TIF_NEED_RESCHED	3	/* rescheduling necessary */
 #define TIF_POLLING_NRFLAG	4	/* true if poll_idle() is polling
@@ -96,7 +95,6 @@ static inline struct thread_info *current_thread_info(void)
 
 /* as above, but as bit values */
 #define _TIF_SYSCALL_TRACE	(1<<TIF_SYSCALL_TRACE)
-#define _TIF_NOTIFY_RESUME	(1<<TIF_NOTIFY_RESUME)
 #define _TIF_SIGPENDING		(1<<TIF_SIGPENDING)
 #define _TIF_NEED_RESCHED	(1<<TIF_NEED_RESCHED)
 #define _TIF_POLLING_NRFLAG	(1<<TIF_POLLING_NRFLAG)
diff --git a/include/asm-i386/thread_info.h b/include/asm-i386/thread_info.h
index 54424e0..e776620 100644
--- a/include/asm-i386/thread_info.h
+++ b/include/asm-i386/thread_info.h
@@ -124,7 +124,6 @@ static inline struct thread_info *current_thread_info(void)
  * - other flags in MSW
  */
 #define TIF_SYSCALL_TRACE	0	/* syscall trace active */
-#define TIF_NOTIFY_RESUME	1	/* resumption notification requested */
 #define TIF_SIGPENDING		2	/* signal pending */
 #define TIF_NEED_RESCHED	3	/* rescheduling necessary */
 #define TIF_SINGLESTEP		4	/* restore singlestep on return to user mode */
@@ -140,7 +139,6 @@ static inline struct thread_info *current_thread_info(void)
 #define TIF_NOTSC		20	/* TSC is not accessible in userland */
 
 #define _TIF_SYSCALL_TRACE	(1<<TIF_SYSCALL_TRACE)
-#define _TIF_NOTIFY_RESUME	(1<<TIF_NOTIFY_RESUME)
 #define _TIF_SIGPENDING		(1<<TIF_SIGPENDING)
 #define _TIF_NEED_RESCHED	(1<<TIF_NEED_RESCHED)
 #define _TIF_SINGLESTEP		(1<<TIF_SINGLESTEP)
diff --git a/include/asm-ia64/thread_info.h b/include/asm-ia64/thread_info.h
index 7d0241d..f0d64b2 100644
--- a/include/asm-ia64/thread_info.h
+++ b/include/asm-ia64/thread_info.h
@@ -79,7 +79,7 @@ struct thread_info {
  * - pending work-to-be-done flags are in least-significant 16 bits, other flags
  *   in top 16 bits
  */
-#define TIF_NOTIFY_RESUME	0	/* resumption notification requested */
+#define TIF_PERFMON_WORK	0	/* work for pfm_handle_work() */
 #define TIF_SIGPENDING		1	/* signal pending */
 #define TIF_NEED_RESCHED	2	/* rescheduling necessary */
 #define TIF_SYSCALL_TRACE	3	/* syscall trace active */
@@ -96,7 +96,6 @@ struct thread_info {
 #define _TIF_SYSCALL_AUDIT	(1 << TIF_SYSCALL_AUDIT)
 #define _TIF_SINGLESTEP		(1 << TIF_SINGLESTEP)
 #define _TIF_SYSCALL_TRACEAUDIT	(_TIF_SYSCALL_TRACE|_TIF_SYSCALL_AUDIT|_TIF_SINGLESTEP)
-#define _TIF_NOTIFY_RESUME	(1 << TIF_NOTIFY_RESUME)
 #define _TIF_RESTORE_SIGMASK	(1 << TIF_RESTORE_SIGMASK)
 #define _TIF_SIGPENDING		(1 << TIF_SIGPENDING)
 #define _TIF_NEED_RESCHED	(1 << TIF_NEED_RESCHED)
@@ -104,9 +103,11 @@ struct thread_info {
 #define _TIF_MCA_INIT		(1 << TIF_MCA_INIT)
 #define _TIF_DB_DISABLED	(1 << TIF_DB_DISABLED)
 #define _TIF_FREEZE		(1 << TIF_FREEZE)
+#define _TIF_PERFMON_WORK	(1 << TIF_PERFMON_WORK)
 
 /* "work to do on user-return" bits */
-#define TIF_ALLWORK_MASK	(_TIF_NOTIFY_RESUME|_TIF_SIGPENDING|_TIF_NEED_RESCHED|_TIF_SYSCALL_TRACE|_TIF_SYSCALL_AUDIT|_TIF_RESTORE_SIGMASK)
+#define TIF_ALLWORK_MASK	(_TIF_SIGPENDING|_TIF_NEED_RESCHED|_TIF_SYSCALL_TRACE|\
+				 _TIF_PERFMON_WORK|_TIF_SYSCALL_AUDIT|_TIF_RESTORE_SIGMASK)
 /* like TIF_ALLWORK_BITS but sans TIF_SYSCALL_TRACE or TIF_SYSCALL_AUDIT */
 #define TIF_WORK_MASK		(TIF_ALLWORK_MASK&~(_TIF_SYSCALL_TRACE|_TIF_SYSCALL_AUDIT))
 
diff --git a/include/asm-m32r/thread_info.h b/include/asm-m32r/thread_info.h
index 22aff32..845a796 100644
--- a/include/asm-m32r/thread_info.h
+++ b/include/asm-m32r/thread_info.h
@@ -146,7 +146,6 @@ static inline unsigned int get_thread_fault_code(void)
  * - other flags in MSW
  */
 #define TIF_SYSCALL_TRACE	0	/* syscall trace active */
-#define TIF_NOTIFY_RESUME	1	/* resumption notification requested */
 #define TIF_SIGPENDING		2	/* signal pending */
 #define TIF_NEED_RESCHED	3	/* rescheduling necessary */
 #define TIF_SINGLESTEP		4	/* restore singlestep on return to user mode */
@@ -156,7 +155,6 @@ static inline unsigned int get_thread_fault_code(void)
 #define TIF_MEMDIE		17
 
 #define _TIF_SYSCALL_TRACE	(1<<TIF_SYSCALL_TRACE)
-#define _TIF_NOTIFY_RESUME	(1<<TIF_NOTIFY_RESUME)
 #define _TIF_SIGPENDING		(1<<TIF_SIGPENDING)
 #define _TIF_NEED_RESCHED	(1<<TIF_NEED_RESCHED)
 #define _TIF_SINGLESTEP		(1<<TIF_SINGLESTEP)
diff --git a/include/asm-m68knommu/thread_info.h b/include/asm-m68knommu/thread_info.h
index b8f009e..81bb037 100644
--- a/include/asm-m68knommu/thread_info.h
+++ b/include/asm-m68knommu/thread_info.h
@@ -83,7 +83,6 @@ static inline struct thread_info *current_thread_info(void)
  * thread information flag bit numbers
  */
 #define TIF_SYSCALL_TRACE	0	/* syscall trace active */
-#define TIF_NOTIFY_RESUME	1	/* resumption notification requested */
 #define TIF_SIGPENDING		2	/* signal pending */
 #define TIF_NEED_RESCHED	3	/* rescheduling necessary */
 #define TIF_POLLING_NRFLAG	4	/* true if poll_idle() is polling
@@ -92,7 +91,6 @@ static inline struct thread_info *current_thread_info(void)
 
 /* as above, but as bit values */
 #define _TIF_SYSCALL_TRACE	(1<<TIF_SYSCALL_TRACE)
-#define _TIF_NOTIFY_RESUME	(1<<TIF_NOTIFY_RESUME)
 #define _TIF_SIGPENDING		(1<<TIF_SIGPENDING)
 #define _TIF_NEED_RESCHED	(1<<TIF_NEED_RESCHED)
 #define _TIF_POLLING_NRFLAG	(1<<TIF_POLLING_NRFLAG)
diff --git a/include/asm-mips/thread_info.h b/include/asm-mips/thread_info.h
index fbcda82..bf373c5 100644
--- a/include/asm-mips/thread_info.h
+++ b/include/asm-mips/thread_info.h
@@ -109,7 +109,6 @@ register struct thread_info *__current_thread_info __asm__("$28");
  * - pending work-to-be-done flags are in LSW
  * - other flags in MSW
  */
-#define TIF_NOTIFY_RESUME	1	/* resumption notification requested */
 #define TIF_SIGPENDING		2	/* signal pending */
 #define TIF_NEED_RESCHED	3	/* rescheduling necessary */
 #define TIF_SYSCALL_AUDIT	4	/* syscall auditing active */
@@ -122,7 +121,6 @@ register struct thread_info *__current_thread_info __asm__("$28");
 #define TIF_SYSCALL_TRACE	31	/* syscall trace active */
 
 #define _TIF_SYSCALL_TRACE	(1<<TIF_SYSCALL_TRACE)
-#define _TIF_NOTIFY_RESUME	(1<<TIF_NOTIFY_RESUME)
 #define _TIF_SIGPENDING		(1<<TIF_SIGPENDING)
 #define _TIF_NEED_RESCHED	(1<<TIF_NEED_RESCHED)
 #define _TIF_SYSCALL_AUDIT	(1<<TIF_SYSCALL_AUDIT)
diff --git a/include/asm-parisc/thread_info.h b/include/asm-parisc/thread_info.h
index 949314c..d4b09ff 100644
--- a/include/asm-parisc/thread_info.h
+++ b/include/asm-parisc/thread_info.h
@@ -56,7 +56,6 @@ struct thread_info {
  * thread information flags
  */
 #define TIF_SYSCALL_TRACE	0	/* syscall trace active */
-#define TIF_NOTIFY_RESUME	1	/* resumption notification requested */
 #define TIF_SIGPENDING		2	/* signal pending */
 #define TIF_NEED_RESCHED	3	/* rescheduling necessary */
 #define TIF_POLLING_NRFLAG	4	/* true if poll_idle() is polling TIF_NEED_RESCHED */
@@ -65,14 +64,13 @@ struct thread_info {
 #define TIF_RESTORE_SIGMASK	7	/* restore saved signal mask */
 
 #define _TIF_SYSCALL_TRACE	(1 << TIF_SYSCALL_TRACE)
-#define _TIF_NOTIFY_RESUME	(1 << TIF_NOTIFY_RESUME)
 #define _TIF_SIGPENDING		(1 << TIF_SIGPENDING)
 #define _TIF_NEED_RESCHED	(1 << TIF_NEED_RESCHED)
 #define _TIF_POLLING_NRFLAG	(1 << TIF_POLLING_NRFLAG)
 #define _TIF_32BIT		(1 << TIF_32BIT)
 #define _TIF_RESTORE_SIGMASK	(1 << TIF_RESTORE_SIGMASK)
 
-#define _TIF_USER_WORK_MASK     (_TIF_NOTIFY_RESUME | _TIF_SIGPENDING | \
+#define _TIF_USER_WORK_MASK     ( _TIF_SIGPENDING | \
                                  _TIF_NEED_RESCHED | _TIF_RESTORE_SIGMASK)
 
 #endif /* __KERNEL__ */
diff --git a/include/asm-powerpc/thread_info.h b/include/asm-powerpc/thread_info.h
index 9d9aeca..deefa68 100644
--- a/include/asm-powerpc/thread_info.h
+++ b/include/asm-powerpc/thread_info.h
@@ -107,7 +107,6 @@ static inline struct thread_info *current_thread_info(void)
  * thread information flag bit numbers
  */
 #define TIF_SYSCALL_TRACE	0	/* syscall trace active */
-#define TIF_NOTIFY_RESUME	1	/* resumption notification requested */
 #define TIF_SIGPENDING		2	/* signal pending */
 #define TIF_NEED_RESCHED	3	/* rescheduling necessary */
 #define TIF_POLLING_NRFLAG	4	/* true if poll_idle() is polling
@@ -128,7 +127,6 @@ static inline struct thread_info *current_thread_info(void)
 
 /* as above, but as bit values */
 #define _TIF_SYSCALL_TRACE	(1<<TIF_SYSCALL_TRACE)
-#define _TIF_NOTIFY_RESUME	(1<<TIF_NOTIFY_RESUME)
 #define _TIF_SIGPENDING		(1<<TIF_SIGPENDING)
 #define _TIF_NEED_RESCHED	(1<<TIF_NEED_RESCHED)
 #define _TIF_POLLING_NRFLAG	(1<<TIF_POLLING_NRFLAG)
@@ -146,7 +144,7 @@ static inline struct thread_info *current_thread_info(void)
 #define _TIF_ABI_PENDING	(1<<TIF_ABI_PENDING)
 #define _TIF_SYSCALL_T_OR_A	(_TIF_SYSCALL_TRACE|_TIF_SYSCALL_AUDIT|_TIF_SECCOMP)
 
-#define _TIF_USER_WORK_MASK	(_TIF_NOTIFY_RESUME | _TIF_SIGPENDING | \
+#define _TIF_USER_WORK_MASK	( _TIF_SIGPENDING | \
 				 _TIF_NEED_RESCHED | _TIF_RESTORE_SIGMASK)
 #define _TIF_PERSYSCALL_MASK	(_TIF_RESTOREALL|_TIF_NOERROR)
 
diff --git a/include/asm-sh/thread_info.h b/include/asm-sh/thread_info.h
index 31d55e3..d9286b6 100644
--- a/include/asm-sh/thread_info.h
+++ b/include/asm-sh/thread_info.h
@@ -107,7 +107,6 @@ static inline struct thread_info *current_thread_info(void)
  * - other flags in MSW
  */
 #define TIF_SYSCALL_TRACE	0	/* syscall trace active */
-#define TIF_NOTIFY_RESUME	1	/* resumption notification requested */
 #define TIF_SIGPENDING		2	/* signal pending */
 #define TIF_NEED_RESCHED	3	/* rescheduling necessary */
 #define TIF_RESTORE_SIGMASK	4	/* restore signal mask in do_signal() */
@@ -118,7 +117,6 @@ static inline struct thread_info *current_thread_info(void)
 #define TIF_FREEZE		19
 
 #define _TIF_SYSCALL_TRACE	(1<<TIF_SYSCALL_TRACE)
-#define _TIF_NOTIFY_RESUME	(1<<TIF_NOTIFY_RESUME)
 #define _TIF_SIGPENDING		(1<<TIF_SIGPENDING)
 #define _TIF_NEED_RESCHED	(1<<TIF_NEED_RESCHED)
 #define _TIF_RESTORE_SIGMASK	(1<<TIF_RESTORE_SIGMASK)
diff --git a/include/asm-v850/thread_info.h b/include/asm-v850/thread_info.h
index 82b8f28..558a42b 100644
--- a/include/asm-v850/thread_info.h
+++ b/include/asm-v850/thread_info.h
@@ -77,7 +77,6 @@ struct thread_info {
  * thread information flag bit numbers
  */
 #define TIF_SYSCALL_TRACE	0	/* syscall trace active */
-#define TIF_NOTIFY_RESUME	1	/* resumption notification requested */
 #define TIF_SIGPENDING		2	/* signal pending */
 #define TIF_NEED_RESCHED	3	/* rescheduling necessary */
 #define TIF_POLLING_NRFLAG	4	/* true if poll_idle() is polling
@@ -86,7 +85,6 @@ struct thread_info {
 
 /* as above, but as bit values */
 #define _TIF_SYSCALL_TRACE	(1<<TIF_SYSCALL_TRACE)
-#define _TIF_NOTIFY_RESUME	(1<<TIF_NOTIFY_RESUME)
 #define _TIF_SIGPENDING		(1<<TIF_SIGPENDING)
 #define _TIF_NEED_RESCHED	(1<<TIF_NEED_RESCHED)
 #define _TIF_POLLING_NRFLAG	(1<<TIF_POLLING_NRFLAG)
diff --git a/include/asm-x86_64/thread_info.h b/include/asm-x86_64/thread_info.h
index 33c72ef..beae2bf 100644
--- a/include/asm-x86_64/thread_info.h
+++ b/include/asm-x86_64/thread_info.h
@@ -107,7 +107,6 @@ static inline struct thread_info *stack_thread_info(void)
  * Warning: layout of LSW is hardcoded in entry.S
  */
 #define TIF_SYSCALL_TRACE	0	/* syscall trace active */
-#define TIF_NOTIFY_RESUME	1	/* resumption notification requested */
 #define TIF_SIGPENDING		2	/* signal pending */
 #define TIF_NEED_RESCHED	3	/* rescheduling necessary */
 #define TIF_SINGLESTEP		4	/* reenable singlestep on user return*/
@@ -126,7 +125,6 @@ static inline struct thread_info *stack_thread_info(void)
 #define TIF_FREEZE		23	/* is freezing for suspend */
 
 #define _TIF_SYSCALL_TRACE	(1<<TIF_SYSCALL_TRACE)
-#define _TIF_NOTIFY_RESUME	(1<<TIF_NOTIFY_RESUME)
 #define _TIF_SIGPENDING		(1<<TIF_SIGPENDING)
 #define _TIF_SINGLESTEP		(1<<TIF_SINGLESTEP)
 #define _TIF_NEED_RESCHED	(1<<TIF_NEED_RESCHED)
diff --git a/include/asm-xtensa/thread_info.h b/include/asm-xtensa/thread_info.h
index 3fa2979..ce168d0 100644
--- a/include/asm-xtensa/thread_info.h
+++ b/include/asm-xtensa/thread_info.h
@@ -110,7 +110,6 @@ static inline struct thread_info *current_thread_info(void)
  * - other flags in MSW
  */
 #define TIF_SYSCALL_TRACE	0	/* syscall trace active */
-#define TIF_NOTIFY_RESUME	1	/* resumption notification requested */
 #define TIF_SIGPENDING		2	/* signal pending */
 #define TIF_NEED_RESCHED	3	/* rescheduling necessary */
 #define TIF_SINGLESTEP		4	/* restore singlestep on return to user mode */
@@ -120,7 +119,6 @@ static inline struct thread_info *current_thread_info(void)
 #define TIF_POLLING_NRFLAG	16	/* true if poll_idle() is polling TIF_NEED_RESCHED */
 
 #define _TIF_SYSCALL_TRACE	(1<<TIF_SYSCALL_TRACE)
-#define _TIF_NOTIFY_RESUME	(1<<TIF_NOTIFY_RESUME)
 #define _TIF_SIGPENDING		(1<<TIF_SIGPENDING)
 #define _TIF_NEED_RESCHED	(1<<TIF_NEED_RESCHED)
 #define _TIF_SINGLESTEP		(1<<TIF_SINGLESTEP)
