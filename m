From: David Hildenbrand <david@redhat.com>
Date: Wed, 19 Aug 2020 10:11:56 +0000
Subject: [PATCH v1 10/11] mm: pass migratetype into memmap_init_zone() and move_pfn_range_to_zone()
Message-Id: <20200819101157.12723-11-david@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200819101157.12723-1-david@redhat.com>
In-Reply-To: <20200819101157.12723-1-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, David Hildenbrand <david@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Wei Yang <richard.weiyang@linux.alibaba.com>, Baoquan He <bhe@redhat.com>, Pankaj Gupta <pankaj.gupta.linux@gmail.com>, Oscar Salvador <osalvador@suse.de>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Logan Gunthorpe <logang@deltatee.com>, Dan Williams <dan.j.williams@intel.com>, Mike Rapoport <rppt@kernel.org>, "Matthew Wilcox (Oracle)" <willy@infradead.org>, Michel Lespinasse <walken@google.com>, linux-ia64@vger.kernel.org

On the memory hotplug path, we want to start with MIGRATE_ISOLATE, to
un-isolate the pages after memory onlining is complete. Let's allow
passing in the migratetype.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Wei Yang <richard.weiyang@linux.alibaba.com>
Cc: Baoquan He <bhe@redhat.com>
Cc: Pankaj Gupta <pankaj.gupta.linux@gmail.com>
Cc: Oscar Salvador <osalvador@suse.de>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: Logan Gunthorpe <logang@deltatee.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Mike Rapoport <rppt@kernel.org>
Cc: "Matthew Wilcox (Oracle)" <willy@infradead.org>
Cc: Michel Lespinasse <walken@google.com>
Cc: linux-ia64@vger.kernel.org
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 arch/ia64/mm/init.c            |  4 ++--
 include/linux/memory_hotplug.h |  3 ++-
 include/linux/mm.h             |  3 ++-
 mm/memory_hotplug.c            | 11 ++++++++---
 mm/memremap.c                  |  3 ++-
 mm/page_alloc.c                | 21 ++++++++++++---------
 6 files changed, 28 insertions(+), 17 deletions(-)

diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index 0b3fb4c7af292..82b7a46ddd23d 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -538,7 +538,7 @@ virtual_memmap_init(u64 start, u64 end, void *arg)
 	if (map_start < map_end)
 		memmap_init_zone((unsigned long)(map_end - map_start),
 				 args->nid, args->zone, page_to_pfn(map_start),
-				 MEMMAP_EARLY, NULL);
+				 MEMMAP_EARLY, NULL, MIGRATE_MOVABLE);
 	return 0;
 }
 
