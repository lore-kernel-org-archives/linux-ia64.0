From: Matthew Wilcox <willy@debian.org>
Date: Mon, 23 Jun 2003 19:11:47 +0000
Subject: [PATCH] Missing Kconfig dependencies
Message-Id: <marc-linux-ia64-105639552318774@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


If one turns off SERIAL_8250, these items shouldn't be selectable.
Also gets the indentation right in `make oldconfig'.

Index: drivers/serial/Kconfig
=================================RCS file: /var/cvs/linux-2.5/drivers/serial/Kconfig,v
retrieving revision 1.13
diff -u -p -r1.13 Kconfig
--- a/drivers/serial/Kconfig	23 Jun 2003 03:30:31 -0000	1.13
+++ b/drivers/serial/Kconfig	23 Jun 2003 19:01:59 -0000
@@ -80,14 +80,14 @@ config SERIAL_8250_CS
 config SERIAL_8250_ACPI
 	bool "8250/16550 device discovery via ACPI namespace"
 	default y if IA64
-	depends on ACPI_BUS
+	depends on ACPI_BUS && SERIAL_8250
 	---help---
 	  If you wish to enable serial port discovery via the ACPI
 	  namespace, say Y here.  If unsure, say N.
 
 config SERIAL_8250_HCDP
 	bool "8250/16550 device discovery support via EFI HCDP table"
-	depends on IA64
+	depends on IA64 && SERIAL_8250
 	---help---
 	  If you wish to make the serial console port described by the EFI
 	  HCDP table available for use as serial console or general

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk
