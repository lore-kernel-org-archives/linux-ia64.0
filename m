From: "Eric W. Biederman" <ebiederm@xmission.com>
Date: Wed, 18 May 2022 22:53:50 +0000
Subject: [PATCH 11/16] ptrace: Use si_sino as the signal number to resume with
Message-Id: <20220518225355.784371-11-ebiederm@xmission.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <871qwq5ucx.fsf_-_@email.froward.int.ebiederm.org>
In-Reply-To: <871qwq5ucx.fsf_-_@email.froward.int.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: rjw@rjwysocki.net, Oleg Nesterov <oleg@redhat.com>, mingo@kernel.org, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, rostedt@goodmis.org, mgorman@suse.de, bigeasy@linutronix.de, Will Deacon <will@kernel.org>, tj@kernel.org, linux-pm@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Richard Weinberger <richard@nod.at>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, Johannes Berg <johannes@sipsolutions.net>, linux-um@lists.infradead.org, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, linux-xtensa@linux-xtensa.org, Kees Cook <keescook@chromium.org>, Jann Horn <jannh@google.com>, linux-ia64@vger.kernel.org, Robert OCallahan <roc@pernos.co>, Kyle Huey <khuey@pernos.co>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Jason Wessel <jason.wessel@windriver.com>, Daniel Thompson <daniel.thompson@linaro.org>, Douglas Anderson <dianders@chromium.org>, Douglas Miller <dougmill@linux.vnet.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, "Eric W. Biederman" <ebiederm@xmission.com>

The signal number to resume with is already in si_signo.  So instead
of placing an extra copy in tsk->exit_code and later reading the extra
copy from tsk->exit_code just read si_signo.

Read si_signo in ptrace_do_notify where it is easy as the siginfo is a
local variable.  Only ptrace_report_syscall cares about the signal to
resume with from ptrace_stop and it calls ptrace_notify which calls
ptrace_do_notify so moving the actual work into ptrace_do_notify where
it is easier is not a problem.

With ptrace_stop not being involved in returning the signal to tracer
asked the tracee to resume with remove the comment and the return
code from ptrace_stop.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 kernel/ptrace.c |  1 -
 kernel/signal.c | 13 ++++---------
 2 files changed, 4 insertions(+), 10 deletions(-)

diff --git a/kernel/ptrace.c b/kernel/ptrace.c
index a0a07d140751..e0ecb1536dfc 100644
--- a/kernel/ptrace.c
+++ b/kernel/ptrace.c
@@ -530,7 +530,6 @@ static void ptrace_set_signr(struct task_struct *child, unsigned int signr)
 {
 	struct kernel_siginfo *info = child->last_siginfo;
 
-	child->exit_code = signr;
 	/*
 	 * Update the siginfo structure if the signal has
 	 * changed.  If the debugger wanted something
diff --git a/kernel/signal.c b/kernel/signal.c
index 3d955c23b13d..2cc45e8448e2 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -2186,12 +2186,8 @@ static void do_notify_parent_cldstop(struct task_struct *tsk,
  * We always set current->last_siginfo while stopped here.
  * That makes it a way to test a stopped process for
  * being ptrace-stopped vs being job-control-stopped.
- *
- * Returns the signal the ptracer requested the code resume
- * with.  If the code did not stop because the tracer is gone,
- * the stop signal remains unchanged unless clear_code.
  */
-static int ptrace_stop(int exit_code, int why, unsigned long message,
+static void ptrace_stop(int exit_code, int why, unsigned long message,
 		       kernel_siginfo_t *info)
 	__releases(&current->sighand->siglock)
 	__acquires(&current->sighand->siglock)
@@ -2219,7 +2215,7 @@ static int ptrace_stop(int exit_code, int why, unsigned long message,
 	 * signals here to prevent ptrace_stop sleeping in schedule.
 	 */
 	if (!current->ptrace || __fatal_signal_pending(current))
-		return exit_code;
+		return;
 
 	set_special_state(TASK_TRACED);
 	current->jobctl |= JOBCTL_TRACED;
@@ -2302,7 +2298,6 @@ static int ptrace_stop(int exit_code, int why, unsigned long message,
 	 * any signal-sending on another CPU that wants to examine it.
 	 */
 	spin_lock_irq(&current->sighand->siglock);
-	exit_code = current->exit_code;
 	current->last_siginfo = NULL;
 	current->ptrace_message = 0;
 	current->exit_code = 0;
@@ -2316,7 +2311,6 @@ static int ptrace_stop(int exit_code, int why, unsigned long message,
 	 * This sets TIF_SIGPENDING, but never clears it.
 	 */
 	recalc_sigpending_tsk(current);
-	return exit_code;
 }
 
 static int ptrace_do_notify(int signr, int exit_code, int why, unsigned long message)
@@ -2330,7 +2324,8 @@ static int ptrace_do_notify(int signr, int exit_code, int why, unsigned long mes
 	info.si_uid = from_kuid_munged(current_user_ns(), current_uid());
 
 	/* Let the debugger run.  */
-	return ptrace_stop(exit_code, why, message, &info);
+	ptrace_stop(exit_code, why, message, &info);
+	return info.si_signo;
 }
 
 int ptrace_notify(int exit_code, unsigned long message)
-- 
2.35.3
