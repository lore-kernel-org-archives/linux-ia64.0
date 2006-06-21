From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Wed, 21 Jun 2006 03:17:13 +0000
Subject: [RFC 1/3] pgtable.h - reflow macros
Message-Id: <20060621031713.22750.87725.sendpatchset@wagner.orchestra.cse.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Make the macros for each level consist, and document them.  Previous
criticism has been that upper layers will never be more than a
pointer, so why bother, but since it all falls out in the preprocessor
I don't think it matters.

Signed-Off-By: Ian Wienand <ianw@gelato.unsw.edu.au>

---

 pgtable.h |  109 ++++++++++++++++++++++++++++++++++++++++----------------------
 1 file changed, 72 insertions(+), 37 deletions(-)

--- a/include/asm-ia64/pgtable.h
+++ b/include/asm-ia64/pgtable.h
@@ -84,54 +84,72 @@
 #define __DIRTY_BITS		_PAGE_ED | __DIRTY_BITS_NO_ED
 
 /*
- * How many pointers will a page table level hold expressed in shift
+ * Overall page table macro explanations
+ * ==================+ * level_ENTRY_BITS : How many bits in one entry at this level.
+ *                    i.e. log2(width of entry)
+ * level_INDEX_BITS : Those bits in a page full of entries that identify unique entries.
+ *                    i.e. PAGE_SIZE / (width of entry)
+ * PTRS_PER_level   : The number of entries of level a page can hold
+ *                    i.e. 2^level_INDEX_BITS
+ * level_SHIFT      : number of bits this level maps (cumulative with lower levels)
+ * level_SIZE       : how much an address space an entry at this level maps
+ *                    i.e. 2^level_SHIFT
+ * level_MASK       : mask of bits that make up this level and lower levels
  */
-#define PTRS_PER_PTD_SHIFT	(PAGE_SHIFT-3)
 
 /*
  * Definitions for fourth level:
+ * A PTD is a page full of PTE entries
  */
-#define PTRS_PER_PTE	(__IA64_UL(1) << (PTRS_PER_PTD_SHIFT))
+#define PTD_ENTRY_BITS	3
+#define PTD_INDEX_BITS	(PAGE_SHIFT - PTD_ENTRY_BITS)
+#define PTRS_PER_PTD	(__IA64_UL(1) << PTD_INDEX_BITS)
+/* some other places in the kernel expect PTRS_PER_PTE to be defined
+ * to the number of ptes in a page; we define it here but try not to
+ * use it to avoid further confusion
+ */
+#define PTRS_PER_PTE	PTRS_PER_PTD
+#define PTD_SHIFT	PAGE_SHIFT
 
 /*
- * Definitions for third level:
- *
- * PMD_SHIFT determines the size of the area a third-level page table
- * can map.
+ * Definitions for third level (middle)
  */
-#define PMD_SHIFT	(PAGE_SHIFT + (PTRS_PER_PTD_SHIFT))
-#define PMD_SIZE	(1UL << PMD_SHIFT)
+#define PMD_ENTRY_BITS	3
+#define PMD_INDEX_BITS	(PAGE_SHIFT - PMD_ENTRY_BITS)
+#define PMD_SHIFT	(PMD_INDEX_BITS + PTD_SHIFT)
+#define PMD_SIZE	(__IA64_UL(1) << PMD_SHIFT)
 #define PMD_MASK	(~(PMD_SIZE-1))
-#define PTRS_PER_PMD	(1UL << (PTRS_PER_PTD_SHIFT))
+#define PTRS_PER_PMD	(__IA64_UL(1) << (PMD_INDEX_BITS))
 
-#ifdef CONFIG_PGTABLE_4
 /*
- * Definitions for second level:
- *
- * PUD_SHIFT determines the size of the area a second-level page table
- * can map.
+ * Definitions for second level (upper)
+ * By default we do not have 4 level page tables
  */
-#define PUD_SHIFT	(PMD_SHIFT + (PTRS_PER_PTD_SHIFT))
-#define PUD_SIZE	(1UL << PUD_SHIFT)
+#ifdef CONFIG_PGTABLE_4
+#define PUD_ENTRY_BITS	3
+#define PUD_INDEX_BITS	(PAGE_SHIFT - PUD_ENTRY_BITS)
+#define PUD_SHIFT	(PUD_INDEX_BITS + PMD_SHIFT)
+#define PUD_SIZE	(__IA64_UL(1) << PUD_SHIFT)
 #define PUD_MASK	(~(PUD_SIZE-1))
-#define PTRS_PER_PUD	(1UL << (PTRS_PER_PTD_SHIFT))
+#define PTRS_PER_PUD	(__IA64_UL(1) << PUD_INDEX_BITS)
 #endif
 
 /*
- * Definitions for first level:
- *
- * PGDIR_SHIFT determines what a first-level page table entry can map.
+ * Definitions for first level (global)
  */
+#define PGD_ENTRY_BITS		3
+#define PGD_INDEX_BITS		(PAGE_SHIFT - PGD_ENTRY_BITS)
 #ifdef CONFIG_PGTABLE_4
-#define PGDIR_SHIFT		(PUD_SHIFT + (PTRS_PER_PTD_SHIFT))
+#define PGDIR_SHIFT		(PGD_INDEX_BITS + PUD_SHIFT)
 #else
-#define PGDIR_SHIFT		(PMD_SHIFT + (PTRS_PER_PTD_SHIFT))
+#define PGDIR_SHIFT		(PGD_INDEX_BITS + PMD_SHIFT)
 #endif
 #define PGDIR_SIZE		(__IA64_UL(1) << PGDIR_SHIFT)
 #define PGDIR_MASK		(~(PGDIR_SIZE-1))
