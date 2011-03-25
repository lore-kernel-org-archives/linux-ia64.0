From: Thomas Gleixner <tglx@linutronix.de>
Date: Fri, 25 Mar 2011 20:51:49 +0000
Subject: [patch 03/23] ia64-convert-irq-migr.patch
Message-Id: <20110325204514.781910475@linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
 arch/ia64/kernel/irq.c |   27 ++++++++++++++-------------
 1 file changed, 14 insertions(+), 13 deletions(-)

Index: linux-2.6-tip/arch/ia64/kernel/irq.c
=================================--- linux-2.6-tip.orig/arch/ia64/kernel/irq.c
+++ linux-2.6-tip/arch/ia64/kernel/irq.c
@@ -130,11 +130,12 @@ unsigned int vectors_in_migration[NR_IRQ
  */
 static void migrate_irqs(void)
 {
-	struct irq_desc *desc;
 	int 		irq, new_cpu;
 
 	for (irq=0; irq < NR_IRQS; irq++) {
-		desc = irq_desc + irq;
+		struct irq_desc *desc = irq_to_desc(irq);
+		struct irq_data *data = irq_desc_get_irq_data(desc);
+		struct irq_chip *chip = irq_data_get_irq_chip(data);
 
 		if (desc->status = IRQ_DISABLED)
 			continue;
@@ -145,10 +146,10 @@ static void migrate_irqs(void)
 		 * tell CPU not to respond to these local intr sources.
 		 * such as ITV,CPEI,MCA etc.
 		 */
-		if (desc->status = IRQ_PER_CPU)
+		if (irqd_is_per_cpu(data))
 			continue;
 
-		if (cpumask_any_and(irq_desc[irq].affinity, cpu_online_mask)
+		if (cpumask_any_and(data->affinity, cpu_online_mask)
 		    >= nr_cpu_ids) {
 			/*
 			 * Save it for phase 2 processing
@@ -160,16 +161,16 @@ static void migrate_irqs(void)
 			/*
 			 * Al three are essential, currently WARN_ON.. maybe panic?
 			 */
-			if (desc->chip && desc->chip->disable &&
-				desc->chip->enable && desc->chip->set_affinity) {
-				desc->chip->disable(irq);
-				desc->chip->set_affinity(irq,
-							 cpumask_of(new_cpu));
-				desc->chip->enable(irq);
+			if (chip && chip->irq_disable &&
+				chip->irq_enable && chip->irq_set_affinity) {
+				chip->irq_disable(data);
+				chip->irq_set_affinity(data,
+						       cpumask_of(new_cpu), false);
+				chip->irq_enable(data);
 			} else {
-				WARN_ON((!(desc->chip) || !(desc->chip->disable) ||
-						!(desc->chip->enable) ||
-						!(desc->chip->set_affinity)));
+				WARN_ON((!chip || !chip->irq_disable ||
+					 !chip->irq_enable ||
+					 !chip->irq_set_affinity));
 			}
 		}
 	}


