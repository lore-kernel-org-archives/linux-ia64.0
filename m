From: David Hildenbrand <david@redhat.com>
Date: Wed, 05 Feb 2020 14:55:52 +0000
Subject: Re: [PATCH v6 08/10] mm/memory_hotplug: Don't check for "all holes" in shrink_zone_span()
Message-Id: <00d040ca-1885-1b38-e3da-54276c37bc8e@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191006085646.5768-1-david@redhat.com>
 <20191006085646.5768-9-david@redhat.com> <20200205095924.GC24162@richard>
 <b8f142b9d569459d84b71949cb5efc27@AcuMS.aculab.com>
In-Reply-To: <b8f142b9d569459d84b71949cb5efc27@AcuMS.aculab.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Laight <David.Laight@ACULAB.COM>, 'Wei Yang' <richardw.yang@linux.intel.com>
Cc: "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Pavel Tatashin <pasha.tatashin@soleen.com>, "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, Dan Williams <dan.j.williams@intel.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Oscar Salvador <osalvador@suse.de>

On 05.02.20 15:54, David Laight wrote:
> From: Wei Yang
>> Sent: 05 February 2020 09:59
> ...
>> If it is me, I would like to take out these two similar logic out.
>>
>> For example:
>>
>> 	if () {
>> 	} else if () {
>> 	} else {
>> 		goto out;
>> 	}
> 
> I'm pretty sure the kernel layout rules disallow 'else if'.

Huh?

git grep "else if" | wc -l
49336

I'm afraid I don't get what you mean :)

-- 
Thanks,

David / dhildenb
