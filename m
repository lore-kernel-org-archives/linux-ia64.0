From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Wed, 28 May 2003 23:26:02 +0000
Subject: Re: [Linux-ia64] SAL error record logging/decoding
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_KWU1+nMESWMfvml"
Message-Id: <marc-linux-ia64-105590723706060@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705660@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705660@msgid-missing>
To: linux-ia64@vger.kernel.org

--Boundary-00=_KWU1+nMESWMfvml
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Wednesday 21 May 2003 12:06 pm, Luck, Tony wrote:
> Is there any easy way to get a notification that there is
> a record waiting in one of the /proc/sal/cpuX/* files ...

That's a good question that hadn't even occurred to me.
Here's another pass; see what you think:

	- Added support for poll(2) on the cpuX/* files
	- App keeps all the (4*NR_CPUS) files open
	- poll(2) tells app which files have data to be read
	- Added wakeup at the place we currently call
	  ia64_log_print

It got a little more involved than I hoped, because I didn't
want to call get_state_info() for all (4*NR_CPUS) files every
time the app called poll(2).

Oh, and I removed the MCA printks from the kernel.  I'll
go back and pull all the other printks out too, but I'll
propose that as a separate patch to avoid cluttering this
one.

Later, Tony wrote:
> 4) Reading this way is also kind of weird in that every partial read
> results in the kernel going back to re-fetch the data from the SAL
> with another call to ia64_sal_get_state_info().

I thought about trying to avoid this by caching the records in
open(), but then the app has to close and reopen the file in
order to see new data.  I really want to avoid managing buffers
of this stuff in the kernel, and I couldn't figure out a good
way to avoid the extra get_state_info() calls without maintaining
a lot more state.  With the current patch, we do about 4 or 5
get_state_info() calls per event:

	- ia64_os_mca_tlb_error_check() in mca_asm.S
	- ia64_log_get() in mca.c ISR
	- salinfo_log_read_cpu() when app reads record
	- salinfo_log_read_cpu() (to get EOF indication
	  after a short read)
	- salinfo_log_clear_cpu() when app clears record
	  (to see whether this makes another record available)

and I think we can get rid of the one in mca.c by just doing
the appropriate wakeup.  If the kernel doesn't decode anything,
there's probably no need to even get the record.

That still seems like a lot, but at least it scales with the
number of events that occur, not the number of CPUs and event
types.

Bjorn


===== arch/ia64/kernel/mca.c 1.26 vs edited =====
--- 1.26/arch/ia64/kernel/mca.c	Fri May 16 04:33:42 2003
+++ edited/arch/ia64/kernel/mca.c	Wed May 28 09:48:33 2003
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
===== arch/ia64/kernel/salinfo.c 1.1 vs edited =====
--- 1.1/arch/ia64/kernel/salinfo.c	Thu Sep 12 10:43:47 2002
+++ edited/arch/ia64/kernel/salinfo.c	Wed May 28 15:46:59 2003
@@ -4,16 +4,21 @@
  * Creates entries in /proc/sal for various system features.
  *
  * Copyright (c) 2001 Silicon Graphics, Inc.  All rights reserved.
+ * Copyright (c) 2003 Hewlett-Packard Co
+ *	Bjorn Helgaas <bjorn.helgaas@hp.com>
  *
  * 10/30/2001	jbarnes@sgi.com		copied much of Stephane's palinfo
  *					code to create this file
  */
 
 #include <linux/types.h>
+#include <linux/poll.h>
 #include <linux/proc_fs.h>
 #include <linux/module.h>
+#include <linux/smp.h>
 
 #include <asm/sal.h>
+#include <asm/uaccess.h>
 
 MODULE_AUTHOR("Jesse Barnes <jbarnes@sgi.com>");
 MODULE_DESCRIPTION("/proc interface to IA-64 SAL features");
