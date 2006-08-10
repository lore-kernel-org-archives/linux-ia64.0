From: Al Stone <ahs3@fc.hp.com>
Date: Thu, 10 Aug 2006 00:16:18 +0000
Subject: [PATCH] reformat ivt.S for 80-column use
Message-Id: <1155168978.12634.62.camel@deimos>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

So, my first patch for this list....please be gentle with me :).

I was having to read ivt.S quite a bit and the old formatting
just finally got to me; this patch rearranges comments so that
everything can be seen on an 80-column display, in line with
Linux coding style.  No instructions have been changed.  With
any luck, I didn't screw up any of the white space otherwise.


Signed-off-by: Al Stone <ahs3@fc.hp.com>

diff --git a/arch/ia64/kernel/ivt.S b/arch/ia64/kernel/ivt.S
index 6b7fcbd..d4ac622 100644
--- a/arch/ia64/kernel/ivt.S
+++ b/arch/ia64/kernel/ivt.S
@@ -11,7 +11,8 @@
  *      Fenghua Yu <fenghua.yu@intel.com>
  *
  * 00/08/23 Asit Mallick <asit.k.mallick@intel.com> TLB handling for SMP
- * 00/12/20 David Mosberger-Tang <davidm@hpl.hp.com> DTLB/ITLB handler now=
 uses virtual PT.
+ * 00/12/20 David Mosberger-Tang <davidm@hpl.hp.com> DTLB/ITLB handler now
+ *          uses virtual PT.
  */
 /*
  * This file defines the interruption vector table used by the CPU.
@@ -60,19 +61,23 @@ #endif
=20
 #if 0
   /*
-   * This lets you track the last eight faults that occurred on the CPU.  =
Make sure ar.k2 isn't
-   * needed for something else before enabling this...
+   * This lets you track the last eight faults that occurred on the CPU.  =

+   * Make sure ar.k2 isn't needed for something else before enabling this.=
..
    */
-# define DBG_FAULT(i)	mov r16=3Dar.k2;;	shl r16=3Dr16,8;;	add r16=3D(i),r1=
6;;mov ar.k2=3Dr16
+# define DBG_FAULT(i) 		\
+	mov r16=3Dar.k2;;		\
+	shl r16=3Dr16,8;;		\
+	add r16=3D(i),r16;;	\
+	mov ar.k2=3Dr16
 #else
 # define DBG_FAULT(i)
 #endif
=20
 #include "minstate.h"
=20
-#define FAULT(n)									\
-	mov r31=3Dpr;									\
-	mov r19=3Dn;;			/* prepare to save predicates */		\
+#define FAULT(n)							\
+	mov r31=3Dpr;							\
+	mov r19=3Dn;;		/* prepare to save predicates */	\
 	br.sptk.many dispatch_to_fault_handler
=20
 	.section .text.ivt,"ax"
@@ -80,39 +85,39 @@ #define FAULT(n)									\
 	.align 32768	// align on 32KB boundary
 	.global ia64_ivt
 ia64_ivt:
-//////////////////////////////////////////////////////////////////////////=
///////////////
+//////////////////////////////////////////////////////////////////////////
 // 0x0000 Entry 0 (size 64 bundles) VHPT Translation (8,20,47)
 ENTRY(vhpt_miss)
 	DBG_FAULT(0)
 	/*
-	 * The VHPT vector is invoked when the TLB entry for the virtual page tab=
le
-	 * is missing.  This happens only as a result of a previous
-	 * (the "original") TLB miss, which may either be caused by an instruction
-	 * fetch or a data access (or non-access).
+	 * The VHPT vector is invoked when the TLB entry for the virtual=20
+	 * page table is missing.  This happens only as a result of a=20
+	 * previous (the "original") TLB miss, which may either be caused
+	 * by an instruction fetch or a data access (or non-access).
 	 *
-	 * What we do here is normal TLB miss handing for the _original_ miss,
-	 * followed by inserting the TLB entry for the virtual page table page
-	 * that the VHPT walker was attempting to access.  The latter gets
-	 * inserted as long as page table entry above pte level have valid
-	 * mappings for the faulting address.  The TLB entry for the original
-	 * miss gets inserted only if the pte entry indicates that the page is
-	 * present.
+	 * What we do here is normal TLB miss handing for the _original_
+	 * miss, followed by inserting the TLB entry for the virtual page
+	 * table page that the VHPT walker was attempting to access.  The
+	 * latter gets inserted as long as page table entries above pte=20
+	 * level have valid mappings for the faulting address.  The TLB=20
+	 * entry for the original miss gets inserted only if the pte entry
+	 * indicates that the page is present.
 	 *
 	 * do_page_fault gets invoked in the following cases:
 	 *	- the faulting virtual address uses unimplemented address bits
 	 *	- the faulting virtual address has no valid page table mapping
 	 */
-	mov r16=3Dcr.ifa				// get address that caused the TLB miss
+	mov r16=3Dcr.ifa			// get address that caused the TLB miss
 #ifdef CONFIG_HUGETLB_PAGE
 	movl r18=3DPAGE_SHIFT
 	mov r25=3Dcr.itir
 #endif
 	;;
-	rsm psr.dt				// use physical addressing for data
-	mov r31=3Dpr				// save the predicate registers
-	mov r19=3DIA64_KR(PT_BASE)		// get page table base address
-	shl r21=3Dr16,3				// shift bit 60 into sign bit
-	shr.u r17=3Dr16,61			// get the region number into r17
+	rsm psr.dt			// use physical addressing for data
+	mov r31=3Dpr			// save the predicate registers
+	mov r19=3DIA64_KR(PT_BASE)	// get page table base address
+	shl r21=3Dr16,3			// shift bit 60 into sign bit
+	shr.u r17=3Dr16,61		// get the region number into r17
 	;;
 	shr.u r22=3Dr21,3
 #ifdef CONFIG_HUGETLB_PAGE
@@ -125,70 +130,77 @@ (p8)	dep r25=3Dr18,r25,2,6
 (p8)	shr r22=3Dr22,r27
 #endif
 	;;
-	cmp.eq p6,p7=3D5,r17			// is IFA pointing into to region 5?
-	shr.u r18=3Dr22,PGDIR_SHIFT		// get bottom portion of pgd index bit
+	cmp.eq p6,p7=3D5,r17		// is IFA pointing into to region 5?
+	shr.u r18=3Dr22,PGDIR_SHIFT	// get bottom portion of pgd index bit
 	;;
-(p7)	dep r17=3Dr17,r19,(PAGE_SHIFT-3),3	// put region number bits in place
+(p7)	dep r17=3Dr17,r19,(PAGE_SHIFT-3),3  // put region number bits in place
=20
 	srlz.d
-	LOAD_PHYSICAL(p6, r19, swapper_pg_dir)	// region 5 is rooted at swapper_p=
g_dir
+	LOAD_PHYSICAL(p6, r19, swapper_pg_dir) // region 5 is rooted at
+					       //   swapper_pg_dir
=20
 	.pred.rel "mutex", p6, p7
 (p6)	shr.u r21=3Dr21,PGDIR_SHIFT+PAGE_SHIFT
 (p7)	shr.u r21=3Dr21,PGDIR_SHIFT+PAGE_SHIFT-3
 	;;
-(p6)	dep r17=3Dr18,r19,3,(PAGE_SHIFT-3)	// r17=3Dpgd_offset for region 5
-(p7)	dep r17=3Dr18,r17,3,(PAGE_SHIFT-6)	// r17=3Dpgd_offset for region[0-4]
-	cmp.eq p7,p6=3D0,r21			// unused address bits all zeroes?
+(p6)	dep r17=3Dr18,r19,3,(PAGE_SHIFT-3)      // r17=3Dpgd_offset for regio=
n 5
+(p7)	dep r17=3Dr18,r17,3,(PAGE_SHIFT-6)      // r17=3Dpgd_offset for regio=
n[0-4]
+	cmp.eq p7,p6=3D0,r21		      // unused address bits all zeroes?
 #ifdef CONFIG_PGTABLE_4
-	shr.u r28=3Dr22,PUD_SHIFT			// shift pud index into position
+	shr.u r28=3Dr22,PUD_SHIFT		      // shift pud index into position
 #else
-	shr.u r18=3Dr22,PMD_SHIFT			// shift pmd index into position
+	shr.u r18=3Dr22,PMD_SHIFT		      // shift pmd index into position
 #endif
 	;;
-	ld8 r17=3D[r17]				// get *pgd (may be 0)
+	ld8 r17=3D[r17]			      // get *pgd (may be 0)
 	;;
-(p7)	cmp.eq p6,p7=3Dr17,r0			// was pgd_present(*pgd) =3D NULL?
+(p7)	cmp.eq p6,p7=3Dr17,r0		      // was pgd_present(*pgd) =3D NULL?
 #ifdef CONFIG_PGTABLE_4
-	dep r28=3Dr28,r17,3,(PAGE_SHIFT-3)	// r28=3Dpud_offset(pgd,addr)
+	dep r28=3Dr28,r17,3,(PAGE_SHIFT-3)      // r28=3Dpud_offset(pgd,addr)
 	;;
-	shr.u r18=3Dr22,PMD_SHIFT			// shift pmd index into position
-(p7)	ld8 r29=3D[r28]				// get *pud (may be 0)
+	shr.u r18=3Dr22,PMD_SHIFT		      // shift pmd index into position
+(p7)	ld8 r29=3D[r28]			      // get *pud (may be 0)
 	;;
-(p7)	cmp.eq.or.andcm p6,p7=3Dr29,r0		// was pud_present(*pud) =3D NULL?
-	dep r17=3Dr18,r29,3,(PAGE_SHIFT-3)	// r17=3Dpmd_offset(pud,addr)
+(p7)	cmp.eq.or.andcm p6,p7=3Dr29,r0	      // was pud_present(*pud) =3D NUL=
L?
+	dep r17=3Dr18,r29,3,(PAGE_SHIFT-3)      // r17=3Dpmd_offset(pud,addr)
 #else
-	dep r17=3Dr18,r17,3,(PAGE_SHIFT-3)	// r17=3Dpmd_offset(pgd,addr)
+	dep r17=3Dr18,r17,3,(PAGE_SHIFT-3)      // r17=3Dpmd_offset(pgd,addr)
 #endif
 	;;
-(p7)	ld8 r20=3D[r17]				// get *pmd (may be 0)
-	shr.u r19=3Dr22,PAGE_SHIFT		// shift pte index into position
-	;;
-(p7)	cmp.eq.or.andcm p6,p7=3Dr20,r0		// was pmd_present(*pmd) =3D NULL?
-	dep r21=3Dr19,r20,3,(PAGE_SHIFT-3)	// r21=3Dpte_offset(pmd,addr)
-	;;
-(p7)	ld8 r18=3D[r21]				// read *pte
-	mov r19=3Dcr.isr				// cr.isr bit 32 tells us if this is an insn miss
-	;;
-(p7)	tbit.z p6,p7=3Dr18,_PAGE_P_BIT		// page present bit cleared?
-	mov r22=3Dcr.iha				// get the VHPT address that caused the TLB miss
-	;;					// avoid RAW on p7
-(p7)	tbit.nz.unc p10,p11=3Dr19,32		// is it an instruction TLB miss?
-	dep r23=3D0,r20,0,PAGE_SHIFT		// clear low bits to get page address
-	;;
-(p10)	itc.i r18				// insert the instruction TLB entry
-(p11)	itc.d r18				// insert the data TLB entry
-(p6)	br.cond.spnt.many page_fault		// handle bad address/page not present =
(page fault)
+(p7)	ld8 r20=3D[r17]			      // get *pmd (may be 0)
+	shr.u r19=3Dr22,PAGE_SHIFT	      // shift pte index into position
+	;;
+(p7)	cmp.eq.or.andcm p6,p7=3Dr20,r0	      // was pmd_present(*pmd) =3D NUL=
L?
+	dep r21=3Dr19,r20,3,(PAGE_SHIFT-3)      // r21=3Dpte_offset(pmd,addr)
+	;;
+(p7)	ld8 r18=3D[r21]			      // read *pte
+	mov r19=3Dcr.isr			      // cr.isr bit 32 tells us if=20
+					      // this is an insn miss
+	;;
+(p7)	tbit.z p6,p7=3Dr18,_PAGE_P_BIT	      // page present bit cleared?
+	mov r22=3Dcr.iha			      // get the VHPT address that=20
+					      //   caused the TLB miss
+	;;				      // avoid RAW on p7
+(p7)	tbit.nz.unc p10,p11=3Dr19,32	      // is it an instruction TLB miss?
+	dep r23=3D0,r20,0,PAGE_SHIFT	      // clear low bits to get page=20
+					      //   address
+	;;
+(p10)	itc.i r18			      // insert the instruction TLB=20
+					      // entry
+(p11)	itc.d r18			      // insert the data TLB entry
+(p6)	br.cond.spnt.many page_fault	      // handle bad address/page not=20
+					      //   present (page fault)
 	mov cr.ifa=3Dr22
