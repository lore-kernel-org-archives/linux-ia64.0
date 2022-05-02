From: Oleg Nesterov <oleg@redhat.com>
Date: Mon, 02 May 2022 15:39:35 +0000
Subject: Re: [PATCH v2 07/12] ptrace: Don't change __state
Message-Id: <20220502153934.GD17276@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <87k0b7v9yk.fsf_-_@email.froward.int.ebiederm.org>
 <20220429214837.386518-7-ebiederm@xmission.com>
In-Reply-To: <20220429214837.386518-7-ebiederm@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: linux-kernel@vger.kernel.org, rjw@rjwysocki.net, mingo@kernel.org, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, rostedt@goodmis.org, mgorman@suse.de, bigeasy@linutronix.de, Will Deacon <will@kernel.org>, tj@kernel.org, linux-pm@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Richard Weinberger <richard@nod.at>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, Johannes Berg <johannes@sipsolutions.net>, linux-um@lists.infradead.org, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, linux-xtensa@linux-xtensa.org, Kees Cook <keescook@chromium.org>, Jann Horn <jannh@google.com>, linux-ia64@vger.kernel.org

On 04/29, Eric W. Biederman wrote:
>
> Stop playing with tsk->__state to remove TASK_WAKEKILL while a ptrace
> command is executing.

Eric, I'll read this patch and the rest of this series tomorrow.
Somehow I failed to force myself to read yet another version after
weekend ;)

plus I don't really understand this one...

>  #define TASK_KILLABLE			(TASK_WAKEKILL | TASK_UNINTERRUPTIBLE)
>  #define TASK_STOPPED			(TASK_WAKEKILL | __TASK_STOPPED)
> -#define TASK_TRACED			(TASK_WAKEKILL | __TASK_TRACED)
> +#define TASK_TRACED			__TASK_TRACED
...
>  static inline void signal_wake_up(struct task_struct *t, bool resume)
>  {
> -	signal_wake_up_state(t, resume ? TASK_WAKEKILL : 0);
> +	unsigned int state = 0;
> +	if (resume) {
> +		state = TASK_WAKEKILL;
> +		if (!(t->jobctl & JOBCTL_PTRACE_FROZEN))
> +			state |= __TASK_TRACED;
> +	}
> +	signal_wake_up_state(t, state);

Can't understand why is this better than the previous version which removed
TASK_WAKEKILL if resume... Looks a bit strange to me. But again, I didn't
look at the next patches yet.

> @@ -2209,11 +2209,8 @@ static int ptrace_stop(int exit_code, int why, int clear_code,
>  		spin_lock_irq(&current->sighand->siglock);
>  	}
>
> -	/*
> -	 * schedule() will not sleep if there is a pending signal that
> -	 * can awaken the task.
> -	 */
> -	set_special_state(TASK_TRACED);
> +	if (!__fatal_signal_pending(current))
> +		set_special_state(TASK_TRACED);

This is where I stuck. This probably makes sense, but what does it buy
for this particular patch?

And if we check __fatal_signal_pending(), why can't ptrace_stop() simply
return ?

Oleg.
