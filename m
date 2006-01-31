From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Tue, 31 Jan 2006 22:26:25 +0000
Subject: RE: [patch] add syscall entry for *at()
Message-Id: <200601312226.k0VMQXg17420@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200601312049.k0VKnsg08813@unix-os.sc.intel.com>
In-Reply-To: <200601312049.k0VKnsg08813@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Luck, Tony wrote on Tuesday, January 31, 2006 1:15 PM
> > Wire up the ia64 syscalls.
> 
> You should really add some more zeroes at the end
> of fsys.S too just to keep things in step.

OK. I got tired writing bunch of zeros, change them to .space
assembler directive.



Wire up the ia64 syscalls for *at() functions.

Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>

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
--- ./arch/ia64/kernel/fsys.S.orig	2006-01-31 15:04:28.840191630 -0800
+++ ./arch/ia64/kernel/fsys.S	2006-01-31 15:19:05.944673073 -0800
@@ -878,31 +878,8 @@ fsyscall_table:
 	data8 0				// timer_delete
 	data8 0				// clock_settime
 	data8 fsys_clock_gettime	// clock_gettime
-	data8 0				// clock_getres		// 1255
-	data8 0				// clock_nanosleep
-	data8 0				// fstatfs64
-	data8 0				// statfs64
-	data8 0
-	data8 0							// 1260
-	data8 0
-	data8 0				// mq_open
-	data8 0				// mq_unlink
-	data8 0				// mq_timedsend
-	data8 0				// mq_timedreceive	// 1265
-	data8 0				// mq_notify
-	data8 0				// mq_getsetattr
-	data8 0				// kexec_load
-	data8 0
-	data8 0							// 1270
-	data8 0
-	data8 0
-	data8 0
-	data8 0
-	data8 0							// 1275
-	data8 0
-	data8 0
-	data8 0
-	data8 0
-	data8 0							// 1280
+	#define __NR_syscall_last	1255
+
+	.space 8*(NR_syscalls + 1024 - __NR_syscall_last), 0
 
 	.org fsyscall_table + 8*NR_syscalls	// guard against failures to increase NR_syscalls
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
 

