From: Jason Uhlenkott <jasonuhl@sgi.com>
Date: Fri, 30 Dec 2005 10:27:01 +0000
Subject: [PATCH] Handle debug traps in fsys mode
Message-Id: <20051230102701.GA328696@dragonfly.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

We need to handle debug traps in fsys mode non-fatally.  They can
happen now that we have fsyscalls which contain probe instructions.

Signed-off-by: Jason Uhlenkott <jasonuhl@sgi.com>


Index: linux/arch/ia64/kernel/traps.c
=================================--- linux.orig/arch/ia64/kernel/traps.c	2005-12-08 14:19:53.761003480 -0800
+++ linux/arch/ia64/kernel/traps.c	2005-12-30 02:13:57.700204467 -0800
@@ -530,12 +530,15 @@
 		if (fsys_mode(current, &regs)) {
 			extern char __kernel_syscall_via_break[];
 			/*
-			 * Got a trap in fsys-mode: Taken Branch Trap and Single Step trap
-			 * need special handling; Debug trap is not supposed to happen.
+			 * Got a trap in fsys-mode: Taken Branch Trap
+			 * and Single Step trap need special handling;
+			 * Debug trap is ignored (we disable it here
+			 * and re-enable it in the lower-privilege trap).
 			 */
 			if (unlikely(vector = 29)) {
-				die("Got debug trap in fsys-mode---not supposed to happen!",
-				    &regs, 0);
+				set_thread_flag(TIF_DB_DISABLED);
+				ia64_psr(&regs)->db = 0;
+				ia64_psr(&regs)->lp = 1;
 				return;
 			}
 			/* re-do the system call via break 0x100000: */
@@ -589,10 +592,19 @@
 	      case 34:
 		if (isr & 0x2) {
 			/* Lower-Privilege Transfer Trap */
+
+			/* If we disabled debug traps during an fsyscall,
+			 * re-enable them here.
+			 */
+			if (test_thread_flag(TIF_DB_DISABLED)) {
+				clear_thread_flag(TIF_DB_DISABLED);
+				ia64_psr(&regs)->db = 1;
+			}
+
 			/*
-			 * Just clear PSR.lp and then return immediately: all the
-			 * interesting work (e.g., signal delivery is done in the kernel
-			 * exit path).
+			 * Just clear PSR.lp and then return immediately:
+			 * all the interesting work (e.g., signal delivery)
+			 * is done in the kernel exit path.
 			 */
 			ia64_psr(&regs)->lp = 0;
 			return;
Index: linux/include/asm-ia64/thread_info.h
=================================--- linux.orig/include/asm-ia64/thread_info.h	2005-12-08 14:20:17.290561439 -0800
+++ linux/include/asm-ia64/thread_info.h	2005-12-30 02:15:39.749259718 -0800
@@ -84,6 +84,7 @@
 #define TIF_POLLING_NRFLAG	16	/* true if poll_idle() is polling TIF_NEED_RESCHED */
 #define TIF_MEMDIE		17
 #define TIF_MCA_INIT		18	/* this task is processing MCA or INIT */
+#define TIF_DB_DISABLED		19	/* debug trap disabled for fsyscall */
 
 #define _TIF_SYSCALL_TRACE	(1 << TIF_SYSCALL_TRACE)
 #define _TIF_SYSCALL_AUDIT	(1 << TIF_SYSCALL_AUDIT)
@@ -91,9 +92,10 @@
 #define _TIF_NOTIFY_RESUME	(1 << TIF_NOTIFY_RESUME)
 #define _TIF_SIGPENDING		(1 << TIF_SIGPENDING)
 #define _TIF_NEED_RESCHED	(1 << TIF_NEED_RESCHED)
-#define _TIF_SIGDELAYED	(1 << TIF_SIGDELAYED)
+#define _TIF_SIGDELAYED		(1 << TIF_SIGDELAYED)
 #define _TIF_POLLING_NRFLAG	(1 << TIF_POLLING_NRFLAG)
 #define _TIF_MCA_INIT		(1 << TIF_MCA_INIT)
+#define _TIF_DB_DISABLED	(1 << TIF_DB_DISABLED)
 
 /* "work to do on user-return" bits */
 #define TIF_ALLWORK_MASK	(_TIF_NOTIFY_RESUME|_TIF_SIGPENDING|_TIF_NEED_RESCHED|_TIF_SYSCALL_TRACE|_TIF_SYSCALL_AUDIT|_TIF_SIGDELAYED)
