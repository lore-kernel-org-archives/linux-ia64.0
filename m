From: "Pallipadi, Venkatesh" <venkatesh.pallipadi@intel.com>
Date: Thu, 28 Nov 2002 01:31:08 +0000
Subject: [Linux-ia64] [PATCH] IA32 ptrace bug-fixes
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C2967D.D39B20B8"
Message-Id: <marc-linux-ia64-105590709805494@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C2967D.D39B20B8
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable


Attached is the patch to IA32 ptrace code in IA64 kernel. This
patch basically helps gdb'ing of an ia32 app (with ia32=20
gdb binary). The patch can easily be verified by running gdb and=20
looking at all-registers.

The changes done in the patch include:
1) Support for xmm registers.=20
   At present xmm registers are not saved/restored during=20
   ptrace and gdb wont show them. Patch adds new ptrace=20
   options (IA32_PTRACE_GETFPXREGS and IA32_PTRACE_SETFPXREGS,=20
   used by gdb to get/set fp+xmm state).
2) Bug fix in getting 'tag' field of fpstate
      (fsr>>16 in place of fsr>>32)
3) Bug fix in calculating fp TOS=20
   (it is a 3 bit field in fsr. Using (fsr>>11) & 7 in place=20
    of (fsr>>11) & 3)
Also, I had to add new structures in ia32.h, corresponding to
the way gdb is expecting the data. Gdb uses structures
defined in sys/user.h

Please let me know, if you need any more information on this.

Thanks,
-Venkatesh

--- ia64-fpe/include/asm-ia64/ia32.h.1	Tue Oct  8 17:00:19 2002
+++ ia64-fpe/include/asm-ia64/ia32.h	Tue Oct  8 13:34:08 2002
@@ -131,6 +131,44 @@
 };
=20
=20
+/* user.h */
+/*
+ * IA32 (Pentium III/4) FXSR, SSE support
+ *
+ * Provide support for the GDB 5.0+ PTRACE_{GET|SET}FPXREGS requests =
for
+ * interacting with the FXSR-format floating point environment.  =
Floating
+ * point data can be accessed in the regular format in the usual =
manner,
+ * and both the standard and SIMD floating point data can be accessed =
via
+ * the new ptrace requests.  In either case, changes to the FPU =
environment
+ * will be reflected in the task's state as expected.
+ */
+struct ia32_user_i387_struct {
+	int	cwd;
+	int	swd;
+	int	twd;
+	int	fip;
+	int	fcs;
+	int	foo;
+	int	fos;
+	int	st_space[20];	/* 8*10 bytes for each FP-reg =3D 80 bytes */
+};
+
+struct ia32_user_fxsr_struct {
+	unsigned short	cwd;
+	unsigned short	swd;
+	unsigned short	twd;
+	unsigned short	fop;
+	int	fip;
+	int	fcs;
+	int	foo;
+	int	fos;
+	int	mxcsr;
+	int	reserved;
+	int	st_space[32];	/* 8*16 bytes for each FP-reg =3D 128 bytes */
+	int	xmm_space[32];	/* 8*16 bytes for each XMM-reg =3D 128 bytes */
+	int	padding[56];
+};
+
 /* signal.h */
 #define _IA32_NSIG	       64
 #define _IA32_NSIG_BPW	       32
@@ -464,6 +502,8 @@
 #define IA32_PTRACE_SETREGS	13
 #define IA32_PTRACE_GETFPREGS	14
 #define IA32_PTRACE_SETFPREGS	15
+#define IA32_PTRACE_GETFPXREGS	18
+#define IA32_PTRACE_SETFPXREGS	19
=20
 #define ia32_start_thread(regs,new_ip,new_sp) do {				\
 	set_fs(USER_DS);							\
--- ia64-fpe/arch/ia64/ia32/sys_ia32.c.1	Mon Oct  7 23:21:19 2002
+++ ia64-fpe/arch/ia64/ia32/sys_ia32.c	Tue Oct  8 17:23:41 2002
@@ -2899,58 +2899,144 @@
 }
=20
 static int
-save_ia32_fpstate (struct task_struct *tsk, struct _fpstate_ia32 *save)
+save_ia32_fpstate (struct task_struct *tsk, struct =
ia32_user_i387_struct *save)
 {
 	struct switch_stack *swp;
 	struct pt_regs *ptp;
 	int i, tos;
=20
 	if (!access_ok(VERIFY_WRITE, save, sizeof(*save)))
-		return -EIO;
-	__put_user(tsk->thread.fcr, &save->cw);
-	__put_user(tsk->thread.fsr, &save->sw);
-	__put_user(tsk->thread.fsr >> 32, &save->tag);
-	__put_user(tsk->thread.fir, &save->ipoff);
-	__put_user(__USER_CS, &save->cssel);
-	__put_user(tsk->thread.fdr, &save->dataoff);
-	__put_user(__USER_DS, &save->datasel);
+		return -EFAULT;
+
+	__put_user(tsk->thread.fcr & 0xffff, &save->cwd);
+	__put_user(tsk->thread.fsr & 0xffff, &save->swd);
+	__put_user((tsk->thread.fsr>>16) & 0xffff, &save->twd);
+	__put_user(tsk->thread.fir, &save->fip);
+	__put_user((tsk->thread.fir>>32) & 0xffff, &save->fcs);
+	__put_user(tsk->thread.fdr, &save->foo);
+	__put_user((tsk->thread.fdr>>32) & 0xffff, &save->fos);
=20
 	/*
 	 *  Stack frames start with 16-bytes of temp space
 	 */
 	swp =3D (struct switch_stack *)(tsk->thread.ksp + 16);
 	ptp =3D ia64_task_regs(tsk);
-	tos =3D (tsk->thread.fsr >> 11) & 3;
+	tos =3D (tsk->thread.fsr >> 11) & 7;
 	for (i =3D 0; i < 8; i++)
-		put_fpreg(i, &save->_st[i], ptp, swp, tos);
+		put_fpreg(i, (struct _fpreg_ia32 *)&save->st_space[4*i], ptp, swp, =
tos);
 	return 0;
 }
