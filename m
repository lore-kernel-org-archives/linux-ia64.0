From: Bob Picco <bob.picco@hp.com>
Date: Thu, 26 May 2005 20:54:08 +0000
Subject: Re: [patch 0/4] ia64 SPARSEMEM
Message-Id: <20050526205408.GJ23448@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050523175031.GC2783@localhost.localdomain>
In-Reply-To: <20050523175031.GC2783@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

luck wrote:	[Wed May 25 2005, 08:32:54PM EDT]
> 
> >+#ifdef CONFIG_SPARSEMEM
> >+ /*
> >+ * SECTION_SIZE_BITS            2^N: how big each section will be
> >+ * MAX_PHYSADDR_BITS            2^N: how much physical address space we have
> >+ * MAX_PHYSMEM_BITS             2^N: how much memory we can have in that space
> >+ */
> 
> MAX_PHYSADDR_BITS is apparently never used ... what's the distinction
Ah MAX_PHYSADDR_BITS appears not used by all arches ported to SPARSEMEM.  I 
wonder if it's a remnant of NONLINEAR.  Dave, do you recall?
> between it and MAX_PHYSMEM_BITS?  From the comments, I'd guess that you
> really meant to use MAX_PHYSADDR_BITS in this:
> 
> #define SECTIONS_SHIFT          (MAX_PHYSMEM_BITS - SECTION_SIZE_BITS)
> 
> Pursuing Jack Steiner's line of questioning on how this works for
> the SGI Altix ... it would appear that he will need to use 50 for
> MAX_PHYSMEM_BITS, and probably 32 for SECTION_SIZE_BITS (but maybe
I went back and reviewed Jack's email.  I must be blind but don't see why
he would need more than 44 bits of physical memory bits.  I agree that
should you need 50 bits for physical address bits then you should use
32 bits for SECTION_SIZE_BITS.
> a smaller number ... his banks of memory all start on 4G boundaries,
> but could be as small as 1G ... can you have a chunk with an empty
> tail?).  So SGI will end up with 2^(50-32) = 256K entries in mem_section[]
> (or perhaps 4x that if sections must be fully populated).  All allocated
> on the boot node ... and perhaps consuming a significant portion of
> the kernel memory mapped by dtr[0].
Well worse case it would consume 2^(1(50-32)+3) (2 Mb).  I would hope that 
it's not configured for 28 SECTION_SIZE_BITS and 50 physical. This would
be excessive 2^((50-28)+3 = 32Mb and not advised.
> 
> 
> It will be interesting to see performance numbers on how this compares
> with against VIRTUAL_MEM_MAP ... trading cache misses vs. TLB misses.
> 
> -Tony
bob
