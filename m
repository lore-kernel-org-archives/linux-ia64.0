From: Christoph Hellwig <hch@lst.de>
Date: Thu, 29 Nov 2018 16:23:23 +0000
Subject: Re: remove the ->mapping_error method from dma_map_ops V2
Message-Id: <20181129162323.GA27068@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <CAHk-=wgfGzXuDAKFQPdzMib3QCRHfSTsy5=gLU-WCoya+Ym+1A@mail.gmail.com> <11829e3c-7302-f821-cf5c-863e5267a17b@arm.com> <CAHk-=whxf0zqutExPr_j1A625Z3gcL6k_ABzKo1BtzN4F93hkA@mail.gmail.com> <20181123065511.GA17856@lst.de> <20181128074117.GA21126@lst.de> <CAHk-=wg5+rXK8dpjkSmK7tuz29VfxVWNEwmTVYB409mmyLkeew@mail.gmail.com> <20181128174545.GJ30658@n2100.armlinux.org.uk> <CAHk-=whnz4Kty6cas11bc2Gh=9zTzeeRS2k=dV9Hfc4B=xnHkQ@mail.gmail.com> <20181128180841.GM30658@n2100.armlinux.org.uk> <CAHk-=whcbiSxSUprsKjVPEdN5-+o8WnTGiKxEV-+HbKNDs=iNA@mail.gmail.com>
In-Reply-To: <CAHk-=whcbiSxSUprsKjVPEdN5-+o8WnTGiKxEV-+HbKNDs=iNA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Russell King - ARM Linux <linux@armlinux.org.uk>, Christoph Hellwig <hch@lst.de>, linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, robin.murphy@arm.com, the arch/x86 maintainers <x86@kernel.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, iommu@lists.linux-foundation.org, linux-alpha@vger.kernel.org, xen-devel@lists.xenproject.org, David Woodhouse <dwmw2@infradead.org>, linux-arm-kernel@lists.infradead.org

On Wed, Nov 28, 2018 at 11:19:15AM -0800, Linus Torvalds wrote:
> Let me just paste it back in here:
> 
>   "Which is what we ALREADY do for these exact reasons. If the DMA
> mappings means that you'd need to add one more page to that list of
> reserved pages, then so be it."
> 
> So no, I'm not at all confused.
> 
> Let me re-iterate: the argument that all addresses have to be dma'able is
> garbage.
> 
> *Exactly* as with kmalloc and limited virtual addresses, we can limit
> physical addresses.

We can.  At least in theory.  The problem is that depending on the
crazy mapping from physical and kernel virtual address to dma addresses
these might be pages at pretty random places.  Look at fun like
arch/x86/pci/sta2x11-fixup.c for how ugly these mappings could look.

It also means that we might have setup swiotlb on just about every
32-bit architecture, even if it has no real addressing limit except for
the one we imposed.  I don't really see how this is a win for us just
to be able to report more detailed error codes, which would be nice
to have, but the lack of which hasn't really harmed us.

So as far as I'm concerned I'd go either with the series that we are
discussing here, or change the map_page method to return an errno
and the dma_addr_t in the argument.  As Davem pointed out that can lead
to less optimal code, but it would still be better than the indirect
call we have.  But then again I think the series as posted here might
and up much simpler and good enough without opening up this rathole.
