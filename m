From: Wen Congyang <wency@cn.fujitsu.com>
Date: Mon, 30 Jul 2012 10:35:37 +0000
Subject: Re: [RFC PATCH v5 12/19] memory-hotplug: introduce new function arch_remove_memory()
Message-Id: <50166379.4090305@cn.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <50126B83.3050201@cn.fujitsu.com> <50126E2F.8010301@cn.fujitsu.com> <20120730102305.GB3631@osiris.boeblingen.de.ibm.com>
In-Reply-To: <20120730102305.GB3631@osiris.boeblingen.de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, Yasuaki ISIMATU <isimatu.yasuaki@jp.fujitsu.com>

At 07/30/2012 06:23 PM, Heiko Carstens Wrote:
> On Fri, Jul 27, 2012 at 06:32:15PM +0800, Wen Congyang wrote:
>> We don't call __add_pages() directly in the function add_memory()
>> because some other architecture related things need to be done
>> before or after calling __add_pages(). So we should introduce
>> a new function arch_remove_memory() to revert the things
>> done in arch_add_memory().
>>
>> Note: the function for s390 is not implemented(I don't know how to
>> implement it for s390).
> 
> There is no hardware or firmware interface which could trigger a
> hot memory remove on s390. So there is nothing that needs to be
> implemented.

Thanks for providing this information.

According to this, arch_remove_memory() for s390 can just return -EBUSY.

Thanks
Wen Congyang

> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-acpi" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

