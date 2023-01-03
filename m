From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Tue, 03 Jan 2023 08:14:07 +0000
Subject: [PATCH 5.10 37/63] ia64: add support for TIF_NOTIFY_SIGNAL
Message-Id: <20230103081310.802833748@linuxfoundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230103081308.548338576@linuxfoundation.org>
In-Reply-To: <20230103081308.548338576@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: stable@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, patches@lists.linux.dev, linux-ia64@vger.kernel.org, Jens Axboe <axboe@kernel.dk>

From: Jens Axboe <axboe@kernel.dk>

[ Upstream commit b269c229b0e89aedb7943c06673b56b6052cf5e5 ]

Wire up TIF_NOTIFY_SIGNAL handling for ia64.

Cc: linux-ia64@vger.kernel.org
[axboe: added fixes from Mike Rapoport <rppt@kernel.org>]
Signed-off-by: Jens Axboe <axboe@kernel.dk>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 arch/ia64/include/asm/thread_info.h |    4 +++-
 arch/ia64/kernel/process.c          |    3 ++-
 2 files changed, 5 insertions(+), 2 deletions(-)

--- a/arch/ia64/include/asm/thread_info.h
+++ b/arch/ia64/include/asm/thread_info.h
@@ -103,6 +103,7 @@ struct thread_info {
 #define TIF_SYSCALL_TRACE	2	/* syscall trace active */
 #define TIF_SYSCALL_AUDIT	3	/* syscall auditing active */
 #define TIF_SINGLESTEP		4	/* restore singlestep on return to user mode */
+#define TIF_NOTIFY_SIGNAL	5	/* signal notification exist */
 #define TIF_NOTIFY_RESUME	6	/* resumption notification requested */
 #define TIF_MEMDIE		17	/* is terminating due to OOM killer */
 #define TIF_MCA_INIT		18	/* this task is processing MCA or INIT */
@@ -115,6 +116,7 @@ struct thread_info {
 #define _TIF_SINGLESTEP		(1 << TIF_SINGLESTEP)
 #define _TIF_SYSCALL_TRACEAUDIT	(_TIF_SYSCALL_TRACE|_TIF_SYSCALL_AUDIT|_TIF_SINGLESTEP)
 #define _TIF_NOTIFY_RESUME	(1 << TIF_NOTIFY_RESUME)
+#define _TIF_NOTIFY_SIGNAL	(1 << TIF_NOTIFY_SIGNAL)
 #define _TIF_SIGPENDING		(1 << TIF_SIGPENDING)
 #define _TIF_NEED_RESCHED	(1 << TIF_NEED_RESCHED)
 #define _TIF_MCA_INIT		(1 << TIF_MCA_INIT)
@@ -124,7 +126,7 @@ struct thread_info {
 
 /* "work to do on user-return" bits */
 #define TIF_ALLWORK_MASK	(_TIF_SIGPENDING|_TIF_NOTIFY_RESUME|_TIF_SYSCALL_AUDIT|\
-				 _TIF_NEED_RESCHED|_TIF_SYSCALL_TRACE)
+				 _TIF_NEED_RESCHED|_TIF_SYSCALL_TRACE|_TIF_NOTIFY_SIGNAL)
 /* like TIF_ALLWORK_BITS but sans TIF_SYSCALL_TRACE or TIF_SYSCALL_AUDIT */
 #define TIF_WORK_MASK		(TIF_ALLWORK_MASK&~(_TIF_SYSCALL_TRACE|_TIF_SYSCALL_AUDIT))
 
--- a/arch/ia64/kernel/process.c
+++ b/arch/ia64/kernel/process.c
@@ -171,7 +171,8 @@ do_notify_resume_user(sigset_t *unused,
 	}
 
 	/* deal with pending signal delivery */
-	if (test_thread_flag(TIF_SIGPENDING)) {
+	if (test_thread_flag(TIF_SIGPENDING) ||
+	    test_thread_flag(TIF_NOTIFY_SIGNAL)) {
 		local_irq_enable();	/* force interrupt enable */
 		ia64_do_signal(scr, in_syscall);
 	}

