From: "Zou, Nanhai" <nanhai.zou@intel.com>
Date: Tue, 28 Sep 2004 05:47:08 +0000
Subject: [PATCH] remove an unused efi_memmap_walk in arch/iak4/mm/discontig.c
Message-Id: <894E37DECA393E4D9374E0ACBBE7427013C8E9@pdsmsx402.ccr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C4A51E.9799CE47"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C4A51E.9799CE47
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: quoted-printable

max_gap is not used in discontig.c.
This patch is to remove it and the related efi_memmap_walk.

Signed-off-by: Zou Nan hai <Nanhai.zou@intel.com>
Zou Nan hai

------_=_NextPart_001_01C4A51E.9799CE47
Content-Type: application/octet-stream;
	name="remove_an_unused_efi_memmap_walk_ia64.patch"
Content-Transfer-Encoding: base64
Content-Description: remove_an_unused_efi_memmap_walk_ia64.patch
Content-Disposition: attachment;
	filename="remove_an_unused_efi_memmap_walk_ia64.patch"

ZGlmZiAtTnJhdXAgYS9hcmNoL2lhNjQvbW0vZGlzY29udGlnLmMgYi9hcmNoL2lhNjQvbW0vZGlz
Y29udGlnLmMKLS0tIGEvYXJjaC9pYTY0L21tL2Rpc2NvbnRpZy5jCTIwMDQtMDktMTIgMjI6MzM6
MjMuMDAwMDAwMDAwIC0wNzAwCisrKyBiL2FyY2gvaWE2NC9tbS9kaXNjb250aWcuYwkyMDA0LTA5
LTI2IDA0OjUxOjAwLjYyNDI4NTMyNyAtMDcwMApAQCAtNjE4LDEyICs2MTgsMTAgQEAgdm9pZCBw
YWdpbmdfaW5pdCh2b2lkKQogCXVuc2lnbmVkIGxvbmcgbWF4X2RtYTsKIAl1bnNpZ25lZCBsb25n
IHpvbmVzX3NpemVbTUFYX05SX1pPTkVTXTsKIAl1bnNpZ25lZCBsb25nIHpob2xlc19zaXplW01B
WF9OUl9aT05FU107Ci0JdW5zaWduZWQgbG9uZyBtYXhfZ2FwLCBwZm5fb2Zmc2V0ID0gMDsKKwl1
bnNpZ25lZCBsb25nIHBmbl9vZmZzZXQgPSAwOwogCWludCBub2RlOwogCiAJbWF4X2RtYSA9IHZp
cnRfdG9fcGh5cygodm9pZCAqKSBNQVhfRE1BX0FERFJFU1MpID4+IFBBR0VfU0hJRlQ7Ci0JbWF4
X2dhcCA9IDA7Ci0JZWZpX21lbW1hcF93YWxrKGZpbmRfbGFyZ2VzdF9ob2xlLCAmbWF4X2dhcCk7
CiAKIAkvKiBzbyBtaW4oKSB3aWxsIHdvcmsgaW4gY291bnRfbm9kZV9wYWdlcyAqLwogCWZvciAo
bm9kZSA9IDA7IG5vZGUgPCBudW1ub2Rlczsgbm9kZSsrKQo=

------_=_NextPart_001_01C4A51E.9799CE47--
