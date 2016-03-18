From: Robin Murphy <robin.murphy@arm.com>
Date: Fri, 18 Mar 2016 12:12:10 +0000
Subject: Re: [PATCH 2/3] swiotlb: prefix dma_to_phys and phys_to_dma functions
Message-Id: <56EBF09A.1060503@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1458252137-24497-1-git-send-email-okaya@codeaurora.org>
 <1458252137-24497-2-git-send-email-okaya@codeaurora.org>
In-Reply-To: <1458252137-24497-2-git-send-email-okaya@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sinan Kaya <okaya@codeaurora.org>, linux-arm-kernel@lists.infradead.org, timur@codeaurora.org, cov@codeaurora.org, nwatters@codeaurora.org
Cc: linux-mips@linux-mips.org, linux-ia64@vger.kernel.org, linux-xtensa@linux-xtensa.org, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Max Filippov <jcmvbkbc@gmail.com>, Chris Metcalf <cmetcalf@ezchip.com>, Paul Mackerras <paulus@samba.org>, "H. Peter Anvin" <hpa@zytor.com>, Huacai Chen <chenhc@lemote.com>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Marek Szyprowski <m.szyprowski@samsung.com>, Jisheng Zhang <jszhang@marvell.com>, Florian Fainelli <f.fainelli@gmail.com>, Russell King <linux@arm.linux.org.uk>, Aaro Koskinen <aaro.koskinen@iki.fi>, Michael Ellerman <mpe@ellerman.id.au>, x86@kernel.org, Ingo Molnar <mingo@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Guenter Roeck <linux@roeck-us.net>, Fenghua Yu <fenghua.yu@intel.com>, Denys Vlasenko <dvlasenk@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Akinobu Mita <akinobu.mita@gmail.com>, Bjorn Helgaas <bhelgaas@google.com>, Thomas Gleixner <tglx@linutronix.de>, Valentin Rothberg <valentinrothberg@gmail.com>, Chris Zankel <chris@zankel.net>, Tony Luck <tony.luck@intel.com>, linux-pci@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, Dean Nelson <dnelson@redhat.com>, linux-kernel@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, "Suthikulpanit, Suravee" <Suravee.Suthikulpanit@amd.com>, Joe Perches <joe@perches.com>, Andrew Morton <akpm@linux-foundation.org>

On 17/03/16 22:02, Sinan Kaya wrote:
> Prefixing dma_to_phys and phys_to_dma API with swiotlb so that
> they are no longer part of the DMA API. These APIs do not exist
> on all architectures and breaks compatibility.
>
> In preparation for the clean up, also make the ARCH implementation
> known by defining swiotlb_phys_do_dma and swiotlb_dma_to_phys.
>
> Signed-off-by: Sinan Kaya <okaya@codeaurora.org>
> ---
>   arch/arm/include/asm/dma-mapping.h                 |  8 ++-
>   arch/arm64/include/asm/dma-mapping.h               |  9 ++-
>   arch/arm64/mm/dma-mapping.c                        | 75 ++++++++++++++--------

[...]

