From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 06 Aug 2003 21:54:49 +0000
Subject: Re: 2.4 PATCH: Fix acpi for bigsur
Message-Id: <marc-linux-ia64-106020690128452@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106018473231291@msgid-missing>
In-Reply-To: <marc-linux-ia64-106018473231291@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I need this patch to get the current 2.4 kernel to boot on bigsur.

I reproduced that problem, and applied the following patch for 2.4
(this is what we had in 2.4.21, prior to the big ACPI update in 2.4).

Andy, can you apply this to ACPI?  It's needed for both 2.4 and 2.5
ia64 kernels.  The problem is that on machines with an 8259, the
SCI interrupt might be a legacy ISA IRQ, not a GSI.

I'm not thrilled about the name "acpi_irq_to_vector".  Something
like "acpi_interrupt_to_irq" seems like it would fit the usage better.
Suggestions?

Bjorn


=== drivers/acpi/osl.c 1.27 vs edited ==--- 1.27/drivers/acpi/osl.c	Thu Jul 10 04:20:31 2003
+++ edited/drivers/acpi/osl.c	Wed Aug  6 16:16:38 2003
@@ -251,7 +251,12 @@
 	irq = acpi_fadt.sci_int;
 
 #ifdef CONFIG_IA64
-	irq = gsi_to_vector(irq);
+	irq = acpi_irq_to_vector(irq);
+	if (irq < 0) {
+		printk(KERN_ERR PREFIX "SCI (ACPI interrupt %d) not registerd\n",
+		       acpi_fadt.sci_int);
+		return AE_OK;
+	}
 #endif
 	acpi_irq_irq = irq;
 	acpi_irq_handler = handler;
@@ -269,7 +274,7 @@
 {
 	if (acpi_irq_handler) {
 #ifdef CONFIG_IA64
-		irq = gsi_to_vector(irq);
+		irq = acpi_irq_to_vector(irq);
 #endif
 		free_irq(irq, acpi_irq);
 		acpi_irq_handler = NULL;

