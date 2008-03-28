From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Fri, 28 Mar 2008 09:58:56 +0000
Subject: [06/17][PATCH] kvm/ia64: VMM module interfaces.
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDCFF7EFA@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C890BA.563F5FE7"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C890BA.563F5FE7
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

From 6af8b4d7ca1d4ec40cc634cf8b0d5ae8d2dc53ce Mon Sep 17 00:00:00 2001
From: Xiantao Zhang <xiantao.zhang@intel.com>
Date: Wed, 12 Mar 2008 13:44:37 +0800
Subject: [PATCH] kvm/ia64: VMM module interfaces.

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

------_=_NextPart_001_01C890BA.563F5FE7
Content-Type: application/octet-stream;
	name="0006-kvm-ia64-VMM-module-interfaces.patch"
Content-Transfer-Encoding: base64
Content-Description: 0006-kvm-ia64-VMM-module-interfaces.patch
Content-Disposition: attachment;
	filename="0006-kvm-ia64-VMM-module-interfaces.patch"

RnJvbSA2YWY4YjRkN2NhMWQ0ZWM0MGNjNjM0Y2Y4YjBkNWFlOGQyZGM1M2NlIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBYaWFudGFvIFpoYW5nIDx4aWFudGFvLnpoYW5nQGludGVsLmNv
bT4KRGF0ZTogV2VkLCAxMiBNYXIgMjAwOCAxMzo0NDozNyArMDgwMApTdWJqZWN0OiBbUEFUQ0hd
IGt2bS9pYTY0OiBWTU0gbW9kdWxlIGludGVyZmFjZXMuCgp2bW0uYyBhZGRzIHRoZSBpbnRlcmZh
Y2VzIHdpdGgga3ZtL21vZHVsZSwgYW5kIGluaXRpYWxpemUgZ2xvYmFsIGRhdGEgYXJlYS4KU2ln
bmVkLW9mZi1ieTogWGlhbnRhbyBaaGFuZyA8eGlhbnRhby56aGFuZ0BpbnRlbC5jb20+Ci0tLQog
YXJjaC9pYTY0L2t2bS92bW0uYyB8ICAgNjYgKysrKysrKysrKysrKysrKysrKysrKysrKysrKysr
KysrKysrKysrKysrKysrKysrKysrCiAxIGZpbGVzIGNoYW5nZWQsIDY2IGluc2VydGlvbnMoKyks
IDAgZGVsZXRpb25zKC0pCiBjcmVhdGUgbW9kZSAxMDA2NDQgYXJjaC9pYTY0L2t2bS92bW0uYwoK
ZGlmZiAtLWdpdCBhL2FyY2gvaWE2NC9rdm0vdm1tLmMgYi9hcmNoL2lhNjQva3ZtL3ZtbS5jCm5l
dyBmaWxlIG1vZGUgMTAwNjQ0CmluZGV4IDAwMDAwMDAuLjIyNzViZjQKLS0tIC9kZXYvbnVsbAor
KysgYi9hcmNoL2lhNjQva3ZtL3ZtbS5jCkBAIC0wLDAgKzEsNjYgQEAKKy8qCisgKiB2bW0uYzog
dm1tIG1vZHVsZSBpbnRlcmZhY2Ugd2l0aCBrdm0gbW9kdWxlCisgKgorICogQ29weXJpZ2h0IChj
KSAyMDA3LCBJbnRlbCBDb3Jwb3JhdGlvbi4KKyAqCisgKiAgWGlhbnRhbyBaaGFuZyAoeGlhbnRh
by56aGFuZ0BpbnRlbC5jb20pCisgKgorICogVGhpcyBwcm9ncmFtIGlzIGZyZWUgc29mdHdhcmU7
IHlvdSBjYW4gcmVkaXN0cmlidXRlIGl0IGFuZC9vciBtb2RpZnkgaXQKKyAqIHVuZGVyIHRoZSB0
ZXJtcyBhbmQgY29uZGl0aW9ucyBvZiB0aGUgR05VIEdlbmVyYWwgUHVibGljIExpY2Vuc2UsCisg
KiB2ZXJzaW9uIDIsIGFzIHB1Ymxpc2hlZCBieSB0aGUgRnJlZSBTb2Z0d2FyZSBGb3VuZGF0aW9u
LgorICoKKyAqIFRoaXMgcHJvZ3JhbSBpcyBkaXN0cmlidXRlZCBpbiB0aGUgaG9wZSBpdCB3aWxs
IGJlIHVzZWZ1bCwgYnV0IFdJVEhPVVQKKyAqIEFOWSBXQVJSQU5UWTsgd2l0aG91dCBldmVuIHRo
ZSBpbXBsaWVkIHdhcnJhbnR5IG9mIE1FUkNIQU5UQUJJTElUWSBvcgorICogRklUTkVTUyBGT1Ig
QSBQQVJUSUNVTEFSIFBVUlBPU0UuICBTZWUgdGhlIEdOVSBHZW5lcmFsIFB1YmxpYyBMaWNlbnNl
IGZvcgorICogbW9yZSBkZXRhaWxzLgorICoKKyAqIFlvdSBzaG91bGQgaGF2ZSByZWNlaXZlZCBh
IGNvcHkgb2YgdGhlIEdOVSBHZW5lcmFsIFB1YmxpYyBMaWNlbnNlIGFsb25nIHdpdGgKKyAqIHRo
aXMgcHJvZ3JhbTsgaWYgbm90LCB3cml0ZSB0byB0aGUgRnJlZSBTb2Z0d2FyZSBGb3VuZGF0aW9u
LCBJbmMuLCA1OSBUZW1wbGUKKyAqIFBsYWNlIC0gU3VpdGUgMzMwLCBCb3N0b24sIE1BIDAyMTEx
LTEzMDcgVVNBLgorICovCisKKworI2luY2x1ZGU8bGludXgvbW9kdWxlLmg+CisjaW5jbHVkZTxh
c20vZnBzd2EuaD4KKworI2luY2x1ZGUgInZjcHUuaCIKKworTU9EVUxFX0FVVEhPUigiSW50ZWwi
KTsKK01PRFVMRV9MSUNFTlNFKCJHUEwiKTsKKworZXh0ZXJuIGNoYXIga3ZtX2lhNjRfaXZ0Owor
ZXh0ZXJuIGZwc3dhX2ludGVyZmFjZV90ICp2bW1fZnBzd2FfaW50ZXJmYWNlOworCitzdHJ1Y3Qg
a3ZtX3ZtbV9pbmZvIHZtbV9pbmZvID0geworCS5tb2R1bGUJICAgICA9IFRISVNfTU9EVUxFLAor
CS52bW1fZW50cnkgICA9IHZtbV9lbnRyeSwKKwkudHJhbXBfZW50cnkgPSB2bW1fdHJhbXBvbGlu
ZSwKKwkudm1tX2l2dCAgICAgPSAodW5zaWduZWQgbG9uZykma3ZtX2lhNjRfaXZ0LAorfTsKKwor
c3RhdGljIGludCBfX2luaXQgIGt2bV92bW1faW5pdCh2b2lkKQoreworCisJdm1tX2Zwc3dhX2lu
dGVyZmFjZSA9IGZwc3dhX2ludGVyZmFjZTsKKworCS8qUmVnaXN0ZXIgdm1tIGRhdGEgdG8ga3Zt
IHNpZGUqLworCXJldHVybiBrdm1faW5pdCgmdm1tX2luZm8sIDEwMjQsIFRISVNfTU9EVUxFKTsK
K30KKworc3RhdGljIHZvaWQgX19leGl0IGt2bV92bW1fZXhpdCh2b2lkKQoreworCWt2bV9leGl0
KCk7CisJcmV0dXJuIDsKK30KKwordm9pZCB2bW1fc3Bpbl9sb2NrKHNwaW5sb2NrX3QgKmxvY2sp
Cit7CisJX3ZtbV9yYXdfc3Bpbl9sb2NrKGxvY2spOworfQorCit2b2lkIHZtbV9zcGluX3VubG9j
ayhzcGlubG9ja190ICpsb2NrKQoreworCV92bW1fcmF3X3NwaW5fdW5sb2NrKGxvY2spOworfQor
bW9kdWxlX2luaXQoa3ZtX3ZtbV9pbml0KQorbW9kdWxlX2V4aXQoa3ZtX3ZtbV9leGl0KQotLSAK
MS41LjIKCg==

------_=_NextPart_001_01C890BA.563F5FE7--
