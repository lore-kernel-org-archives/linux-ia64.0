From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 09 May 2006 12:08:47 +0000
Subject: [PATCH] avoid creating empty node take 2 [1/2] move reserve_memory
Message-Id: <20060509210847.05c263d0.kamezawa.hiroyu@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi, this patch is to delete empty node. (take2)

Changelog V1->V2
- Add comments about I/O only nodes. ACPI 3.0.
- much simpler than V1.
- reworked against 2.6.17-rc3

=
When SRAT table includes cpu entries which is not available or includes memory
entries which doesn't has available memory, pxm_flag for it is set.
(in arch/ia64/kernel/acpi.c, acpi_numa_arch_fixup().)
As a result, empty node is created.

Our NUMA machine's sysfs will always show 8 nodes even if it is booted up with
only one node, whose SRAT describes all possible cpus and memory.
This is not good for a machine which supports SRAT with Hot-Add information.

Note: SRAT's enable bit just says "you can read this entry." not means 
"memory is available/"

We have to check a pxm is assigned to available resources.

[1/2] -- just move reserve_memory() .
[2/2] -- empty node fix.


-Kame


reserve_memory() is called in find_memory(), both in contig.c and in
discontig.c. After reserve_memory(), the kernel setup code can use 
EFI memory map information.
By moving this before parsing acpi SRAT information, we can use EFI
information in acpi NUMA setup.
This patch is against 2.6.17-rc3.

Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Index: linux-2.6.17-rc3/arch/ia64/mm/contig.c
=================================--- linux-2.6.17-rc3.orig/arch/ia64/mm/contig.c	2006-05-09 16:29:34.000000000 +0900
+++ linux-2.6.17-rc3/arch/ia64/mm/contig.c	2006-05-09 16:31:02.000000000 +0900
@@ -146,8 +146,6 @@
 {
 	unsigned long bootmap_size;
 
-	reserve_memory();
-
 	/* first find highest page frame number */
 	max_pfn = 0;
 	efi_memmap_walk(find_max_pfn, &max_pfn);
Index: linux-2.6.17-rc3/arch/ia64/mm/discontig.c
=================================--- linux-2.6.17-rc3.orig/arch/ia64/mm/discontig.c	2006-05-09 16:29:34.000000000 +0900
+++ linux-2.6.17-rc3/arch/ia64/mm/discontig.c	2006-05-09 16:31:02.000000000 +0900
@@ -438,8 +438,6 @@
 {
 	int node;
 
-	reserve_memory();
-
 	if (num_online_nodes() = 0) {
 		printk(KERN_ERR "node info missing!\n");
 		node_set_online(0);
Index: linux-2.6.17-rc3/arch/ia64/kernel/setup.c
=================================--- linux-2.6.17-rc3.orig/arch/ia64/kernel/setup.c	2006-05-09 16:29:34.000000000 +0900
+++ linux-2.6.17-rc3/arch/ia64/kernel/setup.c	2006-05-09 16:31:31.000000000 +0900
@@ -419,6 +419,7 @@
 	if (early_console_setup(*cmdline_p) = 0)
 		mark_bsp_online();
 
+	reserve_memory();
 #ifdef CONFIG_ACPI
 	/* Initialize the ACPI boot-time table parser */
 	acpi_table_init();

