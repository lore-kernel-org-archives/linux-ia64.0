From: dcn@sgi.com (Dean Nelson)
Date: Tue, 25 Oct 2005 19:07:43 +0000
Subject: [PATCH] fixes for XPC disengage and open/close protocol
Message-Id: <435E827F.mailx5HV11SRY9@aqua.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch addresses a few issues with the open/close protocol that
were revealed by the newly added disengage functionality combined
with more extensive testing.

Signed-off-by: Dean Nelson <dcn@sgi.com>


Index: linux-2.6.git#test/include/asm-ia64/sn/xp.h
=================================--- linux-2.6.git#test.orig/include/asm-ia64/sn/xp.h	2005-10-13 09:14:09.306720356 -0500
+++ linux-2.6.git#test/include/asm-ia64/sn/xp.h	2005-10-13 09:42:56.749093273 -0500
@@ -225,7 +225,9 @@
 
 	xpcDisconnecting,	/* 49: channel disconnecting (closing) */
 
-	xpcUnknownReason	/* 50: unknown reason -- must be last in list */
+	xpcOpenCloseError,	/* 50: channel open/close protocol error */
+
+	xpcUnknownReason	/* 51: unknown reason -- must be last in list */
 };
 
 
@@ -350,7 +352,7 @@
  *
  * The 'func' field points to the function to call when aynchronous
  * notification is required for such events as: a connection established/lost,
- * or an incomming message received, or an error condition encountered. A
+ * or an incoming message received, or an error condition encountered. A
  * non-NULL 'func' field indicates that there is an active registration for
  * the channel.
  */
Index: linux-2.6.git#test/arch/ia64/sn/kernel/xpc.h
=================================--- linux-2.6.git#test.orig/arch/ia64/sn/kernel/xpc.h	2005-10-13 09:13:35.654851937 -0500
+++ linux-2.6.git#test/arch/ia64/sn/kernel/xpc.h	2005-10-14 10:50:35.521602529 -0500
@@ -417,6 +417,9 @@
 	atomic_t n_on_msg_allocate_wq;   /* #on msg allocation wait queue */
 	wait_queue_head_t msg_allocate_wq; /* msg allocation wait queue */
 
+	u8 delayed_IPI_flags;		/* IPI flags received, but delayed */
+					/* action until channel disconnected */
+
 	/* queue of msg senders who want to be notified when msg received */
 
 	atomic_t n_to_notify;		/* #of msg senders to notify */
@@ -478,7 +481,8 @@
 
 #define	XPC_C_DISCONNECTED	0x00002000 /* channel is disconnected */
 #define	XPC_C_DISCONNECTING	0x00004000 /* channel is being disconnected */
-#define	XPC_C_WDISCONNECT	0x00008000 /* waiting for channel disconnect */
+#define	XPC_C_DISCONNECTCALLOUT	0x00008000 /* chan disconnected callout made */
+#define	XPC_C_WDISCONNECT	0x00010000 /* waiting for channel disconnect */
 
 
 
@@ -508,13 +512,13 @@
 	int reason_line;		/* line# deactivation initiated from */
 	int reactivate_nasid;		/* nasid in partition to reactivate */
 
-	unsigned long disengage_request_timeout; /* timeout in XPC_TICKS */
+	unsigned long disengage_request_timeout; /* timeout in jiffies */
 	struct timer_list disengage_request_timer;
 
 
 	/* XPC infrastructure referencing and teardown control */
 
-	volatile u8 setup_state;			/* infrastructure setup state */
+	volatile u8 setup_state;	/* infrastructure setup state */
 	wait_queue_head_t teardown_wq;	/* kthread waiting to teardown infra */
 	atomic_t references;		/* #of references to infrastructure */
 
@@ -604,7 +608,7 @@
 
 
 /* number of seconds to wait for other partitions to disengage */
