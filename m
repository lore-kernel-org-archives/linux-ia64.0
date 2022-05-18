From: "Eric W. Biederman" <ebiederm@xmission.com>
Date: Wed, 18 May 2022 22:53:54 +0000
Subject: [PATCH 15/16] ptrace: Use siglock instead of tasklist_lock in ptrace_check_attach
Message-Id: <20220518225355.784371-15-ebiederm@xmission.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <871qwq5ucx.fsf_-_@email.froward.int.ebiederm.org>
In-Reply-To: <871qwq5ucx.fsf_-_@email.froward.int.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: rjw@rjwysocki.net, Oleg Nesterov <oleg@redhat.com>, mingo@kernel.org, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, rostedt@goodmis.org, mgorman@suse.de, bigeasy@linutronix.de, Will Deacon <will@kernel.org>, tj@kernel.org, linux-pm@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Richard Weinberger <richard@nod.at>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, Johannes Berg <johannes@sipsolutions.net>, linux-um@lists.infradead.org, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, linux-xtensa@linux-xtensa.org, Kees Cook <keescook@chromium.org>, Jann Horn <jannh@google.com>, linux-ia64@vger.kernel.org, Robert OCallahan <roc@pernos.co>, Kyle Huey <khuey@pernos.co>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Jason Wessel <jason.wessel@windriver.com>, Daniel Thompson <daniel.thompson@linaro.org>, Douglas Anderson <dianders@chromium.org>, Douglas Miller <dougmill@linux.vnet.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, "Eric W. Biederman" <ebiederm@xmission.com>

Now that siglock protects tsk->parent and tsk->ptrace there is no need
to grab tasklist_lock in ptrace_check_attach.  The siglock can handle
all of the locking needs of ptrace_check_attach.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 kernel/ptrace.c | 23 +++++++++--------------
 1 file changed, 9 insertions(+), 14 deletions(-)

diff --git a/kernel/ptrace.c b/kernel/ptrace.c
index 77dfdb3d1ced..fa65841bbdbe 100644
--- a/kernel/ptrace.c
+++ b/kernel/ptrace.c
@@ -194,17 +194,14 @@ static bool ptrace_freeze_traced(struct task_struct *task)
 {
 	bool ret = false;
 
-	/* Lockless, nobody but us can set this flag */
 	if (task->jobctl & JOBCTL_LISTENING)
 		return ret;
 
-	spin_lock_irq(&task->sighand->siglock);
 	if (task_is_traced(task) && !looks_like_a_spurious_pid(task) &&
 	    !__fatal_signal_pending(task)) {
 		task->jobctl |= JOBCTL_PTRACE_FROZEN;
 		ret = true;
 	}
-	spin_unlock_irq(&task->sighand->siglock);
 
 	return ret;
 }
@@ -240,32 +237,30 @@ static void ptrace_unfreeze_traced(struct task_struct *task)
  * state.
  *
  * CONTEXT:
- * Grabs and releases tasklist_lock and @child->sighand->siglock.
+ * Grabs and releases @child->sighand->siglock.
  *
  * RETURNS:
  * 0 on success, -ESRCH if %child is not ready.
  */
 static int ptrace_check_attach(struct task_struct *child, bool ignore_state)
 {
+	unsigned long flags;
 	int ret = -ESRCH;
 
 	/*
-	 * We take the read lock around doing both checks to close a
+	 * We take the siglock around doing both checks to close a
 	 * possible race where someone else was tracing our child and
 	 * detached between these two checks.  After this locked check,
 	 * we are sure that this is our traced child and that can only
 	 * be changed by us so it's not changing right after this.
 	 */
-	read_lock(&tasklist_lock);
-	if (child->ptrace && child->parent = current) {
-		/*
-		 * child->sighand can't be NULL, release_task()
-		 * does ptrace_unlink() before __exit_signal().
-		 */
-		if (ignore_state || ptrace_freeze_traced(child))
-			ret = 0;
+	if (lock_task_sighand(child, &flags)) {
+		if (child->ptrace && child->parent = current) {
+			if (ignore_state || ptrace_freeze_traced(child))
+				ret = 0;
+		}
+		unlock_task_sighand(child, &flags);
 	}
-	read_unlock(&tasklist_lock);
 
 	if (!ret && !ignore_state &&
 	    WARN_ON_ONCE(!wait_task_inactive(child, __TASK_TRACED)))
-- 
2.35.3