> diff --git a/arch/arm64/mm/dma-mapping.c b/arch/arm64/mm/dma-mapping.c
> index a6e757c..ada00c3 100644
> --- a/arch/arm64/mm/dma-mapping.c
> +++ b/arch/arm64/mm/dma-mapping.c
> @@ -107,7 +107,7 @@ static void *__dma_alloc_coherent(struct device *dev, size_t size,
>   		if (!page)
>   			return NULL;
>
> -		*dma_handle = phys_to_dma(dev, page_to_phys(page));
> +		*dma_handle = swiotlb_phys_to_dma(dev, page_to_phys(page));
>   		addr = page_address(page);
>   		memset(addr, 0, size);
>   		return addr;
> @@ -121,7 +121,7 @@ static void __dma_free_coherent(struct device *dev, size_t size,
>   				struct dma_attrs *attrs)
>   {
>   	bool freed;
> -	phys_addr_t paddr = dma_to_phys(dev, dma_handle);
> +	phys_addr_t paddr = swiotlb_dma_to_phys(dev, dma_handle);
>
>   	if (dev = NULL) {
>   		WARN_ONCE(1, "Use an actual device structure for DMA allocation\n");
> @@ -151,7 +151,8 @@ static void *__dma_alloc(struct device *dev, size_t size,
>   		void *addr = __alloc_from_pool(size, &page, flags);
>
>   		if (addr)
> -			*dma_handle = phys_to_dma(dev, page_to_phys(page));
> +			*dma_handle = swiotlb_phys_to_dma(dev,
> +							  page_to_phys(page));
>
>   		return addr;
>   	}
> @@ -187,7 +188,7 @@ static void __dma_free(struct device *dev, size_t size,
>   		       void *vaddr, dma_addr_t dma_handle,
>   		       struct dma_attrs *attrs)
>   {
> -	void *swiotlb_addr = phys_to_virt(dma_to_phys(dev, dma_handle));
> +	void *swiotlb_addr = phys_to_virt(swiotlb_dma_to_phys(dev, dma_handle));
>
>   	size = PAGE_ALIGN(size);
>
> @@ -208,7 +209,8 @@ static dma_addr_t __swiotlb_map_page(struct device *dev, struct page *page,
>
>   	dev_addr = swiotlb_map_page(dev, page, offset, size, dir, attrs);
>   	if (!is_device_dma_coherent(dev))
> -		__dma_map_area(phys_to_virt(dma_to_phys(dev, dev_addr)), size, dir);
> +		__dma_map_area(phys_to_virt(swiotlb_dma_to_phys(dev, dev_addr)),
> +			       size, dir);
>
>   	return dev_addr;
>   }
> @@ -218,8 +220,11 @@ static void __swiotlb_unmap_page(struct device *dev, dma_addr_t dev_addr,
>   				 size_t size, enum dma_data_direction dir,
>   				 struct dma_attrs *attrs)
>   {
> -	if (!is_device_dma_coherent(dev))
> -		__dma_unmap_area(phys_to_virt(dma_to_phys(dev, dev_addr)), size, dir);
> +	if (!is_device_dma_coherent(dev)) {
> +		phys_addr_t phys = swiotlb_dma_to_phys(dev, dev_addr);
> +
> +		__dma_unmap_area(phys_to_virt(phys), size, dir);
> +	}
>   	swiotlb_unmap_page(dev, dev_addr, size, dir, attrs);
>   }
>
> @@ -232,9 +237,12 @@ static int __swiotlb_map_sg_attrs(struct device *dev, struct scatterlist *sgl,
>
>   	ret = swiotlb_map_sg_attrs(dev, sgl, nelems, dir, attrs);
>   	if (!is_device_dma_coherent(dev))
> -		for_each_sg(sgl, sg, ret, i)
> -			__dma_map_area(phys_to_virt(dma_to_phys(dev, sg->dma_address)),
> -				       sg->length, dir);
> +		for_each_sg(sgl, sg, ret, i) {
> +			dma_addr_t dma = sg->dma_address;
> +			phys_addr_t phys = swiotlb_dma_to_phys(dev, dma);
> +
> +			__dma_map_area(phys_to_virt(phys), sg->length, dir);
> +		}
>
>   	return ret;
>   }
> @@ -248,9 +256,12 @@ static void __swiotlb_unmap_sg_attrs(struct device *dev,
>   	int i;
>
>   	if (!is_device_dma_coherent(dev))
> -		for_each_sg(sgl, sg, nelems, i)
> -			__dma_unmap_area(phys_to_virt(dma_to_phys(dev, sg->dma_address)),
> -					 sg->length, dir);
> +		for_each_sg(sgl, sg, nelems, i) {
> +			dma_addr_t dma = sg->dma_address;
> +			phys_addr_t phys = swiotlb_dma_to_phys(dev, dma);
> +
> +			__dma_unmap_area(phys_to_virt(phys), sg->length, dir);
> +		}
>   	swiotlb_unmap_sg_attrs(dev, sgl, nelems, dir, attrs);
>   }
>
> @@ -258,8 +269,11 @@ static void __swiotlb_sync_single_for_cpu(struct device *dev,
>   					  dma_addr_t dev_addr, size_t size,
>   					  enum dma_data_direction dir)
>   {
> -	if (!is_device_dma_coherent(dev))
> -		__dma_unmap_area(phys_to_virt(dma_to_phys(dev, dev_addr)), size, dir);
> +	if (!is_device_dma_coherent(dev)) {
> +		phys_addr_t phys = swiotlb_dma_to_phys(dev, dev_addr);
> +
> +		__dma_unmap_area(phys_to_virt(phys), size, dir);
> +	}
>   	swiotlb_sync_single_for_cpu(dev, dev_addr, size, dir);
>   }
>
> @@ -269,7 +283,8 @@ static void __swiotlb_sync_single_for_device(struct device *dev,
>   {
>   	swiotlb_sync_single_for_device(dev, dev_addr, size, dir);
>   	if (!is_device_dma_coherent(dev))
> -		__dma_map_area(phys_to_virt(dma_to_phys(dev, dev_addr)), size, dir);
> +		__dma_map_area(phys_to_virt(swiotlb_dma_to_phys(dev, dev_addr)),
> +			       size, dir);
>   }
>
>   static void __swiotlb_sync_sg_for_cpu(struct device *dev,
> @@ -280,9 +295,12 @@ static void __swiotlb_sync_sg_for_cpu(struct device *dev,
>   	int i;
>
>   	if (!is_device_dma_coherent(dev))
> -		for_each_sg(sgl, sg, nelems, i)
> -			__dma_unmap_area(phys_to_virt(dma_to_phys(dev, sg->dma_address)),
> -					 sg->length, dir);
> +		for_each_sg(sgl, sg, nelems, i) {
> +			dma_addr_t dma = sg->dma_address;
> +			phys_addr_t phys = swiotlb_dma_to_phys(dev, dma);
> +
> +			__dma_unmap_area(phys_to_virt(phys), sg->length, dir);
> +		}
>   	swiotlb_sync_sg_for_cpu(dev, sgl, nelems, dir);
>   }
>
> @@ -295,9 +313,12 @@ static void __swiotlb_sync_sg_for_device(struct device *dev,
>
>   	swiotlb_sync_sg_for_device(dev, sgl, nelems, dir);
>   	if (!is_device_dma_coherent(dev))
> -		for_each_sg(sgl, sg, nelems, i)
> -			__dma_map_area(phys_to_virt(dma_to_phys(dev, sg->dma_address)),
> -				       sg->length, dir);
> +		for_each_sg(sgl, sg, nelems, i) {
> +			dma_addr_t dma = sg->dma_address;
> +			phys_addr_t phys = swiotlb_dma_to_phys(dev, dma);
> +
> +			__dma_map_area(phys_to_virt(phys), sg->length, dir);
> +		}
>   }
>
>   static int __swiotlb_mmap(struct device *dev,
> @@ -309,7 +330,7 @@ static int __swiotlb_mmap(struct device *dev,
>   	unsigned long nr_vma_pages = (vma->vm_end - vma->vm_start) >>
>   					PAGE_SHIFT;
>   	unsigned long nr_pages = PAGE_ALIGN(size) >> PAGE_SHIFT;
> -	unsigned long pfn = dma_to_phys(dev, dma_addr) >> PAGE_SHIFT;
> +	unsigned long pfn = swiotlb_dma_to_phys(dev, dma_addr) >> PAGE_SHIFT;
>   	unsigned long off = vma->vm_pgoff;
>
>   	vma->vm_page_prot = __get_dma_pgprot(attrs, vma->vm_page_prot,
> @@ -334,9 +355,11 @@ static int __swiotlb_get_sgtable(struct device *dev, struct sg_table *sgt,
>   {
>   	int ret = sg_alloc_table(sgt, 1, GFP_KERNEL);
>
> -	if (!ret)
> -		sg_set_page(sgt->sgl, phys_to_page(dma_to_phys(dev, handle)),
> -			    PAGE_ALIGN(size), 0);
> +	if (!ret) {
> +		phys_addr_t phys = swiotlb_dma_to_phys(dev, handle);
> +
> +		sg_set_page(sgt->sgl, phys_to_page(phys), PAGE_ALIGN(size), 0);
> +	}
>
>   	return ret;
>   }

Since we know for sure that swiotlb_to_phys is a no-op on arm64, it 
might be cleaner to simply not reference it at all. I suppose we could 
have some private local wrappers, e.g.:

#define swiotlb_to_virt(addr) phys_to_virt((phys_addr_t)(addr))

to keep the intent of the code clear (and just in case anyone ever 
builds a system mad enough to warrant switching out that definition, but 
I'd hope that never happens).

Otherwise, looks good - thanks for doing this!

Robin.
