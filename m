From: Guenter Roeck <linux@roeck-us.net>
Date: Tue, 07 Oct 2014 05:28:29 +0000
Subject: [PATCH 27/44] x86: apm: Register with kernel poweroff handler
Message-Id: <1412659726-29957-28-git-send-email-linux@roeck-us.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1412659726-29957-1-git-send-email-linux@roeck-us.net>
In-Reply-To: <1412659726-29957-1-git-send-email-linux@roeck-us.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: adi-buildroot-devel@lists.sourceforge.net, devel@driverdev.osuosl.org, devicetree@vger.kernel.org, lguest@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-alpha@vger.kernel.org, linux-am33-list@redhat.com, linux-cris-kernel@axis.com, linux-efi@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-m32r-ja@ml.linux-m32r.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-tegra@vger.kernel.org, linux-xtensa@linux-xtensa.org, openipmi-developer@lists.sourceforge.net, user-mode-linux-devel@lists.sourceforge.net, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linux-pm@vger.kernel.org, linux-sh@vger.kernel.org, xen-devel@lists.xenproject.org, Guenter Roeck <linux@roeck-us.net>, Thomas

Register with kernel poweroff handler instead of setting pm_power_off
directly. Register with high priority value of 192 to reflect that
the original code overwrites existing poweroff handlers.

Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Jiri Kosina <jkosina@suse.cz>
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 arch/x86/kernel/apm_32.c | 20 +++++++++++++++-----
 1 file changed, 15 insertions(+), 5 deletions(-)

diff --git a/arch/x86/kernel/apm_32.c b/arch/x86/kernel/apm_32.c
index 5848744..84566a6 100644
--- a/arch/x86/kernel/apm_32.c
+++ b/arch/x86/kernel/apm_32.c
@@ -219,6 +219,7 @@
 #include <linux/init.h>
 #include <linux/time.h>
 #include <linux/sched.h>
+#include <linux/notifier.h>
 #include <linux/pm.h>
 #include <linux/capability.h>
 #include <linux/device.h>
@@ -981,7 +982,8 @@ recalc:
  *	on their first cpu.
  */
 
-static void apm_power_off(void)
+static int apm_power_off(struct notifier_block *this, unsigned long unused1,
+			 void *unused2)
 {
 	/* Some bioses don't like being called from CPU != 0 */
 	if (apm_info.realmode_power_off) {
@@ -990,8 +992,14 @@ static void apm_power_off(void)
 	} else {
 		(void)set_system_power_state(APM_STATE_OFF);
 	}
+	return NOTIFY_DONE;
 }
 
+static struct notifier_block apm_poweroff_nb = {
+	.notifier_call = apm_power_off,
+	.priority = 192,
+};
+
 #ifdef CONFIG_APM_DO_ENABLE
 
 /**
@@ -1847,8 +1855,11 @@ static int apm(void *unused)
 	}
 
 	/* Install our power off handler.. */
-	if (power_off)
-		pm_power_off = apm_power_off;
+	if (power_off) {
+		error = register_poweroff_handler(&apm_poweroff_nb);
+		if (error)
+			pr_err("apm: Failed to register poweroff handler\n");
+	}
 
 	if (num_online_cpus() = 1 || smp) {
 #if defined(CONFIG_APM_DISPLAY_BLANK) && defined(CONFIG_VT)
@@ -2408,9 +2419,8 @@ static void __exit apm_exit(void)
 			apm_error("disengage power management", error);
 	}
 	misc_deregister(&apm_device);
+	unregister_poweroff_handler(&apm_poweroff_nb);
 	remove_proc_entry("apm", NULL);
-	if (power_off)
-		pm_power_off = NULL;
 	if (kapmd_task) {
 		kthread_stop(kapmd_task);
 		kapmd_task = NULL;
-- 
1.9.1

