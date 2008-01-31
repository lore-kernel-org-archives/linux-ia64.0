From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Thu, 31 Jan 2008 10:30:12 +0000
Subject: [PATCH][15]add optimization for some virtulization faults
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDCD31FD2@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C863F4.4345B04B"
List-Id: <linux-ia64.vger.kernel.org>
To: Avi Kivity <avi@qumranet.com>, "Luck, Tony" <tony.luck@intel.com>, "Xu, Anthony" <anthony.xu@intel.com>, "Zhang, Xiantao" <xiantao.zhang@intel.com>
Cc: kvm-devel@lists.sourceforge.net, kvm-ia64-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C863F4.4345B04B
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

From: Zhang Xiantao <xiantao.zhang@intel.com>
Date: Tue, 29 Jan 2008 14:35:44 +0800
Subject: [PATCH] kvm/ia64: add optimization for some virtulization
faults

optvfault.S adds optimization for some performance-critical
virtualization
faults.
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
1.5.1

------_=_NextPart_001_01C863F4.4345B04B
Content-Type: application/octet-stream;
	name="0015-kvm-ia64-add-optimization-for-some-virtulization-fa.patch"
Content-Transfer-Encoding: base64
Content-Description: 0015-kvm-ia64-add-optimization-for-some-virtulization-fa.patch
Content-Disposition: attachment;
	filename="0015-kvm-ia64-add-optimization-for-some-virtulization-fa.patch"

