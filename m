From: "Eric W. Biederman" <ebiederm@xmission.com>
Date: Fri, 29 Apr 2022 21:48:32 +0000
Subject: [PATCH v2 07/12] ptrace: Don't change __state
Message-Id: <20220429214837.386518-7-ebiederm@xmission.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <87k0b7v9yk.fsf_-_@email.froward.int.ebiederm.org>
In-Reply-To: <87k0b7v9yk.fsf_-_@email.froward.int.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: rjw@rjwysocki.net, Oleg Nesterov <oleg@redhat.com>, mingo@kernel.org, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, rostedt@goodmis.org, mgorman@suse.de, bigeasy@linutronix.de, Will Deacon <will@kernel.org>, tj@kernel.org, linux-pm@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Richard Weinberger <richard@nod.at>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, Johannes Berg <johannes@sipsolutions.net>, linux-um@lists.infradead.org, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, linux-xtensa@linux-xtensa.org, Kees Cook <keescook@chromium.org>, Jann Horn <jannh@google.com>, linux-ia64@vger.kernel.org, "Eric W. Biederman" <ebiederm@xmission.com>

Stop playing with tsk->__state to remove TASK_WAKEKILL while a ptrace
command is executing.

Instead TASK_WAKEKILL from the definition of TASK_TRACED, and
implemention a new jobctl flag TASK_PTRACE_FROZEN.  This new This new
flag is set in jobctl_freeze_task and cleared when ptrace_stop is
awoken or in jobctl_unfreeze_task (when ptrace_stop remains asleep).

In singal_wake_up add __TASK_TRACED to state along with TASK_WAKEKILL
when it is indicated a fatal signal is pending.  Skip adding
__TASK_TRACED when TASK_PTRACE_FROZEN is not set.  This has the same
effect as changing TASK_TRACED to __TASK_TRACED as all of the wake_ups
that use TASK_KILLABLE go through signal_wake_up.

Don't set TASK_TRACED if fatal_signal_pending so that the code
continues not to sleep if there was a pending fatal signal before
ptrace_stop is called.  With TASK_WAKEKILL no longer present in
TASK_TRACED signal_pending_state will no longer prevent ptrace_stop
from sleeping if there is a pending fatal signal.

Previously the __state value of __TASK_TRACED was changed to
TASK_RUNNING when woken up or back to TASK_TRACED when the code was
left in ptrace_stop.  Now when woken up ptrace_stop now clears
JOBCTL_PTRACE_FROZEN and when left sleeping ptrace_unfreezed_traced
clears JOBCTL_PTRACE_FROZEN.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/linux/sched.h        |  2 +-
 include/linux/sched/jobctl.h |  2 ++
 include/linux/sched/signal.h |  8 +++++++-
 kernel/ptrace.c              | 21 ++++++++-------------
 kernel/signal.c              |  9 +++------
 5 files changed, 21 insertions(+), 21 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index d5e3c00b74e1..610f2fdb1e2c 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -103,7 +103,7 @@ struct task_group;
 /* Convenience macros for the sake of set_current_state: */
 #define TASK_KILLABLE			(TASK_WAKEKILL | TASK_UNINTERRUPTIBLE)
 #define TASK_STOPPED			(TASK_WAKEKILL | __TASK_STOPPED)
-#define TASK_TRACED			(TASK_WAKEKILL | __TASK_TRACED)
+#define TASK_TRACED			__TASK_TRACED
 
 #define TASK_IDLE			(TASK_UNINTERRUPTIBLE | TASK_NOLOAD)
 
diff --git a/include/linux/sched/jobctl.h b/include/linux/sched/jobctl.h
index fa067de9f1a9..d556c3425963 100644
--- a/include/linux/sched/jobctl.h
+++ b/include/linux/sched/jobctl.h
@@ -19,6 +19,7 @@ struct task_struct;
 #define JOBCTL_TRAPPING_BIT	21	/* switching to TRACED */
 #define JOBCTL_LISTENING_BIT	22	/* ptracer is listening for events */
 #define JOBCTL_TRAP_FREEZE_BIT	23	/* trap for cgroup freezer */
+#define JOBCTL_PTRACE_FROZEN_BIT	24	/* frozen for ptrace */
 
 #define JOBCTL_STOP_DEQUEUED	(1UL << JOBCTL_STOP_DEQUEUED_BIT)
 #define JOBCTL_STOP_PENDING	(1UL << JOBCTL_STOP_PENDING_BIT)
@@ -28,6 +29,7 @@ struct task_struct;
 #define JOBCTL_TRAPPING		(1UL << JOBCTL_TRAPPING_BIT)
 #define JOBCTL_LISTENING	(1UL << JOBCTL_LISTENING_BIT)
 #define JOBCTL_TRAP_FREEZE	(1UL << JOBCTL_TRAP_FREEZE_BIT)
