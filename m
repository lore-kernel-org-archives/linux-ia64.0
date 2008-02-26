From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Tue, 26 Feb 2008 13:58:53 +0000
Subject: [PATCH 2/8] ia64/pv_ops: preparation for paravirtualizatin of switch_leave.S and ivt.S
Message-Id: <1204034339620-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

make some symbol global and add some hooks.
define __IA64_ASM_PARAVIRTUALIZED_NATIVE to tell its native compilation
when compiling ivt.S and switch_leave.S

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/kernel/Makefile       |    6 ++++++
 arch/ia64/kernel/entry.S        |    4 ++--
 arch/ia64/kernel/minstate.h     |    2 ++
 arch/ia64/kernel/switch_leave.S |   19 ++++++++++---------
 include/asm-ia64/privop.h       |   26 ++++++++++++++++++++++++++
 5 files changed, 46 insertions(+), 11 deletions(-)
 create mode 100644 include/asm-ia64/privop.h

diff --git a/arch/ia64/kernel/Makefile b/arch/ia64/kernel/Makefile
index f9bc3c4..9281bf6 100644
--- a/arch/ia64/kernel/Makefile
+++ b/arch/ia64/kernel/Makefile
@@ -70,3 +70,9 @@ $(obj)/gate-syms.o: $(obj)/gate.lds $(obj)/gate.o FORCE
 # We must build gate.so before we can assemble it.
 # Note: kbuild does not track this dependency due to usage of .incbin
 $(obj)/gate-data.o: $(obj)/gate.so
+
+#
+# native ivt.S and switch_leave.S
+#
+AFLAGS_ivt.o +=3D -D__IA64_ASM_PARAVIRTUALIZED_NATIVE
+AFLAGS_switch_leave.o +=3D -D__IA64_ASM_PARAVIRTUALIZED_NATIVE
diff --git a/arch/ia64/kernel/entry.S b/arch/ia64/kernel/entry.S
index df8dcc9..de91f61 100644
--- a/arch/ia64/kernel/entry.S
+++ b/arch/ia64/kernel/entry.S
@@ -304,7 +304,7 @@ END(save_switch_stack)
  *	- b7 holds address to return to
  *	- must not touch r8-r11
  */
-ENTRY(load_switch_stack)
+GLOBAL_ENTRY(load_switch_stack)
 	.prologue
 	.altrp b7
=20
@@ -624,7 +624,7 @@ END(ia64_invoke_schedule_tail)
 	 * be set up by the caller.  We declare 8 input registers so the system c=
all
 	 * args get preserved, in case we need to restart a system call.
 	 */
-ENTRY(notify_resume_user)
+GLOBAL_ENTRY(notify_resume_user)
 	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(8)
 	alloc loc1=3Dar.pfs,8,2,3,0 // preserve all eight input regs in case of s=
yscall restart!
 	mov r9=3Dar.unat
diff --git a/arch/ia64/kernel/minstate.h b/arch/ia64/kernel/minstate.h
index c9ac8ba..3dfd36c 100644
--- a/arch/ia64/kernel/minstate.h
+++ b/arch/ia64/kernel/minstate.h
@@ -3,6 +3,7 @@
=20
 #include "entry.h"
=20
+#ifdef __IA64_ASM_PARAVIRTUALIZED_NATIVE
 /*
  * DO_SAVE_MIN switches to the kernel stacks (if necessary) and saves
  * the minimum state necessary that allows us to turn psr.ic back
@@ -129,6 +130,7 @@
 	;;											\
 	bsw.1;			/* switch back to bank 1 (must be last in insn group) */	\
 	;;
+#endif /* __IA64_ASM_PARAVIRTUALIZED_NATIVE */
=20
 /*
  * SAVE_REST saves the remainder of pt_regs (with psr.ic on).
diff --git a/arch/ia64/kernel/switch_leave.S b/arch/ia64/kernel/switch_leav=
e.S
index 5ca5b84..b235917 100644
--- a/arch/ia64/kernel/switch_leave.S
+++ b/arch/ia64/kernel/switch_leave.S
@@ -53,7 +53,7 @@
  *	called.  The code starting at .map relies on this.  The rest of the code
  *	doesn't care about the interrupt masking status.
  */
-GLOBAL_ENTRY(ia64_switch_to)
+GLOBAL_ENTRY(__ia64_switch_to)
 	.prologue
 	alloc r16=3Dar.pfs,1,0,0,0
 	DO_SAVE_SWITCH_STACK