RnJvbSBkMTBjZDVkMTdhNjc2NmY4YzMzZTEwNTI5OWRkNmQ1MTljMDg4YjA3IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBaaGFuZyBYaWFudGFvIDx4aWFudGFvLnpoYW5nQGludGVsLmNv
bT4KRGF0ZTogVHVlLCAyOSBKYW4gMjAwOCAxNDozNTo0NCArMDgwMApTdWJqZWN0OiBbUEFUQ0hd
IGt2bS9pYTY0OiBhZGQgb3B0aW1pemF0aW9uIGZvciBzb21lIHZpcnR1bGl6YXRpb24gZmF1bHRz
CgpvcHR2ZmF1bHQuUyBhZGRzIG9wdGltaXphdGlvbiBmb3Igc29tZSBwZXJmb3JtYW5jZS1jcml0
aWNhbCB2aXJ0dWFsaXphdGlvbgpmYXVsdHMuClNpZ25lZC1vZmYtYnk6IEFudGhvbnkgWHUgPGFu
dGhvbnkueHVAaW50ZWwuY29tPgpTaWduZWQtb2ZmLWJ5OiBYaWFudGFvIFpoYW5nIDx4aWFudGFv
LnpoYW5nQGludGVsLmNvbT4KLS0tCiBhcmNoL2lhNjQva3ZtL29wdHZmYXVsdC5TIHwgIDkxOCAr
KysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysKIDEgZmlsZXMgY2hh
bmdlZCwgOTE4IGluc2VydGlvbnMoKyksIDAgZGVsZXRpb25zKC0pCiBjcmVhdGUgbW9kZSAxMDA2
NDQgYXJjaC9pYTY0L2t2bS9vcHR2ZmF1bHQuUwoKZGlmZiAtLWdpdCBhL2FyY2gvaWE2NC9rdm0v
b3B0dmZhdWx0LlMgYi9hcmNoL2lhNjQva3ZtL29wdHZmYXVsdC5TCm5ldyBmaWxlIG1vZGUgMTAw
NjQ0CmluZGV4IDAwMDAwMDAuLjVkZTIxMGUKLS0tIC9kZXYvbnVsbAorKysgYi9hcmNoL2lhNjQv
a3ZtL29wdHZmYXVsdC5TCkBAIC0wLDAgKzEsOTE4IEBACisvKgorICogYXJjaC9pYTY0L3ZteC9v
cHR2ZmF1bHQuUworICogb3B0aW1pemUgdmlydHVhbGl6YXRpb24gZmF1bHQgaGFuZGxlcgorICoK
KyAqIENvcHlyaWdodCAoQykgMjAwNiBJbnRlbCBDbworICoJWHVlZmVpIFh1IChBbnRob255IFh1
KSA8YW50aG9ueS54dUBpbnRlbC5jb20+CisgKi8KKworI2luY2x1ZGUgPGFzbS9hc21tYWNyby5o
PgorI2luY2x1ZGUgPGFzbS9wcm9jZXNzb3IuaD4KKworI2luY2x1ZGUgInZ0aS5oIgorI2luY2x1
ZGUgImFzbS1vZmZzZXRzLmgiCisKKyNkZWZpbmUgQUNDRV9NT1ZfRlJPTV9BUgorI2RlZmluZSBB
Q0NFX01PVl9GUk9NX1JSCisjZGVmaW5lIEFDQ0VfTU9WX1RPX1JSCisjZGVmaW5lIEFDQ0VfUlNN
CisjZGVmaW5lIEFDQ0VfU1NNCisjZGVmaW5lIEFDQ0VfTU9WX1RPX1BTUgorI2RlZmluZSBBQ0NF
X1RIQVNICisKKy8vbW92IHIxPWFyMworR0xPQkFMX0VOVFJZKGt2bV9hc21fbW92X2Zyb21fYXIp
CisjaWZuZGVmIEFDQ0VfTU9WX0ZST01fQVIKKyAgICBici5tYW55IGt2bV92aXJ0dWFsaXphdGlv
bl9mYXVsdF9iYWNrCisjZW5kaWYKKyAgICBhZGQgcjE4PVZNTV9WQ1BVX0lUQ19PRlNfT0ZGU0VU
LCByMjEKKyAgICBhZGQgcjE2PVZNTV9WQ1BVX0xBU1RfSVRDX09GRlNFVCxyMjEKKyAgICBleHRy
LnUgcjE3PXIyNSw2LDcKKyAgICA7OworICAgIGxkOCByMTg9W3IxOF0KKyAgICBtb3YgcjE5PWFy
Lml0YworICAgIG1vdiByMjQ9YjAKKyAgICA7OworICAgIGFkZCByMTk9cjE5LHIxOAorICAgIGFk
ZGwgcjIwPUBncHJlbChhc21fbW92X3RvX3JlZyksZ3AKKyAgICA7OworICAgIHN0OCBbcjE2XSA9
IHIxOQorICAgIGFkZHMgcjMwPWt2bV9yZXN1bWVfdG9fZ3Vlc3QtYXNtX21vdl90b19yZWcscjIw
CisgICAgc2hsYWRkIHIxNz1yMTcsNCxyMjAKKyAgICA7OworICAgIG1vdiBiMD1yMTcKKyAgICBi
ci5zcHRrLmZldyBiMAorICAgIDs7CitFTkQoa3ZtX2FzbV9tb3ZfZnJvbV9hcikKKworCisvLyBt
b3YgcjE9cnJbcjNdCitHTE9CQUxfRU5UUlkoa3ZtX2FzbV9tb3ZfZnJvbV9ycikKKyNpZm5kZWYg
QUNDRV9NT1ZfRlJPTV9SUgorICAgIGJyLm1hbnkga3ZtX3ZpcnR1YWxpemF0aW9uX2ZhdWx0X2Jh
Y2sKKyNlbmRpZgorICAgIGV4dHIudSByMTY9cjI1LDIwLDcKKyAgICBleHRyLnUgcjE3PXIyNSw2
LDcKKyAgICBhZGRsIHIyMD1AZ3ByZWwoYXNtX21vdl9mcm9tX3JlZyksZ3AKKyAgICA7OworICAg
IGFkZHMgcjMwPWt2bV9hc21fbW92X2Zyb21fcnJfYmFja18xLWFzbV9tb3ZfZnJvbV9yZWcscjIw
CisgICAgc2hsYWRkIHIxNj1yMTYsNCxyMjAKKyAgICBtb3YgcjI0PWIwCisgICAgOzsKKyAgICBh
ZGQgcjI3PVZNTV9WQ1BVX1ZSUjBfT0ZGU0VULHIyMQorICAgIG1vdiBiMD1yMTYKKyAgICBici5t
YW55IGIwCisgICAgOzsKK2t2bV9hc21fbW92X2Zyb21fcnJfYmFja18xOgorICAgIGFkZHMgcjMw
PWt2bV9yZXN1bWVfdG9fZ3Vlc3QtYXNtX21vdl9mcm9tX3JlZyxyMjAKKyAgICBhZGRzIHIyMj1h
c21fbW92X3RvX3JlZy1hc21fbW92X2Zyb21fcmVnLHIyMAorICAgIHNoci51IHIyNj1yMTksNjEK
KyAgICA7OworICAgIHNobGFkZCByMTc9cjE3LDQscjIyCisgICAgc2hsYWRkIHIyNz1yMjYsMyxy
MjcKKyAgICA7OworICAgIGxkOCByMTk9W3IyN10KKyAgICBtb3YgYjA9cjE3CisgICAgYnIubWFu
eSBiMAorRU5EKGt2bV9hc21fbW92X2Zyb21fcnIpCisKKworLy8gbW92IHJyW3IzXT1yMgorR0xP
QkFMX0VOVFJZKGt2bV9hc21fbW92X3RvX3JyKQorI2lmbmRlZiBBQ0NFX01PVl9UT19SUgorICAg
IGJyLm1hbnkga3ZtX3ZpcnR1YWxpemF0aW9uX2ZhdWx0X2JhY2sKKyNlbmRpZgorICAgIGV4dHIu
dSByMTY9cjI1LDIwLDcKKyAgICBleHRyLnUgcjE3PXIyNSwxMyw3CisgICAgYWRkbCByMjA9QGdw
cmVsKGFzbV9tb3ZfZnJvbV9yZWcpLGdwCisgICAgOzsKKyAgICBhZGRzIHIzMD1rdm1fYXNtX21v
dl90b19ycl9iYWNrXzEtYXNtX21vdl9mcm9tX3JlZyxyMjAKKyAgICBzaGxhZGQgcjE2PXIxNiw0
LHIyMAorICAgIG1vdiByMjI9YjAKKyAgICA7OworICAgIGFkZCByMjc9Vk1NX1ZDUFVfVlJSMF9P
RkZTRVQscjIxCisgICAgbW92IGIwPXIxNgorICAgIGJyLm1hbnkgYjAKKyAgICA7Owora3ZtX2Fz
bV9tb3ZfdG9fcnJfYmFja18xOgorICAgIGFkZHMgcjMwPWt2bV9hc21fbW92X3RvX3JyX2JhY2tf
Mi1hc21fbW92X2Zyb21fcmVnLHIyMAorICAgIHNoci51IHIyMz1yMTksNjEKKyAgICBzaGxhZGQg
cjE3PXIxNyw0LHIyMAorICAgIDs7CisgICAgLy9pZiBycjYsIGdvIGJhY2sKKyAgICBjbXAuZXEg
cDYscDA9NixyMjMKKyAgICBtb3YgYjA9cjIyCisgICAgKHA2KSBici5jb25kLmRwbnQubWFueSBr
dm1fdmlydHVhbGl6YXRpb25fZmF1bHRfYmFjaworICAgIDs7CisgICAgbW92IHIyOD1yMTkKKyAg
ICBtb3YgYjA9cjE3CisgICAgYnIubWFueSBiMAora3ZtX2FzbV9tb3ZfdG9fcnJfYmFja18yOgor
ICAgIGFkZHMgcjMwPWt2bV9yZXN1bWVfdG9fZ3Vlc3QtYXNtX21vdl9mcm9tX3JlZyxyMjAKKyAg
ICBzaGxhZGQgcjI3PXIyMywzLHIyNworICAgIDs7IC8vIHZyci5yaWQ8PDQgfDB4ZQorICAgIHN0
OCBbcjI3XT1yMTkKKyAgICBtb3YgYjA9cjMwCisgICAgOzsKKyAgICBleHRyLnUgcjE2PXIxOSw4
LDI2CisgICAgZXh0ci51IHIxOCA9cjE5LDIsNgorICAgIG1vdiByMTcgPTB4ZQorICAgIDs7Cisg
ICAgc2hsYWRkIHIxNiA9IHIxNiwgNCwgcjE3CisgICAgZXh0ci51IHIxOSA9cjE5LDAsOAorICAg
IDs7CisgICAgc2hsIHIxNiA9IHIxNiw4CisgICAgOzsKKyAgICBhZGQgcjE5ID0gcjE5LCByMTYK
KyAgICA7OyAvL3NldCB2ZSAxCisgICAgZGVwIHIxOT0tMSxyMTksMCwxCisgICAgY21wLmx0IHA2
LHAwPTE0LHIxOAorICAgIDs7CisgICAgKHA2KSBtb3YgcjE4PTE0CisgICAgOzsKKyAgICAocDYp
IGRlcCByMTk9cjE4LHIxOSwyLDYKKyAgICA7OworICAgIGNtcC5lcSBwNixwMD0wLHIyMworICAg
IDs7CisgICAgY21wLmVxLm9yIHA2LHAwPTQscjIzCisgICAgOzsKKyAgICBhZGRzIHIxNj1WTU1f
VkNQVV9NT0RFX0ZMQUdTX09GRlNFVCxyMjEKKyAgICAocDYpIGFkZHMgcjE3PVZNTV9WQ1BVX01F
VEFfU0FWRURfUlIwX09GRlNFVCxyMjEKKyAgICA7OworICAgIGxkNCByMTY9W3IxNl0KKyAgICBj
bXAuZXEgcDcscDA9cjAscjAKKyAgICAocDYpIHNobGFkZCByMTc9cjIzLDEscjE3CisgICAgOzsK
KyAgICAocDYpIHN0OCBbcjE3XT1yMTkKKyAgICAocDYpIHRiaXQubnogcDYscDc9cjE2LDAKKyAg
ICA7OworICAgIChwNykgbW92IHJyW3IyOF09cjE5CisgICAgbW92IHIyND1yMjIKKyAgICBici5t
YW55IGIwCitFTkQoa3ZtX2FzbV9tb3ZfdG9fcnIpCisKKworLy9yc20KK0dMT0JBTF9FTlRSWShr
dm1fYXNtX3JzbSkKKyNpZm5kZWYgQUNDRV9SU00KKyAgICBici5tYW55IGt2bV92aXJ0dWFsaXph
dGlvbl9mYXVsdF9iYWNrCisjZW5kaWYKKyAgICBhZGQgcjE2PVZNTV9WUERfQkFTRV9PRkZTRVQs
cjIxCisgICAgZXh0ci51IHIyNj1yMjUsNiwyMQorICAgIGV4dHIudSByMjc9cjI1LDMxLDIKKyAg
ICA7OworICAgIGxkOCByMTY9W3IxNl0KKyAgICBleHRyLnUgcjI4PXIyNSwzNiwxCisgICAgZGVw
IHIyNj1yMjcscjI2LDIxLDIKKyAgICA7OworICAgIGFkZCByMTc9VlBEX1ZQU1JfU1RBUlRfT0ZG
U0VULHIxNgorICAgIGFkZCByMjI9Vk1NX1ZDUFVfTU9ERV9GTEFHU19PRkZTRVQscjIxCisgICAg
Ly9yMjYgaXMgaW1tMjQKKyAgICBkZXAgcjI2PXIyOCxyMjYsMjMsMQorICAgIDs7CisgICAgbGQ4
IHIxOD1bcjE3XQorICAgIG1vdmwgcjI4PUlBNjRfUFNSX0lDK0lBNjRfUFNSX0krSUE2NF9QU1Jf
RFQrSUE2NF9QU1JfU0kKKyAgICBsZDQgcjIzPVtyMjJdCisgICAgc3ViIHIyNz0tMSxyMjYKKyAg
ICBtb3YgcjI0PWIwCisgICAgOzsKKyAgICBtb3YgcjIwPWNyLmlwc3IKKyAgICBvciByMjg9cjI3
LHIyOAorICAgIGFuZCByMTk9cjE4LHIyNworICAgIDs7CisgICAgc3Q4IFtyMTddPXIxOQorICAg
IGFuZCByMjA9cjIwLHIyOAorICAgIC8qIENvbW1lbnQgaXQgb3V0IGR1ZSB0byBzaG9ydCBvZiBm
cCBsYXp5IGFsb3JnaXRobSBzdXBwb3J0CisgICAgYWRkcyByMjc9SUE2NF9WQ1BVX0ZQX1BTUl9P
RkZTRVQscjIxCisgICAgOzsKKyAgICBsZDggcjI3PVtyMjddCisgICAgOzsKKyAgICB0Yml0Lm56
IHA4LHAwPSByMjcsSUE2NF9QU1JfREZIX0JJVAorICAgIDs7CisgICAgKHA4KSBkZXAgcjIwPS0x
LHIyMCxJQTY0X1BTUl9ERkhfQklULDEKKyAgICAqLworICAgIDs7CisgICAgbW92IGNyLmlwc3I9
cjIwCisgICAgdGJpdC5ueiBwNixwMD1yMjMsMAorICAgIDs7CisgICAgdGJpdC56Lm9yIHA2LHAw
PXIyNixJQTY0X1BTUl9EVF9CSVQKKyAgICAocDYpIGJyLmRwdGsga3ZtX3Jlc3VtZV90b19ndWVz
dAorICAgIDs7CisgICAgYWRkIHIyNj1WTU1fVkNQVV9NRVRBX1JSMF9PRkZTRVQscjIxCisgICAg
YWRkIHIyNz1WTU1fVkNQVV9NRVRBX1JSMF9PRkZTRVQrOCxyMjEKKyAgICBkZXAgcjIzPS0xLHIy
MywwLDEKKyAgICA7OworICAgIGxkOCByMjY9W3IyNl0KKyAgICBsZDggcjI3PVtyMjddCisgICAg
c3Q0IFtyMjJdPXIyMworICAgIGRlcC56IHIyOD00LDYxLDMKKyAgICA7OworICAgIG1vdiByclty
MF09cjI2CisgICAgOzsKKyAgICBtb3YgcnJbcjI4XT1yMjcKKyAgICA7OworICAgIHNybHouZAor
ICAgIGJyLm1hbnkga3ZtX3Jlc3VtZV90b19ndWVzdAorRU5EKGt2bV9hc21fcnNtKQorCisKKy8v
c3NtCitHTE9CQUxfRU5UUlkoa3ZtX2FzbV9zc20pCisjaWZuZGVmIEFDQ0VfU1NNCisgICAgYnIu
bWFueSBrdm1fdmlydHVhbGl6YXRpb25fZmF1bHRfYmFjaworI2VuZGlmCisgICAgYWRkIHIxNj1W
TU1fVlBEX0JBU0VfT0ZGU0VULHIyMQorICAgIGV4dHIudSByMjY9cjI1LDYsMjEKKyAgICBleHRy
LnUgcjI3PXIyNSwzMSwyCisgICAgOzsKKyAgICBsZDggcjE2PVtyMTZdCisgICAgZXh0ci51IHIy
OD1yMjUsMzYsMQorICAgIGRlcCByMjY9cjI3LHIyNiwyMSwyCisgICAgOzsgIC8vcjI2IGlzIGlt
bTI0CisgICAgYWRkIHIyNz1WUERfVlBTUl9TVEFSVF9PRkZTRVQscjE2CisgICAgZGVwIHIyNj1y
MjgscjI2LDIzLDEKKyAgICA7OyAgLy9yMTkgdnBzcgorICAgIGxkOCByMjk9W3IyN10KKyAgICBt
b3YgcjI0PWIwCisgICAgOzsKKyAgICBhZGQgcjIyPVZNTV9WQ1BVX01PREVfRkxBR1NfT0ZGU0VU
LHIyMQorICAgIG1vdiByMjA9Y3IuaXBzcgorICAgIG9yIHIxOT1yMjkscjI2CisgICAgOzsKKyAg
ICBsZDQgcjIzPVtyMjJdCisgICAgc3Q4IFtyMjddPXIxOQorICAgIG9yIHIyMD1yMjAscjI2Cisg
ICAgOzsKKyAgICBtb3YgY3IuaXBzcj1yMjAKKyAgICBtb3ZsIHIyOD1JQTY0X1BTUl9EVCtJQTY0
X1BTUl9SVCtJQTY0X1BTUl9JVAorICAgIDs7CisgICAgYW5kIHIxOT1yMjgscjE5CisgICAgdGJp
dC56IHA2LHAwPXIyMywwCisgICAgOzsKKyAgICBjbXAubmUub3IgcDYscDA9cjI4LHIxOQorICAg
IChwNikgYnIuZHB0ayBrdm1fYXNtX3NzbV8xCisgICAgOzsKKyAgICBhZGQgcjI2PVZNTV9WQ1BV
X01FVEFfU0FWRURfUlIwX09GRlNFVCxyMjEKKyAgICBhZGQgcjI3PVZNTV9WQ1BVX01FVEFfU0FW
RURfUlIwX09GRlNFVCs4LHIyMQorICAgIGRlcCByMjM9MCxyMjMsMCwxCisgICAgOzsKKyAgICBs
ZDggcjI2PVtyMjZdCisgICAgbGQ4IHIyNz1bcjI3XQorICAgIHN0NCBbcjIyXT1yMjMKKyAgICBk
ZXAueiByMjg9NCw2MSwzCisgICAgOzsKKyAgICBtb3YgcnJbcjBdPXIyNgorICAgIDs7CisgICAg
bW92IHJyW3IyOF09cjI3CisgICAgOzsKKyAgICBzcmx6LmQKKyAgICA7Owora3ZtX2FzbV9zc21f
MToKKyAgICB0Yml0Lm56IHA2LHAwPXIyOSxJQTY0X1BTUl9JX0JJVAorICAgIDs7CisgICAgdGJp
dC56Lm9yIHA2LHAwPXIxOSxJQTY0X1BTUl9JX0JJVAorICAgIChwNikgYnIuZHB0ayBrdm1fcmVz
dW1lX3RvX2d1ZXN0CisgICAgOzsKKyAgICBhZGQgcjI5PVZQRF9WVFBSX1NUQVJUX09GRlNFVCxy
MTYKKyAgICBhZGQgcjMwPVZQRF9WSFBJX1NUQVJUX09GRlNFVCxyMTYKKyAgICA7OworICAgIGxk
OCByMjk9W3IyOV0KKyAgICBsZDggcjMwPVtyMzBdCisgICAgOzsKKyAgICBleHRyLnUgcjE3PXIy
OSw0LDQKKyAgICBleHRyLnUgcjE4PXIyOSwxNiwxCisgICAgOzsKKyAgICBkZXAgcjE3PXIxOCxy
MTcsNCwxCisgICAgOzsKKyAgICBjbXAuZ3QgcDYscDA9cjMwLHIxNworICAgIChwNikgYnIuZHBu
dC5mZXcga3ZtX2FzbV9kaXNwYXRjaF92ZXhpcnEKKyAgICBici5tYW55IGt2bV9yZXN1bWVfdG9f
Z3Vlc3QKK0VORChrdm1fYXNtX3NzbSkKKworCisvL21vdiBwc3IubD1yMgorR0xPQkFMX0VOVFJZ
KGt2bV9hc21fbW92X3RvX3BzcikKKyNpZm5kZWYgQUNDRV9NT1ZfVE9fUFNSCisgICAgYnIubWFu
eSBrdm1fdmlydHVhbGl6YXRpb25fZmF1bHRfYmFjaworI2VuZGlmCisgICAgYWRkIHIxNj1WTU1f
VlBEX0JBU0VfT0ZGU0VULHIyMQorICAgIGV4dHIudSByMjY9cjI1LDEzLDcgLy9yMgorICAgIDs7
CisgICAgbGQ4IHIxNj1bcjE2XQorICAgIGFkZGwgcjIwPUBncHJlbChhc21fbW92X2Zyb21fcmVn
KSxncAorICAgIDs7CisgICAgYWRkcyByMzA9a3ZtX2FzbV9tb3ZfdG9fcHNyX2JhY2stYXNtX21v
dl9mcm9tX3JlZyxyMjAKKyAgICBzaGxhZGQgcjI2PXIyNiw0LHIyMAorICAgIG1vdiByMjQ9YjAK
KyAgICA7OworICAgIGFkZCByMjc9VlBEX1ZQU1JfU1RBUlRfT0ZGU0VULHIxNgorICAgIG1vdiBi
MD1yMjYKKyAgICBici5tYW55IGIwCisgICAgOzsKK2t2bV9hc21fbW92X3RvX3Bzcl9iYWNrOgor
ICAgIGxkOCByMTc9W3IyN10KKyAgICBhZGQgcjIyPVZNTV9WQ1BVX01PREVfRkxBR1NfT0ZGU0VU
LHIyMQorICAgIGRlcCByMTk9MCxyMTksMzIsMzIKKyAgICA7OworICAgIGxkNCByMjM9W3IyMl0K
KyAgICBkZXAgcjE4PTAscjE3LDAsMzIKKyAgICA7OworICAgIGFkZCByMzA9cjE4LHIxOQorICAg
IG1vdmwgcjI4PUlBNjRfUFNSX0RUK0lBNjRfUFNSX1JUK0lBNjRfUFNSX0lUCisgICAgOzsKKyAg
ICBzdDggW3IyN109cjMwCisgICAgYW5kIHIyNz1yMjgscjMwCisgICAgYW5kIHIyOT1yMjgscjE3
CisgICAgOzsKKyAgICBjbXAuZXEgcDUscDA9cjI5LHIyNworICAgIGNtcC5lcSBwNixwNz1yMjgs
cjI3CisgICAgKHA1KSBici5tYW55IGt2bV9hc21fbW92X3RvX3Bzcl8xCisgICAgOzsKKyAgICAv
L3ZpcnR1YWwgdG8gcGh5c2ljYWwKKyAgICAocDcpIGFkZCByMjY9Vk1NX1ZDUFVfTUVUQV9SUjBf
T0ZGU0VULHIyMQorICAgIChwNykgYWRkIHIyNz1WTU1fVkNQVV9NRVRBX1JSMF9PRkZTRVQrOCxy
MjEKKyAgICAocDcpIGRlcCByMjM9LTEscjIzLDAsMQorICAgIDs7CisgICAgLy9waHlzaWNhbCB0
byB2aXJ0dWFsCisgICAgKHA2KSBhZGQgcjI2PVZNTV9WQ1BVX01FVEFfU0FWRURfUlIwX09GRlNF
VCxyMjEKKyAgICAocDYpIGFkZCByMjc9Vk1NX1ZDUFVfTUVUQV9TQVZFRF9SUjBfT0ZGU0VUKzgs
cjIxCisgICAgKHA2KSBkZXAgcjIzPTAscjIzLDAsMQorICAgIDs7CisgICAgbGQ4IHIyNj1bcjI2
XQorICAgIGxkOCByMjc9W3IyN10KKyAgICBzdDQgW3IyMl09cjIzCisgICAgZGVwLnogcjI4PTQs
NjEsMworICAgIDs7CisgICAgbW92IHJyW3IwXT1yMjYKKyAgICA7OworICAgIG1vdiBycltyMjhd
PXIyNworICAgIDs7CisgICAgc3Jsei5kCisgICAgOzsKK2t2bV9hc21fbW92X3RvX3Bzcl8xOgor
ICAgIG1vdiByMjA9Y3IuaXBzcgorICAgIG1vdmwgcjI4PUlBNjRfUFNSX0lDK0lBNjRfUFNSX0kr
SUE2NF9QU1JfRFQrSUE2NF9QU1JfU0krSUE2NF9QU1JfUlQKKyAgICA7OworICAgIG9yIHIxOT1y
MTkscjI4CisgICAgZGVwIHIyMD0wLHIyMCwwLDMyCisgICAgOzsKKyAgICBhZGQgcjIwPXIxOSxy
MjAKKyAgICBtb3YgYjA9cjI0CisgICAgOzsKKyAgICAvKiBDb21tZW50IGl0IG91dCBkdWUgdG8g
c2hvcnQgb2YgZnAgbGF6eSBhbGdvcml0aG0gc3VwcG9ydAorICAgIGFkZHMgcjI3PUlBNjRfVkNQ
VV9GUF9QU1JfT0ZGU0VULHIyMQorICAgIDs7CisgICAgbGQ4IHIyNz1bcjI3XQorICAgIDs7Cisg
ICAgdGJpdC5ueiBwOCxwMD1yMjcsSUE2NF9QU1JfREZIX0JJVAorICAgIDs7CisgICAgKHA4KSBk
ZXAgcjIwPS0xLHIyMCxJQTY0X1BTUl9ERkhfQklULDEKKyAgICA7OworICAgICovCisgICAgbW92
IGNyLmlwc3I9cjIwCisgICAgY21wLm5lIHA2LHAwPXIwLHIwCisgICAgOzsKKyAgICB0Yml0Lm56
Lm9yIHA2LHAwPXIxNyxJQTY0X1BTUl9JX0JJVAorICAgIHRiaXQuei5vciBwNixwMD1yMzAsSUE2
NF9QU1JfSV9CSVQKKyAgICAocDYpIGJyLmRwbnQuZmV3IGt2bV9yZXN1bWVfdG9fZ3Vlc3QKKyAg
ICA7OworICAgIGFkZCByMjk9VlBEX1ZUUFJfU1RBUlRfT0ZGU0VULHIxNgorICAgIGFkZCByMzA9
VlBEX1ZIUElfU1RBUlRfT0ZGU0VULHIxNgorICAgIDs7CisgICAgbGQ4IHIyOT1bcjI5XQorICAg
IGxkOCByMzA9W3IzMF0KKyAgICA7OworICAgIGV4dHIudSByMTc9cjI5LDQsNAorICAgIGV4dHIu
dSByMTg9cjI5LDE2LDEKKyAgICA7OworICAgIGRlcCByMTc9cjE4LHIxNyw0LDEKKyAgICA7Owor
ICAgIGNtcC5ndCBwNixwMD1yMzAscjE3CisgICAgKHA2KSBici5kcG50LmZldyBrdm1fYXNtX2Rp
c3BhdGNoX3ZleGlycQorICAgIGJyLm1hbnkga3ZtX3Jlc3VtZV90b19ndWVzdAorRU5EKGt2bV9h
c21fbW92X3RvX3BzcikKKworCitFTlRSWShrdm1fYXNtX2Rpc3BhdGNoX3ZleGlycSkKKy8vaW5j
cmVtZW50IGlpcAorICAgIG1vdiByMTY9Y3IuaXBzcgorICAgIDs7CisgICAgZXh0ci51IHIxNz1y
MTYsSUE2NF9QU1JfUklfQklULDIKKyAgICB0Yml0Lm56IHA2LHA3PXIxNixJQTY0X1BTUl9SSV9C
SVQrMQorICAgIDs7CisgICAgKHA2KSBtb3YgcjE4PWNyLmlpcAorICAgIChwNikgbW92IHIxNz1y
MAorICAgIChwNykgYWRkIHIxNz0xLHIxNworICAgIDs7CisgICAgKHA2KSBhZGQgcjE4PTB4MTAs
cjE4CisgICAgZGVwIHIxNj1yMTcscjE2LElBNjRfUFNSX1JJX0JJVCwyCisgICAgOzsKKyAgICAo
cDYpIG1vdiBjci5paXA9cjE4CisgICAgbW92IGNyLmlwc3I9cjE2CisgICAgbW92IHIzMCA9MQor
ICAgIGJyLm1hbnkga3ZtX2Rpc3BhdGNoX3ZleGlycQorRU5EKGt2bV9hc21fZGlzcGF0Y2hfdmV4
aXJxKQorCisvLyB0aGFzaAorLy8gVE9ETzogYWRkIHN1cHBvcnQgd2hlbiBwdGEudmYgPSAxCitH
TE9CQUxfRU5UUlkoa3ZtX2FzbV90aGFzaCkKKyNpZm5kZWYgQUNDRV9USEFTSAorICAgIGJyLm1h
bnkga3ZtX3ZpcnR1YWxpemF0aW9uX2ZhdWx0X2JhY2sKKyNlbmRpZgorICAgIGV4dHIudSByMTc9
cjI1LDIwLDcJCS8vIGdldCByMyBmcm9tIG9wY29kZSBpbiByMjUKKyAgICBleHRyLnUgcjE4PXIy
NSw2LDcJCS8vIGdldCByMSBmcm9tIG9wY29kZSBpbiByMjUKKyAgICBhZGRsIHIyMD1AZ3ByZWwo
YXNtX21vdl9mcm9tX3JlZyksZ3AKKyAgICA7OworICAgIGFkZHMgcjMwPWt2bV9hc21fdGhhc2hf
YmFjazEtYXNtX21vdl9mcm9tX3JlZyxyMjAKKyAgICBzaGxhZGQgcjE3PXIxNyw0LHIyMAkvLyBn
ZXQgYWRkciBvZiBNT1ZFX0ZST01fUkVHKHIxNykKKyAgICBhZGRzIHIxNj1WTU1fVlBEX0JBU0Vf
T0ZGU0VULHIyMQkvLyBnZXQgdmNwdS5hcmNoLnByaXZlcmVncworICAgIDs7CisgICAgbW92IHIy
ND1iMAorICAgIDs7CisgICAgbGQ4IHIxNj1bcjE2XQkJLy8gZ2V0IFZQRCBhZGRyCisgICAgbW92
IGIwPXIxNworICAgIGJyLm1hbnkgYjAJCQkvLyByMTkgcmV0dXJuIHZhbHVlCisgICAgOzsKK2t2
bV9hc21fdGhhc2hfYmFjazE6CisgICAgc2hyLnUgcjIzPXIxOSw2MQkJLy8gZ2V0IFJSIG51bWJl
cgorICAgIGFkZHMgcjI1PVZNTV9WQ1BVX1ZSUjBfT0ZGU0VULHIyMQkvLyBnZXQgdmNwdS0+YXJj
aC52cnJbMF0ncyBhZGRyCisgICAgYWRkcyByMTY9Vk1NX1ZQRF9WUFRBX09GRlNFVCxyMTYJLy8g
Z2V0IHZwdGEKKyAgICA7OworICAgIHNobGFkZCByMjc9cjIzLDMscjI1CS8vIGdldCB2Y3B1LT5h
cmNoLnZycltyMjNdJ3MgYWRkcgorICAgIGxkOCByMTc9W3IxNl0JCS8vIGdldCBQVEEKKyAgICBt
b3YgcjI2PTEKKyAgICA7OworICAgIGV4dHIudSByMjk9cjE3LDIsNgkJLy8gZ2V0IHB0YS5zaXpl
CisgICAgbGQ4IHIyNT1bcjI3XQkJLy8gZ2V0IHZjcHUtPmFyY2gudnJyW3IyM10ncyB2YWx1ZQor
ICAgIDs7CisgICAgZXh0ci51IHIyNT1yMjUsMiw2CQkvLyBnZXQgcnIucHMKKyAgICBzaGwgcjIy
PXIyNixyMjkJCS8vIDFVTCA8PCBwdGEuc2l6ZQorICAgIDs7CisgICAgc2hyLnUgcjIzPXIxOSxy
MjUJCS8vIHZhZGRyID4+IHJyLnBzCisgICAgYWRkcyByMjY9MyxyMjkJCS8vIHB0YS5zaXplICsg
MworICAgIHNobCByMjc9cjE3LDMJCS8vIHB0YSA8PCAzCisgICAgOzsKKyAgICBzaGwgcjIzPXIy
MywzCQkvLyAodmFkZHIgPj4gcnIucHMpIDw8IDMKKyAgICBzaHIudSByMjc9cjI3LHIyNgkJLy8g
KHB0YSA8PCAzKSA+PiAocHRhLnNpemUrMykKKyAgICBtb3ZsIHIxNj03PDw2MQorICAgIDs7Cisg
ICAgYWRkcyByMjI9LTEscjIyCQkvLyAoMVVMIDw8IHB0YS5zaXplKSAtIDEKKyAgICBzaGwgcjI3
PXIyNyxyMjkJCS8vICgocHRhPDwzKT4+KHB0YS5zaXplKzMpKTw8cHRhLnNpemUKKyAgICBhbmQg
cjE5PXIxOSxyMTYJCS8vIHZhZGRyICYgVlJOX01BU0sKKyAgICA7OworICAgIGFuZCByMjI9cjIy
LHIyMwkJLy8gdmhwdF9vZmZzZXQKKyAgICBvciByMTk9cjE5LHIyNyAvLyAodmFkciZWUk5fTUFT
SykgfCgoKHB0YTw8Myk+PihwdGEuc2l6ZSArIDMpKTw8cHRhLnNpemUpCisgICAgYWRkcyByMjY9
YXNtX21vdl90b19yZWctYXNtX21vdl9mcm9tX3JlZyxyMjAKKyAgICA7OworICAgIG9yIHIxOT1y
MTkscjIyCQkvLyBjYWxjIHB2YWwKKyAgICBzaGxhZGQgcjE3PXIxOCw0LHIyNgorICAgIGFkZHMg
cjMwPWt2bV9yZXN1bWVfdG9fZ3Vlc3QtYXNtX21vdl9mcm9tX3JlZyxyMjAKKyAgICA7OworICAg
IG1vdiBiMD1yMTcKKyAgICBici5tYW55IGIwCitFTkQoa3ZtX2FzbV90aGFzaCkKKworI2RlZmlu
ZSBNT1ZfVE9fUkVHMAlcCit7OwkJCVwKKyAgICBub3AuYiAweDA7CQlcCisgICAgbm9wLmIgMHgw
OwkJXAorICAgIG5vcC5iIDB4MDsJCVwKKyAgICA7OwkJCVwKK307CisKKworI2RlZmluZSBNT1Zf
VE9fUkVHKG4pCVwKK3s7CQkJXAorICAgIG1vdiByIyNuIyM9cjE5OwlcCisgICAgbW92IGIwPXIz
MDsJXAorICAgIGJyLnNwdGsubWFueSBiMDsJXAorICAgIDs7CQkJXAorfTsKKworCisjZGVmaW5l
IE1PVl9GUk9NX1JFRyhuKQlcCit7OwkJCQlcCisgICAgbW92IHIxOT1yIyNuIyM7CQlcCisgICAg
bW92IGIwPXIzMDsJCVwKKyAgICBici5zcHRrLm1hbnkgYjA7CQlcCisgICAgOzsJCQkJXAorfTsK
KworCisjZGVmaW5lIE1PVl9UT19CQU5LMF9SRUcobikJCQlcCitFTlRSWV9NSU5fQUxJR04oYXNt
X21vdl90b19iYW5rMF9yZWcjI24jIyk7CVwKK3s7CQkJCQkJXAorICAgIG1vdiByMjY9cjI7CQkJ
CVwKKyAgICBtb3YgcjI9cjE5OwkJCQlcCisgICAgYnN3LjE7CQkJCQlcCisgICAgOzsJCQkJCQlc
Cit9OwkJCQkJCVwKK3s7CQkJCQkJXAorICAgIG1vdiByIyNuIyM9cjI7CQkJCVwKKyAgICBub3Au
YiAweDA7CQkJCQlcCisgICAgYnN3LjA7CQkJCQlcCisgICAgOzsJCQkJCQlcCit9OwkJCQkJCVwK
K3s7CQkJCQkJXAorICAgIG1vdiByMj1yMjY7CQkJCVwKKyAgICBtb3YgYjA9cjMwOwkJCQlcCisg
ICAgYnIuc3B0ay5tYW55IGIwOwkJCQlcCisgICAgOzsJCQkJCQlcCit9OwkJCQkJCVwKK0VORChh
c21fbW92X3RvX2JhbmswX3JlZyMjbiMjKQorCisKKyNkZWZpbmUgTU9WX0ZST01fQkFOSzBfUkVH
KG4pCQkJXAorRU5UUllfTUlOX0FMSUdOKGFzbV9tb3ZfZnJvbV9iYW5rMF9yZWcjI24jIyk7CVwK
K3s7CQkJCQkJXAorICAgIG1vdiByMjY9cjI7CQkJCVwKKyAgICBub3AuYiAweDA7CQkJCQlcCisg
ICAgYnN3LjE7CQkJCQlcCisgICAgOzsJCQkJCQlcCit9OwkJCQkJCVwKK3s7CQkJCQkJXAorICAg
IG1vdiByMj1yIyNuIyM7CQkJCVwKKyAgICBub3AuYiAweDA7CQkJCQlcCisgICAgYnN3LjA7CQkJ
CQlcCisgICAgOzsJCQkJCQlcCit9OwkJCQkJCVwKK3s7CQkJCQkJXAorICAgIG1vdiByMTk9cjI7
CQkJCVwKKyAgICBtb3YgcjI9cjI2OwkJCQlcCisgICAgbW92IGIwPXIzMDsJCQkJXAorfTsJCQkJ
CQlcCit7OwkJCQkJCVwKKyAgICBub3AuYiAweDA7CQkJCQlcCisgICAgbm9wLmIgMHgwOwkJCQkJ
XAorICAgIGJyLnNwdGsubWFueSBiMDsJCQkJXAorICAgIDs7CQkJCQkJXAorfTsJCQkJCQlcCitF
TkQoYXNtX21vdl9mcm9tX2JhbmswX3JlZyMjbiMjKQorCisKKyNkZWZpbmUgSk1QX1RPX01PVl9U
T19CQU5LMF9SRUcobikJCVwKK3s7CQkJCQkJXAorICAgIG5vcC5iIDB4MDsJCQkJCVwKKyAgICBu
b3AuYiAweDA7CQkJCQlcCisgICAgYnIuc3B0ay5tYW55IGFzbV9tb3ZfdG9fYmFuazBfcmVnIyNu
IyM7CVwKKyAgICA7OwkJCQkJCVwKK30KKworCisjZGVmaW5lIEpNUF9UT19NT1ZfRlJPTV9CQU5L
MF9SRUcobikJCVwKK3s7CQkJCQkJXAorICAgIG5vcC5iIDB4MDsJCQkJCVwKKyAgICBub3AuYiAw
eDA7CQkJCQlcCisgICAgYnIuc3B0ay5tYW55IGFzbV9tb3ZfZnJvbV9iYW5rMF9yZWcjI24jIzsJ
XAorICAgIDs7CQkJCQkJXAorfQorCisKK01PVl9GUk9NX0JBTkswX1JFRygxNikKK01PVl9GUk9N
X0JBTkswX1JFRygxNykKK01PVl9GUk9NX0JBTkswX1JFRygxOCkKK01PVl9GUk9NX0JBTkswX1JF
RygxOSkKK01PVl9GUk9NX0JBTkswX1JFRygyMCkKK01PVl9GUk9NX0JBTkswX1JFRygyMSkKK01P
Vl9GUk9NX0JBTkswX1JFRygyMikKK01PVl9GUk9NX0JBTkswX1JFRygyMykKK01PVl9GUk9NX0JB
TkswX1JFRygyNCkKK01PVl9GUk9NX0JBTkswX1JFRygyNSkKK01PVl9GUk9NX0JBTkswX1JFRygy
NikKK01PVl9GUk9NX0JBTkswX1JFRygyNykKK01PVl9GUk9NX0JBTkswX1JFRygyOCkKK01PVl9G
Uk9NX0JBTkswX1JFRygyOSkKK01PVl9GUk9NX0JBTkswX1JFRygzMCkKK01PVl9GUk9NX0JBTksw
X1JFRygzMSkKKworCisvLyBtb3YgZnJvbSByZWcgdGFibGUKK0VOVFJZKGFzbV9tb3ZfZnJvbV9y
ZWcpCisgICAgTU9WX0ZST01fUkVHKDApCisgICAgTU9WX0ZST01fUkVHKDEpCisgICAgTU9WX0ZS
T01fUkVHKDIpCisgICAgTU9WX0ZST01fUkVHKDMpCisgICAgTU9WX0ZST01fUkVHKDQpCisgICAg
TU9WX0ZST01fUkVHKDUpCisgICAgTU9WX0ZST01fUkVHKDYpCisgICAgTU9WX0ZST01fUkVHKDcp
CisgICAgTU9WX0ZST01fUkVHKDgpCisgICAgTU9WX0ZST01fUkVHKDkpCisgICAgTU9WX0ZST01f
UkVHKDEwKQorICAgIE1PVl9GUk9NX1JFRygxMSkKKyAgICBNT1ZfRlJPTV9SRUcoMTIpCisgICAg
TU9WX0ZST01fUkVHKDEzKQorICAgIE1PVl9GUk9NX1JFRygxNCkKKyAgICBNT1ZfRlJPTV9SRUco
MTUpCisgICAgSk1QX1RPX01PVl9GUk9NX0JBTkswX1JFRygxNikKKyAgICBKTVBfVE9fTU9WX0ZS
T01fQkFOSzBfUkVHKDE3KQorICAgIEpNUF9UT19NT1ZfRlJPTV9CQU5LMF9SRUcoMTgpCisgICAg
Sk1QX1RPX01PVl9GUk9NX0JBTkswX1JFRygxOSkKKyAgICBKTVBfVE9fTU9WX0ZST01fQkFOSzBf
UkVHKDIwKQorICAgIEpNUF9UT19NT1ZfRlJPTV9CQU5LMF9SRUcoMjEpCisgICAgSk1QX1RPX01P
Vl9GUk9NX0JBTkswX1JFRygyMikKKyAgICBKTVBfVE9fTU9WX0ZST01fQkFOSzBfUkVHKDIzKQor
ICAgIEpNUF9UT19NT1ZfRlJPTV9CQU5LMF9SRUcoMjQpCisgICAgSk1QX1RPX01PVl9GUk9NX0JB
TkswX1JFRygyNSkKKyAgICBKTVBfVE9fTU9WX0ZST01fQkFOSzBfUkVHKDI2KQorICAgIEpNUF9U
T19NT1ZfRlJPTV9CQU5LMF9SRUcoMjcpCisgICAgSk1QX1RPX01PVl9GUk9NX0JBTkswX1JFRygy
OCkKKyAgICBKTVBfVE9fTU9WX0ZST01fQkFOSzBfUkVHKDI5KQorICAgIEpNUF9UT19NT1ZfRlJP
TV9CQU5LMF9SRUcoMzApCisgICAgSk1QX1RPX01PVl9GUk9NX0JBTkswX1JFRygzMSkKKyAgICBN
T1ZfRlJPTV9SRUcoMzIpCisgICAgTU9WX0ZST01fUkVHKDMzKQorICAgIE1PVl9GUk9NX1JFRygz
NCkKKyAgICBNT1ZfRlJPTV9SRUcoMzUpCisgICAgTU9WX0ZST01fUkVHKDM2KQorICAgIE1PVl9G
Uk9NX1JFRygzNykKKyAgICBNT1ZfRlJPTV9SRUcoMzgpCisgICAgTU9WX0ZST01fUkVHKDM5KQor
ICAgIE1PVl9GUk9NX1JFRyg0MCkKKyAgICBNT1ZfRlJPTV9SRUcoNDEpCisgICAgTU9WX0ZST01f
UkVHKDQyKQorICAgIE1PVl9GUk9NX1JFRyg0MykKKyAgICBNT1ZfRlJPTV9SRUcoNDQpCisgICAg
TU9WX0ZST01fUkVHKDQ1KQorICAgIE1PVl9GUk9NX1JFRyg0NikKKyAgICBNT1ZfRlJPTV9SRUco
NDcpCisgICAgTU9WX0ZST01fUkVHKDQ4KQorICAgIE1PVl9GUk9NX1JFRyg0OSkKKyAgICBNT1Zf
RlJPTV9SRUcoNTApCisgICAgTU9WX0ZST01fUkVHKDUxKQorICAgIE1PVl9GUk9NX1JFRyg1MikK
KyAgICBNT1ZfRlJPTV9SRUcoNTMpCisgICAgTU9WX0ZST01fUkVHKDU0KQorICAgIE1PVl9GUk9N
X1JFRyg1NSkKKyAgICBNT1ZfRlJPTV9SRUcoNTYpCisgICAgTU9WX0ZST01fUkVHKDU3KQorICAg
IE1PVl9GUk9NX1JFRyg1OCkKKyAgICBNT1ZfRlJPTV9SRUcoNTkpCisgICAgTU9WX0ZST01fUkVH
KDYwKQorICAgIE1PVl9GUk9NX1JFRyg2MSkKKyAgICBNT1ZfRlJPTV9SRUcoNjIpCisgICAgTU9W
X0ZST01fUkVHKDYzKQorICAgIE1PVl9GUk9NX1JFRyg2NCkKKyAgICBNT1ZfRlJPTV9SRUcoNjUp
CisgICAgTU9WX0ZST01fUkVHKDY2KQorICAgIE1PVl9GUk9NX1JFRyg2NykKKyAgICBNT1ZfRlJP
TV9SRUcoNjgpCisgICAgTU9WX0ZST01fUkVHKDY5KQorICAgIE1PVl9GUk9NX1JFRyg3MCkKKyAg
ICBNT1ZfRlJPTV9SRUcoNzEpCisgICAgTU9WX0ZST01fUkVHKDcyKQorICAgIE1PVl9GUk9NX1JF
Ryg3MykKKyAgICBNT1ZfRlJPTV9SRUcoNzQpCisgICAgTU9WX0ZST01fUkVHKDc1KQorICAgIE1P
Vl9GUk9NX1JFRyg3NikKKyAgICBNT1ZfRlJPTV9SRUcoNzcpCisgICAgTU9WX0ZST01fUkVHKDc4
KQorICAgIE1PVl9GUk9NX1JFRyg3OSkKKyAgICBNT1ZfRlJPTV9SRUcoODApCisgICAgTU9WX0ZS
T01fUkVHKDgxKQorICAgIE1PVl9GUk9NX1JFRyg4MikKKyAgICBNT1ZfRlJPTV9SRUcoODMpCisg
ICAgTU9WX0ZST01fUkVHKDg0KQorICAgIE1PVl9GUk9NX1JFRyg4NSkKKyAgICBNT1ZfRlJPTV9S
RUcoODYpCisgICAgTU9WX0ZST01fUkVHKDg3KQorICAgIE1PVl9GUk9NX1JFRyg4OCkKKyAgICBN
T1ZfRlJPTV9SRUcoODkpCisgICAgTU9WX0ZST01fUkVHKDkwKQorICAgIE1PVl9GUk9NX1JFRyg5
MSkKKyAgICBNT1ZfRlJPTV9SRUcoOTIpCisgICAgTU9WX0ZST01fUkVHKDkzKQorICAgIE1PVl9G
Uk9NX1JFRyg5NCkKKyAgICBNT1ZfRlJPTV9SRUcoOTUpCisgICAgTU9WX0ZST01fUkVHKDk2KQor
ICAgIE1PVl9GUk9NX1JFRyg5NykKKyAgICBNT1ZfRlJPTV9SRUcoOTgpCisgICAgTU9WX0ZST01f
UkVHKDk5KQorICAgIE1PVl9GUk9NX1JFRygxMDApCisgICAgTU9WX0ZST01fUkVHKDEwMSkKKyAg
ICBNT1ZfRlJPTV9SRUcoMTAyKQorICAgIE1PVl9GUk9NX1JFRygxMDMpCisgICAgTU9WX0ZST01f
UkVHKDEwNCkKKyAgICBNT1ZfRlJPTV9SRUcoMTA1KQorICAgIE1PVl9GUk9NX1JFRygxMDYpCisg
ICAgTU9WX0ZST01fUkVHKDEwNykKKyAgICBNT1ZfRlJPTV9SRUcoMTA4KQorICAgIE1PVl9GUk9N
X1JFRygxMDkpCisgICAgTU9WX0ZST01fUkVHKDExMCkKKyAgICBNT1ZfRlJPTV9SRUcoMTExKQor
ICAgIE1PVl9GUk9NX1JFRygxMTIpCisgICAgTU9WX0ZST01fUkVHKDExMykKKyAgICBNT1ZfRlJP
TV9SRUcoMTE0KQorICAgIE1PVl9GUk9NX1JFRygxMTUpCisgICAgTU9WX0ZST01fUkVHKDExNikK
KyAgICBNT1ZfRlJPTV9SRUcoMTE3KQorICAgIE1PVl9GUk9NX1JFRygxMTgpCisgICAgTU9WX0ZS
T01fUkVHKDExOSkKKyAgICBNT1ZfRlJPTV9SRUcoMTIwKQorICAgIE1PVl9GUk9NX1JFRygxMjEp
CisgICAgTU9WX0ZST01fUkVHKDEyMikKKyAgICBNT1ZfRlJPTV9SRUcoMTIzKQorICAgIE1PVl9G
Uk9NX1JFRygxMjQpCisgICAgTU9WX0ZST01fUkVHKDEyNSkKKyAgICBNT1ZfRlJPTV9SRUcoMTI2
KQorICAgIE1PVl9GUk9NX1JFRygxMjcpCitFTkQoYXNtX21vdl9mcm9tX3JlZykKKworCisvKiBt
dXN0IGJlIGluIGJhbmsgMAorICogcGFyYW1ldGVyOgorICogcjMxOiBwcgorICogcjI0OiBiMAor
ICovCitFTlRSWShrdm1fcmVzdW1lX3RvX2d1ZXN0KQorICAgIGFkZHMgcjE2ID0gVk1NX1ZDUFVf
U0FWRURfR1BfT0ZGU0VULHIyMQorICAgIDs7CisgICAgbGQ4IHIxID1bcjE2XQorICAgIGFkZHMg
cjIwID0gVk1NX1ZDUFVfVlNBX0JBU0VfT0ZGU0VULHIyMQorICAgIDs7CisgICAgbW92IHIxNj1j
ci5pcHNyCisgICAgOzsKKyAgICBsZDggcjIwID0gW3IyMF0KKyAgICBhZGRzIHIxOT1WTU1fVlBE
X0JBU0VfT0ZGU0VULHIyMQorICAgIDs7CisgICAgbGQ4IHIyNT1bcjE5XQorICAgIGV4dHIudSBy
MTc9cjE2LElBNjRfUFNSX1JJX0JJVCwyCisgICAgdGJpdC5ueiBwNixwNz1yMTYsSUE2NF9QU1Jf
UklfQklUKzEKKyAgICA7OworICAgIChwNikgbW92IHIxOD1jci5paXAKKyAgICAocDYpIG1vdiBy
MTc9cjAKKyAgICA7OworICAgIChwNikgYWRkIHIxOD0weDEwLHIxOAorICAgIChwNykgYWRkIHIx
Nz0xLHIxNworICAgIDs7CisgICAgKHA2KSBtb3YgY3IuaWlwPXIxOAorICAgIGRlcCByMTY9cjE3
LHIxNixJQTY0X1BTUl9SSV9CSVQsMgorICAgIDs7CisgICAgbW92IGNyLmlwc3I9cjE2CisgICAg
YWRkcyByMTk9IFZQRF9WUFNSX1NUQVJUX09GRlNFVCxyMjUKKyAgICBhZGQgcjI4PVBBTF9WUFNf
UkVTVU1FX05PUk1BTCxyMjAKKyAgICBhZGQgcjI5PVBBTF9WUFNfUkVTVU1FX0hBTkRMRVIscjIw
CisgICAgOzsKKyAgICBsZDggcjE5PVtyMTldCisgICAgbW92IGIwPXIyOQorICAgIGNtcC5uZSBw
NixwNyA9IHIwLHIwCisgICAgOzsKKyAgICB0Yml0LnogcDYscDcgPSByMTksSUE2NF9QU1JfSUNf
QklUCQkvLyBwMT12cHNyLmljCisgICAgOzsKKyAgICAocDYpIGxkOCByMjY9W3IyNV0KKyAgICAo
cDcpIG1vdiBiMD1yMjgKKyAgICBtb3YgcHI9cjMxLC0yCisgICAgYnIuc3B0ay5tYW55IGIwICAg
ICAgICAgICAgIC8vIGNhbGwgcGFsIHNlcnZpY2UKKyAgICA7OworRU5EKGt2bV9yZXN1bWVfdG9f
Z3Vlc3QpCisKKworTU9WX1RPX0JBTkswX1JFRygxNikKK01PVl9UT19CQU5LMF9SRUcoMTcpCitN
T1ZfVE9fQkFOSzBfUkVHKDE4KQorTU9WX1RPX0JBTkswX1JFRygxOSkKK01PVl9UT19CQU5LMF9S
RUcoMjApCitNT1ZfVE9fQkFOSzBfUkVHKDIxKQorTU9WX1RPX0JBTkswX1JFRygyMikKK01PVl9U
T19CQU5LMF9SRUcoMjMpCitNT1ZfVE9fQkFOSzBfUkVHKDI0KQorTU9WX1RPX0JBTkswX1JFRygy
NSkKK01PVl9UT19CQU5LMF9SRUcoMjYpCitNT1ZfVE9fQkFOSzBfUkVHKDI3KQorTU9WX1RPX0JB
TkswX1JFRygyOCkKK01PVl9UT19CQU5LMF9SRUcoMjkpCitNT1ZfVE9fQkFOSzBfUkVHKDMwKQor
TU9WX1RPX0JBTkswX1JFRygzMSkKKworCisvLyBtb3YgdG8gcmVnIHRhYmxlCitFTlRSWShhc21f
bW92X3RvX3JlZykKKyAgICBNT1ZfVE9fUkVHMAorICAgIE1PVl9UT19SRUcoMSkKKyAgICBNT1Zf
VE9fUkVHKDIpCisgICAgTU9WX1RPX1JFRygzKQorICAgIE1PVl9UT19SRUcoNCkKKyAgICBNT1Zf
VE9fUkVHKDUpCisgICAgTU9WX1RPX1JFRyg2KQorICAgIE1PVl9UT19SRUcoNykKKyAgICBNT1Zf
VE9fUkVHKDgpCisgICAgTU9WX1RPX1JFRyg5KQorICAgIE1PVl9UT19SRUcoMTApCisgICAgTU9W
X1RPX1JFRygxMSkKKyAgICBNT1ZfVE9fUkVHKDEyKQorICAgIE1PVl9UT19SRUcoMTMpCisgICAg
TU9WX1RPX1JFRygxNCkKKyAgICBNT1ZfVE9fUkVHKDE1KQorICAgIEpNUF9UT19NT1ZfVE9fQkFO
SzBfUkVHKDE2KQorICAgIEpNUF9UT19NT1ZfVE9fQkFOSzBfUkVHKDE3KQorICAgIEpNUF9UT19N
T1ZfVE9fQkFOSzBfUkVHKDE4KQorICAgIEpNUF9UT19NT1ZfVE9fQkFOSzBfUkVHKDE5KQorICAg
IEpNUF9UT19NT1ZfVE9fQkFOSzBfUkVHKDIwKQorICAgIEpNUF9UT19NT1ZfVE9fQkFOSzBfUkVH
KDIxKQorICAgIEpNUF9UT19NT1ZfVE9fQkFOSzBfUkVHKDIyKQorICAgIEpNUF9UT19NT1ZfVE9f
QkFOSzBfUkVHKDIzKQorICAgIEpNUF9UT19NT1ZfVE9fQkFOSzBfUkVHKDI0KQorICAgIEpNUF9U
T19NT1ZfVE9fQkFOSzBfUkVHKDI1KQorICAgIEpNUF9UT19NT1ZfVE9fQkFOSzBfUkVHKDI2KQor
ICAgIEpNUF9UT19NT1ZfVE9fQkFOSzBfUkVHKDI3KQorICAgIEpNUF9UT19NT1ZfVE9fQkFOSzBf
UkVHKDI4KQorICAgIEpNUF9UT19NT1ZfVE9fQkFOSzBfUkVHKDI5KQorICAgIEpNUF9UT19NT1Zf
VE9fQkFOSzBfUkVHKDMwKQorICAgIEpNUF9UT19NT1ZfVE9fQkFOSzBfUkVHKDMxKQorICAgIE1P
Vl9UT19SRUcoMzIpCisgICAgTU9WX1RPX1JFRygzMykKKyAgICBNT1ZfVE9fUkVHKDM0KQorICAg
IE1PVl9UT19SRUcoMzUpCisgICAgTU9WX1RPX1JFRygzNikKKyAgICBNT1ZfVE9fUkVHKDM3KQor
ICAgIE1PVl9UT19SRUcoMzgpCisgICAgTU9WX1RPX1JFRygzOSkKKyAgICBNT1ZfVE9fUkVHKDQw
KQorICAgIE1PVl9UT19SRUcoNDEpCisgICAgTU9WX1RPX1JFRyg0MikKKyAgICBNT1ZfVE9fUkVH
KDQzKQorICAgIE1PVl9UT19SRUcoNDQpCisgICAgTU9WX1RPX1JFRyg0NSkKKyAgICBNT1ZfVE9f
UkVHKDQ2KQorICAgIE1PVl9UT19SRUcoNDcpCisgICAgTU9WX1RPX1JFRyg0OCkKKyAgICBNT1Zf
VE9fUkVHKDQ5KQorICAgIE1PVl9UT19SRUcoNTApCisgICAgTU9WX1RPX1JFRyg1MSkKKyAgICBN
T1ZfVE9fUkVHKDUyKQorICAgIE1PVl9UT19SRUcoNTMpCisgICAgTU9WX1RPX1JFRyg1NCkKKyAg
ICBNT1ZfVE9fUkVHKDU1KQorICAgIE1PVl9UT19SRUcoNTYpCisgICAgTU9WX1RPX1JFRyg1NykK
KyAgICBNT1ZfVE9fUkVHKDU4KQorICAgIE1PVl9UT19SRUcoNTkpCisgICAgTU9WX1RPX1JFRyg2
MCkKKyAgICBNT1ZfVE9fUkVHKDYxKQorICAgIE1PVl9UT19SRUcoNjIpCisgICAgTU9WX1RPX1JF
Ryg2MykKKyAgICBNT1ZfVE9fUkVHKDY0KQorICAgIE1PVl9UT19SRUcoNjUpCisgICAgTU9WX1RP
X1JFRyg2NikKKyAgICBNT1ZfVE9fUkVHKDY3KQorICAgIE1PVl9UT19SRUcoNjgpCisgICAgTU9W
X1RPX1JFRyg2OSkKKyAgICBNT1ZfVE9fUkVHKDcwKQorICAgIE1PVl9UT19SRUcoNzEpCisgICAg
TU9WX1RPX1JFRyg3MikKKyAgICBNT1ZfVE9fUkVHKDczKQorICAgIE1PVl9UT19SRUcoNzQpCisg
ICAgTU9WX1RPX1JFRyg3NSkKKyAgICBNT1ZfVE9fUkVHKDc2KQorICAgIE1PVl9UT19SRUcoNzcp
CisgICAgTU9WX1RPX1JFRyg3OCkKKyAgICBNT1ZfVE9fUkVHKDc5KQorICAgIE1PVl9UT19SRUco
ODApCisgICAgTU9WX1RPX1JFRyg4MSkKKyAgICBNT1ZfVE9fUkVHKDgyKQorICAgIE1PVl9UT19S
RUcoODMpCisgICAgTU9WX1RPX1JFRyg4NCkKKyAgICBNT1ZfVE9fUkVHKDg1KQorICAgIE1PVl9U
T19SRUcoODYpCisgICAgTU9WX1RPX1JFRyg4NykKKyAgICBNT1ZfVE9fUkVHKDg4KQorICAgIE1P
Vl9UT19SRUcoODkpCisgICAgTU9WX1RPX1JFRyg5MCkKKyAgICBNT1ZfVE9fUkVHKDkxKQorICAg
IE1PVl9UT19SRUcoOTIpCisgICAgTU9WX1RPX1JFRyg5MykKKyAgICBNT1ZfVE9fUkVHKDk0KQor
ICAgIE1PVl9UT19SRUcoOTUpCisgICAgTU9WX1RPX1JFRyg5NikKKyAgICBNT1ZfVE9fUkVHKDk3
KQorICAgIE1PVl9UT19SRUcoOTgpCisgICAgTU9WX1RPX1JFRyg5OSkKKyAgICBNT1ZfVE9fUkVH
KDEwMCkKKyAgICBNT1ZfVE9fUkVHKDEwMSkKKyAgICBNT1ZfVE9fUkVHKDEwMikKKyAgICBNT1Zf
VE9fUkVHKDEwMykKKyAgICBNT1ZfVE9fUkVHKDEwNCkKKyAgICBNT1ZfVE9fUkVHKDEwNSkKKyAg
ICBNT1ZfVE9fUkVHKDEwNikKKyAgICBNT1ZfVE9fUkVHKDEwNykKKyAgICBNT1ZfVE9fUkVHKDEw
OCkKKyAgICBNT1ZfVE9fUkVHKDEwOSkKKyAgICBNT1ZfVE9fUkVHKDExMCkKKyAgICBNT1ZfVE9f
UkVHKDExMSkKKyAgICBNT1ZfVE9fUkVHKDExMikKKyAgICBNT1ZfVE9fUkVHKDExMykKKyAgICBN
T1ZfVE9fUkVHKDExNCkKKyAgICBNT1ZfVE9fUkVHKDExNSkKKyAgICBNT1ZfVE9fUkVHKDExNikK
KyAgICBNT1ZfVE9fUkVHKDExNykKKyAgICBNT1ZfVE9fUkVHKDExOCkKKyAgICBNT1ZfVE9fUkVH
KDExOSkKKyAgICBNT1ZfVE9fUkVHKDEyMCkKKyAgICBNT1ZfVE9fUkVHKDEyMSkKKyAgICBNT1Zf
VE9fUkVHKDEyMikKKyAgICBNT1ZfVE9fUkVHKDEyMykKKyAgICBNT1ZfVE9fUkVHKDEyNCkKKyAg
ICBNT1ZfVE9fUkVHKDEyNSkKKyAgICBNT1ZfVE9fUkVHKDEyNikKKyAgICBNT1ZfVE9fUkVHKDEy
NykKK0VORChhc21fbW92X3RvX3JlZykKLS0gCjEuNS4xCgo=

------_=_NextPart_001_01C863F4.4345B04B--
