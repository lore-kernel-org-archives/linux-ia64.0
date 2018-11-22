From: Russell King - ARM Linux <linux@armlinux.org.uk>
Date: Thu, 22 Nov 2018 18:05:26 +0000
Subject: Re: remove the ->mapping_error method from dma_map_ops V2
Message-Id: <20181122180526.GL30658@n2100.armlinux.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181122140320.24080-1-hch@lst.de>
 <CAHk-=wh=_T=A53+o4zLNbKio43LGqVDb0KCbWPDvAg54bRDmWw@mail.gmail.com>
 <20181122170715.GI30658@n2100.armlinux.org.uk>
 <CAHk-=wgfGzXuDAKFQPdzMib3QCRHfSTsy5=gLU-WCoya+Ym+1A@mail.gmail.com>
 <11829e3c-7302-f821-cf5c-863e5267a17b@arm.com>
 <CAHk-=whxf0zqutExPr_j1A625Z3gcL6k_ABzKo1BtzN4F93hkA@mail.gmail.com>
In-Reply-To: <CAHk-=whxf0zqutExPr_j1A625Z3gcL6k_ABzKo1BtzN4F93hkA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: robin.murphy@arm.com, linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, joro@8bytes.org, the arch/x86 maintainers <x86@kernel.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, iommu@lists.linux-foundation.org, linux-alpha@vger.kernel.org, xen-devel@lists.xenproject.org, jdmason@kudzu.us, David Woodhouse <dwmw2@infradead.org>, Christoph Hellwig <hch@lst.de>, linux-arm-kernel@lists.infradead.org, m.szyprowski@samsung.com

On Thu, Nov 22, 2018 at 09:55:25AM -0800, Linus Torvalds wrote:
> On Thu, Nov 22, 2018 at 9:52 AM Robin Murphy <robin.murphy@arm.com> wrote:
> >
> > Unfortunately, with things like the top-down IOVA allocator, and 32-bit
> > systems in general, "the top 4095" values may well still be valid
> > addresses -
> 
> Ugh.
> 
> > The only immediate benefit I can see is that we could distinguish cases
> > like the first which can never possibly succeed, and thus callers could
> > actually give up instead of doing what various subsystems currently do
> > and retry the exact same mapping indefinitely on the apparent assumption
> > that errors must be transient.
> 
> No, the big immediate benefit of allowing "return -EINVAL" etc is
> simply legibility and error avoidance.
> 
> It's basically how pretty much all the rest of the kernel returns
> errors, so not only is it very obvious, it's also what people do
> without even thinking.. So it would be good to work.

An alternative idea would be to migrate away from the
dma_map_single() and dma_map_page() interfaces that return a
dma_addr_t, and instead have them return an error code or zero
on success.

I've thought for some time that our DMA interfaces aren't particularly
friendly, especially after we had the stuff with PCI DMA which migrated
its way into the DMA API:

DEFINE_DMA_UNMAP_ADDR
DEFINE_DMA_UNMAP_LEN
dma_unmap_*

When coupled that with the requirement that dma_unmap_*() should be
called with the same parameters as dma_map_*(), I wonder why we never
did:

struct dma_map_state {
	dma_addr_t dma_addr;
	whatever's needed;
}

int dma_map_single(struct device *dev, struct dma_map_state *state,
		   void *cpu, size_t len, enum dma_data_direction dir);
void dma_unmap_single(struct device *dev, struct dma_map_state *state);

note the simpler unmap API, which inherently guarantees that the
parameters to the map could be carried over to the unmap - without
our many driver authors having to think about it.

That also paves the way for dma_map_single() to return an error code
or zero.

However, I fear that boat sailed long ago - but maybe its worth
thinking along these lines if we want to sanitise the API now?

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line in suburbia: sync at 12.1Mbps down 622kbps up
According to speedtest.net: 11.9Mbps down 500kbps up
