From: "Pallipadi, Venkatesh" <venkatesh.pallipadi@intel.com>
Date: Sat, 31 May 2003 01:19:02 +0000
Subject: [Linux-ia64] [PATCH] IA-32 emulation patch: ptrace get_FPREGS bug fix
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C32712.9F08C6D2"
Message-Id: <marc-linux-ia64-105590723706099@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C32712.9F08C6D2
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable



A bug-fix in IA-32 emulation ptrace code. The bug originally got
introduced with the addition of FPXREGS support in ptrace.

The bug is in ptrace get/set FPREGS routine. gdb by default will not use
FPREGS routines when FPXREGS routines are supported.  So we may not see
this bug during normal gdb operations. But, if gdb (or any other app)
directly tries to get/set FPREGS (probably an old version of gdb), it
will end with an segmentation fault due to this bug.

Attached patch fixes the issue. The patch is taken against 2.5.69. But
it applies to 2.4 tree as well.=20

Please let me know, if you need any more information on this.

Thanks,
-Venkatesh

------_=_NextPart_001_01C32712.9F08C6D2
Content-Type: application/octet-stream;
	name="ptrace_2569.patch"
Content-Transfer-Encoding: base64
Content-Description: ptrace_2569.patch
Content-Disposition: attachment;
	filename="ptrace_2569.patch"

ZGlmZiAtdXJOIGxpbnV4LTIuNS42OS9hcmNoL2lhNjQvaWEzMi9zeXNfaWEzMi5jIGxpbnV4LTIu
NS42OS1maXgvYXJjaC9pYTY0L2lhMzIvc3lzX2lhMzIuYwotLS0gbGludXgtMi41LjY5L2FyY2gv
aWE2NC9pYTMyL3N5c19pYTMyLmMJTW9uIE1heSAxMiAxNDoyMDoyMyAyMDAzCisrKyBsaW51eC0y
LjUuNjktZml4L2FyY2gvaWE2NC9pYTMyL3N5c19pYTMyLmMJRnJpIE1heSAzMCAxMToyNjoyNSAy
MDAzCkBAIC0xODYwLDcgKzE4NjAsNyBAQAogCXB0cCA9IGlhNjRfdGFza19yZWdzKHRzayk7CiAJ
dG9zID0gKHRzay0+dGhyZWFkLmZzciA+PiAxMSkgJiA3OwogCWZvciAoaSA9IDA7IGkgPCA4OyBp
KyspCi0JCXB1dF9mcHJlZyhpLCAoc3RydWN0IF9mcHJlZ19pYTMyICopJnNhdmUtPnN0X3NwYWNl
WzQqaV0sIHB0cCwgc3dwLCB0b3MpOworCQlwdXRfZnByZWcoaSwgJnNhdmUtPnN0X3NwYWNlW2ld
LCBwdHAsIHN3cCwgdG9zKTsKIAlyZXR1cm4gMDsKIH0KIApAQCAtMTg5Myw3ICsxODkzLDcgQEAK
IAlwdHAgPSBpYTY0X3Rhc2tfcmVncyh0c2spOwogCXRvcyA9ICh0c2stPnRocmVhZC5mc3IgPj4g
MTEpICYgNzsKIAlmb3IgKGkgPSAwOyBpIDwgODsgaSsrKQotCQlnZXRfZnByZWcoaSwgKHN0cnVj
dCBfZnByZWdfaWEzMiAqKSZzYXZlLT5zdF9zcGFjZVs0KmldLCBwdHAsIHN3cCwgdG9zKTsKKwkJ
Z2V0X2ZwcmVnKGksICZzYXZlLT5zdF9zcGFjZVtpXSwgcHRwLCBzd3AsIHRvcyk7CiAJcmV0dXJu
IDA7CiB9CiAKZGlmZiAtdXJOIGxpbnV4LTIuNS42OS9pbmNsdWRlL2FzbS1pYTY0L2lhMzIuaCBs
aW51eC0yLjUuNjktZml4L2luY2x1ZGUvYXNtLWlhNjQvaWEzMi5oCi0tLSBsaW51eC0yLjUuNjkv
aW5jbHVkZS9hc20taWE2NC9pYTMyLmgJTW9uIE1heSAxMiAxNDoyMDozMiAyMDAzCisrKyBsaW51
eC0yLjUuNjktZml4L2luY2x1ZGUvYXNtLWlhNjQvaWEzMi5oCUZyaSBNYXkgMzAgMTE6MjY6MjUg
MjAwMwpAQCAtMTA4LDcgKzEwOCw4IEBACiAJaW50CWZjczsKIAlpbnQJZm9vOwogCWludAlmb3M7
Ci0JaW50CXN0X3NwYWNlWzIwXTsJLyogOCoxMCBieXRlcyBmb3IgZWFjaCBGUC1yZWcgPSA4MCBi
eXRlcyAqLworCS8qIDgqMTAgYnl0ZXMgZm9yIGVhY2ggRlAtcmVnID0gODAgYnl0ZXMgKi8KKwlz
dHJ1Y3QgX2ZwcmVnX2lhMzIgCXN0X3NwYWNlWzhdOwogfTsKIAogc3RydWN0IGlhMzJfdXNlcl9m
eHNyX3N0cnVjdCB7Cg==

------_=_NextPart_001_01C32712.9F08C6D2--

