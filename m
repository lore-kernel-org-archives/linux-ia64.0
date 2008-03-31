From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Mon, 31 Mar 2008 08:27:18 +0000
Subject: [06/17][PATCH] kvm/ia64: VMM module interfaces.--V8
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDC01048248@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C89309.085677A3"
List-Id: <linux-ia64.vger.kernel.org>
References: <42DFA526FC41B1429CE7279EF83C6BDCFF7EFA@pdsmsx415.ccr.corp.intel.com>
In-Reply-To: <42DFA526FC41B1429CE7279EF83C6BDCFF7EFA@pdsmsx415.ccr.corp.intel.com>
To: Avi Kivity <avi@qumranet.com>, "Luck, Tony" <tony.luck@intel.com>, "Xu, Anthony" <anthony.xu@intel.com>, Jes Sorensen <jes@sgi.com>, Akio Takebe <takebe_akio@jp.fujitsu.com>, 

This is a multi-part message in MIME format.

------_=_NextPart_001_01C89309.085677A3
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

From f0a80c40029b18df15ae2da7e4784a8881fe4c06 Mon Sep 17 00:00:00 2001
From: Xiantao Zhang <xiantao.zhang@intel.com>
Date: Wed, 12 Mar 2008 13:44:37 +0800
Subject: [PATCH] KVM:IA64 : VMM module interfaces.

vmm.c adds the interfaces with kvm/module, and initialize global data
area.
Signed-off-by: Xiantao Zhang <xiantao.zhang@intel.com>
---
 arch/ia64/kvm/vmm.c |   66
+++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 66 insertions(+), 0 deletions(-)
 create mode 100644 arch/ia64/kvm/vmm.c

diff --git a/arch/ia64/kvm/vmm.c b/arch/ia64/kvm/vmm.c
new file mode 100644
index 0000000..2275bf4
--- /dev/null
+++ b/arch/ia64/kvm/vmm.c
@@ -0,0 +1,66 @@
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
+void vmm_spin_lock(spinlock_t *lock)
+{
+	_vmm_raw_spin_lock(lock);
+}
+
+void vmm_spin_unlock(spinlock_t *lock)
+{
+	_vmm_raw_spin_unlock(lock);
+}
+module_init(kvm_vmm_init)
+module_exit(kvm_vmm_exit)
--=20
1.5.2

------_=_NextPart_001_01C89309.085677A3
Content-Type: application/octet-stream;
	name="0006-KVM-IA64-VMM-module-interfaces.patch"
Content-Transfer-Encoding: base64
Content-Description: 0006-KVM-IA64-VMM-module-interfaces.patch
Content-Disposition: attachment;
	filename="0006-KVM-IA64-VMM-module-interfaces.patch"

