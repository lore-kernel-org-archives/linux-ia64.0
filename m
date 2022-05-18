From: "Eric W. Biederman" <ebiederm@xmission.com>
Date: Wed, 18 May 2022 22:53:51 +0000
Subject: [PATCH 12/16] ptrace: Stop protecting ptrace_set_signr with tasklist_lock
Message-Id: <20220518225355.784371-12-ebiederm@xmission.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <871qwq5ucx.fsf_-_@email.froward.int.ebiederm.org>
In-Reply-To: <871qwq5ucx.fsf_-_@email.froward.int.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: rjw@rjwysocki.net, Oleg Nesterov <oleg@redhat.com>, mingo@kernel.org, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, rostedt@goodmis.org, mgorman@suse.de, bigeasy@linutronix.de, Will Deacon <will@kernel.org>, tj@kernel.org, linux-pm@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Richard Weinberger <richard@nod.at>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, Johannes Berg <johannes@sipsolutions.net>, linux-um@lists.infradead.org, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, linux-xtensa@linux-xtensa.org, Kees Cook <keescook@chromium.org>, Jann Horn <jannh@google.com>, linux-ia64@vger.kernel.org, Robert OCallahan <roc@pernos.co>, Kyle Huey <khuey@pernos.co>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Jason Wessel <jason.wessel@windriver.com>, Daniel Thompson <daniel.thompson@linaro.org>, Douglas Anderson <dianders@chromium.org>, Douglas Miller <dougmill@linux.vnet.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, "Eric W. Biederman" <ebiederm@xmission.com>

Now that ptrace_set_signr no longer sets task->exit_code the race
documented in commit b72c186999e6 ("ptrace: fix race between
ptrace_resume() and wait_task_stopped()") is no longer possible, as
task->exit_code is only updated by wait during a ptrace_stop.

As there is no possibilty of a race and ptrace_freeze_traced is
all of the protection ptrace_set_signr needs to operate without
contention move ptrace_set_signr outside of tasklist_lock
and remove the documentation about the race that is no more.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 kernel/ptrace.c | 19 ++++---------------
 1 file changed, 4 insertions(+), 15 deletions(-)

diff --git a/kernel/ptrace.c b/kernel/ptrace.c
index e0ecb1536dfc..d0527b6e2b29 100644
--- a/kernel/ptrace.c
+++ b/kernel/ptrace.c
@@ -595,17 +595,14 @@ static int ptrace_detach(struct task_struct *child, unsigned int data)
 	/* Architecture-specific hardware disable .. */
 	ptrace_disable(child);
 
+	ptrace_set_signr(child, data);
+
 	write_lock_irq(&tasklist_lock);
 	/*
 	 * We rely on ptrace_freeze_traced(). It can't be killed and
 	 * untraced by another thread, it can't be a zombie.
 	 */
 	WARN_ON(!child->ptrace || child->exit_state);
-	/*
-	 * tasklist_lock avoids the race with wait_task_stopped(), see
-	 * the comment in ptrace_resume().
-	 */
-	ptrace_set_signr(child, data);
 	__ptrace_detach(current, child);
 	write_unlock_irq(&tasklist_lock);
 
@@ -869,17 +866,9 @@ static int ptrace_resume(struct task_struct *child, long request,
 		user_disable_single_step(child);
 	}
 
-	/*
-	 * Change ->exit_code and ->state under siglock to avoid the race
-	 * with wait_task_stopped() in between; a non-zero ->exit_code will
-	 * wrongly look like another report from tracee.
-	 *
-	 * Note that we need siglock even if ->exit_code = data and/or this
-	 * status was not reported yet, the new status must not be cleared by
-	 * wait_task_stopped() after resume.
-	 */
-	spin_lock_irq(&child->sighand->siglock);
 	ptrace_set_signr(child, data);
+
+	spin_lock_irq(&child->sighand->siglock);
 	child->jobctl &= ~JOBCTL_TRACED;
 	wake_up_state(child, __TASK_TRACED);
 	spin_unlock_irq(&child->sighand->siglock);
-- 
2.35.3
