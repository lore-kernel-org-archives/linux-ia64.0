From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 27 Jan 2005 00:40:42 +0000
Subject: RE: [patch] fix per-CPU MCA mess and make UP kernels work again
Message-Id: <16888.14474.588197.695427@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16887.1203.470842.161249@napali.hpl.hp.com>
In-Reply-To: <16887.1203.470842.161249@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 26 Jan 2005 14:33:00 -0800, "Luck, Tony" <tony.luck@intel.com> said:

  Tony> Jesse's generic up-build patch still needs some work, right?
  >>  Not if we change per_cpu_init() to _not_ allocate the MCA data.
  >> I can cook up a patch for doing this once the above two patches
  >> show up in your release-2.6.11 bk tree.

  Tony> Ok.  Your big fix-it patch, and Russ's addendum ar in the
  Tony> release tree.

OK, how about this patch?  Compile-tested and boot-tested for zx1 UP
and SMP and GENERIC.  I also verified that INIT dumps works for all
three kernels.

The discontig stuff is untested but I hope I got it right.

Note that with this patch applied, the per-CPU MCA memory will be
allocated from one node only.  As per our earlier discussion, that
should be OK.  I wouldn't object to doing per-node allocations, if
only there was a sane interface to allocate boot-memory for a
particular CPU (along the lines of the alloc_boot_mem_for_cpu() I
suggested), but I'm not familiar enough with the NUMA code to do this
myself.

	--david

--------------------------------------------------------------------
ia64: Move allocation of per-CPU MCA data out of per_cpu_init()

This patch moves the per-CPU MCA data allocation out of per_cpu_init()
so the code can be shared for contig and discontig memory
architectures.  Also, it means we can revert back to the old way
of doing per_cpu_init() on UP.

Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>

=== arch/ia64/kernel/mca.c 1.77 vs edited ==--- 1.77/arch/ia64/kernel/mca.c	2005-01-26 10:01:28 -08:00
+++ edited/arch/ia64/kernel/mca.c	2005-01-26 15:43:02 -08:00
@@ -1209,6 +1209,18 @@
 {
 	void *pal_vaddr;
 
+	if (smp_processor_id() = 0) {
+		void *mca_data;
+		int cpu;
+
+		mca_data = alloc_bootmem(sizeof(struct ia64_mca_cpu)
+					 * NR_CPUS);
+		for (cpu = 0; cpu < NR_CPUS; cpu++) {
+			__per_cpu_mca[cpu] = __pa(mca_data);
+			mca_data += sizeof(struct ia64_mca_cpu);
+		}
+	}
+
         /*
          * The MCA info structure was allocated earlier and its
          * physical address saved in __per_cpu_mca[cpu].  Copy that
=== arch/ia64/mm/contig.c 1.13 vs edited ==--- 1.13/arch/ia64/mm/contig.c	2005-01-26 10:01:33 -08:00
+++ edited/arch/ia64/mm/contig.c	2005-01-26 15:39:07 -08:00
@@ -169,6 +169,7 @@
 	find_initrd();
 }
 
+#ifdef CONFIG_SMP
 /**
  * per_cpu_init - setup per-cpu variables
  *
@@ -177,18 +178,15 @@
 void *
 per_cpu_init (void)
 {
-	void *mca_data, *my_data;
+	void *cpu_data;
 	int cpu;
 
-#ifdef CONFIG_SMP
 	/*
 	 * get_free_pages() cannot be used before cpu_init() done.  BSP
 	 * allocates "NR_CPUS" pages for all CPUs to avoid that AP calls
 	 * get_zeroed_page().
 	 */
 	if (smp_processor_id() = 0) {
-		void *cpu_data;
-
 		cpu_data = __alloc_bootmem(PERCPU_PAGE_SIZE * NR_CPUS,
 					   PERCPU_PAGE_SIZE, __pa(MAX_DMA_ADDRESS));
 		for (cpu = 0; cpu < NR_CPUS; cpu++) {
@@ -198,20 +196,9 @@
 			per_cpu(local_per_cpu_offset, cpu) = __per_cpu_offset[cpu];
 		}
 	}
-	my_data = __per_cpu_start + __per_cpu_offset[smp_processor_id()];
-#else
-	my_data = (void *) __phys_per_cpu_start;
-#endif
-
-	if (smp_processor_id() = 0) {
-		mca_data = alloc_bootmem(sizeof (struct ia64_mca_cpu) * NR_CPUS);
-		for (cpu = 0; cpu < NR_CPUS; cpu++) {
-			__per_cpu_mca[cpu] = __pa(mca_data);
-			mca_data += sizeof (struct ia64_mca_cpu);
-		}
-	}
-	return my_data;
+	return __per_cpu_start + __per_cpu_offset[smp_processor_id()];
 }
