From: "Li, Shaohua" <shaohua.li@intel.com>
Date: Fri, 12 Nov 2004 08:23:59 +0000
Subject: RE: [PATCH] GPE block driver [2/2]
Message-Id: <16A54BF5D6E14E4D916CE26C9AD3057588EFB6@pdsmsx402.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20041107145048.GE23303@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20041107145048.GE23303@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <matthew-Ztpu424NOJ8@public.gmane.org>
Cc: acpi-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org

>GPE blocks are used to extend the number of events that ACPI can
handle,
>particularly on larger machines.
>
>Index: linux-2.6/drivers/acpi/Kconfig
>=================================>RCS file: /var/cvs/linux-2.6/drivers/acpi/Kconfig,v
>retrieving revision 1.13
>diff -u -p -r1.13 Kconfig
>--- linux-2.6/drivers/acpi/Kconfig	11 Oct 2004 21:41:01 -0000
1.13
>+++ linux-2.6/drivers/acpi/Kconfig	7 Nov 2004 14:34:33 -0000
>@@ -119,6 +119,15 @@ config ACPI_FAN
> 	  This driver adds support for ACPI fan devices, allowing
user-mode
> 	  applications to perform basic fan control (on, off, status).
>
>+config ACPI_GPE_BLOCK
>+	tristate "GPE block"
>+	depends on ACPI_INTERPRETER
>+	depends on !IA64_SGI_SN
>+	default m
>+	help
>+	  GPE block devices are used to increase the number of
interrupts
>+	  available on larger machines.
>+
> config ACPI_PROCESSOR
> 	tristate "Processor"
> 	depends on ACPI_INTERPRETER
>Index: linux-2.6/drivers/acpi/Makefile
>=================================>RCS file: /var/cvs/linux-2.6/drivers/acpi/Makefile,v
>retrieving revision 1.4
>diff -u -p -r1.4 Makefile
>--- linux-2.6/drivers/acpi/Makefile	13 Sep 2004 15:22:51 -0000
1.4
>+++ linux-2.6/drivers/acpi/Makefile	7 Nov 2004 14:34:33 -0000
>@@ -38,6 +38,7 @@ obj-$(CONFIG_ACPI_BATTERY)	+= battery.o
> obj-$(CONFIG_ACPI_BUTTON)	+= button.o
> obj-$(CONFIG_ACPI_EC)		+= ec.o
> obj-$(CONFIG_ACPI_FAN)		+= fan.o
>+obj-$(CONFIG_ACPI_GPE_BLOCK)	+= gpe-block.o
> obj-$(CONFIG_ACPI_PCI)		+= pci_root.o pci_link.o
pci_irq.o pci_bind.o
> obj-$(CONFIG_ACPI_POWER)	+= power.o
> obj-$(CONFIG_ACPI_PROCESSOR)	+= processor.o
>Index: linux-2.6/drivers/acpi/gpe-block.c
>=================================>RCS file: linux-2.6/drivers/acpi/gpe-block.c
>diff -N linux-2.6/drivers/acpi/gpe-block.c
>--- /dev/null	1 Jan 1970 00:00:00 -0000
>+++ linux-2.6/drivers/acpi/gpe-block.c	7 Nov 2004 14:34:33 -0000
>@@ -0,0 +1,155 @@
>+/*
>+ * drivers/acpi/gpe-block.c
>+ *
>+ * Copyright (c) Matthew Wilcox for Hewlett Packard 2004
>+ *
>+ * This program is free software; you can redistribute it and/or
modify
>+ * it under the terms of the GNU General Public License as published
by
>+ * the Free Software Foundation; either version 2 of the License, or
(at
>+ * your option) any later version.
>+ */
>+
>+#include <linux/acpi.h>
>+#include <linux/ioport.h>
>+#include <linux/module.h>
>+#include <acpi/acpi_bus.h>
>+#include <acpi/acpi_drivers.h>
>+#include <acpi/acpixf.h>
>+
>+MODULE_AUTHOR("Matthew Wilcox <willy@hp.com>");
>+MODULE_LICENSE("GPL");
>+MODULE_VERSION("0.2");
>+
>+#define NAME "gpe-block"
>+
>+struct gpe_block {
>+	struct acpi_generic_address address;
>+	u32 register_count;
>+	u32 interrupt_level;
>+};
>+
>+static acpi_status acpi_gpe_block_crs_irq(struct acpi_resource_ext_irq
>*irq,
>+		struct gpe_block *data)
>+{
>+	acpi_register_gsi(irq->interrupts[0], irq->edge_level,
>+			irq->active_high_low);
>+	data->interrupt_level = irq->interrupts[0];
>+	return AE_OK;
>+}
Hi Matthew,
Will you send a sequent patch? I haven't looked at an interrupt handler
is registered for the IRQ from GPE block device.

Shaohua
