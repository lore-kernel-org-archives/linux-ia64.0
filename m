From: Paul Bame <bame@fc.hp.com>
Date: Tue, 14 Jan 2003 18:11:50 +0000
Subject: [Linux-ia64] Latest HP Diva/ECI/MP serial
Message-Id: <marc-linux-ia64-105590709805671@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Someday HP'll release boxes which can contain more than one
ECI/MP/Diva multiport serial card.  This patch, unlike the earlier
one I sent, supports multiple instances of the card.

This patch also has some ACPI serial code for which I claim no
responsibility.

	-P

Index: drivers/char/serial.c
=================================RCS file: /var/cvs/linux/drivers/char/serial.c,v
retrieving revision 1.1.2.5
diff -u -r1.1.2.5 serial.c
--- drivers/char/serial.c	11 Dec 2002 16:47:51 -0000	1.1.2.5
+++ drivers/char/serial.c	14 Jan 2003 18:06:18 -0000
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
+#include "../acpi/acpi_bus.h"
+#endif
 
 /*
  * All of the compatibilty code so we can compile serial.c against
@@ -257,6 +260,10 @@
 
 static struct timer_list serial_timer;
 
+#define HP_DIVA_CHECKTIME (1*HZ)
+static struct timer_list hp_diva_timer;
+static int hp_diva_count = 0;
+
 /* serial subtype definitions */
 #ifndef SERIAL_TYPE_NORMAL
 #define SERIAL_TYPE_NORMAL	1
@@ -793,6 +800,41 @@
 }
 
 #ifdef CONFIG_SERIAL_SHARE_IRQ
+static inline int is_hp_diva_info(struct async_struct *info) 
+{
+    struct pci_dev *dev = info->state->dev;
+    return (dev && dev->vendor = PCI_VENDOR_ID_HP &&
+		dev->device = PCI_DEVICE_ID_HP_SAS);
+}
+
+static inline int is_hp_diva_irq(int irq)
+{
+    struct async_struct *info = IRQ_ports[irq];
+    return (info && is_hp_diva_info(info));
+}
+
+/*
+ * It is possible to "use up" transmit empty interrupts in some
+ * cases with HP Diva cards.  Figure out if there _should_ be a
+ * transmit interrupt and if so, return a suitable iir value so
+ * that we can recover when called from rs_timer().
+ */
+static inline int hp_diva_iir(int irq, struct async_struct *info)
+{
+	int iir = serial_in(info, UART_IIR);
+
+	if (is_hp_diva_info(info) &&
+		(iir & UART_IIR_NO_INT) != 0 &&
+		(info->IER & UART_IER_THRI) != 0 &&
+		(info->xmit.head != info->xmit.tail || info->x_char) &&
+		(serial_in(info, UART_LSR) & UART_LSR_THRE) != 0) {
+		    iir &= ~(UART_IIR_ID | UART_IIR_NO_INT);
+		    iir |= UART_IIR_THRI;
+	}
+
+	return iir;
+}
+
 /*
  * This is the serial driver's generic interrupt routine
  */
@@ -823,7 +865,7 @@
 
 	do {
 		if (!info->tty ||
-		    ((iir=serial_in(info, UART_IIR)) & UART_IIR_NO_INT)) {
+		    ((iir=hp_diva_iir(irq, info)) & UART_IIR_NO_INT)) {
 			if (!end_mark)
 				end_mark = info;
 			goto next;
@@ -1087,9 +1129,11 @@
 #ifdef CONFIG_SERIAL_SHARE_IRQ
 			if (info->next_port) {
 				do {
-					serial_out(info, UART_IER, 0);
-					info->IER |= UART_IER_THRI;
-					serial_out(info, UART_IER, info->IER);
+					if (!is_hp_diva_info(info)) {
+						serial_out(info, UART_IER, 0);
+						info->IER |= UART_IER_THRI;
+						serial_out(info, UART_IER, info->IER);
+					}
 					info = info->next_port;
 				} while (info);
 #ifdef CONFIG_SERIAL_MULTIPORT
@@ -1121,6 +1165,33 @@
 }
 
 /*
+ * This subroutine is called when the hp_diva_timer goes off.  In certain
+ * cases (multiple gettys in particular) Diva seems
+ * to issue only a single transmit empty interrupt instead of one each
+ * time THRI is enabled, causing interrupts to be "used up".  This
+ * serves to poll the Diva UARTS more frequently than rs_timer() does.
+ */
+static void hp_diva_check(unsigned long dummy)
+{
+	static unsigned long last_strobe;
+	unsigned long flags;
+	int i;
+
+	if (time_after_eq(jiffies, last_strobe + HP_DIVA_CHECKTIME)) {
+		for (i = 0; i < NR_IRQS; i++) {
+			if (is_hp_diva_irq(i)) {
+			    save_flags(flags); cli();
+			    rs_interrupt(i, NULL, NULL);
+			    restore_flags(flags);
+			}
+		}
+	}
+	last_strobe = jiffies;
+	mod_timer(&hp_diva_timer, jiffies + HP_DIVA_CHECKTIME);
+}
+
+
+/*
  * ---------------------------------------------------------------
  * Low level utility subroutines for the serial driver:  routines to
  * figure out the appropriate timeout for an interrupt chain, routines
@@ -3263,6 +3334,12 @@
 		      (state->port ? state->port : (long)state->iomem_base),
 		      state->irq);
 
+	if ((state->io_type = SERIAL_IO_PORT && !state->port) ||
+	    (state->io_type = SERIAL_IO_MEM && !state->iomem_base)) {
+		ret += sprintf(buf+ret, "\n");
+		return ret;
+	}
+
 	/*
 	 * Figure out the current RS-232 lines
 	 */
@@ -4258,6 +4335,8 @@
 	if (!enable)
 		return 0;
 
+	hp_diva_count++;
+
 	switch (dev->subsystem_device) {
 	case 0x1049: /* Prelude Diva 1 */
 	case 0x1223: /* Superdome */
@@ -4276,6 +4355,10 @@
 		break;
 	}
 
+	init_timer(&hp_diva_timer);
+	hp_diva_timer.function = hp_diva_check;
+	mod_timer(&hp_diva_timer, jiffies + HP_DIVA_CHECKTIME);
+
 	return 0;
 }
 
@@ -4577,6 +4660,93 @@
 	}
 }
 
