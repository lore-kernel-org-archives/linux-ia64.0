From: "Eric W. Biederman" <ebiederm@xmission.com>
Date: Tue, 03 May 2022 19:36:55 +0000
Subject: Re: [PATCH v2 06/12] ptrace: Reimplement PTRACE_KILL by always sending SIGKILL
Message-Id: <87y1zio1bc.fsf@email.froward.int.ebiederm.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <87k0b7v9yk.fsf_-_@email.froward.int.ebiederm.org>
        <20220429214837.386518-6-ebiederm@xmission.com>
        <20220502143750.GC17276@redhat.com>
In-Reply-To: <20220502143750.GC17276@redhat.com> (Oleg Nesterov's message of
        "Mon, 2 May 2022 16:37:51 +0200")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Nesterov <oleg@redhat.com>
Cc: linux-kernel@vger.kernel.org, rjw@rjwysocki.net, mingo@kernel.org, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, rostedt@goodmis.org, mgorman@suse.de, bigeasy@linutronix.de, Will Deacon <will@kernel.org>, tj@kernel.org, linux-pm@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Richard Weinberger <richard@nod.at>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, Johannes Berg <johannes@sipsolutions.net>, linux-um@lists.infradead.org, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, linux-xtensa@linux-xtensa.org, Kees Cook <keescook@chromium.org>, Jann Horn <jannh@google.com>, linux-ia64@vger.kernel.org, stable@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>

Oleg Nesterov <oleg@redhat.com> writes:

> On 04/29, Eric W. Biederman wrote:
>>
>> Call send_sig_info in PTRACE_KILL instead of ptrace_resume.  Calling
>> ptrace_resume is not safe to call if the task has not been stopped
>> with ptrace_freeze_traced.
>
> Oh, I was never, never able to understand why do we have PTRACE_KILL
> and what should it actually do.
>
> I suggested many times to simply remove it but OK, we probably can't
> do this.

I thought I remembered you suggesting fixing it in some other way.

I took at quick look in codesearch.debian.net and PTRACE_KILL is
definitely in use. I find uses in gcc-10, firefox-esr_91.8,
llvm_toolchain, qtwebengine.  At which point I stopped looking.


>> --- a/kernel/ptrace.c
>> +++ b/kernel/ptrace.c
>> @@ -1238,7 +1238,7 @@ int ptrace_request(struct task_struct *child, long request,
>>  	case PTRACE_KILL:
>>  		if (child->exit_state)	/* already dead */
>>  			return 0;
>> -		return ptrace_resume(child, request, SIGKILL);
>> +		return send_sig_info(SIGKILL, SEND_SIG_NOINFO, child);
>
> Note that currently ptrace(PTRACE_KILL) can never fail (yes, yes, it
> is unsafe), but send_sig_info() can. If we do not remove PTRACE_KILL,
> then I'd suggest
>
> 	case PTRACE_KILL:
> 		if (!child->exit_state)
> 			send_sig_info(SIGKILL);
> 		return 0;
>
> to make this change a bit more compatible.


Quite.  The only failure I can find from send_sig_info is if
lock_task_sighand fails and PTRACE_KILL is deliberately ignoring errors
when the target task has exited.

 	case PTRACE_KILL:
 		send_sig_info(SIGKILL);
 		return 0;

I think that should suffice.


> Also, please remove the note about PTRACE_KILL in
> set_task_blockstep().

Good catch, thank you.

Eric
