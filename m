From: Ishimatsu Yasuaki <isimatu.yasuaki@jp.fujitsu.com>
Date: Wed, 09 May 2007 07:53:45 +0000
Subject: [PATCH 5/12]  Use dynamic irq for iosapic interrupts
Message-Id: <46417E09.7010509@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Use create_irq()/destroy_irq() for iosapic interrupts.

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

---
 arch/ia64/kernel/iosapic.c |   39 +++++++++++++++------------------------
 1 files changed, 15 insertions(+), 24 deletions(-)

Index: linux-2.6.21/arch/ia64/kernel/iosapic.c
=================================--- linux-2.6.21.orig/arch/ia64/kernel/iosapic.c	2007-05-07 11:44:21.000000000 +0900
+++ linux-2.6.21/arch/ia64/kernel/iosapic.c	2007-05-08 12:08:05.000000000 +0900
@@ -534,12 +534,13 @@
 static void __init
 iosapic_reassign_vector (int vector)
 {
-	int new_vector;
+	int irq, new_vector;

 	if (!list_empty(&iosapic_intr_info[vector].rtes)) {
-		new_vector = assign_irq_vector(AUTO_ASSIGN);
-		if (new_vector < 0)
+		irq = create_irq();
+		if (irq < 0)
 			panic("%s: out of interrupt vectors!\n", __FUNCTION__);
+		new_vector = irq_to_vector(irq);
 		printk(KERN_INFO "Reassigning vector %d to %d\n",
 		       vector, new_vector);
 		memcpy(&iosapic_intr_info[new_vector], &iosapic_intr_info[vector],
@@ -754,7 +755,7 @@
 iosapic_register_intr (unsigned int gsi,
 		       unsigned long polarity, unsigned long trigger)
 {
-	int vector, mask = 1, err;
+	int irq, vector, mask = 1, err;
 	unsigned int dest;
 	unsigned long flags;
 	struct iosapic_rte_info *rte;
@@ -774,12 +775,13 @@
 	}

 	/* If vector is running out, we try to find a sharable vector */
-	vector = assign_irq_vector(AUTO_ASSIGN);
-	if (vector < 0) {
+	irq = create_irq();
+	if (irq < 0) {
 		vector = iosapic_find_sharable_vector(trigger, polarity);
   		if (vector < 0)
 			goto unlock_iosapic_lock;
-	}
+	} else
+		vector = irq_to_vector(irq);

 	spin_lock(&irq_desc[vector].lock);
 	dest = get_target_cpu(gsi, vector);
@@ -874,30 +876,18 @@
 	if (list_empty(&iosapic_intr_info[vector].rtes)) {
 		/* Sanity check */
 		BUG_ON(iosapic_intr_info[vector].count);
-
-		/* Clear the interrupt controller descriptor */
-		idesc->chip = &no_irq_type;
-
 #ifdef CONFIG_SMP
 		/* Clear affinity */
 		cpus_setall(idesc->affinity);
 #endif
-
 		/* Clear the interrupt information */
 		memset(&iosapic_intr_info[vector], 0,
 		       sizeof(struct iosapic_intr_info));
 		iosapic_intr_info[vector].low32 |= IOSAPIC_MASK;
 		INIT_LIST_HEAD(&iosapic_intr_info[vector].rtes);

-		if (idesc->action) {
-			printk(KERN_ERR
-			       "interrupt handlers still exist on IRQ %u\n",
-			       irq);
-			WARN_ON(1);
-		}
-
-		/* Free the interrupt vector */
-		free_irq_vector(vector);
+		/* Destroy IRQ */
+		destroy_irq(irq);
 	}
  out:
 	spin_unlock_irqrestore(&iosapic_lock, flags);
@@ -913,7 +903,7 @@
 {
 	static const char * const name[] = {"unknown", "PMI", "INIT", "CPEI"};
 	unsigned char delivery;
-	int vector, mask = 0;
+	int irq, vector, mask = 0;
 	unsigned int dest = ((id << 8) | eid) & 0xffff;

 	switch (int_type) {
@@ -927,9 +917,10 @@
 		delivery = IOSAPIC_PMI;
 		break;
 	      case ACPI_INTERRUPT_INIT:
-		vector = assign_irq_vector(AUTO_ASSIGN);
-		if (vector < 0)
+		irq = create_irq();
+		if (irq < 0)
 			panic("%s: out of interrupt vectors!\n", __FUNCTION__);
+		vector = irq_to_vector(irq);
 		delivery = IOSAPIC_INIT;
 		break;
 	      case ACPI_INTERRUPT_CPEI:


