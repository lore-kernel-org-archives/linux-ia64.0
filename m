From: "Yu, Fenghua" <fenghua.yu@intel.com>
Date: Thu, 02 Oct 2008 21:46:06 +0000
Subject: RE: [PATCH 1/2]Add Variable Page Size and IA64 Support in Intel
Message-Id: <A6AD88C3F2289247BE726C37303E1EB88408ADFF@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <BAE9DCEF64577A439B3A37F36F9B691C0339372B@orsmsx418.amr.corp.intel.com>
 <617E1C2C70743745A92448908E030B2A02AD5AD7@scsmsx411.amr.corp.intel.com>
 <20081001165725.GA21559@linux-os.sc.intel.com>
 <200810020931.48952.bjorn.helgaas@hp.com>
In-Reply-To: <200810020931.48952.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bjorn.helgaas@hp.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, Jesse Barnes <jbarnes@virtuousgeek.org>, David Woodhouse <dwmw2@infradead.org>, Ingo Molnar <mingo@elte.hu>, Avi Kivity <avi@redhat.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

>> The current Intel IOMMU code assumes that both host page size and Intel IOMMU page size are 4K. The first patch supports variable page size. This provides support for IA64 which has multiple page sizes.
>>
>> This patch also adds some other code hooks for IA64 platform including DMAR_OPERATION_TIMEOUT definition, .

>Can you split this patch up?  It contains several logically separate
changes:
>  - casting things to unsigned long long
>  - adding stuff under #ifdef CONFIG_IA64
>  - page size changes
>  - whitespace changes

Depends on who is picking up the generic patch. If it's needed, I can split it into multiple patches.

>> @@ -510,7 +514,7 @@ int alloc_iommu(struct dmar_drhd_unit *drhd)
>>
>>       iommu->seq_id = iommu_allocated++;
>>
>> -     iommu->reg = ioremap(drhd->reg_base_addr, PAGE_SIZE_4K);
>> +     iommu->reg = ioremap(drhd->reg_base_addr, IOMMU_PAGE_SIZE);
>>       if (!iommu->reg) {
>>               printk(KERN_ERR "IOMMU: can't map the region\n");
>
>This printk should include a clue, like the IOMMU ID and/or address
>we tried to map.

This is a good comment. This patch set is mainly for porting IOMMU to IA64. I will add IOMMU ID in a follow-up clean-up patch.

>> +#ifdef CONFIG_IA64
>> +static inline void *ia64_get_zeroed_page(gfp_t gfp_mask)
>> +{
>> +     struct page *page;
>> +
>> +     page = alloc_pages(gfp_mask | __GFP_ZERO, 0);
>> +     if (page)
>> +             return (void *)page_address(page);
>> +     return 0;
>> +}
>> +#endif
>>
>>  static inline void *alloc_pgtable_page(void)
>>  {
>> @@ -141,7 +155,11 @@ static inline void *alloc_pgtable_page(void)
>>       /* trying to avoid low memory issues */
>>       flags = current->flags & PF_MEMALLOC;
>>       current->flags |= PF_MEMALLOC;
>> +#ifdef CONFIG_IA64
>> +     vaddr = ia64_get_zeroed_page(GFP_ATOMIC);
>> +#else
>>       vaddr = (void *)get_zeroed_page(GFP_ATOMIC);
>> +#endif

>Why does ia64 need a special case here?

I think old kernel I originally work on doesn't have get_zeroed_page for ia64. Yes, I will remove this change in the updated patch.

>> @@ -655,7 +673,8 @@ static int __iommu_flush_iotlb(struct intel_iommu *iommu, u16 did,
>>               printk(KERN_ERR"IOMMU: flush IOTLB failed\n");
>>       if (DMA_TLB_IAIG(val) != DMA_TLB_IIRG(type))
>>               pr_debug("IOMMU: tlb flush request %Lx, actual %Lx\n",
>> -                     DMA_TLB_IIRG(type), DMA_TLB_IAIG(val));
>> +                     (unsigned long long)DMA_TLB_IIRG(type),
>> +                     (unsigned long long) DMA_TLB_IAIG(val));
>
>These printks should include an IOMMU ID also (I assume a system can
>contain multiple IOMMUs).

This patch set is mainly for porting IOMMU to IA64. I will add IOMMU ID in a follow-up clean-up patch.

>> @@ -1490,9 +1513,9 @@ static int iommu_prepare_identity_map(struct pci_dev *pdev, u64 start, u64 end)
>>               return -ENOMEM;
>>
>>       /* The address might not be aligned */
>> -     base = start & PAGE_MASK_4K;
>> +     base = start & PAGE_MASK;
>>       size = end - base;
>> -     size = PAGE_ALIGN_4K(size);
>> +     size = PAGE_ALIGN(size);
>>       if (!reserve_iova(&domain->iovad, IOVA_PFN(base),
>>                       IOVA_PFN(base + size) - 1)) {
>>               printk(KERN_ERR "IOMMU: reserve iova failed\n");
>
>This should probably be a "dev_err(&pdev->dev," and include the
>IOMMU ID.

This patch set is mainly for porting IOMMU to IA64. I will add IOMMU ID and dev_err in a follow-up clean-up patch.


>> @@ -1855,27 +1879,23 @@ intel_map_single(struct device *hwdev, phys_addr_t paddr, size_t size, int dir)
>>        * is not a big problem
>>        */
>>       ret = domain_page_mapping(domain, start_paddr,
>> -             ((u64)paddr) & PAGE_MASK_4K, size, prot);
>> +             ((u64)paddr) & PAGE_MASK, size, prot);
>>       if (ret)
>>               goto error;
>>
>> -     pr_debug("Device %s request: %lx@%llx mapping: %lx@%llx, dir %d\n",
>> -             pci_name(pdev), size, (u64)paddr,
>> -             size, (u64)start_paddr, dir);
>> -
>>       /* it's a non-present to present mapping */
>>       ret = iommu_flush_iotlb_psi(domain->iommu, domain->id,
>> -                     start_paddr, size >> PAGE_SHIFT_4K, 1);
>> +                     start_paddr, size >> IOMMU_PAGE_SHIFT, 1);
>>       if (ret)
>>               iommu_flush_write_buffer(domain->iommu);
>>
>> -     return (start_paddr + ((u64)paddr & (~PAGE_MASK_4K)));
>> +     return start_paddr + ((u64)paddr & (~PAGE_MASK));
>>
>>  error:
>>       if (iova)
>>               __free_iova(&domain->iovad, iova);
>>       printk(KERN_ERR"Device %s request: %lx@%llx dir %d --- failed\n",
>> -             pci_name(pdev), size, (u64)paddr, dir);
>> +             pci_name(pdev), size, (unsigned long long)paddr, dir);
>
>Use dev_err() here and include IOMMU ID.

