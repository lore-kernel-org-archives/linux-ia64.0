From: Arun Sharma <arun.sharma@intel.com>
Date: Sat, 19 Apr 2003 00:29:47 +0000
Subject: [Linux-ia64] 32 bit syscall unification in 2.5
Message-Id: <marc-linux-ia64-105590723705570@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch was commited to Linus' tree a couple of days ago.

ChangeSet@1.1054.1.17, 2003-04-16 21:45:43-07:00, tausq@debian.org
  [PATCH] getrlimit,setrlimit,getrusage,wait4 unification

(Note: the changeset numbers could change over time. To lookup the
above change at a later date, you may need to use this key:
tausq@debian.org|ChangeSet|20030417044543|02530 )

Changes were made to many architectures, but not ia64. The attached
patch makes a rougly equivalent change to ia64.

	-Arun

=== arch/ia64/ia32/ia32_entry.S 1.22 vs edited ==--- 1.22/arch/ia64/ia32/ia32_entry.S	Mon Apr 14 22:07:43 2003
+++ edited/arch/ia64/ia32/ia32_entry.S	Thu Apr 17 18:33:31 2003
@@ -273,9 +273,9 @@
 	data8 sys32_sigsuspend
 	data8 compat_sys_sigpending
 	data8 sys_sethostname
-	data8 sys32_setrlimit	  /* 75 */
-	data8 sys32_old_getrlimit
-	data8 sys32_getrusage
+	data8 compat_sys_setrlimit	  /* 75 */
+	data8 compat_sys_old_getrlimit
+	data8 compat_sys_getrusage
 	data8 sys32_gettimeofday
 	data8 sys32_settimeofday
 	data8 sys32_getgroups16	  /* 80 */
@@ -312,7 +312,7 @@
 	data8 sys_vhangup
 	data8 sys32_ni_syscall		/* used to be sys_idle */
 	data8 sys32_ni_syscall
-	data8 sys32_wait4
+	data8 compat_sys_wait4
 	data8 sys_swapoff	  /* 115 */
 	data8 sys32_sysinfo
 	data8 sys32_ipc
@@ -389,7 +389,7 @@
 	data8 sys32_ni_syscall		  /* streams1 */
 	data8 sys32_ni_syscall		  /* streams2 */
 	data8 sys32_vfork	  /* 190 */
-	data8 sys32_getrlimit
+	data8 compat_sys_getrlimit
 	data8 sys32_mmap2
 	data8 sys32_truncate64
 	data8 sys32_ftruncate64
=== arch/ia64/ia32/sys_ia32.c 1.49 vs edited ==--- 1.49/arch/ia64/ia32/sys_ia32.c	Wed Apr  9 11:51:34 2003
+++ edited/arch/ia64/ia32/sys_ia32.c	Thu Apr 17 18:54:18 2003
@@ -1005,77 +1005,6 @@
 	return ret;
 }
 
-#define RLIM_INFINITY32	0x7fffffff
-#define RESOURCE32(x) ((x > RLIM_INFINITY32) ? RLIM_INFINITY32 : x)
-
-struct rlimit32 {
-	int	rlim_cur;
-	int	rlim_max;
-};
-
-extern asmlinkage long sys_getrlimit (unsigned int resource, struct rlimit *rlim);
-
-asmlinkage long
-sys32_old_getrlimit (unsigned int resource, struct rlimit32 *rlim)
-{
-	mm_segment_t old_fs = get_fs();
-	struct rlimit r;
-	int ret;
-
-	set_fs(KERNEL_DS);
-	ret = sys_getrlimit(resource, &r);
-	set_fs(old_fs);
-	if (!ret) {
-		ret = put_user(RESOURCE32(r.rlim_cur), &rlim->rlim_cur);
-		ret |= put_user(RESOURCE32(r.rlim_max), &rlim->rlim_max);
-	}
-	return ret;
-}
-
-asmlinkage long
-sys32_getrlimit (unsigned int resource, struct rlimit32 *rlim)
-{
-	mm_segment_t old_fs = get_fs();
-	struct rlimit r;
-	int ret;
-
-	set_fs(KERNEL_DS);
-	ret = sys_getrlimit(resource, &r);
-	set_fs(old_fs);
-	if (!ret) {
-		if (r.rlim_cur >= 0xffffffff)
-			r.rlim_cur = 0xffffffff;
-		if (r.rlim_max >= 0xffffffff)
-			r.rlim_max = 0xffffffff;
-		ret = put_user(r.rlim_cur, &rlim->rlim_cur);
-		ret |= put_user(r.rlim_max, &rlim->rlim_max);
-	}
-	return ret;
-}
-
-extern asmlinkage long sys_setrlimit (unsigned int resource, struct rlimit *rlim);
-
-asmlinkage long
-sys32_setrlimit (unsigned int resource, struct rlimit32 *rlim)
-{
-	struct rlimit r;
-	int ret;
-	mm_segment_t old_fs = get_fs();
-
-	if (resource >= RLIM_NLIMITS)
-		return -EINVAL;
-	if (get_user(r.rlim_cur, &rlim->rlim_cur) || get_user(r.rlim_max, &rlim->rlim_max))
-		return -EFAULT;
-	if (r.rlim_cur = RLIM_INFINITY32)
-		r.rlim_cur = RLIM_INFINITY;
-	if (r.rlim_max = RLIM_INFINITY32)
-		r.rlim_max = RLIM_INFINITY;
-	set_fs(KERNEL_DS);
-	ret = sys_setrlimit(resource, &r);
-	set_fs(old_fs);
-	return ret;
-}
-
 /*
  * sys32_ipc() is the de-multiplexer for the SysV IPC calls in 32bit emulation..
  *
@@ -1724,98 +1653,10 @@
 	return i;
 }
 
-struct rusage32 {
-	struct compat_timeval ru_utime;
-	struct compat_timeval ru_stime;
-	int    ru_maxrss;
-	int    ru_ixrss;
-	int    ru_idrss;
-	int    ru_isrss;
-	int    ru_minflt;
-	int    ru_majflt;
-	int    ru_nswap;
-	int    ru_inblock;
-	int    ru_oublock;
-	int    ru_msgsnd;
-	int    ru_msgrcv;
-	int    ru_nsignals;
-	int    ru_nvcsw;
-	int    ru_nivcsw;
-};
-
-static int
-put_rusage (struct rusage32 *ru, struct rusage *r)
-{
-	int err;
-
-	if (!access_ok(VERIFY_WRITE, ru, sizeof(*ru)))
-		return -EFAULT;
-
-	err = __put_user (r->ru_utime.tv_sec, &ru->ru_utime.tv_sec);
-	err |= __put_user (r->ru_utime.tv_usec, &ru->ru_utime.tv_usec);
-	err |= __put_user (r->ru_stime.tv_sec, &ru->ru_stime.tv_sec);
-	err |= __put_user (r->ru_stime.tv_usec, &ru->ru_stime.tv_usec);
-	err |= __put_user (r->ru_maxrss, &ru->ru_maxrss);
-	err |= __put_user (r->ru_ixrss, &ru->ru_ixrss);
-	err |= __put_user (r->ru_idrss, &ru->ru_idrss);
-	err |= __put_user (r->ru_isrss, &ru->ru_isrss);
-	err |= __put_user (r->ru_minflt, &ru->ru_minflt);
-	err |= __put_user (r->ru_majflt, &ru->ru_majflt);
-	err |= __put_user (r->ru_nswap, &ru->ru_nswap);
-	err |= __put_user (r->ru_inblock, &ru->ru_inblock);
-	err |= __put_user (r->ru_oublock, &ru->ru_oublock);
-	err |= __put_user (r->ru_msgsnd, &ru->ru_msgsnd);
-	err |= __put_user (r->ru_msgrcv, &ru->ru_msgrcv);
-	err |= __put_user (r->ru_nsignals, &ru->ru_nsignals);
-	err |= __put_user (r->ru_nvcsw, &ru->ru_nvcsw);
-	err |= __put_user (r->ru_nivcsw, &ru->ru_nivcsw);
-	return err;
-}
-
-asmlinkage long
-sys32_wait4 (int pid, unsigned int *stat_addr, int options, struct rusage32 *ru)
-{
-	if (!ru)
-		return sys_wait4(pid, stat_addr, options, NULL);
-	else {
-		struct rusage r;
-		int ret;
-		unsigned int status;
-		mm_segment_t old_fs = get_fs();
-
-		set_fs(KERNEL_DS);
-		ret = sys_wait4(pid, stat_addr ? &status : NULL, options, &r);
-		set_fs(old_fs);
-		if (put_rusage(ru, &r))
-			return -EFAULT;
-		if (stat_addr && put_user(status, stat_addr))
-			return -EFAULT;
-		return ret;
-	}
-}
-
 asmlinkage long
 sys32_waitpid (int pid, unsigned int *stat_addr, int options)
 {
-	return sys32_wait4(pid, stat_addr, options, NULL);
-}
-
-
-extern asmlinkage long sys_getrusage (int who, struct rusage *ru);
-
-asmlinkage long
-sys32_getrusage (int who, struct rusage32 *ru)
-{
-	struct rusage r;
-	int ret;
-	mm_segment_t old_fs = get_fs();
-
-	set_fs(KERNEL_DS);
-	ret = sys_getrusage(who, &r);
-	set_fs(old_fs);
-	if (put_rusage (ru, &r))
-		return -EFAULT;
-	return ret;
+	return compat_sys_wait4(pid, stat_addr, options, NULL);
 }
 
 static unsigned int
--- linux-2.5.67/include/asm-ia64/compat.h-	Fri Apr 18 14:18:17 2003
+++ linux-2.5.67/include/asm-ia64/compat.h	Fri Apr 18 14:18:38 2003
@@ -102,6 +102,9 @@
 	int		f_spare[6];
 };
 
+#define COMPAT_RLIM_OLD_INFINITY       0x7fffffff
+#define COMPAT_RLIM_INFINITY           0xffffffff
+
 typedef u32		compat_old_sigset_t;	/* at least 32 bits */
 
 #define _COMPAT_NSIG		64
--- linux-2.5.67/kernel/sys.c-	Fri Apr 18 14:21:34 2003
+++ linux-2.5.67/kernel/sys.c	Fri Apr 18 14:21:54 2003
@@ -1218,7 +1218,7 @@
 			? -EFAULT : 0;
 }
 
-#if !defined(__ia64__) && !defined(CONFIG_V850)
+#if !defined(CONFIG_V850)
 
 /*
  *	Back compatibility for getrlimit. Needed for some apps.


