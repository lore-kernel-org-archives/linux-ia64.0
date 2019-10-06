From: David Hildenbrand <david@redhat.com>
Date: Sun, 06 Oct 2019 08:56:38 +0000
Subject: [PATCH v6 02/10] mm/memmap_init: Update variable name in memmap_init_zone
Message-Id: <20191006085646.5768-3-david@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191006085646.5768-1-david@redhat.com>
In-Reply-To: <20191006085646.5768-1-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: linux-s390@vger.kernel.org, Michal Hocko <mhocko@suse.com>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Pankaj Gupta <pagupta@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Alexander Duyck <alexander.h.duyck@linux.intel.com>, x86@kernel.org, David Hildenbrand <david@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Mike Rapoport <rppt@linux.ibm.com>, linux-mm@kvack.org, Pavel Tatashin <pavel.tatashin@microsoft.com>, Alexander Potapenko <glider@google.com>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, Dan Williams <dan.j.williams@intel.com>, linux-arm-kernel@lists.infradead.org, Oscar Salvador <osalvador@suse.de>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>

The third argument is actually number of pages. Changes the variable name
from size to nr_pages to indicate this better.

No functional change in this patch.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Oscar Salvador <osalvador@suse.de>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Mike Rapoport <rppt@linux.ibm.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Cc: Pavel Tatashin <pavel.tatashin@microsoft.com>
Cc: Alexander Potapenko <glider@google.com>
Reviewed-by: Pankaj Gupta <pagupta@redhat.com>
Reviewed-by: David Hildenbrand <david@redhat.com>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 mm/page_alloc.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 15c2050c629b..b0b2d5464000 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5936,10 +5936,10 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 #ifdef CONFIG_ZONE_DEVICE
 void __ref memmap_init_zone_device(struct zone *zone,
 				   unsigned long start_pfn,
-				   unsigned long size,
+				   unsigned long nr_pages,
 				   struct dev_pagemap *pgmap)
 {
-	unsigned long pfn, end_pfn = start_pfn + size;
+	unsigned long pfn, end_pfn = start_pfn + nr_pages;
 	struct pglist_data *pgdat = zone->zone_pgdat;
 	struct vmem_altmap *altmap = pgmap_altmap(pgmap);
 	unsigned long zone_idx = zone_idx(zone);
@@ -5956,7 +5956,7 @@ void __ref memmap_init_zone_device(struct zone *zone,
 	 */
 	if (altmap) {
 		start_pfn = altmap->base_pfn + vmem_altmap_offset(altmap);
-		size = end_pfn - start_pfn;
+		nr_pages = end_pfn - start_pfn;
 	}
 
 	for (pfn = start_pfn; pfn < end_pfn; pfn++) {
@@ -6003,7 +6003,7 @@ void __ref memmap_init_zone_device(struct zone *zone,
 	}
 
 	pr_info("%s initialised %lu pages in %ums\n", __func__,
-		size, jiffies_to_msecs(jiffies - start));
+		nr_pages, jiffies_to_msecs(jiffies - start));
 }
 
 #endif
-- 
2.21.0
