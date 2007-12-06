From: Stephane Eranian <eranian@hpl.hp.com>
Date: Thu, 06 Dec 2007 17:15:27 +0000
Subject: Re: [PATCH 1/3] Rename TIF_PERFMON_WORK back to TIF_NOTIFY_RESUME
Message-Id: <20071206171527.GG13304@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1196959881.6586.6.camel@elijah.suse.cz>
In-Reply-To: <1196959881.6586.6.camel@elijah.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello,

On Thu, Dec 06, 2007 at 05:51:21PM +0100, Petr Tesarik wrote:
> The RSE synchronization will need a TIF_ flag, but all work-to-be-done
> bits are already used, so we'll have to multiplex TIF_NOTIFY_RESUME
> again.
> 

Yes, I knew this was coming. I think it is okay to multiplex on
TIF_NOITFY_RESUME. However, I think it would be cleaner and likely
more efficient to add yet another TIF flags for perfmon instead of
adding the pfm_needs_checking field. That new TIF flag would not have
to be in the low 7 bits. It could be higher because it would not be
checked by the assembly code but rather in do_notify_resume_user().
The TIF limitation is just in the assembly code.

Any comments?


> Signed-off-by: Shaohua Li <shaohua.li@intel.com>
> Signed-off-by: Petr Tesarik <ptesarik@suse.cz>
> ---
>  arch/ia64/kernel/perfmon.c     |   21 +++------------------
>  arch/ia64/kernel/process.c     |    9 +++++++++
>  include/asm-ia64/thread_info.h |    9 ++++++---
>  3 files changed, 18 insertions(+), 21 deletions(-)
> 
> diff --git a/arch/ia64/kernel/perfmon.c b/arch/ia64/kernel/perfmon.c
> index 73e7c2e..446e452 100644
> --- a/arch/ia64/kernel/perfmon.c
> +++ b/arch/ia64/kernel/perfmon.c
> @@ -586,21 +586,6 @@ pfm_put_task(struct task_struct *task)
>  }
>  
>  static inline void
> -pfm_set_task_notify(struct task_struct *task)
> -{
> -	struct thread_info *info;
> -
> -	info = (struct thread_info *) ((char *) task + IA64_TASK_SIZE);
> -	set_bit(TIF_PERFMON_WORK, &info->flags);
> -}
> -
> -static inline void
> -pfm_clear_task_notify(void)
> -{
> -	clear_thread_flag(TIF_PERFMON_WORK);
> -}
> -
> -static inline void
>  pfm_reserve_page(unsigned long a)
>  {
>  	SetPageReserved(vmalloc_to_page((void *)a));
> @@ -3724,7 +3709,7 @@ pfm_restart(pfm_context_t *ctx, void *ar
>  
>  		PFM_SET_WORK_PENDING(task, 1);
>  
> -		pfm_set_task_notify(task);
> +		tsk_set_notify_resume(task);
>  
>  		/*
>  		 * XXX: send reschedule if task runs on another CPU
> @@ -5082,7 +5067,7 @@ pfm_handle_work(void)
>  
>  	PFM_SET_WORK_PENDING(current, 0);
>  
> -	pfm_clear_task_notify();
> +	tsk_clear_notify_resume(current);
>  
>  	regs = task_pt_regs(current);
>  
> @@ -5450,7 +5435,7 @@ pfm_overflow_handler(struct task_struct 
>  			 * when coming from ctxsw, current still points to the
>  			 * previous task, therefore we must work with task and not current.
>  			 */
> -			pfm_set_task_notify(task);
> +			tsk_set_notify_resume(task);
>  		}
>  		/*
>  		 * defer until state is changed (shorten spin window). the context is locked
> diff --git a/arch/ia64/kernel/process.c b/arch/ia64/kernel/process.c
> index 2418289..94a92de 100644
> --- a/arch/ia64/kernel/process.c
> +++ b/arch/ia64/kernel/process.c
> @@ -155,6 +155,15 @@ show_regs (struct pt_regs *regs)
>  		show_stack(NULL, NULL);
>  }
>  
> +void tsk_clear_notify_resume(struct task_struct *tsk)
> +{
> +#ifdef CONFIG_PERFMON
> +	if (tsk->thread.pfm_needs_checking)
> +		return;
> +#endif
> +	clear_ti_thread_flag(task_thread_info(tsk), TIF_NOTIFY_RESUME);
> +}
> +
>  void
>  do_notify_resume_user (sigset_t *unused, struct sigscratch *scr, long in_syscall)
>  {
> diff --git a/include/asm-ia64/thread_info.h b/include/asm-ia64/thread_info.h
> index d16031e..5a2c479 100644
> --- a/include/asm-ia64/thread_info.h
> +++ b/include/asm-ia64/thread_info.h
> @@ -71,6 +71,9 @@ #define __HAVE_ARCH_TASK_STRUCT_ALLOCATO
>  #define alloc_task_struct()	((struct task_struct *)__get_free_pages(GFP_KERNEL | __GFP_COMP, KERNEL_STACK_SIZE_ORDER))
>  #define free_task_struct(tsk)	free_pages((unsigned long) (tsk), KERNEL_STACK_SIZE_ORDER)
>  
> +#define tsk_set_notify_resume(tsk) \
> +	set_ti_thread_flag(task_thread_info(tsk), TIF_NOTIFY_RESUME)
> +extern void tsk_clear_notify_resume(struct task_struct *tsk);
>  #endif /* !__ASSEMBLY */
>  
>  /*
> @@ -85,7 +88,7 @@ #define TIF_SYSCALL_TRACE	2	/* syscall t
>  #define TIF_SYSCALL_AUDIT	3	/* syscall auditing active */
>  #define TIF_SINGLESTEP		4	/* restore singlestep on return to user mode */
>  #define TIF_RESTORE_SIGMASK	5	/* restore signal mask in do_signal() */
> -#define TIF_PERFMON_WORK	6	/* work for pfm_handle_work() */
> +#define TIF_NOTIFY_RESUME	6	/* resumption notification requested */
>  #define TIF_POLLING_NRFLAG	16	/* true if poll_idle() is polling TIF_NEED_RESCHED */
>  #define TIF_MEMDIE		17
>  #define TIF_MCA_INIT		18	/* this task is processing MCA or INIT */
> @@ -97,7 +100,7 @@ #define _TIF_SYSCALL_AUDIT	(1 << TIF_SYS
>  #define _TIF_SINGLESTEP		(1 << TIF_SINGLESTEP)
>  #define _TIF_SYSCALL_TRACEAUDIT	(_TIF_SYSCALL_TRACE|_TIF_SYSCALL_AUDIT|_TIF_SINGLESTEP)
>  #define _TIF_RESTORE_SIGMASK	(1 << TIF_RESTORE_SIGMASK)
> -#define _TIF_PERFMON_WORK	(1 << TIF_PERFMON_WORK)
> +#define _TIF_NOTIFY_RESUME	(1 << TIF_NOTIFY_RESUME)
>  #define _TIF_SIGPENDING		(1 << TIF_SIGPENDING)
>  #define _TIF_NEED_RESCHED	(1 << TIF_NEED_RESCHED)
>  #define _TIF_POLLING_NRFLAG	(1 << TIF_POLLING_NRFLAG)
> @@ -106,7 +109,7 @@ #define _TIF_DB_DISABLED	(1 << TIF_DB_DI
>  #define _TIF_FREEZE		(1 << TIF_FREEZE)
>  
>  /* "work to do on user-return" bits */
> -#define TIF_ALLWORK_MASK	(_TIF_SIGPENDING|_TIF_PERFMON_WORK|_TIF_SYSCALL_AUDIT|\
> +#define TIF_ALLWORK_MASK	(_TIF_SIGPENDING|_TIF_NOTIFY_RESUME|_TIF_SYSCALL_AUDIT|\
>  				 _TIF_NEED_RESCHED| _TIF_SYSCALL_TRACE|\
>  				 _TIF_RESTORE_SIGMASK)
>  /* like TIF_ALLWORK_BITS but sans TIF_SYSCALL_TRACE or TIF_SYSCALL_AUDIT */
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 

-Stephane
