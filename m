From: mel@skynet.ie (Mel Gorman)
Date: Thu, 16 Nov 2006 16:05:41 +0000
Subject: Re: 05e0caad3b7bd0d0fbeff980bca22f186241a501 breaks ia64 kdump
Message-Id: <20061116160540.GA6747@skynet.ie>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061026075951.GA30910@verge.net.au>
In-Reply-To: <20061026075951.GA30910@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> > As you say, it's not clear why the normal discontig kernel boots because
> > the regions should have been skipped by add_active_range().
> >
>   I think that depends on the init value of memmap, if they are all zero,
>   free_pages_check will be happy and not report any thing. So I guess we may
>   see this bug in normal kernel with a warm reboot, or with a machine which
>   PROM does not clear memory to all zero.

It could have been just luck. See more below

>  
> > Try your patch and see does it work for kdump. It should work fine in the
> > normal case because at very worst, slightly more memmap is allocated than
> > is strictly required.
> > 
>   It works for kdump.
> 

Can you try out the patch below please as a possibly simplier alternative? It's
a patch from Bob Picco that addresses a similar problem with initmem on a
kernel booting as normal. The only difference between Bob's original patch
and this one is the addition of the CONFIG_KEXEC stuff from your patch. It
survived a simply boot test.

Thanks

>>> Begin Bob's patch

While pursuing and unrelated issue with 64Mb granules I noticed a problem
related to inconsistent use of add_active_range. There doesn't appear any
reason to me why FLATMEM versus DISCONTIG_MEM should register memory
to add_active_range with different code. So I've changed the code into
a common implementation. 

The other subtle issue fixed by this patch was calling add_active_range
in count_node_pages before granule aligning is performed. We were lucky with
16MB granules but not so with 64MB granules. count_node_pages has reserved
regions filtered out and as a consequence linked kernel text and data
aren't covered by calls to count_node_pages. So linked kernel regions
wasn't reported to add_active_regions. This resulted in free_initmem causing
numerous bad_page reports. This won't occur with this patch because now
all known memory regions are reported by register_active_ranges.

Acked-by: Mel Gorman <mel@csn.ul.ie>
Signed-off-by: Bob Picco <bob.picco@hp.com>

 arch/ia64/mm/contig.c      |    3 +--
 arch/ia64/mm/discontig.c   |    4 +++-
 arch/ia64/mm/init.c        |   24 +++++++++++++++++-------
 include/asm-ia64/meminit.h |    3 ++-
 4 files changed, 23 insertions(+), 11 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.19-rc5-clean/arch/ia64/mm/contig.c linux-2.6.19-rc5-register_all_memory/arch/ia64/mm/contig.c