=20
 #ifdef CONFIG_HUGETLB_PAGE
-(p8)	mov cr.itir=3Dr25				// change to default page-size for VHPT
+(p8)	mov cr.itir=3Dr25			      // change to default page-size
+					      //   for VHPT
 #endif
=20
 	/*
-	 * Now compute and insert the TLB entry for the virtual page table.  We n=
ever
-	 * execute in a page table page so there is no need to set the exception =
deferral
-	 * bit.
+	 * Now compute and insert the TLB entry for the virtual page table.
+	 * We never execute in a page table page so there is no need to set=20
+	 * the exception deferral bit.
 	 */
 	adds r24=3D__DIRTY_BITS_NO_ED|_PAGE_PL_0|_PAGE_AR_RW,r23
 	;;
@@ -196,15 +208,15 @@ (p7)	itc.d r24
 	;;
 #ifdef CONFIG_SMP
 	/*
-	 * Tell the assemblers dependency-violation checker that the above "itc" =
instructions
-	 * cannot possibly affect the following loads:
+	 * Tell the assemblers dependency-violation checker that the above
+	 * "itc" instructions cannot possibly affect the following loads:
 	 */
 	dv_serialize_data
=20
 	/*
-	 * Re-check pagetable entry.  If they changed, we may have received a ptc=
.g
-	 * between reading the pagetable and the "itc".  If so, flush the entry we
-	 * inserted and retry.  At this point, we have:
+	 * Re-check pagetable entry.  If they changed, we may have received
+	 * a ptc.g between reading the pagetable and the "itc".  If so, flush
+	 * the entry we inserted and retry.  At this point, we have:
 	 *
 	 * r28 =3D equivalent of pud_offset(pgd, ifa)
 	 * r17 =3D equivalent of pmd_offset(pud, ifa)
@@ -238,7 +250,7 @@ #endif
 END(vhpt_miss)
=20
 	.org ia64_ivt+0x400
-//////////////////////////////////////////////////////////////////////////=
///////////////
+//////////////////////////////////////////////////////////////////////////
 // 0x0400 Entry 1 (size 64 bundles) ITLB (21)
 ENTRY(itlb_miss)
 	DBG_FAULT(1)
@@ -253,7 +265,8 @@ ENTRY(itlb_miss)
 	mov r31=3Dpr				// save predicates
 .itlb_fault:
 	mov r17=3Dcr.iha				// get virtual address of PTE
-	movl r30=1F				// load nested fault continuation point
+	movl r30=1F				// load nested fault=20
+						//   continuation point
 	;;
 1:	ld8 r18=3D[r17]				// read *pte
 	;;
@@ -265,13 +278,13 @@ (p6)	br.cond.spnt page_fault
 	;;
 #ifdef CONFIG_SMP
 	/*
-	 * Tell the assemblers dependency-violation checker that the above "itc" =
instructions
-	 * cannot possibly affect the following loads:
+	 * Tell the assemblers dependency-violation checker that the above
+	 * "itc" instructions cannot possibly affect the following loads:
 	 */
 	dv_serialize_data
=20
-	ld8 r19=3D[r17]				// read *pte again and see if same
-	mov r20=3DPAGE_SHIFT<<2			// setup page size for purge
+	ld8 r19=3D[r17]			// read *pte again and see if same
+	mov r20=3DPAGE_SHIFT<<2		// setup page size for purge
 	;;
 	cmp.ne p7,p0=3Dr18,r19
 	;;
@@ -282,7 +295,7 @@ #endif
 END(itlb_miss)
=20
 	.org ia64_ivt+0x0800
-//////////////////////////////////////////////////////////////////////////=
///////////////
+//////////////////////////////////////////////////////////////////////////
 // 0x0800 Entry 2 (size 64 bundles) DTLB (9,48)
 ENTRY(dtlb_miss)
 	DBG_FAULT(2)
@@ -297,7 +310,8 @@ ENTRY(dtlb_miss)
 	mov r31=3Dpr				// save predicates
 dtlb_fault:
 	mov r17=3Dcr.iha				// get virtual address of PTE
-	movl r30=1F				// load nested fault continuation point
+	movl r30=1F				// load nested fault=20
+						//   continuation point
 	;;
 1:	ld8 r18=3D[r17]				// read *pte
 	;;
@@ -309,13 +323,13 @@ (p6)	br.cond.spnt page_fault
 	;;
 #ifdef CONFIG_SMP
 	/*
-	 * Tell the assemblers dependency-violation checker that the above "itc" =
instructions
-	 * cannot possibly affect the following loads:
+	 * Tell the assemblers dependency-violation checker that the above
+	 * "itc" instructions cannot possibly affect the following loads:
 	 */
 	dv_serialize_data
=20
-	ld8 r19=3D[r17]				// read *pte again and see if same
-	mov r20=3DPAGE_SHIFT<<2			// setup page size for purge
+	ld8 r19=3D[r17]			// read *pte again and see if same
+	mov r20=3DPAGE_SHIFT<<2		// setup page size for purge
 	;;
 	cmp.ne p7,p0=3Dr18,r19
 	;;
@@ -326,7 +340,7 @@ #endif
 END(dtlb_miss)
=20
 	.org ia64_ivt+0x0c00
-//////////////////////////////////////////////////////////////////////////=
///////////////
+//////////////////////////////////////////////////////////////////////////
 // 0x0c00 Entry 3 (size 64 bundles) Alt ITLB (19)
 ENTRY(alt_itlb_miss)
 	DBG_FAULT(3)
@@ -337,14 +351,14 @@ ENTRY(alt_itlb_miss)
 	mov r31=3Dpr
 	;;
 #ifdef CONFIG_DISABLE_VHPT
-	shr.u r22=3Dr16,61			// get the region number into r21
+	shr.u r22=3Dr16,61		// get the region number into r21
 	;;
-	cmp.gt p8,p0=3D6,r22			// user mode
+	cmp.gt p8,p0=3D6,r22		// user mode
 	;;
 (p8)	thash r17=3Dr16
 	;;
 (p8)	mov cr.iha=3Dr17
-(p8)	mov r29=B0				// save b0
+(p8)	mov r29=B0			// save b0
 (p8)	br.cond.dptk .itlb_fault
 #endif
 	extr.u r23=3Dr21,IA64_PSR_CPL0_BIT,2	// extract psr.cpl
@@ -355,7 +369,8 @@ #endif
 	cmp.ne p8,p0=3Dr0,r23	// psr.cpl !=3D 0?
 	or r19=3Dr17,r19		// insert PTE control bits into r19
 	;;
-	or r19=3Dr19,r18		// set bit 4 (uncached) if the access was to region 6
+	or r19=3Dr19,r18		// set bit 4 (uncached) if the access was to=20
+				//   region 6
 (p8)	br.cond.spnt page_fault
 	;;
 	itc.i r19		// insert the TLB entry
@@ -364,7 +379,7 @@ (p8)	br.cond.spnt page_fault
 END(alt_itlb_miss)
=20
 	.org ia64_ivt+0x1000
-//////////////////////////////////////////////////////////////////////////=
///////////////
+//////////////////////////////////////////////////////////////////////////
 // 0x1000 Entry 4 (size 64 bundles) Alt DTLB (7,46)
 ENTRY(alt_dtlb_miss)
 	DBG_FAULT(4)
@@ -376,21 +391,22 @@ ENTRY(alt_dtlb_miss)
 	mov r31=3Dpr
 	;;
 #ifdef CONFIG_DISABLE_VHPT
-	shr.u r22=3Dr16,61			// get the region number into r21
+	shr.u r22=3Dr16,61		// get the region number into r21
 	;;
-	cmp.gt p8,p0=3D6,r22			// access to region 0-5
+	cmp.gt p8,p0=3D6,r22		// access to region 0-5
 	;;
 (p8)	thash r17=3Dr16
 	;;
 (p8)	mov cr.iha=3Dr17
-(p8)	mov r29=B0				// save b0
+(p8)	mov r29=B0			// save b0
 (p8)	br.cond.dptk dtlb_fault
 #endif
 	extr.u r23=3Dr21,IA64_PSR_CPL0_BIT,2	// extract psr.cpl
 	and r22=3DIA64_ISR_CODE_MASK,r20		// get the isr.code field
 	tbit.nz p6,p7=3Dr20,IA64_ISR_SP_BIT	// is speculation bit on?
 	shr.u r18=3Dr16,57			// move address bit 61 to bit 4
-	and r19=3Dr19,r16				// clear ed, reserved bits, and PTE control bits
+	and r19=3Dr19,r16				// clear ed, reserved bits, and
+						//   PTE control bits
 	tbit.nz p9,p0=3Dr20,IA64_ISR_NA_BIT	// is non-access bit on?
 	;;
 	andcm r18=3D0x10,r18	// bit 4=3D~address-bit(61)
@@ -401,7 +417,8 @@ (p8)	br.cond.spnt page_fault
 	dep r21=3D-1,r21,IA64_PSR_ED_BIT,1
 	or r19=3Dr19,r17		// insert PTE control bits into r19
 	;;
-	or r19=3Dr19,r18		// set bit 4 (uncached) if the access was to region 6
+	or r19=3Dr19,r18		// set bit 4 (uncached) if the access was to
+				//   region 6
 (p6)	mov cr.ipsr=3Dr21
 	;;
 (p7)	itc.d r19		// insert the TLB entry
@@ -410,18 +427,19 @@ (p7)	itc.d r19		// insert the TLB entry
 END(alt_dtlb_miss)
=20
 	.org ia64_ivt+0x1400
-//////////////////////////////////////////////////////////////////////////=
///////////////
+//////////////////////////////////////////////////////////////////////////
 // 0x1400 Entry 5 (size 64 bundles) Data nested TLB (6,45)
 ENTRY(nested_dtlb_miss)
 	/*
-	 * In the absence of kernel bugs, we get here when the virtually mapped l=
inear
-	 * page table is accessed non-speculatively (e.g., in the Dirty-bit, Inst=
ruction
-	 * Access-bit, or Data Access-bit faults).  If the DTLB entry for the vir=
tual page
-	 * table is missing, a nested TLB miss fault is triggered and control is
-	 * transferred to this point.  When this happens, we lookup the pte for t=
he
-	 * faulting address by walking the page table in physical mode and return=
 to the
-	 * continuation point passed in register r30 (or call page_fault if the a=
ddress is
-	 * not mapped).
+	 * In the absence of kernel bugs, we get here when the virtually
+	 * mapped linear page table is accessed non-speculatively (e.g.,=20
+	 * in the Dirty-bit, Instruction Access-bit, or Data Access-bit=20
+	 * faults).  If the DTLB entry for the virtual page table is missing,
+	 * a nested TLB miss fault is triggered and control is transferred
+	 * to this point.  When this happens, we lookup the pte for the
+	 * faulting address by walking the page table in physical mode=20
+	 * and return to the continuation point passed in register r30=20
+	 * (or call page_fault if the address is not mapped).
 	 *
 	 * Input:	r16:	faulting address
 	 *		r29:	saved b0
@@ -435,71 +453,74 @@ ENTRY(nested_dtlb_miss)
 	 *
 	 * Clobbered:	b0, r18, r19, r21, r22, psr.dt (cleared)
 	 */
