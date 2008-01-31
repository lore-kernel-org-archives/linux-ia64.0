From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Thu, 31 Jan 2008 10:29:53 +0000
Subject: [PATCH][12]Add interruption vector table for vmm.
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDCD31FCF@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C863F4.37DD060F"
List-Id: <linux-ia64.vger.kernel.org>
To: Avi Kivity <avi-atKUWr5tajBWk0Htik3J/w@public.gmane.org>, "Luck, Tony" <tony.luck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, "Xu, Anthony" <anthony.xu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, "Zhang, Xiantao" <xiantao.zhang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: kvm-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kvm-ia64-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C863F4.37DD060F
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

From: Zhang Xiantao <xiantao.zhang@intel.com>
Date: Tue, 29 Jan 2008 14:30:36 +0800
Subject: [PATCH] kvm/ia64: Add interruption vector table for vmm.

vmm_ivt.S includes an ivt for vmm use.
Signed-off-by: Anthony Xu <anthony.xu@intel.com>
Signed-off-by: Xiantao Zhang <xiantao.zhang@intel.com>
---
 arch/ia64/kvm/vmm_ivt.S | 1423
+++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 1423 insertions(+), 0 deletions(-)
 create mode 100644 arch/ia64/kvm/vmm_ivt.S

diff --git a/arch/ia64/kvm/vmm_ivt.S b/arch/ia64/kvm/vmm_ivt.S
new file mode 100644
index 0000000..5ca8651
--- /dev/null
+++ b/arch/ia64/kvm/vmm_ivt.S
@@ -0,0 +1,1423 @@
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
+    srlz.d
+    mov b6=3Dentry
+    br.cond.sptk b6         // call the service
+2:
+    // Architectural sequence for enabling interrupts if necessary
+(p7)    ssm psr.ic
+    ;;
+(p7)    srlz.d
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
+    srlz.d
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
1.5.1

------_=_NextPart_001_01C863F4.37DD060F
Content-Type: application/octet-stream;
	name="0012-kvm-ia64-Add-interruption-vector-table-for-vmm.patch"
Content-Transfer-Encoding: base64
Content-Description: 0012-kvm-ia64-Add-interruption-vector-table-for-vmm.patch
Content-Disposition: attachment;
	filename="0012-kvm-ia64-Add-interruption-vector-table-for-vmm.patch"

