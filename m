From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 29 Mar 2006 02:11:14 +0000
Subject: [RFC][PATCH] avoid creating empty nodes [1/2] move reserve memory
Message-Id: <20060329111114.c6231d03.kamezawa.hiroyu@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060329110903.d7bae796.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20060329110903.d7bae796.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

move callers of reserve_memory() to use efi_memmap_walk
in acpi_numa_fixup().

Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Index: linux-2.6.16-mm1/arch/ia64/kernel/setup.c
=================================--- linux-2.6.16-mm1.orig/arch/ia64/kernel/setup.c	2006-03-28 11:16:13.000000000 +0900
+++ linux-2.6.16-mm1/arch/ia64/kernel/setup.c	2006-03-28 15:20:52.000000000 +0900
@@ -431,6 +431,8 @@
 		mark_bsp_online();
 
 	parse_early_param();
+
+	reserve_memory();
 #ifdef CONFIG_ACPI
 	/* Initialize the ACPI boot-time table parser */
 	acpi_table_init();
Index: linux-2.6.16-mm1/arch/ia64/mm/contig.c
=================================--- linux-2.6.16-mm1.orig/arch/ia64/mm/contig.c	2006-03-28 11:16:13.000000000 +0900
+++ linux-2.6.16-mm1/arch/ia64/mm/contig.c	2006-03-28 15:20:52.000000000 +0900
@@ -146,8 +146,6 @@
 {
 	unsigned long bootmap_size;
 
-	reserve_memory();
-
 	/* first find highest page frame number */
 	max_pfn = 0;
 	efi_memmap_walk(find_max_pfn, &max_pfn);
Index: linux-2.6.16-mm1/arch/ia64/mm/discontig.c
=================================--- linux-2.6.16-mm1.orig/arch/ia64/mm/discontig.c	2006-03-28 11:16:13.000000000 +0900
+++ linux-2.6.16-mm1/arch/ia64/mm/discontig.c	2006-03-28 15:20:52.000000000 +0900
@@ -438,8 +438,6 @@
 {
 	int node;
 
-	reserve_memory();
-
 	if (num_online_nodes() = 0) {
 		printk(KERN_ERR "node info missing!\n");
 		node_set_online(0);
