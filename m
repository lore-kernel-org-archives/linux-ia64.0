From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 05 Oct 2004 10:04:10 +0000
Subject: sparse minimal enablement (__user annotations)
Message-Id: <200410051004.i95A4Ale001185@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony,

The patch should be safe, even though the changes to uaccess.h are
not 100% trivial.  I did boot-test it and run my mini test-suite
(which would catch uaccess.h failures etc.).  Note: I left off any
changes to the ia32 subsystem.  I'll send those separately to
Arun.

Please apply.

	--david

ia64: minimal sparse-enablement; add __user annotations

This enables sparse for ia64 and adds a basic set of __user
annotations.  Apart for sys_execve() and the uaccess.h changes, the
patch is trivially safe.  Also note that in gcc_intrin.h, I
changed "asm __volatile" to "asm volatile" since sparse didn't
like the old version (and it's a "strane" version anyhow).
Patch has been (boot) tested.

Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>

 arch/ia64/Makefile                |    2 
 arch/ia64/kernel/irq.c            |    2 
 arch/ia64/kernel/perfmon.c        |    6 +-
 arch/ia64/kernel/process.c        |   16 +++---
 arch/ia64/kernel/ptrace.c         |    8 +--
 arch/ia64/kernel/salinfo.c        |    6 +-
 arch/ia64/kernel/sigframe.h       |    2 
 arch/ia64/kernel/signal.c         |   26 +++++------
 arch/ia64/kernel/sys_ia64.c       |    2 
 arch/ia64/kernel/traps.c          |   25 +++++-----
 arch/ia64/kernel/unaligned.c      |   16 +++---
 arch/ia64/kernel/unwind.c         |    2 
 arch/ia64/lib/csum_partial_copy.c |    4 -
 arch/ia64/mm/fault.c              |    2 
 arch/ia64/mm/init.c               |    4 -
 include/asm-ia64/compat.h         |    8 +--
 include/asm-ia64/gcc_intrin.h     |   24 +++++-----
 include/asm-ia64/processor.h      |    4 -
 include/asm-ia64/siginfo.h        |    2 
 include/asm-ia64/signal.h         |    4 -
 include/asm-ia64/uaccess.h        |   87 ++++++++++++++++++++++++--------------
 include/asm-ia64/unistd.h         |    4 -
 22 files changed, 142 insertions(+), 114 deletions(-)

=== arch/ia64/Makefile 1.68 vs edited ==--- 1.68/arch/ia64/Makefile	2004-09-13 11:55:33 -07:00
+++ edited/arch/ia64/Makefile	2004-10-01 09:05:45 -07:00
@@ -13,6 +13,8 @@
 
 export AWK
 
+CHECKFLAGS	+= -m64 -D__ia64=1 -D__ia64__=1 -D_LP64 -D__LP64__
+
 OBJCOPYFLAGS	:= --strip-all
 LDFLAGS_vmlinux	:= -static
 LDFLAGS_MODULE	+= -T $(srctree)/arch/ia64/module.lds
=== arch/ia64/kernel/irq.c 1.48 vs edited ==--- 1.48/arch/ia64/kernel/irq.c	2004-09-08 13:05:16 -07:00
+++ edited/arch/ia64/kernel/irq.c	2004-10-05 01:44:16 -07:00
@@ -966,7 +966,7 @@
 	return len;
 }
 
