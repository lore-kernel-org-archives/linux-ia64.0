From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Fri, 20 Dec 2002 01:06:40 +0000
Subject: [Linux-ia64] CONFIG_SERIAL_ACPI missing??
Message-Id: <marc-linux-ia64-105590709805621@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,
The options CONFIG_SERIAL_8250_ACPI and CONFIG_SERIAL_8250_HDCP appear
to have vanished in recent kernels.

Here's a patch against 2.5.45 to reinstate them.

diff -Nur --exclude=RCS --exclude=CVS --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet linux-2.5-EXPORT/drivers/serial/Kconfig linux-2.5-preempt/drivers/serial/Kconfig
--- linux-2.5-EXPORT/drivers/serial/Kconfig	Fri Dec 20 11:47:23 2002
+++ linux-2.5-preempt/drivers/serial/Kconfig	Thu Dec 12 11:52:33 2002
@@ -138,6 +138,23 @@
 	help
 	  ::: To be written :::
 
+config SERIAL_8250_ACPI
+       bool "Support for serial ports defined by the ACPI tables"
+       depends on SERIAL_8250 && IA64
+       help 
+         Legacy free machines may not have serial ports at the legacy
+	 COM1, COM2 etc addresses. Serial ports on such machines are
+	 described by the ACPI tables SPCR (Serial Port Console
+	 Redirection) table and DBGP (Debug Port) table. Say Y here if
+	 you want to include support for these serial ports.
+
+config SERIAL_8250_HCDP
+       bool "Support for serial ports defined by the EFI HCDP"
+       depends on SERIAL_8250 && IA64
+       help
+         ::: No help yet :::
+
+
 comment "Non-8250 serial port support"
 
 config SERIAL_8250_ACORN

