From: Keith Owens <kaos@ocs.com.au>
Date: Sat, 02 Sep 2000 01:27:23 +0000
Subject: [Linux-ia64] 2.4.0 do_fork() change, all architectures
Message-Id: <marc-linux-ia64-105590678205445@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch hits every arch so it is being cross mailed to every arch
mailing list, apologies for duplicates.  Please trim replies to the
relevant mailing list.  Also please cc: kaos@ocs.com.au on replies, I
am not on every list.

IA64 needs an extra parameter on do_fork() and copy_thread(), those
functions are globally defined but arch local so there are changes to
every architecture.  For everything except IA64, the extra parameter is
unused and is specified as 0.  Sparc assembler changes by DaveM, blame
me for everything else.  If nobody complains, this patch against
2.4.0-test8-pre1 will go to Linus on Monday evening GMT.

Index: 0-test8-pre1.1/kernel/fork.c
--- 0-test8-pre1.1/kernel/fork.c Tue, 29 Aug 2000 15:22:12 +1100 kaos (linux-2.4/j/35_fork.c 1.1.1.9.1.6 644)
+++ 0-test8-pre1.1(w)/kernel/fork.c Sat, 02 Sep 2000 11:34:02 +1100 kaos (linux-2.4/j/35_fork.c 1.1.1.9.1.6 644)
@@ -528,10 +528,15 @@
 
 /*
  *  Ok, this is the main fork-routine. It copies the system process
- * information (task[nr]) and sets up the necessary registers. It
- * also copies the data segment in its entirety.
+ * information (task[nr]) and sets up the necessary registers. It also
+ * copies the data segment in its entirety.  The "stack_start" and
+ * "stack_top" arguments are simply passed along to the platform
+ * specific copy_thread() routine.  Most platforms ignore stack_top.
+ * For an example that's using stack_top, see
+ * arch/ia64/kernel/process.c.
  */
-int do_fork(unsigned long clone_flags, unsigned long usp, struct pt_regs *regs)
+int do_fork(unsigned long clone_flags, unsigned long stack_start, unsigned long stack_top,
+	    struct pt_regs *regs)
 {
 	int retval = -ENOMEM;
 	struct task_struct *p;
@@ -628,7 +633,7 @@
 		goto bad_fork_cleanup_fs;
 	if (copy_mm(clone_flags, p))
 		goto bad_fork_cleanup_sighand;
-	retval = copy_thread(0, clone_flags, usp, p, regs);
+	retval = copy_thread(0, clone_flags, stack_start, stack_top, p, regs);
 	if (retval)
 		goto bad_fork_cleanup_sighand;
 	p->semundo = NULL;
Index: 0-test8-pre1.1/include/linux/sched.h
--- 0-test8-pre1.1/include/linux/sched.h Tue, 29 Aug 2000 15:22:12 +1100 kaos (linux-2.4/Z/49_sched.h 1.1.1.7.1.3 644)
+++ 0-test8-pre1.1(w)/include/linux/sched.h Sat, 02 Sep 2000 11:45:41 +1100 kaos (linux-2.4/Z/49_sched.h 1.1.1.7.1.3 644)
@@ -708,7 +708,7 @@
 extern int expand_fdset(struct files_struct *, int nr);
 extern void free_fdset(fd_set *, int);
 
-extern int  copy_thread(int, unsigned long, unsigned long, struct task_struct *, struct pt_regs *);
+extern int  copy_thread(int, unsigned long, unsigned long, unsigned long, struct task_struct *, struct pt_regs *);
 extern void flush_thread(void);
 extern void exit_thread(void);
 
@@ -719,7 +719,7 @@
 extern void daemonize(void);
 
 extern int do_execve(char *, char **, char **, struct pt_regs *);
-extern int do_fork(unsigned long, unsigned long, struct pt_regs *);
+extern int do_fork(unsigned long, unsigned long, unsigned long, struct pt_regs *);
 
 extern void FASTCALL(add_wait_queue(wait_queue_head_t *q, wait_queue_t * wait));
 extern void FASTCALL(add_wait_queue_exclusive(wait_queue_head_t *q, wait_queue_t * wait));
Index: 0-test8-pre1.1/arch/s390/kernel/smp.c
--- 0-test8-pre1.1/arch/s390/kernel/smp.c Tue, 11 Jul 2000 11:25:12 +1000 kaos (linux-2.4/Y/b/24_smp.c 1.2 644)
+++ 0-test8-pre1.1(w)/arch/s390/kernel/smp.c Sat, 02 Sep 2000 11:30:29 +1100 kaos (linux-2.4/Y/b/24_smp.c 1.2 644)
@@ -528,7 +528,7 @@
        /* don't care about the psw and regs settings since we'll never
           reschedule the forked task. */
        memset(&regs,sizeof(pt_regs),0);
-       return do_fork(CLONE_VM|CLONE_PID, 0, &regs);
+       return do_fork(CLONE_VM|CLONE_PID, 0, 0, &regs);
 }
 
 static void __init do_boot_cpu(int cpu)
