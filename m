From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Sun, 02 Feb 2003 22:54:11 +0000
Subject: [Linux-ia64] [PATCH] IA32 support without sysctl doesn't work
Message-Id: <marc-linux-ia64-105590709805797@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

If you try to compile with CONFIG_IA32 on and CONFIG_SYSCTL off, then
you get an undefined reference to do_sysctl() on final link.

I believe that if sysctl is turned off, it should be off for IA32
processes as well as for IA64 processes.  Here's a patch:

=== arch/ia64/ia32/ia32_entry.S 1.18 vs edited ==--- 1.18/arch/ia64/ia32/ia32_entry.S	Mon Jan 13 11:07:06 2003
+++ edited/arch/ia64/ia32/ia32_entry.S	Mon Feb  3 09:49:48 2003
@@ -347,7 +347,11 @@
 	data8 sys32_writev
 	data8 sys_getsid
 	data8 sys_fdatasync
+#ifdef CONFIG_SYSCTL
 	data8 sys32_sysctl
+#else
+	data8 sys32_ni_syscall
+#endif
 	data8 sys_mlock		  /* 150 */
 	data8 sys_munlock
 	data8 sys_mlockall
=== arch/ia64/ia32/sys_ia32.c 1.43 vs edited ==--- 1.43/arch/ia64/ia32/sys_ia32.c	Tue Jan 28 10:44:14 2003
+++ edited/arch/ia64/ia32/sys_ia32.c	Mon Feb  3 09:48:39 2003
@@ -3148,6 +3148,7 @@
 
 extern asmlinkage long sys_sysctl(struct __sysctl_args *args);
 
+#ifdef CONFIG_SYSCTL
 asmlinkage long
 sys32_sysctl (struct sysctl32 *args)
 {
@@ -3189,6 +3190,7 @@
 
 	return ret;
 }
+#endif
 
 asmlinkage long
 sys32_newuname (struct new_utsname *name)

