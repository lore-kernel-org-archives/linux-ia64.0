From: Roland McGrath <roland@redhat.com>
Date: Sat, 29 Mar 2008 00:14:18 +0000
Subject: [PATCH 3/4] s390 renumber TIF_RESTORE_SIGMASK
Message-Id: <20080329001418.D5F3526FA1D@magilla.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080329001230.D013726FA1D@magilla.localdomain>
In-Reply-To: Roland McGrath's message of  Friday, 28 March 2008 17:12:30 -0700 <20080329001230.D013726FA1D@magilla.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-s390@vger.kernel.org

TIF_RESTORE_SIGMASK no longer needs to be in the _TIF_WORK_* masks.
Those low bits are scarce, and are all used up now.
Renumber TIF_RESTORE_SIGMASK to free one up.

Signed-off-by: Roland McGrath <roland@redhat.com>
---
 arch/s390/kernel/entry.S       |   14 +++++++-------
 arch/s390/kernel/entry64.S     |   12 ++++++------
 include/asm-s390/thread_info.h |    2 +-
 3 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/arch/s390/kernel/entry.S b/arch/s390/kernel/entry.S
index 6766e37..bdbb3bc 100644
--- a/arch/s390/kernel/entry.S
+++ b/arch/s390/kernel/entry.S
@@ -49,9 +49,9 @@ SP_ILC	     =	STACK_FRAME_OVERHEAD + __PT_ILC
 SP_TRAP      =	STACK_FRAME_OVERHEAD + __PT_TRAP
 SP_SIZE      =	STACK_FRAME_OVERHEAD + __PT_SIZE
 
