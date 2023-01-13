From: David Hildenbrand <david@redhat.com>
Date: Fri, 13 Jan 2023 17:10:03 +0000
Subject: [PATCH mm-unstable v1 03/26] arc/mm: support __HAVE_ARCH_PTE_SWP_EXCLUSIVE
Message-Id: <20230113171026.582290-4-david@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230113171026.582290-1-david@redhat.com>
In-Reply-To: <20230113171026.582290-1-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, John Hubbard <jhubbard@nvidia.com>, Jason Gunthorpe <jgg@nvidia.com>, Mike Rapoport <rppt@linux.ibm.com>, Yang Shi <shy828301@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Nadav Amit <namit@vmware.com>, Andrea Arcangeli <aarcange@redhat.com>, Peter Xu <peterx@redhat.com>, linux-mm@kvack.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-csky@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-um@lists.infradead.org, linux-xtensa@linux-xtensa.org, David Hildenbrand <david@redhat.com>, Vineet Gupta <vgupta@kernel.org>

Let's support __HAVE_ARCH_PTE_SWP_EXCLUSIVE by using bit 5, which is yet
unused. The only important parts seems to be to not use _PAGE_PRESENT
(bit 9).

Cc: Vineet Gupta <vgupta@kernel.org>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 arch/arc/include/asm/pgtable-bits-arcv2.h | 27 ++++++++++++++++++++---
 1 file changed, 24 insertions(+), 3 deletions(-)

diff --git a/arch/arc/include/asm/pgtable-bits-arcv2.h b/arch/arc/include/asm/pgtable-bits-arcv2.h
index 515e82db519f..611f412713b9 100644
--- a/arch/arc/include/asm/pgtable-bits-arcv2.h
+++ b/arch/arc/include/asm/pgtable-bits-arcv2.h
@@ -26,6 +26,9 @@
 #define _PAGE_GLOBAL		(1 << 8)  /* ASID agnostic (H) */
 #define _PAGE_PRESENT		(1 << 9)  /* PTE/TLB Valid (H) */
 
+/* We borrow bit 5 to store the exclusive marker in swap PTEs. */
+#define _PAGE_SWP_EXCLUSIVE	_PAGE_DIRTY
+
 #ifdef CONFIG_ARC_MMU_V4
 #define _PAGE_HW_SZ		(1 << 10)  /* Normal/super (H) */
 #else
@@ -106,9 +109,18 @@ static inline void set_pte_at(struct mm_struct *mm, unsigned long addr,
 void update_mmu_cache(struct vm_area_struct *vma, unsigned long address,
 		      pte_t *ptep);
 
-/* Encode swap {type,off} tuple into PTE
- * We reserve 13 bits for 5-bit @type, keeping bits 12-5 zero, ensuring that
- * PAGE_PRESENT is zero in a PTE holding swap "identifier"
+/*
+ * Encode/decode swap entries and swap PTEs. Swap PTEs are all PTEs that
+ * are !pte_none() && !pte_present().
+ *
+ * Format of swap PTEs:
+ *
+ *   3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
+ *   1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
+ *   <-------------- offset -------------> <--- zero --> E < type ->
+ *
+ *   E is the exclusive marker that is not stored in swap entries.
+ *   The zero'ed bits include _PAGE_PRESENT.
  */
 #define __swp_entry(type, off)		((swp_entry_t) \
 					{ ((type) & 0x1f) | ((off) << 13) })
@@ -120,6 +132,15 @@ void update_mmu_cache(struct vm_area_struct *vma, unsigned long address,
 #define __pte_to_swp_entry(pte)		((swp_entry_t) { pte_val(pte) })
 #define __swp_entry_to_pte(x)		((pte_t) { (x).val })
 
+#define __HAVE_ARCH_PTE_SWP_EXCLUSIVE
+static inline int pte_swp_exclusive(pte_t pte)
+{
+	return pte_val(pte) & _PAGE_SWP_EXCLUSIVE;
+}
+
+PTE_BIT_FUNC(swp_mkexclusive, |= (_PAGE_SWP_EXCLUSIVE));
+PTE_BIT_FUNC(swp_clear_exclusive, &= ~(_PAGE_SWP_EXCLUSIVE));
+
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 #include <asm/hugepage.h>
 #endif
-- 
2.39.0
