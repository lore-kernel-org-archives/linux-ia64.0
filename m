From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Mon, 22 Jul 2002 22:15:49 +0000
Subject: [Linux-ia64] [PATCH] 2.4.18 early printk, PCI segment, multi-IOMMU support
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------Boundary-00=_DI8OG9N44J5EWH7I4DL4"
Message-Id: <marc-linux-ia64-105590701905803@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--------------Boundary-00=_DI8OG9N44J5EWH7I4DL4
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8bit

The attached patches are for 2.4.18-ia64-020719.  They add support for
early printk on a UART, multiple PCI segments, PCI root bridge
translation offsets, and multiple HP ZX1 IOMMUs.

Tested on HP ZX1 and i2000.

10_early_printk.diff
    Early printk for MMIO UARTs.  UART address from HCDP or specified
    in config.

20_iosapic_gsi.diff
    Remove gsi_to_vector(), which had a hard-coded limit on the range
    of GSIs.

30_sci.diff
    Add acpi_irq_to_vector() to handle both legacy ISA and new GSI
    interrupt numbers.  Add support for SCI on GSI interrupt.

40_pcibios_segment.diff
    Add struct pci_controller for IA64 sysdata.  Stash the PCI segment
    there and add support in config accessors.  The HP ZX1 "fake dev"
    stuff that used to be stored in sysdata is pushed down a level (I
    hope to get rid of this completely soon).

50_iosapic_segment.diff
    Add segment support for PCI interrupts.

60_pci_tra.diff
    Add support for PCI root bridges with non-zero translation
    offsets.

70_enable_device.diff
    Add a platform vector for pci_enable_device().  ZX1 needs this to
    associate a device with the correct IOMMU.

80_multi_ioc.diff
    Support multiple ZX1 IOMMUs, discovered via ACPI (not "fake dev"
    stuff).
-- 
Bjorn Helgaas - bjorn_helgaas at hp.com
Linux Systems Operation R&D
Hewlett-Packard Company
--------------Boundary-00=_DI8OG9N44J5EWH7I4DL4
Content-Type: text/x-diff;
  charset="us-ascii";
  name="10_early_printk.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="10_early_printk.diff"

diff -u -r -X /home/helgaas/exclude linux-2.4.18-ia64-020719/Documentation/Configure.help 10_early_printk/Documentation/Configure.help
--- linux-2.4.18-ia64-020719/Documentation/Configure.help	Sun Jul 21 03:03:28 2002
+++ 10_early_printk/Documentation/Configure.help	Sun Jul 21 03:03:31 2002
@@ -23866,12 +23866,29 @@
   and restore instructions.  It's useful for tracking down spinlock
   problems, but slow!  If you're unsure, select N.
 
-Early printk support (requires VGA!)
+Early printk support
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
+Early printk on serial port
+CONFIG_IA64_EARLY_PRINTK_UART
+  Select this option to use a serial port for early printk() output.
+  You must either select CONFIG_SERIAL_HCDP (to locate the UART
+  using the EFI HCDP table) or set the UART address explicitly
+  with CONFIG_IA64_EARLY_PRINTK_UART_BASE.
+
+UART base address
+CONFIG_IA64_EARLY_PRINTK_UART_BASE
+  The physical MMIO address of the UART to use for early printk().
+  This overrides any UART located using the EFI HCDP table.
+
+Early printk on VGA
+CONFIG_IA64_EARLY_PRINTK_VGA
+  Select this option to use VGA for early printk() output.
 
 Print possible IA64 hazards to console
 CONFIG_IA64_PRINT_HAZARDS
diff -u -r -X /home/helgaas/exclude linux-2.4.18-ia64-020719/arch/ia64/config.in 10_early_printk/arch/ia64/config.in
--- linux-2.4.18-ia64-020719/arch/ia64/config.in	Sun Jul 21 03:03:28 2002
+++ 10_early_printk/arch/ia64/config.in	Sun Jul 21 03:03:31 2002
@@ -294,7 +294,14 @@
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
diff -u -r -X /home/helgaas/exclude linux-2.4.18-ia64-020719/kernel/printk.c 10_early_printk/kernel/printk.c
--- linux-2.4.18-ia64-020719/kernel/printk.c	Sun Jul 21 03:03:30 2002
+++ 10_early_printk/kernel/printk.c	Mon Jul 22 05:05:47 2002
@@ -694,6 +694,47 @@
 
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
@@ -702,8 +743,7 @@
 
 static int current_ypos = VGALINES, current_xpos = 0;
 
-void
-early_printk (const char *str, size_t len)
+static void early_printk_vga(const char *str, size_t len)
 {
 	char c;
 	int  i, k, j;
@@ -735,6 +775,17 @@
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

--------------Boundary-00=_DI8OG9N44J5EWH7I4DL4
Content-Type: text/x-diff;
  charset="us-ascii";
  name="20_iosapic_gsi.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="20_iosapic_gsi.diff"

diff -u -r 10_early_printk/arch/ia64/kernel/ia64_ksyms.c 20_iosapic_gsi/arch/ia64/kernel/ia64_ksyms.c
--- 10_early_printk/arch/ia64/kernel/ia64_ksyms.c	Sat Jul 20 16:31:07 2002
+++ 20_iosapic_gsi/arch/ia64/kernel/ia64_ksyms.c	Sat Jul 20 16:32:16 2002
@@ -28,7 +28,6 @@
 
 #include <linux/irq.h>
 EXPORT_SYMBOL(isa_irq_to_vector_map);
-EXPORT_SYMBOL(gsi_to_vector_map);
 EXPORT_SYMBOL(enable_irq);
 EXPORT_SYMBOL(disable_irq);
 EXPORT_SYMBOL(disable_irq_nosync);
diff -u -r 10_early_printk/arch/ia64/kernel/iosapic.c 20_iosapic_gsi/arch/ia64/kernel/iosapic.c
--- 10_early_printk/arch/ia64/kernel/iosapic.c	Sat Jul 20 16:31:07 2002
+++ 20_iosapic_gsi/arch/ia64/kernel/iosapic.c	Sat Jul 20 16:32:16 2002
@@ -421,7 +421,6 @@
 	irq_desc_t *idesc;
 	struct hw_interrupt_type *irq_type;
 
-	gsi_to_vector(global_vector) = vector;
 	iosapic_irq[vector].pin	= pin;
 	iosapic_irq[vector].polarity = polarity ? IOSAPIC_POL_HIGH : IOSAPIC_POL_LOW;
 	iosapic_irq[vector].dmode    = delivery;
diff -u -r 10_early_printk/arch/ia64/kernel/irq_ia64.c 20_iosapic_gsi/arch/ia64/kernel/irq_ia64.c
--- 10_early_printk/arch/ia64/kernel/irq_ia64.c	Sat Jul 20 16:31:07 2002
+++ 20_iosapic_gsi/arch/ia64/kernel/irq_ia64.c	Sat Jul 20 16:32:16 2002
@@ -54,11 +54,6 @@
 	0x28, 0x27, 0x26, 0x25, 0x24, 0x23, 0x22, 0x21
 };
 
