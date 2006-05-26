From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 26 May 2006 09:02:10 +0000
Subject: [RFC][PATCH] ia64 node hotplug -- cpu - node relationship fix [1/2]
Message-Id: <20060526180210.ec88165c.kamezawa.hiroyu@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060526175622.13057d7e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20060526175622.13057d7e.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, y-goto@jp.fujitsu.com, linux-ia64@vger.kernel.org, ashok.raj@intel.com, steiner@sgi.com, tony.luck@intel.com

Remove empty node -- a node which containes no cpu, no memory (and no I/O).

When empty node is onlined, it allocates NODE_DATA(). This causes 
for_each_online_node() walks through unused NODE_DATA.

Because an empty node has no memory, its NODE_DATA is allocated off-node.
Now, Node-hot-add is introduced to -mm. It can alloc NODE_DATA dynamically.
But if empty node exists, node-hotplug cannot allocate new NODE_DATA in local
memory  on-node(*)

I think it's good chance to remove empty node, which came from mishandling of
pxm in SRAT.

TBD: I/O only node detections scheme should be fixed. Does anyone have a
     suggestion ?

(*) Allocating NODE_DATA in local memory at node-hotplug is on my TBD list.
    not posted yet.

Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


Index: linux-2.6.17-rc4-mm3/arch/ia64/kernel/setup.c
=================================--- linux-2.6.17-rc4-mm3.orig/arch/ia64/kernel/setup.c	2006-05-25 18:48:15.000000000 +0900
+++ linux-2.6.17-rc4-mm3/arch/ia64/kernel/setup.c	2006-05-25 18:50:20.000000000 +0900
@@ -418,7 +418,7 @@
 
 	if (early_console_setup(*cmdline_p) = 0)
 		mark_bsp_online();
-
+	reserve_memory();
 #ifdef CONFIG_ACPI
 	/* Initialize the ACPI boot-time table parser */
 	acpi_table_init();
Index: linux-2.6.17-rc4-mm3/arch/ia64/mm/contig.c
=================================--- linux-2.6.17-rc4-mm3.orig/arch/ia64/mm/contig.c	2006-05-25 18:48:15.000000000 +0900
+++ linux-2.6.17-rc4-mm3/arch/ia64/mm/contig.c	2006-05-25 18:49:24.000000000 +0900
@@ -146,8 +146,6 @@
 {
 	unsigned long bootmap_size;
 
-	reserve_memory();
-
 	/* first find highest page frame number */
 	max_pfn = 0;
 	efi_memmap_walk(find_max_pfn, &max_pfn);
Index: linux-2.6.17-rc4-mm3/arch/ia64/mm/discontig.c
=================================--- linux-2.6.17-rc4-mm3.orig/arch/ia64/mm/discontig.c	2006-05-25 18:48:15.000000000 +0900
+++ linux-2.6.17-rc4-mm3/arch/ia64/mm/discontig.c	2006-05-25 18:49:40.000000000 +0900
@@ -443,8 +443,6 @@
 {
 	int node;
 
-	reserve_memory();
-
 	if (num_online_nodes() = 0) {
 		printk(KERN_ERR "node info missing!\n");
 		node_set_online(0);
Index: linux-2.6.17-rc4-mm3/arch/ia64/kernel/acpi.c
=================================--- linux-2.6.17-rc4-mm3.orig/arch/ia64/kernel/acpi.c	2006-05-25 18:48:15.000000000 +0900
+++ linux-2.6.17-rc4-mm3/arch/ia64/kernel/acpi.c	2006-05-26 16:38:35.000000000 +0900
@@ -515,6 +515,43 @@
 	num_node_memblks++;
 }
 
+/* online node if node has valid memory */
+static
+int find_valid_memory_range(unsigned long start, unsigned long end, void *arg)
+{
+	int i;
+	struct node_memblk_s *p;
+	start = __pa(start);
+	end = __pa(end);
+	for (i = 0; i < num_node_memblks; ++i) {
+		p = &node_memblk[i];
+		if (end < p->start_paddr)
+			continue;
+		if (p->start_paddr + p->size <= start)
+			continue;
+		node_set_online(p->nid);
+	}
+	return 0;
+}
+
+static void
+acpi_online_node_fixup(void)
+{
+	int i, cpu;
+	/* online node if a node has available cpus */
+	for (i = 0; i < srat_num_cpus; ++i)
+		for (cpu = 0; cpu < available_cpus; ++cpu)
+			if (smp_boot_data.cpu_phys_id[cpu] =
+				node_cpuid[i].phys_id) {
+				node_set_online(node_cpuid[i].nid);
+				break;
+			}
+	/* memory */
+	efi_memmap_walk(find_valid_memory_range, NULL);
+
+	/* TBD: check I/O devices which have valid nid. and online it*/
+}
+
 void __init acpi_numa_arch_fixup(void)
 {
 	int i, j, node_from, node_to;
@@ -526,22 +563,28 @@
 		return;
 	}
 
-	/*
-	 * MCD - This can probably be dropped now.  No need for pxm ID to node ID
-	 * mapping with sparse node numbering iff MAX_PXM_DOMAINS <= MAX_NUMNODES.
-	 */
 	nodes_clear(node_online_map);
+	/* MAP pxm to nid */
 	for (i = 0; i < MAX_PXM_DOMAINS; i++) {
 		if (pxm_bit_test(i)) {
-			int nid = acpi_map_pxm_to_node(i);
-			node_set_online(nid);
+			/* this makes pxm <-> nid mapping */
+			acpi_map_pxm_to_node(i);
 		}
 	}
+	/* convert pxm information to nid information */
 
-	/* set logical node id in memory chunk structure */
 	for (i = 0; i < num_node_memblks; i++)
 		node_memblk[i].nid = pxm_to_node(node_memblk[i].nid);
 
+	for (i = 0; i < srat_num_cpus; i++)
+		node_cpuid[i].nid = pxm_to_node(node_cpuid[i].nid);
+
+	/*
+         * confirm node is online or not.
+         * onlined node will have their own NODE_DATA
+	 */
+	acpi_online_node_fixup();
+
 	/* assign memory bank numbers for each chunk on each node */
 	for_each_online_node(i) {
 		int bank;
@@ -552,9 +595,6 @@
 				node_memblk[j].bank = bank++;
 	}
 
-	/* set logical node id in cpu structure */
-	for (i = 0; i < srat_num_cpus; i++)
-		node_cpuid[i].nid = pxm_to_node(node_cpuid[i].nid);
 
 	printk(KERN_INFO "Number of logical nodes in system = %d\n",
 	       num_online_nodes());

