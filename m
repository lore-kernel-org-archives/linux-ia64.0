From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Sat, 29 Mar 2008 02:40:16 +0000
Subject: [14/17][PATCH] kvm/ia64: Add guest interruption injection support. V7
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDCFF7F68@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C89146.39BC1893"
List-Id: <linux-ia64.vger.kernel.org>
References: <42DFA526FC41B1429CE7279EF83C6BDCFF7EF2@pdsmsx415.ccr.corp.intel.com>
In-Reply-To: <42DFA526FC41B1429CE7279EF83C6BDCFF7EF2@pdsmsx415.ccr.corp.intel.com>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C89146.39BC1893
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

From 851ad380c7aace2b1a1409e91722660b1df43aa1 Mon Sep 17 00:00:00 2001
From: Xiantao Zhang <xiantao.zhang@intel.com>
Date: Wed, 12 Mar 2008 13:50:49 +0800
Subject: [PATCH] kvm/ia64: Add guest interruption injection support.

process.c mainly handle interruption injection, and some
faults handling.
Signed-off-by: Anthony Xu <anthony.xu@intel.com>
Signed-off-by: Xiantao Zhang <xiantao.zhang@intel.com>
---
 arch/ia64/kvm/process.c |  981
+++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 981 insertions(+), 0 deletions(-)
 create mode 100644 arch/ia64/kvm/process.c

diff --git a/arch/ia64/kvm/process.c b/arch/ia64/kvm/process.c
new file mode 100644
index 0000000..e4c32c4
--- /dev/null
+++ b/arch/ia64/kvm/process.c
@@ -0,0 +1,981 @@
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
+#define INITIAL_PSR_VALUE_AT_INTERRUPTION IA64_PSR_UP_BIT|
IA64_PSR_MFL_BIT|\
+
IA64_PSR_MFH_BIT|IA64_PSR_PK_BIT|IA64_PSR_DT_BIT|    \
+			IA64_PSR_RT_BIT|IA64_PSR_MC_BIT|IA64_PSR_IT_BIT
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
--=20
1.5.2

------_=_NextPart_001_01C89146.39BC1893
Content-Type: application/octet-stream;
	name="0014-kvm-ia64-Add-guest-interruption-injection-support.patch"
Content-Transfer-Encoding: base64
Content-Description: 0014-kvm-ia64-Add-guest-interruption-injection-support.patch
Content-Disposition: attachment;
	filename="0014-kvm-ia64-Add-guest-interruption-injection-support.patch"

