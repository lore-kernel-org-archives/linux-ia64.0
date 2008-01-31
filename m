From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Thu, 31 Jan 2008 10:29:32 +0000
Subject: [PATCH][09]VMM module interfaces.
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDCD31FCC@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C863F4.2B3C06BF"
List-Id: <linux-ia64.vger.kernel.org>
To: Avi Kivity <avi-atKUWr5tajBWk0Htik3J/w@public.gmane.org>, "Luck, Tony" <tony.luck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, "Xu, Anthony" <anthony.xu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, "Zhang, Xiantao" <xiantao.zhang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: kvm-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kvm-ia64-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C863F4.2B3C06BF
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

From: Zhang Xiantao <xiantao.zhang@intel.com>
Date: Tue, 29 Jan 2008 13:31:55 +0800
Subject: [PATCH] kvm/ia64: VMM module interfaces.

vmm.c adds the interfaces with kvm/module, and initialize global data
area.
Signed-off-by: Xiantao Zhang<xiantao.zhang@intel.com>
---
 arch/ia64/kvm/vmm.c |   57
+++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 57 insertions(+), 0 deletions(-)
 create mode 100644 arch/ia64/kvm/vmm.c

diff --git a/arch/ia64/kvm/vmm.c b/arch/ia64/kvm/vmm.c
new file mode 100644
index 0000000..0973c68
--- /dev/null
+++ b/arch/ia64/kvm/vmm.c
@@ -0,0 +1,57 @@
+/*
+ * vmm.c: vmm module interface with kvm module
+ *
+ * Copyright (c) 2007, Intel Corporation.
+ *
+ *  Xiantao Zhang (xiantao.zhang@intel.com)
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
+ */
+
+
+#include<linux/module.h>
+#include<asm/fpswa.h>
+
+#include "vcpu.h"
+
+MODULE_AUTHOR("Intel");
+MODULE_LICENSE("GPL");
+
+extern char kvm_ia64_ivt;
+extern fpswa_interface_t *vmm_fpswa_interface;
+
+struct kvm_vmm_info vmm_info =3D {
+	.module	     =3D THIS_MODULE,
+	.vmm_entry   =3D vmm_entry,
+	.tramp_entry =3D vmm_trampoline,
+	.vmm_ivt     =3D (unsigned long)&kvm_ia64_ivt,
+};
+
+static int __init  kvm_vmm_init(void)
+{
+
+	vmm_fpswa_interface =3D fpswa_interface;
+
+	/*Register vmm data to kvm side*/
+	return kvm_init(&vmm_info, 1024, THIS_MODULE);
+}
+
+static void __exit kvm_vmm_exit(void)
+{
+	kvm_exit();
+	return ;
+}
+
+module_init(kvm_vmm_init)
+module_exit(kvm_vmm_exit)
--=20
1.5.1

------_=_NextPart_001_01C863F4.2B3C06BF
Content-Type: application/octet-stream;
	name="0009-kvm-ia64-VMM-module-interfaces.patch"
Content-Transfer-Encoding: base64
Content-Description: 0009-kvm-ia64-VMM-module-interfaces.patch
Content-Disposition: attachment;
	filename="0009-kvm-ia64-VMM-module-interfaces.patch"

