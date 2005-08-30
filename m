From: Keith Owens <kaos@sgi.com>
Date: Tue, 30 Aug 2005 05:04:24 +0000
Subject: [PATCH 2.6.13 2/7] MCA/INIT: add an extra thread_info flag
Message-Id: <20050830050424.7997.56925.sendpatchset@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Add an extra thread_info flag to indicate the special MCA/INIT stacks.
Mainly for debuggers.

Signed-off-by: Keith Owens <kaos@sgi.com>

---

 ptrace.h      |    2 +-
 thread_info.h |    2 ++
 2 files changed, 3 insertions(+), 1 deletion(-)

Index: linux/include/asm-ia64/ptrace.h
=================================--- linux.orig/include/asm-ia64/ptrace.h	2005-06-18 05:48:29.000000000 +1000
+++ linux/include/asm-ia64/ptrace.h	2005-08-01 12:25:33.360883229 +1000
@@ -119,7 +119,7 @@ struct pt_regs {
 	unsigned long ar_unat;		/* interrupted task's NaT register (preserved) */
 	unsigned long ar_pfs;		/* prev function state  */
 	unsigned long ar_rsc;		/* RSE configuration */
-	/* The following two are valid only if cr_ipsr.cpl > 0: */
+	/* The following two are valid only if cr_ipsr.cpl > 0 || ti->flags & _TIF_MCA_INIT */
 	unsigned long ar_rnat;		/* RSE NaT */
 	unsigned long ar_bspstore;	/* RSE bspstore */
 
Index: linux/include/asm-ia64/thread_info.h
=================================--- linux.orig/include/asm-ia64/thread_info.h	2005-08-01 11:49:13.053126287 +1000
+++ linux/include/asm-ia64/thread_info.h	2005-08-01 12:25:48.541555064 +1000
@@ -76,6 +76,7 @@ struct thread_info {
 #define TIF_SIGDELAYED		5	/* signal delayed from MCA/INIT/NMI/PMI context */
 #define TIF_POLLING_NRFLAG	16	/* true if poll_idle() is polling TIF_NEED_RESCHED */
 #define TIF_MEMDIE		17
+#define TIF_MCA_INIT		18	/* this task is processing MCA or INIT */
 
 #define _TIF_SYSCALL_TRACE	(1 << TIF_SYSCALL_TRACE)
 #define _TIF_SYSCALL_AUDIT	(1 << TIF_SYSCALL_AUDIT)
@@ -85,6 +86,7 @@ struct thread_info {
 #define _TIF_NEED_RESCHED	(1 << TIF_NEED_RESCHED)
 #define _TIF_SIGDELAYED	(1 << TIF_SIGDELAYED)
 #define _TIF_POLLING_NRFLAG	(1 << TIF_POLLING_NRFLAG)
+#define _TIF_MCA_INIT		(1 << TIF_MCA_INIT)
 
 /* "work to do on user-return" bits */
 #define TIF_ALLWORK_MASK	(_TIF_NOTIFY_RESUME|_TIF_SIGPENDING|_TIF_NEED_RESCHED|_TIF_SYSCALL_TRACE|_TIF_SYSCALL_AUDIT|_TIF_SIGDELAYED)
