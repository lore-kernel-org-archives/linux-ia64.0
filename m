From: Robin Murphy <robin.murphy@arm.com>
Date: Wed, 10 Jan 2018 11:59:30 +0000
Subject: Re: [PATCH 20/33] dma-mapping: clear harmful GFP_* flags in common code
Message-Id: <27b90341-f9d0-356f-0194-1c7203a3f93e@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180110080027.13879-1-hch@lst.de>
	<20180110080027.13879-21-hch@lst.de>
In-Reply-To: <20180110080027.13879-21-hch-jcswGhMUV9g@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>, iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sparclinux-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Guan Xuetao <gxt-TG0Ac1+ktVePQbnJrJN+5g@public.gmane.org>, linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-c6x-dev-jPsnJVOj+W6hPH1hqNUYSQ@public.gmane.org, linux-hexagon-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, Konrad Rzeszutek Wilk <konrad-Gq0aWv8utHQdnm+yROfE0A@public.gmane.org>, linux-snps-arc-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-m68k-cunTk1MwBs8S/qaLPR03pWD2FQJk+8+b@public.gmane.org, patches-q3qR2WxjNRFS9aJRtSZj7A@public.gmane.org, linux-metag-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, Michal Simek <monstr-pSz03upnqPeHXe+LvDLADg@public.gmane.org>, linux-cris-kernel-VrBV9hrLPhE@public.gmane.org, linux-parisc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-alpha-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org

On 10/01/18 08:00, Christoph Hellwig wrote:
[...]
> diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
> index 9f28b2fa329e..88bcb1a8211d 100644
> --- a/include/linux/dma-mapping.h
> +++ b/include/linux/dma-mapping.h
> @@ -518,6 +518,13 @@ static inline void *dma_alloc_attrs(struct device *dev, size_t size,
>   	if (dma_alloc_from_dev_coherent(dev, size, dma_handle, &cpu_addr))
>   		return cpu_addr;
>   
> +	/*
> +	 * Let the implementation decide on the zone to allocate from, and
> +	 * decide on the way of zeroing the memory given that the memory
> +	 * returned should always be zeroed.
> +	 */

Just a note that if we're all happy to enshrine the "allocations are 
always zeroed" behaviour in the API (I am too, for the record), we 
should remember to follow up once the dust settles to update the docs 
and I guess just #define dma_zalloc_coherent dma_alloc_coherent.

Robin.

> +	flag &= ~(__GFP_DMA | __GFP_DMA32 | __GFP_HIGHMEM | __GFP_ZERO);
> +
>   	if (!arch_dma_alloc_attrs(&dev, &flag))
>   		return NULL;
>   	if (!ops->alloc)
> 
