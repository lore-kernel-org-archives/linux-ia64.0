From: Steven Rostedt <rostedt@goodmis.org>
Date: Tue, 13 Jan 2009 06:11:18 +0000
Subject: [PATCH 8/9] tracing: add a new workqueue tracer
Message-Id: <20090113061148.600568109@goodmis.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090113061110.856268617@goodmis.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Frederic Weisbecker <fweisbec@gmail.com>, Shaohua Li <shaohua.li@intel.com>, ia64 <linux-ia64@vger.kernel.org>, Tony Luck <tony.luck@intel.com>, Sam Ravnborg <sam@ravnborg.org>, u.kleine-koenig@pengutronix.de, Steven Rostedt <srostedt@redhat.com>

From: Frederic Weisbecker <fweisbec@gmail.com>

Impact: new tracer

The workqueue tracer provides some statistical informations
about each cpu workqueue thread such as the number of the
works inserted and executed since their creation. It can help
to evaluate the amount of work each of them have to perform.
For example it can help a developer to decide whether he should
choose a per cpu workqueue instead of a singlethreaded one.

It only traces statistical informations for now but it will probably later
provide event tracing too.

Such a tracer could help too, and be improved, to help rt priority sorted
workqueue development.

To have a snapshot of the workqueues state at any time, just do

cat /debugfs/tracing/trace_stat/workqueues

Ie:

  1    125        125       reiserfs/1
  1      0          0       scsi_tgtd/1
  1      0          0       aio/1
  1      0          0       ata/1
  1    114        114       kblockd/1
  1      0          0       kintegrityd/1
  1   2147       2147       events/1

  0      0          0       kpsmoused
  0    105        105       reiserfs/0
  0      0          0       scsi_tgtd/0
  0      0          0       aio/0
  0      0          0       ata_aux
  0      0          0       ata/0
  0      0          0       cqueue
  0      0          0       kacpi_notify
  0      0          0       kacpid
  0    149        149       kblockd/0
  0      0          0       kintegrityd/0
  0   1000       1000       khelper
  0   2270       2270       events/0

Changes in V2:

_ Drop the static array based on NR_CPU and dynamically allocate the stat array
  with num_possible_cpus() and other cpu mask facilities....
_ Trace workqueue insertion at a bit lower level (insert_work instead of queue_work) to handle
  even the workqueue barriers.

Signed-off-by: Frederic Weisbecker <fweisbec@gmail.com>
Signed-off-by: Steven Rostedt <srostedt@redhat.com>
---
 include/trace/workqueue.h      |   25 ++++
 kernel/trace/Kconfig           |   11 ++
 kernel/trace/Makefile          |    1 +
 kernel/trace/trace_workqueue.c |  287 ++++++++++++++++++++++++++++++++++++++++
 kernel/workqueue.c             |   16 ++-
 5 files changed, 339 insertions(+), 1 deletions(-)
 create mode 100644 include/trace/workqueue.h
 create mode 100644 kernel/trace/trace_workqueue.c

diff --git a/include/trace/workqueue.h b/include/trace/workqueue.h
new file mode 100644
index 0000000..867829d
--- /dev/null
+++ b/include/trace/workqueue.h
@@ -0,0 +1,25 @@
+#ifndef __TRACE_WORKQUEUE_H
+#define __TRACE_WORKQUEUE_H
+
+#include <linux/tracepoint.h>
+#include <linux/workqueue.h>
+#include <linux/sched.h>
+
+DECLARE_TRACE(workqueue_insertion,
+	   TPPROTO(struct task_struct *wq_thread, struct work_struct *work),
+	   TPARGS(wq_thread, work));
+
+DECLARE_TRACE(workqueue_execution,
+	   TPPROTO(struct task_struct *wq_thread, struct work_struct *work),
+	   TPARGS(wq_thread, work));
+
+/* Trace the creation of one workqueue thread on a cpu */
+DECLARE_TRACE(workqueue_creation,
+	   TPPROTO(struct task_struct *wq_thread, int cpu),
+	   TPARGS(wq_thread, cpu));
+
+DECLARE_TRACE(workqueue_destruction,
+	   TPPROTO(struct task_struct *wq_thread),
+	   TPARGS(wq_thread));
+
+#endif /* __TRACE_WORKQUEUE_H */
diff --git a/kernel/trace/Kconfig b/kernel/trace/Kconfig
index 9442392..dde1d46 100644
--- a/kernel/trace/Kconfig
+++ b/kernel/trace/Kconfig
@@ -284,6 +284,17 @@ config KMEMTRACE
 
 	  If unsure, say N.
 
