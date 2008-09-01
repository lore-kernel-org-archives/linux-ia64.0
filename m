From: Christoph Hellwig <hch@lst.de>
Date: Mon, 01 Sep 2008 16:16:52 +0000
Subject: [PATCH] ia64: remove sys32_pause
Message-Id: <20080901161652.GB16121@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

It's just a duplicate of the native sys_pause, which we can use after
defining __ARCH_WANT_SYS_PAUSE.


Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/arch/ia64/ia32/ia32_entry.S
=================================--- linux-2.6.orig/arch/ia64/ia32/ia32_entry.S	2008-09-01 09:29:16.000000000 -0300
+++ linux-2.6/arch/ia64/ia32/ia32_entry.S	2008-09-01 09:30:25.000000000 -0300
@@ -202,7 +202,7 @@ ia32_syscall_table:
 	data8 sys32_ptrace
 	data8 sys32_alarm
 	data8 sys_ni_syscall
-	data8 sys32_pause
+	data8 sys_pause
 	data8 compat_sys_utime	  /* 30 */
 	data8 sys_ni_syscall	  /* old stty syscall holder */
 	data8 sys_ni_syscall	  /* old gtty syscall holder */
Index: linux-2.6/arch/ia64/ia32/sys_ia32.c
=================================--- linux-2.6.orig/arch/ia64/ia32/sys_ia32.c	2008-09-01 09:29:16.000000000 -0300
+++ linux-2.6/arch/ia64/ia32/sys_ia32.c	2008-09-01 09:30:25.000000000 -0300
@@ -1795,14 +1795,6 @@ out:
 }
 
 asmlinkage int
-sys32_pause (void)
-{
-	current->state = TASK_INTERRUPTIBLE;
-	schedule();
-	return -ERESTARTNOHAND;
-}
-
-asmlinkage int
 sys32_msync (unsigned int start, unsigned int len, int flags)
 {
 	unsigned int addr;
Index: linux-2.6/arch/ia64/include/asm/unistd.h
=================================--- linux-2.6.orig/arch/ia64/include/asm/unistd.h	2008-09-01 09:31:13.000000000 -0300
+++ linux-2.6/arch/ia64/include/asm/unistd.h	2008-09-01 09:31:32.000000000 -0300
@@ -337,6 +337,7 @@
 # define __ARCH_WANT_SYS_NICE
 # define __ARCH_WANT_SYS_OLD_GETRLIMIT
 # define __ARCH_WANT_SYS_OLDUMOUNT
+# define __ARCH_WANT_SYS_PAUSE
 # define __ARCH_WANT_SYS_SIGPENDING
 # define __ARCH_WANT_SYS_SIGPROCMASK
 # define __ARCH_WANT_COMPAT_SYS_RT_SIGSUSPEND
