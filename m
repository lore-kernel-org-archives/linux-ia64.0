From: Russ Anderson <rja@sgi.com>
Date: Fri, 05 Nov 2004 23:04:41 +0000
Subject: Re: [PATCH] make INIT# handler call panic
Message-Id: <200411052304.iA5N4fb7091367@ben.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1099662943.913.180.camel@clarsen>
In-Reply-To: <1099662943.913.180.camel@clarsen>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Bjorn Helgaas wrote:
> 
> My personal preference would be something like this:
>    1) dump register state (for all CPUs, not just the INIT monarch)
>       on the console
>    2) print backtraces (maybe just for currently-running tasks;
>       currently we do the task on the INIT monarch plus all other
>       non-running tasks, which is definitely non-optimal)
>    3) optional debugger/crashdump hook
>    4) call panic (maybe)
>    5) optional timeout, then reboot (if not calling panic)
> 
> Part 5 would be trivial and probably not *too* controversial.
> Part 1 is harder but extremely useful, and I think someone (Zoltan?)
> posted a start.  Part 2 should be simple given part 1.

I agree.  I am working on part 1 (per cpu MCA/INIT save areas).

For example, the following sample patch:
  1) Reserves ar.k3 for a pointer to this cpu's mca info save area.
  2) Defines the struct layout of the save area.
  3) Allocates the memory for the save area (at boot time).

The part that I'm debugging it tying this into mca_asm.S.

-----------------------------------------------------------
Index: sles9-sgidev/linux/include/asm-ia64/kregs.h
=================================--- sles9-sgidev.orig/linux/include/asm-ia64/kregs.h	2004-02-23 22:44:17.000000000 -0600
+++ sles9-sgidev/linux/include/asm-ia64/kregs.h	2004-11-04 11:12:06.000000000 -0600
@@ -14,6 +14,7 @@
  */
 #define IA64_KR_IO_BASE		0	/* ar.k0: legacy I/O base address */
 #define IA64_KR_TSSD		1	/* ar.k1: IVE uses this as the TSSD */
+#define IA64_KR_MCA_INFO	3	/* ar.k3: phys addr of this cpu's mca_info struct */
 #define IA64_KR_CURRENT_STACK	4	/* ar.k4: what's mapped in IA64_TR_CURRENT_STACK */
 #define IA64_KR_FPU_OWNER	5	/* ar.k5: fpu-owner (UP only, at the moment) */
 #define IA64_KR_CURRENT		6	/* ar.k6: "current" task pointer */
Index: sles9-sgidev/linux/include/asm-ia64/mca.h
=================================--- sles9-sgidev.orig/linux/include/asm-ia64/mca.h	2004-02-23 23:57:45.000000000 -0600
+++ sles9-sgidev/linux/include/asm-ia64/mca.h	2004-11-04 12:38:23.000000000 -0600
@@ -107,6 +107,15 @@
 						 */
 } ia64_mca_os_to_sal_state_t;
 
+typedef struct ia64_mca_cpu_s {
+	u64		ia64_mca_proc_state_dump[512];
+	u64		ia64_mca_stack[1024] __attribute__((aligned(16)));
+	u64		ia64_mca_stackframe[32];
+	u64		ia64_mca_bspstore[1024];
+	u64		ia64_init_stack[KERNEL_STACK_SIZE/8] __attribute__((aligned(16)));
+	struct ia64_mca_tlb_info ia64_mca_cpu_tlb;
+} ia64_mca_cpu_t;
+
 extern void ia64_mca_init(void);
 extern void ia64_os_mca_dispatch(void);
 extern void ia64_os_mca_dispatch_end(void);
Index: sles9-sgidev/linux/arch/ia64/mm/discontig.c
=================================--- sles9-sgidev.orig/linux/arch/ia64/mm/discontig.c	2004-09-24 08:43:54.000000000 -0500
+++ sles9-sgidev/linux/arch/ia64/mm/discontig.c	2004-11-04 14:36:23.000000000 -0600
@@ -4,6 +4,10 @@
  * Copyright (c) 2001 Tony Luck <tony.luck@intel.com>
  * Copyright (c) 2002 NEC Corp.
  * Copyright (c) 2002 Kimio Suganuma <k-suganuma@da.jp.nec.com>
