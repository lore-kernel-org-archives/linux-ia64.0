From: Zi Yan <zi.yan@sent.com>
Date: Thu, 06 May 2021 15:26:17 +0000
Subject: [RFC PATCH 1/7] mm: sparse: set/clear subsection bitmap when pages are onlined/offlined.
Message-Id: <20210506152623.178731-2-zi.yan@sent.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210506152623.178731-1-zi.yan@sent.com>
In-Reply-To: <20210506152623.178731-1-zi.yan@sent.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Hildenbrand <david@redhat.com>, Oscar Salvador <osalvador@suse.de>
Cc: Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Thomas Gleixner <tglx@linutronix.de>, x86@kernel.org, Andy Lutomirski <luto@kernel.org>, "Rafael J . Wysocki" <rafael@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@kernel.org>, Anshuman Khandual <anshuman.khandual@arm.com>, Michal Hocko <mhocko@suse.com>, Dan Williams <dan.j.williams@intel.com>, Wei Yang <richard.weiyang@linux.alibaba.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, Zi Yan <ziy@nvidia.com>

From: Zi Yan <ziy@nvidia.com>

subsection bitmap was set/cleared when a section is added/removed, but
pfn_to_online_page() uses subsection bitmap to check if the page is
online, which is not accurate. It was working when a whole section is
added/removed during memory hotplug and hotremove. When the following
patches enable memory hotplug and hotremove for subsections,
subsection bitmap needs to be changed during page online/offline time,
otherwise, pfn_to_online_page() will not give right answers. Move the
subsection bitmap manipulation code from section_activate() to
online_mem_sections() and section_deactivate() to
offline_mem_sections(), respectively.

Signed-off-by: Zi Yan <ziy@nvidia.com>
---
 mm/sparse.c | 36 +++++++++++++++++++++++++++++++++---
 1 file changed, 33 insertions(+), 3 deletions(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index b2ada9dc00cb..7637208b8874 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -606,6 +606,7 @@ void __init sparse_init(void)
 
 #ifdef CONFIG_MEMORY_HOTPLUG
 
+static int fill_subsection_map(unsigned long pfn, unsigned long nr_pages);
 /* Mark all memory sections within the pfn range as online */
 void online_mem_sections(unsigned long start_pfn, unsigned long end_pfn)
 {
@@ -621,9 +622,12 @@ void online_mem_sections(unsigned long start_pfn, unsigned long end_pfn)
 
 		ms = __nr_to_section(section_nr);
 		ms->section_mem_map |= SECTION_IS_ONLINE;
+		fill_subsection_map(pfn, min(end_pfn, pfn + PAGES_PER_SECTION) - pfn);
 	}
 }
 
+static int clear_subsection_map(unsigned long pfn, unsigned long nr_pages);
+static bool is_subsection_map_empty(struct mem_section *ms);
 /* Mark all memory sections within the pfn range as offline */
 void offline_mem_sections(unsigned long start_pfn, unsigned long end_pfn)
 {
@@ -641,7 +645,13 @@ void offline_mem_sections(unsigned long start_pfn, unsigned long end_pfn)
 			continue;
 
 		ms = __nr_to_section(section_nr);
-		ms->section_mem_map &= ~SECTION_IS_ONLINE;
+
+		if (end_pfn < pfn + PAGES_PER_SECTION) {
+			clear_subsection_map(pfn, end_pfn - pfn);
+			if (is_subsection_map_empty(ms))
+				ms->section_mem_map &= ~SECTION_IS_ONLINE;
+		} else
+			ms->section_mem_map &= ~SECTION_IS_ONLINE;
 	}
 }
 
@@ -668,6 +678,17 @@ static void free_map_bootmem(struct page *memmap)
 	vmemmap_free(start, end, NULL);
 }
 
+static int subsection_map_intersects(struct mem_section *ms, unsigned long pfn,
+				     unsigned long nr_pages)
+{
+	DECLARE_BITMAP(map, SUBSECTIONS_PER_SECTION) = { 0 };
+	unsigned long *subsection_map = &ms->usage->subsection_map[0];
+
+	subsection_mask_set(map, pfn, nr_pages);
+
+	return bitmap_intersects(map, subsection_map, SUBSECTIONS_PER_SECTION);
+}
+
 static int clear_subsection_map(unsigned long pfn, unsigned long nr_pages)
 {
 	DECLARE_BITMAP(map, SUBSECTIONS_PER_SECTION) = { 0 };
@@ -760,6 +781,12 @@ static void free_map_bootmem(struct page *memmap)
 	}
 }
 
+static int subsection_map_intersects(struct mem_section *ms, unsigned long pfn,
+				     unsigned long nr_pages)
+{
+	return 0;
+}
+
 static int clear_subsection_map(unsigned long pfn, unsigned long nr_pages)
 {
 	return 0;
@@ -800,7 +827,10 @@ static void section_deactivate(unsigned long pfn, unsigned long nr_pages,
 	struct page *memmap = NULL;
 	bool empty;
 
-	if (clear_subsection_map(pfn, nr_pages))
+	if (WARN((IS_ENABLED(CONFIG_SPARSEMEM_VMEMMAP) && !ms->usage) ||
+		 subsection_map_intersects(ms, pfn, nr_pages),
+				"section already deactivated (%#lx + %ld)\n",
+				pfn, nr_pages))
 		return;
 
 	empty = is_subsection_map_empty(ms);
@@ -855,7 +885,7 @@ static struct page * __meminit section_activate(int nid, unsigned long pfn,
 		ms->usage = usage;
 	}
 
-	rc = fill_subsection_map(pfn, nr_pages);
+	rc = !nr_pages || subsection_map_intersects(ms, pfn, nr_pages);
 	if (rc) {
 		if (usage)
 			ms->usage = NULL;
-- 
2.30.2