-#define XPC_DISENGAGE_REQUEST_TIMELIMIT 90
+#define XPC_DISENGAGE_REQUEST_DEFAULT_TIMELIMIT	90
 
 /* interval in seconds to print 'waiting disengagement' messages */
 #define XPC_DISENGAGE_PRINTMSG_INTERVAL		10
@@ -618,20 +622,18 @@
 extern struct xpc_registration xpc_registrations[];
 
 
-/* >>> found in xpc_main.c only */
+/* found in xpc_main.c */
 extern struct device *xpc_part;
 extern struct device *xpc_chan;
+extern int xpc_disengage_request_timelimit;
 extern irqreturn_t xpc_notify_IRQ_handler(int, void *, struct pt_regs *);
 extern void xpc_dropped_IPI_check(struct xpc_partition *);
+extern void xpc_activate_partition(struct xpc_partition *);
 extern void xpc_activate_kthreads(struct xpc_channel *, int);
 extern void xpc_create_kthreads(struct xpc_channel *, int);
 extern void xpc_disconnect_wait(int);
 
 
-/* found in xpc_main.c and efi-xpc.c */
-extern void xpc_activate_partition(struct xpc_partition *);
-
-
 /* found in xpc_partition.c */
 extern int xpc_exiting;
 extern struct xpc_vars *xpc_vars;
@@ -1077,6 +1079,7 @@
 
 /* given an AMO variable and a channel#, get its associated IPI flags */
 #define XPC_GET_IPI_FLAGS(_amo, _c)	((u8) (((_amo) >> ((_c) * 8)) & 0xff))
+#define XPC_SET_IPI_FLAGS(_amo, _c, _f)	(_amo) |= ((u64) (_f) << ((_c) * 8))
 
 #define	XPC_ANY_OPENCLOSE_IPI_FLAGS_SET(_amo) ((_amo) & 0x0f0f0f0f0f0f0f0f)
 #define XPC_ANY_MSG_IPI_FLAGS_SET(_amo)       ((_amo) & 0x1010101010101010)
Index: linux-2.6.git#test/arch/ia64/sn/kernel/xpc_main.c
=================================--- linux-2.6.git#test.orig/arch/ia64/sn/kernel/xpc_main.c	2005-10-13 09:13:35.656804865 -0500
+++ linux-2.6.git#test/arch/ia64/sn/kernel/xpc_main.c	2005-10-14 11:19:27.816319194 -0500
@@ -91,6 +91,10 @@
 static int xpc_hb_check_min_interval = 10;
 static int xpc_hb_check_max_interval = 120;
 
+int xpc_disengage_request_timelimit = XPC_DISENGAGE_REQUEST_DEFAULT_TIMELIMIT;
+static int xpc_disengage_request_min_timelimit = 0;
+static int xpc_disengage_request_max_timelimit = 120;
+
 static ctl_table xpc_sys_xpc_hb_dir[] = {
 	{
 		1,
@@ -129,6 +133,19 @@
 		0555,
 		xpc_sys_xpc_hb_dir
 	},
+	{
+		2,
+		"disengage_request_timelimit",
+		&xpc_disengage_request_timelimit,
+		sizeof(int),
+		0644,
+		NULL,
+		&proc_dointvec_minmax,
+		&sysctl_intvec,
+		NULL,
+		&xpc_disengage_request_min_timelimit,
+		&xpc_disengage_request_max_timelimit
+	},
 	{0}
 };
 static ctl_table xpc_sys_dir[] = {
@@ -153,11 +170,11 @@
 
 static unsigned long xpc_hb_check_timeout;
 
-/* used as an indication of when the xpc_hb_checker thread is inactive */
-static DECLARE_MUTEX_LOCKED(xpc_hb_checker_inactive);
+/* notification that the xpc_hb_checker thread has exited */
+static DECLARE_MUTEX_LOCKED(xpc_hb_checker_exited);
 
-/* used as an indication of when the xpc_discovery thread is inactive */
-static DECLARE_MUTEX_LOCKED(xpc_discovery_inactive);
+/* notification that the xpc_discovery thread has exited */
+static DECLARE_MUTEX_LOCKED(xpc_discovery_exited);
 
 
 static struct timer_list xpc_hb_timer;
@@ -181,7 +198,7 @@
 	struct xpc_partition *part = (struct xpc_partition *) data;
 
 
-	DBUG_ON(XPC_TICKS < part->disengage_request_timeout);
+	DBUG_ON(jiffies < part->disengage_request_timeout);
 
 	(void) xpc_partition_disengaged(part);
 
@@ -292,8 +309,8 @@
 	dev_dbg(xpc_part, "heartbeat checker is exiting\n");
 
 
-	/* mark this thread as inactive */
-	up(&xpc_hb_checker_inactive);
+	/* mark this thread as having exited */
+	up(&xpc_hb_checker_exited);
 	return 0;
 }
 
