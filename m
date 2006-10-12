From: Christoph Lameter <clameter@sgi.com>
Date: Thu, 12 Oct 2006 19:18:28 +0000
Subject: [PATCH 4/4] vmm: Use a static memory map
Message-Id: <20061012191828.21498.95831.sendpatchset@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

IA64: Use a statically defined address space for the virtual memmap.

IA64 currently uses a dynamically configured memory map that is taken off
the end of VMALLOC space. This means that we do some tweaking with some
core constants that now refer to variables and we keep having to
get the address of the virtual memory map and the limits from memory.
This patch makes pfn_to_page and page_to_pfn possible without referencing
any memory location.

The VMALLOC area on IA64 is 128 Terabytes of space. A statically defined
page table for the possible 1 Petabytes of main memory requires:

Supported memory: 50 bits = 1 Petabyte

Amount of page structs needed for 16k pagesize:

50 address bits - 14 page bits = 36 bits.
This is 128 billion or 128 * 2^30

Size of struct page is 7 words = 56 bytes.
Round to next power of two = 64 bytes / 6 bits.

Amount of virtual address space needed is:
36 pfn bits + 6 bits = 42 bits = 8 Terabyte.

So, the size of the virtual memory map is always less than 8 Terabyte.

I think its reasonable to take these 8 Terabyte away from the 128 Terabyte
that we currently reserve for support for VMALLOC space.

Advantages:
- virt_to_page, page_address, pfn_to_page, page_to_pfn become simple address
  calculations without a memory reference.
- We no longer tinker around with VMALLOC_END. It is a true constant now.
- virt_to_page(), page_address(), pfn_to_page(), page_to_pfn() do not need any
  bootstrapping but can be used right waway.
- The plan is to further generalize the virtual mem map support
  in the Linux kernel. With this patch the virtual memory map
  is more independent from VMALLOC.
- This patch will enable later patches to move the virtual memory map into
  another region with a larger page size. Larger page sizes will reduce
  TLB pressure.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.19-rc1-mm1/include/asm-ia64/page.h
=================================--- linux-2.6.19-rc1-mm1.orig/include/asm-ia64/page.h	2006-10-04 19:57:05.000000000 -0700
+++ linux-2.6.19-rc1-mm1/include/asm-ia64/page.h	2006-10-12 11:50:18.445019681 -0700
@@ -106,11 +106,8 @@ extern int ia64_pfn_valid (unsigned long
 #endif
 
 #ifdef CONFIG_VIRTUAL_MEM_MAP
-extern struct page *vmem_map;
-#ifdef CONFIG_DISCONTIGMEM
-# define page_to_pfn(page)	((unsigned long) (page - vmem_map))
-# define pfn_to_page(pfn)	(vmem_map + (pfn))
-#endif
+#define page_to_pfn(page)	((unsigned long) (page - mem_map))
+#define pfn_to_page(pfn)	(mem_map + (pfn))
 #endif
 
 #if defined(CONFIG_FLATMEM) || defined(CONFIG_SPARSEMEM)
Index: linux-2.6.19-rc1-mm1/include/asm-ia64/pgtable.h
=================================--- linux-2.6.19-rc1-mm1.orig/include/asm-ia64/pgtable.h	2006-10-04 19:57:05.000000000 -0700
+++ linux-2.6.19-rc1-mm1/include/asm-ia64/pgtable.h	2006-10-12 11:50:18.445996183 -0700
@@ -133,6 +133,10 @@
 #define USER_PTRS_PER_PGD	(5*PTRS_PER_PGD/8)	/* regions 0-4 are user regions */
 #define FIRST_USER_ADDRESS	0
 
+#define RGN_MAP_SHIFT (PGDIR_SHIFT + PTRS_PER_PGD_SHIFT - 3)
+#define RGN_MAP_LIMIT	((1UL << RGN_MAP_SHIFT) - PAGE_SIZE)	/* per region addr limit */
+
+
 /*
  * All the normal masks have the "page accessed" bits on, as any time
  * they are used, the page is accessed. They are cleared only by the
@@ -147,6 +151,8 @@
 #define PAGE_KERNEL	__pgprot(__DIRTY_BITS  | _PAGE_PL_0 | _PAGE_AR_RWX)
 #define PAGE_KERNELRX	__pgprot(__ACCESS_BITS | _PAGE_PL_0 | _PAGE_AR_RX)
 
+#define VIRTUAL_MEM_MAP		(RGN_BASE(RGN_GATE) + 0x200000000)
+
 # ifndef __ASSEMBLY__
 
 #include <linux/sched.h>	/* for mm_struct */
@@ -230,22 +236,27 @@ ia64_phys_addr_valid (unsigned long addr
 #define set_pte(ptep, pteval)	(*(ptep) = (pteval))
 #define set_pte_at(mm,addr,ptep,pteval) set_pte(ptep,pteval)
 
-#define VMALLOC_START		(RGN_BASE(RGN_GATE) + 0x200000000UL)
+/*
+ * STRUCT_PAGE_ORDER is needed to approximate the size of struct page
+ * that is unknown at this point. struct page must be smaller than
+ * 1 << STRUCT_PAGE_ORDER.
+ */
+#define STRUCT_PAGE_ORDER      6
+
 #ifdef CONFIG_VIRTUAL_MEM_MAP
-# define VMALLOC_END_INIT	(RGN_BASE(RGN_GATE) + (1UL << (4*PAGE_SHIFT - 9)))
-# define VMALLOC_END		vmalloc_end
-  extern unsigned long vmalloc_end;
+#define VIRTUAL_MEM_MAP_SIZE   (1UL << (IA64_MAX_PHYS_BITS - PAGE_SHIFT +\
+					STRUCT_PAGE_ORDER))
 #else
