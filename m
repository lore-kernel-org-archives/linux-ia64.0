From: Jes Sorensen <jes@wildopensource.com>
Date: Mon, 07 Jul 2003 21:05:57 +0000
Subject: serial legacy ports and ACPI
Message-Id: <marc-linux-ia64-105761215001812@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

I am trying to come up with a solution to tell the serial driver to not
try and probe for serial ports on legacy IO addresses. While the current
code seems to work on SN2 it's a bit of a pain on systems which do not
come with a stack of 16550's glued to the motherboard.

Looking at the ACPI spec, it seems reasonable to me to disable this
probe if the FADT doesn't have the BAF_LEGACY_DEVICES bit set. Anyone
having oppinions on this?

I am proposing the below patch to solve the problem (relative to
2.4.20).  It works for me on SN2, but I don't know what other platforms
set in their FADT.

Cheers,
Jes

--- ../old/drivers/char/serial.c	Fri Jul  4 16:10:30 2003
+++ drivers/char/serial.c	Mon Jul  7 13:07:29 2003
@@ -230,6 +230,9 @@
 #ifdef CONFIG_MAGIC_SYSRQ
 #include <linux/sysrq.h>
 #endif
+#ifdef CONFIG_ACPI
+#include <linux/acpi.h>
+#endif
 
 /*
  * All of the compatibilty code so we can compile serial.c against
@@ -5524,6 +5527,10 @@
 {
 	int i;
 	struct serial_state * state;
+#ifdef CONFIG_ACPI
+	acpi_buffer acpi_buf;
+	unsigned int acpi_status;
+#endif
 
 	init_bh(SERIAL_BH, do_serial_bh);
 	init_timer(&serial_timer);
@@ -5624,7 +5631,24 @@
 		panic("Couldn't register serial driver\n");
 	if (tty_register_driver(&callout_driver))
 		panic("Couldn't register callout driver\n");
-	
+
+#ifdef CONFIG_ACPI
+	acpi_buf.pointer = NULL;
+	acpi_buf.length = ACPI_ALLOCATE_BUFFER;
+
+	acpi_status = acpi_get_table(ACPI_TABLE_FADT, 1, &acpi_buf);
+	if (!acpi_status) {
+		fadt_descriptor_rev2 *fadt;
+		u16 iapc_boot_arch;
+
+		fadt = acpi_buf.pointer;
+		iapc_boot_arch = fadt->iapc_boot_arch;
+		kfree(acpi_buf.pointer);
+
+		if (!iapc_boot_arch & BAF_LEGACY_DEVICES)
+			goto skip_legacy_probe;
+	}
+#endif
 	for (i = 0, state = rs_table; i < NR_PORTS; i++,state++) {
 		state->magic = SSTATE_MAGIC;
 		state->line = i;
@@ -5677,6 +5701,9 @@
 		tty_register_devfs(&callout_driver, 0,
 				   callout_driver.minor_start + state->line);
 	}
+#ifdef CONFIG_ACPI
+ skip_legacy_probe:
+#endif
 #ifdef CONFIG_SERIAL_GSC
 	probe_serial_gsc();
 #endif
