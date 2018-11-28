From: Russell King - ARM Linux <linux@armlinux.org.uk>
Date: Wed, 28 Nov 2018 19:23:02 +0000
Subject: Re: remove the ->mapping_error method from dma_map_ops V2
Message-Id: <20181128192301.GN30658@n2100.armlinux.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181122170715.GI30658@n2100.armlinux.org.uk>
 <CAHk-=wgfGzXuDAKFQPdzMib3QCRHfSTsy5=gLU-WCoya+Ym+1A@mail.gmail.com>
 <11829e3c-7302-f821-cf5c-863e5267a17b@arm.com>
 <CAHk-=whxf0zqutExPr_j1A625Z3gcL6k_ABzKo1BtzN4F93hkA@mail.gmail.com>
 <20181123065511.GA17856@lst.de>
 <20181128074117.GA21126@lst.de>
 <CAHk-=wg5+rXK8dpjkSmK7tuz29VfxVWNEwmTVYB409mmyLkeew@mail.gmail.com>
 <20181128174545.GJ30658@n2100.armlinux.org.uk>
 <CAHk-=whnz4Kty6cas11bc2Gh=9zTzeeRS2k=dV9Hfc4B=xnHkQ@mail.gmail.com>
 <20181128180841.GM30658@n2100.armlinux.org.uk>
In-Reply-To: <20181128180841.GM30658@n2100.armlinux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, David Woodhouse <dwmw2@infradead.org>, the arch/x86 maintainers <x86@kernel.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, iommu@lists.linux-foundation.org, linux-alpha@vger.kernel.org, xen-devel@lists.xenproject.org, robin.murphy@arm.com, Christoph Hellwig <hch@lst.de>, linux-arm-kernel@lists.infradead.org

On Wed, Nov 28, 2018 at 06:08:41PM +0000, Russell King - ARM Linux wrote:
> On Wed, Nov 28, 2018 at 10:00:06AM -0800, Linus Torvalds wrote:
> > On Wed, Nov 28, 2018 at 9:45 AM Russell King - ARM Linux
> > <linux@armlinux.org.uk> wrote:
> > >
> > > > I don't think this is a huge deal, but ERR_PTR() has been hugely
> > > > successful elsewhere. And I'm not hugely convinced about all these
> > > > "any address can be valid" arguments. How the hell do you generate a
> > > > random dma address in the last page that isn't even page-aligned?
> > >
> > > kmalloc() a 64-byte buffer, dma_map_single() that buffer.
> > 
> > No.
> > 
> > You already cannot do that kmalloc(), exactly because of ERR_PTR().
> 
> I'm very sorry, but I think you are confused.
> 
> kmalloc() returns a _virtual_ address, which quite rightly must not be
> in the top 4K of 4GB, exactly due to ERR_PTR().  That is fine.
> 
> However, that is a completely different kettle of fish from a physical
> or DMA address - neither of which are virtual addresses.
> 
> Now, say we have 1GB of RAM which starts at 0xc0000000 _physical_.
> The kernel is configured with a 2GB/2GB user/kernel split, which means
> all 1GB of RAM is mapped as lowmem from 0x80000000 to 0xbfffffff
> inclusive.  This means kmalloc() can return any address in that range.
> 
> ERR_PTR() will work correctly on any of those pointers, meaning that
> none of them will be seen as an error.
> 
> However, map any virtual address in the range of 0xbffff000 to
> 0xbfffffff into DMA space, and the resulting DMA address could well
> be in the range of 0xfffff000 to 0xffffffff - precisely the range
> of addresses that you are advocating to be used for error codes.
> 
> > The whole argument of "every possible piece of memory is DMA'able" is
> > just wrong.
> 
> I'm very sorry, but I do not buy your argument - you are conflating
> virtual addresses which ERR_PTR() deals in with physical and bus
> addresses - and if you persist down this route, you will cause
> regressions.

Here's another case:

i.MX6 with 4GB of RAM.  Devices are mapped to 0-0x0fffffff physical,
RAM is mapped to 0x10000000-0xffffffff physical.  The last 256MB of
RAM is not accessible as this is a 32-bit device.  DMA addresses are
the same as physical addresses.

While the final physical page will be highmem in a normal kernel,
and thus will not be available for kmalloc(), that doesn't mean it
can't happen.  A crashdump kernel loaded high in physical memory
(eg, last 512MB and given the last 512MB to play around in) would
have the top 512MB as lowmem, and therefore available for kmalloc().

If a page is available in lowmem, it's available for kmalloc(), and
we can't say that we will never allocate memory from such a page for
DMA - if we do and we're using an IS_ERR_VALUE() scheme, it _will_
break if that happens as memory will end up being mapped by the DMA
API but dma_mapping_error() will see it as a failure.

It won't be an obvious breakage, because it depends on the right
conditions happening - a kmalloc() from the top page of physical
RAM and that being passed to dma_map_single().  IOW, it's not something
that a quick boot test would find, it's something that is likely to
cause failures after a system has been running for a period of time.

There are other situations where there are possibilities - such as:

	dma_map_page(dev, page, offset, size, direction)

If 'page' is a highmem page which happens to be the top page in the
4GB space, and offset is non-zero, and there's a 1:1 mapping between
physical address and DMA address, the returned value will be
0xfffff000 + offset - within the "last 4095 values are errors"
range.

Networking uses this for fragments - the packet fragment list is
a list of pages, offsets and sizes - we have sendpage() that may
end up finding that last page, and TCP-sized packets may be
generated from it which would certianly result in non-zero offsets
being passed to dma_map_page().

So, whatever way _I_ look at it, I find your proposal to be unsafe
and potentially regression causing, and I *completely* and strongly
oppose it in its current form.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line in suburbia: sync at 12.1Mbps down 622kbps up
According to speedtest.net: 11.9Mbps down 500kbps up
