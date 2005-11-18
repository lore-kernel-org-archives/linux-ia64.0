From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Fri, 18 Nov 2005 05:49:58 +0000
Subject: [RFC] ivt.S abstractions
Message-Id: <20051118054958.GA11941@cse.unsw.EDU.AU>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="OXfL5xGRrasGEqWY"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--OXfL5xGRrasGEqWY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

One thing we found is that ivt.S starts to get very cluttered when you
start introducing LVHPT and even worse if you do things like doubling
the size of a PTE while keeping it being able to be compiled out.  You
end up with nasty #ifdefs blocks everywhere.

My latest idea for getting around this is assembler macros, an example
is below.  Pulling out a few bits and pieces into separate files gives
you an opportunity to keep things a bit cleaner.  I'm really just
trolling for comments, although the patch boots and works on my
hardware.

Thanks,

-i
ianw@gelato.unsw.edu.au
http://www.gelato.unsw.edu.au

---

 arch/ia64/kernel/ivt.S       |  104 +++++------------------------------------
 include/asm-ia64/ivt-macro.S |  109 +++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 123 insertions(+), 90 deletions(-)
diff --git a/arch/ia64/kernel/ivt.S b/arch/ia64/kernel/ivt.S
index 301f2e9..a8f9a06 100644
--- a/arch/ia64/kernel/ivt.S
+++ b/arch/ia64/kernel/ivt.S
@@ -53,6 +53,9 @@
 #include <asm/unistd.h>
 #include <asm/errno.h>
 
+/* Generic macros that can be used in multiple places */
+#include <asm/ivt-macro.S>
+	
 #if 1
 # define PSR_DEFAULT_BITS	psr.ac
 #else
@@ -253,15 +256,8 @@ ENTRY(itlb_miss)
 	mov r29=b0				// save b0
 	mov r31=pr				// save predicates
 .itlb_fault:
-	mov r17=cr.iha				// get virtual address of PTE
-	movl r30=1f				// load nested fault continuation point
-	;;
-1:	ld8 r18=[r17]				// read *pte
-	;;
-	mov b0=r29
-	tbit.z p6,p0=r18,_PAGE_P_BIT		// page present bit cleared?
-(p6)	br.cond.spnt page_fault
-	;;
+	LOAD_PTE_MISS r17, r18, page_fault
+	;; 
 	itc.i r18
 	;;
 #ifdef CONFIG_SMP
@@ -297,14 +293,7 @@ ENTRY(dtlb_miss)
 	mov r29=b0				// save b0
 	mov r31=pr				// save predicates
 dtlb_fault:
-	mov r17=cr.iha				// get virtual address of PTE
-	movl r30=1f				// load nested fault continuation point
-	;;
-1:	ld8 r18=[r17]				// read *pte
-	;;
-	mov b0=r29
-	tbit.z p6,p0=r18,_PAGE_P_BIT		// page present bit cleared?
-(p6)	br.cond.spnt page_fault
+	LOAD_PTE_MISS r17, r18, page_fault
 	;;
 	itc.d r18
 	;;
@@ -436,56 +425,7 @@ ENTRY(nested_dtlb_miss)
 	 *
 	 * Clobbered:	b0, r18, r19, r21, r22, psr.dt (cleared)
 	 */
