From: Russell King - ARM Linux <linux@armlinux.org.uk>
Date: Wed, 11 May 2016 18:56:17 +0000
Subject: Re: [PATCH 11/12] kexec: allow architectures to override boot mapping
Message-Id: <20160511185616.GP19428@n2100.arm.linux.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20160428092644.GX19428@n2100.arm.linux.org.uk>
 <E1aviFU-0000jk-9q@rmk-PC.arm.linux.org.uk>
In-Reply-To: <E1aviFU-0000jk-9q@rmk-PC.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org
Cc: Mark Rutland <mark.rutland@arm.com>, devicetree@vger.kernel.org, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-doc@vger.kernel.org, Pawel Moll <pawel.moll@arm.com>, Jonathan Corbet <corbet@lwn.net>, Ian Campbell <ijc+devicetree@hellion.org.uk>, kexec@lists.infradead.org, Fenghua Yu <fenghua.yu@intel.com>, Haren Myneni <hbabu@us.ibm.com>, Rob Herring <robh+dt@kernel.org>, Eric Biederman <ebiederm@xmission.com>, Santosh Shilimkar <ssantosh@kernel.org>, Kumar Gala <galak@codeaurora.org>, Vivek Goyal <vgoyal@redhat.com>

I was going to send the patches to Andrew, but then I noticed this
one has received no acks.  What's the situation for this patch?

