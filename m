From: Nicolin Chen <nicoleotsuka@gmail.com>
Date: Tue, 01 Sep 2020 07:54:01 +0000
Subject: Re: [RESEND][PATCH 0/7] Avoid overflow at boundary_size
Message-Id: <20200901075401.GA5667@Asurada-Nvidia>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200831203811.8494-1-nicoleotsuka@gmail.com>
 <20200901073623.GA30418@lst.de>
In-Reply-To: <20200901073623.GA30418@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: mpe@ellerman.id.au, benh@kernel.crashing.org, paulus@samba.org, rth@twiddle.net, ink@jurassic.park.msu.ru, mattst88@gmail.com, tony.luck@intel.com, fenghua.yu@intel.com, schnelle@linux.ibm.com, gerald.schaefer@linux.ibm.com, hca@linux.ibm.com, gor@linux.ibm.com, borntraeger@de.ibm.com, davem@davemloft.net, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, x86@kernel.org, hpa@zytor.com, James.Bottomley@HansenPartnership.com, deller@gmx.de, sfr@canb.auug.org.au, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linux-parisc@vger.kernel.org

Hi Christoph,

On Tue, Sep 01, 2020 at 09:36:23AM +0200, Christoph Hellwig wrote:
> I really don't like all the open coded smarts in the various drivers.
> What do you think about a helper like the one in the untested patch

A helper function will be actually better. I was thinking of
one yet not very sure about the naming and where to put it.

> below (on top of your series).  Also please include the original
> segment boundary patch with the next resend so that the series has
> the full context.

I will use your change instead and resend with the ULONG_MAX
change. But in that case, should I make separate changes for
different files like this series, or just one single change
like yours?

Asking this as I was expecting that those changes would get
applied by different maintainers. But now it feels like you
will merge it to your tree at once?

Thanks
Nic

