From: Mark Goodwin <markgw@sgi.com>
Date: Mon, 06 Sep 2004 04:48:44 +0000
Subject: Re: [PATCH resent] arch/ia64/sn: use seq_file in sn_proc_fs.c
Message-Id: <Pine.LNX.4.44.0409061428400.29636-100000@woolami.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.44.0409031150050.4971-100000@woolami.melbourne.sgi.com>
In-Reply-To: <Pine.LNX.4.44.0409031150050.4971-100000@woolami.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 3 Sep 2004, Randy.Dunlap wrote:

> On Fri, 3 Sep 2004 12:05:49 +1000 (EST) Mark Goodwin wrote:
> | ---
> | 
> | --- 2.6.8-rc2/arch/ia64/sn/kernel/sn2/sn_proc_fs.c	Tue Aug 17 11:45:18 2004
> | +++ 2.6.8-rc2-seq_file/arch/ia64/sn/kernel/sn2/sn_proc_fs.c	Wed Aug 18 07:22:24 2004
> 
> Hi-
> This no longer applies cleanly to current tree (2.6.9-rc1 or -mm3).

ok, I've redone the patch against 2.6.9-rc1 (actually top-of-tree bk),
see below.

> Please use tabs instead of spaces...

ok

> Have you run any of this thru sparse?

No I hadn't, but have now. Using sparse from 
http://www.codemonkey.org.uk/projects/bitkeeper/sparse/sparse-2004-09-05.tar.gz

It complains about all sorts of stuff in headers I'm including, but
apparently no complaints in sn_proc_fs.c itself.

> It may be clean as is, but I thought that I saw a couple of
> questionable items in it.
> 
> Thanks,
> --
> ~Randy

Thanks for the review .. which items were questionable? Here's the revised
patch for your consideration.

    Thanks
    -- Mark

convert arch/ia64/sn/kernel/sn2/sn_proc_fs.c to use the seq_file API
Signed-off-by: Mark Goodwin <markgw@sgi.com>
---

--- linux-2.6-9-rc2/arch/ia64/sn/kernel/sn2/sn_proc_fs.c	Mon Sep  6 12:09:40 2004
+++ linux-2.6-9-rc2-seq_file/arch/ia64/sn/kernel/sn2/sn_proc_fs.c	Mon Sep  6 13:16:35 2004
@@ -10,67 +10,41 @@
 
 #ifdef CONFIG_PROC_FS
 #include <linux/proc_fs.h>
+#include <linux/seq_file.h>
 #include <asm/sn/sgi.h>
 #include <asm/sn/sn_sal.h>
 
-
-static int partition_id_read_proc(char *page, char **start, off_t off,
-		int count, int *eof, void *data) {
-
-	return sprintf(page, "%d\n", sn_local_partid());
+static int partition_id_show(struct seq_file *s, void *p)
+{
+	seq_printf(s, "%d\n", sn_local_partid());
+	return 0;
 }
 
-static struct proc_dir_entry * sgi_proc_dir;
-
-void
-register_sn_partition_id(void) {
-	struct proc_dir_entry *entry;
-
-	if (!sgi_proc_dir) {
-		sgi_proc_dir = proc_mkdir("sgi_sn", 0);
-	}
-	entry = create_proc_entry("partition_id", 0444, sgi_proc_dir);
-	if (entry) {
-		entry->nlink = 1;
-		entry->data = 0;
-		entry->read_proc = partition_id_read_proc;
-		entry->write_proc = NULL;
-	}
+static int partition_id_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, partition_id_show, NULL);
 }
 
-static int
-system_serial_number_read_proc(char *page, char **start, off_t off,
-		int count, int *eof, void *data) {
-	return sprintf(page, "%s\n", sn_system_serial_number());
+static int system_serial_number_show(struct seq_file *s, void *p)
+{
+	seq_printf(s, "%s\n", sn_system_serial_number());
+	return 0;
 }
 
-static int
-licenseID_read_proc(char *page, char **start, off_t off,
-		int count, int *eof, void *data) {
-	return sprintf(page, "0x%lx\n",sn_partition_serial_number_val());
+static int system_serial_number_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, system_serial_number_show, NULL);
 }
 
-void
-register_sn_serial_numbers(void) {
-	struct proc_dir_entry *entry;
+static int licenseID_show(struct seq_file *s, void *p)
+{
+	seq_printf(s, "0x%lx\n", sn_partition_serial_number_val());
+	return 0;
+}
 
-	if (!sgi_proc_dir) {
-		sgi_proc_dir = proc_mkdir("sgi_sn", 0);
-	}
-	entry = create_proc_entry("system_serial_number", 0444, sgi_proc_dir);
-	if (entry) {
-		entry->nlink = 1;
-		entry->data = 0;
-		entry->read_proc = system_serial_number_read_proc;
-		entry->write_proc = NULL;
-	}
-	entry = create_proc_entry("licenseID", 0444, sgi_proc_dir);
-	if (entry) {
-		entry->nlink = 1;
-		entry->data = 0;
-		entry->read_proc = licenseID_read_proc;
-		entry->write_proc = NULL;
-	}
+static int licenseID_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, licenseID_show, NULL);
 }
 
 /*
@@ -81,70 +55,83 @@
  */
 int sn_force_interrupt_flag = 1;
 
