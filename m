From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 09 Mar 2004 23:26:31 +0000
Subject: Re: [ACPI] [PATCH] 4 of 6 introduce acpi_global_irq_to_irq()
Message-Id: <200403091626.31461.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200403091619.04333.bjorn.helgaas@hp.com>
In-Reply-To: <200403091619.04333.bjorn.helgaas-VXdhtT5mjnY@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: acpi-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Andi Kleen <ak-l3A5Bk7waGM@public.gmane.org>, "Nakajima, Jun" <jun.nakajima-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, "Brown, Len" <len.brown-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

i386, x86_64, ia64, ACPI:  Introduce acpi_global_irq_to_irq()

Rename acpi_irq_to_vector() to acpi_global_irq_to_irq().
This function takes an ACPI global IRQ (often called a "global
system interrupt", but "global_irq" seems to be commonly used
in Linux), and converts it to a Linux IRQ.

This removes IA64 and PCI_USE_VECTOR #ifdefs from ACPI.

diff -Nru a/arch/i386/kernel/acpi/boot.c b/arch/i386/kernel/acpi/boot.c
--- a/arch/i386/kernel/acpi/boot.c	Tue Mar  9 15:29:18 2004
+++ b/arch/i386/kernel/acpi/boot.c	Tue Mar  9 15:29:18 2004
@@ -349,11 +349,13 @@
 #endif /* CONFIG_ACPI_BUS */
 
 #ifdef CONFIG_X86_IO_APIC
-int acpi_irq_to_vector(u32 irq)
+int acpi_global_irq_to_irq(u32 global_irq, unsigned int *irq)
 {
-	if (use_pci_vector() && !platform_legacy_irq(irq))
- 		irq = IO_APIC_VECTOR(irq);
-	return irq;
+	if (use_pci_vector() && !platform_legacy_irq(global_irq))
+ 		*irq = IO_APIC_VECTOR(global_irq);
+	else
+		*irq = global_irq;
+	return 0;
 }
 #endif
 
diff -Nru a/arch/i386/kernel/mpparse.c b/arch/i386/kernel/mpparse.c
--- a/arch/i386/kernel/mpparse.c	Tue Mar  9 15:29:18 2004
+++ b/arch/i386/kernel/mpparse.c	Tue Mar  9 15:29:18 2004
@@ -1127,8 +1127,8 @@
 
 		/* Don't set up the ACPI SCI because it's already set up */
                 if (acpi_fadt.sci_int = global_irq) {
-			global_irq = acpi_irq_to_vector(global_irq);
-			entry->irq = global_irq; /* we still need to set entry's irq */
+			/* we still need to set entry's irq */
+			acpi_global_irq_to_irq(global_irq, &entry->irq);
 			continue;
                 }
 	
@@ -1158,14 +1158,14 @@
 		if ((1<<bit) & mp_ioapic_routing[ioapic].pin_programmed[idx]) {
 			Dprintk(KERN_DEBUG "Pin %d-%d already programmed\n",
 				mp_ioapic_routing[ioapic].apic_id, ioapic_pin);
-			entry->irq = acpi_irq_to_vector(global_irq);
+			acpi_global_irq_to_irq(global_irq, &entry->irq);
 			continue;
 		}
 
 		mp_ioapic_routing[ioapic].pin_programmed[idx] |= (1<<bit);
 
 		if (!io_apic_set_pci_routing(ioapic, ioapic_pin, global_irq, edge_level, active_high_low)) {
-			entry->irq = acpi_irq_to_vector(global_irq);
+			acpi_global_irq_to_irq(global_irq, &entry->irq);
 		}
 		printk(KERN_DEBUG "%02x:%02x:%02x[%c] -> %d-%d -> IRQ %d\n",
 			entry->id.segment, entry->id.bus,
diff -Nru a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
--- a/arch/ia64/kernel/acpi.c	Tue Mar  9 15:29:18 2004
+++ b/arch/ia64/kernel/acpi.c	Tue Mar  9 15:29:18 2004
@@ -627,12 +627,20 @@
 }
 
 int
