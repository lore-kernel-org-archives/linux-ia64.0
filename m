From: Roland McGrath <roland@redhat.com>
Date: Mon, 12 Nov 2007 02:14:03 +0000
Subject: RE: [PATCH] ptrace RSE bug
Message-Id: <20071112021403.327EE4D04C7@magilla.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <1188357710.22637.7.camel@sli10-conroe.sh.intel.com>
In-Reply-To: <1188357710.22637.7.camel@sli10-conroe.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Sorry for the late reply on this.  I've been juggling too many other
things, and also I was out for most of a couple of weeks in October.

I did indeed promise to do the ptrace/signals magic part of the equation
once you ia64 folks ironed out the ia64-specific code for this plan.
I'm very glad to do it and see this wart finally get thoroughly cleaned up!

To integrate this with the ia64 code, I imagine in asm-ia64/ptrace.h adding:

#define arch_ptrace_stop_needed(code, info)	\
	(!test_thread_flag(TIF_RESTORE_RSE))
#define arch_ptrace_stop(code, info)		ia64_rse_writeback()

I have not tested this patch except to verify that it compiles away to no
change when the two new macros are not defined.  It may be difficult to
really test for the case it's particularly intended for, since it's a race.
You need something like repeated runs of strace /bin/true while
asynchronously trying kill -9 on the traced /bin/true process (but might
need to avoid killing the whole pgrp including strace), and see if it ever
leaves off with the traced process stuck in TASK_TRACED (T) with a pending
SIGKILL, rather than being a dead zombie (and cleaned up by strace).  If
you try to produce a test scenario for the problem, you can test it with a
version that never calls sigkill_pending after calling arch_ptrace_stop
with the siglock dropped.  Once you produce the bug with that kernel and
believe you can make it hit with a known test scenario, try the proper
patch as below to verify it can no longer hit.

If you are happy with this patch and the results of integrating it with
your ia64 changes, then either you or I can post this machine-independent
patch upstream for inclusion in the mainline kernel.  I'm eager to see all
the old cruft in ia64 ptrace get cleaned out after we have this in.


Thanks,
Roland

---
[PATCH] arch_ptrace_stop

This adds support to allow asm/ptrace.h to define two new macros,
arch_ptrace_stop_needed and arch_ptrace_stop.  These control special
machine-specific actions to be done before a ptrace stop.  The new
code compiles away to nothing when the new macros are not defined.
This is the case on all machines to begin with.

On ia64, these macros will be defined to solve the long-standing
issue of ptrace vs register backing store.

Signed-off-by: Roland McGrath <roland@redhat.com>
---
 kernel/signal.c |   48 +++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 47 insertions(+), 1 deletions(-)

diff --git a/kernel/signal.c b/kernel/signal.c
index 909a0cc..0ac614a 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -1594,6 +1594,32 @@ static inline int may_ptrace_stop(void)
 }
 
 /*
+ * The arch can have machine-specific work to be done before ptrace stops.
+ * On ia64, register backing store gets written back to user memory here.
+ * Since this can be costly (requires dropping the siglock), we only do it
+ * when the arch requires it for this particular stop.  For example, if
+ * the thread has not been back to user mode since the last stop, the
+ * thread state might indicate that nothing needs to be done.
+ */
+#ifndef arch_ptrace_stop_needed
+#define arch_ptrace_stop_needed(code, info)	0
+#endif
+#ifndef arch_ptrace_stop
+#define arch_ptrace_stop(code, info)		do { } while (0)
+#endif
+
+/*
+ * Return nonzero if there is a SIGKILL that should be waking us up.
+ * Called with the siglock held.
+ */
+static int sigkill_pending(struct task_struct *tsk)
+{
+	return ((sigismember(&tsk->pending.signal, SIGKILL) ||
+		 sigismember(&tsk->signal->shared_pending.signal, SIGKILL)) &&
+		!unlikely(sigismember(&tsk->blocked, SIGKILL)));
+}
+
+/*
  * This must be called with current->sighand->siglock held.
  *
  * This should be the path for all ptrace stops.
@@ -1606,6 +1632,26 @@ static inline int may_ptrace_stop(void)
  */
 static void ptrace_stop(int exit_code, int nostop_code, siginfo_t *info)
 {
+	int killed = 0;
+
+	if (arch_ptrace_stop_needed(exit_code, info)) {
+		/*
+		 * The arch code has something special to do before a
+		 * ptrace stop.  This is allowed to block, e.g. for faults
+		 * on user stack pages.  We can't keep the siglock while
+		 * calling arch_ptrace_stop, so we must release it now.
+		 * To preserve proper semantics, we must do this before
+		 * any signal bookkeeping like checking group_stop_count.
+		 * Meanwhile, a SIGKILL could come in before we retake the
+		 * siglock.  That must prevent us from sleeping in TASK_TRACED.
+		 * So after regaining the lock, we must check for SIGKILL.
+		 */
+		spin_unlock_irq(&current->sighand->siglock);
+		arch_ptrace_stop(exit_code, info);
+		spin_lock_irq(&current->sighand->siglock);
+		killed = sigkill_pending(current);
+	}
+
 	/*
 	 * If there is a group stop in progress,
 	 * we must participate in the bookkeeping.
@@ -1621,7 +1667,7 @@ static void ptrace_stop(int exit_code, int nostop_code, siginfo_t *info)
 	spin_unlock_irq(&current->sighand->siglock);
 	try_to_freeze();
 	read_lock(&tasklist_lock);
-	if (may_ptrace_stop()) {
+	if (!unlikely(killed) && may_ptrace_stop()) {
 		do_notify_parent_cldstop(current, CLD_TRAPPED);
 		read_unlock(&tasklist_lock);
 		schedule();
