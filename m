From: Christophe Leroy <christophe.leroy@c-s.fr>
Date: Thu, 05 Jul 2018 10:22:30 +0000
Subject: Re: [PATCH v3 02/11] hugetlb: Introduce generic version of hugetlb_free_pgd_range
Message-Id: <005bf713-fb51-bf29-5f86-6f244cd49f35@c-s.fr>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180705051640.790-1-alex@ghiti.fr>
 <20180705051640.790-3-alex@ghiti.fr>
In-Reply-To: <20180705051640.790-3-alex@ghiti.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alexandre Ghiti <alex@ghiti.fr>, linux@armlinux.org.uk, catalin.marinas@arm.com, will.deacon@arm.com, tony.luck@intel.com, fenghua.yu@intel.com, ralf@linux-mips.org, paul.burton@mips.com, jhogan@kernel.org, jejb@parisc-linux.org, deller@gmx.de, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, ysato@users.sourceforge.jp, dalias@libc.org, davem@davemloft.net, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, arnd@arndb.de, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org



On 07/05/2018 05:16 AM, Alexandre Ghiti wrote:
> arm, arm64, mips, parisc, sh, x86 architectures use the
> same version of hugetlb_free_pgd_range, so move this generic
> implementation into asm-generic/hugetlb.h.
> 
> Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>

Build failure on mpc885_ads_defconfig

   CC      arch/powerpc/kernel/setup-common.o
In file included from arch/powerpc/kernel/setup-common.c:37:
./include/linux/hugetlb.h:191:65: error: expected identifier or '(' 
before '{' token
  #define hugetlb_free_pgd_range(tlb, addr, end, floor, ceiling) 
({BUG(); 0; })
                                                                  ^
./include/asm-generic/hugetlb.h:44:20: note: in expansion of macro 
'hugetlb_free_pgd_range'
  static inline void hugetlb_free_pgd_range(struct mmu_gather *tlb,
                     ^~~~~~~~~~~~~~~~~~~~~~

see below

> ---
>   arch/arm/include/asm/hugetlb.h     | 12 ++----------
>   arch/arm64/include/asm/hugetlb.h   | 10 ----------
>   arch/ia64/include/asm/hugetlb.h    |  5 +++--
>   arch/mips/include/asm/hugetlb.h    | 13 ++-----------
>   arch/parisc/include/asm/hugetlb.h  | 12 ++----------
>   arch/powerpc/include/asm/hugetlb.h |  4 +++-
>   arch/sh/include/asm/hugetlb.h      | 12 ++----------
>   arch/sparc/include/asm/hugetlb.h   |  4 +++-
>   arch/x86/include/asm/hugetlb.h     | 11 ++---------
>   include/asm-generic/hugetlb.h      | 11 +++++++++++
>   10 files changed, 30 insertions(+), 64 deletions(-)
> 

[snip]

> diff --git a/arch/powerpc/include/asm/hugetlb.h b/arch/powerpc/include/asm/hugetlb.h
> index 3225eb6402cc..de46ee16b615 100644
> --- a/arch/powerpc/include/asm/hugetlb.h
> +++ b/arch/powerpc/include/asm/hugetlb.h
> @@ -4,7 +4,6 @@
>   
>   #ifdef CONFIG_HUGETLB_PAGE
>   #include <asm/page.h>
> -#include <asm-generic/hugetlb.h>
>   
>   extern struct kmem_cache *hugepte_cache;
>   
> @@ -113,6 +112,7 @@ static inline void flush_hugetlb_page(struct vm_area_struct *vma,
>   void flush_hugetlb_page(struct vm_area_struct *vma, unsigned long vmaddr);
>   #endif
>   
> +#define __HAVE_ARCH_HUGETLB_FREE_PGD_RANGE
>   void hugetlb_free_pgd_range(struct mmu_gather *tlb, unsigned long addr,
>   			    unsigned long end, unsigned long floor,
>   			    unsigned long ceiling);
> @@ -193,4 +193,6 @@ static inline pte_t *hugepte_offset(hugepd_t hpd, unsigned long addr,
>   }
>   #endif /* CONFIG_HUGETLB_PAGE */
>   
> +#include <asm-generic/hugetlb.h>
> +

That include was previously inside #ifdef CONFIG_HUGETLB_PAGE.
Why put it outside ?

Christophe

