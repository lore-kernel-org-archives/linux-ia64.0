From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 20 Apr 2004 14:46:39 +0000
Subject: Re: [PATCH][RFC] Vector sharing
Message-Id: <200404200846.39749.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <MDEEKOKJPMPMKGHIFAMAOENCDMAA.kaneshige.kenji@jp.fujitsu.com>
In-Reply-To: <MDEEKOKJPMPMKGHIFAMAOENCDMAA.kaneshige.kenji@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday 20 April 2004 6:25 am, Jean-Francois Neyroud wrote:
> Kenji Kaneshige wrote:
> >I'm trying to make a patch that allows device vectors to be shared by
> >multiple interrupt sources. This patch enables ia64 linux to boot on
> >the machine that has single vector number space and many device
> >interrupt sources (more than 184).
> 
> An other or complementary way is to attach a vector only for interrupt
> lines witch are used, PCI slots have 4 interrupt lines but only 1 or
> sometime 2 are used by adapters.

I have a patch in the works that will clean up ACPI _PRT handling
(it removes the boot-time _PRT parsing and does the IOSAPIC setup
at pci_enable_device()-time).  One side effect is that we only set
up vectors for interrupt lines actually used.

The attached patch is the current status.  It's been tested on
a few ia64 configs, but I think there are some x86 wrinkles that
I still need to work out, so this is just FYI, in case anybody
wants to give it a whirl.

Bjorn

=== arch/i386/kernel/mpparse.c 1.69 vs edited ==--- 1.69/arch/i386/kernel/mpparse.c	Mon Mar 22 14:00:03 2004
+++ edited/arch/i386/kernel/mpparse.c	Tue Apr 13 11:10:37 2004
@@ -1036,93 +1036,58 @@
 
 extern FADT_DESCRIPTOR acpi_fadt;
 
-#ifdef CONFIG_ACPI_PCI
+#endif /*CONFIG_X86_IO_APIC && CONFIG_ACPI_INTERPRETER*/
+
+#ifdef CONFIG_X86_IO_APIC
 
