From: "Pat O'Rourke" <orourke@mclinux.com>
Date: Thu, 14 Sep 2000 00:42:39 +0000
Subject: [Linux-ia64] [PATCH] unresolved symbol 'sys_ioperm'
Message-Id: <marc-linux-ia64-105590678205491@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The definitions of sys_ioperm() and sys_iopl() were moved to sys_ia32.c
between 2.4.0-test7 and 2.4.0-test8.  As a result you will get undefined
references to sys_ioperm() if you build a kernel w/o CONFIG_IA32_SUPPORT
enabled.  The following patch corrects this.

Pat

-- 
Patrick O'Rourke
orourke@missioncriticallinux.com

diff -u --new-file --recursive linux-2.4.0-test8/arch/ia64/kernel/entry.S 
linux-2.4.0-test8-patch/arch/ia64/kernel/entry.S
--- linux-2.4.0-test8/arch/ia64/kernel/entry.S	Tue Sep  5 16:50:01 2000
+++ linux-2.4.0-test8-patch/arch/ia64/kernel/entry.S	Wed Sep 13 20:11:24 2000
@@ -1088,7 +1088,7 @@
 	data8 sys_setpriority
 	data8 sys_statfs
 	data8 sys_fstatfs
-	data8 sys_ioperm			// 1105
+	data8 ia64_ni_syscall			// 1105
 	data8 sys_semget
 	data8 sys_semop
 	data8 sys_semctl
diff -u --new-file --recursive linux-2.4.0-test8/drivers/char/vt.c 
linux-2.4.0-test8-patch/drivers/char/vt.c
--- linux-2.4.0-test8/drivers/char/vt.c	Tue Aug  8 18:25:24 2000
+++ linux-2.4.0-test8-patch/drivers/char/vt.c	Wed Sep 13 20:12:07 2000
@@ -62,7 +62,7 @@
  */
 unsigned char keyboard_type = KB_101;
 
-#if !defined(__alpha__) && !defined(__mips__) && !defined(__arm__) && 
!defined(__sh__)
+#if !defined(__alpha__) && !defined(__mips__) && !defined(__arm__) && 
!defined(__sh__) && !defined(__ia64__)
 asmlinkage long sys_ioperm(unsigned long from, unsigned long num, int on);
 #endif
 
@@ -472,7 +472,7 @@
 		ucval = keyboard_type;
 		goto setchar;
 
-#if !defined(__alpha__) && !defined(__mips__) && !defined(__arm__) && 
!defined(__sh__)
+#if !defined(__alpha__) && !defined(__mips__) && !defined(__arm__) && 
!defined(__sh__) && !defined(__ia64__)
 		/*
 		 * These cannot be implemented on any machine that implements
 		 * ioperm() in user level (such as Alpha PCs).




