From: Christoph Hellwig <hch@lst.de>
Date: Thu, 04 Jan 2018 08:52:05 +0000
Subject: Re: [PATCH 27/67] dma-direct: add dma address sanity checks
Message-Id: <20180104085205.GC3251@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171229081911.2802-1-hch@lst.de> <20171229081911.2802-28-hch@lst.de> <CAMuHMdWg3PnTXezMCcr3oGf-83-cjvcj4wGiPk7j2pY1Tgzo9Q@mail.gmail.com>
In-Reply-To: <CAMuHMdWg3PnTXezMCcr3oGf-83-cjvcj4wGiPk7j2pY1Tgzo9Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Christoph Hellwig <hch@lst.de>, iommu@lists.linux-foundation.org, Linux MIPS Mailing List <linux-mips@linux-mips.org>, linux-ia64@vger.kernel.org, Linux-sh list <linux-sh@vger.kernel.org>, sparclinux <sparclinux@vger.kernel.org>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Linux-Arch <linux-arch@vger.kernel.org>, linux-s390 <linux-s390@vger.kernel.org>, linux-c6x-dev@linux-c6x.org, "open list:QUALCOMM HEXAGON..." <linux-hexagon@vger.kernel.org>, the arch/x86 maintainers <x86@kernel.org>, arcml <linux-snps-arc@lists.infradead.org>, adi-buildroot-devel@lists.sourceforge.net, linux-m68k <linux-m68k@lists.linux-m68k.org>, patches@groups.riscv.org, "open list:METAG ARCHITECTURE" <linux-metag@vger.kernel.org>, linux-arm-kernel@lists.infradead.org, Michal Simek <mon>

On Fri, Dec 29, 2017 at 03:12:25PM +0100, Geert Uytterhoeven wrote:
> > +check_addr(struct device *dev, dma_addr_t dma_addr, size_t size,
> > +               const char *caller)
> > +{
> > +       if (unlikely(dev && !dma_capable(dev, dma_addr, size))) {
> > +               if (*dev->dma_mask >= DMA_BIT_MASK(32)) {
> > +                       dev_err(dev,
> > +                               "%s: overflow %llx+%zu of device mask %llx\n",
> 
> Please use "%pad" to format dma_addr_t ...
> 
> > +                               caller, (long long)dma_addr, size,
> 
> ... and use &dma_addr.
> 
> > +                               (long long)*dev->dma_mask);
> 
> This cast is not needed, as u64 is unsigned long long in kernelspace on
> all architectures.

Thanks, fixed.
