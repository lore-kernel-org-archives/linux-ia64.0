From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Mon, 19 Apr 2004 09:31:31 +0000
Subject: [PATCH][RFC] Vector sharing
Message-Id: <MDEEKOKJPMPMKGHIFAMAOENCDMAA.kaneshige.kenji@jp.fujitsu.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----=_NextPart_000_0011_01C4263C.894E2670"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------=_NextPart_000_0011_01C4263C.894E2670
Content-Type: text/plain;
	charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit

Hi,

I'm trying to make a patch that allows device vectors to be shared by
multiple interrupt sources. This patch enables ia64 linux to boot on
the machine that has single vector number space and many device
interrupt sources (more than 184).

I am changing IA64_LAST_DEVICE_VECTOR to 0x30 in order to test my
patch. My patch seems to work fine on my test environment.

The information of /proc/interrupts on my test environment is shown
below. It says multiple devices are sharing the vector (==IRQ)
0x30. Of course, these devices are not sharing the same interrupt
lines.

           CPU0       CPU1       CPU2       CPU3
 29:          0          0          0          0          LSAPIC  cmc_poll
 30:          0          0          0          0  IO-SAPIC-level  cpe_hndlr
 31:          0          0          0          0          LSAPIC  cmc_hndlr
 34:          2          0          6          0   IO-SAPIC-edge  ide0
 39:          0          0          0          0  IO-SAPIC-level  acpi
 45:          0         50        189          2   IO-SAPIC-edge  serial
 48:          0        280      56383         16  IO-SAPIC-level  ioc0,
ioc1, ehci_hcd, uhci_hcd, uhci_hcd, eth0, eth1
232:          0          0          0          0          LSAPIC  mca_rdzv
238:          0          0          0          0          LSAPIC  perfmon
239:    6732150    6729399    6729272    6729140          LSAPIC  timer
240:          0          0          0          0          LSAPIC  mca_wkup
254:          7         85         85         81          LSAPIC  IPI
NMI:          0          0          0          0
ERR:          0


I am concerned about following point of the design:

    o My patch supports to find the sharable vectors not only for
      level triggered interrupt sources but also for edge triggered
      interrupt sources (Please see
      iosapic_find_sharable_vector()). But I am wondering if it is
      needed for edge triggered interrupt sources.  (As a matter of
      fact, my patch doesn't mark the vectors for edge triggered
      interrupts as sharable (e.g. iosapic_register_intr()).


Any comments are welcomed.

Thanks,
Kenji Kaneshige


diff -Naur linux-2.6.6-rc1/arch/ia64/kernel/iosapic.c
linux-2.6.6-rc1-changed/arch/ia64/kernel/iosapic.c
--- linux-2.6.6-rc1/arch/ia64/kernel/iosapic.c	2004-04-19
16:10:25.970346988 +0900
+++ linux-2.6.6-rc1-changed/arch/ia64/kernel/iosapic.c	2004-04-19
16:25:23.251036926 +0900
@@ -101,15 +101,23 @@

 /* These tables map IA-64 vectors to the IOSAPIC pin that generates this
vector. */

-static struct iosapic_intr_info {
+struct iosapic_pin {
+	struct list_head pin_list;	/* IOSAPIC pins which share the same vector
*/
 	char		*addr;		/* base address of IOSAPIC */
 	u32		low32;		/* current value of low word of Redirection table entry
*/
 	unsigned int	gsi_base;	/* first GSI assigned to this IOSAPIC */
-	char		rte_index;	/* IOSAPIC RTE index (-1 => not an IOSAPIC interrupt)
*/
-	unsigned char	dmode	: 3;	/* delivery mode (see iosapic.h) */
+	char		rte_index;	/* IOSAPIC RTE index */
 	unsigned char 	polarity: 1;	/* interrupt polarity (see iosapic.h) */
+};
+
+static struct iosapic_intr_info {
+	struct list_head pin_head;	/* List head of IOSAPIC pins */
+	struct iosapic_pin pin;		/* First entry of IOSAPIC pins list */
+	int		count;		/* # of pins (0 => not an IOSAPIC interrupt) */
+	unsigned char	dmode	: 3;	/* delivery mode (see iosapic.h) */
 	unsigned char	trigger	: 1;	/* trigger mode (see iosapic.h) */
-} iosapic_intr_info[IA64_NUM_VECTORS];
+	unsigned char	type	: 1;	/* Vector type */
+} iosapic_intr_info[IA64_NUM_VECTORS] __cacheline_aligned;

 static struct iosapic {
 	char		*addr;		/* base address of IOSAPIC */
@@ -142,10 +150,14 @@
 _gsi_to_vector (unsigned int gsi)
 {
 	struct iosapic_intr_info *info;
+	struct iosapic_pin *pin;

-	for (info = iosapic_intr_info; info < iosapic_intr_info +
IA64_NUM_VECTORS; ++info)
-		if (info->gsi_base + info->rte_index == gsi)
-			return info - iosapic_intr_info;
+	for (info = iosapic_intr_info; info < iosapic_intr_info +
IA64_NUM_VECTORS; ++info) {
+		list_for_each_entry(pin, &info->pin_head, pin_list) {
+			if (pin->gsi_base + pin->rte_index == gsi)
+				return info - iosapic_intr_info;
+		}
+	}
 	return -1;
 }

@@ -177,15 +189,13 @@
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
-	pol     = iosapic_intr_info[vector].polarity;
 	trigger = iosapic_intr_info[vector].trigger;
 	dmode   = iosapic_intr_info[vector].dmode;

@@ -193,31 +203,47 @@
 #ifdef CONFIG_SMP
 	{
 		unsigned int irq;
+		cpumask_t cpumask;

 		for (irq = 0; irq < NR_IRQS; ++irq)
 			if (irq_to_vector(irq) == vector) {
-				set_irq_affinity_info(irq, (int)(dest & 0xffff), redir);
+				/* All pins should use the same destination CPU */
+				cpumask = get_irq_affinity_info(irq);
+				if (cpumask != CPU_MASK_ALL)
+					dest = cpu_physical_id(first_cpu(mask));
+				else
+					set_irq_affinity_info(irq, (int)(dest & 0xffff), redir);
 				break;
 			}
 	}
 #endif

-	low32 = ((pol << IOSAPIC_POLARITY_SHIFT) |
-		 (trigger << IOSAPIC_TRIGGER_SHIFT) |
-		 (dmode << IOSAPIC_DELIVERY_SHIFT) |
-		 ((mask ? 1 : 0) << IOSAPIC_MASK_SHIFT) |
-		 vector);
-
 	/* dest contains both id and eid */
 	high32 = (dest << IOSAPIC_DEST_SHIFT);

 	spin_lock_irqsave(&iosapic_lock, flags);
 	{
-		writel(IOSAPIC_RTE_HIGH(rte_index), addr + IOSAPIC_REG_SELECT);
-		writel(high32, addr + IOSAPIC_WINDOW);
-		writel(IOSAPIC_RTE_LOW(rte_index), addr + IOSAPIC_REG_SELECT);
-		writel(low32, addr + IOSAPIC_WINDOW);
-		iosapic_intr_info[vector].low32 = low32;
+		list_for_each_entry(pin, &iosapic_intr_info[vector].pin_head, pin_list)
{
+			/* Don't change RTE which is already unmasked */
+			if (!(pin->low32 & IOSAPIC_MASK))
+				continue;
+
+			rte_index = pin->rte_index;
+			addr    = pin->addr;
+			pol     = pin->polarity;
+
+			low32 = ((pol << IOSAPIC_POLARITY_SHIFT) |
+				 (trigger << IOSAPIC_TRIGGER_SHIFT) |
+				 (dmode << IOSAPIC_DELIVERY_SHIFT) |
+				 ((mask ? 1 : 0) << IOSAPIC_MASK_SHIFT) |
+				 vector);
+
+			writel(IOSAPIC_RTE_HIGH(rte_index), addr + IOSAPIC_REG_SELECT);
+			writel(high32, addr + IOSAPIC_WINDOW);
+			writel(IOSAPIC_RTE_LOW(rte_index), addr + IOSAPIC_REG_SELECT);
+			writel(low32, addr + IOSAPIC_WINDOW);
+			pin->low32 = low32;
+		}
 	}
 	spin_unlock_irqrestore(&iosapic_lock, flags);
 }
@@ -236,21 +262,24 @@
 	u32 low32;
 	int rte_index;
 	ia64_vector vec = irq_to_vector(irq);
+	struct iosapic_pin *pin;

-	addr = iosapic_intr_info[vec].addr;
-	rte_index = iosapic_intr_info[vec].rte_index;
-
-	if (rte_index < 0)
+	if (!iosapic_intr_info[vec].count)
 		return;			/* not an IOSAPIC interrupt! */

 	spin_lock_irqsave(&iosapic_lock, flags);
 	{
-		writel(IOSAPIC_RTE_LOW(rte_index), addr + IOSAPIC_REG_SELECT);
+		list_for_each_entry(pin, &iosapic_intr_info[vec].pin_head, pin_list) {
+			addr = pin->addr;
+			rte_index = pin->rte_index;
+
+			writel(IOSAPIC_RTE_LOW(rte_index), addr + IOSAPIC_REG_SELECT);

-		/* set only the mask bit */
-		low32 = iosapic_intr_info[vec].low32 |= IOSAPIC_MASK;
+			/* set only the mask bit */
+			low32 = pin->low32 |= IOSAPIC_MASK;

-		writel(low32, addr + IOSAPIC_WINDOW);
+			writel(low32, addr + IOSAPIC_WINDOW);
+		}
 	}
 	spin_unlock_irqrestore(&iosapic_lock, flags);
 }
