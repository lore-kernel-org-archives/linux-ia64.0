From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Thu, 15 Jul 2004 01:49:05 +0000
Subject: [PATCH] Vector sharing (Large I/O system support)
Message-Id: <40F5E291.7050803@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

Current ia64 linux cannot handle greater than 184 interrupt
sources because of the lack of vectors. The following patch
enables ia64 linux to handle greater than 184 interrupt sources
by allowing the same vector number to be shared by multiple
IOSAPIC's RTEs.

Even if you don't have a large I/O system, you can see the
behavior of vector sharing by changing
IOSAPIC_LAST_DEVICE_VECTOR to fewer value.

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>


 arch/ia64/kernel/iosapic.c  |  232 ++++++++++++++++++++++++++++++++++----------
 arch/ia64/kernel/irq.c      |    5 
 arch/ia64/kernel/irq_ia64.c |   37 ++++++-
 include/asm-ia64/hw_irq.h   |    3 
 include/asm-ia64/iosapic.h  |    6 +
 include/asm-ia64/irq.h      |    2 
 6 files changed, 230 insertions(+), 55 deletions(-)


diff -Naurp linux-2.6.8-rc1/arch/ia64/kernel/iosapic.c linux-2.6.8-rc1-changed/arch/ia64/kernel/iosapic.c
--- linux-2.6.8-rc1/arch/ia64/kernel/iosapic.c	2004-07-14 15:07:23.811416574 +0900
+++ linux-2.6.8-rc1-changed/arch/ia64/kernel/iosapic.c	2004-07-14 15:08:02.630001886 +0900
@@ -103,15 +103,23 @@ static spinlock_t iosapic_lock = SPIN_LO
 
 /* These tables map IA-64 vectors to the IOSAPIC pin that generates this vector. */
 
-static struct iosapic_intr_info {
+struct iosapic_pin {
+	struct list_head pin_list;	/* IOSAPIC pins which share the same vector */
 	char		*addr;		/* base address of IOSAPIC */
-	u32		low32;		/* current value of low word of Redirection table entry */
 	unsigned int	gsi_base;	/* first GSI assigned to this IOSAPIC */
-	char		rte_index;	/* IOSAPIC RTE index (-1 => not an IOSAPIC interrupt) */
+	char		rte_index;	/* IOSAPIC RTE index */
+};
+
+static struct iosapic_intr_info {
+	struct list_head pin_head;	/* List head of IOSAPIC pins */
+	struct iosapic_pin pin;		/* First entry of IOSAPIC pins list */
+	int		count;		/* # of pins (0 => not an IOSAPIC interrupt) */
+	u32		low32;		/* current value of low word of Redirection table entry */
 	unsigned char	dmode	: 3;	/* delivery mode (see iosapic.h) */
 	unsigned char 	polarity: 1;	/* interrupt polarity (see iosapic.h) */
 	unsigned char	trigger	: 1;	/* trigger mode (see iosapic.h) */
-} iosapic_intr_info[IA64_NUM_VECTORS];
+	unsigned char	type	: 1;	/* Vector type */
+} iosapic_intr_info[IA64_NUM_VECTORS] __cacheline_aligned;
 
 static struct iosapic {
 	char		*addr;		/* base address of IOSAPIC */
@@ -144,10 +152,14 @@ static inline int
 _gsi_to_vector (unsigned int gsi)
 {
 	struct iosapic_intr_info *info;
+	struct iosapic_pin *pin;
 
-	for (info = iosapic_intr_info; info < iosapic_intr_info + IA64_NUM_VECTORS; ++info)
-		if (info->gsi_base + info->rte_index = gsi)
-			return info - iosapic_intr_info;
+	for (info = iosapic_intr_info; info < iosapic_intr_info + IA64_NUM_VECTORS; ++info) {
+		list_for_each_entry(pin, &info->pin_head, pin_list) {
+			if (pin->gsi_base + pin->rte_index = gsi)
+				return info - iosapic_intr_info;
+		}
+	}
 	return -1;
 }
 
@@ -171,22 +183,33 @@ gsi_to_irq (unsigned int gsi)
 	return _gsi_to_vector(gsi);
 }
 
