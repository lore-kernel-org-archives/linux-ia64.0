From: David Hildenbrand <david@redhat.com>
Date: Tue, 04 Jun 2019 06:56:15 +0000
Subject: Re: [PATCH v3 04/11] arm64/mm: Add temporary arch_remove_memory() implementation
Message-Id: <5059f68d-45d2-784e-0770-ee67060773c7@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190527111152.16324-1-david@redhat.com>
 <20190527111152.16324-5-david@redhat.com>
 <20190603214139.mercn5hol2yyfl2s@master>
In-Reply-To: <20190603214139.mercn5hol2yyfl2s@master>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Wei Yang <richard.weiyang@gmail.com>
Cc: Mark Rutland <mark.rutland@arm.com>, linux-s390@vger.kernel.org, linux-ia64@vger.kernel.org, Yu Zhao <yuzhao@google.com>, Anshuman Khandual <anshuman.khandual@arm.com>, linux-sh@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.ibm.com>, Jun Yao <yaojun8558363@gmail.com>, linux-mm@kvack.org, Chintan Pandya <cpandya@codeaurora.org>, Igor Mammedov <imammedo@redhat.com>, akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org, Dan Williams <dan.j.williams@intel.com>, linux-arm-kernel@lists.infradead.org, Robin Murphy <robin.murphy@arm.com>

On 03.06.19 23:41, Wei Yang wrote:
> On Mon, May 27, 2019 at 01:11:45PM +0200, David Hildenbrand wrote:
>> A proper arch_remove_memory() implementation is on its way, which also
>> cleanly removes page tables in arch_add_memory() in case something goes
>> wrong.
> 
> Would this be better to understand?
> 
>     removes page tables created in arch_add_memory

That's not what this sentence expresses. Have a look at
arch_add_memory(), in case  __add_pages() fails, the page tables are not
removed. This will also be fixed by Anshuman in the same shot.

> 
>>
>> As we want to use arch_remove_memory() in case something goes wrong
>> during memory hotplug after arch_add_memory() finished, let's add
>> a temporary hack that is sufficient enough until we get a proper
>> implementation that cleans up page table entries.
>>
>> We will remove CONFIG_MEMORY_HOTREMOVE around this code in follow up
>> patches.
>>
>> Cc: Catalin Marinas <catalin.marinas@arm.com>
>> Cc: Will Deacon <will.deacon@arm.com>
>> Cc: Mark Rutland <mark.rutland@arm.com>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>
>> Cc: Chintan Pandya <cpandya@codeaurora.org>
>> Cc: Mike Rapoport <rppt@linux.ibm.com>
>> Cc: Jun Yao <yaojun8558363@gmail.com>
>> Cc: Yu Zhao <yuzhao@google.com>
>> Cc: Robin Murphy <robin.murphy@arm.com>
>> Cc: Anshuman Khandual <anshuman.khandual@arm.com>
>> Signed-off-by: David Hildenbrand <david@redhat.com>
>> ---
>> arch/arm64/mm/mmu.c | 19 +++++++++++++++++++
>> 1 file changed, 19 insertions(+)
>>
>> diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
>> index a1bfc4413982..e569a543c384 100644
>> --- a/arch/arm64/mm/mmu.c
>> +++ b/arch/arm64/mm/mmu.c
>> @@ -1084,4 +1084,23 @@ int arch_add_memory(int nid, u64 start, u64 size,
>> 	return __add_pages(nid, start >> PAGE_SHIFT, size >> PAGE_SHIFT,
>> 			   restrictions);
>> }
>> +#ifdef CONFIG_MEMORY_HOTREMOVE
>> +void arch_remove_memory(int nid, u64 start, u64 size,
>> +			struct vmem_altmap *altmap)
>> +{
>> +	unsigned long start_pfn = start >> PAGE_SHIFT;
>> +	unsigned long nr_pages = size >> PAGE_SHIFT;
>> +	struct zone *zone;
>> +
>> +	/*
>> +	 * FIXME: Cleanup page tables (also in arch_add_memory() in case
>> +	 * adding fails). Until then, this function should only be used
>> +	 * during memory hotplug (adding memory), not for memory
>> +	 * unplug. ARCH_ENABLE_MEMORY_HOTREMOVE must not be
>> +	 * unlocked yet.
>> +	 */
>> +	zone = page_zone(pfn_to_page(start_pfn));
> 
> Compared with arch_remove_memory in x86. If altmap is not NULL, zone will be
> retrieved from page related to altmap. Not sure why this is not the same?

This is a minimal implementation, sufficient for this use case here. A
full implementation is in the works. For now, this function will not be
used with an altmap (ZONE_DEVICE is not esupported for arm64 yet).

Thanks!

> 
>> +	__remove_pages(zone, start_pfn, nr_pages, altmap);
>> +}
>> +#endif
>> #endif
>> -- 
>> 2.20.1
> 


-- 

Thanks,

David / dhildenb
