From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 09 Jul 2004 21:03:09 +0000
Subject: Deadly bug in fsys_gettimeofday
Message-Id: <200407092100.i69L0bY17642@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

The order of reading ar.itc is incorrect with respect to all other variables
in fsys_gettimeofday.  All variables involved in time interpolation need to=
 be
protected by the sequence lock xtime_lock for consistency check.  However, =
the
first time that fsys_gettimeofday take a time stamp, it read the count outs=
ide
the seq lock and leading to the following time leap into the future scenari=
o:

fsys_gettimeofday:
	read ar.itc

		.... <went out for lunch > ....

	read_seqbegin
		read all other variables (last_nsec_offset, jiffies, xtime)
		do time interpolation - elapsed_cycles become a large negative
					      number and converting it to nsec overflows
						and make it a large positive number
	read_seqretry success
	updates last_nsec_offset (which is several seconds into the future).

All subsequent gettiemofday will be wrong as well because monotonic property
kicks in.  It only self correct until that future time actually arrives. Th=
is
bug can be trivially demonstrated. I can post a test case if anyone is inte=
rested.


Here is a patch to fix the bug. (moved one instruction to make some room).


--- 1.1/arch/ia64/kernel/fsys.S	Sun May  9 19:33:22 2004
+++ edited/arch/ia64/kernel/fsys.S	Fri Jul  9 13:08:17 2004
@@ -165,7 +165,6 @@
 	add r9=3DTI_FLAGS+IA64_TASK_SIZE,r16
 	addl r3=3DTHIS_CPU(cpu_info),r0

-	mov.m r31=3Dar.itc		// put time stamp into r31 (ITC) =3D now		(35 cyc)
 #ifdef CONFIG_SMP
 	movl r10=3D__per_cpu_offset
 	movl r2=3Dsal_platform_features
@@ -240,12 +239,13 @@
 	;;

 	ldf8 f8=3D[r21]			// f8 now contains itm_next
+	mov.m r31=3Dar.itc		// put time stamp into r31 (ITC) =3D now
 	sub r28=3Dr29, r28, 1		// r28 now contains "-(lost + 1)"
-	tbit.nz p9, p10=3Dr23, 0		// p9 <- is_odd(r23), p10 <- is_even(r23)
 	;;

 	ld8 r2=3D[r19]			// r2 =3D sec =3D xtime.tv_sec
 	ld8 r29=3D[r20]			// r29 =3D nsec =3D xtime.tv_nsec
+	tbit.nz p9, p10=3Dr23, 0		// p9 <- is_odd(r23), p10 <- is_even(r23)

 	setf.sig f6=3Dr28			// f6 <- -(lost + 1)				(6 cyc)
 	;;
@@ -260,7 +260,6 @@
 	nop 0
 	;;

-	mov r31=3Dar.itc			// re-read ITC in case we .retry		(35 cyc)
 	xma.l f8=F11, f8, f12	// f8 (elapsed_cycles) <- (-1*last_tick + now) =3D =
(now - last_tick)
 	nop 0
 	;;



