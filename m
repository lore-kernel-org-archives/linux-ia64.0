From: "Pallipadi, Venkatesh" <venkatesh.pallipadi@intel.com>
Date: Mon, 02 Dec 2002 23:13:58 +0000
Subject: [Linux-ia64] [PATCH] Resend: IA32 ptrace bug-fixes
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C29A58.7E5B7E9F"
Message-Id: <marc-linux-ia64-105590709805495@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C29A58.7E5B7E9F
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable


Resending the patch that applies cleanly onto both 2.4 and 2.5 tree. It =
also has two bug fixes over the previous patch.=20

Please let me know if you need any more information on this.

Thanks,
-Venkatesh

-----Original Message-----
From: Pallipadi, Venkatesh=20
Sent: Wednesday, November 27, 2002 5:31 PM
To: 'linux-ia64@linuxia64.org'
Cc: Mallick, Asit K
Subject: [PATCH] IA32 ptrace bug-fixes
Attached is the patch to IA32 ptrace code in IA64 kernel. This
patch basically helps gdb'ing of an ia32 app (with ia32
gdb binary). The patch can easily be verified by running gdb and
looking at all-registers.

The changes done in the patch include:
1) Support for xmm registers.
   At present xmm registers are not saved/restored during
   ptrace and gdb wont show them. Patch adds new ptrace
   options (IA32_PTRACE_GETFPXREGS and IA32_PTRACE_SETFPXREGS,
   used by gdb to get/set fp+xmm state).
2) Bug fix in getting 'tag' field of fpstate
      (fsr>>16 in place of fsr>>32)
3) Bug fix in calculating fp TOS
   (it is a 3 bit field in fsr. Using (fsr>>11) & 7 in place
    of (fsr>>11) & 3)
Also, I had to add new structures in ia32.h, corresponding to
the way gdb is expecting the data. Gdb uses structures
defined in sys/user.h

Please let me know, if you need any more information on this.

Thanks,
-Venkatesh

--- linux-2.5.50/include/asm-ia64/ia32.h.1	2002-11-28 14:07:10.000000000 =
-0800
+++ linux-2.5.50/include/asm-ia64/ia32.h	2002-11-28 14:07:27.000000000 =
-0800
@@ -130,6 +130,44 @@
        unsigned int cr2;
 };
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
@@ -462,6 +500,8 @@
 #define IA32_PTRACE_SETREGS	13
 #define IA32_PTRACE_GETFPREGS	14
 #define IA32_PTRACE_SETFPREGS	15
+#define IA32_PTRACE_GETFPXREGS	18
+#define IA32_PTRACE_SETFPXREGS	19
=20
 #define ia32_start_thread(regs,new_ip,new_sp) do {				\
 	set_fs(USER_DS);							\
--- linux-2.5.50/arch/ia64/ia32/sys_ia32.c.1	2002-11-28 =
14:06:54.000000000 -0800
+++ linux-2.5.50/arch/ia64/ia32/sys_ia32.c	2002-11-28 18:17:31.000000000 =
-0800
@@ -2898,57 +2898,152 @@
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
+
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
+	return 0;
+}
+
+static int
+restore_ia32_fpstate (struct task_struct *tsk, struct =
ia32_user_i387_struct *save)
+{
+	struct switch_stack *swp;
+	struct pt_regs *ptp;
+	int i, tos;
+	unsigned int fsrlo, fsrhi, num32;
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
+	__get_user(num32, (unsigned int *)&save->fip);
+	tsk->thread.fir =3D (tsk->thread.fir & (~0xffffffff)) | num32;
+	__get_user(num32, (unsigned int *)&save->foo);
+	tsk->thread.fdr =3D (tsk->thread.fdr & (~0xffffffff)) | num32;
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
+        /*
+         *  Stack frames start with 16-bytes of temp space
+         */
+        swp =3D (struct switch_stack *)(tsk->thread.ksp + 16);
+        ptp =3D ia64_task_regs(tsk);
+	tos =3D (tsk->thread.fsr >> 11) & 7;
+        for (i =3D 0; i < 8; i++)
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
 	return 0;
 }
=20
 static int