@@ -263,17 +292,21 @@
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
-		writel(IOSAPIC_RTE_LOW(rte_index), addr + IOSAPIC_REG_SELECT);
-		low32 = iosapic_intr_info[vec].low32 &= ~IOSAPIC_MASK;
-		writel(low32, addr + IOSAPIC_WINDOW);
+		list_for_each_entry(pin, &iosapic_intr_info[vec].pin_head, pin_list) {
+			addr = pin->addr;
+			rte_index = pin->rte_index;
+
+			writel(IOSAPIC_RTE_LOW(rte_index), addr + IOSAPIC_REG_SELECT);
+			low32 = pin->low32 &= ~IOSAPIC_MASK;
+			writel(low32, addr + IOSAPIC_WINDOW);
+		}
 	}
 	spin_unlock_irqrestore(&iosapic_lock, flags);
 }
@@ -289,6 +322,7 @@
 	char *addr;
 	int redir = (irq & IA64_IRQ_REDIRECTED) ? 1 : 0;
 	ia64_vector vec;
+	struct iosapic_pin *pin;

 	irq &= (~IA64_IRQ_REDIRECTED);
 	vec = irq_to_vector(irq);
@@ -298,10 +332,7 @@

 	dest = cpu_physical_id(first_cpu(mask));

-	rte_index = iosapic_intr_info[vec].rte_index;
-	addr = iosapic_intr_info[vec].addr;
-
-	if (rte_index < 0)
+	if (!iosapic_intr_info[vec].count)
 		return;			/* not an IOSAPIC interrupt */

 	set_irq_affinity_info(irq, dest, redir);
@@ -311,21 +342,26 @@

 	spin_lock_irqsave(&iosapic_lock, flags);
 	{
-		/* get current delivery mode by reading the low32 */
-		writel(IOSAPIC_RTE_LOW(rte_index), addr + IOSAPIC_REG_SELECT);
-		low32 = iosapic_intr_info[vec].low32 & ~(7 << IOSAPIC_DELIVERY_SHIFT);
-		if (redir)
-		        /* change delivery mode to lowest priority */
-			low32 |= (IOSAPIC_LOWEST_PRIORITY << IOSAPIC_DELIVERY_SHIFT);
-		else
-		        /* change delivery mode to fixed */
-			low32 |= (IOSAPIC_FIXED << IOSAPIC_DELIVERY_SHIFT);
-
-		iosapic_intr_info[vec].low32 = low32;
-		writel(IOSAPIC_RTE_HIGH(rte_index), addr + IOSAPIC_REG_SELECT);
-		writel(high32, addr + IOSAPIC_WINDOW);
-		writel(IOSAPIC_RTE_LOW(rte_index), addr + IOSAPIC_REG_SELECT);
-		writel(low32, addr + IOSAPIC_WINDOW);
+		list_for_each_entry(pin, &iosapic_intr_info[vec].pin_head, pin_list) {
+			rte_index = pin->rte_index;
+			addr = pin->addr;
+
+			/* get current delivery mode by reading the low32 */
+			writel(IOSAPIC_RTE_LOW(rte_index), addr + IOSAPIC_REG_SELECT);
+			low32 = pin->low32 & ~(7 << IOSAPIC_DELIVERY_SHIFT);
+			if (redir)
+				/* change delivery mode to lowest priority */
+				low32 |= (IOSAPIC_LOWEST_PRIORITY << IOSAPIC_DELIVERY_SHIFT);
+			else
+				/* change delivery mode to fixed */
+				low32 |= (IOSAPIC_FIXED << IOSAPIC_DELIVERY_SHIFT);
+
+			pin->low32 = low32;
+			writel(IOSAPIC_RTE_HIGH(rte_index), addr + IOSAPIC_REG_SELECT);
+			writel(high32, addr + IOSAPIC_WINDOW);
+			writel(IOSAPIC_RTE_LOW(rte_index), addr + IOSAPIC_REG_SELECT);
+			writel(low32, addr + IOSAPIC_WINDOW);
+		}
 	}
 	spin_unlock_irqrestore(&iosapic_lock, flags);
 #endif
@@ -346,8 +382,11 @@
 iosapic_end_level_irq (unsigned int irq)
 {
 	ia64_vector vec = irq_to_vector(irq);
+	struct iosapic_pin *pin;

-	writel(vec, iosapic_intr_info[vec].addr + IOSAPIC_EOI);
+	list_for_each_entry(pin, &iosapic_intr_info[vec].pin_head, pin_list) {
+		writel(vec, pin->addr + IOSAPIC_EOI);
+	}
 }

 #define iosapic_shutdown_level_irq	mask_irq
@@ -427,6 +466,30 @@
 }

 /*
+ * Find a sharable vector.
+ *
+ * NOTE: This function assumes that platform interrupt doesn't share
+ * the vector.
+ */
+static int
+iosapic_find_sharable_vector (unsigned long trigger)
+{
+	int i;
+	static int next_vector = IA64_FIRST_DEVICE_VECTOR;
+
+	for (i = 0; i < IA64_LAST_DEVICE_VECTOR - IA64_FIRST_DEVICE_VECTOR + 1;
i++) {
+		if (next_vector > IA64_LAST_DEVICE_VECTOR)
+			next_vector = IA64_FIRST_DEVICE_VECTOR;
+
+		if (iosapic_intr_info[next_vector].type == IOSAPIC_VECTOR_SHARABLE &&
+		    iosapic_intr_info[next_vector].trigger == trigger)
+			return next_vector++;
+	}
+
+	return -1;
+}
+
+/*
  * if the given vector is already owned by other,
  *  assign a new vector for the other and make the vector available
  */
