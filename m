From: Horms <horms@verge.net.au>
Date: Mon, 19 Jun 2006 08:23:55 +0000
Subject: [PATCH 1/2] ia64,kexec: refactor some mmu-related marcors to allow them to be reused by kexec
Message-Id: <20060619082353.GA15635@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Kexec makes use of pte_bits, vmlpt_bits and POW2(). By refactoring
these and some related macros, and moving them into a header, they
can be shared between the mmu initialisation code and kexec.

I wasn't sure about which header to put them in, but asm-ia64/pgalloc.h seems
appropriate.

I will post a subsequent patch which uses these versions of macros in kexec.

Signed-Off-By: Horms <horms@verge.net.au>

 arch/ia64/mm/init.c        |   37 ++++++++-----------------------------
 include/asm-ia64/pgalloc.h |   25 +++++++++++++++++++++++++
 2 files changed, 33 insertions(+), 29 deletions(-)

9ca6a5b6809de26d1ffdc5a1dcde6e129fdf7f59
diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index cafa877..88dfe4f 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -356,48 +356,26 @@ #endif
 	ia64_set_psr(psr);
 	ia64_srlz_i();
 
-	/*
-	 * Check if the virtually mapped linear page table (VMLPT) overlaps with a mapped
-	 * address space.  The IA-64 architecture guarantees that at least 50 bits of
-	 * virtual address space are implemented but if we pick a large enough page size
-	 * (e.g., 64KB), the mapped address space is big enough that it will overlap with
-	 * VMLPT.  I assume that once we run on machines big enough to warrant 64KB pages,
-	 * IMPL_VA_MSB will be significantly bigger, so this is unlikely to become a
-	 * problem in practice.  Alternatively, we could truncate the top of the mapped
-	 * address space to not permit mappings that would overlap with the VMLPT.
-	 * --davidm 00/12/06
-	 */
-#	define pte_bits			3
-#	define mapped_space_bits	(3*(PAGE_SHIFT - pte_bits) + PAGE_SHIFT)
-	/*
-	 * The virtual page table has to cover the entire implemented address space within
-	 * a region even though not all of this space may be mappable.  The reason for
-	 * this is that the Access bit and Dirty bit fault handlers perform
-	 * non-speculative accesses to the virtual page table, so the address range of the
-	 * virtual page table itself needs to be covered by virtual page table.
-	 */
-#	define vmlpt_bits		(impl_va_bits - PAGE_SHIFT + pte_bits)
-#	define POW2(n)			(1ULL << (n))
-
 	impl_va_bits = ffz(~(local_cpu_data->unimpl_va_mask | (7UL << 61)));
 
 	if (impl_va_bits < 51 || impl_va_bits > 61)
 		panic("CPU has bogus IMPL_VA_MSB value of %lu!\n", impl_va_bits - 1);
 	/*
-	 * mapped_space_bits - PAGE_SHIFT is the total number of ptes we need,
-	 * which must fit into "vmlpt_bits - pte_bits" slots. Second half of
+	 * MAPPED_SPACE_BITS - PAGE_SHIFT is the total number of ptes we need,
+	 * which must fit into "vmlpt_bits - PTE_BITS" slots. Second half of
 	 * the test makes sure that our mapped space doesn't overlap the
 	 * unimplemented hole in the middle of the region.
 	 */
-	if ((mapped_space_bits - PAGE_SHIFT > vmlpt_bits - pte_bits) ||
-	    (mapped_space_bits > impl_va_bits - 1))
+	if ((MAPPED_SPACE_BITS - PAGE_SHIFT > 
+	     vmlpt_bits(impl_va_bits) - PTE_BITS) ||
+	    (MAPPED_SPACE_BITS > impl_va_bits - 1))
 		panic("Cannot build a big enough virtual-linear page table"
 		      " to cover mapped address space.\n"
 		      " Try using a smaller page size.\n");
 
 
 	/* place the VMLPT at the end of each page-table mapped region: */
-	pta = POW2(61) - POW2(vmlpt_bits);
+	pta = POW2(61) - POW2(vmlpt_bits(impl_va_bits));
 
 	/*
 	 * Set the (virtually mapped linear) page table address.  Bit
@@ -405,7 +383,8 @@ #	define POW2(n)			(1ULL << (n))
 	 * size of the table, and bit 0 whether the VHPT walker is
 	 * enabled.
 	 */
-	ia64_set_pta(pta | (0 << 8) | (vmlpt_bits << 2) | VHPT_ENABLE_BIT);
+	ia64_set_pta(pta | (0 << 8) | (vmlpt_bits(impl_va_bits) << 2) | 
+		     VHPT_ENABLE_BIT);
 
 	ia64_tlb_init();
 
diff --git a/include/asm-ia64/pgalloc.h b/include/asm-ia64/pgalloc.h
index f2f2338..73d3714 100644
--- a/include/asm-ia64/pgalloc.h
+++ b/include/asm-ia64/pgalloc.h
@@ -161,4 +161,29 @@ #define __pte_free_tlb(tlb, pte)	pte_fre
 
 extern void check_pgt_cache(void);
 
+/*
+ * Check if the virtually mapped linear page table (VMLPT) overlaps with a
+ * mapped address space.  The IA-64 architecture guarantees that at least
+ * 50 bits of virtual address space are implemented but if we pick a large
+ * enough page size (e.g., 64KB), the mapped address space is big enough
+ * that it will overlap with VMLPT.  I assume that once we run on machines
+ * big enough to warrant 64KB pages, IMPL_VA_MSB will be significantly
+ * bigger, so this is unlikely to become a problem in practice.
+ * Alternatively, we could truncate the top of the mapped address space to
+ * not permit mappings that would overlap with the VMLPT.
+ * --davidm 00/12/06
+ */
+#define PTE_BITS		3
+#define MAPPED_SPACE_BITS	(3*(PAGE_SHIFT - PTE_BITS) + PAGE_SHIFT)
+/*
+ * The virtual page table has to cover the entire implemented address space
+ * within a region even though not all of this space may be mappable.  The
+ * reason for this is that the Access bit and Dirty bit fault handlers
+ * perform non-speculative accesses to the virtual page table, so the
+ * address range of the virtual page table itself needs to be covered by
+ * virtual page table.
+ */
+#define vmlpt_bits(va_bits)	((va_bits) - PAGE_SHIFT + PTE_BITS)
+#define POW2(n)			(1ULL << (n))
+
 #endif				/* _ASM_IA64_PGALLOC_H */
