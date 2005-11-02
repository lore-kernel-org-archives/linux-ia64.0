From: Robin Holt <holt@sgi.com>
Date: Wed, 02 Nov 2005 17:30:16 +0000
Subject: [Patch 2/2] Make 4-Level Page Tables configurable.
Message-Id: <20051102173016.GE23600@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


This patch makes the page table levels configurable.  I made
it a seperate patch since I have not yet measured any performance
difference and I thought this would make it easier to remove the
config option once it is deemed unneeded.

Signed-off-by: Robin Holt <holt@sgi.com>


Index: linux-2.6/include/asm-ia64/page.h
=================================--- linux-2.6.orig/include/asm-ia64/page.h	2005-11-02 06:01:21.252977544 -0600
+++ linux-2.6/include/asm-ia64/page.h	2005-11-02 06:01:21.988255563 -0600
@@ -172,13 +172,17 @@ get_order (unsigned long size)
    */
   typedef struct { unsigned long pte; } pte_t;
   typedef struct { unsigned long pmd; } pmd_t;
+#ifdef CONFIG_PGTABLE_4
   typedef struct { unsigned long pud; } pud_t;
+#endif
   typedef struct { unsigned long pgd; } pgd_t;
   typedef struct { unsigned long pgprot; } pgprot_t;
 
 # define pte_val(x)	((x).pte)
 # define pmd_val(x)	((x).pmd)
+#ifdef CONFIG_PGTABLE_4
 # define pud_val(x)	((x).pud)
+#endif
 # define pgd_val(x)	((x).pgd)
 # define pgprot_val(x)	((x).pgprot)
 
Index: linux-2.6/include/asm-ia64/pgtable.h
=================================--- linux-2.6.orig/include/asm-ia64/pgtable.h	2005-11-02 06:01:21.252001079 -0600
+++ linux-2.6/include/asm-ia64/pgtable.h	2005-11-02 06:01:21.989232027 -0600
@@ -104,6 +104,7 @@
 #define PMD_MASK	(~(PMD_SIZE-1))
 #define PTRS_PER_PMD	(1UL << (PTRS_PER_PTD_SHIFT))
 
+#ifdef CONFIG_PGTABLE_4
 /*
  * Definitions for second level:
  *
@@ -114,13 +115,18 @@
 #define PUD_SIZE	(1UL << PUD_SHIFT)
 #define PUD_MASK	(~(PUD_SIZE-1))
 #define PTRS_PER_PUD	(1UL << (PTRS_PER_PTD_SHIFT))
+#endif
 
 /*
  * Definitions for first level:
  *
  * PGDIR_SHIFT determines what a first-level page table entry can map.
  */
+#ifdef CONFIG_PGTABLE_4
 #define PGDIR_SHIFT		(PUD_SHIFT + (PTRS_PER_PTD_SHIFT))
+#else
+#define PGDIR_SHIFT		(PMD_SHIFT + (PTRS_PER_PTD_SHIFT))
+#endif
 #define PGDIR_SIZE		(__IA64_UL(1) << PGDIR_SHIFT)
 #define PGDIR_MASK		(~(PGDIR_SIZE-1))
 #define PTRS_PER_PGD		(1UL << (PTRS_PER_PTD_SHIFT))
@@ -176,7 +182,9 @@
 #define __S111	__pgprot(__ACCESS_BITS | _PAGE_PL_3 | _PAGE_AR_RWX)
 
 #define pgd_ERROR(e)	printk("%s:%d: bad pgd %016lx.\n", __FILE__, __LINE__, pgd_val(e))
+#ifdef CONFIG_PGTABLE_4
 #define pud_ERROR(e)	printk("%s:%d: bad pud %016lx.\n", __FILE__, __LINE__, pud_val(e))
+#endif
 #define pmd_ERROR(e)	printk("%s:%d: bad pmd %016lx.\n", __FILE__, __LINE__, pmd_val(e))
 #define pte_ERROR(e)	printk("%s:%d: bad pte %016lx.\n", __FILE__, __LINE__, pte_val(e))
 
