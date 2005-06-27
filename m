From: Bob Picco <bob.picco@hp.com>
Date: Mon, 27 Jun 2005 21:59:21 +0000
Subject: Re: [PATCH 0/4] V3 ia64 SPARSEMEM
Message-Id: <20050627215921.GC25758@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050616132819.GP23911@localhost.localdomain>
In-Reply-To: <20050616132819.GP23911@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Greg Edwards wrote:	[Mon Jun 27 2005, 04:03:58PM EDT]
> On Thu, Jun 16, 2005 at 09:28:19AM -0400, Bob Picco wrote:
> | Tony,
> | 
> | ChangeLog V2:
> | 	Jesse's review input has been applied to patches 3 and 4.
> | 	These were all cosmetic changes.
> | ChangeLog V3:
> | 	This patchset has changes for building ia64 with SPARSEMEM +
> | 	ARCH_SPARSEMEM_EXTREME config options.  The configuration options
> | 	SECTION_BITS and PHYSICAL_MEMORY_BITS have been removed and are
> | 	like other arches (not configurable).  
> | 
> | 	This patchset depends on SPARSEMEM EXTREME patches submitted to -mm.
> | 	The -mm patch sparsemem-extreme.patch and all those which it depends
> | 	on are required. EXTREME has introduced a two dimensional array
> | 	to SPARSEMEM. The two level layout should reduce memory requirements
> | 	for extremely sparse memory at the expense of an additional load
> | 	and shift when fetching the section map for a page frame.
> | 
> | 	The only C code change since V2 is in patch 4.  SPARSEMEM's 
> | 	routine memory_present, for identifying a section with memory, is
> | 	called in paging_init instead of find_memory. This is required
> | 	because EXTREME uses the bootmem allocator for the root level
> | 	allocations in the new two level layout scheme. 
> | 	
> | 	I have gathered OSDL aim7 data on an rx2600 4Gb of memory and two
> | 	CPUs.  The data is for SPARSEMEM+EXTREME and DISCONTIG+VIRTUAL_MEM_MAP.
> | 	This obviously isn't conclusive data for the adoption of ia64
> | 	SPARSEMEM but does demonstrate no degradation on a small server.  I'll 
> | 	need Jack's help to gather more supporting performance data.
> | 
> | This is a series of patches which enable SPARSEMEM for ia64.  It's against
> | rc4-mm2.  The patches have been tested against memory configurations FLATMEM,
> | DISCONTIG and SPARSEMEM+EXTREME.  This includes NUMA simulated hardware, rx2600
> | and HPSIM.  An early version of ia64 with SPARSEMEM was tested by Jesse. It
> | would be optimal to have another test pass on SGI NUMA hardware.
> 
> Bob,
> 
> I did a few aim7 runs of SPARSEMEM+EXTREME vs DISCONTIG+VIRTUAL_MEM_MAP
> with 2.6.12-mm1 on a 128p Altix.  There wasn't a noticeable difference
> between the two, so I think we're good to go.
> 
> Greg
Greg,

Thanks!

bob
