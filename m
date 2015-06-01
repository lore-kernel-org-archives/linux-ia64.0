From: Jiang Liu <jiang.liu@linux.intel.com>
Date: Mon, 01 Jun 2015 08:05:28 +0000
Subject: [Patch v3 19/36] IA64, irq: Use access helper irq_data_get_affinity_mask()
Message-Id: <1433145945-789-20-git-send-email-jiang.liu@linux.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1433145945-789-1-git-send-email-jiang.liu@linux.intel.com>
In-Reply-To: <1433145945-789-1-git-send-email-jiang.liu@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Gleixner <tglx@linutronix.de>, Bjorn Helgaas <bhelgaas@google.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Randy Dunlap <rdunlap@infradead.org>, Yinghai Lu <yinghai@kernel.org>, Borislav Petkov <bp@alien8.de>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Jiang Liu <jiang.liu@linux.intel.com>, Rusty Russell <rusty@rustcorp.com.au>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-acpi@vger.kernel.org, linux-ia64@vger.kernel.org

Use access helper irq_data_get_affinity_mask() to hide implementation
details of struct irq_desc.

Signed-off-by: Jiang Liu <jiang.liu@linux.intel.com>
---
 arch/ia64/kernel/iosapic.c   |    2 +-
 arch/ia64/kernel/irq.c       |    6 +++---
 arch/ia64/kernel/msi_ia64.c  |    4 ++--
 arch/ia64/sn/kernel/msi_sn.c |    2 +-
 4 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/arch/ia64/kernel/iosapic.c b/arch/ia64/kernel/iosapic.c
index bc9501e36e77..4d2698d43c39 100644
--- a/arch/ia64/kernel/iosapic.c
+++ b/arch/ia64/kernel/iosapic.c
@@ -838,7 +838,7 @@ iosapic_unregister_intr (unsigned int gsi)
 	if (iosapic_intr_info[irq].count = 0) {
 #ifdef CONFIG_SMP
 		/* Clear affinity */
-		cpumask_setall(irq_get_irq_data(irq)->affinity);
+		cpumask_setall(irq_get_affinity_mask(irq));
 #endif
 		/* Clear the interrupt information */
 		iosapic_intr_info[irq].dest = 0;
diff --git a/arch/ia64/kernel/irq.c b/arch/ia64/kernel/irq.c
index 812a1e6b3179..de4fc00dea98 100644
--- a/arch/ia64/kernel/irq.c
+++ b/arch/ia64/kernel/irq.c
@@ -67,7 +67,7 @@ static char irq_redir [NR_IRQS]; // = { [0 ... NR_IRQS-1] = 1 };
 void set_irq_affinity_info (unsigned int irq, int hwid, int redir)
 {
 	if (irq < NR_IRQS) {
-		cpumask_copy(irq_get_irq_data(irq)->affinity,
+		cpumask_copy(irq_get_affinity_mask(irq),
 			     cpumask_of(cpu_logical_id(hwid)));
 		irq_redir[irq] = (char) (redir & 0xff);
 	}
@@ -119,8 +119,8 @@ static void migrate_irqs(void)
 		if (irqd_is_per_cpu(data))
 			continue;
 
-		if (cpumask_any_and(data->affinity, cpu_online_mask)
-		    >= nr_cpu_ids) {
+		if (cpumask_any_and(irq_data_get_affinity_mask(data),
+				    cpu_online_mask) >= nr_cpu_ids) {
 			/*
 			 * Save it for phase 2 processing
 			 */
diff --git a/arch/ia64/kernel/msi_ia64.c b/arch/ia64/kernel/msi_ia64.c
index d70bf15c690a..6c50d332b7d7 100644
--- a/arch/ia64/kernel/msi_ia64.c
+++ b/arch/ia64/kernel/msi_ia64.c
@@ -36,7 +36,7 @@ static int ia64_set_msi_irq_affinity(struct irq_data *idata,
 	msg.data = data;
 
 	pci_write_msi_msg(irq, &msg);
-	cpumask_copy(idata->affinity, cpumask_of(cpu));
+	cpumask_copy(irq_data_get_affinity_mask(idata), cpumask_of(cpu));
 
 	return 0;
 }
@@ -148,7 +148,7 @@ static int dmar_msi_set_affinity(struct irq_data *data,
 	msg.address_lo |= MSI_ADDR_DEST_ID_CPU(cpu_physical_id(cpu));
 
 	dmar_msi_write(irq, &msg);
-	cpumask_copy(data->affinity, mask);
+	cpumask_copy(irq_data_get_affinity_mask(data), mask);
 
 	return 0;
 }
diff --git a/arch/ia64/sn/kernel/msi_sn.c b/arch/ia64/sn/kernel/msi_sn.c
index a0eb27b66d13..42b5a13af142 100644
--- a/arch/ia64/sn/kernel/msi_sn.c
+++ b/arch/ia64/sn/kernel/msi_sn.c
@@ -206,7 +206,7 @@ static int sn_set_msi_irq_affinity(struct irq_data *data,
 	msg.address_lo = (u32)(bus_addr & 0x00000000ffffffff);
 
 	pci_write_msi_msg(irq, &msg);
-	cpumask_copy(data->affinity, cpu_mask);
+	cpumask_copy(irq_data_get_affinity_mask(data), cpu_mask);
 
 	return 0;
 }
-- 
1.7.10.4