@@ -277,11 +285,13 @@ ia64_phys_addr_valid (unsigned long addr
 #define pud_clear(pudp)			(pud_val(*(pudp)) = 0UL)
 #define pud_page(pud)			((unsigned long) __va(pud_val(pud) & _PFN_MASK))
 
+#ifdef CONFIG_PGTABLE_4
 #define pgd_none(pgd)			(!pgd_val(pgd))
 #define pgd_bad(pgd)			(!ia64_phys_addr_valid(pgd_val(pgd)))
 #define pgd_present(pgd)		(pgd_val(pgd) != 0UL)
 #define pgd_clear(pgdp)			(pgd_val(*(pgdp)) = 0UL)
 #define pgd_page(pgd)			((unsigned long) __va(pgd_val(pgd) & _PFN_MASK))
+#endif
 
 /*
  * The following have defined behavior only work if pte_present() is true.
@@ -350,9 +360,11 @@ pgd_offset (struct mm_struct *mm, unsign
    here.  */
 #define pgd_offset_gate(mm, addr)	pgd_offset_k(addr)
 
+#ifdef CONFIG_PGTABLE_4
 /* Find an entry in the second-level page table.. */
 #define pud_offset(dir,addr) \
 	((pud_t *) pgd_page(*(dir)) + (((addr) >> PUD_SHIFT) & (PTRS_PER_PUD - 1)))
+#endif
 
 /* Find an entry in the third-level page table.. */
 #define pmd_offset(dir,addr) \
@@ -587,6 +599,9 @@ do {											\
 #define __HAVE_ARCH_PGD_OFFSET_GATE
 #define __HAVE_ARCH_LAZY_MMU_PROT_UPDATE
 
+#ifndef CONFIG_PGTABLE_4
+#include <asm-generic/pgtable-nopud.h>
+#endif
 #include <asm-generic/pgtable.h>
 
 #endif /* _ASM_IA64_PGTABLE_H */
Index: linux-2.6/arch/ia64/kernel/ivt.S
=================================--- linux-2.6.orig/arch/ia64/kernel/ivt.S	2005-11-02 06:01:21.255906938 -0600
+++ linux-2.6/arch/ia64/kernel/ivt.S	2005-11-02 06:41:13.291247266 -0600
@@ -140,11 +140,16 @@ ENTRY(vhpt_miss)
 (p6)	dep r17=r18,r19,3,(PAGE_SHIFT-3)	// r17=PTA + IFA(33,42)*8
 (p7)	dep r17=r18,r17,3,(PAGE_SHIFT-6)	// r17=PTA + (((IFA(61,63) << 7) | IFA(33,39))*8)
 	cmp.eq p7,p6=0,r21			// unused address bits all zeroes?
+#ifdef CONFIG_PGTABLE_4
 	shr.u r28=r22,PUD_SHIFT			// shift L2 index into position
+#else
+	shr.u r20=r22,PMD_SHIFT			// shift L3 index into position
+#endif
 	;;
 	ld8 r17=[r17]				// fetch the L1 entry (may be 0)
 	;;
 (p7)	cmp.eq p6,p7=r17,r0			// was L1 entry NULL?
+#ifdef CONFIG_PGTABLE_4
 	dep r28=r28,r17,3,(PAGE_SHIFT-3)	// compute address of L2 page table entry
 	;;
 	shr.u r20=r22,PMD_SHIFT			// shift L3 index into position
@@ -152,6 +157,9 @@ ENTRY(vhpt_miss)
 	;;
 (p7)	cmp.eq.or.andcm p6,p7=r29,r0		// was L2 entry NULL?
 	dep r17=r20,r29,3,(PAGE_SHIFT-3)	// compute address of L3 page table entry
+#else
+	dep r17=r20,r17,3,(PAGE_SHIFT-3)	// compute address of L3 page table entry
+#endif
 	;;
 	shr.u r19=r22,PAGE_SHIFT		// shift L4 index into position
 (p7)	ld8 r20=[r17]				// fetch the L3 entry (may be 0)
@@ -200,12 +208,18 @@ ENTRY(vhpt_miss)
 	 */
 	ld8 r25=[r21]				// read L4 PTE again
 	ld8 r26=[r17]				// read L3 entry again
+#ifdef CONFIG_PGTABLE_4
 	ld8 r30=[r28]				// read L2 entry again
 	;;
 	cmp.ne p6,p7=r30,r29			// did L2 entry change
 	mov r27=PAGE_SHIFT<<2
 	;;
 (p7)	cmp.ne.or.andcm p6,p7=r26,r20		// did L3 entry change
+#else
+	cmp.ne p6,p7=r26,r20			// did L3 entry change
+	mov r27=PAGE_SHIFT<<2
+	;;
+#endif
 	;;
 (p6)	ptc.l r22,r27				// purge PTE page translation
 (p7)	cmp.ne.or.andcm p6,p7=r25,r18		// did L4 PTE change
@@ -441,18 +455,28 @@ ENTRY(nested_dtlb_miss)
 (p6)	dep r17=r18,r19,3,(PAGE_SHIFT-3)	// r17=PTA + IFA(33,42)*8
 (p7)	dep r17=r18,r17,3,(PAGE_SHIFT-6)	// r17=PTA + (((IFA(61,63) << 7) | IFA(33,39))*8)
 	cmp.eq p7,p6=0,r21			// unused address bits all zeroes?
+#ifdef CONFIG_PGTABLE_4
 	shr.u r19=r22,PUD_SHIFT			// shift L2 index into position
+#else
+	shr.u r18=r22,PMD_SHIFT			// shift L3 index into position
+#endif
 	;;
 	ld8 r17=[r17]				// fetch the L1 entry (may be 0)
+#ifdef CONFIG_PGTABLE_4
 	shr.u r18=r22,PMD_SHIFT			// shift L3 index into position
+#else
+	shr.u r19=r22,PAGE_SHIFT		// shift L4 index into position
+#endif
 	;;
 (p7)	cmp.eq p6,p7=r17,r0			// was L1 entry NULL?
+#ifdef CONFIG_PGTABLE_4
 	dep r17=r19,r17,3,(PAGE_SHIFT-3)	// compute address of L2 page table entry
 	;;
 (p7)	ld8 r17=[r17]				// fetch the L2 entry (may be 0)
 	shr.u r19=r22,PAGE_SHIFT		// shift L4 index into position
 	;;
 (p7)	cmp.eq.or.andcm p6,p7=r17,r0		// was L2 entry NULL?
+#endif
 	dep r17=r18,r17,3,(PAGE_SHIFT-3)	// compute address of L3 page table entry
 	;;
 (p7)	ld8 r17=[r17]				// fetch the L3 entry (may be 0)
Index: linux-2.6/arch/ia64/Kconfig
=================================--- linux-2.6.orig/arch/ia64/Kconfig	2005-10-28 19:05:30.000000000 -0500
+++ linux-2.6/arch/ia64/Kconfig	2005-11-02 06:06:23.081186944 -0600
@@ -160,6 +160,18 @@ config IA64_PAGE_SIZE_64KB
 
 endchoice
 
+choice
+	prompt "Page Table Levels"
+	default PGTABLE_4
+
+config PGTABLE_3
+	bool "3 Levels"
+
+config PGTABLE_4
+	bool "4 Levels"
+
+endchoice
+
 source kernel/Kconfig.hz
 
 config IA64_BRL_EMU
Index: linux-2.6/include/asm/pgalloc.h
=================================--- linux-2.6.orig/include/asm/pgalloc.h	2005-11-02 06:01:21.252001079 -0600
+++ linux-2.6/include/asm/pgalloc.h	2005-11-02 06:12:52.449469685 -0600
@@ -86,6 +86,7 @@ static inline void pgd_free(pgd_t * pgd)
 	pgtable_quicklist_free(pgd);
 }
 
+#ifdef CONFIG_PGTABLE_4
 static inline void
 pgd_populate(struct mm_struct *mm, pgd_t * pgd_entry, pud_t * pud)
 {
@@ -102,6 +103,7 @@ static inline void pud_free(pud_t * pud)
 	pgtable_quicklist_free(pud);
 }
 #define __pud_free_tlb(tlb, pud)	pud_free(pud)
+#endif /* CONFIG_PGTABLE_4 */
 
 static inline void
 pud_populate(struct mm_struct *mm, pud_t * pud_entry, pmd_t * pmd)
Index: linux-2.6/arch/ia64/configs/sn2_defconfig
=================================--- linux-2.6.orig/arch/ia64/configs/sn2_defconfig	2005-10-12 10:43:53.000000000 -0500
+++ linux-2.6/arch/ia64/configs/sn2_defconfig	2005-11-02 06:52:21.251052933 -0600
@@ -80,6 +80,8 @@ CONFIG_MCKINLEY=y
 # CONFIG_IA64_PAGE_SIZE_8KB is not set
 CONFIG_IA64_PAGE_SIZE_16KB=y
 # CONFIG_IA64_PAGE_SIZE_64KB is not set
+# CONFIG_PGTABLE_3 is not set
+CONFIG_PGTABLE_4=y
 # CONFIG_HZ_100 is not set
 CONFIG_HZ_250=y
 # CONFIG_HZ_1000 is not set
