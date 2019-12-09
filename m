From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 09 Dec 2019 21:00:13 +0000
Subject: Re: [PATCH 5/6] mm, memory_hotplug: Provide argument for the pgprot_t in arch_add_memory()
Message-Id: <CAPcyv4iKKw8cuFyDrY2VLN2ecd-qAbDCfYa7SufuhUb59e89Rw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191209191346.5197-1-logang@deltatee.com>
 <20191209191346.5197-6-logang@deltatee.com>
 <ce50d9da-c60e-05a1-a86b-3bb3629de502@redhat.com>
 <f34a4c52-cc95-15ed-8a72-c05ab4fd6d33@deltatee.com>
 <20191209204128.GC7658@dhcp22.suse.cz>
In-Reply-To: <20191209204128.GC7658@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Michal Hocko <mhocko@kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, linux-s390 <linux-s390@vger.kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, linux-ia64@vger.kernel.org, Will Deacon <will@kernel.org>, David Hildenbrand <david@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Logan Gunthorpe <logang@deltatee.com>, Linux-sh <linux-sh@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, platform-driver-x86@vger.kernel.org, Linux MM <linux-mm@kvack.org>, Ingo Molnar <mingo@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Andy Lutomirski <luto@kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Borislav Petkov <bp@alien8.de>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, Christoph Hellwig <hch@lst.de>, Linux ARM <linux-arm-kernel@lists.infradead.org>

On Mon, Dec 9, 2019 at 12:47 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Mon 09-12-19 13:24:19, Logan Gunthorpe wrote:
> >
> >
> > On 2019-12-09 12:23 p.m., David Hildenbrand wrote:
> > > On 09.12.19 20:13, Logan Gunthorpe wrote:
> > >> devm_memremap_pages() is currently used by the PCI P2PDMA code to create
> > >> struct page mappings for IO memory. At present, these mappings are created
> > >> with PAGE_KERNEL which implies setting the PAT bits to be WB. However, on
> > >> x86, an mtrr register will typically override this and force the cache
> > >> type to be UC-. In the case firmware doesn't set this register it is
> > >> effectively WB and will typically result in a machine check exception
> > >> when it's accessed.
> > >>
> > >> Other arches are not currently likely to function correctly seeing they
> > >> don't have any MTRR registers to fall back on.
> > >>
> > >> To solve this, add an argument to arch_add_memory() to explicitly
> > >> set the pgprot value to a specific value.
> > >>
> > >> Of the arches that support MEMORY_HOTPLUG: x86_64, s390 and arm64 is a
> > >> simple change to pass the pgprot_t down to their respective functions
> > >> which set up the page tables. For x86_32, set the page tables explicitly
> > >> using _set_memory_prot() (seeing they are already mapped). For sh, reject
> > >> anything but PAGE_KERNEL settings -- this should be fine, for now, seeing
> > >> sh doesn't support ZONE_DEVICE anyway.
> > >>
> > >> Cc: Dan Williams <dan.j.williams@intel.com>
> > >> Cc: David Hildenbrand <david@redhat.com>
> > >> Cc: Michal Hocko <mhocko@suse.com>
> > >> Signed-off-by: Logan Gunthorpe <logang@deltatee.com>
> > >> ---
> > >>  arch/arm64/mm/mmu.c            | 4 ++--
> > >>  arch/ia64/mm/init.c            | 5 ++++-
> > >>  arch/powerpc/mm/mem.c          | 4 ++--
> > >>  arch/s390/mm/init.c            | 4 ++--
> > >>  arch/sh/mm/init.c              | 5 ++++-
> > >>  arch/x86/mm/init_32.c          | 7 ++++++-
> > >>  arch/x86/mm/init_64.c          | 4 ++--
> > >>  include/linux/memory_hotplug.h | 2 +-
> > >>  mm/memory_hotplug.c            | 2 +-
> > >>  mm/memremap.c                  | 2 +-
> > >>  10 files changed, 25 insertions(+), 14 deletions(-)
> > >>
> > >> diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
> > >> index 60c929f3683b..48b65272df15 100644
> > >> --- a/arch/arm64/mm/mmu.c
> > >> +++ b/arch/arm64/mm/mmu.c
> > >> @@ -1050,7 +1050,7 @@ int p4d_free_pud_page(p4d_t *p4d, unsigned long addr)
> > >>  }
> > >>
> > >>  #ifdef CONFIG_MEMORY_HOTPLUG
> > >> -int arch_add_memory(int nid, u64 start, u64 size,
> > >> +int arch_add_memory(int nid, u64 start, u64 size, pgprot_t prot,
> > >>                    struct mhp_restrictions *restrictions)
> > >
> > > Can we fiddle that into "struct mhp_restrictions" instead?
> >
> > Yes, if that's what people want, it's pretty trivial to do. I chose not
> > to do it that way because it doesn't get passed down to add_pages() and
> > it's not really a "restriction". If I don't hear any objections, I will
> > do that for v2.
>
> I do agree that restriction is not the best fit. But I consider prot
> argument to complicate the API to all users even though it is not really
> clear whether we are going to have many users really benefiting from it.
> Look at the vmalloc API and try to find how many users of __vmalloc do
> not use PAGE_KERNEL.

At least for this I can foresee at least one more user in the
pipeline, encrypted memory support for persistent memory mappings that
will store the key-id in the ptes.

>
> So I can see two options. One of them is to add arch_add_memory_prot
> that would allow to have give and extra prot argument or simply call
> an arch independent API to change the protection after arch_add_memory.
> The later sounds like much less code. The memory shouldn't be in use by
> anybody at that stage yet AFAIU. Maybe there even is an API like that.

I'm ok with passing it the same way as altmap or a new
arch_add_memory_prot() my only hangup with after the fact changes is
the wasted effort it inflicts in the init path for potentially large
address ranges.
