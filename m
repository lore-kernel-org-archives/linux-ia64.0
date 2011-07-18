From: Prarit Bhargava <prarit@redhat.com>
Date: Mon, 18 Jul 2011 13:08:17 +0000
Subject: [PATCH 03/34] arch specific changes for SMBIOS and System Firmware
Message-Id: <1310994528-26276-4-git-send-email-prarit@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1310994528-26276-1-git-send-email-prarit@redhat.com>
In-Reply-To: <1310994528-26276-1-git-send-email-prarit@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-kernel@vger.kernel.org
Cc: Prarit Bhargava <prarit@redhat.com>, linux-ia64@vger.kernel.org, x86@kernel.org

As part of the new SMBIOS and System Firmware code:

- add in ia64 and x86 calls to initialize SMBIOS
- Replace old dmi* structures and functions with new sysfw* and smbios*
structures and functions in individual drivers
- cleanup sysfw_id lookup tables
- cleanup of includes for dmi.h and mod_devicetable.h which were included in
some files that did not need them

Cc: linux-ia64@vger.kernel.org
Cc: x86@kernel.org
Signed-off-by: Prarit Bhargava <prarit@redhat.com>
---
 arch/ia64/kernel/setup.c           |    8 +-
 arch/x86/include/asm/mmconfig.h    |    4 +-
 arch/x86/include/asm/pci_x86.h     |    6 +-
 arch/x86/kernel/acpi/boot.c        |  177 ++++++++--------
 arch/x86/kernel/acpi/sleep.c       |    1 -
 arch/x86/kernel/apic/apic.c        |   20 +-
 arch/x86/kernel/apic/bigsmp_32.c   |   37 ++--
 arch/x86/kernel/apm_32.c           |  391 ++++++++++++++++++++++----------=
----
 arch/x86/kernel/cpu/amd.c          |    2 +-
 arch/x86/kernel/cpu/vmware.c       |   17 ++-
 arch/x86/kernel/io_delay.c         |   42 ++--
 arch/x86/kernel/mmconf-fam10h_64.c |   28 ++--
 arch/x86/kernel/probe_roms.c       |    1 -
 arch/x86/kernel/process.c          |    8 +-
 arch/x86/kernel/reboot.c           |  132 +++++++------
 arch/x86/kernel/setup.c            |   14 +-
 arch/x86/kernel/tsc.c              |   16 +-
 arch/x86/pci/acpi.c                |   18 +-
 arch/x86/pci/broadcom_bus.c        |    1 -
 arch/x86/pci/common.c              |  163 ++++++++--------
 arch/x86/pci/direct.c              |    7 +-
 arch/x86/pci/fixup.c               |   33 ++--
 arch/x86/pci/init.c                |    4 +-
 arch/x86/pci/irq.c                 |   26 ++--
 arch/x86/pci/mmconfig-shared.c     |   10 +-
 arch/x86/pci/mrst.c                |    1 -
 drivers/cpufreq/acpi-cpufreq.c     |   16 +-
 drivers/cpufreq/powernow-k7.c      |   14 +-
 28 files changed, 657 insertions(+), 540 deletions(-)

diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
index 5e2c724..e170fcc 100644
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -36,7 +36,7 @@
 #include <linux/string.h>
 #include <linux/threads.h>
 #include <linux/screen_info.h>
-#include <linux/dmi.h>
+#include <linux/smbios.h>
 #include <linux/serial.h>
 #include <linux/serial_core.h>
 #include <linux/efi.h>
@@ -1043,9 +1043,9 @@ check_bugs (void)
 			       (unsigned long) __end___mckinley_e9_bundles);
 }
=20
-static int __init run_dmi_scan(void)
+static int __init run_smbios_scan(void)
 {
-	dmi_scan_machine();
+	smbios_init();
 	return 0;
 }
-core_initcall(run_dmi_scan);
+core_initcall(run_smbios_scan);
diff --git a/arch/x86/include/asm/mmconfig.h b/arch/x86/include/asm/mmconfi=
g.h
index 9b119da..1831965 100644
--- a/arch/x86/include/asm/mmconfig.h
+++ b/arch/x86/include/asm/mmconfig.h
@@ -3,10 +3,10 @@
=20
 #ifdef CONFIG_PCI_MMCONFIG
 extern void __cpuinit fam10h_check_enable_mmcfg(void);
-extern void __cpuinit check_enable_amd_mmconf_dmi(void);
+extern void __cpuinit check_enable_amd_pci_mmconf(void);
 #else
 static inline void fam10h_check_enable_mmcfg(void) { }
-static inline void check_enable_amd_mmconf_dmi(void) { }
+static inline void check_enable_amd_pci_mmconf(void) { }
 #endif
=20
 #endif /* _ASM_X86_MMCONFIG_H */
diff --git a/arch/x86/include/asm/pci_x86.h b/arch/x86/include/asm/pci_x86.h
index 7045267..28e3f3a 100644
--- a/arch/x86/include/asm/pci_x86.h
+++ b/arch/x86/include/asm/pci_x86.h
@@ -39,7 +39,7 @@ enum pci_bf_sort_state {
 	pci_bf_sort_default,
 	pci_force_nobf,
 	pci_force_bf,
-	pci_dmi_bf,
+	pci_smbios_bf,
 };
=20
 /* pci-i386.c */
@@ -109,8 +109,8 @@ extern bool port_cf9_safe;
 extern int pci_direct_probe(void);
 extern void pci_direct_init(int type);
 extern void pci_pcbios_init(void);
-extern void __init dmi_check_pciprobe(void);
-extern void __init dmi_check_skip_isa_align(void);
+extern void __init smbios_check_pciprobe(void);
+extern void __init smbios_check_skip_isa_align(void);
=20
 /* some common used subsys_initcalls */
 extern int __init pci_acpi_init(void);
diff --git a/arch/x86/kernel/acpi/boot.c b/arch/x86/kernel/acpi/boot.c
index 4558f0d..180d4c7 100644
--- a/arch/x86/kernel/acpi/boot.c
+++ b/arch/x86/kernel/acpi/boot.c
@@ -29,7 +29,7 @@
 #include <linux/efi.h>
 #include <linux/cpumask.h>
 #include <linux/module.h>
-#include <linux/dmi.h>
+#include <linux/sysfw.h>
 #include <linux/irq.h>
 #include <linux/slab.h>
 #include <linux/bootmem.h>
@@ -1294,7 +1294,7 @@ static void __init acpi_process_madt(void)
 	return;
 }
=20
-static int __init disable_acpi_irq(const struct dmi_system_id *d)
+static int __init disable_acpi_irq(const struct sysfw_id *d)
 {
 	if (!acpi_force) {
 		printk(KERN_NOTICE "%s detected: force use of acpi=3Dnoirq\n",
@@ -1304,7 +1304,7 @@ static int __init disable_acpi_irq(const struct dmi_s=
ystem_id *d)
 	return 0;
 }
=20
-static int __init disable_acpi_pci(const struct dmi_system_id *d)
+static int __init disable_acpi_pci(const struct sysfw_id *d)
 {
 	if (!acpi_force) {
 		printk(KERN_NOTICE "%s detected: force use of pci=3Dnoacpi\n",
@@ -1314,14 +1314,14 @@ static int __init disable_acpi_pci(const struct dmi=
_system_id *d)
 	return 0;
 }
=20
-static int __init dmi_disable_acpi(const struct dmi_system_id *d)
+static int __init id_disable_acpi(const struct sysfw_id *d)
 {
 	if (!acpi_force) {
 		printk(KERN_NOTICE "%s detected: acpi off\n", d->ident);
 		disable_acpi();
 	} else {
-		printk(KERN_NOTICE
-		       "Warning: DMI blacklist says broken, but acpi forced\n");
+		printk(KERN_NOTICE "Warning: SMBIOS blacklist says broken, "
+		       "but acpi forced\n");
 	}
 	return 0;
 }
@@ -1329,7 +1329,8 @@ static int __init dmi_disable_acpi(const struct dmi_s=
ystem_id *d)
 /*
  * Force ignoring BIOS IRQ0 pin2 override
  */
-static int __init dmi_ignore_irq0_timer_override(const struct dmi_system_i=
d *d)
+static int __init
+id_ignore_irq0_timer_override(const struct sysfw_id *d)
 {
 	/*
 	 * The ati_ixp4x0_rev() early PCI quirk should have set
@@ -1348,33 +1349,32 @@ static int __init dmi_ignore_irq0_timer_override(co=
nst struct dmi_system_id *d)
  * If your system is blacklisted here, but you find that acpi=3Dforce
  * works for you, please contact linux-acpi@vger.kernel.org
  */
-static struct dmi_system_id __initdata acpi_dmi_table[] =3D {
+static struct sysfw_id __initdata acpi_id_table[] =3D {
 	/*
 	 * Boxes that need ACPI disabled
 	 */
 	{
-	 .callback =3D dmi_disable_acpi,
-	 .ident =3D "IBM Thinkpad",
-	 .matches =3D {
-		     DMI_MATCH(DMI_BOARD_VENDOR, "IBM"),
-		     DMI_MATCH(DMI_BOARD_NAME, "2629H1G"),
-		     },
+		.callback =3D id_disable_acpi,
+		.ident =3D "IBM Thinkpad",
+		.matches =3D {
+			     SYSFW_MATCH(SYSFW_BOARD_VENDOR, "IBM"),
+			     SYSFW_MATCH(SYSFW_BOARD_NAME, "2629H1G"),
+		},
 	 },
-
 	/*
 	 * Boxes that need ACPI PCI IRQ routing disabled
 	 */
 	{
-	 .callback =3D disable_acpi_irq,
-	 .ident =3D "ASUS A7V",
-	 .matches =3D {
-		     DMI_MATCH(DMI_BOARD_VENDOR, "ASUSTeK Computer INC"),
-		     DMI_MATCH(DMI_BOARD_NAME, "<A7V>"),
-		     /* newer BIOS, Revision 1011, does work */
-		     DMI_MATCH(DMI_BIOS_VERSION,
-			       "ASUS A7V ACPI BIOS Revision 1007"),
-		     },
-	 },
+		.callback =3D disable_acpi_irq,
+		.ident =3D "ASUS A7V",
+		.matches =3D {
+			SYSFW_MATCH(SYSFW_BOARD_VENDOR, "ASUSTeK Computer INC"),
+			SYSFW_MATCH(SYSFW_BOARD_NAME, "<A7V>"),
+			/* newer BIOS, Revision 1011, does work */
+			SYSFW_MATCH(SYSFW_BIOS_VERSION,
+				    "ASUS A7V ACPI BIOS Revision 1007"),
+			},
+	},
 	{
 		/*
 		 * Latest BIOS for IBM 600E (1.16) has bad pcinum
@@ -1382,48 +1382,49 @@ static struct dmi_system_id __initdata acpi_dmi_tab=
le[] =3D {
 		 * interrupt links to work. DSDT fix is in bug 5966.
 		 * 2645, 2646 model numbers are shared with 600/600E/600X
 		 */
-	 .callback =3D disable_acpi_irq,
-	 .ident =3D "IBM Thinkpad 600 Series 2645",
-	 .matches =3D {
-		     DMI_MATCH(DMI_BOARD_VENDOR, "IBM"),
-		     DMI_MATCH(DMI_BOARD_NAME, "2645"),
-		     },
-	 },
+		.callback =3D disable_acpi_irq,
+		.ident =3D "IBM Thinkpad 600 Series 2645",
+		.matches =3D {
+			SYSFW_MATCH(SYSFW_BOARD_VENDOR, "IBM"),
+			SYSFW_MATCH(SYSFW_BOARD_NAME, "2645"),
+		},
+	},
 	{
-	 .callback =3D disable_acpi_irq,
-	 .ident =3D "IBM Thinkpad 600 Series 2646",
-	 .matches =3D {
-		     DMI_MATCH(DMI_BOARD_VENDOR, "IBM"),
-		     DMI_MATCH(DMI_BOARD_NAME, "2646"),
-		     },
-	 },
+		.callback =3D disable_acpi_irq,
+		.ident =3D "IBM Thinkpad 600 Series 2646",
+		.matches =3D {
+			SYSFW_MATCH(SYSFW_BOARD_VENDOR, "IBM"),
+			SYSFW_MATCH(SYSFW_BOARD_NAME, "2646"),
+		},
+	},
 	/*
 	 * Boxes that need ACPI PCI IRQ routing and PCI scan disabled
 	 */
 	{			/* _BBN 0 bug */
-	 .callback =3D disable_acpi_pci,
-	 .ident =3D "ASUS PR-DLS",
-	 .matches =3D {
-		     DMI_MATCH(DMI_BOARD_VENDOR, "ASUSTeK Computer INC."),
-		     DMI_MATCH(DMI_BOARD_NAME, "PR-DLS"),
-		     DMI_MATCH(DMI_BIOS_VERSION,
-			       "ASUS PR-DLS ACPI BIOS Revision 1010"),
-		     DMI_MATCH(DMI_BIOS_DATE, "03/21/2003")
-		     },
-	 },
+		.callback =3D disable_acpi_pci,
+		.ident =3D "ASUS PR-DLS",
+		.matches =3D {
+			SYSFW_MATCH(SYSFW_BOARD_VENDOR,
+				    "ASUSTeK Computer INC."),
+			SYSFW_MATCH(SYSFW_BOARD_NAME, "PR-DLS"),
+			SYSFW_MATCH(SYSFW_BIOS_VERSION,
+				    "ASUS PR-DLS ACPI BIOS Revision 1010"),
+			SYSFW_MATCH(SYSFW_BIOS_DATE, "03/21/2003")
+		},
+	},
 	{
-	 .callback =3D disable_acpi_pci,
-	 .ident =3D "Acer TravelMate 36x Laptop",
-	 .matches =3D {
-		     DMI_MATCH(DMI_SYS_VENDOR, "Acer"),
-		     DMI_MATCH(DMI_PRODUCT_NAME, "TravelMate 360"),
-		     },
-	 },
+		.callback =3D disable_acpi_pci,
+		.ident =3D "Acer TravelMate 36x Laptop",
+		.matches =3D {
+			SYSFW_MATCH(SYSFW_SYS_VENDOR, "Acer"),
+			SYSFW_MATCH(SYSFW_PRODUCT_NAME, "TravelMate 360"),
+			},
+		},
 	{}
 };
=20
-/* second table for DMI checks that should run after early-quirks */
-static struct dmi_system_id __initdata acpi_dmi_table_late[] =3D {
+/* second table for SMBIOS checks that should run after early-quirks */
+static struct sysfw_id __initdata acpi_id_late[] =3D {
 	/*
 	 * HP laptops which use a DSDT reporting as HP/SB400/10000,
 	 * which includes some code which overrides all temperature
@@ -1435,37 +1436,37 @@ static struct dmi_system_id __initdata acpi_dmi_tab=
le_late[] =3D {
 	 * override in that cases.
 	 */
 	{
-	 .callback =3D dmi_ignore_irq0_timer_override,
-	 .ident =3D "HP nx6115 laptop",
-	 .matches =3D {
-		     DMI_MATCH(DMI_SYS_VENDOR, "Hewlett-Packard"),
-		     DMI_MATCH(DMI_PRODUCT_NAME, "HP Compaq nx6115"),
-		     },
-	 },
+		.callback =3D id_ignore_irq0_timer_override,
+		.ident =3D "HP nx6115 laptop",
+		.matches =3D {
+			SYSFW_MATCH(SYSFW_SYS_VENDOR, "Hewlett-Packard"),
+			SYSFW_MATCH(SYSFW_PRODUCT_NAME, "HP Compaq nx6115"),
+		},
+	},
 	{
-	 .callback =3D dmi_ignore_irq0_timer_override,
-	 .ident =3D "HP NX6125 laptop",
-	 .matches =3D {
-		     DMI_MATCH(DMI_SYS_VENDOR, "Hewlett-Packard"),
-		     DMI_MATCH(DMI_PRODUCT_NAME, "HP Compaq nx6125"),
-		     },
-	 },
+		.callback =3D id_ignore_irq0_timer_override,
+		.ident =3D "HP NX6125 laptop",
+		.matches =3D {
+			SYSFW_MATCH(SYSFW_SYS_VENDOR, "Hewlett-Packard"),
+			SYSFW_MATCH(SYSFW_PRODUCT_NAME, "HP Compaq nx6125"),
+		},
+	},
 	{
-	 .callback =3D dmi_ignore_irq0_timer_override,
-	 .ident =3D "HP NX6325 laptop",
-	 .matches =3D {
-		     DMI_MATCH(DMI_SYS_VENDOR, "Hewlett-Packard"),
-		     DMI_MATCH(DMI_PRODUCT_NAME, "HP Compaq nx6325"),
-		     },
-	 },
+		.callback =3D id_ignore_irq0_timer_override,
+		.ident =3D "HP NX6325 laptop",
+		.matches =3D {
+			SYSFW_MATCH(SYSFW_SYS_VENDOR, "Hewlett-Packard"),
+			SYSFW_MATCH(SYSFW_PRODUCT_NAME, "HP Compaq nx6325"),
+		},
+	},
 	{
-	 .callback =3D dmi_ignore_irq0_timer_override,
-	 .ident =3D "HP 6715b laptop",
-	 .matches =3D {
-		     DMI_MATCH(DMI_SYS_VENDOR, "Hewlett-Packard"),
-		     DMI_MATCH(DMI_PRODUCT_NAME, "HP Compaq 6715b"),
-		     },
-	 },
+		.callback =3D id_ignore_irq0_timer_override,
+		.ident =3D "HP 6715b laptop",
+		.matches =3D {
+			SYSFW_MATCH(SYSFW_SYS_VENDOR, "Hewlett-Packard"),
+			SYSFW_MATCH(SYSFW_PRODUCT_NAME, "HP Compaq 6715b"),
+		},
+	},
 	{}
 };
