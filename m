From: Jack Steiner <steiner@sgi.com>
Date: Thu, 26 May 2005 21:44:53 +0000
Subject: Re: [patch 0/4] ia64 SPARSEMEM
Message-Id: <20050526214453.GA20816@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050523175031.GC2783@localhost.localdomain>
In-Reply-To: <20050523175031.GC2783@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, May 26, 2005 at 04:54:08PM -0400, Bob Picco wrote:
> luck wrote:	[Wed May 25 2005, 08:32:54PM EDT]
> > 
> > >+#ifdef CONFIG_SPARSEMEM
> > >+ /*
> > >+ * SECTION_SIZE_BITS            2^N: how big each section will be
> > >+ * MAX_PHYSADDR_BITS            2^N: how much physical address space we have
> > >+ * MAX_PHYSMEM_BITS             2^N: how much memory we can have in that space
> > >+ */
> > 
> > MAX_PHYSADDR_BITS is apparently never used ... what's the distinction
> Ah MAX_PHYSADDR_BITS appears not used by all arches ported to SPARSEMEM.  I 
> wonder if it's a remnant of NONLINEAR.  Dave, do you recall?
> > between it and MAX_PHYSMEM_BITS?  From the comments, I'd guess that you
> > really meant to use MAX_PHYSADDR_BITS in this:
> > 
> > #define SECTIONS_SHIFT          (MAX_PHYSMEM_BITS - SECTION_SIZE_BITS)
> > 
> > Pursuing Jack Steiner's line of questioning on how this works for
> > the SGI Altix ... it would appear that he will need to use 50 for
> > MAX_PHYSMEM_BITS, and probably 32 for SECTION_SIZE_BITS (but maybe
> I went back and reviewed Jack's email.  I must be blind but don't see why
> he would need more than 44 bits of physical memory bits.  I agree that
> should you need 50 bits for physical address bits then you should use
> 32 bits for SECTION_SIZE_BITS.

Ahhhh. You folks are a step ahead of me. I was just in the process of trying
to figure out the various options.

We definitely need 50 bit physical addresses (49 on todays hardware but more
coming).

A physical address on Altix looks like:

	+-------------+--+--------------------+
	|  NODE #     |AS|       NodeOffset   |
	+-------------+--+--------------------+
	 4           3 33 3                  0
	 9           8 76 5                  0
	
		Bits [48:38] contain a node number in the range 0..2047
			(another bit will be added soon)
		Bits [37:36] always contain a "3" for WB RAM.
		Bits [35:0]  contain the node offset

Node numbers are not dense & do not start at 0. Large systems can
be partitioned into smaller chunks. Node numbers within a partition
are typically not interleaved with the node numbers of other partitions, but
it is possible to have a partition with almost any subset of node numbers.
For example, a partition could consist of nodes 1536, 1538, & 1552.


> > a smaller number ... his banks of memory all start on 4G boundaries,

All banks (currently) start on 16GB boundaries. I don't think it
matters, but directory memory occupies the last 1/32 of each DIMM. This
means that memory blocks are slightly smaller than you might expect. The
bios marks the directory memory as "unavailable".


> > but could be as small as 1G ... can you have a chunk with an empty
> > tail?).  So SGI will end up with 2^(50-32) = 256K entries in mem_section[]
> > (or perhaps 4x that if sections must be fully populated).  All allocated
> > on the boot node ... and perhaps consuming a significant portion of
> > the kernel memory mapped by dtr[0].
> Well worse case it would consume 2^(1(50-32)+3) (2 Mb).  I would hope that 
> it's not configured for 28 SECTION_SIZE_BITS and 50 physical. This would
> be excessive 2^((50-28)+3 = 32Mb and not advised.
> > 
> > 
> > It will be interesting to see performance numbers on how this compares
> > with against VIRTUAL_MEM_MAP ... trading cache misses vs. TLB misses.

I just finished buildind & booting a SPARSEMEM kernel. No problems but I have 
not run any performance tests yet. 

I had MAX_PHYSMEM_BITS set to the wrong value. I was on a small
system so it did not cause problems. I'll fix the size before running 
performance tests.

I noticed that available memory seems slightly smaller but have not tracked down the
cause.
 BASELINE
 Nid  MemTotal   MemFree   MemUsed      (in kB)
   0   3820304   3510272    310032
   1   3882992   3800224     82768
   2   3883008   3794352     88656
   3   3882992   3801552     81440
   4   3883008   3802272     80736

 SPARSE
 Nid  MemTotal   MemFree   MemUsed      (in kB)
   0   3820256   3320784    499472
   1   3882992   3741328    141664
   2   3883008   3749536    133472
   3   3882992   3751392    131600
   4   3883008   3758368    124640
	


> > 
> > -Tony
> bob
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


