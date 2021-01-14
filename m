From: Viresh Kumar <viresh.kumar@linaro.org>
Date: Thu, 14 Jan 2021 11:47:18 +0000
Subject: [PATCH 05/18] arch: ia64: Remove CONFIG_OPROFILE support
Message-Id: <f23ce8ae475324c6666cd8a717a49b550e6653a6.1610622251.git.viresh.kumar@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1610622251.git.viresh.kumar@linaro.org>
In-Reply-To: <cover.1610622251.git.viresh.kumar@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>, Robert Richter <rric@kernel.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: Viresh Kumar <viresh.kumar@linaro.org>, Vincent Guittot <vincent.guittot@linaro.org>, Arnd Bergmann <arnd@kernel.org>, oprofile-list@lists.sf.net, William Cohen <wcohen@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>, anmar.oueja@linaro.org, Christoph Hellwig <hch@infradead.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

The "oprofile" user-space tools don't use the kernel OPROFILE support
any more, and haven't in a long time. User-space has been converted to
the perf interfaces.

Also note that ia64 supports oprofile but not perf and profiling
shouldn't be working anyway currently.

Remove the old oprofile's architecture specific support.

Suggested-by: Christoph Hellwig <hch@infradead.org>
Suggested-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Viresh Kumar <viresh.kumar@linaro.org>
---
 arch/ia64/Kconfig                  |   1 -
 arch/ia64/Makefile                 |   1 -
 arch/ia64/configs/bigsur_defconfig |   1 -
 arch/ia64/oprofile/Makefile        |  10 ---
 arch/ia64/oprofile/backtrace.c     | 131 -----------------------------
 arch/ia64/oprofile/init.c          |  28 ------
 6 files changed, 172 deletions(-)
 delete mode 100644 arch/ia64/oprofile/Makefile
 delete mode 100644 arch/ia64/oprofile/backtrace.c
 delete mode 100644 arch/ia64/oprofile/init.c

diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index eed59ec32657..2ad7a8d29fcc 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -24,7 +24,6 @@ config IA64
 	select HAVE_UNSTABLE_SCHED_CLOCK
 	select HAVE_EXIT_THREAD
 	select HAVE_IDE
-	select HAVE_OPROFILE
 	select HAVE_KPROBES
 	select HAVE_KRETPROBES
 	select HAVE_FTRACE_MCOUNT_RECORD
diff --git a/arch/ia64/Makefile b/arch/ia64/Makefile
index 703b1c4f6d12..33c11fa31192 100644
--- a/arch/ia64/Makefile
+++ b/arch/ia64/Makefile
@@ -52,7 +52,6 @@ core-y				+= arch/ia64/kernel/ arch/ia64/mm/
 core-$(CONFIG_IA64_SGI_UV)	+= arch/ia64/uv/
 
 drivers-y			+= arch/ia64/pci/ arch/ia64/hp/common/
-drivers-$(CONFIG_OPROFILE)	+= arch/ia64/oprofile/
 
 PHONY += compressed check
 
diff --git a/arch/ia64/configs/bigsur_defconfig b/arch/ia64/configs/bigsur_defconfig
index cfed5ed89301..c409756b5396 100644
--- a/arch/ia64/configs/bigsur_defconfig
+++ b/arch/ia64/configs/bigsur_defconfig
@@ -2,7 +2,6 @@ CONFIG_SYSVIPC=y
 CONFIG_POSIX_MQUEUE=y
 CONFIG_LOG_BUF_SHIFT
 CONFIG_PROFILING=y
-CONFIG_OPROFILE=y
 CONFIG_MODULES=y
 CONFIG_MODULE_UNLOAD=y
 CONFIG_PARTITION_ADVANCED=y
