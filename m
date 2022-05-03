From: Oleg Nesterov <oleg@redhat.com>
Date: Tue, 03 May 2022 13:41:50 +0000
Subject: Re: [PATCH v2 07/12] ptrace: Don't change __state
Message-Id: <20220503134149.GA22999@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <87k0b7v9yk.fsf_-_@email.froward.int.ebiederm.org>
 <20220429214837.386518-7-ebiederm@xmission.com>
 <20220502153934.GD17276@redhat.com>
 <87levjrixl.fsf@email.froward.int.ebiederm.org>
In-Reply-To: <87levjrixl.fsf@email.froward.int.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: linux-kernel@vger.kernel.org, rjw@rjwysocki.net, mingo@kernel.org, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, rostedt@goodmis.org, mgorman@suse.de, bigeasy@linutronix.de, Will Deacon <will@kernel.org>, tj@kernel.org, linux-pm@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Richard Weinberger <richard@nod.at>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, Johannes Berg <johannes@sipsolutions.net>, linux-um@lists.infradead.org, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, linux-xtensa@linux-xtensa.org, Kees Cook <keescook@chromium.org>, Jann Horn <jannh@google.com>, linux-ia64@vger.kernel.org

On 05/02, Eric W. Biederman wrote:
>
> Oleg Nesterov <oleg@redhat.com> writes:
>
> >>  #define TASK_KILLABLE			(TASK_WAKEKILL | TASK_UNINTERRUPTIBLE)
> >>  #define TASK_STOPPED			(TASK_WAKEKILL | __TASK_STOPPED)
> >> -#define TASK_TRACED			(TASK_WAKEKILL | __TASK_TRACED)
> >> +#define TASK_TRACED			__TASK_TRACED
> > ...
> >>  static inline void signal_wake_up(struct task_struct *t, bool resume)
> >>  {
> >> -	signal_wake_up_state(t, resume ? TASK_WAKEKILL : 0);
> >> +	unsigned int state = 0;
> >> +	if (resume) {
> >> +		state = TASK_WAKEKILL;
> >> +		if (!(t->jobctl & JOBCTL_PTRACE_FROZEN))
> >> +			state |= __TASK_TRACED;
> >> +	}
> >> +	signal_wake_up_state(t, state);
> >
> > Can't understand why is this better than the previous version which removed
> > TASK_WAKEKILL if resume... Looks a bit strange to me. But again, I didn't
> > look at the next patches yet.
>
> The goal is to replace the existing mechanism with an equivalent one,
> so that we don't have to be clever and deal with it being slightly
> different in one case.
>
> The difference is how does signal_pending_state affect how schedule will
> sleep in ptrace_stop.

But why is it bad if the tracee doesn't sleep in schedule ? If it races
with SIGKILL. I still can't understand this.

Yes, wait_task_inactive() can fail, so you need to remove WARN_ON_ONCE()
in 11/12.

Why is removing TASK_WAKEKILL from TASK_TRACED and complicating
*signal_wake_up() better?

And even if we need to ensure the tracee will always block after
ptrace_freeze_traced(), we can change signal_pending_state() to
return false if JOBCTL_PTRACE_FROZEN. Much simpler, imo. But still
looks unnecessary to me.



> Peter's plans to fix PREEMPT_RT or the freezer wait_task_inactive needs
> to cope with the final being changed by something else. (TASK_FROZEN in
> the freezer case).  I can only see that happening by removing the
> dependency on the final state in wait_task_inactive.  Which we can't do
> if we depend on wait_task_inactive failing if the process is in the
> wrong state.

OK, I guess this is what I do not understand. Could you spell please?

And speaking of RT, wait_task_inactive() still can fail because
cgroup_enter_frozen() takes css_set_lock? And it is called under
preempt_disable() ? I don't understand the plan :/

> At a practical level I think it also has an impact on patch:
> "10/12 ptrace: Only return signr from ptrace_stop if it was provided".

I didn't look at JOBCTL_PTRACE_SIGNR yet. But this looks minor to me,
I mean, I am not sure it worth the trouble.

Oleg.
