From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 28 Nov 2018 16:47:05 +0000
Subject: Re: remove the ->mapping_error method from dma_map_ops V2
Message-Id: <CAHk-=wg5+rXK8dpjkSmK7tuz29VfxVWNEwmTVYB409mmyLkeew@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181122140320.24080-1-hch@lst.de> <CAHk-=wh=_T=A53+o4zLNbKio43LGqVDb0KCbWPDvAg54bRDmWw@mail.gmail.com>
 <20181122170715.GI30658@n2100.armlinux.org.uk> <CAHk-=wgfGzXuDAKFQPdzMib3QCRHfSTsy5=gLU-WCoya+Ym+1A@mail.gmail.com>
 <11829e3c-7302-f821-cf5c-863e5267a17b@arm.com> <CAHk-=whxf0zqutExPr_j1A625Z3gcL6k_ABzKo1BtzN4F93hkA@mail.gmail.com>
 <20181123065511.GA17856@lst.de> <20181128074117.GA21126@lst.de>
In-Reply-To: <20181128074117.GA21126@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, David Woodhouse <dwmw2@infradead.org>, the arch/x86 maintainers <x86@kernel.org>, linux@armlinux.org.uk, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, iommu@lists.linux-foundation.org, linux-alpha@vger.kernel.org, xen-devel@lists.xenproject.org, robin.murphy@arm.com, linux-arm-kernel@lists.infradead.org

On Tue, Nov 27, 2018 at 11:41 PM Christoph Hellwig <hch@lst.de> wrote:
>
> On Fri, Nov 23, 2018 at 07:55:11AM +0100, Christoph Hellwig wrote:
> > Well, I can tweak the last patch to return -EINVAL from dma_mapping_error
> > instead of the old 1 is as bool true.  The callers should all be fine,
> > although I'd have to audit them.  Still wouldn't help with being able to
> > return different errors.
>
> Any opinions?  I'd really like to make some forward progress on this
> series.

So I do think that yes, dma_mapping_error() should return an error
code, not 0/1.

But I was really hoping that the individual drivers themselves could
return error codes. Right now the patch-series has code like this:

      ret = needs_bounce(dev, dma_addr, size);
      if (ret < 0)
-         return ARM_MAPPING_ERROR;
+         return DMA_MAPPING_ERROR;

which while it all makes sense in the context of this patch-series, I
*really* think it would have been so much nicer to return the error
code 'ret' instead (which in this case is -E2BIG).

I don't think this is a huge deal, but ERR_PTR() has been hugely
successful elsewhere. And I'm not hugely convinced about all these
"any address can be valid" arguments. How the hell do you generate a
random dma address in the last page that isn't even page-aligned?

                     Linus
