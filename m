From: David Hildenbrand <david@redhat.com>
Date: Thu, 09 May 2019 22:18:50 +0000
Subject: Re: [PATCH v2 4/8] mm/memory_hotplug: Create memory block devices after arch_add_memory()
Message-Id: <c5cfec90-8837-8d84-29fa-564e4e5923a1@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190507183804.5512-1-david@redhat.com>
 <20190507183804.5512-5-david@redhat.com>
 <20190509143151.zexjmwu3ikkmye7i@master>
 <28071389-372c-14eb-1209-02464726b4f0@redhat.com>
 <20190509215034.jl2qejw3pzqtbu5d@master>
In-Reply-To: <20190509215034.jl2qejw3pzqtbu5d@master>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Wei Yang <richard.weiyang@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, akpm@linux-foundation.org, Dan Williams <dan.j.williams@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rafael@kernel.org>, "mike.travis@hpe.com" <mike.travis@hpe.com>, Ingo Molnar <mingo@kernel.org>, Andrew Banman <andrew.banman@hpe.com>, Oscar Salvador <osalvador@suse.de>, Michal Hocko <mhocko@suse.com>, Pavel Tatashin <pasha.tatashin@soleen.com>, Qian Cai <cai@lca.pw>, Arun KS <arunks@codeaurora.org>, Mathieu Malaterre <malat@debian.org>

> Looks good to me.
> 
>>
>> (I would actually even prefer "memory_block_devices", because memory
>> blocks have different meanins)
>>
> 
> Agree with you, this comes to my mind sometime ago :-)

We have memblocks, memory_blocks  ... I guess memory_block_device is
unique :)

> 
>>>
>>> [...]
>>>
>>>> /*
>>>> @@ -1106,6 +1100,13 @@ int __ref add_memory_resource(int nid, struct resource *res)
>>>> 	if (ret < 0)
>>>> 		goto error;
>>>>
>>>> +	/* create memory block devices after memory was added */
>>>> +	ret = hotplug_memory_register(start, size);
>>>> +	if (ret) {
>>>> +		arch_remove_memory(nid, start, size, NULL);
>>>
>>> Functionally, it works I think.
>>>
>>> But arch_remove_memory() would remove pages from zone. At this point, we just
>>> allocate section/mmap for pages, the zones are empty and pages are not
>>> connected to zone.
>>>
>>> Function  zone = page_zone(page); always gets zone #0, since pages->flags is 0
>>> at  this point. This is not exact.
>>>
>>> Would we add some comment to mention this? Or we need to clean up
>>> arch_remove_memory() to take out __remove_zone()?
>>
>> That is precisely what is on my list next (see cover letter).This is
>> already broken when memory that was never onlined is removed again.
>> So I am planning to fix that independently.
>>
> 
> Sounds great :-)

Especially, I suspect a lot of bugs in the area of

1. Remove memory that has never been onlined
2. Remove memory that has been onlined/offlined a couple of times
3. Remove memory that has been onlined to different zones.

Will see when refactoring if my intuition is right :)

> 
> Hope you would cc me in the following series.


Sure! Thanks!


-- 

Thanks,

David / dhildenb
