From: Prarit Bhargava <prarit@sgi.com>
Date: Fri, 14 Jan 2005 13:51:25 +0000
Subject: [PATCH]: Error in ACPI error handling results in WARN_ON
Message-Id: <41E7CE5D.3010805@sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------040908080007040005040305"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------040908080007040005040305
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

The issue here is the error handling within the ACPI layer.  gsi = 0 is a
valid return value from acpi_pci_irq_lookup, while gsi = (-1) is the value
returned when a PRT cannot be found.

This error in error handling can result in a WARN_ON at
arch/ia64/kernel/iosapic.c:622 .

The remaining fix is to complete error handling within the core IDE
layer and the IOC4 IDE driver.



--------------040908080007040005040305
Content-Type: text/plain;
 name="acpi-ide.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="acpi-ide.patch"

===== drivers/acpi/pci_irq.c 1.35 vs edited =====
--- 1.35/drivers/acpi/pci_irq.c	2005-01-04 21:48:17 -05:00
+++ edited/drivers/acpi/pci_irq.c	2005-01-13 16:08:10 -05:00
@@ -487,10 +487,10 @@
 	 * If no PRT entry was found, we'll try to derive an IRQ from the
 	 * device's parent bridge.
 	 */
-	if (!gsi)
+	if (gsi == (-1))
  		gsi = acpi_pci_irq_derive(dev, pin,
 					  &edge_level, &active_high_low);
-	if (!gsi)
+	if (!gsi == (-1))
 		return_VOID;
 
 	/*
===== drivers/ide/ide-probe.c 1.90 vs edited =====
--- 1.90/drivers/ide/ide-probe.c	2004-12-10 14:12:14 -05:00
+++ edited/drivers/ide/ide-probe.c	2005-01-14 07:16:42 -05:00
@@ -841,7 +841,11 @@
 	if (fixup)
 		fixup(hwif);
 
-	hwif_init(hwif);
+	if (!hwif_init(hwif))
+	{
+		printk("%s: Failed to initialize IDE interface\n", hwif->name);
+		return -1;
+	}
 
 	if (hwif->present) {
 		u16 unit = 0;
===== drivers/ide/pci/sgiioc4.c 1.22 vs edited =====
--- 1.22/drivers/ide/pci/sgiioc4.c	2005-01-06 20:35:35 -05:00
+++ edited/drivers/ide/pci/sgiioc4.c	2005-01-14 07:23:27 -05:00
@@ -669,7 +669,11 @@
 		printk(KERN_INFO "%s: %s Bus-Master DMA disabled\n",
 		       hwif->name, d->name);
 
-	probe_hwif_init(hwif);
+	if (probe_hwif_init(hwif))
+	{
+		printk(KERN_INFO "%s: initialization failed\n", hwif->name);
+		return -EIO;
+	}
 
 	/* Create /proc/ide entries */
 	create_proc_ide_interfaces(); 

--------------040908080007040005040305--
