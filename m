From: Khalid Aziz <khalid_aziz@hp.com>
Date: Thu, 21 Nov 2002 17:31:44 +0000
Subject: [Linux-ia64] [PATCH 2.5] Support for HCDP console
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------42D6CD343E791A73D272F4A9"
Message-Id: <marc-linux-ia64-105590709805466@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------42D6CD343E791A73D272F4A9
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Attached patch adds support for HCDP described serial console to 2.5
kernel. This patch applies on top of 2.5.45+Mosberger's 021031 patch.

David, please apply.

--
Khalid 

====================================================================
Khalid Aziz                                Linux and Open Source Lab
(970)898-9214                                        Hewlett-Packard
khalid@hp.com                                       Fort Collins, CO

"The Linux kernel is subject to relentless development" 
				- Alessandro Rubini
--------------42D6CD343E791A73D272F4A9
Content-Type: text/plain; charset=us-ascii;
 name="patch.hcdp_2.5.45_mosberger"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch.hcdp_2.5.45_mosberger"

diff -urN linux-2.5.45/arch/ia64/kernel/setup.c linux-2.5.45-hcdp/arch/ia64/kernel/setup.c
--- linux-2.5.45/arch/ia64/kernel/setup.c	Wed Nov 13 16:56:54 2002
+++ linux-2.5.45-hcdp/arch/ia64/kernel/setup.c	Wed Nov 13 16:01:37 2002
@@ -421,7 +421,7 @@
 #ifdef CONFIG_ACPI_BOOT
 	acpi_boot_init(*cmdline_p);
 #endif
