From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Fri, 19 Sep 2003 21:20:47 +0000
Subject: [PATCH] bail out of sba_init() if no hardware found
Message-Id: <marc-linux-ia64-106400656632465@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch against 2.5 gets rid of the following annoying but
harmless messages when booting a generic kernel on a non-ZX1 box:

	No IOC for PCI Bus 0000:00 in ACPI
	No IOC for PCI Bus 0000:01 in ACPI
	...

We just forgot to bail out of the SBA IOMMU init function if it didn't
find any SBA hardware.

=== arch/ia64/hp/common/sba_iommu.c 1.30 vs edited ==--- 1.30/arch/ia64/hp/common/sba_iommu.c	Mon Sep  8 14:51:17 2003
+++ edited/arch/ia64/hp/common/sba_iommu.c	Fri Sep 19 15:03:40 2003
@@ -1844,18 +1844,19 @@
 static void __init
 ioc_proc_init(void)
 {
-	if (ioc_list) {
-		struct proc_dir_entry *dir, *entry;
+	struct proc_dir_entry *dir, *entry;
 
-		dir = proc_mkdir("bus/mckinley", 0);
-		entry = create_proc_entry(ioc_list->name, 0, dir);
-		if (entry)
-			entry->proc_fops = &ioc_fops;
-
-		entry = create_proc_entry("bitmap", 0, dir);
-		if (entry)
-			entry->proc_fops = &ioc_map_fops;
-	}
+	dir = proc_mkdir("bus/mckinley", 0);
+	if (!dir)
+		return;
+
+	entry = create_proc_entry(ioc_list->name, 0, dir);
+	if (entry)
+		entry->proc_fops = &ioc_fops;
+
+	entry = create_proc_entry("bitmap", 0, dir);
+	if (entry)
+		entry->proc_fops = &ioc_map_fops;
 }
 #endif
 
@@ -1941,6 +1942,8 @@
 sba_init(void)
 {
 	acpi_bus_register_driver(&acpi_sba_ioc_driver);
+	if (!ioc_list)
+		return 0;
 
 #ifdef CONFIG_PCI
 	{

