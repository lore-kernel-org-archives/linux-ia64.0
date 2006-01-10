From: dcn@sgi.com (Dean Nelson)
Date: Tue, 10 Jan 2006 17:08:00 +0000
Subject: [PATCH] ignoring loss of heartbeat while XPC is in kdebug
Message-Id: <43C3E9F0.mailxJ311RHK1@aqua.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Allow for the loss of heartbeat while in kdebug to be ignored by remote
partitions.

Signed-off-by: Dean Nelson <dcn@sgi.com>


Index: linux-2.6/arch/ia64/sn/kernel/xpc_main.c
=================================--- linux-2.6.orig/arch/ia64/sn/kernel/xpc_main.c	2006-01-10 07:54:15.283917046 -0600
+++ linux-2.6/arch/ia64/sn/kernel/xpc_main.c	2006-01-10 07:56:18.299260749 -0600
@@ -82,6 +82,9 @@
 struct device *xpc_chan = &xpc_chan_dbg_subname;
 
 
+static int xpc_kdebug_ignore;
+
+
 /* systune related variables for /proc/sys directories */
 
 static int xpc_hb_interval = XPC_HB_DEFAULT_INTERVAL;
@@ -1148,7 +1151,12 @@
 
 
 /*
- * This function is called when the system is being rebooted.
+ * This function is called when the system is being restarted or halted due
+ * to some sort of system failure. If this is the case we need to notify the
+ * other partitions to disengage from all references to our memory.
+ * This function can also be called when our heartbeater could be offlined
+ * for a time. In this case we need to notify other partitions to not worry
+ * about the lack of a heartbeat.
  */
 static int
 xpc_system_die(struct notifier_block *nb, unsigned long event, void *unused)
@@ -1158,11 +1166,25 @@
 	case DIE_MACHINE_HALT:
 		xpc_die_disengage();
 		break;
+
+	case DIE_KDEBUG_ENTER:
+		/* Should lack of heartbeat be ignored by other partitions? */
+		if (!xpc_kdebug_ignore) {
+			break;
+		}
+		/* fall through */
 	case DIE_MCA_MONARCH_ENTER:
 	case DIE_INIT_MONARCH_ENTER:
 		xpc_vars->heartbeat++;
 		xpc_vars->heartbeat_offline = 1;
 		break;
+
+	case DIE_KDEBUG_LEAVE:
+		/* Is lack of heartbeat being ignored by other partitions? */
+		if (!xpc_kdebug_ignore) {
+			break;
+		}
+		/* fall through */
 	case DIE_MCA_MONARCH_LEAVE:
 	case DIE_INIT_MONARCH_LEAVE:
 		xpc_vars->heartbeat++;
@@ -1387,3 +1409,7 @@
 MODULE_PARM_DESC(xpc_disengage_request_timelimit, "Number of seconds to wait "
 		"for disengage request to complete.");
 
+module_param(xpc_kdebug_ignore, int, 0);
+MODULE_PARM_DESC(xpc_kdebug_ignore, "Should lack of heartbeat be ignored by "
+		"other partitions when dropping into kdebug.");
+
