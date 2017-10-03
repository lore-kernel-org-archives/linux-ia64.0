From: Christoph Hellwig <hch@lst.de>
Date: Tue, 03 Oct 2017 11:43:30 +0000
Subject: Re: [PATCH 07/11] powerpc: make dma_cache_sync a no-op
Message-Id: <20171003114330.GA24592@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171003104311.10058-1-hch@lst.de> <20171003104311.10058-8-hch@lst.de> <670a0571-1a36-51a3-db52-64bc61184c35@c-s.fr>
In-Reply-To: <670a0571-1a36-51a3-db52-64bc61184c35@c-s.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christophe LEROY <christophe.leroy@c-s.fr>
Cc: Christoph Hellwig <hch@lst.de>, iommu@lists.linux-foundation.org, Chris Zankel <chris@zankel.net>, Michal Simek <monstr@monstr.eu>, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linux-sh@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-xtensa@linux-xtensa.org, x86@kernel.org, linux-kernel@vger.kernel.org, David Howells <dhowells@redhat.com>, Max Filippov <jcmvbkbc@gmail.com>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Robin Murphy <robin.murphy@arm.com>, Marek Szyprowski <m.szyprowski@samsung.com>

On Tue, Oct 03, 2017 at 01:24:57PM +0200, Christophe LEROY wrote:
>> powerpc does not implement DMA_ATTR_NON_CONSISTENT allocations, so it
>> doesn't make any sense to do any work in dma_cache_sync given that it
>> must be a no-op when dma_alloc_attrs returns coherent memory.
> What about arch/powerpc/mm/dma-noncoherent.c ?
>
> Powerpc 8xx doesn't have coherent memory.

It doesn't implement the DMA_ATTR_NON_CONSISTENT interface either,
so if it really doesn't have a way to provide dma coherent allocation
(although the code in __dma_alloc_coherent suggests it does provide
dma coherent allocations) I have no idea how it could ever have
worked.
