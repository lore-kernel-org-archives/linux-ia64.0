From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Fri, 30 May 2003 20:27:36 +0000
Subject: Re: [Linux-ia64] SAL error record logging/decoding
Message-Id: <marc-linux-ia64-105590723706092@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705660@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705660@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Friday 30 May 2003 5:56 am, Matthew Wilcox wrote:
> > Or, back to two files: {event,data} ... we read from "event" to see
> > what happened.  Writing to "data" controls what will be read from "data".
> 
> I like this alternative better.  But there's a bit of a race condition if
> two programs are attempting to use these files at the same time.

OK, I coded this up.  Actually, I made two files per event type,
so we have

	/proc/sal/mca/event
	/proc/sal/mca/data
	/proc/sal/init/event
	... etc

The "event" files are read-only and reads block if no error records
are available.  When records become available, the data returned
looks like "read 0".  If several CPUs have records available, reads
round-robin through them.

The "data" files are read/write and single-open, so a smart app can
keep it open to prevent races.  If you write the data you got from
an "event" file (i.e., "read 0"), subsequent reads from "data" return
error records from the indicated CPU.  You can also write "clear 0"
to clear the error record.

So a simple-minded loop looks like this:

	EVENT=/proc/sal/cpe/event
	DATA=/proc/sal/cpe/data
	LOG=/var/log/sal/cpe/log

	while read ACTION CPU < $EVENT; do
	    echo $ACTION $CPU > $DATA
	    cat  $DATA > $LOG
	    echo clear $CPU > $DATA
	    decode $LOG
	done

Of course a better logger would keep the data file open to
prevent races, generate new log files for each event, etc.

I didn't implement poll(2), but we could if it seems necessary.

The basic logging/decoding package is here:

    ftp://kernel.org/pub/linux/kernel/people/helgaas/salinfo-0.1.tar.gz

Bjorn


=== arch/ia64/kernel/mca.c 1.26 vs edited ==--- 1.26/arch/ia64/kernel/mca.c	Fri May 16 04:33:42 2003
+++ edited/arch/ia64/kernel/mca.c	Thu May 29 19:24:29 2003
@@ -130,12 +130,14 @@
  */
 static int cmc_polling_enabled = 1;
 
+extern void salinfo_log_wakeup(int);
+
 /*
  *  ia64_mca_log_sal_error_record
  *
- *  This function retrieves a specified error record type from SAL, sends it to
- *  the system log, and notifies SALs to clear the record from its non-volatile
- *  memory.
+ *  This function retrieves a specified error record type from SAL,
+ *  wakes up any processes waiting for error records, and sends it to
+ *  the system log.
  *
  *  Inputs  :   sal_info_type   (Type of error record MCA/CMC/CPE/INIT)
  *  Outputs :   platform error status
@@ -155,11 +157,8 @@
 	 * 3. set ia64_os_mca_recovery_successful flag, if applicable
 	 */
 
+	salinfo_log_wakeup(sal_info_type);
 	platform_err = ia64_log_print(sal_info_type, (prfunc_t)printk);
-	/* temporary: only clear SAL logs on hardware-corrected errors
-		or if we're logging an error after an MCA-initiated reboot */
-	if ((sal_info_type > 1) || (called_from_init))
-		ia64_sal_clear_state_info(sal_info_type);
 
 	return platform_err;
 }
@@ -369,9 +368,7 @@
  *  ia64_mca_check_errors
  *
  *  External entry to check for error records which may have been posted by SAL
- *  for a prior failure which resulted in a machine shutdown before an the
- *  error could be logged.  This function must be called after the filesystem
- *  is initialized.
+ *  for a prior failure.
  *
  *  Inputs  :   None
  *
@@ -383,6 +380,7 @@
 	/*
 	 *  If there is an MCA error record pending, get it and log it.
 	 */
+	printk("CPU %d: checking for saved MCA error records\n", smp_processor_id());
 	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_MCA, 1);
 
 	return 0;
@@ -1250,9 +1248,6 @@
 
 	ia64_process_min_state_save(&SAL_LPI_PSI_INFO(proc_ptr)->min_state_area);
 
-	/* Clear the INIT SAL logs now that they have been saved in the OS buffer */
-	ia64_sal_clear_state_info(SAL_INFO_TYPE_INIT);
-
 	init_handler_platform(proc_ptr, pt, sw);	/* call platform specific routines */
 }
 
