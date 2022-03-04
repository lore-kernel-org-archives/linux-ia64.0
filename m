From: Dongli Zhang <dongli.zhang@oracle.com>
Date: Fri, 04 Mar 2022 18:27:50 +0000
Subject: Re: [PATCH 10/12] swiotlb: add a SWIOTLB_ANY flag to lift the low memory restriction
Message-Id: <556312e4-da86-b980-475c-1cfd7818ffdc@oracle.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220301105311.885699-1-hch@lst.de>
 <20220301105311.885699-11-hch@lst.de>
 <MN0PR21MB3098F7AFC85BE5D83B0E64E5D7059@MN0PR21MB3098.namprd21.prod.outlook.com>
In-Reply-To: <MN0PR21MB3098F7AFC85BE5D83B0E64E5D7059@MN0PR21MB3098.namprd21.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Michael Kelley (LINUX)" <mikelley@microsoft.com>, Christoph Hellwig <hch@lst.de>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>
Cc: "x86@kernel.org" <x86@kernel.org>, Anshuman Khandual <anshuman.khandual@arm.com>, Tom Lendacky <thomas.lendacky@amd.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Stefano Stabellini <sstabellini@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Joerg Roedel <joro@8bytes.org>, David Woodhouse <dwmw2@infradead.org>, Lu Baolu <baolu.lu@linux.intel.com>, Robin Murphy <robin.murphy@arm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-mips@vger.kernel.org" <linux-mips@vger.kernel.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "linux-riscv@lists.infradead.org" <linux-riscv@lists.infradead.org>, "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>, "linux-hyperv@vger.kernel.org" <linux-hyperv@vger.kernel.org>, "tboot-devel@lists.sourceforge.net" <tboot-devel@lists.sourceforge.net>, "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>

Hi Michael,

On 3/4/22 10:12 AM, Michael Kelley (LINUX) wrote:
> From: Christoph Hellwig <hch@lst.de> Sent: Tuesday, March 1, 2022 2:53 AM
>>
>> Power SVM wants to allocate a swiotlb buffer that is not restricted to low memory for
>> the trusted hypervisor scheme.  Consolidate the support for this into the swiotlb_init
>> interface by adding a new flag.
> 
> Hyper-V Isolated VMs want to do the same thing of not restricting the swiotlb
> buffer to low memory.  That's what Tianyu Lan's patch set[1] is proposing.
> Hyper-V synthetic devices have no DMA addressing limitations, and the
> likelihood of using a PCI pass-thru device with addressing limitations in an
> Isolated VM seems vanishingly small.
> 
> So could use of the SWIOTLB_ANY flag be generalized?  Let Hyper-V init
> code set the flag before swiotlb_init() is called.  Or provide a CONFIG
> variable that Hyper-V Isolated VMs could set.

I used to send 64-bit swiotlb, while at that time people thought it was the same
as Restricted DMA patchset.

https://lore.kernel.org/all/20210203233709.19819-1-dongli.zhang@oracle.com/

However, I do not think Restricted DMA patchset is going to supports 64-bit (or
high memory) DMA. Is this what you are looking for?

Dongli Zhang

