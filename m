From: Tony Luck <tony.luck@intel.com>
Date: Mon, 27 Sep 2004 22:33:10 +0000
Subject: [PATCH] clean up contig/discontig/virt_mem_map macros
Message-Id: <200409272233.i8RMXAV32176@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I got this patch from Zou Nan hai to resolve the problem that
Andrew Morton has been having booting his ia64 system.  The code
is quite a bit cleaner as he has reduced the number of different
definitions of pfn_valid/page_to_pfn/pfn_to_page, and left the
only remaining ones next to each other in page.h ... so this
should be easier to maintain going forward.

It has been tested on a variety of systems:

	1G Tiger \  Tested by Zou Nan hai, I assume DIG=y, NUMA=n
	8G Tiger /  but I don't know for sure.
	4G Tiger with generic_defconfig
	4G Tiger with DIG kernel, NUMA, DISCONTIG and VIRTUAL_MEM_MAP on
	4G Tiger with DIG kernel, NUMA/DISCONTIG off; VIRTUAL_MEM_MAP on
	HP zx2000 with zx1_defconfig

Can someone please check it on sn2 (sn2_defconfig compiles, but I haven't
booted it) ... and any other systems or configurations that don't match
any of the above.  I'd like to stop carrying the BPB that Andrew gave
me.

-Tony

diff -Nraup a/arch/ia64/mm/contig.c b/arch/ia64/mm/contig.c
--- a/arch/ia64/mm/contig.c	2004-09-12 22:32:00.000000000 -0700
+++ b/arch/ia64/mm/contig.c	2004-09-26 04:36:46.944608285 -0700
@@ -269,7 +269,6 @@ paging_init (void)
 		vmem_map = (struct page *) 0;
 		free_area_init_node(0, &contig_page_data, zones_size, 0,
 				    zholes_size);
-		mem_map = contig_page_data.node_mem_map;
 	} else {
 		unsigned long map_size;
 
@@ -280,11 +279,10 @@ paging_init (void)
 		vmem_map = (struct page *) vmalloc_end;
 		efi_memmap_walk(create_mem_map_page_table, 0);
 
-		contig_page_data.node_mem_map = vmem_map;
+		mem_map = contig_page_data.node_mem_map = vmem_map;
 		free_area_init_node(0, &contig_page_data, zones_size,
 				    0, zholes_size);
 
-		mem_map = contig_page_data.node_mem_map;
 		printk("Virtual mem_map starts at 0x%p\n", mem_map);
 	}
 #else /* !CONFIG_VIRTUAL_MEM_MAP */
diff -Nraup a/include/asm-ia64/mmzone.h b/include/asm-ia64/mmzone.h
--- a/include/asm-ia64/mmzone.h	2004-09-12 22:33:39.000000000 -0700
+++ b/include/asm-ia64/mmzone.h	2004-09-26 04:37:13.863553267 -0700
@@ -27,12 +27,6 @@
 # define NR_NODE_MEMBLKS	(NR_NODES * 4)
 #endif
 
-extern unsigned long max_low_pfn;
-
-#define pfn_valid(pfn)		(((pfn) < max_low_pfn) && ia64_pfn_valid(pfn))
-#define page_to_pfn(page)	((unsigned long) (page - vmem_map))
-#define pfn_to_page(pfn)	(vmem_map + (pfn))
-
 #else /* CONFIG_DISCONTIGMEM */
 # define NR_NODE_MEMBLKS	4
 #endif /* CONFIG_DISCONTIGMEM */
diff -Nraup a/include/asm-ia64/page.h b/include/asm-ia64/page.h
--- a/include/asm-ia64/page.h	2004-09-12 22:31:43.000000000 -0700
+++ b/include/asm-ia64/page.h	2004-09-26 04:36:59.530545630 -0700
@@ -84,17 +84,16 @@ extern int ia64_pfn_valid (unsigned long
 #endif
 
 #ifndef CONFIG_DISCONTIGMEM
-# ifdef CONFIG_VIRTUAL_MEM_MAP
+# define pfn_valid(pfn)		(((pfn) < max_mapnr) && ia64_pfn_valid(pfn))
+# define page_to_pfn(page)	((unsigned long) (page - mem_map))
+# define pfn_to_page(pfn)	(mem_map + (pfn))
+#else
 extern struct page *vmem_map;
-#  define pfn_valid(pfn)	(((pfn) < max_mapnr) && ia64_pfn_valid(pfn))
-#  define page_to_pfn(page)	((unsigned long) (page - vmem_map))
-#  define pfn_to_page(pfn)	(vmem_map + (pfn))
-# else
-#  define pfn_valid(pfn)	(((pfn) < max_mapnr) && ia64_pfn_valid(pfn))
-#  define page_to_pfn(page)	((unsigned long) (page - mem_map))
-#  define pfn_to_page(pfn)	(mem_map + (pfn))
-# endif
-#endif /* CONFIG_DISCONTIGMEM */
+extern unsigned long max_low_pfn;
+# define pfn_valid(pfn)		(((pfn) < max_low_pfn) && ia64_pfn_valid(pfn))
+# define page_to_pfn(page)	((unsigned long) (page - vmem_map))
+# define pfn_to_page(pfn)	(vmem_map + (pfn))
+#endif
 
 #define page_to_phys(page)	(page_to_pfn(page) << PAGE_SHIFT)
 #define virt_to_page(kaddr)	pfn_to_page(__pa(kaddr) >> PAGE_SHIFT)
