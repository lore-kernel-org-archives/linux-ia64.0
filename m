From: Matthew Wilcox <willy@fc.hp.com>
Date: Mon, 20 May 2002 22:18:00 +0000
Subject: [Linux-ia64] ia64 patch for ACPI 20020517 release
Message-Id: <marc-linux-ia64-105590701905588@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The previous patch for 20020503 is insufficient for 20020517.  Here's
a patch (to apply on top of David's 20020508 release, upgraded to
20020517) which allows 20020517 to compile.

Index: arch/ia64/kernel/acpi.c
=================================RCS file: /var/cvs/linux/arch/ia64/kernel/acpi.c,v
retrieving revision 1.14
diff -u -p -r1.14 acpi.c
--- arch/ia64/kernel/acpi.c	15 May 2002 16:14:35 -0000	1.14
+++ arch/ia64/kernel/acpi.c	20 May 2002 22:07:57 -0000
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
-		vector[i].pin    = entry->id.pin;
-		vector[i].irq    = entry->source.index;
+		vector[i].pci_id = ((u32) entry->id.device << 16) | 0xffff;
+		vector[i].pin    = entry->pin;
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
Index: arch/ia64/kernel/pci.c
=================================RCS file: /var/cvs/linux/arch/ia64/kernel/pci.c,v
retrieving revision 1.5
diff -u -p -r1.5 pci.c
--- arch/ia64/kernel/pci.c	15 May 2002 16:14:36 -0000	1.5
+++ arch/ia64/kernel/pci.c	20 May 2002 22:07:57 -0000
@@ -165,7 +165,7 @@ struct pci_ops pci_sal_ops = {
  */
 
 struct pci_bus *
-pcibios_scan_root(int seg, int bus)
+pcibios_scan_root(int bus)
 {
 	struct list_head *list = NULL;
 	struct pci_bus *pci_bus = NULL;
@@ -174,12 +174,12 @@ pcibios_scan_root(int seg, int bus)
 		pci_bus = pci_bus_b(list);
 		if (pci_bus->number = bus) {
 			/* Already scanned */
-			printk("PCI: Bus (%02x:%02x) already probed\n", seg, bus);
+			printk("PCI: Bus (%02x) already probed\n", bus);
 			return pci_bus;
 		}
 	}
 
-	printk("PCI: Probing PCI hardware on bus (%02x:%02x)\n", seg, bus);
+	printk("PCI: Probing PCI hardware on bus (%02x)\n", bus);
 
 	return pci_scan_bus(bus, pci_root_ops, NULL);
 }
Index: include/asm-ia64/acpi.h
=================================RCS file: /var/cvs/linux/include/asm-ia64/acpi.h,v
retrieving revision 1.2
diff -u -p -r1.2 acpi.h
--- include/asm-ia64/acpi.h	15 May 2002 16:15:17 -0000	1.2
+++ include/asm-ia64/acpi.h	20 May 2002 22:07:58 -0000
@@ -30,11 +30,74 @@
 
 #ifdef __KERNEL__
 
