From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 16 Oct 2001 15:54:08 +0000
Subject: [Linux-ia64] [patch] fix unaligned references inside s/w pipelined loops
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_000_01C1565A.CA1C4420"
Message-Id: <marc-linux-ia64-105590698805353@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This message is in MIME format. Since your mail reader does not understand
this format, some or all of this message may not be legible.

------_=_NextPart_000_01C1565A.CA1C4420
Content-Type: text/plain;
	charset="ISO-8859-1"

If an application takes an unaligned trap on a "rotating"
register inside a software pipelined loop[1], then the kernel
will use the wrong register when it fixes the fault.  This
results in corrupted memory or register depending on whether
the unaligned reference was a store or a load respectively.

Attached is a patch to fix this (both for the integer case,
which was the one actually reported to me, and the floating
point case too).  Patch is against 2.4.10.

-Tony Luck

[1] Don't ask me why someone would go through all the effort
of writing a s/w pipelined loop, but not check for unaligned
access, I don't understand it either ... but they did.


------_=_NextPart_000_01C1565A.CA1C4420
Content-Type: text/plain;
	name="diff.unaligned.txt"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="diff.unaligned.txt"

--- ../../REF/2.4.10-ia64-combo/arch/ia64/kernel/unaligned.c	Wed Oct  3 =
11:02:18 2001=0A=
+++ linux/arch/ia64/kernel/unaligned.c	Thu Oct 11 09:00:54 2001=0A=
@@ -5,6 +5,7 @@=0A=
  * Copyright (C) 1999-2000 Stephane Eranian <eranian@hpl.hp.com>=0A=
  * Copyright (C) 2001 David Mosberger-Tang <davidm@hpl.hp.com>=0A=
  *=0A=
+ * 2001/10/11	Fix unaligned access to rotating registers in s/w =
pipelined loops.=0A=
  * 2001/08/13	Correct size of extended floats (float_fsz) from 16 to =
10 bytes.=0A=
  * 2001/01/17	Add support emulation of unaligned kernel accesses.=0A=
  */=0A=
@@ -283,9 +284,19 @@=0A=
 	unsigned long rnats, nat_mask;=0A=
 	unsigned long on_kbs;=0A=
 	long sof =3D (regs->cr_ifs) & 0x7f;=0A=
+	long sor =3D 8 * ((regs->cr_ifs >> 14) & 0xf);=0A=
+	long rrb_gr =3D (regs->cr_ifs >> 18) & 0x7f;=0A=
+	long ridx;=0A=
+=0A=
+	if ((r1 - 32) > sor)=0A=
+		ridx =3D -sof + (r1 - 32);=0A=
+	else if ((r1 - 32) < (sor - rrb_gr))=0A=
+		ridx =3D -sof + (r1 - 32) + rrb_gr;=0A=
+	else=0A=
+		ridx =3D -sof + (r1 - 32) - (sor - rrb_gr);=0A=
 =0A=
-	DPRINT("r%lu, sw.bspstore=3D%lx pt.bspstore=3D%lx sof=3D%ld =
sol=3D%ld\n",=0A=
-	       r1, sw->ar_bspstore, regs->ar_bspstore, sof, (regs->cr_ifs >> =
7) & 0x7f);=0A=
+	DPRINT("r%lu, sw.bspstore=3D%lx pt.bspstore=3D%lx sof=3D%ld sol=3D%ld =
ridx=3D%ld\n",=0A=
+	       r1, sw->ar_bspstore, regs->ar_bspstore, sof, (regs->cr_ifs >> =
7) & 0x7f, ridx);=0A=
 =0A=
 	if ((r1 - 32) >=3D sof) {=0A=
 		/* this should never happen, as the "rsvd register fault" has higher =
priority */=0A=
@@ -294,7 +305,7 @@=0A=
 	}=0A=
 =0A=
 	on_kbs =3D ia64_rse_num_regs(kbs, (unsigned long *) =
sw->ar_bspstore);=0A=
-	addr =3D ia64_rse_skip_regs((unsigned long *) sw->ar_bspstore, -sof + =
(r1 - 32));=0A=
+	addr =3D ia64_rse_skip_regs((unsigned long *) sw->ar_bspstore, =
ridx);=0A=
 	if (addr >=3D kbs) {=0A=
 		/* the register is on the kernel backing store: easy... */=0A=
 		rnat_addr =3D ia64_rse_rnat_addr(addr);=0A=
@@ -319,12 +330,12 @@=0A=
 		return;=0A=
 	}=0A=
 =0A=
