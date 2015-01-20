From: Jiang Liu <jiang.liu@linux.intel.com>
Date: Tue, 20 Jan 2015 03:08:22 +0000
Subject: [Patch Part1 v7 19/38] iommu/vt-d: Refine the interfaces to create IRQ for DMAR unit
Message-Id: <1421723321-8386-20-git-send-email-jiang.liu@linux.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1421723321-8386-1-git-send-email-jiang.liu@linux.intel.com>
In-Reply-To: <1421723321-8386-1-git-send-email-jiang.liu-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, "Rafael J. Wysocki" <rjw-LthD3rsA81gm4RdzfppkhA@public.gmane.org>, Randy Dunlap <rdunlap-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, Yinghai Lu <yinghai-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Borislav Petkov <bp-Gina5bIWoIWzQB+pC5nmwQ@public.gmane.org>, Dimitri Sivanich <sivanich-sJ/iWh9BUns@public.gmane.org>, Tony Luck <tony.luck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Fenghua Yu <fenghua.yu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, Joerg Roedel <joro-zLv9SwRftAIdnm+yROfE0A@public.gmane.org>, Vinod Koul <vinod.koul-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Jiang Liu <jiang.liu-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Cc: linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Cohen <david.a.cohen-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>, Sander Eikelenboom <linux-6SM94LqRVpn6gRhOQ7JHfg@public.gmane.org>, iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, David Vrabel <david.vrabel-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>, linux-pci-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dmaengine-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>

Refine the interfaces to create IRQ for DMAR unit. It's a preparation
for converting DMAR IRQ to hierarchy irqdomain on x86.

It also moves dmar_alloc_hwirq()/dmar_free_hwirq() from irq_remapping.h
to dmar.h. They are not irq_remapping specific.

Signed-off-by: Jiang Liu <jiang.liu@linux.intel.com>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: iommu@lists.linux-foundation.org
Cc: Bjorn Helgaas <bhelgaas@google.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Rafael J. Wysocki <rjw@rjwysocki.net>
Cc: Randy Dunlap <rdunlap@infradead.org>
Cc: Yinghai Lu <yinghai@kernel.org>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: Joerg Roedel <joro@8bytes.org>
Cc: Vinod Koul <vinod.koul@intel.com>
Link: http://lkml.kernel.org/r/1416894816-23245-20-git-send-email-jiang.liu@linux.intel.com
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
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
index 8ae36ea177d3..3f6b76135645 100644
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
index a6d0cca0d08f..79f1a84e6a85 100644
--- a/arch/x86/include/asm/irq_remapping.h
+++ b/arch/x86/include/asm/irq_remapping.h
@@ -117,8 +117,4 @@ irq_remapping_get_irq_domain(struct irq_alloc_info *info)
 
 #define	irq_remapping_print_chip	NULL
 #endif /* CONFIG_IRQ_REMAP */
-
-extern int dmar_alloc_hwirq(void);
-extern void dmar_free_hwirq(int irq);
-
 #endif /* __X86_IRQ_REMAPPING_H */
diff --git a/arch/x86/kernel/apic/msi.c b/arch/x86/kernel/apic/msi.c
index afaaa1166a7d..695c82bbd682 100644
--- a/arch/x86/kernel/apic/msi.c
+++ b/arch/x86/kernel/apic/msi.c
@@ -228,25 +228,27 @@ static struct irq_chip dmar_msi_type = {
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
index 9847613085e1..536f2d8ea41a 100644
--- a/drivers/iommu/dmar.c
+++ b/drivers/iommu/dmar.c
@@ -1087,8 +1087,8 @@ static void free_iommu(struct intel_iommu *iommu)
 
 	if (iommu->irq) {
 		free_irq(iommu->irq, iommu);
-		irq_set_handler_data(iommu->irq, NULL);
 		dmar_free_hwirq(iommu->irq);
+		iommu->irq = 0;
 	}
 
 	if (iommu->qi) {
@@ -1642,23 +1642,14 @@ int dmar_set_interrupt(struct intel_iommu *iommu)
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
index 30624954dec5..84737565c1fd 100644
--- a/include/linux/dmar.h
+++ b/include/linux/dmar.h
@@ -227,6 +227,7 @@ extern void dmar_msi_read(int irq, struct msi_msg *msg);
 extern void dmar_msi_write(int irq, struct msi_msg *msg);
 extern int dmar_set_interrupt(struct intel_iommu *iommu);
 extern irqreturn_t dmar_fault(int irq, void *dev_id);
-extern int arch_setup_dmar_msi(unsigned int irq);
+extern int dmar_alloc_hwirq(int id, int node, void *arg);
+extern void dmar_free_hwirq(int irq);
 
 #endif /* __DMAR_H__ */
-- 
1.7.10.4

