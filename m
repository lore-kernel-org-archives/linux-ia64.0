From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 02 Mar 2006 00:00:27 +0000
Subject: [PATCH] serial: remove 8250_acpi (replaced by 8250_pnp and PNPACPI)
Message-Id: <200603011700.27683.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Russell King <rmk+serial@arm.linux.org.uk>
Cc: linux-serial@vger.kernel.org, len.brown@intel.com, linux-acpi@vger.kernel.org, linux-ia64@vger.kernel.org, Andrew Morton <akpm@osdl.org>

[This is post-2.6.16 material]

With the combination of PNPACPI and 8250_pnp, we no longer need 8250_acpi.

Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>

Index: work-mm4/drivers/serial/Kconfig
=================================--- work-mm4.orig/drivers/serial/Kconfig	2006-03-01 15:37:42.000000000 -0700
+++ work-mm4/drivers/serial/Kconfig	2006-03-01 15:38:09.000000000 -0700
@@ -77,14 +77,6 @@
 
 	  If unsure, say N.
 
-config SERIAL_8250_ACPI
-	bool "8250/16550 device discovery via ACPI namespace"
-	default y if IA64
-	depends on ACPI && SERIAL_8250
-	---help---
-	  If you wish to enable serial port discovery via the ACPI
-	  namespace, say Y here.  If unsure, say N.
-
 config SERIAL_8250_NR_UARTS
 	int "Maximum number of 8250/16550 serial ports"
 	depends on SERIAL_8250
Index: work-mm4/drivers/serial/Makefile
=================================--- work-mm4.orig/drivers/serial/Makefile	2006-03-01 15:37:42.000000000 -0700
+++ work-mm4/drivers/serial/Makefile	2006-03-01 15:38:09.000000000 -0700
@@ -5,7 +5,6 @@
 #
 
 serial-8250-y :-serial-8250-$(CONFIG_SERIAL_8250_ACPI) += 8250_acpi.o
 serial-8250-$(CONFIG_PNP) += 8250_pnp.o
 serial-8250-$(CONFIG_GSC) += 8250_gsc.o
 serial-8250-$(CONFIG_PCI) += 8250_pci.o
