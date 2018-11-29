From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 29 Nov 2018 17:44:05 +0000
Subject: Re: remove the ->mapping_error method from dma_map_ops V2
Message-Id: <CAHk-=wi2K7_+dgCbc-sAK9CST5Zh+pOuH7sVT9WW-kqs50HSzQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <CAHk-=wgfGzXuDAKFQPdzMib3QCRHfSTsy5=gLU-WCoya+Ym+1A@mail.gmail.com>
 <11829e3c-7302-f821-cf5c-863e5267a17b@arm.com> <CAHk-=whxf0zqutExPr_j1A625Z3gcL6k_ABzKo1BtzN4F93hkA@mail.gmail.com>
 <20181123065511.GA17856@lst.de> <20181128074117.GA21126@lst.de>
 <CAHk-=wg5+rXK8dpjkSmK7tuz29VfxVWNEwmTVYB409mmyLkeew@mail.gmail.com>
 <20181128174545.GJ30658@n2100.armlinux.org.uk> <CAHk-=whnz4Kty6cas11bc2Gh=9zTzeeRS2k=dV9Hfc4B=xnHkQ@mail.gmail.com>
 <20181128180841.GM30658@n2100.armlinux.org.uk> <CAHk-=whcbiSxSUprsKjVPEdN5-+o8WnTGiKxEV-+HbKNDs=iNA@mail.gmail.com>
 <20181129162323.GA27068@lst.de>
In-Reply-To: <20181129162323.GA27068@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: Russell King - ARM Linux <linux@armlinux.org.uk>, linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, robin.murphy@arm.com, the arch/x86 maintainers <x86@kernel.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, iommu@lists.linux-foundation.org, linux-alpha@vger.kernel.org, xen-devel@lists.xenproject.org, David Woodhouse <dwmw2@infradead.org>, linux-arm-kernel@lists.infradead.org

On Thu, Nov 29, 2018 at 8:23 AM Christoph Hellwig <hch@lst.de> wrote:
>
> We can.  At least in theory.  The problem is that depending on the
> crazy mapping from physical and kernel virtual address to dma addresses
> these might be pages at pretty random places.  Look at fun like
> arch/x86/pci/sta2x11-fixup.c for how ugly these mappings could look.
>
> It also means that we might have setup swiotlb on just about every
> 32-bit architecture, even if it has no real addressing limit except for
> the one we imposed.

No. Really. If there's no iotlb, then you just mark that one page
reserved. It simply doesn't get used. It doesn't mean you suddenly
need a swiotlb.

If there *is* a iotlb, none of this should matter, because you'd just
never map anything into that page.

But whatever. It's independent from the patch series under discussion.
Make dma_mapping_error() at least return a real error (eg -EINVAL, or
whatever is the common error), and we can maybe do this later.

Or, better yet, plan on removing the single-page dma mappign entirely
at a later date, and make the issue moot.

              Linus
