From: Dean Nelson <dcn@sgi.com>
Date: Thu, 05 Jan 2006 18:43:56 +0000
Subject: Re: [PATCH] cleanup XPC disengage related messages (v2)
Message-Id: <20060105184356.GA11465@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <43AC2281.mailxDCB118CPI@aqua.americas.sgi.com>
In-Reply-To: <43AC2281.mailxDCB118CPI@aqua.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony,

   Please ignore the previous version of this patch, use this one instead.

Thanks,
Dean



Cleanup the XPC disengage related messages that are printed to the log.

Signed-off-by: Dean Nelson <dcn@sgi.com>


Index: linux-2.6.git-test/arch/ia64/sn/kernel/xpc_main.c
=================================--- linux-2.6.git-test.orig/arch/ia64/sn/kernel/xpc_main.c	2005-12-23 07:37:53.313511106 -0600
+++ linux-2.6.git-test/arch/ia64/sn/kernel/xpc_main.c	2006-01-05 09:50:23.885862251 -0600
@@ -162,6 +162,8 @@
 };
 static struct ctl_table_header *xpc_sysctl;
 
+/* non-zero if any remote partition disengage request was timed out */
+int xpc_disengage_request_timedout;
 
 /* #of IRQs received */
 static atomic_t xpc_act_IRQ_rcvd;
@@ -921,9 +923,9 @@
 xpc_do_exit(enum xpc_retval reason)
 {
 	partid_t partid;
-	int active_part_count;
+	int active_part_count, printed_waiting_msg = 0;
 	struct xpc_partition *part;
-	unsigned long printmsg_time;
+	unsigned long printmsg_time, disengage_request_timeout = 0;
 
 
 	/* a 'rmmod XPC' and a 'reboot' cannot both end up here together */
@@ -953,7 +955,8 @@
 
 	/* wait for all partitions to become inactive */
 
-	printmsg_time = jiffies;
+	printmsg_time = jiffies + (XPC_DISENGAGE_PRINTMSG_INTERVAL * HZ);
+	xpc_disengage_request_timedout = 0;
 
 	do {
 		active_part_count = 0;
@@ -969,20 +972,39 @@
 			active_part_count++;
 
 			XPC_DEACTIVATE_PARTITION(part, reason);
-		}
 
-		if (active_part_count = 0) {
-			break;
+			if (part->disengage_request_timeout >
+						disengage_request_timeout) {
+				disengage_request_timeout +						part->disengage_request_timeout;
+			}
 		}
 
-		if (jiffies >= printmsg_time) {
-			dev_info(xpc_part, "waiting for partitions to "
-				"deactivate/disengage, active count=%d, remote "
-				"engaged=0x%lx\n", active_part_count,
-				xpc_partition_engaged(1UL << partid));
-
-			printmsg_time = jiffies +
+		if (xpc_partition_engaged(-1UL)) {
+			if (jiffies >= printmsg_time) {
+				dev_info(xpc_part, "waiting for remote "
+					"partitions to disengage, timeout in "
+					"%ld seconds\n",
+					(disengage_request_timeout - jiffies)
+									/ HZ);
+				printmsg_time = jiffies +
 					(XPC_DISENGAGE_PRINTMSG_INTERVAL * HZ);
+				printed_waiting_msg = 1;
+			}
+
+		} else if (active_part_count > 0) {
+			if (printed_waiting_msg) {
+				dev_info(xpc_part, "waiting for local partition"
+					" to disengage\n");
+				printed_waiting_msg = 0;
+			}
+
+		} else {
+			if (!(volatile int) xpc_disengage_request_timedout) {
+				dev_info(xpc_part, "all partitions have "
+					"disengaged\n");
+			}
+			break;
 		}
 
 		/* sleep for a 1/3 of a second or so */
@@ -1028,7 +1050,7 @@
 	struct xpc_partition *part;
 	partid_t partid;
 	unsigned long engaged;
-	long time, print_time, disengage_request_timeout;
+	long time, printmsg_time, disengage_request_timeout;
 
 
 	/* keep xpc_hb_checker thread from doing anything (just in case) */
@@ -1055,24 +1077,43 @@
 		}
 	}
 
-	print_time = rtc_time();
-	disengage_request_timeout = print_time +
+	time = rtc_time();
+	printmsg_time = time +
+		(XPC_DISENGAGE_PRINTMSG_INTERVAL * sn_rtc_cycles_per_second);
+	disengage_request_timeout = time +
 		(xpc_disengage_request_timelimit * sn_rtc_cycles_per_second);
 
 	/* wait for all other partitions to disengage from us */
 
-	while ((engaged = xpc_partition_engaged(-1UL)) &&
-			(time = rtc_time()) < disengage_request_timeout) {
+	while (1) {
+		engaged = xpc_partition_engaged(-1UL);
+		if (!engaged) {
+			dev_info(xpc_part, "all partitions have disengaged\n");
+			break;
+		}
 
-		if (time >= print_time) {
+		time = rtc_time();
+		if (time >= disengage_request_timeout) {
+			for (partid = 1; partid < XP_MAX_PARTITIONS; partid++) {
+				if (engaged & (1UL << partid)) {
+					dev_info(xpc_part, "disengage from "
+						"remote partition %d timed "
+						"out\n", partid);
+				}
+			}
+			break;
+		}
+
+		if (time >= printmsg_time) {
 			dev_info(xpc_part, "waiting for remote partitions to "
-				"disengage, engaged=0x%lx\n", engaged);
-			print_time = time + (XPC_DISENGAGE_PRINTMSG_INTERVAL *
+				"disengage, timeout in %ld seconds\n",
+				(disengage_request_timeout - time) /
+						sn_rtc_cycles_per_second);
+			printmsg_time = time +
+					(XPC_DISENGAGE_PRINTMSG_INTERVAL *
 						sn_rtc_cycles_per_second);
 		}
 	}
-	dev_info(xpc_part, "finished waiting for remote partitions to "
-				"disengage, engaged=0x%lx\n", engaged);
 }
 
 
Index: linux-2.6.git-test/arch/ia64/sn/kernel/xpc_partition.c
=================================--- linux-2.6.git-test.orig/arch/ia64/sn/kernel/xpc_partition.c	2005-12-23 07:37:53.313511106 -0600
+++ linux-2.6.git-test/arch/ia64/sn/kernel/xpc_partition.c	2005-12-23 07:38:47.033491740 -0600
@@ -874,6 +874,9 @@
 			 * request in a timely fashion, so assume it's dead.
 			 */
 
+			dev_info(xpc_part, "disengage from remote partition %d "
+				"timed out\n", partid);
+			xpc_disengage_request_timedout = 1;
 			xpc_clear_partition_engaged(1UL << partid);
 			disengaged = 1;
 		}
Index: linux-2.6.git-test/arch/ia64/sn/kernel/xpc.h
=================================--- linux-2.6.git-test.orig/arch/ia64/sn/kernel/xpc.h	2005-12-23 07:37:53.314487567 -0600
+++ linux-2.6.git-test/arch/ia64/sn/kernel/xpc.h	2005-12-23 08:35:54.575338459 -0600
@@ -663,6 +663,7 @@
 extern struct device *xpc_part;
 extern struct device *xpc_chan;
 extern int xpc_disengage_request_timelimit;
+extern int xpc_disengage_request_timedout;
 extern irqreturn_t xpc_notify_IRQ_handler(int, void *, struct pt_regs *);
 extern void xpc_dropped_IPI_check(struct xpc_partition *);
 extern void xpc_activate_partition(struct xpc_partition *);
