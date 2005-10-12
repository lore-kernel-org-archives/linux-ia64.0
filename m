From: Mark Maule <maule@sgi.com>
Date: Wed, 12 Oct 2005 18:55:02 +0000
Subject: Re: [PATCH] set altix preferred console
Message-Id: <20051012185502.GJ14350@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050930200422.GD13855@sgi.com>
In-Reply-To: <20050930200422.GD13855@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

New version of Greg's original patch per review comments from Bjorn:


Fix default VGA console on SN platforms.  Since SN firmware does not pass
enough ACPI information to identify VGA cards and the associated legacy IO/MEM
addresses, we rely on the EFI PCDP table.  Since the linux pcdp driver is
optional (and overridden if console= directives are used) SN duplicates a
portion of the pcdp scan code to identify if there is a usable console VGA
adapter.

To avoid also dup'ing PCDP structures, drivers/firmware/pcdp.h is moved to
include/linux/pcdp.h.

Signed-off-by: Mark Maule <maule@sgi.com>

Index: vga/arch/ia64/sn/kernel/setup.c
=================================--- vga.orig/arch/ia64/sn/kernel/setup.c	2005-10-12 10:36:40.914797412 -0500
+++ vga/arch/ia64/sn/kernel/setup.c	2005-10-12 11:50:44.543433497 -0500
@@ -30,6 +30,8 @@
 #include <linux/root_dev.h>
 #include <linux/nodemask.h>
 #include <linux/pm.h>
+#include <linux/efi.h>
+#include <linux/pcdp.h>
 
 #include <asm/io.h>
 #include <asm/sal.h>
@@ -242,6 +244,48 @@
 	}
 }
 
+static void
+sn_scan_pcdp(void)
+{
+	u8 *bp;
+	struct pcdp *pcdp;
+	struct pcdp_device device;
+	struct pcdp_if_pci if_pci;
+	extern struct efi efi;
+
+	pcdp = efi.hcdp;
+	if (! pcdp)
+		return;		/* no hcdp/pcdp table */
+
+	if (pcdp->rev < 3)
+		return;		/* only support PCDP (rev >= 3) */
+
+	for (bp = (u8 *)&pcdp->uart[pcdp->num_uarts];
+	     bp < (u8 *)pcdp + pcdp->length;
+	     bp += device.length) {
+		memcpy(&device, bp, sizeof(device));
+		if (! (device.flags & PCDP_PRIMARY_CONSOLE))
+			continue;	/* not primary console */
+
+		if (device.type != PCDP_CONSOLE_VGA)
+			continue;	/* not VGA descriptor */
+
+		memcpy(&if_pci, bp+sizeof(device), sizeof(if_pci));
+		if (if_pci.interconnect != PCDP_IF_PCI)
+			continue;	/* not PCI interconnect */
+
+		if (if_pci.trans & PCDP_PCI_TRANS_IOPORT)
+			vga_console_iobase +				if_pci.ioport_tra | __IA64_UNCACHED_OFFSET;
+
+		if (if_pci.trans & PCDP_PCI_TRANS_MMIO)
+			vga_console_membase +				if_pci.mmio_tra | __IA64_UNCACHED_OFFSET;
+
+		break; /* once we find the primary, we're done */
+	}
+}
+
 /**
  * sn_setup - SN platform setup routine
  * @cmdline_p: kernel command line
@@ -263,16 +307,35 @@
 
 #if defined(CONFIG_VT) && defined(CONFIG_VGA_CONSOLE)
 	/*
-	 * If there was a primary vga adapter identified through the
-	 * EFI PCDP table, make it the preferred console.  Otherwise
-	 * zero out conswitchp.
+	 * Handle SN vga console.
+	 *
+	 * SN systems do not have enough ACPI table information
+	 * being passed from prom to identify VGA adapters and the legacy
+	 * addresses to access them.  Until that is done, SN systems rely
+	 * on the PCDP table to identify the primary VGA console if one
+	 * exists.
+	 *
+	 * However, kernel PCDP support is optional, and even if it is built
+	 * into the kernel, it will not be used if the boot cmdline contains
+	 * console= directives.
+	 *
+	 * So, to work around this mess, we duplicate some of the PCDP code
+	 * here so that the primary VGA console (as defined by PCDP) will
+	 * work on SN systems even if a different console (e.g. serial) is
+	 * selected on the boot line (or CONFIG_EFI_PCDP is off).
 	 */
 
