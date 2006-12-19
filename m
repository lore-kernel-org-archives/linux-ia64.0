From: Horms <horms@verge.net.au>
Date: Tue, 19 Dec 2006 03:35:58 +0000
Subject: Re: 05e0caad3b7bd0d0fbeff980bca22f186241a501 breaks ia64 kdump
Message-Id: <20061219033556.GA4213@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061026075951.GA30910@verge.net.au>
In-Reply-To: <20061026075951.GA30910@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Dec 18, 2006 at 02:52:44PM +0000, Mel Gorman wrote:
> On (12/12/06 18:10), Horms didst pronounce:
> > On Mon, Nov 20, 2006 at 09:40:32AM +0800, Zou, Nanhai wrote:
> > > > -----Original Message-----
> > > > From: Luck, Tony
> > > > Sent: 2006?$BG/11?$B7n17?$BF| 1:36
> > > > To: Zou, Nanhai; 'Mel Gorman'
> > > > Cc: 'Horms'; 'Andy Whitcroft'; 'Linux-IA64'; 'Bob Picco'; 'Andrew Morton';
> > > > 'Dave Hansen'; 'Andi Kleen'; 'Benjamin Herrenschmidt'; 'Paul Mackerras';
> > > > 'Keith Mannthey'; 'KAMEZAWA Hiroyuki'; 'Yasunori Goto'; 'Khalid Aziz'
> > > > Subject: RE: 05e0caad3b7bd0d0fbeff980bca22f186241a501 breaks ia64 kdump
> > > > 
> > > > 
> > > > > I think that depends on the init value of memmap, if they
> > > > > are all zero, free_pages_check will be happy and not report
> > > > > any thing. So I guess we may see this bug in normal kernel
> > > > > with a warm reboot, or with a machine which PROM does not
> > > > > clear memory to all zero.
> > > > 
> > > > I don't think there is any requirement that PROM clear memory
> > > > to zero ... if the kernel is making that assumption anywhere,
> > > > then this is a bug.  I thought that the initialization code
> > > > wrote to each of the fields of the page struct that it needed
> > > > to (certainly ->count and ->flags are set by __free_pages_bootmem,
> > > > but I'm not so sure about ->mapping ... which free_pages_check()
> > > > looks at).
> > > >
> > >   Yes, so the add_active_range in discontigmem need fix.  I think
> > >   Bob's patch is ok, it is almost the same as mine except the
> > >   CONFIG_KEXEC part. So we may first include Bob's patch, I will
> > >   add CONFIG_KEXEC part after KEXEC_KDUMP patch is in mainstream.
> > 
> > Now that ia64 kexec/kdump has been merged into Linus tree this
> > really ought to be fixed. What is the best way forward?
> > 
> 
> Sorry for the delay in responding. I was ill all of last week and
> offline as a result. First, can you confirm the problem still exist?
> Assuming it does, does Bob's patch fix it? A compile-tested rebase
> against 2.6.20-rc1-mm1 of the patch is posted below for your
> convenience. I don'y have access to an ia64 machine right now to boot
> test it.

I took a look at this problem using Linus' current git tree (~v2.6.20-rc1)
on a Tiger2 machine. Yes the problem does still manifest. And yes,
the patch does seem to resolve the problem. 

crashkernel%6Mb@256Mb

First kernel: 

Zone PFN ranges:
  DMA          1024 ->   262144
  Normal     262144 ->   262144
early_node_map[3] active PFN ranges
    0:     1024 ->   128557
    0:   128576 ->   130688
    0:   130984 ->   130998

Crash (second) kernel:

Zone PFN ranges:
  DMA         16384 ->   262144
  Normal     262144 ->   262144
early_node_map[1] active PFN ranges
    0:    16384 ->    31744

> >>> Begin Bob's patch
> 
> While pursuing and unrelated issue with 64Mb granules I noticed a problem
> related to inconsistent use of add_active_range. There doesn't appear any
> reason to me why FLATMEM versus DISCONTIG_MEM should register memory
> to add_active_range with different code. So I've changed the code into
> a common implementation. 
> 
> The other subtle issue fixed by this patch was calling add_active_range
> in count_node_pages before granule aligning is performed. We were lucky with
> 16MB granules but not so with 64MB granules. count_node_pages has reserved
> regions filtered out and as a consequence linked kernel text and data
> aren't covered by calls to count_node_pages. So linked kernel regions
> wasn't reported to add_active_regions. This resulted in free_initmem causing
> numerous bad_page reports. This won't occur with this patch because now
> all known memory regions are reported by register_active_ranges.

I won't pretend that I understand the nitty-gritty of exactly what this
patch does.  But it does seem fine to me. I have put a few minor
comments inline below.

