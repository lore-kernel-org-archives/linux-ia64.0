From: Zi Yan <zi.yan@sent.com>
Date: Thu, 06 May 2021 15:26:21 +0000
Subject: [RFC PATCH 5/7] mm: memory_hotplug, sparse: enable memory hotplug/hotremove subsections
Message-Id: <20210506152623.178731-6-zi.yan@sent.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210506152623.178731-1-zi.yan@sent.com>
In-Reply-To: <20210506152623.178731-1-zi.yan@sent.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Hildenbrand <david@redhat.com>, Oscar Salvador <osalvador@suse.de>
Cc: Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Thomas Gleixner <tglx@linutronix.de>, x86@kernel.org, Andy Lutomirski <luto@kernel.org>, "Rafael J . Wysocki" <rafael@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@kernel.org>, Anshuman Khandual <anshuman.khandual@arm.com>, Michal Hocko <mhocko@suse.com>, Dan Williams <dan.j.williams@intel.com>, Wei Yang <richard.weiyang@linux.alibaba.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, Zi Yan <ziy@nvidia.com>

From: Zi Yan <ziy@nvidia.com>

Remove the section size alignment checks for memory hotplug/hotremove,
so that we can online/offline subsection memory.

Signed-off-by: Zi Yan <ziy@nvidia.com>
---
 mm/memory_hotplug.c | 16 +++++++++-------
 mm/page_isolation.c |  4 ----
 mm/sparse.c         | 17 ++++++++++++++---
 3 files changed, 23 insertions(+), 14 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 6e93b0ecc5cb..5384bb62ac10 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -661,12 +661,15 @@ static void online_pages_range(unsigned long start_pfn, unsigned long nr_pages)
 	 * When using memmap_on_memory, the range might not be aligned to
 	 * MAX_ORDER_NR_PAGES - 1, but pageblock aligned. __ffs() will detect
 	 * this and the first chunk to online will be pageblock_nr_pages.
+	 * When onlining subsections, the range might be smaller than MAX_ORDER
+	 * - 1, use __ffs(nr_pages) to get the right size.
 	 */
 	for (pfn = start_pfn; pfn < end_pfn;) {
-		int order = min(MAX_ORDER - 1UL, __ffs(pfn));
+		int order = min3(MAX_ORDER - 1UL, __ffs(pfn), __ffs(nr_pages));
 
 		(*online_page_callback)(pfn_to_page(pfn), order);
 		pfn += (1UL << order);
+		nr_pages -= (1UL << order);
 	}
 
 	/* mark all involved sections as online */
@@ -912,16 +915,16 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, struct zone *z
 	struct memory_notify arg;
 
 	/*
-	 * {on,off}lining is constrained to full memory sections (or more
+	 * {on,off}lining is constrained to memory subsections (or more
 	 * precisly to memory blocks from the user space POV).
 	 * memmap_on_memory is an exception because it reserves initial part
 	 * of the physical memory space for vmemmaps. That space is pageblock
 	 * aligned.
 	 */
 	if (WARN_ON_ONCE(!nr_pages ||
-			 !IS_ALIGNED(pfn, pageblock_nr_pages) ||
-			 !IS_ALIGNED(pfn + nr_pages, PAGES_PER_SECTION)))
+			 !IS_ALIGNED(pfn + nr_pages, PAGES_PER_SUBSECTION))) {
 		return -EINVAL;
+	}
 
 	mem_hotplug_begin();
 
@@ -1702,15 +1705,14 @@ int __ref offline_pages(unsigned long start_pfn, unsigned long nr_pages)
 	char *reason;
 
 	/*
-	 * {on,off}lining is constrained to full memory sections (or more
+	 * {on,off}lining is constrained to memory subsections (or more
 	 * precisly to memory blocks from the user space POV).
 	 * memmap_on_memory is an exception because it reserves initial part
 	 * of the physical memory space for vmemmaps. That space is pageblock
 	 * aligned.
 	 */
 	if (WARN_ON_ONCE(!nr_pages ||
-			 !IS_ALIGNED(start_pfn, pageblock_nr_pages) ||
-			 !IS_ALIGNED(start_pfn + nr_pages, PAGES_PER_SECTION)))
+			 !IS_ALIGNED(start_pfn + nr_pages, PAGES_PER_SUBSECTION)))
 		return -EINVAL;
 
 	mem_hotplug_begin();
diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index c1b9b8848382..7f1791faf03f 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -147,7 +147,6 @@ __first_valid_page(unsigned long pfn, unsigned long nr_pages)
  * be MIGRATE_ISOLATE.
  * @start_pfn:		The lower PFN of the range to be isolated.
  * @end_pfn:		The upper PFN of the range to be isolated.
- *			start_pfn/end_pfn must be aligned to pageblock_order.
  * @migratetype:	Migrate type to set in error recovery.
  * @flags:		The following flags are allowed (they can be combined in
  *			a bit mask)
@@ -190,9 +189,6 @@ int start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
 	unsigned long undo_pfn;
 	struct page *page;
 
-	BUG_ON(!IS_ALIGNED(start_pfn, pageblock_nr_pages));
-	BUG_ON(!IS_ALIGNED(end_pfn, pageblock_nr_pages));
-
 	for (pfn = start_pfn;
 	     pfn < end_pfn;
 	     pfn += pageblock_nr_pages) {
diff --git a/mm/sparse.c b/mm/sparse.c
index 1c2957807882..09b5e6978ab0 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -251,7 +251,8 @@ void __init subsection_map_init(unsigned long pfn, unsigned long nr_pages)
 /* Record a memory area against a node. */
 static void __init memory_present(int nid, unsigned long start, unsigned long end)
 {
-	unsigned long pfn;
+	unsigned long pfn, nr_pages;
+	unsigned long section, end_sec, start_sec;
 
 #ifdef CONFIG_SPARSEMEM_EXTREME
 	if (unlikely(!mem_section)) {
@@ -268,9 +269,17 @@ static void __init memory_present(int nid, unsigned long start, unsigned long en
 
 	start &= PAGE_SECTION_MASK;
 	mminit_validate_memmodel_limits(&start, &end);
-	for (pfn = start; pfn < end; pfn += PAGES_PER_SECTION) {
-		unsigned long section = pfn_to_section_nr(pfn);
+	start_sec = pfn_to_section_nr(start);
+	end_sec = pfn_to_section_nr(end - 1);
+	pfn = start;
+	nr_pages = end - start;
+
+	for (section = start_sec; section <= end_sec; section++) {
 		struct mem_section *ms;
+		unsigned long pfns;
+
+		pfns = min(nr_pages, PAGES_PER_SECTION
+				- (pfn & ~PAGE_SECTION_MASK));
 
 		sparse_index_init(section, nid);
 		set_section_nid(section, nid);
@@ -281,6 +290,8 @@ static void __init memory_present(int nid, unsigned long start, unsigned long en
 							SECTION_IS_ONLINE;
 			section_mark_present(ms);
 		}
+		pfn += pfns;
+		nr_pages -= pfns;
 	}
 }
 
-- 
2.30.2