-void __init mp_parse_prt (void)
+void mp_register_gsi (u32 gsi, int edge_level, int active_high_low)
 {
-	struct list_head	*node = NULL;
-	struct acpi_prt_entry	*entry = NULL;
 	int			ioapic = -1;
 	int			ioapic_pin = 0;
-	int			gsi = 0;
 	int			idx, bit = 0;
-	int			edge_level = 0;
-	int			active_high_low = 0;
 
-	/*
-	 * Parsing through the PCI Interrupt Routing Table (PRT) and program
-	 * routing for all entries.
-	 */
-	list_for_each(node, &acpi_prt.entries) {
-		entry = list_entry(node, struct acpi_prt_entry, node);
+	/* Don't set up the ACPI SCI because it's already set up */
+	if (acpi_fadt.sci_int = gsi)
+		return;
+
+	ioapic = mp_find_ioapic(gsi);
+	if (ioapic < 0) {
+		printk(KERN_WARNING "No IOAPIC for GSI 0x%x\n", gsi);
+		return;
+	}
+
+	ioapic_pin = gsi - mp_ioapic_routing[ioapic].gsi_base;
 
-		/* Need to get gsi for dynamic entry */
-		if (entry->link.handle) {
-			gsi = acpi_pci_link_get_irq(entry->link.handle, entry->link.index, &edge_level, &active_high_low);
-			if (!gsi)
-				continue;
-		}
-		else {
-			/* Hardwired GSI. Assume PCI standard settings */
-			gsi = entry->link.index;
-			edge_level = 1;
-			active_high_low = 1;
-		}
-
-		/* Don't set up the ACPI SCI because it's already set up */
-                if (acpi_fadt.sci_int = gsi) {
-			/* we still need to set entry's irq */
-			acpi_gsi_to_irq(gsi, &entry->irq);
-			continue;
-                }
-	
-		ioapic = mp_find_ioapic(gsi);
-		if (ioapic < 0)
-			continue;
-		ioapic_pin = gsi - mp_ioapic_routing[ioapic].gsi_base;
-
-		if (es7000_plat) {
-			if (!ioapic && (gsi < 16))
-				gsi += 16;
-		}
-
-		/* 
-		 * Avoid pin reprogramming.  PRTs typically include entries  
-		 * with redundant pin->gsi mappings (but unique PCI devices);
-		 * we only only program the IOAPIC on the first.
-		 */
-		bit = ioapic_pin % 32;
-		idx = (ioapic_pin < 32) ? 0 : (ioapic_pin / 32);
-		if (idx > 3) {
-			printk(KERN_ERR "Invalid reference to IOAPIC pin "
-				"%d-%d\n", mp_ioapic_routing[ioapic].apic_id, 
-				ioapic_pin);
-			continue;
-		}
-		if ((1<<bit) & mp_ioapic_routing[ioapic].pin_programmed[idx]) {
-			Dprintk(KERN_DEBUG "Pin %d-%d already programmed\n",
-				mp_ioapic_routing[ioapic].apic_id, ioapic_pin);
-			acpi_gsi_to_irq(gsi, &entry->irq);
-			continue;
-		}
-
-		mp_ioapic_routing[ioapic].pin_programmed[idx] |= (1<<bit);
-
-		if (!io_apic_set_pci_routing(ioapic, ioapic_pin, gsi, edge_level, active_high_low)) {
-			acpi_gsi_to_irq(gsi, &entry->irq);
-		}
-		printk(KERN_DEBUG "%02x:%02x:%02x[%c] -> %d-%d -> IRQ %d\n",
-			entry->id.segment, entry->id.bus,
-			entry->id.device, ('A' + entry->pin),
-			mp_ioapic_routing[ioapic].apic_id, ioapic_pin,
-			entry->irq);
+	if (es7000_plat) {
+		if (!ioapic && (gsi < 16))
+			gsi += 16;
 	}
 
-	print_IO_APIC();
+	/* 
+	 * Avoid pin reprogramming.  PRTs typically include entries  
+	 * with redundant pin->gsi mappings (but unique PCI devices);
+	 * we only only program the IOAPIC on the first.
+	 */
+	bit = ioapic_pin % 32;
+	idx = (ioapic_pin < 32) ? 0 : (ioapic_pin / 32);
+	if (idx > 3) {
+		printk(KERN_ERR "Invalid reference to IOAPIC pin "
+			"%d-%d\n", mp_ioapic_routing[ioapic].apic_id, 
+			ioapic_pin);
+		return;
+	}
+	if ((1<<bit) & mp_ioapic_routing[ioapic].pin_programmed[idx]) {
+		Dprintk(KERN_DEBUG "Pin %d-%d already programmed\n",
+			mp_ioapic_routing[ioapic].apic_id, ioapic_pin);
+		return;
+	}
 
-	return;
+	mp_ioapic_routing[ioapic].pin_programmed[idx] |= (1<<bit);
+
+	io_apic_set_pci_routing(ioapic, ioapic_pin, gsi,
+		    edge_level = ACPI_EDGE_SENSITIVE ? 0 : 1,
+		    active_high_low = ACPI_ACTIVE_HIGH ? 0 : 1);
 }
 
-#endif /*CONFIG_ACPI_PCI*/
-#endif /*CONFIG_X86_IO_APIC && CONFIG_ACPI_INTERPRETER*/
+#endif /*CONFIG_X86_IO_APIC*/
 #endif /*CONFIG_ACPI_BOOT*/
=== arch/i386/kernel/acpi/boot.c 1.57 vs edited ==--- 1.57/arch/i386/kernel/acpi/boot.c	Tue Mar 30 15:05:19 2004
+++ edited/arch/i386/kernel/acpi/boot.c	Tue Apr 13 16:09:50 2004
@@ -425,6 +425,28 @@
 	return 0;
 }
 