diff --git a/arch/ia64/oprofile/Makefile b/arch/ia64/oprofile/Makefile
deleted file mode 100644
index fc7944d462f4..000000000000
--- a/arch/ia64/oprofile/Makefile
+++ /dev/null
@@ -1,10 +0,0 @@
-# SPDX-License-Identifier: GPL-2.0
-obj-$(CONFIG_OPROFILE) += oprofile.o
-
-DRIVER_OBJS := $(addprefix ../../../drivers/oprofile/, \
-		oprof.o cpu_buffer.o buffer_sync.o \
-		event_buffer.o oprofile_files.o \
-		oprofilefs.o oprofile_stats.o \
-		timer_int.o )
-
-oprofile-y := $(DRIVER_OBJS) init.o backtrace.o
diff --git a/arch/ia64/oprofile/backtrace.c b/arch/ia64/oprofile/backtrace.c
deleted file mode 100644
index 6a219a946050..000000000000
--- a/arch/ia64/oprofile/backtrace.c
+++ /dev/null
@@ -1,131 +0,0 @@
-/**
- * @file backtrace.c
- *
- * @remark Copyright 2004 Silicon Graphics Inc.  All Rights Reserved.
- * @remark Read the file COPYING
- *
- * @author Greg Banks <gnb@melbourne.sgi.com>
- * @author Keith Owens <kaos@melbourne.sgi.com>
- * Based on work done for the ia64 port of the SGI kernprof patch, which is
- *    Copyright (c) 2003-2004 Silicon Graphics Inc.  All Rights Reserved.
- */
-
-#include <linux/oprofile.h>
-#include <linux/sched.h>
-#include <linux/mm.h>
-#include <asm/ptrace.h>
-
-/*
- * For IA64 we need to perform a complex little dance to get both
- * the struct pt_regs and a synthetic struct switch_stack in place
- * to allow the unwind code to work.  This dance requires our unwind
- * using code to be called from a function called from unw_init_running().
- * There we only get a single void* data pointer, so use this struct
- * to hold all the data we need during the unwind.
- */
-typedef struct
-{
-	unsigned int depth;
-	struct pt_regs *regs;
-	struct unw_frame_info frame;
-	unsigned long *prev_pfs_loc;	/* state for WAR for old spinlock ool code */
-} ia64_backtrace_t;
-
-/* Returns non-zero if the PC is in the Interrupt Vector Table */
-static __inline__ int in_ivt_code(unsigned long pc)
-{
-	extern char ia64_ivt[];
-	return (pc >= (u_long)ia64_ivt && pc < (u_long)ia64_ivt+32768);
-}
-
-/*
- * Unwind to next stack frame.
- */
-static __inline__ int next_frame(ia64_backtrace_t *bt)
-{
-	/*
-	 * Avoid unsightly console message from unw_unwind() when attempting
-	 * to unwind through the Interrupt Vector Table which has no unwind
-	 * information.
-	 */
-	if (in_ivt_code(bt->frame.ip))
-		return 0;
-
-	/*
-	 * WAR for spinlock contention from leaf functions.  ia64_spinlock_contention_pre3_4
-	 * has ar.pfs = r0.  Leaf functions do not modify ar.pfs so ar.pfs remains
-	 * as 0, stopping the backtrace.  Record the previous ar.pfs when the current
-	 * IP is in ia64_spinlock_contention_pre3_4 then unwind, if pfs_loc has not changed
-	 * after unwind then use pt_regs.ar_pfs which is where the real ar.pfs is for
-	 * leaf functions.
-	 */
-	if (bt->prev_pfs_loc && bt->regs && bt->frame.pfs_loc = bt->prev_pfs_loc)
-		bt->frame.pfs_loc = &bt->regs->ar_pfs;
-	bt->prev_pfs_loc = NULL;
-
-	return unw_unwind(&bt->frame) = 0;
-}
-
-
-static void do_ia64_backtrace(struct unw_frame_info *info, void *vdata)
-{
-	ia64_backtrace_t *bt = vdata;
-	struct switch_stack *sw;
-	int count = 0;
-	u_long pc, sp;
-
-	sw = (struct switch_stack *)(info+1);
-	/* padding from unw_init_running */
-	sw = (struct switch_stack *)(((unsigned long)sw + 15) & ~15);
-
-	unw_init_frame_info(&bt->frame, current, sw);
-
-	/* skip over interrupt frame and oprofile calls */
-	do {
-		unw_get_sp(&bt->frame, &sp);
-		if (sp >= (u_long)bt->regs)
-			break;
-		if (!next_frame(bt))
-			return;
-	} while (count++ < 200);
-
-	/* finally, grab the actual sample */
-	while (bt->depth-- && next_frame(bt)) {
-		unw_get_ip(&bt->frame, &pc);
-		oprofile_add_trace(pc);
-		if (unw_is_intr_frame(&bt->frame)) {
-			/*
-			 * Interrupt received on kernel stack; this can
-			 * happen when timer interrupt fires while processing
-			 * a softirq from the tail end of a hardware interrupt
-			 * which interrupted a system call.  Don't laugh, it
-			 * happens!  Splice the backtrace into two parts to
-			 * avoid spurious cycles in the gprof output.
-			 */
-			/* TODO: split rather than drop the 2nd half */
-			break;
-		}
-	}
-}
-
-void
-ia64_backtrace(struct pt_regs * const regs, unsigned int depth)
-{
-	ia64_backtrace_t bt;
-	unsigned long flags;
-
-	/*
-	 * On IA64 there is little hope of getting backtraces from
-	 * user space programs -- the problems of getting the unwind
-	 * information from arbitrary user programs are extreme.
-	 */
-	if (user_mode(regs))
-		return;
-
-	bt.depth = depth;
-	bt.regs = regs;
-	bt.prev_pfs_loc = NULL;
-	local_irq_save(flags);
-	unw_init_running(do_ia64_backtrace, &bt);
-	local_irq_restore(flags);
-}
diff --git a/arch/ia64/oprofile/init.c b/arch/ia64/oprofile/init.c
deleted file mode 100644
index a692ba16a07b..000000000000
--- a/arch/ia64/oprofile/init.c
+++ /dev/null
@@ -1,28 +0,0 @@
-/**
- * @file init.c
- *
- * @remark Copyright 2002 OProfile authors
- * @remark Read the file COPYING
- *
- * @author John Levon <levon@movementarian.org>
- */
-
-#include <linux/kernel.h>
-#include <linux/oprofile.h>
-#include <linux/init.h>
-#include <linux/errno.h>
- 
-extern int perfmon_init(struct oprofile_operations *ops);
-extern void perfmon_exit(void);
-extern void ia64_backtrace(struct pt_regs * const regs, unsigned int depth);
-
-int __init oprofile_arch_init(struct oprofile_operations *ops)
-{
-	ops->backtrace = ia64_backtrace;
-	return -ENODEV;
-}
-
-
-void oprofile_arch_exit(void)
-{
-}
-- 
2.25.0.rc1.19.g042ed3e048af
