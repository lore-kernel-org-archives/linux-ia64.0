From: David Hildenbrand <david@redhat.com>
Date: Wed, 05 Jun 2019 09:00:28 +0000
Subject: Re: [PATCH v3 09/11] mm/memory_hotplug: Remove memory block devices before arch_remove_memory()
Message-Id: <38b8b004-9a26-e4ba-d8e3-a41c8fcc51c1@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190527111152.16324-1-david@redhat.com>
 <20190527111152.16324-10-david@redhat.com>
 <20190604220715.d4d2ctwjk25vd5sq@master>
In-Reply-To: <20190604220715.d4d2ctwjk25vd5sq@master>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Wei Yang <richard.weiyang@gmail.com>
Cc: Michal Hocko <mhocko@suse.com>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Chris Wilson <chris@chris-wilson.co.uk>, linux-mm@kvack.org, Arun KS <arunks@codeaurora.org>, Ingo Molnar <mingo@kernel.org>, linux-s390@vger.kernel.org, "Rafael J. Wysocki" <rafael@kernel.org>, Pavel Tatashin <pavel.tatashin@microsoft.com>, "mike.travis@hpe.com" <mike.travis@hpe.com>, Mark Brown <broonie@kernel.org>, Jonathan Cameron <Jonathan.Cameron@huawei.com>, Dan Williams <dan.j.williams@intel.com>, linux-arm-kernel@lists.infradead.org, Oscar Salvador <osalvador@suse.de>, Andrew Banman <andrew.banman@hpe.com>, Mathieu Malaterre <malat@debian.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, Alex Deucher <alexander.deucher@amd.com>, Igor Mammedov <imammedo@redhat.com>, akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>

On 05.06.19 00:07, Wei Yang wrote:
> On Mon, May 27, 2019 at 01:11:50PM +0200, David Hildenbrand wrote:
>> Let's factor out removing of memory block devices, which is only
>> necessary for memory added via add_memory() and friends that created
>> memory block devices. Remove the devices before calling
>> arch_remove_memory().
>>
>> This finishes factoring out memory block device handling from
>> arch_add_memory() and arch_remove_memory().
>>
>> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
>> Cc: "Rafael J. Wysocki" <rafael@kernel.org>
>> Cc: David Hildenbrand <david@redhat.com>
>> Cc: "mike.travis@hpe.com" <mike.travis@hpe.com>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: Andrew Banman <andrew.banman@hpe.com>
>> Cc: Ingo Molnar <mingo@kernel.org>
>> Cc: Alex Deucher <alexander.deucher@amd.com>
>> Cc: "David S. Miller" <davem@davemloft.net>
>> Cc: Mark Brown <broonie@kernel.org>
>> Cc: Chris Wilson <chris@chris-wilson.co.uk>
>> Cc: Oscar Salvador <osalvador@suse.de>
>> Cc: Jonathan Cameron <Jonathan.Cameron@huawei.com>
>> Cc: Michal Hocko <mhocko@suse.com>
>> Cc: Pavel Tatashin <pavel.tatashin@microsoft.com>
>> Cc: Arun KS <arunks@codeaurora.org>
>> Cc: Mathieu Malaterre <malat@debian.org>
>> Reviewed-by: Dan Williams <dan.j.williams@intel.com>
>> Signed-off-by: David Hildenbrand <david@redhat.com>
>> ---
>> drivers/base/memory.c  | 37 ++++++++++++++++++-------------------
>> drivers/base/node.c    | 11 ++++++-----
>> include/linux/memory.h |  2 +-
>> include/linux/node.h   |  6 ++----
>> mm/memory_hotplug.c    |  5 +++--
>> 5 files changed, 30 insertions(+), 31 deletions(-)
>>
>> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
>> index 5a0370f0c506..f28efb0bf5c7 100644
>> --- a/drivers/base/memory.c
>> +++ b/drivers/base/memory.c
>> @@ -763,32 +763,31 @@ int create_memory_block_devices(unsigned long start, unsigned long size)
>> 	return ret;
>> }
>>
>> -void unregister_memory_section(struct mem_section *section)
>> +/*
>> + * Remove memory block devices for the given memory area. Start and size
>> + * have to be aligned to memory block granularity. Memory block devices
>> + * have to be offline.
>> + */
>> +void remove_memory_block_devices(unsigned long start, unsigned long size)
>> {
>> +	const int start_block_id = pfn_to_block_id(PFN_DOWN(start));
>> +	const int end_block_id = pfn_to_block_id(PFN_DOWN(start + size));
>> 	struct memory_block *mem;
>> +	int block_id;
>>
>> -	if (WARN_ON_ONCE(!present_section(section)))
>> +	if (WARN_ON_ONCE(!IS_ALIGNED(start, memory_block_size_bytes()) ||
>> +			 !IS_ALIGNED(size, memory_block_size_bytes())))
>> 		return;
>>
>> 	mutex_lock(&mem_sysfs_mutex);
>> -
>> -	/*
>> -	 * Some users of the memory hotplug do not want/need memblock to
>> -	 * track all sections. Skip over those.
>> -	 */
>> -	mem = find_memory_block(section);
>> -	if (!mem)
>> -		goto out_unlock;
>> -
>> -	unregister_mem_sect_under_nodes(mem, __section_nr(section));
>> -
>> -	mem->section_count--;
>> -	if (mem->section_count = 0)
>> +	for (block_id = start_block_id; block_id != end_block_id; block_id++) {
>> +		mem = find_memory_block_by_id(block_id, NULL);
>> +		if (WARN_ON_ONCE(!mem))
>> +			continue;
>> +		mem->section_count = 0;
> 
> Is this step necessary?

It's what the previous code does, it might not be - I'll leave it like
that for now. As mentioned in another reply, I might remove the
section_count completely, eventually.

-- 

Thanks,

David / dhildenb
