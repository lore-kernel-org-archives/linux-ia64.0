From: Robin Holt <holt@sgi.com>
Date: Thu, 02 Feb 2006 18:30:21 +0000
Subject: Re: [Patch] Fix XPC code which sleeps with spin_lock_irqsave().
Message-Id: <20060202183021.GA13871@attica.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060201145537.GC21833@lnx-holt.americas.sgi.com>
In-Reply-To: <20060201145537.GC21833@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

During some testing, we got a warning about trying to allocate
memory while holding a lock.  This fixes that problem.

Signed-off-by: Robin Holt <holt@sgi.com>
Acked-by: Dean Nelson <dcn@sgi.com>

----

This replaces the patch I sent yesterday.  Dean pointed out that the
spin_lock_irqsave does not need to happen when the kernel_thread succeeds.
Tony, If you have not already taken either of the patches, please use
this one instead.


Index: linux-2.6/arch/ia64/sn/kernel/xpc_main.c
=================================--- linux-2.6.orig/arch/ia64/sn/kernel/xpc_main.c	2006-02-01 07:26:10.156287841 -0600
+++ linux-2.6/arch/ia64/sn/kernel/xpc_main.c	2006-02-02 07:25:25.611646908 -0600
@@ -575,18 +575,21 @@ xpc_activate_partition(struct xpc_partit
 
 	spin_lock_irqsave(&part->act_lock, irq_flags);
 
-	pid = kernel_thread(xpc_activating, (void *) ((u64) partid), 0);
-
 	DBUG_ON(part->act_state != XPC_P_INACTIVE);
 
-	if (pid > 0) {
-		part->act_state = XPC_P_ACTIVATION_REQ;
-		XPC_SET_REASON(part, xpcCloneKThread, __LINE__);
-	} else {
-		XPC_SET_REASON(part, xpcCloneKThreadFailed, __LINE__);
-	}
+	part->act_state = XPC_P_ACTIVATION_REQ;
+	XPC_SET_REASON(part, xpcCloneKThread, __LINE__);
 
 	spin_unlock_irqrestore(&part->act_lock, irq_flags);
+
+	pid = kernel_thread(xpc_activating, (void *) ((u64) partid), 0);
+
+	if (unlikely(pid <= 0)) {
+		spin_lock_irqsave(&part->act_lock, irq_flags);
+		part->act_state = XPC_P_INACTIVE;
+		XPC_SET_REASON(part, xpcCloneKThreadFailed, __LINE__);
+		spin_unlock_irqrestore(&part->act_lock, irq_flags);
+	}
 }
 
 

