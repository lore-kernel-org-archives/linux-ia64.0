From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 16 Jan 2003 01:14:01 +0000
Subject: Re: [Linux-ia64] fsyscall-support
Message-Id: <marc-linux-ia64-105590709805694@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805677@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805677@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The patch below fixes the
asynchronous-signal-delivery-during-fsys-mode case that I mentioned
earlier.  The solution is simple and has not adverse effect on
fsyscall handlers: if an asynchronous signal (or some other event)
gets posted during an fsyscall, we turn on PSR.lp to request a trap
upon returning to user-level.

The patch also adds a workaround for the McKinley Erratum 7.  The
workaround adds ~20 cycles of overhead for getpid().  Not ideal, but
still _very_ fast and the good news is that the workaround is really
only needed on McKinley.

For convenience, I also refreshed the 2.5.52 patch at
http://www.kernel.org/pub/linux/kernel/ports/ia64/v2.5:

  linux-2.5.52-ia64-030115.diff.gz

This patch contains the fsys-mode support as well as a couple of small
fixes.  It works well on HP Ski simulator and HP zx6000 and should
work fine on all other Itanium/Itanium 2 hardware as well.  One big
caveat: the cmd649 driver is BROKEN.  Don't use it on IDE disks
because it WILL eat your filesystem.

	--david

PS: If you sent me patches and don't see them in the above patch yet:
    don't panic---I'll sync up with those in the next iteration.

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.896   -> 1.897  
#	arch/ia64/kernel/fsys.S	1.1     -> 1.2    
#	include/asm-ia64/asmmacro.h	1.4     -> 1.5    
#	arch/ia64/kernel/process.c	1.22    -> 1.23   
#	Documentation/ia64/fsys.txt	1.1     -> 1.2    
#	include/asm-ia64/ptrace.h	1.6     -> 1.7    
#	arch/ia64/kernel/gate.S	1.10    -> 1.11   
#	arch/ia64/kernel/unaligned.c	1.9     -> 1.10   
#	arch/ia64/kernel/traps.c	1.21    -> 1.22   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/01/15	davidm@tiger.hpl.hp.com	1.897
# ia64: Make asynchronous signal delivery work properly during fsys-mode execution.
# 	Add workaround for McKinley Erratum 7.
# --------------------------------------------
#
diff -Nru a/Documentation/ia64/fsys.txt b/Documentation/ia64/fsys.txt
--- a/Documentation/ia64/fsys.txt	Wed Jan 15 17:02:02 2003
+++ b/Documentation/ia64/fsys.txt	Wed Jan 15 17:02:02 2003
@@ -4,7 +4,7 @@
 		-----------------------------------
 
 		        Started: 13-Jan-2002
-		    Last update: 14-Jan-2002
+		    Last update: 15-Jan-2002
 
 	              David Mosberger-Tang
 		      <davidm@hpl.hp.com>
@@ -14,23 +14,22 @@
 "fsys-mode".  To recap, the normal states of execution are:
 
   - kernel mode:
-	Both the register stack and the kernel stack have been
-	switched over to the kernel stack.  The user-level state
-	is saved in a pt-regs structure at the top of the kernel
-	memory stack.
+	Both the register stack and the memory stack have been
+	switched over to kernel memory.  The user-level state is saved
+	in a pt-regs structure at the top of the kernel memory stack.
 
   - user mode:
 	Both the register stack and the kernel stack are in
-	user land.  The user-level state is contained in the
+	user memory.  The user-level state is contained in the
 	CPU registers.
 
   - bank 0 interruption-handling mode:
-	This is the non-interruptible state in that all
-	interruption-handlers start executing in.  The user-level
+	This is the non-interruptible state which all
+	interruption-handlers start execution in.  The user-level
 	state remains in the CPU registers and some kernel state may
 	be stored in bank 0 of registers r16-r31.
 
