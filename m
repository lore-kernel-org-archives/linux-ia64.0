From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Wed, 07 May 2003 23:41:08 +0000
Subject: [Linux-ia64] SAL error record logging/decoding
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_UmZu+FMOzk5r0lJ"
Message-Id: <marc-linux-ia64-105590723705660@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--Boundary-00=_UmZu+FMOzk5r0lJ
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

The MCA/INIT/CMC/CPE log decoding currently in arch/ia64/kernel/mca.c
has some problems:

	- It doesn't know much about OEM-specific sections.
	- At boot-time, it sometimes takes so long to print
	  the log to the console that the BSP erroneously
	  assumes an AP is stuck.  This sometimes causes
	  *another* MCA.
	- The log goes ONLY to the console, where the output
	  may be lost.

So here's some fodder for discussion.  I don't claim that this is ready
for prime time; I just want to get some feedback on whether this
is a reasonable approach.

The attached patch (against 2.4.21-rc1) makes the raw, binary
error records straight from SAL available via files in /proc:

	/proc/sal/cpu<n>/{mca,init,cmc,cpe}

If you read the file, you get the raw data.  If you write "clear" to
it, you invalidate the current error record (which as I read the spec,
may potentially make another, pending record available to be read).

The idea is that

	- An rc script run at boot-time can save all the logs in
	  files, clearing each afterwards.
	- A user-level analysis tool can decode them as needed
	  (perhaps also run from the same rc script above).
	- The user-level analyzer need not be open-source, if
	  people are worried about IP in the OEM-specific sections.
	- A baseline open-source analyzer can provide at least the
	  functionality available today in the kernel decoder.

So, attached are the kernel patch against 2.4.21-rc1 and a simple
user program ("salinfo") to decode the logs.  Note that the kernel
patch removes the SAL clear_state_info calls from mca.c, so the error
records will be preserved until the user program can read them.
This feels like the right thing to me (only a user program
can know that the logs have been saved somewhere safe), but
no doubt there are issues here.

The user-space analyzer is derived from the current kernel code
in mca.c and should produce identical output.  For now, I left
all the code in the kernel as well, but ultimately it could be
removed.

Bjorn

--Boundary-00=_UmZu+FMOzk5r0lJ
Content-Type: text/x-diff;
  charset="us-ascii";
  name="diffs"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="diffs"

===== arch/ia64/kernel/mca.c 1.23 vs edited =====
--- 1.23/arch/ia64/kernel/mca.c	Fri Apr 18 04:07:09 2003
+++ edited/arch/ia64/kernel/mca.c	Fri May  2 11:24:15 2003
@@ -156,10 +156,6 @@
 	 */
 
 	platform_err = ia64_log_print(sal_info_type, (prfunc_t)printk);
-	/* temporary: only clear SAL logs on hardware-corrected errors
-		or if we're logging an error after an MCA-initiated reboot */
-	if ((sal_info_type > 1) || (called_from_init))
-		ia64_sal_clear_state_info(sal_info_type);
 
 	return platform_err;
 }
@@ -1235,9 +1231,6 @@
 	proc_ptr = &plog_ptr->proc_err;
 
 	ia64_process_min_state_save(&SAL_LPI_PSI_INFO(proc_ptr)->min_state_area);
-
-	/* Clear the INIT SAL logs now that they have been saved in the OS buffer */
-	ia64_sal_clear_state_info(SAL_INFO_TYPE_INIT);
 
 	init_handler_platform(proc_ptr, pt, sw);	/* call platform specific routines */
 }
===== arch/ia64/kernel/salinfo.c 1.1 vs edited =====
--- 1.1/arch/ia64/kernel/salinfo.c	Thu Sep 12 10:43:47 2002
+++ edited/arch/ia64/kernel/salinfo.c	Tue May  6 14:53:28 2003
@@ -4,6 +4,8 @@
  * Creates entries in /proc/sal for various system features.
  *
  * Copyright (c) 2001 Silicon Graphics, Inc.  All rights reserved.
