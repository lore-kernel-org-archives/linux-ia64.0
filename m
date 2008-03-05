From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Wed, 05 Mar 2008 18:18:39 +0000
Subject: [PATCH 24/50] ia64/pv_ops: paravirtualize arch/ia64/kernel/ivt.S.
Message-Id: <12047411461849-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/kernel/ivt.S |  153 ++++++++++++++++++++++++--------------------=
---
 1 files changed, 78 insertions(+), 75 deletions(-)

diff --git a/arch/ia64/kernel/ivt.S b/arch/ia64/kernel/ivt.S
index 34f44d8..d1cebe5 100644
--- a/arch/ia64/kernel/ivt.S
+++ b/arch/ia64/kernel/ivt.S
@@ -12,6 +12,13 @@
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
  */
 /*
  * This file defines the interruption vector table used by the CPU.
@@ -68,6 +75,7 @@
 # define DBG_FAULT(i)
 #endif
=20
+#include "inst_paravirt.h"
 #include "minstate.h"
=20
 #define FAULT(n)									\
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
@@ -168,21 +176,20 @@ ENTRY(vhpt_miss)
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
-
+	MOV_TO_IFA(r22, r24)
 #ifdef CONFIG_HUGETLB_PAGE
-(p8)	mov cr.itir=3Dr25				// change to default page-size for VHPT
+	MOV_TO_ITIR(p8, r25, r24)		// change to default page-size for VHPT
 #endif
=20
 	/*
@@ -192,7 +199,7 @@ ENTRY(vhpt_miss)
 	 */
 	adds r24=3D__DIRTY_BITS_NO_ED|_PAGE_PL_0|_PAGE_AR_RW,r23
 	;;
-(p7)	itc.d r24
+	ITC_D(p7, r24, r25)
 	;;
 #ifdef CONFIG_SMP
 	/*
@@ -234,7 +241,7 @@ ENTRY(vhpt_miss)
 #endif
=20
 	mov pr=3Dr31,-1				// restore predicate registers
-	rfi
+	RFI
 END(vhpt_miss)
=20
 	.org ia64_ivt+0x400
@@ -248,11 +255,11 @@ ENTRY(itlb_miss)
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
@@ -261,7 +268,7 @@ ENTRY(itlb_miss)
 	tbit.z p6,p0=3Dr18,_PAGE_P_BIT		// page present bit cleared?
 (p6)	br.cond.spnt page_fault
 	;;
-	itc.i r18
+	ITC_I(p0, r18, r19)
 	;;
 #ifdef CONFIG_SMP
 	/*
@@ -278,7 +285,7 @@ ENTRY(itlb_miss)
 (p7)	ptc.l r16,r20
 #endif
 	mov pr=3Dr31,-1
-	rfi
+	RFI
 END(itlb_miss)
=20
 	.org ia64_ivt+0x0800
@@ -292,11 +299,11 @@ ENTRY(dtlb_miss)
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
@@ -305,7 +312,7 @@ dtlb_fault:
 	tbit.z p6,p0=3Dr18,_PAGE_P_BIT		// page present bit cleared?
 (p6)	br.cond.spnt page_fault
 	;;
-	itc.d r18
+	ITC_D(p0, r18, r19)
 	;;
 #ifdef CONFIG_SMP
 	/*
@@ -322,7 +329,7 @@ dtlb_fault:
 (p7)	ptc.l r16,r20
 #endif
 	mov pr=3Dr31,-1
-	rfi
+	RFI
 END(dtlb_miss)
=20
 	.org ia64_ivt+0x0c00
@@ -330,9 +337,9 @@ END(dtlb_miss)
 // 0x0c00 Entry 3 (size 64 bundles) Alt ITLB (19)
 ENTRY(alt_itlb_miss)
 	DBG_FAULT(3)
-	mov r16=3Dcr.ifa		// get address that caused the TLB miss
+	MOV_FROM_IFA(r16)	// get address that caused the TLB miss
 	movl r17=3DPAGE_KERNEL
-	mov r21=3Dcr.ipsr
+	MOV_FROM_IPSR(r21)
 	movl r19=3D(((1 << IA64_MAX_PHYS_BITS) - 1) & ~0xfff)
 	mov r31=3Dpr
 	;;
@@ -341,9 +348,9 @@ ENTRY(alt_itlb_miss)
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
@@ -358,9 +365,9 @@ ENTRY(alt_itlb_miss)
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
@@ -368,11 +375,11 @@ END(alt_itlb_miss)
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
+	MOV_FROM_IPSR(r21)
 	mov r31=3Dpr
 	mov r24=3DPERCPU_ADDR
 	;;
@@ -381,9 +388,9 @@ ENTRY(alt_dtlb_miss)
 	;;
 	cmp.gt p8,p0=3D6,r22			// access to region 0-5
 	;;
-(p8)	thash r17=3Dr16
+	THASH(p8, r17, r16, r25)
 	;;
-(p8)	mov cr.iha=3Dr17
+	MOV_TO_IHA(r17, r25)
 (p8)	mov r29=B0				// save b0
 (p8)	br.cond.dptk dtlb_fault
 #endif
@@ -402,7 +409,7 @@ ENTRY(alt_dtlb_miss)
 	tbit.nz p9,p0=3Dr20,IA64_ISR_NA_BIT	// is non-access bit on?
 	;;
 (p10)	sub r19=3Dr19,r26
-(p10)	mov cr.itir=3Dr25
+	MOV_TO_ITIR(p10, r25, r24)
 	cmp.ne p8,p0=3Dr0,r23
 (p9)	cmp.eq.or.andcm p6,p7=3DIA64_ISR_CODE_LFETCH,r22	// check isr.code fi=
eld
 (p12)	dep r17=3D-1,r17,4,1			// set ma=3DUC for region 6 addr
@@ -413,9 +420,9 @@ ENTRY(alt_dtlb_miss)
 	or r19=3Dr19,r17		// insert PTE control bits into r19
 (p6)	mov cr.ipsr=3Dr21
 	;;
-(p7)	itc.d r19		// insert the TLB entry
+	ITC_D(p7, r19, r18)	// insert the TLB entry
 	mov pr=3Dr31,-1
-	rfi
+	RFI
 END(alt_dtlb_miss)
=20
 	.org ia64_ivt+0x1400
@@ -444,10 +451,10 @@ ENTRY(nested_dtlb_miss)
 	 *
 	 * Clobbered:	b0, r18, r19, r21, r22, psr.dt (cleared)
 	 */
