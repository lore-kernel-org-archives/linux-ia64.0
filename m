From: David Hildenbrand <david@redhat.com>
Date: Tue, 07 May 2019 21:27:17 +0000
Subject: Re: [PATCH v2 4/8] mm/memory_hotplug: Create memory block devices after arch_add_memory()
Message-Id: <a41438f2-6bac-a2ad-96ec-234762c1cd37@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190507183804.5512-1-david@redhat.com>
 <20190507183804.5512-5-david@redhat.com>
 <CAPcyv4jiVyaPbUrQwSiy65xk=EegJwuGSDKkVYWkGiTJz847gg@mail.gmail.com>
In-Reply-To: <CAPcyv4jiVyaPbUrQwSiy65xk=EegJwuGSDKkVYWkGiTJz847gg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dan Williams <dan.j.williams@intel.com>
Cc: Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, linux-s390 <linux-s390@vger.kernel.org>, Linux-sh <linux-sh@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rafael@kernel.org>, "mike.travis@hpe.com" <mike.travis@hpe.com>, Ingo Molnar <mingo@kernel.org>, Andrew Banman <andrew.banman@hpe.com>, Oscar Salvador <osalvador@suse.de>, Michal Hocko <mhocko@suse.com>, Pavel Tatashin <pasha.tatashin@soleen.com>, Qian Cai <cai@lca.pw>, Wei Yang <richard.weiyang@gmail.com>, Arun KS <arunks@codeaurora.org>, Mathieu Malaterre <malat@debian.org>

>> +static void unregister_memory(struct memory_block *memory)
>> +{
>> +       BUG_ON(memory->dev.bus != &memory_subsys);
> 
> Given this should never happen and only a future kernel developer
> might trip over it, do we really need to kill that developer's
> machine? I.e. s/BUG/WARN/? I guess an argument can be made to move
> such a change that to a follow-on patch since you're just preserving
> existing behavior, but I figure might as well address these as the
> code is refactored.

I assume only

if (WARN ...)
	return;

makes sense then, right?

> 
>> +
>> +       /* drop the ref. we got via find_memory_block() */
>> +       put_device(&memory->dev);
>> +       device_unregister(&memory->dev);
>> +}
>> +
>>  /*
>> - * need an interface for the VM to add new memory regions,
>> - * but without onlining it.
>> + * Create memory block devices for the given memory area. Start and size
>> + * have to be aligned to memory block granularity. Memory block devices
>> + * will be initialized as offline.
>>   */
>> -int hotplug_memory_register(int nid, struct mem_section *section)
>> +int hotplug_memory_register(unsigned long start, unsigned long size)
>>  {
>> -       int ret = 0;
>> +       unsigned long block_nr_pages = memory_block_size_bytes() >> PAGE_SHIFT;
>> +       unsigned long start_pfn = PFN_DOWN(start);
>> +       unsigned long end_pfn = start_pfn + (size >> PAGE_SHIFT);
>> +       unsigned long pfn;
>>         struct memory_block *mem;
>> +       int ret = 0;
>>
>> -       mutex_lock(&mem_sysfs_mutex);
>> +       BUG_ON(!IS_ALIGNED(start, memory_block_size_bytes()));
>> +       BUG_ON(!IS_ALIGNED(size, memory_block_size_bytes()));
> 
> Perhaps:
> 
>     if (WARN_ON(...))
>         return -EINVAL;
> 

Yes, guess this souldn't hurt.

>>
>> -       mem = find_memory_block(section);
>> -       if (mem) {
>> -               mem->section_count++;
>> -               put_device(&mem->dev);
>> -       } else {
>> -               ret = init_memory_block(&mem, section, MEM_OFFLINE);
>> +       mutex_lock(&mem_sysfs_mutex);
>> +       for (pfn = start_pfn; pfn != end_pfn; pfn += block_nr_pages) {
>> +               mem = find_memory_block(__pfn_to_section(pfn));
>> +               if (mem) {
>> +                       WARN_ON_ONCE(false);
> 
> ?? Isn't that a nop?

Yes, that makes no sense :)

Thanks!

-- 

Thanks,

David / dhildenb
