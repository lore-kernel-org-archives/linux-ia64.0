From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Mon, 19 May 2008 13:13:38 +0000
Subject: [PATCH 11/17] ia64/pv_ops: paravirtualize ivt.S
Message-Id: <12112028253723-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

paravirtualize ivt.S which implements fault handler in hand written
assembly code.
They includes sensitive or performance critical privileged instructions.
So they need paravirtualization.

Cc: Keith Owens <kaos@ocs.com.au>
Cc: tgingold@free.fr
Cc: Akio Takebe <takebe_akio@jp.fujitsu.com>
Signed-off-by: Yaozu (Eddie) Dong <eddie.dong@intel.com>
Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/kernel/ivt.S |  249 +++++++++++++++++++++++---------------------=
---
 1 files changed, 122 insertions(+), 127 deletions(-)

diff --git a/arch/ia64/kernel/ivt.S b/arch/ia64/kernel/ivt.S
index 6678c49..f041daf 100644
--- a/arch/ia64/kernel/ivt.S
+++ b/arch/ia64/kernel/ivt.S
@@ -12,6 +12,14 @@
  *
  * 00/08/23 Asit Mallick <asit.k.mallick@intel.com> TLB handling for SMP
  * 00/12/20 David Mosberger-Tang <davidm@hpl.hp.com> DTLB/ITLB handler now=
 uses virtual PT.
+ *
+ * Copyright (C) 2005 Hewlett-Packard Co
+ *	Dan Magenheimer <dan.magenheimer@hp.com>
+ *      Xen paravirtualization
+ * Copyright (c) 2008 Isaku Yamahata <yamahata at valinux co jp>
+ *                    VA Linux Systems Japan K.K.
+ *                    pv_ops.
+ *      Yaozu (Eddie) Dong <eddie.dong@intel.com>
  */
 /*
  * This file defines the interruption vector table used by the CPU.
@@ -102,13 +110,13 @@ ENTRY(vhpt_miss)
 	 *	- the faulting virtual address uses unimplemented address bits
 	 *	- the faulting virtual address has no valid page table mapping
 	 */
-	mov r16=3Dcr.ifa				// get address that caused the TLB miss
+	MOV_FROM_IFA(r16)			// get address that caused the TLB miss
 #ifdef CONFIG_HUGETLB_PAGE
 	movl r18=3DPAGE_SHIFT
-	mov r25=3Dcr.itir
+	MOV_FROM_ITIR(r25)
 #endif
 	;;
-	rsm psr.dt				// use physical addressing for data
+	RSM_PSR_DT				// use physical addressing for data
 	mov r31=3Dpr				// save the predicate registers
 	mov r19=3DIA64_KR(PT_BASE)		// get page table base address
 	shl r21=3Dr16,3				// shift bit 60 into sign bit
@@ -168,21 +176,21 @@ ENTRY(vhpt_miss)
 	dep r21=3Dr19,r20,3,(PAGE_SHIFT-3)	// r21=3Dpte_offset(pmd,addr)
 	;;
 (p7)	ld8 r18=3D[r21]				// read *pte
-	mov r19=3Dcr.isr				// cr.isr bit 32 tells us if this is an insn miss
+	MOV_FROM_ISR(r19)			// cr.isr bit 32 tells us if this is an insn miss
 	;;
 (p7)	tbit.z p6,p7=3Dr18,_PAGE_P_BIT		// page present bit cleared?
-	mov r22=3Dcr.iha				// get the VHPT address that caused the TLB miss
+	MOV_FROM_IHA(r22)			// get the VHPT address that caused the TLB miss
 	;;					// avoid RAW on p7
 (p7)	tbit.nz.unc p10,p11=3Dr19,32		// is it an instruction TLB miss?
 	dep r23=3D0,r20,0,PAGE_SHIFT		// clear low bits to get page address
 	;;
-(p10)	itc.i r18				// insert the instruction TLB entry
-(p11)	itc.d r18				// insert the data TLB entry
+	ITC_I_AND_D(p10, p11, r18, r24)		// insert the instruction TLB entry and
+						// insert the data TLB entry
 (p6)	br.cond.spnt.many page_fault		// handle bad address/page not present =
(page fault)
-	mov cr.ifa=3Dr22
+	MOV_TO_IFA(r22, r24)
=20
 #ifdef CONFIG_HUGETLB_PAGE
