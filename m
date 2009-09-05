From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Sat, 05 Sep 2009 00:02:59 +0000
Subject: [PATCH] sgi-xp: fix printk format warnings
Message-Id: <20090904170259.02ed92ea.randy.dunlap@oracle.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>

Fix warnings in SGI XPC sn2 driver:  lots of printk format warnings

and:
drivers/misc/sgi-xp/xpc_sn2.c: In function 'xpc_get_partition_rsvd_page_pa_sn2':
drivers/misc/sgi-xp/xpc_sn2.c:618: warning: passing argument 3 of 'sn_partition_reserved_page_pa' from incompatible pointer type
drivers/misc/sgi-xp/xpc_sn2.c:618: warning: passing argument 4 of 'sn_partition_reserved_page_pa' from incompatible pointer type

(likely due to generic u64 / long long changes)

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 drivers/misc/sgi-xp/xpc_sn2.c |   40 ++++++++++++++++----------------
 1 file changed, 21 insertions(+), 19 deletions(-)

--- linux-2.6.31-rc8-git1.orig/drivers/misc/sgi-xp/xpc_sn2.c
+++ linux-2.6.31-rc8-git1/drivers/misc/sgi-xp/xpc_sn2.c
@@ -279,7 +279,7 @@ xpc_check_for_sent_chctl_flags_sn2(struc
 	spin_unlock_irqrestore(&part->chctl_lock, irq_flags);
 
 	dev_dbg(xpc_chan, "received notify IRQ from partid=%d, chctl.all_flags="
-		"0x%lx\n", XPC_PARTID(part), chctl.all_flags);
+		"0x%llx\n", XPC_PARTID(part), chctl.all_flags);
 
 	xpc_wakeup_channel_mgr(part);
 }
