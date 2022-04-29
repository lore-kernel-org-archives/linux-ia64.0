From: Peter Zijlstra <peterz@infradead.org>
Date: Fri, 29 Apr 2022 22:27:55 +0000
Subject: Re: [PATCH v2 07/12] ptrace: Don't change __state
Message-Id: <Ymxma2vRP+FjEkgq@hirez.programming.kicks-ass.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <87k0b7v9yk.fsf_-_@email.froward.int.ebiederm.org>
 <20220429214837.386518-7-ebiederm@xmission.com>
In-Reply-To: <20220429214837.386518-7-ebiederm@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: linux-kernel@vger.kernel.org, rjw@rjwysocki.net, Oleg Nesterov <oleg@redhat.com>, mingo@kernel.org, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, rostedt@goodmis.org, mgorman@suse.de, bigeasy@linutronix.de, Will Deacon <will@kernel.org>, tj@kernel.org, linux-pm@vger.kernel.org, Richard Weinberger <richard@nod.at>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, Johannes Berg <johannes@sipsolutions.net>, linux-um@lists.infradead.org, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, linux-xtensa@linux-xtensa.org, Kees Cook <keescook@chromium.org>, Jann Horn <jannh@google.com>, linux-ia64@vger.kernel.org

On Fri, Apr 29, 2022 at 04:48:32PM -0500, Eric W. Biederman wrote:
> Stop playing with tsk->__state to remove TASK_WAKEKILL while a ptrace
> command is executing.
> 
> Instead TASK_WAKEKILL from the definition of TASK_TRACED, and
> implemention a new jobctl flag TASK_PTRACE_FROZEN.  This new This new
> flag is set in jobctl_freeze_task and cleared when ptrace_stop is
> awoken or in jobctl_unfreeze_task (when ptrace_stop remains asleep).
> 
> In singal_wake_up add __TASK_TRACED to state along with TASK_WAKEKILL
> when it is indicated a fatal signal is pending.  Skip adding
> __TASK_TRACED when TASK_PTRACE_FROZEN is not set.  This has the same
> effect as changing TASK_TRACED to __TASK_TRACED as all of the wake_ups
> that use TASK_KILLABLE go through signal_wake_up.
> 
> Don't set TASK_TRACED if fatal_signal_pending so that the code
> continues not to sleep if there was a pending fatal signal before
> ptrace_stop is called.  With TASK_WAKEKILL no longer present in
> TASK_TRACED signal_pending_state will no longer prevent ptrace_stop
> from sleeping if there is a pending fatal signal.
> 
> Previously the __state value of __TASK_TRACED was changed to
> TASK_RUNNING when woken up or back to TASK_TRACED when the code was
> left in ptrace_stop.  Now when woken up ptrace_stop now clears
> JOBCTL_PTRACE_FROZEN and when left sleeping ptrace_unfreezed_traced
> clears JOBCTL_PTRACE_FROZEN.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> ---
>  include/linux/sched.h        |  2 +-
>  include/linux/sched/jobctl.h |  2 ++
>  include/linux/sched/signal.h |  8 +++++++-
>  kernel/ptrace.c              | 21 ++++++++-------------
>  kernel/signal.c              |  9 +++------
>  5 files changed, 21 insertions(+), 21 deletions(-)

Please fold this hunk:

--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -6310,10 +6310,7 @@ static void __sched notrace __schedule(u
 
 	/*
 	 * We must load prev->state once (task_struct::state is volatile), such
-	 * that:
-	 *
-	 *  - we form a control dependency vs deactivate_task() below.
-	 *  - ptrace_{,un}freeze_traced() can change ->state underneath us.
+	 * that we form a control dependency vs deactivate_task() below.
 	 */
 	prev_state = READ_ONCE(prev->__state);
 	if (!(sched_mode & SM_MASK_PREEMPT) && prev_state) {