@@ -2302,10 +2297,8 @@
 
 	switch(sal_info_type) {
 	      case SAL_INFO_TYPE_MCA:
-		prfunc("+BEGIN HARDWARE ERROR STATE AT MCA\n");
-		platform_err = ia64_log_platform_info_print(IA64_LOG_CURR_BUFFER(sal_info_type),
-							    prfunc);
-		prfunc("+END HARDWARE ERROR STATE AT MCA\n");
+		prfunc("+CPU %d: SAL log contains MCA error record\n", smp_processor_id());
+		ia64_log_rec_header_print(IA64_LOG_CURR_BUFFER(sal_info_type), prfunc);
 		break;
 	      case SAL_INFO_TYPE_INIT:
 		prfunc("+MCA INIT ERROR LOG (UNIMPLEMENTED)\n");
=== arch/ia64/kernel/salinfo.c 1.1 vs edited ==--- 1.1/arch/ia64/kernel/salinfo.c	Thu Sep 12 10:43:47 2002
+++ edited/arch/ia64/kernel/salinfo.c	Fri May 30 12:46:28 2003
@@ -4,6 +4,8 @@
  * Creates entries in /proc/sal for various system features.
  *
  * Copyright (c) 2001 Silicon Graphics, Inc.  All rights reserved.
+ * Copyright (c) 2003 Hewlett-Packard Co
+ *	Bjorn Helgaas <bjorn.helgaas@hp.com>
  *
  * 10/30/2001	jbarnes@sgi.com		copied much of Stephane's palinfo
  *					code to create this file
@@ -12,8 +14,10 @@
 #include <linux/types.h>
 #include <linux/proc_fs.h>
 #include <linux/module.h>
+#include <linux/smp.h>
 
 #include <asm/sal.h>
+#include <asm/uaccess.h>
 
 MODULE_AUTHOR("Jesse Barnes <jbarnes@sgi.com>");
 MODULE_DESCRIPTION("/proc interface to IA-64 SAL features");
@@ -40,25 +44,326 @@
 
 #define NR_SALINFO_ENTRIES (sizeof(salinfo_entries)/sizeof(salinfo_entry_t))
 
-/*
- * One for each feature and one more for the directory entry...
- */
-static struct proc_dir_entry *salinfo_proc_entries[NR_SALINFO_ENTRIES + 1];
+static char *salinfo_log_name[] = {
+	"mca",
+	"init",
+	"cmc",
+	"cpe",
+};
+
+static struct proc_dir_entry *salinfo_proc_entries[
+	ARRAY_SIZE(salinfo_entries) +			/* /proc/sal/bus_lock */
+	ARRAY_SIZE(salinfo_log_name) +			/* /proc/sal/{mca,...} */
+	(2 * ARRAY_SIZE(salinfo_log_name)) +		/* /proc/sal/mca/{event,data} */
+	1];						/* /proc/sal */
+
+struct salinfo_log_data {
+	int	type;
+	u8	*log_buffer;
+	u64	log_size;
+};
+
+struct salinfo_event {
+	int			type;
+	int			cpu;		/* next CPU to check */
+	volatile unsigned long	cpu_mask;
+	wait_queue_head_t	queue;
+};
+
+static struct salinfo_event *salinfo_event[ARRAY_SIZE(salinfo_log_name)];
+
+struct salinfo_data {
+	int	open;		/* single-open to prevent races */
+	int	type;
+	int	cpu;		/* "current" cpu for reads */
+};
+
+static struct salinfo_data salinfo_data[ARRAY_SIZE(salinfo_log_name)];
+
+static spinlock_t data_lock;
+
+void
+salinfo_log_wakeup(int type)
+{
+	if (type < ARRAY_SIZE(salinfo_log_name)) {
+		struct salinfo_event *event = salinfo_event[type];
+
+		if (event) {
+			set_bit(smp_processor_id(), &event->cpu_mask);
+			wake_up_interruptible(&event->queue);
+		}
+	}
+}
+
+static int
+salinfo_event_open(struct inode *inode, struct file *file)
+{
+	struct proc_dir_entry *entry = (struct proc_dir_entry *) inode->u.generic_ip;
+	struct salinfo_event *event = entry->data;
+
+	if (!suser())
+		return -EPERM;
+	return 0;
+}
+
+static ssize_t
+salinfo_event_read(struct file *file, char *buffer, size_t count, loff_t *ppos)
+{
+	struct inode *inode = file->f_dentry->d_inode;
+	struct proc_dir_entry *entry = (struct proc_dir_entry *) inode->u.generic_ip;
+	struct salinfo_event *event = entry->data;
+	char cmd[32];
+	size_t size;
+	int i, n, cpu = -1;
+
+retry:
+	if (!event->cpu_mask) {
+		if (file->f_flags & O_NONBLOCK)
+			return -EAGAIN;
+		interruptible_sleep_on(&event->queue);
+		if (signal_pending(current))
+			return -EINTR;
+	}
+
+	n = event->cpu;
+	for (i = 0; i < NR_CPUS; i++) {
+		if (event->cpu_mask & 1UL << n) {
+			cpu = n;
+			break;
+		}
+		if (++n = NR_CPUS)
+			n = 0;
+	}
+
+	if (cpu = -1)
+		goto retry;
+
+	/* for next read, start checking at next CPU */
+	event->cpu = cpu;
+	if (++event->cpu = NR_CPUS)
+		event->cpu = 0;
+
+	snprintf(cmd, sizeof(cmd), "read %d\n", cpu);
+
+	size = strlen(cmd);
+	if (size > count)
+		size = count;
+	if (copy_to_user(buffer, cmd, size))
+		return -EFAULT;
+
+	return size;
+}
+
+static struct file_operations salinfo_event_fops = {
+	.open  = salinfo_event_open,
+	.read  = salinfo_event_read,
+};
+
+static int
+salinfo_log_open(struct inode *inode, struct file *file)
+{
+	struct proc_dir_entry *entry = (struct proc_dir_entry *) inode->u.generic_ip;
+	struct salinfo_data *data = entry->data;
+
+	if (!suser())
+		return -EPERM;
+
+	spin_lock(&data_lock);
+	if (data->open) {
+		spin_unlock(&data_lock);
+		return -EBUSY;
+	}
+	data->open = 1;
+	spin_unlock(&data_lock);
+
+	return 0;
+}
+
+static int
+salinfo_log_release(struct inode *inode, struct file *file)
+{
+	struct proc_dir_entry *entry = (struct proc_dir_entry *) inode->u.generic_ip;
+	struct salinfo_data *data = entry->data;
+
+	spin_lock(&data_lock);
+	data->open = 0;
+	spin_unlock(&data_lock);
+	return 0;
+}
+
+static void
+call_on_cpu(int cpu, void (*fn)(void *), void *arg)
+{
+	if (cpu = smp_processor_id())
+		(*fn)(arg);
+#ifdef CONFIG_SMP
+	else if (cpu_online(cpu))	/* cpu may be unvalidated */
+		smp_call_function_single(cpu, fn, arg, 0, 1);
+#endif
+}
+
+static void
+salinfo_log_read_cpu(void *context)
+{
+	struct salinfo_log_data *info = context;
+	struct salinfo_event *event = salinfo_event[info->type];
+	u64 size;
+
+	size = ia64_sal_get_state_info_size(info->type);
+	info->log_buffer = kmalloc(size, GFP_ATOMIC);
+	if (!info->log_buffer)
+		return;
+
+	clear_bit(smp_processor_id(), &event->cpu_mask);
+	info->log_size = ia64_sal_get_state_info(info->type, (u64 *) info->log_buffer);
+	if (info->log_size)
+		salinfo_log_wakeup(info->type);
+}
+
+static ssize_t
+salinfo_log_read(struct file *file, char *buffer, size_t count, loff_t *ppos)
+{
+	struct inode *inode = file->f_dentry->d_inode;
+	struct proc_dir_entry *entry = (struct proc_dir_entry *) inode->u.generic_ip;
+	struct salinfo_data *data = entry->data;
+	struct salinfo_log_data info;
+	int ret;
+	void *saldata;
+	size_t size;
+
+	info.type = data->type;
+	call_on_cpu(data->cpu, salinfo_log_read_cpu, &info);
+	if (!info.log_buffer || *ppos >= info.log_size) {
+		ret = 0;
+		goto out;
+	}
+
+	saldata = info.log_buffer + file->f_pos;
+	size = info.log_size - file->f_pos;
+	if (size > count)
+		size = count;
+	if (copy_to_user(buffer, saldata, size)) {
+		ret = -EFAULT;
+		goto out;
+	}
+
+	*ppos += size;
+	ret = size;
+
+out:
+	kfree(info.log_buffer);
+	return ret;
+}
+
+static void
+salinfo_log_clear_cpu(void *context)
+{
+	struct salinfo_data *data = context;
+	struct salinfo_event *event = salinfo_event[data->type];
+	struct salinfo_log_data info;
+
+	clear_bit(smp_processor_id(), &event->cpu_mask);
+	ia64_sal_clear_state_info(data->type);
+
+	/* clearing one record may make another visible */
+	info.type = data->type;
+	salinfo_log_read_cpu(&info);
+	if (info.log_buffer && info.log_size)
+		salinfo_log_wakeup(data->type);
+
+	kfree(info.log_buffer);
+}
+
+static ssize_t
+salinfo_log_write(struct file *file, const char *buffer, size_t count, loff_t *ppos)
+{
+	struct inode *inode = file->f_dentry->d_inode;
+	struct proc_dir_entry *entry = (struct proc_dir_entry *) inode->u.generic_ip;
+	struct salinfo_data *data = entry->data;
+	char cmd[32];
+	size_t size;
+	int cpu;
+
+	size = sizeof(cmd);
+	if (count < size)
+		size = count;
+	if (copy_from_user(cmd, buffer, size))
+		return -EFAULT;
+
+	if (sscanf(cmd, "read %d", &cpu) = 1)
+		data->cpu = cpu;
+	else if (sscanf(cmd, "clear %d", &cpu) = 1)
+		call_on_cpu(cpu, salinfo_log_clear_cpu, data);
+	else if (sscanf(cmd, "wake %d", &cpu) = 1)	// FIXME for debug
+		call_on_cpu(cpu, salinfo_log_wakeup, data->type);
+
+	return count;
+}
+
+static struct file_operations salinfo_data_fops = {
+	.open    = salinfo_log_open,
+	.release = salinfo_log_release,
+	.read    = salinfo_log_read,
+	.write   = salinfo_log_write,
+};
 
 static int __init
 salinfo_init(void)
 {
 	struct proc_dir_entry *salinfo_dir; /* /proc/sal dir entry */
 	struct proc_dir_entry **sdir = salinfo_proc_entries; /* keeps track of every entry */
-	int i;
+	struct proc_dir_entry *dir, *entry;
+	struct salinfo_event *event;
+	struct salinfo_data *data;
+	int i, j;
 
 	salinfo_dir = proc_mkdir("sal", NULL);
+	if (!salinfo_dir)
+		return 0;
 
 	for (i=0; i < NR_SALINFO_ENTRIES; i++) {
 		/* pass the feature bit in question as misc data */
 		*sdir++ = create_proc_read_entry (salinfo_entries[i].name, 0, salinfo_dir,
 						  salinfo_read, (void *)salinfo_entries[i].feature);
 	}
+
+	for (i = 0; i < ARRAY_SIZE(salinfo_log_name); i++) {
+		dir = proc_mkdir(salinfo_log_name[i], salinfo_dir);
+		if (!dir)
+			continue;
+
+		entry = create_proc_entry("event", S_IRUSR, dir);
+		if (!entry)
+			continue;
+
+		event = kmalloc(sizeof(*event), GFP_KERNEL);
+		if (!event)
+			continue;
+		memset(event, 0, sizeof(*event));
+		event->type = i;
+		init_waitqueue_head(&event->queue);
+		salinfo_event[i] = event;
+		/* we missed any events before now */
+		for (j = 0; j < NR_CPUS; j++)
+			if (cpu_online(j))
+				set_bit(j, &event->cpu_mask);
+		entry->data = event;
+		entry->proc_fops = &salinfo_event_fops;
+		*sdir++ = entry;
+
+		entry = create_proc_entry("data", S_IRUSR | S_IWUSR, dir);
+		if (!entry)
+			continue;
+
+		data = &salinfo_data[i];
+		data->type = i;
+		entry->data = data;
+		entry->proc_fops = &salinfo_data_fops;
+		*sdir++ = entry;
+
+		*sdir++ = dir;
+	}
+
 	*sdir++ = salinfo_dir;
 
 	return 0;
@@ -69,7 +374,7 @@
 {
 	int i = 0;
 
-	for (i = 0; i < NR_SALINFO_ENTRIES ; i++) {
+	for (i = 0; i < ARRAY_SIZE(salinfo_proc_entries); i++) {
 		if (salinfo_proc_entries[i])
 			remove_proc_entry (salinfo_proc_entries[i]->name, NULL);
 	}


