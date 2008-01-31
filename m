From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Thu, 31 Jan 2008 10:28:12 +0000
Subject: [PATCH] [01]Appoint kvm/ia64 maintainers
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDCD31FC4@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C863F3.FBDB849B"
List-Id: <linux-ia64.vger.kernel.org>
To: Avi Kivity <avi-atKUWr5tajBWk0Htik3J/w@public.gmane.org>, "Luck, Tony" <tony.luck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, "Xu, Anthony" <anthony.xu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, "Zhang, Xiantao" <xiantao.zhang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: kvm-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kvm-ia64-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C863F3.FBDB849B
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

From: Zhang Xiantao <xiantao.zhang@intel.com>
Date: Thu, 31 Jan 2008 12:03:39 +0800
Subject: [PATCH] Appoint kvm/ia64 Maintainers

Signed-off-by Anthony Xu <anthony.xu@intel.com>
Signed-off-by Xiantao Zhang <xiantao.zhang@intel.com>
---
 MAINTAINERS |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 3c7db62..8c54fc3 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2219,6 +2219,15 @@ L:	kvm-devel@lists.sourceforge.net
 W:	kvm.sourceforge.net
 S:	Supported
=20
+KERNEL VIRTUAL MACHINE For Itanium(KVM/IA64)
+P:	Anthony Xu
+M:	anthony.xu@intel.com
+P:	Xiantao Zhang
+M:	xiantao.zhang@intel.com
+L:	kvm-ia64-devel@lists.sourceforge.net
+W:	kvm.sourceforge.net
+S:	Supported
+
 KEXEC
 P:	Eric Biederman
 M:	ebiederm@xmission.com
--=20
1.5.1

------_=_NextPart_001_01C863F3.FBDB849B
Content-Type: application/octet-stream;
	name="0001-Appoint-kvm-ia64-Maintainers.patch"
Content-Transfer-Encoding: base64
Content-Description: 0001-Appoint-kvm-ia64-Maintainers.patch
Content-Disposition: attachment;
	filename="0001-Appoint-kvm-ia64-Maintainers.patch"

RnJvbSA3NWQzNGQ4YzVlOWNkN2JhNzhmZjhlM2ZmN2QxNzU0YWIwNGYyZmRiIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBaaGFuZyBYaWFudGFvIDx4aWFudGFvLnpoYW5nQGludGVsLmNv
bT4KRGF0ZTogVGh1LCAzMSBKYW4gMjAwOCAxMjowMzozOSArMDgwMApTdWJqZWN0OiBbUEFUQ0hd
IEFwcG9pbnQga3ZtL2lhNjQgTWFpbnRhaW5lcnMKClNpZ25lZC1vZmYtYnkgQW50aG9ueSBYdSA8
YW50aG9ueS54dUBpbnRlbC5jb20+ClNpZ25lZC1vZmYtYnkgWGlhbnRhbyBaaGFuZyA8eGlhbnRh
by56aGFuZ0BpbnRlbC5jb20+Ci0tLQogTUFJTlRBSU5FUlMgfCAgICA5ICsrKysrKysrKwogMSBm
aWxlcyBjaGFuZ2VkLCA5IGluc2VydGlvbnMoKyksIDAgZGVsZXRpb25zKC0pCgpkaWZmIC0tZ2l0
IGEvTUFJTlRBSU5FUlMgYi9NQUlOVEFJTkVSUwppbmRleCAzYzdkYjYyLi44YzU0ZmMzIDEwMDY0
NAotLS0gYS9NQUlOVEFJTkVSUworKysgYi9NQUlOVEFJTkVSUwpAQCAtMjIxOSw2ICsyMjE5LDE1
IEBAIEw6CWt2bS1kZXZlbEBsaXN0cy5zb3VyY2Vmb3JnZS5uZXQKIFc6CWt2bS5zb3VyY2Vmb3Jn
ZS5uZXQKIFM6CVN1cHBvcnRlZAogCitLRVJORUwgVklSVFVBTCBNQUNISU5FIEZvciBJdGFuaXVt
KEtWTS9JQTY0KQorUDoJQW50aG9ueSBYdQorTToJYW50aG9ueS54dUBpbnRlbC5jb20KK1A6CVhp
YW50YW8gWmhhbmcKK006CXhpYW50YW8uemhhbmdAaW50ZWwuY29tCitMOglrdm0taWE2NC1kZXZl
bEBsaXN0cy5zb3VyY2Vmb3JnZS5uZXQKK1c6CWt2bS5zb3VyY2Vmb3JnZS5uZXQKK1M6CVN1cHBv
cnRlZAorCiBLRVhFQwogUDoJRXJpYyBCaWVkZXJtYW4KIE06CWViaWVkZXJtQHhtaXNzaW9uLmNv
bQotLSAKMS41LjEKCg==

------_=_NextPart_001_01C863F3.FBDB849B--
