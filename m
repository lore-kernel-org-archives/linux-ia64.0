From: Dean Nelson <dcn@sgi.com>
Date: Wed, 26 Mar 2008 16:53:04 +0000
Subject: [Patch 5/5] run drivers/misc/xp through scripts/checkpatch.pl -v2
Message-Id: <20080326165304.GF20663@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080326163823.GA25653@sgi.com>
In-Reply-To: <20080326163823.GA25653@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: jes@sgi.com, tony.luck@intel.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Addressed issues raised by scripts/checkpatch.pl. Removed unnecessary curly
braces.  Eliminated uses of volatiles and use of kernel_thread() and
daemonize().

Signed-off-by: Dean Nelson <dcn@sgi.com>

---

There are still a few false positives from checkpatch.pl concerning
WARNING: EXPORT_SYMBOL(foo); should immediately follow its function/variable

 drivers/misc/xp/xp_main.c       |   68 ++++------
 drivers/misc/xp/xp_sn2.c        |   23 +--
 drivers/misc/xp/xp_uv.c         |    2
 drivers/misc/xp/xpc.h           |  116 ++++++++---------
 drivers/misc/xp/xpc_channel.c   |  243 +++++++++++++++---------------------
 drivers/misc/xp/xpc_main.c      |  239 ++++++++++++-----------------------
 drivers/misc/xp/xpc_partition.c |   78 ++++-------
 drivers/misc/xp/xpnet.c         |   15 --
 8 files changed, 324 insertions(+), 460 deletions(-)

Index: linux-2.6/drivers/misc/xp/xpnet.c
===================================================================
--- linux-2.6.orig/drivers/misc/xp/xpnet.c	2008-03-25 07:10:15.693148179 -0500
+++ linux-2.6/drivers/misc/xp/xpnet.c	2008-03-25 07:10:17.729402225 -0500
@@ -84,8 +84,8 @@ struct xpnet_message {
 #define XPNET_VERSION_MAJOR(_v)		((_v) >> 4)
 #define XPNET_VERSION_MINOR(_v)		((_v) & 0xf)
 
-#define	XPNET_VERSION _XPNET_VERSION(1,0)	/* version 1.0 */
-#define	XPNET_VERSION_EMBED _XPNET_VERSION(1,1)	/* version 1.1 */
+#define	XPNET_VERSION _XPNET_VERSION(1, 0)	/* version 1.0 */
+#define	XPNET_VERSION_EMBED _XPNET_VERSION(1, 1)	/* version 1.1 */
 #define XPNET_MAGIC	0x88786984	/* "XNET" */
 
 #define XPNET_VALID_MSG(_m)						     \
@@ -571,9 +571,8 @@ xpnet_init(void)
 	short partid;
 	int result = -ENOMEM;
 
-	if (!is_shub() && !is_uv()) {
+	if (!is_shub() && !is_uv())
 		return -ENODEV;
-	}
 
 	dev_info(xpnet, "registering network device %s\n", XPNET_DEVICE_NAME);
 
@@ -583,9 +582,8 @@ xpnet_init(void)
 	 */
 	xpnet_device = alloc_netdev(sizeof(struct xpnet_dev_private),
 				    XPNET_DEVICE_NAME, ether_setup);
-	if (xpnet_device == NULL) {
+	if (xpnet_device == NULL)
 		return -ENOMEM;
-	}
 
 	netif_carrier_off(xpnet_device);
 
@@ -603,7 +601,7 @@ xpnet_init(void)
 	 * MAC addresses.  We chose the first octet of the MAC to be unlikely
 	 * to collide with any vendor's officially issued MAC.
 	 */
-	xpnet_device->dev_addr[0] = 0x02;	/* locally administered, no OUI */
+	xpnet_device->dev_addr[0] = 0x02;     /* locally administered, no OUI */
 
 	partid = xp_partition_id;
 
@@ -624,9 +622,8 @@ xpnet_init(void)
 	xpnet_device->features = NETIF_F_NO_CSUM;
 
 	result = register_netdev(xpnet_device);
-	if (result != 0) {
+	if (result != 0)
 		free_netdev(xpnet_device);
-	}
 
 	return result;
 }
Index: linux-2.6/drivers/misc/xp/xpc_partition.c
===================================================================
--- linux-2.6.orig/drivers/misc/xp/xpc_partition.c	2008-03-25 07:10:15.693148179 -0500
+++ linux-2.6/drivers/misc/xp/xpc_partition.c	2008-03-25 07:10:17.737403223 -0500
@@ -64,19 +64,19 @@ xpc_kmalloc_cacheline_aligned(size_t siz
 {
 	/* see if kmalloc will give us cachline aligned memory by default */
 	*base = kmalloc(size, flags);
-	if (*base == NULL) {
+	if (*base == NULL)
 		return NULL;
-	}
-	if ((u64)*base == L1_CACHE_ALIGN((u64)*base)) {
+
+	if ((u64)*base == L1_CACHE_ALIGN((u64)*base))
 		return *base;
-	}
+
 	kfree(*base);
 
 	/* nope, we'll have to do it ourselves */
 	*base = kmalloc(size + L1_CACHE_BYTES, flags);
-	if (*base == NULL) {
+	if (*base == NULL)
 		return NULL;
-	}
+
 	return (void *)L1_CACHE_ALIGN((u64)*base);
 }
 
@@ -103,9 +103,8 @@ xpc_get_rsvd_page_pa(int nasid)
 			"x, address=0x%016" U64_ELL "x len=0x%016lx\n", ret,
 			cookie, rp_pa, len);
 