-	rsm psr.dt				// switch to using physical data addressing
-	mov r19=3DIA64_KR(PT_BASE)		// get the page table base address
-	shl r21=3Dr16,3				// shift bit 60 into sign bit
+	rsm psr.dt			// switch to using physical data=20
+					//   addressing
+	mov r19=3DIA64_KR(PT_BASE)	// get the page table base address
+	shl r21=3Dr16,3			// shift bit 60 into sign bit
 	mov r18=3Dcr.itir
 	;;
-	shr.u r17=3Dr16,61			// get the region number into r17
-	extr.u r18=3Dr18,2,6			// get the faulting page size
+	shr.u r17=3Dr16,61		// get the region number into r17
+	extr.u r18=3Dr18,2,6		// get the faulting page size
 	;;
-	cmp.eq p6,p7=3D5,r17			// is faulting address in region 5?
-	add r22=3D-PAGE_SHIFT,r18			// adjustment for hugetlb address
+	cmp.eq p6,p7=3D5,r17		// is faulting address in region 5?
+	add r22=3D-PAGE_SHIFT,r18		// adjustment for hugetlb address
 	add r18=3DPGDIR_SHIFT-PAGE_SHIFT,r18
 	;;
 	shr.u r22=3Dr16,r22
 	shr.u r18=3Dr16,r18
-(p7)	dep r17=3Dr17,r19,(PAGE_SHIFT-3),3	// put region number bits in place
+(p7)	dep r17=3Dr17,r19,(PAGE_SHIFT-3),3  // put region number bits in place
=20
 	srlz.d
-	LOAD_PHYSICAL(p6, r19, swapper_pg_dir)	// region 5 is rooted at swapper_p=
g_dir
+	LOAD_PHYSICAL(p6, r19, swapper_pg_dir)	// region 5 is rooted at=20
+						//   swapper_pg_dir
=20
 	.pred.rel "mutex", p6, p7
 (p6)	shr.u r21=3Dr21,PGDIR_SHIFT+PAGE_SHIFT
 (p7)	shr.u r21=3Dr21,PGDIR_SHIFT+PAGE_SHIFT-3
 	;;
-(p6)	dep r17=3Dr18,r19,3,(PAGE_SHIFT-3)	// r17=3Dpgd_offset for region 5
-(p7)	dep r17=3Dr18,r17,3,(PAGE_SHIFT-6)	// r17=3Dpgd_offset for region[0-4]
-	cmp.eq p7,p6=3D0,r21			// unused address bits all zeroes?
+(p6)	dep r17=3Dr18,r19,3,(PAGE_SHIFT-3)  // r17=3Dpgd_offset for region 5
+(p7)	dep r17=3Dr18,r17,3,(PAGE_SHIFT-6)  // r17=3Dpgd_offset for region[0-=
4]
+	cmp.eq p7,p6=3D0,r21		// unused address bits all zeroes?
 #ifdef CONFIG_PGTABLE_4
-	shr.u r18=3Dr22,PUD_SHIFT			// shift pud index into position
+	shr.u r18=3Dr22,PUD_SHIFT		// shift pud index into position
 #else
-	shr.u r18=3Dr22,PMD_SHIFT			// shift pmd index into position
+	shr.u r18=3Dr22,PMD_SHIFT		// shift pmd index into position
 #endif
 	;;
-	ld8 r17=3D[r17]				// get *pgd (may be 0)
+	ld8 r17=3D[r17]			// get *pgd (may be 0)
 	;;
-(p7)	cmp.eq p6,p7=3Dr17,r0			// was pgd_present(*pgd) =3D NULL?
-	dep r17=3Dr18,r17,3,(PAGE_SHIFT-3)	// r17=3Dp[u|m]d_offset(pgd,addr)
+(p7)	cmp.eq p6,p7=3Dr17,r0		// was pgd_present(*pgd) =3D NULL?
+	dep r17=3Dr18,r17,3,(PAGE_SHIFT-3)  // r17=3Dp[u|m]d_offset(pgd,addr)
 	;;
 #ifdef CONFIG_PGTABLE_4
-(p7)	ld8 r17=3D[r17]				// get *pud (may be 0)
-	shr.u r18=3Dr22,PMD_SHIFT			// shift pmd index into position
+(p7)	ld8 r17=3D[r17]			// get *pud (may be 0)
+	shr.u r18=3Dr22,PMD_SHIFT		// shift pmd index into position
 	;;
-(p7)	cmp.eq.or.andcm p6,p7=3Dr17,r0		// was pud_present(*pud) =3D NULL?
-	dep r17=3Dr18,r17,3,(PAGE_SHIFT-3)	// r17=3Dpmd_offset(pud,addr)
+(p7)	cmp.eq.or.andcm p6,p7=3Dr17,r0	// was pud_present(*pud) =3D NULL?
+	dep r17=3Dr18,r17,3,(PAGE_SHIFT-3)  // r17=3Dpmd_offset(pud,addr)
 	;;
 #endif
-(p7)	ld8 r17=3D[r17]				// get *pmd (may be 0)
-	shr.u r19=3Dr22,PAGE_SHIFT		// shift pte index into position
+(p7)	ld8 r17=3D[r17]			// get *pmd (may be 0)
+	shr.u r19=3Dr22,PAGE_SHIFT	// shift pte index into position
 	;;
-(p7)	cmp.eq.or.andcm p6,p7=3Dr17,r0		// was pmd_present(*pmd) =3D NULL?
-	dep r17=3Dr19,r17,3,(PAGE_SHIFT-3)	// r17=3Dpte_offset(pmd,addr);
+(p7)	cmp.eq.or.andcm p6,p7=3Dr17,r0	// was pmd_present(*pmd) =3D NULL?
+	dep r17=3Dr19,r17,3,(PAGE_SHIFT-3)  // r17=3Dpte_offset(pmd,addr);
 (p6)	br.cond.spnt page_fault
 	mov b0=3Dr30
-	br.sptk.many b0				// return to continuation point
+	br.sptk.many b0			// return to continuation point
 END(nested_dtlb_miss)
=20
 	.org ia64_ivt+0x1800
-//////////////////////////////////////////////////////////////////////////=
///////////////
+//////////////////////////////////////////////////////////////////////////
 // 0x1800 Entry 6 (size 64 bundles) Instruction Key Miss (24)
 ENTRY(ikey_miss)
 	DBG_FAULT(6)
 	FAULT(6)
 END(ikey_miss)
=20
-	//-----------------------------------------------------------------------=
------------
-	// call do_page_fault (predicates are in r31, psr.dt may be off, r16 is f=
aulting address)
+	//----------------------------------------------------------------
+	// call do_page_fault (predicates are in r31, psr.dt may be off,=20
+	// r16 is faulting address)
 ENTRY(page_fault)
 	ssm psr.dt
 	;;
@@ -509,24 +530,25 @@ ENTRY(page_fault)
 	alloc r15=3Dar.pfs,0,0,3,0
 	mov out0=3Dcr.ifa
 	mov out1=3Dcr.isr
-	adds r3=3D8,r2				// set up second base pointer
+	adds r3=3D8,r2			// set up second base pointer
 	;;
 	ssm psr.ic | PSR_DEFAULT_BITS
 	;;
-	srlz.i					// guarantee that interruption collectin is on
+	srlz.i				// guarantee that interruption=20
+					//   collection is on
 	;;
-(p15)	ssm psr.i				// restore psr.i
+(p15)	ssm psr.i			// restore psr.i
 	movl r14=3Dia64_leave_kernel
 	;;
 	SAVE_REST
 	mov rp=3Dr14
 	;;
-	adds out2=16,r12			// out2 =3D pointer to pt_regs
+	adds out2=16,r12		// out2 =3D pointer to pt_regs
 	br.call.sptk.many b6=3Dia64_do_page_fault	// ignore return address
 END(page_fault)
=20
 	.org ia64_ivt+0x1c00
-//////////////////////////////////////////////////////////////////////////=
///////////////
+//////////////////////////////////////////////////////////////////////////
 // 0x1c00 Entry 7 (size 64 bundles) Data Key Miss (12,51)
 ENTRY(dkey_miss)
 	DBG_FAULT(7)
@@ -534,77 +556,83 @@ ENTRY(dkey_miss)
 END(dkey_miss)
=20
 	.org ia64_ivt+0x2000
-//////////////////////////////////////////////////////////////////////////=
///////////////
+//////////////////////////////////////////////////////////////////////////
 // 0x2000 Entry 8 (size 64 bundles) Dirty-bit (54)
 ENTRY(dirty_bit)
 	DBG_FAULT(8)
 	/*
-	 * What we do here is to simply turn on the dirty bit in the PTE.  We nee=
d to
-	 * update both the page-table and the TLB entry.  To efficiently access t=
he PTE,
-	 * we address it through the virtual page table.  Most likely, the TLB en=
try for
-	 * the relevant virtual page table page is still present in the TLB so we=
 can
-	 * normally do this without additional TLB misses.  In case the necessary=
 virtual
-	 * page table TLB entry isn't present, we take a nested TLB miss hit wher=
e we look
-	 * up the physical address of the L3 PTE and then continue at label 1 bel=
ow.
+	 * What we do here is to simply turn on the dirty bit in the PTE.
+	 * We need to update both the page-table and the TLB entry.  To=20
+	 * efficiently access the PTE, we address it through the virtual=20
+	 * page table.  Most likely, the TLB entry for the relevant virtual
+	 * page table page is still present in the TLB so we can normally=20
+	 * do this without additional TLB misses.  In case the necessary=20
+	 * virtual page table TLB entry isn't present, we take a nested=20
+	 * TLB miss hit where we look up the physical address of the L3
+	 * PTE and then continue at label 1 below.
 	 */
-	mov r16=3Dcr.ifa				// get the address that caused the fault
-	movl r30=1F				// load continuation point in case of nested fault
-	;;
-	thash r17=3Dr16				// compute virtual address of L3 PTE
-	mov r29=B0				// save b0 in case of nested fault
-	mov r31=3Dpr				// save pr
+	mov r16=3Dcr.ifa			// get the address that caused the
+					//   fault
+	movl r30=1F			// load continuation point in case=20
+					//   of nested fault
+	;;
+	thash r17=3Dr16			// compute virtual address of L3 PTE
+	mov r29=B0			// save b0 in case of nested fault
+	mov r31=3Dpr			// save pr
 #ifdef CONFIG_SMP
-	mov r28=3Dar.ccv				// save ar.ccv
+	mov r28=3Dar.ccv			// save ar.ccv
 	;;
 1:	ld8 r18=3D[r17]
-	;;					// avoid RAW on r18
-	mov ar.ccv=3Dr18				// set compare value for cmpxchg
-	or r25=3D_PAGE_D|_PAGE_A,r18		// set the dirty and accessed bits
-	tbit.z p7,p6 =3D r18,_PAGE_P_BIT		// Check present bit
+	;;				// avoid RAW on r18
+	mov ar.ccv=3Dr18			// set compare value for cmpxchg
+	or r25=3D_PAGE_D|_PAGE_A,r18	// set the dirty and accessed bits
+	tbit.z p7,p6 =3D r18,_PAGE_P_BIT	// Check present bit
 	;;
-(p6)	cmpxchg8.acq r26=3D[r17],r25,ar.ccv	// Only update if page is present
+(p6)	cmpxchg8.acq r26=3D[r17],r25,ar.ccv  // Only update if page is present
 	mov r24=3DPAGE_SHIFT<<2
 	;;
-(p6)	cmp.eq p6,p7=3Dr26,r18			// Only compare if page is present
+(p6)	cmp.eq p6,p7=3Dr26,r18		// Only compare if page is present
 	;;
