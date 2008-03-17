From: holt@sgi.com
Date: Mon, 17 Mar 2008 12:12:43 +0000
Subject: [Patch 3/3] Allocate mca/init stacks as part of per_node reservation.
Message-Id: <20080317121241.193785380@attica.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080213175520.786006915@attica.americas.sgi.com>
In-Reply-To: <20080213175520.786006915@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


This patch will reserve space on the node at the same time as per_cpu
space is reserved.  By the time the for_each_possible_cpu() cpumask is
initialized, we will have already reserved and initialized the mca and
init stack areas for every possible cpu.

Signed-off-by: Robin Holt <holt@sgi.com>
Signed-off-by: Russ Anderson <rja@sgi.com>

---


Index: per_cpu_mca_v1/arch/ia64/mm/discontig.c
=================================--- per_cpu_mca_v1.orig/arch/ia64/mm/discontig.c	2008-03-17 07:02:33.085979563 -0500
+++ per_cpu_mca_v1/arch/ia64/mm/discontig.c	2008-03-17 07:03:13.386995549 -0500
@@ -27,6 +27,7 @@
 #include <asm/meminit.h>
 #include <asm/numa.h>
 #include <asm/sections.h>
+#include <asm/mca.h>
 
 /*
  * Track per-node information needed to setup the boot memory allocator, the
@@ -127,11 +128,38 @@ static unsigned long __meminit compute_p
 	pernodesize += L1_CACHE_ALIGN(sizeof(pg_data_t));
 	pernodesize += L1_CACHE_ALIGN(sizeof(struct ia64_node_data));
 	pernodesize += L1_CACHE_ALIGN(sizeof(pg_data_t));
+	pernodesize = ALIGN(pernodesize, KERNEL_STACK_SIZE);
+	pernodesize += sizeof(struct ia64_mca_cpu) * cpus;
 	pernodesize = PAGE_ALIGN(pernodesize);
 	return pernodesize;
 }
 
 /**
+ * per_node_mca_setup - setup mca areas on each node for its cpus
+ * @mca_area: mca area on this node
+ * @node: node to setup
+ */
+static unsigned long per_node_mca_setup(unsigned long mca_area, int node)
+{
+#ifdef CONFIG_SMP
+	int cpu;
+
+	for_each_possible_early_cpu(cpu) {
+		if (node = node_cpuid[cpu].nid) {
+			__per_cpu_mca[cpu] = mca_area;
+			mca_area += sizeof(struct ia64_mca_cpu);
+		}
+	}
+#else
+	if (node = 0) {
+		__per_cpu_mca[0] = mca_area;
+		mca_area += sizeof(struct ia64_mca_cpu);
+	}
+#endif
+	return mca_area;
+}
+
+/**
  * per_cpu_node_setup - setup per-cpu areas on each node
  * @cpu_data: per-cpu area on this node
  * @node: node to setup
@@ -188,6 +216,10 @@ static void __init fill_pernode(int node
 	pgdat_list[node]->bdata = bdp;
 	pernode += L1_CACHE_ALIGN(sizeof(pg_data_t));
 
+	pernode = ALIGN(pernode, KERNEL_STACK_SIZE);
+
+	pernode = per_node_mca_setup(pernode, node);
+
 	cpu_data = per_cpu_node_setup(cpu_data, node);
 
 	return;
Index: per_cpu_mca_v1/arch/ia64/mm/contig.c
=================================--- per_cpu_mca_v1.orig/arch/ia64/mm/contig.c	2008-03-17 07:02:33.085979563 -0500
+++ per_cpu_mca_v1/arch/ia64/mm/contig.c	2008-03-17 07:03:28.716903531 -0500
@@ -184,8 +184,26 @@ alloc_per_cpu_data(void)
 	cpu_data = __alloc_bootmem(PERCPU_PAGE_SIZE * NR_CPUS,
 				   PERCPU_PAGE_SIZE, __pa(MAX_DMA_ADDRESS));
 }
+
+static inline void
+alloc_mca_data(void)
+{
+	int cpu;
+
+	for_each_possible_early_cpu(cpu) {
+		__per_cpu_mca[cpu] = __pa(__alloc_bootmem(
+			sizeof(struct ia64_mca_cpu), KERNEL_STACK_SIZE, 0));
+	}
+}
 #else
 #define alloc_per_cpu_data() do { } while (0)
+
+static inline void
+alloc_mca_data(void)
+{
+	__per_cpu_mca[0] = __pa(__alloc_bootmem(
+			sizeof(struct ia64_mca_cpu), KERNEL_STACK_SIZE, 0));
+}
 #endif /* CONFIG_SMP */
 
 /**
@@ -225,6 +243,8 @@ find_memory (void)
 	find_initrd();
 
 	alloc_per_cpu_data();
+
+	alloc_mca_data();
 }
 
 static int
Index: per_cpu_mca_v1/arch/ia64/kernel/mca.c
=================================--- per_cpu_mca_v1.orig/arch/ia64/kernel/mca.c	2008-03-17 07:02:33.085979563 -0500
+++ per_cpu_mca_v1/arch/ia64/kernel/mca.c	2008-03-17 07:03:13.427000528 -0500
@@ -1759,45 +1759,26 @@ format_mca_init_stack(void *mca_data, un
 	strncpy(p->comm, type, sizeof(p->comm)-1);
 }
 
-/* Caller prevents this from being called after init */
-static void * __init_refok mca_bootmem(void)
-{
-	return __alloc_bootmem(sizeof(struct ia64_mca_cpu),
-	                    KERNEL_STACK_SIZE, 0);
-}
-
 /* Do per-CPU MCA-related initialization.  */
 void __cpuinit
 ia64_mca_cpu_init(void *cpu_data)
 {
 	void *pal_vaddr;
 	void *data;
-	long sz = sizeof(struct ia64_mca_cpu);
 	int cpu = smp_processor_id();
-	static int first_time = 1;
 
 	/*
 	 * Structure will already be allocated if cpu has been online,
 	 * then offlined.
 	 */
-	if (__per_cpu_mca[cpu]) {
-		data = __va(__per_cpu_mca[cpu]);
-	} else {
-		if (first_time) {
-			data = mca_bootmem();
-			first_time = 0;
-		} else
-			data = page_address(alloc_pages_node(numa_node_id(),
-					GFP_KERNEL, get_order(sz)));
-		if (!data)
-			panic("Could not allocate MCA memory for cpu %d\n",
-					cpu);
-	}
+	BUG_ON(__per_cpu_mca[cpu] = 0);
+	data = __va(__per_cpu_mca[cpu]);
+
 	format_mca_init_stack(data, offsetof(struct ia64_mca_cpu, mca_stack),
 		"MCA", cpu);
 	format_mca_init_stack(data, offsetof(struct ia64_mca_cpu, init_stack),
 		"INIT", cpu);
-	__get_cpu_var(ia64_mca_data) = __per_cpu_mca[cpu] = __pa(data);
+	__get_cpu_var(ia64_mca_data) = __pa(data);
 
 	/*
 	 * Stash away a copy of the PTE needed to map the per-CPU page.

-- 
