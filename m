From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 23 Mar 2004 22:37:14 +0000
Subject: [RFC] ACPI IRQ proposal
Message-Id: <200403231537.14505.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: acpi-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org

I think the ACPI/platform interactions for IRQ setup are unnecessarily
complex.  Today we have:

    - boot-time parsing of all the _PRTs (platform subsys_initcall
      calls acpi_pci_irq_init(), which calls either mp_parse_prt()
      or iosapic_parse_prt() based on some #ifdefs).

    - pci_enable_device()-time IRQ enable (platform
      pcibios_enable_resources() calls acpi_pci_irq_enable(), which
      calls back to platform code, again based on some #ifdefs).

By defining a new platform interface, we should be able to get rid of
the boot-time _PRT parsing and do everything cleanly at
pci_enable_device()-time:

    int					/* Linux IRQ */
    acpi_register_gsi(int gsi,
		      int polarity,	/* active high or low */
		      int trigger)	/* edge or level */

This is responsible for whatever APIC or IOSAPIC programming the
platform needs, as well as allocating and returning a Linux IRQ.

By doing this, we get

    - possibility of hot-plugging a PCI root bridge (w/ _PRT)
    - removal of architecture #ifdefs from pci_irq.c and osl.c
    - removal of some Linux IRQ junk from acpi/pci_irq.c

If there are still some broken drivers that don't call pci_enable_device(),
we still have the option of putting a hook somewhere that just calls
acpi_pci_irq_enable() for all PCI devices.

Sample patch below only cleans up ia64; i386 and x86_64 looks a
little more complicated.  Any comments?

 arch/ia64/kernel/acpi.c    |   36 +----------
 arch/ia64/kernel/iosapic.c |   55 ------------------
 arch/ia64/pci/pci.c        |   13 ----
 drivers/acpi/osl.c         |   23 ++++---
 drivers/acpi/pci_irq.c     |  136 ++++++++++++++++-----------------------------
 drivers/pci/pci.c          |    5 +
 drivers/serial/8250_acpi.c |   13 ----
 drivers/serial/8250_hcdp.c |    6 -
 include/asm-ia64/acpi.h    |    3 
 include/linux/acpi.h       |    3 
 10 files changed, 79 insertions(+), 214 deletions(-)

=== arch/ia64/kernel/acpi.c 1.64 vs edited ==--- 1.64/arch/ia64/kernel/acpi.c	Fri Mar 12 05:32:11 2004
+++ edited/arch/ia64/kernel/acpi.c	Tue Mar 23 12:49:46 2004
@@ -529,7 +529,6 @@
 	if (fadt->iapc_boot_arch & BAF_LEGACY_DEVICES)
 		acpi_legacy_devices = 1;
 
-	acpi_register_irq(fadt->sci_int, ACPI_ACTIVE_LOW, ACPI_LEVEL_SENSITIVE);
 	return 0;
 }
 
@@ -626,43 +625,20 @@
 	return 0;
 }
 
-/* deprecated in favor of acpi_gsi_to_irq */
 int
-acpi_irq_to_vector (u32 gsi)
+acpi_register_gsi (u32 gsi, int polarity, int trigger)
 {
-	if (has_8259 && gsi < 16)
-		return isa_irq_to_vector(gsi);
-
-	return gsi_to_vector(gsi);
-}
+	unsigned int irq;
 
