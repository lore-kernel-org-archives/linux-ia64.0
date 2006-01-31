From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Tue, 31 Jan 2006 20:49:46 +0000
Subject: [patch] add syscall entry for *at()
Message-Id: <200601312049.k0VKnsg08813@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Wire up the ia64 syscalls.

Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>

---
While cruising Linus's git change log, ran into this commit:
5590ff0d5528b60153c0b4e7b771472b5a95e297

[PATCH] vfs: *at functions: core
Here is a series of patches which introduce in total 13 new system calls
which take a file descriptor/filename pair instead of a single file
name.

Should we wire them in for ia64?


--- ./arch/ia64/kernel/entry.S.orig	2006-01-31 13:10:32.657658186 -0800
+++ ./arch/ia64/kernel/entry.S	2006-01-31 13:44:37.023844080 -0800
@@ -1587,5 +1587,18 @@ sys_call_table:
 	data8 sys_inotify_add_watch
 	data8 sys_inotify_rm_watch
 	data8 sys_migrate_pages			// 1280
+	data8 sys_openat
+	data8 sys_mkdirat
+	data8 sys_mknodat
+	data8 sys_fchownat
+	data8 sys_futimesat			// 1285
+	data8 sys_newfstatat
+	data8 sys_unlinkat
+	data8 sys_renameat
+	data8 sys_linkat
+	data8 sys_symlinkat			// 1290
+	data8 sys_readlinkat
+	data8 sys_fchmodat
+	data8 sys_faccessat
 
 	.org sys_call_table + 8*NR_syscalls	// guard against failures to increase NR_syscalls
--- ./include/asm-ia64/unistd.h.orig	2006-01-31 13:17:53.860777781 -0800
+++ ./include/asm-ia64/unistd.h	2006-01-31 13:44:23.769937992 -0800
@@ -270,6 +270,19 @@
 #define __NR_inotify_add_watch		1278
 #define __NR_inotify_rm_watch		1279
 #define __NR_migrate_pages		1280
+#define __NR_openat			1281
+#define __NR_mkdirat			1282
+#define __NR_mknodat			1283
+#define __NR_fchownat			1284
+#define __NR_futimesat			1285
+#define __NR_newfstatat			1286
+#define __NR_unlinkat			1287
+#define __NR_renameat			1288
+#define __NR_linkat			1289
+#define __NR_symlinkat			1290
+#define __NR_readlinkat			1291
+#define __NR_fchmodat			1292
+#define __NR_faccessat			1293
 
 #ifdef __KERNEL__
 

