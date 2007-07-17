From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Date: Tue, 17 Jul 2007 12:22:23 +0000
Subject: [PATCH take3 8/12] Add mapping table between irq and vector
Message-Id: <469CB47F.70500@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Add mapping tables between irqs and vectors, and its management code.
This is necessary for supporting multiple vector domain because 1:1
mapping between irq and vector will be changed to n:1.

The irq = vector relationship between irqs and vectors is explicitly
remained for percpu interrupts, platform interrupts, isa IRQs and
vectors assigned using assign_irq_vector() because some programs might
depend on it.

And I should consider the following problem.

When pci drivers enabled/disabled devices dynamically, its irq number
is changed to the different one. Therefore, suspend/resume code may
happen problem.

To fix this problem, I bound gsi to irq.

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

 arch/ia64/kernel/iosapic.c  |   61 +++++++------
 arch/ia64/kernel/irq.c      |    2
 arch/ia64/kernel/irq_ia64.c |  199 ++++++++++++++++++++++++++++++++++++--------
 arch/ia64/kernel/smpboot.c  |    4
 include/asm-ia64/hw_irq.h   |   15 ++-
 5 files changed, 218 insertions(+), 63 deletions(-)

Index: linux-2.6.22/arch/ia64/kernel/irq_ia64.c
=================================--- linux-2.6.22.orig/arch/ia64/kernel/irq_ia64.c	2007-07-17 11:42:03.000000000 +0900
+++ linux-2.6.22/arch/ia64/kernel/irq_ia64.c	2007-07-17 12:08:13.000000000 +0900
@@ -46,6 +46,12 @@

 #define IRQ_DEBUG	0

+#define IRQ_VECTOR_UNASSIGNED	(0)
+
+#define IRQ_UNUSED		(0)
+#define IRQ_USED		(1)
+#define IRQ_RSVD		(2)
+
 /* These can be overridden in platform_irq_init */
 int ia64_first_device_vector = IA64_DEF_FIRST_DEVICE_VECTOR;
 int ia64_last_device_vector = IA64_DEF_LAST_DEVICE_VECTOR;
@@ -64,46 +70,161 @@ __u8 isa_irq_to_vector_map[16] = {
 };
 EXPORT_SYMBOL(isa_irq_to_vector_map);

