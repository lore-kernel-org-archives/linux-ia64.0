From: David Hildenbrand <david@redhat.com>
Date: Thu, 09 May 2019 14:58:56 +0000
Subject: Re: [PATCH v2 4/8] mm/memory_hotplug: Create memory block devices after arch_add_memory()
Message-Id: <28071389-372c-14eb-1209-02464726b4f0@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190507183804.5512-1-david@redhat.com>
 <20190507183804.5512-5-david@redhat.com>
 <20190509143151.zexjmwu3ikkmye7i@master>
In-Reply-To: <20190509143151.zexjmwu3ikkmye7i@master>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Wei Yang <richard.weiyang@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, akpm@linux-foundation.org, Dan Williams <dan.j.williams@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rafael@kernel.org>, "mike.travis@hpe.com" <mike.travis@hpe.com>, Ingo Molnar <mingo@kernel.org>, Andrew Banman <andrew.banman@hpe.com>, Oscar Salvador <osalvador@suse.de>, Michal Hocko <mhocko@suse.com>, Pavel Tatashin <pasha.tatashin@soleen.com>, Qian Cai <cai@lca.pw>, Arun KS <arunks@codeaurora.org>, Mathieu Malaterre <malat@debian.org>

On 09.05.19 16:31, Wei Yang wrote:
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
> 
> One trivial suggestion about the function name.
> 
> For memory_block device, sometimes we use the full name
> 
>     find_memory_block
>     init_memory_block
>     add_memory_block
> 
> But sometimes we use *nick* name
> 
>     hotplug_memory_register
>     register_memory
>     unregister_memory
> 
> This is a little bit confusion.
> 
> Can we use one name convention here?

We can just go for

crate_memory_blocks() and free_memory_blocks(). Or do
you have better suggestions?

(I would actually even prefer "memory_block_devices", because memory
blocks have different meanins)

> 
> [...]
> 
>> /*
>> @@ -1106,6 +1100,13 @@ int __ref add_memory_resource(int nid, struct resource *res)
>> 	if (ret < 0)
>> 		goto error;
>>
>> +	/* create memory block devices after memory was added */
>> +	ret = hotplug_memory_register(start, size);
>> +	if (ret) {
>> +		arch_remove_memory(nid, start, size, NULL);
> 
> Functionally, it works I think.
> 
> But arch_remove_memory() would remove pages from zone. At this point, we just
> allocate section/mmap for pages, the zones are empty and pages are not
> connected to zone.
> 
> Function  zone = page_zone(page); always gets zone #0, since pages->flags is 0
> at  this point. This is not exact.
> 
> Would we add some comment to mention this? Or we need to clean up
> arch_remove_memory() to take out __remove_zone()?

That is precisely what is on my list next (see cover letter).This is
already broken when memory that was never onlined is removed again.
So I am planning to fix that independently.


-- 

Thanks,

David / dhildenb
