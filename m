From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Mon, 22 Jul 2002 22:22:30 +0000
Subject: [Linux-ia64] [PATCH] 2.5.18 early printk, PCI segment, multi-IOMMU support
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------Boundary-00=_IT8O30XQWF10YMWHHA7A"
Message-Id: <marc-linux-ia64-105590701905804@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--------------Boundary-00=_IT8O30XQWF10YMWHHA7A
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8bit

The attached patches are for 2.5.18-ia64-020530.  They add support for
early printk on a UART, multiple PCI segments, PCI root bridge
translation offsets, and multiple HP ZX1 IOMMUs.

These have the same content as the ones I just posted for 2.4.18,
except that 2.5.18 has slightly older ACPI, has a different ZX1 "fake
device" strategy (doesn't use sysdata) and doesn't have a working ZX1
IOMMU yet.

The early printk diff includes a diff to hcdp_serial.c, which was not
in the 020530 patch.  If you have since pulled hcdp_serial.c into
2.5, that hunk will be useful, otherwise you can just ignore it.
(Without HCDP, you have to specify the UART address with
CONFIG_IA64_EARLY_PRINTK_UART_BASE.)

Tested on HP ZX1 and i2000.

10_early_printk.diff
    Early printk for MMIO UARTs.  UART address from HCDP or specified
    in config.

30_sci.diff
    Add acpi_irq_to_vector() to handle both legacy ISA and new GSI
    interrupt numbers.  Add support for SCI on GSI interrupt.

40_pcibios_segment.diff
    Add struct pci_controller for IA64 sysdata.  Stash the PCI segment
    there and add support in config accessors.

50_iosapic_segment.diff
    Add segment support for PCI interrupts.

60_pci_tra.diff
    Add support for PCI root bridges with non-zero translation
    offsets.

70_enable_device.diff
    Add a platform vector for pci_enable_device().  ZX1 needs this to
    associate a device with the correct IOMMU.
-- 
Bjorn Helgaas - bjorn_helgaas at hp.com
Linux Systems Operation R&D
Hewlett-Packard Company
--------------Boundary-00=_IT8O30XQWF10YMWHHA7A
Content-Type: text/x-diff;
  charset="us-ascii";
  name="10_early_printk.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="10_early_printk.diff"

diff -u -r linux-2.5.18-ia64-020530/arch/ia64/Config.help 10_early_printk/arch/ia64/Config.help
--- linux-2.5.18-ia64-020530/arch/ia64/Config.help	Sun Jul 21 03:03:05 2002
+++ 10_early_printk/arch/ia64/Config.help	Mon Jul 22 06:27:45 2002
@@ -502,10 +502,24 @@
   problems, but slow!  If you're unsure, select N.
 
 CONFIG_IA64_EARLY_PRINTK
-  Selecting this option uses the VGA screen for printk() output before
-  the consoles are initialised.  It is useful for debugging problems
-  early in the boot process, but only if you have a VGA screen
-  attached.  If you're unsure, select N.
+  Selecting this option uses a UART or VGA screen (or both) for
+  printk() output before the consoles are initialised.  It is useful
+  for debugging problems early in the boot process, but only if you
+  have a serial terminal or a VGA screen attached.  If you're unsure,
+  select N.
+
+CONFIG_IA64_EARLY_PRINTK_UART
+  Select this option to use a serial port for early printk() output.
+  You must either select CONFIG_SERIAL_HCDP (to locate the UART
+  using the EFI HCDP table) or set the UART address explicitly
+  with CONFIG_IA64_EARLY_PRINTK_UART_BASE.
+
+CONFIG_IA64_EARLY_PRINTK_UART_BASE
+  The physical MMIO address of the UART to use for early printk().
+  This overrides any UART located using the EFI HCDP table.
+
+CONFIG_IA64_EARLY_PRINTK_VGA
+  Select this option to use VGA for early printk() output.
 
 CONFIG_IA64_PRINT_HAZARDS
   Selecting this option prints more information for Illegal Dependency
diff -u -r linux-2.5.18-ia64-020530/arch/ia64/config.in 10_early_printk/arch/ia64/config.in
--- linux-2.5.18-ia64-020530/arch/ia64/config.in	Sun Jul 21 03:03:05 2002
+++ 10_early_printk/arch/ia64/config.in	Mon Jul 22 06:27:45 2002
@@ -255,7 +255,14 @@
    bool '  Disable VHPT' CONFIG_DISABLE_VHPT
    bool '  Magic SysRq key' CONFIG_MAGIC_SYSRQ
 
-   bool '  Early printk support (requires VGA!)' CONFIG_IA64_EARLY_PRINTK
+   bool '  Early printk support' CONFIG_IA64_EARLY_PRINTK
+   if [ "$CONFIG_IA64_EARLY_PRINTK" != "n" ]; then
+      bool '    Early printk on MMIO serial port' CONFIG_IA64_EARLY_PRINTK_UART
+      if [ "$CONFIG_IA64_EARLY_PRINTK_UART" != "n" ]; then
+         hex '      UART MMIO base address' CONFIG_IA64_EARLY_PRINTK_UART_BASE 0
+      fi
+      bool '    Early printk on VGA' CONFIG_IA64_EARLY_PRINTK_VGA
+   fi
    bool '  Debug memory allocations' CONFIG_DEBUG_SLAB
    bool '  Spinlock debugging' CONFIG_DEBUG_SPINLOCK
    bool '  Turn on compare-and-exchange bug checking (slow!)' CONFIG_IA64_DEBUG_CMPXCHG
