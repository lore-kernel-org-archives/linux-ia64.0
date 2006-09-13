From: Jes Sorensen <jes@sgi.com>
Date: Wed, 13 Sep 2006 14:44:00 +0000
Subject: [patch] trim output of show_mem()
Message-Id: <yq0zmd3esi7.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

This patch goes on top of the patch I posted earlier today. It trims
the number of lines of memory information output per node down from 5
lines to one line per node. Kinda helps if you have 1024 live nodes in
a system and you are dumping to the console :)

Cheers,
Jes

Cut the number of lines of memory info output per node from five
to one line.

Signed-off-by: Jes Sorensen <jes@sgi.com>

---
 arch/ia64/mm/discontig.c |    9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

Index: linux-2.6/arch/ia64/mm/discontig.c
=================================--- linux-2.6.orig/arch/ia64/mm/discontig.c
+++ linux-2.6/arch/ia64/mm/discontig.c
@@ -551,12 +551,13 @@ void show_mem(void)
 	show_free_areas();
 	printk(KERN_INFO "Free swap:       %6ldkB\n",
 	       nr_swap_pages<<(PAGE_SHIFT-10));
+	printk(KERN_INFO "Node memory in pages:\n");
 	for_each_online_pgdat(pgdat) {
 		unsigned long present;
 		unsigned long flags;
 		int shared = 0, cached = 0, reserved = 0;
 
-		printk(KERN_INFO "Node ID: %d\n", pgdat->node_id);
+		printk(KERN_INFO "Node %d:", pgdat->node_id);
 		pgdat_resize_lock(pgdat, &flags);
 		present = pgdat->node_present_pages;
 		for(i = 0; i < pgdat->node_spanned_pages; i++) {
@@ -580,10 +581,8 @@ void show_mem(void)
 		total_reserved += reserved;
 		total_cached += cached;
 		total_shared += shared;
-		printk(KERN_INFO "\t%ld pages of RAM\n", present);
-		printk(KERN_INFO "\t%d reserved pages\n", reserved);
-		printk(KERN_INFO "\t%d pages shared\n", shared);
-		printk(KERN_INFO "\t%d pages swap cached\n", cached);
+		printk("\tRAM: %ld, reserved: %d, shared: %d, "
+		       "swap cached: %d\n", present, reserved, shared, cached);
 	}
 	printk(KERN_INFO "%ld pages of RAM\n", total_present);
 	printk(KERN_INFO "%d reserved pages\n", total_reserved);
