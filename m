From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 27 Sep 2001 01:20:24 +0000
Subject: [Linux-ia64] [PATCH] important bug fix
Message-Id: <marc-linux-ia64-105590698805263@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Yesterday, I discovered that the ia32 subsystem is missing support for
the regular sigsuspend() system call (newer versions of glibc use
rt_sigsuspend()).  When looking at the existing ia32 rt_sigsuspend()
code, I realized that it was wrong and shouldn't work at all.  Turns
the reason it worked was because there was a missing access_ok() in
sys_rt_sigsuspend().  Ouch!  This is a serious bug as it creates a
security hole.  The patch below fixes this problem and updates the
ia32 subsystem accordingly.

Anyhow interested in writing (or enhancing an existing) kernel
validation suite which will verify that all system calls return
-EFAULT for illegal pointer arguments?  Bugs like these could be
caught very easily...

	--david

diff -urN lia64/arch/ia64/ia32/ia32_entry.S lia64-kdb/arch/ia64/ia32/ia32_entry.S
--- lia64/arch/ia64/ia32/ia32_entry.S	Mon Sep 24 21:44:23 2001
+++ lia64-kdb/arch/ia64/ia32/ia32_entry.S	Wed Sep 26 17:44:51 2001
@@ -48,31 +48,43 @@
 	br.ret.sptk.many rp
 END(ia32_clone)
 
-	//
-	// Get possibly unaligned sigmask argument into an aligned
-	//   kernel buffer
-GLOBAL_ENTRY(ia32_rt_sigsuspend)
-	// We'll cheat and not do an alloc here since we are ultimately
-	// going to do a simple branch to the IA64 sys_rt_sigsuspend.
-	// r32 is still the first argument which is the signal mask.
-	// We copy this 4-byte aligned value to an 8-byte aligned buffer
-	// in the task structure and then jump to the IA64 code.
-	zxt4 r32=r32
-	;;
-	EX(.Lfail, ld4 r2=[r32],4)		// load low part of sigmask
-	;;
-	EX(.Lfail, ld4 r3=[r32])		// load high part of sigmask
-	adds r32=IA64_TASK_THREAD_SIGMASK_OFFSET,r13
-	;;
-	st8 [r32]=r2
-	adds r10=IA64_TASK_THREAD_SIGMASK_OFFSET+4,r13
+ENTRY(sys32_rt_sigsuspend)
+	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(8)
+	alloc loc1=ar.pfs,8,2,3,0		// preserve all eight input regs
+	mov loc0=rp
+	mov out0=in0				// mask
+	mov out1=in1				// sigsetsize
+	mov out2=sp				// out2 = &sigscratch
+	.fframe 16
+	adds sp=-16,sp				// allocate dummy "sigscratch"
 	;;
+	.body
+	br.call.sptk.many rp=ia32_rt_sigsuspend
+1:	.restore sp
+	adds sp,sp
+	mov rp=loc0
+	mov ar.pfs=loc1
+	br.ret.sptk.many rp
+END(sys32_rt_sigsuspend)
 
-	st4 [r10]=r3
-	br.cond.sptk.many sys_rt_sigsuspend
-
-.Lfail:	br.ret.sptk.many rp	// failed to read sigmask
-END(ia32_rt_sigsuspend)
+ENTRY(sys32_sigsuspend)
+	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(8)
+	alloc r2=ar.pfs,8,2,3,0			// preserve all eight input regs
+	mov loc0=rp
+	mov out0=in0				// mask
+	mov out1=4				// sigsetsize
+	;;
+	mov out2=sp				// out2 = &sigscratch
+	.fframe 16
+	adds sp=-16,sp				// allocate dummy "sigscratch"
+	.body
+	br.call.sptk.many rp=ia32_rt_sigsuspend
+1:	.restore sp
+	adds sp,sp
+	mov rp=loc0
+	mov ar.pfs=loc1
+	br.ret.sptk.many rp
+END(sys32_sigsuspend)
 
 GLOBAL_ENTRY(ia32_ret_from_clone)
 	PT_REGS_UNWIND_INFO(0)
