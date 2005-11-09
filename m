From: dcn@sgi.com (Dean Nelson)
Date: Wed, 09 Nov 2005 20:41:57 +0000
Subject: [PATCH] utilize notify_die() for XPC disengage
Message-Id: <43725F15.mailx5K311LZHD@aqua.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

XPC (as in arch/ia64/sn/kernel/xp*) has a need to notify other partitions
(SGI Altix) whenever a partition is going down in order to get them to
disengage from accessing the halting partition's memory. If this is not
done before the reset of the hardware, the other partitions can find
themselves encountering MCAs that bring them down.

This functionality depends on patches submitted by Keith Owens <kaos@sgi.com>

	http://marc.theaimsgroup.com/?l=linux-ia64&m3090221421071&w=2
	http://marc.theaimsgroup.com/?l=linux-kernel&m3132971819786&w=2

Signed-off-by: Dean Nelson <dcn@sgi.com>


Index: linux-2.6.git-test/arch/ia64/sn/kernel/xpc_main.c
=================================--- linux-2.6.git-test.orig/arch/ia64/sn/kernel/xpc_main.c	2005-11-09 12:50:16.949830222 -0600
+++ linux-2.6.git-test/arch/ia64/sn/kernel/xpc_main.c	2005-11-09 14:05:41.891525144 -0600
@@ -57,6 +57,7 @@
 #include <linux/reboot.h>
 #include <asm/sn/intr.h>
 #include <asm/sn/sn_sal.h>
+#include <asm/kdebug.h>
 #include <asm/uaccess.h>
 #include "xpc.h"
 
@@ -188,6 +189,11 @@
 	.notifier_call = xpc_system_reboot,
 };
 
+static int xpc_system_die(struct notifier_block *, unsigned long, void *);
+static struct notifier_block xpc_die_notifier = {
+	.notifier_call = xpc_system_die,
+};
+
 
 /*
  * Timer function to enforce the timelimit on the partition disengage request.
@@ -997,6 +1003,9 @@
 	/* take ourselves off of the reboot_notifier_list */
 	(void) unregister_reboot_notifier(&xpc_reboot_notifier);
 
+	/* take ourselves off of the die_notifier list */
+	(void) unregister_die_notifier(&xpc_die_notifier);
+
 	/* close down protections for IPI operations */
 	xpc_restrict_IPI_ops();
 
@@ -1011,6 +1020,63 @@
 
 
 /*
+ * Called when the system is about to be either restarted or halted.
+ */
+static void
+xpc_die_disengage(void)
+{
+	struct xpc_partition *part;
+	partid_t partid;
+	unsigned long engaged;
+	long time, print_time, disengage_request_timeout;
+
+
+	/* keep xpc_hb_checker thread from doing anything (just in case) */
+	xpc_exiting = 1;
+
+	xpc_vars->heartbeating_to_mask = 0;  /* indicate we're deactivated */
+
+	for (partid = 1; partid < XP_MAX_PARTITIONS; partid++) {
+		part = &xpc_partitions[partid];
+
+		if (!XPC_SUPPORTS_DISENGAGE_REQUEST(part->
+							remote_vars_version)) {
+
+			/* just in case it was left set by an earlier XPC */
+			xpc_clear_partition_engaged(1UL << partid);
+			continue;
+		}
+
+		if (xpc_partition_engaged(1UL << partid) ||
+					part->act_state != XPC_P_INACTIVE) {
+			xpc_request_partition_disengage(part);
+			xpc_mark_partition_disengaged(part);
+			xpc_IPI_send_disengage(part);
+		}
+	}
+
+	print_time = rtc_time();
+	disengage_request_timeout = print_time +
+		(xpc_disengage_request_timelimit * sn_rtc_cycles_per_second);
+
+	/* wait for all other partitions to disengage from us */
+
+	while ((engaged = xpc_partition_engaged(-1UL)) &&
+			(time = rtc_time()) < disengage_request_timeout) {
+
+		if (time >= print_time) {
+			dev_info(xpc_part, "waiting for remote partitions to "
+				"disengage, engaged=0x%lx\n", engaged);
+			print_time = time + (XPC_DISENGAGE_PRINTMSG_INTERVAL *
+						sn_rtc_cycles_per_second);
+		}
+	}
+	dev_info(xpc_part, "finished waiting for remote partitions to "
+				"disengage, engaged=0x%lx\n", engaged);
+}
+
+
+/*
  * This function is called when the system is being rebooted.
  */
 static int
