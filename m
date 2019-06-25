From: Frank Scheiner <frank.scheiner@web.de>
Date: Tue, 25 Jun 2019 07:26:01 +0000
Subject: Re: Regression in 543cea9a - was: Re: Kernel problem on rx2800 i2
Message-Id: <5939b8fa-8f3b-fa30-aeb0-d19c6baf89da@web.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1d62aadd-67b6-da13-53cc-4b5213de8937@physik.fu-berlin.de>
In-Reply-To: <1d62aadd-67b6-da13-53cc-4b5213de8937@physik.fu-berlin.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 6/25/19 08:59, Christoph Hellwig wrote:
> On Tue, Jun 25, 2019 at 08:54:11AM +0200, John Paul Adrian Glaubitz wrote:
>> Okay, thanks. I'll whip up a patch for Frank to test.
>
> The one below should do it, but from looking at the ia64 zone
> initialization I'm not sure this will be the culprit.
>
> diff --git a/kernel/dma/direct.c b/kernel/dma/direct.c
> index 2c2772e9702a..3e802f4580b3 100644
> --- a/kernel/dma/direct.c
> +++ b/kernel/dma/direct.c
> @@ -82,9 +82,7 @@ static gfp_t __dma_direct_optimal_gfp_mask(struct device *dev, u64 dma_mask,
>   	 */
>   	if (*phys_mask <= DMA_BIT_MASK(ARCH_ZONE_DMA_BITS))
>   		return GFP_DMA;
> -	if (*phys_mask <= DMA_BIT_MASK(32))
> -		return GFP_DMA32;
> -	return 0;
> +	return GFP_DMA32;
>   }
>
>   static bool dma_coherent_ok(struct device *dev, phys_addr_t phys, size_t size)
>

Ok, will apply that to the most recent non-rc kernel source and give it
a try. Should take about 45 mins or so.

Cheers,
Frank