@@ -236,7 +248,7 @@
 	data8 sys32_ni_syscall
 	data8 sys_setreuid	/* 16-bit version */	  /* 70 */
 	data8 sys_setregid	/* 16-bit version */
-	data8 sys32_ni_syscall
+	data8 sys32_sigsuspend
 	data8 sys32_sigpending
 	data8 sys_sethostname
 	data8 sys32_setrlimit	  /* 75 */
@@ -343,7 +355,7 @@
 	data8 sys_rt_sigpending
 	data8 sys32_rt_sigtimedwait
 	data8 sys32_rt_sigqueueinfo
-	data8 ia32_rt_sigsuspend
+	data8 sys32_rt_sigsuspend
 	data8 sys32_pread	  /* 180 */
 	data8 sys32_pwrite
 	data8 sys_chown	/* 16-bit version */
diff -urN lia64/arch/ia64/ia32/ia32_signal.c lia64-kdb/arch/ia64/ia32/ia32_signal.c
--- lia64/arch/ia64/ia32/ia32_signal.c	Mon Sep 24 21:45:00 2001
+++ lia64-kdb/arch/ia64/ia32/ia32_signal.c	Wed Sep 26 16:54:44 2001
@@ -29,6 +29,10 @@
 #include <asm/segment.h>
 #include <asm/ia32.h>
 
+#include "../kernel/sigframe.h"
+
+#define A(__x)		((unsigned long)(__x))
+
 #define DEBUG_SIG	0
 #define _BLOCKABLE	(~(sigmask(SIGKILL) | sigmask(SIGSTOP)))
 
@@ -139,7 +143,220 @@
 	return err;
 }
 
