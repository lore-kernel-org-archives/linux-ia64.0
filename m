From: Ashok Raj <ashok.raj@intel.com>
Date: Sat, 12 Feb 2005 14:59:12 +0000
Subject: CPU Hotplug - Retargetting CPEI
Message-Id: <20050212065911.A26140@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi

In addition to the patches submitted for CPU hotplug, handoff to SAL.

Latest patch posted.

http://marc.theaimsgroup.com/?l=linux-ia64&m0815828013781&w=2


This patch is ACPI 3.0 specific which gives a hint that the platform is 
symmetric and any CPU can be a target of the CPEI. 

The patch to support BSP removal will be posted next.

Cheers,
ashok


---

Signed-off-by: Ashok Raj <ashok.raj@intel.com>

This patch adds support to evaluate cpei override flag in the 
platform interrupt source structure. Also records the cpu that
was provided as hint from ACPI.
---

---

 release_work-araj/arch/ia64/kernel/acpi.c     |   44 ++++++++++++++++++++++++++
 release_work-araj/arch/ia64/kernel/topology.c |    7 ++++
 release_work-araj/include/asm-ia64/acpi.h     |    9 +++++
 release_work-araj/include/linux/acpi.h        |    5 ++
 4 files changed, 64 insertions(+), 1 deletion(-)

diff -puN arch/ia64/kernel/acpi.c~cpei_override arch/ia64/kernel/acpi.c
--- release_work/arch/ia64/kernel/acpi.c~cpei_override	2005-02-11 14:19:31.839889245 -0800
+++ release_work-araj/arch/ia64/kernel/acpi.c	2005-02-11 14:19:31.913131431 -0800
@@ -11,6 +11,7 @@
  *  Copyright (C) 2001 Jenna Hall <jenna.s.hall@intel.com>
  *  Copyright (C) 2001 Takayoshi Kochi <t-kochi@bq.jp.nec.com>
  *  Copyright (C) 2002 Erich Focht <efocht@ess.nec.de>
+ *  Copyright (C) 2004 Ashok Raj <ashok.raj@intel.com>
  *
  * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  *
@@ -67,6 +68,11 @@ EXPORT_SYMBOL(pm_power_off);
 unsigned char acpi_kbd_controller_present = 1;
 unsigned char acpi_legacy_devices;
 
+static unsigned int __initdata acpi_madt_rev;
+
+unsigned int acpi_cpei_override;
+unsigned int acpi_cpei_phys_cpuid;
+
 #define MAX_SAPICS 256
 u16 ia64_acpiid_to_sapicid[MAX_SAPICS]  	{ [0 ... MAX_SAPICS - 1] = -1 };
@@ -267,10 +273,46 @@ acpi_parse_plat_int_src (
 						(plintsrc->flags.trigger = 1) ? IOSAPIC_EDGE : IOSAPIC_LEVEL);
 
 	platform_intr_list[plintsrc->type] = vector;
+	if (acpi_madt_rev > 1) {
+		acpi_cpei_override = plintsrc->plint_flags.cpei_override_flag;
+	}
+
+	/*
+	 * Save the physical id, so we can check when its being removed
+	 */
+	acpi_cpei_phys_cpuid = ((plintsrc->id << 8) | (plintsrc->eid)) & 0xffff;
+
 	return 0;
 }
 
 
+unsigned int can_cpei_retarget(void)
+{
+	return (1 ? (acpi_cpei_override) : 0);
+}
+
+unsigned int is_cpu_cpei_target(unsigned int cpu)
+{
+	unsigned int logical_id;
+
+	logical_id = cpu_logical_id(acpi_cpei_phys_cpuid);
+
+	if (logical_id = cpu)
+		return 1;
+	else
+		return 0;
+}
+
+void set_cpei_target_cpu(unsigned int cpu)
+{
+	acpi_cpei_phys_cpuid = cpu_physical_id(cpu);
+}
+
+unsigned int get_cpei_target_cpu(void)
+{
+	return acpi_cpei_phys_cpuid;
+}
+
 static int __init
 acpi_parse_int_src_ovr (
 	acpi_table_entry_header *header, const unsigned long end)
@@ -328,6 +370,8 @@ acpi_parse_madt (unsigned long phys_addr
 
 	acpi_madt = (struct acpi_table_madt *) __va(phys_addr);
 
+	acpi_madt_rev = acpi_madt->header.revision;
+
 	/* remember the value for reference after free_initmem() */
 #ifdef CONFIG_ITANIUM
 	has_8259 = 1; /* Firmware on old Itanium systems is broken */
diff -puN arch/ia64/kernel/topology.c~cpei_override arch/ia64/kernel/topology.c
--- release_work/arch/ia64/kernel/topology.c~cpei_override	2005-02-11 14:19:31.844772057 -0800
+++ release_work-araj/arch/ia64/kernel/topology.c	2005-02-11 14:19:31.914107994 -0800
@@ -36,6 +36,13 @@ int arch_register_cpu(int num)
 	parent = &sysfs_nodes[cpu_to_node(num)];
 #endif /* CONFIG_NUMA */
 
+	/*
+	 * If CPEI cannot be re-targetted, and this is
+	 * CPEI target, then dont create the control file
+	 */
+	if (!can_cpei_retarget() && is_cpu_cpei_target(num))
+		sysfs_cpus[num].cpu.no_control = 1;
+
 	return register_cpu(&sysfs_cpus[num].cpu, num, parent);
 }
 
diff -puN include/asm-ia64/acpi.h~cpei_override include/asm-ia64/acpi.h
--- release_work/include/asm-ia64/acpi.h~cpei_override	2005-02-11 14:19:31.890670494 -0800
+++ release_work-araj/include/asm-ia64/acpi.h	2005-02-11 14:19:31.915084556 -0800
@@ -98,6 +98,15 @@ const char *acpi_get_sysname (void);
 int acpi_request_vector (u32 int_type);
 int acpi_gsi_to_irq (u32 gsi, unsigned int *irq);
 
+/*
+ * Record the cpei override flag and current logical cpu. This is
+ * useful for CPU removal.
+ */
+extern unsigned int can_cpei_retarget(void);
+extern unsigned int is_cpu_cpei_target(unsigned int cpu);
+extern void set_cpei_target_cpu(unsigned int cpu);
+extern unsigned int get_cpei_target_cpu(void);
+
 #ifdef CONFIG_ACPI_NUMA
 /* Proximity bitmap length; _PXM is at most 255 (8 bit)*/
 #define MAX_PXM_DOMAINS (256)
diff -puN include/linux/acpi.h~cpei_override include/linux/acpi.h
--- release_work/include/linux/acpi.h~cpei_override	2005-02-11 14:19:31.905318932 -0800
+++ release_work-araj/include/linux/acpi.h	2005-02-11 14:19:31.916061119 -0800
@@ -202,7 +202,10 @@ struct acpi_table_plat_int_src {
 	u8			eid;
 	u8			iosapic_vector;
 	u32			global_irq;
-	u32			reserved;
+	struct {
+		u32			cpei_override_flag:1;
+		u32			reserved:31;
+	}			plint_flags;
 } __attribute__ ((packed));
 
 enum acpi_interrupt_id {
_
