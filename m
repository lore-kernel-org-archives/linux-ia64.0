From: John Keller <jpk@sgi.com>
Date: Thu, 23 Aug 2007 00:32:06 +0000
Subject: RESEND [PATCH] - SN: Add support for CPU disable
Message-Id: <20070823003206.20245.14884.sendpatchset@attica.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070801210017.18859.29844.59674@attica.americas.sgi.com>
In-Reply-To: <20070801210017.18859.29844.59674@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, John Keller <jpk@sgi.com>

Add additional support for CPU disable on SN platforms.
Correctly setup the smp_affinity mask for I/O error IRQs.
Restrict the use of the feature to Altix 4000 and 450 systems
running with a CPU disable capable PROM, and do not allow disabling
of CPU 0.

Signed-off-by: John Keller <jpk@sgi.com>
---
Resend #2:
  Add severity levels to the new "printk" messages.

Resend #1:
  Code was incorrectly passing a logical, instead of physical,
  cpuid to set_irq_affinity_info(). Also, some cleanup per
  review comments.


 arch/ia64/kernel/smpboot.c              |    6 +++++
 arch/ia64/sn/kernel/huberror.c          |   14 ++++++++---
 arch/ia64/sn/kernel/irq.c               |   15 ++++++++++++
 arch/ia64/sn/kernel/sn2/sn2_smp.c       |   26 ++++++++++++++++++++++
 arch/ia64/sn/pci/pcibr/pcibr_provider.c |    1 
 arch/ia64/sn/pci/tioca_provider.c       |    2 +
 arch/ia64/sn/pci/tioce_provider.c       |    1 
 include/asm-ia64/sn/arch.h              |    1 
 include/asm-ia64/sn/intr.h              |    1 
 include/asm-ia64/sn/sn_feature_sets.h   |    1 
 10 files changed, 64 insertions(+), 4 deletions(-)


Index: release/arch/ia64/sn/kernel/huberror.c
=================================--- release.orig/arch/ia64/sn/kernel/huberror.c	2007-08-22 16:51:28.667238863 -0500
+++ release/arch/ia64/sn/kernel/huberror.c	2007-08-22 18:41:19.088053993 -0500
@@ -185,11 +185,14 @@ void hubiio_crb_error_handler(struct hub
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
+	sn_set_err_irq_affinity(SGI_II_ERROR);
 }
 
 
@@ -202,11 +205,14 @@ void hub_error_init(struct hubdev_info *
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
+	sn_set_err_irq_affinity(SGI_TIO_ERROR);
 }
 
Index: release/arch/ia64/sn/pci/pcibr/pcibr_provider.c
=================================--- release.orig/arch/ia64/sn/pci/pcibr/pcibr_provider.c	2007-08-22 16:51:28.679240340 -0500
+++ release/arch/ia64/sn/pci/pcibr/pcibr_provider.c	2007-08-22 18:41:19.100055471 -0500
@@ -145,6 +145,7 @@ pcibr_bus_fixup(struct pcibus_bussoft *p
 		printk(KERN_WARNING
 		       "pcibr cannot allocate interrupt for error handler\n");
 	}
+	sn_set_err_irq_affinity(SGI_PCIASIC_ERROR);
 
 	/* 
 	 * Update the Bridge with the "kernel" pagesize 
Index: release/arch/ia64/sn/pci/tioca_provider.c
=================================--- release.orig/arch/ia64/sn/pci/tioca_provider.c	2007-08-22 16:51:28.679240340 -0500
+++ release/arch/ia64/sn/pci/tioca_provider.c	2007-08-22 18:41:19.112056948 -0500
@@ -654,6 +654,8 @@ tioca_bus_fixup(struct pcibus_bussoft *p
 		       __FUNCTION__, SGI_TIOCA_ERROR,
 		       (int)tioca_common->ca_common.bs_persist_busnum);
 
+	sn_set_err_irq_affinity(SGI_TIOCA_ERROR);
+
 	/* Setup locality information */
 	controller->node = tioca_kern->ca_closest_node;
 	return tioca_common;
Index: release/arch/ia64/sn/pci/tioce_provider.c
=================================--- release.orig/arch/ia64/sn/pci/tioce_provider.c	2007-08-22 16:51:28.679240340 -0500
+++ release/arch/ia64/sn/pci/tioce_provider.c	2007-08-22 18:41:19.124058426 -0500
@@ -1034,6 +1034,7 @@ tioce_bus_fixup(struct pcibus_bussoft *p
 		       tioce_common->ce_pcibus.bs_persist_segment,
 		       tioce_common->ce_pcibus.bs_persist_busnum);
 
+	sn_set_err_irq_affinity(SGI_PCIASIC_ERROR);
 	return tioce_common;
 }
 
