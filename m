From: David Hildenbrand <david@redhat.com>
Date: Tue, 07 May 2019 18:38:04 +0000
Subject: [PATCH v2 8/8] mm/memory_hotplug: Remove "zone" parameter from sparse_remove_one_section
Message-Id: <20190507183804.5512-9-david@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190507183804.5512-1-david@redhat.com>
In-Reply-To: <20190507183804.5512-1-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, akpm@linux-foundation.org, Dan Williams <dan.j.williams@intel.com>, David Hildenbrand <david@redhat.com>

Unused, and memory unplug path should never care about zones. This is
the job of memory offlining. ZONE_DEVICE might require special care -
the caller of arch_remove_memory() should handle this.

Signed-off-by: David Hildenbrand <david@redhat.com>
---
 include/linux/memory_hotplug.h | 2 +-
 mm/memory_hotplug.c            | 2 +-
 mm/sparse.c                    | 4 ++--
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 2f1f87e13baa..1a4257c5f74c 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -346,7 +346,7 @@ extern void move_pfn_range_to_zone(struct zone *zone, unsigned long start_pfn,
 extern bool is_memblock_offlined(struct memory_block *mem);
 extern int sparse_add_one_section(int nid, unsigned long start_pfn,
 				  struct vmem_altmap *altmap);
-extern void sparse_remove_one_section(struct zone *zone, struct mem_section *ms,
+extern void sparse_remove_one_section(struct mem_section *ms,
 		unsigned long map_offset, struct vmem_altmap *altmap);
 extern struct page *sparse_decode_mem_map(unsigned long coded_mem_map,
 					  unsigned long pnum);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 527fe4f9c620..e0340c8f6df4 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -523,7 +523,7 @@ static void __remove_section(struct zone *zone, struct mem_section *ms,
 	start_pfn = section_nr_to_pfn((unsigned long)scn_nr);
 	__remove_zone(zone, start_pfn);
 
-	sparse_remove_one_section(zone, ms, map_offset, altmap);
+	sparse_remove_one_section(ms, map_offset, altmap);
 }
 
 /**
diff --git a/mm/sparse.c b/mm/sparse.c
index d1d5e05f5b8d..1552c855d62a 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -800,8 +800,8 @@ static void free_section_usemap(struct page *memmap, unsigned long *usemap,
 		free_map_bootmem(memmap);
 }
 
-void sparse_remove_one_section(struct zone *zone, struct mem_section *ms,
-		unsigned long map_offset, struct vmem_altmap *altmap)
+void sparse_remove_one_section(struct mem_section *ms, unsigned long map_offset,
+			       struct vmem_altmap *altmap)
 {
 	struct page *memmap = NULL;
 	unsigned long *usemap = NULL;
-- 
2.20.1
