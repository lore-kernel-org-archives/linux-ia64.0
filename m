From: Bob Picco <bob.picco@hp.com>
Date: Tue, 04 Oct 2005 19:13:30 +0000
Subject: [PATCH 0/5] V5 ia64 SPARSEMEM
Message-Id: <20051004191330.GP25483@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


ChangeLog V2:
	Jesse's review input has been applied to patches 3 and 4.
	These were all cosmetic changes.
ChangeLog V3:
	This patchset has changes for building ia64 with 
	ARCH_SPARSEMEM_EXTREME config options.  The configuration options
	SECTION_BITS and PHYSICAL_MEMORY_BITS have been removed.  I've
	chosen SECTION_SIZE_BITS to be 30. I'm sure this will be debated
	but seems adequate for the near term. 

	This patchset depends on SPARSEMEM EXTREME patch submitted to -mm.
	The -mm patch makes mem_section a one dimensional array of pointers 
	to mem_sections. The two level layout reduces the memory requirements
	of SPARSEMEM for very sparse memory but at the expense of an 
	additional shift and load instruction.

	The SPARSEMEM function memory_present, which marks sections with
	memory, is called from paging_init instead of find_memory. This is
	done because the bootmem allocator in used by SPARSEMEM to allocate
	the SPARSEMEM section arrays. This is the only code change within
	this patchset.
ChanageLog V4:
	SPARSEMEM EXTREME is now the default SPARSEMEM configuration. Thus
	the arch doesn't need to request EXTREME.  A couple of preprocessor
	#elif were cleaned up. There was a merge conflict in discontig.c's
	paging_init function and some minor code rearranging was required.

	Thanks to Kame and Yasunori for review and corrections.

	Memory models SPARSEMEM+EXTREME, DISCONTIG+VIRTUAL_MEM_MAP, 
	FLATMEM and FLATMEM+VIRTUAL_MEM_MAP were boot tested on rx2600
	by me; against -rcX.  Yasunori did the same configuration testing 
	on his Tiger4 box with Node emulation for NUMA; against -rc1.
ChangeLog V5:
	Eliminated paddr_to_nid change which was inadvertent and should
	be cleaned up in a different patch.

	Eliminated from IA64_GENERIC config option the selection of
	VIRTUAL_MEM_MAP and DISCONTIGMEM.

	Introduced comment in arch/ia64/Kconfig for VIRTUAL_MEM_MAP that
	identifies how it is functionaly equivalent to FLAT_NODE_MEM_MAP.

	Adopted Dave Hansen's suggesting of defining arch_sparse_init.

	Added a gensparse_defconfig which is a config generated file for
	SPARSEMEM and GENERIC kernel configuration (defconfig). 
	

thanks,

bob