Index: 0-test8-pre1.1/arch/s390/kernel/process.c
--- 0-test8-pre1.1/arch/s390/kernel/process.c Sat, 05 Aug 2000 13:33:35 +1000 kaos (linux-2.4/Y/b/35_process.c 1.2.1.1 644)
+++ 0-test8-pre1.1(w)/arch/s390/kernel/process.c Sat, 02 Sep 2000 11:30:29 +1100 kaos (linux-2.4/Y/b/35_process.c 1.2.1.1 644)
@@ -264,6 +264,7 @@
 }
 
 int copy_thread(int nr, unsigned long clone_flags, unsigned long new_stackp,
+	unsigned long unused,
         struct task_struct * p, struct pt_regs * regs)
 {
         struct stack_frame
@@ -313,7 +314,7 @@
         int ret;
 
         lock_kernel();
-        ret = do_fork(SIGCHLD, regs.gprs[15], &regs);
+        ret = do_fork(SIGCHLD, regs.gprs[15], 0, &regs);
         unlock_kernel();
         return ret;
 }
@@ -329,7 +330,7 @@
         newsp = regs.gprs[2];
         if (!newsp)
                 newsp = regs.gprs[15];
-        ret = do_fork(clone_flags, newsp, &regs);
+        ret = do_fork(clone_flags, newsp, 0, &regs);
         unlock_kernel();
         return ret;
 }
