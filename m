From: David Hildenbrand <david@redhat.com>
Date: Thu, 09 May 2019 12:50:11 +0000
Subject: Re: [PATCH v2 4/8] mm/memory_hotplug: Create memory block devices after arch_add_memory()
Message-Id: <85a81b34-4f8d-9649-939a-f722528e37ee@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190507183804.5512-1-david@redhat.com>
 <20190507183804.5512-5-david@redhat.com>
 <20190509124302.at7jltfrycj7sxbd@master>
In-Reply-To: <20190509124302.at7jltfrycj7sxbd@master>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Wei Yang <richard.weiyang@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, akpm@linux-foundation.org, Dan Williams <dan.j.williams@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rafael@kernel.org>, "mike.travis@hpe.com" <mike.travis@hpe.com>, Ingo Molnar <mingo@kernel.org>, Andrew Banman <andrew.banman@hpe.com>, Oscar Salvador <osalvador@suse.de>, Michal Hocko <mhocko@suse.com>, Pavel Tatashin <pasha.tatashin@soleen.com>, Qian Cai <cai@lca.pw>, Arun KS <arunks@codeaurora.org>, Mathieu Malaterre <malat@debian.org>

On 09.05.19 14:43, Wei Yang wrote:
> On Tue, May 07, 2019 at 08:38:00PM +0200, David Hildenbrand wrote:
>> Only memory to be added to the buddy and to be onlined/offlined by
>> user space using memory block devices needs (and should have!) memory
>> block devices.
>>
>> Factor out creation of memory block devices Create all devices after
>> arch_add_memory() succeeded. We can later drop the want_memblock parameter,
>> because it is now effectively stale.
>>
>> Only after memory block devices have been added, memory can be onlined
>> by user space. This implies, that memory is not visible to user space at
>> all before arch_add_memory() succeeded.
>>
>> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
>> Cc: "Rafael J. Wysocki" <rafael@kernel.org>
>> Cc: David Hildenbrand <david@redhat.com>
>> Cc: "mike.travis@hpe.com" <mike.travis@hpe.com>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: Ingo Molnar <mingo@kernel.org>
>> Cc: Andrew Banman <andrew.banman@hpe.com>
>> Cc: Oscar Salvador <osalvador@suse.de>
>> Cc: Michal Hocko <mhocko@suse.com>
>> Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
>> Cc: Qian Cai <cai@lca.pw>
>> Cc: Wei Yang <richard.weiyang@gmail.com>
>> Cc: Arun KS <arunks@codeaurora.org>
>> Cc: Mathieu Malaterre <malat@debian.org>
>> Signed-off-by: David Hildenbrand <david@redhat.com>
>> ---
>> drivers/base/memory.c  | 70 ++++++++++++++++++++++++++----------------
>> include/linux/memory.h |  2 +-
>> mm/memory_hotplug.c    | 15 ++++-----
>> 3 files changed, 53 insertions(+), 34 deletions(-)
>>
>> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
>> index 6e0cb4fda179..862c202a18ca 100644
>> --- a/drivers/base/memory.c
>> +++ b/drivers/base/memory.c
>> @@ -701,44 +701,62 @@ static int add_memory_block(int base_section_nr)
>> 	return 0;
>> }
>>
>> +static void unregister_memory(struct memory_block *memory)
>> +{
>> +	BUG_ON(memory->dev.bus != &memory_subsys);
>> +
>> +	/* drop the ref. we got via find_memory_block() */
>> +	put_device(&memory->dev);
>> +	device_unregister(&memory->dev);
>> +}
>> +
>> /*
>> - * need an interface for the VM to add new memory regions,
>> - * but without onlining it.
>> + * Create memory block devices for the given memory area. Start and size
>> + * have to be aligned to memory block granularity. Memory block devices
>> + * will be initialized as offline.
>>  */
>> -int hotplug_memory_register(int nid, struct mem_section *section)
>> +int hotplug_memory_register(unsigned long start, unsigned long size)
>> {
>> -	int ret = 0;
>> +	unsigned long block_nr_pages = memory_block_size_bytes() >> PAGE_SHIFT;
>> +	unsigned long start_pfn = PFN_DOWN(start);
>> +	unsigned long end_pfn = start_pfn + (size >> PAGE_SHIFT);
>> +	unsigned long pfn;
>> 	struct memory_block *mem;
>> +	int ret = 0;
>>
>> -	mutex_lock(&mem_sysfs_mutex);
>> +	BUG_ON(!IS_ALIGNED(start, memory_block_size_bytes()));
>> +	BUG_ON(!IS_ALIGNED(size, memory_block_size_bytes()));
> 
> After this change, the call flow looks like this:
> 
> add_memory_resource
>     check_hotplug_memory_range
>     hotplug_memory_register
> 
> Since in check_hotplug_memory_range() has checked the boundary, do we need to
> check here again?
> 

I prefer to check for such requirements explicitly in applicable places,
especially if they are placed in different files. Makes code easier to
get. WARN_ON_ONCE will indicate that this has to be assured by the caller.

Thanks!

-- 

Thanks,

David / dhildenb
