From: Matthew Wilcox <willy@infradead.org>
Date: Mon, 26 Aug 2019 13:13:08 +0000
Subject: Re: [RFC V2 0/1] mm/debug: Add tests for architecture exported page table helpers
Message-Id: <20190826131308.GA15933@bombadil.infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1565335998-22553-1-git-send-email-anshuman.khandual@arm.com>
 <20190809101632.GM5482@bombadil.infradead.org>
 <a5aab7ff-f7fd-9cc1-6e37-e4185eee65ac@arm.com>
 <20190809135202.GN5482@bombadil.infradead.org>
 <7a88f6bb-e8c7-3ac7-2f92-1de752a01f33@arm.com>
In-Reply-To: <7a88f6bb-e8c7-3ac7-2f92-1de752a01f33@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: Mark Rutland <mark.rutland@arm.com>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, James Hogan <jhogan@kernel.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Heiko Carstens <heiko.carstens@de.ibm.com>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Dave Hansen <dave.hansen@intel.com>, Paul Mackerras <paulus@samba.org>, sparclinux@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-s390@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, x86@kernel.org, Russell King - ARM Linux <linux@armlinux.org.uk>, Steven Price <Steven.Price@arm.com>, Jason Gunthorpe <jgg@ziepe.ca>, linux-arm-kernel@lists.infradead.org, linux-snps-arc@lists.infradead.org, Kees Cook <keescook@chromium.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Mark Brown <broonie@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Sri Krishna chowdary <schowdary@nvidia.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mips@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, linux-kernel@vger.kernel.org, Paul Burton <paul.burton@mips.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Vineet Gupta <vgupta@synopsys.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>

On Mon, Aug 26, 2019 at 08:07:13AM +0530, Anshuman Khandual wrote:
> On 08/09/2019 07:22 PM, Matthew Wilcox wrote:
> > On Fri, Aug 09, 2019 at 04:05:07PM +0530, Anshuman Khandual wrote:
> >> On 08/09/2019 03:46 PM, Matthew Wilcox wrote:
> >>> On Fri, Aug 09, 2019 at 01:03:17PM +0530, Anshuman Khandual wrote:
> >>>> Should alloc_gigantic_page() be made available as an interface for general
> >>>> use in the kernel. The test module here uses very similar implementation from
> >>>> HugeTLB to allocate a PUD aligned memory block. Similar for mm_alloc() which
> >>>> needs to be exported through a header.
> >>>
> >>> Why are you allocating memory at all instead of just using some
> >>> known-to-exist PFNs like I suggested?
> >>
> >> We needed PFN to be PUD aligned for pfn_pud() and PMD aligned for mk_pmd().
> >> Now walking the kernel page table for a known symbol like kernel_init()
> > 
> > I didn't say to walk the kernel page table.  I said to call virt_to_pfn()
> > for a known symbol like kernel_init().
> > 
> >> as you had suggested earlier we might encounter page table page entries at PMD
> >> and PUD which might not be PMD or PUD aligned respectively. It seemed to me
> >> that alignment requirement is applicable only for mk_pmd() and pfn_pud()
> >> which create large mappings at those levels but that requirement does not
> >> exist for page table pages pointing to next level. Is not that correct ? Or
> >> I am missing something here ?
> > 
> > Just clear the bottom bits off the PFN until you get a PMD or PUD aligned
> > PFN.  It's really not hard.
> 
> As Mark pointed out earlier that might end up being just a synthetic PFN
> which might not even exist on a given system.

And why would that matter?
