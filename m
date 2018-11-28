From: Russell King - ARM Linux <linux@armlinux.org.uk>
Date: Wed, 28 Nov 2018 19:31:57 +0000
Subject: Re: remove the ->mapping_error method from dma_map_ops V2
Message-Id: <20181128193157.GO30658@n2100.armlinux.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <CAHk-=wgfGzXuDAKFQPdzMib3QCRHfSTsy5=gLU-WCoya+Ym+1A@mail.gmail.com>
 <11829e3c-7302-f821-cf5c-863e5267a17b@arm.com>
 <CAHk-=whxf0zqutExPr_j1A625Z3gcL6k_ABzKo1BtzN4F93hkA@mail.gmail.com>
 <20181123065511.GA17856@lst.de>
 <20181128074117.GA21126@lst.de>
 <CAHk-=wg5+rXK8dpjkSmK7tuz29VfxVWNEwmTVYB409mmyLkeew@mail.gmail.com>
 <20181128174545.GJ30658@n2100.armlinux.org.uk>
 <CAHk-=whnz4Kty6cas11bc2Gh=9zTzeeRS2k=dV9Hfc4B=xnHkQ@mail.gmail.com>
 <20181128180841.GM30658@n2100.armlinux.org.uk>
 <CAHk-=whcbiSxSUprsKjVPEdN5-+o8WnTGiKxEV-+HbKNDs=iNA@mail.gmail.com>
In-Reply-To: <CAHk-=whcbiSxSUprsKjVPEdN5-+o8WnTGiKxEV-+HbKNDs=iNA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Hellwig <hch@lst.de>, linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, robin.murphy@arm.com, the arch/x86 maintainers <x86@kernel.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, iommu@lists.linux-foundation.org, linux-alpha@vger.kernel.org, xen-devel@lists.xenproject.org, David Woodhouse <dwmw2@infradead.org>, linux-arm-kernel@lists.infradead.org

On Wed, Nov 28, 2018 at 11:19:15AM -0800, Linus Torvalds wrote:
> On Wed, Nov 28, 2018, 10:08 Russell King - ARM Linux <linux@armlinux.org.uk
> wrote:
> 
> > >
> > > You already cannot do that kmalloc(), exactly because of ERR_PTR().
> >
> > I'm very sorry, but I think you are confused.
> >
> > kmalloc() returns a _virtual_ address, which quite rightly must not be
> > in the top 4K of 4GB, exactly due to ERR_PTR().  That is fine.
> >
> > However, that is a completely different kettle of fish from a physical
> > or DMA address - neither of which are virtual addresses.
> >
> 
> You cut away the part that showed that I'm not in the least confused.
> 
> Let me just paste it back in here:
> 
>   "Which is what we ALREADY do for these exact reasons. If the DMA
> mappings means that you'd need to add one more page to that list of
> reserved pages, then so be it."

We're not talking about just one more page.  We're talking about
_every_ page that _may_ map to a bus address in the range of 4GB - 4K
(a point I've already made earlier in this discussion.)

It's not just about physical addresses, it's about bus addresses,
and there are buses out there that have a translation between physical
address and bus address without IOMMUs and the like.

Can we know ahead of time about all these translations?  It means
moving that information out of various bus drivers into core
architecture code (yuck, when you have multiple different platforms)
or into DT (which means effectively breaking every damn platform
that's using older DT files) - something that we don't have to do
today.

I remain 100% opposed to your idea.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line in suburbia: sync at 12.1Mbps down 622kbps up
According to speedtest.net: 11.9Mbps down 500kbps up
