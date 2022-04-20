From: Andrew Morton <akpm@linux-foundation.org>
Date: Wed, 20 Apr 2022 22:27:49 +0000
Subject: Re: [PATCH v2 7/9] mm: Calc the right pfn if page size is not 4K
Message-Id: <20220420152749.d41097e7d53ccd6a2a2aea5f@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220414101314.1250667-1-mawupeng1@huawei.com>
        <20220414101314.1250667-8-mawupeng1@huawei.com>
        <672ff459-81bd-38ef-882d-e718992d295c@arm.com>
        <CAMj1kXFnEhJ4Qu50Ads9psY6kmT3ddw5Za+6-YqUM+eYj1Oafw@mail.gmail.com>
In-Reply-To: <CAMj1kXFnEhJ4Qu50Ads9psY6kmT3ddw5Za+6-YqUM+eYj1Oafw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ard Biesheuvel <ardb@kernel.org>
Cc: Anshuman Khandual <anshuman.khandual@arm.com>, Wupeng Ma <mawupeng1@huawei.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, X86 ML <x86@kernel.org>, hpa@zyccr.com, Darren Hart <dvhart@infradead.org>, Andy Shevchenko <andy@infradead.org>, Mike Rapoport <rppt@kernel.org>, "Paul E. McKenney" <paulmck@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Joerg Roedel <jroedel@suse.de>, songmuchun@bytedance.com, macro@orcam.me.uk, Frederic Weisbecker <frederic@kernel.org>, W_Armin@gmx.de, John Garry <john.garry@huawei.com>, Sean Christopherson <seanjc@google.com>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, chenhuacai@kernel.org, David Hildenbrand <david@redhat.com>, gpiccoli@igalia.com, Mark Rutland <mark.rutland@arm.com>, Kefeng Wang <wangkefeng.wang@huawei.com>, Linux Doc Mailing List <linux-doc@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-efi <linux-efi@vger.kernel.org>, linux-ia64@vger.kernel.org, platform-driver-x86@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>

On Tue, 19 Apr 2022 20:29:27 +0200 Ard Biesheuvel <ardb@kernel.org> wrote:

> > > --- a/mm/page_alloc.c
> > > +++ b/mm/page_alloc.c
> > > @@ -7870,7 +7870,7 @@ static void __init find_zone_movable_pfns_for_nodes(void)
> > >
> > >                       usable_startpfn = memblock_region_memory_base_pfn(r);
> > >
> > > -                     if (usable_startpfn < 0x100000) {
> > > +                     if (usable_startpfn < PHYS_PFN(SZ_4G)) {
> > >                               mem_below_4gb_not_mirrored = true;
> > >                               continue;
> > >                       }
> >
> > Regardless PFN value should never be encoded directly.
> >
> > Reviewed-by: Anshuman Khandual <anshuman.khandual@arm.com>
> 
> Acked-by: Ard Biesheuvel <ardb@kernel.org>
> 
> Andrew, can you please take this one through the -mm tree? The rest of
> the series needs a bit more work, but is an obvious fix and there is
> no point in holding it up.

Sure.

I'm not seeing any description of the runtime effects of this
shortcoming.  I tentatively queued the fix for 5.18, without a
cc:stable for backporting.  But that might not be the best decision?
