From: Jack Steiner <steiner@sgi.com>
Date: Fri, 16 Aug 2002 21:53:56 +0000
Subject: Re: [Linux-ia64] Re: [Discontig-devel] CLUMPS, CHUNKS and GRANULES
Message-Id: <marc-linux-ia64-105590701905945@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905942@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905942@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Good start.

I like the idea of trying to simplify the discontig concepts. I
expect we will iterate a few times before we settle on something,
I've spent much of today refreshing my memory on why things are the
way they are.

Discontig is certainly difficult to understand but it is trying
to provide an abstract framework for describing a very diverse of 
hardware. The SGI hardware, unfortunately, is likely to be 
the "worst case" example. :-(


Here are some comments.  More to follow......

-------------------------------------------------------------------------


> 
> Hi Tony,
> 
> hmmm, no comments to your post yesterday... maybe we find more people
> interested on this on lia64 ML?
> 
> Actually I wanted to make some suggestions regarding the names, but
> after looking at some code I'd rather like to suggest to simplify
> things and get rid of some concepts. In my opinion we need only
> the following concepts inside DISCONTIGMEM:
>  - node IDs (AKA compact node IDs or logical nodes).
>  - physical node IDs
>  - clumps (I'd prefer the name memory BANKS here, as a clump suggests
>  something to be contiguous, without holes (German: Klumpen)).
> 
> In the initialisation phase we need:
>  - memory blocks (AKA chunks?) (contiguous pieces of memory on one
>  node, provided by ACPI, only used for setup. No size or alignment
>  expected. Needed later for paddr_to_nid() but that's all.)
>  - proximity domains (only ACPI NUMA setup, invisible to the rest of
>  the DISCONTIG code).
> 
> This reduces the number of platform specific macros considerably and
> should improve the readability of the code.
> 
> Therefore a node would have several memory banks which are not
> necessarily adjacent in the physical memory space. There can be gaps
> or banks from other nodes interleaved. In the mem_map array there is
> space reserved for page struct entries of ALL pages of one bank,
> existent or not. Memory holes between banks don't build holes in the
> mem_map array.

If the mem_map has entries for pages that dont exist, how do you handle
code that scans the mem_map array. How does code recognize  & skip pages
associated with missing memory?? For examples, see show_mem()
& get_discontig_info(). (Maybe I misunderstood your proposal here).


I _think_ I have a another problem with the concept of page struct
entries for non-existent memory, but I may be misinterpreting something.
I  created a detailed description of the SGI memory map. Let's use it
as an example for our discussion. (Maybe other architectures should
do the same thing???)




=======================================
SGI SN2

This is the memory map for physical node 0. 
I've shown a typical way the node can be
populated with memory.

For other nodes, add 256GB*physical_node_num
to each of the addresses.

A few more oddities:
	- physical node numbers are all even numbers
	- physical nodes numbers are in the range of 0..2048
	  and can be very sparse.
	- IO space is interspersed BETWEEN the nodes - not
	  at the end.
	- physical node 0 normally doesnt exist. Starting
	  node number is indeterminate.
	

(I hope the formatting doesnt get mangled.



end     ------------------- 192GB+64GB
        |  ///////////    |
        |  ///////////    |
        |    empty        |
        |  ///////////    |
        | - - - - - - - - |
        |                 |
        |      2GB        |
        |-----------------| 192GB+48GB
        |  ///////////    |
        |  ///////////    |
        |  ///////////    |
        |    empty        |
        |  ///////////    |
        |  ///////////    |
        |  ///////////    |
        |-----------------| 192GB+32GB
        |  ///////////    |
        |    empty        |
        |  ///////////    |
        | - - - - - - - - |
        |                 |
        |      8GB        |
        |                 |
        |-----------------| 192GB+16GB
        |  ///////////    |
        |  ///////////    |
        |    empty        |
        |  ///////////    |
        |  ///////////    |
        | - - - - - - - - |
        |      1GB        |
start	------------------- 192GB


A node consists of 4 chunks (banks) of memory. Chunks are populated 
independent of each other. Each chunk will have contiguous memory 
with no holes. 

The amount of memory in each chunk is 128MB, 256MB, 512MB ...
16GB. A few of the smaller sizes may be deprecated - I'll check.



We currently describe this in mmzone_sn2.h as:

	NODESIZE        = 64GB
	MAX_NODES       = 128
	MAX_NODE_NUMBER = 2048  		// plus 1
	CHUNKSIZE       = 32MB  		// (for other reasons)
	CLUMPSIZE       = 16GB
	CLUMPS_PER_NODE = 4

To make sure I understand your proposal, how do you see this
being described??

=======================================






> 
> Appended are some comments to the mem.txt attachment, somewhat
> lengthy, but explaining more in detail what I summarized above.
> 
> ---------- comments to mem.txt (in include/asm-ia64/mmzone.h) ---------
> > - Nodes are numbered several ways:
> >
> > 	compact node numbers - compact node numbers are a dense numbering of
> > 	all the nodes in the system. An N node system will have compact
> > 	nodes numbered 0 .. N-1. There is no significance to the node
> > 	numbers. The compact node number assigned to a specific physical
> > 	node may vary from boot to boot. The boot node is not necessarily
> > 	node 0.
> 
> I'd prefer to call them "logical node numbers" or just "node numbers",
> similar to CPUs. We don't have compact CPU IDs.

I dont particularily care for "compact node number" either. Changing it is ok as 
long as we can come up with consistent naming for both the "physical" and 
"logical" node concepts. In the past, this have proven to be difficult since some 
platforms dont really have both concepts.

On the SGI platform, "physical node number" has a very precise definition. This is
not true on all architectures. On SGI, the physical number is bits [48:38] of
the physical address. In addition, a system can run with a sparse set of physical
node numbers. For example, a 3 node system could have physical node 512, 800 & 2012. 




> > 	proximity domain numbers - these numbers are assigned by ACPI.
> > 	Each platform must provide a platform specific function
> > 	for mapping proximity node numbers to physical node numbers.
> 
> The proximity domain numbers are unnecessary. They are just other

Unfortunately, for SGI hardware,  proximity domain numbers cant be the same as
a physical node number. ACPI limits proximity domain numbers to 0..254. On
SGI, physical node numbers are 0..2047. Fortunately, we found a way
to compress the physical node number into a proximity domain number.
In the future, though, our current "trick" may no longer work. If we can
get the the proximity domain numbers changed to 0..65K, then I
agree that it could be the same as the physical node number.
Is there any chance we can get this changed???



> (compact) mapping. Only SGI uses the pxm numbers later as:
> #define PLAT_BOOTMEM_ALLOC_GOAL(cnode,kaddr) \
>   __pa(SN2_KADDR(PLAT_PXM_TO_PHYS_NODE_NUMBER(nid_to_pxm_map[cnode]) ...
> but it is clear that what they actually want to do is translate the
> compact node id to a physical node id. They just misuse the PXM
> translation tables for this. All reference to proximity domain numbers
> can be eliminated after the ACPI setup phase. Maybe we need some map
> when hotplugging and adjusting a physical->logical translation table,
> but not in DISCONTIG.
> 
> > - Memory is conceptually divided into chunks. A chunk is either
> >   completely present, or else the kernel assumes it is completely
> >   absent. Each node consists of a number of possibly discontiguous chunks.
> 
> When reading the code I get the impression that the concept of a CHUNK
> isn't really needed in the code. The definitions are misleading
> because they suggest that CHUNKS are equally sized (there is a
> CHUNKSHIFT) and we should expect ACPI to give us a bunch of
> chunks. But all we really need these for is to check whether a
> physical address is valid or to find out to which node a physical
> address belongs to. When building the mem_map and the page struct
> entries we need to know whether a page is inside a valid memory block
> or not, no matter how this memory block looks like, how big it is
> of whether it fits into one clump or not. On Azusa a chunk returned by
> ACPI can span the whole node memory, thus the rule: "a clump is made
> of chunks" is not valid.

Agree that CHUNK is barely used. I think the way GRANULE is being used, it
may replace the need for CHUNKs.

The original reason for CHUNK was for support of kern_addr_valid(). Since a chunk
is either all present OR all missing, using CHUNKNUM as an index into
a bit array (or tree) seemed like a fast way to determine whether a 
chunk was present.

However, since IA64 doesnt current implement a kern_addr_valid() function, CHUNK
is not currently used.

Do you know if kern_addr_valid() for IA64 is planned in the future???

It appears that GRANULE could be used the same way as CHUNK.



> 
> I tried to find the places where the CHUNKs are used:
> - PLAT_CHUNKNUM : used by SGI for kern_addr_valid in the form
> VALIDCHUNK(PLAT_CHUNKNUM(_kav))
> but VALIDCHUNK allways returns 1! So it is not needed!
> - PLAT_CHUNKSIZE : only used in CHUNKROUNDUP in discontig.c. I think
> we can recode this to round up to a GRANULE boundary, that's what we
> really want, I guess.
> - *_CHUNKSHIFT is only used for PLAT_CHUNKSIZE and PLAT_CHUNKNUM.
> 
> On NEC Azusa ACPI returns each available contiguous memory block as
> one SRAT table entry. The size and the alignment can vary, there are
> no fixed size chunks. For building up the clumps, we don't need to
> know anything about these chunks! If a clump has holes, the setup
> routine will take care of them. All we need is the list of memory
> blocks delivered by ACPI and their assignment to nodes. The maximum
> number of memory blocks expected is currently set to PLAT_MAXCLUMPS. I
> think this is wrong, as a clump can contain multiple memory blocks.
> 
> I would like to eliminate the CHUNK concept and the need for setting a
> lot of CHUNK related macros for each platform. All we really need is
> MAX_NR_MEMBLKS and only the setup routines will deal with these
> blocks. Call the ACPI memory blocks CHUNKS again, if you want, but
> they are only needed in the setup phase related to ACPI and shouldn't
> need an own philosophy within DISCONTIG.
> 
> 
> > - A contiguous group of memory chunks that reside on the same node
> >   are referred to as a clump. Note that a clump may be partially present.
> >   (Note, on some hardware implementations, a clump is the same as a memory
> >   bank or a DIMM).
> >
> > - a node consists of multiple clumps of memory. From a NUMA perspective
> >   accesses to all clumps on the node have the same latency. Except for zone issues,
> >   the clumps are treated as equivalent for allocation/performance purposes.
> >
> > - each node has a single contiguous mem_map array. The array contains page struct
> >   entries for every page on the node. There are no "holes" in the mem_map array.
> >   The node data area (see below) has pointers to the start of the mem_map entries
> >   for each clump on the node.
> 
> The mem_map array is the same on each node, copied from the boot_node
> to all other nodes. It contains page_struct entries for ALL pages on
> ALL nodes (if I interpret discontig_paging_init() correctly). The
> first two sentences need to be reformulated.

I think the first two sentences are correct, but the last one is misleading.
Is this better:

	- each node has a single contiguous page_struct array. This array contains page struct
	  entries for every page that is actually present on the node. There are no 
	  "holes" in the page_struct array for non-existent memory. Note that
	  adjacent entries in the array are NOT necessarily for contiguous physical
	  pages if there are multiple non-contiguous clumps on the node.

	  The node data area (see below) has pointers to the start of the page_struct 
	  entries for each clump on the node.

> 
> 
> > - each platform is responsible for defining the following constants & functions:
> >
> > 	PLAT_BOOTMEM_ALLOC_GOAL(cnode,kaddr) - Calculate a "goal" value to be passed
> > 		to __alloc_bootmem_node for allocating structures on nodes so that
> > 		they dont alias to the same line in the cache as the previous
> > 		allocated structure. You can return 0 if your platform doesnt have
> > 		this problem.
> > 			(Note: need better solution but works for now ZZZ).
> 
> Either I misunderstood something or the definition in
> include/asm-ia64/sn/sn2/mmzone_sn2.h doesn't really unalias the
> cachelines. This would be nice to have!

I'm not real happy with this solution, but I think it works. To verify it, I added a 
printk right after the point in discontig.c that does the allocate:

	Alloc pgdat: cnode 6, pnode 42, pgdat 0xe0000ab000106880, size 0xc4b8, goal 0xab000010000
	Alloc pgdat: cnode 5, pnode 38, pgdat 0xe00009b000114000, size 0xc4b8, goal 0x9b000114000
	Alloc pgdat: cnode 4, pnode 36, pgdat 0xe000093000124000, size 0xc4b8, goal 0x93000124000
	Alloc pgdat: cnode 3, pnode 34, pgdat 0xe00008b000134000, size 0xc4b8, goal 0x8b000134000
	Alloc pgdat: cnode 2, pnode 14, pgdat 0xe00003b000144000, size 0xc4b8, goal 0x3b000144000
	Alloc pgdat: cnode 1, pnode  6, pgdat 0xe00001b000154000, size 0xc4b8, goal 0x1b000154000
	Alloc pgdat: cnode 0, pnode  0, pgdat 0xe000003000406880, size 0xc4b8, goal 0x3000164000

Looks ok, although the node 0 allocation is not necessarily ideal.


> 
> > 	PLAT_CHUNKSIZE - defines the size of the platform memory chunk.
> 
> Get rid of this.
> 
> > 	PLAT_CHUNKNUM(kaddr) - takes a kaddr & returns its chunk number
> 
> Get rid of this.
> 
> > 	PLAT_CLUMP_MEM_MAP_INDEX(kaddr) - Given a kaddr, find the index into the
> > 		clump_mem_map_base array of the page struct entry for the first page
> > 		of the clump.
> >
> > 	PLAT_CLUMP_OFFSET(kaddr) - find the byte offset of a kaddr within the clump that
> > 		contains it.
> >
> > 	PLAT_CLUMPSIZE - defines the size in bytes of the smallest clump supported on the platform.
> 
> This definition is misleading. The clumps are all the same
> size. Suppose you have banks (for me this name sounds better than
> clump because I can associate with it something I know from looking
> into a computer) of 1GB which you want to call clumps. The minimum
> size of a bank is 128MB, because this is the smallest DIMM you can
> insert. Setting PLAT_CLUMPSIZE to 128MB leads to too small page struct
> lists when setting up the mem_map (at least on DIG64).
> 
> PLAT_CLUMPSIZE - defines the size in bytes of the biggest clump
> supported on the platform. Make sure that (PLAT_CLUMPS_PER_NODE *
> PLAT_CLUMPSIZE is big enough for the maximum memory per node supported
> by the platform.
> 
> > 	PLAT_CLUMPS_PER_NODE - maximum number of clumps per node
> >
> > 	PLAT_MAXCLUMPS - maximum number of clumps on all node combined
> >
> > 	PLAT_MAX_COMPACT_NODES - maximum number of nodes in a system. (do not confuse this
> > 		with the maximum node number. Nodes can be sparsely numbered).
> 
> The name for this is MAX_NUMNODES or just NR_NODES. There was a patch
> from IBM changing everything to NR_NODES. That's also why I prefer
> calling compact nodes just "nodes".

OK. 

Consistency in naming is what is important. We should all agree on the terminology &
variable naming conventions. We also need to be clear that maximum node node is
NOT the same as NR_NODES-1.

If I understand your proposal,

	locical nodes are:
		values: 0..NR_NODES-1. 
		names are (pick one) node, nodenum, lnode, cnode, ...

	physical nodes:
		values: are 0 .. ???
		names: pnode, physnode, ....

Lets pick the names we want to use.


> 
> > 	PLAT_MAX_NODE_NUMBER - maximum physical node number plus 1
> 
> And this one should be MAX_PHYS_NODES or NR_PHYS_NODES.

These names are confusing. For example, the SGI SN2 system has 
	maximum number of nodes is 128
	maximum node number 2047

According to the current discontig patch for SN2:
	PLAT_MAX_NODE_NUMBER = 2048
	PLAT_MAX_COMPACT_NODES = 128

(Note: I dont object to changing names, but we need both abstractions).



>
> > 	PLAT_PXM_TO_PHYS_NODE_NUMBER(pxm) - convert a proximity_domain number (from ACPI)
> > 		into a physical node number
> 
> Get rid of this. Not needed outside ACPI SRAT/SLIT interpretation
> routines.

Again (sorry to keep bringing up SGI systems, but they pay me for this :-). 
The current SLIT definition requires PXM number to be 0 .. 254. SGI systems 
have physical node numbers > 255.


> 
> 
> Ideas? Comments?
> 
> Regards,
> Erich
> 
> 
> On Thursday 15 August 2002 20:05, Luck, Tony wrote:
> > Attached is the preamble to mmzone.h, which describes how
> > the ia64 discontig patch uses "CLUMPS" and "CHUNKS" to
> > split up memory into various sized pieces to make handling
> > easier for different parts of kernel code.  It doesn't
> > mention "GRANULES" which are yet another ia64ism for
> > keeping track of aggregates of memory which aren't directly
> > related to discontig memory support, but I thought that I'd
> > include them here, so we covered every kind of aggregate.
> >
> > I'm spawning this thread to try to come up with some good
> > documentation for all of the above concepts, to make the
> > discontig patch easier to understand, and thus make it more
> > likely to be accepted, and easier to maintain the code.
> >
> > The Atlas authors are not particularly attached to the
> > "CLUMP" and "CHUNK" names, and GRANULE was more or less
> > disowned at birth by its author (see the comment in pgtable.h),
> > so if you have better names, please suggest them!
> >
> > Definitions:
> >
> > GRANULE - contiguous, self-sized aligned block of memory all
> > of which exists, and has the same physical caching attributes.
> > The kernel maps memory at this granularity using a single
> > TLB entry (hence the alignment and cache-attribute requirements).
> >
> > CHUNK - A (usually) larger memory area, all of which exists.
> >
> > CLUMP - A (potentially) even larger memory area, providing only a
> > base address alignment on which CHUNKS of memory may be found.
> > E.g. the base address for a node (or memory bank within a node).
> > On systems that need to set the CHUNK size greater that the CLUMP
> > size only a few CHUNKS at the start of a CLUMP exist.
> >
> >
> > Rationale - Hardware designers have had various degrees of
> > "creativity" when coming up with memory maps for machines. Linux
> > needs an efficient way of getting from a physical address to the
> > page structure that contains all the information about the page.
> > In a machine with contguous memory, we simply allocate an array
> > of page structures, and use the physical page number as an index
> > into the array.  CLUMPS and CHUNKS provide for an efficient way
> > to get from a sparse physical page number to the page structure.
> > On many systems the CLUMP may be the same size as the CHUNK.
> >
> > -Tony
> 
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64
> 


-- 
Thanks

Jack Steiner    (651-683-5302)   (vnet 233-5302)      steiner@sgi.com