-#ifdef CONFIG_SERIAL_HCDP
+#ifdef CONFIG_SERIAL_8250_HCDP
 	if (efi.hcdp) {
 		void setup_serial_hcdp(void *);
 
diff -urN linux-2.5.45/drivers/serial/8250.c linux-2.5.45-hcdp/drivers/serial/8250.c
--- linux-2.5.45/drivers/serial/8250.c	Wed Nov 13 16:56:55 2002
+++ linux-2.5.45-hcdp/drivers/serial/8250.c	Wed Nov 13 16:01:37 2002
@@ -1692,8 +1692,27 @@
 		return;
 	first = 0;
 
-	for (i = 0, up = serial8250_ports; i < ARRAY_SIZE(old_serial_port);
-	     i++, up++) {
+	for (i = 0, up = serial8250_ports; i < UART_NR; i++, up++) {
+		/*
+		 * Is this entry available? If not, look for the first 
+		 * available one. If we run out of available entries,
+		 * we are done.
+		 */
+		while ((up->port.iobase != 0) || (up->port.membase != 0)) {
+			if ((++up) > (up+UART_NR))
+				return;
+		}
+
+		/*
+		 * A placeholder entry in old_serial_port will have a 
+		 * membase and iobase of -1. Skip such entries. These ports
+		 * will be added separately.
+		 */
+		while ((old_serial_port[i].port == -1) && 
+				(old_serial_port[i].iomem_base == (unsigned char *) -1)) {
+			if (++i >= UART_NR)
+				return;
+		}
 		up->port.iobase   = old_serial_port[i].port;
 		up->port.irq      = irq_cannonicalize(old_serial_port[i].irq);
 		up->port.uartclk  = old_serial_port[i].baud_base * 16;
@@ -1915,14 +1936,13 @@
 	return __register_serial(req, -1);
 }
 
-int __init early_register_port (struct uart_port *port)
+int __init early_serial_setup(struct uart_port *port)
 {
-	if (port->line >= ARRAY_SIZE(serial8250_ports))
-		return -ENODEV;
-
-	serial8250_isa_init_ports();	/* force ISA defaults */
-	serial8250_ports[port->line].port = *port;
-	serial8250_ports[port->line].port.ops = &serial8250_pops;
+	serial8250_ports[port->line].port        = *port;
+	serial8250_ports[port->line].port.irq    = irq_cannonicalize(port->irq);
+	serial8250_ports[port->line].port.uartclk= port->uartclk * 16;
+	serial8250_ports[port->line].port.flags  = port->flags | UPF_RESOURCES;
+	serial8250_ports[port->line].port.ops     = &serial8250_pops;
 	return 0;
 }
 
diff -urN linux-2.5.45/drivers/serial/8250_hcdp.c linux-2.5.45-hcdp/drivers/serial/8250_hcdp.c
--- linux-2.5.45/drivers/serial/8250_hcdp.c	Wed Nov 13 16:56:55 2002
+++ linux-2.5.45-hcdp/drivers/serial/8250_hcdp.c	Wed Nov 13 16:01:37 2002
@@ -4,15 +4,16 @@
  * Copyright (C) 2002 Hewlett-Packard Co.
  *	Khalid Aziz <khalid_aziz@hp.com>
  *
- * Parse the EFI HCDP table to locate serial console and debug ports and initialize them.
+ * Parse the EFI HCDP table to locate serial console and debug ports 
+ * and initialize them.
  *
- * 2002/08/29 davidm	Adjust it to new 2.5 serial driver infrastructure (untested).
+ * 2002/08/29 davidm	Adjust it to new 2.5 serial driver 
+ * 			infrastructure (untested).
  */
 #include <linux/config.h>
 
 #include <linux/kernel.h>
 #include <linux/efi.h>
-#include <linux/hcdp_serial.h>
 #include <linux/init.h>
 #include <linux/tty.h>
 #include <linux/serial.h>
@@ -22,27 +23,27 @@
 #include <asm/io.h>
 #include <asm/serial.h>
 
-#define SERIAL_DEBUG_HCDP
+#include "8250_hcdp.h"
+
+#undef SERIAL_DEBUG_HCDP
 
 /*
- * Parse the HCDP table to find descriptions for headless console and debug serial ports
- * and add them to rs_table[]. A pointer to HCDP table is passed as parameter. This
- * function should be called before serial_console_init() is called to make sure the HCDP
- * serial console will be available for use. IA-64 kernel calls this function from
+ * Parse the HCDP table to find descriptions for headless console and 
+ * debug serial ports and add them to rs_table[]. A pointer to HCDP 
+ * table is passed as parameter. This function should be called before 
+ * serial_console_init() is called to make sure the HCDP serial console 
+ * will be available for use. IA-64 kernel calls this function from
  * setup_arch() after the EFI and ACPI tables have been parsed.
  */
 void __init
-setup_serial_hcdp (void *tablep)
+setup_serial_hcdp(void *tablep)
 {
 	hcdp_dev_t *hcdp_dev;
 	struct uart_port port;
 	unsigned long iobase;
 	hcdp_t hcdp;
-	int gsi, i = 0, nr;
-#if 0
-	static int shift_once = 1;
-#endif
-	extern int early_register_port (struct uart_port *);  /* XXX fix me */
+	int gsi, nr;
+	extern int early_register_port(struct uart_port *);	/* XXX fix me */
 
 #ifdef SERIAL_DEBUG_HCDP
 	printk("Entering setup_serial_hcdp()\n");
@@ -52,17 +53,19 @@
 	if (!tablep)
 		return;
 
-	memset(&port, 0, sizeof(port));
+	memset(&port, 0, sizeof (port));
 
 	/*
-	 * Don't trust firmware to give us a table starting at an aligned address. Make a
-	 * local copy of the HCDP table with aligned structures.
+	 * Don't trust firmware to give us a table starting at an 
+	 * aligned address. Make a local copy of the HCDP table with 
+	 * aligned structures.
 	 */
-	memcpy(&hcdp, tablep, sizeof(hcdp));
+	memcpy(&hcdp, tablep, sizeof (hcdp));
 
 	/*
-	 * Perform a sanity check on the table. Table should have a signature of "HCDP"
-	 * and it should be atleast 82 bytes long to have any useful information.
+	 * Perform a sanity check on the table. Table should have a 
+	 * signature of "HCDP" and it should be atleast 82 bytes long 
+	 * to have any useful information.
 	 */
 	if ((strncmp(hcdp.signature, HCDP_SIGNATURE, HCDP_SIG_LEN) != 0))
 		return;
@@ -70,15 +73,18 @@
 		return;
 
 #ifdef SERIAL_DEBUG_HCDP
-	printk("setup_serial_hcdp(): table pointer = 0x%p\n", tablep);
-	printk("                     sig = '%c%c%c%c'\n",
-	       hcdp.signature[0], hcdp.signature[1], hcdp.signature[2], hcdp.signature[3]);
-	printk("                     length = %d\n", hcdp.len);
-	printk("                     Rev = %d\n", hcdp.rev);
-	printk("                     OEM ID = %c%c%c%c%c%c\n",
+	printk("setup_serial_hcdp():\n");
+	printk("   table pointer = 0x%p\n", tablep);
+	printk("   sig = '%c%c%c%c'\n",
+	       hcdp.signature[0], hcdp.signature[1], hcdp.signature[2],
+	       hcdp.signature[3]);
+	printk("   length = %d\n", hcdp.len);
+	printk("   Rev = %d\n", hcdp.rev);
+	printk("   OEM ID = %c%c%c%c%c%c\n",
 	       hcdp.oemid[0], hcdp.oemid[1], hcdp.oemid[2],
 	       hcdp.oemid[3], hcdp.oemid[4], hcdp.oemid[5]);
-	printk("                     Number of entries = %d\n", hcdp.num_entries);
+	printk("      Number of entries = %d\n",
+	       hcdp.num_entries);
 #endif
 
 	/*
@@ -87,109 +93,87 @@
 	for (nr = 0; nr < hcdp.num_entries; nr++) {
 		hcdp_dev = hcdp.hcdp_dev + nr;
 		/*
-		 * We will parse only the primary console device which is the first entry
-		 * for these devices. We will ignore rest of the entries for the same type
-		 * device that has already been parsed and initialized
+		 * We will parse only the primary console device which is 
+		 * the first entry for these devices. We will ignore rest 
+		 * of the entries for the same type device that has 
+		 * already been parsed and initialized
 		 */
 		if (hcdp_dev->type != HCDP_DEV_CONSOLE)
 			continue;
 
-		iobase = ((u64) hcdp_dev->base_addr.addrhi << 32) | hcdp_dev->base_addr.addrlo;
+		iobase =
+		    ((u64) hcdp_dev->base_addr.addrhi << 32) | hcdp_dev->
+		    base_addr.addrlo;
 		gsi = hcdp_dev->global_int;
 #ifdef SERIAL_DEBUG_HCDP
-		printk("                 type = %s\n",
+		printk("      type = %s\n",
 		       ((hcdp_dev->type == HCDP_DEV_CONSOLE)
-			? "Headless Console" : ((hcdp_dev->type == HCDP_DEV_DEBUG)
-						? "Debug port" : "Huh????")));
-		printk("                 Base address space = %s\n",
+			? "Headless Console"
+			: ((hcdp_dev->type == HCDP_DEV_DEBUG)
+			   ? "Debug port" : "Huh????")));
+		printk("      Base address space = %s\n",
 		       ((hcdp_dev->base_addr.space_id == ACPI_MEM_SPACE)
-			? "Memory Space" : ((hcdp_dev->base_addr.space_id == ACPI_IO_SPACE)
-					    ? "I/O space" : "PCI space")));
-		printk("                 Base address = 0x%lx\n", iobase);
-		printk("                 Global System Int = %d\n", gsi);
-		printk("                 Baud rate = %lu\n", (unsigned long) hcdp_dev->baud);
-		printk("                 Bits = %d\n", hcdp_dev->bits);
-		printk("                 Clock rate = %d\n", hcdp_dev->clock_rate);
+			? "Memory Space"
+			: ((hcdp_dev->base_addr.space_id == ACPI_IO_SPACE)
+			   ? "I/O space" : "PCI space")));
+		printk("      Base address = 0x%p\n", iobase);
+		printk("      Global System Int = %d\n", gsi);
+		printk("      Baud rate = %lu\n",
+		       (unsigned long) hcdp_dev->baud);
+		printk("      Bits = %d\n", hcdp_dev->bits);
+		printk("      Clock rate = %d\n",
+		       hcdp_dev->clock_rate);
 		if (hcdp_dev->base_addr.space_id == ACPI_PCICONF_SPACE) {
-			printk("             PCI serial port:\n");
-			printk("                 Bus %d, Device %d, Vendor ID 0x%x, Dev ID 0x%x\n",
-			       hcdp_dev->pci_bus, hcdp_dev->pci_dev,
-			       hcdp_dev->pci_vendor_id, hcdp_dev->pci_dev_id);
+			printk("      PCI serial port:\n");
+			printk
+			    ("         Bus %d, Device %d, Vendor ID 0x%x, Dev ID 0x%x\n",
+			     hcdp_dev->pci_bus, hcdp_dev->pci_dev,
+			     hcdp_dev->pci_vendor_id, hcdp_dev->pci_dev_id);
 		}
 #endif
 		/*
-		 * Now fill in a port structure to update the 8250 port table..
+		 * Now fill in a port structure to update the 8250 port table.
 		 */
 		if (hcdp_dev->clock_rate)
 			port.uartclk = hcdp_dev->clock_rate;
 		else
 			port.uartclk = DEFAULT_UARTCLK;
 		/*
-		 * Check if this is an I/O mapped address or a memory mapped address
+		 * Check if this is an I/O mapped address or a memory 
+		 * mapped address
 		 */
 		if (hcdp_dev->base_addr.space_id == ACPI_MEM_SPACE) {
 			port.iobase = 0;
 			port.mapbase = iobase;
 			port.membase = ioremap(iobase, 64);
-			port.iotype = SERIAL_IO_MEM;
+			port.iotype = UPIO_MEM;
 		} else if (hcdp_dev->base_addr.space_id == ACPI_IO_SPACE) {
 			port.iobase = iobase;
 			port.mapbase = 0;
 			port.membase = NULL;
-			port.iotype = SERIAL_IO_PORT;
+			port.iotype = UPIO_PORT;
 		} else if (hcdp_dev->base_addr.space_id == ACPI_PCICONF_SPACE) {
 			printk("WARNING: No support for PCI serial console\n");
 			return;
 		}
 
-#if 0
 		/*
-		 * Check if HCDP defines a port already in rs_table
+		 * We will place the console at ttyS0
 		 */
-		for (i = 0; i < serial_nr_ports; i++) {
-			if ((rs_table[i].port == serial_req.port) &&
-				(rs_table[i].iomem_base==serial_req.iomem_base))
-				break;
-		}
-		if (i == serial_nr_ports) {
-			/*
-			 * We have reserved a slot for HCDP defined console port at
-			 * HCDP_SERIAL_CONSOLE_PORT in rs_table which is not 0. This means
-			 * using this slot would put the console at a device other than
-			 * ttyS0.  Users expect to see the console at ttyS0. Now that we
-			 * have determined HCDP does describe a serial console and it is
-			 * not one of the compiled in ports, let us move the entries in
-			 * rs_table up by a slot towards HCDP_SERIAL_CONSOLE_PORT to make
-			 * room for the HCDP console at ttyS0. We may go through this loop
-			 * more than once if early_serial_setup() fails. Make sure we
-			 * shift the entries in rs_table only once.
-			 */
-			if (shift_once) {
-				int j;
-
-				for (j = HCDP_SERIAL_CONSOLE_PORT; j > 0; j--)
-					memcpy(rs_table+j, rs_table+j-1,
-					       sizeof(struct serial_state));
-				shift_once = 0;
-			}
-			serial_req.line = 0;
-		} else
-			serial_req.line = i;
-#else
-		port.line = i++;	/* XXX fix me */
-#endif
-
+		port.line = 0;
 		port.irq = gsi;
-		port.flags = UPF_SKIP_TEST | UPF_BOOT_AUTOCONF;
-		if (gsi)
-			port.flags |= ASYNC_AUTO_IRQ;
-
+		if (gsi == 0)
+			port.flags = ASYNC_SKIP_TEST | ASYNC_BOOT_AUTOCONF;
+		else
+			port.flags = ASYNC_SKIP_TEST | ASYNC_BOOT_AUTOCONF |
+						UPF_AUTO_IRQ;
 		port.fifosize = 0;
 		port.hub6 = 0;
 		port.regshift = 0;
-		if (early_register_port(&port) < 0) {
-			printk("setup_serial_hcdp(): early_register_port() for HCDP serial "
-			       "console port failed. Will try any additional consoles in HCDP.\n");
+		if (early_serial_setup(&port) < 0) {
+			printk
+			    ("setup_serial_hcdp(): early_register_port() for HCDP serial "
+			     "console port failed. Will try any additional consoles in HCDP.\n");
 			continue;
 		} else if (hcdp_dev->type == HCDP_DEV_CONSOLE)
 			break;
@@ -205,7 +189,7 @@
 
 #ifdef CONFIG_IA64_EARLY_PRINTK_UART
 unsigned long
-hcdp_early_uart (void)
+hcdp_early_uart(void)
 {
 	efi_system_table_t *systab;
 	efi_config_table_t *config_tables;
@@ -235,8 +219,9 @@
 
 	for (i = 0, dev = hcdp->hcdp_dev; i < hcdp->num_entries; i++, dev++) {
 		if (dev->type == HCDP_DEV_CONSOLE)
-			return (u64) dev->base_addr.addrhi << 32 | dev->base_addr.addrlo;
+			return (u64) dev->base_addr.addrhi << 32 | dev->
+			    base_addr.addrlo;
 	}
 	return 0;
 }
-#endif /* CONFIG_IA64_EARLY_PRINTK_UART */
+#endif				/* CONFIG_IA64_EARLY_PRINTK_UART */
diff -urN linux-2.5.45/drivers/serial/8250_hcdp.h linux-2.5.45-hcdp/drivers/serial/8250_hcdp.h
--- linux-2.5.45/drivers/serial/8250_hcdp.h	Wed Dec 31 17:00:00 1969
+++ linux-2.5.45-hcdp/drivers/serial/8250_hcdp.h	Wed Nov 13 16:01:37 2002
@@ -0,0 +1,79 @@
+/*
+ * drivers/serial/8250_hcdp.h
+ *
+ * Copyright (C) 2002 Hewlett-Packard Co.
+ *	Khalid Aziz <khalid_aziz@hp.com>
+ *
+ * Definitions for HCDP defined serial ports (Serial console and debug
+ * ports)
+ */
+
+/* ACPI table signatures */
+#define HCDP_SIG_LEN		4
+#define HCDP_SIGNATURE		"HCDP"
+
+/* Space ID as defined in ACPI generic address structure */
+#define ACPI_MEM_SPACE		0
+#define ACPI_IO_SPACE		1
+#define ACPI_PCICONF_SPACE	2
+
+/*
+ * Maximum number of HCDP devices we want to read in
+ */
+#define MAX_HCDP_DEVICES	6
+
+/*
+ * Default UART clock rate if clock rate is 0 in HCDP table.
+ */
+#define DEFAULT_UARTCLK		115200
+
+/*
+ * ACPI Generic Address Structure
+ */
+typedef struct {
+	u8  space_id;
+	u8  bit_width;
+	u8  bit_offset;
+	u8  resv;
+	u32 addrlo;
+	u32 addrhi;
+} acpi_gen_addr;
+
+/* HCDP Device descriptor entry types */
+#define HCDP_DEV_CONSOLE	0
+#define HCDP_DEV_DEBUG		1
+
+/* HCDP Device descriptor type */
+typedef struct {
+	u8	type;
+	u8	bits;
+	u8	parity;
+	u8	stop_bits;
+	u8	pci_seg;
+	u8	pci_bus;
+	u8	pci_dev;
+	u8	pci_func;
+	u64	baud;
+	acpi_gen_addr	base_addr;
+	u16	pci_dev_id;
+	u16	pci_vendor_id;
+	u32	global_int;
+	u32	clock_rate;
+	u8	pci_prog_intfc;
+	u8	resv;
+} hcdp_dev_t;
+
+/* HCDP Table format */
+typedef struct {
+	u8	signature[4];
+	u32	len;
+	u8	rev;
+	u8	chksum;
+	u8	oemid[6];
+	u8	oem_tabid[8];
+	u32	oem_rev;
+	u8	creator_id[4];
+	u32	creator_rev;
+	u32	num_entries;
+	hcdp_dev_t	hcdp_dev[MAX_HCDP_DEVICES];
+} hcdp_t;
diff -urN linux-2.5.45/drivers/serial/Kconfig linux-2.5.45-hcdp/drivers/serial/Kconfig
--- linux-2.5.45/drivers/serial/Kconfig	Wed Nov 13 16:56:55 2002
+++ linux-2.5.45-hcdp/drivers/serial/Kconfig	Wed Nov 13 16:01:37 2002
@@ -77,6 +77,14 @@
 	  a module, say M here and read <file:Documentation/modules.txt>.
 	  If unsure, say N.
 
+config SERIAL_8250_HCDP
+	bool "8250/16550 device discovery support via EFI HCDP table"
+	depends on IA64
+	---help---
+	  If you wish to make the serial console port described by the EFI 
+	  HCDP table available for use as serial console or general
+	  purpose port, say Y here.
+
 config SERIAL_8250_EXTENDED
 	bool "Extended 8250/16550 serial driver options"
 	depends on SERIAL_8250
@@ -155,13 +163,6 @@
 	  Locate serial ports via the Microsoft proprietary ACPI SPCR/DBGP tables.
 	  This table has been superseded by the EFI HCDP table.
 
-config SERIAL_8250_HCDP
-	tristate "8250/16550 device discovery support via EFI HCDP table"
-	depends on IA64
-	help
-	  Locate console and debug serial ports via the EFI HCDP table.  See
-	  <http://www.dig64.org/specifications/DIG64_HCDPv10a_01.pdf>.
-
 config SERIAL_ANAKIN
 	bool "Anakin serial port support"
 	depends on ARM && ARCH_ANAKIN
diff -urN linux-2.5.45/drivers/serial/Makefile linux-2.5.45-hcdp/drivers/serial/Makefile
--- linux-2.5.45/drivers/serial/Makefile	Wed Nov 13 16:56:55 2002
+++ linux-2.5.45-hcdp/drivers/serial/Makefile	Wed Nov 13 16:01:37 2002
@@ -10,12 +10,12 @@
 serial-8250-$(CONFIG_PCI) += 8250_pci.o
 serial-8250-$(CONFIG_PNP) += 8250_pnp.o
 serial-8250-$(CONFIG_SERIAL_8250_ACPI) += 8250_acpi.o
-serial-8250-$(CONFIG_SERIAL_8250_HCDP) += 8250_hcdp.o
 obj-$(CONFIG_SERIAL_CORE) += core.o
 obj-$(CONFIG_SERIAL_21285) += 21285.o
 obj-$(CONFIG_SERIAL_8250) += 8250.o $(serial-8250-y)
 obj-$(CONFIG_SERIAL_8250_CS) += 8250_cs.o
 obj-$(CONFIG_SERIAL_8250_ACORN) += 8250_acorn.o
+obj-$(CONFIG_SERIAL_8250_HCDP) += 8250_hcdp.o
 obj-$(CONFIG_SERIAL_ANAKIN) += anakin.o
 obj-$(CONFIG_SERIAL_AMBA) += amba.o
 obj-$(CONFIG_SERIAL_CLPS711X) += clps711x.o
diff -urN linux-2.5.45/drivers/serial/core.c linux-2.5.45-hcdp/drivers/serial/core.c
--- linux-2.5.45/drivers/serial/core.c	Wed Oct 30 17:42:20 2002
+++ linux-2.5.45-hcdp/drivers/serial/core.c	Wed Nov 13 16:01:37 2002
@@ -1132,7 +1132,7 @@
 
 	state = info->state;
 
-	DPRINTK("uart_close() called\n");
+	DPRINTK("uart_close(%d) called\n", port->line);
 
 	/*
 	 * This is safe, as long as the BKL exists in
@@ -1990,7 +1990,7 @@
 		printk("I/O 0x%x offset 0x%x", port->iobase, port->hub6);
 		break;
 	case UPIO_MEM:
-		printk("MMIO 0x%lx", port->mapbase);
+		printk("MMIO 0x%p", port->membase);
 		break;
 	}
 	printk(" (irq = %d) is a %s\n", port->irq, uart_type(port));
diff -urN linux-2.5.45/include/asm-ia64/serial.h linux-2.5.45-hcdp/include/asm-ia64/serial.h
--- linux-2.5.45/include/asm-ia64/serial.h	Wed Oct 30 17:42:54 2002
+++ linux-2.5.45-hcdp/include/asm-ia64/serial.h	Wed Nov 13 16:01:37 2002
@@ -59,6 +59,11 @@
 	{ 0, BASE_BAUD, 0x3E8, 4, STD_COM_FLAGS },	/* ttyS2 */	\
 	{ 0, BASE_BAUD, 0x2E8, 3, STD_COM4_FLAGS },	/* ttyS3 */
 
+/*
+ * placeholder for HCDP described serial console port
+ */
+#define HCDP_SERIAL_PORT_DEFNS			\
+	{0, BASE_BAUD, -1, 0, STD_COM_FLAGS, 0, UPIO_MEM, -1, 0},
 
 #ifdef CONFIG_SERIAL_MANY_PORTS
 #define EXTRA_SERIAL_PORT_DEFNS			\
@@ -117,6 +122,7 @@
 
 #define SERIAL_PORT_DFNS		\
 	STD_SERIAL_PORT_DEFNS		\
+	HCDP_SERIAL_PORT_DEFNS		\
 	EXTRA_SERIAL_PORT_DEFNS		\
 	HUB6_SERIAL_PORT_DFNS
 
diff -urN linux-2.5.45/include/linux/serial.h linux-2.5.45-hcdp/include/linux/serial.h
--- linux-2.5.45/include/linux/serial.h	Wed Nov 13 16:56:55 2002
+++ linux-2.5.45-hcdp/include/linux/serial.h	Wed Nov 13 16:01:37 2002
@@ -182,14 +182,5 @@
 struct uart_port;	/* forward declaration */
 extern int early_register_port(struct uart_port *port);
 
-#ifdef CONFIG_ACPI
-/* tty ports reserved for the ACPI serial console port and debug port */
-#define ACPI_SERIAL_CONSOLE_PORT        0
-#define ACPI_SERIAL_DEBUG_PORT          5
-#endif
-
-/* tty port reserved for the HCDP serial console port */
-#define HCDP_SERIAL_CONSOLE_PORT	4
-
 #endif /* __KERNEL__ */
 #endif /* _LINUX_SERIAL_H */

--------------42D6CD343E791A73D272F4A9--


