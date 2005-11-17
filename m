From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 17 Nov 2005 21:39:10 +0000
Subject: bugfix git pull on ia64 linux tree
Message-Id: <200511172139.jAHLdAtE031181@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200509142223.j8EMN0qk011773@agluck-lia64.sc.intel.com>
In-Reply-To: <200509142223.j8EMN0qk011773@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi Linus,

One small bugfix to the 4-level page table code, plus a larger patch that
improves the comments in the assembly code handlers.

please pull from:

	git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git release

This will update the files shown below.

Thanks!

-Tony

 arch/ia64/kernel/ivt.S |  137 ++++++++++++++++++++++++++------------------=
-----
 1 files changed, 73 insertions(+), 64 deletions(-)

Chen, Kenneth W:
      [IA64] 4 level page table bug fix in vhpt_miss
      [IA64] polish comments for tlb fault handler in ivt.S

diff-tree e8aabc47168d24eabc08418db4e034a4c625721c (from fedb25fae72bc2c370=
9448a43be067439643da87)
Author: Chen, Kenneth W <kenneth.w.chen@intel.com>
Date:   Thu Nov 17 01:55:34 2005 -0800

    [IA64] polish comments for tlb fault handler in ivt.S
   =20
    Polish the comments specifically in vhpt_miss and nested_dtlb_miss
    handlers.  I think it's better to explicitly name each page table
    level with its name instead of numerically name them.  i.e., use
    pgd, pud, pmd, and pte instead of referring as L1, L2, L3 etc.
    Along the line, remove some magic number in the comments like:
    "PTA + (((IFA(61,63) << 7) | IFA(33,39))*8)".  No code change at
    all, pure comment update.  Feel free to shoot anything you have,
    darts or tomahawk cruise missile.  I will duck behind a bunker ;-)
   =20
    Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>
    Acked-by: Robin Holt <holt@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/ivt.S b/arch/ia64/kernel/ivt.S
index c71c792..301f2e9 100644
--- a/arch/ia64/kernel/ivt.S
+++ b/arch/ia64/kernel/ivt.S
@@ -91,16 +91,17 @@ ENTRY(vhpt_miss)
 	 * (the "original") TLB miss, which may either be caused by an instruction
 	 * fetch or a data access (or non-access).
 	 *
-	 * What we do here is normal TLB miss handing for the _original_ miss, fo=
llowed
-	 * by inserting the TLB entry for the virtual page table page that the VH=
PT
-	 * walker was attempting to access.  The latter gets inserted as long
-	 * as both L1 and L2 have valid mappings for the faulting address.
-	 * The TLB entry for the original miss gets inserted only if
-	 * the L3 entry indicates that the page is present.
+	 * What we do here is normal TLB miss handing for the _original_ miss,
+	 * followed by inserting the TLB entry for the virtual page table page
+	 * that the VHPT walker was attempting to access.  The latter gets
+	 * inserted as long as page table entry above pte level have valid
+	 * mappings for the faulting address.  The TLB entry for the original
+	 * miss gets inserted only if the pte entry indicates that the page is
+	 * present.
 	 *
 	 * do_page_fault gets invoked in the following cases:
 	 *	- the faulting virtual address uses unimplemented address bits
-	 *	- the faulting virtual address has no L1, L2, or L3 mapping
+	 *	- the faulting virtual address has no valid page table mapping
 	 */
 	mov r16=3Dcr.ifa				// get address that caused the TLB miss
 #ifdef CONFIG_HUGETLB_PAGE
@@ -126,7 +127,7 @@ ENTRY(vhpt_miss)
 #endif
 	;;
 	cmp.eq p6,p7=3D5,r17			// is IFA pointing into to region 5?
-	shr.u r18=3Dr22,PGDIR_SHIFT		// get bits 33-63 of the faulting address
+	shr.u r18=3Dr22,PGDIR_SHIFT		// get bottom portion of pgd index bit
 	;;
 (p7)	dep r17=3Dr17,r19,(PAGE_SHIFT-3),3	// put region number bits in place