diff -u -r linux-2.5.18-ia64-020530/kernel/printk.c 10_early_printk/kernel/printk.c
--- linux-2.5.18-ia64-020530/kernel/printk.c	Sun Jul 21 03:03:06 2002
+++ 10_early_printk/kernel/printk.c	Mon Jul 22 07:10:19 2002
@@ -693,6 +693,47 @@
 
 #ifdef CONFIG_IA64_EARLY_PRINTK
 
+#ifdef CONFIG_IA64_EARLY_PRINTK_UART
+
+#include <linux/serial_reg.h>
+#include <asm/system.h>
+
+static void early_printk_uart(const char *str, size_t len)
+{
+	static char *uart = 0;
+	unsigned long uart_base;
+	char c;
+
+	if (!uart) {
+#ifdef CONFIG_SERIAL_HCDP
+		extern unsigned long hcdp_early_uart(void);
+		uart_base = hcdp_early_uart();
+#endif
+#if CONFIG_IA64_EARLY_PRINTK_UART_BASE
+		uart_base = CONFIG_IA64_EARLY_PRINTK_UART_BASE;
+#endif
+		if (uart_base)
+			uart = ioremap(uart_base, 64);
+	}
+
+	if (!uart)
+		return;
+
+	while (len-- > 0) {
+		c = *str++;
+		while (!(UART_LSR_TEMT & readb(uart + UART_LSR)))
+			; /* spin */
+
+		writeb(c, uart + UART_TX);
+
+		if (c == '\n')
+			writeb('\r', uart + UART_TX);
+	}
+}
+#endif /* CONFIG_IA64_EARLY_PRINTK_UART */
+
+#ifdef CONFIG_IA64_EARLY_PRINTK_VGA
+
 #include <asm/io.h>
 
 #define VGABASE		((char *)0xc0000000000b8000)
@@ -701,8 +742,7 @@
 
 static int current_ypos = VGALINES, current_xpos = 0;
 
-void
-early_printk (const char *str, size_t len)
+static void early_printk_vga(const char *str, size_t len)
 {
 	char c;
 	int  i, k, j;
@@ -734,6 +774,17 @@
 			}
 		}
 	}
+}
+#endif /* CONFIG_IA64_EARLY_PRINTK_VGA */
+
+void early_printk(const char *str, size_t len)
+{
+#ifdef CONFIG_IA64_EARLY_PRINTK_UART
+	early_printk_uart(str, len);
+#endif
+#ifdef CONFIG_IA64_EARLY_PRINTK_VGA
+	early_printk_vga(str, len);
+#endif
 }
 
 #endif /* CONFIG_IA64_EARLY_PRINTK */
diff -u -r -X /home/helgaas/exclude linux-2.4.18-ia64-020719/drivers/char/hcdp_serial.c 10_early_printk/drivers/char/hcdp_serial.c
--- linux-2.4.18-ia64-020719/drivers/char/hcdp_serial.c	Sun Jul 21 03:03:29 2002
+++ 10_early_printk/drivers/char/hcdp_serial.c	Mon Jul 22 05:07:15 2002
@@ -219,3 +219,41 @@
 	printk("Leaving setup_serial_hcdp()\n");
 #endif
 }
+
+#ifdef CONFIG_IA64_EARLY_PRINTK_UART
+unsigned long hcdp_early_uart(void)
+{
+	efi_system_table_t *systab;
+	efi_config_table_t *config_tables;
+	hcdp_t *hcdp = 0;
+	hcdp_dev_t *dev;
+	int i;
+
+	systab = (efi_system_table_t *) ia64_boot_param->efi_systab;
+	if (!systab)
+		return 0;
+	systab = __va(systab);
+
+	config_tables = (efi_config_table_t *) systab->tables;
+	if (!config_tables)
+		return 0;
+	config_tables = __va(config_tables);
+
+	for (i = 0; i < systab->nr_tables; i++) {
+		if (efi_guidcmp(config_tables[i].guid, HCDP_TABLE_GUID) == 0) {
+			hcdp = (hcdp_t *) config_tables[i].table;
+			break;
+		}
+	}
+	if (!hcdp)
+		return 0;
+	hcdp = __va(hcdp);
+
+	for (i = 0, dev = hcdp->hcdp_dev; i < hcdp->num_entries; i++, dev++) {
+		if (dev->type == HCDP_DEV_CONSOLE)
+			return (u64) dev->base_addr.addrhi << 32
+				| dev->base_addr.addrlo;
+	}
+	return 0;
+}
+#endif

--------------Boundary-00=_IT8O30XQWF10YMWHHA7A
Content-Type: text/x-diff;
  charset="us-ascii";
  name="30_sci.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="30_sci.diff"

diff -u -r 10_early_printk/arch/ia64/kernel/acpi.c 30_sci/arch/ia64/kernel/acpi.c
--- 10_early_printk/arch/ia64/kernel/acpi.c	Sun Jul 21 03:03:05 2002
+++ 30_sci/arch/ia64/kernel/acpi.c	Mon Jul 22 07:19:46 2002
@@ -201,6 +201,7 @@
 static int			total_cpus __initdata;
 static int			available_cpus __initdata;
 struct acpi_table_madt *	acpi_madt __initdata;
+u8				has_8259;
 
 
 static int __init
