From: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
Date: Tue, 01 Sep 2020 15:22:09 +0000
Subject: Re: [PATCH 22/28] sgiseeq: convert from dma_cache_sync to dma_sync_single_for_device
Message-Id: <20200901152209.GA14288@alpha.franken.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200819065555.1802761-1-hch@lst.de>
 <20200819065555.1802761-23-hch@lst.de>
In-Reply-To: <20200819065555.1802761-23-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: Mauro Carvalho Chehab <mchehab@kernel.org>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Joonyoung Shim <jy0922.shim@samsung.com>, Seung-Woo Kim <sw0312.kim@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Ben Skeggs <bskeggs@redhat.com>, Pawel Osciak <pawel@osciak.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Matt Porter <mporter@kernel.crashing.org>, iommu@lists.linux-foundation.org, Tom Lendacky <thomas.lendacky@amd.com>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linux-samsung-soc@vger.kernel.org, nouveau@lists.freedesktop.org, netdev@vger.kernel.org, linux-nvme@lists.infradead.org, linux-scsi@vger.kernel.org, linux-mm@kvack.org, alsa-devel@alsa-project.org

On Wed, Aug 19, 2020 at 08:55:49AM +0200, Christoph Hellwig wrote:
> Use the proper modern API to transfer cache ownership for incoherent DMA.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  drivers/net/ethernet/seeq/sgiseeq.c | 12 ++++++++----
>  1 file changed, 8 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/ethernet/seeq/sgiseeq.c b/drivers/net/ethernet/seeq/sgiseeq.c
> index 39599bbb5d45b6..f91dae16d69a19 100644
> --- a/drivers/net/ethernet/seeq/sgiseeq.c
> +++ b/drivers/net/ethernet/seeq/sgiseeq.c
> @@ -112,14 +112,18 @@ struct sgiseeq_private {
>  
>  static inline void dma_sync_desc_cpu(struct net_device *dev, void *addr)
>  {
> -	dma_cache_sync(dev->dev.parent, addr, sizeof(struct sgiseeq_rx_desc),
> -		       DMA_FROM_DEVICE);
> +	struct sgiseeq_private *sp = netdev_priv(dev);
> +
> +	dma_sync_single_for_cpu(dev->dev.parent, VIRT_TO_DMA(sp, addr),
> +			sizeof(struct sgiseeq_rx_desc), DMA_BIDIRECTIONAL);
>  }
>  
>  static inline void dma_sync_desc_dev(struct net_device *dev, void *addr)
>  {
> -	dma_cache_sync(dev->dev.parent, addr, sizeof(struct sgiseeq_rx_desc),
> -		       DMA_TO_DEVICE);
> +	struct sgiseeq_private *sp = netdev_priv(dev);
> +
> +	dma_sync_single_for_device(dev->dev.parent, VIRT_TO_DMA(sp, addr),
> +			sizeof(struct sgiseeq_rx_desc), DMA_BIDIRECTIONAL);
>  }

this breaks ethernet on IP22 completely, but I haven't figured out why, yet.

Thomas.

-- 
Crap can work. Given enough thrust pigs will fly, but it's not necessarily a
good idea.                                                [ RFC1925, 2.3 ]
