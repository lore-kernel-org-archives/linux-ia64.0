From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Thu, 23 Aug 2018 00:01:45 +0000
Subject: Re: [PATCH 02/20] kernel/dma/direct: refine dma_direct_alloc zone selection
Message-Id: <d9866d44704073ecc418f62da0ba7587ce7c9af8.camel@kernel.crashing.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180730163824.10064-1-hch@lst.de>
 <20180730163824.10064-3-hch@lst.de>
 <7177553cdb5cd1b968f653a52d7e88bd71aae4d8.camel@kernel.crashing.org>
 <20180822065856.GC19284@lst.de>
In-Reply-To: <20180822065856.GC19284@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Robin Murphy <robin.murphy@arm.com>, linuxppc-dev@lists.ozlabs.org, iommu@lists.linux-foundation.org, linux-ia64@vger.kernel.org

On Wed, 2018-08-22 at 08:58 +0200, Christoph Hellwig wrote:
> On Thu, Aug 09, 2018 at 09:54:33AM +1000, Benjamin Herrenschmidt wrote:
> > On Mon, 2018-07-30 at 18:38 +0200, Christoph Hellwig wrote:
> > > We need to take the DMA offset and encryption bit into account when selecting
> > > a zone.  Add a helper that takes those into account and use it.
> > 
> > That whole "encryption" stuff seems to be completely specific to the
> > way x86 does memory encryption, or am I mistaken ? It's not clear to me
> > what that does in practice and how it relates to DMA mappings.
> 
> Not even all of x86, but AMD in particular, Intel does it yet another
> way.  But it still is easier to take this into the core with a few
> overrides than duplicating all the code.
> 
> > I'm also not sure about that whole business with ZONE_DMA and
> > ARCH_ZONE_DMA_BITS...
> 
> ZONE_DMA usually (but not always) maps to 24-bits of address space,
> if it doesn't (I mostly through about s390 with it's odd 31-bits)
> the architecture can override it if it cares).
> 
> > On ppc64, unless you enable swiotlb (which we only do currently on
> > some embedded platforms), you have all of memory in ZONE_DMA.
> > 
> > [    0.000000] Zone ranges:
> > [    0.000000]   DMA      [mem 0x0000000000000000-0x0000001fffffffff]
> > [    0.000000]   DMA32    empty
> > [    0.000000]   Normal   empty
> > [    0.000000]   Device   empty
> 
> This is really weird.  Why would you wire up ZONE_DMA like this?

We always did :-) It predates my involvement and I think it predates
even Pauls. It's quite silly actually since the first powerpc machines
actually had ISA devices in them, but that's how it's been for ever. I
suppose we could change it but that would mean digging out some old
stuff to test.

> The general scheme that architectures should implement is:
> 
> ZONE_DMA:	Any memory below a magic threshold that is lower than
> 		32-bit.  Only enabled if actually required (usually
> 		either 24-bit for ISA, or some other weird architecture
> 		specific value like 32-bit for S/390)

It should have been ZONE_ISA_DMA :-)

> ZONE_DMA32:	Memory <= 32-bit if the architecture supports more than
> 		32-bits worth of physical address space.  Should generally
> 		be enabled on all 64-bit architectures unless you have
> 		a very good reason not to.

Yeah so we sort-of enable the config option but only populate the zone
on platforms using swiotlb (freescale stuff). It's a bit messy at the
moment I must admit.

> ZONE_NORMAL:	Everything above 32-bit not falling into HIGHMEM or
> 		MOVEABLE.

Cheers,
Ben.