-static unsigned long ia64_vector_mask[BITS_TO_LONGS(IA64_MAX_DEVICE_VECTORS)];
+DEFINE_SPINLOCK(vector_lock);
+
+struct irq_cfg irq_cfg[NR_IRQS] __read_mostly = {
+	[0 ... NR_IRQS - 1] = { .vector = IRQ_VECTOR_UNASSIGNED }
+};
+
+DEFINE_PER_CPU(int[IA64_NUM_VECTORS], vector_irq) = {
+	[0 ... IA64_NUM_VECTORS - 1] = IA64_SPURIOUS_INT_VECTOR
+};
+
+static int irq_status[NR_IRQS] = {
+	[0 ... NR_IRQS -1] = IRQ_UNUSED
+};
+
+int check_irq_used(int irq)
+{
+	if (irq_status[irq] = IRQ_USED)
+		return 1;
+
+	return -1;
+}
+
+static void reserve_irq(unsigned int irq)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&vector_lock, flags);
+	irq_status[irq] = IRQ_RSVD;
+	spin_unlock_irqrestore(&vector_lock, flags);
+}
+
+static inline int find_unassigned_irq(void)
+{
+	int irq;
+
+	for (irq = IA64_FIRST_DEVICE_VECTOR; irq < NR_IRQS; irq++)
+		if (irq_status[irq] = IRQ_UNUSED)
+			return irq;
+	return -ENOSPC;
+}
+
+static inline int find_unassigned_vector(void)
+{
+	int vector;
+
+	for (vector = IA64_FIRST_DEVICE_VECTOR;
+	     vector <= IA64_LAST_DEVICE_VECTOR; vector++)
+		if (__get_cpu_var(vector_irq[vector]) = IA64_SPURIOUS_INT_VECTOR)
+			return vector;
+	return -ENOSPC;
+}
+
+static int __bind_irq_vector(int irq, int vector)
+{
+	int cpu;
+
+	if (irq_to_vector(irq) = vector)
+		return 0;
+	if (irq_to_vector(irq) != IRQ_VECTOR_UNASSIGNED)
+		return -EBUSY;
+	for_each_online_cpu(cpu)
+		per_cpu(vector_irq, cpu)[vector] = irq;
+	irq_cfg[irq].vector = vector;
+	irq_status[irq] = IRQ_USED;
+	return 0;
+}
+
+int bind_irq_vector(int irq, int vector)
+{
+	unsigned long flags;
+	int ret;
+
+	spin_lock_irqsave(&vector_lock, flags);
+	ret = __bind_irq_vector(irq, vector);
+	spin_unlock_irqrestore(&vector_lock, flags);
+	return ret;
+}
+
+static void clear_irq_vector(int irq)
+{
+	unsigned long flags;
+	int vector, cpu;
+
+	spin_lock_irqsave(&vector_lock, flags);
+	BUG_ON((unsigned)irq >= NR_IRQS);
+	BUG_ON(irq_cfg[irq].vector = IRQ_VECTOR_UNASSIGNED);
+	vector = irq_cfg[irq].vector;
+	for_each_online_cpu(cpu)
+		per_cpu(vector_irq, cpu)[vector] = IA64_SPURIOUS_INT_VECTOR;
+	irq_cfg[irq].vector = IRQ_VECTOR_UNASSIGNED;
+	irq_status[irq] = IRQ_UNUSED;
+	spin_unlock_irqrestore(&vector_lock, flags);
+}

 int
 assign_irq_vector (int irq)
 {
-	int pos, vector;
- again:
-	pos = find_first_zero_bit(ia64_vector_mask, IA64_NUM_DEVICE_VECTORS);
-	vector = IA64_FIRST_DEVICE_VECTOR + pos;
-	if (vector > IA64_LAST_DEVICE_VECTOR)
-		return -ENOSPC;
-	if (test_and_set_bit(pos, ia64_vector_mask))
-		goto again;
+	unsigned long flags;
+	int vector = -ENOSPC;
+
+	if (irq < 0) {
+		goto out;
+	}
+	spin_lock_irqsave(&vector_lock, flags);
+	vector = find_unassigned_vector();
+	if (vector < 0)
+		goto out;
+	BUG_ON(__bind_irq_vector(irq, vector));
+	spin_unlock_irqrestore(&vector_lock, flags);
+ out:
 	return vector;
 }

 void
 free_irq_vector (int vector)
 {
-	int pos;
-
-	if (vector < IA64_FIRST_DEVICE_VECTOR || vector > IA64_LAST_DEVICE_VECTOR)
+	if (vector < IA64_FIRST_DEVICE_VECTOR ||
+	    vector > IA64_LAST_DEVICE_VECTOR)
 		return;
-
-	pos = vector - IA64_FIRST_DEVICE_VECTOR;
-	if (!test_and_clear_bit(pos, ia64_vector_mask))
-		printk(KERN_WARNING "%s: double free!\n", __FUNCTION__);
+	clear_irq_vector(vector);
 }

 int
 reserve_irq_vector (int vector)
 {
-	int pos;
-
 	if (vector < IA64_FIRST_DEVICE_VECTOR ||
 	    vector > IA64_LAST_DEVICE_VECTOR)
 		return -EINVAL;
+	return !!bind_irq_vector(vector, vector);
+}
+
+/*
+ * Initialize vector_irq on a new cpu. This function must be called
+ * with vector_lock held.
+ */
+void __setup_vector_irq(int cpu)
+{
+	int irq, vector;
+
+	/* Clear vector_irq */
+	for (vector = 0; vector < IA64_NUM_VECTORS; ++vector)
+		per_cpu(vector_irq, cpu)[vector] = IA64_SPURIOUS_INT_VECTOR;
+	/* Mark the inuse vectors */
+	for (irq = 0; irq < NR_IRQS; ++irq) {
+		if ((vector = irq_to_vector(irq)) != IRQ_VECTOR_UNASSIGNED)
+			per_cpu(vector_irq, cpu)[vector] = irq;
+	}
+}
+
+void destroy_and_reserve_irq(unsigned int irq)
+{
+	dynamic_irq_cleanup(irq);

-	pos = vector - IA64_FIRST_DEVICE_VECTOR;
-	return test_and_set_bit(pos, ia64_vector_mask);
+	clear_irq_vector(irq);
+	reserve_irq(irq);
 }

 /*
@@ -111,18 +232,29 @@ reserve_irq_vector (int vector)
  */
 int create_irq(void)
 {
-	int vector = assign_irq_vector(AUTO_ASSIGN);
+	unsigned long flags;
+	int irq, vector;

-	if (vector >= 0)
-		dynamic_irq_init(vector);
-
-	return vector;
+	irq = -ENOSPC;
+	spin_lock_irqsave(&vector_lock, flags);
+	vector = find_unassigned_vector();
+	if (vector < 0)
+		goto out;
+	irq = find_unassigned_irq();
+	if (irq < 0)
+		goto out;
+	BUG_ON(__bind_irq_vector(irq, vector));
+ out:
+	spin_unlock_irqrestore(&vector_lock, flags);
+	if (irq >= 0)
+		dynamic_irq_init(irq);
+	return irq;
 }

 void destroy_irq(unsigned int irq)
 {
 	dynamic_irq_cleanup(irq);
-	free_irq_vector(irq);
+	clear_irq_vector(irq);
 }

 #ifdef CONFIG_SMP
