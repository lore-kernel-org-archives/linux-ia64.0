From: "Siddha, Suresh B" <suresh.b.siddha@intel.com>
Date: Sat, 18 Jan 2003 01:15:39 +0000
Subject: [Linux-ia64] [Patch] Fix in printk.c
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C2BE8F.1CB891E4"
Message-Id: <marc-linux-ia64-105590709805719@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C2BE8F.1CB891E4
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

c99 specifies

<snip>
       [#7] If, within a  translation  unit,  the  same  identifier
       appears   with  both  internal  and  external  linkage,  the
       behavior is undefined.
</snip>

"early_printk" has this type of behaviour in printk.c. Attached/appended =
patch removes the dependency on the behaviour of the compiler.

thanks,
suresh

diff -Nru linux-2.5.52/kernel/printk.c~ linux-2.5.52/kernel/printk.c
--- linux-2.5.52/kernel/printk.c~	Fri Jan 17 14:53:30 2003
+++ linux-2.5.52/kernel/printk.c	Fri Jan 17 14:53:37 2003
@@ -329,7 +329,7 @@
 	}
 #ifdef CONFIG_IA64_EARLY_PRINTK
 	if (!console_drivers) {
-		static void early_printk (const char *str, size_t len);
+		void early_printk (const char *str, size_t len);
 		early_printk(&LOG_BUF(start), end - start);
 	}
 #endif


------_=_NextPart_001_01C2BE8F.1CB891E4
Content-Type: application/octet-stream;
	name="printk.c.diff"
Content-Transfer-Encoding: base64
Content-Description: printk.c.diff
Content-Disposition: attachment;
	filename="printk.c.diff"

ZGlmZiAtTnJ1IGxpbnV4LTIuNS41Mi9rZXJuZWwvcHJpbnRrLmN+IGxpbnV4LTIuNS41Mi9rZXJu
ZWwvcHJpbnRrLmMNCi0tLSBsaW51eC0yLjUuNTIva2VybmVsL3ByaW50ay5jfglGcmkgSmFuIDE3
IDE0OjUzOjMwIDIwMDMNCisrKyBsaW51eC0yLjUuNTIva2VybmVsL3ByaW50ay5jCUZyaSBKYW4g
MTcgMTQ6NTM6MzcgMjAwMw0KQEAgLTMyOSw3ICszMjksNyBAQA0KIAl9DQogI2lmZGVmIENPTkZJ
R19JQTY0X0VBUkxZX1BSSU5USw0KIAlpZiAoIWNvbnNvbGVfZHJpdmVycykgew0KLQkJc3RhdGlj
IHZvaWQgZWFybHlfcHJpbnRrIChjb25zdCBjaGFyICpzdHIsIHNpemVfdCBsZW4pOw0KKwkJdm9p
ZCBlYXJseV9wcmludGsgKGNvbnN0IGNoYXIgKnN0ciwgc2l6ZV90IGxlbik7DQogCQllYXJseV9w
cmludGsoJkxPR19CVUYoc3RhcnQpLCBlbmQgLSBzdGFydCk7DQogCX0NCiAjZW5kaWYNCg==

------_=_NextPart_001_01C2BE8F.1CB891E4--

