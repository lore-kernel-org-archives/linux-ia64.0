From: Jiang Liu <jiang.liu@linux.intel.com>
Date: Tue, 04 Nov 2014 12:02:02 +0000
Subject: [Patch Part2 v4 28/31] iommu/vt-d: Refine the interfaces to create IRQ for DMAR unit
Message-Id: <1415102525-9898-29-git-send-email-jiang.liu@linux.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1415102525-9898-1-git-send-email-jiang.liu@linux.intel.com>
In-Reply-To: <1415102525-9898-1-git-send-email-jiang.liu-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, "Rafael J. Wysocki" <rjw-LthD3rsA81gm4RdzfppkhA@public.gmane.org>, Bjorn Helgaas <bhelgaas-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Randy Dunlap <rdunlap-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, Yinghai Lu <yinghai-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Borislav Petkov <bp-Gina5bIWoIWzQB+pC5nmwQ@public.gmane.org>, Grant Likely <grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, Marc Zyngier <marc.zyngier-5wv7dgnIgG8@public.gmane.org>, Yingjoe Chen <yingjoe.chen-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>, Tony Luck <tony.luck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Fenghua Yu <fenghua.yu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, Joerg Roedel <joro-zLv9SwRftAIdnm+yROfE0A@public.gmane.org>, Vinod Koul <vinod.koul-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Matthias Brugger <matthias.bgg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Jiang Liu <jiang.liu-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Cc: linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-pci-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dmaengine-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org

Refine the interfaces to create IRQ for DMAR unit. It's a preparation
for converting DMAR IRQ to irqdomain on x86.

It also moves dmar_alloc_hwirq()/dmar_free_hwirq() from irq_remapping.h
to dmar.h. They are not irq_remapping specific.

Signed-off-by: Jiang Liu <jiang.liu@linux.intel.com>
---
 arch/ia64/include/asm/irq_remapping.h |    2 --
 arch/ia64/kernel/msi_ia64.c           |   30 +++++++++++++++++++-----------
 arch/x86/include/asm/irq_remapping.h  |    4 ----
 arch/x86/kernel/apic/msi.c            |   24 +++++++++++++-----------
 drivers/iommu/dmar.c                  |   19 +++++--------------
 include/linux/dmar.h                  |    3 ++-
 6 files changed, 39 insertions(+), 43 deletions(-)

diff --git a/arch/ia64/include/asm/irq_remapping.h b/arch/ia64/include/asm/irq_remapping.h
index e3b3556e2e1b..a8687b1d8906 100644
--- a/arch/ia64/include/asm/irq_remapping.h
+++ b/arch/ia64/include/asm/irq_remapping.h
@@ -1,6 +1,4 @@
 #ifndef __IA64_INTR_REMAPPING_H
 #define __IA64_INTR_REMAPPING_H
 #define irq_remapping_enabled 0
-#define dmar_alloc_hwirq	create_irq
-#define dmar_free_hwirq		destroy_irq
 #endif
diff --git a/arch/ia64/kernel/msi_ia64.c b/arch/ia64/kernel/msi_ia64.c
index 8c3730c3c63d..15032330573b 100644
--- a/arch/ia64/kernel/msi_ia64.c
+++ b/arch/ia64/kernel/msi_ia64.c
@@ -166,7 +166,7 @@ static struct irq_chip dmar_msi_type = {
 	.irq_retrigger = ia64_msi_retrigger_irq,
 };
 
-static int
+static void
 msi_compose_msg(struct pci_dev *pdev, unsigned int irq, struct msi_msg *msg)
 {
 	struct irq_cfg *cfg = irq_cfg + irq;
@@ -188,21 +188,29 @@ msi_compose_msg(struct pci_dev *pdev, unsigned int irq, struct msi_msg *msg)
 		MSI_DATA_LEVEL_ASSERT |
 		MSI_DATA_DELIVERY_FIXED |
 		MSI_DATA_VECTOR(cfg->vector);
-	return 0;
 }
 
-int arch_setup_dmar_msi(unsigned int irq)
+int dmar_alloc_hwirq(int id, int node, void *arg)
 {
-	int ret;
+	int irq;
 	struct msi_msg msg;
 
-	ret = msi_compose_msg(NULL, irq, &msg);
-	if (ret < 0)
-		return ret;
-	dmar_msi_write(irq, &msg);
-	irq_set_chip_and_handler_name(irq, &dmar_msi_type, handle_edge_irq,
-				      "edge");
-	return 0;
+	irq = create_irq();
+	if (irq > 0) {
+		irq_set_handler_data(irq, arg);
+		irq_set_chip_and_handler_name(irq, &dmar_msi_type,
+					      handle_edge_irq, "edge");
+		msi_compose_msg(NULL, irq, &msg);
+		dmar_msi_write(irq, &msg);
+	}
+
+	return irq;
+}
+
+void dmar_free_hwirq(int irq)
+{
+	irq_set_handler_data(irq, NULL);
+	destroy_irq(irq);
 }
 #endif /* CONFIG_INTEL_IOMMU */
 