--- linux-2.6.19-rc5-clean/arch/ia64/mm/contig.c	2006-11-08 02:24:20.000000000 +0000
+++ linux-2.6.19-rc5-register_all_memory/arch/ia64/mm/contig.c	2006-11-16 15:29:31.000000000 +0000
@@ -226,7 +226,6 @@ void __init
 paging_init (void)
 {
 	unsigned long max_dma;
-	unsigned long nid = 0;
 	unsigned long max_zone_pfns[MAX_NR_ZONES];
 
 	num_physpages = 0;
@@ -238,7 +237,7 @@ paging_init (void)
 	max_zone_pfns[ZONE_NORMAL] = max_low_pfn;
 
 #ifdef CONFIG_VIRTUAL_MEM_MAP
-	efi_memmap_walk(register_active_ranges, &nid);
+	efi_memmap_walk(register_active_ranges, NULL);
 	efi_memmap_walk(find_largest_hole, (u64 *)&max_gap);
 	if (max_gap < LARGE_GAP) {
 		vmem_map = (struct page *) 0;
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.19-rc5-clean/arch/ia64/mm/discontig.c linux-2.6.19-rc5-register_all_memory/arch/ia64/mm/discontig.c
--- linux-2.6.19-rc5-clean/arch/ia64/mm/discontig.c	2006-11-08 02:24:20.000000000 +0000
+++ linux-2.6.19-rc5-register_all_memory/arch/ia64/mm/discontig.c	2006-11-16 15:29:31.000000000 +0000
@@ -473,6 +473,9 @@ void __init find_memory(void)
 			node_clear(node, memory_less_mask);
 			mem_data[node].min_pfn = ~0UL;
 		}
+
+	efi_memmap_walk(register_active_ranges, NULL);
+
 	/*
 	 * Initialize the boot memory maps in reverse order since that's
 	 * what the bootmem allocator expects
@@ -654,7 +657,6 @@ static __init int count_node_pages(unsig
 {
 	unsigned long end = start + len;
 
-	add_active_range(node, start >> PAGE_SHIFT, end >> PAGE_SHIFT);
 	mem_data[node].num_physpages += len >> PAGE_SHIFT;
 	if (start <= __pa(MAX_DMA_ADDRESS))
 		mem_data[node].num_dma_physpages +diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.19-rc5-clean/arch/ia64/mm/init.c linux-2.6.19-rc5-register_all_memory/arch/ia64/mm/init.c
--- linux-2.6.19-rc5-clean/arch/ia64/mm/init.c	2006-11-08 02:24:20.000000000 +0000
+++ linux-2.6.19-rc5-register_all_memory/arch/ia64/mm/init.c	2006-11-16 15:33:25.000000000 +0000
@@ -594,18 +594,28 @@ find_largest_hole (u64 start, u64 end, v
 	return 0;
 }
 
+#endif /* CONFIG_VIRTUAL_MEM_MAP */
+
 int __init
-register_active_ranges(u64 start, u64 end, void *nid)
+register_active_ranges(u64 start, u64 end, void *arg)
 {
-	BUG_ON(nid = NULL);
-	BUG_ON(*(unsigned long *)nid >= MAX_NUMNODES);
+	int nid = paddr_to_nid(__pa(start));
+
+	if (nid < 0)
+		nid = 0;
 
-	add_active_range(*(unsigned long *)nid,
-				__pa(start) >> PAGE_SHIFT,
-				__pa(end) >> PAGE_SHIFT);
+#ifdef CONFIG_KEXEC
+	if (start > crashk_res.start && start < crashk_res.end)
+		start = max(start, crashk_res.end);
+	if (end > crashk_res.start && end < crashk_res.end)
+		end = min(end, crashk_res.start);
+#endif
+	
+	if (start < end)
+		add_active_range(nid, __pa(start) >> PAGE_SHIFT,
+			__pa(end) >> PAGE_SHIFT);
 	return 0;
 }
-#endif /* CONFIG_VIRTUAL_MEM_MAP */
 
 static int __init
 count_reserved_pages (u64 start, u64 end, void *arg)
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.19-rc5-clean/include/asm-ia64/meminit.h linux-2.6.19-rc5-register_all_memory/include/asm-ia64/meminit.h
--- linux-2.6.19-rc5-clean/include/asm-ia64/meminit.h	2006-11-08 02:24:20.000000000 +0000
+++ linux-2.6.19-rc5-register_all_memory/include/asm-ia64/meminit.h	2006-11-16 15:29:31.000000000 +0000
@@ -50,12 +50,13 @@ extern void efi_memmap_init(unsigned lon
 
 #define IGNORE_PFN0	1	/* XXX fix me: ignore pfn 0 until TLB miss handler is updated... */
 
+extern int register_active_ranges (u64 start, u64 end, void *arg);
+
 #ifdef CONFIG_VIRTUAL_MEM_MAP
 # define LARGE_GAP	0x40000000 /* Use virtual mem map if hole is > than this */
   extern unsigned long vmalloc_end;
   extern struct page *vmem_map;
   extern int find_largest_hole (u64 start, u64 end, void *arg);
-  extern int register_active_ranges (u64 start, u64 end, void *arg);
   extern int create_mem_map_page_table (u64 start, u64 end, void *arg);
   extern int vmemmap_find_next_valid_pfn(int, int);
 #else

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab
