From: John Keller <jpk@sgi.com>
Date: Mon, 06 Nov 2006 20:10:50 +0000
Subject: [PATCH] SN: Correctly update smp_affinty mask
Message-Id: <20061106201050.27405.45838.sendpatchset@attica.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Altix systems, the /proc/irq/nn/smp_affinity mask is not being setup
at device iniitalization, or updated after an interrupt redirection.
This patch resolves those issues.

Signed-off-by: John Keller <jpk@sgi.com>
---

 arch/ia64/sn/kernel/irq.c    |   18 +++++++++++++++---
 arch/ia64/sn/kernel/msi_sn.c |    4 ----
 2 files changed, 15 insertions(+), 7 deletions(-)


Index: release/arch/ia64/sn/kernel/irq.c
=================================--- release.orig/arch/ia64/sn/kernel/irq.c	2006-11-06 11:57:34.412002910 -0600
+++ release/arch/ia64/sn/kernel/irq.c	2006-11-06 13:49:19.331005432 -0600
@@ -117,7 +117,10 @@ struct sn_irq_info *sn_retarget_vector(s
 				       nasid_t nasid, int slice)
 {
 	int vector;
+	int cpuid;
+#ifdef CONFIG_SMP
 	int cpuphys;
+#endif
 	int64_t bridge;
 	int local_widget, status;
 	nasid_t local_nasid;
@@ -146,7 +149,6 @@ struct sn_irq_info *sn_retarget_vector(s
 	vector = sn_irq_info->irq_irq;
 	/* Free the old PROM new_irq_info structure */
 	sn_intr_free(local_nasid, local_widget, new_irq_info);
-	/* Update kernels new_irq_info with new target info */
 	unregister_intr_pda(new_irq_info);
 
 	/* allocate a new PROM new_irq_info struct */
@@ -160,8 +162,10 @@ struct sn_irq_info *sn_retarget_vector(s
 		return NULL;
 	}
 
-	cpuphys = nasid_slice_to_cpuid(nasid, slice);
-	new_irq_info->irq_cpuid = cpuphys;
+	/* Update kernels new_irq_info with new target info */
+	cpuid = nasid_slice_to_cpuid(new_irq_info->irq_nasid,
+				     new_irq_info->irq_slice);
+	new_irq_info->irq_cpuid = cpuid;
 	register_intr_pda(new_irq_info);
 
 	pci_provider = sn_pci_provider[new_irq_info->irq_bridge_type];
@@ -180,6 +184,7 @@ struct sn_irq_info *sn_retarget_vector(s
 	call_rcu(&sn_irq_info->rcu, sn_irq_info_free);
 
 #ifdef CONFIG_SMP
+	cpuphys = cpu_physical_id(cpuid);
 	set_irq_affinity_info((vector & 0xff), cpuphys, 0);
 #endif
 
@@ -299,6 +304,9 @@ void sn_irq_fixup(struct pci_dev *pci_de
 	nasid_t nasid = sn_irq_info->irq_nasid;
 	int slice = sn_irq_info->irq_slice;
 	int cpu = nasid_slice_to_cpuid(nasid, slice);
+#ifdef CONFIG_SMP
+	int cpuphys;
+#endif
 
 	pci_dev_get(pci_dev);
 	sn_irq_info->irq_cpuid = cpu;
@@ -311,6 +319,10 @@ void sn_irq_fixup(struct pci_dev *pci_de
 	spin_unlock(&sn_irq_info_lock);
 
 	register_intr_pda(sn_irq_info);
+#ifdef CONFIG_SMP
+	cpuphys = cpu_physical_id(cpu);
+	set_irq_affinity_info(sn_irq_info->irq_irq, cpuphys, 0);
+#endif
 }
 
 void sn_irq_unfixup(struct pci_dev *pci_dev)
Index: release/arch/ia64/sn/kernel/msi_sn.c
=================================--- release.orig/arch/ia64/sn/kernel/msi_sn.c	2006-11-06 11:57:34.412002910 -0600
+++ release/arch/ia64/sn/kernel/msi_sn.c	2006-11-06 11:58:56.045980248 -0600
@@ -136,10 +136,6 @@ int sn_setup_msi_irq(unsigned int irq, s
 	 */
 	msg.data = 0x100 + irq;
 
-#ifdef CONFIG_SMP
-	set_irq_affinity_info(irq, sn_irq_info->irq_cpuid, 0);
-#endif
-
 	write_msi_msg(irq, &msg);
 	set_irq_chip_and_handler(irq, &sn_msi_chip, handle_edge_irq);
 