+static inline void
+sigact_set_handler (struct k_sigaction *sa, unsigned int handler, unsigned int restorer)
+{
+	if (handler + 1 <= 2)
+		/* SIG_DFL, SIG_IGN, or SIG_ERR: must sign-extend to 64-bits */
+		sa->sa.sa_handler = (__sighandler_t) A((int) handler);
+	else
+		sa->sa.sa_handler = (__sighandler_t) (((unsigned long) restorer << 32) | handler);
+}
+
+asmlinkage long
+ia32_rt_sigsuspend (sigset32_t *uset, unsigned int sigsetsize, struct sigscratch *scr)
+{
+	extern long ia64_do_signal (sigset_t *oldset, struct sigscratch *scr, long in_syscall);
+	sigset_t oldset, set;
+
+	scr->scratch_unat = 0;	/* avoid leaking kernel bits to user level */
+	memset(&set.sig, 0, sizeof(&set.sig));
+
+	if (sigsetsize > sizeof(sigset_t))
+		return -EINVAL;
+
+	if (copy_from_user(&set.sig, &uset->sig, sigsetsize))
+		return -EFAULT;
+
+	sigdelsetmask(&set, ~_BLOCKABLE);
+
+	spin_lock_irq(&current->sigmask_lock);
+	{
+		oldset = current->blocked;
+		current->blocked = set;
+		recalc_sigpending(current);
+	}
+	spin_unlock_irq(&current->sigmask_lock);
+
+	/*
+	 * The return below usually returns to the signal handler.  We need to pre-set the
+	 * correct error code here to ensure that the right values get saved in sigcontext
+	 * by ia64_do_signal.
+	 */
+	scr->pt.r8 = -EINTR;
+	while (1) {
+		current->state = TASK_INTERRUPTIBLE;
+		schedule();
+		if (ia64_do_signal(&oldset, scr, 1))
+			return -EINTR;
+	}
+}
+
+asmlinkage long
+sys32_signal (int sig, unsigned int handler)
+{
+	struct k_sigaction new_sa, old_sa;
+	int ret;
+
+	sigact_set_handler(&new_sa, handler, 0);
+	new_sa.sa.sa_flags = SA_ONESHOT | SA_NOMASK;
+
+	ret = do_sigaction(sig, &new_sa, &old_sa);
+
+	return ret ? ret : IA32_SA_HANDLER(&old_sa);
+}
+
+asmlinkage long
+sys32_rt_sigaction (int sig, struct sigaction32 *act,
+		    struct sigaction32 *oact, unsigned int sigsetsize)
+{
+	struct k_sigaction new_ka, old_ka;
+	unsigned int handler, restorer;
+	int ret;
+
+	/* XXX: Don't preclude handling different sized sigset_t's.  */
+	if (sigsetsize != sizeof(sigset32_t))
+		return -EINVAL;
+
+	if (act) {
+		ret = get_user(handler, &act->sa_handler);
+		ret |= get_user(new_ka.sa.sa_flags, &act->sa_flags);
+		ret |= get_user(restorer, &act->sa_restorer);
+		ret |= copy_from_user(&new_ka.sa.sa_mask, &act->sa_mask, sizeof(sigset32_t));
+		if (ret)
+			return -EFAULT;
+
+		sigact_set_handler(&new_ka, handler, restorer);
+	}
+
+	ret = do_sigaction(sig, act ? &new_ka : NULL, oact ? &old_ka : NULL);
+
+	if (!ret && oact) {
+		ret = put_user(IA32_SA_HANDLER(&old_ka), &oact->sa_handler);
+		ret |= put_user(old_ka.sa.sa_flags, &oact->sa_flags);
+		ret |= put_user(IA32_SA_RESTORER(&old_ka), &oact->sa_restorer);
+		ret |= copy_to_user(&oact->sa_mask, &old_ka.sa.sa_mask, sizeof(sigset32_t));
+	}
+	return ret;
+}
+
+
+extern asmlinkage long sys_rt_sigprocmask (int how, sigset_t *set, sigset_t *oset,
+					   size_t sigsetsize);
+
+asmlinkage long
+sys32_rt_sigprocmask (int how, sigset32_t *set, sigset32_t *oset, unsigned int sigsetsize)
+{
+	mm_segment_t old_fs = get_fs();
+	sigset_t s;
+	long ret;
+
+	if (sigsetsize > sizeof(s))
+		return -EINVAL;
+
+	if (set) {
+		memset(&s, 0, sizeof(s));
+		if (copy_from_user(&s.sig, set, sigsetsize))
+			return -EFAULT;
+	}
+	set_fs(KERNEL_DS);
+	ret = sys_rt_sigprocmask(how, set ? &s : NULL, oset ? &s : NULL, sizeof(s));
+	set_fs(old_fs);
+	if (ret)
+		return ret;
+	if (oset) {
+		if (copy_to_user(oset, &s.sig, sigsetsize))
+			return -EFAULT;
+	}
+	return 0;
+}
+
+asmlinkage long
+sys32_sigprocmask (int how, unsigned int *set, unsigned int *oset)
+{
+	return sys32_rt_sigprocmask(how, (sigset32_t *) set, (sigset32_t *) oset, sizeof(*set));
+}
+
+asmlinkage long
+sys32_rt_sigtimedwait (sigset32_t *uthese, siginfo_t32 *uinfo, struct timespec32 *uts,
+		       unsigned int sigsetsize)
+{
+	extern asmlinkage long sys_rt_sigtimedwait (const sigset_t *, siginfo_t *,
+						    const struct timespec *, size_t);
+	extern int copy_siginfo_to_user32 (siginfo_t32 *, siginfo_t *);
+	mm_segment_t old_fs = get_fs();
+	struct timespec t;
+	siginfo_t info;
+	sigset_t s;
+	int ret;
+
+	if (copy_from_user(&s.sig, uthese, sizeof(sigset32_t)))
+		return -EFAULT;
+	if (uts) {
+		ret = get_user(t.tv_sec, &uts->tv_sec);
+		ret |= get_user(t.tv_nsec, &uts->tv_nsec);
+		if (ret)
+			return -EFAULT;
+	}
+	set_fs(KERNEL_DS);
+	ret = sys_rt_sigtimedwait(&s, &info, &t, sigsetsize);
+	set_fs(old_fs);
+	if (ret >= 0 && uinfo) {
+		if (copy_siginfo_to_user32(uinfo, &info))
+			return -EFAULT;
+	}
+	return ret;
+}
+
+asmlinkage long
+sys32_rt_sigqueueinfo (int pid, int sig, siginfo_t32 *uinfo)
+{
+	extern asmlinkage long sys_rt_sigqueueinfo (int, int, siginfo_t *);
+	extern int copy_siginfo_from_user32 (siginfo_t *to, siginfo_t32 *from);
+	mm_segment_t old_fs = get_fs();
+	siginfo_t info;
+	int ret;
+
+	if (copy_siginfo_from_user32(&info, uinfo))
+		return -EFAULT;
+	set_fs(KERNEL_DS);
+	ret = sys_rt_sigqueueinfo(pid, sig, &info);
+	set_fs(old_fs);
+	return ret;
+}
 
