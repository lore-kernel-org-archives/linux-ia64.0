From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 09 May 2006 12:10:46 +0000
Subject: [PATCH] avoid creating empty node take 2 [2/2] empty node fix
Message-Id: <20060509211046.68246df6.kamezawa.hiroyu@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060509210847.05c263d0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20060509210847.05c263d0.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On ia64/NUMA, SRAT is now used to describe NUMA configration.
And SRAT is also used to describe possible resources ,which can be
hot-added later.

Now, ia64's SRAT parser sets pxm and create nodes if it finds SRAT entry.
But, SRAT just shows possible resources. not available ones. By this,
we see empty node in sysfs, which has no cpu, no memory. 

This patch removes empty nodes.

Note: I hear I/O only node can be described in ACPI3.0. Then, we have
to deal with it later.

Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Index: linux-2.6.17-rc3/arch/ia64/kernel/acpi.c
=================================--- linux-2.6.17-rc3.orig/arch/ia64/kernel/acpi.c	2006-05-09 16:29:34.000000000 +0900
+++ linux-2.6.17-rc3/arch/ia64/kernel/acpi.c	2006-05-09 16:33:20.000000000 +0900
@@ -470,9 +470,6 @@
 
 	pxm = get_processor_proximity_domain(pa);
 
-	/* record this node in proximity bitmap */
-	pxm_bit_set(pxm);
-
 	node_cpuid[srat_num_cpus].phys_id  	    (pa->apic_id << 8) | (pa->lsapic_eid);
 	/* nid should be overridden as logical node id later */
@@ -499,9 +496,6 @@
 	if (!ma->flags.enabled)
 		return;
 
-	/* record this node in proximity bitmap */
-	pxm_bit_set(pxm);
-
 	/* Insertion sort based on base address */
 	pend = &node_memblk[num_node_memblks];
 	for (p = &node_memblk[0]; p < pend; p++) {
@@ -518,6 +512,54 @@
 	num_node_memblks++;
 }
 
+static int __init
+find_valid_memory_range(unsigned long start, unsigned long end, void *arg)
+{
+	int i;
+	struct node_memblk_s *p;
+	start = __pa(start);
+	end = __pa(end);
+	for (i = 0; i < num_node_memblks; i++) {
+		p = &node_memblk[i];
+		if (end < p->start_paddr)
+			continue;
+		if (p->start_paddr + p->size < start)
+			continue;
+		/* there is intersection. */
+		pxm_bit_set(p->nid);
+		break;
+	}
+	return 0;
+}
+
+static void __init acpi_pxm_fixup(void)
+{
+	int i, cpu;
+	/*
+	 * check CPU: compare SRAT and MADT table
+	 * set pxm bitmap if cpu is avilable
+	 */
+	for (i = 0; i < srat_num_cpus; ++i)
+		for (cpu = 0; cpu < available_cpus; ++cpu)
+			if (smp_boot_data.cpu_phys_id[cpu] =
+			    node_cpuid[i].phys_id) {
+				pxm_bit_set(node_cpuid[i].nid);
+				break;
+			}
+	/*
+	 * check memory: compare SRAT and EFI table
+	 * set pxm bitmap if memory range contains valid memory.
+	 */
+	efi_memmap_walk(find_valid_memory_range, NULL);
+
+	/*
+	 * FIXME: when I/O only nodes are available, we have to
+	 * detect them here. ACPI 3.0 supports it.
+	 * If some sub-arch wants to add additinal pxm validation,
+   	 * please add here.
+	 */
+}
+
 void __init acpi_numa_arch_fixup(void)
 {
 	int i, j, node_from, node_to;
@@ -529,6 +571,8 @@
 		return;
 	}
 
+	acpi_pxm_fixup();
+
 	/*
 	 * MCD - This can probably be dropped now.  No need for pxm ID to node ID
 	 * mapping with sparse node numbering iff MAX_PXM_DOMAINS <= MAX_NUMNODES.
@@ -562,7 +606,10 @@
 
 	/* set logical node id in cpu structure */
 	for (i = 0; i < srat_num_cpus; i++)
-		node_cpuid[i].nid = pxm_to_nid_map[node_cpuid[i].nid];
+		if (node_online(i))
+			node_cpuid[i].nid = pxm_to_nid_map[node_cpuid[i].nid];
+		else
+			node_cpuid[i].nid = 0;
 
 	printk(KERN_INFO "Number of logical nodes in system = %d\n",
 	       num_online_nodes());

