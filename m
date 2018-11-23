From: Russell King - ARM Linux <linux@armlinux.org.uk>
Date: Fri, 23 Nov 2018 11:01:55 +0000
Subject: Re: remove the ->mapping_error method from dma_map_ops V2
Message-Id: <20181123110155.GR30658@n2100.armlinux.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181122140320.24080-1-hch@lst.de>
 <CAHk-=wh=_T=A53+o4zLNbKio43LGqVDb0KCbWPDvAg54bRDmWw@mail.gmail.com>
 <20181122170715.GI30658@n2100.armlinux.org.uk>
 <CAHk-=wgfGzXuDAKFQPdzMib3QCRHfSTsy5=gLU-WCoya+Ym+1A@mail.gmail.com>
 <11829e3c-7302-f821-cf5c-863e5267a17b@arm.com>
 <20181123104918.GE1586@8bytes.org>
In-Reply-To: <20181123104918.GE1586@8bytes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Joerg Roedel <joro@8bytes.org>
Cc: Robin Murphy <robin.murphy@arm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, linux-arch@vger.kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, David Woodhouse <dwmw2@infradead.org>, the arch/x86 maintainers <x86@kernel.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, iommu@lists.linux-foundation.org, jdmason@kudzu.us, xen-devel@lists.xenproject.org, linux-arm-kernel@lists.infradead.org, m.szyprowski@samsung.com

On Fri, Nov 23, 2018 at 11:49:18AM +0100, Joerg Roedel wrote:
> On Thu, Nov 22, 2018 at 05:52:15PM +0000, Robin Murphy wrote:
> > Unfortunately, with things like the top-down IOVA allocator, and 32-bit
> > systems in general, "the top 4095" values may well still be valid addresses
> > - we're relying on a 1-byte mapping of the very top byte of memory/IOVA
> > space being sufficiently ridiculous that no real code would ever do that,
> > but even a 4-byte mapping of the top 4 bytes is within the realms of the
> > plausible (I've definitely seen the USB layer make 8-byte mappings from any
> > old offset within a page, for example).
> 
> But we can easily work around that by reserving the top 4k of the first
> 4GB of IOVA address space in the allocator, no? Then these values are
> never returned as valid DMA handles.

Yuck.  So, if we have a 4GB non-PAE 32-bit system, or a PAE system
where we have valid memory across the 4GB boundary and no IOMMU,
we have to reserve the top 4K page in the first 4GB of RAM?

Linus' IS_DMA_ERR() solution is way more preferable, but unfortunately
it still falls short, because it knocks out the top 4K of every DMA
capable bus.

A DMA capable bus may involve some translation of the address (eg, by
simple offsetting) which means that we'd need to potentially knock out
multiple pages from the page allocator for each of those pages that
correspond to the top 4K of any DMA capable bus.  Knowing that at the
right time at boot will be fun!  It also sounds wasteful to me.

Rather than inventing magic cookies like this, I'd much rather we
sanitised the API so that we have functions that return success or
an error code, rather than trying to shoe-horn some kind of magic
error codes into dma_addr_t and subtly break systems in the process.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line in suburbia: sync at 12.1Mbps down 622kbps up
According to speedtest.net: 11.9Mbps down 500kbps up
