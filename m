From: Robin Murphy <robin.murphy@arm.com>
Date: Tue, 03 Oct 2017 11:49:51 +0000
Subject: Re: refactor dma_cache_sync V2
Message-Id: <87817c6a-b03f-6da0-4e69-22ea68d44bd5@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171003104311.10058-1-hch@lst.de>
In-Reply-To: <20171003104311.10058-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>, iommu@lists.linux-foundation.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Michal Simek <monstr@monstr.eu>, David Howells <dhowells@redhat.com>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, x86@kernel.org, linux-mips@linux-mips.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-xtensa@linux-xtensa.org, linux-sh@vger.kernel.org, linux-kernel@vger.kernel.org

On 03/10/17 11:43, Christoph Hellwig wrote:
> The dma_cache_sync routines is used to flush caches for memory returned
> by dma_alloc_attrs with the DMA_ATTR_NON_CONSISTENT flag (or previously
> from dma_alloc_noncoherent), but the requirements for it seems to be
> frequently misunderstood.  dma_cache_sync is documented to be a no-op for
> allocations that do not have the DMA_ATTR_NON_CONSISTENT flag set, and
> yet a lot of architectures implement it in some way despite not
> implementing DMA_ATTR_NON_CONSISTENT.
> 
> This series removes a few abuses of dma_cache_sync for non-DMA API
> purposes, then changes all remaining architectures that do not implement
> DMA_ATTR_NON_CONSISTENT to implement dma_cache_sync as a no-op, and
> then adds the struct dma_map_ops indirection we use for all other
> DMA mapping operations to dma_cache_sync as well, thus removing all but
> two implementations of the function.
> 
> Changes since V1:
>  - drop the mips fd_cacheflush, merged via maintainer
>  - spelling fix in last commit descriptions (thanks Geert)
> 

For the series,

Reviewed-by: Robin Murphy <robin.murphy@arm.com>

The MIPS DMA ops are a little fiddly, but I've satisfied myself that
CONFIG_DMA_NONCOHERENT and CONFIG_SWIOTLB are mutually exclusive for
Loongson64 such that patch #11 isn't missing anything.

Robin.
