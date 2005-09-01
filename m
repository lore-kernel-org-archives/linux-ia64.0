From: dcn@sgi.com (Dean Nelson)
Date: Thu, 01 Sep 2005 19:01:37 +0000
Subject: [PATCH] get XPC to cleanly disengage from remote memory
Message-Id: <43175011.mailxATR1187F3@aqua.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

When XPC is being shutdown (i.e., rmmod, reboot) it doesn't ensure that
other partitions with whom it was connected have completely disengaged
from any attempt at cross-partition memory references. This can lead to
MCAs in any of these other partitions when the partition is reset.

Signed-off-by: Dean Nelson <dcn@sgi.com>


 arch/ia64/sn/kernel/xpc.h           |  288 ++++++++++++++++++++++++++++++---
 arch/ia64/sn/kernel/xpc_channel.c   |  216 +++++++++++++-----------
 arch/ia64/sn/kernel/xpc_main.c      |  244 ++++++++++++++++++++--------
 arch/ia64/sn/kernel/xpc_partition.c |  312 +++++++++++++++++++++++++++++------- include/asm-ia64/sn/xp.h            |   10 +
 5 files changed, 827 insertions(+), 243 deletions(-)


Index: release/include/asm-ia64/sn/xp.h
=================================--- release.orig/include/asm-ia64/sn/xp.h	2005-08-31 11:08:50.287012929 -0500
+++ release/include/asm-ia64/sn/xp.h	2005-08-31 11:47:37.206930056 -0500
@@ -217,7 +217,15 @@
 	xpcInvalidPartid,	/* 42: invalid partition ID */
 	xpcLocalPartid,		/* 43: local partition ID */
 
-	xpcUnknownReason	/* 44: unknown reason -- must be last in list */
+	xpcOtherGoingDown,	/* 44: other side going down, reason unknown */
+	xpcSystemGoingDown,	/* 45: system is going down, reason unknown */
+	xpcSystemHalt,		/* 46: system is being halted */
+	xpcSystemReboot,	/* 47: system is being rebooted */
+	xpcSystemPoweroff,	/* 48: system is being powered off */
+
+	xpcDisconnecting,	/* 49: channel disconnecting (closing) */
+
+	xpcUnknownReason	/* 50: unknown reason -- must be last in list */
 };
 
 
Index: release/arch/ia64/sn/kernel/xpc.h
=================================--- release.orig/arch/ia64/sn/kernel/xpc.h	2005-08-31 11:08:50.287989393 -0500
+++ release/arch/ia64/sn/kernel/xpc.h	2005-08-31 12:57:34.915221539 -0500
@@ -57,7 +57,7 @@
 #define XPC_NASID_FROM_W_B(_w, _b) (((_w) * 64 + (_b)) * 2)
 
 #define XPC_HB_DEFAULT_INTERVAL		5	/* incr HB every x secs */
-#define XPC_HB_CHECK_DEFAULT_TIMEOUT	20	/* check HB every x secs */
+#define XPC_HB_CHECK_DEFAULT_INTERVAL	20	/* check HB every x secs */
 
 /* define the process name of HB checker and the CPU it is pinned to */
 #define XPC_HB_CHECK_THREAD_NAME	"xpc_hb"
@@ -67,11 +67,6 @@
 #define XPC_DISCOVERY_THREAD_NAME	"xpc_discovery"
 
 
-#define XPC_HB_ALLOWED(_p, _v)	((_v)->heartbeating_to_mask & (1UL << (_p)))
-#define XPC_ALLOW_HB(_p, _v)	(_v)->heartbeating_to_mask |= (1UL << (_p))
-#define XPC_DISALLOW_HB(_p, _v)	(_v)->heartbeating_to_mask &= (~(1UL << (_p)))
-
-
 /*
  * Reserved Page provided by SAL.
  *
@@ -88,14 +83,38 @@
 	u8 version;
 	u8 pad[6];		/* pad to u64 align */
 	volatile u64 vars_pa;
+	struct timespec stamp;	/* time when reserved page was initialized */
 	u64 part_nasids[XP_NASID_MASK_WORDS] ____cacheline_aligned;
 	u64 mach_nasids[XP_NASID_MASK_WORDS] ____cacheline_aligned;
 };
-#define XPC_RP_VERSION _XPC_VERSION(1,0) /* version 1.0 of the reserved page */
 
 #define XPC_RSVD_PAGE_ALIGNED_SIZE \
 			(L1_CACHE_ALIGN(sizeof(struct xpc_rsvd_page)))
 
+#define XPC_RP_VERSION _XPC_VERSION(1,1) /* version 1.1 of the reserved page */
+
+#define XPC_SUPPORTS_RP_STAMP(_version) \
+			(_version >= _XPC_VERSION(1,1))
+
+/*
+ * compare stamps - the return value is:
+ *
+ *	< 0,	if stamp1 < stamp2
+ *	= 0,	if stamp1 = stamp2
+ *	> 0,	if stamp1 > stamp2
+ */
+static inline int
+xpc_compare_stamps(struct timespec *stamp1, struct timespec *stamp2)
+{
+	int ret;
+
+
+	if ((ret = stamp1->tv_sec - stamp2->tv_sec) = 0) {
+		ret = stamp1->tv_nsec - stamp2->tv_nsec;
+	}
+	return ret;
+}
+
 
 /*
  * Define the structures by which XPC variables can be exported to other
@@ -121,12 +140,61 @@
 	u64 vars_part_pa;
 	u64 amos_page_pa;	/* paddr of page of AMOs from MSPEC driver */
 	AMO_t *amos_page;	/* vaddr of page of AMOs from MSPEC driver */
-	AMO_t *act_amos;	/* pointer to the first activation AMO */
 };
-#define XPC_V_VERSION _XPC_VERSION(3,0) /* version 3.0 of the cross vars */
 
 #define XPC_VARS_ALIGNED_SIZE  (L1_CACHE_ALIGN(sizeof(struct xpc_vars)))
 
+#define XPC_V_VERSION _XPC_VERSION(3,1) /* version 3.1 of the cross vars */
+
+#define XPC_SUPPORTS_DISENGAGE_REQUEST(_version) \
+			(_version >= _XPC_VERSION(3,1))
+
+
+static inline int
+xpc_hb_allowed(partid_t partid, struct xpc_vars *vars)
+{
+	return ((vars->heartbeating_to_mask & (1UL << partid)) != 0);
+}
+
+static inline void
+xpc_allow_hb(partid_t partid, struct xpc_vars *vars)
+{
+	u64 old_mask, new_mask;
+
+	do {
+		old_mask = vars->heartbeating_to_mask;
+		new_mask = (old_mask | (1UL << partid));
+	} while (cmpxchg(&vars->heartbeating_to_mask, old_mask, new_mask) !+							old_mask);
+}
+
+static inline void
+xpc_disallow_hb(partid_t partid, struct xpc_vars *vars)
+{
+	u64 old_mask, new_mask;
+
+	do {
+		old_mask = vars->heartbeating_to_mask;
+		new_mask = (old_mask & ~(1UL << partid));
+	} while (cmpxchg(&vars->heartbeating_to_mask, old_mask, new_mask) !+							old_mask);
+}
+
+
+/*
+ * The AMOs page consists of a number of AMO variables which are divided into
+ * four groups, The first two groups are used to identify an IRQ's sender.
+ * These two groups consist of 64 and 16 AMO variables respectively. The last
+ * two groups, consisting of just one AMO variable each, are used to identify
+ * the remote partitions that are currently engaged (from the viewpoint of
+ * the XPC running on the remote partition).
+ */
+#define XPC_NOTIFY_IRQ_AMOS	   0
+#define XPC_ACTIVATE_IRQ_AMOS	   (XPC_NOTIFY_IRQ_AMOS + XP_MAX_PARTITIONS)
+#define XPC_ENGAGED_PARTITIONS_AMO (XPC_ACTIVATE_IRQ_AMOS + XP_NASID_MASK_WORDS)
+#define XPC_DISENGAGE_REQUEST_AMO  (XPC_ENGAGED_PARTITIONS_AMO + 1)
+
+
 /*
  * The following structure describes the per partition specific variables.
  *
@@ -358,7 +426,7 @@
 	void *key;			/* pointer to user's key */
 
 	struct semaphore msg_to_pull_sema; /* next msg to pull serialization */
-	struct semaphore teardown_sema;    /* wait for teardown completion */
+	struct semaphore wdisconnect_sema; /* wait for channel disconnect */
 
 	struct xpc_openclose_args *local_openclose_args; /* args passed on */
 					/* opening or closing of channel */
@@ -410,6 +478,7 @@
 
 #define	XPC_C_DISCONNECTED	0x00002000 /* channel is disconnected */
 #define	XPC_C_DISCONNECTING	0x00004000 /* channel is being disconnected */
+#define	XPC_C_WDISCONNECT	0x00008000 /* waiting for channel disconnect */
 
 
 
@@ -422,6 +491,8 @@
 
 	/* XPC HB infrastructure */
 
+	u8 remote_rp_version;		/* version# of partition's rsvd pg */
+	struct timespec remote_rp_stamp;/* time when rsvd pg was initialized */
 	u64 remote_rp_pa;		/* phys addr of partition's rsvd pg */
 	u64 remote_vars_pa;		/* phys addr of partition's vars */
 	u64 remote_vars_part_pa;	/* phys addr of partition's vars part */
