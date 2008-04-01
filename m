From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Tue, 01 Apr 2008 10:47:43 +0000
Subject: [09/18]KVM: IA64 : Add interruption vector table for vmm.
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDC01048728@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C893E5.D0ECEEB3"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C893E5.D0ECEEB3
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

From bc167336da8eb43e7baf802695ea7168121d6cb2 Mon Sep 17 00:00:00 2001
From: Xiantao Zhang <xiantao.zhang@intel.com>
Date: Tue, 1 Apr 2008 14:52:19 +0800
Subject: [PATCH] KVM: IA64 : Add interruption vector table for vmm.

vmm_ivt.S includes an ivt for vmm use.
Signed-off-by: Anthony Xu <anthony.xu@intel.com>
Signed-off-by: Xiantao Zhang <xiantao.zhang@intel.com>
---
 arch/ia64/kvm/vmm_ivt.S | 1425
+++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 1425 insertions(+), 0 deletions(-)
 create mode 100644 arch/ia64/kvm/vmm_ivt.S

diff --git a/arch/ia64/kvm/vmm_ivt.S b/arch/ia64/kvm/vmm_ivt.S
new file mode 100644
index 0000000..c8b2c6e
--- /dev/null
+++ b/arch/ia64/kvm/vmm_ivt.S
@@ -0,0 +1,1425 @@
+/*
+ * /ia64/kvm_ivt.S
+ *
+ * Copyright (C) 1998-2001, 2003 Hewlett-Packard Co
+ *      Stephane Eranian <eranian@hpl.hp.com>
+ *      David Mosberger <davidm@hpl.hp.com>
+ * Copyright (C) 2000, 2002-2003 Intel Co
+ *      Asit Mallick <asit.k.mallick@intel.com>
+ *      Suresh Siddha <suresh.b.siddha@intel.com>
+ *      Kenneth Chen <kenneth.w.chen@intel.com>
+ *      Fenghua Yu <fenghua.yu@intel.com>
+ *
+ *
+ * 00/08/23 Asit Mallick <asit.k.mallick@intel.com> TLB handling
+ * for SMP
+ * 00/12/20 David Mosberger-Tang <davidm@hpl.hp.com> DTLB/ITLB
+ * handler now uses virtual PT.
+ *
+ * 07/6/20 Xuefei Xu  (Anthony Xu) (anthony.xu@intel.com)
+ *              Supporting Intel virtualization architecture
+ *
+ */
+
+/*
+ * This file defines the interruption vector table used by the CPU.
+ * It does not include one entry per possible cause of interruption.
+ *
+ * The first 20 entries of the table contain 64 bundles each while the
+ * remaining 48 entries contain only 16 bundles each.
+ *
+ * The 64 bundles are used to allow inlining the whole handler for
+ * critical
+ * interruptions like TLB misses.
+ *
+ *  For each entry, the comment is as follows:
+ *
+ *              // 0x1c00 Entry 7 (size 64 bundles) Data Key Miss
+ *              (12,51)
+ *  entry offset ----/     /         /                  /
+ *  /
+ *  entry number ---------/         /                  /
+ *  /
+ *  size of the entry -------------/                  /
+ *  /
+ *  vector name -------------------------------------/
+ *  /
+ *  interruptions triggering this vector
+ *  ----------------------/
+ *
+ * The table is 32KB in size and must be aligned on 32KB
+ * boundary.
+ * (The CPU ignores the 15 lower bits of the address)
+ *
+ * Table is based upon EAS2.6 (Oct 1999)
+ */
+
+
+#include <asm/asmmacro.h>
+#include <asm/cache.h>
+#include <asm/pgtable.h>
+
+#include "asm-offsets.h"
+#include "vcpu.h"
+#include "kvm_minstate.h"
+#include "vti.h"
+
+#if 1
+# define PSR_DEFAULT_BITS   psr.ac
+#else
+# define PSR_DEFAULT_BITS   0
+#endif
+
+
+#define KVM_FAULT(n)    \
+    kvm_fault_##n:;          \
+    mov r19=3Dn;;          \
+    br.sptk.many kvm_fault_##n;         \
+    ;;                  \
+
+
+#define KVM_REFLECT(n)    \
+    mov r31=3Dpr;           \
+    mov r19=3Dn;       /* prepare to save predicates */ \
+    mov r29=3Dcr.ipsr;      \
+    ;;      \
+    tbit.z p6,p7=3Dr29,IA64_PSR_VM_BIT;       \
+(p7)br.sptk.many kvm_dispatch_reflection;        \
+    br.sptk.many kvm_panic;      \
+
+
+GLOBAL_ENTRY(kvm_panic)
+    br.sptk.many kvm_panic
+    ;;
+END(kvm_panic)
+
+
+
+
+
+    .section .text.ivt,"ax"
+
+    .align 32768    // align on 32KB boundary
+    .global kvm_ia64_ivt
+kvm_ia64_ivt:
+///////////////////////////////////////////////////////////////
+// 0x0000 Entry 0 (size 64 bundles) VHPT Translation (8,20,47)
+ENTRY(kvm_vhpt_miss)
+    KVM_FAULT(0)
+END(kvm_vhpt_miss)
+
+
+    .org kvm_ia64_ivt+0x400
+////////////////////////////////////////////////////////////////
+// 0x0400 Entry 1 (size 64 bundles) ITLB (21)
+ENTRY(kvm_itlb_miss)
+    mov r31 =3D pr
+    mov r29=3Dcr.ipsr;
+    ;;
+    tbit.z p6,p7=3Dr29,IA64_PSR_VM_BIT;
+    (p6) br.sptk kvm_alt_itlb_miss
+    mov r19 =3D 1
+    br.sptk kvm_itlb_miss_dispatch
+    KVM_FAULT(1);
+END(kvm_itlb_miss)
+
+    .org kvm_ia64_ivt+0x0800
+//////////////////////////////////////////////////////////////////
+// 0x0800 Entry 2 (size 64 bundles) DTLB (9,48)
+ENTRY(kvm_dtlb_miss)
+    mov r31 =3D pr
+    mov r29=3Dcr.ipsr;
+    ;;
+    tbit.z p6,p7=3Dr29,IA64_PSR_VM_BIT;
+(p6)br.sptk kvm_alt_dtlb_miss
+    br.sptk kvm_dtlb_miss_dispatch
+END(kvm_dtlb_miss)
+
+     .org kvm_ia64_ivt+0x0c00
+////////////////////////////////////////////////////////////////////
+// 0x0c00 Entry 3 (size 64 bundles) Alt ITLB (19)
+ENTRY(kvm_alt_itlb_miss)
+    mov r16=3Dcr.ifa    // get address that caused the TLB miss
+    ;;
+    movl r17=3DPAGE_KERNEL
+    mov r24=3Dcr.ipsr
+    movl r19=3D(((1 << IA64_MAX_PHYS_BITS) - 1) & ~0xfff)
+    ;;
+    and r19=3Dr19,r16     // clear ed, reserved bits, and PTE control
bits
+    ;;
+    or r19=3Dr17,r19      // insert PTE control bits into r19
+    ;;
+    movl r20=3DIA64_GRANULE_SHIFT<<2
+    ;;
+    mov cr.itir=3Dr20
+    ;;
+    itc.i r19		// insert the TLB entry
+    mov pr=3Dr31,-1
+    rfi
+END(kvm_alt_itlb_miss)
+
+    .org kvm_ia64_ivt+0x1000
+/////////////////////////////////////////////////////////////////////
+// 0x1000 Entry 4 (size 64 bundles) Alt DTLB (7,46)
+ENTRY(kvm_alt_dtlb_miss)
+    mov r16=3Dcr.ifa		// get address that caused the TLB miss
+    ;;
+    movl r17=3DPAGE_KERNEL
+    movl r19=3D(((1 << IA64_MAX_PHYS_BITS) - 1) & ~0xfff)
+    mov r24=3Dcr.ipsr
+    ;;
+    and r19=3Dr19,r16     // clear ed, reserved bits, and PTE control
bits
+    ;;
+    or r19=3Dr19,r17	// insert PTE control bits into r19
+    ;;
+    movl r20=3DIA64_GRANULE_SHIFT<<2
+    ;;
+    mov cr.itir=3Dr20
+    ;;
+    itc.d r19		// insert the TLB entry
+    mov pr=3Dr31,-1
+    rfi
+END(kvm_alt_dtlb_miss)
+
+    .org kvm_ia64_ivt+0x1400
+//////////////////////////////////////////////////////////////////////
+// 0x1400 Entry 5 (size 64 bundles) Data nested TLB (6,45)
+ENTRY(kvm_nested_dtlb_miss)
+    KVM_FAULT(5)
+END(kvm_nested_dtlb_miss)
+
+    .org kvm_ia64_ivt+0x1800
+/////////////////////////////////////////////////////////////////////
+// 0x1800 Entry 6 (size 64 bundles) Instruction Key Miss (24)
+ENTRY(kvm_ikey_miss)
+    KVM_REFLECT(6)
+END(kvm_ikey_miss)
+
+    .org kvm_ia64_ivt+0x1c00
+/////////////////////////////////////////////////////////////////////
+// 0x1c00 Entry 7 (size 64 bundles) Data Key Miss (12,51)
+ENTRY(kvm_dkey_miss)
+    KVM_REFLECT(7)
+END(kvm_dkey_miss)
+
+    .org kvm_ia64_ivt+0x2000
+////////////////////////////////////////////////////////////////////
+// 0x2000 Entry 8 (size 64 bundles) Dirty-bit (54)
+ENTRY(kvm_dirty_bit)
+    KVM_REFLECT(8)
+END(kvm_dirty_bit)
+
+    .org kvm_ia64_ivt+0x2400
+////////////////////////////////////////////////////////////////////
+// 0x2400 Entry 9 (size 64 bundles) Instruction Access-bit (27)
+ENTRY(kvm_iaccess_bit)
+    KVM_REFLECT(9)
+END(kvm_iaccess_bit)
+
+    .org kvm_ia64_ivt+0x2800
+///////////////////////////////////////////////////////////////////
+// 0x2800 Entry 10 (size 64 bundles) Data Access-bit (15,55)
+ENTRY(kvm_daccess_bit)
+    KVM_REFLECT(10)
+END(kvm_daccess_bit)
+
+    .org kvm_ia64_ivt+0x2c00
+/////////////////////////////////////////////////////////////////
+// 0x2c00 Entry 11 (size 64 bundles) Break instruction (33)
+ENTRY(kvm_break_fault)
+    mov r31=3Dpr
+    mov r19=3D11
+    mov r29=3Dcr.ipsr
+    ;;
+    KVM_SAVE_MIN_WITH_COVER_R19
+    ;;
+    alloc r14=3Dar.pfs,0,0,4,0 // now it's safe (must be first in insn
group!)
+    mov out0=3Dcr.ifa
+    mov out2=3Dcr.isr     // FIXME: pity to make this slow access twice
+    mov out3=3Dcr.iim     // FIXME: pity to make this slow access twice
+    adds r3=3D8,r2                // set up second base pointer
+    ;;
+    ssm psr.ic
+    ;;
+    srlz.i                  // guarantee that interruption collection
is on
+    ;;
+    //(p15)ssm psr.i               // restore psr.i
+    addl r14=3D@gprel(ia64_leave_hypervisor),gp
+    ;;
+    KVM_SAVE_REST
+    mov rp=3Dr14
+    ;;
+    adds out1=3D16,sp
+    br.call.sptk.many b6=3Dkvm_ia64_handle_break
+    ;;
+END(kvm_break_fault)
+
+    .org kvm_ia64_ivt+0x3000
+/////////////////////////////////////////////////////////////////
+// 0x3000 Entry 12 (size 64 bundles) External Interrupt (4)
+ENTRY(kvm_interrupt)
+    mov r31=3Dpr		// prepare to save predicates
+    mov r19=3D12
+    mov r29=3Dcr.ipsr
+    ;;
+    tbit.z p6,p7=3Dr29,IA64_PSR_VM_BIT
+    tbit.z p0,p15=3Dr29,IA64_PSR_I_BIT
+    ;;
+(p7) br.sptk kvm_dispatch_interrupt
+    ;;
+    mov r27=3Dar.rsc		/* M */
+    mov r20=3Dr1			/* A */
+    mov r25=3Dar.unat		/* M */
+    mov r26=3Dar.pfs		/* I */
+    mov r28=3Dcr.iip		/* M */
+    cover			/* B (or nothing) */
+    ;;
+    mov r1=3Dsp
+    ;;
+    invala			/* M */
+    mov r30=3Dcr.ifs
+    ;;
+    addl r1=3D-VMM_PT_REGS_SIZE,r1
+    ;;
+    adds r17=3D2*L1_CACHE_BYTES,r1	/* really: biggest cache-line
size */
+    adds r16=3DPT(CR_IPSR),r1
+    ;;
+    lfetch.fault.excl.nt1 [r17],L1_CACHE_BYTES
+    st8 [r16]=3Dr29			/* save cr.ipsr */
+    ;;
+    lfetch.fault.excl.nt1 [r17]
+    mov r29=3Db0
+    ;;
+    adds r16=3DPT(R8),r1  	/* initialize first base pointer */
+    adds r17=3DPT(R9),r1  	/* initialize second base pointer */
+    mov r18=3Dr0      		/* make sure r18 isn't NaT */
+    ;;
+.mem.offset 0,0; st8.spill [r16]=3Dr8,16
+.mem.offset 8,0; st8.spill [r17]=3Dr9,16
+        ;;
+.mem.offset 0,0; st8.spill [r16]=3Dr10,24
+.mem.offset 8,0; st8.spill [r17]=3Dr11,24
+        ;;
+    st8 [r16]=3Dr28,16		/* save cr.iip */
+    st8 [r17]=3Dr30,16		/* save cr.ifs */
+    mov r8=3Dar.fpsr		/* M */
+    mov r9=3Dar.csd
+    mov r10=3Dar.ssd
+    movl r11=3DFPSR_DEFAULT	/* L-unit */
+    ;;
+    st8 [r16]=3Dr25,16		/* save ar.unat */
+    st8 [r17]=3Dr26,16		/* save ar.pfs */
+    shl r18=3Dr18,16		/* compute ar.rsc to be used for
"loadrs" */
+    ;;
+    st8 [r16]=3Dr27,16		/* save ar.rsc */
+    adds r17=3D16,r17		/* skip over ar_rnat field */
+    ;;
+    st8 [r17]=3Dr31,16		/* save predicates */
+    adds r16=3D16,r16		/* skip over ar_bspstore field */
+    ;;
+    st8 [r16]=3Dr29,16		/* save b0 */
+    st8 [r17]=3Dr18,16		/* save ar.rsc value for "loadrs" */
+    ;;
+.mem.offset 0,0; st8.spill [r16]=3Dr20,16    /* save original r1 */
+.mem.offset 8,0; st8.spill [r17]=3Dr12,16
+    adds r12=3D-16,r1
+    /* switch to kernel memory stack (with 16 bytes of scratch) */
+    ;;
+.mem.offset 0,0; st8.spill [r16]=3Dr13,16
+.mem.offset 8,0; st8.spill [r17]=3Dr8,16 /* save ar.fpsr */
+    ;;
+.mem.offset 0,0; st8.spill [r16]=3Dr15,16
+.mem.offset 8,0; st8.spill [r17]=3Dr14,16
+    dep r14=3D-1,r0,60,4
+    ;;
+.mem.offset 0,0; st8.spill [r16]=3Dr2,16
+.mem.offset 8,0; st8.spill [r17]=3Dr3,16
+    adds r2=3DVMM_PT_REGS_R16_OFFSET,r1
+    adds r14 =3D VMM_VCPU_GP_OFFSET,r13
+    ;;
+    mov r8=3Dar.ccv
+    ld8 r14 =3D [r14]
+    ;;
+    mov r1=3Dr14       /* establish kernel global pointer */
+    ;;                                          \
+    bsw.1
+    ;;
+    alloc r14=3Dar.pfs,0,0,1,0	// must be first in an insn group
+    mov out0=3Dr13
+    ;;
+    ssm psr.ic
+    ;;
+    srlz.i
+    ;;
+    //(p15) ssm psr.i
+    adds r3=3D8,r2		// set up second base pointer for
SAVE_REST
+    srlz.i			// ensure everybody knows psr.ic is back
on
+    ;;
+.mem.offset 0,0; st8.spill [r2]=3Dr16,16
+.mem.offset 8,0; st8.spill [r3]=3Dr17,16
+    ;;
+.mem.offset 0,0; st8.spill [r2]=3Dr18,16
+.mem.offset 8,0; st8.spill [r3]=3Dr19,16
+    ;;
+.mem.offset 0,0; st8.spill [r2]=3Dr20,16
+.mem.offset 8,0; st8.spill [r3]=3Dr21,16
+    mov r18=3Db6
+    ;;
+.mem.offset 0,0; st8.spill [r2]=3Dr22,16
+.mem.offset 8,0; st8.spill [r3]=3Dr23,16
+    mov r19=3Db7
+    ;;
+.mem.offset 0,0; st8.spill [r2]=3Dr24,16
+.mem.offset 8,0; st8.spill [r3]=3Dr25,16
+    ;;
+.mem.offset 0,0; st8.spill [r2]=3Dr26,16
+.mem.offset 8,0; st8.spill [r3]=3Dr27,16
+    ;;
+.mem.offset 0,0; st8.spill [r2]=3Dr28,16
+.mem.offset 8,0; st8.spill [r3]=3Dr29,16
+    ;;
+.mem.offset 0,0; st8.spill [r2]=3Dr30,16
+.mem.offset 8,0; st8.spill [r3]=3Dr31,32
+    ;;
+    mov ar.fpsr=3Dr11       /* M-unit */
+    st8 [r2]=3Dr8,8         /* ar.ccv */
+    adds r24=3DPT(B6)-PT(F7),r3
+    ;;
+    stf.spill [r2]=3Df6,32
+    stf.spill [r3]=3Df7,32
+    ;;
+    stf.spill [r2]=3Df8,32
+    stf.spill [r3]=3Df9,32
+    ;;
+    stf.spill [r2]=3Df10
+    stf.spill [r3]=3Df11
+    adds r25=3DPT(B7)-PT(F11),r3
+    ;;
+    st8 [r24]=3Dr18,16       /* b6 */
+    st8 [r25]=3Dr19,16       /* b7 */
+    ;;
+    st8 [r24]=3Dr9           /* ar.csd */
+    st8 [r25]=3Dr10          /* ar.ssd */
+    ;;
+    srlz.d		// make sure we see the effect of cr.ivr
+    addl r14=3D@gprel(ia64_leave_nested),gp
+    ;;
+    mov rp=3Dr14
+    br.call.sptk.many b6=3Dkvm_ia64_handle_irq
+    ;;
+END(kvm_interrupt)
+
+    .global kvm_dispatch_vexirq
+    .org kvm_ia64_ivt+0x3400
+//////////////////////////////////////////////////////////////////////
+// 0x3400 Entry 13 (size 64 bundles) Reserved
+ENTRY(kvm_virtual_exirq)
+    mov r31=3Dpr
+    mov r19=3D13
+    mov r30 =3Dr0
+    ;;
+kvm_dispatch_vexirq:
+    cmp.eq p6,p0 =3D 1,r30
+    ;;
+(p6)add r29 =3D VMM_VCPU_SAVED_GP_OFFSET,r21
+    ;;
+(p6)ld8 r1 =3D [r29]
+    ;;
+    KVM_SAVE_MIN_WITH_COVER_R19
+    alloc r14=3Dar.pfs,0,0,1,0
+    mov out0=3Dr13
+
+    ssm psr.ic
+    ;;
+    srlz.i                  // guarantee that interruption collection
is on
+    ;;
+    //(p15) ssm psr.i               // restore psr.i
+    adds r3=3D8,r2                // set up second base pointer
+    ;;
+    KVM_SAVE_REST
+    addl r14=3D@gprel(ia64_leave_hypervisor),gp
+    ;;
+    mov rp=3Dr14
+    br.call.sptk.many b6=3Dkvm_vexirq
+END(kvm_virtual_exirq)
+
+    .org kvm_ia64_ivt+0x3800
+/////////////////////////////////////////////////////////////////////
+// 0x3800 Entry 14 (size 64 bundles) Reserved
+    KVM_FAULT(14)
+    // this code segment is from 2.6.16.13
+
+
+    .org kvm_ia64_ivt+0x3c00
+///////////////////////////////////////////////////////////////////////
+// 0x3c00 Entry 15 (size 64 bundles) Reserved
+    KVM_FAULT(15)
+
+
+    .org kvm_ia64_ivt+0x4000
+///////////////////////////////////////////////////////////////////////
+// 0x4000 Entry 16 (size 64 bundles) Reserved
+    KVM_FAULT(16)
+
+    .org kvm_ia64_ivt+0x4400
+//////////////////////////////////////////////////////////////////////
+// 0x4400 Entry 17 (size 64 bundles) Reserved
+    KVM_FAULT(17)
+
+    .org kvm_ia64_ivt+0x4800
+//////////////////////////////////////////////////////////////////////
+// 0x4800 Entry 18 (size 64 bundles) Reserved
+    KVM_FAULT(18)
+
+    .org kvm_ia64_ivt+0x4c00
+//////////////////////////////////////////////////////////////////////
+// 0x4c00 Entry 19 (size 64 bundles) Reserved
+    KVM_FAULT(19)
+
+    .org kvm_ia64_ivt+0x5000
+//////////////////////////////////////////////////////////////////////
+// 0x5000 Entry 20 (size 16 bundles) Page Not Present
+ENTRY(kvm_page_not_present)
+    KVM_REFLECT(20)
+END(kvm_page_not_present)
+
+    .org kvm_ia64_ivt+0x5100
+///////////////////////////////////////////////////////////////////////
+// 0x5100 Entry 21 (size 16 bundles) Key Permission vector
+ENTRY(kvm_key_permission)
+    KVM_REFLECT(21)
+END(kvm_key_permission)
+
+    .org kvm_ia64_ivt+0x5200
+//////////////////////////////////////////////////////////////////////
+// 0x5200 Entry 22 (size 16 bundles) Instruction Access Rights (26)
+ENTRY(kvm_iaccess_rights)
+    KVM_REFLECT(22)
+END(kvm_iaccess_rights)
+
+    .org kvm_ia64_ivt+0x5300
+//////////////////////////////////////////////////////////////////////
+// 0x5300 Entry 23 (size 16 bundles) Data Access Rights (14,53)
+ENTRY(kvm_daccess_rights)
+    KVM_REFLECT(23)
+END(kvm_daccess_rights)
+
+    .org kvm_ia64_ivt+0x5400
+/////////////////////////////////////////////////////////////////////
+// 0x5400 Entry 24 (size 16 bundles) General Exception
(5,32,34,36,38,39)
+ENTRY(kvm_general_exception)
+   KVM_REFLECT(24)
+   KVM_FAULT(24)
+END(kvm_general_exception)
+
+    .org kvm_ia64_ivt+0x5500
+//////////////////////////////////////////////////////////////////////
+// 0x5500 Entry 25 (size 16 bundles) Disabled FP-Register (35)
+ENTRY(kvm_disabled_fp_reg)
+    KVM_REFLECT(25)
+END(kvm_disabled_fp_reg)
+
+    .org kvm_ia64_ivt+0x5600
+////////////////////////////////////////////////////////////////////
+// 0x5600 Entry 26 (size 16 bundles) Nat Consumption (11,23,37,50)
+ENTRY(kvm_nat_consumption)
+    KVM_REFLECT(26)
+END(kvm_nat_consumption)
+
+    .org kvm_ia64_ivt+0x5700
+/////////////////////////////////////////////////////////////////////
+// 0x5700 Entry 27 (size 16 bundles) Speculation (40)
+ENTRY(kvm_speculation_vector)
+    KVM_REFLECT(27)
+END(kvm_speculation_vector)
+
+    .org kvm_ia64_ivt+0x5800
+/////////////////////////////////////////////////////////////////////
+// 0x5800 Entry 28 (size 16 bundles) Reserved
+    KVM_FAULT(28)
+
+    .org kvm_ia64_ivt+0x5900
+///////////////////////////////////////////////////////////////////
+// 0x5900 Entry 29 (size 16 bundles) Debug (16,28,56)
+ENTRY(kvm_debug_vector)
+    KVM_FAULT(29)
+END(kvm_debug_vector)
+
+    .org kvm_ia64_ivt+0x5a00
+///////////////////////////////////////////////////////////////
+// 0x5a00 Entry 30 (size 16 bundles) Unaligned Reference (57)
+ENTRY(kvm_unaligned_access)
+    KVM_REFLECT(30)
+END(kvm_unaligned_access)
+
+    .org kvm_ia64_ivt+0x5b00
+//////////////////////////////////////////////////////////////////////
+// 0x5b00 Entry 31 (size 16 bundles) Unsupported Data Reference (57)
+ENTRY(kvm_unsupported_data_reference)
+    KVM_REFLECT(31)
+END(kvm_unsupported_data_reference)
+
+    .org kvm_ia64_ivt+0x5c00
+////////////////////////////////////////////////////////////////////
+// 0x5c00 Entry 32 (size 16 bundles) Floating Point FAULT (65)
+ENTRY(kvm_floating_point_fault)
+    KVM_REFLECT(32)
+END(kvm_floating_point_fault)
+
+    .org kvm_ia64_ivt+0x5d00
+/////////////////////////////////////////////////////////////////////
+// 0x5d00 Entry 33 (size 16 bundles) Floating Point Trap (66)
+ENTRY(kvm_floating_point_trap)
+    KVM_REFLECT(33)
+END(kvm_floating_point_trap)
+
+    .org kvm_ia64_ivt+0x5e00
+//////////////////////////////////////////////////////////////////////
+// 0x5e00 Entry 34 (size 16 bundles) Lower Privilege Transfer Trap (66)
+ENTRY(kvm_lower_privilege_trap)
+    KVM_REFLECT(34)
+END(kvm_lower_privilege_trap)
+
+    .org kvm_ia64_ivt+0x5f00
+//////////////////////////////////////////////////////////////////////
+// 0x5f00 Entry 35 (size 16 bundles) Taken Branch Trap (68)
+ENTRY(kvm_taken_branch_trap)
+    KVM_REFLECT(35)
+END(kvm_taken_branch_trap)
+
+    .org kvm_ia64_ivt+0x6000
+////////////////////////////////////////////////////////////////////
+// 0x6000 Entry 36 (size 16 bundles) Single Step Trap (69)
+ENTRY(kvm_single_step_trap)
+    KVM_REFLECT(36)
+END(kvm_single_step_trap)
+    .global kvm_virtualization_fault_back
+    .org kvm_ia64_ivt+0x6100
+/////////////////////////////////////////////////////////////////////
+// 0x6100 Entry 37 (size 16 bundles) Virtualization Fault
+ENTRY(kvm_virtualization_fault)
+    mov r31=3Dpr
+    adds r16 =3D VMM_VCPU_SAVED_GP_OFFSET,r21
+    ;;
+    st8 [r16] =3D r1
+    adds r17 =3D VMM_VCPU_GP_OFFSET, r21
+    ;;
+    ld8 r1 =3D [r17]
+    cmp.eq p6,p0=3DEVENT_MOV_FROM_AR,r24
+    cmp.eq p7,p0=3DEVENT_MOV_FROM_RR,r24
+    cmp.eq p8,p0=3DEVENT_MOV_TO_RR,r24
+    cmp.eq p9,p0=3DEVENT_RSM,r24
+    cmp.eq p10,p0=3DEVENT_SSM,r24
+    cmp.eq p11,p0=3DEVENT_MOV_TO_PSR,r24
+    cmp.eq p12,p0=3DEVENT_THASH,r24
+    (p6) br.dptk.many kvm_asm_mov_from_ar
+    (p7) br.dptk.many kvm_asm_mov_from_rr
+    (p8) br.dptk.many kvm_asm_mov_to_rr
+    (p9) br.dptk.many kvm_asm_rsm
+    (p10) br.dptk.many kvm_asm_ssm
+    (p11) br.dptk.many kvm_asm_mov_to_psr
+    (p12) br.dptk.many kvm_asm_thash
+    ;;
+kvm_virtualization_fault_back:
+    adds r16 =3D VMM_VCPU_SAVED_GP_OFFSET,r21
+    ;;
+    ld8 r1 =3D [r16]
+    ;;
+    mov r19=3D37
+    adds r16 =3D VMM_VCPU_CAUSE_OFFSET,r21
+    adds r17 =3D VMM_VCPU_OPCODE_OFFSET,r21
+    ;;
+    st8 [r16] =3D r24
+    st8 [r17] =3D r25
+    ;;
+    cmp.ne p6,p0=3DEVENT_RFI, r24
+    (p6) br.sptk kvm_dispatch_virtualization_fault
+    ;;
+    adds r18=3DVMM_VPD_BASE_OFFSET,r21
+    ;;
+    ld8 r18=3D[r18]
+    ;;
+    adds r18=3DVMM_VPD_VIFS_OFFSET,r18
+    ;;
+    ld8 r18=3D[r18]
+    ;;
+    tbit.z p6,p0=3Dr18,63
+    (p6) br.sptk kvm_dispatch_virtualization_fault
+    ;;
+    //if vifs.v=3D1 desert current register frame
+    alloc r18=3Dar.pfs,0,0,0,0
+    br.sptk kvm_dispatch_virtualization_fault
+END(kvm_virtualization_fault)
+
+    .org kvm_ia64_ivt+0x6200
+//////////////////////////////////////////////////////////////
+// 0x6200 Entry 38 (size 16 bundles) Reserved
+    KVM_FAULT(38)
+
+    .org kvm_ia64_ivt+0x6300
+/////////////////////////////////////////////////////////////////
+// 0x6300 Entry 39 (size 16 bundles) Reserved
+    KVM_FAULT(39)
+
+    .org kvm_ia64_ivt+0x6400
+/////////////////////////////////////////////////////////////////
+// 0x6400 Entry 40 (size 16 bundles) Reserved
+    KVM_FAULT(40)
+
+    .org kvm_ia64_ivt+0x6500
+//////////////////////////////////////////////////////////////////
+// 0x6500 Entry 41 (size 16 bundles) Reserved
+    KVM_FAULT(41)
+
+    .org kvm_ia64_ivt+0x6600
+//////////////////////////////////////////////////////////////////
+// 0x6600 Entry 42 (size 16 bundles) Reserved
+    KVM_FAULT(42)
+
+    .org kvm_ia64_ivt+0x6700
+//////////////////////////////////////////////////////////////////
+// 0x6700 Entry 43 (size 16 bundles) Reserved
+    KVM_FAULT(43)
+
+    .org kvm_ia64_ivt+0x6800
+//////////////////////////////////////////////////////////////////
+// 0x6800 Entry 44 (size 16 bundles) Reserved
+    KVM_FAULT(44)
+
+    .org kvm_ia64_ivt+0x6900
+///////////////////////////////////////////////////////////////////
+// 0x6900 Entry 45 (size 16 bundles) IA-32 Exeception
+//(17,18,29,41,42,43,44,58,60,61,62,72,73,75,76,77)
+ENTRY(kvm_ia32_exception)
+    KVM_FAULT(45)
+END(kvm_ia32_exception)
+
+    .org kvm_ia64_ivt+0x6a00
+////////////////////////////////////////////////////////////////////
+// 0x6a00 Entry 46 (size 16 bundles) IA-32 Intercept  (30,31,59,70,71)
+ENTRY(kvm_ia32_intercept)
+    KVM_FAULT(47)
+END(kvm_ia32_intercept)
+
+    .org kvm_ia64_ivt+0x6c00
+/////////////////////////////////////////////////////////////////////
+// 0x6c00 Entry 48 (size 16 bundles) Reserved
+    KVM_FAULT(48)
+
+    .org kvm_ia64_ivt+0x6d00
+//////////////////////////////////////////////////////////////////////
+// 0x6d00 Entry 49 (size 16 bundles) Reserved
+    KVM_FAULT(49)
+
+    .org kvm_ia64_ivt+0x6e00
+//////////////////////////////////////////////////////////////////////
+// 0x6e00 Entry 50 (size 16 bundles) Reserved
+    KVM_FAULT(50)
+
+    .org kvm_ia64_ivt+0x6f00
+/////////////////////////////////////////////////////////////////////
+// 0x6f00 Entry 51 (size 16 bundles) Reserved
+    KVM_FAULT(52)
+
+    .org kvm_ia64_ivt+0x7100
+////////////////////////////////////////////////////////////////////
+// 0x7100 Entry 53 (size 16 bundles) Reserved
+    KVM_FAULT(53)
+
+    .org kvm_ia64_ivt+0x7200
+/////////////////////////////////////////////////////////////////////
+// 0x7200 Entry 54 (size 16 bundles) Reserved
+    KVM_FAULT(54)
+
+    .org kvm_ia64_ivt+0x7300
+////////////////////////////////////////////////////////////////////
+// 0x7300 Entry 55 (size 16 bundles) Reserved
+    KVM_FAULT(55)
+
+    .org kvm_ia64_ivt+0x7400
+////////////////////////////////////////////////////////////////////
+// 0x7400 Entry 56 (size 16 bundles) Reserved
+    KVM_FAULT(56)
+
+    .org kvm_ia64_ivt+0x7500
+/////////////////////////////////////////////////////////////////////
+// 0x7500 Entry 57 (size 16 bundles) Reserved
+    KVM_FAULT(57)
+
+    .org kvm_ia64_ivt+0x7600
+/////////////////////////////////////////////////////////////////////
+// 0x7600 Entry 58 (size 16 bundles) Reserved
+    KVM_FAULT(58)
+
+    .org kvm_ia64_ivt+0x7700
+////////////////////////////////////////////////////////////////////
+// 0x7700 Entry 59 (size 16 bundles) Reserved
+    KVM_FAULT(59)
+
+    .org kvm_ia64_ivt+0x7800
+////////////////////////////////////////////////////////////////////
+// 0x7800 Entry 60 (size 16 bundles) Reserved
+    KVM_FAULT(60)
+
+    .org kvm_ia64_ivt+0x7900
+/////////////////////////////////////////////////////////////////////
+// 0x7900 Entry 61 (size 16 bundles) Reserved
+    KVM_FAULT(61)
+
+    .org kvm_ia64_ivt+0x7a00
+/////////////////////////////////////////////////////////////////////
+// 0x7a00 Entry 62 (size 16 bundles) Reserved
+    KVM_FAULT(62)
+
+    .org kvm_ia64_ivt+0x7b00
+/////////////////////////////////////////////////////////////////////
+// 0x7b00 Entry 63 (size 16 bundles) Reserved
+    KVM_FAULT(63)
+
+    .org kvm_ia64_ivt+0x7c00
+////////////////////////////////////////////////////////////////////
+// 0x7c00 Entry 64 (size 16 bundles) Reserved
+    KVM_FAULT(64)
+
+    .org kvm_ia64_ivt+0x7d00
+/////////////////////////////////////////////////////////////////////
+// 0x7d00 Entry 65 (size 16 bundles) Reserved
+    KVM_FAULT(65)
+
+    .org kvm_ia64_ivt+0x7e00
+/////////////////////////////////////////////////////////////////////
+// 0x7e00 Entry 66 (size 16 bundles) Reserved
+    KVM_FAULT(66)
+
+    .org kvm_ia64_ivt+0x7f00
+////////////////////////////////////////////////////////////////////
+// 0x7f00 Entry 67 (size 16 bundles) Reserved
+    KVM_FAULT(67)
+
+    .org kvm_ia64_ivt+0x8000
+// There is no particular reason for this code to be here, other than
that
+// there happens to be space here that would go unused otherwise.  If
this
+// fault ever gets "unreserved", simply moved the following code to a
more
+// suitable spot...
+
+
+ENTRY(kvm_dtlb_miss_dispatch)
+    mov r19 =3D 2
+    KVM_SAVE_MIN_WITH_COVER_R19
+    alloc r14=3Dar.pfs,0,0,3,0
+    mov out0=3Dcr.ifa
+    mov out1=3Dr15
+    adds r3=3D8,r2                // set up second base pointer
+    ;;
+    ssm psr.ic
+    ;;
+    srlz.i                  // guarantee that interruption collection
is on
+    ;;
+    //(p15) ssm psr.i               // restore psr.i
+    addl r14=3D@gprel(ia64_leave_hypervisor_prepare),gp
+    ;;
+    KVM_SAVE_REST
+    KVM_SAVE_EXTRA
+    mov rp=3Dr14
+    ;;
+    adds out2=3D16,r12
+    br.call.sptk.many b6=3Dkvm_page_fault
+END(kvm_dtlb_miss_dispatch)
+
+ENTRY(kvm_itlb_miss_dispatch)
+
+    KVM_SAVE_MIN_WITH_COVER_R19
+    alloc r14=3Dar.pfs,0,0,3,0
+    mov out0=3Dcr.ifa
+    mov out1=3Dr15
+    adds r3=3D8,r2                // set up second base pointer
+    ;;
+    ssm psr.ic
+    ;;
+    srlz.i                  // guarantee that interruption collection
is on
+    ;;
+    //(p15) ssm psr.i               // restore psr.i
+    addl r14=3D@gprel(ia64_leave_hypervisor),gp
+    ;;
+    KVM_SAVE_REST
+    mov rp=3Dr14
+    ;;
+    adds out2=3D16,r12
+    br.call.sptk.many b6=3Dkvm_page_fault
+END(kvm_itlb_miss_dispatch)
+
+ENTRY(kvm_dispatch_reflection)
+    /*
+     * Input:
+     *  psr.ic: off
+     *  r19:    intr type (offset into ivt, see ia64_int.h)
+     *  r31:    contains saved predicates (pr)
+     */
+    KVM_SAVE_MIN_WITH_COVER_R19
+    alloc r14=3Dar.pfs,0,0,5,0
+    mov out0=3Dcr.ifa
+    mov out1=3Dcr.isr
+    mov out2=3Dcr.iim
+    mov out3=3Dr15
+    adds r3=3D8,r2                // set up second base pointer
+    ;;
+    ssm psr.ic
+    ;;
+    srlz.i                  // guarantee that interruption collection
is on
+    ;;
+    //(p15) ssm psr.i               // restore psr.i
+    addl r14=3D@gprel(ia64_leave_hypervisor),gp
+    ;;
+    KVM_SAVE_REST
+    mov rp=3Dr14
+    ;;
+    adds out4=3D16,r12
+    br.call.sptk.many b6=3Dreflect_interruption
+END(kvm_dispatch_reflection)
+
+ENTRY(kvm_dispatch_virtualization_fault)
+    adds r16 =3D VMM_VCPU_CAUSE_OFFSET,r21
+    adds r17 =3D VMM_VCPU_OPCODE_OFFSET,r21
+    ;;
+    st8 [r16] =3D r24
+    st8 [r17] =3D r25
+    ;;
+    KVM_SAVE_MIN_WITH_COVER_R19
+    ;;
+    alloc r14=3Dar.pfs,0,0,2,0 // now it's safe (must be first in insn
group!)
+    mov out0=3Dr13        //vcpu
+    adds r3=3D8,r2                // set up second base pointer
+    ;;
+    ssm psr.ic
+    ;;
+    srlz.i                  // guarantee that interruption collection
is on
+    ;;
+    //(p15) ssm psr.i               // restore psr.i
+    addl r14=3D@gprel(ia64_leave_hypervisor_prepare),gp
+    ;;
+    KVM_SAVE_REST
+    KVM_SAVE_EXTRA
+    mov rp=3Dr14
+    ;;
+    adds out1=3D16,sp         //regs
+    br.call.sptk.many b6=3Dkvm_emulate
+END(kvm_dispatch_virtualization_fault)
+
+
+ENTRY(kvm_dispatch_interrupt)
+    KVM_SAVE_MIN_WITH_COVER_R19	// uses r31; defines r2 and r3
+    ;;
+    alloc r14=3Dar.pfs,0,0,1,0 // must be first in an insn group
+    //mov out0=3Dcr.ivr		// pass cr.ivr as first arg
+    adds r3=3D8,r2		// set up second base pointer for
SAVE_REST
+    ;;
+    ssm psr.ic
+    ;;
+    srlz.i
+    ;;
+    //(p15) ssm psr.i
+    addl r14=3D@gprel(ia64_leave_hypervisor),gp
+    ;;
+    KVM_SAVE_REST
+    mov rp=3Dr14
+    ;;
+    mov out0=3Dr13		// pass pointer to pt_regs as second arg
+    br.call.sptk.many b6=3Dkvm_ia64_handle_irq
+END(kvm_dispatch_interrupt)
+
+
+
+
+GLOBAL_ENTRY(ia64_leave_nested)
+	rsm psr.i
+	;;
+	adds r21=3DPT(PR)+16,r12
+	;;
+	lfetch [r21],PT(CR_IPSR)-PT(PR)
+	adds r2=3DPT(B6)+16,r12
+	adds r3=3DPT(R16)+16,r12
+	;;
+	lfetch [r21]
+	ld8 r28=3D[r2],8		// load b6
+	adds r29=3DPT(R24)+16,r12
+
+	ld8.fill r16=3D[r3]
+	adds r3=3DPT(AR_CSD)-PT(R16),r3
+	adds r30=3DPT(AR_CCV)+16,r12
+	;;
+	ld8.fill r24=3D[r29]
+	ld8 r15=3D[r30]		// load ar.ccv
+	;;
+	ld8 r29=3D[r2],16		// load b7
+	ld8 r30=3D[r3],16		// load ar.csd
+	;;
+	ld8 r31=3D[r2],16		// load ar.ssd
+	ld8.fill r8=3D[r3],16
+	;;
+	ld8.fill r9=3D[r2],16
+	ld8.fill r10=3D[r3],PT(R17)-PT(R10)
+	;;
+	ld8.fill r11=3D[r2],PT(R18)-PT(R11)
+	ld8.fill r17=3D[r3],16
+	;;
+	ld8.fill r18=3D[r2],16
+	ld8.fill r19=3D[r3],16
+	;;
+	ld8.fill r20=3D[r2],16
+	ld8.fill r21=3D[r3],16
+	mov ar.csd=3Dr30
+	mov ar.ssd=3Dr31
+	;;
+	rsm psr.i | psr.ic
+	// initiate turning off of interrupt and interruption collection
+	invala			// invalidate ALAT
+	;;
+	srlz.i
+	;;
+	ld8.fill r22=3D[r2],24
+	ld8.fill r23=3D[r3],24
+	mov b6=3Dr28
+	;;
+	ld8.fill r25=3D[r2],16
+	ld8.fill r26=3D[r3],16
+	mov b7=3Dr29
+	;;
+	ld8.fill r27=3D[r2],16
+	ld8.fill r28=3D[r3],16
+	;;
+	ld8.fill r29=3D[r2],16
+	ld8.fill r30=3D[r3],24
+	;;
+	ld8.fill r31=3D[r2],PT(F9)-PT(R31)
+	adds r3=3DPT(F10)-PT(F6),r3
+	;;
+	ldf.fill f9=3D[r2],PT(F6)-PT(F9)
+	ldf.fill f10=3D[r3],PT(F8)-PT(F10)
+	;;
+	ldf.fill f6=3D[r2],PT(F7)-PT(F6)
+	;;
+	ldf.fill f7=3D[r2],PT(F11)-PT(F7)
+	ldf.fill f8=3D[r3],32
+	;;
+	srlz.i			// ensure interruption collection is off
+	mov ar.ccv=3Dr15
+	;;
+	bsw.0	// switch back to bank 0 (no stop bit required
beforehand...)
+	;;
+	ldf.fill f11=3D[r2]
+//	mov r18=3Dr13
+//    mov r21=3Dr13
+	adds r16=3DPT(CR_IPSR)+16,r12
+	adds r17=3DPT(CR_IIP)+16,r12
+	;;
+	ld8 r29=3D[r16],16	// load cr.ipsr
+	ld8 r28=3D[r17],16	// load cr.iip
+	;;
+	ld8 r30=3D[r16],16	// load cr.ifs
+	ld8 r25=3D[r17],16	// load ar.unat
+	;;
+	ld8 r26=3D[r16],16	// load ar.pfs
+	ld8 r27=3D[r17],16	// load ar.rsc
+	cmp.eq p9,p0=3Dr0,r0
+	// set p9 to indicate that we should restore cr.ifs
+	;;
+	ld8 r24=3D[r16],16	// load ar.rnat (may be garbage)
+	ld8 r23=3D[r17],16// load ar.bspstore (may be garbage)
+	;;
+	ld8 r31=3D[r16],16	// load predicates
+	ld8 r22=3D[r17],16	// load b0
+	;;
+	ld8 r19=3D[r16],16	// load ar.rsc value for "loadrs"
+	ld8.fill r1=3D[r17],16	// load r1
+	;;
+	ld8.fill r12=3D[r16],16
+	ld8.fill r13=3D[r17],16
+	;;
+	ld8 r20=3D[r16],16	// ar.fpsr
+	ld8.fill r15=3D[r17],16
+	;;
+	ld8.fill r14=3D[r16],16
+	ld8.fill r2=3D[r17]
+	;;
+	ld8.fill r3=3D[r16]
+	;;
+	mov r16=3Dar.bsp		// get existing backing store pointer
+	;;
+	mov b0=3Dr22
+	mov ar.pfs=3Dr26
+	mov cr.ifs=3Dr30
+	mov cr.ipsr=3Dr29
+	mov ar.fpsr=3Dr20
+	mov cr.iip=3Dr28
+	;;
+	mov ar.rsc=3Dr27
+	mov ar.unat=3Dr25
+	mov pr=3Dr31,-1
+	rfi
+END(ia64_leave_nested)
+
+
+
+GLOBAL_ENTRY(ia64_leave_hypervisor_prepare)
+    /*
+     * work.need_resched etc. mustn't get changed
+     *by this CPU before it returns to
+    ;;
+     * user- or fsys-mode, hence we disable interrupts early on:
+     */
+    adds r2 =3D PT(R4)+16,r12
+    adds r3 =3D PT(R5)+16,r12
+    adds r8 =3D PT(EML_UNAT)+16,r12
+    ;;
+    ld8 r8 =3D [r8]
+    ;;
+    mov ar.unat=3Dr8
+    ;;
+    ld8.fill r4=3D[r2],16    //load r4
+    ld8.fill r5=3D[r3],16    //load r5
+    ;;
+    ld8.fill r6=3D[r2]    //load r6
+    ld8.fill r7=3D[r3]    //load r7
+    ;;
+END(ia64_leave_hypervisor_prepare)
+//fall through
+GLOBAL_ENTRY(ia64_leave_hypervisor)
+    rsm psr.i
+    ;;
+    br.call.sptk.many b0=3Dleave_hypervisor_tail
+    ;;
+    adds r20=3DPT(PR)+16,r12
+    adds r8=3DPT(EML_UNAT)+16,r12
+    ;;
+    ld8 r8=3D[r8]
+    ;;
+    mov ar.unat=3Dr8
+    ;;
+    lfetch [r20],PT(CR_IPSR)-PT(PR)
+    adds r2 =3D PT(B6)+16,r12
+    adds r3 =3D PT(B7)+16,r12
+    ;;
+    lfetch [r20]
+    ;;
+    ld8 r24=3D[r2],16        /* B6 */
+    ld8 r25=3D[r3],16        /* B7 */
+    ;;
+    ld8 r26=3D[r2],16        /* ar_csd */
+    ld8 r27=3D[r3],16        /* ar_ssd */
+    mov b6 =3D r24
+    ;;
+    ld8.fill r8=3D[r2],16
+    ld8.fill r9=3D[r3],16
+    mov b7 =3D r25
+    ;;
+    mov ar.csd =3D r26
+    mov ar.ssd =3D r27
+    ;;
+    ld8.fill r10=3D[r2],PT(R15)-PT(R10)
+    ld8.fill r11=3D[r3],PT(R14)-PT(R11)
+    ;;
+    ld8.fill r15=3D[r2],PT(R16)-PT(R15)
+    ld8.fill r14=3D[r3],PT(R17)-PT(R14)
+    ;;
+    ld8.fill r16=3D[r2],16
+    ld8.fill r17=3D[r3],16
+    ;;
+    ld8.fill r18=3D[r2],16
+    ld8.fill r19=3D[r3],16
+    ;;
+    ld8.fill r20=3D[r2],16
+    ld8.fill r21=3D[r3],16
+    ;;
+    ld8.fill r22=3D[r2],16
+    ld8.fill r23=3D[r3],16
+    ;;
+    ld8.fill r24=3D[r2],16
+    ld8.fill r25=3D[r3],16
+    ;;
+    ld8.fill r26=3D[r2],16
+    ld8.fill r27=3D[r3],16
+    ;;
+    ld8.fill r28=3D[r2],16
+    ld8.fill r29=3D[r3],16
+    ;;
+    ld8.fill r30=3D[r2],PT(F6)-PT(R30)
+    ld8.fill r31=3D[r3],PT(F7)-PT(R31)
+    ;;
+    rsm psr.i | psr.ic
+    // initiate turning off of interrupt and interruption collection
+    invala          // invalidate ALAT
+    ;;
+    srlz.i          // ensure interruption collection is off
+    ;;
+    bsw.0
+    ;;
+    adds r16 =3D PT(CR_IPSR)+16,r12
+    adds r17 =3D PT(CR_IIP)+16,r12
+    mov r21=3Dr13		// get current
+    ;;
+    ld8 r31=3D[r16],16    // load cr.ipsr
+    ld8 r30=3D[r17],16    // load cr.iip
+    ;;
+    ld8 r29=3D[r16],16    // load cr.ifs
+    ld8 r28=3D[r17],16    // load ar.unat
+    ;;
+    ld8 r27=3D[r16],16    // load ar.pfs
+    ld8 r26=3D[r17],16    // load ar.rsc
+    ;;
+    ld8 r25=3D[r16],16    // load ar.rnat
+    ld8 r24=3D[r17],16    // load ar.bspstore
+    ;;
+    ld8 r23=3D[r16],16    // load predicates
+    ld8 r22=3D[r17],16    // load b0
+    ;;
+    ld8 r20=3D[r16],16    // load ar.rsc value for "loadrs"
+    ld8.fill r1=3D[r17],16    //load r1
+    ;;
+    ld8.fill r12=3D[r16],16    //load r12
+    ld8.fill r13=3D[r17],PT(R2)-PT(R13)    //load r13
+    ;;
+    ld8 r19=3D[r16],PT(R3)-PT(AR_FPSR)    //load ar_fpsr
+    ld8.fill r2=3D[r17],PT(AR_CCV)-PT(R2)    //load r2
+    ;;
+    ld8.fill r3=3D[r16]	//load r3
+    ld8 r18=3D[r17]	//load ar_ccv
+    ;;
+    mov ar.fpsr=3Dr19
+    mov ar.ccv=3Dr18
+    shr.u r18=3Dr20,16
+    ;;
+kvm_rbs_switch:
+    mov r19=3D96
+
+kvm_dont_preserve_current_frame:
+/*
+    * To prevent leaking bits between the hypervisor and guest domain,
+    * we must clear the stacked registers in the "invalid" partition
here.
+    * 5 registers/cycle on McKinley).
+    */
+#   define pRecurse	p6
+#   define pReturn	p7
+#   define Nregs	14
+
+    alloc loc0=3Dar.pfs,2,Nregs-2,2,0
+    shr.u loc1=3Dr18,9		// RNaTslots <=3D floor(dirtySize /
(64*8))
+    sub r19=3Dr19,r18		// r19 =3D (physStackedSize + 8) -
dirtySize
+    ;;
+    mov ar.rsc=3Dr20		// load ar.rsc to be used for "loadrs"
+    shladd in0=3Dloc1,3,r19
+    mov in1=3D0
+    ;;
+    TEXT_ALIGN(32)
+kvm_rse_clear_invalid:
+    alloc loc0=3Dar.pfs,2,Nregs-2,2,0
+    cmp.lt pRecurse,p0=3DNregs*8,in0
+    // if more than Nregs regs left to clear, (re)curse
+    add out0=3D-Nregs*8,in0
+    add out1=3D1,in1		// increment recursion count
+    mov loc1=3D0
+    mov loc2=3D0
+    ;;
+    mov loc3=3D0
+    mov loc4=3D0
+    mov loc5=3D0
+    mov loc6=3D0
+    mov loc7=3D0
+(pRecurse) br.call.dptk.few b0=3Dkvm_rse_clear_invalid
+    ;;
+    mov loc8=3D0
+    mov loc9=3D0
+    cmp.ne pReturn,p0=3Dr0,in1
+    // if recursion count !=3D 0, we need to do a br.ret
+    mov loc10=3D0
+    mov loc11=3D0
+(pReturn) br.ret.dptk.many b0
+
+#	undef pRecurse
+#	undef pReturn
+
+// loadrs has already been shifted
+    alloc r16=3Dar.pfs,0,0,0,0    // drop current register frame
+    ;;
+    loadrs
+    ;;
+    mov ar.bspstore=3Dr24
+    ;;
+    mov ar.unat=3Dr28
+    mov ar.rnat=3Dr25
+    mov ar.rsc=3Dr26
+    ;;
+    mov cr.ipsr=3Dr31
+    mov cr.iip=3Dr30
+    mov cr.ifs=3Dr29
+    mov ar.pfs=3Dr27
+    adds r18=3DVMM_VPD_BASE_OFFSET,r21
+    ;;
+    ld8 r18=3D[r18]   //vpd
+    adds r17=3DVMM_VCPU_ISR_OFFSET,r21
+    ;;
+    ld8 r17=3D[r17]
+    adds r19=3DVMM_VPD_VPSR_OFFSET,r18
+    ;;
+    ld8 r19=3D[r19]        //vpsr
+    adds r20=3DVMM_VCPU_VSA_BASE_OFFSET,r21
+    ;;
+    ld8 r20=3D[r20]
+    ;;
+//vsa_sync_write_start
+    mov r25=3Dr18
+    adds r16=3D VMM_VCPU_GP_OFFSET,r21
+    ;;
+    ld8 r16=3D [r16] // Put gp in r24
+    movl r24=3D@gprel(ia64_vmm_entry)  // calculate return address
+    ;;
+    add  r24=3Dr24,r16
+    ;;
+    add r16=3DPAL_VPS_SYNC_WRITE,r20
+    ;;
+    mov b0=3Dr16
+    br.cond.sptk b0         // call the service
+    ;;
+END(ia64_leave_hypervisor)
+// fall through
+GLOBAL_ENTRY(ia64_vmm_entry)
+/*
+ *  must be at bank 0
+ *  parameter:
+ *  r17:cr.isr
+ *  r18:vpd
+ *  r19:vpsr
+ *  r20:__vsa_base
+ *  r22:b0
+ *  r23:predicate
+ */
+    mov r24=3Dr22
+    mov r25=3Dr18
+    tbit.nz p1,p2 =3D r19,IA64_PSR_IC_BIT        // p1=3Dvpsr.ic
+    ;;
+    (p1) add r29=3DPAL_VPS_RESUME_NORMAL,r20
+    (p1) br.sptk.many ia64_vmm_entry_out
+    ;;
+    tbit.nz p1,p2 =3D r17,IA64_ISR_IR_BIT		//p1=3Dcr.isr.ir
+    ;;
+    (p1) add r29=3DPAL_VPS_RESUME_NORMAL,r20
+    (p2) add r29=3DPAL_VPS_RESUME_HANDLER,r20
+    (p2) ld8 r26=3D[r25]
+    ;;
+ia64_vmm_entry_out:
+    mov pr=3Dr23,-2
+    mov b0=3Dr29
+    ;;
+    br.cond.sptk b0             // call pal service
+END(ia64_vmm_entry)
+
+
+
+/*
+ * extern u64 ia64_call_vsa(u64 proc, u64 arg1, u64 arg2,
+ *                  u64 arg3, u64 arg4, u64 arg5,
+ *                  u64 arg6, u64 arg7);
+ *
+ * XXX: The currently defined services use only 4 args at the max. The
+ *  rest are not consumed.
+ */
+GLOBAL_ENTRY(ia64_call_vsa)
+    .regstk 4,4,0,0
+
+rpsave  =3D   loc0
+pfssave =3D   loc1
+psrsave =3D   loc2
+entry   =3D   loc3
+hostret =3D   r24
+
+    alloc   pfssave=3Dar.pfs,4,4,0,0
+    mov rpsave=3Drp
+    adds entry=3DVMM_VCPU_VSA_BASE_OFFSET, r13
+    ;;
+    ld8 entry=3D[entry]
+1:  mov hostret=3Dip
+    mov r25=3Din1         // copy arguments
+    mov r26=3Din2
+    mov r27=3Din3
+    mov psrsave=3Dpsr
+    ;;
+    tbit.nz p6,p0=3Dpsrsave,14    // IA64_PSR_I
+    tbit.nz p7,p0=3Dpsrsave,13    // IA64_PSR_IC
+    ;;
+    add hostret=3D2f-1b,hostret   // calculate return address
+    add entry=3Dentry,in0
+    ;;
+    rsm psr.i | psr.ic
+    ;;
+    srlz.i
+    mov b6=3Dentry
+    br.cond.sptk b6         // call the service
+2:
+    // Architectural sequence for enabling interrupts if necessary
+(p7)    ssm psr.ic
+    ;;
+(p7)    srlz.i
+    ;;
+//(p6)    ssm psr.i
+    ;;
+    mov rp=3Drpsave
+    mov ar.pfs=3Dpfssave
+    mov r8=3Dr31
+    ;;
+    srlz.d
+    br.ret.sptk rp
+
+END(ia64_call_vsa)
+
+#define  INIT_BSPSTORE  ((4<<30)-(12<<20)-0x100)
+
+GLOBAL_ENTRY(vmm_reset_entry)
+    //set up ipsr, iip, vpd.vpsr, dcr
+    // For IPSR: it/dt/rt=3D1, i/ic=3D1, si=3D1, vm/bn=3D1
+    // For DCR: all bits 0
+    adds r14=3D-VMM_PT_REGS_SIZE, r12
+    ;;
+    movl r6=3D0x501008826000      // IPSR dt/rt/it:1;i/ic:1, si:1,
vm/bn:1
+    movl r10=3D0x8000000000000000
+    adds r16=3DPT(CR_IIP), r14
+    adds r20=3DPT(R1), r14
+    ;;
+    rsm psr.ic | psr.i
+    ;;
+    srlz.i
+    ;;
+    bsw.0
+    ;;
+    mov r21 =3Dr13
+    ;;
+    bsw.1
+    ;;
+    mov ar.rsc =3D 0
+    ;;
+    flushrs
+    ;;
+    mov ar.bspstore =3D 0
+    // clear BSPSTORE
+    ;;
+    mov cr.ipsr=3Dr6
+    mov cr.ifs=3Dr10
+    ld8 r4 =3D [r16] // Set init iip for first run.
+    ld8 r1 =3D [r20]
+    ;;
+    mov cr.iip=3Dr4
+    ;;
+    adds r16=3DVMM_VPD_BASE_OFFSET,r13
+    adds r20=3DVMM_VCPU_VSA_BASE_OFFSET,r13
+    ;;
+    ld8 r18=3D[r16]
+    ld8 r20=3D[r20]
+    ;;
+    adds r19=3DVMM_VPD_VPSR_OFFSET,r18
+    ;;
+    ld8 r19=3D[r19]
+    mov r17=3Dr0
+    mov r22=3Dr0
+    mov r23=3Dr0
+    br.cond.sptk ia64_vmm_entry
+    br.ret.sptk  b0
+END(vmm_reset_entry)
+
--=20
1.5.2

