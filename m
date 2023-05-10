From: Palmer Dabbelt <palmer@dabbelt.com>
Date: Wed, 10 May 2023 14:01:54 +0000
Subject: Re: [PATCH 14/23] riscv/hugetlb: pte_alloc_huge() pte_offset_huge()
Message-Id: <mhng-fa58638c-1b42-4264-8bf1-55d4bc42a5e2@palmer-ri-x1c9>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <d1e54510-9ea2-edf-3851-fa7635ce1e5e@google.com>
References: <d1e54510-9ea2-edf-3851-fa7635ce1e5e@google.com>
In-Reply-To: <d1e54510-9ea2-edf-3851-fa7635ce1e5e@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: hughd@google.com
Cc: akpm@linux-foundation.org, mike.kravetz@oracle.com, rppt@kernel.org, kirill.shutemov@linux.intel.com, willy@infradead.org, david@redhat.com, surenb@google.com, zhengqi.arch@bytedance.com, linux@armlinux.org.uk, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, geert@linux-m68k.org, gerg@linux-m68k.org, monstr@monstr.eu, tsbogend@alpha.franken.de, deller@gmx.de, dave.anglin@bell.net, aneesh.kumar@linux.ibm.com, mpe@ellerman.id.au, alexghiti@rivosinc.com, hca@linux.ibm.com, borntraeger@linux.ibm.com, imbrenda@linux.ibm.com, glaubitz@physik.fu-berlin.de, davem@davemloft.net, chris@zankel.net, jcmvbkbc@gmail.com, x86@kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 09 May 2023 21:59:57 PDT (-0700), hughd@google.com wrote:
> pte_alloc_map() expects to be followed by pte_unmap(), but hugetlb omits
> that: to keep balance in future, use the recently added pte_alloc_huge()
> instead; with pte_offset_huge() a better name for pte_offset_kernel().
>
> Signed-off-by: Hugh Dickins <hughd@google.com>
> ---
>  arch/riscv/mm/hugetlbpage.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/arch/riscv/mm/hugetlbpage.c b/arch/riscv/mm/hugetlbpage.c
> index a163a3e0f0d4..80926946759f 100644
> --- a/arch/riscv/mm/hugetlbpage.c
> +++ b/arch/riscv/mm/hugetlbpage.c
> @@ -43,7 +43,7 @@ pte_t *huge_pte_alloc(struct mm_struct *mm,
>
>  	for_each_napot_order(order) {
>  		if (napot_cont_size(order) = sz) {
> -			pte = pte_alloc_map(mm, pmd, addr & napot_cont_mask(order));
> +			pte = pte_alloc_huge(mm, pmd, addr & napot_cont_mask(order));
>  			break;
>  		}
>  	}
> @@ -90,7 +90,7 @@ pte_t *huge_pte_offset(struct mm_struct *mm,
>
>  	for_each_napot_order(order) {
>  		if (napot_cont_size(order) = sz) {
> -			pte = pte_offset_kernel(pmd, addr & napot_cont_mask(order));
> +			pte = pte_offset_huge(pmd, addr & napot_cont_mask(order));
>  			break;
>  		}
>  	}

Acked-by: Palmer Dabbelt <palmer@rivosinc.com>