> diff --git a/arch/alpha/kernel/pci_iommu.c b/arch/alpha/kernel/pci_iommu.c
> index 1ef2c647bd3ec2..6f7de4f4e191e7 100644
> --- a/arch/alpha/kernel/pci_iommu.c
> +++ b/arch/alpha/kernel/pci_iommu.c
> @@ -141,10 +141,7 @@ iommu_arena_find_pages(struct device *dev, struct pci_iommu_arena *arena,
>  	unsigned long boundary_size;
>  
>  	base = arena->dma_base >> PAGE_SHIFT;
> -
> -	boundary_size = dev ? dma_get_seg_boundary(dev) : U32_MAX;
> -	/* Overflow-free shortcut for: ALIGN(b + 1, 1 << s) >> s */
> -	boundary_size = (boundary_size >> PAGE_SHIFT) + 1;
> +	boundary_size = dma_get_seg_boundary_nr_pages(dev, PAGE_SHIFT);
>  
>  	/* Search forward for the first mask-aligned sequence of N free ptes */
>  	ptes = arena->ptes;
> diff --git a/arch/ia64/hp/common/sba_iommu.c b/arch/ia64/hp/common/sba_iommu.c
> index 945954903bb0ba..b49b73a95067d2 100644
> --- a/arch/ia64/hp/common/sba_iommu.c
> +++ b/arch/ia64/hp/common/sba_iommu.c
> @@ -485,8 +485,7 @@ sba_search_bitmap(struct ioc *ioc, struct device *dev,
>  	ASSERT(((unsigned long) ioc->res_hint & (sizeof(unsigned long) - 1UL)) = 0);
>  	ASSERT(res_ptr < res_end);
>  
> -	/* Overflow-free shortcut for: ALIGN(b + 1, 1 << s) >> s */
> -	boundary_size = (dma_get_seg_boundary(dev) >> iovp_shift) + 1;
> +	boundary_size = dma_get_seg_boundary_nr_pages(dev, iovp_shift);
>  
>  	BUG_ON(ioc->ibase & ~iovp_mask);
>  	shift = ioc->ibase >> iovp_shift;
> diff --git a/arch/powerpc/kernel/iommu.c b/arch/powerpc/kernel/iommu.c
> index c01ccbf8afdd42..cbc2e62db597cf 100644
> --- a/arch/powerpc/kernel/iommu.c
> +++ b/arch/powerpc/kernel/iommu.c
> @@ -236,11 +236,7 @@ static unsigned long iommu_range_alloc(struct device *dev,
>  		}
>  	}
>  
> -	/* 4GB boundary for iseries_hv_alloc and iseries_hv_map */
> -	boundary_size = dev ? dma_get_seg_boundary(dev) : U32_MAX;
> -
> -	/* Overflow-free shortcut for: ALIGN(b + 1, 1 << s) >> s */
> -	boundary_size = (boundary_size >> tbl->it_page_shift) + 1;
> +	boundary_size = dma_get_seg_boundary_nr_pages(dev, tbl->it_page_shift);
>  
>  	n = iommu_area_alloc(tbl->it_map, limit, start, npages, tbl->it_offset,
>  			     boundary_size, align_mask);
> diff --git a/arch/s390/pci/pci_dma.c b/arch/s390/pci/pci_dma.c
> index ecb067acc6d532..4a37d8f4de9d9d 100644
> --- a/arch/s390/pci/pci_dma.c
> +++ b/arch/s390/pci/pci_dma.c
> @@ -261,13 +261,11 @@ static unsigned long __dma_alloc_iommu(struct device *dev,
>  				       unsigned long start, int size)
>  {
>  	struct zpci_dev *zdev = to_zpci(to_pci_dev(dev));
> -	unsigned long boundary_size;
>  
> -	/* Overflow-free shortcut for: ALIGN(b + 1, 1 << s) >> s */
> -	boundary_size = (dma_get_seg_boundary(dev) >> PAGE_SHIFT) + 1;
>  	return iommu_area_alloc(zdev->iommu_bitmap, zdev->iommu_pages,
>  				start, size, zdev->start_dma >> PAGE_SHIFT,
> -				boundary_size, 0);
> +				dma_get_seg_boundary_nr_pages(dev, PAGE_SHIFT),
> +				0);
>  }
>  
>  static dma_addr_t dma_alloc_address(struct device *dev, int size)
> diff --git a/arch/sparc/kernel/iommu-common.c b/arch/sparc/kernel/iommu-common.c
> index 843e71894d0482..e6139c99762e11 100644
> --- a/arch/sparc/kernel/iommu-common.c
> +++ b/arch/sparc/kernel/iommu-common.c
> @@ -166,10 +166,6 @@ unsigned long iommu_tbl_range_alloc(struct device *dev,
>  		}
>  	}
>  
> -	boundary_size = dev ? dma_get_seg_boundary(dev) : U32_MAX;
> -
> -	/* Overflow-free shortcut for: ALIGN(b + 1, 1 << s) >> s */
> -	boundary_size = (boundary_size >> iommu->table_shift) + 1;
>  	/*
>  	 * if the skip_span_boundary_check had been set during init, we set
>  	 * things up so that iommu_is_span_boundary() merely checks if the
> @@ -178,7 +174,11 @@ unsigned long iommu_tbl_range_alloc(struct device *dev,
>  	if ((iommu->flags & IOMMU_NO_SPAN_BOUND) != 0) {
>  		shift = 0;
>  		boundary_size = iommu->poolsize * iommu->nr_pools;
> +	} else {
> +		boundary_size = dma_get_seg_boundary_nr_pages(dev,
> +					iommu->table_shift);
>  	}
> +
>  	n = iommu_area_alloc(iommu->map, limit, start, npages, shift,
>  			     boundary_size, align_mask);
>  	if (n = -1) {
> diff --git a/arch/sparc/kernel/iommu.c b/arch/sparc/kernel/iommu.c
> index d981c37305ae31..c3e4e2df26a8b8 100644
> --- a/arch/sparc/kernel/iommu.c
> +++ b/arch/sparc/kernel/iommu.c
> @@ -472,8 +472,7 @@ static int dma_4u_map_sg(struct device *dev, struct scatterlist *sglist,
>  	outs->dma_length = 0;
>  
>  	max_seg_size = dma_get_max_seg_size(dev);
> -	/* Overflow-free shortcut for: ALIGN(b + 1, 1 << s) >> s */
> -	seg_boundary_size = (dma_get_seg_boundary(dev) >> IO_PAGE_SHIFT) + 1;
> +	seg_boundary_size = dma_get_seg_boundary_nr_pages(dev, IO_PAGE_SHIFT);
>  	base_shift = iommu->tbl.table_map_base >> IO_PAGE_SHIFT;
>  	for_each_sg(sglist, s, nelems, i) {
>  		unsigned long paddr, npages, entry, out_entry = 0, slen;
> diff --git a/arch/sparc/kernel/pci_sun4v.c b/arch/sparc/kernel/pci_sun4v.c
> index 233fe8a20cec33..6b92dd51c0026f 100644
> --- a/arch/sparc/kernel/pci_sun4v.c
> +++ b/arch/sparc/kernel/pci_sun4v.c
> @@ -508,8 +508,7 @@ static int dma_4v_map_sg(struct device *dev, struct scatterlist *sglist,
>  	iommu_batch_start(dev, prot, ~0UL);
>  
>  	max_seg_size = dma_get_max_seg_size(dev);
> -	/* Overflow-free shortcut for: ALIGN(b + 1, 1 << s) >> s */
> -	seg_boundary_size = (dma_get_seg_boundary(dev) >> IO_PAGE_SHIFT) + 1;
> +	seg_boundary_size = dma_get_seg_boundary_nr_pages(dev, IO_PAGE_SHIFT);
>  
>  	mask = *dev->dma_mask;
>  	if (!iommu_use_atu(iommu, mask))
> diff --git a/arch/x86/kernel/amd_gart_64.c b/arch/x86/kernel/amd_gart_64.c
> index 7fa0bb490065a1..bccc5357bffd6c 100644
> --- a/arch/x86/kernel/amd_gart_64.c
> +++ b/arch/x86/kernel/amd_gart_64.c
> @@ -96,8 +96,7 @@ static unsigned long alloc_iommu(struct device *dev, int size,
>  
>  	base_index = ALIGN(iommu_bus_base & dma_get_seg_boundary(dev),
>  			   PAGE_SIZE) >> PAGE_SHIFT;
> -	/* Overflow-free shortcut for: ALIGN(b + 1, 1 << s) >> s */
> -	boundary_size = (dma_get_seg_boundary(dev) >> PAGE_SHIFT) + 1;
> +	boundary_size = dma_get_seg_boundary_nr_pages(dev, PAGE_SHIFT);
>  
>  	spin_lock_irqsave(&iommu_bitmap_lock, flags);
>  	offset = iommu_area_alloc(iommu_gart_bitmap, iommu_pages, next_bit,
> diff --git a/drivers/parisc/ccio-dma.c b/drivers/parisc/ccio-dma.c
> index c667d6aba7646e..ba16b7f8f80612 100644
> --- a/drivers/parisc/ccio-dma.c
> +++ b/drivers/parisc/ccio-dma.c
> @@ -356,8 +356,7 @@ ccio_alloc_range(struct ioc *ioc, struct device *dev, size_t size)
>  	** ggg sacrifices another 710 to the computer gods.
>  	*/
>  
> -	/* Overflow-free shortcut for: ALIGN(b + 1, 1 << s) >> s */
> -	boundary_size = (dma_get_seg_boundary(dev) >> IOVP_SHIFT) + 1;
> +	boundary_size = dma_get_seg_boundary_nr_pages(dev, IOVP_SHIFT);
>  
>  	if (pages_needed <= 8) {
>  		/*
> diff --git a/drivers/parisc/sba_iommu.c b/drivers/parisc/sba_iommu.c
> index 96bc2c617cbd19..959bda193b9603 100644
> --- a/drivers/parisc/sba_iommu.c
> +++ b/drivers/parisc/sba_iommu.c
> @@ -342,8 +342,7 @@ sba_search_bitmap(struct ioc *ioc, struct device *dev,
>  	unsigned long shift;
>  	int ret;
>  
> -	/* Overflow-free shortcut for: ALIGN(b + 1, 1 << s) >> s */
> -	boundary_size = (dma_get_seg_boundary(dev) >> IOVP_SHIFT) + 1;
> +	boundary_size = dma_get_seg_boundary_nr_pages(dev, IOVP_SHIFT);
>  
>  #if defined(ZX1_SUPPORT)
>  	BUG_ON(ioc->ibase & ~IOVP_MASK);
> diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
> index 52635e91143b25..7477a164500adb 100644
> --- a/include/linux/dma-mapping.h
> +++ b/include/linux/dma-mapping.h
> @@ -632,6 +632,25 @@ static inline unsigned long dma_get_seg_boundary(struct device *dev)
>  	return DMA_BIT_MASK(32);
>  }
>  
> +/**
> + * dma_get_seg_boundary_nr_pages - return the segment boundary in "page" units
> + * @dev: device to guery the boundary for
> + * @page_shift: ilog() of the the IOMMU page size
> + *
> + * Return the segment boundary in IOMMU page units (which may be different from
> + * the CPU page size) for the passed in device.
> + *
> + * If @dev is NULL a boundary of U32_MAX is assumed, this case is just for
> + * non-DMA API callers.
> + */
> +static inline unsigned long dma_get_seg_boundary_nr_pages(struct device *dev,
> +		unsigned int page_shift)
> +{
> +	if (!dev)
> +		return (U32_MAX >> page_shift) + 1;
> +	return (dma_get_seg_boundary(dev) >> page_shift) + 1;
> +}
> +
>  static inline int dma_set_seg_boundary(struct device *dev, unsigned long mask)
>  {
>  	if (dev->dma_parms) {