-#define __acpi_map_table(phys_addr, size) __va(phys_addr)
+#define COMPILER_DEPENDENT_INT64	long
+#define COMPILER_DEPENDENT_UINT64	unsigned long
+
+/*
+ * Calling conventions:
+ *
+ * ACPI_SYSTEM_XFACE        - Interfaces to host OS (handlers, threads)
+ * ACPI_EXTERNAL_XFACE      - External ACPI interfaces
+ * ACPI_INTERNAL_XFACE      - Internal ACPI interfaces
+ * ACPI_INTERNAL_VAR_XFACE  - Internal variable-parameter list interfaces
+ */
+#define ACPI_SYSTEM_XFACE
+#define ACPI_EXTERNAL_XFACE
+#define ACPI_INTERNAL_XFACE
+#define ACPI_INTERNAL_VAR_XFACE
+
+/* Asm macros */
+
+#define ACPI_ASM_MACROS
+#define BREAKPOINT3
+#define ACPI_DISABLE_IRQS() __cli()
+#define ACPI_ENABLE_IRQS()  __sti()
+#define ACPI_FLUSH_CPU_CACHE()
+
+#define ACPI_ACQUIRE_GLOBAL_LOCK(GLptr, Acq) \
+	do { \
+	__asm__ volatile ("1:  ld4      r29=%1\n"  \
+		";;\n"                  \
+		"mov    ar.ccv=r29\n"   \
+		"mov    r2=r29\n"       \
+		"shr.u  r30=r29,1\n"    \
+		"and    r29=-4,r29\n"   \
+		";;\n"                  \
+		"add    r29=2,r29\n"    \
+		"and    r30=1,r30\n"    \
+		";;\n"                  \
+		"add    r29=r29,r30\n"  \
+		";;\n"                  \
+		"cmpxchg4.acq   r30=%1,r29,ar.ccv\n" \
+		";;\n"                  \
+		"cmp.eq p6,p7=r2,r30\n" \
+		"(p7) br.dpnt.few 1b\n" \
+		"cmp.gt p8,p9=3,r29\n"  \
+		";;\n"                  \
+		"(p8) mov %0=-1\n"      \
+		"(p9) mov %0=r0\n"      \
+		:"=r"(Acq):"m"(GLptr):"r2","r29","r30","memory"); \
+	} while (0)
+
+#define ACPI_RELEASE_GLOBAL_LOCK(GLptr, Acq) \
+	do { \
+	__asm__ volatile ("1:  ld4      r29=%1\n" \
+		";;\n"                  \
+		"mov    ar.ccv=r29\n"   \
+		"mov    r2=r29\n"       \
+		"and    r29=-4,r29\n"   \
+		";;\n"                  \
+		"cmpxchg4.acq   r30=%1,r29,ar.ccv\n" \
+		";;\n"                  \
+		"cmp.eq p6,p7=r2,r30\n" \
+		"(p7) br.dpnt.few 1b\n" \
+		"and    %0=1,r2\n"      \
+		";;\n"                  \
+		:"=r"(Acq):"m"(GLptr):"r2","r29","r30","memory"); \
+	} while (0)
 
 const char *acpi_get_sysname (void);
 int acpi_boot_init (char *cdline);
-int acpi_find_rsdp (unsigned long *phys_addr);
 int acpi_request_vector (u32 int_type);
 int acpi_get_prt (struct pci_vector_struct **vectors, int *count);
 int acpi_get_interrupt_model(int *type);
Index: include/asm-ia64/pci.h
=================================RCS file: /var/cvs/linux/include/asm-ia64/pci.h,v
retrieving revision 1.5
diff -u -p -r1.5 pci.h
--- include/asm-ia64/pci.h	15 May 2002 16:15:18 -0000	1.5
+++ include/asm-ia64/pci.h	20 May 2002 22:07:58 -0000
@@ -20,7 +20,7 @@
 #define PCIBIOS_MIN_MEM		0x10000000
 
 void pcibios_config_init(void);
-struct pci_bus * pcibios_scan_root(int seg, int bus);
+struct pci_bus * pcibios_scan_root(int bus);
 extern int (*pci_config_read)(int seg, int bus, int dev, int fn, int reg, int len, u32 *value);
 extern int (*pci_config_write)(int seg, int bus, int dev, int fn, int reg, int len, u32 value);
 
Index: include/asm-ia64/system.h
=================================RCS file: /var/cvs/linux/include/asm-ia64/system.h,v
retrieving revision 1.3
diff -u -p -r1.3 system.h
--- include/asm-ia64/system.h	15 May 2002 16:15:18 -0000	1.3
+++ include/asm-ia64/system.h	20 May 2002 22:07:59 -0000
@@ -15,6 +15,7 @@
 #include <linux/config.h>
 
 #include <asm/page.h>
+#include <asm/pal.h>
 
 #define KERNEL_START		(PAGE_OFFSET + 68*1024*1024)
 
@@ -100,6 +101,8 @@ ia64_insn_group_barrier (void)
  */
 #define set_mb(var, value)	do { (var) = (value); mb(); } while (0)
 #define set_wmb(var, value)	do { (var) = (value); mb(); } while (0)
+
+#define safe_halt()         ia64_pal_halt(1)                /* PAL_HALT */
 
 /*
  * The group barrier in front of the rsm & ssm are necessary to ensure

-- 
It's always legal to use Linux (TM) systems
http://www.gnu.org/philosophy/why-free.html

