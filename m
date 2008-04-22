From: Dean Nelson <dcn@sgi.com>
Date: Tue, 22 Apr 2008 19:48:55 +0000
Subject: [Patch 3/4] run drivers/misc/sgi-xp through scripts/Lindent part2 -v4
Message-Id: <20080422194855.GC14628@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080422194459.GB13086@sgi.com>
In-Reply-To: <20080422194459.GB13086@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com
Cc: jes@sgi.com, gregkh@suse.de, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Ran patches through scripts/Lindent (part 2).

Signed-off-by: Dean Nelson <dcn@sgi.com>

---

 drivers/misc/sgi-xp/xpc_channel.c |  390 ++++++++++++----------------------
 drivers/misc/sgi-xp/xpc_main.c    |  329 ++++++++++++----------------
 drivers/misc/sgi-xp/xpnet.c       |  109 +++------
 3 files changed, 322 insertions(+), 506 deletions(-)

Index: linux-2.6/drivers/misc/sgi-xp/xpc_channel.c
=================================--- linux-2.6.orig/drivers/misc/sgi-xp/xpc_channel.c	2008-04-22 11:20:44.000000000 -0500
+++ linux-2.6/drivers/misc/sgi-xp/xpc_channel.c	2008-04-22 11:32:20.848407833 -0500
@@ -6,7 +6,6 @@
  * Copyright (c) 2004-2008 Silicon Graphics, Inc.  All Rights Reserved.
  */
 
-
 /*
  * Cross Partition Communication (XPC) channel support.
  *
@@ -15,7 +14,6 @@
  *
  */
 
-
 #include <linux/kernel.h>
 #include <linux/init.h>
 #include <linux/sched.h>
@@ -27,7 +25,6 @@
 #include <asm/sn/sn_sal.h>
 #include "xpc.h"
 
-
 /*
  * Guarantee that the kzalloc'd memory is cacheline aligned.
  */
