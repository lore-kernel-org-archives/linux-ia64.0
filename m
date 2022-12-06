From: David Hildenbrand <david@redhat.com>
Date: Tue, 06 Dec 2022 14:47:22 +0000
Subject: [PATCH mm-unstable RFC 18/26] powerpc/nohash/mm: support __HAVE_ARCH_PTE_SWP_EXCLUSIVE
Message-Id: <20221206144730.163732-19-david@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20221206144730.163732-1-david@redhat.com>
In-Reply-To: <20221206144730.163732-1-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, John Hubbard <jhubbard@nvidia.com>, Jason Gunthorpe <jgg@nvidia.com>, Mike Rapoport <rppt@linux.ibm.com>, Yang Shi <shy828301@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Nadav Amit <namit@vmware.com>, Andrea Arcangeli <aarcange@redhat.com>, Peter Xu <peterx@redhat.com>, linux-mm@kvack.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-csky@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-um@lists.infradead.org, linux-xtensa@linux-xtensa.org, David Hildenbrand <david@redhat.com>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Christophe Leroy <christophe.leroy@csgroup.eu>

Let's support __HAVE_ARCH_PTE_SWP_EXCLUSIVE on 32bit and 64bit.

On 64bit, let's use MSB 56 (LSB 7), located right next to the page type.
On 32bit, let's use LSB 2 to avoid stealing one bit from the swap offset.

There seems to be no real reason why these bits cannot be used for swap
PTEs. The important part is that _PAGE_PRESENT and _PAGE_HASHPTE remain
0.

While at it, mask the type in __swp_entry() and remove
_PAGE_BIT_SWAP_TYPE from pte-e500.h: while it was used in 64bit code it was
ignored in 32bit code.

Cc: Michael Ellerman <mpe@ellerman.id.au>
Cc: Nicholas Piggin <npiggin@gmail.com>
Cc: Christophe Leroy <christophe.leroy@csgroup.eu>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 arch/powerpc/include/asm/nohash/32/pgtable.h  | 22 +++++++++++++----
 arch/powerpc/include/asm/nohash/32/pte-40x.h  |  6 ++---
 arch/powerpc/include/asm/nohash/32/pte-44x.h  | 18 ++++----------
 arch/powerpc/include/asm/nohash/32/pte-85xx.h |  4 ++--
 arch/powerpc/include/asm/nohash/64/pgtable.h  | 24 ++++++++++++++++---
 arch/powerpc/include/asm/nohash/pgtable.h     | 16 +++++++++++++
 arch/powerpc/include/asm/nohash/pte-e500.h    |  1 -
 7 files changed, 63 insertions(+), 28 deletions(-)

diff --git a/arch/powerpc/include/asm/nohash/32/pgtable.h b/arch/powerpc/include/asm/nohash/32/pgtable.h
index 0d40b33184eb..1bb3698e6628 100644
--- a/arch/powerpc/include/asm/nohash/32/pgtable.h
+++ b/arch/powerpc/include/asm/nohash/32/pgtable.h
@@ -354,18 +354,30 @@ static inline int pte_young(pte_t pte)
 #endif
 
 #define pmd_page(pmd)		pfn_to_page(pmd_pfn(pmd))
+
 /*
- * Encode and decode a swap entry.
- * Note that the bits we use in a PTE for representing a swap entry
- * must not include the _PAGE_PRESENT bit.
- *   -- paulus
+ * Encode/decode swap entries and swap PTEs. Swap PTEs are all PTEs that
+ * are !pte_none() && !pte_present().
+ *
+ * Format of swap PTEs (32bit PTEs):
+ *
+ *                         1 1 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 3 3
+ *   0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+ *   <------------------ offset -------------------> < type -> E 0 0
+ *
+ * E is the exclusive marker that is not stored in swap entries.
+ *
+ * For 64bit PTEs, the offset is extended by 32bit.
  */
 #define __swp_type(entry)		((entry).val & 0x1f)
 #define __swp_offset(entry)		((entry).val >> 5)
-#define __swp_entry(type, offset)	((swp_entry_t) { (type) | ((offset) << 5) })
+#define __swp_entry(type, offset)	((swp_entry_t) { ((type) & 0x1f) | ((offset) << 5) })
 #define __pte_to_swp_entry(pte)		((swp_entry_t) { pte_val(pte) >> 3 })
 #define __swp_entry_to_pte(x)		((pte_t) { (x).val << 3 })
 
