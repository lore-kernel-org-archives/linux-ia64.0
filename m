From: John Keller <jpk@sgi.com>
Date: Tue, 31 Jul 2007 19:45:05 +0000
Subject: [PATCH] - SN: Add support for CPU disable
Message-Id: <20070731194505.24177.41215.89690@attica.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, John Keller <jpk@sgi.com>

Add additional support for CPU disable on SN platforms.
Correctly setup the smp_affinity mask for I/O error IRQs.
Restrict the use of the feature to Altix 4000 and 450 systems
running with a CPU disable capable PROM, and do not allow disabling
of CPU 0.

Signed-off-by: John Keller <jpk@sgi.com>
---

 arch/ia64/kernel/smpboot.c              |    6 ++++
 arch/ia64/sn/kernel/huberror.c          |   31 +++++++++++++++++++---
 arch/ia64/sn/kernel/sn2/sn2_smp.c       |   24 +++++++++++++++++
 arch/ia64/sn/pci/pcibr/pcibr_provider.c |   10 +++++++
 arch/ia64/sn/pci/tioca_provider.c       |   10 +++++++
 arch/ia64/sn/pci/tioce_provider.c       |   11 +++++++
 include/asm-ia64/sn/arch.h              |    1 
 include/asm-ia64/sn/sn_feature_sets.h   |    1 
 8 files changed, 90 insertions(+), 4 deletions(-)



Index: linux-2.6/arch/ia64/sn/kernel/huberror.c
=================================--- linux-2.6.orig/arch/ia64/sn/kernel/huberror.c	2007-07-31 09:09:55.414522005 -0500
+++ linux-2.6/arch/ia64/sn/kernel/huberror.c	2007-07-31 09:38:14.634045360 -0500
@@ -14,6 +14,7 @@
 #include <asm/sn/addrs.h>
 #include <asm/sn/shubio.h>
 #include <asm/sn/geo.h>
+#include <asm/sn/sn_feature_sets.h>
 #include "xtalk/xwidgetdev.h"
 #include "xtalk/hubdev.h"
 #include <asm/sn/bte.h>
@@ -185,11 +186,22 @@ void hubiio_crb_error_handler(struct hub
  */
 void hub_error_init(struct hubdev_info *hubdev_info)
 {
+
 	if (request_irq(SGI_II_ERROR, hub_eint_handler, IRQF_SHARED,
-			"SN_hub_error", (void *)hubdev_info))
+			"SN_hub_error", (void *)hubdev_info)) {
 		printk("hub_error_init: Failed to request_irq for 0x%p\n",
 		    hubdev_info);
-	return;
+		return;
+	}
+
+#ifdef CONFIG_SMP
+	/*
+	 * On systems which support CPU disabling (SHub2), all error interrupts
+	 * are targetted at the boot CPU.
+	 */
+	if (is_shub2() && sn_prom_feature_available(PRF_CPU_DISABLE_SUPPORT))
+		set_irq_affinity_info(SGI_II_ERROR, 0, 0);
+#endif
 }
 
 
@@ -202,11 +214,22 @@ void hub_error_init(struct hubdev_info *
  */
 void ice_error_init(struct hubdev_info *hubdev_info)
 {
+
         if (request_irq
             (SGI_TIO_ERROR, (void *)hub_eint_handler, IRQF_SHARED, "SN_TIO_error",
-             (void *)hubdev_info))
+             (void *)hubdev_info)) {
                 printk("ice_error_init: request_irq() error hubdev_info 0x%p\n",
                        hubdev_info);
-        return;
+		return;
+	}
+
+#ifdef CONFIG_SMP
+	/*
+	 * On systems which support CPU disabling (SHub2), all error interrupts
+	 * are targetted at the boot CPU.
+	 */
+	if (is_shub2() && sn_prom_feature_available(PRF_CPU_DISABLE_SUPPORT))
+		set_irq_affinity_info(SGI_TIO_ERROR, 0, 0);
+#endif
 }
 
