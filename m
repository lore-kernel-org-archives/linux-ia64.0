From: David Laight <David.Laight@ACULAB.COM>
Date: Tue, 03 Oct 2017 16:02:10 +0000
Subject: RE: [PATCH 02/11] x86: make dma_cache_sync a no-op
Message-Id: <063D6719AE5E284EB5DD2968C1650D6DD0088B73@AcuExch.aculab.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171003104311.10058-1-hch@lst.de>
 <20171003104311.10058-3-hch@lst.de>
In-Reply-To: <20171003104311.10058-3-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Christoph Hellwig' <hch@lst.de>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>
Cc: Chris Zankel <chris@zankel.net>, Michal Simek <monstr@monstr.eu>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-mips@linux-mips.org" <linux-mips@linux-mips.org>, "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "linux-xtensa@linux-xtensa.org" <linux-xtensa@linux-xtensa.org>, "x86@kernel.org" <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, David Howells <dhowells@redhat.com>, Max Filippov <jcmvbkbc@gmail.com>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Robin Murphy <robin.murphy@arm.com>, Marek Szyprowski <m.szyprowski@samsung.com>

From: Christoph Hellwig
> Sent: 03 October 2017 11:43
> x86 does not implement DMA_ATTR_NON_CONSISTENT allocations, so it doesn't
> make any sense to do any work in dma_cache_sync given that it must be a
> no-op when dma_alloc_attrs returns coherent memory.

I believe it is just about possible to require an explicit
write flush on x86.
ISTR this can happen with something like write combining.

Whether this can actually happen is the kernel is another matter.

	David

