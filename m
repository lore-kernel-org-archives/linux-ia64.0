From: Christoph Hellwig <hch@lst.de>
Date: Wed, 07 Aug 2019 13:30:48 +0000
Subject: [PATCH 28/29] ia64: remove CONFIG_ACPI_NUMA ifdefs
Message-Id: <20190807133049.20893-29-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190807133049.20893-1-hch@lst.de>
In-Reply-To: <20190807133049.20893-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

CONFIG_ACPI_NUMA is now unconditionally selected on ia64, so remove the
ifdefs.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/ia64/include/asm/acpi.h |  5 -----
 arch/ia64/kernel/acpi.c      | 17 -----------------
 arch/ia64/kernel/setup.c     |  2 --
 3 files changed, 24 deletions(-)

diff --git a/arch/ia64/include/asm/acpi.h b/arch/ia64/include/asm/acpi.h
index f886d4dc9d55..9598f998a94f 100644
--- a/arch/ia64/include/asm/acpi.h
+++ b/arch/ia64/include/asm/acpi.h
@@ -55,7 +55,6 @@ extern int additional_cpus;
 #define additional_cpus 0
 #endif
 
-#ifdef CONFIG_ACPI_NUMA
 #if MAX_NUMNODES > 256
 #define MAX_PXM_DOMAINS MAX_NUMNODES
 #else
@@ -63,7 +62,6 @@ extern int additional_cpus;
 #endif
 extern int pxm_to_nid_map[MAX_PXM_DOMAINS];
 extern int __initdata nid_to_pxm_map[MAX_NUMNODES];
-#endif
 
 static inline bool arch_has_acpi_pdc(void) { return true; }
 static inline void arch_acpi_set_pdc_bits(u32 *buf)
@@ -73,7 +71,6 @@ static inline void arch_acpi_set_pdc_bits(u32 *buf)
 
 #define acpi_unlazy_tlb(x)
 
-#ifdef CONFIG_ACPI_NUMA
 extern cpumask_t early_cpu_possible_map;
 #define for_each_possible_early_cpu(cpu)  \
 	for_each_cpu((cpu), &early_cpu_possible_map)
@@ -102,8 +99,6 @@ static inline void per_cpu_scan_finalize(int min_cpus, int reserve_cpus)
 
 extern void acpi_numa_fixup(void);
 
-#endif /* CONFIG_ACPI_NUMA */
-
 #endif /*__KERNEL__*/
 
 #endif /*_ASM_ACPI_H*/
diff --git a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
index 70d1587ddcd4..f681e8068c8d 100644
--- a/arch/ia64/kernel/acpi.c
+++ b/arch/ia64/kernel/acpi.c
@@ -316,8 +316,6 @@ static int __init acpi_parse_madt(struct acpi_table_header *table)
 	return 0;
 }
 
-#ifdef CONFIG_ACPI_NUMA
-
 #undef SLIT_DEBUG
 
 #define PXM_FLAG_LEN ((MAX_PXM_DOMAINS + 1)/32)
@@ -517,7 +515,6 @@ void __init acpi_numa_fixup(void)
 	}
 #endif
 }
-#endif				/* CONFIG_ACPI_NUMA */
 
 /*
  * success: return IRQ number (>=0)
@@ -668,7 +665,6 @@ int __init acpi_boot_init(void)
 	if (acpi_table_parse(ACPI_SIG_FADT, acpi_parse_fadt))
 		printk(KERN_ERR PREFIX "Can't find FADT\n");
 
-#ifdef CONFIG_ACPI_NUMA
 #ifdef CONFIG_SMP
 	if (srat_num_cpus = 0) {
 		int cpu, i = 1;
@@ -680,7 +676,6 @@ int __init acpi_boot_init(void)
 	}
 #endif
 	build_cpu_to_node_map();
-#endif
 	return 0;
 }
 
@@ -713,7 +708,6 @@ int acpi_isa_irq_to_gsi(unsigned isa_irq, u32 *gsi)
 #ifdef CONFIG_ACPI_HOTPLUG_CPU
 int acpi_map_cpu2node(acpi_handle handle, int cpu, int physid)
 {
-#ifdef CONFIG_ACPI_NUMA
 	/*
 	 * We don't have cpu-only-node hotadd. But if the system equips
 	 * SRAT table, pxm is already found and node is ready.
@@ -723,7 +717,6 @@ int acpi_map_cpu2node(acpi_handle handle, int cpu, int physid)
 	 */
 	node_cpuid[cpu].phys_id = physid;
 	node_cpuid[cpu].nid = acpi_get_node(handle);
-#endif
 	return 0;
 }
 
@@ -813,17 +806,11 @@ int acpi_unmap_cpu(int cpu)
 {
 	ia64_cpu_to_sapicid[cpu] = -1;
 	set_cpu_present(cpu, false);
-
-#ifdef CONFIG_ACPI_NUMA
-	/* NUMA specific cleanup's */
-#endif
-
 	return (0);
 }
 EXPORT_SYMBOL(acpi_unmap_cpu);
 #endif				/* CONFIG_ACPI_HOTPLUG_CPU */
 
-#ifdef CONFIG_ACPI_NUMA
 static acpi_status acpi_map_iosapic(acpi_handle handle, u32 depth,
 				    void *context, void **ret)
 {
@@ -877,7 +864,6 @@ acpi_map_iosapics (void)
 }
 
 fs_initcall(acpi_map_iosapics);
-#endif				/* CONFIG_ACPI_NUMA */
 
 int __ref acpi_register_ioapic(acpi_handle handle, u64 phys_addr, u32 gsi_base)
 {
@@ -886,10 +872,7 @@ int __ref acpi_register_ioapic(acpi_handle handle, u64 phys_addr, u32 gsi_base)
 	if ((err = iosapic_init(phys_addr, gsi_base)))
 		return err;
 
-#ifdef CONFIG_ACPI_NUMA
 	acpi_map_iosapic(handle, 0, NULL, NULL);
-#endif				/* CONFIG_ACPI_NUMA */
-
 	return 0;
 }
 
diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
index 18de565d5825..6dbb58bb4c8c 100644
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -569,7 +569,6 @@ setup_arch (char **cmdline_p)
 	/* Initialize the ACPI boot-time table parser */
 	acpi_table_init();
 	early_acpi_boot_init();
-#ifdef CONFIG_ACPI_NUMA
 	acpi_numa_init();
 	acpi_numa_fixup();
 #ifdef CONFIG_ACPI_HOTPLUG_CPU
@@ -578,7 +577,6 @@ setup_arch (char **cmdline_p)
 	per_cpu_scan_finalize((cpumask_weight(&early_cpu_possible_map) = 0 ?
 		32 : cpumask_weight(&early_cpu_possible_map)),
 		additional_cpus > 0 ? additional_cpus : 0);
-#endif /* CONFIG_ACPI_NUMA */
 
 #ifdef CONFIG_SMP
 	smp_build_cpu_map();
-- 
2.20.1