=20
 static int
-restore_ia32_fpstate (struct task_struct *tsk, struct _fpstate_ia32 =
*save)
+restore_ia32_fpstate (struct task_struct *tsk, struct =
ia32_user_i387_struct *save)
 {
 	struct switch_stack *swp;
 	struct pt_regs *ptp;
-	int i, tos, ret;
-	int fsrlo, fsrhi;
+	int i, tos;
+	unsigned int fsrlo, fsrhi, num32;
=20
 	if (!access_ok(VERIFY_READ, save, sizeof(*save)))
-		return(-EIO);
-	ret =3D __get_user(tsk->thread.fcr, (unsigned int *)&save->cw);
-	ret |=3D __get_user(fsrlo, (unsigned int *)&save->sw);
-	ret |=3D __get_user(fsrhi, (unsigned int *)&save->tag);
-	tsk->thread.fsr =3D ((long)fsrhi << 32) | (long)fsrlo;
-	ret |=3D __get_user(tsk->thread.fir, (unsigned int *)&save->ipoff);
-	ret |=3D __get_user(tsk->thread.fdr, (unsigned int *)&save->dataoff);
+		return(-EFAULT);
+
+	__get_user(num32, (unsigned int *)&save->cwd);
+	tsk->thread.fcr =3D (tsk->thread.fcr & (~0x1f3f)) | (num32 & 0x1f3f);
+	__get_user(fsrlo, (unsigned int *)&save->swd);
+	__get_user(fsrhi, (unsigned int *)&save->twd);
+	num32 =3D (fsrhi << 16) | fsrlo;
+	tsk->thread.fsr =3D (tsk->thread.fsr & (~0xffffffff)) | num32;
+
+	/*
+	 *  Stack frames start with 16-bytes of temp space
+	 */
+	swp =3D (struct switch_stack *)(tsk->thread.ksp + 16);
+	ptp =3D ia64_task_regs(tsk);
+	tos =3D (tsk->thread.fsr >> 11) & 7;
+	for (i =3D 0; i < 8; i++)
+		get_fpreg(i, (struct _fpreg_ia32 *)&save->st_space[4*i], ptp, swp, =
tos);
+	return 0;
+}
+
+static int
+save_ia32_fpxstate (struct task_struct *tsk, struct =
ia32_user_fxsr_struct *save)
+{
+	struct switch_stack *swp;
+	struct pt_regs *ptp;
+	int i, tos;
+	unsigned long mxcsr=3D0;
+	unsigned long num128[2];
+
+	if (!access_ok(VERIFY_WRITE, save, sizeof(*save)))
+		return -EFAULT;
+
+	__put_user(tsk->thread.fcr & 0xffff, &save->cwd);
+	__put_user(tsk->thread.fsr & 0xffff, &save->swd);
+	__put_user((tsk->thread.fsr>>16) & 0xffff, &save->twd);
+	__put_user(tsk->thread.fir, &save->fip);
+	__put_user((tsk->thread.fir>>32) & 0xffff, &save->fcs);
+	__put_user(tsk->thread.fdr, &save->foo);
+	__put_user((tsk->thread.fdr>>32) & 0xffff, &save->fos);
+
 	/*
 	 *  Stack frames start with 16-bytes of temp space
 	 */
 	swp =3D (struct switch_stack *)(tsk->thread.ksp + 16);
 	ptp =3D ia64_task_regs(tsk);
-	tos =3D (tsk->thread.fsr >> 11) & 3;
+	tos =3D (tsk->thread.fsr >> 11) & 7;
 	for (i =3D 0; i < 8; i++)
-		get_fpreg(i, &save->_st[i], ptp, swp, tos);
-	return ret ? -EFAULT : 0;
+		put_fpreg(i, (struct _fpxreg_ia32 *)&save->st_space[4*i], ptp, swp, =
tos);
+
+	mxcsr =3D ((tsk->thread.fcr>>32) & 0xff80) | ((tsk->thread.fsr>>32) & =
0x3f);
+	__put_user(mxcsr & 0xffff, &save->mxcsr);
+	for (i =3D 0; i < 8; i++) {
+		memcpy(&(num128[0]), &(swp->f16) + i*2, sizeof(unsigned long));
+		memcpy(&(num128[1]), &(swp->f17) + i*2, sizeof(unsigned long));
+		copy_to_user(&save->xmm_space[0] + 4*i, num128, sizeof(struct =
_xmmreg_ia32));
+	}
+	return 0;
+}
+
+static int
+restore_ia32_fpxstate (struct task_struct *tsk, struct =
ia32_user_fxsr_struct *save)
+{
+	struct switch_stack *swp;
+	struct pt_regs *ptp;
+	int i, tos;
+	unsigned int fsrlo, fsrhi, num32;
+	int mxcsr;
+	unsigned long num64;
+	unsigned long num128[2];
+
+	if (!access_ok(VERIFY_READ, save, sizeof(*save)))
+		return(-EFAULT);
+
+	__get_user(num32, (unsigned int *)&save->cwd);
+	tsk->thread.fcr =3D (tsk->thread.fcr & (~0x1f3f)) | (num32 & 0x1f3f);
+	__get_user(fsrlo, (unsigned int *)&save->swd);
+	__get_user(fsrhi, (unsigned int *)&save->twd);
+	num32 =3D (fsrhi << 16) | fsrlo;
+	tsk->thread.fsr =3D (tsk->thread.fsr & (~0xffffffff)) | num32;
+
+	/*
+	 *  Stack frames start with 16-bytes of temp space
+	 */
+	swp =3D (struct switch_stack *)(tsk->thread.ksp + 16);
+	ptp =3D ia64_task_regs(tsk);
+	tos =3D (tsk->thread.fsr >> 11) & 7;
+	for (i =3D 0; i < 8; i++)
+		get_fpreg(i, (struct _fpxreg_ia32 *)&save->st_space[4*i], ptp, swp, =
tos);
+
+	__get_user(mxcsr, (unsigned int *)&save->mxcsr);
+	num64 =3D mxcsr & 0xff10;
+	tsk->thread.fcr =3D (tsk->thread.fcr & (~0xff1000000000)) | =
(num64<<32);
+	num64 =3D mxcsr & 0x3f;
+	tsk->thread.fsr =3D (tsk->thread.fsr & (~0x3f00000000)) | (num64<<32);
+
+	for (i =3D 0; i < 8; i++) {
+		copy_from_user(num128, &save->xmm_space[0] + 4*i, sizeof(struct =
_xmmreg_ia32));
+		memcpy(&(swp->f16) + i*2, &(num128[0]), sizeof(unsigned long));
+		memcpy(&(swp->f17) + i*2, &(num128[1]), sizeof(unsigned long));
+	}
+	return 0;
 }
