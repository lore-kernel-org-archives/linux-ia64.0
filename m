From: Wei Yang <richard.weiyang@gmail.com>
Date: Wed, 05 Jun 2019 21:21:25 +0000
Subject: Re: [PATCH v3 11/11] mm/memory_hotplug: Remove "zone" parameter from sparse_remove_one_section
Message-Id: <20190605212125.gwmvjjicylhp3wcz@master>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190527111152.16324-1-david@redhat.com>
 <20190527111152.16324-12-david@redhat.com>
In-Reply-To: <20190527111152.16324-12-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Hildenbrand <david@redhat.com>
Cc: linux-s390@vger.kernel.org, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, linux-kernel@vger.kernel.org, Wei Yang <richard.weiyang@gmail.com>, linux-mm@kvack.org, Igor Mammedov <imammedo@redhat.com>, akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org, Dan Williams <dan.j.williams@intel.com>, linux-arm-kernel@lists.infradead.org

On Mon, May 27, 2019 at 01:11:52PM +0200, David Hildenbrand wrote:
>The parameter is unused, so let's drop it. Memory removal paths should
>never care about zones. This is the job of memory offlining and will
>require more refactorings.
>
>Reviewed-by: Dan Williams <dan.j.williams@intel.com>
>Signed-off-by: David Hildenbrand <david@redhat.com>

Reviewed-by: Wei Yang <richardw.yang@linux.intel.com>

>---
> include/linux/memory_hotplug.h | 2 +-
> mm/memory_hotplug.c            | 2 +-
> mm/sparse.c                    | 4 ++--
> 3 files changed, 4 insertions(+), 4 deletions(-)
>
>diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
>index 2f1f87e13baa..1a4257c5f74c 100644
>--- a/include/linux/memory_hotplug.h
>+++ b/include/linux/memory_hotplug.h
>@@ -346,7 +346,7 @@ extern void move_pfn_range_to_zone(struct zone *zone, unsigned long start_pfn,
> extern bool is_memblock_offlined(struct memory_block *mem);
> extern int sparse_add_one_section(int nid, unsigned long start_pfn,
> 				  struct vmem_altmap *altmap);
>-extern void sparse_remove_one_section(struct zone *zone, struct mem_section *ms,
>+extern void sparse_remove_one_section(struct mem_section *ms,
> 		unsigned long map_offset, struct vmem_altmap *altmap);
> extern struct page *sparse_decode_mem_map(unsigned long coded_mem_map,
> 					  unsigned long pnum);
>diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>index 82136c5b4c5f..e48ec7b9dee2 100644
>--- a/mm/memory_hotplug.c
>+++ b/mm/memory_hotplug.c
>@@ -524,7 +524,7 @@ static void __remove_section(struct zone *zone, struct mem_section *ms,
> 	start_pfn = section_nr_to_pfn((unsigned long)scn_nr);
> 	__remove_zone(zone, start_pfn);
> 
>-	sparse_remove_one_section(zone, ms, map_offset, altmap);
>+	sparse_remove_one_section(ms, map_offset, altmap);
> }
> 
> /**
>diff --git a/mm/sparse.c b/mm/sparse.c
>index d1d5e05f5b8d..1552c855d62a 100644
>--- a/mm/sparse.c
>+++ b/mm/sparse.c
>@@ -800,8 +800,8 @@ static void free_section_usemap(struct page *memmap, unsigned long *usemap,
> 		free_map_bootmem(memmap);
> }
> 
>-void sparse_remove_one_section(struct zone *zone, struct mem_section *ms,
>-		unsigned long map_offset, struct vmem_altmap *altmap)
>+void sparse_remove_one_section(struct mem_section *ms, unsigned long map_offset,
>+			       struct vmem_altmap *altmap)
> {
> 	struct page *memmap = NULL;
> 	unsigned long *usemap = NULL;
>-- 
>2.20.1

-- 
Wei Yang
Help you, Help me