+ * Copyright (c) 2003-2004 Silicon Graphics, Inc
+ *      Russ Anderson <rja@sgi.com>
+ *      Jesse Barnes <jbarnes@sgi.com>
+ *      Jack Steiner <steiner@sgi.com>
  */
 
 /*
@@ -21,6 +25,7 @@
 #include <asm/meminit.h>
 #include <asm/numa.h>
 #include <asm/sections.h>
+#include <asm/mca.h>
 
 /*
  * Track per-node information needed to setup the boot memory allocator, the
@@ -203,12 +208,33 @@
 }
 
 /**
+ * early_nr_phys_cpus_node - return number of physical cpus on a given node
+ * @node: node to check
+ *
+ * Count the number of physical cpus on @node.  These are cpus that actually
+ * exist.  We can't use nr_cpus_node() yet because
+ * acpi_boot_init() (which builds the node_to_cpu_mask array) hasn't been
+ * called yet.
+ */
+static int early_nr_phys_cpus_node(int node)
+{
+	int cpu, n = 0;
+
+	for (cpu = 0; cpu < NR_CPUS; cpu++)
+		if (node = node_cpuid[cpu].nid)
+			if ((cpu = 0) || node_cpuid[cpu].phys_id)
+				n++;
+
+	return n;
+}
+
+/**
  * early_nr_cpus_node - return number of cpus on a given node
  * @node: node to check
  *
  * Count the number of cpus on @node.  We can't use nr_cpus_node() yet because
  * acpi_boot_init() (which builds the node_to_cpu_mask array) hasn't been
- * called yet.
+ * called yet.  Note that node 0 will also count all non-existent cpus.
  */
 static int early_nr_cpus_node(int node)
 {
@@ -235,12 +261,15 @@
  *   |                        |
  *   |~~~~~~~~~~~~~~~~~~~~~~~~| <-- NODEDATA_ALIGN(start, node) for the first
  *   |    PERCPU_PAGE_SIZE *  |     start and length big enough
- *   |        NR_CPUS         |
+ *   |    cpus_on_this_node   | Node 0 will also have entries for all non-existent cpus.
  *   |------------------------|
  *   |   local pg_data_t *    |
  *   |------------------------|
  *   |  local ia64_node_data  |
  *   |------------------------|
+ *   |    MCA/INIT data *     |
+ *   |    cpus_on_this_node   |
+ *   |------------------------|
  *   |          ???           |
  *   |________________________|
  *
@@ -252,9 +281,9 @@
 static int __init find_pernode_space(unsigned long start, unsigned long len,
 				     int node)
 {
-	unsigned long epfn, cpu, cpus;
+	unsigned long epfn, cpu, cpus, phys_cpus;
 	unsigned long pernodesize = 0, pernode, pages, mapsize;
-	void *cpu_data;
+	void *cpu_data, *mca_data_phys;
 	struct bootmem_data *bdp = &mem_data[node].bootmem_data;
 
 	epfn = (start + len) >> PAGE_SHIFT;
@@ -278,9 +307,11 @@
 	 * for good alignment and alias prevention.
 	 */
 	cpus = early_nr_cpus_node(node);
+	phys_cpus = early_nr_phys_cpus_node(node);
 	pernodesize += PERCPU_PAGE_SIZE * cpus;
 	pernodesize += L1_CACHE_ALIGN(sizeof(pg_data_t));
 	pernodesize += L1_CACHE_ALIGN(sizeof(struct ia64_node_data));
+	pernodesize += L1_CACHE_ALIGN(sizeof(ia64_mca_cpu_t)) * phys_cpus;
 	pernodesize = PAGE_ALIGN(pernodesize);
 	pernode = NODEDATA_ALIGN(start, node);
 
@@ -299,6 +330,9 @@
 		mem_data[node].node_data = __va(pernode);
 		pernode += L1_CACHE_ALIGN(sizeof(struct ia64_node_data));
 
+		mca_data_phys = (void *)pernode;
+		pernode += L1_CACHE_ALIGN(sizeof(ia64_mca_cpu_t)) * phys_cpus;
+
 		mem_data[node].pgdat->bdata = bdp;
 		pernode += L1_CACHE_ALIGN(sizeof(pg_data_t));
 
@@ -311,6 +345,14 @@
 			if (node = node_cpuid[cpu].nid) {
 				memcpy(__va(cpu_data), __phys_per_cpu_start,
 				       __per_cpu_end - __per_cpu_start);
+				if ((cpu = 0) || (node_cpuid[cpu].phys_id > 0)) {
+					ia64_set_kr(IA64_KR_MCA_INFO, __pa(mca_data_phys));
+					mca_data_phys += L1_CACHE_ALIGN(sizeof(ia64_mca_cpu_t));
+				}
 				__per_cpu_offset[cpu] = (char*)__va(cpu_data) -
 					__per_cpu_start;
 				cpu_data += PERCPU_PAGE_SIZE;


-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