-int
-acpi_gsi_to_irq (u32 gsi, unsigned int *irq)
-{
-	int vector;
-
-	if (has_8259 && gsi < 16)
-		*irq = isa_irq_to_vector(gsi);
-	else {
-		vector = gsi_to_vector(gsi);
-		if (vector = -1)
-			return -1;
-
-		*irq = vector;
-	}
-	return 0;
-}
-
-int
-acpi_register_irq (u32 gsi, u32 polarity, u32 trigger)
-{
 	if (has_8259 && gsi < 16)
 		return isa_irq_to_vector(gsi);
 
-	return iosapic_register_intr(gsi,
+	irq = iosapic_register_intr(gsi,
 			(polarity = ACPI_ACTIVE_HIGH) ? IOSAPIC_POL_HIGH : IOSAPIC_POL_LOW,
 			(trigger = ACPI_EDGE_SENSITIVE) ? IOSAPIC_EDGE : IOSAPIC_LEVEL);
+	iosapic_enable_intr(irq);
+	return irq;
 }
-EXPORT_SYMBOL(acpi_register_irq);
+EXPORT_SYMBOL(acpi_register_gsi);
 
 #endif /* CONFIG_ACPI_BOOT */
=== arch/ia64/kernel/iosapic.c 1.36 vs edited ==--- 1.36/arch/ia64/kernel/iosapic.c	Thu Mar 11 00:26:39 2004
+++ edited/arch/ia64/kernel/iosapic.c	Tue Mar 23 10:36:21 2004
@@ -675,58 +675,3 @@
 	printk(KERN_INFO "IOSAPIC: vector %d -> CPU 0x%04x, enabled\n",
 	       vector, dest);
 }
-
-#ifdef CONFIG_ACPI_PCI
-
-void __init
-iosapic_parse_prt (void)
-{
-	struct acpi_prt_entry *entry;
-	struct list_head *node;
-	unsigned int gsi;
-	int vector;
-	char pci_id[16];
-	struct hw_interrupt_type *irq_type = &irq_type_iosapic_level;
-	irq_desc_t *idesc;
-
-	list_for_each(node, &acpi_prt.entries) {
-		entry = list_entry(node, struct acpi_prt_entry, node);
-
-		/* We're only interested in static (non-link) entries.  */
-		if (entry->link.handle)
-			continue;
-
-		gsi = entry->link.index;
-
-		vector = gsi_to_vector(gsi);
-		if (vector < 0) {
-			if (find_iosapic(gsi) < 0)
-				continue;
-
-			/* allocate a vector for this interrupt line */
-			if (pcat_compat && (gsi < 16))
-				vector = isa_irq_to_vector(gsi);
-			else
-				/* new GSI; allocate a vector for it */
-				vector = ia64_alloc_vector();
-
-			register_intr(gsi, vector, IOSAPIC_LOWEST_PRIORITY, IOSAPIC_POL_LOW,
-				      IOSAPIC_LEVEL);
-		}
-		entry->irq = vector;
-		snprintf(pci_id, sizeof(pci_id), "%02x:%02x:%02x[%c]",
-			 entry->id.segment, entry->id.bus, entry->id.device, 'A' + entry->pin);
-
-		/*
-		 * If vector was previously initialized to a different
-		 * handler, re-initialize.
-		 */
-		idesc = irq_descp(vector);
-		if (idesc->handler != irq_type)
-			register_intr(gsi, vector, IOSAPIC_LOWEST_PRIORITY, IOSAPIC_POL_LOW,
-				      IOSAPIC_LEVEL);
-
-	}
-}
-
-#endif /* CONFIG_ACPI */
=== arch/ia64/pci/pci.c 1.44 vs edited ==--- 1.44/arch/ia64/pci/pci.c	Fri Mar 19 15:17:58 2004
+++ edited/arch/ia64/pci/pci.c	Tue Mar 23 14:25:43 2004
@@ -156,18 +156,6 @@
 	.write = pci_write,
 };
 
-static int __init
-pci_acpi_init (void)
-{
-	if (!acpi_pci_irq_init())
-		printk(KERN_INFO "PCI: Using ACPI for IRQ routing\n");
-	else
-		printk(KERN_WARNING "PCI: Invalid ACPI-PCI IRQ routing table\n");
-	return 0;
-}
-
-subsys_initcall(pci_acpi_init);
-
 /* Called by ACPI when it finds a new root bus.  */
 
 static struct pci_controller * __devinit
@@ -440,7 +428,6 @@
 	if (ret < 0)
 		return ret;
 
-	printk(KERN_INFO "PCI: Found IRQ %d for device %s\n", dev->irq, pci_name(dev));
 	return acpi_pci_irq_enable(dev);
 }
 
