From: "Siddha, Suresh B" <suresh.b.siddha@intel.com>
Date: Sat, 18 Jan 2003 01:43:44 +0000
Subject: [Linux-ia64] [Patch] Fix in process.c
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C2BE93.0915945A"
Message-Id: <marc-linux-ia64-105590709805720@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C2BE93.0915945A
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

Attached/appended fix for another problem(getting the address of a =
function), which depends on the compiler behaviour.

thanks,
suresh

diff -Nru linux-2.5.52/arch/ia64/kernel/process.c~ =
linux-2.5.52/arch/ia64/kernel/process.c
--- linux-2.5.52/arch/ia64/kernel/process.c~	Fri Jan 17 14:53:52 2003
+++ linux-2.5.52/arch/ia64/kernel/process.c	Fri Jan 17 15:27:46 2003
@@ -281,7 +281,10 @@
 {
 	unsigned long rbs, child_rbs, rbs_size, stack_offset, stack_top, =
stack_used;
 	struct switch_stack *child_stack, *stack;
-	extern char ia64_ret_from_clone, ia32_ret_from_clone;
+	extern void  ia64_ret_from_clone(void);
+#ifdef CONFIG_IA32_SUPPORT
+	extern void ia32_ret_from_clone(void);
+#endif
 	struct pt_regs *child_ptregs;
 	int retval =3D 0;
=20
@@ -332,10 +335,13 @@
 		child_ptregs->r12 =3D (unsigned long) (child_ptregs + 1); /* kernel =
sp */
 		child_ptregs->r13 =3D (unsigned long) p;		/* set `current' pointer */
 	}
+#ifdef CONFIG_IA32_SUPPORT
 	if (IS_IA32_PROCESS(regs))
-		child_stack->b0 =3D (unsigned long) &ia32_ret_from_clone;
+		child_stack->b0 =3D ((unsigned long *) &ia32_ret_from_clone)[0];
 	else
-		child_stack->b0 =3D (unsigned long) &ia64_ret_from_clone;
+#else
+		child_stack->b0 =3D ((unsigned long *) &ia64_ret_from_clone)[0];
+#endif
 	child_stack->ar_bspstore =3D child_rbs + rbs_size;
=20
 	/* copy parts of thread_struct: */

------_=_NextPart_001_01C2BE93.0915945A
Content-Type: application/octet-stream;
	name="process.c.diff"
Content-Transfer-Encoding: base64
Content-Description: process.c.diff
Content-Disposition: attachment;
	filename="process.c.diff"

ZGlmZiAtTnJ1IGxpbnV4LTIuNS41Mi9hcmNoL2lhNjQva2VybmVsL3Byb2Nlc3MuY34gbGludXgt
Mi41LjUyL2FyY2gvaWE2NC9rZXJuZWwvcHJvY2Vzcy5jDQotLS0gbGludXgtMi41LjUyL2FyY2gv
aWE2NC9rZXJuZWwvcHJvY2Vzcy5jfglGcmkgSmFuIDE3IDE0OjUzOjUyIDIwMDMNCisrKyBsaW51
eC0yLjUuNTIvYXJjaC9pYTY0L2tlcm5lbC9wcm9jZXNzLmMJRnJpIEphbiAxNyAxNToyNzo0NiAy
MDAzDQpAQCAtMjgxLDcgKzI4MSwxMCBAQA0KIHsNCiAJdW5zaWduZWQgbG9uZyByYnMsIGNoaWxk
X3JicywgcmJzX3NpemUsIHN0YWNrX29mZnNldCwgc3RhY2tfdG9wLCBzdGFja191c2VkOw0KIAlz
dHJ1Y3Qgc3dpdGNoX3N0YWNrICpjaGlsZF9zdGFjaywgKnN0YWNrOw0KLQlleHRlcm4gY2hhciBp
YTY0X3JldF9mcm9tX2Nsb25lLCBpYTMyX3JldF9mcm9tX2Nsb25lOw0KKwlleHRlcm4gdm9pZCAg
aWE2NF9yZXRfZnJvbV9jbG9uZSh2b2lkKTsNCisjaWZkZWYgQ09ORklHX0lBMzJfU1VQUE9SVA0K
KwlleHRlcm4gdm9pZCBpYTMyX3JldF9mcm9tX2Nsb25lKHZvaWQpOw0KKyNlbmRpZg0KIAlzdHJ1
Y3QgcHRfcmVncyAqY2hpbGRfcHRyZWdzOw0KIAlpbnQgcmV0dmFsID0gMDsNCiANCkBAIC0zMzIs
MTAgKzMzNSwxMyBAQA0KIAkJY2hpbGRfcHRyZWdzLT5yMTIgPSAodW5zaWduZWQgbG9uZykgKGNo
aWxkX3B0cmVncyArIDEpOyAvKiBrZXJuZWwgc3AgKi8NCiAJCWNoaWxkX3B0cmVncy0+cjEzID0g
KHVuc2lnbmVkIGxvbmcpIHA7CQkvKiBzZXQgYGN1cnJlbnQnIHBvaW50ZXIgKi8NCiAJfQ0KKyNp
ZmRlZiBDT05GSUdfSUEzMl9TVVBQT1JUDQogCWlmIChJU19JQTMyX1BST0NFU1MocmVncykpDQot
CQljaGlsZF9zdGFjay0+YjAgPSAodW5zaWduZWQgbG9uZykgJmlhMzJfcmV0X2Zyb21fY2xvbmU7
DQorCQljaGlsZF9zdGFjay0+YjAgPSAoKHVuc2lnbmVkIGxvbmcgKikgJmlhMzJfcmV0X2Zyb21f
Y2xvbmUpWzBdOw0KIAllbHNlDQotCQljaGlsZF9zdGFjay0+YjAgPSAodW5zaWduZWQgbG9uZykg
JmlhNjRfcmV0X2Zyb21fY2xvbmU7DQorI2Vsc2UNCisJCWNoaWxkX3N0YWNrLT5iMCA9ICgodW5z
aWduZWQgbG9uZyAqKSAmaWE2NF9yZXRfZnJvbV9jbG9uZSlbMF07DQorI2VuZGlmDQogCWNoaWxk
X3N0YWNrLT5hcl9ic3BzdG9yZSA9IGNoaWxkX3JicyArIHJic19zaXplOw0KIA0KIAkvKiBjb3B5
IHBhcnRzIG9mIHRocmVhZF9zdHJ1Y3Q6ICovDQo=

------_=_NextPart_001_01C2BE93.0915945A--

