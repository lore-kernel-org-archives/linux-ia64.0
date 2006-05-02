From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Tue, 02 May 2006 05:25:51 +0000
Subject: [RFC 1/3] LVHPT - Fault handler modifications
Message-Id: <20060502052551.8990.16410.sendpatchset@wagner.orchestra.cse.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060502052546.8990.33000.sendpatchset@wagner.orchestra.cse.unsw.EDU.AU>
In-Reply-To: <20060502052546.8990.33000.sendpatchset@wagner.orchestra.cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org
Cc: linux-mm@kvack.org, Ian Wienand <ianw@gelato.unsw.edu.au>

Fault handler changes

The logic behind the two fault paths is graphically layed out

http://www.gelato.unsw.edu.au/IA64wiki/TLBMissFlowchart

Firstly, we have stripped out common code in ivt.S into assembler
macros in ivt-macro.S.  The comments before the macros should explain
what each is doing.

The main changes are

vhpt_miss can no longer happen.  This fault is only raised when the
walker does not have a mapping for the hashed address; with lvhpt the
hash table is pinned with a single entry.

i/dtlb_miss now has to walk the page tables so that we can insert the
translation into the lvhpt.  With short-format the code references the
hashed address, and if the hashed address was not mapped (e.g. a
mapping pointing to a page of PTE entries did not cover it) it would
raise the nested_dtlb_miss handler, which would then walk the page
table and insert a translation for that page of PTE's.  However, we
can now no-longer fall into nested_dtlb_miss since the VHPT is always
mapped.

The only other changes are updating the VHPT in fairly obvious places
to make sure it is up to date.

Signed-Off-By: Ian Wienand <ianw@gelato.unsw.edu.au>

---

 arch/ia64/kernel/ivt.S       |  152 ++++++++++++------------------
 include/asm-ia64/ivt-macro.S |  213 ++++++++++++++++++++++++++++++++++++++=
+++++
 2 files changed, 277 insertions(+), 88 deletions(-)

Index: linux-2.6.17-rc3-lvhpt/arch/ia64/kernel/ivt.S
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.17-rc3-lvhpt.orig/arch/ia64/kernel/iv=
t.S	2006-05-02 15:12:35.000000000 +1000
+++ linux-2.6.17-rc3-lvhpt/arch/ia64/kernel/ivt.S	2006-05-02 15:13:23.00000=
0000 +1000
@@ -53,6 +53,9 @@
 #include <asm/unistd.h>
 #include <asm/errno.h>
=20
+/* Generic macros that can be used in multiple places */
+#include <asm/ivt-macro.S>
+=09
 #if 1
 # define PSR_DEFAULT_BITS	psr.ac
 #else
@@ -103,6 +106,13 @@
 	 *	- the faulting virtual address uses unimplemented address bits
 	 *	- the faulting virtual address has no valid page table mapping
 	 */
+
+	/* With LVHPT this fault should not occur, since we have it
+	 * permanently mapped
+	 */
+#ifdef CONFIG_IA64_LONG_FORMAT_VHPT
+	FAULT(0)
+#else
 	mov r16=3Dcr.ifa				// get address that caused the TLB miss
 #ifdef CONFIG_HUGETLB_PAGE
 	movl r18=3DPAGE_SHIFT
@@ -236,6 +246,7 @@
=20
 	mov pr=3Dr31,-1				// restore predicate registers
 	rfi
+#endif /* !CONFIG_IA64_LONG_FORMAT_VHPT */
 END(vhpt_miss)
=20
 	.org ia64_ivt+0x400
@@ -253,15 +264,13 @@
 	mov r29=B0				// save b0
 	mov r31=3Dpr				// save predicates
 .itlb_fault:
-	mov r17=3Dcr.iha				// get virtual address of PTE
-	movl r30=1F				// load nested fault continuation point
-	;;
-1:	ld8 r18=3D[r17]				// read *pte
-	;;
-	mov b0=3Dr29
-	tbit.z p6,p0=3Dr18,_PAGE_P_BIT		// page present bit cleared?
-(p6)	br.cond.spnt page_fault
+#ifdef CONFIG_IA64_LONG_FORMAT_VHPT
+	LOAD_PTE_MISS r16, r17, r18, r22, page_fault
 	;;