+unsigned int acpi_register_gsi(u32 gsi, int edge_level, int active_high_low)
+{
+	static u16 irq_mask;
+	unsigned int irq;
+	extern void eisa_set_level_irq(unsigned int irq);
+
+	/*
+	 * Make sure all (legacy) PCI IRQs are set as level-triggered.
+	 */
+	if ((gsi < 16) && !((1 << gsi) & irq_mask)) {
+		printk(KERN_DEBUG PREFIX "Setting GSI 0x%x as level-triggered\n", gsi);
+		irq_mask |= (1 << gsi);
+		eisa_set_level_irq(gsi);
+	}
+
+#ifdef CONFIG_X86_IO_APIC
+	mp_register_gsi(gsi, edge_level, active_high_low);
+#endif
+	acpi_gsi_to_irq(gsi, &irq);
+	return irq;
+}
+
 static unsigned long __init
 acpi_scan_rsdp (
 	unsigned long		start,
=== arch/i386/pci/acpi.c 1.12 vs edited ==--- 1.12/arch/i386/pci/acpi.c	Thu Dec 11 19:19:07 2003
+++ edited/arch/i386/pci/acpi.c	Tue Apr 13 17:42:01 2004
@@ -18,16 +18,16 @@
 	if (pcibios_scanned)
 		return 0;
 
-	if (!acpi_noirq) {
-		if (!acpi_pci_irq_init()) {
-			printk(KERN_INFO "PCI: Using ACPI for IRQ routing\n");
-			printk(KERN_INFO "PCI: if you experience problems, try using option 'pci=noacpi' or even 'acpi=off'\n");
-			pcibios_scanned++;
-			pcibios_enable_irq = acpi_pci_irq_enable;
-		} else
-			printk(KERN_WARNING "PCI: Invalid ACPI-PCI IRQ routing table\n");
+	if (acpi_noirq)
+		return 0;
 
-	}
+	printk(KERN_INFO "PCI: Using ACPI for IRQ routing\n");
+	printk(KERN_INFO "PCI: if you experience problems, try using option 'pci=noacpi' or even 'acpi=off'\n");
+	if (!acpi_pci_irq_init()) {
+		pcibios_scanned++;
+		pcibios_enable_irq = acpi_pci_irq_enable;
+	} else
+		printk(KERN_WARNING "PCI: Invalid ACPI-PCI IRQ routing table\n");
 
 	return 0;
 }
=== arch/ia64/kernel/acpi.c 1.68 vs edited ==--- 1.68/arch/ia64/kernel/acpi.c	Thu Apr  8 19:30:12 2004
+++ edited/arch/ia64/kernel/acpi.c	Tue Apr 13 10:50:16 2004
@@ -508,9 +508,14 @@
 #endif /* CONFIG_ACPI_NUMA */
 
 unsigned int
-acpi_register_gsi (u32 gsi, int polarity, int trigger)
+acpi_register_gsi (u32 gsi, int edge_level, int active_high_low)
 {
-	return acpi_register_irq(gsi, polarity, trigger);
+	if (has_8259 && gsi < 16)
+		return isa_irq_to_vector(gsi);
+
+	return iosapic_register_intr(gsi,
+			(active_high_low = ACPI_ACTIVE_HIGH) ? IOSAPIC_POL_HIGH : IOSAPIC_POL_LOW,
+			(edge_level = ACPI_EDGE_SENSITIVE) ? IOSAPIC_EDGE : IOSAPIC_LEVEL);
 }
 EXPORT_SYMBOL(acpi_register_gsi);
 
@@ -535,7 +540,7 @@
 	if (fadt->iapc_boot_arch & BAF_LEGACY_DEVICES)
 		acpi_legacy_devices = 1;
 
-	acpi_register_gsi(fadt->sci_int, ACPI_ACTIVE_LOW, ACPI_LEVEL_SENSITIVE);
+	acpi_register_gsi(fadt->sci_int, ACPI_LEVEL_SENSITIVE, ACPI_ACTIVE_LOW);
 	return 0;
 }
 
@@ -658,17 +663,5 @@
 	}
 	return 0;
 }
-
-int
-acpi_register_irq (u32 gsi, u32 polarity, u32 trigger)
-{
-	if (has_8259 && gsi < 16)
-		return isa_irq_to_vector(gsi);
-
-	return iosapic_register_intr(gsi,
-			(polarity = ACPI_ACTIVE_HIGH) ? IOSAPIC_POL_HIGH : IOSAPIC_POL_LOW,
-			(trigger = ACPI_EDGE_SENSITIVE) ? IOSAPIC_EDGE : IOSAPIC_LEVEL);
-}
-EXPORT_SYMBOL(acpi_register_irq);
 
 #endif /* CONFIG_ACPI_BOOT */
