From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Date: Mon, 02 May 2022 10:18:29 +0000
Subject: Re: [PATCH v2 12/12] sched,signal,ptrace: Rework TASK_TRACED, TASK_STOPPED state
Message-Id: <Ym+v9VAf71oOlDLF@linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <87k0b7v9yk.fsf_-_@email.froward.int.ebiederm.org>
 <20220429214837.386518-12-ebiederm@xmission.com>
In-Reply-To: <20220429214837.386518-12-ebiederm@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: linux-kernel@vger.kernel.org, rjw@rjwysocki.net, Oleg Nesterov <oleg@redhat.com>, mingo@kernel.org, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, rostedt@goodmis.org, mgorman@suse.de, Will Deacon <will@kernel.org>, tj@kernel.org, linux-pm@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Richard Weinberger <richard@nod.at>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, Johannes Berg <johannes@sipsolutions.net>, linux-um@lists.infradead.org, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, linux-xtensa@linux-xtensa.org, Kees Cook <keescook@chromium.org>, Jann Horn <jannh@google.com>, linux-ia64@vger.kernel.org

On 2022-04-29 16:48:37 [-0500], Eric W. Biederman wrote:

Needs
 From: Peter Zijlstra (Intel) <peterz@infradead.org>

at the top.

> Currently ptrace_stop() / do_signal_stop() rely on the special states
> TASK_TRACED and TASK_STOPPED resp. to keep unique state. That is, this
> state exists only in task->__state and nowhere else.
> 
> There's two spots of bother with this:
> 
>  - PREEMPT_RT has task->saved_state which complicates matters,
>    meaning task_is_{traced,stopped}() needs to check an additional
>    variable.
> 
>  - An alternative freezer implementation that itself relies on a
>    special TASK state would loose TASK_TRACED/TASK_STOPPED and will
>    result in misbehaviour.
> 
> As such, add additional state to task->jobctl to track this state
> outside of task->__state.
> 
> NOTE: this doesn't actually fix anything yet, just adds extra state.
> 
> --EWB
>   * didn't add a unnecessary newline in signal.h
>   * Update t->jobctl in signal_wake_up and ptrace_signal_wake_up
>     instead of in signal_wake_up_state.  This prevents the clearing
>     of TASK_STOPPED and TASK_TRACED from getting lost.
>   * Added warnings if JOBCTL_STOPPED or JOBCTL_TRACED are not cleared
> 
> Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
> Link: https://lkml.kernel.org/r/20220421150654.757693825@infradead.org
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Sebastian