@@ -323,9 +324,8 @@
 
 	if (iosapic_init) {
 #ifndef CONFIG_ITANIUM
-		/* PCAT_COMPAT flag indicates dual-8259 setup */
 		iosapic_init(iosapic->address, iosapic->global_irq_base,
-			     acpi_madt->flags.pcat_compat);
+			     has_8259);
 #else
 		/* Firmware on old Itanium systems is broken */
 		iosapic_init(iosapic->address, iosapic->global_irq_base, 1);
@@ -430,6 +430,8 @@
 		return -ENODEV;
 	}
 
+	has_8259 = acpi_madt->flags.pcat_compat;
+
 	/* Get base address of IPI Message Block */
 
 	if (acpi_madt->lapic_address)
@@ -442,6 +444,39 @@
 }
 
 
+static int __init
+acpi_parse_facp (unsigned long phys_addr, unsigned long size)
+{
+	struct acpi_table_header *facp_header;
+	fadt_descriptor_rev2 *facp;
+	u32 irq, irq_base = 0;
+	char *iosapic_address = NULL;
+
+	if (!phys_addr || !size)
+		return -EINVAL;
+
+	if (!iosapic_register_irq)
+		return -ENODEV;
+
+	facp_header = (struct acpi_table_header *) __va(phys_addr);
+
+	/* Only deal with ACPI 2.0 FACP */
+	if (facp_header->revision != 3)
+		return -ENODEV;
+
+	facp = (fadt_descriptor_rev2 *)facp_header;
+	irq = facp->sci_int;
+
+	if (has_8259 && irq < 16)
+		return 0;	/* legacy, no setup required */
+
+	if (!acpi_find_iosapic(irq, &irq_base, &iosapic_address))
+		iosapic_register_irq(irq, 0, 0, irq_base, iosapic_address);
+
+	return 0;
+}
+
+
 int __init
 acpi_find_rsdp (unsigned long *rsdp_phys)
 {
@@ -594,6 +629,13 @@
 		return result;
 	}
 
+	/*
+	 * The FADT table contains an SCI_INT line, by which the system
+	 * gets interrupts such as power and sleep buttons.  If it's not
+	 * on a Legacy interrupt, it needs to be setup.
+	 */
+	acpi_table_parse(ACPI_FACP, acpi_parse_facp);
+
 #ifdef CONFIG_SERIAL_ACPI
 	/*
 	 * TBD: Need phased approach to table parsing (only do those absolutely
@@ -674,6 +716,15 @@
 	*type = ACPI_INT_MODEL_IOSAPIC;
 
         return 0;
+}
+
+int
+acpi_irq_to_vector(u32 irq)
+{
+	if (has_8259 && irq < 16)
+		return isa_irq_to_vector(irq);
+
+	return iosapic_irq_to_vector(irq);
 }
 
 #endif /* CONFIG_ACPI_BOOT */
diff -u -r 10_early_printk/arch/ia64/kernel/iosapic.c 30_sci/arch/ia64/kernel/iosapic.c
--- 10_early_printk/arch/ia64/kernel/iosapic.c	Sun Jul 21 03:03:05 2002
+++ 30_sci/arch/ia64/kernel/iosapic.c	Sun Jul 21 03:03:07 2002
@@ -125,8 +125,8 @@
  * Translate IOSAPIC irq number to the corresponding IA-64 interrupt vector.  If no
  * entry exists, return -1.
  */
