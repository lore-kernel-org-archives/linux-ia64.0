From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 26 Sep 2003 23:11:16 +0000
Subject: Hugetlbfs and hugetlb_page config menu
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C38483.7C946E96"
Message-Id: <marc-linux-ia64-106461789029929@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C38483.7C946E96
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: quoted-printable

Hugetlbfs is not module'able at current state, so tristate the "HugeTLB
file system support" option is kind of silly.  Also, at present you can
set CONFIG_HUGETLB_PAGE and not CONFIG_HUGETLBFS, which give the kernel
low-level hugepage support, but no userspace API to access it is also
kind of silly.

While I'm at it, here is a patch that flips dependency around:
CONFIG_HUGETLB_PAGE mirrors CONFIG_HUGETLBFS option and hugetlb page
size selection appear/disappear depending on whether hugetlbfs is
selected or not.  (this is taken from 2.6).

- Ken

------_=_NextPart_001_01C38483.7C946E96
Content-Type: application/octet-stream;
	name="hugetlbfs-config.patch"
Content-Transfer-Encoding: base64
Content-Description: hugetlbfs-config.patch
Content-Disposition: attachment;
	filename="hugetlbfs-config.patch"

ZGlmZiAtTnVyIDIuNC4yMy1wcmU1L2FyY2gvaWE2NC9jb25maWcuaW4gMi40LjIzLXByZTUua2Vu
L2FyY2gvaWE2NC9jb25maWcuaW4KLS0tIDIuNC4yMy1wcmU1L2FyY2gvaWE2NC9jb25maWcuaW4J
RnJpIFNlcCAyNiAxNDoyMTo1NCAyMDAzCisrKyAyLjQuMjMtcHJlNS5rZW4vYXJjaC9pYTY0L2Nv
bmZpZy5pbglGcmkgU2VwIDI2IDE1OjU1OjIwIDIwMDMKQEAgLTg2LDggKzg2LDYgQEAKIAogZGVm
aW5lX2ludCBDT05GSUdfRk9SQ0VfTUFYX1pPTkVPUkRFUiAxOQogCi1ib29sICdJQS02NCBIdWdl
IFRMQiBQYWdlIFN1cHBvcnQnIENPTkZJR19IVUdFVExCX1BBR0UKLQogaWYgWyAiJENPTkZJR19I
VUdFVExCX1BBR0UiID0gInkiIF07IHRoZW4KIAlpZiBbICIkQ09ORklHX01DS0lOTEVZIiA9ICJ5
IiBdOyB0aGVuCiAJCWNob2ljZSAnICAgIElBLTY0IEh1Z2UgVExCIFBhZ2UgU2l6ZScJCVwKZGlm
ZiAtTnVyIDIuNC4yMy1wcmU1L2ZzL0NvbmZpZy5pbiAyLjQuMjMtcHJlNS5rZW4vZnMvQ29uZmln
LmluCi0tLSAyLjQuMjMtcHJlNS9mcy9Db25maWcuaW4JRnJpIFNlcCAyNiAxNDoyMjowMyAyMDAz
CisrKyAyLjQuMjMtcHJlNS5rZW4vZnMvQ29uZmlnLmluCUZyaSBTZXAgMjYgMTU6NTY6NTEgMjAw
MwpAQCAtNTQsOCArNTQsMTEgQEAKIGJvb2wgJ1ZpcnR1YWwgbWVtb3J5IGZpbGUgc3lzdGVtIHN1
cHBvcnQgKGZvcm1lciBzaG0gZnMpJyBDT05GSUdfVE1QRlMKIGRlZmluZV9ib29sIENPTkZJR19S
QU1GUyB5CiAKLWlmIFsgIiRDT05GSUdfSFVHRVRMQl9QQUdFIiA9ICJ5IiBdOyB0aGVuCi0JdHJp
c3RhdGUgJ0h1Z2VUTEIgZmlsZSBzeXN0ZW0gc3VwcG9ydCcgQ09ORklHX0hVR0VUTEJGUyAKK2Jv
b2wgJ0h1Z2VUTEIgZmlsZSBzeXN0ZW0gc3VwcG9ydCcgQ09ORklHX0hVR0VUTEJGUworaWYgWyAi
JENPTkZJR19IVUdFVExCRlMiID0gInkiIF07IHRoZW4KKwlkZWZpbmVfYm9vbCBDT05GSUdfSFVH
RVRMQl9QQUdFIHkKK2Vsc2UKKwlkZWZpbmVfYm9vbCBDT05GSUdfSFVHRVRMQl9QQUdFIG4KIGZp
CiAKIHRyaXN0YXRlICdJU08gOTY2MCBDRFJPTSBmaWxlIHN5c3RlbSBzdXBwb3J0JyBDT05GSUdf
SVNPOTY2MF9GUwo=

------_=_NextPart_001_01C38483.7C946E96--
