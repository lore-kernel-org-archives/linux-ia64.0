From: Robin Holt <holt@sgi.com>
Date: Wed, 01 Feb 2006 14:55:37 +0000
Subject: [Patch] Fix XPC code which sleeps with spin_lock_irqsave().
Message-Id: <20060201145537.GC21833@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

During some testing, we got a warning about trying to allocate
memory while holding a lock.  This fixes that problem.

Signed-off-by: Robin Holt <holt@sgi.com>
Acked-by: Dean Nelson <dcn@sgi.com>


Index: linux-2.6/arch/ia64/sn/kernel/xpc_main.c
=================================--- linux-2.6.orig/arch/ia64/sn/kernel/xpc_main.c	2006-02-01 07:26:10.156287841 -0600
+++ linux-2.6/arch/ia64/sn/kernel/xpc_main.c	2006-02-01 07:29:04.463443840 -0600
@@ -575,14 +575,19 @@ xpc_activate_partition(struct xpc_partit
 
 	spin_lock_irqsave(&part->act_lock, irq_flags);
 
+	DBUG_ON(part->act_state != XPC_P_INACTIVE);
+
+	part->act_state = XPC_P_ACTIVATION_REQ;
+	XPC_SET_REASON(part, xpcCloneKThread, __LINE__);
+
+	spin_unlock_irqrestore(&part->act_lock, irq_flags);
+
 	pid = kernel_thread(xpc_activating, (void *) ((u64) partid), 0);
 
-	DBUG_ON(part->act_state != XPC_P_INACTIVE);
+	spin_lock_irqsave(&part->act_lock, irq_flags);
 
-	if (pid > 0) {
-		part->act_state = XPC_P_ACTIVATION_REQ;
-		XPC_SET_REASON(part, xpcCloneKThread, __LINE__);
-	} else {
+	if (pid <= 0) {
+		part->act_state = XPC_P_INACTIVE;
 		XPC_SET_REASON(part, xpcCloneKThreadFailed, __LINE__);
 	}
 