-_TIF_WORK_SVC = (_TIF_SIGPENDING | _TIF_RESTORE_SIGMASK | _TIF_NEED_RESCHED | \
+_TIF_WORK_SVC = (_TIF_SIGPENDING | _TIF_NEED_RESCHED | \
 		 _TIF_MCCK_PENDING | _TIF_RESTART_SVC | _TIF_SINGLE_STEP )
-_TIF_WORK_INT = (_TIF_SIGPENDING | _TIF_RESTORE_SIGMASK | _TIF_NEED_RESCHED | \
+_TIF_WORK_INT = (_TIF_SIGPENDING | _TIF_NEED_RESCHED | \
 		 _TIF_MCCK_PENDING)
 
 STACK_SHIFT = PAGE_SHIFT + THREAD_ORDER
@@ -316,7 +316,7 @@ sysc_work:
 	bo	BASED(sysc_mcck_pending)
 	tm	__TI_flags+3(%r9),_TIF_NEED_RESCHED
 	bo	BASED(sysc_reschedule)
-	tm	__TI_flags+3(%r9),(_TIF_SIGPENDING | _TIF_RESTORE_SIGMASK)
+	tm	__TI_flags+3(%r9),_TIF_SIGPENDING
 	bnz	BASED(sysc_sigpending)
 	tm	__TI_flags+3(%r9),_TIF_RESTART_SVC
 	bo	BASED(sysc_restart)
@@ -342,7 +342,7 @@ sysc_mcck_pending:
 	br	%r1			# TIF bit will be cleared by handler
 
 #
-# _TIF_SIGPENDING or _TIF_RESTORE_SIGMASK is set, call do_signal
+# _TIF_SIGPENDING is set, call do_signal
 #
 sysc_sigpending:
 	ni	__TI_flags+3(%r9),255-_TIF_SINGLE_STEP # clear TIF_SINGLE_STEP
@@ -657,7 +657,7 @@ io_work:
 	lr	%r15,%r1
 #
 # One of the work bits is on. Find out which one.
-# Checked are: _TIF_SIGPENDING, _TIF_RESTORE_SIGMASK, _TIF_NEED_RESCHED
+# Checked are: _TIF_SIGPENDING, _TIF_NEED_RESCHED
 #		and _TIF_MCCK_PENDING
 #
 io_work_loop:
@@ -665,7 +665,7 @@ io_work_loop:
 	bo	BASED(io_mcck_pending)
 	tm	__TI_flags+3(%r9),_TIF_NEED_RESCHED
 	bo	BASED(io_reschedule)
-	tm	__TI_flags+3(%r9),(_TIF_SIGPENDING | _TIF_RESTORE_SIGMASK)
+	tm	__TI_flags+3(%r9),_TIF_SIGPENDING
 	bnz	BASED(io_sigpending)
 	b	BASED(io_restore)
 io_work_done:
@@ -693,7 +693,7 @@ io_reschedule:
 	b	BASED(io_work_loop)
 
 #
-# _TIF_SIGPENDING or _TIF_RESTORE_SIGMASK is set, call do_signal
+# _TIF_SIGPENDING is set, call do_signal
 #
 io_sigpending:
 	TRACE_IRQS_ON
diff --git a/arch/s390/kernel/entry64.S b/arch/s390/kernel/entry64.S
index efde6e1..0338579 100644
--- a/arch/s390/kernel/entry64.S
+++ b/arch/s390/kernel/entry64.S
@@ -52,9 +52,9 @@ SP_SIZE      =	STACK_FRAME_OVERHEAD + __PT_SIZE
 STACK_SHIFT = PAGE_SHIFT + THREAD_ORDER
 STACK_SIZE  = 1 << STACK_SHIFT
 
-_TIF_WORK_SVC = (_TIF_SIGPENDING | _TIF_RESTORE_SIGMASK | _TIF_NEED_RESCHED | \
+_TIF_WORK_SVC = (_TIF_SIGPENDING | _TIF_NEED_RESCHED | \
 		 _TIF_MCCK_PENDING | _TIF_RESTART_SVC | _TIF_SINGLE_STEP )
-_TIF_WORK_INT = (_TIF_SIGPENDING | _TIF_RESTORE_SIGMASK | _TIF_NEED_RESCHED | \
+_TIF_WORK_INT = (_TIF_SIGPENDING | _TIF_NEED_RESCHED | \
 		 _TIF_MCCK_PENDING)
 
 #define BASED(name) name-system_call(%r13)
@@ -308,7 +308,7 @@ sysc_work:
 	jo	sysc_mcck_pending
 	tm	__TI_flags+7(%r9),_TIF_NEED_RESCHED
 	jo	sysc_reschedule
-	tm	__TI_flags+7(%r9),(_TIF_SIGPENDING | _TIF_RESTORE_SIGMASK)
+	tm	__TI_flags+7(%r9),_TIF_SIGPENDING
 	jnz	sysc_sigpending
 	tm	__TI_flags+7(%r9),_TIF_RESTART_SVC
 	jo	sysc_restart
@@ -332,7 +332,7 @@ sysc_mcck_pending:
 	jg	s390_handle_mcck	# TIF bit will be cleared by handler
 
 #
-# _TIF_SIGPENDING or _TIF_RESTORE_SIGMASK is set, call do_signal
+# _TIF_SIGPENDING is set, call do_signal
 #
 sysc_sigpending:
 	ni	__TI_flags+7(%r9),255-_TIF_SINGLE_STEP # clear TIF_SINGLE_STEP
@@ -647,7 +647,7 @@ io_work_loop:
 	jo	io_mcck_pending
 	tm	__TI_flags+7(%r9),_TIF_NEED_RESCHED
 	jo	io_reschedule
-	tm	__TI_flags+7(%r9),(_TIF_SIGPENDING | _TIF_RESTORE_SIGMASK)
+	tm	__TI_flags+7(%r9),_TIF_SIGPENDING
 	jnz	io_sigpending
 	j	io_restore
 io_work_done:
@@ -673,7 +673,7 @@ io_reschedule:
 	j	io_work_loop
 
 #
-# _TIF_SIGPENDING or _TIF_RESTORE_SIGMASK is set, call do_signal
+# _TIF_SIGPENDING or is set, call do_signal
 #
 io_sigpending:
 	TRACE_IRQS_ON
diff --git a/include/asm-s390/thread_info.h b/include/asm-s390/thread_info.h
index 0a51891..99bbed9 100644
--- a/include/asm-s390/thread_info.h
+++ b/include/asm-s390/thread_info.h
@@ -89,7 +89,6 @@ static inline struct thread_info *current_thread_info(void)
  * thread information flags bit numbers
  */
 #define TIF_SYSCALL_TRACE	0	/* syscall trace active */
-#define TIF_RESTORE_SIGMASK	1	/* restore signal mask in do_signal() */
 #define TIF_SIGPENDING		2	/* signal pending */
 #define TIF_NEED_RESCHED	3	/* rescheduling necessary */
 #define TIF_RESTART_SVC		4	/* restart svc with new svc number */
@@ -101,6 +100,7 @@ static inline struct thread_info *current_thread_info(void)
 					   TIF_NEED_RESCHED */
 #define TIF_31BIT		18	/* 32bit process */ 
 #define TIF_MEMDIE		19
+#define TIF_RESTORE_SIGMASK	20	/* restore signal mask in do_signal() */
 
 #define _TIF_SYSCALL_TRACE	(1<<TIF_SYSCALL_TRACE)
 #define _TIF_RESTORE_SIGMASK	(1<<TIF_RESTORE_SIGMASK)