+config WORKQUEUE_TRACER
+	bool "Trace workqueues"
+	select TRACING
+	help
+	  The workqueue tracer provides some statistical informations
+          about each cpu workqueue thread such as the number of the
+          works inserted and executed since their creation. It can help
+          to evaluate the amount of work each of them have to perform.
+          For example it can help a developer to decide whether he should
+          choose a per cpu workqueue instead of a singlethreaded one.
+
 
 config DYNAMIC_FTRACE
 	bool "enable/disable ftrace tracepoints dynamically"
diff --git a/kernel/trace/Makefile b/kernel/trace/Makefile
index 05c9182..f76d48f 100644
--- a/kernel/trace/Makefile
+++ b/kernel/trace/Makefile
@@ -36,5 +36,6 @@ obj-$(CONFIG_TRACE_BRANCH_PROFILING) += trace_branch.o
 obj-$(CONFIG_HW_BRANCH_TRACER) += trace_hw_branches.o
 obj-$(CONFIG_POWER_TRACER) += trace_power.o
 obj-$(CONFIG_KMEMTRACE) += kmemtrace.o
+obj-$(CONFIG_WORKQUEUE_TRACER) += trace_workqueue.o
 
 libftrace-y := ftrace.o
diff --git a/kernel/trace/trace_workqueue.c b/kernel/trace/trace_workqueue.c
new file mode 100644
index 0000000..f8118d3
--- /dev/null
+++ b/kernel/trace/trace_workqueue.c
@@ -0,0 +1,287 @@
+/*
+ * Workqueue statistical tracer.
+ *
+ * Copyright (C) 2008 Frederic Weisbecker <fweisbec@gmail.com>
+ *
+ */
+
+
+#include <trace/workqueue.h>
+#include <linux/list.h>
+#include "trace_stat.h"
+#include "trace.h"
+
+
+/* A cpu workqueue thread */
+struct cpu_workqueue_stats {
+	struct list_head            list;
+/* Useful to know if we print the cpu headers */
+	bool		            first_entry;
+	int		            cpu;
+	pid_t 			    pid;
+/* Can be inserted from interrupt or user context, need to be atomic */
+	atomic_t 	            inserted;
+/*
+ *  Don't need to be atomic, works are serialized in a single workqueue thread
+ *  on a single CPU.
+ */
+	unsigned int 	 	    executed;
+};
+
+/* List of workqueue threads on one cpu */
+struct workqueue_global_stats {
+	struct list_head	list;
+	spinlock_t		lock;
+};
+
+/* Don't need a global lock because allocated before the workqueues, and
+ * never freed.
+ */
+static struct workqueue_global_stats *all_workqueue_stat;
+
+/* Insertion of a work */
+static void
+probe_workqueue_insertion(struct task_struct *wq_thread,
+			  struct work_struct *work)
+{
+	int cpu = cpumask_first(&wq_thread->cpus_allowed);
+	struct cpu_workqueue_stats *node, *next;
+	unsigned long flags;
+
+	spin_lock_irqsave(&all_workqueue_stat[cpu].lock, flags);
+	list_for_each_entry_safe(node, next, &all_workqueue_stat[cpu].list,
+							list) {
+		if (node->pid = wq_thread->pid) {
+			atomic_inc(&node->inserted);
+			goto found;
+		}
+	}
+	pr_debug("trace_workqueue: entry not found\n");
+found:
+	spin_unlock_irqrestore(&all_workqueue_stat[cpu].lock, flags);
+}
+
+/* Execution of a work */
+static void
+probe_workqueue_execution(struct task_struct *wq_thread,
+			  struct work_struct *work)
+{
+	int cpu = cpumask_first(&wq_thread->cpus_allowed);
+	struct cpu_workqueue_stats *node, *next;
+	unsigned long flags;
+
+	spin_lock_irqsave(&all_workqueue_stat[cpu].lock, flags);
+	list_for_each_entry_safe(node, next, &all_workqueue_stat[cpu].list,
+							list) {
+		if (node->pid = wq_thread->pid) {
+			node->executed++;
+			goto found;
+		}
+	}
+	pr_debug("trace_workqueue: entry not found\n");
+found:
+	spin_unlock_irqrestore(&all_workqueue_stat[cpu].lock, flags);
+}
+
+/* Creation of a cpu workqueue thread */
+static void probe_workqueue_creation(struct task_struct *wq_thread, int cpu)
+{
+	struct cpu_workqueue_stats *cws;
+	unsigned long flags;
+
+	WARN_ON(cpu < 0 || cpu >= num_possible_cpus());
+
+	/* Workqueues are sometimes created in atomic context */
+	cws = kzalloc(sizeof(struct cpu_workqueue_stats), GFP_ATOMIC);
+	if (!cws) {
+		pr_warning("trace_workqueue: not enough memory\n");
+		return;
+	}
+	tracing_record_cmdline(wq_thread);
+
+	INIT_LIST_HEAD(&cws->list);
+	cws->cpu = cpu;
+
+	cws->pid = wq_thread->pid;
+
+	spin_lock_irqsave(&all_workqueue_stat[cpu].lock, flags);
+	if (list_empty(&all_workqueue_stat[cpu].list))
+		cws->first_entry = true;
+	list_add_tail(&cws->list, &all_workqueue_stat[cpu].list);
+	spin_unlock_irqrestore(&all_workqueue_stat[cpu].lock, flags);
+}
+
+/* Destruction of a cpu workqueue thread */
+static void probe_workqueue_destruction(struct task_struct *wq_thread)
+{
+	/* Workqueue only execute on one cpu */
+	int cpu = cpumask_first(&wq_thread->cpus_allowed);
+	struct cpu_workqueue_stats *node, *next;
+	unsigned long flags;
+
+	spin_lock_irqsave(&all_workqueue_stat[cpu].lock, flags);
+	list_for_each_entry_safe(node, next, &all_workqueue_stat[cpu].list,
+							list) {
+		if (node->pid = wq_thread->pid) {
+			list_del(&node->list);
+			kfree(node);
+			goto found;
+		}
+	}
+
+	pr_debug("trace_workqueue: don't find workqueue to destroy\n");
+found:
+	spin_unlock_irqrestore(&all_workqueue_stat[cpu].lock, flags);
+
+}
+
+static struct cpu_workqueue_stats *workqueue_stat_start_cpu(int cpu)
+{
+	unsigned long flags;
+	struct cpu_workqueue_stats *ret = NULL;
+
+
+	spin_lock_irqsave(&all_workqueue_stat[cpu].lock, flags);
+
+	if (!list_empty(&all_workqueue_stat[cpu].list))
+		ret = list_entry(all_workqueue_stat[cpu].list.next,
+				 struct cpu_workqueue_stats, list);
+
+	spin_unlock_irqrestore(&all_workqueue_stat[cpu].lock, flags);
+
+	return ret;
+}
+
+static void *workqueue_stat_start(void)
+{
+	int cpu;
+	void *ret = NULL;
+
+	for_each_possible_cpu(cpu) {
+		ret = workqueue_stat_start_cpu(cpu);
+		if (ret)
+			return ret;
+	}
+	return NULL;
+}
+
+static void *workqueue_stat_next(void *prev, int idx)
+{
+	struct cpu_workqueue_stats *prev_cws = prev;
+	int cpu = prev_cws->cpu;
+	unsigned long flags;
+	void *ret = NULL;
+
+	spin_lock_irqsave(&all_workqueue_stat[cpu].lock, flags);
+	if (list_is_last(&prev_cws->list, &all_workqueue_stat[cpu].list)) {
+		spin_unlock_irqrestore(&all_workqueue_stat[cpu].lock, flags);
+		for (++cpu ; cpu < num_possible_cpus(); cpu++) {
+			ret = workqueue_stat_start_cpu(cpu);
+			if (ret)
+				return ret;
+		}
+		return NULL;
+	}
+	spin_unlock_irqrestore(&all_workqueue_stat[cpu].lock, flags);
+
+	return list_entry(prev_cws->list.next, struct cpu_workqueue_stats,
+			  list);
+}
+
+static int workqueue_stat_show(struct seq_file *s, void *p)
+{
+	struct cpu_workqueue_stats *cws = p;
+	unsigned long flags;
+	int cpu = cws->cpu;
+
+	seq_printf(s, "%3d %6d     %6u       %s\n", cws->cpu,
+		   atomic_read(&cws->inserted),
+		   cws->executed,
+		   trace_find_cmdline(cws->pid));
+
+	spin_lock_irqsave(&all_workqueue_stat[cpu].lock, flags);
+	if (&cws->list = all_workqueue_stat[cpu].list.next)
+		seq_printf(s, "\n");
+	spin_unlock_irqrestore(&all_workqueue_stat[cpu].lock, flags);
+
+	return 0;
+}
+
+static int workqueue_stat_headers(struct seq_file *s)
+{
+	seq_printf(s, "# CPU  INSERTED  EXECUTED   NAME\n");
+	seq_printf(s, "# |      |         |          |\n\n");
+	return 0;
+}
+
+struct tracer_stat workqueue_stats __read_mostly = {
+	.name = "workqueues",
+	.stat_start = workqueue_stat_start,
+	.stat_next = workqueue_stat_next,
+	.stat_show = workqueue_stat_show,
+	.stat_headers = workqueue_stat_headers
+};
+
+
+int __init stat_workqueue_init(void)
+{
+	if (register_stat_tracer(&workqueue_stats)) {
+		pr_warning("Unable to register workqueue stat tracer\n");
+		return 1;
+	}
+
+	return 0;
+}
+fs_initcall(stat_workqueue_init);
+
+/*
+ * Workqueues are created very early, just after pre-smp initcalls.
+ * So we must register our tracepoints at this stage.
+ */
+int __init trace_workqueue_early_init(void)
+{
+	int ret, cpu;
+
+	ret = register_trace_workqueue_insertion(probe_workqueue_insertion);
+	if (ret)
+		goto out;
+
+	ret = register_trace_workqueue_execution(probe_workqueue_execution);
+	if (ret)
+		goto no_insertion;
+
+	ret = register_trace_workqueue_creation(probe_workqueue_creation);
+	if (ret)
+		goto no_execution;
+
+	ret = register_trace_workqueue_destruction(probe_workqueue_destruction);
+	if (ret)
+		goto no_creation;
+
+	all_workqueue_stat = kmalloc(sizeof(struct workqueue_global_stats)
+				     * num_possible_cpus(), GFP_KERNEL);
+
+	if (!all_workqueue_stat) {
+		pr_warning("trace_workqueue: not enough memory\n");
+		goto no_creation;
+	}
+
+	for_each_possible_cpu(cpu) {
+		spin_lock_init(&all_workqueue_stat[cpu].lock);
+		INIT_LIST_HEAD(&all_workqueue_stat[cpu].list);
+	}
+
+	return 0;
+
+no_creation:
+	unregister_trace_workqueue_creation(probe_workqueue_creation);
+no_execution:
+	unregister_trace_workqueue_execution(probe_workqueue_execution);
+no_insertion:
+	unregister_trace_workqueue_insertion(probe_workqueue_insertion);
+out:
+	pr_warning("trace_workqueue: unable to trace workqueues\n");
+
+	return 1;
+}
+early_initcall(trace_workqueue_early_init);
diff --git a/kernel/workqueue.c b/kernel/workqueue.c
index 2f44583..1fc2bc2 100644
--- a/kernel/workqueue.c
+++ b/kernel/workqueue.c
@@ -33,6 +33,7 @@
 #include <linux/kallsyms.h>
 #include <linux/debug_locks.h>
 #include <linux/lockdep.h>
