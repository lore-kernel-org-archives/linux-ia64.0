From: David Hildenbrand <david@redhat.com>
Date: Tue, 04 Feb 2020 12:41:06 +0000
Subject: Re: [PATCH v6 10/10] mm/memory_hotplug: Cleanup __remove_pages()
Message-Id: <5d698f94-af18-0714-bc97-14b6c520572c@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191006085646.5768-1-david@redhat.com>
 <20191006085646.5768-11-david@redhat.com> <20200204094652.GE6494@linux>
In-Reply-To: <20200204094652.GE6494@linux>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oscar Salvador <osalvador@suse.de>
Cc: linux-s390@vger.kernel.org, Michal Hocko <mhocko@suse.com>, linux-ia64@vger.kernel.org, Pavel Tatashin <pasha.tatashin@soleen.com>, linux-sh@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Wei Yang <richardw.yang@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, Dan Williams <dan.j.williams@intel.com>, linux-arm-kernel@lists.infradead.org

On 04.02.20 10:46, Oscar Salvador wrote:
> On Sun, Oct 06, 2019 at 10:56:46AM +0200, David Hildenbrand wrote:
>> Let's drop the basically unused section stuff and simplify.
>>
>> Also, let's use a shorter variant to calculate the number of pages to
>> the next section boundary.
>>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: Oscar Salvador <osalvador@suse.de>
>> Cc: Michal Hocko <mhocko@suse.com>
>> Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
>> Cc: Dan Williams <dan.j.williams@intel.com>
>> Cc: Wei Yang <richardw.yang@linux.intel.com>
>> Signed-off-by: David Hildenbrand <david@redhat.com>
> 
> I have to confess that it took me while to wrap around my head
> with the new min() change, but looks ok:

It's a pattern commonly used in compilers and emulators to calculate the
number of bytes to the next block/alignment. (we're missing a macro
(like we have ALIGN_UP/IS_ALIGNED) for that - but it's hard to come up
with a good name (e.g., SIZE_TO_NEXT_ALIGN) .

-- 
Thanks,

David / dhildenb