+asmlinkage long
+sys32_sigaction (int sig, struct old_sigaction32 *act, struct old_sigaction32 *oact)
+{
+	struct k_sigaction new_ka, old_ka;
+	unsigned int handler, restorer;
+	int ret;
+
+	if (act) {
+		old_sigset32_t mask;
+
+		ret = get_user(handler, &act->sa_handler);
+		ret |= get_user(new_ka.sa.sa_flags, &act->sa_flags);
+		ret |= get_user(restorer, &act->sa_restorer);
+		ret |= get_user(mask, &act->sa_mask);
+		if (ret)
+			return ret;
+
+		sigact_set_handler(&new_ka, handler, restorer);
+		siginitset(&new_ka.sa.sa_mask, mask);
+	}
+
+	ret = do_sigaction(sig, act ? &new_ka : NULL, oact ? &old_ka : NULL);
+
+	if (!ret && oact) {
+		ret = put_user(IA32_SA_HANDLER(&old_ka), &oact->sa_handler);
+		ret |= put_user(old_ka.sa.sa_flags, &oact->sa_flags);
+		ret |= put_user(IA32_SA_RESTORER(&old_ka), &oact->sa_restorer);
+		ret |= put_user(old_ka.sa.sa_mask.sig[0], &oact->sa_mask);
+	}
+
+	return ret;
+}
 
 static int
 setup_sigcontext_ia32 (struct sigcontext_ia32 *sc, struct _fpstate_ia32 *fpstate,
diff -urN lia64/arch/ia64/ia32/sys_ia32.c lia64-kdb/arch/ia64/ia32/sys_ia32.c
--- lia64/arch/ia64/ia32/sys_ia32.c	Mon Sep 24 21:45:20 2001
+++ lia64-kdb/arch/ia64/ia32/sys_ia32.c	Wed Sep 26 16:36:20 2001
@@ -538,154 +538,6 @@
 	return retval;
 }
 
