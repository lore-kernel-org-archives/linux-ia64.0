From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Sat, 15 May 2004 20:23:57 +0000
Subject: Re: [PATCH] ACPI PCI IRQ routing rework
Message-Id: <200405151423.57324.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200405151120.45753.bjorn.helgaas@hp.com>
In-Reply-To: <200405151120.45753.bjorn.helgaas-VXdhtT5mjnY@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: acpi-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Cc: Len Brown <len.brown-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, David Mosberger <davidm-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org>, Andi Kleen <ak-l3A5Bk7waGM@public.gmane.org>, Jun Nakajima <jun.nakajima-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org

Andi's x86-64 update that showed up in linux-2.5 today touches
mp_parse_prt(), one of the functions I changed.

Here's an updated patch:

=== arch/i386/kernel/mpparse.c 1.71 vs edited ==--- 1.71/arch/i386/kernel/mpparse.c	Fri Apr 30 23:27:25 2004
+++ edited/arch/i386/kernel/mpparse.c	Sat May 15 14:16:59 2004
@@ -1027,94 +1027,58 @@
 
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
-		printk(KERN_DEBUG "%02x:%02x:%02x[%c] -> %d-%d -> IRQ %d %s %s\n",
-			entry->id.segment, entry->id.bus,
-			entry->id.device, ('A' + entry->pin),
-			mp_ioapic_routing[ioapic].apic_id, ioapic_pin,
-			entry->irq, edge_level ? "level" : "edge",
-			active_high_low ? "low" : "high");
+	if (es7000_plat) {
+		if (!ioapic && (gsi < 16))
+			gsi += 16;
 	}
 
-	print_IO_APIC();
+	/* 
+	 * Avoid pin reprogramming.  PRTs typically include entries  
+	 * with redundant pin->gsi mappings (but unique PCI devices);
+	 * we only program the IOAPIC on the first.
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
=== arch/i386/kernel/acpi/boot.c 1.61 vs edited ==--- 1.61/arch/i386/kernel/acpi/boot.c	Sat May 15 00:11:59 2004
+++ edited/arch/i386/kernel/acpi/boot.c	Sat May 15 14:12:30 2004
@@ -428,6 +428,28 @@
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
=== arch/i386/pci/acpi.c 1.13 vs edited ==--- 1.13/arch/i386/pci/acpi.c	Fri Apr 30 23:27:25 2004
+++ edited/arch/i386/pci/acpi.c	Sat May 15 14:12:31 2004
@@ -1,6 +1,8 @@
 #include <linux/pci.h>
 #include <linux/acpi.h>
 #include <linux/init.h>
+#include <linux/irq.h>
+#include <asm/hw_irq.h>
 #include "pci.h"
 
 struct pci_bus * __devinit pci_acpi_scan_root(struct acpi_device *device, int domain, int busnum)
@@ -15,18 +17,28 @@
 
 static int __init pci_acpi_init(void)
 {
+	struct pci_dev *dev = NULL;
+
 	if (pcibios_scanned)
 		return 0;
 
-	if (!acpi_noirq) {
-		if (!acpi_pci_irq_init()) {
-			printk(KERN_INFO "PCI: Using ACPI for IRQ routing\n");
-			pcibios_scanned++;
-			pcibios_enable_irq = acpi_pci_irq_enable;
-		} else
-			printk(KERN_WARNING "PCI: Invalid ACPI-PCI IRQ routing table\n");
+	if (acpi_noirq)
+		return 0;
 
-	}
+	printk(KERN_INFO "PCI: Using ACPI for IRQ routing\n");
+	acpi_irq_penalty_init();
+	pcibios_scanned++;
+	pcibios_enable_irq = acpi_pci_irq_enable;
+
+	/*
+	 * PCI IRQ routing is set up by pci_enable_device(), but we
+	 * also do it here in case there are still broken drivers that
+	 * don't use pci_enable_device().
+	 */
+	while ((dev = pci_find_device(PCI_ANY_ID, PCI_ANY_ID, dev)) != NULL)
+		acpi_pci_irq_enable(dev);
+
+	print_IO_APIC();
 
 	return 0;
 }