@@ -432,10 +503,14 @@
 	u32 act_IRQ_rcvd;		/* IRQs since activation */
 	spinlock_t act_lock;		/* protect updating of act_state */
 	u8 act_state;			/* from XPC HB viewpoint */
+	u8 remote_vars_version;		/* version# of partition's vars */
 	enum xpc_retval reason;		/* reason partition is deactivating */
 	int reason_line;		/* line# deactivation initiated from */
 	int reactivate_nasid;		/* nasid in partition to reactivate */
 
+	unsigned long disengage_request_timeout; /* timeout in XPC_TICKS */
+	struct timer_list disengage_request_timer;
+
 
 	/* XPC infrastructure referencing and teardown control */
 
@@ -454,6 +529,7 @@
 
 	u8 nchannels;		   /* #of defined channels supported */
 	atomic_t nchannels_active; /* #of channels that are not DISCONNECTED */
+	atomic_t nchannels_engaged;/* #of channels engaged with remote part */
 	struct xpc_channel *channels;/* array of channel structures */
 
 	void *local_GPs_base;	  /* base address of kmalloc'd space */
@@ -518,6 +594,7 @@
 #define XPC_P_TORNDOWN		0x03	/* infrastructure is torndown */
 
 
+
 /*
  * struct xpc_partition IPI_timer #of seconds to wait before checking for
  * dropped IPIs. These occur whenever an IPI amo write doesn't complete until
@@ -526,6 +603,13 @@
 #define XPC_P_DROPPED_IPI_WAIT	(0.25 * HZ)
 
 
+/* number of seconds to wait for other partitions to disengage */
+#define XPC_DISENGAGE_REQUEST_TIMELIMIT 90
+
+/* interval in seconds to print 'waiting disengagement' messages */
+#define XPC_DISENGAGE_PRINTMSG_INTERVAL		10
+
+
 #define XPC_PARTID(_p)	((partid_t) ((_p) - &xpc_partitions[0]))
 
 
@@ -550,8 +634,6 @@
 
 /* found in xpc_partition.c */
 extern int xpc_exiting;
-extern int xpc_hb_interval;
-extern int xpc_hb_check_interval;
 extern struct xpc_vars *xpc_vars;
 extern struct xpc_rsvd_page *xpc_rsvd_page;
 extern struct xpc_vars_part *xpc_vars_part;
@@ -561,6 +643,7 @@
 extern void xpc_allow_IPI_ops(void);
 extern void xpc_restrict_IPI_ops(void);
 extern int xpc_identify_act_IRQ_sender(void);
+extern int xpc_partition_disengaged(struct xpc_partition *);
 extern enum xpc_retval xpc_mark_partition_active(struct xpc_partition *);
 extern void xpc_mark_partition_inactive(struct xpc_partition *);
 extern void xpc_discovery(void);
@@ -585,8 +668,8 @@
 extern void xpc_deliver_msg(struct xpc_channel *);
 extern void xpc_disconnect_channel(const int, struct xpc_channel *,
 					enum xpc_retval, unsigned long *);
-extern void xpc_disconnected_callout(struct xpc_channel *);
-extern void xpc_partition_down(struct xpc_partition *, enum xpc_retval);
+extern void xpc_disconnecting_callout(struct xpc_channel *);
+extern void xpc_partition_going_down(struct xpc_partition *, enum xpc_retval);
 extern void xpc_teardown_infrastructure(struct xpc_partition *);
 
 
@@ -674,6 +757,157 @@
 
 
 /*
+ * This next set of inlines are used to keep track of when a partition is
+ * potentially engaged in accessing memory belonging to another partition.
+ */
+
+static inline void
+xpc_mark_partition_engaged(struct xpc_partition *part)
+{
+	unsigned long irq_flags;
+	AMO_t *amo = (AMO_t *) __va(part->remote_amos_page_pa +
+				(XPC_ENGAGED_PARTITIONS_AMO * sizeof(AMO_t)));
+
+
+	local_irq_save(irq_flags);
+
+	/* set bit corresponding to our partid in remote partition's AMO */
+	FETCHOP_STORE_OP(TO_AMO((u64) &amo->variable), FETCHOP_OR,
+						(1UL << sn_partition_id));
+	/*
+	 * We must always use the nofault function regardless of whether we
+	 * are on a Shub 1.1 system or a Shub 1.2 slice 0xc processor. If we
+	 * didn't, we'd never know that the other partition is down and would
+	 * keep sending IPIs and AMOs to it until the heartbeat times out.
+	 */
+	(void) xp_nofault_PIOR((u64 *) GLOBAL_MMR_ADDR(NASID_GET(&amo->
+				variable), xp_nofault_PIOR_target));
+
+	local_irq_restore(irq_flags);
+}
+
+static inline void
+xpc_mark_partition_disengaged(struct xpc_partition *part)
+{
+	unsigned long irq_flags;
+	AMO_t *amo = (AMO_t *) __va(part->remote_amos_page_pa +
+				(XPC_ENGAGED_PARTITIONS_AMO * sizeof(AMO_t)));
+
+
+	local_irq_save(irq_flags);
+
+	/* clear bit corresponding to our partid in remote partition's AMO */
+	FETCHOP_STORE_OP(TO_AMO((u64) &amo->variable), FETCHOP_AND,
+						~(1UL << sn_partition_id));
+	/*
+	 * We must always use the nofault function regardless of whether we
+	 * are on a Shub 1.1 system or a Shub 1.2 slice 0xc processor. If we
+	 * didn't, we'd never know that the other partition is down and would
+	 * keep sending IPIs and AMOs to it until the heartbeat times out.
+	 */
+	(void) xp_nofault_PIOR((u64 *) GLOBAL_MMR_ADDR(NASID_GET(&amo->
+				variable), xp_nofault_PIOR_target));
+
+	local_irq_restore(irq_flags);
+}
+
+static inline void
+xpc_request_partition_disengage(struct xpc_partition *part)
+{
+	unsigned long irq_flags;
+	AMO_t *amo = (AMO_t *) __va(part->remote_amos_page_pa +
+				(XPC_DISENGAGE_REQUEST_AMO * sizeof(AMO_t)));
+
+
+	local_irq_save(irq_flags);
+
+	/* set bit corresponding to our partid in remote partition's AMO */
+	FETCHOP_STORE_OP(TO_AMO((u64) &amo->variable), FETCHOP_OR,
+						(1UL << sn_partition_id));
+	/*
+	 * We must always use the nofault function regardless of whether we
+	 * are on a Shub 1.1 system or a Shub 1.2 slice 0xc processor. If we
+	 * didn't, we'd never know that the other partition is down and would
+	 * keep sending IPIs and AMOs to it until the heartbeat times out.
+	 */
+	(void) xp_nofault_PIOR((u64 *) GLOBAL_MMR_ADDR(NASID_GET(&amo->
+				variable), xp_nofault_PIOR_target));
+
+	local_irq_restore(irq_flags);
+}
+
+static inline void
+xpc_cancel_partition_disengage_request(struct xpc_partition *part)
+{
+	unsigned long irq_flags;
+	AMO_t *amo = (AMO_t *) __va(part->remote_amos_page_pa +
+				(XPC_DISENGAGE_REQUEST_AMO * sizeof(AMO_t)));
+
+
+	local_irq_save(irq_flags);
+
+	/* clear bit corresponding to our partid in remote partition's AMO */
+	FETCHOP_STORE_OP(TO_AMO((u64) &amo->variable), FETCHOP_AND,
+						~(1UL << sn_partition_id));
+	/*
+	 * We must always use the nofault function regardless of whether we
+	 * are on a Shub 1.1 system or a Shub 1.2 slice 0xc processor. If we
+	 * didn't, we'd never know that the other partition is down and would
+	 * keep sending IPIs and AMOs to it until the heartbeat times out.
+	 */
+	(void) xp_nofault_PIOR((u64 *) GLOBAL_MMR_ADDR(NASID_GET(&amo->
+				variable), xp_nofault_PIOR_target));
+
+	local_irq_restore(irq_flags);
+}
+
+static inline u64
+xpc_partition_engaged(u64 partid_mask)
+{
+	AMO_t *amo = xpc_vars->amos_page + XPC_ENGAGED_PARTITIONS_AMO;
+
+
+	/* return our partition's AMO variable ANDed with partid_mask */
+	return (FETCHOP_LOAD_OP(TO_AMO((u64) &amo->variable), FETCHOP_LOAD) &
+								partid_mask);
+}
+
+static inline u64
+xpc_partition_disengage_requested(u64 partid_mask)
+{
+	AMO_t *amo = xpc_vars->amos_page + XPC_DISENGAGE_REQUEST_AMO;
+
+
+	/* return our partition's AMO variable ANDed with partid_mask */
+	return (FETCHOP_LOAD_OP(TO_AMO((u64) &amo->variable), FETCHOP_LOAD) &
+								partid_mask);
+}
+
+static inline void
+xpc_clear_partition_engaged(u64 partid_mask)
+{
+	AMO_t *amo = xpc_vars->amos_page + XPC_ENGAGED_PARTITIONS_AMO;
+
+
+	/* clear bit(s) based on partid_mask in our partition's AMO */
+	FETCHOP_STORE_OP(TO_AMO((u64) &amo->variable), FETCHOP_AND,
+								~partid_mask);
+}
+
+static inline void
+xpc_clear_partition_disengage_request(u64 partid_mask)
+{
+	AMO_t *amo = xpc_vars->amos_page + XPC_DISENGAGE_REQUEST_AMO;
+
+
+	/* clear bit(s) based on partid_mask in our partition's AMO */
+	FETCHOP_STORE_OP(TO_AMO((u64) &amo->variable), FETCHOP_AND,
+								~partid_mask);
+}
+
+
+
+/*
  * The following set of macros and inlines are used for the sending and
  * receiving of IPIs (also known as IRQs). There are two flavors of IPIs,
  * one that is associated with partition activity (SGI_XPC_ACTIVATE) and
@@ -722,13 +956,13 @@
  * Flag the appropriate AMO variable and send an IPI to the specified node.
  */
 static inline void
