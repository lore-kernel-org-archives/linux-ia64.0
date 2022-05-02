From: "Eric W. Biederman" <ebiederm@xmission.com>
Date: Mon, 02 May 2022 16:35:50 +0000
Subject: Re: [PATCH v2 07/12] ptrace: Don't change __state
Message-Id: <87levjrixl.fsf@email.froward.int.ebiederm.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <87k0b7v9yk.fsf_-_@email.froward.int.ebiederm.org>
        <20220429214837.386518-7-ebiederm@xmission.com>
        <20220502153934.GD17276@redhat.com>
In-Reply-To: <20220502153934.GD17276@redhat.com> (Oleg Nesterov's message of
        "Mon, 2 May 2022 17:39:35 +0200")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Nesterov <oleg@redhat.com>
Cc: linux-kernel@vger.kernel.org, rjw@rjwysocki.net, mingo@kernel.org, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, rostedt@goodmis.org, mgorman@suse.de, bigeasy@linutronix.de, Will Deacon <will@kernel.org>, tj@kernel.org, linux-pm@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Richard Weinberger <richard@nod.at>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, Johannes Berg <johannes@sipsolutions.net>, linux-um@lists.infradead.org, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, linux-xtensa@linux-xtensa.org, Kees Cook <keescook@chromium.org>, Jann Horn <jannh@google.com>, linux-ia64@vger.kernel.org

Oleg Nesterov <oleg@redhat.com> writes:

> On 04/29, Eric W. Biederman wrote:
>>
>> Stop playing with tsk->__state to remove TASK_WAKEKILL while a ptrace
>> command is executing.
>
> Eric, I'll read this patch and the rest of this series tomorrow.
> Somehow I failed to force myself to read yet another version after
> weekend ;)

That is quite alright.

> plus I don't really understand this one...
>
>>  #define TASK_KILLABLE			(TASK_WAKEKILL | TASK_UNINTERRUPTIBLE)
>>  #define TASK_STOPPED			(TASK_WAKEKILL | __TASK_STOPPED)
>> -#define TASK_TRACED			(TASK_WAKEKILL | __TASK_TRACED)
>> +#define TASK_TRACED			__TASK_TRACED
> ...
>>  static inline void signal_wake_up(struct task_struct *t, bool resume)
>>  {
>> -	signal_wake_up_state(t, resume ? TASK_WAKEKILL : 0);
>> +	unsigned int state = 0;
>> +	if (resume) {
>> +		state = TASK_WAKEKILL;
>> +		if (!(t->jobctl & JOBCTL_PTRACE_FROZEN))
>> +			state |= __TASK_TRACED;
>> +	}
>> +	signal_wake_up_state(t, state);
>
> Can't understand why is this better than the previous version which removed
> TASK_WAKEKILL if resume... Looks a bit strange to me. But again, I didn't
> look at the next patches yet.

The goal is to replace the existing mechanism with an equivalent one,
so that we don't have to be clever and deal with it being slightly
different in one case.

The difference is how does signal_pending_state affect how schedule will
sleep in ptrace_stop.

As the patch is constructed currently (and how the existing code works)
is that signal_pending_state will always sleep if ptrace_freeze_traced
completes successfully.

When TASK_WAKEKILL was included in TASK_TRACED schedule might refuse
to sleep even though ptrace_freeze_traced completed successfully.  As
you pointed out wait_task_inactive would then fail, keeping
ptrace_check_attach from succeeded.

Other than complicating the analysis by adding extra states we need to
consider when reviewing the patch, the practical difference is for
Peter's plans to fix PREEMPT_RT or the freezer wait_task_inactive needs
to cope with the final being changed by something else. (TASK_FROZEN in
the freezer case).  I can only see that happening by removing the
dependency on the final state in wait_task_inactive.  Which we can't do
if we depend on wait_task_inactive failing if the process is in the
wrong state.


>> @@ -2209,11 +2209,8 @@ static int ptrace_stop(int exit_code, int why, int clear_code,
>>  		spin_lock_irq(&current->sighand->siglock);
>>  	}
>>
>> -	/*
>> -	 * schedule() will not sleep if there is a pending signal that
>> -	 * can awaken the task.
>> -	 */
>> -	set_special_state(TASK_TRACED);
>> +	if (!__fatal_signal_pending(current))
>> +		set_special_state(TASK_TRACED);
>
> This is where I stuck. This probably makes sense, but what does it buy
> for this particular patch?
>
> And if we check __fatal_signal_pending(), why can't ptrace_stop() simply
> return ?

Again this is about preserving existing behavior as much as possible to
simplify analsysis of the patch.

The current code depends upon schedule not sleeping if there was a fatal
signal received before ptrace_stop is called.  With TASK_WAKEKILL
removed from TASK_TRACED that no longer happens.  Just not setting
TASK_TRACED when !__fatal_signal_pending has the same effect.


At a practical level I think it also has an impact on patch:
"10/12 ptrace: Only return signr from ptrace_stop if it was provided".

At a minimum the code would need to do something like:
	if (__fatal_signal_pending(current)) {
		return clear_code ? 0 : exit_code;
        }

With a little bit of care put in to ensure everytime the logic changes
that early return changes too.  I think that just complicates things
unnecessarily.

Eric