=== arch/ia64/kernel/acpi.c 1.69 vs edited ==--- 1.69/arch/ia64/kernel/acpi.c	Sat May 15 00:11:59 2004
+++ edited/arch/ia64/kernel/acpi.c	Sat May 15 14:12:32 2004
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
 
@@ -648,17 +653,5 @@
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
=== arch/ia64/kernel/iosapic.c 1.42 vs edited ==--- 1.42/arch/ia64/kernel/iosapic.c	Fri May 14 20:00:12 2004
+++ edited/arch/ia64/kernel/iosapic.c	Sat May 15 14:12:32 2004
@@ -173,7 +173,7 @@
 }
 
 static void
-set_rte (unsigned int vector, unsigned int dest, int mask)
+set_rte (unsigned int vector, unsigned int dest)
 {
 	unsigned long pol, trigger, dmode, flags;
 	u32 low32, high32;
@@ -207,10 +207,11 @@
 	}
 #endif
 
+	/* the RTE always starts masked; the IRQ startup unmasks it */
 	low32 = ((pol << IOSAPIC_POLARITY_SHIFT) |
 		 (trigger << IOSAPIC_TRIGGER_SHIFT) |
 		 (dmode << IOSAPIC_DELIVERY_SHIFT) |
-		 ((mask ? 1 : 0) << IOSAPIC_MASK_SHIFT) |
+		 (1 << IOSAPIC_MASK_SHIFT) |
 		 vector);
 
 	/* dest contains both id and eid */
@@ -512,6 +513,42 @@
 	}
 }
 
+static unsigned int
+dest_cpu_lid (void)
+{
+#ifdef CONFIG_SMP
+	static int cpu = -1;
+
+	/*
+	 * If the platform supports redirection via XTP, let it
+	 * distribute interrupts.
+	 */
+	if (smp_int_redirect & SMP_IRQ_REDIRECTION)
+		return hard_smp_processor_id();
+
+	/*
+	 * Some interrupts (ACPI SCI, for instance) are registered
+	 * before the BSP is marked as online.
+	 */
+	if (!cpu_online(smp_processor_id()))
+		return hard_smp_processor_id();
+
+	/*
+	 * Otherwise, round-robin interrupt vectors across all the
+	 * processors.  (It'd be nice if we could be smarter in the
+	 * case of NUMA.)
+	 */
+	do {
+		if (++cpu >= NR_CPUS)
+			cpu = 0;
+	} while (!cpu_online(cpu));
+
+	return cpu_physical_id(cpu);
+#else
+	return hard_smp_processor_id();
+#endif
+}
+
 /*
  * ACPI can describe IOSAPIC interrupts via static tables and namespace
  * methods.  This provides an interface to register those interrupts and
@@ -522,21 +559,35 @@
 		       unsigned long polarity, unsigned long trigger)
 {
 	int vector;
-	unsigned int dest = (ia64_getreg(_IA64_REG_CR_LID) >> 16) & 0xffff;
+	unsigned int dest;
+	unsigned long flags;
 
-	vector = gsi_to_vector(gsi);
-	if (vector < 0)
-		vector = assign_irq_vector(AUTO_ASSIGN);
+	/*
+	 * If this GSI has already been registered (i.e., it's a
+	 * shared interrupt, or we lost a race to register it),
+	 * don't touch the RTE.
+	 */
+	spin_lock_irqsave(&iosapic_lock, flags);
+	{
+		vector = gsi_to_vector(gsi);
+		if (vector > 0) {
+			spin_unlock_irqrestore(&iosapic_lock, flags);
+			return vector;
+		}
 
-	register_intr(gsi, vector, IOSAPIC_LOWEST_PRIORITY,
-		      polarity, trigger);
+		vector = assign_irq_vector(AUTO_ASSIGN);
+		dest = dest_cpu_lid();
+		register_intr(gsi, vector, IOSAPIC_LOWEST_PRIORITY,
+			polarity, trigger);
+	}
+	spin_unlock_irqrestore(&iosapic_lock, flags);
 