-(p8)	mov cr.itir=3Dr25				// change to default page-size for VHPT
+	MOV_TO_ITIR(p8, r25, r24)		// change to default page-size for VHPT
 #endif
=20
 	/*
@@ -192,7 +200,7 @@ ENTRY(vhpt_miss)
 	 */
 	adds r24=3D__DIRTY_BITS_NO_ED|_PAGE_PL_0|_PAGE_AR_RW,r23
 	;;
-(p7)	itc.d r24
+	ITC_D(p7, r24, r25)
 	;;
 #ifdef CONFIG_SMP
 	/*
@@ -234,7 +242,7 @@ ENTRY(vhpt_miss)
 #endif
=20
 	mov pr=3Dr31,-1				// restore predicate registers
-	rfi
+	RFI
 END(vhpt_miss)
=20
 	.org ia64_ivt+0x400
@@ -248,11 +256,11 @@ ENTRY(itlb_miss)
 	 * mode, walk the page table, and then re-execute the PTE read and
 	 * go on normally after that.
 	 */
-	mov r16=3Dcr.ifa				// get virtual address
+	MOV_FROM_IFA(r16)			// get virtual address
 	mov r29=B0				// save b0
 	mov r31=3Dpr				// save predicates
 .itlb_fault:
-	mov r17=3Dcr.iha				// get virtual address of PTE
+	MOV_FROM_IHA(r17)			// get virtual address of PTE
 	movl r30=1F				// load nested fault continuation point
 	;;
 1:	ld8 r18=3D[r17]				// read *pte
@@ -261,7 +269,7 @@ ENTRY(itlb_miss)
 	tbit.z p6,p0=3Dr18,_PAGE_P_BIT		// page present bit cleared?
 (p6)	br.cond.spnt page_fault
 	;;
-	itc.i r18
+	ITC_I(p0, r18, r19)
 	;;
 #ifdef CONFIG_SMP
 	/*
@@ -278,7 +286,7 @@ ENTRY(itlb_miss)
 (p7)	ptc.l r16,r20
 #endif
 	mov pr=3Dr31,-1
-	rfi
+	RFI
 END(itlb_miss)
=20
 	.org ia64_ivt+0x0800
@@ -292,11 +300,11 @@ ENTRY(dtlb_miss)
 	 * mode, walk the page table, and then re-execute the PTE read and
 	 * go on normally after that.
 	 */
-	mov r16=3Dcr.ifa				// get virtual address
+	MOV_FROM_IFA(r16)			// get virtual address
 	mov r29=B0				// save b0
 	mov r31=3Dpr				// save predicates
 dtlb_fault:
-	mov r17=3Dcr.iha				// get virtual address of PTE
+	MOV_FROM_IHA(r17)			// get virtual address of PTE
 	movl r30=1F				// load nested fault continuation point
 	;;
 1:	ld8 r18=3D[r17]				// read *pte
@@ -305,7 +313,7 @@ dtlb_fault:
 	tbit.z p6,p0=3Dr18,_PAGE_P_BIT		// page present bit cleared?
 (p6)	br.cond.spnt page_fault
 	;;
