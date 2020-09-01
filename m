From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Tue, 01 Sep 2020 14:52:40 +0000
Subject: Re: [PATCH 07/28] 53c700: improve non-coherent DMA handling
Message-Id: <1598971960.4238.5.camel@HansenPartnership.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200819065555.1802761-1-hch@lst.de>
         <20200819065555.1802761-8-hch@lst.de>
In-Reply-To: <20200819065555.1802761-8-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>, Mauro Carvalho Chehab <mchehab@kernel.org>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Joonyoung Shim <jy0922.shim@samsung.com>, Seung-Woo Kim <sw0312.kim@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Ben Skeggs <bskeggs@redhat.com>, Pawel Osciak <pawel@osciak.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Matt Porter <mporter@kernel.crashing.org>, iommu@lists.linux-foundation.org
Cc: Tom Lendacky <thomas.lendacky@amd.com>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linux-samsung-soc@vger.kernel.org, nouveau@lists.freedesktop.org, netdev@vger.kernel.org, linux-nvme@lists.infradead.org, linux-scsi@vger.kernel.org, linux-mm@kvack.org, alsa-devel@alsa-project.org

On Wed, 2020-08-19 at 08:55 +0200, Christoph Hellwig wrote:
> Switch the 53c700 driver to only use non-coherent descriptor memory
> if it really has to because dma_alloc_coherent fails.  This doesn't
> matter for any of the platforms it runs on currently, but that will
> change soon.
> 
> To help with this two new helpers to transfer ownership to and from
> the device are added that abstract the syncing of the non-coherent
> memory. The two current bidirectional cases are mapped to transfers
> to the device, as that appears to what they are used for.  Note that
> for parisc, which is the only architecture this driver needs to use
> non-coherent memory on, the direction argument of dma_cache_sync is
> ignored, so this will not change behavior in any way.

I think this looks mostly OK, except for one misnamed parameter below. 
Unfortunately, the last non-coherent parisc was the 700 series and I no
longer own a box, so I can't test that part of it (I can fire up the
C360 to test it on a coherent arch).

[...]
> diff --git a/drivers/scsi/53c700.h b/drivers/scsi/53c700.h
> index 05fe439b66afe5..0f545b05fe611d 100644
> --- a/drivers/scsi/53c700.h
> +++ b/drivers/scsi/53c700.h
> @@ -209,6 +209,7 @@ struct NCR_700_Host_Parameters {
>  #endif
>  	__u32	chip710:1;	/* set if really a 710 not
> 700 */
>  	__u32	burst_length:4;	/* set to 0 to disable
> 710 bursting */
> +	__u32	noncoherent:1;	/* needs to use non-
> coherent DMA */
>  
>  	/* NOTHING BELOW HERE NEEDS ALTERING */
>  	__u32	fast:1;		/* if we can alter the
> SCSI bus clock
> @@ -429,7 +430,7 @@ struct NCR_700_Host_Parameters {
>  	for(i=0; i< (sizeof(A_##symbol##_used) / sizeof(__u32));
> i++) { \
>  		__u32 val > bS_to_cpu((script)[A_##symbol##_used[i]]) + da; \
>  		(script)[A_##symbol##_used[i]] = bS_to_host(val); \
> -		dma_cache_sync((dev),
> &(script)[A_##symbol##_used[i]], 4, DMA_TO_DEVICE); \
> +		dma_sync_to_dev((dev),
> &(script)[A_##symbol##_used[i]], 4); \
>  		DEBUG((" script, patching %s at %d to %pad\n", \
>  		       #symbol, A_##symbol##_used[i], &da)); \
>  	} \
> @@ -441,7 +442,7 @@ struct NCR_700_Host_Parameters {
>  	dma_addr_t da = value; \
>  	for(i=0; i< (sizeof(A_##symbol##_used) / sizeof(__u32));
> i++) { \
>  		(script)[A_##symbol##_used[i]] = bS_to_host(da); \
> -		dma_cache_sync((dev),
> &(script)[A_##symbol##_used[i]], 4, DMA_TO_DEVICE); \
> +		dma_sync_to_dev((dev),
> &(script)[A_##symbol##_used[i]], 4); \
>  		DEBUG((" script, patching %s at %d to %pad\n", \
>  		       #symbol, A_##symbol##_used[i], &da)); \
>  	} \
> @@ -456,7 +457,7 @@ struct NCR_700_Host_Parameters {
>  		val &= 0xff00ffff; \
>  		val |= ((value) & 0xff) << 16; \
>  		(script)[A_##symbol##_used[i]] = bS_to_host(val); \
> -		dma_cache_sync((dev),
> &(script)[A_##symbol##_used[i]], 4, DMA_TO_DEVICE); \
> +		dma_sync_to_dev((dev),
> &(script)[A_##symbol##_used[i]], 4); \
>  		DEBUG((" script, patching ID field %s at %d to
> 0x%x\n", \
>  		       #symbol, A_##symbol##_used[i], val)); \
>  	} \
> @@ -470,7 +471,7 @@ struct NCR_700_Host_Parameters {
>  		val &= 0xffff0000; \
>  		val |= ((value) & 0xffff); \
>  		(script)[A_##symbol##_used[i]] = bS_to_host(val); \
> -		dma_cache_sync((dev),
> &(script)[A_##symbol##_used[i]], 4, DMA_TO_DEVICE); \
> +		dma_sync_to_dev((dev),
> &(script)[A_##symbol##_used[i]], 4); \
>  		DEBUG((" script, patching short field %s at %d to
> 0x%x\n", \
>  		       #symbol, A_##symbol##_used[i], val)); \
>  	} \

These macro arguments need updating.  Since you changed the input from
hostdata->dev to hostdata, leaving the macro argument as dev is simply
misleading.  It needs to become hostdata or h.

James
