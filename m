From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Thu, 03 Jun 2004 21:49:07 +0000
Subject: [PATCH] early console registration
Message-Id: <200406031449.07627.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_Tz5vAQsgVTDHLr4"
List-Id: <linux-ia64.vger.kernel.org>
References: <200405141425.59867.jbarnes@engr.sgi.com>
In-Reply-To: <200405141425.59867.jbarnes@engr.sgi.com>
To: linux-ia64@vger.kernel.org


--Boundary-00=_Tz5vAQsgVTDHLr4
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Here's an updated early console registration patch, how does it look?  There's 
another piece to update the sn2 console driver with support for it, but I can 
send that straight to Andrew.  I think Bjorn has a similar patch for the zx1 
console.

Allow consoles to be registered early if they support doing output very early 
in the boot process.  Consoles that allow this are subject to the limitations 
outlined in the comments for the early_console_setup routine.

Thanks,
Jesse

--Boundary-00=_Tz5vAQsgVTDHLr4
Content-Type: text/plain;
  charset="us-ascii";
  name="early-printk-2.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="early-printk-2.patch"

===== arch/ia64/kernel/setup.c 1.71 vs edited =====
--- 1.71/arch/ia64/kernel/setup.c	Fri May 14 19:00:11 2004
+++ edited/arch/ia64/kernel/setup.c	Thu Jun  3 14:39:40 2004
@@ -280,6 +280,36 @@
 }
 #endif
 
+/**
+ * early_console_setup - setup debugging console
+ *
+ * Consoles started here require little enough setup that we can start using
+ * them very early in the boot process, either right after the machine
+ * vector initialization, or even before if the drivers can detect their hw.
+ *
+ * Since these drivers are initialized and called very early on in the boot
+ * process, some services are unavailable until the system is up:
+ *   o memory allocation
+ *   o per-cpu data
+ *   o interrupts
+ * The driver is free to have an initcall that switches the console ops
+ * though, as is done in the sn2 console driver.
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
@@ -296,6 +326,10 @@
 #ifdef CONFIG_IA64_GENERIC
 	machvec_init(acpi_get_sysname());
 #endif
+
+	/* If we register an early console, allow CPU 0 to printk */
+	if (!early_console_setup())
+		cpu_set(smp_processor_id(), cpu_online_map);
 
 #ifdef CONFIG_ACPI_BOOT
 	/* Initialize the ACPI boot-time table parser */

--Boundary-00=_Tz5vAQsgVTDHLr4--
