From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 27 Jan 2006 02:24:59 +0000
Subject: [patch] remove staled comments in asm/system.h
Message-Id: <200601270225.k0R2P0g21811@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

With the recent optimization made to wrap_mmu_context function,
we don't hold tasklist_lock anymore when wrapping context id.
The comments in asm/system.h must fall through the crack earlier.
Remove staled comments.

I believe it is still beneficial to unlock the runqueue lock
across context switch. So leave __ARCH_WANT_UNLOCKED_CTXSW on.

Signed-off-by: <kenneth.w.chen@intel.com>

--- ./include/asm-ia64/system.h.orig	2006-01-26 19:10:39.145107381 -0800
+++ ./include/asm-ia64/system.h	2006-01-26 19:10:58.622646205 -0800
@@ -249,32 +249,7 @@ extern void ia64_load_extra (struct task
 # define switch_to(prev,next,last)	__switch_to(prev, next, last)
 #endif
 
-/*
- * On IA-64, we don't want to hold the runqueue's lock during the low-level context-switch,
- * because that could cause a deadlock.  Here is an example by Erich Focht:
- *
- * Example:
- * CPU#0:
- * schedule()
- *    -> spin_lock_irq(&rq->lock)
- *    -> context_switch()
- *       -> wrap_mmu_context()
- *          -> read_lock(&tasklist_lock)
- *
- * CPU#1:
- * sys_wait4() or release_task() or forget_original_parent()
- *    -> write_lock(&tasklist_lock)
- *    -> do_notify_parent()
- *       -> wake_up_parent()
- *          -> try_to_wake_up()
- *             -> spin_lock_irq(&parent_rq->lock)
- *
- * If the parent's rq happens to be on CPU#0, we'll wait for the rq->lock
- * of that CPU which will not be released, because there we wait for the
- * tasklist_lock to become available.
- */
 #define __ARCH_WANT_UNLOCKED_CTXSW
-
 #define ARCH_HAS_PREFETCH_SWITCH_STACK
 #define ia64_platform_is(x) (strcmp(x, platform_name) = 0)
 

