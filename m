From: "Eric W. Biederman" <ebiederm@xmission.com>
Date: Wed, 04 May 2022 22:40:57 +0000
Subject: [PATCH v3 10/11] ptrace: Always take siglock in ptrace_resume
Message-Id: <20220504224058.476193-10-ebiederm@xmission.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <87k0b0apne.fsf_-_@email.froward.int.ebiederm.org>
In-Reply-To: <87k0b0apne.fsf_-_@email.froward.int.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: rjw@rjwysocki.net, Oleg Nesterov <oleg@redhat.com>, mingo@kernel.org, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, rostedt@goodmis.org, mgorman@suse.de, bigeasy@linutronix.de, Will Deacon <will@kernel.org>, tj@kernel.org, linux-pm@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Richard Weinberger <richard@nod.at>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, Johannes Berg <johannes@sipsolutions.net>, linux-um@lists.infradead.org, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, linux-xtensa@linux-xtensa.org, Kees Cook <keescook@chromium.org>, Jann Horn <jannh@google.com>, linux-ia64@vger.kernel.org, "Eric W. Biederman" <ebiederm@xmission.com>

Make code analysis simpler and future changes easier by
always taking siglock in ptrace_resume.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 kernel/ptrace.c | 13 ++-----------
 1 file changed, 2 insertions(+), 11 deletions(-)

diff --git a/kernel/ptrace.c b/kernel/ptrace.c
index 83ed28262708..36a5b7a00d2f 100644
--- a/kernel/ptrace.c
+++ b/kernel/ptrace.c
@@ -837,8 +837,6 @@ static long ptrace_get_rseq_configuration(struct task_struct *task,
 static int ptrace_resume(struct task_struct *child, long request,
 			 unsigned long data)
 {
-	bool need_siglock;
-
 	if (!valid_signal(data))
 		return -EIO;
 
@@ -874,18 +872,11 @@ static int ptrace_resume(struct task_struct *child, long request,
 	 * Note that we need siglock even if ->exit_code = data and/or this
 	 * status was not reported yet, the new status must not be cleared by
 	 * wait_task_stopped() after resume.
-	 *
-	 * If data = 0 we do not care if wait_task_stopped() reports the old
-	 * status and clears the code too; this can't race with the tracee, it
-	 * takes siglock after resume.
 	 */
-	need_siglock = data && !thread_group_empty(current);
-	if (need_siglock)
-		spin_lock_irq(&child->sighand->siglock);
+	spin_lock_irq(&child->sighand->siglock);
 	child->exit_code = data;
 	wake_up_state(child, __TASK_TRACED);
-	if (need_siglock)
-		spin_unlock_irq(&child->sighand->siglock);
+	spin_unlock_irq(&child->sighand->siglock);
 
 	return 0;
 }
-- 
2.35.3
