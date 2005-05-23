From: "Zhang, Yanmin" <yanmin.zhang@intel.com>
Date: Mon, 23 May 2005 00:47:06 +0000
Subject: [PATCH] sys_mmap doesn't follow posix.1 when parameter len=0
Message-Id: <8126E4F969BA254AB43EA03C59F44E840222BCA7@pdsmsx404>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C55F31.55AC374D"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C55F31.55AC374D
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

In IA64 kernel, sys_mmap calls do_mmap2 and do_mmap2 returns addr if
len=3D0, which means the mmap sys call succeeds.

Posix.1 says:
The mmap() function shall fail if:
[EINVAL]=20
The value of len is zero.=20

Here is a patch to fix it.

Signed-off-by: Zhang Yanmin <yanmin.zhang@intel.com>

 <<do_mmap2_zero_len_2.6.12_rc4.patch>>=20

------_=_NextPart_001_01C55F31.55AC374D
Content-Type: application/octet-stream;
	name="do_mmap2_zero_len_2.6.12_rc4.patch"
Content-Transfer-Encoding: base64
Content-Description: do_mmap2_zero_len_2.6.12_rc4.patch
Content-Disposition: attachment;
	filename="do_mmap2_zero_len_2.6.12_rc4.patch"

ZGlmZiAtTnJhdXAgbGludXgtMi42LjEyLXJjNC9hcmNoL2lhNjQva2VybmVsL3N5c19pYTY0LmMg
bGludXgtMi42LjEyLXJjNF9maXgvYXJjaC9pYTY0L2tlcm5lbC9zeXNfaWE2NC5jCi0tLSBsaW51
eC0yLjYuMTItcmM0L2FyY2gvaWE2NC9rZXJuZWwvc3lzX2lhNjQuYwkyMDA1LTA1LTEzIDE0OjE0
OjEzLjAwMDAwMDAwMCArMDgwMAorKysgbGludXgtMi42LjEyLXJjNF9maXgvYXJjaC9pYTY0L2tl
cm5lbC9zeXNfaWE2NC5jCTIwMDUtMDUtMjAgMTM6MTA6MzIuMDAwMDAwMDAwICswODAwCkBAIC0x
ODIsMTMgKzE4Miw2IEBAIGRvX21tYXAyICh1bnNpZ25lZCBsb25nIGFkZHIsIHVuc2lnbmVkIGwK
IAkJfQogCX0KIAotCS8qCi0JICogQSB6ZXJvIG1tYXAgYWx3YXlzIHN1Y2NlZWRzIGluIExpbnV4
LCBpbmRlcGVuZGVudCBvZiB3aGV0aGVyIG9yIG5vdCB0aGUKLQkgKiByZW1haW5pbmcgYXJndW1l
bnRzIGFyZSB2YWxpZC4KLQkgKi8KLQlpZiAobGVuID09IDApCi0JCWdvdG8gb3V0OwotCiAJLyog
Q2FyZWZ1bCBhYm91dCBvdmVyZmxvd3MuLiAqLwogCWxlbiA9IFBBR0VfQUxJR04obGVuKTsKIAlp
ZiAoIWxlbiB8fCBsZW4gPiBUQVNLX1NJWkUpIHsK

------_=_NextPart_001_01C55F31.55AC374D--
