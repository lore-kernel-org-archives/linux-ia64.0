From: Alex Williamson <alex_williamson@attbi.com>
Date: Thu, 24 Apr 2003 04:44:10 +0000
Subject: [Linux-ia64] [PATCH] 2.5 interrupt fixes/cleanup
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------050600070106030107050806"
Message-Id: <marc-linux-ia64-105590723705597@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------050600070106030107050806
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit


    Here's some cleanups/fixes/changes for interrupts on 2.5.67 + ia64.
Specifically:

  - Cleanup some ugliness with polarity/trigger setup.

  - Add iosapic_enable_intr() to set_rte on an interupt when the
    device is enabled.  IMHO, we really only want to unmask RTEs
    for PRTs we might actually use.  This moves the interrupt
    distribution here too.

  - When changing a vector from edge to level, call register_intr()
    to do it so all the data structures get set correctly.  If we
    have to guess how to setup an interupt and get it wrong, this
    should close some holes in changing it back to the correct type.

  - Register the HCDP interrupt in 8250_hcdp - this is where we have
    to guess the polarity/trigger.  The real handler will get fixed
    up via PCI setup or ACPI namespace serial support, this gets it
    associated w/ the port at setup.  This should allow interrupts
    to work when using builtin UARTs as console on HP Itanium2 boxes.

Comments welcome.  Thanks,

	Alex

--
Alex Williamson                       HP Linux and Open Source Lab

--------------050600070106030107050806
Content-Type: text/plain;
 name="interrupt_cleanup.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="interrupt_cleanup.diff"

diff -urN --exclude=scripts linux-2.5.67/arch/ia64/kernel/acpi.c linux-2.5.67.work/arch/ia64/kernel/acpi.c
--- linux-2.5.67/arch/ia64/kernel/acpi.c	2003-04-22 13:58:09.000000000 -0600
+++ linux-2.5.67.work/arch/ia64/kernel/acpi.c	2003-04-21 10:55:05.000000000 -0600
@@ -922,8 +922,7 @@
 		return 0;
 
 	/* Turn it on */
-	vector = iosapic_register_intr (gsi, polarity ? IOSAPIC_POL_HIGH : IOSAPIC_POL_LOW,
-			trigger ? IOSAPIC_EDGE : IOSAPIC_LEVEL);
+	vector = iosapic_register_intr (gsi, polarity, trigger);
 	return vector;
 }
 
diff -urN --exclude=scripts linux-2.5.67/arch/ia64/kernel/iosapic.c linux-2.5.67.work/arch/ia64/kernel/iosapic.c
--- linux-2.5.67/arch/ia64/kernel/iosapic.c	2003-04-22 13:58:09.000000000 -0600
+++ linux-2.5.67.work/arch/ia64/kernel/iosapic.c	2003-04-22 13:55:10.000000000 -0600
@@ -644,20 +644,11 @@
 	}
 }
 
-static void __init
-fixup_vector (int vector, unsigned int gsi, const char *pci_id)
+void
+iosapic_enable_intr (unsigned int vector)
 {
-	struct hw_interrupt_type *irq_type = &irq_type_iosapic_level;
-	irq_desc_t *idesc;
 	unsigned int dest;
 
-	idesc = irq_desc(vector);
-	if (idesc->handler != irq_type) {
-		if (idesc->handler != &no_irq_type)
-			printk(KERN_INFO "IOSAPIC: changing vector %d from %s to %s\n",
-			       vector, idesc->handler->typename, irq_type->typename);
-		idesc->handler = irq_type;
-	}
 #ifdef CONFIG_SMP
 	/*
	 * For platforms that do not support interrupt redirect via the XTP interface, we
@@ -685,8 +677,8 @@
 #endif
 	set_rte(vector, dest);
 
-	printk(KERN_INFO "IOSAPIC: %s -> GSI 0x%x -> CPU 0x%04x vector %d\n",
-	       pci_id, gsi, dest, vector);
+	printk(KERN_INFO "IOSAPIC: vector %d -> CPU 0x%04x, enabled\n",
+	       vector, dest);
 }
 
 void __init
@@ -697,6 +689,8 @@
 	unsigned int gsi;
 	int vector;
 	char pci_id[16];
+	struct hw_interrupt_type *irq_type = &irq_type_iosapic_level;
+	irq_desc_t *idesc;
 
 	list_for_each(node, &acpi_prt.entries) {
 		entry = list_entry(node, struct acpi_prt_entry, node);
@@ -724,6 +718,13 @@
 		snprintf(pci_id, sizeof(pci_id), "%02x:%02x:%02x[%c]",
 			 entry->id.segment, entry->id.bus, entry->id.device, 'A' + entry->pin);
 
-		fixup_vector(vector, gsi, pci_id);
+		/*
+		 * If vector was previously initialized to a different
+		 * handler, re-initialize.
+		 */
+		idesc = irq_desc(vector);
+		if (idesc->handler != irq_type)
+			register_intr(gsi, vector, IOSAPIC_LOWEST_PRIORITY, IOSAPIC_POL_LOW, IOSAPIC_LEVEL);
+
 	}
 }