-	rsm psr.dt				// switch to using physical data addressing
-	mov r19=IA64_KR(PT_BASE)		// get the page table base address
-	shl r21=r16,3				// shift bit 60 into sign bit
-	mov r18=cr.itir
-	;;
-	shr.u r17=r16,61			// get the region number into r17
-	extr.u r18=r18,2,6			// get the faulting page size
-	;;
-	cmp.eq p6,p7=5,r17			// is faulting address in region 5?
-	add r22=-PAGE_SHIFT,r18			// adjustment for hugetlb address
-	add r18=PGDIR_SHIFT-PAGE_SHIFT,r18
-	;;
-	shr.u r22=r16,r22
-	shr.u r18=r16,r18
-(p7)	dep r17=r17,r19,(PAGE_SHIFT-3),3	// put region number bits in place
-
-	srlz.d
-	LOAD_PHYSICAL(p6, r19, swapper_pg_dir)	// region 5 is rooted at swapper_pg_dir
-
-	.pred.rel "mutex", p6, p7
-(p6)	shr.u r21=r21,PGDIR_SHIFT+PAGE_SHIFT
-(p7)	shr.u r21=r21,PGDIR_SHIFT+PAGE_SHIFT-3
-	;;
-(p6)	dep r17=r18,r19,3,(PAGE_SHIFT-3)	// r17=pgd_offset for region 5
-(p7)	dep r17=r18,r17,3,(PAGE_SHIFT-6)	// r17=pgd_offset for region[0-4]
-	cmp.eq p7,p6=0,r21			// unused address bits all zeroes?
-#ifdef CONFIG_PGTABLE_4
-	shr.u r18=r22,PUD_SHIFT			// shift pud index into position
-#else
-	shr.u r18=r22,PMD_SHIFT			// shift pmd index into position
-#endif
-	;;
-	ld8 r17=[r17]				// get *pgd (may be 0)
-	;;
-(p7)	cmp.eq p6,p7=r17,r0			// was pgd_present(*pgd) == NULL?
-	dep r17=r18,r17,3,(PAGE_SHIFT-3)	// r17=p[u|m]d_offset(pgd,addr)
-	;;
-#ifdef CONFIG_PGTABLE_4
-(p7)	ld8 r17=[r17]				// get *pud (may be 0)
-	shr.u r18=r22,PMD_SHIFT			// shift pmd index into position
-	;;
-(p7)	cmp.eq.or.andcm p6,p7=r17,r0		// was pud_present(*pud) == NULL?
-	dep r17=r18,r17,3,(PAGE_SHIFT-3)	// r17=pmd_offset(pud,addr)
-	;;
-#endif
-(p7)	ld8 r17=[r17]				// get *pmd (may be 0)
-	shr.u r19=r22,PAGE_SHIFT		// shift pte index into position
-	;;
-(p7)	cmp.eq.or.andcm p6,p7=r17,r0		// was pmd_present(*pmd) == NULL?
-	dep r17=r19,r17,3,(PAGE_SHIFT-3)	// r17=pte_offset(pmd,addr);
+	FIND_PTE r16, r17, p6, p7
 (p6)	br.cond.spnt page_fault
 	mov b0=r30
 	br.sptk.many b0				// return to continuation point
@@ -548,16 +488,12 @@ ENTRY(dirty_bit)
 	 * page table TLB entry isn't present, we take a nested TLB miss hit where we look
 	 * up the physical address of the L3 PTE and then continue at label 1 below.
 	 */
-	mov r16=cr.ifa				// get the address that caused the fault
-	movl r30=1f				// load continuation point in case of nested fault
-	;;
-	thash r17=r16				// compute virtual address of L3 PTE
 	mov r29=b0				// save b0 in case of nested fault
 	mov r31=pr				// save pr
+	;; 
+	LOAD_PTE_FAULT r16, r17, r18
 #ifdef CONFIG_SMP
 	mov r28=ar.ccv				// save ar.ccv
-	;;
-1:	ld8 r18=[r17]
 	;;					// avoid RAW on r18
 	mov ar.ccv=r18				// set compare value for cmpxchg
 	or r25=_PAGE_D|_PAGE_A,r18		// set the dirty and accessed bits
@@ -583,8 +519,6 @@ ENTRY(dirty_bit)
 	mov b0=r29				// restore b0
 	mov ar.ccv=r28
 #else
-	;;
-1:	ld8 r18=[r17]
 	;;					// avoid RAW on r18
 	or r18=_PAGE_D|_PAGE_A,r18		// set the dirty and accessed bits
 	mov b0=r29				// restore b0
@@ -603,7 +537,7 @@ ENTRY(iaccess_bit)
 	DBG_FAULT(9)
 	// Like Entry 8, except for instruction access
 	mov r16=cr.ifa				// get the address that caused the fault
-	movl r30=1f				// load continuation point in case of nested fault
+	mov r29=b0
 	mov r31=pr				// save predicates
 #ifdef CONFIG_ITANIUM
 	/*
@@ -617,13 +551,10 @@ ENTRY(iaccess_bit)
 (p6)	mov r16=r18				// if so, use cr.iip instead of cr.ifa
 #endif /* CONFIG_ITANIUM */
 	;;
