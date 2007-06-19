From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Date: Tue, 19 Jun 2007 08:14:14 +0000
Subject: [PATCH take2 1/13]  Remove block structure for locking in iosapic.c
Message-Id: <46779056.2050300@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Remove unnecessary indent between spin_lock() and spin_unlock() in
iosapic.c. This has no functional changes.

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

---
 arch/ia64/kernel/iosapic.c |  303 ++++++++++++++++++++-------------------------
 1 files changed, 136 insertions(+), 167 deletions(-)

Index: linux-2.6.22-rc5/arch/ia64/kernel/iosapic.c
=================================--- linux-2.6.22-rc5.orig/arch/ia64/kernel/iosapic.c	2007-06-19 15:32:12.000000000 +0900
+++ linux-2.6.22-rc5/arch/ia64/kernel/iosapic.c	2007-06-19 15:32:20.000000000 +0900
@@ -209,9 +209,7 @@ gsi_to_irq (unsigned int gsi)
 	 * and Linux irq numbers...
 	 */
 	spin_lock_irqsave(&iosapic_lock, flags);
-	{
-		irq = _gsi_to_vector(gsi);
-	}
+	irq = _gsi_to_vector(gsi);
 	spin_unlock_irqrestore(&iosapic_lock, flags);

 	return irq;
@@ -322,15 +320,12 @@ mask_irq (unsigned int irq)
 		return;			/* not an IOSAPIC interrupt! */

 	spin_lock_irqsave(&iosapic_lock, flags);
-	{
-		/* set only the mask bit */
-		low32 = iosapic_intr_info[vec].low32 |= IOSAPIC_MASK;
-		list_for_each_entry(rte, &iosapic_intr_info[vec].rtes,
-				    rte_list) {
-			addr = rte->addr;
-			rte_index = rte->rte_index;
-			iosapic_write(addr, IOSAPIC_RTE_LOW(rte_index), low32);
-		}
+	/* set only the mask bit */
+	low32 = iosapic_intr_info[vec].low32 |= IOSAPIC_MASK;
+	list_for_each_entry(rte, &iosapic_intr_info[vec].rtes, rte_list) {
+		addr = rte->addr;
+		rte_index = rte->rte_index;
+		iosapic_write(addr, IOSAPIC_RTE_LOW(rte_index), low32);
 	}
 	spin_unlock_irqrestore(&iosapic_lock, flags);
 }
@@ -349,14 +344,11 @@ unmask_irq (unsigned int irq)
 		return;			/* not an IOSAPIC interrupt! */

 	spin_lock_irqsave(&iosapic_lock, flags);
-	{
-		low32 = iosapic_intr_info[vec].low32 &= ~IOSAPIC_MASK;
-		list_for_each_entry(rte, &iosapic_intr_info[vec].rtes,
-				    rte_list) {
-			addr = rte->addr;
-			rte_index = rte->rte_index;
-			iosapic_write(addr, IOSAPIC_RTE_LOW(rte_index), low32);
-		}
+	low32 = iosapic_intr_info[vec].low32 &= ~IOSAPIC_MASK;
+	list_for_each_entry(rte, &iosapic_intr_info[vec].rtes, rte_list) {
+		addr = rte->addr;
+		rte_index = rte->rte_index;
+		iosapic_write(addr, IOSAPIC_RTE_LOW(rte_index), low32);
 	}
 	spin_unlock_irqrestore(&iosapic_lock, flags);
 }
