From: Konrad Rzeszutek Wilk <konrad@darnok.org>
Date: Fri, 12 Jan 2018 13:16:48 +0000
Subject: Re: [PATCH 19/33] dma-mapping: warn when there is no coherent_dma_mask
Message-Id: <20180112131646.GA26900@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180110080027.13879-1-hch@lst.de>
	<20180110080027.13879-20-hch@lst.de>
In-Reply-To: <20180110080027.13879-20-hch-jcswGhMUV9g@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
Cc: linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sparclinux-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Guan Xuetao <gxt-TG0Ac1+ktVePQbnJrJN+5g@public.gmane.org>, linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-c6x-dev-jPsnJVOj+W6hPH1hqNUYSQ@public.gmane.org, linux-hexagon-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-snps-arc-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-m68k-cunTk1MwBs8S/qaLPR03pWD2FQJk+8+b@public.gmane.org, patches-q3qR2WxjNRFS9aJRtSZj7A@public.gmane.org, linux-metag-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, Michal Simek <monstr-pSz03upnqPeHXe+LvDLADg@public.gmane.org>, linux-parisc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-cris-kernel-VrBV9hrLPhE@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-alpha-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org

On Wed, Jan 10, 2018 at 09:00:13AM +0100, Christoph Hellwig wrote:
> These days all devices should have a DMA coherent mask, and most dma_ops
> implementations rely on that fact.  But just to be sure add an assert to
> ring the warning bell if that is not the case.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> ---
>  include/linux/dma-mapping.h | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
> index d84951865be7..9f28b2fa329e 100644
> --- a/include/linux/dma-mapping.h
> +++ b/include/linux/dma-mapping.h
> @@ -513,6 +513,7 @@ static inline void *dma_alloc_attrs(struct device *dev, size_t size,
>  	void *cpu_addr;
>  
>  	BUG_ON(!ops);
> +	WARN_ON_ONCE(!dev->coherent_dma_mask);
>  
>  	if (dma_alloc_from_dev_coherent(dev, size, dma_handle, &cpu_addr))
>  		return cpu_addr;
> -- 
> 2.14.2
> 
