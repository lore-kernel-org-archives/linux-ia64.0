From: "Siddha, Suresh B" <suresh.b.siddha@intel.com>
Date: Mon, 24 Feb 2003 18:21:14 +0000
Subject: [Linux-ia64] [Patch] 2/2 fix in machvec.h
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C2DC31.83D2D128"
Message-Id: <marc-linux-ia64-105590709805918@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C2DC31.83D2D128
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

IA64 ABI specifies that globals > 8 bytes need to be aligned to 16 =
bytes. gcc doesn't follow this convention. Current kernel code will fail =
to work with a compiler which follows the ABI.

size of structure ia64_machine_vector is > 8 bytes and not multiple of =
16 bytes. When we have CONFIG_IA64_GENERIC, each machine specific vector =
from different object files gets linked into a user defined =
section(forming array of structures).=20

Now with a compiler conforming to ABI, there will be holes in this array =
resulting in the code failure when it goes through this array of =
structures.

Following patch will make the size of the structure to be multiple of 16 =
bytes, making both ABI confirming/non-conforming compilers happy.

thanks,
suresh

--- linux/include/asm-ia64/machvec.h~	Thu Feb 20 13:51:48 2003
+++ linux/include/asm-ia64/machvec.h	Thu Feb 20 13:59:35 2003
@@ -113,6 +113,11 @@
 #  define platofrm_mmiob        ia64_mv.mmiob
 # endif
=20
+/* __attribute__((__aligned__(16))) is required to make size of the
+ * structure multiple of 16 bytes.
+ * This will fillup the holes created because of section 3.3.1 in=20
+ * Software Conventions guide.
+ */
 struct ia64_machine_vector {
 	const char *name;
 	ia64_mv_setup_t *setup;
@@ -145,7 +150,7 @@
 	ia64_mv_outw_t *outw;
 	ia64_mv_outl_t *outl;
 	ia64_mv_mmiob_t *mmiob;
-};
+} __attribute__((__aligned__(16)));
=20
 #define MACHVEC_INIT(name)			\
 {						\

------_=_NextPart_001_01C2DC31.83D2D128
Content-Type: application/octet-stream;
	name="machvec.diff"
Content-Transfer-Encoding: base64
Content-Description: machvec.diff
Content-Disposition: attachment;
	filename="machvec.diff"

LS0tIGxpbnV4L2luY2x1ZGUvYXNtLWlhNjQvbWFjaHZlYy5ofglUaHUgRmViIDIwIDEzOjUxOjQ4
IDIwMDMNCisrKyBsaW51eC9pbmNsdWRlL2FzbS1pYTY0L21hY2h2ZWMuaAlUaHUgRmViIDIwIDEz
OjU5OjM1IDIwMDMNCkBAIC0xMTMsNiArMTEzLDExIEBADQogIyAgZGVmaW5lIHBsYXRvZnJtX21t
aW9iICAgICAgICBpYTY0X212Lm1taW9iDQogIyBlbmRpZg0KIA0KKy8qIF9fYXR0cmlidXRlX18o
KF9fYWxpZ25lZF9fKDE2KSkpIGlzIHJlcXVpcmVkIHRvIG1ha2Ugc2l6ZSBvZiB0aGUNCisgKiBz
dHJ1Y3R1cmUgbXVsdGlwbGUgb2YgMTYgYnl0ZXMuDQorICogVGhpcyB3aWxsIGZpbGx1cCB0aGUg
aG9sZXMgY3JlYXRlZCBiZWNhdXNlIG9mIHNlY3Rpb24gMy4zLjEgaW4gDQorICogU29mdHdhcmUg
Q29udmVudGlvbnMgZ3VpZGUuDQorICovDQogc3RydWN0IGlhNjRfbWFjaGluZV92ZWN0b3Igew0K
IAljb25zdCBjaGFyICpuYW1lOw0KIAlpYTY0X212X3NldHVwX3QgKnNldHVwOw0KQEAgLTE0NSw3
ICsxNTAsNyBAQA0KIAlpYTY0X212X291dHdfdCAqb3V0dzsNCiAJaWE2NF9tdl9vdXRsX3QgKm91
dGw7DQogCWlhNjRfbXZfbW1pb2JfdCAqbW1pb2I7DQotfTsNCit9IF9fYXR0cmlidXRlX18oKF9f
YWxpZ25lZF9fKDE2KSkpOw0KIA0KICNkZWZpbmUgTUFDSFZFQ19JTklUKG5hbWUpCQkJXA0KIHsJ
CQkJCQlcDQo=

------_=_NextPart_001_01C2DC31.83D2D128--

