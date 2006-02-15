From: dcn@sgi.com (Dean Nelson)
Date: Wed, 15 Feb 2006 14:02:21 +0000
Subject: [PATCH] enforce proper ordering of callouts by XPC
Message-Id: <43F3346D.mailxJQJ1UP0H1@aqua.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Fix XPC so that it does not deliver any messages until the connected
callout has returned, as well as, prevent the disconnected callout to
occur before the disconnecting callout has returned.

Signed-off-by: Dean Nelson <dcn@sgi.com>

---

Tony, I'd really appreciate it if this patch could get into 2.6.16. Thanks.

 arch/ia64/sn/kernel/xpc_channel.c |    8 +++++---
 arch/ia64/sn/kernel/xpc_main.c    |   20 +++++++++++++-------
 include/asm-ia64/sn/xpc.h         |   27 ++++++++++++++++-----------
 3 files changed, 34 insertions(+), 21 deletions(-)


Index: linux/arch/ia64/sn/kernel/xpc_channel.c
=================================--- linux.orig/arch/ia64/sn/kernel/xpc_channel.c	2006-02-14 07:34:54.000000000 -0600
+++ linux/arch/ia64/sn/kernel/xpc_channel.c	2006-02-14 09:15:20.387178976 -0600
@@ -738,7 +738,9 @@
 
 	/* make sure all activity has settled down first */
 