=20
 extern asmlinkage long sys_ptrace (long, pid_t, unsigned long, unsigned =
long, long, long, long,
@@ -3062,11 +3148,21 @@
 		break;
=20
 	      case IA32_PTRACE_GETFPREGS:
-		ret =3D save_ia32_fpstate(child, (struct _fpstate_ia32 *) A(data));
+		ret =3D save_ia32_fpstate(child, (struct ia32_user_i387_struct *) =
A(data));
+		break;
+
+	      case IA32_PTRACE_GETFPXREGS:
+		ret =3D save_ia32_fpxstate(child, (struct ia32_user_fxsr_struct *) =
A(data));
 		break;
=20
 	      case IA32_PTRACE_SETFPREGS:
-		ret =3D restore_ia32_fpstate(child, (struct _fpstate_ia32 *) =
A(data));
+		ret =3D restore_ia32_fpstate(child, (struct ia32_user_i387_struct *) =
A(data));
+		ret =3D 0;
+		break;
+
+	      case IA32_PTRACE_SETFPXREGS:
+		ret =3D restore_ia32_fpxstate(child, (struct ia32_user_fxsr_struct *) =
A(data));
+		ret =3D 0;
 		break;
=20
 	      case PTRACE_SYSCALL:	/* continue, stop after next syscall */




------_=_NextPart_001_01C2967D.D39B20B8
Content-Type: application/octet-stream;
	name="ia32_ptrace.patch"
Content-Transfer-Encoding: base64
Content-Description: ia32_ptrace.patch
Content-Disposition: attachment;
	filename="ia32_ptrace.patch"

LS0tIGlhNjQtZnBlL2luY2x1ZGUvYXNtLWlhNjQvaWEzMi5oLjEJVHVlIE9jdCAgOCAxNzowMDox
OSAyMDAyCisrKyBpYTY0LWZwZS9pbmNsdWRlL2FzbS1pYTY0L2lhMzIuaAlUdWUgT2N0ICA4IDEz
OjM0OjA4IDIwMDIKQEAgLTEzMSw2ICsxMzEsNDQgQEAKIH07CiAKIAorLyogdXNlci5oICovCisv
KgorICogSUEzMiAoUGVudGl1bSBJSUkvNCkgRlhTUiwgU1NFIHN1cHBvcnQKKyAqCisgKiBQcm92
aWRlIHN1cHBvcnQgZm9yIHRoZSBHREIgNS4wKyBQVFJBQ0Vfe0dFVHxTRVR9RlBYUkVHUyByZXF1
ZXN0cyBmb3IKKyAqIGludGVyYWN0aW5nIHdpdGggdGhlIEZYU1ItZm9ybWF0IGZsb2F0aW5nIHBv
aW50IGVudmlyb25tZW50LiAgRmxvYXRpbmcKKyAqIHBvaW50IGRhdGEgY2FuIGJlIGFjY2Vzc2Vk
IGluIHRoZSByZWd1bGFyIGZvcm1hdCBpbiB0aGUgdXN1YWwgbWFubmVyLAorICogYW5kIGJvdGgg
dGhlIHN0YW5kYXJkIGFuZCBTSU1EIGZsb2F0aW5nIHBvaW50IGRhdGEgY2FuIGJlIGFjY2Vzc2Vk
IHZpYQorICogdGhlIG5ldyBwdHJhY2UgcmVxdWVzdHMuICBJbiBlaXRoZXIgY2FzZSwgY2hhbmdl
cyB0byB0aGUgRlBVIGVudmlyb25tZW50CisgKiB3aWxsIGJlIHJlZmxlY3RlZCBpbiB0aGUgdGFz
aydzIHN0YXRlIGFzIGV4cGVjdGVkLgorICovCitzdHJ1Y3QgaWEzMl91c2VyX2kzODdfc3RydWN0
IHsKKwlpbnQJY3dkOworCWludAlzd2Q7CisJaW50CXR3ZDsKKwlpbnQJZmlwOworCWludAlmY3M7
CisJaW50CWZvbzsKKwlpbnQJZm9zOworCWludAlzdF9zcGFjZVsyMF07CS8qIDgqMTAgYnl0ZXMg
Zm9yIGVhY2ggRlAtcmVnID0gODAgYnl0ZXMgKi8KK307CisKK3N0cnVjdCBpYTMyX3VzZXJfZnhz
cl9zdHJ1Y3QgeworCXVuc2lnbmVkIHNob3J0CWN3ZDsKKwl1bnNpZ25lZCBzaG9ydAlzd2Q7CisJ
dW5zaWduZWQgc2hvcnQJdHdkOworCXVuc2lnbmVkIHNob3J0CWZvcDsKKwlpbnQJZmlwOworCWlu
dAlmY3M7CisJaW50CWZvbzsKKwlpbnQJZm9zOworCWludAlteGNzcjsKKwlpbnQJcmVzZXJ2ZWQ7
CisJaW50CXN0X3NwYWNlWzMyXTsJLyogOCoxNiBieXRlcyBmb3IgZWFjaCBGUC1yZWcgPSAxMjgg
Ynl0ZXMgKi8KKwlpbnQJeG1tX3NwYWNlWzMyXTsJLyogOCoxNiBieXRlcyBmb3IgZWFjaCBYTU0t
cmVnID0gMTI4IGJ5dGVzICovCisJaW50CXBhZGRpbmdbNTZdOworfTsKKwogLyogc2lnbmFsLmgg
Ki8KICNkZWZpbmUgX0lBMzJfTlNJRwkgICAgICAgNjQKICNkZWZpbmUgX0lBMzJfTlNJR19CUFcJ
ICAgICAgIDMyCkBAIC00NjQsNiArNTAyLDggQEAKICNkZWZpbmUgSUEzMl9QVFJBQ0VfU0VUUkVH
UwkxMwogI2RlZmluZSBJQTMyX1BUUkFDRV9HRVRGUFJFR1MJMTQKICNkZWZpbmUgSUEzMl9QVFJB
Q0VfU0VURlBSRUdTCTE1CisjZGVmaW5lIElBMzJfUFRSQUNFX0dFVEZQWFJFR1MJMTgKKyNkZWZp
bmUgSUEzMl9QVFJBQ0VfU0VURlBYUkVHUwkxOQogCiAjZGVmaW5lIGlhMzJfc3RhcnRfdGhyZWFk
KHJlZ3MsbmV3X2lwLG5ld19zcCkgZG8gewkJCQlcCiAJc2V0X2ZzKFVTRVJfRFMpOwkJCQkJCQlc
Ci0tLSBpYTY0LWZwZS9hcmNoL2lhNjQvaWEzMi9zeXNfaWEzMi5jLjEJTW9uIE9jdCAgNyAyMzoy
MToxOSAyMDAyCisrKyBpYTY0LWZwZS9hcmNoL2lhNjQvaWEzMi9zeXNfaWEzMi5jCVR1ZSBPY3Qg
IDggMTc6MjM6NDEgMjAwMgpAQCAtMjg5OSw1OCArMjg5OSwxNDQgQEAKIH0KIAogc3RhdGljIGlu
dAotc2F2ZV9pYTMyX2Zwc3RhdGUgKHN0cnVjdCB0YXNrX3N0cnVjdCAqdHNrLCBzdHJ1Y3QgX2Zw
c3RhdGVfaWEzMiAqc2F2ZSkKK3NhdmVfaWEzMl9mcHN0YXRlIChzdHJ1Y3QgdGFza19zdHJ1Y3Qg
KnRzaywgc3RydWN0IGlhMzJfdXNlcl9pMzg3X3N0cnVjdCAqc2F2ZSkKIHsKIAlzdHJ1Y3Qgc3dp
dGNoX3N0YWNrICpzd3A7CiAJc3RydWN0IHB0X3JlZ3MgKnB0cDsKIAlpbnQgaSwgdG9zOwogCiAJ
aWYgKCFhY2Nlc3Nfb2soVkVSSUZZX1dSSVRFLCBzYXZlLCBzaXplb2YoKnNhdmUpKSkKLQkJcmV0
dXJuIC1FSU87Ci0JX19wdXRfdXNlcih0c2stPnRocmVhZC5mY3IsICZzYXZlLT5jdyk7Ci0JX19w
dXRfdXNlcih0c2stPnRocmVhZC5mc3IsICZzYXZlLT5zdyk7Ci0JX19wdXRfdXNlcih0c2stPnRo
cmVhZC5mc3IgPj4gMzIsICZzYXZlLT50YWcpOwotCV9fcHV0X3VzZXIodHNrLT50aHJlYWQuZmly
LCAmc2F2ZS0+aXBvZmYpOwotCV9fcHV0X3VzZXIoX19VU0VSX0NTLCAmc2F2ZS0+Y3NzZWwpOwot
CV9fcHV0X3VzZXIodHNrLT50aHJlYWQuZmRyLCAmc2F2ZS0+ZGF0YW9mZik7Ci0JX19wdXRfdXNl
cihfX1VTRVJfRFMsICZzYXZlLT5kYXRhc2VsKTsKKwkJcmV0dXJuIC1FRkFVTFQ7CisKKwlfX3B1
dF91c2VyKHRzay0+dGhyZWFkLmZjciAmIDB4ZmZmZiwgJnNhdmUtPmN3ZCk7CisJX19wdXRfdXNl
cih0c2stPnRocmVhZC5mc3IgJiAweGZmZmYsICZzYXZlLT5zd2QpOworCV9fcHV0X3VzZXIoKHRz
ay0+dGhyZWFkLmZzcj4+MTYpICYgMHhmZmZmLCAmc2F2ZS0+dHdkKTsKKwlfX3B1dF91c2VyKHRz
ay0+dGhyZWFkLmZpciwgJnNhdmUtPmZpcCk7CisJX19wdXRfdXNlcigodHNrLT50aHJlYWQuZmly
Pj4zMikgJiAweGZmZmYsICZzYXZlLT5mY3MpOworCV9fcHV0X3VzZXIodHNrLT50aHJlYWQuZmRy
LCAmc2F2ZS0+Zm9vKTsKKwlfX3B1dF91c2VyKCh0c2stPnRocmVhZC5mZHI+PjMyKSAmIDB4ZmZm
ZiwgJnNhdmUtPmZvcyk7CiAKIAkvKgogCSAqICBTdGFjayBmcmFtZXMgc3RhcnQgd2l0aCAxNi1i
eXRlcyBvZiB0ZW1wIHNwYWNlCiAJICovCiAJc3dwID0gKHN0cnVjdCBzd2l0Y2hfc3RhY2sgKiko
dHNrLT50aHJlYWQua3NwICsgMTYpOwogCXB0cCA9IGlhNjRfdGFza19yZWdzKHRzayk7Ci0JdG9z
ID0gKHRzay0+dGhyZWFkLmZzciA+PiAxMSkgJiAzOworCXRvcyA9ICh0c2stPnRocmVhZC5mc3Ig
Pj4gMTEpICYgNzsKIAlmb3IgKGkgPSAwOyBpIDwgODsgaSsrKQotCQlwdXRfZnByZWcoaSwgJnNh
dmUtPl9zdFtpXSwgcHRwLCBzd3AsIHRvcyk7CisJCXB1dF9mcHJlZyhpLCAoc3RydWN0IF9mcHJl
Z19pYTMyICopJnNhdmUtPnN0X3NwYWNlWzQqaV0sIHB0cCwgc3dwLCB0b3MpOwogCXJldHVybiAw
OwogfQogCiBzdGF0aWMgaW50Ci1yZXN0b3JlX2lhMzJfZnBzdGF0ZSAoc3RydWN0IHRhc2tfc3Ry
dWN0ICp0c2ssIHN0cnVjdCBfZnBzdGF0ZV9pYTMyICpzYXZlKQorcmVzdG9yZV9pYTMyX2Zwc3Rh
dGUgKHN0cnVjdCB0YXNrX3N0cnVjdCAqdHNrLCBzdHJ1Y3QgaWEzMl91c2VyX2kzODdfc3RydWN0
ICpzYXZlKQogewogCXN0cnVjdCBzd2l0Y2hfc3RhY2sgKnN3cDsKIAlzdHJ1Y3QgcHRfcmVncyAq
cHRwOwotCWludCBpLCB0b3MsIHJldDsKLQlpbnQgZnNybG8sIGZzcmhpOworCWludCBpLCB0b3M7
CisJdW5zaWduZWQgaW50IGZzcmxvLCBmc3JoaSwgbnVtMzI7CiAKIAlpZiAoIWFjY2Vzc19vayhW
RVJJRllfUkVBRCwgc2F2ZSwgc2l6ZW9mKCpzYXZlKSkpCi0JCXJldHVybigtRUlPKTsKLQlyZXQg
PSBfX2dldF91c2VyKHRzay0+dGhyZWFkLmZjciwgKHVuc2lnbmVkIGludCAqKSZzYXZlLT5jdyk7
Ci0JcmV0IHw9IF9fZ2V0X3VzZXIoZnNybG8sICh1bnNpZ25lZCBpbnQgKikmc2F2ZS0+c3cpOwot
CXJldCB8PSBfX2dldF91c2VyKGZzcmhpLCAodW5zaWduZWQgaW50ICopJnNhdmUtPnRhZyk7Ci0J
dHNrLT50aHJlYWQuZnNyID0gKChsb25nKWZzcmhpIDw8IDMyKSB8IChsb25nKWZzcmxvOwotCXJl
dCB8PSBfX2dldF91c2VyKHRzay0+dGhyZWFkLmZpciwgKHVuc2lnbmVkIGludCAqKSZzYXZlLT5p
cG9mZik7Ci0JcmV0IHw9IF9fZ2V0X3VzZXIodHNrLT50aHJlYWQuZmRyLCAodW5zaWduZWQgaW50
ICopJnNhdmUtPmRhdGFvZmYpOworCQlyZXR1cm4oLUVGQVVMVCk7CisKKwlfX2dldF91c2VyKG51
bTMyLCAodW5zaWduZWQgaW50ICopJnNhdmUtPmN3ZCk7CisJdHNrLT50aHJlYWQuZmNyID0gKHRz
ay0+dGhyZWFkLmZjciAmICh+MHgxZjNmKSkgfCAobnVtMzIgJiAweDFmM2YpOworCV9fZ2V0X3Vz
ZXIoZnNybG8sICh1bnNpZ25lZCBpbnQgKikmc2F2ZS0+c3dkKTsKKwlfX2dldF91c2VyKGZzcmhp
LCAodW5zaWduZWQgaW50ICopJnNhdmUtPnR3ZCk7CisJbnVtMzIgPSAoZnNyaGkgPDwgMTYpIHwg
ZnNybG87CisJdHNrLT50aHJlYWQuZnNyID0gKHRzay0+dGhyZWFkLmZzciAmICh+MHhmZmZmZmZm
ZikpIHwgbnVtMzI7CisKKwkvKgorCSAqICBTdGFjayBmcmFtZXMgc3RhcnQgd2l0aCAxNi1ieXRl
cyBvZiB0ZW1wIHNwYWNlCisJICovCisJc3dwID0gKHN0cnVjdCBzd2l0Y2hfc3RhY2sgKikodHNr
LT50aHJlYWQua3NwICsgMTYpOworCXB0cCA9IGlhNjRfdGFza19yZWdzKHRzayk7CisJdG9zID0g
KHRzay0+dGhyZWFkLmZzciA+PiAxMSkgJiA3OworCWZvciAoaSA9IDA7IGkgPCA4OyBpKyspCisJ
CWdldF9mcHJlZyhpLCAoc3RydWN0IF9mcHJlZ19pYTMyICopJnNhdmUtPnN0X3NwYWNlWzQqaV0s
IHB0cCwgc3dwLCB0b3MpOworCXJldHVybiAwOworfQorCitzdGF0aWMgaW50CitzYXZlX2lhMzJf
ZnB4c3RhdGUgKHN0cnVjdCB0YXNrX3N0cnVjdCAqdHNrLCBzdHJ1Y3QgaWEzMl91c2VyX2Z4c3Jf
c3RydWN0ICpzYXZlKQoreworCXN0cnVjdCBzd2l0Y2hfc3RhY2sgKnN3cDsKKwlzdHJ1Y3QgcHRf
cmVncyAqcHRwOworCWludCBpLCB0b3M7CisJdW5zaWduZWQgbG9uZyBteGNzcj0wOworCXVuc2ln
bmVkIGxvbmcgbnVtMTI4WzJdOworCisJaWYgKCFhY2Nlc3Nfb2soVkVSSUZZX1dSSVRFLCBzYXZl
LCBzaXplb2YoKnNhdmUpKSkKKwkJcmV0dXJuIC1FRkFVTFQ7CisKKwlfX3B1dF91c2VyKHRzay0+
dGhyZWFkLmZjciAmIDB4ZmZmZiwgJnNhdmUtPmN3ZCk7CisJX19wdXRfdXNlcih0c2stPnRocmVh
ZC5mc3IgJiAweGZmZmYsICZzYXZlLT5zd2QpOworCV9fcHV0X3VzZXIoKHRzay0+dGhyZWFkLmZz
cj4+MTYpICYgMHhmZmZmLCAmc2F2ZS0+dHdkKTsKKwlfX3B1dF91c2VyKHRzay0+dGhyZWFkLmZp
ciwgJnNhdmUtPmZpcCk7CisJX19wdXRfdXNlcigodHNrLT50aHJlYWQuZmlyPj4zMikgJiAweGZm
ZmYsICZzYXZlLT5mY3MpOworCV9fcHV0X3VzZXIodHNrLT50aHJlYWQuZmRyLCAmc2F2ZS0+Zm9v
KTsKKwlfX3B1dF91c2VyKCh0c2stPnRocmVhZC5mZHI+PjMyKSAmIDB4ZmZmZiwgJnNhdmUtPmZv
cyk7CisKIAkvKgogCSAqICBTdGFjayBmcmFtZXMgc3RhcnQgd2l0aCAxNi1ieXRlcyBvZiB0ZW1w
IHNwYWNlCiAJICovCiAJc3dwID0gKHN0cnVjdCBzd2l0Y2hfc3RhY2sgKikodHNrLT50aHJlYWQu
a3NwICsgMTYpOwogCXB0cCA9IGlhNjRfdGFza19yZWdzKHRzayk7Ci0JdG9zID0gKHRzay0+dGhy
ZWFkLmZzciA+PiAxMSkgJiAzOworCXRvcyA9ICh0c2stPnRocmVhZC5mc3IgPj4gMTEpICYgNzsK
IAlmb3IgKGkgPSAwOyBpIDwgODsgaSsrKQotCQlnZXRfZnByZWcoaSwgJnNhdmUtPl9zdFtpXSwg
cHRwLCBzd3AsIHRvcyk7Ci0JcmV0dXJuIHJldCA/IC1FRkFVTFQgOiAwOworCQlwdXRfZnByZWco
aSwgKHN0cnVjdCBfZnB4cmVnX2lhMzIgKikmc2F2ZS0+c3Rfc3BhY2VbNCppXSwgcHRwLCBzd3As
IHRvcyk7CisKKwlteGNzciA9ICgodHNrLT50aHJlYWQuZmNyPj4zMikgJiAweGZmODApIHwgKCh0
c2stPnRocmVhZC5mc3I+PjMyKSAmIDB4M2YpOworCV9fcHV0X3VzZXIobXhjc3IgJiAweGZmZmYs
ICZzYXZlLT5teGNzcik7CisJZm9yIChpID0gMDsgaSA8IDg7IGkrKykgeworCQltZW1jcHkoJihu
dW0xMjhbMF0pLCAmKHN3cC0+ZjE2KSArIGkqMiwgc2l6ZW9mKHVuc2lnbmVkIGxvbmcpKTsKKwkJ
bWVtY3B5KCYobnVtMTI4WzFdKSwgJihzd3AtPmYxNykgKyBpKjIsIHNpemVvZih1bnNpZ25lZCBs
b25nKSk7CisJCWNvcHlfdG9fdXNlcigmc2F2ZS0+eG1tX3NwYWNlWzBdICsgNCppLCBudW0xMjgs
IHNpemVvZihzdHJ1Y3QgX3htbXJlZ19pYTMyKSk7CisJfQorCXJldHVybiAwOworfQorCitzdGF0
aWMgaW50CityZXN0b3JlX2lhMzJfZnB4c3RhdGUgKHN0cnVjdCB0YXNrX3N0cnVjdCAqdHNrLCBz
dHJ1Y3QgaWEzMl91c2VyX2Z4c3Jfc3RydWN0ICpzYXZlKQoreworCXN0cnVjdCBzd2l0Y2hfc3Rh
Y2sgKnN3cDsKKwlzdHJ1Y3QgcHRfcmVncyAqcHRwOworCWludCBpLCB0b3M7CisJdW5zaWduZWQg
aW50IGZzcmxvLCBmc3JoaSwgbnVtMzI7CisJaW50IG14Y3NyOworCXVuc2lnbmVkIGxvbmcgbnVt
NjQ7CisJdW5zaWduZWQgbG9uZyBudW0xMjhbMl07CisKKwlpZiAoIWFjY2Vzc19vayhWRVJJRllf
UkVBRCwgc2F2ZSwgc2l6ZW9mKCpzYXZlKSkpCisJCXJldHVybigtRUZBVUxUKTsKKworCV9fZ2V0
X3VzZXIobnVtMzIsICh1bnNpZ25lZCBpbnQgKikmc2F2ZS0+Y3dkKTsKKwl0c2stPnRocmVhZC5m
Y3IgPSAodHNrLT50aHJlYWQuZmNyICYgKH4weDFmM2YpKSB8IChudW0zMiAmIDB4MWYzZik7CisJ
X19nZXRfdXNlcihmc3JsbywgKHVuc2lnbmVkIGludCAqKSZzYXZlLT5zd2QpOworCV9fZ2V0X3Vz
ZXIoZnNyaGksICh1bnNpZ25lZCBpbnQgKikmc2F2ZS0+dHdkKTsKKwludW0zMiA9IChmc3JoaSA8
PCAxNikgfCBmc3JsbzsKKwl0c2stPnRocmVhZC5mc3IgPSAodHNrLT50aHJlYWQuZnNyICYgKH4w
eGZmZmZmZmZmKSkgfCBudW0zMjsKKworCS8qCisJICogIFN0YWNrIGZyYW1lcyBzdGFydCB3aXRo
IDE2LWJ5dGVzIG9mIHRlbXAgc3BhY2UKKwkgKi8KKwlzd3AgPSAoc3RydWN0IHN3aXRjaF9zdGFj
ayAqKSh0c2stPnRocmVhZC5rc3AgKyAxNik7CisJcHRwID0gaWE2NF90YXNrX3JlZ3ModHNrKTsK
Kwl0b3MgPSAodHNrLT50aHJlYWQuZnNyID4+IDExKSAmIDc7CisJZm9yIChpID0gMDsgaSA8IDg7
IGkrKykKKwkJZ2V0X2ZwcmVnKGksIChzdHJ1Y3QgX2ZweHJlZ19pYTMyICopJnNhdmUtPnN0X3Nw
YWNlWzQqaV0sIHB0cCwgc3dwLCB0b3MpOworCisJX19nZXRfdXNlcihteGNzciwgKHVuc2lnbmVk
IGludCAqKSZzYXZlLT5teGNzcik7CisJbnVtNjQgPSBteGNzciAmIDB4ZmYxMDsKKwl0c2stPnRo
cmVhZC5mY3IgPSAodHNrLT50aHJlYWQuZmNyICYgKH4weGZmMTAwMDAwMDAwMCkpIHwgKG51bTY0
PDwzMik7CisJbnVtNjQgPSBteGNzciAmIDB4M2Y7CisJdHNrLT50aHJlYWQuZnNyID0gKHRzay0+
dGhyZWFkLmZzciAmICh+MHgzZjAwMDAwMDAwKSkgfCAobnVtNjQ8PDMyKTsKKworCWZvciAoaSA9
IDA7IGkgPCA4OyBpKyspIHsKKwkJY29weV9mcm9tX3VzZXIobnVtMTI4LCAmc2F2ZS0+eG1tX3Nw
YWNlWzBdICsgNCppLCBzaXplb2Yoc3RydWN0IF94bW1yZWdfaWEzMikpOworCQltZW1jcHkoJihz
d3AtPmYxNikgKyBpKjIsICYobnVtMTI4WzBdKSwgc2l6ZW9mKHVuc2lnbmVkIGxvbmcpKTsKKwkJ
bWVtY3B5KCYoc3dwLT5mMTcpICsgaSoyLCAmKG51bTEyOFsxXSksIHNpemVvZih1bnNpZ25lZCBs
b25nKSk7CisJfQorCXJldHVybiAwOwogfQogCiBleHRlcm4gYXNtbGlua2FnZSBsb25nIHN5c19w
dHJhY2UgKGxvbmcsIHBpZF90LCB1bnNpZ25lZCBsb25nLCB1bnNpZ25lZCBsb25nLCBsb25nLCBs
b25nLCBsb25nLApAQCAtMzA2MiwxMSArMzE0OCwyMSBAQAogCQlicmVhazsKIAogCSAgICAgIGNh
c2UgSUEzMl9QVFJBQ0VfR0VURlBSRUdTOgotCQlyZXQgPSBzYXZlX2lhMzJfZnBzdGF0ZShjaGls
ZCwgKHN0cnVjdCBfZnBzdGF0ZV9pYTMyICopIEEoZGF0YSkpOworCQlyZXQgPSBzYXZlX2lhMzJf
ZnBzdGF0ZShjaGlsZCwgKHN0cnVjdCBpYTMyX3VzZXJfaTM4N19zdHJ1Y3QgKikgQShkYXRhKSk7
CisJCWJyZWFrOworCisJICAgICAgY2FzZSBJQTMyX1BUUkFDRV9HRVRGUFhSRUdTOgorCQlyZXQg
PSBzYXZlX2lhMzJfZnB4c3RhdGUoY2hpbGQsIChzdHJ1Y3QgaWEzMl91c2VyX2Z4c3Jfc3RydWN0
ICopIEEoZGF0YSkpOwogCQlicmVhazsKIAogCSAgICAgIGNhc2UgSUEzMl9QVFJBQ0VfU0VURlBS
RUdTOgotCQlyZXQgPSByZXN0b3JlX2lhMzJfZnBzdGF0ZShjaGlsZCwgKHN0cnVjdCBfZnBzdGF0
ZV9pYTMyICopIEEoZGF0YSkpOworCQlyZXQgPSByZXN0b3JlX2lhMzJfZnBzdGF0ZShjaGlsZCwg
KHN0cnVjdCBpYTMyX3VzZXJfaTM4N19zdHJ1Y3QgKikgQShkYXRhKSk7CisJCXJldCA9IDA7CisJ
CWJyZWFrOworCisJICAgICAgY2FzZSBJQTMyX1BUUkFDRV9TRVRGUFhSRUdTOgorCQlyZXQgPSBy
ZXN0b3JlX2lhMzJfZnB4c3RhdGUoY2hpbGQsIChzdHJ1Y3QgaWEzMl91c2VyX2Z4c3Jfc3RydWN0
ICopIEEoZGF0YSkpOworCQlyZXQgPSAwOwogCQlicmVhazsKIAogCSAgICAgIGNhc2UgUFRSQUNF
X1NZU0NBTEw6CS8qIGNvbnRpbnVlLCBzdG9wIGFmdGVyIG5leHQgc3lzY2FsbCAqLwo=

------_=_NextPart_001_01C2967D.D39B20B8--

