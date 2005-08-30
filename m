From: Keith Owens <kaos@sgi.com>
Date: Tue, 30 Aug 2005 05:04:19 +0000
Subject: [PATCH 2.6.13 1/7] MCA/INIT: scheduler hooks
Message-Id: <20050830050419.7997.29280.sendpatchset@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Scheduler hooks to change which process is deemed to be on a cpu.

Signed-off-by: Keith Owens <kaos@sgi.com>

---

 include/linux/sched.h |    2 ++
 kernel/sched.c        |   28 ++++++++++++++++++++++++++++
 2 files changed, 30 insertions(+)

Index: linux/include/linux/sched.h
=================================--- linux.orig/include/linux/sched.h	2005-08-30 13:53:13.714211731 +1000
+++ linux/include/linux/sched.h	2005-08-30 13:53:55.601081759 +1000
@@ -883,6 +883,8 @@ extern int task_curr(const task_t *p);
 extern int idle_cpu(int cpu);
 extern int sched_setscheduler(struct task_struct *, int, struct sched_param *);
 extern task_t *idle_task(int cpu);
+extern task_t *curr_task(int cpu);
+extern void set_curr_task(int cpu, task_t *p);
 
 void yield(void);
 
Index: linux/kernel/sched.c
=================================--- linux.orig/kernel/sched.c	2005-08-30 13:53:13.714211731 +1000
+++ linux/kernel/sched.c	2005-08-30 13:56:15.981358192 +1000
@@ -3471,6 +3471,34 @@ task_t *idle_task(int cpu)
 }
 
 /**
+ * curr_task - return the current task for a given cpu.
+ * @cpu: the processor in question.
+ */
+task_t *curr_task(int cpu)
+{
+	return cpu_curr(cpu);
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
+	cpu_curr(cpu) = p;
+}
+EXPORT_SYMBOL_GPL(set_curr_task);
+
+/**
  * find_process_by_pid - find a process with a matching PID value.
  * @pid: the pid in question.
  */