@@ -107,7 +107,7 @@ GLOBAL_ENTRY(ia64_switch_to)
 	;;
 	srlz.d
 	br.cond.sptk .done
-END(ia64_switch_to)
+END(__ia64_switch_to)
=20
 /*
  * ia64_leave_syscall(): Same as ia64_leave_kernel, except that it doesn't
@@ -153,7 +153,7 @@ END(ia64_switch_to)
  *	      ar.csd: cleared
  *	      ar.ssd: cleared
  */
-ENTRY(ia64_leave_syscall)
+GLOBAL_ENTRY(__ia64_leave_syscall)
 	PT_REGS_UNWIND_INFO(0)
 	/*
 	 * work.need_resched etc. mustn't get changed by this CPU before it retur=
ns to
@@ -163,7 +163,7 @@ ENTRY(ia64_leave_syscall)
 	 * extra work.  We always check for extra work when returning to user-lev=
el.
 	 * With CONFIG_PREEMPT, we also check for extra work when the preempt_cou=
nt
 	 * is 0.  After extra work processing has been completed, execution
-	 * resumes at .work_processed_syscall with p6 set to 1 if the extra-work-=
check
+	 * resumes at ia64_work_processed_syscall with p6 set to 1 if the extra-w=
ork-check
 	 * needs to be redone.
 	 */
 #ifdef CONFIG_PREEMPT
@@ -181,7 +181,8 @@ ENTRY(ia64_leave_syscall)
 	cmp.eq pLvSys,p0=3Dr0,r0		// pLvSys=3D1: leave from syscall
 (pUStk)	cmp.eq.unc p6,p0=3Dr0,r0		// p6 <- pUStk
 #endif
-.work_processed_syscall:
+.global __ia64_work_processed_syscall;
+__ia64_work_processed_syscall:
 	adds r2=3DPT(LOADRS)+16,r12
 	adds r3=3DPT(AR_BSPSTORE)+16,r12
 	adds r18=3DTI_FLAGS+IA64_TASK_SIZE,r13
@@ -260,9 +261,9 @@ ENTRY(ia64_leave_syscall)
 	mov.m ar.ssd=3Dr0			// M2   clear ar.ssd
 	mov f11=F0			// F    clear f11
 	br.cond.sptk.many rbs_switch	// B
-END(ia64_leave_syscall)
+END(__ia64_leave_syscall)
=20
-GLOBAL_ENTRY(ia64_leave_kernel)
+GLOBAL_ENTRY(__ia64_leave_kernel)
 	PT_REGS_UNWIND_INFO(0)
 	/*
 	 * work.need_resched etc. mustn't get changed by this CPU before it retur=
ns to
@@ -590,5 +591,5 @@ ia64_work_pending_syscall_end:
 	;;
 	ld8 r8=3D[r2]
 	ld8 r10=3D[r3]
-	br.cond.sptk.many .work_processed_syscall	// re-check
-END(ia64_leave_kernel)
+	br.cond.sptk.many ia64_work_processed_syscall	// re-check
+END(__ia64_leave_kernel)
diff --git a/include/asm-ia64/privop.h b/include/asm-ia64/privop.h
new file mode 100644
index 0000000..b8dce79
--- /dev/null
+++ b/include/asm-ia64/privop.h
@@ -0,0 +1,26 @@
+#ifndef _ASM_IA64_PRIVOP_H
+#define _ASM_IA64_PRIVOP_H
+
+#ifndef _ASM_IA64_INTRINSICS_H
+#error "don't include privop.h directly. instead include intrinsics.h"
+#endif
+/*
+ * Copyright (C) 2005 Hewlett-Packard Co
+ *	Dan Magenheimer <dan.magenheimer@hp.com>
+ *
+ */
+
+#ifdef CONFIG_XEN
+#include <asm/xen/privop.h>
+#endif
+
+/* fallback for native case */
+
+#ifndef IA64_PARAVIRTUALIZED_ENTRY
+#define ia64_switch_to			__ia64_switch_to
+#define ia64_leave_syscall		__ia64_leave_syscall
+#define ia64_work_processed_syscall	__ia64_work_processed_syscall
+#define ia64_leave_kernel		__ia64_leave_kernel
+#endif /* !IA64_PARAVIRTUALIZED_ENTRY */
+
+#endif /* _ASM_IA64_PRIVOP_H */
--=20
1.5.3

