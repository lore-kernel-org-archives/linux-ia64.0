From: Erich Focht <efocht@ess.nec.de>
Date: Fri, 16 Aug 2002 11:44:33 +0000
Subject: [Linux-ia64] Re: [Discontig-devel] CLUMPS, CHUNKS and GRANULES
Message-Id: <marc-linux-ia64-105590701905942@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Tony,

hmmm, no comments to your post yesterday... maybe we find more people
interested on this on lia64 ML?

Actually I wanted to make some suggestions regarding the names, but
after looking at some code I'd rather like to suggest to simplify
things and get rid of some concepts. In my opinion we need only
the following concepts inside DISCONTIGMEM:
 - node IDs (AKA compact node IDs or logical nodes).
 - physical node IDs
 - clumps (I'd prefer the name memory BANKS here, as a clump suggests
 something to be contiguous, without holes (German: Klumpen)).

In the initialisation phase we need:
 - memory blocks (AKA chunks?) (contiguous pieces of memory on one
 node, provided by ACPI, only used for setup. No size or alignment
 expected. Needed later for paddr_to_nid() but that's all.)
 - proximity domains (only ACPI NUMA setup, invisible to the rest of
 the DISCONTIG code).

This reduces the number of platform specific macros considerably and
should improve the readability of the code.

Therefore a node would have several memory banks which are not
necessarily adjacent in the physical memory space. There can be gaps
or banks from other nodes interleaved. In the mem_map array there is
space reserved for page struct entries of ALL pages of one bank,
existent or not. Memory holes between banks don't build holes in the
mem_map array.

Appended are some comments to the mem.txt attachment, somewhat
lengthy, but explaining more in detail what I summarized above.

---------- comments to mem.txt (in include/asm-ia64/mmzone.h) ---------
> - Nodes are numbered several ways:
> 
> 	compact node numbers - compact node numbers are a dense numbering of 
> 		all the nodes in the system. An N node system will have compact
> 		nodes numbered 0 .. N-1. There is no significance to the node
> 		numbers. The compact node number assigned to a specific physical
> 		node may vary from boot to boot. The boot node is not necessarily
> 		node 0.

I'd prefer to call them "logical node numbers" or just "node numbers",
similar to CPUs. We don't have compact CPU IDs.

> 	proximity domain numbers - these numbers are assigned by ACPI. 
> 		Each platform must provide a platform specific function
> 		for mapping proximity node numbers to physical node numbers.

The proximity domain numbers are unnecessary. They are just other
"physical" node numbers which are only interesting in the setup phase
when the ACPI _PXM numbers help to build the physical to logical
(compact) mapping. Only SGI uses the pxm numbers later as:
#define PLAT_BOOTMEM_ALLOC_GOAL(cnode,kaddr) \
  __pa(SN2_KADDR(PLAT_PXM_TO_PHYS_NODE_NUMBER(nid_to_pxm_map[cnode]) ...
but it is clear that what they actually want to do is translate the
compact node id to a physical node id. They just misuse the PXM
translation tables for this. All reference to proximity domain numbers
can be eliminated after the ACPI setup phase. Maybe we need some map
when hotplugging and adjusting a physical->logical translation table,
but not in DISCONTIG.

> - Memory is conceptually divided into chunks. A chunk is either
>   completely present, or else the kernel assumes it is completely
>   absent. Each node consists of a number of possibly discontiguous chunks.

When reading the code I get the impression that the concept of a CHUNK
isn't really needed in the code. The definitions are misleading
because they suggest that CHUNKS are equally sized (there is a
CHUNKSHIFT) and we should expect ACPI to give us a bunch of
chunks. But all we really need these for is to check whether a
physical address is valid or to find out to which node a physical
address belongs to. When building the mem_map and the page struct
entries we need to know whether a page is inside a valid memory block
or not, no matter how this memory block looks like, how big it is
of whether it fits into one clump or not. On Azusa a chunk returned by
ACPI can span the whole node memory, thus the rule: "a clump is made
of chunks" is not valid.

I tried to find the places where the CHUNKs are used:
- PLAT_CHUNKNUM : used by SGI for kern_addr_valid in the form
VALIDCHUNK(PLAT_CHUNKNUM(_kav))
but VALIDCHUNK allways returns 1! So it is not needed!
- PLAT_CHUNKSIZE : only used in CHUNKROUNDUP in discontig.c. I think
we can recode this to round up to a GRANULE boundary, that's what we
really want, I guess.
- *_CHUNKSHIFT is only used for PLAT_CHUNKSIZE and PLAT_CHUNKNUM.

On NEC Azusa ACPI returns each available contiguous memory block as
one SRAT table entry. The size and the alignment can vary, there are
no fixed size chunks. For building up the clumps, we don't need to
know anything about these chunks! If a clump has holes, the setup
routine will take care of them. All we need is the list of memory
blocks delivered by ACPI and their assignment to nodes. The maximum
number of memory blocks expected is currently set to PLAT_MAXCLUMPS. I
think this is wrong, as a clump can contain multiple memory blocks.

I would like to eliminate the CHUNK concept and the need for setting a
lot of CHUNK related macros for each platform. All we really need is
MAX_NR_MEMBLKS and only the setup routines will deal with these
blocks. Call the ACPI memory blocks CHUNKS again, if you want, but
they are only needed in the setup phase related to ACPI and shouldn't
need an own philosophy within DISCONTIG.


> - A contiguous group of memory chunks that reside on the same node
>   are referred to as a clump. Note that a clump may be partially present.
>   (Note, on some hardware implementations, a clump is the same as a memory
>   bank or a DIMM).
> 
> - a node consists of multiple clumps of memory. From a NUMA perspective,
>   accesses to all clumps on the node have the same latency. Except for zone issues,
>   the clumps are treated as equivalent for allocation/performance purposes.
> 
> - each node has a single contiguous mem_map array. The array contains page struct
>   entries for every page on the node. There are no "holes" in the mem_map array.
>   The node data area (see below) has pointers to the start of the mem_map entries
>   for each clump on the node.

The mem_map array is the same on each node, copied from the boot_node
to all other nodes. It contains page_struct entries for ALL pages on
ALL nodes (if I interpret discontig_paging_init() correctly). The
first two sentences need to be reformulated.


> - each platform is responsible for defining the following constants & functions:
> 
> 	PLAT_BOOTMEM_ALLOC_GOAL(cnode,kaddr) - Calculate a "goal" value to be passed 
> 		to __alloc_bootmem_node for allocating structures on nodes so that 
> 		they dont alias to the same line in the cache as the previous 
> 		allocated structure. You can return 0 if your platform doesnt have
> 		this problem.
> 			(Note: need better solution but works for now ZZZ).

Either I misunderstood something or the definition in
include/asm-ia64/sn/sn2/mmzone_sn2.h doesn't really unalias the
cachelines. This would be nice to have!

> 	PLAT_CHUNKSIZE - defines the size of the platform memory chunk. 

Get rid of this.

> 	PLAT_CHUNKNUM(kaddr) - takes a kaddr & returns its chunk number

Get rid of this.

> 	PLAT_CLUMP_MEM_MAP_INDEX(kaddr) - Given a kaddr, find the index into the 
> 		clump_mem_map_base array of the page struct entry for the first page 
> 		of the clump.
> 
> 	PLAT_CLUMP_OFFSET(kaddr) - find the byte offset of a kaddr within the clump that
> 		contains it.
> 
> 	PLAT_CLUMPSIZE - defines the size in bytes of the smallest clump supported on the platform.

This definition is misleading. The clumps are all the same
size. Suppose you have banks (for me this name sounds better than
clump because I can associate with it something I know from looking
into a computer) of 1GB which you want to call clumps. The minimum
size of a bank is 128MB, because this is the smallest DIMM you can
insert. Setting PLAT_CLUMPSIZE to 128MB leads to too small page struct
lists when setting up the mem_map (at least on DIG64).

PLAT_CLUMPSIZE - defines the size in bytes of the biggest clump
supported on the platform. Make sure that (PLAT_CLUMPS_PER_NODE *
PLAT_CLUMPSIZE is big enough for the maximum memory per node supported
by the platform.

> 	PLAT_CLUMPS_PER_NODE - maximum number of clumps per node
> 
> 	PLAT_MAXCLUMPS - maximum number of clumps on all node combined
> 
> 	PLAT_MAX_COMPACT_NODES - maximum number of nodes in a system. (do not confuse this
> 		with the maximum node number. Nodes can be sparsely numbered).

The name for this is MAX_NUMNODES or just NR_NODES. There was a patch
from IBM changing everything to NR_NODES. That's also why I prefer
calling compact nodes just "nodes".

> 	PLAT_MAX_NODE_NUMBER - maximum physical node number plus 1

And this one should be MAX_PHYS_NODES or NR_PHYS_NODES.
 
> 	PLAT_PXM_TO_PHYS_NODE_NUMBER(pxm) - convert a proximity_domain number (from ACPI)
> 		into a physical node number

Get rid of this. Not needed outside ACPI SRAT/SLIT interpretation
routines.


Ideas? Comments?

Regards,
Erich


On Thursday 15 August 2002 20:05, Luck, Tony wrote:
> Attached is the preamble to mmzone.h, which describes how
> the ia64 discontig patch uses "CLUMPS" and "CHUNKS" to
> split up memory into various sized pieces to make handling
> easier for different parts of kernel code.  It doesn't
> mention "GRANULES" which are yet another ia64ism for
> keeping track of aggregates of memory which aren't directly
> related to discontig memory support, but I thought that I'd
> include them here, so we covered every kind of aggregate.
>
> I'm spawning this thread to try to come up with some good
> documentation for all of the above concepts, to make the
> discontig patch easier to understand, and thus make it more
> likely to be accepted, and easier to maintain the code.
>
> The Atlas authors are not particularly attached to the
> "CLUMP" and "CHUNK" names, and GRANULE was more or less
> disowned at birth by its author (see the comment in pgtable.h),
> so if you have better names, please suggest them!
>
> Definitions:
>
> GRANULE - contiguous, self-sized aligned block of memory all
> of which exists, and has the same physical caching attributes.
> The kernel maps memory at this granularity using a single
> TLB entry (hence the alignment and cache-attribute requirements).
>
> CHUNK - A (usually) larger memory area, all of which exists.
>
> CLUMP - A (potentially) even larger memory area, providing only a
> base address alignment on which CHUNKS of memory may be found.
> E.g. the base address for a node (or memory bank within a node).
> On systems that need to set the CHUNK size greater that the CLUMP
> size only a few CHUNKS at the start of a CLUMP exist.
>
>
> Rationale - Hardware designers have had various degrees of
> "creativity" when coming up with memory maps for machines. Linux
> needs an efficient way of getting from a physical address to the
> page structure that contains all the information about the page.
> In a machine with contguous memory, we simply allocate an array
> of page structures, and use the physical page number as an index
> into the array.  CLUMPS and CHUNKS provide for an efficient way
> to get from a sparse physical page number to the page structure.
> On many systems the CLUMP may be the same size as the CHUNK.
>
> -Tony


