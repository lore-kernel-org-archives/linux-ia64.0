From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 20 Jan 2004 23:07:32 +0000
Subject: [PATCH] add acpi_interrupt_to_irq
Message-Id: <200401201607.32214.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: acpi-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Len Brown <len.brown-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

This patch against 2.6.1 tightens up some language and removes
a couple IA64 #ifdefs:

 drivers/acpi/osl.c        |   26 ++++++++++++++------------
 include/asm-i386/acpi.h   |    6 ++++++
 include/asm-x86_64/acpi.h |    6 ++++++
 include/asm-ia64/acpi.h   |    2 +-
 arch/ia64/kernel/acpi.c   |   16 ++++++++++++----
 5 files changed, 39 insertions(+), 17 deletions(-)

ACPI: Add acpi_interrupt_to_irq() interface.

ACPI interrupts and Linux IRQs need not be identical (though they are
on i386 and x86_64), so introduce acpi_interrupt_to_irq(), clean up
usage of "interrupt" and "irq", and remove IA64 #ifdefs.

=== drivers/acpi/osl.c 1.43 vs edited ==--- 1.43/drivers/acpi/osl.c	Mon Dec 29 14:37:24 2003
+++ edited/drivers/acpi/osl.c	Tue Jan 20 15:36:23 2004
@@ -240,23 +240,22 @@
 }
 
 acpi_status
-acpi_os_install_interrupt_handler(u32 irq, OSD_HANDLER handler, void *context)
+acpi_os_install_interrupt_handler(u32 interrupt, OSD_HANDLER handler, void *context)
 {
+	unsigned int irq;
+
 	/*
-	 * Ignore the irq from the core, and use the value in our copy of the
+	 * Ignore the interrupt from the core, and use the value in our copy of the
 	 * FADT. It may not be the same if an interrupt source override exists
 	 * for the SCI.
 	 */
-	irq = acpi_fadt.sci_int;
+	interrupt = acpi_fadt.sci_int;
 
-#ifdef CONFIG_IA64
-	irq = acpi_irq_to_vector(irq);
-	if (irq < 0) {
+	if (acpi_interrupt_to_irq(interrupt, &irq)) {
 		printk(KERN_ERR PREFIX "SCI (ACPI interrupt %d) not registered\n",
-		       acpi_fadt.sci_int);
+		       interrupt);
 		return AE_OK;
 	}
-#endif
 	acpi_irq_irq = irq;
 	acpi_irq_handler = handler;
 	acpi_irq_context = context;
@@ -269,12 +268,15 @@
 }
 
 acpi_status
-acpi_os_remove_interrupt_handler(u32 irq, OSD_HANDLER handler)
+acpi_os_remove_interrupt_handler(u32 interrupt, OSD_HANDLER handler)
 {
+	unsigned int irq;
+
 	if (acpi_irq_handler) {
-#ifdef CONFIG_IA64
-		irq = acpi_irq_to_vector(irq);
-#endif
+		if (acpi_interrupt_to_irq(interrupt, &irq)) {
+			printk(KERN_ERR PREFIX "Can't remove ACPI interrupt handler\n");
+			return AE_ERROR;
+		}
 		free_irq(irq, acpi_irq);
 		acpi_irq_handler = NULL;
 	}
=== include/asm-i386/acpi.h 1.9 vs edited ==--- 1.9/include/asm-i386/acpi.h	Tue Sep 16 11:21:55 2003
+++ edited/include/asm-i386/acpi.h	Tue Jan 20 15:33:24 2004
@@ -139,6 +139,12 @@
 
 #endif
 
+static inline int acpi_interrupt_to_irq(u32 interrupt, unsigned int *irq)
+{
+	*irq = interrupt;
+	return 0;
+}
+
 #ifdef CONFIG_ACPI_SLEEP
 
 /* routines for saving/restoring kernel state */
=== include/asm-x86_64/acpi.h 1.3 vs edited ==--- 1.3/include/asm-x86_64/acpi.h	Wed Dec 31 22:32:36 2003
+++ edited/include/asm-x86_64/acpi.h	Tue Jan 20 15:33:54 2004
@@ -120,6 +120,12 @@
 
 #endif /*CONFIG_ACPI_BOOT*/
 
+static inline int acpi_interrupt_to_irq(u32 interrupt, unsigned int *irq)
+{
+	*irq = interrupt;
+	return 0;
+}
+
 #ifdef CONFIG_ACPI_SLEEP
 
 /* routines for saving/restoring kernel state */
=== include/asm-ia64/acpi.h 1.13 vs edited ==--- 1.13/include/asm-ia64/acpi.h	Mon Jan 12 00:20:13 2004
+++ edited/include/asm-ia64/acpi.h	Tue Jan 20 15:35:01 2004
@@ -91,7 +91,7 @@
 const char *acpi_get_sysname (void);
 int acpi_request_vector (u32 int_type);
 int acpi_register_irq (u32 gsi, u32 polarity, u32 trigger);
-int acpi_irq_to_vector (u32 irq);
+int acpi_interrupt_to_irq (u32 interrupt, unsigned int *irq);
 
 #ifdef CONFIG_ACPI_NUMA
 /* Proximity bitmap length; _PXM is at most 255 (8 bit)*/
=== arch/ia64/kernel/acpi.c 1.59 vs edited ==--- 1.59/arch/ia64/kernel/acpi.c	Wed Jan 14 12:09:40 2004
+++ edited/arch/ia64/kernel/acpi.c	Tue Jan 20 15:32:41 2004
@@ -613,12 +613,20 @@
 }
 
 int
-acpi_irq_to_vector (u32 gsi)
+acpi_interrupt_to_irq (u32 interrupt, unsigned int *irq)
 {
-	if (has_8259 && gsi < 16)
-		return isa_irq_to_vector(gsi);
+	int vector;
 
-	return gsi_to_vector(gsi);
+	if (has_8259 && interrupt < 16)
+		vector = isa_irq_to_vector(interrupt);
+	else
+		vector = gsi_to_vector(interrupt);
+
+	if (vector < 0)
+		return -EINVAL;
+
+	*irq = vector;
+	return 0;
 }
 
 int

