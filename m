From: Arun Sharma <arun.sharma@intel.com>
Date: Wed, 06 Oct 2004 22:39:58 +0000
Subject: Re: sparse cleanups for ia32 subsystem
Message-Id: <4164743E.8040008@intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------070806060607010204040401"
List-Id: <linux-ia64.vger.kernel.org>
References: <16738.33692.510681.306179@napali.hpl.hp.com>
In-Reply-To: <16738.33692.510681.306179@napali.hpl.hp.com>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------070806060607010204040401
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

On 10/5/2004 4:21 AM, David Mosberger wrote:

Hi David,

> Hi Arun,
> 
> Below is a complete patch for the sparse-triggered changes to the ia32
> subsystem.  I take it you may have done some of this already but I
> hope the patch is still useful.  Please feed the patches to Tony as
> you see fit.

Thanks for doing this! I've taken care of the remaining sparse warnings and fixed up a couple of issues you found. Details inside the patch.

Tony, please apply.

	-Arun

--------------070806060607010204040401
Content-Type: text/plain;
 name="ia32-sparse.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ia32-sparse.patch"

ia64: sparse annotations and cleanups for ia32 subsystem

+ Add sparse annotations to ia32 subsystem so it checks out cleanly.
+ Add set_fs(KERNEL_DS) in elfcore32.h
+ Use compat_ptr() instead of P()
+ Fix a bug in ia32_sigsuspend() by introducing __ia32_rt_sigsuspend()

Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>
Signed-off-by: Arun Sharma <arun.sharma@intel.com>

===== arch/ia64/ia32/elfcore32.h 1.3 vs edited =====
--- 1.3/arch/ia64/ia32/elfcore32.h	Fri Sep  5 18:29:13 2003
+++ edited/arch/ia64/ia32/elfcore32.h	Wed Oct  6 13:22:07 2004
@@ -103,11 +103,15 @@
 elf_core_copy_task_fpregs(struct task_struct *tsk, struct pt_regs *regs, elf_fpregset_t *fpu)
 {
 	struct ia32_user_i387_struct *fpstate = (void*)fpu;
+	mm_segment_t old_fs;
 
 	if (!tsk->used_math)
 		return 0;
-
-	save_ia32_fpstate(tsk, fpstate);
+	
+	old_fs = get_fs();
+	set_fs(KERNEL_DS);
+	save_ia32_fpstate(tsk, (struct ia32_user_i387_struct __user *) fpstate);
+	set_fs(old_fs);
 
 	return 1;
 }
@@ -117,11 +121,15 @@
 elf_core_copy_task_xfpregs(struct task_struct *tsk, elf_fpxregset_t *xfpu)
 {
 	struct ia32_user_fxsr_struct *fpxstate = (void*) xfpu;
+	mm_segment_t old_fs;
 
 	if (!tsk->used_math)
 		return 0;
 
-	save_ia32_fpxstate(tsk, fpxstate);
+	old_fs = get_fs();
+	set_fs(KERNEL_DS);
+	save_ia32_fpxstate(tsk, (struct ia32_user_fxsr_struct __user *) fpxstate);
+	set_fs(old_fs);
 
 	return 1;
 }
===== arch/ia64/ia32/ia32_ldt.c 1.4 vs edited =====
--- 1.4/arch/ia64/ia32/ia32_ldt.c	Tue Oct 21 12:34:11 2003
+++ edited/arch/ia64/ia32/ia32_ldt.c	Wed Oct  6 12:58:15 2004
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001 Hewlett-Packard Co
+ * Copyright (C) 2001, 2004 Hewlett-Packard Co
  *	David Mosberger-Tang <davidm@hpl.hp.com>
  *
  * Adapted from arch/i386/kernel/ldt.c
@@ -17,25 +17,24 @@
 
 #include "ia32priv.h"
 
-#define P(p)	((void *) (unsigned long) (p))
-
 /*
  * read_ldt() is not really atomic - this is not a problem since synchronization of reads
  * and writes done to the LDT has to be assured by user-space anyway. Writes are atomic,
  * to protect the security checks done on new descriptors.
  */
 static int
-read_ldt (void *ptr, unsigned long bytecount)
+read_ldt (void __user *ptr, unsigned long bytecount)
 {
-	char *src, *dst, buf[256];	/* temporary buffer (don't overflow kernel stack!) */
 	unsigned long bytes_left, n;
+	char __user *src, *dst;
+	char buf[256];	/* temporary buffer (don't overflow kernel stack!) */
 
 	if (bytecount > IA32_LDT_ENTRIES*IA32_LDT_ENTRY_SIZE)
 		bytecount = IA32_LDT_ENTRIES*IA32_LDT_ENTRY_SIZE;
 
 	bytes_left = bytecount;
 
-	src = (void *) IA32_LDT_OFFSET;
+	src = (void __user *) IA32_LDT_OFFSET;
 	dst = ptr;
 
 	while (bytes_left) {
@@ -61,7 +60,7 @@
 }
 
 static int
-read_default_ldt (void * ptr, unsigned long bytecount)
+read_default_ldt (void __user * ptr, unsigned long bytecount)
 {
 	unsigned long size;
 	int err;
@@ -80,7 +79,7 @@
 }
 
 static int
-write_ldt (void * ptr, unsigned long bytecount, int oldmode)
+write_ldt (void __user * ptr, unsigned long bytecount, int oldmode)
 {
 	struct ia32_user_desc ldt_info;
 	__u64 entry;
@@ -120,7 +119,7 @@
 	 * memory, but we still need to guard against out-of-memory, hence we must use
 	 * put_user().
 	 */
-	ret = __put_user(entry, (__u64 *) IA32_LDT_OFFSET + ldt_info.entry_number);
+	ret = __put_user(entry, (__u64 __user *) IA32_LDT_OFFSET + ldt_info.entry_number);
 	ia32_load_segment_descriptors(current);
 	return ret;
 }
@@ -132,16 +131,16 @@
 
 	switch (func) {
 	      case 0:
-		ret = read_ldt(P(ptr), bytecount);
+		ret = read_ldt(compat_ptr(ptr), bytecount);
 		break;
 	      case 1:
-		ret = write_ldt(P(ptr), bytecount, 1);
+		ret = write_ldt(compat_ptr(ptr), bytecount, 1);
 		break;
 	      case 2:
-		ret = read_default_ldt(P(ptr), bytecount);
+		ret = read_default_ldt(compat_ptr(ptr), bytecount);
 		break;
 	      case 0x11:
-		ret = write_ldt(P(ptr), bytecount, 0);
+		ret = write_ldt(compat_ptr(ptr), bytecount, 0);
 		break;
 	}
 	return ret;
===== arch/ia64/ia32/ia32_signal.c 1.32 vs edited =====
--- 1.32/arch/ia64/ia32/ia32_signal.c	Tue Oct  5 11:24:11 2004
+++ edited/arch/ia64/ia32/ia32_signal.c	Wed Oct  6 13:55:35 2004
@@ -66,7 +66,7 @@
 };
 
 int
-copy_siginfo_from_user32 (siginfo_t *to, siginfo_t32 *from)
+copy_siginfo_from_user32 (siginfo_t *to, siginfo_t32 __user *from)
 {
 	unsigned long tmp;
 	int err;
@@ -92,7 +92,7 @@
 			break;
 		      case __SI_FAULT >> 16:
 			err |= __get_user(tmp, &from->si_addr);
-			to->si_addr = (void *) tmp;
+			to->si_addr = (void __user *) tmp;
 			break;
 		      case __SI_POLL >> 16:
 			err |= __get_user(to->si_band, &from->si_band);
@@ -110,7 +110,7 @@
 }
 
 int