=== drivers/acpi/osl.c 1.46 vs edited ==--- 1.46/drivers/acpi/osl.c	Sat Mar 13 02:11:01 2004
+++ edited/drivers/acpi/osl.c	Tue Mar 23 13:26:20 2004
@@ -36,6 +36,7 @@
 #include <linux/delay.h>
 #include <linux/workqueue.h>
 #include <linux/nmi.h>
+#include <linux/acpi.h>
 #include <acpi/acpi.h>
 #include <asm/io.h>
 #include <acpi/acpi_bus.h>
@@ -240,23 +241,24 @@
 }
 
 acpi_status
-acpi_os_install_interrupt_handler(u32 irq, OSD_HANDLER handler, void *context)
+acpi_os_install_interrupt_handler(u32 gsi, OSD_HANDLER handler, void *context)
 {
+	int irq;
+
 	/*
 	 * Ignore the irq from the core, and use the value in our copy of the
 	 * FADT. It may not be the same if an interrupt source override exists
 	 * for the SCI.
 	 */
-	irq = acpi_fadt.sci_int;
+	gsi = acpi_fadt.sci_int;
 
-#if defined(CONFIG_IA64) || defined(CONFIG_PCI_USE_VECTOR)
-	irq = acpi_irq_to_vector(irq);
+	irq = acpi_register_gsi(gsi, ACPI_ACTIVE_LOW, ACPI_LEVEL_SENSITIVE);
 	if (irq < 0) {
 		printk(KERN_ERR PREFIX "SCI (ACPI interrupt %d) not registered\n",
-		       acpi_fadt.sci_int);
+		       gsi);
 		return AE_OK;
 	}
