From: Shuah Khan <shuah.khan@hp.com>
Date: Thu, 15 Nov 2012 18:08:47 +0000
Subject: Re: [PATCH RFT RESEND linux-next] ia64: dma-mapping: support debug_dma_mapping_error
Message-Id: <1353002927.2532.46.camel@lorien2>
List-Id: <linux-ia64.vger.kernel.org>
References: <1351207286.6851.13.camel@lorien2>
	 <1351266308.4013.5.camel@lorien2>
In-Reply-To: <1351266308.4013.5.camel@lorien2>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com, m.szyprowski@samsung.com
Cc: fenghua.yu@intel.com, arnd@arndb.de, andrzej.p@samsung.com, kyungmin.park@samsung.com, linux-ia64@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, shuahkhan@gmail.com

On Fri, 2012-10-26 at 09:45 -0600, Shuah Khan wrote:
> Add support for debug_dma_mapping_error() call to avoid warning from
> debug_dma_unmap() interface when it checks for mapping error checked
> status. Without this patch, device driver failed to check map error
> warning is generated.
> 
> Signed-off-by: Shuah Khan <shuah.khan@hp.com>
> ---
>  arch/ia64/include/asm/dma-mapping.h |    1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/arch/ia64/include/asm/dma-mapping.h b/arch/ia64/include/asm/dma-mapping.h
> index 4f5e814..cf3ab7e 100644
> --- a/arch/ia64/include/asm/dma-mapping.h
> +++ b/arch/ia64/include/asm/dma-mapping.h
> @@ -58,6 +58,7 @@ static inline void dma_free_attrs(struct device *dev, size_t size,
>  static inline int dma_mapping_error(struct device *dev, dma_addr_t daddr)
>  {
>  	struct dma_map_ops *ops = platform_dma_get_ops(dev);
> +	debug_dma_mapping_error(dev, daddr);
>  	return ops->mapping_error(dev, daddr);
>  }
>  

Marek,

This one is for ia64 to go through your tree with all the other arch
debug_dma_mapping_error() patches.

Thanks,
-- Shuah