On Thu, Apr 28, 2016 at 10:28:40AM +0100, Russell King wrote:
> kexec physical addresses are the boot-time view of the system.  For
> certain ARM systems (such as Keystone 2), the boot view of the system
> does not match the kernel's view of the system: the boot view uses a
> special alias in the lower 4GB of the physical address space.
> 
> To cater for these kinds of setups, we need to translate between the
> boot view physical addresses and the normal kernel view physical
> addresses.  This patch extracts the current transation points into
> linux/kexec.h, and allows an architecture to override the functions.
> 
> Due to the translations required, we unfortunately end up with six
> translation functions, which are reduced down to four that the
> architecture can override.
> 
> Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
> ---
>  include/linux/kexec.h | 38 ++++++++++++++++++++++++++++++++++++++
>  kernel/kexec.c        |  3 ++-
>  kernel/kexec_core.c   | 26 +++++++++++++-------------
>  3 files changed, 53 insertions(+), 14 deletions(-)
> 
> diff --git a/include/linux/kexec.h b/include/linux/kexec.h
> index 52a3a221bcb2..99cb9dac7909 100644
> --- a/include/linux/kexec.h
> +++ b/include/linux/kexec.h
> @@ -318,6 +318,44 @@ int __weak arch_kexec_apply_relocations_add(const Elf_Ehdr *ehdr,
>  int __weak arch_kexec_apply_relocations(const Elf_Ehdr *ehdr, Elf_Shdr *sechdrs,
>  					unsigned int relsec);
>  
> +#ifndef page_to_boot_pfn
> +static inline unsigned long page_to_boot_pfn(struct page *page)
> +{
> +	return page_to_pfn(page);
> +}
> +#endif
> +
> +#ifndef boot_pfn_to_page
> +static inline struct page *boot_pfn_to_page(unsigned long boot_pfn)
> +{
> +	return pfn_to_page(boot_pfn);
> +}
> +#endif
> +
> +#ifndef phys_to_boot_phys
> +static inline unsigned long phys_to_boot_phys(phys_addr_t phys)
> +{
> +	return phys;
> +}
> +#endif
> +
> +#ifndef boot_phys_to_phys
> +static inline phys_addr_t boot_phys_to_phys(unsigned long boot_phys)
> +{
> +	return boot_phys;
> +}
> +#endif
> +
> +static inline unsigned long virt_to_boot_phys(void *addr)
> +{
> +	return phys_to_boot_phys(__pa((unsigned long)addr));
> +}
> +
> +static inline void *boot_phys_to_virt(unsigned long entry)
> +{
> +	return phys_to_virt(boot_phys_to_phys(entry));
> +}
> +
>  #else /* !CONFIG_KEXEC_CORE */
>  struct pt_regs;
>  struct task_struct;
> diff --git a/kernel/kexec.c b/kernel/kexec.c
> index ee70aef5cd81..dd49d572a5e2 100644
> --- a/kernel/kexec.c
> +++ b/kernel/kexec.c
> @@ -48,7 +48,8 @@ static int kimage_alloc_init(struct kimage **rimage, unsigned long entry,
>  
>  	if (kexec_on_panic) {
>  		/* Verify we have a valid entry point */
> -		if ((entry < crashk_res.start) || (entry > crashk_res.end))
> +		if ((entry < phys_to_boot_phys(crashk_res.start)) ||
> +		    (entry > phys_to_boot_phys(crashk_res.end)))
>  			return -EADDRNOTAVAIL;
>  	}
>  
> diff --git a/kernel/kexec_core.c b/kernel/kexec_core.c
> index f9847e5822e6..d04940ccc58d 100644
> --- a/kernel/kexec_core.c
> +++ b/kernel/kexec_core.c
> @@ -229,8 +229,8 @@ int sanity_check_segment_list(struct kimage *image)
>  			mstart = image->segment[i].mem;
>  			mend = mstart + image->segment[i].memsz - 1;
>  			/* Ensure we are within the crash kernel limits */
> -			if ((mstart < crashk_res.start) ||
> -			    (mend > crashk_res.end))
> +			if ((mstart < phys_to_boot_phys(crashk_res.start)) ||
> +			    (mend > phys_to_boot_phys(crashk_res.end)))
>  				return result;
>  		}
>  	}
> @@ -354,7 +354,7 @@ static struct page *kimage_alloc_normal_control_pages(struct kimage *image,
>  		pages = kimage_alloc_pages(KEXEC_CONTROL_MEMORY_GFP, order);
>  		if (!pages)
>  			break;
> -		pfn   = page_to_pfn(pages);
> +		pfn   = page_to_boot_pfn(pages);
>  		epfn  = pfn + count;
>  		addr  = pfn << PAGE_SHIFT;
>  		eaddr = epfn << PAGE_SHIFT;
> @@ -480,7 +480,7 @@ static int kimage_add_entry(struct kimage *image, kimage_entry_t entry)
>  			return -ENOMEM;
>  
>  		ind_page = page_address(page);
> -		*image->entry = virt_to_phys(ind_page) | IND_INDIRECTION;
> +		*image->entry = virt_to_boot_phys(ind_page) | IND_INDIRECTION;
>  		image->entry = ind_page;
>  		image->last_entry = ind_page +
>  				      ((PAGE_SIZE/sizeof(kimage_entry_t)) - 1);
> @@ -535,13 +535,13 @@ void kimage_terminate(struct kimage *image)
>  #define for_each_kimage_entry(image, ptr, entry) \
>  	for (ptr = &image->head; (entry = *ptr) && !(entry & IND_DONE); \
>  		ptr = (entry & IND_INDIRECTION) ? \
> -			phys_to_virt((entry & PAGE_MASK)) : ptr + 1)
> +			boot_phys_to_virt((entry & PAGE_MASK)) : ptr + 1)
>  
>  static void kimage_free_entry(kimage_entry_t entry)
>  {
>  	struct page *page;
>  
> -	page = pfn_to_page(entry >> PAGE_SHIFT);
> +	page = boot_pfn_to_page(entry >> PAGE_SHIFT);
>  	kimage_free_pages(page);
>  }
>  
> @@ -635,7 +635,7 @@ static struct page *kimage_alloc_page(struct kimage *image,
>  	 * have a match.
>  	 */
>  	list_for_each_entry(page, &image->dest_pages, lru) {
> -		addr = page_to_pfn(page) << PAGE_SHIFT;
> +		addr = page_to_boot_pfn(page) << PAGE_SHIFT;
>  		if (addr = destination) {
>  			list_del(&page->lru);
>  			return page;
> @@ -650,12 +650,12 @@ static struct page *kimage_alloc_page(struct kimage *image,
>  		if (!page)
>  			return NULL;
>  		/* If the page cannot be used file it away */
> -		if (page_to_pfn(page) >
> +		if (page_to_boot_pfn(page) >
>  				(KEXEC_SOURCE_MEMORY_LIMIT >> PAGE_SHIFT)) {
>  			list_add(&page->lru, &image->unusable_pages);
>  			continue;
>  		}
> -		addr = page_to_pfn(page) << PAGE_SHIFT;
> +		addr = page_to_boot_pfn(page) << PAGE_SHIFT;
>  
>  		/* If it is the destination page we want use it */
>  		if (addr = destination)
> @@ -678,7 +678,7 @@ static struct page *kimage_alloc_page(struct kimage *image,
>  			struct page *old_page;
>  
>  			old_addr = *old & PAGE_MASK;
> -			old_page = pfn_to_page(old_addr >> PAGE_SHIFT);
> +			old_page = boot_pfn_to_page(old_addr >> PAGE_SHIFT);
>  			copy_highpage(page, old_page);
>  			*old = addr | (*old & ~PAGE_MASK);
>  
> @@ -734,7 +734,7 @@ static int kimage_load_normal_segment(struct kimage *image,
>  			result  = -ENOMEM;
>  			goto out;
>  		}
> -		result = kimage_add_page(image, page_to_pfn(page)
> +		result = kimage_add_page(image, page_to_boot_pfn(page)
>  								<< PAGE_SHIFT);
>  		if (result < 0)
>  			goto out;
> @@ -795,7 +795,7 @@ static int kimage_load_crash_segment(struct kimage *image,
>  		char *ptr;
>  		size_t uchunk, mchunk;
>  
> -		page = pfn_to_page(maddr >> PAGE_SHIFT);
> +		page = boot_pfn_to_page(maddr >> PAGE_SHIFT);
>  		if (!page) {
>  			result  = -ENOMEM;
>  			goto out;
> @@ -922,7 +922,7 @@ void __weak crash_free_reserved_phys_range(unsigned long begin,
>  	unsigned long addr;
>  
>  	for (addr = begin; addr < end; addr += PAGE_SIZE)
> -		free_reserved_page(pfn_to_page(addr >> PAGE_SHIFT));
> +		free_reserved_page(boot_pfn_to_page(addr >> PAGE_SHIFT));
>  }
>  
>  int crash_shrink_memory(unsigned long new_size)
> -- 
> 2.1.0
> 
> 
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