-# define VMALLOC_END		(RGN_BASE(RGN_GATE) + (1UL << (4*PAGE_SHIFT - 9)))
+#define VIRTUAL_MEM_MAP_SIZE 0
 #endif
 
+#define VMALLOC_START  (VIRTUAL_MEM_MAP + VIRTUAL_MEM_MAP_SIZE)
+#define VMALLOC_END    (RGN_BASE(RGN_GATE) + (1UL << (4*PAGE_SHIFT - 9)))
+
 /* fs/proc/kcore.c */
 #define	kc_vaddr_to_offset(v) ((v) - RGN_BASE(RGN_GATE))
 #define	kc_offset_to_vaddr(o) ((o) + RGN_BASE(RGN_GATE))
 
-#define RGN_MAP_SHIFT (PGDIR_SHIFT + PTRS_PER_PGD_SHIFT - 3)
-#define RGN_MAP_LIMIT	((1UL << RGN_MAP_SHIFT) - PAGE_SIZE)	/* per region addr limit */
-
 /*
  * Conversion functions: convert page frame number (pfn) and a protection value to a page
  * table entry (pte).
Index: linux-2.6.19-rc1-mm1/arch/ia64/mm/discontig.c
=================================--- linux-2.6.19-rc1-mm1.orig/arch/ia64/mm/discontig.c	2006-10-12 11:50:12.930711100 -0700
+++ linux-2.6.19-rc1-mm1/arch/ia64/mm/discontig.c	2006-10-12 11:50:18.447949188 -0700
@@ -695,11 +695,7 @@ void __init paging_init(void)
 	efi_memmap_walk(filter_rsvd_memory, count_node_pages);
 
 #ifdef CONFIG_VIRTUAL_MEM_MAP
-	vmalloc_end -= PAGE_ALIGN(ALIGN(max_low_pfn, MAX_ORDER_NR_PAGES) *
-		sizeof(struct page));
-	vmem_map = (struct page *) vmalloc_end;
 	efi_memmap_walk(create_mem_map_page_table, NULL);
-	printk("Virtual mem_map starts at 0x%p\n", vmem_map);
 #endif
 
 	for_each_online_node(node) {
Index: linux-2.6.19-rc1-mm1/arch/ia64/mm/init.c
=================================--- linux-2.6.19-rc1-mm1.orig/arch/ia64/mm/init.c	2006-10-12 11:50:16.833790859 -0700
+++ linux-2.6.19-rc1-mm1/arch/ia64/mm/init.c	2006-10-12 11:50:18.447949188 -0700
@@ -45,13 +45,6 @@ extern void ia64_tlb_init (void);
 
 unsigned long MAX_DMA_ADDRESS = PAGE_OFFSET + 0x100000000UL;
 
-#ifdef CONFIG_VIRTUAL_MEM_MAP
-unsigned long vmalloc_end = VMALLOC_END_INIT;
-EXPORT_SYMBOL(vmalloc_end);
-struct page *vmem_map;
-EXPORT_SYMBOL(vmem_map);
-#endif
-
 struct page *zero_page_memmap_ptr;	/* map entry for zero page */
 EXPORT_SYMBOL(zero_page_memmap_ptr);
 
@@ -415,6 +408,9 @@ ia64_mmu_init (void *my_cpu_data)
 }
 
 #ifdef CONFIG_VIRTUAL_MEM_MAP
+
+EXPORT_SYMBOL(mem_map);
+
 int vmemmap_find_next_valid_pfn(int node, int i)
 {
 	unsigned long end_address, hole_next_pfn;
@@ -461,12 +457,11 @@ retry_pte:
 				goto retry_pte;
 			continue;
 		}
-		/* Found next valid vmem_map page */
 		break;
 	} while (end_address < stop_address);
 
 	end_address = min(end_address, stop_address);
-	end_address = end_address - (unsigned long) vmem_map + sizeof(struct page) - 1;
+	end_address = end_address - VIRTUAL_MEM_MAP + sizeof(struct page) - 1;
 	hole_next_pfn = end_address / sizeof(struct page);
 	return hole_next_pfn - pgdat->node_start_pfn;
 }
