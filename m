From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Thu, 31 Jan 2008 10:30:42 +0000
Subject: [PATCH][20]Update IA64 Kconfig and Makefile to include kvm build.
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDCD31FD7@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C863F4.54C0DCD7"
List-Id: <linux-ia64.vger.kernel.org>
To: Avi Kivity <avi@qumranet.com>, "Luck, Tony" <tony.luck@intel.com>, "Xu, Anthony" <anthony.xu@intel.com>, "Zhang, Xiantao" <xiantao.zhang@intel.com>
Cc: kvm-devel@lists.sourceforge.net, kvm-ia64-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C863F4.54C0DCD7
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

From: Zhang Xiantao <xiantao.zhang@intel.com>
Date: Tue, 29 Jan 2008 15:40:27 +0800
Subject: [PATCH] kvm/ia64: Update IA64 Kconfig and Makefile to include
kvm build.

Update IA64 Kconfig and Makefile to include kvm build.
Signed-off-by: Xiantao Zhang <xiantao.zhang@intel.com>
---
 arch/ia64/Kconfig  |    6 ++++++
 arch/ia64/Makefile |    1 +
 2 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index bef4772..4592130 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -99,6 +99,10 @@ config AUDIT_ARCH
 	bool
 	default y
=20
+config ARCH_SUPPORTS_KVM
+	bool
+	default y
+
 choice
 	prompt "System type"
 	default IA64_GENERIC
@@ -568,6 +572,8 @@ config MSPEC
=20
 source "fs/Kconfig"
=20
+source "arch/ia64/kvm/Kconfig"
+
 source "lib/Kconfig"
=20
 #
diff --git a/arch/ia64/Makefile b/arch/ia64/Makefile
index b916ccf..c8d09be 100644
--- a/arch/ia64/Makefile
+++ b/arch/ia64/Makefile
@@ -55,6 +55,7 @@ core-$(CONFIG_IA64_GENERIC) 	+=3D arch/ia64/dig/
 core-$(CONFIG_IA64_HP_ZX1)	+=3D arch/ia64/dig/
 core-$(CONFIG_IA64_HP_ZX1_SWIOTLB) +=3D arch/ia64/dig/
 core-$(CONFIG_IA64_SGI_SN2)	+=3D arch/ia64/sn/
+core-$(CONFIG_KVM) 		+=3D arch/ia64/kvm/
=20
 drivers-$(CONFIG_PCI)		+=3D arch/ia64/pci/
 drivers-$(CONFIG_IA64_HP_SIM)	+=3D arch/ia64/hp/sim/
--=20
1.5.1

------_=_NextPart_001_01C863F4.54C0DCD7
Content-Type: application/octet-stream;
	name="0020-kvm-ia64-Update-IA64-Kconfig-and-Makefile-to-includ.patch"
Content-Transfer-Encoding: base64
Content-Description: 0020-kvm-ia64-Update-IA64-Kconfig-and-Makefile-to-includ.patch
Content-Disposition: attachment;
	filename="0020-kvm-ia64-Update-IA64-Kconfig-and-Makefile-to-includ.patch"

RnJvbSA4MGY1MjljNjM0MmEwNzlkNGY3OThjZTg0ZmVhMTAwMTg0YjA4OThlIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBaaGFuZyBYaWFudGFvIDx4aWFudGFvLnpoYW5nQGludGVsLmNv
bT4KRGF0ZTogVHVlLCAyOSBKYW4gMjAwOCAxNTo0MDoyNyArMDgwMApTdWJqZWN0OiBbUEFUQ0hd
IGt2bS9pYTY0OiBVcGRhdGUgSUE2NCBLY29uZmlnIGFuZCBNYWtlZmlsZSB0byBpbmNsdWRlIGt2
bSBidWlsZC4KClVwZGF0ZSBJQTY0IEtjb25maWcgYW5kIE1ha2VmaWxlIHRvIGluY2x1ZGUga3Zt
IGJ1aWxkLgpTaWduZWQtb2ZmLWJ5OiBYaWFudGFvIFpoYW5nIDx4aWFudGFvLnpoYW5nQGludGVs
LmNvbT4KLS0tCiBhcmNoL2lhNjQvS2NvbmZpZyAgfCAgICA2ICsrKysrKwogYXJjaC9pYTY0L01h
a2VmaWxlIHwgICAgMSArCiAyIGZpbGVzIGNoYW5nZWQsIDcgaW5zZXJ0aW9ucygrKSwgMCBkZWxl
dGlvbnMoLSkKCmRpZmYgLS1naXQgYS9hcmNoL2lhNjQvS2NvbmZpZyBiL2FyY2gvaWE2NC9LY29u
ZmlnCmluZGV4IGJlZjQ3NzIuLjQ1OTIxMzAgMTAwNjQ0Ci0tLSBhL2FyY2gvaWE2NC9LY29uZmln
CisrKyBiL2FyY2gvaWE2NC9LY29uZmlnCkBAIC05OSw2ICs5OSwxMCBAQCBjb25maWcgQVVESVRf
QVJDSAogCWJvb2wKIAlkZWZhdWx0IHkKIAorY29uZmlnIEFSQ0hfU1VQUE9SVFNfS1ZNCisJYm9v
bAorCWRlZmF1bHQgeQorCiBjaG9pY2UKIAlwcm9tcHQgIlN5c3RlbSB0eXBlIgogCWRlZmF1bHQg
SUE2NF9HRU5FUklDCkBAIC01NjgsNiArNTcyLDggQEAgY29uZmlnIE1TUEVDCiAKIHNvdXJjZSAi
ZnMvS2NvbmZpZyIKIAorc291cmNlICJhcmNoL2lhNjQva3ZtL0tjb25maWciCisKIHNvdXJjZSAi
bGliL0tjb25maWciCiAKICMKZGlmZiAtLWdpdCBhL2FyY2gvaWE2NC9NYWtlZmlsZSBiL2FyY2gv
aWE2NC9NYWtlZmlsZQppbmRleCBiOTE2Y2NmLi5jOGQwOWJlIDEwMDY0NAotLS0gYS9hcmNoL2lh
NjQvTWFrZWZpbGUKKysrIGIvYXJjaC9pYTY0L01ha2VmaWxlCkBAIC01NSw2ICs1NSw3IEBAIGNv
cmUtJChDT05GSUdfSUE2NF9HRU5FUklDKSAJKz0gYXJjaC9pYTY0L2RpZy8KIGNvcmUtJChDT05G
SUdfSUE2NF9IUF9aWDEpCSs9IGFyY2gvaWE2NC9kaWcvCiBjb3JlLSQoQ09ORklHX0lBNjRfSFBf
WlgxX1NXSU9UTEIpICs9IGFyY2gvaWE2NC9kaWcvCiBjb3JlLSQoQ09ORklHX0lBNjRfU0dJX1NO
MikJKz0gYXJjaC9pYTY0L3NuLworY29yZS0kKENPTkZJR19LVk0pIAkJKz0gYXJjaC9pYTY0L2t2
bS8KIAogZHJpdmVycy0kKENPTkZJR19QQ0kpCQkrPSBhcmNoL2lhNjQvcGNpLwogZHJpdmVycy0k
KENPTkZJR19JQTY0X0hQX1NJTSkJKz0gYXJjaC9pYTY0L2hwL3NpbS8KLS0gCjEuNS4xCgo=

------_=_NextPart_001_01C863F4.54C0DCD7--