-(p6)	itc.d r25				// install updated PTE
+(p6)	itc.d r25			// install updated PTE
 	;;
 	/*
-	 * Tell the assemblers dependency-violation checker that the above "itc" =
instructions
-	 * cannot possibly affect the following loads:
+	 * Tell the assemblers dependency-violation checker that the above
+	 * "itc" instructions cannot possibly affect the following loads:
 	 */
 	dv_serialize_data
=20
-	ld8 r18=3D[r17]				// read PTE again
+	ld8 r18=3D[r17]			// read PTE again
 	;;
-	cmp.eq p6,p7=3Dr18,r25			// is it same as the newly installed
+	cmp.eq p6,p7=3Dr18,r25		// is it same as the newly installed
 	;;
 (p7)	ptc.l r16,r24
-	mov b0=3Dr29				// restore b0
+	mov b0=3Dr29			// restore b0
 	mov ar.ccv=3Dr28
 #else
 	;;
 1:	ld8 r18=3D[r17]
-	;;					// avoid RAW on r18
-	or r18=3D_PAGE_D|_PAGE_A,r18		// set the dirty and accessed bits
-	mov b0=3Dr29				// restore b0
+	;;				// avoid RAW on r18
+	or r18=3D_PAGE_D|_PAGE_A,r18	// set the dirty and accessed bits
+	mov b0=3Dr29			// restore b0
 	;;
-	st8 [r17]=3Dr18				// store back updated PTE
-	itc.d r18				// install updated PTE
+	st8 [r17]=3Dr18			// store back updated PTE
+	itc.d r18			// install updated PTE
 #endif
-	mov pr=3Dr31,-1				// restore pr
+	mov pr=3Dr31,-1			// restore pr
 	rfi
 END(dirty_bit)
=20
 	.org ia64_ivt+0x2400
-//////////////////////////////////////////////////////////////////////////=
///////////////
+//////////////////////////////////////////////////////////////////////////
 // 0x2400 Entry 9 (size 64 bundles) Instruction Access-bit (27)
 ENTRY(iaccess_bit)
 	DBG_FAULT(9)
 	// Like Entry 8, except for instruction access
-	mov r16=3Dcr.ifa				// get the address that caused the fault
-	movl r30=1F				// load continuation point in case of nested fault
-	mov r31=3Dpr				// save predicates
+	mov r16=3Dcr.ifa			// get the address that caused the
+					//   fault
+	movl r30=1F			// load continuation point in case=20
+					//   of nested fault
+	mov r31=3Dpr			// save predicates
 #ifdef CONFIG_ITANIUM
 	/*
 	 * Erratum 10 (IFA may contain incorrect address) has "NoFix" status.
@@ -612,245 +640,267 @@ #ifdef CONFIG_ITANIUM
 	mov r17=3Dcr.ipsr
 	;;
 	mov r18=3Dcr.iip
-	tbit.z p6,p0=3Dr17,IA64_PSR_IS_BIT	// IA64 instruction set?
+	tbit.z p6,p0=3Dr17,IA64_PSR_IS_BIT  // IA64 instruction set?
 	;;
-(p6)	mov r16=3Dr18				// if so, use cr.iip instead of cr.ifa
+(p6)	mov r16=3Dr18			// if so, use cr.iip instead of cr.ifa
 #endif /* CONFIG_ITANIUM */
 	;;
-	thash r17=3Dr16				// compute virtual address of L3 PTE
-	mov r29=B0				// save b0 in case of nested fault)
+	thash r17=3Dr16			// compute virtual address of L3 PTE
+	mov r29=B0			// save b0 in case of nested fault)
 #ifdef CONFIG_SMP
-	mov r28=3Dar.ccv				// save ar.ccv
+	mov r28=3Dar.ccv			// save ar.ccv
 	;;
 1:	ld8 r18=3D[r17]
 	;;
-	mov ar.ccv=3Dr18				// set compare value for cmpxchg
-	or r25=3D_PAGE_A,r18			// set the accessed bit
-	tbit.z p7,p6 =3D r18,_PAGE_P_BIT	 	// Check present bit
+	mov ar.ccv=3Dr18			// set compare value for cmpxchg
+	or r25=3D_PAGE_A,r18		// set the accessed bit
+	tbit.z p7,p6 =3D r18,_PAGE_P_BIT	// Check present bit
 	;;
-(p6)	cmpxchg8.acq r26=3D[r17],r25,ar.ccv	// Only if page present
+(p6)	cmpxchg8.acq r26=3D[r17],r25,ar.ccv  // Only if page present
 	mov r24=3DPAGE_SHIFT<<2
 	;;
-(p6)	cmp.eq p6,p7=3Dr26,r18			// Only if page present
+(p6)	cmp.eq p6,p7=3Dr26,r18		// Only if page present
 	;;
-(p6)	itc.i r25				// install updated PTE
+(p6)	itc.i r25			// install updated PTE
 	;;
 	/*
-	 * Tell the assemblers dependency-violation checker that the above "itc" =
instructions
-	 * cannot possibly affect the following loads:
+	 * Tell the assemblers dependency-violation checker that the above
+	 * "itc" instructions cannot possibly affect the following loads:
 	 */
 	dv_serialize_data
=20
-	ld8 r18=3D[r17]				// read PTE again
+	ld8 r18=3D[r17]			// read PTE again
 	;;
-	cmp.eq p6,p7=3Dr18,r25			// is it same as the newly installed
+	cmp.eq p6,p7=3Dr18,r25		// is it same as the newly installed
 	;;
 (p7)	ptc.l r16,r24
-	mov b0=3Dr29				// restore b0
+	mov b0=3Dr29			// restore b0
 	mov ar.ccv=3Dr28
 #else /* !CONFIG_SMP */
 	;;
 1:	ld8 r18=3D[r17]
 	;;
-	or r18=3D_PAGE_A,r18			// set the accessed bit
-	mov b0=3Dr29				// restore b0
+	or r18=3D_PAGE_A,r18		// set the accessed bit
+	mov b0=3Dr29			// restore b0
 	;;
-	st8 [r17]=3Dr18				// store back updated PTE
-	itc.i r18				// install updated PTE
+	st8 [r17]=3Dr18			// store back updated PTE
+	itc.i r18			// install updated PTE
 #endif /* !CONFIG_SMP */
 	mov pr=3Dr31,-1
 	rfi
 END(iaccess_bit)
=20
 	.org ia64_ivt+0x2800
-//////////////////////////////////////////////////////////////////////////=
///////////////
+//////////////////////////////////////////////////////////////////////////
 // 0x2800 Entry 10 (size 64 bundles) Data Access-bit (15,55)
 ENTRY(daccess_bit)
 	DBG_FAULT(10)
 	// Like Entry 8, except for data access
-	mov r16=3Dcr.ifa				// get the address that caused the fault
-	movl r30=1F				// load continuation point in case of nested fault
+	mov r16=3Dcr.ifa			// get the address that caused the
+					//   fault
+	movl r30=1F			// load continuation point in case=20
+					//   of nested fault
 	;;
-	thash r17=3Dr16				// compute virtual address of L3 PTE
+	thash r17=3Dr16			// compute virtual address of L3 PTE
 	mov r31=3Dpr
-	mov r29=B0				// save b0 in case of nested fault)
+	mov r29=B0			// save b0 in case of nested fault)
 #ifdef CONFIG_SMP
-	mov r28=3Dar.ccv				// save ar.ccv
+	mov r28=3Dar.ccv			// save ar.ccv
 	;;
 1:	ld8 r18=3D[r17]
-	;;					// avoid RAW on r18
-	mov ar.ccv=3Dr18				// set compare value for cmpxchg
-	or r25=3D_PAGE_A,r18			// set the dirty bit
-	tbit.z p7,p6 =3D r18,_PAGE_P_BIT		// Check present bit
+	;;				// avoid RAW on r18
+	mov ar.ccv=3Dr18			// set compare value for cmpxchg
+	or r25=3D_PAGE_A,r18		// set the dirty bit
+	tbit.z p7,p6 =3D r18,_PAGE_P_BIT	// Check present bit
 	;;
-(p6)	cmpxchg8.acq r26=3D[r17],r25,ar.ccv	// Only if page is present
+(p6)	cmpxchg8.acq r26=3D[r17],r25,ar.ccv  // Only if page is present
 	mov r24=3DPAGE_SHIFT<<2
 	;;
-(p6)	cmp.eq p6,p7=3Dr26,r18			// Only if page is present
+(p6)	cmp.eq p6,p7=3Dr26,r18		// Only if page is present
 	;;
-(p6)	itc.d r25				// install updated PTE
+(p6)	itc.d r25			// install updated PTE
 	/*
-	 * Tell the assemblers dependency-violation checker that the above "itc" =
instructions
-	 * cannot possibly affect the following loads:
+	 * Tell the assemblers dependency-violation checker that the above
+	 * "itc" instructions cannot possibly affect the following loads:
 	 */
 	dv_serialize_data
 	;;
-	ld8 r18=3D[r17]				// read PTE again
+	ld8 r18=3D[r17]			// read PTE again
 	;;
-	cmp.eq p6,p7=3Dr18,r25			// is it same as the newly installed
+	cmp.eq p6,p7=3Dr18,r25		// is it same as the newly installed
 	;;
 (p7)	ptc.l r16,r24
 	mov ar.ccv=3Dr28
 #else
 	;;
 1:	ld8 r18=3D[r17]
-	;;					// avoid RAW on r18
-	or r18=3D_PAGE_A,r18			// set the accessed bit
+	;;				// avoid RAW on r18
+	or r18=3D_PAGE_A,r18		// set the accessed bit
 	;;
-	st8 [r17]=3Dr18				// store back updated PTE
-	itc.d r18				// install updated PTE
+	st8 [r17]=3Dr18			// store back updated PTE
+	itc.d r18			// install updated PTE
 #endif
-	mov b0=3Dr29				// restore b0
+	mov b0=3Dr29			// restore b0
 	mov pr=3Dr31,-1
 	rfi
 END(daccess_bit)
=20
 	.org ia64_ivt+0x2c00
-//////////////////////////////////////////////////////////////////////////=
///////////////
+//////////////////////////////////////////////////////////////////////////
 // 0x2c00 Entry 11 (size 64 bundles) Break instruction (33)
 ENTRY(break_fault)
 	/*
-	 * The streamlined system call entry/exit paths only save/restore the ini=
tial part
-	 * of pt_regs.  This implies that the callers of system-calls must adhere=
 to the
-	 * normal procedure calling conventions.
+	 * The streamlined system call entry/exit paths only save/restore
+	 * the initial part of pt_regs.  This implies that the callers of
+	 * system-calls must adhere to the normal procedure calling=20
+	 * conventions.
 	 *
 	 *   Registers to be saved & restored:
 	 *	CR registers: cr.ipsr, cr.iip, cr.ifs
-	 *	AR registers: ar.unat, ar.pfs, ar.rsc, ar.rnat, ar.bspstore, ar.fpsr
+	 *	AR registers: ar.unat, ar.pfs, ar.rsc, ar.rnat, ar.bspstore,
+	 *		      ar.fpsr
 	 * 	others: pr, b0, b6, loadrs, r1, r11, r12, r13, r15
 	 *   Registers to be restored only:
 	 * 	r8-r11: output value from the system call.
 	 *
-	 * During system call exit, scratch registers (including r15) are modifie=
d/cleared
-	 * to prevent leaking bits from kernel to user level.
+	 * During system call exit, scratch registers (including r15) are=20
+	 * modified/cleared to prevent leaking bits from kernel to user=20
+	 * level.
 	 */
 	DBG_FAULT(11)
