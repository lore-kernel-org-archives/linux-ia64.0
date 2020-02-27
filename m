From: Mike Rapoport <rppt@kernel.org>
Date: Thu, 27 Feb 2020 08:46:08 +0000
Subject: [PATCH v3 14/14] mm: remove __ARCH_HAS_5LEVEL_HACK and include/asm-generic/5level-fixup.h
Message-Id: <20200227084608.18223-15-rppt@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200227084608.18223-1-rppt@kernel.org>
In-Reply-To: <20200227084608.18223-1-rppt@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Rich Felker <dalias@libc.org>, linux-ia64@vger.kernel.org, Geert Uytterhoeven <geert+renesas@glider.be>, linux-sh@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-mm@kvack.org, Paul Mackerras <paulus@samba.org>, linux-hexagon@vger.kernel.org, Will Deacon <will@kernel.org>, kvmarm@lists.cs.columbia.edu, Jonas Bonn <jonas@southpole.se>, linux-arch@vger.kernel.org, Brian Cain <bcain@codeaurora.org>, Marc Zyngier <maz@kernel.org>, Russell King <linux@armlinux.org.uk>, Ley Foon Tan <ley.foon.tan@intel.com>, Mike Rapoport <rppt@linux.ibm.com>, Catalin Marinas <catalin.marinas@arm.com>, uclinux-h8-devel@lists.sourceforge.jp, Fenghua Yu <fenghua.yu@intel.com>, Arnd Bergmann <arnd@arndb.de>, kvm-ppc@vger.kernel.org, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, openrisc@lists.librecores.org, Stafford Horne <shorne@gmail.com>, Guan Xuetao <gxt@pku.edu.cn>, linux-arm-kernel@lists.infradead.org, Christophe Leroy <christophe.leroy@c-s.fr>, Tony Luck <tony.luck@intel.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Michael Ellerman <mpe@ellerman.id.au>, nios2-dev@lists.rocketboards.org, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, Mike Rapoport <rppt@kernel.org>

From: Mike Rapoport <rppt@linux.ibm.com>

There are no architectures that use include/asm-generic/5level-fixup.h
therefore it can be removed along with __ARCH_HAS_5LEVEL_HACK define and
the code it surrounds

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 include/asm-generic/5level-fixup.h | 58 ------------------------------
 include/linux/mm.h                 |  6 ----
 mm/kasan/init.c                    | 11 ------
 mm/memory.c                        |  8 -----
 4 files changed, 83 deletions(-)
 delete mode 100644 include/asm-generic/5level-fixup.h

diff --git a/include/asm-generic/5level-fixup.h b/include/asm-generic/5level-fixup.h
deleted file mode 100644
index 4c74b1c1d13b..000000000000
--- a/include/asm-generic/5level-fixup.h
+++ /dev/null
@@ -1,58 +0,0 @@
-/* SPDX-License-Identifier: GPL-2.0 */
-#ifndef _5LEVEL_FIXUP_H
-#define _5LEVEL_FIXUP_H
-
-#define __ARCH_HAS_5LEVEL_HACK
-#define __PAGETABLE_P4D_FOLDED 1
-
-#define P4D_SHIFT			PGDIR_SHIFT
-#define P4D_SIZE			PGDIR_SIZE
-#define P4D_MASK			PGDIR_MASK
-#define MAX_PTRS_PER_P4D		1
-#define PTRS_PER_P4D			1
-
-#define p4d_t				pgd_t
-
-#define pud_alloc(mm, p4d, address) \
-	((unlikely(pgd_none(*(p4d))) && __pud_alloc(mm, p4d, address)) ? \
-		NULL : pud_offset(p4d, address))
-
-#define p4d_alloc(mm, pgd, address)	(pgd)
-#define p4d_offset(pgd, start)		(pgd)
-
-#ifndef __ASSEMBLY__
-static inline int p4d_none(p4d_t p4d)
-{
-	return 0;
-}
-
-static inline int p4d_bad(p4d_t p4d)
-{
-	return 0;
-}
-
-static inline int p4d_present(p4d_t p4d)
-{
-	return 1;
-}
-#endif
-
-#define p4d_ERROR(p4d)			do { } while (0)
-#define p4d_clear(p4d)			pgd_clear(p4d)
-#define p4d_val(p4d)			pgd_val(p4d)
-#define p4d_populate(mm, p4d, pud)	pgd_populate(mm, p4d, pud)
-#define p4d_populate_safe(mm, p4d, pud)	pgd_populate(mm, p4d, pud)
-#define p4d_page(p4d)			pgd_page(p4d)
-#define p4d_page_vaddr(p4d)		pgd_page_vaddr(p4d)
-
-#define __p4d(x)			__pgd(x)
-#define set_p4d(p4dp, p4d)		set_pgd(p4dp, p4d)
-
-#undef p4d_free_tlb
-#define p4d_free_tlb(tlb, x, addr)	do { } while (0)
-#define p4d_free(mm, x)			do { } while (0)
-
-#undef  p4d_addr_end
-#define p4d_addr_end(addr, end)		(end)
-
-#endif
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 52269e56c514..69fb46e1d91b 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1841,11 +1841,6 @@ int __pte_alloc_kernel(pmd_t *pmd);
 
 #if defined(CONFIG_MMU)
 
