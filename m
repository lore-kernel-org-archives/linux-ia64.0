From: Arun Sharma <arun.sharma@intel.com>
Date: Tue, 24 Jun 2003 22:21:56 +0000
Subject: IA-32 support patch: mmap should return ENOMEM
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------070800000900030800080806"
Message-Id: <marc-linux-ia64-105649349511116@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------070800000900030800080806
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit


Single Unix Specification says:
[ENOMEM] MAP_FIXED was specified, and the range [addr, addr + len) exceeds that allowed for the address space of a process.

Therefore if addr + len > IA32_PAGE_OFFSET, we should return ENOMEM.

Please apply to both 2.4 and 2.5.

	-Arun


--------------070800000900030800080806
Content-Type: text/plain;
 name="mmap-enomem.24.txt"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="mmap-enomem.24.txt"

LS0tIGxpbnV4L2FyY2gvaWE2NC9pYTMyL3N5c19pYTMyLmMtCTIwMDMtMDUtMjcgMTg6NDk6
NDMuMDAwMDAwMDAwIC0wNzAwDQorKysgbGludXgvYXJjaC9pYTY0L2lhMzIvc3lzX2lhMzIu
YwkyMDAzLTA1LTI4IDIzOjM3OjAyLjAwMDAwMDAwMCAtMDcwMA0KQEAgLTQ0OCw3ICs0NDgs
MTIgQEANCiAJCXJldHVybiBhZGRyOw0KIA0KIAlpZiAobGVuID4gSUEzMl9QQUdFX09GRlNF
VCB8fCBhZGRyID4gSUEzMl9QQUdFX09GRlNFVCAtIGxlbikNCisJew0KKwkJaWYgKGZsYWdz
ICYgTUFQX0ZJWEVEKQ0KKwkJCXJldHVybiAtRU5PTUVNOw0KKwkJZWxzZQ0KIAkJcmV0dXJu
IC1FSU5WQUw7DQorCX0NCiANCiAJaWYgKE9GRlNFVDRLKG9mZnNldCkpDQogCQlyZXR1cm4g
LUVJTlZBTDsNCg0KDQo=
--------------070800000900030800080806--