@@ -312,8 +329,8 @@
 
 	dev_dbg(xpc_part, "discovery thread is exiting\n");
 
-	/* mark this thread as inactive */
-	up(&xpc_discovery_inactive);
+	/* mark this thread as having exited */
+	up(&xpc_discovery_exited);
 	return 0;
 }
 
@@ -703,6 +720,7 @@
 	struct xpc_partition *part = &xpc_partitions[partid];
 	struct xpc_channel *ch;
 	int n_needed;
+	unsigned long irq_flags;
 
 
 	daemonize("xpc%02dc%d", partid, ch_number);
@@ -713,11 +731,14 @@
 	ch = &part->channels[ch_number];
 
 	if (!(ch->flags & XPC_C_DISCONNECTING)) {
-		DBUG_ON(!(ch->flags & XPC_C_CONNECTED));
 
 		/* let registerer know that connection has been established */
 
-		if (atomic_read(&ch->kthreads_assigned) = 1) {
+		spin_lock_irqsave(&ch->lock, irq_flags);
+		if (!(ch->flags & XPC_C_CONNECTCALLOUT)) {
+			ch->flags |= XPC_C_CONNECTCALLOUT;
+			spin_unlock_irqrestore(&ch->lock, irq_flags);
+
 			xpc_connected_callout(ch);
 
 			/*
@@ -732,14 +753,23 @@
 					!(ch->flags & XPC_C_DISCONNECTING)) {
 				xpc_activate_kthreads(ch, n_needed);
 			}
+		} else {
+			spin_unlock_irqrestore(&ch->lock, irq_flags);
 		}
 
 		xpc_kthread_waitmsgs(part, ch);
 	}
 
 	if (atomic_dec_return(&ch->kthreads_assigned) = 0) {
-		if (ch->flags & XPC_C_CONNECTCALLOUT) {
+		spin_lock_irqsave(&ch->lock, irq_flags);
+		if ((ch->flags & XPC_C_CONNECTCALLOUT) &&
+				!(ch->flags & XPC_C_DISCONNECTCALLOUT)) {
+			ch->flags |= XPC_C_DISCONNECTCALLOUT;
+			spin_unlock_irqrestore(&ch->lock, irq_flags);
+
 			xpc_disconnecting_callout(ch);
+		} else {
+			spin_unlock_irqrestore(&ch->lock, irq_flags);
 		}
 		if (atomic_dec_return(&part->nchannels_engaged) = 0) {
 			xpc_mark_partition_disengaged(part);
@@ -780,9 +810,29 @@
 
 
 	while (needed-- > 0) {
+
+		/*
+		 * The following is done on behalf of the newly created
+		 * kthread. That kthread is responsible for doing the
+		 * counterpart to the following before it exits.
+		 */
+		(void) xpc_part_ref(part);
+		xpc_msgqueue_ref(ch);
+		if (atomic_inc_return(&ch->kthreads_assigned) = 1 &&
+		    atomic_inc_return(&part->nchannels_engaged) = 1) {
+			xpc_mark_partition_engaged(part);
+		}
+
 		pid = kernel_thread(xpc_daemonize_kthread, (void *) args, 0);
 		if (pid < 0) {
 			/* the fork failed */
+			if (atomic_dec_return(&ch->kthreads_assigned) = 0 &&
+			    atomic_dec_return(&part->nchannels_engaged) = 0) {
+				xpc_mark_partition_disengaged(part);
+				xpc_IPI_send_disengage(part);
+			}
+			xpc_msgqueue_deref(ch);
+			xpc_part_deref(part);
 
 			if (atomic_read(&ch->kthreads_assigned) <
 						ch->kthreads_idle_limit) {
@@ -802,18 +852,6 @@
 			break;
 		}
 
-		/*
-		 * The following is done on behalf of the newly created
-		 * kthread. That kthread is responsible for doing the
-		 * counterpart to the following before it exits.
-		 */
-		(void) xpc_part_ref(part);
-		xpc_msgqueue_ref(ch);
-		if (atomic_inc_return(&ch->kthreads_assigned) = 1) {
-			if (atomic_inc_return(&part->nchannels_engaged) = 1) {
-				xpc_mark_partition_engaged(part);
-			}
-		}
 		ch->kthreads_created++;	// >>> temporary debug only!!!
 	}
 }
@@ -826,26 +864,49 @@
 	partid_t partid;
 	struct xpc_partition *part;
 	struct xpc_channel *ch;
+	int wakeup_channel_mgr;
 
 
 	/* now wait for all callouts to the caller's function to cease */
 	for (partid = 1; partid < XP_MAX_PARTITIONS; partid++) {
 		part = &xpc_partitions[partid];
 
-		if (xpc_part_ref(part)) {
-			ch = &part->channels[ch_number];
+		if (!xpc_part_ref(part)) {
+			continue;
+		}
 
-			if (ch->flags & XPC_C_WDISCONNECT) {
-				if (!(ch->flags & XPC_C_DISCONNECTED)) {
-					(void) down(&ch->wdisconnect_sema);
-				}
-				spin_lock_irqsave(&ch->lock, irq_flags);
-				ch->flags &= ~XPC_C_WDISCONNECT;
-				spin_unlock_irqrestore(&ch->lock, irq_flags);
-			}
+		ch = &part->channels[ch_number];
 
+		if (!(ch->flags & XPC_C_WDISCONNECT)) {
 			xpc_part_deref(part);
+			continue;
+		}
+
+		(void) down(&ch->wdisconnect_sema);
+
+		spin_lock_irqsave(&ch->lock, irq_flags);
+		DBUG_ON(!(ch->flags & XPC_C_DISCONNECTED));
+		wakeup_channel_mgr = 0;
+
+		if (ch->delayed_IPI_flags) {
+			if (part->act_state != XPC_P_DEACTIVATING) {
+				spin_lock(&part->IPI_lock);
+				XPC_SET_IPI_FLAGS(part->local_IPI_amo,
+					ch->number, ch->delayed_IPI_flags);
+				spin_unlock(&part->IPI_lock);
+				wakeup_channel_mgr = 1;
+			}
+			ch->delayed_IPI_flags = 0;
+		}
+
+		ch->flags &= ~XPC_C_WDISCONNECT;
+		spin_unlock_irqrestore(&ch->lock, irq_flags);
+
+		if (wakeup_channel_mgr) {
+			xpc_wakeup_channel_mgr(part);
 		}
+
+		xpc_part_deref(part);
 	}
 }
 
@@ -873,11 +934,11 @@
 	/* ignore all incoming interrupts */
 	free_irq(SGI_XPC_ACTIVATE, NULL);
 
-	/* wait for the discovery thread to mark itself inactive */
-	down(&xpc_discovery_inactive);
+	/* wait for the discovery thread to exit */
+	down(&xpc_discovery_exited);
 
-	/* wait for the heartbeat checker thread to mark itself inactive */
-	down(&xpc_hb_checker_inactive);
+	/* wait for the heartbeat checker thread to exit */
+	down(&xpc_hb_checker_exited);
 
 
 	/* sleep for a 1/3 of a second or so */
@@ -893,6 +954,7 @@
 
 		for (partid = 1; partid < XP_MAX_PARTITIONS; partid++) {
 			part = &xpc_partitions[partid];
+
 			if (xpc_partition_disengaged(part) &&
 					part->act_state = XPC_P_INACTIVE) {
 				continue;
@@ -930,7 +992,7 @@
 
 	/* now it's time to eliminate our heartbeat */
 	del_timer_sync(&xpc_hb_timer);
-	DBUG_ON(xpc_vars->heartbeating_to_mask = 0);
+	DBUG_ON(xpc_vars->heartbeating_to_mask != 0);
 
 	/* take ourselves off of the reboot_notifier_list */
 	(void) unregister_reboot_notifier(&xpc_reboot_notifier);
@@ -1138,7 +1200,7 @@
 		dev_err(xpc_part, "failed while forking discovery thread\n");
 
 		/* mark this new thread as a non-starter */
-		up(&xpc_discovery_inactive);
+		up(&xpc_discovery_exited);
 
 		xpc_do_exit(xpcUnloading);
 		return -EBUSY;
@@ -1176,3 +1238,7 @@
 MODULE_PARM_DESC(xpc_hb_check_interval, "Number of seconds between "
 		"heartbeat checks.");
 
+module_param(xpc_disengage_request_timelimit, int, 0);
+MODULE_PARM_DESC(xpc_disengage_request_timelimit, "Number of seconds to wait "
+		"for disengage request to complete.");
+
Index: linux-2.6.git#test/arch/ia64/sn/kernel/xpc_partition.c
=================================--- linux-2.6.git#test.orig/arch/ia64/sn/kernel/xpc_partition.c	2005-10-13 09:13:35.657781329 -0500
+++ linux-2.6.git#test/arch/ia64/sn/kernel/xpc_partition.c	2005-10-14 11:12:42.327800543 -0500
@@ -578,7 +578,7 @@
 
 
 /*
- * Prior code has determine the nasid which generated an IPI.  Inspect
+ * Prior code has determined the nasid which generated an IPI.  Inspect
  * that nasid to determine if its partition needs to be activated or
  * deactivated.
  *
@@ -942,14 +942,14 @@
 
 		/* set a timelimit on the disengage request */
 		part->disengage_request_timeout = jiffies +
-					(XPC_DISENGAGE_REQUEST_TIMELIMIT * HZ);
+					(xpc_disengage_request_timelimit * HZ);
 		part->disengage_request_timer.expires  					part->disengage_request_timeout;
 		add_timer(&part->disengage_request_timer);
 	}
 
-	dev_dbg(xpc_part, "bringing partition %d down, reason = %d\n", partid,
-		reason);
+	dev_dbg(xpc_part, "bringing partition %d down, reason = %d\n",
+		XPC_PARTID(part), reason);
 
 	xpc_partition_going_down(part, reason);
 }
Index: linux-2.6.git#test/arch/ia64/sn/kernel/xpc_channel.c
=================================--- linux-2.6.git#test.orig/arch/ia64/sn/kernel/xpc_channel.c	2005-10-13 09:13:35.655828401 -0500
+++ linux-2.6.git#test/arch/ia64/sn/kernel/xpc_channel.c	2005-10-17 07:29:45.288958360 -0500
@@ -792,11 +792,20 @@
 			"reason=%d\n", ch->number, ch->partid, ch->reason);
 	}
 
