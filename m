From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 21 Jan 2004 00:12:12 +0000
Subject: [PATCH] add acpi_register_interrupt
Message-Id: <200401201712.12441.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: acpi-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Len Brown <len.brown-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

This patch is against 2.6.1 + the previous "acpi_interrupt_to_irq" patch.
It adds another generic function needed to remove a couple more
IA64 #ifdefs.

 arch/i386/kernel/acpi/boot.c   |    8 ++++++++
 arch/ia64/kernel/acpi.c        |   14 +++++++-------
 arch/x86_64/kernel/acpi/boot.c |    8 ++++++++
 drivers/serial/8250_acpi.c     |   18 ++++--------------
 drivers/serial/8250_hcdp.c     |    6 +-----
 include/asm-i386/acpi.h        |    2 ++
 include/asm-ia64/acpi.h        |    2 +-
 include/asm-x86_64/acpi.h      |    2 ++
 8 files changed, 33 insertions(+), 27 deletions(-)

ACPI: Add acpi_register_interrupt().

For interrupts not described by PCI routing tables, we need a platform
hook to set up the IOSAPIC.  We've been using "acpi_register_irq" on
IA64, but I think that's a bit of a misnomer because we supply an ACPI
interrupt (either an ISA IRQ or a GSI) and get back a Linux IRQ.

So this patch adds acpi_register_interrupt() for ia64, i386, and
x86_64, and removes a couple IA64 #ifdefs.

diff -Nru a/arch/i386/kernel/acpi/boot.c b/arch/i386/kernel/acpi/boot.c
--- a/arch/i386/kernel/acpi/boot.c	Tue Jan 20 17:02:44 2004
+++ b/arch/i386/kernel/acpi/boot.c	Tue Jan 20 17:02:44 2004
@@ -528,3 +528,11 @@
 
 	return 0;
 }
+
+unsigned int
+acpi_register_interrupt(u32 interrupt, u32 polarity, u32 trigger)
+{
+	return interrupt;
+}
+
+EXPORT_SYMBOL(acpi_register_interrupt);
diff -Nru a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
--- a/arch/ia64/kernel/acpi.c	Tue Jan 20 17:02:44 2004
+++ b/arch/ia64/kernel/acpi.c	Tue Jan 20 17:02:44 2004
@@ -515,7 +515,7 @@
 	if (fadt->iapc_boot_arch & BAF_LEGACY_DEVICES)
 		acpi_legacy_devices = 1;
 
-	acpi_register_irq(fadt->sci_int, ACPI_ACTIVE_LOW, ACPI_LEVEL_SENSITIVE);
+	acpi_register_interrupt(fadt->sci_int, ACPI_ACTIVE_LOW, ACPI_LEVEL_SENSITIVE);
 	return 0;
 }
 
@@ -629,16 +629,16 @@
 	return 0;
 }
 
-int
-acpi_register_irq (u32 gsi, u32 polarity, u32 trigger)
+unsigned int
+acpi_register_interrupt (u32 interrupt, u32 polarity, u32 trigger)
 {
-	if (has_8259 && gsi < 16)
-		return isa_irq_to_vector(gsi);
+	if (has_8259 && interrupt < 16)
+		return isa_irq_to_vector(interrupt);
 
-	return iosapic_register_intr(gsi,
+	return iosapic_register_intr(interrupt,
 			(polarity = ACPI_ACTIVE_HIGH) ? IOSAPIC_POL_HIGH : IOSAPIC_POL_LOW,
 			(trigger = ACPI_EDGE_SENSITIVE) ? IOSAPIC_EDGE : IOSAPIC_LEVEL);
 }
-EXPORT_SYMBOL(acpi_register_irq);
+EXPORT_SYMBOL(acpi_register_interrupt);
 
 #endif /* CONFIG_ACPI_BOOT */
diff -Nru a/arch/x86_64/kernel/acpi/boot.c b/arch/x86_64/kernel/acpi/boot.c
--- a/arch/x86_64/kernel/acpi/boot.c	Tue Jan 20 17:02:44 2004
+++ b/arch/x86_64/kernel/acpi/boot.c	Tue Jan 20 17:02:44 2004
@@ -502,5 +502,13 @@
 	return 0;
 }
 
+unsigned int
+acpi_register_interrupt(u32 interrupt, u32 polarity, u32 trigger)
+{
+	return interrupt;
+}
+
+EXPORT_SYMBOL(acpi_register_interrupt);
+
 #endif /*CONFIG_ACPI_BOOT*/
 