-Fsys-mode has the following special properties:
+In contrast, fsys-mode has the following special properties:
 
   - execution is at privilege level 0 (most-privileged)
 
@@ -61,18 +60,19 @@
 three macros:
 
 	user_mode(regs)
-	user_stack(regs)
-	fsys_mode(regs)
+	user_stack(task,regs)
+	fsys_mode(task,regs)
 
-The "regs" argument is a pointer to a pt_regs structure.  user_mode()
-returns TRUE if the CPU state pointed to by "regs" was executing in
-user mode (privilege level 3).  user_stack() returns TRUE if the state
-pointed to by "regs" was executing on the user-level stack(s).
-Finally, fsys_mode() returns TRUE if the CPU state pointed to by
-"regs" was executing in fsys-mode.  The fsys_mode() macro corresponds
-exactly to the expression:
+The "regs" argument is a pointer to a pt_regs structure.  The "task"
+argument is a pointer to the task structure to which the "regs"
+pointer belongs to.  user_mode() returns TRUE if the CPU state pointed
+to by "regs" was executing in user mode (privilege level 3).
+user_stack() returns TRUE if the state pointed to by "regs" was
+executing on the user-level stack(s).  Finally, fsys_mode() returns
+TRUE if the CPU state pointed to by "regs" was executing in fsys-mode.
+The fsys_mode() macro is equivalent to the expression:
 
-	!user_mode(regs) && user_stack(regs)
+	!user_mode(regs) && user_stack(task,regs)
 
 * How to write an fsyscall handler
 
@@ -154,6 +154,17 @@
 fast system call execution (while fully preserving system call
 semantics), but there is also a lot of flexibility in handling more
 complicated cases.
+
+* Signal handling
+
+The delivery of (asynchronous) signals must be delayed until fsys-mode
+is exited.  This is acomplished with the help of the lower-privilege
+transfer trap: arch/ia64/kernel/process.c:do_notify_resume_user()
+checks whether the interrupted task was in fsys-mode and, if so, sets
+PSR.lp and returns immediately.  When fsys-mode is exited via the
+"br.ret" instruction that lowers the privilege level, a trap will
+occur.  The trap handler clears PSR.lp again and returns immediately.
+The kernel exit path then checks for and delivers any pending signals.
 
 * PSR Handling
 
diff -Nru a/arch/ia64/kernel/fsys.S b/arch/ia64/kernel/fsys.S
--- a/arch/ia64/kernel/fsys.S	Wed Jan 15 17:02:02 2003
+++ b/arch/ia64/kernel/fsys.S	Wed Jan 15 17:02:02 2003
@@ -13,6 +13,7 @@
 ENTRY(fsys_ni_syscall)
 	mov r8=ENOSYS
 	mov r10=-1
+	MCKINLEY_E7_WORKAROUND
 	br.ret.sptk.many b6
 END(fsys_ni_syscall)
 
@@ -27,6 +28,7 @@
 	;;
 	cmp.ne p8,p0=0,r9
 (p8)	br.spnt.many fsys_fallback_syscall
+	MCKINLEY_E7_WORKAROUND
 	br.ret.sptk.many b6
 END(fsys_getpid)
 
diff -Nru a/arch/ia64/kernel/gate.S b/arch/ia64/kernel/gate.S
--- a/arch/ia64/kernel/gate.S	Wed Jan 15 17:02:02 2003
+++ b/arch/ia64/kernel/gate.S	Wed Jan 15 17:02:02 2003
@@ -66,6 +66,7 @@
 
 	mov r10=-1
 	mov r8=ENOSYS
+	MCKINLEY_E7_WORKAROUND
 	br.ret.sptk.many b6
 END(syscall_via_epc)
 
@@ -88,6 +89,7 @@
 	 */
 	movl r2=(syscall_via_break - .start_gate) + GATE_ADDR
 	;;
+	MCKINLEY_E7_WORKAROUND
 	mov b7=r2
 	br.ret.sptk.many b7
 END(fsys_fallback_syscall)
