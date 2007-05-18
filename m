From: Robin Holt <holt@sgi.com>
Date: Fri, 18 May 2007 18:46:52 +0000
Subject: [PATCH 2/2] Only unwind non-running tasks.
Message-Id: <20070518184652.GC9217@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Unwinding a running task has proven problematic.

In one instance, the running task was attempting to unwind itself and
received an interrupt between when get_wchan allocated local variables on
the stack and when unw_init_from_blocked_task was called which resulted
in unw_init_frame_info to place this tasks task_struct pointer over the
switch stack's ar_bspstore entry.

Signed-off-by: Robin Holt <holt@sgi.com>


Index: linux-tot-20070517/arch/ia64/kernel/process.c
=================================--- linux-tot-20070517.orig/arch/ia64/kernel/process.c	2007-05-18 10:14:45.485516967 -0500
+++ linux-tot-20070517/arch/ia64/kernel/process.c	2007-05-18 10:15:10.340573728 -0500
@@ -763,6 +763,9 @@ get_wchan (struct task_struct *p)
 	unsigned long ip;
 	int count = 0;
 
+	if (!p || p = current || p->state = TASK_RUNNING)
+		return 0;
+
 	/*
 	 * Note: p may not be a blocked task (it could be current or
 	 * another process running on some other CPU.  Rather than
@@ -773,6 +776,8 @@ get_wchan (struct task_struct *p)
 	 */
 	unw_init_from_blocked_task(&info, p);
 	do {
+		if (p->state = TASK_RUNNING)
+			return 0;
 		if (unw_unwind(&info) < 0)
 			return 0;
 		unw_get_ip(&info, &ip);
