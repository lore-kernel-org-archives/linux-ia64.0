From: "Eric W. Biederman" <ebiederm@xmission.com>
Date: Thu, 05 May 2022 17:21:58 +0000
Subject: Re: [PATCH v3 08/11] ptrace: Admit ptrace_stop can generate spuriuos SIGTRAPs
Message-Id: <87a6bv7v49.fsf@email.froward.int.ebiederm.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <87k0b0apne.fsf_-_@email.froward.int.ebiederm.org>
        <20220504224058.476193-8-ebiederm@xmission.com>
        <20220505150158.GB13929@redhat.com>
In-Reply-To: <20220505150158.GB13929@redhat.com> (Oleg Nesterov's message of
        "Thu, 5 May 2022 17:01:59 +0200")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Nesterov <oleg@redhat.com>
Cc: linux-kernel@vger.kernel.org, rjw@rjwysocki.net, mingo@kernel.org, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, rostedt@goodmis.org, mgorman@suse.de, bigeasy@linutronix.de, Will Deacon <will@kernel.org>, tj@kernel.org, linux-pm@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Richard Weinberger <richard@nod.at>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, Johannes Berg <johannes@sipsolutions.net>, linux-um@lists.infradead.org, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, linux-xtensa@linux-xtensa.org, Kees Cook <keescook@chromium.org>, Jann Horn <jannh@google.com>, linux-ia64@vger.kernel.org

Oleg Nesterov <oleg@redhat.com> writes:

> On 05/04, Eric W. Biederman wrote:
>>
>> With the removal of the incomplete detection of the tracer going away
>> in ptrace_stop, ptrace_stop always sleeps in schedule after
>> ptrace_freeze_traced succeeds.  Modify ptrace_check_attach to
>> warn if wait_task_inactive fails.
>
> Oh. Again, I don't understand the changelog. If we forget about RT,
> ptrace_stop() will always sleep if ptrace_freeze_traced() succeeds.
> may_ptrace_stop() has gone.
>
> IOW. Lets forget about RT
>
>> --- a/kernel/ptrace.c
>> +++ b/kernel/ptrace.c
>> @@ -266,17 +266,9 @@ static int ptrace_check_attach(struct task_struct *child, bool ignore_state)
>>  	}
>>  	read_unlock(&tasklist_lock);
>>
>> -	if (!ret && !ignore_state) {
>> -		if (!wait_task_inactive(child, __TASK_TRACED)) {
>> -			/*
>> -			 * This can only happen if may_ptrace_stop() fails and
>> -			 * ptrace_stop() changes ->state back to TASK_RUNNING,
>> -			 * so we should not worry about leaking __TASK_TRACED.
>> -			 */
>> -			WARN_ON(READ_ONCE(child->__state) = __TASK_TRACED);
>> -			ret = -ESRCH;
>> -		}
>> -	}
>> +	if (!ret && !ignore_state &&
>> +	    WARN_ON_ONCE(!wait_task_inactive(child, __TASK_TRACED)))
>> +		ret = -ESRCH;
>>
>>  	return ret;
>>  }
>
> Why do you think this change would be wrong without any other changes?

For purposes of this analysis ptrace_detach and ptrace_exit (when the
tracer exits) can't happen.  So the bug you spotted in ptrace_stop does
not apply.

I was thinking that the test against !current->ptrace that replaced
the old may_ptrace_stop could trigger a failure here.  If the
ptrace_freeze_traced happens before that test that branch clearly can
not happen.

*Looks twice* Both ptrace_check_attach and ptrace_stop taking a
read_lock on tasklist_lock does not protect against concurrency by each
other, but the write_lock on tasklist_lock in ptrace_attach does
protect against a ptrace_attach coming in after the test and before
__set_current_state(TASK_RUNNING).

So yes. I should really split that part out into it's own patch.
And yes that WARN_ON_ONCE can trigger on PREEMPT_RT but that is just
because PREMPT_RT is currently broken with respect to ptrace.  Which
makes a WARN_ON_ONCE appropriate.

I will see how much of this analysis I can put in the changelog.

Thank you,
Eric
