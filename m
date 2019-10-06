From: David Hildenbrand <david@redhat.com>
Date: Sun, 06 Oct 2019 08:56:40 +0000
Subject: [PATCH v6 04/10] mm/memory_hotplug: Don't access uninitialized memmaps in shrink_zone_span()
Message-Id: <20191006085646.5768-5-david@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191006085646.5768-1-david@redhat.com>
In-Reply-To: <20191006085646.5768-1-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: linux-s390@vger.kernel.org, Michal Hocko <mhocko@suse.com>, linux-ia64@vger.kernel.org, Pavel Tatashin <pasha.tatashin@soleen.com>, linux-sh@vger.kernel.org, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, x86@kernel.org, David Hildenbrand <david@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, Dan Williams <dan.j.williams@intel.com>, linux-arm-kernel@lists.infradead.org, Oscar Salvador <osalvador@suse.de>

Let's limit shrinking to !ZONE_DEVICE so we can fix the current code. We
should never try to touch the memmap of offline sections where we could
have uninitialized memmaps and could trigger BUGs when calling
page_to_nid() on poisoned pages.

There is no reliable way to distinguish an uninitialized memmap from an
initialized memmap that belongs to ZONE_DEVICE, as we don't have
anything like SECTION_IS_ONLINE we can use similar to
pfn_to_online_section() for !ZONE_DEVICE memory. E.g.,
set_zone_contiguous() similarly relies on pfn_to_online_section() and
will therefore never set a ZONE_DEVICE zone consecutive. Stopping to
shrink the ZONE_DEVICE therefore results in no observable changes,
besides /proc/zoneinfo indicating different boundaries - something we
can totally live with.

Before commit d0dc12e86b31 ("mm/memory_hotplug: optimize memory
hotplug"), the memmap was initialized with 0 and the node with the
right value. So the zone might be wrong but not garbage. After that
commit, both the zone and the node will be garbage when touching
uninitialized memmaps.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Oscar Salvador <osalvador@suse.de>
Cc: David Hildenbrand <david@redhat.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Fixes: d0dc12e86b31 ("mm/memory_hotplug: optimize memory hotplug")
Reported-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 mm/memory_hotplug.c | 16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 86b4dc18e831..f96608d24f6a 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -331,7 +331,7 @@ static unsigned long find_smallest_section_pfn(int nid, struct zone *zone,
 				     unsigned long end_pfn)
 {
 	for (; start_pfn < end_pfn; start_pfn += PAGES_PER_SUBSECTION) {
-		if (unlikely(!pfn_valid(start_pfn)))
+		if (unlikely(!pfn_to_online_page(start_pfn)))
 			continue;
 
 		if (unlikely(pfn_to_nid(start_pfn) != nid))
@@ -356,7 +356,7 @@ static unsigned long find_biggest_section_pfn(int nid, struct zone *zone,
 	/* pfn is the end pfn of a memory section. */
 	pfn = end_pfn - 1;
 	for (; pfn >= start_pfn; pfn -= PAGES_PER_SUBSECTION) {
-		if (unlikely(!pfn_valid(pfn)))
+		if (unlikely(!pfn_to_online_page(pfn)))
 			continue;
 
 		if (unlikely(pfn_to_nid(pfn) != nid))
@@ -415,7 +415,7 @@ static void shrink_zone_span(struct zone *zone, unsigned long start_pfn,
 	 */
 	pfn = zone_start_pfn;
 	for (; pfn < zone_end_pfn; pfn += PAGES_PER_SUBSECTION) {
-		if (unlikely(!pfn_valid(pfn)))
+		if (unlikely(!pfn_to_online_page(pfn)))
 			continue;
 
 		if (page_zone(pfn_to_page(pfn)) != zone)
@@ -463,6 +463,16 @@ static void __remove_zone(struct zone *zone, unsigned long start_pfn,
 	struct pglist_data *pgdat = zone->zone_pgdat;
 	unsigned long flags;
 
+#ifdef CONFIG_ZONE_DEVICE
+	/*
+	 * Zone shrinking code cannot properly deal with ZONE_DEVICE. So
+	 * we will not try to shrink the zones - which is okay as
+	 * set_zone_contiguous() cannot deal with ZONE_DEVICE either way.
+	 */
+	if (zone_idx(zone) = ZONE_DEVICE)
+		return;
+#endif
+
 	pgdat_resize_lock(zone->zone_pgdat, &flags);
 	shrink_zone_span(zone, start_pfn, start_pfn + nr_pages);
 	update_pgdat_span(pgdat);
-- 
2.21.0