-static inline void
-sigact_set_handler (struct k_sigaction *sa, unsigned int handler, unsigned int restorer)
-{
-	if (handler + 1 <= 2)
-		/* SIG_DFL, SIG_IGN, or SIG_ERR: must sign-extend to 64-bits */
-		sa->sa.sa_handler = (__sighandler_t) A((int) handler);
-	else
-		sa->sa.sa_handler = (__sighandler_t) (((unsigned long) restorer << 32) | handler);
-}
-
-asmlinkage long
-sys32_signal (int sig, unsigned int handler)
-{
-	struct k_sigaction new_sa, old_sa;
-	int ret;
-
-	sigact_set_handler(&new_sa, handler, 0);
-	new_sa.sa.sa_flags = SA_ONESHOT | SA_NOMASK;
-
-	ret = do_sigaction(sig, &new_sa, &old_sa);
-
-	return ret ? ret : IA32_SA_HANDLER(&old_sa);
-}
-
-asmlinkage long
-sys32_rt_sigaction (int sig, struct sigaction32 *act,
-		    struct sigaction32 *oact, unsigned int sigsetsize)
-{
-	struct k_sigaction new_ka, old_ka;
-	unsigned int handler, restorer;
-	int ret;
-
-	/* XXX: Don't preclude handling different sized sigset_t's.  */
-	if (sigsetsize != sizeof(sigset32_t))
-		return -EINVAL;
-
-	if (act) {
-		ret = get_user(handler, &act->sa_handler);
-		ret |= get_user(new_ka.sa.sa_flags, &act->sa_flags);
-		ret |= get_user(restorer, &act->sa_restorer);
-		ret |= copy_from_user(&new_ka.sa.sa_mask, &act->sa_mask, sizeof(sigset32_t));
-		if (ret)
-			return -EFAULT;
-
-		sigact_set_handler(&new_ka, handler, restorer);
-	}
-
-	ret = do_sigaction(sig, act ? &new_ka : NULL, oact ? &old_ka : NULL);
-
-	if (!ret && oact) {
-		ret = put_user(IA32_SA_HANDLER(&old_ka), &oact->sa_handler);
-		ret |= put_user(old_ka.sa.sa_flags, &oact->sa_flags);
-		ret |= put_user(IA32_SA_RESTORER(&old_ka), &oact->sa_restorer);
-		ret |= copy_to_user(&oact->sa_mask, &old_ka.sa.sa_mask, sizeof(sigset32_t));
-	}
-	return ret;
-}
-
-
-extern asmlinkage long sys_rt_sigprocmask (int how, sigset_t *set, sigset_t *oset,
-					   size_t sigsetsize);
-
-asmlinkage long
-sys32_rt_sigprocmask (int how, sigset32_t *set, sigset32_t *oset, unsigned int sigsetsize)
-{
-	mm_segment_t old_fs = get_fs();
-	sigset_t s;
-	long ret;
-
-	if (sigsetsize > sizeof(s))
-		return -EINVAL;
-
-	if (set) {
-		memset(&s, 0, sizeof(s));
-		if (copy_from_user(&s.sig, set, sigsetsize))
-			return -EFAULT;
-	}
-	set_fs(KERNEL_DS);
-	ret = sys_rt_sigprocmask(how, set ? &s : NULL, oset ? &s : NULL, sizeof(s));
-	set_fs(old_fs);
-	if (ret)
-		return ret;
-	if (oset) {
-		if (copy_to_user(oset, &s.sig, sigsetsize))
-			return -EFAULT;
-	}
-	return 0;
-}
-
-asmlinkage long
-sys32_sigprocmask (int how, unsigned int *set, unsigned int *oset)
-{
-	return sys32_rt_sigprocmask(how, (sigset32_t *) set, (sigset32_t *) oset, sizeof(*set));
-}
-
-struct timespec32 {
-	int	tv_sec;
-	int	tv_nsec;
-};
-
-asmlinkage long
-sys32_rt_sigtimedwait (sigset32_t *uthese, siginfo_t32 *uinfo, struct timespec32 *uts,
-		       unsigned int sigsetsize)
-{
-	extern asmlinkage long sys_rt_sigtimedwait (const sigset_t *, siginfo_t *,
-						    const struct timespec *, size_t);
-	extern int copy_siginfo_to_user32 (siginfo_t32 *, siginfo_t *);
-	mm_segment_t old_fs = get_fs();
-	struct timespec t;
-	siginfo_t info;
-	sigset_t s;
-	int ret;
-
-	if (copy_from_user(&s.sig, uthese, sizeof(sigset32_t)))
-		return -EFAULT;
-	if (uts) {
-		ret = get_user(t.tv_sec, &uts->tv_sec);
-		ret |= get_user(t.tv_nsec, &uts->tv_nsec);
-		if (ret)
-			return -EFAULT;
-	}
-	set_fs(KERNEL_DS);
-	ret = sys_rt_sigtimedwait(&s, &info, &t, sigsetsize);
-	set_fs(old_fs);
-	if (ret >= 0 && uinfo) {
-		if (copy_siginfo_to_user32(uinfo, &info))
-			return -EFAULT;
-	}
-	return ret;
-}
-
-asmlinkage long
-sys32_rt_sigqueueinfo (int pid, int sig, siginfo_t32 *uinfo)
-{
-	extern asmlinkage long sys_rt_sigqueueinfo (int, int, siginfo_t *);
-	extern int copy_siginfo_from_user32 (siginfo_t *to, siginfo_t32 *from);
-	mm_segment_t old_fs = get_fs();
-	siginfo_t info;
-	int ret;
-
-	if (copy_siginfo_from_user32(&info, uinfo))
-		return -EFAULT;
-	set_fs(KERNEL_DS);
-	ret = sys_rt_sigqueueinfo(pid, sig, &info);
-	set_fs(old_fs);
-	return ret;
-}
-
 static inline int
 put_statfs (struct statfs32 *ubuf, struct statfs *kbuf)
 {
@@ -2694,39 +2546,6 @@
 		 */
 		return sys_fcntl(fd, cmd, arg);
 	}
