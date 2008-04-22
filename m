From: Dean Nelson <dcn@sgi.com>
Date: Tue, 22 Apr 2008 19:50:17 +0000
Subject: [Patch 4/4] run drivers/misc/sgi-xp through scripts/checkpatch.pl -v4
Message-Id: <20080422195017.GD14628@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080422194459.GB13086@sgi.com>
In-Reply-To: <20080422194459.GB13086@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com
Cc: jes@sgi.com, gregkh@suse.de, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Addressed issues raised by scripts/checkpatch.pl. Removed unnecessary curly
braces. Eliminated uses of volatiles and use of kernel_thread() and daemonize().

Signed-off-by: Dean Nelson <dcn@sgi.com>

---

The following warning reported by checkpatch.pl I can't do anything about.
The symbol being exported resides in drivers/misc/sgi-xp/xp_nofault.S.

WARNING: EXPORT_SYMBOL(foo); should immediately follow its function/variable
#30: FILE: misc/sgi-xp/xp_main.c:30:
+EXPORT_SYMBOL_GPL(xp_nofault_PIOR);

 drivers/misc/sgi-xp/xp.h            |    6 -
 drivers/misc/sgi-xp/xp_main.c       |   41 +++---
 drivers/misc/sgi-xp/xpc.h           |  124 +++++++++-----------
 drivers/misc/sgi-xp/xpc_channel.c   |  192 ++++++++++++--------------------
 drivers/misc/sgi-xp/xpc_main.c      |  167 +++++++++------------------
 drivers/misc/sgi-xp/xpc_partition.c |   99 +++++++---------
 drivers/misc/sgi-xp/xpnet.c         |   30 ++---
 7 files changed, 268 insertions(+), 391 deletions(-)

