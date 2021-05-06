From: Zi Yan <zi.yan@sent.com>
Date: Thu, 06 May 2021 15:26:18 +0000
Subject: [RFC PATCH 2/7] mm: set pageblock_order to the max of HUGETLB_PAGE_ORDER and MAX_ORDER-1
Message-Id: <20210506152623.178731-3-zi.yan@sent.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210506152623.178731-1-zi.yan@sent.com>
In-Reply-To: <20210506152623.178731-1-zi.yan@sent.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Hildenbrand <david@redhat.com>, Oscar Salvador <osalvador@suse.de>
Cc: Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Thomas Gleixner <tglx@linutronix.de>, x86@kernel.org, Andy Lutomirski <luto@kernel.org>, "Rafael J . Wysocki" <rafael@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@kernel.org>, Anshuman Khandual <anshuman.khandual@arm.com>, Michal Hocko <mhocko@suse.com>, Dan Williams <dan.j.williams@intel.com>, Wei Yang <richard.weiyang@linux.alibaba.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, Zi Yan <ziy@nvidia.com>

From: Zi Yan <ziy@nvidia.com>

As MAX_ORDER can be increased to larger than hugetlb page orders,
pageblock_order will be limited at HUGETLB_PAGE_ORDER. It is not
ideal for anti-fragmentation for allocating pages from buddy allocator
with MAX_ORDER > HUGETLB_PAGE_ORDER. Make pageblock_order a variable and
set it to the max of HUGETLB_PAGE_ORDER, MAX_ORDER - 1.

Remove HUGETLB_PAGE_SIZE_VARIABLE as HUGETLB_PAGE does the same thing
now.

Export pageblock_order since virtio-mem module needs it.

Signed-off-by: Zi Yan <ziy@nvidia.com>
---
 arch/ia64/Kconfig               |  1 -
 arch/powerpc/Kconfig            |  1 -
 include/linux/pageblock-flags.h |  9 ---------
 mm/Kconfig                      |  7 -------
 mm/page_alloc.c                 | 13 +++++++------
 mm/sparse.c                     |  2 +-
 6 files changed, 8 insertions(+), 25 deletions(-)

diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 279252e3e0f7..c6a150cde668 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -34,7 +34,6 @@ config IA64
 	select TTY
 	select HAVE_ARCH_TRACEHOOK
 	select HAVE_VIRT_CPU_ACCOUNTING
-	select HUGETLB_PAGE_SIZE_VARIABLE if HUGETLB_PAGE
 	select VIRT_TO_BUS
 	select GENERIC_IRQ_PROBE
 	select GENERIC_PENDING_IRQ if SMP
diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index 8926461d25b2..9f27c131ed45 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -238,7 +238,6 @@ config PPC
 	select HAVE_HARDLOCKUP_DETECTOR_PERF	if PERF_EVENTS && HAVE_PERF_EVENTS_NMI && !HAVE_HARDLOCKUP_DETECTOR_ARCH
 	select HAVE_PERF_REGS
 	select HAVE_PERF_USER_STACK_DUMP
-	select HUGETLB_PAGE_SIZE_VARIABLE	if PPC_BOOK3S_64 && HUGETLB_PAGE
 	select MMU_GATHER_RCU_TABLE_FREE
 	select MMU_GATHER_PAGE_SIZE
 	select HAVE_REGS_AND_STACK_ACCESS_API
