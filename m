From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 15 Oct 2003 16:54:36 +0000
Subject: [PATCH] fix serial port naming
Message-Id: <marc-linux-ia64-106623720527866@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Now that the serial driver fully supports discovery via ACPI,
we can get rid of all the legacy junk in asm-ia64/serial.h.
This keeps the serial driver from blindly probing I/O port
space.

This also fixes a long-standing serial device naming issue:
ttyS0-ttyS3 were always reserved for the compiled-in
COM ports, even if they weren't present in the box.
Any additional PCI or ACPI ports appeared starting at
ttyS4 (except for the special case of things described
in the HCDP).   Now we'll just name ttyS devices in the
order they're discovered, without any holes for non-existent
devices.

This is a little bit ugly for serial console because the HCDP
is currently the only way we learn about serial ports before
the actual ACPI discovery.  All HP firmware implements HCDP,
but Intel firmware does not.  So in the absence of an HCDP,
we have to probe for legacy COM ports.  Otherwise, the serial
console wouldn't work until the serial driver discovers the
port via ACPI.

=== arch/ia64/kernel/acpi.c 1.52 vs edited ==--- 1.52/arch/ia64/kernel/acpi.c	Sun Oct  5 02:07:48 2003
+++ edited/arch/ia64/kernel/acpi.c	Wed Oct  8 13:16:20 2003
@@ -56,6 +56,7 @@
 void (*pm_power_off) (void);
 
 unsigned char acpi_kbd_controller_present = 1;
+unsigned char acpi_legacy_devices;
 
 int acpi_disabled;	/* XXX this shouldn't be needed---we can't boot without ACPI! */
 
@@ -530,6 +531,9 @@
 
 	if (!(fadt->iapc_boot_arch & BAF_8042_KEYBOARD_CONTROLLER))
 		acpi_kbd_controller_present = 0;
+
+	if (fadt->iapc_boot_arch & BAF_LEGACY_DEVICES)
+		acpi_legacy_devices = 1;
 
 	acpi_register_irq(fadt->sci_int, ACPI_ACTIVE_LOW, ACPI_LEVEL_SENSITIVE);
 	return 0;
=== arch/ia64/kernel/setup.c 1.59 vs edited ==--- 1.59/arch/ia64/kernel/setup.c	Tue Sep 23 14:47:37 2003
+++ edited/arch/ia64/kernel/setup.c	Wed Oct  8 13:24:12 2003
@@ -30,6 +30,8 @@
 #include <linux/string.h>
 #include <linux/threads.h>
 #include <linux/tty.h>
+#include <linux/serial.h>
+#include <linux/serial_core.h>
 #include <linux/efi.h>
 #include <linux/initrd.h>
 
@@ -43,6 +45,7 @@
 #include <asm/processor.h>
 #include <asm/sal.h>
 #include <asm/sections.h>
+#include <asm/serial.h>
 #include <asm/smp.h>
 #include <asm/system.h>
 #include <asm/unistd.h>
@@ -225,6 +228,25 @@
 #endif
 }
 
