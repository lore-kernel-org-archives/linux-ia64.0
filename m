From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Fri, 12 Mar 2004 22:57:21 +0000
Subject: [PATCH] clean up ACPI GSI/IRQ conversions (ia64 part)
Message-Id: <200403121557.21889.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Mosberger <davidm-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org>
Cc: acpi-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org

Hi David,

Here's the ia64 part, again based on 2.6.4.  This should be safe to
apply by itself.  I've compiled and booted this, both with and without
the upcoming ACPI patch.

Changelog:

Add "acpi_gsi_to_irq()" as a generic replacement for "acpi_irq_to_vector()".
This converts from an ACPI global system interrupt number to a Linux IRQ.
Also, convert ia64-specific terminology to use GSI when appropriate.

=== arch/ia64/kernel/acpi.c 1.63 vs edited ==--- 1.63/arch/ia64/kernel/acpi.c	Wed Feb 18 08:10:58 2004
+++ edited/arch/ia64/kernel/acpi.c	Fri Mar 12 12:32:11 2004
@@ -626,6 +626,7 @@
 	return 0;
 }
 
+/* deprecated in favor of acpi_gsi_to_irq */
 int
 acpi_irq_to_vector (u32 gsi)
 {
@@ -633,6 +634,23 @@
 		return isa_irq_to_vector(gsi);
 
 	return gsi_to_vector(gsi);
+}
+
+int
+acpi_gsi_to_irq (u32 gsi, unsigned int *irq)
+{
+	int vector;
+
+	if (has_8259 && gsi < 16)
+		*irq = isa_irq_to_vector(gsi);
+	else {
+		vector = gsi_to_vector(gsi);
+		if (vector = -1)
+			return -1;
+
+		*irq = vector;
+	}
+	return 0;
 }
 
 int
=== include/asm-ia64/acpi.h 1.14 vs edited ==--- 1.14/include/asm-ia64/acpi.h	Thu Feb 26 23:49:53 2004
+++ edited/include/asm-ia64/acpi.h	Fri Mar 12 12:32:41 2004
@@ -93,7 +93,8 @@
 const char *acpi_get_sysname (void);
 int acpi_request_vector (u32 int_type);
 int acpi_register_irq (u32 gsi, u32 polarity, u32 trigger);
-int acpi_irq_to_vector (u32 irq);
+int acpi_irq_to_vector (u32 irq); /* deprecated in favor of acpi_gsi_to_irq */
+int acpi_gsi_to_irq (u32 gsi, unsigned int *irq);
 
 #ifdef CONFIG_ACPI_NUMA
 /* Proximity bitmap length; _PXM is at most 255 (8 bit)*/