@@ -301,14 +433,13 @@ register_percpu_irq (ia64_vector vec, st
 	irq_desc_t *desc;
 	unsigned int irq;

-	for (irq = 0; irq < NR_IRQS; ++irq)
-		if (irq_to_vector(irq) = vec) {
-			desc = irq_desc + irq;
-			desc->status |= IRQ_PER_CPU;
-			desc->chip = &irq_type_ia64_lsapic;
-			if (action)
-				setup_irq(irq, action);
-		}
+	irq = vec;
+	BUG_ON(bind_irq_vector(irq, vec));
+	desc = irq_desc + irq;
+	desc->status |= IRQ_PER_CPU;
+	desc->chip = &irq_type_ia64_lsapic;
+	if (action)
+		setup_irq(irq, action);
 }

 void __init
Index: linux-2.6.22/arch/ia64/kernel/iosapic.c
=================================--- linux-2.6.22.orig/arch/ia64/kernel/iosapic.c	2007-07-17 11:42:03.000000000 +0900
+++ linux-2.6.22/arch/ia64/kernel/iosapic.c	2007-07-17 12:08:13.000000000 +0900
@@ -117,6 +117,9 @@ static DEFINE_SPINLOCK(iosapic_lock);
  * These tables map IA-64 vectors to the IOSAPIC pin that generates this
  * vector.
  */
