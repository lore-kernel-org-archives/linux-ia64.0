From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 26 May 2005 00:32:54 +0000
Subject: RE: [patch 0/4] ia64 SPARSEMEM
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F038D0531@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050523175031.GC2783@localhost.localdomain>
In-Reply-To: <20050523175031.GC2783@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


>+#ifdef CONFIG_SPARSEMEM
>+ /*
>+ * SECTION_SIZE_BITS            2^N: how big each section will be
>+ * MAX_PHYSADDR_BITS            2^N: how much physical address space we have
>+ * MAX_PHYSMEM_BITS             2^N: how much memory we can have in that space
>+ */

MAX_PHYSADDR_BITS is apparently never used ... what's the distinction
between it and MAX_PHYSMEM_BITS?  From the comments, I'd guess that you
really meant to use MAX_PHYSADDR_BITS in this:

#define SECTIONS_SHIFT          (MAX_PHYSMEM_BITS - SECTION_SIZE_BITS)

Pursuing Jack Steiner's line of questioning on how this works for
the SGI Altix ... it would appear that he will need to use 50 for
MAX_PHYSMEM_BITS, and probably 32 for SECTION_SIZE_BITS (but maybe
a smaller number ... his banks of memory all start on 4G boundaries,
but could be as small as 1G ... can you have a chunk with an empty
tail?).  So SGI will end up with 2^(50-32) = 256K entries in mem_section[]
(or perhaps 4x that if sections must be fully populated).  All allocated
on the boot node ... and perhaps consuming a significant portion of
the kernel memory mapped by dtr[0].


It will be interesting to see performance numbers on how this compares
with against VIRTUAL_MEM_MAP ... trading cache misses vs. TLB misses.

-Tony