+#include <trace/workqueue.h>
 
 /*
  * The per-CPU workqueue (if single thread, we always use the first
@@ -125,9 +126,13 @@ struct cpu_workqueue_struct *get_wq_data(struct work_struct *work)
 	return (void *) (atomic_long_read(&work->data) & WORK_STRUCT_WQ_DATA_MASK);
 }
 
+DEFINE_TRACE(workqueue_insertion);
+
 static void insert_work(struct cpu_workqueue_struct *cwq,
 			struct work_struct *work, struct list_head *head)
 {
+	trace_workqueue_insertion(cwq->thread, work);
+
 	set_wq_data(work, cwq);
 	/*
 	 * Ensure that we get the right work->data if we see the
@@ -259,6 +264,8 @@ int queue_delayed_work_on(int cpu, struct workqueue_struct *wq,
 }
 EXPORT_SYMBOL_GPL(queue_delayed_work_on);
 
+DEFINE_TRACE(workqueue_execution);
+
 static void run_workqueue(struct cpu_workqueue_struct *cwq)
 {
 	spin_lock_irq(&cwq->lock);
@@ -284,7 +291,7 @@ static void run_workqueue(struct cpu_workqueue_struct *cwq)
 		 */
 		struct lockdep_map lockdep_map = work->lockdep_map;
 #endif
