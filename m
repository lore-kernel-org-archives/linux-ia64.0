From: dcn@sgi.com (Dean Nelson)
Date: Wed, 07 Nov 2007 13:53:06 +0000
Subject: [PATCH] XPC heartbeat timer function must run on CPU 0
Message-Id: <20071107135306.99AAF11C415@aqua.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Currently, XPC's heartbeat timer function runs on whatever CPU modprobe/insmod
ran on when XPC was started. To avoid the heartbeat from being delayed for
long periods the timer function must run on CPU 0.

Signed-off-by: Dean Nelson <dcn@sgi.com>


Index: linux-2.6/arch/ia64/sn/kernel/xpc_main.c
=================================--- linux-2.6.orig/arch/ia64/sn/kernel/xpc_main.c	2007-11-05 13:39:09.024152387 -0600
+++ linux-2.6/arch/ia64/sn/kernel/xpc_main.c	2007-11-05 13:44:28.815893952 -0600
@@ -3,7 +3,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (c) 2004-2006 Silicon Graphics, Inc.  All Rights Reserved.
+ * Copyright (c) 2004-2007 Silicon Graphics, Inc.  All Rights Reserved.
  */
 
 
@@ -257,7 +257,9 @@
 
 	set_cpus_allowed(current, cpumask_of_cpu(XPC_HB_CHECK_CPU));
 
+	/* set our heartbeating to other partitions into motion */
 	xpc_hb_check_timeout = jiffies + (xpc_hb_check_interval * HZ);
+	xpc_hb_beater(0);
 
 	while (!(volatile int) xpc_exiting) {
 
@@ -1338,16 +1340,8 @@
 		dev_warn(xpc_part, "can't register die notifier\n");
 	}
 
-
-	/*
-	 * Set the beating to other partitions into motion.  This is
-	 * the last requirement for other partitions' discovery to
-	 * initiate communications with us.
-	 */
 	init_timer(&xpc_hb_timer);
 	xpc_hb_timer.function = xpc_hb_beater;
-	xpc_hb_beater(0);
-
 
 	/*
 	 * The real work-horse behind xpc.  This processes incoming