@@ -391,28 +383,21 @@ iosapic_set_affinity (unsigned int irq,
 	high32 = dest << IOSAPIC_DEST_SHIFT;

 	spin_lock_irqsave(&iosapic_lock, flags);
-	{
-		low32 = iosapic_intr_info[vec].low32 &
-			~(7 << IOSAPIC_DELIVERY_SHIFT);
+	low32 = iosapic_intr_info[vec].low32 & ~(7 << IOSAPIC_DELIVERY_SHIFT);
+	if (redir)
+		/* change delivery mode to lowest priority */
+		low32 |= (IOSAPIC_LOWEST_PRIORITY << IOSAPIC_DELIVERY_SHIFT);
+	else
+		/* change delivery mode to fixed */
+		low32 |= (IOSAPIC_FIXED << IOSAPIC_DELIVERY_SHIFT);

-		if (redir)
-		        /* change delivery mode to lowest priority */
-			low32 |= (IOSAPIC_LOWEST_PRIORITY <<
-				  IOSAPIC_DELIVERY_SHIFT);
-		else
-		        /* change delivery mode to fixed */
-			low32 |= (IOSAPIC_FIXED << IOSAPIC_DELIVERY_SHIFT);
-
-		iosapic_intr_info[vec].low32 = low32;
-		iosapic_intr_info[vec].dest = dest;
-		list_for_each_entry(rte, &iosapic_intr_info[vec].rtes,
-				    rte_list) {
-			addr = rte->addr;
-			rte_index = rte->rte_index;
-			iosapic_write(addr, IOSAPIC_RTE_HIGH(rte_index),
-				      high32);
-			iosapic_write(addr, IOSAPIC_RTE_LOW(rte_index), low32);
-		}
+	iosapic_intr_info[vec].low32 = low32;
+	iosapic_intr_info[vec].dest = dest;
+	list_for_each_entry(rte, &iosapic_intr_info[vec].rtes, rte_list) {
+		addr = rte->addr;
+		rte_index = rte->rte_index;
+		iosapic_write(addr, IOSAPIC_RTE_HIGH(rte_index), high32);
+		iosapic_write(addr, IOSAPIC_RTE_LOW(rte_index), low32);
 	}
 	spin_unlock_irqrestore(&iosapic_lock, flags);
 #endif
@@ -797,14 +782,12 @@ again:
 	 * don't touch the RTE.
 	 */
 	spin_lock_irqsave(&iosapic_lock, flags);
-	{
-		vector = gsi_to_vector(gsi);
-		if (vector > 0) {
-			rte = gsi_vector_to_rte(gsi, vector);
-			rte->refcnt++;
-			spin_unlock_irqrestore(&iosapic_lock, flags);
-			return vector;
-		}
+	vector = gsi_to_vector(gsi);
+	if (vector > 0) {
+		rte = gsi_vector_to_rte(gsi, vector);
+		rte->refcnt++;
+		spin_unlock_irqrestore(&iosapic_lock, flags);
+		return vector;
 	}
 	spin_unlock_irqrestore(&iosapic_lock, flags);

@@ -818,35 +801,31 @@ again:

 	spin_lock_irqsave(&irq_desc[vector].lock, flags);
 	spin_lock(&iosapic_lock);
-	{
-		if (gsi_to_vector(gsi) > 0) {
-			if (list_empty(&iosapic_intr_info[vector].rtes))
-				free_irq_vector(vector);
-			spin_unlock(&iosapic_lock);
-			spin_unlock_irqrestore(&irq_desc[vector].lock,
-					       flags);
-			goto again;
-		}
-
-		dest = get_target_cpu(gsi, vector);
-		err = register_intr(gsi, vector, IOSAPIC_LOWEST_PRIORITY,
-			      polarity, trigger);
-		if (err < 0) {
-			spin_unlock(&iosapic_lock);
-			spin_unlock_irqrestore(&irq_desc[vector].lock,
-					       flags);
-			return err;
-		}
+	if (gsi_to_vector(gsi) > 0) {
+		if (list_empty(&iosapic_intr_info[vector].rtes))
+			free_irq_vector(vector);
+		spin_unlock(&iosapic_lock);
+		spin_unlock_irqrestore(&irq_desc[vector].lock, flags);
+		goto again;
+	}

-		/*
-		 * If the vector is shared and already unmasked for
-		 * other interrupt sources, don't mask it.
-		 */
-		low32 = iosapic_intr_info[vector].low32;
-		if (vector_is_shared(vector) && !(low32 & IOSAPIC_MASK))
-			mask = 0;
-		set_rte(gsi, vector, dest, mask);
+	dest = get_target_cpu(gsi, vector);
+	err = register_intr(gsi, vector, IOSAPIC_LOWEST_PRIORITY,
+			    polarity, trigger);
+	if (err < 0) {
+		spin_unlock(&iosapic_lock);
+		spin_unlock_irqrestore(&irq_desc[vector].lock, flags);
+		return err;
 	}
+
+	/*
+	 * If the vector is shared and already unmasked for other
+	 * interrupt sources, don't mask it.
+	 */
+	low32 = iosapic_intr_info[vector].low32;
+	if (vector_is_shared(vector) && !(low32 & IOSAPIC_MASK))
+		mask = 0;
+	set_rte(gsi, vector, dest, mask);
 	spin_unlock(&iosapic_lock);
 	spin_unlock_irqrestore(&irq_desc[vector].lock, flags);

@@ -886,69 +865,64 @@ iosapic_unregister_intr (unsigned int gs
 	idesc = irq_desc + irq;
 	spin_lock_irqsave(&idesc->lock, flags);
 	spin_lock(&iosapic_lock);
-	{
-		if ((rte = gsi_vector_to_rte(gsi, vector)) = NULL) {
-			printk(KERN_ERR
-			       "iosapic_unregister_intr(%u) unbalanced\n",
-			       gsi);
-			WARN_ON(1);
-			goto out;
-		}
+	if ((rte = gsi_vector_to_rte(gsi, vector)) = NULL) {
+		printk(KERN_ERR "iosapic_unregister_intr(%u) unbalanced\n",
+		       gsi);
+		WARN_ON(1);
+		goto out;
+	}

-		if (--rte->refcnt > 0)
-			goto out;
+	if (--rte->refcnt > 0)
+		goto out;

-		/* Mask the interrupt */
-		low32 = iosapic_intr_info[vector].low32 | IOSAPIC_MASK;
-		iosapic_write(rte->addr, IOSAPIC_RTE_LOW(rte->rte_index),
-			      low32);
+	/* Mask the interrupt */
+	low32 = iosapic_intr_info[vector].low32 | IOSAPIC_MASK;
+	iosapic_write(rte->addr, IOSAPIC_RTE_LOW(rte->rte_index), low32);

-		/* Remove the rte entry from the list */
-		list_del(&rte->rte_list);
-		iosapic_intr_info[vector].count--;
-		iosapic_free_rte(rte);
-		index = find_iosapic(gsi);
-		iosapic_lists[index].rtes_inuse--;
-		WARN_ON(iosapic_lists[index].rtes_inuse < 0);
-
-		trigger	 = iosapic_intr_info[vector].trigger;
-		polarity = iosapic_intr_info[vector].polarity;
-		dest     = iosapic_intr_info[vector].dest;
-		printk(KERN_INFO
-		       "GSI %u (%s, %s) -> CPU %d (0x%04x)"
-		       " vector %d unregistered\n",
-		       gsi, (trigger = IOSAPIC_EDGE ? "edge" : "level"),
-		       (polarity = IOSAPIC_POL_HIGH ? "high" : "low"),
-		       cpu_logical_id(dest), dest, vector);
-
-		if (list_empty(&iosapic_intr_info[vector].rtes)) {
-			/* Sanity check */
-			BUG_ON(iosapic_intr_info[vector].count);
+	/* Remove the rte entry from the list */
+	list_del(&rte->rte_list);
+	iosapic_intr_info[vector].count--;
+	iosapic_free_rte(rte);
+	index = find_iosapic(gsi);
+	iosapic_lists[index].rtes_inuse--;
+	WARN_ON(iosapic_lists[index].rtes_inuse < 0);

-			/* Clear the interrupt controller descriptor */
-			idesc->chip = &no_irq_type;
+	trigger	 = iosapic_intr_info[vector].trigger;
+	polarity = iosapic_intr_info[vector].polarity;
+	dest     = iosapic_intr_info[vector].dest;
+	printk(KERN_INFO
+	       "GSI %u (%s, %s) -> CPU %d (0x%04x) vector %d unregistered\n",
+	       gsi, (trigger = IOSAPIC_EDGE ? "edge" : "level"),
+	       (polarity = IOSAPIC_POL_HIGH ? "high" : "low"),
+	       cpu_logical_id(dest), dest, vector);
+
+	if (list_empty(&iosapic_intr_info[vector].rtes)) {
+		/* Sanity check */
+		BUG_ON(iosapic_intr_info[vector].count);
+
+		/* Clear the interrupt controller descriptor */
+		idesc->chip = &no_irq_type;

 #ifdef CONFIG_SMP
-			/* Clear affinity */
-			cpus_setall(idesc->affinity);
+		/* Clear affinity */
+		cpus_setall(idesc->affinity);
 #endif

-			/* Clear the interrupt information */
-			memset(&iosapic_intr_info[vector], 0,
-			       sizeof(struct iosapic_intr_info));
-			iosapic_intr_info[vector].low32 |= IOSAPIC_MASK;
-			INIT_LIST_HEAD(&iosapic_intr_info[vector].rtes);
-
-			if (idesc->action) {
-				printk(KERN_ERR
-				       "interrupt handlers still exist on"
-				       "IRQ %u\n", irq);
-				WARN_ON(1);
-			}
+		/* Clear the interrupt information */
+		memset(&iosapic_intr_info[vector], 0,
+		       sizeof(struct iosapic_intr_info));
+		iosapic_intr_info[vector].low32 |= IOSAPIC_MASK;
+		INIT_LIST_HEAD(&iosapic_intr_info[vector].rtes);

-			/* Free the interrupt vector */
-			free_irq_vector(vector);
+		if (idesc->action) {
+			printk(KERN_ERR
+			       "interrupt handlers still exist on IRQ %u\n",
+			       irq);
+			WARN_ON(1);
 		}
+
+		/* Free the interrupt vector */
+		free_irq_vector(vector);
 	}
  out:
 	spin_unlock(&iosapic_lock);
@@ -1108,31 +1082,29 @@ iosapic_init (unsigned long phys_addr, u
 	unsigned long flags;

 	spin_lock_irqsave(&iosapic_lock, flags);
-	{
-		addr = ioremap(phys_addr, 0);
-		ver = iosapic_version(addr);
-
-		if ((err = iosapic_check_gsi_range(gsi_base, ver))) {
-			iounmap(addr);
-			spin_unlock_irqrestore(&iosapic_lock, flags);
-			return err;
-		}
+	addr = ioremap(phys_addr, 0);
+	ver = iosapic_version(addr);

-		/*
-		 * The MAX_REDIR register holds the highest input pin
-		 * number (starting from 0).
-		 * We add 1 so that we can use it for number of pins (= RTEs)
-		 */
-		num_rte = ((ver >> 16) & 0xff) + 1;
+	if ((err = iosapic_check_gsi_range(gsi_base, ver))) {
+		iounmap(addr);
+		spin_unlock_irqrestore(&iosapic_lock, flags);
+		return err;
+	}

-		index = iosapic_alloc();
-		iosapic_lists[index].addr = addr;
-		iosapic_lists[index].gsi_base = gsi_base;
-		iosapic_lists[index].num_rte = num_rte;
+	/*
+	 * The MAX_REDIR register holds the highest input pin number
+	 * (starting from 0).  We add 1 so that we can use it for
+	 * number of pins (= RTEs)
+	 */
+	num_rte = ((ver >> 16) & 0xff) + 1;
+
+	index = iosapic_alloc();
+	iosapic_lists[index].addr = addr;
+	iosapic_lists[index].gsi_base = gsi_base;
+	iosapic_lists[index].num_rte = num_rte;
 #ifdef CONFIG_NUMA
-		iosapic_lists[index].node = MAX_NUMNODES;
+	iosapic_lists[index].node = MAX_NUMNODES;
 #endif
-	}
 	spin_unlock_irqrestore(&iosapic_lock, flags);

 	if ((gsi_base = 0) && pcat_compat) {
@@ -1157,25 +1129,22 @@ iosapic_remove (unsigned int gsi_base)
 	unsigned long flags;

 	spin_lock_irqsave(&iosapic_lock, flags);
-	{
-		index = find_iosapic(gsi_base);
-		if (index < 0) {
-			printk(KERN_WARNING "%s: No IOSAPIC for GSI base %u\n",
-			       __FUNCTION__, gsi_base);
-			goto out;
-		}
-
-		if (iosapic_lists[index].rtes_inuse) {
-			err = -EBUSY;
-			printk(KERN_WARNING
-			       "%s: IOSAPIC for GSI base %u is busy\n",
-			       __FUNCTION__, gsi_base);
-			goto out;
-		}
+	index = find_iosapic(gsi_base);
+	if (index < 0) {
+		printk(KERN_WARNING "%s: No IOSAPIC for GSI base %u\n",
+		       __FUNCTION__, gsi_base);
+		goto out;
+	}

-		iounmap(iosapic_lists[index].addr);
-		iosapic_free(index);
+	if (iosapic_lists[index].rtes_inuse) {
+		err = -EBUSY;
+		printk(KERN_WARNING "%s: IOSAPIC for GSI base %u is busy\n",
+		       __FUNCTION__, gsi_base);
+		goto out;
 	}
+
+	iounmap(iosapic_lists[index].addr);
+	iosapic_free(index);
  out:
 	spin_unlock_irqrestore(&iosapic_lock, flags);
 	return err;

