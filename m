From: "Eric W. Biederman" <ebiederm@xmission.com>
Date: Tue, 03 May 2022 20:45:12 +0000
Subject: Re: [PATCH v2 07/12] ptrace: Don't change __state
Message-Id: <877d72l50n.fsf@email.froward.int.ebiederm.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <87k0b7v9yk.fsf_-_@email.froward.int.ebiederm.org>
        <20220429214837.386518-7-ebiederm@xmission.com>
        <20220502153934.GD17276@redhat.com>
        <87levjrixl.fsf@email.froward.int.ebiederm.org>
        <20220503134149.GA22999@redhat.com>
In-Reply-To: <20220503134149.GA22999@redhat.com> (Oleg Nesterov's message of
        "Tue, 3 May 2022 15:41:50 +0200")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Nesterov <oleg@redhat.com>
Cc: linux-kernel@vger.kernel.org, rjw@rjwysocki.net, mingo@kernel.org, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, rostedt@goodmis.org, mgorman@suse.de, bigeasy@linutronix.de, Will Deacon <will@kernel.org>, tj@kernel.org, linux-pm@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Richard Weinberger <richard@nod.at>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, Johannes Berg <johannes@sipsolutions.net>, linux-um@lists.infradead.org, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, linux-xtensa@linux-xtensa.org, Kees Cook <keescook@chromium.org>, Jann Horn <jannh@google.com>, linux-ia64@vger.kernel.org

Oleg Nesterov <oleg@redhat.com> writes:

> On 05/02, Eric W. Biederman wrote:
>>
>> Oleg Nesterov <oleg@redhat.com> writes:
>>
>> >>  #define TASK_KILLABLE			(TASK_WAKEKILL | TASK_UNINTERRUPTIBLE)
>> >>  #define TASK_STOPPED			(TASK_WAKEKILL | __TASK_STOPPED)
>> >> -#define TASK_TRACED			(TASK_WAKEKILL | __TASK_TRACED)
>> >> +#define TASK_TRACED			__TASK_TRACED
>> > ...
>> >>  static inline void signal_wake_up(struct task_struct *t, bool resume)
>> >>  {
>> >> -	signal_wake_up_state(t, resume ? TASK_WAKEKILL : 0);
>> >> +	unsigned int state = 0;
>> >> +	if (resume) {
>> >> +		state = TASK_WAKEKILL;
>> >> +		if (!(t->jobctl & JOBCTL_PTRACE_FROZEN))
>> >> +			state |= __TASK_TRACED;
>> >> +	}
>> >> +	signal_wake_up_state(t, state);
>> >
>> > Can't understand why is this better than the previous version which removed
>> > TASK_WAKEKILL if resume... Looks a bit strange to me. But again, I didn't
>> > look at the next patches yet.
>>
>> The goal is to replace the existing mechanism with an equivalent one,
>> so that we don't have to be clever and deal with it being slightly
>> different in one case.
>>
>> The difference is how does signal_pending_state affect how schedule will
>> sleep in ptrace_stop.
>
> But why is it bad if the tracee doesn't sleep in schedule ? If it races
> with SIGKILL. I still can't understand this.
>
> Yes, wait_task_inactive() can fail, so you need to remove WARN_ON_ONCE()
> in 11/12.


>
> Why is removing TASK_WAKEKILL from TASK_TRACED and complicating
> *signal_wake_up() better?

Not changing __state is better because it removes special cases
from the scheduler that only apply to ptrace.


> And even if we need to ensure the tracee will always block after
> ptrace_freeze_traced(), we can change signal_pending_state() to
> return false if JOBCTL_PTRACE_FROZEN. Much simpler, imo. But still
> looks unnecessary to me.

We still need to change signal_wake_up in that case.  Possibly
signal_wake_up_state.  The choice is for fatal signals is TASK_WAKEKILL
suppressed or is TASK_TRACED added.

With removing TASK_WAKEKILL the resulting code behaves in a very obvious
minimally special case way.  Yes there is a special case in
signal_wake_up but that is the entirety of the special case and it is
easy to read and see what it does.

>> Peter's plans to fix PREEMPT_RT or the freezer wait_task_inactive needs
>> to cope with the final being changed by something else. (TASK_FROZEN in
>> the freezer case).  I can only see that happening by removing the
>> dependency on the final state in wait_task_inactive.  Which we can't do
>> if we depend on wait_task_inactive failing if the process is in the
>> wrong state.
>
> OK, I guess this is what I do not understand. Could you spell please?
>
> And speaking of RT, wait_task_inactive() still can fail because
> cgroup_enter_frozen() takes css_set_lock? And it is called under
> preempt_disable() ? I don't understand the plan :/

Let me describe his freezer change as that is much easier to get to the
final result.  RT has more problems as it turns all spin locks into
sleeping locks.  When a task is frozen it turns it's sleeping state into
TASK_FROZEN.  That is TASK_STOPPED and TASK_TRACED become TASK_FROZEN.
If this races with ptrace_check_attach the wait_task_inactive fail as
the process state has changed.  This makes the freezer userspace
visible.

For ordinary tasks the freezer thaws them just by giving them a spurious
wake-up.  After which they check their conditions and go back to sleep
on their on.  For TASK_STOPPED and TASK_TRACED (which can't handle
spurious wake-ups) the __state value is recovered from task->jobctl.

For RT cgroup_enter_frozen needs fixes that no one has proposed yet.
The problem is that for "preempt_disable()" before
"read_unlock(&tasklist_lock)" is not something that can reasonably be
removed.  It would cause a performance regression.

So my plan is to get the things as far as the Peter's freezer change
working.  That cleans up the code and makes it much closer for
ptrace working in PTREMPT_RT.  That makes the problems left for
the PREEMPT_RT folks much smaller.


>> At a practical level I think it also has an impact on patch:
>> "10/12 ptrace: Only return signr from ptrace_stop if it was provided".
>
> I didn't look at JOBCTL_PTRACE_SIGNR yet. But this looks minor to me,
> I mean, I am not sure it worth the trouble.

The immediate problem the JOBCTL_PTRACE_SIGNR patch solves is:
- stopping in ptrace_report_syscall.
- Not having PT_TRACESYSGOOD set.
- The tracee being killed with a fatal signal
- The tracee sending SIGTRAP to itself.

The larger problem solved by the JOBCTL_PTRACE_SIGNR patch is that
it removes the need for current->ptrace test from ptrace_stop.  Which
in turn is part of what is needed for wait_task_inactive to be
guaranteed a stop in ptrace_stop.


Thinking about it.  I think a reasonable case can be made that it
is weird if not dangerous to play with the task fields (ptrace_message,
last_siginfo, and exit_code) without task_is_traced being true.
So I will adjust my patch to check that.  The difference in behavior
is explicit enough we can think about it easily.

Eric