Index: work-mm4/drivers/serial/8250_acpi.c
=================================--- work-mm4.orig/drivers/serial/8250_acpi.c	2006-03-01 15:37:23.000000000 -0700
+++ /dev/null	1970-01-01 00:00:00.000000000 +0000
@@ -1,183 +0,0 @@
-/*
- * Copyright (c) 2002-2003 Matthew Wilcox for Hewlett-Packard
- * Copyright (C) 2004 Hewlett-Packard Co
- *	Bjorn Helgaas <bjorn.helgaas@hp.com>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License as published by
- * the Free Software Foundation; either version 2 of the License, or
- * (at your option) any later version.
- */
-
-#include <linux/acpi.h>
-#include <linux/init.h>
-#include <linux/module.h>
-#include <linux/serial_core.h>
-
-#include <acpi/acpi_bus.h>
-
-#include <asm/io.h>
-
-#include "8250.h"
-
-struct serial_private {
-	int	line;
-};
-
-static acpi_status acpi_serial_mmio(struct uart_port *port,
-				    struct acpi_resource_address64 *addr)
-{
-	port->mapbase = addr->minimum;
-	port->iotype = UPIO_MEM;
-	port->flags |= UPF_IOREMAP;
-	return AE_OK;
-}
-
-static acpi_status acpi_serial_port(struct uart_port *port,
-				    struct acpi_resource_io *io)
-{
-	if (io->address_length) {
-		port->iobase = io->minimum;
-		port->iotype = UPIO_PORT;
-	} else
-		printk(KERN_ERR "%s: zero-length IO port range?\n", __FUNCTION__);
-	return AE_OK;
-}
-
-static acpi_status acpi_serial_ext_irq(struct uart_port *port,
-				       struct acpi_resource_extended_irq *ext_irq)
-{
-	int rc;
-
-	if (ext_irq->interrupt_count > 0) {
-		rc = acpi_register_gsi(ext_irq->interrupts[0],
-	                   ext_irq->triggering, ext_irq->polarity);
-		if (rc < 0)
-			return AE_ERROR;
-		port->irq = rc;
-	}
-	return AE_OK;
-}
-
-static acpi_status acpi_serial_irq(struct uart_port *port,
-				   struct acpi_resource_irq *irq)
-{
-	int rc;
-
-	if (irq->interrupt_count > 0) {
-		rc = acpi_register_gsi(irq->interrupts[0],
-	                   irq->triggering, irq->polarity);
-		if (rc < 0)
-			return AE_ERROR;
-		port->irq = rc;
-	}
-	return AE_OK;
-}
-
-static acpi_status acpi_serial_resource(struct acpi_resource *res, void *data)
-{
-	struct uart_port *port = (struct uart_port *) data;
-	struct acpi_resource_address64 addr;
-	acpi_status status;
-
-	status = acpi_resource_to_address64(res, &addr);
-	if (ACPI_SUCCESS(status))
-		return acpi_serial_mmio(port, &addr);
-	else if (res->type = ACPI_RESOURCE_TYPE_IO)
-		return acpi_serial_port(port, &res->data.io);
-	else if (res->type = ACPI_RESOURCE_TYPE_EXTENDED_IRQ)
-		return acpi_serial_ext_irq(port, &res->data.extended_irq);
-	else if (res->type = ACPI_RESOURCE_TYPE_IRQ)
-		return acpi_serial_irq(port, &res->data.irq);
-	return AE_OK;
-}
-
-static int acpi_serial_add(struct acpi_device *device)
-{
-	struct serial_private *priv;
-	acpi_status status;
-	struct uart_port port;
-	int result;
-
-	memset(&port, 0, sizeof(struct uart_port));
-
-	port.uartclk = 1843200;
-	port.flags = UPF_SKIP_TEST | UPF_BOOT_AUTOCONF;
-
-	priv = kmalloc(sizeof(struct serial_private), GFP_KERNEL);
-	if (!priv) {
-		result = -ENOMEM;
-		goto fail;
-	}
-	memset(priv, 0, sizeof(*priv));
-
-	status = acpi_walk_resources(device->handle, METHOD_NAME__CRS,
-				     acpi_serial_resource, &port);
-	if (ACPI_FAILURE(status)) {
-		result = -ENODEV;
-		goto fail;
-	}
-
-	if (!port.mapbase && !port.iobase) {
-		printk(KERN_ERR "%s: no iomem or port address in %s _CRS\n",
-			__FUNCTION__, device->pnp.bus_id);
-		result = -ENODEV;
-		goto fail;
-	}
-
-	priv->line = serial8250_register_port(&port);
-	if (priv->line < 0) {
-		printk(KERN_WARNING "Couldn't register serial port %s: %d\n",
-			device->pnp.bus_id, priv->line);
-		result = -ENODEV;
-		goto fail;
-	}
-
-	acpi_driver_data(device) = priv;
-	return 0;
-
-fail:
-	kfree(priv);
-
-	return result;
-}
-
-static int acpi_serial_remove(struct acpi_device *device, int type)
-{
-	struct serial_private *priv;
-
-	if (!device || !acpi_driver_data(device))
-		return -EINVAL;
-
-	priv = acpi_driver_data(device);
-	serial8250_unregister_port(priv->line);
-	kfree(priv);
-
-	return 0;
-}
-
-static struct acpi_driver acpi_serial_driver = {
-	.name =		"serial",
-	.class =	"",
-	.ids =		"PNP0501",
-	.ops =	{
-		.add =		acpi_serial_add,
-		.remove =	acpi_serial_remove,
-	},
-};
-
-static int __init acpi_serial_init(void)
-{
-	return acpi_bus_register_driver(&acpi_serial_driver);
-}
-
-static void __exit acpi_serial_exit(void)
-{
-	acpi_bus_unregister_driver(&acpi_serial_driver);
-}
-
-module_init(acpi_serial_init);
-module_exit(acpi_serial_exit);
-
-MODULE_LICENSE("GPL");
-MODULE_DESCRIPTION("Generic 8250/16x50 ACPI serial driver");
