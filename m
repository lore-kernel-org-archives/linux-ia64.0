From: "Eric W. Biederman" <ebiederm@xmission.com>
Date: Tue, 21 Jun 2022 14:02:05 +0000
Subject: Re: [PATCH v4 12/12] sched,signal,ptrace: Rework TASK_TRACED, TASK_STOPPED state
Message-Id: <877d5ajesi.fsf@email.froward.int.ebiederm.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <87a6bv6dl6.fsf_-_@email.froward.int.ebiederm.org>
        <20220505182645.497868-12-ebiederm@xmission.com>
        <YrHA5UkJLornOdCz@li-4a3a4a4c-28e5-11b2-a85c-a8d192c6f089.ibm.com>
In-Reply-To: <YrHA5UkJLornOdCz@li-4a3a4a4c-28e5-11b2-a85c-a8d192c6f089.ibm.com>
        (Alexander Gordeev's message of "Tue, 21 Jun 2022 15:00:21 +0200")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alexander Gordeev <agordeev@linux.ibm.com>
Cc: linux-kernel@vger.kernel.org, rjw@rjwysocki.net, Oleg Nesterov <oleg@redhat.com>, mingo@kernel.org, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, rostedt@goodmis.org, mgorman@suse.de, bigeasy@linutronix.de, Will Deacon <will@kernel.org>, tj@kernel.org, linux-pm@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Richard Weinberger <richard@nod.at>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, Johannes Berg <johannes@sipsolutions.net>, linux-um@lists.infradead.org, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, linux-xtensa@linux-xtensa.org, Kees Cook <keescook@chromium.org>, Jann Horn <jannh@google.com>, linux-ia64@vger.kernel.org

Alexander Gordeev <agordeev@linux.ibm.com> writes:

> On Thu, May 05, 2022 at 01:26:45PM -0500, Eric W. Biederman wrote:
>> From: Peter Zijlstra <peterz@infradead.org>
>> 
>> Currently ptrace_stop() / do_signal_stop() rely on the special states
>> TASK_TRACED and TASK_STOPPED resp. to keep unique state. That is, this
>> state exists only in task->__state and nowhere else.
>> 
>> There's two spots of bother with this:
>> 
>>  - PREEMPT_RT has task->saved_state which complicates matters,
>>    meaning task_is_{traced,stopped}() needs to check an additional
>>    variable.
>> 
>>  - An alternative freezer implementation that itself relies on a
>>    special TASK state would loose TASK_TRACED/TASK_STOPPED and will
>>    result in misbehaviour.
>> 
>> As such, add additional state to task->jobctl to track this state
>> outside of task->__state.
>> 
>> NOTE: this doesn't actually fix anything yet, just adds extra state.
>> 
>> --EWB
>>   * didn't add a unnecessary newline in signal.h
>>   * Update t->jobctl in signal_wake_up and ptrace_signal_wake_up
>>     instead of in signal_wake_up_state.  This prevents the clearing
>>     of TASK_STOPPED and TASK_TRACED from getting lost.
>>   * Added warnings if JOBCTL_STOPPED or JOBCTL_TRACED are not cleared
>
> Hi Eric, Peter,
>
> On s390 this patch triggers warning at kernel/ptrace.c:272 when
> kill_child testcase from strace tool is repeatedly used (the source
> is attached for reference):
>
> while :; do
> 	strace -f -qq -e signal=none -e trace=sched_yield,/kill ./kill_child
> done
>
> It normally takes few minutes to cause the warning in -rc3, but FWIW
> it hits almost immediately for ptrace_stop-cleanup-for-v5.19 tag of
> git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace.
>
> Commit 7b0fe1367ef2 ("ptrace: Document that wait_task_inactive can't
> fail") suggests this WARN_ON_ONCE() is not really expected, yet we
> observe a child in __TASK_TRACED state. Could you please comment here?
>

For clarity the warning is that the child is not in __TASK_TRACED state.

The code is waiting for the code to stop in the scheduler in the
__TASK_TRACED state so that it can safely read and change the
processes state.  Some of that state is not even saved until the
process is scheduled out so we have to wait until the process
is stopped in the scheduler.

At least on s390 it looks like there is a race between SIGKILL and
ptrace_check_attach.  That isn't good.

Reading the code below there is something missing because I don't see
anything making ptrace calls, and ptrace_check_attach (which contains
the warning) only happens in the ptrace syscall.

Eric



> Thanks!
>
> /*
>  * Check for the corner case that previously lead to segfault
>  * due to an attempt to access unitialised tcp->s_ent.
>  *
>  * 13994 ????( <unfinished ...>
>  * ...
>  * 13994 <... ???? resumed>) = ?
>  *
>  * Copyright (c) 2019 The strace developers.
>  * All rights reserved.
>  *
>  * SPDX-License-Identifier: GPL-2.0-or-later
>  */
>
> #include "tests.h"
>
> #include <sched.h>
> #include <signal.h>
> #include <unistd.h>
> #include <sys/mman.h>
> #include <sys/wait.h>
>
> #define ITERS    10000
> #define SC_ITERS 10000
>
> int
> main(void)
> {
> 	volatile sig_atomic_t *const mem > 		mmap(NULL, get_page_size(), PROT_READ | PROT_WRITE,
> 		     MAP_SHARED | MAP_ANONYMOUS, -1, 0);
> 	if (mem = MAP_FAILED)
> 		perror_msg_and_fail("mmap");
>
> 	for (unsigned int i = 0; i < ITERS; ++i) {
> 		mem[0] = mem[1] = 0;
>
> 		const pid_t pid = fork();
> 		if (pid < 0)
> 			perror_msg_and_fail("fork");
>
> 		if (!pid) {
> 			/* wait for the parent */
> 			while (!mem[0])
> 				;
> 			/* let the parent know we are running */
> 			mem[1] = 1;
>
> 			for (unsigned int j = 0; j < SC_ITERS; j++)
> 				sched_yield();
>
> 			pause();
> 			return 0;
> 		}
>
> 		/* let the child know we are running */
> 		mem[0] = 1;
> 		/* wait for the child */
> 		while (!mem[1])
> 			;
>
> 		if (kill(pid, SIGKILL))
> 			perror_msg_and_fail("kill");
> 		if (wait(NULL) != pid)
> 			perror_msg_and_fail("wait");
> 	}
>
> 	return 0;
> }
