From: Keith Owens <kaos@sgi.com>
Date: Tue, 10 Feb 2004 05:50:56 +0000
Subject: [patch] 2.4.25-rc1, 2.6.2-rc2 salinfo.c
Message-Id: <6246.1076392256@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Periodically check for outstanding MCA or INIT records and pass them to
user space salinfo.

Tony: I tested this with recovered MCA events.  The records showed up
once the 5 minute timer popped.

The patch is against 2.4.25-rc1 bk.  It applies to 2.6.2-rc2 with offsets.

Index: 25-rc1.5/arch/ia64/kernel/salinfo.c
--- 25-rc1.5/arch/ia64/kernel/salinfo.c Sat, 07 Feb 2004 10:36:36 +1100 kaos (linux-2.4/K/g/22_salinfo.c 1.1.1.1.1.1.1.2.1.1 644)
+++ 25-rc1.5(w)/arch/ia64/kernel/salinfo.c Tue, 10 Feb 2004 16:24:46 +1100 kaos (linux-2.4/K/g/22_salinfo.c 1.1.1.1.1.1.1.2.1.1 644)
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
@@ -187,6 +191,8 @@ shift1_data_saved (struct salinfo_data *
 /* This routine is invoked in interrupt context.  Note: mca.c enables
  * interrupts before calling this code for CMC/CPE.  MCA and INIT events are
  * not irq safe, do not call any routines that use spinlocks, they may deadlock.
+ * MCA and INIT records are recorded, a timer event will look for any
+ * outstanding events and wake up the user space code.
  *
  * The buffer passed from mca.c points to the output from ia64_log_get. This is
  * a persistent buffer but its contents can change between the interrupt and
@@ -232,6 +238,35 @@ salinfo_log_wakeup(int type, u8 *buffer,
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
@@ -571,6 +606,11 @@ salinfo_init(void)
 
 	*sdir++ = salinfo_dir;
 
+	init_timer(&salinfo_timer);
+	salinfo_timer.expires = jiffies + SALINFO_TIMER_DELAY;
+	salinfo_timer.function = &salinfo_timeout;
+	add_timer(&salinfo_timer);
+
 	return 0;
 }
 

