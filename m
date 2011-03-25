From: Thomas Gleixner <tglx@linutronix.de>
Date: Fri, 25 Mar 2011 20:51:49 +0000
Subject: [patch 02/23] ia64: Convert migrate_platform_irqs() to new irq chip
Message-Id: <20110325204514.688003563@linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
 arch/ia64/kernel/smpboot.c |   14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

Index: linux-2.6-tip/arch/ia64/kernel/smpboot.c
=================================--- linux-2.6-tip.orig/arch/ia64/kernel/smpboot.c
+++ linux-2.6-tip/arch/ia64/kernel/smpboot.c
@@ -677,7 +677,7 @@ extern void fixup_irqs(void);
 int migrate_platform_irqs(unsigned int cpu)
 {
 	int new_cpei_cpu;
-	struct irq_desc *desc = NULL;
+	struct irq_data *data = NULL;
 	const struct cpumask *mask;
 	int 		retval = 0;
 
@@ -693,20 +693,20 @@ int migrate_platform_irqs(unsigned int c
 			new_cpei_cpu = any_online_cpu(cpu_online_map);
 			mask = cpumask_of(new_cpei_cpu);
 			set_cpei_target_cpu(new_cpei_cpu);
-			desc = irq_desc + ia64_cpe_irq;
+			data = irq_get_irq_data(ia64_cpe_irq);
 			/*
 			 * Switch for now, immediately, we need to do fake intr
 			 * as other interrupts, but need to study CPEI behaviour with
 			 * polling before making changes.
 			 */
-			if (desc) {
-				desc->chip->disable(ia64_cpe_irq);
-				desc->chip->set_affinity(ia64_cpe_irq, mask);
-				desc->chip->enable(ia64_cpe_irq);
+			if (data && data->chip) {
+				data->chip->irq_disable(data);
+				data->chip->irq_set_affinity(data, mask, false);
+				data->chip->irq_enable(data);
 				printk ("Re-targetting CPEI to cpu %d\n", new_cpei_cpu);
 			}
 		}
-		if (!desc) {
+		if (!data) {
 			printk ("Unable to retarget CPEI, offline cpu [%d] failed\n", cpu);
 			retval = -EBUSY;
 		}