-	/* wake the thread that is waiting for this channel to disconnect */
 	if (ch->flags & XPC_C_WDISCONNECT) {
 		spin_unlock_irqrestore(&ch->lock, *irq_flags);
 		up(&ch->wdisconnect_sema);
 		spin_lock_irqsave(&ch->lock, *irq_flags);
+
+	} else if (ch->delayed_IPI_flags) {
+		if (part->act_state != XPC_P_DEACTIVATING) {
+			/* time to take action on any delayed IPI flags */
+			spin_lock(&part->IPI_lock);
+			XPC_SET_IPI_FLAGS(part->local_IPI_amo, ch->number,
+							ch->delayed_IPI_flags);
+			spin_unlock(&part->IPI_lock);
+		}
+		ch->delayed_IPI_flags = 0;
 	}
 }
 
@@ -818,6 +827,19 @@
 
 	spin_lock_irqsave(&ch->lock, irq_flags);
 
+again:
+
+	if ((ch->flags & XPC_C_DISCONNECTED) &&
+					(ch->flags & XPC_C_WDISCONNECT)) {
+		/*
+		 * Delay processing IPI flags until thread waiting disconnect
+		 * has had a chance to see that the channel is disconnected.
+		 */
+		ch->delayed_IPI_flags |= IPI_flags;
+		spin_unlock_irqrestore(&ch->lock, irq_flags);
+		return;
+	}
+
 
 	if (IPI_flags & XPC_IPI_CLOSEREQUEST) {
 
@@ -843,14 +865,22 @@
 
 			/* both sides have finished disconnecting */
 			xpc_process_disconnect(ch, &irq_flags);
+			DBUG_ON(!(ch->flags & XPC_C_DISCONNECTED));
+			goto again;
 		}
 
 		if (ch->flags & XPC_C_DISCONNECTED) {
-			// >>> explain this section
-
 			if (!(IPI_flags & XPC_IPI_OPENREQUEST)) {
-				DBUG_ON(part->act_state !-							XPC_P_DEACTIVATING);
+				if ((XPC_GET_IPI_FLAGS(part->local_IPI_amo,
+					 ch_number) & XPC_IPI_OPENREQUEST)) {
+
+					DBUG_ON(ch->delayed_IPI_flags != 0);
+					spin_lock(&part->IPI_lock);
+					XPC_SET_IPI_FLAGS(part->local_IPI_amo,
+							ch_number,
+							XPC_IPI_CLOSEREQUEST);
+					spin_unlock(&part->IPI_lock);
+				}
 				spin_unlock_irqrestore(&ch->lock, irq_flags);
 				return;
 			}
@@ -880,9 +910,13 @@
 			}
 
 			XPC_DISCONNECT_CHANNEL(ch, reason, &irq_flags);
