From: Will Deacon <will.deacon@arm.com>
Date: Mon, 04 Jan 2016 14:46:43 +0000
Subject: Re: [PATCH 6/6] arm64: switch to relative exception tables
Message-Id: <20160104144643.GE1616@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1451837157-447-1-git-send-email-ard.biesheuvel@linaro.org>
 <1451837157-447-7-git-send-email-ard.biesheuvel@linaro.org>
In-Reply-To: <1451837157-447-7-git-send-email-ard.biesheuvel@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, x86@kernel.org, hpa@zytor.com, mingo@redhat.com, heiko.carstens@de.ibm.com, schwidefsky@de.ibm.com, mattst88@gmail.com, ink@jurassic.park.msu.ru, rth@twiddle.net, tony.luck@intel.com, fenghua.yu@intel.com, catalin.marinas@arm.com, arnd@arndb.de, akpm@linux-foundation.org, mark.rutland@arm.com, marc.zyngier@arm.com

On Sun, Jan 03, 2016 at 05:05:57PM +0100, Ard Biesheuvel wrote:
> Instead of using absolute addresses for both the exception location
> and the fixup, use offsets relative to the exception table entry values.
> Not only does this cut the size of the exception table in half, it is
> also a prerequisite for KASLR, since absolute exception table entries
> are subject to dynamic relocation, which is incompatible with the sorting
> of the exception table that occurs at build time.
> 
> Cc: Catalin Marinas <catalin.marinas@arm.com>
> Cc: Will Deacon <will.deacon@arm.com>
> Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
> ---
> 
> Note that this patch supersedes the version I sent as part of the series that
> implements KASLR for arm64: http://thread.gmane.org/gmane.linux.kernel/2116531
> 
>  arch/arm64/include/asm/assembler.h   |  2 +-
>  arch/arm64/include/asm/futex.h       |  4 ++--
>  arch/arm64/include/asm/uaccess.h     | 18 ++++++++++--------
>  arch/arm64/kernel/armv8_deprecated.c |  4 ++--
>  arch/arm64/mm/extable.c              |  2 +-
>  scripts/sortextable.c                |  2 +-
>  6 files changed, 17 insertions(+), 15 deletions(-)

This looks good to me, so for the arm64 part (i.e. this patch):

  Acked-by: Will Deacon <will.deacon@arm.com>

Will