@@ -39,7 +36,7 @@ xpc_kzalloc_cacheline_aligned(size_t siz
 	if (*base = NULL) {
 		return NULL;
 	}
-	if ((u64) *base = L1_CACHE_ALIGN((u64) *base)) {
+	if ((u64)*base = L1_CACHE_ALIGN((u64)*base)) {
 		return *base;
 	}
 	kfree(*base);
@@ -49,10 +46,9 @@ xpc_kzalloc_cacheline_aligned(size_t siz
 	if (*base = NULL) {
 		return NULL;
 	}
-	return (void *) L1_CACHE_ALIGN((u64) *base);
+	return (void *)L1_CACHE_ALIGN((u64)*base);
 }
 
-
 /*
  * Set up the initial values for the XPartition Communication channels.
  */
@@ -62,7 +58,6 @@ xpc_initialize_channels(struct xpc_parti
 	int ch_number;
 	struct xpc_channel *ch;
 
-
 	for (ch_number = 0; ch_number < part->nchannels; ch_number++) {
 		ch = &part->channels[ch_number];
 
@@ -72,7 +67,7 @@ xpc_initialize_channels(struct xpc_parti
 
 		ch->local_GP = &part->local_GPs[ch_number];
 		ch->local_openclose_args -					&part->local_openclose_args[ch_number];
+		    &part->local_openclose_args[ch_number];
 
 		atomic_set(&ch->kthreads_assigned, 0);
 		atomic_set(&ch->kthreads_idle, 0);
@@ -91,7 +86,6 @@ xpc_initialize_channels(struct xpc_parti
 	}
 }
 
-
 /*
  * Setup the infrastructure necessary to support XPartition Communication
  * between the specified remote partition and the local one.
@@ -103,7 +97,6 @@ xpc_setup_infrastructure(struct xpc_part
 	struct timer_list *timer;
 	partid_t partid = XPC_PARTID(part);
 
-
 	/*
 	 * Zero out MOST of the entry for this partition. Only the fields
 	 * starting with `nchannels' will be zeroed. The preceding fields must
@@ -111,14 +104,14 @@ xpc_setup_infrastructure(struct xpc_part
 	 * referenced during this memset() operation.
 	 */
 	memset(&part->nchannels, 0, sizeof(struct xpc_partition) -
-				offsetof(struct xpc_partition, nchannels));
+	       offsetof(struct xpc_partition, nchannels));
 
 	/*
 	 * Allocate all of the channel structures as a contiguous chunk of
 	 * memory.
 	 */
 	part->channels = kzalloc(sizeof(struct xpc_channel) * XPC_NCHANNELS,
-								GFP_KERNEL);
+				 GFP_KERNEL);
 	if (part->channels = NULL) {
 		dev_err(xpc_chan, "can't get memory for channels\n");
 		return xpcNoMemory;
@@ -126,11 +119,11 @@ xpc_setup_infrastructure(struct xpc_part
 
 	part->nchannels = XPC_NCHANNELS;
 
-
 	/* allocate all the required GET/PUT values */
 
 	part->local_GPs = xpc_kzalloc_cacheline_aligned(XPC_GP_SIZE,
-					GFP_KERNEL, &part->local_GPs_base);
+							GFP_KERNEL,
+							&part->local_GPs_base);
 	if (part->local_GPs = NULL) {
 		kfree(part->channels);
 		part->channels = NULL;
@@ -140,7 +133,9 @@ xpc_setup_infrastructure(struct xpc_part
 	}
 
 	part->remote_GPs = xpc_kzalloc_cacheline_aligned(XPC_GP_SIZE,
-					GFP_KERNEL, &part->remote_GPs_base);
+							 GFP_KERNEL,
+							 &part->
+							 remote_GPs_base);
 	if (part->remote_GPs = NULL) {
 		dev_err(xpc_chan, "can't get memory for remote get/put "
 			"values\n");
@@ -151,12 +146,11 @@ xpc_setup_infrastructure(struct xpc_part
 		return xpcNoMemory;
 	}
 
-
 	/* allocate all the required open and close args */
 
-	part->local_openclose_args = xpc_kzalloc_cacheline_aligned(
-					XPC_OPENCLOSE_ARGS_SIZE, GFP_KERNEL,
-					&part->local_openclose_args_base);
+	part->local_openclose_args +	    xpc_kzalloc_cacheline_aligned(XPC_OPENCLOSE_ARGS_SIZE, GFP_KERNEL,
+					  &part->local_openclose_args_base);
 	if (part->local_openclose_args = NULL) {
 		dev_err(xpc_chan, "can't get memory for local connect args\n");
 		kfree(part->remote_GPs_base);
@@ -168,9 +162,9 @@ xpc_setup_infrastructure(struct xpc_part
 		return xpcNoMemory;
 	}
 
-	part->remote_openclose_args = xpc_kzalloc_cacheline_aligned(
-					XPC_OPENCLOSE_ARGS_SIZE, GFP_KERNEL,
-					&part->remote_openclose_args_base);
+	part->remote_openclose_args +	    xpc_kzalloc_cacheline_aligned(XPC_OPENCLOSE_ARGS_SIZE, GFP_KERNEL,
+					  &part->remote_openclose_args_base);
 	if (part->remote_openclose_args = NULL) {
 		dev_err(xpc_chan, "can't get memory for remote connect args\n");
 		kfree(part->local_openclose_args_base);
@@ -184,13 +178,11 @@ xpc_setup_infrastructure(struct xpc_part
 		return xpcNoMemory;
 	}
 
-
 	xpc_initialize_channels(part, partid);
 
 	atomic_set(&part->nchannels_active, 0);
 	atomic_set(&part->nchannels_engaged, 0);
 
-
 	/* local_IPI_amo were set to 0 by an earlier memset() */
 
 	/* Initialize this partitions AMO_t structure */
@@ -203,7 +195,7 @@ xpc_setup_infrastructure(struct xpc_part
 
 	sprintf(part->IPI_owner, "xpc%02d", partid);
 	ret = request_irq(SGI_XPC_NOTIFY, xpc_notify_IRQ_handler, IRQF_SHARED,
-				part->IPI_owner, (void *) (u64) partid);
+			  part->IPI_owner, (void *)(u64)partid);
 	if (ret != 0) {
 		dev_err(xpc_chan, "can't register NOTIFY IRQ handler, "
 			"errno=%d\n", -ret);
@@ -223,8 +215,8 @@ xpc_setup_infrastructure(struct xpc_part
 	/* Setup a timer to check for dropped IPIs */
 	timer = &part->dropped_IPI_timer;
 	init_timer(timer);
-	timer->function = (void (*)(unsigned long)) xpc_dropped_IPI_check;
-	timer->data = (unsigned long) part;
+	timer->function = (void (*)(unsigned long))xpc_dropped_IPI_check;
+	timer->data = (unsigned long)part;
 	timer->expires = jiffies + XPC_P_DROPPED_IPI_WAIT;
 	add_timer(timer);
 
@@ -234,7 +226,6 @@ xpc_setup_infrastructure(struct xpc_part
 	 */
 	part->setup_state = XPC_P_SETUP;
 
-
 	/*
 	 * Setup the per partition specific variables required by the
 	 * remote partition to establish channel connections with us.
@@ -244,7 +235,7 @@ xpc_setup_infrastructure(struct xpc_part
 	 */
 	xpc_vars_part[partid].GPs_pa = __pa(part->local_GPs);
 	xpc_vars_part[partid].openclose_args_pa -					__pa(part->local_openclose_args);
+	    __pa(part->local_openclose_args);
 	xpc_vars_part[partid].IPI_amo_pa = __pa(part->local_IPI_amo_va);
 	cpuid = raw_smp_processor_id();	/* any CPU in this partition will do */
 	xpc_vars_part[partid].IPI_nasid = cpuid_to_nasid(cpuid);
@@ -255,7 +246,6 @@ xpc_setup_infrastructure(struct xpc_part
 	return xpcSuccess;
 }
 
-
 /*
  * Create a wrapper that hides the underlying mechanism for pulling a cacheline
  * (or multiple cachelines) from a remote partition.
@@ -266,21 +256,20 @@ xpc_setup_infrastructure(struct xpc_part
  */
 static enum xpc_retval
 xpc_pull_remote_cachelines(struct xpc_partition *part, void *dst,
-				const void *src, size_t cnt)
+			   const void *src, size_t cnt)
 {
 	bte_result_t bte_ret;
 
-
-	DBUG_ON((u64) src != L1_CACHE_ALIGN((u64) src));
-	DBUG_ON((u64) dst != L1_CACHE_ALIGN((u64) dst));
+	DBUG_ON((u64)src != L1_CACHE_ALIGN((u64)src));
+	DBUG_ON((u64)dst != L1_CACHE_ALIGN((u64)dst));
 	DBUG_ON(cnt != L1_CACHE_ALIGN(cnt));
 
 	if (part->act_state = XPC_P_DEACTIVATING) {
 		return part->reason;
 	}
 
-	bte_ret = xp_bte_copy((u64) src, (u64) dst, (u64) cnt,
-					(BTE_NORMAL | BTE_WACQUIRE), NULL);
+	bte_ret = xp_bte_copy((u64)src, (u64)dst, (u64)cnt,
+			      (BTE_NORMAL | BTE_WACQUIRE), NULL);
 	if (bte_ret = BTE_SUCCESS) {
 		return xpcSuccess;
 	}
@@ -291,7 +280,6 @@ xpc_pull_remote_cachelines(struct xpc_pa
 	return xpc_map_bte_errors(bte_ret);
 }
 
-
 /*
  * Pull the remote per partition specific variables from the specified
  * partition.
@@ -301,41 +289,40 @@ xpc_pull_remote_vars_part(struct xpc_par
 {
 	u8 buffer[L1_CACHE_BYTES * 2];
 	struct xpc_vars_part *pulled_entry_cacheline -			(struct xpc_vars_part *) L1_CACHE_ALIGN((u64) buffer);
+	    (struct xpc_vars_part *)L1_CACHE_ALIGN((u64)buffer);
 	struct xpc_vars_part *pulled_entry;
 	u64 remote_entry_cacheline_pa, remote_entry_pa;
 	partid_t partid = XPC_PARTID(part);
 	enum xpc_retval ret;
 
-
 	/* pull the cacheline that contains the variables we're interested in */
 
 	DBUG_ON(part->remote_vars_part_pa !-				L1_CACHE_ALIGN(part->remote_vars_part_pa));
+		L1_CACHE_ALIGN(part->remote_vars_part_pa));
 	DBUG_ON(sizeof(struct xpc_vars_part) != L1_CACHE_BYTES / 2);
 
 	remote_entry_pa = part->remote_vars_part_pa +
-			sn_partition_id * sizeof(struct xpc_vars_part);
+	    sn_partition_id * sizeof(struct xpc_vars_part);
 
 	remote_entry_cacheline_pa = (remote_entry_pa & ~(L1_CACHE_BYTES - 1));
 
-	pulled_entry = (struct xpc_vars_part *) ((u64) pulled_entry_cacheline +
-				(remote_entry_pa & (L1_CACHE_BYTES - 1)));
+	pulled_entry = (struct xpc_vars_part *)((u64)pulled_entry_cacheline +
+						(remote_entry_pa &
+						 (L1_CACHE_BYTES - 1)));
 
 	ret = xpc_pull_remote_cachelines(part, pulled_entry_cacheline,
-					(void *) remote_entry_cacheline_pa,
-					L1_CACHE_BYTES);
+					 (void *)remote_entry_cacheline_pa,
+					 L1_CACHE_BYTES);
 	if (ret != xpcSuccess) {
 		dev_dbg(xpc_chan, "failed to pull XPC vars_part from "
 			"partition %d, ret=%d\n", partid, ret);
 		return ret;
 	}
 
-
 	/* see if they've been set up yet */
 
 	if (pulled_entry->magic != XPC_VP_MAGIC1 &&
-				pulled_entry->magic != XPC_VP_MAGIC2) {
+	    pulled_entry->magic != XPC_VP_MAGIC2) {
 
 		if (pulled_entry->magic != 0) {
 			dev_dbg(xpc_chan, "partition %d's XPC vars_part for "
@@ -353,8 +340,8 @@ xpc_pull_remote_vars_part(struct xpc_par
 		/* validate the variables */
 
 		if (pulled_entry->GPs_pa = 0 ||
-				pulled_entry->openclose_args_pa = 0 ||
-					pulled_entry->IPI_amo_pa = 0) {
+		    pulled_entry->openclose_args_pa = 0 ||
+		    pulled_entry->IPI_amo_pa = 0) {
 
 			dev_err(xpc_chan, "partition %d's XPC vars_part for "
 				"partition %d are not valid\n", partid,
@@ -366,9 +353,9 @@ xpc_pull_remote_vars_part(struct xpc_par
 
 		part->remote_GPs_pa = pulled_entry->GPs_pa;
 		part->remote_openclose_args_pa -					pulled_entry->openclose_args_pa;
+		    pulled_entry->openclose_args_pa;
 		part->remote_IPI_amo_va -				      (AMO_t *) __va(pulled_entry->IPI_amo_pa);
+		    (AMO_t *)__va(pulled_entry->IPI_amo_pa);
 		part->remote_IPI_nasid = pulled_entry->IPI_nasid;
 		part->remote_IPI_phys_cpuid = pulled_entry->IPI_phys_cpuid;
 
@@ -388,7 +375,6 @@ xpc_pull_remote_vars_part(struct xpc_par
 	return xpcSuccess;
 }
 
-
 /*
  * Get the IPI flags and pull the openclose args and/or remote GPs as needed.
  */
@@ -399,7 +385,6 @@ xpc_get_IPI_flags(struct xpc_partition *
 	u64 IPI_amo;
 	enum xpc_retval ret;
 
-
 	/*
 	 * See if there are any IPI flags to be handled.
 	 */
@@ -410,12 +395,12 @@ xpc_get_IPI_flags(struct xpc_partition *
 	}
 	spin_unlock_irqrestore(&part->IPI_lock, irq_flags);
 
-
 	if (XPC_ANY_OPENCLOSE_IPI_FLAGS_SET(IPI_amo)) {
 		ret = xpc_pull_remote_cachelines(part,
-					part->remote_openclose_args,
-					(void *) part->remote_openclose_args_pa,
-					XPC_OPENCLOSE_ARGS_SIZE);
+						 part->remote_openclose_args,
+						 (void *)part->
+						 remote_openclose_args_pa,
+						 XPC_OPENCLOSE_ARGS_SIZE);
 		if (ret != xpcSuccess) {
 			XPC_DEACTIVATE_PARTITION(part, ret);
 
@@ -430,8 +415,8 @@ xpc_get_IPI_flags(struct xpc_partition *
 
 	if (XPC_ANY_MSG_IPI_FLAGS_SET(IPI_amo)) {
 		ret = xpc_pull_remote_cachelines(part, part->remote_GPs,
-						(void *) part->remote_GPs_pa,
-						XPC_GP_SIZE);
+						 (void *)part->remote_GPs_pa,
+						 XPC_GP_SIZE);
 		if (ret != xpcSuccess) {
 			XPC_DEACTIVATE_PARTITION(part, ret);
 
@@ -446,7 +431,6 @@ xpc_get_IPI_flags(struct xpc_partition *
 	return IPI_amo;
 }
 
-
 /*
  * Allocate the local message queue and the notify queue.
  */
@@ -457,7 +441,6 @@ xpc_allocate_local_msgqueue(struct xpc_c
 	int nentries;
 	size_t nbytes;
 
-
 	// >>> may want to check for ch->flags & XPC_C_DISCONNECTING between
 	// >>> iterations of the for-loop, bail if set?
 
@@ -466,8 +449,9 @@ xpc_allocate_local_msgqueue(struct xpc_c
 
 		nbytes = nentries * ch->msg_size;
 		ch->local_msgqueue = xpc_kzalloc_cacheline_aligned(nbytes,
-						GFP_KERNEL,
-						&ch->local_msgqueue_base);
+								   GFP_KERNEL,
+								   &ch->
+								   local_msgqueue_base);
 		if (ch->local_msgqueue = NULL) {
 			continue;
 		}
@@ -497,7 +481,6 @@ xpc_allocate_local_msgqueue(struct xpc_c
 	return xpcNoMemory;
 }
 
-
 /*
  * Allocate the cached remote message queue.
  */
@@ -508,7 +491,6 @@ xpc_allocate_remote_msgqueue(struct xpc_
 	int nentries;
 	size_t nbytes;
 
-
 	DBUG_ON(ch->remote_nentries <= 0);
 
 	// >>> may want to check for ch->flags & XPC_C_DISCONNECTING between
@@ -519,8 +501,9 @@ xpc_allocate_remote_msgqueue(struct xpc_
 
 		nbytes = nentries * ch->msg_size;
 		ch->remote_msgqueue = xpc_kzalloc_cacheline_aligned(nbytes,
-						GFP_KERNEL,
-						&ch->remote_msgqueue_base);
+								    GFP_KERNEL,
+								    &ch->
+								    remote_msgqueue_base);
 		if (ch->remote_msgqueue = NULL) {
 			continue;
 		}
@@ -542,7 +525,6 @@ xpc_allocate_remote_msgqueue(struct xpc_
 	return xpcNoMemory;
 }
 
-
 /*
  * Allocate message queues and other stuff associated with a channel.
  *
@@ -554,7 +536,6 @@ xpc_allocate_msgqueues(struct xpc_channe
 	unsigned long irq_flags;
 	enum xpc_retval ret;
 
-
 	DBUG_ON(ch->flags & XPC_C_SETUP);
 
 	if ((ret = xpc_allocate_local_msgqueue(ch)) != xpcSuccess) {
@@ -576,7 +557,6 @@ xpc_allocate_msgqueues(struct xpc_channe
 	return xpcSuccess;
 }
 
-
 /*
  * Process a connect message from a remote partition.
  *
@@ -588,11 +568,10 @@ xpc_process_connect(struct xpc_channel *
 {
 	enum xpc_retval ret;
 
-
 	DBUG_ON(!spin_is_locked(&ch->lock));
 
 	if (!(ch->flags & XPC_C_OPENREQUEST) ||
-				!(ch->flags & XPC_C_ROPENREQUEST)) {
+	    !(ch->flags & XPC_C_ROPENREQUEST)) {
 		/* nothing more to do for now */
 		return;
 	}
@@ -629,14 +608,13 @@ xpc_process_connect(struct xpc_channel *
 	ch->flags = (XPC_C_CONNECTED | XPC_C_SETUP);	/* clear all else */
 
 	dev_info(xpc_chan, "channel %d to partition %d connected\n",
-		ch->number, ch->partid);
+		 ch->number, ch->partid);
 
 	spin_unlock_irqrestore(&ch->lock, *irq_flags);
 	xpc_create_kthreads(ch, 1, 0);
 	spin_lock_irqsave(&ch->lock, *irq_flags);
 }
 
-
 /*
  * Notify those who wanted to be notified upon delivery of their message.
  */
@@ -647,7 +625,6 @@ xpc_notify_senders(struct xpc_channel *c
 	u8 notify_type;
 	s64 get = ch->w_remote_GP.get - 1;
 
-
 	while (++get < put && atomic_read(&ch->n_to_notify) > 0) {
 
 		notify = &ch->notify_queue[get % ch->local_nentries];
@@ -660,8 +637,7 @@ xpc_notify_senders(struct xpc_channel *c
 		 */
 		notify_type = notify->type;
 		if (notify_type = 0 ||
-				cmpxchg(&notify->type, notify_type, 0) !-								notify_type) {
+		    cmpxchg(&notify->type, notify_type, 0) != notify_type) {
 			continue;
 		}
 
@@ -672,20 +648,19 @@ xpc_notify_senders(struct xpc_channel *c
 		if (notify->func != NULL) {
 			dev_dbg(xpc_chan, "notify->func() called, notify=0x%p, "
 				"msg_number=%ld, partid=%d, channel=%d\n",
-				(void *) notify, get, ch->partid, ch->number);
+				(void *)notify, get, ch->partid, ch->number);
 
 			notify->func(reason, ch->partid, ch->number,
-								notify->key);
+				     notify->key);
 
 			dev_dbg(xpc_chan, "notify->func() returned, "
 				"notify=0x%p, msg_number=%ld, partid=%d, "
-				"channel=%d\n", (void *) notify, get,
+				"channel=%d\n", (void *)notify, get,
 				ch->partid, ch->number);
 		}
 	}
 }
 
-
 /*
  * Free up message queues and other stuff that were allocated for the specified
  * channel.
@@ -733,7 +708,6 @@ xpc_free_msgqueues(struct xpc_channel *c
 	}
 }
 
-
 /*
  * spin_lock_irqsave() is expected to be held on entry.
  */
@@ -743,7 +717,6 @@ xpc_process_disconnect(struct xpc_channe
 	struct xpc_partition *part = &xpc_partitions[ch->partid];
 	u32 channel_was_connected = (ch->flags & XPC_C_WASCONNECTED);
 
-
 	DBUG_ON(!spin_is_locked(&ch->lock));
 
 	if (!(ch->flags & XPC_C_DISCONNECTING)) {
@@ -755,11 +728,11 @@ xpc_process_disconnect(struct xpc_channe
 	/* make sure all activity has settled down first */
 
 	if (atomic_read(&ch->kthreads_assigned) > 0 ||
-				atomic_read(&ch->references) > 0) {
+	    atomic_read(&ch->references) > 0) {
 		return;
 	}
 	DBUG_ON((ch->flags & XPC_C_CONNECTEDCALLOUT_MADE) &&
-			!(ch->flags & XPC_C_DISCONNECTINGCALLOUT_MADE));
+		!(ch->flags & XPC_C_DISCONNECTINGCALLOUT_MADE));
 
 	if (part->act_state = XPC_P_DEACTIVATING) {
 		/* can't proceed until the other side disengages from us */
@@ -809,7 +782,7 @@ xpc_process_disconnect(struct xpc_channe
 
 	if (channel_was_connected) {
 		dev_info(xpc_chan, "channel %d to partition %d disconnected, "
-			"reason=%d\n", ch->number, ch->partid, ch->reason);
+			 "reason=%d\n", ch->number, ch->partid, ch->reason);
 	}
 
 	if (ch->flags & XPC_C_WDISCONNECT) {
@@ -820,35 +793,31 @@ xpc_process_disconnect(struct xpc_channe
 			/* time to take action on any delayed IPI flags */
 			spin_lock(&part->IPI_lock);
 			XPC_SET_IPI_FLAGS(part->local_IPI_amo, ch->number,
-							ch->delayed_IPI_flags);
+					  ch->delayed_IPI_flags);
 			spin_unlock(&part->IPI_lock);
 		}
 		ch->delayed_IPI_flags = 0;
 	}
 }
 
-
 /*
  * Process a change in the channel's remote connection state.
  */
 static void
 xpc_process_openclose_IPI(struct xpc_partition *part, int ch_number,
-				u8 IPI_flags)
+			  u8 IPI_flags)
 {
 	unsigned long irq_flags;
 	struct xpc_openclose_args *args -				&part->remote_openclose_args[ch_number];
+	    &part->remote_openclose_args[ch_number];
 	struct xpc_channel *ch = &part->channels[ch_number];
 	enum xpc_retval reason;
 
-
-
 	spin_lock_irqsave(&ch->lock, irq_flags);
 
-again:
+      again:
 
-	if ((ch->flags & XPC_C_DISCONNECTED) &&
-					(ch->flags & XPC_C_WDISCONNECT)) {
+	if ((ch->flags & XPC_C_DISCONNECTED) && (ch->flags & XPC_C_WDISCONNECT)) {
 		/*
 		 * Delay processing IPI flags until thread waiting disconnect
 		 * has had a chance to see that the channel is disconnected.
@@ -858,7 +827,6 @@ again:
 		return;
 	}
 
-
 	if (IPI_flags & XPC_IPI_CLOSEREQUEST) {
 
 		dev_dbg(xpc_chan, "XPC_IPI_CLOSEREQUEST (reason=%d) received "
@@ -890,13 +858,14 @@ again:
 		if (ch->flags & XPC_C_DISCONNECTED) {
 			if (!(IPI_flags & XPC_IPI_OPENREQUEST)) {
 				if ((XPC_GET_IPI_FLAGS(part->local_IPI_amo,
-					 ch_number) & XPC_IPI_OPENREQUEST)) {
+						       ch_number) &
+				     XPC_IPI_OPENREQUEST)) {
 
 					DBUG_ON(ch->delayed_IPI_flags != 0);
 					spin_lock(&part->IPI_lock);
 					XPC_SET_IPI_FLAGS(part->local_IPI_amo,
-							ch_number,
-							XPC_IPI_CLOSEREQUEST);
+							  ch_number,
+							  XPC_IPI_CLOSEREQUEST);
 					spin_unlock(&part->IPI_lock);
 				}
 				spin_unlock_irqrestore(&ch->lock, irq_flags);
@@ -937,7 +906,6 @@ again:
 		xpc_process_disconnect(ch, &irq_flags);
 	}
 
-
 	if (IPI_flags & XPC_IPI_CLOSEREPLY) {
 
 		dev_dbg(xpc_chan, "XPC_IPI_CLOSEREPLY received from partid=%d,"
@@ -953,12 +921,13 @@ again:
 
 		if (!(ch->flags & XPC_C_RCLOSEREQUEST)) {
 			if ((XPC_GET_IPI_FLAGS(part->local_IPI_amo, ch_number)
-						& XPC_IPI_CLOSEREQUEST)) {
+			     & XPC_IPI_CLOSEREQUEST)) {
 
 				DBUG_ON(ch->delayed_IPI_flags != 0);
 				spin_lock(&part->IPI_lock);
 				XPC_SET_IPI_FLAGS(part->local_IPI_amo,
-						ch_number, XPC_IPI_CLOSEREPLY);
+						  ch_number,
+						  XPC_IPI_CLOSEREPLY);
 				spin_unlock(&part->IPI_lock);
 			}
 			spin_unlock_irqrestore(&ch->lock, irq_flags);
@@ -973,7 +942,6 @@ again:
 		}
 	}
 
-
 	if (IPI_flags & XPC_IPI_OPENREQUEST) {
 
 		dev_dbg(xpc_chan, "XPC_IPI_OPENREQUEST (msg_size=%d, "
@@ -982,7 +950,7 @@ again:
 			ch->partid, ch->number);
 
 		if (part->act_state = XPC_P_DEACTIVATING ||
-					(ch->flags & XPC_C_ROPENREQUEST)) {
+		    (ch->flags & XPC_C_ROPENREQUEST)) {
 			spin_unlock_irqrestore(&ch->lock, irq_flags);
 			return;
 		}
@@ -993,9 +961,9 @@ again:
 			return;
 		}
 		DBUG_ON(!(ch->flags & (XPC_C_DISCONNECTED |
-							XPC_C_OPENREQUEST)));
+				       XPC_C_OPENREQUEST)));
 		DBUG_ON(ch->flags & (XPC_C_ROPENREQUEST | XPC_C_ROPENREPLY |
-					XPC_C_OPENREPLY | XPC_C_CONNECTED));
+				     XPC_C_OPENREPLY | XPC_C_CONNECTED));
 
 		/*
 		 * The meaningful OPENREQUEST connection state fields are:
@@ -1011,11 +979,10 @@ again:
 		ch->flags |= (XPC_C_ROPENREQUEST | XPC_C_CONNECTING);
 		ch->remote_nentries = args->local_nentries;
 
-
 		if (ch->flags & XPC_C_OPENREQUEST) {
 			if (args->msg_size != ch->msg_size) {
 				XPC_DISCONNECT_CHANNEL(ch, xpcUnequalMsgSizes,
-								&irq_flags);
+						       &irq_flags);
 				spin_unlock_irqrestore(&ch->lock, irq_flags);
 				return;
 			}
@@ -1031,7 +998,6 @@ again:
 		xpc_process_connect(ch, &irq_flags);
 	}
 
-
 	if (IPI_flags & XPC_IPI_OPENREPLY) {
 
 		dev_dbg(xpc_chan, "XPC_IPI_OPENREPLY (local_msgqueue_pa=0x%lx, "
@@ -1046,7 +1012,7 @@ again:
 		}
 		if (!(ch->flags & XPC_C_OPENREQUEST)) {
 			XPC_DISCONNECT_CHANNEL(ch, xpcOpenCloseError,
-								&irq_flags);
+					       &irq_flags);
 			spin_unlock_irqrestore(&ch->lock, irq_flags);
 			return;
 		}
@@ -1057,7 +1023,7 @@ again:
 		/*
 		 * The meaningful OPENREPLY connection state fields are:
 		 *      local_msgqueue_pa = physical address of remote
-		 *			    partition's local_msgqueue
+		 *                          partition's local_msgqueue
 		 *      local_nentries = remote partition's local_nentries
 		 *      remote_nentries = remote partition's remote_nentries
 		 */
@@ -1093,7 +1059,6 @@ again:
 	spin_unlock_irqrestore(&ch->lock, irq_flags);
 }
 
-
 /*
  * Attempt to establish a channel connection to a remote partition.
  */
@@ -1103,7 +1068,6 @@ xpc_connect_channel(struct xpc_channel *
 	unsigned long irq_flags;
 	struct xpc_registration *registration = &xpc_registrations[ch->number];
 
-
 	if (mutex_trylock(&registration->mutex) = 0) {
 		return xpcRetry;
 	}
@@ -1124,7 +1088,6 @@ xpc_connect_channel(struct xpc_channel *
 		return ch->reason;
 	}
 
-
 	/* add info from the channel connect registration to the channel */
 
 	ch->kthreads_assigned_limit = registration->assigned_limit;
@@ -1154,7 +1117,7 @@ xpc_connect_channel(struct xpc_channel *
 			 */
 			mutex_unlock(&registration->mutex);
 			XPC_DISCONNECT_CHANNEL(ch, xpcUnequalMsgSizes,
-								&irq_flags);
+					       &irq_flags);
 			spin_unlock_irqrestore(&ch->lock, irq_flags);
 			return xpcUnequalMsgSizes;
 		}
@@ -1169,7 +1132,6 @@ xpc_connect_channel(struct xpc_channel *
 
 	mutex_unlock(&registration->mutex);
 
-
 	/* initiate the connection */
 
 	ch->flags |= (XPC_C_OPENREQUEST | XPC_C_CONNECTING);
@@ -1182,7 +1144,6 @@ xpc_connect_channel(struct xpc_channel *
 	return xpcSuccess;
 }
 
-
 /*
  * Clear some of the msg flags in the local message queue.
  */
@@ -1192,16 +1153,15 @@ xpc_clear_local_msgqueue_flags(struct xp
 	struct xpc_msg *msg;
 	s64 get;
 
-
 	get = ch->w_remote_GP.get;
 	do {
-		msg = (struct xpc_msg *) ((u64) ch->local_msgqueue +
-				(get % ch->local_nentries) * ch->msg_size);
+		msg = (struct xpc_msg *)((u64)ch->local_msgqueue +
+					 (get % ch->local_nentries) *
+					 ch->msg_size);
 		msg->flags = 0;
-	} while (++get < (volatile s64) ch->remote_GP.get);
+	} while (++get < (volatile s64)ch->remote_GP.get);
 }
 
-
 /*
  * Clear some of the msg flags in the remote message queue.
  */
@@ -1211,43 +1171,39 @@ xpc_clear_remote_msgqueue_flags(struct x
 	struct xpc_msg *msg;
 	s64 put;
 
-
 	put = ch->w_remote_GP.put;
 	do {
-		msg = (struct xpc_msg *) ((u64) ch->remote_msgqueue +
-				(put % ch->remote_nentries) * ch->msg_size);
+		msg = (struct xpc_msg *)((u64)ch->remote_msgqueue +
+					 (put % ch->remote_nentries) *
+					 ch->msg_size);
 		msg->flags = 0;
-	} while (++put < (volatile s64) ch->remote_GP.put);
+	} while (++put < (volatile s64)ch->remote_GP.put);
 }
 
-
 static void
 xpc_process_msg_IPI(struct xpc_partition *part, int ch_number)
 {
 	struct xpc_channel *ch = &part->channels[ch_number];
 	int nmsgs_sent;
 
-
 	ch->remote_GP = part->remote_GPs[ch_number];
 
-
 	/* See what, if anything, has changed for each connected channel */
 
 	xpc_msgqueue_ref(ch);
 
 	if (ch->w_remote_GP.get = ch->remote_GP.get &&
-				ch->w_remote_GP.put = ch->remote_GP.put) {
+	    ch->w_remote_GP.put = ch->remote_GP.put) {
 		/* nothing changed since GPs were last pulled */
 		xpc_msgqueue_deref(ch);
 		return;
 	}
 
-	if (!(ch->flags & XPC_C_CONNECTED)){
+	if (!(ch->flags & XPC_C_CONNECTED)) {
 		xpc_msgqueue_deref(ch);
 		return;
 	}
 
-
 	/*
 	 * First check to see if messages recently sent by us have been
 	 * received by the other side. (The remote GET value will have
@@ -1269,7 +1225,7 @@ xpc_process_msg_IPI(struct xpc_partition
 			 * received and delivered by the other side.
 			 */
 			xpc_notify_senders(ch, xpcMsgDelivered,
-							ch->remote_GP.get);
+					   ch->remote_GP.get);
 		}
 
 		/*
@@ -1293,7 +1249,6 @@ xpc_process_msg_IPI(struct xpc_partition
 		}
 	}
 
-
 	/*
 	 * Now check for newly sent messages by the other side. (The remote
 	 * PUT value will have changed since we last looked at it.)
@@ -1327,7 +1282,6 @@ xpc_process_msg_IPI(struct xpc_partition
 	xpc_msgqueue_deref(ch);
 }
 
-
 void
 xpc_process_channel_activity(struct xpc_partition *part)
 {
@@ -1337,7 +1291,6 @@ xpc_process_channel_activity(struct xpc_
 	int ch_number;
 	u32 ch_flags;
 
-
 	IPI_amo = xpc_get_IPI_flags(part);
 
 	/*
@@ -1350,7 +1303,6 @@ xpc_process_channel_activity(struct xpc_
 	for (ch_number = 0; ch_number < part->nchannels; ch_number++) {
 		ch = &part->channels[ch_number];
 
-
 		/*
 		 * Process any open or close related IPI flags, and then deal
 		 * with connecting or disconnecting the channel as required.
@@ -1378,7 +1330,7 @@ xpc_process_channel_activity(struct xpc_
 		if (!(ch_flags & XPC_C_CONNECTED)) {
 			if (!(ch_flags & XPC_C_OPENREQUEST)) {
 				DBUG_ON(ch_flags & XPC_C_SETUP);
-				(void) xpc_connect_channel(ch);
+				(void)xpc_connect_channel(ch);
 			} else {
 				spin_lock_irqsave(&ch->lock, irq_flags);
 				xpc_process_connect(ch, &irq_flags);
@@ -1387,7 +1339,6 @@ xpc_process_channel_activity(struct xpc_
 			continue;
 		}
 
-
 		/*
 		 * Process any message related IPI flags, this may involve the
 		 * activation of kthreads to deliver any pending messages sent
@@ -1400,7 +1351,6 @@ xpc_process_channel_activity(struct xpc_
 	}
 }
 
-
 /*
  * XPC's heartbeat code calls this function to inform XPC that a partition is
  * going down.  XPC responds by tearing down the XPartition Communication
@@ -1417,7 +1367,6 @@ xpc_partition_going_down(struct xpc_part
 	int ch_number;
 	struct xpc_channel *ch;
 
-
 	dev_dbg(xpc_chan, "deactivating partition %d, reason=%d\n",
 		XPC_PARTID(part), reason);
 
@@ -1426,7 +1375,6 @@ xpc_partition_going_down(struct xpc_part
 		return;
 	}
 
-
 	/* disconnect channels associated with the partition going down */
 
 	for (ch_number = 0; ch_number < part->nchannels; ch_number++) {
@@ -1446,7 +1394,6 @@ xpc_partition_going_down(struct xpc_part
 	xpc_part_deref(part);
 }
 
-
 /*
  * Teardown the infrastructure necessary to support XPartition Communication
  * between the specified remote partition and the local one.
@@ -1456,7 +1403,6 @@ xpc_teardown_infrastructure(struct xpc_p
 {
 	partid_t partid = XPC_PARTID(part);
 
-
 	/*
 	 * We start off by making this partition inaccessible to local
 	 * processes by marking it as no longer setup. Then we make it
@@ -1473,9 +1419,7 @@ xpc_teardown_infrastructure(struct xpc_p
 
 	xpc_vars_part[partid].magic = 0;
 
-
-	free_irq(SGI_XPC_NOTIFY, (void *) (u64) partid);
-
+	free_irq(SGI_XPC_NOTIFY, (void *)(u64)partid);
 
 	/*
 	 * Before proceeding with the teardown we have to wait until all
@@ -1483,7 +1427,6 @@ xpc_teardown_infrastructure(struct xpc_p
 	 */
 	wait_event(part->teardown_wq, (atomic_read(&part->references) = 0));
 
-
 	/* now we can begin tearing down the infrastructure */
 
 	part->setup_state = XPC_P_TORNDOWN;
@@ -1504,7 +1447,6 @@ xpc_teardown_infrastructure(struct xpc_p
 	part->local_IPI_amo_va = NULL;
 }
 
-
 /*
  * Called by XP at the time of channel connection registration to cause
  * XPC to establish connections to all currently active partitions.
@@ -1516,7 +1458,6 @@ xpc_initiate_connect(int ch_number)
 	struct xpc_partition *part;
 	struct xpc_channel *ch;
 
-
 	DBUG_ON(ch_number < 0 || ch_number >= XPC_NCHANNELS);
 
 	for (partid = 1; partid < XP_MAX_PARTITIONS; partid++) {
@@ -1535,7 +1476,6 @@ xpc_initiate_connect(int ch_number)
 	}
 }
 
-
 void
 xpc_connected_callout(struct xpc_channel *ch)
 {
@@ -1546,14 +1486,13 @@ xpc_connected_callout(struct xpc_channel
 			"partid=%d, channel=%d\n", ch->partid, ch->number);
 
 		ch->func(xpcConnected, ch->partid, ch->number,
-				(void *) (u64) ch->local_nentries, ch->key);
+			 (void *)(u64)ch->local_nentries, ch->key);
 
 		dev_dbg(xpc_chan, "ch->func() returned, reason=xpcConnected, "
 			"partid=%d, channel=%d\n", ch->partid, ch->number);
 	}
 }
 
-
 /*
  * Called by XP at the time of channel connection unregistration to cause
  * XPC to teardown all current connections for the specified channel.
@@ -1575,7 +1514,6 @@ xpc_initiate_disconnect(int ch_number)
 	struct xpc_partition *part;
 	struct xpc_channel *ch;
 
-
 	DBUG_ON(ch_number < 0 || ch_number >= XPC_NCHANNELS);
 
 	/* initiate the channel disconnect for every active partition */
@@ -1592,7 +1530,7 @@ xpc_initiate_disconnect(int ch_number)
 				ch->flags |= XPC_C_WDISCONNECT;
 
 				XPC_DISCONNECT_CHANNEL(ch, xpcUnregistering,
-								&irq_flags);
+						       &irq_flags);
 			}
 
 			spin_unlock_irqrestore(&ch->lock, irq_flags);
@@ -1605,7 +1543,6 @@ xpc_initiate_disconnect(int ch_number)
 	xpc_disconnect_wait(ch_number);
 }
 
-
 /*
  * To disconnect a channel, and reflect it back to all who may be waiting.
  *
@@ -1617,11 +1554,10 @@ xpc_initiate_disconnect(int ch_number)
  */
 void
 xpc_disconnect_channel(const int line, struct xpc_channel *ch,
-			enum xpc_retval reason, unsigned long *irq_flags)
+		       enum xpc_retval reason, unsigned long *irq_flags)
 {
 	u32 channel_was_connected = (ch->flags & XPC_C_CONNECTED);
 
-
 	DBUG_ON(!spin_is_locked(&ch->lock));
 
 	if (ch->flags & (XPC_C_DISCONNECTING | XPC_C_DISCONNECTED)) {
@@ -1637,8 +1573,8 @@ xpc_disconnect_channel(const int line, s
 	ch->flags |= (XPC_C_CLOSEREQUEST | XPC_C_DISCONNECTING);
 	/* some of these may not have been set */
 	ch->flags &= ~(XPC_C_OPENREQUEST | XPC_C_OPENREPLY |
-			XPC_C_ROPENREQUEST | XPC_C_ROPENREPLY |
-			XPC_C_CONNECTING | XPC_C_CONNECTED);
+		       XPC_C_ROPENREQUEST | XPC_C_ROPENREPLY |
+		       XPC_C_CONNECTING | XPC_C_CONNECTED);
 
 	xpc_IPI_send_closerequest(ch, irq_flags);
 
@@ -1653,7 +1589,7 @@ xpc_disconnect_channel(const int line, s
 		wake_up_all(&ch->idle_wq);
 
 	} else if ((ch->flags & XPC_C_CONNECTEDCALLOUT_MADE) &&
-			!(ch->flags & XPC_C_DISCONNECTINGCALLOUT)) {
+		   !(ch->flags & XPC_C_DISCONNECTINGCALLOUT)) {
 		/* start a kthread that will do the xpcDisconnecting callout */
 		xpc_create_kthreads(ch, 1, 1);
 	}
@@ -1666,7 +1602,6 @@ xpc_disconnect_channel(const int line, s
 	spin_lock_irqsave(&ch->lock, *irq_flags);
 }
 
-
 void
 xpc_disconnect_callout(struct xpc_channel *ch, enum xpc_retval reason)
 {
@@ -1687,7 +1622,6 @@ xpc_disconnect_callout(struct xpc_channe
 	}
 }
 
-
 /*
  * Wait for a message entry to become available for the specified channel,
  * but don't wait any longer than 1 jiffy.
@@ -1697,9 +1631,8 @@ xpc_allocate_msg_wait(struct xpc_channel
 {
 	enum xpc_retval ret;
 
-
 	if (ch->flags & XPC_C_DISCONNECTING) {
-		DBUG_ON(ch->reason = xpcInterrupted);  // >>> Is this true?
+		DBUG_ON(ch->reason = xpcInterrupted);	// >>> Is this true?
 		return ch->reason;
 	}
 
@@ -1709,7 +1642,7 @@ xpc_allocate_msg_wait(struct xpc_channel
 
 	if (ch->flags & XPC_C_DISCONNECTING) {
 		ret = ch->reason;
-		DBUG_ON(ch->reason = xpcInterrupted);  // >>> Is this true?
+		DBUG_ON(ch->reason = xpcInterrupted);	// >>> Is this true?
 	} else if (ret = 0) {
 		ret = xpcTimeout;
 	} else {
@@ -1719,20 +1652,18 @@ xpc_allocate_msg_wait(struct xpc_channel
 	return ret;
 }
 
-
 /*
  * Allocate an entry for a message from the message queue associated with the
  * specified channel.
  */
 static enum xpc_retval
 xpc_allocate_msg(struct xpc_channel *ch, u32 flags,
-			struct xpc_msg **address_of_msg)
+		 struct xpc_msg **address_of_msg)
 {
 	struct xpc_msg *msg;
 	enum xpc_retval ret;
 	s64 put;
 
-
 	/* this reference will be dropped in xpc_send_msg() */
 	xpc_msgqueue_ref(ch);
 
@@ -1745,7 +1676,6 @@ xpc_allocate_msg(struct xpc_channel *ch,
 		return xpcNotConnected;
 	}
 
-
 	/*
 	 * Get the next available message entry from the local message queue.
 	 * If none are available, we'll make sure that we grab the latest
@@ -1755,25 +1685,23 @@ xpc_allocate_msg(struct xpc_channel *ch,
 
 	while (1) {
 
-		put = (volatile s64) ch->w_local_GP.put;
-		if (put - (volatile s64) ch->w_remote_GP.get <
-							ch->local_nentries) {
+		put = (volatile s64)ch->w_local_GP.put;
+		if (put - (volatile s64)ch->w_remote_GP.get <
+		    ch->local_nentries) {
 
 			/* There are available message entries. We need to try
 			 * to secure one for ourselves. We'll do this by trying
 			 * to increment w_local_GP.put as long as someone else
 			 * doesn't beat us to it. If they do, we'll have to
 			 * try again.
-		 	 */
-			if (cmpxchg(&ch->w_local_GP.put, put, put + 1) =
-									put) {
+			 */
+			if (cmpxchg(&ch->w_local_GP.put, put, put + 1) = put) {
 				/* we got the entry referenced by put */
 				break;
 			}
 			continue;	/* try again */
 		}
 
-
 		/*
 		 * There aren't any available msg entries at this time.
 		 *
@@ -1799,25 +1727,22 @@ xpc_allocate_msg(struct xpc_channel *ch,
 		}
 	}
 
-
 	/* get the message's address and initialize it */
-	msg = (struct xpc_msg *) ((u64) ch->local_msgqueue +
-				(put % ch->local_nentries) * ch->msg_size);
-
+	msg = (struct xpc_msg *)((u64)ch->local_msgqueue +
+				 (put % ch->local_nentries) * ch->msg_size);
 
 	DBUG_ON(msg->flags != 0);
 	msg->number = put;
 
 	dev_dbg(xpc_chan, "w_local_GP.put changed to %ld; msg=0x%p, "
 		"msg_number=%ld, partid=%d, channel=%d\n", put + 1,
-		(void *) msg, msg->number, ch->partid, ch->number);
+		(void *)msg, msg->number, ch->partid, ch->number);
 
 	*address_of_msg = msg;
 
 	return xpcSuccess;
 }
 
-
 /*
  * Allocate an entry for a message from the message queue associated with the
  * specified channel. NOTE that this routine can sleep waiting for a message
@@ -1838,7 +1763,6 @@ xpc_initiate_allocate(partid_t partid, i
 	enum xpc_retval ret = xpcUnknownReason;
 	struct xpc_msg *msg = NULL;
 
-
 	DBUG_ON(partid <= 0 || partid >= XP_MAX_PARTITIONS);
 	DBUG_ON(ch_number < 0 || ch_number >= part->nchannels);
 
@@ -1856,7 +1780,6 @@ xpc_initiate_allocate(partid_t partid, i
 	return ret;
 }
 
-
 /*
  * Now we actually send the messages that are ready to be sent by advancing
  * the local message queue's Put value and then send an IPI to the recipient
@@ -1869,16 +1792,16 @@ xpc_send_msgs(struct xpc_channel *ch, s6
 	s64 put = initial_put + 1;
 	int send_IPI = 0;
 
-
 	while (1) {
 
 		while (1) {
-			if (put = (volatile s64) ch->w_local_GP.put) {
+			if (put = (volatile s64)ch->w_local_GP.put) {
 				break;
 			}
 
-			msg = (struct xpc_msg *) ((u64) ch->local_msgqueue +
-			       (put % ch->local_nentries) * ch->msg_size);
+			msg = (struct xpc_msg *)((u64)ch->local_msgqueue +
+						 (put % ch->local_nentries) *
+						 ch->msg_size);
 
 			if (!(msg->flags & XPC_M_READY)) {
 				break;
@@ -1893,9 +1816,9 @@ xpc_send_msgs(struct xpc_channel *ch, s6
 		}
 
 		if (cmpxchg_rel(&ch->local_GP->put, initial_put, put) !-								initial_put) {
+		    initial_put) {
 			/* someone else beat us to it */
-			DBUG_ON((volatile s64) ch->local_GP->put < initial_put);
+			DBUG_ON((volatile s64)ch->local_GP->put < initial_put);
 			break;
 		}
 
@@ -1919,7 +1842,6 @@ xpc_send_msgs(struct xpc_channel *ch, s6
 	}
 }
 
-
 /*
  * Common code that does the actual sending of the message by advancing the
  * local message queue's Put value and sends an IPI to the partition the
@@ -1927,16 +1849,15 @@ xpc_send_msgs(struct xpc_channel *ch, s6
  */
 static enum xpc_retval
 xpc_send_msg(struct xpc_channel *ch, struct xpc_msg *msg, u8 notify_type,
-			xpc_notify_func func, void *key)
+	     xpc_notify_func func, void *key)
 {
 	enum xpc_retval ret = xpcSuccess;
 	struct xpc_notify *notify = notify;
 	s64 put, msg_number = msg->number;
 
-
 	DBUG_ON(notify_type = XPC_N_CALL && func = NULL);
-	DBUG_ON((((u64) msg - (u64) ch->local_msgqueue) / ch->msg_size) !-					msg_number % ch->local_nentries);
+	DBUG_ON((((u64)msg - (u64)ch->local_msgqueue) / ch->msg_size) !+		msg_number % ch->local_nentries);
 	DBUG_ON(msg->flags & XPC_M_READY);
 
 	if (ch->flags & XPC_C_DISCONNECTING) {
@@ -1970,7 +1891,7 @@ xpc_send_msg(struct xpc_channel *ch, str
 			 * the notify entry.
 			 */
 			if (cmpxchg(&notify->type, notify_type, 0) =
-								notify_type) {
+			    notify_type) {
 				atomic_dec(&ch->n_to_notify);
 				ret = ch->reason;
 			}
@@ -2001,7 +1922,6 @@ xpc_send_msg(struct xpc_channel *ch, str
 	return ret;
 }
 
-
 /*
  * Send a message previously allocated using xpc_initiate_allocate() on the
  * specified channel connected to the specified partition.
@@ -2029,8 +1949,7 @@ xpc_initiate_send(partid_t partid, int c
 	struct xpc_msg *msg = XPC_MSG_ADDRESS(payload);
 	enum xpc_retval ret;
 
-
-	dev_dbg(xpc_chan, "msg=0x%p, partid=%d, channel=%d\n", (void *) msg,
+	dev_dbg(xpc_chan, "msg=0x%p, partid=%d, channel=%d\n", (void *)msg,
 		partid, ch_number);
 
 	DBUG_ON(partid <= 0 || partid >= XP_MAX_PARTITIONS);
@@ -2042,7 +1961,6 @@ xpc_initiate_send(partid_t partid, int c
 	return ret;
 }
 
-
 /*
  * Send a message previously allocated using xpc_initiate_allocate on the
  * specified channel connected to the specified partition.
@@ -2075,14 +1993,13 @@ xpc_initiate_send(partid_t partid, int c
  */
 enum xpc_retval
 xpc_initiate_send_notify(partid_t partid, int ch_number, void *payload,
-				xpc_notify_func func, void *key)
+			 xpc_notify_func func, void *key)
 {
 	struct xpc_partition *part = &xpc_partitions[partid];
 	struct xpc_msg *msg = XPC_MSG_ADDRESS(payload);
 	enum xpc_retval ret;
 
-
-	dev_dbg(xpc_chan, "msg=0x%p, partid=%d, channel=%d\n", (void *) msg,
+	dev_dbg(xpc_chan, "msg=0x%p, partid=%d, channel=%d\n", (void *)msg,
 		partid, ch_number);
 
 	DBUG_ON(partid <= 0 || partid >= XP_MAX_PARTITIONS);
@@ -2091,11 +2008,10 @@ xpc_initiate_send_notify(partid_t partid
 	DBUG_ON(func = NULL);
 
 	ret = xpc_send_msg(&part->channels[ch_number], msg, XPC_N_CALL,
-								func, key);
+			   func, key);
 	return ret;
 }
 
-
 static struct xpc_msg *
 xpc_pull_remote_msg(struct xpc_channel *ch, s64 get)
 {
@@ -2105,7 +2021,6 @@ xpc_pull_remote_msg(struct xpc_channel *
 	u64 msg_offset;
 	enum xpc_retval ret;
 
-
 	if (mutex_lock_interruptible(&ch->msg_to_pull_mutex) != 0) {
 		/* we were interrupted by a signal */
 		return NULL;
@@ -2118,22 +2033,22 @@ xpc_pull_remote_msg(struct xpc_channel *
 		msg_index = ch->next_msg_to_pull % ch->remote_nentries;
 
 		DBUG_ON(ch->next_msg_to_pull >-					(volatile s64) ch->w_remote_GP.put);
-		nmsgs =  (volatile s64) ch->w_remote_GP.put -
-						ch->next_msg_to_pull;
+			(volatile s64)ch->w_remote_GP.put);
+		nmsgs = (volatile s64)ch->w_remote_GP.put -
+		    ch->next_msg_to_pull;
 		if (msg_index + nmsgs > ch->remote_nentries) {
 			/* ignore the ones that wrap the msg queue for now */
 			nmsgs = ch->remote_nentries - msg_index;
 		}
 
 		msg_offset = msg_index * ch->msg_size;
-		msg = (struct xpc_msg *) ((u64) ch->remote_msgqueue +
-								msg_offset);
-		remote_msg = (struct xpc_msg *) (ch->remote_msgqueue_pa +
-								msg_offset);
+		msg = (struct xpc_msg *)((u64)ch->remote_msgqueue + msg_offset);
+		remote_msg = (struct xpc_msg *)(ch->remote_msgqueue_pa +
+						msg_offset);
 
 		if ((ret = xpc_pull_remote_cachelines(part, msg, remote_msg,
-				nmsgs * ch->msg_size)) != xpcSuccess) {
+						      nmsgs * ch->msg_size)) !+		    xpcSuccess) {
 
 			dev_dbg(xpc_chan, "failed to pull %d msgs starting with"
 				" msg %ld from partition %d, channel=%d, "
@@ -2146,7 +2061,7 @@ xpc_pull_remote_msg(struct xpc_channel *
 			return NULL;
 		}
 
-		mb();	/* >>> this may not be needed, we're not sure */
+		mb();		/* >>> this may not be needed, we're not sure */
 
 		ch->next_msg_to_pull += nmsgs;
 	}
@@ -2155,12 +2070,11 @@ xpc_pull_remote_msg(struct xpc_channel *
 
 	/* return the message we were looking for */
 	msg_offset = (get % ch->remote_nentries) * ch->msg_size;
-	msg = (struct xpc_msg *) ((u64) ch->remote_msgqueue + msg_offset);
+	msg = (struct xpc_msg *)((u64)ch->remote_msgqueue + msg_offset);
 
 	return msg;
 }
 
-
 /*
  * Get a message to be delivered.
  */
@@ -2170,14 +2084,13 @@ xpc_get_deliverable_msg(struct xpc_chann
 	struct xpc_msg *msg = NULL;
 	s64 get;
 
-
 	do {
-		if ((volatile u32) ch->flags & XPC_C_DISCONNECTING) {
+		if ((volatile u32)ch->flags & XPC_C_DISCONNECTING) {
 			break;
 		}
 
-		get = (volatile s64) ch->w_local_GP.get;
-		if (get = (volatile s64) ch->w_remote_GP.put) {
+		get = (volatile s64)ch->w_local_GP.get;
+		if (get = (volatile s64)ch->w_remote_GP.put) {
 			break;
 		}
 
@@ -2186,7 +2099,7 @@ xpc_get_deliverable_msg(struct xpc_chann
 		 * by trying to increment w_local_GP.get and hope that no one
 		 * else beats us to it. If they do, we'll we'll simply have
 		 * to try again for the next one.
-	 	 */
+		 */
 
 		if (cmpxchg(&ch->w_local_GP.get, get, get + 1) = get) {
 			/* we got the entry referenced by get */
@@ -2211,7 +2124,6 @@ xpc_get_deliverable_msg(struct xpc_chann
 	return msg;
 }
 
-
 /*
  * Deliver a message to its intended recipient.
  */
@@ -2220,7 +2132,6 @@ xpc_deliver_msg(struct xpc_channel *ch)
 {
 	struct xpc_msg *msg;
 
-
 	if ((msg = xpc_get_deliverable_msg(ch)) != NULL) {
 
 		/*
@@ -2235,16 +2146,16 @@ xpc_deliver_msg(struct xpc_channel *ch)
 		if (ch->func != NULL) {
 			dev_dbg(xpc_chan, "ch->func() called, msg=0x%p, "
 				"msg_number=%ld, partid=%d, channel=%d\n",
-				(void *) msg, msg->number, ch->partid,
+				(void *)msg, msg->number, ch->partid,
 				ch->number);
 
 			/* deliver the message to its intended recipient */
 			ch->func(xpcMsgReceived, ch->partid, ch->number,
-					&msg->payload, ch->key);
+				 &msg->payload, ch->key);
 
 			dev_dbg(xpc_chan, "ch->func() returned, msg=0x%p, "
 				"msg_number=%ld, partid=%d, channel=%d\n",
-				(void *) msg, msg->number, ch->partid,
+				(void *)msg, msg->number, ch->partid,
 				ch->number);
 		}
 
@@ -2252,7 +2163,6 @@ xpc_deliver_msg(struct xpc_channel *ch)
 	}
 }
 
-
 /*
  * Now we actually acknowledge the messages that have been delivered and ack'd
  * by advancing the cached remote message queue's Get value and if requested
@@ -2265,16 +2175,16 @@ xpc_acknowledge_msgs(struct xpc_channel 
 	s64 get = initial_get + 1;
 	int send_IPI = 0;
 
-
 	while (1) {
 
 		while (1) {
-			if (get = (volatile s64) ch->w_local_GP.get) {
+			if (get = (volatile s64)ch->w_local_GP.get) {
 				break;
 			}
 
-			msg = (struct xpc_msg *) ((u64) ch->remote_msgqueue +
-			       (get % ch->remote_nentries) * ch->msg_size);
+			msg = (struct xpc_msg *)((u64)ch->remote_msgqueue +
+						 (get % ch->remote_nentries) *
+						 ch->msg_size);
 
 			if (!(msg->flags & XPC_M_DONE)) {
 				break;
@@ -2290,10 +2200,9 @@ xpc_acknowledge_msgs(struct xpc_channel 
 		}
 
 		if (cmpxchg_rel(&ch->local_GP->get, initial_get, get) !-								initial_get) {
+		    initial_get) {
 			/* someone else beat us to it */
-			DBUG_ON((volatile s64) ch->local_GP->get <-								initial_get);
+			DBUG_ON((volatile s64)ch->local_GP->get <= initial_get);
 			break;
 		}
 
@@ -2317,7 +2226,6 @@ xpc_acknowledge_msgs(struct xpc_channel 
 	}
 }
 
-
 /*
  * Acknowledge receipt of a delivered message.
  *
@@ -2343,17 +2251,16 @@ xpc_initiate_received(partid_t partid, i
 	struct xpc_msg *msg = XPC_MSG_ADDRESS(payload);
 	s64 get, msg_number = msg->number;
 
-
 	DBUG_ON(partid <= 0 || partid >= XP_MAX_PARTITIONS);
 	DBUG_ON(ch_number < 0 || ch_number >= part->nchannels);
 
 	ch = &part->channels[ch_number];
 
 	dev_dbg(xpc_chan, "msg=0x%p, msg_number=%ld, partid=%d, channel=%d\n",
-		(void *) msg, msg_number, ch->partid, ch->number);
+		(void *)msg, msg_number, ch->partid, ch->number);
 
-	DBUG_ON((((u64) msg - (u64) ch->remote_msgqueue) / ch->msg_size) !-					msg_number % ch->remote_nentries);
+	DBUG_ON((((u64)msg - (u64)ch->remote_msgqueue) / ch->msg_size) !+		msg_number % ch->remote_nentries);
 	DBUG_ON(msg->flags & XPC_M_DONE);
 
 	msg->flags |= XPC_M_DONE;
@@ -2376,4 +2283,3 @@ xpc_initiate_received(partid_t partid, i
 	/* the call to xpc_msgqueue_ref() was done by xpc_deliver_msg()  */
 	xpc_msgqueue_deref(ch);
 }
-
Index: linux-2.6/drivers/misc/sgi-xp/xpc_main.c
=================================--- linux-2.6.orig/drivers/misc/sgi-xp/xpc_main.c	2008-04-22 10:54:11.000000000 -0500
+++ linux-2.6/drivers/misc/sgi-xp/xpc_main.c	2008-04-22 11:32:20.872410785 -0500
@@ -6,7 +6,6 @@
  * Copyright (c) 2004-2008 Silicon Graphics, Inc.  All Rights Reserved.
  */
 
-
 /*
  * Cross Partition Communication (XPC) support - standard version.
  *
@@ -44,7 +43,6 @@
  *
  */
 
-
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/init.h>
@@ -61,7 +59,6 @@
 #include <asm/uaccess.h>
 #include "xpc.h"
 
-
 /* define two XPC debug device structures to be used with dev_dbg() et al */
 
 struct device_driver xpc_dbg_name = {
@@ -81,10 +78,8 @@ struct device xpc_chan_dbg_subname = {
 struct device *xpc_part = &xpc_part_dbg_subname;
 struct device *xpc_chan = &xpc_chan_dbg_subname;
 
-
 static int xpc_kdebug_ignore;
 
-
 /* systune related variables for /proc/sys directories */
 
 static int xpc_hb_interval = XPC_HB_DEFAULT_INTERVAL;
@@ -101,56 +96,51 @@ static int xpc_disengage_request_max_tim
 
 static ctl_table xpc_sys_xpc_hb_dir[] = {
 	{
-		.ctl_name 	= CTL_UNNUMBERED,
-		.procname	= "hb_interval",
-		.data		= &xpc_hb_interval,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
-		.extra1		= &xpc_hb_min_interval,
-		.extra2		= &xpc_hb_max_interval
-	},
+	 .ctl_name = CTL_UNNUMBERED,
+	 .procname = "hb_interval",
+	 .data = &xpc_hb_interval,
+	 .maxlen = sizeof(int),
+	 .mode = 0644,
+	 .proc_handler = &proc_dointvec_minmax,
+	 .strategy = &sysctl_intvec,
+	 .extra1 = &xpc_hb_min_interval,
+	 .extra2 = &xpc_hb_max_interval},
 	{
-		.ctl_name	= CTL_UNNUMBERED,
-		.procname	= "hb_check_interval",
-		.data		= &xpc_hb_check_interval,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
-		.extra1		= &xpc_hb_check_min_interval,
-		.extra2		= &xpc_hb_check_max_interval
-	},
+	 .ctl_name = CTL_UNNUMBERED,
+	 .procname = "hb_check_interval",
+	 .data = &xpc_hb_check_interval,
+	 .maxlen = sizeof(int),
+	 .mode = 0644,
+	 .proc_handler = &proc_dointvec_minmax,
+	 .strategy = &sysctl_intvec,
+	 .extra1 = &xpc_hb_check_min_interval,
+	 .extra2 = &xpc_hb_check_max_interval},
 	{}
 };
 static ctl_table xpc_sys_xpc_dir[] = {
 	{
-		.ctl_name	= CTL_UNNUMBERED,
-		.procname	= "hb",
-		.mode		= 0555,
-		.child		= xpc_sys_xpc_hb_dir
-	},
+	 .ctl_name = CTL_UNNUMBERED,
+	 .procname = "hb",
+	 .mode = 0555,
+	 .child = xpc_sys_xpc_hb_dir},
 	{
-		.ctl_name	= CTL_UNNUMBERED,
-		.procname	= "disengage_request_timelimit",
-		.data		= &xpc_disengage_request_timelimit,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
-		.extra1		= &xpc_disengage_request_min_timelimit,
-		.extra2		= &xpc_disengage_request_max_timelimit
-	},
+	 .ctl_name = CTL_UNNUMBERED,
+	 .procname = "disengage_request_timelimit",
+	 .data = &xpc_disengage_request_timelimit,
+	 .maxlen = sizeof(int),
+	 .mode = 0644,
+	 .proc_handler = &proc_dointvec_minmax,
+	 .strategy = &sysctl_intvec,
+	 .extra1 = &xpc_disengage_request_min_timelimit,
+	 .extra2 = &xpc_disengage_request_max_timelimit},
 	{}
 };
 static ctl_table xpc_sys_dir[] = {
 	{
-		.ctl_name	= CTL_UNNUMBERED,
-		.procname	= "xpc",
-		.mode		= 0555,
-		.child		= xpc_sys_xpc_dir
-	},
+	 .ctl_name = CTL_UNNUMBERED,
+	 .procname = "xpc",
+	 .mode = 0555,
+	 .child = xpc_sys_xpc_dir},
 	{}
 };
 static struct ctl_table_header *xpc_sysctl;
@@ -172,13 +162,10 @@ static DECLARE_COMPLETION(xpc_hb_checker
 /* notification that the xpc_discovery thread has exited */
 static DECLARE_COMPLETION(xpc_discovery_exited);
 
-
 static struct timer_list xpc_hb_timer;
 
-
 static void xpc_kthread_waitmsgs(struct xpc_partition *, struct xpc_channel *);
 
-
 static int xpc_system_reboot(struct notifier_block *, unsigned long, void *);
 static struct notifier_block xpc_reboot_notifier = {
 	.notifier_call = xpc_system_reboot,
@@ -189,25 +176,22 @@ static struct notifier_block xpc_die_not
 	.notifier_call = xpc_system_die,
 };
 
-
 /*
  * Timer function to enforce the timelimit on the partition disengage request.
  */
 static void
 xpc_timeout_partition_disengage_request(unsigned long data)
 {
-	struct xpc_partition *part = (struct xpc_partition *) data;
-
+	struct xpc_partition *part = (struct xpc_partition *)data;
 
 	DBUG_ON(time_before(jiffies, part->disengage_request_timeout));
 
-	(void) xpc_partition_disengaged(part);
+	(void)xpc_partition_disengaged(part);
 
 	DBUG_ON(part->disengage_request_timeout != 0);
 	DBUG_ON(xpc_partition_engaged(1UL << XPC_PARTID(part)) != 0);
 }
 
-
 /*
  * Notify the heartbeat check thread that an IRQ has been received.
  */
@@ -219,7 +203,6 @@ xpc_act_IRQ_handler(int irq, void *dev_i
 	return IRQ_HANDLED;
 }
 
-
 /*
  * Timer to produce the heartbeat.  The timer structures function is
  * already set when this is initially called.  A tunable is used to
@@ -238,7 +221,6 @@ xpc_hb_beater(unsigned long dummy)
 	add_timer(&xpc_hb_timer);
 }
 
-
 /*
  * This thread is responsible for nearly all of the partition
  * activation/deactivation.
@@ -248,8 +230,7 @@ xpc_hb_checker(void *ignore)
 {
 	int last_IRQ_count = 0;
 	int new_IRQ_count;
-	int force_IRQ=0;
-
+	int force_IRQ = 0;
 
 	/* this thread was marked active by xpc_hb_init() */
 
@@ -261,14 +242,13 @@ xpc_hb_checker(void *ignore)
 	xpc_hb_check_timeout = jiffies + (xpc_hb_check_interval * HZ);
 	xpc_hb_beater(0);
 
-	while (!(volatile int) xpc_exiting) {
+	while (!(volatile int)xpc_exiting) {
 
 		dev_dbg(xpc_part, "woke up with %d ticks rem; %d IRQs have "
 			"been received\n",
-			(int) (xpc_hb_check_timeout - jiffies),
+			(int)(xpc_hb_check_timeout - jiffies),
 			atomic_read(&xpc_act_IRQ_rcvd) - last_IRQ_count);
 
-
 		/* checking of remote heartbeats is skewed by IRQ handling */
 		if (time_after_eq(jiffies, xpc_hb_check_timeout)) {
 			dev_dbg(xpc_part, "checking remote heartbeats\n");
@@ -282,7 +262,6 @@ xpc_hb_checker(void *ignore)
 			force_IRQ = 1;
 		}
 
-
 		/* check for outstanding IRQs */
 		new_IRQ_count = atomic_read(&xpc_act_IRQ_rcvd);
 		if (last_IRQ_count < new_IRQ_count || force_IRQ != 0) {
@@ -294,30 +273,30 @@ xpc_hb_checker(void *ignore)
 			last_IRQ_count += xpc_identify_act_IRQ_sender();
 			if (last_IRQ_count < new_IRQ_count) {
 				/* retry once to help avoid missing AMO */
-				(void) xpc_identify_act_IRQ_sender();
+				(void)xpc_identify_act_IRQ_sender();
 			}
 			last_IRQ_count = new_IRQ_count;
 
 			xpc_hb_check_timeout = jiffies +
-					   (xpc_hb_check_interval * HZ);
+			    (xpc_hb_check_interval * HZ);
 		}
 
 		/* wait for IRQ or timeout */
-		(void) wait_event_interruptible(xpc_act_IRQ_wq,
-			    (last_IRQ_count < atomic_read(&xpc_act_IRQ_rcvd) ||
-					time_after_eq(jiffies, xpc_hb_check_timeout) ||
-						(volatile int) xpc_exiting));
+		(void)wait_event_interruptible(xpc_act_IRQ_wq,
+					       (last_IRQ_count <
+						atomic_read(&xpc_act_IRQ_rcvd)
+						|| time_after_eq(jiffies,
+							xpc_hb_check_timeout) ||
+						(volatile int)xpc_exiting));
 	}
 
 	dev_dbg(xpc_part, "heartbeat checker is exiting\n");
 
-
 	/* mark this thread as having exited */
 	complete(&xpc_hb_checker_exited);
 	return 0;
 }
 
-
 /*
  * This thread will attempt to discover other partitions to activate
  * based on info provided by SAL. This new thread is short lived and
@@ -337,7 +316,6 @@ xpc_initiate_discovery(void *ignore)
 	return 0;
 }
 
-
 /*
  * Establish first contact with the remote partititon. This involves pulling
  * the XPC per partition variables from the remote partition and waiting for
@@ -348,7 +326,6 @@ xpc_make_first_contact(struct xpc_partit
 {
 	enum xpc_retval ret;
 
-
 	while ((ret = xpc_pull_remote_vars_part(part)) != xpcSuccess) {
 		if (ret != xpcRetry) {
 			XPC_DEACTIVATE_PARTITION(part, ret);
@@ -359,7 +336,7 @@ xpc_make_first_contact(struct xpc_partit
 			"partition %d\n", XPC_PARTID(part));
 
 		/* wait a 1/4 of a second or so */
-		(void) msleep_interruptible(250);
+		(void)msleep_interruptible(250);
 
 		if (part->act_state = XPC_P_DEACTIVATING) {
 			return part->reason;
@@ -369,7 +346,6 @@ xpc_make_first_contact(struct xpc_partit
 	return xpc_mark_partition_active(part);
 }
 
-
 /*
  * The first kthread assigned to a newly activated partition is the one
  * created by XPC HB with which it calls xpc_partition_up(). XPC hangs on to
@@ -386,12 +362,11 @@ static void
 xpc_channel_mgr(struct xpc_partition *part)
 {
 	while (part->act_state != XPC_P_DEACTIVATING ||
-			atomic_read(&part->nchannels_active) > 0 ||
-					!xpc_partition_disengaged(part)) {
+	       atomic_read(&part->nchannels_active) > 0 ||
+	       !xpc_partition_disengaged(part)) {
 
 		xpc_process_channel_activity(part);
 
-
 		/*
 		 * Wait until we've been requested to activate kthreads or
 		 * all of the channel's message queues have been torn down or
@@ -406,13 +381,19 @@ xpc_channel_mgr(struct xpc_partition *pa
 		 * wake him up.
 		 */
 		atomic_dec(&part->channel_mgr_requests);
-		(void) wait_event_interruptible(part->channel_mgr_wq,
-				(atomic_read(&part->channel_mgr_requests) > 0 ||
-				(volatile u64) part->local_IPI_amo != 0 ||
-				((volatile u8) part->act_state =
-							XPC_P_DEACTIVATING &&
-				atomic_read(&part->nchannels_active) = 0 &&
-				xpc_partition_disengaged(part))));
+		(void)wait_event_interruptible(part->channel_mgr_wq,
+					       (atomic_read
+						(&part->channel_mgr_requests) >
+						0 ||
+						(volatile u64)part->
+						local_IPI_amo != 0 ||
+						((volatile u8)part->act_state =
+						 XPC_P_DEACTIVATING &&
+						 atomic_read(&part->
+							     nchannels_active)
+						 = 0 &&
+						 xpc_partition_disengaged
+						 (part))));
 		atomic_set(&part->channel_mgr_requests, 1);
 
 		// >>> Does it need to wakeup periodically as well? In case we
@@ -420,7 +401,6 @@ xpc_channel_mgr(struct xpc_partition *pa
 	}
 }
 
-
 /*
  * When XPC HB determines that a partition has come up, it will create a new
  * kthread and that kthread will call this function to attempt to set up the
@@ -454,7 +434,7 @@ xpc_partition_up(struct xpc_partition *p
 	 * has been dismantled.
 	 */
 
-	(void) xpc_part_ref(part);	/* this will always succeed */
+	(void)xpc_part_ref(part);	/* this will always succeed */
 
 	if (xpc_make_first_contact(part) = xpcSuccess) {
 		xpc_channel_mgr(part);
@@ -465,17 +445,15 @@ xpc_partition_up(struct xpc_partition *p
 	xpc_teardown_infrastructure(part);
 }
 
-
 static int
 xpc_activating(void *__partid)
 {
-	partid_t partid = (u64) __partid;
+	partid_t partid = (u64)__partid;
 	struct xpc_partition *part = &xpc_partitions[partid];
 	unsigned long irq_flags;
-	struct sched_param param = { .sched_priority = MAX_RT_PRIO - 1 };
+	struct sched_param param = {.sched_priority = MAX_RT_PRIO - 1 };
 	int ret;
 
-
 	DBUG_ON(partid <= 0 || partid >= XP_MAX_PARTITIONS);
 
 	spin_lock_irqsave(&part->act_lock, irq_flags);
@@ -505,7 +483,7 @@ xpc_activating(void *__partid)
 	ret = sched_setscheduler(current, SCHED_FIFO, &param);
 	if (ret != 0) {
 		dev_warn(xpc_part, "unable to set pid %d to a realtime "
-			"priority, ret=%d\n", current->pid, ret);
+			 "priority, ret=%d\n", current->pid, ret);
 	}
 
 	/* allow this thread and its children to run on any CPU */
@@ -522,9 +500,9 @@ xpc_activating(void *__partid)
 	 * reloads and system reboots.
 	 */
 	if (sn_register_xp_addr_region(part->remote_amos_page_pa,
-							PAGE_SIZE, 1) < 0) {
+				       PAGE_SIZE, 1) < 0) {
 		dev_warn(xpc_part, "xpc_partition_up(%d) failed to register "
-			"xp_addr region\n", partid);
+			 "xp_addr region\n", partid);
 
 		spin_lock_irqsave(&part->act_lock, irq_flags);
 		part->act_state = XPC_P_INACTIVE;
@@ -537,12 +515,11 @@ xpc_activating(void *__partid)
 	xpc_allow_hb(partid, xpc_vars);
 	xpc_IPI_send_activated(part);
 
-
 	/*
 	 * xpc_partition_up() holds this thread and marks this partition as
 	 * XPC_P_ACTIVE by calling xpc_hb_mark_active().
 	 */
-	(void) xpc_partition_up(part);
+	(void)xpc_partition_up(part);
 
 	xpc_disallow_hb(partid, xpc_vars);
 	xpc_mark_partition_inactive(part);
@@ -555,7 +532,6 @@ xpc_activating(void *__partid)
 	return 0;
 }
 
-
 void
 xpc_activate_partition(struct xpc_partition *part)
 {
@@ -563,7 +539,6 @@ xpc_activate_partition(struct xpc_partit
 	unsigned long irq_flags;
 	pid_t pid;
 
-
 	spin_lock_irqsave(&part->act_lock, irq_flags);
 
 	DBUG_ON(part->act_state != XPC_P_INACTIVE);
@@ -573,7 +548,7 @@ xpc_activate_partition(struct xpc_partit
 
 	spin_unlock_irqrestore(&part->act_lock, irq_flags);
 
-	pid = kernel_thread(xpc_activating, (void *) ((u64) partid), 0);
+	pid = kernel_thread(xpc_activating, (void *)((u64)partid), 0);
 
 	if (unlikely(pid <= 0)) {
 		spin_lock_irqsave(&part->act_lock, irq_flags);
@@ -583,7 +558,6 @@ xpc_activate_partition(struct xpc_partit
 	}
 }
 
-
 /*
  * Handle the receipt of a SGI_XPC_NOTIFY IRQ by seeing whether the specified
  * partition actually sent it. Since SGI_XPC_NOTIFY IRQs may be shared by more
@@ -603,10 +577,9 @@ xpc_activate_partition(struct xpc_partit
 irqreturn_t
 xpc_notify_IRQ_handler(int irq, void *dev_id)
 {
-	partid_t partid = (partid_t) (u64) dev_id;
+	partid_t partid = (partid_t) (u64)dev_id;
 	struct xpc_partition *part = &xpc_partitions[partid];
 
-
 	DBUG_ON(partid <= 0 || partid >= XP_MAX_PARTITIONS);
 
 	if (xpc_part_ref(part)) {
@@ -617,7 +590,6 @@ xpc_notify_IRQ_handler(int irq, void *de
 	return IRQ_HANDLED;
 }
 
-
 /*
  * Check to see if xpc_notify_IRQ_handler() dropped any IPIs on the floor
  * because the write to their associated IPI amo completed after the IRQ/IPI
@@ -630,13 +602,12 @@ xpc_dropped_IPI_check(struct xpc_partiti
 		xpc_check_for_channel_activity(part);
 
 		part->dropped_IPI_timer.expires = jiffies +
-							XPC_P_DROPPED_IPI_WAIT;
+		    XPC_P_DROPPED_IPI_WAIT;
 		add_timer(&part->dropped_IPI_timer);
 		xpc_part_deref(part);
 	}
 }
 
-
 void
 xpc_activate_kthreads(struct xpc_channel *ch, int needed)
 {
@@ -644,7 +615,6 @@ xpc_activate_kthreads(struct xpc_channel
 	int assigned = atomic_read(&ch->kthreads_assigned);
 	int wakeup;
 
-
 	DBUG_ON(needed <= 0);
 
 	if (idle > 0) {
@@ -676,7 +646,6 @@ xpc_activate_kthreads(struct xpc_channel
 	xpc_create_kthreads(ch, needed, 0);
 }
 
-
 /*
  * This function is where XPC's kthreads wait for messages to deliver.
  */
@@ -686,15 +655,14 @@ xpc_kthread_waitmsgs(struct xpc_partitio
 	do {
 		/* deliver messages to their intended recipients */
 
-		while ((volatile s64) ch->w_local_GP.get <
-				(volatile s64) ch->w_remote_GP.put &&
-					!((volatile u32) ch->flags &
-						XPC_C_DISCONNECTING)) {
+		while ((volatile s64)ch->w_local_GP.get <
+		       (volatile s64)ch->w_remote_GP.put &&
+		       !((volatile u32)ch->flags & XPC_C_DISCONNECTING)) {
 			xpc_deliver_msg(ch);
 		}
 
 		if (atomic_inc_return(&ch->kthreads_idle) >
-						ch->kthreads_idle_limit) {
+		    ch->kthreads_idle_limit) {
 			/* too many idle kthreads on this channel */
 			atomic_dec(&ch->kthreads_idle);
 			break;
@@ -703,18 +671,20 @@ xpc_kthread_waitmsgs(struct xpc_partitio
 		dev_dbg(xpc_chan, "idle kthread calling "
 			"wait_event_interruptible_exclusive()\n");
 
-		(void) wait_event_interruptible_exclusive(ch->idle_wq,
-				((volatile s64) ch->w_local_GP.get <
-					(volatile s64) ch->w_remote_GP.put ||
-				((volatile u32) ch->flags &
-						XPC_C_DISCONNECTING)));
+		(void)wait_event_interruptible_exclusive(ch->idle_wq,
+							 ((volatile s64)ch->
+							  w_local_GP.get <
+							  (volatile s64)ch->
+							  w_remote_GP.put ||
+							  ((volatile u32)ch->
+							   flags &
+							   XPC_C_DISCONNECTING)));
 
 		atomic_dec(&ch->kthreads_idle);
 
-	} while (!((volatile u32) ch->flags & XPC_C_DISCONNECTING));
+	} while (!((volatile u32)ch->flags & XPC_C_DISCONNECTING));
 }
 
-
 static int
 xpc_daemonize_kthread(void *args)
 {
@@ -725,7 +695,6 @@ xpc_daemonize_kthread(void *args)
 	int n_needed;
 	unsigned long irq_flags;
 
-
 	daemonize("xpc%02dc%d", partid, ch_number);
 
 	dev_dbg(xpc_chan, "kthread starting, partid=%d, channel=%d\n",
@@ -756,8 +725,7 @@ xpc_daemonize_kthread(void *args)
 			 * need one less than total #of messages to deliver.
 			 */
 			n_needed = ch->w_remote_GP.put - ch->w_local_GP.get - 1;
-			if (n_needed > 0 &&
-					!(ch->flags & XPC_C_DISCONNECTING)) {
+			if (n_needed > 0 && !(ch->flags & XPC_C_DISCONNECTING)) {
 				xpc_activate_kthreads(ch, n_needed);
 			}
 		} else {
@@ -771,7 +739,7 @@ xpc_daemonize_kthread(void *args)
 
 	spin_lock_irqsave(&ch->lock, irq_flags);
 	if ((ch->flags & XPC_C_CONNECTEDCALLOUT_MADE) &&
-			!(ch->flags & XPC_C_DISCONNECTINGCALLOUT)) {
+	    !(ch->flags & XPC_C_DISCONNECTINGCALLOUT)) {
 		ch->flags |= XPC_C_DISCONNECTINGCALLOUT;
 		spin_unlock_irqrestore(&ch->lock, irq_flags);
 
@@ -798,7 +766,6 @@ xpc_daemonize_kthread(void *args)
 	return 0;
 }
 
-
 /*
  * For each partition that XPC has established communications with, there is
  * a minimum of one kernel thread assigned to perform any operation that
@@ -813,14 +780,13 @@ xpc_daemonize_kthread(void *args)
  */
 void
 xpc_create_kthreads(struct xpc_channel *ch, int needed,
-			int ignore_disconnecting)
+		    int ignore_disconnecting)
 {
 	unsigned long irq_flags;
 	pid_t pid;
 	u64 args = XPC_PACK_ARGS(ch->partid, ch->number);
 	struct xpc_partition *part = &xpc_partitions[ch->partid];
 
-
 	while (needed-- > 0) {
 
 		/*
@@ -832,7 +798,7 @@ xpc_create_kthreads(struct xpc_channel *
 			if (!atomic_inc_not_zero(&ch->kthreads_assigned)) {
 				/* kthreads assigned had gone to zero */
 				BUG_ON(!(ch->flags &
-					XPC_C_DISCONNECTINGCALLOUT_MADE));
+					 XPC_C_DISCONNECTINGCALLOUT_MADE));
 				break;
 			}
 
@@ -843,10 +809,10 @@ xpc_create_kthreads(struct xpc_channel *
 			if (atomic_inc_return(&part->nchannels_engaged) = 1)
 				xpc_mark_partition_engaged(part);
 		}
-		(void) xpc_part_ref(part);
+		(void)xpc_part_ref(part);
 		xpc_msgqueue_ref(ch);
 
-		pid = kernel_thread(xpc_daemonize_kthread, (void *) args, 0);
+		pid = kernel_thread(xpc_daemonize_kthread, (void *)args, 0);
 		if (pid < 0) {
 			/* the fork failed */
 
@@ -869,7 +835,7 @@ xpc_create_kthreads(struct xpc_channel *
 			xpc_part_deref(part);
 
 			if (atomic_read(&ch->kthreads_assigned) <
-						ch->kthreads_idle_limit) {
+			    ch->kthreads_idle_limit) {
 				/*
 				 * Flag this as an error only if we have an
 				 * insufficient #of kthreads for the channel
@@ -877,7 +843,7 @@ xpc_create_kthreads(struct xpc_channel *
 				 */
 				spin_lock_irqsave(&ch->lock, irq_flags);
 				XPC_DISCONNECT_CHANNEL(ch, xpcLackOfResources,
-								&irq_flags);
+						       &irq_flags);
 				spin_unlock_irqrestore(&ch->lock, irq_flags);
 			}
 			break;
@@ -887,7 +853,6 @@ xpc_create_kthreads(struct xpc_channel *
 	}
 }
 
-
 void
 xpc_disconnect_wait(int ch_number)
 {
@@ -897,7 +862,6 @@ xpc_disconnect_wait(int ch_number)
 	struct xpc_channel *ch;
 	int wakeup_channel_mgr;
 
-
 	/* now wait for all callouts to the caller's function to cease */
 	for (partid = 1; partid < XP_MAX_PARTITIONS; partid++) {
 		part = &xpc_partitions[partid];
@@ -923,7 +887,8 @@ xpc_disconnect_wait(int ch_number)
 			if (part->act_state != XPC_P_DEACTIVATING) {
 				spin_lock(&part->IPI_lock);
 				XPC_SET_IPI_FLAGS(part->local_IPI_amo,
-					ch->number, ch->delayed_IPI_flags);
+						  ch->number,
+						  ch->delayed_IPI_flags);
 				spin_unlock(&part->IPI_lock);
 				wakeup_channel_mgr = 1;
 			}
@@ -941,7 +906,6 @@ xpc_disconnect_wait(int ch_number)
 	}
 }
 
-
 static void
 xpc_do_exit(enum xpc_retval reason)
 {
@@ -950,7 +914,6 @@ xpc_do_exit(enum xpc_retval reason)
 	struct xpc_partition *part;
 	unsigned long printmsg_time, disengage_request_timeout = 0;
 
-
 	/* a 'rmmod XPC' and a 'reboot' cannot both end up here together */
 	DBUG_ON(xpc_exiting = 1);
 
@@ -971,10 +934,8 @@ xpc_do_exit(enum xpc_retval reason)
 	/* wait for the heartbeat checker thread to exit */
 	wait_for_completion(&xpc_hb_checker_exited);
 
-
 	/* sleep for a 1/3 of a second or so */
-	(void) msleep_interruptible(300);
-
+	(void)msleep_interruptible(300);
 
 	/* wait for all partitions to become inactive */
 
@@ -988,7 +949,7 @@ xpc_do_exit(enum xpc_retval reason)
 			part = &xpc_partitions[partid];
 
 			if (xpc_partition_disengaged(part) &&
-					part->act_state = XPC_P_INACTIVE) {
+			    part->act_state = XPC_P_INACTIVE) {
 				continue;
 			}
 
@@ -997,47 +958,46 @@ xpc_do_exit(enum xpc_retval reason)
 			XPC_DEACTIVATE_PARTITION(part, reason);
 
 			if (part->disengage_request_timeout >
-						disengage_request_timeout) {
+			    disengage_request_timeout) {
 				disengage_request_timeout -						part->disengage_request_timeout;
+				    part->disengage_request_timeout;
 			}
 		}
 
 		if (xpc_partition_engaged(-1UL)) {
 			if (time_after(jiffies, printmsg_time)) {
 				dev_info(xpc_part, "waiting for remote "
-					"partitions to disengage, timeout in "
-					"%ld seconds\n",
-					(disengage_request_timeout - jiffies)
-									/ HZ);
+					 "partitions to disengage, timeout in "
+					 "%ld seconds\n",
+					 (disengage_request_timeout - jiffies)
+					 / HZ);
 				printmsg_time = jiffies +
-					(XPC_DISENGAGE_PRINTMSG_INTERVAL * HZ);
+				    (XPC_DISENGAGE_PRINTMSG_INTERVAL * HZ);
 				printed_waiting_msg = 1;
 			}
 
 		} else if (active_part_count > 0) {
 			if (printed_waiting_msg) {
 				dev_info(xpc_part, "waiting for local partition"
-					" to disengage\n");
+					 " to disengage\n");
 				printed_waiting_msg = 0;
 			}
 
 		} else {
 			if (!xpc_disengage_request_timedout) {
 				dev_info(xpc_part, "all partitions have "
-					"disengaged\n");
+					 "disengaged\n");
 			}
 			break;
 		}
 
 		/* sleep for a 1/3 of a second or so */
-		(void) msleep_interruptible(300);
+		(void)msleep_interruptible(300);
 
 	} while (1);
 
 	DBUG_ON(xpc_partition_engaged(-1UL));
 
-
 	/* indicate to others that our reserved page is uninitialized */
 	xpc_rsvd_page->vars_pa = 0;
 
@@ -1047,16 +1007,15 @@ xpc_do_exit(enum xpc_retval reason)
 
 	if (reason = xpcUnloading) {
 		/* take ourselves off of the reboot_notifier_list */
-		(void) unregister_reboot_notifier(&xpc_reboot_notifier);
+		(void)unregister_reboot_notifier(&xpc_reboot_notifier);
 
 		/* take ourselves off of the die_notifier list */
-		(void) unregister_die_notifier(&xpc_die_notifier);
+		(void)unregister_die_notifier(&xpc_die_notifier);
 	}
 
 	/* close down protections for IPI operations */
 	xpc_restrict_IPI_ops();
 
-
 	/* clear the interface to XPC's functions */
 	xpc_clear_interface();
 
@@ -1067,7 +1026,6 @@ xpc_do_exit(enum xpc_retval reason)
 	kfree(xpc_remote_copy_buffer_base);
 }
 
-
 /*
  * This function is called when the system is being rebooted.
  */
@@ -1076,7 +1034,6 @@ xpc_system_reboot(struct notifier_block 
 {
 	enum xpc_retval reason;
 
-
 	switch (event) {
 	case SYS_RESTART:
 		reason = xpcSystemReboot;
@@ -1095,7 +1052,6 @@ xpc_system_reboot(struct notifier_block 
 	return NOTIFY_DONE;
 }
 
-
 /*
  * Notify other partitions to disengage from all references to our memory.
  */
@@ -1107,17 +1063,15 @@ xpc_die_disengage(void)
 	unsigned long engaged;
 	long time, printmsg_time, disengage_request_timeout;
 
-
 	/* keep xpc_hb_checker thread from doing anything (just in case) */
 	xpc_exiting = 1;
 
-	xpc_vars->heartbeating_to_mask = 0;  /* indicate we're deactivated */
+	xpc_vars->heartbeating_to_mask = 0;	/* indicate we're deactivated */
 
 	for (partid = 1; partid < XP_MAX_PARTITIONS; partid++) {
 		part = &xpc_partitions[partid];
 
-		if (!XPC_SUPPORTS_DISENGAGE_REQUEST(part->
-							remote_vars_version)) {
+		if (!XPC_SUPPORTS_DISENGAGE_REQUEST(part->remote_vars_version)) {
 
 			/* just in case it was left set by an earlier XPC */
 			xpc_clear_partition_engaged(1UL << partid);
@@ -1125,7 +1079,7 @@ xpc_die_disengage(void)
 		}
 
 		if (xpc_partition_engaged(1UL << partid) ||
-					part->act_state != XPC_P_INACTIVE) {
+		    part->act_state != XPC_P_INACTIVE) {
 			xpc_request_partition_disengage(part);
 			xpc_mark_partition_disengaged(part);
 			xpc_IPI_send_disengage(part);
@@ -1134,9 +1088,9 @@ xpc_die_disengage(void)
 
 	time = rtc_time();
 	printmsg_time = time +
-		(XPC_DISENGAGE_PRINTMSG_INTERVAL * sn_rtc_cycles_per_second);
+	    (XPC_DISENGAGE_PRINTMSG_INTERVAL * sn_rtc_cycles_per_second);
 	disengage_request_timeout = time +
-		(xpc_disengage_request_timelimit * sn_rtc_cycles_per_second);
+	    (xpc_disengage_request_timelimit * sn_rtc_cycles_per_second);
 
 	/* wait for all other partitions to disengage from us */
 
@@ -1152,8 +1106,8 @@ xpc_die_disengage(void)
 			for (partid = 1; partid < XP_MAX_PARTITIONS; partid++) {
 				if (engaged & (1UL << partid)) {
 					dev_info(xpc_part, "disengage from "
-						"remote partition %d timed "
-						"out\n", partid);
+						 "remote partition %d timed "
+						 "out\n", partid);
 				}
 			}
 			break;
@@ -1161,17 +1115,16 @@ xpc_die_disengage(void)
 
 		if (time >= printmsg_time) {
 			dev_info(xpc_part, "waiting for remote partitions to "
-				"disengage, timeout in %ld seconds\n",
-				(disengage_request_timeout - time) /
-						sn_rtc_cycles_per_second);
+				 "disengage, timeout in %ld seconds\n",
+				 (disengage_request_timeout - time) /
+				 sn_rtc_cycles_per_second);
 			printmsg_time = time +
-					(XPC_DISENGAGE_PRINTMSG_INTERVAL *
-						sn_rtc_cycles_per_second);
+			    (XPC_DISENGAGE_PRINTMSG_INTERVAL *
+			     sn_rtc_cycles_per_second);
 		}
 	}
 }
 
-
 /*
  * This function is called when the system is being restarted or halted due
  * to some sort of system failure. If this is the case we need to notify the
@@ -1217,7 +1170,6 @@ xpc_system_die(struct notifier_block *nb
 	return NOTIFY_DONE;
 }
 
-
 int __init
 xpc_init(void)
 {
@@ -1227,16 +1179,15 @@ xpc_init(void)
 	pid_t pid;
 	size_t buf_size;
 
-
 	if (!ia64_platform_is("sn2")) {
 		return -ENODEV;
 	}
 
-
 	buf_size = max(XPC_RP_VARS_SIZE,
-				XPC_RP_HEADER_SIZE + XP_NASID_MASK_BYTES);
+		       XPC_RP_HEADER_SIZE + XP_NASID_MASK_BYTES);
 	xpc_remote_copy_buffer = xpc_kmalloc_cacheline_aligned(buf_size,
-				     GFP_KERNEL, &xpc_remote_copy_buffer_base);
+							       GFP_KERNEL,
+							       &xpc_remote_copy_buffer_base);
 	if (xpc_remote_copy_buffer = NULL)
 		return -ENOMEM;
 
@@ -1256,7 +1207,7 @@ xpc_init(void)
 	for (partid = 1; partid < XP_MAX_PARTITIONS; partid++) {
 		part = &xpc_partitions[partid];
 
-		DBUG_ON((u64) part != L1_CACHE_ALIGN((u64) part));
+		DBUG_ON((u64)part != L1_CACHE_ALIGN((u64)part));
 
 		part->act_IRQ_rcvd = 0;
 		spin_lock_init(&part->act_lock);
@@ -1265,8 +1216,8 @@ xpc_init(void)
 
 		init_timer(&part->disengage_request_timer);
 		part->disengage_request_timer.function -				xpc_timeout_partition_disengage_request;
-		part->disengage_request_timer.data = (unsigned long) part;
+		    xpc_timeout_partition_disengage_request;
+		part->disengage_request_timer.data = (unsigned long)part;
 
 		part->setup_state = XPC_P_UNSET;
 		init_waitqueue_head(&part->teardown_wq);
@@ -1292,7 +1243,7 @@ xpc_init(void)
 	 * but rather immediately process the interrupt.
 	 */
 	ret = request_irq(SGI_XPC_ACTIVATE, xpc_act_IRQ_handler, 0,
-							"xpc hb", NULL);
+			  "xpc hb", NULL);
 	if (ret != 0) {
 		dev_err(xpc_part, "can't register ACTIVATE IRQ handler, "
 			"errno=%d\n", -ret);
@@ -1327,7 +1278,6 @@ xpc_init(void)
 		return -EBUSY;
 	}
 
-
 	/* add ourselves to the reboot_notifier_list */
 	ret = register_reboot_notifier(&xpc_reboot_notifier);
 	if (ret != 0) {
@@ -1355,10 +1305,10 @@ xpc_init(void)
 		xpc_rsvd_page->vars_pa = 0;
 
 		/* take ourselves off of the reboot_notifier_list */
-		(void) unregister_reboot_notifier(&xpc_reboot_notifier);
+		(void)unregister_reboot_notifier(&xpc_reboot_notifier);
 
 		/* take ourselves off of the die_notifier list */
-		(void) unregister_die_notifier(&xpc_die_notifier);
+		(void)unregister_die_notifier(&xpc_die_notifier);
 
 		del_timer_sync(&xpc_hb_timer);
 		free_irq(SGI_XPC_ACTIVATE, NULL);
@@ -1372,7 +1322,6 @@ xpc_init(void)
 		return -EBUSY;
 	}
 
-
 	/*
 	 * Startup a thread that will attempt to discover other partitions to
 	 * activate based on info provided by SAL. This new thread is short
@@ -1389,7 +1338,6 @@ xpc_init(void)
 		return -EBUSY;
 	}
 
-
 	/* set the interface to point at XPC's functions */
 	xpc_set_interface(xpc_initiate_connect, xpc_initiate_disconnect,
 			  xpc_initiate_allocate, xpc_initiate_send,
@@ -1398,16 +1346,16 @@ xpc_init(void)
 
 	return 0;
 }
-module_init(xpc_init);
 
+module_init(xpc_init);
 
 void __exit
 xpc_exit(void)
 {
 	xpc_do_exit(xpcUnloading);
 }
-module_exit(xpc_exit);
 
+module_exit(xpc_exit);
 
 MODULE_AUTHOR("Silicon Graphics, Inc.");
 MODULE_DESCRIPTION("Cross Partition Communication (XPC) support");
@@ -1415,17 +1363,16 @@ MODULE_LICENSE("GPL");
 
 module_param(xpc_hb_interval, int, 0);
 MODULE_PARM_DESC(xpc_hb_interval, "Number of seconds between "
-		"heartbeat increments.");
+		 "heartbeat increments.");
 
 module_param(xpc_hb_check_interval, int, 0);
 MODULE_PARM_DESC(xpc_hb_check_interval, "Number of seconds between "
-		"heartbeat checks.");
+		 "heartbeat checks.");
 
 module_param(xpc_disengage_request_timelimit, int, 0);
 MODULE_PARM_DESC(xpc_disengage_request_timelimit, "Number of seconds to wait "
-		"for disengage request to complete.");
+		 "for disengage request to complete.");
 
 module_param(xpc_kdebug_ignore, int, 0);
 MODULE_PARM_DESC(xpc_kdebug_ignore, "Should lack of heartbeat be ignored by "
-		"other partitions when dropping into kdebug.");
-
+		 "other partitions when dropping into kdebug.");
Index: linux-2.6/drivers/misc/sgi-xp/xpnet.c
=================================--- linux-2.6.orig/drivers/misc/sgi-xp/xpnet.c	2008-04-22 11:21:17.000000000 -0500
+++ linux-2.6/drivers/misc/sgi-xp/xpnet.c	2008-04-22 11:32:20.908415213 -0500
@@ -6,7 +6,6 @@
  * Copyright (C) 1999-2008 Silicon Graphics, Inc. All rights reserved.
  */
 
-
 /*
  * Cross Partition Network Interface (XPNET) support
  *
@@ -21,7 +20,6 @@
  *
  */
 
-
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/init.h>
@@ -40,7 +38,6 @@
 #include <asm/atomic.h>
 #include "xp.h"
 
-
 /*
  * The message payload transferred by XPC.
  *
@@ -79,7 +76,6 @@ struct xpnet_message {
 #define XPNET_MSG_ALIGNED_SIZE	(L1_CACHE_ALIGN(XPNET_MSG_SIZE))
 #define XPNET_MSG_NENTRIES	(PAGE_SIZE / XPNET_MSG_ALIGNED_SIZE)
 
-
 #define XPNET_MAX_KTHREADS	(XPNET_MSG_NENTRIES + 1)
 #define XPNET_MAX_IDLE_KTHREADS	(XPNET_MSG_NENTRIES + 1)
 
@@ -91,9 +87,9 @@ struct xpnet_message {
 #define XPNET_VERSION_MAJOR(_v)		((_v) >> 4)
 #define XPNET_VERSION_MINOR(_v)		((_v) & 0xf)
 
-#define	XPNET_VERSION _XPNET_VERSION(1,0)		/* version 1.0 */
-#define	XPNET_VERSION_EMBED _XPNET_VERSION(1,1)		/* version 1.1 */
-#define XPNET_MAGIC	0x88786984 /* "XNET" */
+#define	XPNET_VERSION _XPNET_VERSION(1,0)	/* version 1.0 */
+#define	XPNET_VERSION_EMBED _XPNET_VERSION(1,1)	/* version 1.1 */
+#define XPNET_MAGIC	0x88786984	/* "XNET" */
 
 #define XPNET_VALID_MSG(_m)						     \
    ((XPNET_VERSION_MAJOR(_m->version) = XPNET_VERSION_MAJOR(XPNET_VERSION)) \
@@ -101,7 +97,6 @@ struct xpnet_message {
 
 #define XPNET_DEVICE_NAME		"xp0"
 
-
 /*
  * When messages are queued with xpc_send_notify, a kmalloc'd buffer
  * of the following type is passed as a notification cookie.  When the
@@ -145,7 +140,6 @@ static DEFINE_SPINLOCK(xpnet_broadcast_l
 /* 32KB has been determined to be the ideal */
 #define XPNET_DEF_MTU (0x8000UL)
 
-
 /*
  * The partition id is encapsulated in the MAC address.  The following
  * define locates the octet the partid is in.
@@ -153,7 +147,6 @@ static DEFINE_SPINLOCK(xpnet_broadcast_l
 #define XPNET_PARTID_OCTET	1
 #define XPNET_LICENSE_OCTET	2
 
-
 /*
  * Define the XPNET debug device structure that is to be used with dev_dbg(),
  * dev_err(), dev_warn(), and dev_info().
@@ -163,7 +156,7 @@ struct device_driver xpnet_dbg_name = {
 };
 
 struct device xpnet_dbg_subname = {
-	.bus_id = {0},			/* set to "" */
+	.bus_id = {0},		/* set to "" */
 	.driver = &xpnet_dbg_name
 };
 
@@ -178,14 +171,13 @@ xpnet_receive(partid_t partid, int chann
 	struct sk_buff *skb;
 	bte_result_t bret;
 	struct xpnet_dev_private *priv -		(struct xpnet_dev_private *) xpnet_device->priv;
-
+	    (struct xpnet_dev_private *)xpnet_device->priv;
 
 	if (!XPNET_VALID_MSG(msg)) {
 		/*
 		 * Packet with a different XPC version.  Ignore.
 		 */
-		xpc_received(partid, channel, (void *) msg);
+		xpc_received(partid, channel, (void *)msg);
 
 		priv->stats.rx_errors++;
 
@@ -194,14 +186,13 @@ xpnet_receive(partid_t partid, int chann
 	dev_dbg(xpnet, "received 0x%lx, %d, %d, %d\n", msg->buf_pa, msg->size,
 		msg->leadin_ignore, msg->tailout_ignore);
 
-
 	/* reserve an extra cache line */
 	skb = dev_alloc_skb(msg->size + L1_CACHE_BYTES);
 	if (!skb) {
 		dev_err(xpnet, "failed on dev_alloc_skb(%d)\n",
 			msg->size + L1_CACHE_BYTES);
 
-		xpc_received(partid, channel, (void *) msg);
+		xpc_received(partid, channel, (void *)msg);
 
 		priv->stats.rx_errors++;
 
@@ -227,12 +218,13 @@ xpnet_receive(partid_t partid, int chann
 	 * Move the data over from the other side.
 	 */
 	if ((XPNET_VERSION_MINOR(msg->version) = 1) &&
-						(msg->embedded_bytes != 0)) {
+	    (msg->embedded_bytes != 0)) {
 		dev_dbg(xpnet, "copying embedded message. memcpy(0x%p, 0x%p, "
 			"%lu)\n", skb->data, &msg->data,
-			(size_t) msg->embedded_bytes);
+			(size_t)msg->embedded_bytes);
 
-		skb_copy_to_linear_data(skb, &msg->data, (size_t)msg->embedded_bytes);
+		skb_copy_to_linear_data(skb, &msg->data,
+					(size_t)msg->embedded_bytes);
 	} else {
 		dev_dbg(xpnet, "transferring buffer to the skb->data area;\n\t"
 			"bte_copy(0x%p, 0x%p, %hu)\n", (void *)msg->buf_pa,
@@ -250,10 +242,10 @@ xpnet_receive(partid_t partid, int chann
 			dev_err(xpnet, "bte_copy(0x%p, 0x%p, 0x%hx) returned "
 				"error=0x%x\n", (void *)msg->buf_pa,
 				(void *)__pa((u64)skb->data &
-							~(L1_CACHE_BYTES - 1)),
+					     ~(L1_CACHE_BYTES - 1)),
 				msg->size, bret);
 
-			xpc_received(partid, channel, (void *) msg);
+			xpc_received(partid, channel, (void *)msg);
 
 			priv->stats.rx_errors++;
 
@@ -262,7 +254,7 @@ xpnet_receive(partid_t partid, int chann
 	}
 
 	dev_dbg(xpnet, "<skb->head=0x%p skb->data=0x%p skb->tail=0x%p "
-		"skb->end=0x%p skb->len=%d\n", (void *) skb->head,
+		"skb->end=0x%p skb->len=%d\n", (void *)skb->head,
 		(void *)skb->data, skb_tail_pointer(skb), skb_end_pointer(skb),
 		skb->len);
 
@@ -275,16 +267,14 @@ xpnet_receive(partid_t partid, int chann
 		(void *)skb->head, (void *)skb->data, skb_tail_pointer(skb),
 		skb_end_pointer(skb), skb->len);
 
-
 	xpnet_device->last_rx = jiffies;
 	priv->stats.rx_packets++;
 	priv->stats.rx_bytes += skb->len + ETH_HLEN;
 
 	netif_rx_ni(skb);
-	xpc_received(partid, channel, (void *) msg);
+	xpc_received(partid, channel, (void *)msg);
 }
 
-
 /*
  * This is the handler which XPC calls during any sort of change in
  * state or message reception on a connection.
@@ -295,20 +285,19 @@ xpnet_connection_activity(enum xpc_retva
 {
 	long bp;
 
-
 	DBUG_ON(partid <= 0 || partid >= XP_MAX_PARTITIONS);
 	DBUG_ON(channel != XPC_NET_CHANNEL);
 
-	switch(reason) {
+	switch (reason) {
 	case xpcMsgReceived:	/* message received */
 		DBUG_ON(data = NULL);
 
-		xpnet_receive(partid, channel, (struct xpnet_message *) data);
+		xpnet_receive(partid, channel, (struct xpnet_message *)data);
 		break;
 
 	case xpcConnected:	/* connection completed to a partition */
 		spin_lock_bh(&xpnet_broadcast_lock);
-		xpnet_broadcast_partitions |= 1UL << (partid -1 );
+		xpnet_broadcast_partitions |= 1UL << (partid - 1);
 		bp = xpnet_broadcast_partitions;
 		spin_unlock_bh(&xpnet_broadcast_lock);
 
@@ -321,7 +310,7 @@ xpnet_connection_activity(enum xpc_retva
 
 	default:
 		spin_lock_bh(&xpnet_broadcast_lock);
-		xpnet_broadcast_partitions &= ~(1UL << (partid -1 ));
+		xpnet_broadcast_partitions &= ~(1UL << (partid - 1));
 		bp = xpnet_broadcast_partitions;
 		spin_unlock_bh(&xpnet_broadcast_lock);
 
@@ -337,13 +326,11 @@ xpnet_connection_activity(enum xpc_retva
 	}
 }
 
-
 static int
 xpnet_dev_open(struct net_device *dev)
 {
 	enum xpc_retval ret;
 
-
 	dev_dbg(xpnet, "calling xpc_connect(%d, 0x%p, NULL, %ld, %ld, %ld, "
 		"%ld)\n", XPC_NET_CHANNEL, xpnet_connection_activity,
 		XPNET_MSG_SIZE, XPNET_MSG_NENTRIES, XPNET_MAX_KTHREADS,
@@ -364,7 +351,6 @@ xpnet_dev_open(struct net_device *dev)
 	return 0;
 }
 
-
 static int
 xpnet_dev_stop(struct net_device *dev)
 {
@@ -375,7 +361,6 @@ xpnet_dev_stop(struct net_device *dev)
 	return 0;
 }
 
-
 static int
 xpnet_dev_change_mtu(struct net_device *dev, int new_mtu)
 {
@@ -392,7 +377,6 @@ xpnet_dev_change_mtu(struct net_device *
 	return 0;
 }
 
-
 /*
  * Required for the net_device structure.
  */
@@ -402,7 +386,6 @@ xpnet_dev_set_config(struct net_device *
 	return 0;
 }
 
-
 /*
  * Return statistics to the caller.
  */
@@ -411,13 +394,11 @@ xpnet_dev_get_stats(struct net_device *d
 {
 	struct xpnet_dev_private *priv;
 
-
-	priv = (struct xpnet_dev_private *) dev->priv;
+	priv = (struct xpnet_dev_private *)dev->priv;
 
 	return &priv->stats;
 }
 
-
 /*
  * Notification that the other end has received the message and
  * DMA'd the skb information.  At this point, they are done with
@@ -426,11 +407,9 @@ xpnet_dev_get_stats(struct net_device *d
  */
 static void
 xpnet_send_completed(enum xpc_retval reason, partid_t partid, int channel,
-			void *__qm)
+		     void *__qm)
 {
-	struct xpnet_pending_msg *queued_msg -		(struct xpnet_pending_msg *) __qm;
-
+	struct xpnet_pending_msg *queued_msg = (struct xpnet_pending_msg *)__qm;
 
 	DBUG_ON(queued_msg = NULL);
 
@@ -439,14 +418,13 @@ xpnet_send_completed(enum xpc_retval rea
 
 	if (atomic_dec_return(&queued_msg->use_count) = 0) {
 		dev_dbg(xpnet, "all acks for skb->head=-x%p\n",
-			(void *) queued_msg->skb->head);
+			(void *)queued_msg->skb->head);
 
 		dev_kfree_skb_any(queued_msg->skb);
 		kfree(queued_msg);
 	}
 }
 
-
 /*
  * Network layer has formatted a packet (skb) and is ready to place it
  * "on the wire".  Prepare and send an xpnet_message to all partitions
@@ -469,16 +447,13 @@ xpnet_dev_hard_start_xmit(struct sk_buff
 	struct xpnet_dev_private *priv;
 	u16 embedded_bytes;
 
-
-	priv = (struct xpnet_dev_private *) dev->priv;
-
+	priv = (struct xpnet_dev_private *)dev->priv;
 
 	dev_dbg(xpnet, ">skb->head=0x%p skb->data=0x%p skb->tail=0x%p "
-		"skb->end=0x%p skb->len=%d\n", (void *) skb->head,
+		"skb->end=0x%p skb->len=%d\n", (void *)skb->head,
 		(void *)skb->data, skb_tail_pointer(skb), skb_end_pointer(skb),
 		skb->len);
 
-
 	/*
 	 * The xpnet_pending_msg tracks how many outstanding
 	 * xpc_send_notifies are relying on this skb.  When none
@@ -487,16 +462,15 @@ xpnet_dev_hard_start_xmit(struct sk_buff
 	queued_msg = kmalloc(sizeof(struct xpnet_pending_msg), GFP_ATOMIC);
 	if (queued_msg = NULL) {
 		dev_warn(xpnet, "failed to kmalloc %ld bytes; dropping "
-			"packet\n", sizeof(struct xpnet_pending_msg));
+			 "packet\n", sizeof(struct xpnet_pending_msg));
 
 		priv->stats.tx_errors++;
 
 		return -ENOMEM;
 	}
 
-
 	/* get the beginning of the first cacheline and end of last */
-	start_addr = ((u64) skb->data & ~(L1_CACHE_BYTES - 1));
+	start_addr = ((u64)skb->data & ~(L1_CACHE_BYTES - 1));
 	end_addr = L1_CACHE_ALIGN((u64)skb_tail_pointer(skb));
 
 	/* calculate how many bytes to embed in the XPC message */
@@ -506,7 +480,6 @@ xpnet_dev_hard_start_xmit(struct sk_buff
 		embedded_bytes = skb->len;
 	}
 
-
 	/*
 	 * Since the send occurs asynchronously, we set the count to one
 	 * and begin sending.  Any sends that happen to complete before
@@ -517,14 +490,13 @@ xpnet_dev_hard_start_xmit(struct sk_buff
 	atomic_set(&queued_msg->use_count, 1);
 	queued_msg->skb = skb;
 
-
 	second_mac_octet = skb->data[XPNET_PARTID_OCTET];
 	if (second_mac_octet = 0xff) {
 		/* we are being asked to broadcast to all partitions */
 		dp = xpnet_broadcast_partitions;
 	} else if (second_mac_octet != 0) {
 		dp = xpnet_broadcast_partitions &
-					(1UL << (second_mac_octet - 1));
+		    (1UL << (second_mac_octet - 1));
 	} else {
 		/* 0 is an invalid partid.  Ignore */
 		dp = 0;
@@ -543,7 +515,6 @@ xpnet_dev_hard_start_xmit(struct sk_buff
 	for (dest_partid = 1; dp && dest_partid < XP_MAX_PARTITIONS;
 	     dest_partid++) {
 
-
 		if (!(dp & (1UL << (dest_partid - 1)))) {
 			/* not destined for this partition */
 			continue;
@@ -552,7 +523,6 @@ xpnet_dev_hard_start_xmit(struct sk_buff
 		/* remove this partition from the destinations mask */
 		dp &= ~(1UL << (dest_partid - 1));
 
-
 		/* found a partition to send to */
 
 		ret = xpc_allocate(dest_partid, XPC_NET_CHANNEL,
@@ -565,7 +535,7 @@ xpnet_dev_hard_start_xmit(struct sk_buff
 		if (unlikely(embedded_bytes != 0)) {
 			msg->version = XPNET_VERSION_EMBED;
 			dev_dbg(xpnet, "calling memcpy(0x%p, 0x%p, 0x%lx)\n",
-				&msg->data, skb->data, (size_t) embedded_bytes);
+				&msg->data, skb->data, (size_t)embedded_bytes);
 			skb_copy_from_linear_data(skb, &msg->data,
 						  (size_t)embedded_bytes);
 		} else {
@@ -573,7 +543,7 @@ xpnet_dev_hard_start_xmit(struct sk_buff
 		}
 		msg->magic = XPNET_MAGIC;
 		msg->size = end_addr - start_addr;
-		msg->leadin_ignore = (u64) skb->data - start_addr;
+		msg->leadin_ignore = (u64)skb->data - start_addr;
 		msg->tailout_ignore = end_addr - (u64)skb_tail_pointer(skb);
 		msg->buf_pa = __pa(start_addr);
 
@@ -583,7 +553,6 @@ xpnet_dev_hard_start_xmit(struct sk_buff
 			dest_partid, XPC_NET_CHANNEL, msg->buf_pa, msg->size,
 			msg->leadin_ignore, msg->tailout_ignore);
 
-
 		atomic_inc(&queued_msg->use_count);
 
 		ret = xpc_send_notify(dest_partid, XPC_NET_CHANNEL, msg,
@@ -599,7 +568,6 @@ xpnet_dev_hard_start_xmit(struct sk_buff
 		dev_dbg(xpnet, "no partitions to receive packet destined for "
 			"%d\n", dest_partid);
 
-
 		dev_kfree_skb(skb);
 		kfree(queued_msg);
 	}
@@ -610,23 +578,20 @@ xpnet_dev_hard_start_xmit(struct sk_buff
 	return 0;
 }
 
-
 /*
  * Deal with transmit timeouts coming from the network layer.
  */
 static void
-xpnet_dev_tx_timeout (struct net_device *dev)
+xpnet_dev_tx_timeout(struct net_device *dev)
 {
 	struct xpnet_dev_private *priv;
 
-
-	priv = (struct xpnet_dev_private *) dev->priv;
+	priv = (struct xpnet_dev_private *)dev->priv;
 
 	priv->stats.tx_errors++;
 	return;
 }
 
-
 static int __init
 xpnet_init(void)
 {
@@ -634,7 +599,6 @@ xpnet_init(void)
 	u32 license_num;
 	int result = -ENOMEM;
 
-
 	if (!ia64_platform_is("sn2")) {
 		return -ENODEV;
 	}
@@ -672,7 +636,7 @@ xpnet_init(void)
 	license_num = sn_partition_serial_number_val();
 	for (i = 3; i >= 0; i--) {
 		xpnet_device->dev_addr[XPNET_LICENSE_OCTET + i] -							license_num & 0xff;
+		    license_num & 0xff;
 		license_num = license_num >> 8;
 	}
 
@@ -696,23 +660,22 @@ xpnet_init(void)
 
 	return result;
 }
-module_init(xpnet_init);
 
+module_init(xpnet_init);
 
 static void __exit
 xpnet_exit(void)
 {
 	dev_info(xpnet, "unregistering network device %s\n",
-		xpnet_device[0].name);
+		 xpnet_device[0].name);
 
 	unregister_netdev(xpnet_device);
 
 	free_netdev(xpnet_device);
 }
-module_exit(xpnet_exit);
 
+module_exit(xpnet_exit);
 
 MODULE_AUTHOR("Silicon Graphics, Inc.");
 MODULE_DESCRIPTION("Cross Partition Network adapter (XPNET)");
 MODULE_LICENSE("GPL");
-
