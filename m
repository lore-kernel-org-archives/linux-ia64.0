From: Keith Owens <kaos@sgi.com>
Date: Wed, 28 Jan 2004 01:09:15 +0000
Subject: [patch] 2.4.25-pre6 Periodic check for outstanding MCA/INIT records
Message-Id: <3814.1075252155@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony, this goes with your recent recoverable MCA patch where you
reported that the MCA records were only being logged on the next boot.
It compiles and boots, can you confirm that it picks up the recovered
MCA records every few minutes without needing a reboot?

--- 2.4.25-pre6/arch/ia64/kernel/salinfo.c	Wed Jan 28 12:08:10 2004
+++ 2.4.25-pre6/arch/ia64/kernel/salinfo.c	Wed Jan 28 12:07:12 2004
@@ -16,6 +16,9 @@
  *   Cache the record across multi-block reads from user space.
  *   Support > 64 cpus.
  *   Delete module_exit and MOD_INC/DEC_COUNT, salinfo cannot be a module.
+ *
+ * Jan 28 2004	kaos@sgi.com
+ *   Periodically check for outstanding MCA or INIT records.
  */
 
 #include <linux/types.h>
@@ -23,6 +26,7 @@
 #include <linux/module.h>
 #include <linux/smp.h>
 #include <linux/smp_lock.h>
+#include <linux/timer.h>
 #include <linux/vmalloc.h>
 
 #include <asm/semaphore.h>
@@ -187,6 +191,8 @@
 /* This routine is invoked in interrupt context.  Note: mca.c enables
  * interrupts before calling this code for CMC/CPE.  MCA and INIT events are
  * not irq safe, do not call any routines that use spinlocks, they may deadlock.
+ * MCA and INIT records are recorded, a timer event will look for any
+ * outstanding events and wake up the user space code.
  *
  * The buffer passed from mca.c points to the output from ia64_log_get. This is
  * a persistent buffer but its contents can change between the interrupt and
@@ -232,6 +238,35 @@
 	}
 }
 
+/* Check for outstanding MCA/INIT records every 5 minutes (arbitrary) */
+#define SALINFO_TIMER_DELAY (5*60*HZ)
+static struct timer_list salinfo_timer;
+
+static void
+salinfo_timeout_check(struct salinfo_data *data)
+{
+	int i;
+	if (!data->open)
+		return;
+	for (i = 0; i < NR_CPUS; ++i) {
+		if (test_bit(i, &data->cpu_event)) {
+			/* double up() is not a problem, user space will see no
+			 * records for the additional "events".
+			 */
+			up(&data->sem);
+		}
+	}
+}
+
+static void 
+salinfo_timeout (unsigned long arg)
+{
+	salinfo_timeout_check(salinfo_data + SAL_INFO_TYPE_MCA);
+	salinfo_timeout_check(salinfo_data + SAL_INFO_TYPE_INIT);
+	salinfo_timer.expires = jiffies + SALINFO_TIMER_DELAY;
+	add_timer(&salinfo_timer);
+}
+
 static int
 salinfo_event_open(struct inode *inode, struct file *file)
 {
@@ -571,6 +606,11 @@
 
 	*sdir++ = salinfo_dir;
 
+	init_timer(&salinfo_timer);
+	salinfo_timer.expires = jiffies + SALINFO_TIMER_DELAY;
+	salinfo_timer.function = &salinfo_timeout;
+	add_timer(&salinfo_timer);
+
 	return 0;
 }
 

