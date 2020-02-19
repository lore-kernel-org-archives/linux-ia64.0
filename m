From: Christophe Leroy <christophe.leroy@c-s.fr>
Date: Wed, 19 Feb 2020 12:07:55 +0000
Subject: Re: [PATCH v2 07/13] powerpc: add support for folded p4d page tables
Message-Id: <5b7c3929-5833-8ceb-85c8-a8e92e6a138e@c-s.fr>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200216081843.28670-1-rppt@kernel.org>
 <20200216081843.28670-8-rppt@kernel.org>
In-Reply-To: <20200216081843.28670-8-rppt@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Mike Rapoport <rppt@kernel.org>
Cc: Rich Felker <dalias@libc.org>, linux-ia64@vger.kernel.org, Geert Uytterhoeven <geert+renesas@glider.be>, linux-sh@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-mm@kvack.org, Paul Mackerras <paulus@samba.org>, linux-hexagon@vger.kernel.org, Will Deacon <will@kernel.org>, kvmarm@lists.cs.columbia.edu, Jonas Bonn <jonas@southpole.se>, linux-arch@vger.kernel.org, Brian Cain <bcain@codeaurora.org>, Marc Zyngier <maz@kernel.org>, Russell King <linux@armlinux.org.uk>, Ley Foon Tan <ley.foon.tan@intel.com>, Mike Rapoport <rppt@linux.ibm.com>, Catalin Marinas <catalin.marinas@arm.com>, uclinux-h8-devel@lists.sourceforge.jp, Fenghua Yu <fenghua.yu@intel.com>, Arnd Bergmann <arnd@arndb.de>, kvm-ppc@vger.kernel.org, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, openrisc@lists.librecores.org, Stafford Horne <shorne@gmail.com>, Guan Xuetao <gxt@pku.edu.cn>, linux-arm-kernel@lists.infradead.org, Tony Luck <tony.luck@intel.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-kernel@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, nios2-dev@lists.rocketboards.org, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org



Le 16/02/2020 à 09:18, Mike Rapoport a écrit :
> From: Mike Rapoport <rppt@linux.ibm.com>
> 
> Implement primitives necessary for the 4th level folding, add walks of p4d
> level where appropriate and replace 5level-fixup.h with pgtable-nop4d.h.
> 
> Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
> Tested-by: Christophe Leroy <christophe.leroy@c-s.fr> # 8xx and 83xx
> ---
>   arch/powerpc/include/asm/book3s/32/pgtable.h  |  1 -
>   arch/powerpc/include/asm/book3s/64/hash.h     |  4 +-
>   arch/powerpc/include/asm/book3s/64/pgalloc.h  |  4 +-
>   arch/powerpc/include/asm/book3s/64/pgtable.h  | 58 ++++++++++--------
>   arch/powerpc/include/asm/book3s/64/radix.h    |  6 +-
>   arch/powerpc/include/asm/nohash/32/pgtable.h  |  1 -
>   arch/powerpc/include/asm/nohash/64/pgalloc.h  |  2 +-
>   .../include/asm/nohash/64/pgtable-4k.h        | 32 +++++-----
>   arch/powerpc/include/asm/nohash/64/pgtable.h  |  6 +-
>   arch/powerpc/include/asm/pgtable.h            |  8 +++
>   arch/powerpc/kvm/book3s_64_mmu_radix.c        | 59 ++++++++++++++++---
>   arch/powerpc/lib/code-patching.c              |  7 ++-
>   arch/powerpc/mm/book3s32/mmu.c                |  2 +-
>   arch/powerpc/mm/book3s32/tlb.c                |  4 +-
>   arch/powerpc/mm/book3s64/hash_pgtable.c       |  4 +-
>   arch/powerpc/mm/book3s64/radix_pgtable.c      | 19 ++++--
>   arch/powerpc/mm/book3s64/subpage_prot.c       |  6 +-
>   arch/powerpc/mm/hugetlbpage.c                 | 28 +++++----
>   arch/powerpc/mm/kasan/kasan_init_32.c         |  8 +--
>   arch/powerpc/mm/mem.c                         |  4 +-
>   arch/powerpc/mm/nohash/40x.c                  |  4 +-
>   arch/powerpc/mm/nohash/book3e_pgtable.c       | 15 +++--
>   arch/powerpc/mm/pgtable.c                     | 25 +++++++-
>   arch/powerpc/mm/pgtable_32.c                  | 28 +++++----
>   arch/powerpc/mm/pgtable_64.c                  | 10 ++--
>   arch/powerpc/mm/ptdump/hashpagetable.c        | 20 ++++++-
>   arch/powerpc/mm/ptdump/ptdump.c               | 22 ++++++-
>   arch/powerpc/xmon/xmon.c                      | 17 +++++-
>   28 files changed, 284 insertions(+), 120 deletions(-)
> 
> diff --git a/arch/powerpc/mm/ptdump/ptdump.c b/arch/powerpc/mm/ptdump/ptdump.c
> index 206156255247..7bd4b81d5b5d 100644
> --- a/arch/powerpc/mm/ptdump/ptdump.c
> +++ b/arch/powerpc/mm/ptdump/ptdump.c
> @@ -277,9 +277,9 @@ static void walk_pmd(struct pg_state *st, pud_t *pud, unsigned long start)
>   	}
>   }
>   
> -static void walk_pud(struct pg_state *st, pgd_t *pgd, unsigned long start)
> +static void walk_pud(struct pg_state *st, p4d_t *p4d, unsigned long start)
>   {
> -	pud_t *pud = pud_offset(pgd, 0);
> +	pud_t *pud = pud_offset(p4d, 0);
>   	unsigned long addr;
>   	unsigned int i;
>   
> @@ -293,6 +293,22 @@ static void walk_pud(struct pg_state *st, pgd_t *pgd, unsigned long start)
>   	}
>   }
>   
> +static void walk_p4d(struct pg_state *st, pgd_t *pgd, unsigned long start)
> +{
> +	p4d_t *p4d = p4d_offset(pgd, 0);
> +	unsigned long addr;
> +	unsigned int i;
> +
> +	for (i = 0; i < PTRS_PER_P4D; i++, p4d++) {
> +		addr = start + i * P4D_SIZE;
> +		if (!p4d_none(*p4d) && !p4d_is_leaf(*p4d))
> +			/* p4d exists */
> +			walk_pud(st, p4d, addr);
> +		else
> +			note_page(st, addr, 2, p4d_val(*p4d));

Level 2 is already used by walk_pud().

I think you have to increment the level used in walk_pud() and 
walk_pmd() and walk_pte()

> +	}
> +}
> +
>   static void walk_pagetables(struct pg_state *st)
>   {
>   	unsigned int i;
> @@ -306,7 +322,7 @@ static void walk_pagetables(struct pg_state *st)
>   	for (i = pgd_index(addr); i < PTRS_PER_PGD; i++, pgd++, addr += PGDIR_SIZE) {
>   		if (!pgd_none(*pgd) && !pgd_is_leaf(*pgd))
>   			/* pgd exists */
> -			walk_pud(st, pgd, addr);
> +			walk_p4d(st, pgd, addr);
>   		else
>   			note_page(st, addr, 1, pgd_val(*pgd));
>   	}

Christophe