-		} else {
-			xpc_process_disconnect(ch, &irq_flags);
+
+			DBUG_ON(IPI_flags & XPC_IPI_CLOSEREPLY);
+			spin_unlock_irqrestore(&ch->lock, irq_flags);
+			return;
 		}
+
+		xpc_process_disconnect(ch, &irq_flags);
 	}
 
 
@@ -898,7 +932,20 @@
 		}
 
 		DBUG_ON(!(ch->flags & XPC_C_CLOSEREQUEST));
-		DBUG_ON(!(ch->flags & XPC_C_RCLOSEREQUEST));
+
+		if (!(ch->flags & XPC_C_RCLOSEREQUEST)) {
+			if ((XPC_GET_IPI_FLAGS(part->local_IPI_amo, ch_number)
+						& XPC_IPI_CLOSEREQUEST)) {
+
+				DBUG_ON(ch->delayed_IPI_flags != 0);
+				spin_lock(&part->IPI_lock);
+				XPC_SET_IPI_FLAGS(part->local_IPI_amo,
+						ch_number, XPC_IPI_CLOSEREPLY);
+				spin_unlock(&part->IPI_lock);
+			}
+			spin_unlock_irqrestore(&ch->lock, irq_flags);
+			return;
+		}
 
 		ch->flags |= XPC_C_RCLOSEREPLY;
 
