From: Wen Congyang <wency@cn.fujitsu.com>
Date: Wed, 01 Aug 2012 01:42:22 +0000
Subject: Re: [RFC PATCH v5 12/19] memory-hotplug: introduce new function arch_remove_memory()
Message-Id: <5018897E.4040109@cn.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <50126B83.3050201@cn.fujitsu.com>	<50126E2F.8010301@cn.fujitsu.com>	<20120730102305.GB3631@osiris.boeblingen.de.ibm.com>	<50166379.4090305@cn.fujitsu.com>
 <20120731144000.33fd4a0a@thinkpad>
In-Reply-To: <20120731144000.33fd4a0a@thinkpad>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: gerald.schaefer@de.ibm.com
Cc: linux-s390@vger.kernel.org, linux-ia64@vger.kernel.org, len.brown@intel.com, linux-acpi@vger.kernel.org, linux-sh@vger.kernel.org, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-kernel@vger.kernel.org, cmetcalf@tilera.com, linux-mm@kvack.org, Yasuaki ISIMATU <isimatu.yasuaki@jp.fujitsu.com>, paulus@samba.org, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, rientjes@google.com, cl@linux.com, linuxppc-dev@lists.ozlabs.org, akpm@linux-foundation.org, liuj97@gmail.com

At 07/31/2012 08:40 PM, Gerald Schaefer Wrote:
> On Mon, 30 Jul 2012 18:35:37 +0800
> Wen Congyang <wency@cn.fujitsu.com> wrote:
> 
>> At 07/30/2012 06:23 PM, Heiko Carstens Wrote:
>>> On Fri, Jul 27, 2012 at 06:32:15PM +0800, Wen Congyang wrote:
>>>> We don't call __add_pages() directly in the function add_memory()
>>>> because some other architecture related things need to be done
>>>> before or after calling __add_pages(). So we should introduce
>>>> a new function arch_remove_memory() to revert the things
>>>> done in arch_add_memory().
>>>>
>>>> Note: the function for s390 is not implemented(I don't know how to
>>>> implement it for s390).
>>>
>>> There is no hardware or firmware interface which could trigger a
>>> hot memory remove on s390. So there is nothing that needs to be
>>> implemented.
>>
>> Thanks for providing this information.
>>
>> According to this, arch_remove_memory() for s390 can just return
>> -EBUSY.
> 
> Yes, but there is a prototype mismatch for arch_remove_memory() on s390
> and also other architectures (u64 vs. unsigned long).
> 
> arch/s390/mm/init.c:262: error: conflicting types for
> ‘arch_remove_memory’ include/linux/memory_hotplug.h:88: error: previous
> declaration of ‘arch_remove_memory’ was here
> 
> In memory_hotplug.h you have:
> extern int arch_remove_memory(unsigned long start, unsigned long size);
> 
> On all archs other than x86 you have:
> int arch_remove_memory(u64 start, u64 size)

Thanks for pointing it out. I will fix it.

Wen Congyang

> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

