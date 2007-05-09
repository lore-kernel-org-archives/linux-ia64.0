From: Ishimatsu Yasuaki <isimatu.yasuaki@jp.fujitsu.com>
Date: Wed, 09 May 2007 07:55:40 +0000
Subject: [PATCH 8/12]  Add mapping table between irq and vector
Message-Id: <46417E7C.7030402@jp.fujitsu.com>
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

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

---
 arch/ia64/kernel/iosapic.c  |   12 +--
 arch/ia64/kernel/irq.c      |    2
 arch/ia64/kernel/irq_ia64.c |  162 ++++++++++++++++++++++++++++++++++----------
 arch/ia64/kernel/smpboot.c  |    4 +
 include/asm-ia64/hw_irq.h   |   13 ++-
 5 files changed, 150 insertions(+), 43 deletions(-)

Index: linux-2.6.21/arch/ia64/kernel/irq_ia64.c
=================================--- linux-2.6.21.orig/arch/ia64/kernel/irq_ia64.c	2007-04-26 12:08:32.000000000 +0900
+++ linux-2.6.21/arch/ia64/kernel/irq_ia64.c	2007-05-08 12:10:57.000000000 +0900
@@ -46,6 +46,9 @@

 #define IRQ_DEBUG	0

+#define IRQ_VECTOR_UNASSIGNED	(0)
+#define VECTOR_IRQ_UNASSIGNED	(-1)
+
 /* These can be overridden in platform_irq_init */
 int ia64_first_device_vector = IA64_DEF_FIRST_DEVICE_VECTOR;
 int ia64_last_device_vector = IA64_DEF_LAST_DEVICE_VECTOR;
@@ -64,46 +67,127 @@
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
+	[0 ... IA64_NUM_VECTORS - 1] = VECTOR_IRQ_UNASSIGNED
+};
+
+static inline int find_unassigned_irq(void)
+{
+	int irq;
+
+	for (irq = IA64_FIRST_DEVICE_VECTOR; irq < NR_IRQS; irq++)
+		if (irq_cfg[irq].vector = IRQ_VECTOR_UNASSIGNED)
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
+		if (__get_cpu_var(vector_irq[vector]) = VECTOR_IRQ_UNASSIGNED)
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
+		per_cpu(vector_irq, cpu)[vector] = VECTOR_IRQ_UNASSIGNED;
+	irq_cfg[irq].vector = IRQ_VECTOR_UNASSIGNED;
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
+	int vector;
+
+	spin_lock_irqsave(&vector_lock, flags);
+	vector = find_unassigned_vector();
+	if (vector < 0)
+		goto out;
+	BUG_ON(__bind_irq_vector(vector, vector));
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

-	pos = vector - IA64_FIRST_DEVICE_VECTOR;
-	return test_and_set_bit(pos, ia64_vector_mask);
+	/* Clear vector_irq */
+	for (vector = 0; vector < IA64_NUM_VECTORS; ++vector)
+		per_cpu(vector_irq, cpu)[vector] = VECTOR_IRQ_UNASSIGNED;
+	/* Mark the inuse vectors */
+	for (irq = 0; irq < NR_IRQS; ++irq) {
+		if ((vector = irq_to_vector(irq)) != IRQ_VECTOR_UNASSIGNED)
+			per_cpu(vector_irq, cpu)[vector] = irq;
+	}
 }

 /*
@@ -111,18 +195,29 @@
  */
 int create_irq(void)
 {
-	int vector = assign_irq_vector(AUTO_ASSIGN);
-
-	if (vector >= 0)
-		dynamic_irq_init(vector);
+	unsigned long flags;
+	int irq, vector;

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
@@ -286,14 +381,13 @@
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
Index: linux-2.6.21/arch/ia64/kernel/iosapic.c
=================================--- linux-2.6.21.orig/arch/ia64/kernel/iosapic.c	2007-05-08 12:10:09.000000000 +0900
+++ linux-2.6.21/arch/ia64/kernel/iosapic.c	2007-05-08 12:10:57.000000000 +0900
@@ -893,8 +893,8 @@

 	switch (int_type) {
 	      case ACPI_INTERRUPT_PMI:
-		vector = iosapic_vector;
-		irq = vector;		/* FIXME */
+		irq = vector = iosapic_vector;
+		bind_irq_vector(irq, vector);
 		/*
 		 * since PMI vector is alloc'd by FW(ACPI) not by kernel,
 		 * we need to make sure the vector is available
@@ -910,8 +910,8 @@
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
@@ -946,8 +946,8 @@
 	int vector, irq;
 	unsigned int dest = cpu_physical_id(smp_processor_id());

-	vector = isa_irq_to_vector(isa_irq);
-	irq = vector;	/* FIXME */
+	irq = vector = isa_irq_to_vector(isa_irq);
+	BUG_ON(bind_irq_vector(irq, vector));
 	register_intr(gsi, irq, IOSAPIC_LOWEST_PRIORITY, polarity, trigger);

 	DBG("ISA: IRQ %u -> GSI %u (%s,%s) -> CPU %d (0x%04x) vector %d\n",
Index: linux-2.6.21/arch/ia64/kernel/irq.c
=================================--- linux-2.6.21.orig/arch/ia64/kernel/irq.c	2007-04-26 12:08:32.000000000 +0900
+++ linux-2.6.21/arch/ia64/kernel/irq.c	2007-05-08 12:10:57.000000000 +0900
@@ -35,7 +35,7 @@
 #ifdef CONFIG_IA64_GENERIC
 unsigned int __ia64_local_vector_to_irq (ia64_vector vec)
 {
-	return (unsigned int) vec;
+	return __get_cpu_var(vector_irq)[vec];
 }
 #endif

Index: linux-2.6.21/arch/ia64/kernel/smpboot.c
=================================--- linux-2.6.21.orig/arch/ia64/kernel/smpboot.c	2007-04-26 12:08:32.000000000 +0900
+++ linux-2.6.21/arch/ia64/kernel/smpboot.c	2007-05-08 12:10:57.000000000 +0900
@@ -396,9 +396,13 @@
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

Index: linux-2.6.21/include/asm-ia64/hw_irq.h
=================================--- linux-2.6.21.orig/include/asm-ia64/hw_irq.h	2007-04-26 12:08:32.000000000 +0900
+++ linux-2.6.21/include/asm-ia64/hw_irq.h	2007-05-08 12:10:57.000000000 +0900
@@ -89,11 +89,20 @@
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

@@ -112,7 +121,7 @@
 static inline unsigned int
 __ia64_local_vector_to_irq (ia64_vector vec)
 {
-	return (unsigned int) vec;
+	return __get_cpu_var(vector_irq)[vec];
 }
 #endif

@@ -130,7 +139,7 @@
 static inline ia64_vector
 irq_to_vector (int irq)
 {
-	return (ia64_vector) irq;
+	return irq_cfg[irq].vector;
 }

 /*


