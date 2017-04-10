From: David Howells <dhowells@redhat.com>
Date: Mon, 10 Apr 2017 12:16:12 +0000
Subject: [RFC PATCH 3/5] Unroll various INIT_* macros
Message-Id: <149182657277.9959.8014092636211052221.stgit@warthog.procyon.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <149182655182.9959.4421578108754243877.stgit@warthog.procyon.org.uk>
In-Reply-To: <149182655182.9959.4421578108754243877.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org
Cc: dhowells@redhat.com, linux-kernel@vger.kernel.org

Unroll various INIT_* macros into the single places they're used in
init/init_task.c.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/linux/init_task.h |  101 ---------------------------------------------
 init/init_task.c          |   75 +++++++++++++++++++++++++--------
 2 files changed, 56 insertions(+), 120 deletions(-)

diff --git a/include/linux/init_task.h b/include/linux/init_task.h
index 7e41bc6a19af..e7d46a7e1583 100644
--- a/include/linux/init_task.h
+++ b/include/linux/init_task.h
@@ -19,23 +19,9 @@
 
 #include <asm/thread_info.h>
 
-#ifdef CONFIG_SMP
-# define INIT_PUSHABLE_TASKS(tsk)					\
-	.pushable_tasks = PLIST_NODE_INIT(tsk.pushable_tasks, MAX_PRIO),
-#else
-# define INIT_PUSHABLE_TASKS(tsk)
-#endif
-
 extern struct files_struct init_files;
 extern struct fs_struct init_fs;
 
-#ifdef CONFIG_CPUSETS
-#define INIT_CPUSET_SEQ(tsk)							\
-	.mems_allowed_seq = SEQCNT_ZERO(tsk.mems_allowed_seq),
-#else
-#define INIT_CPUSET_SEQ(tsk)
-#endif
-
 #ifndef CONFIG_VIRT_CPU_ACCOUNTING_NATIVE
 #define INIT_PREV_CPUTIME(x)	.prev_cputime = {			\
 	.lock = __RAW_SPIN_LOCK_UNLOCKED(x.prev_cputime.lock),		\
@@ -116,99 +102,12 @@ extern struct group_info init_groups;
 	.pid = &init_struct_pid,				\
 }
 
-#ifdef CONFIG_AUDITSYSCALL
-#define INIT_IDS \
-	.loginuid = INVALID_UID, \
-	.sessionid = (unsigned int)-1,
-#else
-#define INIT_IDS
-#endif
 
-#ifdef CONFIG_PREEMPT_RCU
-#define INIT_TASK_RCU_TREE_PREEMPT()					\
-	.rcu_blocked_node = NULL,
-#else
-#define INIT_TASK_RCU_TREE_PREEMPT(tsk)
-#endif
-#ifdef CONFIG_PREEMPT_RCU
-#define INIT_TASK_RCU_PREEMPT(tsk)					\
-	.rcu_read_lock_nesting = 0,					\
-	.rcu_read_unlock_special.s = 0,					\
-	.rcu_node_entry = LIST_HEAD_INIT(tsk.rcu_node_entry),		\
-	INIT_TASK_RCU_TREE_PREEMPT()
-#else
-#define INIT_TASK_RCU_PREEMPT(tsk)
-#endif
-#ifdef CONFIG_TASKS_RCU
-#define INIT_TASK_RCU_TASKS(tsk)					\
-	.rcu_tasks_holdout = false,					\
-	.rcu_tasks_holdout_list =					\
-		LIST_HEAD_INIT(tsk.rcu_tasks_holdout_list),		\
-	.rcu_tasks_idle_cpu = -1,
-#else
-#define INIT_TASK_RCU_TASKS(tsk)
-#endif
 
 extern struct cred init_cred;
 
