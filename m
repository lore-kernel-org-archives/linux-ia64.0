From: Fenghua Yu <fenghua.yu@intel.com>
Date: Tue, 06 Feb 2007 00:07:57 +0000
Subject: [PATCH] Hook up getcpu system call for IA64
Message-Id: <20070206000757.GA32026@linux-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

getcpu system call returns cpu# and node# on which this system call and its caller are running. This patch hooks up its implementation on IA64.

Thanks.

-Fenghua

Signed-off-by: Fenghua Yu <fenghua.yu@intel.com>


diff -Nurp linux-2.6.git.orig/arch/ia64/kernel/entry.S linux-2.6.git/arch/ia64/kernel/entry.S
--- linux-2.6.git.orig/arch/ia64/kernel/entry.S	2007-01-26 16:41:32.000000000 -0800
+++ linux-2.6.git/arch/ia64/kernel/entry.S	2007-02-02 16:13:10.000000000 -0800
@@ -1610,5 +1610,7 @@ sys_call_table:
 	data8 sys_sync_file_range		// 1300
 	data8 sys_tee
 	data8 sys_vmsplice
+	data8 sys_ni_syscall			// reserved for move_pages
+	data8 sys_getcpu
 
 	.org sys_call_table + 8*NR_syscalls	// guard against failures to increase NR_syscalls
diff -Nurp linux-2.6.git.orig/include/asm-ia64/unistd.h linux-2.6.git/include/asm-ia64/unistd.h
--- linux-2.6.git.orig/include/asm-ia64/unistd.h	2006-11-29 12:26:15.000000000 -0800
+++ linux-2.6.git/include/asm-ia64/unistd.h	2007-02-02 15:05:27.000000000 -0800
@@ -291,11 +291,13 @@
 #define __NR_sync_file_range		1300
 #define __NR_tee			1301
 #define __NR_vmsplice			1302
+/* 1303 reserved for move_pages */
+#define __NR_getcpu			1304
 
 #ifdef __KERNEL__
 
 
-#define NR_syscalls			279 /* length of syscall table */
+#define NR_syscalls			281 /* length of syscall table */
 
 #define __ARCH_WANT_SYS_RT_SIGACTION
 
