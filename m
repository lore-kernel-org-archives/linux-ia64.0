From: Thomas Gleixner <tglx@linutronix.de>
Date: Thu, 31 Aug 2017 14:06:53 +0000
Subject: Re: [PATCH 04/12] x86: make dma_cache_sync a no-op
Message-Id: <alpine.DEB.2.20.1708311606340.1874@nanos>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170827161032.22772-1-hch@lst.de>
	<20170827161032.22772-5-hch@lst.de>
In-Reply-To: <20170827161032.22772-5-hch-jcswGhMUV9g@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
Cc: Chris Zankel <chris-YvXeqwSYzG2sTnJN9+BGXg@public.gmane.org>, Michal Simek <monstr-pSz03upnqPeHXe+LvDLADg@public.gmane.org>, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-xtensa-PjhNF2WwrV/0Sa2dR60CXw@public.gmane.org, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Max Filippov <jcmvbkbc-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Guan Xuetao <gxt-TG0Ac1+ktVePQbnJrJN+5g@public.gmane.org>

On Sun, 27 Aug 2017, Christoph Hellwig wrote:

> x86 does not implement DMA_ATTR_NON_CONSISTENT allocations, so it doesn't
> make any sense to do any work in dma_cache_sync given that it must be a
> no-op when dma_alloc_attrs returns coherent memory.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de

Reviewed-by: Thomas Gleixner <tglx@linutronix.de>

> ---
>  arch/x86/include/asm/dma-mapping.h | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/arch/x86/include/asm/dma-mapping.h b/arch/x86/include/asm/dma-mapping.h
> index 398c79889f5c..04877267ad18 100644
> --- a/arch/x86/include/asm/dma-mapping.h
> +++ b/arch/x86/include/asm/dma-mapping.h
> @@ -70,7 +70,6 @@ static inline void
>  dma_cache_sync(struct device *dev, void *vaddr, size_t size,
>  	enum dma_data_direction dir)
>  {
> -	flush_write_buffers();
>  }
>  
>  static inline unsigned long dma_alloc_coherent_mask(struct device *dev,
> -- 
> 2.11.0
> 
> 