-#ifdef CONFIG_CGROUP_SCHED
-# define INIT_CGROUP_SCHED(tsk)						\
-	.sched_task_group = &root_task_group,
-#else
-# define INIT_CGROUP_SCHED(tsk)
-#endif
-
-#ifdef CONFIG_PERF_EVENTS
-# define INIT_PERF_EVENTS(tsk)						\
-	.perf_event_mutex = 						\
-		 __MUTEX_INITIALIZER(tsk.perf_event_mutex),		\
-	.perf_event_list = LIST_HEAD_INIT(tsk.perf_event_list),
-#else
-# define INIT_PERF_EVENTS(tsk)
-#endif
-
-#ifdef CONFIG_VIRT_CPU_ACCOUNTING_GEN
-# define INIT_VTIME(tsk)						\
-	.vtime_seqcount = SEQCNT_ZERO(tsk.vtime_seqcount),	\
-	.vtime_snap = 0,				\
-	.vtime_snap_whence = VTIME_SYS,
-#else
-# define INIT_VTIME(tsk)
-#endif
-
 #define INIT_TASK_COMM "swapper"
 
-#ifdef CONFIG_RT_MUTEXES
-# define INIT_RT_MUTEXES(tsk)						\
-	.pi_waiters = RB_ROOT,						\
-	.pi_waiters_leftmost = NULL,
-#else
-# define INIT_RT_MUTEXES(tsk)
-#endif
-
-#ifdef CONFIG_NUMA_BALANCING
-# define INIT_NUMA_BALANCING(tsk)					\
-	.numa_preferred_nid = -1,					\
-	.numa_group = NULL,						\
-	.numa_faults = NULL,
-#else
-# define INIT_NUMA_BALANCING(tsk)
-#endif
-
-#ifdef CONFIG_KASAN
-# define INIT_KASAN(tsk)						\
-	.kasan_depth = 1,
-#else
-# define INIT_KASAN(tsk)
-#endif
-
-#ifdef CONFIG_THREAD_INFO_IN_TASK
-# define INIT_TASK_TI(tsk)			\
-	.thread_info = INIT_THREAD_INFO(tsk),	\
-	.stack_refcount = ATOMIC_INIT(1),
-#else
-# define INIT_TASK_TI(tsk)
-#endif
 
 /* Attach to the init_task data structure for proper alignment */
 #ifdef CONFIG_ARCH_TASK_STRUCT_ON_STACK
diff --git a/init/init_task.c b/init/init_task.c
index 7a8bc40f13fc..b51c49f580ca 100644
--- a/init/init_task.c
+++ b/init/init_task.c
@@ -15,7 +15,6 @@
 static struct signal_struct init_signals = INIT_SIGNALS(init_signals);
 static struct sighand_struct init_sighand = INIT_SIGHAND(init_sighand);
 