-	if (atomic_read(&ch->references) > 0) {
+	if (atomic_read(&ch->references) > 0 ||
+			((ch->flags & XPC_C_CONNECTEDCALLOUT_MADE) &&
+			!(ch->flags & XPC_C_DISCONNECTINGCALLOUT_MADE))) {
 		return;
 	}
 	DBUG_ON(atomic_read(&ch->kthreads_assigned) != 0);
@@ -775,7 +777,7 @@
 
 	/* both sides are disconnected now */
 
-	if (ch->flags & XPC_C_CONNECTCALLOUT) {
+	if (ch->flags & XPC_C_DISCONNECTINGCALLOUT_MADE) {
 		spin_unlock_irqrestore(&ch->lock, *irq_flags);
 		xpc_disconnect_callout(ch, xpcDisconnected);
 		spin_lock_irqsave(&ch->lock, *irq_flags);
@@ -1300,7 +1302,7 @@
 				"delivered=%d, partid=%d, channel=%d\n",
 				nmsgs_sent, ch->partid, ch->number);
 
-			if (ch->flags & XPC_C_CONNECTCALLOUT) {
+			if (ch->flags & XPC_C_CONNECTEDCALLOUT_MADE) {
 				xpc_activate_kthreads(ch, nmsgs_sent);
 			}
 		}
Index: linux/arch/ia64/sn/kernel/xpc_main.c
=================================--- linux.orig/arch/ia64/sn/kernel/xpc_main.c	2006-02-14 07:34:59.000000000 -0600
+++ linux/arch/ia64/sn/kernel/xpc_main.c	2006-02-14 09:16:35.613303593 -0600
@@ -751,12 +751,16 @@
 		/* let registerer know that connection has been established */
 
 		spin_lock_irqsave(&ch->lock, irq_flags);
-		if (!(ch->flags & XPC_C_CONNECTCALLOUT)) {
-			ch->flags |= XPC_C_CONNECTCALLOUT;
+		if (!(ch->flags & XPC_C_CONNECTEDCALLOUT)) {
+			ch->flags |= XPC_C_CONNECTEDCALLOUT;
 			spin_unlock_irqrestore(&ch->lock, irq_flags);
 
 			xpc_connected_callout(ch);
 
+			spin_lock_irqsave(&ch->lock, irq_flags);
+			ch->flags |= XPC_C_CONNECTEDCALLOUT_MADE;
+			spin_unlock_irqrestore(&ch->lock, irq_flags);
+
 			/*
 			 * It is possible that while the callout was being
 			 * made that the remote partition sent some messages.
@@ -778,15 +782,17 @@
 
 	if (atomic_dec_return(&ch->kthreads_assigned) = 0) {
 		spin_lock_irqsave(&ch->lock, irq_flags);
-		if ((ch->flags & XPC_C_CONNECTCALLOUT) &&
-				!(ch->flags & XPC_C_DISCONNECTCALLOUT)) {
-			ch->flags |= XPC_C_DISCONNECTCALLOUT;
+		if ((ch->flags & XPC_C_CONNECTEDCALLOUT_MADE) &&
+				!(ch->flags & XPC_C_DISCONNECTINGCALLOUT)) {
+			ch->flags |= XPC_C_DISCONNECTINGCALLOUT;
 			spin_unlock_irqrestore(&ch->lock, irq_flags);
 
 			xpc_disconnect_callout(ch, xpcDisconnecting);
-		} else {
-			spin_unlock_irqrestore(&ch->lock, irq_flags);
+
+			spin_lock_irqsave(&ch->lock, irq_flags);
+			ch->flags |= XPC_C_DISCONNECTINGCALLOUT_MADE;
 		}
+		spin_unlock_irqrestore(&ch->lock, irq_flags);
 		if (atomic_dec_return(&part->nchannels_engaged) = 0) {
 			xpc_mark_partition_disengaged(part);
 			xpc_IPI_send_disengage(part);
Index: linux/include/asm-ia64/sn/xpc.h
=================================--- linux.orig/include/asm-ia64/sn/xpc.h	2006-02-14 07:34:59.000000000 -0600
+++ linux/include/asm-ia64/sn/xpc.h	2006-02-14 09:25:54.237799446 -0600
@@ -508,19 +508,24 @@
 #define	XPC_C_OPENREQUEST	0x00000010 /* local open channel request */
 
 #define	XPC_C_SETUP		0x00000020 /* channel's msgqueues are alloc'd */
-#define	XPC_C_CONNECTCALLOUT	0x00000040 /* channel connected callout made */
-#define	XPC_C_CONNECTED		0x00000080 /* local channel is connected */
-#define	XPC_C_CONNECTING	0x00000100 /* channel is being connected */
+#define	XPC_C_CONNECTEDCALLOUT	0x00000040 /* connected callout initiated */
+#define	XPC_C_CONNECTEDCALLOUT_MADE \
+				0x00000080 /* connected callout completed */
+#define	XPC_C_CONNECTED		0x00000100 /* local channel is connected */
+#define	XPC_C_CONNECTING	0x00000200 /* channel is being connected */
 
-#define	XPC_C_RCLOSEREPLY	0x00000200 /* remote close channel reply */
-#define	XPC_C_CLOSEREPLY	0x00000400 /* local close channel reply */
-#define	XPC_C_RCLOSEREQUEST	0x00000800 /* remote close channel request */
-#define	XPC_C_CLOSEREQUEST	0x00001000 /* local close channel request */
+#define	XPC_C_RCLOSEREPLY	0x00000400 /* remote close channel reply */
+#define	XPC_C_CLOSEREPLY	0x00000800 /* local close channel reply */
+#define	XPC_C_RCLOSEREQUEST	0x00001000 /* remote close channel request */
+#define	XPC_C_CLOSEREQUEST	0x00002000 /* local close channel request */
 
-#define	XPC_C_DISCONNECTED	0x00002000 /* channel is disconnected */
-#define	XPC_C_DISCONNECTING	0x00004000 /* channel is being disconnected */
-#define	XPC_C_DISCONNECTCALLOUT	0x00008000 /* chan disconnected callout made */
-#define	XPC_C_WDISCONNECT	0x00010000 /* waiting for channel disconnect */
+#define	XPC_C_DISCONNECTED	0x00004000 /* channel is disconnected */
+#define	XPC_C_DISCONNECTING	0x00008000 /* channel is being disconnected */
+#define	XPC_C_DISCONNECTINGCALLOUT \
+				0x00010000 /* disconnecting callout initiated */
+#define	XPC_C_DISCONNECTINGCALLOUT_MADE \
+				0x00020000 /* disconnecting callout completed */
+#define	XPC_C_WDISCONNECT	0x00040000 /* waiting for channel disconnect */
 
 
 
