From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 06 Aug 2003 18:24:20 +0000
Subject: 2.6.0-test2 IOSAPIC .weak symbol cleanup
Message-Id: <marc-linux-ia64-106019437113166@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The patch below removes the ".weak" symbol stuff from iosapic.c.

As far as I can tell, iosapic.c is compiled for every flavor except
the simulator.  I tried to boot the HP_SIM kernel on ski, but it
seems to loop in find_save_locs().  This happens both with and
without this patch, so maybe I have a local problem.  (I started
with a clean tree, did "make oldconfig", "make menuconfig" and
changed the system type to HP_SIM and removed the old
AIC7xxx driver.)

Bjorn


=== arch/ia64/kernel/acpi.c 1.44 vs edited ==--- 1.44/arch/ia64/kernel/acpi.c	Fri Jul 11 12:58:43 2003
+++ edited/arch/ia64/kernel/acpi.c	Wed Aug  6 11:13:56 2003
@@ -51,13 +51,6 @@
 
 #define PREFIX			"ACPI: "
 
-asm (".weak iosapic_register_intr");
-asm (".weak iosapic_override_isa_irq");
-asm (".weak iosapic_register_platform_intr");
-asm (".weak iosapic_init");
-asm (".weak iosapic_system_init");
-asm (".weak iosapic_version");
-
 void (*pm_idle) (void);
 void (*pm_power_off) (void);
 
@@ -241,8 +234,7 @@
 
 	acpi_table_print_madt_entry(header);
 
-	if (iosapic_init)
-		iosapic_init(iosapic->address, iosapic->global_irq_base);
+	iosapic_init(iosapic->address, iosapic->global_irq_base);
 
 	return 0;
 }
@@ -260,11 +252,6 @@
 
 	acpi_table_print_madt_entry(header);
 
-	if (!iosapic_register_platform_intr) {
-		printk(KERN_WARNING PREFIX "No ACPI platform interrupt support\n");
-		return -ENODEV;
-	}
-
 	/*
 	 * Get vector assignment for this interrupt, set attributes,
 	 * and program the IOSAPIC routing table.
@@ -293,10 +280,6 @@
 
 	acpi_table_print_madt_entry(header);
 
-	/* Ignore if the platform doesn't support overrides */
-	if (!iosapic_override_isa_irq)
-		return 0;
-
 	iosapic_override_isa_irq(p->bus_irq, p->global_irq,
 				 (p->flags.polarity = 1) ? IOSAPIC_POL_HIGH : IOSAPIC_POL_LOW,
 				 (p->flags.trigger = 1) ? IOSAPIC_EDGE : IOSAPIC_LEVEL);
@@ -334,8 +317,7 @@
 #else
 	has_8259 = acpi_madt->flags.pcat_compat;
 #endif
-	if (iosapic_system_init)
-		iosapic_system_init(has_8259);
+	iosapic_system_init(has_8259);
 
 	/* Get base address of IPI Message Block */
 
@@ -549,9 +531,6 @@
 	if (!(fadt->iapc_boot_arch & BAF_8042_KEYBOARD_CONTROLLER))
 		acpi_kbd_controller_present = 0;
 
-	if (!iosapic_register_intr)
-		return 0;	/* just ignore the rest */
-
 	sci_irq = fadt->sci_int;
 
 	if (has_8259 && sci_irq < 16)
@@ -722,9 +701,6 @@
 
 	if (has_8259 && (gsi < 16))
 		return isa_irq_to_vector(gsi);
-
-	if (!iosapic_register_intr)
-		return 0;
 
 	/* Turn it on */
 	vector = iosapic_register_intr (gsi, polarity, trigger);
=== include/asm-ia64/iosapic.h 1.10 vs edited ==--- 1.10/include/asm-ia64/iosapic.h	Tue Apr 22 13:17:15 2003
+++ edited/include/asm-ia64/iosapic.h	Wed Aug  6 11:07:39 2003
@@ -51,6 +51,7 @@
 
 #ifndef __ASSEMBLY__
 
+#ifdef CONFIG_IOSAPIC
 extern void __init iosapic_system_init (int pcat_compat);
 extern void __init iosapic_init (unsigned long address,
 				    unsigned int gsi_base);
@@ -72,6 +73,14 @@
 extern unsigned int iosapic_version (char *addr);
 
 extern void iosapic_pci_fixup (int);
+#else
+#define iosapic_system_init(pcat_compat)			do { } while (0)
+#define iosapic_init(address,gsi_base)				do { } while (0)
+#define iosapic_register_intr(gsi,polarity,trigger)		(gsi)
+#define iosapic_override_isa_irq(isa_irq,gsi,polarity,trigger)	do { } while (0)
+#define iosapic_register_platform_intr(type,gsi,pmi,eid,id, \
+	polarity,trigger)					(gsi)
+#endif
 
 # endif /* !__ASSEMBLY__ */
 #endif /* __ASM_IA64_IOSAPIC_H */