Index: linux-2.6/arch/ia64/sn/pci/pcibr/pcibr_provider.c
=================================--- linux-2.6.orig/arch/ia64/sn/pci/pcibr/pcibr_provider.c	2007-07-31 09:09:55.422522987 -0500
+++ linux-2.6/arch/ia64/sn/pci/pcibr/pcibr_provider.c	2007-07-31 09:38:14.662048814 -0500
@@ -17,6 +17,7 @@
 #include <asm/sn/sn_sal.h>
 #include <asm/sn/pic.h>
 #include <asm/sn/sn2/sn_hwperf.h>
+#include <asm/sn/sn_feature_sets.h>
 #include "xtalk/xwidgetdev.h"
 #include "xtalk/hubdev.h"
 
@@ -146,6 +147,15 @@ pcibr_bus_fixup(struct pcibus_bussoft *p
 		       "pcibr cannot allocate interrupt for error handler\n");
 	}
 
+#ifdef CONFIG_SMP
+	/*
+	 * On systems which support CPU disabling (SHub2), all error interrupts
+	 * are targetted at the boot CPU.
+	 */
+	if (is_shub2() && sn_prom_feature_available(PRF_CPU_DISABLE_SUPPORT))
+		set_irq_affinity_info(SGI_PCIASIC_ERROR, 0, 0);
+#endif
+
 	/* 
 	 * Update the Bridge with the "kernel" pagesize 
 	 */
Index: linux-2.6/arch/ia64/sn/pci/tioca_provider.c
=================================--- linux-2.6.orig/arch/ia64/sn/pci/tioca_provider.c	2007-07-31 09:09:55.422522987 -0500
+++ linux-2.6/arch/ia64/sn/pci/tioca_provider.c	2007-07-31 09:38:14.686051774 -0500
@@ -15,6 +15,7 @@
 #include <asm/sn/pcidev.h>
 #include <asm/sn/pcibus_provider_defs.h>
 #include <asm/sn/tioca_provider.h>
+#include <asm/sn/sn_feature_sets.h>
 
 u32 tioca_gart_found;
 EXPORT_SYMBOL(tioca_gart_found);	/* used by agp-sgi */
@@ -653,6 +654,15 @@ tioca_bus_fixup(struct pcibus_bussoft *p
 		       "Error interrupts won't be routed for TIOCA bus %d\n",
 		       __FUNCTION__, SGI_TIOCA_ERROR,
 		       (int)tioca_common->ca_common.bs_persist_busnum);
+#ifdef CONFIG_SMP
+	/*
+	 * On systems which support CPU disabling (SHub2), all error interrupts
+	 * are targetted at the boot CPU.
+	 */
+	if (is_shub2() && sn_prom_feature_available(PRF_CPU_DISABLE_SUPPORT))
+		set_irq_affinity_info(SGI_TIOCA_ERROR, 0, 0);
+#endif
+
 
 	/* Setup locality information */
 	controller->node = tioca_kern->ca_closest_node;
Index: linux-2.6/arch/ia64/sn/pci/tioce_provider.c
=================================--- linux-2.6.orig/arch/ia64/sn/pci/tioce_provider.c	2007-07-31 09:09:55.422522987 -0500
+++ linux-2.6/arch/ia64/sn/pci/tioce_provider.c	2007-07-31 09:38:14.706054241 -0500
@@ -15,6 +15,7 @@
 #include <asm/sn/pcidev.h>
 #include <asm/sn/pcibus_provider_defs.h>
 #include <asm/sn/tioce_provider.h>
+#include <asm/sn/sn_feature_sets.h>
 
 /*
  * 1/26/2006
@@ -1034,6 +1035,16 @@ tioce_bus_fixup(struct pcibus_bussoft *p
 		       tioce_common->ce_pcibus.bs_persist_segment,
 		       tioce_common->ce_pcibus.bs_persist_busnum);
 
+
+#ifdef CONFIG_SMP
+	/*
+	 * On systems which support CPU disabling (SHub2), all error interrupts
+	 * are targetted at the boot CPU.
+	 */
+	if (is_shub2() && sn_prom_feature_available(PRF_CPU_DISABLE_SUPPORT))
+		set_irq_affinity_info(SGI_PCIASIC_ERROR, 0, 0);
+#endif
+
 	return tioce_common;
 }
 
