From: Erich Focht <efocht@ess.nec.de>
Date: Mon, 19 Aug 2002 16:33:40 +0000
Subject: Re: [Linux-ia64] Re: [Discontig-devel] CLUMPS, CHUNKS and GRANULES
Message-Id: <marc-linux-ia64-105590701905954@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905942@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905942@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Jack,

thanks very much for the detailed comments. There was (at least) one
mistake in my previous mail, sorry if that generated confusion. As far
as I understand, you agree with getting rid of CHUNKS and replacing
the one macro using them with GRANULE. Also I hope we can limit the
usage of PXM to be only within arch/ia64/acpi.c.

On Friday 16 August 2002 23:53, Jack Steiner wrote:
> > things and get rid of some concepts. In my opinion we need only
> > the following concepts inside DISCONTIGMEM:
> >  - node IDs (AKA compact node IDs or logical nodes).
> >  - physical node IDs
> >  - clumps (I'd prefer the name memory BANKS here, as a clump suggests
> >  something to be contiguous, without holes (German: Klumpen)).
> >
> > In the initialisation phase we need:
> >  - memory blocks (AKA chunks?) (contiguous pieces of memory on one
> >  node, provided by ACPI, only used for setup. No size or alignment
> >  expected. Needed later for paddr_to_nid() but that's all.)
> >  - proximity domains (only ACPI NUMA setup, invisible to the rest of
> >  the DISCONTIG code).
...

> > Therefore a node would have several memory banks which are not
> > necessarily adjacent in the physical memory space. There can be gaps
> > or banks from other nodes interleaved. In the mem_map array there is
> > space reserved for page struct entries of ALL pages of one bank,
> > existent or not. Memory holes between banks don't build holes in the
> > mem_map array.
>
> If the mem_map has entries for pages that dont exist, how do you handle
> code that scans the mem_map array. How does code recognize  & skip pages
> associated with missing memory?? For examples, see show_mem()
> & get_discontig_info(). (Maybe I misunderstood your proposal here).

Sorry, I didn't mean to change anything related to mem_map. I just
described the current state wrongly. From the following piece of code
in discontig_paging_init() I thought that for each clump we will have
PLAT_CLUMPSIZE/PAGE_SIZE struct page entries in the mem_map array. I
missed the readjustment of npages below...


	mycnodeid = boot_get_local_cnodeid();
	for (cnodeid = 0; cnodeid < numnodes; cnodeid++) {
...
		page = NODE_DATA(cnodeid)->node_mem_map;
		bdp = BOOT_NODE_DATA(cnodeid)->bdata;
		while (bdp->node_low_pfn) {
			kaddr = (unsigned long)__va(bdp->node_boot_start);
			ekaddr = (unsigned long)__va(bdp->node_low_pfn << PAGE_SHIFT);
			while (kaddr < ekaddr) {
				node_data[mycnodeid]->clump_mem_map_base[PLAT_CLUMP_MEM_MAP_INDEX(kaddr)] = page;
				npages = PLAT_CLUMPSIZE/PAGE_SIZE;
				if (kaddr + (npages<<PAGE_SHIFT) > ekaddr)
					npages = (ekaddr - kaddr) >> PAGE_SHIFT;
				for (i = 0; i < npages; i++, page++, kaddr += PAGE_SIZE)
					page->virtual = (void*)kaddr;
			}
			bdp++;
		}
...
	}

Which means: for each memory block we get from the ACPI SRAT table we
will have struct pages reserved. Not more. Hotpluggable (non-existent?)
memory should appear here, too, I guess. But that should not harm.



> On the SGI platform, "physical node number" has a very precise definition.
> This is not true on all architectures. On SGI, the physical number is bits
> [48:38] of the physical address. In addition, a system can run with a
> sparse set of physical node numbers. For example, a 3 node system could
> have physical node 512, 800 & 2012.

It's somewhat similar on the NEC Azusa/Asama, where one can get the
physical node number from the SAPIC_ID of the CPUs.



> > > 	proximity domain numbers - these numbers are assigned by ACPI.
> > > 	Each platform must provide a platform specific function
> > > 	for mapping proximity node numbers to physical node numbers.
> >
> > The proximity domain numbers are unnecessary. They are just other
>
> Unfortunately, for SGI hardware,  proximity domain numbers cant be the same
> as a physical node number. ACPI limits proximity domain numbers to 0..254.
> On SGI, physical node numbers are 0..2047. Fortunately, we found a way to
> compress the physical node number into a proximity domain number. In the
> future, though, our current "trick" may no longer work. If we can get the
> the proximity domain numbers changed to 0..65K, then I
> agree that it could be the same as the physical node number.
> Is there any chance we can get this changed???
>
> > (compact) mapping. Only SGI uses the pxm numbers later as:
> > #define PLAT_BOOTMEM_ALLOC_GOAL(cnode,kaddr) \
> >   __pa(SN2_KADDR(PLAT_PXM_TO_PHYS_NODE_NUMBER(nid_to_pxm_map[cnode]) ...
> > but it is clear that what they actually want to do is translate the
> > compact node id to a physical node id. They just misuse the PXM
> > translation tables for this. All reference to proximity domain numbers
> > can be eliminated after the ACPI setup phase. Maybe we need some map
> > when hotplugging and adjusting a physical->logical translation table,
> > but not in DISCONTIG.

The only place where the PXM is used (after ACPI based initialisation) is
the macro above. And there you do
cnode ---> PXM number ---> physical node id
I suggest something trivial: use a physnode_map[] table initialised
by the ACPI routines which detected the nodes. So just do
cnode ---> physical node id
The physnode_map table will have only numnodes entries and we will never
see PXM outside the ACPI init routines.



> > > - Memory is conceptually divided into chunks. A chunk is either
> > >   completely present, or else the kernel assumes it is completely
> > >   absent. Each node consists of a number of possibly discontiguous
> > > chunks.
> >
> > When reading the code I get the impression that the concept of a CHUNK
> > isn't really needed in the code. The definitions are misleading
> > because they suggest that CHUNKS are equally sized (there is a
> > CHUNKSHIFT) and we should expect ACPI to give us a bunch of
> > chunks. But all we really need these for is to check whether a
> > physical address is valid or to find out to which node a physical
> > address belongs to. When building the mem_map and the page struct
> > entries we need to know whether a page is inside a valid memory block
> > or not, no matter how this memory block looks like, how big it is
> > of whether it fits into one clump or not. On Azusa a chunk returned by
> > ACPI can span the whole node memory, thus the rule: "a clump is made
> > of chunks" is not valid.
>
> Agree that CHUNK is barely used. I think the way GRANULE is being used, it
> may replace the need for CHUNKs.

Fine! Then we can get rid of CHUNKS and PXMs in the mmzone*.h files?

> However, since IA64 doesnt current implement a kern_addr_valid() function,
> CHUNK is not currently used.
>
> Do you know if kern_addr_valid() for IA64 is planned in the future???
No idea. Do you think we need such a thing? We lived without it for quite
a while...

> > > - each node has a single contiguous mem_map array. The array contains
> > > page struct entries for every page on the node. There are no "holes" in
> > > the mem_map array. The node data area (see below) has pointers to the
> > > start of the mem_map entries for each clump on the node.
> >
> > The mem_map array is the same on each node, copied from the boot_node
> > to all other nodes. It contains page_struct entries for ALL pages on
> > ALL nodes (if I interpret discontig_paging_init() correctly). The
> > first two sentences need to be reformulated.
>
> I think the first two sentences are correct, but the last one is
> misleading. Is this better:
>
> 	- each node has a single contiguous page_struct array. This array contains
> page struct entries for every page that is actually present on the node.
> There are no "holes" in the page_struct array for non-existent memory. Note
> that adjacent entries in the array are NOT necessarily for contiguous
> physical pages if there are multiple non-contiguous clumps on the node.
>
> 	  The node data area (see below) has pointers to the start of the
> page_struct entries for each clump on the node.

Agreed. I misunderstood discontig_paging_init.


> > > 	PLAT_BOOTMEM_ALLOC_GOAL(cnode,kaddr) - Calculate a "goal" value to be
> > > passed to __alloc_bootmem_node for allocating structures on nodes so
> > > that they dont alias to the same line in the cache as the previous
> > > allocated structure. You can return 0 if your platform doesnt have this
> > > problem.
...
> I'm not real happy with this solution, but I think it works. To verify it,
> I added a printk right after the point in discontig.c that does the
> allocate:
...
>
> Looks ok, although the node 0 allocation is not necessarily ideal.

OK, looks reasonable. Will think of something similar for DIG64
platforms.



> Consistency in naming is what is important. We should all agree on the
> terminology & variable naming conventions. We also need to be clear that
> maximum node node is NOT the same as NR_NODES-1.
>
> If I understand your proposal,
>
> 	locical nodes are:
> 		values: 0..NR_NODES-1.
> 		names are (pick one) node, nodenum, lnode, cnode, ...
>
> 	physical nodes:
> 		values: are 0 .. ???
> 		names: pnode, physnode, ....
>
> Lets pick the names we want to use.

OK. I like node & physnode (the later is pretty rare, I guess).

> > > 	PLAT_MAX_NODE_NUMBER - maximum physical node number plus 1
> >
> > And this one should be MAX_PHYS_NODES or NR_PHYS_NODES.
>
> These names are confusing. For example, the SGI SN2 system has
> 	maximum number of nodes is 128
> 	maximum node number 2047
>
> According to the current discontig patch for SN2:
> 	PLAT_MAX_NODE_NUMBER = 2048
> 	PLAT_MAX_COMPACT_NODES = 128
>
> (Note: I dont object to changing names, but we need both abstractions).

I understand your objection. For the first macro we need to remind
readers that it is the highest possible physical node ID in the system.
PLAT_MAX_PHYSNODE_NUMBER sounds too long, so maybe:
    MAX_PHYSNODE_ID = 2048   ?
Anyway, this one is only used for the physical_node_map[] which maps
a physnode to a cnode ID, so maybe we shouldn't worry too much about the
name.
Anyway, instead of PLAT_MAX_COMPACT_NODES I'd prefer
     NR_NODES     = 128
or
     MAX_NUMNODES = 128, 
whatever is used on other architectures.

Best regards,
Erich