diff -Nru a/drivers/serial/8250_acpi.c b/drivers/serial/8250_acpi.c
--- a/drivers/serial/8250_acpi.c	Tue Jan 20 17:02:44 2004
+++ b/drivers/serial/8250_acpi.c	Tue Jan 20 17:02:44 2004
@@ -58,28 +58,18 @@
 static acpi_status acpi_serial_ext_irq(struct serial_struct *req,
 				       struct acpi_resource_ext_irq *ext_irq)
 {
-	if (ext_irq->number_of_interrupts > 0) {
-#ifdef CONFIG_IA64
-		req->irq = acpi_register_irq(ext_irq->interrupts[0],
+	if (ext_irq->number_of_interrupts > 0)
+		req->irq = acpi_register_interrupt(ext_irq->interrupts[0],
 	                  ext_irq->active_high_low, ext_irq->edge_level);
-#else
-		req->irq = ext_irq->interrupts[0];
-#endif
-	}
 	return AE_OK;
 }
 
 static acpi_status acpi_serial_irq(struct serial_struct *req,
 				   struct acpi_resource_irq *irq)
 {
-	if (irq->number_of_interrupts > 0) {
-#ifdef CONFIG_IA64
-		req->irq = acpi_register_irq(irq->interrupts[0],
+	if (irq->number_of_interrupts > 0)
+		req->irq = acpi_register_interrupt(irq->interrupts[0],
 	                  irq->active_high_low, irq->edge_level);
-#else
-		req->irq = irq->interrupts[0];
-#endif
-	}
 	return AE_OK;
 }
 
diff -Nru a/drivers/serial/8250_hcdp.c b/drivers/serial/8250_hcdp.c
--- a/drivers/serial/8250_hcdp.c	Tue Jan 20 17:02:44 2004
+++ b/drivers/serial/8250_hcdp.c	Tue Jan 20 17:02:44 2004
@@ -179,12 +179,8 @@
 			printk(KERN_WARNING"warning: No support for PCI serial console\n");
 			return;
 		}
-#ifdef CONFIG_IA64
-		port.irq = acpi_register_irq(gsi, ACPI_ACTIVE_HIGH,
+		port.irq = acpi_register_interrupt(gsi, ACPI_ACTIVE_HIGH,
 				ACPI_EDGE_SENSITIVE);
-#else
-		port.irq = gsi;
-#endif
 		port.flags = UPF_SKIP_TEST | UPF_BOOT_AUTOCONF | UPF_RESOURCES;
 		if (gsi)
 			port.flags |= ASYNC_AUTO_IRQ;
diff -Nru a/include/asm-i386/acpi.h b/include/asm-i386/acpi.h
--- a/include/asm-i386/acpi.h	Tue Jan 20 17:02:44 2004
+++ b/include/asm-i386/acpi.h	Tue Jan 20 17:02:44 2004
@@ -139,6 +139,8 @@
 
 #endif
 
+unsigned int acpi_register_interrupt(u32 interrupt, u32 polarity, u32 trigger);
+
 static inline int acpi_interrupt_to_irq(u32 interrupt, unsigned int *irq)
 {
 	*irq = interrupt;
diff -Nru a/include/asm-ia64/acpi.h b/include/asm-ia64/acpi.h
--- a/include/asm-ia64/acpi.h	Tue Jan 20 17:02:44 2004
+++ b/include/asm-ia64/acpi.h	Tue Jan 20 17:02:44 2004
@@ -90,7 +90,7 @@
 
 const char *acpi_get_sysname (void);
 int acpi_request_vector (u32 int_type);
-int acpi_register_irq (u32 gsi, u32 polarity, u32 trigger);
+unsigned int acpi_register_interrupt (u32 gsi, u32 polarity, u32 trigger);
 int acpi_interrupt_to_irq (u32 interrupt, unsigned int *irq);
 
 #ifdef CONFIG_ACPI_NUMA
diff -Nru a/include/asm-x86_64/acpi.h b/include/asm-x86_64/acpi.h
--- a/include/asm-x86_64/acpi.h	Tue Jan 20 17:02:44 2004
+++ b/include/asm-x86_64/acpi.h	Tue Jan 20 17:02:44 2004
@@ -120,6 +120,8 @@
 
 #endif /*CONFIG_ACPI_BOOT*/
 
+unsigned int acpi_register_interrupt(u32 interrupt, u32 polarity, u32 trigger);
+
 static inline int acpi_interrupt_to_irq(u32 interrupt, unsigned int *irq)
 {
 	*irq = interrupt;

