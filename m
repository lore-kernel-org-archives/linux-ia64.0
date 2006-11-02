From: Mel Gorman <mel@csn.ul.ie>
Date: Thu, 02 Nov 2006 16:26:52 +0000
Subject: Re: 05e0caad3b7bd0d0fbeff980bca22f186241a501 breaks ia64 kdump
Message-Id: <Pine.LNX.4.64.0611021622270.14806@skynet.skynet.ie>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061026075951.GA30910@verge.net.au>
In-Reply-To: <20061026075951.GA30910@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 2 Nov 2006, Horms wrote:

> On Wed, Nov 01, 2006 at 09:38:38AM +0000, Mel Gorman wrote:
>>
>> Plan C
>>
>> Call add_active_ranges() for the the PFN ranges initmem reside in.
>> Look at free_initmem() to see how to get the virtual address of the
>> range is found and make the appropriate conversion. A variation is to
>> call add_active_ranges() for the PFN range the whole kernel resides in
>> if you have that information for the crash kernel.
>
> I've made a version of this approach that seems to work.
> I had to update add_active_range so that it merges
> ranges that are not overlapping, but do create a continous range.
> Is this a correct thing to do?
>

It's a bit unlikely it's the correct fix. As you can see, the 
add_active_range() is already able to merge contiguous ranges. If the 
calls imply there is a one page hole, then there is a one page hole. If 
the caller is wrong and there isn't a one-page hole, then fix the caller 
walking the map. Power for example currently merges large numbers of 
adjacent regions that are registered separetly.


> -- 
> Horms
>  H: http://www.vergenet.net/~horms/
>  W: http://www.valinux.co.jp/en/
>
> Index: linux-2.6/mm/page_alloc.c
> =================================> --- linux-2.6.orig/mm/page_alloc.c	2006-11-02 16:17:17.000000000 +0900
> +++ linux-2.6/mm/page_alloc.c	2006-11-02 16:17:22.000000000 +0900
> @@ -2407,7 +2407,7 @@
> 			return;
>
> 		/* Merge forward if suitable */
> -		if (start_pfn <= early_node_map[i].end_pfn &&
> +		if (start_pfn <= early_node_map[i].end_pfn + 1 &&
> 				end_pfn > early_node_map[i].end_pfn) {
> 			early_node_map[i].end_pfn = end_pfn;
> 			return;
> @@ -2415,7 +2415,7 @@
>
> 		/* Merge backward if suitable */
> 		if (start_pfn < early_node_map[i].end_pfn &&
> -				end_pfn >= early_node_map[i].start_pfn) {
> +				end_pfn + 1 >= early_node_map[i].start_pfn) {
> 			early_node_map[i].start_pfn = start_pfn;
> 			return;
> 		}
> Index: linux-2.6/arch/ia64/mm/discontig.c
> =================================> --- linux-2.6.orig/arch/ia64/mm/discontig.c	2006-11-02 16:17:59.000000000 +0900
> +++ linux-2.6/arch/ia64/mm/discontig.c	2006-11-02 16:18:03.000000000 +0900
> @@ -689,6 +689,8 @@
> 	arch_sparse_init();
>
> 	efi_memmap_walk(filter_rsvd_memory, count_node_pages);
> +	add_active_range(0, ia64_tpa(_text) >> PAGE_SHIFT,
> +	                 (ia64_tpa(_end) -1 ) >> PAGE_SHIFT);
>
> #ifdef CONFIG_VIRTUAL_MEM_MAP
> 	vmalloc_end -= PAGE_ALIGN(ALIGN(max_low_pfn, MAX_ORDER_NR_PAGES) *
>

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab
