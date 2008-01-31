From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Thu, 31 Jan 2008 10:28:19 +0000
Subject: [PATCH][02] Change srlz.d to srlz.i for ia64_set_psr
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDCD31FC5@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C863F3.FFED6BA7"
List-Id: <linux-ia64.vger.kernel.org>
To: Avi Kivity <avi@qumranet.com>, "Luck, Tony" <tony.luck@intel.com>, "Xu, Anthony" <anthony.xu@intel.com>, "Zhang, Xiantao" <xiantao.zhang@intel.com>
Cc: kvm-devel@lists.sourceforge.net, kvm-ia64-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C863F3.FFED6BA7
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

From: Xiantao Zhang <xiantao.zhang@intel.com>
Date: Thu, 31 Jan 2008 17:46:09 +0800
Subject: [PATCH] IA64: ia64_set_psr may need srlz.i sometimes.

Once psr.ic changes by ia64_set_psr, srlz.i is needed here.
Signed-off-by: Xiantao Zhang <xiantao.zhang@intel.com>
---
 arch/ia64/kernel/efi.c       |    1 -
 include/asm-ia64/processor.h |    2 +-
 2 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/arch/ia64/kernel/efi.c b/arch/ia64/kernel/efi.c
index 242d793..f3823db 100644
--- a/arch/ia64/kernel/efi.c
+++ b/arch/ia64/kernel/efi.c
@@ -405,7 +405,6 @@ efi_map_pal_code (void)
 		 pte_val(pfn_pte(__pa(pal_vaddr) >> PAGE_SHIFT,
PAGE_KERNEL)),
 		 IA64_GRANULE_SHIFT);
 	ia64_set_psr(psr);		/* restore psr */
-	ia64_srlz_i();
 }
=20
 void __init
diff --git a/include/asm-ia64/processor.h b/include/asm-ia64/processor.h
index be3b0ae..038642f 100644
--- a/include/asm-ia64/processor.h
+++ b/include/asm-ia64/processor.h
@@ -472,7 +472,7 @@ ia64_set_psr (__u64 psr)
 {
 	ia64_stop();
 	ia64_setreg(_IA64_REG_PSR_L, psr);
-	ia64_srlz_d();
+	ia64_srlz_i();
 }
=20
 /*
--=20
1.5.1

------_=_NextPart_001_01C863F3.FFED6BA7
Content-Type: application/octet-stream;
	name="0002-IA64-ia64_set_psr-may-need-srlz.i-sometimes.patch"
Content-Transfer-Encoding: base64
Content-Description: 0002-IA64-ia64_set_psr-may-need-srlz.i-sometimes.patch
Content-Disposition: attachment;
	filename="0002-IA64-ia64_set_psr-may-need-srlz.i-sometimes.patch"

RnJvbSA1MWRlY2Q4ZWIwMzBlNGZkZjE1YzE0ZWJlNTJiYmI3MDhhNTJjNDNkIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBYaWFudGFvIFpoYW5nIDx4aWFudGFvLnpoYW5nQGludGVsLmNv
bT4KRGF0ZTogVGh1LCAzMSBKYW4gMjAwOCAxNzo0NjowOSArMDgwMApTdWJqZWN0OiBbUEFUQ0hd
IElBNjQ6IGlhNjRfc2V0X3BzciBtYXkgbmVlZCBzcmx6Lmkgc29tZXRpbWVzLgoKT25jZSBwc3Iu
aWMgY2hhbmdlcyBieSBpYTY0X3NldF9wc3IsIHNybHouaSBpcyBuZWVkZWQgaGVyZS4KU2lnbmVk
LW9mZi1ieTogWGlhbnRhbyBaaGFuZyA8eGlhbnRhby56aGFuZ0BpbnRlbC5jb20+Ci0tLQogYXJj
aC9pYTY0L2tlcm5lbC9lZmkuYyAgICAgICB8ICAgIDEgLQogaW5jbHVkZS9hc20taWE2NC9wcm9j
ZXNzb3IuaCB8ICAgIDIgKy0KIDIgZmlsZXMgY2hhbmdlZCwgMSBpbnNlcnRpb25zKCspLCAyIGRl
bGV0aW9ucygtKQoKZGlmZiAtLWdpdCBhL2FyY2gvaWE2NC9rZXJuZWwvZWZpLmMgYi9hcmNoL2lh
NjQva2VybmVsL2VmaS5jCmluZGV4IDI0MmQ3OTMuLmYzODIzZGIgMTAwNjQ0Ci0tLSBhL2FyY2gv
aWE2NC9rZXJuZWwvZWZpLmMKKysrIGIvYXJjaC9pYTY0L2tlcm5lbC9lZmkuYwpAQCAtNDA1LDcg
KzQwNSw2IEBAIGVmaV9tYXBfcGFsX2NvZGUgKHZvaWQpCiAJCSBwdGVfdmFsKHBmbl9wdGUoX19w
YShwYWxfdmFkZHIpID4+IFBBR0VfU0hJRlQsIFBBR0VfS0VSTkVMKSksCiAJCSBJQTY0X0dSQU5V
TEVfU0hJRlQpOwogCWlhNjRfc2V0X3Bzcihwc3IpOwkJLyogcmVzdG9yZSBwc3IgKi8KLQlpYTY0
X3NybHpfaSgpOwogfQogCiB2b2lkIF9faW5pdApkaWZmIC0tZ2l0IGEvaW5jbHVkZS9hc20taWE2
NC9wcm9jZXNzb3IuaCBiL2luY2x1ZGUvYXNtLWlhNjQvcHJvY2Vzc29yLmgKaW5kZXggYmUzYjBh
ZS4uMDM4NjQyZiAxMDA2NDQKLS0tIGEvaW5jbHVkZS9hc20taWE2NC9wcm9jZXNzb3IuaAorKysg
Yi9pbmNsdWRlL2FzbS1pYTY0L3Byb2Nlc3Nvci5oCkBAIC00NzIsNyArNDcyLDcgQEAgaWE2NF9z
ZXRfcHNyIChfX3U2NCBwc3IpCiB7CiAJaWE2NF9zdG9wKCk7CiAJaWE2NF9zZXRyZWcoX0lBNjRf
UkVHX1BTUl9MLCBwc3IpOwotCWlhNjRfc3Jsel9kKCk7CisJaWE2NF9zcmx6X2koKTsKIH0KIAog
LyoKLS0gCjEuNS4xCgo=

------_=_NextPart_001_01C863F3.FFED6BA7--
