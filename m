From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 09 Jul 2002 04:14:53 +0000
Subject: [Linux-ia64] kdb serial-line support for zx1-based platforms
Message-Id: <marc-linux-ia64-105590701905742@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Keith,

Below is a small patch which adds kdb serial-line support for
zx1-based platforms.  Actually, the patch should work for any
legacy-free platform which reports serial lines via ACPI tables.
Would you mind checking it out and, if it looks OK, integrating it
with your ia64-specific kdb patch?

Thanks!

	--david

diff -urN lia64-kdb-orig/arch/ia64/kdb/kdba_io.c lia64-kdb/arch/ia64/kdb/kdba_io.c
--- lia64-kdb-orig/arch/ia64/kdb/kdba_io.c	Mon Jul  8 20:52:48 2002
+++ lia64-kdb/arch/ia64/kdb/kdba_io.c	Mon Jul  8 20:58:26 2002
@@ -47,6 +47,7 @@
 #include <linux/console.h>
 #include <linux/ctype.h>
 #include <linux/keyboard.h>
+#include <linux/serial.h>
 #include <linux/serial_reg.h>
 #include <linux/nmi.h>
 
@@ -159,7 +160,8 @@
 	return -1;
 }
 #endif
-int kdb_port;
+
+struct kdb_serial kdb_serial;
 
 /*
  * This module contains code to read characters from the keyboard or a serial
@@ -196,18 +198,34 @@
 #endif	/* KDB_BLINK_LED */
 
 #if defined(CONFIG_SERIAL_CONSOLE)
+
+static inline unsigned int
+serial_inp (struct kdb_serial *kdb_serial, unsigned long offset)
+{
+	unsigned long addr = (kdb_serial->iobase + (offset << kdb_serial->ioreg_shift));
+	unsigned int ch;
+
+	switch (kdb_serial->io_type) {
+	      case SERIAL_IO_MEM:
+		ch = readb((void *) addr);
+		break;
+	      default:
+		ch = inb(addr);
+		break;
+	}
+	return ch;
+}
+
 /* Check if there is a byte ready at the serial port */
 static int get_serial_char(void)
 {
 	unsigned char ch;
-	int status;
-#define serial_inp(info, offset) inb((info) + (offset))
 
-	if (kdb_port = 0)
+	if (kdb_serial.iobase = 0)
 		return -1;
 
-	if ((status = serial_inp(kdb_port, UART_LSR)) & UART_LSR_DR) {
-		ch = serial_inp(kdb_port, UART_RX);
+	if (serial_inp(&kdb_serial, UART_LSR) & UART_LSR_DR) {
+		ch = serial_inp(&kdb_serial, UART_RX);
 		if (ch = 0x7f)
 			ch = 8;
 		if (ch = '\t')
@@ -228,6 +246,9 @@
 #endif /* CONFIG_SERIAL_CONSOLE */
 
 #if defined(CONFIG_VT)
+
+static int kbd_exists = -1;
+
 /*
  * Check if the keyboard controller has a keypress for us.
  * Some parts (Enter Release, LED change) are still blocking polled here,
@@ -242,6 +263,17 @@
 	u_short keychar;
 	extern u_short plain_map[], shift_map[], ctrl_map[];
 
+	if (kbd_exists <= 0) {
+		if (kbd_exists = 0)
+			return -1;
+
+		if (inb(KBD_STATUS_REG) = 0xff && inb(KBD_DATA_REG) = 0xff) {
+			kbd_exists = 0;
+			return -1;
+		}
+		kbd_exists = 1;
+	}
+
 	if ((inb(KBD_STATUS_REG) & KBD_STAT_OBF) = 0)
 		return -1;
 
@@ -440,7 +472,7 @@
 #endif	/* CONFIG_IA64_SGI_SN2 */
 #endif /* CONFIG_SERIAL_SGI_L1_PROTOCOL */
 
-/* Check if there is a byte ready at the L1 port.  kdb_port is ignored */
+/* Check if there is a byte ready at the L1 port.  kdb_serial is ignored */
 static int snia_get_serial_char(void)
 {
 	unsigned char ch;
@@ -483,6 +515,10 @@
 static int blink_led(void)
 {
 	static long delay;
+
+	if (kbd_exists = 0)
+		return -1;
+
 	if (--delay < 0) {
 		if (BOGOMIPS = 0)	/* early kdb */
 			delay = 150000000/1000;     /* arbitrary bogomips */
diff -urN lia64-kdb-orig/drivers/char/serial.c lia64-kdb/drivers/char/serial.c
--- lia64-kdb-orig/drivers/char/serial.c	Mon Jul  8 20:52:24 2002
+++ lia64-kdb/drivers/char/serial.c	Mon Jul  8 21:04:44 2002
@@ -6027,7 +6027,14 @@
 	 */
 	if (kdb_serial_line = -1) {
 		kdb_serial_line = co->index;
-		kdb_port = state->port;
+		kdb_serial.io_type = info->io_type;
+		if (info->io_type = SERIAL_IO_MEM) {
+			kdb_serial.iobase = info->iomem_base;
+			kdb_serial.ioreg_shift = info->iomem_reg_shift;
+		} else {
+			kdb_serial.iobase = state->port;
+			kdb_serial.ioreg_shift = 0;
+		}
 	}
 #endif	/* CONFIG_KDB */
 
diff -urN lia64-kdb-orig/include/linux/kdb.h lia64-kdb/include/linux/kdb.h
--- lia64-kdb-orig/include/linux/kdb.h	Mon Jul  8 20:52:48 2002
+++ lia64-kdb/include/linux/kdb.h	Mon Jul  8 14:50:40 2002
@@ -75,11 +75,15 @@
 extern int kdb_on;
 
 	/*
-	 * kdb_port is initialized to zero, and is set to the I/O port
+	 * kdb_serial.iobase is initialized to zero, and is set to the I/O 
 	 * address of the serial port when the console is setup in
 	 * serial_console_setup.
 	 */
-extern int kdb_port;
+extern struct kdb_serial {
+	int io_type;
+	unsigned long iobase;
+	unsigned long ioreg_shift;
+} kdb_serial;
 
 	/*
 	 * kdb_diemsg

