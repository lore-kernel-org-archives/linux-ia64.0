From: "Zhang, Yanmin" <yanmin.zhang@intel.com>
Date: Wed, 18 Aug 2004 01:42:49 +0000
Subject: Bug in function find_bootmap_location in kernel 2.6.8
Message-Id: <8126E4F969BA254AB43EA03C59F44E842B6AC4@pdsmsx404>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C484C4.AB9790B0"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C484C4.AB9790B0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Function find_bootmap_location has 2 bugs.

Firstly, if it's done successfully, it should return -1 instead of 1
because its caller, efi_memmap_walk, will end when find_bootmap_location
returns a value smaller than 0.

Secondly, statement 'free_start =3D PAGE_ALIGN(rsvd_region[i].end)' =
should
been moved forward. free_start needs to be initialized for every loop
iteration.  Current implementation is buggy where initialization is
skipped if range_end <=3D range_start.  Skipping initializing will leads
to overlapping bootmap with one of the rsvd_regions and subsequently
kernel hang at boot time.

Here is the patch to fix them against kernel 2.6.8.

Singed-off-by:	Zhang Yanmin <yanmin.zhang@intel.com>
Signed-off-by:	Yao Jun		<junx.yao@intel.com>



 <<find_bootmap_location_err.patch.diff>>=20

------_=_NextPart_001_01C484C4.AB9790B0
Content-Type: application/octet-stream;
	name="find_bootmap_location_err.patch.diff"
Content-Transfer-Encoding: base64
Content-Description: find_bootmap_location_err.patch.diff
Content-Disposition: attachment;
	filename="find_bootmap_location_err.patch.diff"

ZGlmZiAtTnJhdXAgbGludXgtMi42LjgvYXJjaC9pYTY0L21tL2NvbnRpZy5jIGxpbnV4LTIuNi44
X2ZpeC9hcmNoL2lhNjQvbW0vY29udGlnLmMKLS0tIGxpbnV4LTIuNi44L2FyY2gvaWE2NC9tbS9j
b250aWcuYwkyMDA0LTA4LTE2IDA3OjU5OjU4LjU0MjI4MDM3MCArMDgwMAorKysgbGludXgtMi42
LjhfZml4L2FyY2gvaWE2NC9tbS9jb250aWcuYwkyMDA0LTA4LTE2IDA4OjEwOjI5LjU5MTEwMDc2
NSArMDgwMApAQCAtMTE2LDE5ICsxMTYsMTkgQEAgZmluZF9ib290bWFwX2xvY2F0aW9uICh1bnNp
Z25lZCBsb25nIHN0YQogCQlyYW5nZV9zdGFydCA9IG1heChzdGFydCwgZnJlZV9zdGFydCk7CiAJ
CXJhbmdlX2VuZCAgID0gbWluKGVuZCwgcnN2ZF9yZWdpb25baV0uc3RhcnQgJiBQQUdFX01BU0sp
OwogCisJCWZyZWVfc3RhcnQgPSBQQUdFX0FMSUdOKHJzdmRfcmVnaW9uW2ldLmVuZCk7CisKIAkJ
aWYgKHJhbmdlX2VuZCA8PSByYW5nZV9zdGFydCkKIAkJCWNvbnRpbnVlOyAvKiBza2lwIG92ZXIg
ZW1wdHkgcmFuZ2UgKi8KIAotCSAgICAgICAJaWYgKHJhbmdlX2VuZCAtIHJhbmdlX3N0YXJ0ID49
IG5lZWRlZCkgeworCQlpZiAocmFuZ2VfZW5kIC0gcmFuZ2Vfc3RhcnQgPj0gbmVlZGVkKSB7CiAJ
CQlib290bWFwX3N0YXJ0ID0gX19wYShyYW5nZV9zdGFydCk7Ci0JCQlyZXR1cm4gMTsJLyogZG9u
ZSAqLworCQkJcmV0dXJuIC0xOwkvKiBkb25lICovCiAJCX0KIAogCQkvKiBub3RoaW5nIG1vcmUg
YXZhaWxhYmxlIGluIHRoaXMgc2VnbWVudCAqLwogCQlpZiAocmFuZ2VfZW5kID09IGVuZCkKIAkJ
CXJldHVybiAwOwotCi0JCWZyZWVfc3RhcnQgPSBQQUdFX0FMSUdOKHJzdmRfcmVnaW9uW2ldLmVu
ZCk7CiAJfQogCXJldHVybiAwOwogfQo=

------_=_NextPart_001_01C484C4.AB9790B0--
