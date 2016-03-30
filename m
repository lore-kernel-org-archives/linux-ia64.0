From: Peter Zijlstra <peterz@infradead.org>
Date: Wed, 30 Mar 2016 13:25:49 +0000
Subject: Re: [PATCH 03/11] locking, rwsem: introduce basis for down_write_killable
Message-Id: <20160330132549.GU3408@twins.programming.kicks-ass.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1456750705-7141-1-git-send-email-mhocko@kernel.org>
 <1456750705-7141-4-git-send-email-mhocko@kernel.org>
In-Reply-To: <1456750705-7141-4-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Michal Hocko <mhocko@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, "David S. Miller" <davem@davemloft.net>, Tony Luck <tony.luck@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org, Michal Hocko <mhocko@suse.com>

On Mon, Feb 29, 2016 at 01:58:17PM +0100, Michal Hocko wrote:
> @@ -215,16 +216,34 @@ void __sched __down_write(struct rw_semaphore *sem)
>  		 */
>  		if (sem->count = 0)
>  			break;
> -		set_task_state(tsk, TASK_UNINTERRUPTIBLE);
> +		set_task_state(tsk, state);
>  		raw_spin_unlock_irqrestore(&sem->wait_lock, flags);
>  		schedule();
> +		if (signal_pending_state(state, current)) {
> +			ret = -EINTR;
> +			raw_spin_lock_irqsave(&sem->wait_lock, flags);
> +			goto out;
> +		}
>  		raw_spin_lock_irqsave(&sem->wait_lock, flags);
>  	}
>  	/* got the lock */
>  	sem->count = -1;

> @@ -487,20 +488,38 @@ struct rw_semaphore __sched *rwsem_down_write_failed(struct rw_semaphore *sem)
>  		/* Block until there are no active lockers. */
>  		do {
>  			schedule();
> -			set_current_state(TASK_UNINTERRUPTIBLE);
> +			if (signal_pending_state(state, current)) {
> +				raw_spin_lock_irq(&sem->wait_lock);
> +				ret = ERR_PTR(-EINTR);
> +				goto out;
> +			}
> +			set_current_state(state);
>  		} while ((count = sem->count) & RWSEM_ACTIVE_MASK);
>  
>  		raw_spin_lock_irq(&sem->wait_lock);
>  	}
>  	__set_current_state(TASK_RUNNING);

Why is the signal_pending_state() test _after_ the call to schedule()
and before the 'trylock'.

__mutex_lock_common() has it before the call to schedule and after the
'trylock'.

The difference is that rwsem will now respond to the KILL and return
-EINTR even if the lock is available, whereas mutex will acquire it and
ignore the signal (for a little while longer).

Neither is wrong per se, but I feel all the locking primitives should
behave in a consistent manner in this regard.

