From: Bob Picco <bob.picco@hp.com>
Date: Thu, 22 Sep 2005 16:14:18 +0000
Subject: [PATCH 0/4] V4 ia64 SPARSEMEM
Message-Id: <20050922161418.GW16066@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony,

This patchset differs very little from V3. It requires SPARSEMEM EXTREME
patches which are in 2.6.14-rcX.

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
	

thanks,

bob
