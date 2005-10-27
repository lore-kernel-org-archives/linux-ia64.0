From: Robin Holt <holt@sgi.com>
Date: Thu, 27 Oct 2005 04:17:09 +0000
Subject: [RFC] 4-level page table directories.
Message-Id: <20051027041709.GA13193@attica.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


I have started to work on 4-level page tables.  This boots.  I
make no further claims than that.

At one point, I discussed 4-level page tables on the ia64 mailing
list but did not find that discussion in my quick search from
marc.

David, I think it was you who expressed concern with introducing
the fourth level.  I have done some quick benchmarking and found
little difference (well within noise).  How had you envisioned
introducing a 3 or 4 level page tables?  Were you envisioning
a compile-time or run-time selection?

Thanks,
Robin

Index: linux-2.6/include/asm-ia64/pgtable.h
=================================--- linux-2.6.orig/include/asm-ia64/pgtable.h	2005-10-26 18:59:21.253268550 -0500
+++ linux-2.6/include/asm-ia64/pgtable.h	2005-10-26 23:01:34.572838463 -0500
@@ -84,32 +84,48 @@
 #define __DIRTY_BITS		_PAGE_ED | __DIRTY_BITS_NO_ED
 
 /*
- * Definitions for first level:
- *
- * PGDIR_SHIFT determines what a first-level page table entry can map.
+ * How many pointers will a page table level hold expressed in shift
  */
-#define PGDIR_SHIFT		(PAGE_SHIFT + 2*(PAGE_SHIFT-3))
-#define PGDIR_SIZE		(__IA64_UL(1) << PGDIR_SHIFT)
-#define PGDIR_MASK		(~(PGDIR_SIZE-1))
-#define PTRS_PER_PGD		(1UL << (PAGE_SHIFT-3))
-#define USER_PTRS_PER_PGD	(5*PTRS_PER_PGD/8)	/* regions 0-4 are user regions */
-#define FIRST_USER_ADDRESS	0
+#define PTRS_PER_PTD_SHIFT	(PAGE_SHIFT-3)
 
 /*
- * Definitions for second level:
+ * Definitions for fourth level:
+ */
+#define PTRS_PER_PTE	(__IA64_UL(1) << (PTRS_PER_PTD_SHIFT))
+
+/*
+ * Definitions for third level:
  *
- * PMD_SHIFT determines the size of the area a second-level page table
+ * PMD_SHIFT determines the size of the area a third-level page table
  * can map.
  */
-#define PMD_SHIFT	(PAGE_SHIFT + (PAGE_SHIFT-3))
+#define PMD_SHIFT	(PAGE_SHIFT + (PTRS_PER_PTD_SHIFT))
 #define PMD_SIZE	(1UL << PMD_SHIFT)
 #define PMD_MASK	(~(PMD_SIZE-1))
-#define PTRS_PER_PMD	(1UL << (PAGE_SHIFT-3))
+#define PTRS_PER_PMD	(1UL << (PTRS_PER_PTD_SHIFT))
 
 /*
- * Definitions for third level:
+ * Definitions for second level:
+ *
+ * PUD_SHIFT determines the size of the area a second-level page table
+ * can map.
+ */
+#define PUD_SHIFT	(PMD_SHIFT + (PTRS_PER_PTD_SHIFT))
+#define PUD_SIZE	(1UL << PUD_SHIFT)
+#define PUD_MASK	(~(PUD_SIZE-1))
+#define PTRS_PER_PUD	(1UL << (PTRS_PER_PTD_SHIFT))
+
+/*
+ * Definitions for first level:
+ *
+ * PGDIR_SHIFT determines what a first-level page table entry can map.
  */