@@ -435,22 +498,20 @@
 {
 	int new_vector;

-	if (iosapic_intr_info[vector].rte_index >= 0 ||
iosapic_intr_info[vector].addr
-	    || iosapic_intr_info[vector].gsi_base ||
iosapic_intr_info[vector].dmode
-	    || iosapic_intr_info[vector].polarity ||
iosapic_intr_info[vector].trigger)
+	if (!iosapic_intr_info[vector].count)
 	{
 		new_vector = assign_irq_vector(AUTO_ASSIGN);
 		printk(KERN_INFO "Reassigning vector %d to %d\n", vector, new_vector);
 		memcpy(&iosapic_intr_info[new_vector], &iosapic_intr_info[vector],
 		       sizeof(struct iosapic_intr_info));
 		memset(&iosapic_intr_info[vector], 0, sizeof(struct
iosapic_intr_info));
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
@@ -458,6 +519,7 @@
 	int index;
 	unsigned long gsi_base;
 	char *iosapic_address;
+	struct iosapic_pin *pin, *tmp;

 	index = find_iosapic(gsi);
 	if (index < 0) {
@@ -468,13 +530,86 @@
 	iosapic_address = iosapic_lists[index].addr;
 	gsi_base = iosapic_lists[index].gsi_base;

-	rte_index = gsi - gsi_base;
-	iosapic_intr_info[vector].rte_index = rte_index;
-	iosapic_intr_info[vector].polarity = polarity;
-	iosapic_intr_info[vector].dmode    = delivery;
-	iosapic_intr_info[vector].addr     = iosapic_address;
-	iosapic_intr_info[vector].gsi_base = gsi_base;
-	iosapic_intr_info[vector].trigger  = trigger;
+	/*
+	 * Only interrupt sources whose delivery mode is IOSAPIC_LOWEST_PRIORITY
or
+	 * IOSAPIC_FIXED can share the vector in the current implementation.
+	 */
+	if (delivery != IOSAPIC_LOWEST_PRIORITY &&
+	    delivery != IOSAPIC_FIXED &&
+	    type != IOSAPIC_VECTOR_EXCLUSIVE)
+	{
+		type = IOSAPIC_VECTOR_EXCLUSIVE;
+	}
+
+	pin = NULL;
+	list_for_each_entry(tmp, &iosapic_intr_info[vector].pin_head, pin_list) {
+		if (tmp->gsi_base + tmp->rte_index == gsi) {
+			pin = tmp;
+			break;
+		}
+	}
+
+	if (!pin) {
+		/*
+		 * Register a new interrupt
+		 */
+		if (!iosapic_intr_info[vector].count) {
+			pin = &iosapic_intr_info[vector].pin;
+			iosapic_intr_info[vector].dmode   = delivery;
+			iosapic_intr_info[vector].trigger = trigger;
+			iosapic_intr_info[vector].type    = type;
+		}
+		else if (type == IOSAPIC_VECTOR_EXCLUSIVE) {
+			printk (KERN_WARNING "%s: vector %d is in use\n", __FUNCTION__,
vector);
+			return;
+		}
+		else if (iosapic_intr_info[vector].type == IOSAPIC_VECTOR_EXCLUSIVE) {
+			printk (KERN_WARNING "%s: cannot share the vector %d\n",
__FUNCTION__, vector);
+			return;
+		}
+		else {
+			pin = kmalloc(sizeof(struct iosapic_pin), GFP_KERNEL);
+			if (!pin) {
+				printk (KERN_WARNING "%s: cannot allocate memory\n", __FUNCTION__);
+				return;
+			}
+		}
+
+		rte_index = gsi - gsi_base;
+		pin->rte_index = rte_index;
+		pin->polarity = polarity;
+		pin->addr     = iosapic_address;
+		pin->gsi_base = gsi_base;
+		pin->low32    = IOSAPIC_MASK;
+
+		list_add_tail(&pin->pin_list, &iosapic_intr_info[vector].pin_head);
+		iosapic_intr_info[vector].count++;
+	}
+	else {
+		/*
+		 * Override a existing interupt
+		 */
+		if (iosapic_intr_info[vector].count > 1) {
+			if (iosapic_intr_info[vector].trigger != trigger) {
+				printk (KERN_WARNING "%s: cannot change trigger mode\n",
__FUNCTION__);
+				return;
+			}
+			if (type == IOSAPIC_VECTOR_EXCLUSIVE) {
+				printk (KERN_WARNING "%s: vector %d is already shared\n",
__FUNCTION__, vector);
+				return;
+			}
+		}
+
+		rte_index = gsi - gsi_base;
+		pin->rte_index = rte_index;
+		pin->polarity = polarity;
+		pin->addr     = iosapic_address;
+		pin->gsi_base = gsi_base;
+		pin->low32    = IOSAPIC_MASK;
+		iosapic_intr_info[vector].dmode   = delivery;
+		iosapic_intr_info[vector].trigger = trigger;
+		iosapic_intr_info[vector].type    = type;
+	}

 	if (trigger == IOSAPIC_EDGE)
 		irq_type = &irq_type_iosapic_edge;
@@ -504,10 +639,17 @@

 	vector = gsi_to_vector(gsi);
 	if (vector < 0)
-		vector = assign_irq_vector(AUTO_ASSIGN);
+		vector = assign_irq_vector_nopanic(AUTO_ASSIGN);
+
+	if (vector < 0)
+		vector = iosapic_find_sharable_vector(trigger);
+
+	if (vector < 0)
+		panic ("%s: out of interrupt vectors!", __FUNCTION__);

 	register_intr(gsi, vector, IOSAPIC_LOWEST_PRIORITY,
-		      polarity, trigger);
+		      polarity, trigger,
+		      (trigger == IOSAPIC_EDGE ? IOSAPIC_VECTOR_EXCLUSIVE :
IOSAPIC_VECTOR_SHARABLE));

 	printk(KERN_INFO "GSI 0x%x(%s,%s) -> CPU 0x%04x vector %d\n",
 	       gsi, (polarity == IOSAPIC_POL_HIGH ? "high" : "low"),
@@ -555,7 +697,7 @@
 	}

 	register_intr(gsi, vector, delivery, polarity,
-		      trigger);
+		      trigger, IOSAPIC_VECTOR_EXCLUSIVE);

 	printk(KERN_INFO "PLATFORM int 0x%x: GSI 0x%x(%s,%s) -> CPU 0x%04x vector
%d\n",
 	       int_type, gsi, (polarity == IOSAPIC_POL_HIGH ? "high" : "low"),
@@ -581,7 +723,7 @@

 	vector = isa_irq_to_vector(isa_irq);

-	register_intr(gsi, vector, IOSAPIC_LOWEST_PRIORITY, polarity, trigger);
+	register_intr(gsi, vector, IOSAPIC_LOWEST_PRIORITY, polarity, trigger,
IOSAPIC_VECTOR_EXCLUSIVE);

 	DBG("ISA: IRQ %u -> GSI 0x%x (%s,%s) -> CPU 0x%04x vector %d\n",
 	    isa_irq, gsi, polarity == IOSAPIC_POL_HIGH ? "high" : "low",
@@ -596,8 +738,10 @@
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
@@ -710,12 +854,17 @@
 			/* allocate a vector for this interrupt line */
 			if (pcat_compat && (gsi < 16))
 				vector = isa_irq_to_vector(gsi);
-			else
+			else {
 				/* new GSI; allocate a vector for it */
-				vector = assign_irq_vector(AUTO_ASSIGN);
+				vector = assign_irq_vector_nopanic(AUTO_ASSIGN);
+				if (vector < 0)
+					vector = iosapic_find_sharable_vector(IOSAPIC_LEVEL);
+				if (vector < 0)
+					panic ("%s: out of interrupt vectors!", __FUNCTION__);
+			}

 			register_intr(gsi, vector, IOSAPIC_LOWEST_PRIORITY, IOSAPIC_POL_LOW,
-				      IOSAPIC_LEVEL);
+				      IOSAPIC_LEVEL, IOSAPIC_VECTOR_SHARABLE);
 		}
 		entry->irq = vector;
 		snprintf(pci_id, sizeof(pci_id), "%02x:%02x:%02x[%c]",
@@ -728,7 +877,7 @@
 		idesc = irq_descp(vector);
 		if (idesc->handler != irq_type)
 			register_intr(gsi, vector, IOSAPIC_LOWEST_PRIORITY, IOSAPIC_POL_LOW,
-				      IOSAPIC_LEVEL);
+				      IOSAPIC_LEVEL, IOSAPIC_VECTOR_SHARABLE);

 	}
 }
