From: Dean Nelson <dcn@sgi.com>
Date: Tue, 22 Apr 2008 19:48:01 +0000
Subject: [Patch 2/4] run drivers/misc/sgi-xp through scripts/Lindent part1 -v4
Message-Id: <20080422194801.GB14628@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080422194459.GB13086@sgi.com>
In-Reply-To: <20080422194459.GB13086@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com
Cc: jes@sgi.com, gregkh@suse.de, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Ran patches through scripts/Lindent (part 1).

Signed-off-by: Dean Nelson <dcn@sgi.com>

---

 drivers/misc/sgi-xp/xp.h            |   80 ++---
 drivers/misc/sgi-xp/xp_main.c       |   98 +++---
 drivers/misc/sgi-xp/xp_nofault.S    |    1 
 drivers/misc/sgi-xp/xpc.h           |  450 +++++++++++++-------------------
 drivers/misc/sgi-xp/xpc_partition.c |  328 +++++++++--------------
 5 files changed, 400 insertions(+), 557 deletions(-)

Index: linux-2.6/drivers/misc/sgi-xp/xp.h
=================================--- linux-2.6.orig/drivers/misc/sgi-xp/xp.h	2008-04-22 11:21:43.000000000 -0500
+++ linux-2.6/drivers/misc/sgi-xp/xp.h	2008-04-22 11:32:20.764397499 -0500
@@ -6,30 +6,25 @@
  * Copyright (C) 2004-2008 Silicon Graphics, Inc. All rights reserved.
  */
 
-
 /*
  * External Cross Partition (XP) structures and defines.
  */
 
-
 #ifndef _DRIVERS_MISC_SGIXP_XP_H
 #define _DRIVERS_MISC_SGIXP_XP_H
 
-
 #include <linux/cache.h>
 #include <linux/hardirq.h>
 #include <linux/mutex.h>
 #include <asm/sn/types.h>
 #include <asm/sn/bte.h>
 
-
 #ifdef USE_DBUG_ON
 #define DBUG_ON(condition)	BUG_ON(condition)
 #else
 #define DBUG_ON(condition)
 #endif
 
-
 /*
  * Define the maximum number of logically defined partitions the system
  * can support. It is constrained by the maximum number of hardware
@@ -43,7 +38,6 @@
  */
 #define XP_MAX_PARTITIONS	64
 
-
 /*
  * Define the number of u64s required to represent all the C-brick nasids
  * as a bitmap.  The cross-partition kernel modules deal only with
@@ -54,7 +48,6 @@
 #define XP_NASID_MASK_BYTES	((XP_MAX_PHYSNODE_ID + 7) / 8)
 #define XP_NASID_MASK_WORDS	((XP_MAX_PHYSNODE_ID + 63) / 64)
 
-
 /*
  * Wrapper for bte_copy() that should it return a failure status will retry
  * the bte_copy() once in the hope that the failure was due to a temporary
@@ -74,7 +67,6 @@ xp_bte_copy(u64 src, u64 vdst, u64 len, 
 	bte_result_t ret;
 	u64 pdst = ia64_tpa(vdst);
 
-
 	/*
 	 * Ensure that the physically mapped memory is contiguous.
 	 *
@@ -96,7 +88,6 @@ xp_bte_copy(u64 src, u64 vdst, u64 len, 
 	return ret;
 }
 
-
 /*
  * XPC establishes channel connections between the local partition and any
  * other partition that is currently up. Over these channels, kernel-level
@@ -122,7 +113,6 @@ xp_bte_copy(u64 src, u64 vdst, u64 len, 
 #error	XPC_NCHANNELS exceeds MAXIMUM allowed.
 #endif
 
-
 /*
  * The format of an XPC message is as follows:
  *
@@ -160,12 +150,10 @@ struct xpc_msg {
 	u64 payload;		/* user defined portion of message */
 };
 
-
 #define XPC_MSG_PAYLOAD_OFFSET	(u64) (&((struct xpc_msg *)0)->payload)
 #define XPC_MSG_SIZE(_payload_size) \
 		L1_CACHE_ALIGN(XPC_MSG_PAYLOAD_OFFSET + (_payload_size))
 
-
 /*
  * Define the return values and values passed to user's callout functions.
  * (It is important to add new value codes at the end just preceding
@@ -270,7 +258,6 @@ enum xpc_retval {
 	xpcUnknownReason	/* 116: unknown reason -- must be last in list */
 };
 
-
 /*
  * Define the callout function types used by XPC to update the user on
  * connection activity and state changes (via the user function registered by
@@ -375,12 +362,11 @@ enum xpc_retval {
  * ===========+================+==========  */
 
-typedef void (*xpc_channel_func)(enum xpc_retval reason, partid_t partid,
-		int ch_number, void *data, void *key);
-
-typedef void (*xpc_notify_func)(enum xpc_retval reason, partid_t partid,
-		int ch_number, void *key);
+typedef void (*xpc_channel_func) (enum xpc_retval reason, partid_t partid,
+				  int ch_number, void *data, void *key);
 
+typedef void (*xpc_notify_func) (enum xpc_retval reason, partid_t partid,
+				 int ch_number, void *key);
 
 /*
  * The following is a registration entry. There is a global array of these,
@@ -398,50 +384,45 @@ typedef void (*xpc_notify_func)(enum xpc
  */
 struct xpc_registration {
 	struct mutex mutex;
-	xpc_channel_func func;		/* function to call */
-	void *key;			/* pointer to user's key */
-	u16 nentries;			/* #of msg entries in local msg queue */
-	u16 msg_size;			/* message queue's message size */
-	u32 assigned_limit;		/* limit on #of assigned kthreads */
-	u32 idle_limit;			/* limit on #of idle kthreads */
+	xpc_channel_func func;	/* function to call */
+	void *key;		/* pointer to user's key */
+	u16 nentries;		/* #of msg entries in local msg queue */
+	u16 msg_size;		/* message queue's message size */
+	u32 assigned_limit;	/* limit on #of assigned kthreads */
+	u32 idle_limit;		/* limit on #of idle kthreads */
 } ____cacheline_aligned;
 
-
 #define XPC_CHANNEL_REGISTERED(_c)	(xpc_registrations[_c].func != NULL)
 
-
 /* the following are valid xpc_allocate() flags */
-#define XPC_WAIT	0		/* wait flag */
-#define XPC_NOWAIT	1		/* no wait flag */
-
+#define XPC_WAIT	0	/* wait flag */
+#define XPC_NOWAIT	1	/* no wait flag */
 
 struct xpc_interface {
-	void (*connect)(int);
-	void (*disconnect)(int);
-	enum xpc_retval (*allocate)(partid_t, int, u32, void **);
-	enum xpc_retval (*send)(partid_t, int, void *);
-	enum xpc_retval (*send_notify)(partid_t, int, void *,
-						xpc_notify_func, void *);
-	void (*received)(partid_t, int, void *);
-	enum xpc_retval (*partid_to_nasids)(partid_t, void *);
+	void (*connect) (int);
+	void (*disconnect) (int);
+	enum xpc_retval (*allocate) (partid_t, int, u32, void **);
+	enum xpc_retval (*send) (partid_t, int, void *);
+	enum xpc_retval (*send_notify) (partid_t, int, void *,
+					xpc_notify_func, void *);
+	void (*received) (partid_t, int, void *);
+	enum xpc_retval (*partid_to_nasids) (partid_t, void *);
 };
 
-
 extern struct xpc_interface xpc_interface;
 
 extern void xpc_set_interface(void (*)(int),
-		void (*)(int),
-		enum xpc_retval (*)(partid_t, int, u32, void **),
-		enum xpc_retval (*)(partid_t, int, void *),
-		enum xpc_retval (*)(partid_t, int, void *, xpc_notify_func,
-								void *),
-		void (*)(partid_t, int, void *),
-		enum xpc_retval (*)(partid_t, void *));
+			      void (*)(int),
+			      enum xpc_retval (*)(partid_t, int, u32, void **),
+			      enum xpc_retval (*)(partid_t, int, void *),
+			      enum xpc_retval (*)(partid_t, int, void *,
+						  xpc_notify_func, void *),
+			      void (*)(partid_t, int, void *),
+			      enum xpc_retval (*)(partid_t, void *));
 extern void xpc_clear_interface(void);
 
-
 extern enum xpc_retval xpc_connect(int, xpc_channel_func, void *, u16,
-						u16, u32, u32);
+				   u16, u32, u32);
 extern void xpc_disconnect(int);
 
 static inline enum xpc_retval
@@ -458,7 +439,7 @@ xpc_send(partid_t partid, int ch_number,
 
 static inline enum xpc_retval
 xpc_send_notify(partid_t partid, int ch_number, void *payload,
-			xpc_notify_func func, void *key)
+		xpc_notify_func func, void *key)
 {
 	return xpc_interface.send_notify(partid, ch_number, payload, func, key);
 }
@@ -475,11 +456,8 @@ xpc_partid_to_nasids(partid_t partid, vo
 	return xpc_interface.partid_to_nasids(partid, nasids);
 }
 
-
 extern u64 xp_nofault_PIOR_target;
 extern int xp_nofault_PIOR(void *);
 extern int xp_error_PIOR(void);
 
-
 #endif /* _DRIVERS_MISC_SGIXP_XP_H */
-
Index: linux-2.6/drivers/misc/sgi-xp/xp_main.c
=================================--- linux-2.6.orig/drivers/misc/sgi-xp/xp_main.c	2008-04-22 11:21:02.000000000 -0500
+++ linux-2.6/drivers/misc/sgi-xp/xp_main.c	2008-04-22 11:32:20.776398975 -0500
@@ -6,7 +6,6 @@
  * Copyright (c) 2004-2008 Silicon Graphics, Inc.  All Rights Reserved.
  */
 
-
 /*
  * Cross Partition (XP) base.
  *
@@ -15,7 +14,6 @@
  *
  */
 
-
 #include <linux/kernel.h>
 #include <linux/interrupt.h>
 #include <linux/module.h>
@@ -24,49 +22,49 @@
 #include <asm/sn/sn_sal.h>
 #include "xp.h"
 
-
 /*
  * Target of nofault PIO read.
  */
 u64 xp_nofault_PIOR_target;
 
-
 /*
  * xpc_registrations[] keeps track of xpc_connect()'s done by the kernel-level
  * users of XPC.
  */
 struct xpc_registration xpc_registrations[XPC_NCHANNELS];
 
-
 /*
  * Initialize the XPC interface to indicate that XPC isn't loaded.
  */
-static enum xpc_retval xpc_notloaded(void) { return xpcNotLoaded; }
+static enum xpc_retval
+xpc_notloaded(void)
+{
+	return xpcNotLoaded;
+}
 
 struct xpc_interface xpc_interface = {
-	(void (*)(int)) xpc_notloaded,
-	(void (*)(int)) xpc_notloaded,
-	(enum xpc_retval (*)(partid_t, int, u32, void **)) xpc_notloaded,
-	(enum xpc_retval (*)(partid_t, int, void *)) xpc_notloaded,
-	(enum xpc_retval (*)(partid_t, int, void *, xpc_notify_func, void *))
-							xpc_notloaded,
-	(void (*)(partid_t, int, void *)) xpc_notloaded,
-	(enum xpc_retval (*)(partid_t, void *)) xpc_notloaded
+	(void (*)(int))xpc_notloaded,
+	(void (*)(int))xpc_notloaded,
+	(enum xpc_retval(*)(partid_t, int, u32, void **))xpc_notloaded,
+	(enum xpc_retval(*)(partid_t, int, void *))xpc_notloaded,
+	(enum xpc_retval(*)(partid_t, int, void *, xpc_notify_func, void *))
+	    xpc_notloaded,
+	(void (*)(partid_t, int, void *))xpc_notloaded,
+	(enum xpc_retval(*)(partid_t, void *))xpc_notloaded
 };
 
-
 /*
  * XPC calls this when it (the XPC module) has been loaded.
  */
 void
