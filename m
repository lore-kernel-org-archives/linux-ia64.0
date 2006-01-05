From: Keith Owens <kaos@sgi.com>
Date: Thu, 05 Jan 2006 23:36:06 +0000
Subject: [patch 2.6.15] Add hotplug cpu to salinfo.c, replace semaphore with mutex
Message-Id: <24240.1136504166@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Add hotplug cpu support to salinfo.c.

The cpu_event field is a cpumask so use the cpu_* macros consistently,
replacing the existing mixture of cpu_* and *_bit macros.

Instead of counting the number of outstanding events in a semaphore and
trying to track that count over user space context, interrupt context,
non-maskable interrupt context and cpu hotplug, replace the semaphore
with a test for "any bits set" combined with a mutex.

Modify the locking to make the test for "work to do" an atomic
operation.

Signed-off-by: Keith Owens <kaos@sgi.com>

---

 salinfo.c |  170 +++++++++++++++++++++++++++++++++++++++++++-------------------
 1 files changed, 119 insertions(+), 51 deletions(-)


Index: linux/arch/ia64/kernel/salinfo.c
=================================--- linux.orig/arch/ia64/kernel/salinfo.c	2006-01-03 14:21:10.000000000 +1100
+++ linux/arch/ia64/kernel/salinfo.c	2006-01-06 02:14:59.360107040 +1100
@@ -3,7 +3,7 @@
  *
  * Creates entries in /proc/sal for various system features.
  *
- * Copyright (c) 2003 Silicon Graphics, Inc.  All rights reserved.
+ * Copyright (c) 2003, 2006 Silicon Graphics, Inc.  All rights reserved.
  * Copyright (c) 2003 Hewlett-Packard Co
  *	Bjorn Helgaas <bjorn.helgaas@hp.com>
  *
@@ -27,8 +27,16 @@
  *   mca.c may not pass a buffer, a NULL buffer just indicates that a new
  *   record is available in SAL.
  *   Replace some NR_CPUS by cpus_online, for hotplug cpu.
+ *
+ * Jan  5 2006	kaos@sgi.com
+ *   Handle hotplug cpus coming online.
+ *   Handle hotplug cpus going offline while they still have outstanding records.
+ *   Use the cpu_* macros consistently.
+ *   Replace the counting semaphore with a mutex and a test if the cpumask is non-empty.
+ *   Modify the locking to make the test for "work to do" an atomic operation.
  */
 
+#include <linux/cpu.h>
 #include <linux/types.h>
 #include <linux/proc_fs.h>
 #include <linux/module.h>