-	itc.d r18
+	ITC_D(p0, r18, r19)
 	;;
 #ifdef CONFIG_SMP
 	/*
@@ -322,7 +330,7 @@ dtlb_fault:
 (p7)	ptc.l r16,r20
 #endif
 	mov pr=3Dr31,-1
-	rfi
+	RFI
 END(dtlb_miss)
=20
 	.org ia64_ivt+0x0c00
@@ -330,9 +338,9 @@ END(dtlb_miss)
 // 0x0c00 Entry 3 (size 64 bundles) Alt ITLB (19)
 ENTRY(alt_itlb_miss)
 	DBG_FAULT(3)
-	mov r16=3Dcr.ifa		// get address that caused the TLB miss
+	MOV_FROM_IFA(r16)	// get address that caused the TLB miss
 	movl r17=3DPAGE_KERNEL
-	mov r21=3Dcr.ipsr
+	MOV_FROM_IPSR(p0, r21)
 	movl r19=3D(((1 << IA64_MAX_PHYS_BITS) - 1) & ~0xfff)
 	mov r31=3Dpr
 	;;
@@ -341,9 +349,9 @@ ENTRY(alt_itlb_miss)
 	;;
 	cmp.gt p8,p0=3D6,r22			// user mode
 	;;
-(p8)	thash r17=3Dr16
+	THASH(p8, r17, r16, r23)
 	;;
-(p8)	mov cr.iha=3Dr17
+	MOV_TO_IHA(p8, r17, r23)
 (p8)	mov r29=B0				// save b0
 (p8)	br.cond.dptk .itlb_fault
 #endif
@@ -358,9 +366,9 @@ ENTRY(alt_itlb_miss)
 	or r19=3Dr19,r18		// set bit 4 (uncached) if the access was to region 6
 (p8)	br.cond.spnt page_fault
 	;;
-	itc.i r19		// insert the TLB entry
+	ITC_I(p0, r19, r18)	// insert the TLB entry
 	mov pr=3Dr31,-1
-	rfi
+	RFI
 END(alt_itlb_miss)
=20
 	.org ia64_ivt+0x1000
@@ -368,11 +376,11 @@ END(alt_itlb_miss)
 // 0x1000 Entry 4 (size 64 bundles) Alt DTLB (7,46)
 ENTRY(alt_dtlb_miss)
 	DBG_FAULT(4)
-	mov r16=3Dcr.ifa		// get address that caused the TLB miss
+	MOV_FROM_IFA(r16)	// get address that caused the TLB miss
 	movl r17=3DPAGE_KERNEL
-	mov r20=3Dcr.isr
+	MOV_FROM_ISR(r20)
 	movl r19=3D(((1 << IA64_MAX_PHYS_BITS) - 1) & ~0xfff)
-	mov r21=3Dcr.ipsr
+	MOV_FROM_IPSR(p0, r21)
 	mov r31=3Dpr
 	mov r24=3DPERCPU_ADDR
 	;;
@@ -381,9 +389,9 @@ ENTRY(alt_dtlb_miss)
 	;;
 	cmp.gt p8,p0=3D6,r22			// access to region 0-5
 	;;
-(p8)	thash r17=3Dr16
+	THASH(p8, r17, r16, r25)
 	;;
-(p8)	mov cr.iha=3Dr17
+	MOV_TO_IHA(p8, r17, r25)
 (p8)	mov r29=B0				// save b0
 (p8)	br.cond.dptk dtlb_fault
 #endif
@@ -402,7 +410,7 @@ ENTRY(alt_dtlb_miss)
 	tbit.nz p9,p0=3Dr20,IA64_ISR_NA_BIT	// is non-access bit on?
 	;;
 (p10)	sub r19=3Dr19,r26
-(p10)	mov cr.itir=3Dr25
+	MOV_TO_ITIR(p10, r25, r24)
 	cmp.ne p8,p0=3Dr0,r23
 (p9)	cmp.eq.or.andcm p6,p7=3DIA64_ISR_CODE_LFETCH,r22	// check isr.code fi=
eld
 (p12)	dep r17=3D-1,r17,4,1			// set ma=3DUC for region 6 addr
@@ -411,11 +419,11 @@ ENTRY(alt_dtlb_miss)
 	dep r21=3D-1,r21,IA64_PSR_ED_BIT,1
 	;;
 	or r19=3Dr19,r17		// insert PTE control bits into r19
-(p6)	mov cr.ipsr=3Dr21
+	MOV_TO_IPSR(p6, r21, r24)
 	;;
-(p7)	itc.d r19		// insert the TLB entry
+	ITC_D(p7, r19, r18)	// insert the TLB entry
 	mov pr=3Dr31,-1
-	rfi
+	RFI
 END(alt_dtlb_miss)
=20
 	.org ia64_ivt+0x1400
@@ -444,10 +452,10 @@ ENTRY(nested_dtlb_miss)
 	 *
 	 * Clobbered:	b0, r18, r19, r21, r22, psr.dt (cleared)
 	 */
-	rsm psr.dt				// switch to using physical data addressing
+	RSM_PSR_DT				// switch to using physical data addressing
 	mov r19=3DIA64_KR(PT_BASE)		// get the page table base address
 	shl r21=3Dr16,3				// shift bit 60 into sign bit
-	mov r18=3Dcr.itir
+	MOV_FROM_ITIR(r18)
 	;;
 	shr.u r17=3Dr16,61			// get the region number into r17
 	extr.u r18=3Dr18,2,6			// get the faulting page size
@@ -510,21 +518,15 @@ END(ikey_miss)
 	//-----------------------------------------------------------------------=
------------
 	// call do_page_fault (predicates are in r31, psr.dt may be off, r16 is f=
