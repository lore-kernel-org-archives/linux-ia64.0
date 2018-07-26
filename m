From: Mike Kravetz <mike.kravetz@oracle.com>
Date: Thu, 26 Jul 2018 19:02:19 +0000
Subject: Re: [PATCH v4 04/11] hugetlb: Introduce generic version of huge_ptep_get_and_clear
Message-Id: <507b484c-924a-0982-ed58-48ac9882fcc5@oracle.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180705110716.3919-1-alex@ghiti.fr>
 <20180705110716.3919-5-alex@ghiti.fr>
In-Reply-To: <20180705110716.3919-5-alex@ghiti.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alexandre Ghiti <alex@ghiti.fr>, linux@armlinux.org.uk, catalin.marinas@arm.com, will.deacon@arm.com, tony.luck@intel.com, fenghua.yu@intel.com, ralf@linux-mips.org, paul.burton@mips.com, jhogan@kernel.org, jejb@parisc-linux.org, deller@gmx.de, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, ysato@users.sourceforge.jp, dalias@libc.org, davem@davemloft.net, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, arnd@arndb.de, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org

On 07/05/2018 04:07 AM, Alexandre Ghiti wrote:
> arm, ia64, sh, x86 architectures use the
> same version of huge_ptep_get_and_clear, so move this generic
> implementation into asm-generic/hugetlb.h.
> 

Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>
-- 
Mike Kravetz

> Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
> ---
>  arch/arm/include/asm/hugetlb-3level.h | 6 ------
>  arch/arm64/include/asm/hugetlb.h      | 1 +
>  arch/ia64/include/asm/hugetlb.h       | 6 ------
>  arch/mips/include/asm/hugetlb.h       | 1 +
>  arch/parisc/include/asm/hugetlb.h     | 1 +
>  arch/powerpc/include/asm/hugetlb.h    | 1 +
>  arch/sh/include/asm/hugetlb.h         | 6 ------
>  arch/sparc/include/asm/hugetlb.h      | 1 +
>  arch/x86/include/asm/hugetlb.h        | 6 ------
>  include/asm-generic/hugetlb.h         | 8 ++++++++
>  10 files changed, 13 insertions(+), 24 deletions(-)
> 
> diff --git a/arch/arm/include/asm/hugetlb-3level.h b/arch/arm/include/asm/hugetlb-3level.h
> index 398fb06e8207..ad36e84b819a 100644
> --- a/arch/arm/include/asm/hugetlb-3level.h
> +++ b/arch/arm/include/asm/hugetlb-3level.h
> @@ -49,12 +49,6 @@ static inline void huge_ptep_set_wrprotect(struct mm_struct *mm,
>  	ptep_set_wrprotect(mm, addr, ptep);
>  }
>  
> -static inline pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
> -					    unsigned long addr, pte_t *ptep)
> -{
> -	return ptep_get_and_clear(mm, addr, ptep);
> -}
> -
>  static inline int huge_ptep_set_access_flags(struct vm_area_struct *vma,
>  					     unsigned long addr, pte_t *ptep,
>  					     pte_t pte, int dirty)
> diff --git a/arch/arm64/include/asm/hugetlb.h b/arch/arm64/include/asm/hugetlb.h
> index 874661a1dff1..6ae0bcafe162 100644
> --- a/arch/arm64/include/asm/hugetlb.h
> +++ b/arch/arm64/include/asm/hugetlb.h
> @@ -66,6 +66,7 @@ extern void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
>  extern int huge_ptep_set_access_flags(struct vm_area_struct *vma,
>  				      unsigned long addr, pte_t *ptep,
>  				      pte_t pte, int dirty);
> +#define __HAVE_ARCH_HUGE_PTEP_GET_AND_CLEAR
>  extern pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
>  				     unsigned long addr, pte_t *ptep);
>  extern void huge_ptep_set_wrprotect(struct mm_struct *mm,
> diff --git a/arch/ia64/include/asm/hugetlb.h b/arch/ia64/include/asm/hugetlb.h
> index a235d6f60fb3..6719c74da0de 100644
> --- a/arch/ia64/include/asm/hugetlb.h
> +++ b/arch/ia64/include/asm/hugetlb.h
> @@ -20,12 +20,6 @@ static inline int is_hugepage_only_range(struct mm_struct *mm,
>  		REGION_NUMBER((addr)+(len)-1) = RGN_HPAGE);
>  }
>  
> -static inline pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
> -					    unsigned long addr, pte_t *ptep)
> -{
> -	return ptep_get_and_clear(mm, addr, ptep);
> -}
> -
>  static inline void huge_ptep_clear_flush(struct vm_area_struct *vma,
>  					 unsigned long addr, pte_t *ptep)
>  {
> diff --git a/arch/mips/include/asm/hugetlb.h b/arch/mips/include/asm/hugetlb.h
> index 8ea439041d5d..0959cc5a41fa 100644
> --- a/arch/mips/include/asm/hugetlb.h
> +++ b/arch/mips/include/asm/hugetlb.h
> @@ -36,6 +36,7 @@ static inline int prepare_hugepage_range(struct file *file,
>  	return 0;
>  }
>  
> +#define __HAVE_ARCH_HUGE_PTEP_GET_AND_CLEAR
>  static inline pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
>  					    unsigned long addr, pte_t *ptep)
>  {
> diff --git a/arch/parisc/include/asm/hugetlb.h b/arch/parisc/include/asm/hugetlb.h
> index 77c8adbac7c3..6e281e1bb336 100644
> --- a/arch/parisc/include/asm/hugetlb.h
> +++ b/arch/parisc/include/asm/hugetlb.h
> @@ -8,6 +8,7 @@
>  void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
>  		     pte_t *ptep, pte_t pte);
>  
> +#define __HAVE_ARCH_HUGE_PTEP_GET_AND_CLEAR
>  pte_t huge_ptep_get_and_clear(struct mm_struct *mm, unsigned long addr,
>  			      pte_t *ptep);
>  
> diff --git a/arch/powerpc/include/asm/hugetlb.h b/arch/powerpc/include/asm/hugetlb.h
> index 0794b53439d4..970101cf9c82 100644
> --- a/arch/powerpc/include/asm/hugetlb.h
> +++ b/arch/powerpc/include/asm/hugetlb.h
> @@ -132,6 +132,7 @@ static inline int prepare_hugepage_range(struct file *file,
>  	return 0;
>  }
>  
> +#define __HAVE_ARCH_HUGE_PTEP_GET_AND_CLEAR
>  static inline pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
>  					    unsigned long addr, pte_t *ptep)
>  {
> diff --git a/arch/sh/include/asm/hugetlb.h b/arch/sh/include/asm/hugetlb.h
> index bc552e37c1c9..08ee6c00b5e9 100644
> --- a/arch/sh/include/asm/hugetlb.h
> +++ b/arch/sh/include/asm/hugetlb.h
> @@ -25,12 +25,6 @@ static inline int prepare_hugepage_range(struct file *file,
>  	return 0;
>  }
>  
> -static inline pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
> -					    unsigned long addr, pte_t *ptep)
> -{
> -	return ptep_get_and_clear(mm, addr, ptep);
> -}
> -
>  static inline void huge_ptep_clear_flush(struct vm_area_struct *vma,
>  					 unsigned long addr, pte_t *ptep)
>  {
> diff --git a/arch/sparc/include/asm/hugetlb.h b/arch/sparc/include/asm/hugetlb.h
> index 16b0c53ea6c9..944e3a4bfaff 100644
> --- a/arch/sparc/include/asm/hugetlb.h
> +++ b/arch/sparc/include/asm/hugetlb.h
> @@ -16,6 +16,7 @@ extern struct pud_huge_patch_entry __pud_huge_patch, __pud_huge_patch_end;
>  void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
>  		     pte_t *ptep, pte_t pte);
>  
> +#define __HAVE_ARCH_HUGE_PTEP_GET_AND_CLEAR
>  pte_t huge_ptep_get_and_clear(struct mm_struct *mm, unsigned long addr,
>  			      pte_t *ptep);
>  
> diff --git a/arch/x86/include/asm/hugetlb.h b/arch/x86/include/asm/hugetlb.h
> index 554d5614b375..48b8d9b13cc6 100644
> --- a/arch/x86/include/asm/hugetlb.h
> +++ b/arch/x86/include/asm/hugetlb.h
> @@ -27,12 +27,6 @@ static inline int prepare_hugepage_range(struct file *file,
>  	return 0;
>  }
>  
> -static inline pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
> -					    unsigned long addr, pte_t *ptep)
> -{
> -	return ptep_get_and_clear(mm, addr, ptep);
> -}
> -
>  static inline void huge_ptep_clear_flush(struct vm_area_struct *vma,
>  					 unsigned long addr, pte_t *ptep)
>  {
> diff --git a/include/asm-generic/hugetlb.h b/include/asm-generic/hugetlb.h
> index ee010b756246..0f6f151780dd 100644
> --- a/include/asm-generic/hugetlb.h
> +++ b/include/asm-generic/hugetlb.h
> @@ -57,4 +57,12 @@ static inline void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
>  }
>  #endif
>  
> +#ifndef __HAVE_ARCH_HUGE_PTEP_GET_AND_CLEAR
> +static inline pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
> +		unsigned long addr, pte_t *ptep)
> +{
> +	return ptep_get_and_clear(mm, addr, ptep);
> +}
> +#endif
> +
>  #endif /* _ASM_GENERIC_HUGETLB_H */
> 
