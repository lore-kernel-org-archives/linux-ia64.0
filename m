From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Date: Tue, 19 Jun 2007 08:15:59 +0000
Subject: [PATCH take2 4/13]  Cleanup lock order in iosapic_register_intr
Message-Id: <467790BF.8020902@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Cleanup order of irq_desc.lock and iosapic_lock in
iosapic_register_intr() and iosapic_unregister_intr().

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

---
 arch/ia64/kernel/iosapic.c |   50 ++++++++++++++++++---------------------------
 1 files changed, 20 insertions(+), 30 deletions(-)

Index: linux-2.6.22-rc5/arch/ia64/kernel/iosapic.c
=================================--- linux-2.6.22-rc5.orig/arch/ia64/kernel/iosapic.c	2007-06-19 15:33:23.000000000 +0900
+++ linux-2.6.22-rc5/arch/ia64/kernel/iosapic.c	2007-06-19 15:33:26.000000000 +0900
@@ -501,7 +501,7 @@ iosapic_version (char __iomem *addr)
 static int iosapic_find_sharable_vector (unsigned long trigger,
 					 unsigned long pol)
 {
-	int i, vector = -1, min_count = -1;
+	int i, vector = -ENOSPC, min_count = -1;
 	struct iosapic_intr_info *info;

 	/*
@@ -509,7 +509,7 @@ static int iosapic_find_sharable_vector
 	 * supported yet
 	 */
 	if (trigger = IOSAPIC_EDGE)
-		return -1;
+		return -ENOSPC;

 	for (i = IA64_FIRST_DEVICE_VECTOR; i <= IA64_LAST_DEVICE_VECTOR; i++) {
 		info = &iosapic_intr_info[i];
@@ -758,7 +758,7 @@ iosapic_register_intr (unsigned int gsi,
 	unsigned long flags;
 	struct iosapic_rte_info *rte;
 	u32 low32;
-again:
+
 	/*
 	 * If this GSI has already been registered (i.e., it's a
 	 * shared interrupt, or we lost a race to register it),
@@ -769,36 +769,24 @@ again:
 	if (vector > 0) {
 		rte = gsi_vector_to_rte(gsi, vector);
 		rte->refcnt++;
-		spin_unlock_irqrestore(&iosapic_lock, flags);
-		return vector;
+		goto unlock_iosapic_lock;
 	}
-	spin_unlock_irqrestore(&iosapic_lock, flags);

 	/* If vector is running out, we try to find a sharable vector */
 	vector = assign_irq_vector(AUTO_ASSIGN);
 	if (vector < 0) {
 		vector = iosapic_find_sharable_vector(trigger, polarity);
   		if (vector < 0)
-			return -ENOSPC;
-	}
-
-	spin_lock_irqsave(&irq_desc[vector].lock, flags);
-	spin_lock(&iosapic_lock);
-	if (gsi_to_vector(gsi) > 0) {
-		if (list_empty(&iosapic_intr_info[vector].rtes))
-			free_irq_vector(vector);
-		spin_unlock(&iosapic_lock);
-		spin_unlock_irqrestore(&irq_desc[vector].lock, flags);
-		goto again;
+			goto unlock_iosapic_lock;
 	}

+	spin_lock(&irq_desc[vector].lock);
 	dest = get_target_cpu(gsi, vector);
 	err = register_intr(gsi, vector, IOSAPIC_LOWEST_PRIORITY,
 			    polarity, trigger);
 	if (err < 0) {
-		spin_unlock(&iosapic_lock);
-		spin_unlock_irqrestore(&irq_desc[vector].lock, flags);
-		return err;
+		vector = err;
+		goto unlock_all;
 	}

 	/*
@@ -809,14 +797,15 @@ again:
 	if (vector_is_shared(vector) && !(low32 & IOSAPIC_MASK))
 		mask = 0;
 	set_rte(gsi, vector, dest, mask);
-	spin_unlock(&iosapic_lock);
-	spin_unlock_irqrestore(&irq_desc[vector].lock, flags);

 	printk(KERN_INFO "GSI %u (%s, %s) -> CPU %d (0x%04x) vector %d\n",
 	       gsi, (trigger = IOSAPIC_EDGE ? "edge" : "level"),
 	       (polarity = IOSAPIC_POL_HIGH ? "high" : "low"),
 	       cpu_logical_id(dest), dest, vector);
-
+ unlock_all:
+	spin_unlock(&irq_desc[vector].lock);
+ unlock_iosapic_lock:
+	spin_unlock_irqrestore(&iosapic_lock, flags);
 	return vector;
 }

@@ -845,9 +834,7 @@ iosapic_unregister_intr (unsigned int gs
 	}
 	vector = irq_to_vector(irq);

-	idesc = irq_desc + irq;
-	spin_lock_irqsave(&idesc->lock, flags);
-	spin_lock(&iosapic_lock);
+	spin_lock_irqsave(&iosapic_lock, flags);
 	if ((rte = gsi_vector_to_rte(gsi, vector)) = NULL) {
 		printk(KERN_ERR "iosapic_unregister_intr(%u) unbalanced\n",
 		       gsi);
@@ -858,12 +845,16 @@ iosapic_unregister_intr (unsigned int gs
 	if (--rte->refcnt > 0)
 		goto out;

+	/* Remove the rte entry from the list */
+	idesc = irq_desc + irq;
+	spin_lock(&idesc->lock);
+	list_del(&rte->rte_list);
+	spin_unlock(&idesc->lock);
+
 	/* Mask the interrupt */
 	low32 = iosapic_intr_info[vector].low32 | IOSAPIC_MASK;
 	iosapic_write(rte->iosapic, IOSAPIC_RTE_LOW(rte->rte_index), low32);

-	/* Remove the rte entry from the list */
-	list_del(&rte->rte_list);
 	iosapic_intr_info[vector].count--;
 	iosapic_free_rte(rte);
 	index = find_iosapic(gsi);
@@ -908,8 +899,7 @@ iosapic_unregister_intr (unsigned int gs
 		free_irq_vector(vector);
 	}
  out:
-	spin_unlock(&iosapic_lock);
-	spin_unlock_irqrestore(&idesc->lock, flags);
+	spin_unlock_irqrestore(&iosapic_lock, flags);
 }

 /*

