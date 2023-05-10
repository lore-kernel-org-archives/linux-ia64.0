From: Hugh Dickins <hughd@google.com>
Date: Wed, 10 May 2023 04:48:15 +0000
Subject: [PATCH 05/23] m68k: allow pte_offset_map[_lock]() to fail
Message-Id: <237c8410-ce61-94c-4260-7318ad6a4f3@google.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <77a5d8c-406b-7068-4f17-23b7ac53bc83@google.com>
In-Reply-To: <77a5d8c-406b-7068-4f17-23b7ac53bc83@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, Mike Rapoport <rppt@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <willy@infradead.org>, David Hildenbrand <david@redhat.com>, Suren Baghdasaryan <surenb@google.com>, Qi Zheng <zhengqi.arch@bytedance.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Greg Ungerer <gerg@linux-m68k.org>, Michal Simek <monstr@monstr.eu>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Helge Deller <deller@gmx.de>, John David Anglin <dave.anglin@bell.net>, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, Alexandre Ghiti <alexghiti@rivosinc.com>, Palmer Dabbelt <palmer@dabbelt.com>, Heiko Carstens <hca@linux.ibm.com>, Christian Borntraeger <borntraeger@linux.ibm.com>, Claudio Imbrenda <imbrenda@linux.ibm.com>, John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, "David S. Miller" <davem@davemloft.net>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, x86@kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

In rare transient cases, not yet made possible, pte_offset_map() and
pte_offset_map_lock() may not find a page table: handle appropriately.

Restructure cf_tlb_miss() with a pte_unmap() (previously omitted)
at label out, followed by one local_irq_restore() for all.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 arch/m68k/include/asm/mmu_context.h |  6 ++--
 arch/m68k/kernel/sys_m68k.c         |  2 ++
 arch/m68k/mm/mcfmmu.c               | 52 ++++++++++++-----------------
 3 files changed, 27 insertions(+), 33 deletions(-)

diff --git a/arch/m68k/include/asm/mmu_context.h b/arch/m68k/include/asm/mmu_context.h
index 8ed6ac14d99f..141bbdfad960 100644
--- a/arch/m68k/include/asm/mmu_context.h
+++ b/arch/m68k/include/asm/mmu_context.h
@@ -99,7 +99,7 @@ static inline void load_ksp_mmu(struct task_struct *task)
 	p4d_t *p4d;
 	pud_t *pud;
 	pmd_t *pmd;
-	pte_t *pte;
+	pte_t *pte = NULL;
 	unsigned long mmuar;
 
 	local_irq_save(flags);
@@ -139,7 +139,7 @@ static inline void load_ksp_mmu(struct task_struct *task)
 
 	pte = (mmuar >= PAGE_OFFSET) ? pte_offset_kernel(pmd, mmuar)
 				     : pte_offset_map(pmd, mmuar);
-	if (pte_none(*pte) || !pte_present(*pte))
+	if (!pte || pte_none(*pte) || !pte_present(*pte))
 		goto bug;
 
 	set_pte(pte, pte_mkyoung(*pte));
@@ -161,6 +161,8 @@ static inline void load_ksp_mmu(struct task_struct *task)
 bug:
 	pr_info("ksp load failed: mm=0x%p ksp=0x08%lx\n", mm, mmuar);
 end:
+	if (pte && mmuar < PAGE_OFFSET)
+		pte_unmap(pte);
 	local_irq_restore(flags);
 }
 
diff --git a/arch/m68k/kernel/sys_m68k.c b/arch/m68k/kernel/sys_m68k.c
index bd0274c7592e..c586034d2a7a 100644
--- a/arch/m68k/kernel/sys_m68k.c
+++ b/arch/m68k/kernel/sys_m68k.c
@@ -488,6 +488,8 @@ sys_atomic_cmpxchg_32(unsigned long newval, int oldval, int d3, int d4, int d5,
 		if (!pmd_present(*pmd))
 			goto bad_access;
 		pte = pte_offset_map_lock(mm, pmd, (unsigned long)mem, &ptl);
+		if (!pte)
+			goto bad_access;
 		if (!pte_present(*pte) || !pte_dirty(*pte)
 		    || !pte_write(*pte)) {
 			pte_unmap_unlock(pte, ptl);
diff --git a/arch/m68k/mm/mcfmmu.c b/arch/m68k/mm/mcfmmu.c
index 70aa0979e027..42f45abea37a 100644
--- a/arch/m68k/mm/mcfmmu.c
+++ b/arch/m68k/mm/mcfmmu.c
@@ -91,7 +91,8 @@ int cf_tlb_miss(struct pt_regs *regs, int write, int dtlb, int extension_word)
 	p4d_t *p4d;
 	pud_t *pud;
 	pmd_t *pmd;
-	pte_t *pte;
+	pte_t *pte = NULL;
+	int ret = -1;
 	int asid;
 
 	local_irq_save(flags);
@@ -100,47 +101,33 @@ int cf_tlb_miss(struct pt_regs *regs, int write, int dtlb, int extension_word)
 		regs->pc + (extension_word * sizeof(long));
 
 	mm = (!user_mode(regs) && KMAPAREA(mmuar)) ? &init_mm : current->mm;
-	if (!mm) {
-		local_irq_restore(flags);
-		return -1;
-	}
+	if (!mm)
+		goto out;
 
 	pgd = pgd_offset(mm, mmuar);
-	if (pgd_none(*pgd))  {
-		local_irq_restore(flags);
-		return -1;
-	}
+	if (pgd_none(*pgd))
+		goto out;
 
 	p4d = p4d_offset(pgd, mmuar);
-	if (p4d_none(*p4d)) {
-		local_irq_restore(flags);
-		return -1;
-	}
+	if (p4d_none(*p4d))
+		goto out;
 
 	pud = pud_offset(p4d, mmuar);
-	if (pud_none(*pud)) {
-		local_irq_restore(flags);
-		return -1;
-	}
+	if (pud_none(*pud))
+		goto out;
 
 	pmd = pmd_offset(pud, mmuar);
-	if (pmd_none(*pmd)) {
-		local_irq_restore(flags);
-		return -1;
-	}
+	if (pmd_none(*pmd))
+		goto out;
 
 	pte = (KMAPAREA(mmuar)) ? pte_offset_kernel(pmd, mmuar)
 				: pte_offset_map(pmd, mmuar);
-	if (pte_none(*pte) || !pte_present(*pte)) {
-		local_irq_restore(flags);
-		return -1;
-	}
+	if (!pte || pte_none(*pte) || !pte_present(*pte))
+		goto out;
 
 	if (write) {
-		if (!pte_write(*pte)) {
-			local_irq_restore(flags);
-			return -1;
-		}
+		if (!pte_write(*pte))
+			goto out;
 		set_pte(pte, pte_mkdirty(*pte));
 	}
 
@@ -161,9 +148,12 @@ int cf_tlb_miss(struct pt_regs *regs, int write, int dtlb, int extension_word)
 		mmu_write(MMUOR, MMUOR_ACC | MMUOR_UAA);
 	else
 		mmu_write(MMUOR, MMUOR_ITLB | MMUOR_ACC | MMUOR_UAA);
-
+	ret = 0;
+out:
+	if (pte && !KMAPAREA(mmuar))
+		pte_unmap(pte);
 	local_irq_restore(flags);
-	return 0;
+	return ret;
 }
 
 void __init cf_bootmem_alloc(void)
-- 
2.35.3
