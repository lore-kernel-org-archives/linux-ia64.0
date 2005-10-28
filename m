From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Fri, 28 Oct 2005 05:19:57 +0000
Subject: Re: [RFC] 4-level page table directories.
Message-Id: <20051028051957.GC10485@cse.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051027041709.GA13193@attica.americas.sgi.com>
In-Reply-To: <20051027041709.GA13193@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Oct 26, 2005 at 11:17:09PM -0500, Robin Holt wrote:
> I have started to work on 4-level page tables.  This boots.  I
> make no further claims than that.

Do you need 4 level page tables for something?  I seem to remember it
coming up before too, I'd certainly be interested in seeing any
numbers you have.

Something I would really like is a small abstraction of some of the
page table access macros to make it a little clearer as to what is
happening.  Besides which using '-3' in many places assumes the size
of entries (of particular interest is the size of a PTE, which you
might want to increase; I can't see why you would increase the upper
levels).

I'd like to see something like this go in, or possibly wrap it up with
your changes.  I also tried to make comments a little more explicit.

> +#define PTRS_PER_PTD_SHIFT	(PAGE_SHIFT-3)

Is having a page of PTE's called at PTD a standard thing?  It has to
be better than PTRS_PER_PTE which is a little confusing.

-i
ianw@gelato.unsw.edu.au
http://www.gelato.unsw.edu.au

 arch/ia64/kernel/ivt.S     |   36 ++++++++++++++++-----------------
 include/asm-ia64/pgtable.h |   48 ++++++++++++++++++++++++++++++---------------
 2 files changed, 50 insertions(+), 34 deletions(-)
diff --git a/arch/ia64/kernel/ivt.S b/arch/ia64/kernel/ivt.S
--- a/arch/ia64/kernel/ivt.S
+++ b/arch/ia64/kernel/ivt.S
@@ -111,7 +111,7 @@ ENTRY(vhpt_miss)
 	rsm psr.dt				// use physical addressing for data
 	mov r31=pr				// save the predicate registers
 	mov r19=IA64_KR(PT_BASE)		// get page table base address
-	shl r21=r16,3				// shift bit 60 into sign bit
+	shl r21=r16,3				// shift out region number
 	shr.u r17=r16,61			// get the region number into r17
 	;;
 	shr r22=r21,3
@@ -125,33 +125,33 @@ ENTRY(vhpt_miss)
 (p8)	shr r22=r22,r27
 #endif
 	;;
-	cmp.eq p6,p7=5,r17			// is IFA pointing into to region 5?
+	cmp.eq p6,p7=5,r17			// is faulting address in region 5?
 	shr.u r18=r22,PGDIR_SHIFT		// get bits 33-63 of the faulting address
 	;;
-(p7)	dep r17=r17,r19,(PAGE_SHIFT-3),3	// put region number bits in place
+(p7)	dep r17=r17,r19,PGD_INDEX_BITS,PGD_ENTRY_BITS	// put region number bits in place
 
 	srlz.d
 	LOAD_PHYSICAL(p6, r19, swapper_pg_dir)	// region 5 is rooted at swapper_pg_dir
 
 	.pred.rel "mutex", p6, p7
-(p6)	shr.u r21=r21,PGDIR_SHIFT+PAGE_SHIFT
-(p7)	shr.u r21=r21,PGDIR_SHIFT+PAGE_SHIFT-3
+(p6)	shr.u r21=r21,PGDIR_SHIFT+PAGE_SHIFT	// shift out r21 to make sure unused bits zero
+(p7)	shr.u r21=r21,PGDIR_SHIFT+PAGE_SHIFT-3	// for !r5 we already shifted out the top 3 bits
 	;;
-(p6)	dep r17=r18,r19,3,(PAGE_SHIFT-3)	// r17=PTA + IFA(33,42)*8
-(p7)	dep r17=r18,r17,3,(PAGE_SHIFT-6)	// r17=PTA + (((IFA(61,63) << 7) | IFA(33,39))*8)
+(p6)	dep r17=r18,r19,PGD_ENTRY_BITS,PGD_INDEX_BITS	// find the PGD offset from the page table base
+(p7)	dep r17=r18,r17,PGD_ENTRY_BITS,PGD_INDEX_BITS-3 // for !r5 we already have region bits
 	cmp.eq p7,p6=0,r21			// unused address bits all zeroes?
 	shr.u r18=r22,PMD_SHIFT			// shift L2 index into position
 	;;
 	ld8 r17=[r17]				// fetch the L1 entry (may be 0)
 	;;
 (p7)	cmp.eq p6,p7=r17,r0			// was L1 entry NULL?
-	dep r17=r18,r17,3,(PAGE_SHIFT-3)	// compute address of L2 page table entry
+	dep r17=r18,r17,PMD_ENTRY_BITS,PMD_INDEX_BITS	// compute address of L2 page table entry
 	;;
 (p7)	ld8 r20=[r17]				// fetch the L2 entry (may be 0)
 	shr.u r19=r22,PAGE_SHIFT		// shift L3 index into position
 	;;
 (p7)	cmp.eq.or.andcm p6,p7=r20,r0		// was L2 entry NULL?
