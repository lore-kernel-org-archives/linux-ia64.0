From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 13 Oct 2006 00:33:47 +0000
Subject: [RFC] Move virtual memory map into variable page size area
Message-Id: <Pine.LNX.4.64.0610121732510.22794@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Move virtual memory map into variable page size area

If we would be using a larger page size for the virtual memory map then
we may be able to reduce TLB pressure. The IBM sparsemen folks have shown
that a virtual memory map using 4k page size is performance wise
inferior to their table based lookup scheme. Since TLB faults are
much more expensive on IA64 it is likely also an important effect.
We have a higher page size though so we suffer less. However, once
we move to x86_64 we will have to address this issue.

One reason to do this is to get things straight to move the virtual mem
map code into the core kernel and then use that for x86_64

By default this patch uses a page size of 1 Megabyte for the
memory map. That seems to be a reasonable compromise to avoid
excessive memory use for smaller machines and to avoid too much
TLB misses on our large platforms.

With 1MB pages we can map 16k pages  per vmemmap page which is 256 megabytes.
With the current 16k we map 256 pages. So only 4 megabyte per TLB entry.

So if we have 4 GB ram per node then we will now need 16 TLB entries per
node in contast to 1024.

If we would increase the memory map size to 16 megabyte then we
could map the complete memory on a node with a single 16 MB page
using only a single TLB entry instead of 1024 rigt now.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.19-rc1-mm1/arch/ia64/mm/init.c
=================================--- linux-2.6.19-rc1-mm1.orig/arch/ia64/mm/init.c	2006-10-12 11:50:18.447949188 -0700
+++ linux-2.6.19-rc1-mm1/arch/ia64/mm/init.c	2006-10-12 11:55:00.877807965 -0700
@@ -466,6 +466,11 @@ retry_pte:
 	return hole_next_pfn - pgdat->node_start_pfn;
 }
 