=== arch/ia64/pci/pci.c 1.47 vs edited ==--- 1.47/arch/ia64/pci/pci.c	Mon Apr 12 19:50:46 2004
+++ edited/arch/ia64/pci/pci.c	Tue Apr 13 10:58:44 2004
@@ -158,18 +158,6 @@
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
=== arch/x86_64/kernel/mpparse.c 1.25 vs edited ==--- 1.25/arch/x86_64/kernel/mpparse.c	Mon Apr 12 11:53:56 2004
+++ edited/arch/x86_64/kernel/mpparse.c	Tue Apr 13 11:11:01 2004
@@ -894,84 +894,48 @@
 
 extern FADT_DESCRIPTOR acpi_fadt;
 
-#ifdef CONFIG_ACPI_PCI
-
-void __init mp_parse_prt (void)
+void mp_register_gsi (u32 gsi, int edge_level, int active_high_low)
 {
-	struct list_head	*node = NULL;
-	struct acpi_prt_entry	*entry = NULL;
 	int			ioapic = -1;
 	int			ioapic_pin = 0;
-	int			gsi = 0;
 	int			idx, bit = 0;
-	int			edge_level = 0;
-	int			active_high_low = 0;
-
-	/*
-	 * Parsing through the PCI Interrupt Routing Table (PRT) and program
-	 * routing for all static (IOAPIC-direct) entries.
-	 */
-	list_for_each(node, &acpi_prt.entries) {
-		entry = list_entry(node, struct acpi_prt_entry, node);
-
-		/* Need to get gsi for dynamic entry */
-		if (entry->link.handle) {
-			gsi = acpi_pci_link_get_irq(entry->link.handle, entry->link.index, &edge_level, &active_high_low);
-			if (!gsi)
-				continue;
-		} else {
-			/* Hardwired GSI. Assume PCI standard settings */
-			gsi = entry->link.index;
-			edge_level = 1;
-			active_high_low = 1;
-		}
-
-		/* Don't set up the ACPI SCI because it's already set up */
-		if (acpi_fadt.sci_int = gsi)
-			continue;
 
-		ioapic = mp_find_ioapic(gsi);
-		if (ioapic < 0)
-			continue;
-		ioapic_pin = gsi - mp_ioapic_routing[ioapic].gsi_start;
+	/* Don't set up the ACPI SCI because it's already set up */
+	if (acpi_fadt.sci_int = gsi)
+		return;
+
+	ioapic = mp_find_ioapic(gsi);
+	if (ioapic < 0) {
+		printk(KERN_WARNING "No IOAPIC for GSI 0x%x\n", gsi);
+		return;
+	}
 
-		/* 
-		 * Avoid pin reprogramming.  PRTs typically include entries  
-		 * with redundant pin->gsi mappings (but unique PCI devices);
-		 * we only only program the IOAPIC on the first.
-		 */
-		bit = ioapic_pin % 32;
-		idx = (ioapic_pin < 32) ? 0 : (ioapic_pin / 32);
-		if (idx > 3) {
-			printk(KERN_ERR "Invalid reference to IOAPIC pin "
-				"%d-%d\n", mp_ioapic_routing[ioapic].apic_id, 
-				ioapic_pin);
-			continue;
-		}
-		if ((1<<bit) & mp_ioapic_routing[ioapic].pin_programmed[idx]) {
-			Dprintk(KERN_DEBUG "Pin %d-%d already programmed\n",
-				mp_ioapic_routing[ioapic].apic_id, ioapic_pin);
-			acpi_gsi_to_irq(gsi, &entry->irq);
-			continue;
-		}
+	ioapic_pin = gsi - mp_ioapic_routing[ioapic].gsi_start;
 
-		mp_ioapic_routing[ioapic].pin_programmed[idx] |= (1<<bit);
-		if (!io_apic_set_pci_routing(ioapic, ioapic_pin, gsi, edge_level, active_high_low)) {
-			acpi_gsi_to_irq(gsi, &entry->irq);
- 		}
-		printk(KERN_DEBUG "%02x:%02x:%02x[%c] -> %d-%d -> IRQ %d\n",
-			entry->id.segment, entry->id.bus,
-			entry->id.device, ('A' + entry->pin), 
-			mp_ioapic_routing[ioapic].apic_id, ioapic_pin,
-			entry->irq);
+	/* 
+	 * Avoid pin reprogramming.  PRTs typically include entries  
+	 * with redundant pin->gsi mappings (but unique PCI devices);
+	 * we only only program the IOAPIC on the first.
+	 */
+	bit = ioapic_pin % 32;
+	idx = (ioapic_pin < 32) ? 0 : (ioapic_pin / 32);
+	if (idx > 3) {
+		printk(KERN_ERR "Invalid reference to IOAPIC pin "
+			"%d-%d\n", mp_ioapic_routing[ioapic].apic_id, 
+			ioapic_pin);
+		return;
+	}
+	if ((1<<bit) & mp_ioapic_routing[ioapic].pin_programmed[idx]) {
+		Dprintk(KERN_DEBUG "Pin %d-%d already programmed\n",
+			mp_ioapic_routing[ioapic].apic_id, ioapic_pin);
+		return;
 	}
-	
-	print_IO_APIC();
 
-	return;
+	mp_ioapic_routing[ioapic].pin_programmed[idx] |= (1<<bit);
+	io_apic_set_pci_routing(ioapic, ioapic_pin, gsi,
+		edge_level = ACPI_EDGE_SENSITIVE ? 0 : 1,
+		active_high_low = ACPI_ACTIVE_HIGH ? 0 : 1);
 }
-
-#endif /*CONFIG_ACPI_PCI*/
 
 #endif /*CONFIG_X86_IO_APIC*/
 
=== drivers/acpi/pci_irq.c 1.26 vs edited ==--- 1.26/drivers/acpi/pci_irq.c	Thu Apr  1 02:03:21 2004
+++ edited/drivers/acpi/pci_irq.c	Tue Apr 13 16:16:08 2004
@@ -35,12 +35,6 @@
 #include <linux/pm.h>
 #include <linux/pci.h>
 #include <linux/acpi.h>
-#ifdef CONFIG_X86_IO_APIC
-#include <asm/mpspec.h>
-#endif
-#ifdef CONFIG_IOSAPIC
-# include <asm/iosapic.h>
-#endif
 #include <acpi/acpi_bus.h>
 #include <acpi/acpi_drivers.h>
 
@@ -50,10 +44,6 @@
 
 struct acpi_prt_list		acpi_prt;
 
-#ifdef CONFIG_X86
-extern void eisa_set_level_irq(unsigned int irq);
-#endif
-
 
 /* --------------------------------------------------------------------------
                          PCI IRQ Routing Table (PRT) Support
@@ -237,12 +227,18 @@
                           PCI Interrupt Routing Support
    -------------------------------------------------------------------------- */
 
-int
-acpi_pci_irq_lookup (struct pci_bus *bus, int device, int pin)
+static int
+acpi_pci_irq_lookup (
+	struct pci_bus		*bus,
+	int			device,
+	int			pin,
+	int			*edge_level,
+	int			*active_high_low)
 {
 	struct acpi_prt_entry	*entry = NULL;
 	int segment = pci_domain_nr(bus);
 	int bus_nr = bus->number;
+	int irq;
 
 	ACPI_FUNCTION_TRACE("acpi_pci_irq_lookup");
 
@@ -255,28 +251,30 @@
 		ACPI_DEBUG_PRINT((ACPI_DB_INFO, "PRT entry not found\n"));
 		return_VALUE(0);
 	}
-
-	if (!entry->irq && entry->link.handle) {
-		entry->irq = acpi_pci_link_get_irq(entry->link.handle, entry->link.index, NULL, NULL);
-		if (!entry->irq) {
+	
+	if (entry->link.handle) {
+		irq = acpi_pci_link_get_irq(entry->link.handle, entry->link.index, edge_level, active_high_low);
+		if (!irq) {
 			ACPI_DEBUG_PRINT((ACPI_DB_WARN, "Invalid IRQ link routing entry\n"));
 			return_VALUE(0);
 		}
-	}
-	else if (!entry->irq) {
-		ACPI_DEBUG_PRINT((ACPI_DB_INFO, "Invalid static routing entry (IRQ 0)\n"));
-		return_VALUE(0);
+	} else {
+		irq = entry->link.index;
+		*edge_level = ACPI_LEVEL_SENSITIVE;
+		*active_high_low = ACPI_ACTIVE_LOW;
 	}
 
-	ACPI_DEBUG_PRINT((ACPI_DB_INFO, "Found IRQ %d\n", entry->irq));
+	ACPI_DEBUG_PRINT((ACPI_DB_INFO, "Found IRQ %d\n", irq));
 
-	return_VALUE(entry->irq);
+	return_VALUE(irq);
 }
 
 static int
 acpi_pci_irq_derive (
 	struct pci_dev		*dev,
-	int			pin)
+	int			pin,
+	int			*edge_level,
+	int			*active_high_low)
 {
 	struct pci_dev		*bridge = dev;
 	int			irq = 0;
@@ -308,8 +306,8 @@
 			pin = bridge_pin;
 		}
 
-		irq = acpi_pci_irq_lookup(bridge->bus,
-				PCI_SLOT(bridge->devfn), pin);
+		irq = acpi_pci_irq_lookup(bridge->bus, PCI_SLOT(bridge->devfn),
+			pin, edge_level, active_high_low);
 	}
 
 	if (!irq) {
@@ -330,6 +328,8 @@
 {
 	int			irq = 0;
 	u8			pin = 0;
+	int			edge_level = ACPI_LEVEL_SENSITIVE;
+	int			active_high_low = ACPI_ACTIVE_LOW;
 
 	ACPI_FUNCTION_TRACE("acpi_pci_irq_enable");
 
@@ -352,21 +352,22 @@
 	 * First we check the PCI IRQ routing table (PRT) for an IRQ.  PRT
 	 * values override any BIOS-assigned IRQs set during boot.
 	 */
- 	irq = acpi_pci_irq_lookup(dev->bus, PCI_SLOT(dev->devfn), pin);
+ 	irq = acpi_pci_irq_lookup(dev->bus, PCI_SLOT(dev->devfn), pin, &edge_level, &active_high_low);
 
 	/*
 	 * If no PRT entry was found, we'll try to derive an IRQ from the
 	 * device's parent bridge.
 	 */
 	if (!irq)
- 		irq = acpi_pci_irq_derive(dev, pin);
+ 		irq = acpi_pci_irq_derive(dev, pin, &edge_level, &active_high_low);
  
 	/*
 	 * No IRQ known to the ACPI subsystem - maybe the BIOS / 
 	 * driver reported one, then use it. Exit in any case.
 	 */
 	if (!irq) {
-		printk(KERN_WARNING PREFIX "No IRQ known for interrupt pin %c of device %s", ('A' + pin), pci_name(dev));
+		printk(KERN_WARNING PREFIX "PCI interrupt %s[%c]: no GSI",
+			pci_name(dev), ('A' + pin));
 		/* Interrupt Line values above 0xF are forbidden */
 		if (dev->irq && dev->irq >= 0xF) {
 			printk(" - using IRQ %d\n", dev->irq);
@@ -378,27 +379,10 @@
 		}
  	}
 
-	dev->irq = irq;
+	dev->irq = acpi_register_gsi(irq, edge_level, active_high_low);
 
-	ACPI_DEBUG_PRINT((ACPI_DB_INFO, "Device %s using IRQ %d\n", pci_name(dev), dev->irq));
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
+	printk(KERN_DEBUG PREFIX "PCI interrupt %s[%c] -> GSI 0x%x -> IRQ %d\n",
+		pci_name(dev), 'A' + pin, irq, dev->irq);
 
 	return_VALUE(dev->irq);
 }
@@ -421,16 +405,6 @@
 	if (acpi_pci_link_check()) {
 		return_VALUE(-ENODEV);
 	}
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
 
 	while ((dev = pci_find_device(PCI_ANY_ID, PCI_ANY_ID, dev)) != NULL)
 		acpi_pci_irq_enable(dev);
=== drivers/serial/8250_acpi.c 1.8 vs edited ==--- 1.8/drivers/serial/8250_acpi.c	Mon Mar 15 15:53:32 2004
+++ edited/drivers/serial/8250_acpi.c	Tue Apr 13 10:45:59 2004
@@ -58,28 +58,18 @@
 static acpi_status acpi_serial_ext_irq(struct serial_struct *req,
 				       struct acpi_resource_ext_irq *ext_irq)
 {
-	if (ext_irq->number_of_interrupts > 0) {
-#ifdef CONFIG_IA64
-		req->irq = acpi_register_irq(ext_irq->interrupts[0],
-	                  ext_irq->active_high_low, ext_irq->edge_level);
-#else
-		req->irq = ext_irq->interrupts[0];
-#endif
-	}
+	if (ext_irq->number_of_interrupts > 0)
+		req->irq = acpi_register_gsi(ext_irq->interrupts[0],
+	                  ext_irq->edge_level, ext_irq->active_high_low);
 	return AE_OK;
 }
 
 static acpi_status acpi_serial_irq(struct serial_struct *req,
 				   struct acpi_resource_irq *irq)
 {
-	if (irq->number_of_interrupts > 0) {
-#ifdef CONFIG_IA64
-		req->irq = acpi_register_irq(irq->interrupts[0],
-	                  irq->active_high_low, irq->edge_level);
-#else
-		req->irq = irq->interrupts[0];
-#endif
-	}
+	if (irq->number_of_interrupts > 0)
+		req->irq = acpi_register_gsi(irq->interrupts[0],
+	                  irq->edge_level, irq->active_high_low);
 	return AE_OK;
 }
 
=== drivers/serial/8250_hcdp.c 1.4 vs edited ==--- 1.4/drivers/serial/8250_hcdp.c	Sat Apr 10 03:26:14 2004
+++ edited/drivers/serial/8250_hcdp.c	Tue Apr 13 10:46:00 2004
@@ -179,12 +179,8 @@
 			printk(KERN_WARNING"warning: No support for PCI serial console\n");
 			return;
 		}
