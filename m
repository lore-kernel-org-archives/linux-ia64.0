From: "Eric W. Biederman" <ebiederm@xmission.com>
Date: Wed, 18 May 2022 22:53:53 +0000
Subject: [PATCH 14/16] signal: Protect parent child relationships by childs siglock
Message-Id: <20220518225355.784371-14-ebiederm@xmission.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <871qwq5ucx.fsf_-_@email.froward.int.ebiederm.org>
In-Reply-To: <871qwq5ucx.fsf_-_@email.froward.int.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: rjw@rjwysocki.net, Oleg Nesterov <oleg@redhat.com>, mingo@kernel.org, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, rostedt@goodmis.org, mgorman@suse.de, bigeasy@linutronix.de, Will Deacon <will@kernel.org>, tj@kernel.org, linux-pm@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Richard Weinberger <richard@nod.at>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, Johannes Berg <johannes@sipsolutions.net>, linux-um@lists.infradead.org, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, linux-xtensa@linux-xtensa.org, Kees Cook <keescook@chromium.org>, Jann Horn <jannh@google.com>, linux-ia64@vger.kernel.org, Robert OCallahan <roc@pernos.co>, Kyle Huey <khuey@pernos.co>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Jason Wessel <jason.wessel@windriver.com>, Daniel Thompson <daniel.thompson@linaro.org>, Douglas Anderson <dianders@chromium.org>, Douglas Miller <dougmill@linux.vnet.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, "Eric W. Biederman" <ebiederm@xmission.com>

The functions ptrace_stop and do_signal_stop have to drop siglock
and grab tasklist_lock because the parent/child relation ship
is guarded by tasklist_lock and not siglock.

Simplify things by additionally guarding the parent/child relationship
with siglock.  This just requires a little bit of code motion.

After this change tsk->parent, tsk->real_parent, tsk->ptracer_cred
are all protected by tsk->siglock.

The fields tsk->sibling and tsk->ptrace_entry are mostly protected by
tsk->siglock.  The field tsk->ptrace_entry is not protected by siglock
when tsk->ptrace_entry is reused as the dead task list.  The field
tsk->sibling is not protected by siglock when children are reparented
because their original parent dies.

The field tsk->ptrace is protected by siglock except for the options
which may change without siglock being held.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 kernel/exit.c   |  4 ++++
 kernel/fork.c   | 12 ++++++------
 kernel/ptrace.c |  9 +++++----
 3 files changed, 15 insertions(+), 10 deletions(-)

diff --git a/kernel/exit.c b/kernel/exit.c
index 0e26f73c49ac..bad434b23c48 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -643,11 +643,15 @@ static void forget_original_parent(struct task_struct *father,
 
 	reaper = find_new_reaper(father, reaper);
 	list_for_each_entry(p, &father->children, sibling) {
+		spin_lock(&p->sighand->siglock);
 		for_each_thread(p, t) {
 			RCU_INIT_POINTER(t->real_parent, reaper);
 			BUG_ON((!t->ptrace) != (rcu_access_pointer(t->parent) = father));
 			if (likely(!t->ptrace))
 				t->parent = t->real_parent;
+		}
+		spin_unlock(&p->sighand->siglock);
+		for_each_thread(p, t) {
 			if (t->pdeath_signal)
 				group_send_sig_info(t->pdeath_signal,
 						    SEND_SIG_NOINFO, t,
diff --git a/kernel/fork.c b/kernel/fork.c
index 9796897560ab..841021da69f3 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -2367,6 +2367,12 @@ static __latent_entropy struct task_struct *copy_process(
 	 */
 	write_lock_irq(&tasklist_lock);
 
+	klp_copy_process(p);
+
+	sched_core_fork(p);
+
+	spin_lock(&current->sighand->siglock);
+
 	/* CLONE_PARENT re-uses the old parent */
 	if (clone_flags & (CLONE_PARENT|CLONE_THREAD)) {
 		p->real_parent = current->real_parent;
@@ -2381,12 +2387,6 @@ static __latent_entropy struct task_struct *copy_process(
 		p->exit_signal = args->exit_signal;
 	}
 
-	klp_copy_process(p);
-
-	sched_core_fork(p);
-
-	spin_lock(&current->sighand->siglock);
-
 	/*
 	 * Copy seccomp details explicitly here, in case they were changed
 	 * before holding sighand lock.
diff --git a/kernel/ptrace.c b/kernel/ptrace.c
index fbadd2f21f09..77dfdb3d1ced 100644
--- a/kernel/ptrace.c
+++ b/kernel/ptrace.c
@@ -123,13 +123,12 @@ void __ptrace_unlink(struct task_struct *child)
 	clear_task_syscall_work(child, SYSCALL_EMU);
 #endif
 
+	spin_lock(&child->sighand->siglock);
 	child->parent = child->real_parent;
 	list_del_init(&child->ptrace_entry);
 	old_cred = child->ptracer_cred;
 	child->ptracer_cred = NULL;
 	put_cred(old_cred);
-
-	spin_lock(&child->sighand->siglock);
 	child->ptrace = 0;
 	/*
 	 * Clear all pending traps and TRAPPING.  TRAPPING should be
@@ -441,15 +440,15 @@ static int ptrace_attach(struct task_struct *task, long request,
 	if (task->ptrace)
 		goto unlock_tasklist;
 
+	spin_lock(&task->sighand->siglock);
 	task->ptrace = flags;
 
 	ptrace_link(task, current);
 
 	/* SEIZE doesn't trap tracee on attach */
 	if (!seize)
-		send_sig_info(SIGSTOP, SEND_SIG_PRIV, task);
+		send_signal_locked(SIGSTOP, SEND_SIG_PRIV, task, PIDTYPE_PID);
 
-	spin_lock(&task->sighand->siglock);
 
 	/*
 	 * If the task is already STOPPED, set JOBCTL_TRAP_STOP and
@@ -517,8 +516,10 @@ static int ptrace_traceme(void)
 		 * pretend ->real_parent untraces us right after return.
 		 */
 		if (!ret && !(current->real_parent->flags & PF_EXITING)) {
+			spin_lock(&current->sighand->siglock);
 			current->ptrace = PT_PTRACED;
 			ptrace_link(current, current->real_parent);
+			spin_unlock(&current->sighand->siglock);
 		}
 	}
 	write_unlock_irq(&tasklist_lock);
-- 
2.35.3