RnJvbSBmN2NmNzM2MzA3YTJkMjE4OTM1YzQ2NDQ0NTE0ZDg2ODdiNzhjNGM3IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBaaGFuZyBYaWFudGFvIDx4aWFudGFvLnpoYW5nQGludGVsLmNv
bT4KRGF0ZTogVHVlLCAyOSBKYW4gMjAwOCAxMzozMTo1NSArMDgwMApTdWJqZWN0OiBbUEFUQ0hd
IGt2bS9pYTY0OiBWTU0gbW9kdWxlIGludGVyZmFjZXMuCgp2bW0uYyBhZGRzIHRoZSBpbnRlcmZh
Y2VzIHdpdGgga3ZtL21vZHVsZSwgYW5kIGluaXRpYWxpemUgZ2xvYmFsIGRhdGEgYXJlYS4KU2ln
bmVkLW9mZi1ieTogWGlhbnRhbyBaaGFuZzx4aWFudGFvLnpoYW5nQGludGVsLmNvbT4KLS0tCiBh
cmNoL2lhNjQva3ZtL3ZtbS5jIHwgICA1NyArKysrKysrKysrKysrKysrKysrKysrKysrKysrKysr
KysrKysrKysrKysrKysrKysrKysKIDEgZmlsZXMgY2hhbmdlZCwgNTcgaW5zZXJ0aW9ucygrKSwg
MCBkZWxldGlvbnMoLSkKIGNyZWF0ZSBtb2RlIDEwMDY0NCBhcmNoL2lhNjQva3ZtL3ZtbS5jCgpk
aWZmIC0tZ2l0IGEvYXJjaC9pYTY0L2t2bS92bW0uYyBiL2FyY2gvaWE2NC9rdm0vdm1tLmMKbmV3
IGZpbGUgbW9kZSAxMDA2NDQKaW5kZXggMDAwMDAwMC4uMDk3M2M2OAotLS0gL2Rldi9udWxsCisr
KyBiL2FyY2gvaWE2NC9rdm0vdm1tLmMKQEAgLTAsMCArMSw1NyBAQAorLyoKKyAqIHZtbS5jOiB2
bW0gbW9kdWxlIGludGVyZmFjZSB3aXRoIGt2bSBtb2R1bGUKKyAqCisgKiBDb3B5cmlnaHQgKGMp
IDIwMDcsIEludGVsIENvcnBvcmF0aW9uLgorICoKKyAqICBYaWFudGFvIFpoYW5nICh4aWFudGFv
LnpoYW5nQGludGVsLmNvbSkKKyAqCisgKiBUaGlzIHByb2dyYW0gaXMgZnJlZSBzb2Z0d2FyZTsg
eW91IGNhbiByZWRpc3RyaWJ1dGUgaXQgYW5kL29yIG1vZGlmeSBpdAorICogdW5kZXIgdGhlIHRl
cm1zIGFuZCBjb25kaXRpb25zIG9mIHRoZSBHTlUgR2VuZXJhbCBQdWJsaWMgTGljZW5zZSwKKyAq
IHZlcnNpb24gMiwgYXMgcHVibGlzaGVkIGJ5IHRoZSBGcmVlIFNvZnR3YXJlIEZvdW5kYXRpb24u
CisgKgorICogVGhpcyBwcm9ncmFtIGlzIGRpc3RyaWJ1dGVkIGluIHRoZSBob3BlIGl0IHdpbGwg
YmUgdXNlZnVsLCBidXQgV0lUSE9VVAorICogQU5ZIFdBUlJBTlRZOyB3aXRob3V0IGV2ZW4gdGhl
IGltcGxpZWQgd2FycmFudHkgb2YgTUVSQ0hBTlRBQklMSVRZIG9yCisgKiBGSVRORVNTIEZPUiBB
IFBBUlRJQ1VMQVIgUFVSUE9TRS4gIFNlZSB0aGUgR05VIEdlbmVyYWwgUHVibGljIExpY2Vuc2Ug
Zm9yCisgKiBtb3JlIGRldGFpbHMuCisgKgorICogWW91IHNob3VsZCBoYXZlIHJlY2VpdmVkIGEg
Y29weSBvZiB0aGUgR05VIEdlbmVyYWwgUHVibGljIExpY2Vuc2UgYWxvbmcgd2l0aAorICogdGhp
cyBwcm9ncmFtOyBpZiBub3QsIHdyaXRlIHRvIHRoZSBGcmVlIFNvZnR3YXJlIEZvdW5kYXRpb24s
IEluYy4sIDU5IFRlbXBsZQorICogUGxhY2UgLSBTdWl0ZSAzMzAsIEJvc3RvbiwgTUEgMDIxMTEt
MTMwNyBVU0EuCisgKi8KKworCisjaW5jbHVkZTxsaW51eC9tb2R1bGUuaD4KKyNpbmNsdWRlPGFz
bS9mcHN3YS5oPgorCisjaW5jbHVkZSAidmNwdS5oIgorCitNT0RVTEVfQVVUSE9SKCJJbnRlbCIp
OworTU9EVUxFX0xJQ0VOU0UoIkdQTCIpOworCitleHRlcm4gY2hhciBrdm1faWE2NF9pdnQ7Citl
eHRlcm4gZnBzd2FfaW50ZXJmYWNlX3QgKnZtbV9mcHN3YV9pbnRlcmZhY2U7CisKK3N0cnVjdCBr
dm1fdm1tX2luZm8gdm1tX2luZm8gPSB7CisJLm1vZHVsZQkgICAgID0gVEhJU19NT0RVTEUsCisJ
LnZtbV9lbnRyeSAgID0gdm1tX2VudHJ5LAorCS50cmFtcF9lbnRyeSA9IHZtbV90cmFtcG9saW5l
LAorCS52bW1faXZ0ICAgICA9ICh1bnNpZ25lZCBsb25nKSZrdm1faWE2NF9pdnQsCit9OworCitz
dGF0aWMgaW50IF9faW5pdCAga3ZtX3ZtbV9pbml0KHZvaWQpCit7CisKKwl2bW1fZnBzd2FfaW50
ZXJmYWNlID0gZnBzd2FfaW50ZXJmYWNlOworCisJLypSZWdpc3RlciB2bW0gZGF0YSB0byBrdm0g
c2lkZSovCisJcmV0dXJuIGt2bV9pbml0KCZ2bW1faW5mbywgMTAyNCwgVEhJU19NT0RVTEUpOwor
fQorCitzdGF0aWMgdm9pZCBfX2V4aXQga3ZtX3ZtbV9leGl0KHZvaWQpCit7CisJa3ZtX2V4aXQo
KTsKKwlyZXR1cm4gOworfQorCittb2R1bGVfaW5pdChrdm1fdm1tX2luaXQpCittb2R1bGVfZXhp
dChrdm1fdm1tX2V4aXQpCi0tIAoxLjUuMQoK

------_=_NextPart_001_01C863F4.2B3C06BF--
