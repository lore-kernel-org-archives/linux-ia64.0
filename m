From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 10 Sep 2003 18:18:20 +0000
Subject: [PATCH] 2.4 HCDP early printk support
Message-Id: <marc-linux-ia64-106321887122161@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This adds config and HCDP support for early printk.  This is
currently used only by IA64, and the equivalent code is
already in 2.5.

=== Documentation/Configure.help 1.192 vs edited ==--- 1.192/Documentation/Configure.help	Wed Sep  3 18:40:00 2003
+++ edited/Documentation/Configure.help	Wed Sep 10 14:14:24 2003
@@ -27081,12 +27091,31 @@
   and restore instructions.  It's useful for tracking down spinlock
   problems, but slow!  If you're unsure, select N.
 
-Early printk support (requires VGA!)
+Early printk support
 CONFIG_IA64_EARLY_PRINTK
-  Selecting this option uses the VGA screen for printk() output before
-  the consoles are initialised.  It is useful for debugging problems
-  early in the boot process, but only if you have a VGA screen
-  attached.  If you're unsure, select N.
+  Selecting this option uses a UART or VGA screen (or both) for
+  printk() output before the consoles are initialised.  It is useful
+  for debugging problems early in the boot process, but only if you
+  have a serial terminal or a VGA screen attached.  If you're unsure,
+  select N.
+
+Early printk on serial port
+CONFIG_IA64_EARLY_PRINTK_UART
+  Select this option to use a serial port for early printk() output.
+  You must also select either CONFIG_IA64_EARLY_PRINTK_UART_BASE or
+  CONFIG_SERIAL_HCDP.  If you select CONFIG_SERIAL_HCDP, early
+  printk() output will appear on the first console device described by
+  the HCDP.  If you set CONFIG_IA64_EARLY_PRINTK_UART_BASE, the HCDP
+  will be ignored.
+
+UART base address
+CONFIG_IA64_EARLY_PRINTK_UART_BASE
+  The physical MMIO address of the UART to use for early printk().
+  This overrides any UART located using the EFI HCDP table.
+
+Early printk on VGA
+CONFIG_IA64_EARLY_PRINTK_VGA
+  Select this option to use VGA for early printk() output.
 
 Print possible IA64 hazards to console
 CONFIG_IA64_PRINT_HAZARDS
=== drivers/char/hcdp_serial.c 1.3 vs edited ==--- 1.3/drivers/char/hcdp_serial.c	Fri Sep 13 09:23:42 2002
+++ edited/drivers/char/hcdp_serial.c	Wed Sep 10 14:14:24 2003
@@ -219,3 +219,41 @@
 	printk("Leaving setup_serial_hcdp()\n");
 #endif
 }
+
+#ifdef CONFIG_IA64_EARLY_PRINTK_UART
+unsigned long hcdp_early_uart(void)
+{
+	efi_system_table_t *systab;
+	efi_config_table_t *config_tables;
+	hcdp_t *hcdp = 0;
+	hcdp_dev_t *dev;
+	int i;
+
+	systab = (efi_system_table_t *) ia64_boot_param->efi_systab;
+	if (!systab)
+		return 0;
+	systab = __va(systab);
+
+	config_tables = (efi_config_table_t *) systab->tables;
+	if (!config_tables)
+		return 0;
+	config_tables = __va(config_tables);
+
+	for (i = 0; i < systab->nr_tables; i++) {
+		if (efi_guidcmp(config_tables[i].guid, HCDP_TABLE_GUID) = 0) {
+			hcdp = (hcdp_t *) config_tables[i].table;
+			break;
+		}
+	}
+	if (!hcdp)
+		return 0;
+	hcdp = __va(hcdp);
+
+	for (i = 0, dev = hcdp->hcdp_dev; i < hcdp->num_entries; i++, dev++) {
+		if (dev->type = HCDP_DEV_CONSOLE)
+			return (u64) dev->base_addr.addrhi << 32
+				| dev->base_addr.addrlo;
+	}
+	return 0;
+}
+#endif

