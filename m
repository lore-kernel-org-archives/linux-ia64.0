From: "Pallipadi, Venkatesh" <venkatesh.pallipadi@intel.com>
Date: Wed, 27 Nov 2002 01:45:20 +0000
Subject: [Linux-ia64] [PATCH] IA32 exception handler: restore of instruction and data pointers
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C295B6.A5315CC6"
Message-Id: <marc-linux-ia64-105590709805491@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C295B6.A5315CC6
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

Hi,

One more patch in the series of IA32 exception handling patches. I had
thought that during an IA32 exception handling, the fields cssel, ipoff,
datasel and dataoff are READONLY information. But, as it turns out, they
are not. They need to be restored while returning from the exception=20
handler.

The attached patch does the following:
1) restores cssel, ipoff, datasel and dataoff properly during the return
from exception handler
2) An additional check to maintain correctness while restoring the=20
exception status word

Please let me know, if you need any more information on this.

Thanks,
-Venkatesh

--- arch/ia64/ia32/ia32_signal.c.org1	Fri Nov 15 13:25:09 2002
+++ arch/ia64/ia32/ia32_signal.c	Mon Nov 25 11:35:06 2002
@@ -165,10 +165,10 @@
  *    sw         ar.fsr(0:15)
  *    tag        ar.fsr(16:31)               with odd numbered bits not =
used
  *                                           (read returns 0, writes =
ignored)
- *    ipoff      ar.fir(0:31)   RO
- *    cssel      ar.fir(32:47)  RO
- *    dataoff    ar.fdr(0:31)   RO
- *    datasel    ar.fdr(32:47)  RO
+ *    ipoff      ar.fir(0:31)    =20
+ *    cssel      ar.fir(32:47)    =20
+ *    dataoff    ar.fdr(0:31)     =20
+ *    datasel    ar.fdr(32:47)    =20
  *   =20
  *    _st[(0+TOS)%8]   f8
  *    _st[(1+TOS)%8]   f9                    (f8, f9 from ptregs)
@@ -328,7 +328,7 @@
 	unsigned long num64, mxcsr;
 	struct _fpreg_ia32 *fpregp;
 	char buf[32];
-	unsigned long fsr, fcr;
+	unsigned long fsr, fcr, fir, fdr;
 	int fp_tos, fr8_st_map;
=20
 	if (!access_ok(VERIFY_READ, save, sizeof(*save)))
@@ -345,6 +345,8 @@
 	 */
 	asm volatile ( "mov %0=3Dar.fsr;" : "=3Dr"(fsr));
 	asm volatile ( "mov %0=3Dar.fcr;" : "=3Dr"(fcr));
+	asm volatile ( "mov %0=3Dar.fir;" : "=3Dr"(fir));
+	asm volatile ( "mov %0=3Dar.fdr;" : "=3Dr"(fdr));
=20
 	__get_user(mxcsr, (unsigned int *)&save->mxcsr);
 	/* setting bits 0..5 8..12 with cw and 39..47 from mxcsr */
@@ -355,14 +357,34 @@
=20
 	/* setting bits 0..31 with sw and tag and 32..37 from mxcsr */
 	__get_user(lo, (unsigned int *)&save->sw);
+	/* set bits 15,7 (fsw.b, fsw.es) to reflect the current error status =
*/
+	if ( !(lo & 0x7f) )
+		lo &=3D (~0x8080);
 	__get_user(hi, (unsigned int *)&save->tag);
 	num64 =3D mxcsr & 0x3f;
 	num64 =3D (num64 << 16) | (hi & 0xffff);
 	num64 =3D (num64 << 16) | (lo & 0xffff);
 	fsr =3D (fsr & (~0x3fffffffff)) | num64;
=20
+	/* setting bits 0..47 with cssel and ipoff */
+	__get_user(lo, (unsigned int *)&save->ipoff);
+	__get_user(hi, (unsigned int *)&save->cssel);
+	num64 =3D hi & 0xffff;
+	num64 =3D (num64 << 32) | lo;
+	fir =3D (fir & (~0xffffffffffff)) | num64;
+
+	/* setting bits 0..47 with datasel and dataoff */
+	__get_user(lo, (unsigned int *)&save->dataoff);
+	__get_user(hi, (unsigned int *)&save->datasel);
+	num64 =3D hi & 0xffff;
+	num64 =3D (num64 << 32) | lo;
+	fdr =3D (fdr & (~0xffffffffffff)) | num64;
+
 	asm volatile ( "mov ar.fsr=3D%0;" :: "r"(fsr));
 	asm volatile ( "mov ar.fcr=3D%0;" :: "r"(fcr));
