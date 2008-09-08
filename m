From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Mon, 08 Sep 2008 05:30:45 +0000
Subject: [PATCH]Export the symbol ia64_patch_imm64.
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDC01923FC8@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C91174.0B56F2AB"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C91174.0B56F2AB
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

From 0dfc91f92875523cd29ae5f4719f25a21168d637 Mon Sep 17 00:00:00 2001
From: Xiantao Zhang <xiantao.zhang@intel.com>
Date: Mon, 8 Sep 2008 13:10:00 +0800
Subject: [PATCH] ia64: Export the symbol ia64_patch_imm64.

Signed-off-by: Xiantao Zhang <xiantao.zhang@intel.com>
---
 arch/ia64/kernel/ia64_ksyms.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/arch/ia64/kernel/ia64_ksyms.c
b/arch/ia64/kernel/ia64_ksyms.c
index 6da1f20..92cb478 100644
--- a/arch/ia64/kernel/ia64_ksyms.c
+++ b/arch/ia64/kernel/ia64_ksyms.c
@@ -86,6 +86,9 @@ EXPORT_SYMBOL(ia64_save_scratch_fpregs);
 #include <asm/unwind.h>
 EXPORT_SYMBOL(unw_init_running);
=20
+#include <asm/patch.h>
+EXPORT_SYMBOL(ia64_patch_imm64);
+
 #ifdef ASM_SUPPORTED
 # ifdef CONFIG_SMP
 #  if (__GNUC__ =3D=3D 3 && __GNUC_MINOR__ < 3)
--=20
1.5.1

------_=_NextPart_001_01C91174.0B56F2AB
Content-Type: application/octet-stream;
	name="0001-ia64-Export-the-symbol-ia64_patch_imm64.patch"
Content-Transfer-Encoding: base64
Content-Description: 0001-ia64-Export-the-symbol-ia64_patch_imm64.patch
Content-Disposition: attachment;
	filename="0001-ia64-Export-the-symbol-ia64_patch_imm64.patch"

RnJvbSAwZGZjOTFmOTI4NzU1MjNjZDI5YWU1ZjQ3MTlmMjVhMjExNjhkNjM3IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBYaWFudGFvIFpoYW5nIDx4aWFudGFvLnpoYW5nQGludGVsLmNv
bT4KRGF0ZTogTW9uLCA4IFNlcCAyMDA4IDEzOjEwOjAwICswODAwClN1YmplY3Q6IFtQQVRDSF0g
aWE2NDogRXhwb3J0IHRoZSBzeW1ib2wgaWE2NF9wYXRjaF9pbW02NC4KClNpZ25lZC1vZmYtYnk6
IFhpYW50YW8gWmhhbmcgPHhpYW50YW8uemhhbmdAaW50ZWwuY29tPgotLS0KIGFyY2gvaWE2NC9r
ZXJuZWwvaWE2NF9rc3ltcy5jIHwgICAgMyArKysKIDEgZmlsZXMgY2hhbmdlZCwgMyBpbnNlcnRp
b25zKCspLCAwIGRlbGV0aW9ucygtKQoKZGlmZiAtLWdpdCBhL2FyY2gvaWE2NC9rZXJuZWwvaWE2
NF9rc3ltcy5jIGIvYXJjaC9pYTY0L2tlcm5lbC9pYTY0X2tzeW1zLmMKaW5kZXggNmRhMWYyMC4u
OTJjYjQ3OCAxMDA2NDQKLS0tIGEvYXJjaC9pYTY0L2tlcm5lbC9pYTY0X2tzeW1zLmMKKysrIGIv
YXJjaC9pYTY0L2tlcm5lbC9pYTY0X2tzeW1zLmMKQEAgLTg2LDYgKzg2LDkgQEAgRVhQT1JUX1NZ
TUJPTChpYTY0X3NhdmVfc2NyYXRjaF9mcHJlZ3MpOwogI2luY2x1ZGUgPGFzbS91bndpbmQuaD4K
IEVYUE9SVF9TWU1CT0wodW53X2luaXRfcnVubmluZyk7CiAKKyNpbmNsdWRlIDxhc20vcGF0Y2gu
aD4KK0VYUE9SVF9TWU1CT0woaWE2NF9wYXRjaF9pbW02NCk7CisKICNpZmRlZiBBU01fU1VQUE9S
VEVECiAjIGlmZGVmIENPTkZJR19TTVAKICMgIGlmIChfX0dOVUNfXyA9PSAzICYmIF9fR05VQ19N
SU5PUl9fIDwgMykKLS0gCjEuNS4xCgo=

------_=_NextPart_001_01C91174.0B56F2AB--
