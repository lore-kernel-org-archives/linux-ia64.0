From: "Siddha, Suresh B" <suresh.b.siddha@intel.com>
Date: Tue, 21 Jan 2003 02:41:56 +0000
Subject: RE: [Linux-ia64] [Patch] Fix in process.c
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C2C0F6.A9A3537A"
Message-Id: <marc-linux-ia64-105590709805733@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805720@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805720@msgid-missing>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C2C0F6.A9A3537A
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

> >=20
> > I understand that.  What I'm saying is that GCC does the sane thing.
> > There's got to be a way to get the address of a label without having
> > to materialize a function pointer.
> >=20
> > 	--david
> >=20
>=20
> We can do that through the linker script vmlinux.lds.S.
>=20

hi David,

Here is the patch which does this. Please apply.

thanks,
suresh

diff -Nru linux-2.5.52/arch/ia64/kernel/process.c =
linux/arch/ia64/kernel/process.c
--- linux-2.5.52/arch/ia64/kernel/process.c	Mon Jan 20 13:12:08 2003
+++ linux/arch/ia64/kernel/process.c	Mon Jan 20 09:45:21 2003
@@ -281,7 +281,10 @@
 {
 	unsigned long rbs, child_rbs, rbs_size, stack_offset, stack_top, =
stack_used;
 	struct switch_stack *child_stack, *stack;
-	extern char ia64_ret_from_clone, ia32_ret_from_clone;
+	extern int  __ia64_ret_from_clone;
+#ifdef CONFIG_IA32_SUPPORT
+	extern int __ia32_ret_from_clone;
+#endif
 	struct pt_regs *child_ptregs;
 	int retval =3D 0;
=20
@@ -332,10 +335,12 @@
 		child_ptregs->r12 =3D (unsigned long) (child_ptregs + 1); /* kernel =
sp */
 		child_ptregs->r13 =3D (unsigned long) p;		/* set `current' pointer */
 	}
+#ifdef CONFIG_IA32_SUPPORT
 	if (IS_IA32_PROCESS(regs))
-		child_stack->b0 =3D (unsigned long) &ia32_ret_from_clone;
+		child_stack->b0 =3D (unsigned long) &__ia32_ret_from_clone;
 	else
-		child_stack->b0 =3D (unsigned long) &ia64_ret_from_clone;
+#endif
+		child_stack->b0 =3D (unsigned long) &__ia64_ret_from_clone;
 	child_stack->ar_bspstore =3D child_rbs + rbs_size;
=20
 	/* copy parts of thread_struct: */
diff -Nru linux-2.5.52/arch/ia64/vmlinux.lds.S =
linux/arch/ia64/vmlinux.lds.S
--- linux-2.5.52/arch/ia64/vmlinux.lds.S	Mon Jan 20 13:12:09 2003
+++ linux/arch/ia64/vmlinux.lds.S	Mon Jan 20 18:31:14 2003
@@ -39,6 +39,14 @@
 #endif
   _etext =3D .;
=20
+   /* We want to get the address of a label without having
+      to materialize a function pointer. "+0" is for changing
+      the symbol type */
+   __ia64_ret_from_clone =3D ia64_ret_from_clone + 0;
+#ifdef CONFIG_IA32_SUPPORT
+   __ia32_ret_from_clone =3D ia32_ret_from_clone + 0;
+#endif
+
   /* Read-only data */
=20
   /* Global data */


------_=_NextPart_001_01C2C0F6.A9A3537A
Content-Type: application/octet-stream;
	name="process.diff"
Content-Transfer-Encoding: base64
Content-Description: process.diff
Content-Disposition: attachment;
	filename="process.diff"