Index: release/include/asm-ia64/sn/sn_feature_sets.h
=================================--- release.orig/include/asm-ia64/sn/sn_feature_sets.h	2007-08-22 16:51:32.887758491 -0500
+++ release/include/asm-ia64/sn/sn_feature_sets.h	2007-08-22 18:41:19.140060396 -0500
@@ -31,6 +31,7 @@ extern int sn_prom_feature_available(int
 #define PRF_PAL_CACHE_FLUSH_SAFE	0
 #define PRF_DEVICE_FLUSH_LIST		1
 #define PRF_HOTPLUG_SUPPORT		2
+#define PRF_CPU_DISABLE_SUPPORT		3
 
 /* --------------------- OS Features -------------------------------*/
 
Index: release/arch/ia64/kernel/smpboot.c
=================================--- release.orig/arch/ia64/kernel/smpboot.c	2007-08-22 16:51:28.655237385 -0500
+++ release/arch/ia64/kernel/smpboot.c	2007-08-22 18:41:19.160062859 -0500
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
Index: release/arch/ia64/sn/kernel/sn2/sn2_smp.c
=================================--- release.orig/arch/ia64/sn/kernel/sn2/sn2_smp.c	2007-08-22 16:51:28.671239355 -0500
+++ release/arch/ia64/sn/kernel/sn2/sn2_smp.c	2007-08-22 18:54:50.823797761 -0500
@@ -40,6 +40,7 @@
 #include <asm/sn/shub_mmr.h>
 #include <asm/sn/nodepda.h>
 #include <asm/sn/rw_mmr.h>
+#include <asm/sn/sn_feature_sets.h>
 
 DEFINE_PER_CPU(struct ptc_stats, ptcstats);
 DECLARE_PER_CPU(struct ptc_stats, ptcstats);
@@ -429,6 +430,31 @@ void sn2_send_IPI(int cpuid, int vector,
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
+	if (is_shub2() && sn_prom_feature_available(PRF_CPU_DISABLE_SUPPORT)) {
+		if (cpu != 0)
+			return true;
+		else
+			printk(KERN_WARNING
+			      "Disabling the boot processor is not allowed.\n");
+
+	} else
+		printk(KERN_WARNING
+		       "CPU disable is not supported on this system.\n");
+
+	return false;
+}
+#endif /* CONFIG_HOTPLUG_CPU */
+
 #ifdef CONFIG_PROC_FS
 
 #define PTC_BASENAME	"sgi_sn/ptc_statistics"
Index: release/include/asm-ia64/sn/arch.h
=================================--- release.orig/include/asm-ia64/sn/arch.h	2007-08-22 16:51:32.879757506 -0500
+++ release/include/asm-ia64/sn/arch.h	2007-08-22 18:41:19.200067785 -0500
@@ -81,5 +81,6 @@ extern u8 sn_sharing_domain_size;
 extern u8 sn_region_size;
 
 extern void sn_flush_all_caches(long addr, long bytes);
+extern bool sn_cpu_disable_allowed(int cpu);
 
 #endif /* _ASM_IA64_SN_ARCH_H */
Index: release/arch/ia64/sn/kernel/irq.c
=================================--- release.orig/arch/ia64/sn/kernel/irq.c	2007-08-22 16:51:28.671239355 -0500
+++ release/arch/ia64/sn/kernel/irq.c	2007-08-22 18:41:19.224070740 -0500
@@ -19,6 +19,7 @@
 #include <asm/sn/pcidev.h>
 #include <asm/sn/shub_mmr.h>
 #include <asm/sn/sn_sal.h>
+#include <asm/sn/sn_feature_sets.h>
 
 static void force_interrupt(int irq);
 static void register_intr_pda(struct sn_irq_info *sn_irq_info);
@@ -233,6 +234,20 @@ static void sn_set_affinity_irq(unsigned
 		(void)sn_retarget_vector(sn_irq_info, nasid, slice);
 }
 
+#ifdef CONFIG_SMP
+void sn_set_err_irq_affinity(unsigned int irq)
+{
+        /*
+         * On systems which support CPU disabling (SHub2), all error interrupts
+         * are targetted at the boot CPU.
+         */
+        if (is_shub2() && sn_prom_feature_available(PRF_CPU_DISABLE_SUPPORT))
+                set_irq_affinity_info(irq, cpu_physical_id(0), 0);
+}
+#else
+void sn_set_err_irq_affinity(unsigned int irq) { }
+#endif
+
 static void
 sn_mask_irq(unsigned int irq)
 {
Index: release/include/asm-ia64/sn/intr.h
=================================--- release.orig/include/asm-ia64/sn/intr.h	2007-08-22 16:51:32.879757506 -0500
+++ release/include/asm-ia64/sn/intr.h	2007-08-22 18:41:19.248073695 -0500
@@ -60,6 +60,7 @@ extern u64 sn_intr_alloc(nasid_t, int,
 			      int, nasid_t, int);
 extern void sn_intr_free(nasid_t, int, struct sn_irq_info *);
 extern struct sn_irq_info *sn_retarget_vector(struct sn_irq_info *, nasid_t, int);
+extern void sn_set_err_irq_affinity(unsigned int);
 extern struct list_head **sn_irq_lh;
 
 #define CPU_VECTOR_TO_IRQ(cpuid,vector) (vector)