-	mov.m r16=3DIA64_KR(CURRENT)		// M2 r16 <- current task (12 cyc)
-	mov r29=3Dcr.ipsr				// M2 (12 cyc)
-	mov r31=3Dpr				// I0 (2 cyc)
+	mov.m r16=3DIA64_KR(CURRENT)	// M2 r16 <- current task (12 cyc)
+	mov r29=3Dcr.ipsr			// M2 (12 cyc)
+	mov r31=3Dpr			// I0 (2 cyc)
=20
-	mov r17=3Dcr.iim				// M2 (2 cyc)
-	mov.m r27=3Dar.rsc			// M2 (12 cyc)
-	mov r18=3D__IA64_BREAK_SYSCALL		// A
+	mov r17=3Dcr.iim			// M2 (2 cyc)
+	mov.m r27=3Dar.rsc		// M2 (12 cyc)
+	mov r18=3D__IA64_BREAK_SYSCALL	// A
=20
-	mov.m ar.rsc=3D0				// M2
-	mov.m r21=3Dar.fpsr			// M2 (12 cyc)
-	mov r19=B6				// I0 (2 cyc)
+	mov.m ar.rsc=3D0			// M2
+	mov.m r21=3Dar.fpsr		// M2 (12 cyc)
+	mov r19=B6			// I0 (2 cyc)
 	;;
-	mov.m r23=3Dar.bspstore			// M2 (12 cyc)
-	mov.m r24=3Dar.rnat			// M2 (5 cyc)
-	mov.i r26=3Dar.pfs			// I0 (2 cyc)
+	mov.m r23=3Dar.bspstore		// M2 (12 cyc)
+	mov.m r24=3Dar.rnat		// M2 (5 cyc)
+	mov.i r26=3Dar.pfs		// I0 (2 cyc)
=20
-	invala					// M0|1
-	nop.m 0					// M
-	mov r20=3Dr1				// A			save r1
+	invala				// M0|1
+	nop.m 0				// M
+	mov r20=3Dr1			// A			save r1
=20
 	nop.m 0
-	movl r30=3Dsys_call_table			// X
+	movl r30=3Dsys_call_table		// X
=20
-	mov r28=3Dcr.iip				// M2 (2 cyc)
-	cmp.eq p0,p7=3Dr18,r17			// I0 is this a system call?
-(p7)	br.cond.spnt non_syscall		// B  no ->
+	mov r28=3Dcr.iip			// M2 (2 cyc)
+	cmp.eq p0,p7=3Dr18,r17		// I0 is this a system call?
+(p7)	br.cond.spnt non_syscall	// B  no ->
 	//
 	// From this point on, we are definitely on the syscall-path
 	// and we can use (non-banked) scratch registers.
 	//
 ///////////////////////////////////////////////////////////////////////
-	mov r1=3Dr16				// A    move task-pointer to "addl"-addressable reg
-	mov r2=3Dr16				// A    setup r2 for ia64_syscall_setup
-	add r9=3DTI_FLAGS+IA64_TASK_SIZE,r16	// A	r9 =3D &current_thread_info()->=
flags
+	mov r1=3Dr16			// A    move task-pointer to=20
+					//      "addl"-addressable reg
+	mov r2=3Dr16			// A    setup r2 for ia64_syscall_setup
+	add r9=3DTI_FLAGS+IA64_TASK_SIZE,r16
+				// A	r9 =3D &current_thread_info()->flags
=20
 	adds r16=3DIA64_TASK_THREAD_ON_USTACK_OFFSET,r16
-	adds r15=3D-1024,r15			// A    subtract 1024 from syscall number
+	adds r15=3D-1024,r15	// A    subtract 1024 from syscall number
 	mov r3=3DNR_syscalls - 1
 	;;
-	ld1.bias r17=3D[r16]			// M0|1 r17 =3D current->thread.on_ustack flag
-	ld4 r9=3D[r9]				// M0|1 r9 =3D current_thread_info()->flags
-	extr.u r8=3Dr29,41,2			// I0   extract ei field from cr.ipsr
+	ld1.bias r17=3D[r16]	// M0|1 r17 =3D current->thread.on_ustack flag
+	ld4 r9=3D[r9]		// M0|1 r9 =3D current_thread_info()->flags
+	extr.u r8=3Dr29,41,2	// I0   extract ei field from cr.ipsr
=20
-	shladd r30=3Dr15,3,r30			// A    r30 =3D sys_call_table + 8*(syscall-1024)
-	addl r22=3DIA64_RBS_OFFSET,r1		// A    compute base of RBS
-	cmp.leu p6,p7=3Dr15,r3			// A    syscall number in range?
+	shladd r30=3Dr15,3,r30	// A    r30 =3D sys_call_table + 8*(syscall-1024)
+	addl r22=3DIA64_RBS_OFFSET,r1	// A    compute base of RBS
+	cmp.leu p6,p7=3Dr15,r3		// A    syscall number in range?
 	;;
=20
-	lfetch.fault.excl.nt1 [r22]		// M0|1 prefetch RBS
-(p6)	ld8 r30=3D[r30]				// M0|1 load address of syscall entry point
-	tnat.nz.or p7,p0=3Dr15			// I0	is syscall nr a NaT?
+	lfetch.fault.excl.nt1 [r22]	// M0|1 prefetch RBS
+(p6)	ld8 r30=3D[r30]			// M0|1 load address of syscall entry
+					//      point
+	tnat.nz.or p7,p0=3Dr15		// I0	is syscall nr a NaT?
=20
-	mov.m ar.bspstore=3Dr22			// M2   switch to kernel RBS
-	cmp.eq p8,p9=3D2,r8			// A    isr.ei=3D2?
+	mov.m ar.bspstore=3Dr22		// M2   switch to kernel RBS
+	cmp.eq p8,p9=3D2,r8		// A    isr.ei=3D2?
 	;;
=20
-(p8)	mov r8=3D0				// A    clear ei to 0
-(p7)	movl r30=3Dsys_ni_syscall			// X
+(p8)	mov r8=3D0			// A    clear ei to 0
+(p7)	movl r30=3Dsys_ni_syscall		// X
=20
-(p8)	adds r28=16,r28				// A    switch cr.iip to next bundle
-(p9)	adds r8=3D1,r8				// A    increment ei to next slot
+(p8)	adds r28=16,r28			// A    switch cr.iip to next bundle
+(p9)	adds r8=3D1,r8			// A    increment ei to next slot
 	nop.i 0
 	;;
=20
-	mov.m r25=3Dar.unat			// M2 (5 cyc)
-	dep r29=3Dr8,r29,41,2			// I0   insert new ei into cr.ipsr
-	adds r15=1024,r15			// A    restore original syscall number
+	mov.m r25=3Dar.unat		// M2 (5 cyc)
+	dep r29=3Dr8,r29,41,2		// I0   insert new ei into cr.ipsr
+	adds r15=1024,r15		// A    restore original syscall number
 	//
 	// If any of the above loads miss in L1D, we'll stall here until
 	// the data arrives.
 	//
 ///////////////////////////////////////////////////////////////////////
-	st1 [r16]=3Dr0				// M2|3 clear current->thread.on_ustack flag
-	mov b6=3Dr30				// I0   setup syscall handler branch reg early
-	cmp.eq pKStk,pUStk=3Dr0,r17		// A    were we on kernel stacks already?
-
-	and r9=3D_TIF_SYSCALL_TRACEAUDIT,r9	// A    mask trace or audit
-	mov r18=3Dar.bsp				// M2 (12 cyc)
-(pKStk)	br.cond.spnt .break_fixup		// B	we're already in kernel-mode -- fi=
x up RBS
+	st1 [r16]=3Dr0			// M2|3 clear current->thread.on_ustack
+					//      flag
+	mov b6=3Dr30			// I0   setup syscall handler branch
+					//      reg early
+	cmp.eq pKStk,pUStk=3Dr0,r17  	// A    were we on kernel stacks=20
+					//      already?
+
+	and r9=3D_TIF_SYSCALL_TRACEAUDIT,r9  // A    mask trace or audit
+	mov r18=3Dar.bsp			// M2 (12 cyc)
+(pKStk)	br.cond.spnt .break_fixup	// B	we're already in kernel-mode
+					//      -- fix up RBS
 	;;
 .back_from_break_fixup:
-(pUStk)	addl r1=3DIA64_STK_OFFSET-IA64_PT_REGS_SIZE,r1 // A    compute bas=
e of memory stack
-	cmp.eq p14,p0=3Dr9,r0			// A    are syscalls being traced/audited?
+(pUStk)	addl r1=3DIA64_STK_OFFSET-IA64_PT_REGS_SIZE,r1
+					// A    compute base of memory stack
+	cmp.eq p14,p0=3Dr9,r0		// A    are syscalls being=20
+					//      traced/audited?
 	br.call.sptk.many b7=3Dia64_syscall_setup	// B
 1:
-	mov ar.rsc=3D0x3				// M2   set eager mode, pl 0, LE, loadrs=3D0
+	mov ar.rsc=3D0x3			// M2   set eager mode, pl 0, LE,
+					//      loadrs=3D0
 	nop 0
-	bsw.1					// B (6 cyc) regs are saved, switch to bank 1
+	bsw.1				// B (6 cyc) regs are saved, switch
+					//           to bank 1
 	;;
=20
-	ssm psr.ic | PSR_DEFAULT_BITS		// M2	now it's safe to re-enable intr.-col=
lection
-	movl r3=3Dia64_ret_from_syscall		// X
+	ssm psr.ic | PSR_DEFAULT_BITS
+			// M2	now it's safe to re-enable intr.-collection
+	movl r3=3Dia64_ret_from_syscall	// X
 	;;
=20
-	srlz.i					// M0   ensure interruption collection is on
-	mov rp=3Dr3				// I0   set the real return addr
-(p10)	br.cond.spnt.many ia64_ret_from_syscall	// B    return if bad call-f=
rame or r15 is a NaT
+	srlz.i				// M0   ensure interruption collection
+					//	is on
+	mov rp=3Dr3			// I0   set the real return addr
+(p10)	br.cond.spnt.many ia64_ret_from_syscall
+				// B    return if bad call-frame or r15 is a NaT
=20
-(p15)	ssm psr.i				// M2   restore psr.i
-(p14)	br.call.sptk.many b6=B6			// B    invoke syscall-handker (ignore ret=
urn addr)
-	br.cond.spnt.many ia64_trace_syscall	// B	do syscall-tracing thingamagic
+(p15)	ssm psr.i			// M2   restore psr.i
+(p14)	br.call.sptk.many b6=B6		// B    invoke syscall-handker (ignore
+					//	return addr)
+	br.cond.spnt.many ia64_trace_syscall
+					// B	do syscall-tracing thingamagic
 	// NOT REACHED
 ///////////////////////////////////////////////////////////////////////
-	// On entry, we optimistically assumed that we're coming from user-space.
-	// For the rare cases where a system-call is done from within the kernel,
-	// we fix things up at this point:
+	// On entry, we optimistically assumed that we're coming from=20
+	// user-space.  For the rare cases where a system-call is done=20
+	// from within the kernel, we fix things up at this point:
 .break_fixup:
-	add r1=3D-IA64_PT_REGS_SIZE,sp		// A    allocate space for pt_regs struct=
ure
-	mov ar.rnat=3Dr24				// M2	restore kernel's AR.RNAT
+	add r1=3D-IA64_PT_REGS_SIZE,sp	// A    allocate space for pt_regs=20
+					//	structure
+	mov ar.rnat=3Dr24			// M2	restore kernel's AR.RNAT
 	;;
-	mov ar.bspstore=3Dr23			// M2	restore kernel's AR.BSPSTORE
+	mov ar.bspstore=3Dr23		// M2	restore kernel's AR.BSPSTORE
 	br.cond.sptk .back_from_break_fixup
 END(break_fault)
=20
 	.org ia64_ivt+0x3000
-//////////////////////////////////////////////////////////////////////////=
///////////////
+//////////////////////////////////////////////////////////////////////////
 // 0x3000 Entry 12 (size 64 bundles) External Interrupt (4)
 ENTRY(interrupt)
 	DBG_FAULT(12)
