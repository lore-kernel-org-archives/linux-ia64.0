From: Peter Zijlstra <peterz@infradead.org>
Date: Wed, 10 May 2023 08:18:48 +0000
Subject: Re: [PATCH 21/23] x86: Allow get_locked_pte() to fail
Message-Id: <20230510081848.GD83892@hirez.programming.kicks-ass.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <77a5d8c-406b-7068-4f17-23b7ac53bc83@google.com>
 <eba2b72f-2180-498b-c8bd-ce8f717fc78a@google.com>
In-Reply-To: <eba2b72f-2180-498b-c8bd-ce8f717fc78a@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>, Mike Rapoport <rppt@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <willy@infradead.org>, David Hildenbrand <david@redhat.com>, Suren Baghdasaryan <surenb@google.com>, Qi Zheng <zhengqi.arch@bytedance.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Greg Ungerer <gerg@linux-m68k.org>, Michal Simek <monstr@monstr.eu>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Helge Deller <deller@gmx.de>, John David Anglin <dave.anglin@bell.net>, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, Alexandre Ghiti <alexghiti@rivosinc.com>, Palmer Dabbelt <palmer@dabbelt.com>, Heiko Carstens <hca@linux.ibm.com>, Christian Borntraeger <borntraeger@linux.ibm.com>, Claudio Imbrenda <imbrenda@linux.ibm.com>, John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, "David S. Miller" <davem@davemloft.net>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, x86@kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, May 09, 2023 at 10:08:37PM -0700, Hugh Dickins wrote:
> In rare transient cases, not yet made possible, pte_offset_map() and
> pte_offset_map_lock() may not find a page table: handle appropriately.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>
> ---
>  arch/x86/kernel/ldt.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/x86/kernel/ldt.c b/arch/x86/kernel/ldt.c
> index 525876e7b9f4..eb844549cd83 100644
> --- a/arch/x86/kernel/ldt.c
> +++ b/arch/x86/kernel/ldt.c
> @@ -367,8 +367,10 @@ static void unmap_ldt_struct(struct mm_struct *mm, struct ldt_struct *ldt)
>  
>  		va = (unsigned long)ldt_slot_va(ldt->slot) + offset;
>  		ptep = get_locked_pte(mm, va, &ptl);
> -		pte_clear(mm, va, ptep);
> -		pte_unmap_unlock(ptep, ptl);
> +		if (ptep) {
> +			pte_clear(mm, va, ptep);
> +			pte_unmap_unlock(ptep, ptl);
> +		}
>  	}

Ow geez, now I have to go remember how the whole PTI/LDT crud worked :/

At first glance this seems wrong; we can't just not unmap the LDT if we
can't find it in a hurry. Also, IIRC this isn't in fact a regular user
mapping, so it should not be subject to THP induced seizures.

... memory bubbles back ... for PTI kernels we need to map this in the
user and kernel page-tables because obviously userspace needs to be able
to have access to the LDT. But it is not directly acessible by
userspace. It lives in the cpu_entry_area as a virtual map of the real
kernel allocation, and this virtual address is used for LLDT.
Modification is done through sys_modify_ldt().

I think I would feel much better if this were something like:

	if (!WARN_ON_ONCE(!ptep))

This really shouldn't fail and if it does, simply skipping it isn't the
right thing either.