@@ -916,8 +963,14 @@
 			"channel=%d\n", args->msg_size, args->local_nentries,
 			ch->partid, ch->number);
 
-		if ((ch->flags & (XPC_C_DISCONNECTING | XPC_C_WDISCONNECT)) ||
-					part->act_state = XPC_P_DEACTIVATING) {
+		if (part->act_state = XPC_P_DEACTIVATING ||
+					(ch->flags & XPC_C_ROPENREQUEST)) {
+			spin_unlock_irqrestore(&ch->lock, irq_flags);
+			return;
+		}
+
+		if (ch->flags & (XPC_C_DISCONNECTING | XPC_C_WDISCONNECT)) {
+			ch->delayed_IPI_flags |= XPC_IPI_OPENREQUEST;
 			spin_unlock_irqrestore(&ch->lock, irq_flags);
 			return;
 		}
@@ -931,8 +984,11 @@
 		 *      msg_size = size of channel's messages in bytes
 		 *      local_nentries = remote partition's local_nentries
 		 */
-		DBUG_ON(args->msg_size = 0);
-		DBUG_ON(args->local_nentries = 0);
+		if (args->msg_size = 0 || args->local_nentries = 0) {
+			/* assume OPENREQUEST was delayed by mistake */
+			spin_unlock_irqrestore(&ch->lock, irq_flags);
+			return;
+		}
 
 		ch->flags |= (XPC_C_ROPENREQUEST | XPC_C_CONNECTING);
 		ch->remote_nentries = args->local_nentries;
@@ -970,7 +1026,13 @@
 			spin_unlock_irqrestore(&ch->lock, irq_flags);
 			return;
 		}
