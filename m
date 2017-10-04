From: David Laight <David.Laight@ACULAB.COM>
Date: Wed, 04 Oct 2017 08:59:24 +0000
Subject: RE: [PATCH 04/11] ia64: make dma_cache_sync a no-op
Message-Id: <063D6719AE5E284EB5DD2968C1650D6DD0089626@AcuExch.aculab.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171003104311.10058-1-hch@lst.de>
	<20171003104311.10058-5-hch@lst.de>
In-Reply-To: <20171003104311.10058-5-hch-jcswGhMUV9g@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Christoph Hellwig' <hch-jcswGhMUV9g@public.gmane.org>, "iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Cc: Chris Zankel <chris-YvXeqwSYzG2sTnJN9+BGXg@public.gmane.org>, Michal Simek <monstr-pSz03upnqPeHXe+LvDLADg@public.gmane.org>, "linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "linux-xtensa-PjhNF2WwrV/0Sa2dR60CXw@public.gmane.org" <linux-xtensa-PjhNF2WwrV/0Sa2dR60CXw@public.gmane.org>, "x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org" <x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Max Filippov <jcmvbkbc-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, "linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org" <linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org>, Guan Xuetao <gxt-TG0Ac1+ktVePQbnJrJN+5g@public.gmane.org>, "linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org" <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>

From: Christoph Hellwig
> Sent: 03 October 2017 11:43
>
> ia64 does not implement DMA_ATTR_NON_CONSISTENT allocations, so it doesn't
> make any sense to do any work in dma_cache_sync given that it must be a
> no-op when dma_alloc_attrs returns coherent memory.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  arch/ia64/include/asm/dma-mapping.h | 5 -----
>  1 file changed, 5 deletions(-)
> 
> diff --git a/arch/ia64/include/asm/dma-mapping.h b/arch/ia64/include/asm/dma-mapping.h
> index 3ce5ab4339f3..99dfc1aa9d3c 100644
> --- a/arch/ia64/include/asm/dma-mapping.h
> +++ b/arch/ia64/include/asm/dma-mapping.h
> @@ -48,11 +48,6 @@ static inline void
>  dma_cache_sync (struct device *dev, void *vaddr, size_t size,
>  	enum dma_data_direction dir)
>  {
> -	/*
> -	 * IA-64 is cache-coherent, so this is mostly a no-op.  However, we do need to
> -	 * ensure that dma_cache_sync() enforces order, hence the mb().
> -	 */
> -	mb();
>  }

Are you sure about this one?
It looks as though you are doing a mechanical change for all architectures.
Some of them are probably stranger than you realise.

Even with cache coherent memory any cpu 'store/write buffer' may not
be snooped by dma reads.

Something needs to flush the store buffer between the last cpu write
to the dma buffer and the write (probably a device register) that
tells the device it can read the memory.

My guess from the comment is that dma_cache_synch() is expected to
include that barrier - and it might not be anywhere else.

	David

