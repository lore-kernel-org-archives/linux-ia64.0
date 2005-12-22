From: dcn@sgi.com (Dean Nelson)
Date: Thu, 22 Dec 2005 20:32:56 +0000
Subject: [PATCH] ensure XPC disengage request is processed
Message-Id: <43AB0D78.mailxEG61RPPNY@aqua.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch fixes a problem in XPC disengage processing whereby it was not
seeing the request to disengage from a remote partition, so the disengage
wasn't happening. The disengagement is suppose to transpire during the time
a XPC channel is disconnecting, and should be completed before the channel
is declared to be disconnected.

Signed-off-by: Dean Nelson <dcn@sgi.com>


Index: linux-2.6.git-test/include/asm-ia64/sn/xp.h
=================================--- linux-2.6.git-test.orig/include/asm-ia64/sn/xp.h	2005-12-22 06:49:41.254970354 -0600
+++ linux-2.6.git-test/include/asm-ia64/sn/xp.h	2005-12-22 06:50:18.479711698 -0600
@@ -227,7 +227,9 @@
 
 	xpcOpenCloseError,	/* 50: channel open/close protocol error */
 
-	xpcUnknownReason	/* 51: unknown reason -- must be last in list */
+	xpcDisconnected,	/* 51: channel disconnected (closed) */
+
+	xpcUnknownReason	/* 52: unknown reason -- must be last in list */
 };
 
 
Index: linux-2.6.git-test/arch/ia64/sn/kernel/xpc.h
=================================--- linux-2.6.git-test.orig/arch/ia64/sn/kernel/xpc.h	2005-12-22 06:49:41.254970354 -0600
+++ linux-2.6.git-test/arch/ia64/sn/kernel/xpc.h	2005-12-22 06:50:18.481664625 -0600
@@ -707,7 +707,7 @@
 extern void xpc_deliver_msg(struct xpc_channel *);
 extern void xpc_disconnect_channel(const int, struct xpc_channel *,
 					enum xpc_retval, unsigned long *);
-extern void xpc_disconnecting_callout(struct xpc_channel *);
+extern void xpc_disconnect_callout(struct xpc_channel *, enum xpc_retval);
 extern void xpc_partition_going_down(struct xpc_partition *, enum xpc_retval);
 extern void xpc_teardown_infrastructure(struct xpc_partition *);
 
Index: linux-2.6.git-test/arch/ia64/sn/kernel/xpc_partition.c
=================================--- linux-2.6.git-test.orig/arch/ia64/sn/kernel/xpc_partition.c	2005-12-22 06:28:25.053721391 -0600
+++ linux-2.6.git-test/arch/ia64/sn/kernel/xpc_partition.c	2005-12-22 06:55:30.386530303 -0600
@@ -771,7 +771,8 @@
 		}
 	}
 
-	if (!xpc_partition_disengaged(part)) {
+	if (part->disengage_request_timeout > 0 &&
+					!xpc_partition_disengaged(part)) {
 		/* still waiting on other side to disengage from us */
 		return;
 	}
Index: linux-2.6.git-test/arch/ia64/sn/kernel/xpc_channel.c
=================================--- linux-2.6.git-test.orig/arch/ia64/sn/kernel/xpc_channel.c	2005-12-22 06:28:25.050792007 -0600
+++ linux-2.6.git-test/arch/ia64/sn/kernel/xpc_channel.c	2005-12-22 07:39:56.437818525 -0600
@@ -779,6 +779,12 @@
 
 	/* both sides are disconnected now */
 
+	if (ch->flags & XPC_C_CONNECTCALLOUT) {
+		spin_unlock_irqrestore(&ch->lock, *irq_flags);
+		xpc_disconnect_callout(ch, xpcDisconnected);
+		spin_lock_irqsave(&ch->lock, *irq_flags);
+	}
+
 	/* it's now safe to free the channel's message queues */
 	xpc_free_msgqueues(ch);
 
@@ -1645,7 +1651,7 @@
 
 
 void
-xpc_disconnecting_callout(struct xpc_channel *ch)
+xpc_disconnect_callout(struct xpc_channel *ch, enum xpc_retval reason)
 {
 	/*
 	 * Let the channel's registerer know that the channel is being
@@ -1654,15 +1660,13 @@
 	 */
 
 	if (ch->func != NULL) {
-		dev_dbg(xpc_chan, "ch->func() called, reason=xpcDisconnecting,"
-			" partid=%d, channel=%d\n", ch->partid, ch->number);
+		dev_dbg(xpc_chan, "ch->func() called, reason=%d, partid=%d, "
+			"channel=%d\n", reason, ch->partid, ch->number);
 
-		ch->func(xpcDisconnecting, ch->partid, ch->number, NULL,
-								ch->key);
+		ch->func(reason, ch->partid, ch->number, NULL, ch->key);
 
-		dev_dbg(xpc_chan, "ch->func() returned, reason="
-			"xpcDisconnecting, partid=%d, channel=%d\n",
-			ch->partid, ch->number);
+		dev_dbg(xpc_chan, "ch->func() returned, reason=%d, partid=%d, "
+			"channel=%d\n", reason, ch->partid, ch->number);
 	}
 }
 
Index: linux-2.6.git-test/arch/ia64/sn/kernel/xpc_main.c
=================================--- linux-2.6.git-test.orig/arch/ia64/sn/kernel/xpc_main.c	2005-12-22 06:28:25.051768468 -0600
+++ linux-2.6.git-test/arch/ia64/sn/kernel/xpc_main.c	2005-12-22 07:47:39.695252809 -0600
@@ -773,7 +773,7 @@
 			ch->flags |= XPC_C_DISCONNECTCALLOUT;
 			spin_unlock_irqrestore(&ch->lock, irq_flags);
 
-			xpc_disconnecting_callout(ch);
+			xpc_disconnect_callout(ch, xpcDisconnecting);
 		} else {
 			spin_unlock_irqrestore(&ch->lock, irq_flags);
 		}