diff -urN --exclude=scripts linux-2.5.67/drivers/acpi/pci_irq.c linux-2.5.67.work/drivers/acpi/pci_irq.c
--- linux-2.5.67/drivers/acpi/pci_irq.c	2003-04-22 13:58:09.000000000 -0600
+++ linux-2.5.67.work/drivers/acpi/pci_irq.c	2003-04-22 13:27:24.000000000 -0600
@@ -376,6 +376,10 @@
 		eisa_set_level_irq(dev->irq);
 	}
 #endif
+#ifdef CONFIG_IOSAPIC
+	if (acpi_irq_model == ACPI_IRQ_MODEL_IOSAPIC)
+		iosapic_enable_intr(dev->irq);
+#endif
 
 	return_VALUE(dev->irq);
 }
diff -urN --exclude=scripts linux-2.5.67/drivers/serial/8250_hcdp.c linux-2.5.67.work/drivers/serial/8250_hcdp.c
--- linux-2.5.67/drivers/serial/8250_hcdp.c	2003-04-22 13:58:09.000000000 -0600
+++ linux-2.5.67.work/drivers/serial/8250_hcdp.c	2003-04-22 14:05:04.000000000 -0600
@@ -17,9 +17,11 @@
 #include <linux/serial.h>
 #include <linux/serial_core.h>
 #include <linux/types.h>
+#include <linux/acpi.h>
 
 #include <asm/io.h>
 #include <asm/serial.h>
+#include <asm/acpi.h>
 
 #include "8250_hcdp.h"
 
@@ -151,7 +153,11 @@
 			printk(KERN_WARNING"warning: No support for PCI serial console\n");
 			return;
 		}
+#ifdef CONFIG_IA64
+		port.irq = acpi_register_irq(gsi, ACPI_ACTIVE_HIGH, ACPI_EDGE_SENSITIVE);
+#else
 		port.irq = gsi;
+#endif
 		port.flags = UPF_SKIP_TEST | UPF_BOOT_AUTOCONF;
 		if (gsi)
 			port.flags |= ASYNC_AUTO_IRQ;
diff -urN --exclude=scripts linux-2.5.67/drivers/serial/acpi.c linux-2.5.67.work/drivers/serial/acpi.c
--- linux-2.5.67/drivers/serial/acpi.c	2003-04-22 13:58:09.000000000 -0600
+++ linux-2.5.67.work/drivers/serial/acpi.c	2003-04-21 10:51:37.000000000 -0600
@@ -33,8 +33,7 @@
 	if (ext_irq->number_of_interrupts > 0) {
 #ifdef CONFIG_IA64
 		req->irq = acpi_register_irq(ext_irq->interrupts[0],
-	                  ext_irq->active_high_low == ACPI_ACTIVE_HIGH,
-	                  ext_irq->edge_level == ACPI_EDGE_SENSITIVE);
+	                  ext_irq->active_high_low, ext_irq->edge_level);
 #else
 		req->irq = ext_irq->interrupts[0];
 #endif
diff -urN --exclude=scripts linux-2.5.67/include/asm-ia64/iosapic.h linux-2.5.67.work/include/asm-ia64/iosapic.h
--- linux-2.5.67/include/asm-ia64/iosapic.h	2003-04-07 11:31:45.000000000 -0600
+++ linux-2.5.67.work/include/asm-ia64/iosapic.h	2003-04-22 13:17:15.000000000 -0600
@@ -57,6 +57,7 @@
 extern int gsi_to_vector (unsigned int gsi);
 extern int gsi_to_irq (unsigned int gsi);
 extern void __init iosapic_parse_prt (void);
+extern void iosapic_enable_intr (unsigned int vector);
 extern int iosapic_register_intr (unsigned int gsi, unsigned long polarity,
 				  unsigned long trigger);
 extern void __init iosapic_override_isa_irq (unsigned int isa_irq, unsigned int gsi,

--------------050600070106030107050806--