-xpc_activate_IRQ_send(u64 amos_page, int from_nasid, int to_nasid,
+xpc_activate_IRQ_send(u64 amos_page_pa, int from_nasid, int to_nasid,
 			int to_phys_cpuid)
 {
 	int w_index = XPC_NASID_W_INDEX(from_nasid);
 	int b_index = XPC_NASID_B_INDEX(from_nasid);
-	AMO_t *amos = (AMO_t *) __va(amos_page +
-					(XP_MAX_PARTITIONS * sizeof(AMO_t)));
+	AMO_t *amos = (AMO_t *) __va(amos_page_pa +
+				(XPC_ACTIVATE_IRQ_AMOS * sizeof(AMO_t)));
 
 
 	(void) xpc_IPI_send(&amos[w_index], (1UL << b_index), to_nasid,
@@ -756,6 +990,13 @@
 				xpc_vars->act_nasid, xpc_vars->act_phys_cpuid);
 }
 
+static inline void
+xpc_IPI_send_disengage(struct xpc_partition *part)
+{
+	xpc_activate_IRQ_send(part->remote_amos_page_pa, cnodeid_to_nasid(0),
+			part->remote_act_nasid, part->remote_act_phys_cpuid);
+}
+
 
 /*
  * IPIs associated with SGI_XPC_NOTIFY IRQ.
@@ -903,17 +1144,18 @@
  * cacheable mapping for the entire region. This will prevent speculative
  * reading of cached copies of our lines from being issued which will cause
  * a PI FSB Protocol error to be generated by the SHUB. For XPC, we need 64
- * (XP_MAX_PARTITIONS) AMO variables for message notification (xpc_main.c)
- * and an additional 16 AMO variables for partition activation (xpc_hb.c).
+ * (XP_MAX_PARTITIONS) AMO variables for message notification and an
+ * additional 16 (XP_NASID_MASK_WORDS) AMO variables for partition activation
+ * and 2 AMO variables for partition deactivation.
  */
 static inline AMO_t *
-xpc_IPI_init(partid_t partid)
+xpc_IPI_init(int index)
 {
-	AMO_t *part_amo = xpc_vars->amos_page + partid;
+	AMO_t *amo = xpc_vars->amos_page + index;
 
 
-	xpc_IPI_receive(part_amo);
-	return part_amo;
+	(void) xpc_IPI_receive(amo);	/* clear AMO variable */
+	return amo;
 }
 
 
Index: release/arch/ia64/sn/kernel/xpc_main.c
=================================--- release.orig/arch/ia64/sn/kernel/xpc_main.c	2005-08-31 11:08:50.287989393 -0500
+++ release/arch/ia64/sn/kernel/xpc_main.c	2005-08-31 12:49:52.265295281 -0500
@@ -54,6 +54,7 @@
 #include <linux/interrupt.h>
 #include <linux/slab.h>
 #include <linux/delay.h>
+#include <linux/reboot.h>
 #include <asm/sn/intr.h>
 #include <asm/sn/sn_sal.h>
 #include <asm/uaccess.h>
@@ -82,11 +83,13 @@
 
 /* systune related variables for /proc/sys directories */
 
-static int xpc_hb_min = 1;
-static int xpc_hb_max = 10;
-
-static int xpc_hb_check_min = 10;
-static int xpc_hb_check_max = 120;
+static int xpc_hb_interval = XPC_HB_DEFAULT_INTERVAL;
+static int xpc_hb_min_interval = 1;
+static int xpc_hb_max_interval = 10;
+
+static int xpc_hb_check_interval = XPC_HB_CHECK_DEFAULT_INTERVAL;
+static int xpc_hb_check_min_interval = 10;
+static int xpc_hb_check_max_interval = 120;
 
 static ctl_table xpc_sys_xpc_hb_dir[] = {
 	{
@@ -99,7 +102,8 @@
 		&proc_dointvec_minmax,
 		&sysctl_intvec,
 		NULL,
-		&xpc_hb_min, &xpc_hb_max
+		&xpc_hb_min_interval,
+		&xpc_hb_max_interval
 	},
 	{
 		2,
@@ -111,7 +115,8 @@
 		&proc_dointvec_minmax,
 		&sysctl_intvec,
 		NULL,
-		&xpc_hb_check_min, &xpc_hb_check_max
+		&xpc_hb_check_min_interval,
+		&xpc_hb_check_max_interval
 	},
 	{0}
 };
@@ -148,11 +153,11 @@
 
 static unsigned long xpc_hb_check_timeout;
 
-/* xpc_hb_checker thread exited notification */
-static DECLARE_MUTEX_LOCKED(xpc_hb_checker_exited);
+/* used as an indication of when the xpc_hb_checker thread is inactive */
+static DECLARE_MUTEX_LOCKED(xpc_hb_checker_inactive);
 
-/* xpc_discovery thread exited notification */
-static DECLARE_MUTEX_LOCKED(xpc_discovery_exited);
+/* used as an indication of when the xpc_discovery thread is inactive */
+static DECLARE_MUTEX_LOCKED(xpc_discovery_inactive);
 
 
 static struct timer_list xpc_hb_timer;
@@ -161,6 +166,30 @@
 static void xpc_kthread_waitmsgs(struct xpc_partition *, struct xpc_channel *);
 
 
+static int xpc_system_reboot(struct notifier_block *, unsigned long, void *);
+static struct notifier_block xpc_reboot_notifier = {
+	.notifier_call = xpc_system_reboot,
+};
+
+
+/*
+ * Timer function to enforce the timelimit on the partition disengage request.
+ */
+static void
+xpc_timeout_partition_disengage_request(unsigned long data)
+{
+	struct xpc_partition *part = (struct xpc_partition *) data;
+
+
+	DBUG_ON(XPC_TICKS < part->disengage_request_timeout);
+
+	(void) xpc_partition_disengaged(part);
+
+	DBUG_ON(part->disengage_request_timeout != 0);
+	DBUG_ON(xpc_partition_engaged(1UL << XPC_PARTID(part)) != 0);
+}
+
+
 /*
  * Notify the heartbeat check thread that an IRQ has been received.
  */
@@ -214,12 +243,6 @@
 
 	while (!(volatile int) xpc_exiting) {
 
-		/* wait for IRQ or timeout */
-		(void) wait_event_interruptible(xpc_act_IRQ_wq,
-			    (last_IRQ_count < atomic_read(&xpc_act_IRQ_rcvd) ||
-					jiffies >= xpc_hb_check_timeout ||
-						(volatile int) xpc_exiting));
-
 		dev_dbg(xpc_part, "woke up with %d ticks rem; %d IRQs have "
 			"been received\n",
 			(int) (xpc_hb_check_timeout - jiffies),
@@ -240,6 +263,7 @@
 		}
 
 
+		/* check for outstanding IRQs */
 		new_IRQ_count = atomic_read(&xpc_act_IRQ_rcvd);
 		if (last_IRQ_count < new_IRQ_count || force_IRQ != 0) {
 			force_IRQ = 0;
@@ -257,13 +281,19 @@
 			xpc_hb_check_timeout = jiffies +
 					   (xpc_hb_check_interval * HZ);
 		}
+
+		/* wait for IRQ or timeout */
+		(void) wait_event_interruptible(xpc_act_IRQ_wq,
+			    (last_IRQ_count < atomic_read(&xpc_act_IRQ_rcvd) ||
+					jiffies >= xpc_hb_check_timeout ||
+						(volatile int) xpc_exiting));
 	}
 
 	dev_dbg(xpc_part, "heartbeat checker is exiting\n");
 
 
 	/* mark this thread as inactive */
-	up(&xpc_hb_checker_exited);
+	up(&xpc_hb_checker_inactive);
 	return 0;
 }
 
@@ -283,7 +313,7 @@
 	dev_dbg(xpc_part, "discovery thread is exiting\n");
 
 	/* mark this thread as inactive */
-	up(&xpc_discovery_exited);
+	up(&xpc_discovery_inactive);
 	return 0;
 }
 
@@ -309,7 +339,7 @@
 			"partition %d\n", XPC_PARTID(part));
 
 		/* wait a 1/4 of a second or so */
