From: John Marvin <jsm@udlkern.fc.hp.com>
Date: Fri, 15 Nov 2002 00:17:20 +0000
Subject: [Linux-ia64] auto virtual map patch
Message-Id: <marc-linux-ia64-105590709805437@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Enclosed is a patch for 2.5 that is similar to what is going out with Red
Hat AS for ia64.  This makes the virtual mem map support "automatic", i.e.
it will use a virtual mem map if CONFIG_DISCONTIGMEM is not defined and a
gap of greater than 1 GB is found in the physical memory layout.

John Marvin
jsm@fc.hp.com

--- linux/arch/ia64/config.in.old	Fri Oct 18 17:47:26 2002
+++ linux/arch/ia64/config.in	Fri Oct 18 17:47:44 2002
@@ -51,8 +51,6 @@
 	 64KB			CONFIG_IA64_PAGE_SIZE_64KB" 16KB
 fi
 
-bool 'Virtually mapped mem_map?' CONFIG_VIRTUAL_MEM_MAP n
-
 if [ "$CONFIG_ITANIUM" = "y" ]; then
 	define_bool CONFIG_IA64_BRL_EMU y
 	bool '  Enable Itanium B-step specific code' CONFIG_ITANIUM_BSTEP_SPECIFIC
--- linux/arch/ia64/kernel/ia64_ksyms.c.old	Fri Oct 18 16:19:14 2002
+++ linux/arch/ia64/kernel/ia64_ksyms.c	Fri Oct 18 17:04:17 2002
@@ -57,6 +57,10 @@
 #include <asm/page.h>
 EXPORT_SYMBOL(clear_page);
 
+#include <asm/pgtable.h>
+EXPORT_SYMBOL(vmalloc_end);
+EXPORT_SYMBOL(ia64_page_valid);
+
 #include <asm/processor.h>
 # ifndef CONFIG_NUMA
 EXPORT_SYMBOL(_cpu_data);
--- linux/arch/ia64/mm/fault.c.old	Fri Oct 18 17:07:50 2002
+++ linux/arch/ia64/mm/fault.c	Fri Oct 18 21:48:47 2002
@@ -58,7 +58,6 @@
 	if (in_interrupt() || !mm)
 		goto no_context;
 
-#ifdef CONFIG_VIRTUAL_MEM_MAP
 	/*
 	 * If fault is in region 5 and we are in the kernel, we may already
          * have the mmap_sem (VALID_PAGE macro is called during mmap). There
@@ -67,7 +66,6 @@
   	 */
 	if ((REGION_NUMBER(address) = 5) && !user_mode(regs))
 		goto bad_area_no_up;
-#endif
 
 	down_read(&mm->mmap_sem);
 
@@ -148,9 +146,7 @@
 
   bad_area:
 	up_read(&mm->mmap_sem);
-#ifdef CONFIG_VIRTUAL_MEM_MAP
   bad_area_no_up:
-#endif
 	if ((isr & IA64_ISR_SP)
 	    || ((isr & IA64_ISR_NA) && (isr & IA64_ISR_CODE_MASK) = IA64_ISR_CODE_LFETCH))
 	{
--- linux/arch/ia64/mm/init.c.old	Fri Oct 18 17:09:54 2002
+++ linux/arch/ia64/mm/init.c	Thu Nov 14 06:57:20 2002
@@ -35,15 +35,14 @@
 extern void ia64_tlb_init (void);
 
 unsigned long MAX_DMA_ADDRESS = PAGE_OFFSET + 0x100000000UL;
+#define LARGE_GAP 0x40000000 /* Use virtual mem map if a hole is > than this */
 
 static unsigned long totalram_pages;
 
-#ifdef CONFIG_VIRTUAL_MEM_MAP
 unsigned long vmalloc_end = VMALLOC_END_INIT;
 
 static struct page *vmem_map;
 static unsigned long num_dma_physpages;
-#endif
 
 int
 do_check_pgt_cache (int low, int high)
@@ -357,10 +356,6 @@
 	ia64_tlb_init();
 }
 
