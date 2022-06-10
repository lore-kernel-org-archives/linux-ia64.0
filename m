From: Pavel Tikhomirov <ptikhomirov@virtuozzo.com>
Date: Fri, 10 Jun 2022 16:32:13 +0000
Subject: [PATCH 1/2] Add CABA tree to task_struct
Message-Id: <20220610163214.49974-2-ptikhomirov@virtuozzo.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220610163214.49974-1-ptikhomirov@virtuozzo.com>
In-Reply-To: <20220610163214.49974-1-ptikhomirov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Pavel Tikhomirov <ptikhomirov@virtuozzo.com>, Eric Biederman <ebiederm@xmission.com>, Kees Cook <keescook@chromium.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Juri Lelli <juri.lelli@redhat.com>, Vincent Guittot <vincent.guittot@linaro.org>, Dietmar Eggemann <dietmar.eggemann@arm.com>, Steven Rostedt <rostedt@goodmis.org>, Ben Segall <bsegall@google.com>, Mel Gorman <mgorman@suse.de>, Daniel Bristot de Oliveira <bristot@redhat.com>, Valentin Schneider <vschneid@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-ia64@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

In linux after parent (father) process dies, children processes are
moved (reparented) to a reaper process. Roughly speaking:

1) If father has other yet alive thread, this thread would be a reaper.

2) Else if there is father's ancestor (with no pidns level change in the
middle), which has PR_SET_CHILD_SUBREAPER set, this ancestor would be a
reaper.

3) Else father's pidns init would be a reaper for fathers children.

The problem with this for CRIU is that when CRIU comes to dump processes
it does not know the order in which processes and their resources were
created. And processes can have resources which a) can only be inherited
when we clone processes, b) can only be created by specific processes
and c) are shared between several processes (the example of such a
resource is process session). For such resources CRIU restore would need
to re-invent such order of process creation which at the same time
creates the desired process tree topology and allows to inherit all
resources right.

When process reparenting involves child-sub-reapers one can drastically
mix processes in process tree so that it is not obvious how to restore
everything right.

So this is what we came up with to help CRIU to overcome this problem:

CABA = Closest Alive Born Ancestor
CABD = Closest Alive Born Descendant

We want to put processes in one more tree - CABA tree. This tree is not
affecting reparenting or process creation in any way except for
providing a new information to CRIU so that it can understand from where
the reparented child had reparented, though original father is already
dead and probably a fathers father too, we can still have information
about the process which is still alive and was originally a parent of
process sequence (of already dead processes) which lead to us - CABA.

CC: Eric Biederman <ebiederm@xmission.com>
CC: Kees Cook <keescook@chromium.org>
CC: Alexander Viro <viro@zeniv.linux.org.uk>
CC: Ingo Molnar <mingo@redhat.com>
CC: Peter Zijlstra <peterz@infradead.org>
CC: Juri Lelli <juri.lelli@redhat.com>
CC: Vincent Guittot <vincent.guittot@linaro.org>
CC: Dietmar Eggemann <dietmar.eggemann@arm.com>
CC: Steven Rostedt <rostedt@goodmis.org>
CC: Ben Segall <bsegall@google.com>
CC: Mel Gorman <mgorman@suse.de>
CC: Daniel Bristot de Oliveira <bristot@redhat.com>
CC: Valentin Schneider <vschneid@redhat.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: linux-ia64@vger.kernel.org
CC: linux-kernel@vger.kernel.org
CC: linux-mm@kvack.org
CC: linux-fsdevel@vger.kernel.org

Signed-off-by: Pavel Tikhomirov <ptikhomirov@virtuozzo.com>
---
 arch/ia64/kernel/mca.c |  3 +++
 fs/exec.c              |  1 +
 fs/proc/array.c        | 18 +++++++++++++++
 include/linux/sched.h  |  7 ++++++
 init/init_task.c       |  3 +++
 kernel/exit.c          | 50 +++++++++++++++++++++++++++++++++++++-----
 kernel/fork.c          |  4 ++++
 7 files changed, 80 insertions(+), 6 deletions(-)

diff --git a/arch/ia64/kernel/mca.c b/arch/ia64/kernel/mca.c
index c62a66710ad6..74bf75fef9df 100644
--- a/arch/ia64/kernel/mca.c
+++ b/arch/ia64/kernel/mca.c
@@ -1793,6 +1793,9 @@ format_mca_init_stack(void *mca_data, unsigned long offset,
 	p->parent = p->real_parent = p->group_leader = p;
 	INIT_LIST_HEAD(&p->children);
 	INIT_LIST_HEAD(&p->sibling);
+	p->caba = p->real_parent;
+	INIT_LIST_HEAD(&p->cabds);
+	INIT_LIST_HEAD(&p->cabd);
 	strncpy(p->comm, type, sizeof(p->comm)-1);
 }
 
