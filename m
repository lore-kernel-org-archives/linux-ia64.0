From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Tue, 22 Jun 2004 17:54:27 +0000
Subject: [PATCH] early console registration
Message-Id: <200406221354.27322.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_TJH2ACZ2fhvt9rc"
List-Id: <linux-ia64.vger.kernel.org>
References: <200405141425.59867.jbarnes@engr.sgi.com>
In-Reply-To: <200405141425.59867.jbarnes@engr.sgi.com>
To: linux-ia64@vger.kernel.org


--Boundary-00=_TJH2ACZ2fhvt9rc
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

> > But AFAIK, there is no such code now, and I don't have any better ideas,
> > so maybe we should just go with your ia64-specific patch for now.
>
> Sounds good to me.

Bjorn is ok with it, so here it is again.  Pat, can you fix up the #ifdef 
check for your new driver when it gets in?  You should be able to reuse the 
function name...

Allow consoles to register early if they're capable of early output.  If one 
of them registers successfully, set CPU 0 online so that printk() will 
actually call the console drivers.

Drivers that are capable of early output can add themselves to the 
early_console_setup routine in the following form:

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

Signed-off-by: Jesse Barnes <jbarnes@sgi.com>

Thanks,
Jesse

--Boundary-00=_TJH2ACZ2fhvt9rc
Content-Type: text/x-diff;
  charset="iso-8859-1";
  name="early-console-setup.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="early-console-setup.patch"

===== arch/ia64/kernel/setup.c 1.74 vs edited =====
--- 1.74/arch/ia64/kernel/setup.c	2004-06-05 01:15:10 -04:00
+++ edited/arch/ia64/kernel/setup.c	2004-06-22 13:51:27 -04:00
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

--Boundary-00=_TJH2ACZ2fhvt9rc--