@@ -40,25 +45,236 @@
 
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
+	(NR_CPUS * ARRAY_SIZE(salinfo_log_name)) +	/* /proc/sal/cpu0/mca */
+	NR_CPUS +					/* /proc/sal/cpu0 */
+	1];						/* /proc/sal */
+
+struct salinfo_log_data {
+	int	type;
+	u8	*log_buffer;
+	u64	log_size;
+};
+
+struct salinfo_wait_queue {
+	int			cpu;
+	int			type;
+	int			event_ready;
+	wait_queue_head_t	queue;
+};
+
+static struct salinfo_wait_queue *salinfo_wait[NR_CPUS][ARRAY_SIZE(salinfo_log_name)];
+
+void
+salinfo_log_wakeup(int type)
+{
+	int cpu = smp_processor_id();
+
+	if (type < ARRAY_SIZE(salinfo_log_name)) {
+		struct salinfo_wait_queue *wait = salinfo_wait[cpu][type];
+
+		if (wait) {
+			wait->event_ready = 1;
+			wake_up_interruptible(&wait->queue);
+		}
+	}
+}
+
+static int
+salinfo_log_open(struct inode *inode, struct file *file)
+{
+	if (!suser())
+		return -EPERM;
+	return 0;
+}
+
+static void
+call_on_cpu(int cpu, void (*fn)(void *), void *arg)
+{
+#ifdef CONFIG_SMP
+	if (cpu == smp_processor_id())
+		(*fn)(arg);
+	else
+		smp_call_function_single(cpu, fn, arg, 0, 1);
+#else
+	(*fn)(arg);
+#endif
+}
+
+static void
+salinfo_log_read_cpu(void *context)
+{
+	struct salinfo_log_data *info = context;
+	struct salinfo_wait_queue *wait = salinfo_wait[smp_processor_id()][info->type];
+	u64 size;
+
+	size = ia64_sal_get_state_info_size(info->type);
+	info->log_buffer = kmalloc(size, GFP_ATOMIC);
+	if (!info->log_buffer)
+		return;
+
+	wait->event_ready = 0;
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
+	struct salinfo_wait_queue *wait = entry->data;
+	struct salinfo_log_data info;
+	int ret;
+	void *data;
+	size_t size;
+
+	info.type = wait->type;
+	call_on_cpu(wait->cpu, salinfo_log_read_cpu, &info);
+
+	if (!info.log_buffer || *ppos >= info.log_size) {
+		ret = 0;
+		goto out;
+	}
+
+	data = info.log_buffer + file->f_pos;
+	size = info.log_size - file->f_pos;
+	if (size > count)
+		size = count;
+
+	if (copy_to_user(buffer, data, size)) {
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
+	struct salinfo_wait_queue *wait = context;
+	struct salinfo_log_data info;
+
+	wait->event_ready = 0;		/* avoid race with another wakeup */
+	ia64_sal_clear_state_info(wait->type);
+
+	info.type = wait->type;
+	salinfo_log_read_cpu(&info);
+	if (info.log_buffer && info.log_size)
+		salinfo_log_wakeup(wait->type);
+
+	kfree(info.log_buffer);
+}
+
+static ssize_t
+salinfo_log_write(struct file *file, const char *buffer, size_t count, loff_t *ppos)
+{
+	struct inode *inode = file->f_dentry->d_inode;
+	struct proc_dir_entry *entry = (struct proc_dir_entry *) inode->u.generic_ip;
+	struct salinfo_wait_queue *wait = entry->data;
+	char cmd[16];
+
+	if (ppos != &file->f_pos)
+		return -ESPIPE;
+
+	memset(cmd, 0, sizeof(cmd));
+	if (copy_from_user(cmd, buffer, sizeof(cmd)))
+		return -EFAULT;
+
+	if (strncmp(cmd, "clear", 5))
+		return count;
+
+	call_on_cpu(wait->cpu, salinfo_log_clear_cpu, wait);
+	return count;
+}
+
+static unsigned int
+salinfo_log_poll(struct file *file, poll_table *polltab)
+{
+	struct inode *inode = file->f_dentry->d_inode;
+	struct proc_dir_entry *entry = (struct proc_dir_entry *) inode->u.generic_ip;
+	struct salinfo_wait_queue *wait = entry->data;
+	unsigned int mask;
+
+	poll_wait(file, &wait->queue, polltab);
+	mask = POLLOUT | POLLWRNORM;
+	if (wait->event_ready)
+		mask |= POLLIN | POLLRDNORM;
+	return mask;
+}
+
+static struct file_operations salinfo_log_fops = {
+	.open  = salinfo_log_open,
+	.read  = salinfo_log_read,
+	.write = salinfo_log_write,
+	.poll  = salinfo_log_poll,
+};
 
 static int __init
 salinfo_init(void)
 {
 	struct proc_dir_entry *salinfo_dir; /* /proc/sal dir entry */
 	struct proc_dir_entry **sdir = salinfo_proc_entries; /* keeps track of every entry */
-	int i;
+	struct proc_dir_entry *cpu_dir, *entry;
+	struct salinfo_wait_queue *wait;
+#define CPUSTR "cpu%d"
+	char name[sizeof(CPUSTR)];
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
+	for (i = 0; i < NR_CPUS; i++) {
+		if (!cpu_online(i))
+			continue;
+
+		sprintf(name, CPUSTR, i);
+		cpu_dir = proc_mkdir(name, salinfo_dir);
+		if (!cpu_dir)
+			continue;
+
+		for (j = 0; j < ARRAY_SIZE(salinfo_log_name); j++) {
+			wait = kmalloc(sizeof(*wait), GFP_KERNEL);
+			if (!wait)
+				continue;
+
+			entry = create_proc_entry(salinfo_log_name[j], 0, cpu_dir);
+			if (entry) {
+				wait->cpu = i;
+				wait->type = j;
+				wait->event_ready = 1;	/* assume we missed one */
+				init_waitqueue_head(&wait->queue);
+				salinfo_wait[i][j] = wait;
+				entry->data = wait;
+				entry->proc_fops = &salinfo_log_fops;
+				*sdir++ = entry;
+			}
+		}
+		*sdir++ = cpu_dir;
+	}
+
 	*sdir++ = salinfo_dir;
 
 	return 0;
@@ -69,7 +285,7 @@
 {
 	int i = 0;
 
-	for (i = 0; i < NR_SALINFO_ENTRIES ; i++) {
+	for (i = 0; i < ARRAY_SIZE(salinfo_proc_entries); i++) {
 		if (salinfo_proc_entries[i])
 			remove_proc_entry (salinfo_proc_entries[i]->name, NULL);
 	}


--Boundary-00=_KWU1+nMESWMfvml
Content-Type: application/x-tgz;
  name="salinfo-0.1.tar.gz"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="salinfo-0.1.tar.gz"

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

--Boundary-00=_KWU1+nMESWMfvml--