aulting address)
 ENTRY(page_fault)
-	ssm psr.dt
-	;;
-	srlz.i
+	SSM_PSR_DT_AND_SRLZ_I
 	;;
 	SAVE_MIN_WITH_COVER
 	alloc r15=3Dar.pfs,0,0,3,0
-	mov out0=3Dcr.ifa
-	mov out1=3Dcr.isr
+	MOV_FROM_IFA(out0)
+	MOV_FROM_ISR(out1)
+	SSM_PSR_IC_AND_DEFAULT_BITS_AND_SRLZ_I(r14, r3)
 	adds r3=3D8,r2				// set up second base pointer
-	;;
-	ssm psr.ic | PSR_DEFAULT_BITS
-	;;
-	srlz.i					// guarantee that interruption collectin is on
-	;;
-(p15)	ssm psr.i				// restore psr.i
+	SSM_PSR_I(p15, p15, r14)		// restore psr.i
 	movl r14=3Dia64_leave_kernel
 	;;
 	SAVE_REST
@@ -556,10 +558,10 @@ ENTRY(dirty_bit)
 	 * page table TLB entry isn't present, we take a nested TLB miss hit wher=
e we look
 	 * up the physical address of the L3 PTE and then continue at label 1 bel=
ow.
 	 */
-	mov r16=3Dcr.ifa				// get the address that caused the fault
+	MOV_FROM_IFA(r16)			// get the address that caused the fault
 	movl r30=1F				// load continuation point in case of nested fault
 	;;
-	thash r17=3Dr16				// compute virtual address of L3 PTE
+	THASH(p0, r17, r16, r18)		// compute virtual address of L3 PTE
 	mov r29=B0				// save b0 in case of nested fault
 	mov r31=3Dpr				// save pr
 #ifdef CONFIG_SMP
@@ -576,7 +578,7 @@ ENTRY(dirty_bit)
 	;;
 (p6)	cmp.eq p6,p7=3Dr26,r18			// Only compare if page is present
 	;;
-(p6)	itc.d r25				// install updated PTE
+	ITC_D(p6, r25, r18)			// install updated PTE
 	;;
 	/*
 	 * Tell the assemblers dependency-violation checker that the above "itc" =
instructions
@@ -602,7 +604,7 @@ ENTRY(dirty_bit)
 	itc.d r18				// install updated PTE
 #endif
 	mov pr=3Dr31,-1				// restore pr
-	rfi
+	RFI
 END(dirty_bit)
=20
 	.org ia64_ivt+0x2400
@@ -611,22 +613,22 @@ END(dirty_bit)
 ENTRY(iaccess_bit)
 	DBG_FAULT(9)
 	// Like Entry 8, except for instruction access
-	mov r16=3Dcr.ifa				// get the address that caused the fault
+	MOV_FROM_IFA(r16)			// get the address that caused the fault
 	movl r30=1F				// load continuation point in case of nested fault
 	mov r31=3Dpr				// save predicates
 #ifdef CONFIG_ITANIUM
 	/*
 	 * Erratum 10 (IFA may contain incorrect address) has "NoFix" status.
 	 */
-	mov r17=3Dcr.ipsr
+	MOV_FROM_IPSR(p0, r17)
 	;;
-	mov r18=3Dcr.iip
+	MOV_FROM_IIP(r18)
 	tbit.z p6,p0=3Dr17,IA64_PSR_IS_BIT	// IA64 instruction set?
 	;;
 (p6)	mov r16=3Dr18				// if so, use cr.iip instead of cr.ifa
 #endif /* CONFIG_ITANIUM */
 	;;
-	thash r17=3Dr16				// compute virtual address of L3 PTE
+	THASH(p0, r17, r16, r18)		// compute virtual address of L3 PTE
 	mov r29=B0				// save b0 in case of nested fault)
 #ifdef CONFIG_SMP
 	mov r28=3Dar.ccv				// save ar.ccv
@@ -642,7 +644,7 @@ ENTRY(iaccess_bit)
 	;;
 (p6)	cmp.eq p6,p7=3Dr26,r18			// Only if page present
 	;;
-(p6)	itc.i r25				// install updated PTE
+	ITC_I(p6, r25, r26)			// install updated PTE
 	;;
 	/*
 	 * Tell the assemblers dependency-violation checker that the above "itc" =
instructions
@@ -668,7 +670,7 @@ ENTRY(iaccess_bit)
 	itc.i r18				// install updated PTE
 #endif /* !CONFIG_SMP */
 	mov pr=3Dr31,-1