Index: linux-2.6/include/asm-ia64/sn/sn_feature_sets.h
=================================--- linux-2.6.orig/include/asm-ia64/sn/sn_feature_sets.h	2007-07-31 09:09:59.675044555 -0500
+++ linux-2.6/include/asm-ia64/sn/sn_feature_sets.h	2007-07-31 09:38:14.734057695 -0500
@@ -31,6 +31,7 @@ extern int sn_prom_feature_available(int
 #define PRF_PAL_CACHE_FLUSH_SAFE	0
 #define PRF_DEVICE_FLUSH_LIST		1
 #define PRF_HOTPLUG_SUPPORT		2
+#define PRF_CPU_DISABLE_SUPPORT		3
 
 /* --------------------- OS Features -------------------------------*/
 
Index: linux-2.6/arch/ia64/kernel/smpboot.c
=================================--- linux-2.6.orig/arch/ia64/kernel/smpboot.c	2007-07-31 09:09:55.398520043 -0500
+++ linux-2.6/arch/ia64/kernel/smpboot.c	2007-07-31 09:38:14.758060655 -0500
@@ -58,6 +58,7 @@
 #include <asm/system.h>
 #include <asm/tlbflush.h>
 #include <asm/unistd.h>
+#include <asm/sn/arch.h>
 
 #define SMP_DEBUG 0
 
@@ -730,6 +731,11 @@ int __cpu_disable(void)
 		return (-EBUSY);
 	}
 
+	if (ia64_platform_is("sn2")) {
+		if (!sn_cpu_disable_allowed(cpu))
+			return -EBUSY;
+	}
+
 	cpu_clear(cpu, cpu_online_map);
 
 	if (migrate_platform_irqs(cpu)) {
Index: linux-2.6/arch/ia64/sn/kernel/sn2/sn2_smp.c
=================================--- linux-2.6.orig/arch/ia64/sn/kernel/sn2/sn2_smp.c	2007-07-31 09:09:55.418522496 -0500
+++ linux-2.6/arch/ia64/sn/kernel/sn2/sn2_smp.c	2007-07-31 09:38:14.782063615 -0500
@@ -40,6 +40,7 @@
 #include <asm/sn/shub_mmr.h>
 #include <asm/sn/nodepda.h>
 #include <asm/sn/rw_mmr.h>
+#include <asm/sn/sn_feature_sets.h>
 
 DEFINE_PER_CPU(struct ptc_stats, ptcstats);
 DECLARE_PER_CPU(struct ptc_stats, ptcstats);
@@ -429,6 +430,29 @@ void sn2_send_IPI(int cpuid, int vector,
 	sn_send_IPI_phys(nasid, physid, vector, delivery_mode);
 }
 
+#ifdef CONFIG_HOTPLUG_CPU
+/**
+ * sn_cpu_disable_allowed - Determine if a CPU can be disabled.
+ * @cpu - CPU that is requested to be disabled.
+ *
+ * CPU disable is only allowed on SHub2 systems running with a PROM
+ * that supports CPU disable. It is not permitted to disable the boot processor.
+ */
+bool sn_cpu_disable_allowed(int cpu)
+{
+	if (is_shub2() && sn_prom_feature_available(PRF_CPU_DISABLE_SUPPORT))
+		if (cpu != 0)
+			return true;
+		else
+			printk("Disabling the boot processor is not allowed.\n");
+
+	else
+		printk("CPU disable is not supported on this system.\n");
+
+	return false;
+}
+#endif /* CONFIG_HOTPLUG_CPU */
+
 #ifdef CONFIG_PROC_FS
 
 #define PTC_BASENAME	"sgi_sn/ptc_statistics"
Index: linux-2.6/include/asm-ia64/sn/arch.h
=================================--- linux-2.6.orig/include/asm-ia64/sn/arch.h	2007-07-31 09:09:59.667043574 -0500
+++ linux-2.6/include/asm-ia64/sn/arch.h	2007-07-31 09:38:14.806066576 -0500
@@ -81,5 +81,6 @@ extern u8 sn_sharing_domain_size;
 extern u8 sn_region_size;
 
 extern void sn_flush_all_caches(long addr, long bytes);
+extern bool sn_cpu_disable_allowed(int cpu);
 
 #endif /* _ASM_IA64_SN_ARCH_H */
