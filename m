From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 28 Mar 2003 01:06:08 +0000
Subject: [Linux-ia64] IMPORTANT glibc fix
Message-Id: <marc-linux-ia64-105590723705346@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

The patch below was just applied to the CVS glibc.  Since it fixes an
important bug, I'd highly recommend for distributors to also apply the
patch to their currently shipping version of glibc.

	--david

--------------------------------------------------------------------
From: David Mosberger <davidm@linux.hpl.hp.com>
Sender: libc-hacker-owner@sources.redhat.com
To: libc-hacker@sources.redhat.com
Subject: ia64: unat restoration fixes for setjmp() & getcontext()
Date: Thu, 27 Mar 2003 11:40:03 -0800
Reply-To: davidm@hpl.hp.com

The ia64 versions of __sigsetjmp() and getcontext() failed to restore
ar.unat before returning.  Patch below should fix that.

	--david

2003-03-27  David Mosberger  <davidm@hpl.hp.com>

	* sysdeps/unix/sysv/linux/ia64/getcontext.S: Restore caller's
	ar.unat before returning.  Add missing .mem.offset directives
	to ensure file gets assembled without warnings.

	* sysdeps/unix/sysv/linux/ia64/setjmp.S: Ditto.

Index: sysdeps/unix/sysv/linux/ia64/setjmp.S
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3DRCS file: /cvs/glibc/libc/sysdeps/unix/sysv/linux/i=
a64/setjmp.S,v
retrieving revision 1.7 diff -u -r1.7 setjmp.S ---
sysdeps/unix/sysv/linux/ia64/setjmp.S 31 Dec 2002 20:37:30 -0000 1.7
+++ sysdeps/unix/sysv/linux/ia64/setjmp.S 27 Mar 2003 18:05:14 -0000
@@ -87,21 +87,22 @@
 ENTRY(__sigsetjmp)
 	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(2)
 	alloc loc1=3Dar.pfs,2,2,2,0
+	.save ar.unat, r16
 	mov r16=3Dar.unat
 	;;
 	mov r17=3Dar.fpsr
 	mov r2=3Din0
 	add r3=3D8,in0
 	;;
-	st8.spill.nta [r2]=3Dsp,16	// r12 (sp)
-	st8.spill.nta [r3]=3Dgp,16	// r1 (gp)
+.mem.offset 8,0;	st8.spill.nta [r2]=3Dsp,16	// r12 (sp)
+.mem.offset 0,0;	st8.spill.nta [r3]=3Dgp,16	// r1 (gp)
 	;;
 	st8.nta [r2]=3Dr16,16		// save caller's unat
 	st8.nta [r3]=3Dr17,16		// save fpsr
 	add r8=3D0xa0,in0
 	;;
-	st8.spill.nta [r2]=3Dr4,16	// r4
-	st8.spill.nta [r3]=3Dr5,16	// r5
+.mem.offset 8,0;	st8.spill.nta [r2]=3Dr4,16	// r4
+.mem.offset 0,0;	st8.spill.nta [r3]=3Dr5,16	// r5
 	add r9=3D0xb0,in0
 	;;
 	stf.spill.nta [r8]=F2,32
@@ -143,8 +144,8 @@
 	stf.spill.nta [r8]=F30
 	stf.spill.nta [r9]=F31
=20
-	st8.spill.nta [r2]=3Dr6,16	// r6
-	st8.spill.nta [r3]=3Dr7,16	// r7
+.mem.offset 8,0;	st8.spill.nta [r2]=3Dr6,16	// r6
+.mem.offset 0,0;	st8.spill.nta [r3]=3Dr7,16	// r7
 	;;
 	mov r23=3Dar.bsp
 	mov r25=3Dar.unat
@@ -170,9 +171,10 @@
 	st8.nta [r3]=3Din0		// &__jmp_buf
 	br.call.dpnt.few rp=3D__sigjmp_save
 .ret0:					// force a new bundle ::q
-	mov r8=3D0
+	mov.m ar.unat=3Dr16		// restore caller's unat
 	mov rp=3Dloc0
 	mov ar.pfs=3Dloc1
+	mov r8=3D0
 	ret
 END(__sigsetjmp)
=20
Index: sysdeps/unix/sysv/linux/ia64/getcontext.S
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3DRCS file: /cvs/glibc/libc/sysdeps/unix/sysv/linux/i=
a64/getcontext.S,v
retrieving revision 1.6 diff -u -r1.6 getcontext.S ---
sysdeps/unix/sysv/linux/ia64/getcontext.S 9 Oct 2002 09:57:46 -0000
1.6 +++ sysdeps/unix/sysv/linux/ia64/getcontext.S 27 Mar 2003 19:33:04
-0000 @@ -34,6 +34,7 @@
   other than the PRESERVED state.  */
=20
 ENTRY(__getcontext)
+	.prologue
 	alloc r16 =3D ar.pfs, 1, 0, 3, 0
=20
 	// sigprocmask (SIG_BLOCK, NULL, &sc->sc_mask):
@@ -53,7 +54,9 @@
 	add r2 =3D SC_GR+1*8, r32
 	;;
 	mov.m rBSP =3D ar.bsp
+	.save ar.unat, rUNAT
 	mov.m rUNAT =3D ar.unat
+	.body
 	add r3 =3D SC_GR+4*8, r32
 	;;
=20
@@ -65,8 +68,8 @@
 .mem.offset 8,0; st8.spill [r3] =3D r6, 48
 	and rTMP =3D ~0x3, rRSC
 	;;
-	st8.spill [r2] =3D r7, (SC_FR+2*16-(SC_GR+7*8))
-	st8.spill [r3] =3D sp, (SC_FR+3*16-(SC_GR+12*8))
+.mem.offset 0,0; st8.spill [r2] =3D r7, (SC_FR+2*16-(SC_GR+7*8))
+.mem.offset 8,0; st8.spill [r3] =3D sp, (SC_FR+3*16-(SC_GR+12*8))
 	;;
 	mov.m ar.rsc =3D rTMP 		// put RSE into enforced lazy mode
 	mov.m rNAT =3D ar.unat
@@ -119,8 +122,8 @@
 	stf.spill [r3] =3D f31, 32
 	mov rB1 =3D b1
 	;; + mov ar.unat =3D rUNAT // we're done spilling integer regs;
restore caller's UNaT
 	add r2 =3D SC_NAT, r32
-	nop 0
 	add r3 =3D SC_BSP, r32
 	;;
 	st8 [r2] =3D rNAT, (SC_RNAT-SC_NAT)

