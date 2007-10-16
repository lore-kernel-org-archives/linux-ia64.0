From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Tue, 16 Oct 2007 13:40:11 +0000
Subject: [PATCH 7/9] ia64: VIRT_CPU_ACCOUNTING (accurate cpu time accounting)
Message-Id: <4714BF3B.8060507@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

> [7/9] ia64_acct_gate_on_entry.patch

On ia64, there are multiple ways to enter kernel.
These entrances are listed in arch/ia64/kernel/ivt.S.

Some of these, kind of fault handlers, are too short
(since it is a family of bank0 interrupts), so it will
return to user (or previous state in kernel) soon.
I'm not sure how often such faults will happen, but
it seems bad idea to make check points for each faults,
not only because it will impact performance directly,
but also because of limited resources/registers.

Thus I give up gathering time in faults (maybe negligible),
and reduce the building points to where the thread changes
the stack from user stack to kernel stack.

Now, next building point is

 - kernel entrance (stack switching from user to kernel)

This switching events are located in:

 - macro SAVE_MIN
 - system_call (break)
 - fast-system call (at fsys.S)

Following patch builds check points in these, including
fetching ar.itc, cumulate the diff for utime, and update
stamp indicating when this thread comes to the point.

Thanks,
H.Seto

Signed-off-by: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>

---
 arch/ia64/kernel/entry.h    |    9 +++++++++
 arch/ia64/kernel/fsys.S     |   16 ++++++++++++++++
 arch/ia64/kernel/ivt.S      |   21 +++++++++++++++++++++
 arch/ia64/kernel/minstate.h |    1 +
 4 files changed, 47 insertions(+)

Index: linux-2.6.23/arch/ia64/kernel/entry.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.23.orig/arch/ia64/kernel/entry.h
+++ linux-2.6.23/arch/ia64/kernel/entry.h
@@ -80,3 +80,12 @@
 	br.cond.sptk.many load_switch_stack;	\
 1:	.restore sp;				\
 	adds sp=3DIA64_SWITCH_STACK_SIZE,sp
+
+#ifdef CONFIG_VIRT_CPU_ACCOUNTING
+/* r13 =3D current, and now going to leave bank 0 */
+#define ACCOUNT_SYS_ENTER				\
+(pUStk)	br.call.spnt.many rp=ACcount_sys_enter;		\
+	;;
+#else
+#define ACCOUNT_SYS_ENTER
+#endif
Index: linux-2.6.23/arch/ia64/kernel/minstate.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.23.orig/arch/ia64/kernel/minstate.h
+++ linux-2.6.23/arch/ia64/kernel/minstate.h
@@ -127,6 +127,7 @@
 	EXTRA;											\
 	movl r1=3D__gp;		/* establish kernel global pointer */				\
 	;;											\
+	ACCOUNT_SYS_ENTER											\
 	bsw.1;			/* switch back to bank 1 (must be last in insn group) */	\
 	;;

Index: linux-2.6.23/arch/ia64/kernel/ivt.S
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.23.orig/arch/ia64/kernel/ivt.S
+++ linux-2.6.23/arch/ia64/kernel/ivt.S
@@ -829,6 +829,7 @@
 	cmp.eq p14,p0=3Dr9,r0			// A    are syscalls being traced/audited?
 	br.call.sptk.many b7=3Dia64_syscall_setup	// B
 1:
+	ACCOUNT_SYS_ENTER
 	mov ar.rsc=3D0x3				// M2   set eager mode, pl 0, LE, loadrs=3D0
 	nop 0
 	bsw.1					// B (6 cyc) regs are saved, switch to bank 1
@@ -1090,6 +1091,26 @@
 	DBG_FAULT(16)
 	FAULT(16)

+#ifdef CONFIG_VIRT_CPU_ACCOUNTING
+ENTRY(account_sys_enter)
+	mov r20=3Dar.itc
+	add r16=3DTI_AC_STAMP+IA64_TASK_SIZE,r13
+	add r17=3DTI_AC_UTIME+IA64_TASK_SIZE,r13
+	;;
+	ld8 r18=3D[r16]			// get last stamp
+	ld8 r19=3D[r17]			// cumulated utime
+	;;
+	sub r18=3Dr20,r18			// elapsed time
+	;;
+	add r19=3Dr19,r18			// sum
+	;;
+	st8 [r16]=3Dr20			// update stamp
+	st8 [r17]=3Dr19			// update utime
+        ;;
+	br.ret.sptk.many rp
+END(account_sys_enter)
+#endif
+
 	.org ia64_ivt+0x4400
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x4400 Entry 17 (size 64 bundles) Reserved
Index: linux-2.6.23/arch/ia64/kernel/fsys.S
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.23.orig/arch/ia64/kernel/fsys.S
+++ linux-2.6.23/arch/ia64/kernel/fsys.S
@@ -682,6 +682,22 @@
 	cmp.ne pKStk,pUStk=3Dr0,r0		// A    set pKStk <- 0, pUStk <- 1
 	br.call.sptk.many b7=3Dia64_syscall_setup	// B
 	;;
+#ifdef CONFIG_VIRT_CPU_ACCOUNTING
+	mov r20=3Dar.itc
+	add r16=3DTI_AC_STAMP+IA64_TASK_SIZE,r2
+	add r17=3DTI_AC_UTIME+IA64_TASK_SIZE,r2
+	;;
+	ld8 r18=3D[r16]			// get last stamp
+	ld8 r19=3D[r17]			// cumulated utime
+	;;
+	sub r18=3Dr20,r18			// elapsed time
+	;;
+	add r19=3Dr19,r18			// sum
+	;;
+	st8 [r16]=3Dr20			// update stamp
+	st8 [r17]=3Dr19			// update utime
+	;;
+#endif
 	mov ar.rsc=3D0x3				// M2   set eager mode, pl 0, LE, loadrs=3D0
 	mov rp=3Dr14				// I0   set the real return addr
 	and r3=3D_TIF_SYSCALL_TRACEAUDIT,r3	// A


