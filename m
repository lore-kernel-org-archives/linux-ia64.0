From: "Pallipadi, Venkatesh" <venkatesh.pallipadi@intel.com>
Date: Wed, 16 Oct 2002 01:26:21 +0000
Subject: [Linux-ia64] [PATCH] Clearing of exception status before calling IA32 user sig
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_000_01C274B3.08869180"
Message-Id: <marc-linux-ia64-105590709805168@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This message is in MIME format. Since your mail reader does not understand
this format, some or all of this message may not be legible.

------_=_NextPart_000_01C274B3.08869180
Content-Type: text/plain;
	charset="iso-8859-1"


Hi,

   One more bug fix for IA32 exception handler. IA32 exception handler is
not clearing the exception status, before calling the user signal handler
routine. The issue was first observed due to an IA32 binary (which runs fine
on IA32 system), failing on Itanium based system. The binary was trying to
do an "finit" in the user SIGFPE handler. As the exception state was not
cleared before calling the user signal handler, the finit there was failing,
due to the pending exception.

   The attached patch fixes the issue. [Note: Applies over <base> + <IA32
fpstate Save/Restore patch which was sent previously>.]

   Please let me know, if you need any more information on this.

Thanks,
-Venkatesh

--- ia64-fpe/arch/ia64/ia32/ia32_signal.c.org2	Mon Oct 14 19:10:48 2002
+++ ia64-fpe/arch/ia64/ia32/ia32_signal.c	Tue Oct 15 16:16:23 2002
@@ -219,6 +219,7 @@
 	struct _fpreg_ia32 *fpregp;
 	char buf[32];
 	unsigned long fsr, fcr, fir, fdr;
+	unsigned long new_fsr;
 	unsigned long num128[2];
 	unsigned long mxcsr=0;
 	int fp_tos, fr8_st_map;
@@ -231,6 +232,13 @@
 	asm volatile ( "mov %0=ar.fcr;" : "=r"(fcr));
 	asm volatile ( "mov %0=ar.fir;" : "=r"(fir));
 	asm volatile ( "mov %0=ar.fdr;" : "=r"(fdr));
+	/*
+	 * We need to clear the exception state before calling the signal
+	 * handler. Clear the bits 15, bits 0-7 in fp status word. Similar
+	 * to the functionality of fnclex instruction.
+	 */ 
+	new_fsr = fsr & (~0x80ff) ;
+	asm volatile ( "mov ar.fsr=%0;" :: "r"(new_fsr));
 
 	__put_user(fcr & 0xffff, &save->cw);
 	__put_user(fsr & 0xffff, &save->sw);
 <<fpe.2418_finit.patch>> 

------_=_NextPart_000_01C274B3.08869180
Content-Type: application/octet-stream;
	name="fpe.2418_finit.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="fpe.2418_finit.patch"

--- ia64-fpe/arch/ia64/ia32/ia32_signal.c.org2	Mon Oct 14 19:10:48 =
2002=0A=
+++ ia64-fpe/arch/ia64/ia32/ia32_signal.c	Tue Oct 15 16:16:23 2002=0A=
@@ -219,6 +219,7 @@=0A=
 	struct _fpreg_ia32 *fpregp;=0A=
 	char buf[32];=0A=
 	unsigned long fsr, fcr, fir, fdr;=0A=
+	unsigned long new_fsr;=0A=
 	unsigned long num128[2];=0A=
 	unsigned long mxcsr=3D0;=0A=
 	int fp_tos, fr8_st_map;=0A=
@@ -231,6 +232,13 @@=0A=
 	asm volatile ( "mov %0=3Dar.fcr;" : "=3Dr"(fcr));=0A=
 	asm volatile ( "mov %0=3Dar.fir;" : "=3Dr"(fir));=0A=
 	asm volatile ( "mov %0=3Dar.fdr;" : "=3Dr"(fdr));=0A=
+	/*=0A=
+	 * We need to clear the exception state before calling the signal=0A=
+	 * handler. Clear the bits 15, bits 0-7 in fp status word. Similar=0A=
+	 * to the functionality of fnclex instruction.=0A=
+	 */ =0A=
+	new_fsr =3D fsr & (~0x80ff) ;=0A=
+	asm volatile ( "mov ar.fsr=3D%0;" :: "r"(new_fsr));=0A=
 =0A=
 	__put_user(fcr & 0xffff, &save->cw);=0A=
 	__put_user(fsr & 0xffff, &save->sw);=0A=

------_=_NextPart_000_01C274B3.08869180--

