From: Michal Hocko <mhocko@kernel.org>
Date: Mon, 01 Jul 2019 12:48:09 +0000
Subject: Re: [PATCH v3 04/11] arm64/mm: Add temporary arch_remove_memory() implementation
Message-Id: <20190701124809.GV6376@dhcp22.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190527111152.16324-1-david@redhat.com>
 <20190527111152.16324-5-david@redhat.com>
In-Reply-To: <20190527111152.16324-5-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Hildenbrand <david@redhat.com>
Cc: Mark Rutland <mark.rutland@arm.com>, linux-s390@vger.kernel.org, linux-ia64@vger.kernel.org, Yu Zhao <yuzhao@google.com>, Anshuman Khandual <anshuman.khandual@arm.com>, linux-sh@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, Wei Yang <richard.weiyang@gmail.com>, Jun Yao <yaojun8558363@gmail.com>, linux-mm@kvack.org, Chintan Pandya <cpandya@codeaurora.org>, Igor Mammedov <imammedo@redhat.com>, akpm@linux-foundation.org, Mike Rapoport <rppt@linux.ibm.com>, linuxppc-dev@lists.ozlabs.org, Dan Williams <dan.j.williams@intel.com>, linux-arm-kernel@lists.infradead.org, Robin Murphy <robin.murphy@arm.com>

On Mon 27-05-19 13:11:45, David Hildenbrand wrote:
> A proper arch_remove_memory() implementation is on its way, which also
> cleanly removes page tables in arch_add_memory() in case something goes
> wrong.
> 
> As we want to use arch_remove_memory() in case something goes wrong
> during memory hotplug after arch_add_memory() finished, let's add
> a temporary hack that is sufficient enough until we get a proper
> implementation that cleans up page table entries.
> 
> We will remove CONFIG_MEMORY_HOTREMOVE around this code in follow up
> patches.

I would drop this one as well (like s390 counterpart).
 
> Cc: Catalin Marinas <catalin.marinas@arm.com>
> Cc: Will Deacon <will.deacon@arm.com>
> Cc: Mark Rutland <mark.rutland@arm.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>
> Cc: Chintan Pandya <cpandya@codeaurora.org>
> Cc: Mike Rapoport <rppt@linux.ibm.com>
> Cc: Jun Yao <yaojun8558363@gmail.com>
> Cc: Yu Zhao <yuzhao@google.com>
> Cc: Robin Murphy <robin.murphy@arm.com>
> Cc: Anshuman Khandual <anshuman.khandual@arm.com>
> Signed-off-by: David Hildenbrand <david@redhat.com>
> ---
>  arch/arm64/mm/mmu.c | 19 +++++++++++++++++++
>  1 file changed, 19 insertions(+)
> 
> diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
> index a1bfc4413982..e569a543c384 100644
> --- a/arch/arm64/mm/mmu.c
> +++ b/arch/arm64/mm/mmu.c
> @@ -1084,4 +1084,23 @@ int arch_add_memory(int nid, u64 start, u64 size,
>  	return __add_pages(nid, start >> PAGE_SHIFT, size >> PAGE_SHIFT,
>  			   restrictions);
>  }
> +#ifdef CONFIG_MEMORY_HOTREMOVE
> +void arch_remove_memory(int nid, u64 start, u64 size,
> +			struct vmem_altmap *altmap)
> +{
> +	unsigned long start_pfn = start >> PAGE_SHIFT;
> +	unsigned long nr_pages = size >> PAGE_SHIFT;
> +	struct zone *zone;
> +
> +	/*
> +	 * FIXME: Cleanup page tables (also in arch_add_memory() in case
> +	 * adding fails). Until then, this function should only be used
> +	 * during memory hotplug (adding memory), not for memory
> +	 * unplug. ARCH_ENABLE_MEMORY_HOTREMOVE must not be
> +	 * unlocked yet.
> +	 */
> +	zone = page_zone(pfn_to_page(start_pfn));
> +	__remove_pages(zone, start_pfn, nr_pages, altmap);
> +}
> +#endif
>  #endif
> -- 
> 2.20.1

-- 
Michal Hocko
SUSE Labs
