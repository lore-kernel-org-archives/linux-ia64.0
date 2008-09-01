From: Christoph Hellwig <hch@lst.de>
Date: Mon, 01 Sep 2008 16:19:18 +0000
Subject: [PATCH] ia64: use generic compat_sys_ptrace
Message-Id: <20080901161918.GB16320@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

By using the generic compat_sys_ptrace we can remove lots of boilerplate
code.


Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/arch/ia64/ia32/sys_ia32.c
=================================--- linux-2.6.orig/arch/ia64/ia32/sys_ia32.c	2008-09-01 09:41:03.000000000 -0300
+++ linux-2.6/arch/ia64/ia32/sys_ia32.c	2008-09-01 09:46:09.000000000 -0300
@@ -1566,50 +1566,26 @@ restore_ia32_fpxstate (struct task_struc
 	return 0;
 }
 
-asmlinkage long
-sys32_ptrace (int request, pid_t pid, unsigned int addr, unsigned int data)
+long compat_arch_ptrace(struct task_struct *child, compat_long_t request,
+			       compat_ulong_t addr, compat_ulong_t data)
 {
-	struct task_struct *child;
 	unsigned int value, tmp;
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
+	case PTRACE_PEEKTEXT:
+	case PTRACE_PEEKDATA:	/* read word at location addr */
 		ret = ia32_peek(child, addr, &value);
-		if (ret = 0)
+		if (ret != 0)
 			ret = put_user(value, (unsigned int __user *) compat_ptr(data));
 		else
 			ret = -EIO;
-		goto out_tsk;
-
-	      case PTRACE_POKETEXT:
-	      case PTRACE_POKEDATA:	/* write the word at location addr */
+		break;
+	case PTRACE_POKETEXT:
+	case PTRACE_POKEDATA:	/* write the word at location addr */
 		ret = ia32_poke(child, addr, data);
-		goto out_tsk;
-
-	      case PTRACE_PEEKUSR:	/* read word at addr in USER area */
+		break;
+	case PTRACE_PEEKUSR:	/* read word at addr in USER area */
 		ret = -EIO;
 		if ((addr & 3) || addr > 17*sizeof(int))
 			break;
@@ -1618,8 +1594,7 @@ sys32_ptrace (int request, pid_t pid, un
 		if (!put_user(tmp, (unsigned int __user *) compat_ptr(data)))
 			ret = 0;
 		break;
-
-	      case PTRACE_POKEUSR:	/* write word at addr in USER area */
+	case PTRACE_POKEUSR:	/* write word at addr in USER area */
 		ret = -EIO;
 		if ((addr & 3) || addr > 17*sizeof(int))
 			break;
@@ -1627,8 +1602,7 @@ sys32_ptrace (int request, pid_t pid, un
 		putreg(child, addr, data);
 		ret = 0;
 		break;
-
-	      case IA32_PTRACE_GETREGS:
+	case IA32_PTRACE_GETREGS:
 		if (!access_ok(VERIFY_WRITE, compat_ptr(data), 17*sizeof(int))) {
 			ret = -EIO;
 			break;
@@ -1639,8 +1613,7 @@ sys32_ptrace (int request, pid_t pid, un
 		}
 		ret = 0;
 		break;
-
-	      case IA32_PTRACE_SETREGS:
+	case IA32_PTRACE_SETREGS:
 		if (!access_ok(VERIFY_READ, compat_ptr(data), 17*sizeof(int))) {
 			ret = -EIO;
 			break;
@@ -1652,48 +1625,30 @@ sys32_ptrace (int request, pid_t pid, un
 		}
 		ret = 0;
 		break;
-
-	      case IA32_PTRACE_GETFPREGS:
+	case IA32_PTRACE_GETFPREGS:
 		ret = save_ia32_fpstate(child, (struct ia32_user_i387_struct __user *)
 					compat_ptr(data));
 		break;
-
-	      case IA32_PTRACE_GETFPXREGS:
+	case IA32_PTRACE_GETFPXREGS:
 		ret = save_ia32_fpxstate(child, (struct ia32_user_fxsr_struct __user *)
 					 compat_ptr(data));
 		break;
-
-	      case IA32_PTRACE_SETFPREGS:
+	case IA32_PTRACE_SETFPREGS:
 		ret = restore_ia32_fpstate(child, (struct ia32_user_i387_struct __user *)
 					   compat_ptr(data));
 		break;
-
-	      case IA32_PTRACE_SETFPXREGS:
+	case IA32_PTRACE_SETFPXREGS:
 		ret = restore_ia32_fpxstate(child, (struct ia32_user_fxsr_struct __user *)
 					    compat_ptr(data));
 		break;
-
-	      case PTRACE_GETEVENTMSG:   
+	case PTRACE_GETEVENTMSG:
 		ret = put_user(child->ptrace_message, (unsigned int __user *) compat_ptr(data));
 		break;
-
-	      case PTRACE_SYSCALL:	/* continue, stop after next syscall */
-	      case PTRACE_CONT:		/* restart after signal. */
-	      case PTRACE_KILL:
-	      case PTRACE_SINGLESTEP:	/* execute chile for one instruction */
-	      case PTRACE_DETACH:	/* detach a process */
-		ret = sys_ptrace(request, pid, addr, data);
-		break;
-
-	      default:
-		ret = ptrace_request(child, request, addr, data);
+	default:
+		ret = compat_ptrace_request(child, request, addr, data);
 		break;
-
 	}
-  out_tsk:
-	put_task_struct(child);
-  out:
-	unlock_kernel();
+
 	return ret;
 }
 
Index: linux-2.6/arch/ia64/include/asm/ptrace.h
=================================--- linux-2.6.orig/arch/ia64/include/asm/ptrace.h	2008-09-01 09:40:34.000000000 -0300
+++ linux-2.6/arch/ia64/include/asm/ptrace.h	2008-09-01 09:41:05.000000000 -0300
@@ -319,6 +319,8 @@ struct switch_stack {
   #define arch_has_block_step()   (1)
   extern void user_enable_block_step(struct task_struct *);
 
+#define __ARCH_WANT_COMPAT_SYS_PTRACE
+
 #endif /* !__KERNEL__ */
 
 /* pt_all_user_regs is used for PTRACE_GETREGS PTRACE_SETREGS */
