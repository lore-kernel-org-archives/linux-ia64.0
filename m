From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 17 Mar 2004 20:44:39 +0000
Subject: [RFC] early serial console support
Message-Id: <200403171344.39614.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Here's the console work I mentioned earlier.  I don't mean for
this to be applied quite yet; I'd just like some feedback.

My goal is to remove the need for "console=" when booting the
kernel.  We can't do this quite yet because firmware doesn't
tell us whether the user wants VGA or serial console, but I
think that hook is coming.

The core of the change is to remove the usage of early_serial_setup().

early_serial_setup() tells the serial core about a specific UART,
so the console can work early, but unfortunately you also have to
tell it which ttyS<N> the UART should be.  That screws up ttyS
device naming, because we just don't know which ttyS<N> to use.

So instead of early_serial_setup(), I added an early_serial_init()
that registers an early console but doesn't use the "ttyS" name
space.  I also added an early_serial_switch() so we can switch
transparently to the normal serial driver after it's initialized.

The net result after applying this patch:

  - /dev/ttyS<N> naming stays the same, regardless of which port
    is selected as the console in EFI.

  - You can still use "console=ttyS0,115200", but the console
    doesn't start working until after the serial driver initializes.

    Note that if the console is an MP port, it may now be named
    /dev/ttyS2 or something instead of ttyS0.

    As before, you must specify the baud rate unless it is 9600.

  - You can use "console=serial", and the console will start working
    early in setup_arch(), basically the same place early_printk
    on i386 and x86_64 starts working.

    If you have an HCDP, the first port listed in it will be used as
    the console, and the HCDP tells us the baud rate.

    If you don't have an HCDP (i.e., HP i2000 or non-HP box), the
    console is assumed to be COM1 (I/O port 0x3f8), and we peek at
    the UART to figure out the baud rate automatically.

  - If "console=serial" is supplied, when we figure out which ttyS<N>
    device is really the console, we stick "console=ttyS<N>,<baud>"
    in /proc/cmdline so userspace can figure out where to run a getty.
    This is kind of ugly, but I don't know a cleaner way.

  - Note that this doesn't support input, which KDB might care about.
    It should be easy to add, though.


 arch/ia64/kernel/setup.c    |   89 ++++++++++++--------------
 drivers/serial/8250.c       |   37 +++++++++++
 drivers/serial/8250.h       |    3 
 drivers/serial/8250_early.c |  146 ++++++++++++++++++++++++++++++++++++++++++++
 drivers/serial/8250_hcdp.c  |   35 +++-------
 drivers/serial/Makefile     |    2 
 include/linux/serial.h      |    1 
 7 files changed, 240 insertions(+), 73 deletions(-)

diff -Nru a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
--- a/arch/ia64/kernel/setup.c	2004-03-17 12:46:59.000000000 -0700
+++ b/arch/ia64/kernel/setup.c	2004-03-17 11:45:03.000000000 -0700
@@ -35,6 +35,7 @@
 #include <linux/serial_core.h>
 #include <linux/efi.h>
 #include <linux/initrd.h>
+#include <linux/string.h>
 
 #include <asm/ia32.h>
 #include <asm/machvec.h>
@@ -261,25 +262,51 @@
 	num_io_spaces = 1;
 }
 
-#ifdef CONFIG_SERIAL_8250_CONSOLE
 static void __init
