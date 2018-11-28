From: Russell King - ARM Linux <linux@armlinux.org.uk>
Date: Wed, 28 Nov 2018 18:08:41 +0000
Subject: Re: remove the ->mapping_error method from dma_map_ops V2
Message-Id: <20181128180841.GM30658@n2100.armlinux.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <CAHk-=wh=_T=A53+o4zLNbKio43LGqVDb0KCbWPDvAg54bRDmWw@mail.gmail.com>
 <20181122170715.GI30658@n2100.armlinux.org.uk>
 <CAHk-=wgfGzXuDAKFQPdzMib3QCRHfSTsy5=gLU-WCoya+Ym+1A@mail.gmail.com>
 <11829e3c-7302-f821-cf5c-863e5267a17b@arm.com>
 <CAHk-=whxf0zqutExPr_j1A625Z3gcL6k_ABzKo1BtzN4F93hkA@mail.gmail.com>
 <20181123065511.GA17856@lst.de>
 <20181128074117.GA21126@lst.de>
 <CAHk-=wg5+rXK8dpjkSmK7tuz29VfxVWNEwmTVYB409mmyLkeew@mail.gmail.com>
 <20181128174545.GJ30658@n2100.armlinux.org.uk>
 <CAHk-=whnz4Kty6cas11bc2Gh=9zTzeeRS2k=dV9Hfc4B=xnHkQ@mail.gmail.com>
In-Reply-To: <CAHk-=whnz4Kty6cas11bc2Gh=9zTzeeRS2k=dV9Hfc4B=xnHkQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Hellwig <hch@lst.de>, linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, robin.murphy@arm.com, the arch/x86 maintainers <x86@kernel.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, iommu@lists.linux-foundation.org, linux-alpha@vger.kernel.org, xen-devel@lists.xenproject.org, David Woodhouse <dwmw2@infradead.org>, linux-arm-kernel@lists.infradead.org

On Wed, Nov 28, 2018 at 10:00:06AM -0800, Linus Torvalds wrote:
> On Wed, Nov 28, 2018 at 9:45 AM Russell King - ARM Linux
> <linux@armlinux.org.uk> wrote:
> >
> > > I don't think this is a huge deal, but ERR_PTR() has been hugely
> > > successful elsewhere. And I'm not hugely convinced about all these
> > > "any address can be valid" arguments. How the hell do you generate a
> > > random dma address in the last page that isn't even page-aligned?
> >
> > kmalloc() a 64-byte buffer, dma_map_single() that buffer.
> 
> No.
> 
> You already cannot do that kmalloc(), exactly because of ERR_PTR().

I'm very sorry, but I think you are confused.

kmalloc() returns a _virtual_ address, which quite rightly must not be
in the top 4K of 4GB, exactly due to ERR_PTR().  That is fine.

However, that is a completely different kettle of fish from a physical
or DMA address - neither of which are virtual addresses.

Now, say we have 1GB of RAM which starts at 0xc0000000 _physical_.
The kernel is configured with a 2GB/2GB user/kernel split, which means
all 1GB of RAM is mapped as lowmem from 0x80000000 to 0xbfffffff
inclusive.  This means kmalloc() can return any address in that range.

ERR_PTR() will work correctly on any of those pointers, meaning that
none of them will be seen as an error.

However, map any virtual address in the range of 0xbffff000 to
0xbfffffff into DMA space, and the resulting DMA address could well
be in the range of 0xfffff000 to 0xffffffff - precisely the range
of addresses that you are advocating to be used for error codes.

> The whole argument of "every possible piece of memory is DMA'able" is
> just wrong.

I'm very sorry, but I do not buy your argument - you are conflating
virtual addresses which ERR_PTR() deals in with physical and bus
addresses - and if you persist down this route, you will cause
regressions.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line in suburbia: sync at 12.1Mbps down 622kbps up
According to speedtest.net: 11.9Mbps down 500kbps up