@@ -548,7 +548,7 @@ memmap_init (unsigned long size, int nid, unsigned long zone,
 {
 	if (!vmem_map) {
 		memmap_init_zone(size, nid, zone, start_pfn, MEMMAP_EARLY,
-				NULL);
+				 NULL, MIGRATE_MOVABLE);
 	} else {
 		struct page *start;
 		struct memmap_init_callback_data args;
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 0b461691d1a49..cbafeda859380 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -346,7 +346,8 @@ extern int add_memory_resource(int nid, struct resource *resource);
 extern int add_memory_driver_managed(int nid, u64 start, u64 size,
 				     const char *resource_name);
 extern void move_pfn_range_to_zone(struct zone *zone, unsigned long start_pfn,
-		unsigned long nr_pages, struct vmem_altmap *altmap);
+				   unsigned long nr_pages,
+				   struct vmem_altmap *altmap, int migratetype);
 extern void remove_pfn_range_from_zone(struct zone *zone,
 				       unsigned long start_pfn,
 				       unsigned long nr_pages);
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 8ab941cf73f44..c842aa2a97ba2 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2409,7 +2409,8 @@ extern int __meminit __early_pfn_to_nid(unsigned long pfn,
 
 extern void set_dma_reserve(unsigned long new_dma_reserve);
 extern void memmap_init_zone(unsigned long, int, unsigned long, unsigned long,
-		enum memmap_context, struct vmem_altmap *);
+			    enum memmap_context, struct vmem_altmap *,
+			    int migratetype);
 extern void setup_per_zone_wmarks(void);
 extern int __meminit init_per_zone_wmark_min(void);
 extern void mem_init(void);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 3aba0d956f9b1..1c16a5def781e 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -693,9 +693,14 @@ static void __meminit resize_pgdat_range(struct pglist_data *pgdat, unsigned lon
  * Associate the pfn range with the given zone, initializing the memmaps
  * and resizing the pgdat/zone data to span the added pages. After this
  * call, all affected pages are PG_reserved.
+ *
+ * All aligned pageblocks are initialized to the specified migratetype
+ * (usually MIGRATE_MOVABLE). Besides setting the migratetype, no related
+ * zone stats (e.g., nr_isolate_pageblock) are touched.
  */
 void __ref move_pfn_range_to_zone(struct zone *zone, unsigned long start_pfn,
-		unsigned long nr_pages, struct vmem_altmap *altmap)
+				  unsigned long nr_pages,
+				  struct vmem_altmap *altmap, int migratetype)
 {
 	struct pglist_data *pgdat = zone->zone_pgdat;
 	int nid = pgdat->node_id;
@@ -720,7 +725,7 @@ void __ref move_pfn_range_to_zone(struct zone *zone, unsigned long start_pfn,
 	 * are reserved so nobody should be touching them so we should be safe
 	 */
 	memmap_init_zone(nr_pages, nid, zone_idx(zone), start_pfn,
-			MEMMAP_HOTPLUG, altmap);
+			 MEMMAP_HOTPLUG, altmap, migratetype);
 
 	set_zone_contiguous(zone);
 }
@@ -800,7 +805,7 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages,
 
 	/* associate pfn range with the zone */
 	zone = zone_for_pfn_range(online_type, nid, pfn, nr_pages);
-	move_pfn_range_to_zone(zone, pfn, nr_pages, NULL);
+	move_pfn_range_to_zone(zone, pfn, nr_pages, NULL, MIGRATE_MOVABLE);
 
 	arg.start_pfn = pfn;
 	arg.nr_pages = nr_pages;
diff --git a/mm/memremap.c b/mm/memremap.c
index 8afcc54c89286..04dc1f4ed634e 100644
--- a/mm/memremap.c
+++ b/mm/memremap.c
@@ -342,7 +342,8 @@ void *memremap_pages(struct dev_pagemap *pgmap, int nid)
 
 		zone = &NODE_DATA(nid)->node_zones[ZONE_DEVICE];
 		move_pfn_range_to_zone(zone, PHYS_PFN(res->start),
-				PHYS_PFN(resource_size(res)), params.altmap);
+				       PHYS_PFN(resource_size(res)),
+				       params.altmap, MIGRATE_MOVABLE);
 	}
 
 	mem_hotplug_done();
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5db0b35f95e20..9f2dc61968689 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5970,10 +5970,15 @@ overlap_memmap_init(unsigned long zone, unsigned long *pfn)
  * Initially all pages are reserved - free ones are freed
  * up by memblock_free_all() once the early boot process is
  * done. Non-atomic initialization, single-pass.
+ *
+ * All aligned pageblocks are initialized to the specified migratetype
+ * (usually MIGRATE_MOVABLE). Besides setting the migratetype, no related
+ * zone stats (e.g., nr_isolate_pageblock) are touched.
  */
 void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
-		unsigned long start_pfn, enum memmap_context context,
-		struct vmem_altmap *altmap)
+				unsigned long start_pfn,
+				enum memmap_context context,
+				struct vmem_altmap *altmap, int migratetype)
 {
 	unsigned long pfn, end_pfn = start_pfn + size;
 	struct page *page;
@@ -6017,14 +6022,12 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 			__SetPageReserved(page);
 
 		/*
-		 * Mark the block movable so that blocks are reserved for
-		 * movable at startup. This will force kernel allocations
-		 * to reserve their blocks rather than leaking throughout
-		 * the address space during boot when many long-lived
-		 * kernel allocations are made.
+		 * Usually, we want to mark the pageblock MIGRATE_MOVABLE,
+		 * such that unmovable allocations won't be scattered all
+		 * over the place during system boot.
 		 */
 		if (IS_ALIGNED(pfn, pageblock_nr_pages)) {
-			set_pageblock_migratetype(page, MIGRATE_MOVABLE);
+			set_pageblock_migratetype(page, migratetype);
 			cond_resched();
 		}
 		pfn++;
@@ -6124,7 +6127,7 @@ void __meminit __weak memmap_init(unsigned long size, int nid,
 		if (end_pfn > start_pfn) {
 			size = end_pfn - start_pfn;
 			memmap_init_zone(size, nid, zone, start_pfn,
-					 MEMMAP_EARLY, NULL);
+					 MEMMAP_EARLY, NULL, MIGRATE_MOVABLE);
 		}
 	}
 }
-- 
2.26.2
