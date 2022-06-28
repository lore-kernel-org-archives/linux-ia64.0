From: Steven Rostedt <rostedt@goodmis.org>
Date: Tue, 28 Jun 2022 22:48:50 +0000
Subject: Re: [PATCH v4 12/12] sched,signal,ptrace: Rework TASK_TRACED, TASK_STOPPED state
Message-Id: <20220628184850.05f60d1e@gandalf.local.home>
List-Id: <linux-ia64.vger.kernel.org>
References: <87a6bv6dl6.fsf_-_@email.froward.int.ebiederm.org>
        <20220505182645.497868-12-ebiederm@xmission.com>
        <YrHA5UkJLornOdCz@li-4a3a4a4c-28e5-11b2-a85c-a8d192c6f089.ibm.com>
        <877d5ajesi.fsf@email.froward.int.ebiederm.org>
        <YrHgo8GKFPWwoBoJ@li-4a3a4a4c-28e5-11b2-a85c-a8d192c6f089.ibm.com>
        <87y1xk8zx5.fsf@email.froward.int.ebiederm.org>
        <YrtKReO2vIiX8VVU@tuxmaker.boeblingen.de.ibm.com>
        <87czess94h.fsf@email.froward.int.ebiederm.org>
In-Reply-To: <87czess94h.fsf@email.froward.int.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Alexander Gordeev <agordeev@linux.ibm.com>, linux-kernel@vger.kernel.org, rjw@rjwysocki.net, Oleg Nesterov <oleg@redhat.com>, mingo@kernel.org, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, mgorman@suse.de, bigeasy@linutronix.de, Will Deacon <will@kernel.org>, tj@kernel.org, linux-pm@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Richard Weinberger <richard@nod.at>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, Johannes Berg <johannes@sipsolutions.net>, linux-um@lists.infradead.org, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, linux-xtensa@linux-xtensa.org, Kees Cook <keescook@chromium.org>, Jann Horn <jannh@google.com>, linux-ia64@vger.kernel.org

On Tue, 28 Jun 2022 17:42:22 -0500
"Eric W. Biederman" <ebiederm@xmission.com> wrote:

> diff --git a/kernel/ptrace.c b/kernel/ptrace.c
> index 156a99283b11..cb85bcf84640 100644
> --- a/kernel/ptrace.c
> +++ b/kernel/ptrace.c
> @@ -202,6 +202,7 @@ static bool ptrace_freeze_traced(struct task_struct *task)
>  	spin_lock_irq(&task->sighand->siglock);
>  	if (task_is_traced(task) && !looks_like_a_spurious_pid(task) &&
>  	    !__fatal_signal_pending(task)) {
> +		smp_rmb();
>  		task->jobctl |= JOBCTL_PTRACE_FROZEN;
>  		ret = true;
>  	}
> diff --git a/kernel/signal.c b/kernel/signal.c
> index edb1dc9b00dc..bcd576e9de66 100644
> --- a/kernel/signal.c
> +++ b/kernel/signal.c
> @@ -2233,6 +2233,7 @@ static int ptrace_stop(int exit_code, int why, unsigned long message,
>  		return exit_code;
>  
>  	set_special_state(TASK_TRACED);
> +	smp_wmb();
>  	current->jobctl |= JOBCTL_TRACED;
>  

Are not these both done under the sighand->siglock spinlock?

That is, the two paths should already be synchronized, and the memory
barriers will not help anything inside the locks. The locking should (and
must) handle all that.

-- Steve
