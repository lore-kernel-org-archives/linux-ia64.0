From: Christophe Leroy <christophe.leroy@csgroup.eu>
Date: Wed, 14 Apr 2021 05:22:06 +0000
Subject: Re: [PATCH] mm: Define ARCH_HAS_FIRST_USER_ADDRESS
Message-Id: <f29ba8e2-3071-c963-1e9f-e8c88526ed8d@csgroup.eu>
List-Id: <linux-ia64.vger.kernel.org>
References: <1618368899-20311-1-git-send-email-anshuman.khandual@arm.com>
In-Reply-To: <1618368899-20311-1-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Anshuman Khandual <anshuman.khandual@arm.com>, linux-mm@kvack.org, akpm@linux-foundation.org
Cc: linux-s390@vger.kernel.org, x86@kernel.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-sh@vger.kernel.org, linux-um@lists.infradead.org, linux-mips@vger.kernel.org, linux-csky@vger.kernel.org, linux-kernel@vger.kernel.org, linux-m68k@lists.linux-m68k.org, openrisc@lists.librecores.org, linux-alpha@vger.kernel.org, sparclinux@vger.kernel.org, linux-riscv@lists.infradead.org, linux-snps-arc@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, linux-arm-kernel@lists.infradead.org



Le 14/04/2021 à 04:54, Anshuman Khandual a écrit :
> Currently most platforms define FIRST_USER_ADDRESS as 0UL duplicating the
> same code all over. Instead define a new option ARCH_HAS_FIRST_USER_ADDRESS
> for those platforms which would override generic default FIRST_USER_ADDRESS
> value 0UL. This makes it much cleaner with reduced code.
> 
> Cc: linux-alpha@vger.kernel.org
> Cc: linux-snps-arc@lists.infradead.org
> Cc: linux-arm-kernel@lists.infradead.org
> Cc: linux-csky@vger.kernel.org
> Cc: linux-hexagon@vger.kernel.org
> Cc: linux-ia64@vger.kernel.org
> Cc: linux-m68k@lists.linux-m68k.org
> Cc: linux-mips@vger.kernel.org
> Cc: openrisc@lists.librecores.org
> Cc: linux-parisc@vger.kernel.org
> Cc: linuxppc-dev@lists.ozlabs.org
> Cc: linux-riscv@lists.infradead.org
> Cc: linux-s390@vger.kernel.org
> Cc: linux-sh@vger.kernel.org
> Cc: sparclinux@vger.kernel.org
> Cc: linux-um@lists.infradead.org
> Cc: linux-xtensa@linux-xtensa.org
> Cc: x86@kernel.org
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org
> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
> ---
>   arch/alpha/include/asm/pgtable.h             | 1 -
>   arch/arc/include/asm/pgtable.h               | 6 ------
>   arch/arm/Kconfig                             | 1 +
>   arch/arm64/include/asm/pgtable.h             | 2 --
>   arch/csky/include/asm/pgtable.h              | 1 -
>   arch/hexagon/include/asm/pgtable.h           | 3 ---
>   arch/ia64/include/asm/pgtable.h              | 1 -
>   arch/m68k/include/asm/pgtable_mm.h           | 1 -
>   arch/microblaze/include/asm/pgtable.h        | 2 --
>   arch/mips/include/asm/pgtable-32.h           | 1 -
>   arch/mips/include/asm/pgtable-64.h           | 1 -
>   arch/nds32/Kconfig                           | 1 +
>   arch/nios2/include/asm/pgtable.h             | 2 --
>   arch/openrisc/include/asm/pgtable.h          | 1 -
>   arch/parisc/include/asm/pgtable.h            | 2 --
>   arch/powerpc/include/asm/book3s/pgtable.h    | 1 -
>   arch/powerpc/include/asm/nohash/32/pgtable.h | 1 -
>   arch/powerpc/include/asm/nohash/64/pgtable.h | 2 --
>   arch/riscv/include/asm/pgtable.h             | 2 --
>   arch/s390/include/asm/pgtable.h              | 2 --
>   arch/sh/include/asm/pgtable.h                | 2 --
>   arch/sparc/include/asm/pgtable_32.h          | 1 -
>   arch/sparc/include/asm/pgtable_64.h          | 3 ---
>   arch/um/include/asm/pgtable-2level.h         | 1 -
>   arch/um/include/asm/pgtable-3level.h         | 1 -
>   arch/x86/include/asm/pgtable_types.h         | 2 --
>   arch/xtensa/include/asm/pgtable.h            | 1 -
>   include/linux/mm.h                           | 4 ++++
>   mm/Kconfig                                   | 4 ++++
>   29 files changed, 10 insertions(+), 43 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 8ba434287387..47098ccd715e 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -46,6 +46,10 @@ extern int sysctl_page_lock_unfairness;
>   
>   void init_mm_internals(void);
>   
> +#ifndef ARCH_HAS_FIRST_USER_ADDRESS

I guess you didn't test it ..... :)

should be #ifndef CONFIG_ARCH_HAS_FIRST_USER_ADDRESS

> +#define FIRST_USER_ADDRESS	0UL
> +#endif

But why do we need a config option at all for that ?

Why not just:

#ifndef FIRST_USER_ADDRESS
#define FIRST_USER_ADDRESS	0UL
#endif

> +
>   #ifndef CONFIG_NEED_MULTIPLE_NODES	/* Don't use mapnrs, do it properly */
>   extern unsigned long max_mapnr;
>   
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 24c045b24b95..373fbe377075 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -806,6 +806,10 @@ config VMAP_PFN
>   
>   config ARCH_USES_HIGH_VMA_FLAGS
>   	bool
> +
> +config ARCH_HAS_FIRST_USER_ADDRESS
> +	bool
> +
>   config ARCH_HAS_PKEYS
>   	bool
>   
> 