-#ifdef CONFIG_IA64
-		port.irq = acpi_register_irq(gsi, ACPI_ACTIVE_HIGH,
-				ACPI_EDGE_SENSITIVE);
-#else
-		port.irq = gsi;
-#endif
+		port.irq = acpi_register_gsi(gsi,
+			ACPI_EDGE_SENSITIVE, ACPI_ACTIVE_HIGH);
 		port.flags = UPF_SKIP_TEST | UPF_BOOT_AUTOCONF | UPF_RESOURCES;
 		if (gsi)
 			port.flags |= UPF_AUTO_IRQ;
=== include/asm-i386/mpspec.h 1.20 vs edited ==--- 1.20/include/asm-i386/mpspec.h	Mon Apr 12 11:55:30 2004
+++ edited/include/asm-i386/mpspec.h	Tue Apr 13 11:11:13 2004
@@ -33,7 +33,7 @@
 extern void mp_register_ioapic (u8 id, u32 address, u32 gsi_base);
 extern void mp_override_legacy_irq (u8 bus_irq, u8 polarity, u8 trigger, u32 gsi);
 extern void mp_config_acpi_legacy_irqs (void);
-extern void mp_parse_prt (void);
+extern void mp_register_gsi (u32 gsi, int edge_level, int active_high_low);
 #endif /*CONFIG_ACPI_BOOT*/
 
 #define PHYSID_ARRAY_SIZE	BITS_TO_LONGS(MAX_APICS)
