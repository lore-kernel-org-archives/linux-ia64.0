From: Keith Owens <kaos@sgi.com>
Date: Wed, 17 Aug 2005 05:39:13 +0000
Subject: [Review 1/7] MCA/INIT scheduler hooks
Message-Id: <7788.1124257153@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Scheduler hooks to change which process is deemed to be on a cpu.

 include/linux/sched.h |    2 ++
 kernel/sched.c        |   28 ++++++++++++++++++++++++++++
 2 files changed, 30 insertions(+)

Index: linux/include/linux/sched.h
=================================--- linux.orig/include/linux/sched.h	2005-08-01 11:49:17.130276812 +1000
+++ linux/include/linux/sched.h	2005-08-01 12:03:13.857267716 +1000
@@ -883,6 +883,8 @@ extern int task_curr(const task_t *p);
 extern int idle_cpu(int cpu);
 extern int sched_setscheduler(struct task_struct *, int, struct sched_param *);
 extern task_t *idle_task(int cpu);
+extern task_t *curr_task(int cpu);
+extern void set_curr_task(int cpu, task_t *p);
 
 void yield(void);
 
Index: linux/kernel/sched.c
=================================--- linux.orig/kernel/sched.c	2005-08-01 11:49:19.642973411 +1000
+++ linux/kernel/sched.c	2005-08-01 12:03:13.860197405 +1000
@@ -3471,6 +3471,34 @@ task_t *idle_task(int cpu)
 }
 
 /**
+ * curr_task - return the current task for a given cpu.
+ * @cpu: the processor in question.
+ */
+task_t *curr_task(int cpu)
+{
+	return cpu_rq(cpu)->curr;
+}
+EXPORT_SYMBOL_GPL(curr_task);
+
+/**
+ * set_curr_task - set the current task for a given cpu.
+ * @cpu: the processor in question.
+ * @p: the task pointer to set.
+ *
+ * Description: This function must only be used when non-maskable interrupts
+ * are serviced on a separate stack.  It allows the architecture to switch the
+ * notion of the current task on a cpu in a non-blocking manner.  This function
+ * must be called with interrupts disabled, the caller must save the original
+ * value of the current task (see curr_task() above) and restore that value
+ * before reenabling interrupts.
+ */
+void set_curr_task(int cpu, task_t *p)
+{
+	cpu_rq(cpu)->curr = p;
+}
+EXPORT_SYMBOL_GPL(set_curr_task);
+
+/**
  * find_process_by_pid - find a process with a matching PID value.
  * @pid: the pid in question.
  */


