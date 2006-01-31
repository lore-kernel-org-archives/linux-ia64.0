From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Tue, 31 Jan 2006 09:06:58 +0000
Subject: [patch 1/6] remove dead code in ia64_leave_kernel
Message-Id: <200601310907.k0V976g12698@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

The code around restoring user backing store in ia64_leave_kernel
is just plain dumb.  ia64_leave_kernel is used for non-syscall
exit path.  When entering the kernel from the user space, we
already preserved the user stack register frame by doing a
cover instruction.  on the way out, ia64_leave_kernel uncondition-
ally bypass a section of code by "br dont_preserve_current_frame"
(pNonSys should always be one in that path).  However, part of
code in the beginning of rbs_switch is used by ia64_leave_syscall
to calculate new "ndirty" bytes since in leave syscall, kernel
have to preserve the current frame and thus needing to re
calculate new ndirty size for loadrs.  Streamline that section of
code into ia64_leave_syscall and remove unneeded reading ar.bsp
in the leave kernel path.

Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>

--- ./arch/ia64/kernel/entry.S.orig	2006-01-02 19:21:10.000000000 -0800
+++ ./arch/ia64/kernel/entry.S	2006-01-22 02:20:46.475278554 -0800
@@ -787,6 +787,13 @@ ENTRY(ia64_leave_syscall)
=20
 	mov.m ar.ssd=3Dr0			// M2   clear ar.ssd
 	mov f11=F0			// F    clear f11
+	sub r16=3Dr16,r18			// krbs =3D old bsp - size of dirty partition
+	cmp.ne p9,p0=3Dr0,r0		// clear p9 to skip restore of cr.ifs
+	;;
+	sub r19=3Dr19,r16			// calculate total byte size of dirty partition
+	add r18d,r18			// don't force in0-in7 into memory...
+	;;
+	shl r19=3Dr19,16			// shift size of dirty partition into loadrs pos
 	br.cond.sptk.many rbs_switch	// B
 END(ia64_leave_syscall)
=20
@@ -951,32 +958,17 @@ GLOBAL_ENTRY(ia64_leave_kernel)
 (pUStk)	st1 [r18]=3Dr17		// restore current->thread.on_ustack
 	shr.u r18=3Dr19,16	// get byte size of existing "dirty" partition
 	;;
-	mov r16=3Dar.bsp		// get existing backing store pointer
 	addl r17=3DTHIS_CPU(ia64_phys_stacked_size_p8),r0
 	;;
 	ld4 r17=3D[r17]		// r17 =3D cpu_data->phys_stacked_size_p8
 (pKStk)	br.cond.dpnt skip_rbs_switch
=20
+rbs_switch:
 	/*
 	 * Restore user backing store.
 	 *
 	 * NOTE: alloc, loadrs, and cover can't be predicated.
-	 */
-(pNonSys) br.cond.dpnt dont_preserve_current_frame
-	cover				// add current frame into dirty partition and set cr.ifs
-	;;
-	mov r19=3Dar.bsp			// get new backing store pointer
-rbs_switch:
-	sub r16=3Dr16,r18			// krbs =3D old bsp - size of dirty partition
-	cmp.ne p9,p0=3Dr0,r0		// clear p9 to skip restore of cr.ifs
-	;;
-	sub r19=3Dr19,r16			// calculate total byte size of dirty partition
-	add r18d,r18			// don't force in0-in7 into memory...
-	;;
-	shl r19=3Dr19,16			// shift size of dirty partition into loadrs position
-	;;
-dont_preserve_current_frame:
-	/*
+	 *
 	 * To prevent leaking bits between the kernel and user-space,
 	 * we must clear the stacked registers in the "invalid" partition here.
 	 * Not pretty, but at least it's fast (3.34 registers/cycle on Itanium,


