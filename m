From: Zou Nan hai <nanhai.zou@intel.com>
Date: Tue, 25 Jul 2006 23:26:51 +0000
Subject: [Patch] Do not assume output registers be reservered.
Message-Id: <1153870011.3286.62.camel@linux-znh>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

We found an issue in pal.S.

According to the software runtime SPEC,=20
The caller's output registers do not need to be preserved for=20
caller. The callee may reuse input registers for any other=20
purpose within the procedure.

in ia64_pal_call_phys_stacked,

input registers are copied to output registers before call=20
into ia64_switch_mode_phys, then used to call into PAL. This=20
assumes output registers are preserved in ia64_switch_mode_phys,
which may not be true.

In this particular case, ia64_switch_mode_phys alloc a null frame=20
, and mask off psr.i.
If an interrupt comes at this small window,=20
or an MCA comes inside the procedure, output registers=20
maybe changed,=20
then the pal call may got some staled input registers.
=20
This patch moves the copies from input to output=20
after ia64_switch_mode_phys to follow the software=20
runtime convention.

It  also removed some unused labels in=20
ia64_pal_call_phys_stacked.

Signed-off-by: Zou Nan hai <nanhai.zou@intel.com>

--- linux-2.6.18-rc2/arch/ia64/kernel/pal.S	2006-07-26 11:59:06.000000000 +=
0800
+++ linux-2.6.18-rc2-fix/arch/ia64/kernel/pal.S	2006-07-26 12:04:18.0000000=
00 +0800
@@ -217,12 +217,7 @@ GLOBAL_ENTRY(ia64_pal_call_phys_stacked)
 	.body
 	;;
 	ld8 loc2 =3D [loc2]		// loc2 <- entry point
-	mov out0 =3D in0		// first argument
-	mov out1 =3D in1		// copy arg2
-	mov out2 =3D in2		// copy arg3
-	mov out3 =3D in3		// copy arg3
-	;;
-	mov loc3 =3D psr		// save psr
+	mov loc3 =3D psr			// save psr
 	;;
 	mov loc4=3Dar.rsc			// save RSE configuration
 	dep.z loc2=3Dloc2,0,61		// convert pal entry point to physical
@@ -236,18 +231,23 @@ GLOBAL_ENTRY(ia64_pal_call_phys_stacked)
 	;;
 	andcm r16=3Dloc3,r16		// removes bits to clear from psr
 	br.call.sptk.many rp=3Dia64_switch_mode_phys
-.ret6:
+
+	mov out0 =3D in0			// first argument
+	mov out1 =3D in1			// copy arg2
+	mov out2 =3D in2			// copy arg3
+	mov out3 =3D in3			// copy arg3
 	mov loc5 =3D r19
 	mov loc6 =3D r20
+
 	br.call.sptk.many rp=B7		// now make the call
-.ret7:
+
 	mov ar.rsc=3D0			// put RSE in enforced lazy, LE mode
 	mov r16=3Dloc3			// r16=3D original psr
 	mov r19=3Dloc5
 	mov r20=3Dloc6
 	br.call.sptk.many rp=3Dia64_switch_mode_virt	// return to virtual mode
=20
-.ret8:	mov psr.l  =3D loc3		// restore init PSR
+	mov psr.l  =3D loc3		// restore init PSR
 	mov ar.pfs =3D loc1
 	mov rp =3D loc0
 	;;