-		if (ret != xpNeedMoreInfo) {
+		if (ret != xpNeedMoreInfo)
 			break;
-		}
 
 		if (L1_CACHE_ALIGN(len) > buf_len) {
 			kfree(buf_base);
@@ -130,9 +129,9 @@ xpc_get_rsvd_page_pa(int nasid)
 
 	kfree(buf_base);
 
-	if (ret != xpSuccess) {
+	if (ret != xpSuccess)
 		rp_pa = 0;
-	}
+
 	dev_dbg(xpc_part, "reserved page at phys address 0x%016" U64_ELL "x\n",
 		rp_pa);
 	return rp_pa;
@@ -195,7 +194,8 @@ xpc_rsvd_page_init(void)
 	 * that saved copy on subsequent loads of XPC. This AMO page is never
 	 * freed, and its memory protections are never restricted.
 	 */
-	if ((amos_page = xpc_vars->amos_page) == NULL) {
+	amos_page = xpc_vars->amos_page;
+	if (amos_page == NULL) {
 		n_amos = xpc_number_of_amos(XP_NPARTITIONS);
 		amos_page = xp_alloc_amos(n_amos);
 		if (amos_page == NULL) {
@@ -236,9 +236,8 @@ xpc_rsvd_page_init(void)
 
 	/* initialize the activate IRQ related AMO variables */
 	activate_irq_amos = xpc_activate_irq_amos(XP_NPARTITIONS);
-	for (i = 0; i < xp_nasid_mask_words(); i++) {
+	for (i = 0; i < xp_nasid_mask_words(); i++)
 		(void)xpc_IPI_init(activate_irq_amos + i);
-	}
 
 	/* initialize the engaged remote partitions related AMO variables */
 	engaged_partitions_amos = xpc_engaged_partitions_amos(XP_NPARTITIONS);
@@ -276,13 +275,11 @@ xpc_check_remote_hb(void)
 
 	for (partid = XP_MIN_PARTID; partid <= XP_MAX_PARTID; partid++) {
 
-		if (xpc_exiting) {
+		if (xpc_exiting)
 			break;
-		}
 
-		if (partid == xp_partition_id) {
+		if (partid == xp_partition_id)
 			continue;
-		}
 
 		part = &xpc_partitions[partid];
 
@@ -335,23 +332,20 @@ xpc_get_remote_rp(int nasid, u64 *discov
 	/* get the reserved page's physical address */
 
 	*remote_rp_pa = xpc_get_rsvd_page_pa(nasid);
-	if (*remote_rp_pa == 0) {
+	if (*remote_rp_pa == 0)
 		return xpNoRsvdPageAddr;
-	}
 
 	/* pull over the reserved page header and part_nasids mask */
 	ret = xp_remote_memcpy(remote_rp, (void *)*remote_rp_pa,
 			       XPC_RP_HEADER_SIZE + xp_sizeof_nasid_mask);
-	if (ret != xpSuccess) {
+	if (ret != xpSuccess)
 		return ret;
-	}
 
 	if (discovered_nasids != NULL) {
 		u64 *remote_part_nasids = XPC_RP_PART_NASIDS(remote_rp);
 
-		for (i = 0; i < xp_nasid_mask_words(); i++) {
+		for (i = 0; i < xp_nasid_mask_words(); i++)
 			discovered_nasids[i] |= remote_part_nasids[i];
-		}
 	}
 
 	if (XPC_VERSION_MAJOR(remote_rp->version) !=
@@ -373,16 +367,14 @@ xpc_get_remote_vars(u64 remote_vars_pa, 
 {
 	enum xp_retval ret;
 
-	if (remote_vars_pa == 0) {
+	if (remote_vars_pa == 0)
 		return xpVarsNotSet;
-	}
 
 	/* pull over the cross partition variables */
 	ret = xp_remote_memcpy(remote_vars, (void *)remote_vars_pa,
 			       XPC_RP_VARS_SIZE);
-	if (ret != xpSuccess) {
+	if (ret != xpSuccess)
 		return ret;
-	}
 
 	if (XPC_VERSION_MAJOR(remote_vars->version) !=
 	    XPC_VERSION_MAJOR(XPC_V_VERSION)) {
@@ -391,8 +383,9 @@ xpc_get_remote_vars(u64 remote_vars_pa, 
 
 	/* check that the partid is for another partition */
 	if (remote_vars->partid < XP_MIN_PARTID ||
-	    remote_vars->partid > XP_MAX_PARTID)
+	    remote_vars->partid > XP_MAX_PARTID) {
 		return xpInvalidPartid;
+	}
 	if (remote_vars->partid == xp_partition_id)
 		return xpLocalPartid;
 
@@ -494,9 +487,8 @@ xpc_identify_act_IRQ_req(int nasid)
 
 	remote_vars_pa = remote_rp->vars_pa;
 	remote_rp_version = remote_rp->version;
-	if (XPC_SUPPORTS_RP_STAMP(remote_rp_version)) {
+	if (XPC_SUPPORTS_RP_STAMP(remote_rp_version))
 		remote_rp_stamp = remote_rp->stamp;
-	}
 
 	/* pull over the cross partition variables */
 
@@ -656,9 +648,8 @@ xpc_identify_act_IRQ_sender(void)
 	/* scan through activation AMO variables looking for non-zero entries */
 	for (w_index = 0; w_index < xp_nasid_mask_words(); w_index++) {
 
-		if (xpc_exiting) {
+		if (xpc_exiting)
 			break;
-		}
 
 		ret = xp_get_amo(amo_va, XP_AMO_CLEAR, &nasid_mask);
 		BUG_ON(ret != xpSuccess);	/* should never happen */
@@ -733,13 +724,11 @@ xpc_partition_disengaged(struct xpc_part
 
 		DBUG_ON(part->act_state != XPC_P_AS_DEACTIVATING &&
 			part->act_state != XPC_P_AS_INACTIVE);
-		if (part->act_state != XPC_P_AS_INACTIVE) {
+		if (part->act_state != XPC_P_AS_INACTIVE)
 			xpc_wakeup_channel_mgr(part);
-		}
 
-		if (XPC_SUPPORTS_DISENGAGE_REQUEST(part->remote_vars_version)) {
+		if (XPC_SUPPORTS_DISENGAGE_REQUEST(part->remote_vars_version))
 			xpc_cancel_partition_disengage_request(part);
-		}
 	}
 	return disengaged;
 }
@@ -912,9 +901,9 @@ xpc_discovery(void)
 	remote_rp = xpc_kmalloc_cacheline_aligned(XPC_RP_HEADER_SIZE +
 						  xp_sizeof_nasid_mask,
 						  GFP_KERNEL, &remote_rp_base);
-	if (remote_rp == NULL) {
+	if (remote_rp == NULL)
 		return;
-	}
+
 	remote_vars = (struct xpc_vars *)remote_rp;
 
 	discovered_nasids = kzalloc(sizeof(u64) * xp_nasid_mask_words(),
@@ -947,18 +936,16 @@ xpc_discovery(void)
 
 	for (region = 0; region < max_regions; region++) {
 
-		if ((volatile int)xpc_exiting) {
+		if (xpc_exiting)
 			break;
-		}
 
 		dev_dbg(xpc_part, "searching region %d\n", region);
 
 		for (nasid = (region * region_size * 2);
 		     nasid < ((region + 1) * region_size * 2); nasid += 2) {
 
-			if ((volatile int)xpc_exiting) {
+			if (xpc_exiting)
 				break;
-			}
 
 			dev_dbg(xpc_part, "checking nasid %d\n", nasid);
 
@@ -1027,8 +1014,8 @@ xpc_discovery(void)
 			ret = xpc_register_remote_amos(part);
 			if (ret != xpSuccess) {
 				dev_warn(xpc_part, "xpc_discovery() failed to "
-					 "register remote AMOs for partition %d,"
-					 "ret=%d\n", partid, ret);
+					 "register remote AMOs for partition %d"
+					 ", ret=%d\n", partid, ret);
 
 				XPC_SET_REASON(part, xpPhysAddrRegFailed,
 					       __LINE__);
@@ -1072,9 +1059,8 @@ xpc_initiate_partid_to_nasids(short part
 	u64 part_nasid_pa;
 
 	part = &xpc_partitions[partid];
-	if (part->remote_rp_pa == 0) {
+	if (part->remote_rp_pa == 0)
 		return xpPartitionDown;
-	}
 
 	memset(nasid_mask, 0, xp_sizeof_nasid_mask);
 
Index: linux-2.6/drivers/misc/xp/xpc_channel.c
===================================================================
--- linux-2.6.orig/drivers/misc/xp/xpc_channel.c	2008-03-25 07:10:15.693148179 -0500
+++ linux-2.6/drivers/misc/xp/xpc_channel.c	2008-03-25 13:34:50.777575812 -0500
@@ -24,7 +24,7 @@
 #include "xpc.h"
 
 #ifdef CONFIG_X86_64
-#define cmpxchg_rel(ptr,o,n)	cmpxchg(ptr,o,n)
+#define cmpxchg_rel(ptr, o, n)	cmpxchg(ptr, o, n)
 #endif
 
 /*
@@ -35,19 +35,19 @@ xpc_kzalloc_cacheline_aligned(size_t siz
 {
 	/* see if kzalloc will give us cachline aligned memory by default */
 	*base = kzalloc(size, flags);
-	if (*base == NULL) {
+	if (*base == NULL)
 		return NULL;
-	}
-	if ((u64)*base == L1_CACHE_ALIGN((u64)*base)) {
+
+	if ((u64)*base == L1_CACHE_ALIGN((u64)*base))
 		return *base;
-	}
+
 	kfree(*base);
 
 	/* nope, we'll have to do it ourselves */
 	*base = kzalloc(size + L1_CACHE_BYTES, flags);
-	if (*base == NULL) {
+	if (*base == NULL)
 		return NULL;
-	}
+
 	return (void *)L1_CACHE_ALIGN((u64)*base);
 }
 
@@ -98,6 +98,7 @@ xpc_setup_infrastructure(struct xpc_part
 	int ret, cpuid;
 	struct timer_list *timer;
 	short partid = XPC_PARTID(part);
+	enum xp_retval retval;
 
 	/*
 	 * Zero out MOST of the entry for this partition. Only the fields
@@ -127,11 +128,10 @@ xpc_setup_infrastructure(struct xpc_part
 							GFP_KERNEL,
 							&part->local_GPs_base);
 	if (part->local_GPs == NULL) {
-		kfree(part->channels);
-		part->channels = NULL;
 		dev_err(xpc_chan, "can't get memory for local get/put "
 			"values\n");
-		return xpNoMemory;
+		retval = xpNoMemory;
+		goto out_1;
 	}
 
 	part->remote_GPs = xpc_kzalloc_cacheline_aligned(XPC_GP_SIZE,
@@ -141,11 +141,8 @@ xpc_setup_infrastructure(struct xpc_part
 	if (part->remote_GPs == NULL) {
 		dev_err(xpc_chan, "can't get memory for remote get/put "
 			"values\n");
-		kfree(part->local_GPs_base);
-		part->local_GPs = NULL;
-		kfree(part->channels);
-		part->channels = NULL;
-		return xpNoMemory;
+		retval = xpNoMemory;
+		goto out_2;
 	}
 
 	/* allocate all the required open and close args */
@@ -155,13 +152,8 @@ xpc_setup_infrastructure(struct xpc_part
 					  &part->local_openclose_args_base);
 	if (part->local_openclose_args == NULL) {
 		dev_err(xpc_chan, "can't get memory for local connect args\n");
-		kfree(part->remote_GPs_base);
-		part->remote_GPs = NULL;
-		kfree(part->local_GPs_base);
-		part->local_GPs = NULL;
-		kfree(part->channels);
-		part->channels = NULL;
-		return xpNoMemory;
+		retval = xpNoMemory;
+		goto out_3;
 	}
 
 	part->remote_openclose_args =
@@ -169,15 +161,8 @@ xpc_setup_infrastructure(struct xpc_part
 					  &part->remote_openclose_args_base);
 	if (part->remote_openclose_args == NULL) {
 		dev_err(xpc_chan, "can't get memory for remote connect args\n");
-		kfree(part->local_openclose_args_base);
-		part->local_openclose_args = NULL;
-		kfree(part->remote_GPs_base);
-		part->remote_GPs = NULL;
-		kfree(part->local_GPs_base);
-		part->local_GPs = NULL;
-		kfree(part->channels);
-		part->channels = NULL;
-		return xpNoMemory;
+		retval = xpNoMemory;
+		goto out_4;
 	}
 
 	xpc_initialize_channels(part, partid);
@@ -201,17 +186,8 @@ xpc_setup_infrastructure(struct xpc_part
 	if (ret != 0) {
 		dev_err(xpc_chan, "can't register NOTIFY IRQ handler, "
 			"errno=%d\n", -ret);
-		kfree(part->remote_openclose_args_base);
-		part->remote_openclose_args = NULL;
-		kfree(part->local_openclose_args_base);
-		part->local_openclose_args = NULL;
-		kfree(part->remote_GPs_base);
-		part->remote_GPs = NULL;
-		kfree(part->local_GPs_base);
-		part->local_GPs = NULL;
-		kfree(part->channels);
-		part->channels = NULL;
-		return xpLackOfResources;
+		retval = xpLackOfResources;
+		goto out_5;
 	}
 
 	/* Setup a timer to check for dropped IPIs */
@@ -246,6 +222,25 @@ xpc_setup_infrastructure(struct xpc_part
 	xpc_vars_part[partid].magic = XPC_VP_MAGIC1;
 
 	return xpSuccess;
+
+	/* setup of infrastructure failed */
+out_5:
+	kfree(part->remote_openclose_args_base);
+	part->remote_openclose_args = NULL;
+out_4:
+	kfree(part->local_openclose_args_base);
+	part->local_openclose_args = NULL;
+out_3:
+	kfree(part->remote_GPs_base);
+	part->remote_GPs = NULL;
+out_2:
+	kfree(part->local_GPs_base);
+	part->local_GPs = NULL;
+out_1:
+	kfree(part->channels);
+	part->channels = NULL;
+
+	return retval;
 }
 
 /*
@@ -266,9 +261,8 @@ xpc_pull_remote_cachelines(struct xpc_pa
 	DBUG_ON((u64)dst != L1_CACHE_ALIGN((u64)dst));
 	DBUG_ON(cnt != L1_CACHE_ALIGN(cnt));
 
-	if (part->act_state == XPC_P_AS_DEACTIVATING) {
+	if (part->act_state == XPC_P_AS_DEACTIVATING)
 		return part->reason;
-	}
 
 	ret = xp_remote_memcpy(dst, src, cnt);
 	if (ret != xpSuccess) {
@@ -358,18 +352,16 @@ xpc_pull_remote_vars_part(struct xpc_par
 		part->remote_IPI_nasid = pulled_entry->IPI_nasid;
 		part->remote_IPI_phys_cpuid = pulled_entry->IPI_phys_cpuid;
 
-		if (part->nchannels > pulled_entry->nchannels) {
+		if (part->nchannels > pulled_entry->nchannels)
 			part->nchannels = pulled_entry->nchannels;
-		}
 
 		/* let the other side know that we've pulled their variables */
 
 		xpc_vars_part[partid].magic = XPC_VP_MAGIC2;
 	}
 
-	if (pulled_entry->magic == XPC_VP_MAGIC1) {
+	if (pulled_entry->magic == XPC_VP_MAGIC1)
 		return xpRetry;
-	}
 
 	return xpSuccess;
 }
@@ -389,9 +381,10 @@ xpc_get_IPI_flags(struct xpc_partition *
 	 */
 
 	spin_lock_irqsave(&part->IPI_lock, irq_flags);
-	if ((IPI_amo = part->local_IPI_amo) != 0) {
+	IPI_amo = part->local_IPI_amo;
+	if (IPI_amo != 0)
 		part->local_IPI_amo = 0;
-	}
+
 	spin_unlock_irqrestore(&part->IPI_lock, irq_flags);
 
 	if (XPC_ANY_OPENCLOSE_IPI_FLAGS_SET(IPI_amo)) {
@@ -445,11 +438,9 @@ xpc_allocate_local_msgqueue(struct xpc_c
 		nbytes = nentries * ch->msg_size;
 		ch->local_msgqueue = xpc_kzalloc_cacheline_aligned(nbytes,
 								   GFP_KERNEL,
-								   &ch->
-								   local_msgqueue_base);
-		if (ch->local_msgqueue == NULL) {
+						      &ch->local_msgqueue_base);
+		if (ch->local_msgqueue == NULL)
 			continue;
-		}
 
 		nbytes = nentries * sizeof(struct xpc_notify);
 		ch->notify_queue = kzalloc(nbytes, GFP_KERNEL);
@@ -493,11 +484,9 @@ xpc_allocate_remote_msgqueue(struct xpc_
 		nbytes = nentries * ch->msg_size;
 		ch->remote_msgqueue = xpc_kzalloc_cacheline_aligned(nbytes,
 								    GFP_KERNEL,
-								    &ch->
-								    remote_msgqueue_base);
-		if (ch->remote_msgqueue == NULL) {
+						     &ch->remote_msgqueue_base);
+		if (ch->remote_msgqueue == NULL)
 			continue;
-		}
 
 		spin_lock_irqsave(&ch->lock, irq_flags);
 		if (nentries < ch->remote_nentries) {
@@ -529,11 +518,12 @@ xpc_allocate_msgqueues(struct xpc_channe
 
 	DBUG_ON(ch->flags & XPC_C_SETUP);
 
-	if ((ret = xpc_allocate_local_msgqueue(ch)) != xpSuccess) {
+	ret = xpc_allocate_local_msgqueue(ch);
+	if (ret != xpSuccess)
 		return ret;
-	}
 
-	if ((ret = xpc_allocate_remote_msgqueue(ch)) != xpSuccess) {
+	ret = xpc_allocate_remote_msgqueue(ch);
+	if (ret != xpSuccess) {
 		kfree(ch->local_msgqueue_base);
 		ch->local_msgqueue = NULL;
 		kfree(ch->notify_queue);
@@ -573,12 +563,11 @@ xpc_process_connect(struct xpc_channel *
 		ret = xpc_allocate_msgqueues(ch);
 		spin_lock_irqsave(&ch->lock, *irq_flags);
 
-		if (ret != xpSuccess) {
+		if (ret != xpSuccess)
 			XPC_DISCONNECT_CHANNEL(ch, ret, irq_flags);
-		}
-		if (ch->flags & (XPC_C_CONNECTED | XPC_C_DISCONNECTING)) {
+
+		if (ch->flags & (XPC_C_CONNECTED | XPC_C_DISCONNECTING))
 			return;
-		}
 
 		DBUG_ON(!(ch->flags & XPC_C_SETUP));
 		DBUG_ON(ch->local_msgqueue == NULL);
@@ -590,9 +579,8 @@ xpc_process_connect(struct xpc_channel *
 		xpc_IPI_send_openreply(ch, irq_flags);
 	}
 
-	if (!(ch->flags & XPC_C_ROPENREPLY)) {
+	if (!(ch->flags & XPC_C_ROPENREPLY))
 		return;
-	}
 
 	DBUG_ON(ch->remote_msgqueue_pa == 0);
 
@@ -711,9 +699,8 @@ xpc_process_disconnect(struct xpc_channe
 
 	DBUG_ON(!spin_is_locked(&ch->lock));
 
-	if (!(ch->flags & XPC_C_DISCONNECTING)) {
+	if (!(ch->flags & XPC_C_DISCONNECTING))
 		return;
-	}
 
 	DBUG_ON(!(ch->flags & XPC_C_CLOSEREQUEST));
 
@@ -728,26 +715,23 @@ xpc_process_disconnect(struct xpc_channe
 
 	if (part->act_state == XPC_P_AS_DEACTIVATING) {
 		/* can't proceed until the other side disengages from us */
-		if (xpc_partition_engaged(ch->partid)) {
+		if (xpc_partition_engaged(ch->partid))
 			return;
-		}
 
 	} else {
 
 		/* as long as the other side is up do the full protocol */
 
-		if (!(ch->flags & XPC_C_RCLOSEREQUEST)) {
+		if (!(ch->flags & XPC_C_RCLOSEREQUEST))
 			return;
-		}
 
 		if (!(ch->flags & XPC_C_CLOSEREPLY)) {
 			ch->flags |= XPC_C_CLOSEREPLY;
 			xpc_IPI_send_closereply(ch, irq_flags);
 		}
 
-		if (!(ch->flags & XPC_C_RCLOSEREPLY)) {
+		if (!(ch->flags & XPC_C_RCLOSEREPLY))
 			return;
-		}
 	}
 
 	/* wake those waiting for notify completion */
@@ -807,9 +791,10 @@ xpc_process_openclose_IPI(struct xpc_par
 
 	spin_lock_irqsave(&ch->lock, irq_flags);
 
-      again:
+again:
 
-	if ((ch->flags & XPC_C_DISCONNECTED) && (ch->flags & XPC_C_WDISCONNECT)) {
+	if ((ch->flags & XPC_C_DISCONNECTED) &&
+	    (ch->flags & XPC_C_WDISCONNECT)) {
 		/*
 		 * Delay processing IPI flags until thread waiting disconnect
 		 * has had a chance to see that the channel is disconnected.
@@ -882,11 +867,10 @@ xpc_process_openclose_IPI(struct xpc_par
 
 		if (!(ch->flags & XPC_C_DISCONNECTING)) {
 			reason = args->reason;
-			if (reason <= xpSuccess || reason > xpUnknownReason) {
+			if (reason <= xpSuccess || reason > xpUnknownReason)
 				reason = xpUnknownReason;
-			} else if (reason == xpUnregistering) {
+			else if (reason == xpUnregistering)
 				reason = xpOtherUnregistering;
-			}
 
 			XPC_DISCONNECT_CHANNEL(ch, reason, &irq_flags);
 
@@ -1060,9 +1044,8 @@ xpc_connect_channel(struct xpc_channel *
 	unsigned long irq_flags;
 	struct xpc_registration *registration = &xpc_registrations[ch->number];
 
-	if (mutex_trylock(&registration->mutex) == 0) {
+	if (mutex_trylock(&registration->mutex) == 0)
 		return xpRetry;
-	}
 
 	if (!XPC_CHANNEL_REGISTERED(ch->number)) {
 		mutex_unlock(&registration->mutex);
@@ -1151,7 +1134,7 @@ xpc_clear_local_msgqueue_flags(struct xp
 					 (get % ch->local_nentries) *
 					 ch->msg_size);
 		msg->flags = 0;
-	} while (++get < (volatile s64)ch->remote_GP.get);
+	} while (++get < ch->remote_GP.get);
 }
 
 /*
@@ -1169,7 +1152,7 @@ xpc_clear_remote_msgqueue_flags(struct x
 					 (put % ch->remote_nentries) *
 					 ch->msg_size);
 		msg->flags = 0;
-	} while (++put < (volatile s64)ch->remote_GP.put);
+	} while (++put < ch->remote_GP.put);
 }
 
 static void
@@ -1236,9 +1219,8 @@ xpc_process_msg_IPI(struct xpc_partition
 		 * If anyone was waiting for message queue entries to become
 		 * available, wake them up.
 		 */
-		if (atomic_read(&ch->n_on_msg_allocate_wq) > 0) {
+		if (atomic_read(&ch->n_on_msg_allocate_wq) > 0)
 			wake_up(&ch->msg_allocate_wq);
-		}
 	}
 
 	/*
@@ -1265,9 +1247,8 @@ xpc_process_msg_IPI(struct xpc_partition
 				"delivered=%d, partid=%d, channel=%d\n",
 				nmsgs_sent, ch->partid, ch->number);
 
-			if (ch->flags & XPC_C_CONNECTEDCALLOUT_MADE) {
+			if (ch->flags & XPC_C_CONNECTEDCALLOUT_MADE)
 				xpc_activate_kthreads(ch, nmsgs_sent);
-			}
 		}
 	}
 
@@ -1302,9 +1283,8 @@ xpc_process_channel_activity(struct xpc_
 
 		IPI_flags = XPC_GET_IPI_FLAGS(IPI_amo, ch_number);
 
-		if (XPC_ANY_OPENCLOSE_IPI_FLAGS_SET(IPI_flags)) {
+		if (XPC_ANY_OPENCLOSE_IPI_FLAGS_SET(IPI_flags))
 			xpc_process_openclose_IPI(part, ch_number, IPI_flags);
-		}
 
 		ch_flags = ch->flags;	/* need an atomic snapshot of flags */
 
@@ -1315,9 +1295,8 @@ xpc_process_channel_activity(struct xpc_
 			continue;
 		}
 
-		if (part->act_state == XPC_P_AS_DEACTIVATING) {
+		if (part->act_state == XPC_P_AS_DEACTIVATING)
 			continue;
-		}
 
 		if (!(ch_flags & XPC_C_CONNECTED)) {
 			if (!(ch_flags & XPC_C_OPENREQUEST)) {
@@ -1337,9 +1316,8 @@ xpc_process_channel_activity(struct xpc_
 		 * from the other partition.
 		 */
 
-		if (XPC_ANY_MSG_IPI_FLAGS_SET(IPI_flags)) {
+		if (XPC_ANY_MSG_IPI_FLAGS_SET(IPI_flags))
 			xpc_process_msg_IPI(part, ch_number);
-		}
 	}
 }
 
@@ -1552,9 +1530,9 @@ xpc_disconnect_channel(const int line, s
 
 	DBUG_ON(!spin_is_locked(&ch->lock));
 
-	if (ch->flags & (XPC_C_DISCONNECTING | XPC_C_DISCONNECTED)) {
+	if (ch->flags & (XPC_C_DISCONNECTING | XPC_C_DISCONNECTED))
 		return;
-	}
+
 	DBUG_ON(!(ch->flags & (XPC_C_CONNECTING | XPC_C_CONNECTED)));
 
 	dev_dbg(xpc_chan, "reason=%d, line=%d, partid=%d, channel=%d\n",
@@ -1570,9 +1548,8 @@ xpc_disconnect_channel(const int line, s
 
 	xpc_IPI_send_closerequest(ch, irq_flags);
 
-	if (channel_was_connected) {
+	if (channel_was_connected)
 		ch->flags |= XPC_C_WASCONNECTED;
-	}
 
 	spin_unlock_irqrestore(&ch->lock, *irq_flags);
 
@@ -1587,9 +1564,8 @@ xpc_disconnect_channel(const int line, s
 	}
 
 	/* wake those waiting to allocate an entry from the local msg queue */
-	if (atomic_read(&ch->n_on_msg_allocate_wq) > 0) {
+	if (atomic_read(&ch->n_on_msg_allocate_wq) > 0)
 		wake_up(&ch->msg_allocate_wq);
-	}
 
 	spin_lock_irqsave(&ch->lock, *irq_flags);
 }
@@ -1677,9 +1653,9 @@ xpc_allocate_msg(struct xpc_channel *ch,
 
 	while (1) {
 
-		put = (volatile s64)ch->w_local_GP.put;
-		if (put - (volatile s64)ch->w_remote_GP.get <
-		    ch->local_nentries) {
+		put = ch->w_local_GP.put;
+		rmb();	/* guarantee that .put loads before .get */
+		if (put - ch->w_remote_GP.get < ch->local_nentries) {
 
 			/* There are available message entries. We need to try
 			 * to secure one for ourselves. We'll do this by trying
@@ -1703,9 +1679,8 @@ xpc_allocate_msg(struct xpc_channel *ch,
 		 * that will cause the IPI handler to fetch the latest
 		 * GP values as if an IPI was sent by the other side.
 		 */
-		if (ret == xpTimeout) {
+		if (ret == xpTimeout)
 			xpc_IPI_send_local_msgrequest(ch);
-		}
 
 		if (flags & XPC_NOWAIT) {
 			xpc_msgqueue_deref(ch);
@@ -1764,9 +1739,8 @@ xpc_initiate_allocate(short partid, int 
 		ret = xpc_allocate_msg(&part->channels[ch_number], flags, &msg);
 		xpc_part_deref(part);
 
-		if (msg != NULL) {
+		if (msg != NULL)
 			*payload = &msg->payload;
-		}
 	}
 
 	return ret;
@@ -1787,17 +1761,15 @@ xpc_send_msgs(struct xpc_channel *ch, s6
 	while (1) {
 
 		while (1) {
-			if (put == (volatile s64)ch->w_local_GP.put) {
+			if (put == ch->w_local_GP.put)
 				break;
-			}
 
 			msg = (struct xpc_msg *)((u64)ch->local_msgqueue +
 						 (put % ch->local_nentries) *
 						 ch->msg_size);
 
-			if (!(msg->flags & XPC_M_READY)) {
+			if (!(msg->flags & XPC_M_READY))
 				break;
-			}
 
 			put++;
 		}
@@ -1810,7 +1782,7 @@ xpc_send_msgs(struct xpc_channel *ch, s6
 		if (cmpxchg_rel(&ch->local_GP->put, initial_put, put) !=
 		    initial_put) {
 			/* someone else beat us to it */
-			DBUG_ON((volatile s64)ch->local_GP->put < initial_put);
+			DBUG_ON(ch->local_GP->put < initial_put);
 			break;
 		}
 
@@ -1829,9 +1801,8 @@ xpc_send_msgs(struct xpc_channel *ch, s6
 		initial_put = put;
 	}
 
-	if (send_IPI) {
+	if (send_IPI)
 		xpc_IPI_send_msgrequest(ch);
-	}
 }
 
 /*
@@ -1905,9 +1876,8 @@ xpc_send_msg(struct xpc_channel *ch, str
 	/* see if the message is next in line to be sent, if so send it */
 
 	put = ch->local_GP->put;
-	if (put == msg_number) {
+	if (put == msg_number)
 		xpc_send_msgs(ch, put);
-	}
 
 	/* drop the reference grabbed in xpc_allocate_msg() */
 	xpc_msgqueue_deref(ch);
@@ -2024,10 +1994,8 @@ xpc_pull_remote_msg(struct xpc_channel *
 
 		msg_index = ch->next_msg_to_pull % ch->remote_nentries;
 
-		DBUG_ON(ch->next_msg_to_pull >=
-			(volatile s64)ch->w_remote_GP.put);
-		nmsgs = (volatile s64)ch->w_remote_GP.put -
-		    ch->next_msg_to_pull;
+		DBUG_ON(ch->next_msg_to_pull >= ch->w_remote_GP.put);
+		nmsgs = ch->w_remote_GP.put - ch->next_msg_to_pull;
 		if (msg_index + nmsgs > ch->remote_nentries) {
 			/* ignore the ones that wrap the msg queue for now */
 			nmsgs = ch->remote_nentries - msg_index;
@@ -2038,10 +2006,9 @@ xpc_pull_remote_msg(struct xpc_channel *
 		remote_msg = (struct xpc_msg *)(ch->remote_msgqueue_pa +
 						msg_offset);
 
-		if ((ret = xpc_pull_remote_cachelines(part, msg, remote_msg,
-						      nmsgs * ch->msg_size)) !=
-		    xpSuccess) {
-
+		ret = xpc_pull_remote_cachelines(part, msg, remote_msg, nmsgs *
+						 ch->msg_size);
+		if (ret != xpSuccess) {
 			dev_dbg(xpc_chan, "failed to pull %d msgs starting with"
 				" msg %" U64_ELL "d from partition %d, "
 				"channel=%d, ret=%d\n", nmsgs,
@@ -2054,8 +2021,6 @@ xpc_pull_remote_msg(struct xpc_channel *
 			return NULL;
 		}
 
-		mb();		/* >>> this may not be needed, we're not sure */
-
 		ch->next_msg_to_pull += nmsgs;
 	}
 
@@ -2078,14 +2043,13 @@ xpc_get_deliverable_msg(struct xpc_chann
 	s64 get;
 
 	do {
-		if ((volatile u32)ch->flags & XPC_C_DISCONNECTING) {
+		if (ch->flags & XPC_C_DISCONNECTING)
 			break;
-		}
 
-		get = (volatile s64)ch->w_local_GP.get;
-		if (get == (volatile s64)ch->w_remote_GP.put) {
+		get = ch->w_local_GP.get;
+		rmb();	/* guarantee that .get loads before .put */
+		if (get == ch->w_remote_GP.put)
 			break;
-		}
 
 		/* There are messages waiting to be pulled and delivered.
 		 * We need to try to secure one for ourselves. We'll do this
@@ -2125,7 +2089,8 @@ xpc_deliver_msg(struct xpc_channel *ch)
 {
 	struct xpc_msg *msg;
 
-	if ((msg = xpc_get_deliverable_msg(ch)) != NULL) {
+	msg = xpc_get_deliverable_msg(ch);
+	if (msg != NULL) {
 
 		/*
 		 * This ref is taken to protect the payload itself from being
@@ -2171,17 +2136,15 @@ xpc_acknowledge_msgs(struct xpc_channel 
 	while (1) {
 
 		while (1) {
-			if (get == (volatile s64)ch->w_local_GP.get) {
+			if (get == ch->w_local_GP.get)
 				break;
-			}
 
 			msg = (struct xpc_msg *)((u64)ch->remote_msgqueue +
 						 (get % ch->remote_nentries) *
 						 ch->msg_size);
 
-			if (!(msg->flags & XPC_M_DONE)) {
+			if (!(msg->flags & XPC_M_DONE))
 				break;
-			}
 
 			msg_flags |= msg->flags;
 			get++;
@@ -2195,7 +2158,7 @@ xpc_acknowledge_msgs(struct xpc_channel 
 		if (cmpxchg_rel(&ch->local_GP->get, initial_get, get) !=
 		    initial_get) {
 			/* someone else beat us to it */
-			DBUG_ON((volatile s64)ch->local_GP->get <= initial_get);
+			DBUG_ON(ch->local_GP->get <= initial_get);
 			break;
 		}
 
@@ -2214,9 +2177,8 @@ xpc_acknowledge_msgs(struct xpc_channel 
 		initial_get = get;
 	}
 
-	if (send_IPI) {
+	if (send_IPI)
 		xpc_IPI_send_msgrequest(ch);
-	}
 }
 
 /*
@@ -2270,9 +2232,8 @@ xpc_initiate_received(short partid, int 
 	 * been delivered.
 	 */
 	get = ch->local_GP->get;
-	if (get == msg_number) {
+	if (get == msg_number)
 		xpc_acknowledge_msgs(ch, get, msg->flags);
-	}
 
 	/* the call to xpc_msgqueue_ref() was done by xpc_deliver_msg()  */
 	xpc_msgqueue_deref(ch);
Index: linux-2.6/drivers/misc/xp/xpc.h
===================================================================
--- linux-2.6.orig/drivers/misc/xp/xpc.h	2008-03-25 07:10:15.693148179 -0500
+++ linux-2.6/drivers/misc/xp/xpc.h	2008-03-25 07:10:17.809412207 -0500
@@ -109,16 +109,16 @@ struct xpc_rsvd_page {
 	u8 SAL_partid;		/* SAL: partition ID */
 	u8 version;
 	u8 pad[6];
-	volatile u64 vars_pa;	/* physical address of struct xpc_vars */
+	u64 vars_pa;		/* physical address of struct xpc_vars */
 	struct timespec stamp;	/* time when reserved page was setup by XPC */
 	u64 pad2[9];		/* align to last u64 in cacheline */
 	u64 SAL_nasids_size;	/* SAL: size of each nasid mask in bytes */
 };
 
-#define XPC_RP_VERSION _XPC_VERSION(2,0)	/* version 2.0 of the reserved page */
+#define XPC_RP_VERSION _XPC_VERSION(2, 0) /* version 2.0 of the reserved page */
 
 #define XPC_SUPPORTS_RP_STAMP(_version) \
-			(_version >= _XPC_VERSION(1,1))
+			(_version >= _XPC_VERSION(1, 1))
 
 /*
  * compare stamps - the return value is:
@@ -132,9 +132,10 @@ xpc_compare_stamps(struct timespec *stam
 {
 	int ret;
 
-	if ((ret = stamp1->tv_sec - stamp2->tv_sec) == 0) {
+	ret = stamp1->tv_sec - stamp2->tv_sec;
+	if (ret == 0)
 		ret = stamp1->tv_nsec - stamp2->tv_nsec;
-	}
+
 	return ret;
 }
 
@@ -166,10 +167,10 @@ struct xpc_vars {
 	u64 heartbeating_to_mask[BITS_TO_LONGS(XP_MAX_NPARTITIONS)];
 };
 
-#define XPC_V_VERSION _XPC_VERSION(4,0)	/* version 4.0 of the cross vars */
+#define XPC_V_VERSION _XPC_VERSION(4, 0)    /* version 4.0 of the cross vars */
 
 #define XPC_SUPPORTS_DISENGAGE_REQUEST(_version) \
-			(_version >= _XPC_VERSION(3,1))
+			(_version >= _XPC_VERSION(3, 1))
 
 static inline int
 xpc_hb_allowed(short partid, struct xpc_vars *vars)
@@ -267,7 +268,7 @@ xpc_number_of_amos(int npartitions)
  * occupies half a cacheline.
  */
 struct xpc_vars_part {
-	volatile u64 magic;
+	u64 magic;
 
 	u64 openclose_args_pa;	/* physical address of open and close args */
 	u64 GPs_pa;		/* physical address of Get/Put values */
@@ -290,8 +291,8 @@ struct xpc_vars_part {
  * MAGIC2 indicates that this partition has pulled the remote partititions
  * per partition variables that pertain to this partition.
  */
-#define XPC_VP_MAGIC1	0x0053524156435058L	/* 'XPCVARS\0'L (little endian) */
-#define XPC_VP_MAGIC2	0x0073726176435058L	/* 'XPCvars\0'L (little endian) */
+#define XPC_VP_MAGIC1	0x0053524156435058L   /* 'XPCVARS\0'L (little endian) */
+#define XPC_VP_MAGIC2	0x0073726176435058L   /* 'XPCvars\0'L (little endian) */
 
 /* the reserved page sizes and offsets */
 
@@ -301,9 +302,10 @@ struct xpc_vars_part {
 #define XPC_RP_PART_NASIDS(_rp) (u64 *)((u8 *)(_rp) + XPC_RP_HEADER_SIZE)
 #define XPC_RP_MACH_NASIDS(_rp) (XPC_RP_PART_NASIDS(_rp) + \
 				 xp_nasid_mask_words())
-#define XPC_RP_VARS(_rp)	(struct xpc_vars *)(XPC_RP_MACH_NASIDS(_rp) + \
-				 xp_nasid_mask_words())
-#define XPC_RP_VARS_PART(_rp)	(struct xpc_vars_part *)((u8 *)XPC_RP_VARS(_rp) + XPC_RP_VARS_SIZE)
+#define XPC_RP_VARS(_rp)	((struct xpc_vars *)(XPC_RP_MACH_NASIDS(_rp) + \
+				xp_nasid_mask_words()))
+#define XPC_RP_VARS_PART(_rp)	((struct xpc_vars_part *) \
+				((u8 *)XPC_RP_VARS(_rp) + XPC_RP_VARS_SIZE))
 
 /*
  * Functions registered by add_timer() or called by kernel_thread() only
@@ -322,8 +324,8 @@ struct xpc_vars_part {
  * Define a Get/Put value pair (pointers) used with a message queue.
  */
 struct xpc_gp {
-	volatile s64 get;	/* Get value */
-	volatile s64 put;	/* Put value */
+	s64 get;		/* Get value */
+	s64 put;		/* Put value */
 };
 
 #define XPC_GP_SIZE \
@@ -360,7 +362,7 @@ struct xpc_openclose_args {
  * and consumed by the intended recipient.
  */
 struct xpc_notify {
-	volatile u8 type;	/* type of notification */
+	u8 type;		/* type of notification */
 
 	/* the following two fields are only used if type == XPC_N_CALL */
 	xpc_notify_func func;	/* user's notify function */
@@ -466,10 +468,10 @@ struct xpc_channel {
 	void *local_msgqueue_base;	/* base address of kmalloc'd space */
 	struct xpc_msg *local_msgqueue;	/* local message queue */
 	void *remote_msgqueue_base;	/* base address of kmalloc'd space */
-	struct xpc_msg *remote_msgqueue;	/* cached copy of remote partition's */
-	/* local message queue */
+	struct xpc_msg *remote_msgqueue; /* cached copy of remote partition's */
+					 /* local message queue */
 	u64 remote_msgqueue_pa;	/* phys addr of remote partition's */
-	/* local message queue */
+				/* local message queue */
 
 	atomic_t references;	/* #of external references to queues */
 
@@ -477,21 +479,21 @@ struct xpc_channel {
 	wait_queue_head_t msg_allocate_wq;	/* msg allocation wait queue */
 
 	u8 delayed_IPI_flags;	/* IPI flags received, but delayed */
-	/* action until channel disconnected */
+				/* action until channel disconnected */
 
 	/* queue of msg senders who want to be notified when msg received */
 
 	atomic_t n_to_notify;	/* #of msg senders to notify */
-	struct xpc_notify *notify_queue;	/* notify queue for messages sent */
+	struct xpc_notify *notify_queue;    /* notify queue for messages sent */
 
 	xpc_channel_func func;	/* user's channel function */
 	void *key;		/* pointer to user's key */
 
 	struct mutex msg_to_pull_mutex;	/* next msg to pull serialization */
-	struct completion wdisconnect_wait;	/* wait for channel disconnect */
+	struct completion wdisconnect_wait;    /* wait for channel disconnect */
 
-	struct xpc_openclose_args *local_openclose_args;	/* args passed on */
-	/* opening or closing of channel */
+	struct xpc_openclose_args *local_openclose_args;    /* args passed on */
+					     /* opening or closing of channel */
 
 	/* various flavors of local and remote Get/Put values */
 
@@ -519,28 +521,28 @@ struct xpc_channel {
 
 #define	XPC_C_ROPENREPLY	0x00000002	/* remote open channel reply */
 #define	XPC_C_OPENREPLY		0x00000004	/* local open channel reply */
-#define	XPC_C_ROPENREQUEST	0x00000008	/* remote open channel request */
+#define	XPC_C_ROPENREQUEST	0x00000008     /* remote open channel request */
 #define	XPC_C_OPENREQUEST	0x00000010	/* local open channel request */
 
-#define	XPC_C_SETUP		0x00000020	/* channel's msgqueues are alloc'd */
-#define	XPC_C_CONNECTEDCALLOUT	0x00000040	/* connected callout initiated */
+#define	XPC_C_SETUP		0x00000020 /* channel's msgqueues are alloc'd */
+#define	XPC_C_CONNECTEDCALLOUT	0x00000040     /* connected callout initiated */
 #define	XPC_C_CONNECTEDCALLOUT_MADE \
-				0x00000080	/* connected callout completed */
+				0x00000080     /* connected callout completed */
 #define	XPC_C_CONNECTED		0x00000100	/* local channel is connected */
 #define	XPC_C_CONNECTING	0x00000200	/* channel is being connected */
 
 #define	XPC_C_RCLOSEREPLY	0x00000400	/* remote close channel reply */
 #define	XPC_C_CLOSEREPLY	0x00000800	/* local close channel reply */
-#define	XPC_C_RCLOSEREQUEST	0x00001000	/* remote close channel request */
-#define	XPC_C_CLOSEREQUEST	0x00002000	/* local close channel request */
+#define	XPC_C_RCLOSEREQUEST	0x00001000    /* remote close channel request */
+#define	XPC_C_CLOSEREQUEST	0x00002000     /* local close channel request */
 
 #define	XPC_C_DISCONNECTED	0x00004000	/* channel is disconnected */
-#define	XPC_C_DISCONNECTING	0x00008000	/* channel is being disconnected */
+#define	XPC_C_DISCONNECTING	0x00008000   /* channel is being disconnected */
 #define	XPC_C_DISCONNECTINGCALLOUT \
-				0x00010000	/* disconnecting callout initiated */
+				0x00010000 /* disconnecting callout initiated */
 #define	XPC_C_DISCONNECTINGCALLOUT_MADE \
-				0x00020000	/* disconnecting callout completed */
-#define	XPC_C_WDISCONNECT	0x00040000	/* waiting for channel disconnect */
+				0x00020000 /* disconnecting callout completed */
+#define	XPC_C_WDISCONNECT	0x00040000  /* waiting for channel disconnect */
 
 /*
  * Manages channels on a partition basis. There is one of these structures
@@ -554,7 +556,7 @@ struct xpc_partition {
 	u8 remote_rp_version;	/* version# of partition's rsvd pg */
 	short remote_npartitions;	/* value of XPC_NPARTITIONS */
 	u32 flags;		/* general flags */
-	struct timespec remote_rp_stamp;	/* time when rsvd pg was initialized */
+	struct timespec remote_rp_stamp; /* time when rsvd pg was initialized */
 	u64 remote_rp_pa;	/* phys addr of partition's rsvd pg */
 	u64 remote_vars_pa;	/* phys addr of partition's vars */
 	u64 remote_vars_part_pa;	/* phys addr of partition's vars part */
@@ -564,7 +566,7 @@ struct xpc_partition {
 	int remote_act_phys_cpuid;	/* active part's act/deact phys cpuid */
 	u32 act_IRQ_rcvd;	/* IRQs since activation */
 	spinlock_t lock;	/* protect updating of act_state and */
-	/* the general flags */
+				/* the general flags */
 	u8 act_state;		/* from XPC HB viewpoint */
 	u8 remote_vars_version;	/* version# of partition's vars */
 	enum xp_retval reason;	/* reason partition is deactivating */
@@ -576,7 +578,7 @@ struct xpc_partition {
 
 	/* XPC infrastructure referencing and teardown control */
 
-	volatile u8 setup_state;	/* infrastructure setup state */
+	u8 setup_state;		/* infrastructure setup state */
 	wait_queue_head_t teardown_wq;	/* kthread waiting to teardown infra */
 	atomic_t references;	/* #of references to infrastructure */
 
@@ -588,25 +590,25 @@ struct xpc_partition {
 	 */
 
 	u8 nchannels;		/* #of defined channels supported */
-	atomic_t nchannels_active;	/* #of channels that are not DISCONNECTED */
-	atomic_t nchannels_engaged;	/* #of channels engaged with remote part */
+	atomic_t nchannels_active;  /* #of channels that are not DISCONNECTED */
+	atomic_t nchannels_engaged;  /* #of channels engaged with remote part */
 	struct xpc_channel *channels;	/* array of channel structures */
 
 	void *local_GPs_base;	/* base address of kmalloc'd space */
 	struct xpc_gp *local_GPs;	/* local Get/Put values */
 	void *remote_GPs_base;	/* base address of kmalloc'd space */
-	struct xpc_gp *remote_GPs;	/* copy of remote partition's local Get/Put */
-	/* values */
+	struct xpc_gp *remote_GPs;/* copy of remote partition's local Get/Put */
+				  /* values */
 	u64 remote_GPs_pa;	/* phys address of remote partition's local */
-	/* Get/Put values */
+				/* Get/Put values */
 
 	/* fields used to pass args when opening or closing a channel */
 
-	void *local_openclose_args_base;	/* base address of kmalloc'd space */
-	struct xpc_openclose_args *local_openclose_args;	/* local's args */
-	void *remote_openclose_args_base;	/* base address of kmalloc'd space */
-	struct xpc_openclose_args *remote_openclose_args;	/* copy of remote's */
-	/* args */
+	void *local_openclose_args_base;   /* base address of kmalloc'd space */
+	struct xpc_openclose_args *local_openclose_args;      /* local's args */
+	void *remote_openclose_args_base;  /* base address of kmalloc'd space */
+	struct xpc_openclose_args *remote_openclose_args; /* copy of remote's */
+							  /* args */
 	u64 remote_openclose_args_pa;	/* phys addr of remote's args */
 
 	/* IPI sending, receiving and handling related fields */
@@ -631,7 +633,7 @@ struct xpc_partition {
 
 /* struct xpc_partition flags */
 
-#define	XPC_P_RAMOSREGISTERED	0x00000001	/* remote AMOs were registered */
+#define	XPC_P_RAMOSREGISTERED	0x00000001    /* remote AMOs were registered */
 
 /* struct xpc_partition act_state values (for XPC HB) */
 
@@ -725,9 +727,8 @@ extern void xpc_teardown_infrastructure(
 static inline void
 xpc_wakeup_channel_mgr(struct xpc_partition *part)
 {
-	if (atomic_inc_return(&part->channel_mgr_requests) == 1) {
+	if (atomic_inc_return(&part->channel_mgr_requests) == 1)
 		wake_up(&part->channel_mgr_wq);
-	}
 }
 
 /*
@@ -746,9 +747,8 @@ xpc_msgqueue_deref(struct xpc_channel *c
 	s32 refs = atomic_dec_return(&ch->references);
 
 	DBUG_ON(refs < 0);
-	if (refs == 0) {
+	if (refs == 0)
 		xpc_wakeup_channel_mgr(&xpc_partitions[ch->partid]);
-	}
 }
 
 #define XPC_DISCONNECT_CHANNEL(_ch, _reason, _irqflgs) \
@@ -764,9 +764,8 @@ xpc_part_deref(struct xpc_partition *par
 	s32 refs = atomic_dec_return(&part->references);
 
 	DBUG_ON(refs < 0);
-	if (refs == 0 && part->setup_state == XPC_P_SS_WTEARDOWN) {
+	if (refs == 0 && part->setup_state == XPC_P_SS_WTEARDOWN)
 		wake_up(&part->teardown_wq);
-	}
 }
 
 static inline int
@@ -776,9 +775,9 @@ xpc_part_ref(struct xpc_partition *part)
 
 	atomic_inc(&part->references);
 	setup = (part->setup_state == XPC_P_SS_SETUP);
-	if (!setup) {
+	if (!setup)
 		xpc_part_deref(part);
-	}
+
 	return setup;
 }
 
@@ -955,7 +954,7 @@ xpc_activate_IRQ_send(u64 amos_page_pa, 
 					BIT_MASK(from_nasid / 2),
 					remote_amo, to_nasid,
 					to_phys_cpuid, SGI_XPC_ACTIVATE);
-	BUG_ON(!remote_amo && ret != xpSuccess);	/* should never happen */
+	BUG_ON(!remote_amo && ret != xpSuccess);      /* should never happen */
 }
 
 static inline void
@@ -1150,9 +1149,8 @@ xpc_check_for_channel_activity(struct xp
 
 	ret = xp_get_amo(part->local_IPI_amo_va, XP_AMO_CLEAR, &IPI_amo);
 	BUG_ON(ret != xpSuccess);	/* should never happen */
-	if (IPI_amo == 0) {
+	if (IPI_amo == 0)
 		return;
-	}
 
 	spin_lock_irqsave(&part->IPI_lock, irq_flags);
 	part->local_IPI_amo |= IPI_amo;
Index: linux-2.6/drivers/misc/xp/xp_sn2.c
===================================================================
--- linux-2.6.orig/drivers/misc/xp/xp_sn2.c	2008-03-25 07:10:15.693148179 -0500
+++ linux-2.6/drivers/misc/xp/xp_sn2.c	2008-03-25 07:10:17.829414703 -0500
@@ -22,8 +22,6 @@
 #include <asm/sn/sn_sal.h>
 #include "xp.h"
 
-extern struct device *xp;
-
 /*
  * Register a nofault code region which performs a cross-partition PIO read.
  * If the PIO read times out, the MCA handler will consume the error and
@@ -187,10 +185,10 @@ xp_set_amo_sn2(u64 *amo_va, int op, u64 
 		 * it until the heartbeat times out.
 		 */
 		if (xp_nofault_PIOR((u64 *)GLOBAL_MMR_ADDR(NASID_GET(amo_va),
-							   xp_nofault_PIOR_target))
-		    != 0)
+							xp_nofault_PIOR_target))
+		    != 0) {
 			ret = xpPioReadError;
-
+		}
 		local_irq_restore(irq_flags);
 	}
 
@@ -226,10 +224,10 @@ xp_set_amo_with_interrupt_sn2(u64 *amo_v
 		 * it until the heartbeat times out.
 		 */
 		if (xp_nofault_PIOR((u64 *)GLOBAL_MMR_ADDR(NASID_GET(amo_va),
-							   xp_nofault_PIOR_target))
-		    != 0)
+							xp_nofault_PIOR_target))
+		    != 0) {
 			ret = xpPioReadError;
-
+		}
 		local_irq_restore(irq_flags);
 	}
 
@@ -323,10 +321,10 @@ xp_change_memprotect_shub_wars_1_1_sn2(i
 			/* save current protection values */
 			xpc_prot_vec[node] =
 			    (u64)HUB_L((u64 *)GLOBAL_MMR_ADDR(nasid,
-							      SH1_MD_DQLP_MMR_DIR_PRIVEC0));
+						  SH1_MD_DQLP_MMR_DIR_PRIVEC0));
 			/* open up everything */
 			HUB_S((u64 *)GLOBAL_MMR_ADDR(nasid,
-						     SH1_MD_DQLP_MMR_DIR_PRIVEC0),
+						   SH1_MD_DQLP_MMR_DIR_PRIVEC0),
 			      -1UL);
 			HUB_S((u64 *)
 			      GLOBAL_MMR_ADDR(nasid,
@@ -338,15 +336,16 @@ xp_change_memprotect_shub_wars_1_1_sn2(i
 			nasid = cnodeid_to_nasid(node);
 			/* restore original protection values */
 			HUB_S((u64 *)GLOBAL_MMR_ADDR(nasid,
-						     SH1_MD_DQLP_MMR_DIR_PRIVEC0),
+						   SH1_MD_DQLP_MMR_DIR_PRIVEC0),
 			      xpc_prot_vec[node]);
 			HUB_S((u64 *)
 			      GLOBAL_MMR_ADDR(nasid,
 					      SH1_MD_DQRP_MMR_DIR_PRIVEC0),
 			      xpc_prot_vec[node]);
 		}
-	} else
+	} else {
 		BUG();
+	}
 }
 
 /* SH_IPI_ACCESS shub register value on startup */
Index: linux-2.6/drivers/misc/xp/xp_main.c
===================================================================
--- linux-2.6.orig/drivers/misc/xp/xp_main.c	2008-03-25 07:10:15.697148678 -0500
+++ linux-2.6/drivers/misc/xp/xp_main.c	2008-03-25 07:10:17.845416699 -0500
@@ -38,38 +38,58 @@ struct device *xp = &xp_dbg_subname;
 u64 xp_nofault_PIOR_target;
 
 short xp_partition_id;
+EXPORT_SYMBOL_GPL(xp_partition_id);
 u8 xp_region_size;
+EXPORT_SYMBOL_GPL(xp_region_size);
 unsigned long xp_rtc_cycles_per_second;
+EXPORT_SYMBOL_GPL(xp_rtc_cycles_per_second);
 
 enum xp_retval (*xp_remote_memcpy) (void *dst, const void *src, size_t len);
+EXPORT_SYMBOL_GPL(xp_remote_memcpy);
 
 enum xp_retval (*xp_register_remote_amos) (u64 paddr, size_t len);
+EXPORT_SYMBOL_GPL(xp_register_remote_amos);
 enum xp_retval (*xp_unregister_remote_amos) (u64 paddr, size_t len);
+EXPORT_SYMBOL_GPL(xp_unregister_remote_amos);
 
 int xp_sizeof_nasid_mask;
+EXPORT_SYMBOL_GPL(xp_sizeof_nasid_mask);
 int xp_sizeof_amo;
+EXPORT_SYMBOL_GPL(xp_sizeof_amo);
 
 u64 *(*xp_alloc_amos) (int n_amos);
+EXPORT_SYMBOL_GPL(xp_alloc_amos);
 void (*xp_free_amos) (u64 *amos_page, int n_amos);
+EXPORT_SYMBOL_GPL(xp_free_amos);
 
 enum xp_retval (*xp_set_amo) (u64 *amo_va, int op, u64 operand, int remote);
+EXPORT_SYMBOL_GPL(xp_set_amo);
 enum xp_retval (*xp_set_amo_with_interrupt) (u64 *amo_va, int op, u64 operand,
 					     int remote, int nasid,
 					     int phys_cpuid, int vector);
+EXPORT_SYMBOL_GPL(xp_set_amo_with_interrupt);
 
 enum xp_retval (*xp_get_amo) (u64 *amo_va, int op, u64 *amo_value_addr);
+EXPORT_SYMBOL_GPL(xp_get_amo);
 
 enum xp_retval (*xp_get_partition_rsvd_page_pa) (u64 buf, u64 *cookie,
 						 u64 *paddr, size_t *len);
+EXPORT_SYMBOL_GPL(xp_get_partition_rsvd_page_pa);
 
 enum xp_retval (*xp_change_memprotect) (u64 paddr, size_t len, int request,
 					u64 *nasid_array);
+EXPORT_SYMBOL_GPL(xp_change_memprotect);
 void (*xp_change_memprotect_shub_wars_1_1) (int request);
+EXPORT_SYMBOL_GPL(xp_change_memprotect_shub_wars_1_1);
 void (*xp_allow_IPI_ops) (void);
+EXPORT_SYMBOL_GPL(xp_allow_IPI_ops);
 void (*xp_disallow_IPI_ops) (void);
+EXPORT_SYMBOL_GPL(xp_disallow_IPI_ops);
 
 int (*xp_cpu_to_nasid) (int cpuid);
+EXPORT_SYMBOL_GPL(xp_cpu_to_nasid);
 int (*xp_node_to_nasid) (int nid);
+EXPORT_SYMBOL_GPL(xp_node_to_nasid);
 
 /*
  * Initialize the XPC interface to indicate that XPC isn't loaded.
@@ -90,6 +110,7 @@ struct xpc_interface xpc_interface = {
 	(void (*)(short, int, void *))xpc_notloaded,
 	(enum xp_retval(*)(short, void *))xpc_notloaded
 };
+EXPORT_SYMBOL_GPL(xpc_interface);
 
 /*
  * XPC calls this when it (the XPC module) has been loaded.
@@ -112,6 +133,7 @@ xpc_set_interface(void (*connect) (int),
 	xpc_interface.received = received;
 	xpc_interface.partid_to_nasids = partid_to_nasids;
 }
+EXPORT_SYMBOL_GPL(xpc_set_interface);
 
 /*
  * XPC calls this when it (the XPC module) is being unloaded.
@@ -133,12 +155,14 @@ xpc_clear_interface(void)
 	xpc_interface.partid_to_nasids = (enum xp_retval(*)(short, void *))
 	    xpc_notloaded;
 }
+EXPORT_SYMBOL_GPL(xpc_clear_interface);
 
 /*
  * xpc_registrations[] keeps track of xpc_connect()'s done by the kernel-level
  * users of XPC.
  */
 struct xpc_registration xpc_registrations[XPC_NCHANNELS];
+EXPORT_SYMBOL_GPL(xpc_registrations);
 
 /*
  * Register for automatic establishment of a channel connection whenever
@@ -177,9 +201,8 @@ xpc_connect(int ch_number, xpc_channel_f
 
 	registration = &xpc_registrations[ch_number];
 
-	if (mutex_lock_interruptible(&registration->mutex) != 0) {
+	if (mutex_lock_interruptible(&registration->mutex) != 0)
 		return xpInterrupted;
-	}
 
 	/* if XPC_CHANNEL_REGISTERED(ch_number) */
 	if (registration->func != NULL) {
@@ -201,6 +224,7 @@ xpc_connect(int ch_number, xpc_channel_f
 
 	return xpSuccess;
 }
+EXPORT_SYMBOL_GPL(xpc_connect);
 
 /*
  * Remove the registration for automatic connection of the specified channel
@@ -251,9 +275,7 @@ xpc_disconnect(int ch_number)
 
 	return;
 }
-
-extern enum xp_retval xp_init_sn2(void);
-extern enum xp_retval xp_init_uv(void);
+EXPORT_SYMBOL_GPL(xpc_disconnect);
 
 int __init
 xp_init(void)
@@ -268,23 +290,18 @@ xp_init(void)
 	else
 		ret = xpUnsupported;
 
-	if (ret != xpSuccess) {
+	if (ret != xpSuccess)
 		return -ENODEV;
-	}
 
 	/* initialize the connection registration mutex */
-	for (ch_number = 0; ch_number < XPC_NCHANNELS; ch_number++) {
+	for (ch_number = 0; ch_number < XPC_NCHANNELS; ch_number++)
 		mutex_init(&xpc_registrations[ch_number].mutex);
-	}
 
 	return 0;
 }
 
 module_init(xp_init);
 
-extern void xp_exit_sn2(void);
-extern void xp_exit_uv(void);
-
 void __exit
 xp_exit(void)
 {
@@ -299,30 +316,3 @@ module_exit(xp_exit);
 MODULE_AUTHOR("Silicon Graphics, Inc.");
 MODULE_DESCRIPTION("Cross Partition (XP) base");
 MODULE_LICENSE("GPL");
-
-EXPORT_SYMBOL(xp_partition_id);
-EXPORT_SYMBOL(xp_region_size);
-EXPORT_SYMBOL(xp_rtc_cycles_per_second);
-EXPORT_SYMBOL(xp_remote_memcpy);
-EXPORT_SYMBOL(xp_register_remote_amos);
-EXPORT_SYMBOL(xp_unregister_remote_amos);
-EXPORT_SYMBOL(xp_sizeof_nasid_mask);
-EXPORT_SYMBOL(xp_sizeof_amo);
-EXPORT_SYMBOL(xp_alloc_amos);
-EXPORT_SYMBOL(xp_free_amos);
-EXPORT_SYMBOL(xp_set_amo);
-EXPORT_SYMBOL(xp_set_amo_with_interrupt);
-EXPORT_SYMBOL(xp_get_amo);
-EXPORT_SYMBOL(xp_get_partition_rsvd_page_pa);
-EXPORT_SYMBOL(xp_change_memprotect);
-EXPORT_SYMBOL(xp_change_memprotect_shub_wars_1_1);
-EXPORT_SYMBOL(xp_allow_IPI_ops);
-EXPORT_SYMBOL(xp_disallow_IPI_ops);
-EXPORT_SYMBOL(xp_cpu_to_nasid);
-EXPORT_SYMBOL(xp_node_to_nasid);
-EXPORT_SYMBOL(xpc_registrations);
-EXPORT_SYMBOL(xpc_interface);
-EXPORT_SYMBOL(xpc_clear_interface);
-EXPORT_SYMBOL(xpc_set_interface);
-EXPORT_SYMBOL(xpc_connect);
-EXPORT_SYMBOL(xpc_disconnect);
Index: linux-2.6/drivers/misc/xp/xp_uv.c
===================================================================
--- linux-2.6.orig/drivers/misc/xp/xp_uv.c	2008-03-25 07:10:15.697148678 -0500
+++ linux-2.6/drivers/misc/xp/xp_uv.c	2008-03-25 07:10:17.861418696 -0500
@@ -18,8 +18,6 @@
 #include <linux/device.h>
 #include "xp.h"
 
-extern struct device *xp;
-
 static enum xp_retval
 xp_register_nofault_code_uv(void)
 {