diff -Naur linux-2.6.6-rc1/arch/ia64/kernel/irq.c
linux-2.6.6-rc1-changed/arch/ia64/kernel/irq.c
--- linux-2.6.6-rc1/arch/ia64/kernel/irq.c	2004-04-04 12:38:13.000000000
+0900
+++ linux-2.6.6-rc1-changed/arch/ia64/kernel/irq.c	2004-04-19
16:10:53.513448673 +0900
@@ -935,6 +935,11 @@
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
diff -Naur linux-2.6.6-rc1/arch/ia64/kernel/irq_ia64.c
linux-2.6.6-rc1-changed/arch/ia64/kernel/irq_ia64.c
--- linux-2.6.6-rc1/arch/ia64/kernel/irq_ia64.c	2004-04-19
16:10:25.971323555 +0900
+++ linux-2.6.6-rc1-changed/arch/ia64/kernel/irq_ia64.c	2004-04-19
16:10:53.513448673 +0900
@@ -72,17 +72,25 @@
 	preempt_enable_no_resched();
 }

+static int next_vector = IA64_FIRST_DEVICE_VECTOR;
+
 int
 assign_irq_vector (int irq)
 {
-	static int next_vector = IA64_FIRST_DEVICE_VECTOR;
-
 	if (next_vector > IA64_LAST_DEVICE_VECTOR)
 		/* XXX could look for sharable vectors instead of panic'ing... */
 		panic("assign_irq_vector: out of interrupt vectors!");
 	return next_vector++;
 }

+int
+assign_irq_vector_nopanic (int irq)
+{
+	if (next_vector > IA64_LAST_DEVICE_VECTOR)
+		return -1;
+	return next_vector++;
+}
+
 extern unsigned int do_IRQ(unsigned long irq, struct pt_regs *regs);

 /*
diff -Naur linux-2.6.6-rc1/include/asm-ia64/hw_irq.h
linux-2.6.6-rc1-changed/include/asm-ia64/hw_irq.h
--- linux-2.6.6-rc1/include/asm-ia64/hw_irq.h	2004-04-19 16:10:27.139297942
+0900
+++ linux-2.6.6-rc1-changed/include/asm-ia64/hw_irq.h	2004-04-19
16:10:53.514425240 +0900
@@ -83,6 +83,7 @@
 extern struct hw_interrupt_type irq_type_ia64_lsapic;	/* CPU-internal
interrupt controller */

 extern int assign_irq_vector (int irq);	/* allocate a free vector */
+extern int assign_irq_vector_nopanic (int irq);
 extern void ia64_send_ipi (int cpu, int vector, int delivery_mode, int
redirect);
 extern void register_percpu_irq (ia64_vector vec, struct irqaction
*action);

diff -Naur linux-2.6.6-rc1/include/asm-ia64/iosapic.h
linux-2.6.6-rc1-changed/include/asm-ia64/iosapic.h
--- linux-2.6.6-rc1/include/asm-ia64/iosapic.h	2004-04-04
12:37:23.000000000 +0900
+++ linux-2.6.6-rc1-changed/include/asm-ia64/iosapic.h	2004-04-19
16:10:53.514425240 +0900
@@ -49,6 +49,12 @@
 #define	IOSAPIC_MASK_SHIFT		16
 #define	IOSAPIC_MASK			(1<<IOSAPIC_MASK_SHIFT)

+/*
+ * Vector type
+ */
+#define IOSAPIC_VECTOR_EXCLUSIVE	(0)
+#define IOSAPIC_VECTOR_SHARABLE		(1)
+
 #ifndef __ASSEMBLY__

 #ifdef CONFIG_IOSAPIC
diff -Naur linux-2.6.6-rc1/include/asm-ia64/irq.h
linux-2.6.6-rc1-changed/include/asm-ia64/irq.h
--- linux-2.6.6-rc1/include/asm-ia64/irq.h	2004-04-19 16:10:27.140274509
+0900
+++ linux-2.6.6-rc1-changed/include/asm-ia64/irq.h	2004-04-19
16:10:53.514425240 +0900
@@ -29,6 +29,10 @@
 extern void disable_irq_nosync (unsigned int);
 extern void enable_irq (unsigned int);
 extern void set_irq_affinity_info (unsigned int irq, int dest, int redir);
+#ifdef CONFIG_SMP
+#include <asm/cpumask.h>
+extern cpumask_t get_irq_affinity_info (unsigned int irq);
+#endif /* CONFIG_SMP */

 struct irqaction;
 struct pt_regs;

------=_NextPart_000_0011_01C4263C.894E2670
Content-Type: application/octet-stream;
	name="share_vector.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="share_vector.patch"

diff -Naur linux-2.6.6-rc1/arch/ia64/kernel/iosapic.c =
linux-2.6.6-rc1-changed/arch/ia64/kernel/iosapic.c=0A=
--- linux-2.6.6-rc1/arch/ia64/kernel/iosapic.c	2004-04-19 =
16:10:25.970346988 +0900=0A=
+++ linux-2.6.6-rc1-changed/arch/ia64/kernel/iosapic.c	2004-04-19 =
16:25:23.251036926 +0900=0A=
@@ -101,15 +101,23 @@=0A=
 =0A=
 /* These tables map IA-64 vectors to the IOSAPIC pin that generates =
this vector. */=0A=
 =0A=
