From: Anshuman Khandual <anshuman.khandual@arm.com>
Date: Wed, 04 Sep 2019 06:26:25 +0000
Subject: Re: [PATCH 1/1] mm/pgtable/debug: Add test validating architecture page table helpers
Message-Id: <4dc9698f-dff4-b916-a83e-dc932c8087c0@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1567497706-8649-2-git-send-email-anshuman.khandual@arm.com>
 <201909031912.htvWy2Bu%lkp@intel.com>
In-Reply-To: <201909031912.htvWy2Bu%lkp@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: kbuild test robot <lkp@intel.com>
Cc: Mark Rutland <mark.rutland@arm.com>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, James Hogan <jhogan@kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Paul Mackerras <paulus@samba.org>, sparclinux@vger.kernel.org, Dan Williams <dan.j.williams@intel.com>, linux-s390@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, x86@kernel.org, Russell King - ARM Linux <linux@armlinux.org.uk>, Matthew Wilcox <willy@infradead.org>, Steven Price <Steven.Price@arm.com>, Jason Gunthorpe <jgg@ziepe.ca>, Vlastimil Babka <vbabka@suse.cz>, linux-snps-arc@lists.infradead.org, kbuild-all@01.org, Kees Cook <keescook@chromium.org>, Mark Brown <broonie@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, linux-arm-kernel@lists.infradead.org, Sri Krishna chowdary <schowdary@nvidia.com>, Masahiro Yamada <yamada.masahiro@socionext.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Dave Hansen <dave.hansen@intel.com>, linux-mips@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, linux-kernel@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Paul Burton <paul.burton@mips.com>, Vineet Gupta <vgupta@synopsys.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>



On 09/03/2019 04:43 PM, kbuild test robot wrote:
> Hi Anshuman,
> 
> Thank you for the patch! Yet something to improve:
> 
> [auto build test ERROR on linus/master]
> [cannot apply to v5.3-rc7 next-20190902]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> 
> url:    https://github.com/0day-ci/linux/commits/Anshuman-Khandual/mm-debug-Add-tests-for-architecture-exported-page-table-helpers/20190903-162959
> config: m68k-allmodconfig (attached as .config)
> compiler: m68k-linux-gcc (GCC) 7.4.0
> reproduce:
>         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         # save the attached .config to linux build tree
>         GCC_VERSION=7.4.0 make.cross ARCH=m68k 
> 
> If you fix the issue, kindly add following tag
> Reported-by: kbuild test robot <lkp@intel.com>
> 
> All error/warnings (new ones prefixed by >>):
> 
>    In file included from arch/m68k/include/asm/bug.h:32:0,
>                     from include/linux/bug.h:5,
>                     from include/linux/thread_info.h:12,
>                     from include/asm-generic/preempt.h:5,
>                     from ./arch/m68k/include/generated/asm/preempt.h:1,
>                     from include/linux/preempt.h:78,
>                     from arch/m68k/include/asm/irqflags.h:6,
>                     from include/linux/irqflags.h:16,
>                     from arch/m68k/include/asm/atomic.h:6,
>                     from include/linux/atomic.h:7,
>                     from include/linux/mm_types_task.h:13,
>                     from include/linux/mm_types.h:5,
>                     from include/linux/hugetlb.h:5,
>                     from mm/arch_pgtable_test.c:14:
>    mm/arch_pgtable_test.c: In function 'pmd_clear_tests':
>>> arch/m68k/include/asm/page.h:31:22: error: lvalue required as unary '&' operand
>     #define pmd_val(x) ((&x)->pmd[0])
>                          ^
>    include/asm-generic/bug.h:124:25: note: in definition of macro 'WARN_ON'
>      int __ret_warn_on = !!(condition);    \
>                             ^~~~~~~~~
>>> arch/m68k/include/asm/motorola_pgtable.h:138:26: note: in expansion of macro 'pmd_val'
>     #define pmd_none(pmd)  (!pmd_val(pmd))
>                              ^~~~~~~
>>> mm/arch_pgtable_test.c:233:11: note: in expansion of macro 'pmd_none'
>      WARN_ON(!pmd_none(READ_ONCE(*pmdp)));
>               ^~~~~~~~
>    mm/arch_pgtable_test.c: In function 'pmd_populate_tests':
>>> arch/m68k/include/asm/page.h:31:22: error: lvalue required as unary '&' operand
>     #define pmd_val(x) ((&x)->pmd[0])

Storing READ_ONCE(*pmdp) in a local pmd_t variable first solves the problem.
