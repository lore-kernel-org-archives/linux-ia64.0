From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Thu, 31 Jan 2008 10:30:34 +0000
Subject: [PATCH][18]add Kconfig for kvm configuration.
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDCD31FD5@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C863F4.506C33BB"
List-Id: <linux-ia64.vger.kernel.org>
To: Avi Kivity <avi@qumranet.com>, "Luck, Tony" <tony.luck@intel.com>, "Xu, Anthony" <anthony.xu@intel.com>, "Zhang, Xiantao" <xiantao.zhang@intel.com>
Cc: kvm-devel@lists.sourceforge.net, kvm-ia64-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C863F4.506C33BB
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

From: Zhang Xiantao <xiantao.zhang@intel.com>
Date: Tue, 29 Jan 2008 14:42:44 +0800
Subject: [PATCH] kvm/ia64: add Kconfig for kvm configuration.

Kconfig adds kvm/ia64 configurations at kernel configuration
time.
Signed-off-by: Xiantao Zhang <xiantao.zhang@intel.com>
---
 arch/ia64/kvm/Kconfig |   43
+++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 43 insertions(+), 0 deletions(-)
 create mode 100644 arch/ia64/kvm/Kconfig

diff --git a/arch/ia64/kvm/Kconfig b/arch/ia64/kvm/Kconfig
new file mode 100644
index 0000000..aaeb7f1
--- /dev/null
+++ b/arch/ia64/kvm/Kconfig
@@ -0,0 +1,43 @@
+#
+# KVM configuration
+#
+menuconfig VIRTUALIZATION
+	bool "Virtualization"
+	depends on ARCH_SUPPORTS_KVM || IA64
+	default y
+	---help---
+	  Say Y here to get to see options for using your Linux host to
run other
+	  operating systems inside virtual machines (guests).
+	  This option alone does not add any kernel code.
+
+	  If you say N, all options in this submenu will be skipped and
disabled.
+
+if VIRTUALIZATION
+
+config KVM
+	tristate "Kernel-based Virtual Machine (KVM) support"
+	depends on ARCH_SUPPORTS_KVM && EXPERIMENTAL
+	select PREEMPT_NOTIFIERS
+	select ANON_INODES
+	---help---
+	  Support hosting fully virtualized guest machines using
hardware
+	  virtualization extensions.  You will need a fairly recent
+	  processor equipped with virtualization extensions. You will
also
+	  need to select one or more of the processor modules below.
+
+	  This module provides access to the hardware capabilities
through
+	  a character device node named /dev/kvm.
+
+	  To compile this as a module, choose M here: the module
+	  will be called kvm.
+
+	  If unsure, say N.
+
+config KVM_INTEL
+	tristate "KVM for Intel Itanium 2 processors support"
+	depends on KVM && m
+	---help---
+	  Provides support for KVM on Itanium 2 processors equipped with
the VT
+	  extensions.
+
+endif # VIRTUALIZATION
--=20
1.5.1

------_=_NextPart_001_01C863F4.506C33BB
Content-Type: application/octet-stream;
	name="0018-kvm-ia64-add-Kconfig-for-kvm-configuration.patch"
Content-Transfer-Encoding: base64
Content-Description: 0018-kvm-ia64-add-Kconfig-for-kvm-configuration.patch
Content-Disposition: attachment;
	filename="0018-kvm-ia64-add-Kconfig-for-kvm-configuration.patch"