-setup_serial_legacy (void)
+early_console_init (void)
 {
+#ifdef CONFIG_SERIAL_8250_CONSOLE
 	struct uart_port port;
-	unsigned int i, iobase[] = {0x3f8, 0x2f8};
 
-	printk(KERN_INFO "Registering legacy COM ports for serial console\n");
-	memset(&port, 0, sizeof(port));
-	port.iotype = SERIAL_IO_PORT;
-	port.uartclk = BASE_BAUD * 16;
-	for (i = 0; i < ARRAY_SIZE(iobase); i++) {
-		port.line = i;
-		port.iobase = iobase[i];
-		early_serial_setup(&port);
+	if (strstr(saved_command_line, "console=serial")) {
+#ifdef CONFIG_SERIAL_8250_HCDP
+		if (efi.hcdp) {
+			void setup_serial_hcdp(void *);
+			setup_serial_hcdp(efi.hcdp);
+		}
+#endif
+		/*
+		 * Without HCDP, we won't discover any serial ports until the serial
+		 * driver looks in the ACPI namespace, so if the user requested a serial
+		 * console, we have to assume it's at 0x3f8.
+		 */
+		if (!efi.hcdp) {
+			printk(KERN_INFO "Registering legacy COM1 (I/O port 0x3f8) for serial console\n");
+			memset(&port, 0, sizeof(port));
+			port.iotype = SERIAL_IO_PORT;
+			port.iobase = 0x3f8;
+			early_serial_init(&port, NULL);
+		}
 	}
-}
 #endif
 
+#ifdef CONFIG_VT
+# if defined(CONFIG_DUMMY_CONSOLE)
+	conswitchp = &dummy_con;
+# endif
+# if defined(CONFIG_VGA_CONSOLE)
+	/*
+	 * Non-legacy systems may route legacy VGA MMIO range to system
+	 * memory.  vga_con probes the MMIO hole, so memory looks like
+	 * a VGA device to it.  The EFI memory map can tell us if it's
+	 * memory so we can avoid this problem.
+	 */
+	if (efi_mem_type(0xA0000) != EFI_CONVENTIONAL_MEMORY)
+		conswitchp = &vga_con;
+# endif
+#endif
+}
+
 void __init
 setup_arch (char **cmdline_p)
 {
@@ -297,6 +324,8 @@
 	machvec_init(acpi_get_sysname());
 #endif
 
+	early_console_init();
+
 #ifdef CONFIG_ACPI_BOOT
 	/* Initialize the ACPI boot-time table parser */
 	acpi_table_init();
@@ -323,42 +352,6 @@
 #ifdef CONFIG_ACPI_BOOT
 	acpi_boot_init();
 #endif
-#ifdef CONFIG_SERIAL_8250_CONSOLE
-#ifdef CONFIG_SERIAL_8250_HCDP
-	if (efi.hcdp) {
-		void setup_serial_hcdp(void *);
-		setup_serial_hcdp(efi.hcdp);
-	}
-#endif
-	/*
-	 * Without HCDP, we won't discover any serial ports until the serial driver looks
-	 * in the ACPI namespace.  If ACPI claims there are some legacy devices, register
-	 * the legacy COM ports so serial console works earlier.  This is slightly dangerous
-	 * because we don't *really* know whether there's anything there, but we hope that
-	 * all new boxes will implement HCDP.
-	 */
-	{
-		extern unsigned char acpi_legacy_devices;
-		if (!efi.hcdp && acpi_legacy_devices)
-			setup_serial_legacy();
-	}
-#endif
-
-#ifdef CONFIG_VT
-# if defined(CONFIG_DUMMY_CONSOLE)
-	conswitchp = &dummy_con;
-# endif
-# if defined(CONFIG_VGA_CONSOLE)
-	/*
-	 * Non-legacy systems may route legacy VGA MMIO range to system
-	 * memory.  vga_con probes the MMIO hole, so memory looks like
-	 * a VGA device to it.  The EFI memory map can tell us if it's
-	 * memory so we can avoid this problem.
-	 */
-	if (efi_mem_type(0xA0000) != EFI_CONVENTIONAL_MEMORY)
-		conswitchp = &vga_con;
-# endif
-#endif
 
 	/* enable IA-64 Machine Check Abort Handling */
 	ia64_mca_init();
diff -Nru a/drivers/serial/8250.c b/drivers/serial/8250.c
--- a/drivers/serial/8250.c	Wed Mar 17 11:31:00 2004
+++ b/drivers/serial/8250.c	Wed Mar 17 11:31:00 2004
@@ -2014,6 +2014,43 @@
 }
 late_initcall(serial8250_late_console_init);
 
