From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Thu, 03 Feb 2005 10:26:02 +0000
Subject: take5: vector sharing (Large I/O system support)
Message-Id: <4201FC3A.40803@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

I have posted the patch for vector sharing (large I/O system
support) several months ago, and I would like to try again.
The following is updated patch against 2.6.11-rc3.

Tony, could you consider applying this patch onto your test
tree? I hope this patch will be tested by many people.

Thanks,
Kenji Kaneshige


Current ia64 linux cannot handle greater than 184 interrupt sources
because of the lack of vectors. The following patch enables ia64 linux
to handle greater than 184 interrupt sources by allowing the same
vector number to be shared by multiple IOSAPIC's RTEs. The design of
this patch is besed on "Intel(R) Itanium(R) Processor Family Interrupt
Architecture Guide".

Even if you don't have a large I/O system, you can see the behavior of
vector sharing by changing IOSAPIC_LAST_DEVICE_VECTOR to fewer value.

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>


---

 linux-2.6.11-rc3-kanesige/arch/ia64/kernel/iosapic.c  |  340 +++++++++++++-----
 linux-2.6.11-rc3-kanesige/arch/ia64/kernel/irq_ia64.c |   16 
 linux-2.6.11-rc3-kanesige/include/asm-ia64/hw_irq.h   |    1 
 linux-2.6.11-rc3-kanesige/include/asm-ia64/iosapic.h  |    1 
 4 files changed, 265 insertions(+), 93 deletions(-)

diff -puN arch/ia64/kernel/iosapic.c~vector_sharing arch/ia64/kernel/iosapic.c
--- linux-2.6.11-rc3/arch/ia64/kernel/iosapic.c~vector_sharing	2005-02-03 13:15:19.000000000 +0900
+++ linux-2.6.11-rc3-kanesige/arch/ia64/kernel/iosapic.c	2005-02-03 13:15:19.000000000 +0900
@@ -103,15 +103,23 @@ static DEFINE_SPINLOCK(iosapic_lock);
 
 /* These tables map IA-64 vectors to the IOSAPIC pin that generates this vector. */
 
-static struct iosapic_intr_info {
+static struct iosapic_rte_info {
+	struct list_head rte_list;	/* node in list of RTEs sharing the same vector */
 	char __iomem	*addr;		/* base address of IOSAPIC */
-	u32		low32;		/* current value of low word of Redirection table entry */
 	unsigned int	gsi_base;	/* first GSI assigned to this IOSAPIC */
-	char		rte_index;	/* IOSAPIC RTE index (-1 => not an IOSAPIC interrupt) */
+	char		rte_index;	/* IOSAPIC RTE index */
+	int		refcnt;		/* reference counter */
+} iosapic_rte_cache[NR_RTE_CACHE_ENTRIES];
+	
+static struct iosapic_intr_info {
+	struct list_head rtes;		/* RTEs using this vector (empty => not an IOSAPIC interrupt) */
+	int		count;		/* # of RTEs that shares this vector */
+	u32		low32;		/* current value of low word of Redirection table entry */
+	unsigned int	dest;		/* destination CPU physical ID */
 	unsigned char	dmode	: 3;	/* delivery mode (see iosapic.h) */
 	unsigned char 	polarity: 1;	/* interrupt polarity (see iosapic.h) */
 	unsigned char	trigger	: 1;	/* trigger mode (see iosapic.h) */
-	int		refcnt;		/* reference counter */
+	unsigned char	sharable: 1;	/* sharable flag (0: exclusive, 1: sharable) */
 } iosapic_intr_info[IA64_NUM_VECTORS];
 
 static struct iosapic {
@@ -148,10 +156,12 @@ static inline int
 _gsi_to_vector (unsigned int gsi)
 {
 	struct iosapic_intr_info *info;
+	struct iosapic_rte_info *rte;
 
 	for (info = iosapic_intr_info; info < iosapic_intr_info + IA64_NUM_VECTORS; ++info)
-		if (info->gsi_base + info->rte_index = gsi)
-			return info - iosapic_intr_info;
+		list_for_each_entry(rte, &info->rtes, rte_list)
+			if (rte->gsi_base + rte->rte_index = gsi)
+				return info - iosapic_intr_info;
 	return -1;
 }
 
@@ -168,33 +178,52 @@ gsi_to_vector (unsigned int gsi)
 int
 gsi_to_irq (unsigned int gsi)
 {
+	unsigned long flags;
+	int irq;
 	/*
 	 * XXX fix me: this assumes an identity mapping vetween IA-64 vector and Linux irq
 	 * numbers...
 	 */
-	return _gsi_to_vector(gsi);
+	spin_lock_irqsave(&iosapic_lock, flags);
+	{
+		irq = _gsi_to_vector(gsi);
+	}
+	spin_unlock_irqrestore(&iosapic_lock, flags);
+
+	return irq;
+}
+
+static struct iosapic_rte_info *gsi_vector_to_rte(unsigned int gsi, unsigned int vec)
+{
+	struct iosapic_rte_info *rte;
+
+	list_for_each_entry(rte, &iosapic_intr_info[vec].rtes, rte_list)
+		if (rte->gsi_base + rte->rte_index = gsi)
+			return rte;
+	return NULL;
 }
 
 static void
-set_rte (unsigned int vector, unsigned int dest, int mask)
+set_rte (unsigned int gsi, unsigned int vector, unsigned int dest, int mask)
 {
 	unsigned long pol, trigger, dmode;
 	u32 low32, high32;
 	char __iomem *addr;
 	int rte_index;
 	char redir;
+	struct iosapic_rte_info *rte;
 
 	DBG(KERN_DEBUG"IOSAPIC: routing vector %d to 0x%x\n", vector, dest);
 
-	rte_index = iosapic_intr_info[vector].rte_index;
-	if (rte_index < 0)
+	if (list_empty(&iosapic_intr_info[vector].rtes))
 		return;		/* not an IOSAPIC interrupt */
 
-	addr    = iosapic_intr_info[vector].addr;
+	rte 	= gsi_vector_to_rte(gsi, vector);
+	rte_index = rte->rte_index;
+	addr	= rte->addr;
 	pol     = iosapic_intr_info[vector].polarity;
 	trigger = iosapic_intr_info[vector].trigger;
 	dmode   = iosapic_intr_info[vector].dmode;
-	vector &= (~IA64_IRQ_REDIRECTED);
 
 	redir = (dmode = IOSAPIC_LOWEST_PRIORITY) ? 1 : 0;
 
@@ -222,6 +251,7 @@ set_rte (unsigned int vector, unsigned i
 	iosapic_write(addr, IOSAPIC_RTE_HIGH(rte_index), high32);
 	iosapic_write(addr, IOSAPIC_RTE_LOW(rte_index), low32);
 	iosapic_intr_info[vector].low32 = low32;
+	iosapic_intr_info[vector].dest = dest;
 }
 
 static void
@@ -238,18 +268,20 @@ mask_irq (unsigned int irq)
 	u32 low32;
 	int rte_index;
 	ia64_vector vec = irq_to_vector(irq);
+	struct iosapic_rte_info *rte;
 
-	addr = iosapic_intr_info[vec].addr;
-	rte_index = iosapic_intr_info[vec].rte_index;
-
-	if (rte_index < 0)
+	if (list_empty(&iosapic_intr_info[vec].rtes))
 		return;			/* not an IOSAPIC interrupt! */
 
 	spin_lock_irqsave(&iosapic_lock, flags);
 	{
 		/* set only the mask bit */
 		low32 = iosapic_intr_info[vec].low32 |= IOSAPIC_MASK;
-		iosapic_write(addr, IOSAPIC_RTE_LOW(rte_index), low32);
+		list_for_each_entry(rte, &iosapic_intr_info[vec].rtes, rte_list) {
+			addr = rte->addr;
+			rte_index = rte->rte_index;
+			iosapic_write(addr, IOSAPIC_RTE_LOW(rte_index), low32);
+		}
 	}
 	spin_unlock_irqrestore(&iosapic_lock, flags);
 }
@@ -262,16 +294,19 @@ unmask_irq (unsigned int irq)
 	u32 low32;
 	int rte_index;
 	ia64_vector vec = irq_to_vector(irq);
+	struct iosapic_rte_info *rte;
 
-	addr = iosapic_intr_info[vec].addr;
-	rte_index = iosapic_intr_info[vec].rte_index;
-	if (rte_index < 0)
+	if (list_empty(&iosapic_intr_info[vec].rtes))
 		return;			/* not an IOSAPIC interrupt! */
 
 	spin_lock_irqsave(&iosapic_lock, flags);
 	{
 		low32 = iosapic_intr_info[vec].low32 &= ~IOSAPIC_MASK;
-		iosapic_write(addr, IOSAPIC_RTE_LOW(rte_index), low32);
+		list_for_each_entry(rte, &iosapic_intr_info[vec].rtes, rte_list) {
+			addr = rte->addr;
+			rte_index = rte->rte_index;
+			iosapic_write(addr, IOSAPIC_RTE_LOW(rte_index), low32);
+		}
 	}
 	spin_unlock_irqrestore(&iosapic_lock, flags);
 }
@@ -287,6 +322,7 @@ iosapic_set_affinity (unsigned int irq, 
 	char __iomem *addr;
 	int redir = (irq & IA64_IRQ_REDIRECTED) ? 1 : 0;
 	ia64_vector vec;
+	struct iosapic_rte_info *rte;
 
 	irq &= (~IA64_IRQ_REDIRECTED);
 	vec = irq_to_vector(irq);
@@ -296,10 +332,7 @@ iosapic_set_affinity (unsigned int irq, 
 
 	dest = cpu_physical_id(first_cpu(mask));
 
-	rte_index = iosapic_intr_info[vec].rte_index;
-	addr = iosapic_intr_info[vec].addr;
-
-	if (rte_index < 0)
+	if (list_empty(&iosapic_intr_info[vec].rtes))
 		return;			/* not an IOSAPIC interrupt */
 
 	set_irq_affinity_info(irq, dest, redir);
@@ -319,8 +352,13 @@ iosapic_set_affinity (unsigned int irq, 
 			low32 |= (IOSAPIC_FIXED << IOSAPIC_DELIVERY_SHIFT);
 
 		iosapic_intr_info[vec].low32 = low32;
-		iosapic_write(addr, IOSAPIC_RTE_HIGH(rte_index), high32);
-		iosapic_write(addr, IOSAPIC_RTE_LOW(rte_index), low32);
+		iosapic_intr_info[vec].dest = dest;
+		list_for_each_entry(rte, &iosapic_intr_info[vec].rtes, rte_list) {
+			addr = rte->addr;
+			rte_index = rte->rte_index;
+			iosapic_write(addr, IOSAPIC_RTE_HIGH(rte_index), high32);
+			iosapic_write(addr, IOSAPIC_RTE_LOW(rte_index), low32);
+		}
 	}
 	spin_unlock_irqrestore(&iosapic_lock, flags);
 #endif
@@ -341,9 +379,11 @@ static void
 iosapic_end_level_irq (unsigned int irq)
 {
 	ia64_vector vec = irq_to_vector(irq);
+	struct iosapic_rte_info *rte;
 
 	move_irq(irq);
-	iosapic_eoi(iosapic_intr_info[vec].addr, vec);
+	list_for_each_entry(rte, &iosapic_intr_info[vec].rtes, rte_list)
+		iosapic_eoi(rte->addr, vec);
 }
 
 #define iosapic_shutdown_level_irq	mask_irq
@@ -423,6 +463,26 @@ iosapic_version (char __iomem *addr)
 	return iosapic_read(addr, IOSAPIC_VERSION);
 }
 
+static int iosapic_find_sharable_vector (unsigned long trigger, unsigned long pol)
+{
+	int i, vector = -1, min_count = -1;
+	struct iosapic_intr_info *info;
+
+	for (i = IA64_FIRST_DEVICE_VECTOR; i <= IA64_LAST_DEVICE_VECTOR; i++) {
+		info = &iosapic_intr_info[i];
+		if (info->sharable && info->trigger = trigger && info->polarity = pol) {
+			if (min_count = -1 || info->count < min_count) {
+				vector = i;
+				min_count = info->count;
+			}
+		}
+	}
+	if (vector < 0)
+		panic("%s: out of interrupt vectors!\n", __FUNCTION__);
+
+	return vector;
+}
+			
 /*
  * if the given vector is already owned by other,
  *  assign a new vector for the other and make the vector available
@@ -432,22 +492,61 @@ iosapic_reassign_vector (int vector)
 {
 	int new_vector;
 
-	if (iosapic_intr_info[vector].rte_index >= 0 || iosapic_intr_info[vector].addr
-	    || iosapic_intr_info[vector].gsi_base || iosapic_intr_info[vector].dmode
-	    || iosapic_intr_info[vector].polarity || iosapic_intr_info[vector].trigger)
-	{
+	if (!list_empty(&iosapic_intr_info[vector].rtes)) {
 		new_vector = assign_irq_vector(AUTO_ASSIGN);
 		printk(KERN_INFO "Reassigning vector %d to %d\n", vector, new_vector);
 		memcpy(&iosapic_intr_info[new_vector], &iosapic_intr_info[vector],
 		       sizeof(struct iosapic_intr_info));
+		INIT_LIST_HEAD(&iosapic_intr_info[new_vector].rtes);
+		list_move(iosapic_intr_info[vector].rtes.next, &iosapic_intr_info[new_vector].rtes);
 		memset(&iosapic_intr_info[vector], 0, sizeof(struct iosapic_intr_info));
-		iosapic_intr_info[vector].rte_index = -1;
+		iosapic_intr_info[vector].low32 = IOSAPIC_MASK;
+		INIT_LIST_HEAD(&iosapic_intr_info[vector].rtes);
+	}
+}
+
+unsigned long iosapic_rte_cache_mask[BITS_TO_LONGS(NR_RTE_CACHE_ENTRIES)];
+
+static struct iosapic_rte_info *iosapic_alloc_rte (void)
+{
+	int index;
+again:
+	/*
+	 * iosapic_alloc_rte might be called before kmalloc is initialized,
+	 * so several number of iosapic_rte_info structures needs to be
+	 * statically allocated.
+	 */
+	index = find_first_zero_bit(iosapic_rte_cache_mask, NR_RTE_CACHE_ENTRIES);
+	if (index < NR_RTE_CACHE_ENTRIES) {
+		if (test_and_set_bit(index, iosapic_rte_cache_mask))
+			goto again;
+		return iosapic_rte_cache + index;
+	}
+
+	return kmalloc(sizeof(struct iosapic_rte_info), GFP_ATOMIC);
+}
+
+static void iosapic_free_rte (struct iosapic_rte_info *rte)
+{
+	unsigned long index = rte - iosapic_rte_cache;
+
+	if (index < NR_RTE_CACHE_ENTRIES) {
+		if (!test_and_clear_bit(index, iosapic_rte_cache_mask))
+			printk(KERN_WARNING "%s: double free!\n", __FUNCTION__);
+		return;
 	}
+
+	kfree(rte);
+}
+
+static inline int vector_is_shared (int vector)
+{
+	return (iosapic_intr_info[vector].count > 1);
 }
 
 static void
 register_intr (unsigned int gsi, int vector, unsigned char delivery,
-	       unsigned long polarity, unsigned long trigger)
+	       unsigned long polarity, unsigned long trigger, unsigned long sharable)
 {
 	irq_desc_t *idesc;
 	struct hw_interrupt_type *irq_type;
@@ -455,6 +554,7 @@ register_intr (unsigned int gsi, int vec
 	int index;
 	unsigned long gsi_base;
 	void __iomem *iosapic_address;
+	struct iosapic_rte_info *rte;
 
 	index = find_iosapic(gsi);
 	if (index < 0) {
@@ -465,14 +565,33 @@ register_intr (unsigned int gsi, int vec
 	iosapic_address = iosapic_lists[index].addr;
 	gsi_base = iosapic_lists[index].gsi_base;
 
-	rte_index = gsi - gsi_base;
-	iosapic_intr_info[vector].rte_index = rte_index;
+	if ((rte = gsi_vector_to_rte(gsi, vector)) = NULL) {
+		if ((rte = iosapic_alloc_rte()) = NULL) {
+			printk(KERN_WARNING "%s: cannot allocate memory\n", __FUNCTION__);
+			return;
+		}
+
+		memset(rte, 0, sizeof(struct iosapic_rte_info));
+		rte_index = gsi - gsi_base;
+		rte->rte_index	= rte_index;
+		rte->addr	= iosapic_address;
+		rte->gsi_base	= gsi_base;
+		rte->refcnt++;		 
+		list_add_tail(&rte->rte_list, &iosapic_intr_info[vector].rtes);
+		iosapic_intr_info[vector].count++;
+	}
+	else if (vector_is_shared(vector)) {
+		if (!sharable || (iosapic_intr_info[vector].trigger != trigger)
+			      || (iosapic_intr_info[vector].polarity != polarity)) {
+			printk (KERN_WARNING "%s: cannot override the interrupt\n", __FUNCTION__);
+			return;
+		}
+	}
+		
 	iosapic_intr_info[vector].polarity = polarity;
 	iosapic_intr_info[vector].dmode    = delivery;
-	iosapic_intr_info[vector].addr     = iosapic_address;
-	iosapic_intr_info[vector].gsi_base = gsi_base;
 	iosapic_intr_info[vector].trigger  = trigger;
-	iosapic_intr_info[vector].refcnt++;
+	iosapic_intr_info[vector].sharable = sharable;
 
 	if (trigger = IOSAPIC_EDGE)
 		irq_type = &irq_type_iosapic_edge;
@@ -495,6 +614,13 @@ get_target_cpu (unsigned int gsi, int ve
 	static int cpu = -1;
 
 	/*
+	 * In case of vector shared by multiple RTEs, all RTEs that
+	 * share the vector need to use the same destination CPU.
+	 */
+	if (!list_empty(&iosapic_intr_info[vector].rtes))
+		return iosapic_intr_info[vector].dest;
+
+	/*
 	 * If the platform supports redirection via XTP, let it
 	 * distribute interrupts.
 	 */
@@ -566,10 +692,12 @@ int
 iosapic_register_intr (unsigned int gsi,
 		       unsigned long polarity, unsigned long trigger)
 {
-	int vector;
+	int vector, mask = 1;
 	unsigned int dest;
 	unsigned long flags;
-
+	struct iosapic_rte_info *rte;
+	u32 low32;
+again:
 	/*
 	 * If this GSI has already been registered (i.e., it's a
 	 * shared interrupt, or we lost a race to register it),
@@ -579,19 +707,45 @@ iosapic_register_intr (unsigned int gsi,
 	{
 		vector = gsi_to_vector(gsi);
 		if (vector > 0) {
-			iosapic_intr_info[vector].refcnt++;
+			rte = gsi_vector_to_rte(gsi, vector);
+			rte->refcnt++;
 			spin_unlock_irqrestore(&iosapic_lock, flags);
 			return vector;
 		}
+	}
+	spin_unlock_irqrestore(&iosapic_lock, flags);
+
+	/* If vector is running out, we try to find a sharable vector */
+	vector = assign_irq_vector_nopanic(AUTO_ASSIGN);
+	if (vector < 0)
+		vector = iosapic_find_sharable_vector(trigger, polarity);
+
+	spin_lock_irqsave(&irq_descp(vector)->lock, flags);
+	spin_lock(&iosapic_lock);
+	{
+		if (gsi_to_vector(gsi) > 0) {
+			if (list_empty(&iosapic_intr_info[vector].rtes))
+				free_irq_vector(vector);
+			spin_unlock(&iosapic_lock);
+			spin_unlock_irqrestore(&irq_descp(vector)->lock, flags);
+			goto again;
+		}
 
-		vector = assign_irq_vector(AUTO_ASSIGN);
 		dest = get_target_cpu(gsi, vector);
 		register_intr(gsi, vector, IOSAPIC_LOWEST_PRIORITY,
-			polarity, trigger);
+			polarity, trigger, trigger = IOSAPIC_EDGE ? 0 : 1);
 
-		set_rte(vector, dest, 1);
+		/*
+		 * If the vector is shared and already unmasked for
+		 * other interrupt sources, don't mask it.
+		 */
+		low32 = iosapic_intr_info[vector].low32;
+		if (vector_is_shared(vector) && !(low32 & IOSAPIC_MASK))
+			mask = 0;
+		set_rte(gsi, vector, dest, mask);
 	}
-	spin_unlock_irqrestore(&iosapic_lock, flags);
+	spin_unlock_irq(&iosapic_lock);
+	spin_unlock_irqrestore(&irq_descp(vector)->lock, flags);
 
 	printk(KERN_INFO "GSI %u (%s, %s) -> CPU %d (0x%04x) vector %d\n",
 	       gsi, (trigger = IOSAPIC_EDGE ? "edge" : "level"),
@@ -608,8 +762,10 @@ iosapic_unregister_intr (unsigned int gs
 	unsigned long flags;
 	int irq, vector;
 	irq_desc_t *idesc;
-	int rte_index;
+	u32 low32;
 	unsigned long trigger, polarity;
+	unsigned int dest;
+	struct iosapic_rte_info *rte;
 
 	/*
 	 * If the irq associated with the gsi is not found,
@@ -628,54 +784,56 @@ iosapic_unregister_intr (unsigned int gs
 	spin_lock_irqsave(&idesc->lock, flags);
 	spin_lock(&iosapic_lock);
 	{
-		rte_index = iosapic_intr_info[vector].rte_index;
-		if (rte_index < 0) {
-			spin_unlock(&iosapic_lock);
-			spin_unlock_irqrestore(&idesc->lock, flags);
+		if ((rte = gsi_vector_to_rte(gsi, vector)) = NULL) {
 			printk(KERN_ERR "iosapic_unregister_intr(%u) unbalanced\n", gsi);
 			WARN_ON(1);
-			return;
-		}
-
-		if (--iosapic_intr_info[vector].refcnt > 0) {
-			spin_unlock(&iosapic_lock);
-			spin_unlock_irqrestore(&idesc->lock, flags);
-			return;
+			goto out;
 		}
 
-		/*
-		 * If interrupt handlers still exist on the irq
-		 * associated with the gsi, don't unregister the
-		 * interrupt.
-		 */
-		if (idesc->action) {
-			iosapic_intr_info[vector].refcnt++;
-			spin_unlock(&iosapic_lock);
-			spin_unlock_irqrestore(&idesc->lock, flags);
-			printk(KERN_WARNING "Cannot unregister GSI. IRQ %u is still in use.\n", irq);
-			return;
-		}
+		if (--rte->refcnt > 0)
+			goto out;
 
-		/* Clear the interrupt controller descriptor. */
-		idesc->handler = &no_irq_type;
+		/* Mask the interrupt */
+		low32 = iosapic_intr_info[vector].low32 | IOSAPIC_MASK;
+		iosapic_write(rte->addr, IOSAPIC_RTE_LOW(rte->rte_index), low32);
+
+		/* Remove the rte entry from the list */
+		list_del(&rte->rte_list);
+		iosapic_intr_info[vector].count--;
+		iosapic_free_rte(rte);
 
-		trigger  = iosapic_intr_info[vector].trigger;
+		trigger	 = iosapic_intr_info[vector].trigger;
 		polarity = iosapic_intr_info[vector].polarity;
+		dest     = iosapic_intr_info[vector].dest;
+		printk(KERN_INFO "GSI %u (%s, %s) -> CPU %d (0x%04x) vector %d unregistered\n",
+		       gsi, (trigger = IOSAPIC_EDGE ? "edge" : "level"),
+		       (polarity = IOSAPIC_POL_HIGH ? "high" : "low"),
+		       cpu_logical_id(dest), dest, vector);
+
+		if (list_empty(&iosapic_intr_info[vector].rtes)) {
+			/* Sanity check */
+			BUG_ON(iosapic_intr_info[vector].count);
+
+			/* Clear the interrupt controller descriptor */
+			idesc->handler = &no_irq_type;
+
+			/* Clear the interrupt information */
+			memset(&iosapic_intr_info[vector], 0, sizeof(struct iosapic_intr_info));
+			iosapic_intr_info[vector].low32 |= IOSAPIC_MASK;
+			INIT_LIST_HEAD(&iosapic_intr_info[vector].rtes);
+
+			if (idesc->action) {
+				printk(KERN_ERR "interrupt handlers still exist on IRQ %u\n", irq);
+				WARN_ON(1);
+			}
 
-		/* Clear the interrupt information. */
-		memset(&iosapic_intr_info[vector], 0, sizeof(struct iosapic_intr_info));
-		iosapic_intr_info[vector].rte_index = -1;	/* mark as unused */
+			/* Free the interrupt vector */
+			free_irq_vector(vector);
+		}
 	}
+ out:
 	spin_unlock(&iosapic_lock);
 	spin_unlock_irqrestore(&idesc->lock, flags);
-
-	/* Free the interrupt vector */
-	free_irq_vector(vector);
-
-	printk(KERN_INFO "GSI %u (%s, %s) -> vector %d unregisterd.\n",
-	       gsi, (trigger = IOSAPIC_EDGE ? "edge" : "level"),
-	       (polarity = IOSAPIC_POL_HIGH ? "high" : "low"),
-	       vector);
 }
 #endif /* CONFIG_ACPI_DEALLOCATE_IRQ */
 
@@ -717,7 +875,7 @@ iosapic_register_platform_intr (u32 int_
 		return -1;
 	}
 
-	register_intr(gsi, vector, delivery, polarity, trigger);
+	register_intr(gsi, vector, delivery, polarity, trigger, 0);
 
 	printk(KERN_INFO "PLATFORM int %s (0x%x): GSI %u (%s, %s) -> CPU %d (0x%04x) vector %d\n",
 	       int_type < ARRAY_SIZE(name) ? name[int_type] : "unknown",
@@ -725,7 +883,7 @@ iosapic_register_platform_intr (u32 int_
 	       (polarity = IOSAPIC_POL_HIGH ? "high" : "low"),
 	       cpu_logical_id(dest), dest, vector);
 
-	set_rte(vector, dest, mask);
+	set_rte(gsi, vector, dest, mask);
 	return vector;
 }
 
@@ -744,14 +902,14 @@ iosapic_override_isa_irq (unsigned int i
 
 	vector = isa_irq_to_vector(isa_irq);
 
-	register_intr(gsi, vector, IOSAPIC_LOWEST_PRIORITY, polarity, trigger);
+	register_intr(gsi, vector, IOSAPIC_LOWEST_PRIORITY, polarity, trigger, 0);
 
 	DBG("ISA: IRQ %u -> GSI %u (%s,%s) -> CPU %d (0x%04x) vector %d\n",
 	    isa_irq, gsi, trigger = IOSAPIC_EDGE ? "edge" : "level",
 	    polarity = IOSAPIC_POL_HIGH ? "high" : "low",
 	    cpu_logical_id(dest), dest, vector);
 
-	set_rte(vector, dest, 1);
+	set_rte(gsi, vector, dest, 1);
 }
 
 void __init
@@ -759,8 +917,10 @@ iosapic_system_init (int system_pcat_com
 {
 	int vector;
 
-	for (vector = 0; vector < IA64_NUM_VECTORS; ++vector)
-		iosapic_intr_info[vector].rte_index = -1;	/* mark as unused */
+	for (vector = 0; vector < IA64_NUM_VECTORS; ++vector) {
+		iosapic_intr_info[vector].low32 = IOSAPIC_MASK;
+		INIT_LIST_HEAD(&iosapic_intr_info[vector].rtes);	/* mark as unused */
+	}
 
 	pcat_compat = system_pcat_compat;
 	if (pcat_compat) {
diff -puN arch/ia64/kernel/irq_ia64.c~vector_sharing arch/ia64/kernel/irq_ia64.c
--- linux-2.6.11-rc3/arch/ia64/kernel/irq_ia64.c~vector_sharing	2005-02-03 13:15:19.000000000 +0900
+++ linux-2.6.11-rc3-kanesige/arch/ia64/kernel/irq_ia64.c	2005-02-03 13:15:19.000000000 +0900
@@ -63,20 +63,30 @@ EXPORT_SYMBOL(isa_irq_to_vector_map);
 static unsigned long ia64_vector_mask[BITS_TO_LONGS(IA64_NUM_DEVICE_VECTORS)];
 
 int
-assign_irq_vector (int irq)
+assign_irq_vector_nopanic (int irq)
 {
 	int pos, vector;
  again:
 	pos = find_first_zero_bit(ia64_vector_mask, IA64_NUM_DEVICE_VECTORS);
 	vector = IA64_FIRST_DEVICE_VECTOR + pos;
 	if (vector > IA64_LAST_DEVICE_VECTOR)
-		/* XXX could look for sharable vectors instead of panic'ing... */
-		panic("assign_irq_vector: out of interrupt vectors!");
+		return -1;
 	if (test_and_set_bit(pos, ia64_vector_mask))
 		goto again;
 	return vector;
 }
 
+int
+assign_irq_vector (int irq)
+{
+	int vector = assign_irq_vector_nopanic(irq);
+
+	if (vector < 0)
+		panic("assign_irq_vector: out of interrupt vectors!");
+
+	return vector;
+}
+
 void
 free_irq_vector (int vector)
 {
diff -puN include/asm-ia64/hw_irq.h~vector_sharing include/asm-ia64/hw_irq.h
--- linux-2.6.11-rc3/include/asm-ia64/hw_irq.h~vector_sharing	2005-02-03 13:15:19.000000000 +0900
+++ linux-2.6.11-rc3-kanesige/include/asm-ia64/hw_irq.h	2005-02-03 13:15:19.000000000 +0900
@@ -81,6 +81,7 @@ extern __u8 isa_irq_to_vector_map[16];
 
 extern struct hw_interrupt_type irq_type_ia64_lsapic;	/* CPU-internal interrupt controller */
 
+extern int assign_irq_vector_nopanic (int irq); /* allocate a free vector without panic */
 extern int assign_irq_vector (int irq);	/* allocate a free vector */
 extern void free_irq_vector (int vector);
 extern void ia64_send_ipi (int cpu, int vector, int delivery_mode, int redirect);
diff -puN include/asm-ia64/iosapic.h~vector_sharing include/asm-ia64/iosapic.h
--- linux-2.6.11-rc3/include/asm-ia64/iosapic.h~vector_sharing	2005-02-03 13:15:19.000000000 +0900
+++ linux-2.6.11-rc3-kanesige/include/asm-ia64/iosapic.h	2005-02-03 13:15:19.000000000 +0900
@@ -52,6 +52,7 @@
 #ifdef CONFIG_IOSAPIC
 
 #define NR_IOSAPICS			256
+#define NR_RTE_CACHE_ENTRIES		256
 
 static inline unsigned int iosapic_read(char __iomem *iosapic, unsigned int reg)
 {

_
