From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 07 Jan 2005 18:56:00 +0000
Subject: RE: [patch] per cpu MCA/INIT fixes.
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F02AA19EE@scsmsx401.amr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C4F4EA.88A0ABA9"
List-Id: <linux-ia64.vger.kernel.org>
References: <200501060308.j0638M7s194286@ben.americas.sgi.com>
In-Reply-To: <200501060308.j0638M7s194286@ben.americas.sgi.com>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C4F4EA.88A0ABA9
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

>+               mca_data =3D __alloc_bootmem(PERCPU_MCA_SIZE * NR_CPUS,
>+                                          PERCPU_MCA_SIZE, =
__pa(MAX_DMA_ADDRESS));
>
>PERCPU_MCA_SIZE doesn't look likely to be a power of two, so using it
>as the 'align' argument to __alloc_bootmem trips the BUG at =
mm/bootmem.c:158

I just switched the allocation to use alloc_bootmem() which uses the =
default
cache line alignment, which appears to be plenty here.

-Tony

------_=_NextPart_001_01C4F4EA.88A0ABA9
Content-Type: application/octet-stream;
	name="contig.patch"
Content-Transfer-Encoding: base64
Content-Description: contig.patch
Content-Disposition: attachment;
	filename="contig.patch"

PT09PT0gYXJjaC9pYTY0L21tL2NvbnRpZy5jIDEuMTAgdnMgZWRpdGVkID09PT09Ci0tLSAxLjEw
L2FyY2gvaWE2NC9tbS9jb250aWcuYwkyMDA1LTAxLTA2IDE2OjIxOjIyIC0wODowMAorKysgZWRp
dGVkL2FyY2gvaWE2NC9tbS9jb250aWcuYwkyMDA1LTAxLTA3IDEwOjM5OjM4IC0wODowMApAQCAt
MTg5LDggKzE4OSw3IEBACiAJaWYgKHNtcF9wcm9jZXNzb3JfaWQoKSA9PSAwKSB7CiAJCWNwdV9k
YXRhID0gX19hbGxvY19ib290bWVtKFBFUkNQVV9QQUdFX1NJWkUgKiBOUl9DUFVTLAogCQkJCQkg
ICBQRVJDUFVfUEFHRV9TSVpFLCBfX3BhKE1BWF9ETUFfQUREUkVTUykpOwotCQltY2FfZGF0YSA9
IF9fYWxsb2NfYm9vdG1lbShQRVJDUFVfTUNBX1NJWkUgKiBOUl9DUFVTLAotCQkJCQkgICBQRVJD
UFVfTUNBX1NJWkUsIF9fcGEoTUFYX0RNQV9BRERSRVNTKSk7CisJCW1jYV9kYXRhID0gYWxsb2Nf
Ym9vdG1lbShQRVJDUFVfTUNBX1NJWkUgKiBOUl9DUFVTKTsKIAkJZm9yIChjcHUgPSAwOyBjcHUg
PCBOUl9DUFVTOyBjcHUrKykgewogCQkJbWVtY3B5KGNwdV9kYXRhLCBfX3BoeXNfcGVyX2NwdV9z
dGFydCwgX19wZXJfY3B1X2VuZCAtIF9fcGVyX2NwdV9zdGFydCk7CiAJCQlfX3Blcl9jcHVfb2Zm
c2V0W2NwdV0gPSAoY2hhciAqKSBjcHVfZGF0YSAtIF9fcGVyX2NwdV9zdGFydDsK

------_=_NextPart_001_01C4F4EA.88A0ABA9--