-	thash r17=r16				// compute virtual address of L3 PTE
-	mov r29=b0				// save b0 in case of nested fault)
+	LOAD_PTE_FAULT r16, r17, r18
 #ifdef CONFIG_SMP
 	mov r28=ar.ccv				// save ar.ccv
 	;;
-1:	ld8 r18=[r17]
-	;;
 	mov ar.ccv=r18				// set compare value for cmpxchg
 	or r25=_PAGE_A,r18			// set the accessed bit
 	;;
@@ -649,8 +580,6 @@ ENTRY(iaccess_bit)
 	mov ar.ccv=r28
 #else /* !CONFIG_SMP */
 	;;
-1:	ld8 r18=[r17]
-	;;
 	or r18=_PAGE_A,r18			// set the accessed bit
 	mov b0=r29				// restore b0
 	;;
@@ -668,15 +597,12 @@ ENTRY(daccess_bit)
 	DBG_FAULT(10)
 	// Like Entry 8, except for data access
 	mov r16=cr.ifa				// get the address that caused the fault
-	movl r30=1f				// load continuation point in case of nested fault
-	;;
-	thash r17=r16				// compute virtual address of L3 PTE
-	mov r31=pr
 	mov r29=b0				// save b0 in case of nested fault)
+	mov r31=pr
+	;; 
+	LOAD_PTE_FAULT r16, r17, r18
 #ifdef CONFIG_SMP
 	mov r28=ar.ccv				// save ar.ccv
-	;;
-1:	ld8 r18=[r17]
 	;;					// avoid RAW on r18
 	mov ar.ccv=r18				// set compare value for cmpxchg
 	or r25=_PAGE_A,r18			// set the dirty bit
@@ -700,8 +626,6 @@ ENTRY(daccess_bit)
 (p7)	ptc.l r16,r24
 	mov ar.ccv=r28
 #else
-	;;
-1:	ld8 r18=[r17]
 	;;					// avoid RAW on r18
 	or r18=_PAGE_A,r18			// set the accessed bit
 	;;
