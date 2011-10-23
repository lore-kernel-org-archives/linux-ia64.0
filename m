From: Jonas Bonn <jonas@southpole.se>
Date: Sun, 23 Oct 2011 10:20:01 +0000
Subject: [PATCH RFC 7/8] ia64: implement syscall restart generically
Message-Id: <673e9c328fc217dd4e36b8fe22db6812e400b98a.1319364492.git.jonas@southpole.se>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1319364492.git.jonas@southpole.se>
In-Reply-To: <cover.1319364492.git.jonas@southpole.se>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org
Cc: Jonas Bonn <jonas@southpole.se>, linux-ia64@vger.kernel.org


Manipulating task state to effect re-execution of an interrupted syscall
used to be purely architecture specific code.  However, as most arch's
were essentially just making minor adjustments to almost identical logic,
this code could be moved to a common implementation.

The generic variant introduces the function handle_syscall_restart() to be
called after get_signal_to_deliver().  The architecture specific register
manipulations required to effect the actual restart are now implemented
in the generic syscall interface found in asm/syscall.h

This patch transitions this architecture's signal handling code over to
using the generic syscall restart code by:

i)  Implementing the register manipulations in asm/syscall.h
ii) Replacing the restart logic with a call to handle_syscall_restart

Cc: linux-ia64@vger.kernel.org
Signed-off-by: Jonas Bonn <jonas@southpole.se>
---
 arch/ia64/include/asm/syscall.h |   21 +++++++++++++++
 arch/ia64/kernel/signal.c       |   54 +--------------------------------------
 2 files changed, 22 insertions(+), 53 deletions(-)

diff --git a/arch/ia64/include/asm/syscall.h b/arch/ia64/include/asm/syscall.h
index a7ff1c6..ee18042 100644
--- a/arch/ia64/include/asm/syscall.h
+++ b/arch/ia64/include/asm/syscall.h
@@ -15,6 +15,7 @@
 
 #include <linux/sched.h>
 #include <linux/err.h>
+#include <asm/unistd.h>
 
 static inline long syscall_get_nr(struct task_struct *task,
 				  struct pt_regs *regs)
@@ -31,6 +32,26 @@ static inline void syscall_rollback(struct task_struct *task,
 	/* do nothing */
 }
 
+static inline void
+syscall_clear(struct task_struct *task, struct pt_regs *regs)
+{
+	regs->cr_ifs |= (1UL << 63);
+}
+
+static inline void
+syscall_restart(struct task_struct *task, struct pt_regs *regs)
+{
+	syscall_rollback(task, regs);
+	ia64_decrement_ip(regs);
+}
+
+static inline void
+syscall_do_restartblock(struct task_struct *task, struct pt_regs *regs)
+{
+	regs->r15 = __NR_restart_syscall;
+	ia64_decrement_ip(regs);
+}
+
 static inline long syscall_get_error(struct task_struct *task,
 				     struct pt_regs *regs)
 {
diff --git a/arch/ia64/kernel/signal.c b/arch/ia64/kernel/signal.c
index 7bdafc8..0b8abbc 100644
--- a/arch/ia64/kernel/signal.c
+++ b/arch/ia64/kernel/signal.c
@@ -453,8 +453,6 @@ ia64_do_signal (struct sigscratch *scr, long in_syscall)
 	struct k_sigaction ka;
 	sigset_t *oldset;
 	siginfo_t info;
-	long restart = in_syscall;
-	long errno = scr->pt.r8;
 
 	/*
 	 * In the ia64_leave_kernel code path, we want the common case to go fast, which
@@ -476,44 +474,11 @@ ia64_do_signal (struct sigscratch *scr, long in_syscall)
 	while (1) {
 		int signr = get_signal_to_deliver(&info, &ka, &scr->pt, NULL);
 
-		/*
-		 * get_signal_to_deliver() may have run a debugger (via notify_parent())
-		 * and the debugger may have modified the state (e.g., to arrange for an
-		 * inferior call), thus it's important to check for restarting _after_
-		 * get_signal_to_deliver().
-		 */
-		if ((long) scr->pt.r10 != -1)
-			/*
-			 * A system calls has to be restarted only if one of the error codes
-			 * ERESTARTNOHAND, ERESTARTSYS, or ERESTARTNOINTR is returned.  If r10
-			 * isn't -1 then r8 doesn't hold an error code and we don't need to
-			 * restart the syscall, so we can clear the "restart" flag here.
-			 */
-			restart = 0;
+		handle_syscall_restart(&scr->pt, &ka, (signr > 0));
 
 		if (signr <= 0)
 			break;
 
-		if (unlikely(restart)) {
-			switch (errno) {
-			      case ERESTART_RESTARTBLOCK:
-			      case ERESTARTNOHAND:
-				scr->pt.r8 = EINTR;
-				/* note: scr->pt.r10 is already -1 */
-				break;
-
-			      case ERESTARTSYS:
-				if ((ka.sa.sa_flags & SA_RESTART) = 0) {
-					scr->pt.r8 = EINTR;
-					/* note: scr->pt.r10 is already -1 */
-					break;
-				}
-			      case ERESTARTNOINTR:
-				ia64_decrement_ip(&scr->pt);
-				restart = 0; /* don't restart twice if handle_signal() fails... */
-			}
-		}
-
 		/*
 		 * Whee!  Actually deliver the signal.  If the delivery failed, we need to
 		 * continue to iterate in this loop so we can deliver the SIGSEGV...
@@ -530,23 +495,6 @@ ia64_do_signal (struct sigscratch *scr, long in_syscall)
 		}
 	}
 
-	/* Did we come from a system call? */
-	if (restart) {
-		/* Restart the system call - no handlers present */
-		if (errno = ERESTARTNOHAND || errno = ERESTARTSYS || errno = ERESTARTNOINTR
-		    || errno = ERESTART_RESTARTBLOCK)
-		{
-			/*
-			 * Note: the syscall number is in r15 which is saved in
-			 * pt_regs so all we need to do here is adjust ip so that
-			 * the "break" instruction gets re-executed.
-			 */
-			ia64_decrement_ip(&scr->pt);
-			if (errno = ERESTART_RESTARTBLOCK)
-				scr->pt.r15 = __NR_restart_syscall;
-		}
-	}
-
 	/* if there's no signal to deliver, we just put the saved sigmask
 	 * back */
 	if (current_thread_info()->status & TS_RESTORE_SIGMASK) {
-- 
1.7.5.4

