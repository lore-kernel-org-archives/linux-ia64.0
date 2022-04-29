From: "Eric W. Biederman" <ebiederm@xmission.com>
Date: Fri, 29 Apr 2022 21:48:37 +0000
Subject: [PATCH v2 12/12] sched,signal,ptrace: Rework TASK_TRACED, TASK_STOPPED state
Message-Id: <20220429214837.386518-12-ebiederm@xmission.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <87k0b7v9yk.fsf_-_@email.froward.int.ebiederm.org>
In-Reply-To: <87k0b7v9yk.fsf_-_@email.froward.int.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: rjw@rjwysocki.net, Oleg Nesterov <oleg@redhat.com>, mingo@kernel.org, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, rostedt@goodmis.org, mgorman@suse.de, bigeasy@linutronix.de, Will Deacon <will@kernel.org>, tj@kernel.org, linux-pm@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Richard Weinberger <richard@nod.at>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, Johannes Berg <johannes@sipsolutions.net>, linux-um@lists.infradead.org, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, linux-xtensa@linux-xtensa.org, Kees Cook <keescook@chromium.org>, Jann Horn <jannh@google.com>, linux-ia64@vger.kernel.org, "Eric W. Biederman" <ebiederm@xmission.com>

Currently ptrace_stop() / do_signal_stop() rely on the special states
TASK_TRACED and TASK_STOPPED resp. to keep unique state. That is, this
state exists only in task->__state and nowhere else.

There's two spots of bother with this:

 - PREEMPT_RT has task->saved_state which complicates matters,
   meaning task_is_{traced,stopped}() needs to check an additional
   variable.

 - An alternative freezer implementation that itself relies on a
   special TASK state would loose TASK_TRACED/TASK_STOPPED and will
   result in misbehaviour.

As such, add additional state to task->jobctl to track this state
outside of task->__state.

NOTE: this doesn't actually fix anything yet, just adds extra state.

--EWB
  * didn't add a unnecessary newline in signal.h
  * Update t->jobctl in signal_wake_up and ptrace_signal_wake_up
    instead of in signal_wake_up_state.  This prevents the clearing
    of TASK_STOPPED and TASK_TRACED from getting lost.
  * Added warnings if JOBCTL_STOPPED or JOBCTL_TRACED are not cleared

Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
Link: https://lkml.kernel.org/r/20220421150654.757693825@infradead.org
Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 include/linux/sched.h        |  8 +++-----
 include/linux/sched/jobctl.h |  6 ++++++
 include/linux/sched/signal.h | 17 ++++++++++++++---
 kernel/ptrace.c              | 17 +++++++++++++----
 kernel/signal.c              | 16 +++++++++++++---
 5 files changed, 49 insertions(+), 15 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 610f2fdb1e2c..cbe5c899599c 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -118,11 +118,9 @@ struct task_group;
 
 #define task_is_running(task)		(READ_ONCE((task)->__state) = TASK_RUNNING)
 
-#define task_is_traced(task)		((READ_ONCE(task->__state) & __TASK_TRACED) != 0)
-
-#define task_is_stopped(task)		((READ_ONCE(task->__state) & __TASK_STOPPED) != 0)
-
-#define task_is_stopped_or_traced(task)	((READ_ONCE(task->__state) & (__TASK_STOPPED | __TASK_TRACED)) != 0)
+#define task_is_traced(task)		((READ_ONCE(task->jobctl) & JOBCTL_TRACED) != 0)
+#define task_is_stopped(task)		((READ_ONCE(task->jobctl) & JOBCTL_STOPPED) != 0)
+#define task_is_stopped_or_traced(task)	((READ_ONCE(task->jobctl) & (JOBCTL_STOPPED | JOBCTL_TRACED)) != 0)
 
 /*
  * Special states are those that do not use the normal wait-loop pattern. See
diff --git a/include/linux/sched/jobctl.h b/include/linux/sched/jobctl.h
index 2ff1bcd63cf4..9c0b917de2f9 100644
--- a/include/linux/sched/jobctl.h
+++ b/include/linux/sched/jobctl.h
@@ -22,6 +22,9 @@ struct task_struct;
 #define JOBCTL_PTRACE_FROZEN_BIT	24	/* frozen for ptrace */
 #define JOBCTL_PTRACE_SIGNR_BIT	25	/* ptrace signal number */
 