+	VHPT_INSERT r16, r17, r18, r22
+#else
+	LOAD_PTE_MISS r17, r18, page_fault
+#endif
 	itc.i r18
 	;;
 #ifdef CONFIG_SMP
@@ -276,6 +285,7 @@
 	;;
 	cmp.ne p7,p0=3Dr18,r19
 	;;
+	VHPT_PURGE p7, r22
 (p7)	ptc.l r16,r20
 #endif
 	mov pr=3Dr31,-1
@@ -296,16 +306,15 @@
 	mov r16=3Dcr.ifa				// get virtual address
 	mov r29=B0				// save b0
 	mov r31=3Dpr				// save predicates
-dtlb_fault:
-	mov r17=3Dcr.iha				// get virtual address of PTE
-	movl r30=1F				// load nested fault continuation point
-	;;
-1:	ld8 r18=3D[r17]				// read *pte
+.dtlb_fault:
+#ifdef CONFIG_IA64_LONG_FORMAT_VHPT
+	LOAD_PTE_MISS r16, r17, r18, r22, page_fault
 	;;
-	mov b0=3Dr29
-	tbit.z p6,p0=3Dr18,_PAGE_P_BIT		// page present bit cleared?
-(p6)	br.cond.spnt page_fault
+	VHPT_INSERT r16, r17, r18, r22
+#else
+	LOAD_PTE_MISS r17, r18, page_fault
 	;;
+#endif
 	itc.d r18
 	;;
 #ifdef CONFIG_SMP
@@ -320,6 +329,7 @@
 	;;
 	cmp.ne p7,p0=3Dr18,r19
 	;;
+	VHPT_PURGE p7, r22
 (p7)	ptc.l r16,r20
 #endif
 	mov pr=3Dr31,-1
@@ -436,59 +446,17 @@
 	 *
 	 * Clobbered:	b0, r18, r19, r21, r22, psr.dt (cleared)
 	 */
-	rsm psr.dt				// switch to using physical data addressing
-	mov r19=3DIA64_KR(PT_BASE)		// get the page table base address
-	shl r21=3Dr16,3				// shift bit 60 into sign bit
-	mov r18=3Dcr.itir
-	;;
-	shr.u r17=3Dr16,61			// get the region number into r17
-	extr.u r18=3Dr18,2,6			// get the faulting page size
-	;;
-	cmp.eq p6,p7=3D5,r17			// is faulting address in region 5?
-	add r22=3D-PAGE_SHIFT,r18			// adjustment for hugetlb address
-	add r18=3DPGDIR_SHIFT-PAGE_SHIFT,r18
-	;;
-	shr.u r22=3Dr16,r22
-	shr.u r18=3Dr16,r18
-(p7)	dep r17=3Dr17,r19,(PAGE_SHIFT-3),3	// put region number bits in place
=20
-	srlz.d
-	LOAD_PHYSICAL(p6, r19, swapper_pg_dir)	// region 5 is rooted at swapper_p=
g_dir
-
-	.pred.rel "mutex", p6, p7
-(p6)	shr.u r21=3Dr21,PGDIR_SHIFT+PAGE_SHIFT
-(p7)	shr.u r21=3Dr21,PGDIR_SHIFT+PAGE_SHIFT-3
-	;;
-(p6)	dep r17=3Dr18,r19,3,(PAGE_SHIFT-3)	// r17=3Dpgd_offset for region 5
-(p7)	dep r17=3Dr18,r17,3,(PAGE_SHIFT-6)	// r17=3Dpgd_offset for region[0-4]
-	cmp.eq p7,p6=3D0,r21			// unused address bits all zeroes?
-#ifdef CONFIG_PGTABLE_4
-	shr.u r18=3Dr22,PUD_SHIFT			// shift pud index into position
+	/* This fault should not happen with LVHPT */
+#ifdef CONFIG_IA64_LONG_FORMAT_VHPT
+	DBG_FAULT(5)
+	FAULT(5)
 #else