diff --git a/fs/exec.c b/fs/exec.c
index 0989fb8472a1..23e48db6c5b1 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -1136,6 +1136,7 @@ static int de_thread(struct task_struct *tsk)
 
 		list_replace_rcu(&leader->tasks, &tsk->tasks);
 		list_replace_init(&leader->sibling, &tsk->sibling);
+		list_replace_init(&leader->cabd, &tsk->cabd);
 
 		tsk->group_leader = tsk;
 		leader->group_leader = tsk;
diff --git a/fs/proc/array.c b/fs/proc/array.c
index eb815759842c..6c43a8d64f65 100644
--- a/fs/proc/array.c
+++ b/fs/proc/array.c
@@ -151,11 +151,26 @@ static inline void task_state(struct seq_file *m, struct pid_namespace *ns,
 	const struct cred *cred;
 	pid_t ppid, tpid = 0, tgid, ngid;
 	unsigned int max_fds = 0;
+	struct task_struct *caba;
+	struct pid *caba_pid;
+	int caba_level = 0;
+	pid_t caba_pids[MAX_PID_NS_LEVEL] = {};
 
 	rcu_read_lock();
 	ppid = pid_alive(p) ?
 		task_tgid_nr_ns(rcu_dereference(p->real_parent), ns) : 0;
 
+#ifdef CONFIG_PID_NS
+	caba = rcu_dereference(p->caba);
+	caba_pid = get_task_pid(caba, PIDTYPE_PID);
+	if (caba_pid) {
+		caba_level = caba_pid->level;
+		for (g = ns->level; g <= caba_level; g++)
+			caba_pids[g] = task_pid_nr_ns(caba, caba_pid->numbers[g].ns);
+		put_pid(caba_pid);
+	}
+#endif
+
 	tracer = ptrace_parent(p);
 	if (tracer)
 		tpid = task_pid_nr_ns(tracer, ns);
@@ -214,6 +229,9 @@ static inline void task_state(struct seq_file *m, struct pid_namespace *ns,
 	seq_puts(m, "\nNSsid:");
 	for (g = ns->level; g <= pid->level; g++)
 		seq_put_decimal_ull(m, "\t", task_session_nr_ns(p, pid->numbers[g].ns));
+	seq_puts(m, "\nNScaba:");
+	for (g = ns->level; g <= caba_level; g++)
+		seq_put_decimal_ull(m, "\t", caba_pids[g]);
 #endif
 	seq_putc(m, '\n');
 }
diff --git a/include/linux/sched.h b/include/linux/sched.h
index c46f3a63b758..358af0cf8f73 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -973,6 +973,13 @@ struct task_struct {
 	struct list_head		sibling;
 	struct task_struct		*group_leader;
 
+	/* Closest Alive Born Ancestor process: */
+	struct task_struct __rcu	*caba;
+
+	/* Closest Alive Born Descendants list: */
+	struct list_head		cabds;
+	struct list_head		cabd;
+
 	/*
 	 * 'ptraced' is the list of tasks this task is using ptrace() on.
 	 *
diff --git a/init/init_task.c b/init/init_task.c
index 73cc8f03511a..a0b206dd74ef 100644
--- a/init/init_task.c
+++ b/init/init_task.c
@@ -109,6 +109,9 @@ struct task_struct init_task
 	.children	= LIST_HEAD_INIT(init_task.children),
 	.sibling	= LIST_HEAD_INIT(init_task.sibling),
 	.group_leader	= &init_task,
+	.caba		= &init_task,
+	.cabds		= LIST_HEAD_INIT(init_task.cabds),
+	.cabd		= LIST_HEAD_INIT(init_task.cabd),
 	RCU_POINTER_INITIALIZER(real_cred, &init_cred),
 	RCU_POINTER_INITIALIZER(cred, &init_cred),
 	.comm		= INIT_TASK_COMM,
diff --git a/kernel/exit.c b/kernel/exit.c
index f072959fcab7..5eae2ff93576 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -82,6 +82,7 @@ static void __unhash_process(struct task_struct *p, bool group_dead)
 
 		list_del_rcu(&p->tasks);
 		list_del_init(&p->sibling);
+		list_del_init(&p->cabd);
 		__this_cpu_dec(process_counts);
 	}
 	list_del_rcu(&p->thread_group);
@@ -562,11 +563,11 @@ static struct task_struct *find_child_reaper(struct task_struct *father,
  * 3. give it to the init process (PID 1) in our pid namespace
  */
 static struct task_struct *find_new_reaper(struct task_struct *father,
-					   struct task_struct *child_reaper)
+					   struct task_struct *child_reaper,
+					   struct task_struct *thread)
 {
-	struct task_struct *thread, *reaper;
+	struct task_struct *reaper;
 
-	thread = find_alive_thread(father);
 	if (thread)
 		return thread;
 
@@ -620,6 +621,31 @@ static void reparent_leader(struct task_struct *father, struct task_struct *p,
 	kill_orphaned_pgrp(p, father);
 }
 
+static struct task_struct *find_new_caba(struct task_struct *father,
+					 struct task_struct *thread)
+{
+	struct task_struct *caba;
+
+	if (thread)
+		return thread;
+
+	caba = father->caba;
+	while (1) {
+		if (caba = &init_task)
+			break;
+		if (WARN_ON_ONCE(caba->caba = caba))
+			break;
+
+		thread = find_alive_thread(caba);
+		if (thread)
+			return thread;
+
+		caba = caba->caba;
+	}
+
+	return caba;
+}
+
 /*
  * This does two things:
  *
@@ -631,17 +657,19 @@ static void reparent_leader(struct task_struct *father, struct task_struct *p,
 static void forget_original_parent(struct task_struct *father,
 					struct list_head *dead)
 {
-	struct task_struct *p, *t, *reaper;
+	struct task_struct *p, *t, *reaper, *thread, *caba;
 
 	if (unlikely(!list_empty(&father->ptraced)))
 		exit_ptrace(father, dead);
 
 	/* Can drop and reacquire tasklist_lock */
 	reaper = find_child_reaper(father, dead);
+	thread = find_alive_thread(father);
+
 	if (list_empty(&father->children))
-		return;
+		goto caba;
 
-	reaper = find_new_reaper(father, reaper);
+	reaper = find_new_reaper(father, reaper, thread);
 	list_for_each_entry(p, &father->children, sibling) {
 		for_each_thread(p, t) {
 			RCU_INIT_POINTER(t->real_parent, reaper);
@@ -661,6 +689,16 @@ static void forget_original_parent(struct task_struct *father,
 			reparent_leader(father, p, dead);
 	}
 	list_splice_tail_init(&father->children, &reaper->children);
+caba:
+	if (list_empty(&father->cabds))
+		return;
+
+	caba = find_new_caba(father, thread);
+	list_for_each_entry(p, &father->cabds, cabd) {
+		for_each_thread(p, t)
+			RCU_INIT_POINTER(t->caba, caba);
+	}
+	list_splice_tail_init(&father->cabds, &caba->cabds);
 }
 
 /*
diff --git a/kernel/fork.c b/kernel/fork.c
index 9d44f2d46c69..e397122721ff 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -2123,6 +2123,8 @@ static __latent_entropy struct task_struct *copy_process(
 	p->flags |= PF_FORKNOEXEC;
 	INIT_LIST_HEAD(&p->children);
 	INIT_LIST_HEAD(&p->sibling);
+	INIT_LIST_HEAD(&p->cabds);
+	INIT_LIST_HEAD(&p->cabd);
 	rcu_copy_process(p);
 	p->vfork_done = NULL;
 	spin_lock_init(&p->alloc_lock);
@@ -2386,6 +2388,7 @@ static __latent_entropy struct task_struct *copy_process(
 		p->parent_exec_id = current->self_exec_id;
 		p->exit_signal = args->exit_signal;
 	}
+	p->caba = p->real_parent;
 
 	klp_copy_process(p);
 
@@ -2437,6 +2440,7 @@ static __latent_entropy struct task_struct *copy_process(
 			p->signal->has_child_subreaper = p->real_parent->signal->has_child_subreaper ||
 							 p->real_parent->signal->is_child_subreaper;
 			list_add_tail(&p->sibling, &p->real_parent->children);
+			list_add_tail(&p->cabd, &p->caba->cabds);
 			list_add_tail_rcu(&p->tasks, &init_task.tasks);
 			attach_pid(p, PIDTYPE_TGID);
 			attach_pid(p, PIDTYPE_PGID);
-- 
2.35.3
