From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Tue, 01 Apr 2008 10:51:37 +0000
Subject: [15/18]  KVM:IA64 : Add guest interruption injection support.V9
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDC0104872E@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C893E6.5C0C5B0B"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C893E6.5C0C5B0B
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

From 6fd811727b9e234a683b42e7ad461429f02ddd3f Mon Sep 17 00:00:00 2001
From: Xiantao Zhang <xiantao.zhang@intel.com>
Date: Tue, 1 Apr 2008 14:58:42 +0800
Subject: [PATCH] KVM:IA64 : Add guest interruption injection support.

process.c mainly handle interruption injection, and some
faults handling.
Signed-off-by: Anthony Xu <anthony.xu@intel.com>
Signed-off-by: Xiantao Zhang <xiantao.zhang@intel.com>
---
 arch/ia64/kvm/process.c |  970
+++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 970 insertions(+), 0 deletions(-)
 create mode 100644 arch/ia64/kvm/process.c

diff --git a/arch/ia64/kvm/process.c b/arch/ia64/kvm/process.c
new file mode 100644
index 0000000..d6a475b
--- /dev/null
+++ b/arch/ia64/kvm/process.c
@@ -0,0 +1,970 @@
+/*
+ * process.c: handle interruption inject for guests.
+ * Copyright (c) 2005, Intel Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify
it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but
WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License
along with
+ * this program; if not, write to the Free Software Foundation, Inc.,
59 Temple
+ * Place - Suite 330, Boston, MA 02111-1307 USA.
+ *
+ *  	Shaofan Li (Susue Li) <susie.li@intel.com>
+ *  	Xiaoyan Feng (Fleming Feng)  <fleming.feng@intel.com>
+ *  	Xuefei Xu (Anthony Xu) (Anthony.xu@intel.com)
+ *  	Xiantao Zhang (xiantao.zhang@intel.com)
+ */
+#include "vcpu.h"
+
+#include <asm/pal.h>
+#include <asm/sal.h>
+#include <asm/fpswa.h>
+#include <asm/kregs.h>
+#include <asm/tlb.h>
+
+fpswa_interface_t *vmm_fpswa_interface;
+
+#define IA64_VHPT_TRANS_VECTOR			0x0000
+#define IA64_INST_TLB_VECTOR			0x0400
+#define IA64_DATA_TLB_VECTOR			0x0800
+#define IA64_ALT_INST_TLB_VECTOR		0x0c00
+#define IA64_ALT_DATA_TLB_VECTOR		0x1000
+#define IA64_DATA_NESTED_TLB_VECTOR		0x1400
+#define IA64_INST_KEY_MISS_VECTOR		0x1800
+#define IA64_DATA_KEY_MISS_VECTOR		0x1c00
+#define IA64_DIRTY_BIT_VECTOR			0x2000
+#define IA64_INST_ACCESS_BIT_VECTOR		0x2400
+#define IA64_DATA_ACCESS_BIT_VECTOR		0x2800
+#define IA64_BREAK_VECTOR			0x2c00
+#define IA64_EXTINT_VECTOR			0x3000
+#define IA64_PAGE_NOT_PRESENT_VECTOR		0x5000
+#define IA64_KEY_PERMISSION_VECTOR		0x5100
+#define IA64_INST_ACCESS_RIGHTS_VECTOR		0x5200
+#define IA64_DATA_ACCESS_RIGHTS_VECTOR		0x5300
+#define IA64_GENEX_VECTOR			0x5400
+#define IA64_DISABLED_FPREG_VECTOR		0x5500
+#define IA64_NAT_CONSUMPTION_VECTOR		0x5600
+#define IA64_SPECULATION_VECTOR		0x5700 /* UNUSED */
+#define IA64_DEBUG_VECTOR			0x5900
+#define IA64_UNALIGNED_REF_VECTOR		0x5a00
+#define IA64_UNSUPPORTED_DATA_REF_VECTOR	0x5b00
+#define IA64_FP_FAULT_VECTOR			0x5c00
+#define IA64_FP_TRAP_VECTOR			0x5d00
+#define IA64_LOWERPRIV_TRANSFER_TRAP_VECTOR 	0x5e00
+#define IA64_TAKEN_BRANCH_TRAP_VECTOR		0x5f00
+#define IA64_SINGLE_STEP_TRAP_VECTOR		0x6000
+
+/* SDM vol2 5.5 - IVA based interruption handling */
+#define INITIAL_PSR_VALUE_AT_INTERRUPTION (IA64_PSR_UP | IA64_PSR_MFL
|\
+			IA64_PSR_MFH | IA64_PSR_PK | IA64_PSR_DT |
\
+			IA64_PSR_RT | IA64_PSR_MC|IA64_PSR_IT)
+
+#define DOMN_PAL_REQUEST    0x110000
+#define DOMN_SAL_REQUEST    0x110001
+
+static u64 vec2off[68] =3D {0x0, 0x400, 0x800, 0xc00, 0x1000, 0x1400,
0x1800,
+	0x1c00, 0x2000, 0x2400, 0x2800, 0x2c00, 0x3000, 0x3400, 0x3800,
0x3c00,
+	0x4000, 0x4400, 0x4800, 0x4c00, 0x5000, 0x5100, 0x5200, 0x5300,
0x5400,
+	0x5500, 0x5600, 0x5700, 0x5800, 0x5900, 0x5a00, 0x5b00, 0x5c00,
0x5d00,
+	0x5e00, 0x5f00, 0x6000, 0x6100, 0x6200, 0x6300, 0x6400, 0x6500,
0x6600,
+	0x6700, 0x6800, 0x6900, 0x6a00, 0x6b00, 0x6c00, 0x6d00, 0x6e00,
0x6f00,
+	0x7000, 0x7100, 0x7200, 0x7300, 0x7400, 0x7500, 0x7600, 0x7700,
0x7800,
+	0x7900, 0x7a00, 0x7b00, 0x7c00, 0x7d00, 0x7e00, 0x7f00
+};
+
+static void collect_interruption(struct kvm_vcpu *vcpu)
+{
+	u64 ipsr;
+	u64 vdcr;
+	u64 vifs;
+	unsigned long vpsr;
+	struct kvm_pt_regs *regs =3D vcpu_regs(vcpu);
+
+	vpsr =3D vcpu_get_psr(vcpu);
+	vcpu_bsw0(vcpu);
+	if (vpsr & IA64_PSR_IC) {
+
+		/* Sync mpsr id/da/dd/ss/ed bits to vipsr
+		 * since after guest do rfi, we still want these bits on
in
+		 * mpsr
+		 */
+
+		ipsr =3D regs->cr_ipsr;
+		vpsr =3D vpsr | (ipsr & (IA64_PSR_ID | IA64_PSR_DA
+					| IA64_PSR_DD | IA64_PSR_SS
+					| IA64_PSR_ED));
+		vcpu_set_ipsr(vcpu, vpsr);
+
+		/* Currently, for trap, we do not advance IIP to next
+		 * instruction. That's because we assume caller already
+		 * set up IIP correctly
+		 */
+
+		vcpu_set_iip(vcpu , regs->cr_iip);
+
+		/* set vifs.v to zero */
+		vifs =3D VCPU(vcpu, ifs);
+		vifs &=3D ~IA64_IFS_V;
+		vcpu_set_ifs(vcpu, vifs);
+
+		vcpu_set_iipa(vcpu, VMX(vcpu, cr_iipa));
+	}
+
+	vdcr =3D VCPU(vcpu, dcr);
+
+	/* Set guest psr
+	 * up/mfl/mfh/pk/dt/rt/mc/it keeps unchanged
+	 * be: set to the value of dcr.be
+	 * pp: set to the value of dcr.pp
+	 */
+	vpsr &=3D INITIAL_PSR_VALUE_AT_INTERRUPTION;
+	vpsr |=3D (vdcr & IA64_DCR_BE);
+
+	/* VDCR pp bit position is different from VPSR pp bit */
+	if (vdcr & IA64_DCR_PP) {
+		vpsr |=3D IA64_PSR_PP;
+	} else {
+		vpsr &=3D ~IA64_PSR_PP;;
+	}
+
+	vcpu_set_psr(vcpu, vpsr);
+
+}
+
+void inject_guest_interruption(struct kvm_vcpu *vcpu, u64 vec)
+{
+	u64 viva;
+	struct kvm_pt_regs *regs;
+	union ia64_isr pt_isr;
+
+	regs =3D vcpu_regs(vcpu);
+
+	/* clear cr.isr.ir (incomplete register frame)*/
+	pt_isr.val =3D VMX(vcpu, cr_isr);
+	pt_isr.ir =3D 0;
+	VMX(vcpu, cr_isr) =3D pt_isr.val;
+
+	collect_interruption(vcpu);
+
+	viva =3D vcpu_get_iva(vcpu);
+	regs->cr_iip =3D viva + vec;
+}
+
+static u64 vcpu_get_itir_on_fault(struct kvm_vcpu *vcpu, u64 ifa)
+{
+	union ia64_rr rr, rr1;
+
+	rr.val =3D vcpu_get_rr(vcpu, ifa);
+	rr1.val =3D 0;
+	rr1.ps =3D rr.ps;
+	rr1.rid =3D rr.rid;
+	return (rr1.val);
+}
+
+
+/*
+ * Set vIFA & vITIR & vIHA, when vPSR.ic =3D1
+ * Parameter:
+ *  set_ifa: if true, set vIFA
+ *  set_itir: if true, set vITIR
+ *  set_iha: if true, set vIHA
+ */
+void set_ifa_itir_iha(struct kvm_vcpu *vcpu, u64 vadr,
+		int set_ifa, int set_itir, int set_iha)
+{
+	long vpsr;
+	u64 value;
+
+	vpsr =3D VCPU(vcpu, vpsr);
+	/* Vol2, Table 8-1 */
+	if (vpsr & IA64_PSR_IC) {
+		if (set_ifa)
+			vcpu_set_ifa(vcpu, vadr);
+		if (set_itir) {
+			value =3D vcpu_get_itir_on_fault(vcpu, vadr);
+			vcpu_set_itir(vcpu, value);
+		}
+
+		if (set_iha) {
+			value =3D vcpu_thash(vcpu, vadr);
+			vcpu_set_iha(vcpu, value);
+		}
+	}
+}
+
+/*
+ * Data TLB Fault
+ *  @ Data TLB vector
+ * Refer to SDM Vol2 Table 5-6 & 8-1
+ */
+void dtlb_fault(struct kvm_vcpu *vcpu, u64 vadr)
+{
+	/* If vPSR.ic, IFA, ITIR, IHA */
+	set_ifa_itir_iha(vcpu, vadr, 1, 1, 1);
+	inject_guest_interruption(vcpu, IA64_DATA_TLB_VECTOR);
+}
+
+/*
+ * Instruction TLB Fault
+ *  @ Instruction TLB vector
+ * Refer to SDM Vol2 Table 5-6 & 8-1
+ */
+void itlb_fault(struct kvm_vcpu *vcpu, u64 vadr)
+{
+	/* If vPSR.ic, IFA, ITIR, IHA */
+	set_ifa_itir_iha(vcpu, vadr, 1, 1, 1);
+	inject_guest_interruption(vcpu, IA64_INST_TLB_VECTOR);
+}
+
+
+
+/*
+ * Data Nested TLB Fault
+ *  @ Data Nested TLB Vector
+ * Refer to SDM Vol2 Table 5-6 & 8-1
+ */
+void nested_dtlb(struct kvm_vcpu *vcpu)
+{
+	inject_guest_interruption(vcpu, IA64_DATA_NESTED_TLB_VECTOR);
+}
+
+/*
+ * Alternate Data TLB Fault
+ *  @ Alternate Data TLB vector
+ * Refer to SDM Vol2 Table 5-6 & 8-1
+ */
+void alt_dtlb(struct kvm_vcpu *vcpu, u64 vadr)
+{
+	set_ifa_itir_iha(vcpu, vadr, 1, 1, 0);
+	inject_guest_interruption(vcpu, IA64_ALT_DATA_TLB_VECTOR);
+}
+
+
+/*
+ * Data TLB Fault
+ *  @ Data TLB vector
+ * Refer to SDM Vol2 Table 5-6 & 8-1
+ */
+void alt_itlb(struct kvm_vcpu *vcpu, u64 vadr)
+{
+	set_ifa_itir_iha(vcpu, vadr, 1, 1, 0);
+	inject_guest_interruption(vcpu, IA64_ALT_INST_TLB_VECTOR);
+}
+
+/* Deal with:
+ *  VHPT Translation Vector
+ */
+static void _vhpt_fault(struct kvm_vcpu *vcpu, u64 vadr)
+{
+	/* If vPSR.ic, IFA, ITIR, IHA*/
+	set_ifa_itir_iha(vcpu, vadr, 1, 1, 1);
+	inject_guest_interruption(vcpu, IA64_VHPT_TRANS_VECTOR);
+
+
+}
+
+/*
+ * VHPT Instruction Fault
+ *  @ VHPT Translation vector
+ * Refer to SDM Vol2 Table 5-6 & 8-1
+ */
+void ivhpt_fault(struct kvm_vcpu *vcpu, u64 vadr)
+{
+	_vhpt_fault(vcpu, vadr);
+}
+
+
+/*
+ * VHPT Data Fault
+ *  @ VHPT Translation vector
+ * Refer to SDM Vol2 Table 5-6 & 8-1
+ */
+void dvhpt_fault(struct kvm_vcpu *vcpu, u64 vadr)
+{
+	_vhpt_fault(vcpu, vadr);
+}
+
+
+
+/*
+ * Deal with:
+ *  General Exception vector
+ */
+void _general_exception(struct kvm_vcpu *vcpu)
+{
+	inject_guest_interruption(vcpu, IA64_GENEX_VECTOR);
+}
+
+
+/*
+ * Illegal Operation Fault
+ *  @ General Exception Vector
+ * Refer to SDM Vol2 Table 5-6 & 8-1
+ */
+void illegal_op(struct kvm_vcpu *vcpu)
+{
+	_general_exception(vcpu);
+}
+
+/*
+ * Illegal Dependency Fault
+ *  @ General Exception Vector
+ * Refer to SDM Vol2 Table 5-6 & 8-1
+ */
+void illegal_dep(struct kvm_vcpu *vcpu)
+{
+	_general_exception(vcpu);
+}
+
+/*
+ * Reserved Register/Field Fault
+ *  @ General Exception Vector
+ * Refer to SDM Vol2 Table 5-6 & 8-1
+ */
+void rsv_reg_field(struct kvm_vcpu *vcpu)
+{
+	_general_exception(vcpu);
+}
+/*
+ * Privileged Operation Fault
+ *  @ General Exception Vector
+ * Refer to SDM Vol2 Table 5-6 & 8-1
+ */
+
+void privilege_op(struct kvm_vcpu *vcpu)
+{
+	_general_exception(vcpu);
+}
+
+/*
+ * Unimplement Data Address Fault
+ *  @ General Exception Vector
+ * Refer to SDM Vol2 Table 5-6 & 8-1
+ */
+void unimpl_daddr(struct kvm_vcpu *vcpu)
+{
+	_general_exception(vcpu);
+}
+
+/*
+ * Privileged Register Fault
+ *  @ General Exception Vector
+ * Refer to SDM Vol2 Table 5-6 & 8-1
+ */
+void privilege_reg(struct kvm_vcpu *vcpu)
+{
+	_general_exception(vcpu);
+}
+
+/* Deal with
+ *  Nat consumption vector
+ * Parameter:
+ *  vaddr: Optional, if t =3D=3D REGISTER
+ */
+static void _nat_consumption_fault(struct kvm_vcpu *vcpu, u64 vadr,
+						enum tlb_miss_type t)
+{
+	/* If vPSR.ic && t =3D=3D DATA/INST, IFA */
+	if (t =3D=3D DATA || t =3D=3D INSTRUCTION) {
+		/* IFA */
+		set_ifa_itir_iha(vcpu, vadr, 1, 0, 0);
+	}
+
+	inject_guest_interruption(vcpu, IA64_NAT_CONSUMPTION_VECTOR);
+}
+
+/*
+ * Instruction Nat Page Consumption Fault
+ *  @ Nat Consumption Vector
+ * Refer to SDM Vol2 Table 5-6 & 8-1
+ */
+void inat_page_consumption(struct kvm_vcpu *vcpu, u64 vadr)
+{
+	_nat_consumption_fault(vcpu, vadr, INSTRUCTION);
+}
+
+/*
+ * Register Nat Consumption Fault
+ *  @ Nat Consumption Vector
+ * Refer to SDM Vol2 Table 5-6 & 8-1
+ */
+void rnat_consumption(struct kvm_vcpu *vcpu)
+{
+	_nat_consumption_fault(vcpu, 0, REGISTER);
+}
+
+/*
+ * Data Nat Page Consumption Fault
+ *  @ Nat Consumption Vector
+ * Refer to SDM Vol2 Table 5-6 & 8-1
+ */
+void dnat_page_consumption(struct kvm_vcpu *vcpu, u64 vadr)
+{
+	_nat_consumption_fault(vcpu, vadr, DATA);
+}
+
+/* Deal with
+ *  Page not present vector
+ */
+static void __page_not_present(struct kvm_vcpu *vcpu, u64 vadr)
+{
+	/* If vPSR.ic, IFA, ITIR */
+	set_ifa_itir_iha(vcpu, vadr, 1, 1, 0);
+	inject_guest_interruption(vcpu, IA64_PAGE_NOT_PRESENT_VECTOR);
+}
+
+
+void data_page_not_present(struct kvm_vcpu *vcpu, u64 vadr)
+{
+	__page_not_present(vcpu, vadr);
+}
+
+
+void inst_page_not_present(struct kvm_vcpu *vcpu, u64 vadr)
+{
+	__page_not_present(vcpu, vadr);
+}
+
+
+/* Deal with
+ *  Data access rights vector
+ */
+void data_access_rights(struct kvm_vcpu *vcpu, u64 vadr)
+{
+	/* If vPSR.ic, IFA, ITIR */
+	set_ifa_itir_iha(vcpu, vadr, 1, 1, 0);
+	inject_guest_interruption(vcpu, IA64_DATA_ACCESS_RIGHTS_VECTOR);
+}
+
+fpswa_ret_t vmm_fp_emulate(int fp_fault, void *bundle, unsigned long
*ipsr,
+		unsigned long *fpsr, unsigned long *isr, unsigned long
*pr,
+		unsigned long *ifs, struct kvm_pt_regs *regs)
+{
+	fp_state_t fp_state;
+	fpswa_ret_t ret;
+	struct kvm_vcpu *vcpu =3D current_vcpu;
+
+	uint64_t old_rr7 =3D ia64_get_rr(7UL<<61);
+
+	if (!vmm_fpswa_interface)
+		return (fpswa_ret_t) {-1, 0, 0, 0};
+
+	/*
+	 * Just let fpswa driver to use hardware fp registers.
+	 * No fp register is valid in memory.
+	 */
+	memset(&fp_state, 0, sizeof(fp_state_t));
+
+	/*
+	 * unsigned long (*EFI_FPSWA) (
+	 *      unsigned long    trap_type,
+	 *      void             *Bundle,
+	 *      unsigned long    *pipsr,
+	 *      unsigned long    *pfsr,
+	 *      unsigned long    *pisr,
+	 *      unsigned long    *ppreds,
+	 *      unsigned long    *pifs,
+	 *      void             *fp_state);
+	 */
+	/*Call host fpswa interface directly to virtualize
+	 *guest fpswa request!
+	 */
+	ia64_set_rr(7UL << 61, vcpu->arch.host.rr[7]);
+	ia64_srlz_d();
+
+	ret =3D (*vmm_fpswa_interface->fpswa) (fp_fault, bundle,
+			ipsr, fpsr, isr, pr, ifs, &fp_state);
+	ia64_set_rr(7UL << 61, old_rr7);
+	ia64_srlz_d();
+	return ret;
+}
+
+/*
+ * Handle floating-point assist faults and traps for domain.
+ */
+unsigned long vmm_handle_fpu_swa(int fp_fault, struct kvm_pt_regs
*regs,
+					unsigned long isr)
+{
+	struct kvm_vcpu *v =3D current_vcpu;
+	IA64_BUNDLE bundle;
+	unsigned long fault_ip;
+	fpswa_ret_t ret;
+
+	fault_ip =3D regs->cr_iip;
+	/*
+	 * When the FP trap occurs, the trapping instruction is
completed.
+	 * If ipsr.ri =3D=3D 0, there is the trapping instruction in
previous
+	 * bundle.
+	 */
+	if (!fp_fault && (ia64_psr(regs)->ri =3D=3D 0))
+		fault_ip -=3D 16;
+
+	if (fetch_code(v, fault_ip, &bundle))
+		return -EAGAIN;
+
+	if (!bundle.i64[0] && !bundle.i64[1])
+		return -EACCES;
+
+	ret =3D vmm_fp_emulate(fp_fault, &bundle, &regs->cr_ipsr,
&regs->ar_fpsr,
+			&isr, &regs->pr, &regs->cr_ifs, regs);
+	return ret.status;
+}
+
+void reflect_interruption(u64 ifa, u64 isr, u64 iim,
+		u64 vec, struct kvm_pt_regs *regs)
+{
+	u64 vector;
+	int status ;
+	struct kvm_vcpu *vcpu =3D current_vcpu;
+	u64 vpsr =3D VCPU(vcpu, vpsr);
+
+	vector =3D vec2off[vec];
+
+	if (!(vpsr & IA64_PSR_IC) && (vector !=3D
IA64_DATA_NESTED_TLB_VECTOR)) {
+		panic_vm(vcpu);
+		return;
+	}
+
+	switch (vec) {
+	case 32: 	/*IA64_FP_FAULT_VECTOR*/
+		status =3D vmm_handle_fpu_swa(1, regs, isr);
+		if (!status) {
+			vcpu_increment_iip(vcpu);
+			return;
+		} else if (-EAGAIN =3D=3D status)
+			return;
+		break;
+	case 33:	/*IA64_FP_TRAP_VECTOR*/
+		status =3D vmm_handle_fpu_swa(0, regs, isr);
+		if (!status)
+			return ;
+		else if (-EAGAIN =3D=3D status) {
+			vcpu_decrement_iip(vcpu);
+			return ;
+		}
+		break;
+	}
+
+	VCPU(vcpu, isr) =3D isr;
+	VCPU(vcpu, iipa) =3D regs->cr_iip;
+	if (vector =3D=3D IA64_BREAK_VECTOR || vector =3D=3D
IA64_SPECULATION_VECTOR)
+		VCPU(vcpu, iim) =3D iim;
+	else
+		set_ifa_itir_iha(vcpu, ifa, 1, 1, 1);
+
+	inject_guest_interruption(vcpu, vector);
+}
+
+static void set_pal_call_data(struct kvm_vcpu *vcpu)
+{
+	struct exit_ctl_data *p =3D &vcpu->arch.exit_data;
+
+	/*FIXME:For static and stacked convention, firmware
+	 * has put the parameters in gr28-gr31 before
+	 * break to vmm  !!*/
+
+	p->u.pal_data.gr28 =3D vcpu_get_gr(vcpu, 28);
+	p->u.pal_data.gr29 =3D vcpu_get_gr(vcpu, 29);
+	p->u.pal_data.gr30 =3D vcpu_get_gr(vcpu, 30);
+	p->u.pal_data.gr31 =3D vcpu_get_gr(vcpu, 31);
+	p->exit_reason =3D EXIT_REASON_PAL_CALL;
+}
+
+static void set_pal_call_result(struct kvm_vcpu *vcpu)
+{
+	struct exit_ctl_data *p =3D &vcpu->arch.exit_data;
+
+	if (p->exit_reason =3D=3D EXIT_REASON_PAL_CALL) {
+		vcpu_set_gr(vcpu, 8, p->u.pal_data.ret.status, 0);
+		vcpu_set_gr(vcpu, 9, p->u.pal_data.ret.v0, 0);
+		vcpu_set_gr(vcpu, 10, p->u.pal_data.ret.v1, 0);
+		vcpu_set_gr(vcpu, 11, p->u.pal_data.ret.v2, 0);
+	} else
+		panic_vm(vcpu);
+}
+
+static void set_sal_call_data(struct kvm_vcpu *vcpu)
+{
+	struct exit_ctl_data *p =3D &vcpu->arch.exit_data;
+
+	p->u.sal_data.in0 =3D vcpu_get_gr(vcpu, 32);
+	p->u.sal_data.in1 =3D vcpu_get_gr(vcpu, 33);
+	p->u.sal_data.in2 =3D vcpu_get_gr(vcpu, 34);
+	p->u.sal_data.in3 =3D vcpu_get_gr(vcpu, 35);
+	p->u.sal_data.in4 =3D vcpu_get_gr(vcpu, 36);
+	p->u.sal_data.in5 =3D vcpu_get_gr(vcpu, 37);
+	p->u.sal_data.in6 =3D vcpu_get_gr(vcpu, 38);
+	p->u.sal_data.in7 =3D vcpu_get_gr(vcpu, 39);
+	p->exit_reason =3D EXIT_REASON_SAL_CALL;
+}
+
+static void set_sal_call_result(struct kvm_vcpu *vcpu)
+{
+	struct exit_ctl_data *p =3D &vcpu->arch.exit_data;
+
+	if (p->exit_reason =3D=3D EXIT_REASON_SAL_CALL) {
+		vcpu_set_gr(vcpu, 8, p->u.sal_data.ret.r8, 0);
+		vcpu_set_gr(vcpu, 9, p->u.sal_data.ret.r9, 0);
+		vcpu_set_gr(vcpu, 10, p->u.sal_data.ret.r10, 0);
+		vcpu_set_gr(vcpu, 11, p->u.sal_data.ret.r11, 0);
+	} else
+		panic_vm(vcpu);
+}
+
+void  kvm_ia64_handle_break(unsigned long ifa, struct kvm_pt_regs
*regs,
+		unsigned long isr, unsigned long iim)
+{
+	struct kvm_vcpu *v =3D current_vcpu;
+
+	if (ia64_psr(regs)->cpl =3D=3D 0) {
+		/* Allow hypercalls only when cpl =3D 0.  */
+		if (iim =3D=3D DOMN_PAL_REQUEST) {
+			set_pal_call_data(v);
+			vmm_transition(v);
+			set_pal_call_result(v);
+			vcpu_increment_iip(v);
+			return;
+		} else if (iim =3D=3D DOMN_SAL_REQUEST) {
+			set_sal_call_data(v);
+			vmm_transition(v);
+			set_sal_call_result(v);
+			vcpu_increment_iip(v);
+			return;
+		}
+	}
+	reflect_interruption(ifa, isr, iim, 11, regs);
+}
+
+void check_pending_irq(struct kvm_vcpu *vcpu)
+{
+	int  mask, h_pending, h_inservice;
+	u64 isr;
+	unsigned long  vpsr;
+	struct kvm_pt_regs *regs =3D vcpu_regs(vcpu);
+
+	h_pending =3D highest_pending_irq(vcpu);
+	if (h_pending =3D=3D NULL_VECTOR) {
+		update_vhpi(vcpu, NULL_VECTOR);
+		return;
+	}
+	h_inservice =3D highest_inservice_irq(vcpu);
+
+	vpsr =3D VCPU(vcpu, vpsr);
+	mask =3D irq_masked(vcpu, h_pending, h_inservice);
+	if ((vpsr & IA64_PSR_I) && IRQ_NO_MASKED =3D=3D mask) {
+		isr =3D vpsr & IA64_PSR_RI;
+		update_vhpi(vcpu, h_pending);
+		reflect_interruption(0, isr, 0, 12, regs); /* EXT IRQ */
+	} else if (mask =3D=3D IRQ_MASKED_BY_INSVC) {
+		if (VCPU(vcpu, vhpi))
+			update_vhpi(vcpu, NULL_VECTOR);
+	} else {
+		/* masked by vpsr.i or vtpr.*/
+		update_vhpi(vcpu, h_pending);
+	}
+}
+
+static void generate_exirq(struct kvm_vcpu *vcpu)
+{
+	unsigned  vpsr;
+	uint64_t isr;
+
+	struct kvm_pt_regs *regs =3D vcpu_regs(vcpu);
+
+	vpsr =3D VCPU(vcpu, vpsr);
+	isr =3D vpsr & IA64_PSR_RI;
+	if (!(vpsr & IA64_PSR_IC))
+		panic_vm(vcpu);
+	reflect_interruption(0, isr, 0, 12, regs); /* EXT IRQ */
+}
+
+void vhpi_detection(struct kvm_vcpu *vcpu)
+{
+	uint64_t    threshold, vhpi;
+	union ia64_tpr       vtpr;
+	struct ia64_psr vpsr;
+
+	vpsr =3D *(struct ia64_psr *)&VCPU(vcpu, vpsr);
+	vtpr.val =3D VCPU(vcpu, tpr);
+
+	threshold =3D ((!vpsr.i) << 5) | (vtpr.mmi << 4) | vtpr.mic;
+	vhpi =3D VCPU(vcpu, vhpi);
+	if (vhpi > threshold) {
+		/* interrupt actived*/
+		generate_exirq(vcpu);
+	}
+}
+
+
+void leave_hypervisor_tail(void)
+{
+	struct kvm_vcpu *v =3D current_vcpu;
+
+	if (VMX(v, timer_check)) {
+		VMX(v, timer_check) =3D 0;
+		if (VMX(v, itc_check)) {
+			if (vcpu_get_itc(v) > VCPU(v, itm)) {
+				if (!(VCPU(v, itv) & (1 << 16))) {
+					vcpu_pend_interrupt(v, VCPU(v,
itv)
+							& 0xff);
+				VMX(v, itc_check) =3D 0;
+				} else {
+					v->arch.timer_pending =3D 1;
+				}
+				VMX(v, last_itc) =3D VCPU(v, itm) + 1;
+			}
+		}
+	}
+
+	rmb();
+	if (v->arch.irq_new_pending) {
+		v->arch.irq_new_pending =3D 0;
+		VMX(v, irq_check) =3D 0;
+		check_pending_irq(v);
+		return;
+	}
+	if (VMX(v, irq_check)) {
+		VMX(v, irq_check) =3D 0;
+		vhpi_detection(v);
+	}
+}
+
+
+static inline void handle_lds(struct kvm_pt_regs *regs)
+{
+	regs->cr_ipsr |=3D IA64_PSR_ED;
+}
+
+void physical_tlb_miss(struct kvm_vcpu *vcpu, unsigned long vadr, int
type)
+{
+	unsigned long pte;
+	union ia64_rr rr;
+
+	rr.val =3D ia64_get_rr(vadr);
+	pte =3D  vadr & _PAGE_PPN_MASK;
+	pte =3D pte | PHY_PAGE_WB;
+	thash_vhpt_insert(vcpu, pte, (u64)(rr.ps << 2), vadr, type);
+	return;
+}
+
+void kvm_page_fault(u64 vadr , u64 vec, struct kvm_pt_regs *regs)
+{
+	unsigned long vpsr;
+	int type;
+
+	u64 vhpt_adr, gppa, pteval, rr, itir;
+	union ia64_isr misr;
+	union ia64_pta vpta;
+	struct thash_data *data;
+	struct kvm_vcpu *v =3D current_vcpu;
+
+	vpsr =3D VCPU(v, vpsr);
+	misr.val =3D VMX(v, cr_isr);
+
+	type =3D vec;
+
+	if (is_physical_mode(v) && (!(vadr << 1 >> 62))) {
+		if (vec =3D=3D 2) {
+			if (__gpfn_is_io((vadr << 1) >> (PAGE_SHIFT +
1))) {
+				emulate_io_inst(v, ((vadr << 1) >> 1),
4);
+				return;
+			}
+		}
+		physical_tlb_miss(v, vadr, type);
+		return;
+	}
+	data =3D vtlb_lookup(v, vadr, type);
+	if (data !=3D 0) {
+		if (type =3D=3D D_TLB) {
+			gppa =3D (vadr & ((1UL << data->ps) - 1))
+				+ (data->ppn >> (data->ps - 12) <<
data->ps);
+			if (__gpfn_is_io(gppa >> PAGE_SHIFT)) {
+				if (data->pl >=3D ((regs->cr_ipsr >>
+						IA64_PSR_CPL0_BIT) & 3))
+					emulate_io_inst(v, gppa,
data->ma);
+				else {
+					vcpu_set_isr(v, misr.val);
+					data_access_rights(v, vadr);
+				}
+				return ;
+			}
+		}
+		thash_vhpt_insert(v, data->page_flags, data->itir, vadr,
type);
+
+	} else if (type =3D=3D D_TLB) {
+		if (misr.sp) {
+			handle_lds(regs);
+			return;
+		}
+
+		rr =3D vcpu_get_rr(v, vadr);
+		itir =3D rr & (RR_RID_MASK | RR_PS_MASK);
+
+		if (!vhpt_enabled(v, vadr, misr.rs ? RSE_REF :
DATA_REF)) {
+			if (vpsr & IA64_PSR_IC) {
+				vcpu_set_isr(v, misr.val);
+				alt_dtlb(v, vadr);
+			} else {
+				nested_dtlb(v);
+			}
+			return ;
+		}
+
+		vpta.val =3D vcpu_get_pta(v);
+		/* avoid recursively walking (short format) VHPT */
+
+		vhpt_adr =3D vcpu_thash(v, vadr);
+		if (!guest_vhpt_lookup(vhpt_adr, &pteval)) {
+			/* VHPT successfully read.  */
+			if (!(pteval & _PAGE_P)) {
+				if (vpsr & IA64_PSR_IC) {
+					vcpu_set_isr(v, misr.val);
+					dtlb_fault(v, vadr);
+				} else {
+					nested_dtlb(v);
+				}
+			} else if ((pteval & _PAGE_MA_MASK) !=3D
_PAGE_MA_ST) {
+				thash_purge_and_insert(v, pteval, itir,
+								vadr,
D_TLB);
+			} else if (vpsr & IA64_PSR_IC) {
+				vcpu_set_isr(v, misr.val);
+				dtlb_fault(v, vadr);
+			} else {
+				nested_dtlb(v);
+			}
+		} else {
+			/* Can't read VHPT.  */
+			if (vpsr & IA64_PSR_IC) {
+				vcpu_set_isr(v, misr.val);
+				dvhpt_fault(v, vadr);
+			} else {
+				nested_dtlb(v);
+			}
+		}
+	} else if (type =3D=3D I_TLB) {
+		if (!(vpsr & IA64_PSR_IC))
+			misr.ni =3D 1;
+		if (!vhpt_enabled(v, vadr, INST_REF)) {
+			vcpu_set_isr(v, misr.val);
+			alt_itlb(v, vadr);
+			return;
+		}
+
+		vpta.val =3D vcpu_get_pta(v);
+
+		vhpt_adr =3D vcpu_thash(v, vadr);
+		if (!guest_vhpt_lookup(vhpt_adr, &pteval)) {
+			/* VHPT successfully read.  */
+			if (pteval & _PAGE_P) {
+				if ((pteval & _PAGE_MA_MASK) =3D=3D
_PAGE_MA_ST) {
+					vcpu_set_isr(v, misr.val);
+					itlb_fault(v, vadr);
+					return ;
+				}
+				rr =3D vcpu_get_rr(v, vadr);
+				itir =3D rr & (RR_RID_MASK | RR_PS_MASK);
+				thash_purge_and_insert(v, pteval, itir,
+							vadr, I_TLB);
+			} else {
+				vcpu_set_isr(v, misr.val);
+				inst_page_not_present(v, vadr);
+			}
+		} else {
+			vcpu_set_isr(v, misr.val);
+			ivhpt_fault(v, vadr);
+		}
+	}
+}
+
+void kvm_vexirq(struct kvm_vcpu *vcpu)
+{
+	u64 vpsr, isr;
+	struct kvm_pt_regs *regs;
+
+	regs =3D vcpu_regs(vcpu);
+	vpsr =3D VCPU(vcpu, vpsr);
+	isr =3D vpsr & IA64_PSR_RI;
+	reflect_interruption(0, isr, 0, 12, regs); /*EXT IRQ*/
+}
+
+void kvm_ia64_handle_irq(struct kvm_vcpu *v)
+{
+	struct exit_ctl_data *p =3D &v->arch.exit_data;
+	long psr;
+
+	local_irq_save(psr);
+	p->exit_reason =3D EXIT_REASON_EXTERNAL_INTERRUPT;
+	vmm_transition(v);
+	local_irq_restore(psr);
+
+	VMX(v, timer_check) =3D 1;
+
+}
+
+static void ptc_ga_remote_func(struct kvm_vcpu *v, int pos)
+{
+	u64 oldrid, moldrid, oldpsbits, vaddr;
+	struct kvm_ptc_g *p =3D &v->arch.ptc_g_data[pos];
+	vaddr =3D p->vaddr;
+
+	oldrid =3D VMX(v, vrr[0]);
+	VMX(v, vrr[0]) =3D p->rr;
+	oldpsbits =3D VMX(v, psbits[0]);
+	VMX(v, psbits[0]) =3D VMX(v, psbits[REGION_NUMBER(vaddr)]);
+	moldrid =3D ia64_get_rr(0x0);
+	ia64_set_rr(0x0, vrrtomrr(p->rr));
+	ia64_srlz_d();
+
+	vaddr =3D PAGEALIGN(vaddr, p->ps);
+	thash_purge_entries_remote(v, vaddr, p->ps);
+
+	VMX(v, vrr[0]) =3D oldrid;
+	VMX(v, psbits[0]) =3D oldpsbits;
+	ia64_set_rr(0x0, moldrid);
+	ia64_dv_serialize_data();
+}
+
+static void vcpu_do_resume(struct kvm_vcpu *vcpu)
+{
+	/*Re-init VHPT and VTLB once from resume*/
+	vcpu->arch.vhpt.num =3D VHPT_NUM_ENTRIES;
+	thash_init(&vcpu->arch.vhpt, VHPT_SHIFT);
+	vcpu->arch.vtlb.num =3D VTLB_NUM_ENTRIES;
+	thash_init(&vcpu->arch.vtlb, VTLB_SHIFT);
+
+	ia64_set_pta(vcpu->arch.vhpt.pta.val);
+}
+
+static void kvm_do_resume_op(struct kvm_vcpu *vcpu)
+{
+	if (test_and_clear_bit(KVM_REQ_RESUME, &vcpu->requests)) {
+		vcpu_do_resume(vcpu);
+		return;
+	}
+
+	if (unlikely(test_and_clear_bit(KVM_REQ_TLB_FLUSH,
&vcpu->requests))) {
+		thash_purge_all(vcpu);
+		return;
+	}
+
+	if (test_and_clear_bit(KVM_REQ_PTC_G, &vcpu->requests)) {
+		while (vcpu->arch.ptc_g_count > 0)
+			ptc_ga_remote_func(vcpu,
--vcpu->arch.ptc_g_count);
+	}
+}
+
+void vmm_transition(struct kvm_vcpu *vcpu)
+{
+	ia64_call_vsa(PAL_VPS_SAVE, (unsigned long)vcpu->arch.vpd,
+			0, 0, 0, 0, 0, 0);
+	vmm_trampoline(&vcpu->arch.guest, &vcpu->arch.host);
+	ia64_call_vsa(PAL_VPS_RESTORE, (unsigned long)vcpu->arch.vpd,
+						0, 0, 0, 0, 0, 0);
+	kvm_do_resume_op(vcpu);
+}
--=20
1.5.2

