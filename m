From: Wei Yang <richardw.yang@linux.intel.com>
Date: Wed, 05 Feb 2020 09:26:16 +0000
Subject: Re: [PATCH v6 07/10] mm/memory_hotplug: We always have a zone in find_(smallest|biggest)_section_pfn
Message-Id: <20200205092616.GB24162@richard>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191006085646.5768-1-david@redhat.com>
 <20191006085646.5768-8-david@redhat.com>
 <20200205085709.GA24162@richard>
 <80d3baea-2076-ed07-1216-27d8aa8c8734@redhat.com>
In-Reply-To: <80d3baea-2076-ed07-1216-27d8aa8c8734@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Hildenbrand <david@redhat.com>
Cc: linux-s390@vger.kernel.org, Michal Hocko <mhocko@suse.com>, linux-ia64@vger.kernel.org, Pavel Tatashin <pasha.tatashin@soleen.com>, linux-sh@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Wei Yang <richardw.yang@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, Dan Williams <dan.j.williams@intel.com>, linux-arm-kernel@lists.infradead.org, Oscar Salvador <osalvador@suse.de>

On Wed, Feb 05, 2020 at 09:59:41AM +0100, David Hildenbrand wrote:
>On 05.02.20 09:57, Wei Yang wrote:
>> On Sun, Oct 06, 2019 at 10:56:43AM +0200, David Hildenbrand wrote:
>>> With shrink_pgdat_span() out of the way, we now always have a valid
>>> zone.
>>>
>>> Cc: Andrew Morton <akpm@linux-foundation.org>
>>> Cc: Oscar Salvador <osalvador@suse.de>
>>> Cc: David Hildenbrand <david@redhat.com>
>>> Cc: Michal Hocko <mhocko@suse.com>
>>> Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
>>> Cc: Dan Williams <dan.j.williams@intel.com>
>>> Cc: Wei Yang <richardw.yang@linux.intel.com>
>>> Signed-off-by: David Hildenbrand <david@redhat.com>
>> 
>> Reviewed-by: Wei Yang <richardw.yang@linux.intel.com>
>
>Just FYI, the patches are now upstream, so the rb's can no longer be
>applied. (but we can send fixes if we find that something is broken ;)
>). Thanks!
>

Thanks for reminding. :-)

>-- 
>Thanks,
>
>David / dhildenb

-- 
Wei Yang
Help you, Help me