+ * Copyright (c) 2003 Hewlett-Packard Co
+ *	Bjorn Helgaas <bjorn_helgaas@hp.com>
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
@@ -40,25 +44,191 @@
 
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
+static void
+salinfo_log_read_cpu(void *context)
+{
+	struct salinfo_log_data *info = context;
+	u64 size;
+
+	size = ia64_sal_get_state_info_size(info->type);
+	info->log_buffer = kmalloc(size, GFP_ATOMIC);
+	if (!info->log_buffer)
+		return;
+
+	info->log_size = ia64_sal_get_state_info(info->type, (u64 *) info->log_buffer);
+}
+
+static ssize_t
+salinfo_log_read(struct file *file, char *buffer, size_t count, loff_t *ppos)
+{
+	struct inode *inode = file->f_dentry->d_inode;
+	struct proc_dir_entry *entry = (struct proc_dir_entry *) inode->u.generic_ip;
+	struct salinfo_log_data info;
+	int cpu, ret;
+	void *data;
+	size_t size;
+
+	if (!suser())
+		return -EPERM;
+
+	MOD_INC_USE_COUNT;
+
+	cpu = (u64) entry->data >> 16;
+	info.type = (u64) entry->data & 0xffff;
+
+	if (cpu == smp_processor_id())
+		salinfo_log_read_cpu(&info);
+	else {
+#ifdef CONFIG_SMP
+		smp_call_function_single(cpu, salinfo_log_read_cpu, &info, 0, 1);
+#else
+		printk(KERN_ERR "%s: trying to read CPU %d data from %d\n",
+			__FUNCTION__, cpu, smp_processor_id());
+		info.log_buffer = 0;
+#endif
+	}
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
+
+	MOD_DEC_USE_COUNT;
+
+	return ret;
+}
+
+static void
+salinfo_log_write_cpu(void *context)
+{
+	u64 type = (u64) context;
+
+	ia64_sal_clear_state_info(type);
+}
+
+static ssize_t
+salinfo_log_write(struct file *file, const char *buffer, size_t count, loff_t *ppos)
+{
+	struct inode *inode = file->f_dentry->d_inode;
+	struct proc_dir_entry *entry = (struct proc_dir_entry *) inode->u.generic_ip;
+	char cmd[16];
+	int cpu;
+	u64 type;
+
+	if (!suser())
+		return -EPERM;
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
+	MOD_INC_USE_COUNT;
+
+	cpu = (u64) entry->data >> 16;
+	type = (u64) entry->data & 0xffff;
+
+	if (cpu == smp_processor_id())
+		salinfo_log_write_cpu((void *) type);
+	else {
+#ifdef CONFIG_SMP
+		smp_call_function_single(cpu, salinfo_log_write_cpu, (void *) type, 0, 1);
+#else
+		printk(KERN_ERR "%s: trying to clear CPU %d data from %d\n",
+			__FUNCTION__, cpu, smp_processor_id());
+#endif
+	}
+
+	MOD_DEC_USE_COUNT;
+
+	return count;
+}
+
+static struct file_operations salinfo_log_fops = {
+	.read  = salinfo_log_read,
+	.write = salinfo_log_write,
+};
 
 static int __init
 salinfo_init(void)
 {
 	struct proc_dir_entry *salinfo_dir; /* /proc/sal dir entry */
 	struct proc_dir_entry **sdir = salinfo_proc_entries; /* keeps track of every entry */
-	int i;
+	struct proc_dir_entry *cpu_dir, *entry;
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
+			entry = create_proc_entry(salinfo_log_name[j], 0, cpu_dir);
+			if (entry) {
+				entry->proc_fops = &salinfo_log_fops;
+				entry->data = (void *) ((u64) i << 16 | j);
+				*sdir++ = entry;
+			}
+		}
+		*sdir++ = cpu_dir;
+	}
+
 	*sdir++ = salinfo_dir;
 
 	return 0;
@@ -69,7 +239,7 @@
 {
 	int i = 0;
 
-	for (i = 0; i < NR_SALINFO_ENTRIES ; i++) {
+	for (i = 0; i < ARRAY_SIZE(salinfo_proc_entries); i++) {
 		if (salinfo_proc_entries[i])
 			remove_proc_entry (salinfo_proc_entries[i]->name, NULL);
 	}

--Boundary-00=_UmZu+FMOzk5r0lJ
Content-Type: application/x-tgz;
  name="salinfo.tar.gz"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="salinfo.tar.gz"

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

--Boundary-00=_UmZu+FMOzk5r0lJ--