=20
@@ -1490,7 +1491,7 @@ static struct dmi_system_id __initdata acpi_dmi_table=
_late[] =3D {
=20
 void __init acpi_boot_table_init(void)
 {
-	dmi_check_system(acpi_dmi_table);
+	sysfw_callback(acpi_id_table);
=20
 	/*
 	 * If acpi_disabled, bail out
@@ -1541,7 +1542,7 @@ int __init early_acpi_boot_init(void)
 int __init acpi_boot_init(void)
 {
 	/* those are executed after early-quirks are executed */
-	dmi_check_system(acpi_dmi_table_late);
+	sysfw_callback(acpi_id_late);
=20
 	/*
 	 * If acpi_disabled, bail out
diff --git a/arch/x86/kernel/acpi/sleep.c b/arch/x86/kernel/acpi/sleep.c
index 103b6ab..c96b82d 100644
--- a/arch/x86/kernel/acpi/sleep.c
+++ b/arch/x86/kernel/acpi/sleep.c
@@ -8,7 +8,6 @@
 #include <linux/acpi.h>
 #include <linux/bootmem.h>
 #include <linux/memblock.h>
-#include <linux/dmi.h>
 #include <linux/cpumask.h>
 #include <asm/segment.h>
 #include <asm/desc.h>
diff --git a/arch/x86/kernel/apic/apic.c b/arch/x86/kernel/apic/apic.c
index b9338b8..a3a176d 100644
--- a/arch/x86/kernel/apic/apic.c
+++ b/arch/x86/kernel/apic/apic.c
@@ -30,7 +30,7 @@
 #include <linux/dmar.h>
 #include <linux/init.h>
 #include <linux/cpu.h>
-#include <linux/dmi.h>
+#include <linux/sysfw.h>
 #include <linux/smp.h>
 #include <linux/mm.h>
=20
@@ -162,7 +162,7 @@ early_param("nox2apic", setup_nox2apic);
=20
 unsigned long mp_lapic_addr;
 int disable_apic;
-/* Disable local APIC timer from the kernel commandline or via dmi quirk */
+/* Disable local APIC timer from the kernel commandline or via smbios quir=
k */
 static int disable_apic_timer __initdata;
 /* Local APIC timer works in C2 */
 int local_apic_timer_c2_ok;
@@ -2231,7 +2231,7 @@ static int __cpuinit apic_cluster_num(void)
 static int __cpuinitdata multi_checked;
 static int __cpuinitdata multi;
=20
-static int __cpuinit set_multi(const struct dmi_system_id *d)
+static int __cpuinit set_multi(const struct sysfw_id *d)
 {
 	if (multi)
 		return 0;
@@ -2240,24 +2240,24 @@ static int __cpuinit set_multi(const struct dmi_sys=
tem_id *d)
 	return 0;
 }
=20
-static const __cpuinitconst struct dmi_system_id multi_dmi_table[] =3D {
+static const __cpuinitconst struct sysfw_id set_multi_table[] =3D {
 	{
 		.callback =3D set_multi,
 		.ident =3D "IBM System Summit2",
 		.matches =3D {
-			DMI_MATCH(DMI_SYS_VENDOR, "IBM"),
-			DMI_MATCH(DMI_PRODUCT_NAME, "Summit2"),
+			SYSFW_MATCH(SYSFW_SYS_VENDOR, "IBM"),
+			SYSFW_MATCH(SYSFW_PRODUCT_NAME, "Summit2"),
 		},
 	},
 	{}
 };
=20
-static void __cpuinit dmi_check_multi(void)
+static void __cpuinit check_set_multi(void)
 {
 	if (multi_checked)
 		return;
=20
-	dmi_check_system(multi_dmi_table);
+	sysfw_callback(set_multi_table);
 	multi_checked =3D 1;
 }
=20
@@ -2267,11 +2267,11 @@ static void __cpuinit dmi_check_multi(void)
  * Thus far, the major user of this is IBM's Summit2 series:
  * Clustered boxes may have unsynced TSC problems if they are
  * multi-chassis.
- * Use DMI to check them
+ * Use SMBIOS to check them
  */
 __cpuinit int apic_is_clustered_box(void)
 {
-	dmi_check_multi();
+	check_set_multi();
 	if (multi)
 		return 1;
=20
diff --git a/arch/x86/kernel/apic/bigsmp_32.c b/arch/x86/kernel/apic/bigsmp=
_32.c
index efd737e..76bee5d 100644
--- a/arch/x86/kernel/apic/bigsmp_32.c
+++ b/arch/x86/kernel/apic/bigsmp_32.c
@@ -7,7 +7,7 @@
 #include <linux/cpumask.h>
 #include <linux/kernel.h>
 #include <linux/init.h>
-#include <linux/dmi.h>
+#include <linux/sysfw.h>
 #include <linux/smp.h>
=20
 #include <asm/apicdef.h>
@@ -151,30 +151,35 @@ static void bigsmp_send_IPI_all(int vector)
 	bigsmp_send_IPI_mask(cpu_online_mask, vector);
 }
=20
-static int dmi_bigsmp; /* can be set by dmi scanners */
+static int smbios_bigsmp; /* can be set by smbios scanners */
=20
-static int hp_ht_bigsmp(const struct dmi_system_id *d)
+static int hp_ht_bigsmp(const struct sysfw_id *d)
 {
 	printk(KERN_NOTICE "%s detected: force use of apic=3Dbigsmp\n", d->ident);
-	dmi_bigsmp =3D 1;
+	smbios_bigsmp =3D 1;
=20
 	return 0;
 }
=20
=20
-static const struct dmi_system_id bigsmp_dmi_table[] =3D {
-	{ hp_ht_bigsmp, "HP ProLiant DL760 G2",
-		{	DMI_MATCH(DMI_BIOS_VENDOR, "HP"),
-			DMI_MATCH(DMI_BIOS_VERSION, "P44-"),
+static const struct sysfw_id bigsmp_id_table[] =3D {
+	{
+		.callback =3D hp_ht_bigsmp,
+		.ident =3D "HP ProLiant DL760 G2",
+		{
+			SYSFW_MATCH(SYSFW_BIOS_VENDOR, "HP"),
+			SYSFW_MATCH(SYSFW_BIOS_VERSION, "P44-"),
 		}
 	},
-
-	{ hp_ht_bigsmp, "HP ProLiant DL740",
-		{	DMI_MATCH(DMI_BIOS_VENDOR, "HP"),
-			DMI_MATCH(DMI_BIOS_VERSION, "P47-"),
+	{
+		.callback =3D hp_ht_bigsmp,
+		.ident =3D "HP ProLiant DL740",
+		{
+			SYSFW_MATCH(SYSFW_BIOS_VENDOR, "HP"),
+			SYSFW_MATCH(SYSFW_BIOS_VERSION, "P47-"),
 		}
 	},
-	{ } /* NULL entry stops DMI scanning */
+	{} /* NULL entry stops SMBIOS scanning */
 };
=20
 static void bigsmp_vector_allocation_domain(int cpu, struct cpumask *retma=
sk)
@@ -186,11 +191,11 @@ static void bigsmp_vector_allocation_domain(int cpu, =
struct cpumask *retmask)
 static int probe_bigsmp(void)
 {
 	if (def_to_bigsmp)
-		dmi_bigsmp =3D 1;
+		smbios_bigsmp =3D 1;
 	else
-		dmi_check_system(bigsmp_dmi_table);
+		sysfw_callback(bigsmp_id_table);
=20
-	return dmi_bigsmp;
+	return smbios_bigsmp;
 }
=20
 static struct apic apic_bigsmp =3D {
diff --git a/arch/x86/kernel/apm_32.c b/arch/x86/kernel/apm_32.c
index 965a766..dd804ef 100644
--- a/arch/x86/kernel/apm_32.c
+++ b/arch/x86/kernel/apm_32.c
@@ -223,7 +223,7 @@
 #include <linux/kernel.h>
 #include <linux/freezer.h>
 #include <linux/smp.h>
-#include <linux/dmi.h>
+#include <linux/sysfw.h>
 #include <linux/suspend.h>
 #include <linux/kthread.h>
 #include <linux/jiffies.h>
@@ -1931,7 +1931,7 @@ static struct miscdevice apm_device =3D {
=20
=20
 /* Simple "print if true" callback */
-static int __init print_if_true(const struct dmi_system_id *d)
+static int __init print_if_true(const struct sysfw_id *d)
 {
 	printk("%s\n", d->ident);
 	return 0;
@@ -1941,7 +1941,7 @@ static int __init print_if_true(const struct dmi_syst=
em_id *d)
  * Some Bioses enable the PS/2 mouse (touchpad) at resume, even if it was
  * disabled before the suspend. Linux used to get terribly confused by tha=
t.
  */
-static int __init broken_ps2_resume(const struct dmi_system_id *d)
+static int __init broken_ps2_resume(const struct sysfw_id *d)
 {
 	printk(KERN_INFO "%s machine detected. Mousepad Resume Bug "
 	       "workaround hopefully not needed.\n", d->ident);
@@ -1949,7 +1949,7 @@ static int __init broken_ps2_resume(const struct dmi_=
system_id *d)
 }
=20
 /* Some bioses have a broken protected mode poweroff and need to use realm=
ode */
-static int __init set_realmode_power_off(const struct dmi_system_id *d)
+static int __init set_realmode_power_off(const struct sysfw_id *d)
 {
 	if (apm_info.realmode_power_off =3D 0) {
 		apm_info.realmode_power_off =3D 1;
@@ -1960,7 +1960,7 @@ static int __init set_realmode_power_off(const struct=
 dmi_system_id *d)
 }
=20
 /* Some laptops require interrupts to be enabled during APM calls */
-static int __init set_apm_ints(const struct dmi_system_id *d)
+static int __init set_apm_ints(const struct sysfw_id *d)
 {
 	if (apm_info.allow_ints =3D 0) {
 		apm_info.allow_ints =3D 1;
@@ -1971,7 +1971,7 @@ static int __init set_apm_ints(const struct dmi_syste=
m_id *d)
 }
=20
 /* Some APM bioses corrupt memory or just plain do not work */
-static int __init apm_is_horked(const struct dmi_system_id *d)
+static int __init apm_is_horked(const struct sysfw_id *d)
 {
 	if (apm_info.disabled =3D 0) {
 		apm_info.disabled =3D 1;
@@ -1981,7 +1981,7 @@ static int __init apm_is_horked(const struct dmi_syst=
em_id *d)
 	return 0;
 }
=20
-static int __init apm_is_horked_d850md(const struct dmi_system_id *d)
+static int __init apm_is_horked_d850md(const struct sysfw_id *d)
 {
 	if (apm_info.disabled =3D 0) {
 		apm_info.disabled =3D 1;
@@ -1994,7 +1994,7 @@ static int __init apm_is_horked_d850md(const struct d=
mi_system_id *d)
 }
=20
 /* Some APM bioses hang on APM idle calls */
-static int __init apm_likes_to_melt(const struct dmi_system_id *d)
+static int __init apm_likes_to_melt(const struct sysfw_id *d)
 {
 	if (apm_info.forbid_idle =3D 0) {
 		apm_info.forbid_idle =3D 1;
@@ -2019,7 +2019,7 @@ static int __init apm_likes_to_melt(const struct dmi_=
system_id *d)
  *	Phoenix A04  08/24/2000 is known bad (Dell Inspiron 5000e)
  *	Phoenix A07  09/29/2000 is known good (Dell Inspiron 5000)
  */
-static int __init broken_apm_power(const struct dmi_system_id *d)
+static int __init broken_apm_power(const struct sysfw_id *d)
 {
 	apm_info.get_power_status_broken =3D 1;
 	printk(KERN_WARNING "BIOS strings suggest APM bugs, "
@@ -2031,7 +2031,7 @@ static int __init broken_apm_power(const struct dmi_s=
ystem_id *d)
  * This bios swaps the APM minute reporting bytes over (Many sony laptops
  * have this problem).
  */
-static int __init swab_apm_power_in_minutes(const struct dmi_system_id *d)
+static int __init swab_apm_power_in_minutes(const struct sysfw_id *d)
 {
 	apm_info.get_power_status_swabinminutes =3D 1;
 	printk(KERN_WARNING "BIOS strings suggest APM reports battery life "
@@ -2039,215 +2039,314 @@ static int __init swab_apm_power_in_minutes(const=
 struct dmi_system_id *d)
 	return 0;
 }
=20
-static struct dmi_system_id __initdata apm_dmi_table[] =3D {
+static struct sysfw_id __initdata apm_id_table[] =3D {
 	{
-		print_if_true,
+		.callback =3D print_if_true,
 		KERN_WARNING "IBM T23 - BIOS 1.03b+ and controller firmware 1.02+ may be=
 needed for Linux APM.",
-		{	DMI_MATCH(DMI_SYS_VENDOR, "IBM"),
-			DMI_MATCH(DMI_BIOS_VERSION, "1AET38WW (1.01b)"), },
+		{	SYSFW_MATCH(SYSFW_SYS_VENDOR, "IBM"),
+			SYSFW_MATCH(SYSFW_BIOS_VERSION, "1AET38WW (1.01b)"),
+		},
 	},
 	{	/* Handle problems with APM on the C600 */
-		broken_ps2_resume, "Dell Latitude C600",
-		{	DMI_MATCH(DMI_SYS_VENDOR, "Dell"),
-			DMI_MATCH(DMI_PRODUCT_NAME, "Latitude C600"), },
+		.callback =3D broken_ps2_resume,
+		.ident =3D "Dell Latitude C600",
+		{	SYSFW_MATCH(SYSFW_SYS_VENDOR, "Dell"),
+			SYSFW_MATCH(SYSFW_PRODUCT_NAME, "Latitude C600")
+		},
 	},
 	{	/* Allow interrupts during suspend on Dell Latitude laptops*/
-		set_apm_ints, "Dell Latitude",
-		{	DMI_MATCH(DMI_SYS_VENDOR, "Dell Computer Corporation"),
-			DMI_MATCH(DMI_PRODUCT_NAME, "Latitude C510"), }
+		.callback =3D set_apm_ints,
+		.ident =3D "Dell Latitude",
+		{	SYSFW_MATCH(SYSFW_SYS_VENDOR,
+				    "Dell Computer Corporation"),
+			SYSFW_MATCH(SYSFW_PRODUCT_NAME, "Latitude C510"),
+		},
 	},
 	{	/* APM crashes */
-		apm_is_horked, "Dell Inspiron 2500",
-		{	DMI_MATCH(DMI_SYS_VENDOR, "Dell Computer Corporation"),
-			DMI_MATCH(DMI_PRODUCT_NAME, "Inspiron 2500"),
-			DMI_MATCH(DMI_BIOS_VENDOR, "Phoenix Technologies LTD"),
-			DMI_MATCH(DMI_BIOS_VERSION, "A11"), },
+		.callback =3D apm_is_horked,
+		.ident =3D "Dell Inspiron 2500",
+		{	SYSFW_MATCH(SYSFW_SYS_VENDOR,
+				    "Dell Computer Corporation"),
+			SYSFW_MATCH(SYSFW_PRODUCT_NAME, "Inspiron 2500"),
+			SYSFW_MATCH(SYSFW_BIOS_VENDOR,
+				    "Phoenix Technologies LTD"),
+			SYSFW_MATCH(SYSFW_BIOS_VERSION, "A11"), },
 	},
 	{	/* Allow interrupts during suspend on Dell Inspiron laptops*/
-		set_apm_ints, "Dell Inspiron", {
-			DMI_MATCH(DMI_SYS_VENDOR, "Dell Computer Corporation"),
-			DMI_MATCH(DMI_PRODUCT_NAME, "Inspiron 4000"), },
+		.callback =3D set_apm_ints,
+		.ident =3D "Dell Inspiron", {
+			SYSFW_MATCH(SYSFW_SYS_VENDOR,
+				    "Dell Computer Corporation"),
+			SYSFW_MATCH(SYSFW_PRODUCT_NAME, "Inspiron 4000"),
+		},
 	},
 	{	/* Handle problems with APM on Inspiron 5000e */
-		broken_apm_power, "Dell Inspiron 5000e",
-		{	DMI_MATCH(DMI_BIOS_VENDOR, "Phoenix Technologies LTD"),
-			DMI_MATCH(DMI_BIOS_VERSION, "A04"),
-			DMI_MATCH(DMI_BIOS_DATE, "08/24/2000"), },
+		.callback =3D broken_apm_power,
+		.ident =3D "Dell Inspiron 5000e",
+		{	SYSFW_MATCH(SYSFW_BIOS_VENDOR,
+				    "Phoenix Technologies LTD"),
+			SYSFW_MATCH(SYSFW_BIOS_VERSION, "A04"),
+			SYSFW_MATCH(SYSFW_BIOS_DATE, "08/24/2000"),
+		},
 	},
 	{	/* Handle problems with APM on Inspiron 2500 */
-		broken_apm_power, "Dell Inspiron 2500",
-		{	DMI_MATCH(DMI_BIOS_VENDOR, "Phoenix Technologies LTD"),
-			DMI_MATCH(DMI_BIOS_VERSION, "A12"),
-			DMI_MATCH(DMI_BIOS_DATE, "02/04/2002"), },
+		.callback =3D broken_apm_power,
+		.ident =3D "Dell Inspiron 2500",
+		{	SYSFW_MATCH(SYSFW_BIOS_VENDOR,
+				     "Phoenix Technologies LTD"),
+			SYSFW_MATCH(SYSFW_BIOS_VERSION, "A12"),
+			SYSFW_MATCH(SYSFW_BIOS_DATE, "02/04/2002"),
+		},
 	},
 	{	/* APM crashes */
-		apm_is_horked, "Dell Dimension 4100",
-		{	DMI_MATCH(DMI_SYS_VENDOR, "Dell Computer Corporation"),
-			DMI_MATCH(DMI_PRODUCT_NAME, "XPS-Z"),
-			DMI_MATCH(DMI_BIOS_VENDOR, "Intel Corp."),
-			DMI_MATCH(DMI_BIOS_VERSION, "A11"), },
+		.callback =3D apm_is_horked,
+		.ident =3D "Dell Dimension 4100",
+		{	SYSFW_MATCH(SYSFW_SYS_VENDOR,
+				    "Dell Computer Corporation"),
+			SYSFW_MATCH(SYSFW_PRODUCT_NAME, "XPS-Z"),
+			SYSFW_MATCH(SYSFW_BIOS_VENDOR, "Intel Corp."),
+			SYSFW_MATCH(SYSFW_BIOS_VERSION, "A11"),
+		},
 	},
 	{	/* Allow interrupts during suspend on Compaq Laptops*/
-		set_apm_ints, "Compaq 12XL125",
-		{	DMI_MATCH(DMI_SYS_VENDOR, "Compaq"),
-			DMI_MATCH(DMI_PRODUCT_NAME, "Compaq PC"),
-			DMI_MATCH(DMI_BIOS_VENDOR, "Phoenix Technologies LTD"),
-			DMI_MATCH(DMI_BIOS_VERSION, "4.06"), },
+		.callback =3D set_apm_ints,
+		.ident =3D "Compaq 12XL125",
+		{	SYSFW_MATCH(SYSFW_SYS_VENDOR, "Compaq"),
+			SYSFW_MATCH(SYSFW_PRODUCT_NAME, "Compaq PC"),
+			SYSFW_MATCH(SYSFW_BIOS_VENDOR,
+				    "Phoenix Technologies LTD"),
+			SYSFW_MATCH(SYSFW_BIOS_VERSION, "4.06"),
+		},
 	},
 	{	/* Allow interrupts during APM or the clock goes slow */
-		set_apm_ints, "ASUSTeK",
-		{	DMI_MATCH(DMI_SYS_VENDOR, "ASUSTeK Computer Inc."),
-			DMI_MATCH(DMI_PRODUCT_NAME, "L8400K series Notebook PC"), },
+		.callback =3D set_apm_ints,
+		.ident =3D "ASUSTeK",
+		{	SYSFW_MATCH(SYSFW_SYS_VENDOR,
+				    "ASUSTeK Computer Inc."),
+			SYSFW_MATCH(SYSFW_PRODUCT_NAME,
+				    "L8400K series Notebook PC"),
+		},
 	},
 	{	/* APM blows on shutdown */
-		apm_is_horked, "ABIT KX7-333[R]",
-		{	DMI_MATCH(DMI_BOARD_VENDOR, "ABIT"),
-			DMI_MATCH(DMI_BOARD_NAME, "VT8367-8233A (KX7-333[R])"), },
+		.callback =3D apm_is_horked,
+		.ident =3D "ABIT KX7-333[R]",
+		{	SYSFW_MATCH(SYSFW_BOARD_VENDOR, "ABIT"),
+			SYSFW_MATCH(SYSFW_BOARD_NAME,
+				    "VT8367-8233A (KX7-333[R])"), },
 	},
 	{	/* APM crashes */
-		apm_is_horked, "Trigem Delhi3",
-		{	DMI_MATCH(DMI_SYS_VENDOR, "TriGem Computer, Inc"),
-			DMI_MATCH(DMI_PRODUCT_NAME, "Delhi3"), },
+		.callback =3D apm_is_horked,
+		.ident =3D "Trigem Delhi3",
+		{	SYSFW_MATCH(SYSFW_SYS_VENDOR, "TriGem Computer, Inc"),
+			SYSFW_MATCH(SYSFW_PRODUCT_NAME, "Delhi3"),
+		},
 	},
 	{	/* APM crashes */
-		apm_is_horked, "Fujitsu-Siemens",
-		{	DMI_MATCH(DMI_BIOS_VENDOR, "hoenix/FUJITSU SIEMENS"),
-			DMI_MATCH(DMI_BIOS_VERSION, "Version1.01"), },
+		.callback =3D apm_is_horked,
+		.ident =3D "Fujitsu-Siemens",
+		{	SYSFW_MATCH(SYSFW_BIOS_VENDOR,
+				    "hoenix/FUJITSU SIEMENS"),
+			SYSFW_MATCH(SYSFW_BIOS_VERSION, "Version1.01")
+		},
 	},
 	{	/* APM crashes */
-		apm_is_horked_d850md, "Intel D850MD",
-		{	DMI_MATCH(DMI_BIOS_VENDOR, "Intel Corp."),
-			DMI_MATCH(DMI_BIOS_VERSION, "MV85010A.86A.0016.P07.0201251536"), },
+		.callback =3D apm_is_horked_d850md,
+		.ident =3D "Intel D850MD",
+		{	SYSFW_MATCH(SYSFW_BIOS_VENDOR, "Intel Corp."),
+			SYSFW_MATCH(SYSFW_BIOS_VERSION,
+				    "MV85010A.86A.0016.P07.0201251536"),
+		},
 	},
 	{	/* APM crashes */
-		apm_is_horked, "Intel D810EMO",
-		{	DMI_MATCH(DMI_BIOS_VENDOR, "Intel Corp."),
-			DMI_MATCH(DMI_BIOS_VERSION, "MO81010A.86A.0008.P04.0004170800"), },
+		.callback =3D apm_is_horked,
+		.ident =3D "Intel D810EMO",
+		{	SYSFW_MATCH(SYSFW_BIOS_VENDOR, "Intel Corp."),
+			SYSFW_MATCH(SYSFW_BIOS_VERSION,
+				    "MO81010A.86A.0008.P04.0004170800"),
+		},
 	},
 	{	/* APM crashes */
-		apm_is_horked, "Dell XPS-Z",
-		{	DMI_MATCH(DMI_BIOS_VENDOR, "Intel Corp."),
-			DMI_MATCH(DMI_BIOS_VERSION, "A11"),
-			DMI_MATCH(DMI_PRODUCT_NAME, "XPS-Z"), },
+		.callback =3D apm_is_horked,
+		.ident =3D "Dell XPS-Z",
+		{	SYSFW_MATCH(SYSFW_BIOS_VENDOR, "Intel Corp."),
+			SYSFW_MATCH(SYSFW_BIOS_VERSION, "A11"),
+			SYSFW_MATCH(SYSFW_PRODUCT_NAME, "XPS-Z"),
+		},
 	},
 	{	/* APM crashes */
-		apm_is_horked, "Sharp PC-PJ/AX",
-		{	DMI_MATCH(DMI_SYS_VENDOR, "SHARP"),
-			DMI_MATCH(DMI_PRODUCT_NAME, "PC-PJ/AX"),
-			DMI_MATCH(DMI_BIOS_VENDOR, "SystemSoft"),
-			DMI_MATCH(DMI_BIOS_VERSION, "Version R2.08"), },
+		.callback =3D apm_is_horked,
+		.ident =3D "Sharp PC-PJ/AX",
+		{	SYSFW_MATCH(SYSFW_SYS_VENDOR, "SHARP"),
+			SYSFW_MATCH(SYSFW_PRODUCT_NAME, "PC-PJ/AX"),
+			SYSFW_MATCH(SYSFW_BIOS_VENDOR, "SystemSoft"),
+			SYSFW_MATCH(SYSFW_BIOS_VERSION, "Version R2.08"),
+		},
 	},
 	{	/* APM crashes */
-		apm_is_horked, "Dell Inspiron 2500",
-		{	DMI_MATCH(DMI_SYS_VENDOR, "Dell Computer Corporation"),
-			DMI_MATCH(DMI_PRODUCT_NAME, "Inspiron 2500"),
-			DMI_MATCH(DMI_BIOS_VENDOR, "Phoenix Technologies LTD"),
-			DMI_MATCH(DMI_BIOS_VERSION, "A11"), },
+		.callback =3D apm_is_horked,
+		.ident =3D "Dell Inspiron 2500",
+		{	SYSFW_MATCH(SYSFW_SYS_VENDOR,
+				    "Dell Computer Corporation"),
+			SYSFW_MATCH(SYSFW_PRODUCT_NAME, "Inspiron 2500"),
+			SYSFW_MATCH(SYSFW_BIOS_VENDOR,
+				    "Phoenix Technologies LTD"),
+			SYSFW_MATCH(SYSFW_BIOS_VERSION, "A11"),
+		},
 	},
 	{	/* APM idle hangs */
-		apm_likes_to_melt, "Jabil AMD",
-		{	DMI_MATCH(DMI_BIOS_VENDOR, "American Megatrends Inc."),
-			DMI_MATCH(DMI_BIOS_VERSION, "0AASNP06"), },
+		.callback =3D apm_likes_to_melt,
+		.ident =3D "Jabil AMD",
+		{	SYSFW_MATCH(SYSFW_BIOS_VENDOR,
+				    "American Megatrends Inc."),
+			SYSFW_MATCH(SYSFW_BIOS_VERSION, "0AASNP06"),
+		},
 	},
 	{	/* APM idle hangs */
-		apm_likes_to_melt, "AMI Bios",
-		{	DMI_MATCH(DMI_BIOS_VENDOR, "American Megatrends Inc."),
-			DMI_MATCH(DMI_BIOS_VERSION, "0AASNP05"), },
+		.callback =3D apm_likes_to_melt,
+		.ident =3D "AMI Bios",
+		{	SYSFW_MATCH(SYSFW_BIOS_VENDOR,
+				    "American Megatrends Inc."),
+			SYSFW_MATCH(SYSFW_BIOS_VERSION, "0AASNP05"),
+		},
 	},
 	{	/* Handle problems with APM on Sony Vaio PCG-N505X(DE) */
-		swab_apm_power_in_minutes, "Sony VAIO",
-		{	DMI_MATCH(DMI_BIOS_VENDOR, "Phoenix Technologies LTD"),
-			DMI_MATCH(DMI_BIOS_VERSION, "R0206H"),
-			DMI_MATCH(DMI_BIOS_DATE, "08/23/99"), },
+		.callback =3D swab_apm_power_in_minutes,
+		.ident =3D "Sony VAIO",
+		{	SYSFW_MATCH(SYSFW_BIOS_VENDOR,
+				    "Phoenix Technologies LTD"),
+			SYSFW_MATCH(SYSFW_BIOS_VERSION, "R0206H"),
+			SYSFW_MATCH(SYSFW_BIOS_DATE, "08/23/99"),
+		},
 	},
 	{	/* Handle problems with APM on Sony Vaio PCG-N505VX */
-		swab_apm_power_in_minutes, "Sony VAIO",
-		{	DMI_MATCH(DMI_BIOS_VENDOR, "Phoenix Technologies LTD"),
-			DMI_MATCH(DMI_BIOS_VERSION, "W2K06H0"),
-			DMI_MATCH(DMI_BIOS_DATE, "02/03/00"), },
+		.callback =3D swab_apm_power_in_minutes,
+		.ident =3D "Sony VAIO",
+		{	SYSFW_MATCH(SYSFW_BIOS_VENDOR,
+				    "Phoenix Technologies LTD"),
+			SYSFW_MATCH(SYSFW_BIOS_VERSION, "W2K06H0"),
+			SYSFW_MATCH(SYSFW_BIOS_DATE, "02/03/00"),
+		},
 	},
 	{	/* Handle problems with APM on Sony Vaio PCG-XG29 */
-		swab_apm_power_in_minutes, "Sony VAIO",
-		{	DMI_MATCH(DMI_BIOS_VENDOR, "Phoenix Technologies LTD"),
-			DMI_MATCH(DMI_BIOS_VERSION, "R0117A0"),
-			DMI_MATCH(DMI_BIOS_DATE, "04/25/00"), },
+		.callback =3D swab_apm_power_in_minutes,
+		.ident =3D "Sony VAIO",
+		{	SYSFW_MATCH(SYSFW_BIOS_VENDOR,
+				    "Phoenix Technologies LTD"),
+			SYSFW_MATCH(SYSFW_BIOS_VERSION, "R0117A0"),
+			SYSFW_MATCH(SYSFW_BIOS_DATE, "04/25/00"),
+		},
 	},
 	{	/* Handle problems with APM on Sony Vaio PCG-Z600NE */
-		swab_apm_power_in_minutes, "Sony VAIO",
-		{	DMI_MATCH(DMI_BIOS_VENDOR, "Phoenix Technologies LTD"),
-			DMI_MATCH(DMI_BIOS_VERSION, "R0121Z1"),
-			DMI_MATCH(DMI_BIOS_DATE, "05/11/00"), },
+		.callback =3D swab_apm_power_in_minutes,
+		.ident =3D "Sony VAIO",
+		{	SYSFW_MATCH(SYSFW_BIOS_VENDOR,
+				    "Phoenix Technologies LTD"),
+			SYSFW_MATCH(SYSFW_BIOS_VERSION, "R0121Z1"),
+			SYSFW_MATCH(SYSFW_BIOS_DATE, "05/11/00"),
+		},
 	},
 	{	/* Handle problems with APM on Sony Vaio PCG-Z600NE */
-		swab_apm_power_in_minutes, "Sony VAIO",
-		{	DMI_MATCH(DMI_BIOS_VENDOR, "Phoenix Technologies LTD"),
-			DMI_MATCH(DMI_BIOS_VERSION, "WME01Z1"),
-			DMI_MATCH(DMI_BIOS_DATE, "08/11/00"), },
+		.callback =3D swab_apm_power_in_minutes,
+		.ident =3D "Sony VAIO",
+		{	SYSFW_MATCH(SYSFW_BIOS_VENDOR,
+				    "Phoenix Technologies LTD"),
+			SYSFW_MATCH(SYSFW_BIOS_VERSION, "WME01Z1"),
+			SYSFW_MATCH(SYSFW_BIOS_DATE, "08/11/00"),
+		},
 	},
 	{	/* Handle problems with APM on Sony Vaio PCG-Z600LEK(DE) */
-		swab_apm_power_in_minutes, "Sony VAIO",
-		{	DMI_MATCH(DMI_BIOS_VENDOR, "Phoenix Technologies LTD"),
-			DMI_MATCH(DMI_BIOS_VERSION, "R0206Z3"),
-			DMI_MATCH(DMI_BIOS_DATE, "12/25/00"), },
+		.callback =3D swab_apm_power_in_minutes,
+		.ident =3D "Sony VAIO",
+		{	SYSFW_MATCH(SYSFW_BIOS_VENDOR,
+				    "Phoenix Technologies LTD"),
+			SYSFW_MATCH(SYSFW_BIOS_VERSION, "R0206Z3"),
+			SYSFW_MATCH(SYSFW_BIOS_DATE, "12/25/00"),
+		},
 	},
 	{	/* Handle problems with APM on Sony Vaio PCG-Z505LS */
-		swab_apm_power_in_minutes, "Sony VAIO",
-		{	DMI_MATCH(DMI_BIOS_VENDOR, "Phoenix Technologies LTD"),
-			DMI_MATCH(DMI_BIOS_VERSION, "R0203D0"),
-			DMI_MATCH(DMI_BIOS_DATE, "05/12/00"), },
+		.callback =3D swab_apm_power_in_minutes,
+		.ident =3D "Sony VAIO",
+		{	SYSFW_MATCH(SYSFW_BIOS_VENDOR,
+				    "Phoenix Technologies LTD"),
+			SYSFW_MATCH(SYSFW_BIOS_VERSION, "R0203D0"),
+			SYSFW_MATCH(SYSFW_BIOS_DATE, "05/12/00"),
+		},
 	},
 	{	/* Handle problems with APM on Sony Vaio PCG-Z505LS */
-		swab_apm_power_in_minutes, "Sony VAIO",
-		{	DMI_MATCH(DMI_BIOS_VENDOR, "Phoenix Technologies LTD"),
-			DMI_MATCH(DMI_BIOS_VERSION, "R0203Z3"),
-			DMI_MATCH(DMI_BIOS_DATE, "08/25/00"), },
+		.callback =3D swab_apm_power_in_minutes,
+		.ident =3D "Sony VAIO",
+		{	SYSFW_MATCH(SYSFW_BIOS_VENDOR,
+				    "Phoenix Technologies LTD"),
+			SYSFW_MATCH(SYSFW_BIOS_VERSION, "R0203Z3"),
+			SYSFW_MATCH(SYSFW_BIOS_DATE, "08/25/00"),
+		},
 	},
 	{	/* Handle problems with APM on Sony Vaio PCG-Z505LS (with updated BIOS)=
 */
-		swab_apm_power_in_minutes, "Sony VAIO",
-		{	DMI_MATCH(DMI_BIOS_VENDOR, "Phoenix Technologies LTD"),
-			DMI_MATCH(DMI_BIOS_VERSION, "R0209Z3"),
-			DMI_MATCH(DMI_BIOS_DATE, "05/12/01"), },
+		.callback =3D swab_apm_power_in_minutes,
+		.ident =3D "Sony VAIO",
+		{	SYSFW_MATCH(SYSFW_BIOS_VENDOR,
+				    "Phoenix Technologies LTD"),
+			SYSFW_MATCH(SYSFW_BIOS_VERSION, "R0209Z3"),
+			SYSFW_MATCH(SYSFW_BIOS_DATE, "05/12/01"),
+		},
 	},
 	{	/* Handle problems with APM on Sony Vaio PCG-F104K */
-		swab_apm_power_in_minutes, "Sony VAIO",
-		{	DMI_MATCH(DMI_BIOS_VENDOR, "Phoenix Technologies LTD"),
-			DMI_MATCH(DMI_BIOS_VERSION, "R0204K2"),
-			DMI_MATCH(DMI_BIOS_DATE, "08/28/00"), },
+		.callback =3D swab_apm_power_in_minutes,
+		.ident =3D "Sony VAIO",
+		{	SYSFW_MATCH(SYSFW_BIOS_VENDOR,
+				    "Phoenix Technologies LTD"),
+			SYSFW_MATCH(SYSFW_BIOS_VERSION, "R0204K2"),
+			SYSFW_MATCH(SYSFW_BIOS_DATE, "08/28/00"),
+		},
 	},
=20
 	{	/* Handle problems with APM on Sony Vaio PCG-C1VN/C1VE */
-		swab_apm_power_in_minutes, "Sony VAIO",
-		{	DMI_MATCH(DMI_BIOS_VENDOR, "Phoenix Technologies LTD"),
-			DMI_MATCH(DMI_BIOS_VERSION, "R0208P1"),
-			DMI_MATCH(DMI_BIOS_DATE, "11/09/00"), },
+		.callback =3D swab_apm_power_in_minutes,
+		.ident =3D "Sony VAIO",
+		{	SYSFW_MATCH(SYSFW_BIOS_VENDOR,
+				    "Phoenix Technologies LTD"),
+			SYSFW_MATCH(SYSFW_BIOS_VERSION, "R0208P1"),
+			SYSFW_MATCH(SYSFW_BIOS_DATE, "11/09/00"),
+		},
 	},
 	{	/* Handle problems with APM on Sony Vaio PCG-C1VE */
-		swab_apm_power_in_minutes, "Sony VAIO",
-		{	DMI_MATCH(DMI_BIOS_VENDOR, "Phoenix Technologies LTD"),
-			DMI_MATCH(DMI_BIOS_VERSION, "R0204P1"),
-			DMI_MATCH(DMI_BIOS_DATE, "09/12/00"), },
+		.callback =3D swab_apm_power_in_minutes,
+		.ident =3D "Sony VAIO",
+		{	SYSFW_MATCH(SYSFW_BIOS_VENDOR,
+				    "Phoenix Technologies LTD"),
+			SYSFW_MATCH(SYSFW_BIOS_VERSION, "R0204P1"),
+			SYSFW_MATCH(SYSFW_BIOS_DATE, "09/12/00"),
+		},
 	},
 	{	/* Handle problems with APM on Sony Vaio PCG-C1VE */
-		swab_apm_power_in_minutes, "Sony VAIO",
-		{	DMI_MATCH(DMI_BIOS_VENDOR, "Phoenix Technologies LTD"),
-			DMI_MATCH(DMI_BIOS_VERSION, "WXPO1Z3"),
-			DMI_MATCH(DMI_BIOS_DATE, "10/26/01"), },
+		.callback =3D swab_apm_power_in_minutes,
+		.ident =3D "Sony VAIO",
+		{	SYSFW_MATCH(SYSFW_BIOS_VENDOR,
+				    "Phoenix Technologies LTD"),
+			SYSFW_MATCH(SYSFW_BIOS_VERSION, "WXPO1Z3"),
+			SYSFW_MATCH(SYSFW_BIOS_DATE, "10/26/01"),
+		},
 	},
 	{	/* broken PM poweroff bios */
-		set_realmode_power_off, "Award Software v4.60 PGMA",
-		{	DMI_MATCH(DMI_BIOS_VENDOR, "Award Software International, Inc."),
-			DMI_MATCH(DMI_BIOS_VERSION, "4.60 PGMA"),
-			DMI_MATCH(DMI_BIOS_DATE, "134526184"), },
+		.callback =3D set_realmode_power_off,
+		.ident =3D "Award Software v4.60 PGMA",
+		{	SYSFW_MATCH(SYSFW_BIOS_VENDOR,
+				    "Award Software International, Inc."),
+			SYSFW_MATCH(SYSFW_BIOS_VERSION, "4.60 PGMA"),
+			SYSFW_MATCH(SYSFW_BIOS_DATE, "134526184"),
+		},
 	},
=20
 	/* Generic per vendor APM settings  */
=20
 	{	/* Allow interrupts during suspend on IBM laptops */
-		set_apm_ints, "IBM",
-		{	DMI_MATCH(DMI_SYS_VENDOR, "IBM"), },
+		.callback =3D set_apm_ints,
+		.ident =3D "IBM",
+		{
+			SYSFW_MATCH(SYSFW_SYS_VENDOR, "IBM"),
+		},
 	},
-
-	{ }
+	{}
 };
=20
 /*
@@ -2265,7 +2364,7 @@ static int __init apm_init(void)
 	struct desc_struct *gdt;
 	int err;
=20
-	dmi_check_system(apm_dmi_table);
+	sysfw_callback(apm_id_table);
=20
 	if (apm_info.bios.version =3D 0 || paravirt_enabled() || machine_is_olpc(=
)) {
 		printk(KERN_INFO "apm: BIOS not found.\n");
@@ -2288,7 +2387,7 @@ static int __init apm_init(void)
 		apm_info.get_power_status_broken =3D 1;
 	if (realmode_power_off)
 		apm_info.realmode_power_off =3D 1;
-	/* User can override, but default is to trust DMI */
+	/* User can override, but default is to trust SMBIOS */
 	if (apm_disabled !=3D -1)
 		apm_info.disabled =3D apm_disabled;
=20
diff --git a/arch/x86/kernel/cpu/amd.c b/arch/x86/kernel/cpu/amd.c
index b13ed39..79fd786 100644
--- a/arch/x86/kernel/cpu/amd.c
+++ b/arch/x86/kernel/cpu/amd.c
@@ -587,7 +587,7 @@ static void __cpuinit init_amd(struct cpuinfo_x86 *c)
 	if (c->x86 =3D 0x10) {
 		/* do this for boot cpu */
 		if (c =3D &boot_cpu_data)
-			check_enable_amd_mmconf_dmi();
+			check_enable_amd_pci_mmconf();
=20
 		fam10h_check_enable_mmcfg();
 	}
diff --git a/arch/x86/kernel/cpu/vmware.c b/arch/x86/kernel/cpu/vmware.c
index d22d0c4..e427451 100644
--- a/arch/x86/kernel/cpu/vmware.c
+++ b/arch/x86/kernel/cpu/vmware.c
@@ -21,7 +21,7 @@
  *
  */
=20
-#include <linux/dmi.h>
+#include <linux/sysfw.h>
 #include <linux/module.h>
 #include <asm/div64.h>
 #include <asm/x86_init.h>
@@ -85,8 +85,18 @@ static void __init vmware_platform_setup(void)
 		       "Failed to get TSC freq from the hypervisor\n");
 }
=20
+static struct sysfw_id vmware_id_table[] =3D {
+	{
+		 .ident =3D "VMware",
+		.matches =3D {
+			SYSFW_MATCH(SYSFW_PRODUCT_SERIAL, "VMWare"),
+		},
+	},
+	{},
+};
+
 /*
- * While checking the dmi string information, just checking the product
+ * While checking the smbios string information, just checking the product
  * serial key should be enough, as this will always have a VMware
  * specific string when running under VMware hypervisor.
  */
@@ -100,8 +110,7 @@ static bool __init vmware_platform(void)
 		      &hyper_vendor_id[1], &hyper_vendor_id[2]);
 		if (!memcmp(hyper_vendor_id, "VMwareVMware", 12))
 			return true;
-	} else if (dmi_available && dmi_name_in_serial("VMware") &&
-		   __vmware_platform())
+	} else if (sysfw_callback(vmware_id_table) && __vmware_platform())
 		return true;
=20
 	return false;
diff --git a/arch/x86/kernel/io_delay.c b/arch/x86/kernel/io_delay.c
index a979b5b..27c0390 100644
--- a/arch/x86/kernel/io_delay.c
+++ b/arch/x86/kernel/io_delay.c
@@ -1,7 +1,7 @@
 /*
  * I/O delay strategies for inb_p/outb_p
  *
- * Allow for a DMI based override of port 0x80, needed for certain HP lapt=
ops
+ * Allow for a SMBIOS based override of port 0x80, needed for certain HP l=
aptops
  * and possibly other systems. Also allow for the gradual elimination of
  * outb_p/inb_p API uses.
  */
@@ -9,7 +9,7 @@
 #include <linux/module.h>
 #include <linux/delay.h>
 #include <linux/init.h>
-#include <linux/dmi.h>
+#include <linux/sysfw.h>
 #include <linux/io.h>
=20
 int io_delay_type __read_mostly =3D CONFIG_DEFAULT_IO_DELAY_TYPE;
@@ -44,7 +44,7 @@ void native_io_delay(void)
 }
 EXPORT_SYMBOL(native_io_delay);
=20
-static int __init dmi_io_delay_0xed_port(const struct dmi_system_id *id)
+static int __init io_delay_0xed_port(const struct sysfw_id *id)
 {
 	if (io_delay_type =3D CONFIG_IO_DELAY_TYPE_0X80) {
 		pr_notice("%s: using 0xed I/O delay port\n", id->ident);
@@ -58,54 +58,54 @@ static int __init dmi_io_delay_0xed_port(const struct d=
mi_system_id *id)
  * Quirk table for systems that misbehave (lock up, etc.) if port
  * 0x80 is used:
  */
-static struct dmi_system_id __initdata io_delay_0xed_port_dmi_table[] =3D {
+static struct sysfw_id __initdata io_delay_0xed_port_table[] =3D {
 	{
-		.callback	=3D dmi_io_delay_0xed_port,
+		.callback	=3D io_delay_0xed_port,
 		.ident		=3D "Compaq Presario V6000",
 		.matches	=3D {
-			DMI_MATCH(DMI_BOARD_VENDOR,	"Quanta"),
-			DMI_MATCH(DMI_BOARD_NAME,	"30B7")
+			SYSFW_MATCH(SYSFW_BOARD_VENDOR,	"Quanta"),
+			SYSFW_MATCH(SYSFW_BOARD_NAME,	"30B7")
 		}
 	},
 	{
-		.callback	=3D dmi_io_delay_0xed_port,
+		.callback	=3D io_delay_0xed_port,
 		.ident		=3D "HP Pavilion dv9000z",
 		.matches	=3D {
-			DMI_MATCH(DMI_BOARD_VENDOR,	"Quanta"),
-			DMI_MATCH(DMI_BOARD_NAME,	"30B9")
+			SYSFW_MATCH(SYSFW_BOARD_VENDOR,	"Quanta"),
+			SYSFW_MATCH(SYSFW_BOARD_NAME,	"30B9")
 		}
 	},
 	{
-		.callback	=3D dmi_io_delay_0xed_port,
+		.callback	=3D io_delay_0xed_port,
 		.ident		=3D "HP Pavilion dv6000",
 		.matches	=3D {
-			DMI_MATCH(DMI_BOARD_VENDOR,	"Quanta"),
-			DMI_MATCH(DMI_BOARD_NAME,	"30B8")
+			SYSFW_MATCH(SYSFW_BOARD_VENDOR,	"Quanta"),
+			SYSFW_MATCH(SYSFW_BOARD_NAME,	"30B8")
 		}
 	},
 	{
-		.callback	=3D dmi_io_delay_0xed_port,
+		.callback	=3D io_delay_0xed_port,
 		.ident		=3D "HP Pavilion tx1000",
 		.matches	=3D {
-			DMI_MATCH(DMI_BOARD_VENDOR,	"Quanta"),
-			DMI_MATCH(DMI_BOARD_NAME,	"30BF")
+			SYSFW_MATCH(SYSFW_BOARD_VENDOR,	"Quanta"),
+			SYSFW_MATCH(SYSFW_BOARD_NAME,	"30BF")
 		}
 	},
 	{
-		.callback	=3D dmi_io_delay_0xed_port,
+		.callback	=3D io_delay_0xed_port,
 		.ident		=3D "Presario F700",
 		.matches	=3D {
-			DMI_MATCH(DMI_BOARD_VENDOR,	"Quanta"),
-			DMI_MATCH(DMI_BOARD_NAME,	"30D3")
+			SYSFW_MATCH(SYSFW_BOARD_VENDOR,	"Quanta"),
+			SYSFW_MATCH(SYSFW_BOARD_NAME,	"30D3")
 		}
 	},
-	{ }
+	{}
 };
=20
 void __init io_delay_init(void)
 {
 	if (!io_delay_override)
-		dmi_check_system(io_delay_0xed_port_dmi_table);
+		sysfw_callback(io_delay_0xed_port_table);
 }
=20
 static int __init io_delay_param(char *s)
diff --git a/arch/x86/kernel/mmconf-fam10h_64.c b/arch/x86/kernel/mmconf-fa=
m10h_64.c
index ac861b8..f24400a 100644
--- a/arch/x86/kernel/mmconf-fam10h_64.c
+++ b/arch/x86/kernel/mmconf-fam10h_64.c
@@ -6,7 +6,7 @@
 #include <linux/mm.h>
 #include <linux/string.h>
 #include <linux/pci.h>
-#include <linux/dmi.h>
+#include <linux/sysfw.h>
 #include <linux/range.h>
=20
 #include <asm/pci-direct.h>
@@ -213,25 +213,25 @@ void __cpuinit fam10h_check_enable_mmcfg(void)
 	wrmsrl(address, val);
 }
=20
-static int __init set_check_enable_amd_mmconf(const struct dmi_system_id *=
d)
+static int __init set_check_enable_amd_mmconf(const struct sysfw_id *d)
 {
-        pci_probe |=3D PCI_CHECK_ENABLE_AMD_MMCONF;
-        return 0;
+	pci_probe |=3D PCI_CHECK_ENABLE_AMD_MMCONF;
+	return 0;
 }
=20
-static const struct dmi_system_id __initconst mmconf_dmi_table[] =3D {
-        {
-                .callback =3D set_check_enable_amd_mmconf,
-                .ident =3D "Sun Microsystems Machine",
-                .matches =3D {
-                        DMI_MATCH(DMI_SYS_VENDOR, "Sun Microsystems"),
-                },
-        },
+static const struct sysfw_id __initconst mmconf_id_table[] =3D {
+	{
+		.callback =3D set_check_enable_amd_mmconf,
+		.ident =3D "Sun Microsystems Machine",
+		.matches =3D {
+			SYSFW_MATCH(SYSFW_SYS_VENDOR, "Sun Microsystems"),
+		},
+	},
 	{}
 };
=20
 /* Called from a __cpuinit function, but only on the BSP. */
-void __ref check_enable_amd_mmconf_dmi(void)
+void __ref check_enable_amd_pci_mmconf(void)
 {
-	dmi_check_system(mmconf_dmi_table);
+	sysfw_callback(mmconf_id_table);
 }
diff --git a/arch/x86/kernel/probe_roms.c b/arch/x86/kernel/probe_roms.c
index ba0a4cc..e36d641 100644
--- a/arch/x86/kernel/probe_roms.c
+++ b/arch/x86/kernel/probe_roms.c
@@ -7,7 +7,6 @@
 #include <linux/console.h>
 #include <linux/init.h>
 #include <linux/edd.h>
-#include <linux/dmi.h>
 #include <linux/pfn.h>
 #include <linux/pci.h>
 #include <asm/pci-direct.h>
diff --git a/arch/x86/kernel/process.c b/arch/x86/kernel/process.c
index e1ba8cb..c1d7c54 100644
--- a/arch/x86/kernel/process.c
+++ b/arch/x86/kernel/process.c
@@ -10,7 +10,7 @@
 #include <linux/clockchips.h>
 #include <linux/random.h>
 #include <linux/user-return-notifier.h>
-#include <linux/dmi.h>
+#include <linux/sysfw.h>
 #include <linux/utsname.h>
 #include <trace/events/power.h>
 #include <linux/hw_breakpoint.h>
@@ -94,15 +94,15 @@ void show_regs_common(void)
 {
 	const char *vendor, *product, *board;
=20
-	vendor =3D dmi_get_system_info(DMI_SYS_VENDOR);
+	vendor =3D sysfw_lookup(SYSFW_SYS_VENDOR);
 	if (!vendor)
 		vendor =3D "";
-	product =3D dmi_get_system_info(DMI_PRODUCT_NAME);
+	product =3D sysfw_lookup(SYSFW_PRODUCT_NAME);
 	if (!product)
 		product =3D "";
=20
 	/* Board Name is optional */
-	board =3D dmi_get_system_info(DMI_BOARD_NAME);
+	board =3D sysfw_lookup(SYSFW_BOARD_NAME);
=20
 	printk(KERN_CONT "\n");
 	printk(KERN_DEFAULT "Pid: %d, comm: %.20s %s %s %.*s",
diff --git a/arch/x86/kernel/reboot.c b/arch/x86/kernel/reboot.c
index 4f0d46f..b3837c5 100644
--- a/arch/x86/kernel/reboot.c
+++ b/arch/x86/kernel/reboot.c
@@ -3,7 +3,7 @@
 #include <linux/init.h>
 #include <linux/pm.h>
 #include <linux/efi.h>
-#include <linux/dmi.h>
+#include <linux/sysfw.h>
 #include <linux/sched.h>
 #include <linux/tboot.h>
 #include <linux/delay.h>
@@ -127,7 +127,7 @@ __setup("reboot=3D", reboot_setup);
  * Some machines require the "reboot=3Db"  commandline option,
  * this quirk makes that automatic.
  */
-static int __init set_bios_reboot(const struct dmi_system_id *d)
+static int __init set_bios_reboot(const struct sysfw_id *d)
 {
 	if (reboot_type !=3D BOOT_BIOS) {
 		reboot_type =3D BOOT_BIOS;
@@ -136,178 +136,186 @@ static int __init set_bios_reboot(const struct dmi_=
system_id *d)
 	return 0;
 }
=20
-static struct dmi_system_id __initdata reboot_dmi_table[] =3D {
+static struct sysfw_id __initdata reboot_id_table[] =3D {
 	{	/* Handle problems with rebooting on Dell E520's */
 		.callback =3D set_bios_reboot,
 		.ident =3D "Dell E520",
 		.matches =3D {
-			DMI_MATCH(DMI_SYS_VENDOR, "Dell Inc."),
-			DMI_MATCH(DMI_PRODUCT_NAME, "Dell DM061"),
+			SYSFW_MATCH(SYSFW_SYS_VENDOR, "Dell Inc."),
+			SYSFW_MATCH(SYSFW_PRODUCT_NAME, "Dell DM061"),
 		},
 	},
 	{	/* Handle problems with rebooting on Dell 1300's */
 		.callback =3D set_bios_reboot,
 		.ident =3D "Dell PowerEdge 1300",
 		.matches =3D {
-			DMI_MATCH(DMI_SYS_VENDOR, "Dell Computer Corporation"),
-			DMI_MATCH(DMI_PRODUCT_NAME, "PowerEdge 1300/"),
+			SYSFW_MATCH(SYSFW_SYS_VENDOR,
+				    "Dell Computer Corporation"),
+			SYSFW_MATCH(SYSFW_PRODUCT_NAME, "PowerEdge 1300/"),
 		},
 	},
 	{	/* Handle problems with rebooting on Dell 300's */
 		.callback =3D set_bios_reboot,
 		.ident =3D "Dell PowerEdge 300",
 		.matches =3D {
-			DMI_MATCH(DMI_SYS_VENDOR, "Dell Computer Corporation"),
-			DMI_MATCH(DMI_PRODUCT_NAME, "PowerEdge 300/"),
+			SYSFW_MATCH(SYSFW_SYS_VENDOR,
+				    "Dell Computer Corporation"),
+			SYSFW_MATCH(SYSFW_PRODUCT_NAME, "PowerEdge 300/"),
 		},
 	},
 	{       /* Handle problems with rebooting on Dell Optiplex 745's SFF*/
 		.callback =3D set_bios_reboot,
 		.ident =3D "Dell OptiPlex 745",
 		.matches =3D {
-			DMI_MATCH(DMI_SYS_VENDOR, "Dell Inc."),
-			DMI_MATCH(DMI_PRODUCT_NAME, "OptiPlex 745"),
+			SYSFW_MATCH(SYSFW_SYS_VENDOR, "Dell Inc."),
+			SYSFW_MATCH(SYSFW_PRODUCT_NAME, "OptiPlex 745"),
 		},
 	},
 	{       /* Handle problems with rebooting on Dell Optiplex 745's DFF*/
 		.callback =3D set_bios_reboot,
 		.ident =3D "Dell OptiPlex 745",
 		.matches =3D {
-			DMI_MATCH(DMI_SYS_VENDOR, "Dell Inc."),
-			DMI_MATCH(DMI_PRODUCT_NAME, "OptiPlex 745"),
-			DMI_MATCH(DMI_BOARD_NAME, "0MM599"),
+			SYSFW_MATCH(SYSFW_SYS_VENDOR, "Dell Inc."),
+			SYSFW_MATCH(SYSFW_PRODUCT_NAME, "OptiPlex 745"),
+			SYSFW_MATCH(SYSFW_BOARD_NAME, "0MM599"),
 		},
 	},
 	{       /* Handle problems with rebooting on Dell Optiplex 745 with 0KW62=
6 */
 		.callback =3D set_bios_reboot,
 		.ident =3D "Dell OptiPlex 745",
 		.matches =3D {
-			DMI_MATCH(DMI_SYS_VENDOR, "Dell Inc."),
-			DMI_MATCH(DMI_PRODUCT_NAME, "OptiPlex 745"),
-			DMI_MATCH(DMI_BOARD_NAME, "0KW626"),
+			SYSFW_MATCH(SYSFW_SYS_VENDOR, "Dell Inc."),
+			SYSFW_MATCH(SYSFW_PRODUCT_NAME, "OptiPlex 745"),
+			SYSFW_MATCH(SYSFW_BOARD_NAME, "0KW626"),
 		},
 	},
 	{   /* Handle problems with rebooting on Dell Optiplex 330 with 0KP561 */
 		.callback =3D set_bios_reboot,
 		.ident =3D "Dell OptiPlex 330",
 		.matches =3D {
-			DMI_MATCH(DMI_SYS_VENDOR, "Dell Inc."),
-			DMI_MATCH(DMI_PRODUCT_NAME, "OptiPlex 330"),
-			DMI_MATCH(DMI_BOARD_NAME, "0KP561"),
+			SYSFW_MATCH(SYSFW_SYS_VENDOR, "Dell Inc."),
+			SYSFW_MATCH(SYSFW_PRODUCT_NAME, "OptiPlex 330"),
+			SYSFW_MATCH(SYSFW_BOARD_NAME, "0KP561"),
 		},
 	},
 	{   /* Handle problems with rebooting on Dell Optiplex 360 with 0T656F */
 		.callback =3D set_bios_reboot,
 		.ident =3D "Dell OptiPlex 360",
 		.matches =3D {
-			DMI_MATCH(DMI_SYS_VENDOR, "Dell Inc."),
-			DMI_MATCH(DMI_PRODUCT_NAME, "OptiPlex 360"),
-			DMI_MATCH(DMI_BOARD_NAME, "0T656F"),
+			SYSFW_MATCH(SYSFW_SYS_VENDOR, "Dell Inc."),
+			SYSFW_MATCH(SYSFW_PRODUCT_NAME, "OptiPlex 360"),
+			SYSFW_MATCH(SYSFW_BOARD_NAME, "0T656F"),
 		},
 	},
 	{	/* Handle problems with rebooting on Dell OptiPlex 760 with 0G919G*/
 		.callback =3D set_bios_reboot,
 		.ident =3D "Dell OptiPlex 760",
 		.matches =3D {
-			DMI_MATCH(DMI_SYS_VENDOR, "Dell Inc."),
-			DMI_MATCH(DMI_PRODUCT_NAME, "OptiPlex 760"),
-			DMI_MATCH(DMI_BOARD_NAME, "0G919G"),
+			SYSFW_MATCH(SYSFW_SYS_VENDOR, "Dell Inc."),
+			SYSFW_MATCH(SYSFW_PRODUCT_NAME, "OptiPlex 760"),
+			SYSFW_MATCH(SYSFW_BOARD_NAME, "0G919G"),
 		},
 	},
 	{	/* Handle problems with rebooting on Dell 2400's */
 		.callback =3D set_bios_reboot,
 		.ident =3D "Dell PowerEdge 2400",
 		.matches =3D {
-			DMI_MATCH(DMI_SYS_VENDOR, "Dell Computer Corporation"),
-			DMI_MATCH(DMI_PRODUCT_NAME, "PowerEdge 2400"),
+			SYSFW_MATCH(SYSFW_SYS_VENDOR,
+				    "Dell Computer Corporation"),
+			SYSFW_MATCH(SYSFW_PRODUCT_NAME, "PowerEdge 2400"),
 		},
 	},
 	{	/* Handle problems with rebooting on Dell T5400's */
 		.callback =3D set_bios_reboot,
 		.ident =3D "Dell Precision T5400",
 		.matches =3D {
-			DMI_MATCH(DMI_SYS_VENDOR, "Dell Inc."),
-			DMI_MATCH(DMI_PRODUCT_NAME, "Precision WorkStation T5400"),
+			SYSFW_MATCH(SYSFW_SYS_VENDOR, "Dell Inc."),
+			SYSFW_MATCH(SYSFW_PRODUCT_NAME,
+				    "Precision WorkStation T5400"),
 		},
 	},
 	{	/* Handle problems with rebooting on Dell T7400's */
 		.callback =3D set_bios_reboot,
 		.ident =3D "Dell Precision T7400",
 		.matches =3D {
-			DMI_MATCH(DMI_SYS_VENDOR, "Dell Inc."),
-			DMI_MATCH(DMI_PRODUCT_NAME, "Precision WorkStation T7400"),
+			SYSFW_MATCH(SYSFW_SYS_VENDOR, "Dell Inc."),
+			SYSFW_MATCH(SYSFW_PRODUCT_NAME,
+				    "Precision WorkStation T7400"),
 		},
 	},
 	{	/* Handle problems with rebooting on HP laptops */
 		.callback =3D set_bios_reboot,
 		.ident =3D "HP Compaq Laptop",
 		.matches =3D {
-			DMI_MATCH(DMI_SYS_VENDOR, "Hewlett-Packard"),
-			DMI_MATCH(DMI_PRODUCT_NAME, "HP Compaq"),
+			SYSFW_MATCH(SYSFW_SYS_VENDOR, "Hewlett-Packard"),
+			SYSFW_MATCH(SYSFW_PRODUCT_NAME, "HP Compaq"),
 		},
 	},
 	{	/* Handle problems with rebooting on Dell XPS710 */
 		.callback =3D set_bios_reboot,
 		.ident =3D "Dell XPS710",
 		.matches =3D {
-			DMI_MATCH(DMI_SYS_VENDOR, "Dell Inc."),
-			DMI_MATCH(DMI_PRODUCT_NAME, "Dell XPS710"),
+			SYSFW_MATCH(SYSFW_SYS_VENDOR, "Dell Inc."),
+			SYSFW_MATCH(SYSFW_PRODUCT_NAME, "Dell XPS710"),
 		},
 	},
 	{	/* Handle problems with rebooting on Dell DXP061 */
 		.callback =3D set_bios_reboot,
 		.ident =3D "Dell DXP061",
 		.matches =3D {
-			DMI_MATCH(DMI_SYS_VENDOR, "Dell Inc."),
-			DMI_MATCH(DMI_PRODUCT_NAME, "Dell DXP061"),
+			SYSFW_MATCH(SYSFW_SYS_VENDOR, "Dell Inc."),
+			SYSFW_MATCH(SYSFW_PRODUCT_NAME, "Dell DXP061"),
 		},
 	},
 	{	/* Handle problems with rebooting on Sony VGN-Z540N */
 		.callback =3D set_bios_reboot,
 		.ident =3D "Sony VGN-Z540N",
 		.matches =3D {
-			DMI_MATCH(DMI_SYS_VENDOR, "Sony Corporation"),
-			DMI_MATCH(DMI_PRODUCT_NAME, "VGN-Z540N"),
+			SYSFW_MATCH(SYSFW_SYS_VENDOR, "Sony Corporation"),
+			SYSFW_MATCH(SYSFW_PRODUCT_NAME, "VGN-Z540N"),
 		},
 	},
 	{	/* Handle problems with rebooting on CompuLab SBC-FITPC2 */
 		.callback =3D set_bios_reboot,
 		.ident =3D "CompuLab SBC-FITPC2",
 		.matches =3D {
-			DMI_MATCH(DMI_SYS_VENDOR, "CompuLab"),
-			DMI_MATCH(DMI_PRODUCT_NAME, "SBC-FITPC2"),
+			SYSFW_MATCH(SYSFW_SYS_VENDOR, "CompuLab"),
+			SYSFW_MATCH(SYSFW_PRODUCT_NAME, "SBC-FITPC2"),
 		},
 	},
 	{       /* Handle problems with rebooting on ASUS P4S800 */
 		.callback =3D set_bios_reboot,
 		.ident =3D "ASUS P4S800",
 		.matches =3D {
-			DMI_MATCH(DMI_BOARD_VENDOR, "ASUSTeK Computer INC."),
-			DMI_MATCH(DMI_BOARD_NAME, "P4S800"),
+			SYSFW_MATCH(SYSFW_BOARD_VENDOR,
+				    "ASUSTeK Computer INC."),
+			SYSFW_MATCH(SYSFW_BOARD_NAME, "P4S800"),
 		},
 	},
 	{	/* Handle problems with rebooting on VersaLogic Menlow boards */
 		.callback =3D set_bios_reboot,
 		.ident =3D "VersaLogic Menlow based board",
 		.matches =3D {
-			DMI_MATCH(DMI_BOARD_VENDOR, "VersaLogic Corporation"),
-			DMI_MATCH(DMI_BOARD_NAME, "VersaLogic Menlow board"),
+			SYSFW_MATCH(SYSFW_BOARD_VENDOR,
+				    "VersaLogic Corporation"),
+			SYSFW_MATCH(SYSFW_BOARD_NAME,
+				    "VersaLogic Menlow board"),
 		},
 	},
 	{ /* Handle reboot issue on Acer Aspire one */
 		.callback =3D set_bios_reboot,
 		.ident =3D "Acer Aspire One A110",
 		.matches =3D {
-			DMI_MATCH(DMI_SYS_VENDOR, "Acer"),
-			DMI_MATCH(DMI_PRODUCT_NAME, "AOA110"),
+			SYSFW_MATCH(SYSFW_SYS_VENDOR, "Acer"),
+			SYSFW_MATCH(SYSFW_PRODUCT_NAME, "AOA110"),
 		},
 	},
-	{ }
+	{}
 };
=20
 static int __init reboot_init(void)
 {
-	dmi_check_system(reboot_dmi_table);
+	sysfw_callback(reboot_id_table);
 	return 0;
 }
 core_initcall(reboot_init);
@@ -376,7 +384,7 @@ EXPORT_SYMBOL(machine_real_restart);
 /*
  * Some Apple MacBook and MacBookPro's needs reboot=3Dp to be able to rebo=
ot
  */
-static int __init set_pci_reboot(const struct dmi_system_id *d)
+static int __init set_pci_reboot(const struct sysfw_id *d)
 {
 	if (reboot_type !=3D BOOT_CF9) {
 		reboot_type =3D BOOT_CF9;
@@ -386,45 +394,45 @@ static int __init set_pci_reboot(const struct dmi_sys=
tem_id *d)
 	return 0;
 }
=20
-static struct dmi_system_id __initdata pci_reboot_dmi_table[] =3D {
+static struct sysfw_id __initdata pci_reboot_id_table[] =3D {
 	{	/* Handle problems with rebooting on Apple MacBook5 */
 		.callback =3D set_pci_reboot,
 		.ident =3D "Apple MacBook5",
 		.matches =3D {
-			DMI_MATCH(DMI_SYS_VENDOR, "Apple Inc."),
-			DMI_MATCH(DMI_PRODUCT_NAME, "MacBook5"),
+			SYSFW_MATCH(SYSFW_SYS_VENDOR, "Apple Inc."),
+			SYSFW_MATCH(SYSFW_PRODUCT_NAME, "MacBook5"),
 		},
 	},
 	{	/* Handle problems with rebooting on Apple MacBookPro5 */
 		.callback =3D set_pci_reboot,
 		.ident =3D "Apple MacBookPro5",
 		.matches =3D {
-			DMI_MATCH(DMI_SYS_VENDOR, "Apple Inc."),
-			DMI_MATCH(DMI_PRODUCT_NAME, "MacBookPro5"),
+			SYSFW_MATCH(SYSFW_SYS_VENDOR, "Apple Inc."),
+			SYSFW_MATCH(SYSFW_PRODUCT_NAME, "MacBookPro5"),
 		},
 	},
 	{	/* Handle problems with rebooting on Apple Macmini3,1 */
 		.callback =3D set_pci_reboot,
 		.ident =3D "Apple Macmini3,1",
 		.matches =3D {
-			DMI_MATCH(DMI_SYS_VENDOR, "Apple Inc."),
-			DMI_MATCH(DMI_PRODUCT_NAME, "Macmini3,1"),
+			SYSFW_MATCH(SYSFW_SYS_VENDOR, "Apple Inc."),
+			SYSFW_MATCH(SYSFW_PRODUCT_NAME, "Macmini3,1"),
 		},
 	},
 	{	/* Handle problems with rebooting on the iMac9,1. */
 		.callback =3D set_pci_reboot,
 		.ident =3D "Apple iMac9,1",
 		.matches =3D {
-			DMI_MATCH(DMI_SYS_VENDOR, "Apple Inc."),
-			DMI_MATCH(DMI_PRODUCT_NAME, "iMac9,1"),
+			SYSFW_MATCH(SYSFW_SYS_VENDOR, "Apple Inc."),
+			SYSFW_MATCH(SYSFW_PRODUCT_NAME, "iMac9,1"),
 		},
 	},
-	{ }
+	{}
 };
=20
 static int __init pci_reboot_init(void)
 {
-	dmi_check_system(pci_reboot_dmi_table);
+	sysfw_callback(pci_reboot_id_table);
 	return 0;
 }
 core_initcall(pci_reboot_init);
diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index afaf384..8b74838 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -44,7 +44,7 @@
 #include <linux/iscsi_ibft.h>
 #include <linux/nodemask.h>
 #include <linux/kexec.h>
-#include <linux/dmi.h>
+#include <linux/smbios.h>
 #include <linux/pfn.h>
 #include <linux/pci.h>
 #include <asm/pci-direct.h>
@@ -81,7 +81,7 @@
 #include <asm/timer.h>
 #include <asm/i8259.h>
 #include <asm/sections.h>
-#include <asm/dmi.h>
+#include <asm/smbios.h>
 #include <asm/io_apic.h>
 #include <asm/ist.h>
 #include <asm/setup_arch.h>
@@ -123,8 +123,8 @@
 unsigned long max_low_pfn_mapped;
 unsigned long max_pfn_mapped;
=20
-#ifdef CONFIG_DMI
-RESERVE_BRK(dmi_alloc, 65536);
+#ifdef CONFIG_SMBIOS
+RESERVE_BRK(smbios_alloc, SMBIOS_SIZE);
 #endif
=20
=20
@@ -834,11 +834,11 @@ void __init setup_arch(char **cmdline_p)
 	if (efi_enabled)
 		efi_init();
=20
-	dmi_scan_machine();
+	smbios_init();
=20
 	/*
-	 * VMware detection requires dmi to be available, so this
-	 * needs to be done after dmi_scan_machine, for the BP.
+	 * VMware detection requires smbios to be available, so this
+	 * needs to be done after smbios_init(), for the BP.
 	 */
 	init_hypervisor_platform();
=20
diff --git a/arch/x86/kernel/tsc.c b/arch/x86/kernel/tsc.c
index 6cc6922..36c4160 100644
--- a/arch/x86/kernel/tsc.c
+++ b/arch/x86/kernel/tsc.c
@@ -5,7 +5,7 @@
 #include <linux/timer.h>
 #include <linux/acpi_pmtmr.h>
 #include <linux/cpufreq.h>
-#include <linux/dmi.h>
+#include <linux/sysfw.h>
 #include <linux/delay.h>
 #include <linux/clocksource.h>
 #include <linux/percpu.h>
@@ -800,22 +800,22 @@ void mark_tsc_unstable(char *reason)
=20
 EXPORT_SYMBOL_GPL(mark_tsc_unstable);
=20
-static int __init dmi_mark_tsc_unstable(const struct dmi_system_id *d)
+static int __init quirk_mark_tsc_unstable(const struct sysfw_id *d)
 {
 	printk(KERN_NOTICE "%s detected: marking TSC unstable.\n",
-			d->ident);
+	       d->ident);
 	tsc_unstable =3D 1;
 	return 0;
 }
=20
 /* List of systems that have known TSC problems */
-static struct dmi_system_id __initdata bad_tsc_dmi_table[] =3D {
+static struct sysfw_id __initdata bad_tsc_table[] =3D {
 	{
-		.callback =3D dmi_mark_tsc_unstable,
+		.callback =3D quirk_mark_tsc_unstable,
 		.ident =3D "IBM Thinkpad 380XD",
 		.matches =3D {
-			DMI_MATCH(DMI_BOARD_VENDOR, "IBM"),
-			DMI_MATCH(DMI_BOARD_NAME, "2635FA0"),
+			SYSFW_MATCH(SYSFW_BOARD_VENDOR, "IBM"),
+			SYSFW_MATCH(SYSFW_BOARD_NAME, "2635FA0"),
 		},
 	},
 	{}
@@ -1011,7 +1011,7 @@ void __init tsc_init(void)
=20
 	use_tsc_delay();
 	/* Check and install the TSC clocksource */
-	dmi_check_system(bad_tsc_dmi_table);
+	sysfw_callback(bad_tsc_table);
=20
 	if (unsynchronized_tsc())
 		mark_tsc_unstable("TSCs unsynchronized");
diff --git a/arch/x86/pci/acpi.c b/arch/x86/pci/acpi.c
index 68c3c13..51517a1 100644
--- a/arch/x86/pci/acpi.c
+++ b/arch/x86/pci/acpi.c
@@ -2,7 +2,7 @@
 #include <linux/acpi.h>
 #include <linux/init.h>
 #include <linux/irq.h>
-#include <linux/dmi.h>
+#include <linux/sysfw.h>
 #include <linux/slab.h>
 #include <asm/numa.h>
 #include <asm/pci_x86.h>
@@ -18,20 +18,20 @@ struct pci_root_info {
=20
 static bool pci_use_crs =3D true;
=20
-static int __init set_use_crs(const struct dmi_system_id *id)
+static int __init set_use_crs(const struct sysfw_id *id)
 {
 	pci_use_crs =3D true;
 	return 0;
 }
=20
-static const struct dmi_system_id pci_use_crs_table[] __initconst =3D {
+static const struct sysfw_id pci_use_crs_table[] __initconst =3D {
 	/* http://bugzilla.kernel.org/show_bug.cgi?id=14183 */
 	{
 		.callback =3D set_use_crs,
 		.ident =3D "IBM System x3800",
 		.matches =3D {
-			DMI_MATCH(DMI_SYS_VENDOR, "IBM"),
-			DMI_MATCH(DMI_PRODUCT_NAME, "x3800"),
+			SYSFW_MATCH(SYSFW_SYS_VENDOR, "IBM"),
+			SYSFW_MATCH(SYSFW_PRODUCT_NAME, "x3800"),
 		},
 	},
 	/* https://bugzilla.kernel.org/show_bug.cgi?id=16007 */
@@ -40,7 +40,7 @@ static const struct dmi_system_id pci_use_crs_table[] __i=
nitconst =3D {
 		.callback =3D set_use_crs,
 		.ident =3D "ASRock ALiveSATA2-GLAN",
 		.matches =3D {
-			DMI_MATCH(DMI_PRODUCT_NAME, "ALiveSATA2-GLAN"),
+			SYSFW_MATCH(SYSFW_PRODUCT_NAME, "ALiveSATA2-GLAN"),
                 },
         },
 	{}
@@ -48,12 +48,10 @@ static const struct dmi_system_id pci_use_crs_table[] _=
_initconst =3D {
=20
 void __init pci_acpi_crs_quirks(void)
 {
-	int year;
-
-	if (dmi_get_date(DMI_BIOS_DATE, &year, NULL, NULL) && year < 2008)
+	if (!(sysfw_get_date() >=3D 20080000))
 		pci_use_crs =3D false;
=20
-	dmi_check_system(pci_use_crs_table);
+	sysfw_callback(pci_use_crs_table);
=20
 	/*
 	 * If the user specifies "pci=3Duse_crs" or "pci=3Dnocrs" explicitly, that
diff --git a/arch/x86/pci/broadcom_bus.c b/arch/x86/pci/broadcom_bus.c
index ab8269b..c332b7b 100644
--- a/arch/x86/pci/broadcom_bus.c
+++ b/arch/x86/pci/broadcom_bus.c
@@ -11,7 +11,6 @@
=20
 #include <linux/acpi.h>
 #include <linux/delay.h>
-#include <linux/dmi.h>
 #include <linux/pci.h>
 #include <linux/init.h>
 #include <asm/pci_x86.h>
diff --git a/arch/x86/pci/common.c b/arch/x86/pci/common.c
index 5fe7502..ee193bd 100644
--- a/arch/x86/pci/common.c
+++ b/arch/x86/pci/common.c
@@ -8,7 +8,8 @@
 #include <linux/pci.h>
 #include <linux/ioport.h>
 #include <linux/init.h>
-#include <linux/dmi.h>
+#include <linux/smbios.h>
+#include <linux/sysfw.h>
 #include <linux/slab.h>
=20
 #include <asm/acpi.h>
@@ -79,14 +80,15 @@ struct pci_ops pci_root_ops =3D {
  */
 DEFINE_RAW_SPINLOCK(pci_config_lock);
=20
-static int __devinit can_skip_ioresource_align(const struct dmi_system_id =
*d)
+static int __devinit can_skip_ioresource_align(const struct sysfw_id *d)
 {
 	pci_probe |=3D PCI_CAN_SKIP_ISA_ALIGN;
 	printk(KERN_INFO "PCI: %s detected, can skip ISA alignment\n", d->ident);
 	return 0;
 }
=20
-static const struct dmi_system_id can_skip_pciprobe_dmi_table[] __devinitc=
onst =3D {
+static const struct sysfw_id
+can_skip_pciprobe_smbios_table[] __devinitconst =3D {
 /*
  * Systems where PCI IO resource ISA alignment can be skipped
  * when the ISA enable bit in the bridge control is not set
@@ -95,32 +97,32 @@ static const struct dmi_system_id can_skip_pciprobe_dmi=
_table[] __devinitconst  		.callback =3D can_skip_ioresource_align,
 		.ident =3D "IBM System x3800",
 		.matches =3D {
-			DMI_MATCH(DMI_SYS_VENDOR, "IBM"),
-			DMI_MATCH(DMI_PRODUCT_NAME, "x3800"),
+			SYSFW_MATCH(SYSFW_SYS_VENDOR, "IBM"),
+			SYSFW_MATCH(SYSFW_PRODUCT_NAME, "x3800"),
 		},
 	},
 	{
 		.callback =3D can_skip_ioresource_align,
 		.ident =3D "IBM System x3850",
 		.matches =3D {
-			DMI_MATCH(DMI_SYS_VENDOR, "IBM"),
-			DMI_MATCH(DMI_PRODUCT_NAME, "x3850"),
+			SYSFW_MATCH(SYSFW_SYS_VENDOR, "IBM"),
+			SYSFW_MATCH(SYSFW_PRODUCT_NAME, "x3850"),
 		},
 	},
 	{
 		.callback =3D can_skip_ioresource_align,
 		.ident =3D "IBM System x3950",
 		.matches =3D {
-			DMI_MATCH(DMI_SYS_VENDOR, "IBM"),
-			DMI_MATCH(DMI_PRODUCT_NAME, "x3950"),
+			SYSFW_MATCH(SYSFW_SYS_VENDOR, "IBM"),
+			SYSFW_MATCH(SYSFW_PRODUCT_NAME, "x3950"),
 		},
 	},
 	{}
 };
=20
-void __init dmi_check_skip_isa_align(void)
+void __init smbios_check_skip_isa_align(void)
 {
-	dmi_check_system(can_skip_pciprobe_dmi_table);
+	sysfw_callback(can_skip_pciprobe_smbios_table);
 }
=20
 static void __devinit pcibios_fixup_device_resources(struct pci_dev *dev)
@@ -173,32 +175,37 @@ void __devinit pcibios_fixup_bus(struct pci_bus *b)
 }
=20
 /*
- * Only use DMI information to set this if nothing was passed
+ * Only use SMBIOS information to set this if nothing was passed
  * on the kernel command line (which was parsed earlier).
  */
=20
-static int __devinit set_bf_sort(const struct dmi_system_id *d)
+static int __devinit set_bf_sort(const struct sysfw_id *d)
 {
 	if (pci_bf_sort =3D pci_bf_sort_default) {
-		pci_bf_sort =3D pci_dmi_bf;
+		pci_bf_sort =3D pci_smbios_bf;
 		printk(KERN_INFO "PCI: %s detected, enabling pci=BFsort.\n", d->ident);
 	}
 	return 0;
 }
=20
-static void __devinit read_dmi_type_b1(const struct dmi_header *dm,
-				       void *private_data)
+static int __devinit dell_sort_method_decode(const union smbios_struct *ss,
+					     void *data)
 {
-	u8 *d =3D (u8 *)dm + 4;
+	u8 *p;
+	const struct sysfw_id *d =3D (const struct sysfw_id *)data;
=20
-	if (dm->type !=3D 0xB1)
-		return;
-	switch (((*(u32 *)d) >> 9) & 0x03) {
+	if ((ss->header.type) !=3D 0xb1)
+		return SMBIOS_WALK_CONTINUE;
+
+	p =3D (u8 *)ss + 4;
+	switch (((*(u32 *)p) >> 9) & 0x03) {
 	case 0x00:
-		printk(KERN_INFO "dmi type 0xB1 record - unknown flag\n");
+		printk(KERN_INFO "smbios type 0xB1 record - unknown flag\n");
 		break;
 	case 0x01: /* set pci=BFsort */
 		smbios_type_b1_flag =3D 1;
+		set_bf_sort(d);
+		return SMBIOS_WALK_STOP;
 		break;
 	case 0x02: /* do not set pci=BFsort */
 		smbios_type_b1_flag =3D 2;
@@ -206,24 +213,22 @@ static void __devinit read_dmi_type_b1(const struct d=
mi_header *dm,
 	default:
 		break;
 	}
-}
=20
-static int __devinit find_sort_method(const struct dmi_system_id *d)
-{
-	dmi_walk(read_dmi_type_b1, NULL);
+	return SMBIOS_WALK_STOP;
=20
-	if (smbios_type_b1_flag =3D 1) {
-		set_bf_sort(d);
-		return 0;
-	}
-	return -1;
+}
+static int __devinit find_sort_method(const struct sysfw_id *d)
+{
+	if (smbios_walk(dell_sort_method_decode, (void *)d))
+		return 1;
+	return 0;
 }
=20
 /*
  * Enable renumbering of PCI bus# ranges to reach all PCI busses (Cardbus)
  */
 #ifdef __i386__
-static int __devinit assign_all_busses(const struct dmi_system_id *d)
+static int __devinit assign_all_busses(const struct sysfw_id *d)
 {
 	pci_probe |=3D PCI_ASSIGN_ALL_BUSSES;
 	printk(KERN_INFO "%s detected: enabling PCI bus# renumbering"
@@ -232,7 +237,7 @@ static int __devinit assign_all_busses(const struct dmi=
_system_id *d)
 }
 #endif
=20
-static const struct dmi_system_id __devinitconst pciprobe_dmi_table[] =3D {
+static const struct sysfw_id __devinitconst pciprobe_smbios_table[] =3D {
 #ifdef __i386__
 /*
  * Laptops which need pci=3Dassign-busses to see Cardbus cards
@@ -241,8 +246,8 @@ static const struct dmi_system_id __devinitconst pcipro=
be_dmi_table[] =3D {
 		.callback =3D assign_all_busses,
 		.ident =3D "Samsung X20 Laptop",
 		.matches =3D {
-			DMI_MATCH(DMI_SYS_VENDOR, "Samsung Electronics"),
-			DMI_MATCH(DMI_PRODUCT_NAME, "SX20S"),
+			SYSFW_MATCH(SYSFW_SYS_VENDOR, "Samsung Electronics"),
+			SYSFW_MATCH(SYSFW_PRODUCT_NAME, "SX20S"),
 		},
 	},
 #endif		/* __i386__ */
@@ -250,151 +255,151 @@ static const struct dmi_system_id __devinitconst pc=
iprobe_dmi_table[] =3D {
 		.callback =3D find_sort_method,
 		.ident =3D "Dell System",
 		.matches =3D {
-			DMI_MATCH(DMI_SYS_VENDOR, "Dell Inc"),
+			SYSFW_MATCH(SYSFW_SYS_VENDOR, "Dell Inc"),
 		},
 	},
 	{
 		.callback =3D set_bf_sort,
 		.ident =3D "Dell PowerEdge 1950",
 		.matches =3D {
-			DMI_MATCH(DMI_SYS_VENDOR, "Dell"),
-			DMI_MATCH(DMI_PRODUCT_NAME, "PowerEdge 1950"),
+			SYSFW_MATCH(SYSFW_SYS_VENDOR, "Dell"),
+			SYSFW_MATCH(SYSFW_PRODUCT_NAME, "PowerEdge 1950"),
 		},
 	},
 	{
 		.callback =3D set_bf_sort,
 		.ident =3D "Dell PowerEdge 1955",
 		.matches =3D {
-			DMI_MATCH(DMI_SYS_VENDOR, "Dell"),
-			DMI_MATCH(DMI_PRODUCT_NAME, "PowerEdge 1955"),
+			SYSFW_MATCH(SYSFW_SYS_VENDOR, "Dell"),
+			SYSFW_MATCH(SYSFW_PRODUCT_NAME, "PowerEdge 1955"),
 		},
 	},
 	{
 		.callback =3D set_bf_sort,
 		.ident =3D "Dell PowerEdge 2900",
 		.matches =3D {
-			DMI_MATCH(DMI_SYS_VENDOR, "Dell"),
-			DMI_MATCH(DMI_PRODUCT_NAME, "PowerEdge 2900"),
+			SYSFW_MATCH(SYSFW_SYS_VENDOR, "Dell"),
+			SYSFW_MATCH(SYSFW_PRODUCT_NAME, "PowerEdge 2900"),
 		},
 	},
 	{
 		.callback =3D set_bf_sort,
 		.ident =3D "Dell PowerEdge 2950",
 		.matches =3D {
-			DMI_MATCH(DMI_SYS_VENDOR, "Dell"),
-			DMI_MATCH(DMI_PRODUCT_NAME, "PowerEdge 2950"),
+			SYSFW_MATCH(SYSFW_SYS_VENDOR, "Dell"),
+			SYSFW_MATCH(SYSFW_PRODUCT_NAME, "PowerEdge 2950"),
 		},
 	},
 	{
 		.callback =3D set_bf_sort,
 		.ident =3D "Dell PowerEdge R900",
 		.matches =3D {
-			DMI_MATCH(DMI_SYS_VENDOR, "Dell"),
-			DMI_MATCH(DMI_PRODUCT_NAME, "PowerEdge R900"),
+			SYSFW_MATCH(SYSFW_SYS_VENDOR, "Dell"),
+			SYSFW_MATCH(SYSFW_PRODUCT_NAME, "PowerEdge R900"),
 		},
 	},
 	{
 		.callback =3D set_bf_sort,
 		.ident =3D "HP ProLiant BL20p G3",
 		.matches =3D {
-			DMI_MATCH(DMI_SYS_VENDOR, "HP"),
-			DMI_MATCH(DMI_PRODUCT_NAME, "ProLiant BL20p G3"),
+			SYSFW_MATCH(SYSFW_SYS_VENDOR, "HP"),
+			SYSFW_MATCH(SYSFW_PRODUCT_NAME, "ProLiant BL20p G3"),
 		},
 	},
 	{
 		.callback =3D set_bf_sort,
 		.ident =3D "HP ProLiant BL20p G4",
 		.matches =3D {
-			DMI_MATCH(DMI_SYS_VENDOR, "HP"),
-			DMI_MATCH(DMI_PRODUCT_NAME, "ProLiant BL20p G4"),
+			SYSFW_MATCH(SYSFW_SYS_VENDOR, "HP"),
+			SYSFW_MATCH(SYSFW_PRODUCT_NAME, "ProLiant BL20p G4"),
 		},
 	},
 	{
 		.callback =3D set_bf_sort,
 		.ident =3D "HP ProLiant BL30p G1",
 		.matches =3D {
-			DMI_MATCH(DMI_SYS_VENDOR, "HP"),
-			DMI_MATCH(DMI_PRODUCT_NAME, "ProLiant BL30p G1"),
+			SYSFW_MATCH(SYSFW_SYS_VENDOR, "HP"),
+			SYSFW_MATCH(SYSFW_PRODUCT_NAME, "ProLiant BL30p G1"),
 		},
 	},
 	{
 		.callback =3D set_bf_sort,
 		.ident =3D "HP ProLiant BL25p G1",
 		.matches =3D {
-			DMI_MATCH(DMI_SYS_VENDOR, "HP"),
-			DMI_MATCH(DMI_PRODUCT_NAME, "ProLiant BL25p G1"),
+			SYSFW_MATCH(SYSFW_SYS_VENDOR, "HP"),
+			SYSFW_MATCH(SYSFW_PRODUCT_NAME, "ProLiant BL25p G1"),
 		},
 	},
 	{
 		.callback =3D set_bf_sort,
 		.ident =3D "HP ProLiant BL35p G1",
 		.matches =3D {
-			DMI_MATCH(DMI_SYS_VENDOR, "HP"),
-			DMI_MATCH(DMI_PRODUCT_NAME, "ProLiant BL35p G1"),
+			SYSFW_MATCH(SYSFW_SYS_VENDOR, "HP"),
+			SYSFW_MATCH(SYSFW_PRODUCT_NAME, "ProLiant BL35p G1"),
 		},
 	},
 	{
 		.callback =3D set_bf_sort,
 		.ident =3D "HP ProLiant BL45p G1",
 		.matches =3D {
-			DMI_MATCH(DMI_SYS_VENDOR, "HP"),
-			DMI_MATCH(DMI_PRODUCT_NAME, "ProLiant BL45p G1"),
+			SYSFW_MATCH(SYSFW_SYS_VENDOR, "HP"),
+			SYSFW_MATCH(SYSFW_PRODUCT_NAME, "ProLiant BL45p G1"),
 		},
 	},
 	{
 		.callback =3D set_bf_sort,
 		.ident =3D "HP ProLiant BL45p G2",
 		.matches =3D {
-			DMI_MATCH(DMI_SYS_VENDOR, "HP"),
-			DMI_MATCH(DMI_PRODUCT_NAME, "ProLiant BL45p G2"),
+			SYSFW_MATCH(SYSFW_SYS_VENDOR, "HP"),
+			SYSFW_MATCH(SYSFW_PRODUCT_NAME, "ProLiant BL45p G2"),
 		},
 	},
 	{
 		.callback =3D set_bf_sort,
 		.ident =3D "HP ProLiant BL460c G1",
 		.matches =3D {
-			DMI_MATCH(DMI_SYS_VENDOR, "HP"),
-			DMI_MATCH(DMI_PRODUCT_NAME, "ProLiant BL460c G1"),
+			SYSFW_MATCH(SYSFW_SYS_VENDOR, "HP"),
+			SYSFW_MATCH(SYSFW_PRODUCT_NAME, "ProLiant BL460c G1"),
 		},
 	},
 	{
 		.callback =3D set_bf_sort,
 		.ident =3D "HP ProLiant BL465c G1",
 		.matches =3D {
-			DMI_MATCH(DMI_SYS_VENDOR, "HP"),
-			DMI_MATCH(DMI_PRODUCT_NAME, "ProLiant BL465c G1"),
+			SYSFW_MATCH(SYSFW_SYS_VENDOR, "HP"),
+			SYSFW_MATCH(SYSFW_PRODUCT_NAME, "ProLiant BL465c G1"),
 		},
 	},
 	{
 		.callback =3D set_bf_sort,
 		.ident =3D "HP ProLiant BL480c G1",
 		.matches =3D {
-			DMI_MATCH(DMI_SYS_VENDOR, "HP"),
-			DMI_MATCH(DMI_PRODUCT_NAME, "ProLiant BL480c G1"),
+			SYSFW_MATCH(SYSFW_SYS_VENDOR, "HP"),
+			SYSFW_MATCH(SYSFW_PRODUCT_NAME, "ProLiant BL480c G1"),
 		},
 	},
 	{
 		.callback =3D set_bf_sort,
 		.ident =3D "HP ProLiant BL685c G1",
 		.matches =3D {
-			DMI_MATCH(DMI_SYS_VENDOR, "HP"),
-			DMI_MATCH(DMI_PRODUCT_NAME, "ProLiant BL685c G1"),
+			SYSFW_MATCH(SYSFW_SYS_VENDOR, "HP"),
+			SYSFW_MATCH(SYSFW_PRODUCT_NAME, "ProLiant BL685c G1"),
 		},
 	},
 	{
 		.callback =3D set_bf_sort,
 		.ident =3D "HP ProLiant DL360",
 		.matches =3D {
-			DMI_MATCH(DMI_SYS_VENDOR, "HP"),
-			DMI_MATCH(DMI_PRODUCT_NAME, "ProLiant DL360"),
+			SYSFW_MATCH(SYSFW_SYS_VENDOR, "HP"),
+			SYSFW_MATCH(SYSFW_PRODUCT_NAME, "ProLiant DL360"),
 		},
 	},
 	{
 		.callback =3D set_bf_sort,
 		.ident =3D "HP ProLiant DL380",
 		.matches =3D {
-			DMI_MATCH(DMI_SYS_VENDOR, "HP"),
-			DMI_MATCH(DMI_PRODUCT_NAME, "ProLiant DL380"),
+			SYSFW_MATCH(SYSFW_SYS_VENDOR, "HP"),
+			SYSFW_MATCH(SYSFW_PRODUCT_NAME, "ProLiant DL380"),
 		},
 	},
 #ifdef __i386__
@@ -402,8 +407,8 @@ static const struct dmi_system_id __devinitconst pcipro=
be_dmi_table[] =3D {
 		.callback =3D assign_all_busses,
 		.ident =3D "Compaq EVO N800c",
 		.matches =3D {
-			DMI_MATCH(DMI_SYS_VENDOR, "Compaq"),
-			DMI_MATCH(DMI_PRODUCT_NAME, "EVO N800c"),
+			SYSFW_MATCH(SYSFW_SYS_VENDOR, "Compaq"),
+			SYSFW_MATCH(SYSFW_PRODUCT_NAME, "EVO N800c"),
 		},
 	},
 #endif
@@ -411,24 +416,24 @@ static const struct dmi_system_id __devinitconst pcip=
robe_dmi_table[] =3D {
 		.callback =3D set_bf_sort,
 		.ident =3D "HP ProLiant DL385 G2",
 		.matches =3D {
-			DMI_MATCH(DMI_SYS_VENDOR, "HP"),
-			DMI_MATCH(DMI_PRODUCT_NAME, "ProLiant DL385 G2"),
+			SYSFW_MATCH(SYSFW_SYS_VENDOR, "HP"),
+			SYSFW_MATCH(SYSFW_PRODUCT_NAME, "ProLiant DL385 G2"),
 		},
 	},
 	{
 		.callback =3D set_bf_sort,
 		.ident =3D "HP ProLiant DL585 G2",
 		.matches =3D {
-			DMI_MATCH(DMI_SYS_VENDOR, "HP"),
-			DMI_MATCH(DMI_PRODUCT_NAME, "ProLiant DL585 G2"),
+			SYSFW_MATCH(SYSFW_SYS_VENDOR, "HP"),
+			SYSFW_MATCH(SYSFW_PRODUCT_NAME, "ProLiant DL585 G2"),
 		},
 	},
 	{}
 };
=20
-void __init dmi_check_pciprobe(void)
+void __init smbios_check_pciprobe(void)
 {
-	dmi_check_system(pciprobe_dmi_table);
+	sysfw_callback(pciprobe_smbios_table);
 }
=20
 struct pci_bus * __devinit pcibios_scan_root(int busnum)
diff --git a/arch/x86/pci/direct.c b/arch/x86/pci/direct.c
index e6fd847..217d788 100644
--- a/arch/x86/pci/direct.c
+++ b/arch/x86/pci/direct.c
@@ -4,7 +4,7 @@
=20
 #include <linux/pci.h>
 #include <linux/init.h>
-#include <linux/dmi.h>
+#include <linux/sysfw.h>
 #include <asm/pci_x86.h>
=20
 /*
@@ -192,14 +192,13 @@ struct pci_raw_ops pci_direct_conf2 =3D {
 static int __init pci_sanity_check(struct pci_raw_ops *o)
 {
 	u32 x =3D 0;
-	int year, devfn;
+	int devfn;
=20
 	if (pci_probe & PCI_NO_CHECKS)
 		return 1;
 	/* Assume Type 1 works for newer systems.
 	   This handles machines that don't have anything on PCI Bus 0. */
-	dmi_get_date(DMI_BIOS_DATE, &year, NULL, NULL);
-	if (year >=3D 2001)
+	if (sysfw_get_date() >=3D 20010000)
 		return 1;
=20
 	for (devfn =3D 0; devfn < 0x100; devfn++) {
diff --git a/arch/x86/pci/fixup.c b/arch/x86/pci/fixup.c
index 6dd8955..381c136 100644
--- a/arch/x86/pci/fixup.c
+++ b/arch/x86/pci/fixup.c
@@ -3,7 +3,7 @@
  */
=20
 #include <linux/delay.h>
-#include <linux/dmi.h>
+#include <linux/sysfw.h>
 #include <linux/pci.h>
 #include <linux/init.h>
 #include <asm/pci_x86.h>
@@ -356,12 +356,12 @@ static void __devinit pci_fixup_video(struct pci_dev =
*pdev)
 DECLARE_PCI_FIXUP_FINAL(PCI_ANY_ID, PCI_ANY_ID, pci_fixup_video);
=20
=20
-static const struct dmi_system_id __devinitconst msi_k8t_dmi_table[] =3D {
+static const struct sysfw_id __devinitconst msi_k8t_quirk_table[] =3D {
 	{
 		.ident =3D "MSI-K8T-Neo2Fir",
 		.matches =3D {
-			DMI_MATCH(DMI_SYS_VENDOR, "MSI"),
-			DMI_MATCH(DMI_PRODUCT_NAME, "MS-6702E"),
+			SYSFW_MATCH(SYSFW_SYS_VENDOR, "MSI"),
+			SYSFW_MATCH(SYSFW_PRODUCT_NAME, "MS-6702E"),
 		},
 	},
 	{}
@@ -375,12 +375,12 @@ static const struct dmi_system_id __devinitconst msi_=
k8t_dmi_table[] =3D {
  * the corresponding register-value to enable the soundcard.
  *
  * The soundcard is only enabled, if the mainborad is identified
- * via DMI-tables and the soundcard is detected to be off.
+ * via SMBIOS tables and the soundcard is detected to be off.
  */
 static void __devinit pci_fixup_msi_k8t_onboard_sound(struct pci_dev *dev)
 {
 	unsigned char val;
-	if (!dmi_check_system(msi_k8t_dmi_table))
+	if (!sysfw_callback(msi_k8t_quirk_table))
 		return; /* only applies to MSI K8T Neo2-FIR */
=20
 	pci_read_config_byte(dev, 0x50, &val);
@@ -413,34 +413,35 @@ DECLARE_PCI_FIXUP_RESUME(PCI_VENDOR_ID_VIA, PCI_DEVIC=
E_ID_VIA_8237,
  */
 static u16 toshiba_line_size;
=20
-static const struct dmi_system_id __devinitconst toshiba_ohci1394_dmi_tabl=
e[] =3D {
+static const struct sysfw_id __devinitconst
+toshiba_ohci1394_quirk_table[] =3D {
 	{
 		.ident =3D "Toshiba PS5 based laptop",
 		.matches =3D {
-			DMI_MATCH(DMI_SYS_VENDOR, "TOSHIBA"),
-			DMI_MATCH(DMI_PRODUCT_VERSION, "PS5"),
+			SYSFW_MATCH(SYSFW_SYS_VENDOR, "TOSHIBA"),
+			SYSFW_MATCH(SYSFW_PRODUCT_VERSION, "PS5"),
 		},
 	},
 	{
 		.ident =3D "Toshiba PSM4 based laptop",
 		.matches =3D {
-			DMI_MATCH(DMI_SYS_VENDOR, "TOSHIBA"),
-			DMI_MATCH(DMI_PRODUCT_VERSION, "PSM4"),
+			SYSFW_MATCH(SYSFW_SYS_VENDOR, "TOSHIBA"),
+			SYSFW_MATCH(SYSFW_PRODUCT_VERSION, "PSM4"),
 		},
 	},
 	{
 		.ident =3D "Toshiba A40 based laptop",
 		.matches =3D {
-			DMI_MATCH(DMI_SYS_VENDOR, "TOSHIBA"),
-			DMI_MATCH(DMI_PRODUCT_VERSION, "PSA40U"),
+			SYSFW_MATCH(SYSFW_SYS_VENDOR, "TOSHIBA"),
+			SYSFW_MATCH(SYSFW_PRODUCT_VERSION, "PSA40U"),
 		},
 	},
-	{ }
+	{}
 };
=20
 static void __devinit pci_pre_fixup_toshiba_ohci1394(struct pci_dev *dev)
 {
-	if (!dmi_check_system(toshiba_ohci1394_dmi_table))
+	if (!sysfw_callback(toshiba_ohci1394_quirk_table))
 		return; /* only applies to certain Toshibas (so far) */
=20
 	dev->current_state =3D PCI_D3cold;
@@ -451,7 +452,7 @@ DECLARE_PCI_FIXUP_HEADER(PCI_VENDOR_ID_TI, 0x8032,
=20
 static void __devinit pci_post_fixup_toshiba_ohci1394(struct pci_dev *dev)
 {
-	if (!dmi_check_system(toshiba_ohci1394_dmi_table))
+	if (!sysfw_callback(toshiba_ohci1394_quirk_table))
 		return; /* only applies to certain Toshibas (so far) */
=20
 	/* Restore config space on Toshiba laptops */
diff --git a/arch/x86/pci/init.c b/arch/x86/pci/init.c
index adb62aa..9afdbc3 100644
--- a/arch/x86/pci/init.c
+++ b/arch/x86/pci/init.c
@@ -35,9 +35,9 @@ static __init int pci_arch_init(void)
 		printk(KERN_ERR
 		"PCI: Fatal: No config space access function found\n");
=20
-	dmi_check_pciprobe();
+	smbios_check_pciprobe();
=20
-	dmi_check_skip_isa_align();
+	smbios_check_skip_isa_align();
=20
 	return 0;
 }
diff --git a/arch/x86/pci/irq.c b/arch/x86/pci/irq.c
index 372e9b8..3e2ac8f 100644
--- a/arch/x86/pci/irq.c
+++ b/arch/x86/pci/irq.c
@@ -9,7 +9,7 @@
 #include <linux/pci.h>
 #include <linux/init.h>
 #include <linux/interrupt.h>
-#include <linux/dmi.h>
+#include <linux/sysfw.h>
 #include <linux/io.h>
 #include <linux/smp.h>
 #include <asm/io_apic.h>
@@ -1070,7 +1070,7 @@ void __init pcibios_fixup_irqs(void)
  * Work around broken HP Pavilion Notebooks which assign USB to
  * IRQ 9 even though it is actually wired to IRQ 11
  */
-static int __init fix_broken_hp_bios_irq9(const struct dmi_system_id *d)
+static int __init fix_broken_hp_bios_irq9(const struct sysfw_id *d)
 {
 	if (!broken_hp_bios_irq9) {
 		broken_hp_bios_irq9 =3D 1;
@@ -1084,7 +1084,7 @@ static int __init fix_broken_hp_bios_irq9(const struc=
t dmi_system_id *d)
  * Work around broken Acer TravelMate 360 Notebooks which assign
  * Cardbus to IRQ 11 even though it is actually wired to IRQ 10
  */
-static int __init fix_acer_tm360_irqrouting(const struct dmi_system_id *d)
+static int __init fix_acer_tm360_irqrouting(const struct sysfw_id *d)
 {
 	if (!acer_tm360_irqrouting) {
 		acer_tm360_irqrouting =3D 1;
@@ -1094,27 +1094,27 @@ static int __init fix_acer_tm360_irqrouting(const s=
truct dmi_system_id *d)
 	return 0;
 }
=20
-static struct dmi_system_id __initdata pciirq_dmi_table[] =3D {
+static struct sysfw_id __initdata pciirq_quirk_table[] =3D {
 	{
 		.callback =3D fix_broken_hp_bios_irq9,
 		.ident =3D "HP Pavilion N5400 Series Laptop",
 		.matches =3D {
-			DMI_MATCH(DMI_SYS_VENDOR, "Hewlett-Packard"),
-			DMI_MATCH(DMI_BIOS_VERSION, "GE.M1.03"),
-			DMI_MATCH(DMI_PRODUCT_VERSION,
-				"HP Pavilion Notebook Model GE"),
-			DMI_MATCH(DMI_BOARD_VERSION, "OmniBook N32N-736"),
+			SYSFW_MATCH(SYSFW_SYS_VENDOR, "Hewlett-Packard"),
+			SYSFW_MATCH(SYSFW_BIOS_VERSION, "GE.M1.03"),
+			SYSFW_MATCH(SYSFW_PRODUCT_VERSION,
+				    "HP Pavilion Notebook Model GE"),
+			SYSFW_MATCH(SYSFW_BOARD_VERSION, "OmniBook N32N-736"),
 		},
 	},
 	{
 		.callback =3D fix_acer_tm360_irqrouting,
 		.ident =3D "Acer TravelMate 36x Laptop",
 		.matches =3D {
-			DMI_MATCH(DMI_SYS_VENDOR, "Acer"),
-			DMI_MATCH(DMI_PRODUCT_NAME, "TravelMate 360"),
+			SYSFW_MATCH(SYSFW_SYS_VENDOR, "Acer"),
+			SYSFW_MATCH(SYSFW_PRODUCT_NAME, "TravelMate 360"),
 		},
 	},
-	{ }
+	{}
 };
=20
 void __init pcibios_irq_init(void)
@@ -1124,7 +1124,7 @@ void __init pcibios_irq_init(void)
 	if (raw_pci_ops =3D NULL)
 		return;
=20
-	dmi_check_system(pciirq_dmi_table);
+	sysfw_callback(pciirq_quirk_table);
=20
 	pirq_table =3D pirq_find_routing_table();
=20
diff --git a/arch/x86/pci/mmconfig-shared.c b/arch/x86/pci/mmconfig-shared.c
index 750c346..730b36b 100644
--- a/arch/x86/pci/mmconfig-shared.c
+++ b/arch/x86/pci/mmconfig-shared.c
@@ -15,7 +15,7 @@
 #include <linux/acpi.h>
 #include <linux/sfi_acpi.h>
 #include <linux/bitmap.h>
-#include <linux/dmi.h>
+#include <linux/sysfw.h>
 #include <linux/slab.h>
 #include <asm/e820.h>
 #include <asm/pci_x86.h>
@@ -514,19 +514,15 @@ static int __initdata known_bridge;
 static int __init acpi_mcfg_check_entry(struct acpi_table_mcfg *mcfg,
 					struct acpi_mcfg_allocation *cfg)
 {
-	int year;
-
 	if (cfg->address < 0xFFFFFFFF)
 		return 0;
=20
 	if (!strcmp(mcfg->header.oem_id, "SGI"))
 		return 0;
=20
-	if (mcfg->header.revision >=3D 1) {
-		if (dmi_get_date(DMI_BIOS_DATE, &year, NULL, NULL) &&
-		    year >=3D 2010)
+	if (mcfg->header.revision >=3D 1)
+		if (sysfw_get_date() >=3D 20100000)
 			return 0;
-	}
=20
 	printk(KERN_ERR PREFIX "MCFG region for %04x [bus %02x-%02x] at %#llx "
 	       "is above 4GB, ignored\n", cfg->pci_segment,
diff --git a/arch/x86/pci/mrst.c b/arch/x86/pci/mrst.c
index cb29191..741dbb0 100644
--- a/arch/x86/pci/mrst.c
+++ b/arch/x86/pci/mrst.c
@@ -22,7 +22,6 @@
 #include <linux/pci.h>
 #include <linux/ioport.h>
 #include <linux/init.h>
-#include <linux/dmi.h>
=20
 #include <asm/acpi.h>
 #include <asm/segment.h>
diff --git a/drivers/cpufreq/acpi-cpufreq.c b/drivers/cpufreq/acpi-cpufreq.c
index 596d5dd..6880c41 100644
--- a/drivers/cpufreq/acpi-cpufreq.c
+++ b/drivers/cpufreq/acpi-cpufreq.c
@@ -32,7 +32,7 @@
 #include <linux/sched.h>
 #include <linux/cpufreq.h>
 #include <linux/compiler.h>
-#include <linux/dmi.h>
+#include <linux/sysfw.h>
 #include <linux/slab.h>
=20
 #include <linux/acpi.h>
@@ -462,23 +462,23 @@ static int __init acpi_cpufreq_early_init(void)
  */
 static int bios_with_sw_any_bug;
=20
-static int sw_any_bug_found(const struct dmi_system_id *d)
+static int sw_any_bug_found(const struct sysfw_id *d)
 {
 	bios_with_sw_any_bug =3D 1;
 	return 0;
 }
=20
-static const struct dmi_system_id sw_any_bug_dmi_table[] =3D {
+static const struct sysfw_id sw_any_bug_table[] =3D {
 	{
 		.callback =3D sw_any_bug_found,
 		.ident =3D "Supermicro Server X6DLP",
 		.matches =3D {
-			DMI_MATCH(DMI_SYS_VENDOR, "Supermicro"),
-			DMI_MATCH(DMI_BIOS_VERSION, "080010"),
-			DMI_MATCH(DMI_PRODUCT_NAME, "X6DLP"),
+			SYSFW_MATCH(SYSFW_SYS_VENDOR, "Supermicro"),
+			SYSFW_MATCH(SYSFW_BIOS_VERSION, "080010"),
+			SYSFW_MATCH(SYSFW_PRODUCT_NAME, "X6DLP"),
 		},
 	},
-	{ }
+	{}
 };
=20
 static int acpi_cpufreq_blacklist(struct cpuinfo_x86 *c)
@@ -554,7 +554,7 @@ static int acpi_cpufreq_cpu_init(struct cpufreq_policy =
*policy)
 	cpumask_copy(policy->related_cpus, perf->shared_cpu_map);
=20
 #ifdef CONFIG_SMP
-	dmi_check_system(sw_any_bug_dmi_table);
+	sysfw_callback(sw_any_bug_table);
 	if (bios_with_sw_any_bug && cpumask_weight(policy->cpus) =3D 1) {
 		policy->shared_type =3D CPUFREQ_SHARED_TYPE_ALL;
 		cpumask_copy(policy->cpus, cpu_core_mask(cpu));
diff --git a/drivers/cpufreq/powernow-k7.c b/drivers/cpufreq/powernow-k7.c
index d71d9f3..ce33c9f 100644
--- a/drivers/cpufreq/powernow-k7.c
+++ b/drivers/cpufreq/powernow-k7.c
@@ -21,7 +21,7 @@
 #include <linux/cpufreq.h>
 #include <linux/slab.h>
 #include <linux/string.h>
-#include <linux/dmi.h>
+#include <linux/sysfw.h>
 #include <linux/timex.h>
 #include <linux/io.h>
=20
@@ -598,7 +598,7 @@ static unsigned int powernow_get(unsigned int cpu)
 }
=20
=20
-static int __cpuinit acer_cpufreq_pst(const struct dmi_system_id *d)
+static int __cpuinit acer_cpufreq_pst(const struct sysfw_id *d)
 {
 	printk(KERN_WARNING PFX
 		"%s laptop with broken PST tables in BIOS detected.\n",
@@ -616,16 +616,16 @@ static int __cpuinit acer_cpufreq_pst(const struct dm=
i_system_id *d)
  * A BIOS update is all that can save them.
  * Mention this, and disable cpufreq.
  */
-static struct dmi_system_id __cpuinitdata powernow_dmi_table[] =3D {
+static struct sysfw_id __cpuinitdata powernow_id_table[] =3D {
 	{
 		.callback =3D acer_cpufreq_pst,
 		.ident =3D "Acer Aspire",
 		.matches =3D {
-			DMI_MATCH(DMI_SYS_VENDOR, "Insyde Software"),
-			DMI_MATCH(DMI_BIOS_VERSION, "3A71"),
+			SYSFW_MATCH(SYSFW_SYS_VENDOR, "Insyde Software"),
+			SYSFW_MATCH(SYSFW_BIOS_VERSION, "3A71"),
 		},
 	},
-	{ }
+	{}
 };
=20
 static int __cpuinit powernow_cpu_init(struct cpufreq_policy *policy)
@@ -647,7 +647,7 @@ static int __cpuinit powernow_cpu_init(struct cpufreq_p=
olicy *policy)
 	}
 	pr_debug("FSB: %3dMHz\n", fsb/1000);
=20
-	if (dmi_check_system(powernow_dmi_table) || acpi_force) {
+	if (sysfw_callback(powernow_id_table) || acpi_force) {
 		printk(KERN_INFO PFX "PSB/PST known to be broken.  "
 				"Trying ACPI instead\n");
 		result =3D powernow_acpi_init();
--=20
1.6.5.2

