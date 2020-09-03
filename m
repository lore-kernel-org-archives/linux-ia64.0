From: Christoph Hellwig <hch@lst.de>
Date: Thu, 03 Sep 2020 08:42:26 +0000
Subject: Re: [PATCH 22/28] sgiseeq: convert from dma_cache_sync to dma_sync_single_for_device
Message-Id: <20200903084226.GA24410@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200819065555.1802761-1-hch@lst.de> <20200819065555.1802761-23-hch@lst.de> <20200901152209.GA14288@alpha.franken.de> <20200901171241.GA20685@alpha.franken.de> <20200901171627.GA8255@lst.de> <20200901173810.GA25282@alpha.franken.de> <20200902213809.GA7998@alpha.franken.de>
In-Reply-To: <20200902213809.GA7998@alpha.franken.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
Cc: Christoph Hellwig <hch@lst.de>, alsa-devel@alsa-project.org, linux-ia64@vger.kernel.org, linux-doc@vger.kernel.org, nouveau@lists.freedesktop.org, linux-nvme@lists.infradead.org, linux-kernel@vger.kernel.org, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, linux-mm@kvack.org, Marek Szyprowski <m.szyprowski@samsung.com>, linux-samsung-soc@vger.kernel.org, Joonyoung Shim <jy0922.shim@samsung.com>, linux-scsi@vger.kernel.org, Kyungmin Park <kyungmin.park@samsung.com>, Ben Skeggs <bskeggs@redhat.com>, Matt Porter <mporter@kernel.crashing.org>, linux-media@vger.kernel.org, Tom Lendacky <thomas.lendacky@amd.com>, Pawel Osciak <pawel@osciak.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, linux-arm-kernel@lists.infradead.org, linux-parisc@vger.kernel.org, netdev@vger.kernel.org, Seung-Woo Kim <sw0312.kim@samsung.com>, linux-mips@vger.kernel.org, iommu@lists.linux-foundation.org

On Wed, Sep 02, 2020 at 11:38:09PM +0200, Thomas Bogendoerfer wrote:
> the patch below fixes the problem.

But is very wrong unfortunately.

>  static inline void dma_sync_desc_cpu(struct net_device *dev, void *addr)
>  {
> -       dma_cache_sync(dev->dev.parent, addr, sizeof(struct sgiseeq_rx_desc),
> -                      DMA_FROM_DEVICE);
> +       struct sgiseeq_private *sp = netdev_priv(dev);
> +
> +       dma_sync_single_for_device(dev->dev.parent, VIRT_TO_DMA(sp, addr),
> +                       sizeof(struct sgiseeq_rx_desc), DMA_FROM_DEVICE);
>  }
>  
>  static inline void dma_sync_desc_dev(struct net_device *dev, void *addr)
>  {
> -       dma_cache_sync(dev->dev.parent, addr, sizeof(struct sgiseeq_rx_desc),
> -                      DMA_TO_DEVICE);
> +       struct sgiseeq_private *sp = netdev_priv(dev);
> +
> +       dma_sync_single_for_device(dev->dev.parent, VIRT_TO_DMA(sp, addr),
> +                       sizeof(struct sgiseeq_rx_desc), DMA_TO_DEVICE);

This is not how the DMA API works.  You can only call
dma_sync_single_for_{device,cpu} with the direction that the memory
was mapped.  It then transfer ownership to the device or the cpu,
and the ownership of the memory is a fundamental concept that allows
for reasoning about the caching interaction.

>  }
>  
> -- 
> Crap can work. Given enough thrust pigs will fly, but it's not necessarily a
> good idea.                                                [ RFC1925, 2.3 ]
---end quoted text---
