From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Mon, 31 Mar 2008 08:30:36 +0000
Subject: [13/17][PATCH] kvm/ia64: Generate offset values for assembly code use. V8
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDC01048255@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C89309.7E58DF47"
List-Id: <linux-ia64.vger.kernel.org>
References: <42DFA526FC41B1429CE7279EF83C6BDCFF7EF3@pdsmsx415.ccr.corp.intel.com>
In-Reply-To: <42DFA526FC41B1429CE7279EF83C6BDCFF7EF3@pdsmsx415.ccr.corp.intel.com>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C89309.7E58DF47
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

From b0f8c3bf3b020077c14bebd9d052cec455ccedaf Mon Sep 17 00:00:00 2001
From: Xiantao Zhang <xiantao.zhang@intel.com>
Date: Wed, 12 Mar 2008 13:50:13 +0800
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
index 0000000..fc2ac82
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
+	DEFINE(VMM_CTX_R4_OFFSET, offsetof(context_t, gr[4]));
+	DEFINE(VMM_CTX_R5_OFFSET, offsetof(context_t, gr[5]));
+	DEFINE(VMM_CTX_R12_OFFSET, offsetof(context_t, gr[12]));
+	DEFINE(VMM_CTX_R13_OFFSET, offsetof(context_t, gr[13]));
+	DEFINE(VMM_CTX_KR0_OFFSET, offsetof(context_t, ar[0]));
+	DEFINE(VMM_CTX_KR1_OFFSET, offsetof(context_t, ar[1]));
+	DEFINE(VMM_CTX_B0_OFFSET, offsetof(context_t, br[0]));
+	DEFINE(VMM_CTX_B1_OFFSET, offsetof(context_t, br[1]));
+	DEFINE(VMM_CTX_B2_OFFSET, offsetof(context_t, br[2]));
+	DEFINE(VMM_CTX_RR0_OFFSET, offsetof(context_t, rr[0]));
+	DEFINE(VMM_CTX_RSC_OFFSET, offsetof(context_t, ar[16]));
+	DEFINE(VMM_CTX_BSPSTORE_OFFSET, offsetof(context_t, ar[18]));
+	DEFINE(VMM_CTX_RNAT_OFFSET, offsetof(context_t, ar[19]));
+	DEFINE(VMM_CTX_FCR_OFFSET, offsetof(context_t, ar[21]));
+	DEFINE(VMM_CTX_EFLAG_OFFSET, offsetof(context_t, ar[24]));
+	DEFINE(VMM_CTX_CFLG_OFFSET, offsetof(context_t, ar[27]));
+	DEFINE(VMM_CTX_FSR_OFFSET, offsetof(context_t, ar[28]));
+	DEFINE(VMM_CTX_FIR_OFFSET, offsetof(context_t, ar[29]));
+	DEFINE(VMM_CTX_FDR_OFFSET, offsetof(context_t, ar[30]));
+	DEFINE(VMM_CTX_UNAT_OFFSET, offsetof(context_t, ar[36]));
+	DEFINE(VMM_CTX_FPSR_OFFSET, offsetof(context_t, ar[40]));
+	DEFINE(VMM_CTX_PFS_OFFSET, offsetof(context_t, ar[64]));
+	DEFINE(VMM_CTX_LC_OFFSET, offsetof(context_t, ar[65]));
+	DEFINE(VMM_CTX_DCR_OFFSET, offsetof(context_t, cr[0]));
+	DEFINE(VMM_CTX_IVA_OFFSET, offsetof(context_t, cr[2]));
+	DEFINE(VMM_CTX_PTA_OFFSET, offsetof(context_t, cr[8]));
+	DEFINE(VMM_CTX_IBR0_OFFSET, offsetof(context_t, ibr[0]));
+	DEFINE(VMM_CTX_DBR0_OFFSET, offsetof(context_t, dbr[0]));
+	DEFINE(VMM_CTX_F2_OFFSET, offsetof(context_t, fr[2]));
+	DEFINE(VMM_CTX_F3_OFFSET, offsetof(context_t, fr[3]));
+	DEFINE(VMM_CTX_F32_OFFSET, offsetof(context_t, fr[32]));
+	DEFINE(VMM_CTX_F33_OFFSET, offsetof(context_t, fr[33]));
+	DEFINE(VMM_CTX_PKR0_OFFSET, offsetof(context_t, pkr[0]));
+	DEFINE(VMM_CTX_PSR_OFFSET, offsetof(context_t, psr));
+	BLANK();
+}
--=20
1.5.2

------_=_NextPart_001_01C89309.7E58DF47
Content-Type: application/octet-stream;
	name="0013-KVM-IA64-Generate-offset-values-for-assembly-code.patch"
Content-Transfer-Encoding: base64
Content-Description: 0013-KVM-IA64-Generate-offset-values-for-assembly-code.patch
Content-Disposition: attachment;
	filename="0013-KVM-IA64-Generate-offset-values-for-assembly-code.patch"