-acpi_irq_to_vector (u32 gsi)
+acpi_global_irq_to_irq (u32 gsi, unsigned int *irq)
 {
+	int vector;
+
 	if (has_8259 && gsi < 16)
-		return isa_irq_to_vector(gsi);
+		*irq = isa_irq_to_vector(gsi);
+	else {
+		vector = gsi_to_vector(gsi);
+		if (vector = -1)
+			return -1;
 
-	return gsi_to_vector(gsi);
+		*irq = vector;
+	}
+	return 0;
 }
 
 int
diff -Nru a/arch/x86_64/kernel/acpi/boot.c b/arch/x86_64/kernel/acpi/boot.c
--- a/arch/x86_64/kernel/acpi/boot.c	Tue Mar  9 15:29:18 2004
+++ b/arch/x86_64/kernel/acpi/boot.c	Tue Mar  9 15:29:18 2004
@@ -324,11 +324,13 @@
 #endif /* CONFIG_ACPI_BUS */
 
 #ifdef CONFIG_X86_IO_APIC
-int acpi_irq_to_vector(u32 irq)
+int acpi_global_irq_to_irq(u32 global_irq, unsigned int *irq)
 {
-	if (use_pci_vector() && !platform_legacy_irq(irq))
- 		irq = IO_APIC_VECTOR(irq);
-	return irq;
+	if (use_pci_vector() && !platform_legacy_irq(global_irq))
+ 		*irq = IO_APIC_VECTOR(global_irq);
+	else
+		*irq = global_irq;
+	return 0;
 }
 #endif
 
diff -Nru a/arch/x86_64/kernel/mpparse.c b/arch/x86_64/kernel/mpparse.c
--- a/arch/x86_64/kernel/mpparse.c	Tue Mar  9 15:29:18 2004
+++ b/arch/x86_64/kernel/mpparse.c	Tue Mar  9 15:29:18 2004
@@ -998,13 +998,13 @@
 		if ((1<<bit) & mp_ioapic_routing[ioapic].pin_programmed[idx]) {
 			Dprintk(KERN_DEBUG "Pin %d-%d already programmed\n",
 				mp_ioapic_routing[ioapic].apic_id, ioapic_pin);
-			entry->irq = acpi_irq_to_vector(global_irq);
+			acpi_global_irq_to_irq(global_irq, &entry->irq);
 			continue;
 		}
 
 		mp_ioapic_routing[ioapic].pin_programmed[idx] |= (1<<bit);
 		if (!io_apic_set_pci_routing(ioapic, ioapic_pin, global_irq, edge_level, active_high_low)) {
-			entry->irq = acpi_irq_to_vector(global_irq);
+			acpi_global_irq_to_irq(global_irq, &entry->irq);
 		}
 		printk(KERN_DEBUG "%02x:%02x:%02x[%c] -> %d-%d -> IRQ %d\n",
 			entry->id.segment, entry->id.bus,
diff -Nru a/drivers/acpi/osl.c b/drivers/acpi/osl.c
--- a/drivers/acpi/osl.c	Tue Mar  9 15:29:18 2004
+++ b/drivers/acpi/osl.c	Tue Mar  9 15:29:18 2004
@@ -240,23 +240,22 @@
 }
 
 acpi_status
