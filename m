From: Robin Holt <holt@sgi.com>
Date: Fri, 11 Nov 2005 15:35:43 +0000
Subject: [Patch 1/1] 4-level page tables v5.
Message-Id: <20051111153543.GC19382@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


This patch introduces 4-level page tables to ia64.  I have run
some benchmarks and found nothing interesting.  Performance has
consistently fallen within the noise range.

It also introduces a config option (setting the default to 3
levels).  The config option prevents having 4 level page
tables with 64k base page size.


Signed-off-by: Robin Holt <holt@sgi.com>


Index: linux-2.6/include/asm-ia64/pgtable.h
=================================--- linux-2.6.orig/include/asm-ia64/pgtable.h	2005-11-10 16:19:31.069370931 -0600
+++ linux-2.6/include/asm-ia64/pgtable.h	2005-11-10 17:32:49.462651364 -0600
@@ -84,32 +84,55 @@
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
 
+#ifdef CONFIG_PGTABLE_4
 /*
- * Definitions for third level:
+ * Definitions for second level:
+ *
+ * PUD_SHIFT determines the size of the area a second-level page table
+ * can map.
  */
-#define PTRS_PER_PTE	(__IA64_UL(1) << (PAGE_SHIFT-3))
+#define PUD_SHIFT	(PMD_SHIFT + (PTRS_PER_PTD_SHIFT))
+#define PUD_SIZE	(1UL << PUD_SHIFT)
+#define PUD_MASK	(~(PUD_SIZE-1))
+#define PTRS_PER_PUD	(1UL << (PTRS_PER_PTD_SHIFT))
+#endif
+
+/*
+ * Definitions for first level:
+ *
+ * PGDIR_SHIFT determines what a first-level page table entry can map.
+ */
+#ifdef CONFIG_PGTABLE_4
+#define PGDIR_SHIFT		(PUD_SHIFT + (PTRS_PER_PTD_SHIFT))
+#else
+#define PGDIR_SHIFT		(PMD_SHIFT + (PTRS_PER_PTD_SHIFT))
+#endif
+#define PGDIR_SIZE		(__IA64_UL(1) << PGDIR_SHIFT)
+#define PGDIR_MASK		(~(PGDIR_SIZE-1))
+#define PTRS_PER_PGD_SHIFT	PTRS_PER_PTD_SHIFT
+#define PTRS_PER_PGD		(1UL << PTRS_PER_PGD_SHIFT)
+#define USER_PTRS_PER_PGD	(5*PTRS_PER_PGD/8)	/* regions 0-4 are user regions */
+#define FIRST_USER_ADDRESS	0
 
 /*
  * All the normal masks have the "page accessed" bits on, as any time
@@ -161,6 +184,9 @@
 #define __S111	__pgprot(__ACCESS_BITS | _PAGE_PL_3 | _PAGE_AR_RWX)
 
 #define pgd_ERROR(e)	printk("%s:%d: bad pgd %016lx.\n", __FILE__, __LINE__, pgd_val(e))
+#ifdef CONFIG_PGTABLE_4
+#define pud_ERROR(e)	printk("%s:%d: bad pud %016lx.\n", __FILE__, __LINE__, pud_val(e))
+#endif
 #define pmd_ERROR(e)	printk("%s:%d: bad pmd %016lx.\n", __FILE__, __LINE__, pmd_val(e))
 #define pte_ERROR(e)	printk("%s:%d: bad pte %016lx.\n", __FILE__, __LINE__, pte_val(e))
 
@@ -218,6 +244,9 @@ ia64_phys_addr_valid (unsigned long addr
 #define	kc_vaddr_to_offset(v) ((v) - RGN_BASE(RGN_GATE))
 #define	kc_offset_to_vaddr(o) ((o) + RGN_BASE(RGN_GATE))
 
+#define RGN_MAP_SHIFT (PGDIR_SHIFT + PTRS_PER_PGD_SHIFT - 3)
+#define RGN_MAP_LIMIT	((1UL << RGN_MAP_SHIFT) - PAGE_SIZE)	/* per region addr limit */
+
 /*
  * Conversion functions: convert page frame number (pfn) and a protection value to a page
  * table entry (pte).
@@ -254,9 +283,16 @@ ia64_phys_addr_valid (unsigned long addr
 #define pud_bad(pud)			(!ia64_phys_addr_valid(pud_val(pud)))
 #define pud_present(pud)		(pud_val(pud) != 0UL)
 #define pud_clear(pudp)			(pud_val(*(pudp)) = 0UL)
-
 #define pud_page(pud)			((unsigned long) __va(pud_val(pud) & _PFN_MASK))
 
+#ifdef CONFIG_PGTABLE_4
+#define pgd_none(pgd)			(!pgd_val(pgd))
+#define pgd_bad(pgd)			(!ia64_phys_addr_valid(pgd_val(pgd)))
+#define pgd_present(pgd)		(pgd_val(pgd) != 0UL)
+#define pgd_clear(pgdp)			(pgd_val(*(pgdp)) = 0UL)
+#define pgd_page(pgd)			((unsigned long) __va(pgd_val(pgd) & _PFN_MASK))
+#endif
+
 /*
  * The following have defined behavior only work if pte_present() is true.
  */
