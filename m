From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 28 Nov 2018 18:00:06 +0000
Subject: Re: remove the ->mapping_error method from dma_map_ops V2
Message-Id: <CAHk-=whnz4Kty6cas11bc2Gh=9zTzeeRS2k=dV9Hfc4B=xnHkQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181122140320.24080-1-hch@lst.de> <CAHk-=wh=_T=A53+o4zLNbKio43LGqVDb0KCbWPDvAg54bRDmWw@mail.gmail.com>
 <20181122170715.GI30658@n2100.armlinux.org.uk> <CAHk-=wgfGzXuDAKFQPdzMib3QCRHfSTsy5=gLU-WCoya+Ym+1A@mail.gmail.com>
 <11829e3c-7302-f821-cf5c-863e5267a17b@arm.com> <CAHk-=whxf0zqutExPr_j1A625Z3gcL6k_ABzKo1BtzN4F93hkA@mail.gmail.com>
 <20181123065511.GA17856@lst.de> <20181128074117.GA21126@lst.de>
 <CAHk-=wg5+rXK8dpjkSmK7tuz29VfxVWNEwmTVYB409mmyLkeew@mail.gmail.com> <20181128174545.GJ30658@n2100.armlinux.org.uk>
In-Reply-To: <20181128174545.GJ30658@n2100.armlinux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux@armlinux.org.uk
Cc: Christoph Hellwig <hch@lst.de>, linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, robin.murphy@arm.com, the arch/x86 maintainers <x86@kernel.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, iommu@lists.linux-foundation.org, linux-alpha@vger.kernel.org, xen-devel@lists.xenproject.org, David Woodhouse <dwmw2@infradead.org>, linux-arm-kernel@lists.infradead.org

On Wed, Nov 28, 2018 at 9:45 AM Russell King - ARM Linux
<linux@armlinux.org.uk> wrote:
>
> > I don't think this is a huge deal, but ERR_PTR() has been hugely
> > successful elsewhere. And I'm not hugely convinced about all these
> > "any address can be valid" arguments. How the hell do you generate a
> > random dma address in the last page that isn't even page-aligned?
>
> kmalloc() a 64-byte buffer, dma_map_single() that buffer.

No.

You already cannot do that kmalloc(), exactly because of ERR_PTR().

Not all memory is accessible even to the kernel. If you have memory
that shows up in the last page of phys_addr_t, you just mark it
reserved at boot-time.

Which is what we ALREADY do for these exact reasons. If the DMA
mappings means that you'd need to add one more page to that list of
reserved pages, then so be it.

The whole argument of "every possible piece of memory is DMA'able" is
just wrong.

                Linus