-static struct iosapic_intr_info {=0A=
+struct iosapic_pin {=0A=
+	struct list_head pin_list;	/* IOSAPIC pins which share the same vector =
*/=0A=
 	char		*addr;		/* base address of IOSAPIC */=0A=
 	u32		low32;		/* current value of low word of Redirection table entry */=0A=
 	unsigned int	gsi_base;	/* first GSI assigned to this IOSAPIC */=0A=
-	char		rte_index;	/* IOSAPIC RTE index (-1 =3D> not an IOSAPIC =
interrupt) */=0A=
-	unsigned char	dmode	: 3;	/* delivery mode (see iosapic.h) */=0A=
+	char		rte_index;	/* IOSAPIC RTE index */=0A=
 	unsigned char 	polarity: 1;	/* interrupt polarity (see iosapic.h) */=0A=
+};=0A=
+=0A=
+static struct iosapic_intr_info {=0A=
+	struct list_head pin_head;	/* List head of IOSAPIC pins */=0A=
+	struct iosapic_pin pin;		/* First entry of IOSAPIC pins list */=0A=
+	int		count;		/* # of pins (0 =3D> not an IOSAPIC interrupt) */=0A=
+	unsigned char	dmode	: 3;	/* delivery mode (see iosapic.h) */=0A=
 	unsigned char	trigger	: 1;	/* trigger mode (see iosapic.h) */=0A=
-} iosapic_intr_info[IA64_NUM_VECTORS];=0A=
+	unsigned char	type	: 1;	/* Vector type */=0A=
+} iosapic_intr_info[IA64_NUM_VECTORS] __cacheline_aligned;=0A=
 =0A=
 static struct iosapic {=0A=
 	char		*addr;		/* base address of IOSAPIC */=0A=
@@ -142,10 +150,14 @@=0A=
 _gsi_to_vector (unsigned int gsi)=0A=
 {=0A=
 	struct iosapic_intr_info *info;=0A=
+	struct iosapic_pin *pin;=0A=
 =0A=
-	for (info =3D iosapic_intr_info; info < iosapic_intr_info + =
IA64_NUM_VECTORS; ++info)=0A=
-		if (info->gsi_base + info->rte_index =3D=3D gsi)=0A=
-			return info - iosapic_intr_info;=0A=
+	for (info =3D iosapic_intr_info; info < iosapic_intr_info + =
IA64_NUM_VECTORS; ++info) {=0A=
+		list_for_each_entry(pin, &info->pin_head, pin_list) {=0A=
+			if (pin->gsi_base + pin->rte_index =3D=3D gsi)=0A=
+				return info - iosapic_intr_info;=0A=
+		}=0A=
+	}=0A=
 	return -1;=0A=
 }=0A=
 =0A=
@@ -177,15 +189,13 @@=0A=
 	char *addr;=0A=
 	int rte_index;=0A=
 	char redir;=0A=
+	struct iosapic_pin *pin;=0A=
 =0A=
 	DBG(KERN_DEBUG"IOSAPIC: routing vector %d to 0x%x\n", vector, dest);=0A=
 =0A=
-	rte_index =3D iosapic_intr_info[vector].rte_index;=0A=
-	if (rte_index < 0)=0A=
+	if (!iosapic_intr_info[vector].count)=0A=
 		return;		/* not an IOSAPIC interrupt */=0A=
 =0A=
-	addr    =3D iosapic_intr_info[vector].addr;=0A=
-	pol     =3D iosapic_intr_info[vector].polarity;=0A=
 	trigger =3D iosapic_intr_info[vector].trigger;=0A=
 	dmode   =3D iosapic_intr_info[vector].dmode;=0A=
 =0A=
@@ -193,31 +203,47 @@=0A=
 #ifdef CONFIG_SMP=0A=
 	{=0A=
 		unsigned int irq;=0A=
+		cpumask_t cpumask;=0A=
 =0A=
 		for (irq =3D 0; irq < NR_IRQS; ++irq)=0A=
 			if (irq_to_vector(irq) =3D=3D vector) {=0A=
-				set_irq_affinity_info(irq, (int)(dest & 0xffff), redir);=0A=
+				/* All pins should use the same destination CPU */=0A=
+				cpumask =3D get_irq_affinity_info(irq);=0A=
+				if (cpumask !=3D CPU_MASK_ALL)=0A=
+					dest =3D cpu_physical_id(first_cpu(mask));=0A=
+				else=0A=
+					set_irq_affinity_info(irq, (int)(dest & 0xffff), redir);=0A=
 				break;=0A=
 			}=0A=
 	}=0A=
 #endif=0A=
 =0A=
-	low32 =3D ((pol << IOSAPIC_POLARITY_SHIFT) |=0A=
-		 (trigger << IOSAPIC_TRIGGER_SHIFT) |=0A=
-		 (dmode << IOSAPIC_DELIVERY_SHIFT) |=0A=
-		 ((mask ? 1 : 0) << IOSAPIC_MASK_SHIFT) |=0A=
-		 vector);=0A=
-=0A=
 	/* dest contains both id and eid */=0A=
 	high32 =3D (dest << IOSAPIC_DEST_SHIFT);=0A=
 =0A=
 	spin_lock_irqsave(&iosapic_lock, flags);=0A=
 	{=0A=
-		writel(IOSAPIC_RTE_HIGH(rte_index), addr + IOSAPIC_REG_SELECT);=0A=
-		writel(high32, addr + IOSAPIC_WINDOW);=0A=
-		writel(IOSAPIC_RTE_LOW(rte_index), addr + IOSAPIC_REG_SELECT);=0A=
-		writel(low32, addr + IOSAPIC_WINDOW);=0A=
-		iosapic_intr_info[vector].low32 =3D low32;=0A=
+		list_for_each_entry(pin, &iosapic_intr_info[vector].pin_head, =
pin_list) {=0A=
+			/* Don't change RTE which is already unmasked */=0A=
+			if (!(pin->low32 & IOSAPIC_MASK))=0A=
+				continue;=0A=
+=0A=
+			rte_index =3D pin->rte_index;=0A=
+			addr    =3D pin->addr;=0A=
+			pol     =3D pin->polarity;=0A=
+=0A=
+			low32 =3D ((pol << IOSAPIC_POLARITY_SHIFT) |=0A=
+				 (trigger << IOSAPIC_TRIGGER_SHIFT) |=0A=
+				 (dmode << IOSAPIC_DELIVERY_SHIFT) |=0A=
+				 ((mask ? 1 : 0) << IOSAPIC_MASK_SHIFT) |=0A=
+				 vector);=0A=
+=0A=
+			writel(IOSAPIC_RTE_HIGH(rte_index), addr + IOSAPIC_REG_SELECT);=0A=
+			writel(high32, addr + IOSAPIC_WINDOW);=0A=
+			writel(IOSAPIC_RTE_LOW(rte_index), addr + IOSAPIC_REG_SELECT);=0A=
+			writel(low32, addr + IOSAPIC_WINDOW);=0A=
+			pin->low32 =3D low32;=0A=
+		}=0A=
 	}=0A=
 	spin_unlock_irqrestore(&iosapic_lock, flags);=0A=
 }=0A=
@@ -236,21 +262,24 @@=0A=
 	u32 low32;=0A=
 	int rte_index;=0A=
 	ia64_vector vec =3D irq_to_vector(irq);=0A=
+	struct iosapic_pin *pin;=0A=
 =0A=
-	addr =3D iosapic_intr_info[vec].addr;=0A=
-	rte_index =3D iosapic_intr_info[vec].rte_index;=0A=
-=0A=
-	if (rte_index < 0)=0A=
+	if (!iosapic_intr_info[vec].count)=0A=
 		return;			/* not an IOSAPIC interrupt! */=0A=
 =0A=
 	spin_lock_irqsave(&iosapic_lock, flags);=0A=
 	{=0A=
-		writel(IOSAPIC_RTE_LOW(rte_index), addr + IOSAPIC_REG_SELECT);=0A=
+		list_for_each_entry(pin, &iosapic_intr_info[vec].pin_head, pin_list) {=0A=
+			addr =3D pin->addr;=0A=
+			rte_index =3D pin->rte_index;=0A=
+			=0A=
+			writel(IOSAPIC_RTE_LOW(rte_index), addr + IOSAPIC_REG_SELECT);=0A=
 =0A=
-		/* set only the mask bit */=0A=
-		low32 =3D iosapic_intr_info[vec].low32 |=3D IOSAPIC_MASK;=0A=
+			/* set only the mask bit */=0A=
+			low32 =3D pin->low32 |=3D IOSAPIC_MASK;=0A=
 =0A=
-		writel(low32, addr + IOSAPIC_WINDOW);=0A=
+			writel(low32, addr + IOSAPIC_WINDOW);=0A=
+		}=0A=
 	}=0A=
 	spin_unlock_irqrestore(&iosapic_lock, flags);=0A=
 }=0A=
@@ -263,17 +292,21 @@=0A=
 	u32 low32;=0A=
 	int rte_index;=0A=
 	ia64_vector vec =3D irq_to_vector(irq);=0A=
+	struct iosapic_pin *pin;=0A=
 =0A=
-	addr =3D iosapic_intr_info[vec].addr;=0A=
-	rte_index =3D iosapic_intr_info[vec].rte_index;=0A=
-	if (rte_index < 0)=0A=
+	if (!iosapic_intr_info[vec].count)=0A=
 		return;			/* not an IOSAPIC interrupt! */=0A=
 =0A=
 	spin_lock_irqsave(&iosapic_lock, flags);=0A=
 	{=0A=
-		writel(IOSAPIC_RTE_LOW(rte_index), addr + IOSAPIC_REG_SELECT);=0A=
-		low32 =3D iosapic_intr_info[vec].low32 &=3D ~IOSAPIC_MASK;=0A=
-		writel(low32, addr + IOSAPIC_WINDOW);=0A=
+		list_for_each_entry(pin, &iosapic_intr_info[vec].pin_head, pin_list) {=0A=
+			addr =3D pin->addr;=0A=
+			rte_index =3D pin->rte_index;=0A=
+=0A=
+			writel(IOSAPIC_RTE_LOW(rte_index), addr + IOSAPIC_REG_SELECT);=0A=
+			low32 =3D pin->low32 &=3D ~IOSAPIC_MASK;=0A=
+			writel(low32, addr + IOSAPIC_WINDOW);=0A=
+		}=0A=
 	}=0A=
 	spin_unlock_irqrestore(&iosapic_lock, flags);=0A=
 }=0A=
