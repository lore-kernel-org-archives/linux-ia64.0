From: david mosberger <dmosberger@gmail.com>
Date: Wed, 17 Aug 2005 01:56:19 +0000
Subject: Re: Rationalise Region definitions
Message-Id: <ed5aea430508161856380022de@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <17154.38711.462180.885909@berry.gelato.unsw.EDU.AU>
In-Reply-To: <17154.38711.462180.885909@berry.gelato.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Peter,

You deleted this comment:

/* note: this is hardcoded in reload_context()!*/

but didn't actually do anything about reload_context().  There is an
ia64_get_rr(0x8...) which would need to be fixed.

  --david

On 8/16/05, Peter Chubb <peterc@gelato.unsw.edu.au> wrote:
> 
> Currently, region numbers are defined in several files, with several
> names.  For example, we have REGION_KERNEL in asm/page.h and
> RGN_KERNEL in pgtable.h
> 
> We also have address definitions that should depend on the
> RGN_XXX macros, but are currently just long constants.
> 
> The following patch reorganises all the definitions so that they have
> the same form (RGN_XXX), are in one place, and that addresses that
> depend on RGN_XXX are derived from them.
> 
> (This is a necessary but not sufficient patch to allow UML-like
> operation on IA64).
> 
> Signed-off-by: Peter Chubb <peterc@gelato.unsw.edu.au>
> 
>  arch/ia64/kernel/sys_ia64.c |    2 +-
>  arch/ia64/mm/hugetlbpage.c  |    8 ++++----
>  include/asm-ia64/io.h       |    2 +-
>  include/asm-ia64/page.h     |   27 ++++++++++++++++++---------
>  include/asm-ia64/pgtable.h  |   13 +++++--------
>  include/asm-ia64/system.h   |    5 +++--
>  6 files changed, 32 insertions(+), 25 deletions(-)
> 
> Index: linux-2.6-ia64/include/asm-ia64/io.h
> =================================> --- linux-2.6-ia64.orig/include/asm-ia64/io.h   2005-08-17 11:41:35.973769771 +1000
> +++ linux-2.6-ia64/include/asm-ia64/io.h        2005-08-17 11:41:42.013728802 +1000
> @@ -23,7 +23,7 @@
>  #define __SLOW_DOWN_IO do { } while (0)
>  #define SLOW_DOWN_IO   do { } while (0)
> 
> -#define __IA64_UNCACHED_OFFSET 0xc000000000000000UL    /* region 6 */
> +#define __IA64_UNCACHED_OFFSET RGN_BASE(RGN_UNCACHED)
> 
>  /*
>   * The legacy I/O space defined by the ia64 architecture supports only 65536 ports, but
> Index: linux-2.6-ia64/include/asm-ia64/page.h
> =================================> --- linux-2.6-ia64.orig/include/asm-ia64/page.h 2005-08-17 09:42:45.234137614 +1000
> +++ linux-2.6-ia64/include/asm-ia64/page.h      2005-08-17 11:41:42.021728748 +1000
> @@ -13,6 +13,19 @@
>  #include <asm/types.h>
> 
>  /*
> + * The top three bits of an IA64 address are its Region Number.
> + * Different regions are assigned to different purposes.
> + */
> +#define RGN_SHIFT      (61)
> +#define RGN_BASE(r)  (__IA64_UL_CONST(r)<<RGN_SHIFT)
> +
> +#define KHIGH -1       /* high three bits of Kernel virtual address */
> +#define RGN_KERNEL     7       /* Identity mapped region */
> +#define RGN_UNCACHED    6      /* Identity mapped I/O region */
> +#define RGN_GATE       5       /* Gate page, Kernel text, etc */
> +#define RGN_HPAGE      4       /* For Huge TLB pages */
> +
> +/*
>   * PAGE_SHIFT determines the actual kernel page size.
>   */
>  #if defined(CONFIG_IA64_PAGE_SIZE_4KB)
> @@ -36,10 +49,9 @@
> 
>  #define RGN_MAP_LIMIT  ((1UL << (4*PAGE_SHIFT - 12)) - PAGE_SIZE)      /* per region addr limit */
> 
> +
>  #ifdef CONFIG_HUGETLB_PAGE
> -# define REGION_HPAGE          (4UL)   /* note: this is hardcoded in reload_context()!*/
> -# define REGION_SHIFT          61
> -# define HPAGE_REGION_BASE     (REGION_HPAGE << REGION_SHIFT)
> +# define HPAGE_REGION_BASE     RGN_BASE(RGN_HPAGE)
>  # define HPAGE_SHIFT           hpage_shift
>  # define HPAGE_SHIFT_DEFAULT   28      /* check ia64 SDM for architecture supported size */
>  # define HPAGE_SIZE            (__IA64_UL_CONST(1) << HPAGE_SHIFT)
> @@ -130,16 +142,13 @@
>  #define REGION_NUMBER(x)       ({ia64_va _v; _v.l = (long) (x); _v.f.reg;})
>  #define REGION_OFFSET(x)       ({ia64_va _v; _v.l = (long) (x); _v.f.off;})
> 
> -#define REGION_SIZE            REGION_NUMBER(1)
> -#define REGION_KERNEL          7
> -
>  #ifdef CONFIG_HUGETLB_PAGE
>  # define htlbpage_to_page(x)   (((unsigned long) REGION_NUMBER(x) << 61)                       \
>                                  | (REGION_OFFSET(x) >> (HPAGE_SHIFT-PAGE_SHIFT)))
>  # define HUGETLB_PAGE_ORDER    (HPAGE_SHIFT - PAGE_SHIFT)
>  # define is_hugepage_only_range(mm, addr, len)         \
> -        (REGION_NUMBER(addr) = REGION_HPAGE &&        \
> -         REGION_NUMBER((addr)+(len)-1) = REGION_HPAGE)
> +        (REGION_NUMBER(addr) = RGN_HPAGE &&   \
> +         REGION_NUMBER((addr)+(len)-1) = RGN_HPAGE)
>  extern unsigned int hpage_shift;
>  #endif
> 
> @@ -197,7 +206,7 @@
>  # define __pgprot(x)   (x)
>  #endif /* !STRICT_MM_TYPECHECKS */
> 
> -#define PAGE_OFFSET                    __IA64_UL_CONST(0xe000000000000000)
> +#define PAGE_OFFSET                    RGN_BASE(RGN_KERNEL)
> 
>  #define VM_DATA_DEFAULT_FLAGS          (VM_READ | VM_WRITE |                                   \
>                                          VM_MAYREAD | VM_MAYWRITE | VM_MAYEXEC |                \
> Index: linux-2.6-ia64/include/asm-ia64/pgtable.h
> =================================> --- linux-2.6-ia64.orig/include/asm-ia64/pgtable.h      2005-08-17 09:42:45.238137586 +1000
> +++ linux-2.6-ia64/include/asm-ia64/pgtable.h   2005-08-17 11:41:42.033728666 +1000
> @@ -204,21 +204,18 @@
>  #define set_pte(ptep, pteval)  (*(ptep) = (pteval))
>  #define set_pte_at(mm,addr,ptep,pteval) set_pte(ptep,pteval)
> 
> -#define RGN_SIZE       (1UL << 61)
> -#define RGN_KERNEL     7
> -
> -#define VMALLOC_START          0xa000000200000000UL
> +#define VMALLOC_START          (RGN_BASE(RGN_GATE) + 0x200000000UL)
>  #ifdef CONFIG_VIRTUAL_MEM_MAP
> -# define VMALLOC_END_INIT      (0xa000000000000000UL + (1UL << (4*PAGE_SHIFT - 9)))
> +# define VMALLOC_END_INIT      (RGN_BASE(RGN_GATE) + (1UL << (4*PAGE_SHIFT - 9)))
>  # define VMALLOC_END           vmalloc_end
>    extern unsigned long vmalloc_end;
>  #else
> -# define VMALLOC_END           (0xa000000000000000UL + (1UL << (4*PAGE_SHIFT - 9)))
> +# define VMALLOC_END           (RGN_BASE(RGN_GATE) + (1UL << (4*PAGE_SHIFT - 9)))
>  #endif
> 
>  /* fs/proc/kcore.c */
> -#define        kc_vaddr_to_offset(v) ((v) - 0xa000000000000000UL)
> -#define        kc_offset_to_vaddr(o) ((o) + 0xa000000000000000UL)
> +#define        kc_vaddr_to_offset(v) ((v) - RGN_BASE(RGN_GATE))
> +#define        kc_offset_to_vaddr(o) ((o) + RGN_BASE(RGN_GATE))
> 
>  /*
>   * Conversion functions: convert page frame number (pfn) and a protection value to a page
> Index: linux-2.6-ia64/include/asm-ia64/system.h
> =================================> --- linux-2.6-ia64.orig/include/asm-ia64/system.h       2005-08-17 09:42:45.238137586 +1000
> +++ linux-2.6-ia64/include/asm-ia64/system.h    2005-08-17 11:41:42.037728639 +1000
> @@ -19,12 +19,13 @@
>  #include <asm/pal.h>
>  #include <asm/percpu.h>
> 
> -#define GATE_ADDR              __IA64_UL_CONST(0xa000000000000000)
> +#define GATE_ADDR              RGN_BASE(RGN_GATE)
> +
>  /*
>   * 0xa000000000000000+2*PERCPU_PAGE_SIZE
>   * - 0xa000000000000000+3*PERCPU_PAGE_SIZE remain unmapped (guard page)
>   */
> -#define KERNEL_START            __IA64_UL_CONST(0xa000000100000000)
> +#define KERNEL_START            (GATE_ADDR+0x100000000)
>  #define PERCPU_ADDR            (-PERCPU_PAGE_SIZE)
> 
>  #ifndef __ASSEMBLY__
> Index: linux-2.6-ia64/arch/ia64/kernel/sys_ia64.c
> =================================> --- linux-2.6-ia64.orig/arch/ia64/kernel/sys_ia64.c     2005-08-17 09:42:45.238137586 +1000
> +++ linux-2.6-ia64/arch/ia64/kernel/sys_ia64.c  2005-08-17 11:41:42.069728422 +1000
> @@ -35,7 +35,7 @@
>                 return -ENOMEM;
> 
>  #ifdef CONFIG_HUGETLB_PAGE
> -       if (REGION_NUMBER(addr) = REGION_HPAGE)
> +       if (REGION_NUMBER(addr) = RGN_HPAGE)
>                 addr = 0;
>  #endif
>         if (!addr)
> Index: linux-2.6-ia64/arch/ia64/mm/hugetlbpage.c
> =================================> --- linux-2.6-ia64.orig/arch/ia64/mm/hugetlbpage.c      2005-08-17 09:42:45.242137559 +1000
> +++ linux-2.6-ia64/arch/ia64/mm/hugetlbpage.c   2005-08-17 11:41:42.085728314 +1000
> @@ -76,7 +76,7 @@
>                 return -EINVAL;
>         if (addr & ~HPAGE_MASK)
>                 return -EINVAL;
> -       if (REGION_NUMBER(addr) != REGION_HPAGE)
> +       if (REGION_NUMBER(addr) != RGN_HPAGE)
>                 return -EINVAL;
> 
>         return 0;
> @@ -87,7 +87,7 @@
>         struct page *page;
>         pte_t *ptep;
> 
> -       if (REGION_NUMBER(addr) != REGION_HPAGE)
> +       if (REGION_NUMBER(addr) != RGN_HPAGE)
>                 return ERR_PTR(-EINVAL);
> 
>         ptep = huge_pte_offset(mm, addr);
> @@ -142,8 +142,8 @@
>                 return -ENOMEM;
>         if (len & ~HPAGE_MASK)
>                 return -EINVAL;
> -       /* This code assumes that REGION_HPAGE != 0. */
> -       if ((REGION_NUMBER(addr) != REGION_HPAGE) || (addr & (HPAGE_SIZE - 1)))
> +       /* This code assumes that RGN_HPAGE != 0. */
> +       if ((REGION_NUMBER(addr) != RGN_HPAGE) || (addr & (HPAGE_SIZE - 1)))
>                 addr = HPAGE_REGION_BASE;
>         else
>                 addr = ALIGN(addr, HPAGE_SIZE);
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


-- 
Mosberger Consulting LLC, voice/fax: 510-744-9372,
http://www.mosberger-consulting.com/
35706 Runckel Lane, Fremont, CA 94536