=== include/asm-x86_64/mpspec.h 1.11 vs edited ==--- 1.11/include/asm-x86_64/mpspec.h	Mon Apr 12 11:55:30 2004
+++ edited/include/asm-x86_64/mpspec.h	Tue Apr 13 11:11:26 2004
@@ -189,7 +189,7 @@
 extern void mp_register_ioapic (u8 id, u32 address, u32 gsi_base);
 extern void mp_override_legacy_irq (u8 bus_irq, u8 polarity, u8 trigger, u32 gsi);
 extern void mp_config_acpi_legacy_irqs (void);
-extern void mp_parse_prt (void);
+extern void mp_register_gsi (u32 gsi, int edge_level, int active_high_low);
 #endif /*CONFIG_X86_IO_APIC*/
 #endif
 
=== include/linux/acpi.h 1.32 vs edited ==--- 1.32/include/linux/acpi.h	Mon Mar  1 01:26:35 2004
+++ edited/include/linux/acpi.h	Tue Apr 13 11:09:08 2004
@@ -438,6 +438,7 @@
 
 int acpi_pci_irq_enable (struct pci_dev *dev);
 int acpi_pci_irq_init (void);
+unsigned int acpi_register_gsi (u32 gsi, int edge_level, int active_high_low);
 
 struct acpi_pci_driver {
 	struct acpi_pci_driver *next;
