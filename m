From: Robin Murphy <robin.murphy@arm.com>
Date: Tue, 18 Dec 2018 20:42:46 +0000
Subject: Re: [15/15] dma-mapping: bypass indirect calls for dma-direct
Message-Id: <92096de9-7183-dbe8-2169-0143190591fa@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181207190720.18517-16-hch@lst.de>
 <2e779fa7-dc9f-7ed8-252a-5d20c5deca9c@collabora.com>
In-Reply-To: <2e779fa7-dc9f-7ed8-252a-5d20c5deca9c@collabora.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Guillaume Tucker <guillaume.tucker@collabora.com>, Christoph Hellwig <hch@lst.de>
Cc: iommu@lists.linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Tariq Toukan <tariqt@mellanox.com>, Ilias Apalodimas <ilias.apalodimas@linaro.org>, =?UTF-8?Q?Toke_H=c3=b8iland-J=c3=b8rgensen?= <toke@toke.dk>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Keith Busch <keith.busch@intel.com>, Jonathan Derrick <jonathan.derrick@intel.com>, linux-pci@vger.kernel.org, linux-ia64@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, ezequiel Garcia <ezequiel@collabora.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On 2018-12-18 8:34 pm, Guillaume Tucker wrote:
> On 07/12/2018 19:07, Christoph Hellwig wrote:
>> Avoid expensive indirect calls in the fast path DMA mapping
>> operations by directly calling the dma_direct_* ops if we are using
>> the directly mapped DMA operations.
>>
>> Signed-off-by: Christoph Hellwig <hch@lst.de>
>> Signed-off-by: Christoph Hellwig <hch@lst.de>
>> Reported-by: Marek Szyprowski <m.szyprowski@samsung.com>
>> Tested-by: Marek Szyprowski <m.szyprowski@samsung.com>
> 
> I've run a semi-automated bisection on kernelci.org and found that this
> patch appeared to cause some regressions in linux-next on the
> rk3399-gru-kevin arm64 platform.  The bisection was run between
> next-20181128 and its merge base in mainline master (6531e115b7ab) with
> a plain defconfig.
> 
> 
> The problems seem to start with this message:
> 
> [    3.242163] mmc1: Unable to allocate ADMA buffers - falling back to standard DMA
> 
> then we can see this kind of warnings:
> 
> [    3.424261] mmc1: asked for transfer of 512 bytes exceeds bounce buffer 0 bytes
> [    3.432488] WARNING: CPU: 3 PID: 1596 at ../drivers/mmc/host/sdhci.c:1050 sdhci_send_command+0x8f0/0xfe8
> 
> see also:
> 
> [   16.046084] rk_iommu ff8f3f00.iommu: DMA map error for DT

Yup, with this patch as-is, anything which isn't behind an IOMMU will be 
erroneously banned from DMA entirely - see here:

https://lore.kernel.org/lkml/20181214142435.GA18448@lst.de/

Robin.

