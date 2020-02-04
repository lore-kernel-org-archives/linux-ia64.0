From: David Hildenbrand <david@redhat.com>
Date: Tue, 04 Feb 2020 13:38:51 +0000
Subject: Re: [PATCH v6 10/10] mm/memory_hotplug: Cleanup __remove_pages()
Message-Id: <0e2f700c-b01b-8c16-99c2-2648967fc203@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191006085646.5768-1-david@redhat.com>
 <20191006085646.5768-11-david@redhat.com> <20200204094652.GE6494@linux>
 <5d698f94-af18-0714-bc97-14b6c520572c@redhat.com>
 <20200204131353.GJ22482@gate.crashing.org>
In-Reply-To: <20200204131353.GJ22482@gate.crashing.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Segher Boessenkool <segher@kernel.crashing.org>
Cc: linux-s390@vger.kernel.org, Michal Hocko <mhocko@suse.com>, linux-ia64@vger.kernel.org, Pavel Tatashin <pasha.tatashin@soleen.com>, linux-sh@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Wei Yang <richardw.yang@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, Dan Williams <dan.j.williams@intel.com>, linux-arm-kernel@lists.infradead.org, Oscar Salvador <osalvador@suse.de>

On 04.02.20 14:13, Segher Boessenkool wrote:
> On Tue, Feb 04, 2020 at 01:41:06PM +0100, David Hildenbrand wrote:
>> On 04.02.20 10:46, Oscar Salvador wrote:
>>> I have to confess that it took me while to wrap around my head
>>> with the new min() change, but looks ok:
>>
>> It's a pattern commonly used in compilers and emulators to calculate the
>> number of bytes to the next block/alignment. (we're missing a macro
>> (like we have ALIGN_UP/IS_ALIGNED) for that - but it's hard to come up
>> with a good name (e.g., SIZE_TO_NEXT_ALIGN) .
> 
> You can just write the easy to understand
> 
>   ...  ALIGN_UP(x) - x  ...

you mean

ALIGN_UP(x, PAGES_PER_SECTION) - x

but ...

> 
> which is better *without* having a separate name.  Does that not
> generate good machine code for you?

1. There is no ALIGN_UP. "SECTION_ALIGN_UP(x) - x" would be possible
2. It would be wrong if x is already aligned.

e.g., let's use 4096 for simplicity as we all know that value by heart
(for both x and the block size).

a) -(4096 | -4096) -> 4096

b) #define ALIGN_UP(x, a) ((x + a - 1) & -(a))

ALIGN_UP(4096, 4096) - 4096 -> 0

Not as easy as it seems ...

-- 
Thanks,

David / dhildenb