-}
-
-asmlinkage long
-sys32_sigaction (int sig, struct old_sigaction32 *act, struct old_sigaction32 *oact)
-{
-	struct k_sigaction new_ka, old_ka;
-	unsigned int handler, restorer;
-	int ret;
-
-	if (act) {
-		old_sigset32_t mask;
-
-		ret = get_user(handler, &act->sa_handler);
-		ret |= get_user(new_ka.sa.sa_flags, &act->sa_flags);
-		ret |= get_user(restorer, &act->sa_restorer);
-		ret |= get_user(mask, &act->sa_mask);
-		if (ret)
-			return ret;
-
-		sigact_set_handler(&new_ka, handler, restorer);
-		siginitset(&new_ka.sa.sa_mask, mask);
-	}
-
-	ret = do_sigaction(sig, act ? &new_ka : NULL, oact ? &old_ka : NULL);
-
-	if (!ret && oact) {
-		ret = put_user(IA32_SA_HANDLER(&old_ka), &oact->sa_handler);
-		ret |= put_user(old_ka.sa.sa_flags, &oact->sa_flags);
-		ret |= put_user(IA32_SA_RESTORER(&old_ka), &oact->sa_restorer);
-		ret |= put_user(old_ka.sa.sa_mask.sig[0], &oact->sa_mask);
-	}
-
-	return ret;
 }
 
 asmlinkage long sys_ni_syscall(void);