-/*
- * The following ifdef needed to get the 5level-fixup.h header to work.
- * Remove it when 5level-fixup.h has been removed.
- */
-#ifndef __ARCH_HAS_5LEVEL_HACK
 static inline p4d_t *p4d_alloc(struct mm_struct *mm, pgd_t *pgd,
 		unsigned long address)
 {
@@ -1859,7 +1854,6 @@ static inline pud_t *pud_alloc(struct mm_struct *mm, p4d_t *p4d,
 	return (unlikely(p4d_none(*p4d)) && __pud_alloc(mm, p4d, address)) ?
 		NULL : pud_offset(p4d, address);
 }
-#endif /* !__ARCH_HAS_5LEVEL_HACK */
 
 static inline pmd_t *pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address)
 {
diff --git a/mm/kasan/init.c b/mm/kasan/init.c
index ce45c491ebcd..fe6be0be1f76 100644
--- a/mm/kasan/init.c
+++ b/mm/kasan/init.c
@@ -250,20 +250,9 @@ int __ref kasan_populate_early_shadow(const void *shadow_start,
 			 * 3,2 - level page tables where we don't have
 			 * puds,pmds, so pgd_populate(), pud_populate()
 			 * is noops.
-			 *
-			 * The ifndef is required to avoid build breakage.
-			 *
-			 * With 5level-fixup.h, pgd_populate() is not nop and
-			 * we reference kasan_early_shadow_p4d. It's not defined
-			 * unless 5-level paging enabled.
-			 *
-			 * The ifndef can be dropped once all KASAN-enabled
-			 * architectures will switch to pgtable-nop4d.h.
 			 */
-#ifndef __ARCH_HAS_5LEVEL_HACK
 			pgd_populate(&init_mm, pgd,
 					lm_alias(kasan_early_shadow_p4d));
-#endif
 			p4d = p4d_offset(pgd, addr);
 			p4d_populate(&init_mm, p4d,
 					lm_alias(kasan_early_shadow_pud));
diff --git a/mm/memory.c b/mm/memory.c
index 0bccc622e482..10cc147db1b8 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -4252,19 +4252,11 @@ int __pud_alloc(struct mm_struct *mm, p4d_t *p4d, unsigned long address)
 	smp_wmb(); /* See comment in __pte_alloc */
 
 	spin_lock(&mm->page_table_lock);
-#ifndef __ARCH_HAS_5LEVEL_HACK
 	if (!p4d_present(*p4d)) {
 		mm_inc_nr_puds(mm);
 		p4d_populate(mm, p4d, new);
 	} else	/* Another has populated it */
 		pud_free(mm, new);
-#else
-	if (!pgd_present(*p4d)) {
-		mm_inc_nr_puds(mm);
-		pgd_populate(mm, p4d, new);
-	} else	/* Another has populated it */
-		pud_free(mm, new);
-#endif /* __ARCH_HAS_5LEVEL_HACK */
 	spin_unlock(&mm->page_table_lock);
 	return 0;
 }
-- 
2.24.0
