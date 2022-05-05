From: "Eric W. Biederman" <ebiederm@xmission.com>
Date: Thu, 05 May 2022 17:53:45 +0000
Subject: Re: [PATCH v3 08/11] ptrace: Admit ptrace_stop can generate spuriuos SIGTRAPs
Message-Id: <87zgjv6f2u.fsf@email.froward.int.ebiederm.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <87k0b0apne.fsf_-_@email.froward.int.ebiederm.org>
        <20220504224058.476193-8-ebiederm@xmission.com>
        <20220505152801.GC13929@redhat.com>
In-Reply-To: <20220505152801.GC13929@redhat.com> (Oleg Nesterov's message of
        "Thu, 5 May 2022 17:28:03 +0200")
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
>
> Forgot to mention... but in general I like this change.
>
> In particular, I like the fact it kills the ugly "int clear_code" arg
> which looks as if it solves the problems with the exiting tracer, but
> actually it doesn't. And we do not really care, imo.

Further either this change is necessary or we need to take siglock in
the !current->ptrace path in "ptrace: Don't change __state" so that
JOBCTL_TRACED can be cleared.

So I vote for deleting code, and making ptrace_stop easier to reason
about.

Eric