-	dep r21=r19,r20,3,(PAGE_SHIFT-3)	// compute address of L3 page table entry
+	dep r21=r19,r20,PTD_ENTRY_BITS,PTD_INDEX_BITS	// compute address of L3 page table entry
 	;;
 (p7)	ld8 r18=[r21]				// read the L3 PTE
 	mov r19=cr.isr				// cr.isr bit 0 tells us if this is an insn miss
@@ -408,7 +408,7 @@ ENTRY(nested_dtlb_miss)
 	 */
 	rsm psr.dt				// switch to using physical data addressing
 	mov r19=IA64_KR(PT_BASE)		// get the page table base address
-	shl r21=r16,3				// shift bit 60 into sign bit
+	shl r21=r16,3				// shift out region number
 	mov r18=cr.itir
 	;;
 	shr.u r17=r16,61			// get the region number into r17
@@ -420,30 +420,30 @@ ENTRY(nested_dtlb_miss)
 	;;
 	shr.u r22=r16,r22
 	shr.u r18=r16,r18
-(p7)	dep r17=r17,r19,(PAGE_SHIFT-3),3	// put region number bits in place
+(p7)	dep r17=r17,r19,PGD_INDEX_BITS,PGD_ENTRY_BITS	// put region number bits in place
 
 	srlz.d
 	LOAD_PHYSICAL(p6, r19, swapper_pg_dir)	// region 5 is rooted at swapper_pg_dir
 
 	.pred.rel "mutex", p6, p7
-(p6)	shr.u r21=r21,PGDIR_SHIFT+PAGE_SHIFT
-(p7)	shr.u r21=r21,PGDIR_SHIFT+PAGE_SHIFT-3
+(p6)	shr.u r21=r21,PGDIR_SHIFT+PAGE_SHIFT	// shift out r21 to make sure unused bits zero
+(p7)	shr.u r21=r21,PGDIR_SHIFT+PAGE_SHIFT-3  // for !r5 we already shifted out the top 3 bits
 	;;
-(p6)	dep r17=r18,r19,3,(PAGE_SHIFT-3)	// r17=PTA + IFA(33,42)*8
-(p7)	dep r17=r18,r17,3,(PAGE_SHIFT-6)	// r17=PTA + (((IFA(61,63) << 7) | IFA(33,39))*8)
-	cmp.eq p7,p6=0,r21			// unused address bits all zeroes?
+(p6)	dep r17=r18,r19,PGD_ENTRY_BITS,PGD_INDEX_BITS	// find the PGD offset from the page table base
+(p7)	dep r17=r18,r17,PGD_ENTRY_BITS,PGD_INDEX_BITS-3 // for !r5 we already have region bits
+	cmp.eq p7,p6=0,r21			// unused address bits all zeroes?  if not something wrong
 	shr.u r18=r22,PMD_SHIFT			// shift L2 index into position
 	;;
 	ld8 r17=[r17]				// fetch the L1 entry (may be 0)
 	;;
 (p7)	cmp.eq p6,p7=r17,r0			// was L1 entry NULL?
-	dep r17=r18,r17,3,(PAGE_SHIFT-3)	// compute address of L2 page table entry
+	dep r17=r18,r17,PMD_ENTRY_BITS,PMD_INDEX_BITS	// compute address of L2 page table entry
 	;;
 (p7)	ld8 r17=[r17]				// fetch the L2 entry (may be 0)
 	shr.u r19=r22,PAGE_SHIFT		// shift L3 index into position
 	;;
 (p7)	cmp.eq.or.andcm p6,p7=r17,r0		// was L2 entry NULL?
-	dep r17=r19,r17,3,(PAGE_SHIFT-3)	// compute address of L3 page table entry
+	dep r17=r19,r17,PTD_ENTRY_BITS,PTD_INDEX_BITS	// compute address of L3 page table entry
 (p6)	br.cond.spnt page_fault
 	mov b0=r30
 	br.sptk.many b0				// return to continuation point
diff --git a/arch/ia64/mm/contig.c b/arch/ia64/mm/contig.c
diff --git a/arch/ia64/mm/discontig.c b/arch/ia64/mm/discontig.c
diff --git a/arch/ia64/mm/fault.c b/arch/ia64/mm/fault.c
diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
diff --git a/include/asm-ia64/pgtable.h b/include/asm-ia64/pgtable.h
--- a/include/asm-ia64/pgtable.h
+++ b/include/asm-ia64/pgtable.h
@@ -84,16 +84,16 @@
 #define __DIRTY_BITS		_PAGE_ED | __DIRTY_BITS_NO_ED
 
 /*
- * Definitions for first level:
+ * Definitions for third level:
  *
- * PGDIR_SHIFT determines what a first-level page table entry can map.
+ * A PTD is a page full of PTE entries
  */
