From: Keith Owens <kaos@sgi.com>
Date: Sun, 11 Sep 2005 07:19:06 +0000
Subject: [PATCH 2.6.13 1/6] MCA/INIT: scheduler hooks
Message-Id: <25310.1126423146@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Scheduler hooks to change which process is deemed to be on a cpu.

Signed-off-by: Keith Owens <kaos@sgi.com>

---

 include/linux/sched.h |    2 ++
 kernel/sched.c        |   26 ++++++++++++++++++++++++++
 2 files changed, 28 insertions(+)

Index: linux/include/linux/sched.h
=================================--- linux.orig/include/linux/sched.h	2005-09-11 16:28:07.428788751 +1000
+++ linux/include/linux/sched.h	2005-09-11 16:28:52.054399236 +1000
@@ -883,6 +883,8 @@ extern int task_curr(const task_t *p);
 extern int idle_cpu(int cpu);
 extern int sched_setscheduler(struct task_struct *, int, struct sched_param *);
 extern task_t *idle_task(int cpu);
+extern task_t *curr_task(int cpu);
+extern void set_curr_task(int cpu, task_t *p);
 
 void yield(void);
 
Index: linux/kernel/sched.c
=================================--- linux.orig/kernel/sched.c	2005-09-11 16:28:07.429765177 +1000
+++ linux/kernel/sched.c	2005-09-11 16:29:03.264749430 +1000
@@ -3471,6 +3471,32 @@ task_t *idle_task(int cpu)
 }
 
 /**
+ * curr_task - return the current task for a given cpu.
+ * @cpu: the processor in question.
+ */
+task_t *curr_task(int cpu)
+{
+	return cpu_curr(cpu);
+}
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
+
+/**
  * find_process_by_pid - find a process with a matching PID value.
  * @pid: the pid in question.
  */