+#ifdef ENABLE_SERIAL_ACPI
+static int acpi_serial_add(struct acpi_device *device)
+{
+	acpi_status result;
+	acpi_buffer buffer;
+	struct serial_struct serial_req;
+	int line, offset = 0;
+
+	memset(&serial_req, 0, sizeof(serial_req));
+	buffer.length = 0;
+	buffer.pointer = NULL;
+	result = acpi_get_current_resources(device->handle, &buffer);
+	if (result != AE_BUFFER_OVERFLOW)
+		return -ENODEV;
+	buffer.pointer = kmalloc(buffer.length, GFP_KERNEL);
+	if (!buffer.pointer)
+		return -ENOMEM;
+	result = acpi_get_current_resources(device->handle, &buffer);
+	if (result != AE_OK) {
+		result = -ENODEV;
+		goto out;
+	}
+
+	while (offset <= buffer.length) {
+		acpi_resource *res = buffer.pointer + offset;
+		if (res->length = 0)
+			break;
+		offset += res->length;
+		if (res->id = ACPI_RSTYPE_ADDRESS32) {
+			acpi_resource_address32 *addr32 = &res->data.address32;
+			serial_req.iomem_base = ioremap(addr32->min_address_range, addr32->max_address_range - addr32->min_address_range + 1);
+			serial_req.io_type = SERIAL_IO_MEM;
+			serial_req.port = 0;
+			serial_req.port_high = 0;
+		} else if (res->id = ACPI_RSTYPE_EXT_IRQ) {
+			acpi_resource_ext_irq *ext_irq = &res->data.extended_irq;
+			if (ext_irq->number_of_interrupts > 0) {
+#ifdef CONFIG_IA64
+				serial_req.irq = acpi_register_irq(ext_irq->interrupts[0],
+				                  ext_irq->active_high_low = ACPI_ACTIVE_HIGH,
+				                  ext_irq->edge_level = ACPI_EDGE_SENSITIVE);
+#else
+				serial_req.irq = ext_irq->interrupts[0];
+#endif
+			}
+		}
+	}
+
+	serial_req.baud_base = BASE_BAUD;
+	serial_req.flags = ASYNC_SKIP_TEST|ASYNC_BOOT_AUTOCONF|ASYNC_AUTO_IRQ;
+	serial_req.xmit_fifo_size = serial_req.custom_divisor = 0;
+	serial_req.close_delay = serial_req.hub6 = serial_req.closing_wait = 0;
+	serial_req.iomem_reg_shift = 0;
+
+	result = 0;
+	line = register_serial(&serial_req);
+	if (line < 0)
+		result = -ENODEV;
+
+ out:
+	kfree(buffer.pointer);
+	return result;
+}
+
+static int acpi_serial_remove(struct acpi_device *device, int type)
+{
+	return 0;
+}
+
+static struct acpi_driver acpi_serial_driver = {
+	name:	"serial",
+	class:	"",
+	ids:	"PNP0501",
+	ops:	{
+			add:	acpi_serial_add,
+			remove:	acpi_serial_remove,
+		},
+};
+
+/*
+ * Look for serial ports in the ACPI namespace.
+ */
+static void __devinit probe_serial_acpi(void)
+{
+	acpi_bus_register_driver(&acpi_serial_driver);
+}
+#endif /* ENABLE_SERIAL_ACPI */
 
 static struct pci_device_id serial_pci_tbl[] __devinitdata = {
 	{	PCI_VENDOR_ID_V3, PCI_DEVICE_ID_V3_V960,
@@ -5537,11 +5707,14 @@
 		tty_register_devfs(&callout_driver, 0,
 				   callout_driver.minor_start + state->line);
 	}
+#ifdef ENABLE_SERIAL_ACPI
+	probe_serial_acpi();
+#endif
 #ifdef ENABLE_SERIAL_PCI
 	probe_serial_pci();
 #endif
 #ifdef ENABLE_SERIAL_PNP
-       probe_serial_pnp();
+	probe_serial_pnp();
 #endif
 	return 0;
 }
@@ -5714,6 +5887,8 @@
 
 	/* printk("Unloading %s: version %s\n", serial_name, serial_version); */
 	del_timer_sync(&serial_timer);
+	if (hp_diva_count > 0)
+		del_timer_sync(&hp_diva_timer);
 	save_flags(flags); cli();
         remove_bh(SERIAL_BH);
 	if ((e1 = tty_unregister_driver(&serial_driver)))