-		msleep_interruptible(250);
+		(void) msleep_interruptible(250);
 
 		if (part->act_state = XPC_P_DEACTIVATING) {
 			return part->reason;
@@ -336,7 +366,8 @@
 xpc_channel_mgr(struct xpc_partition *part)
 {
 	while (part->act_state != XPC_P_DEACTIVATING ||
-				atomic_read(&part->nchannels_active) > 0) {
+			atomic_read(&part->nchannels_active) > 0 ||
+					!xpc_partition_disengaged(part)) {
 
 		xpc_process_channel_activity(part);
 
@@ -360,7 +391,8 @@
 				(volatile u64) part->local_IPI_amo != 0 ||
 				((volatile u8) part->act_state =
 							XPC_P_DEACTIVATING &&
-				atomic_read(&part->nchannels_active) = 0)));
+				atomic_read(&part->nchannels_active) = 0 &&
+				xpc_partition_disengaged(part))));
 		atomic_set(&part->channel_mgr_requests, 1);
 
 		// >>> Does it need to wakeup periodically as well? In case we
@@ -482,7 +514,7 @@
 		return 0;
 	}
 
-	XPC_ALLOW_HB(partid, xpc_vars);
+	xpc_allow_hb(partid, xpc_vars);
 	xpc_IPI_send_activated(part);
 
 
@@ -492,6 +524,7 @@
 	 */
 	(void) xpc_partition_up(part);
 
+	xpc_disallow_hb(partid, xpc_vars);
 	xpc_mark_partition_inactive(part);
 
 	if (part->reason = xpcReactivating) {
@@ -704,11 +737,14 @@
 		xpc_kthread_waitmsgs(part, ch);
 	}
 
-	if (atomic_dec_return(&ch->kthreads_assigned) = 0 &&
-			((ch->flags & XPC_C_CONNECTCALLOUT) ||
-				(ch->reason != xpcUnregistering &&
-					ch->reason != xpcOtherUnregistering))) {
-		xpc_disconnected_callout(ch);
+	if (atomic_dec_return(&ch->kthreads_assigned) = 0) {
+		if (ch->flags & XPC_C_CONNECTCALLOUT) {
+			xpc_disconnecting_callout(ch);
+		}
+		if (atomic_dec_return(&part->nchannels_engaged) = 0) {
+			xpc_mark_partition_disengaged(part);
+			xpc_IPI_send_disengage(part);
+		}
 	}
 
 
@@ -740,6 +776,7 @@
 	unsigned long irq_flags;
 	pid_t pid;
 	u64 args = XPC_PACK_ARGS(ch->partid, ch->number);
+	struct xpc_partition *part = &xpc_partitions[ch->partid];
 
 
 	while (needed-- > 0) {
@@ -770,9 +807,13 @@
 		 * kthread. That kthread is responsible for doing the
 		 * counterpart to the following before it exits.
 		 */
-		(void) xpc_part_ref(&xpc_partitions[ch->partid]);
+		(void) xpc_part_ref(part);
 		xpc_msgqueue_ref(ch);
-		atomic_inc(&ch->kthreads_assigned);
+		if (atomic_inc_return(&ch->kthreads_assigned) = 1) {
+			if (atomic_inc_return(&part->nchannels_engaged) = 1) {
+				xpc_mark_partition_engaged(part);
+			}
+		}
 		ch->kthreads_created++;	// >>> temporary debug only!!!
 	}
 }
@@ -781,6 +822,7 @@
 void
 xpc_disconnect_wait(int ch_number)
 {
+	unsigned long irq_flags;
 	partid_t partid;
 	struct xpc_partition *part;
 	struct xpc_channel *ch;
@@ -793,10 +835,13 @@
 		if (xpc_part_ref(part)) {
 			ch = &part->channels[ch_number];
 
-// >>> how do we keep from falling into the window between our check and going
-// >>> down and coming back up where sema is re-inited?
-			if (ch->flags & XPC_C_SETUP) {
-				(void) down(&ch->teardown_sema);
+			if (ch->flags & XPC_C_WDISCONNECT) {
+				if (!(ch->flags & XPC_C_DISCONNECTED)) {
+					(void) down(&ch->wdisconnect_sema);
+				}
+				spin_lock_irqsave(&ch->lock, irq_flags);
+				ch->flags &= ~XPC_C_WDISCONNECT;
+				spin_unlock_irqrestore(&ch->lock, irq_flags);
 			}
 
 			xpc_part_deref(part);
@@ -806,62 +851,89 @@
 
 
 static void
-xpc_do_exit(void)
+xpc_do_exit(enum xpc_retval reason)
 {
 	partid_t partid;
 	int active_part_count;
 	struct xpc_partition *part;
+	unsigned long printmsg_time;
 
 
-	/* now it's time to eliminate our heartbeat */
-	del_timer_sync(&xpc_hb_timer);
-	xpc_vars->heartbeating_to_mask = 0;
-
-	/* indicate to others that our reserved page is uninitialized */
-	xpc_rsvd_page->vars_pa = 0;
-
-	/*
-	 * Ignore all incoming interrupts. Without interupts the heartbeat
-	 * checker won't activate any new partitions that may come up.
-	 */
-	free_irq(SGI_XPC_ACTIVATE, NULL);
+	/* a 'rmmod XPC' and a 'reboot' cannot both end up here together */
+	DBUG_ON(xpc_exiting = 1);
 
 	/*
-	 * Cause the heartbeat checker and the discovery threads to exit.
-	 * We don't want them attempting to activate new partitions as we
-	 * try to deactivate the existing ones.
+	 * Let the heartbeat checker thread and the discovery thread
+	 * (if one is running) know that they should exit. Also wake up
+	 * the heartbeat checker thread in case it's sleeping.
 	 */
 	xpc_exiting = 1;
 	wake_up_interruptible(&xpc_act_IRQ_wq);
 
-	/* wait for the heartbeat checker thread to mark itself inactive */
-	down(&xpc_hb_checker_exited);
+	/* ignore all incoming interrupts */
+	free_irq(SGI_XPC_ACTIVATE, NULL);
 
 	/* wait for the discovery thread to mark itself inactive */
-	down(&xpc_discovery_exited);
+	down(&xpc_discovery_inactive);
+
+	/* wait for the heartbeat checker thread to mark itself inactive */
+	down(&xpc_hb_checker_inactive);
 
 
-	msleep_interruptible(300);
+	/* sleep for a 1/3 of a second or so */
+	(void) msleep_interruptible(300);
 
 
 	/* wait for all partitions to become inactive */
 
+	printmsg_time = jiffies;
+
 	do {
 		active_part_count = 0;
 
 		for (partid = 1; partid < XP_MAX_PARTITIONS; partid++) {
 			part = &xpc_partitions[partid];
-			if (part->act_state != XPC_P_INACTIVE) {
-				active_part_count++;
-
-				XPC_DEACTIVATE_PARTITION(part, xpcUnloading);
+			if (xpc_partition_disengaged(part) &&
+					part->act_state = XPC_P_INACTIVE) {
+				continue;
 			}
+
+			active_part_count++;
+
+			XPC_DEACTIVATE_PARTITION(part, reason);
 		}
 
-		if (active_part_count)
-			msleep_interruptible(300);
-	} while (active_part_count > 0);
+		if (active_part_count = 0) {
+			break;
+		}
+
+		if (jiffies >= printmsg_time) {
+			dev_info(xpc_part, "waiting for partitions to "
+				"deactivate/disengage, active count=%d, remote "
+				"engaged=0x%lx\n", active_part_count,
+				xpc_partition_engaged(1UL << partid));
+
+			printmsg_time = jiffies +
+					(XPC_DISENGAGE_PRINTMSG_INTERVAL * HZ);
+		}
+
+		/* sleep for a 1/3 of a second or so */
+		(void) msleep_interruptible(300);
+
+	} while (1);
+
+	DBUG_ON(xpc_partition_engaged(-1UL));
+
+
+	/* indicate to others that our reserved page is uninitialized */
+	xpc_rsvd_page->vars_pa = 0;
+
+	/* now it's time to eliminate our heartbeat */
+	del_timer_sync(&xpc_hb_timer);
+	DBUG_ON(xpc_vars->heartbeating_to_mask = 0);
 
+	/* take ourselves off of the reboot_notifier_list */
+	(void) unregister_reboot_notifier(&xpc_reboot_notifier);
 
 	/* close down protections for IPI operations */
 	xpc_restrict_IPI_ops();
@@ -876,6 +948,34 @@
 }
 
 
+/*
+ * This function is called when the system is being rebooted.
+ */
+static int
+xpc_system_reboot(struct notifier_block *nb, unsigned long event, void *unused)
+{
+	enum xpc_retval reason;
+
+
+	switch (event) {
+	case SYS_RESTART:
+		reason = xpcSystemReboot;
+		break;
+	case SYS_HALT:
+		reason = xpcSystemHalt;
+		break;
+	case SYS_POWER_OFF:
+		reason = xpcSystemPoweroff;
+		break;
+	default:
+		reason = xpcSystemGoingDown;
+	}
+
+	xpc_do_exit(reason);
+	return NOTIFY_DONE;
+}
+
+
 int __init
 xpc_init(void)
 {
@@ -920,6 +1020,12 @@
 		spin_lock_init(&part->act_lock);
 		part->act_state = XPC_P_INACTIVE;
 		XPC_SET_REASON(part, 0, 0);
+
+		init_timer(&part->disengage_request_timer);
+		part->disengage_request_timer.function +				xpc_timeout_partition_disengage_request;
+		part->disengage_request_timer.data = (unsigned long) part;
+
 		part->setup_state = XPC_P_UNSET;
 		init_waitqueue_head(&part->teardown_wq);
 		atomic_set(&part->references, 0);
@@ -976,6 +1082,13 @@
 	}
 
 
+	/* add ourselves to the reboot_notifier_list */
+	ret = register_reboot_notifier(&xpc_reboot_notifier);
+	if (ret != 0) {
+		dev_warn(xpc_part, "can't register reboot notifier\n");
+	}
+
+
 	/*
 	 * Set the beating to other partitions into motion.  This is
 	 * the last requirement for other partitions' discovery to
@@ -997,6 +1110,9 @@
 		/* indicate to others that our reserved page is uninitialized */
 		xpc_rsvd_page->vars_pa = 0;
 
+		/* take ourselves off of the reboot_notifier_list */
+		(void) unregister_reboot_notifier(&xpc_reboot_notifier);
+
 		del_timer_sync(&xpc_hb_timer);
 		free_irq(SGI_XPC_ACTIVATE, NULL);
 		xpc_restrict_IPI_ops();
@@ -1018,9 +1134,9 @@
 		dev_err(xpc_part, "failed while forking discovery thread\n");
 
 		/* mark this new thread as a non-starter */
-		up(&xpc_discovery_exited);
+		up(&xpc_discovery_inactive);
 
-		xpc_do_exit();
+		xpc_do_exit(xpcUnloading);
 		return -EBUSY;
 	}
 
@@ -1039,7 +1155,7 @@
 void __exit
 xpc_exit(void)
 {
-	xpc_do_exit();
+	xpc_do_exit(xpcUnloading);
 }
 module_exit(xpc_exit);
 
Index: release/arch/ia64/sn/kernel/xpc_channel.c
=================================--- release.orig/arch/ia64/sn/kernel/xpc_channel.c	2005-08-31 11:08:50.287989393 -0500
+++ release/arch/ia64/sn/kernel/xpc_channel.c	2005-08-31 11:47:37.236223969 -0500
@@ -57,6 +57,7 @@
 
 		spin_lock_init(&ch->lock);
 		sema_init(&ch->msg_to_pull_sema, 1);	/* mutex */
+		sema_init(&ch->wdisconnect_sema, 0);	/* event wait */
 
 		atomic_set(&ch->n_on_msg_allocate_wq, 0);
 		init_waitqueue_head(&ch->msg_allocate_wq);
@@ -166,6 +167,7 @@
 	xpc_initialize_channels(part, partid);
 
 	atomic_set(&part->nchannels_active, 0);
+	atomic_set(&part->nchannels_engaged, 0);
 
 
 	/* local_IPI_amo were set to 0 by an earlier memset() */
@@ -555,8 +557,6 @@
 		sema_init(&ch->notify_queue[i].sema, 0);
 	}
 
-	sema_init(&ch->teardown_sema, 0);	/* event wait */
-
 	spin_lock_irqsave(&ch->lock, irq_flags);
 	ch->flags |= XPC_C_SETUP;
 	spin_unlock_irqrestore(&ch->lock, irq_flags);
@@ -626,6 +626,55 @@
 
 
 /*
+ * Notify those who wanted to be notified upon delivery of their message.
+ */
+static void
+xpc_notify_senders(struct xpc_channel *ch, enum xpc_retval reason, s64 put)
+{
+	struct xpc_notify *notify;
+	u8 notify_type;
+	s64 get = ch->w_remote_GP.get - 1;
+
+
+	while (++get < put && atomic_read(&ch->n_to_notify) > 0) {
+
+		notify = &ch->notify_queue[get % ch->local_nentries];
+
+		/*
+		 * See if the notify entry indicates it was associated with
+		 * a message who's sender wants to be notified. It is possible
+		 * that it is, but someone else is doing or has done the
+		 * notification.
+		 */
+		notify_type = notify->type;
+		if (notify_type = 0 ||
+				cmpxchg(&notify->type, notify_type, 0) !+								notify_type) {
+			continue;
+		}
+
+		DBUG_ON(notify_type != XPC_N_CALL);
+
+		atomic_dec(&ch->n_to_notify);
+
+		if (notify->func != NULL) {
+			dev_dbg(xpc_chan, "notify->func() called, notify=0x%p, "
+				"msg_number=%ld, partid=%d, channel=%d\n",
+				(void *) notify, get, ch->partid, ch->number);
+
+			notify->func(reason, ch->partid, ch->number,
+								notify->key);
+
+			dev_dbg(xpc_chan, "notify->func() returned, "
+				"notify=0x%p, msg_number=%ld, partid=%d, "
+				"channel=%d\n", (void *) notify, get,
+				ch->partid, ch->number);
+		}
+	}
+}
+
+
+/*
  * Free up message queues and other stuff that were allocated for the specified
  * channel.
  *
@@ -669,9 +718,6 @@
 		ch->remote_msgqueue = NULL;
 		kfree(ch->notify_queue);
 		ch->notify_queue = NULL;
-
-		/* in case someone is waiting for the teardown to complete */
-		up(&ch->teardown_sema);
 	}
 }
 
