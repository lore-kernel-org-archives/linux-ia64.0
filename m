From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 18 Dec 2003 20:22:57 +0000
Subject: [PATCH] Remove unused ACPI functions
Message-Id: <marc-linux-ia64-107177902124173@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

ia64: Remove unused ACPI functions.

Remove unused functions:
    acpi_get_prt()
    acpi_get_interrupt_model()
    acpi_get_addr_space()

=== arch/ia64/kernel/acpi.c 1.55 vs edited ==--- 1.55/arch/ia64/kernel/acpi.c	Wed Oct  8 07:16:20 2003
+++ edited/arch/ia64/kernel/acpi.c	Tue Nov 18 10:05:32 2003
@@ -610,66 +610,6 @@
 	return 0;
 }
 
-/*
- * PCI Interrupt Routing
- */
-
-#ifdef CONFIG_PCI
-int __init
-acpi_get_prt (struct pci_vector_struct **vectors, int *count)
-{
-	struct pci_vector_struct *vector;
-	struct list_head *node;
-	struct acpi_prt_entry *entry;
-	int i = 0;
-
-	if (!vectors || !count)
-		return -EINVAL;
-
-	*vectors = NULL;
-	*count = 0;
-
-	if (acpi_prt.count < 0) {
-		printk(KERN_ERR PREFIX "No PCI interrupt routing entries\n");
-		return -ENODEV;
-	}
-
-	/* Allocate vectors */
-
-	*vectors = kmalloc(sizeof(struct pci_vector_struct) * acpi_prt.count, GFP_KERNEL);
-	if (!(*vectors))
-		return -ENOMEM;
-
-	/* Convert PRT entries to IOSAPIC PCI vectors */
-
-	vector = *vectors;
-
-	list_for_each(node, &acpi_prt.entries) {
-		entry = (struct acpi_prt_entry *)node;
-		vector[i].segment = entry->id.segment;
-		vector[i].bus    = entry->id.bus;
-		vector[i].pci_id = ((u32) entry->id.device << 16) | 0xffff;
-		vector[i].pin    = entry->pin;
-		vector[i].irq    = entry->link.index;
-		i++;
-	}
-	*count = acpi_prt.count;
-	return 0;
-}
-#endif /* CONFIG_PCI */
-
-/* Assume IA64 always use I/O SAPIC */
-
-int __init
-acpi_get_interrupt_model (int *type)
-{
-        if (!type)
-                return -EINVAL;
-
-	*type = ACPI_IRQ_MODEL_IOSAPIC;
-        return 0;
-}
-
 int
 acpi_irq_to_vector (u32 gsi)
 {
=== include/asm-ia64/acpi.h 1.11 vs edited ==--- 1.11/include/asm-ia64/acpi.h	Sun Oct  5 02:07:48 2003
+++ edited/include/asm-ia64/acpi.h	Tue Nov 18 10:06:02 2003
@@ -88,11 +88,8 @@
 
 const char *acpi_get_sysname (void);
 int acpi_request_vector (u32 int_type);
-int acpi_get_prt (struct pci_vector_struct **vectors, int *count);
-int acpi_get_interrupt_model (int *type);
 int acpi_register_irq (u32 gsi, u32 polarity, u32 trigger);
 int acpi_irq_to_vector (u32 irq);
-int acpi_get_addr_space (void *obj, u8 type, u64 *base, u64 *length,u64 *tra);
 
 #ifdef CONFIG_ACPI_NUMA
 #include <asm/numa.h>