-	printk(KERN_INFO "GSI 0x%x(%s,%s) -> CPU 0x%04x vector %d\n",
-	       gsi, (polarity = IOSAPIC_POL_HIGH ? "high" : "low"),
-	       (trigger = IOSAPIC_EDGE ? "edge" : "level"), dest, vector);
+	printk(KERN_INFO "GSI 0x%x (%s, %s) -> CPU %d (0x%04x) vector %d\n",
+	       gsi, (trigger = IOSAPIC_EDGE ? "edge" : "level"),
+	       (polarity = IOSAPIC_POL_HIGH ? "high" : "low"),
+	       cpu_logical_id(dest), dest, vector);
 
-	/* program the IOSAPIC routing table */
-	set_rte(vector, dest, 0);
+	set_rte(vector, dest);
 	return vector;
 }
 
@@ -576,15 +627,14 @@
 		return -1;
 	}
 
-	register_intr(gsi, vector, delivery, polarity,
-		      trigger);
+	register_intr(gsi, vector, delivery, polarity, trigger);
 
-	printk(KERN_INFO "PLATFORM int 0x%x: GSI 0x%x(%s,%s) -> CPU 0x%04x vector %d\n",
-	       int_type, gsi, (polarity = IOSAPIC_POL_HIGH ? "high" : "low"),
-	       (trigger = IOSAPIC_EDGE ? "edge" : "level"), dest, vector);
+	printk(KERN_INFO "PLATFORM int 0x%x: GSI 0x%x (%s, %s) -> CPU %d (0x%04x) vector %d\n",
+	       int_type, gsi, (trigger = IOSAPIC_EDGE ? "edge" : "level"),
+	       (polarity = IOSAPIC_POL_HIGH ? "high" : "low"),
+	       cpu_logical_id(dest), dest, vector);
 
-	/* program the IOSAPIC routing table */
-	set_rte(vector, dest, 0);
+	set_rte(vector, dest);
 	return vector;
 }
 
@@ -605,12 +655,12 @@
 
 	register_intr(gsi, vector, IOSAPIC_LOWEST_PRIORITY, polarity, trigger);
 
-	DBG("ISA: IRQ %u -> GSI 0x%x (%s,%s) -> CPU 0x%04x vector %d\n",
-	    isa_irq, gsi, polarity = IOSAPIC_POL_HIGH ? "high" : "low",
-	    trigger = IOSAPIC_EDGE ? "edge" : "level", dest, vector);
+	DBG("ISA: IRQ %u -> GSI 0x%x (%s,%s) -> CPU %d (0x%04x) vector %d\n",
+	    isa_irq, gsi, trigger = IOSAPIC_EDGE ? "edge" : "level",
+	    polarity = IOSAPIC_POL_HIGH ? "high" : "low",
+	    cpu_logical_id(dest), dest, vector);
 
-	/* program the IOSAPIC routing table */
-	set_rte(vector, dest, 0);
+	set_rte(vector, dest);
 }
 
 void __init
@@ -665,104 +715,3 @@
 			iosapic_override_isa_irq(isa_irq, isa_irq, IOSAPIC_POL_HIGH, IOSAPIC_EDGE);
 	}
 }