> diff --git a/arch/arm64/include/asm/assembler.h b/arch/arm64/include/asm/assembler.h
> index 12eff928ef8b..8094d50f05bc 100644
> --- a/arch/arm64/include/asm/assembler.h
> +++ b/arch/arm64/include/asm/assembler.h
> @@ -98,7 +98,7 @@
>  9999:	x;					\
>  	.section __ex_table,"a";		\
>  	.align	3;				\
> -	.quad	9999b,l;			\
> +	.long	(9999b - .), (l - .);		\
>  	.previous
>  
>  /*
> diff --git a/arch/arm64/include/asm/futex.h b/arch/arm64/include/asm/futex.h
> index 007a69fc4f40..35e73e255ad3 100644
> --- a/arch/arm64/include/asm/futex.h
> +++ b/arch/arm64/include/asm/futex.h
> @@ -44,7 +44,7 @@
>  "	.popsection\n"							\
>  "	.pushsection __ex_table,\"a\"\n"				\
>  "	.align	3\n"							\
> -"	.quad	1b, 4b, 2b, 4b\n"					\
> +"	.long	(1b - .), (4b - .), (2b - .), (4b - .)\n"		\
>  "	.popsection\n"							\
>  	ALTERNATIVE("nop", SET_PSTATE_PAN(1), ARM64_HAS_PAN,		\
>  		    CONFIG_ARM64_PAN)					\
> @@ -135,7 +135,7 @@ futex_atomic_cmpxchg_inatomic(u32 *uval, u32 __user *uaddr,
>  "	.popsection\n"
>  "	.pushsection __ex_table,\"a\"\n"
>  "	.align	3\n"
> -"	.quad	1b, 4b, 2b, 4b\n"
> +"	.long	(1b - .), (4b - .), (2b - .), (4b - .)\n"
>  "	.popsection\n"
>  	: "+r" (ret), "=&r" (val), "+Q" (*uaddr), "=&r" (tmp)
>  	: "r" (oldval), "r" (newval), "Ir" (-EFAULT)
> diff --git a/arch/arm64/include/asm/uaccess.h b/arch/arm64/include/asm/uaccess.h
> index b2ede967fe7d..ab627e6c06c9 100644
> --- a/arch/arm64/include/asm/uaccess.h
> +++ b/arch/arm64/include/asm/uaccess.h
> @@ -36,11 +36,11 @@
>  #define VERIFY_WRITE 1
>  
>  /*
> - * The exception table consists of pairs of addresses: the first is the
> - * address of an instruction that is allowed to fault, and the second is
> - * the address at which the program should continue.  No registers are
> - * modified, so it is entirely up to the continuation code to figure out
> - * what to do.
> + * The exception table consists of pairs of relative offsets: the first
> + * is the relative offset to an instruction that is allowed to fault,
> + * and the second is the relative offset at which the program should
> + * continue. No registers are modified, so it is entirely up to the
> + * continuation code to figure out what to do.
>   *
>   * All the routines below use bits of fixup code that are out of line
>   * with the main instruction path.  This means when everything is well,
> @@ -50,9 +50,11 @@
>  
>  struct exception_table_entry
>  {
> -	unsigned long insn, fixup;
> +	int insn, fixup;
>  };
>  
> +#define ARCH_HAS_RELATIVE_EXTABLE
> +
>  extern int fixup_exception(struct pt_regs *regs);
>  
>  #define KERNEL_DS	(-1UL)
> @@ -125,7 +127,7 @@ static inline void set_fs(mm_segment_t fs)
>  	"	.previous\n"						\
>  	"	.section __ex_table,\"a\"\n"				\
>  	"	.align	3\n"						\
> -	"	.quad	1b, 3b\n"					\
> +	"	.long	(1b - .), (3b - .)\n"				\
>  	"	.previous"						\
>  	: "+r" (err), "=&r" (x)						\
>  	: "r" (addr), "i" (-EFAULT))
> @@ -192,7 +194,7 @@ do {									\
>  	"	.previous\n"						\
>  	"	.section __ex_table,\"a\"\n"				\
>  	"	.align	3\n"						\
> -	"	.quad	1b, 3b\n"					\
> +	"	.long	(1b - .), (3b - .)\n"				\
>  	"	.previous"						\
>  	: "+r" (err)							\
>  	: "r" (x), "r" (addr), "i" (-EFAULT))
> diff --git a/arch/arm64/kernel/armv8_deprecated.c b/arch/arm64/kernel/armv8_deprecated.c
> index 937f5e58a4d3..8f21b1363387 100644
> --- a/arch/arm64/kernel/armv8_deprecated.c
> +++ b/arch/arm64/kernel/armv8_deprecated.c
> @@ -299,8 +299,8 @@ static void register_insn_emulation_sysctl(struct ctl_table *table)
>  	"	.popsection"					\
>  	"	.pushsection	 __ex_table,\"a\"\n"		\
>  	"	.align		3\n"				\
> -	"	.quad		0b, 4b\n"			\
> -	"	.quad		1b, 4b\n"			\
> +	"	.long		(0b - .), (4b - .)\n"		\
> +	"	.long		(1b - .), (4b - .)\n"		\
>  	"	.popsection\n"					\
>  	ALTERNATIVE("nop", SET_PSTATE_PAN(1), ARM64_HAS_PAN,	\
>  		CONFIG_ARM64_PAN)				\
> diff --git a/arch/arm64/mm/extable.c b/arch/arm64/mm/extable.c
> index 79444279ba8c..81acd4706878 100644
> --- a/arch/arm64/mm/extable.c
> +++ b/arch/arm64/mm/extable.c
> @@ -11,7 +11,7 @@ int fixup_exception(struct pt_regs *regs)
>  
>  	fixup = search_exception_tables(instruction_pointer(regs));
>  	if (fixup)
> -		regs->pc = fixup->fixup;
> +		regs->pc = (unsigned long)&fixup->fixup + fixup->fixup;
>  
>  	return fixup != NULL;
>  }
> diff --git a/scripts/sortextable.c b/scripts/sortextable.c
> index c2423d913b46..af247c70fb66 100644
> --- a/scripts/sortextable.c
> +++ b/scripts/sortextable.c
> @@ -282,12 +282,12 @@ do_file(char const *const fname)
>  	case EM_386:
>  	case EM_X86_64:
>  	case EM_S390:
> +	case EM_AARCH64:
>  		custom_sort = sort_relative_table;
>  		break;
>  	case EM_ARCOMPACT:
>  	case EM_ARCV2:
>  	case EM_ARM:
> -	case EM_AARCH64:
>  	case EM_MICROBLAZE:
>  	case EM_MIPS:
>  	case EM_XTENSA:
> -- 
> 1.9.1
> 