-xpc_set_interface(void (*connect)(int),
-		void (*disconnect)(int),
-		enum xpc_retval (*allocate)(partid_t, int, u32, void **),
-		enum xpc_retval (*send)(partid_t, int, void *),
-		enum xpc_retval (*send_notify)(partid_t, int, void *,
-						xpc_notify_func, void *),
-		void (*received)(partid_t, int, void *),
-		enum xpc_retval (*partid_to_nasids)(partid_t, void *))
+xpc_set_interface(void (*connect) (int),
+		  void (*disconnect) (int),
+		  enum xpc_retval (*allocate) (partid_t, int, u32, void **),
+		  enum xpc_retval (*send) (partid_t, int, void *),
+		  enum xpc_retval (*send_notify) (partid_t, int, void *,
+						  xpc_notify_func, void *),
+		  void (*received) (partid_t, int, void *),
+		  enum xpc_retval (*partid_to_nasids) (partid_t, void *))
 {
 	xpc_interface.connect = connect;
 	xpc_interface.disconnect = disconnect;
@@ -77,28 +75,27 @@ xpc_set_interface(void (*connect)(int),
 	xpc_interface.partid_to_nasids = partid_to_nasids;
 }
 
-
 /*
  * XPC calls this when it (the XPC module) is being unloaded.
  */
 void
 xpc_clear_interface(void)
 {
-	xpc_interface.connect = (void (*)(int)) xpc_notloaded;
-	xpc_interface.disconnect = (void (*)(int)) xpc_notloaded;
-	xpc_interface.allocate = (enum xpc_retval (*)(partid_t, int, u32,
-					void **)) xpc_notloaded;
-	xpc_interface.send = (enum xpc_retval (*)(partid_t, int, void *))
-					xpc_notloaded;
-	xpc_interface.send_notify = (enum xpc_retval (*)(partid_t, int, void *,
-				    xpc_notify_func, void *)) xpc_notloaded;
+	xpc_interface.connect = (void (*)(int))xpc_notloaded;
+	xpc_interface.disconnect = (void (*)(int))xpc_notloaded;
+	xpc_interface.allocate = (enum xpc_retval(*)(partid_t, int, u32,
+						     void **))xpc_notloaded;
+	xpc_interface.send = (enum xpc_retval(*)(partid_t, int, void *))
+	    xpc_notloaded;
+	xpc_interface.send_notify = (enum xpc_retval(*)(partid_t, int, void *,
+							xpc_notify_func,
+							void *))xpc_notloaded;
 	xpc_interface.received = (void (*)(partid_t, int, void *))
-					xpc_notloaded;
-	xpc_interface.partid_to_nasids = (enum xpc_retval (*)(partid_t, void *))
-					xpc_notloaded;
+	    xpc_notloaded;
+	xpc_interface.partid_to_nasids = (enum xpc_retval(*)(partid_t, void *))
+	    xpc_notloaded;
 }
 
-
 /*
  * Register for automatic establishment of a channel connection whenever
  * a partition comes up.
@@ -125,11 +122,10 @@ xpc_clear_interface(void)
  */
 enum xpc_retval
 xpc_connect(int ch_number, xpc_channel_func func, void *key, u16 payload_size,
-		u16 nentries, u32 assigned_limit, u32 idle_limit)
+	    u16 nentries, u32 assigned_limit, u32 idle_limit)
 {
 	struct xpc_registration *registration;
 
-
 	DBUG_ON(ch_number < 0 || ch_number >= XPC_NCHANNELS);
 	DBUG_ON(payload_size = 0 || nentries = 0);
 	DBUG_ON(func = NULL);
@@ -162,7 +158,6 @@ xpc_connect(int ch_number, xpc_channel_f
 	return xpcSuccess;
 }
 
-
 /*
  * Remove the registration for automatic connection of the specified channel
  * when a partition comes up.
@@ -181,7 +176,6 @@ xpc_disconnect(int ch_number)
 {
 	struct xpc_registration *registration;
 
-
 	DBUG_ON(ch_number < 0 || ch_number >= XPC_NCHANNELS);
 
 	registration = &xpc_registrations[ch_number];
@@ -214,14 +208,12 @@ xpc_disconnect(int ch_number)
 	return;
 }
 
-
 int __init
 xp_init(void)
 {
 	int ret, ch_number;
-	u64 func_addr = *(u64 *) xp_nofault_PIOR;
-	u64 err_func_addr = *(u64 *) xp_error_PIOR;
-
+	u64 func_addr = *(u64 *)xp_nofault_PIOR;
+	u64 err_func_addr = *(u64 *)xp_error_PIOR;
 
 	if (!ia64_platform_is("sn2")) {
 		return -ENODEV;
@@ -237,9 +229,9 @@ xp_init(void)
 	 * work around).
 	 */
 	if ((ret = sn_register_nofault_code(func_addr, err_func_addr,
-						err_func_addr, 1, 1)) != 0) {
+					    err_func_addr, 1, 1)) != 0) {
 		printk(KERN_ERR "XP: can't register nofault code, error=%d\n",
-			ret);
+		       ret);
 	}
 	/*
 	 * Setup the nofault PIO read target. (There is no special reason why
@@ -258,22 +250,21 @@ xp_init(void)
 
 	return 0;
 }
-module_init(xp_init);
 
+module_init(xp_init);
 
 void __exit
 xp_exit(void)
 {
-	u64 func_addr = *(u64 *) xp_nofault_PIOR;
-	u64 err_func_addr = *(u64 *) xp_error_PIOR;
-
+	u64 func_addr = *(u64 *)xp_nofault_PIOR;
+	u64 err_func_addr = *(u64 *)xp_error_PIOR;
 
 	/* unregister the PIO read nofault code region */
-	(void) sn_register_nofault_code(func_addr, err_func_addr,
-					err_func_addr, 1, 0);
+	(void)sn_register_nofault_code(func_addr, err_func_addr,
+				       err_func_addr, 1, 0);
 }
-module_exit(xp_exit);
 
+module_exit(xp_exit);
 
 MODULE_AUTHOR("Silicon Graphics, Inc.");
 MODULE_DESCRIPTION("Cross Partition (XP) base");
@@ -287,4 +278,3 @@ EXPORT_SYMBOL(xpc_clear_interface);
 EXPORT_SYMBOL(xpc_set_interface);
 EXPORT_SYMBOL(xpc_connect);
 EXPORT_SYMBOL(xpc_disconnect);
-
Index: linux-2.6/drivers/misc/sgi-xp/xp_nofault.S
=================================--- linux-2.6.orig/drivers/misc/sgi-xp/xp_nofault.S	2008-04-22 10:54:11.000000000 -0500
+++ linux-2.6/drivers/misc/sgi-xp/xp_nofault.S	2008-04-22 11:32:20.800401928 -0500
@@ -6,7 +6,6 @@
  * Copyright (c) 2004-2008 Silicon Graphics, Inc.  All Rights Reserved.
  */
 
-
 /*
  * The xp_nofault_PIOR function takes a pointer to a remote PIO register
  * and attempts to load and consume a value from it.  This function
Index: linux-2.6/drivers/misc/sgi-xp/xpc.h
=================================--- linux-2.6.orig/drivers/misc/sgi-xp/xpc.h	2008-04-22 11:06:51.000000000 -0500
+++ linux-2.6/drivers/misc/sgi-xp/xpc.h	2008-04-22 11:32:20.824404880 -0500
@@ -6,7 +6,6 @@
  * Copyright (c) 2004-2008 Silicon Graphics, Inc.  All Rights Reserved.
  */
 
-
 /*
  * Cross Partition Communication (XPC) structures and macros.
  */
@@ -14,7 +13,6 @@
 #ifndef _DRIVERS_MISC_SGIXP_XPC_H
 #define _DRIVERS_MISC_SGIXP_XPC_H
 
-
 #include <linux/interrupt.h>
 #include <linux/sysctl.h>
 #include <linux/device.h>
@@ -29,7 +27,6 @@
 #include <asm/sn/shub_mmr.h>
 #include "xp.h"
 
-
 /*
  * XPC Version numbers consist of a major and minor number. XPC can always
  * talk to versions with same major #, and never talk to versions with a
@@ -39,7 +36,6 @@
 #define XPC_VERSION_MAJOR(_v)		((_v) >> 4)
 #define XPC_VERSION_MINOR(_v)		((_v) & 0xf)
 
-
 /*
  * The next macros define word or bit representations for given
  * C-brick nasid in either the SAL provided bit array representing
@@ -67,7 +63,6 @@
 /* define the process name of the discovery thread */
 #define XPC_DISCOVERY_THREAD_NAME	"xpc_discovery"
 
-
 /*
  * the reserved page
  *
@@ -121,7 +116,7 @@ struct xpc_rsvd_page {
 	u64 nasids_size;	/* SAL: size of each nasid mask in bytes */
 };
 
-#define XPC_RP_VERSION _XPC_VERSION(1,1) /* version 1.1 of the reserved page */
+#define XPC_RP_VERSION _XPC_VERSION(1,1)	/* version 1.1 of the reserved page */
 
 #define XPC_SUPPORTS_RP_STAMP(_version) \
 			(_version >= _XPC_VERSION(1,1))
@@ -138,14 +133,12 @@ xpc_compare_stamps(struct timespec *stam
 {
 	int ret;
 
-
 	if ((ret = stamp1->tv_sec - stamp2->tv_sec) = 0) {
 		ret = stamp1->tv_nsec - stamp2->tv_nsec;
 	}
 	return ret;
 }
 
-
 /*
  * Define the structures by which XPC variables can be exported to other
  * partitions. (There are two: struct xpc_vars and struct xpc_vars_part)
@@ -172,12 +165,11 @@ struct xpc_vars {
 	AMO_t *amos_page;	/* vaddr of page of AMOs from MSPEC driver */
 };
 
-#define XPC_V_VERSION _XPC_VERSION(3,1) /* version 3.1 of the cross vars */
+#define XPC_V_VERSION _XPC_VERSION(3,1)	/* version 3.1 of the cross vars */
 
 #define XPC_SUPPORTS_DISENGAGE_REQUEST(_version) \
 			(_version >= _XPC_VERSION(3,1))
 
-
 static inline int
 xpc_hb_allowed(partid_t partid, struct xpc_vars *vars)
 {
@@ -193,7 +185,7 @@ xpc_allow_hb(partid_t partid, struct xpc
 		old_mask = vars->heartbeating_to_mask;
 		new_mask = (old_mask | (1UL << partid));
 	} while (cmpxchg(&vars->heartbeating_to_mask, old_mask, new_mask) !-							old_mask);
+		 old_mask);
 }
 
 static inline void
@@ -205,10 +197,9 @@ xpc_disallow_hb(partid_t partid, struct 
 		old_mask = vars->heartbeating_to_mask;
 		new_mask = (old_mask & ~(1UL << partid));
 	} while (cmpxchg(&vars->heartbeating_to_mask, old_mask, new_mask) !-							old_mask);
+		 old_mask);
 }
 
-
 /*
  * The AMOs page consists of a number of AMO variables which are divided into
  * four groups, The first two groups are used to identify an IRQ's sender.
@@ -222,7 +213,6 @@ xpc_disallow_hb(partid_t partid, struct 
 #define XPC_ENGAGED_PARTITIONS_AMO (XPC_ACTIVATE_IRQ_AMOS + XP_NASID_MASK_WORDS)
 #define XPC_DISENGAGE_REQUEST_AMO  (XPC_ENGAGED_PARTITIONS_AMO + 1)
 
-
 /*
  * The following structure describes the per partition specific variables.
  *
@@ -257,9 +247,8 @@ struct xpc_vars_part {
  * MAGIC2 indicates that this partition has pulled the remote partititions
  * per partition variables that pertain to this partition.
  */
-#define XPC_VP_MAGIC1	0x0053524156435058L  /* 'XPCVARS\0'L (little endian) */
-#define XPC_VP_MAGIC2	0x0073726176435058L  /* 'XPCvars\0'L (little endian) */
-
+#define XPC_VP_MAGIC1	0x0053524156435058L	/* 'XPCVARS\0'L (little endian) */
+#define XPC_VP_MAGIC2	0x0073726176435058L	/* 'XPCvars\0'L (little endian) */
 
 /* the reserved page sizes and offsets */
 
