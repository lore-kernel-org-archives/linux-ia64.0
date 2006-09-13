From: Jes Sorensen <jes@sgi.com>
Date: Wed, 13 Sep 2006 12:43:42 +0000
Subject: [patch] show_mem() printk levels
Message-Id: <yq04pvcey2p.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

This falls into the cosmetics department, but at least it makes us
consistent with other architectures.

Cheers,
Jes


Use the default sysrq printk level for printing show_mem() output both
for disconfig and contig versions. This is consistent with the printk
level used on other architectures (well ia32 at least).

Signed-off-by: Jes Sorensen <jes@sgi.com>

---
 arch/ia64/mm/contig.c    |   17 +++++++++--------
 arch/ia64/mm/discontig.c |   29 +++++++++++++++--------------
 2 files changed, 24 insertions(+), 22 deletions(-)

Index: linux-2.6/arch/ia64/mm/contig.c
=================================--- linux-2.6.orig/arch/ia64/mm/contig.c
+++ linux-2.6/arch/ia64/mm/contig.c
@@ -41,10 +41,11 @@ show_mem (void)
 	int i, total = 0, reserved = 0;
 	int shared = 0, cached = 0;
 
-	printk("Mem-info:\n");
+	printk(KERN_INFO "Mem-info:\n");
 	show_free_areas();
 
-	printk("Free swap:       %6ldkB\n", nr_swap_pages<<(PAGE_SHIFT-10));
+	printk(KERN_INFO "Free swap:       %6ldkB\n",
+	       nr_swap_pages<<(PAGE_SHIFT-10));
 	i = max_mapnr;
 	for (i = 0; i < max_mapnr; i++) {
 		if (!pfn_valid(i)) {
@@ -63,12 +64,12 @@ show_mem (void)
 		else if (page_count(mem_map + i))
 			shared += page_count(mem_map + i) - 1;
 	}
-	printk("%d pages of RAM\n", total);
-	printk("%d reserved pages\n", reserved);
-	printk("%d pages shared\n", shared);
-	printk("%d pages swap cached\n", cached);
-	printk("%ld pages in page table cache\n",
-		pgtable_quicklist_total_size());
+	printk(KERN_INFO "%d pages of RAM\n", total);
+	printk(KERN_INFO "%d reserved pages\n", reserved);
+	printk(KERN_INFO "%d pages shared\n", shared);
+	printk(KERN_INFO "%d pages swap cached\n", cached);
+	printk(KERN_INFO "%ld pages in page table cache\n",
+	       pgtable_quicklist_total_size());
 }
 
 /* physical address where the bootmem map is located */
Index: linux-2.6/arch/ia64/mm/discontig.c
=================================--- linux-2.6.orig/arch/ia64/mm/discontig.c
+++ linux-2.6/arch/ia64/mm/discontig.c
@@ -547,15 +547,16 @@ void show_mem(void)
 	unsigned long total_present = 0;
 	pg_data_t *pgdat;
 
-	printk("Mem-info:\n");
+	printk(KERN_INFO "Mem-info:\n");
 	show_free_areas();
-	printk("Free swap:       %6ldkB\n", nr_swap_pages<<(PAGE_SHIFT-10));
+	printk(KERN_INFO "Free swap:       %6ldkB\n",
+	       nr_swap_pages<<(PAGE_SHIFT-10));
 	for_each_online_pgdat(pgdat) {
 		unsigned long present;
 		unsigned long flags;
 		int shared = 0, cached = 0, reserved = 0;
 
-		printk("Node ID: %d\n", pgdat->node_id);
+		printk(KERN_INFO "Node ID: %d\n", pgdat->node_id);
 		pgdat_resize_lock(pgdat, &flags);
 		present = pgdat->node_present_pages;
 		for(i = 0; i < pgdat->node_spanned_pages; i++) {
@@ -579,18 +580,18 @@ void show_mem(void)
 		total_reserved += reserved;
 		total_cached += cached;
 		total_shared += shared;
-		printk("\t%ld pages of RAM\n", present);
-		printk("\t%d reserved pages\n", reserved);
-		printk("\t%d pages shared\n", shared);
-		printk("\t%d pages swap cached\n", cached);
+		printk(KERN_INFO "\t%ld pages of RAM\n", present);
+		printk(KERN_INFO "\t%d reserved pages\n", reserved);
+		printk(KERN_INFO "\t%d pages shared\n", shared);
+		printk(KERN_INFO "\t%d pages swap cached\n", cached);
 	}
-	printk("%ld pages of RAM\n", total_present);
-	printk("%d reserved pages\n", total_reserved);
-	printk("%d pages shared\n", total_shared);
-	printk("%d pages swap cached\n", total_cached);
-	printk("Total of %ld pages in page table cache\n",
-		pgtable_quicklist_total_size());
-	printk("%d free buffer pages\n", nr_free_buffer_pages());
+	printk(KERN_INFO "%ld pages of RAM\n", total_present);
+	printk(KERN_INFO "%d reserved pages\n", total_reserved);
+	printk(KERN_INFO "%d pages shared\n", total_shared);
+	printk(KERN_INFO "%d pages swap cached\n", total_cached);
+	printk(KERN_INFO "Total of %ld pages in page table cache\n",
+	       pgtable_quicklist_total_size());
+	printk(KERN_INFO "%d free buffer pages\n", nr_free_buffer_pages());
 }
 
 /**
