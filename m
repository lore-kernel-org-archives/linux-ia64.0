From: Prarit Bhargava <prarit@sgi.com>
Date: Wed, 19 Jan 2005 13:09:36 +0000
Subject: [PATCH]: (resubmitted) Error in ACPI error handling results in WARN_ON
Message-Id: <41EE5C10.4030604@sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------030603060406070606040608"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------030603060406070606040608
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

The issue here is the error handling within the ACPI layer.  gsi = 0 is a
valid return value from acpi_pci_irq_lookup, while gsi = (-1) is the value
returned when a PRT cannot be found.



--------------030603060406070606040608
Content-Type: text/plain;
 name="1-acpi-ide.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="1-acpi-ide.patch"

===== drivers/acpi/pci_irq.c 1.35 vs edited =====
--- 1.35/drivers/acpi/pci_irq.c	2005-01-04 21:48:17 -05:00
+++ edited/drivers/acpi/pci_irq.c	2005-01-14 08:14:34 -05:00
@@ -487,10 +487,10 @@
 	 * If no PRT entry was found, we'll try to derive an IRQ from the
 	 * device's parent bridge.
 	 */
-	if (!gsi)
+	if (gsi == -1)
  		gsi = acpi_pci_irq_derive(dev, pin,
 					  &edge_level, &active_high_low);
-	if (!gsi)
+	if (gsi == -1)
 		return_VOID;
 
 	/*

--------------030603060406070606040608--
