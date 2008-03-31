From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Mon, 31 Mar 2008 08:28:15 +0000
Subject: [08/17][PATCH] kvm/ia64: Add interruption vector table for vmm. V8
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDC0104824C@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C89309.2AB1D75F"
List-Id: <linux-ia64.vger.kernel.org>
References: <42DFA526FC41B1429CE7279EF83C6BDCFF7EF8@pdsmsx415.ccr.corp.intel.com>
In-Reply-To: <42DFA526FC41B1429CE7279EF83C6BDCFF7EF8@pdsmsx415.ccr.corp.intel.com>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C89309.2AB1D75F
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

From 2deffaaead48f216128ebc2ec37731a016b04fff Mon Sep 17 00:00:00 2001
From: Xiantao Zhang <xiantao.zhang@intel.com>
Date: Wed, 12 Mar 2008 13:47:12 +0800
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

------_=_NextPart_001_01C89309.2AB1D75F
Content-Type: application/octet-stream;
	name="0008-KVM-IA64-Add-interruption-vector-table-for-vmm.patch"
Content-Transfer-Encoding: base64
Content-Description: 0008-KVM-IA64-Add-interruption-vector-table-for-vmm.patch
Content-Disposition: attachment;
	filename="0008-KVM-IA64-Add-interruption-vector-table-for-vmm.patch"