-
-void
-iosapic_enable_intr (unsigned int vector)
-{
-	unsigned int dest;
-	irq_desc_t *desc;
-
-	/*
-	 * In the case of a shared interrupt, do not re-route the vector, and
-	 * especially do not mask a running interrupt (startup will not get
-	 * called for a shared interrupt).
-	 */
-	desc = irq_descp(vector);
-	if (desc->action)
-		return;
-
-#ifdef CONFIG_SMP
-	/*
-	 * For platforms that do not support interrupt redirect via the XTP interface, we
-	 * can round-robin the PCI device interrupts to the processors
-	 */
-	if (!(smp_int_redirect & SMP_IRQ_REDIRECTION)) {
-		static int cpu_index = -1;
-
-		do
-			if (++cpu_index >= NR_CPUS)
-				cpu_index = 0;
-		while (!cpu_online(cpu_index));
-
-		dest = cpu_physical_id(cpu_index) & 0xffff;
-	} else {
-		/*
-		 * Direct the interrupt vector to the current cpu, platform redirection
-		 * will distribute them.
-		 */
-		dest = (ia64_getreg(_IA64_REG_CR_LID) >> 16) & 0xffff;
-	}
-#else
-	/* direct the interrupt vector to the running cpu id */
-	dest = (ia64_getreg(_IA64_REG_CR_LID) >> 16) & 0xffff;
-#endif
-	set_rte(vector, dest, 1);
-
-	printk(KERN_INFO "IOSAPIC: vector %d -> CPU 0x%04x, enabled\n",
-	       vector, dest);
-}
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
-				vector = assign_irq_vector(AUTO_ASSIGN);
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
=== arch/ia64/pci/pci.c 1.48 vs edited ==--- 1.48/arch/ia64/pci/pci.c	Wed Apr 21 15:26:09 2004
+++ edited/arch/ia64/pci/pci.c	Sat May 15 14:12:33 2004
@@ -134,10 +134,18 @@
 static int __init
 pci_acpi_init (void)
 {
-	if (!acpi_pci_irq_init())
-		printk(KERN_INFO "PCI: Using ACPI for IRQ routing\n");
-	else
-		printk(KERN_WARNING "PCI: Invalid ACPI-PCI IRQ routing table\n");
+	struct pci_dev *dev = NULL;
+
+	printk(KERN_INFO "PCI: Using ACPI for IRQ routing\n");
+
+	/*
+	 * PCI IRQ routing is set up by pci_enable_device(), but we
+	 * also do it here in case there are still broken drivers that
+	 * don't use pci_enable_device().
+	 */
+	while ((dev = pci_find_device(PCI_ANY_ID, PCI_ANY_ID, dev)) != NULL)
+		acpi_pci_irq_enable(dev);
+
 	return 0;
 }
 
=== arch/x86_64/kernel/mpparse.c 1.27 vs edited ==--- 1.27/arch/x86_64/kernel/mpparse.c	Sat May 15 07:32:27 2004
+++ edited/arch/x86_64/kernel/mpparse.c	Sat May 15 14:16:33 2004
@@ -887,88 +887,49 @@
 
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
 
-	/*
-	 * Parsing through the PCI Interrupt Routing Table (PRT) and program
-	 * routing for all static (IOAPIC-direct) entries.
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
-		if (acpi_fadt.sci_int = gsi) {
-			/* we still need to set up the entry's irq */
-			acpi_gsi_to_irq(gsi, &entry->irq);
-			continue;
-		}
-
-		ioapic = mp_find_ioapic(gsi);
-		if (ioapic < 0)
-			continue;
-		ioapic_pin = gsi - mp_ioapic_routing[ioapic].gsi_start;
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
-		if (!io_apic_set_pci_routing(ioapic, ioapic_pin, gsi, edge_level, active_high_low)) {
-			acpi_gsi_to_irq(gsi, &entry->irq);
- 		}
-		printk(KERN_DEBUG "%02x:%02x:%02x[%c] -> %d-%d -> IRQ %d\n",
-			entry->id.segment, entry->id.bus,
-			entry->id.device, ('A' + entry->pin), 
-			mp_ioapic_routing[ioapic].apic_id, ioapic_pin,
-			entry->irq);
+	ioapic_pin = gsi - mp_ioapic_routing[ioapic].gsi_start;
+
+	/* 
+	 * Avoid pin reprogramming.  PRTs typically include entries  
+	 * with redundant pin->gsi mappings (but unique PCI devices);
+	 * we only program the IOAPIC on the first.
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
-}
+	mp_ioapic_routing[ioapic].pin_programmed[idx] |= (1<<bit);
 
-#endif /*CONFIG_ACPI_PCI*/
+	io_apic_set_pci_routing(ioapic, ioapic_pin, gsi,
+		edge_level = ACPI_EDGE_SENSITIVE ? 0 : 1,
+		active_high_low = ACPI_ACTIVE_HIGH ? 0 : 1);
+}
 
 #endif /*CONFIG_X86_IO_APIC*/