+
+#define NO_REF_RTE	0
+
 static struct iosapic {
 	char __iomem	*addr;		/* base address of IOSAPIC */
 	unsigned int	gsi_base;	/* GSI base */
@@ -204,7 +207,7 @@ inline int
 gsi_to_vector (unsigned int gsi)
 {
 	int irq = __gsi_to_irq(gsi);
-	if (irq < 0)
+	if (check_irq_used(irq) < 0)
 		return -1;
 	return irq_to_vector(irq);
 }
@@ -619,14 +622,18 @@ register_intr (unsigned int gsi, int irq
 		iosapic_intr_info[irq].count++;
 		iosapic_lists[index].rtes_inuse++;
 	}
-	else if (irq_is_shared(irq)) {
+	else if (rte->refcnt = NO_REF_RTE) {
 		struct iosapic_intr_info *info = &iosapic_intr_info[irq];
-		if (info->trigger != trigger || info->polarity != polarity) {
+		if (info->count > 0 &&
+		    (info->trigger != trigger || info->polarity != polarity)){
 			printk (KERN_WARNING
 				"%s: cannot override the interrupt\n",
 				__FUNCTION__);
 			return -EINVAL;
 		}
+		rte->refcnt++;
+		iosapic_intr_info[irq].count++;
+		iosapic_lists[index].rtes_inuse++;
 	}

 	iosapic_intr_info[irq].polarity = polarity;
@@ -756,12 +763,17 @@ iosapic_register_intr (unsigned int gsi,
 	irq = __gsi_to_irq(gsi);
 	if (irq > 0) {
 		rte = find_rte(irq, gsi);
-		rte->refcnt++;
-		goto unlock_iosapic_lock;
-	}
+		if(iosapic_intr_info[irq].count = 0) {
+			assign_irq_vector(irq);
+			dynamic_irq_init(irq);
+		} else if (rte->refcnt != NO_REF_RTE) {
+			rte->refcnt++;
+			goto unlock_iosapic_lock;
+		}
+	} else
+		irq = create_irq();

 	/* If vector is running out, we try to find a sharable vector */
-	irq = create_irq();
 	if (irq < 0) {
 		irq = iosapic_find_sharable_irq(trigger, polarity);
 		if (irq < 0)
@@ -832,18 +844,14 @@ iosapic_unregister_intr (unsigned int gs
 	if (--rte->refcnt > 0)
 		goto out;

-	/* Remove the rte entry from the list */
 	idesc = irq_desc + irq;
-	spin_lock(&idesc->lock);
-	list_del(&rte->rte_list);
-	spin_unlock(&idesc->lock);
+	rte->refcnt = NO_REF_RTE;

 	/* Mask the interrupt */
 	low32 = iosapic_intr_info[irq].low32 | IOSAPIC_MASK;
 	iosapic_write(rte->iosapic, IOSAPIC_RTE_LOW(rte->rte_index), low32);

 	iosapic_intr_info[irq].count--;
-	iosapic_free_rte(rte);
 	index = find_iosapic(gsi);
 	iosapic_lists[index].rtes_inuse--;
 	WARN_ON(iosapic_lists[index].rtes_inuse < 0);
@@ -857,21 +865,20 @@ iosapic_unregister_intr (unsigned int gs
 	       (polarity = IOSAPIC_POL_HIGH ? "high" : "low"),
 	       cpu_logical_id(dest), dest, irq_to_vector(irq));

-	if (list_empty(&iosapic_intr_info[irq].rtes)) {
-		/* Sanity check */
-		BUG_ON(iosapic_intr_info[irq].count);
+	if (iosapic_intr_info[irq].count = 0) {
 #ifdef CONFIG_SMP
 		/* Clear affinity */
 		cpus_setall(idesc->affinity);
 #endif
 		/* Clear the interrupt information */
-		memset(&iosapic_intr_info[irq], 0,
-		       sizeof(struct iosapic_intr_info));
+		iosapic_intr_info[irq].dest = 0;
+		iosapic_intr_info[irq].dmode = 0;
+		iosapic_intr_info[irq].polarity = 0;
+		iosapic_intr_info[irq].trigger = 0;
 		iosapic_intr_info[irq].low32 |= IOSAPIC_MASK;
-		INIT_LIST_HEAD(&iosapic_intr_info[irq].rtes);

-		/* Destroy IRQ */
-		destroy_irq(irq);
+		/* Destroy and reserve IRQ */
+		destroy_and_reserve_irq(irq);
 	}
  out:
 	spin_unlock_irqrestore(&iosapic_lock, flags);
@@ -892,8 +899,8 @@ iosapic_register_platform_intr (u32 int_

 	switch (int_type) {
 	      case ACPI_INTERRUPT_PMI:
-		vector = iosapic_vector;
-		irq = vector;		/* FIXME */
+		irq = vector = iosapic_vector;
+		bind_irq_vector(irq, vector);
 		/*
 		 * since PMI vector is alloc'd by FW(ACPI) not by kernel,
 		 * we need to make sure the vector is available
@@ -909,8 +916,8 @@ iosapic_register_platform_intr (u32 int_
 		delivery = IOSAPIC_INIT;
 		break;
 	      case ACPI_INTERRUPT_CPEI:
-		vector = IA64_CPE_VECTOR;
-		irq = vector;		/* FIXME */
+		irq = vector = IA64_CPE_VECTOR;
+		BUG_ON(bind_irq_vector(irq, vector));
 		delivery = IOSAPIC_LOWEST_PRIORITY;
 		mask = 1;
 		break;
@@ -945,8 +952,8 @@ iosapic_override_isa_irq (unsigned int i
 	int vector, irq;
 	unsigned int dest = cpu_physical_id(smp_processor_id());

-	vector = isa_irq_to_vector(isa_irq);
-	irq = vector;	/* FIXME */
+	irq = vector = isa_irq_to_vector(isa_irq);
+	BUG_ON(bind_irq_vector(irq, vector));
 	register_intr(gsi, irq, IOSAPIC_LOWEST_PRIORITY, polarity, trigger);

 	DBG("ISA: IRQ %u -> GSI %u (%s,%s) -> CPU %d (0x%04x) vector %d\n",
@@ -966,6 +973,8 @@ iosapic_system_init (int system_pcat_com
 		iosapic_intr_info[irq].low32 = IOSAPIC_MASK;
 		/* mark as unused */
 		INIT_LIST_HEAD(&iosapic_intr_info[irq].rtes);
+
+		iosapic_intr_info[irq].count = 0;
 	}

 	pcat_compat = system_pcat_compat;
Index: linux-2.6.22/arch/ia64/kernel/irq.c
=================================--- linux-2.6.22.orig/arch/ia64/kernel/irq.c	2007-07-17 11:42:03.000000000 +0900
+++ linux-2.6.22/arch/ia64/kernel/irq.c	2007-07-17 11:42:10.000000000 +0900
@@ -35,7 +35,7 @@ void ack_bad_irq(unsigned int irq)
 #ifdef CONFIG_IA64_GENERIC
 unsigned int __ia64_local_vector_to_irq (ia64_vector vec)
 {
-	return (unsigned int) vec;
+	return __get_cpu_var(vector_irq)[vec];
 }
 #endif

Index: linux-2.6.22/arch/ia64/kernel/smpboot.c
=================================--- linux-2.6.22.orig/arch/ia64/kernel/smpboot.c	2007-07-17 11:42:03.000000000 +0900
+++ linux-2.6.22/arch/ia64/kernel/smpboot.c	2007-07-17 11:42:10.000000000 +0900
@@ -395,9 +395,13 @@ smp_callin (void)
 	fix_b0_for_bsp();

 	lock_ipi_calllock();
+	spin_lock(&vector_lock);
+	/* Setup the per cpu irq handling data structures */
+	__setup_vector_irq(cpuid);
 	cpu_set(cpuid, cpu_online_map);
 	unlock_ipi_calllock();
 	per_cpu(cpu_state, cpuid) = CPU_ONLINE;
+	spin_unlock(&vector_lock);

 	smp_setup_percpu_timer();

Index: linux-2.6.22/include/asm-ia64/hw_irq.h
=================================--- linux-2.6.22.orig/include/asm-ia64/hw_irq.h	2007-07-17 11:42:03.000000000 +0900
+++ linux-2.6.22/include/asm-ia64/hw_irq.h	2007-07-17 12:09:22.000000000 +0900
@@ -90,13 +90,24 @@ enum {
 extern __u8 isa_irq_to_vector_map[16];
 #define isa_irq_to_vector(x)	isa_irq_to_vector_map[(x)]

+struct irq_cfg {
+	ia64_vector vector;
+};
+extern spinlock_t vector_lock;
+extern struct irq_cfg irq_cfg[NR_IRQS];
+DECLARE_PER_CPU(int[IA64_NUM_VECTORS], vector_irq);
+
 extern struct hw_interrupt_type irq_type_ia64_lsapic;	/* CPU-internal interrupt controller */

+extern int bind_irq_vector(int irq, int vector);
 extern int assign_irq_vector (int irq);	/* allocate a free vector */
 extern void free_irq_vector (int vector);
 extern int reserve_irq_vector (int vector);
+extern void __setup_vector_irq(int cpu);
 extern void ia64_send_ipi (int cpu, int vector, int delivery_mode, int redirect);
 extern void register_percpu_irq (ia64_vector vec, struct irqaction *action);
+extern int check_irq_used (int irq);
+extern void destroy_and_reserve_irq (unsigned int irq);

 static inline void ia64_resend_irq(unsigned int vector)
 {
@@ -113,7 +124,7 @@ extern irq_desc_t irq_desc[NR_IRQS];
 static inline unsigned int
 __ia64_local_vector_to_irq (ia64_vector vec)
 {
-	return (unsigned int) vec;
+	return __get_cpu_var(vector_irq)[vec];
 }
 #endif

@@ -131,7 +142,7 @@ __ia64_local_vector_to_irq (ia64_vector
 static inline ia64_vector
 irq_to_vector (int irq)
 {
-	return (ia64_vector) irq;
+	return irq_cfg[irq].vector;
 }

 /*
