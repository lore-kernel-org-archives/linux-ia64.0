From: Matthew Wilcox <willy@fc.hp.com>
Date: Mon, 20 May 2002 17:38:26 +0000
Subject: [Linux-ia64] ia64 patch for ACPI 20020503 release
Message-Id: <marc-linux-ia64-105590701905585@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I need to apply this patch in order to get the 20020503 drop working on
ia64.  Should still be required for the 20020517 drop.  Note that this
is versus David's 2.4.18-020508 release which includes ACPI CA 20020329.

Index: arch/ia64/kernel/acpi.c
=================================RCS file: /var/cvs/linux/arch/ia64/kernel/acpi.c,v
retrieving revision 1.14
diff -u -p -r1.14 acpi.c
--- arch/ia64/kernel/acpi.c	15 May 2002 16:14:35 -0000	1.14
+++ arch/ia64/kernel/acpi.c	20 May 2002 16:05:14 -0000
@@ -59,6 +59,8 @@
 
 #define PREFIX			"ACPI: "
 
+enum acpi_irq_model_id		acpi_irq_model;
+
 asm (".weak iosapic_register_irq");
 asm (".weak iosapic_register_legacy_irq");
 asm (".weak iosapic_register_platform_irq");
@@ -72,12 +74,13 @@ const char *
 acpi_get_sysname (void)
 {
 #ifdef CONFIG_IA64_GENERIC
-	unsigned long rsdp_phys = 0;
+	unsigned long rsdp_phys;
 	struct acpi20_table_rsdp *rsdp;
 	struct acpi_table_xsdt *xsdt;
 	struct acpi_table_header *hdr;
 
-	if ((0 != acpi_find_rsdp(&rsdp_phys)) || !rsdp_phys) {
+	rsdp_phys = acpi_find_rsdp();
+	if (!rsdp_phys) {
 		printk("ACPI 2.0 RSDP not found, default to \"dig\"\n");
 		return "dig";
 	}
@@ -207,6 +210,13 @@ acpi_request_vector (u32 int_type)
 	return vector;
 }
 
+char *
+__acpi_map_table (
+	unsigned long	phys_addr,
+	unsigned long	size)
+{
+	return __va(phys_addr);
+}
 
 /* --------------------------------------------------------------------------
                             Boot-time Table Parsing
@@ -558,21 +568,19 @@ acpi_irq_probe(acpi_handle obj, u32 dept
 }
 #endif
 
-int __init
-acpi_find_rsdp (unsigned long *rsdp_phys)
+unsigned long __init
+acpi_find_rsdp (void)
 {
-	if (!rsdp_phys)
-		return -EINVAL;
+	unsigned long rsdp_phys = 0;
 
 	if (efi.acpi20) {
-		(*rsdp_phys) = __pa(efi.acpi20);
-		return 0;
+		rsdp_phys = __pa(efi.acpi20);
 	}
 	else if (efi.acpi) {
 		printk(KERN_WARNING PREFIX "v1.0/r0.71 tables no longer supported\n");
 	}
 
-	return -ENODEV;
+	return rsdp_phys;
 }
 
 
@@ -752,14 +760,14 @@ acpi_get_prt (struct pci_vector_struct *
 	*vectors = NULL;
 	*count = 0;
 
-	if (acpi_prts.count < 0) {
+	if (acpi_prt.count < 0) {
 		printk(KERN_ERR PREFIX "No PCI IRQ routing entries\n");
 		return -ENODEV;
 	}
 
 	/* Allocate vectors */
 
-	*vectors = kmalloc(sizeof(struct pci_vector_struct) * acpi_prts.count, GFP_KERNEL);
+	*vectors = kmalloc(sizeof(struct pci_vector_struct) * acpi_prt.count, GFP_KERNEL);
 	if (!(*vectors))
 		return -ENOMEM;
 
@@ -767,15 +775,15 @@ acpi_get_prt (struct pci_vector_struct *
 
 	vector = *vectors;
 
-	list_for_each(node, &acpi_prts.entries) {
+	list_for_each(node, &acpi_prt.entries) {
 		entry = (struct acpi_prt_entry *)node;
 		vector[i].bus    = entry->id.bus;
-		vector[i].pci_id = ((u32) entry->id.dev << 16) | 0xffff;
+		vector[i].pci_id = ((u32) entry->id.device << 16) | 0xffff;
 		vector[i].pin    = entry->id.pin;
-		vector[i].irq    = entry->source.index;
+		vector[i].irq    = entry->link.index;
 		i++;
 	}
-	*count = acpi_prts.count;
+	*count = acpi_prt.count;
 	return 0;
 }
 
@@ -787,7 +795,7 @@ acpi_get_interrupt_model (int *type)
         if (!type)
                 return -EINVAL;
 
-	*type = ACPI_INT_MODEL_IOSAPIC;
+	*type = ACPI_IRQ_MODEL_IOSAPIC;
 
         return 0;
 }
Index: include/asm-ia64/acpi.h
=================================RCS file: /var/cvs/linux/include/asm-ia64/acpi.h,v
retrieving revision 1.2
diff -u -p -r1.2 acpi.h
--- include/asm-ia64/acpi.h	15 May 2002 16:15:17 -0000	1.2
+++ include/asm-ia64/acpi.h	20 May 2002 16:05:16 -0000
@@ -30,11 +30,8 @@
 
 #ifdef __KERNEL__
 
-#define __acpi_map_table(phys_addr, size) __va(phys_addr)
-
 const char *acpi_get_sysname (void);
 int acpi_boot_init (char *cdline);
-int acpi_find_rsdp (unsigned long *phys_addr);
 int acpi_request_vector (u32 int_type);
 int acpi_get_prt (struct pci_vector_struct **vectors, int *count);
 int acpi_get_interrupt_model(int *type);

-- 
It's always legal to use Linux (TM) systems
http://www.gnu.org/philosophy/why-free.html