@@ -877,22 +927,22 @@ ENTRY(interrupt)
 END(interrupt)
=20
 	.org ia64_ivt+0x3400
-//////////////////////////////////////////////////////////////////////////=
///////////////
+//////////////////////////////////////////////////////////////////////////
 // 0x3400 Entry 13 (size 64 bundles) Reserved
 	DBG_FAULT(13)
 	FAULT(13)
=20
 	.org ia64_ivt+0x3800
-//////////////////////////////////////////////////////////////////////////=
///////////////
+//////////////////////////////////////////////////////////////////////////
 // 0x3800 Entry 14 (size 64 bundles) Reserved
 	DBG_FAULT(14)
 	FAULT(14)
=20
 	/*
-	 * There is no particular reason for this code to be here, other than that
-	 * there happens to be space here that would go unused otherwise.  If this
-	 * fault ever gets "unreserved", simply moved the following code to a more
-	 * suitable spot...
+	 * There is no particular reason for this code to be here, other=20
+	 * than that there happens to be space here that would go unused=20
+	 * otherwise.  If this fault ever gets "unreserved", simply move
+	 * the following code to a more suitable spot...
 	 *
 	 * ia64_syscall_setup() is a separate subroutine so that it can
 	 *	allocate stacked registers so it can safely demine any
@@ -939,11 +989,11 @@ GLOBAL_ENTRY(ia64_syscall_setup)
 #if PT(B6) !=3D 0
 # error This code assumes that b6 is the first field in pt_regs.
 #endif
-	st8 [r1]=3Dr19				// save b6
-	add r16=3DPT(CR_IPSR),r1			// initialize first base pointer
-	add r17=3DPT(R11),r1			// initialize second base pointer
+	st8 [r1]=3Dr19			// save b6
+	add r16=3DPT(CR_IPSR),r1		// initialize first base pointer
+	add r17=3DPT(R11),r1		// initialize second base pointer
 	;;
-	alloc r19=3Dar.pfs,8,0,0,0		// ensure in0-in7 are writable
+	alloc r19=3Dar.pfs,8,0,0,0	// ensure in0-in7 are writable
 	st8 [r16]=3Dr29,PT(AR_PFS)-PT(CR_IPSR)	// save cr.ipsr
 	tnat.nz p8,p0=3Din0
=20
@@ -966,8 +1016,8 @@ (p8)	mov in0=3D-1
 	extr.u r11=3Dr19,7,7	// I0		// get sol of ar.pfs
 	and r8=3D0x7f,r19		// A		// get sof of ar.pfs
=20
-	st8 [r17]=3Dr27,PT(AR_BSPSTORE)-PT(AR_RSC)// save ar.rsc
-	tbit.nz p15,p0=3Dr29,IA64_PSR_I_BIT // I0
+	st8 [r17]=3Dr27,PT(AR_BSPSTORE)-PT(AR_RSC)  // save ar.rsc
+	tbit.nz p15,p0=3Dr29,IA64_PSR_I_BIT	// I0
 (p9)	mov in1=3D-1
 	;;
=20
@@ -980,18 +1030,20 @@ (pKStk) adds r17=3DPT(B0)-PT(AR_BSPSTORE),
 	tnat.nz p11,p0=3Din3
 	;;
 (p10)	mov in2=3D-1
-	tnat.nz p12,p0=3Din4				// [I0]
+	tnat.nz p12,p0=3Din4			// [I0]
 (p11)	mov in3=3D-1
 	;;
 (pUStk) st8 [r16]=3Dr24,PT(PR)-PT(AR_RNAT)	// save ar.rnat
 (pUStk) st8 [r17]=3Dr23,PT(B0)-PT(AR_BSPSTORE)	// save ar.bspstore
-	shl r18=3Dr18,16				// compute ar.rsc to be used for "loadrs"
+	shl r18=3Dr18,16				// compute ar.rsc to be used=20
+						//   for "loadrs"
 	;;
 	st8 [r16]=3Dr31,PT(LOADRS)-PT(PR)		// save predicates
 	st8 [r17]=3Dr28,PT(R1)-PT(B0)		// save b0
-	tnat.nz p13,p0=3Din5				// [I0]
+	tnat.nz p13,p0=3Din5			// [I0]
 	;;
-	st8 [r16]=3Dr18,PT(R12)-PT(LOADRS)	// save ar.rsc value for "loadrs"
+	st8 [r16]=3Dr18,PT(R12)-PT(LOADRS)	// save ar.rsc value for=20
+						//   "loadrs"
 	st8.spill [r17]=3Dr20,PT(R13)-PT(R1)	// save original r1
 (p12)	mov in4=3D-1
 	;;
@@ -1006,29 +1058,31 @@ (p13)	mov in5=3D-1
 	;;
 	mov r8=3D1
 (p9)	tnat.nz p10,p0=3Dr15
-	adds r12=3D-16,r1		// switch to kernel memory stack (with 16 bytes of scr=
atch)
+	adds r12=3D-16,r1		// switch to kernel memory stack (with 16=20
+				//   bytes of scratch)
=20
-	st8.spill [r17]=3Dr15			// save r15
+	st8.spill [r17]=3Dr15	// save r15
 	tnat.nz p8,p0=3Din7
 	nop.i 0
=20
-	mov r13=3Dr2				// establish `current'
-	movl r1=3D__gp				// establish kernel global pointer
+	mov r13=3Dr2		// establish `current'
+	movl r1=3D__gp		// establish kernel global pointer
 	;;
-	st8 [r16]=3Dr8		// ensure pt_regs.r8 !=3D 0 (see handle_syscall_error)
+	st8 [r16]=3Dr8		// ensure pt_regs.r8 !=3D 0 (see=20
+				//   handle_syscall_error)
 (p13)	mov in6=3D-1
 (p8)	mov in7=3D-1
=20
-	cmp.eq pSys,pNonSys=3Dr0,r0		// set pSys=3D1, pNonSys=3D0
+	cmp.eq pSys,pNonSys=3Dr0,r0	// set pSys=3D1, pNonSys=3D0
 	movl r17=3DFPSR_DEFAULT
 	;;
-	mov.m ar.fpsr=3Dr17			// set ar.fpsr to kernel default value
+	mov.m ar.fpsr=3Dr17		// set ar.fpsr to kernel default value
 (p10)	mov r8=3D-EINVAL
 	br.ret.sptk.many b7
 END(ia64_syscall_setup)
=20
 	.org ia64_ivt+0x3c00
-//////////////////////////////////////////////////////////////////////////=
///////////////
+//////////////////////////////////////////////////////////////////////////
 // 0x3c00 Entry 15 (size 64 bundles) Reserved
 	DBG_FAULT(15)
 	FAULT(15)
@@ -1036,11 +1090,12 @@ END(ia64_syscall_setup)
 	/*
 	 * Squatting in this space ...
 	 *
-	 * This special case dispatcher for illegal operation faults allows prese=
rved
-	 * registers to be modified through a callback function (asm only) that i=
s handed
-	 * back from the fault handler in r8. Up to three arguments can be passed=
 to the
-	 * callback function by returning an aggregate with the callback as its f=
irst
-	 * element, followed by the arguments.
+	 * This special case dispatcher for illegal operation faults=20
+	 * allows preserved registers to be modified through a callback=20
+	 * function (asm only) that is handed back from the fault handler
+	 * in r8.  Up to three arguments can be passed to the callback=20
+	 * function by returning an aggregate with the callback as its
+	 * first element, followed by the arguments.
 	 */
 ENTRY(dispatch_illegal_op_fault)
 	.prologue
@@ -1076,71 +1131,74 @@ (p6)	br.call.dpnt.many b6=B6		// call re
 END(dispatch_illegal_op_fault)
=20
 	.org ia64_ivt+0x4000
-//////////////////////////////////////////////////////////////////////////=
///////////////
+//////////////////////////////////////////////////////////////////////////
 // 0x4000 Entry 16 (size 64 bundles) Reserved
 	DBG_FAULT(16)
 	FAULT(16)
=20
 	.org ia64_ivt+0x4400
-//////////////////////////////////////////////////////////////////////////=
///////////////
+//////////////////////////////////////////////////////////////////////////
 // 0x4400 Entry 17 (size 64 bundles) Reserved
 	DBG_FAULT(17)
 	FAULT(17)
=20
 ENTRY(non_syscall)
-	mov ar.rsc=3Dr27			// restore ar.rsc before SAVE_MIN_WITH_COVER
+	mov ar.rsc=3Dr27		// restore ar.rsc before SAVE_MIN_WITH_COVER
 	;;
 	SAVE_MIN_WITH_COVER
=20
-	// There is no particular reason for this code to be here, other than that
-	// there happens to be space here that would go unused otherwise.  If this
-	// fault ever gets "unreserved", simply moved the following code to a more
-	// suitable spot...
+	// There is no particular reason for this code to be here, other=20
+	// than that there happens to be space here that would go unused=20
+	// otherwise.  If this fault ever gets "unreserved", simply move
+	// the following code to a more suitable spot...
=20
 	alloc r14=3Dar.pfs,0,0,2,0
 	mov out0=3Dcr.iim
 	add out1=16,sp
-	adds r3=3D8,r2			// set up second base pointer for SAVE_REST
+	adds r3=3D8,r2		// set up second base pointer for SAVE_REST
=20
 	ssm psr.ic | PSR_DEFAULT_BITS
 	;;
-	srlz.i				// guarantee that interruption collection is on
+	srlz.i			// guarantee that interruption collection is on
 	;;
-(p15)	ssm psr.i			// restore psr.i
+(p15)	ssm psr.i		// restore psr.i
 	movl r15=3Dia64_leave_kernel
 	;;
 	SAVE_REST
 	mov rp=3Dr15
 	;;
-	br.call.sptk.many b6=3Dia64_bad_break	// avoid WAW on CFM and ignore retu=
rn addr
+	br.call.sptk.many b6=3Dia64_bad_break	// avoid WAW on CFM and ignore
+						//   return addr
 END(non_syscall)
=20
 	.org ia64_ivt+0x4800
-//////////////////////////////////////////////////////////////////////////=
///////////////
+//////////////////////////////////////////////////////////////////////////
 // 0x4800 Entry 18 (size 64 bundles) Reserved
 	DBG_FAULT(18)
 	FAULT(18)
=20
 	/*
-	 * There is no particular reason for this code to be here, other than that
-	 * there happens to be space here that would go unused otherwise.  If this
-	 * fault ever gets "unreserved", simply moved the following code to a more
-	 * suitable spot...
+	 * There is no particular reason for this code to be here, other=20
+	 * than that there happens to be space here that would go unused=20
+	 * otherwise.  If this fault ever gets "unreserved", simply move
+	 * the following code to a more suitable spot...
 	 */
=20
 ENTRY(dispatch_unaligned_handler)
 	SAVE_MIN_WITH_COVER
 	;;
-	alloc r14=3Dar.pfs,0,0,2,0		// now it's safe (must be first in insn group=
!)
+	alloc r14=3Dar.pfs,0,0,2,0	// now it's safe (must be first in=20
+					//   insn group!)
 	mov out0=3Dcr.ifa
 	adds out1=16,sp
=20
 	ssm psr.ic | PSR_DEFAULT_BITS
 	;;
-	srlz.i					// guarantee that interruption collection is on
+	srlz.i				// guarantee that interruption=20
+					//   collection is on
 	;;
-(p15)	ssm psr.i				// restore psr.i
-	adds r3=3D8,r2				// set up second base pointer
+(p15)	ssm psr.i			// restore psr.i
+	adds r3=3D8,r2			// set up second base pointer
 	;;
 	SAVE_REST
 	movl r14=3Dia64_leave_kernel
@@ -1150,16 +1208,16 @@ (p15)	ssm psr.i				// restore psr.i
 END(dispatch_unaligned_handler)
=20
 	.org ia64_ivt+0x4c00