-static int
-iosapic_irq_to_vector (int irq)
+int
+iosapic_irq_to_vector (unsigned int irq)
 {
 	int vector;
 
diff -u -r 10_early_printk/drivers/acpi/acpi_osl.c 30_sci/drivers/acpi/acpi_osl.c
--- 10_early_printk/drivers/acpi/acpi_osl.c	Sun Jul 21 03:03:05 2002
+++ 30_sci/drivers/acpi/acpi_osl.c	Mon Jul 22 07:20:46 2002
@@ -33,6 +33,7 @@
 #include <linux/interrupt.h>
 #include <linux/kmod.h>
 #include <linux/delay.h>
+#include <linux/acpi.h>
 #include <asm/io.h>
 #include "acpi.h"
 
@@ -40,11 +41,6 @@
 #include <asm/efi.h>
 #endif
 
-#ifdef _IA64
-#include <asm/hw_irq.h>
-#include <asm/delay.h>
-#endif
-
 
 #define _COMPONENT		ACPI_OS_SERVICES
 ACPI_MODULE_NAME	("osl")
@@ -225,8 +221,15 @@
 acpi_os_install_interrupt_handler(u32 irq, OSD_HANDLER handler, void *context)
 {
 #ifdef _IA64
-	irq = isa_irq_to_vector(irq);
-#endif /*_IA64*/
+	int vector;
+
+	vector = acpi_irq_to_vector(irq);
+	if (vector < 0) {
+		printk(KERN_ERR PREFIX "SCI (IRQ%d) not registered\n", irq);
+		return AE_OK;
+	}
+	irq = vector;
+#endif
 	acpi_irq_irq = irq;
 	acpi_irq_handler = handler;
 	acpi_irq_context = context;
@@ -243,8 +246,8 @@
 {
 	if (acpi_irq_handler) {
 #ifdef _IA64
-		irq = isa_irq_to_vector(irq);
-#endif /*_IA64*/
+		irq = acpi_irq_to_vector(irq);
+#endif
 		free_irq(irq, acpi_irq);
 		acpi_irq_handler = NULL;
 	}
diff -u -r 10_early_printk/include/asm-ia64/iosapic.h 30_sci/include/asm-ia64/iosapic.h
--- 10_early_printk/include/asm-ia64/iosapic.h	Fri May 24 19:55:28 2002
+++ 30_sci/include/asm-ia64/iosapic.h	Sun Jul 21 03:03:07 2002
@@ -53,6 +53,7 @@
 
 extern void __init iosapic_init (unsigned long address, unsigned int base_irq,
                                  int pcat_compat);
+extern int iosapic_irq_to_vector (unsigned int irq);
 extern int iosapic_register_irq (u32 global_vector, unsigned long polarity,
                                  unsigned long edge_triggered, u32 base_irq,
                                  char *iosapic_address);
diff -u -r 10_early_printk/include/linux/acpi.h 30_sci/include/linux/acpi.h
--- 10_early_printk/include/linux/acpi.h	Sun Jul 21 03:05:25 2002
+++ 30_sci/include/linux/acpi.h	Sun Jul 21 03:21:51 2002
@@ -389,6 +389,7 @@
 #ifdef CONFIG_ACPI_INTERPRETER
 
 int acpi_init(void);
+int acpi_irq_to_vector(u32 irq);
 
 #endif /*CONFIG_ACPI_INTERPRETER*/
 

--------------Boundary-00=_IT8O30XQWF10YMWHHA7A
Content-Type: text/x-diff;
  charset="us-ascii";
  name="40_pcibios_segment.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="40_pcibios_segment.diff"

diff -u -r 30_sci/arch/ia64/kernel/pci.c 40_pcibios_segment/arch/ia64/kernel/pci.c
--- 30_sci/arch/ia64/kernel/pci.c	Mon Jul 22 07:25:09 2002
+++ 40_pcibios_segment/arch/ia64/kernel/pci.c	Mon Jul 22 09:55:40 2002
@@ -53,11 +53,12 @@
 /*
  * Low-level SAL-based PCI configuration access functions. Note that SAL
  * calls are already serialized (via sal_lock), so we don't need another
- * synchronization mechanism here.  Not using segment number (yet).
+ * synchronization mechanism here.
  */
 
-#define PCI_SAL_ADDRESS(bus, dev, fn, reg) \
-	((u64)(bus << 16) | (u64)(dev << 11) | (u64)(fn << 8) | (u64)(reg))
+#define PCI_SAL_ADDRESS(seg, bus, dev, fn, reg) \
+	((u64)(seg << 24) | (u64)(bus << 16) | \
+	 (u64)(dev << 11) | (u64)(fn << 8) | (u64)(reg))
 
 static int
 pci_sal_read (int seg, int bus, int dev, int fn, int reg, int len, u32 *value)
@@ -65,10 +66,10 @@
 	int result = 0;
 	u64 data = 0;
 
-	if (!value || (bus > 255) || (dev > 31) || (fn > 7) || (reg > 255))
+	if (!value || (seg > 255) || (bus > 255) || (dev > 31) || (fn > 7) || (reg > 255))
 		return -EINVAL;
 
-	result = ia64_sal_pci_config_read(PCI_SAL_ADDRESS(bus, dev, fn, reg), len, &data);
+	result = ia64_sal_pci_config_read(PCI_SAL_ADDRESS(seg, bus, dev, fn, reg), len, &data);
 
 	*value = (u32) data;
 
@@ -78,10 +79,10 @@
 static int
 pci_sal_write (int seg, int bus, int dev, int fn, int reg, int len, u32 value)
 {
-	if ((bus > 255) || (dev > 31) || (fn > 7) || (reg > 255))
+	if ((seg > 255) || (bus > 255) || (dev > 31) || (fn > 7) || (reg > 255))
 		return -EINVAL;
 
-	return ia64_sal_pci_config_write(PCI_SAL_ADDRESS(bus, dev, fn, reg), len, value);
+	return ia64_sal_pci_config_write(PCI_SAL_ADDRESS(seg, bus, dev, fn, reg), len, value);
 }
 
 
@@ -94,7 +95,7 @@
 	if (!value)
 		return -EINVAL;
 
-	result = pci_sal_read(0, dev->bus->number, PCI_SLOT(dev->devfn),
+	result = pci_sal_read(PCI_SEGMENT(dev), dev->bus->number, PCI_SLOT(dev->devfn),
 			      PCI_FUNC(dev->devfn), where, 1, &data);
 
 	*value = (u8) data;
@@ -111,7 +112,7 @@
 	if (!value)
 		return -EINVAL;
 
-	result = pci_sal_read(0, dev->bus->number, PCI_SLOT(dev->devfn),
+	result = pci_sal_read(PCI_SEGMENT(dev), dev->bus->number, PCI_SLOT(dev->devfn),
 			      PCI_FUNC(dev->devfn), where, 2, &data);
 
 	*value = (u16) data;
@@ -125,28 +126,28 @@
 	if (!value)
 		return -EINVAL;
 
-	return pci_sal_read(0, dev->bus->number, PCI_SLOT(dev->devfn),
+	return pci_sal_read(PCI_SEGMENT(dev), dev->bus->number, PCI_SLOT(dev->devfn),
 			    PCI_FUNC(dev->devfn), where, 4, value);
 }
 
 static int
 pci_sal_write_config_byte (struct pci_dev *dev, int where, u8 value)
 {
-	return pci_sal_write(0, dev->bus->number, PCI_SLOT(dev->devfn),
+	return pci_sal_write(PCI_SEGMENT(dev), dev->bus->number, PCI_SLOT(dev->devfn),
 			     PCI_FUNC(dev->devfn), where, 1, value);
 }
 
 static int
 pci_sal_write_config_word (struct pci_dev *dev, int where, u16 value)
 {
-	return pci_sal_write(0, dev->bus->number, PCI_SLOT(dev->devfn),
+	return pci_sal_write(PCI_SEGMENT(dev), dev->bus->number, PCI_SLOT(dev->devfn),
 			     PCI_FUNC(dev->devfn), where, 2, value);
 }
 
 static int
 pci_sal_write_config_dword (struct pci_dev *dev, int where, u32 value)
 {
-	return pci_sal_write(0, dev->bus->number, PCI_SLOT(dev->devfn),
+	return pci_sal_write(PCI_SEGMENT(dev), dev->bus->number, PCI_SLOT(dev->devfn),
 			     PCI_FUNC(dev->devfn), where, 4, value);
 }
 
@@ -164,24 +165,64 @@
  * Initialization. Uses the SAL interface
  */
 
-struct pci_bus *
-pcibios_scan_root(int seg, int bus)
+static struct pci_controller *
+alloc_pci_controller(int seg)
+{
+	struct pci_controller *controller;
+
+	controller = kmalloc(sizeof(*controller), GFP_KERNEL);
+	if (!controller)
+		return NULL;
+
+	memset(controller, 0, sizeof(*controller));
+	controller->segment = seg;
+	return controller;
+}
+
+static struct pci_bus *
+scan_root_bus(int bus, struct pci_ops *ops, void *sysdata)
 {
-	struct list_head *list = NULL;
-	struct pci_bus *pci_bus = NULL;
+	struct pci_bus *b;
+
+	/*
+	 * We know this is a new root bus we haven't seen before, so
+	 * scan it, even if we've seen the same bus number in a different
+	 * segment.
+	 */
+	b = kmalloc(sizeof(*b), GFP_KERNEL);
+	if (!b)
+		return NULL;
+
+	memset(b, 0, sizeof(*b));
+	INIT_LIST_HEAD(&b->children);
+	INIT_LIST_HEAD(&b->devices);
 
-	list_for_each(list, &pci_root_buses) {
-		pci_bus = pci_bus_b(list);
-		if (pci_bus->number == bus) {
-			/* Already scanned */
-			printk("PCI: Bus (%02x:%02x) already probed\n", seg, bus);
-			return pci_bus;
-		}
-	}
+	list_add_tail(&b->node, &pci_root_buses);
+
+	b->number = b->secondary = bus;
+	b->resource[0] = &ioport_resource;
+	b->resource[1] = &iomem_resource;
+
+	b->sysdata = sysdata;
+	b->ops = ops;
+	b->subordinate = pci_do_scan_bus(b);
+
+	return b;
+}
+
+struct pci_bus *
+pcibios_scan_root(void *handle, int seg, int bus)
+{
+	struct pci_controller *controller;
 
 	printk("PCI: Probing PCI hardware on bus (%02x:%02x)\n", seg, bus);
 
-	return pci_scan_bus(bus, pci_root_ops, NULL);
+	controller = alloc_pci_controller(seg);
+	if (!controller)
+		return NULL;
+
+	controller->acpi_handle = handle;
+	return scan_root_bus(bus, pci_root_ops, controller);
 }
 
 void __init
@@ -204,6 +245,7 @@
 {
 #	define PCI_BUSES_TO_SCAN 255
 	int i = 0;
+	struct pci_controller *controller;
 
 #ifdef CONFIG_IA64_MCA
 	ia64_mca_check_errors();    /* For post-failure MCA error logging */
@@ -214,8 +256,10 @@
 	platform_pci_fixup(0);	/* phase 0 fixups (before buses scanned) */
 
 	printk("PCI: Probing PCI hardware\n");
-	for (i = 0; i < PCI_BUSES_TO_SCAN; i++)
-		pci_scan_bus(i, pci_root_ops, NULL);
+	controller = alloc_pci_controller(0);
+	if (controller)
+		for (i = 0; i < PCI_BUSES_TO_SCAN; i++)
+			pci_scan_bus(i, pci_root_ops, controller);
 
 	platform_pci_fixup(1);	/* phase 1 fixups (after buses scanned) */
 	return 0;
diff -u -r 30_sci/drivers/acpi/acpi_pci_root.c 40_pcibios_segment/drivers/acpi/acpi_pci_root.c
--- 30_sci/drivers/acpi/acpi_pci_root.c	Mon Jul 22 07:25:09 2002
+++ 40_pcibios_segment/drivers/acpi/acpi_pci_root.c	Mon Jul 22 09:55:40 2002
@@ -653,7 +653,7 @@
 	 * PCI namespace does not get created until this call is made (and 
 	 * thus the root bridge's pci_dev does not exist).
 	 */
-	root->data.bus = pcibios_scan_root(root->data.id.segment, root->data.id.bus);
+	root->data.bus = pcibios_scan_root(root->handle, root->data.id.segment, root->data.id.bus);
 	if (!root->data.bus) {
 		ACPI_DEBUG_PRINT((ACPI_DB_ERROR, 
 			"Bus %02x:%02x not present in PCI namespace\n", 
diff -u -r 30_sci/include/asm-ia64/pci.h 40_pcibios_segment/include/asm-ia64/pci.h
--- 30_sci/include/asm-ia64/pci.h	Mon Jul 22 07:35:12 2002
+++ 40_pcibios_segment/include/asm-ia64/pci.h	Mon Jul 22 09:55:40 2002
@@ -21,7 +21,7 @@
 #define PCIBIOS_MIN_MEM		0x10000000
 
 void pcibios_config_init(void);
-struct pci_bus * pcibios_scan_root(int seg, int bus);
+struct pci_bus *pcibios_scan_root(void *acpi_handle, int segment, int bus);
 extern int (*pci_config_read)(int seg, int bus, int dev, int fn, int reg, int len, u32 *value);
 extern int (*pci_config_write)(int seg, int bus, int dev, int fn, int reg, int len, u32 value);
 
@@ -95,5 +95,13 @@
 #define HAVE_PCI_MMAP
 extern int pci_mmap_page_range (struct pci_dev *dev, struct vm_area_struct *vma,
 				enum pci_mmap_state mmap_state, int write_combine);
+
+struct pci_controller {
+	void *acpi_handle;
+	int segment;
+};
+
+#define PCI_CONTROLLER(dev) ((struct pci_controller *) dev->sysdata)
+#define PCI_SEGMENT(dev)    (PCI_CONTROLLER(dev)->segment)
 
 #endif /* _ASM_IA64_PCI_H */

--------------Boundary-00=_IT8O30XQWF10YMWHHA7A
Content-Type: text/x-diff;
  charset="us-ascii";
  name="50_iosapic_segment.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="50_iosapic_segment.diff"

diff -u -r 40_pcibios_segment/arch/ia64/kernel/acpi.c 50_iosapic_segment/arch/ia64/kernel/acpi.c
--- 40_pcibios_segment/arch/ia64/kernel/acpi.c	Mon Jul 22 09:52:13 2002
+++ 50_iosapic_segment/arch/ia64/kernel/acpi.c	Mon Jul 22 09:54:02 2002
@@ -695,6 +695,7 @@
 
 	list_for_each(node, &acpi_prts.entries) {
 		entry = (struct acpi_prt_entry *)node;
+		vector[i].segment = entry->id.seg;
 		vector[i].bus    = entry->id.bus;
 		vector[i].pci_id = ((u32) entry->id.dev << 16) | 0xffff;
 		vector[i].pin    = entry->id.pin;
diff -u -r 40_pcibios_segment/arch/ia64/kernel/iosapic.c 50_iosapic_segment/arch/ia64/kernel/iosapic.c
--- 40_pcibios_segment/arch/ia64/kernel/iosapic.c	Mon Jul 22 09:52:13 2002
+++ 50_iosapic_segment/arch/ia64/kernel/iosapic.c	Mon Jul 22 09:54:02 2002
@@ -26,12 +26,13 @@
  * 02/04/18	J.I. Lee	bug fix in iosapic_init_pci_irq
  * 02/04/30	J.I. Lee	bug fix in find_iosapic to fix ACPI PCI IRQ to IOSAPIC mapping
  *				error
+ * 02/07/11	B. Helgaas	Support PCI segments
  */
 /*
  * Here is what the interrupt logic between a PCI device and the CPU looks like:
  *
  * (1) A PCI device raises one of the four interrupt pins (INTA, INTB, INTC, INTD).  The
- *     device is uniquely identified by its bus--, and slot-number (the function
+ *     device is uniquely identified by its segment--, bus--, and slot-number (the function
  *     number does not matter here because all functions share the same interrupt
  *     lines).
  *
@@ -141,12 +142,13 @@
  * return -1.
  */
 int
-pci_pin_to_vector (int bus, int slot, int pci_pin)
+pci_pin_to_vector (int segment, int bus, int slot, int pci_pin)
 {
 	struct pci_vector_struct *r;
 
 	for (r = pci_irq.route; r < pci_irq.route + pci_irq.num_routes; ++r)
-		if (r->bus == bus && (r->pci_id >> 16) == slot && r->pin == pci_pin)
+		if (r->segment == segment && r->bus == bus &&
+		    (r->pci_id >> 16) == slot && r->pin == pci_pin)
 			return iosapic_irq_to_vector(r->irq);
 	return -1;
 }
@@ -691,6 +693,7 @@
 iosapic_pci_fixup (int phase)
 {
 	struct	pci_dev	*dev;
+	int segment;
 	unsigned char pin;
 	int vector;
 	struct hw_interrupt_type *irq_type;
@@ -708,7 +711,8 @@
 		pci_read_config_byte(dev, PCI_INTERRUPT_PIN, &pin);
 		if (pin) {
 			pin--;          /* interrupt pins are numbered starting from 1 */
-			vector = pci_pin_to_vector(dev->bus->number, PCI_SLOT(dev->devfn), pin);
+			segment = PCI_SEGMENT(dev);
+			vector = pci_pin_to_vector(segment, dev->bus->number, PCI_SLOT(dev->devfn), pin);
 			if (vector < 0 && dev->bus->parent) {
 				/* go back to the bridge */
 				struct pci_dev *bridge = dev->bus->self;
@@ -718,7 +722,7 @@
 					do {
 						/* do the bridge swizzle... */
 						pin = (pin + PCI_SLOT(dev->devfn)) % 4;
-						vector = pci_pin_to_vector(bridge->bus->number,
+						vector = pci_pin_to_vector(segment, bridge->bus->number,
 									   PCI_SLOT(bridge->devfn),
 									   pin);
 					} while (vector < 0 && (bridge = bridge->bus->self));
diff -u -r 40_pcibios_segment/include/asm-ia64/system.h 50_iosapic_segment/include/asm-ia64/system.h
--- 40_pcibios_segment/include/asm-ia64/system.h	Mon Jul 22 07:43:12 2002
+++ 50_iosapic_segment/include/asm-ia64/system.h	Mon Jul 22 09:54:02 2002
@@ -29,6 +29,7 @@
 #include <linux/types.h>
 
 struct pci_vector_struct {
+	__u16 segment;	/* PCI Segment number */
 	__u16 bus;	/* PCI Bus number */
 	__u32 pci_id;	/* ACPI split 16 bits device, 16 bits function (see section 6.1.1) */
 	__u8 pin;	/* PCI PIN (0 = A, 1 = B, 2 = C, 3 = D) */

--------------Boundary-00=_IT8O30XQWF10YMWHHA7A
Content-Type: text/x-diff;
  charset="us-ascii";
  name="60_pci_tra.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="60_pci_tra.diff"

diff -u -r 50_iosapic_segment/arch/ia64/kernel/acpi.c 60_pci_tra/arch/ia64/kernel/acpi.c
--- 50_iosapic_segment/arch/ia64/kernel/acpi.c	Fri Jul 19 17:24:49 2002
+++ 60_pci_tra/arch/ia64/kernel/acpi.c	Fri Jul 19 17:24:50 2002
@@ -166,6 +166,73 @@
 	kfree(buf->pointer);
 }
 
+static void
+acpi_get_crs_addr (acpi_buffer *buf, int type, u64 *base, u64 *size, u64 *tra)
+{
+	int offset = 0;
+	acpi_resource_address16 *addr16;
+	acpi_resource_address32 *addr32;
+	acpi_resource_address64 *addr64;
+
+	for (;;) {
+		acpi_resource *res = acpi_get_crs_next(buf, &offset);
+		if (!res)
+			return;
+		switch (res->id) {
+			case ACPI_RSTYPE_ADDRESS16:
+				addr16 = (acpi_resource_address16 *) &res->data;
+
+				if (type == addr16->resource_type) {
+					*base = addr16->min_address_range;
+					*size = addr16->address_length;
+					*tra = addr16->address_translation_offset;
+					return;
+				}
+				break;
+			case ACPI_RSTYPE_ADDRESS32:
+				addr32 = (acpi_resource_address32 *) &res->data;
+				if (type == addr32->resource_type) {
+					*base = addr32->min_address_range;
+					*size = addr32->address_length;
+					*tra = addr32->address_translation_offset;
+					return;
+				}
+				break;
+			case ACPI_RSTYPE_ADDRESS64:
+				addr64 = (acpi_resource_address64 *) &res->data;
+				if (type == addr64->resource_type) {
+					*base = addr64->min_address_range;
+					*size = addr64->address_length;
+					*tra = addr64->address_translation_offset;
+					return;
+				}
+				break;
+		}
+	}
+}
+
+acpi_status
+acpi_get_addr_space(acpi_handle obj, u8 type, u64 *base, u64 *length, u64 *tra)
+{
+	acpi_status status;
+	acpi_buffer buf;
+
+	*base = 0;
+	*length = 0;
+	*tra = 0;
+
+	status = acpi_get_crs(obj, &buf);
+	if (ACPI_FAILURE(status)) {
+		printk(KERN_ERR PREFIX "Unable to get _CRS data on object\n");
+		return status;
+	}
+
+	acpi_get_crs_addr(&buf, type, base, length, tra);
+
+	acpi_dispose_crs(&buf);
+
+	return AE_OK;
+}
 #endif /* CONFIG_ACPI */
 
 #ifdef CONFIG_ACPI_BOOT
diff -u -r 50_iosapic_segment/arch/ia64/kernel/pci.c 60_pci_tra/arch/ia64/kernel/pci.c
--- 50_iosapic_segment/arch/ia64/kernel/pci.c	Fri Jul 19 17:24:49 2002
+++ 60_pci_tra/arch/ia64/kernel/pci.c	Fri Jul 19 17:24:50 2002
@@ -13,6 +13,7 @@
 #include <linux/slab.h>
 #include <linux/smp_lock.h>
 #include <linux/spinlock.h>
+#include <linux/acpi.h>
 
 #include <asm/machvec.h>
 #include <asm/page.h>
@@ -214,6 +215,7 @@
 pcibios_scan_root(void *handle, int seg, int bus)
 {
 	struct pci_controller *controller;
+	u64 base, size, offset;
 
 	printk("PCI: Probing PCI hardware on bus (%02x:%02x)\n", seg, bus);
 
@@ -222,6 +224,10 @@
 		return NULL;
 
 	controller->acpi_handle = handle;
+
+	acpi_get_addr_space(handle, ACPI_MEMORY_RANGE, &base, &size, &offset);
+	controller->mem_offset = offset;
+
 	return scan_root_bus(bus, pci_root_ops, controller);
 }
 
@@ -267,6 +273,27 @@
 
 subsys_initcall(pcibios_init);
 
+static void __init
+pcibios_fixup_resource(struct resource *res, u64 offset)
+{
+	res->start += offset;
+	res->end += offset;
+}
+
+void __init
+pcibios_fixup_device_resources(struct pci_dev *dev, struct pci_bus *bus)
+{
+	int i;
+
+	for (i = 0; i < PCI_NUM_RESOURCES; i++) {
+		if (!dev->resource[i].start)
+			continue;
+		if (dev->resource[i].flags & IORESOURCE_MEM)
+			pcibios_fixup_resource(&dev->resource[i],
+				PCI_CONTROLLER(dev)->mem_offset);
+	}
+}
+
 /*
  *  Called after each bus is probed, but before its children
  *  are examined.
@@ -274,7 +301,10 @@
 void __init
 pcibios_fixup_bus (struct pci_bus *b)
 {
-	return;
+	struct list_head *ln;
+
+	for (ln = b->devices.next; ln != &b->devices; ln = ln->next)
+		pcibios_fixup_device_resources(pci_dev_b(ln), b);
 }
 
 void __init
diff -u -r 50_iosapic_segment/include/asm-ia64/pci.h 60_pci_tra/include/asm-ia64/pci.h
--- 50_iosapic_segment/include/asm-ia64/pci.h	Fri Jul 19 17:24:49 2002
+++ 60_pci_tra/include/asm-ia64/pci.h	Fri Jul 19 17:24:50 2002
@@ -99,6 +99,8 @@
 struct pci_controller {
 	void *acpi_handle;
 	int segment;
+
+	u64 mem_offset;
 };
 
 #define PCI_CONTROLLER(dev) ((struct pci_controller *) dev->sysdata)
diff -u -r 50_iosapic_segment/include/linux/acpi.h 60_pci_tra/include/linux/acpi.h
--- 50_iosapic_segment/include/linux/acpi.h	Fri Jul 19 17:24:49 2002
+++ 60_pci_tra/include/linux/acpi.h	Fri Jul 19 17:30:06 2002
@@ -390,6 +390,7 @@
 
 int acpi_init(void);
 int acpi_irq_to_vector(u32 irq);
+acpi_status acpi_get_addr_space(acpi_handle, u8 type, u64 *base, u64 *length, u64 *tra);
 
 #endif /*CONFIG_ACPI_INTERPRETER*/
 

--------------Boundary-00=_IT8O30XQWF10YMWHHA7A
Content-Type: text/x-diff;
  charset="us-ascii";
  name="70_enable_device.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="70_enable_device.diff"

diff -u -r 60_pci_tra/arch/ia64/kernel/pci.c 70_enable_device/arch/ia64/kernel/pci.c
--- 60_pci_tra/arch/ia64/kernel/pci.c	Mon Jul 22 09:57:07 2002
+++ 70_enable_device/arch/ia64/kernel/pci.c	Mon Jul 22 09:59:09 2002
@@ -342,8 +342,7 @@
 	if (!dev)
 		return -EINVAL;
 
-	/* Not needed, since we enable all devices at startup.  */
-
+ 	platform_pci_enable_device(dev);
 	printk(KERN_INFO "PCI: Found IRQ %d for device %s\n", dev->irq, dev->slot_name);
 	return 0;
 }
diff -u -r 60_pci_tra/include/asm-ia64/machvec.h 70_enable_device/include/asm-ia64/machvec.h
--- 60_pci_tra/include/asm-ia64/machvec.h	Mon Jul 22 07:59:47 2002
+++ 70_enable_device/include/asm-ia64/machvec.h	Mon Jul 22 09:59:09 2002
@@ -24,6 +24,7 @@
 typedef void ia64_mv_cpu_init_t(void);
 typedef void ia64_mv_irq_init_t (void);
 typedef void ia64_mv_pci_fixup_t (int);
+typedef void ia64_mv_pci_enable_device_t (struct pci_dev *);
 typedef unsigned long ia64_mv_map_nr_t (unsigned long);
 typedef void ia64_mv_mca_init_t (void);
 typedef void ia64_mv_mca_handler_t (void);
@@ -92,7 +93,8 @@
 #  define platform_cmci_handler	ia64_mv.cmci_handler
 #  define platform_log_print	ia64_mv.log_print
 #  define platform_pci_fixup	ia64_mv.pci_fixup
-#  define platform_send_ipi	ia64_mv.send_ipi
+#  define platform_pci_enable_device	ia64_mv.pci_enable_device
+#  define platform_send_ipi		ia64_mv.send_ipi
 #  define platform_global_tlb_purge	ia64_mv.global_tlb_purge
 #  define platform_pci_dma_init		ia64_mv.dma_init
 #  define platform_pci_alloc_consistent	ia64_mv.alloc_consistent
@@ -123,6 +125,7 @@
 	ia64_mv_cpu_init_t *cpu_init;
 	ia64_mv_irq_init_t *irq_init;
 	ia64_mv_pci_fixup_t *pci_fixup;
+	ia64_mv_pci_enable_device_t *pci_enable_device;
 	ia64_mv_map_nr_t *map_nr;
 	ia64_mv_mca_init_t *mca_init;
 	ia64_mv_mca_handler_t *mca_handler;
@@ -160,6 +163,7 @@
 	platform_cpu_init,			\
 	platform_irq_init,			\
 	platform_pci_fixup,			\
+	platform_pci_enable_device,		\
 	platform_map_nr,			\
 	platform_mca_init,			\
 	platform_mca_handler,			\
@@ -238,6 +242,9 @@
 #endif
 #ifndef platform_pci_fixup
 # define platform_pci_fixup	((ia64_mv_pci_fixup_t *) machvec_noop)
+#endif
+#ifndef platform_pci_enable_device
+# define platform_pci_enable_device	((ia64_mv_pci_enable_device_t *) machvec_noop)
 #endif
 #ifndef platform_send_ipi
 # define platform_send_ipi	ia64_send_ipi	/* default to architected version */

--------------Boundary-00=_IT8O30XQWF10YMWHHA7A--


