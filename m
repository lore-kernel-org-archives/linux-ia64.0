From: Prarit Bhargava <prarit@sgi.com>
Date: Fri, 14 Jan 2005 14:18:07 +0000
Subject: Re: [PATCH]: Error in ACPI error handling results in WARN_ON
Message-Id: <41E7D49F.1020201@sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------020106040702070200090202"
List-Id: <linux-ia64.vger.kernel.org>
References: <41E7CE5D.3010805@sgi.com>
In-Reply-To: <41E7CE5D.3010805@sgi.com>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------020106040702070200090202
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Thanks for your input Matthew -- it's always appreciated.

Here's a new patch taking into account Matthew's comments.



--------------020106040702070200090202
Content-Type: text/plain;
 name="acpi-ide.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="acpi-ide.patch"

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

--------------020106040702070200090202--
