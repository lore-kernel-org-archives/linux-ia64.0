From: Vladimir Simonov <sv@sw.com.sg>
Date: Fri, 21 Mar 2003 09:36:23 +0000
Subject: [Linux-ia64] show_trace_task portability
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------070404030001040607040703"
Message-Id: <marc-linux-ia64-105590723705283@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------070404030001040607040703
Content-Type: text/plain; charset=KOI8-R; format=flowed
Content-Transfer-Encoding: 7bit

Hi!
Trying to port some patches from i386 to ia64 I've found that
show_trace_task is the only portable way to show tasks' call
traces(perhaps because it is called from ./kernel/sched.c:)).
But its ia64 implementation can't work with running task.

Attached patch fixes this issue.

As I understand show_trace and show_stack are platform
dependent or have different sense/args.

Any opinion?

Best regards
Vladimir Simonov


--------------070404030001040607040703
Content-Type: text/plain;
 name="diff-show_trace_task.ia64"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="diff-show_trace_task.ia64"

--- linux.orig/arch/ia64/kernel/process.c	Fri Mar 21 08:32:37 2003
+++ linux/arch/ia64/kernel/process.c		Fri Mar 21 08:53:06 2003
@@ -53,10 +53,7 @@
 void
 show_trace_task (struct task_struct *task)
 {
-	struct unw_frame_info info;
-
-	unw_init_from_blocked_task(&info, task);
-	do_show_stack(&info, 0);
+	show_stack(task);
 }
 
 void

--------------070404030001040607040703--