-
 /*
  * Set up the first task table, touch at your own risk!. Base=0,
  * limit=0x1fffff (=2MB)
@@ -25,20 +24,23 @@ struct task_struct init_task
 	__init_task_data
 #endif
 = {
-	INIT_TASK_TI(init_task)
+#ifdef CONFIG_THREAD_INFO_IN_TASK
+	.thread_info	= INIT_THREAD_INFO(init_task),
+	.stack_refcount	= ATOMIC_INIT(1),
+#endif
 	.state		= 0,
 	.stack		= init_stack,
 	.usage		= ATOMIC_INIT(2),
 	.flags		= PF_KTHREAD,
-	.prio		= MAX_PRIO-20,
-	.static_prio	= MAX_PRIO-20,
-	.normal_prio	= MAX_PRIO-20,
+	.prio		= MAX_PRIO - 20,
+	.static_prio	= MAX_PRIO - 20,
+	.normal_prio	= MAX_PRIO - 20,
 	.policy		= SCHED_NORMAL,
 	.cpus_allowed	= CPU_MASK_ALL,
 	.nr_cpus_allowed= NR_CPUS,
 	.mm		= NULL,
 	.active_mm	= &init_mm,
-	.restart_block = {
+	.restart_block	= {
 		.fn = do_no_restart_syscall,
 	},
 	.se		= {
@@ -49,8 +51,12 @@ struct task_struct init_task
 		.time_slice	= RR_TIMESLICE,
 	},
 	.tasks		= LIST_HEAD_INIT(init_task.tasks),
-	INIT_PUSHABLE_TASKS(init_task)
-	INIT_CGROUP_SCHED(init_task)
+#ifdef CONFIG_SMP
+	.pushable_tasks	= PLIST_NODE_INIT(init_task.pushable_tasks, MAX_PRIO),
+#endif
+#ifdef CONFIG_CGROUP_SCHED
+	.sched_task_group = &root_task_group,
+#endif
 	.ptraced	= LIST_HEAD_INIT(init_task.ptraced),
 	.ptrace_entry	= LIST_HEAD_INIT(init_task.ptrace_entry),
 	.real_parent	= &init_task,
@@ -84,22 +90,53 @@ struct task_struct init_task
 	},
 	.thread_group	= LIST_HEAD_INIT(init_task.thread_group),
 	.thread_node	= LIST_HEAD_INIT(init_signals.thread_head),
-	INIT_IDS
-	INIT_PERF_EVENTS(init_task)
+#ifdef CONFIG_AUDITSYSCALL
+	.loginuid	= INVALID_UID,
+	.sessionid	= (unsigned int)-1,
+#endif
+#ifdef CONFIG_PERF_EVENTS
+	.perf_event_mutex = __MUTEX_INITIALIZER(init_task.perf_event_mutex),
+	.perf_event_list = LIST_HEAD_INIT(init_task.perf_event_list),
+#endif
+#ifdef CONFIG_PREEMPT_RCU
+	.rcu_read_lock_nesting = 0,
+	.rcu_read_unlock_special.s = 0,
+	.rcu_node_entry = LIST_HEAD_INIT(init_task.rcu_node_entry),
+#ifdef CONFIG_PREEMPT_RCU
+	.rcu_blocked_node = NULL,
+#endif
+#endif
+#ifdef CONFIG_TASKS_RCU
+	.rcu_tasks_holdout = false,
+	.rcu_tasks_holdout_list = LIST_HEAD_INIT(init_task.rcu_tasks_holdout_list),
+	.rcu_tasks_idle_cpu = -1,
+#endif
+#ifdef CONFIG_CPUSETS
+	.mems_allowed_seq = SEQCNT_ZERO(init_task.mems_allowed_seq),
+#endif
+#ifdef CONFIG_RT_MUTEXES
+	.pi_waiters	= RB_ROOT,
+	.pi_waiters_leftmost = NULL,
+#endif
+	INIT_PREV_CPUTIME(init_task)
+#ifdef CONFIG_VIRT_CPU_ACCOUNTING_GEN
+	.vtime_seqcount	= SEQCNT_ZERO(init_task.vtime_seqcount),
+	.vtime_snap	= 0,
+	.vtime_snap_whence = VTIME_SYS,
+#endif
+#ifdef CONFIG_NUMA_BALANCING
+	.numa_preferred_nid = -1,
+	.numa_group	= NULL,
+	.numa_faults	= NULL,
+#endif
+#ifdef CONFIG_KASAN
+	.kasan_depth	= 1,
+#endif
 	INIT_TRACE_IRQFLAGS
 	INIT_LOCKDEP
 	INIT_FTRACE_GRAPH
 	INIT_TRACE_RECURSION
-	INIT_TASK_RCU_PREEMPT(init_task)
-	INIT_TASK_RCU_TASKS(init_task)
-	INIT_CPUSET_SEQ(init_task)
-	INIT_RT_MUTEXES(init_task)
-	INIT_PREV_CPUTIME(init_task)
-	INIT_VTIME(init_task)
-	INIT_NUMA_BALANCING(init_task)
-	INIT_KASAN(init_task)
 };
-
 EXPORT_SYMBOL(init_task);
 
 /*