@@ -131,8 +139,8 @@ enum salinfo_state {
 };
 
 struct salinfo_data {
-	volatile cpumask_t	cpu_event;	/* which cpus have outstanding events */
-	struct semaphore	sem;		/* count of cpus with outstanding events (bits set in cpu_event) */
+	cpumask_t		cpu_event;	/* which cpus have outstanding events */
+	struct semaphore	mutex;
 	u8			*log_buffer;
 	u64			log_size;
 	u8			*oemdata;	/* decoded oem data */
@@ -173,6 +181,21 @@ struct salinfo_platform_oemdata_parms {
 	int ret;
 };
 
+/* Kick the mutex that tells user space that there is work to do.  Instead of
+ * trying to track the state of the mutex across multiple cpus, in user
+ * context, interrupt context, non-maskable interrupt context and hotplug cpu,
+ * it is far easier just to grab the mutex if it is free then release it.
+ *
+ * This routine must be called with data_saved_lock held, to make the down/up
+ * operation atomic.
+ */
+static void
+salinfo_work_to_do(struct salinfo_data *data)
+{
+	down_trylock(&data->mutex);
+	up(&data->mutex);
+}
+
 static void
 salinfo_platform_oemdata_cpu(void *context)
 {
@@ -211,9 +234,9 @@ salinfo_log_wakeup(int type, u8 *buffer,
 
 	BUG_ON(type >= ARRAY_SIZE(salinfo_log_name));
 
+	if (irqsafe)
+		spin_lock_irqsave(&data_saved_lock, flags);
 	if (buffer) {
-		if (irqsafe)
-			spin_lock_irqsave(&data_saved_lock, flags);
 		for (i = 0, data_saved = data->data_saved; i < saved_size; ++i, ++data_saved) {
 			if (!data_saved->buffer)
 				break;
@@ -231,13 +254,11 @@ salinfo_log_wakeup(int type, u8 *buffer,
 			data_saved->size = size;
 			data_saved->buffer = buffer;
 		}
-		if (irqsafe)
-			spin_unlock_irqrestore(&data_saved_lock, flags);
 	}
-
-	if (!test_and_set_bit(smp_processor_id(), &data->cpu_event)) {
-		if (irqsafe)
-			up(&data->sem);
+	cpu_set(smp_processor_id(), data->cpu_event);
+	if (irqsafe) {
+		salinfo_work_to_do(data);
+		spin_unlock_irqrestore(&data_saved_lock, flags);
 	}
 }
 
@@ -248,20 +269,17 @@ static struct timer_list salinfo_timer;
 static void
 salinfo_timeout_check(struct salinfo_data *data)
 {
-	int i;
+	unsigned long flags;
 	if (!data->open)
 		return;
-	for_each_online_cpu(i) {
-		if (test_bit(i, &data->cpu_event)) {
-			/* double up() is not a problem, user space will see no
-			 * records for the additional "events".
-			 */
-			up(&data->sem);
-		}
+	if (!cpus_empty(data->cpu_event)) {
+		spin_lock_irqsave(&data_saved_lock, flags);
+		salinfo_work_to_do(data);
+		spin_unlock_irqrestore(&data_saved_lock, flags);
 	}
 }
 
-static void 
+static void
 salinfo_timeout (unsigned long arg)
 {
 	salinfo_timeout_check(salinfo_data + SAL_INFO_TYPE_MCA);
@@ -289,16 +307,20 @@ salinfo_event_read(struct file *file, ch
 	int i, n, cpu = -1;
 
 retry:
-	if (down_trylock(&data->sem)) {
+	if (cpus_empty(data->cpu_event) && down_trylock(&data->mutex)) {
 		if (file->f_flags & O_NONBLOCK)
 			return -EAGAIN;
-		if (down_interruptible(&data->sem))
+		if (down_interruptible(&data->mutex))
 			return -EINTR;
 	}
 
 	n = data->cpu_check;
 	for (i = 0; i < NR_CPUS; i++) {
-		if (test_bit(n, &data->cpu_event) && cpu_online(n)) {
+		if (cpu_isset(n, data->cpu_event)) {
+			if (!cpu_online(n)) {
+				cpu_clear(n, data->cpu_event);
+				continue;
+			}
 			cpu = n;
 			break;
 		}
@@ -309,9 +331,6 @@ retry:
 	if (cpu = -1)
 		goto retry;
 
-	/* events are sticky until the user says "clear" */
-	up(&data->sem);
-
 	/* for next read, start checking at next CPU */
 	data->cpu_check = cpu;
 	if (++data->cpu_check = NR_CPUS)
@@ -380,10 +399,8 @@ salinfo_log_release(struct inode *inode,
 static void
 call_on_cpu(int cpu, void (*fn)(void *), void *arg)
 {
-	cpumask_t save_cpus_allowed, new_cpus_allowed;
-	memcpy(&save_cpus_allowed, &current->cpus_allowed, sizeof(save_cpus_allowed));
-	memset(&new_cpus_allowed, 0, sizeof(new_cpus_allowed));
-	set_bit(cpu, &new_cpus_allowed);
+	cpumask_t save_cpus_allowed = current->cpus_allowed;
+	cpumask_t new_cpus_allowed = cpumask_of_cpu(cpu);
 	set_cpus_allowed(current, new_cpus_allowed);
 	(*fn)(arg);
 	set_cpus_allowed(current, save_cpus_allowed);
@@ -432,10 +449,10 @@ retry:
 	if (!data->saved_num)
 		call_on_cpu(cpu, salinfo_log_read_cpu, data);
 	if (!data->log_size) {
-	        data->state = STATE_NO_DATA;
-	        clear_bit(cpu, &data->cpu_event);
+		data->state = STATE_NO_DATA;
+		cpu_clear(cpu, data->cpu_event);
 	} else {
-	        data->state = STATE_LOG_RECORD;
+		data->state = STATE_LOG_RECORD;
 	}
 }
 
@@ -472,27 +489,31 @@ static int
 salinfo_log_clear(struct salinfo_data *data, int cpu)
 {
 	sal_log_record_header_t *rh;
+	unsigned long flags;
+	spin_lock_irqsave(&data_saved_lock, flags);
 	data->state = STATE_NO_DATA;
-	if (!test_bit(cpu, &data->cpu_event))
+	if (!cpu_isset(cpu, data->cpu_event)) {
+		spin_unlock_irqrestore(&data_saved_lock, flags);
 		return 0;
-	down(&data->sem);
-	clear_bit(cpu, &data->cpu_event);
+	}
+	cpu_clear(cpu, data->cpu_event);
 	if (data->saved_num) {
-		unsigned long flags;
-		spin_lock_irqsave(&data_saved_lock, flags);
-		shift1_data_saved(data, data->saved_num - 1 );
+		shift1_data_saved(data, data->saved_num - 1);
 		data->saved_num = 0;
-		spin_unlock_irqrestore(&data_saved_lock, flags);
 	}
+	spin_unlock_irqrestore(&data_saved_lock, flags);
 	rh = (sal_log_record_header_t *)(data->log_buffer);
 	/* Corrected errors have already been cleared from SAL */
 	if (rh->severity != sal_log_severity_corrected)
 		call_on_cpu(cpu, salinfo_log_clear_cpu, data);
 	/* clearing a record may make a new record visible */
 	salinfo_log_new_read(cpu, data);
-	if (data->state = STATE_LOG_RECORD &&
-	    !test_and_set_bit(cpu,  &data->cpu_event))
-		up(&data->sem);
+	if (data->state = STATE_LOG_RECORD) {
+		spin_lock_irqsave(&data_saved_lock, flags);
+		cpu_set(cpu, data->cpu_event);
+		salinfo_work_to_do(data);
+		spin_unlock_irqrestore(&data_saved_lock, flags);
+	}
 	return 0;
 }
 
@@ -549,6 +570,53 @@ static struct file_operations salinfo_da
 	.write   = salinfo_log_write,
 };
 
+#ifdef	CONFIG_HOTPLUG_CPU
+static int __devinit
+salinfo_cpu_callback(struct notifier_block *nb, unsigned long action, void *hcpu)
+{
+	unsigned int i, cpu = (unsigned long)hcpu;
+	unsigned long flags;
+	struct salinfo_data *data;
+	switch (action) {
+	case CPU_ONLINE:
+		spin_lock_irqsave(&data_saved_lock, flags);
+		for (i = 0, data = salinfo_data;
+		     i < ARRAY_SIZE(salinfo_data);
+		     ++i, ++data) {
+			cpu_set(cpu, data->cpu_event);
+			salinfo_work_to_do(data);
+		}
+		spin_unlock_irqrestore(&data_saved_lock, flags);
+		break;
+	case CPU_DEAD:
+		spin_lock_irqsave(&data_saved_lock, flags);
+		for (i = 0, data = salinfo_data;
+		     i < ARRAY_SIZE(salinfo_data);
+		     ++i, ++data) {
+			struct salinfo_data_saved *data_saved;
+			int j;
+			for (j = ARRAY_SIZE(data->data_saved) - 1, data_saved = data->data_saved + j;
+			     j >= 0;
+			     --j, --data_saved) {
+				if (data_saved->buffer && data_saved->cpu = cpu) {
+					shift1_data_saved(data, j);
+				}
+			}
+			cpu_clear(cpu, data->cpu_event);
+		}
+		spin_unlock_irqrestore(&data_saved_lock, flags);
+		break;
+	}
+	return NOTIFY_OK;
+}
+
+static struct notifier_block salinfo_cpu_notifier +{
+	.notifier_call = salinfo_cpu_callback,
+	.priority = 0,
+};
+#endif	/* CONFIG_HOTPLUG_CPU */
+
 static int __init
 salinfo_init(void)
 {
@@ -556,7 +624,7 @@ salinfo_init(void)
 	struct proc_dir_entry **sdir = salinfo_proc_entries; /* keeps track of every entry */
 	struct proc_dir_entry *dir, *entry;
 	struct salinfo_data *data;
-	int i, j, online;
+	int i, j;
 
 	salinfo_dir = proc_mkdir("sal", NULL);
 	if (!salinfo_dir)
@@ -571,7 +639,7 @@ salinfo_init(void)
 	for (i = 0; i < ARRAY_SIZE(salinfo_log_name); i++) {
 		data = salinfo_data + i;
 		data->type = i;
-		sema_init(&data->sem, 0);
+		init_MUTEX(&data->mutex);
 		dir = proc_mkdir(salinfo_log_name[i], salinfo_dir);
 		if (!dir)
 			continue;
@@ -591,12 +659,8 @@ salinfo_init(void)
 		*sdir++ = entry;
 
 		/* we missed any events before now */
-		online = 0;
-		for_each_online_cpu(j) {
-			set_bit(j, &data->cpu_event);
-			++online;
-		}
-		sema_init(&data->sem, online);
+		for_each_online_cpu(j)
+			cpu_set(j, data->cpu_event);
 
 		*sdir++ = dir;
 	}
@@ -608,6 +672,10 @@ salinfo_init(void)
 	salinfo_timer.function = &salinfo_timeout;
 	add_timer(&salinfo_timer);
 
+#ifdef	CONFIG_HOTPLUG_CPU
+	register_cpu_notifier(&salinfo_cpu_notifier);
+#endif
+
 	return 0;
 }
 