-
 #endif /*CONFIG_ACPI_BOOT*/
=== drivers/acpi/pci_irq.c 1.27 vs edited ==--- 1.27/drivers/acpi/pci_irq.c	Sat Apr 24 00:17:22 2004
+++ edited/drivers/acpi/pci_irq.c	Sat May 15 14:12:34 2004
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
 		if (dev->irq && (dev->irq <= 0xF)) {
 			printk(" - using IRQ %d\n", dev->irq);
@@ -378,62 +379,14 @@
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
+	printk(KERN_INFO PREFIX "PCI interrupt %s[%c] -> GSI 0x%x "
+		"(%s, %s) -> IRQ %d\n",
+		pci_name(dev), 'A' + pin, irq,
+		(edge_level = ACPI_LEVEL_SENSITIVE) ? "level" : "edge",
+		(active_high_low = ACPI_ACTIVE_LOW) ? "low" : "high",
+		dev->irq);
 
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
=== drivers/acpi/pci_link.c 1.28 vs edited ==--- 1.28/drivers/acpi/pci_link.c	Mon May 10 14:42:35 2004
+++ edited/drivers/acpi/pci_link.c	Sat May 15 14:12:35 2004
@@ -487,13 +487,13 @@
 };
 
 int
-acpi_pci_link_check (void)
+acpi_irq_penalty_init(void)
 {
 	struct list_head	*node = NULL;
 	struct acpi_pci_link    *link = NULL;
 	int			i = 0;
 
-	ACPI_FUNCTION_TRACE("acpi_pci_link_check");
+	ACPI_FUNCTION_TRACE("acpi_irq_penalty_init");
 
 	/*
 	 * Update penalties to facilitate IRQ balancing.
=== drivers/serial/8250_acpi.c 1.8 vs edited ==--- 1.8/drivers/serial/8250_acpi.c	Mon Mar 15 15:53:32 2004
+++ edited/drivers/serial/8250_acpi.c	Sat May 15 14:12:35 2004
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
 
=== drivers/serial/8250_hcdp.c 1.6 vs edited ==--- 1.6/drivers/serial/8250_hcdp.c	Tue May  4 10:54:32 2004
+++ edited/drivers/serial/8250_hcdp.c	Sat May 15 14:12:36 2004
@@ -183,16 +183,12 @@
 		}
 
 		if (HCDP_IRQ_SUPPORTED(hcdp_dev)) {
-#ifdef CONFIG_IA64
 			if (HCDP_PCI_UART(hcdp_dev))
-				port.irq = acpi_register_irq(gsi,
-					ACPI_ACTIVE_LOW, ACPI_LEVEL_SENSITIVE);
+				port.irq = acpi_register_gsi(gsi,
+					ACPI_LEVEL_SENSITIVE, ACPI_ACTIVE_LOW);
 			else
-				port.irq = acpi_register_irq(gsi,
-					ACPI_ACTIVE_HIGH, ACPI_EDGE_SENSITIVE);
-#else
-			port.irq = gsi;
-#endif
+				port.irq = acpi_register_gsi(gsi,
+					ACPI_EDGE_SENSITIVE, ACPI_ACTIVE_HIGH);
 			port.flags |= UPF_AUTO_IRQ;
 
 			if (HCDP_PCI_UART(hcdp_dev))
=== include/acpi/acpi_drivers.h 1.17 vs edited ==--- 1.17/include/acpi/acpi_drivers.h	Mon Dec 15 17:46:29 2003
+++ edited/include/acpi/acpi_drivers.h	Sat May 15 14:12:36 2004
@@ -55,7 +55,7 @@
 
 /* ACPI PCI Interrupt Link (pci_link.c) */
 
-int acpi_pci_link_check (void);
+int acpi_irq_penalty_init (void);
 int acpi_pci_link_get_irq (acpi_handle handle, int index, int* edge_level, int* active_high_low);
 
 /* ACPI PCI Interrupt Routing (pci_irq.c) */
=== include/asm-i386/mpspec.h 1.20 vs edited ==--- 1.20/include/asm-i386/mpspec.h	Mon Apr 12 11:55:30 2004
+++ edited/include/asm-i386/mpspec.h	Sat May 15 14:12:37 2004
@@ -33,7 +33,7 @@
 extern void mp_register_ioapic (u8 id, u32 address, u32 gsi_base);
 extern void mp_override_legacy_irq (u8 bus_irq, u8 polarity, u8 trigger, u32 gsi);
 extern void mp_config_acpi_legacy_irqs (void);
-extern void mp_parse_prt (void);
+extern void mp_register_gsi (u32 gsi, int edge_level, int active_high_low);
 #endif /*CONFIG_ACPI_BOOT*/
 
 #define PHYSID_ARRAY_SIZE	BITS_TO_LONGS(MAX_APICS)
=== include/asm-ia64/iosapic.h 1.13 vs edited ==--- 1.13/include/asm-ia64/iosapic.h	Fri Feb 27 04:39:17 2004
+++ edited/include/asm-ia64/iosapic.h	Sat May 15 14:12:37 2004
@@ -60,7 +60,6 @@
 				    unsigned int gsi_base);
 extern int gsi_to_vector (unsigned int gsi);
 extern int gsi_to_irq (unsigned int gsi);
