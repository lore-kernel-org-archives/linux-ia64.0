From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Tue, 02 Jun 2009 04:08:10 +0000
Subject: Re: [PATCH 01/11] ia64: introduce arch-specific dma-mapping
Message-Id: <20090602130830A.fujita.tomonori@lab.ntt.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <1243870383-12954-1-git-send-email-ian.campbell@citrix.com>
	<1243870383-12954-2-git-send-email-ian.campbell@citrix.com>
In-Reply-To: <1243870383-12954-2-git-send-email-ian.campbell@citrix.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: ian.campbell@citrix.com
Cc: linux-kernel@vger.kernel.org, fujita.tomonori@lab.ntt.co.jp, mingo@elte.hu, jeremy@goop.org, tony.luck@intel.com, linux-ia64@vger.kernel.org

On Mon, 1 Jun 2009 16:32:53 +0100
Ian Campbell <ian.campbell@citrix.com> wrote:

> dma_map_range is intended to replace usage of both
> swiotlb_arch_range_needs_mapping and
> swiotlb_arch_address_needs_mapping as __weak functions as well as
> replacing is_buffer_dma_capable.
> 
> phys_to_dma and dma_to_phys are intended to replace
> swiotlb_phys_to_bus and swiotlb_bus_to_phys.  I choose to use dma
> rather than bus since a) it matches the parameters and b) avoids
> confusion on x86 with the existing (but deprecated) virt_to_bus
> function which relates to ISA device DMA.
> 
> Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
> Cc: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
> Cc: Ingo Molnar <mingo@elte.hu>
> Cc: Jeremy Fitzhardinge <jeremy@goop.org>
> Cc: Tony Luck <tony.luck@intel.com>
> Cc: linux-ia64@vger.kernel.org
> ---
>  arch/ia64/include/asm/dma-mapping.h |   23 +++++++++++++++++++++++
>  1 files changed, 23 insertions(+), 0 deletions(-)
> 
> diff --git a/arch/ia64/include/asm/dma-mapping.h b/arch/ia64/include/asm/dma-mapping.h
> index 36c0009..47d4107 100644
> --- a/arch/ia64/include/asm/dma-mapping.h
> +++ b/arch/ia64/include/asm/dma-mapping.h
> @@ -174,4 +174,27 @@ dma_cache_sync (struct device *dev, void *vaddr, size_t size,
>  
>  #define dma_is_consistent(d, h)	(1)	/* all we do is coherent memory... */
>  
> +static inline dma_addr_t phys_to_dma(struct device *hwdev, phys_addr_t paddr)
> +{
> +	return paddr;
> +}
> +
> +static inline phys_addr_t dma_to_phys(struct device *hwdev, dma_addr_t daddr)
> +{
> +	return daddr;
> +}
> +
> +static inline bool dma_map_range(struct device *dev, u64 mask,
> +				       phys_addr_t addr, size_t size,
> +				       dma_addr_t *dma_addr_p)
> +{
> +	dma_addr_t dma_addr = phys_to_dma(dev, addr);
> +
> +	if (dma_addr + size > mask)
> +		return false;
> +
> +	*dma_addr_p = dma_addr;
> +	return true;
> +}
> +

dma_map_range is a really confusing name. We have dma_map_single and
dma_map_sg, they are the DMA mapping API.

dma_map_range sounds like the DMA mapping API but it isn't. As I said,
Xen dom0 needs to implement something like xen_map_sg, xen_map_single,
etc, which uses some of swiotlb functions internally. Then we don't
need functions like the above.