@@ -683,7 +729,7 @@
 xpc_process_disconnect(struct xpc_channel *ch, unsigned long *irq_flags)
 {
 	struct xpc_partition *part = &xpc_partitions[ch->partid];
-	u32 ch_flags = ch->flags;
+	u32 channel_was_connected = (ch->flags & XPC_C_WASCONNECTED);
 
 
 	DBUG_ON(!spin_is_locked(&ch->lock));
@@ -701,12 +747,13 @@
 	}
 	DBUG_ON(atomic_read(&ch->kthreads_assigned) != 0);
 
-	/* it's now safe to free the channel's message queues */
-
-	xpc_free_msgqueues(ch);
-	DBUG_ON(ch->flags & XPC_C_SETUP);
+	if (part->act_state = XPC_P_DEACTIVATING) {
+		/* can't proceed until the other side disengages from us */
+		if (xpc_partition_engaged(1UL << ch->partid)) {
+			return;
+		}
 
-	if (part->act_state != XPC_P_DEACTIVATING) {
+	} else {
 
 		/* as long as the other side is up do the full protocol */
 
@@ -724,16 +771,33 @@
 		}
 	}
 
+	/* wake those waiting for notify completion */
+	if (atomic_read(&ch->n_to_notify) > 0) {
+		/* >>> we do callout while holding ch->lock */
+		xpc_notify_senders(ch, ch->reason, ch->w_local_GP.put);
+	}
+
 	/* both sides are disconnected now */
 
-	ch->flags = XPC_C_DISCONNECTED;	/* clear all flags, but this one */
+	/* it's now safe to free the channel's message queues */
+	xpc_free_msgqueues(ch);
+
+	/* mark disconnected, clear all other flags except XPC_C_WDISCONNECT */
+	ch->flags = (XPC_C_DISCONNECTED | (ch->flags & XPC_C_WDISCONNECT));
 
 	atomic_dec(&part->nchannels_active);
 
-	if (ch_flags & XPC_C_WASCONNECTED) {
+	if (channel_was_connected) {
 		dev_info(xpc_chan, "channel %d to partition %d disconnected, "
 			"reason=%d\n", ch->number, ch->partid, ch->reason);
 	}
+
+	/* wake the thread that is waiting for this channel to disconnect */
+	if (ch->flags & XPC_C_WDISCONNECT) {
+		spin_unlock_irqrestore(&ch->lock, *irq_flags);
+		up(&ch->wdisconnect_sema);
+		spin_lock_irqsave(&ch->lock, *irq_flags);
+	}
 }
 
 
@@ -764,7 +828,7 @@
 		/*
 		 * If RCLOSEREQUEST is set, we're probably waiting for
 		 * RCLOSEREPLY. We should find it and a ROPENREQUEST packed
-		 * with this RCLOSEQREUQEST in the IPI_flags.
+		 * with this RCLOSEREQUEST in the IPI_flags.
 		 */
 
 		if (ch->flags & XPC_C_RCLOSEREQUEST) {
@@ -852,7 +916,7 @@
 			"channel=%d\n", args->msg_size, args->local_nentries,
 			ch->partid, ch->number);
 
