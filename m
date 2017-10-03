From: Thomas Gleixner <tglx@linutronix.de>
Date: Tue, 03 Oct 2017 20:27:08 +0000
Subject: RE: [PATCH 02/11] x86: make dma_cache_sync a no-op
Message-Id: <alpine.DEB.2.20.1710032214370.2278@nanos>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171003104311.10058-1-hch@lst.de>
	<20171003104311.10058-3-hch@lst.de>
	<063D6719AE5E284EB5DD2968C1650D6DD0088B73@AcuExch.aculab.com>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DD0088B73-VkEWCZq2GCInGFn1LkZF6NBPR1lH4CV8@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Cc: Chris Zankel <chris-YvXeqwSYzG2sTnJN9+BGXg@public.gmane.org>, Michal Simek <monstr-pSz03upnqPeHXe+LvDLADg@public.gmane.org>, "x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org" <x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, "linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org" <linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org>, "linux-xtensa-PjhNF2WwrV/0Sa2dR60CXw@public.gmane.org" <linux-xtensa-PjhNF2WwrV/0Sa2dR60CXw@public.gmane.org>, "linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Max Filippov <jcmvbkbc-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, "iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Guan Xuetao <gxt-TG0Ac1+ktVePQbnJrJN+5g@public.gmane.org>, "linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org" <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>, 'Christoph Hellwig' <hch-jcswGhMUV9g@public.gmane.org>

On Tue, 3 Oct 2017, David Laight wrote:

> From: Christoph Hellwig
> > Sent: 03 October 2017 11:43
> > x86 does not implement DMA_ATTR_NON_CONSISTENT allocations, so it doesn't
> > make any sense to do any work in dma_cache_sync given that it must be a
> > no-op when dma_alloc_attrs returns coherent memory.
> 
> I believe it is just about possible to require an explicit
> write flush on x86.
> ISTR this can happen with something like write combining.

As the changelog says: x86 only implements dma_alloc_coherent() which as
the name says returns coherent memory, i.e. type WB (write back), which is
not subject to dma_cache_sync() operations.

If the driver converts that memory to WC (write combine) on its own via
PAT/MTRR, then it needs to take care of flushing the write buffer on its
own. It's not convered by this interface.

Thanks,

	tglx