diff -Nru a/arch/ia64/kernel/process.c b/arch/ia64/kernel/process.c
--- a/arch/ia64/kernel/process.c	Wed Jan 15 17:02:02 2003
+++ b/arch/ia64/kernel/process.c	Wed Jan 15 17:02:02 2003
@@ -1,7 +1,7 @@
 /*
  * Architecture-specific setup.
  *
- * Copyright (C) 1998-2002 Hewlett-Packard Co
+ * Copyright (C) 1998-2003 Hewlett-Packard Co
  *	David Mosberger-Tang <davidm@hpl.hp.com>
  */
 #define __KERNEL_SYSCALLS__	/* see <asm/unistd.h> */
@@ -144,6 +144,13 @@
 void
 do_notify_resume_user (sigset_t *oldset, struct sigscratch *scr, long in_syscall)
 {
+	if (fsys_mode(current, &scr->pt)) {
+		/* defer signal-handling etc. until we return to privilege-level 0.  */
+		if (!ia64_psr(&scr->pt)->lp)
+			ia64_psr(&scr->pt)->lp = 1;
+		return;
+	}
+
 #ifdef CONFIG_PERFMON
 	if (current->thread.pfm_ovfl_block_reset)
 		pfm_ovfl_block_reset();
diff -Nru a/arch/ia64/kernel/traps.c b/arch/ia64/kernel/traps.c
--- a/arch/ia64/kernel/traps.c	Wed Jan 15 17:02:02 2003
+++ b/arch/ia64/kernel/traps.c	Wed Jan 15 17:02:02 2003
@@ -1,7 +1,7 @@
 /*
  * Architecture-specific trap handling.
  *
- * Copyright (C) 1998-2002 Hewlett-Packard Co
+ * Copyright (C) 1998-2003 Hewlett-Packard Co
  *	David Mosberger-Tang <davidm@hpl.hp.com>
  *
  * 05/12/00 grao <goutham.rao@intel.com> : added isr in siginfo for SIGFPE
@@ -524,7 +524,7 @@
 	      case 29: /* Debug */
 	      case 35: /* Taken Branch Trap */
 	      case 36: /* Single Step Trap */
-		if (fsys_mode(regs)) {
+		if (fsys_mode(current, regs)) {
 			extern char syscall_via_break[], __start_gate_section[];
 			/*
 			 * Got a trap in fsys-mode: Taken Branch Trap and Single Step trap
@@ -580,19 +580,31 @@
 		}
 		return;
 
-	      case 34:		/* Unimplemented Instruction Address Trap */
-		if (user_mode(regs)) {
-			siginfo.si_signo = SIGILL;
-			siginfo.si_code = ILL_BADIADDR;
-			siginfo.si_errno = 0;
-			siginfo.si_flags = 0;
-			siginfo.si_isr = 0;
-			siginfo.si_imm = 0;
-			siginfo.si_addr = (void *) (regs->cr_iip + ia64_psr(regs)->ri);
-			force_sig_info(SIGILL, &siginfo, current);
+	      case 34:
+		if (isr & 0x2) {
+			/* Lower-Privilege Transfer Trap */
+			/*
+			 * Just clear PSR.lp and then return immediately: all the
+			 * interesting work (e.g., signal delivery is done in the kernel
+			 * exit path).
+			 */
+			ia64_psr(regs)->lp = 0;
 			return;
+		} else {
+			/* Unimplemented Instr. Address Trap */
+			if (user_mode(regs)) {
+				siginfo.si_signo = SIGILL;
+				siginfo.si_code = ILL_BADIADDR;
+				siginfo.si_errno = 0;
+				siginfo.si_flags = 0;
+				siginfo.si_isr = 0;
+				siginfo.si_imm = 0;
+				siginfo.si_addr = (void *) (regs->cr_iip + ia64_psr(regs)->ri);
+				force_sig_info(SIGILL, &siginfo, current);
+				return;
+			}
+			sprintf(buf, "Unimplemented Instruction Address fault");
 		}
-		sprintf(buf, "Unimplemented Instruction Address fault");
 		break;
 
 	      case 45:
diff -Nru a/arch/ia64/kernel/unaligned.c b/arch/ia64/kernel/unaligned.c
--- a/arch/ia64/kernel/unaligned.c	Wed Jan 15 17:02:02 2003
+++ b/arch/ia64/kernel/unaligned.c	Wed Jan 15 17:02:02 2003
@@ -331,7 +331,7 @@
 		return;
 	}
 
-	if (!user_stack(regs)) {
+	if (!user_stack(current, regs)) {
 		DPRINT("ignoring kernel write to r%lu; register isn't on the kernel RBS!", r1);
 		return;
 	}
@@ -402,7 +402,7 @@
 		return;
 	}
 
-	if (!user_stack(regs)) {
+	if (!user_stack(current, regs)) {
 		DPRINT("ignoring kernel read of r%lu; register isn't on the RBS!", r1);
 		goto fail;
 	}
diff -Nru a/include/asm-ia64/asmmacro.h b/include/asm-ia64/asmmacro.h
--- a/include/asm-ia64/asmmacro.h	Wed Jan 15 17:02:02 2003
+++ b/include/asm-ia64/asmmacro.h	Wed Jan 15 17:02:02 2003
@@ -6,6 +6,8 @@
  *	David Mosberger-Tang <davidm@hpl.hp.com>
  */
 
+#include <linux/config.h>
+
 #define ENTRY(name)				\
 	.align 32;				\
 	.proc name;				\
@@ -55,6 +57,15 @@
 # define EXCLR(y,x...)					\
 	.xdata4 "__ex_table", @gprel(99f), @gprel(y)+4;	\
   99:	x
+#endif
+
+#ifdef CONFIG_MCKINLEY
+/* workaround for Itanium 2 Errata 7: */
+# define MCKINLEY_E7_WORKAROUND			\
+	br.call.sptk.many b7;;		\
+1:
+#else
+# define MCKINLEY_E7_WORKAROUND
 #endif
 
 #endif /* _ASM_IA64_ASMMACRO_H */
diff -Nru a/include/asm-ia64/ptrace.h b/include/asm-ia64/ptrace.h
--- a/include/asm-ia64/ptrace.h	Wed Jan 15 17:02:02 2003
+++ b/include/asm-ia64/ptrace.h	Wed Jan 15 17:02:02 2003
@@ -2,7 +2,7 @@
 #define _ASM_IA64_PTRACE_H
 
 /*
- * Copyright (C) 1998-2002 Hewlett-Packard Co
+ * Copyright (C) 1998-2003 Hewlett-Packard Co
  *	David Mosberger-Tang <davidm@hpl.hp.com>
  *	Stephane Eranian <eranian@hpl.hp.com>
  *
@@ -218,8 +218,13 @@
 # define ia64_task_regs(t)		(((struct pt_regs *) ((char *) (t) + IA64_STK_OFFSET)) - 1)
 # define ia64_psr(regs)			((struct ia64_psr *) &(regs)->cr_ipsr)
 # define user_mode(regs)		(((struct ia64_psr *) &(regs)->cr_ipsr)->cpl != 0)
-# define user_stack(regs)		(current->thread.on_ustack != 0)
-# define fsys_mode(regs)		(!user_mode(regs) && user_stack(regs))
+# define user_stack(task,regs)	((long) regs - (long) task = IA64_STK_OFFSET - sizeof(*regs))
+# define fsys_mode(task,regs)				\
+  ({							\
+	  struct task_struct *_task = (task);		\
+	  struct pt_regs *_regs = (regs);		\
+	  !user_mode(regs) && user_stack(task, regs);	\
+  })
 
   struct task_struct;			/* forward decl */
 