-#define PTRS_PER_PGD_SHIFT	PTRS_PER_PTD_SHIFT
-#define PTRS_PER_PGD		(1UL << PTRS_PER_PGD_SHIFT)
-#define USER_PTRS_PER_PGD	(5*PTRS_PER_PGD/8)	/* regions 0-4 are user regions */
+#define PTRS_PER_PGD		(__IA64_UL(1) << PGD_INDEX_BITS)
+/* Of the 8 regions, userspace may only map in the 5 regions 0-4 */
+#define USER_PTRS_PER_PGD	(5 * (PTRS_PER_PGD/8))
 #define FIRST_USER_ADDRESS	0
 
 /*
@@ -231,22 +249,40 @@ ia64_phys_addr_valid (unsigned long addr
 #define set_pte(ptep, pteval)	(*(ptep) = (pteval))
 #define set_pte_at(mm,addr,ptep,pteval) set_pte(ptep,pteval)
 
+/*
+ * MAPPED_SPACE_BITS is the number of bits that make up the maximum
+ * space we can map with our page tables
+ * i.e a page full of pgd entries fully populated
+ */
+#define MAPPED_SPACE_BITS	(PGDIR_SHIFT + PGD_INDEX_BITS)
+/* PGTABLE_MAP_LIMIT is how much space we can map with our page tables */
+#define PGTABLE_MAP_LIMIT	(__IA64_UL(1) << MAPPED_SPACE_BITS)
+
+/*
+ * RGN_MAP_LIMIT is the most one region can map, thus we remove the
+ * three region bits from the calculation.  Also remove a guard page.
+ */
+#define RGN_MAP_LIMIT		((__IA64_UL(1) << (MAPPED_SPACE_BITS - 3)) - PAGE_SIZE)
+
 #define VMALLOC_START		(RGN_BASE(RGN_GATE) + 0x200000000UL)
 #ifdef CONFIG_VIRTUAL_MEM_MAP
-# define VMALLOC_END_INIT	(RGN_BASE(RGN_GATE) + (1UL << (4*PAGE_SHIFT - 9)))
+/*
+ * With virtual mem_map, we reduce the vmalloc space and place the
+ * vmem_map virtual array above the vmalloc space.  The actual
+ * vmem_map size obviously depends on how much physical memory we
+ * have.
+ */
+# define VMALLOC_END_INIT	(RGN_BASE(RGN_GATE) + PGTABLE_MAP_LIMIT)
 # define VMALLOC_END		vmalloc_end
   extern unsigned long vmalloc_end;
 #else
-# define VMALLOC_END		(RGN_BASE(RGN_GATE) + (1UL << (4*PAGE_SHIFT - 9)))
+# define VMALLOC_END		(RGN_BASE(RGN_GATE) + PGTABLE_MAP_LIMIT)
 #endif
 
 /* fs/proc/kcore.c */
 #define	kc_vaddr_to_offset(v) ((v) - RGN_BASE(RGN_GATE))
 #define	kc_offset_to_vaddr(o) ((o) + RGN_BASE(RGN_GATE))
 
-#define RGN_MAP_SHIFT (PGDIR_SHIFT + PTRS_PER_PGD_SHIFT - 3)
-#define RGN_MAP_LIMIT	((1UL << RGN_MAP_SHIFT) - PAGE_SIZE)	/* per region addr limit */
-
 /*
  * Conversion functions: convert page frame number (pfn) and a protection value to a page
  * table entry (pte).
@@ -333,17 +369,17 @@ ia64_phys_addr_valid (unsigned long addr
  */
 #define pgprot_writecombine(prot)	__pgprot((pgprot_val(prot) & ~_PAGE_MA_MASK) | _PAGE_MA_WC)
 
+/* The offset in the PGD directory is given by the 3 region bits
+   (61..63) and the level-1 bits.  */
 static inline unsigned long
 pgd_index (unsigned long address)
 {
 	unsigned long region = address >> 61;
-	unsigned long l1index = (address >> PGDIR_SHIFT) & ((PTRS_PER_PGD >> 3) - 1);
+	unsigned long index = (address >> PGDIR_SHIFT) & ((PTRS_PER_PGD >> 3) - 1);
 
-	return (region << (PAGE_SHIFT - 6)) | l1index;
+	return (region << (PGD_INDEX_BITS - 3)) | index;
 }
 
-/* The offset in the 1-level directory is given by the 3 region bits
-   (61..63) and the level-1 bits.  */
 static inline pgd_t*
 pgd_offset (struct mm_struct *mm, unsigned long address)
 {
@@ -374,7 +410,7 @@ pgd_offset (struct mm_struct *mm, unsign
  * Find an entry in the third-level page table.  This looks more complicated than it
  * should be because some platforms place page tables in high memory.
  */
-#define pte_index(addr)	 	(((addr) >> PAGE_SHIFT) & (PTRS_PER_PTE - 1))
+#define pte_index(addr)	 	(((addr) >> PAGE_SHIFT) & (PTRS_PER_PTD - 1))
 #define pte_offset_kernel(dir,addr)	((pte_t *) pmd_page_kernel(*(dir)) + pte_index(addr))
 #define pte_offset_map(dir,addr)	pte_offset_kernel(dir, addr)
 #define pte_offset_map_nested(dir,addr)	pte_offset_map(dir, addr)

-
To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