@@ -289,6 +322,7 @@=0A=
 	char *addr;=0A=
 	int redir =3D (irq & IA64_IRQ_REDIRECTED) ? 1 : 0;=0A=
 	ia64_vector vec;=0A=
+	struct iosapic_pin *pin;=0A=
 =0A=
 	irq &=3D (~IA64_IRQ_REDIRECTED);=0A=
 	vec =3D irq_to_vector(irq);=0A=
@@ -298,10 +332,7 @@=0A=
 =0A=
 	dest =3D cpu_physical_id(first_cpu(mask));=0A=
 =0A=
-	rte_index =3D iosapic_intr_info[vec].rte_index;=0A=
-	addr =3D iosapic_intr_info[vec].addr;=0A=
-=0A=
-	if (rte_index < 0)=0A=
+	if (!iosapic_intr_info[vec].count)=0A=
 		return;			/* not an IOSAPIC interrupt */=0A=
 =0A=
 	set_irq_affinity_info(irq, dest, redir);=0A=
@@ -311,21 +342,26 @@=0A=
 =0A=
 	spin_lock_irqsave(&iosapic_lock, flags);=0A=
 	{=0A=
-		/* get current delivery mode by reading the low32 */=0A=
-		writel(IOSAPIC_RTE_LOW(rte_index), addr + IOSAPIC_REG_SELECT);=0A=
-		low32 =3D iosapic_intr_info[vec].low32 & ~(7 << =
IOSAPIC_DELIVERY_SHIFT);=0A=
-		if (redir)=0A=
-		        /* change delivery mode to lowest priority */=0A=
-			low32 |=3D (IOSAPIC_LOWEST_PRIORITY << IOSAPIC_DELIVERY_SHIFT);=0A=
-		else=0A=
-		        /* change delivery mode to fixed */=0A=
-			low32 |=3D (IOSAPIC_FIXED << IOSAPIC_DELIVERY_SHIFT);=0A=
-=0A=
-		iosapic_intr_info[vec].low32 =3D low32;=0A=
-		writel(IOSAPIC_RTE_HIGH(rte_index), addr + IOSAPIC_REG_SELECT);=0A=
-		writel(high32, addr + IOSAPIC_WINDOW);=0A=
-		writel(IOSAPIC_RTE_LOW(rte_index), addr + IOSAPIC_REG_SELECT);=0A=
-		writel(low32, addr + IOSAPIC_WINDOW);=0A=
+		list_for_each_entry(pin, &iosapic_intr_info[vec].pin_head, pin_list) {=0A=
+			rte_index =3D pin->rte_index;=0A=
+			addr =3D pin->addr;=0A=
+=0A=
+			/* get current delivery mode by reading the low32 */=0A=
+			writel(IOSAPIC_RTE_LOW(rte_index), addr + IOSAPIC_REG_SELECT);=0A=
+			low32 =3D pin->low32 & ~(7 << IOSAPIC_DELIVERY_SHIFT);=0A=
+			if (redir)=0A=
+				/* change delivery mode to lowest priority */=0A=
+				low32 |=3D (IOSAPIC_LOWEST_PRIORITY << IOSAPIC_DELIVERY_SHIFT);=0A=
+			else=0A=
+				/* change delivery mode to fixed */=0A=
+				low32 |=3D (IOSAPIC_FIXED << IOSAPIC_DELIVERY_SHIFT);=0A=
+=0A=
+			pin->low32 =3D low32;=0A=
+			writel(IOSAPIC_RTE_HIGH(rte_index), addr + IOSAPIC_REG_SELECT);=0A=
+			writel(high32, addr + IOSAPIC_WINDOW);=0A=
+			writel(IOSAPIC_RTE_LOW(rte_index), addr + IOSAPIC_REG_SELECT);=0A=
+			writel(low32, addr + IOSAPIC_WINDOW);=0A=
+		}=0A=
 	}=0A=
 	spin_unlock_irqrestore(&iosapic_lock, flags);=0A=
 #endif=0A=
@@ -346,8 +382,11 @@=0A=
 iosapic_end_level_irq (unsigned int irq)=0A=
 {=0A=
 	ia64_vector vec =3D irq_to_vector(irq);=0A=
+	struct iosapic_pin *pin;=0A=
 =0A=
-	writel(vec, iosapic_intr_info[vec].addr + IOSAPIC_EOI);=0A=
+	list_for_each_entry(pin, &iosapic_intr_info[vec].pin_head, pin_list) {=0A=
+		writel(vec, pin->addr + IOSAPIC_EOI);=0A=
+	}=0A=
 }=0A=
 =0A=
 #define iosapic_shutdown_level_irq	mask_irq=0A=
@@ -427,6 +466,30 @@=0A=
 }=0A=
 =0A=
 /*=0A=
+ * Find a sharable vector.=0A=
+ *=0A=
+ * NOTE: This function assumes that platform interrupt doesn't share=0A=
+ * the vector.=0A=
+ */=0A=
+static int=0A=
+iosapic_find_sharable_vector (unsigned long trigger)=0A=
+{=0A=
+	int i;=0A=
+	static int next_vector =3D IA64_FIRST_DEVICE_VECTOR;=0A=
+=0A=
+	for (i =3D 0; i < IA64_LAST_DEVICE_VECTOR - IA64_FIRST_DEVICE_VECTOR + =
1; i++) {=0A=
+		if (next_vector > IA64_LAST_DEVICE_VECTOR)=0A=
+			next_vector =3D IA64_FIRST_DEVICE_VECTOR;=0A=
+=0A=
+		if (iosapic_intr_info[next_vector].type =3D=3D =
IOSAPIC_VECTOR_SHARABLE &&=0A=
+		    iosapic_intr_info[next_vector].trigger =3D=3D trigger)=0A=
+			return next_vector++;=0A=
+	}=0A=
+=0A=
+	return -1;=0A=
+}=0A=
+=0A=
+/*=0A=
  * if the given vector is already owned by other,=0A=
  *  assign a new vector for the other and make the vector available=0A=
  */=0A=