+/* We borrow LSB 2 to store the exclusive marker in swap PTEs. */
+#define _PAGE_SWP_EXCLUSIVE	0x000004
+
 #endif /* !__ASSEMBLY__ */
 
 #endif /* __ASM_POWERPC_NOHASH_32_PGTABLE_H */
diff --git a/arch/powerpc/include/asm/nohash/32/pte-40x.h b/arch/powerpc/include/asm/nohash/32/pte-40x.h
index 2d3153cfc0d7..6fe46e754556 100644
--- a/arch/powerpc/include/asm/nohash/32/pte-40x.h
+++ b/arch/powerpc/include/asm/nohash/32/pte-40x.h
@@ -27,9 +27,9 @@
  *   of the 16 available.  Bit 24-26 of the TLB are cleared in the TLB
  *   miss handler.  Bit 27 is PAGE_USER, thus selecting the correct
  *   zone.
- * - PRESENT *must* be in the bottom two bits because swap cache
- *   entries use the top 30 bits.  Because 40x doesn't support SMP
- *   anyway, M is irrelevant so we borrow it for PAGE_PRESENT.  Bit 30
+ * - PRESENT *must* be in the bottom two bits because swap PTEs
+ *   use the top 30 bits.  Because 40x doesn't support SMP anyway, M is
+ *   irrelevant so we borrow it for PAGE_PRESENT.  Bit 30
  *   is cleared in the TLB miss handler before the TLB entry is loaded.
  * - All other bits of the PTE are loaded into TLBLO without
  *   modification, leaving us only the bits 20, 21, 24, 25, 26, 30 for
diff --git a/arch/powerpc/include/asm/nohash/32/pte-44x.h b/arch/powerpc/include/asm/nohash/32/pte-44x.h
index 78bc304f750e..b7ed13cee137 100644
--- a/arch/powerpc/include/asm/nohash/32/pte-44x.h
+++ b/arch/powerpc/include/asm/nohash/32/pte-44x.h
@@ -56,20 +56,10 @@
  * above bits.  Note that the bit values are CPU specific, not architecture
  * specific.
  *
- * The kernel PTE entry holds an arch-dependent swp_entry structure under
- * certain situations. In other words, in such situations some portion of
- * the PTE bits are used as a swp_entry. In the PPC implementation, the
- * 3-24th LSB are shared with swp_entry, however the 0-2nd three LSB still
- * hold protection values. That means the three protection bits are
- * reserved for both PTE and SWAP entry at the most significant three
- * LSBs.
- *
- * There are three protection bits available for SWAP entry:
- *	_PAGE_PRESENT
- *	_PAGE_HASHPTE (if HW has)
- *
- * So those three bits have to be inside of 0-2nd LSB of PTE.
- *
+ * The kernel PTE entry can be an ordinary PTE mapping a page or a special swap
+ * PTE. In case of a swap PTE, LSB 2-24 are used to store information regarding
+ * the swap entry. However LSB 0-1 still hold protection values, for example,
+ * to distinguish swap PTEs from ordinary PTEs, and must be used with care.
  */
 
 #define _PAGE_PRESENT	0x00000001		/* S: PTE valid */
diff --git a/arch/powerpc/include/asm/nohash/32/pte-85xx.h b/arch/powerpc/include/asm/nohash/32/pte-85xx.h
index 93fb8e11a3f1..16451df5ddb0 100644
--- a/arch/powerpc/include/asm/nohash/32/pte-85xx.h
+++ b/arch/powerpc/include/asm/nohash/32/pte-85xx.h
@@ -11,8 +11,8 @@
    32 33 34 35 36  ... 50 51 52 53 54 55 56 57 58 59 60 61 62 63
    RPN......................  0  0 U0 U1 U2 U3 UX SX UW SW UR SR
 
-   - PRESENT *must* be in the bottom three bits because swap cache
-     entries use the top 29 bits.
+   - PRESENT *must* be in the bottom two bits because swap PTEs use
+     the top 30 bits.
 
 */
 