@@ -271,7 +260,6 @@ struct xpc_vars_part {
 #define XPC_RP_VARS(_rp)	((struct xpc_vars *) XPC_RP_MACH_NASIDS(_rp) + xp_nasid_mask_words)
 #define XPC_RP_VARS_PART(_rp)	(struct xpc_vars_part *) ((u8 *) XPC_RP_VARS(rp) + XPC_RP_VARS_SIZE)
 
-
 /*
  * Functions registered by add_timer() or called by kernel_thread() only
  * allow for a single 64-bit argument. The following macros can be used to
@@ -285,8 +273,6 @@ struct xpc_vars_part {
 #define XPC_UNPACK_ARG1(_args)	(((u64) _args) & 0xffffffff)
 #define XPC_UNPACK_ARG2(_args)	((((u64) _args) >> 32) & 0xffffffff)
 
-
-
 /*
  * Define a Get/Put value pair (pointers) used with a message queue.
  */
@@ -298,8 +284,6 @@ struct xpc_gp {
 #define XPC_GP_SIZE \
 		L1_CACHE_ALIGN(sizeof(struct xpc_gp) * XPC_NCHANNELS)
 
-
-
 /*
  * Define a structure that contains arguments associated with opening and
  * closing a channel.
@@ -315,20 +299,15 @@ struct xpc_openclose_args {
 #define XPC_OPENCLOSE_ARGS_SIZE \
 	      L1_CACHE_ALIGN(sizeof(struct xpc_openclose_args) * XPC_NCHANNELS)
 
-
-
 /* struct xpc_msg flags */
 
 #define	XPC_M_DONE		0x01	/* msg has been received/consumed */
 #define	XPC_M_READY		0x02	/* msg is ready to be sent */
 #define	XPC_M_INTERRUPT		0x04	/* send interrupt when msg consumed */
 
-
 #define XPC_MSG_ADDRESS(_payload) \
 		((struct xpc_msg *)((u8 *)(_payload) - XPC_MSG_PAYLOAD_OFFSET))
 
-
-
 /*
  * Defines notify entry.
  *
@@ -336,19 +315,17 @@ struct xpc_openclose_args {
  * and consumed by the intended recipient.
  */
 struct xpc_notify {
-	volatile u8 type;		/* type of notification */
+	volatile u8 type;	/* type of notification */
 
 	/* the following two fields are only used if type = XPC_N_CALL */
-	xpc_notify_func func;		/* user's notify function */
-	void *key;			/* pointer to user's key */
+	xpc_notify_func func;	/* user's notify function */
+	void *key;		/* pointer to user's key */
 };
 
 /* struct xpc_notify type of notification */
 
 #define	XPC_N_CALL		0x01	/* notify function provided by user */
 
-
-
 /*
  * Define the structure that manages all the stuff required by a channel. In
  * particular, they are used to manage the messages sent across the channel.
@@ -428,48 +405,48 @@ struct xpc_notify {
  *	messages.
  */
 struct xpc_channel {
-	partid_t partid;		/* ID of remote partition connected */
-	spinlock_t lock;		/* lock for updating this structure */
-	u32 flags;			/* general flags */
-
-	enum xpc_retval reason;		/* reason why channel is disconnect'g */
-	int reason_line;		/* line# disconnect initiated from */
-
-	u16 number;			/* channel # */
-
-	u16 msg_size;			/* sizeof each msg entry */
-	u16 local_nentries;		/* #of msg entries in local msg queue */
-	u16 remote_nentries;		/* #of msg entries in remote msg queue*/
+	partid_t partid;	/* ID of remote partition connected */
+	spinlock_t lock;	/* lock for updating this structure */
+	u32 flags;		/* general flags */
+
+	enum xpc_retval reason;	/* reason why channel is disconnect'g */
+	int reason_line;	/* line# disconnect initiated from */
+
+	u16 number;		/* channel # */
+
+	u16 msg_size;		/* sizeof each msg entry */
+	u16 local_nentries;	/* #of msg entries in local msg queue */
+	u16 remote_nentries;	/* #of msg entries in remote msg queue */
 
 	void *local_msgqueue_base;	/* base address of kmalloc'd space */
 	struct xpc_msg *local_msgqueue;	/* local message queue */
 	void *remote_msgqueue_base;	/* base address of kmalloc'd space */
-	struct xpc_msg *remote_msgqueue;/* cached copy of remote partition's */
-					/* local message queue */
-	u64 remote_msgqueue_pa;		/* phys addr of remote partition's */
-					/* local message queue */
+	struct xpc_msg *remote_msgqueue;	/* cached copy of remote partition's */
+						/* local message queue */
+	u64 remote_msgqueue_pa;	/* phys addr of remote partition's */
+				/* local message queue */
 
-	atomic_t references;		/* #of external references to queues */
+	atomic_t references;	/* #of external references to queues */
 
-	atomic_t n_on_msg_allocate_wq;   /* #on msg allocation wait queue */
-	wait_queue_head_t msg_allocate_wq; /* msg allocation wait queue */
+	atomic_t n_on_msg_allocate_wq;	/* #on msg allocation wait queue */
+	wait_queue_head_t msg_allocate_wq;	/* msg allocation wait queue */
 
-	u8 delayed_IPI_flags;		/* IPI flags received, but delayed */
-					/* action until channel disconnected */
+	u8 delayed_IPI_flags;	/* IPI flags received, but delayed */
+				/* action until channel disconnected */
 
 	/* queue of msg senders who want to be notified when msg received */
 
-	atomic_t n_to_notify;		/* #of msg senders to notify */
-	struct xpc_notify *notify_queue;/* notify queue for messages sent */
+	atomic_t n_to_notify;	/* #of msg senders to notify */
+	struct xpc_notify *notify_queue;	/* notify queue for messages sent */
 
-	xpc_channel_func func;		/* user's channel function */
-	void *key;			/* pointer to user's key */
+	xpc_channel_func func;	/* user's channel function */
+	void *key;		/* pointer to user's key */
 
 	struct mutex msg_to_pull_mutex;	/* next msg to pull serialization */
-	struct completion wdisconnect_wait; /* wait for channel disconnect */
+	struct completion wdisconnect_wait;	/* wait for channel disconnect */
 
-	struct xpc_openclose_args *local_openclose_args; /* args passed on */
-					/* opening or closing of channel */
+	struct xpc_openclose_args *local_openclose_args;	/* args passed on */
+								/* opening or closing of channel */
 
 	/* various flavors of local and remote Get/Put values */
 
@@ -477,7 +454,7 @@ struct xpc_channel {
 	struct xpc_gp remote_GP;	/* remote Get/Put values */
 	struct xpc_gp w_local_GP;	/* working local Get/Put values */
 	struct xpc_gp w_remote_GP;	/* working remote Get/Put values */
-	s64 next_msg_to_pull;		/* Put value of next msg to pull */
+	s64 next_msg_to_pull;	/* Put value of next msg to pull */
 
 	/* kthread management related fields */
 
@@ -485,48 +462,45 @@ struct xpc_channel {
 // >>> allow the assigned limit be unbounded and let the idle limit be dynamic
 // >>> dependent on activity over the last interval of time
 	atomic_t kthreads_assigned;	/* #of kthreads assigned to channel */
-	u32 kthreads_assigned_limit; 	/* limit on #of kthreads assigned */
-	atomic_t kthreads_idle;		/* #of kthreads idle waiting for work */
+	u32 kthreads_assigned_limit;	/* limit on #of kthreads assigned */
+	atomic_t kthreads_idle;	/* #of kthreads idle waiting for work */
 	u32 kthreads_idle_limit;	/* limit on #of kthreads idle */
 	atomic_t kthreads_active;	/* #of kthreads actively working */
 	// >>> following field is temporary
-	u32 kthreads_created;		/* total #of kthreads created */
+	u32 kthreads_created;	/* total #of kthreads created */
 
 	wait_queue_head_t idle_wq;	/* idle kthread wait queue */
 
 } ____cacheline_aligned;
 
-
 /* struct xpc_channel flags */
 
-#define	XPC_C_WASCONNECTED	0x00000001 /* channel was connected */
+#define	XPC_C_WASCONNECTED	0x00000001	/* channel was connected */
 
-#define	XPC_C_ROPENREPLY	0x00000002 /* remote open channel reply */
-#define	XPC_C_OPENREPLY		0x00000004 /* local open channel reply */
-#define	XPC_C_ROPENREQUEST	0x00000008 /* remote open channel request */
-#define	XPC_C_OPENREQUEST	0x00000010 /* local open channel request */
+#define	XPC_C_ROPENREPLY	0x00000002	/* remote open channel reply */
+#define	XPC_C_OPENREPLY		0x00000004	/* local open channel reply */
+#define	XPC_C_ROPENREQUEST	0x00000008	/* remote open channel request */
+#define	XPC_C_OPENREQUEST	0x00000010	/* local open channel request */
 
-#define	XPC_C_SETUP		0x00000020 /* channel's msgqueues are alloc'd */
-#define	XPC_C_CONNECTEDCALLOUT	0x00000040 /* connected callout initiated */
+#define	XPC_C_SETUP		0x00000020	/* channel's msgqueues are alloc'd */
+#define	XPC_C_CONNECTEDCALLOUT	0x00000040	/* connected callout initiated */
 #define	XPC_C_CONNECTEDCALLOUT_MADE \
-				0x00000080 /* connected callout completed */
-#define	XPC_C_CONNECTED		0x00000100 /* local channel is connected */
-#define	XPC_C_CONNECTING	0x00000200 /* channel is being connected */
-
-#define	XPC_C_RCLOSEREPLY	0x00000400 /* remote close channel reply */
-#define	XPC_C_CLOSEREPLY	0x00000800 /* local close channel reply */
-#define	XPC_C_RCLOSEREQUEST	0x00001000 /* remote close channel request */
-#define	XPC_C_CLOSEREQUEST	0x00002000 /* local close channel request */
+				0x00000080	/* connected callout completed */
+#define	XPC_C_CONNECTED		0x00000100	/* local channel is connected */
+#define	XPC_C_CONNECTING	0x00000200	/* channel is being connected */
+
+#define	XPC_C_RCLOSEREPLY	0x00000400	/* remote close channel reply */
+#define	XPC_C_CLOSEREPLY	0x00000800	/* local close channel reply */
+#define	XPC_C_RCLOSEREQUEST	0x00001000	/* remote close channel request */
+#define	XPC_C_CLOSEREQUEST	0x00002000	/* local close channel request */
 
-#define	XPC_C_DISCONNECTED	0x00004000 /* channel is disconnected */
-#define	XPC_C_DISCONNECTING	0x00008000 /* channel is being disconnected */
+#define	XPC_C_DISCONNECTED	0x00004000	/* channel is disconnected */
+#define	XPC_C_DISCONNECTING	0x00008000	/* channel is being disconnected */
 #define	XPC_C_DISCONNECTINGCALLOUT \
-				0x00010000 /* disconnecting callout initiated */
+				0x00010000	/* disconnecting callout initiated */
 #define	XPC_C_DISCONNECTINGCALLOUT_MADE \
-				0x00020000 /* disconnecting callout completed */
-#define	XPC_C_WDISCONNECT	0x00040000 /* waiting for channel disconnect */
-
-
+				0x00020000	/* disconnecting callout completed */
+#define	XPC_C_WDISCONNECT	0x00040000	/* waiting for channel disconnect */
 
 /*
  * Manages channels on a partition basis. There is one of these structures
@@ -537,33 +511,31 @@ struct xpc_partition {
 
 	/* XPC HB infrastructure */
 
-	u8 remote_rp_version;		/* version# of partition's rsvd pg */
-	struct timespec remote_rp_stamp;/* time when rsvd pg was initialized */
-	u64 remote_rp_pa;		/* phys addr of partition's rsvd pg */
-	u64 remote_vars_pa;		/* phys addr of partition's vars */
+	u8 remote_rp_version;	/* version# of partition's rsvd pg */
+	struct timespec remote_rp_stamp;	/* time when rsvd pg was initialized */
+	u64 remote_rp_pa;	/* phys addr of partition's rsvd pg */
+	u64 remote_vars_pa;	/* phys addr of partition's vars */
 	u64 remote_vars_part_pa;	/* phys addr of partition's vars part */
-	u64 last_heartbeat;		/* HB at last read */
+	u64 last_heartbeat;	/* HB at last read */
 	u64 remote_amos_page_pa;	/* phys addr of partition's amos page */
-	int remote_act_nasid;		/* active part's act/deact nasid */
+	int remote_act_nasid;	/* active part's act/deact nasid */
 	int remote_act_phys_cpuid;	/* active part's act/deact phys cpuid */
-	u32 act_IRQ_rcvd;		/* IRQs since activation */
-	spinlock_t act_lock;		/* protect updating of act_state */
-	u8 act_state;			/* from XPC HB viewpoint */
-	u8 remote_vars_version;		/* version# of partition's vars */
-	enum xpc_retval reason;		/* reason partition is deactivating */
-	int reason_line;		/* line# deactivation initiated from */
-	int reactivate_nasid;		/* nasid in partition to reactivate */
+	u32 act_IRQ_rcvd;	/* IRQs since activation */
+	spinlock_t act_lock;	/* protect updating of act_state */
+	u8 act_state;		/* from XPC HB viewpoint */
+	u8 remote_vars_version;	/* version# of partition's vars */
+	enum xpc_retval reason;	/* reason partition is deactivating */
+	int reason_line;	/* line# deactivation initiated from */
+	int reactivate_nasid;	/* nasid in partition to reactivate */
 
-	unsigned long disengage_request_timeout; /* timeout in jiffies */
+	unsigned long disengage_request_timeout;	/* timeout in jiffies */
 	struct timer_list disengage_request_timer;
 
-
 	/* XPC infrastructure referencing and teardown control */
 
 	volatile u8 setup_state;	/* infrastructure setup state */
 	wait_queue_head_t teardown_wq;	/* kthread waiting to teardown infra */
-	atomic_t references;		/* #of references to infrastructure */
-
+	atomic_t references;	/* #of references to infrastructure */
 
 	/*
 	 * NONE OF THE PRECEDING FIELDS OF THIS STRUCTURE WILL BE CLEARED WHEN
@@ -572,53 +544,48 @@ struct xpc_partition {
 	 * 'nchannels' FIELD MUST BE THE FIRST OF THE FIELDS TO BE CLEARED.)
 	 */
 
-
-	u8 nchannels;		   /* #of defined channels supported */
-	atomic_t nchannels_active; /* #of channels that are not DISCONNECTED */
-	atomic_t nchannels_engaged;/* #of channels engaged with remote part */
-	struct xpc_channel *channels;/* array of channel structures */
-
-	void *local_GPs_base;	  /* base address of kmalloc'd space */
-	struct xpc_gp *local_GPs; /* local Get/Put values */
-	void *remote_GPs_base;    /* base address of kmalloc'd space */
-	struct xpc_gp *remote_GPs;/* copy of remote partition's local Get/Put */
-				  /* values */
-	u64 remote_GPs_pa;	  /* phys address of remote partition's local */
-				  /* Get/Put values */
-
+	u8 nchannels;		/* #of defined channels supported */
+	atomic_t nchannels_active;	/* #of channels that are not DISCONNECTED */
+	atomic_t nchannels_engaged;	/* #of channels engaged with remote part */
+	struct xpc_channel *channels;	/* array of channel structures */
+
+	void *local_GPs_base;	/* base address of kmalloc'd space */
+	struct xpc_gp *local_GPs;	/* local Get/Put values */
+	void *remote_GPs_base;	/* base address of kmalloc'd space */
+	struct xpc_gp *remote_GPs;	/* copy of remote partition's local Get/Put */
+					/* values */
+	u64 remote_GPs_pa;	/* phys address of remote partition's local */
+				/* Get/Put values */
 
 	/* fields used to pass args when opening or closing a channel */
 
-	void *local_openclose_args_base;  /* base address of kmalloc'd space */
-	struct xpc_openclose_args *local_openclose_args;  /* local's args */
-	void *remote_openclose_args_base; /* base address of kmalloc'd space */
-	struct xpc_openclose_args *remote_openclose_args; /* copy of remote's */
-					  /* args */
-	u64 remote_openclose_args_pa;	  /* phys addr of remote's args */
-
+	void *local_openclose_args_base;	/* base address of kmalloc'd space */
+	struct xpc_openclose_args *local_openclose_args;	/* local's args */
+	void *remote_openclose_args_base;	/* base address of kmalloc'd space */
+	struct xpc_openclose_args *remote_openclose_args;	/* copy of remote's */
+								/* args */
+	u64 remote_openclose_args_pa;	/* phys addr of remote's args */
 
 	/* IPI sending, receiving and handling related fields */
 
-	int remote_IPI_nasid;	    /* nasid of where to send IPIs */
-	int remote_IPI_phys_cpuid;  /* phys CPU ID of where to send IPIs */
-	AMO_t *remote_IPI_amo_va;   /* address of remote IPI AMO_t structure */
-
-	AMO_t *local_IPI_amo_va;    /* address of IPI AMO_t structure */
-	u64 local_IPI_amo;	    /* IPI amo flags yet to be handled */
-	char IPI_owner[8];	    /* IPI owner's name */
-	struct timer_list dropped_IPI_timer; /* dropped IPI timer */
-
-	spinlock_t IPI_lock;	    /* IPI handler lock */
+	int remote_IPI_nasid;	/* nasid of where to send IPIs */
+	int remote_IPI_phys_cpuid;	/* phys CPU ID of where to send IPIs */
+	AMO_t *remote_IPI_amo_va;	/* address of remote IPI AMO_t structure */
+
+	AMO_t *local_IPI_amo_va;	/* address of IPI AMO_t structure */
+	u64 local_IPI_amo;	/* IPI amo flags yet to be handled */
+	char IPI_owner[8];	/* IPI owner's name */
+	struct timer_list dropped_IPI_timer;	/* dropped IPI timer */
 
+	spinlock_t IPI_lock;	/* IPI handler lock */
 
 	/* channel manager related fields */
 
 	atomic_t channel_mgr_requests;	/* #of requests to activate chan mgr */
-	wait_queue_head_t channel_mgr_wq; /* channel mgr's wait queue */
+	wait_queue_head_t channel_mgr_wq;	/* channel mgr's wait queue */
 
 } ____cacheline_aligned;
 
-
 /* struct xpc_partition act_state values (for XPC HB) */
 
 #define	XPC_P_INACTIVE		0x00	/* partition is not active */
@@ -627,11 +594,9 @@ struct xpc_partition {
 #define XPC_P_ACTIVE		0x03	/* xpc_partition_up() was called */
 #define XPC_P_DEACTIVATING	0x04	/* partition deactivation initiated */
 
-
 #define XPC_DEACTIVATE_PARTITION(_p, _reason) \
 			xpc_deactivate_partition(__LINE__, (_p), (_reason))
 
-
 /* struct xpc_partition setup_state values */
 
 #define XPC_P_UNSET		0x00	/* infrastructure was never setup */
@@ -639,8 +604,6 @@ struct xpc_partition {
 #define XPC_P_WTEARDOWN		0x02	/* waiting to teardown infrastructure */
 #define XPC_P_TORNDOWN		0x03	/* infrastructure is torndown */
 
-
-
 /*
  * struct xpc_partition IPI_timer #of seconds to wait before checking for
  * dropped IPIs. These occur whenever an IPI amo write doesn't complete until
@@ -648,22 +611,17 @@ struct xpc_partition {
  */
 #define XPC_P_DROPPED_IPI_WAIT	(0.25 * HZ)
 
-
 /* number of seconds to wait for other partitions to disengage */
 #define XPC_DISENGAGE_REQUEST_DEFAULT_TIMELIMIT	90
 
 /* interval in seconds to print 'waiting disengagement' messages */
 #define XPC_DISENGAGE_PRINTMSG_INTERVAL		10
 
-
 #define XPC_PARTID(_p)	((partid_t) ((_p) - &xpc_partitions[0]))
 
-
-
 /* found in xp_main.c */
 extern struct xpc_registration xpc_registrations[];
 
-
 /* found in xpc_main.c */
 extern struct device *xpc_part;
 extern struct device *xpc_chan;
@@ -676,7 +634,6 @@ extern void xpc_activate_kthreads(struct
 extern void xpc_create_kthreads(struct xpc_channel *, int, int);
 extern void xpc_disconnect_wait(int);
 
-
 /* found in xpc_partition.c */
 extern int xpc_exiting;
 extern struct xpc_vars *xpc_vars;
@@ -696,10 +653,9 @@ extern void xpc_mark_partition_inactive(
 extern void xpc_discovery(void);
 extern void xpc_check_remote_hb(void);
 extern void xpc_deactivate_partition(const int, struct xpc_partition *,
-						enum xpc_retval);
+				     enum xpc_retval);
 extern enum xpc_retval xpc_initiate_partid_to_nasids(partid_t, void *);
 
-
 /* found in xpc_channel.c */
 extern void xpc_initiate_connect(int);
 extern void xpc_initiate_disconnect(int);
@@ -714,13 +670,11 @@ extern void xpc_process_channel_activity
 extern void xpc_connected_callout(struct xpc_channel *);
 extern void xpc_deliver_msg(struct xpc_channel *);
 extern void xpc_disconnect_channel(const int, struct xpc_channel *,
-					enum xpc_retval, unsigned long *);
+				   enum xpc_retval, unsigned long *);
 extern void xpc_disconnect_callout(struct xpc_channel *, enum xpc_retval);
 extern void xpc_partition_going_down(struct xpc_partition *, enum xpc_retval);
 extern void xpc_teardown_infrastructure(struct xpc_partition *);
 
-
-
 static inline void
 xpc_wakeup_channel_mgr(struct xpc_partition *part)
 {
@@ -729,8 +683,6 @@ xpc_wakeup_channel_mgr(struct xpc_partit
 	}
 }
 
-
-
 /*
  * These next two inlines are used to keep us from tearing down a channel's
  * msg queues while a thread may be referencing them.
@@ -752,12 +704,9 @@ xpc_msgqueue_deref(struct xpc_channel *c
 	}
 }
 
-
-
 #define XPC_DISCONNECT_CHANNEL(_ch, _reason, _irqflgs) \
 		xpc_disconnect_channel(__LINE__, _ch, _reason, _irqflgs)
 
-
 /*
  * These two inlines are used to keep us from tearing down a partition's
  * setup infrastructure while a thread may be referencing it.
@@ -767,7 +716,6 @@ xpc_part_deref(struct xpc_partition *par
 {
 	s32 refs = atomic_dec_return(&part->references);
 
-
 	DBUG_ON(refs < 0);
 	if (refs = 0 && part->setup_state = XPC_P_WTEARDOWN) {
 		wake_up(&part->teardown_wq);
@@ -779,7 +727,6 @@ xpc_part_ref(struct xpc_partition *part)
 {
 	int setup;
 
-
 	atomic_inc(&part->references);
 	setup = (part->setup_state = XPC_P_SETUP);
 	if (!setup) {
@@ -788,8 +735,6 @@ xpc_part_ref(struct xpc_partition *part)
 	return setup;
 }
 
-
-
 /*
  * The following macro is to be used for the setting of the reason and
  * reason_line fields in both the struct xpc_channel and struct xpc_partition
@@ -801,8 +746,6 @@ xpc_part_ref(struct xpc_partition *part)
 		(_p)->reason_line = _line; \
 	}
 
-
-
 /*
  * This next set of inlines are used to keep track of when a partition is
  * potentially engaged in accessing memory belonging to another partition.
@@ -812,23 +755,24 @@ static inline void
 xpc_mark_partition_engaged(struct xpc_partition *part)
 {
 	unsigned long irq_flags;
-	AMO_t *amo = (AMO_t *) __va(part->remote_amos_page_pa +
-				(XPC_ENGAGED_PARTITIONS_AMO * sizeof(AMO_t)));
-
+	AMO_t *amo = (AMO_t *)__va(part->remote_amos_page_pa +
+				   (XPC_ENGAGED_PARTITIONS_AMO *
+				    sizeof(AMO_t)));
 
 	local_irq_save(irq_flags);
 
 	/* set bit corresponding to our partid in remote partition's AMO */
-	FETCHOP_STORE_OP(TO_AMO((u64) &amo->variable), FETCHOP_OR,
-						(1UL << sn_partition_id));
+	FETCHOP_STORE_OP(TO_AMO((u64)&amo->variable), FETCHOP_OR,
+			 (1UL << sn_partition_id));
 	/*
 	 * We must always use the nofault function regardless of whether we
 	 * are on a Shub 1.1 system or a Shub 1.2 slice 0xc processor. If we
 	 * didn't, we'd never know that the other partition is down and would
 	 * keep sending IPIs and AMOs to it until the heartbeat times out.
 	 */
-	(void) xp_nofault_PIOR((u64 *) GLOBAL_MMR_ADDR(NASID_GET(&amo->
-				variable), xp_nofault_PIOR_target));
+	(void)xp_nofault_PIOR((u64 *)GLOBAL_MMR_ADDR(NASID_GET(&amo->
+							       variable),
+						     xp_nofault_PIOR_target));
 
 	local_irq_restore(irq_flags);
 }
@@ -837,23 +781,24 @@ static inline void
 xpc_mark_partition_disengaged(struct xpc_partition *part)
 {
 	unsigned long irq_flags;
-	AMO_t *amo = (AMO_t *) __va(part->remote_amos_page_pa +
-				(XPC_ENGAGED_PARTITIONS_AMO * sizeof(AMO_t)));
-
+	AMO_t *amo = (AMO_t *)__va(part->remote_amos_page_pa +
+				   (XPC_ENGAGED_PARTITIONS_AMO *
+				    sizeof(AMO_t)));
 
 	local_irq_save(irq_flags);
 
 	/* clear bit corresponding to our partid in remote partition's AMO */
-	FETCHOP_STORE_OP(TO_AMO((u64) &amo->variable), FETCHOP_AND,
-						~(1UL << sn_partition_id));
+	FETCHOP_STORE_OP(TO_AMO((u64)&amo->variable), FETCHOP_AND,
+			 ~(1UL << sn_partition_id));
 	/*
 	 * We must always use the nofault function regardless of whether we
 	 * are on a Shub 1.1 system or a Shub 1.2 slice 0xc processor. If we
 	 * didn't, we'd never know that the other partition is down and would
 	 * keep sending IPIs and AMOs to it until the heartbeat times out.
 	 */
-	(void) xp_nofault_PIOR((u64 *) GLOBAL_MMR_ADDR(NASID_GET(&amo->
-				variable), xp_nofault_PIOR_target));
+	(void)xp_nofault_PIOR((u64 *)GLOBAL_MMR_ADDR(NASID_GET(&amo->
+							       variable),
+						     xp_nofault_PIOR_target));
 
 	local_irq_restore(irq_flags);
 }
@@ -862,23 +807,23 @@ static inline void
 xpc_request_partition_disengage(struct xpc_partition *part)
 {
 	unsigned long irq_flags;
-	AMO_t *amo = (AMO_t *) __va(part->remote_amos_page_pa +
-				(XPC_DISENGAGE_REQUEST_AMO * sizeof(AMO_t)));
-
+	AMO_t *amo = (AMO_t *)__va(part->remote_amos_page_pa +
+				   (XPC_DISENGAGE_REQUEST_AMO * sizeof(AMO_t)));
 
 	local_irq_save(irq_flags);
 
 	/* set bit corresponding to our partid in remote partition's AMO */
-	FETCHOP_STORE_OP(TO_AMO((u64) &amo->variable), FETCHOP_OR,
-						(1UL << sn_partition_id));
+	FETCHOP_STORE_OP(TO_AMO((u64)&amo->variable), FETCHOP_OR,
+			 (1UL << sn_partition_id));
 	/*
 	 * We must always use the nofault function regardless of whether we
 	 * are on a Shub 1.1 system or a Shub 1.2 slice 0xc processor. If we
 	 * didn't, we'd never know that the other partition is down and would
 	 * keep sending IPIs and AMOs to it until the heartbeat times out.
 	 */
-	(void) xp_nofault_PIOR((u64 *) GLOBAL_MMR_ADDR(NASID_GET(&amo->
-				variable), xp_nofault_PIOR_target));
+	(void)xp_nofault_PIOR((u64 *)GLOBAL_MMR_ADDR(NASID_GET(&amo->
+							       variable),
+						     xp_nofault_PIOR_target));
 
 	local_irq_restore(irq_flags);
 }
@@ -887,23 +832,23 @@ static inline void
 xpc_cancel_partition_disengage_request(struct xpc_partition *part)
 {
 	unsigned long irq_flags;
-	AMO_t *amo = (AMO_t *) __va(part->remote_amos_page_pa +
-				(XPC_DISENGAGE_REQUEST_AMO * sizeof(AMO_t)));
-
+	AMO_t *amo = (AMO_t *)__va(part->remote_amos_page_pa +
+				   (XPC_DISENGAGE_REQUEST_AMO * sizeof(AMO_t)));
 
 	local_irq_save(irq_flags);
 
 	/* clear bit corresponding to our partid in remote partition's AMO */
-	FETCHOP_STORE_OP(TO_AMO((u64) &amo->variable), FETCHOP_AND,
-						~(1UL << sn_partition_id));
+	FETCHOP_STORE_OP(TO_AMO((u64)&amo->variable), FETCHOP_AND,
+			 ~(1UL << sn_partition_id));
 	/*
 	 * We must always use the nofault function regardless of whether we
 	 * are on a Shub 1.1 system or a Shub 1.2 slice 0xc processor. If we
 	 * didn't, we'd never know that the other partition is down and would
 	 * keep sending IPIs and AMOs to it until the heartbeat times out.
 	 */
-	(void) xp_nofault_PIOR((u64 *) GLOBAL_MMR_ADDR(NASID_GET(&amo->
-				variable), xp_nofault_PIOR_target));
+	(void)xp_nofault_PIOR((u64 *)GLOBAL_MMR_ADDR(NASID_GET(&amo->
+							       variable),
+						     xp_nofault_PIOR_target));
 
 	local_irq_restore(irq_flags);
 }
@@ -913,10 +858,9 @@ xpc_partition_engaged(u64 partid_mask)
 {
 	AMO_t *amo = xpc_vars->amos_page + XPC_ENGAGED_PARTITIONS_AMO;
 
-
 	/* return our partition's AMO variable ANDed with partid_mask */
-	return (FETCHOP_LOAD_OP(TO_AMO((u64) &amo->variable), FETCHOP_LOAD) &
-								partid_mask);
+	return (FETCHOP_LOAD_OP(TO_AMO((u64)&amo->variable), FETCHOP_LOAD) &
+		partid_mask);
 }
 
 static inline u64
@@ -924,10 +868,9 @@ xpc_partition_disengage_requested(u64 pa
 {
 	AMO_t *amo = xpc_vars->amos_page + XPC_DISENGAGE_REQUEST_AMO;
 
-
 	/* return our partition's AMO variable ANDed with partid_mask */
-	return (FETCHOP_LOAD_OP(TO_AMO((u64) &amo->variable), FETCHOP_LOAD) &
-								partid_mask);
+	return (FETCHOP_LOAD_OP(TO_AMO((u64)&amo->variable), FETCHOP_LOAD) &
+		partid_mask);
 }
 
 static inline void
@@ -935,10 +878,9 @@ xpc_clear_partition_engaged(u64 partid_m
 {
 	AMO_t *amo = xpc_vars->amos_page + XPC_ENGAGED_PARTITIONS_AMO;
 
-
 	/* clear bit(s) based on partid_mask in our partition's AMO */
-	FETCHOP_STORE_OP(TO_AMO((u64) &amo->variable), FETCHOP_AND,
-								~partid_mask);
+	FETCHOP_STORE_OP(TO_AMO((u64)&amo->variable), FETCHOP_AND,
+			 ~partid_mask);
 }
 
 static inline void
@@ -946,14 +888,11 @@ xpc_clear_partition_disengage_request(u6
 {
 	AMO_t *amo = xpc_vars->amos_page + XPC_DISENGAGE_REQUEST_AMO;
 
-
 	/* clear bit(s) based on partid_mask in our partition's AMO */
-	FETCHOP_STORE_OP(TO_AMO((u64) &amo->variable), FETCHOP_AND,
-								~partid_mask);
+	FETCHOP_STORE_OP(TO_AMO((u64)&amo->variable), FETCHOP_AND,
+			 ~partid_mask);
 }
 
-
-
 /*
  * The following set of macros and inlines are used for the sending and
  * receiving of IPIs (also known as IRQs). There are two flavors of IPIs,
@@ -964,20 +903,18 @@ xpc_clear_partition_disengage_request(u6
 static inline u64
 xpc_IPI_receive(AMO_t *amo)
 {
-	return FETCHOP_LOAD_OP(TO_AMO((u64) &amo->variable), FETCHOP_CLEAR);
+	return FETCHOP_LOAD_OP(TO_AMO((u64)&amo->variable), FETCHOP_CLEAR);
 }
 
-
 static inline enum xpc_retval
 xpc_IPI_send(AMO_t *amo, u64 flag, int nasid, int phys_cpuid, int vector)
 {
 	int ret = 0;
 	unsigned long irq_flags;
 
-
 	local_irq_save(irq_flags);
 
-	FETCHOP_STORE_OP(TO_AMO((u64) &amo->variable), FETCHOP_OR, flag);
+	FETCHOP_STORE_OP(TO_AMO((u64)&amo->variable), FETCHOP_OR, flag);
 	sn_send_IPI_phys(nasid, phys_cpuid, vector, 0);
 
 	/*
@@ -986,15 +923,14 @@ xpc_IPI_send(AMO_t *amo, u64 flag, int n
 	 * didn't, we'd never know that the other partition is down and would
 	 * keep sending IPIs and AMOs to it until the heartbeat times out.
 	 */
-	ret = xp_nofault_PIOR((u64 *) GLOBAL_MMR_ADDR(NASID_GET(&amo->variable),
-				xp_nofault_PIOR_target));
+	ret = xp_nofault_PIOR((u64 *)GLOBAL_MMR_ADDR(NASID_GET(&amo->variable),
+						     xp_nofault_PIOR_target));
 
 	local_irq_restore(irq_flags);
 
 	return ((ret = 0) ? xpcSuccess : xpcPioReadError);
 }
 
-
 /*
  * IPIs associated with SGI_XPC_ACTIVATE IRQ.
  */
@@ -1004,47 +940,47 @@ xpc_IPI_send(AMO_t *amo, u64 flag, int n
  */
 static inline void
 xpc_activate_IRQ_send(u64 amos_page_pa, int from_nasid, int to_nasid,
-			int to_phys_cpuid)
+		      int to_phys_cpuid)
 {
 	int w_index = XPC_NASID_W_INDEX(from_nasid);
 	int b_index = XPC_NASID_B_INDEX(from_nasid);
-	AMO_t *amos = (AMO_t *) __va(amos_page_pa +
-				(XPC_ACTIVATE_IRQ_AMOS * sizeof(AMO_t)));
-
+	AMO_t *amos = (AMO_t *)__va(amos_page_pa +
+				    (XPC_ACTIVATE_IRQ_AMOS * sizeof(AMO_t)));
 
-	(void) xpc_IPI_send(&amos[w_index], (1UL << b_index), to_nasid,
-				to_phys_cpuid, SGI_XPC_ACTIVATE);
+	(void)xpc_IPI_send(&amos[w_index], (1UL << b_index), to_nasid,
+			   to_phys_cpuid, SGI_XPC_ACTIVATE);
 }
 
 static inline void
 xpc_IPI_send_activate(struct xpc_vars *vars)
 {
 	xpc_activate_IRQ_send(vars->amos_page_pa, cnodeid_to_nasid(0),
-				vars->act_nasid, vars->act_phys_cpuid);
+			      vars->act_nasid, vars->act_phys_cpuid);
 }
 
 static inline void
 xpc_IPI_send_activated(struct xpc_partition *part)
 {
 	xpc_activate_IRQ_send(part->remote_amos_page_pa, cnodeid_to_nasid(0),
-			part->remote_act_nasid, part->remote_act_phys_cpuid);
+			      part->remote_act_nasid,
+			      part->remote_act_phys_cpuid);
 }
 
 static inline void
 xpc_IPI_send_reactivate(struct xpc_partition *part)
 {
 	xpc_activate_IRQ_send(xpc_vars->amos_page_pa, part->reactivate_nasid,
-				xpc_vars->act_nasid, xpc_vars->act_phys_cpuid);
+			      xpc_vars->act_nasid, xpc_vars->act_phys_cpuid);
 }
 
 static inline void
 xpc_IPI_send_disengage(struct xpc_partition *part)
 {
 	xpc_activate_IRQ_send(part->remote_amos_page_pa, cnodeid_to_nasid(0),
-			part->remote_act_nasid, part->remote_act_phys_cpuid);
+			      part->remote_act_nasid,
+			      part->remote_act_phys_cpuid);
 }
 
-
 /*
  * IPIs associated with SGI_XPC_NOTIFY IRQ.
  */
@@ -1058,18 +994,16 @@ xpc_IPI_send_disengage(struct xpc_partit
 
 static inline void
 xpc_notify_IRQ_send(struct xpc_channel *ch, u8 ipi_flag, char *ipi_flag_string,
-			unsigned long *irq_flags)
+		    unsigned long *irq_flags)
 {
 	struct xpc_partition *part = &xpc_partitions[ch->partid];
 	enum xpc_retval ret;
 
-
 	if (likely(part->act_state != XPC_P_DEACTIVATING)) {
 		ret = xpc_IPI_send(part->remote_IPI_amo_va,
-					(u64) ipi_flag << (ch->number * 8),
-					part->remote_IPI_nasid,
-					part->remote_IPI_phys_cpuid,
-					SGI_XPC_NOTIFY);
+				   (u64)ipi_flag << (ch->number * 8),
+				   part->remote_IPI_nasid,
+				   part->remote_IPI_phys_cpuid, SGI_XPC_NOTIFY);
 		dev_dbg(xpc_chan, "%s sent to partid=%d, channel=%d, ret=%d\n",
 			ipi_flag_string, ch->partid, ch->number, ret);
 		if (unlikely(ret != xpcSuccess)) {
@@ -1084,7 +1018,6 @@ xpc_notify_IRQ_send(struct xpc_channel *
 	}
 }
 
-
 /*
  * Make it look like the remote partition, which is associated with the
  * specified channel, sent us an IPI. This faked IPI will be handled
@@ -1095,18 +1028,16 @@ xpc_notify_IRQ_send(struct xpc_channel *
 
 static inline void
 xpc_notify_IRQ_send_local(struct xpc_channel *ch, u8 ipi_flag,
-				char *ipi_flag_string)
+			  char *ipi_flag_string)
 {
 	struct xpc_partition *part = &xpc_partitions[ch->partid];
 
-
-	FETCHOP_STORE_OP(TO_AMO((u64) &part->local_IPI_amo_va->variable),
-			FETCHOP_OR, ((u64) ipi_flag << (ch->number * 8)));
+	FETCHOP_STORE_OP(TO_AMO((u64)&part->local_IPI_amo_va->variable),
+			 FETCHOP_OR, ((u64)ipi_flag << (ch->number * 8)));
 	dev_dbg(xpc_chan, "%s sent local from partid=%d, channel=%d\n",
 		ipi_flag_string, ch->partid, ch->number);
 }
 
-
 /*
  * The sending and receiving of IPIs includes the setting of an AMO variable
  * to indicate the reason the IPI was sent. The 64-bit variable is divided
@@ -1121,7 +1052,6 @@ xpc_notify_IRQ_send_local(struct xpc_cha
 #define	XPC_IPI_OPENREPLY	0x08
 #define	XPC_IPI_MSGREQUEST	0x10
 
-
 /* given an AMO variable and a channel#, get its associated IPI flags */
 #define XPC_GET_IPI_FLAGS(_amo, _c)	((u8) (((_amo) >> ((_c) * 8)) & 0xff))
 #define XPC_SET_IPI_FLAGS(_amo, _c, _f)	(_amo) |= ((u64) (_f) << ((_c) * 8))
@@ -1129,13 +1059,11 @@ xpc_notify_IRQ_send_local(struct xpc_cha
 #define	XPC_ANY_OPENCLOSE_IPI_FLAGS_SET(_amo) ((_amo) & __IA64_UL_CONST(0x0f0f0f0f0f0f0f0f))
 #define XPC_ANY_MSG_IPI_FLAGS_SET(_amo)       ((_amo) & __IA64_UL_CONST(0x1010101010101010))
 
-
 static inline void
 xpc_IPI_send_closerequest(struct xpc_channel *ch, unsigned long *irq_flags)
 {
 	struct xpc_openclose_args *args = ch->local_openclose_args;
 
-
 	args->reason = ch->reason;
 
 	XPC_NOTIFY_IRQ_SEND(ch, XPC_IPI_CLOSEREQUEST, irq_flags);
@@ -1152,7 +1080,6 @@ xpc_IPI_send_openrequest(struct xpc_chan
 {
 	struct xpc_openclose_args *args = ch->local_openclose_args;
 
-
 	args->msg_size = ch->msg_size;
 	args->local_nentries = ch->local_nentries;
 
@@ -1164,7 +1091,6 @@ xpc_IPI_send_openreply(struct xpc_channe
 {
 	struct xpc_openclose_args *args = ch->local_openclose_args;
 
-
 	args->remote_nentries = ch->remote_nentries;
 	args->local_nentries = ch->local_nentries;
 	args->local_msgqueue_pa = __pa(ch->local_msgqueue);
@@ -1184,7 +1110,6 @@ xpc_IPI_send_local_msgrequest(struct xpc
 	XPC_NOTIFY_IRQ_SEND_LOCAL(ch, XPC_IPI_MSGREQUEST);
 }
 
-
 /*
  * Memory for XPC's AMO variables is allocated by the MSPEC driver. These
  * pages are located in the lowest granule. The lowest granule uses 4k pages
@@ -1201,13 +1126,10 @@ xpc_IPI_init(int index)
 {
 	AMO_t *amo = xpc_vars->amos_page + index;
 
-
-	(void) xpc_IPI_receive(amo);	/* clear AMO variable */
+	(void)xpc_IPI_receive(amo);	/* clear AMO variable */
 	return amo;
 }
 
-
-
 static inline enum xpc_retval
 xpc_map_bte_errors(bte_result_t error)
 {
@@ -1220,22 +1142,31 @@ xpc_map_bte_errors(bte_result_t error)
 		return xpcBteUnmappedError;
 	}
 	switch (error) {
-	case BTE_SUCCESS:	return xpcSuccess;
-	case BTEFAIL_DIR:	return xpcBteDirectoryError;
-	case BTEFAIL_POISON:	return xpcBtePoisonError;
-	case BTEFAIL_WERR:	return xpcBteWriteError;
-	case BTEFAIL_ACCESS:	return xpcBteAccessError;
-	case BTEFAIL_PWERR:	return xpcBtePWriteError;
-	case BTEFAIL_PRERR:	return xpcBtePReadError;
-	case BTEFAIL_TOUT:	return xpcBteTimeOutError;
-	case BTEFAIL_XTERR:	return xpcBteXtalkError;
-	case BTEFAIL_NOTAVAIL:	return xpcBteNotAvailable;
-	default:		return xpcBteUnmappedError;
+	case BTE_SUCCESS:
+		return xpcSuccess;
+	case BTEFAIL_DIR:
+		return xpcBteDirectoryError;
+	case BTEFAIL_POISON:
+		return xpcBtePoisonError;
+	case BTEFAIL_WERR:
+		return xpcBteWriteError;
+	case BTEFAIL_ACCESS:
+		return xpcBteAccessError;
+	case BTEFAIL_PWERR:
+		return xpcBtePWriteError;
+	case BTEFAIL_PRERR:
+		return xpcBtePReadError;
+	case BTEFAIL_TOUT:
+		return xpcBteTimeOutError;
+	case BTEFAIL_XTERR:
+		return xpcBteXtalkError;
+	case BTEFAIL_NOTAVAIL:
+		return xpcBteNotAvailable;
+	default:
+		return xpcBteUnmappedError;
 	}
 }
 
-
-
 /*
  * Check to see if there is any channel activity to/from the specified
  * partition.
@@ -1246,7 +1177,6 @@ xpc_check_for_channel_activity(struct xp
 	u64 IPI_amo;
 	unsigned long irq_flags;
 
-
 	IPI_amo = xpc_IPI_receive(part->local_IPI_amo_va);
 	if (IPI_amo = 0) {
 		return;
@@ -1262,6 +1192,4 @@ xpc_check_for_channel_activity(struct xp
 	xpc_wakeup_channel_mgr(part);
 }
 
-
 #endif /* _DRIVERS_MISC_SGIXP_XPC_H */
-
Index: linux-2.6/drivers/misc/sgi-xp/xpc_partition.c
=================================--- linux-2.6.orig/drivers/misc/sgi-xp/xpc_partition.c	2008-04-22 11:20:56.000000000 -0500
+++ linux-2.6/drivers/misc/sgi-xp/xpc_partition.c	2008-04-22 11:32:20.892413245 -0500
@@ -6,7 +6,6 @@
  * Copyright (c) 2004-2008 Silicon Graphics, Inc.  All Rights Reserved.
  */
 
-
 /*
  * Cross Partition Communication (XPC) partition support.
  *
@@ -16,7 +15,6 @@
  *
  */
 
-
 #include <linux/kernel.h>
 #include <linux/sysctl.h>
 #include <linux/cache.h>
@@ -30,11 +28,9 @@
 #include <asm/sn/addrs.h>
 #include "xpc.h"
 
-
 /* XPC is exiting flag */
 int xpc_exiting;
 
-
 /* SH_IPI_ACCESS shub register value on startup */
 static u64 xpc_sh1_IPI_access;
 static u64 xpc_sh2_IPI_access0;
@@ -42,11 +38,9 @@ static u64 xpc_sh2_IPI_access1;
 static u64 xpc_sh2_IPI_access2;
 static u64 xpc_sh2_IPI_access3;
 
-
 /* original protection values for each node */
 u64 xpc_prot_vec[MAX_NUMNODES];
 
-
 /* this partition's reserved page pointers */
 struct xpc_rsvd_page *xpc_rsvd_page;
 static u64 *xpc_part_nasids;
@@ -57,7 +51,6 @@ struct xpc_vars_part *xpc_vars_part;
 static int xp_nasid_mask_bytes;	/* actual size in bytes of nasid mask */
 static int xp_nasid_mask_words;	/* actual size in words of nasid mask */
 
-
 /*
  * For performance reasons, each entry of xpc_partitions[] is cacheline
  * aligned. And xpc_partitions[] is padded with an additional entry at the
@@ -66,7 +59,6 @@ static int xp_nasid_mask_words;	/* actua
  */
 struct xpc_partition xpc_partitions[XP_MAX_PARTITIONS + 1];
 
-
 /*
  * Generic buffer used to store a local copy of portions of a remote
  * partition's reserved page (either its header and part_nasids mask,
@@ -75,7 +67,6 @@ struct xpc_partition xpc_partitions[XP_M
 char *xpc_remote_copy_buffer;
 void *xpc_remote_copy_buffer_base;
 
-
 /*
  * Guarantee that the kmalloc'd memory is cacheline aligned.
  */
@@ -87,7 +78,7 @@ xpc_kmalloc_cacheline_aligned(size_t siz
 	if (*base = NULL) {
 		return NULL;
 	}
-	if ((u64) *base = L1_CACHE_ALIGN((u64) *base)) {
+	if ((u64)*base = L1_CACHE_ALIGN((u64)*base)) {
 		return *base;
 	}
 	kfree(*base);
@@ -97,10 +88,9 @@ xpc_kmalloc_cacheline_aligned(size_t siz
 	if (*base = NULL) {
 		return NULL;
 	}
-	return (void *) L1_CACHE_ALIGN((u64) *base);
+	return (void *)L1_CACHE_ALIGN((u64)*base);
 }
 
-
 /*
  * Given a nasid, get the physical address of the  partition's reserved page
  * for that nasid. This function returns 0 on any error.
@@ -117,11 +107,10 @@ xpc_get_rsvd_page_pa(int nasid)
 	u64 buf_len = 0;
 	void *buf_base = NULL;
 
-
 	while (1) {
 
 		status = sn_partition_reserved_page_pa(buf, &cookie, &rp_pa,
-								&len);
+						       &len);
 
 		dev_dbg(xpc_part, "SAL returned with status=%li, cookie="
 			"0x%016lx, address=0x%016lx, len=0x%016lx\n",
@@ -134,8 +123,9 @@ xpc_get_rsvd_page_pa(int nasid)
 		if (L1_CACHE_ALIGN(len) > buf_len) {
 			kfree(buf_base);
 			buf_len = L1_CACHE_ALIGN(len);
-			buf = (u64) xpc_kmalloc_cacheline_aligned(buf_len,
-							GFP_KERNEL, &buf_base);
+			buf = (u64)xpc_kmalloc_cacheline_aligned(buf_len,
+								 GFP_KERNEL,
+								 &buf_base);
 			if (buf_base = NULL) {
 				dev_err(xpc_part, "unable to kmalloc "
 					"len=0x%016lx\n", buf_len);
@@ -145,7 +135,7 @@ xpc_get_rsvd_page_pa(int nasid)
 		}
 
 		bte_res = xp_bte_copy(rp_pa, buf, buf_len,
-					(BTE_NOTIFY | BTE_WACQUIRE), NULL);
+				      (BTE_NOTIFY | BTE_WACQUIRE), NULL);
 		if (bte_res != BTE_SUCCESS) {
 			dev_dbg(xpc_part, "xp_bte_copy failed %i\n", bte_res);
 			status = SALRET_ERROR;
@@ -162,7 +152,6 @@ xpc_get_rsvd_page_pa(int nasid)
 	return rp_pa;
 }
 
-
 /*
  * Fill the partition reserved page with the information needed by
  * other partitions to discover we are alive and establish initial
@@ -176,7 +165,6 @@ xpc_rsvd_page_init(void)
 	u64 rp_pa, nasid_array = 0;
 	int i, ret;
 
-
 	/* get the local reserved page's address */
 
 	preempt_disable();
@@ -186,7 +174,7 @@ xpc_rsvd_page_init(void)
 		dev_err(xpc_part, "SAL failed to locate the reserved page\n");
 		return NULL;
 	}
-	rp = (struct xpc_rsvd_page *) __va(rp_pa);
+	rp = (struct xpc_rsvd_page *)__va(rp_pa);
 
 	if (rp->partid != sn_partition_id) {
 		dev_err(xpc_part, "the reserved page's partid of %d should be "
@@ -223,7 +211,7 @@ xpc_rsvd_page_init(void)
 	 * memory protections are never restricted.
 	 */
 	if ((amos_page = xpc_vars->amos_page) = NULL) {
-		amos_page = (AMO_t *) TO_AMO(uncached_alloc_page(0));
+		amos_page = (AMO_t *)TO_AMO(uncached_alloc_page(0));
 		if (amos_page = NULL) {
 			dev_err(xpc_part, "can't allocate page of AMOs\n");
 			return NULL;
@@ -234,30 +222,31 @@ xpc_rsvd_page_init(void)
 		 * when xpc_allow_IPI_ops() is called via xpc_hb_init().
 		 */
 		if (!enable_shub_wars_1_1()) {
-			ret = sn_change_memprotect(ia64_tpa((u64) amos_page),
-					PAGE_SIZE, SN_MEMPROT_ACCESS_CLASS_1,
-					&nasid_array);
+			ret = sn_change_memprotect(ia64_tpa((u64)amos_page),
+						   PAGE_SIZE,
+						   SN_MEMPROT_ACCESS_CLASS_1,
+						   &nasid_array);
 			if (ret != 0) {
 				dev_err(xpc_part, "can't change memory "
 					"protections\n");
 				uncached_free_page(__IA64_UNCACHED_OFFSET |
-						   TO_PHYS((u64) amos_page));
+						   TO_PHYS((u64)amos_page));
 				return NULL;
 			}
 		}
-	} else if (!IS_AMO_ADDRESS((u64) amos_page)) {
+	} else if (!IS_AMO_ADDRESS((u64)amos_page)) {
 		/*
 		 * EFI's XPBOOT can also set amos_page in the reserved page,
 		 * but it happens to leave it as an uncached physical address
 		 * and we need it to be an uncached virtual, so we'll have to
 		 * convert it.
 		 */
-		if (!IS_AMO_PHYS_ADDRESS((u64) amos_page)) {
+		if (!IS_AMO_PHYS_ADDRESS((u64)amos_page)) {
 			dev_err(xpc_part, "previously used amos_page address "
-				"is bad = 0x%p\n", (void *) amos_page);
+				"is bad = 0x%p\n", (void *)amos_page);
 			return NULL;
 		}
-		amos_page = (AMO_t *) TO_AMO((u64) amos_page);
+		amos_page = (AMO_t *)TO_AMO((u64)amos_page);
 	}
 
 	/* clear xpc_vars */
@@ -267,22 +256,21 @@ xpc_rsvd_page_init(void)
 	xpc_vars->act_nasid = cpuid_to_nasid(0);
 	xpc_vars->act_phys_cpuid = cpu_physical_id(0);
 	xpc_vars->vars_part_pa = __pa(xpc_vars_part);
-	xpc_vars->amos_page_pa = ia64_tpa((u64) amos_page);
-	xpc_vars->amos_page = amos_page;  /* save for next load of XPC */
-
+	xpc_vars->amos_page_pa = ia64_tpa((u64)amos_page);
+	xpc_vars->amos_page = amos_page;	/* save for next load of XPC */
 
 	/* clear xpc_vars_part */
-	memset((u64 *) xpc_vars_part, 0, sizeof(struct xpc_vars_part) *
-							XP_MAX_PARTITIONS);
+	memset((u64 *)xpc_vars_part, 0, sizeof(struct xpc_vars_part) *
+	       XP_MAX_PARTITIONS);
 
 	/* initialize the activate IRQ related AMO variables */
 	for (i = 0; i < xp_nasid_mask_words; i++) {
-		(void) xpc_IPI_init(XPC_ACTIVATE_IRQ_AMOS + i);
+		(void)xpc_IPI_init(XPC_ACTIVATE_IRQ_AMOS + i);
 	}
 
 	/* initialize the engaged remote partitions related AMO variables */
-	(void) xpc_IPI_init(XPC_ENGAGED_PARTITIONS_AMO);
-	(void) xpc_IPI_init(XPC_DISENGAGE_REQUEST_AMO);
+	(void)xpc_IPI_init(XPC_ENGAGED_PARTITIONS_AMO);
+	(void)xpc_IPI_init(XPC_DISENGAGE_REQUEST_AMO);
 
 	/* timestamp of when reserved page was setup by XPC */
 	rp->stamp = CURRENT_TIME;
@@ -296,7 +284,6 @@ xpc_rsvd_page_init(void)
 	return rp;
 }
 
-
 /*
  * Change protections to allow IPI operations (and AMO operations on
  * Shub 1.1 systems).
@@ -307,39 +294,38 @@ xpc_allow_IPI_ops(void)
 	int node;
 	int nasid;
 
-
 	// >>> Change SH_IPI_ACCESS code to use SAL call once it is available.
 
 	if (is_shub2()) {
 		xpc_sh2_IPI_access0 -			(u64) HUB_L((u64 *) LOCAL_MMR_ADDR(SH2_IPI_ACCESS0));
+		    (u64)HUB_L((u64 *)LOCAL_MMR_ADDR(SH2_IPI_ACCESS0));
 		xpc_sh2_IPI_access1 -			(u64) HUB_L((u64 *) LOCAL_MMR_ADDR(SH2_IPI_ACCESS1));
+		    (u64)HUB_L((u64 *)LOCAL_MMR_ADDR(SH2_IPI_ACCESS1));
 		xpc_sh2_IPI_access2 -			(u64) HUB_L((u64 *) LOCAL_MMR_ADDR(SH2_IPI_ACCESS2));
+		    (u64)HUB_L((u64 *)LOCAL_MMR_ADDR(SH2_IPI_ACCESS2));
 		xpc_sh2_IPI_access3 -			(u64) HUB_L((u64 *) LOCAL_MMR_ADDR(SH2_IPI_ACCESS3));
+		    (u64)HUB_L((u64 *)LOCAL_MMR_ADDR(SH2_IPI_ACCESS3));
 
 		for_each_online_node(node) {
 			nasid = cnodeid_to_nasid(node);
-			HUB_S((u64 *) GLOBAL_MMR_ADDR(nasid, SH2_IPI_ACCESS0),
-								-1UL);
-			HUB_S((u64 *) GLOBAL_MMR_ADDR(nasid, SH2_IPI_ACCESS1),
-								-1UL);
-			HUB_S((u64 *) GLOBAL_MMR_ADDR(nasid, SH2_IPI_ACCESS2),
-								-1UL);
-			HUB_S((u64 *) GLOBAL_MMR_ADDR(nasid, SH2_IPI_ACCESS3),
-								-1UL);
+			HUB_S((u64 *)GLOBAL_MMR_ADDR(nasid, SH2_IPI_ACCESS0),
+			      -1UL);
+			HUB_S((u64 *)GLOBAL_MMR_ADDR(nasid, SH2_IPI_ACCESS1),
+			      -1UL);
+			HUB_S((u64 *)GLOBAL_MMR_ADDR(nasid, SH2_IPI_ACCESS2),
+			      -1UL);
+			HUB_S((u64 *)GLOBAL_MMR_ADDR(nasid, SH2_IPI_ACCESS3),
+			      -1UL);
 		}
 
 	} else {
 		xpc_sh1_IPI_access -			(u64) HUB_L((u64 *) LOCAL_MMR_ADDR(SH1_IPI_ACCESS));
+		    (u64)HUB_L((u64 *)LOCAL_MMR_ADDR(SH1_IPI_ACCESS));
 
 		for_each_online_node(node) {
 			nasid = cnodeid_to_nasid(node);
-			HUB_S((u64 *) GLOBAL_MMR_ADDR(nasid, SH1_IPI_ACCESS),
-								-1UL);
+			HUB_S((u64 *)GLOBAL_MMR_ADDR(nasid, SH1_IPI_ACCESS),
+			      -1UL);
 
 			/*
 			 * Since the BIST collides with memory operations on
@@ -347,21 +333,23 @@ xpc_allow_IPI_ops(void)
 			 */
 			if (enable_shub_wars_1_1()) {
 				/* open up everything */
-				xpc_prot_vec[node] = (u64) HUB_L((u64 *)
-						GLOBAL_MMR_ADDR(nasid,
-						SH1_MD_DQLP_MMR_DIR_PRIVEC0));
-				HUB_S((u64 *) GLOBAL_MMR_ADDR(nasid,
-						SH1_MD_DQLP_MMR_DIR_PRIVEC0),
-								-1UL);
-				HUB_S((u64 *) GLOBAL_MMR_ADDR(nasid,
-						SH1_MD_DQRP_MMR_DIR_PRIVEC0),
-								-1UL);
+				xpc_prot_vec[node] = (u64)HUB_L((u64 *)
+								GLOBAL_MMR_ADDR
+								(nasid,
+								 SH1_MD_DQLP_MMR_DIR_PRIVEC0));
+				HUB_S((u64 *)
+				      GLOBAL_MMR_ADDR(nasid,
+						      SH1_MD_DQLP_MMR_DIR_PRIVEC0),
+				      -1UL);
+				HUB_S((u64 *)
+				      GLOBAL_MMR_ADDR(nasid,
+						      SH1_MD_DQRP_MMR_DIR_PRIVEC0),
+				      -1UL);
 			}
 		}
 	}
 }
 
-
 /*
  * Restrict protections to disallow IPI operations (and AMO operations on
  * Shub 1.1 systems).
@@ -372,43 +360,41 @@ xpc_restrict_IPI_ops(void)
 	int node;
 	int nasid;
 
-
 	// >>> Change SH_IPI_ACCESS code to use SAL call once it is available.
 
 	if (is_shub2()) {
 
 		for_each_online_node(node) {
 			nasid = cnodeid_to_nasid(node);
-			HUB_S((u64 *) GLOBAL_MMR_ADDR(nasid, SH2_IPI_ACCESS0),
-							xpc_sh2_IPI_access0);
-			HUB_S((u64 *) GLOBAL_MMR_ADDR(nasid, SH2_IPI_ACCESS1),
-							xpc_sh2_IPI_access1);
-			HUB_S((u64 *) GLOBAL_MMR_ADDR(nasid, SH2_IPI_ACCESS2),
-							xpc_sh2_IPI_access2);
-			HUB_S((u64 *) GLOBAL_MMR_ADDR(nasid, SH2_IPI_ACCESS3),
-							xpc_sh2_IPI_access3);
+			HUB_S((u64 *)GLOBAL_MMR_ADDR(nasid, SH2_IPI_ACCESS0),
+			      xpc_sh2_IPI_access0);
+			HUB_S((u64 *)GLOBAL_MMR_ADDR(nasid, SH2_IPI_ACCESS1),
+			      xpc_sh2_IPI_access1);
+			HUB_S((u64 *)GLOBAL_MMR_ADDR(nasid, SH2_IPI_ACCESS2),
+			      xpc_sh2_IPI_access2);
+			HUB_S((u64 *)GLOBAL_MMR_ADDR(nasid, SH2_IPI_ACCESS3),
+			      xpc_sh2_IPI_access3);
 		}
 
 	} else {
 
 		for_each_online_node(node) {
 			nasid = cnodeid_to_nasid(node);
-			HUB_S((u64 *) GLOBAL_MMR_ADDR(nasid, SH1_IPI_ACCESS),
-							xpc_sh1_IPI_access);
+			HUB_S((u64 *)GLOBAL_MMR_ADDR(nasid, SH1_IPI_ACCESS),
+			      xpc_sh1_IPI_access);
 
 			if (enable_shub_wars_1_1()) {
-				HUB_S((u64 *) GLOBAL_MMR_ADDR(nasid,
-						SH1_MD_DQLP_MMR_DIR_PRIVEC0),
-							xpc_prot_vec[node]);
-				HUB_S((u64 *) GLOBAL_MMR_ADDR(nasid,
-						SH1_MD_DQRP_MMR_DIR_PRIVEC0),
-							xpc_prot_vec[node]);
+				HUB_S((u64 *)GLOBAL_MMR_ADDR(nasid,
+							     SH1_MD_DQLP_MMR_DIR_PRIVEC0),
+				      xpc_prot_vec[node]);
+				HUB_S((u64 *)GLOBAL_MMR_ADDR(nasid,
+							     SH1_MD_DQRP_MMR_DIR_PRIVEC0),
+				      xpc_prot_vec[node]);
 			}
 		}
 	}
 }
 
-
 /*
  * At periodic intervals, scan through all active partitions and ensure
  * their heartbeat is still active.  If not, the partition is deactivated.
@@ -421,8 +407,7 @@ xpc_check_remote_hb(void)
 	partid_t partid;
 	bte_result_t bres;
 
-
-	remote_vars = (struct xpc_vars *) xpc_remote_copy_buffer;
+	remote_vars = (struct xpc_vars *)xpc_remote_copy_buffer;
 
 	for (partid = 1; partid < XP_MAX_PARTITIONS; partid++) {
 
@@ -437,18 +422,18 @@ xpc_check_remote_hb(void)
 		part = &xpc_partitions[partid];
 
 		if (part->act_state = XPC_P_INACTIVE ||
-				part->act_state = XPC_P_DEACTIVATING) {
+		    part->act_state = XPC_P_DEACTIVATING) {
 			continue;
 		}
 
 		/* pull the remote_hb cache line */
 		bres = xp_bte_copy(part->remote_vars_pa,
-					(u64) remote_vars,
-					XPC_RP_VARS_SIZE,
-					(BTE_NOTIFY | BTE_WACQUIRE), NULL);
+				   (u64)remote_vars,
+				   XPC_RP_VARS_SIZE,
+				   (BTE_NOTIFY | BTE_WACQUIRE), NULL);
 		if (bres != BTE_SUCCESS) {
 			XPC_DEACTIVATE_PARTITION(part,
-						xpc_map_bte_errors(bres));
+						 xpc_map_bte_errors(bres));
 			continue;
 		}
 
@@ -459,8 +444,8 @@ xpc_check_remote_hb(void)
 			remote_vars->heartbeating_to_mask);
 
 		if (((remote_vars->heartbeat = part->last_heartbeat) &&
-			(remote_vars->heartbeat_offline = 0)) ||
-			     !xpc_hb_allowed(sn_partition_id, remote_vars)) {
+		     (remote_vars->heartbeat_offline = 0)) ||
+		    !xpc_hb_allowed(sn_partition_id, remote_vars)) {
 
 			XPC_DEACTIVATE_PARTITION(part, xpcNoHeartbeat);
 			continue;
@@ -470,7 +455,6 @@ xpc_check_remote_hb(void)
 	}
 }
 
-
 /*
  * Get a copy of a portion of the remote partition's rsvd page.
  *
@@ -480,11 +464,10 @@ xpc_check_remote_hb(void)
  */
 static enum xpc_retval
 xpc_get_remote_rp(int nasid, u64 *discovered_nasids,
-		struct xpc_rsvd_page *remote_rp, u64 *remote_rp_pa)
+		  struct xpc_rsvd_page *remote_rp, u64 *remote_rp_pa)
 {
 	int bres, i;
 
-
 	/* get the reserved page's physical address */
 
 	*remote_rp_pa = xpc_get_rsvd_page_pa(nasid);
@@ -492,30 +475,26 @@ xpc_get_remote_rp(int nasid, u64 *discov
 		return xpcNoRsvdPageAddr;
 	}
 
-
 	/* pull over the reserved page header and part_nasids mask */
-	bres = xp_bte_copy(*remote_rp_pa, (u64) remote_rp,
-				XPC_RP_HEADER_SIZE + xp_nasid_mask_bytes,
-				(BTE_NOTIFY | BTE_WACQUIRE), NULL);
+	bres = xp_bte_copy(*remote_rp_pa, (u64)remote_rp,
+			   XPC_RP_HEADER_SIZE + xp_nasid_mask_bytes,
+			   (BTE_NOTIFY | BTE_WACQUIRE), NULL);
 	if (bres != BTE_SUCCESS) {
 		return xpc_map_bte_errors(bres);
 	}
 
-
 	if (discovered_nasids != NULL) {
 		u64 *remote_part_nasids = XPC_RP_PART_NASIDS(remote_rp);
 
-
 		for (i = 0; i < xp_nasid_mask_words; i++) {
 			discovered_nasids[i] |= remote_part_nasids[i];
 		}
 	}
 
-
 	/* check that the partid is for another partition */
 
 	if (remote_rp->partid < 1 ||
-				remote_rp->partid > (XP_MAX_PARTITIONS - 1)) {
+	    remote_rp->partid > (XP_MAX_PARTITIONS - 1)) {
 		return xpcInvalidPartid;
 	}
 
@@ -523,16 +502,14 @@ xpc_get_remote_rp(int nasid, u64 *discov
 		return xpcLocalPartid;
 	}
 
-
 	if (XPC_VERSION_MAJOR(remote_rp->version) !-					XPC_VERSION_MAJOR(XPC_RP_VERSION)) {
+	    XPC_VERSION_MAJOR(XPC_RP_VERSION)) {
 		return xpcBadVersion;
 	}
 
 	return xpcSuccess;
 }
 