=20
@@ -137,38 +138,38 @@ ENTRY(vhpt_miss)
 (p6)	shr.u r21=3Dr21,PGDIR_SHIFT+PAGE_SHIFT
 (p7)	shr.u r21=3Dr21,PGDIR_SHIFT+PAGE_SHIFT-3
 	;;
-(p6)	dep r17=3Dr18,r19,3,(PAGE_SHIFT-3)	// r17=3DPTA + IFA(33,42)*8
-(p7)	dep r17=3Dr18,r17,3,(PAGE_SHIFT-6)	// r17=3DPTA + (((IFA(61,63) << 7)=
 | IFA(33,39))*8)
+(p6)	dep r17=3Dr18,r19,3,(PAGE_SHIFT-3)	// r17=3Dpgd_offset for region 5
+(p7)	dep r17=3Dr18,r17,3,(PAGE_SHIFT-6)	// r17=3Dpgd_offset for region[0-4]
 	cmp.eq p7,p6=3D0,r21			// unused address bits all zeroes?
 #ifdef CONFIG_PGTABLE_4
-	shr.u r28=3Dr22,PUD_SHIFT			// shift L2 index into position
+	shr.u r28=3Dr22,PUD_SHIFT			// shift pud index into position
 #else
-	shr.u r18=3Dr22,PMD_SHIFT			// shift L3 index into position
+	shr.u r18=3Dr22,PMD_SHIFT			// shift pmd index into position
 #endif
 	;;
-	ld8 r17=3D[r17]				// fetch the L1 entry (may be 0)
+	ld8 r17=3D[r17]				// get *pgd (may be 0)
 	;;
-(p7)	cmp.eq p6,p7=3Dr17,r0			// was L1 entry NULL?
+(p7)	cmp.eq p6,p7=3Dr17,r0			// was pgd_present(*pgd) =3D NULL?
 #ifdef CONFIG_PGTABLE_4
-	dep r28=3Dr28,r17,3,(PAGE_SHIFT-3)	// compute address of L2 page table en=
try
+	dep r28=3Dr28,r17,3,(PAGE_SHIFT-3)	// r28=3Dpud_offset(pgd,addr)
 	;;
-	shr.u r18=3Dr22,PMD_SHIFT			// shift L3 index into position
-(p7)	ld8 r29=3D[r28]				// fetch the L2 entry (may be 0)
+	shr.u r18=3Dr22,PMD_SHIFT			// shift pmd index into position
+(p7)	ld8 r29=3D[r28]				// get *pud (may be 0)
 	;;
-(p7)	cmp.eq.or.andcm p6,p7=3Dr29,r0		// was L2 entry NULL?
-	dep r17=3Dr18,r29,3,(PAGE_SHIFT-3)	// compute address of L3 page table en=
try
+(p7)	cmp.eq.or.andcm p6,p7=3Dr29,r0		// was pud_present(*pud) =3D NULL?
+	dep r17=3Dr18,r29,3,(PAGE_SHIFT-3)	// r17=3Dpmd_offset(pud,addr)
 #else
-	dep r17=3Dr18,r17,3,(PAGE_SHIFT-3)	// compute address of L3 page table en=
try
+	dep r17=3Dr18,r17,3,(PAGE_SHIFT-3)	// r17=3Dpmd_offset(pgd,addr)
 #endif
 	;;
-(p7)	ld8 r20=3D[r17]				// fetch the L3 entry (may be 0)
-	shr.u r19=3Dr22,PAGE_SHIFT		// shift L4 index into position
+(p7)	ld8 r20=3D[r17]				// get *pmd (may be 0)
+	shr.u r19=3Dr22,PAGE_SHIFT		// shift pte index into position
 	;;
-(p7)	cmp.eq.or.andcm p6,p7=3Dr20,r0		// was L3 entry NULL?
-	dep r21=3Dr19,r20,3,(PAGE_SHIFT-3)	// compute address of L4 page table en=
try
+(p7)	cmp.eq.or.andcm p6,p7=3Dr20,r0		// was pmd_present(*pmd) =3D NULL?
+	dep r21=3Dr19,r20,3,(PAGE_SHIFT-3)	// r21=3Dpte_offset(pmd,addr)
 	;;