-#define PTRS_PER_PTE	(__IA64_UL(1) << (PAGE_SHIFT-3))
+#define PGDIR_SHIFT		(PUD_SHIFT + (PTRS_PER_PTD_SHIFT))
+#define PGDIR_SIZE		(__IA64_UL(1) << PGDIR_SHIFT)
+#define PGDIR_MASK		(~(PGDIR_SIZE-1))
+#define PTRS_PER_PGD		(1UL << (PTRS_PER_PTD_SHIFT))
+#define USER_PTRS_PER_PGD	(5*PTRS_PER_PGD/8)	/* regions 0-4 are user regions */
+#define FIRST_USER_ADDRESS	0
 
 /*
  * All the normal masks have the "page accessed" bits on, as any time
@@ -160,6 +176,7 @@
 #define __S111	__pgprot(__ACCESS_BITS | _PAGE_PL_3 | _PAGE_AR_RWX)
 
 #define pgd_ERROR(e)	printk("%s:%d: bad pgd %016lx.\n", __FILE__, __LINE__, pgd_val(e))
+#define pud_ERROR(e)	printk("%s:%d: bad pud %016lx.\n", __FILE__, __LINE__, pud_val(e))
 #define pmd_ERROR(e)	printk("%s:%d: bad pmd %016lx.\n", __FILE__, __LINE__, pmd_val(e))
 #define pte_ERROR(e)	printk("%s:%d: bad pte %016lx.\n", __FILE__, __LINE__, pte_val(e))
 
@@ -256,9 +273,14 @@ ia64_phys_addr_valid (unsigned long addr
 #define pud_bad(pud)			(!ia64_phys_addr_valid(pud_val(pud)))
 #define pud_present(pud)		(pud_val(pud) != 0UL)
 #define pud_clear(pudp)			(pud_val(*(pudp)) = 0UL)
-
 #define pud_page(pud)			((unsigned long) __va(pud_val(pud) & _PFN_MASK))
 
+#define pgd_none(pgd)			(!pgd_val(pgd))
+#define pgd_bad(pgd)			(!ia64_phys_addr_valid(pgd_val(pgd)))
+#define pgd_present(pgd)		(pgd_val(pgd) != 0UL)
+#define pgd_clear(pgdp)			(pgd_val(*(pgdp)) = 0UL)
+#define pgd_page(pgd)			((unsigned long) __va(pgd_val(pgd) & _PFN_MASK))
+
 /*
  * The following have defined behavior only work if pte_present() is true.
  */
