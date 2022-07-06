From: Peter Zijlstra <peterz@infradead.org>
Date: Wed, 06 Jul 2022 10:11:15 +0000
Subject: Re: [PATCH v4 12/12] sched,signal,ptrace: Rework TASK_TRACED, TASK_STOPPED state
Message-Id: <YsVfw3dy7smrpEbn@hirez.programming.kicks-ass.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <YrHA5UkJLornOdCz@li-4a3a4a4c-28e5-11b2-a85c-a8d192c6f089.ibm.com>
 <877d5ajesi.fsf@email.froward.int.ebiederm.org>
 <YrHgo8GKFPWwoBoJ@li-4a3a4a4c-28e5-11b2-a85c-a8d192c6f089.ibm.com>
 <20220628191541.34a073fc@gandalf.local.home>
 <yt9d5ykbekn3.fsf@linux.ibm.com>
 <yt9dpmijcvu6.fsf@linux.ibm.com>
 <YsSQRmCZSIQ1ewzo@worktop.programming.kicks-ass.net>
 <yt9dsfneaczk.fsf@linux.ibm.com>
 <YsVO1NU3bXGg9YJ3@worktop.programming.kicks-ass.net>
 <yt9da69ma8wm.fsf@linux.ibm.com>
In-Reply-To: <yt9da69ma8wm.fsf@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sven Schnelle <svens@linux.ibm.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Alexander Gordeev <agordeev@linux.ibm.com>, "Eric W. Biederman" <ebiederm@xmission.com>, linux-kernel@vger.kernel.org, rjw@rjwysocki.net, Oleg Nesterov <oleg@redhat.com>, mingo@kernel.org, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, mgorman@suse.de, bigeasy@linutronix.de, Will Deacon <will@kernel.org>, tj@kernel.org, linux-pm@vger.kernel.org, Richard Weinberger <richard@nod.at>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, Johannes Berg <johannes@sipsolutions.net>, linux-um@lists.infradead.org, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, linux-xtensa@linux-xtensa.org, Kees Cook <keescook@chromium.org>, Jann Horn <jannh@google.com>, linux-ia64@vger.kernel.org

On Wed, Jul 06, 2022 at 11:27:05AM +0200, Sven Schnelle wrote:
> Peter Zijlstra <peterz@infradead.org> writes:
> 
> > On Wed, Jul 06, 2022 at 09:58:55AM +0200, Sven Schnelle wrote:
> >
> >> >> [   86.218551] kill_chi-343805    6d.... 79990141us : ptrace_stop: JOBCTL_TRACED already set, state=0 <------ valid combination of flags?
> >> >
> >> > Yeah, that's not supposed to be so. JOBCTL_TRACED is supposed to follow
> >> > __TASK_TRACED for now. Set when __TASK_TRACED, cleared when
> >> > TASK_RUNNING.
> >> >
> >> > Specifically {ptrace_,}signal_wake_up() in signal.h clear JOBCTL_TRACED
> >> > when they would wake a __TASK_TRACED task.
> >> 
> >> try_to_wake_up() clears TASK_TRACED in this case because a signal
> >> (SIGKILL) has to be delivered. As a test I put the following change
> >> on top, and it "fixes" the problem:
> >> 
> >> diff --git a/kernel/sched/core.c b/kernel/sched/core.c
> >> index da0bf6fe9ecd..f2e0f5e70e77 100644
> >> --- a/kernel/sched/core.c
> >> +++ b/kernel/sched/core.c
> >> @@ -4141,6 +4149,9 @@ try_to_wake_up(struct task_struct *p, unsigned int state, int wake_flags)
> >>          * TASK_WAKING such that we can unlock p->pi_lock before doing the
> >>          * enqueue, such as ttwu_queue_wakelist().
> >>          */
> >> +       if (p->__state & TASK_TRACED)
> >> +               trace_printk("clearing TASK_TRACED 2\n");
> >> +       p->jobctl &= ~JOBCTL_TRACED;
> >>         WRITE_ONCE(p->__state, TASK_WAKING);
> >> 
> >>         /*
> >> 
> >> There are several places where the state is changed from TASK_TRACED to
> >> something else without clearing JOBCTL_TRACED.
> >
> > I'm having difficulty spotting them; I find:
> >
> > TASK_WAKEKILL: signal_wake_up()
> > __TASK_TRACED: ptrace_signal_wake_up(), ptrace_unfreeze_traced(), ptrace_resume()
> >
> > And all those sites dutifully clear JOBCTL_TRACED.
> >
> > I'd be most interested in the calstack for the 'clearing TASK_TRACED 2'
> > events to see where we miss a spot.
> 
> The calltrace is:
> [    9.863613] Call Trace:
> [    9.863616]  [<00000000d3105f0e>] try_to_wake_up+0xae/0x620
> [    9.863620] ([<00000000d3106164>] try_to_wake_up+0x304/0x620)
> [    9.863623]  [<00000000d30d1e46>] ptrace_unfreeze_traced+0x9e/0xa8
> [    9.863629]  [<00000000d30d2ef0>] __s390x_sys_ptrace+0xc0/0x160
> [    9.863633]  [<00000000d3c5d8f4>] __do_syscall+0x1d4/0x200
> [    9.863678]  [<00000000d3c6c332>] system_call+0x82/0xb0
> [    9.863685] Last Breaking-Event-Address:
> [    9.863686]  [<00000000d3106176>] try_to_wake_up+0x316/0x620
> [    9.863688] ---[ end trace 0000000000000000 ]---
> 
> ptrace_unfreeze_traced() is:
> 
> static void ptrace_unfreeze_traced(struct task_struct *task)
> {
>         unsigned long flags;
> 
>         /*
>          * The child may be awake and may have cleared
>          * JOBCTL_PTRACE_FROZEN (see ptrace_resume).  The child will
>          * not set JOBCTL_PTRACE_FROZEN or enter __TASK_TRACED anew.
>          */
>         if (lock_task_sighand(task, &flags)) {
>                 task->jobctl &= ~JOBCTL_PTRACE_FROZEN;
>                 if (__fatal_signal_pending(task)) {
>                         task->jobctl &= ~TASK_TRACED;
> 
> Looking at this, shouldn't the line above read task->jobctl &= ~JOBCTL_TRACED?

YES! Absolutely.

>                         wake_up_state(task, __TASK_TRACED);
>                 }
>                 unlock_task_sighand(task, &flags);
>         }
> }
