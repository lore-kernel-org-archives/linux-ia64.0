From: David Hildenbrand <david@redhat.com>
Date: Fri, 13 Jan 2023 17:10:24 +0000
Subject: [PATCH mm-unstable v1 24/26] x86/mm: support __HAVE_ARCH_PTE_SWP_EXCLUSIVE also on 32bit
Message-Id: <20230113171026.582290-25-david@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230113171026.582290-1-david@redhat.com>
In-Reply-To: <20230113171026.582290-1-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, John Hubbard <jhubbard@nvidia.com>, Jason Gunthorpe <jgg@nvidia.com>, Mike Rapoport <rppt@linux.ibm.com>, Yang Shi <shy828301@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Nadav Amit <namit@vmware.com>, Andrea Arcangeli <aarcange@redhat.com>, Peter Xu <peterx@redhat.com>, linux-mm@kvack.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-csky@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-um@lists.infradead.org, linux-xtensa@linux-xtensa.org, David Hildenbrand <david@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>

Let's support __HAVE_ARCH_PTE_SWP_EXCLUSIVE just like we already do on
x86-64. After deciphering the PTE layout it becomes clear that there are
still unused bits for 2-level and 3-level page tables that we should be
able to use. Reusing a bit avoids stealing one bit from the swap offset.

While at it, mask the type in __swp_entry(); use some helper definitions
to make the macros easier to grasp.

Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 arch/x86/include/asm/pgtable-2level.h | 26 +++++++++++++++++++++-----
 arch/x86/include/asm/pgtable-3level.h | 26 +++++++++++++++++++++++---
 arch/x86/include/asm/pgtable.h        |  2 --
 3 files changed, 44 insertions(+), 10 deletions(-)

diff --git a/arch/x86/include/asm/pgtable-2level.h b/arch/x86/include/asm/pgtable-2level.h
index 60d0f9015317..e9482a11ac52 100644
--- a/arch/x86/include/asm/pgtable-2level.h
+++ b/arch/x86/include/asm/pgtable-2level.h
@@ -80,21 +80,37 @@ static inline unsigned long pte_bitop(unsigned long value, unsigned int rightshi
 	return ((value >> rightshift) & mask) << leftshift;
 }
 
-/* Encode and de-code a swap entry */
+/*
+ * Encode/decode swap entries and swap PTEs. Swap PTEs are all PTEs that
+ * are !pte_none() && !pte_present().
+ *
+ * Format of swap PTEs:
+ *
+ *   3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
+ *   1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
+ *   <----------------- offset ------------------> 0 E <- type --> 0
+ *
+ *   E is the exclusive marker that is not stored in swap entries.
+ */
 #define SWP_TYPE_BITS 5
+#define _SWP_TYPE_MASK ((1U << SWP_TYPE_BITS) - 1)
+#define _SWP_TYPE_SHIFT (_PAGE_BIT_PRESENT + 1)
 #define SWP_OFFSET_SHIFT (_PAGE_BIT_PROTNONE + 1)
 
-#define MAX_SWAPFILES_CHECK() BUILD_BUG_ON(MAX_SWAPFILES_SHIFT > SWP_TYPE_BITS)
+#define MAX_SWAPFILES_CHECK() BUILD_BUG_ON(MAX_SWAPFILES_SHIFT > 5)
 
-#define __swp_type(x)			(((x).val >> (_PAGE_BIT_PRESENT + 1)) \
-					 & ((1U << SWP_TYPE_BITS) - 1))
+#define __swp_type(x)			(((x).val >> _SWP_TYPE_SHIFT) \
+					 & _SWP_TYPE_MASK)
 #define __swp_offset(x)			((x).val >> SWP_OFFSET_SHIFT)
 #define __swp_entry(type, offset)	((swp_entry_t) { \
-					 ((type) << (_PAGE_BIT_PRESENT + 1)) \
+					 (((type) & _SWP_TYPE_MASK) << _SWP_TYPE_SHIFT) \
 					 | ((offset) << SWP_OFFSET_SHIFT) })
 #define __pte_to_swp_entry(pte)		((swp_entry_t) { (pte).pte_low })
 #define __swp_entry_to_pte(x)		((pte_t) { .pte = (x).val })
 