@@ -435,22 +498,20 @@=0A=
 {=0A=
 	int new_vector;=0A=
 =0A=
-	if (iosapic_intr_info[vector].rte_index >=3D 0 || =
iosapic_intr_info[vector].addr=0A=
-	    || iosapic_intr_info[vector].gsi_base || =
iosapic_intr_info[vector].dmode=0A=
-	    || iosapic_intr_info[vector].polarity || =
iosapic_intr_info[vector].trigger)=0A=
+	if (!iosapic_intr_info[vector].count)=0A=
 	{=0A=
 		new_vector =3D assign_irq_vector(AUTO_ASSIGN);=0A=
 		printk(KERN_INFO "Reassigning vector %d to %d\n", vector, new_vector);=0A=
 		memcpy(&iosapic_intr_info[new_vector], &iosapic_intr_info[vector],=0A=
 		       sizeof(struct iosapic_intr_info));=0A=
 		memset(&iosapic_intr_info[vector], 0, sizeof(struct =
iosapic_intr_info));=0A=
-		iosapic_intr_info[vector].rte_index =3D -1;=0A=
+		INIT_LIST_HEAD(&iosapic_intr_info[vector].pin_head);=0A=
 	}=0A=
 }=0A=
 =0A=
 static void=0A=
 register_intr (unsigned int gsi, int vector, unsigned char delivery,=0A=
-	       unsigned long polarity, unsigned long trigger)=0A=
+	       unsigned long polarity, unsigned long trigger, unsigned long =
type)=0A=
 {=0A=
 	irq_desc_t *idesc;=0A=
 	struct hw_interrupt_type *irq_type;=0A=
@@ -458,6 +519,7 @@=0A=
 	int index;=0A=
 	unsigned long gsi_base;=0A=
 	char *iosapic_address;=0A=
+	struct iosapic_pin *pin, *tmp;=0A=
 =0A=
 	index =3D find_iosapic(gsi);=0A=
 	if (index < 0) {=0A=
@@ -468,13 +530,86 @@=0A=
 	iosapic_address =3D iosapic_lists[index].addr;=0A=
 	gsi_base =3D iosapic_lists[index].gsi_base;=0A=
 =0A=
-	rte_index =3D gsi - gsi_base;=0A=
-	iosapic_intr_info[vector].rte_index =3D rte_index;=0A=
-	iosapic_intr_info[vector].polarity =3D polarity;=0A=
-	iosapic_intr_info[vector].dmode    =3D delivery;=0A=
-	iosapic_intr_info[vector].addr     =3D iosapic_address;=0A=
-	iosapic_intr_info[vector].gsi_base =3D gsi_base;=0A=
-	iosapic_intr_info[vector].trigger  =3D trigger;=0A=
+	/*=0A=
+	 * Only interrupt sources whose delivery mode is =
IOSAPIC_LOWEST_PRIORITY or=0A=
+	 * IOSAPIC_FIXED can share the vector in the current implementation.=0A=
+	 */=0A=
+	if (delivery !=3D IOSAPIC_LOWEST_PRIORITY &&=0A=
+	    delivery !=3D IOSAPIC_FIXED &&=0A=
+	    type !=3D IOSAPIC_VECTOR_EXCLUSIVE)=0A=
+	{=0A=
+		type =3D IOSAPIC_VECTOR_EXCLUSIVE;=0A=
+	}=0A=
+=0A=
+	pin =3D NULL;=0A=
+	list_for_each_entry(tmp, &iosapic_intr_info[vector].pin_head, =
pin_list) {=0A=
+		if (tmp->gsi_base + tmp->rte_index =3D=3D gsi) {=0A=
+			pin =3D tmp;=0A=
+			break;=0A=
+		}=0A=
+	}=0A=
+=0A=
+	if (!pin) {=0A=
+		/*=0A=
+		 * Register a new interrupt=0A=
+		 */=0A=
+		if (!iosapic_intr_info[vector].count) {=0A=
+			pin =3D &iosapic_intr_info[vector].pin;=0A=
+			iosapic_intr_info[vector].dmode   =3D delivery;=0A=
+			iosapic_intr_info[vector].trigger =3D trigger;=0A=
+			iosapic_intr_info[vector].type    =3D type;=0A=
+		}=0A=
+		else if (type =3D=3D IOSAPIC_VECTOR_EXCLUSIVE) {=0A=
+			printk (KERN_WARNING "%s: vector %d is in use\n", __FUNCTION__, =
vector);=0A=
+			return;=0A=
+		}=0A=
+		else if (iosapic_intr_info[vector].type =3D=3D =
IOSAPIC_VECTOR_EXCLUSIVE) {=0A=
+			printk (KERN_WARNING "%s: cannot share the vector %d\n", =
__FUNCTION__, vector);=0A=
+			return;=0A=
+		}=0A=
+		else {=0A=
+			pin =3D kmalloc(sizeof(struct iosapic_pin), GFP_KERNEL);=0A=
+			if (!pin) {=0A=
+				printk (KERN_WARNING "%s: cannot allocate memory\n", __FUNCTION__);=0A=
+				return;=0A=
+			}=0A=
+		}=0A=
+		=0A=
+		rte_index =3D gsi - gsi_base;=0A=
+		pin->rte_index =3D rte_index;=0A=
+		pin->polarity =3D polarity;=0A=
+		pin->addr     =3D iosapic_address;=0A=
+		pin->gsi_base =3D gsi_base;=0A=
+		pin->low32    =3D IOSAPIC_MASK;=0A=
+=0A=
+		list_add_tail(&pin->pin_list, &iosapic_intr_info[vector].pin_head);=0A=
+		iosapic_intr_info[vector].count++;=0A=
+	}=0A=
+	else {=0A=
+		/*=0A=
+		 * Override a existing interupt=0A=
+		 */=0A=
+		if (iosapic_intr_info[vector].count > 1) {=0A=
+			if (iosapic_intr_info[vector].trigger !=3D trigger) {=0A=
+				printk (KERN_WARNING "%s: cannot change trigger mode\n", =
__FUNCTION__);=0A=
+				return;=0A=
+			}=0A=
+			if (type =3D=3D IOSAPIC_VECTOR_EXCLUSIVE) {=0A=
+				printk (KERN_WARNING "%s: vector %d is already shared\n", =
__FUNCTION__, vector);=0A=
+				return;=0A=
+			}=0A=
+		}=0A=
+=0A=
+		rte_index =3D gsi - gsi_base;=0A=
+		pin->rte_index =3D rte_index;=0A=
+		pin->polarity =3D polarity;=0A=
+		pin->addr     =3D iosapic_address;=0A=
+		pin->gsi_base =3D gsi_base;=0A=
+		pin->low32    =3D IOSAPIC_MASK;=0A=
+		iosapic_intr_info[vector].dmode   =3D delivery;=0A=
+		iosapic_intr_info[vector].trigger =3D trigger;=0A=
+		iosapic_intr_info[vector].type    =3D type;=0A=
+	}=0A=
 =0A=
 	if (trigger =3D=3D IOSAPIC_EDGE)=0A=
 		irq_type =3D &irq_type_iosapic_edge;=0A=
@@ -504,10 +639,17 @@=0A=
 =0A=
 	vector =3D gsi_to_vector(gsi);=0A=
 	if (vector < 0)=0A=
-		vector =3D assign_irq_vector(AUTO_ASSIGN);=0A=
+		vector =3D assign_irq_vector_nopanic(AUTO_ASSIGN);=0A=
+=0A=
+	if (vector < 0)=0A=
+		vector =3D iosapic_find_sharable_vector(trigger);=0A=
+=0A=
+	if (vector < 0)=0A=
+		panic ("%s: out of interrupt vectors!", __FUNCTION__);=0A=
 =0A=
 	register_intr(gsi, vector, IOSAPIC_LOWEST_PRIORITY,=0A=
-		      polarity, trigger);=0A=
+		      polarity, trigger,=0A=
+		      (trigger =3D=3D IOSAPIC_EDGE ? IOSAPIC_VECTOR_EXCLUSIVE : =
IOSAPIC_VECTOR_SHARABLE));=0A=
 =0A=
 	printk(KERN_INFO "GSI 0x%x(%s,%s) -> CPU 0x%04x vector %d\n",=0A=
 	       gsi, (polarity =3D=3D IOSAPIC_POL_HIGH ? "high" : "low"),=0A=
@@ -555,7 +697,7 @@=0A=
 	}=0A=
 =0A=
 	register_intr(gsi, vector, delivery, polarity,=0A=
-		      trigger);=0A=
+		      trigger, IOSAPIC_VECTOR_EXCLUSIVE);=0A=
 =0A=
 	printk(KERN_INFO "PLATFORM int 0x%x: GSI 0x%x(%s,%s) -> CPU 0x%04x =
vector %d\n",=0A=
 	       int_type, gsi, (polarity =3D=3D IOSAPIC_POL_HIGH ? "high" : =
"low"),=0A=
@@ -581,7 +723,7 @@=0A=
 =0A=
 	vector =3D isa_irq_to_vector(isa_irq);=0A=
 =0A=
-	register_intr(gsi, vector, IOSAPIC_LOWEST_PRIORITY, polarity, trigger);=0A=
+	register_intr(gsi, vector, IOSAPIC_LOWEST_PRIORITY, polarity, trigger, =
IOSAPIC_VECTOR_EXCLUSIVE);=0A=
 =0A=
 	DBG("ISA: IRQ %u -> GSI 0x%x (%s,%s) -> CPU 0x%04x vector %d\n",=0A=
 	    isa_irq, gsi, polarity =3D=3D IOSAPIC_POL_HIGH ? "high" : "low",=0A=
@@ -596,8 +738,10 @@=0A=
 {=0A=
 	int vector;=0A=
 =0A=
-	for (vector =3D 0; vector < IA64_NUM_VECTORS; ++vector)=0A=
-		iosapic_intr_info[vector].rte_index =3D -1;	/* mark as unused */=0A=
+	for (vector =3D 0; vector < IA64_NUM_VECTORS; ++vector) {=0A=
+		iosapic_intr_info[vector].count =3D 0;	/* mark as unused */=0A=
+		INIT_LIST_HEAD(&iosapic_intr_info[vector].pin_head);=0A=
+	}=0A=
 =0A=
 	pcat_compat =3D system_pcat_compat;=0A=
 	if (pcat_compat) {=0A=
@@ -710,12 +854,17 @@=0A=
 			/* allocate a vector for this interrupt line */=0A=
 			if (pcat_compat && (gsi < 16))=0A=
 				vector =3D isa_irq_to_vector(gsi);=0A=
-			else=0A=
+			else {=0A=
 				/* new GSI; allocate a vector for it */=0A=
-				vector =3D assign_irq_vector(AUTO_ASSIGN);=0A=
+				vector =3D assign_irq_vector_nopanic(AUTO_ASSIGN);=0A=
+				if (vector < 0)=0A=
+					vector =3D iosapic_find_sharable_vector(IOSAPIC_LEVEL);=0A=
+				if (vector < 0)=0A=
+					panic ("%s: out of interrupt vectors!", __FUNCTION__);=0A=
+			}=0A=
 =0A=
 			register_intr(gsi, vector, IOSAPIC_LOWEST_PRIORITY, IOSAPIC_POL_LOW,=0A=
-				      IOSAPIC_LEVEL);=0A=
+				      IOSAPIC_LEVEL, IOSAPIC_VECTOR_SHARABLE);=0A=
 		}=0A=
 		entry->irq =3D vector;=0A=
 		snprintf(pci_id, sizeof(pci_id), "%02x:%02x:%02x[%c]",=0A=
@@ -728,7 +877,7 @@=0A=
 		idesc =3D irq_descp(vector);=0A=
 		if (idesc->handler !=3D irq_type)=0A=
 			register_intr(gsi, vector, IOSAPIC_LOWEST_PRIORITY, IOSAPIC_POL_LOW,=0A=
-				      IOSAPIC_LEVEL);=0A=
+				      IOSAPIC_LEVEL, IOSAPIC_VECTOR_SHARABLE);=0A=
 =0A=
 	}=0A=
 }=0A=
