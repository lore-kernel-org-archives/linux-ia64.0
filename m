From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 10 Feb 2004 23:11:22 +0000
Subject: [PATCH] Discover ACPI serial ports before plug-in ports
Message-Id: <200402101611.22768.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Russell King <rmk-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>
Cc: linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, acpi-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org

I propose the following patch (against 2.6.2).  This makes us
discover ACPI serial ports before PCI ones.  The ACPI ports
tend to be built-in, and discovering them late means their ttyS
names move around if PCI serial ports are added or removed.  I
think it makes more sense to have relatively predictable and
consistent names for the built-in hardware.

=== drivers/serial/Makefile 1.20 vs edited ==--- 1.20/drivers/serial/Makefile	Tue Sep  9 03:30:53 2003
+++ edited/drivers/serial/Makefile	Tue Feb 10 15:46:15 2004
@@ -5,11 +5,11 @@
 #
 
 serial-8250-y :+serial-8250-$(CONFIG_SERIAL_8250_ACPI) += 8250_acpi.o
 serial-8250-$(CONFIG_GSC) += 8250_gsc.o
 serial-8250-$(CONFIG_PCI) += 8250_pci.o
 serial-8250-$(CONFIG_PNP) += 8250_pnp.o
 serial-8250-$(CONFIG_SERIAL_8250_HCDP) += 8250_hcdp.o
-serial-8250-$(CONFIG_SERIAL_8250_ACPI) += 8250_acpi.o
 
 obj-$(CONFIG_SERIAL_CORE) += serial_core.o
 obj-$(CONFIG_SERIAL_21285) += 21285.o

