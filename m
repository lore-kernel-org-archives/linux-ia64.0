From: "Siddha, Suresh B" <suresh.b.siddha@intel.com>
Date: Tue, 21 Jan 2003 03:16:09 +0000
Subject: [Linux-ia64] [Patch] trivial fix in linker script
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C2C0FB.7190411E"
Message-Id: <marc-linux-ia64-105590709805734@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C2C0FB.7190411E
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

There is a chance that __start___ksymtab may not point at the  beginning =
of section __ksymtab. Appended/attached one line patch fixes this =
problem.

thanks,
suresh

diff -Nru linux-2.5.52/arch/ia64/vmlinux.lds.S~ =
linux-2.5.52/arch/ia64/vmlinux.lds.S
--- linux-2.5.52/arch/ia64/vmlinux.lds.S~       Mon Jan 20 18:42:47 2003
+++ linux-2.5.52/arch/ia64/vmlinux.lds.S        Mon Jan 20 18:43:42 2003
@@ -60,6 +60,7 @@
   machvec_end =3D .;
 #endif
=20
+  . =3D ALIGN(16);
   __start___ksymtab =3D .;       /* Kernel symbol table */
   __ksymtab : AT(ADDR(__ksymtab) - PAGE_OFFSET)
        { *(__ksymtab) }


------_=_NextPart_001_01C2C0FB.7190411E
Content-Type: application/octet-stream;
	name="vmlinux.lds.S.diff"
Content-Transfer-Encoding: base64
Content-Description: vmlinux.lds.S.diff
Content-Disposition: attachment;
	filename="vmlinux.lds.S.diff"

LS0tIGxpbnV4LTIuNS41Mi9hcmNoL2lhNjQvdm1saW51eC5sZHMuU34JTW9uIEphbiAyMCAxODo0
Mjo0NyAyMDAzDQorKysgbGludXgtMi41LjUyL2FyY2gvaWE2NC92bWxpbnV4Lmxkcy5TCU1vbiBK
YW4gMjAgMTg6NDM6NDIgMjAwMw0KQEAgLTYwLDYgKzYwLDcgQEANCiAgIG1hY2h2ZWNfZW5kID0g
LjsNCiAjZW5kaWYNCiANCisgIC4gPSBBTElHTigxNik7DQogICBfX3N0YXJ0X19fa3N5bXRhYiA9
IC47CS8qIEtlcm5lbCBzeW1ib2wgdGFibGUgKi8NCiAgIF9fa3N5bXRhYiA6IEFUKEFERFIoX19r
c3ltdGFiKSAtIFBBR0VfT0ZGU0VUKQ0KIAl7ICooX19rc3ltdGFiKSB9DQo=

------_=_NextPart_001_01C2C0FB.7190411E--