diff --git a/arch/powerpc/include/asm/nohash/64/pgtable.h b/arch/powerpc/include/asm/nohash/64/pgtable.h
index 879e9a6e5a87..287e25864ffa 100644
--- a/arch/powerpc/include/asm/nohash/64/pgtable.h
+++ b/arch/powerpc/include/asm/nohash/64/pgtable.h
@@ -276,22 +276,40 @@ static inline void __ptep_set_access_flags(struct vm_area_struct *vma,
 #define pgd_ERROR(e) \
 	pr_err("%s:%d: bad pgd %08lx.\n", __FILE__, __LINE__, pgd_val(e))
 
-/* Encode and de-code a swap entry */
+/*
+ * Encode/decode swap entries and swap PTEs. Swap PTEs are all PTEs that
+ * are !pte_none() && !pte_present().
+ *
+ * Format of swap PTEs:
+ *
+ *                         1 1 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 3 3
+ *   0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+ *   <-------------------------- offset ----------------------------
+ *
+ *   3 3 3 3 3 3 3 3 4 4 4 4 4 4 4 4 4 4 5 5 5 5 5 5 5 5 5 5 6 6 6 6
+ *   2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3
+ *   --------------> <----------- zero ------------> E < type -> 0 0
+ *
+ * E is the exclusive marker that is not stored in swap entries.
+ */
 #define MAX_SWAPFILES_CHECK() do { \
 	BUILD_BUG_ON(MAX_SWAPFILES_SHIFT > SWP_TYPE_BITS); \
 	} while (0)
 
 #define SWP_TYPE_BITS 5
-#define __swp_type(x)		(((x).val >> _PAGE_BIT_SWAP_TYPE) \
+#define __swp_type(x)		(((x).val >> 2) \
 				& ((1UL << SWP_TYPE_BITS) - 1))
 #define __swp_offset(x)		((x).val >> PTE_RPN_SHIFT)
 #define __swp_entry(type, offset)	((swp_entry_t) { \
-					((type) << _PAGE_BIT_SWAP_TYPE) \
+					(((type) & 0x1f) << 2) \
 					| ((offset) << PTE_RPN_SHIFT) })
 
 #define __pte_to_swp_entry(pte)		((swp_entry_t) { pte_val((pte)) })
 #define __swp_entry_to_pte(x)		__pte((x).val)
 
+/* We borrow MSB 56 (LSB 7) to store the exclusive marker in swap PTEs. */
+#define _PAGE_SWP_EXCLUSIVE	0x80
+
 int map_kernel_page(unsigned long ea, unsigned long pa, pgprot_t prot);
 void unmap_kernel_page(unsigned long va);
 extern int __meminit vmemmap_create_mapping(unsigned long start,
diff --git a/arch/powerpc/include/asm/nohash/pgtable.h b/arch/powerpc/include/asm/nohash/pgtable.h
index d9067dfc531c..c6df317ab6c3 100644
--- a/arch/powerpc/include/asm/nohash/pgtable.h
+++ b/arch/powerpc/include/asm/nohash/pgtable.h
@@ -151,6 +151,22 @@ static inline pte_t pte_modify(pte_t pte, pgprot_t newprot)
 	return __pte((pte_val(pte) & _PAGE_CHG_MASK) | pgprot_val(newprot));
 }
 
+#define __HAVE_ARCH_PTE_SWP_EXCLUSIVE
+static inline int pte_swp_exclusive(pte_t pte)
+{
+	return pte_val(pte) & _PAGE_SWP_EXCLUSIVE;
+}
+
+static inline pte_t pte_swp_mkexclusive(pte_t pte)
+{
+	return __pte(pte_val(pte) | _PAGE_SWP_EXCLUSIVE);
+}
+
+static inline pte_t pte_swp_clear_exclusive(pte_t pte)
+{
+	return __pte(pte_val(pte) & ~_PAGE_SWP_EXCLUSIVE);
+}
+
 /* Insert a PTE, top-level function is out of line. It uses an inline
  * low level function in the respective pgtable-* files
  */
diff --git a/arch/powerpc/include/asm/nohash/pte-e500.h b/arch/powerpc/include/asm/nohash/pte-e500.h
index 0934e8965e4e..d8924cbd61e4 100644
--- a/arch/powerpc/include/asm/nohash/pte-e500.h
+++ b/arch/powerpc/include/asm/nohash/pte-e500.h
@@ -12,7 +12,6 @@
 /* Architected bits */
 #define _PAGE_PRESENT	0x000001 /* software: pte contains a translation */
 #define _PAGE_SW1	0x000002
-#define _PAGE_BIT_SWAP_TYPE	2
 #define _PAGE_BAP_SR	0x000004
 #define _PAGE_BAP_UR	0x000008
 #define _PAGE_BAP_SW	0x000010
-- 
2.38.1