------_=_NextPart_001_01C893E6.5C0C5B0B
Content-Type: application/octet-stream;
	name="0015-KVM-IA64-Add-guest-interruption-injection-support.patch"
Content-Transfer-Encoding: base64
Content-Description: 0015-KVM-IA64-Add-guest-interruption-injection-support.patch
Content-Disposition: attachment;
	filename="0015-KVM-IA64-Add-guest-interruption-injection-support.patch"

RnJvbSA2ZmQ4MTE3MjdiOWUyMzRhNjgzYjQyZTdhZDQ2MTQyOWYwMmRkZDNmIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBYaWFudGFvIFpoYW5nIDx4aWFudGFvLnpoYW5nQGludGVsLmNv
bT4KRGF0ZTogVHVlLCAxIEFwciAyMDA4IDE0OjU4OjQyICswODAwClN1YmplY3Q6IFtQQVRDSF0g
S1ZNOklBNjQgOiBBZGQgZ3Vlc3QgaW50ZXJydXB0aW9uIGluamVjdGlvbiBzdXBwb3J0LgoKcHJv
Y2Vzcy5jIG1haW5seSBoYW5kbGUgaW50ZXJydXB0aW9uIGluamVjdGlvbiwgYW5kIHNvbWUKZmF1
bHRzIGhhbmRsaW5nLgpTaWduZWQtb2ZmLWJ5OiBBbnRob255IFh1IDxhbnRob255Lnh1QGludGVs
LmNvbT4KU2lnbmVkLW9mZi1ieTogWGlhbnRhbyBaaGFuZyA8eGlhbnRhby56aGFuZ0BpbnRlbC5j
b20+Ci0tLQogYXJjaC9pYTY0L2t2bS9wcm9jZXNzLmMgfCAgOTcwICsrKysrKysrKysrKysrKysr
KysrKysrKysrKysrKysrKysrKysrKysrKysrKysrCiAxIGZpbGVzIGNoYW5nZWQsIDk3MCBpbnNl
cnRpb25zKCspLCAwIGRlbGV0aW9ucygtKQogY3JlYXRlIG1vZGUgMTAwNjQ0IGFyY2gvaWE2NC9r
dm0vcHJvY2Vzcy5jCgpkaWZmIC0tZ2l0IGEvYXJjaC9pYTY0L2t2bS9wcm9jZXNzLmMgYi9hcmNo
L2lhNjQva3ZtL3Byb2Nlc3MuYwpuZXcgZmlsZSBtb2RlIDEwMDY0NAppbmRleCAwMDAwMDAwLi5k
NmE0NzViCi0tLSAvZGV2L251bGwKKysrIGIvYXJjaC9pYTY0L2t2bS9wcm9jZXNzLmMKQEAgLTAs
MCArMSw5NzAgQEAKKy8qCisgKiBwcm9jZXNzLmM6IGhhbmRsZSBpbnRlcnJ1cHRpb24gaW5qZWN0
IGZvciBndWVzdHMuCisgKiBDb3B5cmlnaHQgKGMpIDIwMDUsIEludGVsIENvcnBvcmF0aW9uLgor
ICoKKyAqIFRoaXMgcHJvZ3JhbSBpcyBmcmVlIHNvZnR3YXJlOyB5b3UgY2FuIHJlZGlzdHJpYnV0
ZSBpdCBhbmQvb3IgbW9kaWZ5IGl0CisgKiB1bmRlciB0aGUgdGVybXMgYW5kIGNvbmRpdGlvbnMg
b2YgdGhlIEdOVSBHZW5lcmFsIFB1YmxpYyBMaWNlbnNlLAorICogdmVyc2lvbiAyLCBhcyBwdWJs
aXNoZWQgYnkgdGhlIEZyZWUgU29mdHdhcmUgRm91bmRhdGlvbi4KKyAqCisgKiBUaGlzIHByb2dy
YW0gaXMgZGlzdHJpYnV0ZWQgaW4gdGhlIGhvcGUgaXQgd2lsbCBiZSB1c2VmdWwsIGJ1dCBXSVRI
T1VUCisgKiBBTlkgV0FSUkFOVFk7IHdpdGhvdXQgZXZlbiB0aGUgaW1wbGllZCB3YXJyYW50eSBv
ZiBNRVJDSEFOVEFCSUxJVFkgb3IKKyAqIEZJVE5FU1MgRk9SIEEgUEFSVElDVUxBUiBQVVJQT1NF
LiAgU2VlIHRoZSBHTlUgR2VuZXJhbCBQdWJsaWMgTGljZW5zZSBmb3IKKyAqIG1vcmUgZGV0YWls
cy4KKyAqCisgKiBZb3Ugc2hvdWxkIGhhdmUgcmVjZWl2ZWQgYSBjb3B5IG9mIHRoZSBHTlUgR2Vu
ZXJhbCBQdWJsaWMgTGljZW5zZSBhbG9uZyB3aXRoCisgKiB0aGlzIHByb2dyYW07IGlmIG5vdCwg
d3JpdGUgdG8gdGhlIEZyZWUgU29mdHdhcmUgRm91bmRhdGlvbiwgSW5jLiwgNTkgVGVtcGxlCisg
KiBQbGFjZSAtIFN1aXRlIDMzMCwgQm9zdG9uLCBNQSAwMjExMS0xMzA3IFVTQS4KKyAqCisgKiAg
CVNoYW9mYW4gTGkgKFN1c3VlIExpKSA8c3VzaWUubGlAaW50ZWwuY29tPgorICogIAlYaWFveWFu
IEZlbmcgKEZsZW1pbmcgRmVuZykgIDxmbGVtaW5nLmZlbmdAaW50ZWwuY29tPgorICogIAlYdWVm
ZWkgWHUgKEFudGhvbnkgWHUpIChBbnRob255Lnh1QGludGVsLmNvbSkKKyAqICAJWGlhbnRhbyBa
aGFuZyAoeGlhbnRhby56aGFuZ0BpbnRlbC5jb20pCisgKi8KKyNpbmNsdWRlICJ2Y3B1LmgiCisK
KyNpbmNsdWRlIDxhc20vcGFsLmg+CisjaW5jbHVkZSA8YXNtL3NhbC5oPgorI2luY2x1ZGUgPGFz
bS9mcHN3YS5oPgorI2luY2x1ZGUgPGFzbS9rcmVncy5oPgorI2luY2x1ZGUgPGFzbS90bGIuaD4K
KworZnBzd2FfaW50ZXJmYWNlX3QgKnZtbV9mcHN3YV9pbnRlcmZhY2U7CisKKyNkZWZpbmUgSUE2
NF9WSFBUX1RSQU5TX1ZFQ1RPUgkJCTB4MDAwMAorI2RlZmluZSBJQTY0X0lOU1RfVExCX1ZFQ1RP
UgkJCTB4MDQwMAorI2RlZmluZSBJQTY0X0RBVEFfVExCX1ZFQ1RPUgkJCTB4MDgwMAorI2RlZmlu
ZSBJQTY0X0FMVF9JTlNUX1RMQl9WRUNUT1IJCTB4MGMwMAorI2RlZmluZSBJQTY0X0FMVF9EQVRB
X1RMQl9WRUNUT1IJCTB4MTAwMAorI2RlZmluZSBJQTY0X0RBVEFfTkVTVEVEX1RMQl9WRUNUT1IJ
CTB4MTQwMAorI2RlZmluZSBJQTY0X0lOU1RfS0VZX01JU1NfVkVDVE9SCQkweDE4MDAKKyNkZWZp
bmUgSUE2NF9EQVRBX0tFWV9NSVNTX1ZFQ1RPUgkJMHgxYzAwCisjZGVmaW5lIElBNjRfRElSVFlf
QklUX1ZFQ1RPUgkJCTB4MjAwMAorI2RlZmluZSBJQTY0X0lOU1RfQUNDRVNTX0JJVF9WRUNUT1IJ
CTB4MjQwMAorI2RlZmluZSBJQTY0X0RBVEFfQUNDRVNTX0JJVF9WRUNUT1IJCTB4MjgwMAorI2Rl
ZmluZSBJQTY0X0JSRUFLX1ZFQ1RPUgkJCTB4MmMwMAorI2RlZmluZSBJQTY0X0VYVElOVF9WRUNU
T1IJCQkweDMwMDAKKyNkZWZpbmUgSUE2NF9QQUdFX05PVF9QUkVTRU5UX1ZFQ1RPUgkJMHg1MDAw
CisjZGVmaW5lIElBNjRfS0VZX1BFUk1JU1NJT05fVkVDVE9SCQkweDUxMDAKKyNkZWZpbmUgSUE2
NF9JTlNUX0FDQ0VTU19SSUdIVFNfVkVDVE9SCQkweDUyMDAKKyNkZWZpbmUgSUE2NF9EQVRBX0FD
Q0VTU19SSUdIVFNfVkVDVE9SCQkweDUzMDAKKyNkZWZpbmUgSUE2NF9HRU5FWF9WRUNUT1IJCQkw
eDU0MDAKKyNkZWZpbmUgSUE2NF9ESVNBQkxFRF9GUFJFR19WRUNUT1IJCTB4NTUwMAorI2RlZmlu
ZSBJQTY0X05BVF9DT05TVU1QVElPTl9WRUNUT1IJCTB4NTYwMAorI2RlZmluZSBJQTY0X1NQRUNV
TEFUSU9OX1ZFQ1RPUgkJMHg1NzAwIC8qIFVOVVNFRCAqLworI2RlZmluZSBJQTY0X0RFQlVHX1ZF
Q1RPUgkJCTB4NTkwMAorI2RlZmluZSBJQTY0X1VOQUxJR05FRF9SRUZfVkVDVE9SCQkweDVhMDAK
KyNkZWZpbmUgSUE2NF9VTlNVUFBPUlRFRF9EQVRBX1JFRl9WRUNUT1IJMHg1YjAwCisjZGVmaW5l
IElBNjRfRlBfRkFVTFRfVkVDVE9SCQkJMHg1YzAwCisjZGVmaW5lIElBNjRfRlBfVFJBUF9WRUNU
T1IJCQkweDVkMDAKKyNkZWZpbmUgSUE2NF9MT1dFUlBSSVZfVFJBTlNGRVJfVFJBUF9WRUNUT1Ig
CTB4NWUwMAorI2RlZmluZSBJQTY0X1RBS0VOX0JSQU5DSF9UUkFQX1ZFQ1RPUgkJMHg1ZjAwCisj
ZGVmaW5lIElBNjRfU0lOR0xFX1NURVBfVFJBUF9WRUNUT1IJCTB4NjAwMAorCisvKiBTRE0gdm9s
MiA1LjUgLSBJVkEgYmFzZWQgaW50ZXJydXB0aW9uIGhhbmRsaW5nICovCisjZGVmaW5lIElOSVRJ
QUxfUFNSX1ZBTFVFX0FUX0lOVEVSUlVQVElPTiAoSUE2NF9QU1JfVVAgfCBJQTY0X1BTUl9NRkwg
fFwKKwkJCUlBNjRfUFNSX01GSCB8IElBNjRfUFNSX1BLIHwgSUE2NF9QU1JfRFQgfCAgICAJXAor
CQkJSUE2NF9QU1JfUlQgfCBJQTY0X1BTUl9NQ3xJQTY0X1BTUl9JVCkKKworI2RlZmluZSBET01O
X1BBTF9SRVFVRVNUICAgIDB4MTEwMDAwCisjZGVmaW5lIERPTU5fU0FMX1JFUVVFU1QgICAgMHgx
MTAwMDEKKworc3RhdGljIHU2NCB2ZWMyb2ZmWzY4XSA9IHsweDAsIDB4NDAwLCAweDgwMCwgMHhj
MDAsIDB4MTAwMCwgMHgxNDAwLCAweDE4MDAsCisJMHgxYzAwLCAweDIwMDAsIDB4MjQwMCwgMHgy
ODAwLCAweDJjMDAsIDB4MzAwMCwgMHgzNDAwLCAweDM4MDAsIDB4M2MwMCwKKwkweDQwMDAsIDB4
NDQwMCwgMHg0ODAwLCAweDRjMDAsIDB4NTAwMCwgMHg1MTAwLCAweDUyMDAsIDB4NTMwMCwgMHg1
NDAwLAorCTB4NTUwMCwgMHg1NjAwLCAweDU3MDAsIDB4NTgwMCwgMHg1OTAwLCAweDVhMDAsIDB4
NWIwMCwgMHg1YzAwLCAweDVkMDAsCisJMHg1ZTAwLCAweDVmMDAsIDB4NjAwMCwgMHg2MTAwLCAw
eDYyMDAsIDB4NjMwMCwgMHg2NDAwLCAweDY1MDAsIDB4NjYwMCwKKwkweDY3MDAsIDB4NjgwMCwg
MHg2OTAwLCAweDZhMDAsIDB4NmIwMCwgMHg2YzAwLCAweDZkMDAsIDB4NmUwMCwgMHg2ZjAwLAor
CTB4NzAwMCwgMHg3MTAwLCAweDcyMDAsIDB4NzMwMCwgMHg3NDAwLCAweDc1MDAsIDB4NzYwMCwg
MHg3NzAwLCAweDc4MDAsCisJMHg3OTAwLCAweDdhMDAsIDB4N2IwMCwgMHg3YzAwLCAweDdkMDAs
IDB4N2UwMCwgMHg3ZjAwCit9OworCitzdGF0aWMgdm9pZCBjb2xsZWN0X2ludGVycnVwdGlvbihz
dHJ1Y3Qga3ZtX3ZjcHUgKnZjcHUpCit7CisJdTY0IGlwc3I7CisJdTY0IHZkY3I7CisJdTY0IHZp
ZnM7CisJdW5zaWduZWQgbG9uZyB2cHNyOworCXN0cnVjdCBrdm1fcHRfcmVncyAqcmVncyA9IHZj
cHVfcmVncyh2Y3B1KTsKKworCXZwc3IgPSB2Y3B1X2dldF9wc3IodmNwdSk7CisJdmNwdV9ic3cw
KHZjcHUpOworCWlmICh2cHNyICYgSUE2NF9QU1JfSUMpIHsKKworCQkvKiBTeW5jIG1wc3IgaWQv
ZGEvZGQvc3MvZWQgYml0cyB0byB2aXBzcgorCQkgKiBzaW5jZSBhZnRlciBndWVzdCBkbyByZmks
IHdlIHN0aWxsIHdhbnQgdGhlc2UgYml0cyBvbiBpbgorCQkgKiBtcHNyCisJCSAqLworCisJCWlw
c3IgPSByZWdzLT5jcl9pcHNyOworCQl2cHNyID0gdnBzciB8IChpcHNyICYgKElBNjRfUFNSX0lE
IHwgSUE2NF9QU1JfREEKKwkJCQkJfCBJQTY0X1BTUl9ERCB8IElBNjRfUFNSX1NTCisJCQkJCXwg
SUE2NF9QU1JfRUQpKTsKKwkJdmNwdV9zZXRfaXBzcih2Y3B1LCB2cHNyKTsKKworCQkvKiBDdXJy
ZW50bHksIGZvciB0cmFwLCB3ZSBkbyBub3QgYWR2YW5jZSBJSVAgdG8gbmV4dAorCQkgKiBpbnN0
cnVjdGlvbi4gVGhhdCdzIGJlY2F1c2Ugd2UgYXNzdW1lIGNhbGxlciBhbHJlYWR5CisJCSAqIHNl
dCB1cCBJSVAgY29ycmVjdGx5CisJCSAqLworCisJCXZjcHVfc2V0X2lpcCh2Y3B1ICwgcmVncy0+
Y3JfaWlwKTsKKworCQkvKiBzZXQgdmlmcy52IHRvIHplcm8gKi8KKwkJdmlmcyA9IFZDUFUodmNw
dSwgaWZzKTsKKwkJdmlmcyAmPSB+SUE2NF9JRlNfVjsKKwkJdmNwdV9zZXRfaWZzKHZjcHUsIHZp
ZnMpOworCisJCXZjcHVfc2V0X2lpcGEodmNwdSwgVk1YKHZjcHUsIGNyX2lpcGEpKTsKKwl9CisK
Kwl2ZGNyID0gVkNQVSh2Y3B1LCBkY3IpOworCisJLyogU2V0IGd1ZXN0IHBzcgorCSAqIHVwL21m
bC9tZmgvcGsvZHQvcnQvbWMvaXQga2VlcHMgdW5jaGFuZ2VkCisJICogYmU6IHNldCB0byB0aGUg
dmFsdWUgb2YgZGNyLmJlCisJICogcHA6IHNldCB0byB0aGUgdmFsdWUgb2YgZGNyLnBwCisJICov
CisJdnBzciAmPSBJTklUSUFMX1BTUl9WQUxVRV9BVF9JTlRFUlJVUFRJT047CisJdnBzciB8PSAo
dmRjciAmIElBNjRfRENSX0JFKTsKKworCS8qIFZEQ1IgcHAgYml0IHBvc2l0aW9uIGlzIGRpZmZl
cmVudCBmcm9tIFZQU1IgcHAgYml0ICovCisJaWYgKHZkY3IgJiBJQTY0X0RDUl9QUCkgeworCQl2
cHNyIHw9IElBNjRfUFNSX1BQOworCX0gZWxzZSB7CisJCXZwc3IgJj0gfklBNjRfUFNSX1BQOzsK
Kwl9CisKKwl2Y3B1X3NldF9wc3IodmNwdSwgdnBzcik7CisKK30KKwordm9pZCBpbmplY3RfZ3Vl
c3RfaW50ZXJydXB0aW9uKHN0cnVjdCBrdm1fdmNwdSAqdmNwdSwgdTY0IHZlYykKK3sKKwl1NjQg
dml2YTsKKwlzdHJ1Y3Qga3ZtX3B0X3JlZ3MgKnJlZ3M7CisJdW5pb24gaWE2NF9pc3IgcHRfaXNy
OworCisJcmVncyA9IHZjcHVfcmVncyh2Y3B1KTsKKworCS8qIGNsZWFyIGNyLmlzci5pciAoaW5j
b21wbGV0ZSByZWdpc3RlciBmcmFtZSkqLworCXB0X2lzci52YWwgPSBWTVgodmNwdSwgY3JfaXNy
KTsKKwlwdF9pc3IuaXIgPSAwOworCVZNWCh2Y3B1LCBjcl9pc3IpID0gcHRfaXNyLnZhbDsKKwor
CWNvbGxlY3RfaW50ZXJydXB0aW9uKHZjcHUpOworCisJdml2YSA9IHZjcHVfZ2V0X2l2YSh2Y3B1
KTsKKwlyZWdzLT5jcl9paXAgPSB2aXZhICsgdmVjOworfQorCitzdGF0aWMgdTY0IHZjcHVfZ2V0
X2l0aXJfb25fZmF1bHQoc3RydWN0IGt2bV92Y3B1ICp2Y3B1LCB1NjQgaWZhKQoreworCXVuaW9u
IGlhNjRfcnIgcnIsIHJyMTsKKworCXJyLnZhbCA9IHZjcHVfZ2V0X3JyKHZjcHUsIGlmYSk7CisJ
cnIxLnZhbCA9IDA7CisJcnIxLnBzID0gcnIucHM7CisJcnIxLnJpZCA9IHJyLnJpZDsKKwlyZXR1
cm4gKHJyMS52YWwpOworfQorCisKKy8qCisgKiBTZXQgdklGQSAmIHZJVElSICYgdklIQSwgd2hl
biB2UFNSLmljID0xCisgKiBQYXJhbWV0ZXI6CisgKiAgc2V0X2lmYTogaWYgdHJ1ZSwgc2V0IHZJ
RkEKKyAqICBzZXRfaXRpcjogaWYgdHJ1ZSwgc2V0IHZJVElSCisgKiAgc2V0X2loYTogaWYgdHJ1
ZSwgc2V0IHZJSEEKKyAqLwordm9pZCBzZXRfaWZhX2l0aXJfaWhhKHN0cnVjdCBrdm1fdmNwdSAq
dmNwdSwgdTY0IHZhZHIsCisJCWludCBzZXRfaWZhLCBpbnQgc2V0X2l0aXIsIGludCBzZXRfaWhh
KQoreworCWxvbmcgdnBzcjsKKwl1NjQgdmFsdWU7CisKKwl2cHNyID0gVkNQVSh2Y3B1LCB2cHNy
KTsKKwkvKiBWb2wyLCBUYWJsZSA4LTEgKi8KKwlpZiAodnBzciAmIElBNjRfUFNSX0lDKSB7CisJ
CWlmIChzZXRfaWZhKQorCQkJdmNwdV9zZXRfaWZhKHZjcHUsIHZhZHIpOworCQlpZiAoc2V0X2l0
aXIpIHsKKwkJCXZhbHVlID0gdmNwdV9nZXRfaXRpcl9vbl9mYXVsdCh2Y3B1LCB2YWRyKTsKKwkJ
CXZjcHVfc2V0X2l0aXIodmNwdSwgdmFsdWUpOworCQl9CisKKwkJaWYgKHNldF9paGEpIHsKKwkJ
CXZhbHVlID0gdmNwdV90aGFzaCh2Y3B1LCB2YWRyKTsKKwkJCXZjcHVfc2V0X2loYSh2Y3B1LCB2
YWx1ZSk7CisJCX0KKwl9Cit9CisKKy8qCisgKiBEYXRhIFRMQiBGYXVsdAorICogIEAgRGF0YSBU
TEIgdmVjdG9yCisgKiBSZWZlciB0byBTRE0gVm9sMiBUYWJsZSA1LTYgJiA4LTEKKyAqLwordm9p
ZCBkdGxiX2ZhdWx0KHN0cnVjdCBrdm1fdmNwdSAqdmNwdSwgdTY0IHZhZHIpCit7CisJLyogSWYg
dlBTUi5pYywgSUZBLCBJVElSLCBJSEEgKi8KKwlzZXRfaWZhX2l0aXJfaWhhKHZjcHUsIHZhZHIs
IDEsIDEsIDEpOworCWluamVjdF9ndWVzdF9pbnRlcnJ1cHRpb24odmNwdSwgSUE2NF9EQVRBX1RM
Ql9WRUNUT1IpOworfQorCisvKgorICogSW5zdHJ1Y3Rpb24gVExCIEZhdWx0CisgKiAgQCBJbnN0
cnVjdGlvbiBUTEIgdmVjdG9yCisgKiBSZWZlciB0byBTRE0gVm9sMiBUYWJsZSA1LTYgJiA4LTEK
KyAqLwordm9pZCBpdGxiX2ZhdWx0KHN0cnVjdCBrdm1fdmNwdSAqdmNwdSwgdTY0IHZhZHIpCit7
CisJLyogSWYgdlBTUi5pYywgSUZBLCBJVElSLCBJSEEgKi8KKwlzZXRfaWZhX2l0aXJfaWhhKHZj
cHUsIHZhZHIsIDEsIDEsIDEpOworCWluamVjdF9ndWVzdF9pbnRlcnJ1cHRpb24odmNwdSwgSUE2
NF9JTlNUX1RMQl9WRUNUT1IpOworfQorCisKKworLyoKKyAqIERhdGEgTmVzdGVkIFRMQiBGYXVs
dAorICogIEAgRGF0YSBOZXN0ZWQgVExCIFZlY3RvcgorICogUmVmZXIgdG8gU0RNIFZvbDIgVGFi
bGUgNS02ICYgOC0xCisgKi8KK3ZvaWQgbmVzdGVkX2R0bGIoc3RydWN0IGt2bV92Y3B1ICp2Y3B1
KQoreworCWluamVjdF9ndWVzdF9pbnRlcnJ1cHRpb24odmNwdSwgSUE2NF9EQVRBX05FU1RFRF9U
TEJfVkVDVE9SKTsKK30KKworLyoKKyAqIEFsdGVybmF0ZSBEYXRhIFRMQiBGYXVsdAorICogIEAg
QWx0ZXJuYXRlIERhdGEgVExCIHZlY3RvcgorICogUmVmZXIgdG8gU0RNIFZvbDIgVGFibGUgNS02
ICYgOC0xCisgKi8KK3ZvaWQgYWx0X2R0bGIoc3RydWN0IGt2bV92Y3B1ICp2Y3B1LCB1NjQgdmFk
cikKK3sKKwlzZXRfaWZhX2l0aXJfaWhhKHZjcHUsIHZhZHIsIDEsIDEsIDApOworCWluamVjdF9n
dWVzdF9pbnRlcnJ1cHRpb24odmNwdSwgSUE2NF9BTFRfREFUQV9UTEJfVkVDVE9SKTsKK30KKwor
CisvKgorICogRGF0YSBUTEIgRmF1bHQKKyAqICBAIERhdGEgVExCIHZlY3RvcgorICogUmVmZXIg
dG8gU0RNIFZvbDIgVGFibGUgNS02ICYgOC0xCisgKi8KK3ZvaWQgYWx0X2l0bGIoc3RydWN0IGt2
bV92Y3B1ICp2Y3B1LCB1NjQgdmFkcikKK3sKKwlzZXRfaWZhX2l0aXJfaWhhKHZjcHUsIHZhZHIs
IDEsIDEsIDApOworCWluamVjdF9ndWVzdF9pbnRlcnJ1cHRpb24odmNwdSwgSUE2NF9BTFRfSU5T
VF9UTEJfVkVDVE9SKTsKK30KKworLyogRGVhbCB3aXRoOgorICogIFZIUFQgVHJhbnNsYXRpb24g
VmVjdG9yCisgKi8KK3N0YXRpYyB2b2lkIF92aHB0X2ZhdWx0KHN0cnVjdCBrdm1fdmNwdSAqdmNw
dSwgdTY0IHZhZHIpCit7CisJLyogSWYgdlBTUi5pYywgSUZBLCBJVElSLCBJSEEqLworCXNldF9p
ZmFfaXRpcl9paGEodmNwdSwgdmFkciwgMSwgMSwgMSk7CisJaW5qZWN0X2d1ZXN0X2ludGVycnVw
dGlvbih2Y3B1LCBJQTY0X1ZIUFRfVFJBTlNfVkVDVE9SKTsKKworCit9CisKKy8qCisgKiBWSFBU
IEluc3RydWN0aW9uIEZhdWx0CisgKiAgQCBWSFBUIFRyYW5zbGF0aW9uIHZlY3RvcgorICogUmVm
ZXIgdG8gU0RNIFZvbDIgVGFibGUgNS02ICYgOC0xCisgKi8KK3ZvaWQgaXZocHRfZmF1bHQoc3Ry
dWN0IGt2bV92Y3B1ICp2Y3B1LCB1NjQgdmFkcikKK3sKKwlfdmhwdF9mYXVsdCh2Y3B1LCB2YWRy
KTsKK30KKworCisvKgorICogVkhQVCBEYXRhIEZhdWx0CisgKiAgQCBWSFBUIFRyYW5zbGF0aW9u
IHZlY3RvcgorICogUmVmZXIgdG8gU0RNIFZvbDIgVGFibGUgNS02ICYgOC0xCisgKi8KK3ZvaWQg
ZHZocHRfZmF1bHQoc3RydWN0IGt2bV92Y3B1ICp2Y3B1LCB1NjQgdmFkcikKK3sKKwlfdmhwdF9m
YXVsdCh2Y3B1LCB2YWRyKTsKK30KKworCisKKy8qCisgKiBEZWFsIHdpdGg6CisgKiAgR2VuZXJh
bCBFeGNlcHRpb24gdmVjdG9yCisgKi8KK3ZvaWQgX2dlbmVyYWxfZXhjZXB0aW9uKHN0cnVjdCBr
dm1fdmNwdSAqdmNwdSkKK3sKKwlpbmplY3RfZ3Vlc3RfaW50ZXJydXB0aW9uKHZjcHUsIElBNjRf
R0VORVhfVkVDVE9SKTsKK30KKworCisvKgorICogSWxsZWdhbCBPcGVyYXRpb24gRmF1bHQKKyAq
ICBAIEdlbmVyYWwgRXhjZXB0aW9uIFZlY3RvcgorICogUmVmZXIgdG8gU0RNIFZvbDIgVGFibGUg
NS02ICYgOC0xCisgKi8KK3ZvaWQgaWxsZWdhbF9vcChzdHJ1Y3Qga3ZtX3ZjcHUgKnZjcHUpCit7
CisJX2dlbmVyYWxfZXhjZXB0aW9uKHZjcHUpOworfQorCisvKgorICogSWxsZWdhbCBEZXBlbmRl
bmN5IEZhdWx0CisgKiAgQCBHZW5lcmFsIEV4Y2VwdGlvbiBWZWN0b3IKKyAqIFJlZmVyIHRvIFNE
TSBWb2wyIFRhYmxlIDUtNiAmIDgtMQorICovCit2b2lkIGlsbGVnYWxfZGVwKHN0cnVjdCBrdm1f
dmNwdSAqdmNwdSkKK3sKKwlfZ2VuZXJhbF9leGNlcHRpb24odmNwdSk7Cit9CisKKy8qCisgKiBS
ZXNlcnZlZCBSZWdpc3Rlci9GaWVsZCBGYXVsdAorICogIEAgR2VuZXJhbCBFeGNlcHRpb24gVmVj
dG9yCisgKiBSZWZlciB0byBTRE0gVm9sMiBUYWJsZSA1LTYgJiA4LTEKKyAqLwordm9pZCByc3Zf
cmVnX2ZpZWxkKHN0cnVjdCBrdm1fdmNwdSAqdmNwdSkKK3sKKwlfZ2VuZXJhbF9leGNlcHRpb24o
dmNwdSk7Cit9CisvKgorICogUHJpdmlsZWdlZCBPcGVyYXRpb24gRmF1bHQKKyAqICBAIEdlbmVy
YWwgRXhjZXB0aW9uIFZlY3RvcgorICogUmVmZXIgdG8gU0RNIFZvbDIgVGFibGUgNS02ICYgOC0x
CisgKi8KKwordm9pZCBwcml2aWxlZ2Vfb3Aoc3RydWN0IGt2bV92Y3B1ICp2Y3B1KQoreworCV9n
ZW5lcmFsX2V4Y2VwdGlvbih2Y3B1KTsKK30KKworLyoKKyAqIFVuaW1wbGVtZW50IERhdGEgQWRk
cmVzcyBGYXVsdAorICogIEAgR2VuZXJhbCBFeGNlcHRpb24gVmVjdG9yCisgKiBSZWZlciB0byBT
RE0gVm9sMiBUYWJsZSA1LTYgJiA4LTEKKyAqLwordm9pZCB1bmltcGxfZGFkZHIoc3RydWN0IGt2
bV92Y3B1ICp2Y3B1KQoreworCV9nZW5lcmFsX2V4Y2VwdGlvbih2Y3B1KTsKK30KKworLyoKKyAq
IFByaXZpbGVnZWQgUmVnaXN0ZXIgRmF1bHQKKyAqICBAIEdlbmVyYWwgRXhjZXB0aW9uIFZlY3Rv
cgorICogUmVmZXIgdG8gU0RNIFZvbDIgVGFibGUgNS02ICYgOC0xCisgKi8KK3ZvaWQgcHJpdmls
ZWdlX3JlZyhzdHJ1Y3Qga3ZtX3ZjcHUgKnZjcHUpCit7CisJX2dlbmVyYWxfZXhjZXB0aW9uKHZj
cHUpOworfQorCisvKiBEZWFsIHdpdGgKKyAqICBOYXQgY29uc3VtcHRpb24gdmVjdG9yCisgKiBQ
YXJhbWV0ZXI6CisgKiAgdmFkZHI6IE9wdGlvbmFsLCBpZiB0ID09IFJFR0lTVEVSCisgKi8KK3N0
YXRpYyB2b2lkIF9uYXRfY29uc3VtcHRpb25fZmF1bHQoc3RydWN0IGt2bV92Y3B1ICp2Y3B1LCB1
NjQgdmFkciwKKwkJCQkJCWVudW0gdGxiX21pc3NfdHlwZSB0KQoreworCS8qIElmIHZQU1IuaWMg
JiYgdCA9PSBEQVRBL0lOU1QsIElGQSAqLworCWlmICh0ID09IERBVEEgfHwgdCA9PSBJTlNUUlVD
VElPTikgeworCQkvKiBJRkEgKi8KKwkJc2V0X2lmYV9pdGlyX2loYSh2Y3B1LCB2YWRyLCAxLCAw
LCAwKTsKKwl9CisKKwlpbmplY3RfZ3Vlc3RfaW50ZXJydXB0aW9uKHZjcHUsIElBNjRfTkFUX0NP
TlNVTVBUSU9OX1ZFQ1RPUik7Cit9CisKKy8qCisgKiBJbnN0cnVjdGlvbiBOYXQgUGFnZSBDb25z
dW1wdGlvbiBGYXVsdAorICogIEAgTmF0IENvbnN1bXB0aW9uIFZlY3RvcgorICogUmVmZXIgdG8g
U0RNIFZvbDIgVGFibGUgNS02ICYgOC0xCisgKi8KK3ZvaWQgaW5hdF9wYWdlX2NvbnN1bXB0aW9u
KHN0cnVjdCBrdm1fdmNwdSAqdmNwdSwgdTY0IHZhZHIpCit7CisJX25hdF9jb25zdW1wdGlvbl9m
YXVsdCh2Y3B1LCB2YWRyLCBJTlNUUlVDVElPTik7Cit9CisKKy8qCisgKiBSZWdpc3RlciBOYXQg
Q29uc3VtcHRpb24gRmF1bHQKKyAqICBAIE5hdCBDb25zdW1wdGlvbiBWZWN0b3IKKyAqIFJlZmVy
IHRvIFNETSBWb2wyIFRhYmxlIDUtNiAmIDgtMQorICovCit2b2lkIHJuYXRfY29uc3VtcHRpb24o
c3RydWN0IGt2bV92Y3B1ICp2Y3B1KQoreworCV9uYXRfY29uc3VtcHRpb25fZmF1bHQodmNwdSwg
MCwgUkVHSVNURVIpOworfQorCisvKgorICogRGF0YSBOYXQgUGFnZSBDb25zdW1wdGlvbiBGYXVs
dAorICogIEAgTmF0IENvbnN1bXB0aW9uIFZlY3RvcgorICogUmVmZXIgdG8gU0RNIFZvbDIgVGFi
bGUgNS02ICYgOC0xCisgKi8KK3ZvaWQgZG5hdF9wYWdlX2NvbnN1bXB0aW9uKHN0cnVjdCBrdm1f
dmNwdSAqdmNwdSwgdTY0IHZhZHIpCit7CisJX25hdF9jb25zdW1wdGlvbl9mYXVsdCh2Y3B1LCB2
YWRyLCBEQVRBKTsKK30KKworLyogRGVhbCB3aXRoCisgKiAgUGFnZSBub3QgcHJlc2VudCB2ZWN0
b3IKKyAqLworc3RhdGljIHZvaWQgX19wYWdlX25vdF9wcmVzZW50KHN0cnVjdCBrdm1fdmNwdSAq
dmNwdSwgdTY0IHZhZHIpCit7CisJLyogSWYgdlBTUi5pYywgSUZBLCBJVElSICovCisJc2V0X2lm
YV9pdGlyX2loYSh2Y3B1LCB2YWRyLCAxLCAxLCAwKTsKKwlpbmplY3RfZ3Vlc3RfaW50ZXJydXB0
aW9uKHZjcHUsIElBNjRfUEFHRV9OT1RfUFJFU0VOVF9WRUNUT1IpOworfQorCisKK3ZvaWQgZGF0
YV9wYWdlX25vdF9wcmVzZW50KHN0cnVjdCBrdm1fdmNwdSAqdmNwdSwgdTY0IHZhZHIpCit7CisJ
X19wYWdlX25vdF9wcmVzZW50KHZjcHUsIHZhZHIpOworfQorCisKK3ZvaWQgaW5zdF9wYWdlX25v
dF9wcmVzZW50KHN0cnVjdCBrdm1fdmNwdSAqdmNwdSwgdTY0IHZhZHIpCit7CisJX19wYWdlX25v
dF9wcmVzZW50KHZjcHUsIHZhZHIpOworfQorCisKKy8qIERlYWwgd2l0aAorICogIERhdGEgYWNj
ZXNzIHJpZ2h0cyB2ZWN0b3IKKyAqLwordm9pZCBkYXRhX2FjY2Vzc19yaWdodHMoc3RydWN0IGt2
bV92Y3B1ICp2Y3B1LCB1NjQgdmFkcikKK3sKKwkvKiBJZiB2UFNSLmljLCBJRkEsIElUSVIgKi8K
KwlzZXRfaWZhX2l0aXJfaWhhKHZjcHUsIHZhZHIsIDEsIDEsIDApOworCWluamVjdF9ndWVzdF9p
bnRlcnJ1cHRpb24odmNwdSwgSUE2NF9EQVRBX0FDQ0VTU19SSUdIVFNfVkVDVE9SKTsKK30KKwor
ZnBzd2FfcmV0X3Qgdm1tX2ZwX2VtdWxhdGUoaW50IGZwX2ZhdWx0LCB2b2lkICpidW5kbGUsIHVu
c2lnbmVkIGxvbmcgKmlwc3IsCisJCXVuc2lnbmVkIGxvbmcgKmZwc3IsIHVuc2lnbmVkIGxvbmcg
KmlzciwgdW5zaWduZWQgbG9uZyAqcHIsCisJCXVuc2lnbmVkIGxvbmcgKmlmcywgc3RydWN0IGt2
bV9wdF9yZWdzICpyZWdzKQoreworCWZwX3N0YXRlX3QgZnBfc3RhdGU7CisJZnBzd2FfcmV0X3Qg
cmV0OworCXN0cnVjdCBrdm1fdmNwdSAqdmNwdSA9IGN1cnJlbnRfdmNwdTsKKworCXVpbnQ2NF90
IG9sZF9ycjcgPSBpYTY0X2dldF9ycig3VUw8PDYxKTsKKworCWlmICghdm1tX2Zwc3dhX2ludGVy
ZmFjZSkKKwkJcmV0dXJuIChmcHN3YV9yZXRfdCkgey0xLCAwLCAwLCAwfTsKKworCS8qCisJICog
SnVzdCBsZXQgZnBzd2EgZHJpdmVyIHRvIHVzZSBoYXJkd2FyZSBmcCByZWdpc3RlcnMuCisJICog
Tm8gZnAgcmVnaXN0ZXIgaXMgdmFsaWQgaW4gbWVtb3J5LgorCSAqLworCW1lbXNldCgmZnBfc3Rh
dGUsIDAsIHNpemVvZihmcF9zdGF0ZV90KSk7CisKKwkvKgorCSAqIHVuc2lnbmVkIGxvbmcgKCpF
RklfRlBTV0EpICgKKwkgKiAgICAgIHVuc2lnbmVkIGxvbmcgICAgdHJhcF90eXBlLAorCSAqICAg
ICAgdm9pZCAgICAgICAgICAgICAqQnVuZGxlLAorCSAqICAgICAgdW5zaWduZWQgbG9uZyAgICAq
cGlwc3IsCisJICogICAgICB1bnNpZ25lZCBsb25nICAgICpwZnNyLAorCSAqICAgICAgdW5zaWdu
ZWQgbG9uZyAgICAqcGlzciwKKwkgKiAgICAgIHVuc2lnbmVkIGxvbmcgICAgKnBwcmVkcywKKwkg
KiAgICAgIHVuc2lnbmVkIGxvbmcgICAgKnBpZnMsCisJICogICAgICB2b2lkICAgICAgICAgICAg
ICpmcF9zdGF0ZSk7CisJICovCisJLypDYWxsIGhvc3QgZnBzd2EgaW50ZXJmYWNlIGRpcmVjdGx5
IHRvIHZpcnR1YWxpemUKKwkgKmd1ZXN0IGZwc3dhIHJlcXVlc3QhCisJICovCisJaWE2NF9zZXRf
cnIoN1VMIDw8IDYxLCB2Y3B1LT5hcmNoLmhvc3QucnJbN10pOworCWlhNjRfc3Jsel9kKCk7CisK
KwlyZXQgPSAoKnZtbV9mcHN3YV9pbnRlcmZhY2UtPmZwc3dhKSAoZnBfZmF1bHQsIGJ1bmRsZSwK
KwkJCWlwc3IsIGZwc3IsIGlzciwgcHIsIGlmcywgJmZwX3N0YXRlKTsKKwlpYTY0X3NldF9ycig3
VUwgPDwgNjEsIG9sZF9ycjcpOworCWlhNjRfc3Jsel9kKCk7CisJcmV0dXJuIHJldDsKK30KKwor
LyoKKyAqIEhhbmRsZSBmbG9hdGluZy1wb2ludCBhc3Npc3QgZmF1bHRzIGFuZCB0cmFwcyBmb3Ig
ZG9tYWluLgorICovCit1bnNpZ25lZCBsb25nIHZtbV9oYW5kbGVfZnB1X3N3YShpbnQgZnBfZmF1
bHQsIHN0cnVjdCBrdm1fcHRfcmVncyAqcmVncywKKwkJCQkJdW5zaWduZWQgbG9uZyBpc3IpCit7
CisJc3RydWN0IGt2bV92Y3B1ICp2ID0gY3VycmVudF92Y3B1OworCUlBNjRfQlVORExFIGJ1bmRs
ZTsKKwl1bnNpZ25lZCBsb25nIGZhdWx0X2lwOworCWZwc3dhX3JldF90IHJldDsKKworCWZhdWx0
X2lwID0gcmVncy0+Y3JfaWlwOworCS8qCisJICogV2hlbiB0aGUgRlAgdHJhcCBvY2N1cnMsIHRo
ZSB0cmFwcGluZyBpbnN0cnVjdGlvbiBpcyBjb21wbGV0ZWQuCisJICogSWYgaXBzci5yaSA9PSAw
LCB0aGVyZSBpcyB0aGUgdHJhcHBpbmcgaW5zdHJ1Y3Rpb24gaW4gcHJldmlvdXMKKwkgKiBidW5k
bGUuCisJICovCisJaWYgKCFmcF9mYXVsdCAmJiAoaWE2NF9wc3IocmVncyktPnJpID09IDApKQor
CQlmYXVsdF9pcCAtPSAxNjsKKworCWlmIChmZXRjaF9jb2RlKHYsIGZhdWx0X2lwLCAmYnVuZGxl
KSkKKwkJcmV0dXJuIC1FQUdBSU47CisKKwlpZiAoIWJ1bmRsZS5pNjRbMF0gJiYgIWJ1bmRsZS5p
NjRbMV0pCisJCXJldHVybiAtRUFDQ0VTOworCisJcmV0ID0gdm1tX2ZwX2VtdWxhdGUoZnBfZmF1
bHQsICZidW5kbGUsICZyZWdzLT5jcl9pcHNyLCAmcmVncy0+YXJfZnBzciwKKwkJCSZpc3IsICZy
ZWdzLT5wciwgJnJlZ3MtPmNyX2lmcywgcmVncyk7CisJcmV0dXJuIHJldC5zdGF0dXM7Cit9CisK
K3ZvaWQgcmVmbGVjdF9pbnRlcnJ1cHRpb24odTY0IGlmYSwgdTY0IGlzciwgdTY0IGlpbSwKKwkJ
dTY0IHZlYywgc3RydWN0IGt2bV9wdF9yZWdzICpyZWdzKQoreworCXU2NCB2ZWN0b3I7CisJaW50
IHN0YXR1cyA7CisJc3RydWN0IGt2bV92Y3B1ICp2Y3B1ID0gY3VycmVudF92Y3B1OworCXU2NCB2
cHNyID0gVkNQVSh2Y3B1LCB2cHNyKTsKKworCXZlY3RvciA9IHZlYzJvZmZbdmVjXTsKKworCWlm
ICghKHZwc3IgJiBJQTY0X1BTUl9JQykgJiYgKHZlY3RvciAhPSBJQTY0X0RBVEFfTkVTVEVEX1RM
Ql9WRUNUT1IpKSB7CisJCXBhbmljX3ZtKHZjcHUpOworCQlyZXR1cm47CisJfQorCisJc3dpdGNo
ICh2ZWMpIHsKKwljYXNlIDMyOiAJLypJQTY0X0ZQX0ZBVUxUX1ZFQ1RPUiovCisJCXN0YXR1cyA9
IHZtbV9oYW5kbGVfZnB1X3N3YSgxLCByZWdzLCBpc3IpOworCQlpZiAoIXN0YXR1cykgeworCQkJ
dmNwdV9pbmNyZW1lbnRfaWlwKHZjcHUpOworCQkJcmV0dXJuOworCQl9IGVsc2UgaWYgKC1FQUdB
SU4gPT0gc3RhdHVzKQorCQkJcmV0dXJuOworCQlicmVhazsKKwljYXNlIDMzOgkvKklBNjRfRlBf
VFJBUF9WRUNUT1IqLworCQlzdGF0dXMgPSB2bW1faGFuZGxlX2ZwdV9zd2EoMCwgcmVncywgaXNy
KTsKKwkJaWYgKCFzdGF0dXMpCisJCQlyZXR1cm4gOworCQllbHNlIGlmICgtRUFHQUlOID09IHN0
YXR1cykgeworCQkJdmNwdV9kZWNyZW1lbnRfaWlwKHZjcHUpOworCQkJcmV0dXJuIDsKKwkJfQor
CQlicmVhazsKKwl9CisKKwlWQ1BVKHZjcHUsIGlzcikgPSBpc3I7CisJVkNQVSh2Y3B1LCBpaXBh
KSA9IHJlZ3MtPmNyX2lpcDsKKwlpZiAodmVjdG9yID09IElBNjRfQlJFQUtfVkVDVE9SIHx8IHZl
Y3RvciA9PSBJQTY0X1NQRUNVTEFUSU9OX1ZFQ1RPUikKKwkJVkNQVSh2Y3B1LCBpaW0pID0gaWlt
OworCWVsc2UKKwkJc2V0X2lmYV9pdGlyX2loYSh2Y3B1LCBpZmEsIDEsIDEsIDEpOworCisJaW5q
ZWN0X2d1ZXN0X2ludGVycnVwdGlvbih2Y3B1LCB2ZWN0b3IpOworfQorCitzdGF0aWMgdm9pZCBz
ZXRfcGFsX2NhbGxfZGF0YShzdHJ1Y3Qga3ZtX3ZjcHUgKnZjcHUpCit7CisJc3RydWN0IGV4aXRf
Y3RsX2RhdGEgKnAgPSAmdmNwdS0+YXJjaC5leGl0X2RhdGE7CisKKwkvKkZJWE1FOkZvciBzdGF0
aWMgYW5kIHN0YWNrZWQgY29udmVudGlvbiwgZmlybXdhcmUKKwkgKiBoYXMgcHV0IHRoZSBwYXJh
bWV0ZXJzIGluIGdyMjgtZ3IzMSBiZWZvcmUKKwkgKiBicmVhayB0byB2bW0gICEhKi8KKworCXAt
PnUucGFsX2RhdGEuZ3IyOCA9IHZjcHVfZ2V0X2dyKHZjcHUsIDI4KTsKKwlwLT51LnBhbF9kYXRh
LmdyMjkgPSB2Y3B1X2dldF9ncih2Y3B1LCAyOSk7CisJcC0+dS5wYWxfZGF0YS5ncjMwID0gdmNw
dV9nZXRfZ3IodmNwdSwgMzApOworCXAtPnUucGFsX2RhdGEuZ3IzMSA9IHZjcHVfZ2V0X2dyKHZj
cHUsIDMxKTsKKwlwLT5leGl0X3JlYXNvbiA9IEVYSVRfUkVBU09OX1BBTF9DQUxMOworfQorCitz
dGF0aWMgdm9pZCBzZXRfcGFsX2NhbGxfcmVzdWx0KHN0cnVjdCBrdm1fdmNwdSAqdmNwdSkKK3sK
KwlzdHJ1Y3QgZXhpdF9jdGxfZGF0YSAqcCA9ICZ2Y3B1LT5hcmNoLmV4aXRfZGF0YTsKKworCWlm
IChwLT5leGl0X3JlYXNvbiA9PSBFWElUX1JFQVNPTl9QQUxfQ0FMTCkgeworCQl2Y3B1X3NldF9n
cih2Y3B1LCA4LCBwLT51LnBhbF9kYXRhLnJldC5zdGF0dXMsIDApOworCQl2Y3B1X3NldF9ncih2
Y3B1LCA5LCBwLT51LnBhbF9kYXRhLnJldC52MCwgMCk7CisJCXZjcHVfc2V0X2dyKHZjcHUsIDEw
LCBwLT51LnBhbF9kYXRhLnJldC52MSwgMCk7CisJCXZjcHVfc2V0X2dyKHZjcHUsIDExLCBwLT51
LnBhbF9kYXRhLnJldC52MiwgMCk7CisJfSBlbHNlCisJCXBhbmljX3ZtKHZjcHUpOworfQorCitz
dGF0aWMgdm9pZCBzZXRfc2FsX2NhbGxfZGF0YShzdHJ1Y3Qga3ZtX3ZjcHUgKnZjcHUpCit7CisJ
c3RydWN0IGV4aXRfY3RsX2RhdGEgKnAgPSAmdmNwdS0+YXJjaC5leGl0X2RhdGE7CisKKwlwLT51
LnNhbF9kYXRhLmluMCA9IHZjcHVfZ2V0X2dyKHZjcHUsIDMyKTsKKwlwLT51LnNhbF9kYXRhLmlu
MSA9IHZjcHVfZ2V0X2dyKHZjcHUsIDMzKTsKKwlwLT51LnNhbF9kYXRhLmluMiA9IHZjcHVfZ2V0
X2dyKHZjcHUsIDM0KTsKKwlwLT51LnNhbF9kYXRhLmluMyA9IHZjcHVfZ2V0X2dyKHZjcHUsIDM1
KTsKKwlwLT51LnNhbF9kYXRhLmluNCA9IHZjcHVfZ2V0X2dyKHZjcHUsIDM2KTsKKwlwLT51LnNh
bF9kYXRhLmluNSA9IHZjcHVfZ2V0X2dyKHZjcHUsIDM3KTsKKwlwLT51LnNhbF9kYXRhLmluNiA9
IHZjcHVfZ2V0X2dyKHZjcHUsIDM4KTsKKwlwLT51LnNhbF9kYXRhLmluNyA9IHZjcHVfZ2V0X2dy
KHZjcHUsIDM5KTsKKwlwLT5leGl0X3JlYXNvbiA9IEVYSVRfUkVBU09OX1NBTF9DQUxMOworfQor
CitzdGF0aWMgdm9pZCBzZXRfc2FsX2NhbGxfcmVzdWx0KHN0cnVjdCBrdm1fdmNwdSAqdmNwdSkK
K3sKKwlzdHJ1Y3QgZXhpdF9jdGxfZGF0YSAqcCA9ICZ2Y3B1LT5hcmNoLmV4aXRfZGF0YTsKKwor
CWlmIChwLT5leGl0X3JlYXNvbiA9PSBFWElUX1JFQVNPTl9TQUxfQ0FMTCkgeworCQl2Y3B1X3Nl
dF9ncih2Y3B1LCA4LCBwLT51LnNhbF9kYXRhLnJldC5yOCwgMCk7CisJCXZjcHVfc2V0X2dyKHZj
cHUsIDksIHAtPnUuc2FsX2RhdGEucmV0LnI5LCAwKTsKKwkJdmNwdV9zZXRfZ3IodmNwdSwgMTAs
IHAtPnUuc2FsX2RhdGEucmV0LnIxMCwgMCk7CisJCXZjcHVfc2V0X2dyKHZjcHUsIDExLCBwLT51
LnNhbF9kYXRhLnJldC5yMTEsIDApOworCX0gZWxzZQorCQlwYW5pY192bSh2Y3B1KTsKK30KKwor
dm9pZCAga3ZtX2lhNjRfaGFuZGxlX2JyZWFrKHVuc2lnbmVkIGxvbmcgaWZhLCBzdHJ1Y3Qga3Zt
X3B0X3JlZ3MgKnJlZ3MsCisJCXVuc2lnbmVkIGxvbmcgaXNyLCB1bnNpZ25lZCBsb25nIGlpbSkK
K3sKKwlzdHJ1Y3Qga3ZtX3ZjcHUgKnYgPSBjdXJyZW50X3ZjcHU7CisKKwlpZiAoaWE2NF9wc3Io
cmVncyktPmNwbCA9PSAwKSB7CisJCS8qIEFsbG93IGh5cGVyY2FsbHMgb25seSB3aGVuIGNwbCA9
IDAuICAqLworCQlpZiAoaWltID09IERPTU5fUEFMX1JFUVVFU1QpIHsKKwkJCXNldF9wYWxfY2Fs
bF9kYXRhKHYpOworCQkJdm1tX3RyYW5zaXRpb24odik7CisJCQlzZXRfcGFsX2NhbGxfcmVzdWx0
KHYpOworCQkJdmNwdV9pbmNyZW1lbnRfaWlwKHYpOworCQkJcmV0dXJuOworCQl9IGVsc2UgaWYg
KGlpbSA9PSBET01OX1NBTF9SRVFVRVNUKSB7CisJCQlzZXRfc2FsX2NhbGxfZGF0YSh2KTsKKwkJ
CXZtbV90cmFuc2l0aW9uKHYpOworCQkJc2V0X3NhbF9jYWxsX3Jlc3VsdCh2KTsKKwkJCXZjcHVf
aW5jcmVtZW50X2lpcCh2KTsKKwkJCXJldHVybjsKKwkJfQorCX0KKwlyZWZsZWN0X2ludGVycnVw
dGlvbihpZmEsIGlzciwgaWltLCAxMSwgcmVncyk7Cit9CisKK3ZvaWQgY2hlY2tfcGVuZGluZ19p
cnEoc3RydWN0IGt2bV92Y3B1ICp2Y3B1KQoreworCWludCAgbWFzaywgaF9wZW5kaW5nLCBoX2lu
c2VydmljZTsKKwl1NjQgaXNyOworCXVuc2lnbmVkIGxvbmcgIHZwc3I7CisJc3RydWN0IGt2bV9w
dF9yZWdzICpyZWdzID0gdmNwdV9yZWdzKHZjcHUpOworCisJaF9wZW5kaW5nID0gaGlnaGVzdF9w
ZW5kaW5nX2lycSh2Y3B1KTsKKwlpZiAoaF9wZW5kaW5nID09IE5VTExfVkVDVE9SKSB7CisJCXVw
ZGF0ZV92aHBpKHZjcHUsIE5VTExfVkVDVE9SKTsKKwkJcmV0dXJuOworCX0KKwloX2luc2Vydmlj
ZSA9IGhpZ2hlc3RfaW5zZXJ2aWNlX2lycSh2Y3B1KTsKKworCXZwc3IgPSBWQ1BVKHZjcHUsIHZw
c3IpOworCW1hc2sgPSBpcnFfbWFza2VkKHZjcHUsIGhfcGVuZGluZywgaF9pbnNlcnZpY2UpOwor
CWlmICgodnBzciAmIElBNjRfUFNSX0kpICYmIElSUV9OT19NQVNLRUQgPT0gbWFzaykgeworCQlp
c3IgPSB2cHNyICYgSUE2NF9QU1JfUkk7CisJCXVwZGF0ZV92aHBpKHZjcHUsIGhfcGVuZGluZyk7
CisJCXJlZmxlY3RfaW50ZXJydXB0aW9uKDAsIGlzciwgMCwgMTIsIHJlZ3MpOyAvKiBFWFQgSVJR
ICovCisJfSBlbHNlIGlmIChtYXNrID09IElSUV9NQVNLRURfQllfSU5TVkMpIHsKKwkJaWYgKFZD
UFUodmNwdSwgdmhwaSkpCisJCQl1cGRhdGVfdmhwaSh2Y3B1LCBOVUxMX1ZFQ1RPUik7CisJfSBl
bHNlIHsKKwkJLyogbWFza2VkIGJ5IHZwc3IuaSBvciB2dHByLiovCisJCXVwZGF0ZV92aHBpKHZj
cHUsIGhfcGVuZGluZyk7CisJfQorfQorCitzdGF0aWMgdm9pZCBnZW5lcmF0ZV9leGlycShzdHJ1
Y3Qga3ZtX3ZjcHUgKnZjcHUpCit7CisJdW5zaWduZWQgIHZwc3I7CisJdWludDY0X3QgaXNyOwor
CisJc3RydWN0IGt2bV9wdF9yZWdzICpyZWdzID0gdmNwdV9yZWdzKHZjcHUpOworCisJdnBzciA9
IFZDUFUodmNwdSwgdnBzcik7CisJaXNyID0gdnBzciAmIElBNjRfUFNSX1JJOworCWlmICghKHZw
c3IgJiBJQTY0X1BTUl9JQykpCisJCXBhbmljX3ZtKHZjcHUpOworCXJlZmxlY3RfaW50ZXJydXB0
aW9uKDAsIGlzciwgMCwgMTIsIHJlZ3MpOyAvKiBFWFQgSVJRICovCit9CisKK3ZvaWQgdmhwaV9k
ZXRlY3Rpb24oc3RydWN0IGt2bV92Y3B1ICp2Y3B1KQoreworCXVpbnQ2NF90ICAgIHRocmVzaG9s
ZCwgdmhwaTsKKwl1bmlvbiBpYTY0X3RwciAgICAgICB2dHByOworCXN0cnVjdCBpYTY0X3BzciB2
cHNyOworCisJdnBzciA9ICooc3RydWN0IGlhNjRfcHNyICopJlZDUFUodmNwdSwgdnBzcik7CisJ
dnRwci52YWwgPSBWQ1BVKHZjcHUsIHRwcik7CisKKwl0aHJlc2hvbGQgPSAoKCF2cHNyLmkpIDw8
IDUpIHwgKHZ0cHIubW1pIDw8IDQpIHwgdnRwci5taWM7CisJdmhwaSA9IFZDUFUodmNwdSwgdmhw
aSk7CisJaWYgKHZocGkgPiB0aHJlc2hvbGQpIHsKKwkJLyogaW50ZXJydXB0IGFjdGl2ZWQqLwor
CQlnZW5lcmF0ZV9leGlycSh2Y3B1KTsKKwl9Cit9CisKKwordm9pZCBsZWF2ZV9oeXBlcnZpc29y
X3RhaWwodm9pZCkKK3sKKwlzdHJ1Y3Qga3ZtX3ZjcHUgKnYgPSBjdXJyZW50X3ZjcHU7CisKKwlp
ZiAoVk1YKHYsIHRpbWVyX2NoZWNrKSkgeworCQlWTVgodiwgdGltZXJfY2hlY2spID0gMDsKKwkJ
aWYgKFZNWCh2LCBpdGNfY2hlY2spKSB7CisJCQlpZiAodmNwdV9nZXRfaXRjKHYpID4gVkNQVSh2
LCBpdG0pKSB7CisJCQkJaWYgKCEoVkNQVSh2LCBpdHYpICYgKDEgPDwgMTYpKSkgeworCQkJCQl2
Y3B1X3BlbmRfaW50ZXJydXB0KHYsIFZDUFUodiwgaXR2KQorCQkJCQkJCSYgMHhmZik7CisJCQkJ
Vk1YKHYsIGl0Y19jaGVjaykgPSAwOworCQkJCX0gZWxzZSB7CisJCQkJCXYtPmFyY2gudGltZXJf
cGVuZGluZyA9IDE7CisJCQkJfQorCQkJCVZNWCh2LCBsYXN0X2l0YykgPSBWQ1BVKHYsIGl0bSkg
KyAxOworCQkJfQorCQl9CisJfQorCisJcm1iKCk7CisJaWYgKHYtPmFyY2guaXJxX25ld19wZW5k
aW5nKSB7CisJCXYtPmFyY2guaXJxX25ld19wZW5kaW5nID0gMDsKKwkJVk1YKHYsIGlycV9jaGVj
aykgPSAwOworCQljaGVja19wZW5kaW5nX2lycSh2KTsKKwkJcmV0dXJuOworCX0KKwlpZiAoVk1Y
KHYsIGlycV9jaGVjaykpIHsKKwkJVk1YKHYsIGlycV9jaGVjaykgPSAwOworCQl2aHBpX2RldGVj
dGlvbih2KTsKKwl9Cit9CisKKworc3RhdGljIGlubGluZSB2b2lkIGhhbmRsZV9sZHMoc3RydWN0
IGt2bV9wdF9yZWdzICpyZWdzKQoreworCXJlZ3MtPmNyX2lwc3IgfD0gSUE2NF9QU1JfRUQ7Cit9
CisKK3ZvaWQgcGh5c2ljYWxfdGxiX21pc3Moc3RydWN0IGt2bV92Y3B1ICp2Y3B1LCB1bnNpZ25l
ZCBsb25nIHZhZHIsIGludCB0eXBlKQoreworCXVuc2lnbmVkIGxvbmcgcHRlOworCXVuaW9uIGlh
NjRfcnIgcnI7CisKKwlyci52YWwgPSBpYTY0X2dldF9ycih2YWRyKTsKKwlwdGUgPSAgdmFkciAm
IF9QQUdFX1BQTl9NQVNLOworCXB0ZSA9IHB0ZSB8IFBIWV9QQUdFX1dCOworCXRoYXNoX3ZocHRf
aW5zZXJ0KHZjcHUsIHB0ZSwgKHU2NCkocnIucHMgPDwgMiksIHZhZHIsIHR5cGUpOworCXJldHVy
bjsKK30KKwordm9pZCBrdm1fcGFnZV9mYXVsdCh1NjQgdmFkciAsIHU2NCB2ZWMsIHN0cnVjdCBr
dm1fcHRfcmVncyAqcmVncykKK3sKKwl1bnNpZ25lZCBsb25nIHZwc3I7CisJaW50IHR5cGU7CisK
Kwl1NjQgdmhwdF9hZHIsIGdwcGEsIHB0ZXZhbCwgcnIsIGl0aXI7CisJdW5pb24gaWE2NF9pc3Ig
bWlzcjsKKwl1bmlvbiBpYTY0X3B0YSB2cHRhOworCXN0cnVjdCB0aGFzaF9kYXRhICpkYXRhOwor
CXN0cnVjdCBrdm1fdmNwdSAqdiA9IGN1cnJlbnRfdmNwdTsKKworCXZwc3IgPSBWQ1BVKHYsIHZw
c3IpOworCW1pc3IudmFsID0gVk1YKHYsIGNyX2lzcik7CisKKwl0eXBlID0gdmVjOworCisJaWYg
KGlzX3BoeXNpY2FsX21vZGUodikgJiYgKCEodmFkciA8PCAxID4+IDYyKSkpIHsKKwkJaWYgKHZl
YyA9PSAyKSB7CisJCQlpZiAoX19ncGZuX2lzX2lvKCh2YWRyIDw8IDEpID4+IChQQUdFX1NISUZU
ICsgMSkpKSB7CisJCQkJZW11bGF0ZV9pb19pbnN0KHYsICgodmFkciA8PCAxKSA+PiAxKSwgNCk7
CisJCQkJcmV0dXJuOworCQkJfQorCQl9CisJCXBoeXNpY2FsX3RsYl9taXNzKHYsIHZhZHIsIHR5
cGUpOworCQlyZXR1cm47CisJfQorCWRhdGEgPSB2dGxiX2xvb2t1cCh2LCB2YWRyLCB0eXBlKTsK
KwlpZiAoZGF0YSAhPSAwKSB7CisJCWlmICh0eXBlID09IERfVExCKSB7CisJCQlncHBhID0gKHZh
ZHIgJiAoKDFVTCA8PCBkYXRhLT5wcykgLSAxKSkKKwkJCQkrIChkYXRhLT5wcG4gPj4gKGRhdGEt
PnBzIC0gMTIpIDw8IGRhdGEtPnBzKTsKKwkJCWlmIChfX2dwZm5faXNfaW8oZ3BwYSA+PiBQQUdF
X1NISUZUKSkgeworCQkJCWlmIChkYXRhLT5wbCA+PSAoKHJlZ3MtPmNyX2lwc3IgPj4KKwkJCQkJ
CUlBNjRfUFNSX0NQTDBfQklUKSAmIDMpKQorCQkJCQllbXVsYXRlX2lvX2luc3QodiwgZ3BwYSwg
ZGF0YS0+bWEpOworCQkJCWVsc2UgeworCQkJCQl2Y3B1X3NldF9pc3IodiwgbWlzci52YWwpOwor
CQkJCQlkYXRhX2FjY2Vzc19yaWdodHModiwgdmFkcik7CisJCQkJfQorCQkJCXJldHVybiA7CisJ
CQl9CisJCX0KKwkJdGhhc2hfdmhwdF9pbnNlcnQodiwgZGF0YS0+cGFnZV9mbGFncywgZGF0YS0+
aXRpciwgdmFkciwgdHlwZSk7CisKKwl9IGVsc2UgaWYgKHR5cGUgPT0gRF9UTEIpIHsKKwkJaWYg
KG1pc3Iuc3ApIHsKKwkJCWhhbmRsZV9sZHMocmVncyk7CisJCQlyZXR1cm47CisJCX0KKworCQly
ciA9IHZjcHVfZ2V0X3JyKHYsIHZhZHIpOworCQlpdGlyID0gcnIgJiAoUlJfUklEX01BU0sgfCBS
Ul9QU19NQVNLKTsKKworCQlpZiAoIXZocHRfZW5hYmxlZCh2LCB2YWRyLCBtaXNyLnJzID8gUlNF
X1JFRiA6IERBVEFfUkVGKSkgeworCQkJaWYgKHZwc3IgJiBJQTY0X1BTUl9JQykgeworCQkJCXZj
cHVfc2V0X2lzcih2LCBtaXNyLnZhbCk7CisJCQkJYWx0X2R0bGIodiwgdmFkcik7CisJCQl9IGVs
c2UgeworCQkJCW5lc3RlZF9kdGxiKHYpOworCQkJfQorCQkJcmV0dXJuIDsKKwkJfQorCisJCXZw
dGEudmFsID0gdmNwdV9nZXRfcHRhKHYpOworCQkvKiBhdm9pZCByZWN1cnNpdmVseSB3YWxraW5n
IChzaG9ydCBmb3JtYXQpIFZIUFQgKi8KKworCQl2aHB0X2FkciA9IHZjcHVfdGhhc2godiwgdmFk
cik7CisJCWlmICghZ3Vlc3RfdmhwdF9sb29rdXAodmhwdF9hZHIsICZwdGV2YWwpKSB7CisJCQkv
KiBWSFBUIHN1Y2Nlc3NmdWxseSByZWFkLiAgKi8KKwkJCWlmICghKHB0ZXZhbCAmIF9QQUdFX1Ap
KSB7CisJCQkJaWYgKHZwc3IgJiBJQTY0X1BTUl9JQykgeworCQkJCQl2Y3B1X3NldF9pc3Iodiwg
bWlzci52YWwpOworCQkJCQlkdGxiX2ZhdWx0KHYsIHZhZHIpOworCQkJCX0gZWxzZSB7CisJCQkJ
CW5lc3RlZF9kdGxiKHYpOworCQkJCX0KKwkJCX0gZWxzZSBpZiAoKHB0ZXZhbCAmIF9QQUdFX01B
X01BU0spICE9IF9QQUdFX01BX1NUKSB7CisJCQkJdGhhc2hfcHVyZ2VfYW5kX2luc2VydCh2LCBw
dGV2YWwsIGl0aXIsCisJCQkJCQkJCXZhZHIsIERfVExCKTsKKwkJCX0gZWxzZSBpZiAodnBzciAm
IElBNjRfUFNSX0lDKSB7CisJCQkJdmNwdV9zZXRfaXNyKHYsIG1pc3IudmFsKTsKKwkJCQlkdGxi
X2ZhdWx0KHYsIHZhZHIpOworCQkJfSBlbHNlIHsKKwkJCQluZXN0ZWRfZHRsYih2KTsKKwkJCX0K
KwkJfSBlbHNlIHsKKwkJCS8qIENhbid0IHJlYWQgVkhQVC4gICovCisJCQlpZiAodnBzciAmIElB
NjRfUFNSX0lDKSB7CisJCQkJdmNwdV9zZXRfaXNyKHYsIG1pc3IudmFsKTsKKwkJCQlkdmhwdF9m
YXVsdCh2LCB2YWRyKTsKKwkJCX0gZWxzZSB7CisJCQkJbmVzdGVkX2R0bGIodik7CisJCQl9CisJ
CX0KKwl9IGVsc2UgaWYgKHR5cGUgPT0gSV9UTEIpIHsKKwkJaWYgKCEodnBzciAmIElBNjRfUFNS
X0lDKSkKKwkJCW1pc3IubmkgPSAxOworCQlpZiAoIXZocHRfZW5hYmxlZCh2LCB2YWRyLCBJTlNU
X1JFRikpIHsKKwkJCXZjcHVfc2V0X2lzcih2LCBtaXNyLnZhbCk7CisJCQlhbHRfaXRsYih2LCB2
YWRyKTsKKwkJCXJldHVybjsKKwkJfQorCisJCXZwdGEudmFsID0gdmNwdV9nZXRfcHRhKHYpOwor
CisJCXZocHRfYWRyID0gdmNwdV90aGFzaCh2LCB2YWRyKTsKKwkJaWYgKCFndWVzdF92aHB0X2xv
b2t1cCh2aHB0X2FkciwgJnB0ZXZhbCkpIHsKKwkJCS8qIFZIUFQgc3VjY2Vzc2Z1bGx5IHJlYWQu
ICAqLworCQkJaWYgKHB0ZXZhbCAmIF9QQUdFX1ApIHsKKwkJCQlpZiAoKHB0ZXZhbCAmIF9QQUdF
X01BX01BU0spID09IF9QQUdFX01BX1NUKSB7CisJCQkJCXZjcHVfc2V0X2lzcih2LCBtaXNyLnZh
bCk7CisJCQkJCWl0bGJfZmF1bHQodiwgdmFkcik7CisJCQkJCXJldHVybiA7CisJCQkJfQorCQkJ
CXJyID0gdmNwdV9nZXRfcnIodiwgdmFkcik7CisJCQkJaXRpciA9IHJyICYgKFJSX1JJRF9NQVNL
IHwgUlJfUFNfTUFTSyk7CisJCQkJdGhhc2hfcHVyZ2VfYW5kX2luc2VydCh2LCBwdGV2YWwsIGl0
aXIsCisJCQkJCQkJdmFkciwgSV9UTEIpOworCQkJfSBlbHNlIHsKKwkJCQl2Y3B1X3NldF9pc3Io
diwgbWlzci52YWwpOworCQkJCWluc3RfcGFnZV9ub3RfcHJlc2VudCh2LCB2YWRyKTsKKwkJCX0K
KwkJfSBlbHNlIHsKKwkJCXZjcHVfc2V0X2lzcih2LCBtaXNyLnZhbCk7CisJCQlpdmhwdF9mYXVs
dCh2LCB2YWRyKTsKKwkJfQorCX0KK30KKwordm9pZCBrdm1fdmV4aXJxKHN0cnVjdCBrdm1fdmNw
dSAqdmNwdSkKK3sKKwl1NjQgdnBzciwgaXNyOworCXN0cnVjdCBrdm1fcHRfcmVncyAqcmVnczsK
KworCXJlZ3MgPSB2Y3B1X3JlZ3ModmNwdSk7CisJdnBzciA9IFZDUFUodmNwdSwgdnBzcik7CisJ
aXNyID0gdnBzciAmIElBNjRfUFNSX1JJOworCXJlZmxlY3RfaW50ZXJydXB0aW9uKDAsIGlzciwg
MCwgMTIsIHJlZ3MpOyAvKkVYVCBJUlEqLworfQorCit2b2lkIGt2bV9pYTY0X2hhbmRsZV9pcnEo
c3RydWN0IGt2bV92Y3B1ICp2KQoreworCXN0cnVjdCBleGl0X2N0bF9kYXRhICpwID0gJnYtPmFy
Y2guZXhpdF9kYXRhOworCWxvbmcgcHNyOworCisJbG9jYWxfaXJxX3NhdmUocHNyKTsKKwlwLT5l
eGl0X3JlYXNvbiA9IEVYSVRfUkVBU09OX0VYVEVSTkFMX0lOVEVSUlVQVDsKKwl2bW1fdHJhbnNp
dGlvbih2KTsKKwlsb2NhbF9pcnFfcmVzdG9yZShwc3IpOworCisJVk1YKHYsIHRpbWVyX2NoZWNr
KSA9IDE7CisKK30KKworc3RhdGljIHZvaWQgcHRjX2dhX3JlbW90ZV9mdW5jKHN0cnVjdCBrdm1f
dmNwdSAqdiwgaW50IHBvcykKK3sKKwl1NjQgb2xkcmlkLCBtb2xkcmlkLCBvbGRwc2JpdHMsIHZh
ZGRyOworCXN0cnVjdCBrdm1fcHRjX2cgKnAgPSAmdi0+YXJjaC5wdGNfZ19kYXRhW3Bvc107CisJ
dmFkZHIgPSBwLT52YWRkcjsKKworCW9sZHJpZCA9IFZNWCh2LCB2cnJbMF0pOworCVZNWCh2LCB2
cnJbMF0pID0gcC0+cnI7CisJb2xkcHNiaXRzID0gVk1YKHYsIHBzYml0c1swXSk7CisJVk1YKHYs
IHBzYml0c1swXSkgPSBWTVgodiwgcHNiaXRzW1JFR0lPTl9OVU1CRVIodmFkZHIpXSk7CisJbW9s
ZHJpZCA9IGlhNjRfZ2V0X3JyKDB4MCk7CisJaWE2NF9zZXRfcnIoMHgwLCB2cnJ0b21ycihwLT5y
cikpOworCWlhNjRfc3Jsel9kKCk7CisKKwl2YWRkciA9IFBBR0VBTElHTih2YWRkciwgcC0+cHMp
OworCXRoYXNoX3B1cmdlX2VudHJpZXNfcmVtb3RlKHYsIHZhZGRyLCBwLT5wcyk7CisKKwlWTVgo
diwgdnJyWzBdKSA9IG9sZHJpZDsKKwlWTVgodiwgcHNiaXRzWzBdKSA9IG9sZHBzYml0czsKKwlp
YTY0X3NldF9ycigweDAsIG1vbGRyaWQpOworCWlhNjRfZHZfc2VyaWFsaXplX2RhdGEoKTsKK30K
Kworc3RhdGljIHZvaWQgdmNwdV9kb19yZXN1bWUoc3RydWN0IGt2bV92Y3B1ICp2Y3B1KQorewor
CS8qUmUtaW5pdCBWSFBUIGFuZCBWVExCIG9uY2UgZnJvbSByZXN1bWUqLworCXZjcHUtPmFyY2gu
dmhwdC5udW0gPSBWSFBUX05VTV9FTlRSSUVTOworCXRoYXNoX2luaXQoJnZjcHUtPmFyY2gudmhw
dCwgVkhQVF9TSElGVCk7CisJdmNwdS0+YXJjaC52dGxiLm51bSA9IFZUTEJfTlVNX0VOVFJJRVM7
CisJdGhhc2hfaW5pdCgmdmNwdS0+YXJjaC52dGxiLCBWVExCX1NISUZUKTsKKworCWlhNjRfc2V0
X3B0YSh2Y3B1LT5hcmNoLnZocHQucHRhLnZhbCk7Cit9CisKK3N0YXRpYyB2b2lkIGt2bV9kb19y
ZXN1bWVfb3Aoc3RydWN0IGt2bV92Y3B1ICp2Y3B1KQoreworCWlmICh0ZXN0X2FuZF9jbGVhcl9i
aXQoS1ZNX1JFUV9SRVNVTUUsICZ2Y3B1LT5yZXF1ZXN0cykpIHsKKwkJdmNwdV9kb19yZXN1bWUo
dmNwdSk7CisJCXJldHVybjsKKwl9CisKKwlpZiAodW5saWtlbHkodGVzdF9hbmRfY2xlYXJfYml0
KEtWTV9SRVFfVExCX0ZMVVNILCAmdmNwdS0+cmVxdWVzdHMpKSkgeworCQl0aGFzaF9wdXJnZV9h
bGwodmNwdSk7CisJCXJldHVybjsKKwl9CisKKwlpZiAodGVzdF9hbmRfY2xlYXJfYml0KEtWTV9S
RVFfUFRDX0csICZ2Y3B1LT5yZXF1ZXN0cykpIHsKKwkJd2hpbGUgKHZjcHUtPmFyY2gucHRjX2df
Y291bnQgPiAwKQorCQkJcHRjX2dhX3JlbW90ZV9mdW5jKHZjcHUsIC0tdmNwdS0+YXJjaC5wdGNf
Z19jb3VudCk7CisJfQorfQorCit2b2lkIHZtbV90cmFuc2l0aW9uKHN0cnVjdCBrdm1fdmNwdSAq
dmNwdSkKK3sKKwlpYTY0X2NhbGxfdnNhKFBBTF9WUFNfU0FWRSwgKHVuc2lnbmVkIGxvbmcpdmNw
dS0+YXJjaC52cGQsCisJCQkwLCAwLCAwLCAwLCAwLCAwKTsKKwl2bW1fdHJhbXBvbGluZSgmdmNw
dS0+YXJjaC5ndWVzdCwgJnZjcHUtPmFyY2guaG9zdCk7CisJaWE2NF9jYWxsX3ZzYShQQUxfVlBT
X1JFU1RPUkUsICh1bnNpZ25lZCBsb25nKXZjcHUtPmFyY2gudnBkLAorCQkJCQkJMCwgMCwgMCwg
MCwgMCwgMCk7CisJa3ZtX2RvX3Jlc3VtZV9vcCh2Y3B1KTsKK30KLS0gCjEuNS4yCgo=

------_=_NextPart_001_01C893E6.5C0C5B0B--