@@ -324,7 +360,13 @@ pgd_offset (struct mm_struct *mm, unsign
    here.  */
 #define pgd_offset_gate(mm, addr)	pgd_offset_k(addr)
 
+#ifdef CONFIG_PGTABLE_4
 /* Find an entry in the second-level page table.. */
+#define pud_offset(dir,addr) \
+	((pud_t *) pgd_page(*(dir)) + (((addr) >> PUD_SHIFT) & (PTRS_PER_PUD - 1)))
+#endif
+
+/* Find an entry in the third-level page table.. */
 #define pmd_offset(dir,addr) \
 	((pmd_t *) pud_page(*(dir)) + (((addr) >> PMD_SHIFT) & (PTRS_PER_PMD - 1)))
 
@@ -557,7 +599,9 @@ do {											\
 #define __HAVE_ARCH_PGD_OFFSET_GATE
 #define __HAVE_ARCH_LAZY_MMU_PROT_UPDATE
 
+#ifndef CONFIG_PGTABLE_4
 #include <asm-generic/pgtable-nopud.h>
+#endif
 #include <asm-generic/pgtable.h>
 
 #endif /* _ASM_IA64_PGTABLE_H */
Index: linux-2.6/include/asm-ia64/pgalloc.h
=================================--- linux-2.6.orig/include/asm-ia64/pgalloc.h	2005-11-10 16:19:31.070347396 -0600
+++ linux-2.6/include/asm-ia64/pgalloc.h	2005-11-10 17:32:49.472415356 -0600
@@ -86,6 +86,25 @@ static inline void pgd_free(pgd_t * pgd)
 	pgtable_quicklist_free(pgd);
 }
 
+#ifdef CONFIG_PGTABLE_4
+static inline void
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
+#endif /* CONFIG_PGTABLE_4 */
+
 static inline void
 pud_populate(struct mm_struct *mm, pud_t * pud_entry, pmd_t * pmd)
 {
Index: linux-2.6/include/asm-ia64/page.h
=================================--- linux-2.6.orig/include/asm-ia64/page.h	2005-11-10 16:19:31.070347396 -0600
+++ linux-2.6/include/asm-ia64/page.h	2005-11-10 17:32:49.478273751 -0600
@@ -47,8 +47,6 @@
 #define PERCPU_PAGE_SHIFT	16	/* log2() of max. size of per-CPU area */
 #define PERCPU_PAGE_SIZE	(__IA64_UL_CONST(1) << PERCPU_PAGE_SHIFT)
 
-#define RGN_MAP_LIMIT	((1UL << (4*PAGE_SHIFT - 12)) - PAGE_SIZE)	/* per region addr limit */
-
 
 #ifdef CONFIG_HUGETLB_PAGE
 # define HPAGE_REGION_BASE	RGN_BASE(RGN_HPAGE)
@@ -175,11 +173,17 @@ get_order (unsigned long size)
    */
   typedef struct { unsigned long pte; } pte_t;
   typedef struct { unsigned long pmd; } pmd_t;
+#ifdef CONFIG_PGTABLE_4
+  typedef struct { unsigned long pud; } pud_t;
+#endif
   typedef struct { unsigned long pgd; } pgd_t;
   typedef struct { unsigned long pgprot; } pgprot_t;
 
 # define pte_val(x)	((x).pte)
 # define pmd_val(x)	((x).pmd)
+#ifdef CONFIG_PGTABLE_4
+# define pud_val(x)	((x).pud)
+#endif
 # define pgd_val(x)	((x).pgd)
 # define pgprot_val(x)	((x).pgprot)
 
Index: linux-2.6/arch/ia64/kernel/ivt.S
=================================--- linux-2.6.orig/arch/ia64/kernel/ivt.S	2005-11-10 16:19:31.070347396 -0600
+++ linux-2.6/arch/ia64/kernel/ivt.S	2005-11-11 09:03:17.949824694 -0600
@@ -114,7 +114,7 @@ ENTRY(vhpt_miss)
 	shl r21=r16,3				// shift bit 60 into sign bit
 	shr.u r17=r16,61			// get the region number into r17
 	;;
-	shr r22=r21,3
+	shr.u r22=r21,3
 #ifdef CONFIG_HUGETLB_PAGE
 	extr.u r26=r25,2,6
 	;;
@@ -140,20 +140,34 @@ ENTRY(vhpt_miss)
 (p6)	dep r17=r18,r19,3,(PAGE_SHIFT-3)	// r17=PTA + IFA(33,42)*8
 (p7)	dep r17=r18,r17,3,(PAGE_SHIFT-6)	// r17=PTA + (((IFA(61,63) << 7) | IFA(33,39))*8)
 	cmp.eq p7,p6=0,r21			// unused address bits all zeroes?
-	shr.u r18=r22,PMD_SHIFT			// shift L2 index into position
+#ifdef CONFIG_PGTABLE_4
+	shr.u r28=r22,PUD_SHIFT			// shift L2 index into position
+#else
+	shr.u r18=r22,PMD_SHIFT			// shift L3 index into position
+#endif
 	;;
 	ld8 r17=[r17]				// fetch the L1 entry (may be 0)
 	;;
 (p7)	cmp.eq p6,p7=r17,r0			// was L1 entry NULL?
-	dep r17=r18,r17,3,(PAGE_SHIFT-3)	// compute address of L2 page table entry
+#ifdef CONFIG_PGTABLE_4
+	dep r28=r28,r17,3,(PAGE_SHIFT-3)	// compute address of L2 page table entry
+	;;
+	shr.u r18=r22,PMD_SHIFT			// shift L3 index into position
+(p7)	ld8 r29=[r28]				// fetch the L2 entry (may be 0)
 	;;
-(p7)	ld8 r20=[r17]				// fetch the L2 entry (may be 0)
-	shr.u r19=r22,PAGE_SHIFT		// shift L3 index into position
+(p7)	cmp.eq.or.andcm p6,p7=r29,r0		// was L2 entry NULL?
+	dep r17=r18,r29,3,(PAGE_SHIFT-3)	// compute address of L3 page table entry
+#else
+	dep r17=r18,r17,3,(PAGE_SHIFT-3)	// compute address of L3 page table entry
+#endif
 	;;
-(p7)	cmp.eq.or.andcm p6,p7=r20,r0		// was L2 entry NULL?
-	dep r21=r19,r20,3,(PAGE_SHIFT-3)	// compute address of L3 page table entry
+(p7)	ld8 r20=[r17]				// fetch the L3 entry (may be 0)
+	shr.u r19=r22,PAGE_SHIFT		// shift L4 index into position
 	;;
-(p7)	ld8 r18=[r21]				// read the L3 PTE
+(p7)	cmp.eq.or.andcm p6,p7=r20,r0		// was L3 entry NULL?
+	dep r21=r19,r20,3,(PAGE_SHIFT-3)	// compute address of L4 page table entry
+	;;
+(p7)	ld8 r18=[r21]				// read the L4 PTE
 	mov r19=cr.isr				// cr.isr bit 0 tells us if this is an insn miss
 	;;
 (p7)	tbit.z p6,p7=r18,_PAGE_P_BIT		// page present bit cleared?
@@ -192,14 +206,21 @@ ENTRY(vhpt_miss)
 	 * between reading the pagetable and the "itc".  If so, flush the entry we
 	 * inserted and retry.
 	 */
-	ld8 r25=[r21]				// read L3 PTE again
-	ld8 r26=[r17]				// read L2 entry again
+	ld8 r25=[r21]				// read L4 entry again
+	ld8 r26=[r17]				// read L3 PTE again
+#ifdef CONFIG_PGTABLE_4
+	ld8 r18=[r28]				// read L2 entry again
+#endif
+	cmp.ne p6,p7=r0,r0
 	;;
-	cmp.ne p6,p7=r26,r20			// did L2 entry change
+	cmp.ne.or.andcm p6,p7=r26,r20		// did L3 entry change
+#ifdef CONFIG_PGTABLE_4
+	cmp.ne.or.andcm p6,p7=r29,r18		// did L4 PTE change
+#endif
 	mov r27=PAGE_SHIFT<<2
 	;;
 (p6)	ptc.l r22,r27				// purge PTE page translation
-(p7)	cmp.ne.or.andcm p6,p7=r25,r18		// did L3 PTE change
+(p7)	cmp.ne.or.andcm p6,p7=r25,r18		// did L4 PTE change
 	;;
 (p6)	ptc.l r16,r27				// purge translation
 #endif
@@ -432,18 +453,30 @@ ENTRY(nested_dtlb_miss)
 (p6)	dep r17=r18,r19,3,(PAGE_SHIFT-3)	// r17=PTA + IFA(33,42)*8
 (p7)	dep r17=r18,r17,3,(PAGE_SHIFT-6)	// r17=PTA + (((IFA(61,63) << 7) | IFA(33,39))*8)
 	cmp.eq p7,p6=0,r21			// unused address bits all zeroes?
-	shr.u r18=r22,PMD_SHIFT			// shift L2 index into position
+#ifdef CONFIG_PGTABLE_4
+	shr.u r18=r22,PUD_SHIFT			// shift L2 index into position
+#else
+	shr.u r18=r22,PMD_SHIFT			// shift L3 index into position
+#endif
 	;;
 	ld8 r17=[r17]				// fetch the L1 entry (may be 0)
 	;;
 (p7)	cmp.eq p6,p7=r17,r0			// was L1 entry NULL?
 	dep r17=r18,r17,3,(PAGE_SHIFT-3)	// compute address of L2 page table entry
 	;;
+#ifdef CONFIG_PGTABLE_4
 (p7)	ld8 r17=[r17]				// fetch the L2 entry (may be 0)
-	shr.u r19=r22,PAGE_SHIFT		// shift L3 index into position
+	shr.u r18=r22,PMD_SHIFT			// shift L3 index into position
 	;;
 (p7)	cmp.eq.or.andcm p6,p7=r17,r0		// was L2 entry NULL?
-	dep r17=r19,r17,3,(PAGE_SHIFT-3)	// compute address of L3 page table entry
+	dep r17=r18,r17,3,(PAGE_SHIFT-3)	// compute address of L2 page table entry
+	;;
+#endif
+(p7)	ld8 r17=[r17]				// fetch the L3 entry (may be 0)
+	shr.u r19=r22,PAGE_SHIFT		// shift L4 index into position
+	;;
+(p7)	cmp.eq.or.andcm p6,p7=r17,r0		// was L3 entry NULL?
+	dep r17=r19,r17,3,(PAGE_SHIFT-3)	// compute address of L4 page table entry
 (p6)	br.cond.spnt page_fault
 	mov b0=r30
 	br.sptk.many b0				// return to continuation point
Index: linux-2.6/arch/ia64/configs/sn2_defconfig
=================================--- linux-2.6.orig/arch/ia64/configs/sn2_defconfig	2005-11-10 16:19:31.071323861 -0600
+++ linux-2.6/arch/ia64/configs/sn2_defconfig	2005-11-10 17:32:49.668671591 -0600
@@ -80,6 +80,8 @@ CONFIG_MCKINLEY=y
 # CONFIG_IA64_PAGE_SIZE_8KB is not set
 CONFIG_IA64_PAGE_SIZE_16KB=y
 # CONFIG_IA64_PAGE_SIZE_64KB is not set
+# CONFIG_PGTABLE_3 is not set
+CONFIG_PGTABLE_4=y
 # CONFIG_HZ_100 is not set
 CONFIG_HZ_250=y
 # CONFIG_HZ_1000 is not set
Index: linux-2.6/arch/ia64/defconfig
=================================--- linux-2.6.orig/arch/ia64/defconfig	2005-11-10 16:19:31.071323861 -0600
+++ linux-2.6/arch/ia64/defconfig	2005-11-10 17:32:49.694057969 -0600
@@ -82,6 +82,8 @@ CONFIG_MCKINLEY=y
 # CONFIG_IA64_PAGE_SIZE_8KB is not set
 CONFIG_IA64_PAGE_SIZE_16KB=y
 # CONFIG_IA64_PAGE_SIZE_64KB is not set
+CONFIG_PGTABLE_3=y
+# CONFIG_PGTABLE_4 is not set
 # CONFIG_HZ_100 is not set
 CONFIG_HZ_250=y
 # CONFIG_HZ_1000 is not set
Index: linux-2.6/arch/ia64/Kconfig
=================================--- linux-2.6.orig/arch/ia64/Kconfig	2005-11-10 16:19:31.071323861 -0600
+++ linux-2.6/arch/ia64/Kconfig	2005-11-10 17:32:49.697963566 -0600
@@ -164,6 +164,19 @@ config IA64_PAGE_SIZE_64KB
 
 endchoice
 
+choice
+	prompt "Page Table Levels"
+	default PGTABLE_3
+
+config PGTABLE_3
+	bool "3 Levels"
+
+config PGTABLE_4
+	depends on !IA64_PAGE_SIZE_64KB
+	bool "4 Levels"
+
+endchoice
+
 source kernel/Kconfig.hz
 
 config IA64_BRL_EMU
