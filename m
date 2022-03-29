From: mawupeng <mawupeng1@huawei.com>
Date: Tue, 29 Mar 2022 01:14:50 +0000
Subject: Re: [PATCH 7/9] mm: Calc the right pfn if page size is not 4K
Message-Id: <931b1e5a-de85-f172-a834-1496bc45535e@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220326064632.131637-1-mawupeng1@huawei.com>
 <20220326064632.131637-8-mawupeng1@huawei.com>
 <15e3f11b-1551-a9c2-c348-bbe1ae1d9ef7@redhat.com>
In-Reply-To: <15e3f11b-1551-a9c2-c348-bbe1ae1d9ef7@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: david@redhat.com, akpm@linux-foundation.org, catalin.marinas@arm.com, will@kernel.org, corbet@lwn.net
Cc: ardb@kernel.org, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, dave.hansen@linux.intel.com, x86@kernel.org, hpa@zyccr.com, dvhart@infradead.org, andy@infradead.org, rppt@kernel.org, paulmck@kernel.org, peterz@infradead.org, jroedel@suse.de, songmuchun@bytedance.com, macro@orcam.me.uk, frederic@kernel.org, W_Armin@gmx.de, john.garry@huawei.com, seanjc@google.com, tsbogend@alpha.franken.de, anshuman.khandual@arm.com, chenhuacai@kernel.org, gpiccoli@igalia.com, mark.rutland@arm.com, wangkefeng.wang@huawei.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-efi@vger.kernel.org, linux-ia64@vger.kernel.org, platform-driver-x86@vger.kernel.org, linux-mm@kvack.org



在 2022/3/28 20:33, David Hildenbrand 写道:
> On 26.03.22 07:46, Wupeng Ma wrote:
>> From: Ma Wupeng <mawupeng1@huawei.com>
>>
>> Pervious 0x100000 is used to check the 4G limit in
> 
> s/Pervious/Previous/
> 
>> find_zone_movable_pfns_for_nodes(). This is right in x86 because
>> the page size can only be 4K. But 16K and 64K are available in
>> arm64. So replate it with SIZE_4G >> PAGE_SHIFT.
> 
> s/replate/replace/
> 
>>
>> Signed-off-by: Ma Wupeng <mawupeng1@huawei.com>
>> ---
>>   mm/page_alloc.c | 2 +-
>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 6e0b4596cde9..41fd987b5b93 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -7811,7 +7811,7 @@ static void __init find_zone_movable_pfns_for_nodes(void)
>>   
>>   			usable_startpfn = memblock_region_memory_base_pfn(r);
>>   
>> -			if (usable_startpfn < 0x100000) {
>> +			if (usable_startpfn < (SZ_4G >> PAGE_SHIFT)) {
> 
> PHYS_PFN(SZ_4G)
> 
> ?
> 
Thanks for reviewing, will be fixed in the next version.

Thanks.
>>   				mem_below_4gb_not_mirrored = true;
>>   				continue;
>>   			}
> 
> 
