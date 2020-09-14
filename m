From: Laurent Dufour <ldufour@linux.ibm.com>
Date: Mon, 14 Sep 2020 08:51:06 +0000
Subject: Re: [PATCH 1/3] mm: replace memmap_context by memplug_context
Message-Id: <d3843235-2e02-a4ad-494c-20222a7e3b45@linux.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200911134831.53258-1-ldufour@linux.ibm.com>
 <20200911134831.53258-2-ldufour@linux.ibm.com>
 <20200914084904.GA16999@dhcp22.suse.cz>
In-Reply-To: <20200914084904.GA16999@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Michal Hocko <mhocko@suse.com>
Cc: akpm@linux-foundation.org, David Hildenbrand <david@redhat.com>, Oscar Salvador <osalvador@suse.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mm@kvack.org, "Rafael J . Wysocki" <rafael@kernel.org>, nathanl@linux.ibm.com, cheloha@linux.ibm.com, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Le 14/09/2020 à 10:49, Michal Hocko a écrit :
> On Fri 11-09-20 15:48:29, Laurent Dufour wrote:
>> The memmap_context is used to detect whether a memory operation is due to a
>> hot-add operation or happening at boot time.
>>
>> Makes it general to the hotplug operation, renaming it at memplug_context
>> and move its define in the corresponding header.
>>
>> There is no functional change introduced by this patch
> 
> I do not want to nit picking on naming but we want to look at this from
> the initialization POV rather than hotplug. So....
>>
>> Suggested-by: David Hildenbrand <david@redhat.com>
>> Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>
> [...]
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
>> + * hot-plugged memory.
>> + */
>> +enum memplug_context {
>> +	MEMPLUG_EARLY,
>> +	MEMPLUG_HOTPLUG,
>> +};
> 
> /*
>   * Memory initialization context, use to differentiate memory added by
>   * the platform statically or via memory hotplug interface.
>   */
> enum meminit_context {
> 	MEMINIT_EARLY,
> 	MEMINIT_HOTPLUG
> }
> 

Sounds good too.
What about its definition's place, in include/mm/zone.h as David suggested ?
