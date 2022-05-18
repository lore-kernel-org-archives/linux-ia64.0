From: "Eric W. Biederman" <ebiederm@xmission.com>
Date: Wed, 18 May 2022 22:53:47 +0000
Subject: [PATCH 08/16] ptrace: Only populate last_siginfo from ptrace
Message-Id: <20220518225355.784371-8-ebiederm@xmission.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <871qwq5ucx.fsf_-_@email.froward.int.ebiederm.org>
In-Reply-To: <871qwq5ucx.fsf_-_@email.froward.int.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: rjw@rjwysocki.net, Oleg Nesterov <oleg@redhat.com>, mingo@kernel.org, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, rostedt@goodmis.org, mgorman@suse.de, bigeasy@linutronix.de, Will Deacon <will@kernel.org>, tj@kernel.org, linux-pm@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Richard Weinberger <richard@nod.at>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, Johannes Berg <johannes@sipsolutions.net>, linux-um@lists.infradead.org, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, linux-xtensa@linux-xtensa.org, Kees Cook <keescook@chromium.org>, Jann Horn <jannh@google.com>, linux-ia64@vger.kernel.org, Robert OCallahan <roc@pernos.co>, Kyle Huey <khuey@pernos.co>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Jason Wessel <jason.wessel@windriver.com>, Daniel Thompson <daniel.thompson@linaro.org>, Douglas Anderson <dianders@chromium.org>, Douglas Miller <dougmill@linux.vnet.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, "Eric W. Biederman" <ebiederm@xmission.com>

The code in ptrace_signal to populate siginfo if the signal number
changed is buggy.  If the tracer contined the tracee using
ptrace_detach it is guaranteed to use the real_parent (or possibly a
new tracer) but definitely not the origional tracer to populate si_pid
and si_uid.

Fix this bug by only updating siginfo from the tracer so that the
tracers pid and the tracers uid are always used.

If it happens that ptrace_resume or ptrace_detach don't have
a signal to continue with clear siginfo.

This is a very old bug that has been fixable since commit 1669ce53e2ff
("Add PTRACE_GETSIGINFO and PTRACE_SETSIGINFO") when last_siginfo was
introduced and the tracer could change siginfo.

Fixes: v2.1.68
History-Tree: https://git.kernel.org/pub/scm/linux/kernel/git/tglx/history.git
Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 kernel/ptrace.c | 31 +++++++++++++++++++++++++++++--
 kernel/signal.c | 18 ------------------
 2 files changed, 29 insertions(+), 20 deletions(-)

diff --git a/kernel/ptrace.c b/kernel/ptrace.c
index 15e93eafa6f0..a24eed725cec 100644
--- a/kernel/ptrace.c
+++ b/kernel/ptrace.c
@@ -526,6 +526,33 @@ static int ptrace_traceme(void)
 	return ret;
 }
 
+static void ptrace_set_signr(struct task_struct *child, unsigned int signr)
+{
+	struct kernel_siginfo *info = child->last_siginfo;
+
+	child->exit_code = signr;
+	/*
+	 * Update the siginfo structure if the signal has
+	 * changed.  If the debugger wanted something
+	 * specific in the siginfo structure then it should
+	 * have updated *info via PTRACE_SETSIGINFO.
+	 */
+	if (info && (info->si_signo != signr)) {
+		clear_siginfo(info);
+
+		if (signr != 0) {
+			info->si_signo = signr;
+			info->si_errno = 0;
+			info->si_code = SI_USER;
+			rcu_read_lock();
+			info->si_pid = task_pid_nr_ns(current, task_active_pid_ns(child));
+			info->si_uid = from_kuid_munged(task_cred_xxx(child, user_ns),
+						current_uid());
+			rcu_read_unlock();
+		}
+	}
+}
+
 /*
  * Called with tasklist_lock held for writing.
  * Unlink a traced task, and clean it up if it was a traced zombie.
@@ -579,7 +606,7 @@ static int ptrace_detach(struct task_struct *child, unsigned int data)
 	 * tasklist_lock avoids the race with wait_task_stopped(), see
 	 * the comment in ptrace_resume().
 	 */
-	child->exit_code = data;
+	ptrace_set_signr(child, data);
 	__ptrace_detach(current, child);
 	write_unlock_irq(&tasklist_lock);
 
@@ -851,7 +878,7 @@ static int ptrace_resume(struct task_struct *child, long request,
 	 * wait_task_stopped() after resume.
 	 */
 	spin_lock_irq(&child->sighand->siglock);
-	child->exit_code = data;
+	ptrace_set_signr(child, data);
 	child->jobctl &= ~JOBCTL_TRACED;
 	wake_up_state(child, __TASK_TRACED);
 	spin_unlock_irq(&child->sighand->siglock);
diff --git a/kernel/signal.c b/kernel/signal.c
index e782c2611b64..ff4a52352390 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -2562,24 +2562,6 @@ static int ptrace_signal(int signr, kernel_siginfo_t *info, enum pid_type type)
 	if (signr = 0)
 		return signr;
 
-	/*
-	 * Update the siginfo structure if the signal has
-	 * changed.  If the debugger wanted something
-	 * specific in the siginfo structure then it should
-	 * have updated *info via PTRACE_SETSIGINFO.
-	 */
-	if (signr != info->si_signo) {
-		clear_siginfo(info);
-		info->si_signo = signr;
-		info->si_errno = 0;
-		info->si_code = SI_USER;
-		rcu_read_lock();
-		info->si_pid = task_pid_vnr(current->parent);
-		info->si_uid = from_kuid_munged(current_user_ns(),
-						task_uid(current->parent));
-		rcu_read_unlock();
-	}
-
 	/* If the (new) signal is now blocked, requeue it.  */
 	if (sigismember(&current->blocked, signr) ||
 	    fatal_signal_pending(current)) {
-- 
2.35.3