-		if ((ch->flags & XPC_C_DISCONNECTING) ||
+		if ((ch->flags & (XPC_C_DISCONNECTING | XPC_C_WDISCONNECT)) ||
 					part->act_state = XPC_P_DEACTIVATING) {
 			spin_unlock_irqrestore(&ch->lock, irq_flags);
 			return;
@@ -1040,55 +1104,6 @@
 
 
 /*
- * Notify those who wanted to be notified upon delivery of their message.
- */
-static void
-xpc_notify_senders(struct xpc_channel *ch, enum xpc_retval reason, s64 put)
-{
-	struct xpc_notify *notify;
-	u8 notify_type;
-	s64 get = ch->w_remote_GP.get - 1;
-
-
-	while (++get < put && atomic_read(&ch->n_to_notify) > 0) {
-
-		notify = &ch->notify_queue[get % ch->local_nentries];
-
-		/*
-		 * See if the notify entry indicates it was associated with
-		 * a message who's sender wants to be notified. It is possible
-		 * that it is, but someone else is doing or has done the
-		 * notification.
-		 */
-		notify_type = notify->type;
-		if (notify_type = 0 ||
-				cmpxchg(&notify->type, notify_type, 0) !-								notify_type) {
-			continue;
-		}
-
-		DBUG_ON(notify_type != XPC_N_CALL);
-
-		atomic_dec(&ch->n_to_notify);
-
-		if (notify->func != NULL) {
-			dev_dbg(xpc_chan, "notify->func() called, notify=0x%p, "
-				"msg_number=%ld, partid=%d, channel=%d\n",
-				(void *) notify, get, ch->partid, ch->number);
-
-			notify->func(reason, ch->partid, ch->number,
-								notify->key);
-
-			dev_dbg(xpc_chan, "notify->func() returned, "
-				"notify=0x%p, msg_number=%ld, partid=%d, "
-				"channel=%d\n", (void *) notify, get,
-				ch->partid, ch->number);
-		}
-	}
-}
-
-
-/*
  * Clear some of the msg flags in the local message queue.
  */
 static inline void
@@ -1240,6 +1255,7 @@
 	u64 IPI_amo, IPI_flags;
 	struct xpc_channel *ch;
 	int ch_number;
+	u32 ch_flags;
 
 
 	IPI_amo = xpc_get_IPI_flags(part);
@@ -1266,8 +1282,9 @@
 			xpc_process_openclose_IPI(part, ch_number, IPI_flags);
 		}
 
+		ch_flags = ch->flags;	/* need an atomic snapshot of flags */
 
-		if (ch->flags & XPC_C_DISCONNECTING) {
+		if (ch_flags & XPC_C_DISCONNECTING) {
 			spin_lock_irqsave(&ch->lock, irq_flags);
 			xpc_process_disconnect(ch, &irq_flags);
 			spin_unlock_irqrestore(&ch->lock, irq_flags);
@@ -1278,9 +1295,9 @@
 			continue;
 		}
 
-		if (!(ch->flags & XPC_C_CONNECTED)) {
-			if (!(ch->flags & XPC_C_OPENREQUEST)) {
-				DBUG_ON(ch->flags & XPC_C_SETUP);
+		if (!(ch_flags & XPC_C_CONNECTED)) {
+			if (!(ch_flags & XPC_C_OPENREQUEST)) {
+				DBUG_ON(ch_flags & XPC_C_SETUP);
 				(void) xpc_connect_channel(ch);
 			} else {
 				spin_lock_irqsave(&ch->lock, irq_flags);
@@ -1305,8 +1322,8 @@
 
 
 /*
- * XPC's heartbeat code calls this function to inform XPC that a partition has
- * gone down.  XPC responds by tearing down the XPartition Communication
+ * XPC's heartbeat code calls this function to inform XPC that a partition is
+ * going down.  XPC responds by tearing down the XPartition Communication
  * infrastructure used for the just downed partition.
  *
  * XPC's heartbeat code will never call this function and xpc_partition_up()
@@ -1314,7 +1331,7 @@
  * at the same time.
  */
 void
-xpc_partition_down(struct xpc_partition *part, enum xpc_retval reason)
+xpc_partition_going_down(struct xpc_partition *part, enum xpc_retval reason)
 {
 	unsigned long irq_flags;
 	int ch_number;
@@ -1330,12 +1347,11 @@
 	}
 
 
-	/* disconnect all channels associated with the downed partition */
+	/* disconnect channels associated with the partition going down */
 
 	for (ch_number = 0; ch_number < part->nchannels; ch_number++) {
 		ch = &part->channels[ch_number];
 
-
 		xpc_msgqueue_ref(ch);
 		spin_lock_irqsave(&ch->lock, irq_flags);
 
@@ -1370,6 +1386,7 @@
 	 * this partition.
 	 */
 
+	DBUG_ON(atomic_read(&part->nchannels_engaged) != 0);
 	DBUG_ON(atomic_read(&part->nchannels_active) != 0);
 	DBUG_ON(part->setup_state != XPC_P_SETUP);
 	part->setup_state = XPC_P_WTEARDOWN;
@@ -1506,8 +1523,12 @@
 
 			spin_lock_irqsave(&ch->lock, irq_flags);
 
-			XPC_DISCONNECT_CHANNEL(ch, xpcUnregistering,
+			if (!(ch->flags & XPC_C_DISCONNECTED)) {
+				ch->flags |= XPC_C_WDISCONNECT;
+
+				XPC_DISCONNECT_CHANNEL(ch, xpcUnregistering,
 								&irq_flags);
+			}
 
 			spin_unlock_irqrestore(&ch->lock, irq_flags);
 
@@ -1523,8 +1544,9 @@
 /*
  * To disconnect a channel, and reflect it back to all who may be waiting.
  *
- * >>> An OPEN is not allowed until XPC_C_DISCONNECTING is cleared by
- * >>> xpc_free_msgqueues().
+ * An OPEN is not allowed until XPC_C_DISCONNECTING is cleared by
+ * xpc_process_disconnect(), and if set, XPC_C_WDISCONNECT is cleared by
+ * xpc_disconnect_wait().
  *
  * THE CHANNEL IS TO BE LOCKED BY THE CALLER AND WILL REMAIN LOCKED UPON RETURN.
  */
@@ -1532,7 +1554,7 @@
 xpc_disconnect_channel(const int line, struct xpc_channel *ch,
 			enum xpc_retval reason, unsigned long *irq_flags)
 {
-	u32 flags;
+	u32 channel_was_connected = (ch->flags & XPC_C_CONNECTED);
 
 
 	DBUG_ON(!spin_is_locked(&ch->lock));
@@ -1547,61 +1569,53 @@
 
 	XPC_SET_REASON(ch, reason, line);
 
-	flags = ch->flags;
+	ch->flags |= (XPC_C_CLOSEREQUEST | XPC_C_DISCONNECTING);
 	/* some of these may not have been set */
 	ch->flags &= ~(XPC_C_OPENREQUEST | XPC_C_OPENREPLY |
 			XPC_C_ROPENREQUEST | XPC_C_ROPENREPLY |
 			XPC_C_CONNECTING | XPC_C_CONNECTED);
 
-	ch->flags |= (XPC_C_CLOSEREQUEST | XPC_C_DISCONNECTING);
 	xpc_IPI_send_closerequest(ch, irq_flags);
 
-	if (flags & XPC_C_CONNECTED) {
+	if (channel_was_connected) {
 		ch->flags |= XPC_C_WASCONNECTED;
 	}
 
+	spin_unlock_irqrestore(&ch->lock, *irq_flags);
+
+	/* wake all idle kthreads so they can exit */
 	if (atomic_read(&ch->kthreads_idle) > 0) {
-		/* wake all idle kthreads so they can exit */
 		wake_up_all(&ch->idle_wq);
 	}
 
-	spin_unlock_irqrestore(&ch->lock, *irq_flags);
-
-
 	/* wake those waiting to allocate an entry from the local msg queue */
-
 	if (atomic_read(&ch->n_on_msg_allocate_wq) > 0) {
 		wake_up(&ch->msg_allocate_wq);
 	}
 
-	/* wake those waiting for notify completion */
-
-	if (atomic_read(&ch->n_to_notify) > 0) {
-		xpc_notify_senders(ch, reason, ch->w_local_GP.put);
-	}
-
 	spin_lock_irqsave(&ch->lock, *irq_flags);
 }
 
 
 void
-xpc_disconnected_callout(struct xpc_channel *ch)
+xpc_disconnecting_callout(struct xpc_channel *ch)
 {
 	/*
-	 * Let the channel's registerer know that the channel is now
+	 * Let the channel's registerer know that the channel is being
 	 * disconnected. We don't want to do this if the registerer was never
-	 * informed of a connection being made, unless the disconnect was for
-	 * abnormal reasons.
+	 * informed of a connection being made.
 	 */
 
 	if (ch->func != NULL) {
-		dev_dbg(xpc_chan, "ch->func() called, reason=%d, partid=%d, "
-			"channel=%d\n", ch->reason, ch->partid, ch->number);
+		dev_dbg(xpc_chan, "ch->func() called, reason=xpcDisconnecting,"
+			" partid=%d, channel=%d\n", ch->partid, ch->number);
 
-		ch->func(ch->reason, ch->partid, ch->number, NULL, ch->key);
+		ch->func(xpcDisconnecting, ch->partid, ch->number, NULL,
+								ch->key);
 
-		dev_dbg(xpc_chan, "ch->func() returned, reason=%d, partid=%d, "
-			"channel=%d\n", ch->reason, ch->partid, ch->number);
+		dev_dbg(xpc_chan, "ch->func() returned, reason="
+			"xpcDisconnecting, partid=%d, channel=%d\n",
+			ch->partid, ch->number);
 	}
 }
 
@@ -1848,7 +1862,7 @@
 			xpc_notify_func func, void *key)
 {
 	enum xpc_retval ret = xpcSuccess;
-	struct xpc_notify *notify = NULL;   // >>> to keep the compiler happy!!
+	struct xpc_notify *notify = notify;
 	s64 put, msg_number = msg->number;
 
 
Index: release/arch/ia64/sn/kernel/xpc_partition.c
=================================--- release.orig/arch/ia64/sn/kernel/xpc_partition.c	2005-08-30 13:29:30.650065459 -0500
+++ release/arch/ia64/sn/kernel/xpc_partition.c	2005-08-31 12:55:50.880727126 -0500
@@ -76,11 +76,6 @@
 		xpc_remote_copy_buffer[XPC_RSVD_PAGE_ALIGNED_SIZE];
 
 
-/* systune related variables */
-int xpc_hb_interval = XPC_HB_DEFAULT_INTERVAL;
-int xpc_hb_check_interval = XPC_HB_CHECK_DEFAULT_TIMEOUT;
-
-
 /*
  * Given a nasid, get the physical address of the  partition's reserved page
  * for that nasid. This function returns 0 on any error.
@@ -239,16 +234,21 @@
 	xpc_vars->amos_page = amos_page;  /* save for next load of XPC */
 
 
-	/*
-	 * Initialize the activation related AMO variables.
-	 */
-	xpc_vars->act_amos = xpc_IPI_init(XP_MAX_PARTITIONS);
-	for (i = 1; i < XP_NASID_MASK_WORDS; i++) {
-		xpc_IPI_init(i + XP_MAX_PARTITIONS);
+	/* initialize the activate IRQ related AMO variables */
+	for (i = 0; i < XP_NASID_MASK_WORDS; i++) {
+		(void) xpc_IPI_init(XPC_ACTIVATE_IRQ_AMOS + i);
 	}
+
+	/* initialize the engaged remote partitions related AMO variables */
+	(void) xpc_IPI_init(XPC_ENGAGED_PARTITIONS_AMO);
+	(void) xpc_IPI_init(XPC_DISENGAGE_REQUEST_AMO);
+
 	/* export AMO page's physical address to other partitions */
 	xpc_vars->amos_page_pa = ia64_tpa((u64) xpc_vars->amos_page);
 
+	/* timestamp of when reserved page was initialized */
+	rp->stamp = CURRENT_TIME;
+
 	/*
 	 * This signifies to the remote partition that our reserved
 	 * page is initialized.
@@ -387,6 +387,11 @@
 	remote_vars = (struct xpc_vars *) xpc_remote_copy_buffer;
 
 	for (partid = 1; partid < XP_MAX_PARTITIONS; partid++) {
+
+		if (xpc_exiting) {
+			break;
+		}
+
 		if (partid = sn_partition_id) {
 			continue;
 		}
@@ -417,7 +422,7 @@
 
 		if (((remote_vars->heartbeat = part->last_heartbeat) &&
 			(remote_vars->kdb_status = 0)) ||
-			     !XPC_HB_ALLOWED(sn_partition_id, remote_vars)) {
+			     !xpc_hb_allowed(sn_partition_id, remote_vars)) {
 
 			XPC_DEACTIVATE_PARTITION(part, xpcNoHeartbeat);
 			continue;
@@ -436,23 +441,23 @@
  */
 static enum xpc_retval
 xpc_get_remote_rp(int nasid, u64 *discovered_nasids,
-		struct xpc_rsvd_page *remote_rp, u64 *remote_rsvd_page_pa)
+		struct xpc_rsvd_page *remote_rp, u64 *remote_rp_pa)
 {
 	int bres, i;
 
 
 	/* get the reserved page's physical address */
 
-	*remote_rsvd_page_pa = xpc_get_rsvd_page_pa(nasid, (u64) remote_rp,
+	*remote_rp_pa = xpc_get_rsvd_page_pa(nasid, (u64) remote_rp,
 						XPC_RSVD_PAGE_ALIGNED_SIZE);
-	if (*remote_rsvd_page_pa = 0) {
+	if (*remote_rp_pa = 0) {
 		return xpcNoRsvdPageAddr;
 	}
 
 
 	/* pull over the reserved page structure */
 
-	bres = xp_bte_copy(*remote_rsvd_page_pa, ia64_tpa((u64) remote_rp),
+	bres = xp_bte_copy(*remote_rp_pa, ia64_tpa((u64) remote_rp),
 				XPC_RSVD_PAGE_ALIGNED_SIZE,
 				(BTE_NOTIFY | BTE_WACQUIRE), NULL);
 	if (bres != BTE_SUCCESS) {
@@ -524,6 +529,55 @@
 
 
 /*
+ * Update the remote partition's info.
+ */
+static void
+xpc_update_partition_info(struct xpc_partition *part, u8 remote_rp_version,
+		struct timespec *remote_rp_stamp, u64 remote_rp_pa,
+		u64 remote_vars_pa, struct xpc_vars *remote_vars)
+{
+	part->remote_rp_version = remote_rp_version;
+	dev_dbg(xpc_part, "  remote_rp_version = 0x%016lx\n",
+		part->remote_rp_version);
+
+	part->remote_rp_stamp = *remote_rp_stamp;
+	dev_dbg(xpc_part, "  remote_rp_stamp (tv_sec = 0x%lx tv_nsec = 0x%lx\n",
+		part->remote_rp_stamp.tv_sec, part->remote_rp_stamp.tv_nsec);
+
+	part->remote_rp_pa = remote_rp_pa;
+	dev_dbg(xpc_part, "  remote_rp_pa = 0x%016lx\n", part->remote_rp_pa);
+
+	part->remote_vars_pa = remote_vars_pa;
+	dev_dbg(xpc_part, "  remote_vars_pa = 0x%016lx\n",
+		part->remote_vars_pa);
+
+	part->last_heartbeat = remote_vars->heartbeat;
+	dev_dbg(xpc_part, "  last_heartbeat = 0x%016lx\n",
+		part->last_heartbeat);
+
+	part->remote_vars_part_pa = remote_vars->vars_part_pa;
+	dev_dbg(xpc_part, "  remote_vars_part_pa = 0x%016lx\n",
+		part->remote_vars_part_pa);
+
+	part->remote_act_nasid = remote_vars->act_nasid;
+	dev_dbg(xpc_part, "  remote_act_nasid = 0x%x\n",
+		part->remote_act_nasid);
+
+	part->remote_act_phys_cpuid = remote_vars->act_phys_cpuid;
+	dev_dbg(xpc_part, "  remote_act_phys_cpuid = 0x%x\n",
+		part->remote_act_phys_cpuid);
+
+	part->remote_amos_page_pa = remote_vars->amos_page_pa;
+	dev_dbg(xpc_part, "  remote_amos_page_pa = 0x%lx\n",
+		part->remote_amos_page_pa);
+
+	part->remote_vars_version = remote_vars->version;
+	dev_dbg(xpc_part, "  remote_vars_version = 0x%x\n",
+		part->remote_vars_version);
+}
+
+
+/*
  * Prior code has determine the nasid which generated an IPI.  Inspect
  * that nasid to determine if its partition needs to be activated or
  * deactivated.
@@ -542,8 +596,12 @@
 {
 	struct xpc_rsvd_page *remote_rp;
 	struct xpc_vars *remote_vars;
-	u64 remote_rsvd_page_pa;
+	u64 remote_rp_pa;
 	u64 remote_vars_pa;
+	int remote_rp_version;
+	int reactivate = 0;
+	int stamp_diff;
+	struct timespec remote_rp_stamp = { 0, 0 };
 	partid_t partid;
 	struct xpc_partition *part;
 	enum xpc_retval ret;
@@ -553,7 +611,7 @@
 
 	remote_rp = (struct xpc_rsvd_page *) xpc_remote_copy_buffer;
 
-	ret = xpc_get_remote_rp(nasid, NULL, remote_rp, &remote_rsvd_page_pa);
+	ret = xpc_get_remote_rp(nasid, NULL, remote_rp, &remote_rp_pa);
 	if (ret != xpcSuccess) {
 		dev_warn(xpc_part, "unable to get reserved page from nasid %d, "
 			"which sent interrupt, reason=%d\n", nasid, ret);
@@ -561,6 +619,10 @@
 	}
 
 	remote_vars_pa = remote_rp->vars_pa;
+	remote_rp_version = remote_rp->version;
+	if (XPC_SUPPORTS_RP_STAMP(remote_rp_version)) {
+		remote_rp_stamp = remote_rp->stamp;
+	}
 	partid = remote_rp->partid;
 	part = &xpc_partitions[partid];
 
@@ -586,44 +648,117 @@
 		"%ld:0x%lx\n", (int) nasid, (int) partid, part->act_IRQ_rcvd,
 		remote_vars->heartbeat, remote_vars->heartbeating_to_mask);
 
+	if (xpc_partition_disengaged(part) &&
+					part->act_state = XPC_P_INACTIVE) {
 
-	if (part->act_state = XPC_P_INACTIVE) {
+		xpc_update_partition_info(part, remote_rp_version,
+					&remote_rp_stamp, remote_rp_pa,
+					remote_vars_pa, remote_vars);
+
+		if (XPC_SUPPORTS_DISENGAGE_REQUEST(part->remote_vars_version)) {
+			if (xpc_partition_disengage_requested(1UL << partid)) {
+				/*
+				 * Other side is waiting on us to disengage,
+				 * even though we already have.
+				 */
+				return;
+			}
+		} else {
+			/* other side doesn't support disengage requests */
+			xpc_clear_partition_disengage_request(1UL << partid);
+		}
 
-		part->remote_rp_pa = remote_rsvd_page_pa;
-		dev_dbg(xpc_part, "  remote_rp_pa = 0x%016lx\n",
-			part->remote_rp_pa);
-
-		part->remote_vars_pa = remote_vars_pa;
-		dev_dbg(xpc_part, "  remote_vars_pa = 0x%016lx\n",
-			part->remote_vars_pa);
+		xpc_activate_partition(part);
+		return;
+	}
 
-		part->last_heartbeat = remote_vars->heartbeat;
-		dev_dbg(xpc_part, "  last_heartbeat = 0x%016lx\n",
-			part->last_heartbeat);
+	DBUG_ON(part->remote_rp_version = 0);
+	DBUG_ON(part->remote_vars_version = 0);
 
-		part->remote_vars_part_pa = remote_vars->vars_part_pa;
-		dev_dbg(xpc_part, "  remote_vars_part_pa = 0x%016lx\n",
-			part->remote_vars_part_pa);
-
-		part->remote_act_nasid = remote_vars->act_nasid;
-		dev_dbg(xpc_part, "  remote_act_nasid = 0x%x\n",
-			part->remote_act_nasid);
-
-		part->remote_act_phys_cpuid = remote_vars->act_phys_cpuid;
-		dev_dbg(xpc_part, "  remote_act_phys_cpuid = 0x%x\n",
-			part->remote_act_phys_cpuid);
-
-		part->remote_amos_page_pa = remote_vars->amos_page_pa;
-		dev_dbg(xpc_part, "  remote_amos_page_pa = 0x%lx\n",
-			part->remote_amos_page_pa);
+	if (!XPC_SUPPORTS_RP_STAMP(part->remote_rp_version)) {
+		DBUG_ON(XPC_SUPPORTS_DISENGAGE_REQUEST(part->
+							remote_vars_version));
+
+		if (!XPC_SUPPORTS_RP_STAMP(remote_rp_version)) {
+			DBUG_ON(XPC_SUPPORTS_DISENGAGE_REQUEST(remote_vars->
+								version));
+			/* see if the other side rebooted */
+			if (part->remote_amos_page_pa =
+				remote_vars->amos_page_pa &&
+					xpc_hb_allowed(sn_partition_id,
+								remote_vars)) {
+				/* doesn't look that way, so ignore the IPI */
+				return;
+			}
+		}
 
-		xpc_activate_partition(part);
+		/*
+		 * Other side rebooted and previous XPC didn't support the
+		 * disengage request, so we don't need to do anything special.
+		 */
+
+		xpc_update_partition_info(part, remote_rp_version,
+						&remote_rp_stamp, remote_rp_pa,
+						remote_vars_pa, remote_vars);
+		part->reactivate_nasid = nasid;
+		XPC_DEACTIVATE_PARTITION(part, xpcReactivating);
+		return;
+	}
+
+	DBUG_ON(!XPC_SUPPORTS_DISENGAGE_REQUEST(part->remote_vars_version));
+
+	if (!XPC_SUPPORTS_RP_STAMP(remote_rp_version)) {
+		DBUG_ON(!XPC_SUPPORTS_DISENGAGE_REQUEST(remote_vars->version));
+
+		/*
+		 * Other side rebooted and previous XPC did support the
+		 * disengage request, but the new one doesn't.
+		 */
+
+		xpc_clear_partition_engaged(1UL << partid);
+		xpc_clear_partition_disengage_request(1UL << partid);
+
+		xpc_update_partition_info(part, remote_rp_version,
+						&remote_rp_stamp, remote_rp_pa,
+						remote_vars_pa, remote_vars);
+		reactivate = 1;
 
-	} else if (part->remote_amos_page_pa != remote_vars->amos_page_pa ||
-			!XPC_HB_ALLOWED(sn_partition_id, remote_vars)) {
+	} else {
+		DBUG_ON(!XPC_SUPPORTS_DISENGAGE_REQUEST(remote_vars->version));
+
+		stamp_diff = xpc_compare_stamps(&part->remote_rp_stamp,
+							&remote_rp_stamp);
+		if (stamp_diff != 0) {
+			DBUG_ON(stamp_diff >= 0);
+
+			/*
+			 * Other side rebooted and the previous XPC did support
+			 * the disengage request, as does the new one.
+			 */
+
+			DBUG_ON(xpc_partition_engaged(1UL << partid));
+			DBUG_ON(xpc_partition_disengage_requested(1UL <<
+								partid));
+
+			xpc_update_partition_info(part, remote_rp_version,
+						&remote_rp_stamp, remote_rp_pa,
+						remote_vars_pa, remote_vars);
+			reactivate = 1;
+		}
+	}
+
+	if (!xpc_partition_disengaged(part)) {
+		/* still waiting on other side to disengage from us */
+		return;
+	}
 
+	if (reactivate) {
 		part->reactivate_nasid = nasid;
 		XPC_DEACTIVATE_PARTITION(part, xpcReactivating);
+
+	} else if (XPC_SUPPORTS_DISENGAGE_REQUEST(part->remote_vars_version) &&
+			xpc_partition_disengage_requested(1UL << partid)) {
+		XPC_DEACTIVATE_PARTITION(part, xpcOtherGoingDown);
 	}
 }
 
@@ -646,12 +781,16 @@
 	struct xpc_rsvd_page *rp = (struct xpc_rsvd_page *) xpc_rsvd_page;
 
 
-	act_amos = xpc_vars->act_amos;
+	act_amos = xpc_vars->amos_page + XPC_ACTIVATE_IRQ_AMOS;
 
 
 	/* scan through act AMO variable looking for non-zero entries */
 	for (word = 0; word < XP_NASID_MASK_WORDS; word++) {
 
+		if (xpc_exiting) {
+			break;
+		}
+
 		nasid_mask = xpc_IPI_receive(&act_amos[word]);
 		if (nasid_mask = 0) {
 			/* no IRQs from nasids in this variable */
@@ -688,6 +827,55 @@
 
 
 /*
+ * See if the other side has responded to a partition disengage request
+ * from us.
+ */
+int
+xpc_partition_disengaged(struct xpc_partition *part)
+{
+	partid_t partid = XPC_PARTID(part);
+	int disengaged;
+
+
+	disengaged = (xpc_partition_engaged(1UL << partid) = 0);
+	if (part->disengage_request_timeout) {
+		if (!disengaged) {
+			if (jiffies < part->disengage_request_timeout) {
+				/* timelimit hasn't been reached yet */
+				return 0;
+			}
+
+			/*
+			 * Other side hasn't responded to our disengage
+			 * request in a timely fashion, so assume it's dead.
+			 */
+
+			xpc_clear_partition_engaged(1UL << partid);
+			disengaged = 1;
+		}
+		part->disengage_request_timeout = 0;
+
+		/* cancel the timer function, provided it's not us */
+		if (!in_interrupt()) {
+			del_singleshot_timer_sync(&part->
+						      disengage_request_timer);
+		}
+
+		DBUG_ON(part->act_state != XPC_P_DEACTIVATING &&
+					part->act_state != XPC_P_INACTIVE);
+		if (part->act_state != XPC_P_INACTIVE) {
+			xpc_wakeup_channel_mgr(part);
+		}
+
+		if (XPC_SUPPORTS_DISENGAGE_REQUEST(part->remote_vars_version)) {
+			xpc_cancel_partition_disengage_request(part);
+		}
+	}
+	return disengaged;
+}
+
+
+/*
  * Mark specified partition as active.
  */
 enum xpc_retval
@@ -721,7 +909,6 @@
 				enum xpc_retval reason)
 {
 	unsigned long irq_flags;
-	partid_t partid = XPC_PARTID(part);
 
 
 	spin_lock_irqsave(&part->act_lock, irq_flags);
@@ -749,17 +936,27 @@
 
 	spin_unlock_irqrestore(&part->act_lock, irq_flags);
 
-	XPC_DISALLOW_HB(partid, xpc_vars);
+	if (XPC_SUPPORTS_DISENGAGE_REQUEST(part->remote_vars_version)) {
+		xpc_request_partition_disengage(part);
+		xpc_IPI_send_disengage(part);
+
+		/* set a timelimit on the disengage request */
+		part->disengage_request_timeout = jiffies +
+					(XPC_DISENGAGE_REQUEST_TIMELIMIT * HZ);
+		part->disengage_request_timer.expires +					part->disengage_request_timeout;
+		add_timer(&part->disengage_request_timer);
+	}
 
 	dev_dbg(xpc_part, "bringing partition %d down, reason = %d\n", partid,
 		reason);
 
-	xpc_partition_down(part, reason);
+	xpc_partition_going_down(part, reason);
 }
 
 
 /*
- * Mark specified partition as active.
+ * Mark specified partition as inactive.
  */
 void
 xpc_mark_partition_inactive(struct xpc_partition *part)
@@ -792,7 +989,7 @@
 	void *remote_rp_base;
 	struct xpc_rsvd_page *remote_rp;
 	struct xpc_vars *remote_vars;
-	u64 remote_rsvd_page_pa;
+	u64 remote_rp_pa;
 	u64 remote_vars_pa;
 	int region;
 	int max_regions;
@@ -877,7 +1074,7 @@
 			/* pull over the reserved page structure */
 
 			ret = xpc_get_remote_rp(nasid, discovered_nasids,
-					      remote_rp, &remote_rsvd_page_pa);
+					      remote_rp, &remote_rp_pa);
 			if (ret != xpcSuccess) {
 				dev_dbg(xpc_part, "unable to get reserved page "
 					"from nasid %d, reason=%d\n", nasid,
@@ -948,6 +1145,13 @@
 				remote_vars->act_nasid,
 				remote_vars->act_phys_cpuid);
 
+			if (XPC_SUPPORTS_DISENGAGE_REQUEST(remote_vars->
+								version)) {
+				part->remote_amos_page_pa +						remote_vars->amos_page_pa;
+				xpc_mark_partition_disengaged(part);
+				xpc_cancel_partition_disengage_request(part);
+			}
 			xpc_IPI_send_activate(remote_vars);
 		}
 	}
