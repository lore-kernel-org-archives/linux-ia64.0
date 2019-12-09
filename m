From: Logan Gunthorpe <logang@deltatee.com>
Date: Mon, 09 Dec 2019 21:27:12 +0000
Subject: Re: [PATCH 5/6] mm, memory_hotplug: Provide argument for the pgprot_t in arch_add_memory()
Message-Id: <05e82397-4d89-a54d-5334-2ddca6c94f19@deltatee.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191209191346.5197-1-logang@deltatee.com>
 <20191209191346.5197-6-logang@deltatee.com>
 <ce50d9da-c60e-05a1-a86b-3bb3629de502@redhat.com>
 <f34a4c52-cc95-15ed-8a72-c05ab4fd6d33@deltatee.com>
 <20191209204128.GC7658@dhcp22.suse.cz>
 <CAPcyv4iKKw8cuFyDrY2VLN2ecd-qAbDCfYa7SufuhUb59e89Rw@mail.gmail.com>
In-Reply-To: <CAPcyv4iKKw8cuFyDrY2VLN2ecd-qAbDCfYa7SufuhUb59e89Rw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@kernel.org>
Cc: linux-s390 <linux-s390@vger.kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, linux-ia64@vger.kernel.org, Will Deacon <will@kernel.org>, David Hildenbrand <david@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, Linux-sh <linux-sh@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, platform-driver-x86@vger.kernel.org, Linux MM <linux-mm@kvack.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Andy Lutomirski <luto@kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Borislav Petkov <bp@alien8.de>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, Christoph Hellwig <hch@lst.de>, Linux ARM <linux-arm-kernel@lists.infradead.org>



On 2019-12-09 2:00 p.m., Dan Williams wrote:
>>>> Can we fiddle that into "struct mhp_restrictions" instead?
>>>
>>> Yes, if that's what people want, it's pretty trivial to do. I chose not
>>> to do it that way because it doesn't get passed down to add_pages() and
>>> it's not really a "restriction". If I don't hear any objections, I will
>>> do that for v2.
>>
>> I do agree that restriction is not the best fit. But I consider prot
>> argument to complicate the API to all users even though it is not really
>> clear whether we are going to have many users really benefiting from it.
>> Look at the vmalloc API and try to find how many users of __vmalloc do
>> not use PAGE_KERNEL.
> 
> At least for this I can foresee at least one more user in the
> pipeline, encrypted memory support for persistent memory mappings that
> will store the key-id in the ptes.
> 
>>
>> So I can see two options. One of them is to add arch_add_memory_prot
>> that would allow to have give and extra prot argument or simply call
>> an arch independent API to change the protection after arch_add_memory.
>> The later sounds like much less code. The memory shouldn't be in use by
>> anybody at that stage yet AFAIU. Maybe there even is an API like that.
> 
> I'm ok with passing it the same way as altmap or a new
> arch_add_memory_prot() my only hangup with after the fact changes is
> the wasted effort it inflicts in the init path for potentially large
> address ranges.

Yes, I'll change the way it's passed in for v2 as that seems to be
generally agreed upon. I can also add a patch to make the name change.

And, yes, given our testing, the wasted effort is quite significant so
I'm against changing the prots after the fact.

Logan