------_=_NextPart_001_01C893E5.D0ECEEB3
Content-Type: application/octet-stream;
	name="0009-KVM-IA64-Add-interruption-vector-table-for-vmm.patch"
Content-Transfer-Encoding: base64
Content-Description: 0009-KVM-IA64-Add-interruption-vector-table-for-vmm.patch
Content-Disposition: attachment;
	filename="0009-KVM-IA64-Add-interruption-vector-table-for-vmm.patch"

RnJvbSBiYzE2NzMzNmRhOGViNDNlN2JhZjgwMjY5NWVhNzE2ODEyMWQ2Y2IyIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBYaWFudGFvIFpoYW5nIDx4aWFudGFvLnpoYW5nQGludGVsLmNv
bT4KRGF0ZTogVHVlLCAxIEFwciAyMDA4IDE0OjUyOjE5ICswODAwClN1YmplY3Q6IFtQQVRDSF0g
S1ZNOiBJQTY0IDogQWRkIGludGVycnVwdGlvbiB2ZWN0b3IgdGFibGUgZm9yIHZtbS4KCnZtbV9p
dnQuUyBpbmNsdWRlcyBhbiBpdnQgZm9yIHZtbSB1c2UuClNpZ25lZC1vZmYtYnk6IEFudGhvbnkg
WHUgPGFudGhvbnkueHVAaW50ZWwuY29tPgpTaWduZWQtb2ZmLWJ5OiBYaWFudGFvIFpoYW5nIDx4
aWFudGFvLnpoYW5nQGludGVsLmNvbT4KLS0tCiBhcmNoL2lhNjQva3ZtL3ZtbV9pdnQuUyB8IDE0
MjUgKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysKIDEgZmls
ZXMgY2hhbmdlZCwgMTQyNSBpbnNlcnRpb25zKCspLCAwIGRlbGV0aW9ucygtKQogY3JlYXRlIG1v
ZGUgMTAwNjQ0IGFyY2gvaWE2NC9rdm0vdm1tX2l2dC5TCgpkaWZmIC0tZ2l0IGEvYXJjaC9pYTY0
L2t2bS92bW1faXZ0LlMgYi9hcmNoL2lhNjQva3ZtL3ZtbV9pdnQuUwpuZXcgZmlsZSBtb2RlIDEw
MDY0NAppbmRleCAwMDAwMDAwLi5jOGIyYzZlCi0tLSAvZGV2L251bGwKKysrIGIvYXJjaC9pYTY0
L2t2bS92bW1faXZ0LlMKQEAgLTAsMCArMSwxNDI1IEBACisvKgorICogL2lhNjQva3ZtX2l2dC5T
CisgKgorICogQ29weXJpZ2h0IChDKSAxOTk4LTIwMDEsIDIwMDMgSGV3bGV0dC1QYWNrYXJkIENv
CisgKiAgICAgIFN0ZXBoYW5lIEVyYW5pYW4gPGVyYW5pYW5AaHBsLmhwLmNvbT4KKyAqICAgICAg
RGF2aWQgTW9zYmVyZ2VyIDxkYXZpZG1AaHBsLmhwLmNvbT4KKyAqIENvcHlyaWdodCAoQykgMjAw
MCwgMjAwMi0yMDAzIEludGVsIENvCisgKiAgICAgIEFzaXQgTWFsbGljayA8YXNpdC5rLm1hbGxp
Y2tAaW50ZWwuY29tPgorICogICAgICBTdXJlc2ggU2lkZGhhIDxzdXJlc2guYi5zaWRkaGFAaW50
ZWwuY29tPgorICogICAgICBLZW5uZXRoIENoZW4gPGtlbm5ldGgudy5jaGVuQGludGVsLmNvbT4K
KyAqICAgICAgRmVuZ2h1YSBZdSA8ZmVuZ2h1YS55dUBpbnRlbC5jb20+CisgKgorICoKKyAqIDAw
LzA4LzIzIEFzaXQgTWFsbGljayA8YXNpdC5rLm1hbGxpY2tAaW50ZWwuY29tPiBUTEIgaGFuZGxp
bmcKKyAqIGZvciBTTVAKKyAqIDAwLzEyLzIwIERhdmlkIE1vc2Jlcmdlci1UYW5nIDxkYXZpZG1A
aHBsLmhwLmNvbT4gRFRMQi9JVExCCisgKiBoYW5kbGVyIG5vdyB1c2VzIHZpcnR1YWwgUFQuCisg
KgorICogMDcvNi8yMCBYdWVmZWkgWHUgIChBbnRob255IFh1KSAoYW50aG9ueS54dUBpbnRlbC5j
b20pCisgKiAgICAgICAgICAgICAgU3VwcG9ydGluZyBJbnRlbCB2aXJ0dWFsaXphdGlvbiBhcmNo
aXRlY3R1cmUKKyAqCisgKi8KKworLyoKKyAqIFRoaXMgZmlsZSBkZWZpbmVzIHRoZSBpbnRlcnJ1
cHRpb24gdmVjdG9yIHRhYmxlIHVzZWQgYnkgdGhlIENQVS4KKyAqIEl0IGRvZXMgbm90IGluY2x1
ZGUgb25lIGVudHJ5IHBlciBwb3NzaWJsZSBjYXVzZSBvZiBpbnRlcnJ1cHRpb24uCisgKgorICog
VGhlIGZpcnN0IDIwIGVudHJpZXMgb2YgdGhlIHRhYmxlIGNvbnRhaW4gNjQgYnVuZGxlcyBlYWNo
IHdoaWxlIHRoZQorICogcmVtYWluaW5nIDQ4IGVudHJpZXMgY29udGFpbiBvbmx5IDE2IGJ1bmRs
ZXMgZWFjaC4KKyAqCisgKiBUaGUgNjQgYnVuZGxlcyBhcmUgdXNlZCB0byBhbGxvdyBpbmxpbmlu
ZyB0aGUgd2hvbGUgaGFuZGxlciBmb3IKKyAqIGNyaXRpY2FsCisgKiBpbnRlcnJ1cHRpb25zIGxp
a2UgVExCIG1pc3Nlcy4KKyAqCisgKiAgRm9yIGVhY2ggZW50cnksIHRoZSBjb21tZW50IGlzIGFz
IGZvbGxvd3M6CisgKgorICogICAgICAgICAgICAgIC8vIDB4MWMwMCBFbnRyeSA3IChzaXplIDY0
IGJ1bmRsZXMpIERhdGEgS2V5IE1pc3MKKyAqICAgICAgICAgICAgICAoMTIsNTEpCisgKiAgZW50
cnkgb2Zmc2V0IC0tLS0vICAgICAvICAgICAgICAgLyAgICAgICAgICAgICAgICAgIC8KKyAqICAv
CisgKiAgZW50cnkgbnVtYmVyIC0tLS0tLS0tLS8gICAgICAgICAvICAgICAgICAgICAgICAgICAg
LworICogIC8KKyAqICBzaXplIG9mIHRoZSBlbnRyeSAtLS0tLS0tLS0tLS0tLyAgICAgICAgICAg
ICAgICAgIC8KKyAqICAvCisgKiAgdmVjdG9yIG5hbWUgLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS8KKyAqICAvCisgKiAgaW50ZXJydXB0aW9ucyB0cmlnZ2VyaW5nIHRoaXMg
dmVjdG9yCisgKiAgLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS8KKyAqCisgKiBUaGUgdGFibGUgaXMg
MzJLQiBpbiBzaXplIGFuZCBtdXN0IGJlIGFsaWduZWQgb24gMzJLQgorICogYm91bmRhcnkuCisg
KiAoVGhlIENQVSBpZ25vcmVzIHRoZSAxNSBsb3dlciBiaXRzIG9mIHRoZSBhZGRyZXNzKQorICoK
KyAqIFRhYmxlIGlzIGJhc2VkIHVwb24gRUFTMi42IChPY3QgMTk5OSkKKyAqLworCisKKyNpbmNs
dWRlIDxhc20vYXNtbWFjcm8uaD4KKyNpbmNsdWRlIDxhc20vY2FjaGUuaD4KKyNpbmNsdWRlIDxh
c20vcGd0YWJsZS5oPgorCisjaW5jbHVkZSAiYXNtLW9mZnNldHMuaCIKKyNpbmNsdWRlICJ2Y3B1
LmgiCisjaW5jbHVkZSAia3ZtX21pbnN0YXRlLmgiCisjaW5jbHVkZSAidnRpLmgiCisKKyNpZiAx
CisjIGRlZmluZSBQU1JfREVGQVVMVF9CSVRTICAgcHNyLmFjCisjZWxzZQorIyBkZWZpbmUgUFNS
X0RFRkFVTFRfQklUUyAgIDAKKyNlbmRpZgorCisKKyNkZWZpbmUgS1ZNX0ZBVUxUKG4pICAgIFwK
KyAgICBrdm1fZmF1bHRfIyNuOjsgICAgICAgICAgXAorICAgIG1vdiByMTk9bjs7ICAgICAgICAg
IFwKKyAgICBici5zcHRrLm1hbnkga3ZtX2ZhdWx0XyMjbjsgICAgICAgICBcCisgICAgOzsgICAg
ICAgICAgICAgICAgICBcCisKKworI2RlZmluZSBLVk1fUkVGTEVDVChuKSAgICBcCisgICAgbW92
IHIzMT1wcjsgICAgICAgICAgIFwKKyAgICBtb3YgcjE5PW47ICAgICAgIC8qIHByZXBhcmUgdG8g
c2F2ZSBwcmVkaWNhdGVzICovIFwKKyAgICBtb3YgcjI5PWNyLmlwc3I7ICAgICAgXAorICAgIDs7
ICAgICAgXAorICAgIHRiaXQueiBwNixwNz1yMjksSUE2NF9QU1JfVk1fQklUOyAgICAgICBcCiso
cDcpYnIuc3B0ay5tYW55IGt2bV9kaXNwYXRjaF9yZWZsZWN0aW9uOyAgICAgICAgXAorICAgIGJy
LnNwdGsubWFueSBrdm1fcGFuaWM7ICAgICAgXAorCisKK0dMT0JBTF9FTlRSWShrdm1fcGFuaWMp
CisgICAgYnIuc3B0ay5tYW55IGt2bV9wYW5pYworICAgIDs7CitFTkQoa3ZtX3BhbmljKQorCisK
KworCisKKyAgICAuc2VjdGlvbiAudGV4dC5pdnQsImF4IgorCisgICAgLmFsaWduIDMyNzY4ICAg
IC8vIGFsaWduIG9uIDMyS0IgYm91bmRhcnkKKyAgICAuZ2xvYmFsIGt2bV9pYTY0X2l2dAora3Zt
X2lhNjRfaXZ0OgorLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vCisvLyAweDAwMDAgRW50cnkgMCAoc2l6ZSA2NCBidW5kbGVzKSBW
SFBUIFRyYW5zbGF0aW9uICg4LDIwLDQ3KQorRU5UUlkoa3ZtX3ZocHRfbWlzcykKKyAgICBLVk1f
RkFVTFQoMCkKK0VORChrdm1fdmhwdF9taXNzKQorCisKKyAgICAub3JnIGt2bV9pYTY0X2l2dCsw
eDQwMAorLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLworLy8gMHgwNDAwIEVudHJ5IDEgKHNpemUgNjQgYnVuZGxlcykgSVRMQiAo
MjEpCitFTlRSWShrdm1faXRsYl9taXNzKQorICAgIG1vdiByMzEgPSBwcgorICAgIG1vdiByMjk9
Y3IuaXBzcjsKKyAgICA7OworICAgIHRiaXQueiBwNixwNz1yMjksSUE2NF9QU1JfVk1fQklUOwor
ICAgIChwNikgYnIuc3B0ayBrdm1fYWx0X2l0bGJfbWlzcworICAgIG1vdiByMTkgPSAxCisgICAg
YnIuc3B0ayBrdm1faXRsYl9taXNzX2Rpc3BhdGNoCisgICAgS1ZNX0ZBVUxUKDEpOworRU5EKGt2
bV9pdGxiX21pc3MpCisKKyAgICAub3JnIGt2bV9pYTY0X2l2dCsweDA4MDAKKy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLwor
Ly8gMHgwODAwIEVudHJ5IDIgKHNpemUgNjQgYnVuZGxlcykgRFRMQiAoOSw0OCkKK0VOVFJZKGt2
bV9kdGxiX21pc3MpCisgICAgbW92IHIzMSA9IHByCisgICAgbW92IHIyOT1jci5pcHNyOworICAg
IDs7CisgICAgdGJpdC56IHA2LHA3PXIyOSxJQTY0X1BTUl9WTV9CSVQ7CisocDYpYnIuc3B0ayBr
dm1fYWx0X2R0bGJfbWlzcworICAgIGJyLnNwdGsga3ZtX2R0bGJfbWlzc19kaXNwYXRjaAorRU5E
KGt2bV9kdGxiX21pc3MpCisKKyAgICAgLm9yZyBrdm1faWE2NF9pdnQrMHgwYzAwCisvLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLworLy8gMHgwYzAwIEVudHJ5IDMgKHNpemUgNjQgYnVuZGxlcykgQWx0IElUTEIgKDE5KQor
RU5UUlkoa3ZtX2FsdF9pdGxiX21pc3MpCisgICAgbW92IHIxNj1jci5pZmEgICAgLy8gZ2V0IGFk
ZHJlc3MgdGhhdCBjYXVzZWQgdGhlIFRMQiBtaXNzCisgICAgOzsKKyAgICBtb3ZsIHIxNz1QQUdF
X0tFUk5FTAorICAgIG1vdiByMjQ9Y3IuaXBzcgorICAgIG1vdmwgcjE5PSgoKDEgPDwgSUE2NF9N
QVhfUEhZU19CSVRTKSAtIDEpICYgfjB4ZmZmKQorICAgIDs7CisgICAgYW5kIHIxOT1yMTkscjE2
ICAgICAvLyBjbGVhciBlZCwgcmVzZXJ2ZWQgYml0cywgYW5kIFBURSBjb250cm9sIGJpdHMKKyAg
ICA7OworICAgIG9yIHIxOT1yMTcscjE5ICAgICAgLy8gaW5zZXJ0IFBURSBjb250cm9sIGJpdHMg
aW50byByMTkKKyAgICA7OworICAgIG1vdmwgcjIwPUlBNjRfR1JBTlVMRV9TSElGVDw8MgorICAg
IDs7CisgICAgbW92IGNyLml0aXI9cjIwCisgICAgOzsKKyAgICBpdGMuaSByMTkJCS8vIGluc2Vy
dCB0aGUgVExCIGVudHJ5CisgICAgbW92IHByPXIzMSwtMQorICAgIHJmaQorRU5EKGt2bV9hbHRf
aXRsYl9taXNzKQorCisgICAgLm9yZyBrdm1faWE2NF9pdnQrMHgxMDAwCisvLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8K
Ky8vIDB4MTAwMCBFbnRyeSA0IChzaXplIDY0IGJ1bmRsZXMpIEFsdCBEVExCICg3LDQ2KQorRU5U
Ulkoa3ZtX2FsdF9kdGxiX21pc3MpCisgICAgbW92IHIxNj1jci5pZmEJCS8vIGdldCBhZGRyZXNz
IHRoYXQgY2F1c2VkIHRoZSBUTEIgbWlzcworICAgIDs7CisgICAgbW92bCByMTc9UEFHRV9LRVJO
RUwKKyAgICBtb3ZsIHIxOT0oKCgxIDw8IElBNjRfTUFYX1BIWVNfQklUUykgLSAxKSAmIH4weGZm
ZikKKyAgICBtb3YgcjI0PWNyLmlwc3IKKyAgICA7OworICAgIGFuZCByMTk9cjE5LHIxNiAgICAg
Ly8gY2xlYXIgZWQsIHJlc2VydmVkIGJpdHMsIGFuZCBQVEUgY29udHJvbCBiaXRzCisgICAgOzsK
KyAgICBvciByMTk9cjE5LHIxNwkvLyBpbnNlcnQgUFRFIGNvbnRyb2wgYml0cyBpbnRvIHIxOQor
ICAgIDs7CisgICAgbW92bCByMjA9SUE2NF9HUkFOVUxFX1NISUZUPDwyCisgICAgOzsKKyAgICBt
b3YgY3IuaXRpcj1yMjAKKyAgICA7OworICAgIGl0Yy5kIHIxOQkJLy8gaW5zZXJ0IHRoZSBUTEIg
ZW50cnkKKyAgICBtb3YgcHI9cjMxLC0xCisgICAgcmZpCitFTkQoa3ZtX2FsdF9kdGxiX21pc3Mp
CisKKyAgICAub3JnIGt2bV9pYTY0X2l2dCsweDE0MDAKKy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8KKy8vIDB4MTQw
MCBFbnRyeSA1IChzaXplIDY0IGJ1bmRsZXMpIERhdGEgbmVzdGVkIFRMQiAoNiw0NSkKK0VOVFJZ
KGt2bV9uZXN0ZWRfZHRsYl9taXNzKQorICAgIEtWTV9GQVVMVCg1KQorRU5EKGt2bV9uZXN0ZWRf
ZHRsYl9taXNzKQorCisgICAgLm9yZyBrdm1faWE2NF9pdnQrMHgxODAwCisvLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8K
Ky8vIDB4MTgwMCBFbnRyeSA2IChzaXplIDY0IGJ1bmRsZXMpIEluc3RydWN0aW9uIEtleSBNaXNz
ICgyNCkKK0VOVFJZKGt2bV9pa2V5X21pc3MpCisgICAgS1ZNX1JFRkxFQ1QoNikKK0VORChrdm1f
aWtleV9taXNzKQorCisgICAgLm9yZyBrdm1faWE2NF9pdnQrMHgxYzAwCisvLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8K
Ky8vIDB4MWMwMCBFbnRyeSA3IChzaXplIDY0IGJ1bmRsZXMpIERhdGEgS2V5IE1pc3MgKDEyLDUx
KQorRU5UUlkoa3ZtX2RrZXlfbWlzcykKKyAgICBLVk1fUkVGTEVDVCg3KQorRU5EKGt2bV9ka2V5
X21pc3MpCisKKyAgICAub3JnIGt2bV9pYTY0X2l2dCsweDIwMDAKKy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vCisvLyAw
eDIwMDAgRW50cnkgOCAoc2l6ZSA2NCBidW5kbGVzKSBEaXJ0eS1iaXQgKDU0KQorRU5UUlkoa3Zt
X2RpcnR5X2JpdCkKKyAgICBLVk1fUkVGTEVDVCg4KQorRU5EKGt2bV9kaXJ0eV9iaXQpCisKKyAg
ICAub3JnIGt2bV9pYTY0X2l2dCsweDI0MDAKKy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vCisvLyAweDI0MDAgRW50cnkg
OSAoc2l6ZSA2NCBidW5kbGVzKSBJbnN0cnVjdGlvbiBBY2Nlc3MtYml0ICgyNykKK0VOVFJZKGt2
bV9pYWNjZXNzX2JpdCkKKyAgICBLVk1fUkVGTEVDVCg5KQorRU5EKGt2bV9pYWNjZXNzX2JpdCkK
KworICAgIC5vcmcga3ZtX2lhNjRfaXZ0KzB4MjgwMAorLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLworLy8gMHgyODAwIEVu
dHJ5IDEwIChzaXplIDY0IGJ1bmRsZXMpIERhdGEgQWNjZXNzLWJpdCAoMTUsNTUpCitFTlRSWShr
dm1fZGFjY2Vzc19iaXQpCisgICAgS1ZNX1JFRkxFQ1QoMTApCitFTkQoa3ZtX2RhY2Nlc3NfYml0
KQorCisgICAgLm9yZyBrdm1faWE2NF9pdnQrMHgyYzAwCisvLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLworLy8gMHgyYzAwIEVu
dHJ5IDExIChzaXplIDY0IGJ1bmRsZXMpIEJyZWFrIGluc3RydWN0aW9uICgzMykKK0VOVFJZKGt2
bV9icmVha19mYXVsdCkKKyAgICBtb3YgcjMxPXByCisgICAgbW92IHIxOT0xMQorICAgIG1vdiBy
Mjk9Y3IuaXBzcgorICAgIDs7CisgICAgS1ZNX1NBVkVfTUlOX1dJVEhfQ09WRVJfUjE5CisgICAg
OzsKKyAgICBhbGxvYyByMTQ9YXIucGZzLDAsMCw0LDAgLy8gbm93IGl0J3Mgc2FmZSAobXVzdCBi
ZSBmaXJzdCBpbiBpbnNuIGdyb3VwISkKKyAgICBtb3Ygb3V0MD1jci5pZmEKKyAgICBtb3Ygb3V0
Mj1jci5pc3IgICAgIC8vIEZJWE1FOiBwaXR5IHRvIG1ha2UgdGhpcyBzbG93IGFjY2VzcyB0d2lj
ZQorICAgIG1vdiBvdXQzPWNyLmlpbSAgICAgLy8gRklYTUU6IHBpdHkgdG8gbWFrZSB0aGlzIHNs
b3cgYWNjZXNzIHR3aWNlCisgICAgYWRkcyByMz04LHIyICAgICAgICAgICAgICAgIC8vIHNldCB1
cCBzZWNvbmQgYmFzZSBwb2ludGVyCisgICAgOzsKKyAgICBzc20gcHNyLmljCisgICAgOzsKKyAg
ICBzcmx6LmkgICAgICAgICAgICAgICAgICAvLyBndWFyYW50ZWUgdGhhdCBpbnRlcnJ1cHRpb24g
Y29sbGVjdGlvbiBpcyBvbgorICAgIDs7CisgICAgLy8ocDE1KXNzbSBwc3IuaSAgICAgICAgICAg
ICAgIC8vIHJlc3RvcmUgcHNyLmkKKyAgICBhZGRsIHIxND1AZ3ByZWwoaWE2NF9sZWF2ZV9oeXBl
cnZpc29yKSxncAorICAgIDs7CisgICAgS1ZNX1NBVkVfUkVTVAorICAgIG1vdiBycD1yMTQKKyAg
ICA7OworICAgIGFkZHMgb3V0MT0xNixzcAorICAgIGJyLmNhbGwuc3B0ay5tYW55IGI2PWt2bV9p
YTY0X2hhbmRsZV9icmVhaworICAgIDs7CitFTkQoa3ZtX2JyZWFrX2ZhdWx0KQorCisgICAgLm9y
ZyBrdm1faWE2NF9pdnQrMHgzMDAwCisvLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLworLy8gMHgzMDAwIEVudHJ5IDEyIChzaXpl
IDY0IGJ1bmRsZXMpIEV4dGVybmFsIEludGVycnVwdCAoNCkKK0VOVFJZKGt2bV9pbnRlcnJ1cHQp
CisgICAgbW92IHIzMT1wcgkJLy8gcHJlcGFyZSB0byBzYXZlIHByZWRpY2F0ZXMKKyAgICBtb3Yg
cjE5PTEyCisgICAgbW92IHIyOT1jci5pcHNyCisgICAgOzsKKyAgICB0Yml0LnogcDYscDc9cjI5
LElBNjRfUFNSX1ZNX0JJVAorICAgIHRiaXQueiBwMCxwMTU9cjI5LElBNjRfUFNSX0lfQklUCisg
ICAgOzsKKyhwNykgYnIuc3B0ayBrdm1fZGlzcGF0Y2hfaW50ZXJydXB0CisgICAgOzsKKyAgICBt
b3YgcjI3PWFyLnJzYwkJLyogTSAqLworICAgIG1vdiByMjA9cjEJCQkvKiBBICovCisgICAgbW92
IHIyNT1hci51bmF0CQkvKiBNICovCisgICAgbW92IHIyNj1hci5wZnMJCS8qIEkgKi8KKyAgICBt
b3YgcjI4PWNyLmlpcAkJLyogTSAqLworICAgIGNvdmVyCQkJLyogQiAob3Igbm90aGluZykgKi8K
KyAgICA7OworICAgIG1vdiByMT1zcAorICAgIDs7CisgICAgaW52YWxhCQkJLyogTSAqLworICAg
IG1vdiByMzA9Y3IuaWZzCisgICAgOzsKKyAgICBhZGRsIHIxPS1WTU1fUFRfUkVHU19TSVpFLHIx
CisgICAgOzsKKyAgICBhZGRzIHIxNz0yKkwxX0NBQ0hFX0JZVEVTLHIxCS8qIHJlYWxseTogYmln
Z2VzdCBjYWNoZS1saW5lIHNpemUgKi8KKyAgICBhZGRzIHIxNj1QVChDUl9JUFNSKSxyMQorICAg
IDs7CisgICAgbGZldGNoLmZhdWx0LmV4Y2wubnQxIFtyMTddLEwxX0NBQ0hFX0JZVEVTCisgICAg
c3Q4IFtyMTZdPXIyOQkJCS8qIHNhdmUgY3IuaXBzciAqLworICAgIDs7CisgICAgbGZldGNoLmZh
dWx0LmV4Y2wubnQxIFtyMTddCisgICAgbW92IHIyOT1iMAorICAgIDs7CisgICAgYWRkcyByMTY9
UFQoUjgpLHIxICAJLyogaW5pdGlhbGl6ZSBmaXJzdCBiYXNlIHBvaW50ZXIgKi8KKyAgICBhZGRz
IHIxNz1QVChSOSkscjEgIAkvKiBpbml0aWFsaXplIHNlY29uZCBiYXNlIHBvaW50ZXIgKi8KKyAg
ICBtb3YgcjE4PXIwICAgICAgCQkvKiBtYWtlIHN1cmUgcjE4IGlzbid0IE5hVCAqLworICAgIDs7
CisubWVtLm9mZnNldCAwLDA7IHN0OC5zcGlsbCBbcjE2XT1yOCwxNgorLm1lbS5vZmZzZXQgOCww
OyBzdDguc3BpbGwgW3IxN109cjksMTYKKyAgICAgICAgOzsKKy5tZW0ub2Zmc2V0IDAsMDsgc3Q4
LnNwaWxsIFtyMTZdPXIxMCwyNAorLm1lbS5vZmZzZXQgOCwwOyBzdDguc3BpbGwgW3IxN109cjEx
LDI0CisgICAgICAgIDs7CisgICAgc3Q4IFtyMTZdPXIyOCwxNgkJLyogc2F2ZSBjci5paXAgKi8K
KyAgICBzdDggW3IxN109cjMwLDE2CQkvKiBzYXZlIGNyLmlmcyAqLworICAgIG1vdiByOD1hci5m
cHNyCQkvKiBNICovCisgICAgbW92IHI5PWFyLmNzZAorICAgIG1vdiByMTA9YXIuc3NkCisgICAg
bW92bCByMTE9RlBTUl9ERUZBVUxUCS8qIEwtdW5pdCAqLworICAgIDs7CisgICAgc3Q4IFtyMTZd
PXIyNSwxNgkJLyogc2F2ZSBhci51bmF0ICovCisgICAgc3Q4IFtyMTddPXIyNiwxNgkJLyogc2F2
ZSBhci5wZnMgKi8KKyAgICBzaGwgcjE4PXIxOCwxNgkJLyogY29tcHV0ZSBhci5yc2MgdG8gYmUg
dXNlZCBmb3IgImxvYWRycyIgKi8KKyAgICA7OworICAgIHN0OCBbcjE2XT1yMjcsMTYJCS8qIHNh
dmUgYXIucnNjICovCisgICAgYWRkcyByMTc9MTYscjE3CQkvKiBza2lwIG92ZXIgYXJfcm5hdCBm
aWVsZCAqLworICAgIDs7CisgICAgc3Q4IFtyMTddPXIzMSwxNgkJLyogc2F2ZSBwcmVkaWNhdGVz
ICovCisgICAgYWRkcyByMTY9MTYscjE2CQkvKiBza2lwIG92ZXIgYXJfYnNwc3RvcmUgZmllbGQg
Ki8KKyAgICA7OworICAgIHN0OCBbcjE2XT1yMjksMTYJCS8qIHNhdmUgYjAgKi8KKyAgICBzdDgg
W3IxN109cjE4LDE2CQkvKiBzYXZlIGFyLnJzYyB2YWx1ZSBmb3IgImxvYWRycyIgKi8KKyAgICA7
OworLm1lbS5vZmZzZXQgMCwwOyBzdDguc3BpbGwgW3IxNl09cjIwLDE2ICAgIC8qIHNhdmUgb3Jp
Z2luYWwgcjEgKi8KKy5tZW0ub2Zmc2V0IDgsMDsgc3Q4LnNwaWxsIFtyMTddPXIxMiwxNgorICAg
IGFkZHMgcjEyPS0xNixyMQorICAgIC8qIHN3aXRjaCB0byBrZXJuZWwgbWVtb3J5IHN0YWNrICh3
aXRoIDE2IGJ5dGVzIG9mIHNjcmF0Y2gpICovCisgICAgOzsKKy5tZW0ub2Zmc2V0IDAsMDsgc3Q4
LnNwaWxsIFtyMTZdPXIxMywxNgorLm1lbS5vZmZzZXQgOCwwOyBzdDguc3BpbGwgW3IxN109cjgs
MTYgLyogc2F2ZSBhci5mcHNyICovCisgICAgOzsKKy5tZW0ub2Zmc2V0IDAsMDsgc3Q4LnNwaWxs
IFtyMTZdPXIxNSwxNgorLm1lbS5vZmZzZXQgOCwwOyBzdDguc3BpbGwgW3IxN109cjE0LDE2Cisg
ICAgZGVwIHIxND0tMSxyMCw2MCw0CisgICAgOzsKKy5tZW0ub2Zmc2V0IDAsMDsgc3Q4LnNwaWxs
IFtyMTZdPXIyLDE2CisubWVtLm9mZnNldCA4LDA7IHN0OC5zcGlsbCBbcjE3XT1yMywxNgorICAg
IGFkZHMgcjI9Vk1NX1BUX1JFR1NfUjE2X09GRlNFVCxyMQorICAgIGFkZHMgcjE0ID0gVk1NX1ZD
UFVfR1BfT0ZGU0VULHIxMworICAgIDs7CisgICAgbW92IHI4PWFyLmNjdgorICAgIGxkOCByMTQg
PSBbcjE0XQorICAgIDs7CisgICAgbW92IHIxPXIxNCAgICAgICAvKiBlc3RhYmxpc2gga2VybmVs
IGdsb2JhbCBwb2ludGVyICovCisgICAgOzsgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICBcCisgICAgYnN3LjEKKyAgICA7OworICAgIGFsbG9jIHIxND1hci5wZnMsMCww
LDEsMAkvLyBtdXN0IGJlIGZpcnN0IGluIGFuIGluc24gZ3JvdXAKKyAgICBtb3Ygb3V0MD1yMTMK
KyAgICA7OworICAgIHNzbSBwc3IuaWMKKyAgICA7OworICAgIHNybHouaQorICAgIDs7CisgICAg
Ly8ocDE1KSBzc20gcHNyLmkKKyAgICBhZGRzIHIzPTgscjIJCS8vIHNldCB1cCBzZWNvbmQgYmFz
ZSBwb2ludGVyIGZvciBTQVZFX1JFU1QKKyAgICBzcmx6LmkJCQkvLyBlbnN1cmUgZXZlcnlib2R5
IGtub3dzIHBzci5pYyBpcyBiYWNrIG9uCisgICAgOzsKKy5tZW0ub2Zmc2V0IDAsMDsgc3Q4LnNw
aWxsIFtyMl09cjE2LDE2CisubWVtLm9mZnNldCA4LDA7IHN0OC5zcGlsbCBbcjNdPXIxNywxNgor
ICAgIDs7CisubWVtLm9mZnNldCAwLDA7IHN0OC5zcGlsbCBbcjJdPXIxOCwxNgorLm1lbS5vZmZz
ZXQgOCwwOyBzdDguc3BpbGwgW3IzXT1yMTksMTYKKyAgICA7OworLm1lbS5vZmZzZXQgMCwwOyBz
dDguc3BpbGwgW3IyXT1yMjAsMTYKKy5tZW0ub2Zmc2V0IDgsMDsgc3Q4LnNwaWxsIFtyM109cjIx
LDE2CisgICAgbW92IHIxOD1iNgorICAgIDs7CisubWVtLm9mZnNldCAwLDA7IHN0OC5zcGlsbCBb
cjJdPXIyMiwxNgorLm1lbS5vZmZzZXQgOCwwOyBzdDguc3BpbGwgW3IzXT1yMjMsMTYKKyAgICBt
b3YgcjE5PWI3CisgICAgOzsKKy5tZW0ub2Zmc2V0IDAsMDsgc3Q4LnNwaWxsIFtyMl09cjI0LDE2
CisubWVtLm9mZnNldCA4LDA7IHN0OC5zcGlsbCBbcjNdPXIyNSwxNgorICAgIDs7CisubWVtLm9m
ZnNldCAwLDA7IHN0OC5zcGlsbCBbcjJdPXIyNiwxNgorLm1lbS5vZmZzZXQgOCwwOyBzdDguc3Bp
bGwgW3IzXT1yMjcsMTYKKyAgICA7OworLm1lbS5vZmZzZXQgMCwwOyBzdDguc3BpbGwgW3IyXT1y
MjgsMTYKKy5tZW0ub2Zmc2V0IDgsMDsgc3Q4LnNwaWxsIFtyM109cjI5LDE2CisgICAgOzsKKy5t
ZW0ub2Zmc2V0IDAsMDsgc3Q4LnNwaWxsIFtyMl09cjMwLDE2CisubWVtLm9mZnNldCA4LDA7IHN0
OC5zcGlsbCBbcjNdPXIzMSwzMgorICAgIDs7CisgICAgbW92IGFyLmZwc3I9cjExICAgICAgIC8q
IE0tdW5pdCAqLworICAgIHN0OCBbcjJdPXI4LDggICAgICAgICAvKiBhci5jY3YgKi8KKyAgICBh
ZGRzIHIyND1QVChCNiktUFQoRjcpLHIzCisgICAgOzsKKyAgICBzdGYuc3BpbGwgW3IyXT1mNiwz
MgorICAgIHN0Zi5zcGlsbCBbcjNdPWY3LDMyCisgICAgOzsKKyAgICBzdGYuc3BpbGwgW3IyXT1m
OCwzMgorICAgIHN0Zi5zcGlsbCBbcjNdPWY5LDMyCisgICAgOzsKKyAgICBzdGYuc3BpbGwgW3Iy
XT1mMTAKKyAgICBzdGYuc3BpbGwgW3IzXT1mMTEKKyAgICBhZGRzIHIyNT1QVChCNyktUFQoRjEx
KSxyMworICAgIDs7CisgICAgc3Q4IFtyMjRdPXIxOCwxNiAgICAgICAvKiBiNiAqLworICAgIHN0
OCBbcjI1XT1yMTksMTYgICAgICAgLyogYjcgKi8KKyAgICA7OworICAgIHN0OCBbcjI0XT1yOSAg
ICAgICAgICAgLyogYXIuY3NkICovCisgICAgc3Q4IFtyMjVdPXIxMCAgICAgICAgICAvKiBhci5z
c2QgKi8KKyAgICA7OworICAgIHNybHouZAkJLy8gbWFrZSBzdXJlIHdlIHNlZSB0aGUgZWZmZWN0
IG9mIGNyLml2cgorICAgIGFkZGwgcjE0PUBncHJlbChpYTY0X2xlYXZlX25lc3RlZCksZ3AKKyAg
ICA7OworICAgIG1vdiBycD1yMTQKKyAgICBici5jYWxsLnNwdGsubWFueSBiNj1rdm1faWE2NF9o
YW5kbGVfaXJxCisgICAgOzsKK0VORChrdm1faW50ZXJydXB0KQorCisgICAgLmdsb2JhbCBrdm1f
ZGlzcGF0Y2hfdmV4aXJxCisgICAgLm9yZyBrdm1faWE2NF9pdnQrMHgzNDAwCisvLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vCisvLyAweDM0MDAgRW50cnkgMTMgKHNpemUgNjQgYnVuZGxlcykgUmVzZXJ2ZWQKK0VOVFJZ
KGt2bV92aXJ0dWFsX2V4aXJxKQorICAgIG1vdiByMzE9cHIKKyAgICBtb3YgcjE5PTEzCisgICAg
bW92IHIzMCA9cjAKKyAgICA7Owora3ZtX2Rpc3BhdGNoX3ZleGlycToKKyAgICBjbXAuZXEgcDYs
cDAgPSAxLHIzMAorICAgIDs7CisocDYpYWRkIHIyOSA9IFZNTV9WQ1BVX1NBVkVEX0dQX09GRlNF
VCxyMjEKKyAgICA7OworKHA2KWxkOCByMSA9IFtyMjldCisgICAgOzsKKyAgICBLVk1fU0FWRV9N
SU5fV0lUSF9DT1ZFUl9SMTkKKyAgICBhbGxvYyByMTQ9YXIucGZzLDAsMCwxLDAKKyAgICBtb3Yg
b3V0MD1yMTMKKworICAgIHNzbSBwc3IuaWMKKyAgICA7OworICAgIHNybHouaSAgICAgICAgICAg
ICAgICAgIC8vIGd1YXJhbnRlZSB0aGF0IGludGVycnVwdGlvbiBjb2xsZWN0aW9uIGlzIG9uCisg
ICAgOzsKKyAgICAvLyhwMTUpIHNzbSBwc3IuaSAgICAgICAgICAgICAgIC8vIHJlc3RvcmUgcHNy
LmkKKyAgICBhZGRzIHIzPTgscjIgICAgICAgICAgICAgICAgLy8gc2V0IHVwIHNlY29uZCBiYXNl
IHBvaW50ZXIKKyAgICA7OworICAgIEtWTV9TQVZFX1JFU1QKKyAgICBhZGRsIHIxND1AZ3ByZWwo
aWE2NF9sZWF2ZV9oeXBlcnZpc29yKSxncAorICAgIDs7CisgICAgbW92IHJwPXIxNAorICAgIGJy
LmNhbGwuc3B0ay5tYW55IGI2PWt2bV92ZXhpcnEKK0VORChrdm1fdmlydHVhbF9leGlycSkKKwor
ICAgIC5vcmcga3ZtX2lhNjRfaXZ0KzB4MzgwMAorLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vCisvLyAweDM4MDAgRW50
cnkgMTQgKHNpemUgNjQgYnVuZGxlcykgUmVzZXJ2ZWQKKyAgICBLVk1fRkFVTFQoMTQpCisgICAg
Ly8gdGhpcyBjb2RlIHNlZ21lbnQgaXMgZnJvbSAyLjYuMTYuMTMKKworCisgICAgLm9yZyBrdm1f
aWE2NF9pdnQrMHgzYzAwCisvLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLworLy8gMHgzYzAwIEVudHJ5IDE1IChzaXpl
IDY0IGJ1bmRsZXMpIFJlc2VydmVkCisgICAgS1ZNX0ZBVUxUKDE1KQorCisKKyAgICAub3JnIGt2
bV9pYTY0X2l2dCsweDQwMDAKKy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vCisvLyAweDQwMDAgRW50cnkgMTYgKHNp
emUgNjQgYnVuZGxlcykgUmVzZXJ2ZWQKKyAgICBLVk1fRkFVTFQoMTYpCisKKyAgICAub3JnIGt2
bV9pYTY0X2l2dCsweDQ0MDAKKy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8KKy8vIDB4NDQwMCBFbnRyeSAxNyAoc2l6
ZSA2NCBidW5kbGVzKSBSZXNlcnZlZAorICAgIEtWTV9GQVVMVCgxNykKKworICAgIC5vcmcga3Zt
X2lhNjRfaXZ0KzB4NDgwMAorLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLworLy8gMHg0ODAwIEVudHJ5IDE4IChzaXpl
IDY0IGJ1bmRsZXMpIFJlc2VydmVkCisgICAgS1ZNX0ZBVUxUKDE4KQorCisgICAgLm9yZyBrdm1f
aWE2NF9pdnQrMHg0YzAwCisvLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vCisvLyAweDRjMDAgRW50cnkgMTkgKHNpemUg
NjQgYnVuZGxlcykgUmVzZXJ2ZWQKKyAgICBLVk1fRkFVTFQoMTkpCisKKyAgICAub3JnIGt2bV9p
YTY0X2l2dCsweDUwMDAKKy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8KKy8vIDB4NTAwMCBFbnRyeSAyMCAoc2l6ZSAx
NiBidW5kbGVzKSBQYWdlIE5vdCBQcmVzZW50CitFTlRSWShrdm1fcGFnZV9ub3RfcHJlc2VudCkK
KyAgICBLVk1fUkVGTEVDVCgyMCkKK0VORChrdm1fcGFnZV9ub3RfcHJlc2VudCkKKworICAgIC5v
cmcga3ZtX2lhNjRfaXZ0KzB4NTEwMAorLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8KKy8vIDB4NTEwMCBFbnRyeSAy
MSAoc2l6ZSAxNiBidW5kbGVzKSBLZXkgUGVybWlzc2lvbiB2ZWN0b3IKK0VOVFJZKGt2bV9rZXlf
cGVybWlzc2lvbikKKyAgICBLVk1fUkVGTEVDVCgyMSkKK0VORChrdm1fa2V5X3Blcm1pc3Npb24p
CisKKyAgICAub3JnIGt2bV9pYTY0X2l2dCsweDUyMDAKKy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8KKy8vIDB4NTIw
MCBFbnRyeSAyMiAoc2l6ZSAxNiBidW5kbGVzKSBJbnN0cnVjdGlvbiBBY2Nlc3MgUmlnaHRzICgy
NikKK0VOVFJZKGt2bV9pYWNjZXNzX3JpZ2h0cykKKyAgICBLVk1fUkVGTEVDVCgyMikKK0VORChr
dm1faWFjY2Vzc19yaWdodHMpCisKKyAgICAub3JnIGt2bV9pYTY0X2l2dCsweDUzMDAKKy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8KKy8vIDB4NTMwMCBFbnRyeSAyMyAoc2l6ZSAxNiBidW5kbGVzKSBEYXRhIEFjY2Vz
cyBSaWdodHMgKDE0LDUzKQorRU5UUlkoa3ZtX2RhY2Nlc3NfcmlnaHRzKQorICAgIEtWTV9SRUZM
RUNUKDIzKQorRU5EKGt2bV9kYWNjZXNzX3JpZ2h0cykKKworICAgIC5vcmcga3ZtX2lhNjRfaXZ0
KzB4NTQwMAorLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vCisvLyAweDU0MDAgRW50cnkgMjQgKHNpemUgMTYgYnVuZGxl
cykgR2VuZXJhbCBFeGNlcHRpb24gKDUsMzIsMzQsMzYsMzgsMzkpCitFTlRSWShrdm1fZ2VuZXJh
bF9leGNlcHRpb24pCisgICBLVk1fUkVGTEVDVCgyNCkKKyAgIEtWTV9GQVVMVCgyNCkKK0VORChr
dm1fZ2VuZXJhbF9leGNlcHRpb24pCisKKyAgICAub3JnIGt2bV9pYTY0X2l2dCsweDU1MDAKKy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8KKy8vIDB4NTUwMCBFbnRyeSAyNSAoc2l6ZSAxNiBidW5kbGVzKSBEaXNhYmxl
ZCBGUC1SZWdpc3RlciAoMzUpCitFTlRSWShrdm1fZGlzYWJsZWRfZnBfcmVnKQorICAgIEtWTV9S
RUZMRUNUKDI1KQorRU5EKGt2bV9kaXNhYmxlZF9mcF9yZWcpCisKKyAgICAub3JnIGt2bV9pYTY0
X2l2dCsweDU2MDAKKy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vCisvLyAweDU2MDAgRW50cnkgMjYgKHNpemUgMTYgYnVu
ZGxlcykgTmF0IENvbnN1bXB0aW9uICgxMSwyMywzNyw1MCkKK0VOVFJZKGt2bV9uYXRfY29uc3Vt
cHRpb24pCisgICAgS1ZNX1JFRkxFQ1QoMjYpCitFTkQoa3ZtX25hdF9jb25zdW1wdGlvbikKKwor
ICAgIC5vcmcga3ZtX2lhNjRfaXZ0KzB4NTcwMAorLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vCisvLyAweDU3MDAgRW50
cnkgMjcgKHNpemUgMTYgYnVuZGxlcykgU3BlY3VsYXRpb24gKDQwKQorRU5UUlkoa3ZtX3NwZWN1
bGF0aW9uX3ZlY3RvcikKKyAgICBLVk1fUkVGTEVDVCgyNykKK0VORChrdm1fc3BlY3VsYXRpb25f
dmVjdG9yKQorCisgICAgLm9yZyBrdm1faWE2NF9pdnQrMHg1ODAwCisvLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8KKy8v
IDB4NTgwMCBFbnRyeSAyOCAoc2l6ZSAxNiBidW5kbGVzKSBSZXNlcnZlZAorICAgIEtWTV9GQVVM
VCgyOCkKKworICAgIC5vcmcga3ZtX2lhNjRfaXZ0KzB4NTkwMAorLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLworLy8gMHg1
OTAwIEVudHJ5IDI5IChzaXplIDE2IGJ1bmRsZXMpIERlYnVnICgxNiwyOCw1NikKK0VOVFJZKGt2
bV9kZWJ1Z192ZWN0b3IpCisgICAgS1ZNX0ZBVUxUKDI5KQorRU5EKGt2bV9kZWJ1Z192ZWN0b3Ip
CisKKyAgICAub3JnIGt2bV9pYTY0X2l2dCsweDVhMDAKKy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLworLy8gMHg1YTAwIEVudHJ5
IDMwIChzaXplIDE2IGJ1bmRsZXMpIFVuYWxpZ25lZCBSZWZlcmVuY2UgKDU3KQorRU5UUlkoa3Zt
X3VuYWxpZ25lZF9hY2Nlc3MpCisgICAgS1ZNX1JFRkxFQ1QoMzApCitFTkQoa3ZtX3VuYWxpZ25l
ZF9hY2Nlc3MpCisKKyAgICAub3JnIGt2bV9pYTY0X2l2dCsweDViMDAKKy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8K
Ky8vIDB4NWIwMCBFbnRyeSAzMSAoc2l6ZSAxNiBidW5kbGVzKSBVbnN1cHBvcnRlZCBEYXRhIFJl
ZmVyZW5jZSAoNTcpCitFTlRSWShrdm1fdW5zdXBwb3J0ZWRfZGF0YV9yZWZlcmVuY2UpCisgICAg
S1ZNX1JFRkxFQ1QoMzEpCitFTkQoa3ZtX3Vuc3VwcG9ydGVkX2RhdGFfcmVmZXJlbmNlKQorCisg
ICAgLm9yZyBrdm1faWE2NF9pdnQrMHg1YzAwCisvLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLworLy8gMHg1YzAwIEVudHJ5
IDMyIChzaXplIDE2IGJ1bmRsZXMpIEZsb2F0aW5nIFBvaW50IEZBVUxUICg2NSkKK0VOVFJZKGt2
bV9mbG9hdGluZ19wb2ludF9mYXVsdCkKKyAgICBLVk1fUkVGTEVDVCgzMikKK0VORChrdm1fZmxv
YXRpbmdfcG9pbnRfZmF1bHQpCisKKyAgICAub3JnIGt2bV9pYTY0X2l2dCsweDVkMDAKKy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLworLy8gMHg1ZDAwIEVudHJ5IDMzIChzaXplIDE2IGJ1bmRsZXMpIEZsb2F0aW5nIFBv
aW50IFRyYXAgKDY2KQorRU5UUlkoa3ZtX2Zsb2F0aW5nX3BvaW50X3RyYXApCisgICAgS1ZNX1JF
RkxFQ1QoMzMpCitFTkQoa3ZtX2Zsb2F0aW5nX3BvaW50X3RyYXApCisKKyAgICAub3JnIGt2bV9p
YTY0X2l2dCsweDVlMDAKKy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8KKy8vIDB4NWUwMCBFbnRyeSAzNCAoc2l6ZSAx
NiBidW5kbGVzKSBMb3dlciBQcml2aWxlZ2UgVHJhbnNmZXIgVHJhcCAoNjYpCitFTlRSWShrdm1f
bG93ZXJfcHJpdmlsZWdlX3RyYXApCisgICAgS1ZNX1JFRkxFQ1QoMzQpCitFTkQoa3ZtX2xvd2Vy
X3ByaXZpbGVnZV90cmFwKQorCisgICAgLm9yZyBrdm1faWE2NF9pdnQrMHg1ZjAwCisvLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vCisvLyAweDVmMDAgRW50cnkgMzUgKHNpemUgMTYgYnVuZGxlcykgVGFrZW4gQnJhbmNo
IFRyYXAgKDY4KQorRU5UUlkoa3ZtX3Rha2VuX2JyYW5jaF90cmFwKQorICAgIEtWTV9SRUZMRUNU
KDM1KQorRU5EKGt2bV90YWtlbl9icmFuY2hfdHJhcCkKKworICAgIC5vcmcga3ZtX2lhNjRfaXZ0
KzB4NjAwMAorLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8KKy8vIDB4NjAwMCBFbnRyeSAzNiAoc2l6ZSAxNiBidW5kbGVz
KSBTaW5nbGUgU3RlcCBUcmFwICg2OSkKK0VOVFJZKGt2bV9zaW5nbGVfc3RlcF90cmFwKQorICAg
IEtWTV9SRUZMRUNUKDM2KQorRU5EKGt2bV9zaW5nbGVfc3RlcF90cmFwKQorICAgIC5nbG9iYWwg
a3ZtX3ZpcnR1YWxpemF0aW9uX2ZhdWx0X2JhY2sKKyAgICAub3JnIGt2bV9pYTY0X2l2dCsweDYx
MDAKKy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLworLy8gMHg2MTAwIEVudHJ5IDM3IChzaXplIDE2IGJ1bmRsZXMpIFZp
cnR1YWxpemF0aW9uIEZhdWx0CitFTlRSWShrdm1fdmlydHVhbGl6YXRpb25fZmF1bHQpCisgICAg
bW92IHIzMT1wcgorICAgIGFkZHMgcjE2ID0gVk1NX1ZDUFVfU0FWRURfR1BfT0ZGU0VULHIyMQor
ICAgIDs7CisgICAgc3Q4IFtyMTZdID0gcjEKKyAgICBhZGRzIHIxNyA9IFZNTV9WQ1BVX0dQX09G
RlNFVCwgcjIxCisgICAgOzsKKyAgICBsZDggcjEgPSBbcjE3XQorICAgIGNtcC5lcSBwNixwMD1F
VkVOVF9NT1ZfRlJPTV9BUixyMjQKKyAgICBjbXAuZXEgcDcscDA9RVZFTlRfTU9WX0ZST01fUlIs
cjI0CisgICAgY21wLmVxIHA4LHAwPUVWRU5UX01PVl9UT19SUixyMjQKKyAgICBjbXAuZXEgcDks
cDA9RVZFTlRfUlNNLHIyNAorICAgIGNtcC5lcSBwMTAscDA9RVZFTlRfU1NNLHIyNAorICAgIGNt
cC5lcSBwMTEscDA9RVZFTlRfTU9WX1RPX1BTUixyMjQKKyAgICBjbXAuZXEgcDEyLHAwPUVWRU5U
X1RIQVNILHIyNAorICAgIChwNikgYnIuZHB0ay5tYW55IGt2bV9hc21fbW92X2Zyb21fYXIKKyAg
ICAocDcpIGJyLmRwdGsubWFueSBrdm1fYXNtX21vdl9mcm9tX3JyCisgICAgKHA4KSBici5kcHRr
Lm1hbnkga3ZtX2FzbV9tb3ZfdG9fcnIKKyAgICAocDkpIGJyLmRwdGsubWFueSBrdm1fYXNtX3Jz
bQorICAgIChwMTApIGJyLmRwdGsubWFueSBrdm1fYXNtX3NzbQorICAgIChwMTEpIGJyLmRwdGsu
bWFueSBrdm1fYXNtX21vdl90b19wc3IKKyAgICAocDEyKSBici5kcHRrLm1hbnkga3ZtX2FzbV90
aGFzaAorICAgIDs7Citrdm1fdmlydHVhbGl6YXRpb25fZmF1bHRfYmFjazoKKyAgICBhZGRzIHIx
NiA9IFZNTV9WQ1BVX1NBVkVEX0dQX09GRlNFVCxyMjEKKyAgICA7OworICAgIGxkOCByMSA9IFty
MTZdCisgICAgOzsKKyAgICBtb3YgcjE5PTM3CisgICAgYWRkcyByMTYgPSBWTU1fVkNQVV9DQVVT
RV9PRkZTRVQscjIxCisgICAgYWRkcyByMTcgPSBWTU1fVkNQVV9PUENPREVfT0ZGU0VULHIyMQor
ICAgIDs7CisgICAgc3Q4IFtyMTZdID0gcjI0CisgICAgc3Q4IFtyMTddID0gcjI1CisgICAgOzsK
KyAgICBjbXAubmUgcDYscDA9RVZFTlRfUkZJLCByMjQKKyAgICAocDYpIGJyLnNwdGsga3ZtX2Rp
c3BhdGNoX3ZpcnR1YWxpemF0aW9uX2ZhdWx0CisgICAgOzsKKyAgICBhZGRzIHIxOD1WTU1fVlBE
X0JBU0VfT0ZGU0VULHIyMQorICAgIDs7CisgICAgbGQ4IHIxOD1bcjE4XQorICAgIDs7CisgICAg
YWRkcyByMTg9Vk1NX1ZQRF9WSUZTX09GRlNFVCxyMTgKKyAgICA7OworICAgIGxkOCByMTg9W3Ix
OF0KKyAgICA7OworICAgIHRiaXQueiBwNixwMD1yMTgsNjMKKyAgICAocDYpIGJyLnNwdGsga3Zt
X2Rpc3BhdGNoX3ZpcnR1YWxpemF0aW9uX2ZhdWx0CisgICAgOzsKKyAgICAvL2lmIHZpZnMudj0x
IGRlc2VydCBjdXJyZW50IHJlZ2lzdGVyIGZyYW1lCisgICAgYWxsb2MgcjE4PWFyLnBmcywwLDAs
MCwwCisgICAgYnIuc3B0ayBrdm1fZGlzcGF0Y2hfdmlydHVhbGl6YXRpb25fZmF1bHQKK0VORChr
dm1fdmlydHVhbGl6YXRpb25fZmF1bHQpCisKKyAgICAub3JnIGt2bV9pYTY0X2l2dCsweDYyMDAK
Ky8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vCisvLyAweDYyMDAgRW50cnkgMzggKHNpemUgMTYgYnVuZGxlcykgUmVzZXJ2ZWQKKyAg
ICBLVk1fRkFVTFQoMzgpCisKKyAgICAub3JnIGt2bV9pYTY0X2l2dCsweDYzMDAKKy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
CisvLyAweDYzMDAgRW50cnkgMzkgKHNpemUgMTYgYnVuZGxlcykgUmVzZXJ2ZWQKKyAgICBLVk1f
RkFVTFQoMzkpCisKKyAgICAub3JnIGt2bV9pYTY0X2l2dCsweDY0MDAKKy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vCisvLyAw
eDY0MDAgRW50cnkgNDAgKHNpemUgMTYgYnVuZGxlcykgUmVzZXJ2ZWQKKyAgICBLVk1fRkFVTFQo
NDApCisKKyAgICAub3JnIGt2bV9pYTY0X2l2dCsweDY1MDAKKy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLworLy8gMHg2NTAw
IEVudHJ5IDQxIChzaXplIDE2IGJ1bmRsZXMpIFJlc2VydmVkCisgICAgS1ZNX0ZBVUxUKDQxKQor
CisgICAgLm9yZyBrdm1faWE2NF9pdnQrMHg2NjAwCisvLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8KKy8vIDB4NjYwMCBFbnRy
eSA0MiAoc2l6ZSAxNiBidW5kbGVzKSBSZXNlcnZlZAorICAgIEtWTV9GQVVMVCg0MikKKworICAg
IC5vcmcga3ZtX2lhNjRfaXZ0KzB4NjcwMAorLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vCisvLyAweDY3MDAgRW50cnkgNDMg
KHNpemUgMTYgYnVuZGxlcykgUmVzZXJ2ZWQKKyAgICBLVk1fRkFVTFQoNDMpCisKKyAgICAub3Jn
IGt2bV9pYTY0X2l2dCsweDY4MDAKKy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLworLy8gMHg2ODAwIEVudHJ5IDQ0IChzaXpl
IDE2IGJ1bmRsZXMpIFJlc2VydmVkCisgICAgS1ZNX0ZBVUxUKDQ0KQorCisgICAgLm9yZyBrdm1f
aWE2NF9pdnQrMHg2OTAwCisvLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vCisvLyAweDY5MDAgRW50cnkgNDUgKHNpemUgMTYg
YnVuZGxlcykgSUEtMzIgRXhlY2VwdGlvbgorLy8oMTcsMTgsMjksNDEsNDIsNDMsNDQsNTgsNjAs
NjEsNjIsNzIsNzMsNzUsNzYsNzcpCitFTlRSWShrdm1faWEzMl9leGNlcHRpb24pCisgICAgS1ZN
X0ZBVUxUKDQ1KQorRU5EKGt2bV9pYTMyX2V4Y2VwdGlvbikKKworICAgIC5vcmcga3ZtX2lhNjRf
aXZ0KzB4NmEwMAorLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8KKy8vIDB4NmEwMCBFbnRyeSA0NiAoc2l6ZSAxNiBidW5k
bGVzKSBJQS0zMiBJbnRlcmNlcHQgICgzMCwzMSw1OSw3MCw3MSkKK0VOVFJZKGt2bV9pYTMyX2lu
dGVyY2VwdCkKKyAgICBLVk1fRkFVTFQoNDcpCitFTkQoa3ZtX2lhMzJfaW50ZXJjZXB0KQorCisg
ICAgLm9yZyBrdm1faWE2NF9pdnQrMHg2YzAwCisvLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8KKy8vIDB4NmMwMCBFbnRy
eSA0OCAoc2l6ZSAxNiBidW5kbGVzKSBSZXNlcnZlZAorICAgIEtWTV9GQVVMVCg0OCkKKworICAg
IC5vcmcga3ZtX2lhNjRfaXZ0KzB4NmQwMAorLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLworLy8gMHg2ZDAwIEVudHJ5
IDQ5IChzaXplIDE2IGJ1bmRsZXMpIFJlc2VydmVkCisgICAgS1ZNX0ZBVUxUKDQ5KQorCisgICAg
Lm9yZyBrdm1faWE2NF9pdnQrMHg2ZTAwCisvLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vCisvLyAweDZlMDAgRW50cnkg
NTAgKHNpemUgMTYgYnVuZGxlcykgUmVzZXJ2ZWQKKyAgICBLVk1fRkFVTFQoNTApCisKKyAgICAu
b3JnIGt2bV9pYTY0X2l2dCsweDZmMDAKKy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLworLy8gMHg2ZjAwIEVudHJ5IDUx
IChzaXplIDE2IGJ1bmRsZXMpIFJlc2VydmVkCisgICAgS1ZNX0ZBVUxUKDUyKQorCisgICAgLm9y
ZyBrdm1faWE2NF9pdnQrMHg3MTAwCisvLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLworLy8gMHg3MTAwIEVudHJ5IDUzIChz
aXplIDE2IGJ1bmRsZXMpIFJlc2VydmVkCisgICAgS1ZNX0ZBVUxUKDUzKQorCisgICAgLm9yZyBr
dm1faWE2NF9pdnQrMHg3MjAwCisvLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8KKy8vIDB4NzIwMCBFbnRyeSA1NCAoc2l6
ZSAxNiBidW5kbGVzKSBSZXNlcnZlZAorICAgIEtWTV9GQVVMVCg1NCkKKworICAgIC5vcmcga3Zt
X2lhNjRfaXZ0KzB4NzMwMAorLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8KKy8vIDB4NzMwMCBFbnRyeSA1NSAoc2l6ZSAx
NiBidW5kbGVzKSBSZXNlcnZlZAorICAgIEtWTV9GQVVMVCg1NSkKKworICAgIC5vcmcga3ZtX2lh
NjRfaXZ0KzB4NzQwMAorLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8KKy8vIDB4NzQwMCBFbnRyeSA1NiAoc2l6ZSAxNiBi
dW5kbGVzKSBSZXNlcnZlZAorICAgIEtWTV9GQVVMVCg1NikKKworICAgIC5vcmcga3ZtX2lhNjRf
aXZ0KzB4NzUwMAorLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vCisvLyAweDc1MDAgRW50cnkgNTcgKHNpemUgMTYgYnVu
ZGxlcykgUmVzZXJ2ZWQKKyAgICBLVk1fRkFVTFQoNTcpCisKKyAgICAub3JnIGt2bV9pYTY0X2l2
dCsweDc2MDAKKy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLworLy8gMHg3NjAwIEVudHJ5IDU4IChzaXplIDE2IGJ1bmRs
ZXMpIFJlc2VydmVkCisgICAgS1ZNX0ZBVUxUKDU4KQorCisgICAgLm9yZyBrdm1faWE2NF9pdnQr
MHg3NzAwCisvLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLworLy8gMHg3NzAwIEVudHJ5IDU5IChzaXplIDE2IGJ1bmRsZXMp
IFJlc2VydmVkCisgICAgS1ZNX0ZBVUxUKDU5KQorCisgICAgLm9yZyBrdm1faWE2NF9pdnQrMHg3
ODAwCisvLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLworLy8gMHg3ODAwIEVudHJ5IDYwIChzaXplIDE2IGJ1bmRsZXMpIFJl
c2VydmVkCisgICAgS1ZNX0ZBVUxUKDYwKQorCisgICAgLm9yZyBrdm1faWE2NF9pdnQrMHg3OTAw
CisvLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8KKy8vIDB4NzkwMCBFbnRyeSA2MSAoc2l6ZSAxNiBidW5kbGVzKSBSZXNl
cnZlZAorICAgIEtWTV9GQVVMVCg2MSkKKworICAgIC5vcmcga3ZtX2lhNjRfaXZ0KzB4N2EwMAor
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vCisvLyAweDdhMDAgRW50cnkgNjIgKHNpemUgMTYgYnVuZGxlcykgUmVzZXJ2
ZWQKKyAgICBLVk1fRkFVTFQoNjIpCisKKyAgICAub3JnIGt2bV9pYTY0X2l2dCsweDdiMDAKKy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLworLy8gMHg3YjAwIEVudHJ5IDYzIChzaXplIDE2IGJ1bmRsZXMpIFJlc2VydmVk
CisgICAgS1ZNX0ZBVUxUKDYzKQorCisgICAgLm9yZyBrdm1faWE2NF9pdnQrMHg3YzAwCisvLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLworLy8gMHg3YzAwIEVudHJ5IDY0IChzaXplIDE2IGJ1bmRsZXMpIFJlc2VydmVkCisg
ICAgS1ZNX0ZBVUxUKDY0KQorCisgICAgLm9yZyBrdm1faWE2NF9pdnQrMHg3ZDAwCisvLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8KKy8vIDB4N2QwMCBFbnRyeSA2NSAoc2l6ZSAxNiBidW5kbGVzKSBSZXNlcnZlZAorICAg
IEtWTV9GQVVMVCg2NSkKKworICAgIC5vcmcga3ZtX2lhNjRfaXZ0KzB4N2UwMAorLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vCisvLyAweDdlMDAgRW50cnkgNjYgKHNpemUgMTYgYnVuZGxlcykgUmVzZXJ2ZWQKKyAgICBL
Vk1fRkFVTFQoNjYpCisKKyAgICAub3JnIGt2bV9pYTY0X2l2dCsweDdmMDAKKy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
CisvLyAweDdmMDAgRW50cnkgNjcgKHNpemUgMTYgYnVuZGxlcykgUmVzZXJ2ZWQKKyAgICBLVk1f
RkFVTFQoNjcpCisKKyAgICAub3JnIGt2bV9pYTY0X2l2dCsweDgwMDAKKy8vIFRoZXJlIGlzIG5v
IHBhcnRpY3VsYXIgcmVhc29uIGZvciB0aGlzIGNvZGUgdG8gYmUgaGVyZSwgb3RoZXIgdGhhbiB0
aGF0CisvLyB0aGVyZSBoYXBwZW5zIHRvIGJlIHNwYWNlIGhlcmUgdGhhdCB3b3VsZCBnbyB1bnVz
ZWQgb3RoZXJ3aXNlLiAgSWYgdGhpcworLy8gZmF1bHQgZXZlciBnZXRzICJ1bnJlc2VydmVkIiwg
c2ltcGx5IG1vdmVkIHRoZSBmb2xsb3dpbmcgY29kZSB0byBhIG1vcmUKKy8vIHN1aXRhYmxlIHNw
b3QuLi4KKworCitFTlRSWShrdm1fZHRsYl9taXNzX2Rpc3BhdGNoKQorICAgIG1vdiByMTkgPSAy
CisgICAgS1ZNX1NBVkVfTUlOX1dJVEhfQ09WRVJfUjE5CisgICAgYWxsb2MgcjE0PWFyLnBmcyww
LDAsMywwCisgICAgbW92IG91dDA9Y3IuaWZhCisgICAgbW92IG91dDE9cjE1CisgICAgYWRkcyBy
Mz04LHIyICAgICAgICAgICAgICAgIC8vIHNldCB1cCBzZWNvbmQgYmFzZSBwb2ludGVyCisgICAg
OzsKKyAgICBzc20gcHNyLmljCisgICAgOzsKKyAgICBzcmx6LmkgICAgICAgICAgICAgICAgICAv
LyBndWFyYW50ZWUgdGhhdCBpbnRlcnJ1cHRpb24gY29sbGVjdGlvbiBpcyBvbgorICAgIDs7Cisg
ICAgLy8ocDE1KSBzc20gcHNyLmkgICAgICAgICAgICAgICAvLyByZXN0b3JlIHBzci5pCisgICAg
YWRkbCByMTQ9QGdwcmVsKGlhNjRfbGVhdmVfaHlwZXJ2aXNvcl9wcmVwYXJlKSxncAorICAgIDs7
CisgICAgS1ZNX1NBVkVfUkVTVAorICAgIEtWTV9TQVZFX0VYVFJBCisgICAgbW92IHJwPXIxNAor
ICAgIDs7CisgICAgYWRkcyBvdXQyPTE2LHIxMgorICAgIGJyLmNhbGwuc3B0ay5tYW55IGI2PWt2
bV9wYWdlX2ZhdWx0CitFTkQoa3ZtX2R0bGJfbWlzc19kaXNwYXRjaCkKKworRU5UUlkoa3ZtX2l0
bGJfbWlzc19kaXNwYXRjaCkKKworICAgIEtWTV9TQVZFX01JTl9XSVRIX0NPVkVSX1IxOQorICAg
IGFsbG9jIHIxND1hci5wZnMsMCwwLDMsMAorICAgIG1vdiBvdXQwPWNyLmlmYQorICAgIG1vdiBv
dXQxPXIxNQorICAgIGFkZHMgcjM9OCxyMiAgICAgICAgICAgICAgICAvLyBzZXQgdXAgc2Vjb25k
IGJhc2UgcG9pbnRlcgorICAgIDs7CisgICAgc3NtIHBzci5pYworICAgIDs7CisgICAgc3Jsei5p
ICAgICAgICAgICAgICAgICAgLy8gZ3VhcmFudGVlIHRoYXQgaW50ZXJydXB0aW9uIGNvbGxlY3Rp
b24gaXMgb24KKyAgICA7OworICAgIC8vKHAxNSkgc3NtIHBzci5pICAgICAgICAgICAgICAgLy8g
cmVzdG9yZSBwc3IuaQorICAgIGFkZGwgcjE0PUBncHJlbChpYTY0X2xlYXZlX2h5cGVydmlzb3Ip
LGdwCisgICAgOzsKKyAgICBLVk1fU0FWRV9SRVNUCisgICAgbW92IHJwPXIxNAorICAgIDs7Cisg
ICAgYWRkcyBvdXQyPTE2LHIxMgorICAgIGJyLmNhbGwuc3B0ay5tYW55IGI2PWt2bV9wYWdlX2Zh
dWx0CitFTkQoa3ZtX2l0bGJfbWlzc19kaXNwYXRjaCkKKworRU5UUlkoa3ZtX2Rpc3BhdGNoX3Jl
ZmxlY3Rpb24pCisgICAgLyoKKyAgICAgKiBJbnB1dDoKKyAgICAgKiAgcHNyLmljOiBvZmYKKyAg
ICAgKiAgcjE5OiAgICBpbnRyIHR5cGUgKG9mZnNldCBpbnRvIGl2dCwgc2VlIGlhNjRfaW50Lmgp
CisgICAgICogIHIzMTogICAgY29udGFpbnMgc2F2ZWQgcHJlZGljYXRlcyAocHIpCisgICAgICov
CisgICAgS1ZNX1NBVkVfTUlOX1dJVEhfQ09WRVJfUjE5CisgICAgYWxsb2MgcjE0PWFyLnBmcyww
LDAsNSwwCisgICAgbW92IG91dDA9Y3IuaWZhCisgICAgbW92IG91dDE9Y3IuaXNyCisgICAgbW92
IG91dDI9Y3IuaWltCisgICAgbW92IG91dDM9cjE1CisgICAgYWRkcyByMz04LHIyICAgICAgICAg
ICAgICAgIC8vIHNldCB1cCBzZWNvbmQgYmFzZSBwb2ludGVyCisgICAgOzsKKyAgICBzc20gcHNy
LmljCisgICAgOzsKKyAgICBzcmx6LmkgICAgICAgICAgICAgICAgICAvLyBndWFyYW50ZWUgdGhh
dCBpbnRlcnJ1cHRpb24gY29sbGVjdGlvbiBpcyBvbgorICAgIDs7CisgICAgLy8ocDE1KSBzc20g
cHNyLmkgICAgICAgICAgICAgICAvLyByZXN0b3JlIHBzci5pCisgICAgYWRkbCByMTQ9QGdwcmVs
KGlhNjRfbGVhdmVfaHlwZXJ2aXNvciksZ3AKKyAgICA7OworICAgIEtWTV9TQVZFX1JFU1QKKyAg
ICBtb3YgcnA9cjE0CisgICAgOzsKKyAgICBhZGRzIG91dDQ9MTYscjEyCisgICAgYnIuY2FsbC5z
cHRrLm1hbnkgYjY9cmVmbGVjdF9pbnRlcnJ1cHRpb24KK0VORChrdm1fZGlzcGF0Y2hfcmVmbGVj
dGlvbikKKworRU5UUlkoa3ZtX2Rpc3BhdGNoX3ZpcnR1YWxpemF0aW9uX2ZhdWx0KQorICAgIGFk
ZHMgcjE2ID0gVk1NX1ZDUFVfQ0FVU0VfT0ZGU0VULHIyMQorICAgIGFkZHMgcjE3ID0gVk1NX1ZD
UFVfT1BDT0RFX09GRlNFVCxyMjEKKyAgICA7OworICAgIHN0OCBbcjE2XSA9IHIyNAorICAgIHN0
OCBbcjE3XSA9IHIyNQorICAgIDs7CisgICAgS1ZNX1NBVkVfTUlOX1dJVEhfQ09WRVJfUjE5Cisg
ICAgOzsKKyAgICBhbGxvYyByMTQ9YXIucGZzLDAsMCwyLDAgLy8gbm93IGl0J3Mgc2FmZSAobXVz
dCBiZSBmaXJzdCBpbiBpbnNuIGdyb3VwISkKKyAgICBtb3Ygb3V0MD1yMTMgICAgICAgIC8vdmNw
dQorICAgIGFkZHMgcjM9OCxyMiAgICAgICAgICAgICAgICAvLyBzZXQgdXAgc2Vjb25kIGJhc2Ug
cG9pbnRlcgorICAgIDs7CisgICAgc3NtIHBzci5pYworICAgIDs7CisgICAgc3Jsei5pICAgICAg
ICAgICAgICAgICAgLy8gZ3VhcmFudGVlIHRoYXQgaW50ZXJydXB0aW9uIGNvbGxlY3Rpb24gaXMg
b24KKyAgICA7OworICAgIC8vKHAxNSkgc3NtIHBzci5pICAgICAgICAgICAgICAgLy8gcmVzdG9y
ZSBwc3IuaQorICAgIGFkZGwgcjE0PUBncHJlbChpYTY0X2xlYXZlX2h5cGVydmlzb3JfcHJlcGFy
ZSksZ3AKKyAgICA7OworICAgIEtWTV9TQVZFX1JFU1QKKyAgICBLVk1fU0FWRV9FWFRSQQorICAg
IG1vdiBycD1yMTQKKyAgICA7OworICAgIGFkZHMgb3V0MT0xNixzcCAgICAgICAgIC8vcmVncwor
ICAgIGJyLmNhbGwuc3B0ay5tYW55IGI2PWt2bV9lbXVsYXRlCitFTkQoa3ZtX2Rpc3BhdGNoX3Zp
cnR1YWxpemF0aW9uX2ZhdWx0KQorCisKK0VOVFJZKGt2bV9kaXNwYXRjaF9pbnRlcnJ1cHQpCisg
ICAgS1ZNX1NBVkVfTUlOX1dJVEhfQ09WRVJfUjE5CS8vIHVzZXMgcjMxOyBkZWZpbmVzIHIyIGFu
ZCByMworICAgIDs7CisgICAgYWxsb2MgcjE0PWFyLnBmcywwLDAsMSwwIC8vIG11c3QgYmUgZmly
c3QgaW4gYW4gaW5zbiBncm91cAorICAgIC8vbW92IG91dDA9Y3IuaXZyCQkvLyBwYXNzIGNyLml2
ciBhcyBmaXJzdCBhcmcKKyAgICBhZGRzIHIzPTgscjIJCS8vIHNldCB1cCBzZWNvbmQgYmFzZSBw
b2ludGVyIGZvciBTQVZFX1JFU1QKKyAgICA7OworICAgIHNzbSBwc3IuaWMKKyAgICA7OworICAg
IHNybHouaQorICAgIDs7CisgICAgLy8ocDE1KSBzc20gcHNyLmkKKyAgICBhZGRsIHIxND1AZ3By
ZWwoaWE2NF9sZWF2ZV9oeXBlcnZpc29yKSxncAorICAgIDs7CisgICAgS1ZNX1NBVkVfUkVTVAor
ICAgIG1vdiBycD1yMTQKKyAgICA7OworICAgIG1vdiBvdXQwPXIxMwkJLy8gcGFzcyBwb2ludGVy
IHRvIHB0X3JlZ3MgYXMgc2Vjb25kIGFyZworICAgIGJyLmNhbGwuc3B0ay5tYW55IGI2PWt2bV9p
YTY0X2hhbmRsZV9pcnEKK0VORChrdm1fZGlzcGF0Y2hfaW50ZXJydXB0KQorCisKKworCitHTE9C
QUxfRU5UUlkoaWE2NF9sZWF2ZV9uZXN0ZWQpCisJcnNtIHBzci5pCisJOzsKKwlhZGRzIHIyMT1Q
VChQUikrMTYscjEyCisJOzsKKwlsZmV0Y2ggW3IyMV0sUFQoQ1JfSVBTUiktUFQoUFIpCisJYWRk
cyByMj1QVChCNikrMTYscjEyCisJYWRkcyByMz1QVChSMTYpKzE2LHIxMgorCTs7CisJbGZldGNo
IFtyMjFdCisJbGQ4IHIyOD1bcjJdLDgJCS8vIGxvYWQgYjYKKwlhZGRzIHIyOT1QVChSMjQpKzE2
LHIxMgorCisJbGQ4LmZpbGwgcjE2PVtyM10KKwlhZGRzIHIzPVBUKEFSX0NTRCktUFQoUjE2KSxy
MworCWFkZHMgcjMwPVBUKEFSX0NDVikrMTYscjEyCisJOzsKKwlsZDguZmlsbCByMjQ9W3IyOV0K
KwlsZDggcjE1PVtyMzBdCQkvLyBsb2FkIGFyLmNjdgorCTs7CisJbGQ4IHIyOT1bcjJdLDE2CQkv
LyBsb2FkIGI3CisJbGQ4IHIzMD1bcjNdLDE2CQkvLyBsb2FkIGFyLmNzZAorCTs7CisJbGQ4IHIz
MT1bcjJdLDE2CQkvLyBsb2FkIGFyLnNzZAorCWxkOC5maWxsIHI4PVtyM10sMTYKKwk7OworCWxk
OC5maWxsIHI5PVtyMl0sMTYKKwlsZDguZmlsbCByMTA9W3IzXSxQVChSMTcpLVBUKFIxMCkKKwk7
OworCWxkOC5maWxsIHIxMT1bcjJdLFBUKFIxOCktUFQoUjExKQorCWxkOC5maWxsIHIxNz1bcjNd
LDE2CisJOzsKKwlsZDguZmlsbCByMTg9W3IyXSwxNgorCWxkOC5maWxsIHIxOT1bcjNdLDE2CisJ
OzsKKwlsZDguZmlsbCByMjA9W3IyXSwxNgorCWxkOC5maWxsIHIyMT1bcjNdLDE2CisJbW92IGFy
LmNzZD1yMzAKKwltb3YgYXIuc3NkPXIzMQorCTs7CisJcnNtIHBzci5pIHwgcHNyLmljCisJLy8g
aW5pdGlhdGUgdHVybmluZyBvZmYgb2YgaW50ZXJydXB0IGFuZCBpbnRlcnJ1cHRpb24gY29sbGVj
dGlvbgorCWludmFsYQkJCS8vIGludmFsaWRhdGUgQUxBVAorCTs7CisJc3Jsei5pCisJOzsKKwls
ZDguZmlsbCByMjI9W3IyXSwyNAorCWxkOC5maWxsIHIyMz1bcjNdLDI0CisJbW92IGI2PXIyOAor
CTs7CisJbGQ4LmZpbGwgcjI1PVtyMl0sMTYKKwlsZDguZmlsbCByMjY9W3IzXSwxNgorCW1vdiBi
Nz1yMjkKKwk7OworCWxkOC5maWxsIHIyNz1bcjJdLDE2CisJbGQ4LmZpbGwgcjI4PVtyM10sMTYK
Kwk7OworCWxkOC5maWxsIHIyOT1bcjJdLDE2CisJbGQ4LmZpbGwgcjMwPVtyM10sMjQKKwk7Owor
CWxkOC5maWxsIHIzMT1bcjJdLFBUKEY5KS1QVChSMzEpCisJYWRkcyByMz1QVChGMTApLVBUKEY2
KSxyMworCTs7CisJbGRmLmZpbGwgZjk9W3IyXSxQVChGNiktUFQoRjkpCisJbGRmLmZpbGwgZjEw
PVtyM10sUFQoRjgpLVBUKEYxMCkKKwk7OworCWxkZi5maWxsIGY2PVtyMl0sUFQoRjcpLVBUKEY2
KQorCTs7CisJbGRmLmZpbGwgZjc9W3IyXSxQVChGMTEpLVBUKEY3KQorCWxkZi5maWxsIGY4PVty
M10sMzIKKwk7OworCXNybHouaQkJCS8vIGVuc3VyZSBpbnRlcnJ1cHRpb24gY29sbGVjdGlvbiBp
cyBvZmYKKwltb3YgYXIuY2N2PXIxNQorCTs7CisJYnN3LjAJLy8gc3dpdGNoIGJhY2sgdG8gYmFu
ayAwIChubyBzdG9wIGJpdCByZXF1aXJlZCBiZWZvcmVoYW5kLi4uKQorCTs7CisJbGRmLmZpbGwg
ZjExPVtyMl0KKy8vCW1vdiByMTg9cjEzCisvLyAgICBtb3YgcjIxPXIxMworCWFkZHMgcjE2PVBU
KENSX0lQU1IpKzE2LHIxMgorCWFkZHMgcjE3PVBUKENSX0lJUCkrMTYscjEyCisJOzsKKwlsZDgg
cjI5PVtyMTZdLDE2CS8vIGxvYWQgY3IuaXBzcgorCWxkOCByMjg9W3IxN10sMTYJLy8gbG9hZCBj
ci5paXAKKwk7OworCWxkOCByMzA9W3IxNl0sMTYJLy8gbG9hZCBjci5pZnMKKwlsZDggcjI1PVty
MTddLDE2CS8vIGxvYWQgYXIudW5hdAorCTs7CisJbGQ4IHIyNj1bcjE2XSwxNgkvLyBsb2FkIGFy
LnBmcworCWxkOCByMjc9W3IxN10sMTYJLy8gbG9hZCBhci5yc2MKKwljbXAuZXEgcDkscDA9cjAs
cjAKKwkvLyBzZXQgcDkgdG8gaW5kaWNhdGUgdGhhdCB3ZSBzaG91bGQgcmVzdG9yZSBjci5pZnMK
Kwk7OworCWxkOCByMjQ9W3IxNl0sMTYJLy8gbG9hZCBhci5ybmF0IChtYXkgYmUgZ2FyYmFnZSkK
KwlsZDggcjIzPVtyMTddLDE2Ly8gbG9hZCBhci5ic3BzdG9yZSAobWF5IGJlIGdhcmJhZ2UpCisJ
OzsKKwlsZDggcjMxPVtyMTZdLDE2CS8vIGxvYWQgcHJlZGljYXRlcworCWxkOCByMjI9W3IxN10s
MTYJLy8gbG9hZCBiMAorCTs7CisJbGQ4IHIxOT1bcjE2XSwxNgkvLyBsb2FkIGFyLnJzYyB2YWx1
ZSBmb3IgImxvYWRycyIKKwlsZDguZmlsbCByMT1bcjE3XSwxNgkvLyBsb2FkIHIxCisJOzsKKwls
ZDguZmlsbCByMTI9W3IxNl0sMTYKKwlsZDguZmlsbCByMTM9W3IxN10sMTYKKwk7OworCWxkOCBy
MjA9W3IxNl0sMTYJLy8gYXIuZnBzcgorCWxkOC5maWxsIHIxNT1bcjE3XSwxNgorCTs7CisJbGQ4
LmZpbGwgcjE0PVtyMTZdLDE2CisJbGQ4LmZpbGwgcjI9W3IxN10KKwk7OworCWxkOC5maWxsIHIz
PVtyMTZdCisJOzsKKwltb3YgcjE2PWFyLmJzcAkJLy8gZ2V0IGV4aXN0aW5nIGJhY2tpbmcgc3Rv
cmUgcG9pbnRlcgorCTs7CisJbW92IGIwPXIyMgorCW1vdiBhci5wZnM9cjI2CisJbW92IGNyLmlm
cz1yMzAKKwltb3YgY3IuaXBzcj1yMjkKKwltb3YgYXIuZnBzcj1yMjAKKwltb3YgY3IuaWlwPXIy
OAorCTs7CisJbW92IGFyLnJzYz1yMjcKKwltb3YgYXIudW5hdD1yMjUKKwltb3YgcHI9cjMxLC0x
CisJcmZpCitFTkQoaWE2NF9sZWF2ZV9uZXN0ZWQpCisKKworCitHTE9CQUxfRU5UUlkoaWE2NF9s
ZWF2ZV9oeXBlcnZpc29yX3ByZXBhcmUpCisgICAgLyoKKyAgICAgKiB3b3JrLm5lZWRfcmVzY2hl
ZCBldGMuIG11c3RuJ3QgZ2V0IGNoYW5nZWQKKyAgICAgKmJ5IHRoaXMgQ1BVIGJlZm9yZSBpdCBy
ZXR1cm5zIHRvCisgICAgOzsKKyAgICAgKiB1c2VyLSBvciBmc3lzLW1vZGUsIGhlbmNlIHdlIGRp
c2FibGUgaW50ZXJydXB0cyBlYXJseSBvbjoKKyAgICAgKi8KKyAgICBhZGRzIHIyID0gUFQoUjQp
KzE2LHIxMgorICAgIGFkZHMgcjMgPSBQVChSNSkrMTYscjEyCisgICAgYWRkcyByOCA9IFBUKEVN
TF9VTkFUKSsxNixyMTIKKyAgICA7OworICAgIGxkOCByOCA9IFtyOF0KKyAgICA7OworICAgIG1v
diBhci51bmF0PXI4CisgICAgOzsKKyAgICBsZDguZmlsbCByND1bcjJdLDE2ICAgIC8vbG9hZCBy
NAorICAgIGxkOC5maWxsIHI1PVtyM10sMTYgICAgLy9sb2FkIHI1CisgICAgOzsKKyAgICBsZDgu
ZmlsbCByNj1bcjJdICAgIC8vbG9hZCByNgorICAgIGxkOC5maWxsIHI3PVtyM10gICAgLy9sb2Fk
IHI3CisgICAgOzsKK0VORChpYTY0X2xlYXZlX2h5cGVydmlzb3JfcHJlcGFyZSkKKy8vZmFsbCB0
aHJvdWdoCitHTE9CQUxfRU5UUlkoaWE2NF9sZWF2ZV9oeXBlcnZpc29yKQorICAgIHJzbSBwc3Iu
aQorICAgIDs7CisgICAgYnIuY2FsbC5zcHRrLm1hbnkgYjA9bGVhdmVfaHlwZXJ2aXNvcl90YWls
CisgICAgOzsKKyAgICBhZGRzIHIyMD1QVChQUikrMTYscjEyCisgICAgYWRkcyByOD1QVChFTUxf
VU5BVCkrMTYscjEyCisgICAgOzsKKyAgICBsZDggcjg9W3I4XQorICAgIDs7CisgICAgbW92IGFy
LnVuYXQ9cjgKKyAgICA7OworICAgIGxmZXRjaCBbcjIwXSxQVChDUl9JUFNSKS1QVChQUikKKyAg
ICBhZGRzIHIyID0gUFQoQjYpKzE2LHIxMgorICAgIGFkZHMgcjMgPSBQVChCNykrMTYscjEyCisg
ICAgOzsKKyAgICBsZmV0Y2ggW3IyMF0KKyAgICA7OworICAgIGxkOCByMjQ9W3IyXSwxNiAgICAg
ICAgLyogQjYgKi8KKyAgICBsZDggcjI1PVtyM10sMTYgICAgICAgIC8qIEI3ICovCisgICAgOzsK
KyAgICBsZDggcjI2PVtyMl0sMTYgICAgICAgIC8qIGFyX2NzZCAqLworICAgIGxkOCByMjc9W3Iz
XSwxNiAgICAgICAgLyogYXJfc3NkICovCisgICAgbW92IGI2ID0gcjI0CisgICAgOzsKKyAgICBs
ZDguZmlsbCByOD1bcjJdLDE2CisgICAgbGQ4LmZpbGwgcjk9W3IzXSwxNgorICAgIG1vdiBiNyA9
IHIyNQorICAgIDs7CisgICAgbW92IGFyLmNzZCA9IHIyNgorICAgIG1vdiBhci5zc2QgPSByMjcK
KyAgICA7OworICAgIGxkOC5maWxsIHIxMD1bcjJdLFBUKFIxNSktUFQoUjEwKQorICAgIGxkOC5m
aWxsIHIxMT1bcjNdLFBUKFIxNCktUFQoUjExKQorICAgIDs7CisgICAgbGQ4LmZpbGwgcjE1PVty
Ml0sUFQoUjE2KS1QVChSMTUpCisgICAgbGQ4LmZpbGwgcjE0PVtyM10sUFQoUjE3KS1QVChSMTQp
CisgICAgOzsKKyAgICBsZDguZmlsbCByMTY9W3IyXSwxNgorICAgIGxkOC5maWxsIHIxNz1bcjNd
LDE2CisgICAgOzsKKyAgICBsZDguZmlsbCByMTg9W3IyXSwxNgorICAgIGxkOC5maWxsIHIxOT1b
cjNdLDE2CisgICAgOzsKKyAgICBsZDguZmlsbCByMjA9W3IyXSwxNgorICAgIGxkOC5maWxsIHIy
MT1bcjNdLDE2CisgICAgOzsKKyAgICBsZDguZmlsbCByMjI9W3IyXSwxNgorICAgIGxkOC5maWxs
IHIyMz1bcjNdLDE2CisgICAgOzsKKyAgICBsZDguZmlsbCByMjQ9W3IyXSwxNgorICAgIGxkOC5m
aWxsIHIyNT1bcjNdLDE2CisgICAgOzsKKyAgICBsZDguZmlsbCByMjY9W3IyXSwxNgorICAgIGxk
OC5maWxsIHIyNz1bcjNdLDE2CisgICAgOzsKKyAgICBsZDguZmlsbCByMjg9W3IyXSwxNgorICAg
IGxkOC5maWxsIHIyOT1bcjNdLDE2CisgICAgOzsKKyAgICBsZDguZmlsbCByMzA9W3IyXSxQVChG
NiktUFQoUjMwKQorICAgIGxkOC5maWxsIHIzMT1bcjNdLFBUKEY3KS1QVChSMzEpCisgICAgOzsK
KyAgICByc20gcHNyLmkgfCBwc3IuaWMKKyAgICAvLyBpbml0aWF0ZSB0dXJuaW5nIG9mZiBvZiBp
bnRlcnJ1cHQgYW5kIGludGVycnVwdGlvbiBjb2xsZWN0aW9uCisgICAgaW52YWxhICAgICAgICAg
IC8vIGludmFsaWRhdGUgQUxBVAorICAgIDs7CisgICAgc3Jsei5pICAgICAgICAgIC8vIGVuc3Vy
ZSBpbnRlcnJ1cHRpb24gY29sbGVjdGlvbiBpcyBvZmYKKyAgICA7OworICAgIGJzdy4wCisgICAg
OzsKKyAgICBhZGRzIHIxNiA9IFBUKENSX0lQU1IpKzE2LHIxMgorICAgIGFkZHMgcjE3ID0gUFQo
Q1JfSUlQKSsxNixyMTIKKyAgICBtb3YgcjIxPXIxMwkJLy8gZ2V0IGN1cnJlbnQKKyAgICA7Owor
ICAgIGxkOCByMzE9W3IxNl0sMTYgICAgLy8gbG9hZCBjci5pcHNyCisgICAgbGQ4IHIzMD1bcjE3
XSwxNiAgICAvLyBsb2FkIGNyLmlpcAorICAgIDs7CisgICAgbGQ4IHIyOT1bcjE2XSwxNiAgICAv
LyBsb2FkIGNyLmlmcworICAgIGxkOCByMjg9W3IxN10sMTYgICAgLy8gbG9hZCBhci51bmF0Cisg
ICAgOzsKKyAgICBsZDggcjI3PVtyMTZdLDE2ICAgIC8vIGxvYWQgYXIucGZzCisgICAgbGQ4IHIy
Nj1bcjE3XSwxNiAgICAvLyBsb2FkIGFyLnJzYworICAgIDs7CisgICAgbGQ4IHIyNT1bcjE2XSwx
NiAgICAvLyBsb2FkIGFyLnJuYXQKKyAgICBsZDggcjI0PVtyMTddLDE2ICAgIC8vIGxvYWQgYXIu
YnNwc3RvcmUKKyAgICA7OworICAgIGxkOCByMjM9W3IxNl0sMTYgICAgLy8gbG9hZCBwcmVkaWNh
dGVzCisgICAgbGQ4IHIyMj1bcjE3XSwxNiAgICAvLyBsb2FkIGIwCisgICAgOzsKKyAgICBsZDgg
cjIwPVtyMTZdLDE2ICAgIC8vIGxvYWQgYXIucnNjIHZhbHVlIGZvciAibG9hZHJzIgorICAgIGxk
OC5maWxsIHIxPVtyMTddLDE2ICAgIC8vbG9hZCByMQorICAgIDs7CisgICAgbGQ4LmZpbGwgcjEy
PVtyMTZdLDE2ICAgIC8vbG9hZCByMTIKKyAgICBsZDguZmlsbCByMTM9W3IxN10sUFQoUjIpLVBU
KFIxMykgICAgLy9sb2FkIHIxMworICAgIDs7CisgICAgbGQ4IHIxOT1bcjE2XSxQVChSMyktUFQo
QVJfRlBTUikgICAgLy9sb2FkIGFyX2Zwc3IKKyAgICBsZDguZmlsbCByMj1bcjE3XSxQVChBUl9D
Q1YpLVBUKFIyKSAgICAvL2xvYWQgcjIKKyAgICA7OworICAgIGxkOC5maWxsIHIzPVtyMTZdCS8v
bG9hZCByMworICAgIGxkOCByMTg9W3IxN10JLy9sb2FkIGFyX2NjdgorICAgIDs7CisgICAgbW92
IGFyLmZwc3I9cjE5CisgICAgbW92IGFyLmNjdj1yMTgKKyAgICBzaHIudSByMTg9cjIwLDE2Cisg
ICAgOzsKK2t2bV9yYnNfc3dpdGNoOgorICAgIG1vdiByMTk9OTYKKwora3ZtX2RvbnRfcHJlc2Vy
dmVfY3VycmVudF9mcmFtZToKKy8qCisgICAgKiBUbyBwcmV2ZW50IGxlYWtpbmcgYml0cyBiZXR3
ZWVuIHRoZSBoeXBlcnZpc29yIGFuZCBndWVzdCBkb21haW4sCisgICAgKiB3ZSBtdXN0IGNsZWFy
IHRoZSBzdGFja2VkIHJlZ2lzdGVycyBpbiB0aGUgImludmFsaWQiIHBhcnRpdGlvbiBoZXJlLgor
ICAgICogNSByZWdpc3RlcnMvY3ljbGUgb24gTWNLaW5sZXkpLgorICAgICovCisjICAgZGVmaW5l
IHBSZWN1cnNlCXA2CisjICAgZGVmaW5lIHBSZXR1cm4JcDcKKyMgICBkZWZpbmUgTnJlZ3MJMTQK
KworICAgIGFsbG9jIGxvYzA9YXIucGZzLDIsTnJlZ3MtMiwyLDAKKyAgICBzaHIudSBsb2MxPXIx
OCw5CQkvLyBSTmFUc2xvdHMgPD0gZmxvb3IoZGlydHlTaXplIC8gKDY0KjgpKQorICAgIHN1YiBy
MTk9cjE5LHIxOAkJLy8gcjE5ID0gKHBoeXNTdGFja2VkU2l6ZSArIDgpIC0gZGlydHlTaXplCisg
ICAgOzsKKyAgICBtb3YgYXIucnNjPXIyMAkJLy8gbG9hZCBhci5yc2MgdG8gYmUgdXNlZCBmb3Ig
ImxvYWRycyIKKyAgICBzaGxhZGQgaW4wPWxvYzEsMyxyMTkKKyAgICBtb3YgaW4xPTAKKyAgICA7
OworICAgIFRFWFRfQUxJR04oMzIpCitrdm1fcnNlX2NsZWFyX2ludmFsaWQ6CisgICAgYWxsb2Mg
bG9jMD1hci5wZnMsMixOcmVncy0yLDIsMAorICAgIGNtcC5sdCBwUmVjdXJzZSxwMD1OcmVncyo4
LGluMAorICAgIC8vIGlmIG1vcmUgdGhhbiBOcmVncyByZWdzIGxlZnQgdG8gY2xlYXIsIChyZSlj
dXJzZQorICAgIGFkZCBvdXQwPS1OcmVncyo4LGluMAorICAgIGFkZCBvdXQxPTEsaW4xCQkvLyBp
bmNyZW1lbnQgcmVjdXJzaW9uIGNvdW50CisgICAgbW92IGxvYzE9MAorICAgIG1vdiBsb2MyPTAK
KyAgICA7OworICAgIG1vdiBsb2MzPTAKKyAgICBtb3YgbG9jND0wCisgICAgbW92IGxvYzU9MAor
ICAgIG1vdiBsb2M2PTAKKyAgICBtb3YgbG9jNz0wCisocFJlY3Vyc2UpIGJyLmNhbGwuZHB0ay5m
ZXcgYjA9a3ZtX3JzZV9jbGVhcl9pbnZhbGlkCisgICAgOzsKKyAgICBtb3YgbG9jOD0wCisgICAg
bW92IGxvYzk9MAorICAgIGNtcC5uZSBwUmV0dXJuLHAwPXIwLGluMQorICAgIC8vIGlmIHJlY3Vy
c2lvbiBjb3VudCAhPSAwLCB3ZSBuZWVkIHRvIGRvIGEgYnIucmV0CisgICAgbW92IGxvYzEwPTAK
KyAgICBtb3YgbG9jMTE9MAorKHBSZXR1cm4pIGJyLnJldC5kcHRrLm1hbnkgYjAKKworIwl1bmRl
ZiBwUmVjdXJzZQorIwl1bmRlZiBwUmV0dXJuCisKKy8vIGxvYWRycyBoYXMgYWxyZWFkeSBiZWVu
IHNoaWZ0ZWQKKyAgICBhbGxvYyByMTY9YXIucGZzLDAsMCwwLDAgICAgLy8gZHJvcCBjdXJyZW50
IHJlZ2lzdGVyIGZyYW1lCisgICAgOzsKKyAgICBsb2FkcnMKKyAgICA7OworICAgIG1vdiBhci5i
c3BzdG9yZT1yMjQKKyAgICA7OworICAgIG1vdiBhci51bmF0PXIyOAorICAgIG1vdiBhci5ybmF0
PXIyNQorICAgIG1vdiBhci5yc2M9cjI2CisgICAgOzsKKyAgICBtb3YgY3IuaXBzcj1yMzEKKyAg
ICBtb3YgY3IuaWlwPXIzMAorICAgIG1vdiBjci5pZnM9cjI5CisgICAgbW92IGFyLnBmcz1yMjcK
KyAgICBhZGRzIHIxOD1WTU1fVlBEX0JBU0VfT0ZGU0VULHIyMQorICAgIDs7CisgICAgbGQ4IHIx
OD1bcjE4XSAgIC8vdnBkCisgICAgYWRkcyByMTc9Vk1NX1ZDUFVfSVNSX09GRlNFVCxyMjEKKyAg
ICA7OworICAgIGxkOCByMTc9W3IxN10KKyAgICBhZGRzIHIxOT1WTU1fVlBEX1ZQU1JfT0ZGU0VU
LHIxOAorICAgIDs7CisgICAgbGQ4IHIxOT1bcjE5XSAgICAgICAgLy92cHNyCisgICAgYWRkcyBy
MjA9Vk1NX1ZDUFVfVlNBX0JBU0VfT0ZGU0VULHIyMQorICAgIDs7CisgICAgbGQ4IHIyMD1bcjIw
XQorICAgIDs7CisvL3ZzYV9zeW5jX3dyaXRlX3N0YXJ0CisgICAgbW92IHIyNT1yMTgKKyAgICBh
ZGRzIHIxNj0gVk1NX1ZDUFVfR1BfT0ZGU0VULHIyMQorICAgIDs7CisgICAgbGQ4IHIxNj0gW3Ix
Nl0gLy8gUHV0IGdwIGluIHIyNAorICAgIG1vdmwgcjI0PUBncHJlbChpYTY0X3ZtbV9lbnRyeSkg
IC8vIGNhbGN1bGF0ZSByZXR1cm4gYWRkcmVzcworICAgIDs7CisgICAgYWRkICByMjQ9cjI0LHIx
NgorICAgIDs7CisgICAgYWRkIHIxNj1QQUxfVlBTX1NZTkNfV1JJVEUscjIwCisgICAgOzsKKyAg
ICBtb3YgYjA9cjE2CisgICAgYnIuY29uZC5zcHRrIGIwICAgICAgICAgLy8gY2FsbCB0aGUgc2Vy
dmljZQorICAgIDs7CitFTkQoaWE2NF9sZWF2ZV9oeXBlcnZpc29yKQorLy8gZmFsbCB0aHJvdWdo
CitHTE9CQUxfRU5UUlkoaWE2NF92bW1fZW50cnkpCisvKgorICogIG11c3QgYmUgYXQgYmFuayAw
CisgKiAgcGFyYW1ldGVyOgorICogIHIxNzpjci5pc3IKKyAqICByMTg6dnBkCisgKiAgcjE5OnZw
c3IKKyAqICByMjA6X192c2FfYmFzZQorICogIHIyMjpiMAorICogIHIyMzpwcmVkaWNhdGUKKyAq
LworICAgIG1vdiByMjQ9cjIyCisgICAgbW92IHIyNT1yMTgKKyAgICB0Yml0Lm56IHAxLHAyID0g
cjE5LElBNjRfUFNSX0lDX0JJVCAgICAgICAgLy8gcDE9dnBzci5pYworICAgIDs7CisgICAgKHAx
KSBhZGQgcjI5PVBBTF9WUFNfUkVTVU1FX05PUk1BTCxyMjAKKyAgICAocDEpIGJyLnNwdGsubWFu
eSBpYTY0X3ZtbV9lbnRyeV9vdXQKKyAgICA7OworICAgIHRiaXQubnogcDEscDIgPSByMTcsSUE2
NF9JU1JfSVJfQklUCQkvL3AxPWNyLmlzci5pcgorICAgIDs7CisgICAgKHAxKSBhZGQgcjI5PVBB
TF9WUFNfUkVTVU1FX05PUk1BTCxyMjAKKyAgICAocDIpIGFkZCByMjk9UEFMX1ZQU19SRVNVTUVf
SEFORExFUixyMjAKKyAgICAocDIpIGxkOCByMjY9W3IyNV0KKyAgICA7OworaWE2NF92bW1fZW50
cnlfb3V0OgorICAgIG1vdiBwcj1yMjMsLTIKKyAgICBtb3YgYjA9cjI5CisgICAgOzsKKyAgICBi
ci5jb25kLnNwdGsgYjAgICAgICAgICAgICAgLy8gY2FsbCBwYWwgc2VydmljZQorRU5EKGlhNjRf
dm1tX2VudHJ5KQorCisKKworLyoKKyAqIGV4dGVybiB1NjQgaWE2NF9jYWxsX3ZzYSh1NjQgcHJv
YywgdTY0IGFyZzEsIHU2NCBhcmcyLAorICogICAgICAgICAgICAgICAgICB1NjQgYXJnMywgdTY0
IGFyZzQsIHU2NCBhcmc1LAorICogICAgICAgICAgICAgICAgICB1NjQgYXJnNiwgdTY0IGFyZzcp
OworICoKKyAqIFhYWDogVGhlIGN1cnJlbnRseSBkZWZpbmVkIHNlcnZpY2VzIHVzZSBvbmx5IDQg
YXJncyBhdCB0aGUgbWF4LiBUaGUKKyAqICByZXN0IGFyZSBub3QgY29uc3VtZWQuCisgKi8KK0dM
T0JBTF9FTlRSWShpYTY0X2NhbGxfdnNhKQorICAgIC5yZWdzdGsgNCw0LDAsMAorCitycHNhdmUg
ID0gICBsb2MwCitwZnNzYXZlID0gICBsb2MxCitwc3JzYXZlID0gICBsb2MyCitlbnRyeSAgID0g
ICBsb2MzCitob3N0cmV0ID0gICByMjQKKworICAgIGFsbG9jICAgcGZzc2F2ZT1hci5wZnMsNCw0
LDAsMAorICAgIG1vdiBycHNhdmU9cnAKKyAgICBhZGRzIGVudHJ5PVZNTV9WQ1BVX1ZTQV9CQVNF
X09GRlNFVCwgcjEzCisgICAgOzsKKyAgICBsZDggZW50cnk9W2VudHJ5XQorMTogIG1vdiBob3N0
cmV0PWlwCisgICAgbW92IHIyNT1pbjEgICAgICAgICAvLyBjb3B5IGFyZ3VtZW50cworICAgIG1v
diByMjY9aW4yCisgICAgbW92IHIyNz1pbjMKKyAgICBtb3YgcHNyc2F2ZT1wc3IKKyAgICA7Owor
ICAgIHRiaXQubnogcDYscDA9cHNyc2F2ZSwxNCAgICAvLyBJQTY0X1BTUl9JCisgICAgdGJpdC5u
eiBwNyxwMD1wc3JzYXZlLDEzICAgIC8vIElBNjRfUFNSX0lDCisgICAgOzsKKyAgICBhZGQgaG9z
dHJldD0yZi0xYixob3N0cmV0ICAgLy8gY2FsY3VsYXRlIHJldHVybiBhZGRyZXNzCisgICAgYWRk
IGVudHJ5PWVudHJ5LGluMAorICAgIDs7CisgICAgcnNtIHBzci5pIHwgcHNyLmljCisgICAgOzsK
KyAgICBzcmx6LmkKKyAgICBtb3YgYjY9ZW50cnkKKyAgICBici5jb25kLnNwdGsgYjYgICAgICAg
ICAvLyBjYWxsIHRoZSBzZXJ2aWNlCisyOgorICAgIC8vIEFyY2hpdGVjdHVyYWwgc2VxdWVuY2Ug
Zm9yIGVuYWJsaW5nIGludGVycnVwdHMgaWYgbmVjZXNzYXJ5CisocDcpICAgIHNzbSBwc3IuaWMK
KyAgICA7OworKHA3KSAgICBzcmx6LmkKKyAgICA7OworLy8ocDYpICAgIHNzbSBwc3IuaQorICAg
IDs7CisgICAgbW92IHJwPXJwc2F2ZQorICAgIG1vdiBhci5wZnM9cGZzc2F2ZQorICAgIG1vdiBy
OD1yMzEKKyAgICA7OworICAgIHNybHouZAorICAgIGJyLnJldC5zcHRrIHJwCisKK0VORChpYTY0
X2NhbGxfdnNhKQorCisjZGVmaW5lICBJTklUX0JTUFNUT1JFICAoKDQ8PDMwKS0oMTI8PDIwKS0w
eDEwMCkKKworR0xPQkFMX0VOVFJZKHZtbV9yZXNldF9lbnRyeSkKKyAgICAvL3NldCB1cCBpcHNy
LCBpaXAsIHZwZC52cHNyLCBkY3IKKyAgICAvLyBGb3IgSVBTUjogaXQvZHQvcnQ9MSwgaS9pYz0x
LCBzaT0xLCB2bS9ibj0xCisgICAgLy8gRm9yIERDUjogYWxsIGJpdHMgMAorICAgIGFkZHMgcjE0
PS1WTU1fUFRfUkVHU19TSVpFLCByMTIKKyAgICA7OworICAgIG1vdmwgcjY9MHg1MDEwMDg4MjYw
MDAgICAgICAvLyBJUFNSIGR0L3J0L2l0OjE7aS9pYzoxLCBzaToxLCB2bS9ibjoxCisgICAgbW92
bCByMTA9MHg4MDAwMDAwMDAwMDAwMDAwCisgICAgYWRkcyByMTY9UFQoQ1JfSUlQKSwgcjE0Cisg
ICAgYWRkcyByMjA9UFQoUjEpLCByMTQKKyAgICA7OworICAgIHJzbSBwc3IuaWMgfCBwc3IuaQor
ICAgIDs7CisgICAgc3Jsei5pCisgICAgOzsKKyAgICBic3cuMAorICAgIDs7CisgICAgbW92IHIy
MSA9cjEzCisgICAgOzsKKyAgICBic3cuMQorICAgIDs7CisgICAgbW92IGFyLnJzYyA9IDAKKyAg
ICA7OworICAgIGZsdXNocnMKKyAgICA7OworICAgIG1vdiBhci5ic3BzdG9yZSA9IDAKKyAgICAv
LyBjbGVhciBCU1BTVE9SRQorICAgIDs7CisgICAgbW92IGNyLmlwc3I9cjYKKyAgICBtb3YgY3Iu
aWZzPXIxMAorICAgIGxkOCByNCA9IFtyMTZdIC8vIFNldCBpbml0IGlpcCBmb3IgZmlyc3QgcnVu
LgorICAgIGxkOCByMSA9IFtyMjBdCisgICAgOzsKKyAgICBtb3YgY3IuaWlwPXI0CisgICAgOzsK
KyAgICBhZGRzIHIxNj1WTU1fVlBEX0JBU0VfT0ZGU0VULHIxMworICAgIGFkZHMgcjIwPVZNTV9W
Q1BVX1ZTQV9CQVNFX09GRlNFVCxyMTMKKyAgICA7OworICAgIGxkOCByMTg9W3IxNl0KKyAgICBs
ZDggcjIwPVtyMjBdCisgICAgOzsKKyAgICBhZGRzIHIxOT1WTU1fVlBEX1ZQU1JfT0ZGU0VULHIx
OAorICAgIDs7CisgICAgbGQ4IHIxOT1bcjE5XQorICAgIG1vdiByMTc9cjAKKyAgICBtb3YgcjIy
PXIwCisgICAgbW92IHIyMz1yMAorICAgIGJyLmNvbmQuc3B0ayBpYTY0X3ZtbV9lbnRyeQorICAg
IGJyLnJldC5zcHRrICBiMAorRU5EKHZtbV9yZXNldF9lbnRyeSkKKwotLSAKMS41LjIKCg==

------_=_NextPart_001_01C893E5.D0ECEEB3--
