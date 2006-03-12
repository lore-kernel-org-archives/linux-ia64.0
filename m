From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Sun, 12 Mar 2006 17:04:54 +0000
Subject: [patch 3/6] add init declaration to memory initialization functions
Message-Id: <200603121704.k2CH4qg10206@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Add init declaration to variables/functions used for memory
initialization.  I don't think they would clash with memory
hotplug.  If they do, please yell.


Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>


--- ./arch/ia64/kernel/setup.c.orig	2006-03-12 00:25:16.844400279 -0800
+++ ./arch/ia64/kernel/setup.c	2006-03-12 00:25:52.983071711 -0800
@@ -131,8 +131,8 @@ EXPORT_SYMBOL(ia64_max_iommu_merge_mask)
 /*
  * We use a special marker for the end of memory and it uses the extra (+1) slot
  */
-struct rsvd_region rsvd_region[IA64_MAX_RSVD_REGIONS + 1];
-int num_rsvd_regions;
+struct rsvd_region rsvd_region[IA64_MAX_RSVD_REGIONS + 1] __initdata;
+static int num_rsvd_regions __initdata;
 
 
 /*
@@ -141,7 +141,7 @@ int num_rsvd_regions;
  * caller-specified function is called with the memory ranges that remain after filtering.
  * This routine does not assume the incoming segments are sorted.
  */
-int
+int __init
 filter_rsvd_memory (unsigned long start, unsigned long end, void *arg)
 {
 	unsigned long range_start, range_end, prev_start;
@@ -177,7 +177,7 @@ filter_rsvd_memory (unsigned long start,
 	return 0;
 }
 
-static void
+static void __init
 sort_regions (struct rsvd_region *rsvd_region, int max)
 {
 	int j;
@@ -218,7 +218,7 @@ __initcall(register_memory);
  * initrd, etc.  There are currently %IA64_MAX_RSVD_REGIONS defined,
  * see include/asm-ia64/meminit.h if you need to define more.
  */
-void
+void __init
 reserve_memory (void)
 {
 	int n = 0;
@@ -270,7 +270,7 @@ reserve_memory (void)
  * Grab the initrd start and end from the boot parameter struct given us by
  * the boot loader.
  */
-void
+void __init
 find_initrd (void)
 {
 #ifdef CONFIG_BLK_DEV_INITRD
--- ./arch/ia64/mm/init.c.orig	2006-03-12 00:25:16.848306529 -0800
+++ ./arch/ia64/mm/init.c	2006-03-12 00:23:05.937175000 -0800
@@ -206,7 +206,7 @@ free_initmem (void)
 	       (__init_end - __init_begin) >> 10);
 }
 
-void
+void __init
 free_initrd_mem (unsigned long start, unsigned long end)
 {
 	struct page *page;
@@ -261,7 +261,7 @@ free_initrd_mem (unsigned long start, un
 /*
  * This installs a clean page in the kernel's page table.
  */
-struct page *
+static struct page * __init
 put_kernel_page (struct page *page, unsigned long address, pgprot_t pgprot)
 {
 	pgd_t *pgd;
@@ -411,7 +411,7 @@ ia64_mmu_init (void *my_cpu_data)
 
 #ifdef CONFIG_VIRTUAL_MEM_MAP
 
-int
+int __init
 create_mem_map_page_table (u64 start, u64 end, void *arg)
 {
 	unsigned long address, start_page, end_page;
@@ -519,7 +519,7 @@ ia64_pfn_valid (unsigned long pfn)
 }
 EXPORT_SYMBOL(ia64_pfn_valid);
 
-int
+int __init
 find_largest_hole (u64 start, u64 end, void *arg)
 {
 	u64 *max_gap = arg;
@@ -535,7 +535,7 @@ find_largest_hole (u64 start, u64 end, v
 }
 #endif /* CONFIG_VIRTUAL_MEM_MAP */
 
-static int
+static int __init
 count_reserved_pages (u64 start, u64 end, void *arg)
 {
 	unsigned long num_reserved = 0;
@@ -567,7 +567,7 @@ nolwsys_setup (char *s)
 
 __setup("nolwsys", nolwsys_setup);
 
-void
+void __init
 mem_init (void)
 {
 	long reserved_pages, codesize, datasize, initsize;
--- ./arch/ia64/mm/contig.c.orig	2006-01-02 19:21:10.000000000 -0800
+++ ./arch/ia64/mm/contig.c	2006-03-12 00:25:52.983071711 -0800
@@ -97,7 +97,7 @@ find_max_pfn (unsigned long start, unsig
  * Find a place to put the bootmap and return its starting address in
  * bootmap_start.  This address must be page-aligned.
  */
-int
+static int __init
 find_bootmap_location (unsigned long start, unsigned long end, void *arg)
 {
 	unsigned long needed = *(unsigned long *)arg;
@@ -141,7 +141,7 @@ find_bootmap_location (unsigned long sta
  * Walk the EFI memory map and find usable memory for the system, taking
  * into account reserved areas.
  */
-void
+void __init
 find_memory (void)
 {
 	unsigned long bootmap_size;
@@ -226,7 +226,7 @@ count_dma_pages (u64 start, u64 end, voi
  * Set up the page tables.
  */
 
-void
+void __init
 paging_init (void)
 {
 	unsigned long max_dma;



