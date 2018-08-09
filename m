From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Thu, 09 Aug 2018 00:27:46 +0000
Subject: Re: [PATCH 10/20] powerpc/dma-noncoherent: don't disable irqs over kmap_atomic
Message-Id: <bfa22816fee0759cfee28705b427be3586c7d2e3.camel@kernel.crashing.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180730163824.10064-1-hch@lst.de>
 <20180730163824.10064-11-hch@lst.de>
In-Reply-To: <20180730163824.10064-11-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Robin Murphy <robin.murphy@arm.com>, linuxppc-dev@lists.ozlabs.org, iommu@lists.linux-foundation.org, linux-ia64@vger.kernel.org

On Mon, 2018-07-30 at 18:38 +0200, Christoph Hellwig wrote:
> The requirement to disable local irqs over kmap_atomic is long gone,
> so remove those calls.

Really ? I'm trying to verify that and getting lost in a mess of macros
from hell in the per-cpu stuff but if you look at our implementation
of kmap_atomic_prot(), all it does is a preempt_disable(), and then
it uses kmap_atomic_idx_push():

	int idx = __this_cpu_inc_return(__kmap_atomic_idx) - 1;

Note the use of __this_cpu_inc_return(), not this_cpu_inc_return(),
ie this is the non-interrupt safe version...

Ben.

> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  arch/powerpc/mm/dma-noncoherent.c | 6 +-----
>  1 file changed, 1 insertion(+), 5 deletions(-)
> 
> diff --git a/arch/powerpc/mm/dma-noncoherent.c b/arch/powerpc/mm/dma-noncoherent.c
> index 382528475433..d1c16456abac 100644
> --- a/arch/powerpc/mm/dma-noncoherent.c
> +++ b/arch/powerpc/mm/dma-noncoherent.c
> @@ -357,12 +357,10 @@ static inline void __dma_sync_page_highmem(struct page *page,
>  {
>  	size_t seg_size = min((size_t)(PAGE_SIZE - offset), size);
>  	size_t cur_size = seg_size;
> -	unsigned long flags, start, seg_offset = offset;
> +	unsigned long start, seg_offset = offset;
>  	int nr_segs = 1 + ((size - seg_size) + PAGE_SIZE - 1)/PAGE_SIZE;
>  	int seg_nr = 0;
>  
> -	local_irq_save(flags);
> -
>  	do {
>  		start = (unsigned long)kmap_atomic(page + seg_nr) + seg_offset;
>  
> @@ -378,8 +376,6 @@ static inline void __dma_sync_page_highmem(struct page *page,
>  		cur_size += seg_size;
>  		seg_offset = 0;
>  	} while (seg_nr < nr_segs);
> -
> -	local_irq_restore(flags);
>  }
>  #endif /* CONFIG_HIGHMEM */
>  

