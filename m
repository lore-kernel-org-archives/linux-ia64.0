From: Aaron Young <ayoung@google.engr.sgi.com>
Date: Fri, 04 Mar 2005 23:56:51 +0000
Subject: [PATCH] 2.6.12 Altix: enable poweroff
Message-Id: <200503042356.PAA59985@google.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



 This patch adds the necessary "hook" to allow SGI/SN
 machines to perform a system power off upon a 
 'init 0', 'halt -p', 'poweroff' or 'shutdown -h'.

 The "hook" is to set the pm_power_off callback
 to ia64_sn_power_down(). pm_power_off is checked
 in machine_power_off()/do_poweroff() and, if set, is executed. ia64_sn_power_down()
 is a function already present (but not used currently) in the sn kernel.
 ia64_sn_power_down() makes a SAL call to execute the
 power off.
 
 Signed-off-by: Aaron J Young <ayoung@sgi.com>

--- linux2.6.12/arch/ia64/sn/kernel/setup.c.orig        2005-03-04 14:14:36 -06:00
+++ linux2.6.12/arch/ia64/sn/kernel/setup.c     2005-03-04 14:09:28 -06:00
@@ -29,6 +29,7 @@
 #include <linux/sched.h>
 #include <linux/root_dev.h>
 #include <linux/nodemask.h>
+#include <linux/pm.h>
 
 #include <asm/io.h>
 #include <asm/sal.h>
@@ -341,6 +342,14 @@ void __init sn_setup(char **cmdline_p)
        screen_info = sn_screen_info;
 
        sn_timer_init();
+
+       /*
+        * set pm_power_off to a SAL call to allow
+        * sn machines to power off. The SAL call can be replaced
+        * by an ACPI interface call when ACPI is fully implemented
+        * for sn.
+        */
+       pm_power_off = ia64_sn_power_down;
 }
 
 /**
