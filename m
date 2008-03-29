From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Sat, 29 Mar 2008 02:48:32 +0000
Subject: [14/17][PATCH] kvm/ia64: Add guest interruption injection support. V7
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDCFF7F6A@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C89147.61382077"
List-Id: <linux-ia64.vger.kernel.org>
References: <42DFA526FC41B1429CE7279EF83C6BDCFF7EF2@pdsmsx415.ccr.corp.intel.com>
In-Reply-To: <42DFA526FC41B1429CE7279EF83C6BDCFF7EF2@pdsmsx415.ccr.corp.intel.com>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C89147.61382077
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
 1 files changed, 982 insertions(+), 0 deletions(-)
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
+}
--=20
1.5.2

------_=_NextPart_001_01C89147.61382077
Content-Type: application/octet-stream;
	name="0014-kvm-ia64-Add-guest-interruption-injection-support.patch"
Content-Transfer-Encoding: base64
Content-Description: 0014-kvm-ia64-Add-guest-interruption-injection-support.patch
Content-Disposition: attachment;
	filename="0014-kvm-ia64-Add-guest-interruption-injection-support.patch"

RnJvbSA4NTFhZDM4MGM3YWFjZTJiMWExNDA5ZTkxNzIyNjYwYjFkZjQzYWExIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQ0KRnJvbTogWGlhbnRhbyBaaGFuZyA8eGlhbnRhby56aGFuZ0BpbnRlbC5j
b20+DQpEYXRlOiBXZWQsIDEyIE1hciAyMDA4IDEzOjUwOjQ5ICswODAwDQpTdWJqZWN0OiBbUEFU
Q0hdIGt2bS9pYTY0OiBBZGQgZ3Vlc3QgaW50ZXJydXB0aW9uIGluamVjdGlvbiBzdXBwb3J0Lg0K
DQpwcm9jZXNzLmMgbWFpbmx5IGhhbmRsZSBpbnRlcnJ1cHRpb24gaW5qZWN0aW9uLCBhbmQgc29t
ZQ0KZmF1bHRzIGhhbmRsaW5nLg0KU2lnbmVkLW9mZi1ieTogQW50aG9ueSBYdSA8YW50aG9ueS54
dUBpbnRlbC5jb20+DQpTaWduZWQtb2ZmLWJ5OiBYaWFudGFvIFpoYW5nIDx4aWFudGFvLnpoYW5n
QGludGVsLmNvbT4NCi0tLQ0KIGFyY2gvaWE2NC9rdm0vcHJvY2Vzcy5jIHwgIDk4MSArKysrKysr
KysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKw0KIDEgZmlsZXMgY2hhbmdl
ZCwgOTgyIGluc2VydGlvbnMoKyksIDAgZGVsZXRpb25zKC0pDQogY3JlYXRlIG1vZGUgMTAwNjQ0
IGFyY2gvaWE2NC9rdm0vcHJvY2Vzcy5jDQoNCmRpZmYgLS1naXQgYS9hcmNoL2lhNjQva3ZtL3By
b2Nlc3MuYyBiL2FyY2gvaWE2NC9rdm0vcHJvY2Vzcy5jDQpuZXcgZmlsZSBtb2RlIDEwMDY0NA0K
aW5kZXggMDAwMDAwMC4uZTRjMzJjNA0KLS0tIC9kZXYvbnVsbA0KKysrIGIvYXJjaC9pYTY0L2t2
bS9wcm9jZXNzLmMNCkBAIC0wLDAgKzEsOTgxIEBADQorLyoNCisgKiBwcm9jZXNzLmM6IGhhbmRs
ZSBpbnRlcnJ1cHRpb24gaW5qZWN0IGZvciBndWVzdHMuDQorICogQ29weXJpZ2h0IChjKSAyMDA1
LCBJbnRlbCBDb3Jwb3JhdGlvbi4NCisgKg0KKyAqIFRoaXMgcHJvZ3JhbSBpcyBmcmVlIHNvZnR3
YXJlOyB5b3UgY2FuIHJlZGlzdHJpYnV0ZSBpdCBhbmQvb3IgbW9kaWZ5IGl0DQorICogdW5kZXIg
dGhlIHRlcm1zIGFuZCBjb25kaXRpb25zIG9mIHRoZSBHTlUgR2VuZXJhbCBQdWJsaWMgTGljZW5z
ZSwNCisgKiB2ZXJzaW9uIDIsIGFzIHB1Ymxpc2hlZCBieSB0aGUgRnJlZSBTb2Z0d2FyZSBGb3Vu
ZGF0aW9uLg0KKyAqDQorICogVGhpcyBwcm9ncmFtIGlzIGRpc3RyaWJ1dGVkIGluIHRoZSBob3Bl
IGl0IHdpbGwgYmUgdXNlZnVsLCBidXQgV0lUSE9VVA0KKyAqIEFOWSBXQVJSQU5UWTsgd2l0aG91
dCBldmVuIHRoZSBpbXBsaWVkIHdhcnJhbnR5IG9mIE1FUkNIQU5UQUJJTElUWSBvcg0KKyAqIEZJ
VE5FU1MgRk9SIEEgUEFSVElDVUxBUiBQVVJQT1NFLiAgU2VlIHRoZSBHTlUgR2VuZXJhbCBQdWJs
aWMgTGljZW5zZSBmb3INCisgKiBtb3JlIGRldGFpbHMuDQorICoNCisgKiBZb3Ugc2hvdWxkIGhh
dmUgcmVjZWl2ZWQgYSBjb3B5IG9mIHRoZSBHTlUgR2VuZXJhbCBQdWJsaWMgTGljZW5zZSBhbG9u
ZyB3aXRoDQorICogdGhpcyBwcm9ncmFtOyBpZiBub3QsIHdyaXRlIHRvIHRoZSBGcmVlIFNvZnR3
YXJlIEZvdW5kYXRpb24sIEluYy4sIDU5IFRlbXBsZQ0KKyAqIFBsYWNlIC0gU3VpdGUgMzMwLCBC
b3N0b24sIE1BIDAyMTExLTEzMDcgVVNBLg0KKyAqDQorICogIAlTaGFvZmFuIExpIChTdXN1ZSBM
aSkgPHN1c2llLmxpQGludGVsLmNvbT4NCisgKiAgCVhpYW95YW4gRmVuZyAoRmxlbWluZyBGZW5n
KSAgPGZsZW1pbmcuZmVuZ0BpbnRlbC5jb20+DQorICogIAlYdWVmZWkgWHUgKEFudGhvbnkgWHUp
IChBbnRob255Lnh1QGludGVsLmNvbSkNCisgKiAgCVhpYW50YW8gWmhhbmcgKHhpYW50YW8uemhh
bmdAaW50ZWwuY29tKQ0KKyAqLw0KKyNpbmNsdWRlICJ2Y3B1LmgiDQorDQorI2luY2x1ZGUgPGFz
bS9wYWwuaD4NCisjaW5jbHVkZSA8YXNtL3NhbC5oPg0KKyNpbmNsdWRlIDxhc20vZnBzd2EuaD4N
CisjaW5jbHVkZSA8YXNtL2tyZWdzLmg+DQorDQorZnBzd2FfaW50ZXJmYWNlX3QgKnZtbV9mcHN3
YV9pbnRlcmZhY2U7DQorDQorI2RlZmluZSBJQTY0X1ZIUFRfVFJBTlNfVkVDVE9SCQkJMHgwMDAw
DQorI2RlZmluZSBJQTY0X0lOU1RfVExCX1ZFQ1RPUgkJCTB4MDQwMA0KKyNkZWZpbmUgSUE2NF9E
QVRBX1RMQl9WRUNUT1IJCQkweDA4MDANCisjZGVmaW5lIElBNjRfQUxUX0lOU1RfVExCX1ZFQ1RP
UgkJMHgwYzAwDQorI2RlZmluZSBJQTY0X0FMVF9EQVRBX1RMQl9WRUNUT1IJCTB4MTAwMA0KKyNk
ZWZpbmUgSUE2NF9EQVRBX05FU1RFRF9UTEJfVkVDVE9SCQkweDE0MDANCisjZGVmaW5lIElBNjRf
SU5TVF9LRVlfTUlTU19WRUNUT1IJCTB4MTgwMA0KKyNkZWZpbmUgSUE2NF9EQVRBX0tFWV9NSVNT
X1ZFQ1RPUgkJMHgxYzAwDQorI2RlZmluZSBJQTY0X0RJUlRZX0JJVF9WRUNUT1IJCQkweDIwMDAN
CisjZGVmaW5lIElBNjRfSU5TVF9BQ0NFU1NfQklUX1ZFQ1RPUgkJMHgyNDAwDQorI2RlZmluZSBJ
QTY0X0RBVEFfQUNDRVNTX0JJVF9WRUNUT1IJCTB4MjgwMA0KKyNkZWZpbmUgSUE2NF9CUkVBS19W
RUNUT1IJCQkweDJjMDANCisjZGVmaW5lIElBNjRfRVhUSU5UX1ZFQ1RPUgkJCTB4MzAwMA0KKyNk
ZWZpbmUgSUE2NF9QQUdFX05PVF9QUkVTRU5UX1ZFQ1RPUgkJMHg1MDAwDQorI2RlZmluZSBJQTY0
X0tFWV9QRVJNSVNTSU9OX1ZFQ1RPUgkJMHg1MTAwDQorI2RlZmluZSBJQTY0X0lOU1RfQUNDRVNT
X1JJR0hUU19WRUNUT1IJCTB4NTIwMA0KKyNkZWZpbmUgSUE2NF9EQVRBX0FDQ0VTU19SSUdIVFNf
VkVDVE9SCQkweDUzMDANCisjZGVmaW5lIElBNjRfR0VORVhfVkVDVE9SCQkJMHg1NDAwDQorI2Rl
ZmluZSBJQTY0X0RJU0FCTEVEX0ZQUkVHX1ZFQ1RPUgkJMHg1NTAwDQorI2RlZmluZSBJQTY0X05B
VF9DT05TVU1QVElPTl9WRUNUT1IJCTB4NTYwMA0KKyNkZWZpbmUgSUE2NF9TUEVDVUxBVElPTl9W
RUNUT1IJCTB4NTcwMCAvKiBVTlVTRUQgKi8NCisjZGVmaW5lIElBNjRfREVCVUdfVkVDVE9SCQkJ
MHg1OTAwDQorI2RlZmluZSBJQTY0X1VOQUxJR05FRF9SRUZfVkVDVE9SCQkweDVhMDANCisjZGVm
aW5lIElBNjRfVU5TVVBQT1JURURfREFUQV9SRUZfVkVDVE9SCTB4NWIwMA0KKyNkZWZpbmUgSUE2
NF9GUF9GQVVMVF9WRUNUT1IJCQkweDVjMDANCisjZGVmaW5lIElBNjRfRlBfVFJBUF9WRUNUT1IJ
CQkweDVkMDANCisjZGVmaW5lIElBNjRfTE9XRVJQUklWX1RSQU5TRkVSX1RSQVBfVkVDVE9SIAkw
eDVlMDANCisjZGVmaW5lIElBNjRfVEFLRU5fQlJBTkNIX1RSQVBfVkVDVE9SCQkweDVmMDANCisj
ZGVmaW5lIElBNjRfU0lOR0xFX1NURVBfVFJBUF9WRUNUT1IJCTB4NjAwMA0KKw0KKy8qIFNETSB2
b2wyIDUuNSAtIElWQSBiYXNlZCBpbnRlcnJ1cHRpb24gaGFuZGxpbmcgKi8NCisjZGVmaW5lIElO
SVRJQUxfUFNSX1ZBTFVFX0FUX0lOVEVSUlVQVElPTiBJQTY0X1BTUl9VUF9CSVR8IElBNjRfUFNS
X01GTF9CSVR8XA0KKwkJCUlBNjRfUFNSX01GSF9CSVR8SUE2NF9QU1JfUEtfQklUfElBNjRfUFNS
X0RUX0JJVHwgICAgXA0KKwkJCUlBNjRfUFNSX1JUX0JJVHxJQTY0X1BTUl9NQ19CSVR8SUE2NF9Q
U1JfSVRfQklUDQorDQorI2RlZmluZSBET01OX1BBTF9SRVFVRVNUICAgIDB4MTEwMDAwDQorI2Rl
ZmluZSBET01OX1NBTF9SRVFVRVNUICAgIDB4MTEwMDAxDQorDQorc3RhdGljIHU2NCB2ZWMyb2Zm
WzY4XSA9IHsweDAsIDB4NDAwLCAweDgwMCwgMHhjMDAsIDB4MTAwMCwgMHgxNDAwLCAweDE4MDAs
DQorCTB4MWMwMCwgMHgyMDAwLCAweDI0MDAsIDB4MjgwMCwgMHgyYzAwLCAweDMwMDAsIDB4MzQw
MCwgMHgzODAwLCAweDNjMDAsDQorCTB4NDAwMCwgMHg0NDAwLCAweDQ4MDAsIDB4NGMwMCwgMHg1
MDAwLCAweDUxMDAsIDB4NTIwMCwgMHg1MzAwLCAweDU0MDAsDQorCTB4NTUwMCwgMHg1NjAwLCAw
eDU3MDAsIDB4NTgwMCwgMHg1OTAwLCAweDVhMDAsIDB4NWIwMCwgMHg1YzAwLCAweDVkMDAsDQor
CTB4NWUwMCwgMHg1ZjAwLCAweDYwMDAsIDB4NjEwMCwgMHg2MjAwLCAweDYzMDAsIDB4NjQwMCwg
MHg2NTAwLCAweDY2MDAsDQorCTB4NjcwMCwgMHg2ODAwLCAweDY5MDAsIDB4NmEwMCwgMHg2YjAw
LCAweDZjMDAsIDB4NmQwMCwgMHg2ZTAwLCAweDZmMDAsDQorCTB4NzAwMCwgMHg3MTAwLCAweDcy
MDAsIDB4NzMwMCwgMHg3NDAwLCAweDc1MDAsIDB4NzYwMCwgMHg3NzAwLCAweDc4MDAsDQorCTB4
NzkwMCwgMHg3YTAwLCAweDdiMDAsIDB4N2MwMCwgMHg3ZDAwLCAweDdlMDAsIDB4N2YwMA0KK307
DQorDQorc3RhdGljIHZvaWQgY29sbGVjdF9pbnRlcnJ1cHRpb24oVkNQVSAqdmNwdSkNCit7DQor
CXU2NCBpcHNyOw0KKwl1NjQgdmRjcjsNCisJdTY0IHZpZnM7DQorCWlhNjRfcHNyIHZwc3I7DQor
CVJFR1MgKnJlZ3MgPSB2Y3B1X3JlZ3ModmNwdSk7DQorDQorCXZwc3IudmFsID0gdmNwdV9nZXRf
cHNyKHZjcHUpOw0KKwl2Y3B1X2JzdzAodmNwdSk7DQorCWlmICh2cHNyLmljKSB7DQorDQorCQkv
KiBTeW5jIG1wc3IgaWQvZGEvZGQvc3MvZWQgYml0cyB0byB2aXBzcg0KKwkJICogc2luY2UgYWZ0
ZXIgZ3Vlc3QgZG8gcmZpLCB3ZSBzdGlsbCB3YW50IHRoZXNlIGJpdHMgb24gaW4NCisJCSAqIG1w
c3INCisJCSAqLw0KKw0KKwkJaXBzciA9IHJlZ3MtPmNyX2lwc3I7DQorCQl2cHNyLnZhbCA9IHZw
c3IudmFsIHwgKGlwc3IgJiAoSUE2NF9QU1JfSUQgfCBJQTY0X1BTUl9EQQ0KKwkJCQkJfCBJQTY0
X1BTUl9ERCB8IElBNjRfUFNSX1NTDQorCQkJCQl8IElBNjRfUFNSX0VEKSk7DQorCQl2Y3B1X3Nl
dF9pcHNyKHZjcHUsIHZwc3IudmFsKTsNCisNCisJCS8qIEN1cnJlbnRseSwgZm9yIHRyYXAsIHdl
IGRvIG5vdCBhZHZhbmNlIElJUCB0byBuZXh0DQorCQkgKiBpbnN0cnVjdGlvbi4gVGhhdCdzIGJl
Y2F1c2Ugd2UgYXNzdW1lIGNhbGxlciBhbHJlYWR5DQorCQkgKiBzZXQgdXAgSUlQIGNvcnJlY3Rs
eQ0KKwkJICovDQorDQorCQl2Y3B1X3NldF9paXAodmNwdSAsIHJlZ3MtPmNyX2lpcCk7DQorDQor
CQkvKiBzZXQgdmlmcy52IHRvIHplcm8gKi8NCisJCXZpZnMgPSBWQ1BVKHZjcHUsIGlmcyk7DQor
CQl2aWZzICY9IH5JQTY0X0lGU19WOw0KKwkJdmNwdV9zZXRfaWZzKHZjcHUsIHZpZnMpOw0KKw0K
KwkJdmNwdV9zZXRfaWlwYSh2Y3B1LCBWTVgodmNwdSwgY3JfaWlwYSkpOw0KKwl9DQorDQorCXZk
Y3IgPSBWQ1BVKHZjcHUsIGRjcik7DQorDQorCS8qIFNldCBndWVzdCBwc3INCisJICogdXAvbWZs
L21maC9way9kdC9ydC9tYy9pdCBrZWVwcyB1bmNoYW5nZWQNCisJICogYmU6IHNldCB0byB0aGUg
dmFsdWUgb2YgZGNyLmJlDQorCSAqIHBwOiBzZXQgdG8gdGhlIHZhbHVlIG9mIGRjci5wcA0KKwkg
Ki8NCisJdnBzci52YWwgJj0gSU5JVElBTF9QU1JfVkFMVUVfQVRfSU5URVJSVVBUSU9OOw0KKwl2
cHNyLnZhbCB8PSAodmRjciAmIElBNjRfRENSX0JFKTsNCisNCisJLyogVkRDUiBwcCBiaXQgcG9z
aXRpb24gaXMgZGlmZmVyZW50IGZyb20gVlBTUiBwcCBiaXQgKi8NCisJaWYgKHZkY3IgJiBJQTY0
X0RDUl9QUCkgew0KKwkJdnBzci52YWwgfD0gSUE2NF9QU1JfUFA7DQorCX0gZWxzZSB7DQorCQl2
cHNyLnZhbCAmPSB+SUE2NF9QU1JfUFA7Ow0KKwl9DQorDQorCXZjcHVfc2V0X3Bzcih2Y3B1LCB2
cHNyLnZhbCk7DQorDQorfQ0KKw0KK3ZvaWQgaW5qZWN0X2d1ZXN0X2ludGVycnVwdGlvbihWQ1BV
ICp2Y3B1LCB1NjQgdmVjKQ0KK3sNCisJdTY0IHZpdmE7DQorCVJFR1MgKnJlZ3M7DQorCWlhNjRf
aXNyIHB0X2lzcjsNCisNCisJcmVncyA9IHZjcHVfcmVncyh2Y3B1KTsNCisNCisJLyogY2xlYXIg
Y3IuaXNyLmlyIChpbmNvbXBsZXRlIHJlZ2lzdGVyIGZyYW1lKSovDQorCXB0X2lzci52YWwgPSBW
TVgodmNwdSwgY3JfaXNyKTsNCisJcHRfaXNyLmlyID0gMDsNCisJVk1YKHZjcHUsIGNyX2lzcikg
PSBwdF9pc3IudmFsOw0KKw0KKwljb2xsZWN0X2ludGVycnVwdGlvbih2Y3B1KTsNCisNCisJdml2
YSA9IHZjcHVfZ2V0X2l2YSh2Y3B1KTsNCisJcmVncy0+Y3JfaWlwID0gdml2YSArIHZlYzsNCit9
DQorDQorc3RhdGljIHU2NCB2Y3B1X2dldF9pdGlyX29uX2ZhdWx0KFZDUFUgKnZjcHUsIHU2NCBp
ZmEpDQorew0KKwlpYTY0X3JyIHJyLCBycjE7DQorDQorCXJyLnZhbCA9IHZjcHVfZ2V0X3JyKHZj
cHUsIGlmYSk7DQorCXJyMS52YWwgPSAwOw0KKwlycjEucHMgPSByci5wczsNCisJcnIxLnJpZCA9
IHJyLnJpZDsNCisJcmV0dXJuIChycjEudmFsKTsNCit9DQorDQorDQorLyoNCisgKiBTZXQgdklG
QSAmIHZJVElSICYgdklIQSwgd2hlbiB2UFNSLmljID0xDQorICogUGFyYW1ldGVyOg0KKyAqICBz
ZXRfaWZhOiBpZiB0cnVlLCBzZXQgdklGQQ0KKyAqICBzZXRfaXRpcjogaWYgdHJ1ZSwgc2V0IHZJ
VElSDQorICogIHNldF9paGE6IGlmIHRydWUsIHNldCB2SUhBDQorICovDQordm9pZCBzZXRfaWZh
X2l0aXJfaWhhKFZDUFUgKnZjcHUsIHU2NCB2YWRyLA0KKwkJaW50IHNldF9pZmEsIGludCBzZXRf
aXRpciwgaW50IHNldF9paGEpDQorew0KKwlpYTY0X3BzciB2cHNyOw0KKwl1NjQgdmFsdWU7DQor
DQorCXZwc3IudmFsID0gVkNQVSh2Y3B1LCB2cHNyKTsNCisJLyogVm9sMiwgVGFibGUgOC0xICov
DQorCWlmICh2cHNyLmljKSB7DQorCQlpZiAoc2V0X2lmYSkgew0KKwkJCXZjcHVfc2V0X2lmYSh2
Y3B1LCB2YWRyKTsNCisJCX0NCisJCWlmIChzZXRfaXRpcikgew0KKwkJCXZhbHVlID0gdmNwdV9n
ZXRfaXRpcl9vbl9mYXVsdCh2Y3B1LCB2YWRyKTsNCisJCQl2Y3B1X3NldF9pdGlyKHZjcHUsIHZh
bHVlKTsNCisJCX0NCisNCisJCWlmIChzZXRfaWhhKSB7DQorCQkJdmFsdWUgPSB2Y3B1X3RoYXNo
KHZjcHUsIHZhZHIpOw0KKwkJCXZjcHVfc2V0X2loYSh2Y3B1LCB2YWx1ZSk7DQorCQl9DQorCX0N
Cit9DQorDQorLyoNCisgKiBEYXRhIFRMQiBGYXVsdA0KKyAqICBAIERhdGEgVExCIHZlY3Rvcg0K
KyAqIFJlZmVyIHRvIFNETSBWb2wyIFRhYmxlIDUtNiAmIDgtMQ0KKyAqLw0KK3ZvaWQgZHRsYl9m
YXVsdChWQ1BVICp2Y3B1LCB1NjQgdmFkcikNCit7DQorCS8qIElmIHZQU1IuaWMsIElGQSwgSVRJ
UiwgSUhBICovDQorCXNldF9pZmFfaXRpcl9paGEodmNwdSwgdmFkciwgMSwgMSwgMSk7DQorCWlu
amVjdF9ndWVzdF9pbnRlcnJ1cHRpb24odmNwdSwgSUE2NF9EQVRBX1RMQl9WRUNUT1IpOw0KK30N
CisNCisvKg0KKyAqIEluc3RydWN0aW9uIFRMQiBGYXVsdA0KKyAqICBAIEluc3RydWN0aW9uIFRM
QiB2ZWN0b3INCisgKiBSZWZlciB0byBTRE0gVm9sMiBUYWJsZSA1LTYgJiA4LTENCisgKi8NCit2
b2lkIGl0bGJfZmF1bHQgKFZDUFUgKnZjcHUsIHU2NCB2YWRyKQ0KK3sNCisJLyogSWYgdlBTUi5p
YywgSUZBLCBJVElSLCBJSEEgKi8NCisJc2V0X2lmYV9pdGlyX2loYSh2Y3B1LCB2YWRyLCAxLCAx
LCAxKTsNCisJaW5qZWN0X2d1ZXN0X2ludGVycnVwdGlvbih2Y3B1LCBJQTY0X0lOU1RfVExCX1ZF
Q1RPUik7DQorfQ0KKw0KKw0KKw0KKy8qDQorICogRGF0YSBOZXN0ZWQgVExCIEZhdWx0DQorICog
IEAgRGF0YSBOZXN0ZWQgVExCIFZlY3Rvcg0KKyAqIFJlZmVyIHRvIFNETSBWb2wyIFRhYmxlIDUt
NiAmIDgtMQ0KKyAqLw0KK3ZvaWQgbmVzdGVkX2R0bGIoVkNQVSAqdmNwdSkNCit7DQorCWluamVj
dF9ndWVzdF9pbnRlcnJ1cHRpb24odmNwdSwgSUE2NF9EQVRBX05FU1RFRF9UTEJfVkVDVE9SKTsN
Cit9DQorDQorLyoNCisgKiBBbHRlcm5hdGUgRGF0YSBUTEIgRmF1bHQNCisgKiAgQCBBbHRlcm5h
dGUgRGF0YSBUTEIgdmVjdG9yDQorICogUmVmZXIgdG8gU0RNIFZvbDIgVGFibGUgNS02ICYgOC0x
DQorICovDQordm9pZCBhbHRfZHRsYihWQ1BVICp2Y3B1LCB1NjQgdmFkcikNCit7DQorCXNldF9p
ZmFfaXRpcl9paGEodmNwdSwgdmFkciwgMSwgMSwgMCk7DQorCWluamVjdF9ndWVzdF9pbnRlcnJ1
cHRpb24odmNwdSwgSUE2NF9BTFRfREFUQV9UTEJfVkVDVE9SKTsNCit9DQorDQorDQorLyoNCisg
KiBEYXRhIFRMQiBGYXVsdA0KKyAqICBAIERhdGEgVExCIHZlY3Rvcg0KKyAqIFJlZmVyIHRvIFNE
TSBWb2wyIFRhYmxlIDUtNiAmIDgtMQ0KKyAqLw0KK3ZvaWQgYWx0X2l0bGIoVkNQVSAqdmNwdSwg
dTY0IHZhZHIpDQorew0KKwlzZXRfaWZhX2l0aXJfaWhhKHZjcHUsIHZhZHIsIDEsIDEsIDApOw0K
KwlpbmplY3RfZ3Vlc3RfaW50ZXJydXB0aW9uKHZjcHUsIElBNjRfQUxUX0lOU1RfVExCX1ZFQ1RP
Uik7DQorfQ0KKw0KKy8qIERlYWwgd2l0aDoNCisgKiAgVkhQVCBUcmFuc2xhdGlvbiBWZWN0b3IN
CisgKi8NCitzdGF0aWMgdm9pZCBfdmhwdF9mYXVsdChWQ1BVICp2Y3B1LCB1NjQgdmFkcikNCit7
DQorCS8qIElmIHZQU1IuaWMsIElGQSwgSVRJUiwgSUhBKi8NCisJc2V0X2lmYV9pdGlyX2loYSh2
Y3B1LCB2YWRyLCAxLCAxLCAxKTsNCisJaW5qZWN0X2d1ZXN0X2ludGVycnVwdGlvbih2Y3B1LCBJ
QTY0X1ZIUFRfVFJBTlNfVkVDVE9SKTsNCisNCisNCit9DQorDQorLyoNCisgKiBWSFBUIEluc3Ry
dWN0aW9uIEZhdWx0DQorICogIEAgVkhQVCBUcmFuc2xhdGlvbiB2ZWN0b3INCisgKiBSZWZlciB0
byBTRE0gVm9sMiBUYWJsZSA1LTYgJiA4LTENCisgKi8NCit2b2lkIGl2aHB0X2ZhdWx0KFZDUFUg
KnZjcHUsIHU2NCB2YWRyKQ0KK3sNCisJX3ZocHRfZmF1bHQodmNwdSwgdmFkcik7DQorfQ0KKw0K
Kw0KKy8qDQorICogVkhQVCBEYXRhIEZhdWx0DQorICogIEAgVkhQVCBUcmFuc2xhdGlvbiB2ZWN0
b3INCisgKiBSZWZlciB0byBTRE0gVm9sMiBUYWJsZSA1LTYgJiA4LTENCisgKi8NCit2b2lkIGR2
aHB0X2ZhdWx0KFZDUFUgKnZjcHUsIHU2NCB2YWRyKQ0KK3sNCisJX3ZocHRfZmF1bHQodmNwdSwg
dmFkcik7DQorfQ0KKw0KKw0KKw0KKy8qDQorICogRGVhbCB3aXRoOg0KKyAqICBHZW5lcmFsIEV4
Y2VwdGlvbiB2ZWN0b3INCisgKi8NCit2b2lkIF9nZW5lcmFsX2V4Y2VwdGlvbihWQ1BVICp2Y3B1
KQ0KK3sNCisJaW5qZWN0X2d1ZXN0X2ludGVycnVwdGlvbih2Y3B1LCBJQTY0X0dFTkVYX1ZFQ1RP
Uik7DQorfQ0KKw0KKw0KKy8qDQorICogSWxsZWdhbCBPcGVyYXRpb24gRmF1bHQNCisgKiAgQCBH
ZW5lcmFsIEV4Y2VwdGlvbiBWZWN0b3INCisgKiBSZWZlciB0byBTRE0gVm9sMiBUYWJsZSA1LTYg
JiA4LTENCisgKi8NCit2b2lkIGlsbGVnYWxfb3AoVkNQVSAqdmNwdSkNCit7DQorCV9nZW5lcmFs
X2V4Y2VwdGlvbih2Y3B1KTsNCit9DQorDQorLyoNCisgKiBJbGxlZ2FsIERlcGVuZGVuY3kgRmF1
bHQNCisgKiAgQCBHZW5lcmFsIEV4Y2VwdGlvbiBWZWN0b3INCisgKiBSZWZlciB0byBTRE0gVm9s
MiBUYWJsZSA1LTYgJiA4LTENCisgKi8NCit2b2lkIGlsbGVnYWxfZGVwKFZDUFUgKnZjcHUpDQor
ew0KKwlfZ2VuZXJhbF9leGNlcHRpb24odmNwdSk7DQorfQ0KKw0KKy8qDQorICogUmVzZXJ2ZWQg
UmVnaXN0ZXIvRmllbGQgRmF1bHQNCisgKiAgQCBHZW5lcmFsIEV4Y2VwdGlvbiBWZWN0b3INCisg
KiBSZWZlciB0byBTRE0gVm9sMiBUYWJsZSA1LTYgJiA4LTENCisgKi8NCit2b2lkIHJzdl9yZWdf
ZmllbGQoVkNQVSAqdmNwdSkNCit7DQorCV9nZW5lcmFsX2V4Y2VwdGlvbih2Y3B1KTsNCit9DQor
LyoNCisgKiBQcml2aWxlZ2VkIE9wZXJhdGlvbiBGYXVsdA0KKyAqICBAIEdlbmVyYWwgRXhjZXB0
aW9uIFZlY3Rvcg0KKyAqIFJlZmVyIHRvIFNETSBWb2wyIFRhYmxlIDUtNiAmIDgtMQ0KKyAqLw0K
Kw0KK3ZvaWQgcHJpdmlsZWdlX29wKFZDUFUgKnZjcHUpDQorew0KKwlfZ2VuZXJhbF9leGNlcHRp
b24odmNwdSk7DQorfQ0KKw0KKy8qDQorICogVW5pbXBsZW1lbnQgRGF0YSBBZGRyZXNzIEZhdWx0
DQorICogIEAgR2VuZXJhbCBFeGNlcHRpb24gVmVjdG9yDQorICogUmVmZXIgdG8gU0RNIFZvbDIg
VGFibGUgNS02ICYgOC0xDQorICovDQordm9pZCB1bmltcGxfZGFkZHIoVkNQVSAqdmNwdSkNCit7
DQorCV9nZW5lcmFsX2V4Y2VwdGlvbih2Y3B1KTsNCit9DQorDQorLyoNCisgKiBQcml2aWxlZ2Vk
IFJlZ2lzdGVyIEZhdWx0DQorICogIEAgR2VuZXJhbCBFeGNlcHRpb24gVmVjdG9yDQorICogUmVm
ZXIgdG8gU0RNIFZvbDIgVGFibGUgNS02ICYgOC0xDQorICovDQordm9pZCBwcml2aWxlZ2VfcmVn
KFZDUFUgKnZjcHUpDQorew0KKwlfZ2VuZXJhbF9leGNlcHRpb24odmNwdSk7DQorfQ0KKw0KKy8q
IERlYWwgd2l0aA0KKyAqICBOYXQgY29uc3VtcHRpb24gdmVjdG9yDQorICogUGFyYW1ldGVyOg0K
KyAqICB2YWRkcjogT3B0aW9uYWwsIGlmIHQgPT0gUkVHSVNURVINCisgKi8NCitzdGF0aWMgdm9p
ZCBfbmF0X2NvbnN1bXB0aW9uX2ZhdWx0KFZDUFUgKnZjcHUsIHU2NCB2YWRyLCBtaXNzX3R5cGUg
dCkNCit7DQorCS8qIElmIHZQU1IuaWMgJiYgdCA9PSBEQVRBL0lOU1QsIElGQSAqLw0KKwlpZiAo
dCA9PSBEQVRBIHx8IHQgPT0gSU5TVFJVQ1RJT04pIHsNCisJCS8qIElGQSAqLw0KKwkJc2V0X2lm
YV9pdGlyX2loYSh2Y3B1LCB2YWRyLCAxLCAwLCAwKTsNCisJfQ0KKw0KKwlpbmplY3RfZ3Vlc3Rf
aW50ZXJydXB0aW9uKHZjcHUsIElBNjRfTkFUX0NPTlNVTVBUSU9OX1ZFQ1RPUik7DQorfQ0KKw0K
Ky8qDQorICogSVIgRGF0YSBOYXQgUGFnZSBDb25zdW1wdGlvbiBGYXVsdA0KKyAqICBAIE5hdCBD
b25zdW1wdGlvbiBWZWN0b3INCisgKiBSZWZlciB0byBTRE0gVm9sMiBUYWJsZSA1LTYgJiA4LTEN
CisgKi8NCisjaWYgMA0KKwlzdGF0aWMgdm9pZA0KK2lyX25hdF9wYWdlX2NvbnN1bXB0aW9uKFZD
UFUgKnZjcHUsIHU2NCB2YWRyKQ0KK3sNCisJX25hdF9jb25zdW1wdGlvbl9mYXVsdCh2Y3B1LCB2
YWRyLCBEQVRBKTsNCit9DQorI2VuZGlmIC8qc2hhZG93IGl0IGR1ZSB0byBubyB1c2UgY3VycmVu
dGx5Ki8NCisNCisvKg0KKyAqIEluc3RydWN0aW9uIE5hdCBQYWdlIENvbnN1bXB0aW9uIEZhdWx0
DQorICogIEAgTmF0IENvbnN1bXB0aW9uIFZlY3Rvcg0KKyAqIFJlZmVyIHRvIFNETSBWb2wyIFRh
YmxlIDUtNiAmIDgtMQ0KKyAqLw0KK3ZvaWQgaW5hdF9wYWdlX2NvbnN1bXB0aW9uKFZDUFUgKnZj
cHUsIHU2NCB2YWRyKQ0KK3sNCisJX25hdF9jb25zdW1wdGlvbl9mYXVsdCh2Y3B1LCB2YWRyLCBJ
TlNUUlVDVElPTik7DQorfQ0KKw0KKy8qDQorICogUmVnaXN0ZXIgTmF0IENvbnN1bXB0aW9uIEZh
dWx0DQorICogIEAgTmF0IENvbnN1bXB0aW9uIFZlY3Rvcg0KKyAqIFJlZmVyIHRvIFNETSBWb2wy
IFRhYmxlIDUtNiAmIDgtMQ0KKyAqLw0KK3ZvaWQgcm5hdF9jb25zdW1wdGlvbihWQ1BVICp2Y3B1
KQ0KK3sNCisJX25hdF9jb25zdW1wdGlvbl9mYXVsdCh2Y3B1LCAwLCBSRUdJU1RFUik7DQorfQ0K
Kw0KKy8qDQorICogRGF0YSBOYXQgUGFnZSBDb25zdW1wdGlvbiBGYXVsdA0KKyAqICBAIE5hdCBD
b25zdW1wdGlvbiBWZWN0b3INCisgKiBSZWZlciB0byBTRE0gVm9sMiBUYWJsZSA1LTYgJiA4LTEN
CisgKi8NCit2b2lkIGRuYXRfcGFnZV9jb25zdW1wdGlvbihWQ1BVICp2Y3B1LCB1NjQgdmFkcikN
Cit7DQorCV9uYXRfY29uc3VtcHRpb25fZmF1bHQodmNwdSwgdmFkciwgREFUQSk7DQorfQ0KKw0K
Ky8qIERlYWwgd2l0aA0KKyAqICBQYWdlIG5vdCBwcmVzZW50IHZlY3Rvcg0KKyAqLw0KK3N0YXRp
YyB2b2lkIF9fcGFnZV9ub3RfcHJlc2VudChWQ1BVICp2Y3B1LCB1NjQgdmFkcikNCit7DQorCS8q
IElmIHZQU1IuaWMsIElGQSwgSVRJUiAqLw0KKwlzZXRfaWZhX2l0aXJfaWhhKHZjcHUsIHZhZHIs
IDEsIDEsIDApOw0KKwlpbmplY3RfZ3Vlc3RfaW50ZXJydXB0aW9uKHZjcHUsIElBNjRfUEFHRV9O
T1RfUFJFU0VOVF9WRUNUT1IpOw0KK30NCisNCisNCit2b2lkIGRhdGFfcGFnZV9ub3RfcHJlc2Vu
dChWQ1BVICp2Y3B1LCB1NjQgdmFkcikNCit7DQorCV9fcGFnZV9ub3RfcHJlc2VudCh2Y3B1LCB2
YWRyKTsNCit9DQorDQorDQordm9pZCBpbnN0X3BhZ2Vfbm90X3ByZXNlbnQoVkNQVSAqdmNwdSwg
dTY0IHZhZHIpDQorew0KKwlfX3BhZ2Vfbm90X3ByZXNlbnQodmNwdSwgdmFkcik7DQorfQ0KKw0K
Kw0KKy8qIERlYWwgd2l0aA0KKyAqICBEYXRhIGFjY2VzcyByaWdodHMgdmVjdG9yDQorICovDQor
dm9pZCBkYXRhX2FjY2Vzc19yaWdodHMoVkNQVSAqdmNwdSwgdTY0IHZhZHIpDQorew0KKwkvKiBJ
ZiB2UFNSLmljLCBJRkEsIElUSVIgKi8NCisJc2V0X2lmYV9pdGlyX2loYSh2Y3B1LCB2YWRyLCAx
LCAxLCAwKTsNCisJaW5qZWN0X2d1ZXN0X2ludGVycnVwdGlvbih2Y3B1LCBJQTY0X0RBVEFfQUND
RVNTX1JJR0hUU19WRUNUT1IpOw0KK30NCisNCitmcHN3YV9yZXRfdCB2bW1fZnBfZW11bGF0ZShp
bnQgZnBfZmF1bHQsIHZvaWQgKmJ1bmRsZSwgdW5zaWduZWQgbG9uZyAqaXBzciwNCisJCXVuc2ln
bmVkIGxvbmcgKmZwc3IsIHVuc2lnbmVkIGxvbmcgKmlzciwgdW5zaWduZWQgbG9uZyAqcHIsDQor
CQl1bnNpZ25lZCBsb25nICppZnMsIFJFR1MgKnJlZ3MpDQorew0KKwlmcF9zdGF0ZV90IGZwX3N0
YXRlOw0KKwlmcHN3YV9yZXRfdCByZXQ7DQorCXN0cnVjdCBrdm1fdmNwdSAqdmNwdSA9IGN1cnJl
bnRfdmNwdTsNCisNCisJdWludDY0X3Qgb2xkX3JyNyA9IGlhNjRfZ2V0X3JyKDdVTDw8NjEpOw0K
Kw0KKwlpZiAoIXZtbV9mcHN3YV9pbnRlcmZhY2UpDQorCQlyZXR1cm4gKGZwc3dhX3JldF90KSB7
LTEsIDAsIDAsIDB9Ow0KKw0KKwkvKg0KKwkgKiBKdXN0IGxldCBmcHN3YSBkcml2ZXIgdG8gdXNl
IGhhcmR3YXJlIGZwIHJlZ2lzdGVycy4NCisJICogTm8gZnAgcmVnaXN0ZXIgaXMgdmFsaWQgaW4g
bWVtb3J5Lg0KKwkgKi8NCisJbWVtc2V0KCZmcF9zdGF0ZSwgMCwgc2l6ZW9mKGZwX3N0YXRlX3Qp
KTsNCisNCisJLyoNCisJICogdW5zaWduZWQgbG9uZyAoKkVGSV9GUFNXQSkgKA0KKwkgKiAgICAg
IHVuc2lnbmVkIGxvbmcgICAgdHJhcF90eXBlLA0KKwkgKiAgICAgIHZvaWQgICAgICAgICAgICAg
KkJ1bmRsZSwNCisJICogICAgICB1bnNpZ25lZCBsb25nICAgICpwaXBzciwNCisJICogICAgICB1
bnNpZ25lZCBsb25nICAgICpwZnNyLA0KKwkgKiAgICAgIHVuc2lnbmVkIGxvbmcgICAgKnBpc3Is
DQorCSAqICAgICAgdW5zaWduZWQgbG9uZyAgICAqcHByZWRzLA0KKwkgKiAgICAgIHVuc2lnbmVk
IGxvbmcgICAgKnBpZnMsDQorCSAqICAgICAgdm9pZCAgICAgICAgICAgICAqZnBfc3RhdGUpOw0K
KwkgKi8NCisJLypDYWxsIGhvc3QgZnBzd2EgaW50ZXJmYWNlIGRpcmVjdGx5IHRvIHZpcnR1YWxp
emUNCisJICpndWVzdCBmcHN3YSByZXF1ZXN0IQ0KKwkgKi8NCisJaWE2NF9zZXRfcnIoN1VMIDw8
IDYxLCB2Y3B1LT5hcmNoLmhvc3QucnJbN10pOw0KKwlpYTY0X3NybHpfZCgpOw0KKw0KKwlyZXQg
PSAoKnZtbV9mcHN3YV9pbnRlcmZhY2UtPmZwc3dhKSAoZnBfZmF1bHQsIGJ1bmRsZSwNCisJCQlp
cHNyLCBmcHNyLCBpc3IsIHByLCBpZnMsICZmcF9zdGF0ZSk7DQorCWlhNjRfc2V0X3JyKDdVTCA8
PCA2MSwgb2xkX3JyNyk7DQorCWlhNjRfc3Jsel9kKCk7DQorCXJldHVybiByZXQ7DQorfQ0KKw0K
Ky8qDQorICogSGFuZGxlIGZsb2F0aW5nLXBvaW50IGFzc2lzdCBmYXVsdHMgYW5kIHRyYXBzIGZv
ciBkb21haW4uDQorICovDQordW5zaWduZWQgbG9uZyB2bW1faGFuZGxlX2ZwdV9zd2EoaW50IGZw
X2ZhdWx0LCBSRUdTICpyZWdzLCB1bnNpZ25lZCBsb25nIGlzcikNCit7DQorCXN0cnVjdCBrdm1f
dmNwdSAqdiA9IGN1cnJlbnRfdmNwdTsNCisJSUE2NF9CVU5ETEUgYnVuZGxlOw0KKwl1bnNpZ25l
ZCBsb25nIGZhdWx0X2lwOw0KKwlmcHN3YV9yZXRfdCByZXQ7DQorDQorCWZhdWx0X2lwID0gcmVn
cy0+Y3JfaWlwOw0KKwkvKg0KKwkgKiBXaGVuIHRoZSBGUCB0cmFwIG9jY3VycywgdGhlIHRyYXBw
aW5nIGluc3RydWN0aW9uIGlzIGNvbXBsZXRlZC4NCisJICogSWYgaXBzci5yaSA9PSAwLCB0aGVy
ZSBpcyB0aGUgdHJhcHBpbmcgaW5zdHJ1Y3Rpb24gaW4gcHJldmlvdXMNCisJICogYnVuZGxlLg0K
KwkgKi8NCisJaWYgKCFmcF9mYXVsdCAmJiAoaWE2NF9wc3IocmVncyktPnJpID09IDApKQ0KKwkJ
ZmF1bHRfaXAgLT0gMTY7DQorDQorCWlmIChmZXRjaF9jb2RlKHYsIGZhdWx0X2lwLCAmYnVuZGxl
KSkNCisJCXJldHVybiAtRUFHQUlOOw0KKw0KKwlpZiAoIWJ1bmRsZS5pNjRbMF0gJiYgIWJ1bmRs
ZS5pNjRbMV0pIHsNCisJCXJldHVybiAtRUFDQ0VTOw0KKwl9DQorDQorCXJldCA9IHZtbV9mcF9l
bXVsYXRlKGZwX2ZhdWx0LCAmYnVuZGxlLCAmcmVncy0+Y3JfaXBzciwgJnJlZ3MtPmFyX2Zwc3Is
DQorCQkJJmlzciwgJnJlZ3MtPnByLCAmcmVncy0+Y3JfaWZzLCByZWdzKTsNCisJcmV0dXJuIHJl
dC5zdGF0dXM7DQorfQ0KKw0KK3ZvaWQgcmVmbGVjdF9pbnRlcnJ1cHRpb24odTY0IGlmYSwgdTY0
IGlzciwgdTY0IGlpbSwNCisJCXU2NCB2ZWMsIFJFR1MgKnJlZ3MpDQorew0KKwl1NjQgdmVjdG9y
Ow0KKwlpbnQgc3RhdHVzIDsNCisJVkNQVSAqdmNwdSA9IGN1cnJlbnRfdmNwdTsNCisJdTY0IHZw
c3IgPSBWQ1BVKHZjcHUsIHZwc3IpOw0KKw0KKwl2ZWN0b3IgPSB2ZWMyb2ZmW3ZlY107DQorDQor
CWlmICghKHZwc3IgJiBJQTY0X1BTUl9JQykgJiYgKHZlY3RvciAhPSBJQTY0X0RBVEFfTkVTVEVE
X1RMQl9WRUNUT1IpKSB7DQorCQlwYW5pY192bSh2Y3B1KTsNCisJCXJldHVybjsNCisJfQ0KKw0K
Kwlzd2l0Y2ggKHZlYykgew0KKwljYXNlIDMyOiAJLypJQTY0X0ZQX0ZBVUxUX1ZFQ1RPUiovDQor
CQlzdGF0dXMgPSB2bW1faGFuZGxlX2ZwdV9zd2EoMSwgcmVncywgaXNyKTsNCisJCWlmICghc3Rh
dHVzKSB7DQorCQkJdmNwdV9pbmNyZW1lbnRfaWlwKHZjcHUpOw0KKwkJCXJldHVybjsNCisJCX0g
ZWxzZSBpZiAoLUVBR0FJTiA9PSBzdGF0dXMpDQorCQkJcmV0dXJuOw0KKwkJYnJlYWs7DQorCWNh
c2UgMzM6CS8qSUE2NF9GUF9UUkFQX1ZFQ1RPUiovDQorCQlzdGF0dXMgPSB2bW1faGFuZGxlX2Zw
dV9zd2EoMCwgcmVncywgaXNyKTsNCisJCWlmICghc3RhdHVzKQ0KKwkJCXJldHVybiA7DQorCQll
bHNlIGlmICgtRUFHQUlOID09IHN0YXR1cykgew0KKwkJCXZjcHVfZGVjcmVtZW50X2lpcCh2Y3B1
KTsNCisJCQlyZXR1cm4gOw0KKwkJfQ0KKwkJYnJlYWs7DQorCX0NCisNCisJVkNQVSh2Y3B1LCBp
c3IpID0gaXNyOw0KKwlWQ1BVKHZjcHUsIGlpcGEpID0gcmVncy0+Y3JfaWlwOw0KKwlpZiAodmVj
dG9yID09IElBNjRfQlJFQUtfVkVDVE9SIHx8IHZlY3RvciA9PSBJQTY0X1NQRUNVTEFUSU9OX1ZF
Q1RPUikNCisJCVZDUFUodmNwdSwgaWltKSA9IGlpbTsNCisJZWxzZSB7DQorCQlzZXRfaWZhX2l0
aXJfaWhhKHZjcHUsIGlmYSwgMSwgMSwgMSk7DQorCX0NCisJaW5qZWN0X2d1ZXN0X2ludGVycnVw
dGlvbih2Y3B1LCB2ZWN0b3IpOw0KK30NCisNCitzdGF0aWMgdm9pZCBzZXRfcGFsX2NhbGxfZGF0
YShWQ1BVICp2Y3B1KQ0KK3sNCisJc3RydWN0IGV4aXRfY3RsX2RhdGEgKnAgPSAmdmNwdS0+YXJj
aC5leGl0X2RhdGE7DQorDQorCS8qRklYTUU6Rm9yIHN0YXRpYyBhbmQgc3RhY2tlZCBjb252ZW50
aW9uLCBmaXJtd2FyZQ0KKwkgKiBoYXMgcHV0IHRoZSBwYXJhbWV0ZXJzIGluIGdyMjgtZ3IzMSBi
ZWZvcmUNCisJICogYnJlYWsgdG8gdm1tICAhISovDQorDQorCXAtPnUucGFsX2RhdGEuZ3IyOCA9
IHZjcHVfZ2V0X2dyKHZjcHUsIDI4KTsNCisJcC0+dS5wYWxfZGF0YS5ncjI5ID0gdmNwdV9nZXRf
Z3IodmNwdSwgMjkpOw0KKwlwLT51LnBhbF9kYXRhLmdyMzAgPSB2Y3B1X2dldF9ncih2Y3B1LCAz
MCk7DQorCXAtPnUucGFsX2RhdGEuZ3IzMSA9IHZjcHVfZ2V0X2dyKHZjcHUsIDMxKTsNCisJcC0+
ZXhpdF9yZWFzb24gPSBFWElUX1JFQVNPTl9QQUxfQ0FMTDsNCit9DQorDQorc3RhdGljIHZvaWQg
c2V0X3BhbF9jYWxsX3Jlc3VsdChWQ1BVICp2Y3B1KQ0KK3sNCisJc3RydWN0IGV4aXRfY3RsX2Rh
dGEgKnAgPSAmdmNwdS0+YXJjaC5leGl0X2RhdGE7DQorDQorCWlmIChwLT5leGl0X3JlYXNvbiA9
PSBFWElUX1JFQVNPTl9QQUxfQ0FMTCkgew0KKwkJdmNwdV9zZXRfZ3IodmNwdSwgOCwgcC0+dS5w
YWxfZGF0YS5yZXQuc3RhdHVzLCAwKTsNCisJCXZjcHVfc2V0X2dyKHZjcHUsIDksIHAtPnUucGFs
X2RhdGEucmV0LnYwLCAwKTsNCisJCXZjcHVfc2V0X2dyKHZjcHUsIDEwLCBwLT51LnBhbF9kYXRh
LnJldC52MSwgMCk7DQorCQl2Y3B1X3NldF9ncih2Y3B1LCAxMSwgcC0+dS5wYWxfZGF0YS5yZXQu
djIsIDApOw0KKwl9IGVsc2UNCisJCXBhbmljX3ZtKHZjcHUpOw0KK30NCisNCitzdGF0aWMgdm9p
ZCBzZXRfc2FsX2NhbGxfZGF0YShWQ1BVICp2Y3B1KQ0KK3sNCisJc3RydWN0IGV4aXRfY3RsX2Rh
dGEgKnAgPSAmdmNwdS0+YXJjaC5leGl0X2RhdGE7DQorDQorCXAtPnUuc2FsX2RhdGEuaW4wID0g
dmNwdV9nZXRfZ3IodmNwdSwgMzIpOw0KKwlwLT51LnNhbF9kYXRhLmluMSA9IHZjcHVfZ2V0X2dy
KHZjcHUsIDMzKTsNCisJcC0+dS5zYWxfZGF0YS5pbjIgPSB2Y3B1X2dldF9ncih2Y3B1LCAzNCk7
DQorCXAtPnUuc2FsX2RhdGEuaW4zID0gdmNwdV9nZXRfZ3IodmNwdSwgMzUpOw0KKwlwLT51LnNh
bF9kYXRhLmluNCA9IHZjcHVfZ2V0X2dyKHZjcHUsIDM2KTsNCisJcC0+dS5zYWxfZGF0YS5pbjUg
PSB2Y3B1X2dldF9ncih2Y3B1LCAzNyk7DQorCXAtPnUuc2FsX2RhdGEuaW42ID0gdmNwdV9nZXRf
Z3IodmNwdSwgMzgpOw0KKwlwLT51LnNhbF9kYXRhLmluNyA9IHZjcHVfZ2V0X2dyKHZjcHUsIDM5
KTsNCisJcC0+ZXhpdF9yZWFzb24gPSBFWElUX1JFQVNPTl9TQUxfQ0FMTDsNCit9DQorDQorc3Rh
dGljIHZvaWQgc2V0X3NhbF9jYWxsX3Jlc3VsdChWQ1BVICp2Y3B1KQ0KK3sNCisJc3RydWN0IGV4
aXRfY3RsX2RhdGEgKnAgPSAmdmNwdS0+YXJjaC5leGl0X2RhdGE7DQorDQorCWlmIChwLT5leGl0
X3JlYXNvbiA9PSBFWElUX1JFQVNPTl9TQUxfQ0FMTCkgew0KKwkJdmNwdV9zZXRfZ3IodmNwdSwg
OCwgcC0+dS5zYWxfZGF0YS5yZXQucjgsIDApOw0KKwkJdmNwdV9zZXRfZ3IodmNwdSwgOSwgcC0+
dS5zYWxfZGF0YS5yZXQucjksIDApOw0KKwkJdmNwdV9zZXRfZ3IodmNwdSwgMTAsIHAtPnUuc2Fs
X2RhdGEucmV0LnIxMCwgMCk7DQorCQl2Y3B1X3NldF9ncih2Y3B1LCAxMSwgcC0+dS5zYWxfZGF0
YS5yZXQucjExLCAwKTsNCisJfSBlbHNlDQorCQlwYW5pY192bSh2Y3B1KTsNCit9DQorDQordm9p
ZCAga3ZtX2lhNjRfaGFuZGxlX2JyZWFrKHVuc2lnbmVkIGxvbmcgaWZhLCBzdHJ1Y3Qga3ZtX3B0
X3JlZ3MgKnJlZ3MsDQorCQl1bnNpZ25lZCBsb25nIGlzciwgdW5zaWduZWQgbG9uZyBpaW0pDQor
ew0KKwlWQ1BVICp2ID0gY3VycmVudF92Y3B1Ow0KKw0KKwlpZiAoaWE2NF9wc3IocmVncyktPmNw
bCA9PSAwKSB7DQorCQkvKiBBbGxvdyBoeXBlcmNhbGxzIG9ubHkgd2hlbiBjcGwgPSAwLiAgKi8N
CisJCWlmIChpaW0gPT0gRE9NTl9QQUxfUkVRVUVTVCkgew0KKwkJCXNldF9wYWxfY2FsbF9kYXRh
KHYpOw0KKwkJCXZtbV90cmFuc2l0aW9uKHYpOw0KKwkJCXNldF9wYWxfY2FsbF9yZXN1bHQodik7
DQorCQkJdmNwdV9pbmNyZW1lbnRfaWlwKHYpOw0KKwkJCXJldHVybjsNCisJCX0gZWxzZSBpZiAo
aWltID09IERPTU5fU0FMX1JFUVVFU1QpIHsNCisJCQlzZXRfc2FsX2NhbGxfZGF0YSh2KTsNCisJ
CQl2bW1fdHJhbnNpdGlvbih2KTsNCisJCQlzZXRfc2FsX2NhbGxfcmVzdWx0KHYpOw0KKwkJCXZj
cHVfaW5jcmVtZW50X2lpcCh2KTsNCisJCQlyZXR1cm47DQorCQl9DQorCX0NCisJcmVmbGVjdF9p
bnRlcnJ1cHRpb24oaWZhLCBpc3IsIGlpbSwgMTEsIHJlZ3MpOw0KK30NCisNCit2b2lkIGNoZWNr
X3BlbmRpbmdfaXJxKFZDUFUgKnZjcHUpDQorew0KKwlpbnQgIG1hc2ssIGhfcGVuZGluZywgaF9p
bnNlcnZpY2U7DQorCXU2NCBpc3I7DQorCWlhNjRfcHNyIHZwc3I7DQorCVJFR1MgKnJlZ3MgPSB2
Y3B1X3JlZ3ModmNwdSk7DQorDQorCWhfcGVuZGluZyA9IGhpZ2hlc3RfcGVuZGluZ19pcnEodmNw
dSk7DQorCWlmIChoX3BlbmRpbmcgPT0gTlVMTF9WRUNUT1IpIHsNCisJCXVwZGF0ZV92aHBpKHZj
cHUsIE5VTExfVkVDVE9SKTsNCisJCXJldHVybjsNCisJfQ0KKwloX2luc2VydmljZSA9IGhpZ2hl
c3RfaW5zZXJ2aWNlX2lycSh2Y3B1KTsNCisNCisJdnBzci52YWwgPSBWQ1BVKHZjcHUsIHZwc3Ip
Ow0KKwltYXNrID0gaXJxX21hc2tlZCh2Y3B1LCBoX3BlbmRpbmcsIGhfaW5zZXJ2aWNlKTsNCisJ
aWYgKHZwc3IuaSAmJiBJUlFfTk9fTUFTS0VEID09IG1hc2spIHsNCisJCWlzciA9IHZwc3IudmFs
ICYgSUE2NF9QU1JfUkk7DQorCQl1cGRhdGVfdmhwaSh2Y3B1LCBoX3BlbmRpbmcpOw0KKwkJcmVm
bGVjdF9pbnRlcnJ1cHRpb24oMCwgaXNyLCAwLCAxMiwgcmVncyk7IC8qIEVYVCBJUlEgKi8NCisJ
fSBlbHNlIGlmIChtYXNrID09IElSUV9NQVNLRURfQllfSU5TVkMpIHsNCisJCWlmIChWQ1BVKHZj
cHUsIHZocGkpKQ0KKwkJCXVwZGF0ZV92aHBpKHZjcHUsIE5VTExfVkVDVE9SKTsNCisJfSBlbHNl
IHsNCisJCS8qIG1hc2tlZCBieSB2cHNyLmkgb3IgdnRwci4qLw0KKwkJdXBkYXRlX3ZocGkodmNw
dSwgaF9wZW5kaW5nKTsNCisJfQ0KK30NCisNCitzdGF0aWMgdm9pZCBnZW5lcmF0ZV9leGlycShW
Q1BVICp2Y3B1KQ0KK3sNCisJaWE2NF9wc3IgdnBzcjsNCisJdWludDY0X3QgaXNyOw0KKw0KKwlS
RUdTICpyZWdzID0gdmNwdV9yZWdzKHZjcHUpOw0KKw0KKwl2cHNyLnZhbCA9IFZDUFUodmNwdSwg
dnBzcik7DQorCWlzciA9IHZwc3IudmFsICYgSUE2NF9QU1JfUkk7DQorCWlmICghdnBzci5pYykN
CisJCXBhbmljX3ZtKHZjcHUpOw0KKwlyZWZsZWN0X2ludGVycnVwdGlvbigwLCBpc3IsIDAsIDEy
LCByZWdzKTsgLyogRVhUIElSUSAqLw0KK30NCisNCit2b2lkIHZocGlfZGV0ZWN0aW9uKFZDUFUg
KnZjcHUpDQorew0KKwl1aW50NjRfdCAgICB0aHJlc2hvbGQsIHZocGk7DQorCXRwcl90ICAgICAg
IHZ0cHI7DQorCWlhNjRfcHNyICAgIHZwc3I7DQorDQorCXZwc3IudmFsID0gVkNQVSh2Y3B1LCB2
cHNyKTsNCisJdnRwci52YWwgPSBWQ1BVKHZjcHUsIHRwcik7DQorDQorCXRocmVzaG9sZCA9ICgo
IXZwc3IuaSkgPDwgNSkgfCAodnRwci5tbWkgPDwgNCkgfCB2dHByLm1pYzsNCisJdmhwaSA9IFZD
UFUodmNwdSwgdmhwaSk7DQorCWlmICh2aHBpID4gdGhyZXNob2xkKSB7DQorCQkvKiBpbnRlcnJ1
cHQgYWN0aXZlZCovDQorCQlnZW5lcmF0ZV9leGlycSh2Y3B1KTsNCisJfQ0KK30NCisNCisNCit2
b2lkIGxlYXZlX2h5cGVydmlzb3JfdGFpbCh2b2lkKQ0KK3sNCisJVkNQVSAqdiA9IGN1cnJlbnRf
dmNwdTsNCisNCisJaWYgKFZNWCh2LCB0aW1lcl9jaGVjaykpIHsNCisJCVZNWCh2LCB0aW1lcl9j
aGVjaykgPSAwOw0KKwkJaWYgKFZNWCh2LCBpdGNfY2hlY2spKSB7DQorCQkJaWYgKHZjcHVfZ2V0
X2l0Yyh2KSA+IFZDUFUodiwgaXRtKSkgew0KKwkJCQlpZiAoIShWQ1BVKHYsIGl0dikgJiAoMSA8
PCAxNikpKSB7DQorCQkJCQl2Y3B1X3BlbmRfaW50ZXJydXB0KHYsIFZDUFUodiwgaXR2KQ0KKwkJ
CQkJCQkmIDB4ZmYpOw0KKwkJCQlWTVgodiwgaXRjX2NoZWNrKSA9IDA7DQorCQkJCX0gZWxzZSB7
DQorCQkJCQl2LT5hcmNoLnRpbWVyX3BlbmRpbmcgPSAxOw0KKwkJCQl9DQorCQkJCVZNWCh2LCBs
YXN0X2l0YykgPSBWQ1BVKHYsIGl0bSkgKyAxOw0KKwkJCX0NCisJCX0NCisJfQ0KKw0KKwlybWIo
KTsNCisJaWYgKHYtPmFyY2guaXJxX25ld19wZW5kaW5nKSB7DQorCQl2LT5hcmNoLmlycV9uZXdf
cGVuZGluZyA9IDA7DQorCQlWTVgodiwgaXJxX2NoZWNrKSA9IDA7DQorCQljaGVja19wZW5kaW5n
X2lycSh2KTsNCisJCXJldHVybjsNCisJfQ0KKwlpZiAoVk1YKHYsIGlycV9jaGVjaykpIHsNCisJ
CVZNWCh2LCBpcnFfY2hlY2spID0gMDsNCisJCXZocGlfZGV0ZWN0aW9uKHYpOw0KKwl9DQorfQ0K
Kw0KKw0KK3N0YXRpYyBpbmxpbmUgdm9pZCBoYW5kbGVfbGRzKFJFR1MgKnJlZ3MpDQorew0KKwly
ZWdzLT5jcl9pcHNyIHw9IElBNjRfUFNSX0VEOw0KK30NCisNCit2b2lkIHBoeXNpY2FsX3RsYl9t
aXNzKFZDUFUgKnZjcHUsIHVuc2lnbmVkIGxvbmcgdmFkciwgaW50IHR5cGUpDQorew0KKwl1bnNp
Z25lZCBsb25nIHB0ZTsNCisJaWE2NF9yciBycjsNCisNCisJcnIudmFsID0gaWE2NF9nZXRfcnIo
dmFkcik7DQorCXB0ZSA9ICB2YWRyICYgX1BBR0VfUFBOX01BU0s7DQorCXB0ZSA9IHB0ZSB8IFBI
WV9QQUdFX1dCOw0KKwl0aGFzaF92aHB0X2luc2VydCh2Y3B1LCBwdGUsICh1NjQpKHJyLnBzIDw8
IDIpLCB2YWRyLCB0eXBlKTsNCisJcmV0dXJuOw0KK30NCisNCit2b2lkIGt2bV9wYWdlX2ZhdWx0
KHU2NCB2YWRyICwgdTY0IHZlYywgUkVHUyAqcmVncykNCit7DQorCWlhNjRfcHNyIHZwc3I7DQor
CWludCB0eXBlOw0KKw0KKwl1NjQgdmhwdF9hZHIsIGdwcGEsIHB0ZXZhbCwgcnIsIGl0aXI7DQor
CWlhNjRfaXNyIG1pc3I7DQorCWlhNjRfcHRhIHZwdGE7DQorCXRoYXNoX2RhdGFfdCAqZGF0YTsN
CisJVkNQVSAqdiA9IGN1cnJlbnRfdmNwdTsNCisNCisJdnBzci52YWwgPSBWQ1BVKHYsIHZwc3Ip
Ow0KKwltaXNyLnZhbCA9IFZNWCh2LCBjcl9pc3IpOw0KKw0KKwl0eXBlID0gdmVjOw0KKw0KKwlp
ZiAoaXNfcGh5c2ljYWxfbW9kZSh2KSAmJiAoISh2YWRyIDw8IDEgPj4gNjIpKSkgew0KKwkJaWYg
KHZlYyA9PSAyKSB7DQorCQkJaWYgKF9fZ3Bmbl9pc19pbygodmFkciA8PCAxKSA+PiAoUEFHRV9T
SElGVCArIDEpKSkgew0KKwkJCQllbXVsYXRlX2lvX2luc3QodiwgKCh2YWRyIDw8IDEpID4+IDEp
LCA0KTsNCisJCQkJcmV0dXJuOw0KKwkJCX0NCisJCX0NCisJCXBoeXNpY2FsX3RsYl9taXNzKHYs
IHZhZHIsIHR5cGUpOw0KKwkJcmV0dXJuOw0KKwl9DQorCWRhdGEgPSB2dGxiX2xvb2t1cCh2LCB2
YWRyLCB0eXBlKTsNCisJaWYgKGRhdGEgIT0gMCkgew0KKwkJaWYgKHR5cGUgPT0gRF9UTEIpIHsN
CisJCQlncHBhID0gKHZhZHIgJiAoKDFVTCA8PCBkYXRhLT5wcykgLSAxKSkNCisJCQkJKyAoZGF0
YS0+cHBuID4+IChkYXRhLT5wcyAtIDEyKSA8PCBkYXRhLT5wcyk7DQorCQkJaWYgKF9fZ3Bmbl9p
c19pbyhncHBhID4+IFBBR0VfU0hJRlQpKSB7DQorCQkJCWlmIChkYXRhLT5wbCA+PSAoKHJlZ3Mt
PmNyX2lwc3IgPj4NCisJCQkJCQlJQTY0X1BTUl9DUEwwX0JJVCkgJiAzKSkNCisJCQkJCWVtdWxh
dGVfaW9faW5zdCh2LCBncHBhLCBkYXRhLT5tYSk7DQorCQkJCWVsc2Ugew0KKwkJCQkJdmNwdV9z
ZXRfaXNyKHYsIG1pc3IudmFsKTsNCisJCQkJCWRhdGFfYWNjZXNzX3JpZ2h0cyh2LCB2YWRyKTsN
CisJCQkJfQ0KKwkJCQlyZXR1cm4gOw0KKwkJCX0NCisJCX0NCisJCXRoYXNoX3ZocHRfaW5zZXJ0
KHYsIGRhdGEtPnBhZ2VfZmxhZ3MsIGRhdGEtPml0aXIsIHZhZHIsIHR5cGUpOw0KKw0KKwl9IGVs
c2UgaWYgKHR5cGUgPT0gRF9UTEIpIHsNCisJCWlmIChtaXNyLnNwKSB7DQorCQkJaGFuZGxlX2xk
cyhyZWdzKTsNCisJCQlyZXR1cm47DQorCQl9DQorDQorCQlyciA9IHZjcHVfZ2V0X3JyKHYsIHZh
ZHIpOw0KKwkJaXRpciA9IHJyICYgKFJSX1JJRF9NQVNLIHwgUlJfUFNfTUFTSyk7DQorDQorCQlp
ZiAoIXZocHRfZW5hYmxlZCh2LCB2YWRyLCBtaXNyLnJzID8gUlNFX1JFRiA6IERBVEFfUkVGKSkg
ew0KKwkJCWlmICh2cHNyLmljKSB7DQorCQkJCXZjcHVfc2V0X2lzcih2LCBtaXNyLnZhbCk7DQor
CQkJCWFsdF9kdGxiKHYsIHZhZHIpOw0KKwkJCX0gZWxzZSB7DQorCQkJCW5lc3RlZF9kdGxiKHYp
Ow0KKwkJCX0NCisJCQlyZXR1cm4gOw0KKwkJfQ0KKw0KKwkJdnB0YS52YWwgPSB2Y3B1X2dldF9w
dGEodik7DQorCQkvKiBhdm9pZCByZWN1cnNpdmVseSB3YWxraW5nIChzaG9ydCBmb3JtYXQpIFZI
UFQgKi8NCisNCisJCXZocHRfYWRyID0gdmNwdV90aGFzaCh2LCB2YWRyKTsNCisJCWlmICghZ3Vl
c3RfdmhwdF9sb29rdXAodmhwdF9hZHIsICZwdGV2YWwpKSB7DQorCQkJLyogVkhQVCBzdWNjZXNz
ZnVsbHkgcmVhZC4gICovDQorCQkJaWYgKCEocHRldmFsICYgX1BBR0VfUCkpIHsNCisJCQkJaWYg
KHZwc3IuaWMpIHsNCisJCQkJCXZjcHVfc2V0X2lzcih2LCBtaXNyLnZhbCk7DQorCQkJCQlkdGxi
X2ZhdWx0KHYsIHZhZHIpOw0KKwkJCQl9IGVsc2Ugew0KKwkJCQkJbmVzdGVkX2R0bGIodik7DQor
CQkJCX0NCisJCQl9IGVsc2UgaWYgKChwdGV2YWwgJiBfUEFHRV9NQV9NQVNLKSAhPSBfUEFHRV9N
QV9TVCkgew0KKwkJCQl0aGFzaF9wdXJnZV9hbmRfaW5zZXJ0KHYsIHB0ZXZhbCwgaXRpciwNCisJ
CQkJCQkJCXZhZHIsIERfVExCKTsNCisJCQl9IGVsc2UgaWYgKHZwc3IuaWMpIHsNCisJCQkJdmNw
dV9zZXRfaXNyKHYsIG1pc3IudmFsKTsNCisJCQkJZHRsYl9mYXVsdCh2LCB2YWRyKTsNCisJCQl9
IGVsc2Ugew0KKwkJCQluZXN0ZWRfZHRsYih2KTsNCisJCQl9DQorCQl9IGVsc2Ugew0KKwkJCS8q
IENhbid0IHJlYWQgVkhQVC4gICovDQorCQkJaWYgKHZwc3IuaWMpIHsNCisJCQkJdmNwdV9zZXRf
aXNyKHYsIG1pc3IudmFsKTsNCisJCQkJZHZocHRfZmF1bHQodiwgdmFkcik7DQorCQkJfSBlbHNl
IHsNCisJCQkJbmVzdGVkX2R0bGIodik7DQorCQkJfQ0KKwkJfQ0KKwl9IGVsc2UgaWYgKHR5cGUg
PT0gSV9UTEIpIHsNCisJCWlmICghdnBzci5pYykNCisJCQltaXNyLm5pID0gMTsNCisJCWlmICgh
dmhwdF9lbmFibGVkKHYsIHZhZHIsIElOU1RfUkVGKSkgew0KKwkJCXZjcHVfc2V0X2lzcih2LCBt
aXNyLnZhbCk7DQorCQkJYWx0X2l0bGIodiwgdmFkcik7DQorCQkJcmV0dXJuOw0KKwkJfQ0KKw0K
KwkJdnB0YS52YWwgPSB2Y3B1X2dldF9wdGEodik7DQorDQorCQl2aHB0X2FkciA9IHZjcHVfdGhh
c2godiwgdmFkcik7DQorCQlpZiAoIWd1ZXN0X3ZocHRfbG9va3VwKHZocHRfYWRyLCAmcHRldmFs
KSkgew0KKwkJCS8qIFZIUFQgc3VjY2Vzc2Z1bGx5IHJlYWQuICAqLw0KKwkJCWlmIChwdGV2YWwg
JiBfUEFHRV9QKSB7DQorCQkJCWlmICgocHRldmFsICYgX1BBR0VfTUFfTUFTSykgPT0gX1BBR0Vf
TUFfU1QpIHsNCisJCQkJCXZjcHVfc2V0X2lzcih2LCBtaXNyLnZhbCk7DQorCQkJCQlpdGxiX2Zh
dWx0KHYsIHZhZHIpOw0KKwkJCQkJcmV0dXJuIDsNCisJCQkJfQ0KKwkJCQlyciA9IHZjcHVfZ2V0
X3JyKHYsIHZhZHIpOw0KKwkJCQlpdGlyID0gcnIgJiAoUlJfUklEX01BU0sgfCBSUl9QU19NQVNL
KTsNCisJCQkJdGhhc2hfcHVyZ2VfYW5kX2luc2VydCh2LCBwdGV2YWwsIGl0aXIsDQorCQkJCQkJ
CXZhZHIsIElfVExCKTsNCisJCQl9IGVsc2Ugew0KKwkJCQl2Y3B1X3NldF9pc3IodiwgbWlzci52
YWwpOw0KKwkJCQlpbnN0X3BhZ2Vfbm90X3ByZXNlbnQodiwgdmFkcik7DQorCQkJfQ0KKwkJfSBl
bHNlIHsNCisJCQl2Y3B1X3NldF9pc3IodiwgbWlzci52YWwpOw0KKwkJCWl2aHB0X2ZhdWx0KHYs
IHZhZHIpOw0KKwkJfQ0KKwl9DQorfQ0KKw0KK3ZvaWQga3ZtX3ZleGlycShWQ1BVICp2Y3B1KQ0K
K3sNCisJdTY0IHZwc3IsIGlzcjsNCisJUkVHUyAqcmVnczsNCisNCisJcmVncyA9IHZjcHVfcmVn
cyh2Y3B1KTsNCisJdnBzciA9IFZDUFUodmNwdSwgdnBzcik7DQorCWlzciA9IHZwc3IgJiBJQTY0
X1BTUl9SSTsNCisJcmVmbGVjdF9pbnRlcnJ1cHRpb24oMCwgaXNyLCAwLCAxMiwgcmVncyk7IC8q
RVhUIElSUSovDQorfQ0KKw0KK3ZvaWQga3ZtX2lhNjRfaGFuZGxlX2lycShWQ1BVICp2KQ0KK3sN
CisJc3RydWN0IGV4aXRfY3RsX2RhdGEgKnAgPSAmdi0+YXJjaC5leGl0X2RhdGE7DQorCWxvbmcg
cHNyOw0KKw0KKwlsb2NhbF9pcnFfc2F2ZShwc3IpOw0KKwlwLT5leGl0X3JlYXNvbiA9IEVYSVRf
UkVBU09OX0VYVEVSTkFMX0lOVEVSUlVQVDsNCisJdm1tX3RyYW5zaXRpb24odik7DQorCWxvY2Fs
X2lycV9yZXN0b3JlKHBzcik7DQorDQorCVZNWCh2LCB0aW1lcl9jaGVjaykgPSAxOw0KKw0KK30N
CisNCitzdGF0aWMgdm9pZCBwdGNfZ2FfcmVtb3RlX2Z1bmMoc3RydWN0IGt2bV92Y3B1ICp2LCBp
bnQgcG9zKQ0KK3sNCisJdTY0IG9sZHJpZCwgbW9sZHJpZCwgb2xkcHNiaXRzLCB2YWRkcjsNCisJ
c3RydWN0IGt2bV9wdGNfZyAqcCA9ICZ2LT5hcmNoLnB0Y19nX2RhdGFbcG9zXTsNCisJdmFkZHIg
PSBwLT52YWRkcjsNCisNCisJb2xkcmlkID0gVk1YKHYsIHZyclswXSk7DQorCVZNWCh2LCB2cnJb
MF0pID0gcC0+cnI7DQorCW9sZHBzYml0cyA9IFZNWCh2LCBwc2JpdHNbMF0pOw0KKwlWTVgodiwg
cHNiaXRzWzBdKSA9IFZNWCh2LCBwc2JpdHNbUkVHSU9OX05VTUJFUih2YWRkcildKTsNCisJbW9s
ZHJpZCA9IGlhNjRfZ2V0X3JyKDB4MCk7DQorCWlhNjRfc2V0X3JyKDB4MCwgdnJydG9tcnIocC0+
cnIpKTsNCisJaWE2NF9zcmx6X2QoKTsNCisNCisJdmFkZHIgPSBQQUdFQUxJR04odmFkZHIsIHAt
PnBzKTsNCisJdGhhc2hfcHVyZ2VfZW50cmllc19yZW1vdGUodiwgdmFkZHIsIHAtPnBzKTsNCisN
CisJVk1YKHYsIHZyclswXSkgPSBvbGRyaWQ7DQorCVZNWCh2LCBwc2JpdHNbMF0pID0gb2xkcHNi
aXRzOw0KKwlpYTY0X3NldF9ycigweDAsIG1vbGRyaWQpOw0KKwlpYTY0X2R2X3NlcmlhbGl6ZV9k
YXRhKCk7DQorfQ0KKw0KK3N0YXRpYyB2b2lkIHZjcHVfZG9fcmVzdW1lKHN0cnVjdCBrdm1fdmNw
dSAqdmNwdSkNCit7DQorCS8qUmUtaW5pdCBWSFBUIGFuZCBWVExCIG9uY2UgZnJvbSByZXN1bWUq
Lw0KKwl2Y3B1LT5hcmNoLnZocHQubnVtID0gVkhQVF9OVU1fRU5UUklFUzsNCisJdGhhc2hfaW5p
dCgmdmNwdS0+YXJjaC52aHB0LCBWSFBUX1NISUZUKTsNCisJdmNwdS0+YXJjaC52dGxiLm51bSA9
IFZUTEJfTlVNX0VOVFJJRVM7DQorCXRoYXNoX2luaXQoJnZjcHUtPmFyY2gudnRsYiwgVlRMQl9T
SElGVCk7DQorDQorCWlhNjRfc2V0X3B0YSh2Y3B1LT5hcmNoLnZocHQucHRhLnZhbCk7DQorfQ0K
Kw0KK3N0YXRpYyB2b2lkIGt2bV9kb19yZXN1bWVfb3Aoc3RydWN0IGt2bV92Y3B1ICp2Y3B1KQ0K
K3sNCisJaWYgKHRlc3RfYW5kX2NsZWFyX2JpdChLVk1fUkVRX1JFU1VNRSwgJnZjcHUtPnJlcXVl
c3RzKSkgew0KKwkJdmNwdV9kb19yZXN1bWUodmNwdSk7DQorCQlyZXR1cm47DQorCX0NCisNCisJ
aWYgKHVubGlrZWx5KHRlc3RfYW5kX2NsZWFyX2JpdChLVk1fUkVRX1RMQl9GTFVTSCwgJnZjcHUt
PnJlcXVlc3RzKSkpIHsNCisJCXRoYXNoX3B1cmdlX2FsbCh2Y3B1KTsNCisJCXJldHVybjsNCisJ
fQ0KKw0KKwlpZiAodGVzdF9hbmRfY2xlYXJfYml0KEtWTV9SRVFfUFRDX0csICZ2Y3B1LT5yZXF1
ZXN0cykpIHsNCisJCXdoaWxlICh2Y3B1LT5hcmNoLnB0Y19nX2NvdW50ID4gMCkNCisJCQlwdGNf
Z2FfcmVtb3RlX2Z1bmModmNwdSwgLS12Y3B1LT5hcmNoLnB0Y19nX2NvdW50KTsNCisJfQ0KK30N
CisNCit2b2lkIHZtbV90cmFuc2l0aW9uKHN0cnVjdCBrdm1fdmNwdSAqdmNwdSkNCit7DQorCWlh
NjRfY2FsbF92c2EoUEFMX1ZQU19TQVZFLCAodW5zaWduZWQgbG9uZyl2Y3B1LT5hcmNoLnZwZCwN
CisJCQkwLCAwLCAwLCAwLCAwLCAwKTsNCisJdm1tX3RyYW1wb2xpbmUoJnZjcHUtPmFyY2guZ3Vl
c3QsICZ2Y3B1LT5hcmNoLmhvc3QpOw0KKwlpYTY0X2NhbGxfdnNhKFBBTF9WUFNfUkVTVE9SRSwg
KHVuc2lnbmVkIGxvbmcpdmNwdS0+YXJjaC52cGQsDQorCQkJCQkJMCwgMCwgMCwgMCwgMCwgMCk7
DQorCWt2bV9kb19yZXN1bWVfb3AodmNwdSk7DQorfQ0KLS0gDQoxLjUuMg0KDQo=

------_=_NextPart_001_01C89147.61382077--
