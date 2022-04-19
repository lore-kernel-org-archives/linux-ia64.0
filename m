From: Ard Biesheuvel <ardb@kernel.org>
Date: Tue, 19 Apr 2022 18:29:27 +0000
Subject: Re: [PATCH v2 7/9] mm: Calc the right pfn if page size is not 4K
Message-Id: <CAMj1kXFnEhJ4Qu50Ads9psY6kmT3ddw5Za+6-YqUM+eYj1Oafw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220414101314.1250667-1-mawupeng1@huawei.com>
 <20220414101314.1250667-8-mawupeng1@huawei.com> <672ff459-81bd-38ef-882d-e718992d295c@arm.com>
In-Reply-To: <672ff459-81bd-38ef-882d-e718992d295c@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Anshuman Khandual <anshuman.khandual@arm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Wupeng Ma <mawupeng1@huawei.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, X86 ML <x86@kernel.org>, hpa@zyccr.com, Darren Hart <dvhart@infradead.org>, Andy Shevchenko <andy@infradead.org>, Mike Rapoport <rppt@kernel.org>, "Paul E. McKenney" <paulmck@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Joerg Roedel <jroedel@suse.de>, songmuchun@bytedance.com, macro@orcam.me.uk, Frederic Weisbecker <frederic@kernel.org>, W_Armin@gmx.de, John Garry <john.garry@huawei.com>, Sean Christopherson <seanjc@google.com>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, chenhuacai@kernel.org, David Hildenbrand <david@redhat.com>, gpiccoli@igalia.com, Mark Rutland <mark.rutland@arm.com>, Kefeng Wang <wangkefeng.wang@huawei.com>, Linux Doc Mailing List <linux-doc@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-efi <linux-efi@vger.kernel.org>, linux-ia64@vger.kernel.org, platform-driver-x86@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>

On Tue, 19 Apr 2022 at 13:13, Anshuman Khandual
<anshuman.khandual@arm.com> wrote:
>
>
>
> On 4/14/22 15:43, Wupeng Ma wrote:
> > From: Ma Wupeng <mawupeng1@huawei.com>
> >
> > Previous 0x100000 is used to check the 4G limit in
> > find_zone_movable_pfns_for_nodes(). This is right in x86 because
> > the page size can only be 4K. But 16K and 64K are available in
> > arm64. So replace it with PHYS_PFN(SZ_4G).
> >
> > Signed-off-by: Ma Wupeng <mawupeng1@huawei.com>
> > ---
> >  mm/page_alloc.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> >
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 6e5b4488a0c5..570d0ebf98df 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -7870,7 +7870,7 @@ static void __init find_zone_movable_pfns_for_nodes(void)
> >
> >                       usable_startpfn = memblock_region_memory_base_pfn(r);
> >
> > -                     if (usable_startpfn < 0x100000) {
> > +                     if (usable_startpfn < PHYS_PFN(SZ_4G)) {
> >                               mem_below_4gb_not_mirrored = true;
> >                               continue;
> >                       }
>
> Regardless PFN value should never be encoded directly.
>
> Reviewed-by: Anshuman Khandual <anshuman.khandual@arm.com>

Acked-by: Ard Biesheuvel <ardb@kernel.org>

Andrew, can you please take this one through the -mm tree? The rest of
the series needs a bit more work, but is an obvious fix and there is
no point in holding it up.

Thanks,
Ard.
