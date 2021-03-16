From: Christophe Leroy <christophe.leroy@csgroup.eu>
Date: Tue, 16 Mar 2021 14:47:05 +0000
Subject: Re: [PATCH] mm: Move mem_init_print_info() into mm_init()
Message-Id: <26cca1c0-bd38-3d5b-5ca4-44081c444396@csgroup.eu>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210316142637.92193-1-wangkefeng.wang@huawei.com>
In-Reply-To: <20210316142637.92193-1-wangkefeng.wang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Kefeng Wang <wangkefeng.wang@huawei.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, Dave Hansen <dave.hansen@linux.intel.com>, linux-mm@kvack.org, Guo Ren <guoren@kernel.org>, sparclinux@vger.kernel.org, linux-riscv@lists.infradead.org, Jonas Bonn <jonas@southpole.se>, linux-s390@vger.kernel.org, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-hexagon@vger.kernel.org, Huacai Chen <chenhuacai@kernel.org>, Russell King <linux@armlinux.org.uk>, linux-csky@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, linux-snps-arc@lists.infradead.org, linux-xtensa@linux-xtensa.org, Heiko Carstens <hca@linux.ibm.com>, linux-um@lists.infradead.org, linux-m68k@lists.linux-m68k.org, openrisc@lists.librecores.org, linux-arm-kernel@lists.infradead.org, Richard Henderson <rth@twiddle.net>, linux-parisc@vger.kernel.org, linux-mips@vger.kernel.org, Palmer Dabbelt <palmer@dabbelt.com>, linux-alpha@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>



Le 16/03/2021 à 15:26, Kefeng Wang a écrit :
> mem_init_print_info() is called in mem_init() on each architecture,
> and pass NULL argument, cleanup it by using void argument and move
> it into mm_init().
> 
> Signed-off-by: Kefeng Wang <wangkefeng.wang@huawei.com>
> ---
>   arch/alpha/mm/init.c             | 1 -
>   arch/arc/mm/init.c               | 1 -
>   arch/arm/mm/init.c               | 2 --
>   arch/arm64/mm/init.c             | 2 --
>   arch/csky/mm/init.c              | 1 -
>   arch/h8300/mm/init.c             | 2 --
>   arch/hexagon/mm/init.c           | 1 -
>   arch/ia64/mm/init.c              | 1 -
>   arch/m68k/mm/init.c              | 1 -
>   arch/microblaze/mm/init.c        | 1 -
>   arch/mips/loongson64/numa.c      | 1 -
>   arch/mips/mm/init.c              | 1 -
>   arch/mips/sgi-ip27/ip27-memory.c | 1 -
>   arch/nds32/mm/init.c             | 1 -
>   arch/nios2/mm/init.c             | 1 -
>   arch/openrisc/mm/init.c          | 2 --
>   arch/parisc/mm/init.c            | 2 --
>   arch/powerpc/mm/mem.c            | 1 -
>   arch/riscv/mm/init.c             | 1 -
>   arch/s390/mm/init.c              | 2 --
>   arch/sh/mm/init.c                | 1 -
>   arch/sparc/mm/init_32.c          | 2 --
>   arch/sparc/mm/init_64.c          | 1 -
>   arch/um/kernel/mem.c             | 1 -
>   arch/x86/mm/init_32.c            | 2 --
>   arch/x86/mm/init_64.c            | 2 --
>   arch/xtensa/mm/init.c            | 1 -
>   include/linux/mm.h               | 2 +-
>   init/main.c                      | 1 +
>   mm/page_alloc.c                  | 2 +-
>   30 files changed, 3 insertions(+), 38 deletions(-)
> 

> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 55d938297ce6..e4a6bf69c806 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -7728,7 +7728,7 @@ unsigned long free_reserved_area(void *start, void *end, int poison, const char
>   	return pages;
>   }
>   
> -void __init mem_init_print_info(const char *str)
> +void __init mem_init_print_info(void)
>   {
>   	unsigned long physpages, codesize, datasize, rosize, bss_size;
>   	unsigned long init_code_size, init_data_size;
> 

And what about the 'str' in the last line of the function ?

	pr_info("Memory: %luK/%luK available (%luK kernel code, %luK rwdata, %luK rodata, %luK init, %luK 
bss, %luK reserved, %luK cma-reserved"
#ifdef	CONFIG_HIGHMEM
		", %luK highmem"
#endif
		"%s%s)\n",
		nr_free_pages() << (PAGE_SHIFT - 10),
		physpages << (PAGE_SHIFT - 10),
		codesize >> 10, datasize >> 10, rosize >> 10,
		(init_data_size + init_code_size) >> 10, bss_size >> 10,
		(physpages - totalram_pages() - totalcma_pages) << (PAGE_SHIFT - 10),
		totalcma_pages << (PAGE_SHIFT - 10),
#ifdef	CONFIG_HIGHMEM
		totalhigh_pages() << (PAGE_SHIFT - 10),
#endif
		str ? ", " : "", str ? str : "");


Christophe