-//////////////////////////////////////////////////////////////////////////=
///////////////
+//////////////////////////////////////////////////////////////////////////
 // 0x4c00 Entry 19 (size 64 bundles) Reserved
 	DBG_FAULT(19)
 	FAULT(19)
=20
 	/*
-	 * There is no particular reason for this code to be here, other than that
-	 * there happens to be space here that would go unused otherwise.  If this
-	 * fault ever gets "unreserved", simply moved the following code to a more
-	 * suitable spot...
+	 * There is no particular reason for this code to be here, other=20
+	 * than that there happens to be space here that would go unused=20
+	 * otherwise.  If this fault ever gets "unreserved", simply move
+	 * the following code to a more suitable spot...
 	 */
=20
 ENTRY(dispatch_to_fault_handler)
@@ -1179,10 +1237,12 @@ ENTRY(dispatch_to_fault_handler)
 	;;
 	ssm psr.ic | PSR_DEFAULT_BITS
 	;;
-	srlz.i					// guarantee that interruption collection is on
+	srlz.i				// guarantee that interruption=20
+					//   collection is on
 	;;
-(p15)	ssm psr.i				// restore psr.i
-	adds r3=3D8,r2				// set up second base pointer for SAVE_REST
+(p15)	ssm psr.i			// restore psr.i
+	adds r3=3D8,r2			// set up second base pointer for=20
+					//   SAVE_REST
 	;;
 	SAVE_REST
 	movl r14=3Dia64_leave_kernel
@@ -1196,15 +1256,16 @@ END(dispatch_to_fault_handler)
 //
=20
 	.org ia64_ivt+0x5000
-//////////////////////////////////////////////////////////////////////////=
///////////////
+//////////////////////////////////////////////////////////////////////////
 // 0x5000 Entry 20 (size 16 bundles) Page Not Present (10,22,49)
 ENTRY(page_not_present)
 	DBG_FAULT(20)
 	mov r16=3Dcr.ifa
 	rsm psr.dt
 	/*
-	 * The Linux page fault handler doesn't expect non-present pages to be in
-	 * the TLB.  Flush the existing entry now, so we meet that expectation.
+	 * The Linux page fault handler doesn't expect non-present pages
+	 * to be in the TLB.  Flush the existing entry now, so we meet=20
+	 * that expectation.
 	 */
 	mov r17=3DPAGE_SHIFT<<2
 	;;
@@ -1216,7 +1277,7 @@ ENTRY(page_not_present)
 END(page_not_present)
=20
 	.org ia64_ivt+0x5100
-//////////////////////////////////////////////////////////////////////////=
///////////////
+//////////////////////////////////////////////////////////////////////////
 // 0x5100 Entry 21 (size 16 bundles) Key Permission (13,25,52)
 ENTRY(key_permission)
 	DBG_FAULT(21)
@@ -1229,7 +1290,7 @@ ENTRY(key_permission)
 END(key_permission)
=20
 	.org ia64_ivt+0x5200
-//////////////////////////////////////////////////////////////////////////=
///////////////
+//////////////////////////////////////////////////////////////////////////
 // 0x5200 Entry 22 (size 16 bundles) Instruction Access Rights (26)
 ENTRY(iaccess_rights)
 	DBG_FAULT(22)
@@ -1242,7 +1303,7 @@ ENTRY(iaccess_rights)
 END(iaccess_rights)
=20
 	.org ia64_ivt+0x5300
-//////////////////////////////////////////////////////////////////////////=
///////////////
+//////////////////////////////////////////////////////////////////////////
 // 0x5300 Entry 23 (size 16 bundles) Data Access Rights (14,53)
 ENTRY(daccess_rights)
 	DBG_FAULT(23)
@@ -1255,7 +1316,7 @@ ENTRY(daccess_rights)
 END(daccess_rights)
=20
 	.org ia64_ivt+0x5400
-//////////////////////////////////////////////////////////////////////////=
///////////////
+//////////////////////////////////////////////////////////////////////////
 // 0x5400 Entry 24 (size 16 bundles) General Exception (5,32,34,36,38,39)
 ENTRY(general_exception)
 	DBG_FAULT(24)
@@ -1270,7 +1331,7 @@ (p6)	br.sptk.many dispatch_illegal_op_fa
 END(general_exception)
=20
 	.org ia64_ivt+0x5500
-//////////////////////////////////////////////////////////////////////////=
///////////////
+//////////////////////////////////////////////////////////////////////////
 // 0x5500 Entry 25 (size 16 bundles) Disabled FP-Register (35)
 ENTRY(disabled_fp_reg)
 	DBG_FAULT(25)
@@ -1283,7 +1344,7 @@ ENTRY(disabled_fp_reg)
 END(disabled_fp_reg)
=20
 	.org ia64_ivt+0x5600
-//////////////////////////////////////////////////////////////////////////=
///////////////
+//////////////////////////////////////////////////////////////////////////
 // 0x5600 Entry 26 (size 16 bundles) Nat Consumption (11,23,37,50)
 ENTRY(nat_consumption)
 	DBG_FAULT(26)
@@ -1297,7 +1358,8 @@ ENTRY(nat_consumption)
 	;;
 	cmp.ne.or p6,p0=3DIA64_ISR_CODE_LFETCH,r18
 	dep r16=3D-1,r16,IA64_PSR_ED_BIT,1
-(p6)	br.cond.spnt 1f		// branch if (cr.ispr.na =3D 0 || cr.ipsr.code{3:0} =
!=3D LFETCH)
+(p6)	br.cond.spnt 1f		// branch if (cr.ispr.na =3D 0 ||=20
+				//            cr.ipsr.code{3:0} !=3D LFETCH)
 	;;
 	mov cr.ipsr=3Dr16		// set cr.ipsr.na
 	mov pr=3Dr31,-1
@@ -1310,17 +1372,18 @@ (p6)	br.cond.spnt 1f		// branch if (cr.i
 END(nat_consumption)
=20
 	.org ia64_ivt+0x5700
-//////////////////////////////////////////////////////////////////////////=
///////////////
+//////////////////////////////////////////////////////////////////////////
 // 0x5700 Entry 27 (size 16 bundles) Speculation (40)
 ENTRY(speculation_vector)
 	DBG_FAULT(27)
 	/*
-	 * A [f]chk.[as] instruction needs to take the branch to the recovery cod=
e but
-	 * this part of the architecture is not implemented in hardware on some C=
PUs, such
-	 * as Itanium.  Thus, in general we need to emulate the behavior.  IIM co=
ntains
-	 * the relative target (not yet sign extended).  So after sign extending =
it we
-	 * simply add it to IIP.  We also need to reset the EI field of the IPSR =
to zero,
-	 * i.e., the slot to restart into.
+	 * A [f]chk.[as] instruction needs to take the branch to the=20
+	 * recovery code but this part of the architecture is not=20
+	 * implemented in hardware on some CPUs, such as Itanium.  Thus,
+	 * in general we need to emulate the behavior.  IIM contains the
+	 * relative target (not yet sign extended).  So after sign extending
+	 * it we simply add it to IIP.  We also need to reset the EI field
+	 * of the IPSR to zero, i.e., the slot to restart into.
 	 *
 	 * cr.imm contains zero_ext(imm21)
 	 */
@@ -1347,13 +1410,13 @@ ENTRY(speculation_vector)
 END(speculation_vector)
=20
 	.org ia64_ivt+0x5800
-//////////////////////////////////////////////////////////////////////////=
///////////////
+//////////////////////////////////////////////////////////////////////////
 // 0x5800 Entry 28 (size 16 bundles) Reserved
 	DBG_FAULT(28)
 	FAULT(28)
=20
 	.org ia64_ivt+0x5900
-//////////////////////////////////////////////////////////////////////////=
///////////////
+//////////////////////////////////////////////////////////////////////////
 // 0x5900 Entry 29 (size 16 bundles) Debug (16,28,56)
 ENTRY(debug_vector)
 	DBG_FAULT(29)
@@ -1361,7 +1424,7 @@ ENTRY(debug_vector)
 END(debug_vector)
=20
 	.org ia64_ivt+0x5a00
-//////////////////////////////////////////////////////////////////////////=
///////////////
+//////////////////////////////////////////////////////////////////////////
 // 0x5a00 Entry 30 (size 16 bundles) Unaligned Reference (57)
 ENTRY(unaligned_access)
 	DBG_FAULT(30)
@@ -1371,7 +1434,7 @@ ENTRY(unaligned_access)
 END(unaligned_access)
=20
 	.org ia64_ivt+0x5b00
-//////////////////////////////////////////////////////////////////////////=
///////////////
+//////////////////////////////////////////////////////////////////////////
 // 0x5b00 Entry 31 (size 16 bundles) Unsupported Data Reference (57)
 ENTRY(unsupported_data_reference)
 	DBG_FAULT(31)
@@ -1379,7 +1442,7 @@ ENTRY(unsupported_data_reference)
 END(unsupported_data_reference)
=20
 	.org ia64_ivt+0x5c00
-//////////////////////////////////////////////////////////////////////////=
///////////////
+//////////////////////////////////////////////////////////////////////////
 // 0x5c00 Entry 32 (size 16 bundles) Floating-Point Fault (64)
 ENTRY(floating_point_fault)
 	DBG_FAULT(32)
@@ -1387,7 +1450,7 @@ ENTRY(floating_point_fault)
 END(floating_point_fault)
=20
 	.org ia64_ivt+0x5d00
-//////////////////////////////////////////////////////////////////////////=
///////////////
+//////////////////////////////////////////////////////////////////////////
 // 0x5d00 Entry 33 (size 16 bundles) Floating Point Trap (66)
 ENTRY(floating_point_trap)
 	DBG_FAULT(33)
@@ -1395,7 +1458,7 @@ ENTRY(floating_point_trap)
 END(floating_point_trap)
=20
 	.org ia64_ivt+0x5e00
-//////////////////////////////////////////////////////////////////////////=
///////////////
+//////////////////////////////////////////////////////////////////////////
 // 0x5e00 Entry 34 (size 16 bundles) Lower Privilege Transfer Trap (66)
 ENTRY(lower_privilege_trap)
 	DBG_FAULT(34)
@@ -1403,7 +1466,7 @@ ENTRY(lower_privilege_trap)
 END(lower_privilege_trap)
=20
 	.org ia64_ivt+0x5f00
-//////////////////////////////////////////////////////////////////////////=
///////////////
+//////////////////////////////////////////////////////////////////////////
 // 0x5f00 Entry 35 (size 16 bundles) Taken Branch Trap (68)
 ENTRY(taken_branch_trap)
 	DBG_FAULT(35)
@@ -1411,7 +1474,7 @@ ENTRY(taken_branch_trap)
 END(taken_branch_trap)
=20
 	.org ia64_ivt+0x6000
-//////////////////////////////////////////////////////////////////////////=
///////////////
+//////////////////////////////////////////////////////////////////////////
 // 0x6000 Entry 36 (size 16 bundles) Single Step Trap (69)
 ENTRY(single_step_trap)
 	DBG_FAULT(36)
@@ -1419,63 +1482,65 @@ ENTRY(single_step_trap)
 END(single_step_trap)
=20
 	.org ia64_ivt+0x6100
-//////////////////////////////////////////////////////////////////////////=
///////////////
+//////////////////////////////////////////////////////////////////////////
 // 0x6100 Entry 37 (size 16 bundles) Reserved
 	DBG_FAULT(37)
 	FAULT(37)
=20
 	.org ia64_ivt+0x6200
-//////////////////////////////////////////////////////////////////////////=
///////////////
+//////////////////////////////////////////////////////////////////////////
 // 0x6200 Entry 38 (size 16 bundles) Reserved
 	DBG_FAULT(38)
 	FAULT(38)
=20
 	.org ia64_ivt+0x6300
-//////////////////////////////////////////////////////////////////////////=
///////////////
+//////////////////////////////////////////////////////////////////////////
 // 0x6300 Entry 39 (size 16 bundles) Reserved
 	DBG_FAULT(39)
 	FAULT(39)