RnJvbSBmMGE4MGM0MDAyOWIxOGRmMTVhZTJkYTdlNDc4NGE4ODgxZmU0YzA2IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBYaWFudGFvIFpoYW5nIDx4aWFudGFvLnpoYW5nQGludGVsLmNv
bT4KRGF0ZTogV2VkLCAxMiBNYXIgMjAwOCAxMzo0NDozNyArMDgwMApTdWJqZWN0OiBbUEFUQ0hd
IEtWTTpJQTY0IDogVk1NIG1vZHVsZSBpbnRlcmZhY2VzLgoKdm1tLmMgYWRkcyB0aGUgaW50ZXJm
YWNlcyB3aXRoIGt2bS9tb2R1bGUsIGFuZCBpbml0aWFsaXplIGdsb2JhbCBkYXRhIGFyZWEuClNp
Z25lZC1vZmYtYnk6IFhpYW50YW8gWmhhbmcgPHhpYW50YW8uemhhbmdAaW50ZWwuY29tPgotLS0K
IGFyY2gvaWE2NC9rdm0vdm1tLmMgfCAgIDY2ICsrKysrKysrKysrKysrKysrKysrKysrKysrKysr
KysrKysrKysrKysrKysrKysrKysrKwogMSBmaWxlcyBjaGFuZ2VkLCA2NiBpbnNlcnRpb25zKCsp
LCAwIGRlbGV0aW9ucygtKQogY3JlYXRlIG1vZGUgMTAwNjQ0IGFyY2gvaWE2NC9rdm0vdm1tLmMK
CmRpZmYgLS1naXQgYS9hcmNoL2lhNjQva3ZtL3ZtbS5jIGIvYXJjaC9pYTY0L2t2bS92bW0uYwpu
ZXcgZmlsZSBtb2RlIDEwMDY0NAppbmRleCAwMDAwMDAwLi4yMjc1YmY0Ci0tLSAvZGV2L251bGwK
KysrIGIvYXJjaC9pYTY0L2t2bS92bW0uYwpAQCAtMCwwICsxLDY2IEBACisvKgorICogdm1tLmM6
IHZtbSBtb2R1bGUgaW50ZXJmYWNlIHdpdGgga3ZtIG1vZHVsZQorICoKKyAqIENvcHlyaWdodCAo
YykgMjAwNywgSW50ZWwgQ29ycG9yYXRpb24uCisgKgorICogIFhpYW50YW8gWmhhbmcgKHhpYW50
YW8uemhhbmdAaW50ZWwuY29tKQorICoKKyAqIFRoaXMgcHJvZ3JhbSBpcyBmcmVlIHNvZnR3YXJl
OyB5b3UgY2FuIHJlZGlzdHJpYnV0ZSBpdCBhbmQvb3IgbW9kaWZ5IGl0CisgKiB1bmRlciB0aGUg
dGVybXMgYW5kIGNvbmRpdGlvbnMgb2YgdGhlIEdOVSBHZW5lcmFsIFB1YmxpYyBMaWNlbnNlLAor
ICogdmVyc2lvbiAyLCBhcyBwdWJsaXNoZWQgYnkgdGhlIEZyZWUgU29mdHdhcmUgRm91bmRhdGlv
bi4KKyAqCisgKiBUaGlzIHByb2dyYW0gaXMgZGlzdHJpYnV0ZWQgaW4gdGhlIGhvcGUgaXQgd2ls
bCBiZSB1c2VmdWwsIGJ1dCBXSVRIT1VUCisgKiBBTlkgV0FSUkFOVFk7IHdpdGhvdXQgZXZlbiB0
aGUgaW1wbGllZCB3YXJyYW50eSBvZiBNRVJDSEFOVEFCSUxJVFkgb3IKKyAqIEZJVE5FU1MgRk9S
IEEgUEFSVElDVUxBUiBQVVJQT1NFLiAgU2VlIHRoZSBHTlUgR2VuZXJhbCBQdWJsaWMgTGljZW5z
ZSBmb3IKKyAqIG1vcmUgZGV0YWlscy4KKyAqCisgKiBZb3Ugc2hvdWxkIGhhdmUgcmVjZWl2ZWQg
YSBjb3B5IG9mIHRoZSBHTlUgR2VuZXJhbCBQdWJsaWMgTGljZW5zZSBhbG9uZyB3aXRoCisgKiB0
aGlzIHByb2dyYW07IGlmIG5vdCwgd3JpdGUgdG8gdGhlIEZyZWUgU29mdHdhcmUgRm91bmRhdGlv
biwgSW5jLiwgNTkgVGVtcGxlCisgKiBQbGFjZSAtIFN1aXRlIDMzMCwgQm9zdG9uLCBNQSAwMjEx
MS0xMzA3IFVTQS4KKyAqLworCisKKyNpbmNsdWRlPGxpbnV4L21vZHVsZS5oPgorI2luY2x1ZGU8
YXNtL2Zwc3dhLmg+CisKKyNpbmNsdWRlICJ2Y3B1LmgiCisKK01PRFVMRV9BVVRIT1IoIkludGVs
Iik7CitNT0RVTEVfTElDRU5TRSgiR1BMIik7CisKK2V4dGVybiBjaGFyIGt2bV9pYTY0X2l2dDsK
K2V4dGVybiBmcHN3YV9pbnRlcmZhY2VfdCAqdm1tX2Zwc3dhX2ludGVyZmFjZTsKKworc3RydWN0
IGt2bV92bW1faW5mbyB2bW1faW5mbyA9IHsKKwkubW9kdWxlCSAgICAgPSBUSElTX01PRFVMRSwK
Kwkudm1tX2VudHJ5ICAgPSB2bW1fZW50cnksCisJLnRyYW1wX2VudHJ5ID0gdm1tX3RyYW1wb2xp
bmUsCisJLnZtbV9pdnQgICAgID0gKHVuc2lnbmVkIGxvbmcpJmt2bV9pYTY0X2l2dCwKK307CisK
K3N0YXRpYyBpbnQgX19pbml0ICBrdm1fdm1tX2luaXQodm9pZCkKK3sKKworCXZtbV9mcHN3YV9p
bnRlcmZhY2UgPSBmcHN3YV9pbnRlcmZhY2U7CisKKwkvKlJlZ2lzdGVyIHZtbSBkYXRhIHRvIGt2
bSBzaWRlKi8KKwlyZXR1cm4ga3ZtX2luaXQoJnZtbV9pbmZvLCAxMDI0LCBUSElTX01PRFVMRSk7
Cit9CisKK3N0YXRpYyB2b2lkIF9fZXhpdCBrdm1fdm1tX2V4aXQodm9pZCkKK3sKKwlrdm1fZXhp
dCgpOworCXJldHVybiA7Cit9CisKK3ZvaWQgdm1tX3NwaW5fbG9jayhzcGlubG9ja190ICpsb2Nr
KQoreworCV92bW1fcmF3X3NwaW5fbG9jayhsb2NrKTsKK30KKwordm9pZCB2bW1fc3Bpbl91bmxv
Y2soc3BpbmxvY2tfdCAqbG9jaykKK3sKKwlfdm1tX3Jhd19zcGluX3VubG9jayhsb2NrKTsKK30K
K21vZHVsZV9pbml0KGt2bV92bW1faW5pdCkKK21vZHVsZV9leGl0KGt2bV92bW1fZXhpdCkKLS0g
CjEuNS4yCgo=

------_=_NextPart_001_01C89309.085677A3--