@@ -347,7 +348,7 @@
 asmlinkage int sys_vfork(struct pt_regs regs)
 {
 	return do_fork(CLONE_VFORK | CLONE_VM | SIGCHLD,
-                       regs.gprs[15], &regs);
+                       regs.gprs[15], 0, &regs);
 }
 
 /*
Index: 0-test8-pre1.1/arch/mips64/kernel/syscall.c
--- 0-test8-pre1.1/arch/mips64/kernel/syscall.c Tue, 01 Aug 2000 16:55:46 +1000 kaos (linux-2.4/a/c/16_syscall.c 1.1.1.4 644)
+++ 0-test8-pre1.1(w)/arch/mips64/kernel/syscall.c Sat, 02 Sep 2000 11:30:29 +1100 kaos (linux-2.4/a/c/16_syscall.c 1.1.1.4 644)
@@ -77,7 +77,7 @@
 	int res;
 
 	save_static(&regs);
-	res = do_fork(SIGCHLD, regs.regs[29], &regs);
+	res = do_fork(SIGCHLD, regs.regs[29], 0, &regs);
 	return res;
 }
 
@@ -92,7 +92,7 @@
 	newsp = regs.regs[5];
 	if (!newsp)
 		newsp = regs.regs[29];
-	res = do_fork(clone_flags, newsp, &regs);
+	res = do_fork(clone_flags, newsp, 0, &regs);
 	return res;
 }
 
Index: 0-test8-pre1.1/arch/mips64/kernel/process.c
--- 0-test8-pre1.1/arch/mips64/kernel/process.c Thu, 13 Jul 2000 18:35:31 +1000 kaos (linux-2.4/a/c/31_process.c 1.5 644)
+++ 0-test8-pre1.1(w)/arch/mips64/kernel/process.c Sat, 02 Sep 2000 11:30:29 +1100 kaos (linux-2.4/a/c/31_process.c 1.5 644)
@@ -69,6 +69,7 @@
 }
 
 int copy_thread(int nr, unsigned long clone_flags, unsigned long usp,
+		 unsigned long unused,
                  struct task_struct * p, struct pt_regs * regs)
 {
 	struct pt_regs * childregs;
Index: 0-test8-pre1.1/arch/sh/kernel/process.c
--- 0-test8-pre1.1/arch/sh/kernel/process.c Sat, 22 Jul 2000 18:25:55 +1000 kaos (linux-2.4/d/c/21_process.c 1.1.1.3 644)
+++ 0-test8-pre1.1(w)/arch/sh/kernel/process.c Sat, 02 Sep 2000 11:30:29 +1100 kaos (linux-2.4/d/c/21_process.c 1.1.1.3 644)
@@ -211,6 +211,7 @@
 asmlinkage void ret_from_fork(void);
 
 int copy_thread(int nr, unsigned long clone_flags, unsigned long usp,
+		unsigned long unused,
 		struct task_struct *p, struct pt_regs *regs)
 {
 	struct pt_regs *childregs;
@@ -292,7 +293,7 @@
 			unsigned long r6, unsigned long r7,
 			struct pt_regs regs)
 {
-	return do_fork(SIGCHLD, regs.regs[15], &regs);
+	return do_fork(SIGCHLD, regs.regs[15], 0, &regs);
 }
 
 asmlinkage int sys_clone(unsigned long clone_flags, unsigned long newsp,
@@ -301,7 +302,7 @@
 {
 	if (!newsp)
 		newsp = regs.regs[15];
-	return do_fork(clone_flags, newsp, &regs);
+	return do_fork(clone_flags, newsp, 0, &regs);
 }
 
 /*
@@ -318,7 +319,7 @@
 			 unsigned long r6, unsigned long r7,
 			 struct pt_regs regs)
 {
-	return do_fork(CLONE_VFORK | CLONE_VM | SIGCHLD, regs.regs[15], &regs);
+	return do_fork(CLONE_VFORK | CLONE_VM | SIGCHLD, regs.regs[15], 0, &regs);
 }
 
 /*
Index: 0-test8-pre1.1/arch/arm/kernel/process.c
--- 0-test8-pre1.1/arch/arm/kernel/process.c Tue, 15 Aug 2000 17:59:12 +1000 kaos (linux-2.4/f/c/43_process.c 1.1.1.5 644)
+++ 0-test8-pre1.1(w)/arch/arm/kernel/process.c Sat, 02 Sep 2000 11:30:29 +1100 kaos (linux-2.4/f/c/43_process.c 1.1.1.5 644)
@@ -291,6 +291,7 @@
 }
 
 int copy_thread(int nr, unsigned long clone_flags, unsigned long esp,
+	unsigned long unused,
 	struct task_struct * p, struct pt_regs * regs)
 {
 	struct pt_regs * childregs;
Index: 0-test8-pre1.1/arch/arm/kernel/sys_arm.c
--- 0-test8-pre1.1/arch/arm/kernel/sys_arm.c Wed, 19 Jul 2000 17:53:13 +1000 kaos (linux-2.4/f/c/50_sys_arm.c 1.4 644)
+++ 0-test8-pre1.1(w)/arch/arm/kernel/sys_arm.c Sat, 02 Sep 2000 11:30:29 +1100 kaos (linux-2.4/f/c/50_sys_arm.c 1.4 644)
@@ -203,7 +203,7 @@
  */
 asmlinkage int sys_fork(struct pt_regs *regs)
 {
-	return do_fork(SIGCHLD, regs->ARM_sp, regs);
+	return do_fork(SIGCHLD, regs->ARM_sp, 0, regs);
 }
 
 /* Clone a task - this clones the calling program thread.
@@ -213,12 +213,12 @@
 {
 	if (!newsp)
 		newsp = regs->ARM_sp;
-	return do_fork(clone_flags, newsp, regs);
+	return do_fork(clone_flags, newsp, 0, regs);
 }
 
 asmlinkage int sys_vfork(struct pt_regs *regs)
 {
-	return do_fork(CLONE_VFORK | CLONE_VM | SIGCHLD, regs->ARM_sp, regs);
+	return do_fork(CLONE_VFORK | CLONE_VM | SIGCHLD, regs->ARM_sp, 0, regs);
 }
 
 /* sys_execve() executes a new program.
Index: 0-test8-pre1.1/arch/sparc64/kernel/entry.S
--- 0-test8-pre1.1/arch/sparc64/kernel/entry.S Sat, 05 Aug 2000 13:33:35 +1000 kaos (linux-2.4/i/c/20_entry.S 1.1.1.3 644)
+++ 0-test8-pre1.1(w)/arch/sparc64/kernel/entry.S Sat, 02 Sep 2000 11:30:29 +1100 kaos (linux-2.4/i/c/20_entry.S 1.1.1.3 644)
@@ -911,7 +911,7 @@
 		mov		SIGCHLD, %o0
 sys_clone:	flushw
 		movrz		%o1, %fp, %o1
-		nop
+		mov		0, %o3
 		ba,pt		%xcc, do_fork
 		 add		%sp, STACK_BIAS + REGWIN_SZ, %o2
 ret_from_syscall:
Index: 0-test8-pre1.1/arch/sparc64/kernel/process.c
--- 0-test8-pre1.1/arch/sparc64/kernel/process.c Thu, 24 Aug 2000 03:13:10 +1000 kaos (linux-2.4/i/c/25_process.c 1.6 644)
+++ 0-test8-pre1.1(w)/arch/sparc64/kernel/process.c Sat, 02 Sep 2000 11:30:29 +1100 kaos (linux-2.4/i/c/25_process.c 1.6 644)
@@ -573,6 +573,7 @@
  *       do_fork().
  */
 int copy_thread(int nr, unsigned long clone_flags, unsigned long sp,
+		unsigned long unused,
 		struct task_struct *p, struct pt_regs *regs)
 {
 	struct thread_struct *t = &p->thread;
Index: 0-test8-pre1.1/arch/m68k/kernel/process.c
--- 0-test8-pre1.1/arch/m68k/kernel/process.c Tue, 11 Jul 2000 11:25:12 +1000 kaos (linux-2.4/l/c/42_process.c 1.2 644)
+++ 0-test8-pre1.1(w)/arch/m68k/kernel/process.c Sat, 02 Sep 2000 11:30:29 +1100 kaos (linux-2.4/l/c/42_process.c 1.2 644)
@@ -181,12 +181,12 @@
 
 asmlinkage int m68k_fork(struct pt_regs *regs)
 {
-	return do_fork(SIGCHLD, rdusp(), regs);
+	return do_fork(SIGCHLD, rdusp(), 0, regs);
 }
 
 asmlinkage int m68k_vfork(struct pt_regs *regs)
 {
-	return do_fork(CLONE_VFORK | CLONE_VM | SIGCHLD, rdusp(), regs);
+	return do_fork(CLONE_VFORK | CLONE_VM | SIGCHLD, rdusp(), 0, regs);
 }
 
 asmlinkage int m68k_clone(struct pt_regs *regs)
@@ -199,10 +199,11 @@
 	newsp = regs->d2;
 	if (!newsp)
 		newsp = rdusp();
-	return do_fork(clone_flags, newsp, regs);
+	return do_fork(clone_flags, newsp, 0, regs);
 }
 
 int copy_thread(int nr, unsigned long clone_flags, unsigned long usp,
+		 unsigned long unused,
 		 struct task_struct * p, struct pt_regs * regs)
 {
 	struct pt_regs * childregs;
Index: 0-test8-pre1.1/arch/ppc/kernel/smp.c
--- 0-test8-pre1.1/arch/ppc/kernel/smp.c Fri, 14 Jul 2000 19:35:46 +1000 kaos (linux-2.4/q/c/36_smp.c 1.1.1.3 644)
+++ 0-test8-pre1.1(w)/arch/ppc/kernel/smp.c Sat, 02 Sep 2000 11:30:29 +1100 kaos (linux-2.4/q/c/36_smp.c 1.1.1.3 644)
@@ -347,7 +347,7 @@
 		/* create a process for the processor */
 		/* we don't care about the values in regs since we'll
 		   never reschedule the forked task. */
-		if (do_fork(CLONE_VM|CLONE_PID, 0, &regs) < 0)
+		if (do_fork(CLONE_VM|CLONE_PID, 0, 0, &regs) < 0)
 			panic("failed fork for CPU %d", i);
 		p = init_task.prev_task;
 		if (!p)
Index: 0-test8-pre1.1/arch/ppc/kernel/process.c
--- 0-test8-pre1.1/arch/ppc/kernel/process.c Wed, 21 Jun 2000 12:24:29 +1000 kaos (linux-2.4/r/c/11_process.c 1.1.1.1 644)
+++ 0-test8-pre1.1(w)/arch/ppc/kernel/process.c Sat, 02 Sep 2000 11:30:29 +1100 kaos (linux-2.4/r/c/11_process.c 1.1.1.1 644)
@@ -315,6 +315,7 @@
  */
 int
 copy_thread(int nr, unsigned long clone_flags, unsigned long usp,
+	    unsigned long unused,
 	    struct task_struct * p, struct pt_regs * regs)
 {
 	unsigned long msr;
@@ -446,7 +447,7 @@
 	unsigned long clone_flags = p1;
 	int res;
 	lock_kernel();
-	res = do_fork(clone_flags, regs->gpr[1], regs);
+	res = do_fork(clone_flags, regs->gpr[1], 0, regs);
 #ifdef CONFIG_SMP
 	/* When we clone the idle task we keep the same pid but
 	 * the return value of 0 for both causes problems.
@@ -465,7 +466,7 @@
 
 	int res;
 	
-	res = do_fork(SIGCHLD, regs->gpr[1], regs);
+	res = do_fork(SIGCHLD, regs->gpr[1], 0, regs);
 #ifdef CONFIG_SMP
 	/* When we clone the idle task we keep the same pid but
 	 * the return value of 0 for both causes problems.
@@ -480,7 +481,7 @@
 asmlinkage int sys_vfork(int p1, int p2, int p3, int p4, int p5, int p6,
 			 struct pt_regs *regs)
 {
-	return do_fork(CLONE_VFORK | CLONE_VM | SIGCHLD, regs->gpr[1], regs);
+	return do_fork(CLONE_VFORK | CLONE_VM | SIGCHLD, regs->gpr[1], 0, regs);
 }
 
 asmlinkage int sys_execve(unsigned long a0, unsigned long a1, unsigned long a2,
Index: 0-test8-pre1.1/arch/mips/kernel/syscall.c
--- 0-test8-pre1.1/arch/mips/kernel/syscall.c Tue, 11 Jul 2000 00:21:05 +1000 kaos (linux-2.4/u/c/17_syscall.c 1.3 644)
+++ 0-test8-pre1.1(w)/arch/mips/kernel/syscall.c Sat, 02 Sep 2000 11:30:29 +1100 kaos (linux-2.4/u/c/17_syscall.c 1.3 644)
@@ -97,7 +97,7 @@
 	int res;
 
 	save_static(&regs);
-	res = do_fork(SIGCHLD, regs.regs[29], &regs);
+	res = do_fork(SIGCHLD, regs.regs[29], 0, &regs);
 	return res;
 }
 
@@ -112,7 +112,7 @@
 	newsp = regs.regs[5];
 	if (!newsp)
 		newsp = regs.regs[29];
-	res = do_fork(clone_flags, newsp, &regs);
+	res = do_fork(clone_flags, newsp, 0, &regs);
 	return res;
 }
 
Index: 0-test8-pre1.1/arch/mips/kernel/process.c
--- 0-test8-pre1.1/arch/mips/kernel/process.c Tue, 11 Jul 2000 11:25:12 +1000 kaos (linux-2.4/u/c/26_process.c 1.2 644)
+++ 0-test8-pre1.1(w)/arch/mips/kernel/process.c Sat, 02 Sep 2000 11:30:29 +1100 kaos (linux-2.4/u/c/26_process.c 1.2 644)
@@ -72,6 +72,7 @@
 }
 
 int copy_thread(int nr, unsigned long clone_flags, unsigned long usp,
+		 unsigned long unused,
                  struct task_struct * p, struct pt_regs * regs)
 {
 	struct pt_regs * childregs;
Index: 0-test8-pre1.1/arch/sparc/kernel/process.c
--- 0-test8-pre1.1/arch/sparc/kernel/process.c Wed, 12 Jul 2000 11:58:08 +1000 kaos (linux-2.4/w/c/50_process.c 1.4 644)
+++ 0-test8-pre1.1(w)/arch/sparc/kernel/process.c Sat, 02 Sep 2000 11:30:29 +1100 kaos (linux-2.4/w/c/50_process.c 1.4 644)
@@ -462,6 +462,7 @@
 #endif
 
 int copy_thread(int nr, unsigned long clone_flags, unsigned long sp,
+		unsigned long unused,
 		struct task_struct *p, struct pt_regs *regs)
 {
 	struct pt_regs *childregs;
Index: 0-test8-pre1.1/arch/sparc/kernel/entry.S
--- 0-test8-pre1.1/arch/sparc/kernel/entry.S Wed, 21 Jun 2000 12:24:29 +1000 kaos (linux-2.4/x/c/6_entry.S 1.1.1.1 644)
+++ 0-test8-pre1.1(w)/arch/sparc/kernel/entry.S Sat, 02 Sep 2000 11:30:29 +1100 kaos (linux-2.4/x/c/6_entry.S 1.1.1.1 644)
@@ -1391,6 +1391,7 @@
 	mov	%fp, %o1			! arg1:	usp
 	std	%g4, [%curptr + AOFF_task_thread + AOFF_thread_fork_kpsr]
 	add	%sp, REGWIN_SZ, %o2		! arg2:	pt_regs ptr
+	mov	0, %o3
 	call	C_LABEL(do_fork)
 	 mov	%l5, %o7
 	
@@ -1413,6 +1414,7 @@
 1:
 	std	%g4, [%curptr + AOFF_task_thread + AOFF_thread_fork_kpsr]
 	add	%sp, REGWIN_SZ, %o2		! arg2:	pt_regs ptr
+	mov	0, %o3
 	call	C_LABEL(do_fork)
 	 mov	%l5, %o7
 
@@ -1430,6 +1432,7 @@
 	mov	%fp, %o1
 	or	%o0, %lo(0x4000 | 0x0100 | SIGCHLD), %o0
 	sethi	%hi(C_LABEL(do_fork)), %l1
+	mov	0, %o3
 	jmpl	%l1 + %lo(C_LABEL(do_fork)), %g0
 	 add	%sp, REGWIN_SZ, %o2
 
Index: 0-test8-pre1.1/arch/alpha/kernel/smp.c
--- 0-test8-pre1.1/arch/alpha/kernel/smp.c Sat, 05 Aug 2000 13:33:35 +1000 kaos (linux-2.4/y/c/9_smp.c 1.1.1.2.1.2 644)
+++ 0-test8-pre1.1(w)/arch/alpha/kernel/smp.c Sat, 02 Sep 2000 11:30:29 +1100 kaos (linux-2.4/y/c/9_smp.c 1.1.1.2.1.2 644)
@@ -420,7 +420,7 @@
 	 * don't care about the regs settings since
 	 * we'll never reschedule the forked task.
 	 */
-	return do_fork(CLONE_VM|CLONE_PID, 0, &regs);
+	return do_fork(CLONE_VM|CLONE_PID, 0, 0, &regs);
 }
 
 /*
Index: 0-test8-pre1.1/arch/alpha/kernel/process.c
--- 0-test8-pre1.1/arch/alpha/kernel/process.c Tue, 11 Jul 2000 11:25:12 +1000 kaos (linux-2.4/y/c/13_process.c 1.2 644)
+++ 0-test8-pre1.1(w)/arch/alpha/kernel/process.c Sat, 02 Sep 2000 11:30:29 +1100 kaos (linux-2.4/y/c/13_process.c 1.2 644)
@@ -276,14 +276,14 @@
 {
 	if (!usp)
 		usp = rdusp();
-	return do_fork(clone_flags, usp, (struct pt_regs *) (swstack+1));
+	return do_fork(clone_flags, usp, 0, (struct pt_regs *) (swstack+1));
 }
 
 int
 alpha_vfork(struct switch_stack * swstack)
 {
 	return do_fork(CLONE_VFORK | CLONE_VM | SIGCHLD, rdusp(),
-			(struct pt_regs *) (swstack+1));
+			0, (struct pt_regs *) (swstack+1));
 }
 
 /*
@@ -299,6 +299,7 @@
 
 int
 copy_thread(int nr, unsigned long clone_flags, unsigned long usp,
+	    unsigned long unused,
 	    struct task_struct * p, struct pt_regs * regs)
 {
 	extern void ret_from_sys_call(void);
Index: 0-test8-pre1.1/arch/i386/kernel/smpboot.c
--- 0-test8-pre1.1/arch/i386/kernel/smpboot.c Thu, 24 Aug 2000 03:13:10 +1000 kaos (linux-2.4/z/c/29_smpboot.c 1.1.1.2 644)
+++ 0-test8-pre1.1(w)/arch/i386/kernel/smpboot.c Sat, 02 Sep 2000 11:30:30 +1100 kaos (linux-2.4/z/c/29_smpboot.c 1.1.1.2 644)
@@ -497,7 +497,7 @@
 	 * don't care about the eip and regs settings since
 	 * we'll never reschedule the forked task.
 	 */
-	return do_fork(CLONE_VM|CLONE_PID, 0, &regs);
+	return do_fork(CLONE_VM|CLONE_PID, 0, 0, &regs);
 }
 
 #if APIC_DEBUG
