From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Tue, 09 Sep 2008 05:11:33 +0000
Subject: RE: [PATCH]Export the symbol ia64_patch_imm64.
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDC0192443E@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C9123A.86D65DB9"
List-Id: <linux-ia64.vger.kernel.org>
References: <42DFA526FC41B1429CE7279EF83C6BDC01923FC8@pdsmsx415.ccr.corp.intel.com>
In-Reply-To: <42DFA526FC41B1429CE7279EF83C6BDC01923FC8@pdsmsx415.ccr.corp.intel.com>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C9123A.86D65DB9
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Luck, Tony wrote:
> Why does this need to be exported?  I'm assuming
> that kvm is involved ... but you should provide
> some details in the patch so that the GIT commit
> will have some descriptive value.

Okay, added in the updated version.=20
=20
> Is it a legacy case?  If not, then we should use
> EXPORT_SYMBOL_GPL.
Since kvm is only merged into linux-2.6.26 and newer version, we don't
need to consider legacy cases. So EXPORT_SYMBOL_GPL is better, Thanks!
Xiantao

From 15760b3bf350de562f7138fc84d128369543f17f Mon Sep 17 00:00:00 2001
From: Xiantao Zhang <xiantao.zhang@intel.com>
Date: Tue, 9 Sep 2008 09:52:07 +0800
Subject: [PATCH] ia64: Export the symbol ia64_patch_imm64.

In kvm module, it uses ia64_patch_imm64 to patch some instructions of
itself
to reduce cost, when it calls PAL virtualization services.

Signed-off-by: Xiantao Zhang <xiantao.zhang@intel.com>
---
 arch/ia64/kernel/ia64_ksyms.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/arch/ia64/kernel/ia64_ksyms.c
b/arch/ia64/kernel/ia64_ksyms.c
index 6da1f20..b872f54 100644
--- a/arch/ia64/kernel/ia64_ksyms.c
+++ b/arch/ia64/kernel/ia64_ksyms.c
@@ -86,6 +86,9 @@ EXPORT_SYMBOL(ia64_save_scratch_fpregs);
 #include <asm/unwind.h>
 EXPORT_SYMBOL(unw_init_running);
=20
+#include <asm/patch.h>
+EXPORT_SYMBOL_GPL(ia64_patch_imm64);
+
 #ifdef ASM_SUPPORTED
 # ifdef CONFIG_SMP
 #  if (__GNUC__ =3D=3D 3 && __GNUC_MINOR__ < 3)
--=20
1.5.1


------_=_NextPart_001_01C9123A.86D65DB9
Content-Type: application/octet-stream;
	name="0001-ia64-Export-the-symbol-ia64_patch_imm64.patch"
Content-Transfer-Encoding: base64
Content-Description: 0001-ia64-Export-the-symbol-ia64_patch_imm64.patch
Content-Disposition: attachment;
	filename="0001-ia64-Export-the-symbol-ia64_patch_imm64.patch"

RnJvbSAxNTc2MGIzYmYzNTBkZTU2MmY3MTM4ZmM4NGQxMjgzNjk1NDNmMTdmIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBYaWFudGFvIFpoYW5nIDx4aWFudGFvLnpoYW5nQGludGVsLmNv
bT4KRGF0ZTogVHVlLCA5IFNlcCAyMDA4IDA5OjUyOjA3ICswODAwClN1YmplY3Q6IFtQQVRDSF0g
aWE2NDogRXhwb3J0IHRoZSBzeW1ib2wgaWE2NF9wYXRjaF9pbW02NC4KCkluIGt2bSBtb2R1bGUs
IGl0IHVzZXMgaWE2NF9wYXRjaF9pbW02NCB0byBwYXRjaCBzb21lIGluc3RydWN0aW9ucyBvZiBp
dHNlbGYKdG8gcmVkdWNlIGNvc3QsIHdoZW4gaXQgY2FsbHMgUEFMIHZpcnR1YWxpemF0aW9uIHNl
cnZpY2VzLgoKU2lnbmVkLW9mZi1ieTogWGlhbnRhbyBaaGFuZyA8eGlhbnRhby56aGFuZ0BpbnRl
bC5jb20+Ci0tLQogYXJjaC9pYTY0L2tlcm5lbC9pYTY0X2tzeW1zLmMgfCAgICAzICsrKwogMSBm
aWxlcyBjaGFuZ2VkLCAzIGluc2VydGlvbnMoKyksIDAgZGVsZXRpb25zKC0pCgpkaWZmIC0tZ2l0
IGEvYXJjaC9pYTY0L2tlcm5lbC9pYTY0X2tzeW1zLmMgYi9hcmNoL2lhNjQva2VybmVsL2lhNjRf
a3N5bXMuYwppbmRleCA2ZGExZjIwLi5iODcyZjU0IDEwMDY0NAotLS0gYS9hcmNoL2lhNjQva2Vy
bmVsL2lhNjRfa3N5bXMuYworKysgYi9hcmNoL2lhNjQva2VybmVsL2lhNjRfa3N5bXMuYwpAQCAt
ODYsNiArODYsOSBAQCBFWFBPUlRfU1lNQk9MKGlhNjRfc2F2ZV9zY3JhdGNoX2ZwcmVncyk7CiAj
aW5jbHVkZSA8YXNtL3Vud2luZC5oPgogRVhQT1JUX1NZTUJPTCh1bndfaW5pdF9ydW5uaW5nKTsK
IAorI2luY2x1ZGUgPGFzbS9wYXRjaC5oPgorRVhQT1JUX1NZTUJPTF9HUEwoaWE2NF9wYXRjaF9p
bW02NCk7CisKICNpZmRlZiBBU01fU1VQUE9SVEVECiAjIGlmZGVmIENPTkZJR19TTVAKICMgIGlm
IChfX0dOVUNfXyA9PSAzICYmIF9fR05VQ19NSU5PUl9fIDwgMykKLS0gCjEuNS4xCgo=

------_=_NextPart_001_01C9123A.86D65DB9--