RnJvbSAwOTQ3ZWM4YjZhMzIxZmIwYjk2NTRhOTMzMTE4NjRlMGI5ZTc0Njk5IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBaaGFuZyBYaWFudGFvIDx4aWFudGFvLnpoYW5nQGludGVsLmNv
bT4KRGF0ZTogVHVlLCAyOSBKYW4gMjAwOCAxNDo0Mjo0NCArMDgwMApTdWJqZWN0OiBbUEFUQ0hd
IGt2bS9pYTY0OiBhZGQgS2NvbmZpZyBmb3Iga3ZtIGNvbmZpZ3VyYXRpb24uCgpLY29uZmlnIGFk
ZHMga3ZtL2lhNjQgY29uZmlndXJhdGlvbnMgYXQga2VybmVsIGNvbmZpZ3VyYXRpb24KdGltZS4K
U2lnbmVkLW9mZi1ieTogWGlhbnRhbyBaaGFuZyA8eGlhbnRhby56aGFuZ0BpbnRlbC5jb20+Ci0t
LQogYXJjaC9pYTY0L2t2bS9LY29uZmlnIHwgICA0MyArKysrKysrKysrKysrKysrKysrKysrKysr
KysrKysrKysrKysrKysrKysrCiAxIGZpbGVzIGNoYW5nZWQsIDQzIGluc2VydGlvbnMoKyksIDAg
ZGVsZXRpb25zKC0pCiBjcmVhdGUgbW9kZSAxMDA2NDQgYXJjaC9pYTY0L2t2bS9LY29uZmlnCgpk
aWZmIC0tZ2l0IGEvYXJjaC9pYTY0L2t2bS9LY29uZmlnIGIvYXJjaC9pYTY0L2t2bS9LY29uZmln
Cm5ldyBmaWxlIG1vZGUgMTAwNjQ0CmluZGV4IDAwMDAwMDAuLmFhZWI3ZjEKLS0tIC9kZXYvbnVs
bAorKysgYi9hcmNoL2lhNjQva3ZtL0tjb25maWcKQEAgLTAsMCArMSw0MyBAQAorIworIyBLVk0g
Y29uZmlndXJhdGlvbgorIworbWVudWNvbmZpZyBWSVJUVUFMSVpBVElPTgorCWJvb2wgIlZpcnR1
YWxpemF0aW9uIgorCWRlcGVuZHMgb24gQVJDSF9TVVBQT1JUU19LVk0gfHwgSUE2NAorCWRlZmF1
bHQgeQorCS0tLWhlbHAtLS0KKwkgIFNheSBZIGhlcmUgdG8gZ2V0IHRvIHNlZSBvcHRpb25zIGZv
ciB1c2luZyB5b3VyIExpbnV4IGhvc3QgdG8gcnVuIG90aGVyCisJICBvcGVyYXRpbmcgc3lzdGVt
cyBpbnNpZGUgdmlydHVhbCBtYWNoaW5lcyAoZ3Vlc3RzKS4KKwkgIFRoaXMgb3B0aW9uIGFsb25l
IGRvZXMgbm90IGFkZCBhbnkga2VybmVsIGNvZGUuCisKKwkgIElmIHlvdSBzYXkgTiwgYWxsIG9w
dGlvbnMgaW4gdGhpcyBzdWJtZW51IHdpbGwgYmUgc2tpcHBlZCBhbmQgZGlzYWJsZWQuCisKK2lm
IFZJUlRVQUxJWkFUSU9OCisKK2NvbmZpZyBLVk0KKwl0cmlzdGF0ZSAiS2VybmVsLWJhc2VkIFZp
cnR1YWwgTWFjaGluZSAoS1ZNKSBzdXBwb3J0IgorCWRlcGVuZHMgb24gQVJDSF9TVVBQT1JUU19L
Vk0gJiYgRVhQRVJJTUVOVEFMCisJc2VsZWN0IFBSRUVNUFRfTk9USUZJRVJTCisJc2VsZWN0IEFO
T05fSU5PREVTCisJLS0taGVscC0tLQorCSAgU3VwcG9ydCBob3N0aW5nIGZ1bGx5IHZpcnR1YWxp
emVkIGd1ZXN0IG1hY2hpbmVzIHVzaW5nIGhhcmR3YXJlCisJICB2aXJ0dWFsaXphdGlvbiBleHRl
bnNpb25zLiAgWW91IHdpbGwgbmVlZCBhIGZhaXJseSByZWNlbnQKKwkgIHByb2Nlc3NvciBlcXVp
cHBlZCB3aXRoIHZpcnR1YWxpemF0aW9uIGV4dGVuc2lvbnMuIFlvdSB3aWxsIGFsc28KKwkgIG5l
ZWQgdG8gc2VsZWN0IG9uZSBvciBtb3JlIG9mIHRoZSBwcm9jZXNzb3IgbW9kdWxlcyBiZWxvdy4K
KworCSAgVGhpcyBtb2R1bGUgcHJvdmlkZXMgYWNjZXNzIHRvIHRoZSBoYXJkd2FyZSBjYXBhYmls
aXRpZXMgdGhyb3VnaAorCSAgYSBjaGFyYWN0ZXIgZGV2aWNlIG5vZGUgbmFtZWQgL2Rldi9rdm0u
CisKKwkgIFRvIGNvbXBpbGUgdGhpcyBhcyBhIG1vZHVsZSwgY2hvb3NlIE0gaGVyZTogdGhlIG1v
ZHVsZQorCSAgd2lsbCBiZSBjYWxsZWQga3ZtLgorCisJICBJZiB1bnN1cmUsIHNheSBOLgorCitj
b25maWcgS1ZNX0lOVEVMCisJdHJpc3RhdGUgIktWTSBmb3IgSW50ZWwgSXRhbml1bSAyIHByb2Nl
c3NvcnMgc3VwcG9ydCIKKwlkZXBlbmRzIG9uIEtWTSAmJiBtCisJLS0taGVscC0tLQorCSAgUHJv
dmlkZXMgc3VwcG9ydCBmb3IgS1ZNIG9uIEl0YW5pdW0gMiBwcm9jZXNzb3JzIGVxdWlwcGVkIHdp
dGggdGhlIFZUCisJICBleHRlbnNpb25zLgorCitlbmRpZiAjIFZJUlRVQUxJWkFUSU9OCi0tIAox
LjUuMQoK

------_=_NextPart_001_01C863F4.506C33BB--