+#define JOBCTL_STOPPED_BIT	26	/* do_signal_stop() */
+#define JOBCTL_TRACED_BIT	27	/* ptrace_stop() */
+
 #define JOBCTL_STOP_DEQUEUED	(1UL << JOBCTL_STOP_DEQUEUED_BIT)
 #define JOBCTL_STOP_PENDING	(1UL << JOBCTL_STOP_PENDING_BIT)
 #define JOBCTL_STOP_CONSUME	(1UL << JOBCTL_STOP_CONSUME_BIT)
@@ -33,6 +36,9 @@ struct task_struct;
 #define JOBCTL_PTRACE_FROZEN	(1UL << JOBCTL_PTRACE_FROZEN_BIT)
 #define JOBCTL_PTRACE_SIGNR	(1UL << JOBCTL_PTRACE_SIGNR_BIT)
 
+#define JOBCTL_STOPPED		(1UL << JOBCTL_STOPPED_BIT)
+#define JOBCTL_TRACED		(1UL << JOBCTL_TRACED_BIT)
+
 #define JOBCTL_TRAP_MASK	(JOBCTL_TRAP_STOP | JOBCTL_TRAP_NOTIFY)
 #define JOBCTL_PENDING_MASK	(JOBCTL_STOP_PENDING | JOBCTL_TRAP_MASK)
 
diff --git a/include/linux/sched/signal.h b/include/linux/sched/signal.h
index 35af34eeee9e..4dcce2bbf1fb 100644
--- a/include/linux/sched/signal.h
+++ b/include/linux/sched/signal.h
@@ -294,8 +294,10 @@ static inline int kernel_dequeue_signal(void)
 static inline void kernel_signal_stop(void)
 {
 	spin_lock_irq(&current->sighand->siglock);
-	if (current->jobctl & JOBCTL_STOP_DEQUEUED)
+	if (current->jobctl & JOBCTL_STOP_DEQUEUED) {
+		current->jobctl |= JOBCTL_STOPPED;
 		set_special_state(TASK_STOPPED);
+	}
 	spin_unlock_irq(&current->sighand->siglock);
 
 	schedule();
@@ -439,15 +441,24 @@ static inline void signal_wake_up(struct task_struct *t, bool resume)
 {
 	unsigned int state = 0;
 	if (resume) {
+		unsigned long jmask = JOBCTL_STOPPED;
 		state = TASK_WAKEKILL;
-		if (!(t->jobctl & JOBCTL_PTRACE_FROZEN))
+		if (!(t->jobctl & JOBCTL_PTRACE_FROZEN)) {
+			jmask |= JOBCTL_TRACED;
 			state |= __TASK_TRACED;
+		}
+		t->jobctl &= ~jmask;
 	}
 	signal_wake_up_state(t, state);
 }
 static inline void ptrace_signal_wake_up(struct task_struct *t, bool resume)
 {
-	signal_wake_up_state(t, resume ? __TASK_TRACED : 0);
+	unsigned int state = 0;
+	if (resume) {
+		t->jobctl &= ~JOBCTL_TRACED;
+		state = __TASK_TRACED;
+	}
+	signal_wake_up_state(t, state);
 }
 
 void task_join_group_stop(struct task_struct *task);
diff --git a/kernel/ptrace.c b/kernel/ptrace.c
index c1afebd2e8f3..38913801717f 100644
--- a/kernel/ptrace.c
+++ b/kernel/ptrace.c
@@ -185,7 +185,12 @@ static bool looks_like_a_spurious_pid(struct task_struct *task)
 	return true;
 }
 
-/* Ensure that nothing can wake it up, even SIGKILL */
+/*
+ * Ensure that nothing can wake it up, even SIGKILL
+ *
+ * A task is switched to this state while a ptrace operation is in progress;
+ * such that the ptrace operation is uninterruptible.
+ */
 static bool ptrace_freeze_traced(struct task_struct *task)
 {
 	bool ret = false;
@@ -216,8 +221,10 @@ static void ptrace_unfreeze_traced(struct task_struct *task)
 	 */
 	if (lock_task_sighand(task, &flags)) {
 		task->jobctl &= ~JOBCTL_PTRACE_FROZEN;
-		if (__fatal_signal_pending(task))
+		if (__fatal_signal_pending(task)) {
+			task->jobctl &= ~TASK_TRACED;
 			wake_up_state(task, __TASK_TRACED);
+		}
 		unlock_task_sighand(task, &flags);
 	}
 }