-
+		trace_workqueue_execution(cwq->thread, work);
 		cwq->current_work = work;
 		list_del_init(cwq->worklist.next);
 		spin_unlock_irq(&cwq->lock);
@@ -765,6 +772,8 @@ init_cpu_workqueue(struct workqueue_struct *wq, int cpu)
 	return cwq;
 }
 
+DEFINE_TRACE(workqueue_creation);
+
 static int create_workqueue_thread(struct cpu_workqueue_struct *cwq, int cpu)
 {
 	struct sched_param param = { .sched_priority = MAX_RT_PRIO-1 };
@@ -787,6 +796,8 @@ static int create_workqueue_thread(struct cpu_workqueue_struct *cwq, int cpu)
 		sched_setscheduler_nocheck(p, SCHED_FIFO, &param);
 	cwq->thread = p;
 
+	trace_workqueue_creation(cwq->thread, cpu);
+
 	return 0;
 }
 
@@ -868,6 +879,8 @@ struct workqueue_struct *__create_workqueue_key(const char *name,
 }
 EXPORT_SYMBOL_GPL(__create_workqueue_key);
 
+DEFINE_TRACE(workqueue_destruction);
+
 static void cleanup_workqueue_thread(struct cpu_workqueue_struct *cwq)
 {
 	/*
@@ -891,6 +904,7 @@ static void cleanup_workqueue_thread(struct cpu_workqueue_struct *cwq)
 	 * checks list_empty(), and a "normal" queue_work() can't use
 	 * a dead CPU.
 	 */
+	trace_workqueue_destruction(cwq->thread);
 	kthread_stop(cwq->thread);
 	cwq->thread = NULL;
 }
-- 
1.5.6.5

-- 
