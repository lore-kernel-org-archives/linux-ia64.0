From: John Marvin <jsm@udlkern.fc.hp.com>
Date: Mon, 15 Mar 2004 12:33:07 +0000
Subject: [PATCH] Revised fix for show_mem panic
Message-Id: <200403151233.i2FCX7519363@udlkern.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

--- a/arch/ia64/mm/contig.c	Fri Mar 12 07:17:21 2004
+++ b/arch/ia64/mm/contig.c	Fri Mar 12 05:59:24 2004
@@ -46,6 +46,8 @@
 	printk("Free swap:       %6dkB\n", nr_swap_pages<<(PAGE_SHIFT-10));
 	i = max_mapnr;
 	while (i-- > 0) {
+		if (!pfn_valid(i))
+			continue;
 		total++;
 		if (PageReserved(mem_map+i))
 			reserved++;
--- a/arch/ia64/mm/discontig.c	Fri Mar 12 07:17:21 2004
+++ b/arch/ia64/mm/discontig.c	Fri Mar 12 06:15:26 2004
@@ -377,6 +377,8 @@
 	for_each_pgdat(pgdat) {
 		printk("Node ID: %d\n", pgdat->node_id);
 		for(i = 0; i < pgdat->node_spanned_pages; i++) {
+			if (!ia64_pfn_valid(pgdat->node_start_pfn+i))
+				continue;
 			if (PageReserved(pgdat->node_mem_map+i))
 				reserved++;
 			else if (PageSwapCache(pgdat->node_mem_map+i))
--- a/arch/ia64/mm/init.c	Fri Mar 12 07:17:21 2004
+++ b/arch/ia64/mm/init.c	Mon Mar 15 04:55:08 2004
@@ -455,8 +455,11 @@
 ia64_pfn_valid (unsigned long pfn)
 {
 	char byte;
+	struct page *pg = pfn_to_page(pfn);
 
-	return __get_user(byte, (char *) pfn_to_page(pfn)) = 0;
+	return     (__get_user(byte, (char *) pg) = 0)
+		&& ((((u64)pg & PAGE_MASK) = (((u64)(pg + 1) - 1) & PAGE_MASK))
+			|| (__get_user(byte, (char *) (pg + 1) - 1) = 0));
 }
 EXPORT_SYMBOL(ia64_pfn_valid);
 