diff --git a/include/linux/pageblock-flags.h b/include/linux/pageblock-flags.h
index fff52ad370c1..efab85e2ae1c 100644
--- a/include/linux/pageblock-flags.h
+++ b/include/linux/pageblock-flags.h
@@ -30,18 +30,9 @@ enum pageblock_bits {
 
 #ifdef CONFIG_HUGETLB_PAGE
 
-#ifdef CONFIG_HUGETLB_PAGE_SIZE_VARIABLE
-
 /* Huge page sizes are variable */
 extern unsigned int pageblock_order;
 
-#else /* CONFIG_HUGETLB_PAGE_SIZE_VARIABLE */
-
-/* Huge pages are a constant size */
-#define pageblock_order		HUGETLB_PAGE_ORDER
-
-#endif /* CONFIG_HUGETLB_PAGE_SIZE_VARIABLE */
-
 #else /* CONFIG_HUGETLB_PAGE */
 
 /* If huge pages are not used, group by MAX_ORDER_NR_PAGES */
diff --git a/mm/Kconfig b/mm/Kconfig
index a8a367c30053..3466c3d09295 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -284,13 +284,6 @@ config ARCH_ENABLE_HUGEPAGE_MIGRATION
 config ARCH_ENABLE_THP_MIGRATION
 	bool
 
-config HUGETLB_PAGE_SIZE_VARIABLE
-	def_bool n
-	help
-	  Allows the pageblock_order value to be dynamic instead of just standard
-	  HUGETLB_PAGE_ORDER when there are multiple HugeTLB page sizes available
-	  on a platform.
-
 config CONTIG_ALLOC
 	def_bool (MEMORY_ISOLATION && COMPACTION) || CMA
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a2fe714aed93..72bb4a300e03 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -256,8 +256,9 @@ bool pm_suspended_storage(void)
 }
 #endif /* CONFIG_PM_SLEEP */
 
-#ifdef CONFIG_HUGETLB_PAGE_SIZE_VARIABLE
+#ifdef CONFIG_HUGETLB_PAGE
 unsigned int pageblock_order __read_mostly;
+EXPORT_SYMBOL_GPL(pageblock_order);
 #endif
 
 static void __free_pages_ok(struct page *page, unsigned int order,
@@ -7057,7 +7058,7 @@ static void __ref setup_usemap(struct zone *zone)
 static inline void setup_usemap(struct zone *zone) {}
 #endif /* CONFIG_SPARSEMEM */
 
-#ifdef CONFIG_HUGETLB_PAGE_SIZE_VARIABLE
+#ifdef CONFIG_HUGETLB_PAGE
 
 /* Initialise the number of pages represented by NR_PAGEBLOCK_BITS */
 void __init set_pageblock_order(void)
@@ -7068,7 +7069,7 @@ void __init set_pageblock_order(void)
 	if (pageblock_order)
 		return;
 
-	if (HPAGE_SHIFT > PAGE_SHIFT)
+	if ((HPAGE_SHIFT > PAGE_SHIFT) && (HUGETLB_PAGE_ORDER > (MAX_ORDER - 1)))
 		order = HUGETLB_PAGE_ORDER;
 	else
 		order = MAX_ORDER - 1;
@@ -7080,10 +7081,10 @@ void __init set_pageblock_order(void)
 	 */
 	pageblock_order = order;
 }
-#else /* CONFIG_HUGETLB_PAGE_SIZE_VARIABLE */
+#else /* CONFIG_HUGETLB_PAGE */
 
 /*
- * When CONFIG_HUGETLB_PAGE_SIZE_VARIABLE is not set, set_pageblock_order()
+ * When CONFIG_HUGETLB_PAGE is not set, set_pageblock_order()
  * is unused as pageblock_order is set at compile-time. See
  * include/linux/pageblock-flags.h for the values of pageblock_order based on
  * the kernel config
@@ -7092,7 +7093,7 @@ void __init set_pageblock_order(void)
 {
 }
 
-#endif /* CONFIG_HUGETLB_PAGE_SIZE_VARIABLE */
+#endif /* CONFIG_HUGETLB_PAGE */
 
 static unsigned long __init calc_memmap_size(unsigned long spanned_pages,
 						unsigned long present_pages)
diff --git a/mm/sparse.c b/mm/sparse.c
index 7637208b8874..1c2957807882 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -583,7 +583,7 @@ void __init sparse_init(void)
 	pnum_begin = first_present_section_nr();
 	nid_begin = sparse_early_nid(__nr_to_section(pnum_begin));
 
-	/* Setup pageblock_order for HUGETLB_PAGE_SIZE_VARIABLE */
+	/* Setup pageblock_order for HUGETLB_PAGE */
 	set_pageblock_order();
 
 	for_each_present_section_nr(pnum_begin + 1, pnum_end) {
-- 
2.30.2
