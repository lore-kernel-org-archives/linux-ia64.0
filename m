From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Mon, 25 Feb 2008 03:16:45 +0000
Subject: [PATCH 3/4] ia64: prepare for paravirtualizatin of entry.S
Message-Id: <12039094063637-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org


Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/kernel/entry.S  |   41 +++++++++++++++++++++++++++++------------
 include/asm-ia64/privop.h |   26 ++++++++++++++++++++++++++
 2 files changed, 55 insertions(+), 12 deletions(-)
 create mode 100644 include/asm-ia64/privop.h

diff --git a/arch/ia64/kernel/entry.S b/arch/ia64/kernel/entry.S
index 3c331c4..39bb7d5 100644
--- a/arch/ia64/kernel/entry.S
+++ b/arch/ia64/kernel/entry.S
@@ -180,7 +180,7 @@ END(sys_clone)
  *	called.  The code starting at .map relies on this.  The rest of the code
  *	doesn't care about the interrupt masking status.
  */
-GLOBAL_ENTRY(ia64_switch_to)
+GLOBAL_ENTRY(__ia64_switch_to)
 	.prologue
 	alloc r16=3Dar.pfs,1,0,0,0
 	DO_SAVE_SWITCH_STACK
@@ -234,7 +234,7 @@ GLOBAL_ENTRY(ia64_switch_to)
 	;;
 	srlz.d
 	br.cond.sptk .done
-END(ia64_switch_to)
+END(__ia64_switch_to)
=20
 /*
  * Note that interrupts are enabled during save_switch_stack and load_swit=
ch_stack.  This
@@ -375,7 +375,7 @@ END(save_switch_stack)
  *	- b7 holds address to return to
  *	- must not touch r8-r11
  */
-ENTRY(load_switch_stack)
+GLOBAL_ENTRY(load_switch_stack)
 	.prologue
 	.altrp b7
=20
@@ -635,8 +635,16 @@ GLOBAL_ENTRY(ia64_ret_from_syscall)
 	adds r2=3DPT(R8)+16,sp			// r2 =3D &pt_regs.r8
 	mov r10=3Dr0				// clear error indication in r10
 (p7)	br.cond.spnt handle_syscall_error	// handle potential syscall failure
+#ifdef CONFIG_PARAVIRT_GUEST
+	;;
+	// don't fall through, ia64_leave_syscall may be #define'd
+	br.cond.sptk.few ia64_leave_syscall
+	;;
+#endif
 END(ia64_ret_from_syscall)
+#ifndef CONFIG_PARAVIRT_GUEST
 	// fall through
+#endif
 /*
  * ia64_leave_syscall(): Same as ia64_leave_kernel, except that it doesn't
  *	need to switch to bank 0 and doesn't restore the scratch registers.
@@ -681,7 +689,7 @@ END(ia64_ret_from_syscall)
  *	      ar.csd: cleared
  *	      ar.ssd: cleared
  */
-ENTRY(ia64_leave_syscall)
+GLOBAL_ENTRY(__ia64_leave_syscall)
 	PT_REGS_UNWIND_INFO(0)
 	/*
 	 * work.need_resched etc. mustn't get changed by this CPU before it retur=
ns to
@@ -691,7 +699,7 @@ ENTRY(ia64_leave_syscall)
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
@@ -709,7 +717,8 @@ ENTRY(ia64_leave_syscall)
 	cmp.eq pLvSys,p0=3Dr0,r0		// pLvSys=3D1: leave from syscall
 (pUStk)	cmp.eq.unc p6,p0=3Dr0,r0		// p6 <- pUStk
 #endif
-.work_processed_syscall:
+.global __ia64_work_processed_syscall;
+__ia64_work_processed_syscall:
 	adds r2=3DPT(LOADRS)+16,r12
 	adds r3=3DPT(AR_BSPSTORE)+16,r12
 	adds r18=3DTI_FLAGS+IA64_TASK_SIZE,r13
@@ -788,7 +797,7 @@ ENTRY(ia64_leave_syscall)
 	mov.m ar.ssd=3Dr0			// M2   clear ar.ssd
 	mov f11=F0			// F    clear f11
 	br.cond.sptk.many rbs_switch	// B
-END(ia64_leave_syscall)
+END(__ia64_leave_syscall)
=20
 #ifdef CONFIG_IA32_SUPPORT
 GLOBAL_ENTRY(ia64_ret_from_ia32_execve)
@@ -800,10 +809,18 @@ GLOBAL_ENTRY(ia64_ret_from_ia32_execve)
 	st8.spill [r2]=3Dr8	// store return value in slot for r8 and set unat bit
 	.mem.offset 8,0
 	st8.spill [r3]=3Dr0	// clear error indication in slot for r10 and set una=
t bit
+#ifdef CONFIG_PARAVIRT_GUEST
+	;;
+	// don't fall through, ia64_leave_kernel may be #define'd
+	br.cond.sptk.few ia64_leave_kernel
+	;;
+#endif
 END(ia64_ret_from_ia32_execve)
+#ifndef CONFIG_PARAVIRT_GUEST
 	// fall through
+#endif
 #endif /* CONFIG_IA32_SUPPORT */
-GLOBAL_ENTRY(ia64_leave_kernel)
+GLOBAL_ENTRY(__ia64_leave_kernel)
 	PT_REGS_UNWIND_INFO(0)
 	/*
 	 * work.need_resched etc. mustn't get changed by this CPU before it retur=
ns to
@@ -1130,9 +1147,9 @@ skip_rbs_switch:
 	;;
 	ld8 r8=3D[r2]
 	ld8 r10=3D[r3]
-	br.cond.sptk.many .work_processed_syscall	// re-check
+	br.cond.sptk.many ia64_work_processed_syscall	// re-check
=20
-END(ia64_leave_kernel)
+END(__ia64_leave_kernel)
=20
 ENTRY(handle_syscall_error)
 	/*
@@ -1172,7 +1189,7 @@ END(ia64_invoke_schedule_tail)
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
@@ -1234,7 +1251,7 @@ ENTRY(sys_rt_sigreturn)
 	adds sp=16,sp
 	;;
 	ld8 r9=3D[sp]				// load new ar.unat
-	mov.sptk b7=3Dr8,ia64_leave_kernel
+	mov.sptk b7=3Dr8,__ia64_leave_kernel
 	;;
 	mov ar.unat=3Dr9
 	br.many b7
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

