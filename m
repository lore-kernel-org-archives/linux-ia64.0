From: Robin Murphy <robin.murphy@arm.com>
Date: Wed, 10 Jan 2018 14:56:01 +0000
Subject: Re: [PATCH 11/33] dma-mapping: move swiotlb arch helpers to a new header
Message-Id: <3721b4ba-0685-255e-06b9-6e60678a1a92@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180110080027.13879-1-hch@lst.de>
	<20180110080027.13879-12-hch@lst.de>
In-Reply-To: <20180110080027.13879-12-hch-jcswGhMUV9g@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>, iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sparclinux-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Guan Xuetao <gxt-TG0Ac1+ktVePQbnJrJN+5g@public.gmane.org>, linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-c6x-dev-jPsnJVOj+W6hPH1hqNUYSQ@public.gmane.org, linux-hexagon-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, Konrad Rzeszutek Wilk <konrad-Gq0aWv8utHQdnm+yROfE0A@public.gmane.org>, linux-snps-arc-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-m68k-cunTk1MwBs8S/qaLPR03pWD2FQJk+8+b@public.gmane.org, patches-q3qR2WxjNRFS9aJRtSZj7A@public.gmane.org, linux-metag-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, Michal Simek <monstr-pSz03upnqPeHXe+LvDLADg@public.gmane.org>, linux-cris-kernel-VrBV9hrLPhE@public.gmane.org, linux-parisc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-alpha-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org

On 10/01/18 08:00, Christoph Hellwig wrote:
> phys_to_dma, dma_to_phys and dma_capable are helpers published by
> architecture code for use of swiotlb and xen-swiotlb only.  Drivers are
> not supposed to use these directly, but use the DMA API instead.
> 
> Move these to a new asm/dma-direct.h helper, included by a
> linux/dma-direct.h wrapper that provides the default linear mapping
> unless the architecture wants to override it.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
[...]
>   drivers/crypto/marvell/cesa.c                      |  1 +
>   drivers/mtd/nand/qcom_nandc.c                      |  1 +

I took a look at these, and it seems their phys_to_dma() usage is doing 
the thing which we subsequently formalised as dma_map_resource(). I've 
had a crack at a quick patch to update the CESA driver; qcom_nandc looks 
slightly more complex in that the changes probably need to span the BAM 
dmaengine driver as well.

In the process, though, I stumbled across gen_pool_dma_alloc() - yuck, 
something needs doing there, for sure...

Robin.