ZGlmZiAtTnJ1IGxpbnV4LTIuNS41Mi9hcmNoL2lhNjQva2VybmVsL3Byb2Nlc3MuYyBsaW51eC9h
cmNoL2lhNjQva2VybmVsL3Byb2Nlc3MuYw0KLS0tIGxpbnV4LTIuNS41Mi9hcmNoL2lhNjQva2Vy
bmVsL3Byb2Nlc3MuYwlNb24gSmFuIDIwIDEzOjEyOjA4IDIwMDMNCisrKyBsaW51eC9hcmNoL2lh
NjQva2VybmVsL3Byb2Nlc3MuYwlNb24gSmFuIDIwIDA5OjQ1OjIxIDIwMDMNCkBAIC0yODEsNyAr
MjgxLDEwIEBADQogew0KIAl1bnNpZ25lZCBsb25nIHJicywgY2hpbGRfcmJzLCByYnNfc2l6ZSwg
c3RhY2tfb2Zmc2V0LCBzdGFja190b3AsIHN0YWNrX3VzZWQ7DQogCXN0cnVjdCBzd2l0Y2hfc3Rh
Y2sgKmNoaWxkX3N0YWNrLCAqc3RhY2s7DQotCWV4dGVybiBjaGFyIGlhNjRfcmV0X2Zyb21fY2xv
bmUsIGlhMzJfcmV0X2Zyb21fY2xvbmU7DQorCWV4dGVybiBpbnQgIF9faWE2NF9yZXRfZnJvbV9j
bG9uZTsNCisjaWZkZWYgQ09ORklHX0lBMzJfU1VQUE9SVA0KKwlleHRlcm4gaW50IF9faWEzMl9y
ZXRfZnJvbV9jbG9uZTsNCisjZW5kaWYNCiAJc3RydWN0IHB0X3JlZ3MgKmNoaWxkX3B0cmVnczsN
CiAJaW50IHJldHZhbCA9IDA7DQogDQpAQCAtMzMyLDEwICszMzUsMTIgQEANCiAJCWNoaWxkX3B0
cmVncy0+cjEyID0gKHVuc2lnbmVkIGxvbmcpIChjaGlsZF9wdHJlZ3MgKyAxKTsgLyoga2VybmVs
IHNwICovDQogCQljaGlsZF9wdHJlZ3MtPnIxMyA9ICh1bnNpZ25lZCBsb25nKSBwOwkJLyogc2V0
IGBjdXJyZW50JyBwb2ludGVyICovDQogCX0NCisjaWZkZWYgQ09ORklHX0lBMzJfU1VQUE9SVA0K
IAlpZiAoSVNfSUEzMl9QUk9DRVNTKHJlZ3MpKQ0KLQkJY2hpbGRfc3RhY2stPmIwID0gKHVuc2ln
bmVkIGxvbmcpICZpYTMyX3JldF9mcm9tX2Nsb25lOw0KKwkJY2hpbGRfc3RhY2stPmIwID0gKHVu
c2lnbmVkIGxvbmcpICZfX2lhMzJfcmV0X2Zyb21fY2xvbmU7DQogCWVsc2UNCi0JCWNoaWxkX3N0
YWNrLT5iMCA9ICh1bnNpZ25lZCBsb25nKSAmaWE2NF9yZXRfZnJvbV9jbG9uZTsNCisjZW5kaWYN
CisJCWNoaWxkX3N0YWNrLT5iMCA9ICh1bnNpZ25lZCBsb25nKSAmX19pYTY0X3JldF9mcm9tX2Ns
b25lOw0KIAljaGlsZF9zdGFjay0+YXJfYnNwc3RvcmUgPSBjaGlsZF9yYnMgKyByYnNfc2l6ZTsN
CiANCiAJLyogY29weSBwYXJ0cyBvZiB0aHJlYWRfc3RydWN0OiAqLw0KZGlmZiAtTnJ1IGxpbnV4
LTIuNS41Mi9hcmNoL2lhNjQvdm1saW51eC5sZHMuUyBsaW51eC9hcmNoL2lhNjQvdm1saW51eC5s
ZHMuUw0KLS0tIGxpbnV4LTIuNS41Mi9hcmNoL2lhNjQvdm1saW51eC5sZHMuUwlNb24gSmFuIDIw
IDEzOjEyOjA5IDIwMDMNCisrKyBsaW51eC9hcmNoL2lhNjQvdm1saW51eC5sZHMuUwlNb24gSmFu
IDIwIDE4OjMxOjE0IDIwMDMNCkBAIC0zOSw2ICszOSwxNCBAQA0KICNlbmRpZg0KICAgX2V0ZXh0
ID0gLjsNCiANCisgICAvKiBXZSB3YW50IHRvIGdldCB0aGUgYWRkcmVzcyBvZiBhIGxhYmVsIHdp
dGhvdXQgaGF2aW5nDQorICAgICAgdG8gbWF0ZXJpYWxpemUgYSBmdW5jdGlvbiBwb2ludGVyLiAi
KzAiIGlzIGZvciBjaGFuZ2luZw0KKyAgICAgIHRoZSBzeW1ib2wgdHlwZSAqLw0KKyAgIF9faWE2
NF9yZXRfZnJvbV9jbG9uZSA9IGlhNjRfcmV0X2Zyb21fY2xvbmUgKyAwOw0KKyNpZmRlZiBDT05G
SUdfSUEzMl9TVVBQT1JUDQorICAgX19pYTMyX3JldF9mcm9tX2Nsb25lID0gaWEzMl9yZXRfZnJv
bV9jbG9uZSArIDA7DQorI2VuZGlmDQorDQogICAvKiBSZWFkLW9ubHkgZGF0YSAqLw0KIA0KICAg
LyogR2xvYmFsIGRhdGEgKi8NCg==

------_=_NextPart_001_01C2C0F6.A9A3537A--