-		DBUG_ON(!(ch->flags & XPC_C_OPENREQUEST));
+		if (!(ch->flags & XPC_C_OPENREQUEST)) {
+			XPC_DISCONNECT_CHANNEL(ch, xpcOpenCloseError,
+								&irq_flags);
+			spin_unlock_irqrestore(&ch->lock, irq_flags);
+			return;
+		}
+
 		DBUG_ON(!(ch->flags & XPC_C_ROPENREQUEST));
 		DBUG_ON(ch->flags & XPC_C_CONNECTED);
 
@@ -1024,8 +1086,8 @@
 	struct xpc_registration *registration = &xpc_registrations[ch->number];
 
 
-	if (down_interruptible(&registration->sema) != 0) {
-		return xpcInterrupted;
+	if (down_trylock(&registration->sema) != 0) {
+		return xpcRetry;
 	}
 
 	if (!XPC_CHANNEL_REGISTERED(ch->number)) {
@@ -1445,19 +1507,11 @@
 		if (xpc_part_ref(part)) {
 			ch = &part->channels[ch_number];
 
-			if (!(ch->flags & XPC_C_DISCONNECTING)) {
-				DBUG_ON(ch->flags & XPC_C_OPENREQUEST);
-				DBUG_ON(ch->flags & XPC_C_CONNECTED);
-				DBUG_ON(ch->flags & XPC_C_SETUP);
-
-				/*
-				 * Initiate the establishment of a connection
-				 * on the newly registered channel to the
-				 * remote partition.
-				 */
-				xpc_wakeup_channel_mgr(part);
-			}
-
+			/*
+			 * Initiate the establishment of a connection on the
+			 * newly registered channel to the remote partition.
+			 */
+			xpc_wakeup_channel_mgr(part);
 			xpc_part_deref(part);
 		}
 	}
@@ -1467,9 +1521,6 @@
 void
 xpc_connected_callout(struct xpc_channel *ch)
 {
-	unsigned long irq_flags;
-
-
 	/* let the registerer know that a connection has been established */
 
 	if (ch->func != NULL) {
@@ -1482,10 +1533,6 @@
 		dev_dbg(xpc_chan, "ch->func() returned, reason=xpcConnected, "
 			"partid=%d, channel=%d\n", ch->partid, ch->number);
 	}
-
-	spin_lock_irqsave(&ch->lock, irq_flags);
-	ch->flags |= XPC_C_CONNECTCALLOUT;
-	spin_unlock_irqrestore(&ch->lock, irq_flags);
 }
 
 
