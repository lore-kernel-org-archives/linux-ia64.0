From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 09 Mar 2004 23:27:12 +0000
Subject: Re: [ACPI] [PATCH] 6 of 6 rename some ACPI IRQ variables
Message-Id: <200403091627.12824.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200403091619.04333.bjorn.helgaas@hp.com>
In-Reply-To: <200403091619.04333.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: acpi-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org
Cc: Andi Kleen <ak@suse.de>, "Nakajima, Jun" <jun.nakajima@intel.com>, "Brown, Len" <len.brown@intel.com>

ACPI: Rename ACPI IRQ variables for clarity

	acpi_irq_irq -> acpi_irq_global_irq
	acpi_irq -> acpi_irq_trampoline

diff -Nru a/drivers/acpi/osl.c b/drivers/acpi/osl.c
--- a/drivers/acpi/osl.c	Tue Mar  9 14:44:25 2004
+++ b/drivers/acpi/osl.c	Tue Mar  9 14:44:25 2004
@@ -63,7 +63,7 @@
 extern char line_buf[80];
 #endif /*ENABLE_DEBUGGER*/
 
-static int acpi_irq_irq;
+static int acpi_irq_global_irq;
 static OSD_HANDLER acpi_irq_handler;
 static void *acpi_irq_context;
 
@@ -88,7 +88,7 @@
 acpi_os_terminate(void)
 {
 	if (acpi_irq_handler) {
-		acpi_os_remove_interrupt_handler(acpi_irq_irq,
+		acpi_os_remove_interrupt_handler(acpi_irq_global_irq,
 						 acpi_irq_handler);
 	}
 
@@ -234,7 +234,7 @@
 }
 
 static irqreturn_t
-acpi_irq(int irq, void *dev_id, struct pt_regs *regs)
+acpi_irq_trampoline(int irq, void *dev_id, struct pt_regs *regs)
 {
 	return (*acpi_irq_handler)(acpi_irq_context) ? IRQ_HANDLED : IRQ_NONE;
 }
@@ -258,11 +258,11 @@
 	}
 	acpi_irq_handler = handler;
 	acpi_irq_context = context;
-	if (request_irq(irq, acpi_irq, SA_SHIRQ, "acpi", acpi_irq)) {
+	if (request_irq(irq, acpi_irq_trampoline, SA_SHIRQ, "acpi", acpi_irq_trampoline)) {
 		printk(KERN_ERR PREFIX "SCI (IRQ%d) allocation failed\n", irq);
 		return AE_NOT_ACQUIRED;
 	}
-	acpi_irq_irq = global_irq;
+	acpi_irq_global_irq = global_irq;
 
 	return AE_OK;
 }
@@ -277,9 +277,9 @@
 			printk(KERN_ERR PREFIX "Can't remove ACPI interrupt handler\n");
 			return AE_ERROR;
 		}
-		free_irq(irq, acpi_irq);
+		free_irq(irq, acpi_irq_trampoline);
 		acpi_irq_handler = NULL;
-		acpi_irq_irq = 0;
+		acpi_irq_global_irq = 0;
 	}
 
 	return AE_OK;

