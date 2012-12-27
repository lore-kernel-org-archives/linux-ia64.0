From: Tang Chen <tangchen@cn.fujitsu.com>
Date: Thu, 27 Dec 2012 03:10:56 +0000
Subject: Re: [PATCH v5 02/14] memory-hotplug: check whether all memory blocks are offlined or not when removi
Message-Id: <50DBBC40.6040700@cn.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1356350964-13437-1-git-send-email-tangchen@cn.fujitsu.com> <1356350964-13437-3-git-send-email-tangchen@cn.fujitsu.com> <50DA6AB3.2030608@jp.fujitsu.com>
In-Reply-To: <50DA6AB3.2030608@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: akpm@linux-foundation.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wujianguo@huawei.com, wency@cn.fujitsu.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org

On 12/26/2012 11:10 AM, Kamezawa Hiroyuki wrote:
> (2012/12/24 21:09), Tang Chen wrote:
>> From: Yasuaki Ishimatsu<isimatu.yasuaki@jp.fujitsu.com>
>>
>> We remove the memory like this:
>> 1. lock memory hotplug
>> 2. offline a memory block
>> 3. unlock memory hotplug
>> 4. repeat 1-3 to offline all memory blocks
>> 5. lock memory hotplug
>> 6. remove memory(TODO)
>> 7. unlock memory hotplug
>>
>> All memory blocks must be offlined before removing memory. But we don't hold
>> the lock in the whole operation. So we should check whether all memory blocks
>> are offlined before step6. Otherwise, kernel maybe panicked.
>>
>> Signed-off-by: Wen Congyang<wency@cn.fujitsu.com>
>> Signed-off-by: Yasuaki Ishimatsu<isimatu.yasuaki@jp.fujitsu.com>
> 
> Acked-by: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
> 
> a nitpick below.
> 
>> +
>> +	for (pfn = start_pfn; pfn<  end_pfn; pfn += PAGES_PER_SECTION) {
> 
> I prefer adding mem = NULL at the start of this for().

Hi Kamezawa-san,

Added, thanks. :)

> 
>> +		section_nr = pfn_to_section_nr(pfn);
>> +		if (!present_section_nr(section_nr))
>> +			continue;
>> +
>> +		section = __nr_to_section(section_nr);
>> +		/* same memblock? */
>> +		if (mem)
>> +			if ((section_nr>= mem->start_section_nr)&&
>> +			    (section_nr<= mem->end_section_nr))
>> +				continue;
>> +
> 
> Thanks,
> -Kame
> 
> 
> 

