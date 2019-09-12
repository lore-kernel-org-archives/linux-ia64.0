From: Christophe Leroy <christophe.leroy@c-s.fr>
Date: Thu, 12 Sep 2019 14:42:25 +0000
Subject: Re: [PATCH V2 0/2] mm/debug: Add tests for architecture exported page table helpers
Message-Id: <527edfce-c986-de4c-e286-34a70f6a2790@c-s.fr>
List-Id: <linux-ia64.vger.kernel.org>
References: <1568268173-31302-1-git-send-email-anshuman.khandual@arm.com>
In-Reply-To: <1568268173-31302-1-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Anshuman Khandual <anshuman.khandual@arm.com>, linux-mm@kvack.org
Cc: Mark Rutland <mark.rutland@arm.com>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, James Hogan <jhogan@kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, Michal Hocko <mhocko@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Paul Mackerras <paulus@samba.org>, sparclinux@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-s390@vger.kernel.org, Jason Gunthorpe <jgg@ziepe.ca>, Michael Ellerman <mpe@ellerman.id.au>, x86@kernel.org, Russell King - ARM Linux <linux@armlinux.org.uk>, Matthew Wilcox <willy@infradead.org>, Steven Price <Steven.Price@arm.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, linux-snps-arc@lists.infradead.org, Kees Cook <keescook@chromium.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Mark Brown <broonie@kernel.org>, "Kirill A . Shutemov" <kirill@shutemov.name>, Dan Williams <dan.j.williams@intel.com>, Vlastimil Babka <vbabka@suse.cz>, linux-arm-kernel@lists.infradead.org, Sri Krishna chowdary <schowdary@nvidia.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mips@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, linux-kernel@vger.kernel.org, Paul Burton <paul.burton@mips.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Vineet Gupta <vgupta@synopsys.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>, Mike Kravetz <mike.kravetz@oracle.com>

Hi,

I didn't get patch 1 of this series, and it is not on linuxppc-dev 
patchwork either. Can you resend ?

Thanks
Christophe