diff -Naur linux-2.6.6-rc1/arch/ia64/kernel/irq.c =
linux-2.6.6-rc1-changed/arch/ia64/kernel/irq.c=0A=
--- linux-2.6.6-rc1/arch/ia64/kernel/irq.c	2004-04-04 12:38:13.000000000 =
+0900=0A=
+++ linux-2.6.6-rc1-changed/arch/ia64/kernel/irq.c	2004-04-19 =
16:10:53.513448673 +0900=0A=
@@ -935,6 +935,11 @@=0A=
 	}=0A=
 }=0A=
 =0A=
+cpumask_t get_irq_affinity_info (unsigned int irq)=0A=
+{=0A=
+	return irq_affinity[irq];=0A=
+}=0A=
+=0A=
 static int irq_affinity_read_proc (char *page, char **start, off_t off,=0A=
 			int count, int *eof, void *data)=0A=
 {=0A=
diff -Naur linux-2.6.6-rc1/arch/ia64/kernel/irq_ia64.c =
linux-2.6.6-rc1-changed/arch/ia64/kernel/irq_ia64.c=0A=
--- linux-2.6.6-rc1/arch/ia64/kernel/irq_ia64.c	2004-04-19 =
16:10:25.971323555 +0900=0A=
+++ linux-2.6.6-rc1-changed/arch/ia64/kernel/irq_ia64.c	2004-04-19 =
16:10:53.513448673 +0900=0A=
@@ -72,17 +72,25 @@=0A=
 	preempt_enable_no_resched();=0A=
 }=0A=
 =0A=
+static int next_vector =3D IA64_FIRST_DEVICE_VECTOR;=0A=
+=0A=
 int=0A=
 assign_irq_vector (int irq)=0A=
 {=0A=
-	static int next_vector =3D IA64_FIRST_DEVICE_VECTOR;=0A=
-=0A=
 	if (next_vector > IA64_LAST_DEVICE_VECTOR)=0A=
 		/* XXX could look for sharable vectors instead of panic'ing... */=0A=
 		panic("assign_irq_vector: out of interrupt vectors!");=0A=
 	return next_vector++;=0A=
 }=0A=
 =0A=
+int=0A=
+assign_irq_vector_nopanic (int irq)=0A=
+{=0A=
+	if (next_vector > IA64_LAST_DEVICE_VECTOR)=0A=
+		return -1;=0A=
+	return next_vector++;=0A=
+}=0A=
+=0A=
 extern unsigned int do_IRQ(unsigned long irq, struct pt_regs *regs);=0A=
 =0A=
 /*=0A=
diff -Naur linux-2.6.6-rc1/include/asm-ia64/hw_irq.h =
linux-2.6.6-rc1-changed/include/asm-ia64/hw_irq.h=0A=
--- linux-2.6.6-rc1/include/asm-ia64/hw_irq.h	2004-04-19 =
16:10:27.139297942 +0900=0A=
+++ linux-2.6.6-rc1-changed/include/asm-ia64/hw_irq.h	2004-04-19 =
16:10:53.514425240 +0900=0A=
@@ -83,6 +83,7 @@=0A=
 extern struct hw_interrupt_type irq_type_ia64_lsapic;	/* CPU-internal =
interrupt controller */=0A=
 =0A=
 extern int assign_irq_vector (int irq);	/* allocate a free vector */=0A=
+extern int assign_irq_vector_nopanic (int irq);=0A=
 extern void ia64_send_ipi (int cpu, int vector, int delivery_mode, int =
redirect);=0A=
 extern void register_percpu_irq (ia64_vector vec, struct irqaction =
*action);=0A=
 =0A=
diff -Naur linux-2.6.6-rc1/include/asm-ia64/iosapic.h =
linux-2.6.6-rc1-changed/include/asm-ia64/iosapic.h=0A=
--- linux-2.6.6-rc1/include/asm-ia64/iosapic.h	2004-04-04 =
12:37:23.000000000 +0900=0A=
+++ linux-2.6.6-rc1-changed/include/asm-ia64/iosapic.h	2004-04-19 =
16:10:53.514425240 +0900=0A=
@@ -49,6 +49,12 @@=0A=
 #define	IOSAPIC_MASK_SHIFT		16=0A=
 #define	IOSAPIC_MASK			(1<<IOSAPIC_MASK_SHIFT)=0A=
 =0A=
+/*=0A=
+ * Vector type=0A=
+ */=0A=
+#define IOSAPIC_VECTOR_EXCLUSIVE	(0)=0A=
+#define IOSAPIC_VECTOR_SHARABLE		(1)=0A=
+=0A=
 #ifndef __ASSEMBLY__=0A=
 =0A=
 #ifdef CONFIG_IOSAPIC=0A=
diff -Naur linux-2.6.6-rc1/include/asm-ia64/irq.h =
linux-2.6.6-rc1-changed/include/asm-ia64/irq.h=0A=
--- linux-2.6.6-rc1/include/asm-ia64/irq.h	2004-04-19 16:10:27.140274509 =
+0900=0A=
+++ linux-2.6.6-rc1-changed/include/asm-ia64/irq.h	2004-04-19 =
16:10:53.514425240 +0900=0A=
@@ -29,6 +29,10 @@=0A=
 extern void disable_irq_nosync (unsigned int);=0A=
 extern void enable_irq (unsigned int);=0A=
 extern void set_irq_affinity_info (unsigned int irq, int dest, int =
redir);=0A=
+#ifdef CONFIG_SMP=0A=
+#include <asm/cpumask.h>=0A=
+extern cpumask_t get_irq_affinity_info (unsigned int irq);=0A=
+#endif /* CONFIG_SMP */=0A=
 =0A=
 struct irqaction;=0A=
 struct pt_regs;=0A=

------=_NextPart_000_0011_01C4263C.894E2670--