-copy_siginfo_to_user32 (siginfo_t32 *to, siginfo_t *from)
+copy_siginfo_to_user32 (siginfo_t32 __user *to, siginfo_t *from)
 {
 	unsigned int addr;
 	int err;
@@ -141,7 +141,8 @@
 			err |= __put_user(from->si_uid, &to->si_uid);
 			break;
 		case __SI_FAULT >> 16:
-			err |= __put_user((long)from->si_addr, &to->si_addr);
+			/* avoid type-checking warnings by copying _pad[0] in lieu of si_addr... */
+			err |= __put_user(from->_sifields._pad[0], &to->si_addr);
 			break;
 		case __SI_POLL >> 16:
 			err |= __put_user(from->si_band, &to->si_band);
@@ -202,7 +203,7 @@
  */
 
 static int
-save_ia32_fpstate_live (struct _fpstate_ia32 *save)
+save_ia32_fpstate_live (struct _fpstate_ia32 __user *save)
 {
 	struct task_struct *tsk = current;
 	struct pt_regs *ptp;
@@ -310,7 +311,7 @@
 }
 
 static int
-restore_ia32_fpstate_live (struct _fpstate_ia32 *save)
+restore_ia32_fpstate_live (struct _fpstate_ia32 __user *save)
 {
 	struct task_struct *tsk = current;
 	struct pt_regs *ptp;
@@ -339,34 +340,34 @@
 	fir = ia64_getreg(_IA64_REG_AR_FIR);
 	fdr = ia64_getreg(_IA64_REG_AR_FDR);
 
-	__get_user(mxcsr, (unsigned int *)&save->mxcsr);
+	__get_user(mxcsr, (unsigned int __user *)&save->mxcsr);
 	/* setting bits 0..5 8..12 with cw and 39..47 from mxcsr */
-	__get_user(lo, (unsigned int *)&save->cw);
+	__get_user(lo, (unsigned int __user *)&save->cw);
 	num64 = mxcsr & 0xff10;
 	num64 = (num64 << 32) | (lo & 0x1f3f);
 	fcr = (fcr & (~0xff1000001f3fUL)) | num64;
 
 	/* setting bits 0..31 with sw and tag and 32..37 from mxcsr */
-	__get_user(lo, (unsigned int *)&save->sw);
+	__get_user(lo, (unsigned int __user *)&save->sw);
 	/* set bits 15,7 (fsw.b, fsw.es) to reflect the current error status */
 	if ( !(lo & 0x7f) )
 		lo &= (~0x8080);
-	__get_user(hi, (unsigned int *)&save->tag);
+	__get_user(hi, (unsigned int __user *)&save->tag);
 	num64 = mxcsr & 0x3f;
 	num64 = (num64 << 16) | (hi & 0xffff);
 	num64 = (num64 << 16) | (lo & 0xffff);
 	fsr = (fsr & (~0x3fffffffffUL)) | num64;
 
 	/* setting bits 0..47 with cssel and ipoff */
-	__get_user(lo, (unsigned int *)&save->ipoff);
-	__get_user(hi, (unsigned int *)&save->cssel);
+	__get_user(lo, (unsigned int __user *)&save->ipoff);
+	__get_user(hi, (unsigned int __user *)&save->cssel);
 	num64 = hi & 0xffff;
 	num64 = (num64 << 32) | lo;
 	fir = (fir & (~0xffffffffffffUL)) | num64;
 
 	/* setting bits 0..47 with datasel and dataoff */
-	__get_user(lo, (unsigned int *)&save->dataoff);
-	__get_user(hi, (unsigned int *)&save->datasel);
+	__get_user(lo, (unsigned int __user *)&save->dataoff);
+	__get_user(hi, (unsigned int __user *)&save->datasel);
 	num64 = hi & 0xffff;
 	num64 = (num64 << 32) | lo;
 	fdr = (fdr & (~0xffffffffffffUL)) | num64;
@@ -452,8 +453,8 @@
 		sa->sa.sa_handler = (__sighandler_t) (((unsigned long) restorer << 32) | handler);
 }
 
-asmlinkage long
-ia32_rt_sigsuspend (compat_sigset_t *uset, unsigned int sigsetsize, struct sigscratch *scr)
+long
+__ia32_rt_sigsuspend (compat_sigset_t *sset, unsigned int sigsetsize, struct sigscratch *scr)
 {
 	extern long ia64_do_signal (sigset_t *oldset, struct sigscratch *scr, long in_syscall);
 	sigset_t oldset, set;
@@ -461,10 +462,7 @@
 	scr->scratch_unat = 0;	/* avoid leaking kernel bits to user level */
 	memset(&set, 0, sizeof(&set));
 
-	if (sigsetsize > sizeof(sigset_t))
-		return -EINVAL;
-
-	if (copy_from_user(&set.sig, &uset->sig, sigsetsize))
+	if (memcpy(&set.sig, &sset->sig, sigsetsize))
 		return -EFAULT;
 
 	sigdelsetmask(&set, ~_BLOCKABLE);
@@ -492,9 +490,23 @@
 }
 
 asmlinkage long
+ia32_rt_sigsuspend (compat_sigset_t __user *uset, unsigned int sigsetsize, struct sigscratch *scr)
+{
+	compat_sigset_t set;
+
+	if (sigsetsize > sizeof(compat_sigset_t))
+		return -EINVAL;
+
+	if (copy_from_user(&set.sig, &uset->sig, sigsetsize))
+		return -EFAULT;
+
+	return __ia32_rt_sigsuspend(&set, sigsetsize, scr);
+}
+
+asmlinkage long
 ia32_sigsuspend (unsigned int mask, struct sigscratch *scr)
 {
-	return ia32_rt_sigsuspend((compat_sigset_t *)&mask, sizeof(mask), scr);
+	return __ia32_rt_sigsuspend((compat_sigset_t *) &mask, sizeof(mask), scr);
 }
 
 asmlinkage long
@@ -512,8 +524,8 @@
 }
 
 asmlinkage long
-sys32_rt_sigaction (int sig, struct sigaction32 *act,
-		    struct sigaction32 *oact, unsigned int sigsetsize)
+sys32_rt_sigaction (int sig, struct sigaction32 __user *act,
+		    struct sigaction32 __user *oact, unsigned int sigsetsize)
 {
 	struct k_sigaction new_ka, old_ka;
 	unsigned int handler, restorer;
@@ -547,7 +559,8 @@
 
 
 asmlinkage long
-sys32_rt_sigprocmask (int how, compat_sigset_t *set, compat_sigset_t *oset, unsigned int sigsetsize)
+sys32_rt_sigprocmask (int how, compat_sigset_t __user *set, compat_sigset_t __user *oset,
+		      unsigned int sigsetsize)
 {
 	mm_segment_t old_fs = get_fs();
 	sigset_t s;
@@ -562,7 +575,9 @@
 			return -EFAULT;
 	}
 	set_fs(KERNEL_DS);
-	ret = sys_rt_sigprocmask(how, set ? &s : NULL, oset ? &s : NULL, sizeof(s));
+	ret = sys_rt_sigprocmask(how,
+				 set ? (sigset_t __user *) &s : NULL,
+				 oset ? (sigset_t __user *) &s : NULL, sizeof(s));
 	set_fs(old_fs);
 	if (ret)
 		return ret;
@@ -574,10 +589,9 @@
 }
 
 asmlinkage long
