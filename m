From: Russell King - ARM Linux <linux@armlinux.org.uk>
Date: Thu, 22 Nov 2018 17:07:15 +0000
Subject: Re: remove the ->mapping_error method from dma_map_ops V2
Message-Id: <20181122170715.GI30658@n2100.armlinux.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181122140320.24080-1-hch@lst.de>
 <CAHk-=wh=_T=A53+o4zLNbKio43LGqVDb0KCbWPDvAg54bRDmWw@mail.gmail.com>
In-Reply-To: <CAHk-=wh=_T=A53+o4zLNbKio43LGqVDb0KCbWPDvAg54bRDmWw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Hellwig <hch@lst.de>, linux-arch@vger.kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, David Woodhouse <dwmw2@infradead.org>, joro@8bytes.org, the arch/x86 maintainers <x86@kernel.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, iommu@lists.linux-foundation.org, jdmason@kudzu.us, xen-devel@lists.xenproject.org, robin.murphy@arm.com, linux-arm-kernel@lists.infradead.org, m.szyprowski@samsung.com

On Thu, Nov 22, 2018 at 08:50:47AM -0800, Linus Torvalds wrote:
> On Thu, Nov 22, 2018 at 6:03 AM Christoph Hellwig <hch@lst.de> wrote:
> >
> > The 0 return doesn't work for direct mappings that have ram at address
> > zero and a lot of IOMMUs that start allocating bus space from address
> > zero, so we can't consolidate on that, but I think we can move everyone
> > to all-Fs, which the patch here does.
> 
> Hmm. Maybe not limit it to just all ones, but actually use the
> (standard, for the kernel) IS_ERR_VALUE()?
> 
> That basically reserves the last 4095 values in an unsigned long for
> error values.
> 
> Then those functions could actually return *what* error they
> encountered, using just plain
> 
>         return -ENOMEM;
> 
> or whatever?

Linus,

I'm afraid that won't work very well - 32 bit platforms with 64-bit
addresses (LPAE) would have dma_addr_t as a 64-bit value, which
wouldn't fit into an unsigned long.

IS_ERR_VALUE() would cast a 64-bit DMA address down to a 32-bit
pointer (effectively masking with 0xffffffff).  It would have the
effect of making (eg) 0xXXXXXXXX_fffffVVV an error, where XXXXXXXX
are any of the top 32-bits of a 64-bit bus address, and VVV is the
error code value.

That could be a problem if you hit it in several places throughout
your available RAM... we'd have to mark every top page of RAM in
a naturally aligned 4GB as unusable, as well as block the top page
in natually aligned 4GB blocks from IOMMUs... and then what about
buses that have weird offsets...

So, I don't think the IS_ERR_VALUE() would work very well.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line in suburbia: sync at 12.1Mbps down 622kbps up
According to speedtest.net: 11.9Mbps down 500kbps up
