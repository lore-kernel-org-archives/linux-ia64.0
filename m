From: Jesse Barnes <jbarnes@sgi.com>
Date: Thu, 04 Oct 2001 22:06:04 +0000
Subject: [Linux-ia64] show_mem for discontig
Message-Id: <marc-linux-ia64-105590698805300@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Here's a small patch I came up with to implement the show_mem() function
for CONFIG_DISCONTIG.  This could could actually be used in the
non-discontig case as well, but we'll probably be adding more per-node
statistics to it, so it might be best to keep it seperate.  I'm submitting
it for inclusing into the ia64 patch.  Feedback would be appreciated.

Thanks,
Jesse

--- /usr/tmp/TmpDir.9409-0/linux/arch/ia64/mm/init.c_1.13	Thu Oct  4 15:03:48 2001
+++ linux/arch/ia64/mm/init.c	Thu Oct  4 12:52:08 2001
@@ -208,9 +208,30 @@
 void
 show_mem(void)
 {
-	printk("show_mem: fixme\n") ;
+	int i, total = 0, reserved = 0;
+	int shared = 0, cached = 0;
+	pg_data_t *pgdat = pgdat_list;
+
 	printk("Mem-info:\n");
 	show_free_areas();
+	printk("Free swap:       %6dkB\n", nr_swap_pages<<(PAGE_SHIFT-10));
+	do {
+		printk("Node ID: %d\n", pgdat->node_id);
+		for(i = 0; i < pgdat->node_size; i++) {
+			if (PageReserved(pgdat->node_mem_map+i))
+				reserved++;
+			else if (PageSwapCache(pgdat->node_mem_map+i))
+				cached++;
+			else if (page_count(pgdat->node_mem_map + i))
+				shared += page_count(pgdat->node_mem_map + i) - 1;
+		}
+		printk("\t%d pages of RAM\n", pgdat->node_size);
+		printk("\t%d reserved pages\n", reserved);
+		printk("\t%d pages shared\n", shared);
+		printk("\t%d pages swap cached\n", cached);
+		pgdat = pgdat->node_next;
+	} while(pgdat);
+	printk("Total of %ld pages in page table cache\n", pgtable_cache_size);
 	show_buffers();
 	printk("%d free buffer pages\n", nr_free_buffer_pages());
 }