-	rfi
+	RFI
 END(iaccess_bit)
=20
 	.org ia64_ivt+0x2800
@@ -677,10 +679,10 @@ END(iaccess_bit)
 ENTRY(daccess_bit)
 	DBG_FAULT(10)
 	// Like Entry 8, except for data access
-	mov r16=3Dcr.ifa				// get the address that caused the fault
+	MOV_FROM_IFA(r16)			// get the address that caused the fault
 	movl r30=1F				// load continuation point in case of nested fault
 	;;
-	thash r17=3Dr16				// compute virtual address of L3 PTE
+	THASH(p0, r17, r16, r18)		// compute virtual address of L3 PTE
 	mov r31=3Dpr
 	mov r29=B0				// save b0 in case of nested fault)
 #ifdef CONFIG_SMP
@@ -697,7 +699,7 @@ ENTRY(daccess_bit)
 	;;
 (p6)	cmp.eq p6,p7=3Dr26,r18			// Only if page is present
 	;;
-(p6)	itc.d r25				// install updated PTE
+	ITC_D(p6, r25, r26)			// install updated PTE
 	/*
 	 * Tell the assemblers dependency-violation checker that the above "itc" =
instructions
 	 * cannot possibly affect the following loads:
@@ -721,7 +723,7 @@ ENTRY(daccess_bit)
 #endif
 	mov b0=3Dr29				// restore b0
 	mov pr=3Dr31,-1
-	rfi
+	RFI
 END(daccess_bit)
=20
 	.org ia64_ivt+0x2c00
@@ -745,10 +747,10 @@ ENTRY(break_fault)
 	 */
 	DBG_FAULT(11)
 	mov.m r16=3DIA64_KR(CURRENT)		// M2 r16 <- current task (12 cyc)
-	mov r29=3Dcr.ipsr				// M2 (12 cyc)
+	MOV_FROM_IPSR(p0, r29)			// M2 (12 cyc)
 	mov r31=3Dpr				// I0 (2 cyc)
=20
-	mov r17=3Dcr.iim				// M2 (2 cyc)
+	MOV_FROM_IIM(r17)			// M2 (2 cyc)
 	mov.m r27=3Dar.rsc			// M2 (12 cyc)
 	mov r18=3D__IA64_BREAK_SYSCALL		// A
=20
@@ -767,7 +769,7 @@ ENTRY(break_fault)
 	nop.m 0
 	movl r30=3Dsys_call_table			// X
=20
-	mov r28=3Dcr.iip				// M2 (2 cyc)
+	MOV_FROM_IIP(r28)			// M2 (2 cyc)
 	cmp.eq p0,p7=3Dr18,r17			// I0 is this a system call?
 (p7)	br.cond.spnt non_syscall		// B  no ->
 	//
@@ -864,18 +866,17 @@ ENTRY(break_fault)
 #endif
 	mov ar.rsc=3D0x3				// M2   set eager mode, pl 0, LE, loadrs=3D0
 	nop 0
-	bsw.1					// B (6 cyc) regs are saved, switch to bank 1
+	BSW_1(r2, r14)				// B (6 cyc) regs are saved, switch to bank 1
 	;;
=20
-	ssm psr.ic | PSR_DEFAULT_BITS		// M2	now it's safe to re-enable intr.-col=
lection
+	SSM_PSR_IC_AND_DEFAULT_BITS_AND_SRLZ_I(r3, r16)	// M2	now it's safe to re=
-enable intr.-collection
+						// M0   ensure interruption collection is on
 	movl r3=3Dia64_ret_from_syscall		// X
 	;;
-
-	srlz.i					// M0   ensure interruption collection is on
 	mov rp=3Dr3				// I0   set the real return addr
 (p10)	br.cond.spnt.many ia64_ret_from_syscall	// B    return if bad call-f=
rame or r15 is a NaT
=20
-(p15)	ssm psr.i				// M2   restore psr.i
+	SSM_PSR_I(p15, p15, r16)		// M2   restore psr.i
 (p14)	br.call.sptk.many b6=B6			// B    invoke syscall-handker (ignore ret=
urn addr)
 	br.cond.spnt.many ia64_trace_syscall	// B	do syscall-tracing thingamagic
 	// NOT REACHED
