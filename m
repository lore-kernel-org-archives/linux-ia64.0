From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 12 Apr 2001 06:31:47 +0000
Subject: [Linux-ia64] small strace fix
Message-Id: <marc-linux-ia64-105590693005394@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi Don,

Attached below is a small fix for strace.  It makes strace work across
inlined system calls.  Actually, you also need a one-line fix to the
kernel for this to really work:

--- arch/ia64/kernel/ivt.S~	Thu Mar 29 13:57:32 2001
+++ arch/ia64/kernel/ivt.S	Wed Apr 11 23:09:07 2001
@@ -702,7 +702,7 @@
 	st8 [r16]=3Dr18				// store new value for cr.isr
=20
 (p8)	br.call.sptk.many b6=B6			// ignore this return addr
-	br.call.sptk.many rp=3Dia64_trace_syscall	// rp will be overwritten (igno=
red)
+	br.cond.sptk.many ia64_trace_syscall
 	// NOT REACHED
 END(break_fault)
=20

	--david

ChangeLog

2001-04-11  David Mosberger  <davidm@hpl.hp.com>

	* syscall.c (syscall_enter): Use PT_RBS_END instead of deprecated
	PT_AR_BSP.  Pick up arguments starting with out0, which is not
	always the same as r32 (e.g., consider inlined syscalls).

Index: syscall.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3DRCS file: /cvsroot/strace/strace/syscall.c,v
retrieving revision 1.25.2.3
diff -u -r1.25.2.3 syscall.c
--- syscall.c	2001/03/07 01:13:25	1.25.2.3
+++ syscall.c	2001/04/12 06:27:57
@@ -1190,21 +1190,26 @@
 	}
 #elif defined (IA64)
 	{
-		unsigned long *bsp, cfm, i;
+		unsigned long *out0, *rbs_end, cfm, sof, sol, i;
+#ifndef PT_RBS_END
+# define PT_RBS_END	PT_AR_BSP	/* be backwards compatible with kernels befo=
re 2.4.4... */
+#endif
=20
-		if (upeek(pid, PT_AR_BSP, (long *) &bsp) < 0)
+		if (upeek(pid, PT_RBS_END, (long *) &rbs_end) < 0)
 			return -1;
 		if (upeek(pid, PT_CFM, (long *) &cfm) < 0)
 			return -1;
=20
-		bsp =3D ia64_rse_skip_regs(bsp, -(cfm & 0x7f));
+		sof =3D (cfm >> 0) & 0x7f;
+		sol =3D (cfm >> 7) & 0x7f;
+		out0 =3D ia64_rse_skip_regs(rbs_end, -sof + sol);
=20
 		if (tcp->scno >=3D 0 && tcp->scno < nsyscalls && sysent[tcp->scno].nargs=
 !=3D -1)
 			tcp->u_nargs =3D sysent[tcp->scno].nargs;
-		else=20
+		else
      	        	tcp->u_nargs =3D MAX_ARGS;
 		for (i =3D 0; i < tcp->u_nargs; ++i) {
-			if (umoven(tcp, (unsigned long) ia64_rse_skip_regs(bsp, i), sizeof(long=
),
+			if (umoven(tcp, (unsigned long) ia64_rse_skip_regs(out0, i), sizeof(lon=
g),
 				   (char *) &tcp->u_arg[i])
 			    < 0)
 				return -1;

