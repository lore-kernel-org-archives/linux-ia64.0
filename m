From: David Hildenbrand <david@redhat.com>
Date: Wed, 05 Jun 2019 21:50:52 +0000
Subject: Re: [PATCH v3 07/11] mm/memory_hotplug: Create memory block devices after arch_add_memory()
Message-Id: <4d29c1d6-d394-903d-28ae-733d55ac06f4@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190527111152.16324-1-david@redhat.com>
 <20190527111152.16324-8-david@redhat.com>
 <20190604214234.ltwtkcdoju2gxisx@master>
 <f6523d67-cac9-1189-884a-67b6829320ba@redhat.com>
 <9a1d282f-8dd9-a48b-cc96-f9afaa435c62@redhat.com>
 <20190605212249.s7knac6vimealdmx@master>
In-Reply-To: <20190605212249.s7knac6vimealdmx@master>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Wei Yang <richard.weiyang@gmail.com>
Cc: linux-s390@vger.kernel.org, Michal Hocko <mhocko@suse.com>, linux-ia64@vger.kernel.org, Pavel Tatashin <pasha.tatashin@soleen.com>, linux-sh@vger.kernel.org, "mike.travis@hpe.com" <mike.travis@hpe.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rafael@kernel.org>, Mathieu Malaterre <malat@debian.org>, linux-kernel@vger.kernel.org, Arun KS <arunks@codeaurora.org>, Ingo Molnar <mingo@kernel.org>, linux-mm@kvack.org, Andrew Banman <andrew.banman@hpe.com>, Qian Cai <cai@lca.pw>, Igor Mammedov <imammedo@redhat.com>, akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org, Dan Williams <dan.j.williams@intel.com>, linux-arm-kernel@lists.infradead.org, Oscar Salvador <osalvador@suse.de>

On 05.06.19 23:22, Wei Yang wrote:
> On Wed, Jun 05, 2019 at 12:58:46PM +0200, David Hildenbrand wrote:
>> On 05.06.19 10:58, David Hildenbrand wrote:
>>>>> /*
>>>>>  * For now, we have a linear search to go find the appropriate
>>>>>  * memory_block corresponding to a particular phys_index. If
>>>>> @@ -658,6 +670,11 @@ static int init_memory_block(struct memory_block **memory, int block_id,
>>>>> 	unsigned long start_pfn;
>>>>> 	int ret = 0;
>>>>>
>>>>> +	mem = find_memory_block_by_id(block_id, NULL);
>>>>> +	if (mem) {
>>>>> +		put_device(&mem->dev);
>>>>> +		return -EEXIST;
>>>>> +	}
>>>>
>>>> find_memory_block_by_id() is not that close to the main idea in this patch.
>>>> Would it be better to split this part?
>>>
>>> I played with that but didn't like the temporary results (e.g. having to
>>> export find_memory_block_by_id()). I'll stick to this for now.
>>>
>>>>
>>>>> 	mem = kzalloc(sizeof(*mem), GFP_KERNEL);
>>>>> 	if (!mem)
>>>>> 		return -ENOMEM;
>>>>> @@ -699,44 +716,53 @@ static int add_memory_block(int base_section_nr)
>>>>> 	return 0;
>>>>> }
>>>>>
>>>>> +static void unregister_memory(struct memory_block *memory)
>>>>> +{
>>>>> +	if (WARN_ON_ONCE(memory->dev.bus != &memory_subsys))
>>>>> +		return;
>>>>> +
>>>>> +	/* drop the ref. we got via find_memory_block() */
>>>>> +	put_device(&memory->dev);
>>>>> +	device_unregister(&memory->dev);
>>>>> +}
>>>>> +
>>>>> /*
>>>>> - * need an interface for the VM to add new memory regions,
>>>>> - * but without onlining it.
>>>>> + * Create memory block devices for the given memory area. Start and size
>>>>> + * have to be aligned to memory block granularity. Memory block devices
>>>>> + * will be initialized as offline.
>>>>>  */
>>>>> -int hotplug_memory_register(int nid, struct mem_section *section)
>>>>> +int create_memory_block_devices(unsigned long start, unsigned long size)
>>>>> {
>>>>> -	int block_id = base_memory_block_id(__section_nr(section));
>>>>> -	int ret = 0;
>>>>> +	const int start_block_id = pfn_to_block_id(PFN_DOWN(start));
>>>>> +	int end_block_id = pfn_to_block_id(PFN_DOWN(start + size));
>>>>> 	struct memory_block *mem;
>>>>> +	unsigned long block_id;
>>>>> +	int ret = 0;
>>>>>
>>>>> -	mutex_lock(&mem_sysfs_mutex);
>>>>> +	if (WARN_ON_ONCE(!IS_ALIGNED(start, memory_block_size_bytes()) ||
>>>>> +			 !IS_ALIGNED(size, memory_block_size_bytes())))
>>>>> +		return -EINVAL;
>>>>>
>>>>> -	mem = find_memory_block(section);
>>>>> -	if (mem) {
>>>>> -		mem->section_count++;
>>>>> -		put_device(&mem->dev);
>>>>> -	} else {
>>>>> +	mutex_lock(&mem_sysfs_mutex);
>>>>> +	for (block_id = start_block_id; block_id != end_block_id; block_id++) {
>>>>> 		ret = init_memory_block(&mem, block_id, MEM_OFFLINE);
>>>>> 		if (ret)
>>>>> -			goto out;
>>>>> -		mem->section_count++;
>>>>> +			break;
>>>>> +		mem->section_count = sections_per_block;
>>>>> +	}
>>>>> +	if (ret) {
>>>>> +		end_block_id = block_id;
>>>>> +		for (block_id = start_block_id; block_id != end_block_id;
>>>>> +		     block_id++) {
>>>>> +			mem = find_memory_block_by_id(block_id, NULL);
>>>>> +			mem->section_count = 0;
>>>>> +			unregister_memory(mem);
>>>>> +		}
>>>>> 	}
>>>>
>>>> Would it be better to do this in reverse order?
>>>>
>>>> And unregister_memory() would free mem, so it is still necessary to set
>>>> section_count to 0?
>>>
>>> 1. I kept the existing behavior (setting it to 0) for now. I am planning
>>> to eventually remove the section count completely (it could be
>>> beneficial to detect removing of partially populated memory blocks).
>>
>> Correction: We already use it to block offlining of partially populated
>> memory blocks \o/
> 
> Would you mind letting me know where we leverage this?

Sure:

drivers/base/memory.c:memory_subsys_offline()

if (mem->section_count != sections_per_block)
	return -EINVAL;

I would have expected such checks in the offline_pages() function instead.

-- 

Thanks,

David / dhildenb
