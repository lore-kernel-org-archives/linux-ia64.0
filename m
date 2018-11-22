From: Russell King - ARM Linux <linux@armlinux.org.uk>
Date: Thu, 22 Nov 2018 17:14:47 +0000
Subject: Re: remove the ->mapping_error method from dma_map_ops V2
Message-Id: <20181122171446.GJ30658@n2100.armlinux.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181122140320.24080-1-hch@lst.de>
 <CAHk-=wh=_T=A53+o4zLNbKio43LGqVDb0KCbWPDvAg54bRDmWw@mail.gmail.com>
 <20181122170715.GI30658@n2100.armlinux.org.uk>
 <CAHk-=wgfGzXuDAKFQPdzMib3QCRHfSTsy5=gLU-WCoya+Ym+1A@mail.gmail.com>
In-Reply-To: <CAHk-=wgfGzXuDAKFQPdzMib3QCRHfSTsy5=gLU-WCoya+Ym+1A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Hellwig <hch@lst.de>, linux-arch@vger.kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, David Woodhouse <dwmw2@infradead.org>, joro@8bytes.org, the arch/x86 maintainers <x86@kernel.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, iommu@lists.linux-foundation.org, jdmason@kudzu.us, xen-devel@lists.xenproject.org, robin.murphy@arm.com, linux-arm-kernel@lists.infradead.org, m.szyprowski@samsung.com

On Thu, Nov 22, 2018 at 09:09:47AM -0800, Linus Torvalds wrote:
> On Thu, Nov 22, 2018 at 9:07 AM Russell King - ARM Linux
> <linux@armlinux.org.uk> wrote:
> >
> > I'm afraid that won't work very well - 32 bit platforms with 64-bit
> > addresses (LPAE) would have dma_addr_t as a 64-bit value, which
> > wouldn't fit into an unsigned long.
> 
> Good point. So we'd have to have a special IS_DMA_ERR() function that
> takes a dma_addr_t and checks the same "is it the top 4095 values".

No problem with that.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line in suburbia: sync at 12.1Mbps down 622kbps up
According to speedtest.net: 11.9Mbps down 500kbps up
