From: Guenter Roeck <linux@roeck-us.net>
Date: Tue, 07 Oct 2014 05:28:21 +0000
Subject: [PATCH 19/44] ipmi: Register with kernel poweroff handler
Message-Id: <1412659726-29957-20-git-send-email-linux@roeck-us.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1412659726-29957-1-git-send-email-linux@roeck-us.net>
In-Reply-To: <1412659726-29957-1-git-send-email-linux@roeck-us.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: adi-buildroot-devel@lists.sourceforge.net, devel@driverdev.osuosl.org, devicetree@vger.kernel.org, lguest@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-alpha@vger.kernel.org, linux-am33-list@redhat.com, linux-cris-kernel@axis.com, linux-efi@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-m32r-ja@ml.linux-m32r.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-tegra@vger.kernel.org, linux-xtensa@linux-xtensa.org, openipmi-developer@lists.sourceforge.net, user-mode-linux-devel@lists.sourceforge.net, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linux-pm@vger.kernel.org, linux-sh@vger.kernel.org, xen-devel@lists.xenproject.org, Guenter Roeck <linux@roeck-us.net>, Corey

Register with kernel poweroff handler instead of setting pm_power_off
directly. Register with a high priority value of 192 to reflect that
the original code overwrites pm_power_off unconditionally.

Register poweroff handler after the ipmi system is ready, and unregister
it prior to cleanup. This avoids having to check for the ready variable
in the poweroff callback.

Cc: Corey Minyard <minyard@acm.org>
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 drivers/char/ipmi/ipmi_poweroff.c | 30 +++++++++++++++++++-----------
 1 file changed, 19 insertions(+), 11 deletions(-)

diff --git a/drivers/char/ipmi/ipmi_poweroff.c b/drivers/char/ipmi/ipmi_poweroff.c
index 9f2e3be..a942a41 100644
--- a/drivers/char/ipmi/ipmi_poweroff.c
+++ b/drivers/char/ipmi/ipmi_poweroff.c
@@ -36,6 +36,7 @@
 #include <linux/proc_fs.h>
 #include <linux/string.h>
 #include <linux/completion.h>
+#include <linux/notifier.h>
 #include <linux/pm.h>
 #include <linux/kdev_t.h>
 #include <linux/ipmi.h>
@@ -63,9 +64,6 @@ static ipmi_user_t ipmi_user;
 static int ipmi_ifnum;
 static void (*specific_poweroff_func)(ipmi_user_t user);
 
-/* Holds the old poweroff function so we can restore it on removal. */
-static void (*old_poweroff_func)(void);
-
 static int set_param_ifnum(const char *val, struct kernel_param *kp)
 {
 	int rv = param_set_int(val, kp);
@@ -544,15 +542,20 @@ static struct poweroff_function poweroff_functions[] = {
 
 
 /* Called on a powerdown request. */
-static void ipmi_poweroff_function(void)
+static int ipmi_poweroff_function(struct notifier_block *this,
+				  unsigned long unused1, void *unused2)
 {
-	if (!ready)
-		return;
-
 	/* Use run-to-completion mode, since interrupts may be off. */
 	specific_poweroff_func(ipmi_user);
+
+	return NOTIFY_DONE;
 }
 
+static struct notifier_block ipmi_poweroff_nb = {
+	.notifier_call = ipmi_poweroff_function,
+	.priority = 192,
+};
+
 /* Wait for an IPMI interface to be installed, the first one installed
    will be grabbed by this code and used to perform the powerdown. */
 static void ipmi_po_new_smi(int if_num, struct device *device)
@@ -631,9 +634,12 @@ static void ipmi_po_new_smi(int if_num, struct device *device)
 	printk(KERN_INFO PFX "Found a %s style poweroff function\n",
 	       poweroff_functions[i].platform_type);
 	specific_poweroff_func = poweroff_functions[i].poweroff_func;
-	old_poweroff_func = pm_power_off;
-	pm_power_off = ipmi_poweroff_function;
+
 	ready = 1;
+
+	rv = register_poweroff_handler(&ipmi_poweroff_nb);
+	if (rv)
+		pr_err(PFX "failed to register poweroff handler\n");
 }
 
 static void ipmi_po_smi_gone(int if_num)
@@ -644,9 +650,10 @@ static void ipmi_po_smi_gone(int if_num)
 	if (ipmi_ifnum != if_num)
 		return;
 
+	unregister_poweroff_handler(&ipmi_poweroff_nb);
+
 	ready = 0;
 	ipmi_destroy_user(ipmi_user);
-	pm_power_off = old_poweroff_func;
 }
 
 static struct ipmi_smi_watcher smi_watcher = {
@@ -732,12 +739,13 @@ static void __exit ipmi_poweroff_cleanup(void)
 
 	ipmi_smi_watcher_unregister(&smi_watcher);
 
+	unregister_poweroff_handler(&ipmi_poweroff_nb);
+
 	if (ready) {
 		rv = ipmi_destroy_user(ipmi_user);
 		if (rv)
 			printk(KERN_ERR PFX "could not cleanup the IPMI"
 			       " user: 0x%x\n", rv);
-		pm_power_off = old_poweroff_func;
 	}
 }
 module_exit(ipmi_poweroff_cleanup);
-- 
1.9.1