-(p7)	ld8 r18=3D[r21]				// read the L4 PTE
-	mov r19=3Dcr.isr				// cr.isr bit 0 tells us if this is an insn miss
+(p7)	ld8 r18=3D[r21]				// read *pte
+	mov r19=3Dcr.isr				// cr.isr bit 32 tells us if this is an insn miss
 	;;
 (p7)	tbit.z p6,p7=3Dr18,_PAGE_P_BIT		// page present bit cleared?
 	mov r22=3Dcr.iha				// get the VHPT address that caused the TLB miss
@@ -202,25 +203,33 @@ ENTRY(vhpt_miss)
 	dv_serialize_data
=20
 	/*
-	 * Re-check L2 and L3 pagetable.  If they changed, we may have received a=
 ptc.g
+	 * Re-check pagetable entry.  If they changed, we may have received a ptc=
.g
 	 * between reading the pagetable and the "itc".  If so, flush the entry we
-	 * inserted and retry.
+	 * inserted and retry.  At this point, we have:
+	 *
+	 * r28 =3D equivalent of pud_offset(pgd, ifa)
+	 * r17 =3D equivalent of pmd_offset(pud, ifa)
+	 * r21 =3D equivalent of pte_offset(pmd, ifa)
+	 *
+	 * r29 =3D *pud
+	 * r20 =3D *pmd
+	 * r18 =3D *pte
 	 */
-	ld8 r25=3D[r21]				// read L4 entry again
-	ld8 r26=3D[r17]				// read L3 PTE again
+	ld8 r25=3D[r21]				// read *pte again
+	ld8 r26=3D[r17]				// read *pmd again
 #ifdef CONFIG_PGTABLE_4
-	ld8 r19=3D[r28]				// read L2 entry again
+	ld8 r19=3D[r28]				// read *pud again
 #endif
 	cmp.ne p6,p7=3Dr0,r0
 	;;
-	cmp.ne.or.andcm p6,p7=3Dr26,r20		// did L3 entry change
+	cmp.ne.or.andcm p6,p7=3Dr26,r20		// did *pmd change
 #ifdef CONFIG_PGTABLE_4
-	cmp.ne.or.andcm p6,p7=3Dr19,r29		// did L4 PTE change
+	cmp.ne.or.andcm p6,p7=3Dr19,r29		// did *pud change
 #endif
 	mov r27=3DPAGE_SHIFT<<2
 	;;
 (p6)	ptc.l r22,r27				// purge PTE page translation
-(p7)	cmp.ne.or.andcm p6,p7=3Dr25,r18		// did L4 PTE change
+(p7)	cmp.ne.or.andcm p6,p7=3Dr25,r18		// did *pte change
 	;;
 (p6)	ptc.l r16,r27				// purge translation
 #endif
@@ -235,19 +244,19 @@ END(vhpt_miss)
 ENTRY(itlb_miss)
 	DBG_FAULT(1)
 	/*
-	 * The ITLB handler accesses the L3 PTE via the virtually mapped linear
+	 * The ITLB handler accesses the PTE via the virtually mapped linear
 	 * page table.  If a nested TLB miss occurs, we switch into physical
-	 * mode, walk the page table, and then re-execute the L3 PTE read
-	 * and go on normally after that.
+	 * mode, walk the page table, and then re-execute the PTE read and
+	 * go on normally after that.
 	 */
 	mov r16=3Dcr.ifa				// get virtual address
 	mov r29=B0				// save b0
 	mov r31=3Dpr				// save predicates
 .itlb_fault:
-	mov r17=3Dcr.iha				// get virtual address of L3 PTE
+	mov r17=3Dcr.iha				// get virtual address of PTE
 	movl r30=1F				// load nested fault continuation point
 	;;
-1:	ld8 r18=3D[r17]				// read L3 PTE
+1:	ld8 r18=3D[r17]				// read *pte
 	;;
 	mov b0=3Dr29
 	tbit.z p6,p0=3Dr18,_PAGE_P_BIT		// page present bit cleared?
@@ -262,7 +271,7 @@ ENTRY(itlb_miss)
 	 */
 	dv_serialize_data
