From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 17 Mar 2004 20:06:01 +0000
Subject: [PATCH] init IO port space, IO accessors earlier
Message-Id: <200403171306.01728.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This is a minor patch to get things setup so consoles can
work earlier.  (No change to consoles here, I just split this
out to make the diff easier to read.)

(io_port_init): New function, same old code to setup ia64_iobase
	and legacy IO port space.
(setup_arch): Call io_port_init() and machvec_init() as early as
	possible so consoles can work earlier.

=== arch/ia64/kernel/setup.c 1.69 vs edited ==--- 1.69/arch/ia64/kernel/setup.c	Mon Mar 15 07:20:19 2004
+++ edited/arch/ia64/kernel/setup.c	Wed Mar 17 12:46:59 2004
@@ -229,6 +229,38 @@
 #endif
 }
 
+static void __init
+io_port_init (void)
+{
+	extern unsigned long ia64_iobase;
+	unsigned long phys_iobase;
+
+	/*
+	 *  Set `iobase' to the appropriate address in region 6 (uncached access range).
+	 *
+	 *  The EFI memory map is the "preferred" location to get the I/O port space base,
+	 *  rather the relying on AR.KR0. This should become more clear in future SAL
+	 *  specs. We'll fall back to getting it out of AR.KR0 if no appropriate entry is
+	 *  found in the memory map.
+	 */
+	phys_iobase = efi_get_iobase();
+	if (phys_iobase)
+		/* set AR.KR0 since this is all we use it for anyway */
+		ia64_set_kr(IA64_KR_IO_BASE, phys_iobase);
+	else {
+		phys_iobase = ia64_get_kr(IA64_KR_IO_BASE);
+		printk(KERN_INFO "No I/O port range found in EFI memory map, falling back "
+		       "to AR.KR0\n");
+		printk(KERN_INFO "I/O port base = 0x%lx\n", phys_iobase);
+	}
+	ia64_iobase = (unsigned long) ioremap(phys_iobase, 0);
+
+	/* setup legacy IO port space */
+	io_space[0].mmio_base = ia64_iobase;
+	io_space[0].sparse = 1;
+	num_io_spaces = 1;
+}
+
 #ifdef CONFIG_SERIAL_8250_CONSOLE
 static void __init
 setup_serial_legacy (void)
@@ -251,9 +283,6 @@
 void __init
 setup_arch (char **cmdline_p)
 {
-	extern unsigned long ia64_iobase;
-	unsigned long phys_iobase;
-
 	unw_init();
 
 	ia64_patch_vtop((u64) __start___vtop_patchlist, (u64) __end___vtop_patchlist);
@@ -262,6 +291,11 @@
 	strlcpy(saved_command_line, *cmdline_p, sizeof(saved_command_line));
 
 	efi_init();
+	io_port_init();
+
+#ifdef CONFIG_IA64_GENERIC
+	machvec_init(acpi_get_sysname());
+#endif
 
 #ifdef CONFIG_ACPI_BOOT
 	/* Initialize the ACPI boot-time table parser */
@@ -279,35 +313,6 @@
 
 	/* process SAL system table: */
 	ia64_sal_init(efi.sal_systab);
-
-#ifdef CONFIG_IA64_GENERIC
-	machvec_init(acpi_get_sysname());
-#endif
-
-	/*
-	 *  Set `iobase' to the appropriate address in region 6 (uncached access range).
-	 *
-	 *  The EFI memory map is the "preferred" location to get the I/O port space base,
-	 *  rather the relying on AR.KR0. This should become more clear in future SAL
-	 *  specs. We'll fall back to getting it out of AR.KR0 if no appropriate entry is
-	 *  found in the memory map.
-	 */
-	phys_iobase = efi_get_iobase();
-	if (phys_iobase)
-		/* set AR.KR0 since this is all we use it for anyway */
-		ia64_set_kr(IA64_KR_IO_BASE, phys_iobase);
-	else {
-		phys_iobase = ia64_get_kr(IA64_KR_IO_BASE);
-		printk(KERN_INFO "No I/O port range found in EFI memory map, falling back "
-		       "to AR.KR0\n");
-		printk(KERN_INFO "I/O port base = 0x%lx\n", phys_iobase);
-	}
-	ia64_iobase = (unsigned long) ioremap(phys_iobase, 0);
-
-	/* setup legacy IO port space */
-	io_space[0].mmio_base = ia64_iobase;
-	io_space[0].sparse = 1;
-	num_io_spaces = 1;
 
 #ifdef CONFIG_SMP
 	cpu_physical_id(0) = hard_smp_processor_id();

