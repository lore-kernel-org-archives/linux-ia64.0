From: Matthew Wilcox <matthew@wil.cx>
Date: Sun, 07 Nov 2004 14:50:48 +0000
Subject: [PATCH] GPE block driver [2/2]
Message-Id: <20041107145048.GE23303@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20041106064442.GA21423@parcelfarce.linux.theplanet.co.uk> <20041106074900.GA29632@parcelfarce.linux.theplanet.co.uk> <20041107144315.GC23303@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20041107144315.GC23303@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <matthew@wil.cx>
Cc: acpi-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org


GPE blocks are used to extend the number of events that ACPI can handle,
particularly on larger machines.

Index: linux-2.6/drivers/acpi/Kconfig
=================================RCS file: /var/cvs/linux-2.6/drivers/acpi/Kconfig,v
retrieving revision 1.13
diff -u -p -r1.13 Kconfig
--- linux-2.6/drivers/acpi/Kconfig	11 Oct 2004 21:41:01 -0000	1.13
+++ linux-2.6/drivers/acpi/Kconfig	7 Nov 2004 14:34:33 -0000
@@ -119,6 +119,15 @@ config ACPI_FAN
 	  This driver adds support for ACPI fan devices, allowing user-mode 
 	  applications to perform basic fan control (on, off, status).
 
+config ACPI_GPE_BLOCK
+	tristate "GPE block"
+	depends on ACPI_INTERPRETER
+	depends on !IA64_SGI_SN
+	default m
+	help
+	  GPE block devices are used to increase the number of interrupts
+	  available on larger machines.
+
 config ACPI_PROCESSOR
 	tristate "Processor"
 	depends on ACPI_INTERPRETER
Index: linux-2.6/drivers/acpi/Makefile
=================================RCS file: /var/cvs/linux-2.6/drivers/acpi/Makefile,v
retrieving revision 1.4
diff -u -p -r1.4 Makefile
--- linux-2.6/drivers/acpi/Makefile	13 Sep 2004 15:22:51 -0000	1.4
+++ linux-2.6/drivers/acpi/Makefile	7 Nov 2004 14:34:33 -0000
@@ -38,6 +38,7 @@ obj-$(CONFIG_ACPI_BATTERY)	+= battery.o
 obj-$(CONFIG_ACPI_BUTTON)	+= button.o
 obj-$(CONFIG_ACPI_EC)		+= ec.o
 obj-$(CONFIG_ACPI_FAN)		+= fan.o
+obj-$(CONFIG_ACPI_GPE_BLOCK)	+= gpe-block.o
 obj-$(CONFIG_ACPI_PCI)		+= pci_root.o pci_link.o pci_irq.o pci_bind.o
 obj-$(CONFIG_ACPI_POWER)	+= power.o
 obj-$(CONFIG_ACPI_PROCESSOR)	+= processor.o
Index: linux-2.6/drivers/acpi/gpe-block.c
=================================RCS file: linux-2.6/drivers/acpi/gpe-block.c
diff -N linux-2.6/drivers/acpi/gpe-block.c
--- /dev/null	1 Jan 1970 00:00:00 -0000
+++ linux-2.6/drivers/acpi/gpe-block.c	7 Nov 2004 14:34:33 -0000
@@ -0,0 +1,155 @@
+/*
+ * drivers/acpi/gpe-block.c
+ *
+ * Copyright (c) Matthew Wilcox for Hewlett Packard 2004
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or (at
+ * your option) any later version.
+ */
+
+#include <linux/acpi.h>
+#include <linux/ioport.h>
+#include <linux/module.h>
+#include <acpi/acpi_bus.h>
+#include <acpi/acpi_drivers.h>
+#include <acpi/acpixf.h>
+
+MODULE_AUTHOR("Matthew Wilcox <willy@hp.com>");
+MODULE_LICENSE("GPL");
+MODULE_VERSION("0.2");
+
+#define NAME "gpe-block"
+
+struct gpe_block {
+	struct acpi_generic_address address;
+	u32 register_count;
+	u32 interrupt_level;
+};
+
+static acpi_status acpi_gpe_block_crs_irq(struct acpi_resource_ext_irq *irq,
+		struct gpe_block *data)
+{
+	acpi_register_gsi(irq->interrupts[0], irq->edge_level,
+			irq->active_high_low);
+	data->interrupt_level = irq->interrupts[0];
+	return AE_OK;
+}
+
+static acpi_status acpi_gpe_block_crs_addr(struct acpi_resource_address64 *addr,
+		struct gpe_block *data)
+{
+	int size = addr->max_address_range - addr->min_address_range + 1;
+	if (addr->resource_type = ACPI_MEMORY_RANGE) {
+		data->address.address_space_id = ACPI_ADR_SPACE_SYSTEM_MEMORY;
+		if (!request_mem_region(addr->min_address_range, size, NAME))
+			return AE_CTRL_TERMINATE;
+
+	} else if (addr->resource_type = ACPI_IO_RANGE) {
+		data->address.address_space_id = ACPI_ADR_SPACE_SYSTEM_IO;
+		if (!request_region(addr->min_address_range, size, NAME))
+			return AE_CTRL_TERMINATE;
+	} else {
+		return AE_CTRL_TERMINATE;
+	}
+
+	data->address.register_bit_width = ACPI_GPE_REGISTER_WIDTH;
+	data->address.register_bit_offset = ACPI_GPE_REGISTER_WIDTH;
+	data->address.address = addr->min_address_range;
+	data->register_count = size / 2;
+
+	return AE_OK;
+}
+
+static acpi_status acpi_gpe_block_crs_add(struct acpi_resource *res, void *data)
+{
+	if (res->id = ACPI_RSTYPE_EXT_IRQ)
+		return acpi_gpe_block_crs_irq(&res->data.extended_irq, data);
+
+	if (res->id = ACPI_RSTYPE_ADDRESS16 ||
+	    res->id = ACPI_RSTYPE_ADDRESS32 ||
+	    res->id = ACPI_RSTYPE_ADDRESS64) {
+		struct acpi_resource_address64 address;
+		acpi_resource_to_address64(res, &address);
+		return acpi_gpe_block_crs_addr(&address, data);
+	}
+
+	return AE_OK;
+}
+
+static acpi_status acpi_gpe_block_crs_remove(struct acpi_resource *res,
+		void *context)
+{
+	struct acpi_resource_address64 addr;
+	int size;
+	int *fadt = context;
+
+	*fadt = 0;
+
+	if (res->id != ACPI_RSTYPE_ADDRESS16 &&
+	    res->id != ACPI_RSTYPE_ADDRESS32 &&
+	    res->id != ACPI_RSTYPE_ADDRESS64)
+		return AE_OK;
+
+	acpi_resource_to_address64(res, &addr);
+
+	size = addr.max_address_range - addr.min_address_range + 1;
+	if (addr.resource_type = ACPI_MEMORY_RANGE) {
+		release_mem_region(addr.min_address_range, size);
+	} else if (addr.resource_type = ACPI_IO_RANGE) {
+		release_region(addr.min_address_range, size);
+	}
+	return AE_OK;
+}
+
+static int acpi_gpe_block_add(struct acpi_device *device)
+{
+	struct gpe_block block;
+
+	block.register_count = 0;
+	acpi_walk_resources(device->handle, METHOD_NAME__CRS,
+			acpi_gpe_block_crs_add, &block);
+	if (block.register_count = 0)
+		return 0;
+
+	acpi_install_gpe_block(device->handle, &block.address,
+			block.register_count, block.interrupt_level);
+
+	return AE_OK;
+}
+
+static int acpi_gpe_block_remove(struct acpi_device *device, int type)
+{
+	int fadt = 1;
+
+	acpi_walk_resources(device->handle, METHOD_NAME__CRS,
+			acpi_gpe_block_crs_remove, &fadt);
+	if (fadt)
+		return AE_OK;
+
+	return acpi_remove_gpe_block(device->handle);
+}
+
+static struct acpi_driver acpi_gpe_block_driver = {
+	.name =		NAME,
+	.ids =		"ACPI0006",
+	.ops =	{
+		.add =		acpi_gpe_block_add,
+		.remove =	acpi_gpe_block_remove,
+	},
+};
+
+static int __init acpi_gpe_block_init(void)
+{
+	int result = acpi_bus_register_driver(&acpi_gpe_block_driver);
+	return (result < 0) ? -ENODEV : 0;
+}
+
+static void __exit acpi_gpe_block_exit(void)
+{
+	acpi_bus_unregister_driver(&acpi_gpe_block_driver);
+}
+
+module_init(acpi_gpe_block_init);
+module_exit(acpi_gpe_block_exit);

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