Index: linux-2.6/drivers/misc/sgi-xp/xp.h
=================================--- linux-2.6.orig/drivers/misc/sgi-xp/xp.h	2008-04-22 11:46:34.625831202 -0500
+++ linux-2.6/drivers/misc/sgi-xp/xp.h	2008-04-22 11:48:06.701227831 -0500
@@ -79,9 +79,9 @@ xp_bte_copy(u64 src, u64 vdst, u64 len, 
 
 	ret = bte_copy(src, pdst, len, mode, notification);
 	if ((ret != BTE_SUCCESS) && BTE_ERROR_RETRY(ret)) {
-		if (!in_interrupt()) {
+		if (!in_interrupt())
 			cond_resched();
-		}
+
 		ret = bte_copy(src, pdst, len, mode, notification);
 	}
 
@@ -255,7 +255,7 @@ enum xpc_retval {
 				/* 115: BTE end */
 	xpcBteSh2End = xpcBteSh2Start + BTEFAIL_SH2_ALL,
 
-	xpcUnknownReason	/* 116: unknown reason -- must be last in list */
+	xpcUnknownReason	/* 116: unknown reason - must be last in enum */
 };
 
 /*
Index: linux-2.6/drivers/misc/sgi-xp/xp_main.c
=================================--- linux-2.6.orig/drivers/misc/sgi-xp/xp_main.c	2008-04-22 11:46:34.625831202 -0500
+++ linux-2.6/drivers/misc/sgi-xp/xp_main.c	2008-04-22 12:19:47.481315796 -0500
@@ -23,15 +23,21 @@
 #include "xp.h"
 
 /*
- * Target of nofault PIO read.
+ * The export of xp_nofault_PIOR needs to happen here since it is defined
+ * in drivers/misc/sgi-xp/xp_nofault.S. The target of the nofault read is
+ * defined here.
  */
+EXPORT_SYMBOL_GPL(xp_nofault_PIOR);
+
 u64 xp_nofault_PIOR_target;
+EXPORT_SYMBOL_GPL(xp_nofault_PIOR_target);
 
 /*
  * xpc_registrations[] keeps track of xpc_connect()'s done by the kernel-level
  * users of XPC.
  */
 struct xpc_registration xpc_registrations[XPC_NCHANNELS];
+EXPORT_SYMBOL_GPL(xpc_registrations);
 
 /*
  * Initialize the XPC interface to indicate that XPC isn't loaded.
@@ -52,6 +58,7 @@ struct xpc_interface xpc_interface = {
 	(void (*)(partid_t, int, void *))xpc_notloaded,
 	(enum xpc_retval(*)(partid_t, void *))xpc_notloaded
 };
+EXPORT_SYMBOL_GPL(xpc_interface);
 
 /*
  * XPC calls this when it (the XPC module) has been loaded.
@@ -74,6 +81,7 @@ xpc_set_interface(void (*connect) (int),
 	xpc_interface.received = received;
 	xpc_interface.partid_to_nasids = partid_to_nasids;
 }
+EXPORT_SYMBOL_GPL(xpc_set_interface);
 
 /*
  * XPC calls this when it (the XPC module) is being unloaded.
@@ -95,6 +103,7 @@ xpc_clear_interface(void)
 	xpc_interface.partid_to_nasids = (enum xpc_retval(*)(partid_t, void *))
 	    xpc_notloaded;
 }
+EXPORT_SYMBOL_GPL(xpc_clear_interface);
 
 /*
  * Register for automatic establishment of a channel connection whenever
@@ -133,9 +142,8 @@ xpc_connect(int ch_number, xpc_channel_f
 
 	registration = &xpc_registrations[ch_number];
 
-	if (mutex_lock_interruptible(&registration->mutex) != 0) {
+	if (mutex_lock_interruptible(&registration->mutex) != 0)
 		return xpcInterrupted;
-	}
 
 	/* if XPC_CHANNEL_REGISTERED(ch_number) */
 	if (registration->func != NULL) {
@@ -157,6 +165,7 @@ xpc_connect(int ch_number, xpc_channel_f
 
 	return xpcSuccess;
 }
+EXPORT_SYMBOL_GPL(xpc_connect);
 
 /*
  * Remove the registration for automatic connection of the specified channel
@@ -207,6 +216,7 @@ xpc_disconnect(int ch_number)
 
 	return;
 }
+EXPORT_SYMBOL_GPL(xpc_disconnect);
 
 int __init
 xp_init(void)
@@ -215,9 +225,8 @@ xp_init(void)
 	u64 func_addr = *(u64 *)xp_nofault_PIOR;
 	u64 err_func_addr = *(u64 *)xp_error_PIOR;
 
-	if (!ia64_platform_is("sn2")) {
+	if (!ia64_platform_is("sn2"))
 		return -ENODEV;
-	}
 
 	/*
 	 * Register a nofault code region which performs a cross-partition
@@ -228,8 +237,9 @@ xp_init(void)
 	 * least some CPUs on Shubs <= v1.2, which unfortunately we have to
 	 * work around).
 	 */
-	if ((ret = sn_register_nofault_code(func_addr, err_func_addr,
-					    err_func_addr, 1, 1)) != 0) {
+	ret = sn_register_nofault_code(func_addr, err_func_addr, err_func_addr,
+				       1, 1);
+	if (ret != 0) {
 		printk(KERN_ERR "XP: can't register nofault code, error=%d\n",
 		       ret);
 	}
@@ -237,16 +247,14 @@ xp_init(void)
 	 * Setup the nofault PIO read target. (There is no special reason why
 	 * SH_IPI_ACCESS was selected.)
 	 */
-	if (is_shub2()) {
+	if (is_shub2())
 		xp_nofault_PIOR_target = SH2_IPI_ACCESS0;
-	} else {
+	else
 		xp_nofault_PIOR_target = SH1_IPI_ACCESS;
-	}
 
 	/* initialize the connection registration mutex */
-	for (ch_number = 0; ch_number < XPC_NCHANNELS; ch_number++) {
+	for (ch_number = 0; ch_number < XPC_NCHANNELS; ch_number++)
 		mutex_init(&xpc_registrations[ch_number].mutex);
-	}
 
 	return 0;
 }
@@ -269,12 +277,3 @@ module_exit(xp_exit);
 MODULE_AUTHOR("Silicon Graphics, Inc.");
 MODULE_DESCRIPTION("Cross Partition (XP) base");
 MODULE_LICENSE("GPL");
-
-EXPORT_SYMBOL(xp_nofault_PIOR);
-EXPORT_SYMBOL(xp_nofault_PIOR_target);
-EXPORT_SYMBOL(xpc_registrations);
-EXPORT_SYMBOL(xpc_interface);
-EXPORT_SYMBOL(xpc_clear_interface);
-EXPORT_SYMBOL(xpc_set_interface);
-EXPORT_SYMBOL(xpc_connect);
-EXPORT_SYMBOL(xpc_disconnect);
Index: linux-2.6/drivers/misc/sgi-xp/xpc.h
=================================--- linux-2.6.orig/drivers/misc/sgi-xp/xpc.h	2008-04-22 11:46:34.625831202 -0500
+++ linux-2.6/drivers/misc/sgi-xp/xpc.h	2008-04-22 11:48:06.749233774 -0500
@@ -110,16 +110,16 @@ struct xpc_rsvd_page {
 	u8 partid;		/* SAL: partition ID */
 	u8 version;
 	u8 pad1[6];		/* align to next u64 in cacheline */
-	volatile u64 vars_pa;
+	u64 vars_pa;		/* physical address of struct xpc_vars */
 	struct timespec stamp;	/* time when reserved page was setup by XPC */
 	u64 pad2[9];		/* align to last u64 in cacheline */
 	u64 nasids_size;	/* SAL: size of each nasid mask in bytes */
 };
 
-#define XPC_RP_VERSION _XPC_VERSION(1,1)	/* version 1.1 of the reserved page */
+#define XPC_RP_VERSION _XPC_VERSION(1, 1) /* version 1.1 of the reserved page */
 
 #define XPC_SUPPORTS_RP_STAMP(_version) \
-			(_version >= _XPC_VERSION(1,1))
+			(_version >= _XPC_VERSION(1, 1))
 
 /*
  * compare stamps - the return value is:
@@ -133,9 +133,10 @@ xpc_compare_stamps(struct timespec *stam
 {
 	int ret;
 
-	if ((ret = stamp1->tv_sec - stamp2->tv_sec) = 0) {
+	ret = stamp1->tv_sec - stamp2->tv_sec;
+	if (ret = 0)
 		ret = stamp1->tv_nsec - stamp2->tv_nsec;
-	}
+
 	return ret;
 }
 
@@ -165,10 +166,10 @@ struct xpc_vars {
 	AMO_t *amos_page;	/* vaddr of page of AMOs from MSPEC driver */
 };
 
-#define XPC_V_VERSION _XPC_VERSION(3,1)	/* version 3.1 of the cross vars */
+#define XPC_V_VERSION _XPC_VERSION(3, 1)    /* version 3.1 of the cross vars */
 
 #define XPC_SUPPORTS_DISENGAGE_REQUEST(_version) \
-			(_version >= _XPC_VERSION(3,1))
+			(_version >= _XPC_VERSION(3, 1))
 
 static inline int
 xpc_hb_allowed(partid_t partid, struct xpc_vars *vars)
@@ -224,7 +225,7 @@ xpc_disallow_hb(partid_t partid, struct 
  * occupies half a cacheline.
  */
 struct xpc_vars_part {
-	volatile u64 magic;
+	u64 magic;
 
 	u64 openclose_args_pa;	/* physical address of open and close args */
 	u64 GPs_pa;		/* physical address of Get/Put values */
@@ -247,18 +248,20 @@ struct xpc_vars_part {
  * MAGIC2 indicates that this partition has pulled the remote partititions
  * per partition variables that pertain to this partition.
  */
-#define XPC_VP_MAGIC1	0x0053524156435058L	/* 'XPCVARS\0'L (little endian) */
-#define XPC_VP_MAGIC2	0x0073726176435058L	/* 'XPCvars\0'L (little endian) */
+#define XPC_VP_MAGIC1	0x0053524156435058L   /* 'XPCVARS\0'L (little endian) */
+#define XPC_VP_MAGIC2	0x0073726176435058L   /* 'XPCvars\0'L (little endian) */
 
 /* the reserved page sizes and offsets */
 
 #define XPC_RP_HEADER_SIZE	L1_CACHE_ALIGN(sizeof(struct xpc_rsvd_page))
-#define XPC_RP_VARS_SIZE 	L1_CACHE_ALIGN(sizeof(struct xpc_vars))
+#define XPC_RP_VARS_SIZE	L1_CACHE_ALIGN(sizeof(struct xpc_vars))
 
-#define XPC_RP_PART_NASIDS(_rp) (u64 *) ((u8 *) _rp + XPC_RP_HEADER_SIZE)
+#define XPC_RP_PART_NASIDS(_rp) ((u64 *)((u8 *)(_rp) + XPC_RP_HEADER_SIZE))
 #define XPC_RP_MACH_NASIDS(_rp) (XPC_RP_PART_NASIDS(_rp) + xp_nasid_mask_words)
-#define XPC_RP_VARS(_rp)	((struct xpc_vars *) XPC_RP_MACH_NASIDS(_rp) + xp_nasid_mask_words)
-#define XPC_RP_VARS_PART(_rp)	(struct xpc_vars_part *) ((u8 *) XPC_RP_VARS(rp) + XPC_RP_VARS_SIZE)
+#define XPC_RP_VARS(_rp)	((struct xpc_vars *)(XPC_RP_MACH_NASIDS(_rp) + \
+				    xp_nasid_mask_words))
+#define XPC_RP_VARS_PART(_rp)	((struct xpc_vars_part *) \
+				    ((u8 *)XPC_RP_VARS(_rp) + XPC_RP_VARS_SIZE))
 
 /*
  * Functions registered by add_timer() or called by kernel_thread() only
@@ -277,8 +280,8 @@ struct xpc_vars_part {
  * Define a Get/Put value pair (pointers) used with a message queue.
  */
 struct xpc_gp {
-	volatile s64 get;	/* Get value */
-	volatile s64 put;	/* Put value */
+	s64 get;		/* Get value */
+	s64 put;		/* Put value */
 };
 
 #define XPC_GP_SIZE \
@@ -315,7 +318,7 @@ struct xpc_openclose_args {
  * and consumed by the intended recipient.
  */
 struct xpc_notify {
-	volatile u8 type;	/* type of notification */
+	u8 type;		/* type of notification */
 
 	/* the following two fields are only used if type = XPC_N_CALL */
 	xpc_notify_func func;	/* user's notify function */
@@ -421,8 +424,8 @@ struct xpc_channel {
 	void *local_msgqueue_base;	/* base address of kmalloc'd space */
 	struct xpc_msg *local_msgqueue;	/* local message queue */
 	void *remote_msgqueue_base;	/* base address of kmalloc'd space */
-	struct xpc_msg *remote_msgqueue;	/* cached copy of remote partition's */
-						/* local message queue */
+	struct xpc_msg *remote_msgqueue; /* cached copy of remote partition's */
+					 /* local message queue */
 	u64 remote_msgqueue_pa;	/* phys addr of remote partition's */
 				/* local message queue */
 
@@ -437,16 +440,16 @@ struct xpc_channel {
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
-								/* opening or closing of channel */
+	struct xpc_openclose_args *local_openclose_args; /* args passed on */
+					     /* opening or closing of channel */
 
 	/* various flavors of local and remote Get/Put values */
 
@@ -458,16 +461,11 @@ struct xpc_channel {
 
 	/* kthread management related fields */
 
-// >>> rethink having kthreads_assigned_limit and kthreads_idle_limit; perhaps
-// >>> allow the assigned limit be unbounded and let the idle limit be dynamic
-// >>> dependent on activity over the last interval of time
 	atomic_t kthreads_assigned;	/* #of kthreads assigned to channel */
 	u32 kthreads_assigned_limit;	/* limit on #of kthreads assigned */
 	atomic_t kthreads_idle;	/* #of kthreads idle waiting for work */
 	u32 kthreads_idle_limit;	/* limit on #of kthreads idle */
 	atomic_t kthreads_active;	/* #of kthreads actively working */
-	// >>> following field is temporary
-	u32 kthreads_created;	/* total #of kthreads created */
 
 	wait_queue_head_t idle_wq;	/* idle kthread wait queue */
 
@@ -479,28 +477,28 @@ struct xpc_channel {
 
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
@@ -512,7 +510,7 @@ struct xpc_partition {
 	/* XPC HB infrastructure */
 
 	u8 remote_rp_version;	/* version# of partition's rsvd pg */
-	struct timespec remote_rp_stamp;	/* time when rsvd pg was initialized */
+	struct timespec remote_rp_stamp; /* time when rsvd pg was initialized */
 	u64 remote_rp_pa;	/* phys addr of partition's rsvd pg */
 	u64 remote_vars_pa;	/* phys addr of partition's vars */
 	u64 remote_vars_part_pa;	/* phys addr of partition's vars part */
@@ -533,7 +531,7 @@ struct xpc_partition {
 
 	/* XPC infrastructure referencing and teardown control */
 
-	volatile u8 setup_state;	/* infrastructure setup state */
+	u8 setup_state;		/* infrastructure setup state */
 	wait_queue_head_t teardown_wq;	/* kthread waiting to teardown infra */
 	atomic_t references;	/* #of references to infrastructure */
 
@@ -545,32 +543,32 @@ struct xpc_partition {
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
-					/* values */
+	struct xpc_gp *remote_GPs;	/* copy of remote partition's local */
+					/* Get/Put values */
 	u64 remote_GPs_pa;	/* phys address of remote partition's local */
 				/* Get/Put values */
 
 	/* fields used to pass args when opening or closing a channel */
 
-	void *local_openclose_args_base;	/* base address of kmalloc'd space */
-	struct xpc_openclose_args *local_openclose_args;	/* local's args */
-	void *remote_openclose_args_base;	/* base address of kmalloc'd space */
-	struct xpc_openclose_args *remote_openclose_args;	/* copy of remote's */
-								/* args */
+	void *local_openclose_args_base;   /* base address of kmalloc'd space */
+	struct xpc_openclose_args *local_openclose_args;      /* local's args */
+	void *remote_openclose_args_base;  /* base address of kmalloc'd space */
+	struct xpc_openclose_args *remote_openclose_args; /* copy of remote's */
+							  /* args */
 	u64 remote_openclose_args_pa;	/* phys addr of remote's args */
 
 	/* IPI sending, receiving and handling related fields */
 
 	int remote_IPI_nasid;	/* nasid of where to send IPIs */
 	int remote_IPI_phys_cpuid;	/* phys CPU ID of where to send IPIs */
-	AMO_t *remote_IPI_amo_va;	/* address of remote IPI AMO_t structure */
+	AMO_t *remote_IPI_amo_va;    /* address of remote IPI AMO_t structure */
 
 	AMO_t *local_IPI_amo_va;	/* address of IPI AMO_t structure */
 	u64 local_IPI_amo;	/* IPI amo flags yet to be handled */
@@ -678,9 +676,8 @@ extern void xpc_teardown_infrastructure(
 static inline void
 xpc_wakeup_channel_mgr(struct xpc_partition *part)
 {
-	if (atomic_inc_return(&part->channel_mgr_requests) = 1) {
+	if (atomic_inc_return(&part->channel_mgr_requests) = 1)
 		wake_up(&part->channel_mgr_wq);
-	}
 }
 
 /*
@@ -699,9 +696,8 @@ xpc_msgqueue_deref(struct xpc_channel *c
 	s32 refs = atomic_dec_return(&ch->references);
 
 	DBUG_ON(refs < 0);
-	if (refs = 0) {
+	if (refs = 0)
 		xpc_wakeup_channel_mgr(&xpc_partitions[ch->partid]);
-	}
 }
 
 #define XPC_DISCONNECT_CHANNEL(_ch, _reason, _irqflgs) \
@@ -717,9 +713,8 @@ xpc_part_deref(struct xpc_partition *par
 	s32 refs = atomic_dec_return(&part->references);
 
 	DBUG_ON(refs < 0);
-	if (refs = 0 && part->setup_state = XPC_P_WTEARDOWN) {
+	if (refs = 0 && part->setup_state = XPC_P_WTEARDOWN)
 		wake_up(&part->teardown_wq);
-	}
 }
 
 static inline int
@@ -729,9 +724,9 @@ xpc_part_ref(struct xpc_partition *part)
 
 	atomic_inc(&part->references);
 	setup = (part->setup_state = XPC_P_SETUP);
-	if (!setup) {
+	if (!setup)
 		xpc_part_deref(part);
-	}
+
 	return setup;
 }
 
@@ -1007,13 +1002,11 @@ xpc_notify_IRQ_send(struct xpc_channel *
 		dev_dbg(xpc_chan, "%s sent to partid=%d, channel=%d, ret=%d\n",
 			ipi_flag_string, ch->partid, ch->number, ret);
 		if (unlikely(ret != xpcSuccess)) {
-			if (irq_flags != NULL) {
+			if (irq_flags != NULL)
 				spin_unlock_irqrestore(&ch->lock, *irq_flags);
-			}
 			XPC_DEACTIVATE_PARTITION(part, ret);
-			if (irq_flags != NULL) {
+			if (irq_flags != NULL)
 				spin_lock_irqsave(&ch->lock, *irq_flags);
-			}
 		}
 	}
 }
@@ -1056,8 +1049,8 @@ xpc_notify_IRQ_send_local(struct xpc_cha
 #define XPC_GET_IPI_FLAGS(_amo, _c)	((u8) (((_amo) >> ((_c) * 8)) & 0xff))
 #define XPC_SET_IPI_FLAGS(_amo, _c, _f)	(_amo) |= ((u64) (_f) << ((_c) * 8))
 
-#define	XPC_ANY_OPENCLOSE_IPI_FLAGS_SET(_amo) ((_amo) & __IA64_UL_CONST(0x0f0f0f0f0f0f0f0f))
-#define XPC_ANY_MSG_IPI_FLAGS_SET(_amo)       ((_amo) & __IA64_UL_CONST(0x1010101010101010))
+#define	XPC_ANY_OPENCLOSE_IPI_FLAGS_SET(_amo) ((_amo) & 0x0f0f0f0f0f0f0f0fUL)
+#define XPC_ANY_MSG_IPI_FLAGS_SET(_amo)       ((_amo) & 0x1010101010101010UL)
 
 static inline void
 xpc_IPI_send_closerequest(struct xpc_channel *ch, unsigned long *irq_flags)
@@ -1178,9 +1171,8 @@ xpc_check_for_channel_activity(struct xp
 	unsigned long irq_flags;
 
 	IPI_amo = xpc_IPI_receive(part->local_IPI_amo_va);
-	if (IPI_amo = 0) {
+	if (IPI_amo = 0)
 		return;
-	}
 
 	spin_lock_irqsave(&part->IPI_lock, irq_flags);
 	part->local_IPI_amo |= IPI_amo;
Index: linux-2.6/drivers/misc/sgi-xp/xpc_main.c
=================================--- linux-2.6.orig/drivers/misc/sgi-xp/xpc_main.c	2008-04-22 11:46:34.625831202 -0500
+++ linux-2.6/drivers/misc/sgi-xp/xpc_main.c	2008-04-22 11:48:06.773236745 -0500
@@ -46,17 +46,16 @@
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/init.h>
-#include <linux/sched.h>
-#include <linux/syscalls.h>
 #include <linux/cache.h>
 #include <linux/interrupt.h>
 #include <linux/delay.h>
 #include <linux/reboot.h>
 #include <linux/completion.h>
 #include <linux/kdebug.h>
+#include <linux/kthread.h>
+#include <linux/uaccess.h>
 #include <asm/sn/intr.h>
 #include <asm/sn/sn_sal.h>
-#include <asm/uaccess.h>
 #include "xpc.h"
 
 /* define two XPC debug device structures to be used with dev_dbg() et al */
@@ -91,7 +90,7 @@ static int xpc_hb_check_min_interval = 1
 static int xpc_hb_check_max_interval = 120;
 
 int xpc_disengage_request_timelimit = XPC_DISENGAGE_REQUEST_DEFAULT_TIMELIMIT;
-static int xpc_disengage_request_min_timelimit = 0;
+static int xpc_disengage_request_min_timelimit;	/* = 0 */
 static int xpc_disengage_request_max_timelimit = 120;
 
 static ctl_table xpc_sys_xpc_hb_dir[] = {
@@ -213,9 +212,8 @@ xpc_hb_beater(unsigned long dummy)
 {
 	xpc_vars->heartbeat++;
 
-	if (time_after_eq(jiffies, xpc_hb_check_timeout)) {
+	if (time_after_eq(jiffies, xpc_hb_check_timeout))
 		wake_up_interruptible(&xpc_act_IRQ_wq);
-	}
 
 	xpc_hb_timer.expires = jiffies + (xpc_hb_interval * HZ);
 	add_timer(&xpc_hb_timer);
@@ -234,15 +232,13 @@ xpc_hb_checker(void *ignore)
 
 	/* this thread was marked active by xpc_hb_init() */
 
-	daemonize(XPC_HB_CHECK_THREAD_NAME);
-
 	set_cpus_allowed(current, cpumask_of_cpu(XPC_HB_CHECK_CPU));
 
 	/* set our heartbeating to other partitions into motion */
 	xpc_hb_check_timeout = jiffies + (xpc_hb_check_interval * HZ);
 	xpc_hb_beater(0);
 
-	while (!(volatile int)xpc_exiting) {
+	while (!xpc_exiting) {
 
 		dev_dbg(xpc_part, "woke up with %d ticks rem; %d IRQs have "
 			"been received\n",
@@ -287,7 +283,7 @@ xpc_hb_checker(void *ignore)
 						atomic_read(&xpc_act_IRQ_rcvd)
 						|| time_after_eq(jiffies,
 							xpc_hb_check_timeout) ||
-						(volatile int)xpc_exiting));
+						xpc_exiting));
 	}
 
 	dev_dbg(xpc_part, "heartbeat checker is exiting\n");
@@ -305,8 +301,6 @@ xpc_hb_checker(void *ignore)
 static int
 xpc_initiate_discovery(void *ignore)
 {
-	daemonize(XPC_DISCOVERY_THREAD_NAME);
-
 	xpc_discovery();
 
 	dev_dbg(xpc_part, "discovery thread is exiting\n");
@@ -338,9 +332,8 @@ xpc_make_first_contact(struct xpc_partit
 		/* wait a 1/4 of a second or so */
 		(void)msleep_interruptible(250);
 
-		if (part->act_state = XPC_P_DEACTIVATING) {
+		if (part->act_state = XPC_P_DEACTIVATING)
 			return part->reason;
-		}
 	}
 
 	return xpc_mark_partition_active(part);
@@ -382,22 +375,12 @@ xpc_channel_mgr(struct xpc_partition *pa
 		 */
 		atomic_dec(&part->channel_mgr_requests);
 		(void)wait_event_interruptible(part->channel_mgr_wq,
-					       (atomic_read
-						(&part->channel_mgr_requests) >
-						0 ||
-						(volatile u64)part->
-						local_IPI_amo != 0 ||
-						((volatile u8)part->act_state =
-						 XPC_P_DEACTIVATING &&
-						 atomic_read(&part->
-							     nchannels_active)
-						 = 0 &&
-						 xpc_partition_disengaged
-						 (part))));
+				(atomic_read(&part->channel_mgr_requests) > 0 ||
+				 part->local_IPI_amo != 0 ||
+				 (part->act_state = XPC_P_DEACTIVATING &&
+				 atomic_read(&part->nchannels_active) = 0 &&
+				 xpc_partition_disengaged(part))));
 		atomic_set(&part->channel_mgr_requests, 1);
-
-		// >>> Does it need to wakeup periodically as well? In case we
-		// >>> miscalculated the #of kthreads to wakeup or create?
 	}
 }
 
@@ -423,9 +406,8 @@ xpc_partition_up(struct xpc_partition *p
 
 	dev_dbg(xpc_chan, "activating partition %d\n", XPC_PARTID(part));
 
-	if (xpc_setup_infrastructure(part) != xpcSuccess) {
+	if (xpc_setup_infrastructure(part) != xpcSuccess)
 		return;
-	}
 
 	/*
 	 * The kthread that XPC HB called us with will become the
@@ -436,9 +418,8 @@ xpc_partition_up(struct xpc_partition *p
 
 	(void)xpc_part_ref(part);	/* this will always succeed */
 
-	if (xpc_make_first_contact(part) = xpcSuccess) {
+	if (xpc_make_first_contact(part) = xpcSuccess)
 		xpc_channel_mgr(part);
-	}
 
 	xpc_part_deref(part);
 
@@ -451,8 +432,6 @@ xpc_activating(void *__partid)
 	partid_t partid = (u64)__partid;
 	struct xpc_partition *part = &xpc_partitions[partid];
 	unsigned long irq_flags;
-	struct sched_param param = {.sched_priority = MAX_RT_PRIO - 1 };
-	int ret;
 
 	DBUG_ON(partid <= 0 || partid >= XP_MAX_PARTITIONS);
 
@@ -474,21 +453,6 @@ xpc_activating(void *__partid)
 
 	dev_dbg(xpc_part, "bringing partition %d up\n", partid);
 
-	daemonize("xpc%02d", partid);
-
-	/*
-	 * This thread needs to run at a realtime priority to prevent a
-	 * significant performance degradation.
-	 */
-	ret = sched_setscheduler(current, SCHED_FIFO, &param);
-	if (ret != 0) {
-		dev_warn(xpc_part, "unable to set pid %d to a realtime "
-			 "priority, ret=%d\n", current->pid, ret);
-	}
-
-	/* allow this thread and its children to run on any CPU */
-	set_cpus_allowed(current, CPU_MASK_ALL);
-
 	/*
 	 * Register the remote partition's AMOs with SAL so it can handle
 	 * and cleanup errors within that address range should the remote
@@ -537,7 +501,7 @@ xpc_activate_partition(struct xpc_partit
 {
 	partid_t partid = XPC_PARTID(part);
 	unsigned long irq_flags;
-	pid_t pid;
+	struct task_struct *kthread;
 
 	spin_lock_irqsave(&part->act_lock, irq_flags);
 
@@ -548,9 +512,9 @@ xpc_activate_partition(struct xpc_partit
 
 	spin_unlock_irqrestore(&part->act_lock, irq_flags);
 
-	pid = kernel_thread(xpc_activating, (void *)((u64)partid), 0);
-
-	if (unlikely(pid <= 0)) {
+	kthread = kthread_run(xpc_activating, (void *)((u64)partid), "xpc%02d",
+			      partid);
+	if (IS_ERR(kthread)) {
 		spin_lock_irqsave(&part->act_lock, irq_flags);
 		part->act_state = XPC_P_INACTIVE;
 		XPC_SET_REASON(part, xpcCloneKThreadFailed, __LINE__);
@@ -562,7 +526,7 @@ xpc_activate_partition(struct xpc_partit
  * Handle the receipt of a SGI_XPC_NOTIFY IRQ by seeing whether the specified
  * partition actually sent it. Since SGI_XPC_NOTIFY IRQs may be shared by more
  * than one partition, we use an AMO_t structure per partition to indicate
- * whether a partition has sent an IPI or not.  >>> If it has, then wake up the
+ * whether a partition has sent an IPI or not.  If it has, then wake up the
  * associated kthread to handle it.
  *
  * All SGI_XPC_NOTIFY IRQs received by XPC are the result of IPIs sent by XPC
@@ -628,16 +592,13 @@ xpc_activate_kthreads(struct xpc_channel
 		wake_up_nr(&ch->idle_wq, wakeup);
 	}
 
-	if (needed <= 0) {
+	if (needed <= 0)
 		return;
-	}
 
 	if (needed + assigned > ch->kthreads_assigned_limit) {
 		needed = ch->kthreads_assigned_limit - assigned;
-		// >>>should never be less than 0
-		if (needed <= 0) {
+		if (needed <= 0)
 			return;
-		}
 	}
 
 	dev_dbg(xpc_chan, "create %d new kthreads, partid=%d, channel=%d\n",
@@ -655,9 +616,8 @@ xpc_kthread_waitmsgs(struct xpc_partitio
 	do {
 		/* deliver messages to their intended recipients */
 
-		while ((volatile s64)ch->w_local_GP.get <
-		       (volatile s64)ch->w_remote_GP.put &&
-		       !((volatile u32)ch->flags & XPC_C_DISCONNECTING)) {
+		while (ch->w_local_GP.get < ch->w_remote_GP.put &&
+		       !(ch->flags & XPC_C_DISCONNECTING)) {
 			xpc_deliver_msg(ch);
 		}
 
@@ -672,21 +632,16 @@ xpc_kthread_waitmsgs(struct xpc_partitio
 			"wait_event_interruptible_exclusive()\n");
 
 		(void)wait_event_interruptible_exclusive(ch->idle_wq,
-							 ((volatile s64)ch->
-							  w_local_GP.get <
-							  (volatile s64)ch->
-							  w_remote_GP.put ||
-							  ((volatile u32)ch->
-							   flags &
-							   XPC_C_DISCONNECTING)));
+				(ch->w_local_GP.get < ch->w_remote_GP.put ||
+				 (ch->flags & XPC_C_DISCONNECTING)));
 
 		atomic_dec(&ch->kthreads_idle);
 
-	} while (!((volatile u32)ch->flags & XPC_C_DISCONNECTING));
+	} while (!(ch->flags & XPC_C_DISCONNECTING));
 }
 
 static int
-xpc_daemonize_kthread(void *args)
+xpc_kthread_start(void *args)
 {
 	partid_t partid = XPC_UNPACK_ARG1(args);
 	u16 ch_number = XPC_UNPACK_ARG2(args);
@@ -695,8 +650,6 @@ xpc_daemonize_kthread(void *args)
 	int n_needed;
 	unsigned long irq_flags;
 
-	daemonize("xpc%02dc%d", partid, ch_number);
-
 	dev_dbg(xpc_chan, "kthread starting, partid=%d, channel=%d\n",
 		partid, ch_number);
 
@@ -725,9 +678,9 @@ xpc_daemonize_kthread(void *args)
 			 * need one less than total #of messages to deliver.
 			 */
 			n_needed = ch->w_remote_GP.put - ch->w_local_GP.get - 1;
-			if (n_needed > 0 && !(ch->flags & XPC_C_DISCONNECTING)) {
+			if (n_needed > 0 && !(ch->flags & XPC_C_DISCONNECTING))
 				xpc_activate_kthreads(ch, n_needed);
-			}
+
 		} else {
 			spin_unlock_irqrestore(&ch->lock, irq_flags);
 		}
@@ -783,9 +736,9 @@ xpc_create_kthreads(struct xpc_channel *
 		    int ignore_disconnecting)
 {
 	unsigned long irq_flags;
-	pid_t pid;
 	u64 args = XPC_PACK_ARGS(ch->partid, ch->number);
 	struct xpc_partition *part = &xpc_partitions[ch->partid];
+	struct task_struct *kthread;
 
 	while (needed-- > 0) {
 
@@ -812,8 +765,9 @@ xpc_create_kthreads(struct xpc_channel *
 		(void)xpc_part_ref(part);
 		xpc_msgqueue_ref(ch);
 
-		pid = kernel_thread(xpc_daemonize_kthread, (void *)args, 0);
-		if (pid < 0) {
+		kthread = kthread_run(xpc_kthread_start, (void *)args,
+				      "xpc%02dc%d", ch->partid, ch->number);
+		if (IS_ERR(kthread)) {
 			/* the fork failed */
 
 			/*
@@ -823,7 +777,7 @@ xpc_create_kthreads(struct xpc_channel *
 			 * to this channel are blocked in the channel's
 			 * registerer, because the only thing that will unblock
 			 * them is the xpcDisconnecting callout that this
-			 * failed kernel_thread would have made.
+			 * failed kthread_run() would have made.
 			 */
 
 			if (atomic_dec_return(&ch->kthreads_assigned) = 0 &&
@@ -848,8 +802,6 @@ xpc_create_kthreads(struct xpc_channel *
 			}
 			break;
 		}
-
-		ch->kthreads_created++;	// >>> temporary debug only!!!
 	}
 }
 
@@ -866,9 +818,8 @@ xpc_disconnect_wait(int ch_number)
 	for (partid = 1; partid < XP_MAX_PARTITIONS; partid++) {
 		part = &xpc_partitions[partid];
 
-		if (!xpc_part_ref(part)) {
+		if (!xpc_part_ref(part))
 			continue;
-		}
 
 		ch = &part->channels[ch_number];
 
@@ -898,9 +849,8 @@ xpc_disconnect_wait(int ch_number)
 		ch->flags &= ~XPC_C_WDISCONNECT;
 		spin_unlock_irqrestore(&ch->lock, irq_flags);
 
-		if (wakeup_channel_mgr) {
+		if (wakeup_channel_mgr)
 			xpc_wakeup_channel_mgr(part);
-		}
 
 		xpc_part_deref(part);
 	}
@@ -1019,9 +969,8 @@ xpc_do_exit(enum xpc_retval reason)
 	/* clear the interface to XPC's functions */
 	xpc_clear_interface();
 
-	if (xpc_sysctl) {
+	if (xpc_sysctl)
 		unregister_sysctl_table(xpc_sysctl);
-	}
 
 	kfree(xpc_remote_copy_buffer_base);
 }
@@ -1071,7 +1020,8 @@ xpc_die_disengage(void)
 	for (partid = 1; partid < XP_MAX_PARTITIONS; partid++) {
 		part = &xpc_partitions[partid];
 
-		if (!XPC_SUPPORTS_DISENGAGE_REQUEST(part->remote_vars_version)) {
+		if (!XPC_SUPPORTS_DISENGAGE_REQUEST(part->
+		    remote_vars_version)) {
 
 			/* just in case it was left set by an earlier XPC */
 			xpc_clear_partition_engaged(1UL << partid);
@@ -1144,9 +1094,9 @@ xpc_system_die(struct notifier_block *nb
 
 	case DIE_KDEBUG_ENTER:
 		/* Should lack of heartbeat be ignored by other partitions? */
-		if (!xpc_kdebug_ignore) {
+		if (!xpc_kdebug_ignore)
 			break;
-		}
+
 		/* fall through */
 	case DIE_MCA_MONARCH_ENTER:
 	case DIE_INIT_MONARCH_ENTER:
@@ -1156,9 +1106,9 @@ xpc_system_die(struct notifier_block *nb
 
 	case DIE_KDEBUG_LEAVE:
 		/* Is lack of heartbeat being ignored by other partitions? */
-		if (!xpc_kdebug_ignore) {
+		if (!xpc_kdebug_ignore)
 			break;
-		}
+
 		/* fall through */
 	case DIE_MCA_MONARCH_LEAVE:
 	case DIE_INIT_MONARCH_LEAVE:
@@ -1176,18 +1126,17 @@ xpc_init(void)
 	int ret;
 	partid_t partid;
 	struct xpc_partition *part;
-	pid_t pid;
+	struct task_struct *kthread;
 	size_t buf_size;
 
-	if (!ia64_platform_is("sn2")) {
+	if (!ia64_platform_is("sn2"))
 		return -ENODEV;
-	}
 
 	buf_size = max(XPC_RP_VARS_SIZE,
 		       XPC_RP_HEADER_SIZE + XP_NASID_MASK_BYTES);
 	xpc_remote_copy_buffer = xpc_kmalloc_cacheline_aligned(buf_size,
 							       GFP_KERNEL,
-							       &xpc_remote_copy_buffer_base);
+						  &xpc_remote_copy_buffer_base);
 	if (xpc_remote_copy_buffer = NULL)
 		return -ENOMEM;
 
@@ -1250,9 +1199,8 @@ xpc_init(void)
 
 		xpc_restrict_IPI_ops();
 
-		if (xpc_sysctl) {
+		if (xpc_sysctl)
 			unregister_sysctl_table(xpc_sysctl);
-		}
 
 		kfree(xpc_remote_copy_buffer_base);
 		return -EBUSY;
@@ -1270,9 +1218,8 @@ xpc_init(void)
 		free_irq(SGI_XPC_ACTIVATE, NULL);
 		xpc_restrict_IPI_ops();
 
-		if (xpc_sysctl) {
+		if (xpc_sysctl)
 			unregister_sysctl_table(xpc_sysctl);
-		}
 
 		kfree(xpc_remote_copy_buffer_base);
 		return -EBUSY;
@@ -1280,15 +1227,13 @@ xpc_init(void)
 
 	/* add ourselves to the reboot_notifier_list */
 	ret = register_reboot_notifier(&xpc_reboot_notifier);
-	if (ret != 0) {
+	if (ret != 0)
 		dev_warn(xpc_part, "can't register reboot notifier\n");
-	}
 
 	/* add ourselves to the die_notifier list */
 	ret = register_die_notifier(&xpc_die_notifier);
-	if (ret != 0) {
+	if (ret != 0)
 		dev_warn(xpc_part, "can't register die notifier\n");
-	}
 
 	init_timer(&xpc_hb_timer);
 	xpc_hb_timer.function = xpc_hb_beater;
@@ -1297,8 +1242,8 @@ xpc_init(void)
 	 * The real work-horse behind xpc.  This processes incoming
 	 * interrupts and monitors remote heartbeats.
 	 */
-	pid = kernel_thread(xpc_hb_checker, NULL, 0);
-	if (pid < 0) {
+	kthread = kthread_run(xpc_hb_checker, NULL, XPC_HB_CHECK_THREAD_NAME);
+	if (IS_ERR(kthread)) {
 		dev_err(xpc_part, "failed while forking hb check thread\n");
 
 		/* indicate to others that our reserved page is uninitialized */
@@ -1314,9 +1259,8 @@ xpc_init(void)
 		free_irq(SGI_XPC_ACTIVATE, NULL);
 		xpc_restrict_IPI_ops();
 
-		if (xpc_sysctl) {
+		if (xpc_sysctl)
 			unregister_sysctl_table(xpc_sysctl);
-		}
 
 		kfree(xpc_remote_copy_buffer_base);
 		return -EBUSY;
@@ -1327,8 +1271,9 @@ xpc_init(void)
 	 * activate based on info provided by SAL. This new thread is short
 	 * lived and will exit once discovery is complete.
 	 */
-	pid = kernel_thread(xpc_initiate_discovery, NULL, 0);
-	if (pid < 0) {
+	kthread = kthread_run(xpc_initiate_discovery, NULL,
+			      XPC_DISCOVERY_THREAD_NAME);
+	if (IS_ERR(kthread)) {
 		dev_err(xpc_part, "failed while forking discovery thread\n");
 
 		/* mark this new thread as a non-starter */
Index: linux-2.6/drivers/misc/sgi-xp/xpc_channel.c
=================================--- linux-2.6.orig/drivers/misc/sgi-xp/xpc_channel.c	2008-04-22 11:46:34.625831202 -0500
+++ linux-2.6/drivers/misc/sgi-xp/xpc_channel.c	2008-04-22 11:48:06.797239716 -0500
@@ -33,19 +33,19 @@ xpc_kzalloc_cacheline_aligned(size_t siz
 {
 	/* see if kzalloc will give us cachline aligned memory by default */
 	*base = kzalloc(size, flags);
-	if (*base = NULL) {
+	if (*base = NULL)
 		return NULL;
-	}
-	if ((u64)*base = L1_CACHE_ALIGN((u64)*base)) {
+
+	if ((u64)*base = L1_CACHE_ALIGN((u64)*base))
 		return *base;
-	}
+
 	kfree(*base);
 
 	/* nope, we'll have to do it ourselves */
 	*base = kzalloc(size + L1_CACHE_BYTES, flags);
-	if (*base = NULL) {
+	if (*base = NULL)
 		return NULL;
-	}
+
 	return (void *)L1_CACHE_ALIGN((u64)*base);
 }
 
@@ -264,15 +264,13 @@ xpc_pull_remote_cachelines(struct xpc_pa
 	DBUG_ON((u64)dst != L1_CACHE_ALIGN((u64)dst));
 	DBUG_ON(cnt != L1_CACHE_ALIGN(cnt));
 
-	if (part->act_state = XPC_P_DEACTIVATING) {
+	if (part->act_state = XPC_P_DEACTIVATING)
 		return part->reason;
-	}
 
 	bte_ret = xp_bte_copy((u64)src, (u64)dst, (u64)cnt,
 			      (BTE_NORMAL | BTE_WACQUIRE), NULL);
-	if (bte_ret = BTE_SUCCESS) {
+	if (bte_ret = BTE_SUCCESS)
 		return xpcSuccess;
-	}
 
 	dev_dbg(xpc_chan, "xp_bte_copy() from partition %d failed, ret=%d\n",
 		XPC_PARTID(part), bte_ret);
@@ -359,18 +357,16 @@ xpc_pull_remote_vars_part(struct xpc_par
 		part->remote_IPI_nasid = pulled_entry->IPI_nasid;
 		part->remote_IPI_phys_cpuid = pulled_entry->IPI_phys_cpuid;
 
-		if (part->nchannels > pulled_entry->nchannels) {
+		if (part->nchannels > pulled_entry->nchannels)
 			part->nchannels = pulled_entry->nchannels;
-		}
 
 		/* let the other side know that we've pulled their variables */
 
 		xpc_vars_part[partid].magic = XPC_VP_MAGIC2;
 	}
 
-	if (pulled_entry->magic = XPC_VP_MAGIC1) {
+	if (pulled_entry->magic = XPC_VP_MAGIC1)
 		return xpcRetry;
-	}
 
 	return xpcSuccess;
 }
@@ -390,9 +386,10 @@ xpc_get_IPI_flags(struct xpc_partition *
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
@@ -441,20 +438,14 @@ xpc_allocate_local_msgqueue(struct xpc_c
 	int nentries;
 	size_t nbytes;
 
-	// >>> may want to check for ch->flags & XPC_C_DISCONNECTING between
-	// >>> iterations of the for-loop, bail if set?
-
-	// >>> should we impose a minimum #of entries? like 4 or 8?
 	for (nentries = ch->local_nentries; nentries > 0; nentries--) {
 
 		nbytes = nentries * ch->msg_size;
 		ch->local_msgqueue = xpc_kzalloc_cacheline_aligned(nbytes,
 								   GFP_KERNEL,
-								   &ch->
-								   local_msgqueue_base);
-		if (ch->local_msgqueue = NULL) {
+						      &ch->local_msgqueue_base);
+		if (ch->local_msgqueue = NULL)
 			continue;
-		}
 
 		nbytes = nentries * sizeof(struct xpc_notify);
 		ch->notify_queue = kzalloc(nbytes, GFP_KERNEL);
@@ -493,20 +484,14 @@ xpc_allocate_remote_msgqueue(struct xpc_
 
 	DBUG_ON(ch->remote_nentries <= 0);
 
-	// >>> may want to check for ch->flags & XPC_C_DISCONNECTING between
-	// >>> iterations of the for-loop, bail if set?
-
-	// >>> should we impose a minimum #of entries? like 4 or 8?
 	for (nentries = ch->remote_nentries; nentries > 0; nentries--) {
 
 		nbytes = nentries * ch->msg_size;
 		ch->remote_msgqueue = xpc_kzalloc_cacheline_aligned(nbytes,
 								    GFP_KERNEL,
-								    &ch->
-								    remote_msgqueue_base);
-		if (ch->remote_msgqueue = NULL) {
+						     &ch->remote_msgqueue_base);
+		if (ch->remote_msgqueue = NULL)
 			continue;
-		}
 
 		spin_lock_irqsave(&ch->lock, irq_flags);
 		if (nentries < ch->remote_nentries) {
@@ -538,11 +523,12 @@ xpc_allocate_msgqueues(struct xpc_channe
 
 	DBUG_ON(ch->flags & XPC_C_SETUP);
 
-	if ((ret = xpc_allocate_local_msgqueue(ch)) != xpcSuccess) {
+	ret = xpc_allocate_local_msgqueue(ch);
+	if (ret != xpcSuccess)
 		return ret;
-	}
 
-	if ((ret = xpc_allocate_remote_msgqueue(ch)) != xpcSuccess) {
+	ret = xpc_allocate_remote_msgqueue(ch);
+	if (ret != xpcSuccess) {
 		kfree(ch->local_msgqueue_base);
 		ch->local_msgqueue = NULL;
 		kfree(ch->notify_queue);
@@ -582,12 +568,11 @@ xpc_process_connect(struct xpc_channel *
 		ret = xpc_allocate_msgqueues(ch);
 		spin_lock_irqsave(&ch->lock, *irq_flags);
 
-		if (ret != xpcSuccess) {
+		if (ret != xpcSuccess)
 			XPC_DISCONNECT_CHANNEL(ch, ret, irq_flags);
-		}
-		if (ch->flags & (XPC_C_CONNECTED | XPC_C_DISCONNECTING)) {
+
+		if (ch->flags & (XPC_C_CONNECTED | XPC_C_DISCONNECTING))
 			return;
-		}
 
 		DBUG_ON(!(ch->flags & XPC_C_SETUP));
 		DBUG_ON(ch->local_msgqueue = NULL);
@@ -599,9 +584,8 @@ xpc_process_connect(struct xpc_channel *
 		xpc_IPI_send_openreply(ch, irq_flags);
 	}
 
-	if (!(ch->flags & XPC_C_ROPENREPLY)) {
+	if (!(ch->flags & XPC_C_ROPENREPLY))
 		return;
-	}
 
 	DBUG_ON(ch->remote_msgqueue_pa = 0);
 
@@ -719,9 +703,8 @@ xpc_process_disconnect(struct xpc_channe
 
 	DBUG_ON(!spin_is_locked(&ch->lock));
 
-	if (!(ch->flags & XPC_C_DISCONNECTING)) {
+	if (!(ch->flags & XPC_C_DISCONNECTING))
 		return;
-	}
 
 	DBUG_ON(!(ch->flags & XPC_C_CLOSEREQUEST));
 
@@ -736,26 +719,23 @@ xpc_process_disconnect(struct xpc_channe
 
 	if (part->act_state = XPC_P_DEACTIVATING) {
 		/* can't proceed until the other side disengages from us */
-		if (xpc_partition_engaged(1UL << ch->partid)) {
+		if (xpc_partition_engaged(1UL << ch->partid))
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
@@ -815,9 +795,10 @@ xpc_process_openclose_IPI(struct xpc_par
 
 	spin_lock_irqsave(&ch->lock, irq_flags);
 
-      again:
+again:
 
-	if ((ch->flags & XPC_C_DISCONNECTED) && (ch->flags & XPC_C_WDISCONNECT)) {
+	if ((ch->flags & XPC_C_DISCONNECTED) &&
+	    (ch->flags & XPC_C_WDISCONNECT)) {
 		/*
 		 * Delay processing IPI flags until thread waiting disconnect
 		 * has had a chance to see that the channel is disconnected.
@@ -890,11 +871,10 @@ xpc_process_openclose_IPI(struct xpc_par
 
 		if (!(ch->flags & XPC_C_DISCONNECTING)) {
 			reason = args->reason;
-			if (reason <= xpcSuccess || reason > xpcUnknownReason) {
+			if (reason <= xpcSuccess || reason > xpcUnknownReason)
 				reason = xpcUnknownReason;
-			} else if (reason = xpcUnregistering) {
+			else if (reason = xpcUnregistering)
 				reason = xpcOtherUnregistering;
-			}
 
 			XPC_DISCONNECT_CHANNEL(ch, reason, &irq_flags);
 
@@ -1068,9 +1048,8 @@ xpc_connect_channel(struct xpc_channel *
 	unsigned long irq_flags;
 	struct xpc_registration *registration = &xpc_registrations[ch->number];
 
-	if (mutex_trylock(&registration->mutex) = 0) {
+	if (mutex_trylock(&registration->mutex) = 0)
 		return xpcRetry;
-	}
 
 	if (!XPC_CHANNEL_REGISTERED(ch->number)) {
 		mutex_unlock(&registration->mutex);
@@ -1159,7 +1138,7 @@ xpc_clear_local_msgqueue_flags(struct xp
 					 (get % ch->local_nentries) *
 					 ch->msg_size);
 		msg->flags = 0;
-	} while (++get < (volatile s64)ch->remote_GP.get);
+	} while (++get < ch->remote_GP.get);
 }
 
 /*
@@ -1177,7 +1156,7 @@ xpc_clear_remote_msgqueue_flags(struct x
 					 (put % ch->remote_nentries) *
 					 ch->msg_size);
 		msg->flags = 0;
-	} while (++put < (volatile s64)ch->remote_GP.put);
+	} while (++put < ch->remote_GP.put);
 }
 
 static void
@@ -1244,9 +1223,8 @@ xpc_process_msg_IPI(struct xpc_partition
 		 * If anyone was waiting for message queue entries to become
 		 * available, wake them up.
 		 */
-		if (atomic_read(&ch->n_on_msg_allocate_wq) > 0) {
+		if (atomic_read(&ch->n_on_msg_allocate_wq) > 0)
 			wake_up(&ch->msg_allocate_wq);
-		}
 	}
 
 	/*
@@ -1273,9 +1251,8 @@ xpc_process_msg_IPI(struct xpc_partition
 				"delivered=%d, partid=%d, channel=%d\n",
 				nmsgs_sent, ch->partid, ch->number);
 
-			if (ch->flags & XPC_C_CONNECTEDCALLOUT_MADE) {
+			if (ch->flags & XPC_C_CONNECTEDCALLOUT_MADE)
 				xpc_activate_kthreads(ch, nmsgs_sent);
-			}
 		}
 	}
 
@@ -1310,9 +1287,8 @@ xpc_process_channel_activity(struct xpc_
 
 		IPI_flags = XPC_GET_IPI_FLAGS(IPI_amo, ch_number);
 
-		if (XPC_ANY_OPENCLOSE_IPI_FLAGS_SET(IPI_flags)) {
+		if (XPC_ANY_OPENCLOSE_IPI_FLAGS_SET(IPI_flags))
 			xpc_process_openclose_IPI(part, ch_number, IPI_flags);
-		}
 
 		ch_flags = ch->flags;	/* need an atomic snapshot of flags */
 
@@ -1323,9 +1299,8 @@ xpc_process_channel_activity(struct xpc_
 			continue;
 		}
 
-		if (part->act_state = XPC_P_DEACTIVATING) {
+		if (part->act_state = XPC_P_DEACTIVATING)
 			continue;
-		}
 
 		if (!(ch_flags & XPC_C_CONNECTED)) {
 			if (!(ch_flags & XPC_C_OPENREQUEST)) {
@@ -1345,9 +1320,8 @@ xpc_process_channel_activity(struct xpc_
 		 * from the other partition.
 		 */
 
-		if (XPC_ANY_MSG_IPI_FLAGS_SET(IPI_flags)) {
+		if (XPC_ANY_MSG_IPI_FLAGS_SET(IPI_flags))
 			xpc_process_msg_IPI(part, ch_number);
-		}
 	}
 }
 
@@ -1560,9 +1534,9 @@ xpc_disconnect_channel(const int line, s
 
 	DBUG_ON(!spin_is_locked(&ch->lock));
 
-	if (ch->flags & (XPC_C_DISCONNECTING | XPC_C_DISCONNECTED)) {
+	if (ch->flags & (XPC_C_DISCONNECTING | XPC_C_DISCONNECTED))
 		return;
-	}
+
 	DBUG_ON(!(ch->flags & (XPC_C_CONNECTING | XPC_C_CONNECTED)));
 
 	dev_dbg(xpc_chan, "reason=%d, line=%d, partid=%d, channel=%d\n",
@@ -1578,9 +1552,8 @@ xpc_disconnect_channel(const int line, s
 
 	xpc_IPI_send_closerequest(ch, irq_flags);
 
-	if (channel_was_connected) {
+	if (channel_was_connected)
 		ch->flags |= XPC_C_WASCONNECTED;
-	}
 
 	spin_unlock_irqrestore(&ch->lock, *irq_flags);
 
@@ -1595,9 +1568,8 @@ xpc_disconnect_channel(const int line, s
 	}
 
 	/* wake those waiting to allocate an entry from the local msg queue */
-	if (atomic_read(&ch->n_on_msg_allocate_wq) > 0) {
+	if (atomic_read(&ch->n_on_msg_allocate_wq) > 0)
 		wake_up(&ch->msg_allocate_wq);
-	}
 
 	spin_lock_irqsave(&ch->lock, *irq_flags);
 }
@@ -1632,7 +1604,7 @@ xpc_allocate_msg_wait(struct xpc_channel
 	enum xpc_retval ret;
 
 	if (ch->flags & XPC_C_DISCONNECTING) {
-		DBUG_ON(ch->reason = xpcInterrupted);	// >>> Is this true?
+		DBUG_ON(ch->reason = xpcInterrupted);
 		return ch->reason;
 	}
 
@@ -1642,7 +1614,7 @@ xpc_allocate_msg_wait(struct xpc_channel
 
 	if (ch->flags & XPC_C_DISCONNECTING) {
 		ret = ch->reason;
-		DBUG_ON(ch->reason = xpcInterrupted);	// >>> Is this true?
+		DBUG_ON(ch->reason = xpcInterrupted);
 	} else if (ret = 0) {
 		ret = xpcTimeout;
 	} else {
@@ -1685,9 +1657,9 @@ xpc_allocate_msg(struct xpc_channel *ch,
 
 	while (1) {
 
-		put = (volatile s64)ch->w_local_GP.put;
-		if (put - (volatile s64)ch->w_remote_GP.get <
-		    ch->local_nentries) {
+		put = ch->w_local_GP.put;
+		rmb();	/* guarantee that .put loads before .get */
+		if (put - ch->w_remote_GP.get < ch->local_nentries) {
 
 			/* There are available message entries. We need to try
 			 * to secure one for ourselves. We'll do this by trying
@@ -1711,9 +1683,8 @@ xpc_allocate_msg(struct xpc_channel *ch,
 		 * that will cause the IPI handler to fetch the latest
 		 * GP values as if an IPI was sent by the other side.
 		 */
-		if (ret = xpcTimeout) {
+		if (ret = xpcTimeout)
 			xpc_IPI_send_local_msgrequest(ch);
-		}
 
 		if (flags & XPC_NOWAIT) {
 			xpc_msgqueue_deref(ch);
@@ -1772,9 +1743,8 @@ xpc_initiate_allocate(partid_t partid, i
 		ret = xpc_allocate_msg(&part->channels[ch_number], flags, &msg);
 		xpc_part_deref(part);
 
-		if (msg != NULL) {
+		if (msg != NULL)
 			*payload = &msg->payload;
-		}
 	}
 
 	return ret;
@@ -1795,17 +1765,15 @@ xpc_send_msgs(struct xpc_channel *ch, s6
 	while (1) {
 
 		while (1) {
-			if (put = (volatile s64)ch->w_local_GP.put) {
+			if (put = ch->w_local_GP.put)
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
@@ -1818,7 +1786,7 @@ xpc_send_msgs(struct xpc_channel *ch, s6
 		if (cmpxchg_rel(&ch->local_GP->put, initial_put, put) ! 		    initial_put) {
 			/* someone else beat us to it */
-			DBUG_ON((volatile s64)ch->local_GP->put < initial_put);
+			DBUG_ON(ch->local_GP->put < initial_put);
 			break;
 		}
 
@@ -1837,9 +1805,8 @@ xpc_send_msgs(struct xpc_channel *ch, s6
 		initial_put = put;
 	}
 
-	if (send_IPI) {
+	if (send_IPI)
 		xpc_IPI_send_msgrequest(ch);
-	}
 }
 
 /*
@@ -1880,7 +1847,7 @@ xpc_send_msg(struct xpc_channel *ch, str
 		notify->key = key;
 		notify->type = notify_type;
 
-		// >>> is a mb() needed here?
+		/* >>> is a mb() needed here? */
 
 		if (ch->flags & XPC_C_DISCONNECTING) {
 			/*
@@ -1913,9 +1880,8 @@ xpc_send_msg(struct xpc_channel *ch, str
 	/* see if the message is next in line to be sent, if so send it */
 
 	put = ch->local_GP->put;
-	if (put = msg_number) {
+	if (put = msg_number)
 		xpc_send_msgs(ch, put);
-	}
 
 	/* drop the reference grabbed in xpc_allocate_msg() */
 	xpc_msgqueue_deref(ch);
@@ -2032,10 +1998,8 @@ xpc_pull_remote_msg(struct xpc_channel *
 
 		msg_index = ch->next_msg_to_pull % ch->remote_nentries;
 
-		DBUG_ON(ch->next_msg_to_pull >-			(volatile s64)ch->w_remote_GP.put);
-		nmsgs = (volatile s64)ch->w_remote_GP.put -
-		    ch->next_msg_to_pull;
+		DBUG_ON(ch->next_msg_to_pull >= ch->w_remote_GP.put);
+		nmsgs = ch->w_remote_GP.put - ch->next_msg_to_pull;
 		if (msg_index + nmsgs > ch->remote_nentries) {
 			/* ignore the ones that wrap the msg queue for now */
 			nmsgs = ch->remote_nentries - msg_index;
@@ -2046,9 +2010,9 @@ xpc_pull_remote_msg(struct xpc_channel *
 		remote_msg = (struct xpc_msg *)(ch->remote_msgqueue_pa +
 						msg_offset);
 
-		if ((ret = xpc_pull_remote_cachelines(part, msg, remote_msg,
-						      nmsgs * ch->msg_size)) !-		    xpcSuccess) {
+		ret = xpc_pull_remote_cachelines(part, msg, remote_msg,
+						 nmsgs * ch->msg_size);
+		if (ret != xpcSuccess) {
 
 			dev_dbg(xpc_chan, "failed to pull %d msgs starting with"
 				" msg %ld from partition %d, channel=%d, "
@@ -2061,8 +2025,6 @@ xpc_pull_remote_msg(struct xpc_channel *
 			return NULL;
 		}
 
-		mb();		/* >>> this may not be needed, we're not sure */
-
 		ch->next_msg_to_pull += nmsgs;
 	}
 
@@ -2085,14 +2047,13 @@ xpc_get_deliverable_msg(struct xpc_chann
 	s64 get;
 
 	do {
-		if ((volatile u32)ch->flags & XPC_C_DISCONNECTING) {
+		if (ch->flags & XPC_C_DISCONNECTING)
 			break;
-		}
 
-		get = (volatile s64)ch->w_local_GP.get;
-		if (get = (volatile s64)ch->w_remote_GP.put) {
+		get = ch->w_local_GP.get;
+		rmb();	/* guarantee that .get loads before .put */
+		if (get = ch->w_remote_GP.put)
 			break;
-		}
 
 		/* There are messages waiting to be pulled and delivered.
 		 * We need to try to secure one for ourselves. We'll do this
@@ -2132,7 +2093,8 @@ xpc_deliver_msg(struct xpc_channel *ch)
 {
 	struct xpc_msg *msg;
 
-	if ((msg = xpc_get_deliverable_msg(ch)) != NULL) {
+	msg = xpc_get_deliverable_msg(ch);
+	if (msg != NULL) {
 
 		/*
 		 * This ref is taken to protect the payload itself from being
@@ -2178,17 +2140,15 @@ xpc_acknowledge_msgs(struct xpc_channel 
 	while (1) {
 
 		while (1) {
-			if (get = (volatile s64)ch->w_local_GP.get) {
+			if (get = ch->w_local_GP.get)
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
@@ -2202,7 +2162,7 @@ xpc_acknowledge_msgs(struct xpc_channel 
 		if (cmpxchg_rel(&ch->local_GP->get, initial_get, get) ! 		    initial_get) {
 			/* someone else beat us to it */
-			DBUG_ON((volatile s64)ch->local_GP->get <= initial_get);
+			DBUG_ON(ch->local_GP->get <= initial_get);
 			break;
 		}
 
@@ -2221,9 +2181,8 @@ xpc_acknowledge_msgs(struct xpc_channel 
 		initial_get = get;
 	}
 
-	if (send_IPI) {
+	if (send_IPI)
 		xpc_IPI_send_msgrequest(ch);
-	}
 }
 
 /*
@@ -2276,9 +2235,8 @@ xpc_initiate_received(partid_t partid, i
 	 * been delivered.
 	 */
 	get = ch->local_GP->get;
-	if (get = msg_number) {
+	if (get = msg_number)
 		xpc_acknowledge_msgs(ch, get, msg->flags);
-	}
 
 	/* the call to xpc_msgqueue_ref() was done by xpc_deliver_msg()  */
 	xpc_msgqueue_deref(ch);
Index: linux-2.6/drivers/misc/sgi-xp/xpnet.c
=================================--- linux-2.6.orig/drivers/misc/sgi-xp/xpnet.c	2008-04-22 11:46:34.625831202 -0500
+++ linux-2.6/drivers/misc/sgi-xp/xpnet.c	2008-04-22 11:48:06.813241696 -0500
@@ -21,6 +21,7 @@
  */
 
 #include <linux/module.h>
+#include <linux/types.h>
 #include <linux/kernel.h>
 #include <linux/init.h>
 #include <linux/ioport.h>
@@ -34,7 +35,6 @@
 #include <asm/sn/bte.h>
 #include <asm/sn/io.h>
 #include <asm/sn/sn_sal.h>
-#include <asm/types.h>
 #include <asm/atomic.h>
 #include "xp.h"
 
@@ -87,8 +87,8 @@ struct xpnet_message {
 #define XPNET_VERSION_MAJOR(_v)		((_v) >> 4)
 #define XPNET_VERSION_MINOR(_v)		((_v) & 0xf)
 
-#define	XPNET_VERSION _XPNET_VERSION(1,0)	/* version 1.0 */
-#define	XPNET_VERSION_EMBED _XPNET_VERSION(1,1)	/* version 1.1 */
+#define	XPNET_VERSION _XPNET_VERSION(1, 0)	/* version 1.0 */
+#define	XPNET_VERSION_EMBED _XPNET_VERSION(1, 1)	/* version 1.1 */
 #define XPNET_MAGIC	0x88786984	/* "XNET" */
 
 #define XPNET_VALID_MSG(_m)						     \
@@ -236,9 +236,11 @@ xpnet_receive(partid_t partid, int chann
 				msg->size, (BTE_NOTIFY | BTE_WACQUIRE), NULL);
 
 		if (bret != BTE_SUCCESS) {
-			// >>> Need better way of cleaning skb.  Currently skb
-			// >>> appears in_use and we can't just call
-			// >>> dev_kfree_skb.
+			/*
+			 * >>> Need better way of cleaning skb.  Currently skb
+			 * >>> appears in_use and we can't just call
+			 * >>> dev_kfree_skb.
+			 */
 			dev_err(xpnet, "bte_copy(0x%p, 0x%p, 0x%hx) returned "
 				"error=0x%x\n", (void *)msg->buf_pa,
 				(void *)__pa((u64)skb->data &
@@ -314,9 +316,8 @@ xpnet_connection_activity(enum xpc_retva
 		bp = xpnet_broadcast_partitions;
 		spin_unlock_bh(&xpnet_broadcast_lock);
 
-		if (bp = 0) {
+		if (bp = 0)
 			netif_carrier_off(xpnet_device);
-		}
 
 		dev_dbg(xpnet, "%s disconnected from partition %d; "
 			"xpnet_broadcast_partitions=0x%lx\n",
@@ -527,9 +528,8 @@ xpnet_dev_hard_start_xmit(struct sk_buff
 
 		ret = xpc_allocate(dest_partid, XPC_NET_CHANNEL,
 				   XPC_NOWAIT, (void **)&msg);
-		if (unlikely(ret != xpcSuccess)) {
+		if (unlikely(ret != xpcSuccess))
 			continue;
-		}
 
 		msg->embedded_bytes = embedded_bytes;
 		if (unlikely(embedded_bytes != 0)) {
@@ -561,7 +561,6 @@ xpnet_dev_hard_start_xmit(struct sk_buff
 			atomic_dec(&queued_msg->use_count);
 			continue;
 		}
-
 	}
 
 	if (atomic_dec_return(&queued_msg->use_count) = 0) {
@@ -599,9 +598,8 @@ xpnet_init(void)
 	u32 license_num;
 	int result = -ENOMEM;
 
-	if (!ia64_platform_is("sn2")) {
+	if (!ia64_platform_is("sn2"))
 		return -ENODEV;
-	}
 
 	dev_info(xpnet, "registering network device %s\n", XPNET_DEVICE_NAME);
 
@@ -611,9 +609,8 @@ xpnet_init(void)
 	 */
 	xpnet_device = alloc_netdev(sizeof(struct xpnet_dev_private),
 				    XPNET_DEVICE_NAME, ether_setup);
-	if (xpnet_device = NULL) {
+	if (xpnet_device = NULL)
 		return -ENOMEM;
-	}
 
 	netif_carrier_off(xpnet_device);
 
@@ -654,9 +651,8 @@ xpnet_init(void)
 	xpnet_device->features = NETIF_F_NO_CSUM;
 
 	result = register_netdev(xpnet_device);
-	if (result != 0) {
+	if (result != 0)
 		free_netdev(xpnet_device);
-	}
 
 	return result;
 }
Index: linux-2.6/drivers/misc/sgi-xp/xpc_partition.c
=================================--- linux-2.6.orig/drivers/misc/sgi-xp/xpc_partition.c	2008-04-22 11:46:34.625831202 -0500
+++ linux-2.6/drivers/misc/sgi-xp/xpc_partition.c	2008-04-22 12:00:35.158192083 -0500
@@ -75,19 +75,19 @@ xpc_kmalloc_cacheline_aligned(size_t siz
 {
 	/* see if kmalloc will give us cachline aligned memory by default */
 	*base = kmalloc(size, flags);
-	if (*base = NULL) {
+	if (*base = NULL)
 		return NULL;
-	}
-	if ((u64)*base = L1_CACHE_ALIGN((u64)*base)) {
+
+	if ((u64)*base = L1_CACHE_ALIGN((u64)*base))
 		return *base;
-	}
+
 	kfree(*base);
 
 	/* nope, we'll have to do it ourselves */
 	*base = kmalloc(size + L1_CACHE_BYTES, flags);
-	if (*base = NULL) {
+	if (*base = NULL)
 		return NULL;
-	}
+
 	return (void *)L1_CACHE_ALIGN((u64)*base);
 }
 
@@ -116,9 +116,8 @@ xpc_get_rsvd_page_pa(int nasid)
 			"0x%016lx, address=0x%016lx, len=0x%016lx\n",
 			status, cookie, rp_pa, len);
 
-		if (status != SALRET_MORE_PASSES) {
+		if (status != SALRET_MORE_PASSES)
 			break;
-		}
 
 		if (L1_CACHE_ALIGN(len) > buf_len) {
 			kfree(buf_base);
@@ -145,9 +144,9 @@ xpc_get_rsvd_page_pa(int nasid)
 
 	kfree(buf_base);
 
-	if (status != SALRET_OK) {
+	if (status != SALRET_OK)
 		rp_pa = 0;
-	}
+
 	dev_dbg(xpc_part, "reserved page at phys address 0x%016lx\n", rp_pa);
 	return rp_pa;
 }
@@ -210,7 +209,8 @@ xpc_rsvd_page_init(void)
 	 * on subsequent loads of XPC. This AMO page is never freed, and its
 	 * memory protections are never restricted.
 	 */
-	if ((amos_page = xpc_vars->amos_page) = NULL) {
+	amos_page = xpc_vars->amos_page;
+	if (amos_page = NULL) {
 		amos_page = (AMO_t *)TO_AMO(uncached_alloc_page(0));
 		if (amos_page = NULL) {
 			dev_err(xpc_part, "can't allocate page of AMOs\n");
@@ -264,9 +264,8 @@ xpc_rsvd_page_init(void)
 	       XP_MAX_PARTITIONS);
 
 	/* initialize the activate IRQ related AMO variables */
-	for (i = 0; i < xp_nasid_mask_words; i++) {
+	for (i = 0; i < xp_nasid_mask_words; i++)
 		(void)xpc_IPI_init(XPC_ACTIVATE_IRQ_AMOS + i);
-	}
 
 	/* initialize the engaged remote partitions related AMO variables */
 	(void)xpc_IPI_init(XPC_ENGAGED_PARTITIONS_AMO);
@@ -294,7 +293,7 @@ xpc_allow_IPI_ops(void)
 	int node;
 	int nasid;
 
-	// >>> Change SH_IPI_ACCESS code to use SAL call once it is available.
+	/* >>> Change SH_IPI_ACCESS code to use SAL call once it is available */
 
 	if (is_shub2()) {
 		xpc_sh2_IPI_access0 @@ -336,14 +335,14 @@ xpc_allow_IPI_ops(void)
 				xpc_prot_vec[node] = (u64)HUB_L((u64 *)
 								GLOBAL_MMR_ADDR
 								(nasid,
-								 SH1_MD_DQLP_MMR_DIR_PRIVEC0));
+						  SH1_MD_DQLP_MMR_DIR_PRIVEC0));
 				HUB_S((u64 *)
 				      GLOBAL_MMR_ADDR(nasid,
-						      SH1_MD_DQLP_MMR_DIR_PRIVEC0),
+						   SH1_MD_DQLP_MMR_DIR_PRIVEC0),
 				      -1UL);
 				HUB_S((u64 *)
 				      GLOBAL_MMR_ADDR(nasid,
-						      SH1_MD_DQRP_MMR_DIR_PRIVEC0),
+						   SH1_MD_DQRP_MMR_DIR_PRIVEC0),
 				      -1UL);
 			}
 		}
@@ -360,7 +359,7 @@ xpc_restrict_IPI_ops(void)
 	int node;
 	int nasid;
 
-	// >>> Change SH_IPI_ACCESS code to use SAL call once it is available.
+	/* >>> Change SH_IPI_ACCESS code to use SAL call once it is available */
 
 	if (is_shub2()) {
 
@@ -385,10 +384,10 @@ xpc_restrict_IPI_ops(void)
 
 			if (enable_shub_wars_1_1()) {
 				HUB_S((u64 *)GLOBAL_MMR_ADDR(nasid,
-							     SH1_MD_DQLP_MMR_DIR_PRIVEC0),
+						   SH1_MD_DQLP_MMR_DIR_PRIVEC0),
 				      xpc_prot_vec[node]);
 				HUB_S((u64 *)GLOBAL_MMR_ADDR(nasid,
-							     SH1_MD_DQRP_MMR_DIR_PRIVEC0),
+						   SH1_MD_DQRP_MMR_DIR_PRIVEC0),
 				      xpc_prot_vec[node]);
 			}
 		}
@@ -411,13 +410,11 @@ xpc_check_remote_hb(void)
 
 	for (partid = 1; partid < XP_MAX_PARTITIONS; partid++) {
 
-		if (xpc_exiting) {
+		if (xpc_exiting)
 			break;
-		}
 
-		if (partid = sn_partition_id) {
+		if (partid = sn_partition_id)
 			continue;
-		}
 
 		part = &xpc_partitions[partid];
 
@@ -471,24 +468,21 @@ xpc_get_remote_rp(int nasid, u64 *discov
 	/* get the reserved page's physical address */
 
 	*remote_rp_pa = xpc_get_rsvd_page_pa(nasid);
-	if (*remote_rp_pa = 0) {
+	if (*remote_rp_pa = 0)
 		return xpcNoRsvdPageAddr;
-	}
 
 	/* pull over the reserved page header and part_nasids mask */
 	bres = xp_bte_copy(*remote_rp_pa, (u64)remote_rp,
 			   XPC_RP_HEADER_SIZE + xp_nasid_mask_bytes,
 			   (BTE_NOTIFY | BTE_WACQUIRE), NULL);
-	if (bres != BTE_SUCCESS) {
+	if (bres != BTE_SUCCESS)
 		return xpc_map_bte_errors(bres);
-	}
 
 	if (discovered_nasids != NULL) {
 		u64 *remote_part_nasids = XPC_RP_PART_NASIDS(remote_rp);
 
-		for (i = 0; i < xp_nasid_mask_words; i++) {
+		for (i = 0; i < xp_nasid_mask_words; i++)
 			discovered_nasids[i] |= remote_part_nasids[i];
-		}
 	}
 
 	/* check that the partid is for another partition */
@@ -498,9 +492,8 @@ xpc_get_remote_rp(int nasid, u64 *discov
 		return xpcInvalidPartid;
 	}
 
-	if (remote_rp->partid = sn_partition_id) {
+	if (remote_rp->partid = sn_partition_id)
 		return xpcLocalPartid;
-	}
 
 	if (XPC_VERSION_MAJOR(remote_rp->version) ! 	    XPC_VERSION_MAJOR(XPC_RP_VERSION)) {
@@ -521,16 +514,14 @@ xpc_get_remote_vars(u64 remote_vars_pa, 
 {
 	int bres;
 
-	if (remote_vars_pa = 0) {
+	if (remote_vars_pa = 0)
 		return xpcVarsNotSet;
-	}
 
 	/* pull over the cross partition variables */
 	bres = xp_bte_copy(remote_vars_pa, (u64)remote_vars, XPC_RP_VARS_SIZE,
 			   (BTE_NOTIFY | BTE_WACQUIRE), NULL);
-	if (bres != BTE_SUCCESS) {
+	if (bres != BTE_SUCCESS)
 		return xpc_map_bte_errors(bres);
-	}
 
 	if (XPC_VERSION_MAJOR(remote_vars->version) ! 	    XPC_VERSION_MAJOR(XPC_V_VERSION)) {
@@ -630,9 +621,9 @@ xpc_identify_act_IRQ_req(int nasid)
 
 	remote_vars_pa = remote_rp->vars_pa;
 	remote_rp_version = remote_rp->version;
-	if (XPC_SUPPORTS_RP_STAMP(remote_rp_version)) {
+	if (XPC_SUPPORTS_RP_STAMP(remote_rp_version))
 		remote_rp_stamp = remote_rp->stamp;
-	}
+
 	partid = remote_rp->partid;
 	part = &xpc_partitions[partid];
 
@@ -656,7 +647,8 @@ xpc_identify_act_IRQ_req(int nasid)
 		"%ld:0x%lx\n", (int)nasid, (int)partid, part->act_IRQ_rcvd,
 		remote_vars->heartbeat, remote_vars->heartbeating_to_mask);
 
-	if (xpc_partition_disengaged(part) && part->act_state = XPC_P_INACTIVE) {
+	if (xpc_partition_disengaged(part) &&
+	    part->act_state = XPC_P_INACTIVE) {
 
 		xpc_update_partition_info(part, remote_rp_version,
 					  &remote_rp_stamp, remote_rp_pa,
@@ -791,9 +783,8 @@ xpc_identify_act_IRQ_sender(void)
 	/* scan through act AMO variable looking for non-zero entries */
 	for (word = 0; word < xp_nasid_mask_words; word++) {
 
-		if (xpc_exiting) {
+		if (xpc_exiting)
 			break;
-		}
 
 		nasid_mask = xpc_IPI_receive(&act_amos[word]);
 		if (nasid_mask = 0) {
@@ -840,7 +831,8 @@ xpc_partition_disengaged(struct xpc_part
 	disengaged = (xpc_partition_engaged(1UL << partid) = 0);
 	if (part->disengage_request_timeout) {
 		if (!disengaged) {
-			if (time_before(jiffies, part->disengage_request_timeout)) {
+			if (time_before(jiffies,
+			    part->disengage_request_timeout)) {
 				/* timelimit hasn't been reached yet */
 				return 0;
 			}
@@ -866,13 +858,11 @@ xpc_partition_disengaged(struct xpc_part
 
 		DBUG_ON(part->act_state != XPC_P_DEACTIVATING &&
 			part->act_state != XPC_P_INACTIVE);
-		if (part->act_state != XPC_P_INACTIVE) {
+		if (part->act_state != XPC_P_INACTIVE)
 			xpc_wakeup_channel_mgr(part);
-		}
 
-		if (XPC_SUPPORTS_DISENGAGE_REQUEST(part->remote_vars_version)) {
+		if (XPC_SUPPORTS_DISENGAGE_REQUEST(part->remote_vars_version))
 			xpc_cancel_partition_disengage_request(part);
-		}
 	}
 	return disengaged;
 }
@@ -1000,9 +990,9 @@ xpc_discovery(void)
 	remote_rp = xpc_kmalloc_cacheline_aligned(XPC_RP_HEADER_SIZE +
 						  xp_nasid_mask_bytes,
 						  GFP_KERNEL, &remote_rp_base);
-	if (remote_rp = NULL) {
+	if (remote_rp = NULL)
 		return;
-	}
+
 	remote_vars = (struct xpc_vars *)remote_rp;
 
 	discovered_nasids = kzalloc(sizeof(u64) * xp_nasid_mask_words,
@@ -1035,18 +1025,16 @@ xpc_discovery(void)
 
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
 
@@ -1080,9 +1068,9 @@ xpc_discovery(void)
 					"from nasid %d, reason=%d\n", nasid,
 					ret);
 
-				if (ret = xpcLocalPartid) {
+				if (ret = xpcLocalPartid)
 					break;
-				}
+
 				continue;
 			}
 
@@ -1171,9 +1159,8 @@ xpc_initiate_partid_to_nasids(partid_t p
 	int bte_res;
 
 	part = &xpc_partitions[partid];
-	if (part->remote_rp_pa = 0) {
+	if (part->remote_rp_pa = 0)
 		return xpcPartitionDown;
-	}
 
 	memset(nasid_mask, 0, XP_NASID_MASK_BYTES);
 
