From: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Date: Tue, 19 Jan 2021 01:50:39 +0000
Subject: Re: [PATCH] ia64: add support for TIF_NOTIFY_SIGNAL
Message-Id: <71d32a91-c429-7405-f4a6-58c74eb898bf@physik.fu-berlin.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <d3a2aa1e-0fae-1d3f-519f-d32adc608c38@kernel.dk>
In-Reply-To: <d3a2aa1e-0fae-1d3f-519f-d32adc608c38@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Jens!

On 10/29/20 5:15 PM, Jens Axboe wrote:
> Wire up TIF_NOTIFY_SIGNAL handling for ia64.
> 
> Cc: linux-ia64@vger.kernel.org
> Signed-off-by: Jens Axboe <axboe@kernel.dk>
> ---
> 
> 5.11 has support queued up for TIF_NOTIFY_SIGNAL, see this posting
> for details:
> 
> https://lore.kernel.org/io-uring/20201026203230.386348-1-axboe@kernel.dk/
> 
> As part of that work, I'm adding TIF_NOTIFY_SIGNAL support to all archs,
> as that will enable a set of cleanups once all of them support it. I'm
> happy carrying this patch if need be, or it can be funelled through the
> arch tree. Let me know.
> 
>  arch/ia64/include/asm/thread_info.h | 4 +++-
>  arch/ia64/kernel/process.c          | 3 ++-
>  2 files changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/ia64/include/asm/thread_info.h b/arch/ia64/include/asm/thread_info.h
> index 64a1011f6812..759d7d68a5f2 100644
> --- a/arch/ia64/include/asm/thread_info.h
> +++ b/arch/ia64/include/asm/thread_info.h
> @@ -104,6 +104,7 @@ struct thread_info {
>  #define TIF_SYSCALL_AUDIT	3	/* syscall auditing active */
>  #define TIF_SINGLESTEP		4	/* restore singlestep on return to user mode */
>  #define TIF_NOTIFY_RESUME	6	/* resumption notification requested */
> +#define TIF_NOTIFY_SIGNAL	7	/* signal notification exist */
>  #define TIF_MEMDIE		17	/* is terminating due to OOM killer */
>  #define TIF_MCA_INIT		18	/* this task is processing MCA or INIT */
>  #define TIF_DB_DISABLED		19	/* debug trap disabled for fsyscall */
> @@ -115,6 +116,7 @@ struct thread_info {
>  #define _TIF_SINGLESTEP		(1 << TIF_SINGLESTEP)
>  #define _TIF_SYSCALL_TRACEAUDIT	(_TIF_SYSCALL_TRACE|_TIF_SYSCALL_AUDIT|_TIF_SINGLESTEP)
>  #define _TIF_NOTIFY_RESUME	(1 << TIF_NOTIFY_RESUME)
> +#define _TIF_SIGNAL_NOTIFY	(1 << TIF_SIGNAL_NOTIFY)
>  #define _TIF_SIGPENDING		(1 << TIF_SIGPENDING)
>  #define _TIF_NEED_RESCHED	(1 << TIF_NEED_RESCHED)
>  #define _TIF_MCA_INIT		(1 << TIF_MCA_INIT)
> @@ -124,7 +126,7 @@ struct thread_info {
>  
>  /* "work to do on user-return" bits */
>  #define TIF_ALLWORK_MASK	(_TIF_SIGPENDING|_TIF_NOTIFY_RESUME|_TIF_SYSCALL_AUDIT|\
> -				 _TIF_NEED_RESCHED|_TIF_SYSCALL_TRACE)
> +				 _TIF_NEED_RESCHED|_TIF_SYSCALL_TRACE|_TIF_NOTIFY_SIGNAL)
>  /* like TIF_ALLWORK_BITS but sans TIF_SYSCALL_TRACE or TIF_SYSCALL_AUDIT */
>  #define TIF_WORK_MASK		(TIF_ALLWORK_MASK&~(_TIF_SYSCALL_TRACE|_TIF_SYSCALL_AUDIT))
>  
> diff --git a/arch/ia64/kernel/process.c b/arch/ia64/kernel/process.c
> index 6b61a703bcf5..0e0146daa88d 100644
> --- a/arch/ia64/kernel/process.c
> +++ b/arch/ia64/kernel/process.c
> @@ -171,7 +171,8 @@ do_notify_resume_user(sigset_t *unused, struct sigscratch *scr, long in_syscall)
>  	}
>  
>  	/* deal with pending signal delivery */
> -	if (test_thread_flag(TIF_SIGPENDING)) {
> +	if (test_thread_flag(TIF_SIGPENDING) ||
> +	    test_thread_flags(TIF_NOTIFY_SIGNAL)) {
>  		local_irq_enable();	/* force interrupt enable */
>  		ia64_do_signal(scr, in_syscall);
>  	}
> 

This change broke the hpsa driver on my RX-2600 ia64 workstation in the sense that the
driver no longer loads and hence hard disks are no longer recognized.

Any idea what could be wrong?

Adrian

-- 
 .''`.  John Paul Adrian Glaubitz
: :' :  Debian Developer - glaubitz@debian.org
`. `'   Freie Universitaet Berlin - glaubitz@physik.fu-berlin.de
  `-    GPG: 62FF 8A75 84E0 2956 9546  0006 7426 3B37 F5B5 F913
