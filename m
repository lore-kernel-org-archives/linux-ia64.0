From: Christoph Hellwig <hch@lst.de>
Date: Tue, 03 Oct 2017 10:43:00 +0000
Subject: refactor dma_cache_sync V2
Message-Id: <20171003104311.10058-1-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: Chris Zankel <chris-YvXeqwSYzG2sTnJN9+BGXg@public.gmane.org>, Michal Simek <monstr-pSz03upnqPeHXe+LvDLADg@public.gmane.org>, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-xtensa-PjhNF2WwrV/0Sa2dR60CXw@public.gmane.org, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Max Filippov <jcmvbkbc-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Guan Xuetao <gxt-TG0Ac1+ktVePQbnJrJN+5g@public.gmane.org>

The dma_cache_sync routines is used to flush caches for memory returned
by dma_alloc_attrs with the DMA_ATTR_NON_CONSISTENT flag (or previously
from dma_alloc_noncoherent), but the requirements for it seems to be
frequently misunderstood.  dma_cache_sync is documented to be a no-op for
allocations that do not have the DMA_ATTR_NON_CONSISTENT flag set, and
yet a lot of architectures implement it in some way despite not
implementing DMA_ATTR_NON_CONSISTENT.

This series removes a few abuses of dma_cache_sync for non-DMA API
purposes, then changes all remaining architectures that do not implement
DMA_ATTR_NON_CONSISTENT to implement dma_cache_sync as a no-op, and
then adds the struct dma_map_ops indirection we use for all other
DMA mapping operations to dma_cache_sync as well, thus removing all but
two implementations of the function.

Changes since V1:
 - drop the mips fd_cacheflush, merged via maintainer
 - spelling fix in last commit descriptions (thanks Geert)
