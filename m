From: Robin Murphy <robin.murphy@arm.com>
Date: Tue, 03 Oct 2017 11:43:07 +0000
Subject: Re: [PATCH 07/11] powerpc: make dma_cache_sync a no-op
Message-Id: <1dcf9810-6e9f-c32f-a416-b114d1992ade@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171003104311.10058-1-hch@lst.de>
 <20171003104311.10058-8-hch@lst.de>
 <670a0571-1a36-51a3-db52-64bc61184c35@c-s.fr>
In-Reply-To: <670a0571-1a36-51a3-db52-64bc61184c35@c-s.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Christophe LEROY <christophe.leroy@c-s.fr>, Christoph Hellwig <hch@lst.de>, iommu@lists.linux-foundation.org
Cc: Chris Zankel <chris@zankel.net>, Michal Simek <monstr@monstr.eu>, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linux-sh@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-xtensa@linux-xtensa.org, x86@kernel.org, linux-kernel@vger.kernel.org, David Howells <dhowells@redhat.com>, Max Filippov <jcmvbkbc@gmail.com>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Marek Szyprowski <m.szyprowski@samsung.com>

On 03/10/17 12:24, Christophe LEROY wrote:
> 
> 
> Le 03/10/2017 à 12:43, Christoph Hellwig a écrit :
>> powerpc does not implement DMA_ATTR_NON_CONSISTENT allocations, so it
>> doesn't make any sense to do any work in dma_cache_sync given that it
>> must be a no-op when dma_alloc_attrs returns coherent memory.
> What about arch/powerpc/mm/dma-noncoherent.c ?

AFAICS, just like the ARM code from which it is derived, that will
always return a non-cacheable remap of the allocation, which should thus
not require explicit maintenance after CPU accesses. dma_cache_sync()
would only matter if dma_alloc_attrs(..., DMA_ATTR_NON_CONSISTENT) got
special treatment and was allowed to return a cacheable address, but PPC
doesn't even propagate the attrs to its internal __dma_alloc_coherent()
implementations.

Robin.

> Powerpc 8xx doesn't have coherent memory.
> 
> Christophe
> 
>>
>> Signed-off-by: Christoph Hellwig <hch@lst.de>
>> ---
>>   arch/powerpc/include/asm/dma-mapping.h | 2 --
>>   1 file changed, 2 deletions(-)
>>
>> diff --git a/arch/powerpc/include/asm/dma-mapping.h
>> b/arch/powerpc/include/asm/dma-mapping.h
>> index eaece3d3e225..320846442bfb 100644
>> --- a/arch/powerpc/include/asm/dma-mapping.h
>> +++ b/arch/powerpc/include/asm/dma-mapping.h
>> @@ -144,8 +144,6 @@ static inline phys_addr_t dma_to_phys(struct
>> device *dev, dma_addr_t daddr)
>>   static inline void dma_cache_sync(struct device *dev, void *vaddr,
>> size_t size,
>>           enum dma_data_direction direction)
>>   {
>> -    BUG_ON(direction = DMA_NONE);
>> -    __dma_sync(vaddr, size, (int)direction);
>>   }
>>     #endif /* __KERNEL__ */
>>

