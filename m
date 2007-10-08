From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 08 Oct 2007 20:25:59 +0000
Subject: RE: [PATCH] Register memory ranges in a consistent manner on IA64
Message-Id: <617E1C2C70743745A92448908E030B2A02A23183@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070117131832.GA27728@localhost>
In-Reply-To: <20070117131832.GA27728@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

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

This was applied back in January, but we've now found a hole in the
implementation.  Skipping the path through filter_rsvd_memory() fixes
the problem with kernel regions not being reported to add_active_regions().
But it also bypasses the path through "call_pernode_memory()" which
neatly assigned all memory to the right node.  The code Bob added in
register_active_ranges() that calls paddr_to_node() on the first address
in the block found in the efi_memory map doesn't allow for the fact that
a memory block in the efi memory map may span across nodes. And we've
now found a system where this happens ... so memory that belongs to
node 1 is being attached to node 0 because it happens to be part of
a contiguous block of memory that starts on node 0.

I'd initially coded but a fix that put the filter_reserved_memory()
path back in.  But on more careful reading of your comments in the
commit I see that will re-introduce problems that were fixed before.

Perhaps we should change the calling convention for call_pernode_memory()
(It currently takes [start,len] as physical addresses rather than [start,end]
as virtual addresses) so it can be used as a first argument to
efi_memmap_walk() ... so the code can be:

	efi_memmap_walk(call_pernode_memory, register_active_ranges);

Thoughts?

-Tony