+/* 
+ * The device -> ttyS<N> mapping is determined when the driver claims
+ * all its devices, so unless a platform supplies SERIAL_PORT_DFNS or
+ * uses early_serial_setup(), a serial console only works after driver
+ * initialization.
+ *
+ * This interface allows platform code to discover a serial device,
+ * set up an early console on it, then transparently switch to using
+ * the normal serial console driver after it is initialized.
+ *
+ * The early console driver supplies the UART info.  If we can match
+ * it to a ttyS<N>, set it up as a console and return N (N may be
+ * exported to userland so it can figure out where to start a getty).
+ */
+int __init serial8250_start_console(struct uart_port *port, char *options)
+{
+	struct uart_port *up;
+	int i;
+
+	for (i = 0; i < UART_NR; i++) {
+		up = &serial8250_ports[i].port;
+		if (up->iotype = port->iotype &&up->iobase = port->iobase &&
+		    up->membase = port->membase) {
+			add_preferred_console("ttyS", i, options);
+			break;
+		}
+	}
+	if (i = UART_NR)
+		return -ENODEV;
+
+	if (!(serial8250_console.flags & CON_ENABLED)) {
+		serial8250_console.flags &= ~CON_PRINTBUFFER;
+		register_console(&serial8250_console);
+	}
+	return i;
+}
+
 #define SERIAL8250_CONSOLE	&serial8250_console
 #else
 #define SERIAL8250_CONSOLE	NULL
diff -Nru a/drivers/serial/8250.h b/drivers/serial/8250.h
--- a/drivers/serial/8250.h	Wed Mar 17 11:31:00 2004
+++ b/drivers/serial/8250.h	Wed Mar 17 11:31:00 2004
@@ -17,6 +17,8 @@
 
 #include <linux/config.h>
 
