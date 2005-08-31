From: Christoph Lameter <clameter@engr.sgi.com>
Date: Wed, 31 Aug 2005 20:59:54 +0000
Subject: [PATCH] Reserve syscall number for sys_migrate_pages
Message-Id: <Pine.LNX.4.62.0508311347470.29108@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch adds a reservation for the sys_migrate_pages system call. I 
just had to rework Ray's page migration patchset because the syscall has 
been taken for inotify. This patch is will make sure that we are not 
continuing to do this.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.13/include/asm-ia64/unistd.h
=================================--- linux-2.6.13.orig/include/asm-ia64/unistd.h	2005-08-28 16:41:01.000000000 -0700
+++ linux-2.6.13/include/asm-ia64/unistd.h	2005-08-31 13:55:18.000000000 -0700
@@ -269,12 +269,13 @@
 #define __NR_inotify_init		1277
 #define __NR_inotify_add_watch		1278
 #define __NR_inotify_rm_watch		1279
+#define __NR_sys_migrate_pages		1280
 
 #ifdef __KERNEL__
 
 #include <linux/config.h>
 
-#define NR_syscalls			256 /* length of syscall table */
+#define NR_syscalls			257 /* length of syscall table */
 
 #define __ARCH_WANT_SYS_RT_SIGACTION
 
Index: linux-2.6.13/arch/ia64/kernel/entry.S
=================================--- linux-2.6.13.orig/arch/ia64/kernel/entry.S	2005-08-28 16:41:01.000000000 -0700
+++ linux-2.6.13/arch/ia64/kernel/entry.S	2005-08-31 13:44:12.000000000 -0700
@@ -1577,5 +1577,6 @@ sys_call_table:
 	data8 sys_inotify_init
 	data8 sys_inotify_add_watch
 	data8 sys_inotify_rm_watch
+	data8 sys_ni_syscall			// reserved for sys_migrate_pages
 
 	.org sys_call_table + 8*NR_syscalls	// guard against failures to increase NR_syscalls