> Acked-by: Mel Gorman <mel@csn.ul.ie>
> Signed-off-by: Bob Picco <bob.picco@hp.com>
> 
>  arch/ia64/mm/discontig.c   |    4 +++-
>  arch/ia64/mm/init.c        |   18 ++++++++++++++++--
>  include/asm-ia64/meminit.h |    3 ++-
>  3 files changed, 21 insertions(+), 4 deletions(-)
> 
> diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.20-rc1-mm1-clean/arch/ia64/mm/discontig.c linux-2.6.20-rc1-mm1-register_all_memory/arch/ia64/mm/discontig.c
> --- linux-2.6.20-rc1-mm1-clean/arch/ia64/mm/discontig.c	2006-12-18 14:12:18.000000000 +0000
> +++ linux-2.6.20-rc1-mm1-register_all_memory/arch/ia64/mm/discontig.c	2006-12-18 14:39:28.000000000 +0000
> @@ -475,6 +475,9 @@ void __init find_memory(void)
>  			node_clear(node, memory_less_mask);
>  			mem_data[node].min_pfn = ~0UL;
>  		}
> +
> +	efi_memmap_walk(register_active_ranges, NULL);
> +
>  	/*
>  	 * Initialize the boot memory maps in reverse order since that's
>  	 * what the bootmem allocator expects
> @@ -656,7 +659,6 @@ static __init int count_node_pages(unsig
>  {
>  	unsigned long end = start + len;
>  
> -	add_active_range(node, start >> PAGE_SHIFT, end >> PAGE_SHIFT);
>  	mem_data[node].num_physpages += len >> PAGE_SHIFT;
>  #ifdef CONFIG_ZONE_DMA
>  	if (start <= __pa(MAX_DMA_ADDRESS))
> diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.20-rc1-mm1-clean/arch/ia64/mm/init.c linux-2.6.20-rc1-mm1-register_all_memory/arch/ia64/mm/init.c
> --- linux-2.6.20-rc1-mm1-clean/arch/ia64/mm/init.c	2006-12-14 01:14:23.000000000 +0000
> +++ linux-2.6.20-rc1-mm1-register_all_memory/arch/ia64/mm/init.c	2006-12-18 14:42:40.000000000 +0000

linux/kexec.h is needed in order for crashk_res to be defined.
The following fragment does that.

@@ -19,6 +19,7 @@
 #include <linux/swap.h>
 #include <linux/proc_fs.h>
 #include <linux/bitops.h>
+#include <linux/kexec.h>
 
 #include <asm/a.out.h>
 #include <asm/dma.h>

> @@ -594,13 +594,27 @@ find_largest_hole (u64 start, u64 end, v
>  	return 0;
>  }
>  
> +#endif /* CONFIG_VIRTUAL_MEM_MAP */
> +
>  int __init
>  register_active_ranges(u64 start, u64 end, void *arg)
>  {
> -	add_active_range(0, __pa(start) >> PAGE_SHIFT, __pa(end) >> PAGE_SHIFT);
> +	int nid = paddr_to_nid(__pa(start));
> +
> +	if (nid < 0)
> +		nid = 0;
> +#ifdef CONFIG_KEXEC
> +	if (start > crashk_res.start && start < crashk_res.end)
> +		start = max(start, crashk_res.end);
> +	if (end > crashk_res.start && end < crashk_res.end)
> +		end = min(end, crashk_res.start);

I think having (start < crashk_res.end) as a condition and then using
max() is redundant (though harmless). Ditto for (end < crashk_res.end and)
min(). How about the following?

	if (start > crashk_res.start && start < crashk_res.end)
		start = crashk_res.end;
	if (end > crashk_res.start && end < crashk_res.end)
		end = crashk_res.start;


> +#endif
> +
> +	if (start < end)
> +		add_active_range(nid, __pa(start) >> PAGE_SHIFT,
> +			__pa(end) >> PAGE_SHIFT);
>  	return 0;
>  }
> -#endif /* CONFIG_VIRTUAL_MEM_MAP */
>  
>  static int __init
>  count_reserved_pages (u64 start, u64 end, void *arg)
> diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.20-rc1-mm1-clean/include/asm-ia64/meminit.h linux-2.6.20-rc1-mm1-register_all_memory/include/asm-ia64/meminit.h
> --- linux-2.6.20-rc1-mm1-clean/include/asm-ia64/meminit.h	2006-12-14 01:14:23.000000000 +0000
> +++ linux-2.6.20-rc1-mm1-register_all_memory/include/asm-ia64/meminit.h	2006-12-18 14:39:28.000000000 +0000
> @@ -51,12 +51,13 @@ extern void efi_memmap_init(unsigned lon
>  
>  #define IGNORE_PFN0	1	/* XXX fix me: ignore pfn 0 until TLB miss handler is updated... */
>  
> +extern int register_active_ranges (u64 start, u64 end, void *arg);
> +
>  #ifdef CONFIG_VIRTUAL_MEM_MAP
>  # define LARGE_GAP	0x40000000 /* Use virtual mem map if hole is > than this */
>    extern unsigned long vmalloc_end;
>    extern struct page *vmem_map;
>    extern int find_largest_hole (u64 start, u64 end, void *arg);
> -  extern int register_active_ranges (u64 start, u64 end, void *arg);
>    extern int create_mem_map_page_table (u64 start, u64 end, void *arg);
>    extern int vmemmap_find_next_valid_pfn(int, int);
>  #else

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

