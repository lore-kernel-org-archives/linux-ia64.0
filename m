From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Mon, 31 Mar 2008 08:30:59 +0000
Subject: [14/17][PATCH] kvm/ia64: Add guest interruption injection support. V8
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDC01048258@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C89309.8C88089B"
List-Id: <linux-ia64.vger.kernel.org>
References: <42DFA526FC41B1429CE7279EF83C6BDCFF7EF2@pdsmsx415.ccr.corp.intel.com>
In-Reply-To: <42DFA526FC41B1429CE7279EF83C6BDCFF7EF2@pdsmsx415.ccr.corp.intel.com>
To: Avi Kivity <avi@qumranet.com>, "Luck, Tony" <tony.luck@intel.com>, "Xu, Anthony" <anthony.xu@intel.com>, Jes Sorensen <jes@sgi.com>, Akio Takebe <takebe_akio@jp.fujitsu.com>, 

This is a multi-part message in MIME format.

------_=_NextPart_001_01C89309.8C88089B
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

From 9be1ae8da8cf2cb32c48d47c1639864780494047 Mon Sep 17 00:00:00 2001
From: Xiantao Zhang <xiantao.zhang@intel.com>
Date: Wed, 12 Mar 2008 13:50:49 +0800
Subject: [PATCH] KVM:IA64 : Add guest interruption injection support.

process.c mainly handle interruption injection, and some
faults handling.
Signed-off-by: Anthony Xu <anthony.xu@intel.com>
Signed-off-by: Xiantao Zhang <xiantao.zhang@intel.com>
---
 arch/ia64/kvm/process.c |  982
+++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 982 insertions(+), 0 deletions(-)
 create mode 100644 arch/ia64/kvm/process.c

diff --git a/arch/ia64/kvm/process.c b/arch/ia64/kvm/process.c
new file mode 100644
index 0000000..271ff68
--- /dev/null
+++ b/arch/ia64/kvm/process.c
@@ -0,0 +1,982 @@
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
+#define INITIAL_PSR_VALUE_AT_INTERRUPTION IA64_PSR_UP| IA64_PSR_MFL|
\
+			IA64_PSR_MFH|IA64_PSR_PK|IA64_PSR_DT|
\
+			IA64_PSR_RT|IA64_PSR_MC|IA64_PSR_IT
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

------_=_NextPart_001_01C89309.8C88089B
Content-Type: application/octet-stream;
	name="0014-KVM-IA64-Add-guest-interruption-injection-support.patch"
Content-Transfer-Encoding: base64
Content-Description: 0014-KVM-IA64-Add-guest-interruption-injection-support.patch
Content-Disposition: attachment;
	filename="0014-KVM-IA64-Add-guest-interruption-injection-support.patch"