> 
> 
> The full kernel log is available here:
> 
>    https://lava.collabora.co.uk/scheduler/job/1395093
> 
> 
> Reverting this patch makes the errors go away, but I haven't done any
> further investigation so the actual problem may well lie somewhere else.
> 
> Hope this helps!
> 
> Best wishes,
> Guillaume
> 
>> ---
>>   arch/alpha/include/asm/dma-mapping.h |   2 +-
>>   arch/arc/mm/cache.c                  |   2 +-
>>   arch/arm/include/asm/dma-mapping.h   |   2 +-
>>   arch/arm/mm/dma-mapping-nommu.c      |  14 +---
>>   arch/arm64/mm/dma-mapping.c          |   3 -
>>   arch/ia64/hp/common/hwsw_iommu.c     |   2 +-
>>   arch/ia64/hp/common/sba_iommu.c      |   4 +-
>>   arch/ia64/kernel/dma-mapping.c       |   1 -
>>   arch/mips/include/asm/dma-mapping.h  |   2 +-
>>   arch/parisc/kernel/setup.c           |   4 -
>>   arch/sparc/include/asm/dma-mapping.h |   4 +-
>>   arch/x86/kernel/pci-dma.c            |   2 +-
>>   drivers/gpu/drm/vmwgfx/vmwgfx_drv.c  |   2 +-
>>   drivers/iommu/amd_iommu.c            |  13 +---
>>   include/asm-generic/dma-mapping.h    |   2 +-
>>   include/linux/dma-direct.h           |  17 ----
>>   include/linux/dma-mapping.h          | 111 +++++++++++++++++++++++----
>>   include/linux/dma-noncoherent.h      |   5 +-
>>   kernel/dma/direct.c                  |  37 ++-------
>>   kernel/dma/mapping.c                 |  40 ++++++----
>>   20 files changed, 150 insertions(+), 119 deletions(-)
>>
>> diff --git a/arch/alpha/include/asm/dma-mapping.h b/arch/alpha/include/asm/dma-mapping.h
>> index 8beeafd4f68e..0ee6a5c99b16 100644
>> --- a/arch/alpha/include/asm/dma-mapping.h
>> +++ b/arch/alpha/include/asm/dma-mapping.h
>> @@ -7,7 +7,7 @@ extern const struct dma_map_ops alpha_pci_ops;
>>   static inline const struct dma_map_ops *get_arch_dma_ops(struct bus_type *bus)
>>   {
>>   #ifdef CONFIG_ALPHA_JENSEN
>> -	return &dma_direct_ops;
>> +	return NULL;
>>   #else
>>   	return &alpha_pci_ops;
>>   #endif
>> diff --git a/arch/arc/mm/cache.c b/arch/arc/mm/cache.c
>> index f2701c13a66b..e188bb3ede53 100644
>> --- a/arch/arc/mm/cache.c
>> +++ b/arch/arc/mm/cache.c
>> @@ -1280,7 +1280,7 @@ void __init arc_cache_init_master(void)
>>   	/*
>>   	 * In case of IOC (say IOC+SLC case), pointers above could still be set
>>   	 * but end up not being relevant as the first function in chain is not
>> -	 * called at all for @dma_direct_ops
>> +	 * called at all for devices using coherent DMA.
>>   	 *     arch_sync_dma_for_cpu() -> dma_cache_*() -> __dma_cache_*()
>>   	 */
>>   }
>> diff --git a/arch/arm/include/asm/dma-mapping.h b/arch/arm/include/asm/dma-mapping.h
>> index 965b7c846ecb..31d3b96f0f4b 100644
>> --- a/arch/arm/include/asm/dma-mapping.h
>> +++ b/arch/arm/include/asm/dma-mapping.h
>> @@ -18,7 +18,7 @@ extern const struct dma_map_ops arm_coherent_dma_ops;
>>   
>>   static inline const struct dma_map_ops *get_arch_dma_ops(struct bus_type *bus)
>>   {
>> -	return IS_ENABLED(CONFIG_MMU) ? &arm_dma_ops : &dma_direct_ops;
>> +	return IS_ENABLED(CONFIG_MMU) ? &arm_dma_ops : NULL;
>>   }
>>   
>>   #ifdef __arch_page_to_dma
>> diff --git a/arch/arm/mm/dma-mapping-nommu.c b/arch/arm/mm/dma-mapping-nommu.c
>> index 712416ecd8e6..f304b10e23a4 100644
>> --- a/arch/arm/mm/dma-mapping-nommu.c
>> +++ b/arch/arm/mm/dma-mapping-nommu.c
>> @@ -22,7 +22,7 @@
>>   #include "dma.h"
>>   
>>   /*
>> - *  dma_direct_ops is used if
>> + *  The generic direct mapping code is used if
>>    *   - MMU/MPU is off
>>    *   - cpu is v7m w/o cache support
>>    *   - device is coherent
>> @@ -209,16 +209,9 @@ const struct dma_map_ops arm_nommu_dma_ops = {
>>   };
>>   EXPORT_SYMBOL(arm_nommu_dma_ops);
>>   
>> -static const struct dma_map_ops *arm_nommu_get_dma_map_ops(bool coherent)
>> -{
>> -	return coherent ? &dma_direct_ops : &arm_nommu_dma_ops;
>> -}
>> -
>>   void arch_setup_dma_ops(struct device *dev, u64 dma_base, u64 size,
>>   			const struct iommu_ops *iommu, bool coherent)
>>   {
>> -	const struct dma_map_ops *dma_ops;
>> -
>>   	if (IS_ENABLED(CONFIG_CPU_V7M)) {
>>   		/*
>>   		 * Cache support for v7m is optional, so can be treated as
>> @@ -234,7 +227,6 @@ void arch_setup_dma_ops(struct device *dev, u64 dma_base, u64 size,
>>   		dev->archdata.dma_coherent = (get_cr() & CR_M) ? coherent : true;
>>   	}
>>   
>> -	dma_ops = arm_nommu_get_dma_map_ops(dev->archdata.dma_coherent);
>> -
>> -	set_dma_ops(dev, dma_ops);
>> +	if (!dev->archdata.dma_coherent)
>> +		set_dma_ops(dev, &arm_nommu_dma_ops);
>>   }
>> diff --git a/arch/arm64/mm/dma-mapping.c b/arch/arm64/mm/dma-mapping.c
>> index ab1e417204d0..95eda81e3f2d 100644
>> --- a/arch/arm64/mm/dma-mapping.c
>> +++ b/arch/arm64/mm/dma-mapping.c
>> @@ -462,9 +462,6 @@ static void __iommu_setup_dma_ops(struct device *dev, u64 dma_base, u64 size,
>>   void arch_setup_dma_ops(struct device *dev, u64 dma_base, u64 size,
>>   			const struct iommu_ops *iommu, bool coherent)
>>   {
>> -	if (!dev->dma_ops)
>> -		dev->dma_ops = &dma_direct_ops;
>> -
>>   	dev->dma_coherent = coherent;
>>   	__iommu_setup_dma_ops(dev, dma_base, size, iommu);
>>   
>> diff --git a/arch/ia64/hp/common/hwsw_iommu.c b/arch/ia64/hp/common/hwsw_iommu.c
>> index f40ca499b246..8840ed97712f 100644
>> --- a/arch/ia64/hp/common/hwsw_iommu.c
>> +++ b/arch/ia64/hp/common/hwsw_iommu.c
>> @@ -38,7 +38,7 @@ static inline int use_swiotlb(struct device *dev)
>>   const struct dma_map_ops *hwsw_dma_get_ops(struct device *dev)
>>   {
>>   	if (use_swiotlb(dev))
>> -		return &dma_direct_ops;
>> +		return NULL;
>>   	return &sba_dma_ops;
>>   }
>>   EXPORT_SYMBOL(hwsw_dma_get_ops);
>> diff --git a/arch/ia64/hp/common/sba_iommu.c b/arch/ia64/hp/common/sba_iommu.c
>> index 5ee74820a0f6..5a361e51cb1e 100644
>> --- a/arch/ia64/hp/common/sba_iommu.c
>> +++ b/arch/ia64/hp/common/sba_iommu.c
>> @@ -2078,7 +2078,7 @@ sba_init(void)
>>   	 * a successful kdump kernel boot is to use the swiotlb.
>>   	 */
>>   	if (is_kdump_kernel()) {
>> -		dma_ops = &dma_direct_ops;
>> +		dma_ops = NULL;
>>   		if (swiotlb_late_init_with_default_size(64 * (1<<20)) != 0)
>>   			panic("Unable to initialize software I/O TLB:"
>>   				  " Try machvec=dig boot option");
>> @@ -2100,7 +2100,7 @@ sba_init(void)
>>   		 * If we didn't find something sba_iommu can claim, we
>>   		 * need to setup the swiotlb and switch to the dig machvec.
>>   		 */
>> -		dma_ops = &dma_direct_ops;
>> +		dma_ops = NULL;
>>   		if (swiotlb_late_init_with_default_size(64 * (1<<20)) != 0)
>>   			panic("Unable to find SBA IOMMU or initialize "
>>   			      "software I/O TLB: Try machvec=dig boot option");
>> diff --git a/arch/ia64/kernel/dma-mapping.c b/arch/ia64/kernel/dma-mapping.c
>> index 80cd3e1ea95a..ad7d9963de34 100644
>> --- a/arch/ia64/kernel/dma-mapping.c
>> +++ b/arch/ia64/kernel/dma-mapping.c
>> @@ -36,7 +36,6 @@ long arch_dma_coherent_to_pfn(struct device *dev, void *cpu_addr,
>>   
>>   void __init swiotlb_dma_init(void)
>>   {
>> -	dma_ops = &dma_direct_ops;
>>   	swiotlb_init(1);
>>   }
>>   #endif
>> diff --git a/arch/mips/include/asm/dma-mapping.h b/arch/mips/include/asm/dma-mapping.h
>> index 69f914667f3e..20dfaad3a55d 100644
>> --- a/arch/mips/include/asm/dma-mapping.h
>> +++ b/arch/mips/include/asm/dma-mapping.h
>> @@ -11,7 +11,7 @@ static inline const struct dma_map_ops *get_arch_dma_ops(struct bus_type *bus)
>>   #if defined(CONFIG_MACH_JAZZ)
>>   	return &jazz_dma_ops;
>>   #else
>> -	return &dma_direct_ops;
>> +	return NULL;
>>   #endif
>>   }
>>   
>> diff --git a/arch/parisc/kernel/setup.c b/arch/parisc/kernel/setup.c
>> index cd227f1cf629..54818cd78bd0 100644
>> --- a/arch/parisc/kernel/setup.c
>> +++ b/arch/parisc/kernel/setup.c
>> @@ -99,10 +99,6 @@ void __init dma_ops_init(void)
>>   
>>   	case pcxl2:
>>   		pa7300lc_init();
>> -	case pcxl: /* falls through */
>> -	case pcxs:
>> -	case pcxt:
>> -		hppa_dma_ops = &dma_direct_ops;
>>   		break;
>>   	default:
>>   		break;
>> diff --git a/arch/sparc/include/asm/dma-mapping.h b/arch/sparc/include/asm/dma-mapping.h
>> index b0bb2fcaf1c9..59f5a0f17316 100644
>> --- a/arch/sparc/include/asm/dma-mapping.h
>> +++ b/arch/sparc/include/asm/dma-mapping.h
>> @@ -14,11 +14,11 @@ static inline const struct dma_map_ops *get_arch_dma_ops(struct bus_type *bus)
>>   {
>>   #ifdef CONFIG_SPARC_LEON
>>   	if (sparc_cpu_model = sparc_leon)
>> -		return &dma_direct_ops;
>> +		return NULL;
>>   #endif
>>   #if defined(CONFIG_SPARC32) && defined(CONFIG_PCI)
>>   	if (bus = &pci_bus_type)
>> -		return &dma_direct_ops;
>> +		return NULL;
>>   #endif
>>   	return dma_ops;
>>   }
>> diff --git a/arch/x86/kernel/pci-dma.c b/arch/x86/kernel/pci-dma.c
>> index f4562fcec681..d460998ae828 100644
>> --- a/arch/x86/kernel/pci-dma.c
>> +++ b/arch/x86/kernel/pci-dma.c
>> @@ -17,7 +17,7 @@
>>   
>>   static bool disable_dac_quirk __read_mostly;
>>   
>> -const struct dma_map_ops *dma_ops = &dma_direct_ops;
>> +const struct dma_map_ops *dma_ops;
>>   EXPORT_SYMBOL(dma_ops);
>>   
>>   #ifdef CONFIG_IOMMU_DEBUG
>> diff --git a/drivers/gpu/drm/vmwgfx/vmwgfx_drv.c b/drivers/gpu/drm/vmwgfx/vmwgfx_drv.c
>> index 61a84b958d67..50637f372e9f 100644
>> --- a/drivers/gpu/drm/vmwgfx/vmwgfx_drv.c
>> +++ b/drivers/gpu/drm/vmwgfx/vmwgfx_drv.c
>> @@ -581,7 +581,7 @@ static int vmw_dma_select_mode(struct vmw_private *dev_priv)
>>   
>>   	dev_priv->map_mode = vmw_dma_map_populate;
>>   
>> -	if (dma_ops->sync_single_for_cpu)
>> +	if (dma_ops && dma_ops->sync_single_for_cpu)
>>   		dev_priv->map_mode = vmw_dma_alloc_coherent;
>>   #ifdef CONFIG_SWIOTLB
>>   	if (swiotlb_nr_tbl() = 0)
>> diff --git a/drivers/iommu/amd_iommu.c b/drivers/iommu/amd_iommu.c
>> index c5d6c7c42b0a..567221cca13c 100644
>> --- a/drivers/iommu/amd_iommu.c
>> +++ b/drivers/iommu/amd_iommu.c
>> @@ -2184,7 +2184,7 @@ static int amd_iommu_add_device(struct device *dev)
>>   				dev_name(dev));
>>   
>>   		iommu_ignore_device(dev);
>> -		dev->dma_ops = &dma_direct_ops;
>> +		dev->dma_ops = NULL;
>>   		goto out;
>>   	}
>>   	init_iommu_group(dev);
>> @@ -2770,17 +2770,6 @@ int __init amd_iommu_init_dma_ops(void)
>>   	swiotlb        = (iommu_pass_through || sme_me_mask) ? 1 : 0;
>>   	iommu_detected = 1;
>>   
>> -	/*
>> -	 * In case we don't initialize SWIOTLB (actually the common case
>> -	 * when AMD IOMMU is enabled and SME is not active), make sure there
>> -	 * are global dma_ops set as a fall-back for devices not handled by
>> -	 * this driver (for example non-PCI devices). When SME is active,
>> -	 * make sure that swiotlb variable remains set so the global dma_ops
>> -	 * continue to be SWIOTLB.
>> -	 */
>> -	if (!swiotlb)
>> -		dma_ops = &dma_direct_ops;
>> -
>>   	if (amd_iommu_unmap_flush)
>>   		pr_info("AMD-Vi: IO/TLB flush on unmap enabled\n");
>>   	else
>> diff --git a/include/asm-generic/dma-mapping.h b/include/asm-generic/dma-mapping.h
>> index 880a292d792f..c13f46109e88 100644
>> --- a/include/asm-generic/dma-mapping.h
>> +++ b/include/asm-generic/dma-mapping.h
>> @@ -4,7 +4,7 @@
>>   
>>   static inline const struct dma_map_ops *get_arch_dma_ops(struct bus_type *bus)
>>   {
>> -	return &dma_direct_ops;
>> +	return NULL;
>>   }
>>   
>>   #endif /* _ASM_GENERIC_DMA_MAPPING_H */
>> diff --git a/include/linux/dma-direct.h b/include/linux/dma-direct.h
>> index 3b0a3ea3876d..b7338702592a 100644
>> --- a/include/linux/dma-direct.h
>> +++ b/include/linux/dma-direct.h
>> @@ -60,22 +60,5 @@ void dma_direct_free_pages(struct device *dev, size_t size, void *cpu_addr,
>>   struct page *__dma_direct_alloc_pages(struct device *dev, size_t size,
>>   		dma_addr_t *dma_handle, gfp_t gfp, unsigned long attrs);
>>   void __dma_direct_free_pages(struct device *dev, size_t size, struct page *page);
>> -dma_addr_t dma_direct_map_page(struct device *dev, struct page *page,
>> -		unsigned long offset, size_t size, enum dma_data_direction dir,
>> -		unsigned long attrs);
>> -void dma_direct_unmap_page(struct device *dev, dma_addr_t addr,
>> -		size_t size, enum dma_data_direction dir, unsigned long attrs);
>> -int dma_direct_map_sg(struct device *dev, struct scatterlist *sgl, int nents,
>> -		enum dma_data_direction dir, unsigned long attrs);
>> -void dma_direct_unmap_sg(struct device *dev, struct scatterlist *sgl,
>> -		int nents, enum dma_data_direction dir, unsigned long attrs);
>> -void dma_direct_sync_single_for_device(struct device *dev,
>> -		dma_addr_t addr, size_t size, enum dma_data_direction dir);
>> -void dma_direct_sync_sg_for_device(struct device *dev,
>> -		struct scatterlist *sgl, int nents, enum dma_data_direction dir);
>> -void dma_direct_sync_single_for_cpu(struct device *dev,
>> -		dma_addr_t addr, size_t size, enum dma_data_direction dir);
>> -void dma_direct_sync_sg_for_cpu(struct device *dev,
>> -		struct scatterlist *sgl, int nents, enum dma_data_direction dir);
>>   int dma_direct_supported(struct device *dev, u64 mask);
>>   #endif /* _LINUX_DMA_DIRECT_H */
>> diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
>> index 269ee27fc3d9..f422aec0f53c 100644
>> --- a/include/linux/dma-mapping.h
>> +++ b/include/linux/dma-mapping.h
>> @@ -134,7 +134,6 @@ struct dma_map_ops {
>>   
>>   #define DMA_MAPPING_ERROR		(~(dma_addr_t)0)
>>   
>> -extern const struct dma_map_ops dma_direct_ops;
>>   extern const struct dma_map_ops dma_virt_ops;
>>   extern const struct dma_map_ops dma_dummy_ops;
>>   
>> @@ -222,6 +221,69 @@ static inline const struct dma_map_ops *get_dma_ops(struct device *dev)
>>   }
>>   #endif
>>   
>> +static inline bool dma_is_direct(const struct dma_map_ops *ops)
>> +{
>> +	return likely(!ops);
>> +}
>> +
>> +/*
>> + * All the dma_direct_* declarations are here just for the indirect call bypass,
>> + * and must not be used directly drivers!
>> + */
>> +dma_addr_t dma_direct_map_page(struct device *dev, struct page *page,
>> +		unsigned long offset, size_t size, enum dma_data_direction dir,
>> +		unsigned long attrs);
>> +int dma_direct_map_sg(struct device *dev, struct scatterlist *sgl, int nents,
>> +		enum dma_data_direction dir, unsigned long attrs);
>> +
>> +#if defined(CONFIG_ARCH_HAS_SYNC_DMA_FOR_DEVICE) || \
>> +    defined(CONFIG_SWIOTLB)
>> +void dma_direct_sync_single_for_device(struct device *dev,
>> +		dma_addr_t addr, size_t size, enum dma_data_direction dir);
>> +void dma_direct_sync_sg_for_device(struct device *dev,
>> +		struct scatterlist *sgl, int nents, enum dma_data_direction dir);
>> +#else
>> +static inline void dma_direct_sync_single_for_device(struct device *dev,
>> +		dma_addr_t addr, size_t size, enum dma_data_direction dir)
>> +{
>> +}
>> +static inline void dma_direct_sync_sg_for_device(struct device *dev,
>> +		struct scatterlist *sgl, int nents, enum dma_data_direction dir)
>> +{
>> +}
>> +#endif
>> +
>> +#if defined(CONFIG_ARCH_HAS_SYNC_DMA_FOR_CPU) || \
>> +    defined(CONFIG_ARCH_HAS_SYNC_DMA_FOR_CPU_ALL) || \
>> +    defined(CONFIG_SWIOTLB)
>> +void dma_direct_unmap_page(struct device *dev, dma_addr_t addr,
>> +		size_t size, enum dma_data_direction dir, unsigned long attrs);
>> +void dma_direct_unmap_sg(struct device *dev, struct scatterlist *sgl,
>> +		int nents, enum dma_data_direction dir, unsigned long attrs);
>> +void dma_direct_sync_single_for_cpu(struct device *dev,
>> +		dma_addr_t addr, size_t size, enum dma_data_direction dir);
>> +void dma_direct_sync_sg_for_cpu(struct device *dev,
>> +		struct scatterlist *sgl, int nents, enum dma_data_direction dir);
>> +#else
>> +static inline void dma_direct_unmap_page(struct device *dev, dma_addr_t addr,
>> +		size_t size, enum dma_data_direction dir, unsigned long attrs)
>> +{
>> +}
>> +static inline void dma_direct_unmap_sg(struct device *dev,
>> +		struct scatterlist *sgl, int nents, enum dma_data_direction dir,
>> +		unsigned long attrs)
>> +{
>> +}
>> +static inline void dma_direct_sync_single_for_cpu(struct device *dev,
>> +		dma_addr_t addr, size_t size, enum dma_data_direction dir)
>> +{
>> +}
>> +static inline void dma_direct_sync_sg_for_cpu(struct device *dev,
>> +		struct scatterlist *sgl, int nents, enum dma_data_direction dir)
>> +{
>> +}
>> +#endif
>> +
>>   static inline dma_addr_t dma_map_single_attrs(struct device *dev, void *ptr,
>>   					      size_t size,
>>   					      enum dma_data_direction dir,
>> @@ -232,9 +294,12 @@ static inline dma_addr_t dma_map_single_attrs(struct device *dev, void *ptr,
>>   
>>   	BUG_ON(!valid_dma_direction(dir));
>>   	debug_dma_map_single(dev, ptr, size);
>> -	addr = ops->map_page(dev, virt_to_page(ptr),
>> -			     offset_in_page(ptr), size,
>> -			     dir, attrs);
>> +	if (dma_is_direct(ops))
>> +		addr = dma_direct_map_page(dev, virt_to_page(ptr),
>> +				offset_in_page(ptr), size, dir, attrs);
>> +	else
>> +		addr = ops->map_page(dev, virt_to_page(ptr),
>> +				offset_in_page(ptr), size, dir, attrs);
>>   	debug_dma_map_page(dev, virt_to_page(ptr),
>>   			   offset_in_page(ptr), size,
>>   			   dir, addr, true);
>> @@ -249,7 +314,9 @@ static inline void dma_unmap_single_attrs(struct device *dev, dma_addr_t addr,
>>   	const struct dma_map_ops *ops = get_dma_ops(dev);
>>   
>>   	BUG_ON(!valid_dma_direction(dir));
>> -	if (ops->unmap_page)
>> +	if (dma_is_direct(ops))
>> +		dma_direct_unmap_page(dev, addr, size, dir, attrs);
>> +	else if (ops->unmap_page)
>>   		ops->unmap_page(dev, addr, size, dir, attrs);
>>   	debug_dma_unmap_page(dev, addr, size, dir, true);
>>   }
>> @@ -272,7 +339,10 @@ static inline int dma_map_sg_attrs(struct device *dev, struct scatterlist *sg,
>>   	int ents;
>>   
>>   	BUG_ON(!valid_dma_direction(dir));
>> -	ents = ops->map_sg(dev, sg, nents, dir, attrs);
>> +	if (dma_is_direct(ops))
>> +		ents = dma_direct_map_sg(dev, sg, nents, dir, attrs);
>> +	else
>> +		ents = ops->map_sg(dev, sg, nents, dir, attrs);
>>   	BUG_ON(ents < 0);
>>   	debug_dma_map_sg(dev, sg, nents, ents, dir);
>>   
>> @@ -287,7 +357,9 @@ static inline void dma_unmap_sg_attrs(struct device *dev, struct scatterlist *sg
>>   
>>   	BUG_ON(!valid_dma_direction(dir));
>>   	debug_dma_unmap_sg(dev, sg, nents, dir);
>> -	if (ops->unmap_sg)
>> +	if (dma_is_direct(ops))
>> +		dma_direct_unmap_sg(dev, sg, nents, dir, attrs);
>> +	else if (ops->unmap_sg)
>>   		ops->unmap_sg(dev, sg, nents, dir, attrs);
>>   }
>>   
>> @@ -301,7 +373,10 @@ static inline dma_addr_t dma_map_page_attrs(struct device *dev,
>>   	dma_addr_t addr;
>>   
>>   	BUG_ON(!valid_dma_direction(dir));
>> -	addr = ops->map_page(dev, page, offset, size, dir, attrs);
>> +	if (dma_is_direct(ops))
>> +		addr = dma_direct_map_page(dev, page, offset, size, dir, attrs);
>> +	else
>> +		addr = ops->map_page(dev, page, offset, size, dir, attrs);
>>   	debug_dma_map_page(dev, page, offset, size, dir, addr, false);
>>   
>>   	return addr;
>> @@ -322,7 +397,7 @@ static inline dma_addr_t dma_map_resource(struct device *dev,
>>   	BUG_ON(pfn_valid(PHYS_PFN(phys_addr)));
>>   
>>   	addr = phys_addr;
>> -	if (ops->map_resource)
>> +	if (ops && ops->map_resource)
>>   		addr = ops->map_resource(dev, phys_addr, size, dir, attrs);
>>   
>>   	debug_dma_map_resource(dev, phys_addr, size, dir, addr);
>> @@ -337,7 +412,7 @@ static inline void dma_unmap_resource(struct device *dev, dma_addr_t addr,
>>   	const struct dma_map_ops *ops = get_dma_ops(dev);
>>   
>>   	BUG_ON(!valid_dma_direction(dir));
>> -	if (ops->unmap_resource)
>> +	if (ops && ops->unmap_resource)
>>   		ops->unmap_resource(dev, addr, size, dir, attrs);
>>   	debug_dma_unmap_resource(dev, addr, size, dir);
>>   }
>> @@ -349,7 +424,9 @@ static inline void dma_sync_single_for_cpu(struct device *dev, dma_addr_t addr,
>>   	const struct dma_map_ops *ops = get_dma_ops(dev);
>>   
>>   	BUG_ON(!valid_dma_direction(dir));
>> -	if (ops->sync_single_for_cpu)
>> +	if (dma_is_direct(ops))
>> +		dma_direct_sync_single_for_cpu(dev, addr, size, dir);
>> +	else if (ops->sync_single_for_cpu)
>>   		ops->sync_single_for_cpu(dev, addr, size, dir);
>>   	debug_dma_sync_single_for_cpu(dev, addr, size, dir);
>>   }
>> @@ -368,7 +445,9 @@ static inline void dma_sync_single_for_device(struct device *dev,
>>   	const struct dma_map_ops *ops = get_dma_ops(dev);
>>   
>>   	BUG_ON(!valid_dma_direction(dir));
>> -	if (ops->sync_single_for_device)
>> +	if (dma_is_direct(ops))
>> +		dma_direct_sync_single_for_device(dev, addr, size, dir);
>> +	else if (ops->sync_single_for_device)
>>   		ops->sync_single_for_device(dev, addr, size, dir);
>>   	debug_dma_sync_single_for_device(dev, addr, size, dir);
>>   }
>> @@ -387,7 +466,9 @@ dma_sync_sg_for_cpu(struct device *dev, struct scatterlist *sg,
>>   	const struct dma_map_ops *ops = get_dma_ops(dev);
>>   
>>   	BUG_ON(!valid_dma_direction(dir));
>> -	if (ops->sync_sg_for_cpu)
>> +	if (dma_is_direct(ops))
>> +		dma_direct_sync_sg_for_cpu(dev, sg, nelems, dir);
>> +	else if (ops->sync_sg_for_cpu)
>>   		ops->sync_sg_for_cpu(dev, sg, nelems, dir);
>>   	debug_dma_sync_sg_for_cpu(dev, sg, nelems, dir);
>>   }
>> @@ -399,7 +480,9 @@ dma_sync_sg_for_device(struct device *dev, struct scatterlist *sg,
>>   	const struct dma_map_ops *ops = get_dma_ops(dev);
>>   
>>   	BUG_ON(!valid_dma_direction(dir));
>> -	if (ops->sync_sg_for_device)
>> +	if (dma_is_direct(ops))
>> +		dma_direct_sync_sg_for_device(dev, sg, nelems, dir);
>> +	else if (ops->sync_sg_for_device)
>>   		ops->sync_sg_for_device(dev, sg, nelems, dir);
>>   	debug_dma_sync_sg_for_device(dev, sg, nelems, dir);
>>   
>> diff --git a/include/linux/dma-noncoherent.h b/include/linux/dma-noncoherent.h
>> index 306557331d7d..69b36ed31a99 100644
>> --- a/include/linux/dma-noncoherent.h
>> +++ b/include/linux/dma-noncoherent.h
>> @@ -38,7 +38,10 @@ pgprot_t arch_dma_mmap_pgprot(struct device *dev, pgprot_t prot,
>>   void arch_dma_cache_sync(struct device *dev, void *vaddr, size_t size,
>>   		enum dma_data_direction direction);
>>   #else
>> -#define arch_dma_cache_sync NULL
>> +static inline void arch_dma_cache_sync(struct device *dev, void *vaddr,
>> +		size_t size, enum dma_data_direction direction)
>> +{
>> +}
>>   #endif /* CONFIG_DMA_NONCOHERENT_CACHE_SYNC */
>>   
>>   #ifdef CONFIG_ARCH_HAS_SYNC_DMA_FOR_DEVICE
>> diff --git a/kernel/dma/direct.c b/kernel/dma/direct.c
>> index 85d8286a0ba2..79da61b49fa4 100644
>> --- a/kernel/dma/direct.c
>> +++ b/kernel/dma/direct.c
>> @@ -223,6 +223,7 @@ void dma_direct_sync_single_for_device(struct device *dev,
>>   	if (!dev_is_dma_coherent(dev))
>>   		arch_sync_dma_for_device(dev, paddr, size, dir);
>>   }
>> +EXPORT_SYMBOL(dma_direct_sync_single_for_device);
>>   
>>   void dma_direct_sync_sg_for_device(struct device *dev,
>>   		struct scatterlist *sgl, int nents, enum dma_data_direction dir)
>> @@ -240,6 +241,7 @@ void dma_direct_sync_sg_for_device(struct device *dev,
>>   					dir);
>>   	}
>>   }
>> +EXPORT_SYMBOL(dma_direct_sync_sg_for_device);
>>   #endif
>>   
>>   #if defined(CONFIG_ARCH_HAS_SYNC_DMA_FOR_CPU) || \
>> @@ -258,6 +260,7 @@ void dma_direct_sync_single_for_cpu(struct device *dev,
>>   	if (unlikely(is_swiotlb_buffer(paddr)))
>>   		swiotlb_tbl_sync_single(dev, paddr, size, dir, SYNC_FOR_CPU);
>>   }
>> +EXPORT_SYMBOL(dma_direct_sync_single_for_cpu);
>>   
>>   void dma_direct_sync_sg_for_cpu(struct device *dev,
>>   		struct scatterlist *sgl, int nents, enum dma_data_direction dir)
>> @@ -277,6 +280,7 @@ void dma_direct_sync_sg_for_cpu(struct device *dev,
>>   	if (!dev_is_dma_coherent(dev))
>>   		arch_sync_dma_for_cpu_all(dev);
>>   }
>> +EXPORT_SYMBOL(dma_direct_sync_sg_for_cpu);
>>   
>>   void dma_direct_unmap_page(struct device *dev, dma_addr_t addr,
>>   		size_t size, enum dma_data_direction dir, unsigned long attrs)
>> @@ -289,6 +293,7 @@ void dma_direct_unmap_page(struct device *dev, dma_addr_t addr,
>>   	if (unlikely(is_swiotlb_buffer(phys)))
>>   		swiotlb_tbl_unmap_single(dev, phys, size, dir, attrs);
>>   }
>> +EXPORT_SYMBOL(dma_direct_unmap_page);
>>   
>>   void dma_direct_unmap_sg(struct device *dev, struct scatterlist *sgl,
>>   		int nents, enum dma_data_direction dir, unsigned long attrs)
>> @@ -300,11 +305,7 @@ void dma_direct_unmap_sg(struct device *dev, struct scatterlist *sgl,
>>   		dma_direct_unmap_page(dev, sg->dma_address, sg_dma_len(sg), dir,
>>   			     attrs);
>>   }
>> -#else
>> -void dma_direct_unmap_sg(struct device *dev, struct scatterlist *sgl,
>> -		int nents, enum dma_data_direction dir, unsigned long attrs)
>> -{
>> -}
>> +EXPORT_SYMBOL(dma_direct_unmap_sg);
>>   #endif
>>   
>>   static inline bool dma_direct_possible(struct device *dev, dma_addr_t dma_addr,
>> @@ -331,6 +332,7 @@ dma_addr_t dma_direct_map_page(struct device *dev, struct page *page,
>>   		arch_sync_dma_for_device(dev, phys, size, dir);
>>   	return dma_addr;
>>   }
>> +EXPORT_SYMBOL(dma_direct_map_page);
>>   
>>   int dma_direct_map_sg(struct device *dev, struct scatterlist *sgl, int nents,
>>   		enum dma_data_direction dir, unsigned long attrs)
>> @@ -352,6 +354,7 @@ int dma_direct_map_sg(struct device *dev, struct scatterlist *sgl, int nents,
>>   	dma_direct_unmap_sg(dev, sgl, i, dir, attrs | DMA_ATTR_SKIP_CPU_SYNC);
>>   	return 0;
>>   }
>> +EXPORT_SYMBOL(dma_direct_map_sg);
>>   
>>   /*
>>    * Because 32-bit DMA masks are so common we expect every architecture to be
>> @@ -372,27 +375,3 @@ int dma_direct_supported(struct device *dev, u64 mask)
>>   
>>   	return mask >= phys_to_dma(dev, min_mask);
>>   }
>> -
>> -const struct dma_map_ops dma_direct_ops = {
>> -	.alloc			= dma_direct_alloc,
>> -	.free			= dma_direct_free,
>> -	.map_page		= dma_direct_map_page,
>> -	.map_sg			= dma_direct_map_sg,
>> -#if defined(CONFIG_ARCH_HAS_SYNC_DMA_FOR_DEVICE) || \
>> -    defined(CONFIG_SWIOTLB)
>> -	.sync_single_for_device	= dma_direct_sync_single_for_device,
>> -	.sync_sg_for_device	= dma_direct_sync_sg_for_device,
>> -#endif
>> -#if defined(CONFIG_ARCH_HAS_SYNC_DMA_FOR_CPU) || \
>> -    defined(CONFIG_ARCH_HAS_SYNC_DMA_FOR_CPU_ALL) || \
>> -    defined(CONFIG_SWIOTLB)
>> -	.sync_single_for_cpu	= dma_direct_sync_single_for_cpu,
>> -	.sync_sg_for_cpu	= dma_direct_sync_sg_for_cpu,
>> -	.unmap_page		= dma_direct_unmap_page,
>> -	.unmap_sg		= dma_direct_unmap_sg,
>> -#endif
>> -	.get_required_mask	= dma_direct_get_required_mask,
>> -	.dma_supported		= dma_direct_supported,
>> -	.cache_sync		= arch_dma_cache_sync,
>> -};
>> -EXPORT_SYMBOL(dma_direct_ops);
>> diff --git a/kernel/dma/mapping.c b/kernel/dma/mapping.c
>> index 0b18cfbdde95..fc84c81029d9 100644
>> --- a/kernel/dma/mapping.c
>> +++ b/kernel/dma/mapping.c
>> @@ -7,6 +7,7 @@
>>    */
>>   #include <linux/memblock.h> /* for max_pfn */
>>   #include <linux/acpi.h>
>> +#include <linux/dma-direct.h>
>>   #include <linux/dma-noncoherent.h>
>>   #include <linux/export.h>
>>   #include <linux/gfp.h>
>> @@ -229,8 +230,8 @@ int dma_get_sgtable_attrs(struct device *dev, struct sg_table *sgt,
>>   		unsigned long attrs)
>>   {
>>   	const struct dma_map_ops *ops = get_dma_ops(dev);
>> -	BUG_ON(!ops);
>> -	if (ops->get_sgtable)
>> +
>> +	if (!dma_is_direct(ops) && ops->get_sgtable)
>>   		return ops->get_sgtable(dev, sgt, cpu_addr, dma_addr, size,
>>   					attrs);
>>   	return dma_common_get_sgtable(dev, sgt, cpu_addr, dma_addr, size,
>> @@ -293,8 +294,8 @@ int dma_mmap_attrs(struct device *dev, struct vm_area_struct *vma,
>>   		unsigned long attrs)
>>   {
>>   	const struct dma_map_ops *ops = get_dma_ops(dev);
>> -	BUG_ON(!ops);
>> -	if (ops->mmap)
>> +
>> +	if (!dma_is_direct(ops) && ops->mmap)
>>   		return ops->mmap(dev, vma, cpu_addr, dma_addr, size, attrs);
>>   	return dma_common_mmap(dev, vma, cpu_addr, dma_addr, size, attrs);
>>   }
>> @@ -324,6 +325,8 @@ u64 dma_get_required_mask(struct device *dev)
>>   {
>>   	const struct dma_map_ops *ops = get_dma_ops(dev);
>>   
>> +	if (dma_is_direct(ops))
>> +		return dma_direct_get_required_mask(dev);
>>   	if (ops->get_required_mask)
>>   		return ops->get_required_mask(dev);
>>   	return dma_default_get_required_mask(dev);
>> @@ -341,7 +344,6 @@ void *dma_alloc_attrs(struct device *dev, size_t size, dma_addr_t *dma_handle,
>>   	const struct dma_map_ops *ops = get_dma_ops(dev);
>>   	void *cpu_addr;
>>   
>> -	BUG_ON(!ops);
>>   	WARN_ON_ONCE(dev && !dev->coherent_dma_mask);
>>   
>>   	if (dma_alloc_from_dev_coherent(dev, size, dma_handle, &cpu_addr))
>> @@ -352,10 +354,14 @@ void *dma_alloc_attrs(struct device *dev, size_t size, dma_addr_t *dma_handle,
>>   
>>   	if (!arch_dma_alloc_attrs(&dev))
>>   		return NULL;
>> -	if (!ops->alloc)
>> +
>> +	if (dma_is_direct(ops))
>> +		cpu_addr = dma_direct_alloc(dev, size, dma_handle, flag, attrs);
>> +	else if (ops->alloc)
>> +		cpu_addr = ops->alloc(dev, size, dma_handle, flag, attrs);
>> +	else
>>   		return NULL;
>>   
>> -	cpu_addr = ops->alloc(dev, size, dma_handle, flag, attrs);
>>   	debug_dma_alloc_coherent(dev, size, *dma_handle, cpu_addr);
>>   	return cpu_addr;
>>   }
>> @@ -366,8 +372,6 @@ void dma_free_attrs(struct device *dev, size_t size, void *cpu_addr,
>>   {
>>   	const struct dma_map_ops *ops = get_dma_ops(dev);
>>   
>> -	BUG_ON(!ops);
>> -
>>   	if (dma_release_from_dev_coherent(dev, get_order(size), cpu_addr))
>>   		return;
>>   	/*
>> @@ -379,11 +383,14 @@ void dma_free_attrs(struct device *dev, size_t size, void *cpu_addr,
>>   	 */
>>   	WARN_ON(irqs_disabled());
>>   
>> -	if (!ops->free || !cpu_addr)
>> +	if (!cpu_addr)
>>   		return;
>>   
>>   	debug_dma_free_coherent(dev, size, cpu_addr, dma_handle);
>> -	ops->free(dev, size, cpu_addr, dma_handle, attrs);
>> +	if (dma_is_direct(ops))
>> +		dma_direct_free(dev, size, cpu_addr, dma_handle, attrs);
>> +	else if (ops->free)
>> +		ops->free(dev, size, cpu_addr, dma_handle, attrs);
>>   }
>>   EXPORT_SYMBOL(dma_free_attrs);
>>   
>> @@ -397,9 +404,9 @@ int dma_supported(struct device *dev, u64 mask)
>>   {
>>   	const struct dma_map_ops *ops = get_dma_ops(dev);
>>   
>> -	if (!ops)
>> -		return 0;
>> -	if (!ops->dma_supported)
>> +	if (dma_is_direct(ops))
>> +		return dma_direct_supported(dev, mask);
>> +	if (ops->dma_supported)
>>   		return 1;
>>   	return ops->dma_supported(dev, mask);
>>   }
>> @@ -437,7 +444,10 @@ void dma_cache_sync(struct device *dev, void *vaddr, size_t size,
>>   	const struct dma_map_ops *ops = get_dma_ops(dev);
>>   
>>   	BUG_ON(!valid_dma_direction(dir));
>> -	if (ops->cache_sync)
>> +
>> +	if (dma_is_direct(ops))
>> +		arch_dma_cache_sync(dev, vaddr, size, dir);
>> +	else if (ops->cache_sync)
>>   		ops->cache_sync(dev, vaddr, size, dir);
>>   }
>>   EXPORT_SYMBOL(dma_cache_sync);
>>
> 
