From: Mark Goodwin <markgw@sgi.com>
Date: Fri, 03 Sep 2004 02:05:49 +0000
Subject: [PATCH resent] arch/ia64/sn: use seq_file in sn_proc_fs.c
Message-Id: <Pine.LNX.4.44.0409031150050.4971-100000@woolami.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


convert arch/ia64/sn/kernel/sn2/sn_proc_fs.c to use the seq_file API

Signed-off-by: Mark Goodwin <markgw@sgi.com>
---

--- 2.6.8-rc2/arch/ia64/sn/kernel/sn2/sn_proc_fs.c	Tue Aug 17 11:45:18 2004
+++ 2.6.8-rc2-seq_file/arch/ia64/sn/kernel/sn2/sn_proc_fs.c	Wed Aug 18 07:22:24 2004
@@ -10,52 +10,41 @@
 
 #ifdef CONFIG_PROC_FS
 #include <linux/proc_fs.h>
+#include <linux/seq_file.h>
 #include <asm/sn/sgi.h>
 #include <asm/sn/sn_sal.h>
 
-
-static struct proc_dir_entry *sgi_proc_dir;
-
-static int partition_id_read_proc(char *page, char **start, off_t off,
-				  int count, int *eof, void *data)
+static int partition_id_show(struct seq_file *s, void *p)
 {
-	return sprintf(page, "%d\n", sn_local_partid());
+	seq_printf(s, "%d\n", sn_local_partid());
+	return 0;
 }
 
-static void register_sn_partition_id(void)
+static int partition_id_open(struct inode *inode, struct file *file)
 {
-	struct proc_dir_entry *entry;
-
-	entry = create_proc_entry("partition_id", 0444, sgi_proc_dir);
-	if (entry) {
-		entry->read_proc = partition_id_read_proc;
-	}
+        return single_open(file, partition_id_show, NULL);
 }
 
-static int system_serial_number_read_proc(char *page, char **start, off_t off,
-					  int count, int *eof, void *data)
+static int system_serial_number_show(struct seq_file *s, void *p)
 {
-	return sprintf(page, "%s\n", sn_system_serial_number());
+	seq_printf(s, "%s\n", sn_system_serial_number());
+	return 0;
 }
 
-static int licenseID_read_proc(char *page, char **start, off_t off,
-			       int count, int *eof, void *data)
+static int system_serial_number_open(struct inode *inode, struct file *file)
 {
-	return sprintf(page, "0x%lx\n", sn_partition_serial_number_val());
+        return single_open(file, system_serial_number_show, NULL);
 }
 
-static void register_sn_serial_numbers(void)
+static int licenseID_show(struct seq_file *s, void *p)
 {
-	struct proc_dir_entry *entry;
+	seq_printf(s, "0x%lx\n", sn_partition_serial_number_val());
+	return 0;
+}
 
-	entry = create_proc_entry("system_serial_number", 0444, sgi_proc_dir);
-	if (entry) {
-		entry->read_proc = system_serial_number_read_proc;
-	}
-	entry = create_proc_entry("licenseID", 0444, sgi_proc_dir);
-	if (entry) {
-		entry->read_proc = licenseID_read_proc;
-	}
+static int licenseID_open(struct inode *inode, struct file *file)
+{
+        return single_open(file, licenseID_show, NULL);
 }
 
 /*
@@ -66,64 +55,88 @@
  */
 int sn_force_interrupt_flag = 1;
 
-static int sn_force_interrupt_read_proc(char *page, char **start, off_t off,
-					int count, int *eof, void *data)
+static int sn_force_interrupt_show(struct seq_file *s, void *p)
 {
-	if (sn_force_interrupt_flag) {
-		return sprintf(page, "Force interrupt is enabled\n");
-	}
-	return sprintf(page, "Force interrupt is disabled\n");
+	seq_printf(s, "Force interrupt is %s\n", 
+		sn_force_interrupt_flag ? "enabled" : "disabled");
+	return 0;
 }
 
-static int sn_force_interrupt_write_proc(struct file *file, const char *buffer,
-					 unsigned long count, void *data)
+static ssize_t sn_force_interrupt_write_proc(struct file *file,
+		 const __user char *buffer, size_t count, loff_t *data)
 {
 	if (*buffer = '0') {
 		sn_force_interrupt_flag = 0;
 	} else {
 		sn_force_interrupt_flag = 1;
 	}
-	return 1;
+
+	return count;
 }
 
-static void register_sn_force_interrupt(void)
+static int sn_force_interrupt_open(struct inode *inode, struct file *file)
 {
-	struct proc_dir_entry *entry;
+        return single_open(file, sn_force_interrupt_show, NULL);
+}
 
-	entry = create_proc_entry("sn_force_interrupt", 0444, sgi_proc_dir);
-	if (entry) {
-		entry->read_proc = sn_force_interrupt_read_proc;
-		entry->write_proc = sn_force_interrupt_write_proc;
-	}
+static int coherence_id_show(struct seq_file *s, void *p)
+{
+	seq_printf(s, "%d\n", cpuid_to_coherence_id(smp_processor_id()));
+	return 0;
 }
 
-static int coherence_id_read_proc(char *page, char **start, off_t off,
-				  int count, int *eof, void *data)
+static int coherence_id_open(struct inode *inode, struct file *file)
 {
-	return sprintf(page, "%d\n", cpuid_to_coherence_id(smp_processor_id()));
+        return single_open(file, coherence_id_show, NULL);
 }
 
-static void register_sn_coherence_id(void)
+static struct proc_dir_entry *sn_procfs_create_entry(
+	const char *name, struct proc_dir_entry *parent,
+	int (*openfunc)(struct inode *, struct file *),
+	int (*releasefunc)(struct inode *, struct file *))
 {
-	struct proc_dir_entry *entry;
+        struct proc_dir_entry *e = create_proc_entry(name, 0444, parent);
 
-	entry = create_proc_entry("coherence_id", 0444, sgi_proc_dir);
-	if (entry) {
-		entry->read_proc = coherence_id_read_proc;
+        if (e) {
+		e->proc_fops = (struct file_operations *)kmalloc(
+				sizeof(struct file_operations), GFP_KERNEL);
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
 
 void register_sn_procfs(void)
 {
-	sgi_proc_dir = proc_mkdir("sgi_sn", 0);
-	if (!sgi_proc_dir) {
+	static struct proc_dir_entry *sgi_proc_dir = NULL;
+	struct proc_dir_entry *e;
+
+	BUG_ON(sgi_proc_dir != NULL);
+	if (!(sgi_proc_dir = proc_mkdir("sgi_sn", 0)))
 		return;
-	}
 
-	register_sn_partition_id();
-	register_sn_serial_numbers();
-	register_sn_force_interrupt();
-	register_sn_coherence_id();
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



