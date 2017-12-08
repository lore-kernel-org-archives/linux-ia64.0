From: David Howells <dhowells@redhat.com>
Date: Fri, 08 Dec 2017 15:51:44 +0000
Subject: [PATCH 3/5] Expand various INIT_* macros and remove
Message-Id: <151274830417.9961.12207832666069760085.stgit@warthog.procyon.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <151274828194.9961.4230316917108602662.stgit@warthog.procyon.org.uk>
In-Reply-To: <151274828194.9961.4230316917108602662.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arch@vger.kernel.org, x86@kernel.org, linux-ia64@vger.kernel.org
Cc: dhowells@redhat.com, torvalds@linux-foundation.org, linux-kernel@vger.kernel.org

Expand various INIT_* macros into the single places they're used in
init/init_task.c and remove them.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/linux/ftrace.h    |   12 -----
 include/linux/init_task.h |  112 ---------------------------------------------
 include/linux/irqflags.h  |    2 -
 include/linux/lockdep.h   |    3 -
 init/init_task.c          |   95 +++++++++++++++++++++++++++++---------
 5 files changed, 71 insertions(+), 153 deletions(-)

diff --git a/include/linux/ftrace.h b/include/linux/ftrace.h
index 2bab81951ced..6311f35acbc4 100644
--- a/include/linux/ftrace.h
+++ b/include/linux/ftrace.h
@@ -764,9 +764,6 @@ typedef int (*trace_func_graph_ent_t)(struct ftrace_graph_ent *); /* entry */
 
 #ifdef CONFIG_FUNCTION_GRAPH_TRACER
 
-/* for init task */
-#define INIT_FTRACE_GRAPH		.ret_stack = NULL,
-
 /*
  * Stack of return addresses for functions
  * of a thread.
@@ -844,7 +841,6 @@ static inline void unpause_graph_tracing(void)
 #else /* !CONFIG_FUNCTION_GRAPH_TRACER */
 
 #define __notrace_funcgraph
-#define INIT_FTRACE_GRAPH
 
 static inline void ftrace_graph_init_task(struct task_struct *t) { }
 static inline void ftrace_graph_exit_task(struct task_struct *t) { }
@@ -923,10 +919,6 @@ extern int tracepoint_printk;
 extern void disable_trace_on_warning(void);
 extern int __disable_trace_on_warning;
 
-#ifdef CONFIG_PREEMPT
-#define INIT_TRACE_RECURSION		.trace_recursion = 0,
-#endif
-
 int tracepoint_printk_sysctl(struct ctl_table *table, int write,
 			     void __user *buffer, size_t *lenp,
 			     loff_t *ppos);
@@ -935,10 +927,6 @@ int tracepoint_printk_sysctl(struct ctl_table *table, int write,
 static inline void  disable_trace_on_warning(void) { }
 #endif /* CONFIG_TRACING */
 
-#ifndef INIT_TRACE_RECURSION
-#define INIT_TRACE_RECURSION
-#endif
-
 #ifdef CONFIG_FTRACE_SYSCALLS
 
 unsigned long arch_syscall_addr(int nr);
diff --git a/include/linux/init_task.h b/include/linux/init_task.h
index 9711611b831d..b1385e1dca63 100644
--- a/include/linux/init_task.h
+++ b/include/linux/init_task.h
@@ -21,23 +21,9 @@
 
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
@@ -117,107 +103,10 @@ extern struct group_info init_groups;
 	.pid = &init_struct_pid,				\
 }
 
-#ifdef CONFIG_AUDITSYSCALL
-#define INIT_IDS \
-	.loginuid = INVALID_UID, \
-	.sessionid = (unsigned int)-1,
-#else
-#define INIT_IDS
-#endif
-
-#ifdef CONFIG_PREEMPT_RCU
-#define INIT_TASK_RCU_PREEMPT(tsk)					\
-	.rcu_read_lock_nesting = 0,					\
-	.rcu_read_unlock_special.s = 0,					\
-	.rcu_node_entry = LIST_HEAD_INIT(tsk.rcu_node_entry),		\
-	.rcu_blocked_node = NULL,
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
-
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
-	.vtime.seqcount = SEQCNT_ZERO(tsk.vtime.seqcount),		\
-	.vtime.starttime = 0,						\
-	.vtime.state = VTIME_SYS,
-#else
-# define INIT_VTIME(tsk)
-#endif
-
 #define INIT_TASK_COMM "swapper"
 
-#ifdef CONFIG_RT_MUTEXES
-# define INIT_RT_MUTEXES(tsk)						\
-	.pi_waiters = RB_ROOT_CACHED,					\
-	.pi_top_task = NULL,
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
-#ifdef CONFIG_LIVEPATCH
-# define INIT_LIVEPATCH(tsk)						\
-	.patch_state = KLP_UNDEFINED,
-#else
-# define INIT_LIVEPATCH(tsk)
-#endif
-
-#ifdef CONFIG_THREAD_INFO_IN_TASK
-# define INIT_TASK_TI(tsk)			\
-	.thread_info = INIT_THREAD_INFO(tsk),	\
-	.stack_refcount = ATOMIC_INIT(1),
-#else
-# define INIT_TASK_TI(tsk)
-#endif
-
-#ifdef CONFIG_SECURITY
-#define INIT_TASK_SECURITY .security = NULL,
-#else
-#define INIT_TASK_SECURITY
-#endif
-
 /* Attach to the init_task data structure for proper alignment */
 #ifdef CONFIG_ARCH_TASK_STRUCT_ON_STACK
 #define __init_task_data __attribute__((__section__(".data..init_task")))