+#ifdef CONFIG_SERIAL_8250_CONSOLE
+static void __init
+setup_serial_legacy (void)
+{
+	struct uart_port port;
+	unsigned int i, iobase[] = {0x3f8, 0x2f8};
+
+	printk(KERN_INFO "Registering legacy COM ports for serial console\n");
+	memset(&port, 0, sizeof(port));
+	port.iotype = SERIAL_IO_PORT;
+	port.uartclk = BASE_BAUD * 16;
+	for (i = 0; i < ARRAY_SIZE(iobase); i++) {
+		port.line = i;
+		port.iobase = iobase[i];
+		early_serial_setup(&port);
+	}
+}
+#endif
+
 void __init
 setup_arch (char **cmdline_p)
 {
@@ -297,11 +319,22 @@
 #ifdef CONFIG_SERIAL_8250_HCDP
 	if (efi.hcdp) {
 		void setup_serial_hcdp(void *);
-
-		/* Setup the serial ports described by HCDP */
 		setup_serial_hcdp(efi.hcdp);
 	}
 #endif
+#ifdef CONFIG_SERIAL_8250_CONSOLE
+	/*
+	 * Without HCDP, we won't discover any serial ports until the serial driver looks
+	 * in the ACPI namespace.  If ACPI claims there are some legacy devices, register
+	 * the legacy COM ports so serial console works earlier.  This is slightly dangerous
+	 * because we don't *really* know whether there's anything there, but we hope that
+	 * all new boxes will implement HCDP.
+	 */
+	extern unsigned char acpi_legacy_devices;
+	if (!efi.hcdp && acpi_legacy_devices)
+		setup_serial_legacy();
+#endif
+
 #ifdef CONFIG_VT
 # if defined(CONFIG_DUMMY_CONSOLE)
 	conswitchp = &dummy_con;
=== include/asm-ia64/serial.h 1.3 vs edited ==--- 1.3/include/asm-ia64/serial.h	Wed Apr  9 16:35:27 2003
+++ edited/include/asm-ia64/serial.h	Wed Oct  8 13:16:20 2003
@@ -4,8 +4,6 @@
  * Derived from the i386 version.
  */
 
-#include <linux/config.h>
-
 /*
  * This assumes you have a 1.8432 MHz clock for your UART.
  *
@@ -15,107 +13,7 @@
  */
 #define BASE_BAUD ( 1843200 / 16 )
 
-#define CONFIG_SERIAL_DETECT_IRQ	/* on IA-64, we always want to autodetect irqs */
-
-/* Standard COM flags (except for COM4, because of the 8514 problem) */
-#ifdef CONFIG_SERIAL_DETECT_IRQ
-#define STD_COM_FLAGS (ASYNC_BOOT_AUTOCONF | ASYNC_SKIP_TEST | ASYNC_AUTO_IRQ)
-#define STD_COM4_FLAGS (ASYNC_BOOT_AUTOCONF | ASYNC_AUTO_IRQ)
-#else
-#define STD_COM_FLAGS (ASYNC_BOOT_AUTOCONF | ASYNC_SKIP_TEST)
-#define STD_COM4_FLAGS ASYNC_BOOT_AUTOCONF
-#endif
-
-#ifdef CONFIG_SERIAL_MANY_PORTS
-#define FOURPORT_FLAGS ASYNC_FOURPORT
-#define ACCENT_FLAGS 0
-#define BOCA_FLAGS 0
-#define HUB6_FLAGS 0
-#define RS_TABLE_SIZE	64
-#else
-#define RS_TABLE_SIZE
-#endif
-
 /*
- * The following define the access methods for the HUB6 card. All
- * access is through two ports for all 24 possible chips. The card is
- * selected through the high 2 bits, the port on that card with the
- * "middle" 3 bits, and the register on that port with the bottom
- * 3 bits.
- *
- * While the access port and interrupt is configurable, the default
- * port locations are 0x302 for the port control register, and 0x303
- * for the data read/write register. Normally, the interrupt is at irq3
- * but can be anything from 3 to 7 inclusive. Note that using 3 will
- * require disabling com2.
- */
-
-#define C_P(card,port) (((card)<<6|(port)<<3) + 1)
-
-#define STD_SERIAL_PORT_DEFNS			\
-	/* UART CLK   PORT IRQ     FLAGS        */			\
-	{ 0, BASE_BAUD, 0x3F8, 4, STD_COM_FLAGS },	/* ttyS0 */	\
-	{ 0, BASE_BAUD, 0x2F8, 3, STD_COM_FLAGS },	/* ttyS1 */	\
-	{ 0, BASE_BAUD, 0x3E8, 4, STD_COM_FLAGS },	/* ttyS2 */	\
-	{ 0, BASE_BAUD, 0x2E8, 3, STD_COM4_FLAGS },	/* ttyS3 */
-
-#ifdef CONFIG_SERIAL_MANY_PORTS
-#define EXTRA_SERIAL_PORT_DEFNS			\
-	{ 0, BASE_BAUD, 0x1A0, 9, FOURPORT_FLAGS }, 	/* ttyS4 */	\
-	{ 0, BASE_BAUD, 0x1A8, 9, FOURPORT_FLAGS },	/* ttyS5 */	\
-	{ 0, BASE_BAUD, 0x1B0, 9, FOURPORT_FLAGS },	/* ttyS6 */	\
-	{ 0, BASE_BAUD, 0x1B8, 9, FOURPORT_FLAGS },	/* ttyS7 */	\
-	{ 0, BASE_BAUD, 0x2A0, 5, FOURPORT_FLAGS },	/* ttyS8 */	\
-	{ 0, BASE_BAUD, 0x2A8, 5, FOURPORT_FLAGS },	/* ttyS9 */	\
-	{ 0, BASE_BAUD, 0x2B0, 5, FOURPORT_FLAGS },	/* ttyS10 */	\
-	{ 0, BASE_BAUD, 0x2B8, 5, FOURPORT_FLAGS },	/* ttyS11 */	\
-	{ 0, BASE_BAUD, 0x330, 4, ACCENT_FLAGS },	/* ttyS12 */	\
-	{ 0, BASE_BAUD, 0x338, 4, ACCENT_FLAGS },	/* ttyS13 */	\
-	{ 0, BASE_BAUD, 0x000, 0, 0 },	/* ttyS14 (spare) */		\
-	{ 0, BASE_BAUD, 0x000, 0, 0 },	/* ttyS15 (spare) */		\
-	{ 0, BASE_BAUD, 0x100, 12, BOCA_FLAGS },	/* ttyS16 */	\
-	{ 0, BASE_BAUD, 0x108, 12, BOCA_FLAGS },	/* ttyS17 */	\
-	{ 0, BASE_BAUD, 0x110, 12, BOCA_FLAGS },	/* ttyS18 */	\
-	{ 0, BASE_BAUD, 0x118, 12, BOCA_FLAGS },	/* ttyS19 */	\
-	{ 0, BASE_BAUD, 0x120, 12, BOCA_FLAGS },	/* ttyS20 */	\
-	{ 0, BASE_BAUD, 0x128, 12, BOCA_FLAGS },	/* ttyS21 */	\
-	{ 0, BASE_BAUD, 0x130, 12, BOCA_FLAGS },	/* ttyS22 */	\
-	{ 0, BASE_BAUD, 0x138, 12, BOCA_FLAGS },	/* ttyS23 */	\
-	{ 0, BASE_BAUD, 0x140, 12, BOCA_FLAGS },	/* ttyS24 */	\
-	{ 0, BASE_BAUD, 0x148, 12, BOCA_FLAGS },	/* ttyS25 */	\
-	{ 0, BASE_BAUD, 0x150, 12, BOCA_FLAGS },	/* ttyS26 */	\
-	{ 0, BASE_BAUD, 0x158, 12, BOCA_FLAGS },	/* ttyS27 */	\
-	{ 0, BASE_BAUD, 0x160, 12, BOCA_FLAGS },	/* ttyS28 */	\
-	{ 0, BASE_BAUD, 0x168, 12, BOCA_FLAGS },	/* ttyS29 */	\
-	{ 0, BASE_BAUD, 0x170, 12, BOCA_FLAGS },	/* ttyS30 */	\
-	{ 0, BASE_BAUD, 0x178, 12, BOCA_FLAGS },	/* ttyS31 */
-#else
-#define EXTRA_SERIAL_PORT_DEFNS
-#endif
-
-/* You can have up to four HUB6's in the system, but I've only
- * included two cards here for a total of twelve ports.
+ * All legacy serial ports should be enumerated via ACPI namespace, so
+ * we need not list them here.
  */
-#if (defined(CONFIG_HUB6) && defined(CONFIG_SERIAL_MANY_PORTS))
-#define HUB6_SERIAL_PORT_DFNS		\
-	{ 0, BASE_BAUD, 0x302, 3, HUB6_FLAGS, C_P(0,0) },  /* ttyS32 */	\
-	{ 0, BASE_BAUD, 0x302, 3, HUB6_FLAGS, C_P(0,1) },  /* ttyS33 */	\
-	{ 0, BASE_BAUD, 0x302, 3, HUB6_FLAGS, C_P(0,2) },  /* ttyS34 */	\
-	{ 0, BASE_BAUD, 0x302, 3, HUB6_FLAGS, C_P(0,3) },  /* ttyS35 */	\
-	{ 0, BASE_BAUD, 0x302, 3, HUB6_FLAGS, C_P(0,4) },  /* ttyS36 */	\
-	{ 0, BASE_BAUD, 0x302, 3, HUB6_FLAGS, C_P(0,5) },  /* ttyS37 */	\
-	{ 0, BASE_BAUD, 0x302, 3, HUB6_FLAGS, C_P(1,0) },  /* ttyS38 */	\
-	{ 0, BASE_BAUD, 0x302, 3, HUB6_FLAGS, C_P(1,1) },  /* ttyS39 */	\
-	{ 0, BASE_BAUD, 0x302, 3, HUB6_FLAGS, C_P(1,2) },  /* ttyS40 */	\
-	{ 0, BASE_BAUD, 0x302, 3, HUB6_FLAGS, C_P(1,3) },  /* ttyS41 */	\
-	{ 0, BASE_BAUD, 0x302, 3, HUB6_FLAGS, C_P(1,4) },  /* ttyS42 */	\
-	{ 0, BASE_BAUD, 0x302, 3, HUB6_FLAGS, C_P(1,5) },  /* ttyS43 */
-#else
-#define HUB6_SERIAL_PORT_DFNS
-#endif
-
-#define SERIAL_PORT_DFNS		\
-	STD_SERIAL_PORT_DEFNS		\
-	EXTRA_SERIAL_PORT_DEFNS		\
-	HUB6_SERIAL_PORT_DFNS
-

