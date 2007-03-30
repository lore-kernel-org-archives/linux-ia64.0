From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Fri, 30 Mar 2007 17:01:30 +0000
Subject: Re: [PATCH 4/4] Cleanup lock order in iosapic_register_intr
Message-Id: <460D426A.6000708@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4608A1EB.3000701@jp.fujitsu.com>
In-Reply-To: <4608A1EB.3000701@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

I found a bug in this patch.

>  
>  	/* If vector is running out, we try to find a sharable vector */
>  	vector = assign_irq_vector(AUTO_ASSIGN);
>  	if (vector < 0) {
>  		vector = iosapic_find_sharable_vector(trigger, polarity);
>    		if (vector < 0)
> -			return -ENOSPC;
> +			goto unlock_iosapic_lock;
>  	}
>  
>  	spin_lock_irqsave(&irq_desc[vector].lock, flags);
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
This linue must be
        spin_lock(&irq_desc[vector].lock, flags);

I'm sorry about that. Here is a fixed one.

Thanks,
Kenji Kaneshige


Cleanup order of irq_desc.lock and iosapic_lock in
iosapic_register_intr() and iosapic_unregister_intr().

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>

---
 arch/ia64/kernel/iosapic.c |   50 ++++++++++++++++++---------------------------
 1 files changed, 20 insertions(+), 30 deletions(-)

Index: linux-2.6.21-rc5/arch/ia64/kernel/iosapic.c
=================================--- linux-2.6.21-rc5.orig/arch/ia64/kernel/iosapic.c	2007-03-31 01:17:47.000000000 +0900
+++ linux-2.6.21-rc5/arch/ia64/kernel/iosapic.c	2007-03-31 01:18:33.000000000 +0900
@@ -502,7 +502,7 @@
 static int iosapic_find_sharable_vector (unsigned long trigger,
 					 unsigned long pol)
 {
-	int i, vector = -1, min_count = -1;
+	int i, vector = -ENOSPC, min_count = -1;
 	struct iosapic_intr_info *info;
 
 	/*
@@ -510,7 +510,7 @@
 	 * supported yet
 	 */
 	if (trigger = IOSAPIC_EDGE)
-		return -1;
+		return -ENOSPC;
 
 	for (i = IA64_FIRST_DEVICE_VECTOR; i <= IA64_LAST_DEVICE_VECTOR; i++) {
 		info = &iosapic_intr_info[i];
@@ -759,7 +759,7 @@
 	unsigned long flags;
 	struct iosapic_rte_info *rte;
 	u32 low32;
-again:
+
 	/*
 	 * If this GSI has already been registered (i.e., it's a
 	 * shared interrupt, or we lost a race to register it),
@@ -770,36 +770,24 @@
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
@@ -810,14 +798,15 @@
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
 
@@ -846,9 +835,7 @@
 	}
 	vector = irq_to_vector(irq);
 
-	idesc = irq_desc + irq;
-	spin_lock_irqsave(&idesc->lock, flags);
-	spin_lock(&iosapic_lock);
+	spin_lock_irqsave(&iosapic_lock, flags);
 	if ((rte = gsi_vector_to_rte(gsi, vector)) = NULL) {
 		printk(KERN_ERR "iosapic_unregister_intr(%u) unbalanced\n",
 		       gsi);
@@ -859,12 +846,16 @@
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
@@ -909,8 +900,7 @@
 		free_irq_vector(vector);
 	}
  out:
-	spin_unlock(&iosapic_lock);
-	spin_unlock_irqrestore(&idesc->lock, flags);
+	spin_unlock_irqrestore(&iosapic_lock, flags);
 }
 
 /*

