From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 07 Aug 2003 16:53:37 +0000
Subject: [PATCH] 2.4 support for discovering serial ports from ACPI namespace
Message-Id: <marc-linux-ia64-106027579227749@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This functionality has been in the ia64 tree for quite a while
now.  Now that 2.4 has current ACPI in it, I'd like to get this
merged as well.  This patch is against Marcelo's current 2.4 BK.

There's a bit of ugliness (the CONFIG_IA64 check) around
registering the IRQ. I'm also working on cleaning that up,
but it will involve adding an ACPI interface, so will take
a bit.

Bjorn


=== Documentation/Configure.help 1.176 vs edited ==--- 1.176/Documentation/Configure.help	Wed Aug  6 09:21:33 2003
+++ edited/Documentation/Configure.help	Thu Aug  7 09:59:40 2003
@@ -17531,6 +17531,11 @@
   purpose port, say Y here. See
   <http://www.dig64.org/specifications/DIG64_HCDPv10a_01.pdf>.
 
+Support for serial ports defined in ACPI namespace
+CONFIG_SERIAL_ACPI
+  If you wish to enable serial port discovery via the ACPI
+  namespace, say Y here.  If unsure, say N.
+
 Support for PowerMac serial ports
 CONFIG_MAC_SERIAL
   If you have Macintosh style serial ports (8 pin mini-DIN), say Y
=== drivers/char/Config.in 1.48 vs edited ==--- 1.48/drivers/char/Config.in	Tue Jul 29 07:55:03 2003
+++ edited/drivers/char/Config.in	Thu Aug  7 09:59:40 2003
@@ -24,6 +24,9 @@
       tristate '   Atomwide serial port support' CONFIG_ATOMWIDE_SERIAL
       tristate '   Dual serial port support' CONFIG_DUALSP_SERIAL
    fi
+   if [ "$CONFIG_ACPI" = "y" ]; then
+      bool '  Support for serial ports defined in ACPI namespace' CONFIG_SERIAL_ACPI
+   fi
 fi
 dep_mbool 'Extended dumb serial driver options' CONFIG_SERIAL_EXTENDED $CONFIG_SERIAL
 if [ "$CONFIG_SERIAL_EXTENDED" = "y" ]; then
=== drivers/char/serial.c 1.34 vs edited ==--- 1.34/drivers/char/serial.c	Sun Jul  6 23:33:28 2003
+++ edited/drivers/char/serial.c	Thu Aug  7 10:16:17 2003
@@ -92,9 +92,8 @@
  * 		ever possible.
  *
  * CONFIG_SERIAL_ACPI
- *		Enable support for serial console port and serial 
- *		debug port as defined by the SPCR and DBGP tables in 
- *		ACPI 2.0.
+ *		Enable support for serial ports found in the ACPI
+ *		namespace.
  */
 
 #include <linux/config.h>
@@ -222,6 +221,10 @@
 #ifdef CONFIG_MAGIC_SYSRQ
 #include <linux/sysrq.h>
 #endif
+#ifdef ENABLE_SERIAL_ACPI
+#include <linux/acpi.h>
+#include <acpi/acpi_bus.h>
+#endif
 
 /*
  * All of the compatibilty code so we can compile serial.c against
@@ -4584,6 +4587,103 @@
 	}
 }
 
+#ifdef ENABLE_SERIAL_ACPI
+static acpi_status acpi_serial_address(struct serial_struct *req,
+				       struct acpi_resource_address64 *addr)
+{
+	unsigned long size;
+
+	size = addr->max_address_range - addr->min_address_range + 1;
+	req->iomem_base = ioremap(addr->min_address_range, size);
+	if (!req->iomem_base) {
+		printk("%s: couldn't ioremap 0x%lx-0x%lx\n", __FUNCTION__,
+			addr->min_address_range, addr->max_address_range);
+		return AE_ERROR;
+	}
+	req->io_type = SERIAL_IO_MEM;
+	return AE_OK;
+}
+
+static acpi_status acpi_serial_irq(struct serial_struct *req,
+				   struct acpi_resource_ext_irq *ext_irq)
+{
+	if (ext_irq->number_of_interrupts > 0) {
+#ifdef CONFIG_IA64
+		req->irq = acpi_register_irq(ext_irq->interrupts[0],
+	                  ext_irq->active_high_low, ext_irq->edge_level);
+#else
+		req->irq = ext_irq->interrupts[0];
+#endif
+	}
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
+}
+
+static int acpi_serial_add(struct acpi_device *device)
+{
+	acpi_status status;
+	struct serial_struct serial_req;
+	int line;
+
+	memset(&serial_req, 0, sizeof(serial_req));
+
+	status = acpi_walk_resources(device->handle, METHOD_NAME__CRS,
+				     acpi_serial_resource, &serial_req);
+	if (ACPI_FAILURE(status))
+		return -ENODEV;
+
+	if (!serial_req.iomem_base) {
+		printk("%s: no iomem address in %s _CRS\n", __FUNCTION__,
+			device->pnp.bus_id);
+		return -ENODEV;
+	}
+
+	serial_req.baud_base = BASE_BAUD;
+	serial_req.flags = ASYNC_SKIP_TEST|ASYNC_BOOT_AUTOCONF|ASYNC_AUTO_IRQ;
+	serial_req.xmit_fifo_size = serial_req.custom_divisor = 0;
+	serial_req.close_delay = serial_req.hub6 = serial_req.closing_wait = 0;
+	serial_req.iomem_reg_shift = 0;
+
+	line = register_serial(&serial_req);
+	if (line < 0)
+		return -ENODEV;
+
+	return 0;
+}
+
+static int acpi_serial_remove(struct acpi_device *device, int type)
+{
+	return 0;
+}
+
+static struct acpi_driver acpi_serial_driver = {
+	.name =		"serial",
+	.class =	"",
+	.ids =		"PNP0501",
+	.ops =	{
+		.add =		acpi_serial_add,
+		.remove =	acpi_serial_remove,
+	},
+};
+
+static void __devinit probe_serial_acpi(void)
+{
+	acpi_bus_register_driver(&acpi_serial_driver);
+}
+#endif /* ENABLE_SERIAL_ACPI */
 
 static struct pci_device_id serial_pci_tbl[] __devinitdata = {
 	{	PCI_VENDOR_ID_V3, PCI_DEVICE_ID_V3_V960,
@@ -5545,6 +5645,9 @@
 		tty_register_devfs(&callout_driver, 0,
 				   callout_driver.minor_start + state->line);
 	}
+#ifdef ENABLE_SERIAL_ACPI
+	probe_serial_acpi();
+#endif
 #ifdef ENABLE_SERIAL_PCI
 	probe_serial_pci();
 #endif

