From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Mon, 28 Apr 2003 20:51:34 +0000
Subject: [Linux-ia64] [PATCH] 2.5 use seq_file for sba_iommu /proc files
Message-Id: <marc-linux-ia64-105590723705618@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch against 2.5.67 changes sba_iommu to use the seq_file
interfaces for /proc files.  This is needed because current
machines may have up to 32 IOCs, which will generate more
than 300K of data.

Bjorn


diff -u -r linux-2.5.67-ia64-030416-io6/arch/ia64/hp/common/sba_iommu.c linux-2.5.67-ia64-030416-io7/arch/ia64/hp/common/sba_iommu.c
--- linux-2.5.67-ia64-030416-io6/arch/ia64/hp/common/sba_iommu.c	2003-04-24 16:29:11.000000000 -0600
+++ linux-2.5.67-ia64-030416-io7/arch/ia64/hp/common/sba_iommu.c	2003-04-28 12:36:47.000000000 -0600
@@ -30,6 +30,7 @@
 #include <linux/string.h>
 #include <linux/pci.h>
 #include <linux/proc_fs.h>
+#include <linux/seq_file.h>
 #include <linux/acpi.h>
 #include <linux/efi.h>
 
@@ -1712,25 +1713,52 @@
 **************************************************************************/
 
 #ifdef CONFIG_PROC_FS
+static void *
+ioc_start(struct seq_file *s, loff_t *pos)
+{
+	struct ioc *ioc;
+	loff_t n = *pos;
+
+	for (ioc = ioc_list; ioc; ioc = ioc->next)
+		if (!n--)
+			return ioc;
+
+	return NULL;
+}
+
+static void *
+ioc_next(struct seq_file *s, void *v, loff_t *pos)
+{
+	struct ioc *ioc = v;
+
+	++*pos;
+	return ioc->next;
+}
+
+static void
+ioc_stop(struct seq_file *s, void *v)
+{
+}
+
 static int
