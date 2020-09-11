From: Laurent Dufour <ldufour@linux.ibm.com>
Date: Fri, 11 Sep 2020 16:23:00 +0000
Subject: Re: [PATCH 1/3] mm: replace memmap_context by memplug_context
Message-Id: <6552ef9a-ac02-e79f-2eb6-08380ba4b478@linux.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200911134831.53258-1-ldufour@linux.ibm.com>
 <20200911134831.53258-2-ldufour@linux.ibm.com>
 <09528ef5-29fd-056d-4e58-fc13e55f418f@redhat.com>
In-Reply-To: <09528ef5-29fd-056d-4e58-fc13e55f418f@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: David Hildenbrand <david@redhat.com>, akpm@linux-foundation.org, Oscar Salvador <osalvador@suse.de>, mhocko@kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-mm@kvack.org, "Rafael J . Wysocki" <rafael@kernel.org>, nathanl@linux.ibm.com, cheloha@linux.ibm.com, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Le 11/09/2020 à 16:59, David Hildenbrand a écrit :
>>   		struct page *start;
>>   		struct memmap_init_callback_data args;
>> diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
>> index 375515803cd8..cd2bd21d3a4d 100644
>> --- a/include/linux/memory_hotplug.h
>> +++ b/include/linux/memory_hotplug.h
>> @@ -15,6 +15,15 @@ struct memory_block;
>>   struct resource;
>>   struct vmem_altmap;
>>   
>> +/*
>> + * Memory plugin context, use to differentiate memory added at boot time and
> 
> "Memory plugin context" sounds weird.

Any suggestion ?

>> + * hot-plugged memory.
>> + */
>> +enum memplug_context {
>> +	MEMPLUG_EARLY,
>> +	MEMPLUG_HOTPLUG,
>> +};
> 
> Not fully sure this is the right place, though. memory_hotplug.h is
> about MEMPLUG_HOTPLUG only ... I'd leave it at the old spot.

Fair enough.
