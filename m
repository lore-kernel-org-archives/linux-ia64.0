From: Russ Anderson <rja@sgi.com>
Date: Tue, 05 Apr 2005 23:06:37 +0000
Subject: [patch] MCA recovery improvements
Message-Id: <200504052306.j35N6bvW8985157@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Jack Steiner uncovered some opportunities for improvement in
the MCA recovery code.

  1) Set bsp to save registers on the kernel stack.
  2) Disable interrupts while in the MCA recovery code.
  3) Change the way the user process is killed, to avoid=20
     a panic in schedule.

Testing shows that these changes make the recovery code much=20
more reliable with the 2.6.12 kernel.

Signed-off-by: Russ Anderson <rja@sgi.com>

---------------------------------------------------------------------------=
---------
Index: linux/arch/ia64/kernel/mca_drv.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux.orig/arch/ia64/kernel/mca_drv.c	2005-04-0=
1 13:28:21.897191890 -0600
+++ linux/arch/ia64/kernel/mca_drv.c	2005-04-01 13:29:48.547634088 -0600
@@ -132,8 +132,7 @@
 	spin_unlock(&mca_bh_lock);
=20
 	/* This process is about to be killed itself */
-	force_sig(SIGKILL, current);
-	schedule();
+	do_exit(SIGKILL);
 }
=20
 /**
@@ -439,6 +438,7 @@
 			psr2 =3D (struct ia64_psr *)&pmsa->pmsa_ipsr;
 			psr2->cpl =3D 0;
 			psr2->ri  =3D 0;
+			psr2->i  =3D 0;
=20
 			return 1;
 		}
Index: linux/arch/ia64/kernel/mca_drv_asm.S
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux.orig/arch/ia64/kernel/mca_drv_asm.S	2005-=
04-01 13:28:15.696086223 -0600
+++ linux/arch/ia64/kernel/mca_drv_asm.S	2005-04-01 14:31:24.275077908 -0600
@@ -10,6 +10,7 @@
=20
 #include <asm/asmmacro.h>
 #include <asm/processor.h>
+#include <asm/ptrace.h>
=20
 GLOBAL_ENTRY(mca_handler_bhhook)
 	invala						// clear RSE ?
@@ -20,12 +21,21 @@
 	;;					=09
 	alloc		r16=3Dar.pfs,0,2,1,0		// make a new frame
 	;;
+	mov		ar.rsc=3D0
+	;;
 	mov		r13=3DIA64_KR(CURRENT)		// current task pointer
 	;;
-	adds		r12=3DIA64_TASK_THREAD_KSP_OFFSET,r13
+	mov		r2=3Dr13
+	;;
+	addl		r22=3DIA64_RBS_OFFSET,r2
+	;;
+	mov		ar.bspstore=3Dr22
 	;;
-	ld8		r12=3D[r12]			// stack pointer
+	addl		sp=3DIA64_STK_OFFSET-IA64_PT_REGS_SIZE,r2
 	;;
+	adds		r2=3DIA64_TASK_THREAD_ON_USTACK_OFFSET,r13
+	;;
+	st1		[r2]=3Dr0				// clear current->thread.on_ustack flag
 	mov		loc0=3Dr16
 	movl		loc1=3Dmca_handler_bh		// recovery C function
 	;;
@@ -34,7 +44,9 @@
 	;;
 	mov		loc1=3Drp
 	;;
-	br.call.sptk.many    rp=B6			// not return ...
+	ssm		psr.i
+	;;
+	br.call.sptk.many    rp=B6			// does not return ...
 	;;
 	mov		ar.pfs=3Dloc0
 	mov 		rp=3Dloc1
---------------------------------------------------------------------------=
---------
--=20
Russ Anderson, OS RAS/Partitioning Project Lead =20
SGI - Silicon Graphics Inc          rja@sgi.com