-	rsm psr.dt				// switch to using physical data addressing
+	RSM_PSR_DT_AND_SRLZ_I			// switch to using physical data addressing
 	mov r19=3DIA64_KR(PT_BASE)		// get the page table base address
 	shl r21=3Dr16,3				// shift bit 60 into sign bit
-	mov r18=3Dcr.itir
+	MOV_FROM_ITIR(r18)
 	;;
 	shr.u r17=3Dr16,61			// get the region number into r17
 	extr.u r18=3Dr18,2,6			// get the faulting page size
@@ -510,21 +517,15 @@ END(ikey_miss)
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
+	SSM_PSR_IC_AND_DEFAULT_BITS(r14, r3)
 	adds r3=3D8,r2				// set up second base pointer
-	;;
-	ssm psr.ic | PSR_DEFAULT_BITS
-	;;
-	srlz.i					// guarantee that interruption collectin is on
-	;;
-(p15)	ssm psr.i				// restore psr.i
+	SSM_PSR_I(p15, r14)			// restore psr.i
 	movl r14=3Dia64_leave_kernel
 	;;
 	SAVE_REST
@@ -556,10 +557,10 @@ ENTRY(dirty_bit)
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
@@ -576,7 +577,7 @@ ENTRY(dirty_bit)
 	;;
 (p6)	cmp.eq p6,p7=3Dr26,r18			// Only compare if page is present
 	;;
