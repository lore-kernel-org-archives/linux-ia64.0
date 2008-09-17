From: shaohua.li@intel.com
Date: Wed, 17 Sep 2008 08:13:24 +0000
Subject: [patch 4/4] covert compat ptrace to use compat_sys_ptrace
Message-Id: <20080917082022.399441481@sli10-desk.sh.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Convert IA64 32-bit ptrace to use compat_sys_ptrace.

Tony, this just passed for compilation, I don't know how to test such 32-bit code

Signed-off-by: Shaohua Li <shaohua.li@intel.com>
---
 arch/ia64/ia32/ia32_entry.S     |    2 
 arch/ia64/ia32/sys_ia32.c       |   83 ++------------------------------------
 arch/ia64/include/asm/ptrace.h  |    2 
 arch/ia64/include/asm/syscall.h |   86 ++++++++++++++++++++++++++++++++++++----
 4 files changed, 87 insertions(+), 86 deletions(-)

Index: linux/arch/ia64/ia32/ia32_entry.S
=================================--- linux.orig/arch/ia64/ia32/ia32_entry.S	2008-09-17 13:30:23.000000000 +0800
+++ linux/arch/ia64/ia32/ia32_entry.S	2008-09-17 13:56:36.000000000 +0800
@@ -199,7 +199,7 @@ ia32_syscall_table:
 	data8 sys_setuid	/* 16-bit version */
 	data8 sys_getuid	/* 16-bit version */
 	data8 compat_sys_stime    /* 25 */
-	data8 sys32_ptrace
+	data8 compat_sys_ptrace
 	data8 sys32_alarm
 	data8 sys_ni_syscall
 	data8 sys32_pause
Index: linux/arch/ia64/ia32/sys_ia32.c
=================================--- linux.orig/arch/ia64/ia32/sys_ia32.c	2008-09-17 13:30:23.000000000 +0800
+++ linux/arch/ia64/ia32/sys_ia32.c	2008-09-17 13:56:36.000000000 +0800
@@ -1300,25 +1300,6 @@ sys32_waitpid (int pid, unsigned int *st
 	return compat_sys_wait4(pid, stat_addr, options, NULL);
 }
 
-static unsigned int
-ia32_peek (struct task_struct *child, unsigned long addr, unsigned int *val)
-{
-	size_t copied;
-	unsigned int ret;
-
-	copied = access_process_vm(child, addr, val, sizeof(*val), 0);
-	return (copied != sizeof(ret)) ? -EIO : 0;
-}
-
-static unsigned int
-ia32_poke (struct task_struct *child, unsigned long addr, unsigned int val)
-{
-
-	if (access_process_vm(child, addr, &val, sizeof(val), 1) != sizeof(val))
-		return -EIO;
-	return 0;
-}
-
 /*
  *  The order in which registers are stored in the ptrace regs structure
  */
@@ -1616,49 +1597,15 @@ restore_ia32_fpxstate (struct task_struc
 	return 0;
 }
 
-asmlinkage long
-sys32_ptrace (int request, pid_t pid, unsigned int addr, unsigned int data)
+long compat_arch_ptrace(struct task_struct *child, compat_long_t request,
+	compat_ulong_t caddr, compat_ulong_t cdata)
 {
-	struct task_struct *child;
-	unsigned int value, tmp;
+	unsigned long addr = caddr;
+	unsigned long data = cdata;
+	unsigned int tmp;
 	long i, ret;
 
-	lock_kernel();
-	if (request = PTRACE_TRACEME) {
-		ret = ptrace_traceme();
-		goto out;
-	}
-
-	child = ptrace_get_task_struct(pid);
-	if (IS_ERR(child)) {
-		ret = PTR_ERR(child);
-		goto out;
-	}
-
-	if (request = PTRACE_ATTACH) {
-		ret = sys_ptrace(request, pid, addr, data);
-		goto out_tsk;
-	}
-
-	ret = ptrace_check_attach(child, request = PTRACE_KILL);
-	if (ret < 0)
-		goto out_tsk;
-
 	switch (request) {
-	      case PTRACE_PEEKTEXT:
-	      case PTRACE_PEEKDATA:	/* read word at location addr */
-		ret = ia32_peek(child, addr, &value);
-		if (ret = 0)
-			ret = put_user(value, (unsigned int __user *) compat_ptr(data));
-		else
-			ret = -EIO;
-		goto out_tsk;
-
-	      case PTRACE_POKETEXT:
-	      case PTRACE_POKEDATA:	/* write the word at location addr */
-		ret = ia32_poke(child, addr, data);
-		goto out_tsk;
-
 	      case PTRACE_PEEKUSR:	/* read word at addr in USER area */
 		ret = -EIO;
 		if ((addr & 3) || addr > 17*sizeof(int))
@@ -1723,27 +1670,9 @@ sys32_ptrace (int request, pid_t pid, un
 					    compat_ptr(data));
 		break;
 
-	      case PTRACE_GETEVENTMSG:   
-		ret = put_user(child->ptrace_message, (unsigned int __user *) compat_ptr(data));
-		break;
-
-	      case PTRACE_SYSCALL:	/* continue, stop after next syscall */
-	      case PTRACE_CONT:		/* restart after signal. */
-	      case PTRACE_KILL:
-	      case PTRACE_SINGLESTEP:	/* execute chile for one instruction */
-	      case PTRACE_DETACH:	/* detach a process */
-		ret = sys_ptrace(request, pid, addr, data);
-		break;
-
 	      default:
-		ret = ptrace_request(child, request, addr, data);
-		break;
-
+		return compat_ptrace_request(child, request, caddr, cdata);
 	}
-  out_tsk:
-	put_task_struct(child);
-  out:
-	unlock_kernel();
 	return ret;
 }
 