-sba_proc_info_one(char *buf, struct ioc *ioc)
+ioc_show(struct seq_file *s, void *v)
 {
+	struct ioc *ioc = v;
 	int total_pages = (int) (ioc->res_size << 3); /* 8 bits per byte */
 	unsigned long i = 0, avg = 0, min, max;
 
-	sprintf(buf, "Hewlett Packard %s IOC rev %d.%d\n",
+	seq_printf(s, "Hewlett Packard %s IOC rev %d.%d\n",
 		ioc->name, ((ioc->rev >> 4) & 0xF), (ioc->rev & 0xF));
-	sprintf(buf, "%sIO PDIR size    : %d bytes (%d entries)\n",
-		buf,
+	seq_printf(s, "IO PDIR size    : %d bytes (%d entries)\n",
 		(int) ((ioc->res_size << 3) * sizeof(u64)), /* 8 bits/byte */
 		total_pages);
 
-	sprintf(buf, "%sIO PDIR entries : %ld free  %ld used (%d%%)\n", buf,
+	seq_printf(s, "IO PDIR entries : %ld free  %ld used (%d%%)\n",
 		total_pages - ioc->used_pages, ioc->used_pages,
 		(int) (ioc->used_pages * 100 / total_pages));
 
-	sprintf(buf, "%sResource bitmap : %d bytes (%d pages)\n",
-		buf, ioc->res_size, ioc->res_size << 3);   /* 8 bits per byte */
+	seq_printf(s, "Resource bitmap : %d bytes (%d pages)\n",
+		ioc->res_size, ioc->res_size << 3);   /* 8 bits per byte */
 
 	min = max = ioc->avg_search[0];
 	for (i = 0; i < SBA_SEARCH_SAMPLE; i++) {
@@ -1739,92 +1767,105 @@
 		if (ioc->avg_search[i] < min) min = ioc->avg_search[i];
 	}
 	avg /= SBA_SEARCH_SAMPLE;
-	sprintf(buf, "%s  Bitmap search : %ld/%ld/%ld (min/avg/max CPU Cycles)\n",
-		buf, min, avg, max);
+	seq_printf(s, "  Bitmap search : %ld/%ld/%ld (min/avg/max CPU Cycles)\n",
+		min, avg, max);
 
-	sprintf(buf, "%spci_map_single(): %12ld calls  %12ld pages (avg %d/1000)\n",
-		buf, ioc->msingle_calls, ioc->msingle_pages,
+	seq_printf(s, "pci_map_single(): %12ld calls  %12ld pages (avg %d/1000)\n",
+		ioc->msingle_calls, ioc->msingle_pages,
 		(int) ((ioc->msingle_pages * 1000)/ioc->msingle_calls));
 #ifdef ALLOW_IOV_BYPASS
-	sprintf(buf, "%spci_map_single(): %12ld bypasses\n",
-	        buf, ioc->msingle_bypass);
+	seq_printf(s, "pci_map_single(): %12ld bypasses\n", ioc->msingle_bypass);
 #endif
 
-	sprintf(buf, "%spci_unmap_single: %12ld calls  %12ld pages (avg %d/1000)\n",
-		buf, ioc->usingle_calls, ioc->usingle_pages,
+	seq_printf(s, "pci_unmap_single: %12ld calls  %12ld pages (avg %d/1000)\n",
+		ioc->usingle_calls, ioc->usingle_pages,
 		(int) ((ioc->usingle_pages * 1000)/ioc->usingle_calls));
 #ifdef ALLOW_IOV_BYPASS
-	sprintf(buf, "%spci_unmap_single: %12ld bypasses\n",
-	        buf, ioc->usingle_bypass);
+	seq_printf(s, "pci_unmap_single: %12ld bypasses\n", ioc->usingle_bypass);
 #endif
 
-	sprintf(buf, "%spci_map_sg()    : %12ld calls  %12ld pages (avg %d/1000)\n",
-		buf, ioc->msg_calls, ioc->msg_pages,
+	seq_printf(s, "pci_map_sg()    : %12ld calls  %12ld pages (avg %d/1000)\n",
+		ioc->msg_calls, ioc->msg_pages,
 		(int) ((ioc->msg_pages * 1000)/ioc->msg_calls));
 #ifdef ALLOW_IOV_BYPASS
-	sprintf(buf, "%spci_map_sg()    : %12ld bypasses\n",
-	        buf, ioc->msg_bypass);
+	seq_printf(s, "pci_map_sg()    : %12ld bypasses\n", ioc->msg_bypass);
 #endif
 
-	sprintf(buf, "%spci_unmap_sg()  : %12ld calls  %12ld pages (avg %d/1000)\n",
-		buf, ioc->usg_calls, ioc->usg_pages,
+	seq_printf(s, "pci_unmap_sg()  : %12ld calls  %12ld pages (avg %d/1000)\n",
+		ioc->usg_calls, ioc->usg_pages,
 		(int) ((ioc->usg_pages * 1000)/ioc->usg_calls));
 
-	return strlen(buf);
+	return 0;
 }
 
+static struct seq_operations ioc_seq_ops = {
+	.start = ioc_start,
+	.next  = ioc_next,
+	.stop  = ioc_stop,
+	.show  = ioc_show
+};
+
 static int
-sba_proc_info(char *buf, char **start, off_t offset, int len)
+ioc_open(struct inode *inode, struct file *file)
 {
-	struct ioc *ioc;
-	char *base = buf;
-
-	for (ioc = ioc_list; ioc; ioc = ioc->next) {
-		buf += sba_proc_info_one(buf, ioc);
-	}
-
-	return strlen(base);
+	return seq_open(file, &ioc_seq_ops);
 }
 
+static struct file_operations ioc_fops = {
+	.open    = ioc_open,
+	.read    = seq_read,
+	.llseek  = seq_lseek,
+	.release = seq_release
+};
+
 static int
-sba_resource_map_one(char *buf, struct ioc *ioc)
+ioc_map_show(struct seq_file *s, void *v)
 {
+	struct ioc *ioc = v;
 	unsigned int *res_ptr = (unsigned int *)ioc->res_map;
 	int i;
 
-	buf[0] = '\0';
-	for(i = 0; i < (ioc->res_size / sizeof(unsigned int)); ++i, ++res_ptr) {
-		if ((i & 7) = 0)
-		    strcat(buf,"\n   ");
-		sprintf(buf, "%s %08x", buf, *res_ptr);
-	}
-	strcat(buf, "\n");
+	for (i = 0; i < (ioc->res_size / sizeof(unsigned int)); ++i, ++res_ptr)
+		seq_printf(s, "%s%08x", (i & 7) ? " " : "\n   ", *res_ptr);
+	seq_printf(s, "\n");
 
-	return strlen(buf);
+	return 0;
 }
 
+static struct seq_operations ioc_map_ops = {
+	.start = ioc_start,
+	.next  = ioc_next,
+	.stop  = ioc_stop,
+	.show  = ioc_map_show
+};
+
 static int
-sba_resource_map(char *buf, char **start, off_t offset, int len)
+ioc_map_open(struct inode *inode, struct file *file)
 {
-	struct ioc *ioc;
-	char *base = buf;
-
-	for (ioc = ioc_list; ioc; ioc = ioc->next) {
-		buf += sba_resource_map_one(buf, ioc);
-	}
-
-	return strlen(base);
+	return seq_open(file, &ioc_map_ops);
 }
 
+static struct file_operations ioc_map_fops = {
+	.open    = ioc_map_open,
+	.read    = seq_read,
+	.llseek  = seq_lseek,
+	.release = seq_release
+};
+
 static void __init
-sba_proc_init(void)
+ioc_proc_init(void)
 {
 	if (ioc_list) {
-		struct proc_dir_entry * proc_mckinley_root;
+		struct proc_dir_entry *dir, *entry;
 
-		proc_mckinley_root = proc_mkdir("bus/mckinley",0);
-		create_proc_info_entry(ioc_list->name, 0, proc_mckinley_root, sba_proc_info);
-		create_proc_info_entry("bitmap", 0, proc_mckinley_root, sba_resource_map);
+		dir = proc_mkdir("bus/mckinley", 0);
+		entry = create_proc_entry(ioc_list->name, 0, dir);
+		if (entry)
+			entry->proc_fops = &ioc_fops;
+
+		entry = create_proc_entry("bitmap", 0, dir);
+		if (entry)
+			entry->proc_fops = &ioc_map_fops;
 	}
 }
 #endif
@@ -1915,7 +1956,7 @@
 		sba_connect_bus(b);
 
 #ifdef CONFIG_PROC_FS
-	sba_proc_init();
+	ioc_proc_init();
 #endif
 	return 0;
 }