diff --git a/include/asm-ia64/ivt-macro.S b/include/asm-ia64/ivt-macro.S
new file mode 100644
index 0000000..c9c6f8e
--- /dev/null
+++ b/include/asm-ia64/ivt-macro.S
@@ -0,0 +1,109 @@
+/*
+ * Macros for use in ivt.S
+ *
+ * Copyright (C) 2005 see ivt.S for orignal authors
+ * Abstractions some combination of
+ *  Matthew Chapman <matthewc@cse.unsw.edu.au>
+ *  Darren Williams <darren.williams@nicta.com.au>
+ *  Ian Wienand <ianw@gelato.unsw.edu.au>
+ */
+
+/*
+ * FIND_PTE 
+ * Walks the page table to find a PTE
+ * @va,		register holding virtual address
+ * @ppte, 	register with pointer to page table entry
+ * @p1,		predicate set if found
+ * @p2,		predicate set if !found
+ */
+.macro find_pte va, ppte, p1, p2
+	rsm psr.dt				// switch to using physical data addressing
+	mov r19=IA64_KR(PT_BASE)		// get the page table base address
+	shl r21=\va,3				// shift bit 60 into sign bit
+	mov r18=cr.itir
+	;;
+	shr.u \ppte=\va,61			// get the region number into ppte
+	extr.u r18=r18,2,6			// get the faulting page size
+	;;
+	cmp.eq \p1,\p2=5,\ppte			// is faulting address in region 5?
+	add r22=-PAGE_SHIFT,r18			// adjustment for hugetlb address
+	add r18=PGDIR_SHIFT-PAGE_SHIFT,r18
+	;;
+	shr.u r22=\va,r22
+	shr.u r18=\va,r18
+(\p2)	dep \ppte=\ppte,r19,PGD_INDEX_BITS,3	// put region number bits in place
+
+	srlz.d
+	LOAD_PHYSICAL(\p1, r19, swapper_pg_dir)	// region 5 is rooted at swapper_pg_dir
+
+	.pred.rel "mutex", \p1, \p2
+(\p1)	shr.u r21=r21,PGDIR_SHIFT+PAGE_SHIFT
+(\p2)	shr.u r21=r21,PGDIR_SHIFT+PAGE_SHIFT-3
+	;;
+(\p1)	dep \ppte=r18,r19,PGD_ENTRY_BITS,PGD_INDEX_BITS		// ppte=pgd_offset for region 5
+(\p2)	dep \ppte=r18,r17,PGD_ENTRY_BITS,PGD_INDEX_BITS-3	// ppte=pgd_offset for region[0-4]
+	cmp.eq \p2,\p1=0,r21			// unused address bits all zeroes?
+#ifdef CONFIG_PGTABLE_4
+	shr.u r18=r22,PUD_SHIFT			// shift pud index into position
+#else
+	shr.u r18=r22,PMD_SHIFT			// shift pmd index into position
+#endif
+	;;
+	ld8 \ppte=[\ppte]			// get *pgd (may be 0)
+	;;
+(\p2)	cmp.eq \p1,\p2=\ppte,r0			// was pgd_present(*pgd) == NULL?
+#ifdef CONFIG_PGTABLE_4
+	dep \ppte=r18,\ppte,PUD_ENTRY_BITS,PUD_INDEX_BITS // ppte=pud_offset(pgd, addr)
+#else
+	dep \ppte=r18,\ppte,PMD_ENTRY_BITS,PMD_INDEX_BITS // ppte=pmd_offset(pgd, addr)
+#endif
+	;;
+#ifdef CONFIG_PGTABLE_4
+(\p2)	ld8 \ppte=[\ppte]			// get *pud (may be 0)
+	shr.u r18=r22,PMD_SHIFT			// shift pmd index into position
+	;;
+(\p2)	cmp.eq.or.andcm \p1,\p2=\ppte,r0	// was pud_present(*pud) == NULL?
+	dep \ppte=r18,\ppte,PMD_ENTRY_BITS,PMD_INDEX_BITS // ppte=pmd_offset(pud,addr)
+	;;
+#endif
+(\p2)	ld8 \ppte=[\ppte]			// get *pmd (may be 0)
+	shr.u r19=r22,PAGE_SHIFT		// shift pte index into position
+	;;
+(\p2)	cmp.eq.or.andcm \p1,\p2=\ppte,r0	// was pmd_present(*pmd) == NULL?
+	dep \ppte=r19,\ppte,PTD_ENTRY_BITS,PTD_INDEX_BITS // ppte=pte_offset(pmd,addr)
+.endm
+
+/*
+ * LOAD_PTE_MISS 
+ * Get a PTE based on the hardware walker's miss address,
+ * branch to the failfn if we can't find it
+ * @ppte,	pointer to page table entry
+ * @pte,	actual pte
+ * @failfn	function to call if PTE not present
+ */
+.macro load_pte_miss ppte, pte, failfn
+	mov \ppte=cr.iha			// get virtual address of L3 PTE
+	movl r30=1f				// load nested fault continuation point
+	;;
+1:	ld8 \pte=[\ppte]			// read L3 PTE
+	;;
+	mov b0=r29
+	tbit.z p6,p0=\pte,_PAGE_P_BIT		// page present bit cleared?
+(p6)	br.cond.spnt \failfn
+.endm
+
+/*
+ * LOAD_PTE_FAULT
+ * get a PTE from the hashed page table
+ * Note we only set r30 and don't save the other registers
+ * as required for nested_dtlb_miss.
+ * @va,		register holding virtual address
+ * @ppte,	register to hold pointer to pte
+ * @pte,	register to hold pte value
+ */
+.macro load_pte_fault va, ppte, pte
+	thash \ppte=\va				// get virtual address of L3
+	movl r30=1f				// load continuation for nested_dtlb_miss
+	;;
+1:	ld8 \pte=[\ppte]
+.endm

--OXfL5xGRrasGEqWY
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFDfWuGWDlSU/gp6ecRAldKAJoCdg57M6WCLyaTQ3VPYsCc4t529wCffFYW
wDP9QgpddSftLOTQnzAr+Jk=
=WGnF
-----END PGP SIGNATURE-----

--OXfL5xGRrasGEqWY--