@@ -228,5 +117,4 @@ extern struct cred init_cred;
 /* Attach to the thread_info data structure for proper alignment */
 #define __init_thread_info __attribute__((__section__(".data..init_thread_info")))
 
-
 #endif
diff --git a/include/linux/irqflags.h b/include/linux/irqflags.h
index 46cb57d5eb13..2ec81dc1487e 100644
--- a/include/linux/irqflags.h
+++ b/include/linux/irqflags.h
@@ -44,7 +44,6 @@ do {						\
 	current->softirq_context--;		\
 	crossrelease_hist_end(XHLOCK_SOFT);	\
 } while (0)
-# define INIT_TRACE_IRQFLAGS	.softirqs_enabled = 1,
 #else
 # define trace_hardirqs_on()		do { } while (0)
 # define trace_hardirqs_off()		do { } while (0)
@@ -58,7 +57,6 @@ do {						\
 # define trace_hardirq_exit()		do { } while (0)
 # define lockdep_softirq_enter()	do { } while (0)
 # define lockdep_softirq_exit()		do { } while (0)
-# define INIT_TRACE_IRQFLAGS
 #endif
 
 #if defined(CONFIG_IRQSOFF_TRACER) || \
diff --git a/include/linux/lockdep.h b/include/linux/lockdep.h
index a842551fe044..7886bf390812 100644
--- a/include/linux/lockdep.h
+++ b/include/linux/lockdep.h
@@ -460,8 +460,6 @@ extern struct pin_cookie lock_pin_lock(struct lockdep_map *lock);
 extern void lock_repin_lock(struct lockdep_map *lock, struct pin_cookie);
 extern void lock_unpin_lock(struct lockdep_map *lock, struct pin_cookie);
 
-# define INIT_LOCKDEP				.lockdep_recursion = 0,
-
 #define lockdep_depth(tsk)	(debug_locks ? (tsk)->lockdep_depth : 0)
 
 #define lockdep_assert_held(l)	do {				\
@@ -519,7 +517,6 @@ static inline void lockdep_on(void)
  * #ifdef the call himself.
  */
 
-# define INIT_LOCKDEP
 # define lockdep_reset()		do { debug_locks = 1; } while (0)
 # define lockdep_free_key_range(start, size)	do { } while (0)
 # define lockdep_sys_exit() 			do { } while (0)
diff --git a/init/init_task.c b/init/init_task.c
index 7b2436f02dad..aa4030a939e5 100644
--- a/init/init_task.c
+++ b/init/init_task.c
@@ -16,7 +16,6 @@
 static struct signal_struct init_signals = INIT_SIGNALS(init_signals);
 static struct sighand_struct init_sighand = INIT_SIGHAND(init_sighand);
 
-
 /*
  * Set up the first task table, touch at your own risk!. Base=0,
  * limit=0x1fffff (=2MB)
@@ -26,20 +25,23 @@ struct task_struct init_task
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
@@ -50,8 +52,12 @@ struct task_struct init_task
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
@@ -85,24 +91,65 @@ struct task_struct init_task
 	},
 	.thread_group	= LIST_HEAD_INIT(init_task.thread_group),
 	.thread_node	= LIST_HEAD_INIT(init_signals.thread_head),
-	INIT_IDS
-	INIT_PERF_EVENTS(init_task)
-	INIT_TRACE_IRQFLAGS
-	INIT_LOCKDEP
-	INIT_FTRACE_GRAPH
-	INIT_TRACE_RECURSION
-	INIT_TASK_RCU_PREEMPT(init_task)
-	INIT_TASK_RCU_TASKS(init_task)
-	INIT_CPUSET_SEQ(init_task)
-	INIT_RT_MUTEXES(init_task)
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
+	.rcu_blocked_node = NULL,
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
+	.pi_waiters	= RB_ROOT_CACHED,
+	.pi_top_task	= NULL,
+#endif
 	INIT_PREV_CPUTIME(init_task)
-	INIT_VTIME(init_task)
-	INIT_NUMA_BALANCING(init_task)
-	INIT_KASAN(init_task)
-	INIT_LIVEPATCH(init_task)
-	INIT_TASK_SECURITY
+#ifdef CONFIG_VIRT_CPU_ACCOUNTING_GEN
+	.vtime.seqcount	= SEQCNT_ZERO(init_task.vtime_seqcount),
+	.vtime.starttime = 0,
+	.vtime.state	= VTIME_SYS,
+#endif
+#ifdef CONFIG_NUMA_BALANCING
+	.numa_preferred_nid = -1,
+	.numa_group	= NULL,
+	.numa_faults	= NULL,
+#endif
+#ifdef CONFIG_KASAN
+	.kasan_depth	= 1,
+#endif
+#ifdef CONFIG_TRACE_IRQFLAGS
+	.softirqs_enabled = 1,
+#endif
+#ifdef CONFIG_LOCKDEP
+	.lockdep_recursion = 0,
+#endif
+#ifdef CONFIG_FUNCTION_GRAPH_TRACER
+	.ret_stack	= NULL,
+#endif
+#if defined(CONFIG_TRACING) && defined(CONFIG_PREEMPT)
+	.trace_recursion = 0,
+#endif
+#ifdef CONFIG_LIVEPATCH
+	.patch_state	= KLP_UNDEFINED,
+#endif
+#ifdef CONFIG_SECURITY
+	.security	= NULL,
+#endif
 };
-
 EXPORT_SYMBOL(init_task);
 
 /*

