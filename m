From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 14 Dec 2004 20:44:22 +0000
Subject: [patch] do early_console_setup() on UP, too
Message-Id: <16831.20646.920259.363254@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony,

Here is trivial patch to enable the early console setup for UP as well.
Tested on zx1.

	--david

Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>

=== arch/ia64/kernel/setup.c 1.81 vs edited ==--- 1.81/arch/ia64/kernel/setup.c	2004-11-18 23:03:10 -08:00
+++ edited/arch/ia64/kernel/setup.c	2004-12-14 12:41:59 -08:00
@@ -289,6 +289,15 @@
 	return -1;
 }
 
+static inline void
+mark_bsp_online (void)
+{
+#ifdef CONFIG_SMP
+	/* If we register an early console, allow CPU 0 to printk */
+	cpu_set(smp_processor_id(), cpu_online_map);
+#endif
+}
+
 void __init
 setup_arch (char **cmdline_p)
 {
@@ -306,11 +315,8 @@
 	machvec_init(acpi_get_sysname());
 #endif
 
-#ifdef CONFIG_SMP
-	/* If we register an early console, allow CPU 0 to printk */
-	if (!early_console_setup(*cmdline_p))
-		cpu_set(smp_processor_id(), cpu_online_map);
-#endif
+	if (early_console_setup(*cmdline_p) = 0)
+		mark_bsp_online();
 
 #ifdef CONFIG_ACPI_BOOT
 	/* Initialize the ACPI boot-time table parser */
