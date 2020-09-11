From: David Hildenbrand <david@redhat.com>
Date: Fri, 11 Sep 2020 17:34:25 +0000
Subject: Re: [PATCH 1/3] mm: replace memmap_context by memplug_context
Message-Id: <a987f876-9d59-f998-b8ab-5f6b79b35ffb@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200911134831.53258-1-ldufour@linux.ibm.com>
 <20200911134831.53258-2-ldufour@linux.ibm.com>
 <09528ef5-29fd-056d-4e58-fc13e55f418f@redhat.com>
 <6552ef9a-ac02-e79f-2eb6-08380ba4b478@linux.ibm.com>
In-Reply-To: <6552ef9a-ac02-e79f-2eb6-08380ba4b478@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Laurent Dufour <ldufour@linux.ibm.com>, akpm@linux-foundation.org, Oscar Salvador <osalvador@suse.de>, mhocko@kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-mm@kvack.org, "Rafael J . Wysocki" <rafael@kernel.org>, nathanl@linux.ibm.com, cheloha@linux.ibm.com, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On 11.09.20 18:23, Laurent Dufour wrote:
> Le 11/09/2020 à 16:59, David Hildenbrand a écrit :
>>>   		struct page *start;
>>>   		struct memmap_init_callback_data args;
>>> diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
>>> index 375515803cd8..cd2bd21d3a4d 100644
>>> --- a/include/linux/memory_hotplug.h
>>> +++ b/include/linux/memory_hotplug.h
>>> @@ -15,6 +15,15 @@ struct memory_block;
>>>   struct resource;
>>>   struct vmem_altmap;
>>>   
>>> +/*
>>> + * Memory plugin context, use to differentiate memory added at boot time and
>>
>> "Memory plugin context" sounds weird.
> 
> Any suggestion ?
> 

I'm not a native speaker, but "plugin" sounds weird in this context.
Maybe simply drop it and start right away with "Differentiate memory
added ..."

-- 
Thanks,

David / dhildenb