-
 /*
  * Get a copy of the remote partition's XPC variables from the reserved page.
  *
@@ -544,34 +521,32 @@ xpc_get_remote_vars(u64 remote_vars_pa, 
 {
 	int bres;
 
-
 	if (remote_vars_pa = 0) {
 		return xpcVarsNotSet;
 	}
 
 	/* pull over the cross partition variables */
-	bres = xp_bte_copy(remote_vars_pa, (u64) remote_vars, XPC_RP_VARS_SIZE,
-				(BTE_NOTIFY | BTE_WACQUIRE), NULL);
+	bres = xp_bte_copy(remote_vars_pa, (u64)remote_vars, XPC_RP_VARS_SIZE,
+			   (BTE_NOTIFY | BTE_WACQUIRE), NULL);
 	if (bres != BTE_SUCCESS) {
 		return xpc_map_bte_errors(bres);
 	}
 
 	if (XPC_VERSION_MAJOR(remote_vars->version) !-					XPC_VERSION_MAJOR(XPC_V_VERSION)) {
+	    XPC_VERSION_MAJOR(XPC_V_VERSION)) {
 		return xpcBadVersion;
 	}
 
 	return xpcSuccess;
 }
 
-
 /*
  * Update the remote partition's info.
  */
 static void
 xpc_update_partition_info(struct xpc_partition *part, u8 remote_rp_version,
-		struct timespec *remote_rp_stamp, u64 remote_rp_pa,
-		u64 remote_vars_pa, struct xpc_vars *remote_vars)
+			  struct timespec *remote_rp_stamp, u64 remote_rp_pa,
+			  u64 remote_vars_pa, struct xpc_vars *remote_vars)
 {
 	part->remote_rp_version = remote_rp_version;
 	dev_dbg(xpc_part, "  remote_rp_version = 0x%016x\n",
@@ -613,7 +588,6 @@ xpc_update_partition_info(struct xpc_par
 		part->remote_vars_version);
 }
 
-
 /*
  * Prior code has determined the nasid which generated an IPI.  Inspect
  * that nasid to determine if its partition needs to be activated or
@@ -643,15 +617,14 @@ xpc_identify_act_IRQ_req(int nasid)
 	struct xpc_partition *part;
 	enum xpc_retval ret;
 
-
 	/* pull over the reserved page structure */
 
-	remote_rp = (struct xpc_rsvd_page *) xpc_remote_copy_buffer;
+	remote_rp = (struct xpc_rsvd_page *)xpc_remote_copy_buffer;
 
 	ret = xpc_get_remote_rp(nasid, NULL, remote_rp, &remote_rp_pa);
 	if (ret != xpcSuccess) {
 		dev_warn(xpc_part, "unable to get reserved page from nasid %d, "
-			"which sent interrupt, reason=%d\n", nasid, ret);
+			 "which sent interrupt, reason=%d\n", nasid, ret);
 		return;
 	}
 
