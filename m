From: john stultz <johnstul@us.ibm.com>
Date: Wed, 18 Feb 2004 05:20:48 +0000
Subject: [RFC][PATCH] linux-2.6.3-rc2_ia64-cyclone_A1
Message-Id: <1077081648.985.27.camel@cog.beaverton.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1076556140.795.119.camel@cog.beaverton.ibm.com>
In-Reply-To: <1076556140.795.119.camel@cog.beaverton.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

All,
        This patch provides access to the cyclone time source found on
IBM EXA based systems (x450 and x455). This is needed on multi-node
systems where the CPU ITCs are not synchronized, causing possible time
inconsistencies.

Since the last release, I've implemented a number of suggested cleanups
and fixes, but please let me know if you have any additional suggestions
or comments.

thanks
-john

diff -Nru a/arch/ia64/Kconfig b/arch/ia64/Kconfig
--- a/arch/ia64/Kconfig	Tue Feb 17 21:16:09 2004
+++ b/arch/ia64/Kconfig	Tue Feb 17 21:16:09 2004
@@ -245,6 +245,12 @@
 	  Say Y here to enable machine check support for IA-64.  If you're
 	  unsure, answer Y.
 
+config IA64_CYCLONE
+	bool "Support Cyclone(EXA) Time Source"
+	help
+		Say Y here to enable support for IBM EXA Cyclone time source.
+		If you're unsure, answer N.
+	
 config PM
 	bool "Power Management support"
 	depends on IA64_GENERIC || IA64_DIG || IA64_HP_ZX1
diff -Nru a/arch/ia64/kernel/Makefile b/arch/ia64/kernel/Makefile
--- a/arch/ia64/kernel/Makefile	Tue Feb 17 21:16:09 2004
+++ b/arch/ia64/kernel/Makefile	Tue Feb 17 21:16:09 2004
@@ -18,6 +18,7 @@
 obj-$(CONFIG_MODULES)		+= module.o
 obj-$(CONFIG_SMP)		+= smp.o smpboot.o
 obj-$(CONFIG_PERFMON)		+= perfmon_default_smpl.o
+obj-$(CONFIG_IA64_CYCLONE)	+= cyclone.o
 
 # The gate DSO image is built using a special linker script.
 targets += gate.so gate-syms.o
diff -Nru a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
--- a/arch/ia64/kernel/acpi.c	Tue Feb 17 21:16:09 2004
+++ b/arch/ia64/kernel/acpi.c	Tue Feb 17 21:16:09 2004
@@ -49,6 +49,8 @@
 #include <asm/page.h>
 #include <asm/system.h>
 #include <asm/numa.h>
+#include <asm/sal.h>
+#include <asm/cyclone.h>
 
 
 #define PREFIX			"ACPI: "
@@ -304,6 +306,22 @@
 	return 0;
 }
 
+/* Hook from generic ACPI tables.c */
+void __init acpi_madt_oem_check(char *oem_id, char *oem_table_id)
+{
+	if (!strncmp(oem_id, "IBM", 3) &&
+	    (!strncmp(oem_table_id, "SERMOW", 6))){
+
+		/* Unfortunatly ITC_DRIFT is not yet part of the
+		 * official SAL spec, so the ITC_DRIFT bit is not
+		 * set by the BIOS on this hardware.
+		 */
+		sal_platform_features |= IA64_SAL_PLATFORM_FEATURE_ITC_DRIFT;
+		
+		/*Start cyclone clock*/
+		cyclone_setup(0);
+	}
+}
 
 static int __init
 acpi_parse_madt (unsigned long phys_addr, unsigned long size)
@@ -327,6 +345,10 @@
 		ipi_base_addr = (unsigned long) ioremap(acpi_madt->lapic_address, 0);
 
 	printk(KERN_INFO PREFIX "Local APIC address 0x%lx\n", ipi_base_addr);
+
+	acpi_madt_oem_check(acpi_madt->header.oem_id,
+		acpi_madt->header.oem_table_id);
+
 	return 0;
 }
 