+static inline struct iosapic_pin *
+gsi_vector_to_pin (unsigned int gsi, unsigned int vector)
+{
+	struct iosapic_pin *pin;
+
+	list_for_each_entry(pin, &iosapic_intr_info[vector].pin_head, pin_list) {
+		if (pin->gsi_base + pin->rte_index = gsi)
+			return pin;
+	}
+	return NULL;
+}
+
 static void
-set_rte (unsigned int vector, unsigned int dest, int mask)
+set_rte (unsigned int gsi, unsigned int vector, unsigned int dest, int mask)
 {
 	unsigned long pol, trigger, dmode, flags;
 	u32 low32, high32;
 	char *addr;
 	int rte_index;
 	char redir;
+	struct iosapic_pin *pin;
 
 	DBG(KERN_DEBUG"IOSAPIC: routing vector %d to 0x%x\n", vector, dest);
 
-	rte_index = iosapic_intr_info[vector].rte_index;
-	if (rte_index < 0)
+	if (!iosapic_intr_info[vector].count)
 		return;		/* not an IOSAPIC interrupt */
 
-	addr    = iosapic_intr_info[vector].addr;
 	pol     = iosapic_intr_info[vector].polarity;
 	trigger = iosapic_intr_info[vector].trigger;
 	dmode   = iosapic_intr_info[vector].dmode;
@@ -217,6 +240,17 @@ set_rte (unsigned int vector, unsigned i
 
 	spin_lock_irqsave(&iosapic_lock, flags);
 	{
+		if (!(iosapic_intr_info[vector].low32 & IOSAPIC_MASK))
+			low32 &= ~IOSAPIC_MASK;
+
+		pin = gsi_vector_to_pin(gsi, vector);
+		if (!pin) {
+			spin_unlock_irqrestore(&iosapic_lock, flags);
+			return;
+		}
+		rte_index = pin->rte_index;
+		addr    = pin->addr;
+
 		iosapic_write(addr, IOSAPIC_RTE_HIGH(rte_index), high32);
 		iosapic_write(addr, IOSAPIC_RTE_LOW(rte_index), low32);
 		iosapic_intr_info[vector].low32 = low32;
@@ -238,18 +272,20 @@ mask_irq (unsigned int irq)
 	u32 low32;
 	int rte_index;
 	ia64_vector vec = irq_to_vector(irq);
-
-	addr = iosapic_intr_info[vec].addr;
-	rte_index = iosapic_intr_info[vec].rte_index;
-
-	if (rte_index < 0)
+	struct iosapic_pin *pin;
+  
+	if (!iosapic_intr_info[vec].count)
 		return;			/* not an IOSAPIC interrupt! */
 
 	spin_lock_irqsave(&iosapic_lock, flags);
 	{
 		/* set only the mask bit */
 		low32 = iosapic_intr_info[vec].low32 |= IOSAPIC_MASK;
-		iosapic_write(addr, IOSAPIC_RTE_LOW(rte_index), low32);
+		list_for_each_entry(pin, &iosapic_intr_info[vec].pin_head, pin_list) {
+			addr = pin->addr;
+			rte_index = pin->rte_index;
+			iosapic_write(addr, IOSAPIC_RTE_LOW(rte_index), low32);
+		}
 	}
 	spin_unlock_irqrestore(&iosapic_lock, flags);
 }
@@ -262,16 +298,19 @@ unmask_irq (unsigned int irq)
 	u32 low32;
 	int rte_index;
 	ia64_vector vec = irq_to_vector(irq);
+	struct iosapic_pin *pin;
 
-	addr = iosapic_intr_info[vec].addr;
-	rte_index = iosapic_intr_info[vec].rte_index;
-	if (rte_index < 0)
+	if (!iosapic_intr_info[vec].count)
 		return;			/* not an IOSAPIC interrupt! */
 
 	spin_lock_irqsave(&iosapic_lock, flags);
 	{
 		low32 = iosapic_intr_info[vec].low32 &= ~IOSAPIC_MASK;
-		iosapic_write(addr, IOSAPIC_RTE_LOW(rte_index), low32);
+		list_for_each_entry(pin, &iosapic_intr_info[vec].pin_head, pin_list) {
+			addr = pin->addr;
+			rte_index = pin->rte_index;
+			iosapic_write(addr, IOSAPIC_RTE_LOW(rte_index), low32);
+		}
 	}
 	spin_unlock_irqrestore(&iosapic_lock, flags);
 }
@@ -287,6 +326,7 @@ iosapic_set_affinity (unsigned int irq, 
 	char *addr;
 	int redir = (irq & IA64_IRQ_REDIRECTED) ? 1 : 0;
 	ia64_vector vec;
+	struct iosapic_pin *pin;
 
 	irq &= (~IA64_IRQ_REDIRECTED);
 	vec = irq_to_vector(irq);
@@ -296,10 +336,7 @@ iosapic_set_affinity (unsigned int irq, 
 
 	dest = cpu_physical_id(first_cpu(mask));
 
-	rte_index = iosapic_intr_info[vec].rte_index;
-	addr = iosapic_intr_info[vec].addr;
-
-	if (rte_index < 0)
+	if (!iosapic_intr_info[vec].count)
 		return;			/* not an IOSAPIC interrupt */
 
 	set_irq_affinity_info(irq, dest, redir);
@@ -312,15 +349,19 @@ iosapic_set_affinity (unsigned int irq, 
 		low32 = iosapic_intr_info[vec].low32 & ~(7 << IOSAPIC_DELIVERY_SHIFT);
 
 		if (redir)
-		        /* change delivery mode to lowest priority */
+			/* change delivery mode to lowest priority */
 			low32 |= (IOSAPIC_LOWEST_PRIORITY << IOSAPIC_DELIVERY_SHIFT);
 		else
-		        /* change delivery mode to fixed */
+			/* change delivery mode to fixed */
 			low32 |= (IOSAPIC_FIXED << IOSAPIC_DELIVERY_SHIFT);
 
 		iosapic_intr_info[vec].low32 = low32;
-		iosapic_write(addr, IOSAPIC_RTE_HIGH(rte_index), high32);
-		iosapic_write(addr, IOSAPIC_RTE_LOW(rte_index), low32);
+		list_for_each_entry(pin, &iosapic_intr_info[vec].pin_head, pin_list) {
+			rte_index = pin->rte_index;
+			addr = pin->addr;
+			iosapic_write(addr, IOSAPIC_RTE_HIGH(rte_index), high32);
+			iosapic_write(addr, IOSAPIC_RTE_LOW(rte_index), low32);
+		}
 	}
 	spin_unlock_irqrestore(&iosapic_lock, flags);
 #endif
@@ -341,9 +382,11 @@ static void
 iosapic_end_level_irq (unsigned int irq)
 {
 	ia64_vector vec = irq_to_vector(irq);
+	struct iosapic_pin *pin;
 
 	move_irq(irq);
-	iosapic_eoi(iosapic_intr_info[vec].addr, vec);
+	list_for_each_entry(pin, &iosapic_intr_info[vec].pin_head, pin_list)
+		iosapic_eoi(pin->addr, vec);
 }
 
 #define iosapic_shutdown_level_irq	mask_irq
@@ -424,6 +467,30 @@ iosapic_version (char *addr)
 }
 
 /*
+ * Find a sharable vector.
+ */
+static int
+iosapic_find_sharable_vector (unsigned long trigger, unsigned long polarity)
+{
+	int i;
+	static int next_vector = IA64_FIRST_DEVICE_VECTOR;
+
+	for (i = 0; i < IA64_NUM_DEVICE_VECTORS; i++) {
+		if (next_vector > IA64_LAST_DEVICE_VECTOR)
+			next_vector = IA64_FIRST_DEVICE_VECTOR;
+
+		if (iosapic_intr_info[next_vector].type = IOSAPIC_VECTOR_SHARABLE &&
+		    iosapic_intr_info[next_vector].trigger = trigger &&
+		    iosapic_intr_info[next_vector].polarity = polarity)
+			return next_vector++;
+
+		next_vector++;
+	}
+
+	return -1;
+}
+
+/*
  * if the given vector is already owned by other,
  *  assign a new vector for the other and make the vector available
  */
@@ -432,22 +499,22 @@ iosapic_reassign_vector (int vector)
 {
 	int new_vector;
 
-	if (iosapic_intr_info[vector].rte_index >= 0 || iosapic_intr_info[vector].addr
-	    || iosapic_intr_info[vector].gsi_base || iosapic_intr_info[vector].dmode
-	    || iosapic_intr_info[vector].polarity || iosapic_intr_info[vector].trigger)
-	{
+	if (iosapic_intr_info[vector].count > 0) {
 		new_vector = assign_irq_vector(AUTO_ASSIGN);
 		printk(KERN_INFO "Reassigning vector %d to %d\n", vector, new_vector);
 		memcpy(&iosapic_intr_info[new_vector], &iosapic_intr_info[vector],
 		       sizeof(struct iosapic_intr_info));
+		INIT_LIST_HEAD(&iosapic_intr_info[new_vector].pin_head);
+		list_add(&iosapic_intr_info[new_vector].pin.pin_list,
+			 &iosapic_intr_info[new_vector].pin_head);
 		memset(&iosapic_intr_info[vector], 0, sizeof(struct iosapic_intr_info));
-		iosapic_intr_info[vector].rte_index = -1;
+		INIT_LIST_HEAD(&iosapic_intr_info[vector].pin_head);
 	}
 }
 
 static void
 register_intr (unsigned int gsi, int vector, unsigned char delivery,
-	       unsigned long polarity, unsigned long trigger)
+	       unsigned long polarity, unsigned long trigger, unsigned long type)
 {
 	irq_desc_t *idesc;
 	struct hw_interrupt_type *irq_type;
@@ -455,6 +522,7 @@ register_intr (unsigned int gsi, int vec
 	int index;
 	unsigned long gsi_base;
 	char *iosapic_address;
+	struct iosapic_pin *pin;
 
 	index = find_iosapic(gsi);
 	if (index < 0) {
@@ -465,13 +533,39 @@ register_intr (unsigned int gsi, int vec
 	iosapic_address = iosapic_lists[index].addr;
 	gsi_base = iosapic_lists[index].gsi_base;
 
+	pin = gsi_vector_to_pin(gsi, vector);
+	if (!pin) {	/* Register a new interrupt */
+		if (!iosapic_intr_info[vector].count) {
+			pin = &iosapic_intr_info[vector].pin;
+			iosapic_intr_info[vector].low32 = IOSAPIC_MASK;
+		}
+		else if ((pin = kmalloc(sizeof(struct iosapic_pin), GFP_KERNEL)) = NULL) {
+			printk (KERN_WARNING "%s: cannot allocate memory\n", __FUNCTION__);
+			return;
+		}
+		list_add_tail(&pin->pin_list, &iosapic_intr_info[vector].pin_head);
+		iosapic_intr_info[vector].count++;
+	} else {	/* Override an existing interrupt */
+		if (iosapic_intr_info[vector].count > 1) {
+			if (iosapic_intr_info[vector].trigger != trigger ||
+			    iosapic_intr_info[vector].polarity != polarity ||
+			    type = IOSAPIC_VECTOR_EXCLUSIVE)
+			{
+				printk(KERN_WARNING "%s: cannot override an interrupt\n",
+				       __FUNCTION__);
+				return;
+			}
+		}
+	}
+
 	rte_index = gsi - gsi_base;
-	iosapic_intr_info[vector].rte_index = rte_index;
+	pin->rte_index = rte_index;
+	pin->addr     = iosapic_address;
+	pin->gsi_base = gsi_base;
 	iosapic_intr_info[vector].polarity = polarity;
 	iosapic_intr_info[vector].dmode    = delivery;
-	iosapic_intr_info[vector].addr     = iosapic_address;
-	iosapic_intr_info[vector].gsi_base = gsi_base;
 	iosapic_intr_info[vector].trigger  = trigger;
+	iosapic_intr_info[vector].type     = type;
 
 	if (trigger = IOSAPIC_EDGE)
 		irq_type = &irq_type_iosapic_edge;
@@ -488,10 +582,23 @@ register_intr (unsigned int gsi, int vec
 }
 
 static unsigned int
-get_target_cpu (void)
+get_target_cpu (int vector)
 {
 #ifdef CONFIG_SMP
 	static int cpu = -1;
+	int irq;
+	cpumask_t cpumask, cpumask_all = CPU_MASK_ALL;
+
+	/*
+	 * if this vector already has its destination CPU, use the
+	 * same destination CPU.
+	 */
+	for (irq = 0; irq < NR_IRQS; ++irq)
+		if (irq_to_vector(irq) = vector) {
+			cpumask = get_irq_affinity_info(irq);
+			if (!cpus_equal(cpumask, cpumask_all))
+				return cpu_physical_id(first_cpu(cpumask));
+		}
 
 	/*
 	 * If the platform supports redirection via XTP, let it
@@ -549,19 +656,40 @@ iosapic_register_intr (unsigned int gsi,
 			return vector;
 		}
 
-		vector = assign_irq_vector(AUTO_ASSIGN);
-		dest = get_target_cpu();
-		register_intr(gsi, vector, IOSAPIC_LOWEST_PRIORITY,
-			polarity, trigger);
+		vector = assign_irq_vector_nopanic(AUTO_ASSIGN);
+		if (vector < 0)
+			vector = iosapic_find_sharable_vector(trigger, polarity);
+		if (vector < 0)
+			panic("%s: out of interrupt vectors!\n", __FUNCTION__);
 	}
 	spin_unlock_irqrestore(&iosapic_lock, flags);
 
+	spin_lock_irqsave(&irq_descp(vector)->lock, flags);
+	spin_lock(&iosapic_lock);
+	{
+		int tmp_vector = gsi_to_vector(gsi);
+		if (tmp_vector > 0) {
+			if (!iosapic_intr_info[vector].count)
+				free_irq_vector(vector);
+			spin_unlock(&iosapic_lock);
+			spin_unlock_irqrestore(&irq_descp(vector)->lock, flags);
+			return tmp_vector;
+		}
+		dest = get_target_cpu(vector);
+		register_intr(gsi, vector, IOSAPIC_LOWEST_PRIORITY,
+			polarity, trigger, trigger = IOSAPIC_EDGE ?
+			IOSAPIC_VECTOR_EXCLUSIVE : IOSAPIC_VECTOR_SHARABLE);
+	}
+	spin_unlock(&iosapic_lock);
+
 	printk(KERN_INFO "GSI %u (%s, %s) -> CPU %d (0x%04x) vector %d\n",
 	       gsi, (trigger = IOSAPIC_EDGE ? "edge" : "level"),
 	       (polarity = IOSAPIC_POL_HIGH ? "high" : "low"),
 	       cpu_logical_id(dest), dest, vector);
 
-	set_rte(vector, dest, 1);
+	set_rte(gsi, vector, dest, 1);
+
+	spin_unlock_irqrestore(&irq_descp(vector)->lock, flags);
 	return vector;
 }
 
@@ -603,7 +731,7 @@ iosapic_register_platform_intr (u32 int_
 		return -1;
 	}
 
-	register_intr(gsi, vector, delivery, polarity, trigger);
+	register_intr(gsi, vector, delivery, polarity, trigger, IOSAPIC_VECTOR_EXCLUSIVE);
 
 	printk(KERN_INFO "PLATFORM int %s (0x%x): GSI %u (%s, %s) -> CPU %d (0x%04x) vector %d\n",
 	       int_type < ARRAY_SIZE(name) ? name[int_type] : "unknown",
@@ -611,7 +739,7 @@ iosapic_register_platform_intr (u32 int_
 	       (polarity = IOSAPIC_POL_HIGH ? "high" : "low"),
 	       cpu_logical_id(dest), dest, vector);
 
-	set_rte(vector, dest, mask);
+	set_rte(gsi, vector, dest, mask);
 	return vector;
 }
 
@@ -630,14 +758,14 @@ iosapic_override_isa_irq (unsigned int i
 
 	vector = isa_irq_to_vector(isa_irq);
 
-	register_intr(gsi, vector, IOSAPIC_LOWEST_PRIORITY, polarity, trigger);
+	register_intr(gsi, vector, IOSAPIC_LOWEST_PRIORITY, polarity, trigger, IOSAPIC_VECTOR_EXCLUSIVE);
 
 	DBG("ISA: IRQ %u -> GSI %u (%s,%s) -> CPU %d (0x%04x) vector %d\n",
 	    isa_irq, gsi, trigger = IOSAPIC_EDGE ? "edge" : "level",
 	    polarity = IOSAPIC_POL_HIGH ? "high" : "low",
 	    cpu_logical_id(dest), dest, vector);
 
-	set_rte(vector, dest, 1);
+	set_rte(gsi, vector, dest, 1);
 }
 
 void __init
@@ -645,8 +773,10 @@ iosapic_system_init (int system_pcat_com
 {
 	int vector;
 
-	for (vector = 0; vector < IA64_NUM_VECTORS; ++vector)
-		iosapic_intr_info[vector].rte_index = -1;	/* mark as unused */
+	for (vector = 0; vector < IA64_NUM_VECTORS; ++vector) {
+		iosapic_intr_info[vector].count = 0;	/* mark as unused */
+		INIT_LIST_HEAD(&iosapic_intr_info[vector].pin_head);
+	}
 
 	pcat_compat = system_pcat_compat;
 	if (pcat_compat) {
diff -Naurp linux-2.6.8-rc1/arch/ia64/kernel/irq.c linux-2.6.8-rc1-changed/arch/ia64/kernel/irq.c
--- linux-2.6.8-rc1/arch/ia64/kernel/irq.c	2004-07-14 15:07:23.815322847 +0900
+++ linux-2.6.8-rc1-changed/arch/ia64/kernel/irq.c	2004-07-14 15:07:57.208095326 +0900
@@ -949,6 +949,11 @@ void set_irq_affinity_info (unsigned int
 	}
 }
 
+cpumask_t get_irq_affinity_info (unsigned int irq)
+{
+	return irq_affinity[irq];
+}
+
 static int irq_affinity_read_proc (char *page, char **start, off_t off,
 			int count, int *eof, void *data)
 {
diff -Naurp linux-2.6.8-rc1/arch/ia64/kernel/irq_ia64.c linux-2.6.8-rc1-changed/arch/ia64/kernel/irq_ia64.c
--- linux-2.6.8-rc1/arch/ia64/kernel/irq_ia64.c	2004-07-14 15:07:23.810440006 +0900
+++ linux-2.6.8-rc1-changed/arch/ia64/kernel/irq_ia64.c	2004-07-14 15:07:57.209071894 +0900
@@ -74,15 +74,44 @@ irq_exit (void)
 	preempt_enable_no_resched();
 }
 
+static unsigned long ia64_vector_mask[BITS_TO_LONGS(IA64_NUM_DEVICE_VECTORS)];
+
+int
+assign_irq_vector_nopanic (int irq)
+{
+	int pos, vector;
+ again:
+	pos = find_first_zero_bit(ia64_vector_mask, IA64_NUM_DEVICE_VECTORS);
+	vector = IA64_FIRST_DEVICE_VECTOR + pos;
+	if (vector > IA64_LAST_DEVICE_VECTOR)
+		return -1;
+	if (test_and_set_bit(pos, ia64_vector_mask))
+		goto again;
+	return vector;
+}
+
 int
 assign_irq_vector (int irq)
 {
-	static int next_vector = IA64_FIRST_DEVICE_VECTOR;
+	int vector = assign_irq_vector_nopanic(irq);
 
-	if (next_vector > IA64_LAST_DEVICE_VECTOR)
-		/* XXX could look for sharable vectors instead of panic'ing... */
+	if (vector = -1)
 		panic("assign_irq_vector: out of interrupt vectors!");
-	return next_vector++;
+	return vector;
+}
+
+void
+free_irq_vector (int vector)
+{
+	int pos;
+
+	if (vector < IA64_FIRST_DEVICE_VECTOR || vector > IA64_LAST_DEVICE_VECTOR) {
+		printk(KERN_WARNING "%s: wrong device vector!\n", __FUNCTION__);
+		return;
+	}
+	pos = vector - IA64_FIRST_DEVICE_VECTOR;
+	if (!test_and_clear_bit(pos, ia64_vector_mask))
+		printk(KERN_WARNING "%s: double free!\n", __FUNCTION__);
 }
 
 extern unsigned int do_IRQ(unsigned long irq, struct pt_regs *regs);
diff -Naurp linux-2.6.8-rc1/include/asm-ia64/hw_irq.h linux-2.6.8-rc1-changed/include/asm-ia64/hw_irq.h
--- linux-2.6.8-rc1/include/asm-ia64/hw_irq.h	2004-07-14 15:07:24.316302325 +0900
+++ linux-2.6.8-rc1-changed/include/asm-ia64/hw_irq.h	2004-07-14 15:07:57.210048462 +0900
@@ -50,6 +50,7 @@ typedef u8 ia64_vector;
  */
 #define IA64_FIRST_DEVICE_VECTOR	0x30
 #define IA64_LAST_DEVICE_VECTOR		0xe7
+#define IA64_NUM_DEVICE_VECTORS		(IA64_LAST_DEVICE_VECTOR - IA64_FIRST_DEVICE_VECTOR + 1)
 
 #define IA64_MCA_RENDEZ_VECTOR		0xe8	/* MCA rendez interrupt */
 #define IA64_PERFMON_VECTOR		0xee	/* performanc monitor interrupt vector */
@@ -82,7 +83,9 @@ extern unsigned long ipi_base_addr;
 
 extern struct hw_interrupt_type irq_type_ia64_lsapic;	/* CPU-internal interrupt controller */
 
+extern int assign_irq_vector_nopanic (int irq);
 extern int assign_irq_vector (int irq);	/* allocate a free vector */
+extern void free_irq_vector (int vector);
 extern void ia64_send_ipi (int cpu, int vector, int delivery_mode, int redirect);
 extern void register_percpu_irq (ia64_vector vec, struct irqaction *action);
 
diff -Naurp linux-2.6.8-rc1/include/asm-ia64/iosapic.h linux-2.6.8-rc1-changed/include/asm-ia64/iosapic.h
--- linux-2.6.8-rc1/include/asm-ia64/iosapic.h	2004-07-14 15:07:24.319232030 +0900
+++ linux-2.6.8-rc1-changed/include/asm-ia64/iosapic.h	2004-07-14 15:07:57.210048462 +0900
@@ -47,6 +47,12 @@
 #define	IOSAPIC_MASK_SHIFT		16
 #define	IOSAPIC_MASK			(1<<IOSAPIC_MASK_SHIFT)
 
+/*
+ * Vector type
+ */
+#define IOSAPIC_VECTOR_EXCLUSIVE	0
+#define IOSAPIC_VECTOR_SHARABLE		1
+
 #ifndef __ASSEMBLY__
 
 #ifdef CONFIG_IOSAPIC
diff -Naurp linux-2.6.8-rc1/include/asm-ia64/irq.h linux-2.6.8-rc1-changed/include/asm-ia64/irq.h
--- linux-2.6.8-rc1/include/asm-ia64/irq.h	2004-07-14 15:07:24.326068007 +0900
+++ linux-2.6.8-rc1-changed/include/asm-ia64/irq.h	2004-07-14 15:07:57.211025030 +0900
@@ -31,6 +31,8 @@ extern void enable_irq (unsigned int);
 extern void set_irq_affinity_info (unsigned int irq, int dest, int redir);
 
 #ifdef CONFIG_SMP
+#include <linux/cpumask.h>
+extern cpumask_t get_irq_affinity_info (unsigned int irq);
 extern void move_irq(int irq);
 #else
 #define move_irq(irq)