RnJvbSA5YmUxYWU4ZGE4Y2YyY2IzMmM0OGQ0N2MxNjM5ODY0NzgwNDk0MDQ3IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBYaWFudGFvIFpoYW5nIDx4aWFudGFvLnpoYW5nQGludGVsLmNv
bT4KRGF0ZTogV2VkLCAxMiBNYXIgMjAwOCAxMzo1MDo0OSArMDgwMApTdWJqZWN0OiBbUEFUQ0hd
IEtWTTpJQTY0IDogQWRkIGd1ZXN0IGludGVycnVwdGlvbiBpbmplY3Rpb24gc3VwcG9ydC4KCnBy
b2Nlc3MuYyBtYWlubHkgaGFuZGxlIGludGVycnVwdGlvbiBpbmplY3Rpb24sIGFuZCBzb21lCmZh
dWx0cyBoYW5kbGluZy4KU2lnbmVkLW9mZi1ieTogQW50aG9ueSBYdSA8YW50aG9ueS54dUBpbnRl
bC5jb20+ClNpZ25lZC1vZmYtYnk6IFhpYW50YW8gWmhhbmcgPHhpYW50YW8uemhhbmdAaW50ZWwu
Y29tPgotLS0KIGFyY2gvaWE2NC9rdm0vcHJvY2Vzcy5jIHwgIDk4MiArKysrKysrKysrKysrKysr
KysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKwogMSBmaWxlcyBjaGFuZ2VkLCA5ODIgaW5z
ZXJ0aW9ucygrKSwgMCBkZWxldGlvbnMoLSkKIGNyZWF0ZSBtb2RlIDEwMDY0NCBhcmNoL2lhNjQv
a3ZtL3Byb2Nlc3MuYwoKZGlmZiAtLWdpdCBhL2FyY2gvaWE2NC9rdm0vcHJvY2Vzcy5jIGIvYXJj
aC9pYTY0L2t2bS9wcm9jZXNzLmMKbmV3IGZpbGUgbW9kZSAxMDA2NDQKaW5kZXggMDAwMDAwMC4u
MjcxZmY2OAotLS0gL2Rldi9udWxsCisrKyBiL2FyY2gvaWE2NC9rdm0vcHJvY2Vzcy5jCkBAIC0w
LDAgKzEsOTgyIEBACisvKgorICogcHJvY2Vzcy5jOiBoYW5kbGUgaW50ZXJydXB0aW9uIGluamVj
dCBmb3IgZ3Vlc3RzLgorICogQ29weXJpZ2h0IChjKSAyMDA1LCBJbnRlbCBDb3Jwb3JhdGlvbi4K
KyAqCisgKiBUaGlzIHByb2dyYW0gaXMgZnJlZSBzb2Z0d2FyZTsgeW91IGNhbiByZWRpc3RyaWJ1
dGUgaXQgYW5kL29yIG1vZGlmeSBpdAorICogdW5kZXIgdGhlIHRlcm1zIGFuZCBjb25kaXRpb25z
IG9mIHRoZSBHTlUgR2VuZXJhbCBQdWJsaWMgTGljZW5zZSwKKyAqIHZlcnNpb24gMiwgYXMgcHVi
bGlzaGVkIGJ5IHRoZSBGcmVlIFNvZnR3YXJlIEZvdW5kYXRpb24uCisgKgorICogVGhpcyBwcm9n
cmFtIGlzIGRpc3RyaWJ1dGVkIGluIHRoZSBob3BlIGl0IHdpbGwgYmUgdXNlZnVsLCBidXQgV0lU
SE9VVAorICogQU5ZIFdBUlJBTlRZOyB3aXRob3V0IGV2ZW4gdGhlIGltcGxpZWQgd2FycmFudHkg
b2YgTUVSQ0hBTlRBQklMSVRZIG9yCisgKiBGSVRORVNTIEZPUiBBIFBBUlRJQ1VMQVIgUFVSUE9T
RS4gIFNlZSB0aGUgR05VIEdlbmVyYWwgUHVibGljIExpY2Vuc2UgZm9yCisgKiBtb3JlIGRldGFp
bHMuCisgKgorICogWW91IHNob3VsZCBoYXZlIHJlY2VpdmVkIGEgY29weSBvZiB0aGUgR05VIEdl
bmVyYWwgUHVibGljIExpY2Vuc2UgYWxvbmcgd2l0aAorICogdGhpcyBwcm9ncmFtOyBpZiBub3Qs
IHdyaXRlIHRvIHRoZSBGcmVlIFNvZnR3YXJlIEZvdW5kYXRpb24sIEluYy4sIDU5IFRlbXBsZQor
ICogUGxhY2UgLSBTdWl0ZSAzMzAsIEJvc3RvbiwgTUEgMDIxMTEtMTMwNyBVU0EuCisgKgorICog
IAlTaGFvZmFuIExpIChTdXN1ZSBMaSkgPHN1c2llLmxpQGludGVsLmNvbT4KKyAqICAJWGlhb3lh
biBGZW5nIChGbGVtaW5nIEZlbmcpICA8ZmxlbWluZy5mZW5nQGludGVsLmNvbT4KKyAqICAJWHVl
ZmVpIFh1IChBbnRob255IFh1KSAoQW50aG9ueS54dUBpbnRlbC5jb20pCisgKiAgCVhpYW50YW8g
WmhhbmcgKHhpYW50YW8uemhhbmdAaW50ZWwuY29tKQorICovCisjaW5jbHVkZSAidmNwdS5oIgor
CisjaW5jbHVkZSA8YXNtL3BhbC5oPgorI2luY2x1ZGUgPGFzbS9zYWwuaD4KKyNpbmNsdWRlIDxh
c20vZnBzd2EuaD4KKyNpbmNsdWRlIDxhc20va3JlZ3MuaD4KKworZnBzd2FfaW50ZXJmYWNlX3Qg
KnZtbV9mcHN3YV9pbnRlcmZhY2U7CisKKyNkZWZpbmUgSUE2NF9WSFBUX1RSQU5TX1ZFQ1RPUgkJ
CTB4MDAwMAorI2RlZmluZSBJQTY0X0lOU1RfVExCX1ZFQ1RPUgkJCTB4MDQwMAorI2RlZmluZSBJ
QTY0X0RBVEFfVExCX1ZFQ1RPUgkJCTB4MDgwMAorI2RlZmluZSBJQTY0X0FMVF9JTlNUX1RMQl9W
RUNUT1IJCTB4MGMwMAorI2RlZmluZSBJQTY0X0FMVF9EQVRBX1RMQl9WRUNUT1IJCTB4MTAwMAor
I2RlZmluZSBJQTY0X0RBVEFfTkVTVEVEX1RMQl9WRUNUT1IJCTB4MTQwMAorI2RlZmluZSBJQTY0
X0lOU1RfS0VZX01JU1NfVkVDVE9SCQkweDE4MDAKKyNkZWZpbmUgSUE2NF9EQVRBX0tFWV9NSVNT
X1ZFQ1RPUgkJMHgxYzAwCisjZGVmaW5lIElBNjRfRElSVFlfQklUX1ZFQ1RPUgkJCTB4MjAwMAor
I2RlZmluZSBJQTY0X0lOU1RfQUNDRVNTX0JJVF9WRUNUT1IJCTB4MjQwMAorI2RlZmluZSBJQTY0
X0RBVEFfQUNDRVNTX0JJVF9WRUNUT1IJCTB4MjgwMAorI2RlZmluZSBJQTY0X0JSRUFLX1ZFQ1RP
UgkJCTB4MmMwMAorI2RlZmluZSBJQTY0X0VYVElOVF9WRUNUT1IJCQkweDMwMDAKKyNkZWZpbmUg
SUE2NF9QQUdFX05PVF9QUkVTRU5UX1ZFQ1RPUgkJMHg1MDAwCisjZGVmaW5lIElBNjRfS0VZX1BF
Uk1JU1NJT05fVkVDVE9SCQkweDUxMDAKKyNkZWZpbmUgSUE2NF9JTlNUX0FDQ0VTU19SSUdIVFNf
VkVDVE9SCQkweDUyMDAKKyNkZWZpbmUgSUE2NF9EQVRBX0FDQ0VTU19SSUdIVFNfVkVDVE9SCQkw
eDUzMDAKKyNkZWZpbmUgSUE2NF9HRU5FWF9WRUNUT1IJCQkweDU0MDAKKyNkZWZpbmUgSUE2NF9E
SVNBQkxFRF9GUFJFR19WRUNUT1IJCTB4NTUwMAorI2RlZmluZSBJQTY0X05BVF9DT05TVU1QVElP
Tl9WRUNUT1IJCTB4NTYwMAorI2RlZmluZSBJQTY0X1NQRUNVTEFUSU9OX1ZFQ1RPUgkJMHg1NzAw
IC8qIFVOVVNFRCAqLworI2RlZmluZSBJQTY0X0RFQlVHX1ZFQ1RPUgkJCTB4NTkwMAorI2RlZmlu
ZSBJQTY0X1VOQUxJR05FRF9SRUZfVkVDVE9SCQkweDVhMDAKKyNkZWZpbmUgSUE2NF9VTlNVUFBP
UlRFRF9EQVRBX1JFRl9WRUNUT1IJMHg1YjAwCisjZGVmaW5lIElBNjRfRlBfRkFVTFRfVkVDVE9S
CQkJMHg1YzAwCisjZGVmaW5lIElBNjRfRlBfVFJBUF9WRUNUT1IJCQkweDVkMDAKKyNkZWZpbmUg
SUE2NF9MT1dFUlBSSVZfVFJBTlNGRVJfVFJBUF9WRUNUT1IgCTB4NWUwMAorI2RlZmluZSBJQTY0
X1RBS0VOX0JSQU5DSF9UUkFQX1ZFQ1RPUgkJMHg1ZjAwCisjZGVmaW5lIElBNjRfU0lOR0xFX1NU
RVBfVFJBUF9WRUNUT1IJCTB4NjAwMAorCisvKiBTRE0gdm9sMiA1LjUgLSBJVkEgYmFzZWQgaW50
ZXJydXB0aW9uIGhhbmRsaW5nICovCisjZGVmaW5lIElOSVRJQUxfUFNSX1ZBTFVFX0FUX0lOVEVS
UlVQVElPTiBJQTY0X1BTUl9VUHwgSUE2NF9QU1JfTUZMfAlcCisJCQlJQTY0X1BTUl9NRkh8SUE2
NF9QU1JfUEt8SUE2NF9QU1JfRFR8ICAgIAlcCisJCQlJQTY0X1BTUl9SVHxJQTY0X1BTUl9NQ3xJ
QTY0X1BTUl9JVAorCisjZGVmaW5lIERPTU5fUEFMX1JFUVVFU1QgICAgMHgxMTAwMDAKKyNkZWZp
bmUgRE9NTl9TQUxfUkVRVUVTVCAgICAweDExMDAwMQorCitzdGF0aWMgdTY0IHZlYzJvZmZbNjhd
ID0gezB4MCwgMHg0MDAsIDB4ODAwLCAweGMwMCwgMHgxMDAwLCAweDE0MDAsIDB4MTgwMCwKKwkw
eDFjMDAsIDB4MjAwMCwgMHgyNDAwLCAweDI4MDAsIDB4MmMwMCwgMHgzMDAwLCAweDM0MDAsIDB4
MzgwMCwgMHgzYzAwLAorCTB4NDAwMCwgMHg0NDAwLCAweDQ4MDAsIDB4NGMwMCwgMHg1MDAwLCAw
eDUxMDAsIDB4NTIwMCwgMHg1MzAwLCAweDU0MDAsCisJMHg1NTAwLCAweDU2MDAsIDB4NTcwMCwg
MHg1ODAwLCAweDU5MDAsIDB4NWEwMCwgMHg1YjAwLCAweDVjMDAsIDB4NWQwMCwKKwkweDVlMDAs
IDB4NWYwMCwgMHg2MDAwLCAweDYxMDAsIDB4NjIwMCwgMHg2MzAwLCAweDY0MDAsIDB4NjUwMCwg
MHg2NjAwLAorCTB4NjcwMCwgMHg2ODAwLCAweDY5MDAsIDB4NmEwMCwgMHg2YjAwLCAweDZjMDAs
IDB4NmQwMCwgMHg2ZTAwLCAweDZmMDAsCisJMHg3MDAwLCAweDcxMDAsIDB4NzIwMCwgMHg3MzAw
LCAweDc0MDAsIDB4NzUwMCwgMHg3NjAwLCAweDc3MDAsIDB4NzgwMCwKKwkweDc5MDAsIDB4N2Ew
MCwgMHg3YjAwLCAweDdjMDAsIDB4N2QwMCwgMHg3ZTAwLCAweDdmMDAKK307CisKK3N0YXRpYyB2
b2lkIGNvbGxlY3RfaW50ZXJydXB0aW9uKFZDUFUgKnZjcHUpCit7CisJdTY0IGlwc3I7CisJdTY0
IHZkY3I7CisJdTY0IHZpZnM7CisJaWE2NF9wc3IgdnBzcjsKKwlSRUdTICpyZWdzID0gdmNwdV9y
ZWdzKHZjcHUpOworCisJdnBzci52YWwgPSB2Y3B1X2dldF9wc3IodmNwdSk7CisJdmNwdV9ic3cw
KHZjcHUpOworCWlmICh2cHNyLmljKSB7CisKKwkJLyogU3luYyBtcHNyIGlkL2RhL2RkL3NzL2Vk
IGJpdHMgdG8gdmlwc3IKKwkJICogc2luY2UgYWZ0ZXIgZ3Vlc3QgZG8gcmZpLCB3ZSBzdGlsbCB3
YW50IHRoZXNlIGJpdHMgb24gaW4KKwkJICogbXBzcgorCQkgKi8KKworCQlpcHNyID0gcmVncy0+
Y3JfaXBzcjsKKwkJdnBzci52YWwgPSB2cHNyLnZhbCB8IChpcHNyICYgKElBNjRfUFNSX0lEIHwg
SUE2NF9QU1JfREEKKwkJCQkJfCBJQTY0X1BTUl9ERCB8IElBNjRfUFNSX1NTCisJCQkJCXwgSUE2
NF9QU1JfRUQpKTsKKwkJdmNwdV9zZXRfaXBzcih2Y3B1LCB2cHNyLnZhbCk7CisKKwkJLyogQ3Vy
cmVudGx5LCBmb3IgdHJhcCwgd2UgZG8gbm90IGFkdmFuY2UgSUlQIHRvIG5leHQKKwkJICogaW5z
dHJ1Y3Rpb24uIFRoYXQncyBiZWNhdXNlIHdlIGFzc3VtZSBjYWxsZXIgYWxyZWFkeQorCQkgKiBz
ZXQgdXAgSUlQIGNvcnJlY3RseQorCQkgKi8KKworCQl2Y3B1X3NldF9paXAodmNwdSAsIHJlZ3Mt
PmNyX2lpcCk7CisKKwkJLyogc2V0IHZpZnMudiB0byB6ZXJvICovCisJCXZpZnMgPSBWQ1BVKHZj
cHUsIGlmcyk7CisJCXZpZnMgJj0gfklBNjRfSUZTX1Y7CisJCXZjcHVfc2V0X2lmcyh2Y3B1LCB2
aWZzKTsKKworCQl2Y3B1X3NldF9paXBhKHZjcHUsIFZNWCh2Y3B1LCBjcl9paXBhKSk7CisJfQor
CisJdmRjciA9IFZDUFUodmNwdSwgZGNyKTsKKworCS8qIFNldCBndWVzdCBwc3IKKwkgKiB1cC9t
ZmwvbWZoL3BrL2R0L3J0L21jL2l0IGtlZXBzIHVuY2hhbmdlZAorCSAqIGJlOiBzZXQgdG8gdGhl
IHZhbHVlIG9mIGRjci5iZQorCSAqIHBwOiBzZXQgdG8gdGhlIHZhbHVlIG9mIGRjci5wcAorCSAq
LworCXZwc3IudmFsICY9IElOSVRJQUxfUFNSX1ZBTFVFX0FUX0lOVEVSUlVQVElPTjsKKwl2cHNy
LnZhbCB8PSAodmRjciAmIElBNjRfRENSX0JFKTsKKworCS8qIFZEQ1IgcHAgYml0IHBvc2l0aW9u
IGlzIGRpZmZlcmVudCBmcm9tIFZQU1IgcHAgYml0ICovCisJaWYgKHZkY3IgJiBJQTY0X0RDUl9Q
UCkgeworCQl2cHNyLnZhbCB8PSBJQTY0X1BTUl9QUDsKKwl9IGVsc2UgeworCQl2cHNyLnZhbCAm
PSB+SUE2NF9QU1JfUFA7OworCX0KKworCXZjcHVfc2V0X3Bzcih2Y3B1LCB2cHNyLnZhbCk7CisK
K30KKwordm9pZCBpbmplY3RfZ3Vlc3RfaW50ZXJydXB0aW9uKFZDUFUgKnZjcHUsIHU2NCB2ZWMp
Cit7CisJdTY0IHZpdmE7CisJUkVHUyAqcmVnczsKKwlpYTY0X2lzciBwdF9pc3I7CisKKwlyZWdz
ID0gdmNwdV9yZWdzKHZjcHUpOworCisJLyogY2xlYXIgY3IuaXNyLmlyIChpbmNvbXBsZXRlIHJl
Z2lzdGVyIGZyYW1lKSovCisJcHRfaXNyLnZhbCA9IFZNWCh2Y3B1LCBjcl9pc3IpOworCXB0X2lz
ci5pciA9IDA7CisJVk1YKHZjcHUsIGNyX2lzcikgPSBwdF9pc3IudmFsOworCisJY29sbGVjdF9p
bnRlcnJ1cHRpb24odmNwdSk7CisKKwl2aXZhID0gdmNwdV9nZXRfaXZhKHZjcHUpOworCXJlZ3Mt
PmNyX2lpcCA9IHZpdmEgKyB2ZWM7Cit9CisKK3N0YXRpYyB1NjQgdmNwdV9nZXRfaXRpcl9vbl9m
YXVsdChWQ1BVICp2Y3B1LCB1NjQgaWZhKQoreworCWlhNjRfcnIgcnIsIHJyMTsKKworCXJyLnZh
bCA9IHZjcHVfZ2V0X3JyKHZjcHUsIGlmYSk7CisJcnIxLnZhbCA9IDA7CisJcnIxLnBzID0gcnIu
cHM7CisJcnIxLnJpZCA9IHJyLnJpZDsKKwlyZXR1cm4gKHJyMS52YWwpOworfQorCisKKy8qCisg
KiBTZXQgdklGQSAmIHZJVElSICYgdklIQSwgd2hlbiB2UFNSLmljID0xCisgKiBQYXJhbWV0ZXI6
CisgKiAgc2V0X2lmYTogaWYgdHJ1ZSwgc2V0IHZJRkEKKyAqICBzZXRfaXRpcjogaWYgdHJ1ZSwg
c2V0IHZJVElSCisgKiAgc2V0X2loYTogaWYgdHJ1ZSwgc2V0IHZJSEEKKyAqLwordm9pZCBzZXRf
aWZhX2l0aXJfaWhhKFZDUFUgKnZjcHUsIHU2NCB2YWRyLAorCQlpbnQgc2V0X2lmYSwgaW50IHNl
dF9pdGlyLCBpbnQgc2V0X2loYSkKK3sKKwlpYTY0X3BzciB2cHNyOworCXU2NCB2YWx1ZTsKKwor
CXZwc3IudmFsID0gVkNQVSh2Y3B1LCB2cHNyKTsKKwkvKiBWb2wyLCBUYWJsZSA4LTEgKi8KKwlp
ZiAodnBzci5pYykgeworCQlpZiAoc2V0X2lmYSkgeworCQkJdmNwdV9zZXRfaWZhKHZjcHUsIHZh
ZHIpOworCQl9CisJCWlmIChzZXRfaXRpcikgeworCQkJdmFsdWUgPSB2Y3B1X2dldF9pdGlyX29u
X2ZhdWx0KHZjcHUsIHZhZHIpOworCQkJdmNwdV9zZXRfaXRpcih2Y3B1LCB2YWx1ZSk7CisJCX0K
KworCQlpZiAoc2V0X2loYSkgeworCQkJdmFsdWUgPSB2Y3B1X3RoYXNoKHZjcHUsIHZhZHIpOwor
CQkJdmNwdV9zZXRfaWhhKHZjcHUsIHZhbHVlKTsKKwkJfQorCX0KK30KKworLyoKKyAqIERhdGEg
VExCIEZhdWx0CisgKiAgQCBEYXRhIFRMQiB2ZWN0b3IKKyAqIFJlZmVyIHRvIFNETSBWb2wyIFRh
YmxlIDUtNiAmIDgtMQorICovCit2b2lkIGR0bGJfZmF1bHQoVkNQVSAqdmNwdSwgdTY0IHZhZHIp
Cit7CisJLyogSWYgdlBTUi5pYywgSUZBLCBJVElSLCBJSEEgKi8KKwlzZXRfaWZhX2l0aXJfaWhh
KHZjcHUsIHZhZHIsIDEsIDEsIDEpOworCWluamVjdF9ndWVzdF9pbnRlcnJ1cHRpb24odmNwdSwg
SUE2NF9EQVRBX1RMQl9WRUNUT1IpOworfQorCisvKgorICogSW5zdHJ1Y3Rpb24gVExCIEZhdWx0
CisgKiAgQCBJbnN0cnVjdGlvbiBUTEIgdmVjdG9yCisgKiBSZWZlciB0byBTRE0gVm9sMiBUYWJs
ZSA1LTYgJiA4LTEKKyAqLwordm9pZCBpdGxiX2ZhdWx0IChWQ1BVICp2Y3B1LCB1NjQgdmFkcikK
K3sKKwkvKiBJZiB2UFNSLmljLCBJRkEsIElUSVIsIElIQSAqLworCXNldF9pZmFfaXRpcl9paGEo
dmNwdSwgdmFkciwgMSwgMSwgMSk7CisJaW5qZWN0X2d1ZXN0X2ludGVycnVwdGlvbih2Y3B1LCBJ
QTY0X0lOU1RfVExCX1ZFQ1RPUik7Cit9CisKKworCisvKgorICogRGF0YSBOZXN0ZWQgVExCIEZh
dWx0CisgKiAgQCBEYXRhIE5lc3RlZCBUTEIgVmVjdG9yCisgKiBSZWZlciB0byBTRE0gVm9sMiBU
YWJsZSA1LTYgJiA4LTEKKyAqLwordm9pZCBuZXN0ZWRfZHRsYihWQ1BVICp2Y3B1KQoreworCWlu
amVjdF9ndWVzdF9pbnRlcnJ1cHRpb24odmNwdSwgSUE2NF9EQVRBX05FU1RFRF9UTEJfVkVDVE9S
KTsKK30KKworLyoKKyAqIEFsdGVybmF0ZSBEYXRhIFRMQiBGYXVsdAorICogIEAgQWx0ZXJuYXRl
IERhdGEgVExCIHZlY3RvcgorICogUmVmZXIgdG8gU0RNIFZvbDIgVGFibGUgNS02ICYgOC0xCisg
Ki8KK3ZvaWQgYWx0X2R0bGIoVkNQVSAqdmNwdSwgdTY0IHZhZHIpCit7CisJc2V0X2lmYV9pdGly
X2loYSh2Y3B1LCB2YWRyLCAxLCAxLCAwKTsKKwlpbmplY3RfZ3Vlc3RfaW50ZXJydXB0aW9uKHZj
cHUsIElBNjRfQUxUX0RBVEFfVExCX1ZFQ1RPUik7Cit9CisKKworLyoKKyAqIERhdGEgVExCIEZh
dWx0CisgKiAgQCBEYXRhIFRMQiB2ZWN0b3IKKyAqIFJlZmVyIHRvIFNETSBWb2wyIFRhYmxlIDUt
NiAmIDgtMQorICovCit2b2lkIGFsdF9pdGxiKFZDUFUgKnZjcHUsIHU2NCB2YWRyKQoreworCXNl
dF9pZmFfaXRpcl9paGEodmNwdSwgdmFkciwgMSwgMSwgMCk7CisJaW5qZWN0X2d1ZXN0X2ludGVy
cnVwdGlvbih2Y3B1LCBJQTY0X0FMVF9JTlNUX1RMQl9WRUNUT1IpOworfQorCisvKiBEZWFsIHdp
dGg6CisgKiAgVkhQVCBUcmFuc2xhdGlvbiBWZWN0b3IKKyAqLworc3RhdGljIHZvaWQgX3ZocHRf
ZmF1bHQoVkNQVSAqdmNwdSwgdTY0IHZhZHIpCit7CisJLyogSWYgdlBTUi5pYywgSUZBLCBJVElS
LCBJSEEqLworCXNldF9pZmFfaXRpcl9paGEodmNwdSwgdmFkciwgMSwgMSwgMSk7CisJaW5qZWN0
X2d1ZXN0X2ludGVycnVwdGlvbih2Y3B1LCBJQTY0X1ZIUFRfVFJBTlNfVkVDVE9SKTsKKworCit9
CisKKy8qCisgKiBWSFBUIEluc3RydWN0aW9uIEZhdWx0CisgKiAgQCBWSFBUIFRyYW5zbGF0aW9u
IHZlY3RvcgorICogUmVmZXIgdG8gU0RNIFZvbDIgVGFibGUgNS02ICYgOC0xCisgKi8KK3ZvaWQg
aXZocHRfZmF1bHQoVkNQVSAqdmNwdSwgdTY0IHZhZHIpCit7CisJX3ZocHRfZmF1bHQodmNwdSwg
dmFkcik7Cit9CisKKworLyoKKyAqIFZIUFQgRGF0YSBGYXVsdAorICogIEAgVkhQVCBUcmFuc2xh
dGlvbiB2ZWN0b3IKKyAqIFJlZmVyIHRvIFNETSBWb2wyIFRhYmxlIDUtNiAmIDgtMQorICovCit2
b2lkIGR2aHB0X2ZhdWx0KFZDUFUgKnZjcHUsIHU2NCB2YWRyKQoreworCV92aHB0X2ZhdWx0KHZj
cHUsIHZhZHIpOworfQorCisKKworLyoKKyAqIERlYWwgd2l0aDoKKyAqICBHZW5lcmFsIEV4Y2Vw
dGlvbiB2ZWN0b3IKKyAqLwordm9pZCBfZ2VuZXJhbF9leGNlcHRpb24oVkNQVSAqdmNwdSkKK3sK
KwlpbmplY3RfZ3Vlc3RfaW50ZXJydXB0aW9uKHZjcHUsIElBNjRfR0VORVhfVkVDVE9SKTsKK30K
KworCisvKgorICogSWxsZWdhbCBPcGVyYXRpb24gRmF1bHQKKyAqICBAIEdlbmVyYWwgRXhjZXB0
aW9uIFZlY3RvcgorICogUmVmZXIgdG8gU0RNIFZvbDIgVGFibGUgNS02ICYgOC0xCisgKi8KK3Zv
aWQgaWxsZWdhbF9vcChWQ1BVICp2Y3B1KQoreworCV9nZW5lcmFsX2V4Y2VwdGlvbih2Y3B1KTsK
K30KKworLyoKKyAqIElsbGVnYWwgRGVwZW5kZW5jeSBGYXVsdAorICogIEAgR2VuZXJhbCBFeGNl
cHRpb24gVmVjdG9yCisgKiBSZWZlciB0byBTRE0gVm9sMiBUYWJsZSA1LTYgJiA4LTEKKyAqLwor
dm9pZCBpbGxlZ2FsX2RlcChWQ1BVICp2Y3B1KQoreworCV9nZW5lcmFsX2V4Y2VwdGlvbih2Y3B1
KTsKK30KKworLyoKKyAqIFJlc2VydmVkIFJlZ2lzdGVyL0ZpZWxkIEZhdWx0CisgKiAgQCBHZW5l
cmFsIEV4Y2VwdGlvbiBWZWN0b3IKKyAqIFJlZmVyIHRvIFNETSBWb2wyIFRhYmxlIDUtNiAmIDgt
MQorICovCit2b2lkIHJzdl9yZWdfZmllbGQoVkNQVSAqdmNwdSkKK3sKKwlfZ2VuZXJhbF9leGNl
cHRpb24odmNwdSk7Cit9CisvKgorICogUHJpdmlsZWdlZCBPcGVyYXRpb24gRmF1bHQKKyAqICBA
IEdlbmVyYWwgRXhjZXB0aW9uIFZlY3RvcgorICogUmVmZXIgdG8gU0RNIFZvbDIgVGFibGUgNS02
ICYgOC0xCisgKi8KKwordm9pZCBwcml2aWxlZ2Vfb3AoVkNQVSAqdmNwdSkKK3sKKwlfZ2VuZXJh
bF9leGNlcHRpb24odmNwdSk7Cit9CisKKy8qCisgKiBVbmltcGxlbWVudCBEYXRhIEFkZHJlc3Mg
RmF1bHQKKyAqICBAIEdlbmVyYWwgRXhjZXB0aW9uIFZlY3RvcgorICogUmVmZXIgdG8gU0RNIFZv
bDIgVGFibGUgNS02ICYgOC0xCisgKi8KK3ZvaWQgdW5pbXBsX2RhZGRyKFZDUFUgKnZjcHUpCit7
CisJX2dlbmVyYWxfZXhjZXB0aW9uKHZjcHUpOworfQorCisvKgorICogUHJpdmlsZWdlZCBSZWdp
c3RlciBGYXVsdAorICogIEAgR2VuZXJhbCBFeGNlcHRpb24gVmVjdG9yCisgKiBSZWZlciB0byBT
RE0gVm9sMiBUYWJsZSA1LTYgJiA4LTEKKyAqLwordm9pZCBwcml2aWxlZ2VfcmVnKFZDUFUgKnZj
cHUpCit7CisJX2dlbmVyYWxfZXhjZXB0aW9uKHZjcHUpOworfQorCisvKiBEZWFsIHdpdGgKKyAq
ICBOYXQgY29uc3VtcHRpb24gdmVjdG9yCisgKiBQYXJhbWV0ZXI6CisgKiAgdmFkZHI6IE9wdGlv
bmFsLCBpZiB0ID09IFJFR0lTVEVSCisgKi8KK3N0YXRpYyB2b2lkIF9uYXRfY29uc3VtcHRpb25f
ZmF1bHQoVkNQVSAqdmNwdSwgdTY0IHZhZHIsIG1pc3NfdHlwZSB0KQoreworCS8qIElmIHZQU1Iu
aWMgJiYgdCA9PSBEQVRBL0lOU1QsIElGQSAqLworCWlmICh0ID09IERBVEEgfHwgdCA9PSBJTlNU
UlVDVElPTikgeworCQkvKiBJRkEgKi8KKwkJc2V0X2lmYV9pdGlyX2loYSh2Y3B1LCB2YWRyLCAx
LCAwLCAwKTsKKwl9CisKKwlpbmplY3RfZ3Vlc3RfaW50ZXJydXB0aW9uKHZjcHUsIElBNjRfTkFU
X0NPTlNVTVBUSU9OX1ZFQ1RPUik7Cit9CisKKy8qCisgKiBJUiBEYXRhIE5hdCBQYWdlIENvbnN1
bXB0aW9uIEZhdWx0CisgKiAgQCBOYXQgQ29uc3VtcHRpb24gVmVjdG9yCisgKiBSZWZlciB0byBT
RE0gVm9sMiBUYWJsZSA1LTYgJiA4LTEKKyAqLworI2lmIDAKKwlzdGF0aWMgdm9pZAoraXJfbmF0
X3BhZ2VfY29uc3VtcHRpb24oVkNQVSAqdmNwdSwgdTY0IHZhZHIpCit7CisJX25hdF9jb25zdW1w
dGlvbl9mYXVsdCh2Y3B1LCB2YWRyLCBEQVRBKTsKK30KKyNlbmRpZiAvKnNoYWRvdyBpdCBkdWUg
dG8gbm8gdXNlIGN1cnJlbnRseSovCisKKy8qCisgKiBJbnN0cnVjdGlvbiBOYXQgUGFnZSBDb25z
dW1wdGlvbiBGYXVsdAorICogIEAgTmF0IENvbnN1bXB0aW9uIFZlY3RvcgorICogUmVmZXIgdG8g
U0RNIFZvbDIgVGFibGUgNS02ICYgOC0xCisgKi8KK3ZvaWQgaW5hdF9wYWdlX2NvbnN1bXB0aW9u
KFZDUFUgKnZjcHUsIHU2NCB2YWRyKQoreworCV9uYXRfY29uc3VtcHRpb25fZmF1bHQodmNwdSwg
dmFkciwgSU5TVFJVQ1RJT04pOworfQorCisvKgorICogUmVnaXN0ZXIgTmF0IENvbnN1bXB0aW9u
IEZhdWx0CisgKiAgQCBOYXQgQ29uc3VtcHRpb24gVmVjdG9yCisgKiBSZWZlciB0byBTRE0gVm9s
MiBUYWJsZSA1LTYgJiA4LTEKKyAqLwordm9pZCBybmF0X2NvbnN1bXB0aW9uKFZDUFUgKnZjcHUp
Cit7CisJX25hdF9jb25zdW1wdGlvbl9mYXVsdCh2Y3B1LCAwLCBSRUdJU1RFUik7Cit9CisKKy8q
CisgKiBEYXRhIE5hdCBQYWdlIENvbnN1bXB0aW9uIEZhdWx0CisgKiAgQCBOYXQgQ29uc3VtcHRp
b24gVmVjdG9yCisgKiBSZWZlciB0byBTRE0gVm9sMiBUYWJsZSA1LTYgJiA4LTEKKyAqLwordm9p
ZCBkbmF0X3BhZ2VfY29uc3VtcHRpb24oVkNQVSAqdmNwdSwgdTY0IHZhZHIpCit7CisJX25hdF9j
b25zdW1wdGlvbl9mYXVsdCh2Y3B1LCB2YWRyLCBEQVRBKTsKK30KKworLyogRGVhbCB3aXRoCisg
KiAgUGFnZSBub3QgcHJlc2VudCB2ZWN0b3IKKyAqLworc3RhdGljIHZvaWQgX19wYWdlX25vdF9w
cmVzZW50KFZDUFUgKnZjcHUsIHU2NCB2YWRyKQoreworCS8qIElmIHZQU1IuaWMsIElGQSwgSVRJ
UiAqLworCXNldF9pZmFfaXRpcl9paGEodmNwdSwgdmFkciwgMSwgMSwgMCk7CisJaW5qZWN0X2d1
ZXN0X2ludGVycnVwdGlvbih2Y3B1LCBJQTY0X1BBR0VfTk9UX1BSRVNFTlRfVkVDVE9SKTsKK30K
KworCit2b2lkIGRhdGFfcGFnZV9ub3RfcHJlc2VudChWQ1BVICp2Y3B1LCB1NjQgdmFkcikKK3sK
KwlfX3BhZ2Vfbm90X3ByZXNlbnQodmNwdSwgdmFkcik7Cit9CisKKwordm9pZCBpbnN0X3BhZ2Vf
bm90X3ByZXNlbnQoVkNQVSAqdmNwdSwgdTY0IHZhZHIpCit7CisJX19wYWdlX25vdF9wcmVzZW50
KHZjcHUsIHZhZHIpOworfQorCisKKy8qIERlYWwgd2l0aAorICogIERhdGEgYWNjZXNzIHJpZ2h0
cyB2ZWN0b3IKKyAqLwordm9pZCBkYXRhX2FjY2Vzc19yaWdodHMoVkNQVSAqdmNwdSwgdTY0IHZh
ZHIpCit7CisJLyogSWYgdlBTUi5pYywgSUZBLCBJVElSICovCisJc2V0X2lmYV9pdGlyX2loYSh2
Y3B1LCB2YWRyLCAxLCAxLCAwKTsKKwlpbmplY3RfZ3Vlc3RfaW50ZXJydXB0aW9uKHZjcHUsIElB
NjRfREFUQV9BQ0NFU1NfUklHSFRTX1ZFQ1RPUik7Cit9CisKK2Zwc3dhX3JldF90IHZtbV9mcF9l
bXVsYXRlKGludCBmcF9mYXVsdCwgdm9pZCAqYnVuZGxlLCB1bnNpZ25lZCBsb25nICppcHNyLAor
CQl1bnNpZ25lZCBsb25nICpmcHNyLCB1bnNpZ25lZCBsb25nICppc3IsIHVuc2lnbmVkIGxvbmcg
KnByLAorCQl1bnNpZ25lZCBsb25nICppZnMsIFJFR1MgKnJlZ3MpCit7CisJZnBfc3RhdGVfdCBm
cF9zdGF0ZTsKKwlmcHN3YV9yZXRfdCByZXQ7CisJc3RydWN0IGt2bV92Y3B1ICp2Y3B1ID0gY3Vy
cmVudF92Y3B1OworCisJdWludDY0X3Qgb2xkX3JyNyA9IGlhNjRfZ2V0X3JyKDdVTDw8NjEpOwor
CisJaWYgKCF2bW1fZnBzd2FfaW50ZXJmYWNlKQorCQlyZXR1cm4gKGZwc3dhX3JldF90KSB7LTEs
IDAsIDAsIDB9OworCisJLyoKKwkgKiBKdXN0IGxldCBmcHN3YSBkcml2ZXIgdG8gdXNlIGhhcmR3
YXJlIGZwIHJlZ2lzdGVycy4KKwkgKiBObyBmcCByZWdpc3RlciBpcyB2YWxpZCBpbiBtZW1vcnku
CisJICovCisJbWVtc2V0KCZmcF9zdGF0ZSwgMCwgc2l6ZW9mKGZwX3N0YXRlX3QpKTsKKworCS8q
CisJICogdW5zaWduZWQgbG9uZyAoKkVGSV9GUFNXQSkgKAorCSAqICAgICAgdW5zaWduZWQgbG9u
ZyAgICB0cmFwX3R5cGUsCisJICogICAgICB2b2lkICAgICAgICAgICAgICpCdW5kbGUsCisJICog
ICAgICB1bnNpZ25lZCBsb25nICAgICpwaXBzciwKKwkgKiAgICAgIHVuc2lnbmVkIGxvbmcgICAg
KnBmc3IsCisJICogICAgICB1bnNpZ25lZCBsb25nICAgICpwaXNyLAorCSAqICAgICAgdW5zaWdu
ZWQgbG9uZyAgICAqcHByZWRzLAorCSAqICAgICAgdW5zaWduZWQgbG9uZyAgICAqcGlmcywKKwkg
KiAgICAgIHZvaWQgICAgICAgICAgICAgKmZwX3N0YXRlKTsKKwkgKi8KKwkvKkNhbGwgaG9zdCBm
cHN3YSBpbnRlcmZhY2UgZGlyZWN0bHkgdG8gdmlydHVhbGl6ZQorCSAqZ3Vlc3QgZnBzd2EgcmVx
dWVzdCEKKwkgKi8KKwlpYTY0X3NldF9ycig3VUwgPDwgNjEsIHZjcHUtPmFyY2guaG9zdC5ycls3
XSk7CisJaWE2NF9zcmx6X2QoKTsKKworCXJldCA9ICgqdm1tX2Zwc3dhX2ludGVyZmFjZS0+ZnBz
d2EpIChmcF9mYXVsdCwgYnVuZGxlLAorCQkJaXBzciwgZnBzciwgaXNyLCBwciwgaWZzLCAmZnBf
c3RhdGUpOworCWlhNjRfc2V0X3JyKDdVTCA8PCA2MSwgb2xkX3JyNyk7CisJaWE2NF9zcmx6X2Qo
KTsKKwlyZXR1cm4gcmV0OworfQorCisvKgorICogSGFuZGxlIGZsb2F0aW5nLXBvaW50IGFzc2lz
dCBmYXVsdHMgYW5kIHRyYXBzIGZvciBkb21haW4uCisgKi8KK3Vuc2lnbmVkIGxvbmcgdm1tX2hh
bmRsZV9mcHVfc3dhKGludCBmcF9mYXVsdCwgUkVHUyAqcmVncywgdW5zaWduZWQgbG9uZyBpc3Ip
Cit7CisJc3RydWN0IGt2bV92Y3B1ICp2ID0gY3VycmVudF92Y3B1OworCUlBNjRfQlVORExFIGJ1
bmRsZTsKKwl1bnNpZ25lZCBsb25nIGZhdWx0X2lwOworCWZwc3dhX3JldF90IHJldDsKKworCWZh
dWx0X2lwID0gcmVncy0+Y3JfaWlwOworCS8qCisJICogV2hlbiB0aGUgRlAgdHJhcCBvY2N1cnMs
IHRoZSB0cmFwcGluZyBpbnN0cnVjdGlvbiBpcyBjb21wbGV0ZWQuCisJICogSWYgaXBzci5yaSA9
PSAwLCB0aGVyZSBpcyB0aGUgdHJhcHBpbmcgaW5zdHJ1Y3Rpb24gaW4gcHJldmlvdXMKKwkgKiBi
dW5kbGUuCisJICovCisJaWYgKCFmcF9mYXVsdCAmJiAoaWE2NF9wc3IocmVncyktPnJpID09IDAp
KQorCQlmYXVsdF9pcCAtPSAxNjsKKworCWlmIChmZXRjaF9jb2RlKHYsIGZhdWx0X2lwLCAmYnVu
ZGxlKSkKKwkJcmV0dXJuIC1FQUdBSU47CisKKwlpZiAoIWJ1bmRsZS5pNjRbMF0gJiYgIWJ1bmRs
ZS5pNjRbMV0pIHsKKwkJcmV0dXJuIC1FQUNDRVM7CisJfQorCisJcmV0ID0gdm1tX2ZwX2VtdWxh
dGUoZnBfZmF1bHQsICZidW5kbGUsICZyZWdzLT5jcl9pcHNyLCAmcmVncy0+YXJfZnBzciwKKwkJ
CSZpc3IsICZyZWdzLT5wciwgJnJlZ3MtPmNyX2lmcywgcmVncyk7CisJcmV0dXJuIHJldC5zdGF0
dXM7Cit9CisKK3ZvaWQgcmVmbGVjdF9pbnRlcnJ1cHRpb24odTY0IGlmYSwgdTY0IGlzciwgdTY0
IGlpbSwKKwkJdTY0IHZlYywgUkVHUyAqcmVncykKK3sKKwl1NjQgdmVjdG9yOworCWludCBzdGF0
dXMgOworCVZDUFUgKnZjcHUgPSBjdXJyZW50X3ZjcHU7CisJdTY0IHZwc3IgPSBWQ1BVKHZjcHUs
IHZwc3IpOworCisJdmVjdG9yID0gdmVjMm9mZlt2ZWNdOworCisJaWYgKCEodnBzciAmIElBNjRf
UFNSX0lDKSAmJiAodmVjdG9yICE9IElBNjRfREFUQV9ORVNURURfVExCX1ZFQ1RPUikpIHsKKwkJ
cGFuaWNfdm0odmNwdSk7CisJCXJldHVybjsKKwl9CisKKwlzd2l0Y2ggKHZlYykgeworCWNhc2Ug
MzI6IAkvKklBNjRfRlBfRkFVTFRfVkVDVE9SKi8KKwkJc3RhdHVzID0gdm1tX2hhbmRsZV9mcHVf
c3dhKDEsIHJlZ3MsIGlzcik7CisJCWlmICghc3RhdHVzKSB7CisJCQl2Y3B1X2luY3JlbWVudF9p
aXAodmNwdSk7CisJCQlyZXR1cm47CisJCX0gZWxzZSBpZiAoLUVBR0FJTiA9PSBzdGF0dXMpCisJ
CQlyZXR1cm47CisJCWJyZWFrOworCWNhc2UgMzM6CS8qSUE2NF9GUF9UUkFQX1ZFQ1RPUiovCisJ
CXN0YXR1cyA9IHZtbV9oYW5kbGVfZnB1X3N3YSgwLCByZWdzLCBpc3IpOworCQlpZiAoIXN0YXR1
cykKKwkJCXJldHVybiA7CisJCWVsc2UgaWYgKC1FQUdBSU4gPT0gc3RhdHVzKSB7CisJCQl2Y3B1
X2RlY3JlbWVudF9paXAodmNwdSk7CisJCQlyZXR1cm4gOworCQl9CisJCWJyZWFrOworCX0KKwor
CVZDUFUodmNwdSwgaXNyKSA9IGlzcjsKKwlWQ1BVKHZjcHUsIGlpcGEpID0gcmVncy0+Y3JfaWlw
OworCWlmICh2ZWN0b3IgPT0gSUE2NF9CUkVBS19WRUNUT1IgfHwgdmVjdG9yID09IElBNjRfU1BF
Q1VMQVRJT05fVkVDVE9SKQorCQlWQ1BVKHZjcHUsIGlpbSkgPSBpaW07CisJZWxzZSB7CisJCXNl
dF9pZmFfaXRpcl9paGEodmNwdSwgaWZhLCAxLCAxLCAxKTsKKwl9CisJaW5qZWN0X2d1ZXN0X2lu
dGVycnVwdGlvbih2Y3B1LCB2ZWN0b3IpOworfQorCitzdGF0aWMgdm9pZCBzZXRfcGFsX2NhbGxf
ZGF0YShWQ1BVICp2Y3B1KQoreworCXN0cnVjdCBleGl0X2N0bF9kYXRhICpwID0gJnZjcHUtPmFy
Y2guZXhpdF9kYXRhOworCisJLypGSVhNRTpGb3Igc3RhdGljIGFuZCBzdGFja2VkIGNvbnZlbnRp
b24sIGZpcm13YXJlCisJICogaGFzIHB1dCB0aGUgcGFyYW1ldGVycyBpbiBncjI4LWdyMzEgYmVm
b3JlCisJICogYnJlYWsgdG8gdm1tICAhISovCisKKwlwLT51LnBhbF9kYXRhLmdyMjggPSB2Y3B1
X2dldF9ncih2Y3B1LCAyOCk7CisJcC0+dS5wYWxfZGF0YS5ncjI5ID0gdmNwdV9nZXRfZ3IodmNw
dSwgMjkpOworCXAtPnUucGFsX2RhdGEuZ3IzMCA9IHZjcHVfZ2V0X2dyKHZjcHUsIDMwKTsKKwlw
LT51LnBhbF9kYXRhLmdyMzEgPSB2Y3B1X2dldF9ncih2Y3B1LCAzMSk7CisJcC0+ZXhpdF9yZWFz
b24gPSBFWElUX1JFQVNPTl9QQUxfQ0FMTDsKK30KKworc3RhdGljIHZvaWQgc2V0X3BhbF9jYWxs
X3Jlc3VsdChWQ1BVICp2Y3B1KQoreworCXN0cnVjdCBleGl0X2N0bF9kYXRhICpwID0gJnZjcHUt
PmFyY2guZXhpdF9kYXRhOworCisJaWYgKHAtPmV4aXRfcmVhc29uID09IEVYSVRfUkVBU09OX1BB
TF9DQUxMKSB7CisJCXZjcHVfc2V0X2dyKHZjcHUsIDgsIHAtPnUucGFsX2RhdGEucmV0LnN0YXR1
cywgMCk7CisJCXZjcHVfc2V0X2dyKHZjcHUsIDksIHAtPnUucGFsX2RhdGEucmV0LnYwLCAwKTsK
KwkJdmNwdV9zZXRfZ3IodmNwdSwgMTAsIHAtPnUucGFsX2RhdGEucmV0LnYxLCAwKTsKKwkJdmNw
dV9zZXRfZ3IodmNwdSwgMTEsIHAtPnUucGFsX2RhdGEucmV0LnYyLCAwKTsKKwl9IGVsc2UKKwkJ
cGFuaWNfdm0odmNwdSk7Cit9CisKK3N0YXRpYyB2b2lkIHNldF9zYWxfY2FsbF9kYXRhKFZDUFUg
KnZjcHUpCit7CisJc3RydWN0IGV4aXRfY3RsX2RhdGEgKnAgPSAmdmNwdS0+YXJjaC5leGl0X2Rh
dGE7CisKKwlwLT51LnNhbF9kYXRhLmluMCA9IHZjcHVfZ2V0X2dyKHZjcHUsIDMyKTsKKwlwLT51
LnNhbF9kYXRhLmluMSA9IHZjcHVfZ2V0X2dyKHZjcHUsIDMzKTsKKwlwLT51LnNhbF9kYXRhLmlu
MiA9IHZjcHVfZ2V0X2dyKHZjcHUsIDM0KTsKKwlwLT51LnNhbF9kYXRhLmluMyA9IHZjcHVfZ2V0
X2dyKHZjcHUsIDM1KTsKKwlwLT51LnNhbF9kYXRhLmluNCA9IHZjcHVfZ2V0X2dyKHZjcHUsIDM2
KTsKKwlwLT51LnNhbF9kYXRhLmluNSA9IHZjcHVfZ2V0X2dyKHZjcHUsIDM3KTsKKwlwLT51LnNh
bF9kYXRhLmluNiA9IHZjcHVfZ2V0X2dyKHZjcHUsIDM4KTsKKwlwLT51LnNhbF9kYXRhLmluNyA9
IHZjcHVfZ2V0X2dyKHZjcHUsIDM5KTsKKwlwLT5leGl0X3JlYXNvbiA9IEVYSVRfUkVBU09OX1NB
TF9DQUxMOworfQorCitzdGF0aWMgdm9pZCBzZXRfc2FsX2NhbGxfcmVzdWx0KFZDUFUgKnZjcHUp
Cit7CisJc3RydWN0IGV4aXRfY3RsX2RhdGEgKnAgPSAmdmNwdS0+YXJjaC5leGl0X2RhdGE7CisK
KwlpZiAocC0+ZXhpdF9yZWFzb24gPT0gRVhJVF9SRUFTT05fU0FMX0NBTEwpIHsKKwkJdmNwdV9z
ZXRfZ3IodmNwdSwgOCwgcC0+dS5zYWxfZGF0YS5yZXQucjgsIDApOworCQl2Y3B1X3NldF9ncih2
Y3B1LCA5LCBwLT51LnNhbF9kYXRhLnJldC5yOSwgMCk7CisJCXZjcHVfc2V0X2dyKHZjcHUsIDEw
LCBwLT51LnNhbF9kYXRhLnJldC5yMTAsIDApOworCQl2Y3B1X3NldF9ncih2Y3B1LCAxMSwgcC0+
dS5zYWxfZGF0YS5yZXQucjExLCAwKTsKKwl9IGVsc2UKKwkJcGFuaWNfdm0odmNwdSk7Cit9CisK
K3ZvaWQgIGt2bV9pYTY0X2hhbmRsZV9icmVhayh1bnNpZ25lZCBsb25nIGlmYSwgc3RydWN0IGt2
bV9wdF9yZWdzICpyZWdzLAorCQl1bnNpZ25lZCBsb25nIGlzciwgdW5zaWduZWQgbG9uZyBpaW0p
Cit7CisJVkNQVSAqdiA9IGN1cnJlbnRfdmNwdTsKKworCWlmIChpYTY0X3BzcihyZWdzKS0+Y3Bs
ID09IDApIHsKKwkJLyogQWxsb3cgaHlwZXJjYWxscyBvbmx5IHdoZW4gY3BsID0gMC4gICovCisJ
CWlmIChpaW0gPT0gRE9NTl9QQUxfUkVRVUVTVCkgeworCQkJc2V0X3BhbF9jYWxsX2RhdGEodik7
CisJCQl2bW1fdHJhbnNpdGlvbih2KTsKKwkJCXNldF9wYWxfY2FsbF9yZXN1bHQodik7CisJCQl2
Y3B1X2luY3JlbWVudF9paXAodik7CisJCQlyZXR1cm47CisJCX0gZWxzZSBpZiAoaWltID09IERP
TU5fU0FMX1JFUVVFU1QpIHsKKwkJCXNldF9zYWxfY2FsbF9kYXRhKHYpOworCQkJdm1tX3RyYW5z
aXRpb24odik7CisJCQlzZXRfc2FsX2NhbGxfcmVzdWx0KHYpOworCQkJdmNwdV9pbmNyZW1lbnRf
aWlwKHYpOworCQkJcmV0dXJuOworCQl9CisJfQorCXJlZmxlY3RfaW50ZXJydXB0aW9uKGlmYSwg
aXNyLCBpaW0sIDExLCByZWdzKTsKK30KKwordm9pZCBjaGVja19wZW5kaW5nX2lycShWQ1BVICp2
Y3B1KQoreworCWludCAgbWFzaywgaF9wZW5kaW5nLCBoX2luc2VydmljZTsKKwl1NjQgaXNyOwor
CWlhNjRfcHNyIHZwc3I7CisJUkVHUyAqcmVncyA9IHZjcHVfcmVncyh2Y3B1KTsKKworCWhfcGVu
ZGluZyA9IGhpZ2hlc3RfcGVuZGluZ19pcnEodmNwdSk7CisJaWYgKGhfcGVuZGluZyA9PSBOVUxM
X1ZFQ1RPUikgeworCQl1cGRhdGVfdmhwaSh2Y3B1LCBOVUxMX1ZFQ1RPUik7CisJCXJldHVybjsK
Kwl9CisJaF9pbnNlcnZpY2UgPSBoaWdoZXN0X2luc2VydmljZV9pcnEodmNwdSk7CisKKwl2cHNy
LnZhbCA9IFZDUFUodmNwdSwgdnBzcik7CisJbWFzayA9IGlycV9tYXNrZWQodmNwdSwgaF9wZW5k
aW5nLCBoX2luc2VydmljZSk7CisJaWYgKHZwc3IuaSAmJiBJUlFfTk9fTUFTS0VEID09IG1hc2sp
IHsKKwkJaXNyID0gdnBzci52YWwgJiBJQTY0X1BTUl9SSTsKKwkJdXBkYXRlX3ZocGkodmNwdSwg
aF9wZW5kaW5nKTsKKwkJcmVmbGVjdF9pbnRlcnJ1cHRpb24oMCwgaXNyLCAwLCAxMiwgcmVncyk7
IC8qIEVYVCBJUlEgKi8KKwl9IGVsc2UgaWYgKG1hc2sgPT0gSVJRX01BU0tFRF9CWV9JTlNWQykg
eworCQlpZiAoVkNQVSh2Y3B1LCB2aHBpKSkKKwkJCXVwZGF0ZV92aHBpKHZjcHUsIE5VTExfVkVD
VE9SKTsKKwl9IGVsc2UgeworCQkvKiBtYXNrZWQgYnkgdnBzci5pIG9yIHZ0cHIuKi8KKwkJdXBk
YXRlX3ZocGkodmNwdSwgaF9wZW5kaW5nKTsKKwl9Cit9CisKK3N0YXRpYyB2b2lkIGdlbmVyYXRl
X2V4aXJxKFZDUFUgKnZjcHUpCit7CisJaWE2NF9wc3IgdnBzcjsKKwl1aW50NjRfdCBpc3I7CisK
KwlSRUdTICpyZWdzID0gdmNwdV9yZWdzKHZjcHUpOworCisJdnBzci52YWwgPSBWQ1BVKHZjcHUs
IHZwc3IpOworCWlzciA9IHZwc3IudmFsICYgSUE2NF9QU1JfUkk7CisJaWYgKCF2cHNyLmljKQor
CQlwYW5pY192bSh2Y3B1KTsKKwlyZWZsZWN0X2ludGVycnVwdGlvbigwLCBpc3IsIDAsIDEyLCBy
ZWdzKTsgLyogRVhUIElSUSAqLworfQorCit2b2lkIHZocGlfZGV0ZWN0aW9uKFZDUFUgKnZjcHUp
Cit7CisJdWludDY0X3QgICAgdGhyZXNob2xkLCB2aHBpOworCXRwcl90ICAgICAgIHZ0cHI7CisJ
aWE2NF9wc3IgICAgdnBzcjsKKworCXZwc3IudmFsID0gVkNQVSh2Y3B1LCB2cHNyKTsKKwl2dHBy
LnZhbCA9IFZDUFUodmNwdSwgdHByKTsKKworCXRocmVzaG9sZCA9ICgoIXZwc3IuaSkgPDwgNSkg
fCAodnRwci5tbWkgPDwgNCkgfCB2dHByLm1pYzsKKwl2aHBpID0gVkNQVSh2Y3B1LCB2aHBpKTsK
KwlpZiAodmhwaSA+IHRocmVzaG9sZCkgeworCQkvKiBpbnRlcnJ1cHQgYWN0aXZlZCovCisJCWdl
bmVyYXRlX2V4aXJxKHZjcHUpOworCX0KK30KKworCit2b2lkIGxlYXZlX2h5cGVydmlzb3JfdGFp
bCh2b2lkKQoreworCVZDUFUgKnYgPSBjdXJyZW50X3ZjcHU7CisKKwlpZiAoVk1YKHYsIHRpbWVy
X2NoZWNrKSkgeworCQlWTVgodiwgdGltZXJfY2hlY2spID0gMDsKKwkJaWYgKFZNWCh2LCBpdGNf
Y2hlY2spKSB7CisJCQlpZiAodmNwdV9nZXRfaXRjKHYpID4gVkNQVSh2LCBpdG0pKSB7CisJCQkJ
aWYgKCEoVkNQVSh2LCBpdHYpICYgKDEgPDwgMTYpKSkgeworCQkJCQl2Y3B1X3BlbmRfaW50ZXJy
dXB0KHYsIFZDUFUodiwgaXR2KQorCQkJCQkJCSYgMHhmZik7CisJCQkJVk1YKHYsIGl0Y19jaGVj
aykgPSAwOworCQkJCX0gZWxzZSB7CisJCQkJCXYtPmFyY2gudGltZXJfcGVuZGluZyA9IDE7CisJ
CQkJfQorCQkJCVZNWCh2LCBsYXN0X2l0YykgPSBWQ1BVKHYsIGl0bSkgKyAxOworCQkJfQorCQl9
CisJfQorCisJcm1iKCk7CisJaWYgKHYtPmFyY2guaXJxX25ld19wZW5kaW5nKSB7CisJCXYtPmFy
Y2guaXJxX25ld19wZW5kaW5nID0gMDsKKwkJVk1YKHYsIGlycV9jaGVjaykgPSAwOworCQljaGVj
a19wZW5kaW5nX2lycSh2KTsKKwkJcmV0dXJuOworCX0KKwlpZiAoVk1YKHYsIGlycV9jaGVjaykp
IHsKKwkJVk1YKHYsIGlycV9jaGVjaykgPSAwOworCQl2aHBpX2RldGVjdGlvbih2KTsKKwl9Cit9
CisKKworc3RhdGljIGlubGluZSB2b2lkIGhhbmRsZV9sZHMoUkVHUyAqcmVncykKK3sKKwlyZWdz
LT5jcl9pcHNyIHw9IElBNjRfUFNSX0VEOworfQorCit2b2lkIHBoeXNpY2FsX3RsYl9taXNzKFZD
UFUgKnZjcHUsIHVuc2lnbmVkIGxvbmcgdmFkciwgaW50IHR5cGUpCit7CisJdW5zaWduZWQgbG9u
ZyBwdGU7CisJaWE2NF9yciBycjsKKworCXJyLnZhbCA9IGlhNjRfZ2V0X3JyKHZhZHIpOworCXB0
ZSA9ICB2YWRyICYgX1BBR0VfUFBOX01BU0s7CisJcHRlID0gcHRlIHwgUEhZX1BBR0VfV0I7CisJ
dGhhc2hfdmhwdF9pbnNlcnQodmNwdSwgcHRlLCAodTY0KShyci5wcyA8PCAyKSwgdmFkciwgdHlw
ZSk7CisJcmV0dXJuOworfQorCit2b2lkIGt2bV9wYWdlX2ZhdWx0KHU2NCB2YWRyICwgdTY0IHZl
YywgUkVHUyAqcmVncykKK3sKKwlpYTY0X3BzciB2cHNyOworCWludCB0eXBlOworCisJdTY0IHZo
cHRfYWRyLCBncHBhLCBwdGV2YWwsIHJyLCBpdGlyOworCWlhNjRfaXNyIG1pc3I7CisJaWE2NF9w
dGEgdnB0YTsKKwl0aGFzaF9kYXRhX3QgKmRhdGE7CisJVkNQVSAqdiA9IGN1cnJlbnRfdmNwdTsK
KworCXZwc3IudmFsID0gVkNQVSh2LCB2cHNyKTsKKwltaXNyLnZhbCA9IFZNWCh2LCBjcl9pc3Ip
OworCisJdHlwZSA9IHZlYzsKKworCWlmIChpc19waHlzaWNhbF9tb2RlKHYpICYmICghKHZhZHIg
PDwgMSA+PiA2MikpKSB7CisJCWlmICh2ZWMgPT0gMikgeworCQkJaWYgKF9fZ3Bmbl9pc19pbygo
dmFkciA8PCAxKSA+PiAoUEFHRV9TSElGVCArIDEpKSkgeworCQkJCWVtdWxhdGVfaW9faW5zdCh2
LCAoKHZhZHIgPDwgMSkgPj4gMSksIDQpOworCQkJCXJldHVybjsKKwkJCX0KKwkJfQorCQlwaHlz
aWNhbF90bGJfbWlzcyh2LCB2YWRyLCB0eXBlKTsKKwkJcmV0dXJuOworCX0KKwlkYXRhID0gdnRs
Yl9sb29rdXAodiwgdmFkciwgdHlwZSk7CisJaWYgKGRhdGEgIT0gMCkgeworCQlpZiAodHlwZSA9
PSBEX1RMQikgeworCQkJZ3BwYSA9ICh2YWRyICYgKCgxVUwgPDwgZGF0YS0+cHMpIC0gMSkpCisJ
CQkJKyAoZGF0YS0+cHBuID4+IChkYXRhLT5wcyAtIDEyKSA8PCBkYXRhLT5wcyk7CisJCQlpZiAo
X19ncGZuX2lzX2lvKGdwcGEgPj4gUEFHRV9TSElGVCkpIHsKKwkJCQlpZiAoZGF0YS0+cGwgPj0g
KChyZWdzLT5jcl9pcHNyID4+CisJCQkJCQlJQTY0X1BTUl9DUEwwX0JJVCkgJiAzKSkKKwkJCQkJ
ZW11bGF0ZV9pb19pbnN0KHYsIGdwcGEsIGRhdGEtPm1hKTsKKwkJCQllbHNlIHsKKwkJCQkJdmNw
dV9zZXRfaXNyKHYsIG1pc3IudmFsKTsKKwkJCQkJZGF0YV9hY2Nlc3NfcmlnaHRzKHYsIHZhZHIp
OworCQkJCX0KKwkJCQlyZXR1cm4gOworCQkJfQorCQl9CisJCXRoYXNoX3ZocHRfaW5zZXJ0KHYs
IGRhdGEtPnBhZ2VfZmxhZ3MsIGRhdGEtPml0aXIsIHZhZHIsIHR5cGUpOworCisJfSBlbHNlIGlm
ICh0eXBlID09IERfVExCKSB7CisJCWlmIChtaXNyLnNwKSB7CisJCQloYW5kbGVfbGRzKHJlZ3Mp
OworCQkJcmV0dXJuOworCQl9CisKKwkJcnIgPSB2Y3B1X2dldF9ycih2LCB2YWRyKTsKKwkJaXRp
ciA9IHJyICYgKFJSX1JJRF9NQVNLIHwgUlJfUFNfTUFTSyk7CisKKwkJaWYgKCF2aHB0X2VuYWJs
ZWQodiwgdmFkciwgbWlzci5ycyA/IFJTRV9SRUYgOiBEQVRBX1JFRikpIHsKKwkJCWlmICh2cHNy
LmljKSB7CisJCQkJdmNwdV9zZXRfaXNyKHYsIG1pc3IudmFsKTsKKwkJCQlhbHRfZHRsYih2LCB2
YWRyKTsKKwkJCX0gZWxzZSB7CisJCQkJbmVzdGVkX2R0bGIodik7CisJCQl9CisJCQlyZXR1cm4g
OworCQl9CisKKwkJdnB0YS52YWwgPSB2Y3B1X2dldF9wdGEodik7CisJCS8qIGF2b2lkIHJlY3Vy
c2l2ZWx5IHdhbGtpbmcgKHNob3J0IGZvcm1hdCkgVkhQVCAqLworCisJCXZocHRfYWRyID0gdmNw
dV90aGFzaCh2LCB2YWRyKTsKKwkJaWYgKCFndWVzdF92aHB0X2xvb2t1cCh2aHB0X2FkciwgJnB0
ZXZhbCkpIHsKKwkJCS8qIFZIUFQgc3VjY2Vzc2Z1bGx5IHJlYWQuICAqLworCQkJaWYgKCEocHRl
dmFsICYgX1BBR0VfUCkpIHsKKwkJCQlpZiAodnBzci5pYykgeworCQkJCQl2Y3B1X3NldF9pc3Io
diwgbWlzci52YWwpOworCQkJCQlkdGxiX2ZhdWx0KHYsIHZhZHIpOworCQkJCX0gZWxzZSB7CisJ
CQkJCW5lc3RlZF9kdGxiKHYpOworCQkJCX0KKwkJCX0gZWxzZSBpZiAoKHB0ZXZhbCAmIF9QQUdF
X01BX01BU0spICE9IF9QQUdFX01BX1NUKSB7CisJCQkJdGhhc2hfcHVyZ2VfYW5kX2luc2VydCh2
LCBwdGV2YWwsIGl0aXIsCisJCQkJCQkJCXZhZHIsIERfVExCKTsKKwkJCX0gZWxzZSBpZiAodnBz
ci5pYykgeworCQkJCXZjcHVfc2V0X2lzcih2LCBtaXNyLnZhbCk7CisJCQkJZHRsYl9mYXVsdCh2
LCB2YWRyKTsKKwkJCX0gZWxzZSB7CisJCQkJbmVzdGVkX2R0bGIodik7CisJCQl9CisJCX0gZWxz
ZSB7CisJCQkvKiBDYW4ndCByZWFkIFZIUFQuICAqLworCQkJaWYgKHZwc3IuaWMpIHsKKwkJCQl2
Y3B1X3NldF9pc3IodiwgbWlzci52YWwpOworCQkJCWR2aHB0X2ZhdWx0KHYsIHZhZHIpOworCQkJ
fSBlbHNlIHsKKwkJCQluZXN0ZWRfZHRsYih2KTsKKwkJCX0KKwkJfQorCX0gZWxzZSBpZiAodHlw
ZSA9PSBJX1RMQikgeworCQlpZiAoIXZwc3IuaWMpCisJCQltaXNyLm5pID0gMTsKKwkJaWYgKCF2
aHB0X2VuYWJsZWQodiwgdmFkciwgSU5TVF9SRUYpKSB7CisJCQl2Y3B1X3NldF9pc3IodiwgbWlz
ci52YWwpOworCQkJYWx0X2l0bGIodiwgdmFkcik7CisJCQlyZXR1cm47CisJCX0KKworCQl2cHRh
LnZhbCA9IHZjcHVfZ2V0X3B0YSh2KTsKKworCQl2aHB0X2FkciA9IHZjcHVfdGhhc2godiwgdmFk
cik7CisJCWlmICghZ3Vlc3RfdmhwdF9sb29rdXAodmhwdF9hZHIsICZwdGV2YWwpKSB7CisJCQkv
KiBWSFBUIHN1Y2Nlc3NmdWxseSByZWFkLiAgKi8KKwkJCWlmIChwdGV2YWwgJiBfUEFHRV9QKSB7
CisJCQkJaWYgKChwdGV2YWwgJiBfUEFHRV9NQV9NQVNLKSA9PSBfUEFHRV9NQV9TVCkgeworCQkJ
CQl2Y3B1X3NldF9pc3IodiwgbWlzci52YWwpOworCQkJCQlpdGxiX2ZhdWx0KHYsIHZhZHIpOwor
CQkJCQlyZXR1cm4gOworCQkJCX0KKwkJCQlyciA9IHZjcHVfZ2V0X3JyKHYsIHZhZHIpOworCQkJ
CWl0aXIgPSByciAmIChSUl9SSURfTUFTSyB8IFJSX1BTX01BU0spOworCQkJCXRoYXNoX3B1cmdl
X2FuZF9pbnNlcnQodiwgcHRldmFsLCBpdGlyLAorCQkJCQkJCXZhZHIsIElfVExCKTsKKwkJCX0g
ZWxzZSB7CisJCQkJdmNwdV9zZXRfaXNyKHYsIG1pc3IudmFsKTsKKwkJCQlpbnN0X3BhZ2Vfbm90
X3ByZXNlbnQodiwgdmFkcik7CisJCQl9CisJCX0gZWxzZSB7CisJCQl2Y3B1X3NldF9pc3Iodiwg
bWlzci52YWwpOworCQkJaXZocHRfZmF1bHQodiwgdmFkcik7CisJCX0KKwl9Cit9CisKK3ZvaWQg
a3ZtX3ZleGlycShWQ1BVICp2Y3B1KQoreworCXU2NCB2cHNyLCBpc3I7CisJUkVHUyAqcmVnczsK
KworCXJlZ3MgPSB2Y3B1X3JlZ3ModmNwdSk7CisJdnBzciA9IFZDUFUodmNwdSwgdnBzcik7CisJ
aXNyID0gdnBzciAmIElBNjRfUFNSX1JJOworCXJlZmxlY3RfaW50ZXJydXB0aW9uKDAsIGlzciwg
MCwgMTIsIHJlZ3MpOyAvKkVYVCBJUlEqLworfQorCit2b2lkIGt2bV9pYTY0X2hhbmRsZV9pcnEo
VkNQVSAqdikKK3sKKwlzdHJ1Y3QgZXhpdF9jdGxfZGF0YSAqcCA9ICZ2LT5hcmNoLmV4aXRfZGF0
YTsKKwlsb25nIHBzcjsKKworCWxvY2FsX2lycV9zYXZlKHBzcik7CisJcC0+ZXhpdF9yZWFzb24g
PSBFWElUX1JFQVNPTl9FWFRFUk5BTF9JTlRFUlJVUFQ7CisJdm1tX3RyYW5zaXRpb24odik7CisJ
bG9jYWxfaXJxX3Jlc3RvcmUocHNyKTsKKworCVZNWCh2LCB0aW1lcl9jaGVjaykgPSAxOworCit9
CisKK3N0YXRpYyB2b2lkIHB0Y19nYV9yZW1vdGVfZnVuYyhzdHJ1Y3Qga3ZtX3ZjcHUgKnYsIGlu
dCBwb3MpCit7CisJdTY0IG9sZHJpZCwgbW9sZHJpZCwgb2xkcHNiaXRzLCB2YWRkcjsKKwlzdHJ1
Y3Qga3ZtX3B0Y19nICpwID0gJnYtPmFyY2gucHRjX2dfZGF0YVtwb3NdOworCXZhZGRyID0gcC0+
dmFkZHI7CisKKwlvbGRyaWQgPSBWTVgodiwgdnJyWzBdKTsKKwlWTVgodiwgdnJyWzBdKSA9IHAt
PnJyOworCW9sZHBzYml0cyA9IFZNWCh2LCBwc2JpdHNbMF0pOworCVZNWCh2LCBwc2JpdHNbMF0p
ID0gVk1YKHYsIHBzYml0c1tSRUdJT05fTlVNQkVSKHZhZGRyKV0pOworCW1vbGRyaWQgPSBpYTY0
X2dldF9ycigweDApOworCWlhNjRfc2V0X3JyKDB4MCwgdnJydG9tcnIocC0+cnIpKTsKKwlpYTY0
X3NybHpfZCgpOworCisJdmFkZHIgPSBQQUdFQUxJR04odmFkZHIsIHAtPnBzKTsKKwl0aGFzaF9w
dXJnZV9lbnRyaWVzX3JlbW90ZSh2LCB2YWRkciwgcC0+cHMpOworCisJVk1YKHYsIHZyclswXSkg
PSBvbGRyaWQ7CisJVk1YKHYsIHBzYml0c1swXSkgPSBvbGRwc2JpdHM7CisJaWE2NF9zZXRfcnIo
MHgwLCBtb2xkcmlkKTsKKwlpYTY0X2R2X3NlcmlhbGl6ZV9kYXRhKCk7Cit9CisKK3N0YXRpYyB2
b2lkIHZjcHVfZG9fcmVzdW1lKHN0cnVjdCBrdm1fdmNwdSAqdmNwdSkKK3sKKwkvKlJlLWluaXQg
VkhQVCBhbmQgVlRMQiBvbmNlIGZyb20gcmVzdW1lKi8KKwl2Y3B1LT5hcmNoLnZocHQubnVtID0g
VkhQVF9OVU1fRU5UUklFUzsKKwl0aGFzaF9pbml0KCZ2Y3B1LT5hcmNoLnZocHQsIFZIUFRfU0hJ
RlQpOworCXZjcHUtPmFyY2gudnRsYi5udW0gPSBWVExCX05VTV9FTlRSSUVTOworCXRoYXNoX2lu
aXQoJnZjcHUtPmFyY2gudnRsYiwgVlRMQl9TSElGVCk7CisKKwlpYTY0X3NldF9wdGEodmNwdS0+
YXJjaC52aHB0LnB0YS52YWwpOworfQorCitzdGF0aWMgdm9pZCBrdm1fZG9fcmVzdW1lX29wKHN0
cnVjdCBrdm1fdmNwdSAqdmNwdSkKK3sKKwlpZiAodGVzdF9hbmRfY2xlYXJfYml0KEtWTV9SRVFf
UkVTVU1FLCAmdmNwdS0+cmVxdWVzdHMpKSB7CisJCXZjcHVfZG9fcmVzdW1lKHZjcHUpOworCQly
ZXR1cm47CisJfQorCisJaWYgKHVubGlrZWx5KHRlc3RfYW5kX2NsZWFyX2JpdChLVk1fUkVRX1RM
Ql9GTFVTSCwgJnZjcHUtPnJlcXVlc3RzKSkpIHsKKwkJdGhhc2hfcHVyZ2VfYWxsKHZjcHUpOwor
CQlyZXR1cm47CisJfQorCisJaWYgKHRlc3RfYW5kX2NsZWFyX2JpdChLVk1fUkVRX1BUQ19HLCAm
dmNwdS0+cmVxdWVzdHMpKSB7CisJCXdoaWxlICh2Y3B1LT5hcmNoLnB0Y19nX2NvdW50ID4gMCkK
KwkJCXB0Y19nYV9yZW1vdGVfZnVuYyh2Y3B1LCAtLXZjcHUtPmFyY2gucHRjX2dfY291bnQpOwor
CX0KK30KKwordm9pZCB2bW1fdHJhbnNpdGlvbihzdHJ1Y3Qga3ZtX3ZjcHUgKnZjcHUpCit7CisJ
aWE2NF9jYWxsX3ZzYShQQUxfVlBTX1NBVkUsICh1bnNpZ25lZCBsb25nKXZjcHUtPmFyY2gudnBk
LAorCQkJMCwgMCwgMCwgMCwgMCwgMCk7CisJdm1tX3RyYW1wb2xpbmUoJnZjcHUtPmFyY2guZ3Vl
c3QsICZ2Y3B1LT5hcmNoLmhvc3QpOworCWlhNjRfY2FsbF92c2EoUEFMX1ZQU19SRVNUT1JFLCAo
dW5zaWduZWQgbG9uZyl2Y3B1LT5hcmNoLnZwZCwKKwkJCQkJCTAsIDAsIDAsIDAsIDAsIDApOwor
CWt2bV9kb19yZXN1bWVfb3AodmNwdSk7Cit9Ci0tIAoxLjUuMgoK

------_=_NextPart_001_01C89309.8C88089B--