@@ -551,20 +546,16 @@ void
 memmap_init (unsigned long size, int nid, unsigned long zone,
 	     unsigned long start_pfn)
 {
-	if (!vmem_map)
-		memmap_init_zone(size, nid, zone, start_pfn);
-	else {
-		struct page *start;
-		struct memmap_init_callback_data args;
-
-		start = pfn_to_page(start_pfn);
-		args.start = start;
-		args.end = start + size;
-		args.nid = nid;
-		args.zone = zone;
+	struct page *start;
+	struct memmap_init_callback_data args;
 
-		efi_memmap_walk(virtual_memmap_init, &args);
-	}
+	start = pfn_to_page(start_pfn);
+	args.start = start;
+	args.end = start + size;
+	args.nid = nid;
+	args.zone = zone;
+
+	efi_memmap_walk(virtual_memmap_init, &args);
 }
 
 int
Index: linux-2.6.19-rc1-mm1/include/asm-ia64/meminit.h
=================================--- linux-2.6.19-rc1-mm1.orig/include/asm-ia64/meminit.h	2006-10-11 17:54:04.009774363 -0700
+++ linux-2.6.19-rc1-mm1/include/asm-ia64/meminit.h	2006-10-12 11:50:18.462596723 -0700
@@ -53,8 +53,6 @@ extern void efi_memmap_init(unsigned lon
 
 #ifdef CONFIG_VIRTUAL_MEM_MAP
 # define LARGE_GAP	0x40000000 /* Use virtual mem map if hole is > than this */
-  extern unsigned long vmalloc_end;
-  extern struct page *vmem_map;
   extern int find_largest_hole (u64 start, u64 end, void *arg);
   extern int register_active_ranges (u64 start, u64 end, void *arg);
   extern int create_mem_map_page_table (u64 start, u64 end, void *arg);
Index: linux-2.6.19-rc1-mm1/arch/ia64/mm/contig.c
=================================--- linux-2.6.19-rc1-mm1.orig/arch/ia64/mm/contig.c	2006-10-11 17:54:00.344961355 -0700
+++ linux-2.6.19-rc1-mm1/arch/ia64/mm/contig.c	2006-10-12 11:50:18.474314751 -0700
@@ -246,22 +246,7 @@ paging_init (void)
 		vmem_map = (struct page *) 0;
 		free_area_init_nodes(max_zone_pfns);
 	} else {
-		unsigned long map_size;
-
-		/* allocate virtual_mem_map */
-
-		map_size = PAGE_ALIGN(ALIGN(max_low_pfn, MAX_ORDER_NR_PAGES) *
-			sizeof(struct page));
-		vmalloc_end -= map_size;
-		vmem_map = (struct page *) vmalloc_end;
 		efi_memmap_walk(create_mem_map_page_table, NULL);
-
-		/*
-		 * alloc_node_mem_map makes an adjustment for mem_map
-		 * which isn't compatible with vmem_map.
-		 */
-		NODE_DATA(0)->node_mem_map = vmem_map +
-			find_min_pfn_with_active_regions();
 		free_area_init_nodes(max_zone_pfns);
 
 		printk("Virtual mem_map starts at 0x%p\n", mem_map);
Index: linux-2.6.19-rc1-mm1/arch/ia64/kernel/vmlinux.lds.S
=================================--- linux-2.6.19-rc1-mm1.orig/arch/ia64/kernel/vmlinux.lds.S	2006-10-12 11:49:52.396820389 -0700
+++ linux-2.6.19-rc1-mm1/arch/ia64/kernel/vmlinux.lds.S	2006-10-12 11:50:18.475291253 -0700
@@ -34,6 +34,9 @@ SECTIONS
 
   v = PAGE_OFFSET;	/* this symbol is here to make debugging easier... */
   phys_start = _start - LOAD_OFFSET;
+#ifdef CONFIG_VIRTUAL_MEM_MAP
+  mem_map = VIRTUAL_MEM_MAP;
+#endif
 
   code : { } :code
   . = KERNEL_START;
Index: linux-2.6.19-rc1-mm1/include/linux/mm.h
=================================--- linux-2.6.19-rc1-mm1.orig/include/linux/mm.h	2006-10-11 17:54:04.254876433 -0700
+++ linux-2.6.19-rc1-mm1/include/linux/mm.h	2006-10-12 11:50:18.486032778 -0700
@@ -25,6 +25,15 @@ struct anon_vma;
 extern unsigned long max_mapnr;
 #endif
 
+#ifdef CONFIG_VIRTUAL_MEM_MAP
+/*
+ * Memory map at a fixed address that can be used to realize basic
+ * VM address conversions without a single memory access,
+ * can be sparsely populated and span multiple NUMA nodes.
+ */
+extern struct page mem_map[];
+#endif
+
 extern unsigned long num_physpages;
 extern void * high_memory;
 extern unsigned long vmalloc_earlyreserve;
