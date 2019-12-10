From: Logan Gunthorpe <logang@deltatee.com>
Date: Tue, 10 Dec 2019 23:52:31 +0000
Subject: Re: [PATCH 5/6] mm, memory_hotplug: Provide argument for the pgprot_t in arch_add_memory()
Message-Id: <297b7cc0-c5bc-a4c6-83eb-afc008395234@deltatee.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191209191346.5197-1-logang@deltatee.com>
 <20191209191346.5197-6-logang@deltatee.com>
 <ce50d9da-c60e-05a1-a86b-3bb3629de502@redhat.com>
 <f34a4c52-cc95-15ed-8a72-c05ab4fd6d33@deltatee.com>
 <CAPcyv4hpXCZxV5p7WaeGgE7ceujBBa5NOz9Z8fepDHOt6zHO2A@mail.gmail.com>
 <20191210100432.GC10404@dhcp22.suse.cz>
 <6da2b279-6a6d-d89c-a34c-962ed021d91d@redhat.com>
 <20191210103452.GF10404@dhcp22.suse.cz>
 <a9d6cfe8-39fb-accf-acdc-7cce5578bf2f@redhat.com>
In-Reply-To: <a9d6cfe8-39fb-accf-acdc-7cce5578bf2f@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Hildenbrand <david@redhat.com>, Michal Hocko <mhocko@kernel.org>
Cc: linux-s390 <linux-s390@vger.kernel.org>, linux-ia64@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Will Deacon <will@kernel.org>, Linux-sh <linux-sh@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, Dave Hansen <dave.hansen@linux.intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, platform-driver-x86@vger.kernel.org, Linux MM <linux-mm@kvack.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Andy Lutomirski <luto@kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Borislav Petkov <bp@alien8.de>, Dan Williams <dan.j.williams@intel.com>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, Christoph Hellwig <hch@lst.de>, Linux ARM <linux-arm-kernel@lists.infradead.org>



On 2019-12-10 4:25 a.m., David Hildenbrand wrote:
> On 10.12.19 11:34, Michal Hocko wrote:
>> On Tue 10-12-19 11:09:46, David Hildenbrand wrote:
>>> On 10.12.19 11:04, Michal Hocko wrote:
>>>> On Mon 09-12-19 12:43:40, Dan Williams wrote:
>>>>> On Mon, Dec 9, 2019 at 12:24 PM Logan Gunthorpe <logang@deltatee.com> wrote:
>>>>>>
>>>>>>
>>>>>>
>>>>>> On 2019-12-09 12:23 p.m., David Hildenbrand wrote:
>>>>>>> On 09.12.19 20:13, Logan Gunthorpe wrote:
>>>> [...]
>>>>>>>>  #ifdef CONFIG_MEMORY_HOTPLUG
>>>>>>>> -int arch_add_memory(int nid, u64 start, u64 size,
>>>>>>>> +int arch_add_memory(int nid, u64 start, u64 size, pgprot_t prot,
>>>>>>>>                      struct mhp_restrictions *restrictions)
>>>>>>>
>>>>>>> Can we fiddle that into "struct mhp_restrictions" instead?
>>>>>>
>>>>>> Yes, if that's what people want, it's pretty trivial to do. I chose not
>>>>>> to do it that way because it doesn't get passed down to add_pages() and
>>>>>> it's not really a "restriction". If I don't hear any objections, I will
>>>>>> do that for v2.
>>>>>
>>>>> +1 to storing this information alongside the altmap in that structure.
>>>>> However, I agree struct mhp_restrictions, with the MHP_MEMBLOCK_API
>>>>> flag now gone, has lost all of its "restrictions". How about dropping
>>>>> the 'flags' property and renaming the struct to 'struct
>>>>> mhp_modifiers'?
>>>>
>>>> Hmm, this email somehow didn't end up in my inbox so I have missed it
>>>> before replying.
>>>>
>>>> Well, mhp_modifiers makes some sense and it would reduce the API
>>>> proliferation but how do you expect the prot part to be handled?
>>>> I really do not want people to think about PAGE_KERNEL or which
>>>> protection to use because my experience tells that this will get copied
>>>> without much thinking or simply will break with some odd usecases.
>>>> So how exactly this would be used?
>>>
>>> I was thinking about exactly the same "issue".
>>>
>>> 1. default initialization via a function
>>>
>>> memhp_modifier_default_init(&modified);
>>>
>>> 2. a flag that unlocks the prot field (default:0). Without the flag, it
>>> is ignored. We can keep the current initialization then.
>>>
>>> Other ideas?
>>
>> 3. a prot mask to apply on top of PAGE_KERNEL? Or would that be
>> insufficient/clumsy?
>>
> 
> If it works for the given use case, I guess this would be simple and ok.

I don't see how we can do that without a ton of work. The pgport_t is
architecture specific so we'd need to add mask functions to every
architecture for every page cache type we need to use. I don't think
that's a good idea.

I think I slightly prefer option 2 over the above.  But I'd actually
prefer callers have to think about the caching type seeing when we grew
the second user (memremap_pages()) and it was paired with
track_pfn_remap(), it was actually subtly wrong because it could create
a mapping that track_pfn_remap() disagreed with. In fact, PAGE_KERNEL
has already been specified in memremap_pages() for ages, it was just
ignored when it got to the arch_add_memory() step which is were this
issue comes from.

In my opinion, having a coder and reviewer see PAGE_KERNEL and ask if
that makes sense is a benefit. Having it hidden because we don't want
people to think about it is worse, harder to understand and results in
bugs that are more difficult to spot.

Though, we may be overthinking this: arch_add_memory() is a low level
non-exported API that's currently used in exactly two places. I don't
think there's going to be many, if any, valid new use cases coming up
for it in the future. That's more what memremap_pages() is for.

Logan
