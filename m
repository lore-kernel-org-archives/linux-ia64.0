From: Amerigo Wang <amwang@redhat.com>
Date: Thu, 13 Aug 2009 08:23:32 +0000
Subject: Re: [Patch 8/8] kexec: allow to shrink reserved memory
Message-Id: <4A83CD84.8040609@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090812081731.5757.25254.sendpatchset@localhost.localdomain>	<20090812081906.5757.39417.sendpatchset@localhost.localdomain>	<m1bpmk8l1g.fsf@fess.ebiederm.org> <4A83893D.50707@redhat.com> <m1eirg5j9i.fsf@fess.ebiederm.org>
In-Reply-To: <m1eirg5j9i.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-mm@kvack.org, Neil Horman <nhorman@redhat.com>, Andi Kleen <andi@firstfloor.org>, akpm@linux-foundation.org, bernhard.walle@gmx.de, Fenghua Yu <fenghua.yu@intel.com>, Ingo Molnar <mingo@elte.hu>, Anton Vorontsov <avorontsov@ru.mvista.com>

Eric W. Biederman wrote:
> Amerigo Wang <amwang@redhat.com> writes:
>
>   
>>>   
>>>       
>>>> +	ret = kexec_crash_image != NULL;
>>>> +	mutex_unlock(&kexec_mutex);
>>>> +	return ret;
>>>> +}
>>>> +
>>>> +size_t get_crash_memory_size(void)
>>>> +{
>>>> +	size_t size;
>>>> +	if (!mutex_trylock(&kexec_mutex))
>>>> +		return 1;
>>>>     
>>>>         
>>> We don't need trylock on this code path 
>>>
>>>   
>>>       
>> Hmm, crashk_res is a global struct, so other process can also
>> change it... but currently no process does that, right?
>>
>>     
>
> We still need the lock.  Just doing trylock doesn't instead
> of just sleeping doesn't seem to make any sense on these
> code paths.
>
>   

Ok, got it.

>>>   
>>>       
>>>> +	start = crashk_res.start;
>>>> +	end = crashk_res.end;
>>>> +
>>>> +	if (new_size >= end - start + 1) {
>>>> +		ret = -EINVAL;
>>>> +		if (new_size = end - start + 1)
>>>> +			ret = 0;
>>>> +		goto unlock;
>>>> +	}
>>>> +
>>>> +	start = roundup(start, PAGE_SIZE);
>>>> +	end = roundup(start + new_size, PAGE_SIZE) - 1;
>>>> +	npages = (end + 1 - start ) / PAGE_SIZE;
>>>> +
>>>> +	pages = kmalloc(sizeof(struct page *) * npages, GFP_KERNEL);
>>>> +	if (!pages) {
>>>> +		ret = -ENOMEM;
>>>> +		goto unlock;
>>>> +	}
>>>> +	for (i = 0; i < npages; i++) {
>>>> +		addr = end + 1 + i * PAGE_SIZE;
>>>> +		pages[i] = virt_to_page(addr);
>>>> +	}
>>>> +
>>>> +	vaddr = vm_map_ram(pages, npages, 0, PAGE_KERNEL);
>>>>     
>>>>         
>>> This is the wrong kernel call to use.  I expect this needs to look
>>> like a memory hotplug event.  This does not put the pages into the
>>> free page pool.
>>>   
>>>       
>> Well, I also wanted to use an memory-hotplug API, but that will make the code
>> depend on memory-hotplug, which certainly is not what we want...
>>
>> I checked the mm code, actually what I need is an API which is similar to
>> add_active_range(), but add_active_range() can't be used here since it is marked
>> as "__init".
>>
>> Do we have that kind of API in mm? I can't find one.
>>     
>
> Perhaps we will need to remove __init from add_active_range.  I know the logic
> but I'm not up to speed on the mm pieces at the moment.
>   

Not that simple, marking it as "__init" means it uses some "__init" data 
which will be dropped after initialization.

Thanks.