@@ -1038,6 +1104,33 @@
 }
 
 
+/*
+ * This function is called when the system is being rebooted.
+ */
+static int
+xpc_system_die(struct notifier_block *nb, unsigned long event, void *unused)
+{
+	switch (event) {
+	case DIE_MACHINE_RESTART:
+	case DIE_MACHINE_HALT:
+		xpc_die_disengage();
+		break;
+	case DIE_MCA_MONARCH_ENTER:
+	case DIE_INIT_MONARCH_ENTER:
+		xpc_vars->heartbeat++;
+		xpc_vars->heartbeat_offline = 1;
+		break;
+	case DIE_MCA_MONARCH_LEAVE:
+	case DIE_INIT_MONARCH_LEAVE:
+		xpc_vars->heartbeat++;
+		xpc_vars->heartbeat_offline = 0;
+		break;
+	}
+
+	return NOTIFY_DONE;
+}
+
+
 int __init
 xpc_init(void)
 {
@@ -1154,6 +1247,12 @@
 		dev_warn(xpc_part, "can't register reboot notifier\n");
 	}
 
+	/* add ourselves to the die_notifier list (i.e., ia64die_chain) */
+	ret = register_die_notifier(&xpc_die_notifier);
+	if (ret != 0) {
+		dev_warn(xpc_part, "can't register die notifier\n");
+	}
+
 
 	/*
 	 * Set the beating to other partitions into motion.  This is
@@ -1179,6 +1278,9 @@
 		/* take ourselves off of the reboot_notifier_list */
 		(void) unregister_reboot_notifier(&xpc_reboot_notifier);
 
+		/* take ourselves off of the die_notifier list */
+		(void) unregister_die_notifier(&xpc_die_notifier);
+
 		del_timer_sync(&xpc_hb_timer);
 		free_irq(SGI_XPC_ACTIVATE, NULL);
 		xpc_restrict_IPI_ops();
Index: linux-2.6.git-test/arch/ia64/sn/kernel/xpc.h
=================================--- linux-2.6.git-test.orig/arch/ia64/sn/kernel/xpc.h	2005-11-09 12:50:16.851207102 -0600
+++ linux-2.6.git-test/arch/ia64/sn/kernel/xpc.h	2005-11-09 14:01:08.472479792 -0600
@@ -163,7 +163,7 @@
 	u8 version;
 	u64 heartbeat;
 	u64 heartbeating_to_mask;
-	u64 kdb_status;		/* 0 = machine running */
+	u64 heartbeat_offline;	/* if 0, heartbeat should be changing */
 	int act_nasid;
 	int act_phys_cpuid;
 	u64 vars_part_pa;
Index: linux-2.6.git-test/arch/ia64/sn/kernel/xpc_partition.c
=================================--- linux-2.6.git-test.orig/arch/ia64/sn/kernel/xpc_partition.c	2005-11-09 12:50:16.851207102 -0600
+++ linux-2.6.git-test/arch/ia64/sn/kernel/xpc_partition.c	2005-11-09 14:08:45.629087760 -0600
@@ -436,13 +436,13 @@
 		}
 
 		dev_dbg(xpc_part, "partid = %d, heartbeat = %ld, last_heartbeat"
-			" = %ld, kdb_status = %ld, HB_mask = 0x%lx\n", partid,
-			remote_vars->heartbeat, part->last_heartbeat,
-			remote_vars->kdb_status,
+			" = %ld, heartbeat_offline = %ld, HB_mask = 0x%lx\n",
+			partid, remote_vars->heartbeat, part->last_heartbeat,
+			remote_vars->heartbeat_offline,
 			remote_vars->heartbeating_to_mask);
 
 		if (((remote_vars->heartbeat = part->last_heartbeat) &&
-			(remote_vars->kdb_status = 0)) ||
+			(remote_vars->heartbeat_offline = 0)) ||
 			     !xpc_hb_allowed(sn_partition_id, remote_vars)) {
 
 			XPC_DEACTIVATE_PARTITION(part, xpcNoHeartbeat);
