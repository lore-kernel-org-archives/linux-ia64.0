From: Robin Holt <holt@sgi.com>
Date: Tue, 16 Mar 2004 11:24:24 +0000
Subject: pgd_free, pmd_free, and pte_free trapping memory.
Message-Id: <20040316112424.GA20203@lnx-holt>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On a 512 CPU system with 256 numa nodes, we have an application which
forks 500 worker threads.  During each fork, 32 pages are allocated on
the node where the main thread is doing the forks.  The child threads
then use sched_set_affinity to migrate to a different cpu. After the
application exits, we are loosing approx 15,000 pages on main node.
If we echo "0 0" >/proc/sys/vm/pagetable_cache, the memory gets returned.
This was run on a 2.4 kernel, but the code in question is identical in 2.6.

Note: because of memory size, pagetable_cache sizes are 25 for min and
15559 for max.

Looking through the code, we have identified the source of the problem.
The fork is occuring on one cpu where the pgd, pmd, and pte allocations
get pages of memory local to that cpu.  The worker thread is then
migrated to a different cpu where it exits.  The pages are then placed
on the cpu which is very distant from where the memory is located.

I looked at the i386 code which appears to have been very similar to the
ia64 at one point in time, but no longer.  They appear to have completely
eliminated the quicklists.  Is this the right direction for ia64?

Since, when the pgd, pmd, and pte are ready to be freed, they are
zeroed out again, I understand the benefit to keeping the entry around
to save the time for zeroing out the page again.  Why not have a single
quicklist where all three are placed.  How would node locality best play
into placing items on the lists?  Should we have one quicklist on
each cpu that a cpu returns node local pages and then a node quicklist
where we place pages that are not node local using cmpxchg?

One other related but different question.  The pagetable_cache size of
15,559 seems a little large.  Given that this machine has a large amount
of memory, I understand that this doesn't seem too outragously large.
What role should node memory play in setting pagetable_cache max size?

As a simple diff to open discussions, I have included the following patch.
On our above test, the problem prevents the pages from being trapped.
The method is simple, if the page that is being freed is not physically
on this node, it is freed, otherwise it is added to the quicklist.

Thanks for your attention,
Robin Holt

--- /usr/tmp/TmpDir.9611-0/linux/include/asm-ia64/pgalloc.h_1.15  Tue Mar 16 05:13:05 2004
+++ linux/include/asm-ia64/pgalloc.h      Tue Mar 16 05:12:55 2004
@@ -18,6 +18,7 @@
 #include <linux/compiler.h>
 #include <linux/mm.h>
 #include <linux/threads.h>
+#include <linux/mmzone.h>
 
 #include <asm/mmu_context.h>
 #include <asm/processor.h>
@@ -65,6 +66,12 @@
 static inline void
 pgd_free (pgd_t *pgd)
 {
+#ifdef CONFIG_NUMA
+       if(page_zone(virt_to_page(pgd))->zone_pgdat->node_id != numa_node_id()) {
+               free_page((unsigned long) pgd);
+               return;
+       }
+#endif
        *(unsigned long *)pgd = (unsigned long) pgd_quicklist;
        pgd_quicklist = (unsigned long *) pgd;
        ++pgtable_cache_size;
@@ -103,6 +110,12 @@
 static inline void
 pmd_free (pmd_t *pmd)
 {
+#ifdef CONFIG_NUMA
+       if(page_zone(virt_to_page(pmd))->zone_pgdat->node_id != numa_node_id()) {
+               free_page((unsigned long) pmd);
+               return;
+       }
+#endif
        *(unsigned long *)pmd = (unsigned long) pmd_quicklist;
        pmd_quicklist = (unsigned long *) pmd;
        ++pgtable_cache_size;
@@ -141,6 +154,12 @@
 static inline void
 pte_free (pte_t *pte)
 {
+#ifdef CONFIG_NUMA
+       if(page_zone(virt_to_page(pte))->zone_pgdat->node_id != numa_node_id()) {
+               free_page((unsigned long) pte);
+               return;
+       }
+#endif
        *(unsigned long *)pte = (unsigned long) pte_quicklist;
        pte_quicklist = (unsigned long *) pte;
        ++pgtable_cache_size;

