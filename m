From: Dave Jiang <dave.jiang@intel.com>
Date: Thu, 08 Jun 2017 16:32:18 +0000
Subject: Re: [PATCH 03/44] dmaengine: ioat: don't use DMA_ERROR_CODE
Message-Id: <bf0a16a3-75d9-25c9-98d3-f1e7624dc5d7@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170608132609.32662-1-hch@lst.de>
 <20170608132609.32662-4-hch@lst.de>
In-Reply-To: <20170608132609.32662-4-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

On 06/08/2017 06:25 AM, Christoph Hellwig wrote:
> DMA_ERROR_CODE is not a public API and will go away.  Instead properly
> unwind based on the loop counter.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Acked-by: Dave Jiang <dave.jiang@intel.com>

> ---
>  drivers/dma/ioat/init.c | 24 +++++++-----------------
>  1 file changed, 7 insertions(+), 17 deletions(-)
> 
> diff --git a/drivers/dma/ioat/init.c b/drivers/dma/ioat/init.c
> index 6ad4384b3fa8..ed8ed1192775 100644
> --- a/drivers/dma/ioat/init.c
> +++ b/drivers/dma/ioat/init.c
> @@ -839,8 +839,6 @@ static int ioat_xor_val_self_test(struct ioatdma_device *ioat_dma)
>  		goto free_resources;
>  	}
>  
> -	for (i = 0; i < IOAT_NUM_SRC_TEST; i++)
> -		dma_srcs[i] = DMA_ERROR_CODE;
>  	for (i = 0; i < IOAT_NUM_SRC_TEST; i++) {
>  		dma_srcs[i] = dma_map_page(dev, xor_srcs[i], 0, PAGE_SIZE,
>  					   DMA_TO_DEVICE);
> @@ -910,8 +908,6 @@ static int ioat_xor_val_self_test(struct ioatdma_device *ioat_dma)
>  
>  	xor_val_result = 1;
>  
> -	for (i = 0; i < IOAT_NUM_SRC_TEST + 1; i++)
> -		dma_srcs[i] = DMA_ERROR_CODE;
>  	for (i = 0; i < IOAT_NUM_SRC_TEST + 1; i++) {
>  		dma_srcs[i] = dma_map_page(dev, xor_val_srcs[i], 0, PAGE_SIZE,
>  					   DMA_TO_DEVICE);
> @@ -965,8 +961,6 @@ static int ioat_xor_val_self_test(struct ioatdma_device *ioat_dma)
>  	op = IOAT_OP_XOR_VAL;
>  
>  	xor_val_result = 0;
> -	for (i = 0; i < IOAT_NUM_SRC_TEST + 1; i++)
> -		dma_srcs[i] = DMA_ERROR_CODE;
>  	for (i = 0; i < IOAT_NUM_SRC_TEST + 1; i++) {
>  		dma_srcs[i] = dma_map_page(dev, xor_val_srcs[i], 0, PAGE_SIZE,
>  					   DMA_TO_DEVICE);
> @@ -1017,18 +1011,14 @@ static int ioat_xor_val_self_test(struct ioatdma_device *ioat_dma)
>  	goto free_resources;
>  dma_unmap:
>  	if (op = IOAT_OP_XOR) {
> -		if (dest_dma != DMA_ERROR_CODE)
> -			dma_unmap_page(dev, dest_dma, PAGE_SIZE,
> -				       DMA_FROM_DEVICE);
> -		for (i = 0; i < IOAT_NUM_SRC_TEST; i++)
> -			if (dma_srcs[i] != DMA_ERROR_CODE)
> -				dma_unmap_page(dev, dma_srcs[i], PAGE_SIZE,
> -					       DMA_TO_DEVICE);
> +		while (--i >= 0)
> +			dma_unmap_page(dev, dma_srcs[i], PAGE_SIZE,
> +				       DMA_TO_DEVICE);
> +		dma_unmap_page(dev, dest_dma, PAGE_SIZE, DMA_FROM_DEVICE);
>  	} else if (op = IOAT_OP_XOR_VAL) {
> -		for (i = 0; i < IOAT_NUM_SRC_TEST + 1; i++)
> -			if (dma_srcs[i] != DMA_ERROR_CODE)
> -				dma_unmap_page(dev, dma_srcs[i], PAGE_SIZE,
> -					       DMA_TO_DEVICE);
> +		while (--i >= 0)
> +			dma_unmap_page(dev, dma_srcs[i], PAGE_SIZE,
> +				       DMA_TO_DEVICE);
>  	}
>  free_resources:
>  	dma->device_free_chan_resources(dma_chan);
> 