-extern void __init iosapic_parse_prt (void);
 extern void iosapic_enable_intr (unsigned int vector);
 extern int iosapic_register_intr (unsigned int gsi, unsigned long polarity,
 				  unsigned long trigger);
=== include/asm-x86_64/mpspec.h 1.11 vs edited ==--- 1.11/include/asm-x86_64/mpspec.h	Mon Apr 12 11:55:30 2004
+++ edited/include/asm-x86_64/mpspec.h	Sat May 15 14:12:37 2004
@@ -189,7 +189,7 @@
 extern void mp_register_ioapic (u8 id, u32 address, u32 gsi_base);
 extern void mp_override_legacy_irq (u8 bus_irq, u8 polarity, u8 trigger, u32 gsi);
 extern void mp_config_acpi_legacy_irqs (void);
-extern void mp_parse_prt (void);
+extern void mp_register_gsi (u32 gsi, int edge_level, int active_high_low);
 #endif /*CONFIG_X86_IO_APIC*/
 #endif
 
=== include/linux/acpi.h 1.33 vs edited ==--- 1.33/include/linux/acpi.h	Fri Apr  2 06:48:53 2004
+++ edited/include/linux/acpi.h	Sat May 15 14:12:38 2004
@@ -437,7 +437,7 @@
 struct pci_dev;
 
 int acpi_pci_irq_enable (struct pci_dev *dev);
-int acpi_pci_irq_init (void);
+unsigned int acpi_register_gsi (u32 gsi, int edge_level, int active_high_low);
 int acpi_gsi_to_irq (u32 gsi, unsigned int *irq);
 
 struct acpi_pci_driver {