-sys32_rt_sigtimedwait (compat_sigset_t *uthese, siginfo_t32 *uinfo,
-		struct compat_timespec *uts, unsigned int sigsetsize)
+sys32_rt_sigtimedwait (compat_sigset_t __user *uthese, siginfo_t32 __user *uinfo,
+		       struct compat_timespec __user *uts, unsigned int sigsetsize)
 {
-	extern int copy_siginfo_to_user32 (siginfo_t32 *, siginfo_t *);
 	mm_segment_t old_fs = get_fs();
 	struct timespec t;
 	siginfo_t info;
@@ -589,8 +603,10 @@
 	if (uts && get_compat_timespec(&t, uts))
 		return -EFAULT;
 	set_fs(KERNEL_DS);
-	ret = sys_rt_sigtimedwait(&s, uinfo ? &info : NULL, uts ? &t : NULL,
-			sigsetsize);
+	ret = sys_rt_sigtimedwait((sigset_t __user *) &s,
+				  uinfo ? (siginfo_t __user *) &info : NULL,
+				  uts ? (struct timespec __user *) &t : NULL,
+				  sigsetsize);
 	set_fs(old_fs);
 	if (ret >= 0 && uinfo) {
 		if (copy_siginfo_to_user32(uinfo, &info))
@@ -600,7 +616,7 @@
 }
 
 asmlinkage long
-sys32_rt_sigqueueinfo (int pid, int sig, siginfo_t32 *uinfo)
+sys32_rt_sigqueueinfo (int pid, int sig, siginfo_t32 __user *uinfo)
 {
 	mm_segment_t old_fs = get_fs();
 	siginfo_t info;
@@ -609,13 +625,13 @@
 	if (copy_siginfo_from_user32(&info, uinfo))
 		return -EFAULT;
 	set_fs(KERNEL_DS);
-	ret = sys_rt_sigqueueinfo(pid, sig, &info);
+	ret = sys_rt_sigqueueinfo(pid, sig, (siginfo_t __user *) &info);
 	set_fs(old_fs);
 	return ret;
 }
 
 asmlinkage long
-sys32_sigaction (int sig, struct old_sigaction32 *act, struct old_sigaction32 *oact)
+sys32_sigaction (int sig, struct old_sigaction32 __user *act, struct old_sigaction32 __user *oact)
 {
 	struct k_sigaction new_ka, old_ka;
 	unsigned int handler, restorer;
@@ -648,7 +664,7 @@
 }
 
 static int
-setup_sigcontext_ia32 (struct sigcontext_ia32 *sc, struct _fpstate_ia32 *fpstate,
+setup_sigcontext_ia32 (struct sigcontext_ia32 __user *sc, struct _fpstate_ia32 __user *fpstate,
 		       struct pt_regs *regs, unsigned long mask)
 {
 	int  err = 0;
@@ -657,10 +673,10 @@
 	if (!access_ok(VERIFY_WRITE, sc, sizeof(*sc)))
 		return -EFAULT;
 
-	err |= __put_user((regs->r16 >> 32) & 0xffff, (unsigned int *)&sc->fs);
-	err |= __put_user((regs->r16 >> 48) & 0xffff, (unsigned int *)&sc->gs);
-	err |= __put_user((regs->r16 >> 16) & 0xffff, (unsigned int *)&sc->es);
-	err |= __put_user(regs->r16 & 0xffff, (unsigned int *)&sc->ds);
+	err |= __put_user((regs->r16 >> 32) & 0xffff, (unsigned int __user *)&sc->fs);
+	err |= __put_user((regs->r16 >> 48) & 0xffff, (unsigned int __user *)&sc->gs);
+	err |= __put_user((regs->r16 >> 16) & 0xffff, (unsigned int __user *)&sc->es);
+	err |= __put_user(regs->r16 & 0xffff, (unsigned int __user *)&sc->ds);
 	err |= __put_user(regs->r15, &sc->edi);
 	err |= __put_user(regs->r14, &sc->esi);
 	err |= __put_user(regs->r13, &sc->ebp);
@@ -674,14 +690,14 @@
 	err |= __put_user(current->tss.error_code, &sc->err);
 #endif
 	err |= __put_user(regs->cr_iip, &sc->eip);
-	err |= __put_user(regs->r17 & 0xffff, (unsigned int *)&sc->cs);
+	err |= __put_user(regs->r17 & 0xffff, (unsigned int __user *)&sc->cs);
 	/*
 	 *  `eflags' is in an ar register for this context
 	 */
 	flag = ia64_getreg(_IA64_REG_AR_EFLAG);
 	err |= __put_user((unsigned int)flag, &sc->eflags);
 	err |= __put_user(regs->r12, &sc->esp_at_signal);
-	err |= __put_user((regs->r17 >> 16) & 0xffff, (unsigned int *)&sc->ss);
+	err |= __put_user((regs->r17 >> 16) & 0xffff, (unsigned int __user *)&sc->ss);
 
 	if ( save_ia32_fpstate_live(fpstate) < 0 )
 		err = -EFAULT;
@@ -705,7 +721,7 @@
 }
 
 static int
-restore_sigcontext_ia32 (struct pt_regs *regs, struct sigcontext_ia32 *sc, int *peax)
+restore_sigcontext_ia32 (struct pt_regs *regs, struct sigcontext_ia32 __user *sc, int *peax)
 {
 	unsigned int err = 0;
 
@@ -775,10 +791,10 @@
 	}
 
 	{
-		struct _fpstate_ia32 *buf = NULL;
+		struct _fpstate_ia32 __user *buf = NULL;
 		u32    fpstate_ptr;
 		err |= get_user(fpstate_ptr, &(sc->fpstate));
-		buf = (struct _fpstate_ia32 *)(u64)fpstate_ptr;
+		buf = compat_ptr(fpstate_ptr);
 		if (buf) {
 			err |= restore_ia32_fpstate_live(buf);
 		}
@@ -808,7 +824,7 @@
 /*
  * Determine which stack to use..
  */
-static inline void *
+static inline void __user *
 get_sigframe (struct k_sigaction *ka, struct pt_regs * regs, size_t frame_size)
 {
 	unsigned long esp;
@@ -823,14 +839,14 @@
 	}
 	/* Legacy stack switching not supported */
 
-	return (void *)((esp - frame_size) & -8ul);
+	return (void __user *)((esp - frame_size) & -8ul);
 }
 
 static int
 setup_frame_ia32 (int sig, struct k_sigaction *ka, sigset_t *set, struct pt_regs * regs)
 {
 	struct exec_domain *ed = current_thread_info()->exec_domain;
-	struct sigframe_ia32 *frame;
+	struct sigframe_ia32 __user *frame;
 	int err = 0;
 
 	frame = get_sigframe(ka, regs, sizeof(*frame));
@@ -862,9 +878,9 @@
 	 * See arch/i386/kernel/signal.c
 	 */
 
-	err |= __put_user(0xb858, (short *)(frame->retcode+0));
-	err |= __put_user(__IA32_NR_sigreturn, (int *)(frame->retcode+2));
-	err |= __put_user(0x80cd, (short *)(frame->retcode+6));
+	err |= __put_user(0xb858, (short __user *)(frame->retcode+0));
+	err |= __put_user(__IA32_NR_sigreturn, (int __user *)(frame->retcode+2));
+	err |= __put_user(0x80cd, (short __user *)(frame->retcode+6));
 
 	if (err)
 		goto give_sigsegv;
@@ -896,7 +912,8 @@
 		     sigset_t *set, struct pt_regs * regs)
 {
 	struct exec_domain *ed = current_thread_info()->exec_domain;
-	struct rt_sigframe_ia32 *frame;
+	compat_uptr_t pinfo, puc;
+	struct rt_sigframe_ia32 __user *frame;
 	int err = 0;
 
 	frame = get_sigframe(ka, regs, sizeof(*frame));
@@ -906,8 +923,11 @@
 
 	err |= __put_user((ed && ed->signal_invmap
 			   && sig < 32 ? ed->signal_invmap[sig] : sig), &frame->sig);
-	err |= __put_user((long)&frame->info, &frame->pinfo);
-	err |= __put_user((long)&frame->uc, &frame->puc);
+
+	pinfo = (long __user) &frame->info;
+	puc = (long __user) &frame->uc;
+	err |= __put_user(pinfo, &frame->pinfo);
+	err |= __put_user(puc, &frame->puc);
 	err |= copy_siginfo_to_user32(&frame->info, info);
 
 	/* Create the ucontext.  */
@@ -936,9 +956,9 @@
 	 * See arch/i386/kernel/signal.c
 	 */
 
-	err |= __put_user(0xb8, (char *)(frame->retcode+0));
-	err |= __put_user(__IA32_NR_rt_sigreturn, (int *)(frame->retcode+1));
-	err |= __put_user(0x80cd, (short *)(frame->retcode+5));
+	err |= __put_user(0xb8, (char __user *)(frame->retcode+0));
+	err |= __put_user(__IA32_NR_rt_sigreturn, (int __user *)(frame->retcode+1));
+	err |= __put_user(0x80cd, (short __user *)(frame->retcode+5));
 
 	if (err)
 		goto give_sigsegv;
@@ -982,7 +1002,7 @@
 {
 	struct pt_regs *regs = (struct pt_regs *) &stack;
 	unsigned long esp = (unsigned int) regs->r12;
-	struct sigframe_ia32 *frame = (struct sigframe_ia32 *)(esp - 8);
+	struct sigframe_ia32 __user *frame = (struct sigframe_ia32 __user *)(esp - 8);
 	sigset_t set;
 	int eax;
 
@@ -996,7 +1016,7 @@
 
 	sigdelsetmask(&set, ~_BLOCKABLE);
 	spin_lock_irq(&current->sighand->siglock);
-	current->blocked = (sigset_t) set;
+	current->blocked = set;
 	recalc_sigpending();
 	spin_unlock_irq(&current->sighand->siglock);
 
@@ -1015,9 +1035,8 @@
 {
 	struct pt_regs *regs = (struct pt_regs *) &stack;
 	unsigned long esp = (unsigned int) regs->r12;
-	struct rt_sigframe_ia32 *frame = (struct rt_sigframe_ia32 *)(esp - 4);
+	struct rt_sigframe_ia32 __user *frame = (struct rt_sigframe_ia32 __user *)(esp - 4);
 	sigset_t set;
-	stack_t st;
 	int eax;
 
 	if (verify_area(VERIFY_READ, frame, sizeof(*frame)))
@@ -1034,11 +1053,9 @@
 	if (restore_sigcontext_ia32(regs, &frame->uc.uc_mcontext, &eax))
 		goto badframe;
 
-	if (__copy_from_user(&st, &frame->uc.uc_stack, sizeof(st)))
-		goto badframe;
 	/* It is more difficult to avoid calling this function than to
 	   call it and ignore errors.  */
-	do_sigaltstack(&st, NULL, esp);
+	do_sigaltstack((stack_t __user *) &frame->uc.uc_stack, NULL, esp);
 
 	return eax;
 
===== arch/ia64/ia32/ia32_support.c 1.19 vs edited =====
--- 1.19/arch/ia64/ia32/ia32_support.c	Tue Oct  5 11:19:50 2004
+++ edited/arch/ia64/ia32/ia32_support.c	Wed Oct  6 12:58:16 2004
@@ -76,7 +76,7 @@
 	struct ia32_user_desc info;
 	int idx;
 
-	if (copy_from_user(&info, (void *)(childregs->r14 & 0xffffffff), sizeof(info)))
+	if (copy_from_user(&info, (void __user *)(childregs->r14 & 0xffffffff), sizeof(info)))
 		return -EFAULT;
 	if (LDT_empty(&info))
 		return -EINVAL;
===== arch/ia64/ia32/ia32priv.h 1.15 vs edited =====
--- 1.15/arch/ia64/ia32/ia32priv.h	Tue Oct  5 11:24:11 2004
+++ edited/arch/ia64/ia32/ia32priv.h	Wed Oct  6 12:58:16 2004
@@ -556,8 +556,8 @@
 };
 
 /* Prototypes for use in elfcore32.h */
-extern int save_ia32_fpstate (struct task_struct *tsk, struct ia32_user_i387_struct *save);
-extern int save_ia32_fpxstate (struct task_struct *tsk, struct ia32_user_fxsr_struct *save);
+extern int save_ia32_fpstate (struct task_struct *, struct ia32_user_i387_struct __user *);
+extern int save_ia32_fpxstate (struct task_struct *, struct ia32_user_fxsr_struct __user *);
 
 #endif /* !CONFIG_IA32_SUPPORT */
 
===== arch/ia64/ia32/sys_ia32.c 1.106 vs edited =====
--- 1.106/arch/ia64/ia32/sys_ia32.c	Tue Oct  5 11:24:11 2004
+++ edited/arch/ia64/ia32/sys_ia32.c	Wed Oct  6 12:58:16 2004
@@ -70,10 +70,7 @@
 # define DBG(fmt...)
 #endif
 
-#define A(__x)		((unsigned long)(__x))
-#define AA(__x)		((unsigned long)(__x))
 #define ROUND_UP(x,a)	((__typeof__(x))(((unsigned long)(x) + ((a) - 1)) & ~((a) - 1)))
-#define NAME_OFFSET(de) ((int) ((de)->d_name - (char *) (de)))
 
 #define OFFSET4K(a)		((a) & 0xfff)
 #define PAGE_START(addr)	((addr) & PAGE_MASK)
@@ -82,9 +79,6 @@
 #define high2lowuid(uid) ((uid) > 65535 ? 65534 : (uid))
 #define high2lowgid(gid) ((gid) > 65535 ? 65534 : (gid))
 
-extern unsigned long arch_get_unmapped_area (struct file *, unsigned long, unsigned long,
-					     unsigned long, unsigned long);
-
 /*
  * Anything that modifies or inspects ia32 user virtual memory must hold this semaphore
  * while doing so.
@@ -93,7 +87,8 @@
 static DECLARE_MUTEX(ia32_mmap_sem);
 
 asmlinkage long
-sys32_execve (char *name, compat_uptr_t __user *argv, compat_uptr_t __user *envp, struct pt_regs *regs)
+sys32_execve (char __user *name, compat_uptr_t __user *argv, compat_uptr_t __user *envp,
+	      struct pt_regs *regs)
 {
 	long error;
 	char *filename;
@@ -128,7 +123,7 @@
 	return error;
 }
 
-int cp_compat_stat(struct kstat *stat, struct compat_stat *ubuf)
+int cp_compat_stat(struct kstat *stat, struct compat_stat __user *ubuf)
 {
 	int err;
 
@@ -199,7 +194,7 @@
 
 	/* Optimize the case where the old mmap and the new mmap are both anonymous */
 	if ((old_prot & PROT_WRITE) && (flags & MAP_ANONYMOUS) && !vma->vm_file) {
-		if (clear_user((void *) start, end - start)) {
+		if (clear_user((void __user *) start, end - start)) {
 			ret = -EFAULT;
 			goto out;
 		}
@@ -211,7 +206,7 @@
 		return -ENOMEM;
 
 	if (old_prot)
-		copy_from_user(page, (void *) PAGE_START(start), PAGE_SIZE);
+		copy_from_user(page, (void __user *) PAGE_START(start), PAGE_SIZE);
 
 	down_write(&current->mm->mmap_sem);
 	{
@@ -226,9 +221,10 @@
 	if (old_prot) {
 		/* copy back the old page contents.  */
 		if (offset_in_page(start))
-			copy_to_user((void *) PAGE_START(start), page, offset_in_page(start));
+			copy_to_user((void __user *) PAGE_START(start), page,
+				     offset_in_page(start));
 		if (offset_in_page(end))
-			copy_to_user((void *) end, page + offset_in_page(end),
+			copy_to_user((void __user *) end, page + offset_in_page(end),
 				     PAGE_SIZE - offset_in_page(end));
 	}
 
@@ -236,7 +232,7 @@
 		/* read the file contents */
 		inode = file->f_dentry->d_inode;
 		if (!inode->i_fop || !file->f_op->read
-		    || ((*file->f_op->read)(file, (char *) start, end - start, &off) < 0))
+		    || ((*file->f_op->read)(file, (char __user *) start, end - start, &off) < 0))
 		{
 			ret = -EINVAL;
 			goto out;
@@ -838,7 +834,8 @@
 		/* read the file contents */
 		inode = file->f_dentry->d_inode;
 		if (!inode->i_fop || !file->f_op->read
-		    || ((*file->f_op->read)(file, (char *) pstart, pend - pstart, &poff) < 0))
+		    || ((*file->f_op->read)(file, (char __user *) pstart, pend - pstart, &poff)
+			< 0))
 		{
 			sys_munmap(pstart, pend - pstart);
 			return -EINVAL;
@@ -927,7 +924,7 @@
 };
 
 asmlinkage long
-sys32_mmap (struct mmap_arg_struct *arg)
+sys32_mmap (struct mmap_arg_struct __user *arg)
 {
 	struct mmap_arg_struct a;
 	struct file *file = NULL;
@@ -1140,7 +1137,7 @@
 }
 
 asmlinkage long
-sys32_pipe (int *fd)
+sys32_pipe (int __user *fd)
 {
 	int retval;
 	int fds[2];
@@ -1155,14 +1152,14 @@
 }
 
 static inline long
-get_tv32 (struct timeval *o, struct compat_timeval *i)
+get_tv32 (struct timeval *o, struct compat_timeval __user *i)
 {
 	return (!access_ok(VERIFY_READ, i, sizeof(*i)) ||
 		(__get_user(o->tv_sec, &i->tv_sec) | __get_user(o->tv_usec, &i->tv_usec)));
 }
 
 static inline long
-put_tv32 (struct compat_timeval *o, struct timeval *i)
+put_tv32 (struct compat_timeval __user *o, struct timeval *i)
 {
 	return (!access_ok(VERIFY_WRITE, o, sizeof(*o)) ||
 		(__put_user(i->tv_sec, &o->tv_sec) | __put_user(i->tv_usec, &o->tv_usec)));
@@ -1192,7 +1189,7 @@
 extern struct timezone sys_tz;
 
 asmlinkage long
-sys32_gettimeofday (struct compat_timeval *tv, struct timezone *tz)
+sys32_gettimeofday (struct compat_timeval __user *tv, struct timezone __user *tz)
 {
 	if (tv) {
 		struct timeval ktv;
@@ -1208,7 +1205,7 @@
 }
 
 asmlinkage long
-sys32_settimeofday (struct compat_timeval *tv, struct timezone *tz)
+sys32_settimeofday (struct compat_timeval __user *tv, struct timezone __user *tz)
 {
 	struct timeval ktv;
 	struct timespec kts;
@@ -1229,14 +1226,14 @@
 }
 
 struct getdents32_callback {
-	struct compat_dirent * current_dir;
-	struct compat_dirent * previous;
+	struct compat_dirent __user *current_dir;
+	struct compat_dirent __user *previous;
 	int count;
 	int error;
 };
 
 struct readdir32_callback {
-	struct old_linux32_dirent * dirent;
+	struct old_linux32_dirent __user * dirent;
 	int count;
 };
 
@@ -1244,9 +1241,9 @@
 filldir32 (void *__buf, const char *name, int namlen, loff_t offset, ino_t ino,
 	   unsigned int d_type)
 {
-	struct compat_dirent * dirent;
+	struct compat_dirent __user * dirent;
 	struct getdents32_callback * buf = (struct getdents32_callback *) __buf;
-	int reclen = ROUND_UP(NAME_OFFSET(dirent) + namlen + 1, 4);
+	int reclen = ROUND_UP(offsetof(struct compat_dirent, d_name) + namlen + 1, 4);
 
 	buf->error = -EINVAL;	/* only used if we fail.. */
 	if (reclen > buf->count)
@@ -1263,17 +1260,17 @@
 	    || copy_to_user(dirent->d_name, name, namlen)
 	    || put_user(0, dirent->d_name + namlen))
 		return -EFAULT;
-	dirent = (struct compat_dirent *) ((char *) dirent + reclen);
+	dirent = (struct compat_dirent __user *) ((char __user *) dirent + reclen);
 	buf->current_dir = dirent;
 	buf->count -= reclen;
 	return 0;
 }
 
 asmlinkage long
-sys32_getdents (unsigned int fd, struct compat_dirent *dirent, unsigned int count)
+sys32_getdents (unsigned int fd, struct compat_dirent __user *dirent, unsigned int count)
 {
 	struct file * file;
-	struct compat_dirent * lastdirent;
+	struct compat_dirent __user * lastdirent;
 	struct getdents32_callback buf;
 	int error;
 
@@ -1310,7 +1307,7 @@
 	      unsigned int d_type)
 {
 	struct readdir32_callback * buf = (struct readdir32_callback *) __buf;
-	struct old_linux32_dirent * dirent;
+	struct old_linux32_dirent __user * dirent;
 
 	if (buf->count)
 		return -EINVAL;
@@ -1326,7 +1323,7 @@
 }
 
 asmlinkage long
-sys32_readdir (unsigned int fd, void *dirent, unsigned int count)
+sys32_readdir (unsigned int fd, void __user *dirent, unsigned int count)
 {
 	int error;
 	struct file * file;
@@ -1357,7 +1354,7 @@
 };
 
 asmlinkage long
-sys32_old_select (struct sel_arg_struct *arg)
+sys32_old_select (struct sel_arg_struct __user *arg)
 {
 	struct sel_arg_struct a;
 
@@ -1434,7 +1431,7 @@
  * so we have to implement this system call here.
  */
 asmlinkage long
-sys32_time (int *tloc)
+sys32_time (int __user *tloc)
 {
 	int i;
 	struct timeval tv;
@@ -1564,8 +1561,8 @@
 }
 
 static void
-put_fpreg (int regno, struct _fpreg_ia32 *reg, struct pt_regs *ptp, struct switch_stack *swp,
-	   int tos)
+put_fpreg (int regno, struct _fpreg_ia32 __user *reg, struct pt_regs *ptp,
+	   struct switch_stack *swp, int tos)
 {
 	struct _fpreg_ia32 *f;
 	char buf[32];
@@ -1597,8 +1594,8 @@
 }
 
 static void
-get_fpreg (int regno, struct _fpreg_ia32 *reg, struct pt_regs *ptp, struct switch_stack *swp,
-	   int tos)
+get_fpreg (int regno, struct _fpreg_ia32 __user *reg, struct pt_regs *ptp,
+	   struct switch_stack *swp, int tos)
 {
 
 	if ((regno += tos) >= 8)
@@ -1627,7 +1624,7 @@
 }
 
 int
-save_ia32_fpstate (struct task_struct *tsk, struct ia32_user_i387_struct *save)
+save_ia32_fpstate (struct task_struct *tsk, struct ia32_user_i387_struct __user *save)
 {
 	struct switch_stack *swp;
 	struct pt_regs *ptp;
@@ -1656,7 +1653,7 @@
 }
 
 static int
-restore_ia32_fpstate (struct task_struct *tsk, struct ia32_user_i387_struct *save)
+restore_ia32_fpstate (struct task_struct *tsk, struct ia32_user_i387_struct __user *save)
 {
 	struct switch_stack *swp;
 	struct pt_regs *ptp;
@@ -1666,15 +1663,15 @@
 	if (!access_ok(VERIFY_READ, save, sizeof(*save)))
 		return(-EFAULT);
 
-	__get_user(num32, (unsigned int *)&save->cwd);
+	__get_user(num32, (unsigned int __user *)&save->cwd);
 	tsk->thread.fcr = (tsk->thread.fcr & (~0x1f3f)) | (num32 & 0x1f3f);
-	__get_user(fsrlo, (unsigned int *)&save->swd);
-	__get_user(fsrhi, (unsigned int *)&save->twd);
+	__get_user(fsrlo, (unsigned int __user *)&save->swd);
+	__get_user(fsrhi, (unsigned int __user *)&save->twd);
 	num32 = (fsrhi << 16) | fsrlo;
 	tsk->thread.fsr = (tsk->thread.fsr & (~0xffffffff)) | num32;
-	__get_user(num32, (unsigned int *)&save->fip);
+	__get_user(num32, (unsigned int __user *)&save->fip);
 	tsk->thread.fir = (tsk->thread.fir & (~0xffffffff)) | num32;
-	__get_user(num32, (unsigned int *)&save->foo);
+	__get_user(num32, (unsigned int __user *)&save->foo);
 	tsk->thread.fdr = (tsk->thread.fdr & (~0xffffffff)) | num32;
 
 	/*
@@ -1689,7 +1686,7 @@
 }
 
 int
-save_ia32_fpxstate (struct task_struct *tsk, struct ia32_user_fxsr_struct *save)
+save_ia32_fpxstate (struct task_struct *tsk, struct ia32_user_fxsr_struct __user *save)
 {
 	struct switch_stack *swp;
 	struct pt_regs *ptp;
@@ -1715,7 +1712,7 @@
         ptp = ia64_task_regs(tsk);
 	tos = (tsk->thread.fsr >> 11) & 7;
         for (i = 0; i < 8; i++)
-		put_fpreg(i, (struct _fpreg_ia32 *)&save->st_space[4*i], ptp, swp, tos);
+		put_fpreg(i, (struct _fpreg_ia32 __user *)&save->st_space[4*i], ptp, swp, tos);
 
 	mxcsr = ((tsk->thread.fcr>>32) & 0xff80) | ((tsk->thread.fsr>>32) & 0x3f);
 	__put_user(mxcsr & 0xffff, &save->mxcsr);
@@ -1728,7 +1725,7 @@
 }
 
 static int
-restore_ia32_fpxstate (struct task_struct *tsk, struct ia32_user_fxsr_struct *save)
+restore_ia32_fpxstate (struct task_struct *tsk, struct ia32_user_fxsr_struct __user *save)
 {
 	struct switch_stack *swp;
 	struct pt_regs *ptp;
@@ -1741,15 +1738,15 @@
 	if (!access_ok(VERIFY_READ, save, sizeof(*save)))
 		return(-EFAULT);
 
-	__get_user(num32, (unsigned int *)&save->cwd);
+	__get_user(num32, (unsigned int __user *)&save->cwd);
 	tsk->thread.fcr = (tsk->thread.fcr & (~0x1f3f)) | (num32 & 0x1f3f);
-	__get_user(fsrlo, (unsigned int *)&save->swd);
-	__get_user(fsrhi, (unsigned int *)&save->twd);
+	__get_user(fsrlo, (unsigned int __user *)&save->swd);
+	__get_user(fsrhi, (unsigned int __user *)&save->twd);
 	num32 = (fsrhi << 16) | fsrlo;
 	tsk->thread.fsr = (tsk->thread.fsr & (~0xffffffff)) | num32;
-	__get_user(num32, (unsigned int *)&save->fip);
+	__get_user(num32, (unsigned int __user *)&save->fip);
 	tsk->thread.fir = (tsk->thread.fir & (~0xffffffff)) | num32;
-	__get_user(num32, (unsigned int *)&save->foo);
+	__get_user(num32, (unsigned int __user *)&save->foo);
 	tsk->thread.fdr = (tsk->thread.fdr & (~0xffffffff)) | num32;
 
 	/*
@@ -1759,9 +1756,9 @@
 	ptp = ia64_task_regs(tsk);
 	tos = (tsk->thread.fsr >> 11) & 7;
 	for (i = 0; i < 8; i++)
-	get_fpreg(i, (struct _fpreg_ia32 *)&save->st_space[4*i], ptp, swp, tos);
+	get_fpreg(i, (struct _fpreg_ia32 __user *)&save->st_space[4*i], ptp, swp, tos);
 
-	__get_user(mxcsr, (unsigned int *)&save->mxcsr);
+	__get_user(mxcsr, (unsigned int __user *)&save->mxcsr);
 	num64 = mxcsr & 0xff10;
 	tsk->thread.fcr = (tsk->thread.fcr & (~0xff1000000000UL)) | (num64<<32);
 	num64 = mxcsr & 0x3f;
@@ -1823,7 +1820,7 @@
 	      case PTRACE_PEEKDATA:	/* read word at location addr */
 		ret = ia32_peek(regs, child, addr, &value);
 		if (ret == 0)
-			ret = put_user(value, (unsigned int *) A(data));
+			ret = put_user(value, (unsigned int __user *) compat_ptr(data));
 		else
 			ret = -EIO;
 		goto out_tsk;
@@ -1839,7 +1836,7 @@
 			break;
 
 		tmp = getreg(child, addr);
-		if (!put_user(tmp, (unsigned int *) A(data)))
+		if (!put_user(tmp, (unsigned int __user *) compat_ptr(data)))
 			ret = 0;
 		break;
 
@@ -1853,24 +1850,24 @@
 		break;
 
 	      case IA32_PTRACE_GETREGS:
-		if (!access_ok(VERIFY_WRITE, (int *) A(data), 17*sizeof(int))) {
+		if (!access_ok(VERIFY_WRITE, compat_ptr(data), 17*sizeof(int))) {
 			ret = -EIO;
 			break;
 		}
 		for (i = 0; i < (int) (17*sizeof(int)); i += sizeof(int) ) {
-			put_user(getreg(child, i), (unsigned int *) A(data));
+			put_user(getreg(child, i), (unsigned int __user *) compat_ptr(data));
 			data += sizeof(int);
 		}
 		ret = 0;
 		break;
 
 	      case IA32_PTRACE_SETREGS:
-		if (!access_ok(VERIFY_READ, (int *) A(data), 17*sizeof(int))) {
+		if (!access_ok(VERIFY_READ, compat_ptr(data), 17*sizeof(int))) {
 			ret = -EIO;
 			break;
 		}
 		for (i = 0; i < (int) (17*sizeof(int)); i += sizeof(int) ) {
-			get_user(tmp, (unsigned int *) A(data));
+			get_user(tmp, (unsigned int __user *) compat_ptr(data));
 			putreg(child, i, tmp);
 			data += sizeof(int);
 		}
@@ -1878,19 +1875,23 @@
 		break;
 
 	      case IA32_PTRACE_GETFPREGS:
-		ret = save_ia32_fpstate(child, (struct ia32_user_i387_struct *) A(data));
+		ret = save_ia32_fpstate(child, (struct ia32_user_i387_struct __user *)
+					compat_ptr(data));
 		break;
 
 	      case IA32_PTRACE_GETFPXREGS:
-		ret = save_ia32_fpxstate(child, (struct ia32_user_fxsr_struct *) A(data));
+		ret = save_ia32_fpxstate(child, (struct ia32_user_fxsr_struct __user *)
+					 compat_ptr(data));
 		break;
 
 	      case IA32_PTRACE_SETFPREGS:
-		ret = restore_ia32_fpstate(child, (struct ia32_user_i387_struct *) A(data));
+		ret = restore_ia32_fpstate(child, (struct ia32_user_i387_struct __user *)
+					   compat_ptr(data));
 		break;
 
 	      case IA32_PTRACE_SETFPXREGS:
-		ret = restore_ia32_fpxstate(child, (struct ia32_user_fxsr_struct *) A(data));
+		ret = restore_ia32_fpxstate(child, (struct ia32_user_fxsr_struct __user *)
+					    compat_ptr(data));
 		break;
 
 	      case PTRACE_SYSCALL:	/* continue, stop after next syscall */
@@ -1920,7 +1921,7 @@
 } ia32_stack_t;
 
 asmlinkage long
-sys32_sigaltstack (ia32_stack_t *uss32, ia32_stack_t *uoss32,
+sys32_sigaltstack (ia32_stack_t __user *uss32, ia32_stack_t __user *uoss32,
 		   long arg2, long arg3, long arg4, long arg5, long arg6, long arg7, long stack)
 {
 	struct pt_regs *pt = (struct pt_regs *) &stack;
@@ -1932,9 +1933,9 @@
 	if (uss32) {
 		if (copy_from_user(&buf32, uss32, sizeof(ia32_stack_t)))
 			return -EFAULT;
-		uss.ss_sp = (void *) (long) buf32.ss_sp;
+		uss.ss_sp = (void __user *) (long) buf32.ss_sp;
 		uss.ss_flags = buf32.ss_flags;
-		/* MINSIGSTKSZ is different for ia32 vs ia64. We lie here to pass the 
+		/* MINSIGSTKSZ is different for ia32 vs ia64. We lie here to pass the
 	           check and set it to the user requested value later */
 		if ((buf32.ss_flags != SS_DISABLE) && (buf32.ss_size < MINSIGSTKSZ_IA32)) {
 			ret = -ENOMEM;
@@ -1943,14 +1944,15 @@
 		uss.ss_size = MINSIGSTKSZ;
 	}
 	set_fs(KERNEL_DS);
-	ret = do_sigaltstack(uss32 ? &uss : NULL, &uoss, pt->r12);
- 	current->sas_ss_size = buf32.ss_size;	
+	ret = do_sigaltstack(uss32 ? (stack_t __user *) &uss : NULL,
+			     (stack_t __user *) &uoss, pt->r12);
+ 	current->sas_ss_size = buf32.ss_size;
 	set_fs(old_fs);
 out:
 	if (ret < 0)
 		return(ret);
 	if (uoss32) {
-		buf32.ss_sp = (long) uoss.ss_sp;
+		buf32.ss_sp = (long __user) uoss.ss_sp;
 		buf32.ss_flags = uoss.ss_flags;
 		buf32.ss_size = uoss.ss_size;
 		if (copy_to_user(uoss32, &buf32, sizeof(ia32_stack_t)))
@@ -1989,14 +1991,14 @@
 };
 
 asmlinkage long
-sys32_sysctl (struct sysctl32 *args)
+sys32_sysctl (struct sysctl32 __user *args)
 {
 #ifdef CONFIG_SYSCTL
 	struct sysctl32 a32;
 	mm_segment_t old_fs = get_fs ();
-	void *oldvalp, *newvalp;
+	void __user *oldvalp, *newvalp;
 	size_t oldlen;
-	int *namep;
+	int __user *namep;
 	long ret;
 
 	if (copy_from_user(&a32, args, sizeof(a32)))
@@ -2009,11 +2011,11 @@
 	 * addresses, we KNOW that access_ok() will always succeed, so this is an
 	 * expensive NOP, but so what...
 	 */
-	namep = (int *) A(a32.name);
-	oldvalp = (void *) A(a32.oldval);
-	newvalp = (void *) A(a32.newval);
+	namep = (int __user *) compat_ptr(a32.name);
+	oldvalp = compat_ptr(a32.oldval);
+	newvalp = compat_ptr(a32.newval);
 
-	if ((oldvalp && get_user(oldlen, (int *) A(a32.oldlenp)))
+	if ((oldvalp && get_user(oldlen, (int __user *) compat_ptr(a32.oldlenp)))
 	    || !access_ok(VERIFY_WRITE, namep, 0)
 	    || !access_ok(VERIFY_WRITE, oldvalp, 0)
 	    || !access_ok(VERIFY_WRITE, newvalp, 0))
@@ -2021,11 +2023,12 @@
 
 	set_fs(KERNEL_DS);
 	lock_kernel();
-	ret = do_sysctl(namep, a32.nlen, oldvalp, &oldlen, newvalp, (size_t) a32.newlen);
+	ret = do_sysctl(namep, a32.nlen, oldvalp, (size_t __user *) &oldlen,
+			newvalp, (size_t) a32.newlen);
 	unlock_kernel();
 	set_fs(old_fs);
 
-	if (oldvalp && put_user (oldlen, (int *) A(a32.oldlenp)))
+	if (oldvalp && put_user (oldlen, (int __user *) compat_ptr(a32.oldlenp)))
 		return -EFAULT;
 
 	return ret;
@@ -2035,7 +2038,7 @@
 }
 
 asmlinkage long
-sys32_newuname (struct new_utsname *name)
+sys32_newuname (struct new_utsname __user *name)
 {
 	int ret = sys_newuname(name);
 
@@ -2046,14 +2049,14 @@
 }
 
 asmlinkage long
-sys32_getresuid16 (u16 *ruid, u16 *euid, u16 *suid)
+sys32_getresuid16 (u16 __user *ruid, u16 __user *euid, u16 __user *suid)
 {
 	uid_t a, b, c;
 	int ret;
 	mm_segment_t old_fs = get_fs();
 
 	set_fs(KERNEL_DS);
-	ret = sys_getresuid(&a, &b, &c);
+	ret = sys_getresuid((uid_t __user *) &a, (uid_t __user *) &b, (uid_t __user *) &c);
 	set_fs(old_fs);
 
 	if (put_user(a, ruid) || put_user(b, euid) || put_user(c, suid))
@@ -2062,14 +2065,14 @@
 }
 
 asmlinkage long
-sys32_getresgid16 (u16 *rgid, u16 *egid, u16 *sgid)
+sys32_getresgid16 (u16 __user *rgid, u16 __user *egid, u16 __user *sgid)
 {
 	gid_t a, b, c;
 	int ret;
 	mm_segment_t old_fs = get_fs();
 
 	set_fs(KERNEL_DS);
-	ret = sys_getresgid(&a, &b, &c);
+	ret = sys_getresgid((gid_t __user *) &a, (gid_t __user *) &b, (gid_t __user *) &c);
 	set_fs(old_fs);
 
 	if (ret)
@@ -2086,7 +2089,7 @@
 }
 
 static int
-groups16_to_user(short *grouplist, struct group_info *group_info)
+groups16_to_user(short __user *grouplist, struct group_info *group_info)
 {
 	int i;
 	short group;
@@ -2101,7 +2104,7 @@
 }
 
 static int
-groups16_from_user(struct group_info *group_info, short *grouplist)
+groups16_from_user(struct group_info *group_info, short __user *grouplist)
 {
 	int i;
 	short group;
@@ -2116,7 +2119,7 @@
 }
 
 asmlinkage long
-sys32_getgroups16 (int gidsetsize, short *grouplist)
+sys32_getgroups16 (int gidsetsize, short __user *grouplist)
 {
 	int i;
 
@@ -2141,7 +2144,7 @@
 }
 
 asmlinkage long
-sys32_setgroups16 (int gidsetsize, short *grouplist)
+sys32_setgroups16 (int gidsetsize, short __user *grouplist)
 {
 	struct group_info *group_info;
 	int retval;
@@ -2169,7 +2172,7 @@
 asmlinkage long
 sys32_truncate64 (unsigned int path, unsigned int len_lo, unsigned int len_hi)
 {
-	return sys_truncate((const char *) A(path), ((unsigned long) len_hi << 32) | len_lo);
+	return sys_truncate(compat_ptr(path), ((unsigned long) len_hi << 32) | len_lo);
 }
 
 asmlinkage long
@@ -2179,7 +2182,7 @@
 }
 
 static int
-putstat64 (struct stat64 *ubuf, struct kstat *kbuf)
+putstat64 (struct stat64 __user *ubuf, struct kstat *kbuf)
 {
 	int err;
 	u64 hdev;
@@ -2188,8 +2191,8 @@
 		return -EFAULT;
 
 	hdev = huge_encode_dev(kbuf->dev);
-	err  = __put_user(hdev, (u32*)&ubuf->st_dev);
-	err |= __put_user(hdev >> 32, ((u32*)&ubuf->st_dev) + 1);
+	err  = __put_user(hdev, (u32 __user*)&ubuf->st_dev);
+	err |= __put_user(hdev >> 32, ((u32 __user*)&ubuf->st_dev) + 1);
 	err |= __put_user(kbuf->ino, &ubuf->__st_ino);
 	err |= __put_user(kbuf->ino, &ubuf->st_ino_lo);
 	err |= __put_user(kbuf->ino >> 32, &ubuf->st_ino_hi);
@@ -2198,8 +2201,8 @@
 	err |= __put_user(kbuf->uid, &ubuf->st_uid);
 	err |= __put_user(kbuf->gid, &ubuf->st_gid);
 	hdev = huge_encode_dev(kbuf->rdev);
-	err  = __put_user(hdev, (u32*)&ubuf->st_rdev);
-	err |= __put_user(hdev >> 32, ((u32*)&ubuf->st_rdev) + 1);
+	err  = __put_user(hdev, (u32 __user*)&ubuf->st_rdev);
+	err |= __put_user(hdev >> 32, ((u32 __user*)&ubuf->st_rdev) + 1);
 	err |= __put_user(kbuf->size, &ubuf->st_size_lo);
 	err |= __put_user((kbuf->size >> 32), &ubuf->st_size_hi);
 	err |= __put_user(kbuf->atime.tv_sec, &ubuf->st_atime);
@@ -2214,7 +2217,7 @@
 }
 
 asmlinkage long
-sys32_stat64 (char *filename, struct stat64 *statbuf)
+sys32_stat64 (char __user *filename, struct stat64 __user *statbuf)
 {
 	struct kstat s;
 	long ret = vfs_stat(filename, &s);
@@ -2224,7 +2227,7 @@
 }
 
 asmlinkage long
-sys32_lstat64 (char *filename, struct stat64 *statbuf)
+sys32_lstat64 (char __user *filename, struct stat64 __user *statbuf)
 {
 	struct kstat s;
 	long ret = vfs_lstat(filename, &s);
@@ -2234,7 +2237,7 @@
 }
 
 asmlinkage long
-sys32_fstat64 (unsigned int fd, struct stat64 *statbuf)
+sys32_fstat64 (unsigned int fd, struct stat64 __user *statbuf)
 {
 	struct kstat s;
 	long ret = vfs_fstat(fd, &s);
@@ -2261,7 +2264,7 @@
 };
 
 asmlinkage long
-sys32_sysinfo (struct sysinfo32 *info)
+sys32_sysinfo (struct sysinfo32 __user *info)
 {
 	struct sysinfo s;
 	long ret, err;
@@ -2269,7 +2272,7 @@
 	mm_segment_t old_fs = get_fs();
 
 	set_fs(KERNEL_DS);
-	ret = sys_sysinfo(&s);
+	ret = sys_sysinfo((struct sysinfo __user *) &s);
 	set_fs(old_fs);
 	/* Check to see if any memory value is too large for 32-bit and
 	 * scale down if needed.
@@ -2312,14 +2315,14 @@
 }
 
 asmlinkage long
-sys32_sched_rr_get_interval (pid_t pid, struct compat_timespec *interval)
+sys32_sched_rr_get_interval (pid_t pid, struct compat_timespec __user *interval)
 {
 	mm_segment_t old_fs = get_fs();
 	struct timespec t;
 	long ret;
 
 	set_fs(KERNEL_DS);
-	ret = sys_sched_rr_get_interval(pid, &t);
+	ret = sys_sched_rr_get_interval(pid, (struct timespec __user *) &t);
 	set_fs(old_fs);
 	if (put_compat_timespec(&t, interval))
 		return -EFAULT;
@@ -2327,19 +2330,19 @@
 }
 
 asmlinkage long
-sys32_pread (unsigned int fd, void *buf, unsigned int count, u32 pos_lo, u32 pos_hi)
+sys32_pread (unsigned int fd, void __user *buf, unsigned int count, u32 pos_lo, u32 pos_hi)
 {
 	return sys_pread64(fd, buf, count, ((unsigned long) pos_hi << 32) | pos_lo);
 }
 
 asmlinkage long
-sys32_pwrite (unsigned int fd, void *buf, unsigned int count, u32 pos_lo, u32 pos_hi)
+sys32_pwrite (unsigned int fd, void __user *buf, unsigned int count, u32 pos_lo, u32 pos_hi)
 {
 	return sys_pwrite64(fd, buf, count, ((unsigned long) pos_hi << 32) | pos_lo);
 }
 
 asmlinkage long
-sys32_sendfile (int out_fd, int in_fd, int *offset, unsigned int count)
+sys32_sendfile (int out_fd, int in_fd, int __user *offset, unsigned int count)
 {
 	mm_segment_t old_fs = get_fs();
 	long ret;
@@ -2349,7 +2352,7 @@
 		return -EFAULT;
 
 	set_fs(KERNEL_DS);
-	ret = sys_sendfile(out_fd, in_fd, offset ? &of : NULL, count);
+	ret = sys_sendfile(out_fd, in_fd, offset ? (off_t __user *) &of : NULL, count);
 	set_fs(old_fs);
 
 	if (!ret && offset && put_user(of, offset))
@@ -2380,7 +2383,7 @@
 	obrk = mm->brk;
 	ret = sys_brk(brk);
 	if (ret < obrk)
-		clear_user((void *) ret, PAGE_ALIGN(ret) - ret);
+		clear_user(compat_ptr(ret), PAGE_ALIGN(ret) - ret);
 	return ret;
 }
 
@@ -2388,7 +2391,7 @@
  * Exactly like fs/open.c:sys_open(), except that it doesn't set the O_LARGEFILE flag.
  */
 asmlinkage long
-sys32_open (const char * filename, int flags, int mode)
+sys32_open (const char __user * filename, int flags, int mode)
 {
 	char * tmp;
 	int fd, error;
@@ -2420,10 +2423,10 @@
 {
 	u32 events;
 	u32 data[2];
-}; 
+};
 
 asmlinkage long
-sys32_epoll_ctl(int epfd, int op, int fd, struct epoll_event32 *event)
+sys32_epoll_ctl(int epfd, int op, int fd, struct epoll_event32 __user *event)
 {
 	mm_segment_t old_fs = get_fs();
 	struct epoll_event event64;
@@ -2441,14 +2444,14 @@
  	event64.data |= (u64)data_halfword << 32;
 
 	set_fs(KERNEL_DS);
-	error = sys_epoll_ctl(epfd, op, fd, &event64);
+	error = sys_epoll_ctl(epfd, op, fd, (struct epoll_event __user *) &event64);
 	set_fs(old_fs);
 
 	return error;
 }
 
 asmlinkage long
-sys32_epoll_wait(int epfd, struct epoll_event32 *events, int maxevents,
+sys32_epoll_wait(int epfd, struct epoll_event32 __user * events, int maxevents,
 		 int timeout)
 {
 	struct epoll_event *events64 = NULL;
@@ -2466,8 +2469,8 @@
 				 maxevents * sizeof(struct epoll_event32))))
 		return error;
 
-	/* 
- 	 * Allocate space for the intermediate copy.  If the space needed 
+	/*
+ 	 * Allocate space for the intermediate copy.  If the space needed
 	 * is large enough to cause kmalloc to fail, then try again with
 	 * __get_free_pages.
 	 */
@@ -2476,14 +2479,15 @@
 	if (events64 == NULL) {
 		events64 = (struct epoll_event *)
 				__get_free_pages(GFP_KERNEL, get_order(size));
-		if (events64 == NULL) 
+		if (events64 == NULL)
 			return -ENOMEM;
 		do_free_pages = 1;
 	}
 
 	/* Do the system call */
 	set_fs(KERNEL_DS); /* copy_to/from_user should work on kernel mem*/
-	numevents = sys_epoll_wait(epfd, events64, maxevents, timeout);
+	numevents = sys_epoll_wait(epfd, (struct epoll_event __user *) events64,
+				   maxevents, timeout);
 	set_fs(old_fs);
 
 	/* Don't modify userspace memory if we're returning an error */
@@ -2526,7 +2530,7 @@
  * Set a given TLS descriptor:
  */
 asmlinkage int
-sys32_set_thread_area (struct ia32_user_desc *u_info)
+sys32_set_thread_area (struct ia32_user_desc __user *u_info)
 {
 	struct thread_struct *t = &current->thread;
 	struct ia32_user_desc info;
@@ -2587,7 +2591,7 @@
 #define GET_USEABLE(desc)	(((desc)->b >> 20) & 1)
 
 asmlinkage int
-sys32_get_thread_area (struct ia32_user_desc *u_info)
+sys32_get_thread_area (struct ia32_user_desc __user *u_info)
 {
 	struct ia32_user_desc info;
 	struct desc_struct *desc;
@@ -2615,12 +2619,8 @@
 	return 0;
 }
 
-extern asmlinkage long
-sys_timer_create(clockid_t which_clock, struct sigevent *timer_event_spec,
-		 timer_t * created_timer_id);
-
 asmlinkage long
-sys32_timer_create(u32 clock, struct sigevent32 *se32, timer_t *timer_id)
+sys32_timer_create(u32 clock, struct sigevent32 __user *se32, timer_t __user *timer_id)
 {
 	struct sigevent se;
 	mm_segment_t oldfs;
@@ -2643,7 +2643,7 @@
 
 	oldfs = get_fs();
 	set_fs(KERNEL_DS);
-	err = sys_timer_create(clock, &se, &t);
+	err = sys_timer_create(clock, (struct sigevent __user *) &se, (timer_t __user *) &t);
 	set_fs(oldfs);
 
 	if (!err)

--------------070806060607010204040401--