diff -urN lia64/arch/ia64/kernel/sigframe.h lia64-kdb/arch/ia64/kernel/sigframe.h
--- lia64/arch/ia64/kernel/sigframe.h	Mon Sep 24 21:52:26 2001
+++ lia64-kdb/arch/ia64/kernel/sigframe.h	Wed Sep 26 16:32:49 2001
@@ -1,3 +1,9 @@
+struct sigscratch {
+	unsigned long scratch_unat;	/* ar.unat for the general registers saved in pt */
+	unsigned long pad;
+	struct pt_regs pt;
+};
+
 struct sigframe {
 	/*
 	 * Place signal handler args where user-level unwinder can find them easily.
diff -urN lia64/arch/ia64/kernel/signal.c lia64-kdb/arch/ia64/kernel/signal.c
--- lia64/arch/ia64/kernel/signal.c	Mon Sep 24 21:52:38 2001
+++ lia64-kdb/arch/ia64/kernel/signal.c	Wed Sep 26 16:32:46 2001
@@ -2,7 +2,7 @@
  * Architecture-specific signal handling support.
  *
  * Copyright (C) 1999-2001 Hewlett-Packard Co
- * Copyright (C) 1999-2001 David Mosberger-Tang <davidm@hpl.hp.com>
+ *	David Mosberger-Tang <davidm@hpl.hp.com>
  *
  * Derived from i386 and Alpha versions.
  */
@@ -39,12 +39,6 @@
 # define GET_SIGSET(k,u)	__get_user((k)->sig[0], &(u)->sig[0])
 #endif
 
-struct sigscratch {
-	unsigned long scratch_unat;	/* ar.unat for the general registers saved in pt */
-	unsigned long pad;
-	struct pt_regs pt;
-};
-
 extern long ia64_do_signal (sigset_t *, struct sigscratch *, long);	/* forward decl */
 
 long
@@ -55,6 +49,10 @@
 	/* XXX: Don't preclude handling different sized sigset_t's.  */
 	if (sigsetsize != sizeof(sigset_t))
 		return -EINVAL;
+
+	if (!access_ok(VERIFY_READ, uset, sigsetsize))
+		return -EFAULT;
+
 	if (GET_SIGSET(&set, uset))
 		return -EFAULT;
 
@@ -73,15 +71,9 @@
 	 * pre-set the correct error code here to ensure that the right values
 	 * get saved in sigcontext by ia64_do_signal.
 	 */
-#ifdef CONFIG_IA32_SUPPORT
-        if (IS_IA32_PROCESS(&scr->pt)) {
-                scr->pt.r8 = -EINTR;
-        } else
-#endif
-	{
-		scr->pt.r8 = EINTR;
-		scr->pt.r10 = -1;
-	}
+	scr->pt.r8 = EINTR;
+	scr->pt.r10 = -1;
+
 	while (1) {
 		current->state = TASK_INTERRUPTIBLE;
 		schedule();
diff -urN lia64/include/asm-ia64/ia32.h lia64-kdb/include/asm-ia64/ia32.h
--- lia64/include/asm-ia64/ia32.h	Mon Sep 24 22:56:58 2001
+++ lia64-kdb/include/asm-ia64/ia32.h	Wed Sep 26 16:34:37 2001
@@ -39,6 +39,11 @@
 #define IA32_CLOCKS_PER_SEC	100	/* Cast in stone for IA32 Linux */
 #define IA32_TICK(tick)		((unsigned long long)(tick) * IA32_CLOCKS_PER_SEC / CLOCKS_PER_SEC)
 
+struct timespec32 {
+	int	tv_sec;
+	int	tv_nsec;
+};
+
 /* fcntl.h */
 struct flock32 {
        short l_type;
diff -urN lia64/include/asm-ia64/processor.h lia64-kdb/include/asm-ia64/processor.h
--- lia64/include/asm-ia64/processor.h	Mon Sep 24 22:26:48 2001
+++ lia64-kdb/include/asm-ia64/processor.h	Wed Sep 26 16:25:01 2001
@@ -347,10 +344,7 @@
 	__u64 ssd;			/* IA32 stack selector descriptor */
 	__u64 tssd;			/* IA32 TSS descriptor */
 	__u64 old_iob;			/* old IOBase value */
-	union {
-		__u64 sigmask;		/* aligned mask for sigsuspend scall */
-	} un;
-# define INIT_THREAD_IA32	0, 0, 0x17800000037fULL, 0, 0, 0, 0, 0, 0, {0},
+# define INIT_THREAD_IA32	0, 0, 0x17800000037fULL, 0, 0, 0, 0, 0, 0,
 #else
 # define INIT_THREAD_IA32
 #endif /* CONFIG_IA32_SUPPORT */

