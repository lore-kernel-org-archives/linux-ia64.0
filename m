From: Thomas Gleixner <tglx@linutronix.de>
Date: Fri, 25 Mar 2011 20:51:53 +0000
Subject: [patch 08/23] ia64: Convert sn to new irq_chip functions
Message-Id: <20110325204515.256557549@linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
 arch/ia64/sn/kernel/irq.c |   44 +++++++++++++++++++++++---------------------
 1 file changed, 23 insertions(+), 21 deletions(-)

Index: linux-2.6-tip/arch/ia64/sn/kernel/irq.c
=================================--- linux-2.6-tip.orig/arch/ia64/sn/kernel/irq.c
+++ linux-2.6-tip/arch/ia64/sn/kernel/irq.c
@@ -78,34 +78,34 @@ u64 sn_intr_redirect(nasid_t local_nasid
 	return ret_stuff.status;
 }
 
-static unsigned int sn_startup_irq(unsigned int irq)
+static unsigned int sn_startup_irq(struct irq_data *data)
 {
 	return 0;
 }
 
-static void sn_shutdown_irq(unsigned int irq)
+static void sn_shutdown_irq(struct irq_data *data)
 {
 }
 
 extern void ia64_mca_register_cpev(int);
 
-static void sn_disable_irq(unsigned int irq)
+static void sn_disable_irq(struct irq_data *data)
 {
-	if (irq = local_vector_to_irq(IA64_CPE_VECTOR))
+	if (data->irq = local_vector_to_irq(IA64_CPE_VECTOR))
 		ia64_mca_register_cpev(0);
 }
 
-static void sn_enable_irq(unsigned int irq)
+static void sn_enable_irq(struct irq_data *data)
 {
-	if (irq = local_vector_to_irq(IA64_CPE_VECTOR))
-		ia64_mca_register_cpev(irq);
+	if (data->irq = local_vector_to_irq(IA64_CPE_VECTOR))
+		ia64_mca_register_cpev(data->irq);
 }
 
-static void sn_ack_irq(unsigned int irq)
+static void sn_ack_irq(struct irq_data *data)
 {
 	u64 event_occurred, mask;
+	unsigned int irq = data->irq & 0xff;
 
-	irq = irq & 0xff;
 	event_occurred = HUB_L((u64*)LOCAL_MMR_ADDR(SH_EVENT_OCCURRED));
 	mask = event_occurred & SH_ALL_INT_MASK;
 	HUB_S((u64*)LOCAL_MMR_ADDR(SH_EVENT_OCCURRED_ALIAS), mask);
@@ -206,9 +206,11 @@ finish_up:
 	return new_irq_info;
 }
 
-static int sn_set_affinity_irq(unsigned int irq, const struct cpumask *mask)
+static int sn_set_affinity_irq(struct irq_data *data,
+			       const struct cpumask *mask, bool force)
 {
 	struct sn_irq_info *sn_irq_info, *sn_irq_info_safe;
+	unsigned int irq = data->irq;
 	nasid_t nasid;
 	int slice;
 
@@ -237,25 +239,25 @@ void sn_set_err_irq_affinity(unsigned in
 #endif
 
 static void
-sn_mask_irq(unsigned int irq)
+sn_mask_irq(struct irq_data *data)
 {
 }
 
 static void
-sn_unmask_irq(unsigned int irq)
+sn_unmask_irq(struct irq_data *data)
 {
 }
 
 struct irq_chip irq_type_sn = {
-	.name		= "SN hub",
-	.startup	= sn_startup_irq,
-	.shutdown	= sn_shutdown_irq,
-	.enable		= sn_enable_irq,
-	.disable	= sn_disable_irq,
-	.ack		= sn_ack_irq,
-	.mask		= sn_mask_irq,
-	.unmask		= sn_unmask_irq,
-	.set_affinity	= sn_set_affinity_irq
+	.name			= "SN hub",
+	.irq_startup		= sn_startup_irq,
+	.irq_shutdown		= sn_shutdown_irq,
+	.irq_enable		= sn_enable_irq,
+	.irq_disable		= sn_disable_irq,
+	.irq_ack		= sn_ack_irq,
+	.irq_mask		= sn_mask_irq,
+	.irq_unmask		= sn_unmask_irq,
+	.irq_set_affinity	= sn_set_affinity_irq
 };
 
 ia64_vector sn_irq_to_vector(int irq)