=20
-	ld8 r19=3D[r17]				// read L3 PTE again and see if same
+	ld8 r19=3D[r17]				// read *pte again and see if same
 	mov r20=3DPAGE_SHIFT<<2			// setup page size for purge
 	;;
 	cmp.ne p7,p0=3Dr18,r19
@@ -279,19 +288,19 @@ END(itlb_miss)
 ENTRY(dtlb_miss)
 	DBG_FAULT(2)
 	/*
-	 * The DTLB handler accesses the L3 PTE via the virtually mapped linear
+	 * The DTLB handler accesses the PTE via the virtually mapped linear
 	 * page table.  If a nested TLB miss occurs, we switch into physical
-	 * mode, walk the page table, and then re-execute the L3 PTE read
-	 * and go on normally after that.
+	 * mode, walk the page table, and then re-execute the PTE read and
+	 * go on normally after that.
 	 */
 	mov r16=3Dcr.ifa				// get virtual address
 	mov r29=B0				// save b0
 	mov r31=3Dpr				// save predicates
 dtlb_fault:
-	mov r17=3Dcr.iha				// get virtual address of L3 PTE
+	mov r17=3Dcr.iha				// get virtual address of PTE
 	movl r30=1F				// load nested fault continuation point
 	;;
-1:	ld8 r18=3D[r17]				// read L3 PTE
+1:	ld8 r18=3D[r17]				// read *pte
 	;;
 	mov b0=3Dr29
 	tbit.z p6,p0=3Dr18,_PAGE_P_BIT		// page present bit cleared?
@@ -306,7 +315,7 @@ dtlb_fault:
 	 */
 	dv_serialize_data
=20
-	ld8 r19=3D[r17]				// read L3 PTE again and see if same
+	ld8 r19=3D[r17]				// read *pte again and see if same
 	mov r20=3DPAGE_SHIFT<<2			// setup page size for purge
 	;;
 	cmp.ne p7,p0=3Dr18,r19
@@ -420,7 +429,7 @@ ENTRY(nested_dtlb_miss)
 	 *		r30:	continuation address
 	 *		r31:	saved pr
 	 *
-	 * Output:	r17:	physical address of L3 PTE of faulting address
+	 * Output:	r17:	physical address of PTE of faulting address
 	 *		r29:	saved b0
 	 *		r30:	continuation address
 	 *		r31:	saved pr
@@ -450,33 +459,33 @@ ENTRY(nested_dtlb_miss)
 (p6)	shr.u r21=3Dr21,PGDIR_SHIFT+PAGE_SHIFT
 (p7)	shr.u r21=3Dr21,PGDIR_SHIFT+PAGE_SHIFT-3
 	;;
-(p6)	dep r17=3Dr18,r19,3,(PAGE_SHIFT-3)	// r17=3DPTA + IFA(33,42)*8
-(p7)	dep r17=3Dr18,r17,3,(PAGE_SHIFT-6)	// r17=3DPTA + (((IFA(61,63) << 7)=
 | IFA(33,39))*8)
+(p6)	dep r17=3Dr18,r19,3,(PAGE_SHIFT-3)	// r17=3Dpgd_offset for region 5
+(p7)	dep r17=3Dr18,r17,3,(PAGE_SHIFT-6)	// r17=3Dpgd_offset for region[0-4]
 	cmp.eq p7,p6=3D0,r21			// unused address bits all zeroes?
 #ifdef CONFIG_PGTABLE_4
-	shr.u r18=3Dr22,PUD_SHIFT			// shift L2 index into position
+	shr.u r18=3Dr22,PUD_SHIFT			// shift pud index into position
 #else
-	shr.u r18=3Dr22,PMD_SHIFT			// shift L3 index into position
+	shr.u r18=3Dr22,PMD_SHIFT			// shift pmd index into position
 #endif
 	;;
-	ld8 r17=3D[r17]				// fetch the L1 entry (may be 0)
+	ld8 r17=3D[r17]				// get *pgd (may be 0)
 	;;
-(p7)	cmp.eq p6,p7=3Dr17,r0			// was L1 entry NULL?
-	dep r17=3Dr18,r17,3,(PAGE_SHIFT-3)	// compute address of L2 page table en=
try
+(p7)	cmp.eq p6,p7=3Dr17,r0			// was pgd_present(*pgd) =3D NULL?
+	dep r17=3Dr18,r17,3,(PAGE_SHIFT-3)	// r17=3Dp[u|m]d_offset(pgd,addr)
 	;;
 #ifdef CONFIG_PGTABLE_4