-(p6)	itc.d r25				// install updated PTE
+	ITC_D(p6, r25, r18)			// install updated PTE
 	;;
 	/*
 	 * Tell the assemblers dependency-violation checker that the above "itc" =
instructions
@@ -602,7 +603,7 @@ ENTRY(dirty_bit)
 	itc.d r18				// install updated PTE
 #endif
 	mov pr=3Dr31,-1				// restore pr
-	rfi
+	RFI
 END(dirty_bit)
=20
 	.org ia64_ivt+0x2400
@@ -611,7 +612,7 @@ END(dirty_bit)
 ENTRY(iaccess_bit)
 	DBG_FAULT(9)
 	// Like Entry 8, except for instruction access
-	mov r16=3Dcr.ifa				// get the address that caused the fault
+	MOV_FROM_IFA(r16)			// get the address that caused the fault
 	movl r30=1F				// load continuation point in case of nested fault
 	mov r31=3Dpr				// save predicates
 #ifdef CONFIG_ITANIUM
@@ -626,7 +627,7 @@ ENTRY(iaccess_bit)
 (p6)	mov r16=3Dr18				// if so, use cr.iip instead of cr.ifa
 #endif /* CONFIG_ITANIUM */
 	;;
-	thash r17=3Dr16				// compute virtual address of L3 PTE
+	THASH(p0, r17, r16, r18)		// compute virtual address of L3 PTE
 	mov r29=B0				// save b0 in case of nested fault)
 #ifdef CONFIG_SMP
 	mov r28=3Dar.ccv				// save ar.ccv
@@ -642,7 +643,7 @@ ENTRY(iaccess_bit)
 	;;
 (p6)	cmp.eq p6,p7=3Dr26,r18			// Only if page present
 	;;
-(p6)	itc.i r25				// install updated PTE
+	ITC_I(p6, r25, r26)			// install updated PTE
 	;;
 	/*
 	 * Tell the assemblers dependency-violation checker that the above "itc" =
instructions
@@ -668,7 +669,7 @@ ENTRY(iaccess_bit)
 	itc.i r18				// install updated PTE
 #endif /* !CONFIG_SMP */
 	mov pr=3Dr31,-1
-	rfi
+	RFI
 END(iaccess_bit)
=20
 	.org ia64_ivt+0x2800
@@ -677,10 +678,10 @@ END(iaccess_bit)
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
@@ -697,7 +698,7 @@ ENTRY(daccess_bit)
 	;;
 (p6)	cmp.eq p6,p7=3Dr26,r18			// Only if page is present
 	;;
-(p6)	itc.d r25				// install updated PTE
+	ITC_D(p6, r25, r26)			// install updated PTE
 	/*
 	 * Tell the assemblers dependency-violation checker that the above "itc" =
instructions
 	 * cannot possibly affect the following loads:
@@ -721,7 +722,7 @@ ENTRY(daccess_bit)
 #endif
 	mov b0=3Dr29				// restore b0
 	mov pr=3Dr31,-1
-	rfi
+	RFI
 END(daccess_bit)
=20
 	.org ia64_ivt+0x2c00
@@ -745,10 +746,10 @@ ENTRY(break_fault)
 	 */
 	DBG_FAULT(11)
 	mov.m r16=3DIA64_KR(CURRENT)		// M2 r16 <- current task (12 cyc)
-	mov r29=3Dcr.ipsr				// M2 (12 cyc)
+	MOV_FROM_IPSR(r29)			// M2 (12 cyc)
 	mov r31=3Dpr				// I0 (2 cyc)
=20
-	mov r17=3Dcr.iim				// M2 (2 cyc)
+	MOV_FROM_IIM(r17)			// M2 (2 cyc)
 	mov.m r27=3Dar.rsc			// M2 (12 cyc)
 	mov r18=3D__IA64_BREAK_SYSCALL		// A
=20
@@ -767,7 +768,7 @@ ENTRY(break_fault)
 	nop.m 0
 	movl r30=3Dsys_call_table			// X
=20
-	mov r28=3Dcr.iip				// M2 (2 cyc)
+	MOV_FROM_IIP(r28)			// M2 (2 cyc)
 	cmp.eq p0,p7=3Dr18,r17			// I0 is this a system call?
 (p7)	br.cond.spnt non_syscall		// B  no ->
 	//
@@ -831,10 +832,10 @@ ENTRY(break_fault)
 1:
 	mov ar.rsc=3D0x3				// M2   set eager mode, pl 0, LE, loadrs=3D0
 	nop 0
-	bsw.1					// B (6 cyc) regs are saved, switch to bank 1
+	BSW_1(r2, r14)				// B (6 cyc) regs are saved, switch to bank 1
 	;;