-static int
-sn_force_interrupt_read_proc(char *page, char **start, off_t off,
-		int count, int *eof, void *data) {
-	if (sn_force_interrupt_flag) {
-		return sprintf(page, "Force interrupt is enabled\n");
-	}
-	return sprintf(page, "Force interrupt is disabled\n");
+static int sn_force_interrupt_show(struct seq_file *s, void *p)
+{
+	seq_printf(s, "Force interrupt is %s\n",
+		sn_force_interrupt_flag ? "enabled" : "disabled");
+	return 0;
 }
 
-static int 
-sn_force_interrupt_write_proc(struct file *file, const char *buffer,
-                                        unsigned long count, void *data)
+static ssize_t sn_force_interrupt_write_proc(struct file *file,
+		const __user char *buffer, size_t count, loff_t *data)
 {
-	if (*buffer = '0') {
-		sn_force_interrupt_flag = 0;
-	} else {
-		sn_force_interrupt_flag = 1;
-	}
-	return 1;
+	sn_force_interrupt_flag = (*buffer = '0') ? 0 : 1;
+	return count;
 }
 
-void
-register_sn_force_interrupt(void) {
-	struct proc_dir_entry *entry;
+static int sn_force_interrupt_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, sn_force_interrupt_show, NULL);
+}
 
-	if (!sgi_proc_dir) {
-		sgi_proc_dir = proc_mkdir("sgi_sn", 0);
-	}
-	entry = create_proc_entry("sn_force_interrupt",0444, sgi_proc_dir);
-	if (entry) {
-		entry->nlink = 1;
-		entry->data = 0;
-		entry->read_proc = sn_force_interrupt_read_proc;
-		entry->write_proc = sn_force_interrupt_write_proc;
-	}
+static int coherence_id_show(struct seq_file *s, void *p)
+{
+	seq_printf(s, "%d\n", cpuid_to_coherence_id(smp_processor_id()));
+	return 0;
 }
 
-static int coherence_id_read_proc(char *page, char **start, off_t off,
-		int count, int *eof, void *data) {
-	return sprintf(page, "%d\n", cpuid_to_coherence_id(smp_processor_id()));
+static int coherence_id_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, coherence_id_show, NULL);
 }
 
-void
-register_sn_coherence_id(void) {
-	struct proc_dir_entry *entry;
+static struct proc_dir_entry *sn_procfs_create_entry(
+	const char *name, struct proc_dir_entry *parent,
+	int (*openfunc)(struct inode *, struct file *),
+	int (*releasefunc)(struct inode *, struct file *))
+{
+	struct proc_dir_entry *e = create_proc_entry(name, 0444, parent);
 
-	if (!sgi_proc_dir) {
-		sgi_proc_dir = proc_mkdir("sgi_sn", 0);
-	}
-	entry = create_proc_entry("coherence_id", 0444, sgi_proc_dir);
-	if (entry) {
-		entry->nlink = 1;
-		entry->data = 0;
-		entry->read_proc = coherence_id_read_proc;
-		entry->write_proc = NULL;
+	if (e) {
+		e->proc_fops = (struct file_operations *)kmalloc(
+			sizeof(struct file_operations), GFP_KERNEL);
+		if (e->proc_fops) {
+			memset(e->proc_fops, 0, sizeof(struct file_operations));
+			e->proc_fops->open = openfunc;
+			e->proc_fops->read = seq_read;
+			e->proc_fops->llseek = seq_lseek;
+			e->proc_fops->release = releasefunc;
+		}
 	}
+
+	return e;
 }
 
-void
-register_sn_procfs(void) {
-	register_sn_partition_id();
-	register_sn_serial_numbers();
-	register_sn_force_interrupt();
-	register_sn_coherence_id();
+void register_sn_procfs(void)
+{
+	static struct proc_dir_entry *sgi_proc_dir = NULL;
+	struct proc_dir_entry *e;
+
+	BUG_ON(sgi_proc_dir != NULL);
+	if (!(sgi_proc_dir = proc_mkdir("sgi_sn", 0)))
+		return;
+
+	sn_procfs_create_entry("partition_id", sgi_proc_dir,
+		partition_id_open, single_release);
+
+	sn_procfs_create_entry("system_serial_number", sgi_proc_dir,
+		system_serial_number_open, single_release);
+
+	sn_procfs_create_entry("licenseID", sgi_proc_dir, 
+		licenseID_open, single_release);
+
+	e = sn_procfs_create_entry("sn_force_interrupt", sgi_proc_dir, 
+		sn_force_interrupt_open, single_release);
+	if (e) 
+		e->proc_fops->write = sn_force_interrupt_write_proc;
+
+	sn_procfs_create_entry("coherence_id", sgi_proc_dir, 
+		coherence_id_open, single_release);
 }
 
 #endif /* CONFIG_PROC_FS */

