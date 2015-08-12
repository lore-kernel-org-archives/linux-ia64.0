From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Date: Wed, 12 Aug 2015 10:28:55 +0000
Subject: Re: [PATCH 19/31] arc: handle page-less SG entries
Message-Id: <C2D7FE5348E1B147BCA15975FBA23075665B21F5@IN01WEMBXB.internal.synopsys.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1439363150-8661-1-git-send-email-hch@lst.de>
 <1439363150-8661-20-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, "axboe@kernel.dk" <axboe@kernel.dk>
Cc: "dan.j.williams@intel.com" <dan.j.williams@intel.com>, "hskinnemoen@gmail.com" <hskinnemoen@gmail.com>, "egtvedt@samfundet.no" <egtvedt@samfundet.no>, "realmz6@gmail.com" <realmz6@gmail.com>, "dhowells@redhat.com" <dhowells@redhat.com>, "monstr@monstr.eu" <monstr@monstr.eu>, "x86@kernel.org" <x86@kernel.org>, "dwmw2@infradead.org" <dwmw2@infradead.org>, "alex.williamson@redhat.com" <alex.williamson@redhat.com>, "grundler@parisc-linux.org" <grundler@parisc-linux.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-alpha@vger.kernel.org" <linux-alpha@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-metag@vger.kernel.org" <linux-metag@vger.kernel.org>, "linux-mips@linux-mips.org" <linux-mips@linux-mips.org>, "linux-parisc@vger.kernel.org" <linux-parisc@vge>

On Wednesday 12 August 2015 12:39 PM, Christoph Hellwig wrote:
> Make all cache invalidation conditional on sg_has_page() and use
> sg_phys to get the physical address directly.
>
> Signed-off-by: Christoph Hellwig <hch@lst.de>

With a minor nit below.

Acked-by: Vineet Gupta <vgupta@synopsys.com>

> ---
>  arch/arc/include/asm/dma-mapping.h | 26 +++++++++++++++++++-------
>  1 file changed, 19 insertions(+), 7 deletions(-)
>
> diff --git a/arch/arc/include/asm/dma-mapping.h b/arch/arc/include/asm/dma-mapping.h
> index 2d28ba9..42eb526 100644
> --- a/arch/arc/include/asm/dma-mapping.h
> +++ b/arch/arc/include/asm/dma-mapping.h
> @@ -108,9 +108,13 @@ dma_map_sg(struct device *dev, struct scatterlist *sg,
>  	struct scatterlist *s;
>  	int i;
>  
> -	for_each_sg(sg, s, nents, i)
> -		s->dma_address = dma_map_page(dev, sg_page(s), s->offset,
> -					       s->length, dir);
> +	for_each_sg(sg, s, nents, i) {
> +		if (sg_has_page(s)) {
> +			_dma_cache_sync((unsigned long)sg_virt(s), s->length,
> +					dir);
> +		}
> +		s->dma_address = sg_phys(s);
> +	}
>  
>  	return nents;
>  }
> @@ -163,8 +167,12 @@ dma_sync_sg_for_cpu(struct device *dev, struct scatterlist *sglist, int nelems,
>  	int i;
>  	struct scatterlist *sg;
>  
> -	for_each_sg(sglist, sg, nelems, i)
> -		_dma_cache_sync((unsigned int)sg_virt(sg), sg->length, dir);
> +	for_each_sg(sglist, sg, nelems, i) {
> +		if (sg_has_page(sg)) {
> +			_dma_cache_sync((unsigned int)sg_virt(sg), sg->length,
> +					dir);
> +		}
> +	}
>  }
>  
>  static inline void
> @@ -174,8 +182,12 @@ dma_sync_sg_for_device(struct device *dev, struct scatterlist *sglist,
>  	int i;
>  	struct scatterlist *sg;
>  
> -	for_each_sg(sglist, sg, nelems, i)
> -		_dma_cache_sync((unsigned int)sg_virt(sg), sg->length, dir);
> +	for_each_sg(sglist, sg, nelems, i) {
> +		if (sg_has_page(sg)) {
> +			_dma_cache_sync((unsigned int)sg_virt(sg), sg->length,
> +				dir);

For consistency, could u please fix the left alignment of @dir above - another tab
perhaps ?

> +		}
> +	}
>  }
>  
>  static inline int dma_supported(struct device *dev, u64 dma_mask)

