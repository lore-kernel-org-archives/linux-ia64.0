From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Thu, 09 Aug 2018 00:14:17 +0000
Subject: Re: [PATCH 09/20] powerpc/dma: remove the unused ISA_DMA_THRESHOLD export
Message-Id: <eebe8416aa668740945dca6b271268b464aac02a.camel@kernel.crashing.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180730163824.10064-1-hch@lst.de>
 <20180730163824.10064-10-hch@lst.de>
In-Reply-To: <20180730163824.10064-10-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Robin Murphy <robin.murphy@arm.com>, linuxppc-dev@lists.ozlabs.org, iommu@lists.linux-foundation.org, linux-ia64@vger.kernel.org

On Mon, 2018-07-30 at 18:38 +0200, Christoph Hellwig wrote:
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Acked-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>


> ---
>  arch/powerpc/kernel/setup_32.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/arch/powerpc/kernel/setup_32.c b/arch/powerpc/kernel/setup_32.c
> index 74457485574b..3c2d093f74c7 100644
> --- a/arch/powerpc/kernel/setup_32.c
> +++ b/arch/powerpc/kernel/setup_32.c
> @@ -55,7 +55,6 @@ unsigned long ISA_DMA_THRESHOLD;
>  unsigned int DMA_MODE_READ;
>  unsigned int DMA_MODE_WRITE;
>  
> -EXPORT_SYMBOL(ISA_DMA_THRESHOLD);
>  EXPORT_SYMBOL(DMA_MODE_READ);
>  EXPORT_SYMBOL(DMA_MODE_WRITE);
>  fooBenjam

