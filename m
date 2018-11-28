From: Russell King - ARM Linux <linux@armlinux.org.uk>
Date: Wed, 28 Nov 2018 19:47:09 +0000
Subject: Re: remove the ->mapping_error method from dma_map_ops V2
Message-Id: <20181128194708.GP30658@n2100.armlinux.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <CAHk-=wg5+rXK8dpjkSmK7tuz29VfxVWNEwmTVYB409mmyLkeew@mail.gmail.com>
 <20181128174545.GJ30658@n2100.armlinux.org.uk>
 <CAHk-=whnz4Kty6cas11bc2Gh=9zTzeeRS2k=dV9Hfc4B=xnHkQ@mail.gmail.com>
 <20181128.112717.149234960284639699.davem@davemloft.net>
In-Reply-To: <20181128.112717.149234960284639699.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>
Cc: torvalds@linux-foundation.org, hch@lst.de, linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, robin.murphy@arm.com, x86@kernel.org, linux-kernel@vger.kernel.org, iommu@lists.linux-foundation.org, linux-alpha@vger.kernel.org, xen-devel@lists.xenproject.org, dwmw2@infradead.org, linux-arm-kernel@lists.infradead.org

On Wed, Nov 28, 2018 at 11:27:17AM -0800, David Miller wrote:
> From: Linus Torvalds <torvalds@linux-foundation.org>
> Date: Wed, 28 Nov 2018 10:00:06 -0800
> 
> > Not all memory is accessible even to the kernel. If you have memory
> > that shows up in the last page of phys_addr_t, you just mark it
> > reserved at boot-time.
> 
> It's not the physical memory at the end that needs to be reserved.
> 
> It's the IOMMU mapping arena.

True, if and only if you have an IOMMU.

Where there isn't an IOMMU, then we'd have to reserve every page that
that translates to a bus address in the top 4K of dma_addr_t on any
bus in the system - that means knowing early in the kernel
initialisation about all buses in the system so we can detect and
reserve these pages.

I don't think that's trivial to do.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line in suburbia: sync at 12.1Mbps down 622kbps up
According to speedtest.net: 11.9Mbps down 500kbps up