@@ -327,6 +349,10 @@ pgd_offset (struct mm_struct *mm, unsign
 #define pgd_offset_gate(mm, addr)	pgd_offset_k(addr)
 
 /* Find an entry in the second-level page table.. */
+#define pud_offset(dir,addr) \
+	((pud_t *) pgd_page(*(dir)) + (((addr) >> PUD_SHIFT) & (PTRS_PER_PUD - 1)))
+
+/* Find an entry in the third-level page table.. */
 #define pmd_offset(dir,addr) \
 	((pmd_t *) pud_page(*(dir)) + (((addr) >> PMD_SHIFT) & (PTRS_PER_PMD - 1)))
 
@@ -559,7 +585,6 @@ do {											\
 #define __HAVE_ARCH_PGD_OFFSET_GATE
 #define __HAVE_ARCH_LAZY_MMU_PROT_UPDATE
 
-#include <asm-generic/pgtable-nopud.h>
 #include <asm-generic/pgtable.h>
 
 #endif /* _ASM_IA64_PGTABLE_H */
Index: linux-2.6/include/asm-ia64/pgalloc.h
=================================--- linux-2.6.orig/include/asm-ia64/pgalloc.h	2005-10-26 18:59:21.254245014 -0500
+++ linux-2.6/include/asm-ia64/pgalloc.h	2005-10-26 19:08:46.598882737 -0500
@@ -87,6 +87,23 @@ static inline void pgd_free(pgd_t * pgd)
 }
 
 static inline void
+pgd_populate(struct mm_struct *mm, pgd_t * pgd_entry, pud_t * pud)
+{
+	pgd_val(*pgd_entry) = __pa(pud);
+}
+
+static inline pud_t *pud_alloc_one(struct mm_struct *mm, unsigned long addr)
+{
+	return pgtable_quicklist_alloc();
+}
+
+static inline void pud_free(pud_t * pud)
+{
+	pgtable_quicklist_free(pud);
+}
+#define __pud_free_tlb(tlb, pud)	pud_free(pud)
+
+static inline void
 pud_populate(struct mm_struct *mm, pud_t * pud_entry, pmd_t * pmd)
 {
 	pud_val(*pud_entry) = __pa(pmd);
Index: linux-2.6/include/asm-ia64/page.h
=================================--- linux-2.6.orig/include/asm-ia64/page.h	2005-10-26 18:59:21.254245014 -0500
+++ linux-2.6/include/asm-ia64/page.h	2005-10-26 19:08:46.604741525 -0500
@@ -174,11 +174,13 @@ get_order (unsigned long size)
    */
   typedef struct { unsigned long pte; } pte_t;
   typedef struct { unsigned long pmd; } pmd_t;
+  typedef struct { unsigned long pud; } pud_t;
   typedef struct { unsigned long pgd; } pgd_t;
   typedef struct { unsigned long pgprot; } pgprot_t;
 
 # define pte_val(x)	((x).pte)
 # define pmd_val(x)	((x).pmd)
+# define pud_val(x)	((x).pud)
 # define pgd_val(x)	((x).pgd)
 # define pgprot_val(x)	((x).pgprot)
 
Index: linux-2.6/arch/ia64/kernel/ivt.S
=================================--- linux-2.6.orig/arch/ia64/kernel/ivt.S	2005-10-26 18:59:21.278656627 -0500
+++ linux-2.6/arch/ia64/kernel/ivt.S	2005-10-26 22:36:41.939866135 -0500
@@ -140,20 +140,26 @@ ENTRY(vhpt_miss)
 (p6)	dep r17=r18,r19,3,(PAGE_SHIFT-3)	// r17=PTA + IFA(33,42)*8
 (p7)	dep r17=r18,r17,3,(PAGE_SHIFT-6)	// r17=PTA + (((IFA(61,63) << 7) | IFA(33,39))*8)
 	cmp.eq p7,p6=0,r21			// unused address bits all zeroes?
-	shr.u r18=r22,PMD_SHIFT			// shift L2 index into position
+	shr.u r19=r22,PUD_SHIFT			// shift L2 index into position
 	;;
 	ld8 r17=[r17]				// fetch the L1 entry (may be 0)
+	shr.u r18=r22,PMD_SHIFT			// shift L3 index into position
 	;;
 (p7)	cmp.eq p6,p7=r17,r0			// was L1 entry NULL?
-	dep r17=r18,r17,3,(PAGE_SHIFT-3)	// compute address of L2 page table entry
+	dep r28=r19,r17,3,(PAGE_SHIFT-3)	// compute address of L2 page table entry
 	;;
-(p7)	ld8 r20=[r17]				// fetch the L2 entry (may be 0)
-	shr.u r19=r22,PAGE_SHIFT		// shift L3 index into position
+(p7)	ld8 r29=[r28]				// fetch the L2 entry (may be 0)
+	shr.u r19=r22,PAGE_SHIFT		// shift L4 index into position
 	;;
-(p7)	cmp.eq.or.andcm p6,p7=r20,r0		// was L2 entry NULL?
-	dep r21=r19,r20,3,(PAGE_SHIFT-3)	// compute address of L3 page table entry
+(p7)	cmp.eq p6,p7=r29,r0			// was L2 entry NULL?
+	dep r17=r18,r29,3,(PAGE_SHIFT-3)	// compute address of L3 page table entry
 	;;
-(p7)	ld8 r18=[r21]				// read the L3 PTE
+(p7)	ld8 r20=[r17]				// fetch the L3 entry (may be 0)
+	;;
+(p7)	cmp.eq.or.andcm p6,p7=r20,r0		// was L3 entry NULL?
+	dep r21=r19,r20,3,(PAGE_SHIFT-3)	// compute address of L4 page table entry
+	;;
+(p7)	ld8 r18=[r21]				// read the L4 PTE
 	mov r19=cr.isr				// cr.isr bit 0 tells us if this is an insn miss
 	;;
 (p7)	tbit.z p6,p7=r18,_PAGE_P_BIT		// page present bit cleared?
@@ -192,12 +198,15 @@ ENTRY(vhpt_miss)
 	 * between reading the pagetable and the "itc".  If so, flush the entry we
 	 * inserted and retry.
 	 */
-	ld8 r25=[r21]				// read L3 PTE again
-	ld8 r26=[r17]				// read L2 entry again
+	ld8 r25=[r21]				// read L4 PTE again
+	ld8 r26=[r17]				// read L3 entry again
+	ld8 r30=[r28]				// read L2 entry again
 	;;
-	cmp.ne p6,p7=r26,r20			// did L2 entry change
+	cmp.ne p6,p7=r26,r20			// did L3 entry change
 	mov r27=PAGE_SHIFT<<2
 	;;
+(p7)	cmp.ne.or.andcm p6,p7=r30,r29		// did L2 entry change
+	;;
 (p6)	ptc.l r22,r27				// purge PTE page translation
 (p7)	cmp.ne.or.andcm p6,p7=r25,r18		// did L3 PTE change
 	;;
@@ -432,18 +441,24 @@ ENTRY(nested_dtlb_miss)
 (p6)	dep r17=r18,r19,3,(PAGE_SHIFT-3)	// r17=PTA + IFA(33,42)*8
 (p7)	dep r17=r18,r17,3,(PAGE_SHIFT-6)	// r17=PTA + (((IFA(61,63) << 7) | IFA(33,39))*8)
 	cmp.eq p7,p6=0,r21			// unused address bits all zeroes?
-	shr.u r18=r22,PMD_SHIFT			// shift L2 index into position
+	shr.u r19=r22,PUD_SHIFT			// shift L2 index into position
 	;;
 	ld8 r17=[r17]				// fetch the L1 entry (may be 0)
+	shr.u r18=r22,PMD_SHIFT			// shift L3 index into position
 	;;
 (p7)	cmp.eq p6,p7=r17,r0			// was L1 entry NULL?
-	dep r17=r18,r17,3,(PAGE_SHIFT-3)	// compute address of L2 page table entry
+	dep r17=r19,r17,3,(PAGE_SHIFT-3)	// compute address of L2 page table entry
 	;;
 (p7)	ld8 r17=[r17]				// fetch the L2 entry (may be 0)
-	shr.u r19=r22,PAGE_SHIFT		// shift L3 index into position
+	shr.u r19=r22,PAGE_SHIFT		// shift L4 index into position
+	;;
+(p7)	cmp.eq p6,p7=r17,r0			// was L2 entry NULL?
+	dep r17=r18,r17,3,(PAGE_SHIFT-3)	// compute address of L3 page table entry
+	;;
+(p7)	ld8 r17=[r17]				// fetch the L3 entry (may be 0)
 	;;
-(p7)	cmp.eq.or.andcm p6,p7=r17,r0		// was L2 entry NULL?
-	dep r17=r19,r17,3,(PAGE_SHIFT-3)	// compute address of L3 page table entry
+(p7)	cmp.eq.or.andcm p6,p7=r17,r0		// was L3 entry NULL?
+	dep r17=r19,r17,3,(PAGE_SHIFT-3)	// compute address of L4 page table entry
 (p6)	br.cond.spnt page_fault
 	mov b0=r30
 	br.sptk.many b0				// return to continuation point
