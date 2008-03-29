From: Roland McGrath <roland@redhat.com>
Date: Sat, 29 Mar 2008 00:14:50 +0000
Subject: [PATCH 4/4] ia64 renumber TIF_RESTORE_SIGMASK
Message-Id: <20080329001450.2B02D26FA1D@magilla.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080329001230.D013726FA1D@magilla.localdomain>
In-Reply-To: Roland McGrath's message of  Friday, 28 March 2008 17:12:30 -0700 <20080329001230.D013726FA1D@magilla.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-s390@vger.kernel.org

TIF_RESTORE_SIGMASK no longer needs to be in the _TIF_WORK_* masks.
Those low bits are scarce.  Renumber TIF_RESTORE_SIGMASK to free one up.

Signed-off-by: Roland McGrath <roland@redhat.com>
---
 arch/ia64/kernel/process.c     |    2 +-
 include/asm-ia64/thread_info.h |    5 ++---
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/arch/ia64/kernel/process.c b/arch/ia64/kernel/process.c
index 49937a3..2ef2794 100644
--- a/arch/ia64/kernel/process.c
+++ b/arch/ia64/kernel/process.c
@@ -183,7 +183,7 @@ do_notify_resume_user (sigset_t *unused, struct sigscratch *scr, long in_syscall
 #endif
 
 	/* deal with pending signal delivery */
-	if (test_thread_flag(TIF_SIGPENDING)||test_thread_flag(TIF_RESTORE_SIGMASK))
+	if (test_thread_flag(TIF_SIGPENDING))
 		ia64_do_signal(scr, in_syscall);
 
 	/* copy user rbs to kernel rbs */
diff --git a/include/asm-ia64/thread_info.h b/include/asm-ia64/thread_info.h
index 93d83cb..366e517 100644
--- a/include/asm-ia64/thread_info.h
+++ b/include/asm-ia64/thread_info.h
@@ -87,7 +87,6 @@ extern void tsk_clear_notify_resume(struct task_struct *tsk);
 #define TIF_SYSCALL_TRACE	2	/* syscall trace active */
 #define TIF_SYSCALL_AUDIT	3	/* syscall auditing active */
 #define TIF_SINGLESTEP		4	/* restore singlestep on return to user mode */
-#define TIF_RESTORE_SIGMASK	5	/* restore signal mask in do_signal() */
 #define TIF_NOTIFY_RESUME	6	/* resumption notification requested */
 #define TIF_POLLING_NRFLAG	16	/* true if poll_idle() is polling TIF_NEED_RESCHED */
 #define TIF_MEMDIE		17
@@ -95,6 +94,7 @@ extern void tsk_clear_notify_resume(struct task_struct *tsk);
 #define TIF_DB_DISABLED		19	/* debug trap disabled for fsyscall */
 #define TIF_FREEZE		20	/* is freezing for suspend */
 #define TIF_RESTORE_RSE		21	/* user RBS is newer than kernel RBS */
+#define TIF_RESTORE_SIGMASK	22	/* restore signal mask in do_signal() */
 
 #define _TIF_SYSCALL_TRACE	(1 << TIF_SYSCALL_TRACE)
 #define _TIF_SYSCALL_AUDIT	(1 << TIF_SYSCALL_AUDIT)
@@ -112,8 +112,7 @@ extern void tsk_clear_notify_resume(struct task_struct *tsk);
 
 /* "work to do on user-return" bits */
 #define TIF_ALLWORK_MASK	(_TIF_SIGPENDING|_TIF_NOTIFY_RESUME|_TIF_SYSCALL_AUDIT|\
-				 _TIF_NEED_RESCHED| _TIF_SYSCALL_TRACE|\
-				 _TIF_RESTORE_SIGMASK)
+				 _TIF_NEED_RESCHED|_TIF_SYSCALL_TRACE)
 /* like TIF_ALLWORK_BITS but sans TIF_SYSCALL_TRACE or TIF_SYSCALL_AUDIT */
 #define TIF_WORK_MASK		(TIF_ALLWORK_MASK&~(_TIF_SYSCALL_TRACE|_TIF_SYSCALL_AUDIT))
 