-#endif
+
 	acpi_irq_handler = handler;
 	acpi_irq_context = context;
 	if (request_irq(irq, acpi_irq, SA_SHIRQ, "acpi", acpi_irq)) {
@@ -272,9 +274,12 @@
 acpi_os_remove_interrupt_handler(u32 irq, OSD_HANDLER handler)
 {
 	if (irq) {
-#if defined(CONFIG_IA64) || defined(CONFIG_PCI_USE_VECTOR)
-		irq = acpi_irq_to_vector(irq);
-#endif
+		/*
+		 * Probably should have something like
+		 * acpi_unregister_gsi() here so the platform can tear
+		 * down IOSAPIC setup for this GSI and deallocate the
+		 * associated Linux IRQ.
+		 */
 		free_irq(irq, acpi_irq);
 		acpi_irq_handler = NULL;
 		acpi_irq_irq = 0;
=== drivers/acpi/pci_irq.c 1.24 vs edited ==--- 1.24/drivers/acpi/pci_irq.c	Wed Feb  4 11:58:03 2004
+++ edited/drivers/acpi/pci_irq.c	Tue Mar 23 13:20:18 2004
@@ -237,12 +237,18 @@
                           PCI Interrupt Routing Support
    -------------------------------------------------------------------------- */
 
-int
-acpi_pci_irq_lookup (struct pci_bus *bus, int device, int pin)
+static int
+acpi_pci_gsi_lookup (
+	struct pci_bus		*bus,
+	int			device,
+	int			pin,
+	int			*polarity,
+	int			*trigger)
 {
 	struct acpi_prt_entry	*entry = NULL;
-	int segment = pci_domain_nr(bus);
-	int bus_nr = bus->number;
+	int			segment = pci_domain_nr(bus);
+	int			bus_nr = bus->number;
+	int			gsi;
 
 	ACPI_FUNCTION_TRACE("acpi_pci_irq_lookup");
 
@@ -256,31 +262,36 @@
 		return_VALUE(0);
 	}
 
-	if (!entry->irq && entry->link.handle) {
-		entry->irq = acpi_pci_link_get_irq(entry->link.handle, entry->link.index, NULL, NULL);
-		if (!entry->irq) {
+	if (entry->link.handle) {
+		gsi = acpi_pci_link_get_irq(entry->link.handle, entry->link.index, polarity, trigger);
+		if (!gsi) {
 			ACPI_DEBUG_PRINT((ACPI_DB_WARN, "Invalid IRQ link routing entry\n"));
 			return_VALUE(0);
 		}
 	}
-	else if (!entry->irq) {
-		ACPI_DEBUG_PRINT((ACPI_DB_INFO, "Invalid static routing entry (IRQ 0)\n"));
-		return_VALUE(0);
+	else {
+		gsi = entry->link.index;
+		*polarity = ACPI_ACTIVE_LOW;
+		*trigger = ACPI_LEVEL_SENSITIVE;
 	}
 
-	ACPI_DEBUG_PRINT((ACPI_DB_INFO, "Found IRQ %d\n", entry->irq));
+	ACPI_DEBUG_PRINT((ACPI_DB_INFO,
+		    "Found GSI 0x%x (active %s, %d triggered)\n", gsi,
+		    *polarity = ACPI_ACTIVE_LOW ? "low" : "high",
+		    *trigger = ACPI_LEVEL_SENSITIVE ? "level" : "edge"));
 
-	return_VALUE(entry->irq);
+	return_VALUE(gsi);
 }
 
-
 static int
-acpi_pci_irq_derive (
+acpi_pci_gsi_derive (
 	struct pci_dev		*dev,
-	int			pin)
+	int			pin,
+	int			*polarity,
+	int			*trigger)
 {
 	struct pci_dev		*bridge = dev;
-	int			irq = 0;
+	int			gsi = 0;
 
 	ACPI_FUNCTION_TRACE("acpi_pci_irq_derive");
 
@@ -288,24 +299,24 @@
 		return_VALUE(-EINVAL);
 
 	/* 
-	 * Attempt to derive an IRQ for this device from a parent bridge's
+	 * Attempt to derive a GSI for this device from a parent bridge's
 	 * PCI interrupt routing entry (a.k.a. the "bridge swizzle").
 	 */
-	while (!irq && bridge->bus->self) {
+	while (!gsi && bridge->bus->self) {
 		pin = (pin + PCI_SLOT(bridge->devfn)) % 4;
 		bridge = bridge->bus->self;
-		irq = acpi_pci_irq_lookup(bridge->bus,
-				PCI_SLOT(bridge->devfn), pin);
+		gsi = acpi_pci_gsi_lookup(bridge->bus,
+				PCI_SLOT(bridge->devfn), pin, polarity, trigger);
 	}
 
-	if (!irq) {
-		ACPI_DEBUG_PRINT((ACPI_DB_WARN, "Unable to derive IRQ for device %s\n", pci_name(dev)));
+	if (!gsi) {
+		ACPI_DEBUG_PRINT((ACPI_DB_WARN, "Unable to derive GSI for device %s\n", pci_name(dev)));
 		return_VALUE(0);
 	}
 
-	ACPI_DEBUG_PRINT((ACPI_DB_INFO, "Derived IRQ %d\n", irq));
+	ACPI_DEBUG_PRINT((ACPI_DB_INFO, "Derived GSI 0x%x\n", gsi));
 
-	return_VALUE(irq);
+	return_VALUE(gsi);
 }
 
 
@@ -313,8 +324,10 @@
 acpi_pci_irq_enable (
 	struct pci_dev		*dev)
 {
-	int			irq = 0;
+	int			gsi;
 	u8			pin = 0;
+	int			polarity = ACPI_ACTIVE_LOW;
+	int			trigger = ACPI_LEVEL_SENSITIVE;
 
 	ACPI_FUNCTION_TRACE("acpi_pci_irq_enable");
 
@@ -334,24 +347,24 @@
 	}
 
 	/* 
-	 * First we check the PCI IRQ routing table (PRT) for an IRQ.  PRT
+	 * First we check the PCI routing table (PRT) for a GSI.  PRT
 	 * values override any BIOS-assigned IRQs set during boot.
 	 */
- 	irq = acpi_pci_irq_lookup(dev->bus, PCI_SLOT(dev->devfn), pin);
+ 	gsi = acpi_pci_gsi_lookup(dev->bus, PCI_SLOT(dev->devfn), pin, &polarity, &trigger);
  
 	/*
-	 * If no PRT entry was found, we'll try to derive an IRQ from the
+	 * If no PRT entry was found, we'll try to derive a GSI from the
 	 * device's parent bridge.
 	 */
-	if (!irq)
- 		irq = acpi_pci_irq_derive(dev, pin);
+	if (!gsi)
+ 		gsi = acpi_pci_gsi_derive(dev, pin, &polarity, &trigger);
  
 	/*
 	 * No IRQ known to the ACPI subsystem - maybe the BIOS / 
 	 * driver reported one, then use it. Exit in any case.
 	 */
-	if (!irq) {
-		printk(KERN_WARNING PREFIX "No IRQ known for interrupt pin %c of device %s", ('A' + pin), pci_name(dev));
+	if (!gsi) {
+		printk(KERN_WARNING PREFIX "No GSI known for interrupt pin %c of device %s", ('A' + pin), pci_name(dev));
 		/* Interrupt Line values above 0xF are forbidden */
 		if (dev->irq && dev->irq >= 0xF) {
 			printk(" - using IRQ %d\n", dev->irq);
@@ -363,62 +376,13 @@
 		}
  	}
 
-	dev->irq = irq;
+	dev->irq = acpi_register_gsi(gsi, polarity, trigger);
 
 	ACPI_DEBUG_PRINT((ACPI_DB_INFO, "Device %s using IRQ %d\n", pci_name(dev), dev->irq));
-
-	/* 
-	 * Make sure all (legacy) PCI IRQs are set as level-triggered.
-	 */
-#ifdef CONFIG_X86
-	{
-		static u16 irq_mask;
-		if ((dev->irq < 16) &&  !((1 << dev->irq) & irq_mask)) {
-			ACPI_DEBUG_PRINT((ACPI_DB_INFO, "Setting IRQ %d as level-triggered\n", dev->irq));
-			irq_mask |= (1 << dev->irq);
-			eisa_set_level_irq(dev->irq);
-		}
-	}
-#endif
-#ifdef CONFIG_IOSAPIC
-	if (acpi_irq_model = ACPI_IRQ_MODEL_IOSAPIC)
-		iosapic_enable_intr(dev->irq);
-#endif
+	printk("Device %s[%c] using GSI 0x%x -> IRQ %d (active %s, %s triggered)\n",
+		pci_name(dev), 'A' + pin, gsi, dev->irq,
+		polarity = ACPI_ACTIVE_LOW ? "low" : "high",
+		trigger = ACPI_LEVEL_SENSITIVE ? "level" : "edge");
 
 	return_VALUE(dev->irq);
-}
-
-
-int __init
-acpi_pci_irq_init (void)
-{
-	struct pci_dev          *dev = NULL;
-
-	ACPI_FUNCTION_TRACE("acpi_pci_irq_init");
-
-	if (!acpi_prt.count) {
-		printk(KERN_WARNING PREFIX "ACPI tables contain no PCI IRQ "
-			"routing entries\n");
-		return_VALUE(-ENODEV);
-	}
-
-	/* Make sure all link devices have a valid IRQ. */
-	if (acpi_pci_link_check()) {
-		return_VALUE(-ENODEV);
-	}
-
-#ifdef CONFIG_X86_IO_APIC
-	/* Program IOAPICs using data from PRT entries. */
-	if (acpi_irq_model = ACPI_IRQ_MODEL_IOAPIC)
-		mp_parse_prt();
-#endif
-#ifdef CONFIG_IOSAPIC
-	if (acpi_irq_model = ACPI_IRQ_MODEL_IOSAPIC)
-		iosapic_parse_prt();
-#endif
-
-	while ((dev = pci_find_device(PCI_ANY_ID, PCI_ANY_ID, dev)) != NULL)
-		acpi_pci_irq_enable(dev);
-
-	return_VALUE(0);
 }
=== drivers/pci/pci.c 1.63 vs edited ==--- 1.63/drivers/pci/pci.c	Sun Mar 14 12:17:06 2004
+++ edited/drivers/pci/pci.c	Tue Mar 23 13:18:26 2004
@@ -363,6 +363,11 @@
 		pci_command &= ~PCI_COMMAND_MASTER;
 		pci_write_config_word(dev, PCI_COMMAND, pci_command);
 	}
+
+	/*
+	 * Probably should have a pcibios_disable_device() so the
+	 * architecture can undo any IRQ setup.
+	 */
 }
 
 /**
=== drivers/serial/8250_acpi.c 1.8 vs edited ==--- 1.8/drivers/serial/8250_acpi.c	Mon Mar 15 15:53:32 2004
+++ edited/drivers/serial/8250_acpi.c	Tue Mar 23 13:16:48 2004
@@ -59,12 +59,8 @@
 				       struct acpi_resource_ext_irq *ext_irq)
 {
 	if (ext_irq->number_of_interrupts > 0) {
-#ifdef CONFIG_IA64
-		req->irq = acpi_register_irq(ext_irq->interrupts[0],
+		req->irq = acpi_register_gsi(ext_irq->interrupts[0],
 	                  ext_irq->active_high_low, ext_irq->edge_level);
-#else
-		req->irq = ext_irq->interrupts[0];
-#endif
 	}
 	return AE_OK;
 }
@@ -73,12 +69,8 @@
 				   struct acpi_resource_irq *irq)
 {
 	if (irq->number_of_interrupts > 0) {
-#ifdef CONFIG_IA64
-		req->irq = acpi_register_irq(irq->interrupts[0],
+		req->irq = acpi_register_gsi(irq->interrupts[0],
 	                  irq->active_high_low, irq->edge_level);
-#else
-		req->irq = irq->interrupts[0];
-#endif
 	}
 	return AE_OK;
 }
@@ -164,6 +156,7 @@
 
 	priv = acpi_driver_data(device);
 	unregister_serial(priv->line);
+	/* Probably should undo acpi_register_gsi() here */
 	if (priv->iomem_base)
 		iounmap(priv->iomem_base);
 	kfree(priv);
=== drivers/serial/8250_hcdp.c 1.3 vs edited ==--- 1.3/drivers/serial/8250_hcdp.c	Mon Mar 15 15:53:32 2004
+++ edited/drivers/serial/8250_hcdp.c	Tue Mar 23 12:53:29 2004
@@ -179,12 +179,6 @@
 			printk(KERN_WARNING"warning: No support for PCI serial console\n");
 			return;
 		}
-#ifdef CONFIG_IA64
-		port.irq = acpi_register_irq(gsi, ACPI_ACTIVE_HIGH,
-				ACPI_EDGE_SENSITIVE);
-#else
-		port.irq = gsi;
-#endif
 		port.flags = UPF_SKIP_TEST | UPF_BOOT_AUTOCONF | UPF_RESOURCES;
 
 		/*
=== include/asm-ia64/acpi.h 1.15 vs edited ==--- 1.15/include/asm-ia64/acpi.h	Fri Mar 12 05:32:41 2004
+++ edited/include/asm-ia64/acpi.h	Tue Mar 23 12:42:44 2004
@@ -92,9 +92,6 @@
 
 const char *acpi_get_sysname (void);
 int acpi_request_vector (u32 int_type);
-int acpi_register_irq (u32 gsi, u32 polarity, u32 trigger);
-int acpi_irq_to_vector (u32 irq); /* deprecated in favor of acpi_gsi_to_irq */
-int acpi_gsi_to_irq (u32 gsi, unsigned int *irq);
 
 #ifdef CONFIG_ACPI_NUMA
 /* Proximity bitmap length; _PXM is at most 255 (8 bit)*/
=== include/linux/acpi.h 1.32 vs edited ==--- 1.32/include/linux/acpi.h	Mon Mar  1 01:26:35 2004
+++ edited/include/linux/acpi.h	Tue Mar 23 12:39:44 2004
@@ -424,7 +424,6 @@
 		acpi_handle		handle;
 		u32			index;
 	}			link;
-	u32			irq;
 };
 
 struct acpi_prt_list {
@@ -437,7 +436,7 @@
 struct pci_dev;
 
 int acpi_pci_irq_enable (struct pci_dev *dev);
-int acpi_pci_irq_init (void);
+int acpi_register_gsi (u32 gsi, int polarity, int trigger);
 
 struct acpi_pci_driver {
 	struct acpi_pci_driver *next;