+struct pci_dev;
+
 struct serial8250_probe {
 	struct module	*owner;
 	int		(*pci_init_one)(struct pci_dev *dev);
@@ -29,6 +31,7 @@
 void serial8250_get_irq_map(unsigned int *map);
 void serial8250_suspend_port(int line);
 void serial8250_resume_port(int line);
+int __init serial8250_start_console(struct uart_port *port, char *options);
 
 struct old_serial_port {
 	unsigned int uart;
diff -Nru a/drivers/serial/8250_early.c b/drivers/serial/8250_early.c
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/drivers/serial/8250_early.c	Wed Mar 17 11:31:00 2004
@@ -0,0 +1,146 @@
+/*
+ * Copyright (C) 2004 Hewlett-Packard Co.
+ *	Bjorn Helgaas <bjorn.helgaas@hp.com>
+ *
+ *  Based on drivers/serial/8250.c, by Russell King, and
+ *  arch/x86_64/kernel/early_printk.c.
+ */
+
+#include <linux/console.h>
+#include <linux/init.h>
+#include <linux/tty.h>
+#include <linux/serial.h>
+#include <linux/serial_core.h>
+#include <linux/serial_reg.h>
+#include <linux/string.h>
+
+#include <asm/io.h>
+#include <asm/serial.h>
+
+#include "8250.h"
+
+static struct uart_port early_port __initdata;
+static char *early_options __initdata;
+static char early_command[32] __initdata;
+
+static u8 __init
+serial_in(struct uart_port *port, int offset)
+{
+	switch (port->iotype) {
+	case  SERIAL_IO_MEM:
+		return readb(port->membase + offset);
+	default:
+		return inb(port->iobase + offset);
+	}
+}
+
+static void __init
+serial_out(struct uart_port *port, int offset, int value)
+{
+	switch (port->iotype) {
+	case SERIAL_IO_MEM:
+		writeb(value, port->membase + offset);
+		break;
+	default:
+		outb(value, port->iobase + offset);
+	}
+}
+
+static void __init
+early_serial_putc(struct uart_port *port, char c)
+{
+	while (!(UART_LSR_TEMT & serial_in(port, UART_LSR)))
+		; /* spin */
+
+	serial_out(port, UART_TX, c);
+}
+
+static void __init
+early_serial_write(struct console *co, const char *s, unsigned count)
+{
+	struct uart_port *port = &early_port;
+
+	while (*s && count-- > 0) {
+		early_serial_putc(port, *s);
+		if (*s = '\n')
+			early_serial_putc(port, '\r');
+		s++;
+	}
+}
+
+static struct console early_serial_console __initdata = {
+	.name	= "serial",
+	.write	= early_serial_write,
+	.flags	= CON_PRINTBUFFER,
+	.index	= -1,
+};
+
+static unsigned int __init
+early_serial_probe_baud(struct uart_port *port)
+{
+	unsigned char lcr, dll, dlm;
+	unsigned int quot, baud;
+
+	lcr = serial_in(port, UART_LCR);
+	serial_out(port, UART_LCR, lcr | UART_LCR_DLAB);
+	dll = serial_in(port, UART_DLL);
+	dlm = serial_in(port, UART_DLM);
+	serial_out(port, UART_LCR, lcr);
+
+	quot = (dlm << 8) | dll;
+	baud = BASE_BAUD / quot;
+	return baud;
+}
+
+void __init
+early_serial_init(struct uart_port *port, char *options)
+{
+	unsigned int baud;
+	static char probed_options[16];
+
+	early_port = *port;
+	register_console(&early_serial_console);
+	if (options)
+		early_options = options;
+	else {
+		baud = early_serial_probe_baud(port);
+		snprintf(probed_options, sizeof(probed_options), "%u", baud);
+		early_options = probed_options;
+	}
+}
+
+static int __init
+early_serial_switch(void)
+{
+	extern char saved_command_line[];
+	int port;
+
+	if (!(early_serial_console.flags & CON_ENABLED))
+		return 0;
+
+	port = serial8250_start_console(&early_port, early_options);
+	if (port < 0) {
+		printk("%s: Can't locate tty device at %s 0x%lx\n", __FUNCTION__,
+			early_port.iotype = SERIAL_IO_MEM ? "MMIO" : "I/O port",
+			early_port.iotype = SERIAL_IO_MEM ? (unsigned long) early_port.membase : (unsigned long) early_port.iobase);
+		unregister_console(&early_serial_console);	// it's __init
+		return 0;
+	}
+
+	if (early_options)
+		snprintf(early_command, sizeof(early_command),
+			" console=ttyS%d,%s", port, early_options);
+	else
+		snprintf(early_command, sizeof(early_command),
+			" console=ttyS%d", port);
+
+	// FIXME don't overflow saved_command_line!
+	strcat(saved_command_line, early_command);
+
+	unregister_console(&early_serial_console);
+	if (early_port.iotype = SERIAL_IO_MEM)
+		iounmap(early_port.membase);
+
+	return 0;
+}
+late_initcall(early_serial_switch);
diff -Nru a/drivers/serial/8250_hcdp.c b/drivers/serial/8250_hcdp.c
--- a/drivers/serial/8250_hcdp.c	Wed Mar 17 11:31:00 2004
+++ b/drivers/serial/8250_hcdp.c	Wed Mar 17 11:31:00 2004
@@ -1,8 +1,9 @@
 /*
- * linux/drivers/char/hcdp_serial.c
+ * EFI HDCP support
  *
- * Copyright (C) 2002 Hewlett-Packard Co.
+ * Copyright (C) 2002, 2004 Hewlett-Packard Co.
  *	Khalid Aziz <khalid_aziz@hp.com>
+ *	Bjorn Helgaas <bjorn.helgaas@hp.com>
  *
  * Parse the EFI HCDP table to locate serial console and debug ports and
  * initialize them.
@@ -10,20 +11,19 @@
  * 2002/08/29 davidm	Adjust it to new 2.5 serial driver infrastructure.
  */
 
-#include <linux/config.h>
-#include <linux/kernel.h>
+#include <linux/acpi.h>
+#include <linux/console.h>
 #include <linux/efi.h>
 #include <linux/init.h>
 #include <linux/tty.h>
 #include <linux/serial.h>
 #include <linux/serial_core.h>
 #include <linux/types.h>
-#include <linux/acpi.h>
 
 #include <asm/io.h>
 #include <asm/serial.h>
-#include <asm/acpi.h>
 
+#include "8250.h"
 #include "8250_hcdp.h"
 
 #undef SERIAL_DEBUG_HCDP
@@ -36,6 +36,8 @@
  * be available for use. IA-64 kernel calls this function from setup_arch()
  * after the EFI and ACPI tables have been parsed.
  */
+static char hcdp_options[16] __initdata;
+
 void __init
 setup_serial_hcdp(void *tablep)
 {
@@ -179,24 +181,9 @@
 			printk(KERN_WARNING"warning: No support for PCI serial console\n");
 			return;
 		}
-#ifdef CONFIG_IA64
-		port.irq = acpi_register_irq(gsi, ACPI_ACTIVE_HIGH,
-				ACPI_EDGE_SENSITIVE);
-#else
-		port.irq = gsi;
-#endif
-		port.flags = UPF_SKIP_TEST | UPF_BOOT_AUTOCONF | UPF_RESOURCES;
-
-		/*
-		 * Note: the above memset() initializes port.line to 0,
-		 * so we register this port as ttyS0.
-		 */
-		if (early_serial_setup(&port) < 0) {
-			printk("setup_serial_hcdp(): early_serial_setup() "
-				"for HCDP serial console port failed. "
-				"Will try any additional consoles in HCDP.\n");
-			continue;
-		}
+		snprintf(hcdp_options, sizeof(hcdp_options),
+			"%lun%d", hcdp_dev->baud, hcdp_dev->bits ? hcdp_dev->bits : 8);
+		early_serial_init(&port, hcdp_options);
 		break;
 	}
 
diff -Nru a/drivers/serial/Makefile b/drivers/serial/Makefile
--- a/drivers/serial/Makefile	Wed Mar 17 11:31:00 2004
+++ b/drivers/serial/Makefile	Wed Mar 17 11:31:00 2004
@@ -13,7 +13,7 @@
 
 obj-$(CONFIG_SERIAL_CORE) += serial_core.o
 obj-$(CONFIG_SERIAL_21285) += 21285.o
-obj-$(CONFIG_SERIAL_8250) += 8250.o $(serial-8250-y)
+obj-$(CONFIG_SERIAL_8250) += 8250.o 8250_early.o $(serial-8250-y)
 obj-$(CONFIG_SERIAL_8250_CS) += serial_cs.o
 obj-$(CONFIG_SERIAL_8250_ACORN) += 8250_acorn.o
 obj-$(CONFIG_SERIAL_ANAKIN) += anakin.o
diff -Nru a/include/linux/serial.h b/include/linux/serial.h
--- a/include/linux/serial.h	Wed Mar 17 11:31:00 2004
+++ b/include/linux/serial.h	Wed Mar 17 11:31:00 2004
@@ -181,6 +181,7 @@
 /* Allow architectures to override entries in serial8250_ports[] at run time: */
 struct uart_port;	/* forward declaration */
 extern int early_serial_setup(struct uart_port *port);
+extern void __init early_serial_init(struct uart_port *port, char *options);
 
 #endif /* __KERNEL__ */
 #endif /* _LINUX_SERIAL_H */

