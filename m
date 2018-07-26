From: Mike Kravetz <mike.kravetz@oracle.com>
Date: Thu, 26 Jul 2018 19:05:17 +0000
Subject: Re: [PATCH v4 07/11] hugetlb: Introduce generic version of huge_pte_wrprotect
Message-Id: <8a8f0608-ff9a-04ea-7c63-2b3bb99b7966@oracle.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180705110716.3919-1-alex@ghiti.fr>
 <20180705110716.3919-8-alex@ghiti.fr>
In-Reply-To: <20180705110716.3919-8-alex@ghiti.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alexandre Ghiti <alex@ghiti.fr>, linux@armlinux.org.uk, catalin.marinas@arm.com, will.deacon@arm.com, tony.luck@intel.com, fenghua.yu@intel.com, ralf@linux-mips.org, paul.burton@mips.com, jhogan@kernel.org, jejb@parisc-linux.org, deller@gmx.de, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, ysato@users.sourceforge.jp, dalias@libc.org, davem@davemloft.net, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, arnd@arndb.de, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org

On 07/05/2018 04:07 AM, Alexandre Ghiti wrote:
> arm, arm64, ia64, mips, parisc, powerpc, sh, sparc, x86
> architectures use the same version of huge_pte_wrprotect, so move
> this generic implementation into asm-generic/hugetlb.h.
> 

Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>
-- 
Mike Kravetz

> Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
> ---
>  arch/arm/include/asm/hugetlb.h     | 5 -----
>  arch/arm64/include/asm/hugetlb.h   | 5 -----
>  arch/ia64/include/asm/hugetlb.h    | 5 -----
>  arch/mips/include/asm/hugetlb.h    | 5 -----
>  arch/parisc/include/asm/hugetlb.h  | 5 -----
>  arch/powerpc/include/asm/hugetlb.h | 5 -----
>  arch/sh/include/asm/hugetlb.h      | 5 -----
>  arch/sparc/include/asm/hugetlb.h   | 5 -----
>  arch/x86/include/asm/hugetlb.h     | 5 -----
>  include/asm-generic/hugetlb.h      | 7 +++++++
>  10 files changed, 7 insertions(+), 45 deletions(-)
> 
> diff --git a/arch/arm/include/asm/hugetlb.h b/arch/arm/include/asm/hugetlb.h
> index 3d2ce4dbc145..1e718a626ef9 100644
> --- a/arch/arm/include/asm/hugetlb.h
> +++ b/arch/arm/include/asm/hugetlb.h
> @@ -43,11 +43,6 @@ static inline int prepare_hugepage_range(struct file *file,
>  	return 0;
>  }
>  
> -static inline pte_t huge_pte_wrprotect(pte_t pte)
> -{
> -	return pte_wrprotect(pte);
> -}
> -
>  static inline void arch_clear_hugepage_flags(struct page *page)
>  {
>  	clear_bit(PG_dcache_clean, &page->flags);
> diff --git a/arch/arm64/include/asm/hugetlb.h b/arch/arm64/include/asm/hugetlb.h
> index 49247c6f94db..1fd64ebf0cd7 100644
> --- a/arch/arm64/include/asm/hugetlb.h
> +++ b/arch/arm64/include/asm/hugetlb.h
> @@ -42,11 +42,6 @@ static inline int prepare_hugepage_range(struct file *file,
>  	return 0;
>  }
>  
> -static inline pte_t huge_pte_wrprotect(pte_t pte)
> -{
> -	return pte_wrprotect(pte);
> -}
> -
>  static inline void arch_clear_hugepage_flags(struct page *page)
>  {
>  	clear_bit(PG_dcache_clean, &page->flags);
> diff --git a/arch/ia64/include/asm/hugetlb.h b/arch/ia64/include/asm/hugetlb.h
> index bf573500b3c4..82fe3d7a38d9 100644
> --- a/arch/ia64/include/asm/hugetlb.h
> +++ b/arch/ia64/include/asm/hugetlb.h
> @@ -26,11 +26,6 @@ static inline void huge_ptep_clear_flush(struct vm_area_struct *vma,
>  {
>  }
>  
> -static inline pte_t huge_pte_wrprotect(pte_t pte)
> -{
> -	return pte_wrprotect(pte);
> -}
> -
>  static inline void huge_ptep_set_wrprotect(struct mm_struct *mm,
>  					   unsigned long addr, pte_t *ptep)
>  {
> diff --git a/arch/mips/include/asm/hugetlb.h b/arch/mips/include/asm/hugetlb.h
> index 1c9c4531376c..b3d6bb53ee6e 100644
> --- a/arch/mips/include/asm/hugetlb.h
> +++ b/arch/mips/include/asm/hugetlb.h
> @@ -62,11 +62,6 @@ static inline int huge_pte_none(pte_t pte)
>  	return !val || (val = (unsigned long)invalid_pte_table);
>  }
>  
> -static inline pte_t huge_pte_wrprotect(pte_t pte)
> -{
> -	return pte_wrprotect(pte);
> -}
> -
>  static inline void huge_ptep_set_wrprotect(struct mm_struct *mm,
>  					   unsigned long addr, pte_t *ptep)
>  {
> diff --git a/arch/parisc/include/asm/hugetlb.h b/arch/parisc/include/asm/hugetlb.h
> index c09d8c74553c..5a102d7251e4 100644
> --- a/arch/parisc/include/asm/hugetlb.h
> +++ b/arch/parisc/include/asm/hugetlb.h
> @@ -38,11 +38,6 @@ static inline void huge_ptep_clear_flush(struct vm_area_struct *vma,
>  {
>  }
>  
> -static inline pte_t huge_pte_wrprotect(pte_t pte)
> -{
> -	return pte_wrprotect(pte);
> -}
> -
>  void huge_ptep_set_wrprotect(struct mm_struct *mm,
>  					   unsigned long addr, pte_t *ptep);
>  
> diff --git a/arch/powerpc/include/asm/hugetlb.h b/arch/powerpc/include/asm/hugetlb.h
> index 3562d46585ba..7123599089c6 100644
> --- a/arch/powerpc/include/asm/hugetlb.h
> +++ b/arch/powerpc/include/asm/hugetlb.h
> @@ -152,11 +152,6 @@ static inline void huge_ptep_clear_flush(struct vm_area_struct *vma,
>  	flush_hugetlb_page(vma, addr);
>  }
>  
> -static inline pte_t huge_pte_wrprotect(pte_t pte)
> -{
> -	return pte_wrprotect(pte);
> -}
> -
>  extern int huge_ptep_set_access_flags(struct vm_area_struct *vma,
>  				      unsigned long addr, pte_t *ptep,
>  				      pte_t pte, int dirty);
> diff --git a/arch/sh/include/asm/hugetlb.h b/arch/sh/include/asm/hugetlb.h
> index a9f8266f33cf..54f65094efe6 100644
> --- a/arch/sh/include/asm/hugetlb.h
> +++ b/arch/sh/include/asm/hugetlb.h
> @@ -31,11 +31,6 @@ static inline void huge_ptep_clear_flush(struct vm_area_struct *vma,
>  {
>  }
>  
> -static inline pte_t huge_pte_wrprotect(pte_t pte)
> -{
> -	return pte_wrprotect(pte);
> -}
> -
>  static inline void huge_ptep_set_wrprotect(struct mm_struct *mm,
>  					   unsigned long addr, pte_t *ptep)
>  {
> diff --git a/arch/sparc/include/asm/hugetlb.h b/arch/sparc/include/asm/hugetlb.h
> index 11115bbd712e..f661362376e0 100644
> --- a/arch/sparc/include/asm/hugetlb.h
> +++ b/arch/sparc/include/asm/hugetlb.h
> @@ -48,11 +48,6 @@ static inline void huge_ptep_clear_flush(struct vm_area_struct *vma,
>  {
>  }
>  
> -static inline pte_t huge_pte_wrprotect(pte_t pte)
> -{
> -	return pte_wrprotect(pte);
> -}
> -
>  static inline void huge_ptep_set_wrprotect(struct mm_struct *mm,
>  					   unsigned long addr, pte_t *ptep)
>  {
> diff --git a/arch/x86/include/asm/hugetlb.h b/arch/x86/include/asm/hugetlb.h
> index c5fdc53b6e41..19668672ab37 100644
> --- a/arch/x86/include/asm/hugetlb.h
> +++ b/arch/x86/include/asm/hugetlb.h
> @@ -27,11 +27,6 @@ static inline int prepare_hugepage_range(struct file *file,
>  	return 0;
>  }
>  
> -static inline pte_t huge_pte_wrprotect(pte_t pte)
> -{
> -	return pte_wrprotect(pte);
> -}
> -
>  static inline void huge_ptep_set_wrprotect(struct mm_struct *mm,
>  					   unsigned long addr, pte_t *ptep)
>  {
> diff --git a/include/asm-generic/hugetlb.h b/include/asm-generic/hugetlb.h
> index 2fc3d68424e9..cd9697672b79 100644
> --- a/include/asm-generic/hugetlb.h
> +++ b/include/asm-generic/hugetlb.h
> @@ -80,4 +80,11 @@ static inline int huge_pte_none(pte_t pte)
>  }
>  #endif
>  
> +#ifndef __HAVE_ARCH_HUGE_PTE_WRPROTECT
> +static inline pte_t huge_pte_wrprotect(pte_t pte)
> +{
> +	return pte_wrprotect(pte);
> +}
> +#endif
> +
>  #endif /* _ASM_GENERIC_HUGETLB_H */
> 
