From: Mike Kravetz <mike.kravetz@oracle.com>
Date: Fri, 08 May 2020 22:22:34 +0000
Subject: Re: [PATCH V3 2/3] mm/hugetlb: Define a generic fallback for is_hugepage_only_range()
Message-Id: <9fc622e1-45ff-b79f-ebe0-35614837456c@oracle.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1588907271-11920-1-git-send-email-anshuman.khandual@arm.com>
 <1588907271-11920-3-git-send-email-anshuman.khandual@arm.com>
In-Reply-To: <1588907271-11920-3-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Anshuman Khandual <anshuman.khandual@arm.com>, linux-mm@kvack.org, akpm@linux-foundation.org
Cc: Rich Felker <dalias@libc.org>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-kernel@vger.kernel.org, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Paul Mackerras <paulus@samba.org>, "H. Peter Anvin" <hpa@zytor.com>, sparclinux@vger.kernel.org, linux-riscv@lists.infradead.org, Will Deacon <will@kernel.org>, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, Yoshinori Sato <ysato@users.sourceforge.jp>, Michael Ellerman <mpe@ellerman.id.au>, Helge Deller <deller@gmx.de>, x86@kernel.org, Russell King <linux@armlinux.org.uk>, Christian Borntraeger <borntraeger@de.ibm.com>, Ingo Molnar <mingo@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Fenghua Yu <fenghua.yu@intel.com>, Vasily Gorbik <gor@linux.ibm.com>, Thomas Bogendoerfer <tsbogend@a>

On 5/7/20 8:07 PM, Anshuman Khandual wrote:
> There are multiple similar definitions for is_hugepage_only_range() on
> various platforms. Lets just add it's generic fallback definition for
> platforms that do not override. This help reduce code duplication.
> 
> Cc: Russell King <linux@armlinux.org.uk>
> Cc: Catalin Marinas <catalin.marinas@arm.com>
> Cc: Will Deacon <will@kernel.org>
> Cc: Tony Luck <tony.luck@intel.com>
> Cc: Fenghua Yu <fenghua.yu@intel.com>
> Cc: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
> Cc: "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>
> Cc: Helge Deller <deller@gmx.de>
> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Cc: Paul Mackerras <paulus@samba.org>
> Cc: Michael Ellerman <mpe@ellerman.id.au>
> Cc: Paul Walmsley <paul.walmsley@sifive.com>
> Cc: Palmer Dabbelt <palmer@dabbelt.com>
> Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
> Cc: Vasily Gorbik <gor@linux.ibm.com>
> Cc: Christian Borntraeger <borntraeger@de.ibm.com>
> Cc: Yoshinori Sato <ysato@users.sourceforge.jp>
> Cc: Rich Felker <dalias@libc.org>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: Borislav Petkov <bp@alien8.de>
> Cc: "H. Peter Anvin" <hpa@zytor.com>
> Cc: Mike Kravetz <mike.kravetz@oracle.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: x86@kernel.org
> Cc: linux-arm-kernel@lists.infradead.org
> Cc: linux-ia64@vger.kernel.org
> Cc: linux-mips@vger.kernel.org
> Cc: linux-parisc@vger.kernel.org
> Cc: linuxppc-dev@lists.ozlabs.org
> Cc: linux-riscv@lists.infradead.org
> Cc: linux-s390@vger.kernel.org
> Cc: linux-sh@vger.kernel.org
> Cc: sparclinux@vger.kernel.org
> Cc: linux-mm@kvack.org
> Cc: linux-arch@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
> ---
>  arch/arm/include/asm/hugetlb.h     | 6 ------
>  arch/arm64/include/asm/hugetlb.h   | 6 ------
>  arch/ia64/include/asm/hugetlb.h    | 1 +
>  arch/mips/include/asm/hugetlb.h    | 7 -------
>  arch/parisc/include/asm/hugetlb.h  | 6 ------
>  arch/powerpc/include/asm/hugetlb.h | 1 +
>  arch/riscv/include/asm/hugetlb.h   | 6 ------
>  arch/s390/include/asm/hugetlb.h    | 7 -------
>  arch/sh/include/asm/hugetlb.h      | 6 ------
>  arch/sparc/include/asm/hugetlb.h   | 6 ------
>  arch/x86/include/asm/hugetlb.h     | 6 ------
>  include/linux/hugetlb.h            | 9 +++++++++
>  12 files changed, 11 insertions(+), 56 deletions(-)
> 
<snip>
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index 43a1cef8f0f1..c01c0c6f7fd4 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -591,6 +591,15 @@ static inline unsigned int blocks_per_huge_page(struct hstate *h)
>  
>  #include <asm/hugetlb.h>
>  
> +#ifndef is_hugepage_only_range
> +static inline int is_hugepage_only_range(struct mm_struct *mm,
> +					unsigned long addr, unsigned long len)
> +{
> +	return 0;
> +}
> +#define is_hugepage_only_range is_hugepage_only_range
> +#endif
> +
>  #ifndef arch_make_huge_pte
>  static inline pte_t arch_make_huge_pte(pte_t entry, struct vm_area_struct *vma,
>  				       struct page *page, int writable)
> 

Did you try building without CONFIG_HUGETLB_PAGE defined?  I'm guessing
that you need a stub for is_hugepage_only_range().  Or, perhaps add this
to asm-generic/hugetlb.h?

-- 
Mike Kravetz
