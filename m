From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 06 Aug 2003 18:57:26 +0000
Subject: 2.6.0-test2 more ACPI/IOSAPIC cleanup
Message-Id: <marc-linux-ia64-106019755517280@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This applies on top of Takayoshi's interrupt polarity fix and just
makes things a tiny bit more consistent.

Is acpi_irq_to_vector() even needed anymore?  I don't see any
references to it.

Bjorn


--- testing-2.5/arch/ia64/kernel/acpi.c.1	2003-08-06 13:32:44.000000000 -0600
+++ testing-2.5/arch/ia64/kernel/acpi.c	2003-08-06 13:37:03.000000000 -0600
@@ -517,7 +517,6 @@
 {
 	struct acpi_table_header *fadt_header;
 	struct fadt_descriptor_rev2 *fadt;
-	u32 sci_irq;
 
 	if (!phys_addr || !size)
 		return -EINVAL;
@@ -531,12 +530,7 @@
 	if (!(fadt->iapc_boot_arch & BAF_8042_KEYBOARD_CONTROLLER))
 		acpi_kbd_controller_present = 0;
 
-	sci_irq = fadt->sci_int;
-
-	if (has_8259 && sci_irq < 16)
-		return 0;	/* legacy, no setup required */
-
-	iosapic_register_intr(sci_irq, IOSAPIC_POL_LOW, IOSAPIC_LEVEL);
+	acpi_register_irq(fadt->sci_int, ACPI_ACTIVE_LOW, ACPI_LEVEL_SENSITIVE);
 	return 0;
 }
 
@@ -686,27 +680,23 @@
 }
 
 int
-acpi_irq_to_vector (u32 irq)
+acpi_irq_to_vector (u32 gsi)
 {
-	if (has_8259 && irq < 16)
-		return isa_irq_to_vector(irq);
+	if (has_8259 && gsi < 16)
+		return isa_irq_to_vector(gsi);
 
-	return gsi_to_vector(irq);
+	return gsi_to_vector(gsi);
 }
 
 int
 acpi_register_irq (u32 gsi, u32 polarity, u32 trigger)
 {
-	int vector = 0;
-
-	if (has_8259 && (gsi < 16))
+	if (has_8259 && gsi < 16)
 		return isa_irq_to_vector(gsi);
 
-	/* Turn it on */
-	vector = iosapic_register_intr (gsi,
+	return iosapic_register_intr(gsi,
 			(polarity = ACPI_ACTIVE_HIGH) ? IOSAPIC_POL_HIGH : IOSAPIC_POL_LOW,
 			(trigger = ACPI_EDGE_SENSITIVE) ? IOSAPIC_EDGE : IOSAPIC_LEVEL);
-	return vector;
 }
 
 #endif /* CONFIG_ACPI_BOOT */

