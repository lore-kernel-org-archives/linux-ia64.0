From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Thu, 14 Jul 2005 09:26:16 +0000
Subject: [RFC][patch 4/10] Multiple vector domain support - per domain vector
Message-Id: <42D62FB8.5090507@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


This patch adds the code to allocate vectors in each domains. This
patch also contains the basic code to eliminate identity mapping
between IA-64 vectors and linux IRQs.

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>

---

 linux-2.6.13-rc1-kanesige/arch/ia64/kernel/irq_ia64.c |  129 ++++++++++++++----
 linux-2.6.13-rc1-kanesige/include/asm-ia64/hw_irq.h   |    4 
 2 files changed, 107 insertions(+), 26 deletions(-)

diff -puN arch/ia64/kernel/irq_ia64.c~vector-domain-ia64-assign_irq_gsv arch/ia64/kernel/irq_ia64.c
--- linux-2.6.13-rc1/arch/ia64/kernel/irq_ia64.c~vector-domain-ia64-assign_irq_gsv	2005-07-13 14:51:42.000000000 +0900
+++ linux-2.6.13-rc1-kanesige/arch/ia64/kernel/irq_ia64.c	2005-07-13 16:12:35.000000000 +0900
@@ -63,44 +63,124 @@ EXPORT_SYMBOL(isa_irq_to_vector_map);
 int ia64_irq_to_gsv_map[NR_IRQS] = { [0 ... NR_IRQS-1] = -1 };
 int ia64_gsv_to_irq_map[NR_GSVS] = { [0 ... NR_GSVS-1] = -1 };
 
-static unsigned long ia64_vector_mask[BITS_TO_LONGS(IA64_NUM_DEVICE_VECTORS)];
+static unsigned long ia64_vector_mask[NR_VECTOR_DOMAINS][BITS_TO_LONGS(IA64_NUM_DEVICE_VECTORS)];
 
-int
-assign_irq_vector_nopanic (int irq)
+static int
+ia64_alloc_vector (unsigned int domain)
+{
+	int pos, vec;
+	do {
+		pos = find_first_zero_bit(ia64_vector_mask[domain],
+					  IA64_NUM_DEVICE_VECTORS);
+		vec = IA64_FIRST_DEVICE_VECTOR + pos;
+		if (vec > IA64_LAST_DEVICE_VECTOR)
+			return -ENOSPC;
+	} while (test_and_set_bit(pos, ia64_vector_mask[domain]));
+	return vec;
+}
+
+static void
+ia64_free_vector (unsigned int domain, unsigned int vector)
+{
+	int pos;
+
+	if (domain >= NR_VECTOR_DOMAINS ||
+	    vector < IA64_FIRST_DEVICE_VECTOR ||
+	    vector > IA64_LAST_DEVICE_VECTOR)
+		return;
+
+	pos = vector - IA64_FIRST_DEVICE_VECTOR;
+	if (!test_and_clear_bit(pos, ia64_vector_mask[domain]))
+		printk(KERN_WARNING "%s: double free vector!\n", __FUNCTION__);
+}
+
+static unsigned long ia64_irq_mask[BITS_TO_LONGS(NR_IRQS)];
+
+static int
+ia64_alloc_irq (void)
+{
+	int irq;
+	do {
+		irq = find_first_zero_bit(ia64_irq_mask, NR_IRQS);
+		if (irq > NR_IRQS)
+			return -1;
+	} while (test_and_set_bit(irq, ia64_irq_mask));
+	return irq;
+}
+
+static void
+ia64_free_irq (unsigned int irq)
+{
+	if (irq >= NR_IRQS)
+		return;
+
+	if (!test_and_clear_bit(irq, ia64_irq_mask))
+		printk(KERN_WARNING "%s: double free irq!\n", __FUNCTION__);
+}
+
+static int
+assign_irq_gsv_domain (int irq, int domain)
 {
-	int pos, vector;
- again:
-	pos = find_first_zero_bit(ia64_vector_mask, IA64_NUM_DEVICE_VECTORS);
-	vector = IA64_FIRST_DEVICE_VECTOR + pos;
-	if (vector > IA64_LAST_DEVICE_VECTOR)
-		return -1;
-	if (test_and_set_bit(pos, ia64_vector_mask))
-		goto again;
-	return vector;
+	int vector, gsv;
+
+	if ((vector = ia64_alloc_vector(domain)) < 0)
+		return -ENOSPC;
+
+	if ((irq = ia64_alloc_irq()) < 0) {
+		ia64_free_vector(domain, vector);
+		return -ENOSPC;
+	}
+
+	gsv = domain_vector_to_gsv(domain, vector);
+	ia64_irq_to_gsv_map[irq] = gsv;
+	ia64_gsv_to_irq_map[gsv] = irq;
+
+	return gsv;
 }
 
 int
