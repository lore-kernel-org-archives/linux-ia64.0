From: Andrew Morton <akpm@linux-foundation.org>
Date: Sun, 26 Apr 2020 00:55:11 +0000
Subject: Re: [PATCH 3/3] mm/hugetlb: Introduce HAVE_ARCH_CLEAR_HUGEPAGE_FLAGS
Message-Id: <20200425175511.7a68efb5e2f4436fe0328c1d@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1586864670-21799-1-git-send-email-anshuman.khandual@arm.com>
        <1586864670-21799-4-git-send-email-anshuman.khandual@arm.com>
In-Reply-To: <1586864670-21799-4-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-mm@kvack.org, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Vasily Gorbik <gor@linux.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, David

On Tue, 14 Apr 2020 17:14:30 +0530 Anshuman Khandual <anshuman.khandual@arm.com> wrote:

> There are multiple similar definitions for arch_clear_hugepage_flags() on
> various platforms. This introduces HAVE_ARCH_CLEAR_HUGEPAGE_FLAGS for those
> platforms that need to define their own arch_clear_hugepage_flags() while
> also providing a generic fallback definition for others to use. This help
> reduce code duplication.
> 
> ...
>
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -544,6 +544,10 @@ static inline int is_hugepage_only_range(struct mm_struct *mm,
>  }
>  #endif
>  
> +#ifndef HAVE_ARCH_CLEAR_HUGEPAGE_FLAGS
> +static inline void arch_clear_hugepage_flags(struct page *page) { }
> +#endif
> +
>  #ifndef arch_make_huge_pte
>  static inline pte_t arch_make_huge_pte(pte_t entry, struct vm_area_struct *vma,
>  				       struct page *page, int writable)

This is the rather old-school way of doing it.  The Linus-suggested way is

#ifndef arch_clear_hugepage_flags
static inline void arch_clear_hugepage_flags(struct page *page)
{
}
#define arch_clear_hugepage_flags arch_clear_hugepage_flags
#endif

And the various arch headers do

static inline void arch_clear_hugepage_flags(struct page *page)
{
	<some implementation>
}
#define arch_clear_hugepage_flags arch_clear_hugepage_flags

It's a small difference - mainly to avoid adding two variables to the
overall namespace where one would do.
