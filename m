From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Tue, 01 Apr 2008 10:50:23 +0000
Subject: [13/18] KVM:IA64: Add optimization for some virtulization faults V9
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDC0104872C@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C893E6.2FFF0333"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C893E6.2FFF0333
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

From 0d698efed15759b49e78adcef085feda0a14a175 Mon Sep 17 00:00:00 2001
From: Xiantao Zhang <xiantao.zhang@intel.com>
Date: Tue, 1 Apr 2008 14:57:09 +0800
Subject: [PATCH] KVM:IA64: Add optimization for some virtulization
faults

optvfault.S Add optimization for some performance-critical
virtualization faults.
Signed-off-by: Anthony Xu <anthony.xu@intel.com>
Signed-off-by: Xiantao Zhang <xiantao.zhang@intel.com>
---
 arch/ia64/kvm/optvfault.S |  918
+++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 918 insertions(+), 0 deletions(-)
 create mode 100644 arch/ia64/kvm/optvfault.S

diff --git a/arch/ia64/kvm/optvfault.S b/arch/ia64/kvm/optvfault.S
new file mode 100644
index 0000000..5de210e
--- /dev/null
+++ b/arch/ia64/kvm/optvfault.S
@@ -0,0 +1,918 @@
+/*
+ * arch/ia64/vmx/optvfault.S
+ * optimize virtualization fault handler
+ *
+ * Copyright (C) 2006 Intel Co
+ *	Xuefei Xu (Anthony Xu) <anthony.xu@intel.com>
+ */
+
+#include <asm/asmmacro.h>
+#include <asm/processor.h>
+
+#include "vti.h"
+#include "asm-offsets.h"
+
+#define ACCE_MOV_FROM_AR
+#define ACCE_MOV_FROM_RR
+#define ACCE_MOV_TO_RR
+#define ACCE_RSM
+#define ACCE_SSM
+#define ACCE_MOV_TO_PSR
+#define ACCE_THASH
+
+//mov r1=3Dar3
+GLOBAL_ENTRY(kvm_asm_mov_from_ar)
+#ifndef ACCE_MOV_FROM_AR
+    br.many kvm_virtualization_fault_back
+#endif
+    add r18=3DVMM_VCPU_ITC_OFS_OFFSET, r21
+    add r16=3DVMM_VCPU_LAST_ITC_OFFSET,r21
+    extr.u r17=3Dr25,6,7
+    ;;
+    ld8 r18=3D[r18]
+    mov r19=3Dar.itc
+    mov r24=3Db0
+    ;;
+    add r19=3Dr19,r18
+    addl r20=3D@gprel(asm_mov_to_reg),gp
+    ;;
+    st8 [r16] =3D r19
+    adds r30=3Dkvm_resume_to_guest-asm_mov_to_reg,r20
+    shladd r17=3Dr17,4,r20
+    ;;
+    mov b0=3Dr17
+    br.sptk.few b0
+    ;;
+END(kvm_asm_mov_from_ar)
+
+
+// mov r1=3Drr[r3]
+GLOBAL_ENTRY(kvm_asm_mov_from_rr)
+#ifndef ACCE_MOV_FROM_RR
+    br.many kvm_virtualization_fault_back
+#endif
+    extr.u r16=3Dr25,20,7
+    extr.u r17=3Dr25,6,7
+    addl r20=3D@gprel(asm_mov_from_reg),gp
+    ;;
+    adds r30=3Dkvm_asm_mov_from_rr_back_1-asm_mov_from_reg,r20
+    shladd r16=3Dr16,4,r20
+    mov r24=3Db0
+    ;;
+    add r27=3DVMM_VCPU_VRR0_OFFSET,r21
+    mov b0=3Dr16
+    br.many b0
+    ;;
+kvm_asm_mov_from_rr_back_1:
+    adds r30=3Dkvm_resume_to_guest-asm_mov_from_reg,r20
+    adds r22=3Dasm_mov_to_reg-asm_mov_from_reg,r20
+    shr.u r26=3Dr19,61
+    ;;
+    shladd r17=3Dr17,4,r22
+    shladd r27=3Dr26,3,r27
+    ;;
+    ld8 r19=3D[r27]
+    mov b0=3Dr17
+    br.many b0
+END(kvm_asm_mov_from_rr)
+
+
+// mov rr[r3]=3Dr2
+GLOBAL_ENTRY(kvm_asm_mov_to_rr)
+#ifndef ACCE_MOV_TO_RR
+    br.many kvm_virtualization_fault_back
+#endif
+    extr.u r16=3Dr25,20,7
+    extr.u r17=3Dr25,13,7
+    addl r20=3D@gprel(asm_mov_from_reg),gp
+    ;;
+    adds r30=3Dkvm_asm_mov_to_rr_back_1-asm_mov_from_reg,r20
+    shladd r16=3Dr16,4,r20
+    mov r22=3Db0
+    ;;
+    add r27=3DVMM_VCPU_VRR0_OFFSET,r21
+    mov b0=3Dr16
+    br.many b0
+    ;;
+kvm_asm_mov_to_rr_back_1:
+    adds r30=3Dkvm_asm_mov_to_rr_back_2-asm_mov_from_reg,r20
+    shr.u r23=3Dr19,61
+    shladd r17=3Dr17,4,r20
+    ;;
+    //if rr6, go back
+    cmp.eq p6,p0=3D6,r23
+    mov b0=3Dr22
+    (p6) br.cond.dpnt.many kvm_virtualization_fault_back
+    ;;
+    mov r28=3Dr19
+    mov b0=3Dr17
+    br.many b0
+kvm_asm_mov_to_rr_back_2:
+    adds r30=3Dkvm_resume_to_guest-asm_mov_from_reg,r20
+    shladd r27=3Dr23,3,r27
+    ;; // vrr.rid<<4 |0xe
+    st8 [r27]=3Dr19
+    mov b0=3Dr30
+    ;;
+    extr.u r16=3Dr19,8,26
+    extr.u r18 =3Dr19,2,6
+    mov r17 =3D0xe
+    ;;
+    shladd r16 =3D r16, 4, r17
+    extr.u r19 =3Dr19,0,8
+    ;;
+    shl r16 =3D r16,8
+    ;;
+    add r19 =3D r19, r16
+    ;; //set ve 1
+    dep r19=3D-1,r19,0,1
+    cmp.lt p6,p0=3D14,r18
+    ;;
+    (p6) mov r18=3D14
+    ;;
+    (p6) dep r19=3Dr18,r19,2,6
+    ;;
+    cmp.eq p6,p0=3D0,r23
+    ;;
+    cmp.eq.or p6,p0=3D4,r23
+    ;;
+    adds r16=3DVMM_VCPU_MODE_FLAGS_OFFSET,r21
+    (p6) adds r17=3DVMM_VCPU_META_SAVED_RR0_OFFSET,r21
+    ;;
+    ld4 r16=3D[r16]
+    cmp.eq p7,p0=3Dr0,r0
+    (p6) shladd r17=3Dr23,1,r17
+    ;;
+    (p6) st8 [r17]=3Dr19
+    (p6) tbit.nz p6,p7=3Dr16,0
+    ;;
+    (p7) mov rr[r28]=3Dr19
+    mov r24=3Dr22
+    br.many b0
+END(kvm_asm_mov_to_rr)
+
+
+//rsm
+GLOBAL_ENTRY(kvm_asm_rsm)
+#ifndef ACCE_RSM
+    br.many kvm_virtualization_fault_back
+#endif
+    add r16=3DVMM_VPD_BASE_OFFSET,r21
+    extr.u r26=3Dr25,6,21
+    extr.u r27=3Dr25,31,2
+    ;;
+    ld8 r16=3D[r16]
+    extr.u r28=3Dr25,36,1
+    dep r26=3Dr27,r26,21,2
+    ;;
+    add r17=3DVPD_VPSR_START_OFFSET,r16
+    add r22=3DVMM_VCPU_MODE_FLAGS_OFFSET,r21
+    //r26 is imm24
+    dep r26=3Dr28,r26,23,1
+    ;;
+    ld8 r18=3D[r17]
+    movl r28=3DIA64_PSR_IC+IA64_PSR_I+IA64_PSR_DT+IA64_PSR_SI
+    ld4 r23=3D[r22]
+    sub r27=3D-1,r26
+    mov r24=3Db0
+    ;;
+    mov r20=3Dcr.ipsr
+    or r28=3Dr27,r28
+    and r19=3Dr18,r27
+    ;;
+    st8 [r17]=3Dr19
+    and r20=3Dr20,r28
+    /* Comment it out due to short of fp lazy alorgithm support
+    adds r27=3DIA64_VCPU_FP_PSR_OFFSET,r21
+    ;;
+    ld8 r27=3D[r27]
+    ;;
+    tbit.nz p8,p0=3D r27,IA64_PSR_DFH_BIT
+    ;;
+    (p8) dep r20=3D-1,r20,IA64_PSR_DFH_BIT,1
+    */
+    ;;
+    mov cr.ipsr=3Dr20
+    tbit.nz p6,p0=3Dr23,0
+    ;;
+    tbit.z.or p6,p0=3Dr26,IA64_PSR_DT_BIT
+    (p6) br.dptk kvm_resume_to_guest
+    ;;
+    add r26=3DVMM_VCPU_META_RR0_OFFSET,r21
+    add r27=3DVMM_VCPU_META_RR0_OFFSET+8,r21
+    dep r23=3D-1,r23,0,1
+    ;;
+    ld8 r26=3D[r26]
+    ld8 r27=3D[r27]
+    st4 [r22]=3Dr23
+    dep.z r28=3D4,61,3
+    ;;
+    mov rr[r0]=3Dr26
+    ;;
+    mov rr[r28]=3Dr27
+    ;;
+    srlz.d
+    br.many kvm_resume_to_guest
+END(kvm_asm_rsm)
+
+
+//ssm
+GLOBAL_ENTRY(kvm_asm_ssm)
+#ifndef ACCE_SSM
+    br.many kvm_virtualization_fault_back
+#endif
+    add r16=3DVMM_VPD_BASE_OFFSET,r21
+    extr.u r26=3Dr25,6,21
+    extr.u r27=3Dr25,31,2
+    ;;
+    ld8 r16=3D[r16]
+    extr.u r28=3Dr25,36,1
+    dep r26=3Dr27,r26,21,2
+    ;;  //r26 is imm24
+    add r27=3DVPD_VPSR_START_OFFSET,r16
+    dep r26=3Dr28,r26,23,1
+    ;;  //r19 vpsr
+    ld8 r29=3D[r27]
+    mov r24=3Db0
+    ;;
+    add r22=3DVMM_VCPU_MODE_FLAGS_OFFSET,r21
+    mov r20=3Dcr.ipsr
+    or r19=3Dr29,r26
+    ;;
+    ld4 r23=3D[r22]
+    st8 [r27]=3Dr19
+    or r20=3Dr20,r26
+    ;;
+    mov cr.ipsr=3Dr20
+    movl r28=3DIA64_PSR_DT+IA64_PSR_RT+IA64_PSR_IT
+    ;;
+    and r19=3Dr28,r19
+    tbit.z p6,p0=3Dr23,0
+    ;;
+    cmp.ne.or p6,p0=3Dr28,r19
+    (p6) br.dptk kvm_asm_ssm_1
+    ;;
+    add r26=3DVMM_VCPU_META_SAVED_RR0_OFFSET,r21
+    add r27=3DVMM_VCPU_META_SAVED_RR0_OFFSET+8,r21
+    dep r23=3D0,r23,0,1
+    ;;
+    ld8 r26=3D[r26]
+    ld8 r27=3D[r27]
+    st4 [r22]=3Dr23
+    dep.z r28=3D4,61,3
+    ;;
+    mov rr[r0]=3Dr26
+    ;;
+    mov rr[r28]=3Dr27
+    ;;
+    srlz.d
+    ;;
+kvm_asm_ssm_1:
+    tbit.nz p6,p0=3Dr29,IA64_PSR_I_BIT
+    ;;
+    tbit.z.or p6,p0=3Dr19,IA64_PSR_I_BIT
+    (p6) br.dptk kvm_resume_to_guest
+    ;;
+    add r29=3DVPD_VTPR_START_OFFSET,r16
+    add r30=3DVPD_VHPI_START_OFFSET,r16
+    ;;
+    ld8 r29=3D[r29]
+    ld8 r30=3D[r30]
+    ;;
+    extr.u r17=3Dr29,4,4
+    extr.u r18=3Dr29,16,1
+    ;;
+    dep r17=3Dr18,r17,4,1
+    ;;
+    cmp.gt p6,p0=3Dr30,r17
+    (p6) br.dpnt.few kvm_asm_dispatch_vexirq
+    br.many kvm_resume_to_guest
+END(kvm_asm_ssm)
+
+
+//mov psr.l=3Dr2
+GLOBAL_ENTRY(kvm_asm_mov_to_psr)
+#ifndef ACCE_MOV_TO_PSR
+    br.many kvm_virtualization_fault_back
+#endif
+    add r16=3DVMM_VPD_BASE_OFFSET,r21
+    extr.u r26=3Dr25,13,7 //r2
+    ;;
+    ld8 r16=3D[r16]
+    addl r20=3D@gprel(asm_mov_from_reg),gp
+    ;;
+    adds r30=3Dkvm_asm_mov_to_psr_back-asm_mov_from_reg,r20
+    shladd r26=3Dr26,4,r20
+    mov r24=3Db0
+    ;;
+    add r27=3DVPD_VPSR_START_OFFSET,r16
+    mov b0=3Dr26
+    br.many b0
+    ;;
+kvm_asm_mov_to_psr_back:
+    ld8 r17=3D[r27]
+    add r22=3DVMM_VCPU_MODE_FLAGS_OFFSET,r21
+    dep r19=3D0,r19,32,32
+    ;;
+    ld4 r23=3D[r22]
+    dep r18=3D0,r17,0,32
+    ;;
+    add r30=3Dr18,r19
+    movl r28=3DIA64_PSR_DT+IA64_PSR_RT+IA64_PSR_IT
+    ;;
+    st8 [r27]=3Dr30
+    and r27=3Dr28,r30
+    and r29=3Dr28,r17
+    ;;
+    cmp.eq p5,p0=3Dr29,r27
+    cmp.eq p6,p7=3Dr28,r27
+    (p5) br.many kvm_asm_mov_to_psr_1
+    ;;
+    //virtual to physical
+    (p7) add r26=3DVMM_VCPU_META_RR0_OFFSET,r21
+    (p7) add r27=3DVMM_VCPU_META_RR0_OFFSET+8,r21
+    (p7) dep r23=3D-1,r23,0,1
+    ;;
+    //physical to virtual
+    (p6) add r26=3DVMM_VCPU_META_SAVED_RR0_OFFSET,r21
+    (p6) add r27=3DVMM_VCPU_META_SAVED_RR0_OFFSET+8,r21
+    (p6) dep r23=3D0,r23,0,1
+    ;;
+    ld8 r26=3D[r26]
+    ld8 r27=3D[r27]
+    st4 [r22]=3Dr23
+    dep.z r28=3D4,61,3
+    ;;
+    mov rr[r0]=3Dr26
+    ;;
+    mov rr[r28]=3Dr27
+    ;;
+    srlz.d
+    ;;
+kvm_asm_mov_to_psr_1:
+    mov r20=3Dcr.ipsr
+    movl =
r28=3DIA64_PSR_IC+IA64_PSR_I+IA64_PSR_DT+IA64_PSR_SI+IA64_PSR_RT
+    ;;
+    or r19=3Dr19,r28
+    dep r20=3D0,r20,0,32
+    ;;
+    add r20=3Dr19,r20
+    mov b0=3Dr24
+    ;;
+    /* Comment it out due to short of fp lazy algorithm support
+    adds r27=3DIA64_VCPU_FP_PSR_OFFSET,r21
+    ;;
+    ld8 r27=3D[r27]
+    ;;
+    tbit.nz p8,p0=3Dr27,IA64_PSR_DFH_BIT
+    ;;
+    (p8) dep r20=3D-1,r20,IA64_PSR_DFH_BIT,1
+    ;;
+    */
+    mov cr.ipsr=3Dr20
+    cmp.ne p6,p0=3Dr0,r0
+    ;;
+    tbit.nz.or p6,p0=3Dr17,IA64_PSR_I_BIT
+    tbit.z.or p6,p0=3Dr30,IA64_PSR_I_BIT
+    (p6) br.dpnt.few kvm_resume_to_guest
+    ;;
+    add r29=3DVPD_VTPR_START_OFFSET,r16
+    add r30=3DVPD_VHPI_START_OFFSET,r16
+    ;;
+    ld8 r29=3D[r29]
+    ld8 r30=3D[r30]
+    ;;
+    extr.u r17=3Dr29,4,4
+    extr.u r18=3Dr29,16,1
+    ;;
+    dep r17=3Dr18,r17,4,1
+    ;;
+    cmp.gt p6,p0=3Dr30,r17
+    (p6) br.dpnt.few kvm_asm_dispatch_vexirq
+    br.many kvm_resume_to_guest
+END(kvm_asm_mov_to_psr)
+
+
+ENTRY(kvm_asm_dispatch_vexirq)
+//increment iip
+    mov r16=3Dcr.ipsr
+    ;;
+    extr.u r17=3Dr16,IA64_PSR_RI_BIT,2
+    tbit.nz p6,p7=3Dr16,IA64_PSR_RI_BIT+1
+    ;;
+    (p6) mov r18=3Dcr.iip
+    (p6) mov r17=3Dr0
+    (p7) add r17=3D1,r17
+    ;;
+    (p6) add r18=3D0x10,r18
+    dep r16=3Dr17,r16,IA64_PSR_RI_BIT,2
+    ;;
+    (p6) mov cr.iip=3Dr18
+    mov cr.ipsr=3Dr16
+    mov r30 =3D1
+    br.many kvm_dispatch_vexirq
+END(kvm_asm_dispatch_vexirq)
+
+// thash
+// TODO: add support when pta.vf =3D 1
+GLOBAL_ENTRY(kvm_asm_thash)
+#ifndef ACCE_THASH
+    br.many kvm_virtualization_fault_back
+#endif
+    extr.u r17=3Dr25,20,7		// get r3 from opcode in r25
+    extr.u r18=3Dr25,6,7		// get r1 from opcode in r25
+    addl r20=3D@gprel(asm_mov_from_reg),gp
+    ;;
+    adds r30=3Dkvm_asm_thash_back1-asm_mov_from_reg,r20
+    shladd r17=3Dr17,4,r20	// get addr of MOVE_FROM_REG(r17)
+    adds r16=3DVMM_VPD_BASE_OFFSET,r21	// get vcpu.arch.priveregs
+    ;;
+    mov r24=3Db0
+    ;;
+    ld8 r16=3D[r16]		// get VPD addr
+    mov b0=3Dr17
+    br.many b0			// r19 return value
+    ;;
+kvm_asm_thash_back1:
+    shr.u r23=3Dr19,61		// get RR number
+    adds r25=3DVMM_VCPU_VRR0_OFFSET,r21	// get vcpu->arch.vrr[0]'s addr
+    adds r16=3DVMM_VPD_VPTA_OFFSET,r16	// get vpta
+    ;;
+    shladd r27=3Dr23,3,r25	// get vcpu->arch.vrr[r23]'s addr
+    ld8 r17=3D[r16]		// get PTA
+    mov r26=3D1
+    ;;
+    extr.u r29=3Dr17,2,6		// get pta.size
+    ld8 r25=3D[r27]		// get vcpu->arch.vrr[r23]'s value
+    ;;
+    extr.u r25=3Dr25,2,6		// get rr.ps
+    shl r22=3Dr26,r29		// 1UL << pta.size
+    ;;
+    shr.u r23=3Dr19,r25		// vaddr >> rr.ps
+    adds r26=3D3,r29		// pta.size + 3
+    shl r27=3Dr17,3		// pta << 3
+    ;;
+    shl r23=3Dr23,3		// (vaddr >> rr.ps) << 3
+    shr.u r27=3Dr27,r26		// (pta << 3) >> (pta.size+3)
+    movl r16=3D7<<61
+    ;;
+    adds r22=3D-1,r22		// (1UL << pta.size) - 1
+    shl r27=3Dr27,r29		// ((pta<<3)>>(pta.size+3))<<pta.size
+    and r19=3Dr19,r16		// vaddr & VRN_MASK
+    ;;
+    and r22=3Dr22,r23		// vhpt_offset
+    or r19=3Dr19,r27 // (vadr&VRN_MASK) |(((pta<<3)>>(pta.size +
3))<<pta.size)
+    adds r26=3Dasm_mov_to_reg-asm_mov_from_reg,r20
+    ;;
+    or r19=3Dr19,r22		// calc pval
+    shladd r17=3Dr18,4,r26
+    adds r30=3Dkvm_resume_to_guest-asm_mov_from_reg,r20
+    ;;
+    mov b0=3Dr17
+    br.many b0
+END(kvm_asm_thash)
+
+#define MOV_TO_REG0	\
+{;			\
+    nop.b 0x0;		\
+    nop.b 0x0;		\
+    nop.b 0x0;		\
+    ;;			\
+};
+
+
+#define MOV_TO_REG(n)	\
+{;			\
+    mov r##n##=3Dr19;	\
+    mov b0=3Dr30;	\
+    br.sptk.many b0;	\
+    ;;			\
+};
+
+
+#define MOV_FROM_REG(n)	\
+{;				\
+    mov r19=3Dr##n##;		\
+    mov b0=3Dr30;		\
+    br.sptk.many b0;		\
+    ;;				\
+};
+
+
+#define MOV_TO_BANK0_REG(n)			\
+ENTRY_MIN_ALIGN(asm_mov_to_bank0_reg##n##);	\
+{;						\
+    mov r26=3Dr2;				\
+    mov r2=3Dr19;				\
+    bsw.1;					\
+    ;;						\
+};						\
+{;						\
+    mov r##n##=3Dr2;				\
+    nop.b 0x0;					\
+    bsw.0;					\
+    ;;						\
+};						\
+{;						\
+    mov r2=3Dr26;				\
+    mov b0=3Dr30;				\
+    br.sptk.many b0;				\
+    ;;						\
+};						\
+END(asm_mov_to_bank0_reg##n##)
+
+
+#define MOV_FROM_BANK0_REG(n)			\
+ENTRY_MIN_ALIGN(asm_mov_from_bank0_reg##n##);	\
+{;						\
+    mov r26=3Dr2;				\
+    nop.b 0x0;					\
+    bsw.1;					\
+    ;;						\
+};						\
+{;						\
+    mov r2=3Dr##n##;				\
+    nop.b 0x0;					\
+    bsw.0;					\
+    ;;						\
+};						\
+{;						\
+    mov r19=3Dr2;				\
+    mov r2=3Dr26;				\
+    mov b0=3Dr30;				\
+};						\
+{;						\
+    nop.b 0x0;					\
+    nop.b 0x0;					\
+    br.sptk.many b0;				\
+    ;;						\
+};						\
+END(asm_mov_from_bank0_reg##n##)
+
+
+#define JMP_TO_MOV_TO_BANK0_REG(n)		\
+{;						\
+    nop.b 0x0;					\
+    nop.b 0x0;					\
+    br.sptk.many asm_mov_to_bank0_reg##n##;	\
+    ;;						\
+}
+
+
+#define JMP_TO_MOV_FROM_BANK0_REG(n)		\
+{;						\
+    nop.b 0x0;					\
+    nop.b 0x0;					\
+    br.sptk.many asm_mov_from_bank0_reg##n##;	\
+    ;;						\
+}
+
+
+MOV_FROM_BANK0_REG(16)
+MOV_FROM_BANK0_REG(17)
+MOV_FROM_BANK0_REG(18)
+MOV_FROM_BANK0_REG(19)
+MOV_FROM_BANK0_REG(20)
+MOV_FROM_BANK0_REG(21)
+MOV_FROM_BANK0_REG(22)
+MOV_FROM_BANK0_REG(23)
+MOV_FROM_BANK0_REG(24)
+MOV_FROM_BANK0_REG(25)
+MOV_FROM_BANK0_REG(26)
+MOV_FROM_BANK0_REG(27)
+MOV_FROM_BANK0_REG(28)
+MOV_FROM_BANK0_REG(29)
+MOV_FROM_BANK0_REG(30)
+MOV_FROM_BANK0_REG(31)
+
+
+// mov from reg table
+ENTRY(asm_mov_from_reg)
+    MOV_FROM_REG(0)
+    MOV_FROM_REG(1)
+    MOV_FROM_REG(2)
+    MOV_FROM_REG(3)
+    MOV_FROM_REG(4)
+    MOV_FROM_REG(5)
+    MOV_FROM_REG(6)
+    MOV_FROM_REG(7)
+    MOV_FROM_REG(8)
+    MOV_FROM_REG(9)
+    MOV_FROM_REG(10)
+    MOV_FROM_REG(11)
+    MOV_FROM_REG(12)
+    MOV_FROM_REG(13)
+    MOV_FROM_REG(14)
+    MOV_FROM_REG(15)
+    JMP_TO_MOV_FROM_BANK0_REG(16)
+    JMP_TO_MOV_FROM_BANK0_REG(17)
+    JMP_TO_MOV_FROM_BANK0_REG(18)
+    JMP_TO_MOV_FROM_BANK0_REG(19)
+    JMP_TO_MOV_FROM_BANK0_REG(20)
+    JMP_TO_MOV_FROM_BANK0_REG(21)
+    JMP_TO_MOV_FROM_BANK0_REG(22)
+    JMP_TO_MOV_FROM_BANK0_REG(23)
+    JMP_TO_MOV_FROM_BANK0_REG(24)
+    JMP_TO_MOV_FROM_BANK0_REG(25)
+    JMP_TO_MOV_FROM_BANK0_REG(26)
+    JMP_TO_MOV_FROM_BANK0_REG(27)
+    JMP_TO_MOV_FROM_BANK0_REG(28)
+    JMP_TO_MOV_FROM_BANK0_REG(29)
+    JMP_TO_MOV_FROM_BANK0_REG(30)
+    JMP_TO_MOV_FROM_BANK0_REG(31)
+    MOV_FROM_REG(32)
+    MOV_FROM_REG(33)
+    MOV_FROM_REG(34)
+    MOV_FROM_REG(35)
+    MOV_FROM_REG(36)
+    MOV_FROM_REG(37)
+    MOV_FROM_REG(38)
+    MOV_FROM_REG(39)
+    MOV_FROM_REG(40)
+    MOV_FROM_REG(41)
+    MOV_FROM_REG(42)
+    MOV_FROM_REG(43)
+    MOV_FROM_REG(44)
+    MOV_FROM_REG(45)
+    MOV_FROM_REG(46)
+    MOV_FROM_REG(47)
+    MOV_FROM_REG(48)
+    MOV_FROM_REG(49)
+    MOV_FROM_REG(50)
+    MOV_FROM_REG(51)
+    MOV_FROM_REG(52)
+    MOV_FROM_REG(53)
+    MOV_FROM_REG(54)
+    MOV_FROM_REG(55)
+    MOV_FROM_REG(56)
+    MOV_FROM_REG(57)
+    MOV_FROM_REG(58)
+    MOV_FROM_REG(59)
+    MOV_FROM_REG(60)
+    MOV_FROM_REG(61)
+    MOV_FROM_REG(62)
+    MOV_FROM_REG(63)
+    MOV_FROM_REG(64)
+    MOV_FROM_REG(65)
+    MOV_FROM_REG(66)
+    MOV_FROM_REG(67)
+    MOV_FROM_REG(68)
+    MOV_FROM_REG(69)
+    MOV_FROM_REG(70)
+    MOV_FROM_REG(71)
+    MOV_FROM_REG(72)
+    MOV_FROM_REG(73)
+    MOV_FROM_REG(74)
+    MOV_FROM_REG(75)
+    MOV_FROM_REG(76)
+    MOV_FROM_REG(77)
+    MOV_FROM_REG(78)
+    MOV_FROM_REG(79)
+    MOV_FROM_REG(80)
+    MOV_FROM_REG(81)
+    MOV_FROM_REG(82)
+    MOV_FROM_REG(83)
+    MOV_FROM_REG(84)
+    MOV_FROM_REG(85)
+    MOV_FROM_REG(86)
+    MOV_FROM_REG(87)
+    MOV_FROM_REG(88)
+    MOV_FROM_REG(89)
+    MOV_FROM_REG(90)
+    MOV_FROM_REG(91)
+    MOV_FROM_REG(92)
+    MOV_FROM_REG(93)
+    MOV_FROM_REG(94)
+    MOV_FROM_REG(95)
+    MOV_FROM_REG(96)
+    MOV_FROM_REG(97)
+    MOV_FROM_REG(98)
+    MOV_FROM_REG(99)
+    MOV_FROM_REG(100)
+    MOV_FROM_REG(101)
+    MOV_FROM_REG(102)
+    MOV_FROM_REG(103)
+    MOV_FROM_REG(104)
+    MOV_FROM_REG(105)
+    MOV_FROM_REG(106)
+    MOV_FROM_REG(107)
+    MOV_FROM_REG(108)
+    MOV_FROM_REG(109)
+    MOV_FROM_REG(110)
+    MOV_FROM_REG(111)
+    MOV_FROM_REG(112)
+    MOV_FROM_REG(113)
+    MOV_FROM_REG(114)
+    MOV_FROM_REG(115)
+    MOV_FROM_REG(116)
+    MOV_FROM_REG(117)
+    MOV_FROM_REG(118)
+    MOV_FROM_REG(119)
+    MOV_FROM_REG(120)
+    MOV_FROM_REG(121)
+    MOV_FROM_REG(122)
+    MOV_FROM_REG(123)
+    MOV_FROM_REG(124)
+    MOV_FROM_REG(125)
+    MOV_FROM_REG(126)
+    MOV_FROM_REG(127)
+END(asm_mov_from_reg)
+
+
+/* must be in bank 0
+ * parameter:
+ * r31: pr
+ * r24: b0
+ */
+ENTRY(kvm_resume_to_guest)
+    adds r16 =3D VMM_VCPU_SAVED_GP_OFFSET,r21
+    ;;
+    ld8 r1 =3D[r16]
+    adds r20 =3D VMM_VCPU_VSA_BASE_OFFSET,r21
+    ;;
+    mov r16=3Dcr.ipsr
+    ;;
+    ld8 r20 =3D [r20]
+    adds r19=3DVMM_VPD_BASE_OFFSET,r21
+    ;;
+    ld8 r25=3D[r19]
+    extr.u r17=3Dr16,IA64_PSR_RI_BIT,2
+    tbit.nz p6,p7=3Dr16,IA64_PSR_RI_BIT+1
+    ;;
+    (p6) mov r18=3Dcr.iip
+    (p6) mov r17=3Dr0
+    ;;
+    (p6) add r18=3D0x10,r18
+    (p7) add r17=3D1,r17
+    ;;
+    (p6) mov cr.iip=3Dr18
+    dep r16=3Dr17,r16,IA64_PSR_RI_BIT,2
+    ;;
+    mov cr.ipsr=3Dr16
+    adds r19=3D VPD_VPSR_START_OFFSET,r25
+    add r28=3DPAL_VPS_RESUME_NORMAL,r20
+    add r29=3DPAL_VPS_RESUME_HANDLER,r20
+    ;;
+    ld8 r19=3D[r19]
+    mov b0=3Dr29
+    cmp.ne p6,p7 =3D r0,r0
+    ;;
+    tbit.z p6,p7 =3D r19,IA64_PSR_IC_BIT		// p1=3Dvpsr.ic
+    ;;
+    (p6) ld8 r26=3D[r25]
+    (p7) mov b0=3Dr28
+    mov pr=3Dr31,-2
+    br.sptk.many b0             // call pal service
+    ;;
+END(kvm_resume_to_guest)
+
+
+MOV_TO_BANK0_REG(16)
+MOV_TO_BANK0_REG(17)
+MOV_TO_BANK0_REG(18)
+MOV_TO_BANK0_REG(19)
+MOV_TO_BANK0_REG(20)
+MOV_TO_BANK0_REG(21)
+MOV_TO_BANK0_REG(22)
+MOV_TO_BANK0_REG(23)
+MOV_TO_BANK0_REG(24)
+MOV_TO_BANK0_REG(25)
+MOV_TO_BANK0_REG(26)
+MOV_TO_BANK0_REG(27)
+MOV_TO_BANK0_REG(28)
+MOV_TO_BANK0_REG(29)
+MOV_TO_BANK0_REG(30)
+MOV_TO_BANK0_REG(31)
+
+
+// mov to reg table
+ENTRY(asm_mov_to_reg)
+    MOV_TO_REG0
+    MOV_TO_REG(1)
+    MOV_TO_REG(2)
+    MOV_TO_REG(3)
+    MOV_TO_REG(4)
+    MOV_TO_REG(5)
+    MOV_TO_REG(6)
+    MOV_TO_REG(7)
+    MOV_TO_REG(8)
+    MOV_TO_REG(9)
+    MOV_TO_REG(10)
+    MOV_TO_REG(11)
+    MOV_TO_REG(12)
+    MOV_TO_REG(13)
+    MOV_TO_REG(14)
+    MOV_TO_REG(15)
+    JMP_TO_MOV_TO_BANK0_REG(16)
+    JMP_TO_MOV_TO_BANK0_REG(17)
+    JMP_TO_MOV_TO_BANK0_REG(18)
+    JMP_TO_MOV_TO_BANK0_REG(19)
+    JMP_TO_MOV_TO_BANK0_REG(20)
+    JMP_TO_MOV_TO_BANK0_REG(21)
+    JMP_TO_MOV_TO_BANK0_REG(22)
+    JMP_TO_MOV_TO_BANK0_REG(23)
+    JMP_TO_MOV_TO_BANK0_REG(24)
+    JMP_TO_MOV_TO_BANK0_REG(25)
+    JMP_TO_MOV_TO_BANK0_REG(26)
+    JMP_TO_MOV_TO_BANK0_REG(27)
+    JMP_TO_MOV_TO_BANK0_REG(28)
+    JMP_TO_MOV_TO_BANK0_REG(29)
+    JMP_TO_MOV_TO_BANK0_REG(30)
+    JMP_TO_MOV_TO_BANK0_REG(31)
+    MOV_TO_REG(32)
+    MOV_TO_REG(33)
+    MOV_TO_REG(34)
+    MOV_TO_REG(35)
+    MOV_TO_REG(36)
+    MOV_TO_REG(37)
+    MOV_TO_REG(38)
+    MOV_TO_REG(39)
+    MOV_TO_REG(40)
+    MOV_TO_REG(41)
+    MOV_TO_REG(42)
+    MOV_TO_REG(43)
+    MOV_TO_REG(44)
+    MOV_TO_REG(45)
+    MOV_TO_REG(46)
+    MOV_TO_REG(47)
+    MOV_TO_REG(48)
+    MOV_TO_REG(49)
+    MOV_TO_REG(50)
+    MOV_TO_REG(51)
+    MOV_TO_REG(52)
+    MOV_TO_REG(53)
+    MOV_TO_REG(54)
+    MOV_TO_REG(55)
+    MOV_TO_REG(56)
+    MOV_TO_REG(57)
+    MOV_TO_REG(58)
+    MOV_TO_REG(59)
+    MOV_TO_REG(60)
+    MOV_TO_REG(61)
+    MOV_TO_REG(62)
+    MOV_TO_REG(63)
+    MOV_TO_REG(64)
+    MOV_TO_REG(65)
+    MOV_TO_REG(66)
+    MOV_TO_REG(67)
+    MOV_TO_REG(68)
+    MOV_TO_REG(69)
+    MOV_TO_REG(70)
+    MOV_TO_REG(71)
+    MOV_TO_REG(72)
+    MOV_TO_REG(73)
+    MOV_TO_REG(74)
+    MOV_TO_REG(75)
+    MOV_TO_REG(76)
+    MOV_TO_REG(77)
+    MOV_TO_REG(78)
+    MOV_TO_REG(79)
+    MOV_TO_REG(80)
+    MOV_TO_REG(81)
+    MOV_TO_REG(82)
+    MOV_TO_REG(83)
+    MOV_TO_REG(84)
+    MOV_TO_REG(85)
+    MOV_TO_REG(86)
+    MOV_TO_REG(87)
+    MOV_TO_REG(88)
+    MOV_TO_REG(89)
+    MOV_TO_REG(90)
+    MOV_TO_REG(91)
+    MOV_TO_REG(92)
+    MOV_TO_REG(93)
+    MOV_TO_REG(94)
+    MOV_TO_REG(95)
+    MOV_TO_REG(96)
+    MOV_TO_REG(97)
+    MOV_TO_REG(98)
+    MOV_TO_REG(99)
+    MOV_TO_REG(100)
+    MOV_TO_REG(101)
+    MOV_TO_REG(102)
+    MOV_TO_REG(103)
+    MOV_TO_REG(104)
+    MOV_TO_REG(105)
+    MOV_TO_REG(106)
+    MOV_TO_REG(107)
+    MOV_TO_REG(108)
+    MOV_TO_REG(109)
+    MOV_TO_REG(110)
+    MOV_TO_REG(111)
+    MOV_TO_REG(112)
+    MOV_TO_REG(113)
+    MOV_TO_REG(114)
+    MOV_TO_REG(115)
+    MOV_TO_REG(116)
+    MOV_TO_REG(117)
+    MOV_TO_REG(118)
+    MOV_TO_REG(119)
+    MOV_TO_REG(120)
+    MOV_TO_REG(121)
+    MOV_TO_REG(122)
+    MOV_TO_REG(123)
+    MOV_TO_REG(124)
+    MOV_TO_REG(125)
+    MOV_TO_REG(126)
+    MOV_TO_REG(127)
+END(asm_mov_to_reg)
--=20
1.5.2

------_=_NextPart_001_01C893E6.2FFF0333
Content-Type: application/octet-stream;
	name="0013-KVM-IA64-Add-optimization-for-some-virtulization-fa.patch"
Content-Transfer-Encoding: base64
Content-Description: 0013-KVM-IA64-Add-optimization-for-some-virtulization-fa.patch
Content-Disposition: attachment;
	filename="0013-KVM-IA64-Add-optimization-for-some-virtulization-fa.patch"

RnJvbSAwZDY5OGVmZWQxNTc1OWI0OWU3OGFkY2VmMDg1ZmVkYTBhMTRhMTc1IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBYaWFudGFvIFpoYW5nIDx4aWFudGFvLnpoYW5nQGludGVsLmNv
bT4KRGF0ZTogVHVlLCAxIEFwciAyMDA4IDE0OjU3OjA5ICswODAwClN1YmplY3Q6IFtQQVRDSF0g
S1ZNOklBNjQ6IEFkZCBvcHRpbWl6YXRpb24gZm9yIHNvbWUgdmlydHVsaXphdGlvbiBmYXVsdHMK
Cm9wdHZmYXVsdC5TIEFkZCBvcHRpbWl6YXRpb24gZm9yIHNvbWUgcGVyZm9ybWFuY2UtY3JpdGlj
YWwKdmlydHVhbGl6YXRpb24gZmF1bHRzLgpTaWduZWQtb2ZmLWJ5OiBBbnRob255IFh1IDxhbnRo
b255Lnh1QGludGVsLmNvbT4KU2lnbmVkLW9mZi1ieTogWGlhbnRhbyBaaGFuZyA8eGlhbnRhby56
aGFuZ0BpbnRlbC5jb20+Ci0tLQogYXJjaC9pYTY0L2t2bS9vcHR2ZmF1bHQuUyB8ICA5MTggKysr
KysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrCiAxIGZpbGVzIGNoYW5n
ZWQsIDkxOCBpbnNlcnRpb25zKCspLCAwIGRlbGV0aW9ucygtKQogY3JlYXRlIG1vZGUgMTAwNjQ0
IGFyY2gvaWE2NC9rdm0vb3B0dmZhdWx0LlMKCmRpZmYgLS1naXQgYS9hcmNoL2lhNjQva3ZtL29w
dHZmYXVsdC5TIGIvYXJjaC9pYTY0L2t2bS9vcHR2ZmF1bHQuUwpuZXcgZmlsZSBtb2RlIDEwMDY0
NAppbmRleCAwMDAwMDAwLi41ZGUyMTBlCi0tLSAvZGV2L251bGwKKysrIGIvYXJjaC9pYTY0L2t2
bS9vcHR2ZmF1bHQuUwpAQCAtMCwwICsxLDkxOCBAQAorLyoKKyAqIGFyY2gvaWE2NC92bXgvb3B0
dmZhdWx0LlMKKyAqIG9wdGltaXplIHZpcnR1YWxpemF0aW9uIGZhdWx0IGhhbmRsZXIKKyAqCisg
KiBDb3B5cmlnaHQgKEMpIDIwMDYgSW50ZWwgQ28KKyAqCVh1ZWZlaSBYdSAoQW50aG9ueSBYdSkg
PGFudGhvbnkueHVAaW50ZWwuY29tPgorICovCisKKyNpbmNsdWRlIDxhc20vYXNtbWFjcm8uaD4K
KyNpbmNsdWRlIDxhc20vcHJvY2Vzc29yLmg+CisKKyNpbmNsdWRlICJ2dGkuaCIKKyNpbmNsdWRl
ICJhc20tb2Zmc2V0cy5oIgorCisjZGVmaW5lIEFDQ0VfTU9WX0ZST01fQVIKKyNkZWZpbmUgQUND
RV9NT1ZfRlJPTV9SUgorI2RlZmluZSBBQ0NFX01PVl9UT19SUgorI2RlZmluZSBBQ0NFX1JTTQor
I2RlZmluZSBBQ0NFX1NTTQorI2RlZmluZSBBQ0NFX01PVl9UT19QU1IKKyNkZWZpbmUgQUNDRV9U
SEFTSAorCisvL21vdiByMT1hcjMKK0dMT0JBTF9FTlRSWShrdm1fYXNtX21vdl9mcm9tX2FyKQor
I2lmbmRlZiBBQ0NFX01PVl9GUk9NX0FSCisgICAgYnIubWFueSBrdm1fdmlydHVhbGl6YXRpb25f
ZmF1bHRfYmFjaworI2VuZGlmCisgICAgYWRkIHIxOD1WTU1fVkNQVV9JVENfT0ZTX09GRlNFVCwg
cjIxCisgICAgYWRkIHIxNj1WTU1fVkNQVV9MQVNUX0lUQ19PRkZTRVQscjIxCisgICAgZXh0ci51
IHIxNz1yMjUsNiw3CisgICAgOzsKKyAgICBsZDggcjE4PVtyMThdCisgICAgbW92IHIxOT1hci5p
dGMKKyAgICBtb3YgcjI0PWIwCisgICAgOzsKKyAgICBhZGQgcjE5PXIxOSxyMTgKKyAgICBhZGRs
IHIyMD1AZ3ByZWwoYXNtX21vdl90b19yZWcpLGdwCisgICAgOzsKKyAgICBzdDggW3IxNl0gPSBy
MTkKKyAgICBhZGRzIHIzMD1rdm1fcmVzdW1lX3RvX2d1ZXN0LWFzbV9tb3ZfdG9fcmVnLHIyMAor
ICAgIHNobGFkZCByMTc9cjE3LDQscjIwCisgICAgOzsKKyAgICBtb3YgYjA9cjE3CisgICAgYnIu
c3B0ay5mZXcgYjAKKyAgICA7OworRU5EKGt2bV9hc21fbW92X2Zyb21fYXIpCisKKworLy8gbW92
IHIxPXJyW3IzXQorR0xPQkFMX0VOVFJZKGt2bV9hc21fbW92X2Zyb21fcnIpCisjaWZuZGVmIEFD
Q0VfTU9WX0ZST01fUlIKKyAgICBici5tYW55IGt2bV92aXJ0dWFsaXphdGlvbl9mYXVsdF9iYWNr
CisjZW5kaWYKKyAgICBleHRyLnUgcjE2PXIyNSwyMCw3CisgICAgZXh0ci51IHIxNz1yMjUsNiw3
CisgICAgYWRkbCByMjA9QGdwcmVsKGFzbV9tb3ZfZnJvbV9yZWcpLGdwCisgICAgOzsKKyAgICBh
ZGRzIHIzMD1rdm1fYXNtX21vdl9mcm9tX3JyX2JhY2tfMS1hc21fbW92X2Zyb21fcmVnLHIyMAor
ICAgIHNobGFkZCByMTY9cjE2LDQscjIwCisgICAgbW92IHIyND1iMAorICAgIDs7CisgICAgYWRk
IHIyNz1WTU1fVkNQVV9WUlIwX09GRlNFVCxyMjEKKyAgICBtb3YgYjA9cjE2CisgICAgYnIubWFu
eSBiMAorICAgIDs7Citrdm1fYXNtX21vdl9mcm9tX3JyX2JhY2tfMToKKyAgICBhZGRzIHIzMD1r
dm1fcmVzdW1lX3RvX2d1ZXN0LWFzbV9tb3ZfZnJvbV9yZWcscjIwCisgICAgYWRkcyByMjI9YXNt
X21vdl90b19yZWctYXNtX21vdl9mcm9tX3JlZyxyMjAKKyAgICBzaHIudSByMjY9cjE5LDYxCisg
ICAgOzsKKyAgICBzaGxhZGQgcjE3PXIxNyw0LHIyMgorICAgIHNobGFkZCByMjc9cjI2LDMscjI3
CisgICAgOzsKKyAgICBsZDggcjE5PVtyMjddCisgICAgbW92IGIwPXIxNworICAgIGJyLm1hbnkg
YjAKK0VORChrdm1fYXNtX21vdl9mcm9tX3JyKQorCisKKy8vIG1vdiBycltyM109cjIKK0dMT0JB
TF9FTlRSWShrdm1fYXNtX21vdl90b19ycikKKyNpZm5kZWYgQUNDRV9NT1ZfVE9fUlIKKyAgICBi
ci5tYW55IGt2bV92aXJ0dWFsaXphdGlvbl9mYXVsdF9iYWNrCisjZW5kaWYKKyAgICBleHRyLnUg
cjE2PXIyNSwyMCw3CisgICAgZXh0ci51IHIxNz1yMjUsMTMsNworICAgIGFkZGwgcjIwPUBncHJl
bChhc21fbW92X2Zyb21fcmVnKSxncAorICAgIDs7CisgICAgYWRkcyByMzA9a3ZtX2FzbV9tb3Zf
dG9fcnJfYmFja18xLWFzbV9tb3ZfZnJvbV9yZWcscjIwCisgICAgc2hsYWRkIHIxNj1yMTYsNCxy
MjAKKyAgICBtb3YgcjIyPWIwCisgICAgOzsKKyAgICBhZGQgcjI3PVZNTV9WQ1BVX1ZSUjBfT0ZG
U0VULHIyMQorICAgIG1vdiBiMD1yMTYKKyAgICBici5tYW55IGIwCisgICAgOzsKK2t2bV9hc21f
bW92X3RvX3JyX2JhY2tfMToKKyAgICBhZGRzIHIzMD1rdm1fYXNtX21vdl90b19ycl9iYWNrXzIt
YXNtX21vdl9mcm9tX3JlZyxyMjAKKyAgICBzaHIudSByMjM9cjE5LDYxCisgICAgc2hsYWRkIHIx
Nz1yMTcsNCxyMjAKKyAgICA7OworICAgIC8vaWYgcnI2LCBnbyBiYWNrCisgICAgY21wLmVxIHA2
LHAwPTYscjIzCisgICAgbW92IGIwPXIyMgorICAgIChwNikgYnIuY29uZC5kcG50Lm1hbnkga3Zt
X3ZpcnR1YWxpemF0aW9uX2ZhdWx0X2JhY2sKKyAgICA7OworICAgIG1vdiByMjg9cjE5CisgICAg
bW92IGIwPXIxNworICAgIGJyLm1hbnkgYjAKK2t2bV9hc21fbW92X3RvX3JyX2JhY2tfMjoKKyAg
ICBhZGRzIHIzMD1rdm1fcmVzdW1lX3RvX2d1ZXN0LWFzbV9tb3ZfZnJvbV9yZWcscjIwCisgICAg
c2hsYWRkIHIyNz1yMjMsMyxyMjcKKyAgICA7OyAvLyB2cnIucmlkPDw0IHwweGUKKyAgICBzdDgg
W3IyN109cjE5CisgICAgbW92IGIwPXIzMAorICAgIDs7CisgICAgZXh0ci51IHIxNj1yMTksOCwy
NgorICAgIGV4dHIudSByMTggPXIxOSwyLDYKKyAgICBtb3YgcjE3ID0weGUKKyAgICA7OworICAg
IHNobGFkZCByMTYgPSByMTYsIDQsIHIxNworICAgIGV4dHIudSByMTkgPXIxOSwwLDgKKyAgICA7
OworICAgIHNobCByMTYgPSByMTYsOAorICAgIDs7CisgICAgYWRkIHIxOSA9IHIxOSwgcjE2Cisg
ICAgOzsgLy9zZXQgdmUgMQorICAgIGRlcCByMTk9LTEscjE5LDAsMQorICAgIGNtcC5sdCBwNixw
MD0xNCxyMTgKKyAgICA7OworICAgIChwNikgbW92IHIxOD0xNAorICAgIDs7CisgICAgKHA2KSBk
ZXAgcjE5PXIxOCxyMTksMiw2CisgICAgOzsKKyAgICBjbXAuZXEgcDYscDA9MCxyMjMKKyAgICA7
OworICAgIGNtcC5lcS5vciBwNixwMD00LHIyMworICAgIDs7CisgICAgYWRkcyByMTY9Vk1NX1ZD
UFVfTU9ERV9GTEFHU19PRkZTRVQscjIxCisgICAgKHA2KSBhZGRzIHIxNz1WTU1fVkNQVV9NRVRB
X1NBVkVEX1JSMF9PRkZTRVQscjIxCisgICAgOzsKKyAgICBsZDQgcjE2PVtyMTZdCisgICAgY21w
LmVxIHA3LHAwPXIwLHIwCisgICAgKHA2KSBzaGxhZGQgcjE3PXIyMywxLHIxNworICAgIDs7Cisg
ICAgKHA2KSBzdDggW3IxN109cjE5CisgICAgKHA2KSB0Yml0Lm56IHA2LHA3PXIxNiwwCisgICAg
OzsKKyAgICAocDcpIG1vdiBycltyMjhdPXIxOQorICAgIG1vdiByMjQ9cjIyCisgICAgYnIubWFu
eSBiMAorRU5EKGt2bV9hc21fbW92X3RvX3JyKQorCisKKy8vcnNtCitHTE9CQUxfRU5UUlkoa3Zt
X2FzbV9yc20pCisjaWZuZGVmIEFDQ0VfUlNNCisgICAgYnIubWFueSBrdm1fdmlydHVhbGl6YXRp
b25fZmF1bHRfYmFjaworI2VuZGlmCisgICAgYWRkIHIxNj1WTU1fVlBEX0JBU0VfT0ZGU0VULHIy
MQorICAgIGV4dHIudSByMjY9cjI1LDYsMjEKKyAgICBleHRyLnUgcjI3PXIyNSwzMSwyCisgICAg
OzsKKyAgICBsZDggcjE2PVtyMTZdCisgICAgZXh0ci51IHIyOD1yMjUsMzYsMQorICAgIGRlcCBy
MjY9cjI3LHIyNiwyMSwyCisgICAgOzsKKyAgICBhZGQgcjE3PVZQRF9WUFNSX1NUQVJUX09GRlNF
VCxyMTYKKyAgICBhZGQgcjIyPVZNTV9WQ1BVX01PREVfRkxBR1NfT0ZGU0VULHIyMQorICAgIC8v
cjI2IGlzIGltbTI0CisgICAgZGVwIHIyNj1yMjgscjI2LDIzLDEKKyAgICA7OworICAgIGxkOCBy
MTg9W3IxN10KKyAgICBtb3ZsIHIyOD1JQTY0X1BTUl9JQytJQTY0X1BTUl9JK0lBNjRfUFNSX0RU
K0lBNjRfUFNSX1NJCisgICAgbGQ0IHIyMz1bcjIyXQorICAgIHN1YiByMjc9LTEscjI2CisgICAg
bW92IHIyND1iMAorICAgIDs7CisgICAgbW92IHIyMD1jci5pcHNyCisgICAgb3IgcjI4PXIyNyxy
MjgKKyAgICBhbmQgcjE5PXIxOCxyMjcKKyAgICA7OworICAgIHN0OCBbcjE3XT1yMTkKKyAgICBh
bmQgcjIwPXIyMCxyMjgKKyAgICAvKiBDb21tZW50IGl0IG91dCBkdWUgdG8gc2hvcnQgb2YgZnAg
bGF6eSBhbG9yZ2l0aG0gc3VwcG9ydAorICAgIGFkZHMgcjI3PUlBNjRfVkNQVV9GUF9QU1JfT0ZG
U0VULHIyMQorICAgIDs7CisgICAgbGQ4IHIyNz1bcjI3XQorICAgIDs7CisgICAgdGJpdC5ueiBw
OCxwMD0gcjI3LElBNjRfUFNSX0RGSF9CSVQKKyAgICA7OworICAgIChwOCkgZGVwIHIyMD0tMSxy
MjAsSUE2NF9QU1JfREZIX0JJVCwxCisgICAgKi8KKyAgICA7OworICAgIG1vdiBjci5pcHNyPXIy
MAorICAgIHRiaXQubnogcDYscDA9cjIzLDAKKyAgICA7OworICAgIHRiaXQuei5vciBwNixwMD1y
MjYsSUE2NF9QU1JfRFRfQklUCisgICAgKHA2KSBici5kcHRrIGt2bV9yZXN1bWVfdG9fZ3Vlc3QK
KyAgICA7OworICAgIGFkZCByMjY9Vk1NX1ZDUFVfTUVUQV9SUjBfT0ZGU0VULHIyMQorICAgIGFk
ZCByMjc9Vk1NX1ZDUFVfTUVUQV9SUjBfT0ZGU0VUKzgscjIxCisgICAgZGVwIHIyMz0tMSxyMjMs
MCwxCisgICAgOzsKKyAgICBsZDggcjI2PVtyMjZdCisgICAgbGQ4IHIyNz1bcjI3XQorICAgIHN0
NCBbcjIyXT1yMjMKKyAgICBkZXAueiByMjg9NCw2MSwzCisgICAgOzsKKyAgICBtb3YgcnJbcjBd
PXIyNgorICAgIDs7CisgICAgbW92IHJyW3IyOF09cjI3CisgICAgOzsKKyAgICBzcmx6LmQKKyAg
ICBici5tYW55IGt2bV9yZXN1bWVfdG9fZ3Vlc3QKK0VORChrdm1fYXNtX3JzbSkKKworCisvL3Nz
bQorR0xPQkFMX0VOVFJZKGt2bV9hc21fc3NtKQorI2lmbmRlZiBBQ0NFX1NTTQorICAgIGJyLm1h
bnkga3ZtX3ZpcnR1YWxpemF0aW9uX2ZhdWx0X2JhY2sKKyNlbmRpZgorICAgIGFkZCByMTY9Vk1N
X1ZQRF9CQVNFX09GRlNFVCxyMjEKKyAgICBleHRyLnUgcjI2PXIyNSw2LDIxCisgICAgZXh0ci51
IHIyNz1yMjUsMzEsMgorICAgIDs7CisgICAgbGQ4IHIxNj1bcjE2XQorICAgIGV4dHIudSByMjg9
cjI1LDM2LDEKKyAgICBkZXAgcjI2PXIyNyxyMjYsMjEsMgorICAgIDs7ICAvL3IyNiBpcyBpbW0y
NAorICAgIGFkZCByMjc9VlBEX1ZQU1JfU1RBUlRfT0ZGU0VULHIxNgorICAgIGRlcCByMjY9cjI4
LHIyNiwyMywxCisgICAgOzsgIC8vcjE5IHZwc3IKKyAgICBsZDggcjI5PVtyMjddCisgICAgbW92
IHIyND1iMAorICAgIDs7CisgICAgYWRkIHIyMj1WTU1fVkNQVV9NT0RFX0ZMQUdTX09GRlNFVCxy
MjEKKyAgICBtb3YgcjIwPWNyLmlwc3IKKyAgICBvciByMTk9cjI5LHIyNgorICAgIDs7CisgICAg
bGQ0IHIyMz1bcjIyXQorICAgIHN0OCBbcjI3XT1yMTkKKyAgICBvciByMjA9cjIwLHIyNgorICAg
IDs7CisgICAgbW92IGNyLmlwc3I9cjIwCisgICAgbW92bCByMjg9SUE2NF9QU1JfRFQrSUE2NF9Q
U1JfUlQrSUE2NF9QU1JfSVQKKyAgICA7OworICAgIGFuZCByMTk9cjI4LHIxOQorICAgIHRiaXQu
eiBwNixwMD1yMjMsMAorICAgIDs7CisgICAgY21wLm5lLm9yIHA2LHAwPXIyOCxyMTkKKyAgICAo
cDYpIGJyLmRwdGsga3ZtX2FzbV9zc21fMQorICAgIDs7CisgICAgYWRkIHIyNj1WTU1fVkNQVV9N
RVRBX1NBVkVEX1JSMF9PRkZTRVQscjIxCisgICAgYWRkIHIyNz1WTU1fVkNQVV9NRVRBX1NBVkVE
X1JSMF9PRkZTRVQrOCxyMjEKKyAgICBkZXAgcjIzPTAscjIzLDAsMQorICAgIDs7CisgICAgbGQ4
IHIyNj1bcjI2XQorICAgIGxkOCByMjc9W3IyN10KKyAgICBzdDQgW3IyMl09cjIzCisgICAgZGVw
LnogcjI4PTQsNjEsMworICAgIDs7CisgICAgbW92IHJyW3IwXT1yMjYKKyAgICA7OworICAgIG1v
diBycltyMjhdPXIyNworICAgIDs7CisgICAgc3Jsei5kCisgICAgOzsKK2t2bV9hc21fc3NtXzE6
CisgICAgdGJpdC5ueiBwNixwMD1yMjksSUE2NF9QU1JfSV9CSVQKKyAgICA7OworICAgIHRiaXQu
ei5vciBwNixwMD1yMTksSUE2NF9QU1JfSV9CSVQKKyAgICAocDYpIGJyLmRwdGsga3ZtX3Jlc3Vt
ZV90b19ndWVzdAorICAgIDs7CisgICAgYWRkIHIyOT1WUERfVlRQUl9TVEFSVF9PRkZTRVQscjE2
CisgICAgYWRkIHIzMD1WUERfVkhQSV9TVEFSVF9PRkZTRVQscjE2CisgICAgOzsKKyAgICBsZDgg
cjI5PVtyMjldCisgICAgbGQ4IHIzMD1bcjMwXQorICAgIDs7CisgICAgZXh0ci51IHIxNz1yMjks
NCw0CisgICAgZXh0ci51IHIxOD1yMjksMTYsMQorICAgIDs7CisgICAgZGVwIHIxNz1yMTgscjE3
LDQsMQorICAgIDs7CisgICAgY21wLmd0IHA2LHAwPXIzMCxyMTcKKyAgICAocDYpIGJyLmRwbnQu
ZmV3IGt2bV9hc21fZGlzcGF0Y2hfdmV4aXJxCisgICAgYnIubWFueSBrdm1fcmVzdW1lX3RvX2d1
ZXN0CitFTkQoa3ZtX2FzbV9zc20pCisKKworLy9tb3YgcHNyLmw9cjIKK0dMT0JBTF9FTlRSWShr
dm1fYXNtX21vdl90b19wc3IpCisjaWZuZGVmIEFDQ0VfTU9WX1RPX1BTUgorICAgIGJyLm1hbnkg
a3ZtX3ZpcnR1YWxpemF0aW9uX2ZhdWx0X2JhY2sKKyNlbmRpZgorICAgIGFkZCByMTY9Vk1NX1ZQ
RF9CQVNFX09GRlNFVCxyMjEKKyAgICBleHRyLnUgcjI2PXIyNSwxMyw3IC8vcjIKKyAgICA7Owor
ICAgIGxkOCByMTY9W3IxNl0KKyAgICBhZGRsIHIyMD1AZ3ByZWwoYXNtX21vdl9mcm9tX3JlZyks
Z3AKKyAgICA7OworICAgIGFkZHMgcjMwPWt2bV9hc21fbW92X3RvX3Bzcl9iYWNrLWFzbV9tb3Zf
ZnJvbV9yZWcscjIwCisgICAgc2hsYWRkIHIyNj1yMjYsNCxyMjAKKyAgICBtb3YgcjI0PWIwCisg
ICAgOzsKKyAgICBhZGQgcjI3PVZQRF9WUFNSX1NUQVJUX09GRlNFVCxyMTYKKyAgICBtb3YgYjA9
cjI2CisgICAgYnIubWFueSBiMAorICAgIDs7Citrdm1fYXNtX21vdl90b19wc3JfYmFjazoKKyAg
ICBsZDggcjE3PVtyMjddCisgICAgYWRkIHIyMj1WTU1fVkNQVV9NT0RFX0ZMQUdTX09GRlNFVCxy
MjEKKyAgICBkZXAgcjE5PTAscjE5LDMyLDMyCisgICAgOzsKKyAgICBsZDQgcjIzPVtyMjJdCisg
ICAgZGVwIHIxOD0wLHIxNywwLDMyCisgICAgOzsKKyAgICBhZGQgcjMwPXIxOCxyMTkKKyAgICBt
b3ZsIHIyOD1JQTY0X1BTUl9EVCtJQTY0X1BTUl9SVCtJQTY0X1BTUl9JVAorICAgIDs7CisgICAg
c3Q4IFtyMjddPXIzMAorICAgIGFuZCByMjc9cjI4LHIzMAorICAgIGFuZCByMjk9cjI4LHIxNwor
ICAgIDs7CisgICAgY21wLmVxIHA1LHAwPXIyOSxyMjcKKyAgICBjbXAuZXEgcDYscDc9cjI4LHIy
NworICAgIChwNSkgYnIubWFueSBrdm1fYXNtX21vdl90b19wc3JfMQorICAgIDs7CisgICAgLy92
aXJ0dWFsIHRvIHBoeXNpY2FsCisgICAgKHA3KSBhZGQgcjI2PVZNTV9WQ1BVX01FVEFfUlIwX09G
RlNFVCxyMjEKKyAgICAocDcpIGFkZCByMjc9Vk1NX1ZDUFVfTUVUQV9SUjBfT0ZGU0VUKzgscjIx
CisgICAgKHA3KSBkZXAgcjIzPS0xLHIyMywwLDEKKyAgICA7OworICAgIC8vcGh5c2ljYWwgdG8g
dmlydHVhbAorICAgIChwNikgYWRkIHIyNj1WTU1fVkNQVV9NRVRBX1NBVkVEX1JSMF9PRkZTRVQs
cjIxCisgICAgKHA2KSBhZGQgcjI3PVZNTV9WQ1BVX01FVEFfU0FWRURfUlIwX09GRlNFVCs4LHIy
MQorICAgIChwNikgZGVwIHIyMz0wLHIyMywwLDEKKyAgICA7OworICAgIGxkOCByMjY9W3IyNl0K
KyAgICBsZDggcjI3PVtyMjddCisgICAgc3Q0IFtyMjJdPXIyMworICAgIGRlcC56IHIyOD00LDYx
LDMKKyAgICA7OworICAgIG1vdiBycltyMF09cjI2CisgICAgOzsKKyAgICBtb3YgcnJbcjI4XT1y
MjcKKyAgICA7OworICAgIHNybHouZAorICAgIDs7Citrdm1fYXNtX21vdl90b19wc3JfMToKKyAg
ICBtb3YgcjIwPWNyLmlwc3IKKyAgICBtb3ZsIHIyOD1JQTY0X1BTUl9JQytJQTY0X1BTUl9JK0lB
NjRfUFNSX0RUK0lBNjRfUFNSX1NJK0lBNjRfUFNSX1JUCisgICAgOzsKKyAgICBvciByMTk9cjE5
LHIyOAorICAgIGRlcCByMjA9MCxyMjAsMCwzMgorICAgIDs7CisgICAgYWRkIHIyMD1yMTkscjIw
CisgICAgbW92IGIwPXIyNAorICAgIDs7CisgICAgLyogQ29tbWVudCBpdCBvdXQgZHVlIHRvIHNo
b3J0IG9mIGZwIGxhenkgYWxnb3JpdGhtIHN1cHBvcnQKKyAgICBhZGRzIHIyNz1JQTY0X1ZDUFVf
RlBfUFNSX09GRlNFVCxyMjEKKyAgICA7OworICAgIGxkOCByMjc9W3IyN10KKyAgICA7OworICAg
IHRiaXQubnogcDgscDA9cjI3LElBNjRfUFNSX0RGSF9CSVQKKyAgICA7OworICAgIChwOCkgZGVw
IHIyMD0tMSxyMjAsSUE2NF9QU1JfREZIX0JJVCwxCisgICAgOzsKKyAgICAqLworICAgIG1vdiBj
ci5pcHNyPXIyMAorICAgIGNtcC5uZSBwNixwMD1yMCxyMAorICAgIDs7CisgICAgdGJpdC5uei5v
ciBwNixwMD1yMTcsSUE2NF9QU1JfSV9CSVQKKyAgICB0Yml0Lnoub3IgcDYscDA9cjMwLElBNjRf
UFNSX0lfQklUCisgICAgKHA2KSBici5kcG50LmZldyBrdm1fcmVzdW1lX3RvX2d1ZXN0CisgICAg
OzsKKyAgICBhZGQgcjI5PVZQRF9WVFBSX1NUQVJUX09GRlNFVCxyMTYKKyAgICBhZGQgcjMwPVZQ
RF9WSFBJX1NUQVJUX09GRlNFVCxyMTYKKyAgICA7OworICAgIGxkOCByMjk9W3IyOV0KKyAgICBs
ZDggcjMwPVtyMzBdCisgICAgOzsKKyAgICBleHRyLnUgcjE3PXIyOSw0LDQKKyAgICBleHRyLnUg
cjE4PXIyOSwxNiwxCisgICAgOzsKKyAgICBkZXAgcjE3PXIxOCxyMTcsNCwxCisgICAgOzsKKyAg
ICBjbXAuZ3QgcDYscDA9cjMwLHIxNworICAgIChwNikgYnIuZHBudC5mZXcga3ZtX2FzbV9kaXNw
YXRjaF92ZXhpcnEKKyAgICBici5tYW55IGt2bV9yZXN1bWVfdG9fZ3Vlc3QKK0VORChrdm1fYXNt
X21vdl90b19wc3IpCisKKworRU5UUlkoa3ZtX2FzbV9kaXNwYXRjaF92ZXhpcnEpCisvL2luY3Jl
bWVudCBpaXAKKyAgICBtb3YgcjE2PWNyLmlwc3IKKyAgICA7OworICAgIGV4dHIudSByMTc9cjE2
LElBNjRfUFNSX1JJX0JJVCwyCisgICAgdGJpdC5ueiBwNixwNz1yMTYsSUE2NF9QU1JfUklfQklU
KzEKKyAgICA7OworICAgIChwNikgbW92IHIxOD1jci5paXAKKyAgICAocDYpIG1vdiByMTc9cjAK
KyAgICAocDcpIGFkZCByMTc9MSxyMTcKKyAgICA7OworICAgIChwNikgYWRkIHIxOD0weDEwLHIx
OAorICAgIGRlcCByMTY9cjE3LHIxNixJQTY0X1BTUl9SSV9CSVQsMgorICAgIDs7CisgICAgKHA2
KSBtb3YgY3IuaWlwPXIxOAorICAgIG1vdiBjci5pcHNyPXIxNgorICAgIG1vdiByMzAgPTEKKyAg
ICBici5tYW55IGt2bV9kaXNwYXRjaF92ZXhpcnEKK0VORChrdm1fYXNtX2Rpc3BhdGNoX3ZleGly
cSkKKworLy8gdGhhc2gKKy8vIFRPRE86IGFkZCBzdXBwb3J0IHdoZW4gcHRhLnZmID0gMQorR0xP
QkFMX0VOVFJZKGt2bV9hc21fdGhhc2gpCisjaWZuZGVmIEFDQ0VfVEhBU0gKKyAgICBici5tYW55
IGt2bV92aXJ0dWFsaXphdGlvbl9mYXVsdF9iYWNrCisjZW5kaWYKKyAgICBleHRyLnUgcjE3PXIy
NSwyMCw3CQkvLyBnZXQgcjMgZnJvbSBvcGNvZGUgaW4gcjI1CisgICAgZXh0ci51IHIxOD1yMjUs
Niw3CQkvLyBnZXQgcjEgZnJvbSBvcGNvZGUgaW4gcjI1CisgICAgYWRkbCByMjA9QGdwcmVsKGFz
bV9tb3ZfZnJvbV9yZWcpLGdwCisgICAgOzsKKyAgICBhZGRzIHIzMD1rdm1fYXNtX3RoYXNoX2Jh
Y2sxLWFzbV9tb3ZfZnJvbV9yZWcscjIwCisgICAgc2hsYWRkIHIxNz1yMTcsNCxyMjAJLy8gZ2V0
IGFkZHIgb2YgTU9WRV9GUk9NX1JFRyhyMTcpCisgICAgYWRkcyByMTY9Vk1NX1ZQRF9CQVNFX09G
RlNFVCxyMjEJLy8gZ2V0IHZjcHUuYXJjaC5wcml2ZXJlZ3MKKyAgICA7OworICAgIG1vdiByMjQ9
YjAKKyAgICA7OworICAgIGxkOCByMTY9W3IxNl0JCS8vIGdldCBWUEQgYWRkcgorICAgIG1vdiBi
MD1yMTcKKyAgICBici5tYW55IGIwCQkJLy8gcjE5IHJldHVybiB2YWx1ZQorICAgIDs7Citrdm1f
YXNtX3RoYXNoX2JhY2sxOgorICAgIHNoci51IHIyMz1yMTksNjEJCS8vIGdldCBSUiBudW1iZXIK
KyAgICBhZGRzIHIyNT1WTU1fVkNQVV9WUlIwX09GRlNFVCxyMjEJLy8gZ2V0IHZjcHUtPmFyY2gu
dnJyWzBdJ3MgYWRkcgorICAgIGFkZHMgcjE2PVZNTV9WUERfVlBUQV9PRkZTRVQscjE2CS8vIGdl
dCB2cHRhCisgICAgOzsKKyAgICBzaGxhZGQgcjI3PXIyMywzLHIyNQkvLyBnZXQgdmNwdS0+YXJj
aC52cnJbcjIzXSdzIGFkZHIKKyAgICBsZDggcjE3PVtyMTZdCQkvLyBnZXQgUFRBCisgICAgbW92
IHIyNj0xCisgICAgOzsKKyAgICBleHRyLnUgcjI5PXIxNywyLDYJCS8vIGdldCBwdGEuc2l6ZQor
ICAgIGxkOCByMjU9W3IyN10JCS8vIGdldCB2Y3B1LT5hcmNoLnZycltyMjNdJ3MgdmFsdWUKKyAg
ICA7OworICAgIGV4dHIudSByMjU9cjI1LDIsNgkJLy8gZ2V0IHJyLnBzCisgICAgc2hsIHIyMj1y
MjYscjI5CQkvLyAxVUwgPDwgcHRhLnNpemUKKyAgICA7OworICAgIHNoci51IHIyMz1yMTkscjI1
CQkvLyB2YWRkciA+PiByci5wcworICAgIGFkZHMgcjI2PTMscjI5CQkvLyBwdGEuc2l6ZSArIDMK
KyAgICBzaGwgcjI3PXIxNywzCQkvLyBwdGEgPDwgMworICAgIDs7CisgICAgc2hsIHIyMz1yMjMs
MwkJLy8gKHZhZGRyID4+IHJyLnBzKSA8PCAzCisgICAgc2hyLnUgcjI3PXIyNyxyMjYJCS8vIChw
dGEgPDwgMykgPj4gKHB0YS5zaXplKzMpCisgICAgbW92bCByMTY9Nzw8NjEKKyAgICA7OworICAg
IGFkZHMgcjIyPS0xLHIyMgkJLy8gKDFVTCA8PCBwdGEuc2l6ZSkgLSAxCisgICAgc2hsIHIyNz1y
MjcscjI5CQkvLyAoKHB0YTw8Myk+PihwdGEuc2l6ZSszKSk8PHB0YS5zaXplCisgICAgYW5kIHIx
OT1yMTkscjE2CQkvLyB2YWRkciAmIFZSTl9NQVNLCisgICAgOzsKKyAgICBhbmQgcjIyPXIyMixy
MjMJCS8vIHZocHRfb2Zmc2V0CisgICAgb3IgcjE5PXIxOSxyMjcgLy8gKHZhZHImVlJOX01BU0sp
IHwoKChwdGE8PDMpPj4ocHRhLnNpemUgKyAzKSk8PHB0YS5zaXplKQorICAgIGFkZHMgcjI2PWFz
bV9tb3ZfdG9fcmVnLWFzbV9tb3ZfZnJvbV9yZWcscjIwCisgICAgOzsKKyAgICBvciByMTk9cjE5
LHIyMgkJLy8gY2FsYyBwdmFsCisgICAgc2hsYWRkIHIxNz1yMTgsNCxyMjYKKyAgICBhZGRzIHIz
MD1rdm1fcmVzdW1lX3RvX2d1ZXN0LWFzbV9tb3ZfZnJvbV9yZWcscjIwCisgICAgOzsKKyAgICBt
b3YgYjA9cjE3CisgICAgYnIubWFueSBiMAorRU5EKGt2bV9hc21fdGhhc2gpCisKKyNkZWZpbmUg
TU9WX1RPX1JFRzAJXAorezsJCQlcCisgICAgbm9wLmIgMHgwOwkJXAorICAgIG5vcC5iIDB4MDsJ
CVwKKyAgICBub3AuYiAweDA7CQlcCisgICAgOzsJCQlcCit9OworCisKKyNkZWZpbmUgTU9WX1RP
X1JFRyhuKQlcCit7OwkJCVwKKyAgICBtb3YgciMjbiMjPXIxOTsJXAorICAgIG1vdiBiMD1yMzA7
CVwKKyAgICBici5zcHRrLm1hbnkgYjA7CVwKKyAgICA7OwkJCVwKK307CisKKworI2RlZmluZSBN
T1ZfRlJPTV9SRUcobikJXAorezsJCQkJXAorICAgIG1vdiByMTk9ciMjbiMjOwkJXAorICAgIG1v
diBiMD1yMzA7CQlcCisgICAgYnIuc3B0ay5tYW55IGIwOwkJXAorICAgIDs7CQkJCVwKK307CisK
KworI2RlZmluZSBNT1ZfVE9fQkFOSzBfUkVHKG4pCQkJXAorRU5UUllfTUlOX0FMSUdOKGFzbV9t
b3ZfdG9fYmFuazBfcmVnIyNuIyMpOwlcCit7OwkJCQkJCVwKKyAgICBtb3YgcjI2PXIyOwkJCQlc
CisgICAgbW92IHIyPXIxOTsJCQkJXAorICAgIGJzdy4xOwkJCQkJXAorICAgIDs7CQkJCQkJXAor
fTsJCQkJCQlcCit7OwkJCQkJCVwKKyAgICBtb3YgciMjbiMjPXIyOwkJCQlcCisgICAgbm9wLmIg
MHgwOwkJCQkJXAorICAgIGJzdy4wOwkJCQkJXAorICAgIDs7CQkJCQkJXAorfTsJCQkJCQlcCit7
OwkJCQkJCVwKKyAgICBtb3YgcjI9cjI2OwkJCQlcCisgICAgbW92IGIwPXIzMDsJCQkJXAorICAg
IGJyLnNwdGsubWFueSBiMDsJCQkJXAorICAgIDs7CQkJCQkJXAorfTsJCQkJCQlcCitFTkQoYXNt
X21vdl90b19iYW5rMF9yZWcjI24jIykKKworCisjZGVmaW5lIE1PVl9GUk9NX0JBTkswX1JFRyhu
KQkJCVwKK0VOVFJZX01JTl9BTElHTihhc21fbW92X2Zyb21fYmFuazBfcmVnIyNuIyMpOwlcCit7
OwkJCQkJCVwKKyAgICBtb3YgcjI2PXIyOwkJCQlcCisgICAgbm9wLmIgMHgwOwkJCQkJXAorICAg
IGJzdy4xOwkJCQkJXAorICAgIDs7CQkJCQkJXAorfTsJCQkJCQlcCit7OwkJCQkJCVwKKyAgICBt
b3YgcjI9ciMjbiMjOwkJCQlcCisgICAgbm9wLmIgMHgwOwkJCQkJXAorICAgIGJzdy4wOwkJCQkJ
XAorICAgIDs7CQkJCQkJXAorfTsJCQkJCQlcCit7OwkJCQkJCVwKKyAgICBtb3YgcjE5PXIyOwkJ
CQlcCisgICAgbW92IHIyPXIyNjsJCQkJXAorICAgIG1vdiBiMD1yMzA7CQkJCVwKK307CQkJCQkJ
XAorezsJCQkJCQlcCisgICAgbm9wLmIgMHgwOwkJCQkJXAorICAgIG5vcC5iIDB4MDsJCQkJCVwK
KyAgICBici5zcHRrLm1hbnkgYjA7CQkJCVwKKyAgICA7OwkJCQkJCVwKK307CQkJCQkJXAorRU5E
KGFzbV9tb3ZfZnJvbV9iYW5rMF9yZWcjI24jIykKKworCisjZGVmaW5lIEpNUF9UT19NT1ZfVE9f
QkFOSzBfUkVHKG4pCQlcCit7OwkJCQkJCVwKKyAgICBub3AuYiAweDA7CQkJCQlcCisgICAgbm9w
LmIgMHgwOwkJCQkJXAorICAgIGJyLnNwdGsubWFueSBhc21fbW92X3RvX2JhbmswX3JlZyMjbiMj
OwlcCisgICAgOzsJCQkJCQlcCit9CisKKworI2RlZmluZSBKTVBfVE9fTU9WX0ZST01fQkFOSzBf
UkVHKG4pCQlcCit7OwkJCQkJCVwKKyAgICBub3AuYiAweDA7CQkJCQlcCisgICAgbm9wLmIgMHgw
OwkJCQkJXAorICAgIGJyLnNwdGsubWFueSBhc21fbW92X2Zyb21fYmFuazBfcmVnIyNuIyM7CVwK
KyAgICA7OwkJCQkJCVwKK30KKworCitNT1ZfRlJPTV9CQU5LMF9SRUcoMTYpCitNT1ZfRlJPTV9C
QU5LMF9SRUcoMTcpCitNT1ZfRlJPTV9CQU5LMF9SRUcoMTgpCitNT1ZfRlJPTV9CQU5LMF9SRUco
MTkpCitNT1ZfRlJPTV9CQU5LMF9SRUcoMjApCitNT1ZfRlJPTV9CQU5LMF9SRUcoMjEpCitNT1Zf
RlJPTV9CQU5LMF9SRUcoMjIpCitNT1ZfRlJPTV9CQU5LMF9SRUcoMjMpCitNT1ZfRlJPTV9CQU5L
MF9SRUcoMjQpCitNT1ZfRlJPTV9CQU5LMF9SRUcoMjUpCitNT1ZfRlJPTV9CQU5LMF9SRUcoMjYp
CitNT1ZfRlJPTV9CQU5LMF9SRUcoMjcpCitNT1ZfRlJPTV9CQU5LMF9SRUcoMjgpCitNT1ZfRlJP
TV9CQU5LMF9SRUcoMjkpCitNT1ZfRlJPTV9CQU5LMF9SRUcoMzApCitNT1ZfRlJPTV9CQU5LMF9S
RUcoMzEpCisKKworLy8gbW92IGZyb20gcmVnIHRhYmxlCitFTlRSWShhc21fbW92X2Zyb21fcmVn
KQorICAgIE1PVl9GUk9NX1JFRygwKQorICAgIE1PVl9GUk9NX1JFRygxKQorICAgIE1PVl9GUk9N
X1JFRygyKQorICAgIE1PVl9GUk9NX1JFRygzKQorICAgIE1PVl9GUk9NX1JFRyg0KQorICAgIE1P
Vl9GUk9NX1JFRyg1KQorICAgIE1PVl9GUk9NX1JFRyg2KQorICAgIE1PVl9GUk9NX1JFRyg3KQor
ICAgIE1PVl9GUk9NX1JFRyg4KQorICAgIE1PVl9GUk9NX1JFRyg5KQorICAgIE1PVl9GUk9NX1JF
RygxMCkKKyAgICBNT1ZfRlJPTV9SRUcoMTEpCisgICAgTU9WX0ZST01fUkVHKDEyKQorICAgIE1P
Vl9GUk9NX1JFRygxMykKKyAgICBNT1ZfRlJPTV9SRUcoMTQpCisgICAgTU9WX0ZST01fUkVHKDE1
KQorICAgIEpNUF9UT19NT1ZfRlJPTV9CQU5LMF9SRUcoMTYpCisgICAgSk1QX1RPX01PVl9GUk9N
X0JBTkswX1JFRygxNykKKyAgICBKTVBfVE9fTU9WX0ZST01fQkFOSzBfUkVHKDE4KQorICAgIEpN
UF9UT19NT1ZfRlJPTV9CQU5LMF9SRUcoMTkpCisgICAgSk1QX1RPX01PVl9GUk9NX0JBTkswX1JF
RygyMCkKKyAgICBKTVBfVE9fTU9WX0ZST01fQkFOSzBfUkVHKDIxKQorICAgIEpNUF9UT19NT1Zf
RlJPTV9CQU5LMF9SRUcoMjIpCisgICAgSk1QX1RPX01PVl9GUk9NX0JBTkswX1JFRygyMykKKyAg
ICBKTVBfVE9fTU9WX0ZST01fQkFOSzBfUkVHKDI0KQorICAgIEpNUF9UT19NT1ZfRlJPTV9CQU5L
MF9SRUcoMjUpCisgICAgSk1QX1RPX01PVl9GUk9NX0JBTkswX1JFRygyNikKKyAgICBKTVBfVE9f
TU9WX0ZST01fQkFOSzBfUkVHKDI3KQorICAgIEpNUF9UT19NT1ZfRlJPTV9CQU5LMF9SRUcoMjgp
CisgICAgSk1QX1RPX01PVl9GUk9NX0JBTkswX1JFRygyOSkKKyAgICBKTVBfVE9fTU9WX0ZST01f
QkFOSzBfUkVHKDMwKQorICAgIEpNUF9UT19NT1ZfRlJPTV9CQU5LMF9SRUcoMzEpCisgICAgTU9W
X0ZST01fUkVHKDMyKQorICAgIE1PVl9GUk9NX1JFRygzMykKKyAgICBNT1ZfRlJPTV9SRUcoMzQp
CisgICAgTU9WX0ZST01fUkVHKDM1KQorICAgIE1PVl9GUk9NX1JFRygzNikKKyAgICBNT1ZfRlJP
TV9SRUcoMzcpCisgICAgTU9WX0ZST01fUkVHKDM4KQorICAgIE1PVl9GUk9NX1JFRygzOSkKKyAg
ICBNT1ZfRlJPTV9SRUcoNDApCisgICAgTU9WX0ZST01fUkVHKDQxKQorICAgIE1PVl9GUk9NX1JF
Ryg0MikKKyAgICBNT1ZfRlJPTV9SRUcoNDMpCisgICAgTU9WX0ZST01fUkVHKDQ0KQorICAgIE1P
Vl9GUk9NX1JFRyg0NSkKKyAgICBNT1ZfRlJPTV9SRUcoNDYpCisgICAgTU9WX0ZST01fUkVHKDQ3
KQorICAgIE1PVl9GUk9NX1JFRyg0OCkKKyAgICBNT1ZfRlJPTV9SRUcoNDkpCisgICAgTU9WX0ZS
T01fUkVHKDUwKQorICAgIE1PVl9GUk9NX1JFRyg1MSkKKyAgICBNT1ZfRlJPTV9SRUcoNTIpCisg
ICAgTU9WX0ZST01fUkVHKDUzKQorICAgIE1PVl9GUk9NX1JFRyg1NCkKKyAgICBNT1ZfRlJPTV9S
RUcoNTUpCisgICAgTU9WX0ZST01fUkVHKDU2KQorICAgIE1PVl9GUk9NX1JFRyg1NykKKyAgICBN
T1ZfRlJPTV9SRUcoNTgpCisgICAgTU9WX0ZST01fUkVHKDU5KQorICAgIE1PVl9GUk9NX1JFRyg2
MCkKKyAgICBNT1ZfRlJPTV9SRUcoNjEpCisgICAgTU9WX0ZST01fUkVHKDYyKQorICAgIE1PVl9G
Uk9NX1JFRyg2MykKKyAgICBNT1ZfRlJPTV9SRUcoNjQpCisgICAgTU9WX0ZST01fUkVHKDY1KQor
ICAgIE1PVl9GUk9NX1JFRyg2NikKKyAgICBNT1ZfRlJPTV9SRUcoNjcpCisgICAgTU9WX0ZST01f
UkVHKDY4KQorICAgIE1PVl9GUk9NX1JFRyg2OSkKKyAgICBNT1ZfRlJPTV9SRUcoNzApCisgICAg
TU9WX0ZST01fUkVHKDcxKQorICAgIE1PVl9GUk9NX1JFRyg3MikKKyAgICBNT1ZfRlJPTV9SRUco
NzMpCisgICAgTU9WX0ZST01fUkVHKDc0KQorICAgIE1PVl9GUk9NX1JFRyg3NSkKKyAgICBNT1Zf
RlJPTV9SRUcoNzYpCisgICAgTU9WX0ZST01fUkVHKDc3KQorICAgIE1PVl9GUk9NX1JFRyg3OCkK
KyAgICBNT1ZfRlJPTV9SRUcoNzkpCisgICAgTU9WX0ZST01fUkVHKDgwKQorICAgIE1PVl9GUk9N
X1JFRyg4MSkKKyAgICBNT1ZfRlJPTV9SRUcoODIpCisgICAgTU9WX0ZST01fUkVHKDgzKQorICAg
IE1PVl9GUk9NX1JFRyg4NCkKKyAgICBNT1ZfRlJPTV9SRUcoODUpCisgICAgTU9WX0ZST01fUkVH
KDg2KQorICAgIE1PVl9GUk9NX1JFRyg4NykKKyAgICBNT1ZfRlJPTV9SRUcoODgpCisgICAgTU9W
X0ZST01fUkVHKDg5KQorICAgIE1PVl9GUk9NX1JFRyg5MCkKKyAgICBNT1ZfRlJPTV9SRUcoOTEp
CisgICAgTU9WX0ZST01fUkVHKDkyKQorICAgIE1PVl9GUk9NX1JFRyg5MykKKyAgICBNT1ZfRlJP
TV9SRUcoOTQpCisgICAgTU9WX0ZST01fUkVHKDk1KQorICAgIE1PVl9GUk9NX1JFRyg5NikKKyAg
ICBNT1ZfRlJPTV9SRUcoOTcpCisgICAgTU9WX0ZST01fUkVHKDk4KQorICAgIE1PVl9GUk9NX1JF
Ryg5OSkKKyAgICBNT1ZfRlJPTV9SRUcoMTAwKQorICAgIE1PVl9GUk9NX1JFRygxMDEpCisgICAg
TU9WX0ZST01fUkVHKDEwMikKKyAgICBNT1ZfRlJPTV9SRUcoMTAzKQorICAgIE1PVl9GUk9NX1JF
RygxMDQpCisgICAgTU9WX0ZST01fUkVHKDEwNSkKKyAgICBNT1ZfRlJPTV9SRUcoMTA2KQorICAg
IE1PVl9GUk9NX1JFRygxMDcpCisgICAgTU9WX0ZST01fUkVHKDEwOCkKKyAgICBNT1ZfRlJPTV9S
RUcoMTA5KQorICAgIE1PVl9GUk9NX1JFRygxMTApCisgICAgTU9WX0ZST01fUkVHKDExMSkKKyAg
ICBNT1ZfRlJPTV9SRUcoMTEyKQorICAgIE1PVl9GUk9NX1JFRygxMTMpCisgICAgTU9WX0ZST01f
UkVHKDExNCkKKyAgICBNT1ZfRlJPTV9SRUcoMTE1KQorICAgIE1PVl9GUk9NX1JFRygxMTYpCisg
ICAgTU9WX0ZST01fUkVHKDExNykKKyAgICBNT1ZfRlJPTV9SRUcoMTE4KQorICAgIE1PVl9GUk9N
X1JFRygxMTkpCisgICAgTU9WX0ZST01fUkVHKDEyMCkKKyAgICBNT1ZfRlJPTV9SRUcoMTIxKQor
ICAgIE1PVl9GUk9NX1JFRygxMjIpCisgICAgTU9WX0ZST01fUkVHKDEyMykKKyAgICBNT1ZfRlJP
TV9SRUcoMTI0KQorICAgIE1PVl9GUk9NX1JFRygxMjUpCisgICAgTU9WX0ZST01fUkVHKDEyNikK
KyAgICBNT1ZfRlJPTV9SRUcoMTI3KQorRU5EKGFzbV9tb3ZfZnJvbV9yZWcpCisKKworLyogbXVz
dCBiZSBpbiBiYW5rIDAKKyAqIHBhcmFtZXRlcjoKKyAqIHIzMTogcHIKKyAqIHIyNDogYjAKKyAq
LworRU5UUlkoa3ZtX3Jlc3VtZV90b19ndWVzdCkKKyAgICBhZGRzIHIxNiA9IFZNTV9WQ1BVX1NB
VkVEX0dQX09GRlNFVCxyMjEKKyAgICA7OworICAgIGxkOCByMSA9W3IxNl0KKyAgICBhZGRzIHIy
MCA9IFZNTV9WQ1BVX1ZTQV9CQVNFX09GRlNFVCxyMjEKKyAgICA7OworICAgIG1vdiByMTY9Y3Iu
aXBzcgorICAgIDs7CisgICAgbGQ4IHIyMCA9IFtyMjBdCisgICAgYWRkcyByMTk9Vk1NX1ZQRF9C
QVNFX09GRlNFVCxyMjEKKyAgICA7OworICAgIGxkOCByMjU9W3IxOV0KKyAgICBleHRyLnUgcjE3
PXIxNixJQTY0X1BTUl9SSV9CSVQsMgorICAgIHRiaXQubnogcDYscDc9cjE2LElBNjRfUFNSX1JJ
X0JJVCsxCisgICAgOzsKKyAgICAocDYpIG1vdiByMTg9Y3IuaWlwCisgICAgKHA2KSBtb3YgcjE3
PXIwCisgICAgOzsKKyAgICAocDYpIGFkZCByMTg9MHgxMCxyMTgKKyAgICAocDcpIGFkZCByMTc9
MSxyMTcKKyAgICA7OworICAgIChwNikgbW92IGNyLmlpcD1yMTgKKyAgICBkZXAgcjE2PXIxNyxy
MTYsSUE2NF9QU1JfUklfQklULDIKKyAgICA7OworICAgIG1vdiBjci5pcHNyPXIxNgorICAgIGFk
ZHMgcjE5PSBWUERfVlBTUl9TVEFSVF9PRkZTRVQscjI1CisgICAgYWRkIHIyOD1QQUxfVlBTX1JF
U1VNRV9OT1JNQUwscjIwCisgICAgYWRkIHIyOT1QQUxfVlBTX1JFU1VNRV9IQU5ETEVSLHIyMAor
ICAgIDs7CisgICAgbGQ4IHIxOT1bcjE5XQorICAgIG1vdiBiMD1yMjkKKyAgICBjbXAubmUgcDYs
cDcgPSByMCxyMAorICAgIDs7CisgICAgdGJpdC56IHA2LHA3ID0gcjE5LElBNjRfUFNSX0lDX0JJ
VAkJLy8gcDE9dnBzci5pYworICAgIDs7CisgICAgKHA2KSBsZDggcjI2PVtyMjVdCisgICAgKHA3
KSBtb3YgYjA9cjI4CisgICAgbW92IHByPXIzMSwtMgorICAgIGJyLnNwdGsubWFueSBiMCAgICAg
ICAgICAgICAvLyBjYWxsIHBhbCBzZXJ2aWNlCisgICAgOzsKK0VORChrdm1fcmVzdW1lX3RvX2d1
ZXN0KQorCisKK01PVl9UT19CQU5LMF9SRUcoMTYpCitNT1ZfVE9fQkFOSzBfUkVHKDE3KQorTU9W
X1RPX0JBTkswX1JFRygxOCkKK01PVl9UT19CQU5LMF9SRUcoMTkpCitNT1ZfVE9fQkFOSzBfUkVH
KDIwKQorTU9WX1RPX0JBTkswX1JFRygyMSkKK01PVl9UT19CQU5LMF9SRUcoMjIpCitNT1ZfVE9f
QkFOSzBfUkVHKDIzKQorTU9WX1RPX0JBTkswX1JFRygyNCkKK01PVl9UT19CQU5LMF9SRUcoMjUp
CitNT1ZfVE9fQkFOSzBfUkVHKDI2KQorTU9WX1RPX0JBTkswX1JFRygyNykKK01PVl9UT19CQU5L
MF9SRUcoMjgpCitNT1ZfVE9fQkFOSzBfUkVHKDI5KQorTU9WX1RPX0JBTkswX1JFRygzMCkKK01P
Vl9UT19CQU5LMF9SRUcoMzEpCisKKworLy8gbW92IHRvIHJlZyB0YWJsZQorRU5UUlkoYXNtX21v
dl90b19yZWcpCisgICAgTU9WX1RPX1JFRzAKKyAgICBNT1ZfVE9fUkVHKDEpCisgICAgTU9WX1RP
X1JFRygyKQorICAgIE1PVl9UT19SRUcoMykKKyAgICBNT1ZfVE9fUkVHKDQpCisgICAgTU9WX1RP
X1JFRyg1KQorICAgIE1PVl9UT19SRUcoNikKKyAgICBNT1ZfVE9fUkVHKDcpCisgICAgTU9WX1RP
X1JFRyg4KQorICAgIE1PVl9UT19SRUcoOSkKKyAgICBNT1ZfVE9fUkVHKDEwKQorICAgIE1PVl9U
T19SRUcoMTEpCisgICAgTU9WX1RPX1JFRygxMikKKyAgICBNT1ZfVE9fUkVHKDEzKQorICAgIE1P
Vl9UT19SRUcoMTQpCisgICAgTU9WX1RPX1JFRygxNSkKKyAgICBKTVBfVE9fTU9WX1RPX0JBTksw
X1JFRygxNikKKyAgICBKTVBfVE9fTU9WX1RPX0JBTkswX1JFRygxNykKKyAgICBKTVBfVE9fTU9W
X1RPX0JBTkswX1JFRygxOCkKKyAgICBKTVBfVE9fTU9WX1RPX0JBTkswX1JFRygxOSkKKyAgICBK
TVBfVE9fTU9WX1RPX0JBTkswX1JFRygyMCkKKyAgICBKTVBfVE9fTU9WX1RPX0JBTkswX1JFRygy
MSkKKyAgICBKTVBfVE9fTU9WX1RPX0JBTkswX1JFRygyMikKKyAgICBKTVBfVE9fTU9WX1RPX0JB
TkswX1JFRygyMykKKyAgICBKTVBfVE9fTU9WX1RPX0JBTkswX1JFRygyNCkKKyAgICBKTVBfVE9f
TU9WX1RPX0JBTkswX1JFRygyNSkKKyAgICBKTVBfVE9fTU9WX1RPX0JBTkswX1JFRygyNikKKyAg
ICBKTVBfVE9fTU9WX1RPX0JBTkswX1JFRygyNykKKyAgICBKTVBfVE9fTU9WX1RPX0JBTkswX1JF
RygyOCkKKyAgICBKTVBfVE9fTU9WX1RPX0JBTkswX1JFRygyOSkKKyAgICBKTVBfVE9fTU9WX1RP
X0JBTkswX1JFRygzMCkKKyAgICBKTVBfVE9fTU9WX1RPX0JBTkswX1JFRygzMSkKKyAgICBNT1Zf
VE9fUkVHKDMyKQorICAgIE1PVl9UT19SRUcoMzMpCisgICAgTU9WX1RPX1JFRygzNCkKKyAgICBN
T1ZfVE9fUkVHKDM1KQorICAgIE1PVl9UT19SRUcoMzYpCisgICAgTU9WX1RPX1JFRygzNykKKyAg
ICBNT1ZfVE9fUkVHKDM4KQorICAgIE1PVl9UT19SRUcoMzkpCisgICAgTU9WX1RPX1JFRyg0MCkK
KyAgICBNT1ZfVE9fUkVHKDQxKQorICAgIE1PVl9UT19SRUcoNDIpCisgICAgTU9WX1RPX1JFRyg0
MykKKyAgICBNT1ZfVE9fUkVHKDQ0KQorICAgIE1PVl9UT19SRUcoNDUpCisgICAgTU9WX1RPX1JF
Ryg0NikKKyAgICBNT1ZfVE9fUkVHKDQ3KQorICAgIE1PVl9UT19SRUcoNDgpCisgICAgTU9WX1RP
X1JFRyg0OSkKKyAgICBNT1ZfVE9fUkVHKDUwKQorICAgIE1PVl9UT19SRUcoNTEpCisgICAgTU9W
X1RPX1JFRyg1MikKKyAgICBNT1ZfVE9fUkVHKDUzKQorICAgIE1PVl9UT19SRUcoNTQpCisgICAg
TU9WX1RPX1JFRyg1NSkKKyAgICBNT1ZfVE9fUkVHKDU2KQorICAgIE1PVl9UT19SRUcoNTcpCisg
ICAgTU9WX1RPX1JFRyg1OCkKKyAgICBNT1ZfVE9fUkVHKDU5KQorICAgIE1PVl9UT19SRUcoNjAp
CisgICAgTU9WX1RPX1JFRyg2MSkKKyAgICBNT1ZfVE9fUkVHKDYyKQorICAgIE1PVl9UT19SRUco
NjMpCisgICAgTU9WX1RPX1JFRyg2NCkKKyAgICBNT1ZfVE9fUkVHKDY1KQorICAgIE1PVl9UT19S
RUcoNjYpCisgICAgTU9WX1RPX1JFRyg2NykKKyAgICBNT1ZfVE9fUkVHKDY4KQorICAgIE1PVl9U
T19SRUcoNjkpCisgICAgTU9WX1RPX1JFRyg3MCkKKyAgICBNT1ZfVE9fUkVHKDcxKQorICAgIE1P
Vl9UT19SRUcoNzIpCisgICAgTU9WX1RPX1JFRyg3MykKKyAgICBNT1ZfVE9fUkVHKDc0KQorICAg
IE1PVl9UT19SRUcoNzUpCisgICAgTU9WX1RPX1JFRyg3NikKKyAgICBNT1ZfVE9fUkVHKDc3KQor
ICAgIE1PVl9UT19SRUcoNzgpCisgICAgTU9WX1RPX1JFRyg3OSkKKyAgICBNT1ZfVE9fUkVHKDgw
KQorICAgIE1PVl9UT19SRUcoODEpCisgICAgTU9WX1RPX1JFRyg4MikKKyAgICBNT1ZfVE9fUkVH
KDgzKQorICAgIE1PVl9UT19SRUcoODQpCisgICAgTU9WX1RPX1JFRyg4NSkKKyAgICBNT1ZfVE9f
UkVHKDg2KQorICAgIE1PVl9UT19SRUcoODcpCisgICAgTU9WX1RPX1JFRyg4OCkKKyAgICBNT1Zf
VE9fUkVHKDg5KQorICAgIE1PVl9UT19SRUcoOTApCisgICAgTU9WX1RPX1JFRyg5MSkKKyAgICBN
T1ZfVE9fUkVHKDkyKQorICAgIE1PVl9UT19SRUcoOTMpCisgICAgTU9WX1RPX1JFRyg5NCkKKyAg
ICBNT1ZfVE9fUkVHKDk1KQorICAgIE1PVl9UT19SRUcoOTYpCisgICAgTU9WX1RPX1JFRyg5NykK
KyAgICBNT1ZfVE9fUkVHKDk4KQorICAgIE1PVl9UT19SRUcoOTkpCisgICAgTU9WX1RPX1JFRygx
MDApCisgICAgTU9WX1RPX1JFRygxMDEpCisgICAgTU9WX1RPX1JFRygxMDIpCisgICAgTU9WX1RP
X1JFRygxMDMpCisgICAgTU9WX1RPX1JFRygxMDQpCisgICAgTU9WX1RPX1JFRygxMDUpCisgICAg
TU9WX1RPX1JFRygxMDYpCisgICAgTU9WX1RPX1JFRygxMDcpCisgICAgTU9WX1RPX1JFRygxMDgp
CisgICAgTU9WX1RPX1JFRygxMDkpCisgICAgTU9WX1RPX1JFRygxMTApCisgICAgTU9WX1RPX1JF
RygxMTEpCisgICAgTU9WX1RPX1JFRygxMTIpCisgICAgTU9WX1RPX1JFRygxMTMpCisgICAgTU9W
X1RPX1JFRygxMTQpCisgICAgTU9WX1RPX1JFRygxMTUpCisgICAgTU9WX1RPX1JFRygxMTYpCisg
ICAgTU9WX1RPX1JFRygxMTcpCisgICAgTU9WX1RPX1JFRygxMTgpCisgICAgTU9WX1RPX1JFRygx
MTkpCisgICAgTU9WX1RPX1JFRygxMjApCisgICAgTU9WX1RPX1JFRygxMjEpCisgICAgTU9WX1RP
X1JFRygxMjIpCisgICAgTU9WX1RPX1JFRygxMjMpCisgICAgTU9WX1RPX1JFRygxMjQpCisgICAg
TU9WX1RPX1JFRygxMjUpCisgICAgTU9WX1RPX1JFRygxMjYpCisgICAgTU9WX1RPX1JFRygxMjcp
CitFTkQoYXNtX21vdl90b19yZWcpCi0tIAoxLjUuMgoK

------_=_NextPart_001_01C893E6.2FFF0333--