-	bspstore =3D (unsigned long *) regs->ar_bspstore;=0A=
+	bspstore =3D (unsigned long *)regs->ar_bspstore;=0A=
 	ubs_end =3D ia64_rse_skip_regs(bspstore, on_kbs);=0A=
 	bsp     =3D ia64_rse_skip_regs(ubs_end, -sof);=0A=
-	addr    =3D ia64_rse_skip_regs(bsp, r1 - 32);=0A=
+	addr    =3D ia64_rse_skip_regs(bsp, ridx + sof);=0A=
 =0A=
-	DPRINT("ubs_end=3D%p bsp=3D%p addr=3D%px\n", (void *) ubs_end, (void =
*) bsp, (void *) addr);=0A=
+	DPRINT("ubs_end=3D%p bsp=3D%p addr=3D%p\n", (void *) ubs_end, (void =
*) bsp, (void *) addr);=0A=
 =0A=
 	ia64_poke(current, sw, (unsigned long) ubs_end, (unsigned long) addr, =
val);=0A=
 =0A=
@@ -354,9 +365,19 @@=0A=
 	unsigned long rnats, nat_mask;=0A=
 	unsigned long on_kbs;=0A=
 	long sof =3D (regs->cr_ifs) & 0x7f;=0A=
+	long sor =3D 8 * ((regs->cr_ifs >> 14) & 0xf);=0A=
+	long rrb_gr =3D (regs->cr_ifs >> 18) & 0x7f;=0A=
+	long ridx;=0A=
+=0A=
+	if ((r1 - 32) > sor)=0A=
+		ridx =3D -sof + (r1 - 32);=0A=
+	else if ((r1 - 32) < (sor - rrb_gr))=0A=
+		ridx =3D -sof + (r1 - 32) + rrb_gr;=0A=
+	else=0A=
+		ridx =3D -sof + (r1 - 32) - (sor - rrb_gr);=0A=
 =0A=
-	DPRINT("r%lu, sw.bspstore=3D%lx pt.bspstore=3D%lx sof=3D%ld =
sol=3D%ld\n",=0A=
-	       r1, sw->ar_bspstore, regs->ar_bspstore, sof, (regs->cr_ifs >> =
7) & 0x7f);=0A=
+	DPRINT("r%lu, sw.bspstore=3D%lx pt.bspstore=3D%lx sof=3D%ld sol=3D%ld =
ridx=3D%ld\n",=0A=
+	       r1, sw->ar_bspstore, regs->ar_bspstore, sof, (regs->cr_ifs >> =
7) & 0x7f, ridx);=0A=
 =0A=
 	if ((r1 - 32) >=3D sof) {=0A=
 		/* this should never happen, as the "rsvd register fault" has higher =
priority */=0A=
@@ -365,7 +386,7 @@=0A=
 	}=0A=
 =0A=
 	on_kbs =3D ia64_rse_num_regs(kbs, (unsigned long *) =
sw->ar_bspstore);=0A=
-	addr =3D ia64_rse_skip_regs((unsigned long *) sw->ar_bspstore, -sof + =
(r1 - 32));=0A=
+	addr =3D ia64_rse_skip_regs((unsigned long *) sw->ar_bspstore, =
ridx);=0A=
 	if (addr >=3D kbs) {=0A=
 		/* the register is on the kernel backing store: easy... */=0A=
 		*val =3D *addr;=0A=
@@ -391,7 +412,7 @@=0A=
 	bspstore =3D (unsigned long *)regs->ar_bspstore;=0A=
 	ubs_end =3D ia64_rse_skip_regs(bspstore, on_kbs);=0A=
 	bsp     =3D ia64_rse_skip_regs(ubs_end, -sof);=0A=
-	addr    =3D ia64_rse_skip_regs(bsp, r1 - 32);=0A=
+	addr    =3D ia64_rse_skip_regs(bsp, ridx + sof);=0A=
 =0A=
 	DPRINT("ubs_end=3D%p bsp=3D%p addr=3D%p\n", (void *) ubs_end, (void =
*) bsp, (void *) addr);=0A=
 =0A=

------_=_NextPart_000_01C1565A.CA1C4420--

