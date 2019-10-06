From: David Hildenbrand <david@redhat.com>
Date: Sun, 06 Oct 2019 08:56:46 +0000
Subject: [PATCH v6 10/10] mm/memory_hotplug: Cleanup __remove_pages()
Message-Id: <20191006085646.5768-11-david@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191006085646.5768-1-david@redhat.com>
In-Reply-To: <20191006085646.5768-1-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: linux-s390@vger.kernel.org, Michal Hocko <mhocko@suse.com>, linux-ia64@vger.kernel.org, Pavel Tatashin <pasha.tatashin@soleen.com>, linux-sh@vger.kernel.org, x86@kernel.org, David Hildenbrand <david@redhat.com>, linux-mm@kvack.org, Wei Yang <richardw.yang@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, Dan Williams <dan.j.williams@intel.com>, linux-arm-kernel@lists.infradead.org, Oscar Salvador <osalvador@suse.de>

Let's drop the basically unused section stuff and simplify.

Also, let's use a shorter variant to calculate the number of pages to
the next section boundary.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Oscar Salvador <osalvador@suse.de>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Wei Yang <richardw.yang@linux.intel.com>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 mm/memory_hotplug.c | 17 ++++++-----------
 1 file changed, 6 insertions(+), 11 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 843481bd507d..2275240cfa10 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -490,25 +490,20 @@ static void __remove_section(unsigned long pfn, unsigned long nr_pages,
 void __remove_pages(unsigned long pfn, unsigned long nr_pages,
 		    struct vmem_altmap *altmap)
 {
+	const unsigned long end_pfn = pfn + nr_pages;
+	unsigned long cur_nr_pages;
 	unsigned long map_offset = 0;
-	unsigned long nr, start_sec, end_sec;
 
 	map_offset = vmem_altmap_offset(altmap);
 
 	if (check_pfn_span(pfn, nr_pages, "remove"))
 		return;
 
-	start_sec = pfn_to_section_nr(pfn);
-	end_sec = pfn_to_section_nr(pfn + nr_pages - 1);
-	for (nr = start_sec; nr <= end_sec; nr++) {
-		unsigned long pfns;
-
+	for (; pfn < end_pfn; pfn += cur_nr_pages) {
 		cond_resched();
-		pfns = min(nr_pages, PAGES_PER_SECTION
-				- (pfn & ~PAGE_SECTION_MASK));
-		__remove_section(pfn, pfns, map_offset, altmap);
-		pfn += pfns;
-		nr_pages -= pfns;
+		/* Select all remaining pages up to the next section boundary */
+		cur_nr_pages = min(end_pfn - pfn, -(pfn | PAGE_SECTION_MASK));
+		__remove_section(pfn, cur_nr_pages, map_offset, altmap);
 		map_offset = 0;
 	}
 }
-- 
2.21.0
