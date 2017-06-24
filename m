From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Sat, 24 Jun 2017 15:36:56 +0000
Subject: Re: clean up and modularize arch dma_mapping interface V2
Message-Id: <1498318616.31581.87.camel@kernel.crashing.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170616181059.19206-1-hch@lst.de>
 <162d7932-5766-4c29-5471-07d1b699190a@oracle.com>
 <20170624071855.GD14580@lst.de>
In-Reply-To: <20170624071855.GD14580@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>, tndave <tushar.n.dave@oracle.com>
Cc: linux-mips@linux-mips.org, sparclinux@vger.kernel.org, linux-samsung-soc@vger.kernel.org, linux-ia64@vger.kernel.org, linux-c6x-dev@linux-c6x.org, linux-sh@vger.kernel.org, linux-s390@vger.kernel.org, linux-xtensa@linux-xtensa.org, x86@kernel.org, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, dmaengine@vger.kernel.org, iommu@lists.linux-foundation.org, openrisc@lists.librecores.org, linux-hexagon@vger.kernel.org, linux-tegra@vger.kernel.org, xen-devel@lists.xenproject.org, linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org

On Sat, 2017-06-24 at 09:18 +0200, Christoph Hellwig wrote:
> On Wed, Jun 21, 2017 at 12:24:28PM -0700, tndave wrote:
> > Thanks for doing this.
> > So archs can still have their own definition for dma_set_mask() if 
> > HAVE_ARCH_DMA_SET_MASK is y?
> > (and similarly for dma_set_coherent_mask() when 
> > CONFIG_ARCH_HAS_DMA_SET_COHERENT_MASK is y)
> > Any plan to change these?
> 
> Yes, those should go away, but I'm not entirely sure how yet.  We'll
> need some hook for switching between an IOMMU and a direct mapping
> (I guess that's what you want to do for sparc as well?), and I need
> to find the best way to do that.  Reimplementing all of dma_set_mask
> and dma_set_coherent_mask is something that I want to move away from.

I think we still need to do it. For example we have a bunch new "funky"
cases.

We already have the case where we mix the direct and iommu mappings,
on some powerpc platforms that translates in an iommu mapping down at
0 for the 32-bit space and a direct mapping high up in the PCI address
space (which crops the top bits and thus hits memory at 0 onwards).

This type of hybrid layout is needed by some adapters, typically
storage, which want to keep the "coherent" mask at 32-bit but support
64-bit for streaming masks.

Another one we are trying to deal better with at the moment is devices
with DMA addressing limitations. Some GPUs typically (but not only)
have limits that go all accross the gamut, typically I've seen 40 bits,
44 bits and 47 bits... And of course those are "high peformance"
adapters so we don't want to limit them to the comparatively small
iommu mapping with extra overhead.

At the moment, we're looking at a dma_set_mask() hook that will, for
these guys, re-configure the iommu mapping to create a "compressed"
linear mapping of system memory (ie, skipping the holes we have between
chip on P9 for example) using the largest possible iommu page size
(256M on P8, 1G on P9).

This is made tricky of course because several devices can potentially
share a DMA domain based on various platform specific reasons. And of
course we have no way to figure out what's the "common denominator" of
all those devices before they start doing DMA. A driver can start
before the neighbour is probed and a driver can start doing DMAs using
the standard 32-bit mapping without doing dma_set_mask().

So heuristics ... ugh. Better ideas welcome :-) All that to say that we
are far from being able to get rid of dma_set_mask() custom
implementations (and coherent mask too).

I was tempted at some point retiring the 32-bit iommu mapping
completely, just doing that "linear" thing I mentioned above and
swiotlb for the rest, along with introducing ZONE_DMA32 on powerpc
(with the real 64-bit bypass still around for non-limited devices but
that's then just extra speed by bypassing the iommu xlate & cache).

But I worry of the impact on those silly adapters that set the coherent
mask to 32-bits to keep their microcode & descriptor ring down in 32-
bit space. I'm not sure how well ZONE_DMA32 behaves in those cases.

Cheers,
Ben.

