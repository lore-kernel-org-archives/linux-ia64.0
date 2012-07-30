From: Wen Congyang <wency@cn.fujitsu.com>
Date: Mon, 30 Jul 2012 01:57:33 +0000
Subject: Re: [RFC PATCH v5 05/19] memory-hotplug: check whether memory is present or not
Message-Id: <5015EA0D.9050501@cn.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <50126B83.3050201@cn.fujitsu.com>	<50126D44.7070608@cn.fujitsu.com> <CA+8MBbL+G=xqkWU4xGF3_Ra7KoeoHuzL6QYcRiKqtVZoOBfLdQ@mail.gmail.com>
In-Reply-To: <CA+8MBbL+G=xqkWU4xGF3_Ra7KoeoHuzL6QYcRiKqtVZoOBfLdQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, Yasuaki ISIMATU <isimatu.yasuaki@jp.fujitsu.com>

At 07/28/2012 04:17 AM, Tony Luck Wrote:
> On Fri, Jul 27, 2012 at 3:28 AM, Wen Congyang <wency@cn.fujitsu.com> wrote:
>> +static inline int pfns_present(unsigned long pfn, unsigned long nr_pages)
>> +{
>> +       int i;
>> +       for (i = 0; i < nr_pages; i++) {
>> +               if (pfn_present(pfn + 1))
> 
> Typo? I think you meant "pfn + i"

Typo error.

Thanks for pointing it out.
Wen Congyang

> 
>> +                       continue;
>> +               else
>> +                       return -EINVAL;
>> +       }
>> +       return 0;
>> +}
> 
> -Tony
> 