RnJvbSAyZGVmZmFhZWFkNDhmMjE2MTI4ZWJjMmVjMzc3MzFhMDE2YjA0ZmZmIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBYaWFudGFvIFpoYW5nIDx4aWFudGFvLnpoYW5nQGludGVsLmNv
bT4KRGF0ZTogV2VkLCAxMiBNYXIgMjAwOCAxMzo0NzoxMiArMDgwMApTdWJqZWN0OiBbUEFUQ0hd
IEtWTTogSUE2NCA6IEFkZCBpbnRlcnJ1cHRpb24gdmVjdG9yIHRhYmxlIGZvciB2bW0uCgp2bW1f
aXZ0LlMgaW5jbHVkZXMgYW4gaXZ0IGZvciB2bW0gdXNlLgpTaWduZWQtb2ZmLWJ5OiBBbnRob255
IFh1IDxhbnRob255Lnh1QGludGVsLmNvbT4KU2lnbmVkLW9mZi1ieTogWGlhbnRhbyBaaGFuZyA8
eGlhbnRhby56aGFuZ0BpbnRlbC5jb20+Ci0tLQogYXJjaC9pYTY0L2t2bS92bW1faXZ0LlMgfCAx
NDI1ICsrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrCiAxIGZp
bGVzIGNoYW5nZWQsIDE0MjUgaW5zZXJ0aW9ucygrKSwgMCBkZWxldGlvbnMoLSkKIGNyZWF0ZSBt
b2RlIDEwMDY0NCBhcmNoL2lhNjQva3ZtL3ZtbV9pdnQuUwoKZGlmZiAtLWdpdCBhL2FyY2gvaWE2
NC9rdm0vdm1tX2l2dC5TIGIvYXJjaC9pYTY0L2t2bS92bW1faXZ0LlMKbmV3IGZpbGUgbW9kZSAx
MDA2NDQKaW5kZXggMDAwMDAwMC4uYzhiMmM2ZQotLS0gL2Rldi9udWxsCisrKyBiL2FyY2gvaWE2
NC9rdm0vdm1tX2l2dC5TCkBAIC0wLDAgKzEsMTQyNSBAQAorLyoKKyAqIC9pYTY0L2t2bV9pdnQu
UworICoKKyAqIENvcHlyaWdodCAoQykgMTk5OC0yMDAxLCAyMDAzIEhld2xldHQtUGFja2FyZCBD
bworICogICAgICBTdGVwaGFuZSBFcmFuaWFuIDxlcmFuaWFuQGhwbC5ocC5jb20+CisgKiAgICAg
IERhdmlkIE1vc2JlcmdlciA8ZGF2aWRtQGhwbC5ocC5jb20+CisgKiBDb3B5cmlnaHQgKEMpIDIw
MDAsIDIwMDItMjAwMyBJbnRlbCBDbworICogICAgICBBc2l0IE1hbGxpY2sgPGFzaXQuay5tYWxs
aWNrQGludGVsLmNvbT4KKyAqICAgICAgU3VyZXNoIFNpZGRoYSA8c3VyZXNoLmIuc2lkZGhhQGlu
dGVsLmNvbT4KKyAqICAgICAgS2VubmV0aCBDaGVuIDxrZW5uZXRoLncuY2hlbkBpbnRlbC5jb20+
CisgKiAgICAgIEZlbmdodWEgWXUgPGZlbmdodWEueXVAaW50ZWwuY29tPgorICoKKyAqCisgKiAw
MC8wOC8yMyBBc2l0IE1hbGxpY2sgPGFzaXQuay5tYWxsaWNrQGludGVsLmNvbT4gVExCIGhhbmRs
aW5nCisgKiBmb3IgU01QCisgKiAwMC8xMi8yMCBEYXZpZCBNb3NiZXJnZXItVGFuZyA8ZGF2aWRt
QGhwbC5ocC5jb20+IERUTEIvSVRMQgorICogaGFuZGxlciBub3cgdXNlcyB2aXJ0dWFsIFBULgor
ICoKKyAqIDA3LzYvMjAgWHVlZmVpIFh1ICAoQW50aG9ueSBYdSkgKGFudGhvbnkueHVAaW50ZWwu
Y29tKQorICogICAgICAgICAgICAgIFN1cHBvcnRpbmcgSW50ZWwgdmlydHVhbGl6YXRpb24gYXJj
aGl0ZWN0dXJlCisgKgorICovCisKKy8qCisgKiBUaGlzIGZpbGUgZGVmaW5lcyB0aGUgaW50ZXJy
dXB0aW9uIHZlY3RvciB0YWJsZSB1c2VkIGJ5IHRoZSBDUFUuCisgKiBJdCBkb2VzIG5vdCBpbmNs
dWRlIG9uZSBlbnRyeSBwZXIgcG9zc2libGUgY2F1c2Ugb2YgaW50ZXJydXB0aW9uLgorICoKKyAq
IFRoZSBmaXJzdCAyMCBlbnRyaWVzIG9mIHRoZSB0YWJsZSBjb250YWluIDY0IGJ1bmRsZXMgZWFj
aCB3aGlsZSB0aGUKKyAqIHJlbWFpbmluZyA0OCBlbnRyaWVzIGNvbnRhaW4gb25seSAxNiBidW5k
bGVzIGVhY2guCisgKgorICogVGhlIDY0IGJ1bmRsZXMgYXJlIHVzZWQgdG8gYWxsb3cgaW5saW5p
bmcgdGhlIHdob2xlIGhhbmRsZXIgZm9yCisgKiBjcml0aWNhbAorICogaW50ZXJydXB0aW9ucyBs
aWtlIFRMQiBtaXNzZXMuCisgKgorICogIEZvciBlYWNoIGVudHJ5LCB0aGUgY29tbWVudCBpcyBh
cyBmb2xsb3dzOgorICoKKyAqICAgICAgICAgICAgICAvLyAweDFjMDAgRW50cnkgNyAoc2l6ZSA2
NCBidW5kbGVzKSBEYXRhIEtleSBNaXNzCisgKiAgICAgICAgICAgICAgKDEyLDUxKQorICogIGVu
dHJ5IG9mZnNldCAtLS0tLyAgICAgLyAgICAgICAgIC8gICAgICAgICAgICAgICAgICAvCisgKiAg
LworICogIGVudHJ5IG51bWJlciAtLS0tLS0tLS0vICAgICAgICAgLyAgICAgICAgICAgICAgICAg
IC8KKyAqICAvCisgKiAgc2l6ZSBvZiB0aGUgZW50cnkgLS0tLS0tLS0tLS0tLS8gICAgICAgICAg
ICAgICAgICAvCisgKiAgLworICogIHZlY3RvciBuYW1lIC0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0vCisgKiAgLworICogIGludGVycnVwdGlvbnMgdHJpZ2dlcmluZyB0aGlz
IHZlY3RvcgorICogIC0tLS0tLS0tLS0tLS0tLS0tLS0tLS0vCisgKgorICogVGhlIHRhYmxlIGlz
IDMyS0IgaW4gc2l6ZSBhbmQgbXVzdCBiZSBhbGlnbmVkIG9uIDMyS0IKKyAqIGJvdW5kYXJ5Lgor
ICogKFRoZSBDUFUgaWdub3JlcyB0aGUgMTUgbG93ZXIgYml0cyBvZiB0aGUgYWRkcmVzcykKKyAq
CisgKiBUYWJsZSBpcyBiYXNlZCB1cG9uIEVBUzIuNiAoT2N0IDE5OTkpCisgKi8KKworCisjaW5j
bHVkZSA8YXNtL2FzbW1hY3JvLmg+CisjaW5jbHVkZSA8YXNtL2NhY2hlLmg+CisjaW5jbHVkZSA8
YXNtL3BndGFibGUuaD4KKworI2luY2x1ZGUgImFzbS1vZmZzZXRzLmgiCisjaW5jbHVkZSAidmNw
dS5oIgorI2luY2x1ZGUgImt2bV9taW5zdGF0ZS5oIgorI2luY2x1ZGUgInZ0aS5oIgorCisjaWYg
MQorIyBkZWZpbmUgUFNSX0RFRkFVTFRfQklUUyAgIHBzci5hYworI2Vsc2UKKyMgZGVmaW5lIFBT
Ul9ERUZBVUxUX0JJVFMgICAwCisjZW5kaWYKKworCisjZGVmaW5lIEtWTV9GQVVMVChuKSAgICBc
CisgICAga3ZtX2ZhdWx0XyMjbjo7ICAgICAgICAgIFwKKyAgICBtb3YgcjE5PW47OyAgICAgICAg
ICBcCisgICAgYnIuc3B0ay5tYW55IGt2bV9mYXVsdF8jI247ICAgICAgICAgXAorICAgIDs7ICAg
ICAgICAgICAgICAgICAgXAorCisKKyNkZWZpbmUgS1ZNX1JFRkxFQ1QobikgICAgXAorICAgIG1v
diByMzE9cHI7ICAgICAgICAgICBcCisgICAgbW92IHIxOT1uOyAgICAgICAvKiBwcmVwYXJlIHRv
IHNhdmUgcHJlZGljYXRlcyAqLyBcCisgICAgbW92IHIyOT1jci5pcHNyOyAgICAgIFwKKyAgICA7
OyAgICAgIFwKKyAgICB0Yml0LnogcDYscDc9cjI5LElBNjRfUFNSX1ZNX0JJVDsgICAgICAgXAor
KHA3KWJyLnNwdGsubWFueSBrdm1fZGlzcGF0Y2hfcmVmbGVjdGlvbjsgICAgICAgIFwKKyAgICBi
ci5zcHRrLm1hbnkga3ZtX3BhbmljOyAgICAgIFwKKworCitHTE9CQUxfRU5UUlkoa3ZtX3Bhbmlj
KQorICAgIGJyLnNwdGsubWFueSBrdm1fcGFuaWMKKyAgICA7OworRU5EKGt2bV9wYW5pYykKKwor
CisKKworCisgICAgLnNlY3Rpb24gLnRleHQuaXZ0LCJheCIKKworICAgIC5hbGlnbiAzMjc2OCAg
ICAvLyBhbGlnbiBvbiAzMktCIGJvdW5kYXJ5CisgICAgLmdsb2JhbCBrdm1faWE2NF9pdnQKK2t2
bV9pYTY0X2l2dDoKKy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLworLy8gMHgwMDAwIEVudHJ5IDAgKHNpemUgNjQgYnVuZGxlcykg
VkhQVCBUcmFuc2xhdGlvbiAoOCwyMCw0NykKK0VOVFJZKGt2bV92aHB0X21pc3MpCisgICAgS1ZN
X0ZBVUxUKDApCitFTkQoa3ZtX3ZocHRfbWlzcykKKworCisgICAgLm9yZyBrdm1faWE2NF9pdnQr
MHg0MDAKKy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8KKy8vIDB4MDQwMCBFbnRyeSAxIChzaXplIDY0IGJ1bmRsZXMpIElUTEIg
KDIxKQorRU5UUlkoa3ZtX2l0bGJfbWlzcykKKyAgICBtb3YgcjMxID0gcHIKKyAgICBtb3YgcjI5
PWNyLmlwc3I7CisgICAgOzsKKyAgICB0Yml0LnogcDYscDc9cjI5LElBNjRfUFNSX1ZNX0JJVDsK
KyAgICAocDYpIGJyLnNwdGsga3ZtX2FsdF9pdGxiX21pc3MKKyAgICBtb3YgcjE5ID0gMQorICAg
IGJyLnNwdGsga3ZtX2l0bGJfbWlzc19kaXNwYXRjaAorICAgIEtWTV9GQVVMVCgxKTsKK0VORChr
dm1faXRsYl9taXNzKQorCisgICAgLm9yZyBrdm1faWE2NF9pdnQrMHgwODAwCisvLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8K
Ky8vIDB4MDgwMCBFbnRyeSAyIChzaXplIDY0IGJ1bmRsZXMpIERUTEIgKDksNDgpCitFTlRSWShr
dm1fZHRsYl9taXNzKQorICAgIG1vdiByMzEgPSBwcgorICAgIG1vdiByMjk9Y3IuaXBzcjsKKyAg
ICA7OworICAgIHRiaXQueiBwNixwNz1yMjksSUE2NF9QU1JfVk1fQklUOworKHA2KWJyLnNwdGsg
a3ZtX2FsdF9kdGxiX21pc3MKKyAgICBici5zcHRrIGt2bV9kdGxiX21pc3NfZGlzcGF0Y2gKK0VO
RChrdm1fZHRsYl9taXNzKQorCisgICAgIC5vcmcga3ZtX2lhNjRfaXZ0KzB4MGMwMAorLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8KKy8vIDB4MGMwMCBFbnRyeSAzIChzaXplIDY0IGJ1bmRsZXMpIEFsdCBJVExCICgxOSkK
K0VOVFJZKGt2bV9hbHRfaXRsYl9taXNzKQorICAgIG1vdiByMTY9Y3IuaWZhICAgIC8vIGdldCBh
ZGRyZXNzIHRoYXQgY2F1c2VkIHRoZSBUTEIgbWlzcworICAgIDs7CisgICAgbW92bCByMTc9UEFH
RV9LRVJORUwKKyAgICBtb3YgcjI0PWNyLmlwc3IKKyAgICBtb3ZsIHIxOT0oKCgxIDw8IElBNjRf
TUFYX1BIWVNfQklUUykgLSAxKSAmIH4weGZmZikKKyAgICA7OworICAgIGFuZCByMTk9cjE5LHIx
NiAgICAgLy8gY2xlYXIgZWQsIHJlc2VydmVkIGJpdHMsIGFuZCBQVEUgY29udHJvbCBiaXRzCisg
ICAgOzsKKyAgICBvciByMTk9cjE3LHIxOSAgICAgIC8vIGluc2VydCBQVEUgY29udHJvbCBiaXRz
IGludG8gcjE5CisgICAgOzsKKyAgICBtb3ZsIHIyMD1JQTY0X0dSQU5VTEVfU0hJRlQ8PDIKKyAg
ICA7OworICAgIG1vdiBjci5pdGlyPXIyMAorICAgIDs7CisgICAgaXRjLmkgcjE5CQkvLyBpbnNl
cnQgdGhlIFRMQiBlbnRyeQorICAgIG1vdiBwcj1yMzEsLTEKKyAgICByZmkKK0VORChrdm1fYWx0
X2l0bGJfbWlzcykKKworICAgIC5vcmcga3ZtX2lhNjRfaXZ0KzB4MTAwMAorLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
CisvLyAweDEwMDAgRW50cnkgNCAoc2l6ZSA2NCBidW5kbGVzKSBBbHQgRFRMQiAoNyw0NikKK0VO
VFJZKGt2bV9hbHRfZHRsYl9taXNzKQorICAgIG1vdiByMTY9Y3IuaWZhCQkvLyBnZXQgYWRkcmVz
cyB0aGF0IGNhdXNlZCB0aGUgVExCIG1pc3MKKyAgICA7OworICAgIG1vdmwgcjE3PVBBR0VfS0VS
TkVMCisgICAgbW92bCByMTk9KCgoMSA8PCBJQTY0X01BWF9QSFlTX0JJVFMpIC0gMSkgJiB+MHhm
ZmYpCisgICAgbW92IHIyND1jci5pcHNyCisgICAgOzsKKyAgICBhbmQgcjE5PXIxOSxyMTYgICAg
IC8vIGNsZWFyIGVkLCByZXNlcnZlZCBiaXRzLCBhbmQgUFRFIGNvbnRyb2wgYml0cworICAgIDs7
CisgICAgb3IgcjE5PXIxOSxyMTcJLy8gaW5zZXJ0IFBURSBjb250cm9sIGJpdHMgaW50byByMTkK
KyAgICA7OworICAgIG1vdmwgcjIwPUlBNjRfR1JBTlVMRV9TSElGVDw8MgorICAgIDs7CisgICAg
bW92IGNyLml0aXI9cjIwCisgICAgOzsKKyAgICBpdGMuZCByMTkJCS8vIGluc2VydCB0aGUgVExC
IGVudHJ5CisgICAgbW92IHByPXIzMSwtMQorICAgIHJmaQorRU5EKGt2bV9hbHRfZHRsYl9taXNz
KQorCisgICAgLm9yZyBrdm1faWE2NF9pdnQrMHgxNDAwCisvLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vCisvLyAweDE0
MDAgRW50cnkgNSAoc2l6ZSA2NCBidW5kbGVzKSBEYXRhIG5lc3RlZCBUTEIgKDYsNDUpCitFTlRS
WShrdm1fbmVzdGVkX2R0bGJfbWlzcykKKyAgICBLVk1fRkFVTFQoNSkKK0VORChrdm1fbmVzdGVk
X2R0bGJfbWlzcykKKworICAgIC5vcmcga3ZtX2lhNjRfaXZ0KzB4MTgwMAorLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
CisvLyAweDE4MDAgRW50cnkgNiAoc2l6ZSA2NCBidW5kbGVzKSBJbnN0cnVjdGlvbiBLZXkgTWlz
cyAoMjQpCitFTlRSWShrdm1faWtleV9taXNzKQorICAgIEtWTV9SRUZMRUNUKDYpCitFTkQoa3Zt
X2lrZXlfbWlzcykKKworICAgIC5vcmcga3ZtX2lhNjRfaXZ0KzB4MWMwMAorLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
CisvLyAweDFjMDAgRW50cnkgNyAoc2l6ZSA2NCBidW5kbGVzKSBEYXRhIEtleSBNaXNzICgxMiw1
MSkKK0VOVFJZKGt2bV9ka2V5X21pc3MpCisgICAgS1ZNX1JFRkxFQ1QoNykKK0VORChrdm1fZGtl
eV9taXNzKQorCisgICAgLm9yZyBrdm1faWE2NF9pdnQrMHgyMDAwCisvLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLworLy8g
MHgyMDAwIEVudHJ5IDggKHNpemUgNjQgYnVuZGxlcykgRGlydHktYml0ICg1NCkKK0VOVFJZKGt2
bV9kaXJ0eV9iaXQpCisgICAgS1ZNX1JFRkxFQ1QoOCkKK0VORChrdm1fZGlydHlfYml0KQorCisg
ICAgLm9yZyBrdm1faWE2NF9pdnQrMHgyNDAwCisvLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLworLy8gMHgyNDAwIEVudHJ5
IDkgKHNpemUgNjQgYnVuZGxlcykgSW5zdHJ1Y3Rpb24gQWNjZXNzLWJpdCAoMjcpCitFTlRSWShr
dm1faWFjY2Vzc19iaXQpCisgICAgS1ZNX1JFRkxFQ1QoOSkKK0VORChrdm1faWFjY2Vzc19iaXQp
CisKKyAgICAub3JnIGt2bV9pYTY0X2l2dCsweDI4MDAKKy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8KKy8vIDB4MjgwMCBF
bnRyeSAxMCAoc2l6ZSA2NCBidW5kbGVzKSBEYXRhIEFjY2Vzcy1iaXQgKDE1LDU1KQorRU5UUlko
a3ZtX2RhY2Nlc3NfYml0KQorICAgIEtWTV9SRUZMRUNUKDEwKQorRU5EKGt2bV9kYWNjZXNzX2Jp
dCkKKworICAgIC5vcmcga3ZtX2lhNjRfaXZ0KzB4MmMwMAorLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8KKy8vIDB4MmMwMCBF
bnRyeSAxMSAoc2l6ZSA2NCBidW5kbGVzKSBCcmVhayBpbnN0cnVjdGlvbiAoMzMpCitFTlRSWShr
dm1fYnJlYWtfZmF1bHQpCisgICAgbW92IHIzMT1wcgorICAgIG1vdiByMTk9MTEKKyAgICBtb3Yg
cjI5PWNyLmlwc3IKKyAgICA7OworICAgIEtWTV9TQVZFX01JTl9XSVRIX0NPVkVSX1IxOQorICAg
IDs7CisgICAgYWxsb2MgcjE0PWFyLnBmcywwLDAsNCwwIC8vIG5vdyBpdCdzIHNhZmUgKG11c3Qg
YmUgZmlyc3QgaW4gaW5zbiBncm91cCEpCisgICAgbW92IG91dDA9Y3IuaWZhCisgICAgbW92IG91
dDI9Y3IuaXNyICAgICAvLyBGSVhNRTogcGl0eSB0byBtYWtlIHRoaXMgc2xvdyBhY2Nlc3MgdHdp
Y2UKKyAgICBtb3Ygb3V0Mz1jci5paW0gICAgIC8vIEZJWE1FOiBwaXR5IHRvIG1ha2UgdGhpcyBz
bG93IGFjY2VzcyB0d2ljZQorICAgIGFkZHMgcjM9OCxyMiAgICAgICAgICAgICAgICAvLyBzZXQg
dXAgc2Vjb25kIGJhc2UgcG9pbnRlcgorICAgIDs7CisgICAgc3NtIHBzci5pYworICAgIDs7Cisg
ICAgc3Jsei5pICAgICAgICAgICAgICAgICAgLy8gZ3VhcmFudGVlIHRoYXQgaW50ZXJydXB0aW9u
IGNvbGxlY3Rpb24gaXMgb24KKyAgICA7OworICAgIC8vKHAxNSlzc20gcHNyLmkgICAgICAgICAg
ICAgICAvLyByZXN0b3JlIHBzci5pCisgICAgYWRkbCByMTQ9QGdwcmVsKGlhNjRfbGVhdmVfaHlw
ZXJ2aXNvciksZ3AKKyAgICA7OworICAgIEtWTV9TQVZFX1JFU1QKKyAgICBtb3YgcnA9cjE0Cisg
ICAgOzsKKyAgICBhZGRzIG91dDE9MTYsc3AKKyAgICBici5jYWxsLnNwdGsubWFueSBiNj1rdm1f
aWE2NF9oYW5kbGVfYnJlYWsKKyAgICA7OworRU5EKGt2bV9icmVha19mYXVsdCkKKworICAgIC5v
cmcga3ZtX2lhNjRfaXZ0KzB4MzAwMAorLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8KKy8vIDB4MzAwMCBFbnRyeSAxMiAoc2l6
ZSA2NCBidW5kbGVzKSBFeHRlcm5hbCBJbnRlcnJ1cHQgKDQpCitFTlRSWShrdm1faW50ZXJydXB0
KQorICAgIG1vdiByMzE9cHIJCS8vIHByZXBhcmUgdG8gc2F2ZSBwcmVkaWNhdGVzCisgICAgbW92
IHIxOT0xMgorICAgIG1vdiByMjk9Y3IuaXBzcgorICAgIDs7CisgICAgdGJpdC56IHA2LHA3PXIy
OSxJQTY0X1BTUl9WTV9CSVQKKyAgICB0Yml0LnogcDAscDE1PXIyOSxJQTY0X1BTUl9JX0JJVAor
ICAgIDs7CisocDcpIGJyLnNwdGsga3ZtX2Rpc3BhdGNoX2ludGVycnVwdAorICAgIDs7CisgICAg
bW92IHIyNz1hci5yc2MJCS8qIE0gKi8KKyAgICBtb3YgcjIwPXIxCQkJLyogQSAqLworICAgIG1v
diByMjU9YXIudW5hdAkJLyogTSAqLworICAgIG1vdiByMjY9YXIucGZzCQkvKiBJICovCisgICAg
bW92IHIyOD1jci5paXAJCS8qIE0gKi8KKyAgICBjb3ZlcgkJCS8qIEIgKG9yIG5vdGhpbmcpICov
CisgICAgOzsKKyAgICBtb3YgcjE9c3AKKyAgICA7OworICAgIGludmFsYQkJCS8qIE0gKi8KKyAg
ICBtb3YgcjMwPWNyLmlmcworICAgIDs7CisgICAgYWRkbCByMT0tVk1NX1BUX1JFR1NfU0laRSxy
MQorICAgIDs7CisgICAgYWRkcyByMTc9MipMMV9DQUNIRV9CWVRFUyxyMQkvKiByZWFsbHk6IGJp
Z2dlc3QgY2FjaGUtbGluZSBzaXplICovCisgICAgYWRkcyByMTY9UFQoQ1JfSVBTUikscjEKKyAg
ICA7OworICAgIGxmZXRjaC5mYXVsdC5leGNsLm50MSBbcjE3XSxMMV9DQUNIRV9CWVRFUworICAg
IHN0OCBbcjE2XT1yMjkJCQkvKiBzYXZlIGNyLmlwc3IgKi8KKyAgICA7OworICAgIGxmZXRjaC5m
YXVsdC5leGNsLm50MSBbcjE3XQorICAgIG1vdiByMjk9YjAKKyAgICA7OworICAgIGFkZHMgcjE2
PVBUKFI4KSxyMSAgCS8qIGluaXRpYWxpemUgZmlyc3QgYmFzZSBwb2ludGVyICovCisgICAgYWRk
cyByMTc9UFQoUjkpLHIxICAJLyogaW5pdGlhbGl6ZSBzZWNvbmQgYmFzZSBwb2ludGVyICovCisg
ICAgbW92IHIxOD1yMCAgICAgIAkJLyogbWFrZSBzdXJlIHIxOCBpc24ndCBOYVQgKi8KKyAgICA7
OworLm1lbS5vZmZzZXQgMCwwOyBzdDguc3BpbGwgW3IxNl09cjgsMTYKKy5tZW0ub2Zmc2V0IDgs
MDsgc3Q4LnNwaWxsIFtyMTddPXI5LDE2CisgICAgICAgIDs7CisubWVtLm9mZnNldCAwLDA7IHN0
OC5zcGlsbCBbcjE2XT1yMTAsMjQKKy5tZW0ub2Zmc2V0IDgsMDsgc3Q4LnNwaWxsIFtyMTddPXIx
MSwyNAorICAgICAgICA7OworICAgIHN0OCBbcjE2XT1yMjgsMTYJCS8qIHNhdmUgY3IuaWlwICov
CisgICAgc3Q4IFtyMTddPXIzMCwxNgkJLyogc2F2ZSBjci5pZnMgKi8KKyAgICBtb3Ygcjg9YXIu
ZnBzcgkJLyogTSAqLworICAgIG1vdiByOT1hci5jc2QKKyAgICBtb3YgcjEwPWFyLnNzZAorICAg
IG1vdmwgcjExPUZQU1JfREVGQVVMVAkvKiBMLXVuaXQgKi8KKyAgICA7OworICAgIHN0OCBbcjE2
XT1yMjUsMTYJCS8qIHNhdmUgYXIudW5hdCAqLworICAgIHN0OCBbcjE3XT1yMjYsMTYJCS8qIHNh
dmUgYXIucGZzICovCisgICAgc2hsIHIxOD1yMTgsMTYJCS8qIGNvbXB1dGUgYXIucnNjIHRvIGJl
IHVzZWQgZm9yICJsb2FkcnMiICovCisgICAgOzsKKyAgICBzdDggW3IxNl09cjI3LDE2CQkvKiBz
YXZlIGFyLnJzYyAqLworICAgIGFkZHMgcjE3PTE2LHIxNwkJLyogc2tpcCBvdmVyIGFyX3JuYXQg
ZmllbGQgKi8KKyAgICA7OworICAgIHN0OCBbcjE3XT1yMzEsMTYJCS8qIHNhdmUgcHJlZGljYXRl
cyAqLworICAgIGFkZHMgcjE2PTE2LHIxNgkJLyogc2tpcCBvdmVyIGFyX2JzcHN0b3JlIGZpZWxk
ICovCisgICAgOzsKKyAgICBzdDggW3IxNl09cjI5LDE2CQkvKiBzYXZlIGIwICovCisgICAgc3Q4
IFtyMTddPXIxOCwxNgkJLyogc2F2ZSBhci5yc2MgdmFsdWUgZm9yICJsb2FkcnMiICovCisgICAg
OzsKKy5tZW0ub2Zmc2V0IDAsMDsgc3Q4LnNwaWxsIFtyMTZdPXIyMCwxNiAgICAvKiBzYXZlIG9y
aWdpbmFsIHIxICovCisubWVtLm9mZnNldCA4LDA7IHN0OC5zcGlsbCBbcjE3XT1yMTIsMTYKKyAg
ICBhZGRzIHIxMj0tMTYscjEKKyAgICAvKiBzd2l0Y2ggdG8ga2VybmVsIG1lbW9yeSBzdGFjayAo
d2l0aCAxNiBieXRlcyBvZiBzY3JhdGNoKSAqLworICAgIDs7CisubWVtLm9mZnNldCAwLDA7IHN0
OC5zcGlsbCBbcjE2XT1yMTMsMTYKKy5tZW0ub2Zmc2V0IDgsMDsgc3Q4LnNwaWxsIFtyMTddPXI4
LDE2IC8qIHNhdmUgYXIuZnBzciAqLworICAgIDs7CisubWVtLm9mZnNldCAwLDA7IHN0OC5zcGls
bCBbcjE2XT1yMTUsMTYKKy5tZW0ub2Zmc2V0IDgsMDsgc3Q4LnNwaWxsIFtyMTddPXIxNCwxNgor
ICAgIGRlcCByMTQ9LTEscjAsNjAsNAorICAgIDs7CisubWVtLm9mZnNldCAwLDA7IHN0OC5zcGls
bCBbcjE2XT1yMiwxNgorLm1lbS5vZmZzZXQgOCwwOyBzdDguc3BpbGwgW3IxN109cjMsMTYKKyAg
ICBhZGRzIHIyPVZNTV9QVF9SRUdTX1IxNl9PRkZTRVQscjEKKyAgICBhZGRzIHIxNCA9IFZNTV9W
Q1BVX0dQX09GRlNFVCxyMTMKKyAgICA7OworICAgIG1vdiByOD1hci5jY3YKKyAgICBsZDggcjE0
ID0gW3IxNF0KKyAgICA7OworICAgIG1vdiByMT1yMTQgICAgICAgLyogZXN0YWJsaXNoIGtlcm5l
bCBnbG9iYWwgcG9pbnRlciAqLworICAgIDs7ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgXAorICAgIGJzdy4xCisgICAgOzsKKyAgICBhbGxvYyByMTQ9YXIucGZzLDAs
MCwxLDAJLy8gbXVzdCBiZSBmaXJzdCBpbiBhbiBpbnNuIGdyb3VwCisgICAgbW92IG91dDA9cjEz
CisgICAgOzsKKyAgICBzc20gcHNyLmljCisgICAgOzsKKyAgICBzcmx6LmkKKyAgICA7OworICAg
IC8vKHAxNSkgc3NtIHBzci5pCisgICAgYWRkcyByMz04LHIyCQkvLyBzZXQgdXAgc2Vjb25kIGJh
c2UgcG9pbnRlciBmb3IgU0FWRV9SRVNUCisgICAgc3Jsei5pCQkJLy8gZW5zdXJlIGV2ZXJ5Ym9k
eSBrbm93cyBwc3IuaWMgaXMgYmFjayBvbgorICAgIDs7CisubWVtLm9mZnNldCAwLDA7IHN0OC5z
cGlsbCBbcjJdPXIxNiwxNgorLm1lbS5vZmZzZXQgOCwwOyBzdDguc3BpbGwgW3IzXT1yMTcsMTYK
KyAgICA7OworLm1lbS5vZmZzZXQgMCwwOyBzdDguc3BpbGwgW3IyXT1yMTgsMTYKKy5tZW0ub2Zm
c2V0IDgsMDsgc3Q4LnNwaWxsIFtyM109cjE5LDE2CisgICAgOzsKKy5tZW0ub2Zmc2V0IDAsMDsg
c3Q4LnNwaWxsIFtyMl09cjIwLDE2CisubWVtLm9mZnNldCA4LDA7IHN0OC5zcGlsbCBbcjNdPXIy
MSwxNgorICAgIG1vdiByMTg9YjYKKyAgICA7OworLm1lbS5vZmZzZXQgMCwwOyBzdDguc3BpbGwg
W3IyXT1yMjIsMTYKKy5tZW0ub2Zmc2V0IDgsMDsgc3Q4LnNwaWxsIFtyM109cjIzLDE2CisgICAg
bW92IHIxOT1iNworICAgIDs7CisubWVtLm9mZnNldCAwLDA7IHN0OC5zcGlsbCBbcjJdPXIyNCwx
NgorLm1lbS5vZmZzZXQgOCwwOyBzdDguc3BpbGwgW3IzXT1yMjUsMTYKKyAgICA7OworLm1lbS5v
ZmZzZXQgMCwwOyBzdDguc3BpbGwgW3IyXT1yMjYsMTYKKy5tZW0ub2Zmc2V0IDgsMDsgc3Q4LnNw
aWxsIFtyM109cjI3LDE2CisgICAgOzsKKy5tZW0ub2Zmc2V0IDAsMDsgc3Q4LnNwaWxsIFtyMl09
cjI4LDE2CisubWVtLm9mZnNldCA4LDA7IHN0OC5zcGlsbCBbcjNdPXIyOSwxNgorICAgIDs7Cisu
bWVtLm9mZnNldCAwLDA7IHN0OC5zcGlsbCBbcjJdPXIzMCwxNgorLm1lbS5vZmZzZXQgOCwwOyBz
dDguc3BpbGwgW3IzXT1yMzEsMzIKKyAgICA7OworICAgIG1vdiBhci5mcHNyPXIxMSAgICAgICAv
KiBNLXVuaXQgKi8KKyAgICBzdDggW3IyXT1yOCw4ICAgICAgICAgLyogYXIuY2N2ICovCisgICAg
YWRkcyByMjQ9UFQoQjYpLVBUKEY3KSxyMworICAgIDs7CisgICAgc3RmLnNwaWxsIFtyMl09ZjYs
MzIKKyAgICBzdGYuc3BpbGwgW3IzXT1mNywzMgorICAgIDs7CisgICAgc3RmLnNwaWxsIFtyMl09
ZjgsMzIKKyAgICBzdGYuc3BpbGwgW3IzXT1mOSwzMgorICAgIDs7CisgICAgc3RmLnNwaWxsIFty
Ml09ZjEwCisgICAgc3RmLnNwaWxsIFtyM109ZjExCisgICAgYWRkcyByMjU9UFQoQjcpLVBUKEYx
MSkscjMKKyAgICA7OworICAgIHN0OCBbcjI0XT1yMTgsMTYgICAgICAgLyogYjYgKi8KKyAgICBz
dDggW3IyNV09cjE5LDE2ICAgICAgIC8qIGI3ICovCisgICAgOzsKKyAgICBzdDggW3IyNF09cjkg
ICAgICAgICAgIC8qIGFyLmNzZCAqLworICAgIHN0OCBbcjI1XT1yMTAgICAgICAgICAgLyogYXIu
c3NkICovCisgICAgOzsKKyAgICBzcmx6LmQJCS8vIG1ha2Ugc3VyZSB3ZSBzZWUgdGhlIGVmZmVj
dCBvZiBjci5pdnIKKyAgICBhZGRsIHIxND1AZ3ByZWwoaWE2NF9sZWF2ZV9uZXN0ZWQpLGdwCisg
ICAgOzsKKyAgICBtb3YgcnA9cjE0CisgICAgYnIuY2FsbC5zcHRrLm1hbnkgYjY9a3ZtX2lhNjRf
aGFuZGxlX2lycQorICAgIDs7CitFTkQoa3ZtX2ludGVycnVwdCkKKworICAgIC5nbG9iYWwga3Zt
X2Rpc3BhdGNoX3ZleGlycQorICAgIC5vcmcga3ZtX2lhNjRfaXZ0KzB4MzQwMAorLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLworLy8gMHgzNDAwIEVudHJ5IDEzIChzaXplIDY0IGJ1bmRsZXMpIFJlc2VydmVkCitFTlRS
WShrdm1fdmlydHVhbF9leGlycSkKKyAgICBtb3YgcjMxPXByCisgICAgbW92IHIxOT0xMworICAg
IG1vdiByMzAgPXIwCisgICAgOzsKK2t2bV9kaXNwYXRjaF92ZXhpcnE6CisgICAgY21wLmVxIHA2
LHAwID0gMSxyMzAKKyAgICA7OworKHA2KWFkZCByMjkgPSBWTU1fVkNQVV9TQVZFRF9HUF9PRkZT
RVQscjIxCisgICAgOzsKKyhwNilsZDggcjEgPSBbcjI5XQorICAgIDs7CisgICAgS1ZNX1NBVkVf
TUlOX1dJVEhfQ09WRVJfUjE5CisgICAgYWxsb2MgcjE0PWFyLnBmcywwLDAsMSwwCisgICAgbW92
IG91dDA9cjEzCisKKyAgICBzc20gcHNyLmljCisgICAgOzsKKyAgICBzcmx6LmkgICAgICAgICAg
ICAgICAgICAvLyBndWFyYW50ZWUgdGhhdCBpbnRlcnJ1cHRpb24gY29sbGVjdGlvbiBpcyBvbgor
ICAgIDs7CisgICAgLy8ocDE1KSBzc20gcHNyLmkgICAgICAgICAgICAgICAvLyByZXN0b3JlIHBz
ci5pCisgICAgYWRkcyByMz04LHIyICAgICAgICAgICAgICAgIC8vIHNldCB1cCBzZWNvbmQgYmFz
ZSBwb2ludGVyCisgICAgOzsKKyAgICBLVk1fU0FWRV9SRVNUCisgICAgYWRkbCByMTQ9QGdwcmVs
KGlhNjRfbGVhdmVfaHlwZXJ2aXNvciksZ3AKKyAgICA7OworICAgIG1vdiBycD1yMTQKKyAgICBi
ci5jYWxsLnNwdGsubWFueSBiNj1rdm1fdmV4aXJxCitFTkQoa3ZtX3ZpcnR1YWxfZXhpcnEpCisK
KyAgICAub3JnIGt2bV9pYTY0X2l2dCsweDM4MDAKKy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLworLy8gMHgzODAwIEVu
dHJ5IDE0IChzaXplIDY0IGJ1bmRsZXMpIFJlc2VydmVkCisgICAgS1ZNX0ZBVUxUKDE0KQorICAg
IC8vIHRoaXMgY29kZSBzZWdtZW50IGlzIGZyb20gMi42LjE2LjEzCisKKworICAgIC5vcmcga3Zt
X2lhNjRfaXZ0KzB4M2MwMAorLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8KKy8vIDB4M2MwMCBFbnRyeSAxNSAoc2l6
ZSA2NCBidW5kbGVzKSBSZXNlcnZlZAorICAgIEtWTV9GQVVMVCgxNSkKKworCisgICAgLm9yZyBr
dm1faWE2NF9pdnQrMHg0MDAwCisvLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLworLy8gMHg0MDAwIEVudHJ5IDE2IChz
aXplIDY0IGJ1bmRsZXMpIFJlc2VydmVkCisgICAgS1ZNX0ZBVUxUKDE2KQorCisgICAgLm9yZyBr
dm1faWE2NF9pdnQrMHg0NDAwCisvLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vCisvLyAweDQ0MDAgRW50cnkgMTcgKHNp
emUgNjQgYnVuZGxlcykgUmVzZXJ2ZWQKKyAgICBLVk1fRkFVTFQoMTcpCisKKyAgICAub3JnIGt2
bV9pYTY0X2l2dCsweDQ4MDAKKy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8KKy8vIDB4NDgwMCBFbnRyeSAxOCAoc2l6
ZSA2NCBidW5kbGVzKSBSZXNlcnZlZAorICAgIEtWTV9GQVVMVCgxOCkKKworICAgIC5vcmcga3Zt
X2lhNjRfaXZ0KzB4NGMwMAorLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLworLy8gMHg0YzAwIEVudHJ5IDE5IChzaXpl
IDY0IGJ1bmRsZXMpIFJlc2VydmVkCisgICAgS1ZNX0ZBVUxUKDE5KQorCisgICAgLm9yZyBrdm1f
aWE2NF9pdnQrMHg1MDAwCisvLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vCisvLyAweDUwMDAgRW50cnkgMjAgKHNpemUg
MTYgYnVuZGxlcykgUGFnZSBOb3QgUHJlc2VudAorRU5UUlkoa3ZtX3BhZ2Vfbm90X3ByZXNlbnQp
CisgICAgS1ZNX1JFRkxFQ1QoMjApCitFTkQoa3ZtX3BhZ2Vfbm90X3ByZXNlbnQpCisKKyAgICAu
b3JnIGt2bV9pYTY0X2l2dCsweDUxMDAKKy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vCisvLyAweDUxMDAgRW50cnkg
MjEgKHNpemUgMTYgYnVuZGxlcykgS2V5IFBlcm1pc3Npb24gdmVjdG9yCitFTlRSWShrdm1fa2V5
X3Blcm1pc3Npb24pCisgICAgS1ZNX1JFRkxFQ1QoMjEpCitFTkQoa3ZtX2tleV9wZXJtaXNzaW9u
KQorCisgICAgLm9yZyBrdm1faWE2NF9pdnQrMHg1MjAwCisvLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vCisvLyAweDUy
MDAgRW50cnkgMjIgKHNpemUgMTYgYnVuZGxlcykgSW5zdHJ1Y3Rpb24gQWNjZXNzIFJpZ2h0cyAo
MjYpCitFTlRSWShrdm1faWFjY2Vzc19yaWdodHMpCisgICAgS1ZNX1JFRkxFQ1QoMjIpCitFTkQo
a3ZtX2lhY2Nlc3NfcmlnaHRzKQorCisgICAgLm9yZyBrdm1faWE2NF9pdnQrMHg1MzAwCisvLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vCisvLyAweDUzMDAgRW50cnkgMjMgKHNpemUgMTYgYnVuZGxlcykgRGF0YSBBY2Nl
c3MgUmlnaHRzICgxNCw1MykKK0VOVFJZKGt2bV9kYWNjZXNzX3JpZ2h0cykKKyAgICBLVk1fUkVG
TEVDVCgyMykKK0VORChrdm1fZGFjY2Vzc19yaWdodHMpCisKKyAgICAub3JnIGt2bV9pYTY0X2l2
dCsweDU0MDAKKy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLworLy8gMHg1NDAwIEVudHJ5IDI0IChzaXplIDE2IGJ1bmRs
ZXMpIEdlbmVyYWwgRXhjZXB0aW9uICg1LDMyLDM0LDM2LDM4LDM5KQorRU5UUlkoa3ZtX2dlbmVy
YWxfZXhjZXB0aW9uKQorICAgS1ZNX1JFRkxFQ1QoMjQpCisgICBLVk1fRkFVTFQoMjQpCitFTkQo
a3ZtX2dlbmVyYWxfZXhjZXB0aW9uKQorCisgICAgLm9yZyBrdm1faWE2NF9pdnQrMHg1NTAwCisv
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vCisvLyAweDU1MDAgRW50cnkgMjUgKHNpemUgMTYgYnVuZGxlcykgRGlzYWJs
ZWQgRlAtUmVnaXN0ZXIgKDM1KQorRU5UUlkoa3ZtX2Rpc2FibGVkX2ZwX3JlZykKKyAgICBLVk1f
UkVGTEVDVCgyNSkKK0VORChrdm1fZGlzYWJsZWRfZnBfcmVnKQorCisgICAgLm9yZyBrdm1faWE2
NF9pdnQrMHg1NjAwCisvLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLworLy8gMHg1NjAwIEVudHJ5IDI2IChzaXplIDE2IGJ1
bmRsZXMpIE5hdCBDb25zdW1wdGlvbiAoMTEsMjMsMzcsNTApCitFTlRSWShrdm1fbmF0X2NvbnN1
bXB0aW9uKQorICAgIEtWTV9SRUZMRUNUKDI2KQorRU5EKGt2bV9uYXRfY29uc3VtcHRpb24pCisK
KyAgICAub3JnIGt2bV9pYTY0X2l2dCsweDU3MDAKKy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLworLy8gMHg1NzAwIEVu
dHJ5IDI3IChzaXplIDE2IGJ1bmRsZXMpIFNwZWN1bGF0aW9uICg0MCkKK0VOVFJZKGt2bV9zcGVj
dWxhdGlvbl92ZWN0b3IpCisgICAgS1ZNX1JFRkxFQ1QoMjcpCitFTkQoa3ZtX3NwZWN1bGF0aW9u
X3ZlY3RvcikKKworICAgIC5vcmcga3ZtX2lhNjRfaXZ0KzB4NTgwMAorLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vCisv
LyAweDU4MDAgRW50cnkgMjggKHNpemUgMTYgYnVuZGxlcykgUmVzZXJ2ZWQKKyAgICBLVk1fRkFV
TFQoMjgpCisKKyAgICAub3JnIGt2bV9pYTY0X2l2dCsweDU5MDAKKy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8KKy8vIDB4
NTkwMCBFbnRyeSAyOSAoc2l6ZSAxNiBidW5kbGVzKSBEZWJ1ZyAoMTYsMjgsNTYpCitFTlRSWShr
dm1fZGVidWdfdmVjdG9yKQorICAgIEtWTV9GQVVMVCgyOSkKK0VORChrdm1fZGVidWdfdmVjdG9y
KQorCisgICAgLm9yZyBrdm1faWE2NF9pdnQrMHg1YTAwCisvLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8KKy8vIDB4NWEwMCBFbnRy
eSAzMCAoc2l6ZSAxNiBidW5kbGVzKSBVbmFsaWduZWQgUmVmZXJlbmNlICg1NykKK0VOVFJZKGt2
bV91bmFsaWduZWRfYWNjZXNzKQorICAgIEtWTV9SRUZMRUNUKDMwKQorRU5EKGt2bV91bmFsaWdu
ZWRfYWNjZXNzKQorCisgICAgLm9yZyBrdm1faWE2NF9pdnQrMHg1YjAwCisvLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
CisvLyAweDViMDAgRW50cnkgMzEgKHNpemUgMTYgYnVuZGxlcykgVW5zdXBwb3J0ZWQgRGF0YSBS
ZWZlcmVuY2UgKDU3KQorRU5UUlkoa3ZtX3Vuc3VwcG9ydGVkX2RhdGFfcmVmZXJlbmNlKQorICAg
IEtWTV9SRUZMRUNUKDMxKQorRU5EKGt2bV91bnN1cHBvcnRlZF9kYXRhX3JlZmVyZW5jZSkKKwor
ICAgIC5vcmcga3ZtX2lhNjRfaXZ0KzB4NWMwMAorLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8KKy8vIDB4NWMwMCBFbnRy
eSAzMiAoc2l6ZSAxNiBidW5kbGVzKSBGbG9hdGluZyBQb2ludCBGQVVMVCAoNjUpCitFTlRSWShr
dm1fZmxvYXRpbmdfcG9pbnRfZmF1bHQpCisgICAgS1ZNX1JFRkxFQ1QoMzIpCitFTkQoa3ZtX2Zs
b2F0aW5nX3BvaW50X2ZhdWx0KQorCisgICAgLm9yZyBrdm1faWE2NF9pdnQrMHg1ZDAwCisvLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8KKy8vIDB4NWQwMCBFbnRyeSAzMyAoc2l6ZSAxNiBidW5kbGVzKSBGbG9hdGluZyBQ
b2ludCBUcmFwICg2NikKK0VOVFJZKGt2bV9mbG9hdGluZ19wb2ludF90cmFwKQorICAgIEtWTV9S
RUZMRUNUKDMzKQorRU5EKGt2bV9mbG9hdGluZ19wb2ludF90cmFwKQorCisgICAgLm9yZyBrdm1f
aWE2NF9pdnQrMHg1ZTAwCisvLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vCisvLyAweDVlMDAgRW50cnkgMzQgKHNpemUg
MTYgYnVuZGxlcykgTG93ZXIgUHJpdmlsZWdlIFRyYW5zZmVyIFRyYXAgKDY2KQorRU5UUlkoa3Zt
X2xvd2VyX3ByaXZpbGVnZV90cmFwKQorICAgIEtWTV9SRUZMRUNUKDM0KQorRU5EKGt2bV9sb3dl
cl9wcml2aWxlZ2VfdHJhcCkKKworICAgIC5vcmcga3ZtX2lhNjRfaXZ0KzB4NWYwMAorLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLworLy8gMHg1ZjAwIEVudHJ5IDM1IChzaXplIDE2IGJ1bmRsZXMpIFRha2VuIEJyYW5j
aCBUcmFwICg2OCkKK0VOVFJZKGt2bV90YWtlbl9icmFuY2hfdHJhcCkKKyAgICBLVk1fUkVGTEVD
VCgzNSkKK0VORChrdm1fdGFrZW5fYnJhbmNoX3RyYXApCisKKyAgICAub3JnIGt2bV9pYTY0X2l2
dCsweDYwMDAKKy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vCisvLyAweDYwMDAgRW50cnkgMzYgKHNpemUgMTYgYnVuZGxl
cykgU2luZ2xlIFN0ZXAgVHJhcCAoNjkpCitFTlRSWShrdm1fc2luZ2xlX3N0ZXBfdHJhcCkKKyAg
ICBLVk1fUkVGTEVDVCgzNikKK0VORChrdm1fc2luZ2xlX3N0ZXBfdHJhcCkKKyAgICAuZ2xvYmFs
IGt2bV92aXJ0dWFsaXphdGlvbl9mYXVsdF9iYWNrCisgICAgLm9yZyBrdm1faWE2NF9pdnQrMHg2
MTAwCisvLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8KKy8vIDB4NjEwMCBFbnRyeSAzNyAoc2l6ZSAxNiBidW5kbGVzKSBW
aXJ0dWFsaXphdGlvbiBGYXVsdAorRU5UUlkoa3ZtX3ZpcnR1YWxpemF0aW9uX2ZhdWx0KQorICAg
IG1vdiByMzE9cHIKKyAgICBhZGRzIHIxNiA9IFZNTV9WQ1BVX1NBVkVEX0dQX09GRlNFVCxyMjEK
KyAgICA7OworICAgIHN0OCBbcjE2XSA9IHIxCisgICAgYWRkcyByMTcgPSBWTU1fVkNQVV9HUF9P
RkZTRVQsIHIyMQorICAgIDs7CisgICAgbGQ4IHIxID0gW3IxN10KKyAgICBjbXAuZXEgcDYscDA9
RVZFTlRfTU9WX0ZST01fQVIscjI0CisgICAgY21wLmVxIHA3LHAwPUVWRU5UX01PVl9GUk9NX1JS
LHIyNAorICAgIGNtcC5lcSBwOCxwMD1FVkVOVF9NT1ZfVE9fUlIscjI0CisgICAgY21wLmVxIHA5
LHAwPUVWRU5UX1JTTSxyMjQKKyAgICBjbXAuZXEgcDEwLHAwPUVWRU5UX1NTTSxyMjQKKyAgICBj
bXAuZXEgcDExLHAwPUVWRU5UX01PVl9UT19QU1IscjI0CisgICAgY21wLmVxIHAxMixwMD1FVkVO
VF9USEFTSCxyMjQKKyAgICAocDYpIGJyLmRwdGsubWFueSBrdm1fYXNtX21vdl9mcm9tX2FyCisg
ICAgKHA3KSBici5kcHRrLm1hbnkga3ZtX2FzbV9tb3ZfZnJvbV9ycgorICAgIChwOCkgYnIuZHB0
ay5tYW55IGt2bV9hc21fbW92X3RvX3JyCisgICAgKHA5KSBici5kcHRrLm1hbnkga3ZtX2FzbV9y
c20KKyAgICAocDEwKSBici5kcHRrLm1hbnkga3ZtX2FzbV9zc20KKyAgICAocDExKSBici5kcHRr
Lm1hbnkga3ZtX2FzbV9tb3ZfdG9fcHNyCisgICAgKHAxMikgYnIuZHB0ay5tYW55IGt2bV9hc21f
dGhhc2gKKyAgICA7Owora3ZtX3ZpcnR1YWxpemF0aW9uX2ZhdWx0X2JhY2s6CisgICAgYWRkcyBy
MTYgPSBWTU1fVkNQVV9TQVZFRF9HUF9PRkZTRVQscjIxCisgICAgOzsKKyAgICBsZDggcjEgPSBb
cjE2XQorICAgIDs7CisgICAgbW92IHIxOT0zNworICAgIGFkZHMgcjE2ID0gVk1NX1ZDUFVfQ0FV
U0VfT0ZGU0VULHIyMQorICAgIGFkZHMgcjE3ID0gVk1NX1ZDUFVfT1BDT0RFX09GRlNFVCxyMjEK
KyAgICA7OworICAgIHN0OCBbcjE2XSA9IHIyNAorICAgIHN0OCBbcjE3XSA9IHIyNQorICAgIDs7
CisgICAgY21wLm5lIHA2LHAwPUVWRU5UX1JGSSwgcjI0CisgICAgKHA2KSBici5zcHRrIGt2bV9k
aXNwYXRjaF92aXJ0dWFsaXphdGlvbl9mYXVsdAorICAgIDs7CisgICAgYWRkcyByMTg9Vk1NX1ZQ
RF9CQVNFX09GRlNFVCxyMjEKKyAgICA7OworICAgIGxkOCByMTg9W3IxOF0KKyAgICA7OworICAg
IGFkZHMgcjE4PVZNTV9WUERfVklGU19PRkZTRVQscjE4CisgICAgOzsKKyAgICBsZDggcjE4PVty
MThdCisgICAgOzsKKyAgICB0Yml0LnogcDYscDA9cjE4LDYzCisgICAgKHA2KSBici5zcHRrIGt2
bV9kaXNwYXRjaF92aXJ0dWFsaXphdGlvbl9mYXVsdAorICAgIDs7CisgICAgLy9pZiB2aWZzLnY9
MSBkZXNlcnQgY3VycmVudCByZWdpc3RlciBmcmFtZQorICAgIGFsbG9jIHIxOD1hci5wZnMsMCww
LDAsMAorICAgIGJyLnNwdGsga3ZtX2Rpc3BhdGNoX3ZpcnR1YWxpemF0aW9uX2ZhdWx0CitFTkQo
a3ZtX3ZpcnR1YWxpemF0aW9uX2ZhdWx0KQorCisgICAgLm9yZyBrdm1faWE2NF9pdnQrMHg2MjAw
CisvLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLworLy8gMHg2MjAwIEVudHJ5IDM4IChzaXplIDE2IGJ1bmRsZXMpIFJlc2VydmVkCisg
ICAgS1ZNX0ZBVUxUKDM4KQorCisgICAgLm9yZyBrdm1faWE2NF9pdnQrMHg2MzAwCisvLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
LworLy8gMHg2MzAwIEVudHJ5IDM5IChzaXplIDE2IGJ1bmRsZXMpIFJlc2VydmVkCisgICAgS1ZN
X0ZBVUxUKDM5KQorCisgICAgLm9yZyBrdm1faWE2NF9pdnQrMHg2NDAwCisvLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLworLy8g
MHg2NDAwIEVudHJ5IDQwIChzaXplIDE2IGJ1bmRsZXMpIFJlc2VydmVkCisgICAgS1ZNX0ZBVUxU
KDQwKQorCisgICAgLm9yZyBrdm1faWE2NF9pdnQrMHg2NTAwCisvLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8KKy8vIDB4NjUw
MCBFbnRyeSA0MSAoc2l6ZSAxNiBidW5kbGVzKSBSZXNlcnZlZAorICAgIEtWTV9GQVVMVCg0MSkK
KworICAgIC5vcmcga3ZtX2lhNjRfaXZ0KzB4NjYwMAorLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vCisvLyAweDY2MDAgRW50
cnkgNDIgKHNpemUgMTYgYnVuZGxlcykgUmVzZXJ2ZWQKKyAgICBLVk1fRkFVTFQoNDIpCisKKyAg
ICAub3JnIGt2bV9pYTY0X2l2dCsweDY3MDAKKy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLworLy8gMHg2NzAwIEVudHJ5IDQz
IChzaXplIDE2IGJ1bmRsZXMpIFJlc2VydmVkCisgICAgS1ZNX0ZBVUxUKDQzKQorCisgICAgLm9y
ZyBrdm1faWE2NF9pdnQrMHg2ODAwCisvLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8KKy8vIDB4NjgwMCBFbnRyeSA0NCAoc2l6
ZSAxNiBidW5kbGVzKSBSZXNlcnZlZAorICAgIEtWTV9GQVVMVCg0NCkKKworICAgIC5vcmcga3Zt
X2lhNjRfaXZ0KzB4NjkwMAorLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLworLy8gMHg2OTAwIEVudHJ5IDQ1IChzaXplIDE2
IGJ1bmRsZXMpIElBLTMyIEV4ZWNlcHRpb24KKy8vKDE3LDE4LDI5LDQxLDQyLDQzLDQ0LDU4LDYw
LDYxLDYyLDcyLDczLDc1LDc2LDc3KQorRU5UUlkoa3ZtX2lhMzJfZXhjZXB0aW9uKQorICAgIEtW
TV9GQVVMVCg0NSkKK0VORChrdm1faWEzMl9leGNlcHRpb24pCisKKyAgICAub3JnIGt2bV9pYTY0
X2l2dCsweDZhMDAKKy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vCisvLyAweDZhMDAgRW50cnkgNDYgKHNpemUgMTYgYnVu
ZGxlcykgSUEtMzIgSW50ZXJjZXB0ICAoMzAsMzEsNTksNzAsNzEpCitFTlRSWShrdm1faWEzMl9p
bnRlcmNlcHQpCisgICAgS1ZNX0ZBVUxUKDQ3KQorRU5EKGt2bV9pYTMyX2ludGVyY2VwdCkKKwor
ICAgIC5vcmcga3ZtX2lhNjRfaXZ0KzB4NmMwMAorLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vCisvLyAweDZjMDAgRW50
cnkgNDggKHNpemUgMTYgYnVuZGxlcykgUmVzZXJ2ZWQKKyAgICBLVk1fRkFVTFQoNDgpCisKKyAg
ICAub3JnIGt2bV9pYTY0X2l2dCsweDZkMDAKKy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8KKy8vIDB4NmQwMCBFbnRy
eSA0OSAoc2l6ZSAxNiBidW5kbGVzKSBSZXNlcnZlZAorICAgIEtWTV9GQVVMVCg0OSkKKworICAg
IC5vcmcga3ZtX2lhNjRfaXZ0KzB4NmUwMAorLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLworLy8gMHg2ZTAwIEVudHJ5
IDUwIChzaXplIDE2IGJ1bmRsZXMpIFJlc2VydmVkCisgICAgS1ZNX0ZBVUxUKDUwKQorCisgICAg
Lm9yZyBrdm1faWE2NF9pdnQrMHg2ZjAwCisvLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8KKy8vIDB4NmYwMCBFbnRyeSA1
MSAoc2l6ZSAxNiBidW5kbGVzKSBSZXNlcnZlZAorICAgIEtWTV9GQVVMVCg1MikKKworICAgIC5v
cmcga3ZtX2lhNjRfaXZ0KzB4NzEwMAorLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8KKy8vIDB4NzEwMCBFbnRyeSA1MyAo
c2l6ZSAxNiBidW5kbGVzKSBSZXNlcnZlZAorICAgIEtWTV9GQVVMVCg1MykKKworICAgIC5vcmcg
a3ZtX2lhNjRfaXZ0KzB4NzIwMAorLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vCisvLyAweDcyMDAgRW50cnkgNTQgKHNp
emUgMTYgYnVuZGxlcykgUmVzZXJ2ZWQKKyAgICBLVk1fRkFVTFQoNTQpCisKKyAgICAub3JnIGt2
bV9pYTY0X2l2dCsweDczMDAKKy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vCisvLyAweDczMDAgRW50cnkgNTUgKHNpemUg
MTYgYnVuZGxlcykgUmVzZXJ2ZWQKKyAgICBLVk1fRkFVTFQoNTUpCisKKyAgICAub3JnIGt2bV9p
YTY0X2l2dCsweDc0MDAKKy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vCisvLyAweDc0MDAgRW50cnkgNTYgKHNpemUgMTYg
YnVuZGxlcykgUmVzZXJ2ZWQKKyAgICBLVk1fRkFVTFQoNTYpCisKKyAgICAub3JnIGt2bV9pYTY0
X2l2dCsweDc1MDAKKy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLworLy8gMHg3NTAwIEVudHJ5IDU3IChzaXplIDE2IGJ1
bmRsZXMpIFJlc2VydmVkCisgICAgS1ZNX0ZBVUxUKDU3KQorCisgICAgLm9yZyBrdm1faWE2NF9p
dnQrMHg3NjAwCisvLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8KKy8vIDB4NzYwMCBFbnRyeSA1OCAoc2l6ZSAxNiBidW5k
bGVzKSBSZXNlcnZlZAorICAgIEtWTV9GQVVMVCg1OCkKKworICAgIC5vcmcga3ZtX2lhNjRfaXZ0
KzB4NzcwMAorLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8KKy8vIDB4NzcwMCBFbnRyeSA1OSAoc2l6ZSAxNiBidW5kbGVz
KSBSZXNlcnZlZAorICAgIEtWTV9GQVVMVCg1OSkKKworICAgIC5vcmcga3ZtX2lhNjRfaXZ0KzB4
NzgwMAorLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8KKy8vIDB4NzgwMCBFbnRyeSA2MCAoc2l6ZSAxNiBidW5kbGVzKSBS
ZXNlcnZlZAorICAgIEtWTV9GQVVMVCg2MCkKKworICAgIC5vcmcga3ZtX2lhNjRfaXZ0KzB4Nzkw
MAorLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vCisvLyAweDc5MDAgRW50cnkgNjEgKHNpemUgMTYgYnVuZGxlcykgUmVz
ZXJ2ZWQKKyAgICBLVk1fRkFVTFQoNjEpCisKKyAgICAub3JnIGt2bV9pYTY0X2l2dCsweDdhMDAK
Ky8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLworLy8gMHg3YTAwIEVudHJ5IDYyIChzaXplIDE2IGJ1bmRsZXMpIFJlc2Vy
dmVkCisgICAgS1ZNX0ZBVUxUKDYyKQorCisgICAgLm9yZyBrdm1faWE2NF9pdnQrMHg3YjAwCisv
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8KKy8vIDB4N2IwMCBFbnRyeSA2MyAoc2l6ZSAxNiBidW5kbGVzKSBSZXNlcnZl
ZAorICAgIEtWTV9GQVVMVCg2MykKKworICAgIC5vcmcga3ZtX2lhNjRfaXZ0KzB4N2MwMAorLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8KKy8vIDB4N2MwMCBFbnRyeSA2NCAoc2l6ZSAxNiBidW5kbGVzKSBSZXNlcnZlZAor
ICAgIEtWTV9GQVVMVCg2NCkKKworICAgIC5vcmcga3ZtX2lhNjRfaXZ0KzB4N2QwMAorLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vCisvLyAweDdkMDAgRW50cnkgNjUgKHNpemUgMTYgYnVuZGxlcykgUmVzZXJ2ZWQKKyAg
ICBLVk1fRkFVTFQoNjUpCisKKyAgICAub3JnIGt2bV9pYTY0X2l2dCsweDdlMDAKKy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLworLy8gMHg3ZTAwIEVudHJ5IDY2IChzaXplIDE2IGJ1bmRsZXMpIFJlc2VydmVkCisgICAg
S1ZNX0ZBVUxUKDY2KQorCisgICAgLm9yZyBrdm1faWE2NF9pdnQrMHg3ZjAwCisvLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
LworLy8gMHg3ZjAwIEVudHJ5IDY3IChzaXplIDE2IGJ1bmRsZXMpIFJlc2VydmVkCisgICAgS1ZN
X0ZBVUxUKDY3KQorCisgICAgLm9yZyBrdm1faWE2NF9pdnQrMHg4MDAwCisvLyBUaGVyZSBpcyBu
byBwYXJ0aWN1bGFyIHJlYXNvbiBmb3IgdGhpcyBjb2RlIHRvIGJlIGhlcmUsIG90aGVyIHRoYW4g
dGhhdAorLy8gdGhlcmUgaGFwcGVucyB0byBiZSBzcGFjZSBoZXJlIHRoYXQgd291bGQgZ28gdW51
c2VkIG90aGVyd2lzZS4gIElmIHRoaXMKKy8vIGZhdWx0IGV2ZXIgZ2V0cyAidW5yZXNlcnZlZCIs
IHNpbXBseSBtb3ZlZCB0aGUgZm9sbG93aW5nIGNvZGUgdG8gYSBtb3JlCisvLyBzdWl0YWJsZSBz
cG90Li4uCisKKworRU5UUlkoa3ZtX2R0bGJfbWlzc19kaXNwYXRjaCkKKyAgICBtb3YgcjE5ID0g
MgorICAgIEtWTV9TQVZFX01JTl9XSVRIX0NPVkVSX1IxOQorICAgIGFsbG9jIHIxND1hci5wZnMs
MCwwLDMsMAorICAgIG1vdiBvdXQwPWNyLmlmYQorICAgIG1vdiBvdXQxPXIxNQorICAgIGFkZHMg
cjM9OCxyMiAgICAgICAgICAgICAgICAvLyBzZXQgdXAgc2Vjb25kIGJhc2UgcG9pbnRlcgorICAg
IDs7CisgICAgc3NtIHBzci5pYworICAgIDs7CisgICAgc3Jsei5pICAgICAgICAgICAgICAgICAg
Ly8gZ3VhcmFudGVlIHRoYXQgaW50ZXJydXB0aW9uIGNvbGxlY3Rpb24gaXMgb24KKyAgICA7Owor
ICAgIC8vKHAxNSkgc3NtIHBzci5pICAgICAgICAgICAgICAgLy8gcmVzdG9yZSBwc3IuaQorICAg
IGFkZGwgcjE0PUBncHJlbChpYTY0X2xlYXZlX2h5cGVydmlzb3JfcHJlcGFyZSksZ3AKKyAgICA7
OworICAgIEtWTV9TQVZFX1JFU1QKKyAgICBLVk1fU0FWRV9FWFRSQQorICAgIG1vdiBycD1yMTQK
KyAgICA7OworICAgIGFkZHMgb3V0Mj0xNixyMTIKKyAgICBici5jYWxsLnNwdGsubWFueSBiNj1r
dm1fcGFnZV9mYXVsdAorRU5EKGt2bV9kdGxiX21pc3NfZGlzcGF0Y2gpCisKK0VOVFJZKGt2bV9p
dGxiX21pc3NfZGlzcGF0Y2gpCisKKyAgICBLVk1fU0FWRV9NSU5fV0lUSF9DT1ZFUl9SMTkKKyAg
ICBhbGxvYyByMTQ9YXIucGZzLDAsMCwzLDAKKyAgICBtb3Ygb3V0MD1jci5pZmEKKyAgICBtb3Yg
b3V0MT1yMTUKKyAgICBhZGRzIHIzPTgscjIgICAgICAgICAgICAgICAgLy8gc2V0IHVwIHNlY29u
ZCBiYXNlIHBvaW50ZXIKKyAgICA7OworICAgIHNzbSBwc3IuaWMKKyAgICA7OworICAgIHNybHou
aSAgICAgICAgICAgICAgICAgIC8vIGd1YXJhbnRlZSB0aGF0IGludGVycnVwdGlvbiBjb2xsZWN0
aW9uIGlzIG9uCisgICAgOzsKKyAgICAvLyhwMTUpIHNzbSBwc3IuaSAgICAgICAgICAgICAgIC8v
IHJlc3RvcmUgcHNyLmkKKyAgICBhZGRsIHIxND1AZ3ByZWwoaWE2NF9sZWF2ZV9oeXBlcnZpc29y
KSxncAorICAgIDs7CisgICAgS1ZNX1NBVkVfUkVTVAorICAgIG1vdiBycD1yMTQKKyAgICA7Owor
ICAgIGFkZHMgb3V0Mj0xNixyMTIKKyAgICBici5jYWxsLnNwdGsubWFueSBiNj1rdm1fcGFnZV9m
YXVsdAorRU5EKGt2bV9pdGxiX21pc3NfZGlzcGF0Y2gpCisKK0VOVFJZKGt2bV9kaXNwYXRjaF9y
ZWZsZWN0aW9uKQorICAgIC8qCisgICAgICogSW5wdXQ6CisgICAgICogIHBzci5pYzogb2ZmCisg
ICAgICogIHIxOTogICAgaW50ciB0eXBlIChvZmZzZXQgaW50byBpdnQsIHNlZSBpYTY0X2ludC5o
KQorICAgICAqICByMzE6ICAgIGNvbnRhaW5zIHNhdmVkIHByZWRpY2F0ZXMgKHByKQorICAgICAq
LworICAgIEtWTV9TQVZFX01JTl9XSVRIX0NPVkVSX1IxOQorICAgIGFsbG9jIHIxND1hci5wZnMs
MCwwLDUsMAorICAgIG1vdiBvdXQwPWNyLmlmYQorICAgIG1vdiBvdXQxPWNyLmlzcgorICAgIG1v
diBvdXQyPWNyLmlpbQorICAgIG1vdiBvdXQzPXIxNQorICAgIGFkZHMgcjM9OCxyMiAgICAgICAg
ICAgICAgICAvLyBzZXQgdXAgc2Vjb25kIGJhc2UgcG9pbnRlcgorICAgIDs7CisgICAgc3NtIHBz
ci5pYworICAgIDs7CisgICAgc3Jsei5pICAgICAgICAgICAgICAgICAgLy8gZ3VhcmFudGVlIHRo
YXQgaW50ZXJydXB0aW9uIGNvbGxlY3Rpb24gaXMgb24KKyAgICA7OworICAgIC8vKHAxNSkgc3Nt
IHBzci5pICAgICAgICAgICAgICAgLy8gcmVzdG9yZSBwc3IuaQorICAgIGFkZGwgcjE0PUBncHJl
bChpYTY0X2xlYXZlX2h5cGVydmlzb3IpLGdwCisgICAgOzsKKyAgICBLVk1fU0FWRV9SRVNUCisg
ICAgbW92IHJwPXIxNAorICAgIDs7CisgICAgYWRkcyBvdXQ0PTE2LHIxMgorICAgIGJyLmNhbGwu
c3B0ay5tYW55IGI2PXJlZmxlY3RfaW50ZXJydXB0aW9uCitFTkQoa3ZtX2Rpc3BhdGNoX3JlZmxl
Y3Rpb24pCisKK0VOVFJZKGt2bV9kaXNwYXRjaF92aXJ0dWFsaXphdGlvbl9mYXVsdCkKKyAgICBh
ZGRzIHIxNiA9IFZNTV9WQ1BVX0NBVVNFX09GRlNFVCxyMjEKKyAgICBhZGRzIHIxNyA9IFZNTV9W
Q1BVX09QQ09ERV9PRkZTRVQscjIxCisgICAgOzsKKyAgICBzdDggW3IxNl0gPSByMjQKKyAgICBz
dDggW3IxN10gPSByMjUKKyAgICA7OworICAgIEtWTV9TQVZFX01JTl9XSVRIX0NPVkVSX1IxOQor
ICAgIDs7CisgICAgYWxsb2MgcjE0PWFyLnBmcywwLDAsMiwwIC8vIG5vdyBpdCdzIHNhZmUgKG11
c3QgYmUgZmlyc3QgaW4gaW5zbiBncm91cCEpCisgICAgbW92IG91dDA9cjEzICAgICAgICAvL3Zj
cHUKKyAgICBhZGRzIHIzPTgscjIgICAgICAgICAgICAgICAgLy8gc2V0IHVwIHNlY29uZCBiYXNl
IHBvaW50ZXIKKyAgICA7OworICAgIHNzbSBwc3IuaWMKKyAgICA7OworICAgIHNybHouaSAgICAg
ICAgICAgICAgICAgIC8vIGd1YXJhbnRlZSB0aGF0IGludGVycnVwdGlvbiBjb2xsZWN0aW9uIGlz
IG9uCisgICAgOzsKKyAgICAvLyhwMTUpIHNzbSBwc3IuaSAgICAgICAgICAgICAgIC8vIHJlc3Rv
cmUgcHNyLmkKKyAgICBhZGRsIHIxND1AZ3ByZWwoaWE2NF9sZWF2ZV9oeXBlcnZpc29yX3ByZXBh
cmUpLGdwCisgICAgOzsKKyAgICBLVk1fU0FWRV9SRVNUCisgICAgS1ZNX1NBVkVfRVhUUkEKKyAg
ICBtb3YgcnA9cjE0CisgICAgOzsKKyAgICBhZGRzIG91dDE9MTYsc3AgICAgICAgICAvL3JlZ3MK
KyAgICBici5jYWxsLnNwdGsubWFueSBiNj1rdm1fZW11bGF0ZQorRU5EKGt2bV9kaXNwYXRjaF92
aXJ0dWFsaXphdGlvbl9mYXVsdCkKKworCitFTlRSWShrdm1fZGlzcGF0Y2hfaW50ZXJydXB0KQor
ICAgIEtWTV9TQVZFX01JTl9XSVRIX0NPVkVSX1IxOQkvLyB1c2VzIHIzMTsgZGVmaW5lcyByMiBh
bmQgcjMKKyAgICA7OworICAgIGFsbG9jIHIxND1hci5wZnMsMCwwLDEsMCAvLyBtdXN0IGJlIGZp
cnN0IGluIGFuIGluc24gZ3JvdXAKKyAgICAvL21vdiBvdXQwPWNyLml2cgkJLy8gcGFzcyBjci5p
dnIgYXMgZmlyc3QgYXJnCisgICAgYWRkcyByMz04LHIyCQkvLyBzZXQgdXAgc2Vjb25kIGJhc2Ug
cG9pbnRlciBmb3IgU0FWRV9SRVNUCisgICAgOzsKKyAgICBzc20gcHNyLmljCisgICAgOzsKKyAg
ICBzcmx6LmkKKyAgICA7OworICAgIC8vKHAxNSkgc3NtIHBzci5pCisgICAgYWRkbCByMTQ9QGdw
cmVsKGlhNjRfbGVhdmVfaHlwZXJ2aXNvciksZ3AKKyAgICA7OworICAgIEtWTV9TQVZFX1JFU1QK
KyAgICBtb3YgcnA9cjE0CisgICAgOzsKKyAgICBtb3Ygb3V0MD1yMTMJCS8vIHBhc3MgcG9pbnRl
ciB0byBwdF9yZWdzIGFzIHNlY29uZCBhcmcKKyAgICBici5jYWxsLnNwdGsubWFueSBiNj1rdm1f
aWE2NF9oYW5kbGVfaXJxCitFTkQoa3ZtX2Rpc3BhdGNoX2ludGVycnVwdCkKKworCisKKworR0xP
QkFMX0VOVFJZKGlhNjRfbGVhdmVfbmVzdGVkKQorCXJzbSBwc3IuaQorCTs7CisJYWRkcyByMjE9
UFQoUFIpKzE2LHIxMgorCTs7CisJbGZldGNoIFtyMjFdLFBUKENSX0lQU1IpLVBUKFBSKQorCWFk
ZHMgcjI9UFQoQjYpKzE2LHIxMgorCWFkZHMgcjM9UFQoUjE2KSsxNixyMTIKKwk7OworCWxmZXRj
aCBbcjIxXQorCWxkOCByMjg9W3IyXSw4CQkvLyBsb2FkIGI2CisJYWRkcyByMjk9UFQoUjI0KSsx
NixyMTIKKworCWxkOC5maWxsIHIxNj1bcjNdCisJYWRkcyByMz1QVChBUl9DU0QpLVBUKFIxNiks
cjMKKwlhZGRzIHIzMD1QVChBUl9DQ1YpKzE2LHIxMgorCTs7CisJbGQ4LmZpbGwgcjI0PVtyMjld
CisJbGQ4IHIxNT1bcjMwXQkJLy8gbG9hZCBhci5jY3YKKwk7OworCWxkOCByMjk9W3IyXSwxNgkJ
Ly8gbG9hZCBiNworCWxkOCByMzA9W3IzXSwxNgkJLy8gbG9hZCBhci5jc2QKKwk7OworCWxkOCBy
MzE9W3IyXSwxNgkJLy8gbG9hZCBhci5zc2QKKwlsZDguZmlsbCByOD1bcjNdLDE2CisJOzsKKwls
ZDguZmlsbCByOT1bcjJdLDE2CisJbGQ4LmZpbGwgcjEwPVtyM10sUFQoUjE3KS1QVChSMTApCisJ
OzsKKwlsZDguZmlsbCByMTE9W3IyXSxQVChSMTgpLVBUKFIxMSkKKwlsZDguZmlsbCByMTc9W3Iz
XSwxNgorCTs7CisJbGQ4LmZpbGwgcjE4PVtyMl0sMTYKKwlsZDguZmlsbCByMTk9W3IzXSwxNgor
CTs7CisJbGQ4LmZpbGwgcjIwPVtyMl0sMTYKKwlsZDguZmlsbCByMjE9W3IzXSwxNgorCW1vdiBh
ci5jc2Q9cjMwCisJbW92IGFyLnNzZD1yMzEKKwk7OworCXJzbSBwc3IuaSB8IHBzci5pYworCS8v
IGluaXRpYXRlIHR1cm5pbmcgb2ZmIG9mIGludGVycnVwdCBhbmQgaW50ZXJydXB0aW9uIGNvbGxl
Y3Rpb24KKwlpbnZhbGEJCQkvLyBpbnZhbGlkYXRlIEFMQVQKKwk7OworCXNybHouaQorCTs7CisJ
bGQ4LmZpbGwgcjIyPVtyMl0sMjQKKwlsZDguZmlsbCByMjM9W3IzXSwyNAorCW1vdiBiNj1yMjgK
Kwk7OworCWxkOC5maWxsIHIyNT1bcjJdLDE2CisJbGQ4LmZpbGwgcjI2PVtyM10sMTYKKwltb3Yg
Yjc9cjI5CisJOzsKKwlsZDguZmlsbCByMjc9W3IyXSwxNgorCWxkOC5maWxsIHIyOD1bcjNdLDE2
CisJOzsKKwlsZDguZmlsbCByMjk9W3IyXSwxNgorCWxkOC5maWxsIHIzMD1bcjNdLDI0CisJOzsK
KwlsZDguZmlsbCByMzE9W3IyXSxQVChGOSktUFQoUjMxKQorCWFkZHMgcjM9UFQoRjEwKS1QVChG
NikscjMKKwk7OworCWxkZi5maWxsIGY5PVtyMl0sUFQoRjYpLVBUKEY5KQorCWxkZi5maWxsIGYx
MD1bcjNdLFBUKEY4KS1QVChGMTApCisJOzsKKwlsZGYuZmlsbCBmNj1bcjJdLFBUKEY3KS1QVChG
NikKKwk7OworCWxkZi5maWxsIGY3PVtyMl0sUFQoRjExKS1QVChGNykKKwlsZGYuZmlsbCBmOD1b
cjNdLDMyCisJOzsKKwlzcmx6LmkJCQkvLyBlbnN1cmUgaW50ZXJydXB0aW9uIGNvbGxlY3Rpb24g
aXMgb2ZmCisJbW92IGFyLmNjdj1yMTUKKwk7OworCWJzdy4wCS8vIHN3aXRjaCBiYWNrIHRvIGJh
bmsgMCAobm8gc3RvcCBiaXQgcmVxdWlyZWQgYmVmb3JlaGFuZC4uLikKKwk7OworCWxkZi5maWxs
IGYxMT1bcjJdCisvLwltb3YgcjE4PXIxMworLy8gICAgbW92IHIyMT1yMTMKKwlhZGRzIHIxNj1Q
VChDUl9JUFNSKSsxNixyMTIKKwlhZGRzIHIxNz1QVChDUl9JSVApKzE2LHIxMgorCTs7CisJbGQ4
IHIyOT1bcjE2XSwxNgkvLyBsb2FkIGNyLmlwc3IKKwlsZDggcjI4PVtyMTddLDE2CS8vIGxvYWQg
Y3IuaWlwCisJOzsKKwlsZDggcjMwPVtyMTZdLDE2CS8vIGxvYWQgY3IuaWZzCisJbGQ4IHIyNT1b
cjE3XSwxNgkvLyBsb2FkIGFyLnVuYXQKKwk7OworCWxkOCByMjY9W3IxNl0sMTYJLy8gbG9hZCBh
ci5wZnMKKwlsZDggcjI3PVtyMTddLDE2CS8vIGxvYWQgYXIucnNjCisJY21wLmVxIHA5LHAwPXIw
LHIwCisJLy8gc2V0IHA5IHRvIGluZGljYXRlIHRoYXQgd2Ugc2hvdWxkIHJlc3RvcmUgY3IuaWZz
CisJOzsKKwlsZDggcjI0PVtyMTZdLDE2CS8vIGxvYWQgYXIucm5hdCAobWF5IGJlIGdhcmJhZ2Up
CisJbGQ4IHIyMz1bcjE3XSwxNi8vIGxvYWQgYXIuYnNwc3RvcmUgKG1heSBiZSBnYXJiYWdlKQor
CTs7CisJbGQ4IHIzMT1bcjE2XSwxNgkvLyBsb2FkIHByZWRpY2F0ZXMKKwlsZDggcjIyPVtyMTdd
LDE2CS8vIGxvYWQgYjAKKwk7OworCWxkOCByMTk9W3IxNl0sMTYJLy8gbG9hZCBhci5yc2MgdmFs
dWUgZm9yICJsb2FkcnMiCisJbGQ4LmZpbGwgcjE9W3IxN10sMTYJLy8gbG9hZCByMQorCTs7CisJ
bGQ4LmZpbGwgcjEyPVtyMTZdLDE2CisJbGQ4LmZpbGwgcjEzPVtyMTddLDE2CisJOzsKKwlsZDgg
cjIwPVtyMTZdLDE2CS8vIGFyLmZwc3IKKwlsZDguZmlsbCByMTU9W3IxN10sMTYKKwk7OworCWxk
OC5maWxsIHIxND1bcjE2XSwxNgorCWxkOC5maWxsIHIyPVtyMTddCisJOzsKKwlsZDguZmlsbCBy
Mz1bcjE2XQorCTs7CisJbW92IHIxNj1hci5ic3AJCS8vIGdldCBleGlzdGluZyBiYWNraW5nIHN0
b3JlIHBvaW50ZXIKKwk7OworCW1vdiBiMD1yMjIKKwltb3YgYXIucGZzPXIyNgorCW1vdiBjci5p
ZnM9cjMwCisJbW92IGNyLmlwc3I9cjI5CisJbW92IGFyLmZwc3I9cjIwCisJbW92IGNyLmlpcD1y
MjgKKwk7OworCW1vdiBhci5yc2M9cjI3CisJbW92IGFyLnVuYXQ9cjI1CisJbW92IHByPXIzMSwt
MQorCXJmaQorRU5EKGlhNjRfbGVhdmVfbmVzdGVkKQorCisKKworR0xPQkFMX0VOVFJZKGlhNjRf
bGVhdmVfaHlwZXJ2aXNvcl9wcmVwYXJlKQorICAgIC8qCisgICAgICogd29yay5uZWVkX3Jlc2No
ZWQgZXRjLiBtdXN0bid0IGdldCBjaGFuZ2VkCisgICAgICpieSB0aGlzIENQVSBiZWZvcmUgaXQg
cmV0dXJucyB0bworICAgIDs7CisgICAgICogdXNlci0gb3IgZnN5cy1tb2RlLCBoZW5jZSB3ZSBk
aXNhYmxlIGludGVycnVwdHMgZWFybHkgb246CisgICAgICovCisgICAgYWRkcyByMiA9IFBUKFI0
KSsxNixyMTIKKyAgICBhZGRzIHIzID0gUFQoUjUpKzE2LHIxMgorICAgIGFkZHMgcjggPSBQVChF
TUxfVU5BVCkrMTYscjEyCisgICAgOzsKKyAgICBsZDggcjggPSBbcjhdCisgICAgOzsKKyAgICBt
b3YgYXIudW5hdD1yOAorICAgIDs7CisgICAgbGQ4LmZpbGwgcjQ9W3IyXSwxNiAgICAvL2xvYWQg
cjQKKyAgICBsZDguZmlsbCByNT1bcjNdLDE2ICAgIC8vbG9hZCByNQorICAgIDs7CisgICAgbGQ4
LmZpbGwgcjY9W3IyXSAgICAvL2xvYWQgcjYKKyAgICBsZDguZmlsbCByNz1bcjNdICAgIC8vbG9h
ZCByNworICAgIDs7CitFTkQoaWE2NF9sZWF2ZV9oeXBlcnZpc29yX3ByZXBhcmUpCisvL2ZhbGwg
dGhyb3VnaAorR0xPQkFMX0VOVFJZKGlhNjRfbGVhdmVfaHlwZXJ2aXNvcikKKyAgICByc20gcHNy
LmkKKyAgICA7OworICAgIGJyLmNhbGwuc3B0ay5tYW55IGIwPWxlYXZlX2h5cGVydmlzb3JfdGFp
bAorICAgIDs7CisgICAgYWRkcyByMjA9UFQoUFIpKzE2LHIxMgorICAgIGFkZHMgcjg9UFQoRU1M
X1VOQVQpKzE2LHIxMgorICAgIDs7CisgICAgbGQ4IHI4PVtyOF0KKyAgICA7OworICAgIG1vdiBh
ci51bmF0PXI4CisgICAgOzsKKyAgICBsZmV0Y2ggW3IyMF0sUFQoQ1JfSVBTUiktUFQoUFIpCisg
ICAgYWRkcyByMiA9IFBUKEI2KSsxNixyMTIKKyAgICBhZGRzIHIzID0gUFQoQjcpKzE2LHIxMgor
ICAgIDs7CisgICAgbGZldGNoIFtyMjBdCisgICAgOzsKKyAgICBsZDggcjI0PVtyMl0sMTYgICAg
ICAgIC8qIEI2ICovCisgICAgbGQ4IHIyNT1bcjNdLDE2ICAgICAgICAvKiBCNyAqLworICAgIDs7
CisgICAgbGQ4IHIyNj1bcjJdLDE2ICAgICAgICAvKiBhcl9jc2QgKi8KKyAgICBsZDggcjI3PVty
M10sMTYgICAgICAgIC8qIGFyX3NzZCAqLworICAgIG1vdiBiNiA9IHIyNAorICAgIDs7CisgICAg
bGQ4LmZpbGwgcjg9W3IyXSwxNgorICAgIGxkOC5maWxsIHI5PVtyM10sMTYKKyAgICBtb3YgYjcg
PSByMjUKKyAgICA7OworICAgIG1vdiBhci5jc2QgPSByMjYKKyAgICBtb3YgYXIuc3NkID0gcjI3
CisgICAgOzsKKyAgICBsZDguZmlsbCByMTA9W3IyXSxQVChSMTUpLVBUKFIxMCkKKyAgICBsZDgu
ZmlsbCByMTE9W3IzXSxQVChSMTQpLVBUKFIxMSkKKyAgICA7OworICAgIGxkOC5maWxsIHIxNT1b
cjJdLFBUKFIxNiktUFQoUjE1KQorICAgIGxkOC5maWxsIHIxND1bcjNdLFBUKFIxNyktUFQoUjE0
KQorICAgIDs7CisgICAgbGQ4LmZpbGwgcjE2PVtyMl0sMTYKKyAgICBsZDguZmlsbCByMTc9W3Iz
XSwxNgorICAgIDs7CisgICAgbGQ4LmZpbGwgcjE4PVtyMl0sMTYKKyAgICBsZDguZmlsbCByMTk9
W3IzXSwxNgorICAgIDs7CisgICAgbGQ4LmZpbGwgcjIwPVtyMl0sMTYKKyAgICBsZDguZmlsbCBy
MjE9W3IzXSwxNgorICAgIDs7CisgICAgbGQ4LmZpbGwgcjIyPVtyMl0sMTYKKyAgICBsZDguZmls
bCByMjM9W3IzXSwxNgorICAgIDs7CisgICAgbGQ4LmZpbGwgcjI0PVtyMl0sMTYKKyAgICBsZDgu
ZmlsbCByMjU9W3IzXSwxNgorICAgIDs7CisgICAgbGQ4LmZpbGwgcjI2PVtyMl0sMTYKKyAgICBs
ZDguZmlsbCByMjc9W3IzXSwxNgorICAgIDs7CisgICAgbGQ4LmZpbGwgcjI4PVtyMl0sMTYKKyAg
ICBsZDguZmlsbCByMjk9W3IzXSwxNgorICAgIDs7CisgICAgbGQ4LmZpbGwgcjMwPVtyMl0sUFQo
RjYpLVBUKFIzMCkKKyAgICBsZDguZmlsbCByMzE9W3IzXSxQVChGNyktUFQoUjMxKQorICAgIDs7
CisgICAgcnNtIHBzci5pIHwgcHNyLmljCisgICAgLy8gaW5pdGlhdGUgdHVybmluZyBvZmYgb2Yg
aW50ZXJydXB0IGFuZCBpbnRlcnJ1cHRpb24gY29sbGVjdGlvbgorICAgIGludmFsYSAgICAgICAg
ICAvLyBpbnZhbGlkYXRlIEFMQVQKKyAgICA7OworICAgIHNybHouaSAgICAgICAgICAvLyBlbnN1
cmUgaW50ZXJydXB0aW9uIGNvbGxlY3Rpb24gaXMgb2ZmCisgICAgOzsKKyAgICBic3cuMAorICAg
IDs7CisgICAgYWRkcyByMTYgPSBQVChDUl9JUFNSKSsxNixyMTIKKyAgICBhZGRzIHIxNyA9IFBU
KENSX0lJUCkrMTYscjEyCisgICAgbW92IHIyMT1yMTMJCS8vIGdldCBjdXJyZW50CisgICAgOzsK
KyAgICBsZDggcjMxPVtyMTZdLDE2ICAgIC8vIGxvYWQgY3IuaXBzcgorICAgIGxkOCByMzA9W3Ix
N10sMTYgICAgLy8gbG9hZCBjci5paXAKKyAgICA7OworICAgIGxkOCByMjk9W3IxNl0sMTYgICAg
Ly8gbG9hZCBjci5pZnMKKyAgICBsZDggcjI4PVtyMTddLDE2ICAgIC8vIGxvYWQgYXIudW5hdAor
ICAgIDs7CisgICAgbGQ4IHIyNz1bcjE2XSwxNiAgICAvLyBsb2FkIGFyLnBmcworICAgIGxkOCBy
MjY9W3IxN10sMTYgICAgLy8gbG9hZCBhci5yc2MKKyAgICA7OworICAgIGxkOCByMjU9W3IxNl0s
MTYgICAgLy8gbG9hZCBhci5ybmF0CisgICAgbGQ4IHIyND1bcjE3XSwxNiAgICAvLyBsb2FkIGFy
LmJzcHN0b3JlCisgICAgOzsKKyAgICBsZDggcjIzPVtyMTZdLDE2ICAgIC8vIGxvYWQgcHJlZGlj
YXRlcworICAgIGxkOCByMjI9W3IxN10sMTYgICAgLy8gbG9hZCBiMAorICAgIDs7CisgICAgbGQ4
IHIyMD1bcjE2XSwxNiAgICAvLyBsb2FkIGFyLnJzYyB2YWx1ZSBmb3IgImxvYWRycyIKKyAgICBs
ZDguZmlsbCByMT1bcjE3XSwxNiAgICAvL2xvYWQgcjEKKyAgICA7OworICAgIGxkOC5maWxsIHIx
Mj1bcjE2XSwxNiAgICAvL2xvYWQgcjEyCisgICAgbGQ4LmZpbGwgcjEzPVtyMTddLFBUKFIyKS1Q
VChSMTMpICAgIC8vbG9hZCByMTMKKyAgICA7OworICAgIGxkOCByMTk9W3IxNl0sUFQoUjMpLVBU
KEFSX0ZQU1IpICAgIC8vbG9hZCBhcl9mcHNyCisgICAgbGQ4LmZpbGwgcjI9W3IxN10sUFQoQVJf
Q0NWKS1QVChSMikgICAgLy9sb2FkIHIyCisgICAgOzsKKyAgICBsZDguZmlsbCByMz1bcjE2XQkv
L2xvYWQgcjMKKyAgICBsZDggcjE4PVtyMTddCS8vbG9hZCBhcl9jY3YKKyAgICA7OworICAgIG1v
diBhci5mcHNyPXIxOQorICAgIG1vdiBhci5jY3Y9cjE4CisgICAgc2hyLnUgcjE4PXIyMCwxNgor
ICAgIDs7Citrdm1fcmJzX3N3aXRjaDoKKyAgICBtb3YgcjE5PTk2CisKK2t2bV9kb250X3ByZXNl
cnZlX2N1cnJlbnRfZnJhbWU6CisvKgorICAgICogVG8gcHJldmVudCBsZWFraW5nIGJpdHMgYmV0
d2VlbiB0aGUgaHlwZXJ2aXNvciBhbmQgZ3Vlc3QgZG9tYWluLAorICAgICogd2UgbXVzdCBjbGVh
ciB0aGUgc3RhY2tlZCByZWdpc3RlcnMgaW4gdGhlICJpbnZhbGlkIiBwYXJ0aXRpb24gaGVyZS4K
KyAgICAqIDUgcmVnaXN0ZXJzL2N5Y2xlIG9uIE1jS2lubGV5KS4KKyAgICAqLworIyAgIGRlZmlu
ZSBwUmVjdXJzZQlwNgorIyAgIGRlZmluZSBwUmV0dXJuCXA3CisjICAgZGVmaW5lIE5yZWdzCTE0
CisKKyAgICBhbGxvYyBsb2MwPWFyLnBmcywyLE5yZWdzLTIsMiwwCisgICAgc2hyLnUgbG9jMT1y
MTgsOQkJLy8gUk5hVHNsb3RzIDw9IGZsb29yKGRpcnR5U2l6ZSAvICg2NCo4KSkKKyAgICBzdWIg
cjE5PXIxOSxyMTgJCS8vIHIxOSA9IChwaHlzU3RhY2tlZFNpemUgKyA4KSAtIGRpcnR5U2l6ZQor
ICAgIDs7CisgICAgbW92IGFyLnJzYz1yMjAJCS8vIGxvYWQgYXIucnNjIHRvIGJlIHVzZWQgZm9y
ICJsb2FkcnMiCisgICAgc2hsYWRkIGluMD1sb2MxLDMscjE5CisgICAgbW92IGluMT0wCisgICAg
OzsKKyAgICBURVhUX0FMSUdOKDMyKQora3ZtX3JzZV9jbGVhcl9pbnZhbGlkOgorICAgIGFsbG9j
IGxvYzA9YXIucGZzLDIsTnJlZ3MtMiwyLDAKKyAgICBjbXAubHQgcFJlY3Vyc2UscDA9TnJlZ3Mq
OCxpbjAKKyAgICAvLyBpZiBtb3JlIHRoYW4gTnJlZ3MgcmVncyBsZWZ0IHRvIGNsZWFyLCAocmUp
Y3Vyc2UKKyAgICBhZGQgb3V0MD0tTnJlZ3MqOCxpbjAKKyAgICBhZGQgb3V0MT0xLGluMQkJLy8g
aW5jcmVtZW50IHJlY3Vyc2lvbiBjb3VudAorICAgIG1vdiBsb2MxPTAKKyAgICBtb3YgbG9jMj0w
CisgICAgOzsKKyAgICBtb3YgbG9jMz0wCisgICAgbW92IGxvYzQ9MAorICAgIG1vdiBsb2M1PTAK
KyAgICBtb3YgbG9jNj0wCisgICAgbW92IGxvYzc9MAorKHBSZWN1cnNlKSBici5jYWxsLmRwdGsu
ZmV3IGIwPWt2bV9yc2VfY2xlYXJfaW52YWxpZAorICAgIDs7CisgICAgbW92IGxvYzg9MAorICAg
IG1vdiBsb2M5PTAKKyAgICBjbXAubmUgcFJldHVybixwMD1yMCxpbjEKKyAgICAvLyBpZiByZWN1
cnNpb24gY291bnQgIT0gMCwgd2UgbmVlZCB0byBkbyBhIGJyLnJldAorICAgIG1vdiBsb2MxMD0w
CisgICAgbW92IGxvYzExPTAKKyhwUmV0dXJuKSBici5yZXQuZHB0ay5tYW55IGIwCisKKyMJdW5k
ZWYgcFJlY3Vyc2UKKyMJdW5kZWYgcFJldHVybgorCisvLyBsb2FkcnMgaGFzIGFscmVhZHkgYmVl
biBzaGlmdGVkCisgICAgYWxsb2MgcjE2PWFyLnBmcywwLDAsMCwwICAgIC8vIGRyb3AgY3VycmVu
dCByZWdpc3RlciBmcmFtZQorICAgIDs7CisgICAgbG9hZHJzCisgICAgOzsKKyAgICBtb3YgYXIu
YnNwc3RvcmU9cjI0CisgICAgOzsKKyAgICBtb3YgYXIudW5hdD1yMjgKKyAgICBtb3YgYXIucm5h
dD1yMjUKKyAgICBtb3YgYXIucnNjPXIyNgorICAgIDs7CisgICAgbW92IGNyLmlwc3I9cjMxCisg
ICAgbW92IGNyLmlpcD1yMzAKKyAgICBtb3YgY3IuaWZzPXIyOQorICAgIG1vdiBhci5wZnM9cjI3
CisgICAgYWRkcyByMTg9Vk1NX1ZQRF9CQVNFX09GRlNFVCxyMjEKKyAgICA7OworICAgIGxkOCBy
MTg9W3IxOF0gICAvL3ZwZAorICAgIGFkZHMgcjE3PVZNTV9WQ1BVX0lTUl9PRkZTRVQscjIxCisg
ICAgOzsKKyAgICBsZDggcjE3PVtyMTddCisgICAgYWRkcyByMTk9Vk1NX1ZQRF9WUFNSX09GRlNF
VCxyMTgKKyAgICA7OworICAgIGxkOCByMTk9W3IxOV0gICAgICAgIC8vdnBzcgorICAgIGFkZHMg
cjIwPVZNTV9WQ1BVX1ZTQV9CQVNFX09GRlNFVCxyMjEKKyAgICA7OworICAgIGxkOCByMjA9W3Iy
MF0KKyAgICA7OworLy92c2Ffc3luY193cml0ZV9zdGFydAorICAgIG1vdiByMjU9cjE4CisgICAg
YWRkcyByMTY9IFZNTV9WQ1BVX0dQX09GRlNFVCxyMjEKKyAgICA7OworICAgIGxkOCByMTY9IFty
MTZdIC8vIFB1dCBncCBpbiByMjQKKyAgICBtb3ZsIHIyND1AZ3ByZWwoaWE2NF92bW1fZW50cnkp
ICAvLyBjYWxjdWxhdGUgcmV0dXJuIGFkZHJlc3MKKyAgICA7OworICAgIGFkZCAgcjI0PXIyNCxy
MTYKKyAgICA7OworICAgIGFkZCByMTY9UEFMX1ZQU19TWU5DX1dSSVRFLHIyMAorICAgIDs7Cisg
ICAgbW92IGIwPXIxNgorICAgIGJyLmNvbmQuc3B0ayBiMCAgICAgICAgIC8vIGNhbGwgdGhlIHNl
cnZpY2UKKyAgICA7OworRU5EKGlhNjRfbGVhdmVfaHlwZXJ2aXNvcikKKy8vIGZhbGwgdGhyb3Vn
aAorR0xPQkFMX0VOVFJZKGlhNjRfdm1tX2VudHJ5KQorLyoKKyAqICBtdXN0IGJlIGF0IGJhbmsg
MAorICogIHBhcmFtZXRlcjoKKyAqICByMTc6Y3IuaXNyCisgKiAgcjE4OnZwZAorICogIHIxOTp2
cHNyCisgKiAgcjIwOl9fdnNhX2Jhc2UKKyAqICByMjI6YjAKKyAqICByMjM6cHJlZGljYXRlCisg
Ki8KKyAgICBtb3YgcjI0PXIyMgorICAgIG1vdiByMjU9cjE4CisgICAgdGJpdC5ueiBwMSxwMiA9
IHIxOSxJQTY0X1BTUl9JQ19CSVQgICAgICAgIC8vIHAxPXZwc3IuaWMKKyAgICA7OworICAgIChw
MSkgYWRkIHIyOT1QQUxfVlBTX1JFU1VNRV9OT1JNQUwscjIwCisgICAgKHAxKSBici5zcHRrLm1h
bnkgaWE2NF92bW1fZW50cnlfb3V0CisgICAgOzsKKyAgICB0Yml0Lm56IHAxLHAyID0gcjE3LElB
NjRfSVNSX0lSX0JJVAkJLy9wMT1jci5pc3IuaXIKKyAgICA7OworICAgIChwMSkgYWRkIHIyOT1Q
QUxfVlBTX1JFU1VNRV9OT1JNQUwscjIwCisgICAgKHAyKSBhZGQgcjI5PVBBTF9WUFNfUkVTVU1F
X0hBTkRMRVIscjIwCisgICAgKHAyKSBsZDggcjI2PVtyMjVdCisgICAgOzsKK2lhNjRfdm1tX2Vu
dHJ5X291dDoKKyAgICBtb3YgcHI9cjIzLC0yCisgICAgbW92IGIwPXIyOQorICAgIDs7CisgICAg
YnIuY29uZC5zcHRrIGIwICAgICAgICAgICAgIC8vIGNhbGwgcGFsIHNlcnZpY2UKK0VORChpYTY0
X3ZtbV9lbnRyeSkKKworCisKKy8qCisgKiBleHRlcm4gdTY0IGlhNjRfY2FsbF92c2EodTY0IHBy
b2MsIHU2NCBhcmcxLCB1NjQgYXJnMiwKKyAqICAgICAgICAgICAgICAgICAgdTY0IGFyZzMsIHU2
NCBhcmc0LCB1NjQgYXJnNSwKKyAqICAgICAgICAgICAgICAgICAgdTY0IGFyZzYsIHU2NCBhcmc3
KTsKKyAqCisgKiBYWFg6IFRoZSBjdXJyZW50bHkgZGVmaW5lZCBzZXJ2aWNlcyB1c2Ugb25seSA0
IGFyZ3MgYXQgdGhlIG1heC4gVGhlCisgKiAgcmVzdCBhcmUgbm90IGNvbnN1bWVkLgorICovCitH
TE9CQUxfRU5UUlkoaWE2NF9jYWxsX3ZzYSkKKyAgICAucmVnc3RrIDQsNCwwLDAKKworcnBzYXZl
ICA9ICAgbG9jMAorcGZzc2F2ZSA9ICAgbG9jMQorcHNyc2F2ZSA9ICAgbG9jMgorZW50cnkgICA9
ICAgbG9jMworaG9zdHJldCA9ICAgcjI0CisKKyAgICBhbGxvYyAgIHBmc3NhdmU9YXIucGZzLDQs
NCwwLDAKKyAgICBtb3YgcnBzYXZlPXJwCisgICAgYWRkcyBlbnRyeT1WTU1fVkNQVV9WU0FfQkFT
RV9PRkZTRVQsIHIxMworICAgIDs7CisgICAgbGQ4IGVudHJ5PVtlbnRyeV0KKzE6ICBtb3YgaG9z
dHJldD1pcAorICAgIG1vdiByMjU9aW4xICAgICAgICAgLy8gY29weSBhcmd1bWVudHMKKyAgICBt
b3YgcjI2PWluMgorICAgIG1vdiByMjc9aW4zCisgICAgbW92IHBzcnNhdmU9cHNyCisgICAgOzsK
KyAgICB0Yml0Lm56IHA2LHAwPXBzcnNhdmUsMTQgICAgLy8gSUE2NF9QU1JfSQorICAgIHRiaXQu
bnogcDcscDA9cHNyc2F2ZSwxMyAgICAvLyBJQTY0X1BTUl9JQworICAgIDs7CisgICAgYWRkIGhv
c3RyZXQ9MmYtMWIsaG9zdHJldCAgIC8vIGNhbGN1bGF0ZSByZXR1cm4gYWRkcmVzcworICAgIGFk
ZCBlbnRyeT1lbnRyeSxpbjAKKyAgICA7OworICAgIHJzbSBwc3IuaSB8IHBzci5pYworICAgIDs7
CisgICAgc3Jsei5pCisgICAgbW92IGI2PWVudHJ5CisgICAgYnIuY29uZC5zcHRrIGI2ICAgICAg
ICAgLy8gY2FsbCB0aGUgc2VydmljZQorMjoKKyAgICAvLyBBcmNoaXRlY3R1cmFsIHNlcXVlbmNl
IGZvciBlbmFibGluZyBpbnRlcnJ1cHRzIGlmIG5lY2Vzc2FyeQorKHA3KSAgICBzc20gcHNyLmlj
CisgICAgOzsKKyhwNykgICAgc3Jsei5pCisgICAgOzsKKy8vKHA2KSAgICBzc20gcHNyLmkKKyAg
ICA7OworICAgIG1vdiBycD1ycHNhdmUKKyAgICBtb3YgYXIucGZzPXBmc3NhdmUKKyAgICBtb3Yg
cjg9cjMxCisgICAgOzsKKyAgICBzcmx6LmQKKyAgICBici5yZXQuc3B0ayBycAorCitFTkQoaWE2
NF9jYWxsX3ZzYSkKKworI2RlZmluZSAgSU5JVF9CU1BTVE9SRSAgKCg0PDwzMCktKDEyPDwyMCkt
MHgxMDApCisKK0dMT0JBTF9FTlRSWSh2bW1fcmVzZXRfZW50cnkpCisgICAgLy9zZXQgdXAgaXBz
ciwgaWlwLCB2cGQudnBzciwgZGNyCisgICAgLy8gRm9yIElQU1I6IGl0L2R0L3J0PTEsIGkvaWM9
MSwgc2k9MSwgdm0vYm49MQorICAgIC8vIEZvciBEQ1I6IGFsbCBiaXRzIDAKKyAgICBhZGRzIHIx
ND0tVk1NX1BUX1JFR1NfU0laRSwgcjEyCisgICAgOzsKKyAgICBtb3ZsIHI2PTB4NTAxMDA4ODI2
MDAwICAgICAgLy8gSVBTUiBkdC9ydC9pdDoxO2kvaWM6MSwgc2k6MSwgdm0vYm46MQorICAgIG1v
dmwgcjEwPTB4ODAwMDAwMDAwMDAwMDAwMAorICAgIGFkZHMgcjE2PVBUKENSX0lJUCksIHIxNAor
ICAgIGFkZHMgcjIwPVBUKFIxKSwgcjE0CisgICAgOzsKKyAgICByc20gcHNyLmljIHwgcHNyLmkK
KyAgICA7OworICAgIHNybHouaQorICAgIDs7CisgICAgYnN3LjAKKyAgICA7OworICAgIG1vdiBy
MjEgPXIxMworICAgIDs7CisgICAgYnN3LjEKKyAgICA7OworICAgIG1vdiBhci5yc2MgPSAwCisg
ICAgOzsKKyAgICBmbHVzaHJzCisgICAgOzsKKyAgICBtb3YgYXIuYnNwc3RvcmUgPSAwCisgICAg
Ly8gY2xlYXIgQlNQU1RPUkUKKyAgICA7OworICAgIG1vdiBjci5pcHNyPXI2CisgICAgbW92IGNy
Lmlmcz1yMTAKKyAgICBsZDggcjQgPSBbcjE2XSAvLyBTZXQgaW5pdCBpaXAgZm9yIGZpcnN0IHJ1
bi4KKyAgICBsZDggcjEgPSBbcjIwXQorICAgIDs7CisgICAgbW92IGNyLmlpcD1yNAorICAgIDs7
CisgICAgYWRkcyByMTY9Vk1NX1ZQRF9CQVNFX09GRlNFVCxyMTMKKyAgICBhZGRzIHIyMD1WTU1f
VkNQVV9WU0FfQkFTRV9PRkZTRVQscjEzCisgICAgOzsKKyAgICBsZDggcjE4PVtyMTZdCisgICAg
bGQ4IHIyMD1bcjIwXQorICAgIDs7CisgICAgYWRkcyByMTk9Vk1NX1ZQRF9WUFNSX09GRlNFVCxy
MTgKKyAgICA7OworICAgIGxkOCByMTk9W3IxOV0KKyAgICBtb3YgcjE3PXIwCisgICAgbW92IHIy
Mj1yMAorICAgIG1vdiByMjM9cjAKKyAgICBici5jb25kLnNwdGsgaWE2NF92bW1fZW50cnkKKyAg
ICBici5yZXQuc3B0ayAgYjAKK0VORCh2bW1fcmVzZXRfZW50cnkpCisKLS0gCjEuNS4yCgo=

------_=_NextPart_001_01C89309.2AB1D75F--