diff -Nru a/arch/ia64/kernel/cyclone.c b/arch/ia64/kernel/cyclone.c
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/arch/ia64/kernel/cyclone.c	Tue Feb 17 21:16:09 2004
@@ -0,0 +1,156 @@
+#include <linux/smp.h>
+#include <linux/time.h>
+#include <linux/errno.h>
+
+/* IBM Summit (EXA) Cyclone counter code*/
+#define CYCLONE_CBAR_ADDR 0xFEB00CD0
+#define CYCLONE_PMCC_OFFSET 0x51A0
+#define CYCLONE_MPMC_OFFSET 0x51D0
+#define CYCLONE_MPCS_OFFSET 0x51A8
+#define CYCLONE_TIMER_FREQ 100000000
+
+int use_cyclone;
+int __init cyclone_setup(char *str)
+{
+	use_cyclone = 1;
+	return 1;
+}
+
+static u32* volatile cyclone_timer;	/* Cyclone MPMC0 register */
+static u32 last_update_cyclone;
+
+static unsigned long offset_base;
+
+static unsigned long get_offset_cyclone(void)
+{
+	u32 now;
+	unsigned long offset;
+
+	/* Read the cyclone timer */
+	now = readl(cyclone_timer);
+	/* .. relative to previous update*/
+	offset = now - last_update_cyclone;
+
+	/* convert cyclone ticks to nanoseconds */
+	offset = (offset*NSEC_PER_SEC)/CYCLONE_TIMER_FREQ;
+
+	/* our adjusted time in nanoseconds */
+	return offset_base + (unsigned long)offset;
+}
+
+static void update_cyclone(long delta_nsec)
+{
+	u32 now;
+	unsigned long offset;
+
+	/* Read the cyclone timer */
+	now = readl(cyclone_timer);
+	/* .. relative to previous update*/
+	offset = now - last_update_cyclone;
+
+	/* convert cyclone ticks to nanoseconds */
+	offset = (offset*NSEC_PER_SEC)/CYCLONE_TIMER_FREQ;
+
+	/* Be careful about signed/unsigned comparisons here: */
+	if (delta_nsec < 0 || (unsigned long) delta_nsec < offset)
+		offset_base = offset_base + offset - delta_nsec;
+	else
+		offset_base = 0;
+
+	last_update_cyclone = now;
+}
+
+static void reset_cyclone(void)
+{
+	offset_base = 0;
+	last_update_cyclone = readl(cyclone_timer);
+}
+
+struct time_interpolator cyclone_interpolator = {
+	.get_offset =	get_offset_cyclone,
+	.update =	update_cyclone,
+	.reset =	reset_cyclone,
+	.frequency =	CYCLONE_TIMER_FREQ,
+	.drift =	-100,
+};
+
+int __init init_cyclone_clock(void)
+{
+	u64* reg;
+	u64 base;	/* saved cyclone base address */
+	u64 offset;	/* offset from pageaddr to cyclone_timer register */
+	int i;
+
+	if (!use_cyclone)
+		return -ENODEV;
+
+	printk(KERN_INFO "Summit chipset: Starting Cyclone Counter.\n");
+
+	/* find base address */
+	offset = (CYCLONE_CBAR_ADDR);
+	reg = (u64*)ioremap_nocache(offset, sizeof(u64));
+	if(!reg){
+		printk(KERN_ERR "Summit chipset: Could not find valid CBAR register.\n");
+		use_cyclone = 0;
+		return -ENODEV;
+	}
+	base = readq(reg);
+	if(!base){
+		printk(KERN_ERR "Summit chipset: Could not find valid CBAR value.\n");
+		use_cyclone = 0;
+		return -ENODEV;
+	}
+	iounmap(reg);
+		
+	/* setup PMCC */
+	offset = (base + CYCLONE_PMCC_OFFSET);
+	reg = (u64*)ioremap_nocache(offset, sizeof(u64));
+	if(!reg){
+		printk(KERN_ERR "Summit chipset: Could not find valid PMCC register.\n");
+		use_cyclone = 0;
+		return -ENODEV;
+	}
+	writel(0x00000001,reg);
+	iounmap(reg);
+	
+	/* setup MPCS */
+	offset = (base + CYCLONE_MPCS_OFFSET);
+	reg = (u64*)ioremap_nocache(offset, sizeof(u64));
+	if(!reg){
+		printk(KERN_ERR "Summit chipset: Could not find valid MPCS register.\n");
+		use_cyclone = 0;
+		return -ENODEV;
+	}
+	writel(0x00000001,reg);
+	iounmap(reg);
+	
+	/* map in cyclone_timer */
+	offset = (base + CYCLONE_MPMC_OFFSET);
+	cyclone_timer = (u32*)ioremap_nocache(offset, sizeof(u32));
+	if(!cyclone_timer){
+		printk(KERN_ERR "Summit chipset: Could not find valid MPMC register.\n");
+		use_cyclone = 0;
+		return -ENODEV;
+	}
+
+	/*quick test to make sure its ticking*/
+	for(i=0; i<3; i++){
+		u32 old = readl(cyclone_timer);
+		int stall = 100;
+		while(stall--) barrier();
+		if(readl(cyclone_timer) = old){
+			printk(KERN_ERR "Summit chipset: Counter not counting! DISABLED\n");
+			iounmap(cyclone_timer);
+			cyclone_timer = 0;
+			use_cyclone = 0;
+			return -ENODEV;
+		}
+	}
+	/* initialize last tick */
+	last_update_cyclone = readl(cyclone_timer);
+	register_time_interpolator(&cyclone_interpolator);
+
+	return 0;
+}
+
+__initcall(init_cyclone_clock);
diff -Nru a/include/asm-ia64/cyclone.h b/include/asm-ia64/cyclone.h
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/include/asm-ia64/cyclone.h	Tue Feb 17 21:16:09 2004
@@ -0,0 +1,15 @@
+#ifndef ASM_IA64_CYCLONE_H
+#define ASM_IA64_CYCLONE_H
+
+#ifdef	CONFIG_IA64_CYCLONE
+extern int use_cyclone;
+extern int __init cyclone_setup(char*);
+#else	/* CONFIG_IA64_CYCLONE */
+#define use_cyclone 0
+static inline void cyclone_setup(char* s)
+{
+	printk(KERN_ERR "Cyclone Counter: System not configured"
+					" w/ CONFIG_IA64_CYCLONE.\n");
+}
+#endif	/* CONFIG_IA64_CYCLONE */
+#endif	/* !ASM_IA64_CYCLONE_H */


