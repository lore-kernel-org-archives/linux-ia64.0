From: Thomas Gleixner <tglx@linutronix.de>
Date: Fri, 25 Mar 2011 20:51:57 +0000
Subject: [patch 13/23] ia64: iosapic: Cleanup irq_desc access
Message-Id: <20110325204515.734357943@linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Use irq_to_desc() and use accessors for setting chip and handler.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
 arch/ia64/kernel/iosapic.c |   32 +++++++++++++++-----------------
 1 file changed, 15 insertions(+), 17 deletions(-)

Index: linux-2.6-tip/arch/ia64/kernel/iosapic.c
=================================--- linux-2.6-tip.orig/arch/ia64/kernel/iosapic.c
+++ linux-2.6-tip/arch/ia64/kernel/iosapic.c
@@ -566,8 +566,7 @@ static int
 register_intr (unsigned int gsi, int irq, unsigned char delivery,
 	       unsigned long polarity, unsigned long trigger)
 {
-	struct irq_desc *idesc;
-	struct irq_chip *irq_type;
+	struct irq_chip *chip, *irq_type;
 	int index;
 	struct iosapic_rte_info *rte;
 
@@ -614,19 +613,18 @@ register_intr (unsigned int gsi, int irq
 
 	irq_type = iosapic_get_irq_chip(trigger);
 
-	idesc = irq_desc + irq;
-	if (irq_type != NULL && idesc->chip != irq_type) {
-		if (idesc->chip != &no_irq_chip)
+	chip = irq_get_chip(irq);
+	if (irq_type != NULL && chip != irq_type) {
+		if (chip != &no_irq_chip)
 			printk(KERN_WARNING
 			       "%s: changing vector %d from %s to %s\n",
 			       __func__, irq_to_vector(irq),
-			       idesc->chip->name, irq_type->name);
-		idesc->chip = irq_type;
+			       chip->name, irq_type->name);
+		chip = irq_type;
 	}
-	if (trigger = IOSAPIC_EDGE)
-		__set_irq_handler_unlocked(irq, handle_edge_irq);
-	else
-		__set_irq_handler_unlocked(irq, handle_level_irq);
+	__irq_set_chip_handler_name_locked(irq, chip, trigger = IOSAPIC_EDGE ?
+					   handle_edge_irq : handle_level_irq,
+					   NULL);
 	return 0;
 }
 
@@ -736,6 +734,7 @@ iosapic_register_intr (unsigned int gsi,
 	struct iosapic_rte_info *rte;
 	u32 low32;
 	unsigned char dmode;
+	struct irq_desc *desc;
 
 	/*
 	 * If this GSI has already been registered (i.e., it's a
@@ -763,12 +762,13 @@ iosapic_register_intr (unsigned int gsi,
 			goto unlock_iosapic_lock;
 	}
 
-	raw_spin_lock(&irq_desc[irq].lock);
+	desc = irq_to_desc(irq);
+	raw_spin_lock(&desc->lock);
 	dest = get_target_cpu(gsi, irq);
 	dmode = choose_dmode();
 	err = register_intr(gsi, irq, dmode, polarity, trigger);
 	if (err < 0) {
-		raw_spin_unlock(&irq_desc[irq].lock);
+		raw_spin_unlock(&desc->lock);
 		irq = err;
 		goto unlock_iosapic_lock;
 	}
@@ -787,7 +787,7 @@ iosapic_register_intr (unsigned int gsi,
 	       (polarity = IOSAPIC_POL_HIGH ? "high" : "low"),
 	       cpu_logical_id(dest), dest, irq_to_vector(irq));
 
-	raw_spin_unlock(&irq_desc[irq].lock);
+	raw_spin_unlock(&desc->lock);
  unlock_iosapic_lock:
 	spin_unlock_irqrestore(&iosapic_lock, flags);
 	return irq;
@@ -798,7 +798,6 @@ iosapic_unregister_intr (unsigned int gs
 {
 	unsigned long flags;
 	int irq, index;
-	struct irq_desc *idesc;
 	u32 low32;
 	unsigned long trigger, polarity;
 	unsigned int dest;
@@ -828,7 +827,6 @@ iosapic_unregister_intr (unsigned int gs
 	if (--rte->refcnt > 0)
 		goto out;
 
-	idesc = irq_desc + irq;
 	rte->refcnt = NO_REF_RTE;
 
 	/* Mask the interrupt */
@@ -852,7 +850,7 @@ iosapic_unregister_intr (unsigned int gs
 	if (iosapic_intr_info[irq].count = 0) {
 #ifdef CONFIG_SMP
 		/* Clear affinity */
-		cpumask_setall(idesc->affinity);
+		cpumask_setall(irq_get_irq_data(irq)->affinity);
 #endif
 		/* Clear the interrupt information */
 		iosapic_intr_info[irq].dest = 0;