+#define JOBCTL_PTRACE_FROZEN	(1UL << JOBCTL_PTRACE_FROZEN_BIT)
 
 #define JOBCTL_TRAP_MASK	(JOBCTL_TRAP_STOP | JOBCTL_TRAP_NOTIFY)
 #define JOBCTL_PENDING_MASK	(JOBCTL_STOP_PENDING | JOBCTL_TRAP_MASK)
diff --git a/include/linux/sched/signal.h b/include/linux/sched/signal.h
index 3c8b34876744..35af34eeee9e 100644
--- a/include/linux/sched/signal.h
+++ b/include/linux/sched/signal.h
@@ -437,7 +437,13 @@ extern void signal_wake_up_state(struct task_struct *t, unsigned int state);
 
 static inline void signal_wake_up(struct task_struct *t, bool resume)
 {
-	signal_wake_up_state(t, resume ? TASK_WAKEKILL : 0);
+	unsigned int state = 0;
+	if (resume) {
+		state = TASK_WAKEKILL;
+		if (!(t->jobctl & JOBCTL_PTRACE_FROZEN))
+			state |= __TASK_TRACED;
+	}
+	signal_wake_up_state(t, state);
 }
 static inline void ptrace_signal_wake_up(struct task_struct *t, bool resume)
 {
diff --git a/kernel/ptrace.c b/kernel/ptrace.c
index 43da5764b6f3..644eb7439d01 100644
--- a/kernel/ptrace.c
+++ b/kernel/ptrace.c
@@ -197,7 +197,7 @@ static bool ptrace_freeze_traced(struct task_struct *task)
 	spin_lock_irq(&task->sighand->siglock);
 	if (task_is_traced(task) && !looks_like_a_spurious_pid(task) &&
 	    !__fatal_signal_pending(task)) {
-		WRITE_ONCE(task->__state, __TASK_TRACED);
+		task->jobctl |= JOBCTL_PTRACE_FROZEN;
 		ret = true;
 	}
 	spin_unlock_irq(&task->sighand->siglock);
@@ -207,23 +207,19 @@ static bool ptrace_freeze_traced(struct task_struct *task)
 
 static void ptrace_unfreeze_traced(struct task_struct *task)
 {
-	if (READ_ONCE(task->__state) != __TASK_TRACED)
-		return;
-
-	WARN_ON(!task->ptrace || task->parent != current);
+	unsigned long flags;
 
 	/*
-	 * PTRACE_LISTEN can allow ptrace_trap_notify to wake us up remotely.
-	 * Recheck state under the lock to close this race.
+	 * The child may be awake and may have cleared
+	 * JOBCTL_PTRACE_FROZEN (see ptrace_resume).  The child will
+	 * not set JOBCTL_PTRACE_FROZEN or enter __TASK_TRACED anew.
 	 */
-	spin_lock_irq(&task->sighand->siglock);
-	if (READ_ONCE(task->__state) = __TASK_TRACED) {
+	if (lock_task_sighand(task, &flags)) {
+		task->jobctl &= ~JOBCTL_PTRACE_FROZEN;
 		if (__fatal_signal_pending(task))
 			wake_up_state(task, __TASK_TRACED);
-		else
-			WRITE_ONCE(task->__state, TASK_TRACED);
+		unlock_task_sighand(task, &flags);
 	}
-	spin_unlock_irq(&task->sighand->siglock);
 }
 
 /**
@@ -256,7 +252,6 @@ static int ptrace_check_attach(struct task_struct *child, bool ignore_state)
 	 */
 	read_lock(&tasklist_lock);
 	if (child->ptrace && child->parent = current) {
-		WARN_ON(READ_ONCE(child->__state) = __TASK_TRACED);
 		/*
 		 * child->sighand can't be NULL, release_task()
 		 * does ptrace_unlink() before __exit_signal().
diff --git a/kernel/signal.c b/kernel/signal.c
index 3fd2ce133387..5cf268982a7e 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -2209,11 +2209,8 @@ static int ptrace_stop(int exit_code, int why, int clear_code,
 		spin_lock_irq(&current->sighand->siglock);
 	}
 
-	/*
-	 * schedule() will not sleep if there is a pending signal that
-	 * can awaken the task.
-	 */
-	set_special_state(TASK_TRACED);
+	if (!__fatal_signal_pending(current))
+		set_special_state(TASK_TRACED);
 
 	/*
 	 * We're committing to trapping.  TRACED should be visible before
@@ -2321,7 +2318,7 @@ static int ptrace_stop(int exit_code, int why, int clear_code,
 	current->exit_code = 0;
 
 	/* LISTENING can be set only during STOP traps, clear it */
-	current->jobctl &= ~JOBCTL_LISTENING;
+	current->jobctl &= ~(JOBCTL_LISTENING | JOBCTL_PTRACE_FROZEN);
 
 	/*
 	 * Queued signals ignored us while we were stopped for tracing.
-- 
2.35.3