-#define PGDIR_SHIFT		(PAGE_SHIFT + 2*(PAGE_SHIFT-3))
-#define PGDIR_SIZE		(__IA64_UL(1) << PGDIR_SHIFT)
-#define PGDIR_MASK		(~(PGDIR_SIZE-1))
-#define PTRS_PER_PGD		(1UL << (PAGE_SHIFT-3))
-#define USER_PTRS_PER_PGD	(5*PTRS_PER_PGD/8)	/* regions 0-4 are user regions */
-#define FIRST_USER_ADDRESS	0
+#define PTD_ENTRY_BITS	3
+#define PTD_INDEX_BITS	(PAGE_SHIFT - PTD_ENTRY_BITS)
+#define PTRS_PER_PTD	(__IA64_UL(1) << PTD_INDEX_BITS)
+#define PTRS_PER_PTE	PTRS_PER_PTD
+ /* one entry maps one page */
+#define PTD_SHIFT	PAGE_SHIFT
 
 /*
  * Definitions for second level:
@@ -101,15 +101,27 @@
  * PMD_SHIFT determines the size of the area a second-level page table
  * can map.
  */
-#define PMD_SHIFT	(PAGE_SHIFT + (PAGE_SHIFT-3))
-#define PMD_SIZE	(1UL << PMD_SHIFT)
+#define PMD_ENTRY_BITS	3
+#define PMD_SHIFT	((PAGE_SHIFT - PMD_ENTRY_BITS) + PTD_SHIFT)
+#define PMD_SIZE	(__IA64_UL(1) << PMD_SHIFT)
 #define PMD_MASK	(~(PMD_SIZE-1))
-#define PTRS_PER_PMD	(1UL << (PAGE_SHIFT-3))
+#define PMD_INDEX_BITS	(PAGE_SHIFT - PMD_ENTRY_BITS)
+#define PTRS_PER_PMD	(__IA64_UL(1) << PMD_INDEX_BITS)
 
 /*
- * Definitions for third level:
+ * Definitions for first level:
+ *
+ * PGDIR_SHIFT determines what a first-level page table entry can map.
  */
-#define PTRS_PER_PTE	(__IA64_UL(1) << (PAGE_SHIFT-3))
+#define PGD_ENTRY_BITS		3
+#define PGDIR_SHIFT		((PAGE_SHIFT - PGD_ENTRY_BITS) + PMD_SHIFT)
+#define PGDIR_SIZE		(__IA64_UL(1) << PGDIR_SHIFT)
+#define PGDIR_MASK		(~(PGDIR_SIZE-1))
+#define PGD_INDEX_BITS		(PAGE_SHIFT - PGD_ENTRY_BITS)
+#define PTRS_PER_PGD		(__IA64_UL(1) << PGD_INDEX_BITS)
+/* regions 0-4 are user regions */
+#define USER_PTRS_PER_PGD	(5*PTRS_PER_PGD/(__IA64_UL(1) << PGD_ENTRY_BITS))
+#define FIRST_USER_ADDRESS	0
 
 /*
  * All the normal masks have the "page accessed" bits on, as any time
@@ -206,11 +218,15 @@ ia64_phys_addr_valid (unsigned long addr
 
 #define VMALLOC_START		(RGN_BASE(RGN_GATE) + 0x200000000UL)
 #ifdef CONFIG_VIRTUAL_MEM_MAP
-# define VMALLOC_END_INIT	(RGN_BASE(RGN_GATE) + (1UL << (4*PAGE_SHIFT - 9)))
+/*
+ * PGDIR_SHIFT is the size one PGD maps, so we need to account for a
+ * whole page of them.
+ */
+# define VMALLOC_END_INIT	(RGN_BASE(RGN_GATE) + (1UL << (PGDIR_SHIFT + PGD_INDEX_BITS)))
 # define VMALLOC_END		vmalloc_end
   extern unsigned long vmalloc_end;
 #else
-# define VMALLOC_END		(RGN_BASE(RGN_GATE) + (1UL << (4*PAGE_SHIFT - 9)))
+# define VMALLOC_END		(RGN_BASE(RGN_GATE) + (1UL << (PGDIR_SHIFT + PGD_INDEX_BITS)))
 #endif
 
 /* fs/proc/kcore.c */
@@ -334,7 +350,7 @@ pgd_offset (struct mm_struct *mm, unsign
  * Find an entry in the third-level page table.  This looks more complicated than it
  * should be because some platforms place page tables in high memory.
  */
-#define pte_index(addr)	 	(((addr) >> PAGE_SHIFT) & (PTRS_PER_PTE - 1))
+#define pte_index(addr)	 	(((addr) >> PAGE_SHIFT) & (PTRS_PER_PTD - 1))
 #define pte_offset_kernel(dir,addr)	((pte_t *) pmd_page_kernel(*(dir)) + pte_index(addr))
 #define pte_offset_map(dir,addr)	pte_offset_kernel(dir, addr)
 #define pte_offset_map_nested(dir,addr)	pte_offset_map(dir, addr)