+#endif /* CONFIG_SMP */
 
 static int
 count_pages (u64 start, u64 end, void *arg)
=== arch/ia64/mm/discontig.c 1.29 vs edited ==--- 1.29/arch/ia64/mm/discontig.c	2005-01-26 10:01:34 -08:00
+++ edited/arch/ia64/mm/discontig.c	2005-01-26 15:39:48 -08:00
@@ -26,7 +26,6 @@
 #include <asm/meminit.h>
 #include <asm/numa.h>
 #include <asm/sections.h>
-#include <asm/mca.h>
 
 /*
  * Track per-node information needed to setup the boot memory allocator, the
@@ -294,9 +293,6 @@
  *   |------------------------|
  *   |  local ia64_node_data  |
  *   |------------------------|
- *   |    MCA/INIT data *     |
- *   |    cpus_on_this_node   |
- *   |------------------------|
  *   |          ???           |
  *   |________________________|
  *
@@ -310,7 +306,7 @@
 {
 	unsigned long epfn, cpu, cpus, phys_cpus;
 	unsigned long pernodesize = 0, pernode, pages, mapsize;
-	void *cpu_data, *mca_data_phys;
+	void *cpu_data;
 	struct bootmem_data *bdp = &mem_data[node].bootmem_data;
 
 	epfn = (start + len) >> PAGE_SHIFT;
@@ -339,7 +335,6 @@
 	pernodesize += node * L1_CACHE_BYTES;
 	pernodesize += L1_CACHE_ALIGN(sizeof(pg_data_t));
 	pernodesize += L1_CACHE_ALIGN(sizeof(struct ia64_node_data));
-	pernodesize += L1_CACHE_ALIGN(sizeof(struct ia64_mca_cpu)) * phys_cpus;
 	pernodesize = PAGE_ALIGN(pernodesize);
 	pernode = NODEDATA_ALIGN(start, node);
 
@@ -362,9 +357,6 @@
 		mem_data[node].pgdat->bdata = bdp;
 		pernode += L1_CACHE_ALIGN(sizeof(pg_data_t));
 
-		mca_data_phys = (void *)pernode;
-		pernode += L1_CACHE_ALIGN(sizeof(struct ia64_mca_cpu)) * phys_cpus;
-
 		/*
 		 * Copy the static per-cpu data into the region we
 		 * just set aside and then setup __per_cpu_offset
@@ -374,18 +366,6 @@
 			if (node = node_cpuid[cpu].nid) {
 				memcpy(__va(cpu_data), __phys_per_cpu_start,
 				       __per_cpu_end - __per_cpu_start);
-				if ((cpu = 0) || (node_cpuid[cpu].phys_id > 0)) {
-					/* 
-					 * The memory for the cpuinfo structure is allocated
-					 * here, but the data in the structure is initialized
-					 * later.  Save the physical address of the MCA save
-					 * area in __per_cpu_mca[cpu].  When the cpuinfo struct 
-					 * is initialized, the value in __per_cpu_mca[cpu]
-					 * will be put in the cpuinfo structure.
-					 */
-					__per_cpu_mca[cpu] = __pa(mca_data_phys);
-					mca_data_phys += L1_CACHE_ALIGN(sizeof(struct ia64_mca_cpu));
-				}
 				__per_cpu_offset[cpu] = (char*)__va(cpu_data) -
 					__per_cpu_start;
 				cpu_data += PERCPU_PAGE_SIZE;
=== include/asm-ia64/percpu.h 1.16 vs edited ==--- 1.16/include/asm-ia64/percpu.h	2005-01-26 10:01:39 -08:00
+++ edited/include/asm-ia64/percpu.h	2005-01-26 15:35:12 -08:00
@@ -46,11 +46,13 @@
 
 extern void percpu_modcopy(void *pcpudst, const void *src, unsigned long size);
 extern void setup_per_cpu_areas (void);
+extern void *per_cpu_init(void);
 
 #else /* ! SMP */
 
 #define per_cpu(var, cpu)			(*((void)cpu, &per_cpu__##var))
 #define __get_cpu_var(var)			per_cpu__##var
+#define per_cpu_init()				(__phys_per_cpu_start)
 
 #endif	/* SMP */
 
@@ -64,8 +66,6 @@
  * more efficient.
  */
 #define __ia64_per_cpu_var(var)	(per_cpu__##var)
-
-extern void *per_cpu_init(void);
 
 #endif /* !__ASSEMBLY__ */
 