-	shr.u r18=3Dr22,PMD_SHIFT			// shift pmd index into position
-#endif
-	;;
-	ld8 r17=3D[r17]				// get *pgd (may be 0)
-	;;
-(p7)	cmp.eq p6,p7=3Dr17,r0			// was pgd_present(*pgd) =3D NULL?
-	dep r17=3Dr18,r17,3,(PAGE_SHIFT-3)	// r17=3Dp[u|m]d_offset(pgd,addr)
-	;;
-#ifdef CONFIG_PGTABLE_4
-(p7)	ld8 r17=3D[r17]				// get *pud (may be 0)
-	shr.u r18=3Dr22,PMD_SHIFT			// shift pmd index into position
-	;;
-(p7)	cmp.eq.or.andcm p6,p7=3Dr17,r0		// was pud_present(*pud) =3D NULL?
-	dep r17=3Dr18,r17,3,(PAGE_SHIFT-3)	// r17=3Dpmd_offset(pud,addr)
-	;;
-#endif
-(p7)	ld8 r17=3D[r17]				// get *pmd (may be 0)
-	shr.u r19=3Dr22,PAGE_SHIFT		// shift pte index into position
-	;;
-(p7)	cmp.eq.or.andcm p6,p7=3Dr17,r0		// was pmd_present(*pmd) =3D NULL?
-	dep r17=3Dr19,r17,3,(PAGE_SHIFT-3)	// r17=3Dpte_offset(pmd,addr);
+	FIND_PTE r16, r17, p6, p7
 (p6)	br.cond.spnt page_fault
 	mov b0=3Dr30
 	br.sptk.many b0				// return to continuation point
+#endif
 END(nested_dtlb_miss)
=20
 	.org ia64_ivt+0x1800
@@ -548,16 +516,16 @@
 	 * page table TLB entry isn't present, we take a nested TLB miss hit wher=
e we look
 	 * up the physical address of the L3 PTE and then continue at label 1 bel=
ow.
 	 */
-	mov r16=3Dcr.ifa				// get the address that caused the fault
-	movl r30=1F				// load continuation point in case of nested fault
-	;;
-	thash r17=3Dr16				// compute virtual address of L3 PTE
 	mov r29=B0				// save b0 in case of nested fault
 	mov r31=3Dpr				// save pr
+	;;=20
+#ifdef CONFIG_IA64_LONG_FORMAT_VHPT
+	LOAD_PTE_FAULT r16, r17, r18, r22, .dtlb_fault
+#else
+	LOAD_PTE_FAULT r16, r17, r18
+#endif
 #ifdef CONFIG_SMP
 	mov r28=3Dar.ccv				// save ar.ccv
-	;;
-1:	ld8 r18=3D[r17]
 	;;					// avoid RAW on r18
 	mov ar.ccv=3Dr18				// set compare value for cmpxchg
 	or r25=3D_PAGE_D|_PAGE_A,r18		// set the dirty and accessed bits
@@ -568,6 +536,7 @@
 	;;
 (p6)	cmp.eq p6,p7=3Dr26,r18			// Only compare if page is present
 	;;
+	VHPT_UPDATE p6, r18, r22
 (p6)	itc.d r25				// install updated PTE
 	;;
 	/*
@@ -580,17 +549,17 @@
 	;;
 	cmp.eq p6,p7=3Dr18,r25			// is it same as the newly installed
 	;;
+	VHPT_PURGE p7, r22
 (p7)	ptc.l r16,r24
 	mov b0=3Dr29				// restore b0
 	mov ar.ccv=3Dr28
 #else
-	;;
-1:	ld8 r18=3D[r17]
 	;;					// avoid RAW on r18
 	or r18=3D_PAGE_D|_PAGE_A,r18		// set the dirty and accessed bits
 	mov b0=3Dr29				// restore b0
 	;;
 	st8 [r17]=3Dr18				// store back updated PTE
+	VHPT_UPDATE p0, r18, r22
 	itc.d r18				// install updated PTE
 #endif
 	mov pr=3Dr31,-1				// restore pr
@@ -604,7 +573,7 @@
 	DBG_FAULT(9)
 	// Like Entry 8, except for instruction access
 	mov r16=3Dcr.ifa				// get the address that caused the fault
-	movl r30=1F				// load continuation point in case of nested fault
+	mov r29=B0
 	mov r31=3Dpr				// save predicates
 #ifdef CONFIG_ITANIUM
 	/*
@@ -618,13 +587,16 @@
 (p6)	mov r16=3Dr18				// if so, use cr.iip instead of cr.ifa
 #endif /* CONFIG_ITANIUM */
 	;;
