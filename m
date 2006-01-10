From: dcn@sgi.com (Dean Nelson)
Date: Tue, 10 Jan 2006 17:07:19 +0000
Subject: [PATCH] XPC and unregistering from notifier lists
Message-Id: <43C3E9C7.mailxHY1P31X4@aqua.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Only unregister from notifier lists if XPC is unloading.

Signed-off-by: Dean Nelson <dcn@sgi.com>


Index: linux-2.6/arch/ia64/sn/kernel/xpc_main.c
=================================--- linux-2.6.orig/arch/ia64/sn/kernel/xpc_main.c	2006-01-10 08:00:45.578850108 -0600
+++ linux-2.6/arch/ia64/sn/kernel/xpc_main.c	2006-01-10 08:00:47.674348795 -0600
@@ -1022,11 +1022,13 @@
 	del_timer_sync(&xpc_hb_timer);
 	DBUG_ON(xpc_vars->heartbeating_to_mask != 0);
 
-	/* take ourselves off of the reboot_notifier_list */
-	(void) unregister_reboot_notifier(&xpc_reboot_notifier);
+	if (reason = xpcUnloading) {
+		/* take ourselves off of the reboot_notifier_list */
+		(void) unregister_reboot_notifier(&xpc_reboot_notifier);
 
-	/* take ourselves off of the die_notifier list */
-	(void) unregister_die_notifier(&xpc_die_notifier);
+		/* take ourselves off of the die_notifier list */
+		(void) unregister_die_notifier(&xpc_die_notifier);
+	}
 
 	/* close down protections for IPI operations */
 	xpc_restrict_IPI_ops();