-acpi_os_install_interrupt_handler(u32 irq, OSD_HANDLER handler, void *context)
+acpi_os_install_interrupt_handler(u32 global_irq, OSD_HANDLER handler, void *context)
 {
+	unsigned int irq;
+
 	/*
 	 * Ignore the irq from the core, and use the value in our copy of the
 	 * FADT. It may not be the same if an interrupt source override exists
 	 * for the SCI.
 	 */
-	irq = acpi_fadt.sci_int;
+	global_irq = acpi_fadt.sci_int;
 
-#if defined(CONFIG_IA64) || defined(CONFIG_PCI_USE_VECTOR)
-	irq = acpi_irq_to_vector(irq);
-	if (irq < 0) {
+	if (acpi_global_irq_to_irq(global_irq, &irq) < 0) {
 		printk(KERN_ERR PREFIX "SCI (ACPI interrupt %d) not registered\n",
-		       acpi_fadt.sci_int);
+		       global_irq);
 		return AE_OK;
 	}
-#endif
 	acpi_irq_handler = handler;
 	acpi_irq_context = context;
 	if (request_irq(irq, acpi_irq, SA_SHIRQ, "acpi", acpi_irq)) {
@@ -269,12 +268,15 @@
 }
 
 acpi_status
-acpi_os_remove_interrupt_handler(u32 irq, OSD_HANDLER handler)
+acpi_os_remove_interrupt_handler(u32 global_irq, OSD_HANDLER handler)
 {
-	if (irq) {
-#if defined(CONFIG_IA64) || defined(CONFIG_PCI_USE_VECTOR)
-		irq = acpi_irq_to_vector(irq);
-#endif
+	unsigned int irq;
+
+	if (global_irq) {
+		if (acpi_global_irq_to_irq(global_irq, &irq) < 0) {
+			printk(KERN_ERR PREFIX "Can't remove ACPI interrupt handler\n");
+			return AE_ERROR;
+		}
 		free_irq(irq, acpi_irq);
 		acpi_irq_handler = NULL;
 		acpi_irq_irq = 0;
diff -Nru a/include/asm-i386/acpi.h b/include/asm-i386/acpi.h
--- a/include/asm-i386/acpi.h	Tue Mar  9 15:29:18 2004
+++ b/include/asm-i386/acpi.h	Tue Mar  9 15:29:18 2004
@@ -115,9 +115,9 @@
 /* Fixmap pages to reserve for ACPI boot-time tables (see fixmap.h) */
 #define FIX_ACPI_PAGES 4
 
+extern int acpi_global_irq_to_irq(u32 global_irq, unsigned int *irq);
 #ifdef CONFIG_X86_IO_APIC
 extern int skip_ioapic_setup;
-extern int acpi_irq_to_vector(u32 irq);
 
 static inline void disable_ioapic_setup(void)
 {
diff -Nru a/include/asm-ia64/acpi.h b/include/asm-ia64/acpi.h
--- a/include/asm-ia64/acpi.h	Tue Mar  9 15:29:18 2004
+++ b/include/asm-ia64/acpi.h	Tue Mar  9 15:29:18 2004
@@ -93,7 +93,7 @@
 const char *acpi_get_sysname (void);
 int acpi_request_vector (u32 int_type);
 int acpi_register_irq (u32 gsi, u32 polarity, u32 trigger);
-int acpi_irq_to_vector (u32 irq);
+int acpi_global_irq_to_irq (u32 global_irq, unsigned int *irq);
 
 #ifdef CONFIG_ACPI_NUMA
 /* Proximity bitmap length; _PXM is at most 255 (8 bit)*/
diff -Nru a/include/asm-x86_64/acpi.h b/include/asm-x86_64/acpi.h
--- a/include/asm-x86_64/acpi.h	Tue Mar  9 15:29:18 2004
+++ b/include/asm-x86_64/acpi.h	Tue Mar  9 15:29:18 2004
@@ -109,6 +109,8 @@
 /* Fixmap pages to reserve for ACPI boot-time tables (see fixmap.h) */
 #define FIX_ACPI_PAGES 4
 
+extern int acpi_global_irq_to_irq(u32 global_irq, unsigned int *irq);
+
 #else	/* !CONFIG_ACPI_BOOT */
 #define acpi_lapic 0
 #define acpi_ioapic 0

