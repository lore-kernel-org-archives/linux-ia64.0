From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 29 Jul 2005 07:22:43 +0000
Subject: RE: Add prefetch switch stack hook in scheduler function
Message-Id: <200507290722.j6T7Mig07477@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <20050729070447.GA3032@elte.hu>
References: <200507272207.j6RM7fg18695@unix-os.sc.intel.com>
In-Reply-To: <200507272207.j6RM7fg18695@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Ingo Molnar' <mingo@elte.hu>
Cc: Keith Owens <kaos@ocs.com.au>, David.Mosberger@acm.org, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Ingo Molnar wrote on Friday, July 29, 2005 12:05 AM
> --- linux.orig/kernel/sched.c
> +++ linux/kernel/sched.c
> @@ -2869,7 +2869,14 @@ go_idle:
>  	 * its thread_info, its kernel stack and mm:
>  	 */
>  	prefetch(next->thread_info);
> -	prefetch(kernel_stack(next));
> +	/*
> +	 * Prefetch (at least) a cacheline below the current
> +	 * kernel stack (in expectation of any new task touching
> +	 * the stack at least minimally), and a cacheline above
> +	 * the stack:
> +	 */
> +	prefetch_range(kernel_stack(next) - MIN_KERNEL_STACK_FOOTPRINT,
> +		       MIN_KERNEL_STACK_FOOTPRINT + L1_CACHE_BYTES);
>  	prefetch(next->mm);


Doctor, it still hurts :-(

On ia64, we have two kernel stacks, one for outgoing task, and one for
incoming task.  for outgoing task, we haven't called switch_to() yet.
So the switch stack structure for 'current' will be allocated immediately
below current 'sp' pointer. For the incoming task, it was fully ctx'ed out
previously, so switch stack structure is immediate above kernel_stack(next).
It Would be beneficial to prefetch both stacks.

