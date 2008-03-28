From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Fri, 28 Mar 2008 09:58:18 +0000
Subject: [14/17][PATCH] kvm/ia64: Add guest interruption injection support.
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDCFF7EF2@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C890BA.3FCD69CF"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C890BA.3FCD69CF
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

From 8a79e0d7002a204be8dbeb6eb7589464fe766866 Mon Sep 17 00:00:00 2001
From: Xiantao Zhang <xiantao.zhang@intel.com>
Date: Wed, 12 Mar 2008 13:50:49 +0800
Subject: [PATCH] kvm/ia64: Add guest interruption injection support.

process.c mainly handle interruption injection, and some
faults handling.
Signed-off-by: Anthony Xu <anthony.xu@intel.com>
Signed-off-by: Xiantao Zhang <xiantao.zhang@intel.com>
---
 arch/ia64/kvm/process.c |  979
+++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 979 insertions(+), 0 deletions(-)
 create mode 100644 arch/ia64/kvm/process.c

diff --git a/arch/ia64/kvm/process.c b/arch/ia64/kvm/process.c
new file mode 100644
index 0000000..c6ad92b
--- /dev/null
+++ b/arch/ia64/kvm/process.c
@@ -0,0 +1,979 @@
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
+#define INITIAL_PSR_VALUE_AT_INTERRUPTION 0x0000001808028034
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
+static void collect_interruption(VCPU *vcpu)
+{
+	u64 ipsr;
+	u64 vdcr;
+	u64 vifs;
+	ia64_psr vpsr;
+	REGS *regs =3D vcpu_regs(vcpu);
+
+	vpsr.val =3D vcpu_get_psr(vcpu);
+	vcpu_bsw0(vcpu);
+	if (vpsr.ic) {
+
+		/* Sync mpsr id/da/dd/ss/ed bits to vipsr
+		 * since after guest do rfi, we still want these bits on
in
+		 * mpsr
+		 */
+
+		ipsr =3D regs->cr_ipsr;
+		vpsr.val =3D vpsr.val | (ipsr & (IA64_PSR_ID | IA64_PSR_DA
+					| IA64_PSR_DD | IA64_PSR_SS
+					| IA64_PSR_ED));
+		vcpu_set_ipsr(vcpu, vpsr.val);
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
+	vpsr.val &=3D INITIAL_PSR_VALUE_AT_INTERRUPTION;
+	vpsr.val |=3D (vdcr & IA64_DCR_BE);
+
+	/* VDCR pp bit position is different from VPSR pp bit */
+	if (vdcr & IA64_DCR_PP) {
+		vpsr.val |=3D IA64_PSR_PP;
+	} else {
+		vpsr.val &=3D ~IA64_PSR_PP;;
+	}
+
+	vcpu_set_psr(vcpu, vpsr.val);
+
+}
+
+void inject_guest_interruption(VCPU *vcpu, u64 vec)
+{
+	u64 viva;
+	REGS *regs;
+	ia64_isr pt_isr;
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
+static u64 vcpu_get_itir_on_fault(VCPU *vcpu, u64 ifa)
+{
+	ia64_rr rr, rr1;
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
+void set_ifa_itir_iha(VCPU *vcpu, u64 vadr,
+		int set_ifa, int set_itir, int set_iha)
+{
+	ia64_psr vpsr;
+	u64 value;
+
+	vpsr.val =3D VCPU(vcpu, vpsr);
+	/* Vol2, Table 8-1 */
+	if (vpsr.ic) {
+		if (set_ifa) {
+			vcpu_set_ifa(vcpu, vadr);
+		}
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
+void dtlb_fault(VCPU *vcpu, u64 vadr)
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
+void itlb_fault (VCPU *vcpu, u64 vadr)
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
+void nested_dtlb(VCPU *vcpu)
+{
+	inject_guest_interruption(vcpu, IA64_DATA_NESTED_TLB_VECTOR);
+}
+
+/*
+ * Alternate Data TLB Fault
+ *  @ Alternate Data TLB vector
+ * Refer to SDM Vol2 Table 5-6 & 8-1
+ */
+void alt_dtlb(VCPU *vcpu, u64 vadr)
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
+void alt_itlb(VCPU *vcpu, u64 vadr)
+{
+	set_ifa_itir_iha(vcpu, vadr, 1, 1, 0);
+	inject_guest_interruption(vcpu, IA64_ALT_INST_TLB_VECTOR);
+}
+
+/* Deal with:
+ *  VHPT Translation Vector
+ */
+static void _vhpt_fault(VCPU *vcpu, u64 vadr)
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
+void ivhpt_fault(VCPU *vcpu, u64 vadr)
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
+void dvhpt_fault(VCPU *vcpu, u64 vadr)
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
+void _general_exception(VCPU *vcpu)
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
+void illegal_op(VCPU *vcpu)
+{
+	_general_exception(vcpu);
+}
+
+/*
+ * Illegal Dependency Fault
+ *  @ General Exception Vector
+ * Refer to SDM Vol2 Table 5-6 & 8-1
+ */
+void illegal_dep(VCPU *vcpu)
+{
+	_general_exception(vcpu);
+}
+
+/*
+ * Reserved Register/Field Fault
+ *  @ General Exception Vector
+ * Refer to SDM Vol2 Table 5-6 & 8-1
+ */
+void rsv_reg_field(VCPU *vcpu)
+{
+	_general_exception(vcpu);
+}
+/*
+ * Privileged Operation Fault
+ *  @ General Exception Vector
+ * Refer to SDM Vol2 Table 5-6 & 8-1
+ */
+
+void privilege_op(VCPU *vcpu)
+{
+	_general_exception(vcpu);
+}
+
+/*
+ * Unimplement Data Address Fault
+ *  @ General Exception Vector
+ * Refer to SDM Vol2 Table 5-6 & 8-1
+ */
+void unimpl_daddr(VCPU *vcpu)
+{
+	_general_exception(vcpu);
+}
+
+/*
+ * Privileged Register Fault
+ *  @ General Exception Vector
+ * Refer to SDM Vol2 Table 5-6 & 8-1
+ */
+void privilege_reg(VCPU *vcpu)
+{
+	_general_exception(vcpu);
+}
+
+/* Deal with
+ *  Nat consumption vector
+ * Parameter:
+ *  vaddr: Optional, if t =3D=3D REGISTER
+ */
+static void _nat_consumption_fault(VCPU *vcpu, u64 vadr, miss_type t)
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
+ * IR Data Nat Page Consumption Fault
+ *  @ Nat Consumption Vector
+ * Refer to SDM Vol2 Table 5-6 & 8-1
+ */
+#if 0
+	static void
+ir_nat_page_consumption(VCPU *vcpu, u64 vadr)
+{
+	_nat_consumption_fault(vcpu, vadr, DATA);
+}
+#endif /*shadow it due to no use currently*/
+
+/*
+ * Instruction Nat Page Consumption Fault
+ *  @ Nat Consumption Vector
+ * Refer to SDM Vol2 Table 5-6 & 8-1
+ */
+void inat_page_consumption(VCPU *vcpu, u64 vadr)
+{
+	_nat_consumption_fault(vcpu, vadr, INSTRUCTION);
+}
+
+/*
+ * Register Nat Consumption Fault
+ *  @ Nat Consumption Vector
+ * Refer to SDM Vol2 Table 5-6 & 8-1
+ */
+void rnat_consumption(VCPU *vcpu)
+{
+	_nat_consumption_fault(vcpu, 0, REGISTER);
+}
+
+/*
+ * Data Nat Page Consumption Fault
+ *  @ Nat Consumption Vector
+ * Refer to SDM Vol2 Table 5-6 & 8-1
+ */
+void dnat_page_consumption(VCPU *vcpu, u64 vadr)
+{
+	_nat_consumption_fault(vcpu, vadr, DATA);
+}
+
+/* Deal with
+ *  Page not present vector
+ */
+static void __page_not_present(VCPU *vcpu, u64 vadr)
+{
+	/* If vPSR.ic, IFA, ITIR */
+	set_ifa_itir_iha(vcpu, vadr, 1, 1, 0);
+	inject_guest_interruption(vcpu, IA64_PAGE_NOT_PRESENT_VECTOR);
+}
+
+
+void data_page_not_present(VCPU *vcpu, u64 vadr)
+{
+	__page_not_present(vcpu, vadr);
+}
+
+
+void inst_page_not_present(VCPU *vcpu, u64 vadr)
+{
+	__page_not_present(vcpu, vadr);
+}
+
+
+/* Deal with
+ *  Data access rights vector
+ */
+void data_access_rights(VCPU *vcpu, u64 vadr)
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
+		unsigned long *ifs, REGS *regs)
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
+unsigned long vmm_handle_fpu_swa(int fp_fault, REGS *regs, unsigned
long isr)
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
+	if (!bundle.i64[0] && !bundle.i64[1]) {
+		return -EACCES;
+	}
+
+	ret =3D vmm_fp_emulate(fp_fault, &bundle, &regs->cr_ipsr,
&regs->ar_fpsr,
+			&isr, &regs->pr, &regs->cr_ifs, regs);
+	return ret.status;
+}
+
+void reflect_interruption(u64 ifa, u64 isr, u64 iim,
+		u64 vec, REGS *regs)
+{
+	u64 vector;
+	int status ;
+	VCPU *vcpu =3D current_vcpu;
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
+	case 32:
+		status =3D vmm_handle_fpu_swa(1, regs, isr);
+		if (!status) {
+			vcpu_increment_iip(vcpu);
+			return;
+		} else if (-EAGAIN =3D=3D status)
+			return;
+		break;
+	case 33:
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
+	else {
+		set_ifa_itir_iha(vcpu, ifa, 1, 1, 1);
+	}
+	inject_guest_interruption(vcpu, vector);
+}
+
+static void set_pal_call_data(VCPU *vcpu)
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
+static void set_pal_call_result(VCPU *vcpu)
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
+static void set_sal_call_data(VCPU *vcpu)
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
+static void set_sal_call_result(VCPU *vcpu)
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
+	VCPU *v =3D current_vcpu;
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
+void check_pending_irq(VCPU *vcpu)
+{
+	int  mask, h_pending, h_inservice;
+	u64 isr;
+	ia64_psr vpsr;
+	REGS *regs =3D vcpu_regs(vcpu);
+
+	h_pending =3D highest_pending_irq(vcpu);
+	if (h_pending =3D=3D NULL_VECTOR) {
+		update_vhpi(vcpu, NULL_VECTOR);
+		return;
+	}
+	h_inservice =3D highest_inservice_irq(vcpu);
+
+	vpsr.val =3D VCPU(vcpu, vpsr);
+	mask =3D irq_masked(vcpu, h_pending, h_inservice);
+	if (vpsr.i && IRQ_NO_MASKED =3D=3D mask) {
+		isr =3D vpsr.val & IA64_PSR_RI;
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
+static void generate_exirq(VCPU *vcpu)
+{
+	ia64_psr vpsr;
+	uint64_t isr;
+
+	REGS *regs =3D vcpu_regs(vcpu);
+
+	vpsr.val =3D VCPU(vcpu, vpsr);
+	isr =3D vpsr.val & IA64_PSR_RI;
+	if (!vpsr.ic)
+		panic_vm(vcpu);
+	reflect_interruption(0, isr, 0, 12, regs); /* EXT IRQ */
+}
+
+void vhpi_detection(VCPU *vcpu)
+{
+	uint64_t    threshold, vhpi;
+	tpr_t       vtpr;
+	ia64_psr    vpsr;
+
+	vpsr.val =3D VCPU(vcpu, vpsr);
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
+	VCPU *v =3D current_vcpu;
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
+static inline void handle_lds(REGS *regs)
+{
+	regs->cr_ipsr |=3D IA64_PSR_ED;
+}
+
+void physical_tlb_miss(VCPU *vcpu, unsigned long vadr, int type)
+{
+	unsigned long pte;
+	ia64_rr rr;
+
+	rr.val =3D ia64_get_rr(vadr);
+	pte =3D  vadr & _PAGE_PPN_MASK;
+	pte =3D pte | PHY_PAGE_WB;
+	thash_vhpt_insert(vcpu, pte, (u64)(rr.ps << 2), vadr, type);
+	return;
+}
+
+void kvm_page_fault(u64 vadr , u64 vec, REGS *regs)
+{
+	ia64_psr vpsr;
+	int type;
+
+	u64 vhpt_adr, gppa, pteval, rr, itir;
+	ia64_isr misr;
+	ia64_pta vpta;
+	thash_data_t *data;
+	VCPU *v =3D current_vcpu;
+
+	vpsr.val =3D VCPU(v, vpsr);
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
+			if (vpsr.ic) {
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
+				if (vpsr.ic) {
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
+			} else if (vpsr.ic) {
+				vcpu_set_isr(v, misr.val);
+				dtlb_fault(v, vadr);
+			} else {
+				nested_dtlb(v);
+			}
+		} else {
+			/* Can't read VHPT.  */
+			if (vpsr.ic) {
+				vcpu_set_isr(v, misr.val);
+				dvhpt_fault(v, vadr);
+			} else {
+				nested_dtlb(v);
+			}
+		}
+	} else if (type =3D=3D I_TLB) {
+		if (!vpsr.ic)
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
+void kvm_vexirq(VCPU *vcpu)
+{
+	u64 vpsr, isr;
+	REGS *regs;
+
+	regs =3D vcpu_regs(vcpu);
+	vpsr =3D VCPU(vcpu, vpsr);
+	isr =3D vpsr & IA64_PSR_RI;
+	reflect_interruption(0, isr, 0, 12, regs); /*EXT IRQ*/
+}
+
+void kvm_ia64_handle_irq(VCPU *v)
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

------_=_NextPart_001_01C890BA.3FCD69CF
Content-Type: application/octet-stream;
	name="0014-kvm-ia64-Add-guest-interruption-injection-support.patch"
Content-Transfer-Encoding: base64
Content-Description: 0014-kvm-ia64-Add-guest-interruption-injection-support.patch
Content-Disposition: attachment;
	filename="0014-kvm-ia64-Add-guest-interruption-injection-support.patch"

RnJvbSA4YTc5ZTBkNzAwMmEyMDRiZThkYmViNmViNzU4OTQ2NGZlNzY2ODY2IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBYaWFudGFvIFpoYW5nIDx4aWFudGFvLnpoYW5nQGludGVsLmNv
bT4KRGF0ZTogV2VkLCAxMiBNYXIgMjAwOCAxMzo1MDo0OSArMDgwMApTdWJqZWN0OiBbUEFUQ0hd
IGt2bS9pYTY0OiBBZGQgZ3Vlc3QgaW50ZXJydXB0aW9uIGluamVjdGlvbiBzdXBwb3J0LgoKcHJv
Y2Vzcy5jIG1haW5seSBoYW5kbGUgaW50ZXJydXB0aW9uIGluamVjdGlvbiwgYW5kIHNvbWUKZmF1
bHRzIGhhbmRsaW5nLgpTaWduZWQtb2ZmLWJ5OiBBbnRob255IFh1IDxhbnRob255Lnh1QGludGVs
LmNvbT4KU2lnbmVkLW9mZi1ieTogWGlhbnRhbyBaaGFuZyA8eGlhbnRhby56aGFuZ0BpbnRlbC5j
b20+Ci0tLQogYXJjaC9pYTY0L2t2bS9wcm9jZXNzLmMgfCAgOTc5ICsrKysrKysrKysrKysrKysr
KysrKysrKysrKysrKysrKysrKysrKysrKysrKysrCiAxIGZpbGVzIGNoYW5nZWQsIDk3OSBpbnNl
cnRpb25zKCspLCAwIGRlbGV0aW9ucygtKQogY3JlYXRlIG1vZGUgMTAwNjQ0IGFyY2gvaWE2NC9r
dm0vcHJvY2Vzcy5jCgpkaWZmIC0tZ2l0IGEvYXJjaC9pYTY0L2t2bS9wcm9jZXNzLmMgYi9hcmNo
L2lhNjQva3ZtL3Byb2Nlc3MuYwpuZXcgZmlsZSBtb2RlIDEwMDY0NAppbmRleCAwMDAwMDAwLi5j
NmFkOTJiCi0tLSAvZGV2L251bGwKKysrIGIvYXJjaC9pYTY0L2t2bS9wcm9jZXNzLmMKQEAgLTAs
MCArMSw5NzkgQEAKKy8qCisgKiBwcm9jZXNzLmM6IGhhbmRsZSBpbnRlcnJ1cHRpb24gaW5qZWN0
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
bS9mcHN3YS5oPgorCitmcHN3YV9pbnRlcmZhY2VfdCAqdm1tX2Zwc3dhX2ludGVyZmFjZTsKKwor
I2RlZmluZSBJQTY0X1ZIUFRfVFJBTlNfVkVDVE9SCQkJMHgwMDAwCisjZGVmaW5lIElBNjRfSU5T
VF9UTEJfVkVDVE9SCQkJMHgwNDAwCisjZGVmaW5lIElBNjRfREFUQV9UTEJfVkVDVE9SCQkJMHgw
ODAwCisjZGVmaW5lIElBNjRfQUxUX0lOU1RfVExCX1ZFQ1RPUgkJMHgwYzAwCisjZGVmaW5lIElB
NjRfQUxUX0RBVEFfVExCX1ZFQ1RPUgkJMHgxMDAwCisjZGVmaW5lIElBNjRfREFUQV9ORVNURURf
VExCX1ZFQ1RPUgkJMHgxNDAwCisjZGVmaW5lIElBNjRfSU5TVF9LRVlfTUlTU19WRUNUT1IJCTB4
MTgwMAorI2RlZmluZSBJQTY0X0RBVEFfS0VZX01JU1NfVkVDVE9SCQkweDFjMDAKKyNkZWZpbmUg
SUE2NF9ESVJUWV9CSVRfVkVDVE9SCQkJMHgyMDAwCisjZGVmaW5lIElBNjRfSU5TVF9BQ0NFU1Nf
QklUX1ZFQ1RPUgkJMHgyNDAwCisjZGVmaW5lIElBNjRfREFUQV9BQ0NFU1NfQklUX1ZFQ1RPUgkJ
MHgyODAwCisjZGVmaW5lIElBNjRfQlJFQUtfVkVDVE9SCQkJMHgyYzAwCisjZGVmaW5lIElBNjRf
RVhUSU5UX1ZFQ1RPUgkJCTB4MzAwMAorI2RlZmluZSBJQTY0X1BBR0VfTk9UX1BSRVNFTlRfVkVD
VE9SCQkweDUwMDAKKyNkZWZpbmUgSUE2NF9LRVlfUEVSTUlTU0lPTl9WRUNUT1IJCTB4NTEwMAor
I2RlZmluZSBJQTY0X0lOU1RfQUNDRVNTX1JJR0hUU19WRUNUT1IJCTB4NTIwMAorI2RlZmluZSBJ
QTY0X0RBVEFfQUNDRVNTX1JJR0hUU19WRUNUT1IJCTB4NTMwMAorI2RlZmluZSBJQTY0X0dFTkVY
X1ZFQ1RPUgkJCTB4NTQwMAorI2RlZmluZSBJQTY0X0RJU0FCTEVEX0ZQUkVHX1ZFQ1RPUgkJMHg1
NTAwCisjZGVmaW5lIElBNjRfTkFUX0NPTlNVTVBUSU9OX1ZFQ1RPUgkJMHg1NjAwCisjZGVmaW5l
IElBNjRfU1BFQ1VMQVRJT05fVkVDVE9SCQkweDU3MDAgLyogVU5VU0VEICovCisjZGVmaW5lIElB
NjRfREVCVUdfVkVDVE9SCQkJMHg1OTAwCisjZGVmaW5lIElBNjRfVU5BTElHTkVEX1JFRl9WRUNU
T1IJCTB4NWEwMAorI2RlZmluZSBJQTY0X1VOU1VQUE9SVEVEX0RBVEFfUkVGX1ZFQ1RPUgkweDVi
MDAKKyNkZWZpbmUgSUE2NF9GUF9GQVVMVF9WRUNUT1IJCQkweDVjMDAKKyNkZWZpbmUgSUE2NF9G
UF9UUkFQX1ZFQ1RPUgkJCTB4NWQwMAorI2RlZmluZSBJQTY0X0xPV0VSUFJJVl9UUkFOU0ZFUl9U
UkFQX1ZFQ1RPUiAJMHg1ZTAwCisjZGVmaW5lIElBNjRfVEFLRU5fQlJBTkNIX1RSQVBfVkVDVE9S
CQkweDVmMDAKKyNkZWZpbmUgSUE2NF9TSU5HTEVfU1RFUF9UUkFQX1ZFQ1RPUgkJMHg2MDAwCisK
Ky8qIFNETSB2b2wyIDUuNSAtIElWQSBiYXNlZCBpbnRlcnJ1cHRpb24gaGFuZGxpbmcgKi8KKyNk
ZWZpbmUgSU5JVElBTF9QU1JfVkFMVUVfQVRfSU5URVJSVVBUSU9OIDB4MDAwMDAwMTgwODAyODAz
NAorCisjZGVmaW5lIERPTU5fUEFMX1JFUVVFU1QgICAgMHgxMTAwMDAKKyNkZWZpbmUgRE9NTl9T
QUxfUkVRVUVTVCAgICAweDExMDAwMQorCitzdGF0aWMgdTY0IHZlYzJvZmZbNjhdID0gezB4MCwg
MHg0MDAsIDB4ODAwLCAweGMwMCwgMHgxMDAwLCAweDE0MDAsIDB4MTgwMCwKKwkweDFjMDAsIDB4
MjAwMCwgMHgyNDAwLCAweDI4MDAsIDB4MmMwMCwgMHgzMDAwLCAweDM0MDAsIDB4MzgwMCwgMHgz
YzAwLAorCTB4NDAwMCwgMHg0NDAwLCAweDQ4MDAsIDB4NGMwMCwgMHg1MDAwLCAweDUxMDAsIDB4
NTIwMCwgMHg1MzAwLCAweDU0MDAsCisJMHg1NTAwLCAweDU2MDAsIDB4NTcwMCwgMHg1ODAwLCAw
eDU5MDAsIDB4NWEwMCwgMHg1YjAwLCAweDVjMDAsIDB4NWQwMCwKKwkweDVlMDAsIDB4NWYwMCwg
MHg2MDAwLCAweDYxMDAsIDB4NjIwMCwgMHg2MzAwLCAweDY0MDAsIDB4NjUwMCwgMHg2NjAwLAor
CTB4NjcwMCwgMHg2ODAwLCAweDY5MDAsIDB4NmEwMCwgMHg2YjAwLCAweDZjMDAsIDB4NmQwMCwg
MHg2ZTAwLCAweDZmMDAsCisJMHg3MDAwLCAweDcxMDAsIDB4NzIwMCwgMHg3MzAwLCAweDc0MDAs
IDB4NzUwMCwgMHg3NjAwLCAweDc3MDAsIDB4NzgwMCwKKwkweDc5MDAsIDB4N2EwMCwgMHg3YjAw
LCAweDdjMDAsIDB4N2QwMCwgMHg3ZTAwLCAweDdmMDAKK307CisKK3N0YXRpYyB2b2lkIGNvbGxl
Y3RfaW50ZXJydXB0aW9uKFZDUFUgKnZjcHUpCit7CisJdTY0IGlwc3I7CisJdTY0IHZkY3I7CisJ
dTY0IHZpZnM7CisJaWE2NF9wc3IgdnBzcjsKKwlSRUdTICpyZWdzID0gdmNwdV9yZWdzKHZjcHUp
OworCisJdnBzci52YWwgPSB2Y3B1X2dldF9wc3IodmNwdSk7CisJdmNwdV9ic3cwKHZjcHUpOwor
CWlmICh2cHNyLmljKSB7CisKKwkJLyogU3luYyBtcHNyIGlkL2RhL2RkL3NzL2VkIGJpdHMgdG8g
dmlwc3IKKwkJICogc2luY2UgYWZ0ZXIgZ3Vlc3QgZG8gcmZpLCB3ZSBzdGlsbCB3YW50IHRoZXNl
IGJpdHMgb24gaW4KKwkJICogbXBzcgorCQkgKi8KKworCQlpcHNyID0gcmVncy0+Y3JfaXBzcjsK
KwkJdnBzci52YWwgPSB2cHNyLnZhbCB8IChpcHNyICYgKElBNjRfUFNSX0lEIHwgSUE2NF9QU1Jf
REEKKwkJCQkJfCBJQTY0X1BTUl9ERCB8IElBNjRfUFNSX1NTCisJCQkJCXwgSUE2NF9QU1JfRUQp
KTsKKwkJdmNwdV9zZXRfaXBzcih2Y3B1LCB2cHNyLnZhbCk7CisKKwkJLyogQ3VycmVudGx5LCBm
b3IgdHJhcCwgd2UgZG8gbm90IGFkdmFuY2UgSUlQIHRvIG5leHQKKwkJICogaW5zdHJ1Y3Rpb24u
IFRoYXQncyBiZWNhdXNlIHdlIGFzc3VtZSBjYWxsZXIgYWxyZWFkeQorCQkgKiBzZXQgdXAgSUlQ
IGNvcnJlY3RseQorCQkgKi8KKworCQl2Y3B1X3NldF9paXAodmNwdSAsIHJlZ3MtPmNyX2lpcCk7
CisKKwkJLyogc2V0IHZpZnMudiB0byB6ZXJvICovCisJCXZpZnMgPSBWQ1BVKHZjcHUsIGlmcyk7
CisJCXZpZnMgJj0gfklBNjRfSUZTX1Y7CisJCXZjcHVfc2V0X2lmcyh2Y3B1LCB2aWZzKTsKKwor
CQl2Y3B1X3NldF9paXBhKHZjcHUsIFZNWCh2Y3B1LCBjcl9paXBhKSk7CisJfQorCisJdmRjciA9
IFZDUFUodmNwdSwgZGNyKTsKKworCS8qIFNldCBndWVzdCBwc3IKKwkgKiB1cC9tZmwvbWZoL3Br
L2R0L3J0L21jL2l0IGtlZXBzIHVuY2hhbmdlZAorCSAqIGJlOiBzZXQgdG8gdGhlIHZhbHVlIG9m
IGRjci5iZQorCSAqIHBwOiBzZXQgdG8gdGhlIHZhbHVlIG9mIGRjci5wcAorCSAqLworCXZwc3Iu
dmFsICY9IElOSVRJQUxfUFNSX1ZBTFVFX0FUX0lOVEVSUlVQVElPTjsKKwl2cHNyLnZhbCB8PSAo
dmRjciAmIElBNjRfRENSX0JFKTsKKworCS8qIFZEQ1IgcHAgYml0IHBvc2l0aW9uIGlzIGRpZmZl
cmVudCBmcm9tIFZQU1IgcHAgYml0ICovCisJaWYgKHZkY3IgJiBJQTY0X0RDUl9QUCkgeworCQl2
cHNyLnZhbCB8PSBJQTY0X1BTUl9QUDsKKwl9IGVsc2UgeworCQl2cHNyLnZhbCAmPSB+SUE2NF9Q
U1JfUFA7OworCX0KKworCXZjcHVfc2V0X3Bzcih2Y3B1LCB2cHNyLnZhbCk7CisKK30KKwordm9p
ZCBpbmplY3RfZ3Vlc3RfaW50ZXJydXB0aW9uKFZDUFUgKnZjcHUsIHU2NCB2ZWMpCit7CisJdTY0
IHZpdmE7CisJUkVHUyAqcmVnczsKKwlpYTY0X2lzciBwdF9pc3I7CisKKwlyZWdzID0gdmNwdV9y
ZWdzKHZjcHUpOworCisJLyogY2xlYXIgY3IuaXNyLmlyIChpbmNvbXBsZXRlIHJlZ2lzdGVyIGZy
YW1lKSovCisJcHRfaXNyLnZhbCA9IFZNWCh2Y3B1LCBjcl9pc3IpOworCXB0X2lzci5pciA9IDA7
CisJVk1YKHZjcHUsIGNyX2lzcikgPSBwdF9pc3IudmFsOworCisJY29sbGVjdF9pbnRlcnJ1cHRp
b24odmNwdSk7CisKKwl2aXZhID0gdmNwdV9nZXRfaXZhKHZjcHUpOworCXJlZ3MtPmNyX2lpcCA9
IHZpdmEgKyB2ZWM7Cit9CisKK3N0YXRpYyB1NjQgdmNwdV9nZXRfaXRpcl9vbl9mYXVsdChWQ1BV
ICp2Y3B1LCB1NjQgaWZhKQoreworCWlhNjRfcnIgcnIsIHJyMTsKKworCXJyLnZhbCA9IHZjcHVf
Z2V0X3JyKHZjcHUsIGlmYSk7CisJcnIxLnZhbCA9IDA7CisJcnIxLnBzID0gcnIucHM7CisJcnIx
LnJpZCA9IHJyLnJpZDsKKwlyZXR1cm4gKHJyMS52YWwpOworfQorCisKKy8qCisgKiBTZXQgdklG
QSAmIHZJVElSICYgdklIQSwgd2hlbiB2UFNSLmljID0xCisgKiBQYXJhbWV0ZXI6CisgKiAgc2V0
X2lmYTogaWYgdHJ1ZSwgc2V0IHZJRkEKKyAqICBzZXRfaXRpcjogaWYgdHJ1ZSwgc2V0IHZJVElS
CisgKiAgc2V0X2loYTogaWYgdHJ1ZSwgc2V0IHZJSEEKKyAqLwordm9pZCBzZXRfaWZhX2l0aXJf
aWhhKFZDUFUgKnZjcHUsIHU2NCB2YWRyLAorCQlpbnQgc2V0X2lmYSwgaW50IHNldF9pdGlyLCBp
bnQgc2V0X2loYSkKK3sKKwlpYTY0X3BzciB2cHNyOworCXU2NCB2YWx1ZTsKKworCXZwc3IudmFs
ID0gVkNQVSh2Y3B1LCB2cHNyKTsKKwkvKiBWb2wyLCBUYWJsZSA4LTEgKi8KKwlpZiAodnBzci5p
YykgeworCQlpZiAoc2V0X2lmYSkgeworCQkJdmNwdV9zZXRfaWZhKHZjcHUsIHZhZHIpOworCQl9
CisJCWlmIChzZXRfaXRpcikgeworCQkJdmFsdWUgPSB2Y3B1X2dldF9pdGlyX29uX2ZhdWx0KHZj
cHUsIHZhZHIpOworCQkJdmNwdV9zZXRfaXRpcih2Y3B1LCB2YWx1ZSk7CisJCX0KKworCQlpZiAo
c2V0X2loYSkgeworCQkJdmFsdWUgPSB2Y3B1X3RoYXNoKHZjcHUsIHZhZHIpOworCQkJdmNwdV9z
ZXRfaWhhKHZjcHUsIHZhbHVlKTsKKwkJfQorCX0KK30KKworLyoKKyAqIERhdGEgVExCIEZhdWx0
CisgKiAgQCBEYXRhIFRMQiB2ZWN0b3IKKyAqIFJlZmVyIHRvIFNETSBWb2wyIFRhYmxlIDUtNiAm
IDgtMQorICovCit2b2lkIGR0bGJfZmF1bHQoVkNQVSAqdmNwdSwgdTY0IHZhZHIpCit7CisJLyog
SWYgdlBTUi5pYywgSUZBLCBJVElSLCBJSEEgKi8KKwlzZXRfaWZhX2l0aXJfaWhhKHZjcHUsIHZh
ZHIsIDEsIDEsIDEpOworCWluamVjdF9ndWVzdF9pbnRlcnJ1cHRpb24odmNwdSwgSUE2NF9EQVRB
X1RMQl9WRUNUT1IpOworfQorCisvKgorICogSW5zdHJ1Y3Rpb24gVExCIEZhdWx0CisgKiAgQCBJ
bnN0cnVjdGlvbiBUTEIgdmVjdG9yCisgKiBSZWZlciB0byBTRE0gVm9sMiBUYWJsZSA1LTYgJiA4
LTEKKyAqLwordm9pZCBpdGxiX2ZhdWx0IChWQ1BVICp2Y3B1LCB1NjQgdmFkcikKK3sKKwkvKiBJ
ZiB2UFNSLmljLCBJRkEsIElUSVIsIElIQSAqLworCXNldF9pZmFfaXRpcl9paGEodmNwdSwgdmFk
ciwgMSwgMSwgMSk7CisJaW5qZWN0X2d1ZXN0X2ludGVycnVwdGlvbih2Y3B1LCBJQTY0X0lOU1Rf
VExCX1ZFQ1RPUik7Cit9CisKKworCisvKgorICogRGF0YSBOZXN0ZWQgVExCIEZhdWx0CisgKiAg
QCBEYXRhIE5lc3RlZCBUTEIgVmVjdG9yCisgKiBSZWZlciB0byBTRE0gVm9sMiBUYWJsZSA1LTYg
JiA4LTEKKyAqLwordm9pZCBuZXN0ZWRfZHRsYihWQ1BVICp2Y3B1KQoreworCWluamVjdF9ndWVz
dF9pbnRlcnJ1cHRpb24odmNwdSwgSUE2NF9EQVRBX05FU1RFRF9UTEJfVkVDVE9SKTsKK30KKwor
LyoKKyAqIEFsdGVybmF0ZSBEYXRhIFRMQiBGYXVsdAorICogIEAgQWx0ZXJuYXRlIERhdGEgVExC
IHZlY3RvcgorICogUmVmZXIgdG8gU0RNIFZvbDIgVGFibGUgNS02ICYgOC0xCisgKi8KK3ZvaWQg
YWx0X2R0bGIoVkNQVSAqdmNwdSwgdTY0IHZhZHIpCit7CisJc2V0X2lmYV9pdGlyX2loYSh2Y3B1
LCB2YWRyLCAxLCAxLCAwKTsKKwlpbmplY3RfZ3Vlc3RfaW50ZXJydXB0aW9uKHZjcHUsIElBNjRf
QUxUX0RBVEFfVExCX1ZFQ1RPUik7Cit9CisKKworLyoKKyAqIERhdGEgVExCIEZhdWx0CisgKiAg
QCBEYXRhIFRMQiB2ZWN0b3IKKyAqIFJlZmVyIHRvIFNETSBWb2wyIFRhYmxlIDUtNiAmIDgtMQor
ICovCit2b2lkIGFsdF9pdGxiKFZDUFUgKnZjcHUsIHU2NCB2YWRyKQoreworCXNldF9pZmFfaXRp
cl9paGEodmNwdSwgdmFkciwgMSwgMSwgMCk7CisJaW5qZWN0X2d1ZXN0X2ludGVycnVwdGlvbih2
Y3B1LCBJQTY0X0FMVF9JTlNUX1RMQl9WRUNUT1IpOworfQorCisvKiBEZWFsIHdpdGg6CisgKiAg
VkhQVCBUcmFuc2xhdGlvbiBWZWN0b3IKKyAqLworc3RhdGljIHZvaWQgX3ZocHRfZmF1bHQoVkNQ
VSAqdmNwdSwgdTY0IHZhZHIpCit7CisJLyogSWYgdlBTUi5pYywgSUZBLCBJVElSLCBJSEEqLwor
CXNldF9pZmFfaXRpcl9paGEodmNwdSwgdmFkciwgMSwgMSwgMSk7CisJaW5qZWN0X2d1ZXN0X2lu
dGVycnVwdGlvbih2Y3B1LCBJQTY0X1ZIUFRfVFJBTlNfVkVDVE9SKTsKKworCit9CisKKy8qCisg
KiBWSFBUIEluc3RydWN0aW9uIEZhdWx0CisgKiAgQCBWSFBUIFRyYW5zbGF0aW9uIHZlY3Rvcgor
ICogUmVmZXIgdG8gU0RNIFZvbDIgVGFibGUgNS02ICYgOC0xCisgKi8KK3ZvaWQgaXZocHRfZmF1
bHQoVkNQVSAqdmNwdSwgdTY0IHZhZHIpCit7CisJX3ZocHRfZmF1bHQodmNwdSwgdmFkcik7Cit9
CisKKworLyoKKyAqIFZIUFQgRGF0YSBGYXVsdAorICogIEAgVkhQVCBUcmFuc2xhdGlvbiB2ZWN0
b3IKKyAqIFJlZmVyIHRvIFNETSBWb2wyIFRhYmxlIDUtNiAmIDgtMQorICovCit2b2lkIGR2aHB0
X2ZhdWx0KFZDUFUgKnZjcHUsIHU2NCB2YWRyKQoreworCV92aHB0X2ZhdWx0KHZjcHUsIHZhZHIp
OworfQorCisKKworLyoKKyAqIERlYWwgd2l0aDoKKyAqICBHZW5lcmFsIEV4Y2VwdGlvbiB2ZWN0
b3IKKyAqLwordm9pZCBfZ2VuZXJhbF9leGNlcHRpb24oVkNQVSAqdmNwdSkKK3sKKwlpbmplY3Rf
Z3Vlc3RfaW50ZXJydXB0aW9uKHZjcHUsIElBNjRfR0VORVhfVkVDVE9SKTsKK30KKworCisvKgor
ICogSWxsZWdhbCBPcGVyYXRpb24gRmF1bHQKKyAqICBAIEdlbmVyYWwgRXhjZXB0aW9uIFZlY3Rv
cgorICogUmVmZXIgdG8gU0RNIFZvbDIgVGFibGUgNS02ICYgOC0xCisgKi8KK3ZvaWQgaWxsZWdh
bF9vcChWQ1BVICp2Y3B1KQoreworCV9nZW5lcmFsX2V4Y2VwdGlvbih2Y3B1KTsKK30KKworLyoK
KyAqIElsbGVnYWwgRGVwZW5kZW5jeSBGYXVsdAorICogIEAgR2VuZXJhbCBFeGNlcHRpb24gVmVj
dG9yCisgKiBSZWZlciB0byBTRE0gVm9sMiBUYWJsZSA1LTYgJiA4LTEKKyAqLwordm9pZCBpbGxl
Z2FsX2RlcChWQ1BVICp2Y3B1KQoreworCV9nZW5lcmFsX2V4Y2VwdGlvbih2Y3B1KTsKK30KKwor
LyoKKyAqIFJlc2VydmVkIFJlZ2lzdGVyL0ZpZWxkIEZhdWx0CisgKiAgQCBHZW5lcmFsIEV4Y2Vw
dGlvbiBWZWN0b3IKKyAqIFJlZmVyIHRvIFNETSBWb2wyIFRhYmxlIDUtNiAmIDgtMQorICovCit2
b2lkIHJzdl9yZWdfZmllbGQoVkNQVSAqdmNwdSkKK3sKKwlfZ2VuZXJhbF9leGNlcHRpb24odmNw
dSk7Cit9CisvKgorICogUHJpdmlsZWdlZCBPcGVyYXRpb24gRmF1bHQKKyAqICBAIEdlbmVyYWwg
RXhjZXB0aW9uIFZlY3RvcgorICogUmVmZXIgdG8gU0RNIFZvbDIgVGFibGUgNS02ICYgOC0xCisg
Ki8KKwordm9pZCBwcml2aWxlZ2Vfb3AoVkNQVSAqdmNwdSkKK3sKKwlfZ2VuZXJhbF9leGNlcHRp
b24odmNwdSk7Cit9CisKKy8qCisgKiBVbmltcGxlbWVudCBEYXRhIEFkZHJlc3MgRmF1bHQKKyAq
ICBAIEdlbmVyYWwgRXhjZXB0aW9uIFZlY3RvcgorICogUmVmZXIgdG8gU0RNIFZvbDIgVGFibGUg
NS02ICYgOC0xCisgKi8KK3ZvaWQgdW5pbXBsX2RhZGRyKFZDUFUgKnZjcHUpCit7CisJX2dlbmVy
YWxfZXhjZXB0aW9uKHZjcHUpOworfQorCisvKgorICogUHJpdmlsZWdlZCBSZWdpc3RlciBGYXVs
dAorICogIEAgR2VuZXJhbCBFeGNlcHRpb24gVmVjdG9yCisgKiBSZWZlciB0byBTRE0gVm9sMiBU
YWJsZSA1LTYgJiA4LTEKKyAqLwordm9pZCBwcml2aWxlZ2VfcmVnKFZDUFUgKnZjcHUpCit7CisJ
X2dlbmVyYWxfZXhjZXB0aW9uKHZjcHUpOworfQorCisvKiBEZWFsIHdpdGgKKyAqICBOYXQgY29u
c3VtcHRpb24gdmVjdG9yCisgKiBQYXJhbWV0ZXI6CisgKiAgdmFkZHI6IE9wdGlvbmFsLCBpZiB0
ID09IFJFR0lTVEVSCisgKi8KK3N0YXRpYyB2b2lkIF9uYXRfY29uc3VtcHRpb25fZmF1bHQoVkNQ
VSAqdmNwdSwgdTY0IHZhZHIsIG1pc3NfdHlwZSB0KQoreworCS8qIElmIHZQU1IuaWMgJiYgdCA9
PSBEQVRBL0lOU1QsIElGQSAqLworCWlmICh0ID09IERBVEEgfHwgdCA9PSBJTlNUUlVDVElPTikg
eworCQkvKiBJRkEgKi8KKwkJc2V0X2lmYV9pdGlyX2loYSh2Y3B1LCB2YWRyLCAxLCAwLCAwKTsK
Kwl9CisKKwlpbmplY3RfZ3Vlc3RfaW50ZXJydXB0aW9uKHZjcHUsIElBNjRfTkFUX0NPTlNVTVBU
SU9OX1ZFQ1RPUik7Cit9CisKKy8qCisgKiBJUiBEYXRhIE5hdCBQYWdlIENvbnN1bXB0aW9uIEZh
dWx0CisgKiAgQCBOYXQgQ29uc3VtcHRpb24gVmVjdG9yCisgKiBSZWZlciB0byBTRE0gVm9sMiBU
YWJsZSA1LTYgJiA4LTEKKyAqLworI2lmIDAKKwlzdGF0aWMgdm9pZAoraXJfbmF0X3BhZ2VfY29u
c3VtcHRpb24oVkNQVSAqdmNwdSwgdTY0IHZhZHIpCit7CisJX25hdF9jb25zdW1wdGlvbl9mYXVs
dCh2Y3B1LCB2YWRyLCBEQVRBKTsKK30KKyNlbmRpZiAvKnNoYWRvdyBpdCBkdWUgdG8gbm8gdXNl
IGN1cnJlbnRseSovCisKKy8qCisgKiBJbnN0cnVjdGlvbiBOYXQgUGFnZSBDb25zdW1wdGlvbiBG
YXVsdAorICogIEAgTmF0IENvbnN1bXB0aW9uIFZlY3RvcgorICogUmVmZXIgdG8gU0RNIFZvbDIg
VGFibGUgNS02ICYgOC0xCisgKi8KK3ZvaWQgaW5hdF9wYWdlX2NvbnN1bXB0aW9uKFZDUFUgKnZj
cHUsIHU2NCB2YWRyKQoreworCV9uYXRfY29uc3VtcHRpb25fZmF1bHQodmNwdSwgdmFkciwgSU5T
VFJVQ1RJT04pOworfQorCisvKgorICogUmVnaXN0ZXIgTmF0IENvbnN1bXB0aW9uIEZhdWx0Cisg
KiAgQCBOYXQgQ29uc3VtcHRpb24gVmVjdG9yCisgKiBSZWZlciB0byBTRE0gVm9sMiBUYWJsZSA1
LTYgJiA4LTEKKyAqLwordm9pZCBybmF0X2NvbnN1bXB0aW9uKFZDUFUgKnZjcHUpCit7CisJX25h
dF9jb25zdW1wdGlvbl9mYXVsdCh2Y3B1LCAwLCBSRUdJU1RFUik7Cit9CisKKy8qCisgKiBEYXRh
IE5hdCBQYWdlIENvbnN1bXB0aW9uIEZhdWx0CisgKiAgQCBOYXQgQ29uc3VtcHRpb24gVmVjdG9y
CisgKiBSZWZlciB0byBTRE0gVm9sMiBUYWJsZSA1LTYgJiA4LTEKKyAqLwordm9pZCBkbmF0X3Bh
Z2VfY29uc3VtcHRpb24oVkNQVSAqdmNwdSwgdTY0IHZhZHIpCit7CisJX25hdF9jb25zdW1wdGlv
bl9mYXVsdCh2Y3B1LCB2YWRyLCBEQVRBKTsKK30KKworLyogRGVhbCB3aXRoCisgKiAgUGFnZSBu
b3QgcHJlc2VudCB2ZWN0b3IKKyAqLworc3RhdGljIHZvaWQgX19wYWdlX25vdF9wcmVzZW50KFZD
UFUgKnZjcHUsIHU2NCB2YWRyKQoreworCS8qIElmIHZQU1IuaWMsIElGQSwgSVRJUiAqLworCXNl
dF9pZmFfaXRpcl9paGEodmNwdSwgdmFkciwgMSwgMSwgMCk7CisJaW5qZWN0X2d1ZXN0X2ludGVy
cnVwdGlvbih2Y3B1LCBJQTY0X1BBR0VfTk9UX1BSRVNFTlRfVkVDVE9SKTsKK30KKworCit2b2lk
IGRhdGFfcGFnZV9ub3RfcHJlc2VudChWQ1BVICp2Y3B1LCB1NjQgdmFkcikKK3sKKwlfX3BhZ2Vf
bm90X3ByZXNlbnQodmNwdSwgdmFkcik7Cit9CisKKwordm9pZCBpbnN0X3BhZ2Vfbm90X3ByZXNl
bnQoVkNQVSAqdmNwdSwgdTY0IHZhZHIpCit7CisJX19wYWdlX25vdF9wcmVzZW50KHZjcHUsIHZh
ZHIpOworfQorCisKKy8qIERlYWwgd2l0aAorICogIERhdGEgYWNjZXNzIHJpZ2h0cyB2ZWN0b3IK
KyAqLwordm9pZCBkYXRhX2FjY2Vzc19yaWdodHMoVkNQVSAqdmNwdSwgdTY0IHZhZHIpCit7CisJ
LyogSWYgdlBTUi5pYywgSUZBLCBJVElSICovCisJc2V0X2lmYV9pdGlyX2loYSh2Y3B1LCB2YWRy
LCAxLCAxLCAwKTsKKwlpbmplY3RfZ3Vlc3RfaW50ZXJydXB0aW9uKHZjcHUsIElBNjRfREFUQV9B
Q0NFU1NfUklHSFRTX1ZFQ1RPUik7Cit9CisKK2Zwc3dhX3JldF90IHZtbV9mcF9lbXVsYXRlKGlu
dCBmcF9mYXVsdCwgdm9pZCAqYnVuZGxlLCB1bnNpZ25lZCBsb25nICppcHNyLAorCQl1bnNpZ25l
ZCBsb25nICpmcHNyLCB1bnNpZ25lZCBsb25nICppc3IsIHVuc2lnbmVkIGxvbmcgKnByLAorCQl1
bnNpZ25lZCBsb25nICppZnMsIFJFR1MgKnJlZ3MpCit7CisJZnBfc3RhdGVfdCBmcF9zdGF0ZTsK
KwlmcHN3YV9yZXRfdCByZXQ7CisJc3RydWN0IGt2bV92Y3B1ICp2Y3B1ID0gY3VycmVudF92Y3B1
OworCisJdWludDY0X3Qgb2xkX3JyNyA9IGlhNjRfZ2V0X3JyKDdVTDw8NjEpOworCisJaWYgKCF2
bW1fZnBzd2FfaW50ZXJmYWNlKQorCQlyZXR1cm4gKGZwc3dhX3JldF90KSB7LTEsIDAsIDAsIDB9
OworCisJLyoKKwkgKiBKdXN0IGxldCBmcHN3YSBkcml2ZXIgdG8gdXNlIGhhcmR3YXJlIGZwIHJl
Z2lzdGVycy4KKwkgKiBObyBmcCByZWdpc3RlciBpcyB2YWxpZCBpbiBtZW1vcnkuCisJICovCisJ
bWVtc2V0KCZmcF9zdGF0ZSwgMCwgc2l6ZW9mKGZwX3N0YXRlX3QpKTsKKworCS8qCisJICogdW5z
aWduZWQgbG9uZyAoKkVGSV9GUFNXQSkgKAorCSAqICAgICAgdW5zaWduZWQgbG9uZyAgICB0cmFw
X3R5cGUsCisJICogICAgICB2b2lkICAgICAgICAgICAgICpCdW5kbGUsCisJICogICAgICB1bnNp
Z25lZCBsb25nICAgICpwaXBzciwKKwkgKiAgICAgIHVuc2lnbmVkIGxvbmcgICAgKnBmc3IsCisJ
ICogICAgICB1bnNpZ25lZCBsb25nICAgICpwaXNyLAorCSAqICAgICAgdW5zaWduZWQgbG9uZyAg
ICAqcHByZWRzLAorCSAqICAgICAgdW5zaWduZWQgbG9uZyAgICAqcGlmcywKKwkgKiAgICAgIHZv
aWQgICAgICAgICAgICAgKmZwX3N0YXRlKTsKKwkgKi8KKwkvKkNhbGwgaG9zdCBmcHN3YSBpbnRl
cmZhY2UgZGlyZWN0bHkgdG8gdmlydHVhbGl6ZQorCSAqZ3Vlc3QgZnBzd2EgcmVxdWVzdCEKKwkg
Ki8KKwlpYTY0X3NldF9ycig3VUwgPDwgNjEsIHZjcHUtPmFyY2guaG9zdC5ycls3XSk7CisJaWE2
NF9zcmx6X2QoKTsKKworCXJldCA9ICgqdm1tX2Zwc3dhX2ludGVyZmFjZS0+ZnBzd2EpIChmcF9m
YXVsdCwgYnVuZGxlLAorCQkJaXBzciwgZnBzciwgaXNyLCBwciwgaWZzLCAmZnBfc3RhdGUpOwor
CWlhNjRfc2V0X3JyKDdVTCA8PCA2MSwgb2xkX3JyNyk7CisJaWE2NF9zcmx6X2QoKTsKKwlyZXR1
cm4gcmV0OworfQorCisvKgorICogSGFuZGxlIGZsb2F0aW5nLXBvaW50IGFzc2lzdCBmYXVsdHMg
YW5kIHRyYXBzIGZvciBkb21haW4uCisgKi8KK3Vuc2lnbmVkIGxvbmcgdm1tX2hhbmRsZV9mcHVf
c3dhKGludCBmcF9mYXVsdCwgUkVHUyAqcmVncywgdW5zaWduZWQgbG9uZyBpc3IpCit7CisJc3Ry
dWN0IGt2bV92Y3B1ICp2ID0gY3VycmVudF92Y3B1OworCUlBNjRfQlVORExFIGJ1bmRsZTsKKwl1
bnNpZ25lZCBsb25nIGZhdWx0X2lwOworCWZwc3dhX3JldF90IHJldDsKKworCWZhdWx0X2lwID0g
cmVncy0+Y3JfaWlwOworCS8qCisJICogV2hlbiB0aGUgRlAgdHJhcCBvY2N1cnMsIHRoZSB0cmFw
cGluZyBpbnN0cnVjdGlvbiBpcyBjb21wbGV0ZWQuCisJICogSWYgaXBzci5yaSA9PSAwLCB0aGVy
ZSBpcyB0aGUgdHJhcHBpbmcgaW5zdHJ1Y3Rpb24gaW4gcHJldmlvdXMKKwkgKiBidW5kbGUuCisJ
ICovCisJaWYgKCFmcF9mYXVsdCAmJiAoaWE2NF9wc3IocmVncyktPnJpID09IDApKQorCQlmYXVs
dF9pcCAtPSAxNjsKKworCWlmIChmZXRjaF9jb2RlKHYsIGZhdWx0X2lwLCAmYnVuZGxlKSkKKwkJ
cmV0dXJuIC1FQUdBSU47CisKKwlpZiAoIWJ1bmRsZS5pNjRbMF0gJiYgIWJ1bmRsZS5pNjRbMV0p
IHsKKwkJcmV0dXJuIC1FQUNDRVM7CisJfQorCisJcmV0ID0gdm1tX2ZwX2VtdWxhdGUoZnBfZmF1
bHQsICZidW5kbGUsICZyZWdzLT5jcl9pcHNyLCAmcmVncy0+YXJfZnBzciwKKwkJCSZpc3IsICZy
ZWdzLT5wciwgJnJlZ3MtPmNyX2lmcywgcmVncyk7CisJcmV0dXJuIHJldC5zdGF0dXM7Cit9CisK
K3ZvaWQgcmVmbGVjdF9pbnRlcnJ1cHRpb24odTY0IGlmYSwgdTY0IGlzciwgdTY0IGlpbSwKKwkJ
dTY0IHZlYywgUkVHUyAqcmVncykKK3sKKwl1NjQgdmVjdG9yOworCWludCBzdGF0dXMgOworCVZD
UFUgKnZjcHUgPSBjdXJyZW50X3ZjcHU7CisJdTY0IHZwc3IgPSBWQ1BVKHZjcHUsIHZwc3IpOwor
CisJdmVjdG9yID0gdmVjMm9mZlt2ZWNdOworCisJaWYgKCEodnBzciAmIElBNjRfUFNSX0lDKSAm
JiAodmVjdG9yICE9IElBNjRfREFUQV9ORVNURURfVExCX1ZFQ1RPUikpIHsKKwkJcGFuaWNfdm0o
dmNwdSk7CisJCXJldHVybjsKKwl9CisKKwlzd2l0Y2ggKHZlYykgeworCWNhc2UgMzI6CisJCXN0
YXR1cyA9IHZtbV9oYW5kbGVfZnB1X3N3YSgxLCByZWdzLCBpc3IpOworCQlpZiAoIXN0YXR1cykg
eworCQkJdmNwdV9pbmNyZW1lbnRfaWlwKHZjcHUpOworCQkJcmV0dXJuOworCQl9IGVsc2UgaWYg
KC1FQUdBSU4gPT0gc3RhdHVzKQorCQkJcmV0dXJuOworCQlicmVhazsKKwljYXNlIDMzOgorCQlz
dGF0dXMgPSB2bW1faGFuZGxlX2ZwdV9zd2EoMCwgcmVncywgaXNyKTsKKwkJaWYgKCFzdGF0dXMp
CisJCQlyZXR1cm4gOworCQllbHNlIGlmICgtRUFHQUlOID09IHN0YXR1cykgeworCQkJdmNwdV9k
ZWNyZW1lbnRfaWlwKHZjcHUpOworCQkJcmV0dXJuIDsKKwkJfQorCQlicmVhazsKKwl9CisKKwlW
Q1BVKHZjcHUsIGlzcikgPSBpc3I7CisJVkNQVSh2Y3B1LCBpaXBhKSA9IHJlZ3MtPmNyX2lpcDsK
KwlpZiAodmVjdG9yID09IElBNjRfQlJFQUtfVkVDVE9SIHx8IHZlY3RvciA9PSBJQTY0X1NQRUNV
TEFUSU9OX1ZFQ1RPUikKKwkJVkNQVSh2Y3B1LCBpaW0pID0gaWltOworCWVsc2UgeworCQlzZXRf
aWZhX2l0aXJfaWhhKHZjcHUsIGlmYSwgMSwgMSwgMSk7CisJfQorCWluamVjdF9ndWVzdF9pbnRl
cnJ1cHRpb24odmNwdSwgdmVjdG9yKTsKK30KKworc3RhdGljIHZvaWQgc2V0X3BhbF9jYWxsX2Rh
dGEoVkNQVSAqdmNwdSkKK3sKKwlzdHJ1Y3QgZXhpdF9jdGxfZGF0YSAqcCA9ICZ2Y3B1LT5hcmNo
LmV4aXRfZGF0YTsKKworCS8qRklYTUU6Rm9yIHN0YXRpYyBhbmQgc3RhY2tlZCBjb252ZW50aW9u
LCBmaXJtd2FyZQorCSAqIGhhcyBwdXQgdGhlIHBhcmFtZXRlcnMgaW4gZ3IyOC1ncjMxIGJlZm9y
ZQorCSAqIGJyZWFrIHRvIHZtbSAgISEqLworCisJcC0+dS5wYWxfZGF0YS5ncjI4ID0gdmNwdV9n
ZXRfZ3IodmNwdSwgMjgpOworCXAtPnUucGFsX2RhdGEuZ3IyOSA9IHZjcHVfZ2V0X2dyKHZjcHUs
IDI5KTsKKwlwLT51LnBhbF9kYXRhLmdyMzAgPSB2Y3B1X2dldF9ncih2Y3B1LCAzMCk7CisJcC0+
dS5wYWxfZGF0YS5ncjMxID0gdmNwdV9nZXRfZ3IodmNwdSwgMzEpOworCXAtPmV4aXRfcmVhc29u
ID0gRVhJVF9SRUFTT05fUEFMX0NBTEw7Cit9CisKK3N0YXRpYyB2b2lkIHNldF9wYWxfY2FsbF9y
ZXN1bHQoVkNQVSAqdmNwdSkKK3sKKwlzdHJ1Y3QgZXhpdF9jdGxfZGF0YSAqcCA9ICZ2Y3B1LT5h
cmNoLmV4aXRfZGF0YTsKKworCWlmIChwLT5leGl0X3JlYXNvbiA9PSBFWElUX1JFQVNPTl9QQUxf
Q0FMTCkgeworCQl2Y3B1X3NldF9ncih2Y3B1LCA4LCBwLT51LnBhbF9kYXRhLnJldC5zdGF0dXMs
IDApOworCQl2Y3B1X3NldF9ncih2Y3B1LCA5LCBwLT51LnBhbF9kYXRhLnJldC52MCwgMCk7CisJ
CXZjcHVfc2V0X2dyKHZjcHUsIDEwLCBwLT51LnBhbF9kYXRhLnJldC52MSwgMCk7CisJCXZjcHVf
c2V0X2dyKHZjcHUsIDExLCBwLT51LnBhbF9kYXRhLnJldC52MiwgMCk7CisJfSBlbHNlCisJCXBh
bmljX3ZtKHZjcHUpOworfQorCitzdGF0aWMgdm9pZCBzZXRfc2FsX2NhbGxfZGF0YShWQ1BVICp2
Y3B1KQoreworCXN0cnVjdCBleGl0X2N0bF9kYXRhICpwID0gJnZjcHUtPmFyY2guZXhpdF9kYXRh
OworCisJcC0+dS5zYWxfZGF0YS5pbjAgPSB2Y3B1X2dldF9ncih2Y3B1LCAzMik7CisJcC0+dS5z
YWxfZGF0YS5pbjEgPSB2Y3B1X2dldF9ncih2Y3B1LCAzMyk7CisJcC0+dS5zYWxfZGF0YS5pbjIg
PSB2Y3B1X2dldF9ncih2Y3B1LCAzNCk7CisJcC0+dS5zYWxfZGF0YS5pbjMgPSB2Y3B1X2dldF9n
cih2Y3B1LCAzNSk7CisJcC0+dS5zYWxfZGF0YS5pbjQgPSB2Y3B1X2dldF9ncih2Y3B1LCAzNik7
CisJcC0+dS5zYWxfZGF0YS5pbjUgPSB2Y3B1X2dldF9ncih2Y3B1LCAzNyk7CisJcC0+dS5zYWxf
ZGF0YS5pbjYgPSB2Y3B1X2dldF9ncih2Y3B1LCAzOCk7CisJcC0+dS5zYWxfZGF0YS5pbjcgPSB2
Y3B1X2dldF9ncih2Y3B1LCAzOSk7CisJcC0+ZXhpdF9yZWFzb24gPSBFWElUX1JFQVNPTl9TQUxf
Q0FMTDsKK30KKworc3RhdGljIHZvaWQgc2V0X3NhbF9jYWxsX3Jlc3VsdChWQ1BVICp2Y3B1KQor
eworCXN0cnVjdCBleGl0X2N0bF9kYXRhICpwID0gJnZjcHUtPmFyY2guZXhpdF9kYXRhOworCisJ
aWYgKHAtPmV4aXRfcmVhc29uID09IEVYSVRfUkVBU09OX1NBTF9DQUxMKSB7CisJCXZjcHVfc2V0
X2dyKHZjcHUsIDgsIHAtPnUuc2FsX2RhdGEucmV0LnI4LCAwKTsKKwkJdmNwdV9zZXRfZ3IodmNw
dSwgOSwgcC0+dS5zYWxfZGF0YS5yZXQucjksIDApOworCQl2Y3B1X3NldF9ncih2Y3B1LCAxMCwg
cC0+dS5zYWxfZGF0YS5yZXQucjEwLCAwKTsKKwkJdmNwdV9zZXRfZ3IodmNwdSwgMTEsIHAtPnUu
c2FsX2RhdGEucmV0LnIxMSwgMCk7CisJfSBlbHNlCisJCXBhbmljX3ZtKHZjcHUpOworfQorCit2
b2lkICBrdm1faWE2NF9oYW5kbGVfYnJlYWsodW5zaWduZWQgbG9uZyBpZmEsIHN0cnVjdCBrdm1f
cHRfcmVncyAqcmVncywKKwkJdW5zaWduZWQgbG9uZyBpc3IsIHVuc2lnbmVkIGxvbmcgaWltKQor
eworCVZDUFUgKnYgPSBjdXJyZW50X3ZjcHU7CisKKwlpZiAoaWE2NF9wc3IocmVncyktPmNwbCA9
PSAwKSB7CisJCS8qIEFsbG93IGh5cGVyY2FsbHMgb25seSB3aGVuIGNwbCA9IDAuICAqLworCQlp
ZiAoaWltID09IERPTU5fUEFMX1JFUVVFU1QpIHsKKwkJCXNldF9wYWxfY2FsbF9kYXRhKHYpOwor
CQkJdm1tX3RyYW5zaXRpb24odik7CisJCQlzZXRfcGFsX2NhbGxfcmVzdWx0KHYpOworCQkJdmNw
dV9pbmNyZW1lbnRfaWlwKHYpOworCQkJcmV0dXJuOworCQl9IGVsc2UgaWYgKGlpbSA9PSBET01O
X1NBTF9SRVFVRVNUKSB7CisJCQlzZXRfc2FsX2NhbGxfZGF0YSh2KTsKKwkJCXZtbV90cmFuc2l0
aW9uKHYpOworCQkJc2V0X3NhbF9jYWxsX3Jlc3VsdCh2KTsKKwkJCXZjcHVfaW5jcmVtZW50X2lp
cCh2KTsKKwkJCXJldHVybjsKKwkJfQorCX0KKwlyZWZsZWN0X2ludGVycnVwdGlvbihpZmEsIGlz
ciwgaWltLCAxMSwgcmVncyk7Cit9CisKK3ZvaWQgY2hlY2tfcGVuZGluZ19pcnEoVkNQVSAqdmNw
dSkKK3sKKwlpbnQgIG1hc2ssIGhfcGVuZGluZywgaF9pbnNlcnZpY2U7CisJdTY0IGlzcjsKKwlp
YTY0X3BzciB2cHNyOworCVJFR1MgKnJlZ3MgPSB2Y3B1X3JlZ3ModmNwdSk7CisKKwloX3BlbmRp
bmcgPSBoaWdoZXN0X3BlbmRpbmdfaXJxKHZjcHUpOworCWlmIChoX3BlbmRpbmcgPT0gTlVMTF9W
RUNUT1IpIHsKKwkJdXBkYXRlX3ZocGkodmNwdSwgTlVMTF9WRUNUT1IpOworCQlyZXR1cm47CisJ
fQorCWhfaW5zZXJ2aWNlID0gaGlnaGVzdF9pbnNlcnZpY2VfaXJxKHZjcHUpOworCisJdnBzci52
YWwgPSBWQ1BVKHZjcHUsIHZwc3IpOworCW1hc2sgPSBpcnFfbWFza2VkKHZjcHUsIGhfcGVuZGlu
ZywgaF9pbnNlcnZpY2UpOworCWlmICh2cHNyLmkgJiYgSVJRX05PX01BU0tFRCA9PSBtYXNrKSB7
CisJCWlzciA9IHZwc3IudmFsICYgSUE2NF9QU1JfUkk7CisJCXVwZGF0ZV92aHBpKHZjcHUsIGhf
cGVuZGluZyk7CisJCXJlZmxlY3RfaW50ZXJydXB0aW9uKDAsIGlzciwgMCwgMTIsIHJlZ3MpOyAv
KiBFWFQgSVJRICovCisJfSBlbHNlIGlmIChtYXNrID09IElSUV9NQVNLRURfQllfSU5TVkMpIHsK
KwkJaWYgKFZDUFUodmNwdSwgdmhwaSkpCisJCQl1cGRhdGVfdmhwaSh2Y3B1LCBOVUxMX1ZFQ1RP
Uik7CisJfSBlbHNlIHsKKwkJLyogbWFza2VkIGJ5IHZwc3IuaSBvciB2dHByLiovCisJCXVwZGF0
ZV92aHBpKHZjcHUsIGhfcGVuZGluZyk7CisJfQorfQorCitzdGF0aWMgdm9pZCBnZW5lcmF0ZV9l
eGlycShWQ1BVICp2Y3B1KQoreworCWlhNjRfcHNyIHZwc3I7CisJdWludDY0X3QgaXNyOworCisJ
UkVHUyAqcmVncyA9IHZjcHVfcmVncyh2Y3B1KTsKKworCXZwc3IudmFsID0gVkNQVSh2Y3B1LCB2
cHNyKTsKKwlpc3IgPSB2cHNyLnZhbCAmIElBNjRfUFNSX1JJOworCWlmICghdnBzci5pYykKKwkJ
cGFuaWNfdm0odmNwdSk7CisJcmVmbGVjdF9pbnRlcnJ1cHRpb24oMCwgaXNyLCAwLCAxMiwgcmVn
cyk7IC8qIEVYVCBJUlEgKi8KK30KKwordm9pZCB2aHBpX2RldGVjdGlvbihWQ1BVICp2Y3B1KQor
eworCXVpbnQ2NF90ICAgIHRocmVzaG9sZCwgdmhwaTsKKwl0cHJfdCAgICAgICB2dHByOworCWlh
NjRfcHNyICAgIHZwc3I7CisKKwl2cHNyLnZhbCA9IFZDUFUodmNwdSwgdnBzcik7CisJdnRwci52
YWwgPSBWQ1BVKHZjcHUsIHRwcik7CisKKwl0aHJlc2hvbGQgPSAoKCF2cHNyLmkpIDw8IDUpIHwg
KHZ0cHIubW1pIDw8IDQpIHwgdnRwci5taWM7CisJdmhwaSA9IFZDUFUodmNwdSwgdmhwaSk7CisJ
aWYgKHZocGkgPiB0aHJlc2hvbGQpIHsKKwkJLyogaW50ZXJydXB0IGFjdGl2ZWQqLworCQlnZW5l
cmF0ZV9leGlycSh2Y3B1KTsKKwl9Cit9CisKKwordm9pZCBsZWF2ZV9oeXBlcnZpc29yX3RhaWwo
dm9pZCkKK3sKKwlWQ1BVICp2ID0gY3VycmVudF92Y3B1OworCisJaWYgKFZNWCh2LCB0aW1lcl9j
aGVjaykpIHsKKwkJVk1YKHYsIHRpbWVyX2NoZWNrKSA9IDA7CisJCWlmIChWTVgodiwgaXRjX2No
ZWNrKSkgeworCQkJaWYgKHZjcHVfZ2V0X2l0Yyh2KSA+IFZDUFUodiwgaXRtKSkgeworCQkJCWlm
ICghKFZDUFUodiwgaXR2KSAmICgxIDw8IDE2KSkpIHsKKwkJCQkJdmNwdV9wZW5kX2ludGVycnVw
dCh2LCBWQ1BVKHYsIGl0dikKKwkJCQkJCQkmIDB4ZmYpOworCQkJCVZNWCh2LCBpdGNfY2hlY2sp
ID0gMDsKKwkJCQl9IGVsc2UgeworCQkJCQl2LT5hcmNoLnRpbWVyX3BlbmRpbmcgPSAxOworCQkJ
CX0KKwkJCQlWTVgodiwgbGFzdF9pdGMpID0gVkNQVSh2LCBpdG0pICsgMTsKKwkJCX0KKwkJfQor
CX0KKworCXJtYigpOworCWlmICh2LT5hcmNoLmlycV9uZXdfcGVuZGluZykgeworCQl2LT5hcmNo
LmlycV9uZXdfcGVuZGluZyA9IDA7CisJCVZNWCh2LCBpcnFfY2hlY2spID0gMDsKKwkJY2hlY2tf
cGVuZGluZ19pcnEodik7CisJCXJldHVybjsKKwl9CisJaWYgKFZNWCh2LCBpcnFfY2hlY2spKSB7
CisJCVZNWCh2LCBpcnFfY2hlY2spID0gMDsKKwkJdmhwaV9kZXRlY3Rpb24odik7CisJfQorfQor
CisKK3N0YXRpYyBpbmxpbmUgdm9pZCBoYW5kbGVfbGRzKFJFR1MgKnJlZ3MpCit7CisJcmVncy0+
Y3JfaXBzciB8PSBJQTY0X1BTUl9FRDsKK30KKwordm9pZCBwaHlzaWNhbF90bGJfbWlzcyhWQ1BV
ICp2Y3B1LCB1bnNpZ25lZCBsb25nIHZhZHIsIGludCB0eXBlKQoreworCXVuc2lnbmVkIGxvbmcg
cHRlOworCWlhNjRfcnIgcnI7CisKKwlyci52YWwgPSBpYTY0X2dldF9ycih2YWRyKTsKKwlwdGUg
PSAgdmFkciAmIF9QQUdFX1BQTl9NQVNLOworCXB0ZSA9IHB0ZSB8IFBIWV9QQUdFX1dCOworCXRo
YXNoX3ZocHRfaW5zZXJ0KHZjcHUsIHB0ZSwgKHU2NCkocnIucHMgPDwgMiksIHZhZHIsIHR5cGUp
OworCXJldHVybjsKK30KKwordm9pZCBrdm1fcGFnZV9mYXVsdCh1NjQgdmFkciAsIHU2NCB2ZWMs
IFJFR1MgKnJlZ3MpCit7CisJaWE2NF9wc3IgdnBzcjsKKwlpbnQgdHlwZTsKKworCXU2NCB2aHB0
X2FkciwgZ3BwYSwgcHRldmFsLCByciwgaXRpcjsKKwlpYTY0X2lzciBtaXNyOworCWlhNjRfcHRh
IHZwdGE7CisJdGhhc2hfZGF0YV90ICpkYXRhOworCVZDUFUgKnYgPSBjdXJyZW50X3ZjcHU7CisK
Kwl2cHNyLnZhbCA9IFZDUFUodiwgdnBzcik7CisJbWlzci52YWwgPSBWTVgodiwgY3JfaXNyKTsK
KworCXR5cGUgPSB2ZWM7CisKKwlpZiAoaXNfcGh5c2ljYWxfbW9kZSh2KSAmJiAoISh2YWRyIDw8
IDEgPj4gNjIpKSkgeworCQlpZiAodmVjID09IDIpIHsKKwkJCWlmIChfX2dwZm5faXNfaW8oKHZh
ZHIgPDwgMSkgPj4gKFBBR0VfU0hJRlQgKyAxKSkpIHsKKwkJCQllbXVsYXRlX2lvX2luc3Qodiwg
KCh2YWRyIDw8IDEpID4+IDEpLCA0KTsKKwkJCQlyZXR1cm47CisJCQl9CisJCX0KKwkJcGh5c2lj
YWxfdGxiX21pc3ModiwgdmFkciwgdHlwZSk7CisJCXJldHVybjsKKwl9CisJZGF0YSA9IHZ0bGJf
bG9va3VwKHYsIHZhZHIsIHR5cGUpOworCWlmIChkYXRhICE9IDApIHsKKwkJaWYgKHR5cGUgPT0g
RF9UTEIpIHsKKwkJCWdwcGEgPSAodmFkciAmICgoMVVMIDw8IGRhdGEtPnBzKSAtIDEpKQorCQkJ
CSsgKGRhdGEtPnBwbiA+PiAoZGF0YS0+cHMgLSAxMikgPDwgZGF0YS0+cHMpOworCQkJaWYgKF9f
Z3Bmbl9pc19pbyhncHBhID4+IFBBR0VfU0hJRlQpKSB7CisJCQkJaWYgKGRhdGEtPnBsID49ICgo
cmVncy0+Y3JfaXBzciA+PgorCQkJCQkJSUE2NF9QU1JfQ1BMMF9CSVQpICYgMykpCisJCQkJCWVt
dWxhdGVfaW9faW5zdCh2LCBncHBhLCBkYXRhLT5tYSk7CisJCQkJZWxzZSB7CisJCQkJCXZjcHVf
c2V0X2lzcih2LCBtaXNyLnZhbCk7CisJCQkJCWRhdGFfYWNjZXNzX3JpZ2h0cyh2LCB2YWRyKTsK
KwkJCQl9CisJCQkJcmV0dXJuIDsKKwkJCX0KKwkJfQorCQl0aGFzaF92aHB0X2luc2VydCh2LCBk
YXRhLT5wYWdlX2ZsYWdzLCBkYXRhLT5pdGlyLCB2YWRyLCB0eXBlKTsKKworCX0gZWxzZSBpZiAo
dHlwZSA9PSBEX1RMQikgeworCQlpZiAobWlzci5zcCkgeworCQkJaGFuZGxlX2xkcyhyZWdzKTsK
KwkJCXJldHVybjsKKwkJfQorCisJCXJyID0gdmNwdV9nZXRfcnIodiwgdmFkcik7CisJCWl0aXIg
PSByciAmIChSUl9SSURfTUFTSyB8IFJSX1BTX01BU0spOworCisJCWlmICghdmhwdF9lbmFibGVk
KHYsIHZhZHIsIG1pc3IucnMgPyBSU0VfUkVGIDogREFUQV9SRUYpKSB7CisJCQlpZiAodnBzci5p
YykgeworCQkJCXZjcHVfc2V0X2lzcih2LCBtaXNyLnZhbCk7CisJCQkJYWx0X2R0bGIodiwgdmFk
cik7CisJCQl9IGVsc2UgeworCQkJCW5lc3RlZF9kdGxiKHYpOworCQkJfQorCQkJcmV0dXJuIDsK
KwkJfQorCisJCXZwdGEudmFsID0gdmNwdV9nZXRfcHRhKHYpOworCQkvKiBhdm9pZCByZWN1cnNp
dmVseSB3YWxraW5nIChzaG9ydCBmb3JtYXQpIFZIUFQgKi8KKworCQl2aHB0X2FkciA9IHZjcHVf
dGhhc2godiwgdmFkcik7CisJCWlmICghZ3Vlc3RfdmhwdF9sb29rdXAodmhwdF9hZHIsICZwdGV2
YWwpKSB7CisJCQkvKiBWSFBUIHN1Y2Nlc3NmdWxseSByZWFkLiAgKi8KKwkJCWlmICghKHB0ZXZh
bCAmIF9QQUdFX1ApKSB7CisJCQkJaWYgKHZwc3IuaWMpIHsKKwkJCQkJdmNwdV9zZXRfaXNyKHYs
IG1pc3IudmFsKTsKKwkJCQkJZHRsYl9mYXVsdCh2LCB2YWRyKTsKKwkJCQl9IGVsc2UgeworCQkJ
CQluZXN0ZWRfZHRsYih2KTsKKwkJCQl9CisJCQl9IGVsc2UgaWYgKChwdGV2YWwgJiBfUEFHRV9N
QV9NQVNLKSAhPSBfUEFHRV9NQV9TVCkgeworCQkJCXRoYXNoX3B1cmdlX2FuZF9pbnNlcnQodiwg
cHRldmFsLCBpdGlyLAorCQkJCQkJCQl2YWRyLCBEX1RMQik7CisJCQl9IGVsc2UgaWYgKHZwc3Iu
aWMpIHsKKwkJCQl2Y3B1X3NldF9pc3IodiwgbWlzci52YWwpOworCQkJCWR0bGJfZmF1bHQodiwg
dmFkcik7CisJCQl9IGVsc2UgeworCQkJCW5lc3RlZF9kdGxiKHYpOworCQkJfQorCQl9IGVsc2Ug
eworCQkJLyogQ2FuJ3QgcmVhZCBWSFBULiAgKi8KKwkJCWlmICh2cHNyLmljKSB7CisJCQkJdmNw
dV9zZXRfaXNyKHYsIG1pc3IudmFsKTsKKwkJCQlkdmhwdF9mYXVsdCh2LCB2YWRyKTsKKwkJCX0g
ZWxzZSB7CisJCQkJbmVzdGVkX2R0bGIodik7CisJCQl9CisJCX0KKwl9IGVsc2UgaWYgKHR5cGUg
PT0gSV9UTEIpIHsKKwkJaWYgKCF2cHNyLmljKQorCQkJbWlzci5uaSA9IDE7CisJCWlmICghdmhw
dF9lbmFibGVkKHYsIHZhZHIsIElOU1RfUkVGKSkgeworCQkJdmNwdV9zZXRfaXNyKHYsIG1pc3Iu
dmFsKTsKKwkJCWFsdF9pdGxiKHYsIHZhZHIpOworCQkJcmV0dXJuOworCQl9CisKKwkJdnB0YS52
YWwgPSB2Y3B1X2dldF9wdGEodik7CisKKwkJdmhwdF9hZHIgPSB2Y3B1X3RoYXNoKHYsIHZhZHIp
OworCQlpZiAoIWd1ZXN0X3ZocHRfbG9va3VwKHZocHRfYWRyLCAmcHRldmFsKSkgeworCQkJLyog
VkhQVCBzdWNjZXNzZnVsbHkgcmVhZC4gICovCisJCQlpZiAocHRldmFsICYgX1BBR0VfUCkgewor
CQkJCWlmICgocHRldmFsICYgX1BBR0VfTUFfTUFTSykgPT0gX1BBR0VfTUFfU1QpIHsKKwkJCQkJ
dmNwdV9zZXRfaXNyKHYsIG1pc3IudmFsKTsKKwkJCQkJaXRsYl9mYXVsdCh2LCB2YWRyKTsKKwkJ
CQkJcmV0dXJuIDsKKwkJCQl9CisJCQkJcnIgPSB2Y3B1X2dldF9ycih2LCB2YWRyKTsKKwkJCQlp
dGlyID0gcnIgJiAoUlJfUklEX01BU0sgfCBSUl9QU19NQVNLKTsKKwkJCQl0aGFzaF9wdXJnZV9h
bmRfaW5zZXJ0KHYsIHB0ZXZhbCwgaXRpciwKKwkJCQkJCQl2YWRyLCBJX1RMQik7CisJCQl9IGVs
c2UgeworCQkJCXZjcHVfc2V0X2lzcih2LCBtaXNyLnZhbCk7CisJCQkJaW5zdF9wYWdlX25vdF9w
cmVzZW50KHYsIHZhZHIpOworCQkJfQorCQl9IGVsc2UgeworCQkJdmNwdV9zZXRfaXNyKHYsIG1p
c3IudmFsKTsKKwkJCWl2aHB0X2ZhdWx0KHYsIHZhZHIpOworCQl9CisJfQorfQorCit2b2lkIGt2
bV92ZXhpcnEoVkNQVSAqdmNwdSkKK3sKKwl1NjQgdnBzciwgaXNyOworCVJFR1MgKnJlZ3M7CisK
KwlyZWdzID0gdmNwdV9yZWdzKHZjcHUpOworCXZwc3IgPSBWQ1BVKHZjcHUsIHZwc3IpOworCWlz
ciA9IHZwc3IgJiBJQTY0X1BTUl9SSTsKKwlyZWZsZWN0X2ludGVycnVwdGlvbigwLCBpc3IsIDAs
IDEyLCByZWdzKTsgLypFWFQgSVJRKi8KK30KKwordm9pZCBrdm1faWE2NF9oYW5kbGVfaXJxKFZD
UFUgKnYpCit7CisJc3RydWN0IGV4aXRfY3RsX2RhdGEgKnAgPSAmdi0+YXJjaC5leGl0X2RhdGE7
CisJbG9uZyBwc3I7CisKKwlsb2NhbF9pcnFfc2F2ZShwc3IpOworCXAtPmV4aXRfcmVhc29uID0g
RVhJVF9SRUFTT05fRVhURVJOQUxfSU5URVJSVVBUOworCXZtbV90cmFuc2l0aW9uKHYpOworCWxv
Y2FsX2lycV9yZXN0b3JlKHBzcik7CisKKwlWTVgodiwgdGltZXJfY2hlY2spID0gMTsKKworfQor
CitzdGF0aWMgdm9pZCBwdGNfZ2FfcmVtb3RlX2Z1bmMoc3RydWN0IGt2bV92Y3B1ICp2LCBpbnQg
cG9zKQoreworCXU2NCBvbGRyaWQsIG1vbGRyaWQsIG9sZHBzYml0cywgdmFkZHI7CisJc3RydWN0
IGt2bV9wdGNfZyAqcCA9ICZ2LT5hcmNoLnB0Y19nX2RhdGFbcG9zXTsKKwl2YWRkciA9IHAtPnZh
ZGRyOworCisJb2xkcmlkID0gVk1YKHYsIHZyclswXSk7CisJVk1YKHYsIHZyclswXSkgPSBwLT5y
cjsKKwlvbGRwc2JpdHMgPSBWTVgodiwgcHNiaXRzWzBdKTsKKwlWTVgodiwgcHNiaXRzWzBdKSA9
IFZNWCh2LCBwc2JpdHNbUkVHSU9OX05VTUJFUih2YWRkcildKTsKKwltb2xkcmlkID0gaWE2NF9n
ZXRfcnIoMHgwKTsKKwlpYTY0X3NldF9ycigweDAsIHZycnRvbXJyKHAtPnJyKSk7CisJaWE2NF9z
cmx6X2QoKTsKKworCXZhZGRyID0gUEFHRUFMSUdOKHZhZGRyLCBwLT5wcyk7CisJdGhhc2hfcHVy
Z2VfZW50cmllc19yZW1vdGUodiwgdmFkZHIsIHAtPnBzKTsKKworCVZNWCh2LCB2cnJbMF0pID0g
b2xkcmlkOworCVZNWCh2LCBwc2JpdHNbMF0pID0gb2xkcHNiaXRzOworCWlhNjRfc2V0X3JyKDB4
MCwgbW9sZHJpZCk7CisJaWE2NF9kdl9zZXJpYWxpemVfZGF0YSgpOworfQorCitzdGF0aWMgdm9p
ZCB2Y3B1X2RvX3Jlc3VtZShzdHJ1Y3Qga3ZtX3ZjcHUgKnZjcHUpCit7CisJLypSZS1pbml0IFZI
UFQgYW5kIFZUTEIgb25jZSBmcm9tIHJlc3VtZSovCisJdmNwdS0+YXJjaC52aHB0Lm51bSA9IFZI
UFRfTlVNX0VOVFJJRVM7CisJdGhhc2hfaW5pdCgmdmNwdS0+YXJjaC52aHB0LCBWSFBUX1NISUZU
KTsKKwl2Y3B1LT5hcmNoLnZ0bGIubnVtID0gVlRMQl9OVU1fRU5UUklFUzsKKwl0aGFzaF9pbml0
KCZ2Y3B1LT5hcmNoLnZ0bGIsIFZUTEJfU0hJRlQpOworCisJaWE2NF9zZXRfcHRhKHZjcHUtPmFy
Y2gudmhwdC5wdGEudmFsKTsKK30KKworc3RhdGljIHZvaWQga3ZtX2RvX3Jlc3VtZV9vcChzdHJ1
Y3Qga3ZtX3ZjcHUgKnZjcHUpCit7CisJaWYgKHRlc3RfYW5kX2NsZWFyX2JpdChLVk1fUkVRX1JF
U1VNRSwgJnZjcHUtPnJlcXVlc3RzKSkgeworCQl2Y3B1X2RvX3Jlc3VtZSh2Y3B1KTsKKwkJcmV0
dXJuOworCX0KKworCWlmICh1bmxpa2VseSh0ZXN0X2FuZF9jbGVhcl9iaXQoS1ZNX1JFUV9UTEJf
RkxVU0gsICZ2Y3B1LT5yZXF1ZXN0cykpKSB7CisJCXRoYXNoX3B1cmdlX2FsbCh2Y3B1KTsKKwkJ
cmV0dXJuOworCX0KKworCWlmICh0ZXN0X2FuZF9jbGVhcl9iaXQoS1ZNX1JFUV9QVENfRywgJnZj
cHUtPnJlcXVlc3RzKSkgeworCQl3aGlsZSAodmNwdS0+YXJjaC5wdGNfZ19jb3VudCA+IDApCisJ
CQlwdGNfZ2FfcmVtb3RlX2Z1bmModmNwdSwgLS12Y3B1LT5hcmNoLnB0Y19nX2NvdW50KTsKKwl9
Cit9CisKK3ZvaWQgdm1tX3RyYW5zaXRpb24oc3RydWN0IGt2bV92Y3B1ICp2Y3B1KQoreworCWlh
NjRfY2FsbF92c2EoUEFMX1ZQU19TQVZFLCAodW5zaWduZWQgbG9uZyl2Y3B1LT5hcmNoLnZwZCwK
KwkJCTAsIDAsIDAsIDAsIDAsIDApOworCXZtbV90cmFtcG9saW5lKCZ2Y3B1LT5hcmNoLmd1ZXN0
LCAmdmNwdS0+YXJjaC5ob3N0KTsKKwlpYTY0X2NhbGxfdnNhKFBBTF9WUFNfUkVTVE9SRSwgKHVu
c2lnbmVkIGxvbmcpdmNwdS0+YXJjaC52cGQsCisJCQkJCQkwLCAwLCAwLCAwLCAwLCAwKTsKKwlr
dm1fZG9fcmVzdW1lX29wKHZjcHUpOworfQotLSAKMS41LjIKCg==

------_=_NextPart_001_01C890BA.3FCD69CF--