=20
 	.org ia64_ivt+0x6400
-//////////////////////////////////////////////////////////////////////////=
///////////////
+//////////////////////////////////////////////////////////////////////////
 // 0x6400 Entry 40 (size 16 bundles) Reserved
 	DBG_FAULT(40)
 	FAULT(40)
=20
 	.org ia64_ivt+0x6500
-//////////////////////////////////////////////////////////////////////////=
///////////////
+//////////////////////////////////////////////////////////////////////////
 // 0x6500 Entry 41 (size 16 bundles) Reserved
 	DBG_FAULT(41)
 	FAULT(41)
=20
 	.org ia64_ivt+0x6600
-//////////////////////////////////////////////////////////////////////////=
///////////////
+//////////////////////////////////////////////////////////////////////////
 // 0x6600 Entry 42 (size 16 bundles) Reserved
 	DBG_FAULT(42)
 	FAULT(42)
=20
 	.org ia64_ivt+0x6700
-//////////////////////////////////////////////////////////////////////////=
///////////////
+//////////////////////////////////////////////////////////////////////////
 // 0x6700 Entry 43 (size 16 bundles) Reserved
 	DBG_FAULT(43)
 	FAULT(43)
=20
 	.org ia64_ivt+0x6800
-//////////////////////////////////////////////////////////////////////////=
///////////////
+//////////////////////////////////////////////////////////////////////////
 // 0x6800 Entry 44 (size 16 bundles) Reserved
 	DBG_FAULT(44)
 	FAULT(44)
=20
 	.org ia64_ivt+0x6900
-//////////////////////////////////////////////////////////////////////////=
///////////////
-// 0x6900 Entry 45 (size 16 bundles) IA-32 Exeception (17,18,29,41,42,43,4=
4,58,60,61,62,72,73,75,76,77)
+//////////////////////////////////////////////////////////////////////////
+// 0x6900 Entry 45 (size 16 bundles) IA-32 Exeception (17,18,29,41,42,43,
+//                                                     44,58,60,61,62,72,
+//                                                     73,75,76,77)
 ENTRY(ia32_exception)
 	DBG_FAULT(45)
 	FAULT(45)
 END(ia32_exception)
=20
 	.org ia64_ivt+0x6a00
-//////////////////////////////////////////////////////////////////////////=
///////////////
+//////////////////////////////////////////////////////////////////////////
 // 0x6a00 Entry 46 (size 16 bundles) IA-32 Intercept  (30,31,59,70,71)
 ENTRY(ia32_intercept)
 	DBG_FAULT(46)
@@ -1505,7 +1570,7 @@ #endif	// CONFIG_IA32_SUPPORT
 END(ia32_intercept)
=20
 	.org ia64_ivt+0x6b00
-//////////////////////////////////////////////////////////////////////////=
///////////////
+//////////////////////////////////////////////////////////////////////////
 // 0x6b00 Entry 47 (size 16 bundles) IA-32 Interrupt  (74)
 ENTRY(ia32_interrupt)
 	DBG_FAULT(47)
@@ -1518,121 +1583,121 @@ #endif
 END(ia32_interrupt)
=20
 	.org ia64_ivt+0x6c00
-//////////////////////////////////////////////////////////////////////////=
///////////////
+//////////////////////////////////////////////////////////////////////////
 // 0x6c00 Entry 48 (size 16 bundles) Reserved
 	DBG_FAULT(48)
 	FAULT(48)
=20
 	.org ia64_ivt+0x6d00
-//////////////////////////////////////////////////////////////////////////=
///////////////
+//////////////////////////////////////////////////////////////////////////
 // 0x6d00 Entry 49 (size 16 bundles) Reserved
 	DBG_FAULT(49)
 	FAULT(49)
=20
 	.org ia64_ivt+0x6e00
-//////////////////////////////////////////////////////////////////////////=
///////////////
+//////////////////////////////////////////////////////////////////////////
 // 0x6e00 Entry 50 (size 16 bundles) Reserved
 	DBG_FAULT(50)
 	FAULT(50)
=20
 	.org ia64_ivt+0x6f00
-//////////////////////////////////////////////////////////////////////////=
///////////////
+//////////////////////////////////////////////////////////////////////////
 // 0x6f00 Entry 51 (size 16 bundles) Reserved
 	DBG_FAULT(51)
 	FAULT(51)
=20
 	.org ia64_ivt+0x7000
-//////////////////////////////////////////////////////////////////////////=
///////////////
+//////////////////////////////////////////////////////////////////////////
 // 0x7000 Entry 52 (size 16 bundles) Reserved
 	DBG_FAULT(52)
 	FAULT(52)
=20
 	.org ia64_ivt+0x7100
-//////////////////////////////////////////////////////////////////////////=
///////////////
+//////////////////////////////////////////////////////////////////////////
 // 0x7100 Entry 53 (size 16 bundles) Reserved
 	DBG_FAULT(53)
 	FAULT(53)
=20
 	.org ia64_ivt+0x7200
-//////////////////////////////////////////////////////////////////////////=
///////////////
+//////////////////////////////////////////////////////////////////////////
 // 0x7200 Entry 54 (size 16 bundles) Reserved
 	DBG_FAULT(54)
 	FAULT(54)
=20
 	.org ia64_ivt+0x7300
-//////////////////////////////////////////////////////////////////////////=
///////////////
+//////////////////////////////////////////////////////////////////////////
 // 0x7300 Entry 55 (size 16 bundles) Reserved
 	DBG_FAULT(55)
 	FAULT(55)
=20
 	.org ia64_ivt+0x7400
-//////////////////////////////////////////////////////////////////////////=
///////////////
+//////////////////////////////////////////////////////////////////////////
 // 0x7400 Entry 56 (size 16 bundles) Reserved
 	DBG_FAULT(56)
 	FAULT(56)
=20
 	.org ia64_ivt+0x7500
-//////////////////////////////////////////////////////////////////////////=
///////////////
+//////////////////////////////////////////////////////////////////////////
 // 0x7500 Entry 57 (size 16 bundles) Reserved
 	DBG_FAULT(57)
 	FAULT(57)
=20
 	.org ia64_ivt+0x7600
-//////////////////////////////////////////////////////////////////////////=
///////////////
+//////////////////////////////////////////////////////////////////////////
 // 0x7600 Entry 58 (size 16 bundles) Reserved
 	DBG_FAULT(58)
 	FAULT(58)
=20
 	.org ia64_ivt+0x7700
-//////////////////////////////////////////////////////////////////////////=
///////////////
+//////////////////////////////////////////////////////////////////////////
 // 0x7700 Entry 59 (size 16 bundles) Reserved
 	DBG_FAULT(59)
 	FAULT(59)
=20
 	.org ia64_ivt+0x7800
-//////////////////////////////////////////////////////////////////////////=
///////////////
+//////////////////////////////////////////////////////////////////////////
 // 0x7800 Entry 60 (size 16 bundles) Reserved
 	DBG_FAULT(60)
 	FAULT(60)
=20
 	.org ia64_ivt+0x7900
-//////////////////////////////////////////////////////////////////////////=
///////////////
+//////////////////////////////////////////////////////////////////////////
 // 0x7900 Entry 61 (size 16 bundles) Reserved
 	DBG_FAULT(61)
 	FAULT(61)
=20
 	.org ia64_ivt+0x7a00
-//////////////////////////////////////////////////////////////////////////=
///////////////
+//////////////////////////////////////////////////////////////////////////
 // 0x7a00 Entry 62 (size 16 bundles) Reserved
 	DBG_FAULT(62)
 	FAULT(62)
=20
 	.org ia64_ivt+0x7b00
-//////////////////////////////////////////////////////////////////////////=
///////////////
+//////////////////////////////////////////////////////////////////////////
 // 0x7b00 Entry 63 (size 16 bundles) Reserved
 	DBG_FAULT(63)
 	FAULT(63)
=20
 	.org ia64_ivt+0x7c00
-//////////////////////////////////////////////////////////////////////////=
///////////////
+//////////////////////////////////////////////////////////////////////////
 // 0x7c00 Entry 64 (size 16 bundles) Reserved
 	DBG_FAULT(64)
 	FAULT(64)
=20
 	.org ia64_ivt+0x7d00
-//////////////////////////////////////////////////////////////////////////=
///////////////
+//////////////////////////////////////////////////////////////////////////
 // 0x7d00 Entry 65 (size 16 bundles) Reserved
 	DBG_FAULT(65)
 	FAULT(65)
=20
 	.org ia64_ivt+0x7e00
-//////////////////////////////////////////////////////////////////////////=
///////////////
+//////////////////////////////////////////////////////////////////////////
 // 0x7e00 Entry 66 (size 16 bundles) Reserved
 	DBG_FAULT(66)
 	FAULT(66)
=20
 	.org ia64_ivt+0x7f00
-//////////////////////////////////////////////////////////////////////////=
///////////////
+//////////////////////////////////////////////////////////////////////////
 // 0x7f00 Entry 67 (size 16 bundles) Reserved
 	DBG_FAULT(67)
 	FAULT(67)
@@ -1640,10 +1705,10 @@ END(ia32_interrupt)
 #ifdef CONFIG_IA32_SUPPORT
=20
 	/*
-	 * There is no particular reason for this code to be here, other than that
-	 * there happens to be space here that would go unused otherwise.  If this
-	 * fault ever gets "unreserved", simply moved the following code to a more
-	 * suitable spot...
+	 * There is no particular reason for this code to be here, other=20
+	 * than that there happens to be space here that would go unused=20
+	 * otherwise.  If this fault ever gets "unreserved", simply move
+	 * the following code to a more suitable spot...
 	 */
=20
 	// IA32 interrupt entry point
@@ -1654,7 +1719,7 @@ ENTRY(dispatch_to_ia32_handler)
 	mov r14=3Dcr.isr
 	ssm psr.ic | PSR_DEFAULT_BITS
 	;;
-	srlz.i					// guarantee that interruption collection is on
+	srlz.i			// guarantee that interruption collection is on
 	;;
 (p15)	ssm psr.i
 	adds r3=3D8,r2		// Base pointer for SAVE_REST
@@ -1667,13 +1732,15 @@ (p15)	ssm psr.i
 	cmp.ne p6,p0=3Dr14,r15
 (p6)	br.call.dpnt.many b6=3Dnon_ia32_syscall
=20
-	adds r14=3DIA64_PT_REGS_R8_OFFSET + 16,sp	// 16 byte hole per SW conventi=
ons
+	adds r14=3DIA64_PT_REGS_R8_OFFSET + 16,sp	// 16 byte hole per SW=20
+						//   conventions
 	adds r15=3DIA64_PT_REGS_R1_OFFSET + 16,sp
 	;;
 	cmp.eq pSys,pNonSys=3Dr0,r0 // set pSys=3D1, pNonSys=3D0
 	ld8 r8=3D[r14]		// get r8
 	;;
-	st8 [r15]=3Dr8		// save original EAX in r1 (IA32 procs don't use the GP)
+	st8 [r15]=3Dr8		// save original EAX in r1 (IA32 procs=20
+				//   don't use the GP)
 	;;
 	alloc r15=3Dar.pfs,0,0,6,0	// must first in an insn group
 	;;
@@ -1714,7 +1781,7 @@ non_ia32_syscall:
 	alloc r15=3Dar.pfs,0,0,2,0
 	mov out0=3Dr14				// interrupt #
 	add out1=16,sp				// pointer to pt_regs
-	;;			// avoid WAW on CFM
+	;;					// avoid WAW on CFM
 	br.call.sptk.many rp=3Dia32_bad_interrupt
 .ret1:	movl r15=3Dia64_leave_kernel
 	;;



--=20
Ciao,
al
----------------------------------------------------------------------
Al Stone                                      Alter Ego:
Open Source and Linux R&D                     Debian Developer
Hewlett-Packard Company                       http://www.debian.org
E-mail: ahs3@fc.hp.com                        ahs3@debian.org
----------------------------------------------------------------------

