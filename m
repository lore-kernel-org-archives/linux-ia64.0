From: "Wang, Zhenyu Z" <zhenyu.z.wang@intel.com>
Date: Wed, 18 Aug 2004 08:23:33 +0000
Subject: [PATCH][2.4.27]max-inline-insns not exists in gcc-3.4 proposal fix
Message-Id: <9DE394C12A921946AEECE1F71944ECD52194F1@pdsmsx404>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C484FC.A74061A7"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C484FC.A74061A7
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable


As gcc-3.4 has no param of max-inline-insns any more, build will fail
without Makefile fix.
I prefer the proposal fix below, but not sure about the num for tune.

Thanks,
-zhen

--- acpi-2.4-0817/arch/ia64/Makefile.orig	2004-08-18
16:07:09.809989639 -0400
+++ acpi-2.4-0817/arch/ia64/Makefile	2004-08-18 16:05:46.499443784
-0400
@@ -43,7 +43,7 @@ $(warning Warning: Please use binutil ve
 endif
=20
 ifneq ($(GCC_VERSION),2)
-	CFLAGS +=3D -frename-registers --param max-inline-insns=3D5000
+	CFLAGS +=3D -frename-registers -finline-limit=3D5000
 endif
=20
 ifeq ($(CONFIG_ITANIUM_BSTEP_SPECIFIC),y)

------_=_NextPart_001_01C484FC.A74061A7
Content-Type: application/octet-stream;
	name="gcc-3.4-ia64-Makefile-proposal-fix.patch"
Content-Transfer-Encoding: base64
Content-Description: gcc-3.4-ia64-Makefile-proposal-fix.patch
Content-Disposition: attachment;
	filename="gcc-3.4-ia64-Makefile-proposal-fix.patch"

LS0tIGFjcGktMi40LTA4MTcvYXJjaC9pYTY0L01ha2VmaWxlLm9yaWcJMjAwNC0wOC0xOCAxNjow
NzowOS44MDk5ODk2MzkgLTA0MDAKKysrIGFjcGktMi40LTA4MTcvYXJjaC9pYTY0L01ha2VmaWxl
CTIwMDQtMDgtMTggMTY6MDU6NDYuNDk5NDQzNzg0IC0wNDAwCkBAIC00Myw3ICs0Myw3IEBAICQo
d2FybmluZyBXYXJuaW5nOiBQbGVhc2UgdXNlIGJpbnV0aWwgdmUKIGVuZGlmCiAKIGlmbmVxICgk
KEdDQ19WRVJTSU9OKSwyKQotCUNGTEFHUyArPSAtZnJlbmFtZS1yZWdpc3RlcnMgLS1wYXJhbSBt
YXgtaW5saW5lLWluc25zPTUwMDAKKwlDRkxBR1MgKz0gLWZyZW5hbWUtcmVnaXN0ZXJzIC1maW5s
aW5lLWxpbWl0PTUwMDAKIGVuZGlmCiAKIGlmZXEgKCQoQ09ORklHX0lUQU5JVU1fQlNURVBfU1BF
Q0lGSUMpLHkpCg==

------_=_NextPart_001_01C484FC.A74061A7--