-assign_irq_vector (int irq)
+assign_irq_gsv (int irq, int domain)
 {
-	int vector = assign_irq_vector_nopanic(irq);
+	static int next_domain = -1;
+	int i, gsv = -ENOSPC;
 
-	if (vector < 0)
-		panic("assign_irq_vector: out of interrupt vectors!");
+	if (domain = AUTO_ASSIGN) {
+		for (i = 0; i < NR_VECTOR_DOMAINS; i++) {
+			if (++next_domain >= NR_VECTOR_DOMAINS)
+				next_domain = 0;
+			if (!cpus_weight(ia64_domain_to_cpumask(next_domain)))
+				continue;
+			gsv = assign_irq_gsv_domain(irq, next_domain);
+			if (gsv >= 0)
+				break;
+		}
+	} else
+		gsv = assign_irq_gsv_domain(irq, domain);
 
-	return vector;
+	return gsv;
 }
 
 void
-free_irq_vector (int vector)
+free_irq_gsv (int gsv)
 {
-	int pos;
+	int vector, domain, irq = gsv_to_irq(gsv);
 
-	if (vector < IA64_FIRST_DEVICE_VECTOR || vector > IA64_LAST_DEVICE_VECTOR)
+	if (gsv >= NR_GSVS || irq > NR_IRQS)
 		return;
 
-	pos = vector - IA64_FIRST_DEVICE_VECTOR;
-	if (!test_and_clear_bit(pos, ia64_vector_mask))
-		printk(KERN_WARNING "%s: double free!\n", __FUNCTION__);
+	ia64_irq_to_gsv_map[irq] = -1;
+	ia64_gsv_to_irq_map[gsv] = -1;
+
+	vector = gsv_to_vector(gsv);
+	domain = gsv_to_domain(gsv);
+	ia64_free_vector(domain, vector);
+	ia64_free_irq(irq);
+}
+
+int
+assign_irq_vector (int irq)
+{
+	return gsv_to_vector(assign_irq_gsv(irq, 0));
 }
 
 #ifdef CONFIG_SMP
@@ -293,7 +373,7 @@ ia64_send_ipi (int cpu, int vector, int 
 void __init
 ia64_vector_domain_init (void)
 {
-	int domain, vec, gsv;
+	int vec, gsv;
 
 	/* Attach BSP to domain #0 */
 	ia64_attach_cpu_to_domain(0);
@@ -307,6 +387,7 @@ ia64_vector_domain_init (void)
 		    vec > IA64_LAST_DEVICE_VECTOR) {
 			ia64_gsv_to_irq_map[gsv] = vec;
 			ia64_irq_to_gsv_map[vec] = vec;
+			set_bit(vec, ia64_irq_mask);
 		}
 	}
 }
diff -puN include/asm-ia64/hw_irq.h~vector-domain-ia64-assign_irq_gsv include/asm-ia64/hw_irq.h
--- linux-2.6.13-rc1/include/asm-ia64/hw_irq.h~vector-domain-ia64-assign_irq_gsv	2005-07-13 14:51:42.000000000 +0900
+++ linux-2.6.13-rc1-kanesige/include/asm-ia64/hw_irq.h	2005-07-13 16:04:54.000000000 +0900
@@ -93,9 +93,9 @@ extern cpumask_t ia64_domain_cpumask[NR_
 
 extern struct hw_interrupt_type irq_type_ia64_lsapic;	/* CPU-internal interrupt controller */
 
-extern int assign_irq_vector_nopanic (int irq); /* allocate a free vector without panic */
 extern int assign_irq_vector (int irq);	/* allocate a free vector */
-extern void free_irq_vector (int vector);
+extern int assign_irq_gsv (int irq, int domain);
+extern void free_irq_gsv (int gsv);
 extern void ia64_send_ipi (int cpu, int vector, int delivery_mode, int redirect);
 extern void register_percpu_irq (ia64_vector vec, struct irqaction *action);
 extern void __init ia64_vector_domain_init(void);

_


