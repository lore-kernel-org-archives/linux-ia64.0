From: Qian Cai <cai@lca.pw>
Date: Tue, 15 Oct 2019 14:41:42 +0000
Subject: Re: [PATCH V6 0/2] mm/debug: Add tests validating architecture page table helpers
Message-Id: <1571150502.5937.39.camel@lca.pw>
List-Id: <linux-ia64.vger.kernel.org>
References: <1571131302-32290-1-git-send-email-anshuman.khandual@arm.com>
In-Reply-To: <1571131302-32290-1-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Anshuman Khandual <anshuman.khandual@arm.com>, linux-mm@kvack.org
Cc: Mark Rutland <mark.rutland@arm.com>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, James Hogan <jhogan@kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, Michal Hocko <mhocko@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Paul Mackerras <paulus@samba.org>, sparclinux@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-s390@vger.kernel.org, Jason Gunthorpe <jgg@ziepe.ca>, Michael Ellerman <mpe@ellerman.id.au>, x86@kernel.org, Russell King - ARM Linux <linux@armlinux.org.uk>, Matthew Wilcox <willy@infradead.org>, Steven Price <Steven.Price@arm.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, Kees Cook <keescook@chromium.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Mark Brown <broonie@kernel.org>, "Kirill A . Shutemov" <kirill@shutemov.name>, Dan Williams <dan.j.williams@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christophe Leroy <christophe.leroy@c-s.fr>, Sri Krishna chowdary <schowdary@nvidia.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mips@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, linux-kernel@vger.kernel.org, Paul Burton <paul.burton@mips.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Vineet Gupta <vgupta@synopsys.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>, Mike Kravetz <mike.kravetz@oracle.com>

The x86 will crash with linux-next during boot due to this series (v5) with the
config below plus CONFIG_DEBUG_VM_PGTABLE=y. I am not sure if v6 would address
it.

https://raw.githubusercontent.com/cailca/linux-mm/master/x86.config

[   33.862600][    T1] page:ffffea0009000000 is uninitialized and poisoned
[   33.862608][    T1] raw: ffffffffffffffff ffffffffffffffff ffffffffffffffff
ffffff871140][    T1]  ? _raw_spin_unlock_irq+0x27/0x40
[   33.871140][    T1]  ? rest_init+0x307/0x307
[   33.871140][    T1]  kernel_init+0x11/0x139
[   33.871140][    T1]  ? rest_init+0x307/0x307
[   33.871140][    T1]  ret_from_fork+0x27/0x50
[   33.871140][    T1] Modules linked in:
[   33.871140][    T1] ---[ end trace e99d392b0f7befbd ]---
[   33.871140][    T1] RIP: 0010:alloc_gigantic_page_order+0x3fe/0x490

On Tue, 2019-10-15 at 14:51 +0530, Anshuman Khandual wrote:
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
> Changes in V6:
> 
> - Moved alloc_gigantic_page_order() into mm/page_alloc.c per Michal
> - Moved alloc_gigantic_page_order() within CONFIG_CONTIG_ALLOC in the test
> - Folded Andrew's include/asm-generic/pgtable.h fix into the test patch 2/2
> 
> Changes in V5: (https://patchwork.kernel.org/project/linux-mm/list/?series5991)
> 
> - Redefined and moved X86 mm_p4d_folded() into a different header per Kirill/Ingo
> - Updated the config option comment per Ingo and dropped 'kernel module' reference
> - Updated the commit message and dropped 'kernel module' reference
> - Changed DEBUG_ARCH_PGTABLE_TEST into DEBUG_VM_PGTABLE per Ingo
> - Moved config option from mm/Kconfig.debug into lib/Kconfig.debug
> - Renamed core test function arch_pgtable_tests() as debug_vm_pgtable()
> - Renamed mm/arch_pgtable_test.c as mm/debug_vm_pgtable.c
> - debug_vm_pgtable() gets called from kernel_init_freeable() after init_mm_internals()
> - Added an entry in Documentation/features/debug/ per Ingo
> - Enabled the test on arm64 and x86 platforms for now
> 
> Changes in V4: (https://patchwork.kernel.org/project/linux-mm/list/?series3465)
> 
> - Disable DEBUG_ARCH_PGTABLE_TEST for ARM and IA64 platforms
> 
> Changes in V3: (https://lore.kernel.org/patchwork/project/lkml/list/?seriesA1216)
> 
> - Changed test trigger from module format into late_initcall()
> - Marked all functions with __init to be freed after completion
> - Changed all __PGTABLE_PXX_FOLDED checks as mm_pxx_folded()
> - Folded in PPC32 fixes from Christophe
> 
> Changes in V2:
> 
> https://lore.kernel.org/linux-mm/1568268173-31302-1-git-send-email-anshuman.khandual@arm.com/T/#t
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
>   memory block from page allocator and pud_* tests are skipped
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
> 
> Anshuman Khandual (2):
>   mm/page_alloc: Make alloc_gigantic_page() available for general use
>   mm/debug: Add tests validating architecture page table helpers
> 
>  .../debug/debug-vm-pgtable/arch-support.txt   |  34 ++
>  arch/arm64/Kconfig                            |   1 +
>  arch/x86/Kconfig                              |   1 +
>  arch/x86/include/asm/pgtable_64.h             |   6 +
>  include/asm-generic/pgtable.h                 |   6 +
>  include/linux/gfp.h                           |   3 +
>  init/main.c                                   |   1 +
>  lib/Kconfig.debug                             |  21 +
>  mm/Makefile                                   |   1 +
>  mm/debug_vm_pgtable.c                         | 450 ++++++++++++++++++
>  mm/hugetlb.c                                  |  76 +--
>  mm/page_alloc.c                               |  98 ++++
>  12 files changed, 623 insertions(+), 75 deletions(-)
>  create mode 100644 Documentation/features/debug/debug-vm-pgtable/arch-support.txt
>  create mode 100644 mm/debug_vm_pgtable.c
> 
