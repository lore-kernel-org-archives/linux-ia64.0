From: Arun Sharma <adsharma@unix-os.sc.intel.com>
Date: Wed, 20 Aug 2003 20:39:51 +0000
Subject: IA-32 compatibility patch: FP denormal handling
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------040603080002070204040500"
Message-Id: <marc-linux-ia64-106141205114677@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------040603080002070204040500
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit


The following patch makes ia64 compatible with i386 with respect to siginfo.si_code on FP denormal operands. This is necessary for the correct emulation of many IA-32 apps.

Please apply to both 2.4 and 2.5.

	-Arun



--------------040603080002070204040500
Content-Type: text/plain;
 name="fp-denormal.patch"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="fp-denormal.patch"

LS0tIGxpbnV4L2FyY2gvaWE2NC9rZXJuZWwvdHJhcHMuYy5vcmlnCUZyaSBBcHIgMjAgMTk6
MDg6MDEgMjAwMQorKysgbGludXgvYXJjaC9pYTY0L2tlcm5lbC90cmFwcy5jCVRodSBKdWwg
IDUgMTM6MzY6NTMgMjAwMQpAQCAtMzI1LDYgKzMyNSwxMCBAQAogCQkJc2lnaW5mby5zaV9h
ZGRyID0gKHZvaWQgKikgKHJlZ3MtPmNyX2lpcCArIGlhNjRfcHNyKHJlZ3MpLT5yaSk7CiAJ
CQlpZiAoaXNyICYgMHgxMSkgewogCQkJCXNpZ2luZm8uc2lfY29kZSA9IEZQRV9GTFRJTlY7
CisJCQl9IGVsc2UgaWYgKGlzciAmIDB4MjIpIHsKKwkJCQkvKiBkZW5vcm1hbCBvcGVyYW5k
IGdldHMgdGhlIHNhbWUgc2lfY29kZSBhcyB1bmRlcmZsb3cgCisJCQkJKiBzZWUgYXJjaC9p
Mzg2L2tlcm5lbC90cmFwcy5jOm1hdGhfZXJyb3IoKSAgKi8KKwkJCQlzaWdpbmZvLnNpX2Nv
ZGUgPSBGUEVfRkxUVU5EOwogCQkJfSBlbHNlIGlmIChpc3IgJiAweDQ0KSB7CiAJCQkJc2ln
aW5mby5zaV9jb2RlID0gRlBFX0ZMVERJVjsKIAkJCX0K
--------------040603080002070204040500--