+static void * __init alloc_vmem_page(int node, unsigned long size)
+{
+	return __alloc_bootmem_node(NODE_DATA(node), size, size, __pa(MAX_DMA_ADDRESS));
+}
+
 int __init
 create_mem_map_page_table (u64 start, u64 end, void *arg)
 {
@@ -476,31 +481,42 @@ create_mem_map_page_table (u64 start, u6
 	pud_t *pud;
 	pmd_t *pmd;
 	pte_t *pte;
+	unsigned long vkp_page_size = 1UL << VIRTUAL_MEM_MAP_PAGE_SHIFT;
 
 	map_start = virt_to_page(start);
 	map_end   = virt_to_page(end);
 
-	start_page = (unsigned long) map_start & PAGE_MASK;
-	end_page = PAGE_ALIGN((unsigned long) map_end);
+
+	start_page = (unsigned long) map_start & ~(vkp_page_size - 1);
+	end_page = ALIGN((unsigned long) map_end, vkp_page_size);
 	node = paddr_to_nid(__pa(start));
 
-	for (address = start_page; address < end_page; address += PAGE_SIZE) {
-		pgd = pgd_offset_k(address);
+	for (address = start_page; address < end_page; address += vkp_page_size) {
+#ifdef CONFIG_VIRTUAL_MEM_MAP_HUGE
+		unsigned long taddr = VKP_PAGE_TO_PAGE(address);
+		pgd = pgd_offset_vkp(taddr);
+#else
+		unsigned long taddr = address;
+		pgd = pgd_offset_k(taddr);
+#endif
 		if (pgd_none(*pgd))
-			pgd_populate(&init_mm, pgd, alloc_bootmem_pages_node(NODE_DATA(node), PAGE_SIZE));
-		pud = pud_offset(pgd, address);
+			pgd_populate(&init_mm, pgd, alloc_vmem_page(node, PAGE_SIZE));
+		pud = pud_offset(pgd, taddr);
 
 		if (pud_none(*pud))
-			pud_populate(&init_mm, pud, alloc_bootmem_pages_node(NODE_DATA(node), PAGE_SIZE));
-		pmd = pmd_offset(pud, address);
+			pud_populate(&init_mm, pud, alloc_vmem_page(node, PAGE_SIZE));
+		pmd = pmd_offset(pud, taddr);
 
 		if (pmd_none(*pmd))
-			pmd_populate_kernel(&init_mm, pmd, alloc_bootmem_pages_node(NODE_DATA(node), PAGE_SIZE));
-		pte = pte_offset_kernel(pmd, address);
+			pmd_populate_kernel(&init_mm, pmd, alloc_vmem_page(node, PAGE_SIZE));
+		pte = pte_offset_kernel(pmd, taddr);
+
+		if (pte_none(*pte)) {
+			unsigned long addr;
 
-		if (pte_none(*pte))
-			set_pte(pte, pfn_pte(__pa(alloc_bootmem_pages_node(NODE_DATA(node), PAGE_SIZE)) >> PAGE_SHIFT,
-					     PAGE_KERNEL));
+			addr = __pa(alloc_vmem_page(node, vkp_page_size));
+			set_pte(pte, mk_pte_phys(addr, PAGE_KERNEL));
+		}
 	}
 	return 0;
 }
Index: linux-2.6.19-rc1-mm1/arch/ia64/mm/fault.c
=================================--- linux-2.6.19-rc1-mm1.orig/arch/ia64/mm/fault.c	2006-10-04 19:57:05.000000000 -0700
+++ linux-2.6.19-rc1-mm1/arch/ia64/mm/fault.c	2006-10-12 11:55:00.878784467 -0700
@@ -65,6 +65,12 @@ mapped_kernel_page_is_present (unsigned 
 	pmd_t *pmd;
 	pte_t *ptep, pte;
 
+#ifdef CONFIG_VIRTUAL_MEM_MAP_HUGE
+	if (VKP_VALID(address)) {
+		address = VKP_PAGE_TO_PAGE(address);
+		pgd = pgd_offset_vkp(address);
+	} else
+#endif
 	pgd = pgd_offset_k(address);
 	if (pgd_none(*pgd) || pgd_bad(*pgd))
 		return 0;
Index: linux-2.6.19-rc1-mm1/arch/ia64/Kconfig
=================================--- linux-2.6.19-rc1-mm1.orig/arch/ia64/Kconfig	2006-10-11 17:54:00.272700187 -0700
+++ linux-2.6.19-rc1-mm1/arch/ia64/Kconfig	2006-10-12 11:55:00.878784467 -0700
@@ -371,8 +371,13 @@ config NODES_SHIFT
 config ARCH_POPULATES_NODE_MAP
 	def_bool y
 
-# VIRTUAL_MEM_MAP and FLAT_NODE_MEM_MAP are functionally equivalent.
-# VIRTUAL_MEM_MAP has been retained for historical reasons.
+# VIRTUAL_MEM_MAP and FLAT_NODE_MEM_MAP may be functionally equivalent but
+# the overhead of FLAT_NODE_MEM_MAP is much higher. Its even worse for
+# a SPARSEMEM configuration that needs indirections through multiple tables
+# for elementary VM operations.
+#
+# VIRTUAL_MEM_MAP is the best choice for handling large sparse memory maps.
+#
 config VIRTUAL_MEM_MAP
 	bool "Virtual mem map"
 	depends on !SPARSEMEM
@@ -384,6 +389,23 @@ config VIRTUAL_MEM_MAP
 	  require the DISCONTIGMEM option for your machine. If you are
 	  unsure, say Y.
 
+config VIRTUAL_MEM_MAP_HUGE
+	depends on VIRTUAL_MEM_MAP
+	bool "Virtual mem map uses Huge pages"
+	help
+	  By default we map the virtual memory map using the default page
+	  size and take a part of VMALLOC space for the map. This option
+	  makes the virtual memory map use huge pages as a base and moves
+	  the virtual memory map out of the VMALLOC space. This has the
+	  effect of decreasing TLB use necessary to access the virtual
+	  memory map.
+	  The default huge page size is decreased from 256M to 16M in order
+	  in order to reduce overhead. A 4M huge page can map ~4GB memory.
+	  A 16k page can map ~4 Megabytes of memory.
+	  Note that changes of the huge page size via a boot option will
+	  then also change the base page size for the virtual memory map.
+	  Too high huge page sizes may lead to memory being wasted.
+
 config HOLES_IN_ZONE
 	bool
 	default y if VIRTUAL_MEM_MAP
Index: linux-2.6.19-rc1-mm1/include/asm-ia64/pgtable.h
=================================--- linux-2.6.19-rc1-mm1.orig/include/asm-ia64/pgtable.h	2006-10-12 11:54:55.917176204 -0700
+++ linux-2.6.19-rc1-mm1/include/asm-ia64/pgtable.h	2006-10-12 11:56:10.266109449 -0700
@@ -151,9 +151,6 @@
 #define PAGE_KERNEL	__pgprot(__DIRTY_BITS  | _PAGE_PL_0 | _PAGE_AR_RWX)
 #define PAGE_KERNELRX	__pgprot(__ACCESS_BITS | _PAGE_PL_0 | _PAGE_AR_RX)
 
-#define VIRTUAL_MEM_MAP		(RGN_BASE(RGN_GATE) + 0x200000000)
-
-
 /*
  * Definitions to support various sizes of kernel pages in region 7
  * that can be used to reduce TLB pressure and create pagetables with
@@ -209,6 +206,16 @@
 #define pgd_offset_vkp(addr)	&region7_pg_dir[VKP_SHIFT_TO_PT(VKP_ADDR_TO_SHIFT(addr))]\
 				[VKP_ADDR_TO_OFFSET(addr) >> PGDIR_SHIFT]
 
+
+
+#ifdef CONFIG_VIRTUAL_MEM_MAP_HUGE
+#define VIRTUAL_MEM_MAP_PAGE_SHIFT	_PAGE_SIZE_1M
+#define VIRTUAL_MEM_MAP			VKP_AREA(VIRTUAL_MEM_MAP_PAGE_SHIFT)
+#else
+#define VIRTUAL_MEM_MAP_PAGE_SHIFT	PAGE_SHIFT
+#define VIRTUAL_MEM_MAP			(RGN_BASE(RGN_GATE) + 0x200000000)
+#endif
+
 # ifndef __ASSEMBLY__
 
 #include <linux/sched.h>	/* for mm_struct */
@@ -306,8 +313,12 @@ ia64_phys_addr_valid (unsigned long addr
 #define VIRTUAL_MEM_MAP_SIZE 0
 #endif
 
-#define VMALLOC_START  (VIRTUAL_MEM_MAP + VIRTUAL_MEM_MAP_SIZE)
-#define VMALLOC_END    (RGN_BASE(RGN_GATE) + (1UL << (4*PAGE_SHIFT - 9)))
+#ifdef CONFIG_VIRTUAL_MEM_MAP_HUGE
+#define VMALLOC_START	(RGN_BASE(RGN_GATE) + 0x200000000)
+#else
+#define VMALLOC_START	(VIRTUAL_MEM_MAP + VIRTUAL_MEM_MAP_SIZE)
+#endif
+#define VMALLOC_END	(RGN_BASE(RGN_GATE) + (1UL << (4*PAGE_SHIFT - 9)))
 
 /* fs/proc/kcore.c */
 #define	kc_vaddr_to_offset(v) ((v) - RGN_BASE(RGN_GATE))
@@ -518,7 +529,7 @@ pte_same (pte_t a, pte_t b)
 #define update_mmu_cache(vma, address, pte) do { } while (0)
 
 extern pgd_t swapper_pg_dir[PTRS_PER_PGD];
-extern pgd_t region7_pg_dir[8][PTRS_PER_PGD];
+extern pgd_t region7_pg_dir[8][PTRS_PER_PGD / 8];
 extern void paging_init (void);
 
 /*