RnJvbSA4NTFhZDM4MGM3YWFjZTJiMWExNDA5ZTkxNzIyNjYwYjFkZjQzYWExIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBYaWFudGFvIFpoYW5nIDx4aWFudGFvLnpoYW5nQGludGVsLmNv
bT4KRGF0ZTogV2VkLCAxMiBNYXIgMjAwOCAxMzo1MDo0OSArMDgwMApTdWJqZWN0OiBbUEFUQ0hd
IGt2bS9pYTY0OiBBZGQgZ3Vlc3QgaW50ZXJydXB0aW9uIGluamVjdGlvbiBzdXBwb3J0LgoKcHJv
Y2Vzcy5jIG1haW5seSBoYW5kbGUgaW50ZXJydXB0aW9uIGluamVjdGlvbiwgYW5kIHNvbWUKZmF1
bHRzIGhhbmRsaW5nLgpTaWduZWQtb2ZmLWJ5OiBBbnRob255IFh1IDxhbnRob255Lnh1QGludGVs
LmNvbT4KU2lnbmVkLW9mZi1ieTogWGlhbnRhbyBaaGFuZyA8eGlhbnRhby56aGFuZ0BpbnRlbC5j
b20+Ci0tLQogYXJjaC9pYTY0L2t2bS9wcm9jZXNzLmMgfCAgOTgxICsrKysrKysrKysrKysrKysr
KysrKysrKysrKysrKysrKysrKysrKysrKysrKysrCiAxIGZpbGVzIGNoYW5nZWQsIDk4MSBpbnNl
cnRpb25zKCspLCAwIGRlbGV0aW9ucygtKQogY3JlYXRlIG1vZGUgMTAwNjQ0IGFyY2gvaWE2NC9r
dm0vcHJvY2Vzcy5jCgpkaWZmIC0tZ2l0IGEvYXJjaC9pYTY0L2t2bS9wcm9jZXNzLmMgYi9hcmNo
L2lhNjQva3ZtL3Byb2Nlc3MuYwpuZXcgZmlsZSBtb2RlIDEwMDY0NAppbmRleCAwMDAwMDAwLi5l
NGMzMmM0Ci0tLSAvZGV2L251bGwKKysrIGIvYXJjaC9pYTY0L2t2bS9wcm9jZXNzLmMKQEAgLTAs
MCArMSw5ODEgQEAKKy8qCisgKiBwcm9jZXNzLmM6IGhhbmRsZSBpbnRlcnJ1cHRpb24gaW5qZWN0
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
bS9mcHN3YS5oPgorI2luY2x1ZGUgPGFzbS9rcmVncy5oPgorCitmcHN3YV9pbnRlcmZhY2VfdCAq
dm1tX2Zwc3dhX2ludGVyZmFjZTsKKworI2RlZmluZSBJQTY0X1ZIUFRfVFJBTlNfVkVDVE9SCQkJ
MHgwMDAwCisjZGVmaW5lIElBNjRfSU5TVF9UTEJfVkVDVE9SCQkJMHgwNDAwCisjZGVmaW5lIElB
NjRfREFUQV9UTEJfVkVDVE9SCQkJMHgwODAwCisjZGVmaW5lIElBNjRfQUxUX0lOU1RfVExCX1ZF
Q1RPUgkJMHgwYzAwCisjZGVmaW5lIElBNjRfQUxUX0RBVEFfVExCX1ZFQ1RPUgkJMHgxMDAwCisj
ZGVmaW5lIElBNjRfREFUQV9ORVNURURfVExCX1ZFQ1RPUgkJMHgxNDAwCisjZGVmaW5lIElBNjRf
SU5TVF9LRVlfTUlTU19WRUNUT1IJCTB4MTgwMAorI2RlZmluZSBJQTY0X0RBVEFfS0VZX01JU1Nf
VkVDVE9SCQkweDFjMDAKKyNkZWZpbmUgSUE2NF9ESVJUWV9CSVRfVkVDVE9SCQkJMHgyMDAwCisj
ZGVmaW5lIElBNjRfSU5TVF9BQ0NFU1NfQklUX1ZFQ1RPUgkJMHgyNDAwCisjZGVmaW5lIElBNjRf
REFUQV9BQ0NFU1NfQklUX1ZFQ1RPUgkJMHgyODAwCisjZGVmaW5lIElBNjRfQlJFQUtfVkVDVE9S
CQkJMHgyYzAwCisjZGVmaW5lIElBNjRfRVhUSU5UX1ZFQ1RPUgkJCTB4MzAwMAorI2RlZmluZSBJ
QTY0X1BBR0VfTk9UX1BSRVNFTlRfVkVDVE9SCQkweDUwMDAKKyNkZWZpbmUgSUE2NF9LRVlfUEVS
TUlTU0lPTl9WRUNUT1IJCTB4NTEwMAorI2RlZmluZSBJQTY0X0lOU1RfQUNDRVNTX1JJR0hUU19W
RUNUT1IJCTB4NTIwMAorI2RlZmluZSBJQTY0X0RBVEFfQUNDRVNTX1JJR0hUU19WRUNUT1IJCTB4
NTMwMAorI2RlZmluZSBJQTY0X0dFTkVYX1ZFQ1RPUgkJCTB4NTQwMAorI2RlZmluZSBJQTY0X0RJ
U0FCTEVEX0ZQUkVHX1ZFQ1RPUgkJMHg1NTAwCisjZGVmaW5lIElBNjRfTkFUX0NPTlNVTVBUSU9O
X1ZFQ1RPUgkJMHg1NjAwCisjZGVmaW5lIElBNjRfU1BFQ1VMQVRJT05fVkVDVE9SCQkweDU3MDAg
LyogVU5VU0VEICovCisjZGVmaW5lIElBNjRfREVCVUdfVkVDVE9SCQkJMHg1OTAwCisjZGVmaW5l
IElBNjRfVU5BTElHTkVEX1JFRl9WRUNUT1IJCTB4NWEwMAorI2RlZmluZSBJQTY0X1VOU1VQUE9S
VEVEX0RBVEFfUkVGX1ZFQ1RPUgkweDViMDAKKyNkZWZpbmUgSUE2NF9GUF9GQVVMVF9WRUNUT1IJ
CQkweDVjMDAKKyNkZWZpbmUgSUE2NF9GUF9UUkFQX1ZFQ1RPUgkJCTB4NWQwMAorI2RlZmluZSBJ
QTY0X0xPV0VSUFJJVl9UUkFOU0ZFUl9UUkFQX1ZFQ1RPUiAJMHg1ZTAwCisjZGVmaW5lIElBNjRf
VEFLRU5fQlJBTkNIX1RSQVBfVkVDVE9SCQkweDVmMDAKKyNkZWZpbmUgSUE2NF9TSU5HTEVfU1RF
UF9UUkFQX1ZFQ1RPUgkJMHg2MDAwCisKKy8qIFNETSB2b2wyIDUuNSAtIElWQSBiYXNlZCBpbnRl
cnJ1cHRpb24gaGFuZGxpbmcgKi8KKyNkZWZpbmUgSU5JVElBTF9QU1JfVkFMVUVfQVRfSU5URVJS
VVBUSU9OIElBNjRfUFNSX1VQX0JJVHwgSUE2NF9QU1JfTUZMX0JJVHxcCisJCQlJQTY0X1BTUl9N
RkhfQklUfElBNjRfUFNSX1BLX0JJVHxJQTY0X1BTUl9EVF9CSVR8ICAgIFwKKwkJCUlBNjRfUFNS
X1JUX0JJVHxJQTY0X1BTUl9NQ19CSVR8SUE2NF9QU1JfSVRfQklUCisKKyNkZWZpbmUgRE9NTl9Q
QUxfUkVRVUVTVCAgICAweDExMDAwMAorI2RlZmluZSBET01OX1NBTF9SRVFVRVNUICAgIDB4MTEw
MDAxCisKK3N0YXRpYyB1NjQgdmVjMm9mZls2OF0gPSB7MHgwLCAweDQwMCwgMHg4MDAsIDB4YzAw
LCAweDEwMDAsIDB4MTQwMCwgMHgxODAwLAorCTB4MWMwMCwgMHgyMDAwLCAweDI0MDAsIDB4Mjgw
MCwgMHgyYzAwLCAweDMwMDAsIDB4MzQwMCwgMHgzODAwLCAweDNjMDAsCisJMHg0MDAwLCAweDQ0
MDAsIDB4NDgwMCwgMHg0YzAwLCAweDUwMDAsIDB4NTEwMCwgMHg1MjAwLCAweDUzMDAsIDB4NTQw
MCwKKwkweDU1MDAsIDB4NTYwMCwgMHg1NzAwLCAweDU4MDAsIDB4NTkwMCwgMHg1YTAwLCAweDVi
MDAsIDB4NWMwMCwgMHg1ZDAwLAorCTB4NWUwMCwgMHg1ZjAwLCAweDYwMDAsIDB4NjEwMCwgMHg2
MjAwLCAweDYzMDAsIDB4NjQwMCwgMHg2NTAwLCAweDY2MDAsCisJMHg2NzAwLCAweDY4MDAsIDB4
NjkwMCwgMHg2YTAwLCAweDZiMDAsIDB4NmMwMCwgMHg2ZDAwLCAweDZlMDAsIDB4NmYwMCwKKwkw
eDcwMDAsIDB4NzEwMCwgMHg3MjAwLCAweDczMDAsIDB4NzQwMCwgMHg3NTAwLCAweDc2MDAsIDB4
NzcwMCwgMHg3ODAwLAorCTB4NzkwMCwgMHg3YTAwLCAweDdiMDAsIDB4N2MwMCwgMHg3ZDAwLCAw
eDdlMDAsIDB4N2YwMAorfTsKKworc3RhdGljIHZvaWQgY29sbGVjdF9pbnRlcnJ1cHRpb24oVkNQ
VSAqdmNwdSkKK3sKKwl1NjQgaXBzcjsKKwl1NjQgdmRjcjsKKwl1NjQgdmlmczsKKwlpYTY0X3Bz
ciB2cHNyOworCVJFR1MgKnJlZ3MgPSB2Y3B1X3JlZ3ModmNwdSk7CisKKwl2cHNyLnZhbCA9IHZj
cHVfZ2V0X3Bzcih2Y3B1KTsKKwl2Y3B1X2JzdzAodmNwdSk7CisJaWYgKHZwc3IuaWMpIHsKKwor
CQkvKiBTeW5jIG1wc3IgaWQvZGEvZGQvc3MvZWQgYml0cyB0byB2aXBzcgorCQkgKiBzaW5jZSBh
ZnRlciBndWVzdCBkbyByZmksIHdlIHN0aWxsIHdhbnQgdGhlc2UgYml0cyBvbiBpbgorCQkgKiBt
cHNyCisJCSAqLworCisJCWlwc3IgPSByZWdzLT5jcl9pcHNyOworCQl2cHNyLnZhbCA9IHZwc3Iu
dmFsIHwgKGlwc3IgJiAoSUE2NF9QU1JfSUQgfCBJQTY0X1BTUl9EQQorCQkJCQl8IElBNjRfUFNS
X0REIHwgSUE2NF9QU1JfU1MKKwkJCQkJfCBJQTY0X1BTUl9FRCkpOworCQl2Y3B1X3NldF9pcHNy
KHZjcHUsIHZwc3IudmFsKTsKKworCQkvKiBDdXJyZW50bHksIGZvciB0cmFwLCB3ZSBkbyBub3Qg
YWR2YW5jZSBJSVAgdG8gbmV4dAorCQkgKiBpbnN0cnVjdGlvbi4gVGhhdCdzIGJlY2F1c2Ugd2Ug
YXNzdW1lIGNhbGxlciBhbHJlYWR5CisJCSAqIHNldCB1cCBJSVAgY29ycmVjdGx5CisJCSAqLwor
CisJCXZjcHVfc2V0X2lpcCh2Y3B1ICwgcmVncy0+Y3JfaWlwKTsKKworCQkvKiBzZXQgdmlmcy52
IHRvIHplcm8gKi8KKwkJdmlmcyA9IFZDUFUodmNwdSwgaWZzKTsKKwkJdmlmcyAmPSB+SUE2NF9J
RlNfVjsKKwkJdmNwdV9zZXRfaWZzKHZjcHUsIHZpZnMpOworCisJCXZjcHVfc2V0X2lpcGEodmNw
dSwgVk1YKHZjcHUsIGNyX2lpcGEpKTsKKwl9CisKKwl2ZGNyID0gVkNQVSh2Y3B1LCBkY3IpOwor
CisJLyogU2V0IGd1ZXN0IHBzcgorCSAqIHVwL21mbC9tZmgvcGsvZHQvcnQvbWMvaXQga2VlcHMg
dW5jaGFuZ2VkCisJICogYmU6IHNldCB0byB0aGUgdmFsdWUgb2YgZGNyLmJlCisJICogcHA6IHNl
dCB0byB0aGUgdmFsdWUgb2YgZGNyLnBwCisJICovCisJdnBzci52YWwgJj0gSU5JVElBTF9QU1Jf
VkFMVUVfQVRfSU5URVJSVVBUSU9OOworCXZwc3IudmFsIHw9ICh2ZGNyICYgSUE2NF9EQ1JfQkUp
OworCisJLyogVkRDUiBwcCBiaXQgcG9zaXRpb24gaXMgZGlmZmVyZW50IGZyb20gVlBTUiBwcCBi
aXQgKi8KKwlpZiAodmRjciAmIElBNjRfRENSX1BQKSB7CisJCXZwc3IudmFsIHw9IElBNjRfUFNS
X1BQOworCX0gZWxzZSB7CisJCXZwc3IudmFsICY9IH5JQTY0X1BTUl9QUDs7CisJfQorCisJdmNw
dV9zZXRfcHNyKHZjcHUsIHZwc3IudmFsKTsKKworfQorCit2b2lkIGluamVjdF9ndWVzdF9pbnRl
cnJ1cHRpb24oVkNQVSAqdmNwdSwgdTY0IHZlYykKK3sKKwl1NjQgdml2YTsKKwlSRUdTICpyZWdz
OworCWlhNjRfaXNyIHB0X2lzcjsKKworCXJlZ3MgPSB2Y3B1X3JlZ3ModmNwdSk7CisKKwkvKiBj
bGVhciBjci5pc3IuaXIgKGluY29tcGxldGUgcmVnaXN0ZXIgZnJhbWUpKi8KKwlwdF9pc3IudmFs
ID0gVk1YKHZjcHUsIGNyX2lzcik7CisJcHRfaXNyLmlyID0gMDsKKwlWTVgodmNwdSwgY3JfaXNy
KSA9IHB0X2lzci52YWw7CisKKwljb2xsZWN0X2ludGVycnVwdGlvbih2Y3B1KTsKKworCXZpdmEg
PSB2Y3B1X2dldF9pdmEodmNwdSk7CisJcmVncy0+Y3JfaWlwID0gdml2YSArIHZlYzsKK30KKwor
c3RhdGljIHU2NCB2Y3B1X2dldF9pdGlyX29uX2ZhdWx0KFZDUFUgKnZjcHUsIHU2NCBpZmEpCit7
CisJaWE2NF9yciByciwgcnIxOworCisJcnIudmFsID0gdmNwdV9nZXRfcnIodmNwdSwgaWZhKTsK
KwlycjEudmFsID0gMDsKKwlycjEucHMgPSByci5wczsKKwlycjEucmlkID0gcnIucmlkOworCXJl
dHVybiAocnIxLnZhbCk7Cit9CisKKworLyoKKyAqIFNldCB2SUZBICYgdklUSVIgJiB2SUhBLCB3
aGVuIHZQU1IuaWMgPTEKKyAqIFBhcmFtZXRlcjoKKyAqICBzZXRfaWZhOiBpZiB0cnVlLCBzZXQg
dklGQQorICogIHNldF9pdGlyOiBpZiB0cnVlLCBzZXQgdklUSVIKKyAqICBzZXRfaWhhOiBpZiB0
cnVlLCBzZXQgdklIQQorICovCit2b2lkIHNldF9pZmFfaXRpcl9paGEoVkNQVSAqdmNwdSwgdTY0
IHZhZHIsCisJCWludCBzZXRfaWZhLCBpbnQgc2V0X2l0aXIsIGludCBzZXRfaWhhKQoreworCWlh
NjRfcHNyIHZwc3I7CisJdTY0IHZhbHVlOworCisJdnBzci52YWwgPSBWQ1BVKHZjcHUsIHZwc3Ip
OworCS8qIFZvbDIsIFRhYmxlIDgtMSAqLworCWlmICh2cHNyLmljKSB7CisJCWlmIChzZXRfaWZh
KSB7CisJCQl2Y3B1X3NldF9pZmEodmNwdSwgdmFkcik7CisJCX0KKwkJaWYgKHNldF9pdGlyKSB7
CisJCQl2YWx1ZSA9IHZjcHVfZ2V0X2l0aXJfb25fZmF1bHQodmNwdSwgdmFkcik7CisJCQl2Y3B1
X3NldF9pdGlyKHZjcHUsIHZhbHVlKTsKKwkJfQorCisJCWlmIChzZXRfaWhhKSB7CisJCQl2YWx1
ZSA9IHZjcHVfdGhhc2godmNwdSwgdmFkcik7CisJCQl2Y3B1X3NldF9paGEodmNwdSwgdmFsdWUp
OworCQl9CisJfQorfQorCisvKgorICogRGF0YSBUTEIgRmF1bHQKKyAqICBAIERhdGEgVExCIHZl
Y3RvcgorICogUmVmZXIgdG8gU0RNIFZvbDIgVGFibGUgNS02ICYgOC0xCisgKi8KK3ZvaWQgZHRs
Yl9mYXVsdChWQ1BVICp2Y3B1LCB1NjQgdmFkcikKK3sKKwkvKiBJZiB2UFNSLmljLCBJRkEsIElU
SVIsIElIQSAqLworCXNldF9pZmFfaXRpcl9paGEodmNwdSwgdmFkciwgMSwgMSwgMSk7CisJaW5q
ZWN0X2d1ZXN0X2ludGVycnVwdGlvbih2Y3B1LCBJQTY0X0RBVEFfVExCX1ZFQ1RPUik7Cit9CisK
Ky8qCisgKiBJbnN0cnVjdGlvbiBUTEIgRmF1bHQKKyAqICBAIEluc3RydWN0aW9uIFRMQiB2ZWN0
b3IKKyAqIFJlZmVyIHRvIFNETSBWb2wyIFRhYmxlIDUtNiAmIDgtMQorICovCit2b2lkIGl0bGJf
ZmF1bHQgKFZDUFUgKnZjcHUsIHU2NCB2YWRyKQoreworCS8qIElmIHZQU1IuaWMsIElGQSwgSVRJ
UiwgSUhBICovCisJc2V0X2lmYV9pdGlyX2loYSh2Y3B1LCB2YWRyLCAxLCAxLCAxKTsKKwlpbmpl
Y3RfZ3Vlc3RfaW50ZXJydXB0aW9uKHZjcHUsIElBNjRfSU5TVF9UTEJfVkVDVE9SKTsKK30KKwor
CisKKy8qCisgKiBEYXRhIE5lc3RlZCBUTEIgRmF1bHQKKyAqICBAIERhdGEgTmVzdGVkIFRMQiBW
ZWN0b3IKKyAqIFJlZmVyIHRvIFNETSBWb2wyIFRhYmxlIDUtNiAmIDgtMQorICovCit2b2lkIG5l
c3RlZF9kdGxiKFZDUFUgKnZjcHUpCit7CisJaW5qZWN0X2d1ZXN0X2ludGVycnVwdGlvbih2Y3B1
LCBJQTY0X0RBVEFfTkVTVEVEX1RMQl9WRUNUT1IpOworfQorCisvKgorICogQWx0ZXJuYXRlIERh
dGEgVExCIEZhdWx0CisgKiAgQCBBbHRlcm5hdGUgRGF0YSBUTEIgdmVjdG9yCisgKiBSZWZlciB0
byBTRE0gVm9sMiBUYWJsZSA1LTYgJiA4LTEKKyAqLwordm9pZCBhbHRfZHRsYihWQ1BVICp2Y3B1
LCB1NjQgdmFkcikKK3sKKwlzZXRfaWZhX2l0aXJfaWhhKHZjcHUsIHZhZHIsIDEsIDEsIDApOwor
CWluamVjdF9ndWVzdF9pbnRlcnJ1cHRpb24odmNwdSwgSUE2NF9BTFRfREFUQV9UTEJfVkVDVE9S
KTsKK30KKworCisvKgorICogRGF0YSBUTEIgRmF1bHQKKyAqICBAIERhdGEgVExCIHZlY3Rvcgor
ICogUmVmZXIgdG8gU0RNIFZvbDIgVGFibGUgNS02ICYgOC0xCisgKi8KK3ZvaWQgYWx0X2l0bGIo
VkNQVSAqdmNwdSwgdTY0IHZhZHIpCit7CisJc2V0X2lmYV9pdGlyX2loYSh2Y3B1LCB2YWRyLCAx
LCAxLCAwKTsKKwlpbmplY3RfZ3Vlc3RfaW50ZXJydXB0aW9uKHZjcHUsIElBNjRfQUxUX0lOU1Rf
VExCX1ZFQ1RPUik7Cit9CisKKy8qIERlYWwgd2l0aDoKKyAqICBWSFBUIFRyYW5zbGF0aW9uIFZl
Y3RvcgorICovCitzdGF0aWMgdm9pZCBfdmhwdF9mYXVsdChWQ1BVICp2Y3B1LCB1NjQgdmFkcikK
K3sKKwkvKiBJZiB2UFNSLmljLCBJRkEsIElUSVIsIElIQSovCisJc2V0X2lmYV9pdGlyX2loYSh2
Y3B1LCB2YWRyLCAxLCAxLCAxKTsKKwlpbmplY3RfZ3Vlc3RfaW50ZXJydXB0aW9uKHZjcHUsIElB
NjRfVkhQVF9UUkFOU19WRUNUT1IpOworCisKK30KKworLyoKKyAqIFZIUFQgSW5zdHJ1Y3Rpb24g
RmF1bHQKKyAqICBAIFZIUFQgVHJhbnNsYXRpb24gdmVjdG9yCisgKiBSZWZlciB0byBTRE0gVm9s
MiBUYWJsZSA1LTYgJiA4LTEKKyAqLwordm9pZCBpdmhwdF9mYXVsdChWQ1BVICp2Y3B1LCB1NjQg
dmFkcikKK3sKKwlfdmhwdF9mYXVsdCh2Y3B1LCB2YWRyKTsKK30KKworCisvKgorICogVkhQVCBE
YXRhIEZhdWx0CisgKiAgQCBWSFBUIFRyYW5zbGF0aW9uIHZlY3RvcgorICogUmVmZXIgdG8gU0RN
IFZvbDIgVGFibGUgNS02ICYgOC0xCisgKi8KK3ZvaWQgZHZocHRfZmF1bHQoVkNQVSAqdmNwdSwg
dTY0IHZhZHIpCit7CisJX3ZocHRfZmF1bHQodmNwdSwgdmFkcik7Cit9CisKKworCisvKgorICog
RGVhbCB3aXRoOgorICogIEdlbmVyYWwgRXhjZXB0aW9uIHZlY3RvcgorICovCit2b2lkIF9nZW5l
cmFsX2V4Y2VwdGlvbihWQ1BVICp2Y3B1KQoreworCWluamVjdF9ndWVzdF9pbnRlcnJ1cHRpb24o
dmNwdSwgSUE2NF9HRU5FWF9WRUNUT1IpOworfQorCisKKy8qCisgKiBJbGxlZ2FsIE9wZXJhdGlv
biBGYXVsdAorICogIEAgR2VuZXJhbCBFeGNlcHRpb24gVmVjdG9yCisgKiBSZWZlciB0byBTRE0g
Vm9sMiBUYWJsZSA1LTYgJiA4LTEKKyAqLwordm9pZCBpbGxlZ2FsX29wKFZDUFUgKnZjcHUpCit7
CisJX2dlbmVyYWxfZXhjZXB0aW9uKHZjcHUpOworfQorCisvKgorICogSWxsZWdhbCBEZXBlbmRl
bmN5IEZhdWx0CisgKiAgQCBHZW5lcmFsIEV4Y2VwdGlvbiBWZWN0b3IKKyAqIFJlZmVyIHRvIFNE
TSBWb2wyIFRhYmxlIDUtNiAmIDgtMQorICovCit2b2lkIGlsbGVnYWxfZGVwKFZDUFUgKnZjcHUp
Cit7CisJX2dlbmVyYWxfZXhjZXB0aW9uKHZjcHUpOworfQorCisvKgorICogUmVzZXJ2ZWQgUmVn
aXN0ZXIvRmllbGQgRmF1bHQKKyAqICBAIEdlbmVyYWwgRXhjZXB0aW9uIFZlY3RvcgorICogUmVm
ZXIgdG8gU0RNIFZvbDIgVGFibGUgNS02ICYgOC0xCisgKi8KK3ZvaWQgcnN2X3JlZ19maWVsZChW
Q1BVICp2Y3B1KQoreworCV9nZW5lcmFsX2V4Y2VwdGlvbih2Y3B1KTsKK30KKy8qCisgKiBQcml2
aWxlZ2VkIE9wZXJhdGlvbiBGYXVsdAorICogIEAgR2VuZXJhbCBFeGNlcHRpb24gVmVjdG9yCisg
KiBSZWZlciB0byBTRE0gVm9sMiBUYWJsZSA1LTYgJiA4LTEKKyAqLworCit2b2lkIHByaXZpbGVn
ZV9vcChWQ1BVICp2Y3B1KQoreworCV9nZW5lcmFsX2V4Y2VwdGlvbih2Y3B1KTsKK30KKworLyoK
KyAqIFVuaW1wbGVtZW50IERhdGEgQWRkcmVzcyBGYXVsdAorICogIEAgR2VuZXJhbCBFeGNlcHRp
b24gVmVjdG9yCisgKiBSZWZlciB0byBTRE0gVm9sMiBUYWJsZSA1LTYgJiA4LTEKKyAqLwordm9p
ZCB1bmltcGxfZGFkZHIoVkNQVSAqdmNwdSkKK3sKKwlfZ2VuZXJhbF9leGNlcHRpb24odmNwdSk7
Cit9CisKKy8qCisgKiBQcml2aWxlZ2VkIFJlZ2lzdGVyIEZhdWx0CisgKiAgQCBHZW5lcmFsIEV4
Y2VwdGlvbiBWZWN0b3IKKyAqIFJlZmVyIHRvIFNETSBWb2wyIFRhYmxlIDUtNiAmIDgtMQorICov
Cit2b2lkIHByaXZpbGVnZV9yZWcoVkNQVSAqdmNwdSkKK3sKKwlfZ2VuZXJhbF9leGNlcHRpb24o
dmNwdSk7Cit9CisKKy8qIERlYWwgd2l0aAorICogIE5hdCBjb25zdW1wdGlvbiB2ZWN0b3IKKyAq
IFBhcmFtZXRlcjoKKyAqICB2YWRkcjogT3B0aW9uYWwsIGlmIHQgPT0gUkVHSVNURVIKKyAqLwor
c3RhdGljIHZvaWQgX25hdF9jb25zdW1wdGlvbl9mYXVsdChWQ1BVICp2Y3B1LCB1NjQgdmFkciwg
bWlzc190eXBlIHQpCit7CisJLyogSWYgdlBTUi5pYyAmJiB0ID09IERBVEEvSU5TVCwgSUZBICov
CisJaWYgKHQgPT0gREFUQSB8fCB0ID09IElOU1RSVUNUSU9OKSB7CisJCS8qIElGQSAqLworCQlz
ZXRfaWZhX2l0aXJfaWhhKHZjcHUsIHZhZHIsIDEsIDAsIDApOworCX0KKworCWluamVjdF9ndWVz
dF9pbnRlcnJ1cHRpb24odmNwdSwgSUE2NF9OQVRfQ09OU1VNUFRJT05fVkVDVE9SKTsKK30KKwor
LyoKKyAqIElSIERhdGEgTmF0IFBhZ2UgQ29uc3VtcHRpb24gRmF1bHQKKyAqICBAIE5hdCBDb25z
dW1wdGlvbiBWZWN0b3IKKyAqIFJlZmVyIHRvIFNETSBWb2wyIFRhYmxlIDUtNiAmIDgtMQorICov
CisjaWYgMAorCXN0YXRpYyB2b2lkCitpcl9uYXRfcGFnZV9jb25zdW1wdGlvbihWQ1BVICp2Y3B1
LCB1NjQgdmFkcikKK3sKKwlfbmF0X2NvbnN1bXB0aW9uX2ZhdWx0KHZjcHUsIHZhZHIsIERBVEEp
OworfQorI2VuZGlmIC8qc2hhZG93IGl0IGR1ZSB0byBubyB1c2UgY3VycmVudGx5Ki8KKworLyoK
KyAqIEluc3RydWN0aW9uIE5hdCBQYWdlIENvbnN1bXB0aW9uIEZhdWx0CisgKiAgQCBOYXQgQ29u
c3VtcHRpb24gVmVjdG9yCisgKiBSZWZlciB0byBTRE0gVm9sMiBUYWJsZSA1LTYgJiA4LTEKKyAq
Lwordm9pZCBpbmF0X3BhZ2VfY29uc3VtcHRpb24oVkNQVSAqdmNwdSwgdTY0IHZhZHIpCit7CisJ
X25hdF9jb25zdW1wdGlvbl9mYXVsdCh2Y3B1LCB2YWRyLCBJTlNUUlVDVElPTik7Cit9CisKKy8q
CisgKiBSZWdpc3RlciBOYXQgQ29uc3VtcHRpb24gRmF1bHQKKyAqICBAIE5hdCBDb25zdW1wdGlv
biBWZWN0b3IKKyAqIFJlZmVyIHRvIFNETSBWb2wyIFRhYmxlIDUtNiAmIDgtMQorICovCit2b2lk
IHJuYXRfY29uc3VtcHRpb24oVkNQVSAqdmNwdSkKK3sKKwlfbmF0X2NvbnN1bXB0aW9uX2ZhdWx0
KHZjcHUsIDAsIFJFR0lTVEVSKTsKK30KKworLyoKKyAqIERhdGEgTmF0IFBhZ2UgQ29uc3VtcHRp
b24gRmF1bHQKKyAqICBAIE5hdCBDb25zdW1wdGlvbiBWZWN0b3IKKyAqIFJlZmVyIHRvIFNETSBW
b2wyIFRhYmxlIDUtNiAmIDgtMQorICovCit2b2lkIGRuYXRfcGFnZV9jb25zdW1wdGlvbihWQ1BV
ICp2Y3B1LCB1NjQgdmFkcikKK3sKKwlfbmF0X2NvbnN1bXB0aW9uX2ZhdWx0KHZjcHUsIHZhZHIs
IERBVEEpOworfQorCisvKiBEZWFsIHdpdGgKKyAqICBQYWdlIG5vdCBwcmVzZW50IHZlY3Rvcgor
ICovCitzdGF0aWMgdm9pZCBfX3BhZ2Vfbm90X3ByZXNlbnQoVkNQVSAqdmNwdSwgdTY0IHZhZHIp
Cit7CisJLyogSWYgdlBTUi5pYywgSUZBLCBJVElSICovCisJc2V0X2lmYV9pdGlyX2loYSh2Y3B1
LCB2YWRyLCAxLCAxLCAwKTsKKwlpbmplY3RfZ3Vlc3RfaW50ZXJydXB0aW9uKHZjcHUsIElBNjRf
UEFHRV9OT1RfUFJFU0VOVF9WRUNUT1IpOworfQorCisKK3ZvaWQgZGF0YV9wYWdlX25vdF9wcmVz
ZW50KFZDUFUgKnZjcHUsIHU2NCB2YWRyKQoreworCV9fcGFnZV9ub3RfcHJlc2VudCh2Y3B1LCB2
YWRyKTsKK30KKworCit2b2lkIGluc3RfcGFnZV9ub3RfcHJlc2VudChWQ1BVICp2Y3B1LCB1NjQg
dmFkcikKK3sKKwlfX3BhZ2Vfbm90X3ByZXNlbnQodmNwdSwgdmFkcik7Cit9CisKKworLyogRGVh
bCB3aXRoCisgKiAgRGF0YSBhY2Nlc3MgcmlnaHRzIHZlY3RvcgorICovCit2b2lkIGRhdGFfYWNj
ZXNzX3JpZ2h0cyhWQ1BVICp2Y3B1LCB1NjQgdmFkcikKK3sKKwkvKiBJZiB2UFNSLmljLCBJRkEs
IElUSVIgKi8KKwlzZXRfaWZhX2l0aXJfaWhhKHZjcHUsIHZhZHIsIDEsIDEsIDApOworCWluamVj
dF9ndWVzdF9pbnRlcnJ1cHRpb24odmNwdSwgSUE2NF9EQVRBX0FDQ0VTU19SSUdIVFNfVkVDVE9S
KTsKK30KKworZnBzd2FfcmV0X3Qgdm1tX2ZwX2VtdWxhdGUoaW50IGZwX2ZhdWx0LCB2b2lkICpi
dW5kbGUsIHVuc2lnbmVkIGxvbmcgKmlwc3IsCisJCXVuc2lnbmVkIGxvbmcgKmZwc3IsIHVuc2ln
bmVkIGxvbmcgKmlzciwgdW5zaWduZWQgbG9uZyAqcHIsCisJCXVuc2lnbmVkIGxvbmcgKmlmcywg
UkVHUyAqcmVncykKK3sKKwlmcF9zdGF0ZV90IGZwX3N0YXRlOworCWZwc3dhX3JldF90IHJldDsK
KwlzdHJ1Y3Qga3ZtX3ZjcHUgKnZjcHUgPSBjdXJyZW50X3ZjcHU7CisKKwl1aW50NjRfdCBvbGRf
cnI3ID0gaWE2NF9nZXRfcnIoN1VMPDw2MSk7CisKKwlpZiAoIXZtbV9mcHN3YV9pbnRlcmZhY2Up
CisJCXJldHVybiAoZnBzd2FfcmV0X3QpIHstMSwgMCwgMCwgMH07CisKKwkvKgorCSAqIEp1c3Qg
bGV0IGZwc3dhIGRyaXZlciB0byB1c2UgaGFyZHdhcmUgZnAgcmVnaXN0ZXJzLgorCSAqIE5vIGZw
IHJlZ2lzdGVyIGlzIHZhbGlkIGluIG1lbW9yeS4KKwkgKi8KKwltZW1zZXQoJmZwX3N0YXRlLCAw
LCBzaXplb2YoZnBfc3RhdGVfdCkpOworCisJLyoKKwkgKiB1bnNpZ25lZCBsb25nICgqRUZJX0ZQ
U1dBKSAoCisJICogICAgICB1bnNpZ25lZCBsb25nICAgIHRyYXBfdHlwZSwKKwkgKiAgICAgIHZv
aWQgICAgICAgICAgICAgKkJ1bmRsZSwKKwkgKiAgICAgIHVuc2lnbmVkIGxvbmcgICAgKnBpcHNy
LAorCSAqICAgICAgdW5zaWduZWQgbG9uZyAgICAqcGZzciwKKwkgKiAgICAgIHVuc2lnbmVkIGxv
bmcgICAgKnBpc3IsCisJICogICAgICB1bnNpZ25lZCBsb25nICAgICpwcHJlZHMsCisJICogICAg
ICB1bnNpZ25lZCBsb25nICAgICpwaWZzLAorCSAqICAgICAgdm9pZCAgICAgICAgICAgICAqZnBf
c3RhdGUpOworCSAqLworCS8qQ2FsbCBob3N0IGZwc3dhIGludGVyZmFjZSBkaXJlY3RseSB0byB2
aXJ0dWFsaXplCisJICpndWVzdCBmcHN3YSByZXF1ZXN0IQorCSAqLworCWlhNjRfc2V0X3JyKDdV
TCA8PCA2MSwgdmNwdS0+YXJjaC5ob3N0LnJyWzddKTsKKwlpYTY0X3NybHpfZCgpOworCisJcmV0
ID0gKCp2bW1fZnBzd2FfaW50ZXJmYWNlLT5mcHN3YSkgKGZwX2ZhdWx0LCBidW5kbGUsCisJCQlp
cHNyLCBmcHNyLCBpc3IsIHByLCBpZnMsICZmcF9zdGF0ZSk7CisJaWE2NF9zZXRfcnIoN1VMIDw8
IDYxLCBvbGRfcnI3KTsKKwlpYTY0X3NybHpfZCgpOworCXJldHVybiByZXQ7Cit9CisKKy8qCisg
KiBIYW5kbGUgZmxvYXRpbmctcG9pbnQgYXNzaXN0IGZhdWx0cyBhbmQgdHJhcHMgZm9yIGRvbWFp
bi4KKyAqLwordW5zaWduZWQgbG9uZyB2bW1faGFuZGxlX2ZwdV9zd2EoaW50IGZwX2ZhdWx0LCBS
RUdTICpyZWdzLCB1bnNpZ25lZCBsb25nIGlzcikKK3sKKwlzdHJ1Y3Qga3ZtX3ZjcHUgKnYgPSBj
dXJyZW50X3ZjcHU7CisJSUE2NF9CVU5ETEUgYnVuZGxlOworCXVuc2lnbmVkIGxvbmcgZmF1bHRf
aXA7CisJZnBzd2FfcmV0X3QgcmV0OworCisJZmF1bHRfaXAgPSByZWdzLT5jcl9paXA7CisJLyoK
KwkgKiBXaGVuIHRoZSBGUCB0cmFwIG9jY3VycywgdGhlIHRyYXBwaW5nIGluc3RydWN0aW9uIGlz
IGNvbXBsZXRlZC4KKwkgKiBJZiBpcHNyLnJpID09IDAsIHRoZXJlIGlzIHRoZSB0cmFwcGluZyBp
bnN0cnVjdGlvbiBpbiBwcmV2aW91cworCSAqIGJ1bmRsZS4KKwkgKi8KKwlpZiAoIWZwX2ZhdWx0
ICYmIChpYTY0X3BzcihyZWdzKS0+cmkgPT0gMCkpCisJCWZhdWx0X2lwIC09IDE2OworCisJaWYg
KGZldGNoX2NvZGUodiwgZmF1bHRfaXAsICZidW5kbGUpKQorCQlyZXR1cm4gLUVBR0FJTjsKKwor
CWlmICghYnVuZGxlLmk2NFswXSAmJiAhYnVuZGxlLmk2NFsxXSkgeworCQlyZXR1cm4gLUVBQ0NF
UzsKKwl9CisKKwlyZXQgPSB2bW1fZnBfZW11bGF0ZShmcF9mYXVsdCwgJmJ1bmRsZSwgJnJlZ3Mt
PmNyX2lwc3IsICZyZWdzLT5hcl9mcHNyLAorCQkJJmlzciwgJnJlZ3MtPnByLCAmcmVncy0+Y3Jf
aWZzLCByZWdzKTsKKwlyZXR1cm4gcmV0LnN0YXR1czsKK30KKwordm9pZCByZWZsZWN0X2ludGVy
cnVwdGlvbih1NjQgaWZhLCB1NjQgaXNyLCB1NjQgaWltLAorCQl1NjQgdmVjLCBSRUdTICpyZWdz
KQoreworCXU2NCB2ZWN0b3I7CisJaW50IHN0YXR1cyA7CisJVkNQVSAqdmNwdSA9IGN1cnJlbnRf
dmNwdTsKKwl1NjQgdnBzciA9IFZDUFUodmNwdSwgdnBzcik7CisKKwl2ZWN0b3IgPSB2ZWMyb2Zm
W3ZlY107CisKKwlpZiAoISh2cHNyICYgSUE2NF9QU1JfSUMpICYmICh2ZWN0b3IgIT0gSUE2NF9E
QVRBX05FU1RFRF9UTEJfVkVDVE9SKSkgeworCQlwYW5pY192bSh2Y3B1KTsKKwkJcmV0dXJuOwor
CX0KKworCXN3aXRjaCAodmVjKSB7CisJY2FzZSAzMjogCS8qSUE2NF9GUF9GQVVMVF9WRUNUT1Iq
LworCQlzdGF0dXMgPSB2bW1faGFuZGxlX2ZwdV9zd2EoMSwgcmVncywgaXNyKTsKKwkJaWYgKCFz
dGF0dXMpIHsKKwkJCXZjcHVfaW5jcmVtZW50X2lpcCh2Y3B1KTsKKwkJCXJldHVybjsKKwkJfSBl
bHNlIGlmICgtRUFHQUlOID09IHN0YXR1cykKKwkJCXJldHVybjsKKwkJYnJlYWs7CisJY2FzZSAz
MzoJLypJQTY0X0ZQX1RSQVBfVkVDVE9SKi8KKwkJc3RhdHVzID0gdm1tX2hhbmRsZV9mcHVfc3dh
KDAsIHJlZ3MsIGlzcik7CisJCWlmICghc3RhdHVzKQorCQkJcmV0dXJuIDsKKwkJZWxzZSBpZiAo
LUVBR0FJTiA9PSBzdGF0dXMpIHsKKwkJCXZjcHVfZGVjcmVtZW50X2lpcCh2Y3B1KTsKKwkJCXJl
dHVybiA7CisJCX0KKwkJYnJlYWs7CisJfQorCisJVkNQVSh2Y3B1LCBpc3IpID0gaXNyOworCVZD
UFUodmNwdSwgaWlwYSkgPSByZWdzLT5jcl9paXA7CisJaWYgKHZlY3RvciA9PSBJQTY0X0JSRUFL
X1ZFQ1RPUiB8fCB2ZWN0b3IgPT0gSUE2NF9TUEVDVUxBVElPTl9WRUNUT1IpCisJCVZDUFUodmNw
dSwgaWltKSA9IGlpbTsKKwllbHNlIHsKKwkJc2V0X2lmYV9pdGlyX2loYSh2Y3B1LCBpZmEsIDEs
IDEsIDEpOworCX0KKwlpbmplY3RfZ3Vlc3RfaW50ZXJydXB0aW9uKHZjcHUsIHZlY3Rvcik7Cit9
CisKK3N0YXRpYyB2b2lkIHNldF9wYWxfY2FsbF9kYXRhKFZDUFUgKnZjcHUpCit7CisJc3RydWN0
IGV4aXRfY3RsX2RhdGEgKnAgPSAmdmNwdS0+YXJjaC5leGl0X2RhdGE7CisKKwkvKkZJWE1FOkZv
ciBzdGF0aWMgYW5kIHN0YWNrZWQgY29udmVudGlvbiwgZmlybXdhcmUKKwkgKiBoYXMgcHV0IHRo
ZSBwYXJhbWV0ZXJzIGluIGdyMjgtZ3IzMSBiZWZvcmUKKwkgKiBicmVhayB0byB2bW0gICEhKi8K
KworCXAtPnUucGFsX2RhdGEuZ3IyOCA9IHZjcHVfZ2V0X2dyKHZjcHUsIDI4KTsKKwlwLT51LnBh
bF9kYXRhLmdyMjkgPSB2Y3B1X2dldF9ncih2Y3B1LCAyOSk7CisJcC0+dS5wYWxfZGF0YS5ncjMw
ID0gdmNwdV9nZXRfZ3IodmNwdSwgMzApOworCXAtPnUucGFsX2RhdGEuZ3IzMSA9IHZjcHVfZ2V0
X2dyKHZjcHUsIDMxKTsKKwlwLT5leGl0X3JlYXNvbiA9IEVYSVRfUkVBU09OX1BBTF9DQUxMOwor
fQorCitzdGF0aWMgdm9pZCBzZXRfcGFsX2NhbGxfcmVzdWx0KFZDUFUgKnZjcHUpCit7CisJc3Ry
dWN0IGV4aXRfY3RsX2RhdGEgKnAgPSAmdmNwdS0+YXJjaC5leGl0X2RhdGE7CisKKwlpZiAocC0+
ZXhpdF9yZWFzb24gPT0gRVhJVF9SRUFTT05fUEFMX0NBTEwpIHsKKwkJdmNwdV9zZXRfZ3IodmNw
dSwgOCwgcC0+dS5wYWxfZGF0YS5yZXQuc3RhdHVzLCAwKTsKKwkJdmNwdV9zZXRfZ3IodmNwdSwg
OSwgcC0+dS5wYWxfZGF0YS5yZXQudjAsIDApOworCQl2Y3B1X3NldF9ncih2Y3B1LCAxMCwgcC0+
dS5wYWxfZGF0YS5yZXQudjEsIDApOworCQl2Y3B1X3NldF9ncih2Y3B1LCAxMSwgcC0+dS5wYWxf
ZGF0YS5yZXQudjIsIDApOworCX0gZWxzZQorCQlwYW5pY192bSh2Y3B1KTsKK30KKworc3RhdGlj
IHZvaWQgc2V0X3NhbF9jYWxsX2RhdGEoVkNQVSAqdmNwdSkKK3sKKwlzdHJ1Y3QgZXhpdF9jdGxf
ZGF0YSAqcCA9ICZ2Y3B1LT5hcmNoLmV4aXRfZGF0YTsKKworCXAtPnUuc2FsX2RhdGEuaW4wID0g
dmNwdV9nZXRfZ3IodmNwdSwgMzIpOworCXAtPnUuc2FsX2RhdGEuaW4xID0gdmNwdV9nZXRfZ3Io
dmNwdSwgMzMpOworCXAtPnUuc2FsX2RhdGEuaW4yID0gdmNwdV9nZXRfZ3IodmNwdSwgMzQpOwor
CXAtPnUuc2FsX2RhdGEuaW4zID0gdmNwdV9nZXRfZ3IodmNwdSwgMzUpOworCXAtPnUuc2FsX2Rh
dGEuaW40ID0gdmNwdV9nZXRfZ3IodmNwdSwgMzYpOworCXAtPnUuc2FsX2RhdGEuaW41ID0gdmNw
dV9nZXRfZ3IodmNwdSwgMzcpOworCXAtPnUuc2FsX2RhdGEuaW42ID0gdmNwdV9nZXRfZ3IodmNw
dSwgMzgpOworCXAtPnUuc2FsX2RhdGEuaW43ID0gdmNwdV9nZXRfZ3IodmNwdSwgMzkpOworCXAt
PmV4aXRfcmVhc29uID0gRVhJVF9SRUFTT05fU0FMX0NBTEw7Cit9CisKK3N0YXRpYyB2b2lkIHNl
dF9zYWxfY2FsbF9yZXN1bHQoVkNQVSAqdmNwdSkKK3sKKwlzdHJ1Y3QgZXhpdF9jdGxfZGF0YSAq
cCA9ICZ2Y3B1LT5hcmNoLmV4aXRfZGF0YTsKKworCWlmIChwLT5leGl0X3JlYXNvbiA9PSBFWElU
X1JFQVNPTl9TQUxfQ0FMTCkgeworCQl2Y3B1X3NldF9ncih2Y3B1LCA4LCBwLT51LnNhbF9kYXRh
LnJldC5yOCwgMCk7CisJCXZjcHVfc2V0X2dyKHZjcHUsIDksIHAtPnUuc2FsX2RhdGEucmV0LnI5
LCAwKTsKKwkJdmNwdV9zZXRfZ3IodmNwdSwgMTAsIHAtPnUuc2FsX2RhdGEucmV0LnIxMCwgMCk7
CisJCXZjcHVfc2V0X2dyKHZjcHUsIDExLCBwLT51LnNhbF9kYXRhLnJldC5yMTEsIDApOworCX0g
ZWxzZQorCQlwYW5pY192bSh2Y3B1KTsKK30KKwordm9pZCAga3ZtX2lhNjRfaGFuZGxlX2JyZWFr
KHVuc2lnbmVkIGxvbmcgaWZhLCBzdHJ1Y3Qga3ZtX3B0X3JlZ3MgKnJlZ3MsCisJCXVuc2lnbmVk
IGxvbmcgaXNyLCB1bnNpZ25lZCBsb25nIGlpbSkKK3sKKwlWQ1BVICp2ID0gY3VycmVudF92Y3B1
OworCisJaWYgKGlhNjRfcHNyKHJlZ3MpLT5jcGwgPT0gMCkgeworCQkvKiBBbGxvdyBoeXBlcmNh
bGxzIG9ubHkgd2hlbiBjcGwgPSAwLiAgKi8KKwkJaWYgKGlpbSA9PSBET01OX1BBTF9SRVFVRVNU
KSB7CisJCQlzZXRfcGFsX2NhbGxfZGF0YSh2KTsKKwkJCXZtbV90cmFuc2l0aW9uKHYpOworCQkJ
c2V0X3BhbF9jYWxsX3Jlc3VsdCh2KTsKKwkJCXZjcHVfaW5jcmVtZW50X2lpcCh2KTsKKwkJCXJl
dHVybjsKKwkJfSBlbHNlIGlmIChpaW0gPT0gRE9NTl9TQUxfUkVRVUVTVCkgeworCQkJc2V0X3Nh
bF9jYWxsX2RhdGEodik7CisJCQl2bW1fdHJhbnNpdGlvbih2KTsKKwkJCXNldF9zYWxfY2FsbF9y
ZXN1bHQodik7CisJCQl2Y3B1X2luY3JlbWVudF9paXAodik7CisJCQlyZXR1cm47CisJCX0KKwl9
CisJcmVmbGVjdF9pbnRlcnJ1cHRpb24oaWZhLCBpc3IsIGlpbSwgMTEsIHJlZ3MpOworfQorCit2
b2lkIGNoZWNrX3BlbmRpbmdfaXJxKFZDUFUgKnZjcHUpCit7CisJaW50ICBtYXNrLCBoX3BlbmRp
bmcsIGhfaW5zZXJ2aWNlOworCXU2NCBpc3I7CisJaWE2NF9wc3IgdnBzcjsKKwlSRUdTICpyZWdz
ID0gdmNwdV9yZWdzKHZjcHUpOworCisJaF9wZW5kaW5nID0gaGlnaGVzdF9wZW5kaW5nX2lycSh2
Y3B1KTsKKwlpZiAoaF9wZW5kaW5nID09IE5VTExfVkVDVE9SKSB7CisJCXVwZGF0ZV92aHBpKHZj
cHUsIE5VTExfVkVDVE9SKTsKKwkJcmV0dXJuOworCX0KKwloX2luc2VydmljZSA9IGhpZ2hlc3Rf
aW5zZXJ2aWNlX2lycSh2Y3B1KTsKKworCXZwc3IudmFsID0gVkNQVSh2Y3B1LCB2cHNyKTsKKwlt
YXNrID0gaXJxX21hc2tlZCh2Y3B1LCBoX3BlbmRpbmcsIGhfaW5zZXJ2aWNlKTsKKwlpZiAodnBz
ci5pICYmIElSUV9OT19NQVNLRUQgPT0gbWFzaykgeworCQlpc3IgPSB2cHNyLnZhbCAmIElBNjRf
UFNSX1JJOworCQl1cGRhdGVfdmhwaSh2Y3B1LCBoX3BlbmRpbmcpOworCQlyZWZsZWN0X2ludGVy
cnVwdGlvbigwLCBpc3IsIDAsIDEyLCByZWdzKTsgLyogRVhUIElSUSAqLworCX0gZWxzZSBpZiAo
bWFzayA9PSBJUlFfTUFTS0VEX0JZX0lOU1ZDKSB7CisJCWlmIChWQ1BVKHZjcHUsIHZocGkpKQor
CQkJdXBkYXRlX3ZocGkodmNwdSwgTlVMTF9WRUNUT1IpOworCX0gZWxzZSB7CisJCS8qIG1hc2tl
ZCBieSB2cHNyLmkgb3IgdnRwci4qLworCQl1cGRhdGVfdmhwaSh2Y3B1LCBoX3BlbmRpbmcpOwor
CX0KK30KKworc3RhdGljIHZvaWQgZ2VuZXJhdGVfZXhpcnEoVkNQVSAqdmNwdSkKK3sKKwlpYTY0
X3BzciB2cHNyOworCXVpbnQ2NF90IGlzcjsKKworCVJFR1MgKnJlZ3MgPSB2Y3B1X3JlZ3ModmNw
dSk7CisKKwl2cHNyLnZhbCA9IFZDUFUodmNwdSwgdnBzcik7CisJaXNyID0gdnBzci52YWwgJiBJ
QTY0X1BTUl9SSTsKKwlpZiAoIXZwc3IuaWMpCisJCXBhbmljX3ZtKHZjcHUpOworCXJlZmxlY3Rf
aW50ZXJydXB0aW9uKDAsIGlzciwgMCwgMTIsIHJlZ3MpOyAvKiBFWFQgSVJRICovCit9CisKK3Zv
aWQgdmhwaV9kZXRlY3Rpb24oVkNQVSAqdmNwdSkKK3sKKwl1aW50NjRfdCAgICB0aHJlc2hvbGQs
IHZocGk7CisJdHByX3QgICAgICAgdnRwcjsKKwlpYTY0X3BzciAgICB2cHNyOworCisJdnBzci52
YWwgPSBWQ1BVKHZjcHUsIHZwc3IpOworCXZ0cHIudmFsID0gVkNQVSh2Y3B1LCB0cHIpOworCisJ
dGhyZXNob2xkID0gKCghdnBzci5pKSA8PCA1KSB8ICh2dHByLm1taSA8PCA0KSB8IHZ0cHIubWlj
OworCXZocGkgPSBWQ1BVKHZjcHUsIHZocGkpOworCWlmICh2aHBpID4gdGhyZXNob2xkKSB7CisJ
CS8qIGludGVycnVwdCBhY3RpdmVkKi8KKwkJZ2VuZXJhdGVfZXhpcnEodmNwdSk7CisJfQorfQor
CisKK3ZvaWQgbGVhdmVfaHlwZXJ2aXNvcl90YWlsKHZvaWQpCit7CisJVkNQVSAqdiA9IGN1cnJl
bnRfdmNwdTsKKworCWlmIChWTVgodiwgdGltZXJfY2hlY2spKSB7CisJCVZNWCh2LCB0aW1lcl9j
aGVjaykgPSAwOworCQlpZiAoVk1YKHYsIGl0Y19jaGVjaykpIHsKKwkJCWlmICh2Y3B1X2dldF9p
dGModikgPiBWQ1BVKHYsIGl0bSkpIHsKKwkJCQlpZiAoIShWQ1BVKHYsIGl0dikgJiAoMSA8PCAx
NikpKSB7CisJCQkJCXZjcHVfcGVuZF9pbnRlcnJ1cHQodiwgVkNQVSh2LCBpdHYpCisJCQkJCQkJ
JiAweGZmKTsKKwkJCQlWTVgodiwgaXRjX2NoZWNrKSA9IDA7CisJCQkJfSBlbHNlIHsKKwkJCQkJ
di0+YXJjaC50aW1lcl9wZW5kaW5nID0gMTsKKwkJCQl9CisJCQkJVk1YKHYsIGxhc3RfaXRjKSA9
IFZDUFUodiwgaXRtKSArIDE7CisJCQl9CisJCX0KKwl9CisKKwlybWIoKTsKKwlpZiAodi0+YXJj
aC5pcnFfbmV3X3BlbmRpbmcpIHsKKwkJdi0+YXJjaC5pcnFfbmV3X3BlbmRpbmcgPSAwOworCQlW
TVgodiwgaXJxX2NoZWNrKSA9IDA7CisJCWNoZWNrX3BlbmRpbmdfaXJxKHYpOworCQlyZXR1cm47
CisJfQorCWlmIChWTVgodiwgaXJxX2NoZWNrKSkgeworCQlWTVgodiwgaXJxX2NoZWNrKSA9IDA7
CisJCXZocGlfZGV0ZWN0aW9uKHYpOworCX0KK30KKworCitzdGF0aWMgaW5saW5lIHZvaWQgaGFu
ZGxlX2xkcyhSRUdTICpyZWdzKQoreworCXJlZ3MtPmNyX2lwc3IgfD0gSUE2NF9QU1JfRUQ7Cit9
CisKK3ZvaWQgcGh5c2ljYWxfdGxiX21pc3MoVkNQVSAqdmNwdSwgdW5zaWduZWQgbG9uZyB2YWRy
LCBpbnQgdHlwZSkKK3sKKwl1bnNpZ25lZCBsb25nIHB0ZTsKKwlpYTY0X3JyIHJyOworCisJcnIu
dmFsID0gaWE2NF9nZXRfcnIodmFkcik7CisJcHRlID0gIHZhZHIgJiBfUEFHRV9QUE5fTUFTSzsK
KwlwdGUgPSBwdGUgfCBQSFlfUEFHRV9XQjsKKwl0aGFzaF92aHB0X2luc2VydCh2Y3B1LCBwdGUs
ICh1NjQpKHJyLnBzIDw8IDIpLCB2YWRyLCB0eXBlKTsKKwlyZXR1cm47Cit9CisKK3ZvaWQga3Zt
X3BhZ2VfZmF1bHQodTY0IHZhZHIgLCB1NjQgdmVjLCBSRUdTICpyZWdzKQoreworCWlhNjRfcHNy
IHZwc3I7CisJaW50IHR5cGU7CisKKwl1NjQgdmhwdF9hZHIsIGdwcGEsIHB0ZXZhbCwgcnIsIGl0
aXI7CisJaWE2NF9pc3IgbWlzcjsKKwlpYTY0X3B0YSB2cHRhOworCXRoYXNoX2RhdGFfdCAqZGF0
YTsKKwlWQ1BVICp2ID0gY3VycmVudF92Y3B1OworCisJdnBzci52YWwgPSBWQ1BVKHYsIHZwc3Ip
OworCW1pc3IudmFsID0gVk1YKHYsIGNyX2lzcik7CisKKwl0eXBlID0gdmVjOworCisJaWYgKGlz
X3BoeXNpY2FsX21vZGUodikgJiYgKCEodmFkciA8PCAxID4+IDYyKSkpIHsKKwkJaWYgKHZlYyA9
PSAyKSB7CisJCQlpZiAoX19ncGZuX2lzX2lvKCh2YWRyIDw8IDEpID4+IChQQUdFX1NISUZUICsg
MSkpKSB7CisJCQkJZW11bGF0ZV9pb19pbnN0KHYsICgodmFkciA8PCAxKSA+PiAxKSwgNCk7CisJ
CQkJcmV0dXJuOworCQkJfQorCQl9CisJCXBoeXNpY2FsX3RsYl9taXNzKHYsIHZhZHIsIHR5cGUp
OworCQlyZXR1cm47CisJfQorCWRhdGEgPSB2dGxiX2xvb2t1cCh2LCB2YWRyLCB0eXBlKTsKKwlp
ZiAoZGF0YSAhPSAwKSB7CisJCWlmICh0eXBlID09IERfVExCKSB7CisJCQlncHBhID0gKHZhZHIg
JiAoKDFVTCA8PCBkYXRhLT5wcykgLSAxKSkKKwkJCQkrIChkYXRhLT5wcG4gPj4gKGRhdGEtPnBz
IC0gMTIpIDw8IGRhdGEtPnBzKTsKKwkJCWlmIChfX2dwZm5faXNfaW8oZ3BwYSA+PiBQQUdFX1NI
SUZUKSkgeworCQkJCWlmIChkYXRhLT5wbCA+PSAoKHJlZ3MtPmNyX2lwc3IgPj4KKwkJCQkJCUlB
NjRfUFNSX0NQTDBfQklUKSAmIDMpKQorCQkJCQllbXVsYXRlX2lvX2luc3QodiwgZ3BwYSwgZGF0
YS0+bWEpOworCQkJCWVsc2UgeworCQkJCQl2Y3B1X3NldF9pc3IodiwgbWlzci52YWwpOworCQkJ
CQlkYXRhX2FjY2Vzc19yaWdodHModiwgdmFkcik7CisJCQkJfQorCQkJCXJldHVybiA7CisJCQl9
CisJCX0KKwkJdGhhc2hfdmhwdF9pbnNlcnQodiwgZGF0YS0+cGFnZV9mbGFncywgZGF0YS0+aXRp
ciwgdmFkciwgdHlwZSk7CisKKwl9IGVsc2UgaWYgKHR5cGUgPT0gRF9UTEIpIHsKKwkJaWYgKG1p
c3Iuc3ApIHsKKwkJCWhhbmRsZV9sZHMocmVncyk7CisJCQlyZXR1cm47CisJCX0KKworCQlyciA9
IHZjcHVfZ2V0X3JyKHYsIHZhZHIpOworCQlpdGlyID0gcnIgJiAoUlJfUklEX01BU0sgfCBSUl9Q
U19NQVNLKTsKKworCQlpZiAoIXZocHRfZW5hYmxlZCh2LCB2YWRyLCBtaXNyLnJzID8gUlNFX1JF
RiA6IERBVEFfUkVGKSkgeworCQkJaWYgKHZwc3IuaWMpIHsKKwkJCQl2Y3B1X3NldF9pc3Iodiwg
bWlzci52YWwpOworCQkJCWFsdF9kdGxiKHYsIHZhZHIpOworCQkJfSBlbHNlIHsKKwkJCQluZXN0
ZWRfZHRsYih2KTsKKwkJCX0KKwkJCXJldHVybiA7CisJCX0KKworCQl2cHRhLnZhbCA9IHZjcHVf
Z2V0X3B0YSh2KTsKKwkJLyogYXZvaWQgcmVjdXJzaXZlbHkgd2Fsa2luZyAoc2hvcnQgZm9ybWF0
KSBWSFBUICovCisKKwkJdmhwdF9hZHIgPSB2Y3B1X3RoYXNoKHYsIHZhZHIpOworCQlpZiAoIWd1
ZXN0X3ZocHRfbG9va3VwKHZocHRfYWRyLCAmcHRldmFsKSkgeworCQkJLyogVkhQVCBzdWNjZXNz
ZnVsbHkgcmVhZC4gICovCisJCQlpZiAoIShwdGV2YWwgJiBfUEFHRV9QKSkgeworCQkJCWlmICh2
cHNyLmljKSB7CisJCQkJCXZjcHVfc2V0X2lzcih2LCBtaXNyLnZhbCk7CisJCQkJCWR0bGJfZmF1
bHQodiwgdmFkcik7CisJCQkJfSBlbHNlIHsKKwkJCQkJbmVzdGVkX2R0bGIodik7CisJCQkJfQor
CQkJfSBlbHNlIGlmICgocHRldmFsICYgX1BBR0VfTUFfTUFTSykgIT0gX1BBR0VfTUFfU1QpIHsK
KwkJCQl0aGFzaF9wdXJnZV9hbmRfaW5zZXJ0KHYsIHB0ZXZhbCwgaXRpciwKKwkJCQkJCQkJdmFk
ciwgRF9UTEIpOworCQkJfSBlbHNlIGlmICh2cHNyLmljKSB7CisJCQkJdmNwdV9zZXRfaXNyKHYs
IG1pc3IudmFsKTsKKwkJCQlkdGxiX2ZhdWx0KHYsIHZhZHIpOworCQkJfSBlbHNlIHsKKwkJCQlu
ZXN0ZWRfZHRsYih2KTsKKwkJCX0KKwkJfSBlbHNlIHsKKwkJCS8qIENhbid0IHJlYWQgVkhQVC4g
ICovCisJCQlpZiAodnBzci5pYykgeworCQkJCXZjcHVfc2V0X2lzcih2LCBtaXNyLnZhbCk7CisJ
CQkJZHZocHRfZmF1bHQodiwgdmFkcik7CisJCQl9IGVsc2UgeworCQkJCW5lc3RlZF9kdGxiKHYp
OworCQkJfQorCQl9CisJfSBlbHNlIGlmICh0eXBlID09IElfVExCKSB7CisJCWlmICghdnBzci5p
YykKKwkJCW1pc3IubmkgPSAxOworCQlpZiAoIXZocHRfZW5hYmxlZCh2LCB2YWRyLCBJTlNUX1JF
RikpIHsKKwkJCXZjcHVfc2V0X2lzcih2LCBtaXNyLnZhbCk7CisJCQlhbHRfaXRsYih2LCB2YWRy
KTsKKwkJCXJldHVybjsKKwkJfQorCisJCXZwdGEudmFsID0gdmNwdV9nZXRfcHRhKHYpOworCisJ
CXZocHRfYWRyID0gdmNwdV90aGFzaCh2LCB2YWRyKTsKKwkJaWYgKCFndWVzdF92aHB0X2xvb2t1
cCh2aHB0X2FkciwgJnB0ZXZhbCkpIHsKKwkJCS8qIFZIUFQgc3VjY2Vzc2Z1bGx5IHJlYWQuICAq
LworCQkJaWYgKHB0ZXZhbCAmIF9QQUdFX1ApIHsKKwkJCQlpZiAoKHB0ZXZhbCAmIF9QQUdFX01B
X01BU0spID09IF9QQUdFX01BX1NUKSB7CisJCQkJCXZjcHVfc2V0X2lzcih2LCBtaXNyLnZhbCk7
CisJCQkJCWl0bGJfZmF1bHQodiwgdmFkcik7CisJCQkJCXJldHVybiA7CisJCQkJfQorCQkJCXJy
ID0gdmNwdV9nZXRfcnIodiwgdmFkcik7CisJCQkJaXRpciA9IHJyICYgKFJSX1JJRF9NQVNLIHwg
UlJfUFNfTUFTSyk7CisJCQkJdGhhc2hfcHVyZ2VfYW5kX2luc2VydCh2LCBwdGV2YWwsIGl0aXIs
CisJCQkJCQkJdmFkciwgSV9UTEIpOworCQkJfSBlbHNlIHsKKwkJCQl2Y3B1X3NldF9pc3Iodiwg
bWlzci52YWwpOworCQkJCWluc3RfcGFnZV9ub3RfcHJlc2VudCh2LCB2YWRyKTsKKwkJCX0KKwkJ
fSBlbHNlIHsKKwkJCXZjcHVfc2V0X2lzcih2LCBtaXNyLnZhbCk7CisJCQlpdmhwdF9mYXVsdCh2
LCB2YWRyKTsKKwkJfQorCX0KK30KKwordm9pZCBrdm1fdmV4aXJxKFZDUFUgKnZjcHUpCit7CisJ
dTY0IHZwc3IsIGlzcjsKKwlSRUdTICpyZWdzOworCisJcmVncyA9IHZjcHVfcmVncyh2Y3B1KTsK
Kwl2cHNyID0gVkNQVSh2Y3B1LCB2cHNyKTsKKwlpc3IgPSB2cHNyICYgSUE2NF9QU1JfUkk7CisJ
cmVmbGVjdF9pbnRlcnJ1cHRpb24oMCwgaXNyLCAwLCAxMiwgcmVncyk7IC8qRVhUIElSUSovCit9
CisKK3ZvaWQga3ZtX2lhNjRfaGFuZGxlX2lycShWQ1BVICp2KQoreworCXN0cnVjdCBleGl0X2N0
bF9kYXRhICpwID0gJnYtPmFyY2guZXhpdF9kYXRhOworCWxvbmcgcHNyOworCisJbG9jYWxfaXJx
X3NhdmUocHNyKTsKKwlwLT5leGl0X3JlYXNvbiA9IEVYSVRfUkVBU09OX0VYVEVSTkFMX0lOVEVS
UlVQVDsKKwl2bW1fdHJhbnNpdGlvbih2KTsKKwlsb2NhbF9pcnFfcmVzdG9yZShwc3IpOworCisJ
Vk1YKHYsIHRpbWVyX2NoZWNrKSA9IDE7CisKK30KKworc3RhdGljIHZvaWQgcHRjX2dhX3JlbW90
ZV9mdW5jKHN0cnVjdCBrdm1fdmNwdSAqdiwgaW50IHBvcykKK3sKKwl1NjQgb2xkcmlkLCBtb2xk
cmlkLCBvbGRwc2JpdHMsIHZhZGRyOworCXN0cnVjdCBrdm1fcHRjX2cgKnAgPSAmdi0+YXJjaC5w
dGNfZ19kYXRhW3Bvc107CisJdmFkZHIgPSBwLT52YWRkcjsKKworCW9sZHJpZCA9IFZNWCh2LCB2
cnJbMF0pOworCVZNWCh2LCB2cnJbMF0pID0gcC0+cnI7CisJb2xkcHNiaXRzID0gVk1YKHYsIHBz
Yml0c1swXSk7CisJVk1YKHYsIHBzYml0c1swXSkgPSBWTVgodiwgcHNiaXRzW1JFR0lPTl9OVU1C
RVIodmFkZHIpXSk7CisJbW9sZHJpZCA9IGlhNjRfZ2V0X3JyKDB4MCk7CisJaWE2NF9zZXRfcnIo
MHgwLCB2cnJ0b21ycihwLT5ycikpOworCWlhNjRfc3Jsel9kKCk7CisKKwl2YWRkciA9IFBBR0VB
TElHTih2YWRkciwgcC0+cHMpOworCXRoYXNoX3B1cmdlX2VudHJpZXNfcmVtb3RlKHYsIHZhZGRy
LCBwLT5wcyk7CisKKwlWTVgodiwgdnJyWzBdKSA9IG9sZHJpZDsKKwlWTVgodiwgcHNiaXRzWzBd
KSA9IG9sZHBzYml0czsKKwlpYTY0X3NldF9ycigweDAsIG1vbGRyaWQpOworCWlhNjRfZHZfc2Vy
aWFsaXplX2RhdGEoKTsKK30KKworc3RhdGljIHZvaWQgdmNwdV9kb19yZXN1bWUoc3RydWN0IGt2
bV92Y3B1ICp2Y3B1KQoreworCS8qUmUtaW5pdCBWSFBUIGFuZCBWVExCIG9uY2UgZnJvbSByZXN1
bWUqLworCXZjcHUtPmFyY2gudmhwdC5udW0gPSBWSFBUX05VTV9FTlRSSUVTOworCXRoYXNoX2lu
aXQoJnZjcHUtPmFyY2gudmhwdCwgVkhQVF9TSElGVCk7CisJdmNwdS0+YXJjaC52dGxiLm51bSA9
IFZUTEJfTlVNX0VOVFJJRVM7CisJdGhhc2hfaW5pdCgmdmNwdS0+YXJjaC52dGxiLCBWVExCX1NI
SUZUKTsKKworCWlhNjRfc2V0X3B0YSh2Y3B1LT5hcmNoLnZocHQucHRhLnZhbCk7Cit9CisKK3N0
YXRpYyB2b2lkIGt2bV9kb19yZXN1bWVfb3Aoc3RydWN0IGt2bV92Y3B1ICp2Y3B1KQoreworCWlm
ICh0ZXN0X2FuZF9jbGVhcl9iaXQoS1ZNX1JFUV9SRVNVTUUsICZ2Y3B1LT5yZXF1ZXN0cykpIHsK
KwkJdmNwdV9kb19yZXN1bWUodmNwdSk7CisJCXJldHVybjsKKwl9CisKKwlpZiAodW5saWtlbHko
dGVzdF9hbmRfY2xlYXJfYml0KEtWTV9SRVFfVExCX0ZMVVNILCAmdmNwdS0+cmVxdWVzdHMpKSkg
eworCQl0aGFzaF9wdXJnZV9hbGwodmNwdSk7CisJCXJldHVybjsKKwl9CisKKwlpZiAodGVzdF9h
bmRfY2xlYXJfYml0KEtWTV9SRVFfUFRDX0csICZ2Y3B1LT5yZXF1ZXN0cykpIHsKKwkJd2hpbGUg
KHZjcHUtPmFyY2gucHRjX2dfY291bnQgPiAwKQorCQkJcHRjX2dhX3JlbW90ZV9mdW5jKHZjcHUs
IC0tdmNwdS0+YXJjaC5wdGNfZ19jb3VudCk7CisJfQorfQorCit2b2lkIHZtbV90cmFuc2l0aW9u
KHN0cnVjdCBrdm1fdmNwdSAqdmNwdSkKK3sKKwlpYTY0X2NhbGxfdnNhKFBBTF9WUFNfU0FWRSwg
KHVuc2lnbmVkIGxvbmcpdmNwdS0+YXJjaC52cGQsCisJCQkwLCAwLCAwLCAwLCAwLCAwKTsKKwl2
bW1fdHJhbXBvbGluZSgmdmNwdS0+YXJjaC5ndWVzdCwgJnZjcHUtPmFyY2guaG9zdCk7CisJaWE2
NF9jYWxsX3ZzYShQQUxfVlBTX1JFU1RPUkUsICh1bnNpZ25lZCBsb25nKXZjcHUtPmFyY2gudnBk
LAorCQkJCQkJMCwgMCwgMCwgMCwgMCwgMCk7CisJa3ZtX2RvX3Jlc3VtZV9vcCh2Y3B1KTsKLS0g
CjEuNS4yCgo=

------_=_NextPart_001_01C89146.39BC1893--