This patch set is mainly for porting IOMMU to IA64. I will add IOMMU ID and use dev_err() in a follow-up clean-up patch.

>> @@ -1953,11 +1974,11 @@ static void intel_unmap_single(struct device *dev, dma_addr_t dev_addr,
>>       if (!iova)
>>               return;
>>
>> -     start_addr = iova->pfn_lo << PAGE_SHIFT_4K;
>> +     start_addr = iova->pfn_lo << PAGE_SHIFT;
>>       size = aligned_size((u64)dev_addr, size);
>>
>>       pr_debug("Device %s unmapping: %lx@%llx\n",
>> -             pci_name(pdev), size, (u64)start_addr);
>> +             pci_name(pdev), size, (unsigned long long)start_addr);
>
>Use dev_dbg() here.

This patch set is mainly for porting IOMMU to IA64. I will change to dev_dbg() in a follow-up patch.

>> diff --git a/include/linux/dma_remapping.h b/include/linux/dma_remapping.h
>> index bff5c65..218598d 100644
>> --- a/include/linux/dma_remapping.h
>> +++ b/include/linux/dma_remapping.h
>> @@ -2,15 +2,15 @@
>>  #define _DMA_REMAPPING_H
>>
>>  /*
>> - * We need a fixed PAGE_SIZE of 4K irrespective of
>> - * arch PAGE_SIZE for IOMMU page tables.
>> + * VT-d hardware uses 4K page size regardless host page size.
>>   */
>> -#define PAGE_SHIFT_4K                (12)
>> -#define PAGE_SIZE_4K         (1UL << PAGE_SHIFT_4K)
>> -#define PAGE_MASK_4K         (((u64)-1) << PAGE_SHIFT_4K)
>> -#define PAGE_ALIGN_4K(addr)  (((addr) + PAGE_SIZE_4K - 1) & PAGE_MASK_4K)
>> +#define IOMMU_PAGE_SHIFT     (12)
>> +#define IOMMU_PAGE_SIZE              (1UL << IOMMU_PAGE_SHIFT)
>> +#define IOMMU_PAGE_MASK              (((u64)-1) << IOMMU_PAGE_SHIFT)
>> +#define IOMMU_PAGE_ALIGN(addr)       \
>> +     (((addr) + IOMMU_PAGE_SIZE - 1) & IOMMU_PAGE_MASK)
>>
>> -#define IOVA_PFN(addr)               ((addr) >> PAGE_SHIFT_4K)
>> +#define IOVA_PFN(addr)               ((addr) >> PAGE_SHIFT)
>
>These are pretty generic names (IOMMU_PAGE_SHIFT, IOVA_PFN, etc),
>but the definitions seem to be specific to VT-d.  I can't tell if
>this file is supposed to be sort of generic, or if it's Intel-specific.

I can change IOMMU_PAGE_SHIFT etc to VTD_PAGE_SHIFT etc and change IOVA_PFN to VTD_IOVA_PFN. What do you think?

>> diff --git a/include/linux/intel-iommu.h b/include/linux/intel-iommu.h
>> index e7b196b..d84612a 100644
>> --- a/include/linux/intel-iommu.h
>> +++ b/include/linux/intel-iommu.h
>> @@ -67,6 +67,13 @@
>>               hi = readl(dmar + reg + 4); \
>>               (((u64) hi) << 32) + lo; })
>>  */
>> +#ifdef CONFIG_IA64
>> +#define dmar_readq readq
>> +static inline void dmar_writeq(void __iomem *addr, u64 val)
>> +{
>> +     writeq(val, addr);
>> +}
>> +#else
>>  static inline u64 dmar_readq(void __iomem *addr)
>>  {
>>       u32 lo, hi;
>> @@ -80,6 +87,7 @@ static inline void dmar_writeq(void __iomem *addr, u64 val)
>>       writel((u32)val, addr);
>>       writel((u32)(val >> 32), addr + 4);
>>  }
>> +#endif
>
>What's this all about?  Why do we need #ifdef CONFIG_IA64 here?
>Doesn't x86 provide its own readq/writeq implementation?

Bjorn