@@ -663,34 +636,31 @@ xpc_identify_act_IRQ_req(int nasid)
 	partid = remote_rp->partid;
 	part = &xpc_partitions[partid];
 
-
 	/* pull over the cross partition variables */
 
-	remote_vars = (struct xpc_vars *) xpc_remote_copy_buffer;
+	remote_vars = (struct xpc_vars *)xpc_remote_copy_buffer;
 
 	ret = xpc_get_remote_vars(remote_vars_pa, remote_vars);
 	if (ret != xpcSuccess) {
 
 		dev_warn(xpc_part, "unable to get XPC variables from nasid %d, "
-			"which sent interrupt, reason=%d\n", nasid, ret);
+			 "which sent interrupt, reason=%d\n", nasid, ret);
 
 		XPC_DEACTIVATE_PARTITION(part, ret);
 		return;
 	}
 
-
 	part->act_IRQ_rcvd++;
 
 	dev_dbg(xpc_part, "partid for nasid %d is %d; IRQs = %d; HB = "
-		"%ld:0x%lx\n", (int) nasid, (int) partid, part->act_IRQ_rcvd,
+		"%ld:0x%lx\n", (int)nasid, (int)partid, part->act_IRQ_rcvd,
 		remote_vars->heartbeat, remote_vars->heartbeating_to_mask);
 