@@ -899,16 +900,15 @@ ENTRY(interrupt)
 	mov r31=3Dpr		// prepare to save predicates
 	;;
 	SAVE_MIN_WITH_COVER	// uses r31; defines r2 and r3
-	ssm psr.ic | PSR_DEFAULT_BITS
-	;;
+	SSM_PSR_IC_AND_DEFAULT_BITS_AND_SRLZ_I(r3, r14)
+				// ensure everybody knows psr.ic is back on
 	adds r3=3D8,r2		// set up second base pointer for SAVE_REST
-	srlz.i			// ensure everybody knows psr.ic is back on
 	;;
 	SAVE_REST
 	;;
 	MCA_RECOVER_RANGE(interrupt)
 	alloc r14=3Dar.pfs,0,0,2,0 // must be first in an insn group
-	mov out0=3Dcr.ivr		// pass cr.ivr as first arg
+	MOV_FROM_IVR(out0, r8)	// pass cr.ivr as first arg
 	add out1=16,sp		// pass pointer to pt_regs as second arg
 	;;
 	srlz.d			// make sure we see the effect of cr.ivr
@@ -978,6 +978,7 @@ END(interrupt)
 	 *	- ar.fpsr: set to kernel settings
 	 *	-  b6: preserved (same as on entry)
 	 */
+#ifdef __IA64_ASM_PARAVIRTUALIZED_NATIVE
 GLOBAL_ENTRY(ia64_syscall_setup)
 #if PT(B6) !=3D 0
 # error This code assumes that b6 is the first field in pt_regs.
@@ -1069,6 +1070,7 @@ GLOBAL_ENTRY(ia64_syscall_setup)
 (p10)	mov r8=3D-EINVAL
 	br.ret.sptk.many b7
 END(ia64_syscall_setup)
+#endif /* __IA64_ASM_PARAVIRTUALIZED_NATIVE */
=20
 	.org ia64_ivt+0x3c00
 //////////////////////////////////////////////////////////////////////////=
///////////////
@@ -1089,11 +1091,10 @@ ENTRY(dispatch_illegal_op_fault)
 	.prologue
 	.body
 	SAVE_MIN_WITH_COVER
-	ssm psr.ic | PSR_DEFAULT_BITS
+	SSM_PSR_IC_AND_DEFAULT_BITS_AND_SRLZ_I(r3, r24)
+				// guarantee that interruption collection is on
 	;;
-	srlz.i		// guarantee that interruption collection is on
-	;;
-(p15)	ssm psr.i	// restore psr.i
+	SSM_PSR_I(p15, p15, r3)	// restore psr.i
 	adds r3=3D8,r2	// set up second base pointer for SAVE_REST
 	;;
 	alloc r14=3Dar.pfs,0,0,1,0	// must be first in insn group
@@ -1124,7 +1125,7 @@ END(dispatch_illegal_op_fault)
 	DBG_FAULT(16)
 	FAULT(16)
=20
-#ifdef CONFIG_VIRT_CPU_ACCOUNTING
+#if defined(CONFIG_VIRT_CPU_ACCOUNTING) && defined(__IA64_ASM_PARAVIRTUALI=
ZED_NATIVE)
 	/*
 	 * There is no particular reason for this code to be here, other than
 	 * that there happens to be space here that would go unused otherwise.
@@ -1134,7 +1135,7 @@ END(dispatch_illegal_op_fault)
 	 * account_sys_enter is called from SAVE_MIN* macros if accounting is
 	 * enabled and if the macro is entered from user mode.
 	 */
-ENTRY(account_sys_enter)
+GLOBAL_ENTRY(account_sys_enter)
 	// mov.m r20=3Dar.itc is called in advance, and r13 is current
 	add r16=3DTI_AC_STAMP+IA64_TASK_SIZE,r13
 	add r17=3DTI_AC_LEAVE+IA64_TASK_SIZE,r13
@@ -1176,15 +1177,13 @@ ENTRY(non_syscall)
 	// suitable spot...
=20
 	alloc r14=3Dar.pfs,0,0,2,0
-	mov out0=3Dcr.iim
+	MOV_FROM_IIM(out0)
 	add out1=16,sp
 	adds r3=3D8,r2			// set up second base pointer for SAVE_REST
