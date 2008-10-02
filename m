From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 02 Oct 2008 20:59:55 +0000
Subject: RE: [patch 2/4] ia64 use trace hook
Message-Id: <200810022059.m92Kxt1J011299@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080917082022.191956457@sli10-desk.sh.intel.com>
In-Reply-To: <20080917082022.191956457@sli10-desk.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

>      Note that the calling arch code should handle the return value from
>      tracehook_report_syscall_entry(), which is behavior that was not
>      required for the old ptrace support. This needs to implement some
>      form of safe abort of the syscall. See the kerneldoc comments for the
>      exact details.

I think this patch meets this requirement.  The 2.6.27 version of
tracehook_report_syscall_entry() always returns 0 ... so the error
code paths are untested.

-Tony

---

diff --git a/arch/ia64/ia32/ia32_entry.S b/arch/ia64/ia32/ia32_entry.S
index 1fabfb7..a73ec00 100644
--- a/arch/ia64/ia32/ia32_entry.S
+++ b/arch/ia64/ia32/ia32_entry.S
@@ -108,6 +108,11 @@ GLOBAL_ENTRY(ia32_trace_syscall)
 	;;
 	st8 [r2]=3Dr3				// initialize return code to -ENOSYS
 	br.call.sptk.few rp=3Dsyscall_trace_enter	// give parent a chance to catc=
h syscall args
+	cmp.lt p6,p0=3Dr8,r0			// check tracehook
+	adds r2=3DIA64_PT_REGS_R8_OFFSET+16,sp	// r2 =3D &pt_regs.r8
+	;;
+(p6)	st8.spill [r2]=3Dr8			// store return value in slot for r8
+(p6)	br.spnt.few .ret4
 .ret2:	// Need to reload arguments (they may be changed by the tracing pro=
cess)
 	adds r2=3DIA64_PT_REGS_R1_OFFSET+16,sp	// r2 =3D &pt_regs.r1
 	adds r3=3DIA64_PT_REGS_R13_OFFSET+16,sp	// r3 =3D &pt_regs.r13
diff --git a/arch/ia64/kernel/entry.S b/arch/ia64/kernel/entry.S
index 0dd6c14..7ef0c59 100644
--- a/arch/ia64/kernel/entry.S
+++ b/arch/ia64/kernel/entry.S
@@ -534,6 +534,11 @@ GLOBAL_ENTRY(ia64_trace_syscall)
  	stf.spill [r16]=F10
  	stf.spill [r17]=F11
 	br.call.sptk.many rp=3Dsyscall_trace_enter // give parent a chance to cat=
ch syscall args
+	cmp.lt p6,p0=3Dr8,r0			// check tracehook
+	adds r2=3DPT(R8)+16,sp			// r2 =3D &pt_regs.r8
+	adds r3=3DPT(R10)+16,sp			// r3 =3D &pt_regs.r10
+	mov r10=3D0
+(p6)	br.cond.sptk strace_error		// syscall failed ->
 	adds r16=3DPT(F6)+16,sp
 	adds r17=3DPT(F7)+16,sp
 	;;
diff --git a/arch/ia64/kernel/ptrace.c b/arch/ia64/kernel/ptrace.c
index 475bfe1..ba72f15 100644
--- a/arch/ia64/kernel/ptrace.c
+++ b/arch/ia64/kernel/ptrace.c
@@ -1234,13 +1234,14 @@ arch_ptrace (struct task_struct *child, long reques=
t, long addr, long data)
=20
 /* "asmlinkage" so the input arguments are preserved... */
=20
-asmlinkage void
+asmlinkage int
 syscall_trace_enter (long arg0, long arg1, long arg2, long arg3,
 		     long arg4, long arg5, long arg6, long arg7,
 		     struct pt_regs regs)
 {
 	if (test_thread_flag(TIF_SYSCALL_TRACE))
-		tracehook_report_syscall_entry(&regs);
+		if (tracehook_report_syscall_entry(&regs))
+			return -ENOSYS;
=20
 	/* copy user rbs to kernel rbs */
 	if (test_thread_flag(TIF_RESTORE_RSE))
@@ -1261,6 +1262,7 @@ syscall_trace_enter (long arg0, long arg1, long arg2,=
 long arg3,
 		audit_syscall_entry(arch, syscall, arg0, arg1, arg2, arg3);
 	}
=20
+	return 0;
 }
=20
 /* "asmlinkage" so the input arguments are preserved... */
