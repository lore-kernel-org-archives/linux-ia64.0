From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 19 Jun 2003 20:34:55 +0000
Subject: local symbols in discarded section
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C336A2.3E0F342A"
Message-Id: <marc-linux-ia64-105605499315077@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C336A2.3E0F342A
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable


>   Tony> undefined reference to `local symbols in discarded=20
> section .exit.text'
>=20
>   Tony> message.  Is this related to the warning about using=20
> an old linker?
>=20
> Not likely.  It sounds like a driver is failing to use __exit_p() (see
> linux/init.h).

The offending driver is i460-agp.c.  Patch attached.

-Tony

------_=_NextPart_001_01C336A2.3E0F342A
Content-Type: application/octet-stream;
	name="i460-agp.patch"
Content-Transfer-Encoding: base64
Content-Description: i460-agp.patch
Content-Disposition: attachment;
	filename="i460-agp.patch"

PT09PT0gZHJpdmVycy9jaGFyL2FncC9pNDYwLWFncC5jIDEuMjYgdnMgZWRpdGVkID09PT09Ci0t
LSAxLjI2L2RyaXZlcnMvY2hhci9hZ3AvaTQ2MC1hZ3AuYwlNb24gSnVuIDE2IDE4OjU1OjM0IDIw
MDMKKysrIGVkaXRlZC9kcml2ZXJzL2NoYXIvYWdwL2k0NjAtYWdwLmMJVGh1IEp1biAxOSAxMzoy
ODoyOCAyMDAzCkBAIC02MDgsNyArNjA4LDcgQEAKIAkubmFtZQkJPSAiYWdwZ2FydC1pbnRlbC1p
NDYwIiwKIAkuaWRfdGFibGUJPSBhZ3BfaW50ZWxfaTQ2MF9wY2lfdGFibGUsCiAJLnByb2JlCQk9
IGFncF9pbnRlbF9pNDYwX3Byb2JlLAotCS5yZW1vdmUJCT0gYWdwX2ludGVsX2k0NjBfcmVtb3Zl
LAorCS5yZW1vdmUJCT0gX19leGl0X3AoYWdwX2ludGVsX2k0NjBfcmVtb3ZlKSwKIH07CiAKIHN0
YXRpYyBpbnQgX19pbml0IGFncF9pbnRlbF9pNDYwX2luaXQodm9pZCkK

------_=_NextPart_001_01C336A2.3E0F342A--