RnJvbSBiMGY4YzNiZjNiMDIwMDc3YzE0YmViZDlkMDUyY2VjNDU1Y2NlZGFmIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBYaWFudGFvIFpoYW5nIDx4aWFudGFvLnpoYW5nQGludGVsLmNv
bT4KRGF0ZTogV2VkLCAxMiBNYXIgMjAwOCAxMzo1MDoxMyArMDgwMApTdWJqZWN0OiBbUEFUQ0hd
IEtWTTpJQTY0IDogR2VuZXJhdGUgb2Zmc2V0IHZhbHVlcyBmb3IgYXNzZW1ibHkgY29kZSB1c2Uu
Cgphc20tb2Zmc2V0cy5jIHdpbGwgZ2VuZXJhdGUgb2Zmc2V0IHZhbHVlcyB1c2VkIGZvciBhc3Nl
bWJseSBjb2RlCmZvciBzb21lIGZpbGVkcyBvZiBzcGVjaWFsIHN0cnVjdHVyZXMuCgpTaWduZWQt
b2ZmLWJ5OiBBbnRob255IFh1IDxhbnRob255Lnh1QGludGVsLmNvbT4KU2lnbmVkLW9mZi1ieTog
WGlhbnRhbyBaaGFuZyA8eGlhbnRhby56aGFuZ0BpbnRlbC5jb20+Ci0tLQogYXJjaC9pYTY0L2t2
bS9hc20tb2Zmc2V0cy5jIHwgIDI1MSArKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysr
KysrKysrKysrCiAxIGZpbGVzIGNoYW5nZWQsIDI1MSBpbnNlcnRpb25zKCspLCAwIGRlbGV0aW9u
cygtKQogY3JlYXRlIG1vZGUgMTAwNjQ0IGFyY2gvaWE2NC9rdm0vYXNtLW9mZnNldHMuYwoKZGlm
ZiAtLWdpdCBhL2FyY2gvaWE2NC9rdm0vYXNtLW9mZnNldHMuYyBiL2FyY2gvaWE2NC9rdm0vYXNt
LW9mZnNldHMuYwpuZXcgZmlsZSBtb2RlIDEwMDY0NAppbmRleCAwMDAwMDAwLi5mYzJhYzgyCi0t
LSAvZGV2L251bGwKKysrIGIvYXJjaC9pYTY0L2t2bS9hc20tb2Zmc2V0cy5jCkBAIC0wLDAgKzEs
MjUxIEBACisvKgorICogYXNtLW9mZnNldHMuYyBHZW5lcmF0ZSBkZWZpbml0aW9ucyBuZWVkZWQg
YnkgYXNzZW1ibHkgbGFuZ3VhZ2UgbW9kdWxlcy4KKyAqIFRoaXMgY29kZSBnZW5lcmF0ZXMgcmF3
IGFzbSBvdXRwdXQgd2hpY2ggaXMgcG9zdC1wcm9jZXNzZWQKKyAqIHRvIGV4dHJhY3QgYW5kIGZv
cm1hdCB0aGUgcmVxdWlyZWQgZGF0YS4KKyAqCisgKiBBbnRob255IFh1ICAgIDxhbnRob255Lnh1
QGludGVsLmNvbT4KKyAqIFhpYW50YW8gWmhhbmcgPHhpYW50YW8uemhhbmdAaW50ZWwuY29tPgor
ICogQ29weXJpZ2h0IChjKSAyMDA3IEludGVsIENvcnBvcmF0aW9uICBLVk0gc3VwcG9ydC4KKyAq
CisgKiBUaGlzIHByb2dyYW0gaXMgZnJlZSBzb2Z0d2FyZTsgeW91IGNhbiByZWRpc3RyaWJ1dGUg
aXQgYW5kL29yIG1vZGlmeSBpdAorICogdW5kZXIgdGhlIHRlcm1zIGFuZCBjb25kaXRpb25zIG9m
IHRoZSBHTlUgR2VuZXJhbCBQdWJsaWMgTGljZW5zZSwKKyAqIHZlcnNpb24gMiwgYXMgcHVibGlz
aGVkIGJ5IHRoZSBGcmVlIFNvZnR3YXJlIEZvdW5kYXRpb24uCisgKgorICogVGhpcyBwcm9ncmFt
IGlzIGRpc3RyaWJ1dGVkIGluIHRoZSBob3BlIGl0IHdpbGwgYmUgdXNlZnVsLCBidXQgV0lUSE9V
VAorICogQU5ZIFdBUlJBTlRZOyB3aXRob3V0IGV2ZW4gdGhlIGltcGxpZWQgd2FycmFudHkgb2Yg
TUVSQ0hBTlRBQklMSVRZIG9yCisgKiBGSVRORVNTIEZPUiBBIFBBUlRJQ1VMQVIgUFVSUE9TRS4g
IFNlZSB0aGUgR05VIEdlbmVyYWwgUHVibGljIExpY2Vuc2UgZm9yCisgKiBtb3JlIGRldGFpbHMu
CisgKgorICogWW91IHNob3VsZCBoYXZlIHJlY2VpdmVkIGEgY29weSBvZiB0aGUgR05VIEdlbmVy
YWwgUHVibGljIExpY2Vuc2UgYWxvbmcgd2l0aAorICogdGhpcyBwcm9ncmFtOyBpZiBub3QsIHdy
aXRlIHRvIHRoZSBGcmVlIFNvZnR3YXJlIEZvdW5kYXRpb24sIEluYy4sIDU5IFRlbXBsZQorICog
UGxhY2UgLSBTdWl0ZSAzMzAsIEJvc3RvbiwgTUEgMDIxMTEtMTMwNyBVU0EuCisgKgorICovCisK
KyNpbmNsdWRlIDxsaW51eC9hdXRvY29uZi5oPgorI2luY2x1ZGUgPGxpbnV4L2t2bV9ob3N0Lmg+
CisKKyNpbmNsdWRlICJ2Y3B1LmgiCisKKyNkZWZpbmUgdGFza19zdHJ1Y3Qga3ZtX3ZjcHUKKwor
I2RlZmluZSBERUZJTkUoc3ltLCB2YWwpIFwKKwlhc20gdm9sYXRpbGUoIlxuLT4iICNzeW0gIiAo
JTApICIgI3ZhbCA6IDogImkiICh2YWwpKQorCisjZGVmaW5lIEJMQU5LKCkgYXNtIHZvbGF0aWxl
KCJcbi0+IiA6IDopCisKKyNkZWZpbmUgT0ZGU0VUKF9zeW0sIF9zdHIsIF9tZW0pIFwKKyAgICBE
RUZJTkUoX3N5bSwgb2Zmc2V0b2YoX3N0ciwgX21lbSkpOworCit2b2lkIGZvbyh2b2lkKQorewor
CURFRklORShWTU1fVEFTS19TSVpFLCBzaXplb2Yoc3RydWN0IGt2bV92Y3B1KSk7CisJREVGSU5F
KFZNTV9QVF9SRUdTX1NJWkUsIHNpemVvZihzdHJ1Y3Qga3ZtX3B0X3JlZ3MpKTsKKworCUJMQU5L
KCk7CisKKwlERUZJTkUoVk1NX1ZDUFVfTUVUQV9SUjBfT0ZGU0VULAorCQkJb2Zmc2V0b2Yoc3Ry
dWN0IGt2bV92Y3B1LCBhcmNoLm1ldGFwaHlzaWNhbF9ycjApKTsKKwlERUZJTkUoVk1NX1ZDUFVf
TUVUQV9TQVZFRF9SUjBfT0ZGU0VULAorCQkJb2Zmc2V0b2Yoc3RydWN0IGt2bV92Y3B1LAorCQkJ
CWFyY2gubWV0YXBoeXNpY2FsX3NhdmVkX3JyMCkpOworCURFRklORShWTU1fVkNQVV9WUlIwX09G
RlNFVCwKKwkJCW9mZnNldG9mKHN0cnVjdCBrdm1fdmNwdSwgYXJjaC52cnJbMF0pKTsKKwlERUZJ
TkUoVk1NX1ZQRF9JUlIwX09GRlNFVCwKKwkJCW9mZnNldG9mKHN0cnVjdCB2cGQsIGlyclswXSkp
OworCURFRklORShWTU1fVkNQVV9JVENfQ0hFQ0tfT0ZGU0VULAorCQkJb2Zmc2V0b2Yoc3RydWN0
IGt2bV92Y3B1LCBhcmNoLml0Y19jaGVjaykpOworCURFRklORShWTU1fVkNQVV9JUlFfQ0hFQ0tf
T0ZGU0VULAorCQkJb2Zmc2V0b2Yoc3RydWN0IGt2bV92Y3B1LCBhcmNoLmlycV9jaGVjaykpOwor
CURFRklORShWTU1fVlBEX1ZIUElfT0ZGU0VULAorCQkJb2Zmc2V0b2Yoc3RydWN0IHZwZCwgdmhw
aSkpOworCURFRklORShWTU1fVkNQVV9WU0FfQkFTRV9PRkZTRVQsCisJCQlvZmZzZXRvZihzdHJ1
Y3Qga3ZtX3ZjcHUsIGFyY2gudnNhX2Jhc2UpKTsKKwlERUZJTkUoVk1NX1ZDUFVfVlBEX09GRlNF
VCwKKwkJCW9mZnNldG9mKHN0cnVjdCBrdm1fdmNwdSwgYXJjaC52cGQpKTsKKwlERUZJTkUoVk1N
X1ZDUFVfSVJRX0NIRUNLLAorCQkJb2Zmc2V0b2Yoc3RydWN0IGt2bV92Y3B1LCBhcmNoLmlycV9j
aGVjaykpOworCURFRklORShWTU1fVkNQVV9USU1FUl9QRU5ESU5HLAorCQkJb2Zmc2V0b2Yoc3Ry
dWN0IGt2bV92Y3B1LCBhcmNoLnRpbWVyX3BlbmRpbmcpKTsKKwlERUZJTkUoVk1NX1ZDUFVfTUVU
QV9TQVZFRF9SUjBfT0ZGU0VULAorCQkJb2Zmc2V0b2Yoc3RydWN0IGt2bV92Y3B1LCBhcmNoLm1l
dGFwaHlzaWNhbF9zYXZlZF9ycjApKTsKKwlERUZJTkUoVk1NX1ZDUFVfTU9ERV9GTEFHU19PRkZT
RVQsCisJCQlvZmZzZXRvZihzdHJ1Y3Qga3ZtX3ZjcHUsIGFyY2gubW9kZV9mbGFncykpOworCURF
RklORShWTU1fVkNQVV9JVENfT0ZTX09GRlNFVCwKKwkJCW9mZnNldG9mKHN0cnVjdCBrdm1fdmNw
dSwgYXJjaC5pdGNfb2Zmc2V0KSk7CisJREVGSU5FKFZNTV9WQ1BVX0xBU1RfSVRDX09GRlNFVCwK
KwkJCW9mZnNldG9mKHN0cnVjdCBrdm1fdmNwdSwgYXJjaC5sYXN0X2l0YykpOworCURFRklORShW
TU1fVkNQVV9TQVZFRF9HUF9PRkZTRVQsCisJCQlvZmZzZXRvZihzdHJ1Y3Qga3ZtX3ZjcHUsIGFy
Y2guc2F2ZWRfZ3ApKTsKKworCUJMQU5LKCk7CisKKwlERUZJTkUoVk1NX1BUX1JFR1NfQjZfT0ZG
U0VULAorCQkJCW9mZnNldG9mKHN0cnVjdCBrdm1fcHRfcmVncywgYjYpKTsKKwlERUZJTkUoVk1N
X1BUX1JFR1NfQjdfT0ZGU0VULAorCQkJCW9mZnNldG9mKHN0cnVjdCBrdm1fcHRfcmVncywgYjcp
KTsKKwlERUZJTkUoVk1NX1BUX1JFR1NfQVJfQ1NEX09GRlNFVCwKKwkJCQlvZmZzZXRvZihzdHJ1
Y3Qga3ZtX3B0X3JlZ3MsIGFyX2NzZCkpOworCURFRklORShWTU1fUFRfUkVHU19BUl9TU0RfT0ZG
U0VULAorCQkJCW9mZnNldG9mKHN0cnVjdCBrdm1fcHRfcmVncywgYXJfc3NkKSk7CisJREVGSU5F
KFZNTV9QVF9SRUdTX1I4X09GRlNFVCwKKwkJCQlvZmZzZXRvZihzdHJ1Y3Qga3ZtX3B0X3JlZ3Ms
IHI4KSk7CisJREVGSU5FKFZNTV9QVF9SRUdTX1I5X09GRlNFVCwKKwkJCQlvZmZzZXRvZihzdHJ1
Y3Qga3ZtX3B0X3JlZ3MsIHI5KSk7CisJREVGSU5FKFZNTV9QVF9SRUdTX1IxMF9PRkZTRVQsCisJ
CQkJb2Zmc2V0b2Yoc3RydWN0IGt2bV9wdF9yZWdzLCByMTApKTsKKwlERUZJTkUoVk1NX1BUX1JF
R1NfUjExX09GRlNFVCwKKwkJCQlvZmZzZXRvZihzdHJ1Y3Qga3ZtX3B0X3JlZ3MsIHIxMSkpOwor
CURFRklORShWTU1fUFRfUkVHU19DUl9JUFNSX09GRlNFVCwKKwkJCQlvZmZzZXRvZihzdHJ1Y3Qg
a3ZtX3B0X3JlZ3MsIGNyX2lwc3IpKTsKKwlERUZJTkUoVk1NX1BUX1JFR1NfQ1JfSUlQX09GRlNF
VCwKKwkJCQlvZmZzZXRvZihzdHJ1Y3Qga3ZtX3B0X3JlZ3MsIGNyX2lpcCkpOworCURFRklORShW
TU1fUFRfUkVHU19DUl9JRlNfT0ZGU0VULAorCQkJCW9mZnNldG9mKHN0cnVjdCBrdm1fcHRfcmVn
cywgY3JfaWZzKSk7CisJREVGSU5FKFZNTV9QVF9SRUdTX0FSX1VOQVRfT0ZGU0VULAorCQkJCW9m
ZnNldG9mKHN0cnVjdCBrdm1fcHRfcmVncywgYXJfdW5hdCkpOworCURFRklORShWTU1fUFRfUkVH
U19BUl9QRlNfT0ZGU0VULAorCQkJCW9mZnNldG9mKHN0cnVjdCBrdm1fcHRfcmVncywgYXJfcGZz
KSk7CisJREVGSU5FKFZNTV9QVF9SRUdTX0FSX1JTQ19PRkZTRVQsCisJCQkJb2Zmc2V0b2Yoc3Ry
dWN0IGt2bV9wdF9yZWdzLCBhcl9yc2MpKTsKKwlERUZJTkUoVk1NX1BUX1JFR1NfQVJfUk5BVF9P
RkZTRVQsCisJCQkJb2Zmc2V0b2Yoc3RydWN0IGt2bV9wdF9yZWdzLCBhcl9ybmF0KSk7CisKKwlE
RUZJTkUoVk1NX1BUX1JFR1NfQVJfQlNQU1RPUkVfT0ZGU0VULAorCQkJCW9mZnNldG9mKHN0cnVj
dCBrdm1fcHRfcmVncywgYXJfYnNwc3RvcmUpKTsKKwlERUZJTkUoVk1NX1BUX1JFR1NfUFJfT0ZG
U0VULAorCQkJCW9mZnNldG9mKHN0cnVjdCBrdm1fcHRfcmVncywgcHIpKTsKKwlERUZJTkUoVk1N
X1BUX1JFR1NfQjBfT0ZGU0VULAorCQkJCW9mZnNldG9mKHN0cnVjdCBrdm1fcHRfcmVncywgYjAp
KTsKKwlERUZJTkUoVk1NX1BUX1JFR1NfTE9BRFJTX09GRlNFVCwKKwkJCQlvZmZzZXRvZihzdHJ1
Y3Qga3ZtX3B0X3JlZ3MsIGxvYWRycykpOworCURFRklORShWTU1fUFRfUkVHU19SMV9PRkZTRVQs
CisJCQkJb2Zmc2V0b2Yoc3RydWN0IGt2bV9wdF9yZWdzLCByMSkpOworCURFRklORShWTU1fUFRf
UkVHU19SMTJfT0ZGU0VULAorCQkJCW9mZnNldG9mKHN0cnVjdCBrdm1fcHRfcmVncywgcjEyKSk7
CisJREVGSU5FKFZNTV9QVF9SRUdTX1IxM19PRkZTRVQsCisJCQkJb2Zmc2V0b2Yoc3RydWN0IGt2
bV9wdF9yZWdzLCByMTMpKTsKKwlERUZJTkUoVk1NX1BUX1JFR1NfQVJfRlBTUl9PRkZTRVQsCisJ
CQkJb2Zmc2V0b2Yoc3RydWN0IGt2bV9wdF9yZWdzLCBhcl9mcHNyKSk7CisJREVGSU5FKFZNTV9Q
VF9SRUdTX1IxNV9PRkZTRVQsCisJCQkJb2Zmc2V0b2Yoc3RydWN0IGt2bV9wdF9yZWdzLCByMTUp
KTsKKwlERUZJTkUoVk1NX1BUX1JFR1NfUjE0X09GRlNFVCwKKwkJCQlvZmZzZXRvZihzdHJ1Y3Qg
a3ZtX3B0X3JlZ3MsIHIxNCkpOworCURFRklORShWTU1fUFRfUkVHU19SMl9PRkZTRVQsCisJCQkJ
b2Zmc2V0b2Yoc3RydWN0IGt2bV9wdF9yZWdzLCByMikpOworCURFRklORShWTU1fUFRfUkVHU19S
M19PRkZTRVQsCisJCQkJb2Zmc2V0b2Yoc3RydWN0IGt2bV9wdF9yZWdzLCByMykpOworCURFRklO
RShWTU1fUFRfUkVHU19SMTZfT0ZGU0VULAorCQkJCW9mZnNldG9mKHN0cnVjdCBrdm1fcHRfcmVn
cywgcjE2KSk7CisJREVGSU5FKFZNTV9QVF9SRUdTX1IxN19PRkZTRVQsCisJCQkJb2Zmc2V0b2Yo
c3RydWN0IGt2bV9wdF9yZWdzLCByMTcpKTsKKwlERUZJTkUoVk1NX1BUX1JFR1NfUjE4X09GRlNF
VCwKKwkJCQlvZmZzZXRvZihzdHJ1Y3Qga3ZtX3B0X3JlZ3MsIHIxOCkpOworCURFRklORShWTU1f
UFRfUkVHU19SMTlfT0ZGU0VULAorCQkJCW9mZnNldG9mKHN0cnVjdCBrdm1fcHRfcmVncywgcjE5
KSk7CisJREVGSU5FKFZNTV9QVF9SRUdTX1IyMF9PRkZTRVQsCisJCQkJb2Zmc2V0b2Yoc3RydWN0
IGt2bV9wdF9yZWdzLCByMjApKTsKKwlERUZJTkUoVk1NX1BUX1JFR1NfUjIxX09GRlNFVCwKKwkJ
CQlvZmZzZXRvZihzdHJ1Y3Qga3ZtX3B0X3JlZ3MsIHIyMSkpOworCURFRklORShWTU1fUFRfUkVH
U19SMjJfT0ZGU0VULAorCQkJCW9mZnNldG9mKHN0cnVjdCBrdm1fcHRfcmVncywgcjIyKSk7CisJ
REVGSU5FKFZNTV9QVF9SRUdTX1IyM19PRkZTRVQsCisJCQkJb2Zmc2V0b2Yoc3RydWN0IGt2bV9w
dF9yZWdzLCByMjMpKTsKKwlERUZJTkUoVk1NX1BUX1JFR1NfUjI0X09GRlNFVCwKKwkJCQlvZmZz
ZXRvZihzdHJ1Y3Qga3ZtX3B0X3JlZ3MsIHIyNCkpOworCURFRklORShWTU1fUFRfUkVHU19SMjVf
T0ZGU0VULAorCQkJCW9mZnNldG9mKHN0cnVjdCBrdm1fcHRfcmVncywgcjI1KSk7CisJREVGSU5F
KFZNTV9QVF9SRUdTX1IyNl9PRkZTRVQsCisJCQkJb2Zmc2V0b2Yoc3RydWN0IGt2bV9wdF9yZWdz
LCByMjYpKTsKKwlERUZJTkUoVk1NX1BUX1JFR1NfUjI3X09GRlNFVCwKKwkJCQlvZmZzZXRvZihz
dHJ1Y3Qga3ZtX3B0X3JlZ3MsIHIyNykpOworCURFRklORShWTU1fUFRfUkVHU19SMjhfT0ZGU0VU
LAorCQkJCW9mZnNldG9mKHN0cnVjdCBrdm1fcHRfcmVncywgcjI4KSk7CisJREVGSU5FKFZNTV9Q
VF9SRUdTX1IyOV9PRkZTRVQsCisJCQkJb2Zmc2V0b2Yoc3RydWN0IGt2bV9wdF9yZWdzLCByMjkp
KTsKKwlERUZJTkUoVk1NX1BUX1JFR1NfUjMwX09GRlNFVCwKKwkJCQlvZmZzZXRvZihzdHJ1Y3Qg
a3ZtX3B0X3JlZ3MsIHIzMCkpOworCURFRklORShWTU1fUFRfUkVHU19SMzFfT0ZGU0VULAorCQkJ
CW9mZnNldG9mKHN0cnVjdCBrdm1fcHRfcmVncywgcjMxKSk7CisJREVGSU5FKFZNTV9QVF9SRUdT
X0FSX0NDVl9PRkZTRVQsCisJCQkJb2Zmc2V0b2Yoc3RydWN0IGt2bV9wdF9yZWdzLCBhcl9jY3Yp
KTsKKwlERUZJTkUoVk1NX1BUX1JFR1NfRjZfT0ZGU0VULAorCQkJCW9mZnNldG9mKHN0cnVjdCBr
dm1fcHRfcmVncywgZjYpKTsKKwlERUZJTkUoVk1NX1BUX1JFR1NfRjdfT0ZGU0VULAorCQkJCW9m
ZnNldG9mKHN0cnVjdCBrdm1fcHRfcmVncywgZjcpKTsKKwlERUZJTkUoVk1NX1BUX1JFR1NfRjhf
T0ZGU0VULAorCQkJCW9mZnNldG9mKHN0cnVjdCBrdm1fcHRfcmVncywgZjgpKTsKKwlERUZJTkUo
Vk1NX1BUX1JFR1NfRjlfT0ZGU0VULAorCQkJCW9mZnNldG9mKHN0cnVjdCBrdm1fcHRfcmVncywg
ZjkpKTsKKwlERUZJTkUoVk1NX1BUX1JFR1NfRjEwX09GRlNFVCwKKwkJCQlvZmZzZXRvZihzdHJ1
Y3Qga3ZtX3B0X3JlZ3MsIGYxMCkpOworCURFRklORShWTU1fUFRfUkVHU19GMTFfT0ZGU0VULAor
CQkJCW9mZnNldG9mKHN0cnVjdCBrdm1fcHRfcmVncywgZjExKSk7CisJREVGSU5FKFZNTV9QVF9S
RUdTX1I0X09GRlNFVCwKKwkJCQlvZmZzZXRvZihzdHJ1Y3Qga3ZtX3B0X3JlZ3MsIHI0KSk7CisJ
REVGSU5FKFZNTV9QVF9SRUdTX1I1X09GRlNFVCwKKwkJCQlvZmZzZXRvZihzdHJ1Y3Qga3ZtX3B0
X3JlZ3MsIHI1KSk7CisJREVGSU5FKFZNTV9QVF9SRUdTX1I2X09GRlNFVCwKKwkJCQlvZmZzZXRv
ZihzdHJ1Y3Qga3ZtX3B0X3JlZ3MsIHI2KSk7CisJREVGSU5FKFZNTV9QVF9SRUdTX1I3X09GRlNF
VCwKKwkJCQlvZmZzZXRvZihzdHJ1Y3Qga3ZtX3B0X3JlZ3MsIHI3KSk7CisJREVGSU5FKFZNTV9Q
VF9SRUdTX0VNTF9VTkFUX09GRlNFVCwKKwkJCQlvZmZzZXRvZihzdHJ1Y3Qga3ZtX3B0X3JlZ3Ms
IGVtbF91bmF0KSk7CisJREVGSU5FKFZNTV9WQ1BVX0lJUEFfT0ZGU0VULAorCQkJCW9mZnNldG9m
KHN0cnVjdCBrdm1fdmNwdSwgYXJjaC5jcl9paXBhKSk7CisJREVGSU5FKFZNTV9WQ1BVX09QQ09E
RV9PRkZTRVQsCisJCQkJb2Zmc2V0b2Yoc3RydWN0IGt2bV92Y3B1LCBhcmNoLm9wY29kZSkpOwor
CURFRklORShWTU1fVkNQVV9DQVVTRV9PRkZTRVQsIG9mZnNldG9mKHN0cnVjdCBrdm1fdmNwdSwg
YXJjaC5jYXVzZSkpOworCURFRklORShWTU1fVkNQVV9JU1JfT0ZGU0VULAorCQkJCW9mZnNldG9m
KHN0cnVjdCBrdm1fdmNwdSwgYXJjaC5jcl9pc3IpKTsKKwlERUZJTkUoVk1NX1BUX1JFR1NfUjE2
X1NMT1QsCisJCQkJKCgob2Zmc2V0b2Yoc3RydWN0IGt2bV9wdF9yZWdzLCByMTYpCisJCQkJLSBz
aXplb2Yoc3RydWN0IGt2bV9wdF9yZWdzKSkgPj4gMykgJiAweDNmKSk7CisJREVGSU5FKFZNTV9W
Q1BVX01PREVfRkxBR1NfT0ZGU0VULAorCQkJCW9mZnNldG9mKHN0cnVjdCBrdm1fdmNwdSwgYXJj
aC5tb2RlX2ZsYWdzKSk7CisJREVGSU5FKFZNTV9WQ1BVX0dQX09GRlNFVCwgb2Zmc2V0b2Yoc3Ry
dWN0IGt2bV92Y3B1LCBhcmNoLl9fZ3ApKTsKKwlCTEFOSygpOworCisJREVGSU5FKFZNTV9WUERf
QkFTRV9PRkZTRVQsIG9mZnNldG9mKHN0cnVjdCBrdm1fdmNwdSwgYXJjaC52cGQpKTsKKwlERUZJ
TkUoVk1NX1ZQRF9WSUZTX09GRlNFVCwgb2Zmc2V0b2Yoc3RydWN0IHZwZCwgaWZzKSk7CisJREVG
SU5FKFZNTV9WTFNBUElDX0lOU1ZDX0JBU0VfT0ZGU0VULAorCQkJb2Zmc2V0b2Yoc3RydWN0IGt2
bV92Y3B1LCBhcmNoLmluc3ZjWzBdKSk7CisJREVGSU5FKFZNTV9WUERfVlBUQV9PRkZTRVQsIG9m
ZnNldG9mKHN0cnVjdCB2cGQsIHB0YSkpOworCURFRklORShWTU1fVlBEX1ZQU1JfT0ZGU0VULCBv
ZmZzZXRvZihzdHJ1Y3QgdnBkLCB2cHNyKSk7CisKKwlERUZJTkUoVk1NX0NUWF9SNF9PRkZTRVQs
IG9mZnNldG9mKGNvbnRleHRfdCwgZ3JbNF0pKTsKKwlERUZJTkUoVk1NX0NUWF9SNV9PRkZTRVQs
IG9mZnNldG9mKGNvbnRleHRfdCwgZ3JbNV0pKTsKKwlERUZJTkUoVk1NX0NUWF9SMTJfT0ZGU0VU
LCBvZmZzZXRvZihjb250ZXh0X3QsIGdyWzEyXSkpOworCURFRklORShWTU1fQ1RYX1IxM19PRkZT
RVQsIG9mZnNldG9mKGNvbnRleHRfdCwgZ3JbMTNdKSk7CisJREVGSU5FKFZNTV9DVFhfS1IwX09G
RlNFVCwgb2Zmc2V0b2YoY29udGV4dF90LCBhclswXSkpOworCURFRklORShWTU1fQ1RYX0tSMV9P
RkZTRVQsIG9mZnNldG9mKGNvbnRleHRfdCwgYXJbMV0pKTsKKwlERUZJTkUoVk1NX0NUWF9CMF9P
RkZTRVQsIG9mZnNldG9mKGNvbnRleHRfdCwgYnJbMF0pKTsKKwlERUZJTkUoVk1NX0NUWF9CMV9P
RkZTRVQsIG9mZnNldG9mKGNvbnRleHRfdCwgYnJbMV0pKTsKKwlERUZJTkUoVk1NX0NUWF9CMl9P
RkZTRVQsIG9mZnNldG9mKGNvbnRleHRfdCwgYnJbMl0pKTsKKwlERUZJTkUoVk1NX0NUWF9SUjBf
T0ZGU0VULCBvZmZzZXRvZihjb250ZXh0X3QsIHJyWzBdKSk7CisJREVGSU5FKFZNTV9DVFhfUlND
X09GRlNFVCwgb2Zmc2V0b2YoY29udGV4dF90LCBhclsxNl0pKTsKKwlERUZJTkUoVk1NX0NUWF9C
U1BTVE9SRV9PRkZTRVQsIG9mZnNldG9mKGNvbnRleHRfdCwgYXJbMThdKSk7CisJREVGSU5FKFZN
TV9DVFhfUk5BVF9PRkZTRVQsIG9mZnNldG9mKGNvbnRleHRfdCwgYXJbMTldKSk7CisJREVGSU5F
KFZNTV9DVFhfRkNSX09GRlNFVCwgb2Zmc2V0b2YoY29udGV4dF90LCBhclsyMV0pKTsKKwlERUZJ
TkUoVk1NX0NUWF9FRkxBR19PRkZTRVQsIG9mZnNldG9mKGNvbnRleHRfdCwgYXJbMjRdKSk7CisJ
REVGSU5FKFZNTV9DVFhfQ0ZMR19PRkZTRVQsIG9mZnNldG9mKGNvbnRleHRfdCwgYXJbMjddKSk7
CisJREVGSU5FKFZNTV9DVFhfRlNSX09GRlNFVCwgb2Zmc2V0b2YoY29udGV4dF90LCBhclsyOF0p
KTsKKwlERUZJTkUoVk1NX0NUWF9GSVJfT0ZGU0VULCBvZmZzZXRvZihjb250ZXh0X3QsIGFyWzI5
XSkpOworCURFRklORShWTU1fQ1RYX0ZEUl9PRkZTRVQsIG9mZnNldG9mKGNvbnRleHRfdCwgYXJb
MzBdKSk7CisJREVGSU5FKFZNTV9DVFhfVU5BVF9PRkZTRVQsIG9mZnNldG9mKGNvbnRleHRfdCwg
YXJbMzZdKSk7CisJREVGSU5FKFZNTV9DVFhfRlBTUl9PRkZTRVQsIG9mZnNldG9mKGNvbnRleHRf
dCwgYXJbNDBdKSk7CisJREVGSU5FKFZNTV9DVFhfUEZTX09GRlNFVCwgb2Zmc2V0b2YoY29udGV4
dF90LCBhcls2NF0pKTsKKwlERUZJTkUoVk1NX0NUWF9MQ19PRkZTRVQsIG9mZnNldG9mKGNvbnRl
eHRfdCwgYXJbNjVdKSk7CisJREVGSU5FKFZNTV9DVFhfRENSX09GRlNFVCwgb2Zmc2V0b2YoY29u
dGV4dF90LCBjclswXSkpOworCURFRklORShWTU1fQ1RYX0lWQV9PRkZTRVQsIG9mZnNldG9mKGNv
bnRleHRfdCwgY3JbMl0pKTsKKwlERUZJTkUoVk1NX0NUWF9QVEFfT0ZGU0VULCBvZmZzZXRvZihj
b250ZXh0X3QsIGNyWzhdKSk7CisJREVGSU5FKFZNTV9DVFhfSUJSMF9PRkZTRVQsIG9mZnNldG9m
KGNvbnRleHRfdCwgaWJyWzBdKSk7CisJREVGSU5FKFZNTV9DVFhfREJSMF9PRkZTRVQsIG9mZnNl
dG9mKGNvbnRleHRfdCwgZGJyWzBdKSk7CisJREVGSU5FKFZNTV9DVFhfRjJfT0ZGU0VULCBvZmZz
ZXRvZihjb250ZXh0X3QsIGZyWzJdKSk7CisJREVGSU5FKFZNTV9DVFhfRjNfT0ZGU0VULCBvZmZz
ZXRvZihjb250ZXh0X3QsIGZyWzNdKSk7CisJREVGSU5FKFZNTV9DVFhfRjMyX09GRlNFVCwgb2Zm
c2V0b2YoY29udGV4dF90LCBmclszMl0pKTsKKwlERUZJTkUoVk1NX0NUWF9GMzNfT0ZGU0VULCBv
ZmZzZXRvZihjb250ZXh0X3QsIGZyWzMzXSkpOworCURFRklORShWTU1fQ1RYX1BLUjBfT0ZGU0VU
LCBvZmZzZXRvZihjb250ZXh0X3QsIHBrclswXSkpOworCURFRklORShWTU1fQ1RYX1BTUl9PRkZT
RVQsIG9mZnNldG9mKGNvbnRleHRfdCwgcHNyKSk7CisJQkxBTksoKTsKK30KLS0gCjEuNS4yCgo=

------_=_NextPart_001_01C89309.7E58DF47--
