From: David Howells <dhowells@redhat.com>
Date: Mon, 10 Apr 2017 12:16:06 +0000
Subject: [RFC PATCH 2/5] Unroll INIT_TASK() in init/init_task.c
Message-Id: <149182656593.9959.9020166815247878895.stgit@warthog.procyon.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <149182655182.9959.4421578108754243877.stgit@warthog.procyon.org.uk>
In-Reply-To: <149182655182.9959.4421578108754243877.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org
Cc: dhowells@redhat.com, linux-kernel@vger.kernel.org

It's no longer necessary to have an INIT_TASK() macro, and this can be
unrolled into the one place it is now used.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/linux/init_task.h |   85 ++-------------------------------------------
 init/init_task.c          |   83 +++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 85 insertions(+), 83 deletions(-)

diff --git a/include/linux/init_task.h b/include/linux/init_task.h
index e889d338cf3e..7e41bc6a19af 100644
--- a/include/linux/init_task.h
+++ b/include/linux/init_task.h
@@ -210,89 +210,12 @@ extern struct cred init_cred;
 # define INIT_TASK_TI(tsk)
 #endif
 
-/*
- *  INIT_TASK is used to set up the first task table, touch at
- * your own risk!. Base=0, limit=0x1fffff (=2MB)
- */
-#define INIT_TASK(tsk)	\
-{									\
-	INIT_TASK_TI(tsk)						\
-	.state		= 0,						\
-	.stack		= init_stack,					\
-	.usage		= ATOMIC_INIT(2),				\
-	.flags		= PF_KTHREAD,					\
-	.prio		= MAX_PRIO-20,					\
-	.static_prio	= MAX_PRIO-20,					\
-	.normal_prio	= MAX_PRIO-20,					\
-	.policy		= SCHED_NORMAL,					\
-	.cpus_allowed	= CPU_MASK_ALL,					\
-	.nr_cpus_allowed= NR_CPUS,					\
-	.mm		= NULL,						\
-	.active_mm	= &init_mm,					\
-	.restart_block = {						\
-		.fn = do_no_restart_syscall,				\
-	},								\
-	.se		= {						\
-		.group_node 	= LIST_HEAD_INIT(tsk.se.group_node),	\
-	},								\
-	.rt		= {						\
-		.run_list	= LIST_HEAD_INIT(tsk.rt.run_list),	\
-		.time_slice	= RR_TIMESLICE,				\
-	},								\
-	.tasks		= LIST_HEAD_INIT(tsk.tasks),			\
-	INIT_PUSHABLE_TASKS(tsk)					\
-	INIT_CGROUP_SCHED(tsk)						\
-	.ptraced	= LIST_HEAD_INIT(tsk.ptraced),			\
-	.ptrace_entry	= LIST_HEAD_INIT(tsk.ptrace_entry),		\
-	.real_parent	= &tsk,						\
-	.parent		= &tsk,						\
-	.children	= LIST_HEAD_INIT(tsk.children),			\
-	.sibling	= LIST_HEAD_INIT(tsk.sibling),			\
-	.group_leader	= &tsk,						\
-	RCU_POINTER_INITIALIZER(real_cred, &init_cred),			\
-	RCU_POINTER_INITIALIZER(cred, &init_cred),			\
-	.comm		= INIT_TASK_COMM,				\
-	.thread		= INIT_THREAD,					\
-	.fs		= &init_fs,					\
-	.files		= &init_files,					\
-	.signal		= &init_signals,				\
-	.sighand	= &init_sighand,				\
-	.nsproxy	= &init_nsproxy,				\
-	.pending	= {						\
-		.list = LIST_HEAD_INIT(tsk.pending.list),		\
-		.signal = {{0}}},					\
-	.blocked	= {{0}},					\
-	.alloc_lock	= __SPIN_LOCK_UNLOCKED(tsk.alloc_lock),		\
-	.journal_info	= NULL,						\
-	INIT_CPU_TIMERS(tsk)						\
-	.pi_lock	= __RAW_SPIN_LOCK_UNLOCKED(tsk.pi_lock),	\
-	.timer_slack_ns = 50000, /* 50 usec default slack */		\
-	.pids = {							\
-		[PIDTYPE_PID]  = INIT_PID_LINK(PIDTYPE_PID),		\
-		[PIDTYPE_PGID] = INIT_PID_LINK(PIDTYPE_PGID),		\
-		[PIDTYPE_SID]  = INIT_PID_LINK(PIDTYPE_SID),		\
-	},								\
-	.thread_group	= LIST_HEAD_INIT(tsk.thread_group),		\
-	.thread_node	= LIST_HEAD_INIT(init_signals.thread_head),	\
-	INIT_IDS							\
-	INIT_PERF_EVENTS(tsk)						\
-	INIT_TRACE_IRQFLAGS						\
-	INIT_LOCKDEP							\
-	INIT_FTRACE_GRAPH						\
-	INIT_TRACE_RECURSION						\
-	INIT_TASK_RCU_PREEMPT(tsk)					\
-	INIT_TASK_RCU_TASKS(tsk)					\
-	INIT_CPUSET_SEQ(tsk)						\
-	INIT_RT_MUTEXES(tsk)						\
-	INIT_PREV_CPUTIME(tsk)						\
-	INIT_VTIME(tsk)							\
-	INIT_NUMA_BALANCING(tsk)					\
-	INIT_KASAN(tsk)							\
-}
-
-
 /* Attach to the init_task data structure for proper alignment */
