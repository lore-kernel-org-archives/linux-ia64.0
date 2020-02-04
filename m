From: David Hildenbrand <david@redhat.com>
Date: Tue, 04 Feb 2020 09:20:16 +0000
Subject: Re: [PATCH v6 08/10] mm/memory_hotplug: Don't check for "all holes" in shrink_zone_span()
Message-Id: <7d36f4cd-3f5b-8fec-2d8b-83e62a34ec89@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191006085646.5768-1-david@redhat.com>
 <20191006085646.5768-9-david@redhat.com> <20200204091312.GC6494@linux>
In-Reply-To: <20200204091312.GC6494@linux>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oscar Salvador <osalvador@suse.de>
Cc: linux-s390@vger.kernel.org, Michal Hocko <mhocko@suse.com>, linux-ia64@vger.kernel.org, Pavel Tatashin <pasha.tatashin@soleen.com>, linux-sh@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Wei Yang <richardw.yang@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, Dan Williams <dan.j.williams@intel.com>, linux-arm-kernel@lists.infradead.org

On 04.02.20 10:13, Oscar Salvador wrote:
> On Sun, Oct 06, 2019 at 10:56:44AM +0200, David Hildenbrand wrote:
>> If we have holes, the holes will automatically get detected and removed
>> once we remove the next bigger/smaller section. The extra checks can
>> go.
>>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: Oscar Salvador <osalvador@suse.de>
>> Cc: Michal Hocko <mhocko@suse.com>
>> Cc: David Hildenbrand <david@redhat.com>
>> Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
>> Cc: Dan Williams <dan.j.williams@intel.com>
>> Cc: Wei Yang <richardw.yang@linux.intel.com>
>> Signed-off-by: David Hildenbrand <david@redhat.com>
> 
> Heh, I have been here before.
> I have to confess that when I wrote my version of this I was not really 100%
> about removing it, because hotplug was a sort of a "catchall" for all sort of weird
> and corner-cases configurations, but thinking more about it, I cannot think of
> any situation that would make this blow up.
> 
> Reviewed-by: Oscar Salvador <osalvador@suse.de>

Thanks for your review Oscar!

-- 
Thanks,

David / dhildenb