-	thash r17=3Dr16				// compute virtual address of L3 PTE
-	mov r29=B0				// save b0 in case of nested fault)
+#ifdef CONFIG_IA64_LONG_FORMAT_VHPT
+	LOAD_PTE_FAULT r16, r17, r18, r22, .itlb_fault
+#else
+	LOAD_PTE_FAULT r16, r17, r18
+#endif
+	;;
+	mov b0=3Dr29				// restore b0
 #ifdef CONFIG_SMP
 	mov r28=3Dar.ccv				// save ar.ccv
 	;;
-1:	ld8 r18=3D[r17]
-	;;
 	mov ar.ccv=3Dr18				// set compare value for cmpxchg
 	or r25=3D_PAGE_A,r18			// set the accessed bit
 	tbit.z p7,p6 =3D r18,_PAGE_P_BIT	 	// Check present bit
@@ -646,17 +618,17 @@
 	;;
 	cmp.eq p6,p7=3Dr18,r25			// is it same as the newly installed
 	;;
+	VHPT_PURGE p7, r22
 (p7)	ptc.l r16,r24
 	mov b0=3Dr29				// restore b0
 	mov ar.ccv=3Dr28
 #else /* !CONFIG_SMP */
 	;;
-1:	ld8 r18=3D[r17]
-	;;
 	or r18=3D_PAGE_A,r18			// set the accessed bit
 	mov b0=3Dr29				// restore b0
 	;;
 	st8 [r17]=3Dr18				// store back updated PTE
+	VHPT_UPDATE p0, r18, r22
 	itc.i r18				// install updated PTE
 #endif /* !CONFIG_SMP */
 	mov pr=3Dr31,-1
@@ -670,15 +642,16 @@
 	DBG_FAULT(10)
 	// Like Entry 8, except for data access
 	mov r16=3Dcr.ifa				// get the address that caused the fault
-	movl r30=1F				// load continuation point in case of nested fault
-	;;
-	thash r17=3Dr16				// compute virtual address of L3 PTE
-	mov r31=3Dpr
 	mov r29=B0				// save b0 in case of nested fault)
+	mov r31=3Dpr
+	;;=20
+#ifdef CONFIG_IA64_LONG_FORMAT_VHPT
+	LOAD_PTE_FAULT r16, r17, r18, r22, .dtlb_fault
+#else
+	LOAD_PTE_FAULT r16, r17, r18
+#endif
 #ifdef CONFIG_SMP
 	mov r28=3Dar.ccv				// save ar.ccv
-	;;
-1:	ld8 r18=3D[r17]
 	;;					// avoid RAW on r18
 	mov ar.ccv=3Dr18				// set compare value for cmpxchg
 	or r25=3D_PAGE_A,r18			// set the dirty bit
@@ -689,6 +662,7 @@
 	;;
 (p6)	cmp.eq p6,p7=3Dr26,r18			// Only if page is present
 	;;
+	VHPT_UPDATE p6, r18, r22
 (p6)	itc.d r25				// install updated PTE
 	/*
 	 * Tell the assemblers dependency-violation checker that the above "itc" =
instructions
@@ -700,19 +674,21 @@
 	;;
 	cmp.eq p6,p7=3Dr18,r25			// is it same as the newly installed
 	;;
+	VHPT_PURGE p7, r22
 (p7)	ptc.l r16,r24
+	mov b0=3Dr29				// restore b0
 	mov ar.ccv=3Dr28
 #else
-	;;
-1:	ld8 r18=3D[r17]
 	;;					// avoid RAW on r18
 	or r18=3D_PAGE_A,r18			// set the accessed bit
 	;;
 	st8 [r17]=3Dr18				// store back updated PTE
+	VHPT_UPDATE p0, r18, r22
 	itc.d r18				// install updated PTE
 #endif
-	mov b0=3Dr29				// restore b0
 	mov pr=3Dr31,-1
+	;;
+	mov b0=3Dr29				// restore b0
 	rfi
 END(daccess_bit)
=20
Index: linux-2.6.17-rc3-lvhpt/include/asm-ia64/ivt-macro.S
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.17-rc3-lvhpt/include/asm-ia64/ivt-macro.S	2006-05-02 15:09:48=
.000000000 +1000
@@ -0,0 +1,213 @@
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
+ * FIND_PTE=20
+ * Walks the page table to find a PTE
+ * @va,		register holding virtual address
+ * @ppte, 	register with pointer to page table entry
+ * @p1,		predicate set if found
+ * @p2,		predicate set if !found
+ */
+.macro find_pte va, ppte, p1, p2
+	rsm psr.dt				// switch to using physical data addressing
+	mov r19=3DIA64_KR(PT_BASE)		// get the page table base address
+	shl r21=3D\va,3				// shift bit 60 into sign bit
+	mov r18=3Dcr.itir
+	;;
+	shr.u \ppte=3D\va,61			// get the region number into ppte
+	extr.u r18=3Dr18,2,6			// get the faulting page size
+	;;
+	cmp.eq \p1,\p2=3D5,\ppte			// is faulting address in region 5?
+	add r22=3D-PAGE_SHIFT,r18			// adjustment for hugetlb address
+	add r18=3DPGDIR_SHIFT-PAGE_SHIFT,r18
+	;;
+	shr.u r22=3D\va,r22
+	shr.u r18=3D\va,r18
+(\p2)	dep \ppte=3D\ppte,r19,(PAGE_SHIFT-3),3	// put region number bits in =
place
+
+	srlz.d
+	LOAD_PHYSICAL(\p1, r19, swapper_pg_dir)	// region 5 is rooted at swapper_=
pg_dir
+
+	.pred.rel "mutex", \p1, \p2
+(\p1)	shr.u r21=3Dr21,PGDIR_SHIFT+PAGE_SHIFT
+(\p2)	shr.u r21=3Dr21,PGDIR_SHIFT+PAGE_SHIFT-3
+	;;
+(\p1)	dep \ppte=3Dr18,r19,3,(PAGE_SHIFT-3)	// ppte=3Dpgd_offset for region=
 5
