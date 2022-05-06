From: "Eric W. Biederman" <ebiederm@xmission.com>
Date: Fri, 06 May 2022 19:42:16 +0000
Subject: Re: [PATCH v4 10/12] ptrace: Don't change __state
Message-Id: <874k2230tj.fsf@email.froward.int.ebiederm.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <87a6bv6dl6.fsf_-_@email.froward.int.ebiederm.org>
        <20220505182645.497868-10-ebiederm@xmission.com>
        <20220506150903.GB16084@redhat.com>
In-Reply-To: <20220506150903.GB16084@redhat.com> (Oleg Nesterov's message of
        "Fri, 6 May 2022 17:09:04 +0200")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Nesterov <oleg@redhat.com>
Cc: linux-kernel@vger.kernel.org, rjw@rjwysocki.net, mingo@kernel.org, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, rostedt@goodmis.org, mgorman@suse.de, bigeasy@linutronix.de, Will Deacon <will@kernel.org>, tj@kernel.org, linux-pm@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Richard Weinberger <richard@nod.at>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, Johannes Berg <johannes@sipsolutions.net>, linux-um@lists.infradead.org, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, linux-xtensa@linux-xtensa.org, Kees Cook <keescook@chromium.org>, Jann Horn <jannh@google.com>, linux-ia64@vger.kernel.org

Oleg Nesterov <oleg@redhat.com> writes:

> On 05/05, Eric W. Biederman wrote:
>>
>> --- a/include/linux/sched.h
>> +++ b/include/linux/sched.h
>> @@ -103,7 +103,7 @@ struct task_group;
>>  /* Convenience macros for the sake of set_current_state: */
>>  #define TASK_KILLABLE			(TASK_WAKEKILL | TASK_UNINTERRUPTIBLE)
>>  #define TASK_STOPPED			(TASK_WAKEKILL | __TASK_STOPPED)
>> -#define TASK_TRACED			(TASK_WAKEKILL | __TASK_TRACED)
>> +#define TASK_TRACED			__TASK_TRACED
>
> however I personally still dislike this change. But let me read the
> code with this series applied, perhaps I will change my mind. If not,
> I will argue ;)

That is fair.  I kind of grew on my after I implemented it and wrapped
my head around what was going on, as it is simple and there are no
implicit cases.

Eric
