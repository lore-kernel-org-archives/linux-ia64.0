From: Ingo Molnar <mingo@kernel.org>
Date: Mon, 07 Oct 2019 13:06:17 +0000
Subject: Re: [PATCH V4 2/2] mm/pgtable/debug: Add test validating architecture page table helpers
Message-Id: <20191007130617.GB56546@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1570427124-21887-1-git-send-email-anshuman.khandual@arm.com>
 <1570427124-21887-3-git-send-email-anshuman.khandual@arm.com>
In-Reply-To: <1570427124-21887-3-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: Mark Rutland <mark.rutland@arm.com>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, James Hogan <jhogan@kernel.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Heiko Carstens <heiko.carstens@de.ibm.com>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Dave Hansen <dave.hansen@intel.com>, Paul Mackerras <paulus@samba.org>, sparclinux@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-s390@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, x86@kernel.org, Russell King - ARM Linux <linux@armlinux.org.uk>, Matthew Wilcox <willy@infradead.org>, Steven Price <Steven.Price@arm.com>, Jason Gunthorpe <jgg@ziepe.ca>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, Kees Cook <keescook@chromium.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Mark Brown <broonie@kernel.org>, "Kirill A . Shutemov" <kirill@shutemov.name>, Dan Williams <dan.j.williams@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christophe Leroy <christophe.leroy@c-s.fr>, Sri Krishna chowdary <schowdary@nvidia.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mips@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, linux-kernel@vger.kernel.org, Paul Burton <paul.burton@mips.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Vineet Gupta <vgupta@synopsys.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>


* Anshuman Khandual <anshuman.khandual@arm.com> wrote:

> This adds a test module which will validate architecture page table helpers
> and accessors regarding compliance with generic MM semantics expectations.
> This will help various architectures in validating changes to the existing
> page table helpers or addition of new ones.
> 
> Test page table and memory pages creating it's entries at various level are
> all allocated from system memory with required alignments. If memory pages
> with required size and alignment could not be allocated, then all depending
> individual tests are skipped.

> diff --git a/arch/x86/include/asm/pgtable_64_types.h b/arch/x86/include/asm/pgtable_64_types.h
> index 52e5f5f2240d..b882792a3999 100644
> --- a/arch/x86/include/asm/pgtable_64_types.h
> +++ b/arch/x86/include/asm/pgtable_64_types.h
> @@ -40,6 +40,8 @@ static inline bool pgtable_l5_enabled(void)
>  #define pgtable_l5_enabled() 0
>  #endif /* CONFIG_X86_5LEVEL */
>  
> +#define mm_p4d_folded(mm) (!pgtable_l5_enabled())
> +
>  extern unsigned int pgdir_shift;
>  extern unsigned int ptrs_per_p4d;

Any deep reason this has to be a macro instead of proper C?

> diff --git a/mm/Kconfig.debug b/mm/Kconfig.debug
> index 327b3ebf23bf..683131b1ee7d 100644
> --- a/mm/Kconfig.debug
> +++ b/mm/Kconfig.debug
> @@ -117,3 +117,18 @@ config DEBUG_RODATA_TEST
>      depends on STRICT_KERNEL_RWX
>      ---help---
>        This option enables a testcase for the setting rodata read-only.
> +
> +config DEBUG_ARCH_PGTABLE_TEST
> +	bool "Test arch page table helpers for semantics compliance"
> +	depends on MMU
> +	depends on DEBUG_KERNEL
> +	depends on !(ARM || IA64)

Please add a proper enabling switch for architectures to opt in.

Please also add it to Documentation/features/list-arch.sh so that it's 
listed as a 'TODO' entry on architectures where the tests are not enabled 
yet.

> +	help
> +	  This options provides a kernel module which can be used to test
> +	  architecture page table helper functions on various platform in
> +	  verifying if they comply with expected generic MM semantics. This
> +	  will help architectures code in making sure that any changes or
> +	  new additions of these helpers will still conform to generic MM
> +	  expected semantics.

Typos and grammar fixed:

	help
	  This option provides a kernel module which can be used to test
	  architecture page table helper functions on various platforms in
	  verifying if they comply with expected generic MM semantics. This
	  will help architecture code in making sure that any changes or
	  new additions of these helpers still conform to expected 
	  semantics of the generic MM.

Also, more fundamentally: isn't a kernel module too late for such a debug 
check, should something break due to a core MM change? Have these debug 
checks caught any bugs or inconsistencies before?

Why not call this as some earlier MM debug check, after enabling paging 
but before executing user-space binaries or relying on complex MM ops 
within the kernel, called at a stage when those primitives are all 
expected to work fine?

It seems to me that arch_pgtable_tests_init) won't even context-switch 
normally, right?

Finally, instead of inventing yet another randomly named .config debug 
switch, please fit it into the regular MM debug options which go along 
the CONFIG_DEBUG_VM* naming scheme.

Might even make sense to enable these new debug checks by default if 
CONFIG_DEBUG_VM=y, that way we'll get a *lot* more debug coverage than 
some random module somewhere that few people will know about, let alone 
run.

Thanks,

	Ingo
