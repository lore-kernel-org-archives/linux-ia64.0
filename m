From: Claudio Imbrenda <imbrenda@linux.ibm.com>
Date: Wed, 17 May 2023 10:35:46 +0000
Subject: Re: [PATCH 15/23] s390: allow pte_offset_map_lock() to fail
Message-Id: <20230517123546.672fb9b0@p-imbrenda>
List-Id: <linux-ia64.vger.kernel.org>
References: <77a5d8c-406b-7068-4f17-23b7ac53bc83@google.com>
        <94aec8fe-383f-892-dcbf-d4c14e460a7@google.com>
In-Reply-To: <94aec8fe-383f-892-dcbf-d4c14e460a7@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>, Mike Rapoport <rppt@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <willy@infradead.org>, David Hildenbrand <david@redhat.com>, Suren Baghdasaryan <surenb@google.com>, Qi Zheng <zhengqi.arch@bytedance.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Greg Ungerer <gerg@linux-m68k.org>, Michal Simek <monstr@monstr.eu>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Helge Deller <deller@gmx.de>, John David Anglin <dave.anglin@bell.net>, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, Alexandre Ghiti <alexghiti@rivosinc.com>, Palmer Dabbelt <palmer@dabbelt.com>, Heiko Carstens <hca@linux.ibm.com>, Christian Borntraeger <borntraeger@linux.ibm.com>, John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, "David S. Miller" <davem@davemloft.net>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, x86@kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 9 May 2023 22:01:16 -0700 (PDT)
Hugh Dickins <hughd@google.com> wrote:

> In rare transient cases, not yet made possible, pte_offset_map() and
> pte_offset_map_lock() may not find a page table: handle appropriately.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>
> ---
>  arch/s390/kernel/uv.c  |  2 ++
>  arch/s390/mm/gmap.c    |  2 ++
>  arch/s390/mm/pgtable.c | 12 +++++++++---
>  3 files changed, 13 insertions(+), 3 deletions(-)
> 
> diff --git a/arch/s390/kernel/uv.c b/arch/s390/kernel/uv.c
> index cb2ee06df286..3c62d1b218b1 100644
> --- a/arch/s390/kernel/uv.c
> +++ b/arch/s390/kernel/uv.c
> @@ -294,6 +294,8 @@ int gmap_make_secure(struct gmap *gmap, unsigned long gaddr, void *uvcb)
>  
>  	rc = -ENXIO;
>  	ptep = get_locked_pte(gmap->mm, uaddr, &ptelock);
> +	if (!ptep)
> +		goto out;
>  	if (pte_present(*ptep) && !(pte_val(*ptep) & _PAGE_INVALID) && pte_write(*ptep)) {
>  		page = pte_page(*ptep);
>  		rc = -EAGAIN;
> diff --git a/arch/s390/mm/gmap.c b/arch/s390/mm/gmap.c
> index dc90d1eb0d55..d198fc9475a2 100644
> --- a/arch/s390/mm/gmap.c
> +++ b/arch/s390/mm/gmap.c
> @@ -2549,6 +2549,8 @@ static int __zap_zero_pages(pmd_t *pmd, unsigned long start,
>  		spinlock_t *ptl;
>  
>  		ptep = pte_offset_map_lock(walk->mm, pmd, addr, &ptl);
> +		if (!ptep)
> +			break;

so if pte_offset_map_lock fails, we abort and skip both the failed
entry and the rest of the entries?

can pte_offset_map_lock be retried immediately if it fails? (consider
that we currently don't allow THP with KVM guests)

Would something like this:

do {
	ptep = pte_offset_map_lock(...);
	mb();	/* maybe? */
} while (!ptep);

make sense?


otherwise maybe it's better to return an error and retry the whole
walk_page_range() in s390_enable_sie() ? it's a slow path anyway.

>  		if (is_zero_pfn(pte_pfn(*ptep)))
>  			ptep_xchg_direct(walk->mm, addr, ptep, __pte(_PAGE_INVALID));
>  		pte_unmap_unlock(ptep, ptl);

[...]