@@ -615,7 +615,8 @@ xpc_get_partition_rsvd_page_pa_sn2(void 
 	s64 status;
 	enum xp_retval ret;
 
-	status = sn_partition_reserved_page_pa((u64)buf, cookie, rp_pa, len);
+	status = sn_partition_reserved_page_pa((u64)buf, cookie,
+			(u64 *)rp_pa, (u64 *)len);
 	if (status = SALRET_OK)
 		ret = xpSuccess;
 	else if (status = SALRET_MORE_PASSES)
@@ -777,8 +778,8 @@ xpc_get_remote_heartbeat_sn2(struct xpc_
 	if (ret != xpSuccess)
 		return ret;
 
-	dev_dbg(xpc_part, "partid=%d, heartbeat=%ld, last_heartbeat=%ld, "
-		"heartbeat_offline=%ld, HB_mask[0]=0x%lx\n", XPC_PARTID(part),
+	dev_dbg(xpc_part, "partid=%d, heartbeat=%lld, last_heartbeat=%lld, "
+		"heartbeat_offline=%lld, HB_mask[0]=0x%lx\n", XPC_PARTID(part),
 		remote_vars->heartbeat, part->last_heartbeat,
 		remote_vars->heartbeat_offline,
 		remote_vars->heartbeating_to_mask[0]);
@@ -940,7 +941,7 @@ xpc_update_partition_info_sn2(struct xpc
 		part_sn2->remote_vars_pa);
 
 	part->last_heartbeat = remote_vars->heartbeat - 1;
-	dev_dbg(xpc_part, "  last_heartbeat = 0x%016lx\n",
+	dev_dbg(xpc_part, "  last_heartbeat = 0x%016llx\n",
 		part->last_heartbeat);
 
 	part_sn2->remote_vars_part_pa = remote_vars->vars_part_pa;
@@ -1029,7 +1030,8 @@ xpc_identify_activate_IRQ_req_sn2(int na
 	part->activate_IRQ_rcvd++;
 
 	dev_dbg(xpc_part, "partid for nasid %d is %d; IRQs = %d; HB = "
-		"%ld:0x%lx\n", (int)nasid, (int)partid, part->activate_IRQ_rcvd,
+		"%lld:0x%lx\n", (int)nasid, (int)partid,
+		part->activate_IRQ_rcvd,
 		remote_vars->heartbeat, remote_vars->heartbeating_to_mask[0]);
 
 	if (xpc_partition_disengaged(part) &&
@@ -1129,7 +1131,7 @@ xpc_identify_activate_IRQ_sender_sn2(voi
 		do {
 			n_IRQs_detected++;
 			nasid = (l * BITS_PER_LONG + b) * 2;
-			dev_dbg(xpc_part, "interrupt from nasid %ld\n", nasid);
+			dev_dbg(xpc_part, "interrupt from nasid %lld\n", nasid);
 			xpc_identify_activate_IRQ_req_sn2(nasid);
 
 			b = find_next_bit(&nasid_mask_long, BITS_PER_LONG,
@@ -1386,7 +1388,7 @@ xpc_pull_remote_vars_part_sn2(struct xpc
 
 		if (pulled_entry->magic != 0) {
 			dev_dbg(xpc_chan, "partition %d's XPC vars_part for "
-				"partition %d has bad magic value (=0x%lx)\n",
+				"partition %d has bad magic value (=0x%llx)\n",
 				partid, sn_partition_id, pulled_entry->magic);
 			return xpBadMagic;
 		}
@@ -1730,14 +1732,14 @@ xpc_notify_senders_sn2(struct xpc_channe
 
 		if (notify->func != NULL) {
 			dev_dbg(xpc_chan, "notify->func() called, notify=0x%p "
-				"msg_number=%ld partid=%d channel=%d\n",
+				"msg_number=%lld partid=%d channel=%d\n",
 				(void *)notify, get, ch->partid, ch->number);
 
 			notify->func(reason, ch->partid, ch->number,
 				     notify->key);
 
 			dev_dbg(xpc_chan, "notify->func() returned, notify=0x%p"
-				" msg_number=%ld partid=%d channel=%d\n",
+				" msg_number=%lld partid=%d channel=%d\n",
 				(void *)notify, get, ch->partid, ch->number);
 		}
 	}
@@ -1858,7 +1860,7 @@ xpc_process_msg_chctl_flags_sn2(struct x
 
 		ch_sn2->w_remote_GP.get = ch_sn2->remote_GP.get;
 
-		dev_dbg(xpc_chan, "w_remote_GP.get changed to %ld, partid=%d, "
+		dev_dbg(xpc_chan, "w_remote_GP.get changed to %lld, partid=%d, "
 			"channel=%d\n", ch_sn2->w_remote_GP.get, ch->partid,
 			ch->number);
 
@@ -1885,7 +1887,7 @@ xpc_process_msg_chctl_flags_sn2(struct x
 		smp_wmb(); /* ensure flags have been cleared before bte_copy */
 		ch_sn2->w_remote_GP.put = ch_sn2->remote_GP.put;
 
-		dev_dbg(xpc_chan, "w_remote_GP.put changed to %ld, partid=%d, "
+		dev_dbg(xpc_chan, "w_remote_GP.put changed to %lld, partid=%d, "
 			"channel=%d\n", ch_sn2->w_remote_GP.put, ch->partid,
 			ch->number);
 
@@ -1943,7 +1945,7 @@ xpc_pull_remote_msg_sn2(struct xpc_chann
 		if (ret != xpSuccess) {
 
 			dev_dbg(xpc_chan, "failed to pull %d msgs starting with"
-				" msg %ld from partition %d, channel=%d, "
+				" msg %lld from partition %d, channel=%d, "
 				"ret=%d\n", nmsgs, ch_sn2->next_msg_to_pull,
 				ch->partid, ch->number, ret);
 
@@ -1995,7 +1997,7 @@ xpc_get_deliverable_payload_sn2(struct x
 		if (cmpxchg(&ch_sn2->w_local_GP.get, get, get + 1) = get) {
 			/* we got the entry referenced by get */
 
-			dev_dbg(xpc_chan, "w_local_GP.get changed to %ld, "
+			dev_dbg(xpc_chan, "w_local_GP.get changed to %lld, "
 				"partid=%d, channel=%d\n", get + 1,
 				ch->partid, ch->number);
 
@@ -2062,7 +2064,7 @@ xpc_send_msgs_sn2(struct xpc_channel *ch
 
 		/* we just set the new value of local_GP->put */
 
-		dev_dbg(xpc_chan, "local_GP->put changed to %ld, partid=%d, "
+		dev_dbg(xpc_chan, "local_GP->put changed to %lld, partid=%d, "
 			"channel=%d\n", put, ch->partid, ch->number);
 
 		send_msgrequest = 1;
@@ -2147,8 +2149,8 @@ xpc_allocate_msg_sn2(struct xpc_channel 
 	DBUG_ON(msg->flags != 0);
 	msg->number = put;
 
-	dev_dbg(xpc_chan, "w_local_GP.put changed to %ld; msg=0x%p, "
-		"msg_number=%ld, partid=%d, channel=%d\n", put + 1,
+	dev_dbg(xpc_chan, "w_local_GP.put changed to %lld; msg=0x%p, "
+		"msg_number=%lld, partid=%d, channel=%d\n", put + 1,
 		(void *)msg, msg->number, ch->partid, ch->number);
 
 	*address_of_msg = msg;
@@ -2296,7 +2298,7 @@ xpc_acknowledge_msgs_sn2(struct xpc_chan
 
 		/* we just set the new value of local_GP->get */
 
-		dev_dbg(xpc_chan, "local_GP->get changed to %ld, partid=%d, "
+		dev_dbg(xpc_chan, "local_GP->get changed to %lld, partid=%d, "
 			"channel=%d\n", get, ch->partid, ch->number);
 
 		send_msgrequest = (msg_flags & XPC_M_SN2_INTERRUPT);
@@ -2323,7 +2325,7 @@ xpc_received_payload_sn2(struct xpc_chan
 	msg = container_of(payload, struct xpc_msg_sn2, payload);
 	msg_number = msg->number;
 
-	dev_dbg(xpc_chan, "msg=0x%p, msg_number=%ld, partid=%d, channel=%d\n",
+	dev_dbg(xpc_chan, "msg=0x%p, msg_number=%lld, partid=%d, channel=%d\n",
 		(void *)msg, msg_number, ch->partid, ch->number);
 
 	DBUG_ON((((u64)msg - (u64)ch->sn.sn2.remote_msgqueue) / ch->entry_size) !

---
~Randy
LPC 2009, Sept. 23-25, Portland, Oregon
http://linuxplumbersconf.org/2009/
