From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Fri, 07 May 2004 23:32:50 +0000
Subject: [PATCH] working early printk
Message-Id: <200405071632.50291.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_iyBnAq4eB6KK4Dz"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--Boundary-00=_iyBnAq4eB6KK4Dz
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Bjorn, does this look like what you had in mind?

Early printk is currently broken due to the removal (quite some time ago) of 
arch_consoles_callable.  This patch re-introduces a flag that can be used by 
printk() to determine whether early printing is ok.  The flag is intended to 
be set by arch code after early console init is done.  It adds an early 
console setup routine for ia64 that can be used by drivers that support early 
printk.

Ideas?

Thanks,
Jesse

--Boundary-00=_iyBnAq4eB6KK4Dz
Content-Type: text/plain;
  charset="us-ascii";
  name="early-printk-sn.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="early-printk-sn.patch"

===== arch/ia64/kernel/setup.c 1.70 vs edited =====
--- 1.70/arch/ia64/kernel/setup.c	Wed Mar 17 04:46:59 2004
+++ edited/arch/ia64/kernel/setup.c	Fri May  7 16:26:25 2004
@@ -280,6 +280,24 @@
 }
 #endif
 
+/**
+ * early_console_setup - setup debugging console
+ *
+ * Consoles started here require little enough setup that we can start using
+ * them very early in the boot process, either right after the machine
+ * vector initialization, or even before if the drivers are smart enough
+ * to detect their hw.
+ *
+ * Returns non-zero if a console couldn't be setup.
+ */
+static int __init early_console_setup(void)
+{
+	extern void sn_serial_console_early_setup(void);
+
+	sn_serial_console_early_setup();
+	return 0;
+}
+
 void __init
 setup_arch (char **cmdline_p)
 {
@@ -296,6 +314,9 @@
 #ifdef CONFIG_IA64_GENERIC
 	machvec_init(acpi_get_sysname());
 #endif
+
+	if (!early_console_setup())
+		early_printk_ok = 1;
 
 #ifdef CONFIG_ACPI_BOOT
 	/* Initialize the ACPI boot-time table parser */
===== drivers/char/sn_serial.c 1.11 vs edited =====
--- 1.11/drivers/char/sn_serial.c	Mon Mar 29 02:48:14 2004
+++ edited/drivers/char/sn_serial.c	Fri May  7 16:22:05 2004
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
@@ -941,6 +931,42 @@
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
+void __init
+sn_serial_console_early_setup(void)
+{
+	if (!sn_func) {
+		if (IS_RUNNING_ON_SIMULATOR())
+			sn_func = &sim_ops;
+		else
+			sn_func = &poll_ops;
+
+		early_sn_setup(); /* Find SAL entry points */
+	}
+
+	register_console(&sal_console_early);
+}
+
 /*
  * Print a string to the SAL console.  The console_lock must be held
  * when we get here.
@@ -998,18 +1024,10 @@
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
 
@@ -1020,6 +1038,7 @@
 		sn_sal_switch_to_asynch();
 		DPRINTF("sn_sal_serial_console_init : register console\n");
 		register_console(&sal_console);
+		unregister_console(&sal_console_early);
 	}
 	return 0;
 }
===== include/asm-ia64/sn/sn_sal.h 1.8 vs edited =====
--- 1.8/include/asm-ia64/sn/sn_sal.h	Tue Apr 27 02:55:57 2004
+++ edited/include/asm-ia64/sn/sn_sal.h	Fri May  7 16:10:14 2004
@@ -130,6 +130,8 @@
 #define SN_SAL_MIN_MAJOR	0x1  /* SN2 kernels need at least PROM 1.0 */
 #define SN_SAL_MIN_MINOR	0x0
 
+void early_sn_setup(void);
+
 u64 ia64_sn_probe_io_slot(long paddr, long size, void *data_ptr);
 
 /*
===== include/linux/kernel.h 1.48 vs edited =====
--- 1.48/include/linux/kernel.h	Mon Apr 12 10:53:58 2004
+++ edited/include/linux/kernel.h	Fri May  7 16:16:49 2004
@@ -107,6 +107,7 @@
 }
 
 extern void bust_spinlocks(int yes);
+extern int early_printk_ok;		/* If set, console drivers will be called even if the system isn't up yet */
 extern int oops_in_progress;		/* If set, an oops, panic(), BUG() or die() is in progress */
 extern int panic_on_oops;
 extern int system_state;		/* See values below */
===== kernel/printk.c 1.37 vs edited =====
--- 1.37/kernel/printk.c	Tue May  4 10:48:06 2004
+++ edited/kernel/printk.c	Fri May  7 15:01:33 2004
@@ -54,6 +54,7 @@
 EXPORT_SYMBOL(console_printk);
 
 int oops_in_progress;
+int early_printk_ok;
 
 /*
  * console_sem protects the console_drivers list, and also
@@ -526,7 +527,7 @@
 			log_level_unknown = 1;
 	}
 
-	if (!cpu_online(smp_processor_id()) &&
+	if (!early_printk_ok && !cpu_online(smp_processor_id()) &&
 	    system_state != SYSTEM_RUNNING) {
 		/*
 		 * Some console drivers may assume that per-cpu resources have

--Boundary-00=_iyBnAq4eB6KK4Dz--
