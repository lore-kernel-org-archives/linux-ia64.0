From: Khalid Aziz <khalid@fc.hp.com>
Date: Tue, 23 Jul 2002 17:58:30 +0000
Subject: [Linux-ia64] [PATCH] Simultaneous support for HCDP and SPCR/DBGP defined ports,
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------C25F4C6978DB19E945AD3972"
Message-Id: <marc-linux-ia64-105590701905822@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------C25F4C6978DB19E945AD3972
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

I am attaching a patch which allows a kernel to be built with support
for HCDP as well as SPCR/DBGP defined ports with no conflict on machines
that support HCDP as well as SPCR/DBGP tables. HCDP table takes
precedence over SPCR/DBGP in this patch. So if the kernel finds HCDP
table on a machine, it will ignore the SPCR table if there is one. Also,
the current HCDP code renames the serial console port defined by HCDP to
always be ttyS0 while SPCR code uses ttyS4 for the console port. This
patch adds code to drivers/char/acpi_serial.c to rename the console port
to be ttyS0.

-- 
Khalid

====================================================================
Khalid Aziz                                   Linux Systems Division
(970)898-9214                                        Hewlett-Packard
khalid@fc.hp.com                                    Fort Collins, CO
--------------C25F4C6978DB19E945AD3972
Content-Type: text/plain; charset=us-ascii;
 name="patch.hcdp_spcr"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch.hcdp_spcr"

diff -urN --exclude-from=diff_exclude_file linux-2.4.18-ia64/arch/ia64/kernel/acpi.c linux-2.4.18-ia64-hcdp/arch/ia64/kernel/acpi.c
--- linux-2.4.18-ia64/arch/ia64/kernel/acpi.c	Mon Jul 22 09:50:38 2002
+++ linux-2.4.18-ia64-hcdp/arch/ia64/kernel/acpi.c	Mon Jul 22 14:37:18 2002
@@ -487,6 +487,17 @@
 	acpi_ser_t *spcr = NULL;
 	unsigned long global_int = 0;
 
+#ifdef CONFIG_SERIAL_HCDP
+	/*
+	 * If an HCDP defined serial console has already been found 
+	 * and initialized, we will ignore SPCR.
+	 */
+	extern int hcdp_initialized;
+
+	if (hcdp_initialized) 
+		return 0;
+#endif
+
 	if (!phys_addr || !size)
 		return -EINVAL;
 
diff -urN --exclude-from=diff_exclude_file linux-2.4.18-ia64/arch/ia64/kernel/setup.c linux-2.4.18-ia64-hcdp/arch/ia64/kernel/setup.c
--- linux-2.4.18-ia64/arch/ia64/kernel/setup.c	Mon Jul 22 09:50:38 2002
+++ linux-2.4.18-ia64-hcdp/arch/ia64/kernel/setup.c	Mon Jul 22 13:52:48 2002
@@ -342,16 +342,16 @@
 
 	cpu_init();	/* initialize the bootstrap CPU */
 
-#ifdef CONFIG_ACPI_BOOT
-	acpi_boot_init(*cmdline_p);
-#endif
-#ifdef CONFIG_SERIAL_HCDP
+#ifdef CONFIG_SERIAL_HCDP)
 	if (efi.hcdp) {
 		void setup_serial_hcdp(void *);
 
 		/* Setup the serial ports described by HCDP */
 		setup_serial_hcdp(efi.hcdp);
 	}
+#endif
+#ifdef CONFIG_ACPI_BOOT
+	acpi_boot_init(*cmdline_p);
 #endif
 #ifdef CONFIG_VT
 # if defined(CONFIG_DUMMY_CONSOLE)
diff -urN --exclude-from=diff_exclude_file linux-2.4.18-ia64/drivers/char/Config.in linux-2.4.18-ia64-hcdp/drivers/char/Config.in
--- linux-2.4.18-ia64/drivers/char/Config.in	Mon Jul 22 09:50:39 2002
+++ linux-2.4.18-ia64-hcdp/drivers/char/Config.in	Mon Jul 22 14:38:05 2002
@@ -12,7 +12,10 @@
 if [ "$CONFIG_SERIAL" = "y" ]; then
    bool '  Support for console on serial port' CONFIG_SERIAL_CONSOLE
    if [ "$CONFIG_IA64" = "y" ]; then
-      bool 'Support for serial console port described by EFI HCDP table' CONFIG_SERIAL_HCDP
+      bool '  Support for serial console port described by EFI HCDP table' CONFIG_SERIAL_HCDP
+   fi
+   if [ "$CONFIG_ACPI" = "y" ]; then
+      bool '  Support for serial ports defined by ACPI tables' CONFIG_SERIAL_ACPI
    fi
    if [ "$CONFIG_ARCH_ACORN" = "y" ]; then
       tristate '   Atomwide serial port support' CONFIG_ATOMWIDE_SERIAL
@@ -20,9 +23,6 @@
    fi
 fi
 dep_mbool 'Extended dumb serial driver options' CONFIG_SERIAL_EXTENDED $CONFIG_SERIAL
-if [ "$CONFIG_ACPI" = "y" ]; then
-   bool '  Support for serial ports defined by ACPI tables' CONFIG_SERIAL_ACPI
-fi
 if [ "$CONFIG_SERIAL_EXTENDED" = "y" ]; then
    bool '  Support more than 4 serial ports' CONFIG_SERIAL_MANY_PORTS
    bool '  Support for sharing serial interrupts' CONFIG_SERIAL_SHARE_IRQ
