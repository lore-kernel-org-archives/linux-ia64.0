From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Fri, 14 May 2004 21:25:59 +0000
Subject: [PATCH] early console registration
Message-Id: <200405141425.59867.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_nlTpA1C/aOahcM/"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--Boundary-00=_nlTpA1C/aOahcM/
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Here's another patch that just sets the bit corresponding to the boot CPU in 
the cpu_online_map if we successfully register an early console.  The 
early_console_setup routine is simple, and I'd expect additions of the form:

...
#ifdef CONFIG_SGI_L1_SERIAL_CONSOLE
	{
		extern int sn_serial_console_early_setup(void);
		if (!sn_serial_console_early_setup())
			return 0;
	}
#endif
...
#ifdef CONFIG_FOO_CONSOLE
	{
		extern int foo_early_setup(void);
		if (!foo_early_setup())
			return 0;
	}
#endif
...
etc.

Is this reasonable?  I've tested it on a couple of machines here and it works 
well.  It's really useful for debugging setup_arch problems.

Thanks,
Jesse


--Boundary-00=_nlTpA1C/aOahcM/
Content-Type: text/plain;
  charset="us-ascii";
  name="early-printk-sn-3.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="early-printk-sn-3.patch"

===== arch/ia64/kernel/setup.c 1.70 vs edited =====
--- 1.70/arch/ia64/kernel/setup.c	Wed Mar 17 04:46:59 2004
+++ edited/arch/ia64/kernel/setup.c	Fri May 14 14:11:29 2004
@@ -280,6 +280,28 @@
 }
 #endif
 
+/**
+ * early_console_setup - setup debugging console
+ *
+ * Consoles started here require little enough setup that we can start using
+ * them very early in the boot process, either right after the machine
+ * vector initialization, or even before if the drivers can detect their hw.
+ *
+ * Returns non-zero if a console couldn't be setup.
+ */
+static int __init early_console_setup(void)
+{
+#ifdef CONFIG_SGI_L1_SERIAL_CONSOLE
+	{
+		extern int sn_serial_console_early_setup(void);
+		if(!sn_serial_console_early_setup())
+			return 0;
+	}
+#endif
+
+	return -1;
+}
+
 void __init
 setup_arch (char **cmdline_p)
 {
@@ -296,6 +318,10 @@
 #ifdef CONFIG_IA64_GENERIC
 	machvec_init(acpi_get_sysname());
 #endif
+
+	/* If we register an early console, allow CPU 0 to printk */
+	if (!early_console_setup())
+		cpu_set(smp_processor_id(), cpu_online_map);
 
 #ifdef CONFIG_ACPI_BOOT
 	/* Initialize the ACPI boot-time table parser */
===== drivers/char/sn_serial.c 1.11 vs edited =====
--- 1.11/drivers/char/sn_serial.c	Mon Mar 29 02:48:14 2004
+++ edited/drivers/char/sn_serial.c	Fri May 14 14:00:05 2004
@@ -229,24 +229,6 @@
 	return ia64_sn_console_intr_status() & SAL_CONSOLE_INTR_RECV;
 }
 
-/* The early printk (possible setup) and function call */
-
-void
-early_printk_sn_sal(const char *s, unsigned count)
-{
-	extern void early_sn_setup(void);
-
-	if (!sn_func) {
-		if (IS_RUNNING_ON_SIMULATOR())
-			sn_func = &sim_ops;
-		else
-			sn_func = &poll_ops;
-
-		early_sn_setup();
-	}
-	sn_func->sal_puts(s, count);
-}
-
 #ifdef DEBUG
 /* this is as "close to the metal" as we can get, used when the driver
  * itself may be broken */
@@ -259,7 +241,15 @@
 
 	va_start(args, fmt);
 	printed_len = vscnprintf(printk_buf, sizeof(printk_buf), fmt, args);
-	early_printk_sn_sal(printk_buf, printed_len);
+	if (!sn_func) {
+		if (IS_RUNNING_ON_SIMULATOR())
+			sn_func = &sim_ops;
+		else
+			sn_func = &poll_ops;
+
+		early_sn_setup();
+	}
+	sn_func->sal_puts(printk_buf, printed_len);
 	va_end(args);
 	return printed_len;
 }
@@ -941,6 +931,45 @@
  */
 
 #ifdef CONFIG_SGI_L1_SERIAL_CONSOLE
+
+/*
+ * Very simple early output routine.  Assumes sn_func operation structure
+ * has arlready been setup by sn_serial_console_early_setup().
+ */
+static void __init
+sn_sal_console_write_early(struct console *co, const char *s, unsigned count)
+{
+	sn_func->sal_puts(s, count);
+}
+
+static struct console sal_console_early __initdata = {
+	.name = "sn_sal",
+	.write = sn_sal_console_write_early,
+	.flags = CON_PRINTBUFFER,
+	.index  = -1,
+};
+
+/*
+ * Register a console early on...
+ */
+int __init
+sn_serial_console_early_setup(void)
+{
+	if (!ia64_platform_is("sn2"))
+		return -1;
+
+	if (IS_RUNNING_ON_SIMULATOR())
+		sn_func = &sim_ops;
+	else
+		sn_func = &poll_ops;
+
+	early_sn_setup(); /* Find SAL entry points */
+
+	register_console(&sal_console_early);
+
+	return 0;
+}
+
 /*
  * Print a string to the SAL console.  The console_lock must be held
  * when we get here.
@@ -998,18 +1027,10 @@
 	return sn_sal_driver;
 }
 
-static int __init
-sn_sal_console_setup(struct console *co, char *options)
-{
-	return 0;
-}
-
-
 static struct console sal_console = {
 	.name = "ttyS",
 	.write = sn_sal_console_write,
 	.device = sn_sal_console_device,
-	.setup = sn_sal_console_setup,
 	.index = -1
 };
 
@@ -1020,6 +1041,7 @@
 		sn_sal_switch_to_asynch();
 		DPRINTF("sn_sal_serial_console_init : register console\n");
 		register_console(&sal_console);
+		unregister_console(&sal_console_early);
 	}
 	return 0;
 }

--Boundary-00=_nlTpA1C/aOahcM/--