+(\p2)	dep \ppte=3Dr18,\ppte,3,(PAGE_SHIFT-3)-3	// ppte=3Dpgd_offset for re=
gion[0-4]
+	cmp.eq \p2,\p1=3D0,r21			// unused address bits all zeroes?
+#ifdef CONFIG_PGTABLE_4
+	shr.u r18=3Dr22,PUD_SHIFT			// shift pud index into position
+#else
+	shr.u r18=3Dr22,PMD_SHIFT			// shift pmd index into position
+#endif
+	;;
+	ld8 \ppte=3D[\ppte]			// get *pgd (may be 0)
+	;;
+(\p2)	cmp.eq \p1,\p2=3D\ppte,r0			// was pgd_present(*pgd) =3D NULL?
+	dep \ppte=3Dr18,\ppte,3,(PAGE_SHIFT-3)	// ppte=3Dp[u|m]d_offset(pgd,addr)
+	;;=20
+#ifdef CONFIG_PGTABLE_4
+(\p2)	ld8 \ppte=3D[\ppte]			// get *pud (may be 0)
+	shr.u r18=3Dr22,PMD_SHIFT			// shift pmd index into position
+	;;=20
+(\p2)	cmp.eq.or.andcm \p1,\p2=3D\ppte,r0	// was pud_present(*pud) =3D NULL?
+	dep \ppte=3Dr18,\ppte,3,(PAGE_SHIFT-3)	// ppte=3Dpmd_offset(pud,addr)
+	;;
+#endif
+(\p2)	ld8 \ppte=3D[\ppte]			// get *pmd (may be 0)
+	shr.u r19=3Dr22,PAGE_SHIFT		// shift pte index into position
+	;;
+(\p2)	cmp.eq.or.andcm \p1,\p2=3D\ppte,r0	// was pmd_present(*pmd) =3D NULL?
+	dep \ppte=3Dr19,\ppte,3,(PAGE_SHIFT-3)	// ppte=3Dpte_offset(pmd,addr)
+.endm
+
+
+#ifdef CONFIG_IA64_LONG_FORMAT_VHPT
+/*
+ * LOAD_PTE_MISS - load pte into tlb and VHPT
+ *    @va,   virtual address
+ *    @ppte, pointer to the page table entry
+ *    @pte,  actual pte
+ *    @hpte, hash page table entry
+ *
+ *    Given a va get the ppte and load its value into pte
+ */
+.macro load_pte_miss va, ppte, pte, hpte, failfn			=09
+	;;										=09
+	FIND_PTE \va, \ppte, p6, p7
+	;;
+(p7)	ld8 \pte=3D[\ppte]
+	;;
+(p7)	tbit.z p6,p0=3D\pte,_PAGE_P_BIT		/* page present bit cleared? */
+(p6)	br.cond.spnt \failfn
+.endm
+=09
+/* Since we access the page table physically, we access the long VHPT phys=
ically as well
+ * to avoid switching back and forth */
+
+/*
+ * LOAD_PTE_FAULT - get the pte entry from the VHPT for va
+ *    @va,     virtual address to resolve
+ *    @ppte,   pointer to the page table entry
+ *    @pte,    page table entry
+ *    @hpte,   store pte in this hash page table entry
+ *    @failfn, function called if fault not resolved
+ *
+ *    Retrieve the pte via the hashed page table and store it in pte=3Dr18
+ *    r25 =3D tag
+ *    r26 =3D htag
+ */
+
+.macro load_pte_fault va, ppte, pte, hpte, failfn
+	thash r28=3D\va
+	rsm psr.dt
+	;;										=09
+	tpa \hpte=3Dr28		// make hash address physical
+	ttag r25=3D\va
+	;;								=09
+	srlz.d
+	add r24=16,\hpte
+	add \ppte$,\hpte
+	;;
+	ld8 r26=3D[r24]		// load tag
+	ld8 \ppte=3D[\ppte]			=09
+	;;
+	cmp.ne p6,p7=3Dr26, r25	// verify tag
+	;;
+(p7)	ld8 \pte=3D[\ppte]
+	;;
+(p6)    mov cr.iha=3Dr28	 	// set cr.iha only if we are going to take
+(p6)	br.cond.spnt \failfn	// the failfn fault, it depends on it
+.endm
+=09
+/*
+ * VHPT_INSERT -
+ *    @va,   virtual address to be inserted
+ *    @ppte, pointer to the page table entry
+ *    @pte,  page table entry to be inserted
+ *    @hpte, insert pte into this hash page table entry
+ *
+ *    Insert the va into the VHPT and tlb, the tlb insert
+ *    happens in ivt.S for the appropriate fault instruction or data.
+ */
+.macro vhpt_insert va, ppte, pte, hpte
+	mov \hpte=3Dcr.iha
+	mov r26=3Dcr.itir
+	;;
+	tpa \hpte=3D\hpte		/* make hash address physical */
+	ttag r25=3D\va
+	;;
+	add r24=16,\hpte
+	;;
+	st8 [\hpte]=3D\pte,8	/* fill out VHPT entry */
+	st8 [r24]=3Dr25,8
+	;;
+	st8 [\hpte]=3Dr26,8
+	st8 [r24]=3D\ppte
+.endm
+
+/*
+ * Update the VHPT with pte value obtained from LOAD_PTE_FAULT
+ */
+.macro vhpt_update cond, pte, hpte
+(\cond)	st8 [\hpte]=3D\pte,16
+.endm
+=09
+/*
+ * Invalidate the tlb for the VHPT pointing to hpte, this is achieved by
+ * setting the invalid tag bit(63) in the VHPT tag field. A VHPT entry with
+ * ti bit set to one will never be inserted into a processor's TLBs.
+ *
+ */
+.macro vhpt_purge cond, hpte
+(\cond)	dep r25=3D-1,r0,63,1	/* set tag-invalid bit */
+;;
+(\cond)	st8 [\hpte]=3Dr25		/* hpte already points to tag (see above) */
+.endm
+
+#else /* !CONFIG_IA64_LONG_FORMAT_VHPT */
+
+/*
+ * LOAD_PTE_MISS=20
+ * Get a PTE based on the hardware walker's miss address,
+ * branch to the failfn if we can't find it
+ * @ppte,	pointer to page table entry
+ * @pte,	actual pte
+ * @failfn	function to call if PTE not present
+ */
+.macro load_pte_miss ppte, pte, failfn
+	mov \ppte=3Dcr.iha			// get virtual address of L3 PTE
+	movl r30=1F				// load nested fault continuation point
+	;;
+1:	ld8 \pte=3D[\ppte]			// read L3 PTE
+	;;
+	mov b0=3Dr29
+	tbit.z p6,p0=3D\pte,_PAGE_P_BIT		// page present bit cleared?
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
+	thash \ppte=3D\va				// get virtual address of L3
+	movl r30=1F				// load continuation for nested_dtlb_miss
+	;;
+1:	ld8 \pte=3D[\ppte]
+.endm
+
+#endif /* CONFIG_IA64_LONG_FORMAT_VHPT */
