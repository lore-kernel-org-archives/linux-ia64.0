From: David Hildenbrand <david@redhat.com>
Date: Thu, 09 May 2019 07:05:23 +0000
Subject: Re: [PATCH v2 5/8] mm/memory_hotplug: Drop MHP_MEMBLOCK_API
Message-Id: <f7fac4cc-468e-0787-a364-760e68f6b1c2@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190507183804.5512-1-david@redhat.com>
 <20190507183804.5512-6-david@redhat.com>
 <CAPcyv4ge1pSOopfHof4USn=7Skc-UV4Xhd_s=h+M9VXSp_p1XQ@mail.gmail.com>
 <d83fec16-ceff-2f6f-72e1-48996187d5ba@redhat.com>
 <CAPcyv4iRQteuT9yESvbUyhp3KVVgTXDiGAo+TwPCM_4f0CzBgg@mail.gmail.com>
 <edd762a1-c012-fe05-a72e-2505cd98188a@redhat.com>
 <1557356938.3028.35.camel@suse.com>
In-Reply-To: <1557356938.3028.35.camel@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: osalvador <osalvador@suse.com>, Dan Williams <dan.j.williams@intel.com>
Cc: Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, linux-s390 <linux-s390@vger.kernel.org>, Linux-sh <linux-sh@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Pavel Tatashin <pasha.tatashin@soleen.com>, Wei Yang <richard.weiyang@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Qian Cai <cai@lca.pw>, Arun KS <arunks@codeaurora.org>, Mathieu Malaterre <malat@debian.org>

On 09.05.19 01:08, osalvador wrote:
> On Wed, 2019-05-08 at 09:39 +0200, David Hildenbrand wrote:
>> However I haven't really thought it through yet, smalles like that
>> could
>> as well just be handled by the caller of
>> arch_add_memory()/arch_remove_memory() eventually, passing it via
>> something like the altmap parameter.
>>
>> Let's leave it in place for now, we can talk about that once we have
>> new
>> patches from Oscar.
> Hi David,
> 
> I plan to send a new patchset once this is and Dan's are merged,
> otherwise I will have a mayhem with the conflicts.
> 
> I also plan/want to review this patchset, but time is tight this week.
> 

Sure, take your time. I'll resend this patch set most probably tomorrow
or early next week. Cheers!

-- 

Thanks,

David / dhildenb
