From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 07 Aug 2003 17:00:36 +0000
Subject: [PATCH] 2.6.0-test2 ACPI serial discovery tweaks
Message-Id: <marc-linux-ia64-106027575727633@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch tweaks the 8250 ACPI namespace discovery to
	1) use acpi_walk_resources() to simplify processing the
	   _CRS data, and
	2) add error checking (ioremap failure, lack of MMIO
	   address in _CRS).

This patch is against the current 2.6.0-test2 BK.

Bjorn


=== drivers/serial/8250_acpi.c 1.1 vs edited ==--- 1.1/drivers/serial/8250_acpi.c	Wed May 14 08:50:37 2003
+++ edited/drivers/serial/8250_acpi.c	Wed Aug  6 18:20:53 2003
@@ -18,19 +18,25 @@
 #include <asm/io.h>
 #include <asm/serial.h>
 
-static void acpi_serial_address(struct serial_struct *req,
-				struct acpi_resource_address32 *addr32)
+static acpi_status acpi_serial_address(struct serial_struct *req,
+				       struct acpi_resource_address64 *addr)
 {
 	unsigned long size;
 
-	size = addr32->max_address_range - addr32->min_address_range + 1;
-	req->iomap_base = addr32->min_address_range;
+	size = addr->max_address_range - addr->min_address_range + 1;
+	req->iomap_base = addr->min_address_range;
 	req->iomem_base = ioremap(req->iomap_base, size);
+	if (!req->iomem_base) {
+		printk("%s: couldn't ioremap 0x%lx-0x%lx\n", __FUNCTION__,
+			addr->min_address_range, addr->max_address_range);
+		return AE_ERROR;
+	}
 	req->io_type = SERIAL_IO_MEM;
+	return AE_OK;
 }
 
-static void acpi_serial_irq(struct serial_struct *req,
-			    struct acpi_resource_ext_irq *ext_irq)
+static acpi_status acpi_serial_irq(struct serial_struct *req,
+				   struct acpi_resource_ext_irq *ext_irq)
 {
 	if (ext_irq->number_of_interrupts > 0) {
 #ifdef CONFIG_IA64
@@ -40,45 +46,50 @@
 		req->irq = ext_irq->interrupts[0];
 #endif
 	}
+	return AE_OK;
+}
+
+static acpi_status acpi_serial_resource(struct acpi_resource *res, void *data)
+{
+	struct serial_struct *serial_req = (struct serial_struct *) data;
+	struct acpi_resource_address64 addr;
+	acpi_status status;
+
+	status = acpi_resource_to_address64(res, &addr);
+	if (ACPI_SUCCESS(status))
+		return acpi_serial_address(serial_req, &addr);
+	else if (res->id = ACPI_RSTYPE_EXT_IRQ)
+		return acpi_serial_irq(serial_req, &res->data.extended_irq);
+	return AE_OK;
 }
 
 static int acpi_serial_add(struct acpi_device *device)
 {
-	acpi_status result;
-	struct acpi_buffer buffer = { ACPI_ALLOCATE_BUFFER, NULL };
+	acpi_status status;
 	struct serial_struct serial_req;
-	int line, offset = 0;
+	int line;
 
 	memset(&serial_req, 0, sizeof(serial_req));
-	result = acpi_get_current_resources(device->handle, &buffer);
-	if (ACPI_FAILURE(result)) {
-		result = -ENODEV;
-		goto out;
-	}
 
-	while (offset <= buffer.length) {
-		struct acpi_resource *res = buffer.pointer + offset;
-		if (res->length = 0)
-			break;
-		offset += res->length;
-		if (res->id = ACPI_RSTYPE_ADDRESS32) {
-			acpi_serial_address(&serial_req, &res->data.address32);
-		} else if (res->id = ACPI_RSTYPE_EXT_IRQ) {
-			acpi_serial_irq(&serial_req, &res->data.extended_irq);
-		}
+	status = acpi_walk_resources(device->handle, METHOD_NAME__CRS,
+				     acpi_serial_resource, &serial_req);
+	if (ACPI_FAILURE(status))
+		return -ENODEV;
+
+	if (!serial_req.iomem_base) {
+		printk("%s: no iomem address in %s _CRS\n", __FUNCTION__,
+			device->pnp.bus_id);
+		return -ENODEV;
 	}
 
 	serial_req.baud_base = BASE_BAUD;
 	serial_req.flags = ASYNC_SKIP_TEST|ASYNC_BOOT_AUTOCONF|ASYNC_AUTO_IRQ;
 
-	result = 0;
 	line = register_serial(&serial_req);
 	if (line < 0)
-		result = -ENODEV;
+		return -ENODEV;
 
- out:
-	acpi_os_free(buffer.pointer);
-	return result;
+	return 0;
 }
 
 static int acpi_serial_remove(struct acpi_device *device, int type)