-	if (xpc_partition_disengaged(part) &&
-					part->act_state = XPC_P_INACTIVE) {
+	if (xpc_partition_disengaged(part) && part->act_state = XPC_P_INACTIVE) {
 
 		xpc_update_partition_info(part, remote_rp_version,
-					&remote_rp_stamp, remote_rp_pa,
-					remote_vars_pa, remote_vars);
+					  &remote_rp_stamp, remote_rp_pa,
+					  remote_vars_pa, remote_vars);
 
 		if (XPC_SUPPORTS_DISENGAGE_REQUEST(part->remote_vars_version)) {
 			if (xpc_partition_disengage_requested(1UL << partid)) {
@@ -714,16 +684,15 @@ xpc_identify_act_IRQ_req(int nasid)
 
 	if (!XPC_SUPPORTS_RP_STAMP(part->remote_rp_version)) {
 		DBUG_ON(XPC_SUPPORTS_DISENGAGE_REQUEST(part->
-							remote_vars_version));
+						       remote_vars_version));
 
 		if (!XPC_SUPPORTS_RP_STAMP(remote_rp_version)) {
 			DBUG_ON(XPC_SUPPORTS_DISENGAGE_REQUEST(remote_vars->
-								version));
+							       version));
 			/* see if the other side rebooted */
 			if (part->remote_amos_page_pa =
-				remote_vars->amos_page_pa &&
-					xpc_hb_allowed(sn_partition_id,
-								remote_vars)) {
+			    remote_vars->amos_page_pa &&
+			    xpc_hb_allowed(sn_partition_id, remote_vars)) {
 				/* doesn't look that way, so ignore the IPI */
 				return;
 			}
@@ -735,8 +704,8 @@ xpc_identify_act_IRQ_req(int nasid)
 		 */
 
 		xpc_update_partition_info(part, remote_rp_version,
-						&remote_rp_stamp, remote_rp_pa,
-						remote_vars_pa, remote_vars);
+					  &remote_rp_stamp, remote_rp_pa,
+					  remote_vars_pa, remote_vars);
 		part->reactivate_nasid = nasid;
 		XPC_DEACTIVATE_PARTITION(part, xpcReactivating);
 		return;