Le 12/09/2019 à 08:02, Anshuman Khandual a écrit :
> This series adds a test validation for architecture exported page table
> helpers. Patch in the series adds basic transformation tests at various
> levels of the page table. Before that it exports gigantic page allocation
> function from HugeTLB.
> 
> This test was originally suggested by Catalin during arm64 THP migration
> RFC discussion earlier. Going forward it can include more specific tests
> with respect to various generic MM functions like THP, HugeTLB etc and
> platform specific tests.
> 
> https://lore.kernel.org/linux-mm/20190628102003.GA56463@arrakis.emea.arm.com/
> 
> Testing:
> 
> Successfully build and boot tested on both arm64 and x86 platforms without
> any test failing. Only build tested on some other platforms.
> 
> But I would really appreciate if folks can help validate this test on other
> platforms and report back problems. All suggestions, comments and inputs
> welcome. Thank you.
> 
> Changes in V2:
> 
> - Fixed small typo error in MODULE_DESCRIPTION()
> - Fixed m64k build problems for lvalue concerns in pmd_xxx_tests()
> - Fixed dynamic page table level folding problems on x86 as per Kirril
> - Fixed second pointers during pxx_populate_tests() per Kirill and Gerald
> - Allocate and free pte table with pte_alloc_one/pte_free per Kirill
> - Modified pxx_clear_tests() to accommodate s390 lower 12 bits situation
> - Changed RANDOM_NZVALUE value from 0xbe to 0xff
> - Changed allocation, usage, free sequence for saved_ptep
> - Renamed VMA_FLAGS as VMFLAGS
> - Implemented a new method for random vaddr generation
> - Implemented some other cleanups
> - Dropped extern reference to mm_alloc()
> - Created and exported new alloc_gigantic_page_order()
> - Dropped the custom allocator and used new alloc_gigantic_page_order()
> 
> Changes in V1:
> 
> https://lore.kernel.org/linux-mm/1567497706-8649-1-git-send-email-anshuman.khandual@arm.com/
> 
> - Added fallback mechanism for PMD aligned memory allocation failure
> 
> Changes in RFC V2:
> 
> https://lore.kernel.org/linux-mm/1565335998-22553-1-git-send-email-anshuman.khandual@arm.com/T/#u
> 
> - Moved test module and it's config from lib/ to mm/
> - Renamed config TEST_ARCH_PGTABLE as DEBUG_ARCH_PGTABLE_TEST
> - Renamed file from test_arch_pgtable.c to arch_pgtable_test.c
> - Added relevant MODULE_DESCRIPTION() and MODULE_AUTHOR() details
> - Dropped loadable module config option
> - Basic tests now use memory blocks with required size and alignment
> - PUD aligned memory block gets allocated with alloc_contig_range()
> - If PUD aligned memory could not be allocated it falls back on PMD aligned
>    memory block from page allocator and pud_* tests are skipped
> - Clear and populate tests now operate on real in memory page table entries
> - Dummy mm_struct gets allocated with mm_alloc()
> - Dummy page table entries get allocated with [pud|pmd|pte]_alloc_[map]()
> - Simplified [p4d|pgd]_basic_tests(), now has random values in the entries
> 
> Original RFC V1:
> 
> https://lore.kernel.org/linux-mm/1564037723-26676-1-git-send-email-anshuman.khandual@arm.com/
> 
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
> Cc: Jason Gunthorpe <jgg@ziepe.ca>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Mark Rutland <mark.rutland@arm.com>
> Cc: Mark Brown <broonie@kernel.org>
> Cc: Steven Price <Steven.Price@arm.com>
> Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>
> Cc: Masahiro Yamada <yamada.masahiro@socionext.com>
> Cc: Kees Cook <keescook@chromium.org>
> Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
> Cc: Matthew Wilcox <willy@infradead.org>
> Cc: Sri Krishna chowdary <schowdary@nvidia.com>
> Cc: Dave Hansen <dave.hansen@intel.com>
> Cc: Russell King - ARM Linux <linux@armlinux.org.uk>
> Cc: Michael Ellerman <mpe@ellerman.id.au>
> Cc: Paul Mackerras <paulus@samba.org>
> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Vineet Gupta <vgupta@synopsys.com>
> Cc: James Hogan <jhogan@kernel.org>
> Cc: Paul Burton <paul.burton@mips.com>
> Cc: Ralf Baechle <ralf@linux-mips.org>
> Cc: Kirill A. Shutemov <kirill@shutemov.name>
> Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>
> Cc: Christophe Leroy <christophe.leroy@c-s.fr>
> Cc: Mike Kravetz <mike.kravetz@oracle.com>
> Cc: linux-snps-arc@lists.infradead.org
> Cc: linux-mips@vger.kernel.org
> Cc: linux-arm-kernel@lists.infradead.org
> Cc: linux-ia64@vger.kernel.org
> Cc: linuxppc-dev@lists.ozlabs.org
> Cc: linux-s390@vger.kernel.org
> Cc: linux-sh@vger.kernel.org
> Cc: sparclinux@vger.kernel.org
> Cc: x86@kernel.org
> Cc: linux-kernel@vger.kernel.org
> 
> Anshuman Khandual (2):
>    mm/hugetlb: Make alloc_gigantic_page() available for general use
>    mm/pgtable/debug: Add test validating architecture page table helpers
> 
>   arch/x86/include/asm/pgtable_64_types.h |   2 +
>   include/linux/hugetlb.h                 |   9 +
>   mm/Kconfig.debug                        |  14 +
>   mm/Makefile                             |   1 +
>   mm/arch_pgtable_test.c                  | 429 ++++++++++++++++++++++++
>   mm/hugetlb.c                            |  24 +-
>   6 files changed, 477 insertions(+), 2 deletions(-)
>   create mode 100644 mm/arch_pgtable_test.c
> 
