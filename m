From: dcn@sgi.com (Dean Nelson)
Date: Tue, 10 Jan 2006 17:08:55 +0000
Subject: [PATCH] move xpc_system_reboot()
Message-Id: <43C3EA27.mailxJM11X21S@aqua.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Move xpc_system_reboot() to be closer to the file it calls for readability
reasons (which are indeed subjective).

Signed-off-by: Dean Nelson <dcn@sgi.com>


Index: linux-2.6/arch/ia64/sn/kernel/xpc_main.c
=================================--- linux-2.6.orig/arch/ia64/sn/kernel/xpc_main.c	2006-01-10 08:02:06.720347868 -0600
+++ linux-2.6/arch/ia64/sn/kernel/xpc_main.c	2006-01-10 08:06:55.555441133 -0600
@@ -1047,7 +1047,35 @@
 
 
 /*
- * Called when the system is about to be either restarted or halted.
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
+/*
+ * Notify other partitions to disengage from all references to our memory.
  */
 static void
 xpc_die_disengage(void)
@@ -1123,34 +1151,6 @@
 
 
 /*
- * This function is called when the system is being rebooted.
- */
-static int
-xpc_system_reboot(struct notifier_block *nb, unsigned long event, void *unused)
-{
-	enum xpc_retval reason;
-
-
-	switch (event) {
-	case SYS_RESTART:
-		reason = xpcSystemReboot;
-		break;
-	case SYS_HALT:
-		reason = xpcSystemHalt;
-		break;
-	case SYS_POWER_OFF:
-		reason = xpcSystemPoweroff;
-		break;
-	default:
-		reason = xpcSystemGoingDown;
-	}
-
-	xpc_do_exit(reason);
-	return NOTIFY_DONE;
-}
-
-
-/*
  * This function is called when the system is being restarted or halted due
  * to some sort of system failure. If this is the case we need to notify the
  * other partitions to disengage from all references to our memory.
