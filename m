From: Russell King - ARM Linux <linux@armlinux.org.uk>
Date: Fri, 23 Nov 2018 13:20:38 +0000
Subject: Re: remove the ->mapping_error method from dma_map_ops V2
Message-Id: <20181123132038.GT30658@n2100.armlinux.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181122140320.24080-1-hch@lst.de>
 <CAHk-=wh=_T=A53+o4zLNbKio43LGqVDb0KCbWPDvAg54bRDmWw@mail.gmail.com>
 <20181122170715.GI30658@n2100.armlinux.org.uk>
 <CAHk-=wgfGzXuDAKFQPdzMib3QCRHfSTsy5=gLU-WCoya+Ym+1A@mail.gmail.com>
 <11829e3c-7302-f821-cf5c-863e5267a17b@arm.com>
 <20181123104918.GE1586@8bytes.org>
 <20181123110155.GR30658@n2100.armlinux.org.uk>
 <20181123130313.GI1586@8bytes.org>
In-Reply-To: <20181123130313.GI1586@8bytes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Joerg Roedel <joro@8bytes.org>
Cc: Robin Murphy <robin.murphy@arm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, linux-arch@vger.kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, David Woodhouse <dwmw2@infradead.org>, the arch/x86 maintainers <x86@kernel.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, iommu@lists.linux-foundation.org, jdmason@kudzu.us, xen-devel@lists.xenproject.org, linux-arm-kernel@lists.infradead.org, m.szyprowski@samsung.com

On Fri, Nov 23, 2018 at 02:03:13PM +0100, Joerg Roedel wrote:
> On Fri, Nov 23, 2018 at 11:01:55AM +0000, Russell King - ARM Linux wrote:
> > Yuck.  So, if we have a 4GB non-PAE 32-bit system, or a PAE system
> > where we have valid memory across the 4GB boundary and no IOMMU,
> > we have to reserve the top 4K page in the first 4GB of RAM?
> 
> But that is only needed when dma_addr_t is 32bit anyway, no?

You said:

  But we can easily work around that by reserving the top 4k of the first
  4GB of IOVA address space in the allocator, no? Then these values are
  never returned as valid DMA handles.

To me, your proposal equates to this in code:

int dma_error(dma_addr_t addr)
{
	return (addr & ~(dma_addr_t)0xfff) = 0xfffff000 ? (s32)addr : 0; 
}

Hence, the size of dma_addr_t would be entirely irrelevant.  This
makes dma_addr_t values in the range of 0xfffff000 to 0xffffffff special,
irrespective of whether dma_addr_t is 32-bit or 64-bit.

If that's not what you meant, then I'm afraid your statement wasn't
worded very well - so please can you re-word to state more precisely
what your proposal is?

> > Rather than inventing magic cookies like this, I'd much rather we
> > sanitised the API so that we have functions that return success or
> > an error code, rather than trying to shoe-horn some kind of magic
> > error codes into dma_addr_t and subtly break systems in the process.
> 
> Sure, but is has the obvious downside that we need to touch every driver
> that uses these functions, and that are probably a lot of drivers.

So we have two options:
- change the interface
- subtly break drivers

In any case, I disagree that we need to touch every driver.  Today,
drivers just do:

	if (dma_mapping_error(dev, addr))

and, because dma_mapping_error() returns a boolean, they only care about
the true/falseness.  If we're going to start returning error codes, then
there's no point just returning error codes unless we have some way for
drivers to use them.  Yes, the simple way would be to make
dma_mapping_error() translate addr to an error code, and that maintains
compatibility with existing drivers.

If, instead, we revamped the DMA API, and had the *new* mapping functions
which returned an error code, then the existing mapping functions can be
implemented as part of compatibility rather trivially:

dma_addr_t dma_map_single(...)
{
	dma_addr_t addr;
	int error;

	error = dma_map_single_error(..., &addr);
	if (error)
		addr = DMA_MAPPING_ERROR;
	return addr;
}

which means that if drivers want access to the error code, they use
dma_map_single_error(), meanwhile existing drivers just get on with life
as it _currently_ is, with the cookie-based all-ones error code - without
introducing any of this potential breakage.

Remember, existing drivers would need modification in _any_ case to make
use of a returned error code, so the argument that we'd need to touch
every driver doesn't really stand up.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line in suburbia: sync at 12.1Mbps down 622kbps up
According to speedtest.net: 11.9Mbps down 500kbps up