-#ifdef CONFIG_VIRTUAL_MEM_MAP
-
-#include <asm/pgtable.h>
-
 static int
 create_mem_map_page_table (u64 start, u64 end, void *arg)
 {
@@ -413,8 +408,8 @@
 
 	/* Should we use platform_map_nr here? */
 
-	map_start = vmem_map + MAP_NR_DENSE(start);
-	map_end   = vmem_map + MAP_NR_DENSE(end);
+	map_start = mem_map + MAP_NR_DENSE(start);
+	map_end   = mem_map + MAP_NR_DENSE(end);
 
 	if (map_start < args->start)
 		map_start = args->start;
@@ -444,15 +439,19 @@
 arch_memmap_init (memmap_init_callback_t *memmap_init, struct page *start,
 	struct page *end, int zone, unsigned long start_paddr, int highmem)
 {
-	struct memmap_init_callback_data args;
+	if (!vmem_map) 
+		memmap_init(start,end,zone,page_to_phys(start),highmem);
+	else {
+		struct memmap_init_callback_data args;
 
-	args.memmap_init = memmap_init;
-	args.start = start;
-	args.end = end;
-	args.zone = zone;
-	args.highmem = highmem;
+		args.memmap_init = memmap_init;
+		args.start = start;
+		args.end = end;
+		args.zone = zone;
+		args.highmem = highmem;
 
-	efi_memmap_walk(virtual_memmap_init, &args);
+		efi_memmap_walk(virtual_memmap_init, &args);
+	}
 
 	return page_to_phys(end);
 }
@@ -475,8 +474,6 @@
 	return __get_user(byte, (char *) page) = 0;
 }
 
-#endif /* CONFIG_VIRTUAL_MEM_MAP */
-
 static int
 count_pages (u64 start, u64 end, void *arg)
 {
@@ -486,47 +483,75 @@
 	return 0;
 }
 
