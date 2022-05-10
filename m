From: "Eric W. Biederman" <ebiederm@xmission.com>
Date: Tue, 10 May 2022 14:26:36 +0000
Subject: Re: [PATCH v4 0/12] ptrace: cleaning up ptrace_stop
Message-Id: <87lev9xy3n.fsf@email.froward.int.ebiederm.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220421150248.667412396@infradead.org>
        <20220421150654.817117821@infradead.org>
        <87czhap9dy.fsf@email.froward.int.ebiederm.org>
        <878rrrh32q.fsf_-_@email.froward.int.ebiederm.org>
        <87k0b7v9yk.fsf_-_@email.froward.int.ebiederm.org>
        <87k0b0apne.fsf_-_@email.froward.int.ebiederm.org>
        <87a6bv6dl6.fsf_-_@email.froward.int.ebiederm.org>
        <20220510141119.GA23277@redhat.com>
In-Reply-To: <20220510141119.GA23277@redhat.com> (Oleg Nesterov's message of
        "Tue, 10 May 2022 16:11:21 +0200")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Nesterov <oleg@redhat.com>
Cc: linux-kernel@vger.kernel.org, rjw@rjwysocki.net, mingo@kernel.org, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, rostedt@goodmis.org, mgorman@suse.de, bigeasy@linutronix.de, Will Deacon <will@kernel.org>, tj@kernel.org, linux-pm@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Richard Weinberger <richard@nod.at>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, Johannes Berg <johannes@sipsolutions.net>, linux-um@lists.infradead.org, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, linux-xtensa@linux-xtensa.org, Jann Horn <jannh@google.com>, Kees Cook <keescook@chromium.org>, linux-ia64@vger.kernel.org

Oleg Nesterov <oleg@redhat.com> writes:

> On 05/05, Eric W. Biederman wrote:
>>
>> Eric W. Biederman (11):
>>       signal: Rename send_signal send_signal_locked
>>       signal: Replace __group_send_sig_info with send_signal_locked
>>       ptrace/um: Replace PT_DTRACE with TIF_SINGLESTEP
>>       ptrace/xtensa: Replace PT_SINGLESTEP with TIF_SINGLESTEP
>>       ptrace: Remove arch_ptrace_attach
>>       signal: Use lockdep_assert_held instead of assert_spin_locked
>>       ptrace: Reimplement PTRACE_KILL by always sending SIGKILL
>>       ptrace: Document that wait_task_inactive can't fail
>>       ptrace: Admit ptrace_stop can generate spuriuos SIGTRAPs
>>       ptrace: Don't change __state
>>       ptrace: Always take siglock in ptrace_resume
>>
>> Peter Zijlstra (1):
>>       sched,signal,ptrace: Rework TASK_TRACED, TASK_STOPPED state
>
> OK, lgtm.
>
> Reviewed-by: Oleg Nesterov <oleg@redhat.com>
>
>
> I still dislike you removed TASK_WAKEKILL from TASK_TRACED, but I can't
> find a good argument against it ;) and yes, this is subjective.

Does anyone else have any comments on this patchset?

If not I am going to apply this to a branch and get it into linux-next.

Eric
