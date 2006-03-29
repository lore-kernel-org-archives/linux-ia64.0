From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 29 Mar 2006 02:12:49 +0000
Subject: [RFC][PATCH] avoid creating empty nodes [2/2] ignore empty pxms.
Message-Id: <20060329111249.d30ce63e.kamezawa.hiroyu@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060329110903.d7bae796.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20060329110903.d7bae796.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

compare SRAT information and other information to
avoid onlining nodes which doesn't have any cpus and memory.
for cpus, compare SRAT and lsapic.
for memory, compare SRAT and EFI.

Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Index: linux-2.6.16-mm1/arch/ia64/kernel/acpi.c
=================================--- linux-2.6.16-mm1.orig/arch/ia64/kernel/acpi.c	2006-03-28 15:04:31.000000000 +0900
+++ linux-2.6.16-mm1/arch/ia64/kernel/acpi.c	2006-03-28 16:53:39.000000000 +0900
@@ -413,8 +413,11 @@
 
 static int __initdata srat_num_cpus;	/* number of cpus */
 static u32 __devinitdata pxm_flag[PXM_FLAG_LEN];
+static u32 __devinitdata pxm_online_flag[PXM_FLAG_LEN];
 #define pxm_bit_set(bit)	(set_bit(bit,(void *)pxm_flag))
 #define pxm_bit_test(bit)	(test_bit(bit,(void *)pxm_flag))
+#define pxm_online_bit_set(bit)	(set_bit(bit, (void *)pxm_online_flag))
+#define pxm_online_bit_test(bit) (test_bit(bit, (void *)pxm_online_flag))
 static struct acpi_table_slit __initdata *slit_table;
 
 /*
@@ -450,6 +453,24 @@
 	srat_num_cpus++;
 }
 
+/*
+ * compare SRAT and lsapic entries.
+ */
+void __init confirm_srat_available_cpu(void)
+{
+	int i, j;
+	unsigned long phys_id;
+	for (i = 0; i < available_cpus; i++) {
+		phys_id = smp_boot_data.cpu_phys_id[i];
+		for (j = 0; j < srat_num_cpus; j++) {
+			if (node_cpuid[j].phys_id = phys_id) {
+				pxm_online_bit_set(node_cpuid[j].nid);
+				printk("set pxm %d online\n", node_cpuid[j].nid);
+			}
+		}
+	}
+}
+
 void __init
 acpi_numa_memory_affinity_init(struct acpi_table_memory_affinity *ma)
 {
@@ -488,9 +509,31 @@
 	num_node_memblks++;
 }
 
+int confirm_srat_efi_memmap(unsigned long start, unsigned long end, void *arg)
+{
+	unsigned long pstart, pend;
+	struct node_memblk_s *p;
+	int i;
+	printk(KERN_INFO "print efi memamp %p %p\n", (void*)start, (void *)end);
+	pstart = __pa(start);
+	pend = __pa(end);
+	/* check intersection with SRAT's memdata */
+	for (i = 0; i < num_node_memblks; i++) {
+		p = &node_memblk[i];
+		if (((p->start_paddr <= pstart) &&
+	             (pstart < p->start_paddr + p->size)) ||
+		    ((pstart <= p->start_paddr) &&
+	             (p->start_paddr + p->size <= pend))) {
+			pxm_online_bit_set(p->nid);
+			printk(KERN_INFO "set pxm %d online\n", p->nid);
+		}
+	}
+	return 0;
+}
+
 void __init acpi_numa_arch_fixup(void)
 {
-	int i, j, node_from, node_to;
+	int i, j, node, node_from, node_to;
 
 	/* If there's no SRAT, fix the phys_id and mark node 0 online */
 	if (srat_num_cpus = 0) {
@@ -498,6 +541,8 @@
 		node_cpuid[0].phys_id = hard_smp_processor_id();
 		return;
 	}
+	confirm_srat_available_cpu();
+	efi_memmap_walk(confirm_srat_efi_memmap, NULL);
 
 	/*
 	 * MCD - This can probably be dropped now.  No need for pxm ID to node ID
@@ -507,8 +552,8 @@
 	for (i = 0; i < MAX_PXM_DOMAINS; i++) {
 		if (pxm_bit_test(i)) {
 			int nid = acpi_map_pxm_to_node(i);
-			pxm_bit_set(i);
-			node_set_online(nid);
+			if (pxm_online_bit_test(i))
+				node_set_online(nid);
 		}
 	}
 
@@ -527,8 +572,13 @@
 	}
 
 	/* set logical node id in cpu structure */
-	for (i = 0; i < srat_num_cpus; i++)
-		node_cpuid[i].nid = pxm_to_node(node_cpuid[i].nid);
+	for (i = 0; i < srat_num_cpus; i++) {
+		node = pxm_to_node(node_cpuid[i].nid);
+		if (node_online(node))
+			node_cpuid[i].nid = node;
+		else
+			node_cpuid[i].nid = 0; /* for possible cpus */
+	}
 
 	printk(KERN_INFO "Number of logical nodes in system = %d\n",
 	       num_online_nodes());