> 
> Michael
> 
> [1] https://urldefense.com/v3/__https://lore.kernel.org/lkml/20220209122302.213882-1-ltykernel@gmail.com/__;!!ACWV5N9M2RV99hQ!fUx4fMgdQIrqJDDy-pbv9xMeyHX0rC6iN8176LWjylI2_lsjy03gysm0-lAbV1Yb7_g$ 
> 
>>
>> Signed-off-by: Christoph Hellwig <hch@lst.de>
>> ---
>>  arch/powerpc/include/asm/svm.h       |  4 ----
>>  arch/powerpc/include/asm/swiotlb.h   |  1 +
>>  arch/powerpc/kernel/dma-swiotlb.c    |  1 +
>>  arch/powerpc/mm/mem.c                |  5 +----
>>  arch/powerpc/platforms/pseries/svm.c | 26 +-------------------------
>>  include/linux/swiotlb.h              |  1 +
>>  kernel/dma/swiotlb.c                 |  9 +++++++--
>>  7 files changed, 12 insertions(+), 35 deletions(-)
>>
>> diff --git a/arch/powerpc/include/asm/svm.h b/arch/powerpc/include/asm/svm.h
>> index 7546402d796af..85580b30aba48 100644
>> --- a/arch/powerpc/include/asm/svm.h
>> +++ b/arch/powerpc/include/asm/svm.h
>> @@ -15,8 +15,6 @@ static inline bool is_secure_guest(void)
>>  	return mfmsr() & MSR_S;
>>  }
>>
>> -void __init svm_swiotlb_init(void);
>> -
>>  void dtl_cache_ctor(void *addr);
>>  #define get_dtl_cache_ctor()	(is_secure_guest() ? dtl_cache_ctor : NULL)
>>
>> @@ -27,8 +25,6 @@ static inline bool is_secure_guest(void)
>>  	return false;
>>  }
>>
>> -static inline void svm_swiotlb_init(void) {}
>> -
>>  #define get_dtl_cache_ctor() NULL
>>
>>  #endif /* CONFIG_PPC_SVM */
>> diff --git a/arch/powerpc/include/asm/swiotlb.h
>> b/arch/powerpc/include/asm/swiotlb.h
>> index 3c1a1cd161286..4203b5e0a88ed 100644
>> --- a/arch/powerpc/include/asm/swiotlb.h
>> +++ b/arch/powerpc/include/asm/swiotlb.h
>> @@ -9,6 +9,7 @@
>>  #include <linux/swiotlb.h>
>>
>>  extern unsigned int ppc_swiotlb_enable;
>> +extern unsigned int ppc_swiotlb_flags;
>>
>>  #ifdef CONFIG_SWIOTLB
>>  void swiotlb_detect_4g(void);
>> diff --git a/arch/powerpc/kernel/dma-swiotlb.c b/arch/powerpc/kernel/dma-
>> swiotlb.c
>> index fc7816126a401..ba256c37bcc0f 100644
>> --- a/arch/powerpc/kernel/dma-swiotlb.c
>> +++ b/arch/powerpc/kernel/dma-swiotlb.c
>> @@ -10,6 +10,7 @@
>>  #include <asm/swiotlb.h>
>>
>>  unsigned int ppc_swiotlb_enable;
>> +unsigned int ppc_swiotlb_flags;
>>
>>  void __init swiotlb_detect_4g(void)
>>  {
>> diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c index
>> e1519e2edc656..a4d65418c30a9 100644
>> --- a/arch/powerpc/mm/mem.c
>> +++ b/arch/powerpc/mm/mem.c
>> @@ -249,10 +249,7 @@ void __init mem_init(void)
>>  	 * back to to-down.
>>  	 */
>>  	memblock_set_bottom_up(true);
>> -	if (is_secure_guest())
>> -		svm_swiotlb_init();
>> -	else
>> -		swiotlb_init(ppc_swiotlb_enable, 0);
>> +	swiotlb_init(ppc_swiotlb_enable, ppc_swiotlb_flags);
>>  #endif
>>
>>  	high_memory = (void *) __va(max_low_pfn * PAGE_SIZE); diff --git
>> a/arch/powerpc/platforms/pseries/svm.c b/arch/powerpc/platforms/pseries/svm.c
>> index c5228f4969eb2..3b4045d508ec8 100644
>> --- a/arch/powerpc/platforms/pseries/svm.c
>> +++ b/arch/powerpc/platforms/pseries/svm.c
>> @@ -28,7 +28,7 @@ static int __init init_svm(void)
>>  	 * need to use the SWIOTLB buffer for DMA even if dma_capable() says
>>  	 * otherwise.
>>  	 */
>> -	swiotlb_force = SWIOTLB_FORCE;
>> +	ppc_swiotlb_flags |= SWIOTLB_ANY | SWIOTLB_FORCE;
>>
>>  	/* Share the SWIOTLB buffer with the host. */
>>  	swiotlb_update_mem_attributes();
>> @@ -37,30 +37,6 @@ static int __init init_svm(void)  }  machine_early_initcall(pseries,
>> init_svm);
>>
>> -/*
>> - * Initialize SWIOTLB. Essentially the same as swiotlb_init(), except that it
>> - * can allocate the buffer anywhere in memory. Since the hypervisor doesn't have
>> - * any addressing limitation, we don't need to allocate it in low addresses.
>> - */
>> -void __init svm_swiotlb_init(void)
>> -{
>> -	unsigned char *vstart;
>> -	unsigned long bytes, io_tlb_nslabs;
>> -
>> -	io_tlb_nslabs = (swiotlb_size_or_default() >> IO_TLB_SHIFT);
>> -	io_tlb_nslabs = ALIGN(io_tlb_nslabs, IO_TLB_SEGSIZE);
>> -
>> -	bytes = io_tlb_nslabs << IO_TLB_SHIFT;
>> -
>> -	vstart = memblock_alloc(PAGE_ALIGN(bytes), PAGE_SIZE);
>> -	if (vstart && !swiotlb_init_with_tbl(vstart, io_tlb_nslabs, false))
>> -		return;
>> -
>> -
>> -	memblock_free(vstart, PAGE_ALIGN(io_tlb_nslabs << IO_TLB_SHIFT));
>> -	panic("SVM: Cannot allocate SWIOTLB buffer");
>> -}
>> -
>>  int set_memory_encrypted(unsigned long addr, int numpages)  {
>>  	if (!cc_platform_has(CC_ATTR_MEM_ENCRYPT))
>> diff --git a/include/linux/swiotlb.h b/include/linux/swiotlb.h index
>> dcecf953f7997..ee655f2e4d28b 100644
>> --- a/include/linux/swiotlb.h
>> +++ b/include/linux/swiotlb.h
>> @@ -15,6 +15,7 @@ struct scatterlist;
>>
>>  #define SWIOTLB_VERBOSE	(1 << 0) /* verbose initialization */
>>  #define SWIOTLB_FORCE	(1 << 1) /* force bounce buffering */
>> +#define SWIOTLB_ANY	(1 << 2) /* allow any memory for the buffer */
>>
>>  /*
>>   * Maximum allowable number of contiguous slabs to map, diff --git
>> a/kernel/dma/swiotlb.c b/kernel/dma/swiotlb.c index 1a40c71c4d51a..77cf73dc20a78
>> 100644
>> --- a/kernel/dma/swiotlb.c
>> +++ b/kernel/dma/swiotlb.c
>> @@ -275,8 +275,13 @@ void __init swiotlb_init(bool addressing_limit, unsigned int
>> flags)
>>  	if (swiotlb_force_disable)
>>  		return;
>>
>> -	/* Get IO TLB memory from the low pages */
>> -	tlb = memblock_alloc_low(bytes, PAGE_SIZE);
>> +	/*
>> +	 * By default allocate the bonuce buffer memory from low memory.
>> +	 */
>> +	if (flags & SWIOTLB_ANY)
>> +		tlb = memblock_alloc(bytes, PAGE_SIZE);
>> +	else
>> +		tlb = memblock_alloc_low(bytes, PAGE_SIZE);
>>  	if (!tlb)
>>  		goto fail;
>>  	if (swiotlb_init_with_tbl(tlb, default_nslabs, flags))
>> --
>> 2.30.2
> 
> 