-/*
- * GSI to IA-64 vector translation table.
- */
-__u8 gsi_to_vector_map[255];
-
 int
 ia64_alloc_irq (void)
 {
diff -u -r 10_early_printk/drivers/acpi/osl.c 20_iosapic_gsi/drivers/acpi/osl.c
--- 10_early_printk/drivers/acpi/osl.c	Sat Jul 20 16:31:08 2002
+++ 20_iosapic_gsi/drivers/acpi/osl.c	Sat Jul 20 16:32:16 2002
@@ -235,7 +235,7 @@
 acpi_os_install_interrupt_handler(u32 irq, OSD_HANDLER handler, void *context)
 {
 #ifdef CONFIG_IA64
-	irq = gsi_to_vector(irq);
+	irq = isa_irq_to_vector(irq);
 #endif /* CONFIG_IA64 */
 	acpi_irq_irq = irq;
 	acpi_irq_handler = handler;
@@ -253,7 +253,7 @@
 {
 	if (acpi_irq_handler) {
 #ifdef CONFIG_IA64
-		irq = gsi_to_vector(irq);
+		irq = isa_irq_to_vector(irq);
 #endif /* CONFIG_IA64 */
 		free_irq(irq, acpi_irq);
 		acpi_irq_handler = NULL;
diff -u -r 10_early_printk/include/asm-ia64/hw_irq.h 20_iosapic_gsi/include/asm-ia64/hw_irq.h
--- 10_early_printk/include/asm-ia64/hw_irq.h	Sat Jul 20 16:31:09 2002
+++ 20_iosapic_gsi/include/asm-ia64/hw_irq.h	Sat Jul 20 16:32:16 2002
@@ -67,8 +67,6 @@
 
 extern __u8 isa_irq_to_vector_map[16];
 #define isa_irq_to_vector(x)	isa_irq_to_vector_map[(x)]
-extern __u8 gsi_to_vector_map[255];
-#define gsi_to_vector(x)	gsi_to_vector_map[(x)]
 
 extern unsigned long ipi_base_addr;
 

--------------Boundary-00=_DI8OG9N44J5EWH7I4DL4
Content-Type: text/x-diff;
  charset="us-ascii";
  name="30_sci.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="30_sci.diff"

diff -u -r -X /home/helgaas/exclude 20_iosapic_gsi/arch/ia64/kernel/acpi.c 30_sci/arch/ia64/kernel/acpi.c
--- 20_iosapic_gsi/arch/ia64/kernel/acpi.c	Sun Jul 21 03:03:28 2002
+++ 30_sci/arch/ia64/kernel/acpi.c	Mon Jul 22 04:56:58 2002
@@ -213,6 +213,7 @@
 static int			total_cpus __initdata;
 static int			available_cpus __initdata;
 struct acpi_table_madt *	acpi_madt __initdata;
+u8				has_8259;
 
 
 static int __init
@@ -335,9 +336,8 @@
 
 	if (iosapic_init) {
 #ifndef CONFIG_ITANIUM
-		/* PCAT_COMPAT flag indicates dual-8259 setup */
 		iosapic_init(iosapic->address, iosapic->global_irq_base,
-			     acpi_madt->flags.pcat_compat);
+			     has_8259);
 #else
 		/* Firmware on old Itanium systems is broken */
 		iosapic_init(iosapic->address, iosapic->global_irq_base, 1);
@@ -444,6 +444,8 @@
 		return -ENODEV;
 	}
 
+	has_8259 = acpi_madt->flags.pcat_compat;
+
 	/* Initialize platform interrupt vector array */
 
 	for (i = 0; i < ACPI_MAX_PLATFORM_IRQS; i++)
@@ -461,6 +463,39 @@
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
 unsigned long __init
 acpi_find_rsdp (void)
 {
@@ -611,6 +646,13 @@
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
@@ -691,6 +733,15 @@
 	*type = ACPI_IRQ_MODEL_IOSAPIC;
 
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
diff -u -r -X /home/helgaas/exclude 20_iosapic_gsi/arch/ia64/kernel/iosapic.c 30_sci/arch/ia64/kernel/iosapic.c
--- 20_iosapic_gsi/arch/ia64/kernel/iosapic.c	Sun Jul 21 03:03:33 2002
+++ 30_sci/arch/ia64/kernel/iosapic.c	Sun Jul 21 03:03:38 2002
@@ -124,8 +124,8 @@
  * Translate IOSAPIC irq number to the corresponding IA-64 interrupt vector.  If no
  * entry exists, return -1.
  */
-static int
-iosapic_irq_to_vector (int irq)
+int
+iosapic_irq_to_vector (unsigned int irq)
 {
 	int vector;
 
diff -u -r -X /home/helgaas/exclude 20_iosapic_gsi/drivers/acpi/osl.c 30_sci/drivers/acpi/osl.c
--- 20_iosapic_gsi/drivers/acpi/osl.c	Sun Jul 21 03:03:33 2002
+++ 30_sci/drivers/acpi/osl.c	Mon Jul 22 04:22:26 2002
@@ -33,6 +33,7 @@
 #include <linux/interrupt.h>
 #include <linux/kmod.h>
 #include <linux/delay.h>
+#include <linux/acpi.h>
 #include <asm/io.h>
 #include "acpi.h"
 
@@ -41,11 +42,6 @@
 u64 efi_mem_attributes (u64 phys_addr);
 #endif
 
-#ifdef CONFIG_IA64
-#include <asm/hw_irq.h>
-#include <asm/delay.h>
-#endif
-
 
 #define _COMPONENT		ACPI_OS_SERVICES
 ACPI_MODULE_NAME	("osl")
@@ -235,8 +231,15 @@
 acpi_os_install_interrupt_handler(u32 irq, OSD_HANDLER handler, void *context)
 {
 #ifdef CONFIG_IA64
-	irq = isa_irq_to_vector(irq);
-#endif /* CONFIG_IA64 */
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
@@ -253,8 +256,8 @@
 {
 	if (acpi_irq_handler) {
 #ifdef CONFIG_IA64
-		irq = isa_irq_to_vector(irq);
-#endif /* CONFIG_IA64 */
+		irq = acpi_irq_to_vector(irq);
+#endif
 		free_irq(irq, acpi_irq);
 		acpi_irq_handler = NULL;
 	}
diff -u -r -X /home/helgaas/exclude 20_iosapic_gsi/include/asm-ia64/iosapic.h 30_sci/include/asm-ia64/iosapic.h
--- 20_iosapic_gsi/include/asm-ia64/iosapic.h	Fri Nov  9 15:26:17 2001
+++ 30_sci/include/asm-ia64/iosapic.h	Sun Jul 21 03:03:38 2002
@@ -53,6 +53,7 @@
 
 extern void __init iosapic_init (unsigned long address, unsigned int base_irq,
                                  int pcat_compat);
+extern int iosapic_irq_to_vector (unsigned int irq);
 extern int iosapic_register_irq (u32 global_vector, unsigned long polarity,
                                  unsigned long edge_triggered, u32 base_irq,
                                  char *iosapic_address);
diff -u -r -X /home/helgaas/exclude 20_iosapic_gsi/include/linux/acpi.h 30_sci/include/linux/acpi.h
--- 20_iosapic_gsi/include/linux/acpi.h	Mon Jul 22 03:12:16 2002
+++ 30_sci/include/linux/acpi.h	Sun Jul 21 03:40:16 2002
@@ -377,6 +377,7 @@
 #ifdef CONFIG_ACPI
 
 int acpi_init(void);
+int acpi_irq_to_vector(u32 irq);
 
 #endif /*CONFIG_ACPI*/
 

--------------Boundary-00=_DI8OG9N44J5EWH7I4DL4
Content-Type: text/x-diff;
  charset="us-ascii";
  name="40_pcibios_segment.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="40_pcibios_segment.diff"

diff -u -r 30_sci/arch/ia64/hp/zx1/hpzx1_misc.c 40_pcibios_segment/arch/ia64/hp/zx1/hpzx1_misc.c
--- 30_sci/arch/ia64/hp/zx1/hpzx1_misc.c	Sat Jul 20 16:31:07 2002
+++ 40_pcibios_segment/arch/ia64/hp/zx1/hpzx1_misc.c	Sat Jul 20 16:33:47 2002
@@ -30,13 +30,16 @@
 	int sizing;			// in middle of BAR sizing operation?
 };
 
+#define PCI_FAKE_DEV(dev)	((struct fake_pci_dev *) \
+					PCI_CONTROLLER(dev)->platform_data)
+
 static struct pci_ops *orig_pci_ops;
 
 #define HP_CFG_RD(sz, bits, name) \
 static int hp_cfg_read##sz (struct pci_dev *dev, int where, u##bits *value) \
 { \
 	struct fake_pci_dev *fake_dev; \
-	if (!(fake_dev = (struct fake_pci_dev *) dev->sysdata)) \
+	if (!(fake_dev = PCI_FAKE_DEV(dev))) \
 		return orig_pci_ops->name(dev, where, value); \
 	\
 	if (where == PCI_BASE_ADDRESS_0) { \
@@ -60,7 +63,7 @@
 { \
 	struct fake_pci_dev *fake_dev; \
 	\
-	if (!(fake_dev = (struct fake_pci_dev *) dev->sysdata)) \
+	if (!(fake_dev = PCI_FAKE_DEV(dev))) \
 		return orig_pci_ops->name(dev, where, value); \
 	\
 	if (where == PCI_BASE_ADDRESS_0) { \
@@ -91,16 +94,26 @@
 static void
 hpzx1_fake_pci_dev(char *name, unsigned int busnum, unsigned long addr, unsigned int size)
 {
+	struct pci_controller *controller;
 	struct fake_pci_dev *fake;
 	int slot;
 	struct pci_dev *dev;
 	struct pci_bus *b, *bus = NULL;
 	u8 hdr;
 
+	controller = kmalloc(sizeof(*controller), GFP_KERNEL);
+	if (!controller) {
+		printk(KERN_ERR PFX "No memory for %s (0x%p) sysdata\n", name,
+			(void *) addr);
+		return;
+	}
+	memset(controller, 0, sizeof(*controller));
+
         fake = kmalloc(sizeof(*fake), GFP_KERNEL);
 	if (!fake) {
 		printk(KERN_ERR PFX "No memory for %s (0x%p) sysdata\n", name,
 			(void *) addr);
+		kfree(controller);
 		return;
 	}
 
@@ -109,6 +122,7 @@
 	fake->csr_size = size;
 	fake->mapped_csrs = (unsigned long) ioremap(addr, size);
 	fake->sizing = 0;
+	controller->platform_data = fake;
 
 	pci_for_each_bus(b)
 		if (busnum == b->number) {
@@ -120,6 +134,7 @@
 		printk(KERN_ERR PFX "No host bus 0x%02x for %s (0x%p)\n",
 			busnum, name, (void *) addr);
 		kfree(fake);
+		kfree(controller);
 		return;
 	}
 
@@ -131,6 +146,7 @@
 		printk(KERN_ERR PFX "No space for %s (0x%p) on bus 0x%02x\n",
 			name, (void *) addr, busnum);
 		kfree(fake);
+		kfree(controller);
 		return;
 	}
 
@@ -139,6 +155,7 @@
 		printk(KERN_ERR PFX "No memory for %s (0x%p)\n", name,
 			(void *) addr);
 		kfree(fake);
+		kfree(controller);
 		return;
 	}
 
@@ -146,7 +163,7 @@
 
 	memset(dev, 0, sizeof(*dev));
 	dev->bus = bus;
-	dev->sysdata = fake;
+	dev->sysdata = controller;
 	dev->devfn = PCI_DEVFN(slot, 0);
 	pci_read_config_word(dev, PCI_VENDOR_ID, &dev->vendor);
 	pci_read_config_word(dev, PCI_DEVICE_ID, &dev->device);
diff -u -r 30_sci/arch/ia64/kernel/pci.c 40_pcibios_segment/arch/ia64/kernel/pci.c
--- 30_sci/arch/ia64/kernel/pci.c	Sat Jul 20 16:31:07 2002
+++ 40_pcibios_segment/arch/ia64/kernel/pci.c	Sat Jul 20 16:33:47 2002
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
+{
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
+
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
 struct pci_bus *
-pcibios_scan_root(int bus)
+pcibios_scan_root(void *handle, int seg, int bus)
 {
-	struct list_head *list = NULL;
-	struct pci_bus *pci_bus = NULL;
+	struct pci_controller *controller;
 
-	list_for_each(list, &pci_root_buses) {
-		pci_bus = pci_bus_b(list);
-		if (pci_bus->number == bus) {
-			/* Already scanned */
-			printk("PCI: Bus (%02x) already probed\n", bus);
-			return pci_bus;
-		}
-	}
+	printk("PCI: Probing PCI hardware on bus (%02x:%02x)\n", seg, bus);
 
-	printk("PCI: Probing PCI hardware on bus (%02x)\n", bus);
+	controller = alloc_pci_controller(seg);
+	if (!controller)
+		return NULL;
 
-	return pci_scan_bus(bus, pci_root_ops, NULL);
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
 
diff -u -r 30_sci/drivers/acpi/pci_root.c 40_pcibios_segment/drivers/acpi/pci_root.c
--- 30_sci/drivers/acpi/pci_root.c	Sat Jul 20 16:31:08 2002
+++ 40_pcibios_segment/drivers/acpi/pci_root.c	Sat Jul 20 16:33:47 2002
@@ -103,8 +103,6 @@
 	switch (status) {
 	case AE_OK:
 		root->id.segment = (u16) value;
-		printk("_SEG exists! Unsupported. Abort.\n");
-		BUG();
 		break;
 	case AE_NOT_FOUND:
 		ACPI_DEBUG_PRINT((ACPI_DB_INFO, 
@@ -162,7 +160,8 @@
 	 * PCI namespace does not get created until this call is made (and 
 	 * thus the root bridge's pci_dev does not exist).
 	 */
-	root->bus = pcibios_scan_root(root->id.bus);
+	root->bus = pcibios_scan_root(root->handle, root->id.segment,
+		root->id.bus);
 	if (!root->bus) {
 		ACPI_DEBUG_PRINT((ACPI_DB_ERROR, 
 			"Bus %02x:%02x not present in PCI namespace\n", 
diff -u -r 30_sci/include/asm-ia64/pci.h 40_pcibios_segment/include/asm-ia64/pci.h
--- 30_sci/include/asm-ia64/pci.h	Sat Jul 20 16:31:09 2002
+++ 40_pcibios_segment/include/asm-ia64/pci.h	Sat Jul 20 16:33:47 2002
@@ -20,7 +20,7 @@
 #define PCIBIOS_MIN_MEM		0x10000000
 
 void pcibios_config_init(void);
-struct pci_bus * pcibios_scan_root(int bus);
+struct pci_bus *pcibios_scan_root(void *acpi_handle, int segment, int bus);
 extern int (*pci_config_read)(int seg, int bus, int dev, int fn, int reg, int len, u32 *value);
 extern int (*pci_config_write)(int seg, int bus, int dev, int fn, int reg, int len, u32 value);
 
@@ -81,5 +81,15 @@
 #define HAVE_PCI_MMAP
 extern int pci_mmap_page_range (struct pci_dev *dev, struct vm_area_struct *vma,
 				enum pci_mmap_state mmap_state, int write_combine);
+
+struct pci_controller {
+	void *acpi_handle;
+	int segment;
+
+	void *platform_data;
+};
+
+#define PCI_CONTROLLER(dev) ((struct pci_controller *) dev->sysdata)
+#define PCI_SEGMENT(dev)    (PCI_CONTROLLER(dev)->segment)
 
 #endif /* _ASM_IA64_PCI_H */

--------------Boundary-00=_DI8OG9N44J5EWH7I4DL4
Content-Type: text/x-diff;
  charset="us-ascii";
  name="50_iosapic_segment.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="50_iosapic_segment.diff"

diff -u -r -X /home/helgaas/exclude 40_pcibios_segment/arch/ia64/kernel/acpi.c 80_multi_ioc/arch/ia64/kernel/acpi.c
--- 40_pcibios_segment/arch/ia64/kernel/acpi.c	Mon Jul 22 05:14:47 2002
+++ 80_multi_ioc/arch/ia64/kernel/acpi.c	Mon Jul 22 05:13:45 2002
@@ -712,6 +712,7 @@
 
 	list_for_each(node, &acpi_prt.entries) {
 		entry = (struct acpi_prt_entry *)node;
+		vector[i].segment = entry->id.segment;
 		vector[i].bus    = entry->id.bus;
 		vector[i].pci_id = ((u32) entry->id.device << 16) | 0xffff;
 		vector[i].pin    = entry->pin;
diff -u -r -X /home/helgaas/exclude 40_pcibios_segment/arch/ia64/kernel/iosapic.c 80_multi_ioc/arch/ia64/kernel/iosapic.c
--- 40_pcibios_segment/arch/ia64/kernel/iosapic.c	Mon Jul 22 05:14:47 2002
+++ 80_multi_ioc/arch/ia64/kernel/iosapic.c	Mon Jul 22 05:13:45 2002
@@ -25,12 +25,13 @@
  * 02/04/02	P. Diefenbaugh	Cleaned up ACPI PCI IRQ routing.
  * 02/04/18	J.I. Lee	bug fix in iosapic_init_pci_irq
  * 02/04/30	J.I. Lee	bug fix in find_iosapic to fix ACPI PCI IRQ to IOSAPIC mapping error
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
@@ -140,12 +141,13 @@
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
@@ -689,6 +691,7 @@
 iosapic_pci_fixup (int phase)
 {
 	struct	pci_dev	*dev;
+	int segment;
 	unsigned char pin;
 	int vector;
 	struct hw_interrupt_type *irq_type;
@@ -706,7 +709,8 @@
 		pci_read_config_byte(dev, PCI_INTERRUPT_PIN, &pin);
 		if (pin) {
 			pin--;          /* interrupt pins are numbered starting from 1 */
-			vector = pci_pin_to_vector(dev->bus->number, PCI_SLOT(dev->devfn), pin);
+			segment = PCI_SEGMENT(dev);
+			vector = pci_pin_to_vector(segment, dev->bus->number, PCI_SLOT(dev->devfn), pin);
 			if (vector < 0 && dev->bus->parent) {
 				/* go back to the bridge */
 				struct pci_dev *bridge = dev->bus->self;
@@ -716,7 +720,7 @@
 					do {
 						/* do the bridge swizzle... */
 						pin = (pin + PCI_SLOT(dev->devfn)) % 4;
-						vector = pci_pin_to_vector(bridge->bus->number,
+						vector = pci_pin_to_vector(segment, bridge->bus->number,
 									   PCI_SLOT(bridge->devfn),
 									   pin);
 					} while (vector < 0 && (bridge = bridge->bus->self));
diff -u -r -X /home/helgaas/exclude 40_pcibios_segment/include/asm-ia64/system.h 80_multi_ioc/include/asm-ia64/system.h
--- 40_pcibios_segment/include/asm-ia64/system.h	Mon Jul 22 03:12:15 2002
+++ 80_multi_ioc/include/asm-ia64/system.h	Mon Jul 22 05:13:45 2002
@@ -29,6 +29,7 @@
 #include <linux/types.h>
 
 struct pci_vector_struct {
+	__u16 segment;	/* PCI Segment number */
 	__u16 bus;	/* PCI Bus number */
 	__u32 pci_id;	/* ACPI split 16 bits device, 16 bits function (see section 6.1.1) */
 	__u8 pin;	/* PCI PIN (0 = A, 1 = B, 2 = C, 3 = D) */

--------------Boundary-00=_DI8OG9N44J5EWH7I4DL4
Content-Type: text/x-diff;
  charset="us-ascii";
  name="60_pci_tra.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="60_pci_tra.diff"

diff -u -r 50_iosapic_segment/arch/ia64/kernel/acpi.c 60_pci_tra/arch/ia64/kernel/acpi.c
--- 50_iosapic_segment/arch/ia64/kernel/acpi.c	Sat Jul 20 16:34:49 2002
+++ 60_pci_tra/arch/ia64/kernel/acpi.c	Sat Jul 20 16:35:33 2002
@@ -169,6 +169,73 @@
 	kfree(buf->pointer);
 }
 
+static void
+acpi_get_crs_addr (acpi_buffer *buf, int type, u64 *base, u64 *length, u64 *tra)
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
+					*length = addr16->address_length;
+					*tra = addr16->address_translation_offset;
+					return;
+				}
+				break;
+			case ACPI_RSTYPE_ADDRESS32:
+				addr32 = (acpi_resource_address32 *) &res->data;
+				if (type == addr32->resource_type) {
+					*base = addr32->min_address_range;
+					*length = addr32->address_length;
+					*tra = addr32->address_translation_offset;
+					return;
+				}
+				break;
+			case ACPI_RSTYPE_ADDRESS64:
+				addr64 = (acpi_resource_address64 *) &res->data;
+				if (type == addr64->resource_type) {
+					*base = addr64->min_address_range;
+					*length = addr64->address_length;
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
--- 50_iosapic_segment/arch/ia64/kernel/pci.c	Sat Jul 20 16:33:47 2002
+++ 60_pci_tra/arch/ia64/kernel/pci.c	Sat Jul 20 16:35:33 2002
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
 
@@ -266,6 +272,27 @@
 	return;
 }
 
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
@@ -273,7 +300,10 @@
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
diff -u -r 50_iosapic_segment/arch/ia64/kernel/setup.c 60_pci_tra/arch/ia64/kernel/setup.c
--- 50_iosapic_segment/arch/ia64/kernel/setup.c	Sat Jul 20 16:31:07 2002
+++ 60_pci_tra/arch/ia64/kernel/setup.c	Sat Jul 20 16:35:33 2002
@@ -29,6 +29,7 @@
 #include <linux/string.h>
 #include <linux/threads.h>
 #include <linux/console.h>
+#include <linux/ioport.h>
 
 #include <asm/ia32.h>
 #include <asm/page.h>
@@ -295,6 +296,7 @@
 
 	efi_init();
 
+	iomem_resource.end = ~0UL;	/* FIXME probably belongs elsewhere */
 	find_memory();
 
 #if 0
diff -u -r 50_iosapic_segment/include/asm-ia64/pci.h 60_pci_tra/include/asm-ia64/pci.h
--- 50_iosapic_segment/include/asm-ia64/pci.h	Sat Jul 20 16:33:47 2002
+++ 60_pci_tra/include/asm-ia64/pci.h	Sat Jul 20 16:35:33 2002
@@ -86,6 +86,8 @@
 	void *acpi_handle;
 	int segment;
 
+	u64 mem_offset;
+
 	void *platform_data;
 };
 
diff -u -r 50_iosapic_segment/include/linux/acpi.h 60_pci_tra/include/linux/acpi.h
--- 50_iosapic_segment/include/linux/acpi.h	Sat Jul 20 16:33:00 2002
+++ 60_pci_tra/include/linux/acpi.h	Sat Jul 20 16:35:33 2002
@@ -378,6 +378,8 @@
 
 int acpi_init(void);
 int acpi_irq_to_vector(u32 irq);
+acpi_status acpi_get_addr_space(acpi_handle, u8 type, u64 *base, u64 *length, u64 *tra);
+
 
 #endif /*CONFIG_ACPI*/
 

--------------Boundary-00=_DI8OG9N44J5EWH7I4DL4
Content-Type: text/x-diff;
  charset="us-ascii";
  name="70_enable_device.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="70_enable_device.diff"

diff -u -r 60_pci_tra/arch/ia64/kernel/pci.c 70_enable_device/arch/ia64/kernel/pci.c
--- 60_pci_tra/arch/ia64/kernel/pci.c	Sat Jul 20 16:35:33 2002
+++ 70_enable_device/arch/ia64/kernel/pci.c	Sat Jul 20 16:38:17 2002
@@ -349,6 +349,8 @@
 	if (!dev)
 		return -EINVAL;
 
+ 	platform_pci_enable_device(dev);
+
 	pci_read_config_word(dev, PCI_COMMAND, &cmd);
 	old_cmd = cmd;
 	for (idx=0; idx<6; idx++) {
diff -u -r 60_pci_tra/include/asm-ia64/machvec.h 70_enable_device/include/asm-ia64/machvec.h
--- 60_pci_tra/include/asm-ia64/machvec.h	Sat Jul 20 16:31:09 2002
+++ 70_enable_device/include/asm-ia64/machvec.h	Sat Jul 20 16:36:38 2002
@@ -24,6 +24,7 @@
 typedef void ia64_mv_cpu_init_t(void);
 typedef void ia64_mv_irq_init_t (void);
 typedef void ia64_mv_pci_fixup_t (int);
+typedef void ia64_mv_pci_enable_device_t (struct pci_dev *);
 typedef unsigned long ia64_mv_map_nr_t (unsigned long);
 typedef void ia64_mv_mca_init_t (void);
 typedef void ia64_mv_mca_handler_t (void);
@@ -91,7 +92,8 @@
 #  define platform_cmci_handler	ia64_mv.cmci_handler
 #  define platform_log_print	ia64_mv.log_print
 #  define platform_pci_fixup	ia64_mv.pci_fixup
-#  define platform_send_ipi	ia64_mv.send_ipi
+#  define platform_pci_enable_device	ia64_mv.pci_enable_device
+#  define platform_send_ipi		ia64_mv.send_ipi
 #  define platform_global_tlb_purge	ia64_mv.global_tlb_purge
 #  define platform_pci_dma_init		ia64_mv.dma_init
 #  define platform_pci_alloc_consistent	ia64_mv.alloc_consistent
@@ -121,6 +123,7 @@
 	ia64_mv_cpu_init_t *cpu_init;
 	ia64_mv_irq_init_t *irq_init;
 	ia64_mv_pci_fixup_t *pci_fixup;
+	ia64_mv_pci_enable_device_t *pci_enable_device;
 	ia64_mv_map_nr_t *map_nr;
 	ia64_mv_mca_init_t *mca_init;
 	ia64_mv_mca_handler_t *mca_handler;
@@ -157,6 +160,7 @@
 	platform_cpu_init,			\
 	platform_irq_init,			\
 	platform_pci_fixup,			\
+	platform_pci_enable_device,		\
 	platform_map_nr,			\
 	platform_mca_init,			\
 	platform_mca_handler,			\
@@ -235,6 +239,9 @@
 #endif
 #ifndef platform_pci_fixup
 # define platform_pci_fixup	((ia64_mv_pci_fixup_t *) machvec_noop)
+#endif
+#ifndef platform_pci_enable_device
+# define platform_pci_enable_device	((ia64_mv_pci_enable_device_t *) machvec_noop)
 #endif
 #ifndef platform_send_ipi
 # define platform_send_ipi	ia64_send_ipi	/* default to architected version */

--------------Boundary-00=_DI8OG9N44J5EWH7I4DL4
Content-Type: text/x-diff;
  charset="us-ascii";
  name="80_multi_ioc.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="80_multi_ioc.diff"

diff -u -r 70_enable_device/arch/ia64/hp/common/sba_iommu.c 80_multi_ioc/arch/ia64/hp/common/sba_iommu.c
--- 70_enable_device/arch/ia64/hp/common/sba_iommu.c	Sat Jul 20 16:31:07 2002
+++ 80_multi_ioc/arch/ia64/hp/common/sba_iommu.c	Sat Jul 20 16:49:15 2002
@@ -29,6 +29,7 @@
 #include <linux/string.h>
 #include <linux/pci.h>
 #include <linux/proc_fs.h>
+#include <linux/acpi.h>
 
 #include <asm/delay.h>		/* ia64_get_itc() */
 #include <asm/io.h>
@@ -36,11 +37,9 @@
 #include <asm/efi.h>
 
 
-#define DRIVER_NAME "SBA"
+#define PFX "IOC: "
 
-#ifndef CONFIG_IA64_HP_PROTO
 #define ALLOW_IOV_BYPASS
-#endif
 #define ENABLE_MARK_CLEAN
 /*
 ** The number of debug flags is a clue - this code is fragile.
@@ -97,10 +96,6 @@
 #define ASSERT(expr)
 #endif
 
-#define KB(x) ((x) * 1024)
-#define MB(x) (KB (KB (x)))
-#define GB(x) (MB (KB (x)))
-
 /*
 ** The number of pdir entries to "free" before issueing
 ** a read to PCOM register to flush out PCOM writes.
@@ -112,28 +107,21 @@
 
 #define DEFAULT_DMA_HINT_REG	0
 
-#define ZX1_FUNC_ID_VALUE    ((PCI_DEVICE_ID_HP_ZX1_SBA << 16) | PCI_VENDOR_ID_HP)
-#define ZX1_MC_ID    ((PCI_DEVICE_ID_HP_ZX1_MC << 16) | PCI_VENDOR_ID_HP)
-
-#define SBA_FUNC_ID	0x0000	/* function id */
-#define SBA_FCLASS	0x0008	/* function class, bist, header, rev... */
-
-#define SBA_FUNC_SIZE	0x10000   /* SBA configuration function reg set */
-
-unsigned int __initdata zx1_func_offsets[] = {0x1000, 0x8000,
-                                              0x9000, 0xa000, -1};
-
-#define SBA_IOC_OFFSET	0x1000
+#define ZX1_IOC_ID	((PCI_DEVICE_ID_HP_ZX1_IOC << 16) | PCI_VENDOR_ID_HP)
+#define REO_IOC_ID	((PCI_DEVICE_ID_HP_REO_IOC << 16) | PCI_VENDOR_ID_HP)
 
-#define MAX_IOC		1	/* we only have 1 for now*/
+#define ZX1_IOC_OFFSET	0x1000	/* ACPI reports SBA, we want IOC */
 
+#define IOC_FUNC_ID	0x000
+#define IOC_FCLASS	0x008	/* function class, bist, header, rev... */
 #define IOC_IBASE	0x300	/* IO TLB */
 #define IOC_IMASK	0x308
 #define IOC_PCOM	0x310
 #define IOC_TCNFG	0x318
 #define IOC_PDIR_BASE	0x320
 
-#define IOC_IOVA_SPACE_BASE	0x40000000 /* IOVA ranges start at 1GB */
+/* AGP GART driver looks for this */
+#define ZX1_SBA_IOMMU_COOKIE	0x0000badbadc0ffeeUL
 
 /*
 ** IOC supports 4/8/16/64KB page sizes (see TCNFG register)
@@ -153,7 +141,7 @@
 #define IOVP_MASK	PAGE_MASK
 
 struct ioc {
-	unsigned long	ioc_hpa;	/* I/O MMU base address */
+	void		*ioc_hpa;	/* I/O MMU base address */
 	char		*res_map;	/* resource map, bit == pdir entry */
 	u64		*pdir_base;	/* physical base address */
 	unsigned long	ibase;		/* pdir IOV Space base */
@@ -194,36 +182,25 @@
 #endif
 #endif
 
-	/* STUFF We don't need in performance path */
+	/* Stuff we don't need in performance path */
+	struct ioc	*next;		/* list of IOC's in system */
+	acpi_handle	handle;		/* for multiple IOC's */
+	const char 	*name;
+	unsigned int	func_id;
+	unsigned int	rev;		/* HW revision of chip */
+	u32		iov_size;
 	unsigned int	pdir_size;	/* in bytes, determined by IOV Space size */
+	struct pci_dev	*sac_only_dev;
 };
 
-struct sba_device {
-	struct sba_device	*next;	/* list of SBA's in system */
-	const char 		*name;
-	unsigned long		sba_hpa; /* base address */
-	spinlock_t		sba_lock;
-	unsigned int		flags;  /* state/functionality enabled */
-	unsigned int		hw_rev;  /* HW revision of chip */
-
-	unsigned int		num_ioc;  /* number of on-board IOC's */
-	struct ioc		ioc[MAX_IOC];
-};
-
-
-static struct sba_device *sba_list;
-static int sba_count;
+static struct ioc *ioc_list;
 static int reserve_sba_gart = 1;
-static struct pci_dev sac_only_dev;
 
 #define sba_sg_iova(sg) (sg->address)
 #define sba_sg_len(sg) (sg->length)
 #define sba_sg_buffer(sg) (sg->orig_address)
 
-/* REVISIT - fix me for multiple SBAs/IOCs */
-#define GET_IOC(dev) (sba_list->ioc)
-#define SBA_SET_AGP(sba_dev) (sba_dev->flags |= 0x1)
-#define SBA_GET_AGP(sba_dev) (sba_dev->flags & 0x1)
+#define GET_IOC(dev)	((struct ioc *) PCI_CONTROLLER(dev)->iommu)
 
 /*
 ** DMA_CHUNK_SIZE is used by the SCSI mid-layer to break up
@@ -234,9 +211,6 @@
 */
 #define DMA_CHUNK_SIZE  (BITS_PER_LONG*PAGE_SIZE)
 
-/* Looks nice and keeps the compiler happy */
-#define SBA_DEV(d) ((struct sba_device *) (d))
-
 #define ROUNDUP(x,y) ((x + ((y)-1)) & ~((y)-1))
 
 /************************************
@@ -629,7 +603,7 @@
  */
 
 #if 1
-#define sba_io_pdir_entry(pdir_ptr, vba) *pdir_ptr = ((vba & ~0xE000000000000FFFULL) | 0x80000000000000FFULL)
+#define sba_io_pdir_entry(pdir_ptr, vba) *pdir_ptr = ((vba & ~0xE000000000000FFFULL) | 0x8000000000000000ULL)
 #else
 void SBA_INLINE
 sba_io_pdir_entry(u64 *pdir_ptr, unsigned long vba)
@@ -939,6 +913,7 @@
 void *
 sba_alloc_consistent(struct pci_dev *hwdev, size_t size, dma_addr_t *dma_handle)
 {
+	struct ioc *ioc;
 	void *ret;
 
 	if (!hwdev) {
@@ -956,7 +931,8 @@
 		 * than dma_mask from the device, this needs to be
 		 * updated.
 		 */
-		*dma_handle = sba_map_single(&sac_only_dev, ret, size, 0);
+		ioc = GET_IOC(hwdev);
+		*dma_handle = sba_map_single(ioc->sac_only_dev, ret, size, 0);
 	}
 
 	return ret;
@@ -1401,74 +1377,70 @@
 *
 ***************************************************************/
 
-
-static void
-sba_ioc_init(struct sba_device *sba_dev, struct ioc *ioc, int ioc_num)
+static void __init
+ioc_iova_init(struct ioc *ioc)
 {
-	u32 iova_space_size, iova_space_mask;
-	void * pdir_base;
-	int pdir_size, iov_order, tcnfg;
+	u32 iova_space_mask;
+	int iov_order, tcnfg;
+	int agp_found = 0;
+	struct pci_dev *device;
 
 	/*
-	** Firmware programs the maximum IOV space size into the imask reg
+	** Firmware programs the base and size of a "safe IOVA space"
+	** (one that doesn't overlap memory or LMMIO space) in the
+	** IBASE and IMASK registers.
 	*/
-	iova_space_size = ~(READ_REG(ioc->ioc_hpa + IOC_IMASK) & 0xFFFFFFFFUL) + 1;
-#ifdef CONFIG_IA64_HP_PROTO
-	if (!iova_space_size)
-		iova_space_size = GB(1);
-#endif
+	ioc->ibase = READ_REG(ioc->ioc_hpa + IOC_IBASE) & ~0x1UL;
+	ioc->iov_size = ~(READ_REG(ioc->ioc_hpa + IOC_IMASK) & 0xFFFFFFFFUL) + 1;
+
+	if (ioc->ibase == 0) {
+		if (((unsigned long) ioc->ioc_hpa & 0x3000UL) == 0x2000)
+			ioc->ibase = 0xc0000000;
+		else
+			ioc->ibase = 0x80000000;
+		printk("WARNING: IBASE is zero; setting to 0x%lx\n", ioc->ibase);
+	}
+
+	if (ioc->ibase < 0xfed00000UL && ioc->ibase + ioc->iov_size >= 0xfee00000UL) {
+		printk("WARNING: IOV space overlaps local config and interrupt message, truncating\n");
+		ioc->iov_size /= 2;
+	}
 
 	/*
 	** iov_order is always based on a 1GB IOVA space since we want to
 	** turn on the other half for AGP GART.
 	*/
-	iov_order = get_order(iova_space_size >> (IOVP_SHIFT-PAGE_SHIFT));
-	ioc->pdir_size = pdir_size = (iova_space_size/IOVP_SIZE) * sizeof(u64);
+	iov_order = get_order(ioc->iov_size >> (IOVP_SHIFT - PAGE_SHIFT));
+	ioc->pdir_size = (ioc->iov_size / IOVP_SIZE) * sizeof(u64);
 
 	DBG_INIT("%s() hpa 0x%lx IOV %dMB (%d bits) PDIR size 0x%0x\n",
-		__FUNCTION__, ioc->ioc_hpa, iova_space_size>>20,
+		__FUNCTION__, ioc->ioc_hpa, ioc->iov_size >> 20,
 		iov_order + PAGE_SHIFT, ioc->pdir_size);
 
 	/* FIXME : DMA HINTs not used */
 	ioc->hint_shift_pdir = iov_order + PAGE_SHIFT;
 	ioc->hint_mask_pdir = ~(0x3 << (iov_order + PAGE_SHIFT));
 
-	ioc->pdir_base =
-	pdir_base = (void *) __get_free_pages(GFP_KERNEL, get_order(pdir_size));
-	if (NULL == pdir_base)
-	{
-		panic(__FILE__ ":%s() could not allocate I/O Page Table\n", __FUNCTION__);
-	}
-	memset(pdir_base, 0, pdir_size);
+	ioc->pdir_base = (void *) __get_free_pages(GFP_KERNEL,
+						   get_order(ioc->pdir_size));
+	if (!ioc->pdir_base)
+		panic(PFX "Couldn't allocate I/O Page Table\n");
+
+	memset(ioc->pdir_base, 0, ioc->pdir_size);
 
 	DBG_INIT("%s() pdir %p size %x hint_shift_pdir %x hint_mask_pdir %lx\n",
-		__FUNCTION__, pdir_base, pdir_size,
+		__FUNCTION__, ioc->pdir_base, ioc->pdir_size,
 		ioc->hint_shift_pdir, ioc->hint_mask_pdir);
 
-	ASSERT((((unsigned long) pdir_base) & PAGE_MASK) == (unsigned long) pdir_base);
-	WRITE_REG(virt_to_phys(pdir_base), ioc->ioc_hpa + IOC_PDIR_BASE);
+	ASSERT((((unsigned long) ioc->pdir_base) & PAGE_MASK) == (unsigned long) ioc->pdir_base);
+	WRITE_REG(virt_to_phys(ioc->pdir_base), ioc->ioc_hpa + IOC_PDIR_BASE);
 
-	DBG_INIT(" base %p\n", pdir_base);
+	DBG_INIT(" base %p\n", ioc->pdir_base);
 
 	/* build IMASK for IOC and Elroy */
 	iova_space_mask =  0xffffffff;
 	iova_space_mask <<= (iov_order + PAGE_SHIFT);
-
-#ifdef CONFIG_IA64_HP_PROTO
-	/*
-	** REVISIT - this is a kludge, but we won't be supporting anything but
-	** zx1 2.0 or greater for real.  When fw is in shape, ibase will
-	** be preprogrammed w/ the IOVA hole base and imask will give us
-	** the size.
-	*/
-	if ((sba_dev->hw_rev & 0xFF) < 0x20) {
-		DBG_INIT("%s() Found SBA rev < 2.0, setting IOVA base to 0.  This device will not be supported in the future.\n", __FUNCTION__);
-		ioc->ibase = 0x0;
-	} else
-#endif
-	ioc->ibase = READ_REG(ioc->ioc_hpa + IOC_IBASE) & 0xFFFFFFFEUL;
-
-	ioc->imask = iova_space_mask;	/* save it */
+	ioc->imask = iova_space_mask;
 
 	DBG_INIT("%s() IOV base 0x%lx mask 0x%0lx\n",
 		__FUNCTION__, ioc->ibase, ioc->imask);
@@ -1478,8 +1450,7 @@
 	** values during boot, so hints should be sane even if we
 	** can't reprogram them the way drivers want.
 	*/
-
-	WRITE_REG(ioc->imask, ioc->ioc_hpa+IOC_IMASK);
+	WRITE_REG(ioc->imask, ioc->ioc_hpa + IOC_IMASK);
 
 	/*
 	** Setting the upper bits makes checking for bypass addresses
@@ -1489,32 +1460,28 @@
 
 	/* Set I/O PDIR Page size to system page size */
 	switch (PAGE_SHIFT) {
-		case 12: /* 4K */
-			tcnfg = 0;
-			break;
-		case 13: /* 8K */
-			tcnfg = 1;
-			break;
-		case 14: /* 16K */
-			tcnfg = 2;
-			break;
-		case 16: /* 64K */
-			tcnfg = 3;
+		case 12: tcnfg = 0; break;	/*  4K */
+		case 13: tcnfg = 1; break;	/*  8K */
+		case 14: tcnfg = 2; break;	/* 16K */
+		case 16: tcnfg = 3; break;	/* 64K */
+		default:
+			panic(PFX "Unsupported system page size %d",
+				1 << PAGE_SHIFT);
 			break;
 	}
-	WRITE_REG(tcnfg, ioc->ioc_hpa+IOC_TCNFG);
+	WRITE_REG(tcnfg, ioc->ioc_hpa + IOC_TCNFG);
 
 	/*
 	** Program the IOC's ibase and enable IOVA translation
 	** Bit zero == enable bit.
 	*/
-	WRITE_REG(ioc->ibase | 1, ioc->ioc_hpa+IOC_IBASE);
+	WRITE_REG(ioc->ibase | 1, ioc->ioc_hpa + IOC_IBASE);
 
 	/*
 	** Clear I/O TLB of any possible entries.
 	** (Yes. This is a bit paranoid...but so what)
 	*/
-	WRITE_REG(0 | 31, ioc->ioc_hpa+IOC_PCOM);
+	WRITE_REG(0 | 31, ioc->ioc_hpa + IOC_PCOM);
 
 	/*
 	** If an AGP device is present, only use half of the IOV space
@@ -1524,149 +1491,158 @@
 	** We program the next pdir index after we stop w/ a key for
 	** the GART code to handshake on.
 	*/
-	if (SBA_GET_AGP(sba_dev)) {
-		DBG_INIT("%s() AGP Device found, reserving 512MB for GART support\n", __FUNCTION__);
+	pci_for_each_dev(device)
+		agp_found |= pci_find_capability(device, PCI_CAP_ID_AGP);
+
+	if (agp_found && reserve_sba_gart) {
+		DBG_INIT("%s: AGP device found, reserving half of IOVA for GART support\n", __FUNCTION__);
 		ioc->pdir_size /= 2;
-		((u64 *)pdir_base)[PDIR_INDEX(iova_space_size/2)] = 0x0000badbadc0ffeeULL;
+		((u64 *)ioc->pdir_base)[PDIR_INDEX(ioc->iov_size/2)] = ZX1_SBA_IOMMU_COOKIE;
 	}
-
-	DBG_INIT("%s() DONE\n", __FUNCTION__);
 }
 
+static void __init
+ioc_resource_init(struct ioc *ioc)
+{
+	spin_lock_init(&ioc->res_lock);
 
+	/* resource map size dictated by pdir_size */
+	ioc->res_size = ioc->pdir_size / sizeof(u64); /* entries */
+	ioc->res_size >>= 3;  /* convert bit count to byte count */
+	DBG_INIT("%s() res_size 0x%x\n", __FUNCTION__, ioc->res_size);
 
-/**************************************************************************
-**
-**   SBA initialization code (HW and SW)
-**
-**   o identify SBA chip itself
-**   o FIXME: initialize DMA hints for reasonable defaults
-**
-**************************************************************************/
+	ioc->res_map = (char *) __get_free_pages(GFP_KERNEL,
+						 get_order(ioc->res_size));
+	if (!ioc->res_map)
+		panic(PFX "Couldn't allocate resource map\n");
 
-static void
-sba_hw_init(struct sba_device *sba_dev)
-{ 
-	int i;
-	int num_ioc;
-	u64 dma_mask;
-	u32 func_id;
+	memset(ioc->res_map, 0, ioc->res_size);
+	/* next available IOVP - circular search */
+	ioc->res_hint = (unsigned long *) ioc->res_map;
 
-	/*
-	** Identify the SBA so we can set the dma_mask.  We can make a virtual
-	** dma_mask of the memory subsystem such that devices not implmenting
-	** a full 64bit mask might still be able to bypass efficiently.
-	*/
-	func_id = READ_REG(sba_dev->sba_hpa + SBA_FUNC_ID);
+#ifdef ASSERT_PDIR_SANITY
+	/* Mark first bit busy - ie no IOVA 0 */
+	ioc->res_map[0] = 0x1;
+	ioc->pdir_base[0] = 0x8000000000000000ULL | ZX1_SBA_IOMMU_COOKIE;
+#endif
 
-	if (func_id == ZX1_FUNC_ID_VALUE) {
-		dma_mask = 0xFFFFFFFFFFUL;
-	} else {
-		dma_mask = 0xFFFFFFFFFFFFFFFFUL;
-	}
+	DBG_INIT("%s() res_map %x %p\n", __FUNCTION__,
+		 ioc->res_size, (void *) ioc->res_map);
+}
+
+static void __init
+ioc_sac_init(struct ioc *ioc)
+{
+	struct pci_dev *sac = NULL;
+	struct pci_controller *controller = NULL;
 
-	DBG_INIT("%s(): ioc->dma_mask == 0x%lx\n", __FUNCTION__, dma_mask);
-	
 	/*
-	** Leaving in the multiple ioc code from parisc for the future,
-	** currently there are no muli-ioc mckinley sbas
-	*/
-	sba_dev->ioc[0].ioc_hpa = SBA_IOC_OFFSET;
-	num_ioc = 1;
+	 * pci_alloc_consistent() must return a DMA address which is
+	 * SAC (single address cycle) addressable, so allocate a
+	 * pseudo-device to enforce that.
+	 */
+	sac = kmalloc(sizeof(*sac), GFP_KERNEL);
+	if (!sac)
+		panic(PFX "Couldn't allocate struct pci_dev");
+	memset(sac, 0, sizeof(*sac));
 
-	sba_dev->num_ioc = num_ioc;
-	for (i = 0; i < num_ioc; i++) {
-		sba_dev->ioc[i].dma_mask = dma_mask;
-		sba_dev->ioc[i].ioc_hpa += sba_dev->sba_hpa;
-		sba_ioc_init(sba_dev, &(sba_dev->ioc[i]), i);
-	}
+	controller = kmalloc(sizeof(*controller), GFP_KERNEL);
+	if (!controller)
+		panic(PFX "Couldn't allocate struct pci_controller");
+	memset(controller, 0, sizeof(*controller));
+
+	controller->iommu = ioc;
+	sac->sysdata = controller;
+	sac->dma_mask = 0xFFFFFFFFUL;
+	ioc->sac_only_dev = sac;
 }
 
-static void
-sba_common_init(struct sba_device *sba_dev)
+static void __init
+ioc_zx1_init(struct ioc *ioc)
 {
-	int i;
+	if (ioc->rev < 0x20)
+		panic(PFX "IOC 2.0 or later required for IOMMU support\n");
 
-	/* add this one to the head of the list (order doesn't matter)
-	** This will be useful for debugging - especially if we get coredumps
-	*/
-	sba_dev->next = sba_list;
-	sba_list = sba_dev;
-	sba_count++;
-
-	for(i=0; i< sba_dev->num_ioc; i++) {
-		int res_size;
-
-		/* resource map size dictated by pdir_size */
-		res_size = sba_dev->ioc[i].pdir_size/sizeof(u64); /* entries */
-		res_size >>= 3;  /* convert bit count to byte count */
-		DBG_INIT("%s() res_size 0x%x\n",
-			__FUNCTION__, res_size);
-
-		sba_dev->ioc[i].res_size = res_size;
-		sba_dev->ioc[i].res_map = (char *) __get_free_pages(GFP_KERNEL, get_order(res_size));
-
-		if (NULL == sba_dev->ioc[i].res_map)
-		{
-			panic(__FILE__ ":%s() could not allocate resource map\n", __FUNCTION__ );
-		}
+	ioc->dma_mask = 0xFFFFFFFFFFUL;
+}
 
-		memset(sba_dev->ioc[i].res_map, 0, res_size);
-		/* next available IOVP - circular search */
-		if ((sba_dev->hw_rev & 0xFF) >= 0x20) {
-			sba_dev->ioc[i].res_hint = (unsigned long *)
-			    sba_dev->ioc[i].res_map;
-		} else {
-			u64 reserved_iov;
-			
-			/* Yet another 1.x hack */
-			printk("zx1 1.x: Starting resource hint offset into IOV space to avoid initial zero value IOVA\n");
-			sba_dev->ioc[i].res_hint = (unsigned long *)
-			    &(sba_dev->ioc[i].res_map[L1_CACHE_BYTES]);
-
-			sba_dev->ioc[i].res_map[0] = 0x1;
-			sba_dev->ioc[i].pdir_base[0] = 0x8000badbadc0ffeeULL;
-
-			for (reserved_iov = 0xA0000 ; reserved_iov < 0xC0000 ; reserved_iov += IOVP_SIZE) {
-				u64 *res_ptr = (u64 *) sba_dev->ioc[i].res_map;
-				int index = PDIR_INDEX(reserved_iov);
-				int res_word;
-				u64 mask;
-
-				res_word = (int)(index / BITS_PER_LONG);
-				mask =  0x1UL << (index - (res_word * BITS_PER_LONG));
-				res_ptr[res_word] |= mask;
-				sba_dev->ioc[i].pdir_base[PDIR_INDEX(reserved_iov)] = (0x80000000000000FFULL | reserved_iov);
+typedef void (initfunc)(struct ioc *);
 
-			}
-		}
+struct ioc_iommu {
+	u32 func_id;
+	char *name;
+	initfunc *init;
+};
 
-#ifdef ASSERT_PDIR_SANITY
-		/* Mark first bit busy - ie no IOVA 0 */
-		sba_dev->ioc[i].res_map[0] = 0x1;
-		sba_dev->ioc[i].pdir_base[0] = 0x8000badbadc0ffeeULL;
-#endif
+static struct ioc_iommu ioc_iommu_info[] __initdata = {
+	{ ZX1_IOC_ID, "zx1", ioc_zx1_init },
+	{ REO_IOC_ID, "REO" },
+};
+
+static struct ioc * __init
+ioc_init(u64 hpa, void *handle)
+{
+	struct ioc *ioc;
+	struct ioc_iommu *info;
+
+	ioc = kmalloc(sizeof(*ioc), GFP_KERNEL);
+	if (!ioc)
+		return NULL;
+
+	memset(ioc, 0, sizeof(*ioc));
+
+	ioc->next = ioc_list;
+	ioc_list = ioc;
+
+	ioc->handle = handle;
+	ioc->ioc_hpa = ioremap(hpa, 0x1000);
 
-		DBG_INIT("%s() %d res_map %x %p\n", __FUNCTION__,
-		         i, res_size, (void *)sba_dev->ioc[i].res_map);
+	ioc->func_id = READ_REG(ioc->ioc_hpa + IOC_FUNC_ID);
+	ioc->rev = READ_REG(ioc->ioc_hpa + IOC_FCLASS) & 0xFFUL;
+	ioc->dma_mask = 0xFFFFFFFFFFFFFFFFUL;	/* conservative */
+
+	for (info = ioc_iommu_info; info < ioc_iommu_info + ARRAY_SIZE(ioc_iommu_info); info++) {
+		if (ioc->func_id == info->func_id) {
+			ioc->name = info->name;
+			if (info->init)
+				(info->init)(ioc);
+		}
 	}
+	if (!ioc->name)
+		ioc->name = "Unknown";
+
+	ioc_iova_init(ioc);
+	ioc_resource_init(ioc);
+	ioc_sac_init(ioc);
+
+	printk(KERN_INFO PFX
+		"Found %s IOC %d.%d HPA 0x%lx IOVA space %dMb at 0x%lx\n",
+		ioc->name, (ioc->rev >> 4) & 0xF, ioc->rev & 0xF,
+		hpa, ioc->iov_size >> 20, ioc->ibase);
 
-	sba_dev->sba_lock = SPIN_LOCK_UNLOCKED;
+	return ioc;
 }
 
+
+
+/**************************************************************************
+**
+**   SBA initialization code (HW and SW)
+**
+**   o identify SBA chip itself
+**   o FIXME: initialize DMA hints for reasonable defaults
+**
+**************************************************************************/
+
 #ifdef CONFIG_PROC_FS
-static int sba_proc_info(char *buf, char **start, off_t offset, int len)
+static int
+sba_proc_info_one(char *buf, struct ioc *ioc)
 {
-	struct sba_device *sba_dev = sba_list;
-	struct ioc *ioc = &sba_dev->ioc[0];	/* FIXME: Multi-IOC support! */
 	int total_pages = (int) (ioc->res_size << 3); /* 8 bits per byte */
 	unsigned long i = 0, avg = 0, min, max;
 
-	sprintf(buf, "%s rev %d.%d\n",
-		"Hewlett Packard zx1 SBA",
-		((sba_dev->hw_rev >> 4) & 0xF),
-		(sba_dev->hw_rev & 0xF)
-		);
+	sprintf(buf, "Hewlett Packard %s IOC rev %d.%d\n",
+		ioc->name, ((ioc->rev >> 4) & 0xF), (ioc->rev & 0xF));
 	sprintf(buf, "%sIO PDIR size    : %d bytes (%d entries)\n",
 		buf,
 		(int) ((ioc->res_size << 3) * sizeof(u64)), /* 8 bits/byte */
@@ -1721,9 +1697,21 @@
 }
 
 static int
-sba_resource_map(char *buf, char **start, off_t offset, int len)
+sba_proc_info(char *buf, char **start, off_t offset, int len)
+{
+	struct ioc *ioc;
+	char *base = buf;
+
+	for (ioc = ioc_list; ioc; ioc = ioc->next) {
+		buf += sba_proc_info_one(buf, ioc);
+	}
+
+	return strlen(base);
+}
+
+static int
+sba_resource_map_one(char *buf, struct ioc *ioc)
 {
-	struct ioc *ioc = sba_list->ioc;	/* FIXME: Multi-IOC support! */
 	unsigned int *res_ptr = (unsigned int *)ioc->res_map;
 	int i;
 
@@ -1737,126 +1725,136 @@
 
 	return strlen(buf);
 }
-#endif
 
-/*
-** Determine if sba should claim this chip (return 0) or not (return 1).
-** If so, initialize the chip and tell other partners in crime they
-** have work to do.
-*/
-void __init sba_init(void)
+static int
+sba_resource_map(char *buf, char **start, off_t offset, int len)
 {
-	struct sba_device *sba_dev;
-	u32 func_id, hw_rev;
-	u32 *func_offset = NULL;
-	int i, agp_found = 0;
-	static char sba_rev[6];
-	struct pci_dev *device = NULL;
-	u64 hpa = 0;
-
-	if (!(device = pci_find_device(PCI_VENDOR_ID_HP, PCI_DEVICE_ID_HP_ZX1_SBA, NULL)))
-		return;
+	struct ioc *ioc;
+	char *base = buf;
 
-	for (i = 0; i < PCI_NUM_RESOURCES; i++) {
-		if (pci_resource_flags(device, i) == IORESOURCE_MEM) {
-			hpa = (u64) ioremap(pci_resource_start(device, i),
-					    pci_resource_len(device, i));
-			break;
-		}
+	for (ioc = ioc_list; ioc; ioc = ioc->next) {
+		buf += sba_resource_map_one(buf, ioc);
 	}
 
-	func_id = READ_REG(hpa + SBA_FUNC_ID);
+	return strlen(base);
+}
+#endif
 
-	if (func_id == ZX1_FUNC_ID_VALUE) {
-		(void)strcpy(sba_rev, "zx1");
-		func_offset = zx1_func_offsets;
-	} else {
-		return;
-	}
+void
+sba_enable_device(struct pci_dev *dev)
+{
+	acpi_handle handle, parent;
+	acpi_status status;
+	struct ioc *ioc;
 
-	/* Read HW Rev First */
-	hw_rev = READ_REG(hpa + SBA_FCLASS) & 0xFFUL;
+	handle = PCI_CONTROLLER(dev)->acpi_handle;
+	if (!handle)
+		return;
 
 	/*
-	 * Not all revision registers of the chipset are updated on every
-	 * turn.  Must scan through all functions looking for the highest rev
+	 * The IOC scope encloses PCI root bridges in the ACPI
+	 * namespace, so work our way out until we find an IOC we
+	 * claimed previously.
 	 */
-	if (func_offset) {
-		for (i = 0 ; func_offset[i] != -1 ; i++) {
-			u32 func_rev;
-
-			func_rev = READ_REG(hpa + SBA_FCLASS + func_offset[i]) & 0xFFUL;
-			DBG_INIT("%s() func offset: 0x%x rev: 0x%x\n",
-			         __FUNCTION__, func_offset[i], func_rev);
-			if (func_rev > hw_rev)
-				hw_rev = func_rev;
-		}
-	}
+	do {
+		for (ioc = ioc_list; ioc; ioc = ioc->next)
+			if (ioc->handle == handle) {
+				PCI_CONTROLLER(dev)->iommu = ioc;
+				return;
+			}
 
-	printk(KERN_INFO "%s found %s %d.%d at %s, HPA 0x%lx\n", DRIVER_NAME,
-	       sba_rev, ((hw_rev >> 4) & 0xF), (hw_rev & 0xF),
-	       device->slot_name, hpa);
+		status = acpi_get_parent(handle, &parent);
+		handle = parent;
+	} while (ACPI_SUCCESS(status));
 
-	if ((hw_rev & 0xFF) < 0x20) {
-		printk(KERN_INFO "%s WARNING rev 2.0 or greater will be required for IO MMU support in the future\n", DRIVER_NAME);
-#ifndef CONFIG_IA64_HP_PROTO
-		panic("%s: CONFIG_IA64_HP_PROTO MUST be enabled to support SBA rev less than 2.0", DRIVER_NAME);
-#endif
-	}
+	printk("No IOC for %s in ACPI\n", dev->slot_name);
+}
 
-	sba_dev = kmalloc(sizeof(struct sba_device), GFP_KERNEL);
-	if (NULL == sba_dev) {
-		printk(KERN_ERR DRIVER_NAME " - couldn't alloc sba_device\n");
-		return;
-	}
+static int __init
+acpi_sba_ioc_add(struct acpi_device *device)
+{
+	struct ioc *ioc;
+	acpi_status status;
+	u64 hpa, length;
+
+	/*
+	 * Only SBA appears in ACPI namespace.  It encloses the PCI
+	 * root bridges, and its CSR space includes the IOC function.
+	 */
+	status = acpi_hp_csr_space(device->handle, &hpa, &length);
+	if (ACPI_FAILURE(status))
+		return 1;
+	ioc = ioc_init(hpa + ZX1_IOC_OFFSET, device->handle);
+	if (!ioc)
+		return 1;
+
+	return 0;
+}
 
-	memset(sba_dev, 0, sizeof(struct sba_device));
+static int __init
+acpi_ioc_add(struct acpi_device *device)
+{
+	struct ioc *ioc;
+	acpi_status status;
+	u64 hpa, length;
 
-	for(i=0; i<MAX_IOC; i++)
-		spin_lock_init(&(sba_dev->ioc[i].res_lock));
+	status = acpi_hp_csr_space(device->handle, &hpa, &length);
+	if (ACPI_FAILURE(status))
+		return 1;
+	ioc = ioc_init(hpa, device->handle);
+	if (!ioc)
+		return 1;
 
-	sba_dev->hw_rev = hw_rev;
-	sba_dev->sba_hpa = hpa;
+	return 0;
+}
 
-	/*
-	 * We pass this fake device from alloc_consistent to ensure
-	 * we only use SAC for alloc_consistent mappings.
-	 */
-	sac_only_dev.dma_mask = 0xFFFFFFFFUL;
+static struct acpi_driver acpi_sba_ioc_driver = {
+	name:		"IOC IOMMU Driver",
+	ids:		"HWP0001",
+	ops: {
+		add:	acpi_sba_ioc_add,
+     },
+};
 
-	/*
-	 * We need to check for an AGP device, if we find one, then only
-	 * use part of the IOVA space for PCI DMA, the rest is for GART.
-	 * REVISIT for multiple IOC.
-	 */
-	pci_for_each_dev(device)
-		agp_found |= pci_find_capability(device, PCI_CAP_ID_AGP);
+static struct acpi_driver acpi_ioc_driver = {
+	name:		"IOC IOMMU Driver",
+	ids:		"HWP0004",
+	ops: {
+		add:	acpi_ioc_add,
+     },
+};
 
-	if (agp_found && reserve_sba_gart)
-		SBA_SET_AGP(sba_dev);
+void __init
+ioc_acpi_init(void)
+{
+	acpi_bus_register_driver(&acpi_sba_ioc_driver);
+	acpi_bus_register_driver(&acpi_ioc_driver);
+}
 
-	sba_hw_init(sba_dev);
-	sba_common_init(sba_dev);
+void __init
+sba_init(void)
+{
+	ioc_acpi_init();
 
 #ifdef CONFIG_PROC_FS
-	{
+	if (ioc_list) {
 		struct proc_dir_entry * proc_mckinley_root;
 
 		proc_mckinley_root = proc_mkdir("bus/mckinley",0);
-		create_proc_info_entry(sba_rev, 0, proc_mckinley_root, sba_proc_info);
+		create_proc_info_entry(ioc_list->name, 0, proc_mckinley_root, sba_proc_info);
 		create_proc_info_entry("bitmap", 0, proc_mckinley_root, sba_resource_map);
 	}
 #endif
 }
 
 static int __init
-nosbagart (char *str)
+nosbagart(char *str)
 {
 	reserve_sba_gart = 0;
 	return 1;
 }
 
-__setup("nosbagart",nosbagart);
+__setup("nosbagart", nosbagart);
 
 EXPORT_SYMBOL(sba_init);
 EXPORT_SYMBOL(sba_map_single);
diff -u -r 70_enable_device/arch/ia64/hp/zx1/hpzx1_misc.c 80_multi_ioc/arch/ia64/hp/zx1/hpzx1_misc.c
--- 70_enable_device/arch/ia64/hp/zx1/hpzx1_misc.c	Sat Jul 20 16:33:47 2002
+++ 80_multi_ioc/arch/ia64/hp/zx1/hpzx1_misc.c	Sat Jul 20 16:48:53 2002
@@ -182,74 +182,6 @@
 	hpzx1_devices++;
 }
 
-typedef struct {
-	u8	guid_id;
-	u8	guid[16];
-	u8	csr_base[8];
-	u8	csr_length[8];
-} acpi_hp_vendor_long;
-
-#define HP_CCSR_LENGTH 0x21
-#define HP_CCSR_TYPE 0x2
-#define HP_CCSR_GUID EFI_GUID(0x69e9adf9, 0x924f, 0xab5f, \
-			      0xf6, 0x4a, 0x24, 0xd2, 0x01, 0x37, 0x0e, 0xad)
-
-extern acpi_status acpi_get_crs(acpi_handle, acpi_buffer *);
-extern acpi_resource *acpi_get_crs_next(acpi_buffer *, int *);
-extern acpi_resource_data *acpi_get_crs_type(acpi_buffer *, int *, int);
-extern void acpi_dispose_crs(acpi_buffer *);
-
-static acpi_status
-hp_csr_space(acpi_handle obj, u64 *csr_base, u64 *csr_length)
-{
-	int i, offset = 0;
-	acpi_status status;
-	acpi_buffer buf;
-	acpi_resource_vendor *res;
-	acpi_hp_vendor_long *hp_res;
-	efi_guid_t vendor_guid;
-
-	*csr_base = 0;
-	*csr_length = 0;
-
-	status = acpi_get_crs(obj, &buf);
-	if (ACPI_FAILURE(status)) {
-		printk(KERN_ERR PFX "Unable to get _CRS data on object\n");
-		return status;
-	}
-
-	res = (acpi_resource_vendor *)acpi_get_crs_type(&buf, &offset, ACPI_RSTYPE_VENDOR);
-	if (!res) {
-		printk(KERN_ERR PFX "Failed to find config space for device\n");
-		acpi_dispose_crs(&buf);
-		return AE_NOT_FOUND;
-	}
-
-	hp_res = (acpi_hp_vendor_long *)(res->reserved);
-
-	if (res->length != HP_CCSR_LENGTH || hp_res->guid_id != HP_CCSR_TYPE) {
-		printk(KERN_ERR PFX "Unknown Vendor data\n");
-		acpi_dispose_crs(&buf);
-		return AE_TYPE; /* Revisit error? */
-	}
-
-	memcpy(&vendor_guid, hp_res->guid, sizeof(efi_guid_t));
-	if (efi_guidcmp(vendor_guid, HP_CCSR_GUID) != 0) {
-		printk(KERN_ERR PFX "Vendor GUID does not match\n");
-		acpi_dispose_crs(&buf);
-		return AE_TYPE; /* Revisit error? */
-	}
-
-	for (i = 0 ; i < 8 ; i++) {
-		*csr_base |= ((u64)(hp_res->csr_base[i]) << (i * 8));
-		*csr_length |= ((u64)(hp_res->csr_length[i]) << (i * 8));
-	}
-
-	acpi_dispose_crs(&buf);
-
-	return AE_OK;
-}
-
 static acpi_status
 hpzx1_sba_probe(acpi_handle obj, u32 depth, void *context, void **ret)
 {
@@ -258,7 +190,7 @@
 	char *name = context;
 	char fullname[16];
 
-	status = hp_csr_space(obj, &csr_base, &csr_length);
+	status = acpi_hp_csr_space(obj, &csr_base, &csr_length);
 	if (ACPI_FAILURE(status))
 		return status;
 
@@ -284,7 +216,7 @@
 	char *name = context;
 	char fullname[32];
 
-	status = hp_csr_space(obj, &csr_base, &csr_length);
+	status = acpi_hp_csr_space(obj, &csr_base, &csr_length);
 	if (ACPI_FAILURE(status))
 		return status;
 
diff -u -r 70_enable_device/arch/ia64/kernel/acpi.c 80_multi_ioc/arch/ia64/kernel/acpi.c
--- 70_enable_device/arch/ia64/kernel/acpi.c	Sat Jul 20 16:35:33 2002
+++ 80_multi_ioc/arch/ia64/kernel/acpi.c	Sat Jul 20 16:48:53 2002
@@ -236,6 +236,69 @@
 
 	return AE_OK;
 }
+
+typedef struct {
+	u8	guid_id;
+	u8	guid[16];
+	u8	csr_base[8];
+	u8	csr_length[8];
+} acpi_hp_vendor_long;
+
+#define HP_CCSR_LENGTH 0x21
+#define HP_CCSR_TYPE 0x2
+#define HP_CCSR_GUID EFI_GUID(0x69e9adf9, 0x924f, 0xab5f, \
+			      0xf6, 0x4a, 0x24, 0xd2, 0x01, 0x37, 0x0e, 0xad)
+
+acpi_status
+acpi_hp_csr_space(acpi_handle obj, u64 *csr_base, u64 *csr_length)
+{
+	int i, offset = 0;
+	acpi_status status;
+	acpi_buffer buf;
+	acpi_resource_vendor *res;
+	acpi_hp_vendor_long *hp_res;
+	efi_guid_t vendor_guid;
+
+	*csr_base = 0;
+	*csr_length = 0;
+
+	status = acpi_get_crs(obj, &buf);
+	if (ACPI_FAILURE(status)) {
+		printk(KERN_ERR PREFIX "Unable to get _CRS data on object\n");
+		return status;
+	}
+
+	res = (acpi_resource_vendor *)acpi_get_crs_type(&buf, &offset, ACPI_RSTYPE_VENDOR);
+	if (!res) {
+		printk(KERN_ERR PREFIX "Failed to find config space for device\n");
+		acpi_dispose_crs(&buf);
+		return AE_NOT_FOUND;
+	}
+
+	hp_res = (acpi_hp_vendor_long *)(res->reserved);
+
+	if (res->length != HP_CCSR_LENGTH || hp_res->guid_id != HP_CCSR_TYPE) {
+		printk(KERN_ERR PREFIX "Unknown Vendor data\n");
+		acpi_dispose_crs(&buf);
+		return AE_TYPE; /* Revisit error? */
+	}
+
+	memcpy(&vendor_guid, hp_res->guid, sizeof(efi_guid_t));
+	if (efi_guidcmp(vendor_guid, HP_CCSR_GUID) != 0) {
+		printk(KERN_ERR PREFIX "Vendor GUID does not match\n");
+		acpi_dispose_crs(&buf);
+		return AE_TYPE; /* Revisit error? */
+	}
+
+	for (i = 0 ; i < 8 ; i++) {
+		*csr_base |= ((u64)(hp_res->csr_base[i]) << (i * 8));
+		*csr_length |= ((u64)(hp_res->csr_length[i]) << (i * 8));
+	}
+
+	acpi_dispose_crs(&buf);
+
+	return AE_OK;
+}
 #endif /* CONFIG_ACPI */
 
 #ifdef CONFIG_ACPI_BOOT
diff -u -r 70_enable_device/include/asm-ia64/machvec_hpzx1.h 80_multi_ioc/include/asm-ia64/machvec_hpzx1.h
--- 70_enable_device/include/asm-ia64/machvec_hpzx1.h	Sat Jul 20 16:31:09 2002
+++ 80_multi_ioc/include/asm-ia64/machvec_hpzx1.h	Sat Jul 20 16:48:53 2002
@@ -3,6 +3,7 @@
 
 extern ia64_mv_setup_t dig_setup;
 extern ia64_mv_pci_fixup_t hpzx1_pci_fixup;
+extern ia64_mv_pci_enable_device_t sba_enable_device;
 extern ia64_mv_map_nr_t map_nr_dense;
 extern ia64_mv_pci_alloc_consistent sba_alloc_consistent;
 extern ia64_mv_pci_free_consistent sba_free_consistent;
@@ -23,6 +24,7 @@
 #define platform_name			"hpzx1"
 #define platform_setup			dig_setup
 #define platform_pci_fixup		hpzx1_pci_fixup
+#define platform_pci_enable_device	sba_enable_device
 #define platform_map_nr			map_nr_dense
 #define platform_pci_dma_init		((ia64_mv_pci_dma_init *) machvec_noop)
 #define platform_pci_alloc_consistent	sba_alloc_consistent
diff -u -r 70_enable_device/include/asm-ia64/pci.h 80_multi_ioc/include/asm-ia64/pci.h
--- 70_enable_device/include/asm-ia64/pci.h	Sat Jul 20 16:35:33 2002
+++ 80_multi_ioc/include/asm-ia64/pci.h	Sat Jul 20 16:48:53 2002
@@ -84,6 +84,7 @@
 
 struct pci_controller {
 	void *acpi_handle;
+	void *iommu;
 	int segment;
 
 	u64 mem_offset;
diff -u -r 70_enable_device/include/linux/acpi.h 80_multi_ioc/include/linux/acpi.h
--- 70_enable_device/include/linux/acpi.h	Sat Jul 20 16:35:33 2002
+++ 80_multi_ioc/include/linux/acpi.h	Sat Jul 20 16:48:53 2002
@@ -36,6 +36,7 @@
  * isn't the right answer either.  Please just ignore it for now.
  */
 #include "../../drivers/acpi/include/acpi.h"
+#include "../../drivers/acpi/acpi_drivers.h"
 #include <asm/acpi.h>
 
 
@@ -378,6 +379,7 @@
 
 int acpi_init(void);
 int acpi_irq_to_vector(u32 irq);
+acpi_status acpi_hp_csr_space (acpi_handle, u64 *base, u64 *length);
 acpi_status acpi_get_addr_space(acpi_handle, u8 type, u64 *base, u64 *length, u64 *tra);
 
 
diff -u -r 70_enable_device/include/linux/pci_ids.h 80_multi_ioc/include/linux/pci_ids.h
--- 70_enable_device/include/linux/pci_ids.h	Sat Jul 20 16:31:10 2002
+++ 80_multi_ioc/include/linux/pci_ids.h	Sat Jul 20 16:48:53 2002
@@ -505,6 +505,8 @@
 #define PCI_DEVICE_ID_HP_DIVA1		0x1049
 #define PCI_DEVICE_ID_HP_DIVA2		0x104A
 #define PCI_DEVICE_ID_HP_SP2_0		0x104B
+#define PCI_DEVICE_ID_HP_REO_SBA	0x10f0
+#define PCI_DEVICE_ID_HP_REO_IOC	0x10f1
 #define PCI_DEVICE_ID_HP_ZX1_SBA	0x1229
 #define PCI_DEVICE_ID_HP_ZX1_IOC	0x122a
 #define PCI_DEVICE_ID_HP_ZX1_LBA	0x122e

--------------Boundary-00=_DI8OG9N44J5EWH7I4DL4--