@@ -756,15 +725,15 @@ xpc_identify_act_IRQ_req(int nasid)
 		xpc_clear_partition_disengage_request(1UL << partid);
 
 		xpc_update_partition_info(part, remote_rp_version,
-						&remote_rp_stamp, remote_rp_pa,
-						remote_vars_pa, remote_vars);
+					  &remote_rp_stamp, remote_rp_pa,
+					  remote_vars_pa, remote_vars);
 		reactivate = 1;
 
 	} else {
 		DBUG_ON(!XPC_SUPPORTS_DISENGAGE_REQUEST(remote_vars->version));
 
 		stamp_diff = xpc_compare_stamps(&part->remote_rp_stamp,
-							&remote_rp_stamp);
+						&remote_rp_stamp);
 		if (stamp_diff != 0) {
 			DBUG_ON(stamp_diff >= 0);
 
@@ -775,17 +744,18 @@ xpc_identify_act_IRQ_req(int nasid)
 
 			DBUG_ON(xpc_partition_engaged(1UL << partid));
 			DBUG_ON(xpc_partition_disengage_requested(1UL <<
-								partid));
+								  partid));
 
 			xpc_update_partition_info(part, remote_rp_version,
-						&remote_rp_stamp, remote_rp_pa,
-						remote_vars_pa, remote_vars);
+						  &remote_rp_stamp,
+						  remote_rp_pa, remote_vars_pa,
+						  remote_vars);
 			reactivate = 1;
 		}
 	}
 
 	if (part->disengage_request_timeout > 0 &&
-					!xpc_partition_disengaged(part)) {
+	    !xpc_partition_disengaged(part)) {
 		/* still waiting on other side to disengage from us */
 		return;
 	}
