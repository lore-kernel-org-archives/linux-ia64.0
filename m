From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 13 Jan 2004 23:45:09 +0000
Subject: [PATCH] move HCDP under serial console #ifdef
Message-Id: <200401131645.09430.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Currently you can select HCDP independent of serial console.  This
doesn't seem very useful, and makes the setup_serial_hcdp() reference
unresolved if the serial driver is built as a module.

CONFIG_SERIAL_8250_CONSOLE is only selectable if the serial core is
built in (SERIAL_8250=y), so this patch makes sure we don't try to
call setup_serial_hcdp() unless it is actually built in to the kernel.

(I think we should also make HCDP selection dependent on
SERIAL_8250_CONSOLE=y in Kconfig; I'll send a separate patch
for that since it's not ia64-specific.)

=== arch/ia64/kernel/setup.c 1.64 vs edited ==--- 1.64/arch/ia64/kernel/setup.c	Mon Dec 29 14:37:24 2003
+++ edited/arch/ia64/kernel/setup.c	Mon Jan 12 15:46:23 2004
@@ -317,13 +317,13 @@
 #ifdef CONFIG_ACPI_BOOT
 	acpi_boot_init();
 #endif
+#ifdef CONFIG_SERIAL_8250_CONSOLE
 #ifdef CONFIG_SERIAL_8250_HCDP
 	if (efi.hcdp) {
 		void setup_serial_hcdp(void *);
 		setup_serial_hcdp(efi.hcdp);
 	}
 #endif
-#ifdef CONFIG_SERIAL_8250_CONSOLE
 	/*
 	 * Without HCDP, we won't discover any serial ports until the serial driver looks
 	 * in the ACPI namespace.  If ACPI claims there are some legacy devices, register

