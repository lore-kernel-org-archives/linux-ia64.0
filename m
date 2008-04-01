From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Tue, 01 Apr 2008 10:51:02 +0000
Subject: [14/18] KVM:IA64 : Generate offset values for assembly code use. V9
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDC0104872D@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C893E6.47773CD3"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C893E6.47773CD3
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

From 10d254b2fdb93a366a2f3f29e17f6c1dfbb6e0a6 Mon Sep 17 00:00:00 2001
From: Xiantao Zhang <xiantao.zhang@intel.com>
Date: Tue, 1 Apr 2008 14:57:53 +0800
Subject: [PATCH] KVM:IA64 : Generate offset values for assembly code
use.

asm-offsets.c will generate offset values used for assembly code
for some fileds of special structures.

Signed-off-by: Anthony Xu <anthony.xu@intel.com>
Signed-off-by: Xiantao Zhang <xiantao.zhang@intel.com>
---
 arch/ia64/kvm/asm-offsets.c |  251
+++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 251 insertions(+), 0 deletions(-)
 create mode 100644 arch/ia64/kvm/asm-offsets.c

diff --git a/arch/ia64/kvm/asm-offsets.c b/arch/ia64/kvm/asm-offsets.c
new file mode 100644
index 0000000..4e3dc13
--- /dev/null
+++ b/arch/ia64/kvm/asm-offsets.c
@@ -0,0 +1,251 @@
+/*
+ * asm-offsets.c Generate definitions needed by assembly language
modules.
+ * This code generates raw asm output which is post-processed
+ * to extract and format the required data.
+ *
+ * Anthony Xu    <anthony.xu@intel.com>
+ * Xiantao Zhang <xiantao.zhang@intel.com>
+ * Copyright (c) 2007 Intel Corporation  KVM support.
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
+ */
+
+#include <linux/autoconf.h>
+#include <linux/kvm_host.h>
+
+#include "vcpu.h"
+
+#define task_struct kvm_vcpu
+
+#define DEFINE(sym, val) \
+	asm volatile("\n->" #sym " (%0) " #val : : "i" (val))
+
+#define BLANK() asm volatile("\n->" : :)
+
+#define OFFSET(_sym, _str, _mem) \
+    DEFINE(_sym, offsetof(_str, _mem));
+
+void foo(void)
+{
+	DEFINE(VMM_TASK_SIZE, sizeof(struct kvm_vcpu));
+	DEFINE(VMM_PT_REGS_SIZE, sizeof(struct kvm_pt_regs));
+
+	BLANK();
+
+	DEFINE(VMM_VCPU_META_RR0_OFFSET,
+			offsetof(struct kvm_vcpu,
arch.metaphysical_rr0));
+	DEFINE(VMM_VCPU_META_SAVED_RR0_OFFSET,
+			offsetof(struct kvm_vcpu,
+				arch.metaphysical_saved_rr0));
+	DEFINE(VMM_VCPU_VRR0_OFFSET,
+			offsetof(struct kvm_vcpu, arch.vrr[0]));
+	DEFINE(VMM_VPD_IRR0_OFFSET,
+			offsetof(struct vpd, irr[0]));
+	DEFINE(VMM_VCPU_ITC_CHECK_OFFSET,
+			offsetof(struct kvm_vcpu, arch.itc_check));
+	DEFINE(VMM_VCPU_IRQ_CHECK_OFFSET,
+			offsetof(struct kvm_vcpu, arch.irq_check));
+	DEFINE(VMM_VPD_VHPI_OFFSET,
+			offsetof(struct vpd, vhpi));
+	DEFINE(VMM_VCPU_VSA_BASE_OFFSET,
+			offsetof(struct kvm_vcpu, arch.vsa_base));
+	DEFINE(VMM_VCPU_VPD_OFFSET,
+			offsetof(struct kvm_vcpu, arch.vpd));
+	DEFINE(VMM_VCPU_IRQ_CHECK,
+			offsetof(struct kvm_vcpu, arch.irq_check));
+	DEFINE(VMM_VCPU_TIMER_PENDING,
+			offsetof(struct kvm_vcpu, arch.timer_pending));
+	DEFINE(VMM_VCPU_META_SAVED_RR0_OFFSET,
+			offsetof(struct kvm_vcpu,
arch.metaphysical_saved_rr0));
+	DEFINE(VMM_VCPU_MODE_FLAGS_OFFSET,
+			offsetof(struct kvm_vcpu, arch.mode_flags));
+	DEFINE(VMM_VCPU_ITC_OFS_OFFSET,
+			offsetof(struct kvm_vcpu, arch.itc_offset));
+	DEFINE(VMM_VCPU_LAST_ITC_OFFSET,
+			offsetof(struct kvm_vcpu, arch.last_itc));
+	DEFINE(VMM_VCPU_SAVED_GP_OFFSET,
+			offsetof(struct kvm_vcpu, arch.saved_gp));
+
+	BLANK();
+
+	DEFINE(VMM_PT_REGS_B6_OFFSET,
+				offsetof(struct kvm_pt_regs, b6));
+	DEFINE(VMM_PT_REGS_B7_OFFSET,
+				offsetof(struct kvm_pt_regs, b7));
+	DEFINE(VMM_PT_REGS_AR_CSD_OFFSET,
+				offsetof(struct kvm_pt_regs, ar_csd));
+	DEFINE(VMM_PT_REGS_AR_SSD_OFFSET,
+				offsetof(struct kvm_pt_regs, ar_ssd));
+	DEFINE(VMM_PT_REGS_R8_OFFSET,
+				offsetof(struct kvm_pt_regs, r8));
+	DEFINE(VMM_PT_REGS_R9_OFFSET,
+				offsetof(struct kvm_pt_regs, r9));
+	DEFINE(VMM_PT_REGS_R10_OFFSET,
+				offsetof(struct kvm_pt_regs, r10));
+	DEFINE(VMM_PT_REGS_R11_OFFSET,
+				offsetof(struct kvm_pt_regs, r11));
+	DEFINE(VMM_PT_REGS_CR_IPSR_OFFSET,
+				offsetof(struct kvm_pt_regs, cr_ipsr));
+	DEFINE(VMM_PT_REGS_CR_IIP_OFFSET,
+				offsetof(struct kvm_pt_regs, cr_iip));
+	DEFINE(VMM_PT_REGS_CR_IFS_OFFSET,
+				offsetof(struct kvm_pt_regs, cr_ifs));
+	DEFINE(VMM_PT_REGS_AR_UNAT_OFFSET,
+				offsetof(struct kvm_pt_regs, ar_unat));
+	DEFINE(VMM_PT_REGS_AR_PFS_OFFSET,
+				offsetof(struct kvm_pt_regs, ar_pfs));
+	DEFINE(VMM_PT_REGS_AR_RSC_OFFSET,
+				offsetof(struct kvm_pt_regs, ar_rsc));
+	DEFINE(VMM_PT_REGS_AR_RNAT_OFFSET,
+				offsetof(struct kvm_pt_regs, ar_rnat));
+
+	DEFINE(VMM_PT_REGS_AR_BSPSTORE_OFFSET,
+				offsetof(struct kvm_pt_regs,
ar_bspstore));
+	DEFINE(VMM_PT_REGS_PR_OFFSET,
+				offsetof(struct kvm_pt_regs, pr));
+	DEFINE(VMM_PT_REGS_B0_OFFSET,
+				offsetof(struct kvm_pt_regs, b0));
+	DEFINE(VMM_PT_REGS_LOADRS_OFFSET,
+				offsetof(struct kvm_pt_regs, loadrs));
+	DEFINE(VMM_PT_REGS_R1_OFFSET,
+				offsetof(struct kvm_pt_regs, r1));
+	DEFINE(VMM_PT_REGS_R12_OFFSET,
+				offsetof(struct kvm_pt_regs, r12));
+	DEFINE(VMM_PT_REGS_R13_OFFSET,
+				offsetof(struct kvm_pt_regs, r13));
+	DEFINE(VMM_PT_REGS_AR_FPSR_OFFSET,
+				offsetof(struct kvm_pt_regs, ar_fpsr));
+	DEFINE(VMM_PT_REGS_R15_OFFSET,
+				offsetof(struct kvm_pt_regs, r15));
+	DEFINE(VMM_PT_REGS_R14_OFFSET,
+				offsetof(struct kvm_pt_regs, r14));
+	DEFINE(VMM_PT_REGS_R2_OFFSET,
+				offsetof(struct kvm_pt_regs, r2));
+	DEFINE(VMM_PT_REGS_R3_OFFSET,
+				offsetof(struct kvm_pt_regs, r3));
+	DEFINE(VMM_PT_REGS_R16_OFFSET,
+				offsetof(struct kvm_pt_regs, r16));
+	DEFINE(VMM_PT_REGS_R17_OFFSET,
+				offsetof(struct kvm_pt_regs, r17));
+	DEFINE(VMM_PT_REGS_R18_OFFSET,
+				offsetof(struct kvm_pt_regs, r18));
+	DEFINE(VMM_PT_REGS_R19_OFFSET,
+				offsetof(struct kvm_pt_regs, r19));
+	DEFINE(VMM_PT_REGS_R20_OFFSET,
+				offsetof(struct kvm_pt_regs, r20));
+	DEFINE(VMM_PT_REGS_R21_OFFSET,
+				offsetof(struct kvm_pt_regs, r21));
+	DEFINE(VMM_PT_REGS_R22_OFFSET,
+				offsetof(struct kvm_pt_regs, r22));
+	DEFINE(VMM_PT_REGS_R23_OFFSET,
+				offsetof(struct kvm_pt_regs, r23));
+	DEFINE(VMM_PT_REGS_R24_OFFSET,
+				offsetof(struct kvm_pt_regs, r24));
+	DEFINE(VMM_PT_REGS_R25_OFFSET,
+				offsetof(struct kvm_pt_regs, r25));
+	DEFINE(VMM_PT_REGS_R26_OFFSET,
+				offsetof(struct kvm_pt_regs, r26));
+	DEFINE(VMM_PT_REGS_R27_OFFSET,
+				offsetof(struct kvm_pt_regs, r27));
+	DEFINE(VMM_PT_REGS_R28_OFFSET,
+				offsetof(struct kvm_pt_regs, r28));
+	DEFINE(VMM_PT_REGS_R29_OFFSET,
+				offsetof(struct kvm_pt_regs, r29));
+	DEFINE(VMM_PT_REGS_R30_OFFSET,
+				offsetof(struct kvm_pt_regs, r30));
+	DEFINE(VMM_PT_REGS_R31_OFFSET,
+				offsetof(struct kvm_pt_regs, r31));
+	DEFINE(VMM_PT_REGS_AR_CCV_OFFSET,
+				offsetof(struct kvm_pt_regs, ar_ccv));
+	DEFINE(VMM_PT_REGS_F6_OFFSET,
+				offsetof(struct kvm_pt_regs, f6));
+	DEFINE(VMM_PT_REGS_F7_OFFSET,
+				offsetof(struct kvm_pt_regs, f7));
+	DEFINE(VMM_PT_REGS_F8_OFFSET,
+				offsetof(struct kvm_pt_regs, f8));
+	DEFINE(VMM_PT_REGS_F9_OFFSET,
+				offsetof(struct kvm_pt_regs, f9));
+	DEFINE(VMM_PT_REGS_F10_OFFSET,
+				offsetof(struct kvm_pt_regs, f10));
+	DEFINE(VMM_PT_REGS_F11_OFFSET,
+				offsetof(struct kvm_pt_regs, f11));
+	DEFINE(VMM_PT_REGS_R4_OFFSET,
+				offsetof(struct kvm_pt_regs, r4));
+	DEFINE(VMM_PT_REGS_R5_OFFSET,
+				offsetof(struct kvm_pt_regs, r5));
+	DEFINE(VMM_PT_REGS_R6_OFFSET,
+				offsetof(struct kvm_pt_regs, r6));
+	DEFINE(VMM_PT_REGS_R7_OFFSET,
+				offsetof(struct kvm_pt_regs, r7));
+	DEFINE(VMM_PT_REGS_EML_UNAT_OFFSET,
+				offsetof(struct kvm_pt_regs, eml_unat));
+	DEFINE(VMM_VCPU_IIPA_OFFSET,
+				offsetof(struct kvm_vcpu,
arch.cr_iipa));
+	DEFINE(VMM_VCPU_OPCODE_OFFSET,
+				offsetof(struct kvm_vcpu, arch.opcode));
+	DEFINE(VMM_VCPU_CAUSE_OFFSET, offsetof(struct kvm_vcpu,
arch.cause));
+	DEFINE(VMM_VCPU_ISR_OFFSET,
+				offsetof(struct kvm_vcpu, arch.cr_isr));
+	DEFINE(VMM_PT_REGS_R16_SLOT,
+				(((offsetof(struct kvm_pt_regs, r16)
+				- sizeof(struct kvm_pt_regs)) >> 3) &
0x3f));
+	DEFINE(VMM_VCPU_MODE_FLAGS_OFFSET,
+				offsetof(struct kvm_vcpu,
arch.mode_flags));
+	DEFINE(VMM_VCPU_GP_OFFSET, offsetof(struct kvm_vcpu,
arch.__gp));
+	BLANK();
+
+	DEFINE(VMM_VPD_BASE_OFFSET, offsetof(struct kvm_vcpu,
arch.vpd));
+	DEFINE(VMM_VPD_VIFS_OFFSET, offsetof(struct vpd, ifs));
+	DEFINE(VMM_VLSAPIC_INSVC_BASE_OFFSET,
+			offsetof(struct kvm_vcpu, arch.insvc[0]));
+	DEFINE(VMM_VPD_VPTA_OFFSET, offsetof(struct vpd, pta));
+	DEFINE(VMM_VPD_VPSR_OFFSET, offsetof(struct vpd, vpsr));
+
+	DEFINE(VMM_CTX_R4_OFFSET, offsetof(union context, gr[4]));
+	DEFINE(VMM_CTX_R5_OFFSET, offsetof(union context, gr[5]));
+	DEFINE(VMM_CTX_R12_OFFSET, offsetof(union context, gr[12]));
+	DEFINE(VMM_CTX_R13_OFFSET, offsetof(union context, gr[13]));
+	DEFINE(VMM_CTX_KR0_OFFSET, offsetof(union context, ar[0]));
+	DEFINE(VMM_CTX_KR1_OFFSET, offsetof(union context, ar[1]));
+	DEFINE(VMM_CTX_B0_OFFSET, offsetof(union context, br[0]));
+	DEFINE(VMM_CTX_B1_OFFSET, offsetof(union context, br[1]));
+	DEFINE(VMM_CTX_B2_OFFSET, offsetof(union context, br[2]));
+	DEFINE(VMM_CTX_RR0_OFFSET, offsetof(union context, rr[0]));
+	DEFINE(VMM_CTX_RSC_OFFSET, offsetof(union context, ar[16]));
+	DEFINE(VMM_CTX_BSPSTORE_OFFSET, offsetof(union context,
ar[18]));
+	DEFINE(VMM_CTX_RNAT_OFFSET, offsetof(union context, ar[19]));
+	DEFINE(VMM_CTX_FCR_OFFSET, offsetof(union context, ar[21]));
+	DEFINE(VMM_CTX_EFLAG_OFFSET, offsetof(union context, ar[24]));
+	DEFINE(VMM_CTX_CFLG_OFFSET, offsetof(union context, ar[27]));
+	DEFINE(VMM_CTX_FSR_OFFSET, offsetof(union context, ar[28]));
+	DEFINE(VMM_CTX_FIR_OFFSET, offsetof(union context, ar[29]));
+	DEFINE(VMM_CTX_FDR_OFFSET, offsetof(union context, ar[30]));
+	DEFINE(VMM_CTX_UNAT_OFFSET, offsetof(union context, ar[36]));
+	DEFINE(VMM_CTX_FPSR_OFFSET, offsetof(union context, ar[40]));
+	DEFINE(VMM_CTX_PFS_OFFSET, offsetof(union context, ar[64]));
+	DEFINE(VMM_CTX_LC_OFFSET, offsetof(union context, ar[65]));
+	DEFINE(VMM_CTX_DCR_OFFSET, offsetof(union context, cr[0]));
+	DEFINE(VMM_CTX_IVA_OFFSET, offsetof(union context, cr[2]));
+	DEFINE(VMM_CTX_PTA_OFFSET, offsetof(union context, cr[8]));
+	DEFINE(VMM_CTX_IBR0_OFFSET, offsetof(union context, ibr[0]));
+	DEFINE(VMM_CTX_DBR0_OFFSET, offsetof(union context, dbr[0]));
+	DEFINE(VMM_CTX_F2_OFFSET, offsetof(union context, fr[2]));
+	DEFINE(VMM_CTX_F3_OFFSET, offsetof(union context, fr[3]));
+	DEFINE(VMM_CTX_F32_OFFSET, offsetof(union context, fr[32]));
+	DEFINE(VMM_CTX_F33_OFFSET, offsetof(union context, fr[33]));
+	DEFINE(VMM_CTX_PKR0_OFFSET, offsetof(union context, pkr[0]));
+	DEFINE(VMM_CTX_PSR_OFFSET, offsetof(union context, psr));
+	BLANK();
+}
--=20
1.5.2

------_=_NextPart_001_01C893E6.47773CD3
Content-Type: application/octet-stream;
	name="0014-KVM-IA64-Generate-offset-values-for-assembly-code.patch"
Content-Transfer-Encoding: base64
Content-Description: 0014-KVM-IA64-Generate-offset-values-for-assembly-code.patch
Content-Disposition: attachment;
	filename="0014-KVM-IA64-Generate-offset-values-for-assembly-code.patch"

RnJvbSAxMGQyNTRiMmZkYjkzYTM2NmEyZjNmMjllMTdmNmMxZGZiYjZlMGE2IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBYaWFudGFvIFpoYW5nIDx4aWFudGFvLnpoYW5nQGludGVsLmNv
bT4KRGF0ZTogVHVlLCAxIEFwciAyMDA4IDE0OjU3OjUzICswODAwClN1YmplY3Q6IFtQQVRDSF0g
S1ZNOklBNjQgOiBHZW5lcmF0ZSBvZmZzZXQgdmFsdWVzIGZvciBhc3NlbWJseSBjb2RlIHVzZS4K
CmFzbS1vZmZzZXRzLmMgd2lsbCBnZW5lcmF0ZSBvZmZzZXQgdmFsdWVzIHVzZWQgZm9yIGFzc2Vt
Ymx5IGNvZGUKZm9yIHNvbWUgZmlsZWRzIG9mIHNwZWNpYWwgc3RydWN0dXJlcy4KClNpZ25lZC1v
ZmYtYnk6IEFudGhvbnkgWHUgPGFudGhvbnkueHVAaW50ZWwuY29tPgpTaWduZWQtb2ZmLWJ5OiBY
aWFudGFvIFpoYW5nIDx4aWFudGFvLnpoYW5nQGludGVsLmNvbT4KLS0tCiBhcmNoL2lhNjQva3Zt
L2FzbS1vZmZzZXRzLmMgfCAgMjUxICsrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysr
KysrKysrKysKIDEgZmlsZXMgY2hhbmdlZCwgMjUxIGluc2VydGlvbnMoKyksIDAgZGVsZXRpb25z
KC0pCiBjcmVhdGUgbW9kZSAxMDA2NDQgYXJjaC9pYTY0L2t2bS9hc20tb2Zmc2V0cy5jCgpkaWZm
IC0tZ2l0IGEvYXJjaC9pYTY0L2t2bS9hc20tb2Zmc2V0cy5jIGIvYXJjaC9pYTY0L2t2bS9hc20t
b2Zmc2V0cy5jCm5ldyBmaWxlIG1vZGUgMTAwNjQ0CmluZGV4IDAwMDAwMDAuLjRlM2RjMTMKLS0t
IC9kZXYvbnVsbAorKysgYi9hcmNoL2lhNjQva3ZtL2FzbS1vZmZzZXRzLmMKQEAgLTAsMCArMSwy
NTEgQEAKKy8qCisgKiBhc20tb2Zmc2V0cy5jIEdlbmVyYXRlIGRlZmluaXRpb25zIG5lZWRlZCBi
eSBhc3NlbWJseSBsYW5ndWFnZSBtb2R1bGVzLgorICogVGhpcyBjb2RlIGdlbmVyYXRlcyByYXcg
YXNtIG91dHB1dCB3aGljaCBpcyBwb3N0LXByb2Nlc3NlZAorICogdG8gZXh0cmFjdCBhbmQgZm9y
bWF0IHRoZSByZXF1aXJlZCBkYXRhLgorICoKKyAqIEFudGhvbnkgWHUgICAgPGFudGhvbnkueHVA
aW50ZWwuY29tPgorICogWGlhbnRhbyBaaGFuZyA8eGlhbnRhby56aGFuZ0BpbnRlbC5jb20+Cisg
KiBDb3B5cmlnaHQgKGMpIDIwMDcgSW50ZWwgQ29ycG9yYXRpb24gIEtWTSBzdXBwb3J0LgorICoK
KyAqIFRoaXMgcHJvZ3JhbSBpcyBmcmVlIHNvZnR3YXJlOyB5b3UgY2FuIHJlZGlzdHJpYnV0ZSBp
dCBhbmQvb3IgbW9kaWZ5IGl0CisgKiB1bmRlciB0aGUgdGVybXMgYW5kIGNvbmRpdGlvbnMgb2Yg
dGhlIEdOVSBHZW5lcmFsIFB1YmxpYyBMaWNlbnNlLAorICogdmVyc2lvbiAyLCBhcyBwdWJsaXNo
ZWQgYnkgdGhlIEZyZWUgU29mdHdhcmUgRm91bmRhdGlvbi4KKyAqCisgKiBUaGlzIHByb2dyYW0g
aXMgZGlzdHJpYnV0ZWQgaW4gdGhlIGhvcGUgaXQgd2lsbCBiZSB1c2VmdWwsIGJ1dCBXSVRIT1VU
CisgKiBBTlkgV0FSUkFOVFk7IHdpdGhvdXQgZXZlbiB0aGUgaW1wbGllZCB3YXJyYW50eSBvZiBN
RVJDSEFOVEFCSUxJVFkgb3IKKyAqIEZJVE5FU1MgRk9SIEEgUEFSVElDVUxBUiBQVVJQT1NFLiAg
U2VlIHRoZSBHTlUgR2VuZXJhbCBQdWJsaWMgTGljZW5zZSBmb3IKKyAqIG1vcmUgZGV0YWlscy4K
KyAqCisgKiBZb3Ugc2hvdWxkIGhhdmUgcmVjZWl2ZWQgYSBjb3B5IG9mIHRoZSBHTlUgR2VuZXJh
bCBQdWJsaWMgTGljZW5zZSBhbG9uZyB3aXRoCisgKiB0aGlzIHByb2dyYW07IGlmIG5vdCwgd3Jp
dGUgdG8gdGhlIEZyZWUgU29mdHdhcmUgRm91bmRhdGlvbiwgSW5jLiwgNTkgVGVtcGxlCisgKiBQ
bGFjZSAtIFN1aXRlIDMzMCwgQm9zdG9uLCBNQSAwMjExMS0xMzA3IFVTQS4KKyAqCisgKi8KKwor
I2luY2x1ZGUgPGxpbnV4L2F1dG9jb25mLmg+CisjaW5jbHVkZSA8bGludXgva3ZtX2hvc3QuaD4K
KworI2luY2x1ZGUgInZjcHUuaCIKKworI2RlZmluZSB0YXNrX3N0cnVjdCBrdm1fdmNwdQorCisj
ZGVmaW5lIERFRklORShzeW0sIHZhbCkgXAorCWFzbSB2b2xhdGlsZSgiXG4tPiIgI3N5bSAiICgl
MCkgIiAjdmFsIDogOiAiaSIgKHZhbCkpCisKKyNkZWZpbmUgQkxBTksoKSBhc20gdm9sYXRpbGUo
IlxuLT4iIDogOikKKworI2RlZmluZSBPRkZTRVQoX3N5bSwgX3N0ciwgX21lbSkgXAorICAgIERF
RklORShfc3ltLCBvZmZzZXRvZihfc3RyLCBfbWVtKSk7CisKK3ZvaWQgZm9vKHZvaWQpCit7CisJ
REVGSU5FKFZNTV9UQVNLX1NJWkUsIHNpemVvZihzdHJ1Y3Qga3ZtX3ZjcHUpKTsKKwlERUZJTkUo
Vk1NX1BUX1JFR1NfU0laRSwgc2l6ZW9mKHN0cnVjdCBrdm1fcHRfcmVncykpOworCisJQkxBTkso
KTsKKworCURFRklORShWTU1fVkNQVV9NRVRBX1JSMF9PRkZTRVQsCisJCQlvZmZzZXRvZihzdHJ1
Y3Qga3ZtX3ZjcHUsIGFyY2gubWV0YXBoeXNpY2FsX3JyMCkpOworCURFRklORShWTU1fVkNQVV9N
RVRBX1NBVkVEX1JSMF9PRkZTRVQsCisJCQlvZmZzZXRvZihzdHJ1Y3Qga3ZtX3ZjcHUsCisJCQkJ
YXJjaC5tZXRhcGh5c2ljYWxfc2F2ZWRfcnIwKSk7CisJREVGSU5FKFZNTV9WQ1BVX1ZSUjBfT0ZG
U0VULAorCQkJb2Zmc2V0b2Yoc3RydWN0IGt2bV92Y3B1LCBhcmNoLnZyclswXSkpOworCURFRklO
RShWTU1fVlBEX0lSUjBfT0ZGU0VULAorCQkJb2Zmc2V0b2Yoc3RydWN0IHZwZCwgaXJyWzBdKSk7
CisJREVGSU5FKFZNTV9WQ1BVX0lUQ19DSEVDS19PRkZTRVQsCisJCQlvZmZzZXRvZihzdHJ1Y3Qg
a3ZtX3ZjcHUsIGFyY2guaXRjX2NoZWNrKSk7CisJREVGSU5FKFZNTV9WQ1BVX0lSUV9DSEVDS19P
RkZTRVQsCisJCQlvZmZzZXRvZihzdHJ1Y3Qga3ZtX3ZjcHUsIGFyY2guaXJxX2NoZWNrKSk7CisJ
REVGSU5FKFZNTV9WUERfVkhQSV9PRkZTRVQsCisJCQlvZmZzZXRvZihzdHJ1Y3QgdnBkLCB2aHBp
KSk7CisJREVGSU5FKFZNTV9WQ1BVX1ZTQV9CQVNFX09GRlNFVCwKKwkJCW9mZnNldG9mKHN0cnVj
dCBrdm1fdmNwdSwgYXJjaC52c2FfYmFzZSkpOworCURFRklORShWTU1fVkNQVV9WUERfT0ZGU0VU
LAorCQkJb2Zmc2V0b2Yoc3RydWN0IGt2bV92Y3B1LCBhcmNoLnZwZCkpOworCURFRklORShWTU1f
VkNQVV9JUlFfQ0hFQ0ssCisJCQlvZmZzZXRvZihzdHJ1Y3Qga3ZtX3ZjcHUsIGFyY2guaXJxX2No
ZWNrKSk7CisJREVGSU5FKFZNTV9WQ1BVX1RJTUVSX1BFTkRJTkcsCisJCQlvZmZzZXRvZihzdHJ1
Y3Qga3ZtX3ZjcHUsIGFyY2gudGltZXJfcGVuZGluZykpOworCURFRklORShWTU1fVkNQVV9NRVRB
X1NBVkVEX1JSMF9PRkZTRVQsCisJCQlvZmZzZXRvZihzdHJ1Y3Qga3ZtX3ZjcHUsIGFyY2gubWV0
YXBoeXNpY2FsX3NhdmVkX3JyMCkpOworCURFRklORShWTU1fVkNQVV9NT0RFX0ZMQUdTX09GRlNF
VCwKKwkJCW9mZnNldG9mKHN0cnVjdCBrdm1fdmNwdSwgYXJjaC5tb2RlX2ZsYWdzKSk7CisJREVG
SU5FKFZNTV9WQ1BVX0lUQ19PRlNfT0ZGU0VULAorCQkJb2Zmc2V0b2Yoc3RydWN0IGt2bV92Y3B1
LCBhcmNoLml0Y19vZmZzZXQpKTsKKwlERUZJTkUoVk1NX1ZDUFVfTEFTVF9JVENfT0ZGU0VULAor
CQkJb2Zmc2V0b2Yoc3RydWN0IGt2bV92Y3B1LCBhcmNoLmxhc3RfaXRjKSk7CisJREVGSU5FKFZN
TV9WQ1BVX1NBVkVEX0dQX09GRlNFVCwKKwkJCW9mZnNldG9mKHN0cnVjdCBrdm1fdmNwdSwgYXJj
aC5zYXZlZF9ncCkpOworCisJQkxBTksoKTsKKworCURFRklORShWTU1fUFRfUkVHU19CNl9PRkZT
RVQsCisJCQkJb2Zmc2V0b2Yoc3RydWN0IGt2bV9wdF9yZWdzLCBiNikpOworCURFRklORShWTU1f
UFRfUkVHU19CN19PRkZTRVQsCisJCQkJb2Zmc2V0b2Yoc3RydWN0IGt2bV9wdF9yZWdzLCBiNykp
OworCURFRklORShWTU1fUFRfUkVHU19BUl9DU0RfT0ZGU0VULAorCQkJCW9mZnNldG9mKHN0cnVj
dCBrdm1fcHRfcmVncywgYXJfY3NkKSk7CisJREVGSU5FKFZNTV9QVF9SRUdTX0FSX1NTRF9PRkZT
RVQsCisJCQkJb2Zmc2V0b2Yoc3RydWN0IGt2bV9wdF9yZWdzLCBhcl9zc2QpKTsKKwlERUZJTkUo
Vk1NX1BUX1JFR1NfUjhfT0ZGU0VULAorCQkJCW9mZnNldG9mKHN0cnVjdCBrdm1fcHRfcmVncywg
cjgpKTsKKwlERUZJTkUoVk1NX1BUX1JFR1NfUjlfT0ZGU0VULAorCQkJCW9mZnNldG9mKHN0cnVj
dCBrdm1fcHRfcmVncywgcjkpKTsKKwlERUZJTkUoVk1NX1BUX1JFR1NfUjEwX09GRlNFVCwKKwkJ
CQlvZmZzZXRvZihzdHJ1Y3Qga3ZtX3B0X3JlZ3MsIHIxMCkpOworCURFRklORShWTU1fUFRfUkVH
U19SMTFfT0ZGU0VULAorCQkJCW9mZnNldG9mKHN0cnVjdCBrdm1fcHRfcmVncywgcjExKSk7CisJ
REVGSU5FKFZNTV9QVF9SRUdTX0NSX0lQU1JfT0ZGU0VULAorCQkJCW9mZnNldG9mKHN0cnVjdCBr
dm1fcHRfcmVncywgY3JfaXBzcikpOworCURFRklORShWTU1fUFRfUkVHU19DUl9JSVBfT0ZGU0VU
LAorCQkJCW9mZnNldG9mKHN0cnVjdCBrdm1fcHRfcmVncywgY3JfaWlwKSk7CisJREVGSU5FKFZN
TV9QVF9SRUdTX0NSX0lGU19PRkZTRVQsCisJCQkJb2Zmc2V0b2Yoc3RydWN0IGt2bV9wdF9yZWdz
LCBjcl9pZnMpKTsKKwlERUZJTkUoVk1NX1BUX1JFR1NfQVJfVU5BVF9PRkZTRVQsCisJCQkJb2Zm
c2V0b2Yoc3RydWN0IGt2bV9wdF9yZWdzLCBhcl91bmF0KSk7CisJREVGSU5FKFZNTV9QVF9SRUdT
X0FSX1BGU19PRkZTRVQsCisJCQkJb2Zmc2V0b2Yoc3RydWN0IGt2bV9wdF9yZWdzLCBhcl9wZnMp
KTsKKwlERUZJTkUoVk1NX1BUX1JFR1NfQVJfUlNDX09GRlNFVCwKKwkJCQlvZmZzZXRvZihzdHJ1
Y3Qga3ZtX3B0X3JlZ3MsIGFyX3JzYykpOworCURFRklORShWTU1fUFRfUkVHU19BUl9STkFUX09G
RlNFVCwKKwkJCQlvZmZzZXRvZihzdHJ1Y3Qga3ZtX3B0X3JlZ3MsIGFyX3JuYXQpKTsKKworCURF
RklORShWTU1fUFRfUkVHU19BUl9CU1BTVE9SRV9PRkZTRVQsCisJCQkJb2Zmc2V0b2Yoc3RydWN0
IGt2bV9wdF9yZWdzLCBhcl9ic3BzdG9yZSkpOworCURFRklORShWTU1fUFRfUkVHU19QUl9PRkZT
RVQsCisJCQkJb2Zmc2V0b2Yoc3RydWN0IGt2bV9wdF9yZWdzLCBwcikpOworCURFRklORShWTU1f
UFRfUkVHU19CMF9PRkZTRVQsCisJCQkJb2Zmc2V0b2Yoc3RydWN0IGt2bV9wdF9yZWdzLCBiMCkp
OworCURFRklORShWTU1fUFRfUkVHU19MT0FEUlNfT0ZGU0VULAorCQkJCW9mZnNldG9mKHN0cnVj
dCBrdm1fcHRfcmVncywgbG9hZHJzKSk7CisJREVGSU5FKFZNTV9QVF9SRUdTX1IxX09GRlNFVCwK
KwkJCQlvZmZzZXRvZihzdHJ1Y3Qga3ZtX3B0X3JlZ3MsIHIxKSk7CisJREVGSU5FKFZNTV9QVF9S
RUdTX1IxMl9PRkZTRVQsCisJCQkJb2Zmc2V0b2Yoc3RydWN0IGt2bV9wdF9yZWdzLCByMTIpKTsK
KwlERUZJTkUoVk1NX1BUX1JFR1NfUjEzX09GRlNFVCwKKwkJCQlvZmZzZXRvZihzdHJ1Y3Qga3Zt
X3B0X3JlZ3MsIHIxMykpOworCURFRklORShWTU1fUFRfUkVHU19BUl9GUFNSX09GRlNFVCwKKwkJ
CQlvZmZzZXRvZihzdHJ1Y3Qga3ZtX3B0X3JlZ3MsIGFyX2Zwc3IpKTsKKwlERUZJTkUoVk1NX1BU
X1JFR1NfUjE1X09GRlNFVCwKKwkJCQlvZmZzZXRvZihzdHJ1Y3Qga3ZtX3B0X3JlZ3MsIHIxNSkp
OworCURFRklORShWTU1fUFRfUkVHU19SMTRfT0ZGU0VULAorCQkJCW9mZnNldG9mKHN0cnVjdCBr
dm1fcHRfcmVncywgcjE0KSk7CisJREVGSU5FKFZNTV9QVF9SRUdTX1IyX09GRlNFVCwKKwkJCQlv
ZmZzZXRvZihzdHJ1Y3Qga3ZtX3B0X3JlZ3MsIHIyKSk7CisJREVGSU5FKFZNTV9QVF9SRUdTX1Iz
X09GRlNFVCwKKwkJCQlvZmZzZXRvZihzdHJ1Y3Qga3ZtX3B0X3JlZ3MsIHIzKSk7CisJREVGSU5F
KFZNTV9QVF9SRUdTX1IxNl9PRkZTRVQsCisJCQkJb2Zmc2V0b2Yoc3RydWN0IGt2bV9wdF9yZWdz
LCByMTYpKTsKKwlERUZJTkUoVk1NX1BUX1JFR1NfUjE3X09GRlNFVCwKKwkJCQlvZmZzZXRvZihz
dHJ1Y3Qga3ZtX3B0X3JlZ3MsIHIxNykpOworCURFRklORShWTU1fUFRfUkVHU19SMThfT0ZGU0VU
LAorCQkJCW9mZnNldG9mKHN0cnVjdCBrdm1fcHRfcmVncywgcjE4KSk7CisJREVGSU5FKFZNTV9Q
VF9SRUdTX1IxOV9PRkZTRVQsCisJCQkJb2Zmc2V0b2Yoc3RydWN0IGt2bV9wdF9yZWdzLCByMTkp
KTsKKwlERUZJTkUoVk1NX1BUX1JFR1NfUjIwX09GRlNFVCwKKwkJCQlvZmZzZXRvZihzdHJ1Y3Qg
a3ZtX3B0X3JlZ3MsIHIyMCkpOworCURFRklORShWTU1fUFRfUkVHU19SMjFfT0ZGU0VULAorCQkJ
CW9mZnNldG9mKHN0cnVjdCBrdm1fcHRfcmVncywgcjIxKSk7CisJREVGSU5FKFZNTV9QVF9SRUdT
X1IyMl9PRkZTRVQsCisJCQkJb2Zmc2V0b2Yoc3RydWN0IGt2bV9wdF9yZWdzLCByMjIpKTsKKwlE
RUZJTkUoVk1NX1BUX1JFR1NfUjIzX09GRlNFVCwKKwkJCQlvZmZzZXRvZihzdHJ1Y3Qga3ZtX3B0
X3JlZ3MsIHIyMykpOworCURFRklORShWTU1fUFRfUkVHU19SMjRfT0ZGU0VULAorCQkJCW9mZnNl
dG9mKHN0cnVjdCBrdm1fcHRfcmVncywgcjI0KSk7CisJREVGSU5FKFZNTV9QVF9SRUdTX1IyNV9P
RkZTRVQsCisJCQkJb2Zmc2V0b2Yoc3RydWN0IGt2bV9wdF9yZWdzLCByMjUpKTsKKwlERUZJTkUo
Vk1NX1BUX1JFR1NfUjI2X09GRlNFVCwKKwkJCQlvZmZzZXRvZihzdHJ1Y3Qga3ZtX3B0X3JlZ3Ms
IHIyNikpOworCURFRklORShWTU1fUFRfUkVHU19SMjdfT0ZGU0VULAorCQkJCW9mZnNldG9mKHN0
cnVjdCBrdm1fcHRfcmVncywgcjI3KSk7CisJREVGSU5FKFZNTV9QVF9SRUdTX1IyOF9PRkZTRVQs
CisJCQkJb2Zmc2V0b2Yoc3RydWN0IGt2bV9wdF9yZWdzLCByMjgpKTsKKwlERUZJTkUoVk1NX1BU
X1JFR1NfUjI5X09GRlNFVCwKKwkJCQlvZmZzZXRvZihzdHJ1Y3Qga3ZtX3B0X3JlZ3MsIHIyOSkp
OworCURFRklORShWTU1fUFRfUkVHU19SMzBfT0ZGU0VULAorCQkJCW9mZnNldG9mKHN0cnVjdCBr
dm1fcHRfcmVncywgcjMwKSk7CisJREVGSU5FKFZNTV9QVF9SRUdTX1IzMV9PRkZTRVQsCisJCQkJ
b2Zmc2V0b2Yoc3RydWN0IGt2bV9wdF9yZWdzLCByMzEpKTsKKwlERUZJTkUoVk1NX1BUX1JFR1Nf
QVJfQ0NWX09GRlNFVCwKKwkJCQlvZmZzZXRvZihzdHJ1Y3Qga3ZtX3B0X3JlZ3MsIGFyX2Njdikp
OworCURFRklORShWTU1fUFRfUkVHU19GNl9PRkZTRVQsCisJCQkJb2Zmc2V0b2Yoc3RydWN0IGt2
bV9wdF9yZWdzLCBmNikpOworCURFRklORShWTU1fUFRfUkVHU19GN19PRkZTRVQsCisJCQkJb2Zm
c2V0b2Yoc3RydWN0IGt2bV9wdF9yZWdzLCBmNykpOworCURFRklORShWTU1fUFRfUkVHU19GOF9P
RkZTRVQsCisJCQkJb2Zmc2V0b2Yoc3RydWN0IGt2bV9wdF9yZWdzLCBmOCkpOworCURFRklORShW
TU1fUFRfUkVHU19GOV9PRkZTRVQsCisJCQkJb2Zmc2V0b2Yoc3RydWN0IGt2bV9wdF9yZWdzLCBm
OSkpOworCURFRklORShWTU1fUFRfUkVHU19GMTBfT0ZGU0VULAorCQkJCW9mZnNldG9mKHN0cnVj
dCBrdm1fcHRfcmVncywgZjEwKSk7CisJREVGSU5FKFZNTV9QVF9SRUdTX0YxMV9PRkZTRVQsCisJ
CQkJb2Zmc2V0b2Yoc3RydWN0IGt2bV9wdF9yZWdzLCBmMTEpKTsKKwlERUZJTkUoVk1NX1BUX1JF
R1NfUjRfT0ZGU0VULAorCQkJCW9mZnNldG9mKHN0cnVjdCBrdm1fcHRfcmVncywgcjQpKTsKKwlE
RUZJTkUoVk1NX1BUX1JFR1NfUjVfT0ZGU0VULAorCQkJCW9mZnNldG9mKHN0cnVjdCBrdm1fcHRf
cmVncywgcjUpKTsKKwlERUZJTkUoVk1NX1BUX1JFR1NfUjZfT0ZGU0VULAorCQkJCW9mZnNldG9m
KHN0cnVjdCBrdm1fcHRfcmVncywgcjYpKTsKKwlERUZJTkUoVk1NX1BUX1JFR1NfUjdfT0ZGU0VU
LAorCQkJCW9mZnNldG9mKHN0cnVjdCBrdm1fcHRfcmVncywgcjcpKTsKKwlERUZJTkUoVk1NX1BU
X1JFR1NfRU1MX1VOQVRfT0ZGU0VULAorCQkJCW9mZnNldG9mKHN0cnVjdCBrdm1fcHRfcmVncywg
ZW1sX3VuYXQpKTsKKwlERUZJTkUoVk1NX1ZDUFVfSUlQQV9PRkZTRVQsCisJCQkJb2Zmc2V0b2Yo
c3RydWN0IGt2bV92Y3B1LCBhcmNoLmNyX2lpcGEpKTsKKwlERUZJTkUoVk1NX1ZDUFVfT1BDT0RF
X09GRlNFVCwKKwkJCQlvZmZzZXRvZihzdHJ1Y3Qga3ZtX3ZjcHUsIGFyY2gub3Bjb2RlKSk7CisJ
REVGSU5FKFZNTV9WQ1BVX0NBVVNFX09GRlNFVCwgb2Zmc2V0b2Yoc3RydWN0IGt2bV92Y3B1LCBh
cmNoLmNhdXNlKSk7CisJREVGSU5FKFZNTV9WQ1BVX0lTUl9PRkZTRVQsCisJCQkJb2Zmc2V0b2Yo
c3RydWN0IGt2bV92Y3B1LCBhcmNoLmNyX2lzcikpOworCURFRklORShWTU1fUFRfUkVHU19SMTZf
U0xPVCwKKwkJCQkoKChvZmZzZXRvZihzdHJ1Y3Qga3ZtX3B0X3JlZ3MsIHIxNikKKwkJCQktIHNp
emVvZihzdHJ1Y3Qga3ZtX3B0X3JlZ3MpKSA+PiAzKSAmIDB4M2YpKTsKKwlERUZJTkUoVk1NX1ZD
UFVfTU9ERV9GTEFHU19PRkZTRVQsCisJCQkJb2Zmc2V0b2Yoc3RydWN0IGt2bV92Y3B1LCBhcmNo
Lm1vZGVfZmxhZ3MpKTsKKwlERUZJTkUoVk1NX1ZDUFVfR1BfT0ZGU0VULCBvZmZzZXRvZihzdHJ1
Y3Qga3ZtX3ZjcHUsIGFyY2guX19ncCkpOworCUJMQU5LKCk7CisKKwlERUZJTkUoVk1NX1ZQRF9C
QVNFX09GRlNFVCwgb2Zmc2V0b2Yoc3RydWN0IGt2bV92Y3B1LCBhcmNoLnZwZCkpOworCURFRklO
RShWTU1fVlBEX1ZJRlNfT0ZGU0VULCBvZmZzZXRvZihzdHJ1Y3QgdnBkLCBpZnMpKTsKKwlERUZJ
TkUoVk1NX1ZMU0FQSUNfSU5TVkNfQkFTRV9PRkZTRVQsCisJCQlvZmZzZXRvZihzdHJ1Y3Qga3Zt
X3ZjcHUsIGFyY2guaW5zdmNbMF0pKTsKKwlERUZJTkUoVk1NX1ZQRF9WUFRBX09GRlNFVCwgb2Zm
c2V0b2Yoc3RydWN0IHZwZCwgcHRhKSk7CisJREVGSU5FKFZNTV9WUERfVlBTUl9PRkZTRVQsIG9m
ZnNldG9mKHN0cnVjdCB2cGQsIHZwc3IpKTsKKworCURFRklORShWTU1fQ1RYX1I0X09GRlNFVCwg
b2Zmc2V0b2YodW5pb24gY29udGV4dCwgZ3JbNF0pKTsKKwlERUZJTkUoVk1NX0NUWF9SNV9PRkZT
RVQsIG9mZnNldG9mKHVuaW9uIGNvbnRleHQsIGdyWzVdKSk7CisJREVGSU5FKFZNTV9DVFhfUjEy
X09GRlNFVCwgb2Zmc2V0b2YodW5pb24gY29udGV4dCwgZ3JbMTJdKSk7CisJREVGSU5FKFZNTV9D
VFhfUjEzX09GRlNFVCwgb2Zmc2V0b2YodW5pb24gY29udGV4dCwgZ3JbMTNdKSk7CisJREVGSU5F
KFZNTV9DVFhfS1IwX09GRlNFVCwgb2Zmc2V0b2YodW5pb24gY29udGV4dCwgYXJbMF0pKTsKKwlE
RUZJTkUoVk1NX0NUWF9LUjFfT0ZGU0VULCBvZmZzZXRvZih1bmlvbiBjb250ZXh0LCBhclsxXSkp
OworCURFRklORShWTU1fQ1RYX0IwX09GRlNFVCwgb2Zmc2V0b2YodW5pb24gY29udGV4dCwgYnJb
MF0pKTsKKwlERUZJTkUoVk1NX0NUWF9CMV9PRkZTRVQsIG9mZnNldG9mKHVuaW9uIGNvbnRleHQs
IGJyWzFdKSk7CisJREVGSU5FKFZNTV9DVFhfQjJfT0ZGU0VULCBvZmZzZXRvZih1bmlvbiBjb250
ZXh0LCBiclsyXSkpOworCURFRklORShWTU1fQ1RYX1JSMF9PRkZTRVQsIG9mZnNldG9mKHVuaW9u
IGNvbnRleHQsIHJyWzBdKSk7CisJREVGSU5FKFZNTV9DVFhfUlNDX09GRlNFVCwgb2Zmc2V0b2Yo
dW5pb24gY29udGV4dCwgYXJbMTZdKSk7CisJREVGSU5FKFZNTV9DVFhfQlNQU1RPUkVfT0ZGU0VU
LCBvZmZzZXRvZih1bmlvbiBjb250ZXh0LCBhclsxOF0pKTsKKwlERUZJTkUoVk1NX0NUWF9STkFU
X09GRlNFVCwgb2Zmc2V0b2YodW5pb24gY29udGV4dCwgYXJbMTldKSk7CisJREVGSU5FKFZNTV9D
VFhfRkNSX09GRlNFVCwgb2Zmc2V0b2YodW5pb24gY29udGV4dCwgYXJbMjFdKSk7CisJREVGSU5F
KFZNTV9DVFhfRUZMQUdfT0ZGU0VULCBvZmZzZXRvZih1bmlvbiBjb250ZXh0LCBhclsyNF0pKTsK
KwlERUZJTkUoVk1NX0NUWF9DRkxHX09GRlNFVCwgb2Zmc2V0b2YodW5pb24gY29udGV4dCwgYXJb
MjddKSk7CisJREVGSU5FKFZNTV9DVFhfRlNSX09GRlNFVCwgb2Zmc2V0b2YodW5pb24gY29udGV4
dCwgYXJbMjhdKSk7CisJREVGSU5FKFZNTV9DVFhfRklSX09GRlNFVCwgb2Zmc2V0b2YodW5pb24g
Y29udGV4dCwgYXJbMjldKSk7CisJREVGSU5FKFZNTV9DVFhfRkRSX09GRlNFVCwgb2Zmc2V0b2Yo
dW5pb24gY29udGV4dCwgYXJbMzBdKSk7CisJREVGSU5FKFZNTV9DVFhfVU5BVF9PRkZTRVQsIG9m
ZnNldG9mKHVuaW9uIGNvbnRleHQsIGFyWzM2XSkpOworCURFRklORShWTU1fQ1RYX0ZQU1JfT0ZG
U0VULCBvZmZzZXRvZih1bmlvbiBjb250ZXh0LCBhcls0MF0pKTsKKwlERUZJTkUoVk1NX0NUWF9Q
RlNfT0ZGU0VULCBvZmZzZXRvZih1bmlvbiBjb250ZXh0LCBhcls2NF0pKTsKKwlERUZJTkUoVk1N
X0NUWF9MQ19PRkZTRVQsIG9mZnNldG9mKHVuaW9uIGNvbnRleHQsIGFyWzY1XSkpOworCURFRklO
RShWTU1fQ1RYX0RDUl9PRkZTRVQsIG9mZnNldG9mKHVuaW9uIGNvbnRleHQsIGNyWzBdKSk7CisJ
REVGSU5FKFZNTV9DVFhfSVZBX09GRlNFVCwgb2Zmc2V0b2YodW5pb24gY29udGV4dCwgY3JbMl0p
KTsKKwlERUZJTkUoVk1NX0NUWF9QVEFfT0ZGU0VULCBvZmZzZXRvZih1bmlvbiBjb250ZXh0LCBj
cls4XSkpOworCURFRklORShWTU1fQ1RYX0lCUjBfT0ZGU0VULCBvZmZzZXRvZih1bmlvbiBjb250
ZXh0LCBpYnJbMF0pKTsKKwlERUZJTkUoVk1NX0NUWF9EQlIwX09GRlNFVCwgb2Zmc2V0b2YodW5p
b24gY29udGV4dCwgZGJyWzBdKSk7CisJREVGSU5FKFZNTV9DVFhfRjJfT0ZGU0VULCBvZmZzZXRv
Zih1bmlvbiBjb250ZXh0LCBmclsyXSkpOworCURFRklORShWTU1fQ1RYX0YzX09GRlNFVCwgb2Zm
c2V0b2YodW5pb24gY29udGV4dCwgZnJbM10pKTsKKwlERUZJTkUoVk1NX0NUWF9GMzJfT0ZGU0VU
LCBvZmZzZXRvZih1bmlvbiBjb250ZXh0LCBmclszMl0pKTsKKwlERUZJTkUoVk1NX0NUWF9GMzNf
T0ZGU0VULCBvZmZzZXRvZih1bmlvbiBjb250ZXh0LCBmclszM10pKTsKKwlERUZJTkUoVk1NX0NU
WF9QS1IwX09GRlNFVCwgb2Zmc2V0b2YodW5pb24gY29udGV4dCwgcGtyWzBdKSk7CisJREVGSU5F
KFZNTV9DVFhfUFNSX09GRlNFVCwgb2Zmc2V0b2YodW5pb24gY29udGV4dCwgcHNyKSk7CisJQkxB
TksoKTsKK30KLS0gCjEuNS4yCgo=

------_=_NextPart_001_01C893E6.47773CD3--
