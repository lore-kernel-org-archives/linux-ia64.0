From: Mark Maule <maule@sgi.com>
Date: Mon, 25 Apr 2005 20:51:25 +0000
Subject: [PATCH 2.6.12 1/1] pcdp: add PCDP pci interface support
Message-Id: <20050425205125.4214.56215.sendpatchset@attica.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050421202619.31042.93421.39277@attica.americas.sgi.com>
In-Reply-To: <20050421202619.31042.93421.39277@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Resend 2 with changes per Bjorn Helgaas comments.  Changes from original:

+ Change globals to vga_console_iobase/vga_console_membase and make them
  unconditional.
+ Address style-related comments.

Patch to extend the PCDP vga setup code to support PCI io/mem translations
for the legacy vga ioport and ram spaces on architectures (e.g. altix) which
need them.  Diffs were generated against the last available ia64 bk test tree.

Summary of the changes:

drivers/firmware/pcdp.c
drivers/firmware/pcdp.h
-----------------------
+ add declaration for the spec-defined PCI interface struct (pcdp_if_pci)
  as well as support macros.

+ extend setup_vga_console() to know about pcdp_if_pci and add a couple of
  globals to hold the io and mem translation offsets if present.

arch/ia64/kernel/setup.c
------------------------
+ tweek early_console_setup() to allow multiple early console setup routines
  to be called.

include/asm-ia64/vga.h
----------------------
+ make VGA_MAP_MEM vga_console_membase asware

Signed-off-by: Mark Maule <maule@sgi.com>

diff -Nru a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
--- a/arch/ia64/kernel/setup.c	2005-04-25 15:47:41 -05:00
+++ b/arch/ia64/kernel/setup.c	2005-04-25 15:47:41 -05:00
@@ -72,6 +72,8 @@
 unsigned long ia64_cycles_per_usec;
 struct ia64_boot_param *ia64_boot_param;
 struct screen_info screen_info;
+unsigned long vga_console_iobase;
+unsigned long vga_console_membase;
 
 unsigned long ia64_max_cacheline_size;
 unsigned long ia64_iobase;	/* virtual address for I/O accesses */
@@ -273,23 +275,25 @@
 static inline int __init
 early_console_setup (char *cmdline)
 {
+	int earlycons = 0;
+
 #ifdef CONFIG_SERIAL_SGI_L1_CONSOLE
 	{
 		extern int sn_serial_console_early_setup(void);
 		if (!sn_serial_console_early_setup())
-			return 0;
+			earlycons++;
 	}
 #endif
 #ifdef CONFIG_EFI_PCDP
 	if (!efi_setup_pcdp_console(cmdline))
-		return 0;
+		earlycons++;
 #endif
 #ifdef CONFIG_SERIAL_8250_CONSOLE
 	if (!early_serial_console_init(cmdline))
-		return 0;
+		earlycons++;
 #endif
 
-	return -1;
+	return (earlycons) ? 0 : -1;
 }
 
 static inline void
diff -Nru a/drivers/firmware/pcdp.c b/drivers/firmware/pcdp.c
--- a/drivers/firmware/pcdp.c	2005-04-25 15:47:41 -05:00
+++ b/drivers/firmware/pcdp.c	2005-04-25 15:47:41 -05:00
@@ -15,6 +15,7 @@
 #include <linux/console.h>
 #include <linux/efi.h>
 #include <linux/serial.h>
+#include <asm/vga.h>
 #include "pcdp.h"
 
 static int __init
@@ -36,10 +37,27 @@
 }
 
 static int __init
-setup_vga_console(struct pcdp_vga *vga)
+setup_vga_console(struct pcdp_device *dev)
 {
 #if defined(CONFIG_VT) && defined(CONFIG_VGA_CONSOLE)
-	if (efi_mem_type(0xA0000) = EFI_CONVENTIONAL_MEMORY) {
+	u8 *if_ptr;
+
+	if_ptr = ((u8 *)dev + sizeof(struct pcdp_device));
+	if (if_ptr[0] = PCDP_IF_PCI) {
+		struct pcdp_if_pci if_pci;
+
+		/* struct copy since ifptr might not be correctly aligned */
+
+		memcpy(&if_pci, if_ptr, sizeof(if_pci));
+
+		if (if_pci.trans & PCDP_PCI_TRANS_IOPORT)
+			vga_console_iobase = if_pci.ioport_tra;
+
+		if (if_pci.trans & PCDP_PCI_TRANS_MMIO)
+			vga_console_membase = if_pci.mmio_tra;
+	}
+
+	if (efi_mem_type(vga_console_membase + 0xA0000) = EFI_CONVENTIONAL_MEMORY) {
 		printk(KERN_ERR "PCDP: VGA selected, but frame buffer is not MMIO!\n");
 		return -ENODEV;
 	}
@@ -91,7 +109,7 @@
 	     dev = (struct pcdp_device *) ((u8 *) dev + dev->length)) {
 		if (dev->flags & PCDP_PRIMARY_CONSOLE) {
 			if (dev->type = PCDP_CONSOLE_VGA) {
-				return setup_vga_console((struct pcdp_vga *) dev);
+				return setup_vga_console(dev);
 			}
 		}
 	}
diff -Nru a/drivers/firmware/pcdp.h b/drivers/firmware/pcdp.h
--- a/drivers/firmware/pcdp.h	2005-04-25 15:47:41 -05:00
+++ b/drivers/firmware/pcdp.h	2005-04-25 15:47:41 -05:00
@@ -52,11 +52,34 @@
 	u32				clock_rate;
 	u8				pci_prog_intfc;
 	u8				flags;
-};
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
 
 struct pcdp_vga {
 	u8			count;		/* address space descriptors */
-};
+} __attribute__((packed));
 
 /* pcdp_device.flags */
 #define PCDP_PRIMARY_CONSOLE	1
@@ -66,7 +89,9 @@
 	u8			flags;
 	u16			length;
 	u16			efi_index;
-};
+	/* next data is pcdp_if_pci or pcdp_if_acpi (not yet supported) */
+	/* next data is device specific type (currently only pcdp_vga) */
+} __attribute__((packed));
 
 struct pcdp {
 	u8			signature[4];
@@ -81,4 +106,4 @@
 	u32			num_uarts;
 	struct pcdp_uart	uart[0];	/* actual size is num_uarts */
 	/* remainder of table is pcdp_device structures */
-};
+} __attribute__((packed));
diff -Nru a/include/asm-ia64/vga.h b/include/asm-ia64/vga.h
--- a/include/asm-ia64/vga.h	2005-04-25 15:47:41 -05:00
+++ b/include/asm-ia64/vga.h	2005-04-25 15:47:41 -05:00
@@ -14,7 +14,10 @@
  * videoram directly without any black magic.
  */
 
-#define VGA_MAP_MEM(x)	((unsigned long) ioremap((x), 0))
+extern unsigned long vga_console_iobase;
+extern unsigned long vga_console_membase;
+
+#define VGA_MAP_MEM(x)	((unsigned long) ioremap(vga_console_membase + (x), 0))
 
 #define vga_readb(x)	(*(x))
 #define vga_writeb(x,y)	(*(y) = (x))