=20
-	ssm psr.ic | PSR_DEFAULT_BITS		// M2	now it's safe to re-enable intr.-col=
lection
+	SSM_PSR_IC_AND_DEFAULT_BITS(r3, r16)	// M2	now it's safe to re-enable int=
r.-collection
 	movl r3=3Dia64_ret_from_syscall		// X
 	;;
=20
@@ -842,7 +843,7 @@ ENTRY(break_fault)
 	mov rp=3Dr3				// I0   set the real return addr
 (p10)	br.cond.spnt.many ia64_ret_from_syscall	// B    return if bad call-f=
rame or r15 is a NaT
=20
-(p15)	ssm psr.i				// M2   restore psr.i
+	SSM_PSR_I(p15, r16)			// M2   restore psr.i
 (p14)	br.call.sptk.many b6=B6			// B    invoke syscall-handker (ignore ret=
urn addr)
 	br.cond.spnt.many ia64_trace_syscall	// B	do syscall-tracing thingamagic
 	// NOT REACHED
@@ -866,7 +867,7 @@ ENTRY(interrupt)
 	mov r31=3Dpr		// prepare to save predicates
 	;;
 	SAVE_MIN_WITH_COVER	// uses r31; defines r2 and r3
-	ssm psr.ic | PSR_DEFAULT_BITS
+	SSM_PSR_IC_AND_DEFAULT_BITS(r3, r14)
 	;;
 	adds r3=3D8,r2		// set up second base pointer for SAVE_REST
 	srlz.i			// ensure everybody knows psr.ic is back on
@@ -875,7 +876,7 @@ ENTRY(interrupt)
 	;;
 	MCA_RECOVER_RANGE(interrupt)
 	alloc r14=3Dar.pfs,0,0,2,0 // must be first in an insn group
-	mov out0=3Dcr.ivr		// pass cr.ivr as first arg
+	MOV_FROM_IVR(out0, r8)	// pass cr.ivr as first arg
 	add out1=16,sp		// pass pointer to pt_regs as second arg
 	;;
 	srlz.d			// make sure we see the effect of cr.ivr
@@ -944,6 +945,7 @@ END(interrupt)
 	 *	- ar.fpsr: set to kernel settings
 	 *	-  b6: preserved (same as on entry)
 	 */
+#ifdef __IA64_ASM_PARAVIRTUALIZED_NATIVE
 GLOBAL_ENTRY(ia64_syscall_setup)
 #if PT(B6) !=3D 0
 # error This code assumes that b6 is the first field in pt_regs.
@@ -1035,6 +1037,7 @@ GLOBAL_ENTRY(ia64_syscall_setup)
 (p10)	mov r8=3D-EINVAL
 	br.ret.sptk.many b7
 END(ia64_syscall_setup)
+#endif /* __IA64_ASM_PARAVIRTUALIZED_NATIVE */
=20
 	.org ia64_ivt+0x3c00
 //////////////////////////////////////////////////////////////////////////=
///////////////
@@ -1181,10 +1184,10 @@ ENTRY(dispatch_to_fault_handler)
 	SAVE_MIN_WITH_COVER_R19
 	alloc r14=3Dar.pfs,0,0,5,0
 	mov out0=3Dr15
-	mov out1=3Dcr.isr
-	mov out2=3Dcr.ifa
-	mov out3=3Dcr.iim
-	mov out4=3Dcr.itir
+	MOV_FROM_ISR(out1)
+	MOV_FROM_IFA(out2)
+	MOV_FROM_IIM(out3)
+	MOV_FROM_ITIR(out4)
 	;;
 	ssm psr.ic | PSR_DEFAULT_BITS
 	;;
@@ -1255,8 +1258,8 @@ END(iaccess_rights)
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
@@ -1352,7 +1355,7 @@ ENTRY(speculation_vector)
 	mov cr.ipsr=3Dr16
 	;;
=20
-	rfi				// and go back
+	RFI
 END(speculation_vector)
=20
 	.org ia64_ivt+0x5800
@@ -1506,7 +1509,7 @@ ENTRY(ia32_intercept)
 (p6)	br.cond.spnt 1f		// eflags.ac bit didn't change
 	;;
 	mov pr=3Dr31,-1		// restore predicate registers
-	rfi
+	RFI
=20
 1:
 #endif	// CONFIG_IA32_SUPPORT
--=20
1.5.3