diff --git a/arch/x86/include/asm/irq_remapping.h b/arch/x86/include/asm/irq_remapping.h
index 61c50e6e28c8..61ec9234c88e 100644
--- a/arch/x86/include/asm/irq_remapping.h
+++ b/arch/x86/include/asm/irq_remapping.h
@@ -124,8 +124,4 @@ irq_remapping_get_irq_domain(struct irq_alloc_info *info)
 
 #define	irq_remapping_print_chip	NULL
 #endif /* CONFIG_IRQ_REMAP */
-
-extern int dmar_alloc_hwirq(void);
-extern void dmar_free_hwirq(int irq);
-
 #endif /* __X86_IRQ_REMAPPING_H */
diff --git a/arch/x86/kernel/apic/msi.c b/arch/x86/kernel/apic/msi.c
index 6bfe85e96c74..79fc6bb0d104 100644
--- a/arch/x86/kernel/apic/msi.c
+++ b/arch/x86/kernel/apic/msi.c
@@ -219,25 +219,27 @@ static struct irq_chip dmar_msi_type = {
  	.flags			= IRQCHIP_SKIP_SET_WAKE,
 };
 
-int arch_setup_dmar_msi(unsigned int irq)
+int dmar_alloc_hwirq(int id, int node, void *arg)
 {
+	int irq;
 	struct msi_msg msg;
-	struct irq_cfg *cfg = irq_cfg(irq);
 
-	native_compose_msi_msg(cfg, &msg);
-	dmar_msi_write(irq, &msg);
-	irq_set_chip_and_handler_name(irq, &dmar_msi_type, handle_edge_irq,
-				      "edge");
-	return 0;
-}
+	irq = irq_domain_alloc_irqs(NULL, 1, node, NULL);
+	if (irq > 0) {
+		irq_set_handler_data(irq, arg);
+		irq_set_chip_and_handler_name(irq, &dmar_msi_type,
+					      handle_edge_irq, "edge");
+		native_compose_msi_msg(irq_cfg(irq), &msg);
+		dmar_msi_write(irq, &msg);
+	}
 
-int dmar_alloc_hwirq(void)
-{
-	return irq_domain_alloc_irqs(NULL, 1, NUMA_NO_NODE, NULL);
+	return irq;
 }
 
 void dmar_free_hwirq(int irq)
 {
+	irq_set_handler_data(irq, NULL);
+	irq_set_handler(irq, NULL);
 	irq_domain_free_irqs(irq, 1);
 }
 #endif
diff --git a/drivers/iommu/dmar.c b/drivers/iommu/dmar.c
index c5c61cabd6e3..25f47937f1d5 100644
--- a/drivers/iommu/dmar.c
+++ b/drivers/iommu/dmar.c
@@ -1018,8 +1018,8 @@ static void free_iommu(struct intel_iommu *iommu)
 
 	if (iommu->irq) {
 		free_irq(iommu->irq, iommu);
-		irq_set_handler_data(iommu->irq, NULL);
 		dmar_free_hwirq(iommu->irq);
+		iommu->irq = 0;
 	}
 
 	if (iommu->qi) {
@@ -1572,23 +1572,14 @@ int dmar_set_interrupt(struct intel_iommu *iommu)
 	if (iommu->irq)
 		return 0;
 
-	irq = dmar_alloc_hwirq();
-	if (irq <= 0) {
+	irq = dmar_alloc_hwirq(iommu->seq_id, iommu->node, iommu);
+	if (irq > 0) {
+		iommu->irq = irq;
+	} else {
 		pr_err("IOMMU: no free vectors\n");
 		return -EINVAL;
 	}
 
-	irq_set_handler_data(irq, iommu);
-	iommu->irq = irq;
-
-	ret = arch_setup_dmar_msi(irq);
-	if (ret) {
-		irq_set_handler_data(irq, NULL);
-		iommu->irq = 0;
-		dmar_free_hwirq(irq);
-		return ret;
-	}
-
 	ret = request_irq(irq, dmar_fault, IRQF_NO_THREAD, iommu->name, iommu);
 	if (ret)
 		pr_err("IOMMU: can't request irq\n");
diff --git a/include/linux/dmar.h b/include/linux/dmar.h
index 593fff99e6bf..df3918482073 100644
--- a/include/linux/dmar.h
+++ b/include/linux/dmar.h
@@ -189,6 +189,7 @@ extern void dmar_msi_read(int irq, struct msi_msg *msg);
 extern void dmar_msi_write(int irq, struct msi_msg *msg);
 extern int dmar_set_interrupt(struct intel_iommu *iommu);
 extern irqreturn_t dmar_fault(int irq, void *dev_id);
-extern int arch_setup_dmar_msi(unsigned int irq);
+extern int dmar_alloc_hwirq(int id, int node, void *arg);
+extern void dmar_free_hwirq(int irq);
 
 #endif /* __DMAR_H__ */
-- 
1.7.10.4