-restore_ia32_fpstate (struct task_struct *tsk, struct _fpstate_ia32 =
*save)
+restore_ia32_fpxstate (struct task_struct *tsk, struct =
ia32_user_fxsr_struct *save)
 {
 	struct switch_stack *swp;
 	struct pt_regs *ptp;
-	int i, tos, ret;
-	int fsrlo, fsrhi;
+	int i, tos;
+	unsigned int fsrlo, fsrhi, num32;
+	int mxcsr;
+	unsigned long num64;
+	unsigned long num128[2];
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
+	__get_user(num32, (unsigned int *)&save->fip);
+	tsk->thread.fir =3D (tsk->thread.fir & (~0xffffffff)) | num32;
+	__get_user(num32, (unsigned int *)&save->foo);
+	tsk->thread.fdr =3D (tsk->thread.fdr & (~0xffffffff)) | num32;
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
+	get_fpreg(i, (struct _fpxreg_ia32 *)&save->st_space[4*i], ptp, swp, =
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
@@ -3060,11 +3155,19 @@
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
+		break;
+
+	      case IA32_PTRACE_SETFPXREGS:
+		ret =3D restore_ia32_fpxstate(child, (struct ia32_user_fxsr_struct *) =
A(data));
 		break;
=20
 	      case PTRACE_SYSCALL:	/* continue, stop after next syscall */





------_=_NextPart_001_01C29A58.7E5B7E9F
Content-Type: application/octet-stream;
	name="ia32_ptrace_2.5.patch"
Content-Transfer-Encoding: base64
Content-Description: ia32_ptrace_2.5.patch
Content-Disposition: attachment;
	filename="ia32_ptrace_2.5.patch"

LS0tIGxpbnV4LTIuNS41MC9pbmNsdWRlL2FzbS1pYTY0L2lhMzIuaC4xCTIwMDItMTEtMjggMTQ6
MDc6MTAuMDAwMDAwMDAwIC0wODAwCisrKyBsaW51eC0yLjUuNTAvaW5jbHVkZS9hc20taWE2NC9p
YTMyLmgJMjAwMi0xMS0yOCAxNDowNzoyNy4wMDAwMDAwMDAgLTA4MDAKQEAgLTEzMCw2ICsxMzAs
NDQgQEAKICAgICAgICB1bnNpZ25lZCBpbnQgY3IyOwogfTsKIAorLyogdXNlci5oICovCisvKgor
ICogSUEzMiAoUGVudGl1bSBJSUkvNCkgRlhTUiwgU1NFIHN1cHBvcnQKKyAqCisgKiBQcm92aWRl
IHN1cHBvcnQgZm9yIHRoZSBHREIgNS4wKyBQVFJBQ0Vfe0dFVHxTRVR9RlBYUkVHUyByZXF1ZXN0
cyBmb3IKKyAqIGludGVyYWN0aW5nIHdpdGggdGhlIEZYU1ItZm9ybWF0IGZsb2F0aW5nIHBvaW50
IGVudmlyb25tZW50LiAgRmxvYXRpbmcKKyAqIHBvaW50IGRhdGEgY2FuIGJlIGFjY2Vzc2VkIGlu
IHRoZSByZWd1bGFyIGZvcm1hdCBpbiB0aGUgdXN1YWwgbWFubmVyLAorICogYW5kIGJvdGggdGhl
IHN0YW5kYXJkIGFuZCBTSU1EIGZsb2F0aW5nIHBvaW50IGRhdGEgY2FuIGJlIGFjY2Vzc2VkIHZp
YQorICogdGhlIG5ldyBwdHJhY2UgcmVxdWVzdHMuICBJbiBlaXRoZXIgY2FzZSwgY2hhbmdlcyB0
byB0aGUgRlBVIGVudmlyb25tZW50CisgKiB3aWxsIGJlIHJlZmxlY3RlZCBpbiB0aGUgdGFzaydz
IHN0YXRlIGFzIGV4cGVjdGVkLgorICovCitzdHJ1Y3QgaWEzMl91c2VyX2kzODdfc3RydWN0IHsK
KwlpbnQJY3dkOworCWludAlzd2Q7CisJaW50CXR3ZDsKKwlpbnQJZmlwOworCWludAlmY3M7CisJ
aW50CWZvbzsKKwlpbnQJZm9zOworCWludAlzdF9zcGFjZVsyMF07CS8qIDgqMTAgYnl0ZXMgZm9y
IGVhY2ggRlAtcmVnID0gODAgYnl0ZXMgKi8KK307CisKK3N0cnVjdCBpYTMyX3VzZXJfZnhzcl9z
dHJ1Y3QgeworCXVuc2lnbmVkIHNob3J0CWN3ZDsKKwl1bnNpZ25lZCBzaG9ydAlzd2Q7CisJdW5z
aWduZWQgc2hvcnQJdHdkOworCXVuc2lnbmVkIHNob3J0CWZvcDsKKwlpbnQJZmlwOworCWludAlm
Y3M7CisJaW50CWZvbzsKKwlpbnQJZm9zOworCWludAlteGNzcjsKKwlpbnQJcmVzZXJ2ZWQ7CisJ
aW50CXN0X3NwYWNlWzMyXTsJLyogOCoxNiBieXRlcyBmb3IgZWFjaCBGUC1yZWcgPSAxMjggYnl0
ZXMgKi8KKwlpbnQJeG1tX3NwYWNlWzMyXTsJLyogOCoxNiBieXRlcyBmb3IgZWFjaCBYTU0tcmVn
ID0gMTI4IGJ5dGVzICovCisJaW50CXBhZGRpbmdbNTZdOworfTsKKwogLyogc2lnbmFsLmggKi8K
ICNkZWZpbmUgX0lBMzJfTlNJRwkgICAgICAgNjQKICNkZWZpbmUgX0lBMzJfTlNJR19CUFcJICAg
ICAgIDMyCkBAIC00NjIsNiArNTAwLDggQEAKICNkZWZpbmUgSUEzMl9QVFJBQ0VfU0VUUkVHUwkx
MwogI2RlZmluZSBJQTMyX1BUUkFDRV9HRVRGUFJFR1MJMTQKICNkZWZpbmUgSUEzMl9QVFJBQ0Vf
U0VURlBSRUdTCTE1CisjZGVmaW5lIElBMzJfUFRSQUNFX0dFVEZQWFJFR1MJMTgKKyNkZWZpbmUg
SUEzMl9QVFJBQ0VfU0VURlBYUkVHUwkxOQogCiAjZGVmaW5lIGlhMzJfc3RhcnRfdGhyZWFkKHJl
Z3MsbmV3X2lwLG5ld19zcCkgZG8gewkJCQlcCiAJc2V0X2ZzKFVTRVJfRFMpOwkJCQkJCQlcCi0t
LSBsaW51eC0yLjUuNTAvYXJjaC9pYTY0L2lhMzIvc3lzX2lhMzIuYy4xCTIwMDItMTEtMjggMTQ6
MDY6NTQuMDAwMDAwMDAwIC0wODAwCisrKyBsaW51eC0yLjUuNTAvYXJjaC9pYTY0L2lhMzIvc3lz
X2lhMzIuYwkyMDAyLTExLTI4IDE4OjE3OjMxLjAwMDAwMDAwMCAtMDgwMApAQCAtMjg5OCw1NyAr
Mjg5OCwxNTIgQEAKIH0KIAogc3RhdGljIGludAotc2F2ZV9pYTMyX2Zwc3RhdGUgKHN0cnVjdCB0
YXNrX3N0cnVjdCAqdHNrLCBzdHJ1Y3QgX2Zwc3RhdGVfaWEzMiAqc2F2ZSkKK3NhdmVfaWEzMl9m
cHN0YXRlIChzdHJ1Y3QgdGFza19zdHJ1Y3QgKnRzaywgc3RydWN0IGlhMzJfdXNlcl9pMzg3X3N0
cnVjdCAqc2F2ZSkKIHsKIAlzdHJ1Y3Qgc3dpdGNoX3N0YWNrICpzd3A7CiAJc3RydWN0IHB0X3Jl
Z3MgKnB0cDsKIAlpbnQgaSwgdG9zOwogCiAJaWYgKCFhY2Nlc3Nfb2soVkVSSUZZX1dSSVRFLCBz
YXZlLCBzaXplb2YoKnNhdmUpKSkKLQkJcmV0dXJuIC1FSU87Ci0JX19wdXRfdXNlcih0c2stPnRo
cmVhZC5mY3IsICZzYXZlLT5jdyk7Ci0JX19wdXRfdXNlcih0c2stPnRocmVhZC5mc3IsICZzYXZl
LT5zdyk7Ci0JX19wdXRfdXNlcih0c2stPnRocmVhZC5mc3IgPj4gMzIsICZzYXZlLT50YWcpOwot
CV9fcHV0X3VzZXIodHNrLT50aHJlYWQuZmlyLCAmc2F2ZS0+aXBvZmYpOwotCV9fcHV0X3VzZXIo
X19VU0VSX0NTLCAmc2F2ZS0+Y3NzZWwpOwotCV9fcHV0X3VzZXIodHNrLT50aHJlYWQuZmRyLCAm
c2F2ZS0+ZGF0YW9mZik7Ci0JX19wdXRfdXNlcihfX1VTRVJfRFMsICZzYXZlLT5kYXRhc2VsKTsK
KwkJcmV0dXJuIC1FRkFVTFQ7CisKKwlfX3B1dF91c2VyKHRzay0+dGhyZWFkLmZjciAmIDB4ZmZm
ZiwgJnNhdmUtPmN3ZCk7CisJX19wdXRfdXNlcih0c2stPnRocmVhZC5mc3IgJiAweGZmZmYsICZz
YXZlLT5zd2QpOworCV9fcHV0X3VzZXIoKHRzay0+dGhyZWFkLmZzcj4+MTYpICYgMHhmZmZmLCAm
c2F2ZS0+dHdkKTsKKwlfX3B1dF91c2VyKHRzay0+dGhyZWFkLmZpciwgJnNhdmUtPmZpcCk7CisJ
X19wdXRfdXNlcigodHNrLT50aHJlYWQuZmlyPj4zMikgJiAweGZmZmYsICZzYXZlLT5mY3MpOwor
CV9fcHV0X3VzZXIodHNrLT50aHJlYWQuZmRyLCAmc2F2ZS0+Zm9vKTsKKwlfX3B1dF91c2VyKCh0
c2stPnRocmVhZC5mZHI+PjMyKSAmIDB4ZmZmZiwgJnNhdmUtPmZvcyk7CisKIAkvKgogCSAqICBT
dGFjayBmcmFtZXMgc3RhcnQgd2l0aCAxNi1ieXRlcyBvZiB0ZW1wIHNwYWNlCiAJICovCiAJc3dw
ID0gKHN0cnVjdCBzd2l0Y2hfc3RhY2sgKikodHNrLT50aHJlYWQua3NwICsgMTYpOwogCXB0cCA9
IGlhNjRfdGFza19yZWdzKHRzayk7Ci0JdG9zID0gKHRzay0+dGhyZWFkLmZzciA+PiAxMSkgJiAz
OworCXRvcyA9ICh0c2stPnRocmVhZC5mc3IgPj4gMTEpICYgNzsKIAlmb3IgKGkgPSAwOyBpIDwg
ODsgaSsrKQotCQlwdXRfZnByZWcoaSwgJnNhdmUtPl9zdFtpXSwgcHRwLCBzd3AsIHRvcyk7CisJ
CXB1dF9mcHJlZyhpLCAoc3RydWN0IF9mcHJlZ19pYTMyICopJnNhdmUtPnN0X3NwYWNlWzQqaV0s
IHB0cCwgc3dwLCB0b3MpOworCXJldHVybiAwOworfQorCitzdGF0aWMgaW50CityZXN0b3JlX2lh
MzJfZnBzdGF0ZSAoc3RydWN0IHRhc2tfc3RydWN0ICp0c2ssIHN0cnVjdCBpYTMyX3VzZXJfaTM4
N19zdHJ1Y3QgKnNhdmUpCit7CisJc3RydWN0IHN3aXRjaF9zdGFjayAqc3dwOworCXN0cnVjdCBw
dF9yZWdzICpwdHA7CisJaW50IGksIHRvczsKKwl1bnNpZ25lZCBpbnQgZnNybG8sIGZzcmhpLCBu
dW0zMjsKKworCWlmICghYWNjZXNzX29rKFZFUklGWV9SRUFELCBzYXZlLCBzaXplb2YoKnNhdmUp
KSkKKwkJcmV0dXJuKC1FRkFVTFQpOworCisJX19nZXRfdXNlcihudW0zMiwgKHVuc2lnbmVkIGlu
dCAqKSZzYXZlLT5jd2QpOworCXRzay0+dGhyZWFkLmZjciA9ICh0c2stPnRocmVhZC5mY3IgJiAo
fjB4MWYzZikpIHwgKG51bTMyICYgMHgxZjNmKTsKKwlfX2dldF91c2VyKGZzcmxvLCAodW5zaWdu
ZWQgaW50ICopJnNhdmUtPnN3ZCk7CisJX19nZXRfdXNlcihmc3JoaSwgKHVuc2lnbmVkIGludCAq
KSZzYXZlLT50d2QpOworCW51bTMyID0gKGZzcmhpIDw8IDE2KSB8IGZzcmxvOworCXRzay0+dGhy
ZWFkLmZzciA9ICh0c2stPnRocmVhZC5mc3IgJiAofjB4ZmZmZmZmZmYpKSB8IG51bTMyOworCV9f
Z2V0X3VzZXIobnVtMzIsICh1bnNpZ25lZCBpbnQgKikmc2F2ZS0+ZmlwKTsKKwl0c2stPnRocmVh
ZC5maXIgPSAodHNrLT50aHJlYWQuZmlyICYgKH4weGZmZmZmZmZmKSkgfCBudW0zMjsKKwlfX2dl
dF91c2VyKG51bTMyLCAodW5zaWduZWQgaW50ICopJnNhdmUtPmZvbyk7CisJdHNrLT50aHJlYWQu
ZmRyID0gKHRzay0+dGhyZWFkLmZkciAmICh+MHhmZmZmZmZmZikpIHwgbnVtMzI7CisKKwkvKgor
CSAqICBTdGFjayBmcmFtZXMgc3RhcnQgd2l0aCAxNi1ieXRlcyBvZiB0ZW1wIHNwYWNlCisJICov
CisJc3dwID0gKHN0cnVjdCBzd2l0Y2hfc3RhY2sgKikodHNrLT50aHJlYWQua3NwICsgMTYpOwor
CXB0cCA9IGlhNjRfdGFza19yZWdzKHRzayk7CisJdG9zID0gKHRzay0+dGhyZWFkLmZzciA+PiAx
MSkgJiA3OworCWZvciAoaSA9IDA7IGkgPCA4OyBpKyspCisJCWdldF9mcHJlZyhpLCAoc3RydWN0
IF9mcHJlZ19pYTMyICopJnNhdmUtPnN0X3NwYWNlWzQqaV0sIHB0cCwgc3dwLCB0b3MpOworCXJl
dHVybiAwOworfQorCitzdGF0aWMgaW50CitzYXZlX2lhMzJfZnB4c3RhdGUgKHN0cnVjdCB0YXNr
X3N0cnVjdCAqdHNrLCBzdHJ1Y3QgaWEzMl91c2VyX2Z4c3Jfc3RydWN0ICpzYXZlKQoreworCXN0
cnVjdCBzd2l0Y2hfc3RhY2sgKnN3cDsKKwlzdHJ1Y3QgcHRfcmVncyAqcHRwOworCWludCBpLCB0
b3M7CisJdW5zaWduZWQgbG9uZyBteGNzcj0wOworCXVuc2lnbmVkIGxvbmcgbnVtMTI4WzJdOwor
CisJaWYgKCFhY2Nlc3Nfb2soVkVSSUZZX1dSSVRFLCBzYXZlLCBzaXplb2YoKnNhdmUpKSkKKwkJ
cmV0dXJuIC1FRkFVTFQ7CisKKwlfX3B1dF91c2VyKHRzay0+dGhyZWFkLmZjciAmIDB4ZmZmZiwg
JnNhdmUtPmN3ZCk7CisJX19wdXRfdXNlcih0c2stPnRocmVhZC5mc3IgJiAweGZmZmYsICZzYXZl
LT5zd2QpOworCV9fcHV0X3VzZXIoKHRzay0+dGhyZWFkLmZzcj4+MTYpICYgMHhmZmZmLCAmc2F2
ZS0+dHdkKTsKKwlfX3B1dF91c2VyKHRzay0+dGhyZWFkLmZpciwgJnNhdmUtPmZpcCk7CisJX19w
dXRfdXNlcigodHNrLT50aHJlYWQuZmlyPj4zMikgJiAweGZmZmYsICZzYXZlLT5mY3MpOworCV9f
cHV0X3VzZXIodHNrLT50aHJlYWQuZmRyLCAmc2F2ZS0+Zm9vKTsKKwlfX3B1dF91c2VyKCh0c2st
PnRocmVhZC5mZHI+PjMyKSAmIDB4ZmZmZiwgJnNhdmUtPmZvcyk7CisKKyAgICAgICAgLyoKKyAg
ICAgICAgICogIFN0YWNrIGZyYW1lcyBzdGFydCB3aXRoIDE2LWJ5dGVzIG9mIHRlbXAgc3BhY2UK
KyAgICAgICAgICovCisgICAgICAgIHN3cCA9IChzdHJ1Y3Qgc3dpdGNoX3N0YWNrICopKHRzay0+
dGhyZWFkLmtzcCArIDE2KTsKKyAgICAgICAgcHRwID0gaWE2NF90YXNrX3JlZ3ModHNrKTsKKwl0
b3MgPSAodHNrLT50aHJlYWQuZnNyID4+IDExKSAmIDc7CisgICAgICAgIGZvciAoaSA9IDA7IGkg
PCA4OyBpKyspCisJCXB1dF9mcHJlZyhpLCAoc3RydWN0IF9mcHhyZWdfaWEzMiAqKSZzYXZlLT5z
dF9zcGFjZVs0KmldLCBwdHAsIHN3cCwgdG9zKTsKKworCW14Y3NyID0gKCh0c2stPnRocmVhZC5m
Y3I+PjMyKSAmIDB4ZmY4MCkgfCAoKHRzay0+dGhyZWFkLmZzcj4+MzIpICYgMHgzZik7CisJX19w
dXRfdXNlcihteGNzciAmIDB4ZmZmZiwgJnNhdmUtPm14Y3NyKTsKKwlmb3IgKGkgPSAwOyBpIDwg
ODsgaSsrKSB7CisJCW1lbWNweSgmKG51bTEyOFswXSksICYoc3dwLT5mMTYpICsgaSoyLCBzaXpl
b2YodW5zaWduZWQgbG9uZykpOworCQltZW1jcHkoJihudW0xMjhbMV0pLCAmKHN3cC0+ZjE3KSAr
IGkqMiwgc2l6ZW9mKHVuc2lnbmVkIGxvbmcpKTsKKwkJY29weV90b191c2VyKCZzYXZlLT54bW1f
c3BhY2VbMF0gKyA0KmksIG51bTEyOCwgc2l6ZW9mKHN0cnVjdCBfeG1tcmVnX2lhMzIpKTsKKwl9
CiAJcmV0dXJuIDA7CiB9CiAKIHN0YXRpYyBpbnQKLXJlc3RvcmVfaWEzMl9mcHN0YXRlIChzdHJ1
Y3QgdGFza19zdHJ1Y3QgKnRzaywgc3RydWN0IF9mcHN0YXRlX2lhMzIgKnNhdmUpCityZXN0b3Jl
X2lhMzJfZnB4c3RhdGUgKHN0cnVjdCB0YXNrX3N0cnVjdCAqdHNrLCBzdHJ1Y3QgaWEzMl91c2Vy
X2Z4c3Jfc3RydWN0ICpzYXZlKQogewogCXN0cnVjdCBzd2l0Y2hfc3RhY2sgKnN3cDsKIAlzdHJ1
Y3QgcHRfcmVncyAqcHRwOwotCWludCBpLCB0b3MsIHJldDsKLQlpbnQgZnNybG8sIGZzcmhpOwor
CWludCBpLCB0b3M7CisJdW5zaWduZWQgaW50IGZzcmxvLCBmc3JoaSwgbnVtMzI7CisJaW50IG14
Y3NyOworCXVuc2lnbmVkIGxvbmcgbnVtNjQ7CisJdW5zaWduZWQgbG9uZyBudW0xMjhbMl07CiAK
IAlpZiAoIWFjY2Vzc19vayhWRVJJRllfUkVBRCwgc2F2ZSwgc2l6ZW9mKCpzYXZlKSkpCi0JCXJl
dHVybigtRUlPKTsKLQlyZXQgPSBfX2dldF91c2VyKHRzay0+dGhyZWFkLmZjciwgKHVuc2lnbmVk
IGludCAqKSZzYXZlLT5jdyk7Ci0JcmV0IHw9IF9fZ2V0X3VzZXIoZnNybG8sICh1bnNpZ25lZCBp
bnQgKikmc2F2ZS0+c3cpOwotCXJldCB8PSBfX2dldF91c2VyKGZzcmhpLCAodW5zaWduZWQgaW50
ICopJnNhdmUtPnRhZyk7Ci0JdHNrLT50aHJlYWQuZnNyID0gKChsb25nKWZzcmhpIDw8IDMyKSB8
IChsb25nKWZzcmxvOwotCXJldCB8PSBfX2dldF91c2VyKHRzay0+dGhyZWFkLmZpciwgKHVuc2ln
bmVkIGludCAqKSZzYXZlLT5pcG9mZik7Ci0JcmV0IHw9IF9fZ2V0X3VzZXIodHNrLT50aHJlYWQu
ZmRyLCAodW5zaWduZWQgaW50ICopJnNhdmUtPmRhdGFvZmYpOworCQlyZXR1cm4oLUVGQVVMVCk7
CisKKwlfX2dldF91c2VyKG51bTMyLCAodW5zaWduZWQgaW50ICopJnNhdmUtPmN3ZCk7CisJdHNr
LT50aHJlYWQuZmNyID0gKHRzay0+dGhyZWFkLmZjciAmICh+MHgxZjNmKSkgfCAobnVtMzIgJiAw
eDFmM2YpOworCV9fZ2V0X3VzZXIoZnNybG8sICh1bnNpZ25lZCBpbnQgKikmc2F2ZS0+c3dkKTsK
KwlfX2dldF91c2VyKGZzcmhpLCAodW5zaWduZWQgaW50ICopJnNhdmUtPnR3ZCk7CisJbnVtMzIg
PSAoZnNyaGkgPDwgMTYpIHwgZnNybG87CisJdHNrLT50aHJlYWQuZnNyID0gKHRzay0+dGhyZWFk
LmZzciAmICh+MHhmZmZmZmZmZikpIHwgbnVtMzI7CisJX19nZXRfdXNlcihudW0zMiwgKHVuc2ln
bmVkIGludCAqKSZzYXZlLT5maXApOworCXRzay0+dGhyZWFkLmZpciA9ICh0c2stPnRocmVhZC5m
aXIgJiAofjB4ZmZmZmZmZmYpKSB8IG51bTMyOworCV9fZ2V0X3VzZXIobnVtMzIsICh1bnNpZ25l
ZCBpbnQgKikmc2F2ZS0+Zm9vKTsKKwl0c2stPnRocmVhZC5mZHIgPSAodHNrLT50aHJlYWQuZmRy
ICYgKH4weGZmZmZmZmZmKSkgfCBudW0zMjsKKwogCS8qCiAJICogIFN0YWNrIGZyYW1lcyBzdGFy
dCB3aXRoIDE2LWJ5dGVzIG9mIHRlbXAgc3BhY2UKIAkgKi8KIAlzd3AgPSAoc3RydWN0IHN3aXRj
aF9zdGFjayAqKSh0c2stPnRocmVhZC5rc3AgKyAxNik7CiAJcHRwID0gaWE2NF90YXNrX3JlZ3Mo
dHNrKTsKLQl0b3MgPSAodHNrLT50aHJlYWQuZnNyID4+IDExKSAmIDM7CisJdG9zID0gKHRzay0+
dGhyZWFkLmZzciA+PiAxMSkgJiA3OwogCWZvciAoaSA9IDA7IGkgPCA4OyBpKyspCi0JCWdldF9m
cHJlZyhpLCAmc2F2ZS0+X3N0W2ldLCBwdHAsIHN3cCwgdG9zKTsKLQlyZXR1cm4gcmV0ID8gLUVG
QVVMVCA6IDA7CisJZ2V0X2ZwcmVnKGksIChzdHJ1Y3QgX2ZweHJlZ19pYTMyICopJnNhdmUtPnN0
X3NwYWNlWzQqaV0sIHB0cCwgc3dwLCB0b3MpOworCisJX19nZXRfdXNlcihteGNzciwgKHVuc2ln
bmVkIGludCAqKSZzYXZlLT5teGNzcik7CisJbnVtNjQgPSBteGNzciAmIDB4ZmYxMDsKKwl0c2st
PnRocmVhZC5mY3IgPSAodHNrLT50aHJlYWQuZmNyICYgKH4weGZmMTAwMDAwMDAwMCkpIHwgKG51
bTY0PDwzMik7CisJbnVtNjQgPSBteGNzciAmIDB4M2Y7CisJdHNrLT50aHJlYWQuZnNyID0gKHRz
ay0+dGhyZWFkLmZzciAmICh+MHgzZjAwMDAwMDAwKSkgfCAobnVtNjQ8PDMyKTsKKworCWZvciAo
aSA9IDA7IGkgPCA4OyBpKyspIHsKKwkJY29weV9mcm9tX3VzZXIobnVtMTI4LCAmc2F2ZS0+eG1t
X3NwYWNlWzBdICsgNCppLCBzaXplb2Yoc3RydWN0IF94bW1yZWdfaWEzMikpOworCQltZW1jcHko
Jihzd3AtPmYxNikgKyBpKjIsICYobnVtMTI4WzBdKSwgc2l6ZW9mKHVuc2lnbmVkIGxvbmcpKTsK
KwkJbWVtY3B5KCYoc3dwLT5mMTcpICsgaSoyLCAmKG51bTEyOFsxXSksIHNpemVvZih1bnNpZ25l
ZCBsb25nKSk7CisJfQorCXJldHVybiAwOwogfQogCiBleHRlcm4gYXNtbGlua2FnZSBsb25nIHN5
c19wdHJhY2UgKGxvbmcsIHBpZF90LCB1bnNpZ25lZCBsb25nLCB1bnNpZ25lZCBsb25nLCBsb25n
LCBsb25nLCBsb25nLApAQCAtMzA2MCwxMSArMzE1NSwxOSBAQAogCQlicmVhazsKIAogCSAgICAg
IGNhc2UgSUEzMl9QVFJBQ0VfR0VURlBSRUdTOgotCQlyZXQgPSBzYXZlX2lhMzJfZnBzdGF0ZShj
aGlsZCwgKHN0cnVjdCBfZnBzdGF0ZV9pYTMyICopIEEoZGF0YSkpOworCQlyZXQgPSBzYXZlX2lh
MzJfZnBzdGF0ZShjaGlsZCwgKHN0cnVjdCBpYTMyX3VzZXJfaTM4N19zdHJ1Y3QgKikgQShkYXRh
KSk7CisJCWJyZWFrOworCisJICAgICAgY2FzZSBJQTMyX1BUUkFDRV9HRVRGUFhSRUdTOgorCQly
ZXQgPSBzYXZlX2lhMzJfZnB4c3RhdGUoY2hpbGQsIChzdHJ1Y3QgaWEzMl91c2VyX2Z4c3Jfc3Ry
dWN0ICopIEEoZGF0YSkpOwogCQlicmVhazsKIAogCSAgICAgIGNhc2UgSUEzMl9QVFJBQ0VfU0VU
RlBSRUdTOgotCQlyZXQgPSByZXN0b3JlX2lhMzJfZnBzdGF0ZShjaGlsZCwgKHN0cnVjdCBfZnBz
dGF0ZV9pYTMyICopIEEoZGF0YSkpOworCQlyZXQgPSByZXN0b3JlX2lhMzJfZnBzdGF0ZShjaGls
ZCwgKHN0cnVjdCBpYTMyX3VzZXJfaTM4N19zdHJ1Y3QgKikgQShkYXRhKSk7CisJCWJyZWFrOwor
CisJICAgICAgY2FzZSBJQTMyX1BUUkFDRV9TRVRGUFhSRUdTOgorCQlyZXQgPSByZXN0b3JlX2lh
MzJfZnB4c3RhdGUoY2hpbGQsIChzdHJ1Y3QgaWEzMl91c2VyX2Z4c3Jfc3RydWN0ICopIEEoZGF0
YSkpOwogCQlicmVhazsKIAogCSAgICAgIGNhc2UgUFRSQUNFX1NZU0NBTEw6CS8qIGNvbnRpbnVl
LCBzdG9wIGFmdGVyIG5leHQgc3lzY2FsbCAqLwo=

------_=_NextPart_001_01C29A58.7E5B7E9F--

