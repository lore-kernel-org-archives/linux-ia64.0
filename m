From: "H. J. Lu" <hjl@lucon.org>
Date: Wed, 06 Aug 2003 15:45:04 +0000
Subject: 2.4 PATCH: Fix acpi for bigsur
Message-Id: <marc-linux-ia64-106018473231291@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I need this patch to get the current 2.4 kernel to boot on bigsur.


H.J.
----
--- linux/drivers/acpi/osl.c.acpi	Mon Jul 21 15:27:59 2003
+++ linux/drivers/acpi/osl.c	Wed Aug  6 07:34:41 2003
@@ -251,7 +251,12 @@ acpi_os_install_interrupt_handler(u32 ir
 	irq = acpi_fadt.sci_int;
 
 #ifdef CONFIG_IA64
-	irq = gsi_to_vector(irq);
+	irq = acpi_irq_to_vector (irq);
+	if (irq < 0) {
+		printk(KERN_ERR PREFIX "SCI (IRQ%d/%d) not registerd\n",
+		       irq, acpi_fadt.sci_int);
+		return AE_OK;
+	}
 #endif
 	acpi_irq_irq = irq;
 	acpi_irq_handler = handler;
