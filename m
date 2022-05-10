From: Oleg Nesterov <oleg@redhat.com>
Date: Tue, 10 May 2022 14:23:18 +0000
Subject: Re: [PATCH v4 10/12] ptrace: Don't change __state
Message-Id: <20220510142202.GB23277@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <87a6bv6dl6.fsf_-_@email.froward.int.ebiederm.org>
 <20220505182645.497868-10-ebiederm@xmission.com>
In-Reply-To: <20220505182645.497868-10-ebiederm@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: linux-kernel@vger.kernel.org, rjw@rjwysocki.net, mingo@kernel.org, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, rostedt@goodmis.org, mgorman@suse.de, bigeasy@linutronix.de, Will Deacon <will@kernel.org>, tj@kernel.org, linux-pm@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Richard Weinberger <richard@nod.at>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, Johannes Berg <johannes@sipsolutions.net>, linux-um@lists.infradead.org, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, linux-xtensa@linux-xtensa.org, Kees Cook <keescook@chromium.org>, Jann Horn <jannh@google.com>, linux-ia64@vger.kernel.org

On 05/05, Eric W. Biederman wrote:
>
>  static void ptrace_unfreeze_traced(struct task_struct *task)
>  {
> -	if (READ_ONCE(task->__state) != __TASK_TRACED)
> -		return;
> -
> -	WARN_ON(!task->ptrace || task->parent != current);
> +	unsigned long flags;
>  
>  	/*
> -	 * PTRACE_LISTEN can allow ptrace_trap_notify to wake us up remotely.
> -	 * Recheck state under the lock to close this race.
> +	 * The child may be awake and may have cleared
> +	 * JOBCTL_PTRACE_FROZEN (see ptrace_resume).  The child will
> +	 * not set JOBCTL_PTRACE_FROZEN or enter __TASK_TRACED anew.
>  	 */
> -	spin_lock_irq(&task->sighand->siglock);
> -	if (READ_ONCE(task->__state) = __TASK_TRACED) {
> +	if (lock_task_sighand(task, &flags)) {

But I still think that a lockless

	if (!(task->jobctl & JOBCTL_PTRACE_FROZEN))
		return;

check at the start of ptrace_unfreeze_traced() makes sense to avoid
lock_task_sighand() if possible.

And ptrace_resume() can probably clear JOBCTL_PTRACE_FROZEN along with
JOBCTL_TRACED to make this optimization work better. The same for
ptrace_signal_wake_up().

Oleg.
