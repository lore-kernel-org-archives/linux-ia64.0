From: akpm@linux-foundation.org
Date: Fri, 28 Mar 2008 21:27:04 +0000
Subject: [patch 4/5] ia64: remove redundant display of free swap space in show_mem()
Message-Id: <200803282127.m2SLR4J5011056@imap1.linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

From: Johannes Weiner <hannes@saeurebad.de>

show_mem() has no need to print the amount of free swap space manually because
show_free_areas() does this already and is called by the former.

The two outputs only differ in text formatting:

  printk("Free swap  = %lukB\n", ...);
  printk("Free swap:       %6ldkB\n", ...);

Signed-off-by: Johannes Weiner <hannes@saeurebad.de>
Cc: "Luck, Tony" <tony.luck@intel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 arch/ia64/mm/contig.c    |    2 --
 arch/ia64/mm/discontig.c |    2 --
 2 files changed, 4 deletions(-)

diff -puN arch/ia64/mm/contig.c~ia64-remove-redundant-display-of-free-swap-space-in-show_mem arch/ia64/mm/contig.c
--- a/arch/ia64/mm/contig.c~ia64-remove-redundant-display-of-free-swap-space-in-show_mem
+++ a/arch/ia64/mm/contig.c
@@ -45,8 +45,6 @@ void show_mem(void)
 
 	printk(KERN_INFO "Mem-info:\n");
 	show_free_areas();
-	printk(KERN_INFO "Free swap:       %6ldkB\n",
-	       nr_swap_pages<<(PAGE_SHIFT-10));
 	printk(KERN_INFO "Node memory in pages:\n");
 	for_each_online_pgdat(pgdat) {
 		unsigned long present;
diff -puN arch/ia64/mm/discontig.c~ia64-remove-redundant-display-of-free-swap-space-in-show_mem arch/ia64/mm/discontig.c
--- a/arch/ia64/mm/discontig.c~ia64-remove-redundant-display-of-free-swap-space-in-show_mem
+++ a/arch/ia64/mm/discontig.c
@@ -522,8 +522,6 @@ void show_mem(void)
 
 	printk(KERN_INFO "Mem-info:\n");
 	show_free_areas();
-	printk(KERN_INFO "Free swap:       %6ldkB\n",
-	       nr_swap_pages<<(PAGE_SHIFT-10));
 	printk(KERN_INFO "Node memory in pages:\n");
 	for_each_online_pgdat(pgdat) {
 		unsigned long present;
_