=20
-	ssm psr.ic | PSR_DEFAULT_BITS
-	;;
-	srlz.i				// guarantee that interruption collection is on
-	;;
-(p15)	ssm psr.i			// restore psr.i
+	SSM_PSR_IC_AND_DEFAULT_BITS_AND_SRLZ_I(r15, r24)
+					// guarantee that interruption collection is on
+	SSM_PSR_I(p15, p15, r15)	// restore psr.i
 	movl r15=3Dia64_leave_kernel
 	;;
 	SAVE_REST
@@ -1210,14 +1209,12 @@ ENTRY(dispatch_unaligned_handler)
 	SAVE_MIN_WITH_COVER
 	;;
 	alloc r14=3Dar.pfs,0,0,2,0		// now it's safe (must be first in insn group=
!)
-	mov out0=3Dcr.ifa
+	MOV_FROM_IFA(out0)
 	adds out1=16,sp
=20
-	ssm psr.ic | PSR_DEFAULT_BITS
-	;;
-	srlz.i					// guarantee that interruption collection is on
-	;;
-(p15)	ssm psr.i				// restore psr.i
+	SSM_PSR_IC_AND_DEFAULT_BITS_AND_SRLZ_I(r3, r24)
+						// guarantee that interruption collection is on
+	SSM_PSR_I(p15, p15, r3)			// restore psr.i
 	adds r3=3D8,r2				// set up second base pointer
 	;;
 	SAVE_REST
@@ -1249,17 +1246,16 @@ ENTRY(dispatch_to_fault_handler)
 	 */
 	SAVE_MIN_WITH_COVER_R19
 	alloc r14=3Dar.pfs,0,0,5,0
-	mov out0=3Dr15
-	mov out1=3Dcr.isr
-	mov out2=3Dcr.ifa
-	mov out3=3Dcr.iim
-	mov out4=3Dcr.itir
-	;;
-	ssm psr.ic | PSR_DEFAULT_BITS
+	MOV_FROM_ISR(out1)
+	MOV_FROM_IFA(out2)
+	MOV_FROM_IIM(out3)
+	MOV_FROM_ITIR(out4)
 	;;
-	srlz.i					// guarantee that interruption collection is on
+	SSM_PSR_IC_AND_DEFAULT_BITS_AND_SRLZ_I(r3, out0)
+						// guarantee that interruption collection is on
+	mov out0=3Dr15
 	;;
-(p15)	ssm psr.i				// restore psr.i
+	SSM_PSR_I(p15, p15, r3)			// restore psr.i
 	adds r3=3D8,r2				// set up second base pointer for SAVE_REST
 	;;
 	SAVE_REST
@@ -1278,8 +1274,8 @@ END(dispatch_to_fault_handler)
 // 0x5000 Entry 20 (size 16 bundles) Page Not Present (10,22,49)
 ENTRY(page_not_present)
 	DBG_FAULT(20)
-	mov r16=3Dcr.ifa
-	rsm psr.dt
+	MOV_FROM_IFA(r16)
+	RSM_PSR_DT
 	/*
 	 * The Linux page fault handler doesn't expect non-present pages to be in
 	 * the TLB.  Flush the existing entry now, so we meet that expectation.
@@ -1298,8 +1294,8 @@ END(page_not_present)
 // 0x5100 Entry 21 (size 16 bundles) Key Permission (13,25,52)
 ENTRY(key_permission)
 	DBG_FAULT(21)
-	mov r16=3Dcr.ifa
-	rsm psr.dt
+	MOV_FROM_IFA(r16)
+	RSM_PSR_DT
 	mov r31=3Dpr
 	;;
 	srlz.d
@@ -1311,8 +1307,8 @@ END(key_permission)
 // 0x5200 Entry 22 (size 16 bundles) Instruction Access Rights (26)
 ENTRY(iaccess_rights)
 	DBG_FAULT(22)
-	mov r16=3Dcr.ifa
-	rsm psr.dt
+	MOV_FROM_IFA(r16)
+	RSM_PSR_DT
 	mov r31=3Dpr
 	;;
 	srlz.d
@@ -1324,8 +1320,8 @@ END(iaccess_rights)
 // 0x5300 Entry 23 (size 16 bundles) Data Access Rights (14,53)
 ENTRY(daccess_rights)
 	DBG_FAULT(23)
-	mov r16=3Dcr.ifa
-	rsm psr.dt
+	MOV_FROM_IFA(r16)
+	RSM_PSR_DT
 	mov r31=3Dpr
 	;;
 	srlz.d
@@ -1337,7 +1333,7 @@ END(daccess_rights)
 // 0x5400 Entry 24 (size 16 bundles) General Exception (5,32,34,36,38,39)
 ENTRY(general_exception)
 	DBG_FAULT(24)
-	mov r16=3Dcr.isr
+	MOV_FROM_ISR(r16)
 	mov r31=3Dpr
 	;;
 	cmp4.eq p6,p0=3D0,r16
@@ -1366,8 +1362,8 @@ END(disabled_fp_reg)
 ENTRY(nat_consumption)
 	DBG_FAULT(26)
=20
-	mov r16=3Dcr.ipsr
-	mov r17=3Dcr.isr
+	MOV_FROM_IPSR(p0, r16)
+	MOV_FROM_ISR(r17)
 	mov r31=3Dpr				// save PR
 	;;
 	and r18=3D0xf,r17				// r18 =3D cr.ipsr.code{3:0}
@@ -1377,10 +1373,10 @@ ENTRY(nat_consumption)
 	dep r16=3D-1,r16,IA64_PSR_ED_BIT,1
 (p6)	br.cond.spnt 1f		// branch if (cr.ispr.na =3D 0 || cr.ipsr.code{3:0} =
!=3D LFETCH)
 	;;
-	mov cr.ipsr=3Dr16		// set cr.ipsr.na
+	MOV_TO_IPSR(p0, r16, r18)
 	mov pr=3Dr31,-1
 	;;
-	rfi
+	RFI
=20
 1:	mov pr=3Dr31,-1
 	;;
@@ -1402,26 +1398,26 @@ ENTRY(speculation_vector)
 	 *
 	 * cr.imm contains zero_ext(imm21)
 	 */
