From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 13 Jan 2004 23:38:15 +0000
Subject: [PATCH] Export acpi_register_irq for modules
Message-Id: <200401131638.15740.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This is needed if drivers for ACPI devices need interrupts and
are built as a modules.  Patch against 2.6.

--- 1.57/arch/ia64/kernel/acpi.c	Tue Nov 18 03:05:32 2003
+++ edited/arch/ia64/kernel/acpi.c	Mon Jan 12 16:45:00 2004
@@ -32,6 +32,7 @@
  */
 
 #include <linux/config.h>
+#include <linux/module.h>
 #include <linux/init.h>
 #include <linux/kernel.h>
 #include <linux/sched.h>
@@ -629,5 +630,6 @@
 			(polarity = ACPI_ACTIVE_HIGH) ? IOSAPIC_POL_HIGH : IOSAPIC_POL_LOW,
 			(trigger = ACPI_EDGE_SENSITIVE) ? IOSAPIC_EDGE : IOSAPIC_LEVEL);
 }
+EXPORT_SYMBOL(acpi_register_irq);
 
 #endif /* CONFIG_ACPI_BOOT */

