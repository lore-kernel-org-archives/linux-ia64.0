From: Francis Galiegue <fg@mandrakesoft.com>
Date: Thu, 01 Mar 2001 18:17:18 +0000
Subject: [Linux-ia64] [PATCH] over 2.4.2 + 010228: also define IA64_L1_CACHE_SHIFT if you
MIME-Version: 1
Content-Type: multipart/mixed; boundary="-1463800575-153962590-983455123=:922"
Message-Id: <marc-linux-ia64-105590693005233@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.
  Send mail to mime@docserver.cac.washington.edu for more info.

---1463800575-153962590-983455123=:922
Content-Type: TEXT/PLAIN; CHARSET=iso-8859-1
Content-ID: <Pine.LNX.4.21.0103011916132.922@toy.mandrakesoft.com>
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by mandrakesoft.mandrakesoft.com id MAA09482


Patch attached. I sent the same mail some 6 hours ago but it didn't arriv=
e.

--=20
Francis Galiegue, fg@mandrakesoft.com - Normand et fier de l'=EAtre
"Programming is a race between programmers, who try and make more and mor=
e
idiot-proof software, and universe, which produces more and more remarkab=
le
idiots. Until now, universe leads the race"  -- R. Cook

---1463800575-153962590-983455123=:922
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII; NAME="ia64-cache-shift-define-outside-ACPI.patch"
Content-ID: <Pine.LNX.4.21.0103011458430.922@toy.mandrakesoft.com>
Content-Description: 
Content-Disposition: ATTACHMENT; FILENAME="ia64-cache-shift-define-outside-ACPI.patch"
Content-Transfer-Encoding: BASE64

LS0tIGxpbnV4L2FyY2gvaWE2NC9jb25maWcuaW4JV2VkIEZlYiAyOCAxNDoz
MjoyMSAyMDAxDQorKysgbGludXgtb2xkL2FyY2gvaWE2NC9jb25maWcuaW4J
VGh1IE1hciAgMSAwNjo1NDoxNiAyMDAxDQpAQCAtNzQsOCArNzQsOCBAQA0K
IAkgIGRlZmluZV9ib29sIENPTkZJR19QTSB5DQogCSAgZGVmaW5lX2Jvb2wg
Q09ORklHX0FDUEkgeQ0KIAkgIGRlZmluZV9ib29sIENPTkZJR19BQ1BJX0lO
VEVSUFJFVEVSIHkNCi0JZmkNCiAJZGVmaW5lX2ludCAgQ09ORklHX0lBNjRf
TDFfQ0FDSEVfU0hJRlQJNgkjIGFsaWduIGNhY2hlLXNlbnNpdGl2ZSBkYXRh
IHN0cnVjdHVyZSB0byA2NCBieXRlcw0KKwlmaQ0KIGZpDQogDQogaWYgWyAi
JENPTkZJR19JQTY0X1NHSV9TTjEiID0gInkiIF07IHRoZW4NCg==
---1463800575-153962590-983455123=:922--

