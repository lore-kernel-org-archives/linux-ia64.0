From: Arun Sharma <arun.sharma@intel.com>
Date: Tue, 24 Jun 2003 22:12:38 +0000
Subject: IA-32 support patch: msgsnd/msgrcv return value off by 4
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------070501040307040200010001"
Message-Id: <marc-linux-ia64-105649278110408@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------070501040307040200010001
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit


The return value of do_sys32_msgsnd() is off by 4. This seems to be a bug inherited from sparc64, fixed in the x86_64 tree in 2.5.

Please apply to both 2.4 and 2.5 trees.

	-Arun

--------------070501040307040200010001
Content-Type: text/plain;
 name="msgrcv.19.txt"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="msgrcv.19.txt"

LS0tIGxpbnV4L2FyY2gvaWE2NC9pYTMyL3N5c19pYTMyLmMtCTIwMDMtMDYtMjMgMDk6MzA6
MTMuMDAwMDAwMDAwICswODAwDQorKysgbGludXgvYXJjaC9pYTY0L2lhMzIvc3lzX2lhMzIu
YwkyMDAzLTA2LTIzIDA5OjI5OjIwLjAwMDAwMDAwMCArMDgwMA0KQEAgLTIyNjIsNyArMjI2
Miw3IEBADQogc3RhdGljIGludA0KIGRvX3N5czMyX21zZ3NuZCAoaW50IGZpcnN0LCBpbnQg
c2Vjb25kLCBpbnQgdGhpcmQsIHZvaWQgKnVwdHIpDQogew0KLQlzdHJ1Y3QgbXNnYnVmICpw
ID0ga21hbGxvYyhzZWNvbmQgKyBzaXplb2Yoc3RydWN0IG1zZ2J1ZikgKyA0LCBHRlBfVVNF
Uik7DQorCXN0cnVjdCBtc2didWYgKnAgPSBrbWFsbG9jKHNlY29uZCArIHNpemVvZihzdHJ1
Y3QgbXNnYnVmKSwgR0ZQX1VTRVIpOw0KIAlzdHJ1Y3QgbXNnYnVmMzIgKnVwID0gKHN0cnVj
dCBtc2didWYzMiAqKXVwdHI7DQogCW1tX3NlZ21lbnRfdCBvbGRfZnM7DQogCWludCBlcnI7
DQpAQCAtMjMwNCwxMiArMjMwNCwxMiBAQA0KIAkJbXNndHlwID0gaXBjay5tc2d0eXA7DQog
CX0NCiAJZXJyID0gLUVOT01FTTsNCi0JcCA9IGttYWxsb2Moc2Vjb25kICsgc2l6ZW9mKHN0
cnVjdCBtc2didWYpICsgNCwgR0ZQX1VTRVIpOw0KKwlwID0ga21hbGxvYyhzZWNvbmQgKyBz
aXplb2Yoc3RydWN0IG1zZ2J1ZiksIEdGUF9VU0VSKTsNCiAJaWYgKCFwKQ0KIAkJZ290byBv
dXQ7DQogCW9sZF9mcyA9IGdldF9mcygpOw0KIAlzZXRfZnMoS0VSTkVMX0RTKTsNCi0JZXJy
ID0gc3lzX21zZ3JjdihmaXJzdCwgcCwgc2Vjb25kICsgNCwgbXNndHlwLCB0aGlyZCk7DQor
CWVyciA9IHN5c19tc2dyY3YoZmlyc3QsIHAsIHNlY29uZCwgbXNndHlwLCB0aGlyZCk7DQog
CXNldF9mcyhvbGRfZnMpOw0KIAlpZiAoZXJyIDwgMCkNCiAJCWdvdG8gZnJlZV90aGVuX291
dDsNCg0KDQo=
--------------070501040307040200010001--