+	if (! vga_console_membase)
+		sn_scan_pcdp();
+
 	if (vga_console_membase) {
 		/* usable vga ... make tty0 the preferred default console */
-		add_preferred_console("tty", 0, NULL);
+		if (!strstr(*cmdline_p, "console="))
+			add_preferred_console("tty", 0, NULL);
 	} else {
 		printk(KERN_DEBUG "SGI: Disabling VGA console\n");
+		if (!strstr(*cmdline_p, "console="))
+			add_preferred_console("ttySG", 0, NULL);
 #ifdef CONFIG_DUMMY_CONSOLE
 		conswitchp = &dummy_con;
 #else
Index: vga/drivers/firmware/pcdp.c
=================================--- vga.orig/drivers/firmware/pcdp.c	2005-10-12 10:36:40.915773877 -0500
+++ vga/drivers/firmware/pcdp.c	2005-10-12 10:43:38.156192381 -0500
@@ -16,8 +16,8 @@
 #include <linux/console.h>
 #include <linux/efi.h>
 #include <linux/serial.h>
+#include <linux/pcdp.h>
 #include <asm/vga.h>
-#include "pcdp.h"
 
 static int __init
 setup_serial_console(struct pcdp_uart *uart)
Index: vga/drivers/firmware/pcdp.h
=================================--- vga.orig/drivers/firmware/pcdp.h	2005-10-12 10:36:40.914797412 -0500
+++ /dev/null	1970-01-01 00:00:00.000000000 +0000
@@ -1,111 +0,0 @@
-/*
- * Definitions for PCDP-defined console devices
- *
- * v1.0a: http://www.dig64.org/specifications/DIG64_HCDPv10a_01.pdf
- * v2.0:  http://www.dig64.org/specifications/DIG64_PCDPv20.pdf
- *
- * (c) Copyright 2002, 2004 Hewlett-Packard Development Company, L.P.
- *	Khalid Aziz <khalid.aziz@hp.com>
- *	Bjorn Helgaas <bjorn.helgaas@hp.com>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#define PCDP_CONSOLE			0
-#define PCDP_DEBUG			1
-#define PCDP_CONSOLE_OUTPUT		2
-#define PCDP_CONSOLE_INPUT		3
-
-#define PCDP_UART			(0 << 3)
-#define PCDP_VGA			(1 << 3)
-#define PCDP_USB			(2 << 3)
-
-/* pcdp_uart.type and pcdp_device.type */
-#define PCDP_CONSOLE_UART		(PCDP_UART | PCDP_CONSOLE)
-#define PCDP_DEBUG_UART			(PCDP_UART | PCDP_DEBUG)
-#define PCDP_CONSOLE_VGA		(PCDP_VGA  | PCDP_CONSOLE_OUTPUT)
-#define PCDP_CONSOLE_USB		(PCDP_USB  | PCDP_CONSOLE_INPUT)
-
-/* pcdp_uart.flags */
-#define PCDP_UART_EDGE_SENSITIVE	(1 << 0)
-#define PCDP_UART_ACTIVE_LOW		(1 << 1)
-#define PCDP_UART_PRIMARY_CONSOLE	(1 << 2)
-#define PCDP_UART_IRQ			(1 << 6) /* in pci_func for rev < 3 */
-#define PCDP_UART_PCI			(1 << 7) /* in pci_func for rev < 3 */
-
-struct pcdp_uart {
-	u8				type;
-	u8				bits;
-	u8				parity;
-	u8				stop_bits;
-	u8				pci_seg;
-	u8				pci_bus;
-	u8				pci_dev;
-	u8				pci_func;
-	u64				baud;
-	struct acpi_generic_address	addr;
-	u16				pci_dev_id;
-	u16				pci_vendor_id;
-	u32				gsi;
-	u32				clock_rate;
-	u8				pci_prog_intfc;
-	u8				flags;
-	u16				conout_index;
-	u32				reserved;
-} __attribute__((packed));
-
-#define PCDP_IF_PCI	1
-
-/* pcdp_if_pci.trans */
-#define PCDP_PCI_TRANS_IOPORT	0x02
-#define PCDP_PCI_TRANS_MMIO	0x01
-
-struct pcdp_if_pci {
-	u8			interconnect;
-	u8			reserved;
-	u16			length;
-	u8			segment;
-	u8			bus;
-	u8			dev;
-	u8			fun;
-	u16			dev_id;
-	u16			vendor_id;
-	u32			acpi_interrupt;
-	u64			mmio_tra;
-	u64			ioport_tra;
-	u8			flags;
-	u8			trans;
-} __attribute__((packed));
-
-struct pcdp_vga {
-	u8			count;		/* address space descriptors */
-} __attribute__((packed));
-
-/* pcdp_device.flags */
-#define PCDP_PRIMARY_CONSOLE	1
-
-struct pcdp_device {
-	u8			type;
-	u8			flags;
-	u16			length;
-	u16			efi_index;
-	/* next data is pcdp_if_pci or pcdp_if_acpi (not yet supported) */
-	/* next data is device specific type (currently only pcdp_vga) */
-} __attribute__((packed));
-
-struct pcdp {
-	u8			signature[4];
-	u32			length;
-	u8			rev;		/* PCDP v2.0 is rev 3 */
-	u8			chksum;
-	u8			oemid[6];
-	u8			oem_tabid[8];
-	u32			oem_rev;
-	u8			creator_id[4];
-	u32			creator_rev;
-	u32			num_uarts;
-	struct pcdp_uart	uart[0];	/* actual size is num_uarts */
-	/* remainder of table is pcdp_device structures */
-} __attribute__((packed));
Index: vga/include/linux/pcdp.h
=================================--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ vga/include/linux/pcdp.h	2005-10-12 10:43:38.172792280 -0500
@@ -0,0 +1,111 @@
+/*
+ * Definitions for PCDP-defined console devices
+ *
+ * v1.0a: http://www.dig64.org/specifications/DIG64_HCDPv10a_01.pdf
+ * v2.0:  http://www.dig64.org/specifications/DIG64_PCDPv20.pdf
+ *
+ * (c) Copyright 2002, 2004 Hewlett-Packard Development Company, L.P.
+ *	Khalid Aziz <khalid.aziz@hp.com>
+ *	Bjorn Helgaas <bjorn.helgaas@hp.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#define PCDP_CONSOLE			0
+#define PCDP_DEBUG			1
+#define PCDP_CONSOLE_OUTPUT		2
+#define PCDP_CONSOLE_INPUT		3
+
+#define PCDP_UART			(0 << 3)
+#define PCDP_VGA			(1 << 3)
+#define PCDP_USB			(2 << 3)
+
+/* pcdp_uart.type and pcdp_device.type */
+#define PCDP_CONSOLE_UART		(PCDP_UART | PCDP_CONSOLE)
+#define PCDP_DEBUG_UART			(PCDP_UART | PCDP_DEBUG)
+#define PCDP_CONSOLE_VGA		(PCDP_VGA  | PCDP_CONSOLE_OUTPUT)
+#define PCDP_CONSOLE_USB		(PCDP_USB  | PCDP_CONSOLE_INPUT)
+
+/* pcdp_uart.flags */
+#define PCDP_UART_EDGE_SENSITIVE	(1 << 0)
+#define PCDP_UART_ACTIVE_LOW		(1 << 1)
+#define PCDP_UART_PRIMARY_CONSOLE	(1 << 2)
+#define PCDP_UART_IRQ			(1 << 6) /* in pci_func for rev < 3 */
+#define PCDP_UART_PCI			(1 << 7) /* in pci_func for rev < 3 */
+
+struct pcdp_uart {
+	u8				type;
+	u8				bits;
+	u8				parity;
+	u8				stop_bits;
+	u8				pci_seg;
+	u8				pci_bus;
+	u8				pci_dev;
+	u8				pci_func;
+	u64				baud;
+	struct acpi_generic_address	addr;
+	u16				pci_dev_id;
+	u16				pci_vendor_id;
+	u32				gsi;
+	u32				clock_rate;
+	u8				pci_prog_intfc;
+	u8				flags;
+	u16				conout_index;
+	u32				reserved;
+} __attribute__((packed));
+
+#define PCDP_IF_PCI	1
+
+/* pcdp_if_pci.trans */
+#define PCDP_PCI_TRANS_IOPORT	0x02
+#define PCDP_PCI_TRANS_MMIO	0x01
+
+struct pcdp_if_pci {
+	u8			interconnect;
+	u8			reserved;
+	u16			length;
+	u8			segment;
+	u8			bus;
+	u8			dev;
+	u8			fun;
+	u16			dev_id;
+	u16			vendor_id;
+	u32			acpi_interrupt;
+	u64			mmio_tra;
+	u64			ioport_tra;
+	u8			flags;
+	u8			trans;
+} __attribute__((packed));
+
+struct pcdp_vga {
+	u8			count;		/* address space descriptors */
+} __attribute__((packed));
+
+/* pcdp_device.flags */
+#define PCDP_PRIMARY_CONSOLE	1
+
+struct pcdp_device {
+	u8			type;
+	u8			flags;
+	u16			length;
+	u16			efi_index;
+	/* next data is pcdp_if_pci or pcdp_if_acpi (not yet supported) */
+	/* next data is device specific type (currently only pcdp_vga) */
+} __attribute__((packed));
+
+struct pcdp {
+	u8			signature[4];
+	u32			length;
+	u8			rev;		/* PCDP v2.0 is rev 3 */
+	u8			chksum;
+	u8			oemid[6];
+	u8			oem_tabid[8];
+	u32			oem_rev;
+	u8			creator_id[4];
+	u32			creator_rev;
+	u32			num_uarts;
+	struct pcdp_uart	uart[0];	/* actual size is num_uarts */
+	/* remainder of table is pcdp_device structures */
+} __attribute__((packed));