@@ -462,8 +469,10 @@ static int ptrace_attach(struct task_struct *task, long request,
 	 * in and out of STOPPED are protected by siglock.
 	 */
 	if (task_is_stopped(task) &&
-	    task_set_jobctl_pending(task, JOBCTL_TRAP_STOP | JOBCTL_TRAPPING))
+	    task_set_jobctl_pending(task, JOBCTL_TRAP_STOP | JOBCTL_TRAPPING)) {
+		task->jobctl &= ~JOBCTL_STOPPED;
 		signal_wake_up_state(task, __TASK_STOPPED);
+	}
 
 	spin_unlock(&task->sighand->siglock);
 
@@ -879,7 +888,7 @@ static int ptrace_resume(struct task_struct *child, long request,
 	 */
 	spin_lock_irq(&child->sighand->siglock);
 	child->exit_code = data;
-	child->jobctl |= JOBCTL_PTRACE_SIGNR;
+	child->jobctl = (child->jobctl | JOBCTL_PTRACE_SIGNR) & ~JOBCTL_TRACED;
 	wake_up_state(child, __TASK_TRACED);
 	spin_unlock_irq(&child->sighand->siglock);
 
diff --git a/kernel/signal.c b/kernel/signal.c
index 4cae3f47f664..d6573abbc169 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -762,7 +762,10 @@ static int dequeue_synchronous_signal(kernel_siginfo_t *info)
  */
 void signal_wake_up_state(struct task_struct *t, unsigned int state)
 {
+	lockdep_assert_held(&t->sighand->siglock);
+
 	set_tsk_thread_flag(t, TIF_SIGPENDING);
+
 	/*
 	 * TASK_WAKEKILL also means wake it up in the stopped/traced/killable
 	 * case. We don't check t->state here because there is a race with it
@@ -930,9 +933,10 @@ static bool prepare_signal(int sig, struct task_struct *p, bool force)
 		for_each_thread(p, t) {
 			flush_sigqueue_mask(&flush, &t->pending);
 			task_clear_jobctl_pending(t, JOBCTL_STOP_PENDING);
-			if (likely(!(t->ptrace & PT_SEIZED)))
+			if (likely(!(t->ptrace & PT_SEIZED))) {
+				t->jobctl &= ~JOBCTL_STOPPED;
 				wake_up_state(t, __TASK_STOPPED);
-			else
+			} else
 				ptrace_trap_notify(t);
 		}
 
@@ -2208,8 +2212,10 @@ static int ptrace_stop(int exit_code, int why, int clear_code,
 		spin_lock_irq(&current->sighand->siglock);
 	}
 
-	if (!__fatal_signal_pending(current))
+	if (!__fatal_signal_pending(current)) {
 		set_special_state(TASK_TRACED);
+		current->jobctl |= JOBCTL_TRACED;
+	}
 
 	/*
 	 * We're committing to trapping.  TRACED should be visible before
@@ -2301,6 +2307,7 @@ static int ptrace_stop(int exit_code, int why, int clear_code,
 
 	/* LISTENING can be set only during STOP traps, clear it */
 	current->jobctl &= ~(JOBCTL_LISTENING | JOBCTL_PTRACE_FROZEN | JOBCTL_PTRACE_SIGNR);
+	WARN_ON_ONCE(current->jobctl & JOBCTL_TRACED);
 
 	/*
 	 * Queued signals ignored us while we were stopped for tracing.
@@ -2433,6 +2440,7 @@ static bool do_signal_stop(int signr)
 		if (task_participate_group_stop(current))
 			notify = CLD_STOPPED;
 
+		current->jobctl |= JOBCTL_STOPPED;
 		set_special_state(TASK_STOPPED);
 		spin_unlock_irq(&current->sighand->siglock);
 
@@ -2454,6 +2462,8 @@ static bool do_signal_stop(int signr)
 		/* Now we don't run again until woken by SIGCONT or SIGKILL */
 		cgroup_enter_frozen();
 		freezable_schedule();
+
+		WARN_ON_ONCE(READ_ONCE(current->jobctl) & JOBCTL_STOPPED);
 		return true;
 	} else {
 		/*
-- 
2.35.3