+#ifndef CONFIG_DISCONTIGMEM
+static int
+find_largest_hole(u64 start, u64 end, void *arg)
+{
+	u64 *max_gap = arg;
+	static u64 last_end = PAGE_OFFSET;
+
+	/* NOTE: this algorithm assumes efi memmap table is ordered */
+
+	if (*max_gap < (start - last_end))
+		*max_gap = start - last_end;
+	last_end = end;
+	return 0;
+}
+#endif
+
 /*
  * Set up the page tables.
  */
 void
 paging_init (void)
 {
-	unsigned long max_dma, zones_size[MAX_NR_ZONES];
+	unsigned long max_dma;
+	unsigned long zones_size[MAX_NR_ZONES];
+	unsigned long zholes_size[MAX_NR_ZONES];
+#ifndef CONFIG_DISCONTIGMEM
+	unsigned long max_gap;
+#endif
 
 	/* initialize mem_map[] */
 
 	memset(zones_size, 0, sizeof(zones_size));
+	memset(zholes_size, 0, sizeof(zholes_size));
 
 	num_physpages = 0;
 	efi_memmap_walk(count_pages, &num_physpages);
 
-	max_dma = virt_to_phys((void *) MAX_DMA_ADDRESS) >> PAGE_SHIFT;
+	num_dma_physpages = 0;
+	efi_memmap_walk(count_dma_pages, &num_dma_physpages);
 
-#ifdef CONFIG_VIRTUAL_MEM_MAP
-	{
-		unsigned long zholes_size[MAX_NR_ZONES];
-		unsigned long map_size;
+	max_dma = virt_to_phys((void *) MAX_DMA_ADDRESS) >> PAGE_SHIFT;
 
-		memset(zholes_size, 0, sizeof(zholes_size));
+	if (max_low_pfn < max_dma) {
+		zones_size[ZONE_DMA] = max_low_pfn;
+		zholes_size[ZONE_DMA] = max_low_pfn - num_dma_physpages;
+	} else {
+		zones_size[ZONE_DMA] = max_dma;
+		zholes_size[ZONE_DMA] = max_dma - num_dma_physpages;
+		if (num_physpages > num_dma_physpages) {
+			zones_size[ZONE_NORMAL] = max_low_pfn - max_dma;
+			zholes_size[ZONE_NORMAL] = (max_low_pfn - max_dma)
+					- (num_physpages - num_dma_physpages);
+		}
+	}
 
-		num_dma_physpages = 0;
-		efi_memmap_walk(count_dma_pages, &num_dma_physpages);
+#ifdef CONFIG_DISCONTIGMEM
+	free_area_init_node(0, NULL, NULL, zones_size, 0, zholes_size);
+#else
+	max_gap = 0;
+	efi_memmap_walk(find_largest_hole, (u64 *)&max_gap);
 
-		if (max_low_pfn < max_dma) {
-			zones_size[ZONE_DMA] = max_low_pfn;
-			zholes_size[ZONE_DMA] = max_low_pfn - num_dma_physpages;
-		} else {
-			zones_size[ZONE_DMA] = max_dma;
-			zholes_size[ZONE_DMA] = max_dma - num_dma_physpages;
-			if (num_physpages > num_dma_physpages) {
-				zones_size[ZONE_NORMAL] = max_low_pfn - max_dma;
-				zholes_size[ZONE_NORMAL] = ((max_low_pfn - max_dma)
-							    - (num_physpages - num_dma_physpages));
-			}
-		}
+	if (max_gap < LARGE_GAP) {
+		vmem_map = (struct page *)0;
+		free_area_init_node(0, NULL, NULL, zones_size, 0, zholes_size);
+	}
+	else {
+		unsigned long map_size;
 
-		/* allocate virtual mem_map: */
+		/* allocate virtual mem_map */
 
 		map_size = PAGE_ALIGN(max_low_pfn*sizeof(struct page));
 		vmalloc_end -= map_size;
@@ -536,15 +561,7 @@
 		free_area_init_node(0, NULL, vmem_map, zones_size, 0, zholes_size);
 		printk("Virtual mem_map starts at 0x%p\n", mem_map);
 	}
-#else /* !CONFIG_VIRTUAL_MEM_MAP */
-	if (max_low_pfn < max_dma)
-		zones_size[ZONE_DMA] = max_low_pfn;
-	else {
-		zones_size[ZONE_DMA] = max_dma;
-		zones_size[ZONE_NORMAL] = max_low_pfn - max_dma;
-	}
-	free_area_init(zones_size);
-#endif /* !CONFIG_VIRTUAL_MEM_MAP */
+#endif
 }
 
 static int
--- linux/include/asm-ia64/page.h.old	Fri Oct 18 17:33:40 2002
+++ linux/include/asm-ia64/page.h	Wed Oct 23 16:57:01 2002
@@ -65,13 +65,10 @@
 # define virt_to_page(kaddr)	(mem_map + MAP_NR_DENSE(kaddr))
 # define page_to_phys(page)	((page - mem_map) << PAGE_SHIFT)
 #endif
-#ifdef CONFIG_VIRTUAL_MEM_MAP
-  struct page;
-  extern int ia64_page_valid (struct page *);
-# define VALID_PAGE(page)	(((page - mem_map) < max_mapnr) && ia64_page_valid(page))
-#else
-# define VALID_PAGE(page)	((page - mem_map) < max_mapnr)
-#endif
+
+struct page;
+extern int ia64_page_valid (struct page *);
+#define VALID_PAGE(page)	(((page - mem_map) < max_mapnr) && ia64_page_valid(page))
 
 typedef union ia64_va {
 	struct {
--- linux/include/asm-ia64/pgtable.h.old	Fri Oct 18 17:44:55 2002
+++ linux/include/asm-ia64/pgtable.h	Wed Oct 23 16:57:03 2002
@@ -198,13 +198,9 @@
 
 #define VMALLOC_START		(0xa000000000000000 + 3*PAGE_SIZE)
 #define VMALLOC_VMADDR(x)	((unsigned long)(x))
-#ifdef CONFIG_VIRTUAL_MEM_MAP
-# define VMALLOC_END_INIT        (0xa000000000000000 + (1UL << (4*PAGE_SHIFT - 9))) 
-# define VMALLOC_END             vmalloc_end
-  extern unsigned long vmalloc_end;
-#else
-# define VMALLOC_END		(0xa000000000000000 + (1UL << (4*PAGE_SHIFT - 9)))
-#endif
+#define VMALLOC_END_INIT        (0xa000000000000000 + (1UL << (4*PAGE_SHIFT - 9))) 
+#define VMALLOC_END             vmalloc_end
+extern unsigned long vmalloc_end;
 
 /*
  * Conversion functions: convert a page and protection to a page entry,
@@ -448,8 +444,6 @@
  */
 #define pgtable_cache_init()	do { } while (0)
 
-#ifdef CONFIG_VIRTUAL_MEM_MAP
-
 /* arch mem_map init routines are needed due to holes in a virtual mem_map */
 #define HAVE_ARCH_MEMMAP_INIT
 
@@ -460,8 +454,6 @@
 	struct page *start, struct page *end, int zone,
 	unsigned long start_paddr, int highmem);
 
-#endif /* CONFIG_VIRTUAL_MEM_MAP */
-
 # endif /* !__ASSEMBLY__ */
 
 /*