+/* We borrow bit 7 to store the exclusive marker in swap PTEs. */
+#define _PAGE_SWP_EXCLUSIVE	_PAGE_PSE
+
 /* No inverted PFNs on 2 level page tables */
 
 static inline u64 protnone_mask(u64 val)
diff --git a/arch/x86/include/asm/pgtable-3level.h b/arch/x86/include/asm/pgtable-3level.h
index 967b135fa2c0..9e7c0b719c3c 100644
--- a/arch/x86/include/asm/pgtable-3level.h
+++ b/arch/x86/include/asm/pgtable-3level.h
@@ -145,8 +145,24 @@ static inline pmd_t pmdp_establish(struct vm_area_struct *vma,
 }
 #endif
 
-/* Encode and de-code a swap entry */
+/*
+ * Encode/decode swap entries and swap PTEs. Swap PTEs are all PTEs that
+ * are !pte_none() && !pte_present().
+ *
+ * Format of swap PTEs:
+ *
+ *   6 6 6 6 5 5 5 5 5 5 5 5 5 5 4 4 4 4 4 4 4 4 4 4 3 3 3 3 3 3 3 3
+ *   3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2
+ *   < type -> <---------------------- offset ----------------------
+ *
+ *   3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
+ *   1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
+ *   --------------------------------------------> 0 E 0 0 0 0 0 0 0
+ *
+ *   E is the exclusive marker that is not stored in swap entries.
+ */
 #define SWP_TYPE_BITS		5
+#define _SWP_TYPE_MASK ((1U << SWP_TYPE_BITS) - 1)
 
 #define SWP_OFFSET_FIRST_BIT	(_PAGE_BIT_PROTNONE + 1)
 
@@ -154,9 +170,10 @@ static inline pmd_t pmdp_establish(struct vm_area_struct *vma,
 #define SWP_OFFSET_SHIFT	(SWP_OFFSET_FIRST_BIT + SWP_TYPE_BITS)
 
 #define MAX_SWAPFILES_CHECK() BUILD_BUG_ON(MAX_SWAPFILES_SHIFT > SWP_TYPE_BITS)
-#define __swp_type(x)			(((x).val) & ((1UL << SWP_TYPE_BITS) - 1))
+#define __swp_type(x)			(((x).val) & _SWP_TYPE_MASK)
 #define __swp_offset(x)			((x).val >> SWP_TYPE_BITS)
-#define __swp_entry(type, offset)	((swp_entry_t){(type) | (offset) << SWP_TYPE_BITS})
+#define __swp_entry(type, offset)	((swp_entry_t){((type) & _SWP_TYPE_MASK) \
+					| (offset) << SWP_TYPE_BITS})
 
 /*
  * Normally, __swp_entry() converts from arch-independent swp_entry_t to
@@ -184,6 +201,9 @@ static inline pmd_t pmdp_establish(struct vm_area_struct *vma,
 #define __pte_to_swp_entry(pte)	(__swp_entry(__pteval_swp_type(pte), \
 					     __pteval_swp_offset(pte)))
 
+/* We borrow bit 7 to store the exclusive marker in swap PTEs. */
+#define _PAGE_SWP_EXCLUSIVE	_PAGE_PSE
+
 #include <asm/pgtable-invert.h>
 
 #endif /* _ASM_X86_PGTABLE_3LEVEL_H */
diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 1c843395a8b3..d25195726b78 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -1299,7 +1299,6 @@ static inline void update_mmu_cache_pud(struct vm_area_struct *vma,
 		unsigned long addr, pud_t *pud)
 {
 }
-#ifdef _PAGE_SWP_EXCLUSIVE
 #define __HAVE_ARCH_PTE_SWP_EXCLUSIVE
 static inline pte_t pte_swp_mkexclusive(pte_t pte)
 {
@@ -1315,7 +1314,6 @@ static inline pte_t pte_swp_clear_exclusive(pte_t pte)
 {
 	return pte_clear_flags(pte, _PAGE_SWP_EXCLUSIVE);
 }
-#endif /* _PAGE_SWP_EXCLUSIVE */
 
 #ifdef CONFIG_HAVE_ARCH_SOFT_DIRTY
 static inline pte_t pte_swp_mksoft_dirty(pte_t pte)
-- 
2.39.0
