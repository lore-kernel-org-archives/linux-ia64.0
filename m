From: "Eric W. Biederman" <ebiederm@xmission.com>
Date: Thu, 05 May 2022 16:59:49 +0000
Subject: Re: [PATCH v3 08/11] ptrace: Admit ptrace_stop can generate spuriuos SIGTRAPs
Message-Id: <87v8uj9apm.fsf@email.froward.int.ebiederm.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <87k0b0apne.fsf_-_@email.froward.int.ebiederm.org>
        <20220504224058.476193-8-ebiederm@xmission.com>
        <20220505145721.GA13929@redhat.com>
In-Reply-To: <20220505145721.GA13929@redhat.com> (Oleg Nesterov's message of
        "Thu, 5 May 2022 16:57:22 +0200")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Nesterov <oleg@redhat.com>
Cc: linux-kernel@vger.kernel.org, rjw@rjwysocki.net, mingo@kernel.org, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, rostedt@goodmis.org, mgorman@suse.de, bigeasy@linutronix.de, Will Deacon <will@kernel.org>, tj@kernel.org, linux-pm@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Richard Weinberger <richard@nod.at>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, Johannes Berg <johannes@sipsolutions.net>, linux-um@lists.infradead.org, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, linux-xtensa@linux-xtensa.org, Kees Cook <keescook@chromium.org>, Jann Horn <jannh@google.com>, linux-ia64@vger.kernel.org

Oleg Nesterov <oleg@redhat.com> writes:

> On 05/04, Eric W. Biederman wrote:
>>
>> -static int ptrace_stop(int exit_code, int why, int clear_code,
>> -			unsigned long message, kernel_siginfo_t *info)
>> +static int ptrace_stop(int exit_code, int why, unsigned long message,
>> +		       kernel_siginfo_t *info)
>>  	__releases(&current->sighand->siglock)
>>  	__acquires(&current->sighand->siglock)
>>  {
>> @@ -2259,54 +2259,33 @@ static int ptrace_stop(int exit_code, int why, int clear_code,
>>  
>>  	spin_unlock_irq(&current->sighand->siglock);
>>  	read_lock(&tasklist_lock);
>> -	if (likely(current->ptrace)) {
>> -		/*
>> -		 * Notify parents of the stop.
>> -		 *
>> -		 * While ptraced, there are two parents - the ptracer and
>> -		 * the real_parent of the group_leader.  The ptracer should
>> -		 * know about every stop while the real parent is only
>> -		 * interested in the completion of group stop.  The states
>> -		 * for the two don't interact with each other.  Notify
>> -		 * separately unless they're gonna be duplicates.
>> -		 */
>> +	/*
>> +	 * Notify parents of the stop.
>> +	 *
>> +	 * While ptraced, there are two parents - the ptracer and
>> +	 * the real_parent of the group_leader.  The ptracer should
>> +	 * know about every stop while the real parent is only
>> +	 * interested in the completion of group stop.  The states
>> +	 * for the two don't interact with each other.  Notify
>> +	 * separately unless they're gonna be duplicates.
>> +	 */
>> +	if (current->ptrace)
>>  		do_notify_parent_cldstop(current, true, why);
>> -		if (gstop_done && ptrace_reparented(current))
>> -			do_notify_parent_cldstop(current, false, why);
>> +	if (gstop_done && (!current->ptrace || ptrace_reparented(current)))
>> +		do_notify_parent_cldstop(current, false, why);
>>  
>> -		/*
>> -		 * Don't want to allow preemption here, because
>> -		 * sys_ptrace() needs this task to be inactive.
>> -		 *
>> -		 * XXX: implement read_unlock_no_resched().
>> -		 */
>> -		preempt_disable();
>> -		read_unlock(&tasklist_lock);
>> -		cgroup_enter_frozen();
>> -		preempt_enable_no_resched();
>> -		freezable_schedule();
>> -		cgroup_leave_frozen(true);
>> -	} else {
>> -		/*
>> -		 * By the time we got the lock, our tracer went away.
>> -		 * Don't drop the lock yet, another tracer may come.
>> -		 *
>> -		 * If @gstop_done, the ptracer went away between group stop
>> -		 * completion and here.  During detach, it would have set
>> -		 * JOBCTL_STOP_PENDING on us and we'll re-enter
>> -		 * TASK_STOPPED in do_signal_stop() on return, so notifying
>> -		 * the real parent of the group stop completion is enough.
>> -		 */
>> -		if (gstop_done)
>> -			do_notify_parent_cldstop(current, false, why);
>> -
>> -		/* tasklist protects us from ptrace_freeze_traced() */
>> -		__set_current_state(TASK_RUNNING);
>> -		read_code = false;
>> -		if (clear_code)
>> -			exit_code = 0;
>> -		read_unlock(&tasklist_lock);
>> -	}
>> +	/*
>> +	 * Don't want to allow preemption here, because
>> +	 * sys_ptrace() needs this task to be inactive.
>> +	 *
>> +	 * XXX: implement read_unlock_no_resched().
>> +	 */
>> +	preempt_disable();
>> +	read_unlock(&tasklist_lock);
>> +	cgroup_enter_frozen();
>> +	preempt_enable_no_resched();
>> +	freezable_schedule();
>
> I must have missed something.
>
> So the tracee calls ptrace_notify() but debugger goes away before the
> ptrace_notify() takes siglock. After that the no longer traced task
> will sleep in TASK_TRACED ?
>
> Looks like ptrace_stop() needs to check current->ptrace before it does
> set_special_state(TASK_TRACED) with siglock held? Then we can rely on
> ptrace_unlink() which will wake the tracee up even if debugger exits.
>
> No?

Hmm.  If the debugger goes away when siglock is dropped and reaquired at
the top of ptrace_stop, that would appear to set the debugged process up
to sleep indefinitely.

I was thinking of the SIGKILL case which is handled.

Thank you for catching that.

Eric