Index: linux/arch/ia64/include/asm/ptrace.h
=================================--- linux.orig/arch/ia64/include/asm/ptrace.h	2008-09-17 13:53:48.000000000 +0800
+++ linux/arch/ia64/include/asm/ptrace.h	2008-09-17 13:56:36.000000000 +0800
@@ -325,6 +325,8 @@ static inline unsigned long user_stack_p
   #define arch_has_block_step()   (1)
   extern void user_enable_block_step(struct task_struct *);
 
+#define __ARCH_WANT_COMPAT_SYS_PTRACE
+
 #endif /* !__KERNEL__ */
 
 /* pt_all_user_regs is used for PTRACE_GETREGS PTRACE_SETREGS */
Index: linux/arch/ia64/include/asm/syscall.h
=================================--- linux.orig/arch/ia64/include/asm/syscall.h	2008-09-17 13:53:48.000000000 +0800
+++ linux/arch/ia64/include/asm/syscall.h	2008-09-17 13:56:36.000000000 +0800
@@ -19,7 +19,10 @@
 static inline long syscall_get_nr(struct task_struct *task,
 				  struct pt_regs *regs)
 {
-	BUG_ON(IS_IA32_PROCESS(regs));
+#ifdef CONFIG_IA32_SUPPORT
+	if (IS_IA32_PROCESS(regs))
+		return regs->r1;
+#endif
 
 	return regs->r15;
 }
@@ -27,14 +30,21 @@ static inline long syscall_get_nr(struct
 static inline void syscall_rollback(struct task_struct *task,
 				    struct pt_regs *regs)
 {
-	BUG_ON(IS_IA32_PROCESS(regs));
+#ifdef CONFIG_IA32_SUPPORT
+	if (IS_IA32_PROCESS(regs))
+		regs->r8 = regs->r1;
+#endif
+
 	/* do nothing */
 }
 
 static inline long syscall_get_error(struct task_struct *task,
 				     struct pt_regs *regs)
 {
-	BUG_ON(IS_IA32_PROCESS(regs));
+#ifdef CONFIG_IA32_SUPPORT
+	if (IS_IA32_PROCESS(regs))
+		return regs->r8;
+#endif
 
 	return regs->r10 = -1 ? regs->r8:0;
 }
@@ -42,8 +52,6 @@ static inline long syscall_get_error(str
 static inline long syscall_get_return_value(struct task_struct *task,
 					    struct pt_regs *regs)
 {
-	BUG_ON(IS_IA32_PROCESS(regs));
-
 	return regs->r8;
 }
 
@@ -51,7 +59,12 @@ static inline void syscall_set_return_va
 					    struct pt_regs *regs,
 					    int error, long val)
 {
-	BUG_ON(IS_IA32_PROCESS(regs));
+#ifdef CONFIG_IA32_SUPPORT
+	if (IS_IA32_PROCESS(regs)) {
+		regs->r8 = (long) error ? error : val;
+		return;
+	}
+#endif
 
 	if (error) {
 		/* error < 0, but ia64 uses > 0 return value */
@@ -71,9 +84,39 @@ static inline void syscall_get_arguments
 					 unsigned int i, unsigned int n,
 					 unsigned long *args)
 {
-	BUG_ON(IS_IA32_PROCESS(regs));
 	BUG_ON(i + n > 6);
 
+#ifdef CONFIG_IA32_SUPPORT
+	if (IS_IA32_PROCESS(regs)) {
+		switch (i + n) {
+		case 6:
+			if (!n--) break;
+			*args++ = regs->r13;
+		case 5:
+			if (!n--) break;
+			*args++ = regs->r15;
+		case 4:
+			if (!n--) break;
+			*args++ = regs->r14;
+		case 3:
+			if (!n--) break;
+			*args++ = regs->r10;
+		case 2:
+			if (!n--) break;
+			*args++ = regs->r9;
+		case 1:
+			if (!n--) break;
+			*args++ = regs->r11;
+		case 0:
+			if (!n--) break;
+		default:
+			BUG();
+			break;
+		}
+
+		return;
+	}
+#endif
 	ia64_syscall_get_set_arguments(task, regs, i, n, args, 0);
 }
 
@@ -82,9 +125,36 @@ static inline void syscall_set_arguments
 					 unsigned int i, unsigned int n,
 					 const unsigned long *args)
 {
-	BUG_ON(IS_IA32_PROCESS(regs));
 	BUG_ON(i + n > 6);
 
+#ifdef CONFIG_IA32_SUPPORT
+	if (IS_IA32_PROCESS(regs)) {
+		switch (i + n) {
+		case 6:
+			if (!n--) break;
+			regs->r13 = *args++;
+		case 5:
+			if (!n--) break;
+			regs->r15 = *args++;
+		case 4:
+			if (!n--) break;
+			regs->r14 = *args++;
+		case 3:
+			if (!n--) break;
+			regs->r10 = *args++;
+		case 2:
+			if (!n--) break;
+			regs->r9 = *args++;
+		case 1:
+			if (!n--) break;
+			regs->r11 = *args++;
+		case 0:
+			if (!n--) break;
+		}
+
+		return;
+	}
+#endif
 	ia64_syscall_get_set_arguments(task, regs, i, n, args, 1);
 }
 #endif	/* _ASM_SYSCALL_H */

-- 