-	mov r18=3Dcr.iim
+	MOV_FROM_IIM(r18)
 	;;
-	mov r17=3Dcr.iip
+	MOV_FROM_IIP(r17)
 	shl r18=3Dr18,43			// put sign bit in position (43d-21)
 	;;
=20
-	mov r16=3Dcr.ipsr
+	MOV_FROM_IPSR(p0, r16)
 	shr r18=3Dr18,39			// sign extend (39C-4)
 	;;
=20
 	add r17=3Dr17,r18			// now add the offset
 	;;
-	mov cr.iip=3Dr17
+	MOV_FROM_IIP(r17)
 	dep r16=3D0,r16,41,2		// clear EI
 	;;
=20
-	mov cr.ipsr=3Dr16
+	MOV_FROM_IPSR(p0, r16)
 	;;
=20
-	rfi				// and go back
+	RFI
 END(speculation_vector)
=20
 	.org ia64_ivt+0x5800
@@ -1559,11 +1555,11 @@ ENTRY(ia32_intercept)
 	DBG_FAULT(46)
 #ifdef	CONFIG_IA32_SUPPORT
 	mov r31=3Dpr
-	mov r16=3Dcr.isr
+	MOV_FROM_ISR(r16)
 	;;
 	extr.u r17=3Dr16,16,8	// get ISR.code
 	mov r18=3Dar.eflag
-	mov r19=3Dcr.iim		// old eflag value
+	MOV_FROM_IIM(r19)	// old eflag value
 	;;
 	cmp.ne p6,p0=3D2,r17
 (p6)	br.cond.spnt 1f		// not a system flag fault
@@ -1575,7 +1571,7 @@ ENTRY(ia32_intercept)
 (p6)	br.cond.spnt 1f		// eflags.ac bit didn't change
 	;;
 	mov pr=3Dr31,-1		// restore predicate registers
-	rfi
+	RFI
=20
 1:
 #endif	// CONFIG_IA32_SUPPORT
@@ -1729,12 +1725,11 @@ END(ia32_interrupt)
 ENTRY(dispatch_to_ia32_handler)
 	SAVE_MIN
 	;;
-	mov r14=3Dcr.isr
-	ssm psr.ic | PSR_DEFAULT_BITS
-	;;
-	srlz.i					// guarantee that interruption collection is on
+	MOV_FROM_ISR(r14)
+	SSM_PSR_IC_AND_DEFAULT_BITS_AND_SRLZ_I(r3, r24)
+				// guarantee that interruption collection is on
 	;;
-(p15)	ssm psr.i
+	SSM_PSR_I(p15, p15, r3)
 	adds r3=3D8,r2		// Base pointer for SAVE_REST
 	;;
 	SAVE_REST
--=20
1.5.3

