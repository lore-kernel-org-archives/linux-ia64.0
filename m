From: Jes Sorensen <jes@sgi.com>
Date: Thu, 19 Apr 2007 11:47:45 +0000
Subject: [Fwd: [PATCH] ia64 sn xpc: Convert to use kthread API.]
Message-Id: <462756E1.2060100@sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------090300060901070307060306"
List-Id: <linux-ia64.vger.kernel.org>
To: rja@sgi.com
Cc: holt@sgi.com, Andrew Morton <akpm@osdl.org>, "Eric W. Biederman" <ebiederm@xmission.com>, tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

This is a multi-part message in MIME format.
--------------090300060901070307060306
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Russ, Robin,

Any objections to this patch?

Eric, please send such patches to the appropriate list, it's in ia64
file after all.

Thanks,
Jes


--------------090300060901070307060306
Content-Type: message/rfc822;
 name="[PATCH] ia64 sn xpc: Convert to use kthread API."
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="[PATCH] ia64 sn xpc: Convert to use kthread API."

Return-Path: <eric@ebiederm.dsl.xmission.com>
X-Original-To: jes@estes.americas.sgi.com
Delivered-To: jes@estes.americas.sgi.com
Received: from relay.sgi.com (netops-testserver-4.corp.sgi.com [192.26.58.214])
	by estes.americas.sgi.com (Postfix) with ESMTP id CAC3870001D5
	for <jes@estes.americas.sgi.com>; Thu, 19 Apr 2007 03:10:16 -0500 (CDT)
Received: from cuda.sgi.com (cuda3.sgi.com [192.48.176.15])
	by netops-testserver-4.corp.sgi.com (Postfix) with ESMTP id 6BF9A61B76
	for <jes@sgi.com>; Thu, 19 Apr 2007 01:10:16 -0700 (PDT)
X-ASG-Debug-ID: 1176970214-79dd00600000-q765qN
X-Barracuda-URL: http://cuda.sgi.com:80/cgi-bin/mark.cgi
Received: from ebiederm.dsl.xmission.com (ebiederm.dsl.xmission.com [166.70.28.69])
	by cuda.sgi.com (Spam Firewall) with ESMTP id D2B31161F326
	for <jes@sgi.com>; Thu, 19 Apr 2007 01:10:14 -0700 (PDT)
Received: from ebiederm.dsl.xmission.com (ebiederm.dsl.xmission.com [166.70.28.69]) by cuda.sgi.com with ESMTP id ECUFfuAYyG6NpNmY for <jes@sgi.com>; Thu, 19 Apr 2007 01:10:14 -0700 (PDT)
Received: from ebiederm.dsl.xmission.com (localhost [127.0.0.1])
	by ebiederm.dsl.xmission.com (8.13.8/8.13.8/Debian-3) with ESMTP id l3J7xZQq010539;
	Thu, 19 Apr 2007 01:59:35 -0600
Received: (from eric@localhost)
	by ebiederm.dsl.xmission.com (8.13.8/8.13.8/Submit) id l3J7xYvc010538;
	Thu, 19 Apr 2007 01:59:34 -0600
From: "Eric W. Biederman" <ebiederm@xmission.com>
To: "<Andrew Morton" <akpm@osdl.org>
Cc: <containers@lists.osdl.org>, Oleg Nesterov <oleg@tv-sign.ru>,
	Christoph Hellwig <hch@infradead.org>,
	<linux-kernel@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Jes Sorensen <jes@sgi.com>, Tony Luck <tony.luck@intel.com>
X-ASG-Orig-Subj: [PATCH] ia64 sn xpc: Convert to use kthread API.
Subject: [PATCH] ia64 sn xpc: Convert to use kthread API.
Date: Thu, 19 Apr 2007 01:58:44 -0600
Message-Id: <1176969574439-git-send-email-ebiederm@xmission.com>
X-Mailer: git-send-email 1.5.1.1.g2de0
In-Reply-To: <m1slawn9eb.fsf@ebiederm.dsl.xmission.com>
References: <m1slawn9eb.fsf@ebiederm.dsl.xmission.com>
X-Barracuda-Connect: ebiederm.dsl.xmission.com[166.70.28.69]
X-Barracuda-Start-Time: 1176970214
X-Barracuda-Bayes: INNOCENT GLOBAL 0.0384 1.0000 -1.7733
X-Barracuda-Virus-Scanned: by cuda.sgi.com at sgi.com
X-Barracuda-Spam-Score: -1.77
X-Barracuda-Spam-Status: No, SCORE=-1.77 using per-user scores of TAG_LEVEL=3.5 QUARANTINE_LEVEL=4.5 KILL_LEVEL=9.0 tests=
X-Barracuda-Spam-Report: Code version 3.1, rules version 3.1.14628
	Rule breakdown below
	 pts rule name              description
	---- ---------------------- --------------------------------------------------

From: Eric W. Biederman <ebiederm@xmission.com>

This patch starts the xpc kernel threads using kthread_run
not a combination of kernel_thread and daemonize.  Resuling
in slightly simpler and more maintainable code.