-static int irq_affinity_write_proc (struct file *file, const char *buffer,
+static int irq_affinity_write_proc (struct file *file, const char __user *buffer,
 				    unsigned long count, void *data)
 {
 	unsigned int irq = (unsigned long) data;
=== arch/ia64/kernel/perfmon.c 1.90 vs edited ==--- 1.90/arch/ia64/kernel/perfmon.c	2004-09-03 07:54:08 -07:00
+++ edited/arch/ia64/kernel/perfmon.c	2004-10-04 06:15:29 -07:00
@@ -1513,7 +1513,7 @@
 }
 
 static ssize_t
-pfm_read(struct file *filp, char *buf, size_t size, loff_t *ppos)
+pfm_read(struct file *filp, char __user *buf, size_t size, loff_t *ppos)
 {
 	pfm_context_t *ctx;
 	pfm_msg_t *msg;
@@ -1606,7 +1606,7 @@
 }
 
 static ssize_t
-pfm_write(struct file *file, const char *ubuf,
+pfm_write(struct file *file, const char __user *ubuf,
 			  size_t size, loff_t *ppos)
 {
 	DPRINT(("pfm_write called\n"));
@@ -4796,7 +4796,7 @@
  * system-call entry point (must return long)
  */
 asmlinkage long
-sys_perfmonctl (int fd, int cmd, void *arg, int count, long arg5, long arg6, long arg7,
+sys_perfmonctl (int fd, int cmd, void __user *arg, int count, long arg5, long arg6, long arg7,
 		long arg8, long stack)
 {
 	struct pt_regs *regs = (struct pt_regs *)&stack;
=== arch/ia64/kernel/process.c 1.63 vs edited ==--- 1.63/arch/ia64/kernel/process.c	2004-09-17 00:07:02 -07:00
+++ edited/arch/ia64/kernel/process.c	2004-10-05 01:44:16 -07:00
@@ -138,7 +138,7 @@
 		ndirty = (regs->loadrs >> 19);
 		bsp = ia64_rse_skip_regs((unsigned long *) regs->ar_bspstore, ndirty);
 		for (i = 0; i < sof; ++i) {
-			get_user(val, ia64_rse_skip_regs(bsp, i));
+			get_user(val, (unsigned long __user *) ia64_rse_skip_regs(bsp, i));
 			printk("r%-3u:%c%016lx%s", 32 + i, is_nat ? '*' : ' ', val,
 			       ((i = sof - 1) || (i % 3) = 2) ? "\n" : " ");
 		}
@@ -610,16 +610,18 @@
 }
 
 asmlinkage long
-sys_execve (char *filename, char **argv, char **envp, struct pt_regs *regs)
+sys_execve (char __user *filename, char __user * __user *argv, char __user * __user *envp,
+	    struct pt_regs *regs)
 {
+	char *fname;
 	int error;
 
-	filename = getname(filename);
-	error = PTR_ERR(filename);
-	if (IS_ERR(filename))
+	fname = getname(filename);
+	error = PTR_ERR(fname);
+	if (IS_ERR(fname))
 		goto out;
-	error = do_execve(filename, argv, envp, regs);
-	putname(filename);
+	error = do_execve(fname, argv, envp, regs);
+	putname(fname);
 out:
 	return error;
 }
=== arch/ia64/kernel/ptrace.c 1.35 vs edited ==--- 1.35/arch/ia64/kernel/ptrace.c	2004-07-09 22:11:26 -07:00
+++ edited/arch/ia64/kernel/ptrace.c	2004-10-05 02:11:19 -07:00
@@ -152,7 +152,7 @@
 		ri = 0;
 		regs->cr_iip += 16;
 	} else if (ri = 2) {
-		get_user(w0, (char *) regs->cr_iip + 0);
+		get_user(w0, (char __user *) regs->cr_iip + 0);
 		if (((w0 >> 1) & 0xf) = IA64_MLX_TEMPLATE) {
 			/*
 			 * rfi'ing to slot 2 of an MLX bundle causes
@@ -174,7 +174,7 @@
 	if (ia64_psr(regs)->ri = 0) {
 		regs->cr_iip -= 16;
 		ri = 2;
-		get_user(w0, (char *) regs->cr_iip + 0);
+		get_user(w0, (char __user *) regs->cr_iip + 0);
 		if (((w0 >> 1) & 0xf) = IA64_MLX_TEMPLATE) {
 			/*
 			 * rfi'ing to slot 2 of an MLX bundle causes
@@ -1429,11 +1458,11 @@
 		goto out_tsk;
 
 	      case PTRACE_GETREGS:
-		ret = ptrace_getregs(child, (struct pt_all_user_regs*) data);
+		ret = ptrace_getregs(child, (struct pt_all_user_regs __user *) data);
 		goto out_tsk;
 
 	      case PTRACE_SETREGS:
-		ret = ptrace_setregs(child, (struct pt_all_user_regs*) data);
+		ret = ptrace_setregs(child, (struct pt_all_user_regs __user *) data);
 		goto out_tsk;
 
 	      default:
=== arch/ia64/kernel/salinfo.c 1.10 vs edited ==--- 1.10/arch/ia64/kernel/salinfo.c	2004-09-23 16:12:16 -07:00
+++ edited/arch/ia64/kernel/salinfo.c	2004-10-04 06:16:45 -07:00
@@ -268,7 +268,7 @@
 }
 
 static ssize_t
-salinfo_event_read(struct file *file, char *buffer, size_t count, loff_t *ppos)
+salinfo_event_read(struct file *file, char __user *buffer, size_t count, loff_t *ppos)
 {
 	struct inode *inode = file->f_dentry->d_inode;
 	struct proc_dir_entry *entry = PDE(inode);
@@ -426,7 +426,7 @@
 }
 
 static ssize_t
-salinfo_log_read(struct file *file, char *buffer, size_t count, loff_t *ppos)
+salinfo_log_read(struct file *file, char __user *buffer, size_t count, loff_t *ppos)
 {
 	struct inode *inode = file->f_dentry->d_inode;
 	struct proc_dir_entry *entry = PDE(inode);
@@ -483,7 +483,7 @@
 }
 
 static ssize_t
-salinfo_log_write(struct file *file, const char *buffer, size_t count, loff_t *ppos)
+salinfo_log_write(struct file *file, const char __user *buffer, size_t count, loff_t *ppos)
 {
 	struct inode *inode = file->f_dentry->d_inode;
 	struct proc_dir_entry *entry = PDE(inode);
=== arch/ia64/kernel/sigframe.h 1.4 vs edited ==--- 1.4/arch/ia64/kernel/sigframe.h	2003-02-10 18:28:00 -08:00
+++ edited/arch/ia64/kernel/sigframe.h	2004-10-04 07:55:28 -07:00
@@ -17,7 +17,7 @@
 	 * End of architected state.
 	 */
 
-	void *handler;			/* pointer to the plabel of the signal handler */
+	void __user *handler;		/* pointer to the plabel of the signal handler */
 	struct siginfo info;
 	struct sigcontext sc;
 };
=== arch/ia64/kernel/signal.c 1.43 vs edited ==--- 1.43/arch/ia64/kernel/signal.c	2004-08-25 10:13:41 -07:00
+++ edited/arch/ia64/kernel/signal.c	2004-10-05 01:44:16 -07:00
@@ -43,7 +43,7 @@
 #endif
 
 long
-ia64_rt_sigsuspend (sigset_t *uset, size_t sigsetsize, struct sigscratch *scr)
+ia64_rt_sigsuspend (sigset_t __user *uset, size_t sigsetsize, struct sigscratch *scr)
 {
 	sigset_t oldset, set;
 
@@ -84,7 +84,7 @@
 }
 
 asmlinkage long
-sys_sigaltstack (const stack_t *uss, stack_t *uoss, long arg2, long arg3, long arg4,
+sys_sigaltstack (const stack_t __user *uss, stack_t __user *uoss, long arg2, long arg3, long arg4,
 		 long arg5, long arg6, long arg7, long stack)
 {
 	struct pt_regs *pt = (struct pt_regs *) &stack;
@@ -93,7 +93,7 @@
 }
 
 static long
-restore_sigcontext (struct sigcontext *sc, struct sigscratch *scr)
+restore_sigcontext (struct sigcontext __user *sc, struct sigscratch *scr)
 {
 	unsigned long ip, flags, nat, um, cfm;
 	long err;
@@ -155,7 +155,7 @@
 }
 
 int
-copy_siginfo_to_user (siginfo_t *to, siginfo_t *from)
+copy_siginfo_to_user (siginfo_t __user *to, siginfo_t *from)
 {
 	if (!access_ok(VERIFY_WRITE, to, sizeof(siginfo_t)))
 		return -EFAULT;
@@ -211,12 +211,12 @@
 ia64_rt_sigreturn (struct sigscratch *scr)
 {
 	extern char ia64_strace_leave_kernel, ia64_leave_kernel;
-	struct sigcontext *sc;
+	struct sigcontext __user *sc;
 	struct siginfo si;
 	sigset_t set;
 	long retval;
 
-	sc = &((struct sigframe *) (scr->pt.r12 + 16))->sc;
+	sc = &((struct sigframe __user *) (scr->pt.r12 + 16))->sc;
 
 	/*
 	 * When we return to the previously executing context, r8 and r10 have already
@@ -281,7 +281,7 @@
  * trampoline starts.  Everything else is done at the user-level.
  */
 static long
-setup_sigcontext (struct sigcontext *sc, sigset_t *mask, struct sigscratch *scr)
+setup_sigcontext (struct sigcontext __user *sc, sigset_t *mask, struct sigscratch *scr)
 {
 	unsigned long flags = 0, ifs, cfm, nat;
 	long err;
@@ -352,7 +352,7 @@
 }
 
 static long
-force_sigsegv_info (int sig, void *addr)
+force_sigsegv_info (int sig, void __user *addr)
 {
 	unsigned long flags;
 	struct siginfo si;
@@ -387,14 +387,14 @@
 {
 	extern char __kernel_sigtramp[];
 	unsigned long tramp_addr, new_rbs = 0;
-	struct sigframe *frame;
+	struct sigframe __user *frame;
 	long err;
 
-	frame = (void *) scr->pt.r12;
+	frame = (void __user *) scr->pt.r12;
 	tramp_addr = (unsigned long) __kernel_sigtramp;
 	if ((ka->sa.sa_flags & SA_ONSTACK) && sas_ss_flags((unsigned long) frame) = 0) {
-		frame = (void *) ((current->sas_ss_sp + current->sas_ss_size)
-				  & ~(STACK_ALIGN - 1));
+		frame = (void __user *) ((current->sas_ss_sp + current->sas_ss_size)
+					 & ~(STACK_ALIGN - 1));
 		/*
 		 * We need to check for the register stack being on the signal stack
 		 * separately, because it's switched separately (memory stack is switched
@@ -403,7 +403,7 @@
 		if (!rbs_on_sig_stack(scr->pt.ar_bspstore))
 			new_rbs = (current->sas_ss_sp + sizeof(long) - 1) & ~(sizeof(long) - 1);
 	}
-	frame = (void *) frame - ((sizeof(*frame) + STACK_ALIGN - 1) & ~(STACK_ALIGN - 1));
+	frame = (void __user *) frame - ((sizeof(*frame) + STACK_ALIGN - 1) & ~(STACK_ALIGN - 1));
 
 	if (!access_ok(VERIFY_WRITE, frame, sizeof(*frame)))
 		return force_sigsegv_info(sig, frame);
=== arch/ia64/kernel/sys_ia64.c 1.29 vs edited ==--- 1.29/arch/ia64/kernel/sys_ia64.c	2004-04-05 09:16:24 -07:00
+++ edited/arch/ia64/kernel/sys_ia64.c	2004-10-05 01:44:16 -07:00
@@ -93,7 +93,7 @@
 }
 
 asmlinkage unsigned long
-ia64_shmat (int shmid, void *shmaddr, int shmflg)
+ia64_shmat (int shmid, void __user *shmaddr, int shmflg)
 {
 	unsigned long raddr;
 	int retval;
=== arch/ia64/kernel/traps.c 1.46 vs edited ==--- 1.46/arch/ia64/kernel/traps.c	2004-09-07 23:32:57 -07:00
+++ edited/arch/ia64/kernel/traps.c	2004-10-04 06:18:35 -07:00
@@ -112,7 +112,7 @@
 	int sig, code;
 
 	/* SIGILL, SIGFPE, SIGSEGV, and SIGBUS want these field initialized: */
-	siginfo.si_addr = (void *) (regs->cr_iip + ia64_psr(regs)->ri);
+	siginfo.si_addr = (void __user *) (regs->cr_iip + ia64_psr(regs)->ri);
 	siginfo.si_imm = break_num;
 	siginfo.si_flags = 0;		/* clear __ISR_VALID */
 	siginfo.si_isr = 0;
@@ -282,7 +282,7 @@
 	fault_ip = regs->cr_iip;
 	if (!fp_fault && (ia64_psr(regs)->ri = 0))
 		fault_ip -= 16;
-	if (copy_from_user(bundle, (void *) fault_ip, sizeof(bundle)))
+	if (copy_from_user(bundle, (void __user *) fault_ip, sizeof(bundle)))
 		return -1;
 
 	if (jiffies - last_time > 5*HZ)
@@ -312,7 +312,7 @@
 			siginfo.si_signo = SIGFPE;
 			siginfo.si_errno = 0;
 			siginfo.si_code = __SI_FAULT;	/* default code */
-			siginfo.si_addr = (void *) (regs->cr_iip + ia64_psr(regs)->ri);
+			siginfo.si_addr = (void __user *) (regs->cr_iip + ia64_psr(regs)->ri);
 			if (isr & 0x11) {
 				siginfo.si_code = FPE_FLTINV;
 			} else if (isr & 0x22) {
@@ -336,7 +336,7 @@
 			siginfo.si_signo = SIGFPE;
 			siginfo.si_errno = 0;
 			siginfo.si_code = __SI_FAULT;	/* default code */
-			siginfo.si_addr = (void *) (regs->cr_iip + ia64_psr(regs)->ri);
+			siginfo.si_addr = (void __user *) (regs->cr_iip + ia64_psr(regs)->ri);
 			if (isr & 0x880) {
 				siginfo.si_code = FPE_FLTOVF;
 			} else if (isr & 0x1100) {
@@ -383,7 +383,7 @@
 	memset(&si, 0, sizeof(si));
 	si.si_signo = SIGILL;
 	si.si_code = ILL_ILLOPC;
-	si.si_addr = (void *) (regs->cr_iip + ia64_psr(regs)->ri);
+	si.si_addr = (void __user *) (regs->cr_iip + ia64_psr(regs)->ri);
 	force_sig_info(SIGILL, &si, current);
 	rv.fkt = 0;
 	return rv;
@@ -445,18 +445,18 @@
 
 	      case 26: /* NaT Consumption */
 		if (user_mode(regs)) {
-			void *addr;
+			void __user *addr;
 
 			if (((isr >> 4) & 0xf) = 2) {
 				/* NaT page consumption */
 				sig = SIGSEGV;
 				code = SEGV_ACCERR;
-				addr = (void *) ifa;
+				addr = (void __user *) ifa;
 			} else {
 				/* register NaT consumption */
 				sig = SIGILL;
 				code = ILL_ILLOPN;
-				addr = (void *) (regs->cr_iip + ia64_psr(regs)->ri);
+				addr = (void __user *) (regs->cr_iip + ia64_psr(regs)->ri);
 			}
 			siginfo.si_signo = sig;
 			siginfo.si_code = code;
@@ -477,7 +477,7 @@
 			siginfo.si_signo = SIGILL;
 			siginfo.si_code = ILL_ILLOPN;
 			siginfo.si_errno = 0;
-			siginfo.si_addr = (void *) (regs->cr_iip + ia64_psr(regs)->ri);
+			siginfo.si_addr = (void __user *) (regs->cr_iip + ia64_psr(regs)->ri);
 			siginfo.si_imm = vector;
 			siginfo.si_flags = __ISR_VALID;
 			siginfo.si_isr = isr;
@@ -524,7 +524,7 @@
 		}
 		siginfo.si_signo = SIGTRAP;
 		siginfo.si_errno = 0;
-		siginfo.si_addr  = (void *) ifa;
+		siginfo.si_addr  = (void __user *) ifa;
 		siginfo.si_imm   = 0;
 		siginfo.si_flags = __ISR_VALID;
 		siginfo.si_isr   = isr;
@@ -538,7 +538,7 @@
 			siginfo.si_signo = SIGFPE;
 			siginfo.si_errno = 0;
 			siginfo.si_code = FPE_FLTINV;
-			siginfo.si_addr = (void *) (regs->cr_iip + ia64_psr(regs)->ri);
+			siginfo.si_addr = (void __user *) (regs->cr_iip + ia64_psr(regs)->ri);
 			siginfo.si_flags = __ISR_VALID;
 			siginfo.si_isr = isr;
 			siginfo.si_imm = 0;
@@ -565,7 +565,8 @@
 				siginfo.si_flags = 0;
 				siginfo.si_isr = 0;
 				siginfo.si_imm = 0;
-				siginfo.si_addr = (void *) (regs->cr_iip + ia64_psr(regs)->ri);
+				siginfo.si_addr = (void __user *)
+					(regs->cr_iip + ia64_psr(regs)->ri);
 				force_sig_info(SIGILL, &siginfo, current);
 				return;
 			}
=== arch/ia64/kernel/unaligned.c 1.21 vs edited ==--- 1.21/arch/ia64/kernel/unaligned.c	2004-04-12 10:54:18 -07:00
+++ edited/arch/ia64/kernel/unaligned.c	2004-10-05 01:44:16 -07:00
@@ -760,7 +760,7 @@
 		return -1;
 	}
 	/* this assumes little-endian byte-order: */
-	if (copy_from_user(&val, (void *) ifa, len))
+	if (copy_from_user(&val, (void __user *) ifa, len))
 		return -1;
 	setreg(ld.r1, val, 0, regs);
 
@@ -887,7 +887,7 @@
 	}
 
 	/* this assumes little-endian byte-order: */
-	if (copy_to_user((void *) ifa, &r2, len))
+	if (copy_to_user((void __user *) ifa, &r2, len))
 		return -1;
 
 	/*
@@ -1036,8 +1036,8 @@
 		 * This assumes little-endian byte-order.  Note that there is no "ldfpe"
 		 * instruction:
 		 */
-		if (copy_from_user(&fpr_init[0], (void *) ifa, len)
-		    || copy_from_user(&fpr_init[1], (void *) (ifa + len), len))
+		if (copy_from_user(&fpr_init[0], (void __user *) ifa, len)
+		    || copy_from_user(&fpr_init[1], (void __user *) (ifa + len), len))
 			return -1;
 
 		DPRINT("ld.r1=%d ld.imm=%d x6_sz=%d\n", ld.r1, ld.imm, ld.x6_sz);
@@ -1138,7 +1138,7 @@
 	 * See comments in ldX for descriptions on how the various loads are handled.
 	 */
 	if (ld.x6_op != 0x2) {
-		if (copy_from_user(&fpr_init, (void *) ifa, len))
+		if (copy_from_user(&fpr_init, (void __user *) ifa, len))
 			return -1;
 
 		DPRINT("ld.r1=%d x6_sz=%d\n", ld.r1, ld.x6_sz);
@@ -1230,7 +1230,7 @@
 	DDUMP("fpr_init =", &fpr_init, len);
 	DDUMP("fpr_final =", &fpr_final, len);
 
-	if (copy_to_user((void *) ifa, &fpr_final, len))
+	if (copy_to_user((void __user *) ifa, &fpr_final, len))
 		return -1;
 
 	/*
@@ -1351,7 +1351,7 @@
 	DPRINT("iip=%lx ifa=%lx isr=%lx (ei=%d, sp=%d)\n",
 	       regs->cr_iip, ifa, regs->cr_ipsr, ipsr->ri, ipsr->it);
 
-	if (__copy_from_user(bundle, (void *) regs->cr_iip, 16))
+	if (__copy_from_user(bundle, (void __user *) regs->cr_iip, 16))
 		goto failure;
 
 	/*
@@ -1496,7 +1496,7 @@
 	si.si_signo = SIGBUS;
 	si.si_errno = 0;
 	si.si_code = BUS_ADRALN;
-	si.si_addr = (void *) ifa;
+	si.si_addr = (void __user *) ifa;
 	si.si_flags = 0;
 	si.si_isr = 0;
 	si.si_imm = 0;
=== arch/ia64/kernel/unwind.c 1.42 vs edited ==--- 1.42/arch/ia64/kernel/unwind.c	2004-09-08 11:49:13 -07:00
+++ edited/arch/ia64/kernel/unwind.c	2004-10-05 02:11:19 -07:00
@@ -2299,7 +2299,7 @@
  *	EFAULT	BUF points outside your accessible address space.
  */
 asmlinkage long
-sys_getunwind (void *buf, size_t buf_size)
+sys_getunwind (void __user *buf, size_t buf_size)
 {
 	if (buf && buf_size >= unw.gate_table_size)
 		if (copy_to_user(buf, unw.gate_table, unw.gate_table_size) != 0)
=== arch/ia64/lib/csum_partial_copy.c 1.6 vs edited ==--- 1.6/arch/ia64/lib/csum_partial_copy.c	2003-10-17 22:51:39 -07:00
+++ edited/arch/ia64/lib/csum_partial_copy.c	2004-10-04 08:25:58 -07:00
@@ -105,7 +105,7 @@
 extern unsigned long do_csum(const unsigned char *, long);
 
 static unsigned int
-do_csum_partial_copy_from_user (const char *src, char *dst, int len,
+do_csum_partial_copy_from_user (const char __user *src, char *dst, int len,
 				unsigned int psum, int *errp)
 {
 	unsigned long result;
@@ -142,7 +142,7 @@
 }
 
 unsigned int
-csum_partial_copy_nocheck(const char *src, char *dst, int len, unsigned int sum)
+csum_partial_copy_nocheck(const char __user *src, char *dst, int len, unsigned int sum)
 {
 	return do_csum_partial_copy_from_user(src, dst, len, sum, NULL);
 }
=== arch/ia64/mm/fault.c 1.20 vs edited ==--- 1.20/arch/ia64/mm/fault.c	2004-09-07 23:32:57 -07:00
+++ edited/arch/ia64/mm/fault.c	2004-10-04 06:21:01 -07:00
@@ -196,7 +196,7 @@
 		si.si_signo = signal;
 		si.si_errno = 0;
 		si.si_code = code;
-		si.si_addr = (void *) address;
+		si.si_addr = (void __user *) address;
 		si.si_isr = isr;
 		si.si_flags = __ISR_VALID;
 		force_sig_info(signal, &si, current);
=== arch/ia64/mm/init.c 1.67 vs edited ==--- 1.67/arch/ia64/mm/init.c	2004-09-21 12:36:02 -07:00
+++ edited/arch/ia64/mm/init.c	2004-10-05 01:44:16 -07:00
@@ -460,9 +460,9 @@
 	char byte;
 	struct page *pg = pfn_to_page(pfn);
 
-	return     (__get_user(byte, (char *) pg) = 0)
+	return     (__get_user(byte, (char __user *) pg) = 0)
 		&& ((((u64)pg & PAGE_MASK) = (((u64)(pg + 1) - 1) & PAGE_MASK))
-			|| (__get_user(byte, (char *) (pg + 1) - 1) = 0));
+			|| (__get_user(byte, (char __user *) (pg + 1) - 1) = 0));
 }
 EXPORT_SYMBOL(ia64_pfn_valid);
 
=== include/asm-ia64/compat.h 1.16 vs edited ==--- 1.16/include/asm-ia64/compat.h	2004-03-15 06:23:36 -08:00
+++ edited/include/asm-ia64/compat.h	2004-10-04 06:35:07 -07:00
@@ -182,17 +182,17 @@
  */
 typedef	u32		compat_uptr_t;
 
-static inline void *
+static inline void __user *
 compat_ptr (compat_uptr_t uptr)
 {
-	return (void *) (unsigned long) uptr;
+	return (void __user *) (unsigned long) uptr;
 }
 
-static __inline__ void *
+static __inline__ void __user *
 compat_alloc_user_space (long len)
 {
 	struct pt_regs *regs = ia64_task_regs(current);
-	return (void *) (((regs->r12 & 0xffffffff) & -16) - len);
+	return (void __user *) (((regs->r12 & 0xffffffff) & -16) - len);
 }
 
 #endif /* _ASM_IA64_COMPAT_H */
=== include/asm-ia64/gcc_intrin.h 1.6 vs edited ==--- 1.6/include/asm-ia64/gcc_intrin.h	2004-06-17 15:45:17 -07:00
+++ edited/include/asm-ia64/gcc_intrin.h	2004-10-04 00:46:18 -07:00
@@ -259,35 +259,35 @@
 	ia64_intri_res;								\
 })
 
-#define ia64_xchg1(ptr,x)						\
-({									\
-	__u64 ia64_intri_res;						\
-	asm __volatile ("xchg1 %0=[%1],%2" : "=r" (ia64_intri_res)	\
-			    : "r" (ptr), "r" (x) : "memory");		\
-	ia64_intri_res;							\
+#define ia64_xchg1(ptr,x)							\
+({										\
+	__u64 ia64_intri_res;							\
+	asm volatile ("xchg1 %0=[%1],%2"					\
+		      : "=r" (ia64_intri_res) : "r" (ptr), "r" (x) : "memory");	\
+	ia64_intri_res;								\
 })
 
 #define ia64_xchg2(ptr,x)						\
 ({									\
 	__u64 ia64_intri_res;						\
-	asm __volatile ("xchg2 %0=[%1],%2" : "=r" (ia64_intri_res)	\
-			    : "r" (ptr), "r" (x) : "memory");		\
+	asm volatile ("xchg2 %0=[%1],%2" : "=r" (ia64_intri_res)	\
+		      : "r" (ptr), "r" (x) : "memory");			\
 	ia64_intri_res;							\
 })
 
 #define ia64_xchg4(ptr,x)						\
 ({									\
 	__u64 ia64_intri_res;						\
-	asm __volatile ("xchg4 %0=[%1],%2" : "=r" (ia64_intri_res)	\
-			    : "r" (ptr), "r" (x) : "memory");		\
+	asm volatile ("xchg4 %0=[%1],%2" : "=r" (ia64_intri_res)	\
+		      : "r" (ptr), "r" (x) : "memory");			\
 	ia64_intri_res;							\
 })
 
 #define ia64_xchg8(ptr,x)						\
 ({									\
 	__u64 ia64_intri_res;						\
-	asm __volatile ("xchg8 %0=[%1],%2" : "=r" (ia64_intri_res)	\
-			    : "r" (ptr), "r" (x) : "memory");		\
+	asm volatile ("xchg8 %0=[%1],%2" : "=r" (ia64_intri_res)	\
+		      : "r" (ptr), "r" (x) : "memory");			\
 	ia64_intri_res;							\
 })
 
=== include/asm-ia64/processor.h 1.62 vs edited ==--- 1.62/include/asm-ia64/processor.h	2004-08-24 02:08:09 -07:00
+++ edited/include/asm-ia64/processor.h	2004-10-05 02:11:19 -07:00
@@ -200,7 +200,7 @@
 #define GET_UNALIGN_CTL(task,addr)								\
 ({												\
 	put_user(((task)->thread.flags & IA64_THREAD_UAC_MASK) >> IA64_THREAD_UAC_SHIFT,	\
-		 (int *) (addr));								\
+		 (int __user *) (addr));							\
 })
 
 #define SET_FPEMU_CTL(task,value)								\
@@ -212,7 +212,7 @@
 #define GET_FPEMU_CTL(task,addr)								\
 ({												\
 	put_user(((task)->thread.flags & IA64_THREAD_FPEMU_MASK) >> IA64_THREAD_FPEMU_SHIFT,	\
-		 (int *) (addr));								\
+		 (int __user *) (addr));							\
 })
 
 #ifdef CONFIG_IA32_SUPPORT
=== include/asm-ia64/siginfo.h 1.18 vs edited ==--- 1.18/include/asm-ia64/siginfo.h	2004-09-15 11:38:30 -07:00
+++ edited/include/asm-ia64/siginfo.h	2004-10-04 05:20:07 -07:00
@@ -60,7 +60,7 @@
 
 		/* SIGILL, SIGFPE, SIGSEGV, SIGBUS */
 		struct {
-			void *_addr;		/* faulting insn/memory ref. */
+			void __user *_addr;	/* faulting insn/memory ref. */
 			int _imm;		/* immediate value for "break" */
 			unsigned int _flags;	/* see below */
 			unsigned long _isr;	/* isr */
=== include/asm-ia64/signal.h 1.13 vs edited ==--- 1.13/include/asm-ia64/signal.h	2004-05-22 01:23:18 -07:00
+++ edited/include/asm-ia64/signal.h	2004-10-04 07:57:30 -07:00
@@ -144,10 +144,10 @@
 struct siginfo;
 
 /* Type of a signal handler.  */
-typedef void (*__sighandler_t)(int);
+typedef void __user (*__sighandler_t)(int);
 
 typedef struct sigaltstack {
-	void *ss_sp;
+	void __user *ss_sp;
 	int ss_flags;
 	size_t ss_size;
 } stack_t;
=== include/asm-ia64/uaccess.h 1.20 vs edited ==--- 1.20/include/asm-ia64/uaccess.h	2004-08-27 00:02:37 -07:00
+++ edited/include/asm-ia64/uaccess.h	2004-10-04 05:18:15 -07:00
@@ -60,14 +60,17 @@
  * address TASK_SIZE is never valid.  We also need to make sure that the address doesn't
  * point inside the virtually mapped linear page table.
  */
-#define __access_ok(addr, size, segment)					\
-	(likely((unsigned long) (addr) <= (segment).seg)			\
-	 && ((segment).seg = KERNEL_DS.seg					\
-	     || likely(REGION_OFFSET((unsigned long) (addr)) < RGN_MAP_LIMIT)))
+#define __access_ok(addr, size, segment)						\
+({											\
+	__chk_user_ptr(addr);								\
+	(likely((unsigned long) (addr) <= (segment).seg)				\
+	 && ((segment).seg = KERNEL_DS.seg						\
+	     || likely(REGION_OFFSET((unsigned long) (addr)) < RGN_MAP_LIMIT)));	\
+})
 #define access_ok(type, addr, size)	__access_ok((addr), (size), get_fs())
 
 static inline int
-verify_area (int type, const void *addr, unsigned long size)
+verify_area (int type, const void __user *addr, unsigned long size)
 {
 	return access_ok(type, addr, size) ? 0 : -EFAULT;
 }
@@ -185,11 +188,11 @@
  */
 #define __do_get_user(check, x, ptr, size, segment)					\
 ({											\
-	const __typeof__(*(ptr)) *__gu_ptr = (ptr);					\
+	const __typeof__(*(ptr)) __user *__gu_ptr = (ptr);				\
 	__typeof__ (size) __gu_size = (size);						\
 	long __gu_err = -EFAULT, __gu_val = 0;						\
 											\
-	if (!check || __access_ok((long) __gu_ptr, size, segment))			\
+	if (!check || __access_ok(__gu_ptr, size, segment))				\
 		switch (__gu_size) {							\
 		      case 1: __get_user_size(__gu_val, __gu_ptr, 1, __gu_err); break;	\
 		      case 2: __get_user_size(__gu_val, __gu_ptr, 2, __gu_err); break;	\
@@ -213,11 +216,11 @@
 #define __do_put_user(check, x, ptr, size, segment)					\
 ({											\
 	__typeof__ (x) __pu_x = (x);							\
-	__typeof__ (*(ptr)) *__pu_ptr = (ptr);						\
+	__typeof__ (*(ptr)) __user *__pu_ptr = (ptr);					\
 	__typeof__ (size) __pu_size = (size);						\
 	long __pu_err = -EFAULT;							\
 											\
-	if (!check || __access_ok((long) __pu_ptr, __pu_size, segment))			\
+	if (!check || __access_ok(__pu_ptr, __pu_size, segment))			\
 		switch (__pu_size) {							\
 		      case 1: __put_user_size(__pu_x, __pu_ptr, 1, __pu_err); break;	\
 		      case 2: __put_user_size(__pu_x, __pu_ptr, 2, __pu_err); break;	\
@@ -234,44 +237,64 @@
 /*
  * Complex access routines
  */
-extern unsigned long __copy_user (void *to, const void *from, unsigned long count);
+extern unsigned long __must_check __copy_user (void __user *to, const void __user *from,
+					       unsigned long count);
 
-#define __copy_to_user(to, from, n)	__copy_user((to), (from), (n))
-#define __copy_from_user(to, from, n)	__copy_user((to), (from), (n))
-#define __copy_to_user_inatomic __copy_to_user
-#define __copy_from_user_inatomic __copy_from_user
-#define copy_to_user(to, from, n)	__copy_tofrom_user((to), (from), (n), 1)
-#define copy_from_user(to, from, n)	__copy_tofrom_user((to), (from), (n), 0)
+static inline unsigned long
+__copy_to_user (void __user *to, const void *from, unsigned long count)
+{
+	return __copy_user(to, (void __user *) from, count);
+}
+
+static inline unsigned long
+__copy_from_user (void *to, const void __user *from, unsigned long count)
+{
+	return __copy_user((void __user *) to, from, count);
+}
 
-#define __copy_tofrom_user(to, from, n, check_to)					\
+#define __copy_to_user_inatomic		__copy_to_user
+#define __copy_from_user_inatomic	__copy_from_user
+#define copy_to_user(to, from, n)							\
 ({											\
-	void *__cu_to = (to);								\
+	void __user *__cu_to = (to);							\
 	const void *__cu_from = (from);							\
 	long __cu_len = (n);								\
 											\
-	if (__access_ok((long) ((check_to) ? __cu_to : __cu_from), __cu_len, get_fs()))	\
-		__cu_len = __copy_user(__cu_to, __cu_from, __cu_len);			\
+	if (__access_ok(__cu_to, __cu_len, get_fs()))					\
+		__cu_len = __copy_user(__cu_to, (void __user *) __cu_from, __cu_len);	\
+	__cu_len;									\
+})
+
+#define copy_from_user(to, from, n)							\
+({											\
+	void *__cu_to = (to);								\
+	const void __user *__cu_from = (from);						\
+	long __cu_len = (n);								\
+											\
+	__chk_user_ptr(__cu_from);							\
+	if (__access_ok(__cu_from, __cu_len, get_fs()))					\
+		__cu_len = __copy_user((void __user *) __cu_to, __cu_from, __cu_len);	\
 	__cu_len;									\
 })
 
 #define __copy_in_user(to, from, size)	__copy_user((to), (from), (size))
 
 static inline unsigned long
-copy_in_user (void *to, const void *from, unsigned long n)
+copy_in_user (void __user *to, const void __user *from, unsigned long n)
 {
 	if (likely(access_ok(VERIFY_READ, from, n) && access_ok(VERIFY_WRITE, to, n)))
 		n = __copy_user(to, from, n);
 	return n;
 }
 
-extern unsigned long __do_clear_user (void *, unsigned long);
+extern unsigned long __do_clear_user (void __user *, unsigned long);
 
 #define __clear_user(to, n)		__do_clear_user(to, n)
 
 #define clear_user(to, n)					\
 ({								\
 	unsigned long __cu_len = (n);				\
-	if (__access_ok((long) to, __cu_len, get_fs()))		\
+	if (__access_ok(to, __cu_len, get_fs()))		\
 		__cu_len = __do_clear_user(to, __cu_len);	\
 	__cu_len;						\
 })
@@ -281,25 +304,25 @@
  * Returns: -EFAULT if exception before terminator, N if the entire buffer filled, else
  * strlen.
  */
-extern long __strncpy_from_user (char *to, const char *from, long to_len);
+extern long __must_check __strncpy_from_user (char *to, const char __user *from, long to_len);
 
 #define strncpy_from_user(to, from, n)					\
 ({									\
-	const char * __sfu_from = (from);				\
+	const char __user * __sfu_from = (from);			\
 	long __sfu_ret = -EFAULT;					\
-	if (__access_ok((long) __sfu_from, 0, get_fs()))		\
+	if (__access_ok(__sfu_from, 0, get_fs()))			\
 		__sfu_ret = __strncpy_from_user((to), __sfu_from, (n));	\
 	__sfu_ret;							\
 })
 
 /* Returns: 0 if bad, string length+1 (memory size) of string if ok */
-extern unsigned long __strlen_user (const char *);
+extern unsigned long __strlen_user (const char __user *);
 
 #define strlen_user(str)				\
 ({							\
-	const char *__su_str = (str);			\
+	const char __user *__su_str = (str);		\
 	unsigned long __su_ret = 0;			\
-	if (__access_ok((long) __su_str, 0, get_fs()))	\
+	if (__access_ok(__su_str, 0, get_fs()))		\
 		__su_ret = __strlen_user(__su_str);	\
 	__su_ret;					\
 })
@@ -309,13 +332,13 @@
  * (N), a value greater than N if the limit would be exceeded, else
  * strlen.
  */
-extern unsigned long __strnlen_user (const char *, long);
+extern unsigned long __strnlen_user (const char __user *, long);
 
 #define strnlen_user(str, len)					\
 ({								\
-	const char *__su_str = (str);				\
+	const char __user *__su_str = (str);			\
 	unsigned long __su_ret = 0;				\
-	if (__access_ok((long) __su_str, 0, get_fs()))		\
+	if (__access_ok(__su_str, 0, get_fs()))			\
 		__su_ret = __strnlen_user(__su_str, len);	\
 	__su_ret;						\
 })
=== include/asm-ia64/unistd.h 1.48 vs edited ==--- 1.48/include/asm-ia64/unistd.h	2004-06-17 15:47:11 -07:00
+++ edited/include/asm-ia64/unistd.h	2004-10-04 05:09:53 -07:00
@@ -369,8 +369,8 @@
 				int fd, long pgoff);
 struct pt_regs;
 struct sigaction;
-asmlinkage long sys_execve(char *filename, char **argv, char **envp,
-				struct pt_regs *regs);
+asmlinkage long sys_execve(char __user *filename, char __user * __user *argv,
+			   char __user * __user *envp, struct pt_regs *regs);
 asmlinkage long sys_pipe(long arg0, long arg1, long arg2, long arg3,
 			long arg4, long arg5, long arg6, long arg7, long stack);
 asmlinkage long sys_ptrace(long request, pid_t pid,
