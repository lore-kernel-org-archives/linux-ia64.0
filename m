From: mita akinobu <amgta@yacht.ocn.ne.jp>
Date: Sun, 05 Sep 2004 16:32:03 +0000
Subject: [PATCH] ia64: fix show_mem() for discontig machines
Message-Id: <200409060132.03951.amgta@yacht.ocn.ne.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org
Cc: linux-kernel@vger.kernel.org

Hello,

On multi-node ia64 system, SysRq-M seems to dump wrong memory info.
(Since I don't have such a large machine, I don't confirm it)
It should reset counters every iteration each node in show_mem().

Signed-off-by: Akinobu Mita <mita@yacht.ocn.ne.jp>

--- 2.6/arch/ia64/mm/discontig.c.orig	2004-09-01 13:31:09.000000000 +0900
+++ 2.6/arch/ia64/mm/discontig.c	2004-09-01 13:37:39.000000000 +0900
@@ -492,14 +492,17 @@ void *per_cpu_init(void)
  */
 void show_mem(void)
 {
-	int i, reserved = 0;
-	int shared = 0, cached = 0;
+	int i, total_reserved = 0;
+	int total_shared = 0, total_cached = 0;
+	unsigned long total_present = 0;
 	pg_data_t *pgdat;
 
 	printk("Mem-info:\n");
 	show_free_areas();
 	printk("Free swap:       %6ldkB\n", nr_swap_pages<<(PAGE_SHIFT-10));
 	for_each_pgdat(pgdat) {
+		unsigned long present = pgdat->node_present_pages;
+		int shared = 0, cached = 0, reserved = 0;
 		printk("Node ID: %d\n", pgdat->node_id);
 		for(i = 0; i < pgdat->node_spanned_pages; i++) {
 			if (!ia64_pfn_valid(pgdat->node_start_pfn+i))
@@ -511,11 +514,19 @@ void show_mem(void)
 			else if (page_count(pgdat->node_mem_map+i))
 				shared += page_count(pgdat->node_mem_map+i)-1;
 		}
-		printk("\t%ld pages of RAM\n", pgdat->node_present_pages);
+		total_present += present;
+		total_reserved += reserved;
+		total_cached += cached;
+		total_shared += shared;
+		printk("\t%ld pages of RAM\n", present);
 		printk("\t%d reserved pages\n", reserved);
 		printk("\t%d pages shared\n", shared);
 		printk("\t%d pages swap cached\n", cached);
 	}
+	printk("%ld pages of RAM\n", total_present);
+	printk("%d reserved pages\n", total_reserved);
+	printk("%d pages shared\n", total_shared);
+	printk("%d pages swap cached\n", total_cached);
 	printk("Total of %ld pages in page table cache\n", pgtable_cache_size);
 	printk("%d free buffer pages\n", nr_free_buffer_pages());
 }