Index: 0-test8-pre1.1/arch/i386/kernel/process.c
--- 0-test8-pre1.1/arch/i386/kernel/process.c Tue, 11 Jul 2000 11:25:12 +1000 kaos (linux-2.4/z/c/47_process.c 1.1.2.3.1.1.1.2 644)
+++ 0-test8-pre1.1(w)/arch/i386/kernel/process.c Sat, 02 Sep 2000 11:31:25 +1100 kaos (linux-2.4/z/c/47_process.c 1.1.2.3.1.1.1.2 644)
@@ -525,6 +525,7 @@
 	asm volatile("movl %%" #seg ",%0":"=m" (*(int *)&(value)))
 
 int copy_thread(int nr, unsigned long clone_flags, unsigned long esp,
+	unsigned long unused,
 	struct task_struct * p, struct pt_regs * regs)
 {
 	struct pt_regs * childregs;
@@ -686,7 +687,7 @@
 
 asmlinkage int sys_fork(struct pt_regs regs)
 {
-	return do_fork(SIGCHLD, regs.esp, &regs);
+	return do_fork(SIGCHLD, regs.esp, 0, &regs);
 }
 
 asmlinkage int sys_clone(struct pt_regs regs)
@@ -698,7 +699,7 @@
 	newsp = regs.ecx;
 	if (!newsp)
 		newsp = regs.esp;
-	return do_fork(clone_flags, newsp, &regs);
+	return do_fork(clone_flags, newsp, 0, &regs);
 }
 
 /*
@@ -713,7 +714,7 @@
  */
 asmlinkage int sys_vfork(struct pt_regs regs)
 {
-	return do_fork(CLONE_VFORK | CLONE_VM | SIGCHLD, regs.esp, &regs);
+	return do_fork(CLONE_VFORK | CLONE_VM | SIGCHLD, regs.esp, 0, &regs);
 }
 
 /*