+#ifdef CONFIG_ARCH_TASK_STRUCT_ON_STACK
 #define __init_task_data __attribute__((__section__(".data..init_task")))
+#else
+#define __init_task_data /**/
+#endif
 
 /* Attach to the thread_info data structure for proper alignment */
 #define __init_thread_info __attribute__((__section__(".data..init_thread_info")))
diff --git a/init/init_task.c b/init/init_task.c
index 14770aa71634..7a8bc40f13fc 100644
--- a/init/init_task.c
+++ b/init/init_task.c
@@ -15,12 +15,91 @@
 static struct signal_struct init_signals = INIT_SIGNALS(init_signals);
 static struct sighand_struct init_sighand = INIT_SIGHAND(init_sighand);
 
-/* Initial task structure */
+
+/*
+ * Set up the first task table, touch at your own risk!. Base=0,
+ * limit=0x1fffff (=2MB)
+ */
 struct task_struct init_task
 #ifdef CONFIG_ARCH_TASK_STRUCT_ON_STACK
 	__init_task_data
 #endif
-	= INIT_TASK(init_task);
+= {
+	INIT_TASK_TI(init_task)
+	.state		= 0,
+	.stack		= init_stack,
+	.usage		= ATOMIC_INIT(2),
+	.flags		= PF_KTHREAD,
+	.prio		= MAX_PRIO-20,
+	.static_prio	= MAX_PRIO-20,
+	.normal_prio	= MAX_PRIO-20,
+	.policy		= SCHED_NORMAL,
+	.cpus_allowed	= CPU_MASK_ALL,
+	.nr_cpus_allowed= NR_CPUS,
+	.mm		= NULL,
+	.active_mm	= &init_mm,
+	.restart_block = {
+		.fn = do_no_restart_syscall,
+	},
+	.se		= {
+		.group_node 	= LIST_HEAD_INIT(init_task.se.group_node),
+	},
+	.rt		= {
+		.run_list	= LIST_HEAD_INIT(init_task.rt.run_list),
+		.time_slice	= RR_TIMESLICE,
+	},
+	.tasks		= LIST_HEAD_INIT(init_task.tasks),
+	INIT_PUSHABLE_TASKS(init_task)
+	INIT_CGROUP_SCHED(init_task)
+	.ptraced	= LIST_HEAD_INIT(init_task.ptraced),
+	.ptrace_entry	= LIST_HEAD_INIT(init_task.ptrace_entry),
+	.real_parent	= &init_task,
+	.parent		= &init_task,
+	.children	= LIST_HEAD_INIT(init_task.children),
+	.sibling	= LIST_HEAD_INIT(init_task.sibling),
+	.group_leader	= &init_task,
+	RCU_POINTER_INITIALIZER(real_cred, &init_cred),
+	RCU_POINTER_INITIALIZER(cred, &init_cred),
+	.comm		= INIT_TASK_COMM,
+	.thread		= INIT_THREAD,
+	.fs		= &init_fs,
+	.files		= &init_files,
+	.signal		= &init_signals,
+	.sighand	= &init_sighand,
+	.nsproxy	= &init_nsproxy,
+	.pending	= {
+		.list = LIST_HEAD_INIT(init_task.pending.list),
+		.signal = {{0}}
+	},
+	.blocked	= {{0}},
+	.alloc_lock	= __SPIN_LOCK_UNLOCKED(init_task.alloc_lock),
+	.journal_info	= NULL,
+	INIT_CPU_TIMERS(init_task)
+	.pi_lock	= __RAW_SPIN_LOCK_UNLOCKED(init_task.pi_lock),
+	.timer_slack_ns = 50000, /* 50 usec default slack */
+	.pids = {
+		[PIDTYPE_PID]  = INIT_PID_LINK(PIDTYPE_PID),
+		[PIDTYPE_PGID] = INIT_PID_LINK(PIDTYPE_PGID),
+		[PIDTYPE_SID]  = INIT_PID_LINK(PIDTYPE_SID),
+	},
+	.thread_group	= LIST_HEAD_INIT(init_task.thread_group),
+	.thread_node	= LIST_HEAD_INIT(init_signals.thread_head),
+	INIT_IDS
+	INIT_PERF_EVENTS(init_task)
+	INIT_TRACE_IRQFLAGS
+	INIT_LOCKDEP
+	INIT_FTRACE_GRAPH
+	INIT_TRACE_RECURSION
+	INIT_TASK_RCU_PREEMPT(init_task)
+	INIT_TASK_RCU_TASKS(init_task)
+	INIT_CPUSET_SEQ(init_task)
+	INIT_RT_MUTEXES(init_task)
+	INIT_PREV_CPUTIME(init_task)
+	INIT_VTIME(init_task)
+	INIT_NUMA_BALANCING(init_task)
+	INIT_KASAN(init_task)
+};
+
 EXPORT_SYMBOL(init_task);
 
 /*