@@ -795,12 +765,11 @@ xpc_identify_act_IRQ_req(int nasid)
 		XPC_DEACTIVATE_PARTITION(part, xpcReactivating);
 
 	} else if (XPC_SUPPORTS_DISENGAGE_REQUEST(part->remote_vars_version) &&
-			xpc_partition_disengage_requested(1UL << partid)) {
+		   xpc_partition_disengage_requested(1UL << partid)) {
 		XPC_DEACTIVATE_PARTITION(part, xpcOtherGoingDown);
 	}
 }
 
-
 /*
  * Loop through the activation AMO variables and process any bits
  * which are set.  Each bit indicates a nasid sending a partition
@@ -813,14 +782,12 @@ xpc_identify_act_IRQ_sender(void)
 {
 	int word, bit;
 	u64 nasid_mask;
-	u64 nasid;			/* remote nasid */
+	u64 nasid;		/* remote nasid */
 	int n_IRQs_detected = 0;
 	AMO_t *act_amos;
 
-
 	act_amos = xpc_vars->amos_page + XPC_ACTIVATE_IRQ_AMOS;
 
-
 	/* scan through act AMO variable looking for non-zero entries */
 	for (word = 0; word < xp_nasid_mask_words; word++) {
 
@@ -837,7 +804,6 @@ xpc_identify_act_IRQ_sender(void)
 		dev_dbg(xpc_part, "AMO[%d] gave back 0x%lx\n", word,
 			nasid_mask);
 
-
 		/*
 		 * If this nasid has been added to the machine since
 		 * our partition was reset, this will retain the
@@ -846,7 +812,6 @@ xpc_identify_act_IRQ_sender(void)
 		 */
 		xpc_mach_nasids[word] |= nasid_mask;
 
-
 		/* locate the nasid(s) which sent interrupts */
 
 		for (bit = 0; bit < (8 * sizeof(u64)); bit++) {
@@ -862,7 +827,6 @@ xpc_identify_act_IRQ_sender(void)
 	return n_IRQs_detected;
 }
 
-
 /*
  * See if the other side has responded to a partition disengage request
  * from us.
@@ -873,7 +837,6 @@ xpc_partition_disengaged(struct xpc_part
 	partid_t partid = XPC_PARTID(part);
 	int disengaged;
 
-
 	disengaged = (xpc_partition_engaged(1UL << partid) = 0);
 	if (part->disengage_request_timeout) {
 		if (!disengaged) {
@@ -888,7 +851,7 @@ xpc_partition_disengaged(struct xpc_part
 			 */
 
 			dev_info(xpc_part, "disengage from remote partition %d "
-				"timed out\n", partid);
+				 "timed out\n", partid);
 			xpc_disengage_request_timedout = 1;
 			xpc_clear_partition_engaged(1UL << partid);
 			disengaged = 1;
@@ -898,11 +861,11 @@ xpc_partition_disengaged(struct xpc_part
 		/* cancel the timer function, provided it's not us */
 		if (!in_interrupt()) {
 			del_singleshot_timer_sync(&part->
-						      disengage_request_timer);
+						  disengage_request_timer);
 		}
 
 		DBUG_ON(part->act_state != XPC_P_DEACTIVATING &&
-					part->act_state != XPC_P_INACTIVE);
+			part->act_state != XPC_P_INACTIVE);
 		if (part->act_state != XPC_P_INACTIVE) {
 			xpc_wakeup_channel_mgr(part);
 		}
@@ -914,7 +877,6 @@ xpc_partition_disengaged(struct xpc_part
 	return disengaged;
 }
 
-
 /*
  * Mark specified partition as active.
  */
@@ -924,7 +886,6 @@ xpc_mark_partition_active(struct xpc_par
 	unsigned long irq_flags;
 	enum xpc_retval ret;
 
-
 	dev_dbg(xpc_part, "setting partition %d to ACTIVE\n", XPC_PARTID(part));
 
 	spin_lock_irqsave(&part->act_lock, irq_flags);
@@ -940,17 +901,15 @@ xpc_mark_partition_active(struct xpc_par
 	return ret;
 }
 
-
 /*
  * Notify XPC that the partition is down.
  */
 void
 xpc_deactivate_partition(const int line, struct xpc_partition *part,
-				enum xpc_retval reason)
+			 enum xpc_retval reason)
 {
 	unsigned long irq_flags;
 
-
 	spin_lock_irqsave(&part->act_lock, irq_flags);
 
 	if (part->act_state = XPC_P_INACTIVE) {
@@ -964,7 +923,7 @@ xpc_deactivate_partition(const int line,
 	}
 	if (part->act_state = XPC_P_DEACTIVATING) {
 		if ((part->reason = xpcUnloading && reason != xpcUnloading) ||
-					reason = xpcReactivating) {
+		    reason = xpcReactivating) {
 			XPC_SET_REASON(part, reason, line);
 		}
 		spin_unlock_irqrestore(&part->act_lock, irq_flags);
@@ -982,9 +941,9 @@ xpc_deactivate_partition(const int line,
 
 		/* set a timelimit on the disengage request */
 		part->disengage_request_timeout = jiffies +
-					(xpc_disengage_request_timelimit * HZ);
+		    (xpc_disengage_request_timelimit * HZ);
 		part->disengage_request_timer.expires -					part->disengage_request_timeout;
+		    part->disengage_request_timeout;
 		add_timer(&part->disengage_request_timer);
 	}
 
@@ -994,7 +953,6 @@ xpc_deactivate_partition(const int line,
 	xpc_partition_going_down(part, reason);
 }
 
-
 /*
  * Mark specified partition as inactive.
  */
@@ -1003,7 +961,6 @@ xpc_mark_partition_inactive(struct xpc_p
 {
 	unsigned long irq_flags;
 
-
 	dev_dbg(xpc_part, "setting partition %d to INACTIVE\n",
 		XPC_PARTID(part));
 
@@ -1013,7 +970,6 @@ xpc_mark_partition_inactive(struct xpc_p
 	part->remote_rp_pa = 0;
 }
 
-
 /*
  * SAL has provided a partition and machine mask.  The partition mask
  * contains a bit for each even nasid in our partition.  The machine
@@ -1041,24 +997,22 @@ xpc_discovery(void)
 	u64 *discovered_nasids;
 	enum xpc_retval ret;
 
-
 	remote_rp = xpc_kmalloc_cacheline_aligned(XPC_RP_HEADER_SIZE +
-						xp_nasid_mask_bytes,
-						GFP_KERNEL, &remote_rp_base);
+						  xp_nasid_mask_bytes,
+						  GFP_KERNEL, &remote_rp_base);
 	if (remote_rp = NULL) {
 		return;
 	}
-	remote_vars = (struct xpc_vars *) remote_rp;
-
+	remote_vars = (struct xpc_vars *)remote_rp;
 
 	discovered_nasids = kzalloc(sizeof(u64) * xp_nasid_mask_words,
-							GFP_KERNEL);
+				    GFP_KERNEL);
 	if (discovered_nasids = NULL) {
 		kfree(remote_rp_base);
 		return;
 	}
 
-	rp = (struct xpc_rsvd_page *) xpc_rsvd_page;
+	rp = (struct xpc_rsvd_page *)xpc_rsvd_page;
 
 	/*
 	 * The term 'region' in this context refers to the minimum number of
@@ -1081,23 +1035,21 @@ xpc_discovery(void)
 
 	for (region = 0; region < max_regions; region++) {
 
-		if ((volatile int) xpc_exiting) {
+		if ((volatile int)xpc_exiting) {
 			break;
 		}
 
 		dev_dbg(xpc_part, "searching region %d\n", region);
 
 		for (nasid = (region * region_size * 2);
-		     nasid < ((region + 1) * region_size * 2);
-		     nasid += 2) {
+		     nasid < ((region + 1) * region_size * 2); nasid += 2) {
 
-			if ((volatile int) xpc_exiting) {
+			if ((volatile int)xpc_exiting) {
 				break;
 			}
 
 			dev_dbg(xpc_part, "checking nasid %d\n", nasid);
 
-
 			if (XPC_NASID_IN_ARRAY(nasid, xpc_part_nasids)) {
 				dev_dbg(xpc_part, "PROM indicates Nasid %d is "
 					"part of the local partition; skipping "
@@ -1119,11 +1071,10 @@ xpc_discovery(void)
 				continue;
 			}
 
-
 			/* pull over the reserved page structure */
 
 			ret = xpc_get_remote_rp(nasid, discovered_nasids,
-					      remote_rp, &remote_rp_pa);
+						remote_rp, &remote_rp_pa);
 			if (ret != xpcSuccess) {
 				dev_dbg(xpc_part, "unable to get reserved page "
 					"from nasid %d, reason=%d\n", nasid,
@@ -1140,7 +1091,6 @@ xpc_discovery(void)
 			partid = remote_rp->partid;
 			part = &xpc_partitions[partid];
 
-
 			/* pull over the cross partition variables */
 
 			ret = xpc_get_remote_vars(remote_vars_pa, remote_vars);
@@ -1171,15 +1121,15 @@ xpc_discovery(void)
 			 * get the same page for remote_act_amos_pa after
 			 * module reloads and system reboots.
 			 */
-			if (sn_register_xp_addr_region(
-					    remote_vars->amos_page_pa,
-							PAGE_SIZE, 1) < 0) {
-				dev_dbg(xpc_part, "partition %d failed to "
+			if (sn_register_xp_addr_region
+			    (remote_vars->amos_page_pa, PAGE_SIZE, 1) < 0) {
+				dev_dbg(xpc_part,
+					"partition %d failed to "
 					"register xp_addr region 0x%016lx\n",
 					partid, remote_vars->amos_page_pa);
 
 				XPC_SET_REASON(part, xpcPhysAddrRegFailed,
-						__LINE__);
+					       __LINE__);
 				break;
 			}
 
@@ -1195,9 +1145,9 @@ xpc_discovery(void)
 				remote_vars->act_phys_cpuid);
 
 			if (XPC_SUPPORTS_DISENGAGE_REQUEST(remote_vars->
-								version)) {
+							   version)) {
 				part->remote_amos_page_pa -						remote_vars->amos_page_pa;
+				    remote_vars->amos_page_pa;
 				xpc_mark_partition_disengaged(part);
 				xpc_cancel_partition_disengage_request(part);
 			}
@@ -1209,7 +1159,6 @@ xpc_discovery(void)
 	kfree(remote_rp_base);
 }
 
-
 /*
  * Given a partid, get the nasids owned by that partition from the
  * remote partition's reserved page.
@@ -1221,7 +1170,6 @@ xpc_initiate_partid_to_nasids(partid_t p
 	u64 part_nasid_pa;
 	int bte_res;
 
-
 	part = &xpc_partitions[partid];
 	if (part->remote_rp_pa = 0) {
 		return xpcPartitionDown;
@@ -1229,11 +1177,11 @@ xpc_initiate_partid_to_nasids(partid_t p
 
 	memset(nasid_mask, 0, XP_NASID_MASK_BYTES);
 
-	part_nasid_pa = (u64) XPC_RP_PART_NASIDS(part->remote_rp_pa);
+	part_nasid_pa = (u64)XPC_RP_PART_NASIDS(part->remote_rp_pa);
 
-	bte_res = xp_bte_copy(part_nasid_pa, (u64) nasid_mask,
-			xp_nasid_mask_bytes, (BTE_NOTIFY | BTE_WACQUIRE), NULL);
+	bte_res = xp_bte_copy(part_nasid_pa, (u64)nasid_mask,
+			      xp_nasid_mask_bytes, (BTE_NOTIFY | BTE_WACQUIRE),
+			      NULL);
 
 	return xpc_map_bte_errors(bte_res);
 }
-