Cc: Jes Sorensen <jes@sgi.com>
Cc: Tony Luck <tony.luck@intel.com>
Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 arch/ia64/sn/kernel/xpc_main.c |   31 +++++++++++++------------------
 1 files changed, 13 insertions(+), 18 deletions(-)

diff --git a/arch/ia64/sn/kernel/xpc_main.c b/arch/ia64/sn/kernel/xpc_main.c
index e336e16..5b53642 100644
--- a/arch/ia64/sn/kernel/xpc_main.c
+++ b/arch/ia64/sn/kernel/xpc_main.c
@@ -56,6 +56,7 @@
 #include <linux/reboot.h>
 #include <linux/completion.h>
 #include <linux/kdebug.h>
+#include <linux/kthread.h>
 #include <asm/sn/intr.h>
 #include <asm/sn/sn_sal.h>
 #include <asm/uaccess.h>
@@ -253,8 +254,6 @@ xpc_hb_checker(void *ignore)
 
 	/* this thread was marked active by xpc_hb_init() */
 
-	daemonize(XPC_HB_CHECK_THREAD_NAME);
-
 	set_cpus_allowed(current, cpumask_of_cpu(XPC_HB_CHECK_CPU));
 
 	xpc_hb_check_timeout = jiffies + (xpc_hb_check_interval * HZ);
@@ -324,8 +323,6 @@ xpc_hb_checker(void *ignore)
 static int
 xpc_initiate_discovery(void *ignore)
 {
-	daemonize(XPC_DISCOVERY_THREAD_NAME);
-
 	xpc_discovery();
 
 	dev_dbg(xpc_part, "discovery thread is exiting\n");
@@ -494,8 +491,6 @@ xpc_activating(void *__partid)
 
 	dev_dbg(xpc_part, "bringing partition %d up\n", partid);
 
-	daemonize("xpc%02d", partid);
-
 	/*
 	 * This thread needs to run at a realtime priority to prevent a
 	 * significant performance degradation.
@@ -559,7 +554,7 @@ xpc_activate_partition(struct xpc_partition *part)
 {
 	partid_t partid = XPC_PARTID(part);
 	unsigned long irq_flags;
-	pid_t pid;
+	struct task_struct *task;
 
 
 	spin_lock_irqsave(&part->act_lock, irq_flags);
@@ -571,9 +566,10 @@ xpc_activate_partition(struct xpc_partition *part)
 
 	spin_unlock_irqrestore(&part->act_lock, irq_flags);
 
-	pid = kernel_thread(xpc_activating, (void *) ((u64) partid), 0);
+	task = kthread_run(xpc_activating, (void *) ((u64) partid),
+			  "xpc%02d", partid);
 
-	if (unlikely(pid <= 0)) {
+	if (unlikely(IS_ERR(task))) {
 		spin_lock_irqsave(&part->act_lock, irq_flags);
 		part->act_state = XPC_P_INACTIVE;
 		XPC_SET_REASON(part, xpcCloneKThreadFailed, __LINE__);
@@ -724,8 +720,6 @@ xpc_daemonize_kthread(void *args)
 	unsigned long irq_flags;
 
 
-	daemonize("xpc%02dc%d", partid, ch_number);
-
 	dev_dbg(xpc_chan, "kthread starting, partid=%d, channel=%d\n",
 		partid, ch_number);
 
@@ -844,8 +838,9 @@ xpc_create_kthreads(struct xpc_channel *ch, int needed,
 		(void) xpc_part_ref(part);
 		xpc_msgqueue_ref(ch);
 
-		pid = kernel_thread(xpc_daemonize_kthread, (void *) args, 0);
-		if (pid < 0) {
+		task = kthread_run(xpc_daemonize_kthread, args,
+				   "xpc%02dc%d", partid, ch_number);
+		if (IS_ERR(task)) {
 			/* the fork failed */
 
 			/*
@@ -1222,7 +1217,7 @@ xpc_init(void)
 	int ret;
 	partid_t partid;
 	struct xpc_partition *part;
-	pid_t pid;
+	struct task_struct *task;
 	size_t buf_size;
 
 
@@ -1353,8 +1348,8 @@ xpc_init(void)
 	 * The real work-horse behind xpc.  This processes incoming
 	 * interrupts and monitors remote heartbeats.
 	 */
-	pid = kernel_thread(xpc_hb_checker, NULL, 0);
-	if (pid < 0) {
+	task = kthread_run(xpc_hb_checker, NULL, XPC_HB_CHECK_THREAD_NAME);
+	if (IS_ERR(task)) {
 		dev_err(xpc_part, "failed while forking hb check thread\n");
 
 		/* indicate to others that our reserved page is uninitialized */
@@ -1384,8 +1379,8 @@ xpc_init(void)
 	 * activate based on info provided by SAL. This new thread is short
 	 * lived and will exit once discovery is complete.
 	 */
-	pid = kernel_thread(xpc_initiate_discovery, NULL, 0);
-	if (pid < 0) {
+	task = kthread_run(xpc_initiate_discovery, NULL, XPC_DISCOVERY_THREAD_NAME);
+	if (IS_ERR(task)) {
 		dev_err(xpc_part, "failed while forking discovery thread\n");
 
 		/* mark this new thread as a non-starter */
-- 
1.5.0.g53756

--------------090300060901070307060306--
