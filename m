From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 09 Mar 2005 21:35:14 +0000
Subject: [patch] speed up syscall path a bit more
Message-Id: <200503092135.j29LZE0w029863@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Recently I noticed that clearing ar.ssd/ar.csd right before srlz.d is
causing significant stalling in the syscall path.  The patch below
fixes that by moving the register-writes after srlz.d.  On a Madison,
this drops break-based getpid() from 241 to 226 cycles (-15 cycles).

	--david

Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>

=3D=3D=3D arch/ia64/kernel/entry.S 1.80 vs edited =3D=3D--- 1.80/arch/ia64/=
kernel/entry.S	2005-01-28 16:37:04 -08:00
+++ edited/arch/ia64/kernel/entry.S	2005-03-08 13:07:35 -08:00
@@ -728,12 +728,8 @@
 	mov f8=F0		// clear f8
 	;;
 	ld8 r30=3D[r2],16		// M0|1 load cr.ifs
-	mov.m ar.ssd=3Dr0		// M2 clear ar.ssd
-	cmp.eq p9,p0=3Dr0,r0	// set p9 to indicate that we should restore cr.ifs
-	;;
 	ld8 r25=3D[r3],16		// M0|1 load ar.unat
-	mov.m ar.csd=3Dr0		// M2 clear ar.csd
-	mov r22=3Dr0		// clear r22
+	cmp.eq p9,p0=3Dr0,r0	// set p9 to indicate that we should restore cr.ifs
 	;;
 	ld8 r26=3D[r2],PT(B0)-PT(AR_PFS)	// M0|1 load ar.pfs
 (pKStk)	mov r22=3Dpsr		// M2 read PSR now that interrupts are disabled
@@ -756,11 +752,15 @@
 	mov f7=F0		// clear f7
 	;;
 	ld8.fill r12=3D[r2]	// restore r12 (sp)
+	mov.m ar.ssd=3Dr0		// M2 clear ar.ssd
+	mov r22=3Dr0		// clear r22
+
 	ld8.fill r15=3D[r3]	// restore r15
+(pUStk) st1 [r14]=3Dr17
 	addl r3=3DTHIS_CPU(ia64_phys_stacked_size_p8),r0
 	;;
 (pUStk)	ld4 r3=3D[r3]		// r3 =3D cpu_data->phys_stacked_size_p8
-(pUStk) st1 [r14]=3Dr17
+	mov.m ar.csd=3Dr0		// M2 clear ar.csd
 	mov b6=3Dr18		// I0  restore b6
 	;;
 	mov r14=3Dr0		// clear r14
