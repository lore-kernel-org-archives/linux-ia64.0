From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 14 Jan 2004 16:03:16 +0000
Subject: [PATCH] make ACPI serial module unload work
Message-Id: <200401140903.16210.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

(Sorry, copied this to the wrong list the first time.)

This patch makes ACPI serial ports work right when the serial driver
is built as a module.  Previously, loading worked fine, but we didn't
clean up on module removal.

This is against 2.6 (and it includes the UPF_RESOURCES change you
recently applied, Russell, so there might be a trivial conflict there).

=== drivers/serial/8250_acpi.c 1.5 vs edited ==--- 1.5/drivers/serial/8250_acpi.c	Wed Oct  8 15:04:40 2003
+++ edited/drivers/serial/8250_acpi.c	Tue Jan 13 16:08:52 2004
@@ -1,6 +1,7 @@
 /*
- * serial/acpi.c
  * Copyright (c) 2002-2003 Matthew Wilcox for Hewlett-Packard
+ * Copyright (C) 2004 Hewlett-Packard Co
+ *	Bjorn Helgaas <bjorn.helgaas@hp.com>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -12,12 +13,19 @@
 #include <linux/init.h>
 #include <linux/module.h>
 #include <linux/serial.h>
+#include <linux/tty.h>
+#include <linux/serial_core.h>
 
 #include <acpi/acpi_bus.h>
 
 #include <asm/io.h>
 #include <asm/serial.h>
 
+struct serial_private {
+	int	line;
+	void	*iomem_base;
+};
+
 static acpi_status acpi_serial_mmio(struct serial_struct *req,
 				    struct acpi_resource_address64 *addr)
 {
@@ -94,38 +102,72 @@
 
 static int acpi_serial_add(struct acpi_device *device)
 {
+	struct serial_private *priv;
 	acpi_status status;
 	struct serial_struct serial_req;
-	int line;
+	int result;
 
 	memset(&serial_req, 0, sizeof(serial_req));
 
+	priv = kmalloc(sizeof(struct serial_private), GFP_KERNEL);
+	if (!priv) {
+		result = -ENOMEM;
+		goto fail;
+	}
+	memset(priv, 0, sizeof(*priv));
+
 	status = acpi_walk_resources(device->handle, METHOD_NAME__CRS,
 				     acpi_serial_resource, &serial_req);
-	if (ACPI_FAILURE(status))
-		return -ENODEV;
+	if (ACPI_FAILURE(status)) {
+		result = -ENODEV;
+		goto fail;
+	}
 
-	if (!serial_req.iomem_base && !serial_req.port) {
+	if (serial_req.iomem_base)
+		priv->iomem_base = serial_req.iomem_base;
+	else if (!serial_req.port) {
 		printk(KERN_ERR "%s: no iomem or port address in %s _CRS\n",
 			__FUNCTION__, device->pnp.bus_id);
-		return -ENODEV;
+		result = -ENODEV;
+		goto fail;
 	}
 
 	serial_req.baud_base = BASE_BAUD;
-	serial_req.flags = ASYNC_SKIP_TEST|ASYNC_BOOT_AUTOCONF|ASYNC_AUTO_IRQ;
+	serial_req.flags = UPF_SKIP_TEST | UPF_BOOT_AUTOCONF |
+			   UPF_AUTO_IRQ  | UPF_RESOURCES;
 
-	line = register_serial(&serial_req);
-	if (line < 0) {
+	priv->line = register_serial(&serial_req);
+	if (priv->line < 0) {
 		printk(KERN_WARNING "Couldn't register serial port %s: %d",
-			device->pnp.bus_id, line);
-		return -ENODEV;
+			device->pnp.bus_id, priv->line);
+		result = -ENODEV;
+		goto fail;
 	}
 
+	acpi_driver_data(device) = priv;
 	return 0;
+
+fail:
+	if (serial_req.iomem_base)
+		iounmap(serial_req.iomem_base);
+	kfree(priv);
+
+	return result;
 }
 
 static int acpi_serial_remove(struct acpi_device *device, int type)
 {
+	struct serial_private *priv;
+
+	if (!device || !acpi_driver_data(device))
+		return -EINVAL;
+
+	priv = acpi_driver_data(device);
+	unregister_serial(priv->line);
+	if (priv->iomem_base)
+		iounmap(priv->iomem_base);
+	kfree(priv);
+
 	return 0;
 }
 

