From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 14 Jan 2004 00:06:56 +0000
Subject: [PATCH] make HCDP dependent on serial console
Message-Id: <200401131706.56756.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I propose the following HCDP Kconfig patch.  It makes HCDP
selectable only when serial console has been selected.  One
desirable side effect is that both are then available only
when statically compiled in (i.e., not built as a module).

The HCDP support doesn't actually depend on IA64, but I left
that in for now because nobody else implements support for it
and I don't want people confused by a selectable option that
doesn't do anything.  Maybe a "depends on EFI" or something
will be useful eventually.

This is against 2.6.

=== drivers/serial/Kconfig 1.19 vs edited ==--- 1.19/drivers/serial/Kconfig	Sun Oct  5 14:56:40 2003
+++ edited/drivers/serial/Kconfig	Tue Jan 13 15:56:55 2004
@@ -62,6 +62,15 @@
 
 	  If unsure, say N.
 
+config SERIAL_8250_HCDP
+	bool "Console device discovery via EFI HCDP table"
+	depends on IA64
+	depends on SERIAL_8250_CONSOLE=y
+	---help---
+	  If you wish to make the serial console port described by the EFI
+	  HCDP table available for use as serial console, say Y here.  See
+	  <http://www.dig64.org/specifications/DIG64_HCDPv10a_01.pdf>.
+
 config SERIAL_8250_CS
 	tristate "8250/16550 PCMCIA device support"
 	depends on PCMCIA && SERIAL_8250
@@ -83,15 +92,6 @@
 	---help---
 	  If you wish to enable serial port discovery via the ACPI
 	  namespace, say Y here.  If unsure, say N.
-
-config SERIAL_8250_HCDP
-	bool "8250/16550 device discovery support via EFI HCDP table"
-	depends on IA64 && SERIAL_8250
-	---help---
-	  If you wish to make the serial console port described by the EFI
-	  HCDP table available for use as serial console or general
-	  purpose port, say Y here. See
-	  <http://www.dig64.org/specifications/DIG64_HCDPv10a_01.pdf>.
 
 config SERIAL_8250_NR_UARTS
 	int "Maximum number of non-legacy 8250/16550 serial ports"