-(p7)	ld8 r17=3D[r17]				// fetch the L2 entry (may be 0)
-	shr.u r18=3Dr22,PMD_SHIFT			// shift L3 index into position
+(p7)	ld8 r17=3D[r17]				// get *pud (may be 0)
+	shr.u r18=3Dr22,PMD_SHIFT			// shift pmd index into position
 	;;
-(p7)	cmp.eq.or.andcm p6,p7=3Dr17,r0		// was L2 entry NULL?
-	dep r17=3Dr18,r17,3,(PAGE_SHIFT-3)	// compute address of L2 page table en=
try
+(p7)	cmp.eq.or.andcm p6,p7=3Dr17,r0		// was pud_present(*pud) =3D NULL?
+	dep r17=3Dr18,r17,3,(PAGE_SHIFT-3)	// r17=3Dpmd_offset(pud,addr)
 	;;
 #endif
-(p7)	ld8 r17=3D[r17]				// fetch the L3 entry (may be 0)
-	shr.u r19=3Dr22,PAGE_SHIFT		// shift L4 index into position
+(p7)	ld8 r17=3D[r17]				// get *pmd (may be 0)
+	shr.u r19=3Dr22,PAGE_SHIFT		// shift pte index into position
 	;;
-(p7)	cmp.eq.or.andcm p6,p7=3Dr17,r0		// was L3 entry NULL?
-	dep r17=3Dr19,r17,3,(PAGE_SHIFT-3)	// compute address of L4 page table en=
try
+(p7)	cmp.eq.or.andcm p6,p7=3Dr17,r0		// was pmd_present(*pmd) =3D NULL?
+	dep r17=3Dr19,r17,3,(PAGE_SHIFT-3)	// r17=3Dpte_offset(pmd,addr);
 (p6)	br.cond.spnt page_fault
 	mov b0=3Dr30
 	br.sptk.many b0				// return to continuation point

diff-tree fedb25fae72bc2c3709448a43be067439643da87 (from 6027994423e12a3c0b=
22d3dbf9ac87364ca4e0ec)
Author: Chen, Kenneth W <kenneth.w.chen@intel.com>
Date:   Thu Nov 17 01:38:42 2005 -0800

    [IA64] 4 level page table bug fix in vhpt_miss
   =20
    From source code inspection, I think there is a bug with 4 level
    page table with vhpt_miss handler.  In the code path of rechecking
    page table entry against previously read value after tlb insertion,
    *pte value in register r18 was overwritten with value newly read
    from pud pointer, render the check of new *pte against previous
    *pte completely wrong.  Though the bug is none fatal and the penalty
    is to purge the entry and retry.  For functional correctness, it
    should be fixed.  The fix is to use a different register so new
    *pud don't trash *pte.  (btw, the comments in the cmp statement is
    wrong as well, which I will address in the next patch).
   =20
    Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/ivt.S b/arch/ia64/kernel/ivt.S
index e06f21f..c71c792 100644
--- a/arch/ia64/kernel/ivt.S
+++ b/arch/ia64/kernel/ivt.S
@@ -209,13 +209,13 @@ ENTRY(vhpt_miss)
 	ld8 r25=3D[r21]				// read L4 entry again
 	ld8 r26=3D[r17]				// read L3 PTE again
 #ifdef CONFIG_PGTABLE_4
-	ld8 r18=3D[r28]				// read L2 entry again
+	ld8 r19=3D[r28]				// read L2 entry again
 #endif
 	cmp.ne p6,p7=3Dr0,r0
 	;;
 	cmp.ne.or.andcm p6,p7=3Dr26,r20		// did L3 entry change
 #ifdef CONFIG_PGTABLE_4
-	cmp.ne.or.andcm p6,p7=3Dr29,r18		// did L4 PTE change
+	cmp.ne.or.andcm p6,p7=3Dr19,r29		// did L4 PTE change
 #endif
 	mov r27=3DPAGE_SHIFT<<2
 	;;
