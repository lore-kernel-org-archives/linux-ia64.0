From: Petr Tesarik <ptesarik@suse.cz>
Date: Fri, 09 May 2008 08:27:21 +0000
Subject: Re: [PATCH] ia64: fix interrupt masking for pending works on
Message-Id: <1210321641.16332.17.camel@elijah.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <48229532.7000809@jp.fujitsu.com>
In-Reply-To: <48229532.7000809@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 2008-05-09 at 15:26 +0900, Hidetoshi Seto wrote:
> [Bug-fix for "[BUG?][2.6.25-mm1] sleeping during IRQ disabled"]
> 
> This patch does:
>  - enable interrupts before calling schedule() as same as others, ex. x86
>  - enable interrupts during ia64_do_signal() and ia64_sync_krbs()
>  - do_notify_resume_user() is still called with interrupts disabled, since
>    we can take short path of fsys_mode if-statement quickly.
>  - pfm_handle_work() is also called with interrupts disabled, since
>    it can deal interrupt mask within itself.
>  - fix/add some comments/notes
> 
> Reported-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Signed-off-by: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>

FWIW I like it this way.

Petr Tesarik

> ---
>  arch/ia64/kernel/entry.S   |   14 ++++++++++----
>  arch/ia64/kernel/process.c |   25 +++++++++++++++++++++----
>  2 files changed, 31 insertions(+), 8 deletions(-)
> 
> diff --git a/arch/ia64/kernel/entry.S b/arch/ia64/kernel/entry.S
> index e49ad8c..ef6b031 100644
> --- a/arch/ia64/kernel/entry.S
> +++ b/arch/ia64/kernel/entry.S
> @@ -1156,6 +1156,9 @@ skip_rbs_switch:
>  	 *	r31 = current->thread_info->flags
>  	 * On exit:
>  	 *	p6 = TRUE if work-pending-check needs to be redone
> +	 *
> +	 * Interrupts are disabled on entry, reenabled depend on work, and
> +	 * disabled on exit.
>  	 */
>  .work_pending_syscall:
>  	add r2=-8,r2
> @@ -1170,8 +1173,8 @@ skip_rbs_switch:
>  (pKStk) dep r21=-1,r0,PREEMPT_ACTIVE_BIT,1
>  	;;
>  (pKStk) st4 [r20]=r21
> -	ssm psr.i		// enable interrupts
>  #endif
> +	ssm psr.i		// enable interrupts
>  	br.call.spnt.many rp=schedule
>  .ret9:	cmp.eq p6,p0=r0,r0				// p6 <- 1
>  	rsm psr.i		// disable interrupts
> @@ -1234,9 +1237,12 @@ GLOBAL_ENTRY(ia64_invoke_schedule_tail)
>  END(ia64_invoke_schedule_tail)
>  
>  	/*
> -	 * Setup stack and call do_notify_resume_user().  Note that pSys and pNonSys need to
> -	 * be set up by the caller.  We declare 8 input registers so the system call
> -	 * args get preserved, in case we need to restart a system call.
> +	 * Setup stack and call do_notify_resume_user(), keeping interrupts
> +	 * disabled.
> +	 *
> +	 * Note that pSys and pNonSys need to be set up by the caller.
> +	 * We declare 8 input registers so the system call args get preserved,
> +	 * in case we need to restart a system call.
>  	 */
>  ENTRY(notify_resume_user)
>  	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(8)
> diff --git a/arch/ia64/kernel/process.c b/arch/ia64/kernel/process.c
> index 58dcfac..a3a34b4 100644
> --- a/arch/ia64/kernel/process.c
> +++ b/arch/ia64/kernel/process.c
> @@ -167,11 +167,18 @@ void tsk_clear_notify_resume(struct task_struct *tsk)
>  	clear_ti_thread_flag(task_thread_info(tsk), TIF_NOTIFY_RESUME);
>  }
>  
> +/*
> + * do_notify_resume_user():
> + *	Called from notify_resume_user at entry.S, with interrupts disabled.
> + */
>  void
> -do_notify_resume_user (sigset_t *unused, struct sigscratch *scr, long in_syscall)
> +do_notify_resume_user(sigset_t *unused, struct sigscratch *scr, long in_syscall)
>  {
>  	if (fsys_mode(current, &scr->pt)) {
> -		/* defer signal-handling etc. until we return to privilege-level 0.  */
> +		/*
> +		 * defer signal-handling etc. until we return to
> +		 * privilege-level 0.
> +		 */
>  		if (!ia64_psr(&scr->pt)->lp)
>  			ia64_psr(&scr->pt)->lp = 1;
>  		return;
> @@ -179,16 +186,26 @@ do_notify_resume_user (sigset_t *unused, struct sigscratch *scr, long in_syscall
>  
>  #ifdef CONFIG_PERFMON
>  	if (current->thread.pfm_needs_checking)
> +		/*
> +		 * Note: pfm_handle_work() allow us to call it with interrupts
> +		 * disabled, and may enable interrupts within the function.
> +		 */
>  		pfm_handle_work();
>  #endif
>  
>  	/* deal with pending signal delivery */
> -	if (test_thread_flag(TIF_SIGPENDING))
> +	if (test_thread_flag(TIF_SIGPENDING)) {
> +		local_irq_enable();	/* force interrupt enable */
>  		ia64_do_signal(scr, in_syscall);
> +	}
>  
>  	/* copy user rbs to kernel rbs */
> -	if (unlikely(test_thread_flag(TIF_RESTORE_RSE)))
> +	if (unlikely(test_thread_flag(TIF_RESTORE_RSE))) {
> +		local_irq_enable();	/* force interrupt enable */
>  		ia64_sync_krbs();
> +	}
> +
> +	local_irq_disable();	/* force interrupt disable */
>  }
>  
>  static int pal_halt        = 1;
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
