From: Arun Sharma <arun.sharma@intel.com>
Date: Tue, 24 Jun 2003 22:51:08 +0000
Subject: IA-32 support patch: fcntl64 calls are broken
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------020701040306010302040000"
Message-Id: <marc-linux-ia64-105649509512709@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------020701040306010302040000
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit


Currently, sys32_fcntl64() is broken, because it passes F_*64 commands to sys_fcntl(), which it doesn't understand. The F_XXX64 commands need to be converted to F_XXX before calling sys_fcntl().

We also eliminated a copy, because the 32 bit struct flock64 and the 64 bit struct flock seem to be identical.

This patch is relevant only to 2.4, as it has already been taken care of in 2.5.

	-Arun

--------------020701040306010302040000
Content-Type: text/plain;
 name="fcntl.29.txt"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="fcntl.29.txt"

LS0tIGxpbnV4L2FyY2gvaWE2NC9pYTMyL3N5c19pYTMyLmMtCTIwMDMtMDUtMjggMjM6Mzc6
MDIuMDAwMDAwMDAwIC0wNzAwDQorKysgbGludXgvYXJjaC9pYTY0L2lhMzIvc3lzX2lhMzIu
YwkyMDAzLTA2LTI0IDAyOjQ3OjEwLjAwMDAwMDAwMCAtMDcwMA0KQEAgLTM2MTgsMTQgKzM1
OTUsOSBAQA0KIAkgICAgICBjYXNlIEZfR0VUTEs2NDoNCiAJICAgICAgY2FzZSBGX1NFVExL
NjQ6DQogCSAgICAgIGNhc2UgRl9TRVRMS1c2NDoNCi0JCWlmIChpYTMyX2dldF9mbG9jaygm
ZiwgYXJnKSkNCi0JCQlyZXR1cm4gLUVGQVVMVDsNCi0JCW9sZF9mcyA9IGdldF9mcygpOw0K
LQkJc2V0X2ZzKEtFUk5FTF9EUyk7DQotCQlyZXQgPSBzeXNfZmNudGwoZmQsIGNtZCwgKHVu
c2lnbmVkIGxvbmcpICZmKTsNCi0JCXNldF9mcyhvbGRfZnMpOw0KLQkJaWYgKGNtZCA9PSBG
X0dFVExLICYmIGlhMzJfcHV0X2Zsb2NrKCZmLCBhcmcpKQ0KLQkJCXJldHVybiAtRUZBVUxU
Ow0KKwkJcmV0ID0gc3lzX2ZjbnRsKGZkLCAoY21kID09IEZfR0VUTEs2NCkgPyBGX0dFVExL
IDoNCisJCQkoKGNtZCA9PSBGX1NFVExLNjQpID8gRl9TRVRMSyA6IEZfU0VUTEtXKSwNCisJ
CQkodW5zaWduZWQgbG9uZylhcmcpOw0KIAkJYnJlYWs7DQogDQogCSAgICAgIGRlZmF1bHQ6
DQoNCg0K
--------------020701040306010302040000--

