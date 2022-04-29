From: "Eric W. Biederman" <ebiederm@xmission.com>
Date: Fri, 29 Apr 2022 21:48:35 +0000
Subject: [PATCH v2 10/12] ptrace: Only return signr from ptrace_stop if it was provided
Message-Id: <20220429214837.386518-10-ebiederm@xmission.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <87k0b7v9yk.fsf_-_@email.froward.int.ebiederm.org>
In-Reply-To: <87k0b7v9yk.fsf_-_@email.froward.int.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: rjw@rjwysocki.net, Oleg Nesterov <oleg@redhat.com>, mingo@kernel.org, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, rostedt@goodmis.org, mgorman@suse.de, bigeasy@linutronix.de, Will Deacon <will@kernel.org>, tj@kernel.org, linux-pm@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Richard Weinberger <richard@nod.at>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, Johannes Berg <johannes@sipsolutions.net>, linux-um@lists.infradead.org, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, linux-xtensa@linux-xtensa.org, Kees Cook <keescook@chromium.org>, Jann Horn <jannh@google.com>, linux-ia64@vger.kernel.org, "Eric W. Biederman" <ebiederm@xmission.com>

In ptrace_stop a ptrace_unlink or SIGKILL can occur either after
siglock is dropped or after tasklist_lock is dropped.  At either point
the result can be that ptrace will continue and not stop at schedule.

This means that there are cases where the current logic fails to handle
the fact that ptrace_stop did not actually stop, and can potentially
cause ptrace_report_syscall to attempt to deliver a signal.

Instead of attempting to detect in ptrace_stop when it fails to
stop update ptrace_resume and ptrace_detach to set a flag to indicate
that the signal to continue with has be set.   Use that
new flag to decided how to set return signal.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/linux/sched/jobctl.h |  2 ++
 kernel/ptrace.c              |  5 +++++
 kernel/signal.c              | 12 ++++++------
 3 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/include/linux/sched/jobctl.h b/include/linux/sched/jobctl.h
index d556c3425963..2ff1bcd63cf4 100644
--- a/include/linux/sched/jobctl.h
+++ b/include/linux/sched/jobctl.h
@@ -20,6 +20,7 @@ struct task_struct;
 #define JOBCTL_LISTENING_BIT	22	/* ptracer is listening for events */
 #define JOBCTL_TRAP_FREEZE_BIT	23	/* trap for cgroup freezer */
 #define JOBCTL_PTRACE_FROZEN_BIT	24	/* frozen for ptrace */
+#define JOBCTL_PTRACE_SIGNR_BIT	25	/* ptrace signal number */
 
 #define JOBCTL_STOP_DEQUEUED	(1UL << JOBCTL_STOP_DEQUEUED_BIT)
 #define JOBCTL_STOP_PENDING	(1UL << JOBCTL_STOP_PENDING_BIT)
@@ -30,6 +31,7 @@ struct task_struct;
 #define JOBCTL_LISTENING	(1UL << JOBCTL_LISTENING_BIT)
 #define JOBCTL_TRAP_FREEZE	(1UL << JOBCTL_TRAP_FREEZE_BIT)
 #define JOBCTL_PTRACE_FROZEN	(1UL << JOBCTL_PTRACE_FROZEN_BIT)
+#define JOBCTL_PTRACE_SIGNR	(1UL << JOBCTL_PTRACE_SIGNR_BIT)
 
 #define JOBCTL_TRAP_MASK	(JOBCTL_TRAP_STOP | JOBCTL_TRAP_NOTIFY)
 #define JOBCTL_PENDING_MASK	(JOBCTL_STOP_PENDING | JOBCTL_TRAP_MASK)
diff --git a/kernel/ptrace.c b/kernel/ptrace.c
index c1c99e8be147..d80222251f60 100644
--- a/kernel/ptrace.c
+++ b/kernel/ptrace.c
@@ -596,7 +596,11 @@ static int ptrace_detach(struct task_struct *child, unsigned int data)
 	 * tasklist_lock avoids the race with wait_task_stopped(), see
 	 * the comment in ptrace_resume().
 	 */
+	spin_lock(&child->sighand->siglock);
 	child->exit_code = data;
+	child->jobctl |= JOBCTL_PTRACE_SIGNR;
+	spin_unlock(&child->sighand->siglock);
+
 	__ptrace_detach(current, child);
 	write_unlock_irq(&tasklist_lock);
 
@@ -883,6 +887,7 @@ static int ptrace_resume(struct task_struct *child, long request,
 	 */
 	spin_lock_irq(&child->sighand->siglock);
 	child->exit_code = data;
+	child->jobctl |= JOBCTL_PTRACE_SIGNR;
 	wake_up_state(child, __TASK_TRACED);
 	spin_unlock_irq(&child->sighand->siglock);
 
diff --git a/kernel/signal.c b/kernel/signal.c
index 5cf268982a7e..7cb27a27290a 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -2193,7 +2193,6 @@ static int ptrace_stop(int exit_code, int why, int clear_code,
 	__acquires(&current->sighand->siglock)
 {
 	bool gstop_done = false;
-	bool read_code = true;
 
 	if (arch_ptrace_stop_needed()) {
 		/*
@@ -2299,9 +2298,6 @@ static int ptrace_stop(int exit_code, int why, int clear_code,
 
 		/* tasklist protects us from ptrace_freeze_traced() */
 		__set_current_state(TASK_RUNNING);
-		read_code = false;
-		if (clear_code)
-			exit_code = 0;
 		read_unlock(&tasklist_lock);
 	}
 
@@ -2311,14 +2307,18 @@ static int ptrace_stop(int exit_code, int why, int clear_code,
 	 * any signal-sending on another CPU that wants to examine it.
 	 */
 	spin_lock_irq(&current->sighand->siglock);
-	if (read_code)
+	/* Did userspace perhaps provide a signal to resume with? */
+	if (current->jobctl & JOBCTL_PTRACE_SIGNR)
 		exit_code = current->exit_code;
+	else if (clear_code)
+		exit_code = 0;
+
 	current->last_siginfo = NULL;
 	current->ptrace_message = 0;
 	current->exit_code = 0;
 
 	/* LISTENING can be set only during STOP traps, clear it */
-	current->jobctl &= ~(JOBCTL_LISTENING | JOBCTL_PTRACE_FROZEN);
+	current->jobctl &= ~(JOBCTL_LISTENING | JOBCTL_PTRACE_FROZEN | JOBCTL_PTRACE_SIGNR);
 
 	/*
 	 * Queued signals ignored us while we were stopped for tracing.
-- 
2.35.3
