From: Laurent Dufour <ldufour@linux.ibm.com>
Date: Mon, 14 Sep 2020 08:39:49 +0000
Subject: Re: [PATCH 2/3] mm: don't rely on system state to detect hot-plug operations
Message-Id: <678b596a-4d40-be88-daf0-c2edb16dd295@linux.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200911134831.53258-1-ldufour@linux.ibm.com>
 <20200911134831.53258-3-ldufour@linux.ibm.com>
 <f50fe4ae-faf0-6e03-b87e-45ca8c53960d@redhat.com>
 <20200914081921.GA15113@linux>
In-Reply-To: <20200914081921.GA15113@linux>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Oscar Salvador <osalvador@suse.de>, David Hildenbrand <david@redhat.com>
Cc: akpm@linux-foundation.org, mhocko@kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mm@kvack.org, "Rafael J . Wysocki" <rafael@kernel.org>, nathanl@linux.ibm.com, cheloha@linux.ibm.com, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org, Michal Hocko <mhocko@suse.com>

Le 14/09/2020 à 10:19, Oscar Salvador a écrit :
> On Mon, Sep 14, 2020 at 09:57:46AM +0200, David Hildenbrand wrote:
>>>   /* register memory section under specified node if it spans that node */
>>> +struct rmsun_args {
>>> +	int nid;
>>> +	enum memplug_context context;
>>> +};
> 
> Uhmf, that is a not so descriptive name.

I do agree, but didn't have a better idea.
Anyway this will disappear since the choosen direction is to have 2 callbacks.

> 
>> Instead of handling this in register_mem_sect_under_node(), I
>> think it would be better two have two separate
>> register_mem_sect_under_node() implementations.
>>
>> static int register_mem_sect_under_node_hotplug(struct memory_block *mem_blk,
>> 						void *arg)
>> {
>> 	const int nid = *(int *)arg;
>> 	int ret;
>>
>> 	/* Hotplugged memory has no holes and belongs to a single node. */
>> 	mem_blk->nid = nid;
>> 	ret = sysfs_create_link_nowarn(&node_devices[nid]->dev.kobj,
>> 				       &mem_blk->dev.kobj,
>> 				       kobject_name(&mem_blk->dev.kobj));
>> 	if (ret)
>> 		returnr et;
>> 	return sysfs_create_link_nowarn(&mem_blk->dev.kobj,
>> 					&node_devices[nid]->dev.kobj,
>> 					kobject_name(&node_devices[nid]->dev.kobj));
>>
>> }
>>
>> Cleaner, right? :) No unnecessary checks.
> 
> I tend to agree here, I like more a simplistic version for hotplug.
> 
>> One could argue if link_mem_section_hotplug() would be better than passing around the context.
> 
> I am not sure if I would duplicate the code there.
> We could just pass the pointer of the function we want to call to
> link_mem_sections? either register_mem_sect_under_node_hotplug or
> register_mem_sect_under_node_early?
> Would not that be clean and clear enough?

That would expose the register_mem_sect_under_node*() prototype to the caller.

I'm wondering if that would be cleaner than passing a MEMPLUG_* constant value 
to link_mem_sections() and let it choose the right callback.