diff -urN --exclude-from=diff_exclude_file linux-2.4.18-ia64/drivers/char/acpi_serial.c linux-2.4.18-ia64-hcdp/drivers/char/acpi_serial.c
--- linux-2.4.18-ia64/drivers/char/acpi_serial.c	Wed Nov 14 12:45:41 2001
+++ linux-2.4.18-ia64-hcdp/drivers/char/acpi_serial.c	Mon Jul 22 17:14:50 2002
@@ -15,13 +15,16 @@
 #include <linux/acpi.h>
 #include <linux/init.h>
 #include <linux/serial.h>
+#include <linux/serialP.h>
 #include <asm/serial.h>
 #include <asm/io.h>
 #include <linux/acpi_serial.h>
-/*#include <asm/acpi-ext.h>*/
 
 #undef SERIAL_DEBUG_ACPI
 
+extern struct serial_state rs_table[];
+extern int serial_nr_ports;
+
 /*
  * Query ACPI tables for a debug and a headless console serial
  * port. If found, add them to rs_table[]. A pointer to either SPCR
@@ -38,6 +41,7 @@
 	struct serial_struct serial_req;
 	unsigned long iobase;
 	int global_sys_irq;
+	int i, j;
 
 #ifdef SERIAL_DEBUG_ACPI
 	printk("Entering setup_serial_acpi()\n");
@@ -134,14 +138,6 @@
 			serial_req.type = PORT_UNKNOWN;
 			break;
 	}
-	if (strncmp(acpi_ser_p->signature, ACPI_SPCRT_SIGNATURE,
-					ACPI_SIG_LEN) == 0) {
-		serial_req.line = ACPI_SERIAL_CONSOLE_PORT;
-	}
-	else if (strncmp(acpi_ser_p->signature, ACPI_DBGPT_SIGNATURE, 
-					ACPI_SIG_LEN) == 0) {
-		serial_req.line = ACPI_SERIAL_DEBUG_PORT;
-	}
 	/*
 	 * Check if this is an I/O mapped address or a memory mapped address
 	 */
@@ -160,6 +156,52 @@
 	else if (acpi_ser_p->base_addr.space_id == ACPI_SERIAL_PCICONF_SPACE) {
 		printk("WARNING: No support for PCI serial console\n");
 		return;
+	}
+
+	/*
+	 * Check if SPCR/DBGP define a port already in rs_table
+	 */
+	for (i = 0; i < serial_nr_ports; i++) {
+		if ((rs_table[i].port == serial_req.port) &&
+			(rs_table[i].iomem_base == serial_req.iomem_base))
+			break;
+	}
+	if (i == serial_nr_ports) {
+		if (strncmp(acpi_ser_p->signature, ACPI_SPCRT_SIGNATURE,
+						ACPI_SIG_LEN) == 0) {
+			/*
+			 * We have reserved a slot for ACPI defined 
+			 * console  port at ACPI_SERIAL_CONSOLE_PORT
+			 * in rs_table which is not 0. This means 
+			 * using this slot would put the console at
+			 * a device other than ttyS0. Users expect
+			 * to see the console at ttyS0. Now that we 
+			 * have determined SPCR does describe a 
+			 * serial console and it is not one of the
+			 * compiled in ports, let us move the entries 
+			 * in rs_table up by a slot towards  
+			 * ACPI_SERIAL_CONSOLE_PORT to make room for
+			 * the  SPCR console at ttyS0.
+			 */
+			for (j=ACPI_SERIAL_CONSOLE_PORT; j>0; j--)
+				memcpy(rs_table+j, rs_table+j-1,
+					sizeof(struct serial_state));
+
+			serial_req.line = 0;
+		}
+		else if (strncmp(acpi_ser_p->signature, ACPI_DBGPT_SIGNATURE, 
+						ACPI_SIG_LEN) == 0) {
+			/*
+			 * See the comments above in the comment block for 
+			 * ACPI_SERIAL_CONSOLE_PORT
+			 */
+			for (j=ACPI_SERIAL_DEBUG_PORT; j>1; j--)
+					memcpy(rs_table+j, rs_table+j-1, sizeof(struct serial_state));
+			serial_req.line = 1;
+		}
+	}
+	else {
+		serial_req.line = i;
 	}
 
 	/*
diff -urN --exclude-from=diff_exclude_file linux-2.4.18-ia64/drivers/char/hcdp_serial.c linux-2.4.18-ia64-hcdp/drivers/char/hcdp_serial.c
--- linux-2.4.18-ia64/drivers/char/hcdp_serial.c	Mon Jul 22 09:50:39 2002
+++ linux-2.4.18-ia64-hcdp/drivers/char/hcdp_serial.c	Mon Jul 22 17:14:59 2002
@@ -25,6 +25,8 @@
 extern struct serial_state rs_table[];
 extern int serial_nr_ports;
 
+int hcdp_initialized = 0;
+
 /*
  * Parse the HCDP table to find descriptions for headless console and 
  * debug serial ports and add them to rs_table[]. A pointer to HCDP
@@ -207,9 +209,10 @@
 			printk("setup_serial_hcdp(): early_serial_setup() for HCDP serial console port failed. Will try any additional consoles in HCDP.\n");
 			continue;
 		}
-		else
-			if (hcdp_dev->type == HCDP_DEV_CONSOLE)
-				break;
+		else {
+			hcdp_initialized = 1;
+			break;
+		}
 #ifdef SERIAL_DEBUG_HCDP
 		printk("\n");
 #endif

--------------C25F4C6978DB19E945AD3972--