RnJvbSAzZjZjMjk2ZTMxMzFlZjZiYjVhOTA2YzI0MDUzY2UwOWQ3OWE1MTQ3IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBaaGFuZyBYaWFudGFvIDx4aWFudGFvLnpoYW5nQGludGVsLmNv
bT4KRGF0ZTogVHVlLCAyOSBKYW4gMjAwOCAxNDozMDozNiArMDgwMApTdWJqZWN0OiBbUEFUQ0hd
IGt2bS9pYTY0OiBBZGQgaW50ZXJydXB0aW9uIHZlY3RvciB0YWJsZSBmb3Igdm1tLgoKdm1tX2l2
dC5TIGluY2x1ZGVzIGFuIGl2dCBmb3Igdm1tIHVzZS4KU2lnbmVkLW9mZi1ieTogQW50aG9ueSBY
dSA8YW50aG9ueS54dUBpbnRlbC5jb20+ClNpZ25lZC1vZmYtYnk6IFhpYW50YW8gWmhhbmcgPHhp
YW50YW8uemhhbmdAaW50ZWwuY29tPgotLS0KIGFyY2gvaWE2NC9rdm0vdm1tX2l2dC5TIHwgMTQy
MyArKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKwogMSBmaWxl
cyBjaGFuZ2VkLCAxNDIzIGluc2VydGlvbnMoKyksIDAgZGVsZXRpb25zKC0pCiBjcmVhdGUgbW9k
ZSAxMDA2NDQgYXJjaC9pYTY0L2t2bS92bW1faXZ0LlMKCmRpZmYgLS1naXQgYS9hcmNoL2lhNjQv
a3ZtL3ZtbV9pdnQuUyBiL2FyY2gvaWE2NC9rdm0vdm1tX2l2dC5TCm5ldyBmaWxlIG1vZGUgMTAw
NjQ0CmluZGV4IDAwMDAwMDAuLjVjYTg2NTEKLS0tIC9kZXYvbnVsbAorKysgYi9hcmNoL2lhNjQv
a3ZtL3ZtbV9pdnQuUwpAQCAtMCwwICsxLDE0MjMgQEAKKy8qCisgKiAvaWE2NC9rdm1faXZ0LlMK
KyAqCisgKiBDb3B5cmlnaHQgKEMpIDE5OTgtMjAwMSwgMjAwMyBIZXdsZXR0LVBhY2thcmQgQ28K
KyAqICAgICAgU3RlcGhhbmUgRXJhbmlhbiA8ZXJhbmlhbkBocGwuaHAuY29tPgorICogICAgICBE
YXZpZCBNb3NiZXJnZXIgPGRhdmlkbUBocGwuaHAuY29tPgorICogQ29weXJpZ2h0IChDKSAyMDAw
LCAyMDAyLTIwMDMgSW50ZWwgQ28KKyAqICAgICAgQXNpdCBNYWxsaWNrIDxhc2l0LmsubWFsbGlj
a0BpbnRlbC5jb20+CisgKiAgICAgIFN1cmVzaCBTaWRkaGEgPHN1cmVzaC5iLnNpZGRoYUBpbnRl
bC5jb20+CisgKiAgICAgIEtlbm5ldGggQ2hlbiA8a2VubmV0aC53LmNoZW5AaW50ZWwuY29tPgor
ICogICAgICBGZW5naHVhIFl1IDxmZW5naHVhLnl1QGludGVsLmNvbT4KKyAqCisgKgorICogMDAv
MDgvMjMgQXNpdCBNYWxsaWNrIDxhc2l0LmsubWFsbGlja0BpbnRlbC5jb20+IFRMQiBoYW5kbGlu
ZworICogZm9yIFNNUAorICogMDAvMTIvMjAgRGF2aWQgTW9zYmVyZ2VyLVRhbmcgPGRhdmlkbUBo
cGwuaHAuY29tPiBEVExCL0lUTEIKKyAqIGhhbmRsZXIgbm93IHVzZXMgdmlydHVhbCBQVC4KKyAq
CisgKiAwNy82LzIwIFh1ZWZlaSBYdSAgKEFudGhvbnkgWHUpIChhbnRob255Lnh1QGludGVsLmNv
bSkKKyAqICAgICAgICAgICAgICBTdXBwb3J0aW5nIEludGVsIHZpcnR1YWxpemF0aW9uIGFyY2hp
dGVjdHVyZQorICoKKyAqLworCisvKgorICogVGhpcyBmaWxlIGRlZmluZXMgdGhlIGludGVycnVw
dGlvbiB2ZWN0b3IgdGFibGUgdXNlZCBieSB0aGUgQ1BVLgorICogSXQgZG9lcyBub3QgaW5jbHVk
ZSBvbmUgZW50cnkgcGVyIHBvc3NpYmxlIGNhdXNlIG9mIGludGVycnVwdGlvbi4KKyAqCisgKiBU
aGUgZmlyc3QgMjAgZW50cmllcyBvZiB0aGUgdGFibGUgY29udGFpbiA2NCBidW5kbGVzIGVhY2gg
d2hpbGUgdGhlCisgKiByZW1haW5pbmcgNDggZW50cmllcyBjb250YWluIG9ubHkgMTYgYnVuZGxl
cyBlYWNoLgorICoKKyAqIFRoZSA2NCBidW5kbGVzIGFyZSB1c2VkIHRvIGFsbG93IGlubGluaW5n
IHRoZSB3aG9sZSBoYW5kbGVyIGZvcgorICogY3JpdGljYWwKKyAqIGludGVycnVwdGlvbnMgbGlr
ZSBUTEIgbWlzc2VzLgorICoKKyAqICBGb3IgZWFjaCBlbnRyeSwgdGhlIGNvbW1lbnQgaXMgYXMg
Zm9sbG93czoKKyAqCisgKiAgICAgICAgICAgICAgLy8gMHgxYzAwIEVudHJ5IDcgKHNpemUgNjQg
YnVuZGxlcykgRGF0YSBLZXkgTWlzcworICogICAgICAgICAgICAgICgxMiw1MSkKKyAqICBlbnRy
eSBvZmZzZXQgLS0tLS8gICAgIC8gICAgICAgICAvICAgICAgICAgICAgICAgICAgLworICogIC8K
KyAqICBlbnRyeSBudW1iZXIgLS0tLS0tLS0tLyAgICAgICAgIC8gICAgICAgICAgICAgICAgICAv
CisgKiAgLworICogIHNpemUgb2YgdGhlIGVudHJ5IC0tLS0tLS0tLS0tLS0vICAgICAgICAgICAg
ICAgICAgLworICogIC8KKyAqICB2ZWN0b3IgbmFtZSAtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLworICogIC8KKyAqICBpbnRlcnJ1cHRpb25zIHRyaWdnZXJpbmcgdGhpcyB2
ZWN0b3IKKyAqICAtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLworICoKKyAqIFRoZSB0YWJsZSBpcyAz
MktCIGluIHNpemUgYW5kIG11c3QgYmUgYWxpZ25lZCBvbiAzMktCCisgKiBib3VuZGFyeS4KKyAq
IChUaGUgQ1BVIGlnbm9yZXMgdGhlIDE1IGxvd2VyIGJpdHMgb2YgdGhlIGFkZHJlc3MpCisgKgor
ICogVGFibGUgaXMgYmFzZWQgdXBvbiBFQVMyLjYgKE9jdCAxOTk5KQorICovCisKKworI2luY2x1
ZGUgPGFzbS9hc21tYWNyby5oPgorI2luY2x1ZGUgPGFzbS9jYWNoZS5oPgorI2luY2x1ZGUgPGFz
bS9wZ3RhYmxlLmg+CisKKyNpbmNsdWRlICJhc20tb2Zmc2V0cy5oIgorI2luY2x1ZGUgInZjcHUu
aCIKKyNpbmNsdWRlICJrdm1fbWluc3RhdGUuaCIKKyNpbmNsdWRlICJ2dGkuaCIKKworI2lmIDEK
KyMgZGVmaW5lIFBTUl9ERUZBVUxUX0JJVFMgICBwc3IuYWMKKyNlbHNlCisjIGRlZmluZSBQU1Jf
REVGQVVMVF9CSVRTICAgMAorI2VuZGlmCisKKworI2RlZmluZSBLVk1fRkFVTFQobikgICAgXAor
ICAgIGt2bV9mYXVsdF8jI246OyAgICAgICAgICBcCisgICAgbW92IHIxOT1uOzsgICAgICAgICAg
XAorICAgIGJyLnNwdGsubWFueSBrdm1fZmF1bHRfIyNuOyAgICAgICAgIFwKKyAgICA7OyAgICAg
ICAgICAgICAgICAgIFwKKworCisjZGVmaW5lIEtWTV9SRUZMRUNUKG4pICAgIFwKKyAgICBtb3Yg
cjMxPXByOyAgICAgICAgICAgXAorICAgIG1vdiByMTk9bjsgICAgICAgLyogcHJlcGFyZSB0byBz
YXZlIHByZWRpY2F0ZXMgKi8gXAorICAgIG1vdiByMjk9Y3IuaXBzcjsgICAgICBcCisgICAgOzsg
ICAgICBcCisgICAgdGJpdC56IHA2LHA3PXIyOSxJQTY0X1BTUl9WTV9CSVQ7ICAgICAgIFwKKyhw
Nylici5zcHRrLm1hbnkga3ZtX2Rpc3BhdGNoX3JlZmxlY3Rpb247ICAgICAgICBcCisgICAgYnIu
c3B0ay5tYW55IGt2bV9wYW5pYzsgICAgICBcCisKKworR0xPQkFMX0VOVFJZKGt2bV9wYW5pYykK
KyAgICBici5zcHRrLm1hbnkga3ZtX3BhbmljCisgICAgOzsKK0VORChrdm1fcGFuaWMpCisKKwor
CisKKworICAgIC5zZWN0aW9uIC50ZXh0Lml2dCwiYXgiCisKKyAgICAuYWxpZ24gMzI3NjggICAg
Ly8gYWxpZ24gb24gMzJLQiBib3VuZGFyeQorICAgIC5nbG9iYWwga3ZtX2lhNjRfaXZ0Citrdm1f
aWE2NF9pdnQ6CisvLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8KKy8vIDB4MDAwMCBFbnRyeSAwIChzaXplIDY0IGJ1bmRsZXMpIFZI
UFQgVHJhbnNsYXRpb24gKDgsMjAsNDcpCitFTlRSWShrdm1fdmhwdF9taXNzKQorICAgIEtWTV9G
QVVMVCgwKQorRU5EKGt2bV92aHB0X21pc3MpCisKKworICAgIC5vcmcga3ZtX2lhNjRfaXZ0KzB4
NDAwCisvLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vCisvLyAweDA0MDAgRW50cnkgMSAoc2l6ZSA2NCBidW5kbGVzKSBJVExCICgy
MSkKK0VOVFJZKGt2bV9pdGxiX21pc3MpCisgICAgbW92IHIzMSA9IHByCisgICAgbW92IHIyOT1j
ci5pcHNyOworICAgIDs7CisgICAgdGJpdC56IHA2LHA3PXIyOSxJQTY0X1BTUl9WTV9CSVQ7Cisg
ICAgKHA2KSBici5zcHRrIGt2bV9hbHRfaXRsYl9taXNzCisgICAgbW92IHIxOSA9IDEKKyAgICBi
ci5zcHRrIGt2bV9pdGxiX21pc3NfZGlzcGF0Y2gKKyAgICBLVk1fRkFVTFQoMSk7CitFTkQoa3Zt
X2l0bGJfbWlzcykKKworICAgIC5vcmcga3ZtX2lhNjRfaXZ0KzB4MDgwMAorLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vCisv
LyAweDA4MDAgRW50cnkgMiAoc2l6ZSA2NCBidW5kbGVzKSBEVExCICg5LDQ4KQorRU5UUlkoa3Zt
X2R0bGJfbWlzcykKKyAgICBtb3YgcjMxID0gcHIKKyAgICBtb3YgcjI5PWNyLmlwc3I7CisgICAg
OzsKKyAgICB0Yml0LnogcDYscDc9cjI5LElBNjRfUFNSX1ZNX0JJVDsKKyhwNilici5zcHRrIGt2
bV9hbHRfZHRsYl9taXNzCisgICAgYnIuc3B0ayBrdm1fZHRsYl9taXNzX2Rpc3BhdGNoCitFTkQo
a3ZtX2R0bGJfbWlzcykKKworICAgICAub3JnIGt2bV9pYTY0X2l2dCsweDBjMDAKKy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vCisvLyAweDBjMDAgRW50cnkgMyAoc2l6ZSA2NCBidW5kbGVzKSBBbHQgSVRMQiAoMTkpCitF
TlRSWShrdm1fYWx0X2l0bGJfbWlzcykKKyAgICBtb3YgcjE2PWNyLmlmYSAgICAvLyBnZXQgYWRk
cmVzcyB0aGF0IGNhdXNlZCB0aGUgVExCIG1pc3MKKyAgICA7OworICAgIG1vdmwgcjE3PVBBR0Vf
S0VSTkVMCisgICAgbW92IHIyND1jci5pcHNyCisgICAgbW92bCByMTk9KCgoMSA8PCBJQTY0X01B
WF9QSFlTX0JJVFMpIC0gMSkgJiB+MHhmZmYpCisgICAgOzsKKyAgICBhbmQgcjE5PXIxOSxyMTYg
ICAgIC8vIGNsZWFyIGVkLCByZXNlcnZlZCBiaXRzLCBhbmQgUFRFIGNvbnRyb2wgYml0cworICAg
IDs7CisgICAgb3IgcjE5PXIxNyxyMTkgICAgICAvLyBpbnNlcnQgUFRFIGNvbnRyb2wgYml0cyBp
bnRvIHIxOQorICAgIDs7CisgICAgbW92bCByMjA9SUE2NF9HUkFOVUxFX1NISUZUPDwyCisgICAg
OzsKKyAgICBtb3YgY3IuaXRpcj1yMjAKKyAgICA7OworICAgIGl0Yy5pIHIxOQkJLy8gaW5zZXJ0
IHRoZSBUTEIgZW50cnkKKyAgICBtb3YgcHI9cjMxLC0xCisgICAgcmZpCitFTkQoa3ZtX2FsdF9p
dGxiX21pc3MpCisKKyAgICAub3JnIGt2bV9pYTY0X2l2dCsweDEwMDAKKy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLwor
Ly8gMHgxMDAwIEVudHJ5IDQgKHNpemUgNjQgYnVuZGxlcykgQWx0IERUTEIgKDcsNDYpCitFTlRS
WShrdm1fYWx0X2R0bGJfbWlzcykKKyAgICBtb3YgcjE2PWNyLmlmYQkJLy8gZ2V0IGFkZHJlc3Mg
dGhhdCBjYXVzZWQgdGhlIFRMQiBtaXNzCisgICAgOzsKKyAgICBtb3ZsIHIxNz1QQUdFX0tFUk5F
TAorICAgIG1vdmwgcjE5PSgoKDEgPDwgSUE2NF9NQVhfUEhZU19CSVRTKSAtIDEpICYgfjB4ZmZm
KQorICAgIG1vdiByMjQ9Y3IuaXBzcgorICAgIDs7CisgICAgYW5kIHIxOT1yMTkscjE2ICAgICAv
LyBjbGVhciBlZCwgcmVzZXJ2ZWQgYml0cywgYW5kIFBURSBjb250cm9sIGJpdHMKKyAgICA7Owor
ICAgIG9yIHIxOT1yMTkscjE3CS8vIGluc2VydCBQVEUgY29udHJvbCBiaXRzIGludG8gcjE5Cisg
ICAgOzsKKyAgICBtb3ZsIHIyMD1JQTY0X0dSQU5VTEVfU0hJRlQ8PDIKKyAgICA7OworICAgIG1v
diBjci5pdGlyPXIyMAorICAgIDs7CisgICAgaXRjLmQgcjE5CQkvLyBpbnNlcnQgdGhlIFRMQiBl
bnRyeQorICAgIG1vdiBwcj1yMzEsLTEKKyAgICByZmkKK0VORChrdm1fYWx0X2R0bGJfbWlzcykK
KworICAgIC5vcmcga3ZtX2lhNjRfaXZ0KzB4MTQwMAorLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLworLy8gMHgxNDAw
IEVudHJ5IDUgKHNpemUgNjQgYnVuZGxlcykgRGF0YSBuZXN0ZWQgVExCICg2LDQ1KQorRU5UUlko
a3ZtX25lc3RlZF9kdGxiX21pc3MpCisgICAgS1ZNX0ZBVUxUKDUpCitFTkQoa3ZtX25lc3RlZF9k
dGxiX21pc3MpCisKKyAgICAub3JnIGt2bV9pYTY0X2l2dCsweDE4MDAKKy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLwor
Ly8gMHgxODAwIEVudHJ5IDYgKHNpemUgNjQgYnVuZGxlcykgSW5zdHJ1Y3Rpb24gS2V5IE1pc3Mg
KDI0KQorRU5UUlkoa3ZtX2lrZXlfbWlzcykKKyAgICBLVk1fUkVGTEVDVCg2KQorRU5EKGt2bV9p
a2V5X21pc3MpCisKKyAgICAub3JnIGt2bV9pYTY0X2l2dCsweDFjMDAKKy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLwor
Ly8gMHgxYzAwIEVudHJ5IDcgKHNpemUgNjQgYnVuZGxlcykgRGF0YSBLZXkgTWlzcyAoMTIsNTEp
CitFTlRSWShrdm1fZGtleV9taXNzKQorICAgIEtWTV9SRUZMRUNUKDcpCitFTkQoa3ZtX2RrZXlf
bWlzcykKKworICAgIC5vcmcga3ZtX2lhNjRfaXZ0KzB4MjAwMAorLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8KKy8vIDB4
MjAwMCBFbnRyeSA4IChzaXplIDY0IGJ1bmRsZXMpIERpcnR5LWJpdCAoNTQpCitFTlRSWShrdm1f
ZGlydHlfYml0KQorICAgIEtWTV9SRUZMRUNUKDgpCitFTkQoa3ZtX2RpcnR5X2JpdCkKKworICAg
IC5vcmcga3ZtX2lhNjRfaXZ0KzB4MjQwMAorLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8KKy8vIDB4MjQwMCBFbnRyeSA5
IChzaXplIDY0IGJ1bmRsZXMpIEluc3RydWN0aW9uIEFjY2Vzcy1iaXQgKDI3KQorRU5UUlkoa3Zt
X2lhY2Nlc3NfYml0KQorICAgIEtWTV9SRUZMRUNUKDkpCitFTkQoa3ZtX2lhY2Nlc3NfYml0KQor
CisgICAgLm9yZyBrdm1faWE2NF9pdnQrMHgyODAwCisvLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vCisvLyAweDI4MDAgRW50
cnkgMTAgKHNpemUgNjQgYnVuZGxlcykgRGF0YSBBY2Nlc3MtYml0ICgxNSw1NSkKK0VOVFJZKGt2
bV9kYWNjZXNzX2JpdCkKKyAgICBLVk1fUkVGTEVDVCgxMCkKK0VORChrdm1fZGFjY2Vzc19iaXQp
CisKKyAgICAub3JnIGt2bV9pYTY0X2l2dCsweDJjMDAKKy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vCisvLyAweDJjMDAgRW50
cnkgMTEgKHNpemUgNjQgYnVuZGxlcykgQnJlYWsgaW5zdHJ1Y3Rpb24gKDMzKQorRU5UUlkoa3Zt
X2JyZWFrX2ZhdWx0KQorICAgIG1vdiByMzE9cHIKKyAgICBtb3YgcjE5PTExCisgICAgbW92IHIy
OT1jci5pcHNyCisgICAgOzsKKyAgICBLVk1fU0FWRV9NSU5fV0lUSF9DT1ZFUl9SMTkKKyAgICA7
OworICAgIGFsbG9jIHIxND1hci5wZnMsMCwwLDQsMCAvLyBub3cgaXQncyBzYWZlIChtdXN0IGJl
IGZpcnN0IGluIGluc24gZ3JvdXAhKQorICAgIG1vdiBvdXQwPWNyLmlmYQorICAgIG1vdiBvdXQy
PWNyLmlzciAgICAgLy8gRklYTUU6IHBpdHkgdG8gbWFrZSB0aGlzIHNsb3cgYWNjZXNzIHR3aWNl
CisgICAgbW92IG91dDM9Y3IuaWltICAgICAvLyBGSVhNRTogcGl0eSB0byBtYWtlIHRoaXMgc2xv
dyBhY2Nlc3MgdHdpY2UKKyAgICBhZGRzIHIzPTgscjIgICAgICAgICAgICAgICAgLy8gc2V0IHVw
IHNlY29uZCBiYXNlIHBvaW50ZXIKKyAgICA7OworICAgIHNzbSBwc3IuaWMKKyAgICA7OworICAg
IHNybHouaSAgICAgICAgICAgICAgICAgIC8vIGd1YXJhbnRlZSB0aGF0IGludGVycnVwdGlvbiBj
b2xsZWN0aW9uIGlzIG9uCisgICAgOzsKKyAgICAvLyhwMTUpc3NtIHBzci5pICAgICAgICAgICAg
ICAgLy8gcmVzdG9yZSBwc3IuaQorICAgIGFkZGwgcjE0PUBncHJlbChpYTY0X2xlYXZlX2h5cGVy
dmlzb3IpLGdwCisgICAgOzsKKyAgICBLVk1fU0FWRV9SRVNUCisgICAgbW92IHJwPXIxNAorICAg
IDs7CisgICAgYWRkcyBvdXQxPTE2LHNwCisgICAgYnIuY2FsbC5zcHRrLm1hbnkgYjY9a3ZtX2lh
NjRfaGFuZGxlX2JyZWFrCisgICAgOzsKK0VORChrdm1fYnJlYWtfZmF1bHQpCisKKyAgICAub3Jn
IGt2bV9pYTY0X2l2dCsweDMwMDAKKy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vCisvLyAweDMwMDAgRW50cnkgMTIgKHNpemUg
NjQgYnVuZGxlcykgRXh0ZXJuYWwgSW50ZXJydXB0ICg0KQorRU5UUlkoa3ZtX2ludGVycnVwdCkK
KyAgICBtb3YgcjMxPXByCQkvLyBwcmVwYXJlIHRvIHNhdmUgcHJlZGljYXRlcworICAgIG1vdiBy
MTk9MTIKKyAgICBtb3YgcjI5PWNyLmlwc3IKKyAgICA7OworICAgIHRiaXQueiBwNixwNz1yMjks
SUE2NF9QU1JfVk1fQklUCisgICAgdGJpdC56IHAwLHAxNT1yMjksSUE2NF9QU1JfSV9CSVQKKyAg
ICA7OworKHA3KSBici5zcHRrIGt2bV9kaXNwYXRjaF9pbnRlcnJ1cHQKKyAgICA7OworICAgIG1v
diByMjc9YXIucnNjCQkvKiBNICovCisgICAgbW92IHIyMD1yMQkJCS8qIEEgKi8KKyAgICBtb3Yg
cjI1PWFyLnVuYXQJCS8qIE0gKi8KKyAgICBtb3YgcjI2PWFyLnBmcwkJLyogSSAqLworICAgIG1v
diByMjg9Y3IuaWlwCQkvKiBNICovCisgICAgY292ZXIJCQkvKiBCIChvciBub3RoaW5nKSAqLwor
ICAgIDs7CisgICAgbW92IHIxPXNwCisgICAgOzsKKyAgICBpbnZhbGEJCQkvKiBNICovCisgICAg
bW92IHIzMD1jci5pZnMKKyAgICA7OworICAgIGFkZGwgcjE9LVZNTV9QVF9SRUdTX1NJWkUscjEK
KyAgICA7OworICAgIGFkZHMgcjE3PTIqTDFfQ0FDSEVfQllURVMscjEJLyogcmVhbGx5OiBiaWdn
ZXN0IGNhY2hlLWxpbmUgc2l6ZSAqLworICAgIGFkZHMgcjE2PVBUKENSX0lQU1IpLHIxCisgICAg
OzsKKyAgICBsZmV0Y2guZmF1bHQuZXhjbC5udDEgW3IxN10sTDFfQ0FDSEVfQllURVMKKyAgICBz
dDggW3IxNl09cjI5CQkJLyogc2F2ZSBjci5pcHNyICovCisgICAgOzsKKyAgICBsZmV0Y2guZmF1
bHQuZXhjbC5udDEgW3IxN10KKyAgICBtb3YgcjI5PWIwCisgICAgOzsKKyAgICBhZGRzIHIxNj1Q
VChSOCkscjEgIAkvKiBpbml0aWFsaXplIGZpcnN0IGJhc2UgcG9pbnRlciAqLworICAgIGFkZHMg
cjE3PVBUKFI5KSxyMSAgCS8qIGluaXRpYWxpemUgc2Vjb25kIGJhc2UgcG9pbnRlciAqLworICAg
IG1vdiByMTg9cjAgICAgICAJCS8qIG1ha2Ugc3VyZSByMTggaXNuJ3QgTmFUICovCisgICAgOzsK
Ky5tZW0ub2Zmc2V0IDAsMDsgc3Q4LnNwaWxsIFtyMTZdPXI4LDE2CisubWVtLm9mZnNldCA4LDA7
IHN0OC5zcGlsbCBbcjE3XT1yOSwxNgorICAgICAgICA7OworLm1lbS5vZmZzZXQgMCwwOyBzdDgu
c3BpbGwgW3IxNl09cjEwLDI0CisubWVtLm9mZnNldCA4LDA7IHN0OC5zcGlsbCBbcjE3XT1yMTEs
MjQKKyAgICAgICAgOzsKKyAgICBzdDggW3IxNl09cjI4LDE2CQkvKiBzYXZlIGNyLmlpcCAqLwor
ICAgIHN0OCBbcjE3XT1yMzAsMTYJCS8qIHNhdmUgY3IuaWZzICovCisgICAgbW92IHI4PWFyLmZw
c3IJCS8qIE0gKi8KKyAgICBtb3Ygcjk9YXIuY3NkCisgICAgbW92IHIxMD1hci5zc2QKKyAgICBt
b3ZsIHIxMT1GUFNSX0RFRkFVTFQJLyogTC11bml0ICovCisgICAgOzsKKyAgICBzdDggW3IxNl09
cjI1LDE2CQkvKiBzYXZlIGFyLnVuYXQgKi8KKyAgICBzdDggW3IxN109cjI2LDE2CQkvKiBzYXZl
IGFyLnBmcyAqLworICAgIHNobCByMTg9cjE4LDE2CQkvKiBjb21wdXRlIGFyLnJzYyB0byBiZSB1
c2VkIGZvciAibG9hZHJzIiAqLworICAgIDs7CisgICAgc3Q4IFtyMTZdPXIyNywxNgkJLyogc2F2
ZSBhci5yc2MgKi8KKyAgICBhZGRzIHIxNz0xNixyMTcJCS8qIHNraXAgb3ZlciBhcl9ybmF0IGZp
ZWxkICovCisgICAgOzsKKyAgICBzdDggW3IxN109cjMxLDE2CQkvKiBzYXZlIHByZWRpY2F0ZXMg
Ki8KKyAgICBhZGRzIHIxNj0xNixyMTYJCS8qIHNraXAgb3ZlciBhcl9ic3BzdG9yZSBmaWVsZCAq
LworICAgIDs7CisgICAgc3Q4IFtyMTZdPXIyOSwxNgkJLyogc2F2ZSBiMCAqLworICAgIHN0OCBb
cjE3XT1yMTgsMTYJCS8qIHNhdmUgYXIucnNjIHZhbHVlIGZvciAibG9hZHJzIiAqLworICAgIDs7
CisubWVtLm9mZnNldCAwLDA7IHN0OC5zcGlsbCBbcjE2XT1yMjAsMTYgICAgLyogc2F2ZSBvcmln
aW5hbCByMSAqLworLm1lbS5vZmZzZXQgOCwwOyBzdDguc3BpbGwgW3IxN109cjEyLDE2CisgICAg
YWRkcyByMTI9LTE2LHIxCisgICAgLyogc3dpdGNoIHRvIGtlcm5lbCBtZW1vcnkgc3RhY2sgKHdp
dGggMTYgYnl0ZXMgb2Ygc2NyYXRjaCkgKi8KKyAgICA7OworLm1lbS5vZmZzZXQgMCwwOyBzdDgu
c3BpbGwgW3IxNl09cjEzLDE2CisubWVtLm9mZnNldCA4LDA7IHN0OC5zcGlsbCBbcjE3XT1yOCwx
NiAvKiBzYXZlIGFyLmZwc3IgKi8KKyAgICA7OworLm1lbS5vZmZzZXQgMCwwOyBzdDguc3BpbGwg
W3IxNl09cjE1LDE2CisubWVtLm9mZnNldCA4LDA7IHN0OC5zcGlsbCBbcjE3XT1yMTQsMTYKKyAg
ICBkZXAgcjE0PS0xLHIwLDYwLDQKKyAgICA7OworLm1lbS5vZmZzZXQgMCwwOyBzdDguc3BpbGwg
W3IxNl09cjIsMTYKKy5tZW0ub2Zmc2V0IDgsMDsgc3Q4LnNwaWxsIFtyMTddPXIzLDE2CisgICAg
YWRkcyByMj1WTU1fUFRfUkVHU19SMTZfT0ZGU0VULHIxCisgICAgYWRkcyByMTQgPSBWTU1fVkNQ
VV9HUF9PRkZTRVQscjEzCisgICAgOzsKKyAgICBtb3Ygcjg9YXIuY2N2CisgICAgbGQ4IHIxNCA9
IFtyMTRdCisgICAgOzsKKyAgICBtb3YgcjE9cjE0ICAgICAgIC8qIGVzdGFibGlzaCBrZXJuZWwg
Z2xvYmFsIHBvaW50ZXIgKi8KKyAgICA7OyAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgIFwKKyAgICBic3cuMQorICAgIDs7CisgICAgYWxsb2MgcjE0PWFyLnBmcywwLDAs
MSwwCS8vIG11c3QgYmUgZmlyc3QgaW4gYW4gaW5zbiBncm91cAorICAgIG1vdiBvdXQwPXIxMwor
ICAgIDs7CisgICAgc3NtIHBzci5pYworICAgIDs7CisgICAgc3Jsei5pCisgICAgOzsKKyAgICAv
LyhwMTUpIHNzbSBwc3IuaQorICAgIGFkZHMgcjM9OCxyMgkJLy8gc2V0IHVwIHNlY29uZCBiYXNl
IHBvaW50ZXIgZm9yIFNBVkVfUkVTVAorICAgIHNybHouaQkJCS8vIGVuc3VyZSBldmVyeWJvZHkg
a25vd3MgcHNyLmljIGlzIGJhY2sgb24KKyAgICA7OworLm1lbS5vZmZzZXQgMCwwOyBzdDguc3Bp
bGwgW3IyXT1yMTYsMTYKKy5tZW0ub2Zmc2V0IDgsMDsgc3Q4LnNwaWxsIFtyM109cjE3LDE2Cisg
ICAgOzsKKy5tZW0ub2Zmc2V0IDAsMDsgc3Q4LnNwaWxsIFtyMl09cjE4LDE2CisubWVtLm9mZnNl
dCA4LDA7IHN0OC5zcGlsbCBbcjNdPXIxOSwxNgorICAgIDs7CisubWVtLm9mZnNldCAwLDA7IHN0
OC5zcGlsbCBbcjJdPXIyMCwxNgorLm1lbS5vZmZzZXQgOCwwOyBzdDguc3BpbGwgW3IzXT1yMjEs
MTYKKyAgICBtb3YgcjE4PWI2CisgICAgOzsKKy5tZW0ub2Zmc2V0IDAsMDsgc3Q4LnNwaWxsIFty
Ml09cjIyLDE2CisubWVtLm9mZnNldCA4LDA7IHN0OC5zcGlsbCBbcjNdPXIyMywxNgorICAgIG1v
diByMTk9YjcKKyAgICA7OworLm1lbS5vZmZzZXQgMCwwOyBzdDguc3BpbGwgW3IyXT1yMjQsMTYK
Ky5tZW0ub2Zmc2V0IDgsMDsgc3Q4LnNwaWxsIFtyM109cjI1LDE2CisgICAgOzsKKy5tZW0ub2Zm
c2V0IDAsMDsgc3Q4LnNwaWxsIFtyMl09cjI2LDE2CisubWVtLm9mZnNldCA4LDA7IHN0OC5zcGls
bCBbcjNdPXIyNywxNgorICAgIDs7CisubWVtLm9mZnNldCAwLDA7IHN0OC5zcGlsbCBbcjJdPXIy
OCwxNgorLm1lbS5vZmZzZXQgOCwwOyBzdDguc3BpbGwgW3IzXT1yMjksMTYKKyAgICA7OworLm1l
bS5vZmZzZXQgMCwwOyBzdDguc3BpbGwgW3IyXT1yMzAsMTYKKy5tZW0ub2Zmc2V0IDgsMDsgc3Q4
LnNwaWxsIFtyM109cjMxLDMyCisgICAgOzsKKyAgICBtb3YgYXIuZnBzcj1yMTEgICAgICAgLyog
TS11bml0ICovCisgICAgc3Q4IFtyMl09cjgsOCAgICAgICAgIC8qIGFyLmNjdiAqLworICAgIGFk
ZHMgcjI0PVBUKEI2KS1QVChGNykscjMKKyAgICA7OworICAgIHN0Zi5zcGlsbCBbcjJdPWY2LDMy
CisgICAgc3RmLnNwaWxsIFtyM109ZjcsMzIKKyAgICA7OworICAgIHN0Zi5zcGlsbCBbcjJdPWY4
LDMyCisgICAgc3RmLnNwaWxsIFtyM109ZjksMzIKKyAgICA7OworICAgIHN0Zi5zcGlsbCBbcjJd
PWYxMAorICAgIHN0Zi5zcGlsbCBbcjNdPWYxMQorICAgIGFkZHMgcjI1PVBUKEI3KS1QVChGMTEp
LHIzCisgICAgOzsKKyAgICBzdDggW3IyNF09cjE4LDE2ICAgICAgIC8qIGI2ICovCisgICAgc3Q4
IFtyMjVdPXIxOSwxNiAgICAgICAvKiBiNyAqLworICAgIDs7CisgICAgc3Q4IFtyMjRdPXI5ICAg
ICAgICAgICAvKiBhci5jc2QgKi8KKyAgICBzdDggW3IyNV09cjEwICAgICAgICAgIC8qIGFyLnNz
ZCAqLworICAgIDs7CisgICAgc3Jsei5kCQkvLyBtYWtlIHN1cmUgd2Ugc2VlIHRoZSBlZmZlY3Qg
b2YgY3IuaXZyCisgICAgYWRkbCByMTQ9QGdwcmVsKGlhNjRfbGVhdmVfbmVzdGVkKSxncAorICAg
IDs7CisgICAgbW92IHJwPXIxNAorICAgIGJyLmNhbGwuc3B0ay5tYW55IGI2PWt2bV9pYTY0X2hh
bmRsZV9pcnEKKyAgICA7OworRU5EKGt2bV9pbnRlcnJ1cHQpCisKKyAgICAuZ2xvYmFsIGt2bV9k
aXNwYXRjaF92ZXhpcnEKKyAgICAub3JnIGt2bV9pYTY0X2l2dCsweDM0MDAKKy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8KKy8vIDB4MzQwMCBFbnRyeSAxMyAoc2l6ZSA2NCBidW5kbGVzKSBSZXNlcnZlZAorRU5UUlko
a3ZtX3ZpcnR1YWxfZXhpcnEpCisgICAgbW92IHIzMT1wcgorICAgIG1vdiByMTk9MTMKKyAgICBt
b3YgcjMwID1yMAorICAgIDs7Citrdm1fZGlzcGF0Y2hfdmV4aXJxOgorICAgIGNtcC5lcSBwNixw
MCA9IDEscjMwCisgICAgOzsKKyhwNilhZGQgcjI5ID0gVk1NX1ZDUFVfU0FWRURfR1BfT0ZGU0VU
LHIyMQorICAgIDs7CisocDYpbGQ4IHIxID0gW3IyOV0KKyAgICA7OworICAgIEtWTV9TQVZFX01J
Tl9XSVRIX0NPVkVSX1IxOQorICAgIGFsbG9jIHIxND1hci5wZnMsMCwwLDEsMAorICAgIG1vdiBv
dXQwPXIxMworCisgICAgc3NtIHBzci5pYworICAgIDs7CisgICAgc3Jsei5pICAgICAgICAgICAg
ICAgICAgLy8gZ3VhcmFudGVlIHRoYXQgaW50ZXJydXB0aW9uIGNvbGxlY3Rpb24gaXMgb24KKyAg
ICA7OworICAgIC8vKHAxNSkgc3NtIHBzci5pICAgICAgICAgICAgICAgLy8gcmVzdG9yZSBwc3Iu
aQorICAgIGFkZHMgcjM9OCxyMiAgICAgICAgICAgICAgICAvLyBzZXQgdXAgc2Vjb25kIGJhc2Ug
cG9pbnRlcgorICAgIDs7CisgICAgS1ZNX1NBVkVfUkVTVAorICAgIGFkZGwgcjE0PUBncHJlbChp
YTY0X2xlYXZlX2h5cGVydmlzb3IpLGdwCisgICAgOzsKKyAgICBtb3YgcnA9cjE0CisgICAgYnIu
Y2FsbC5zcHRrLm1hbnkgYjY9a3ZtX3ZleGlycQorRU5EKGt2bV92aXJ0dWFsX2V4aXJxKQorCisg
ICAgLm9yZyBrdm1faWE2NF9pdnQrMHgzODAwCisvLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8KKy8vIDB4MzgwMCBFbnRy
eSAxNCAoc2l6ZSA2NCBidW5kbGVzKSBSZXNlcnZlZAorICAgIEtWTV9GQVVMVCgxNCkKKyAgICAv
LyB0aGlzIGNvZGUgc2VnbWVudCBpcyBmcm9tIDIuNi4xNi4xMworCisKKyAgICAub3JnIGt2bV9p
YTY0X2l2dCsweDNjMDAKKy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vCisvLyAweDNjMDAgRW50cnkgMTUgKHNpemUg
NjQgYnVuZGxlcykgUmVzZXJ2ZWQKKyAgICBLVk1fRkFVTFQoMTUpCisKKworICAgIC5vcmcga3Zt
X2lhNjRfaXZ0KzB4NDAwMAorLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8KKy8vIDB4NDAwMCBFbnRyeSAxNiAoc2l6
ZSA2NCBidW5kbGVzKSBSZXNlcnZlZAorICAgIEtWTV9GQVVMVCgxNikKKworICAgIC5vcmcga3Zt
X2lhNjRfaXZ0KzB4NDQwMAorLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLworLy8gMHg0NDAwIEVudHJ5IDE3IChzaXpl
IDY0IGJ1bmRsZXMpIFJlc2VydmVkCisgICAgS1ZNX0ZBVUxUKDE3KQorCisgICAgLm9yZyBrdm1f
aWE2NF9pdnQrMHg0ODAwCisvLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vCisvLyAweDQ4MDAgRW50cnkgMTggKHNpemUg
NjQgYnVuZGxlcykgUmVzZXJ2ZWQKKyAgICBLVk1fRkFVTFQoMTgpCisKKyAgICAub3JnIGt2bV9p
YTY0X2l2dCsweDRjMDAKKy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8KKy8vIDB4NGMwMCBFbnRyeSAxOSAoc2l6ZSA2
NCBidW5kbGVzKSBSZXNlcnZlZAorICAgIEtWTV9GQVVMVCgxOSkKKworICAgIC5vcmcga3ZtX2lh
NjRfaXZ0KzB4NTAwMAorLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLworLy8gMHg1MDAwIEVudHJ5IDIwIChzaXplIDE2
IGJ1bmRsZXMpIFBhZ2UgTm90IFByZXNlbnQKK0VOVFJZKGt2bV9wYWdlX25vdF9wcmVzZW50KQor
ICAgIEtWTV9SRUZMRUNUKDIwKQorRU5EKGt2bV9wYWdlX25vdF9wcmVzZW50KQorCisgICAgLm9y
ZyBrdm1faWE2NF9pdnQrMHg1MTAwCisvLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLworLy8gMHg1MTAwIEVudHJ5IDIx
IChzaXplIDE2IGJ1bmRsZXMpIEtleSBQZXJtaXNzaW9uIHZlY3RvcgorRU5UUlkoa3ZtX2tleV9w
ZXJtaXNzaW9uKQorICAgIEtWTV9SRUZMRUNUKDIxKQorRU5EKGt2bV9rZXlfcGVybWlzc2lvbikK
KworICAgIC5vcmcga3ZtX2lhNjRfaXZ0KzB4NTIwMAorLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLworLy8gMHg1MjAw
IEVudHJ5IDIyIChzaXplIDE2IGJ1bmRsZXMpIEluc3RydWN0aW9uIEFjY2VzcyBSaWdodHMgKDI2
KQorRU5UUlkoa3ZtX2lhY2Nlc3NfcmlnaHRzKQorICAgIEtWTV9SRUZMRUNUKDIyKQorRU5EKGt2
bV9pYWNjZXNzX3JpZ2h0cykKKworICAgIC5vcmcga3ZtX2lhNjRfaXZ0KzB4NTMwMAorLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLworLy8gMHg1MzAwIEVudHJ5IDIzIChzaXplIDE2IGJ1bmRsZXMpIERhdGEgQWNjZXNz
IFJpZ2h0cyAoMTQsNTMpCitFTlRSWShrdm1fZGFjY2Vzc19yaWdodHMpCisgICAgS1ZNX1JFRkxF
Q1QoMjMpCitFTkQoa3ZtX2RhY2Nlc3NfcmlnaHRzKQorCisgICAgLm9yZyBrdm1faWE2NF9pdnQr
MHg1NDAwCisvLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8KKy8vIDB4NTQwMCBFbnRyeSAyNCAoc2l6ZSAxNiBidW5kbGVz
KSBHZW5lcmFsIEV4Y2VwdGlvbiAoNSwzMiwzNCwzNiwzOCwzOSkKK0VOVFJZKGt2bV9nZW5lcmFs
X2V4Y2VwdGlvbikKKyAgIEtWTV9SRUZMRUNUKDI0KQorICAgS1ZNX0ZBVUxUKDI0KQorRU5EKGt2
bV9nZW5lcmFsX2V4Y2VwdGlvbikKKworICAgIC5vcmcga3ZtX2lhNjRfaXZ0KzB4NTUwMAorLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLworLy8gMHg1NTAwIEVudHJ5IDI1IChzaXplIDE2IGJ1bmRsZXMpIERpc2FibGVk
IEZQLVJlZ2lzdGVyICgzNSkKK0VOVFJZKGt2bV9kaXNhYmxlZF9mcF9yZWcpCisgICAgS1ZNX1JF
RkxFQ1QoMjUpCitFTkQoa3ZtX2Rpc2FibGVkX2ZwX3JlZykKKworICAgIC5vcmcga3ZtX2lhNjRf
aXZ0KzB4NTYwMAorLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8KKy8vIDB4NTYwMCBFbnRyeSAyNiAoc2l6ZSAxNiBidW5k
bGVzKSBOYXQgQ29uc3VtcHRpb24gKDExLDIzLDM3LDUwKQorRU5UUlkoa3ZtX25hdF9jb25zdW1w
dGlvbikKKyAgICBLVk1fUkVGTEVDVCgyNikKK0VORChrdm1fbmF0X2NvbnN1bXB0aW9uKQorCisg
ICAgLm9yZyBrdm1faWE2NF9pdnQrMHg1NzAwCisvLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8KKy8vIDB4NTcwMCBFbnRy
eSAyNyAoc2l6ZSAxNiBidW5kbGVzKSBTcGVjdWxhdGlvbiAoNDApCitFTlRSWShrdm1fc3BlY3Vs
YXRpb25fdmVjdG9yKQorICAgIEtWTV9SRUZMRUNUKDI3KQorRU5EKGt2bV9zcGVjdWxhdGlvbl92
ZWN0b3IpCisKKyAgICAub3JnIGt2bV9pYTY0X2l2dCsweDU4MDAKKy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLworLy8g
MHg1ODAwIEVudHJ5IDI4IChzaXplIDE2IGJ1bmRsZXMpIFJlc2VydmVkCisgICAgS1ZNX0ZBVUxU
KDI4KQorCisgICAgLm9yZyBrdm1faWE2NF9pdnQrMHg1OTAwCisvLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vCisvLyAweDU5
MDAgRW50cnkgMjkgKHNpemUgMTYgYnVuZGxlcykgRGVidWcgKDE2LDI4LDU2KQorRU5UUlkoa3Zt
X2RlYnVnX3ZlY3RvcikKKyAgICBLVk1fRkFVTFQoMjkpCitFTkQoa3ZtX2RlYnVnX3ZlY3RvcikK
KworICAgIC5vcmcga3ZtX2lhNjRfaXZ0KzB4NWEwMAorLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vCisvLyAweDVhMDAgRW50cnkg
MzAgKHNpemUgMTYgYnVuZGxlcykgVW5hbGlnbmVkIFJlZmVyZW5jZSAoNTcpCitFTlRSWShrdm1f
dW5hbGlnbmVkX2FjY2VzcykKKyAgICBLVk1fUkVGTEVDVCgzMCkKK0VORChrdm1fdW5hbGlnbmVk
X2FjY2VzcykKKworICAgIC5vcmcga3ZtX2lhNjRfaXZ0KzB4NWIwMAorLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLwor
Ly8gMHg1YjAwIEVudHJ5IDMxIChzaXplIDE2IGJ1bmRsZXMpIFVuc3VwcG9ydGVkIERhdGEgUmVm
ZXJlbmNlICg1NykKK0VOVFJZKGt2bV91bnN1cHBvcnRlZF9kYXRhX3JlZmVyZW5jZSkKKyAgICBL
Vk1fUkVGTEVDVCgzMSkKK0VORChrdm1fdW5zdXBwb3J0ZWRfZGF0YV9yZWZlcmVuY2UpCisKKyAg
ICAub3JnIGt2bV9pYTY0X2l2dCsweDVjMDAKKy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vCisvLyAweDVjMDAgRW50cnkg
MzIgKHNpemUgMTYgYnVuZGxlcykgRmxvYXRpbmcgUG9pbnQgRkFVTFQgKDY1KQorRU5UUlkoa3Zt
X2Zsb2F0aW5nX3BvaW50X2ZhdWx0KQorICAgIEtWTV9SRUZMRUNUKDMyKQorRU5EKGt2bV9mbG9h
dGluZ19wb2ludF9mYXVsdCkKKworICAgIC5vcmcga3ZtX2lhNjRfaXZ0KzB4NWQwMAorLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vCisvLyAweDVkMDAgRW50cnkgMzMgKHNpemUgMTYgYnVuZGxlcykgRmxvYXRpbmcgUG9p
bnQgVHJhcCAoNjYpCitFTlRSWShrdm1fZmxvYXRpbmdfcG9pbnRfdHJhcCkKKyAgICBLVk1fUkVG
TEVDVCgzMykKK0VORChrdm1fZmxvYXRpbmdfcG9pbnRfdHJhcCkKKworICAgIC5vcmcga3ZtX2lh
NjRfaXZ0KzB4NWUwMAorLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLworLy8gMHg1ZTAwIEVudHJ5IDM0IChzaXplIDE2
IGJ1bmRsZXMpIExvd2VyIFByaXZpbGVnZSBUcmFuc2ZlciBUcmFwICg2NikKK0VOVFJZKGt2bV9s
b3dlcl9wcml2aWxlZ2VfdHJhcCkKKyAgICBLVk1fUkVGTEVDVCgzNCkKK0VORChrdm1fbG93ZXJf
cHJpdmlsZWdlX3RyYXApCisKKyAgICAub3JnIGt2bV9pYTY0X2l2dCsweDVmMDAKKy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8KKy8vIDB4NWYwMCBFbnRyeSAzNSAoc2l6ZSAxNiBidW5kbGVzKSBUYWtlbiBCcmFuY2gg
VHJhcCAoNjgpCitFTlRSWShrdm1fdGFrZW5fYnJhbmNoX3RyYXApCisgICAgS1ZNX1JFRkxFQ1Qo
MzUpCitFTkQoa3ZtX3Rha2VuX2JyYW5jaF90cmFwKQorCisgICAgLm9yZyBrdm1faWE2NF9pdnQr
MHg2MDAwCisvLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLworLy8gMHg2MDAwIEVudHJ5IDM2IChzaXplIDE2IGJ1bmRsZXMp
IFNpbmdsZSBTdGVwIFRyYXAgKDY5KQorRU5UUlkoa3ZtX3NpbmdsZV9zdGVwX3RyYXApCisgICAg
S1ZNX1JFRkxFQ1QoMzYpCitFTkQoa3ZtX3NpbmdsZV9zdGVwX3RyYXApCisgICAgLmdsb2JhbCBr
dm1fdmlydHVhbGl6YXRpb25fZmF1bHRfYmFjaworICAgIC5vcmcga3ZtX2lhNjRfaXZ0KzB4NjEw
MAorLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vCisvLyAweDYxMDAgRW50cnkgMzcgKHNpemUgMTYgYnVuZGxlcykgVmly
dHVhbGl6YXRpb24gRmF1bHQKK0VOVFJZKGt2bV92aXJ0dWFsaXphdGlvbl9mYXVsdCkKKyAgICBt
b3YgcjMxPXByCisgICAgYWRkcyByMTYgPSBWTU1fVkNQVV9TQVZFRF9HUF9PRkZTRVQscjIxCisg
ICAgOzsKKyAgICBzdDggW3IxNl0gPSByMQorICAgIGFkZHMgcjE3ID0gVk1NX1ZDUFVfR1BfT0ZG
U0VULCByMjEKKyAgICA7OworICAgIGxkOCByMSA9IFtyMTddCisgICAgY21wLmVxIHA2LHAwPUVW
RU5UX01PVl9GUk9NX0FSLHIyNAorICAgIGNtcC5lcSBwNyxwMD1FVkVOVF9NT1ZfRlJPTV9SUixy
MjQKKyAgICBjbXAuZXEgcDgscDA9RVZFTlRfTU9WX1RPX1JSLHIyNAorICAgIGNtcC5lcSBwOSxw
MD1FVkVOVF9SU00scjI0CisgICAgY21wLmVxIHAxMCxwMD1FVkVOVF9TU00scjI0CisgICAgY21w
LmVxIHAxMSxwMD1FVkVOVF9NT1ZfVE9fUFNSLHIyNAorICAgIGNtcC5lcSBwMTIscDA9RVZFTlRf
VEhBU0gscjI0CisgICAgKHA2KSBici5kcHRrLm1hbnkga3ZtX2FzbV9tb3ZfZnJvbV9hcgorICAg
IChwNykgYnIuZHB0ay5tYW55IGt2bV9hc21fbW92X2Zyb21fcnIKKyAgICAocDgpIGJyLmRwdGsu
bWFueSBrdm1fYXNtX21vdl90b19ycgorICAgIChwOSkgYnIuZHB0ay5tYW55IGt2bV9hc21fcnNt
CisgICAgKHAxMCkgYnIuZHB0ay5tYW55IGt2bV9hc21fc3NtCisgICAgKHAxMSkgYnIuZHB0ay5t
YW55IGt2bV9hc21fbW92X3RvX3BzcgorICAgIChwMTIpIGJyLmRwdGsubWFueSBrdm1fYXNtX3Ro
YXNoCisgICAgOzsKK2t2bV92aXJ0dWFsaXphdGlvbl9mYXVsdF9iYWNrOgorICAgIGFkZHMgcjE2
ID0gVk1NX1ZDUFVfU0FWRURfR1BfT0ZGU0VULHIyMQorICAgIDs7CisgICAgbGQ4IHIxID0gW3Ix
Nl0KKyAgICA7OworICAgIG1vdiByMTk9MzcKKyAgICBhZGRzIHIxNiA9IFZNTV9WQ1BVX0NBVVNF
X09GRlNFVCxyMjEKKyAgICBhZGRzIHIxNyA9IFZNTV9WQ1BVX09QQ09ERV9PRkZTRVQscjIxCisg
ICAgOzsKKyAgICBzdDggW3IxNl0gPSByMjQKKyAgICBzdDggW3IxN10gPSByMjUKKyAgICA7Owor
ICAgIGNtcC5uZSBwNixwMD1FVkVOVF9SRkksIHIyNAorICAgIChwNikgYnIuc3B0ayBrdm1fZGlz
cGF0Y2hfdmlydHVhbGl6YXRpb25fZmF1bHQKKyAgICA7OworICAgIGFkZHMgcjE4PVZNTV9WUERf
QkFTRV9PRkZTRVQscjIxCisgICAgOzsKKyAgICBsZDggcjE4PVtyMThdCisgICAgOzsKKyAgICBh
ZGRzIHIxOD1WTU1fVlBEX1ZJRlNfT0ZGU0VULHIxOAorICAgIDs7CisgICAgbGQ4IHIxOD1bcjE4
XQorICAgIDs7CisgICAgdGJpdC56IHA2LHAwPXIxOCw2MworICAgIChwNikgYnIuc3B0ayBrdm1f
ZGlzcGF0Y2hfdmlydHVhbGl6YXRpb25fZmF1bHQKKyAgICA7OworICAgIC8vaWYgdmlmcy52PTEg
ZGVzZXJ0IGN1cnJlbnQgcmVnaXN0ZXIgZnJhbWUKKyAgICBhbGxvYyByMTg9YXIucGZzLDAsMCww
LDAKKyAgICBici5zcHRrIGt2bV9kaXNwYXRjaF92aXJ0dWFsaXphdGlvbl9mYXVsdAorRU5EKGt2
bV92aXJ0dWFsaXphdGlvbl9mYXVsdCkKKworICAgIC5vcmcga3ZtX2lhNjRfaXZ0KzB4NjIwMAor
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8KKy8vIDB4NjIwMCBFbnRyeSAzOCAoc2l6ZSAxNiBidW5kbGVzKSBSZXNlcnZlZAorICAg
IEtWTV9GQVVMVCgzOCkKKworICAgIC5vcmcga3ZtX2lhNjRfaXZ0KzB4NjMwMAorLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8K
Ky8vIDB4NjMwMCBFbnRyeSAzOSAoc2l6ZSAxNiBidW5kbGVzKSBSZXNlcnZlZAorICAgIEtWTV9G
QVVMVCgzOSkKKworICAgIC5vcmcga3ZtX2lhNjRfaXZ0KzB4NjQwMAorLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8KKy8vIDB4
NjQwMCBFbnRyeSA0MCAoc2l6ZSAxNiBidW5kbGVzKSBSZXNlcnZlZAorICAgIEtWTV9GQVVMVCg0
MCkKKworICAgIC5vcmcga3ZtX2lhNjRfaXZ0KzB4NjUwMAorLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vCisvLyAweDY1MDAg
RW50cnkgNDEgKHNpemUgMTYgYnVuZGxlcykgUmVzZXJ2ZWQKKyAgICBLVk1fRkFVTFQoNDEpCisK
KyAgICAub3JnIGt2bV9pYTY0X2l2dCsweDY2MDAKKy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLworLy8gMHg2NjAwIEVudHJ5
IDQyIChzaXplIDE2IGJ1bmRsZXMpIFJlc2VydmVkCisgICAgS1ZNX0ZBVUxUKDQyKQorCisgICAg
Lm9yZyBrdm1faWE2NF9pdnQrMHg2NzAwCisvLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8KKy8vIDB4NjcwMCBFbnRyeSA0MyAo
c2l6ZSAxNiBidW5kbGVzKSBSZXNlcnZlZAorICAgIEtWTV9GQVVMVCg0MykKKworICAgIC5vcmcg
a3ZtX2lhNjRfaXZ0KzB4NjgwMAorLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vCisvLyAweDY4MDAgRW50cnkgNDQgKHNpemUg
MTYgYnVuZGxlcykgUmVzZXJ2ZWQKKyAgICBLVk1fRkFVTFQoNDQpCisKKyAgICAub3JnIGt2bV9p
YTY0X2l2dCsweDY5MDAKKy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8KKy8vIDB4NjkwMCBFbnRyeSA0NSAoc2l6ZSAxNiBi
dW5kbGVzKSBJQS0zMiBFeGVjZXB0aW9uCisvLygxNywxOCwyOSw0MSw0Miw0Myw0NCw1OCw2MCw2
MSw2Miw3Miw3Myw3NSw3Niw3NykKK0VOVFJZKGt2bV9pYTMyX2V4Y2VwdGlvbikKKyAgICBLVk1f
RkFVTFQoNDUpCitFTkQoa3ZtX2lhMzJfZXhjZXB0aW9uKQorCisgICAgLm9yZyBrdm1faWE2NF9p
dnQrMHg2YTAwCisvLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLworLy8gMHg2YTAwIEVudHJ5IDQ2IChzaXplIDE2IGJ1bmRs
ZXMpIElBLTMyIEludGVyY2VwdCAgKDMwLDMxLDU5LDcwLDcxKQorRU5UUlkoa3ZtX2lhMzJfaW50
ZXJjZXB0KQorICAgIEtWTV9GQVVMVCg0NykKK0VORChrdm1faWEzMl9pbnRlcmNlcHQpCisKKyAg
ICAub3JnIGt2bV9pYTY0X2l2dCsweDZjMDAKKy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLworLy8gMHg2YzAwIEVudHJ5
IDQ4IChzaXplIDE2IGJ1bmRsZXMpIFJlc2VydmVkCisgICAgS1ZNX0ZBVUxUKDQ4KQorCisgICAg
Lm9yZyBrdm1faWE2NF9pdnQrMHg2ZDAwCisvLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vCisvLyAweDZkMDAgRW50cnkg
NDkgKHNpemUgMTYgYnVuZGxlcykgUmVzZXJ2ZWQKKyAgICBLVk1fRkFVTFQoNDkpCisKKyAgICAu
b3JnIGt2bV9pYTY0X2l2dCsweDZlMDAKKy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8KKy8vIDB4NmUwMCBFbnRyeSA1
MCAoc2l6ZSAxNiBidW5kbGVzKSBSZXNlcnZlZAorICAgIEtWTV9GQVVMVCg1MCkKKworICAgIC5v
cmcga3ZtX2lhNjRfaXZ0KzB4NmYwMAorLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vCisvLyAweDZmMDAgRW50cnkgNTEg
KHNpemUgMTYgYnVuZGxlcykgUmVzZXJ2ZWQKKyAgICBLVk1fRkFVTFQoNTIpCisKKyAgICAub3Jn
IGt2bV9pYTY0X2l2dCsweDcxMDAKKy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vCisvLyAweDcxMDAgRW50cnkgNTMgKHNp
emUgMTYgYnVuZGxlcykgUmVzZXJ2ZWQKKyAgICBLVk1fRkFVTFQoNTMpCisKKyAgICAub3JnIGt2
bV9pYTY0X2l2dCsweDcyMDAKKy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLworLy8gMHg3MjAwIEVudHJ5IDU0IChzaXpl
IDE2IGJ1bmRsZXMpIFJlc2VydmVkCisgICAgS1ZNX0ZBVUxUKDU0KQorCisgICAgLm9yZyBrdm1f
aWE2NF9pdnQrMHg3MzAwCisvLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLworLy8gMHg3MzAwIEVudHJ5IDU1IChzaXplIDE2
IGJ1bmRsZXMpIFJlc2VydmVkCisgICAgS1ZNX0ZBVUxUKDU1KQorCisgICAgLm9yZyBrdm1faWE2
NF9pdnQrMHg3NDAwCisvLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLworLy8gMHg3NDAwIEVudHJ5IDU2IChzaXplIDE2IGJ1
bmRsZXMpIFJlc2VydmVkCisgICAgS1ZNX0ZBVUxUKDU2KQorCisgICAgLm9yZyBrdm1faWE2NF9p
dnQrMHg3NTAwCisvLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8KKy8vIDB4NzUwMCBFbnRyeSA1NyAoc2l6ZSAxNiBidW5k
bGVzKSBSZXNlcnZlZAorICAgIEtWTV9GQVVMVCg1NykKKworICAgIC5vcmcga3ZtX2lhNjRfaXZ0
KzB4NzYwMAorLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vCisvLyAweDc2MDAgRW50cnkgNTggKHNpemUgMTYgYnVuZGxl
cykgUmVzZXJ2ZWQKKyAgICBLVk1fRkFVTFQoNTgpCisKKyAgICAub3JnIGt2bV9pYTY0X2l2dCsw
eDc3MDAKKy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vCisvLyAweDc3MDAgRW50cnkgNTkgKHNpemUgMTYgYnVuZGxlcykg
UmVzZXJ2ZWQKKyAgICBLVk1fRkFVTFQoNTkpCisKKyAgICAub3JnIGt2bV9pYTY0X2l2dCsweDc4
MDAKKy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vCisvLyAweDc4MDAgRW50cnkgNjAgKHNpemUgMTYgYnVuZGxlcykgUmVz
ZXJ2ZWQKKyAgICBLVk1fRkFVTFQoNjApCisKKyAgICAub3JnIGt2bV9pYTY0X2l2dCsweDc5MDAK
Ky8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLworLy8gMHg3OTAwIEVudHJ5IDYxIChzaXplIDE2IGJ1bmRsZXMpIFJlc2Vy
dmVkCisgICAgS1ZNX0ZBVUxUKDYxKQorCisgICAgLm9yZyBrdm1faWE2NF9pdnQrMHg3YTAwCisv
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8KKy8vIDB4N2EwMCBFbnRyeSA2MiAoc2l6ZSAxNiBidW5kbGVzKSBSZXNlcnZl
ZAorICAgIEtWTV9GQVVMVCg2MikKKworICAgIC5vcmcga3ZtX2lhNjRfaXZ0KzB4N2IwMAorLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vCisvLyAweDdiMDAgRW50cnkgNjMgKHNpemUgMTYgYnVuZGxlcykgUmVzZXJ2ZWQK
KyAgICBLVk1fRkFVTFQoNjMpCisKKyAgICAub3JnIGt2bV9pYTY0X2l2dCsweDdjMDAKKy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vCisvLyAweDdjMDAgRW50cnkgNjQgKHNpemUgMTYgYnVuZGxlcykgUmVzZXJ2ZWQKKyAg
ICBLVk1fRkFVTFQoNjQpCisKKyAgICAub3JnIGt2bV9pYTY0X2l2dCsweDdkMDAKKy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLworLy8gMHg3ZDAwIEVudHJ5IDY1IChzaXplIDE2IGJ1bmRsZXMpIFJlc2VydmVkCisgICAg
S1ZNX0ZBVUxUKDY1KQorCisgICAgLm9yZyBrdm1faWE2NF9pdnQrMHg3ZTAwCisvLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8KKy8vIDB4N2UwMCBFbnRyeSA2NiAoc2l6ZSAxNiBidW5kbGVzKSBSZXNlcnZlZAorICAgIEtW
TV9GQVVMVCg2NikKKworICAgIC5vcmcga3ZtX2lhNjRfaXZ0KzB4N2YwMAorLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8K
Ky8vIDB4N2YwMCBFbnRyeSA2NyAoc2l6ZSAxNiBidW5kbGVzKSBSZXNlcnZlZAorICAgIEtWTV9G
QVVMVCg2NykKKworICAgIC5vcmcga3ZtX2lhNjRfaXZ0KzB4ODAwMAorLy8gVGhlcmUgaXMgbm8g
cGFydGljdWxhciByZWFzb24gZm9yIHRoaXMgY29kZSB0byBiZSBoZXJlLCBvdGhlciB0aGFuIHRo
YXQKKy8vIHRoZXJlIGhhcHBlbnMgdG8gYmUgc3BhY2UgaGVyZSB0aGF0IHdvdWxkIGdvIHVudXNl
ZCBvdGhlcndpc2UuICBJZiB0aGlzCisvLyBmYXVsdCBldmVyIGdldHMgInVucmVzZXJ2ZWQiLCBz
aW1wbHkgbW92ZWQgdGhlIGZvbGxvd2luZyBjb2RlIHRvIGEgbW9yZQorLy8gc3VpdGFibGUgc3Bv
dC4uLgorCisKK0VOVFJZKGt2bV9kdGxiX21pc3NfZGlzcGF0Y2gpCisgICAgbW92IHIxOSA9IDIK
KyAgICBLVk1fU0FWRV9NSU5fV0lUSF9DT1ZFUl9SMTkKKyAgICBhbGxvYyByMTQ9YXIucGZzLDAs
MCwzLDAKKyAgICBtb3Ygb3V0MD1jci5pZmEKKyAgICBtb3Ygb3V0MT1yMTUKKyAgICBhZGRzIHIz
PTgscjIgICAgICAgICAgICAgICAgLy8gc2V0IHVwIHNlY29uZCBiYXNlIHBvaW50ZXIKKyAgICA7
OworICAgIHNzbSBwc3IuaWMKKyAgICA7OworICAgIHNybHouaSAgICAgICAgICAgICAgICAgIC8v
IGd1YXJhbnRlZSB0aGF0IGludGVycnVwdGlvbiBjb2xsZWN0aW9uIGlzIG9uCisgICAgOzsKKyAg
ICAvLyhwMTUpIHNzbSBwc3IuaSAgICAgICAgICAgICAgIC8vIHJlc3RvcmUgcHNyLmkKKyAgICBh
ZGRsIHIxND1AZ3ByZWwoaWE2NF9sZWF2ZV9oeXBlcnZpc29yX3ByZXBhcmUpLGdwCisgICAgOzsK
KyAgICBLVk1fU0FWRV9SRVNUCisgICAgS1ZNX1NBVkVfRVhUUkEKKyAgICBtb3YgcnA9cjE0Cisg
ICAgOzsKKyAgICBhZGRzIG91dDI9MTYscjEyCisgICAgYnIuY2FsbC5zcHRrLm1hbnkgYjY9a3Zt
X3BhZ2VfZmF1bHQKK0VORChrdm1fZHRsYl9taXNzX2Rpc3BhdGNoKQorCitFTlRSWShrdm1faXRs
Yl9taXNzX2Rpc3BhdGNoKQorCisgICAgS1ZNX1NBVkVfTUlOX1dJVEhfQ09WRVJfUjE5CisgICAg
YWxsb2MgcjE0PWFyLnBmcywwLDAsMywwCisgICAgbW92IG91dDA9Y3IuaWZhCisgICAgbW92IG91
dDE9cjE1CisgICAgYWRkcyByMz04LHIyICAgICAgICAgICAgICAgIC8vIHNldCB1cCBzZWNvbmQg
YmFzZSBwb2ludGVyCisgICAgOzsKKyAgICBzc20gcHNyLmljCisgICAgOzsKKyAgICBzcmx6Lmkg
ICAgICAgICAgICAgICAgICAvLyBndWFyYW50ZWUgdGhhdCBpbnRlcnJ1cHRpb24gY29sbGVjdGlv
biBpcyBvbgorICAgIDs7CisgICAgLy8ocDE1KSBzc20gcHNyLmkgICAgICAgICAgICAgICAvLyBy
ZXN0b3JlIHBzci5pCisgICAgYWRkbCByMTQ9QGdwcmVsKGlhNjRfbGVhdmVfaHlwZXJ2aXNvciks
Z3AKKyAgICA7OworICAgIEtWTV9TQVZFX1JFU1QKKyAgICBtb3YgcnA9cjE0CisgICAgOzsKKyAg
ICBhZGRzIG91dDI9MTYscjEyCisgICAgYnIuY2FsbC5zcHRrLm1hbnkgYjY9a3ZtX3BhZ2VfZmF1
bHQKK0VORChrdm1faXRsYl9taXNzX2Rpc3BhdGNoKQorCitFTlRSWShrdm1fZGlzcGF0Y2hfcmVm
bGVjdGlvbikKKyAgICAvKgorICAgICAqIElucHV0OgorICAgICAqICBwc3IuaWM6IG9mZgorICAg
ICAqICByMTk6ICAgIGludHIgdHlwZSAob2Zmc2V0IGludG8gaXZ0LCBzZWUgaWE2NF9pbnQuaCkK
KyAgICAgKiAgcjMxOiAgICBjb250YWlucyBzYXZlZCBwcmVkaWNhdGVzIChwcikKKyAgICAgKi8K
KyAgICBLVk1fU0FWRV9NSU5fV0lUSF9DT1ZFUl9SMTkKKyAgICBhbGxvYyByMTQ9YXIucGZzLDAs
MCw1LDAKKyAgICBtb3Ygb3V0MD1jci5pZmEKKyAgICBtb3Ygb3V0MT1jci5pc3IKKyAgICBtb3Yg
b3V0Mj1jci5paW0KKyAgICBtb3Ygb3V0Mz1yMTUKKyAgICBhZGRzIHIzPTgscjIgICAgICAgICAg
ICAgICAgLy8gc2V0IHVwIHNlY29uZCBiYXNlIHBvaW50ZXIKKyAgICA7OworICAgIHNzbSBwc3Iu
aWMKKyAgICA7OworICAgIHNybHouaSAgICAgICAgICAgICAgICAgIC8vIGd1YXJhbnRlZSB0aGF0
IGludGVycnVwdGlvbiBjb2xsZWN0aW9uIGlzIG9uCisgICAgOzsKKyAgICAvLyhwMTUpIHNzbSBw
c3IuaSAgICAgICAgICAgICAgIC8vIHJlc3RvcmUgcHNyLmkKKyAgICBhZGRsIHIxND1AZ3ByZWwo
aWE2NF9sZWF2ZV9oeXBlcnZpc29yKSxncAorICAgIDs7CisgICAgS1ZNX1NBVkVfUkVTVAorICAg
IG1vdiBycD1yMTQKKyAgICA7OworICAgIGFkZHMgb3V0ND0xNixyMTIKKyAgICBici5jYWxsLnNw
dGsubWFueSBiNj1yZWZsZWN0X2ludGVycnVwdGlvbgorRU5EKGt2bV9kaXNwYXRjaF9yZWZsZWN0
aW9uKQorCitFTlRSWShrdm1fZGlzcGF0Y2hfdmlydHVhbGl6YXRpb25fZmF1bHQpCisgICAgYWRk
cyByMTYgPSBWTU1fVkNQVV9DQVVTRV9PRkZTRVQscjIxCisgICAgYWRkcyByMTcgPSBWTU1fVkNQ
VV9PUENPREVfT0ZGU0VULHIyMQorICAgIDs7CisgICAgc3Q4IFtyMTZdID0gcjI0CisgICAgc3Q4
IFtyMTddID0gcjI1CisgICAgOzsKKyAgICBLVk1fU0FWRV9NSU5fV0lUSF9DT1ZFUl9SMTkKKyAg
ICA7OworICAgIGFsbG9jIHIxND1hci5wZnMsMCwwLDIsMCAvLyBub3cgaXQncyBzYWZlIChtdXN0
IGJlIGZpcnN0IGluIGluc24gZ3JvdXAhKQorICAgIG1vdiBvdXQwPXIxMyAgICAgICAgLy92Y3B1
CisgICAgYWRkcyByMz04LHIyICAgICAgICAgICAgICAgIC8vIHNldCB1cCBzZWNvbmQgYmFzZSBw
b2ludGVyCisgICAgOzsKKyAgICBzc20gcHNyLmljCisgICAgOzsKKyAgICBzcmx6LmkgICAgICAg
ICAgICAgICAgICAvLyBndWFyYW50ZWUgdGhhdCBpbnRlcnJ1cHRpb24gY29sbGVjdGlvbiBpcyBv
bgorICAgIDs7CisgICAgLy8ocDE1KSBzc20gcHNyLmkgICAgICAgICAgICAgICAvLyByZXN0b3Jl
IHBzci5pCisgICAgYWRkbCByMTQ9QGdwcmVsKGlhNjRfbGVhdmVfaHlwZXJ2aXNvcl9wcmVwYXJl
KSxncAorICAgIDs7CisgICAgS1ZNX1NBVkVfUkVTVAorICAgIEtWTV9TQVZFX0VYVFJBCisgICAg
bW92IHJwPXIxNAorICAgIDs7CisgICAgYWRkcyBvdXQxPTE2LHNwICAgICAgICAgLy9yZWdzCisg
ICAgYnIuY2FsbC5zcHRrLm1hbnkgYjY9a3ZtX2VtdWxhdGUKK0VORChrdm1fZGlzcGF0Y2hfdmly
dHVhbGl6YXRpb25fZmF1bHQpCisKKworRU5UUlkoa3ZtX2Rpc3BhdGNoX2ludGVycnVwdCkKKyAg
ICBLVk1fU0FWRV9NSU5fV0lUSF9DT1ZFUl9SMTkJLy8gdXNlcyByMzE7IGRlZmluZXMgcjIgYW5k
IHIzCisgICAgOzsKKyAgICBhbGxvYyByMTQ9YXIucGZzLDAsMCwxLDAgLy8gbXVzdCBiZSBmaXJz
dCBpbiBhbiBpbnNuIGdyb3VwCisgICAgLy9tb3Ygb3V0MD1jci5pdnIJCS8vIHBhc3MgY3IuaXZy
IGFzIGZpcnN0IGFyZworICAgIGFkZHMgcjM9OCxyMgkJLy8gc2V0IHVwIHNlY29uZCBiYXNlIHBv
aW50ZXIgZm9yIFNBVkVfUkVTVAorICAgIDs7CisgICAgc3NtIHBzci5pYworICAgIDs7CisgICAg
c3Jsei5pCisgICAgOzsKKyAgICAvLyhwMTUpIHNzbSBwc3IuaQorICAgIGFkZGwgcjE0PUBncHJl
bChpYTY0X2xlYXZlX2h5cGVydmlzb3IpLGdwCisgICAgOzsKKyAgICBLVk1fU0FWRV9SRVNUCisg
ICAgbW92IHJwPXIxNAorICAgIDs7CisgICAgbW92IG91dDA9cjEzCQkvLyBwYXNzIHBvaW50ZXIg
dG8gcHRfcmVncyBhcyBzZWNvbmQgYXJnCisgICAgYnIuY2FsbC5zcHRrLm1hbnkgYjY9a3ZtX2lh
NjRfaGFuZGxlX2lycQorRU5EKGt2bV9kaXNwYXRjaF9pbnRlcnJ1cHQpCisKKworCisKK0dMT0JB
TF9FTlRSWShpYTY0X2xlYXZlX25lc3RlZCkKKwlyc20gcHNyLmkKKwk7OworCWFkZHMgcjIxPVBU
KFBSKSsxNixyMTIKKwk7OworCWxmZXRjaCBbcjIxXSxQVChDUl9JUFNSKS1QVChQUikKKwlhZGRz
IHIyPVBUKEI2KSsxNixyMTIKKwlhZGRzIHIzPVBUKFIxNikrMTYscjEyCisJOzsKKwlsZmV0Y2gg
W3IyMV0KKwlsZDggcjI4PVtyMl0sOAkJLy8gbG9hZCBiNgorCWFkZHMgcjI5PVBUKFIyNCkrMTYs
cjEyCisKKwlsZDguZmlsbCByMTY9W3IzXQorCWFkZHMgcjM9UFQoQVJfQ1NEKS1QVChSMTYpLHIz
CisJYWRkcyByMzA9UFQoQVJfQ0NWKSsxNixyMTIKKwk7OworCWxkOC5maWxsIHIyND1bcjI5XQor
CWxkOCByMTU9W3IzMF0JCS8vIGxvYWQgYXIuY2N2CisJOzsKKwlsZDggcjI5PVtyMl0sMTYJCS8v
IGxvYWQgYjcKKwlsZDggcjMwPVtyM10sMTYJCS8vIGxvYWQgYXIuY3NkCisJOzsKKwlsZDggcjMx
PVtyMl0sMTYJCS8vIGxvYWQgYXIuc3NkCisJbGQ4LmZpbGwgcjg9W3IzXSwxNgorCTs7CisJbGQ4
LmZpbGwgcjk9W3IyXSwxNgorCWxkOC5maWxsIHIxMD1bcjNdLFBUKFIxNyktUFQoUjEwKQorCTs7
CisJbGQ4LmZpbGwgcjExPVtyMl0sUFQoUjE4KS1QVChSMTEpCisJbGQ4LmZpbGwgcjE3PVtyM10s
MTYKKwk7OworCWxkOC5maWxsIHIxOD1bcjJdLDE2CisJbGQ4LmZpbGwgcjE5PVtyM10sMTYKKwk7
OworCWxkOC5maWxsIHIyMD1bcjJdLDE2CisJbGQ4LmZpbGwgcjIxPVtyM10sMTYKKwltb3YgYXIu
Y3NkPXIzMAorCW1vdiBhci5zc2Q9cjMxCisJOzsKKwlyc20gcHNyLmkgfCBwc3IuaWMKKwkvLyBp
bml0aWF0ZSB0dXJuaW5nIG9mZiBvZiBpbnRlcnJ1cHQgYW5kIGludGVycnVwdGlvbiBjb2xsZWN0
aW9uCisJaW52YWxhCQkJLy8gaW52YWxpZGF0ZSBBTEFUCisJOzsKKwlsZDguZmlsbCByMjI9W3Iy
XSwyNAorCWxkOC5maWxsIHIyMz1bcjNdLDI0CisJbW92IGI2PXIyOAorCTs7CisJbGQ4LmZpbGwg
cjI1PVtyMl0sMTYKKwlsZDguZmlsbCByMjY9W3IzXSwxNgorCW1vdiBiNz1yMjkKKwk7OworCWxk
OC5maWxsIHIyNz1bcjJdLDE2CisJbGQ4LmZpbGwgcjI4PVtyM10sMTYKKwk7OworCWxkOC5maWxs
IHIyOT1bcjJdLDE2CisJbGQ4LmZpbGwgcjMwPVtyM10sMjQKKwk7OworCWxkOC5maWxsIHIzMT1b
cjJdLFBUKEY5KS1QVChSMzEpCisJYWRkcyByMz1QVChGMTApLVBUKEY2KSxyMworCTs7CisJbGRm
LmZpbGwgZjk9W3IyXSxQVChGNiktUFQoRjkpCisJbGRmLmZpbGwgZjEwPVtyM10sUFQoRjgpLVBU
KEYxMCkKKwk7OworCWxkZi5maWxsIGY2PVtyMl0sUFQoRjcpLVBUKEY2KQorCTs7CisJbGRmLmZp
bGwgZjc9W3IyXSxQVChGMTEpLVBUKEY3KQorCWxkZi5maWxsIGY4PVtyM10sMzIKKwk7OworCXNy
bHouaQkJCS8vIGVuc3VyZSBpbnRlcnJ1cHRpb24gY29sbGVjdGlvbiBpcyBvZmYKKwltb3YgYXIu
Y2N2PXIxNQorCTs7CisJYnN3LjAJLy8gc3dpdGNoIGJhY2sgdG8gYmFuayAwIChubyBzdG9wIGJp
dCByZXF1aXJlZCBiZWZvcmVoYW5kLi4uKQorCTs7CisJbGRmLmZpbGwgZjExPVtyMl0KKy8vCW1v
diByMTg9cjEzCisvLyAgICBtb3YgcjIxPXIxMworCWFkZHMgcjE2PVBUKENSX0lQU1IpKzE2LHIx
MgorCWFkZHMgcjE3PVBUKENSX0lJUCkrMTYscjEyCisJOzsKKwlsZDggcjI5PVtyMTZdLDE2CS8v
IGxvYWQgY3IuaXBzcgorCWxkOCByMjg9W3IxN10sMTYJLy8gbG9hZCBjci5paXAKKwk7OworCWxk
OCByMzA9W3IxNl0sMTYJLy8gbG9hZCBjci5pZnMKKwlsZDggcjI1PVtyMTddLDE2CS8vIGxvYWQg
YXIudW5hdAorCTs7CisJbGQ4IHIyNj1bcjE2XSwxNgkvLyBsb2FkIGFyLnBmcworCWxkOCByMjc9
W3IxN10sMTYJLy8gbG9hZCBhci5yc2MKKwljbXAuZXEgcDkscDA9cjAscjAKKwkvLyBzZXQgcDkg
dG8gaW5kaWNhdGUgdGhhdCB3ZSBzaG91bGQgcmVzdG9yZSBjci5pZnMKKwk7OworCWxkOCByMjQ9
W3IxNl0sMTYJLy8gbG9hZCBhci5ybmF0IChtYXkgYmUgZ2FyYmFnZSkKKwlsZDggcjIzPVtyMTdd
LDE2Ly8gbG9hZCBhci5ic3BzdG9yZSAobWF5IGJlIGdhcmJhZ2UpCisJOzsKKwlsZDggcjMxPVty
MTZdLDE2CS8vIGxvYWQgcHJlZGljYXRlcworCWxkOCByMjI9W3IxN10sMTYJLy8gbG9hZCBiMAor
CTs7CisJbGQ4IHIxOT1bcjE2XSwxNgkvLyBsb2FkIGFyLnJzYyB2YWx1ZSBmb3IgImxvYWRycyIK
KwlsZDguZmlsbCByMT1bcjE3XSwxNgkvLyBsb2FkIHIxCisJOzsKKwlsZDguZmlsbCByMTI9W3Ix
Nl0sMTYKKwlsZDguZmlsbCByMTM9W3IxN10sMTYKKwk7OworCWxkOCByMjA9W3IxNl0sMTYJLy8g
YXIuZnBzcgorCWxkOC5maWxsIHIxNT1bcjE3XSwxNgorCTs7CisJbGQ4LmZpbGwgcjE0PVtyMTZd
LDE2CisJbGQ4LmZpbGwgcjI9W3IxN10KKwk7OworCWxkOC5maWxsIHIzPVtyMTZdCisJOzsKKwlt
b3YgcjE2PWFyLmJzcAkJLy8gZ2V0IGV4aXN0aW5nIGJhY2tpbmcgc3RvcmUgcG9pbnRlcgorCTs7
CisJbW92IGIwPXIyMgorCW1vdiBhci5wZnM9cjI2CisJbW92IGNyLmlmcz1yMzAKKwltb3YgY3Iu
aXBzcj1yMjkKKwltb3YgYXIuZnBzcj1yMjAKKwltb3YgY3IuaWlwPXIyOAorCTs7CisJbW92IGFy
LnJzYz1yMjcKKwltb3YgYXIudW5hdD1yMjUKKwltb3YgcHI9cjMxLC0xCisJcmZpCitFTkQoaWE2
NF9sZWF2ZV9uZXN0ZWQpCisKKworCitHTE9CQUxfRU5UUlkoaWE2NF9sZWF2ZV9oeXBlcnZpc29y
X3ByZXBhcmUpCisgICAgLyoKKyAgICAgKiB3b3JrLm5lZWRfcmVzY2hlZCBldGMuIG11c3RuJ3Qg
Z2V0IGNoYW5nZWQKKyAgICAgKmJ5IHRoaXMgQ1BVIGJlZm9yZSBpdCByZXR1cm5zIHRvCisgICAg
OzsKKyAgICAgKiB1c2VyLSBvciBmc3lzLW1vZGUsIGhlbmNlIHdlIGRpc2FibGUgaW50ZXJydXB0
cyBlYXJseSBvbjoKKyAgICAgKi8KKyAgICBhZGRzIHIyID0gUFQoUjQpKzE2LHIxMgorICAgIGFk
ZHMgcjMgPSBQVChSNSkrMTYscjEyCisgICAgYWRkcyByOCA9IFBUKEVNTF9VTkFUKSsxNixyMTIK
KyAgICA7OworICAgIGxkOCByOCA9IFtyOF0KKyAgICA7OworICAgIG1vdiBhci51bmF0PXI4Cisg
ICAgOzsKKyAgICBsZDguZmlsbCByND1bcjJdLDE2ICAgIC8vbG9hZCByNAorICAgIGxkOC5maWxs
IHI1PVtyM10sMTYgICAgLy9sb2FkIHI1CisgICAgOzsKKyAgICBsZDguZmlsbCByNj1bcjJdICAg
IC8vbG9hZCByNgorICAgIGxkOC5maWxsIHI3PVtyM10gICAgLy9sb2FkIHI3CisgICAgOzsKK0VO
RChpYTY0X2xlYXZlX2h5cGVydmlzb3JfcHJlcGFyZSkKKy8vZmFsbCB0aHJvdWdoCitHTE9CQUxf
RU5UUlkoaWE2NF9sZWF2ZV9oeXBlcnZpc29yKQorICAgIHJzbSBwc3IuaQorICAgIDs7CisgICAg
YnIuY2FsbC5zcHRrLm1hbnkgYjA9bGVhdmVfaHlwZXJ2aXNvcl90YWlsCisgICAgOzsKKyAgICBh
ZGRzIHIyMD1QVChQUikrMTYscjEyCisgICAgYWRkcyByOD1QVChFTUxfVU5BVCkrMTYscjEyCisg
ICAgOzsKKyAgICBsZDggcjg9W3I4XQorICAgIDs7CisgICAgbW92IGFyLnVuYXQ9cjgKKyAgICA7
OworICAgIGxmZXRjaCBbcjIwXSxQVChDUl9JUFNSKS1QVChQUikKKyAgICBhZGRzIHIyID0gUFQo
QjYpKzE2LHIxMgorICAgIGFkZHMgcjMgPSBQVChCNykrMTYscjEyCisgICAgOzsKKyAgICBsZmV0
Y2ggW3IyMF0KKyAgICA7OworICAgIGxkOCByMjQ9W3IyXSwxNiAgICAgICAgLyogQjYgKi8KKyAg
ICBsZDggcjI1PVtyM10sMTYgICAgICAgIC8qIEI3ICovCisgICAgOzsKKyAgICBsZDggcjI2PVty
Ml0sMTYgICAgICAgIC8qIGFyX2NzZCAqLworICAgIGxkOCByMjc9W3IzXSwxNiAgICAgICAgLyog
YXJfc3NkICovCisgICAgbW92IGI2ID0gcjI0CisgICAgOzsKKyAgICBsZDguZmlsbCByOD1bcjJd
LDE2CisgICAgbGQ4LmZpbGwgcjk9W3IzXSwxNgorICAgIG1vdiBiNyA9IHIyNQorICAgIDs7Cisg
ICAgbW92IGFyLmNzZCA9IHIyNgorICAgIG1vdiBhci5zc2QgPSByMjcKKyAgICA7OworICAgIGxk
OC5maWxsIHIxMD1bcjJdLFBUKFIxNSktUFQoUjEwKQorICAgIGxkOC5maWxsIHIxMT1bcjNdLFBU
KFIxNCktUFQoUjExKQorICAgIDs7CisgICAgbGQ4LmZpbGwgcjE1PVtyMl0sUFQoUjE2KS1QVChS
MTUpCisgICAgbGQ4LmZpbGwgcjE0PVtyM10sUFQoUjE3KS1QVChSMTQpCisgICAgOzsKKyAgICBs
ZDguZmlsbCByMTY9W3IyXSwxNgorICAgIGxkOC5maWxsIHIxNz1bcjNdLDE2CisgICAgOzsKKyAg
ICBsZDguZmlsbCByMTg9W3IyXSwxNgorICAgIGxkOC5maWxsIHIxOT1bcjNdLDE2CisgICAgOzsK
KyAgICBsZDguZmlsbCByMjA9W3IyXSwxNgorICAgIGxkOC5maWxsIHIyMT1bcjNdLDE2CisgICAg
OzsKKyAgICBsZDguZmlsbCByMjI9W3IyXSwxNgorICAgIGxkOC5maWxsIHIyMz1bcjNdLDE2Cisg
ICAgOzsKKyAgICBsZDguZmlsbCByMjQ9W3IyXSwxNgorICAgIGxkOC5maWxsIHIyNT1bcjNdLDE2
CisgICAgOzsKKyAgICBsZDguZmlsbCByMjY9W3IyXSwxNgorICAgIGxkOC5maWxsIHIyNz1bcjNd
LDE2CisgICAgOzsKKyAgICBsZDguZmlsbCByMjg9W3IyXSwxNgorICAgIGxkOC5maWxsIHIyOT1b
cjNdLDE2CisgICAgOzsKKyAgICBsZDguZmlsbCByMzA9W3IyXSxQVChGNiktUFQoUjMwKQorICAg
IGxkOC5maWxsIHIzMT1bcjNdLFBUKEY3KS1QVChSMzEpCisgICAgOzsKKyAgICByc20gcHNyLmkg
fCBwc3IuaWMKKyAgICAvLyBpbml0aWF0ZSB0dXJuaW5nIG9mZiBvZiBpbnRlcnJ1cHQgYW5kIGlu
dGVycnVwdGlvbiBjb2xsZWN0aW9uCisgICAgaW52YWxhICAgICAgICAgIC8vIGludmFsaWRhdGUg
QUxBVAorICAgIDs7CisgICAgc3Jsei5pICAgICAgICAgIC8vIGVuc3VyZSBpbnRlcnJ1cHRpb24g
Y29sbGVjdGlvbiBpcyBvZmYKKyAgICA7OworICAgIGJzdy4wCisgICAgOzsKKyAgICBhZGRzIHIx
NiA9IFBUKENSX0lQU1IpKzE2LHIxMgorICAgIGFkZHMgcjE3ID0gUFQoQ1JfSUlQKSsxNixyMTIK
KyAgICBtb3YgcjIxPXIxMwkJLy8gZ2V0IGN1cnJlbnQKKyAgICA7OworICAgIGxkOCByMzE9W3Ix
Nl0sMTYgICAgLy8gbG9hZCBjci5pcHNyCisgICAgbGQ4IHIzMD1bcjE3XSwxNiAgICAvLyBsb2Fk
IGNyLmlpcAorICAgIDs7CisgICAgbGQ4IHIyOT1bcjE2XSwxNiAgICAvLyBsb2FkIGNyLmlmcwor
ICAgIGxkOCByMjg9W3IxN10sMTYgICAgLy8gbG9hZCBhci51bmF0CisgICAgOzsKKyAgICBsZDgg
cjI3PVtyMTZdLDE2ICAgIC8vIGxvYWQgYXIucGZzCisgICAgbGQ4IHIyNj1bcjE3XSwxNiAgICAv
LyBsb2FkIGFyLnJzYworICAgIDs7CisgICAgbGQ4IHIyNT1bcjE2XSwxNiAgICAvLyBsb2FkIGFy
LnJuYXQKKyAgICBsZDggcjI0PVtyMTddLDE2ICAgIC8vIGxvYWQgYXIuYnNwc3RvcmUKKyAgICA7
OworICAgIGxkOCByMjM9W3IxNl0sMTYgICAgLy8gbG9hZCBwcmVkaWNhdGVzCisgICAgbGQ4IHIy
Mj1bcjE3XSwxNiAgICAvLyBsb2FkIGIwCisgICAgOzsKKyAgICBsZDggcjIwPVtyMTZdLDE2ICAg
IC8vIGxvYWQgYXIucnNjIHZhbHVlIGZvciAibG9hZHJzIgorICAgIGxkOC5maWxsIHIxPVtyMTdd
LDE2ICAgIC8vbG9hZCByMQorICAgIDs7CisgICAgbGQ4LmZpbGwgcjEyPVtyMTZdLDE2ICAgIC8v
bG9hZCByMTIKKyAgICBsZDguZmlsbCByMTM9W3IxN10sUFQoUjIpLVBUKFIxMykgICAgLy9sb2Fk
IHIxMworICAgIDs7CisgICAgbGQ4IHIxOT1bcjE2XSxQVChSMyktUFQoQVJfRlBTUikgICAgLy9s
b2FkIGFyX2Zwc3IKKyAgICBsZDguZmlsbCByMj1bcjE3XSxQVChBUl9DQ1YpLVBUKFIyKSAgICAv
L2xvYWQgcjIKKyAgICA7OworICAgIGxkOC5maWxsIHIzPVtyMTZdCS8vbG9hZCByMworICAgIGxk
OCByMTg9W3IxN10JLy9sb2FkIGFyX2NjdgorICAgIDs7CisgICAgbW92IGFyLmZwc3I9cjE5Cisg
ICAgbW92IGFyLmNjdj1yMTgKKyAgICBzaHIudSByMTg9cjIwLDE2CisgICAgOzsKK2t2bV9yYnNf
c3dpdGNoOgorICAgIG1vdiByMTk9OTYKKwora3ZtX2RvbnRfcHJlc2VydmVfY3VycmVudF9mcmFt
ZToKKy8qCisgICAgKiBUbyBwcmV2ZW50IGxlYWtpbmcgYml0cyBiZXR3ZWVuIHRoZSBoeXBlcnZp
c29yIGFuZCBndWVzdCBkb21haW4sCisgICAgKiB3ZSBtdXN0IGNsZWFyIHRoZSBzdGFja2VkIHJl
Z2lzdGVycyBpbiB0aGUgImludmFsaWQiIHBhcnRpdGlvbiBoZXJlLgorICAgICogNSByZWdpc3Rl
cnMvY3ljbGUgb24gTWNLaW5sZXkpLgorICAgICovCisjICAgZGVmaW5lIHBSZWN1cnNlCXA2Cisj
ICAgZGVmaW5lIHBSZXR1cm4JcDcKKyMgICBkZWZpbmUgTnJlZ3MJMTQKKworICAgIGFsbG9jIGxv
YzA9YXIucGZzLDIsTnJlZ3MtMiwyLDAKKyAgICBzaHIudSBsb2MxPXIxOCw5CQkvLyBSTmFUc2xv
dHMgPD0gZmxvb3IoZGlydHlTaXplIC8gKDY0KjgpKQorICAgIHN1YiByMTk9cjE5LHIxOAkJLy8g
cjE5ID0gKHBoeXNTdGFja2VkU2l6ZSArIDgpIC0gZGlydHlTaXplCisgICAgOzsKKyAgICBtb3Yg
YXIucnNjPXIyMAkJLy8gbG9hZCBhci5yc2MgdG8gYmUgdXNlZCBmb3IgImxvYWRycyIKKyAgICBz
aGxhZGQgaW4wPWxvYzEsMyxyMTkKKyAgICBtb3YgaW4xPTAKKyAgICA7OworICAgIFRFWFRfQUxJ
R04oMzIpCitrdm1fcnNlX2NsZWFyX2ludmFsaWQ6CisgICAgYWxsb2MgbG9jMD1hci5wZnMsMixO
cmVncy0yLDIsMAorICAgIGNtcC5sdCBwUmVjdXJzZSxwMD1OcmVncyo4LGluMAorICAgIC8vIGlm
IG1vcmUgdGhhbiBOcmVncyByZWdzIGxlZnQgdG8gY2xlYXIsIChyZSljdXJzZQorICAgIGFkZCBv
dXQwPS1OcmVncyo4LGluMAorICAgIGFkZCBvdXQxPTEsaW4xCQkvLyBpbmNyZW1lbnQgcmVjdXJz
aW9uIGNvdW50CisgICAgbW92IGxvYzE9MAorICAgIG1vdiBsb2MyPTAKKyAgICA7OworICAgIG1v
diBsb2MzPTAKKyAgICBtb3YgbG9jND0wCisgICAgbW92IGxvYzU9MAorICAgIG1vdiBsb2M2PTAK
KyAgICBtb3YgbG9jNz0wCisocFJlY3Vyc2UpIGJyLmNhbGwuZHB0ay5mZXcgYjA9a3ZtX3JzZV9j
bGVhcl9pbnZhbGlkCisgICAgOzsKKyAgICBtb3YgbG9jOD0wCisgICAgbW92IGxvYzk9MAorICAg
IGNtcC5uZSBwUmV0dXJuLHAwPXIwLGluMQorICAgIC8vIGlmIHJlY3Vyc2lvbiBjb3VudCAhPSAw
LCB3ZSBuZWVkIHRvIGRvIGEgYnIucmV0CisgICAgbW92IGxvYzEwPTAKKyAgICBtb3YgbG9jMTE9
MAorKHBSZXR1cm4pIGJyLnJldC5kcHRrLm1hbnkgYjAKKworIwl1bmRlZiBwUmVjdXJzZQorIwl1
bmRlZiBwUmV0dXJuCisKKy8vIGxvYWRycyBoYXMgYWxyZWFkeSBiZWVuIHNoaWZ0ZWQKKyAgICBh
bGxvYyByMTY9YXIucGZzLDAsMCwwLDAgICAgLy8gZHJvcCBjdXJyZW50IHJlZ2lzdGVyIGZyYW1l
CisgICAgOzsKKyAgICBsb2FkcnMKKyAgICA7OworICAgIG1vdiBhci5ic3BzdG9yZT1yMjQKKyAg
ICA7OworICAgIG1vdiBhci51bmF0PXIyOAorICAgIG1vdiBhci5ybmF0PXIyNQorICAgIG1vdiBh
ci5yc2M9cjI2CisgICAgOzsKKyAgICBtb3YgY3IuaXBzcj1yMzEKKyAgICBtb3YgY3IuaWlwPXIz
MAorICAgIG1vdiBjci5pZnM9cjI5CisgICAgbW92IGFyLnBmcz1yMjcKKyAgICBhZGRzIHIxOD1W
TU1fVlBEX0JBU0VfT0ZGU0VULHIyMQorICAgIDs7CisgICAgbGQ4IHIxOD1bcjE4XSAgIC8vdnBk
CisgICAgYWRkcyByMTc9Vk1NX1ZDUFVfSVNSX09GRlNFVCxyMjEKKyAgICA7OworICAgIGxkOCBy
MTc9W3IxN10KKyAgICBhZGRzIHIxOT1WTU1fVlBEX1ZQU1JfT0ZGU0VULHIxOAorICAgIDs7Cisg
ICAgbGQ4IHIxOT1bcjE5XSAgICAgICAgLy92cHNyCisgICAgYWRkcyByMjA9Vk1NX1ZDUFVfVlNB
X0JBU0VfT0ZGU0VULHIyMQorICAgIDs7CisgICAgbGQ4IHIyMD1bcjIwXQorICAgIDs7CisvL3Zz
YV9zeW5jX3dyaXRlX3N0YXJ0CisgICAgbW92IHIyNT1yMTgKKyAgICBhZGRzIHIxNj0gVk1NX1ZD
UFVfR1BfT0ZGU0VULHIyMQorICAgIDs7CisgICAgbGQ4IHIxNj0gW3IxNl0gLy8gUHV0IGdwIGlu
IHIyNAorICAgIG1vdmwgcjI0PUBncHJlbChpYTY0X3ZtbV9lbnRyeSkgIC8vIGNhbGN1bGF0ZSBy
ZXR1cm4gYWRkcmVzcworICAgIDs7CisgICAgYWRkICByMjQ9cjI0LHIxNgorICAgIDs7CisgICAg
YWRkIHIxNj1QQUxfVlBTX1NZTkNfV1JJVEUscjIwCisgICAgOzsKKyAgICBtb3YgYjA9cjE2Cisg
ICAgYnIuY29uZC5zcHRrIGIwICAgICAgICAgLy8gY2FsbCB0aGUgc2VydmljZQorICAgIDs7CitF
TkQoaWE2NF9sZWF2ZV9oeXBlcnZpc29yKQorLy8gZmFsbCB0aHJvdWdoCitHTE9CQUxfRU5UUlko
aWE2NF92bW1fZW50cnkpCisvKgorICogIG11c3QgYmUgYXQgYmFuayAwCisgKiAgcGFyYW1ldGVy
OgorICogIHIxNzpjci5pc3IKKyAqICByMTg6dnBkCisgKiAgcjE5OnZwc3IKKyAqICByMjA6X192
c2FfYmFzZQorICogIHIyMjpiMAorICogIHIyMzpwcmVkaWNhdGUKKyAqLworICAgIG1vdiByMjQ9
cjIyCisgICAgbW92IHIyNT1yMTgKKyAgICB0Yml0Lm56IHAxLHAyID0gcjE5LElBNjRfUFNSX0lD
X0JJVCAgICAgICAgLy8gcDE9dnBzci5pYworICAgIDs7CisgICAgKHAxKSBhZGQgcjI5PVBBTF9W
UFNfUkVTVU1FX05PUk1BTCxyMjAKKyAgICAocDEpIGJyLnNwdGsubWFueSBpYTY0X3ZtbV9lbnRy
eV9vdXQKKyAgICA7OworICAgIHRiaXQubnogcDEscDIgPSByMTcsSUE2NF9JU1JfSVJfQklUCQkv
L3AxPWNyLmlzci5pcgorICAgIDs7CisgICAgKHAxKSBhZGQgcjI5PVBBTF9WUFNfUkVTVU1FX05P
Uk1BTCxyMjAKKyAgICAocDIpIGFkZCByMjk9UEFMX1ZQU19SRVNVTUVfSEFORExFUixyMjAKKyAg
ICAocDIpIGxkOCByMjY9W3IyNV0KKyAgICA7OworaWE2NF92bW1fZW50cnlfb3V0OgorICAgIG1v
diBwcj1yMjMsLTIKKyAgICBtb3YgYjA9cjI5CisgICAgOzsKKyAgICBici5jb25kLnNwdGsgYjAg
ICAgICAgICAgICAgLy8gY2FsbCBwYWwgc2VydmljZQorRU5EKGlhNjRfdm1tX2VudHJ5KQorCisK
KworLyoKKyAqIGV4dGVybiB1NjQgaWE2NF9jYWxsX3ZzYSh1NjQgcHJvYywgdTY0IGFyZzEsIHU2
NCBhcmcyLAorICogICAgICAgICAgICAgICAgICB1NjQgYXJnMywgdTY0IGFyZzQsIHU2NCBhcmc1
LAorICogICAgICAgICAgICAgICAgICB1NjQgYXJnNiwgdTY0IGFyZzcpOworICoKKyAqIFhYWDog
VGhlIGN1cnJlbnRseSBkZWZpbmVkIHNlcnZpY2VzIHVzZSBvbmx5IDQgYXJncyBhdCB0aGUgbWF4
LiBUaGUKKyAqICByZXN0IGFyZSBub3QgY29uc3VtZWQuCisgKi8KK0dMT0JBTF9FTlRSWShpYTY0
X2NhbGxfdnNhKQorICAgIC5yZWdzdGsgNCw0LDAsMAorCitycHNhdmUgID0gICBsb2MwCitwZnNz
YXZlID0gICBsb2MxCitwc3JzYXZlID0gICBsb2MyCitlbnRyeSAgID0gICBsb2MzCitob3N0cmV0
ID0gICByMjQKKworICAgIGFsbG9jICAgcGZzc2F2ZT1hci5wZnMsNCw0LDAsMAorICAgIG1vdiBy
cHNhdmU9cnAKKyAgICBhZGRzIGVudHJ5PVZNTV9WQ1BVX1ZTQV9CQVNFX09GRlNFVCwgcjEzCisg
ICAgOzsKKyAgICBsZDggZW50cnk9W2VudHJ5XQorMTogIG1vdiBob3N0cmV0PWlwCisgICAgbW92
IHIyNT1pbjEgICAgICAgICAvLyBjb3B5IGFyZ3VtZW50cworICAgIG1vdiByMjY9aW4yCisgICAg
bW92IHIyNz1pbjMKKyAgICBtb3YgcHNyc2F2ZT1wc3IKKyAgICA7OworICAgIHRiaXQubnogcDYs
cDA9cHNyc2F2ZSwxNCAgICAvLyBJQTY0X1BTUl9JCisgICAgdGJpdC5ueiBwNyxwMD1wc3JzYXZl
LDEzICAgIC8vIElBNjRfUFNSX0lDCisgICAgOzsKKyAgICBhZGQgaG9zdHJldD0yZi0xYixob3N0
cmV0ICAgLy8gY2FsY3VsYXRlIHJldHVybiBhZGRyZXNzCisgICAgYWRkIGVudHJ5PWVudHJ5LGlu
MAorICAgIDs7CisgICAgcnNtIHBzci5pIHwgcHNyLmljCisgICAgOzsKKyAgICBzcmx6LmQKKyAg
ICBtb3YgYjY9ZW50cnkKKyAgICBici5jb25kLnNwdGsgYjYgICAgICAgICAvLyBjYWxsIHRoZSBz
ZXJ2aWNlCisyOgorICAgIC8vIEFyY2hpdGVjdHVyYWwgc2VxdWVuY2UgZm9yIGVuYWJsaW5nIGlu
dGVycnVwdHMgaWYgbmVjZXNzYXJ5CisocDcpICAgIHNzbSBwc3IuaWMKKyAgICA7OworKHA3KSAg
ICBzcmx6LmQKKyAgICA7OworLy8ocDYpICAgIHNzbSBwc3IuaQorICAgIDs7CisgICAgbW92IHJw
PXJwc2F2ZQorICAgIG1vdiBhci5wZnM9cGZzc2F2ZQorICAgIG1vdiByOD1yMzEKKyAgICA7Owor
ICAgIHNybHouZAorICAgIGJyLnJldC5zcHRrIHJwCisKK0VORChpYTY0X2NhbGxfdnNhKQorCisj
ZGVmaW5lICBJTklUX0JTUFNUT1JFICAoKDQ8PDMwKS0oMTI8PDIwKS0weDEwMCkKKworR0xPQkFM
X0VOVFJZKHZtbV9yZXNldF9lbnRyeSkKKyAgICAvL3NldCB1cCBpcHNyLCBpaXAsIHZwZC52cHNy
LCBkY3IKKyAgICAvLyBGb3IgSVBTUjogaXQvZHQvcnQ9MSwgaS9pYz0xLCBzaT0xLCB2bS9ibj0x
CisgICAgLy8gRm9yIERDUjogYWxsIGJpdHMgMAorICAgIGFkZHMgcjE0PS1WTU1fUFRfUkVHU19T
SVpFLCByMTIKKyAgICA7OworICAgIG1vdmwgcjY9MHg1MDEwMDg4MjYwMDAgICAgICAvLyBJUFNS
IGR0L3J0L2l0OjE7aS9pYzoxLCBzaToxLCB2bS9ibjoxCisgICAgbW92bCByMTA9MHg4MDAwMDAw
MDAwMDAwMDAwCisgICAgYWRkcyByMTY9UFQoQ1JfSUlQKSwgcjE0CisgICAgYWRkcyByMjA9UFQo
UjEpLCByMTQKKyAgICA7OworICAgIHJzbSBwc3IuaWMgfCBwc3IuaQorICAgIDs7CisgICAgc3Js
ei5kCisgICAgOzsKKyAgICBic3cuMAorICAgIDs7CisgICAgbW92IHIyMSA9cjEzCisgICAgOzsK
KyAgICBic3cuMQorICAgIDs7CisgICAgbW92IGFyLnJzYyA9IDAKKyAgICA7OworICAgIGZsdXNo
cnMKKyAgICA7OworICAgIG1vdiBhci5ic3BzdG9yZSA9IDAKKyAgICAvLyBjbGVhciBCU1BTVE9S
RQorICAgIDs7CisgICAgbW92IGNyLmlwc3I9cjYKKyAgICBtb3YgY3IuaWZzPXIxMAorICAgIGxk
OCByNCA9IFtyMTZdIC8vIFNldCBpbml0IGlpcCBmb3IgZmlyc3QgcnVuLgorICAgIGxkOCByMSA9
IFtyMjBdCisgICAgOzsKKyAgICBtb3YgY3IuaWlwPXI0CisgICAgOzsKKyAgICBhZGRzIHIxNj1W
TU1fVlBEX0JBU0VfT0ZGU0VULHIxMworICAgIGFkZHMgcjIwPVZNTV9WQ1BVX1ZTQV9CQVNFX09G
RlNFVCxyMTMKKyAgICA7OworICAgIGxkOCByMTg9W3IxNl0KKyAgICBsZDggcjIwPVtyMjBdCisg
ICAgOzsKKyAgICBhZGRzIHIxOT1WTU1fVlBEX1ZQU1JfT0ZGU0VULHIxOAorICAgIDs7CisgICAg
bGQ4IHIxOT1bcjE5XQorICAgIG1vdiByMTc9cjAKKyAgICBtb3YgcjIyPXIwCisgICAgbW92IHIy
Mz1yMAorICAgIGJyLmNvbmQuc3B0ayBpYTY0X3ZtbV9lbnRyeQorICAgIGJyLnJldC5zcHRrICBi
MAorRU5EKHZtbV9yZXNldF9lbnRyeSkKKwotLSAKMS41LjEKCg==

------_=_NextPart_001_01C863F4.37DD060F--