+	asm volatile ( "mov ar.fir=3D%0;" :: "r"(fir));
+	asm volatile ( "mov ar.fdr=3D%0;" :: "r"(fdr));
+
 	/*=20
 	 * restore f8, f9 onto pt_regs
 	 * restore f10..f15 onto live registers



------_=_NextPart_001_01C295B6.A5315CC6
Content-Type: application/octet-stream;
	name="fpe3.patch"
Content-Transfer-Encoding: base64
Content-Description: fpe3.patch
Content-Disposition: attachment;
	filename="fpe3.patch"

LS0tIGFyY2gvaWE2NC9pYTMyL2lhMzJfc2lnbmFsLmMub3JnMQlGcmkgTm92IDE1IDEzOjI1OjA5
IDIwMDIKKysrIGFyY2gvaWE2NC9pYTMyL2lhMzJfc2lnbmFsLmMJTW9uIE5vdiAyNSAxMTozNTow
NiAyMDAyCkBAIC0xNjUsMTAgKzE2NSwxMCBAQAogICogICAgc3cgICAgICAgICBhci5mc3IoMDox
NSkKICAqICAgIHRhZyAgICAgICAgYXIuZnNyKDE2OjMxKSAgICAgICAgICAgICAgIHdpdGggb2Rk
IG51bWJlcmVkIGJpdHMgbm90IHVzZWQKICAqICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgIChyZWFkIHJldHVybnMgMCwgd3JpdGVzIGlnbm9yZWQpCi0gKiAgICBpcG9m
ZiAgICAgIGFyLmZpcigwOjMxKSAgIFJPCi0gKiAgICBjc3NlbCAgICAgIGFyLmZpcigzMjo0Nykg
IFJPCi0gKiAgICBkYXRhb2ZmICAgIGFyLmZkcigwOjMxKSAgIFJPCi0gKiAgICBkYXRhc2VsICAg
IGFyLmZkcigzMjo0NykgIFJPCisgKiAgICBpcG9mZiAgICAgIGFyLmZpcigwOjMxKSAgICAgCisg
KiAgICBjc3NlbCAgICAgIGFyLmZpcigzMjo0NykgICAgIAorICogICAgZGF0YW9mZiAgICBhci5m
ZHIoMDozMSkgICAgICAKKyAqICAgIGRhdGFzZWwgICAgYXIuZmRyKDMyOjQ3KSAgICAgCiAgKiAg
ICAKICAqICAgIF9zdFsoMCtUT1MpJThdICAgZjgKICAqICAgIF9zdFsoMStUT1MpJThdICAgZjkg
ICAgICAgICAgICAgICAgICAgIChmOCwgZjkgZnJvbSBwdHJlZ3MpCkBAIC0zMjgsNyArMzI4LDcg
QEAKIAl1bnNpZ25lZCBsb25nIG51bTY0LCBteGNzcjsKIAlzdHJ1Y3QgX2ZwcmVnX2lhMzIgKmZw
cmVncDsKIAljaGFyIGJ1ZlszMl07Ci0JdW5zaWduZWQgbG9uZyBmc3IsIGZjcjsKKwl1bnNpZ25l
ZCBsb25nIGZzciwgZmNyLCBmaXIsIGZkcjsKIAlpbnQgZnBfdG9zLCBmcjhfc3RfbWFwOwogCiAJ
aWYgKCFhY2Nlc3Nfb2soVkVSSUZZX1JFQUQsIHNhdmUsIHNpemVvZigqc2F2ZSkpKQpAQCAtMzQ1
LDYgKzM0NSw4IEBACiAJICovCiAJYXNtIHZvbGF0aWxlICggIm1vdiAlMD1hci5mc3I7IiA6ICI9
ciIoZnNyKSk7CiAJYXNtIHZvbGF0aWxlICggIm1vdiAlMD1hci5mY3I7IiA6ICI9ciIoZmNyKSk7
CisJYXNtIHZvbGF0aWxlICggIm1vdiAlMD1hci5maXI7IiA6ICI9ciIoZmlyKSk7CisJYXNtIHZv
bGF0aWxlICggIm1vdiAlMD1hci5mZHI7IiA6ICI9ciIoZmRyKSk7CiAKIAlfX2dldF91c2VyKG14
Y3NyLCAodW5zaWduZWQgaW50ICopJnNhdmUtPm14Y3NyKTsKIAkvKiBzZXR0aW5nIGJpdHMgMC4u
NSA4Li4xMiB3aXRoIGN3IGFuZCAzOS4uNDcgZnJvbSBteGNzciAqLwpAQCAtMzU1LDE0ICszNTcs
MzQgQEAKIAogCS8qIHNldHRpbmcgYml0cyAwLi4zMSB3aXRoIHN3IGFuZCB0YWcgYW5kIDMyLi4z
NyBmcm9tIG14Y3NyICovCiAJX19nZXRfdXNlcihsbywgKHVuc2lnbmVkIGludCAqKSZzYXZlLT5z
dyk7CisJLyogc2V0IGJpdHMgMTUsNyAoZnN3LmIsIGZzdy5lcykgdG8gcmVmbGVjdCB0aGUgY3Vy
cmVudCBlcnJvciBzdGF0dXMgKi8KKwlpZiAoICEobG8gJiAweDdmKSApCisJCWxvICY9ICh+MHg4
MDgwKTsKIAlfX2dldF91c2VyKGhpLCAodW5zaWduZWQgaW50ICopJnNhdmUtPnRhZyk7CiAJbnVt
NjQgPSBteGNzciAmIDB4M2Y7CiAJbnVtNjQgPSAobnVtNjQgPDwgMTYpIHwgKGhpICYgMHhmZmZm
KTsKIAludW02NCA9IChudW02NCA8PCAxNikgfCAobG8gJiAweGZmZmYpOwogCWZzciA9IChmc3Ig
JiAofjB4M2ZmZmZmZmZmZikpIHwgbnVtNjQ7CiAKKwkvKiBzZXR0aW5nIGJpdHMgMC4uNDcgd2l0
aCBjc3NlbCBhbmQgaXBvZmYgKi8KKwlfX2dldF91c2VyKGxvLCAodW5zaWduZWQgaW50ICopJnNh
dmUtPmlwb2ZmKTsKKwlfX2dldF91c2VyKGhpLCAodW5zaWduZWQgaW50ICopJnNhdmUtPmNzc2Vs
KTsKKwludW02NCA9IGhpICYgMHhmZmZmOworCW51bTY0ID0gKG51bTY0IDw8IDMyKSB8IGxvOwor
CWZpciA9IChmaXIgJiAofjB4ZmZmZmZmZmZmZmZmKSkgfCBudW02NDsKKworCS8qIHNldHRpbmcg
Yml0cyAwLi40NyB3aXRoIGRhdGFzZWwgYW5kIGRhdGFvZmYgKi8KKwlfX2dldF91c2VyKGxvLCAo
dW5zaWduZWQgaW50ICopJnNhdmUtPmRhdGFvZmYpOworCV9fZ2V0X3VzZXIoaGksICh1bnNpZ25l
ZCBpbnQgKikmc2F2ZS0+ZGF0YXNlbCk7CisJbnVtNjQgPSBoaSAmIDB4ZmZmZjsKKwludW02NCA9
IChudW02NCA8PCAzMikgfCBsbzsKKwlmZHIgPSAoZmRyICYgKH4weGZmZmZmZmZmZmZmZikpIHwg
bnVtNjQ7CisKIAlhc20gdm9sYXRpbGUgKCAibW92IGFyLmZzcj0lMDsiIDo6ICJyIihmc3IpKTsK
IAlhc20gdm9sYXRpbGUgKCAibW92IGFyLmZjcj0lMDsiIDo6ICJyIihmY3IpKTsKKwlhc20gdm9s
YXRpbGUgKCAibW92IGFyLmZpcj0lMDsiIDo6ICJyIihmaXIpKTsKKwlhc20gdm9sYXRpbGUgKCAi
bW92IGFyLmZkcj0lMDsiIDo6ICJyIihmZHIpKTsKKwogCS8qIAogCSAqIHJlc3RvcmUgZjgsIGY5
IG9udG8gcHRfcmVncwogCSAqIHJlc3RvcmUgZjEwLi5mMTUgb250byBsaXZlIHJlZ2lzdGVycwo=

------_=_NextPart_001_01C295B6.A5315CC6--

