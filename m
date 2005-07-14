From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Thu, 14 Jul 2005 09:37:37 +0000
Subject: [RFC][patch 9/10] Multiple vector domain support - inter domain interrupt
Message-Id: <42D63261.6070208@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


This patch adds inter domain interrupt migration for IOSAPIC. This is
needed when all CPUs in the domain is hot-removed.

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>

---

 linux-2.6.13-rc1-kanesige/arch/ia64/kernel/iosapic.c  |   68 ++++++++++++------
 linux-2.6.13-rc1-kanesige/arch/ia64/kernel/irq_ia64.c |   36 ++++++++-
 linux-2.6.13-rc1-kanesige/include/asm-ia64/hw_irq.h   |    1 
 3 files changed, 83 insertions(+), 22 deletions(-)

diff -puN arch/ia64/kernel/iosapic.c~vector-domain-ia64-migrate-irq-domain arch/ia64/kernel/iosapic.c
--- linux-2.6.13-rc1/arch/ia64/kernel/iosapic.c~vector-domain-ia64-migrate-irq-domain	2005-07-13 16:12:53.000000000 +0900
+++ linux-2.6.13-rc1-kanesige/arch/ia64/kernel/iosapic.c	2005-07-13 16:12:53.000000000 +0900
@@ -311,6 +311,25 @@ unmask_irq (unsigned int irq)
 
 
 static void
+iosapic_move_gsv (unsigned int src, unsigned int dst)
+{
+	struct iosapic_intr_info *info_src = &iosapic_intr_info[src];
+	struct iosapic_intr_info *info_dst = &iosapic_intr_info[dst];
+	struct iosapic_rte_info *rte, *next;
+
+	memcpy(info_dst, info_src, sizeof(*info_dst));
+	info_dst->low32 &= ~0xff;
+	info_dst->low32 |= (ia64_vector)gsv_to_vector(dst);
+	INIT_LIST_HEAD(&info_dst->rtes);
+	list_for_each_entry_safe(rte, next, &info_src->rtes, rte_list)
+		list_move_tail(&rte->rte_list, &info_dst->rtes);
+	memset(info_src, 0, sizeof(*info_src));
+	info_src->low32 = IOSAPIC_MASK;
+	INIT_LIST_HEAD(&info_src->rtes);
+}
+
+
+static void
 iosapic_set_affinity (unsigned int irq, cpumask_t mask)
 {
 #ifdef CONFIG_SMP
@@ -331,15 +350,24 @@ iosapic_set_affinity (unsigned int irq, 
 	cpu = first_cpu(mask);
 	dest = cpu_physical_id(cpu);
 
-	/*
-	 * XXX - IRQ migration between different domains is not supported yet.
-	 */
-	if (!cpu_isset(cpu, ia64_domain_to_cpumask(gsv_to_domain(gsv))))
-		return;
-
 	if (list_empty(&iosapic_intr_info[gsv].rtes))
 		return;			/* not an IOSAPIC interrupt */
 
+	/*
+	 * IRQ migration between different domains
+	 */
+	if (!cpu_isset(cpu, ia64_domain_to_cpumask(gsv_to_domain(gsv)))) {
+		int src = gsv;
+		spin_lock_irqsave(&iosapic_lock, flags);
+		gsv = reassign_irq_gsv(irq, ia64_cpu_to_domain(cpu));
+		if (gsv < 0) {
+			spin_unlock_irqrestore(&iosapic_lock, flags);
+			return;
+		}
+		iosapic_move_gsv(src, gsv);
+		spin_unlock_irqrestore(&iosapic_lock, flags);
+	}
+
 	set_irq_affinity_info(irq, dest, redir);
 
 	/* dest contains both id and eid */
@@ -384,10 +412,17 @@ static void
 iosapic_end_level_irq (unsigned int irq)
 {
 	unsigned int gsv = irq_to_gsv(irq);
-	ia64_vector vec = gsv_to_vector(gsv);
+	ia64_vector vec;
 	struct iosapic_rte_info *rte;
 
 	move_irq(irq);
+	/*
+	 * In the case of irq migration to other domain, irq might be
+	 * associated to another gsv.
+	 */
+	gsv = irq_to_gsv(irq);
+	vec = gsv_to_vector(gsv);
+
 	list_for_each_entry(rte, &iosapic_intr_info[gsv].rtes, rte_list)
 		iosapic_eoi(rte->addr, vec);
 }
@@ -525,18 +560,13 @@ iosapic_reassign_gsv (unsigned int gsv)
 {
 	int new_gsv;
 
-	if (!list_empty(&iosapic_intr_info[gsv].rtes)) {
-		new_gsv = assign_irq_gsv(AUTO_ASSIGN, gsv_to_domain(gsv));
-		printk(KERN_INFO "Reassigning vector %d to %d\n",
-			gsv_to_vector(gsv), gsv_to_vector(new_gsv));
-		memcpy(&iosapic_intr_info[new_gsv], &iosapic_intr_info[gsv],
-		       sizeof(struct iosapic_intr_info));
-		INIT_LIST_HEAD(&iosapic_intr_info[new_gsv].rtes);
-		list_move(iosapic_intr_info[gsv].rtes.next, &iosapic_intr_info[new_gsv].rtes);
-		memset(&iosapic_intr_info[gsv], 0, sizeof(struct iosapic_intr_info));
-		iosapic_intr_info[gsv].low32 = IOSAPIC_MASK;
-		INIT_LIST_HEAD(&iosapic_intr_info[gsv].rtes);
-	}
+	if (list_empty(&iosapic_intr_info[gsv].rtes))
+		return;
+
+	new_gsv = assign_irq_gsv(AUTO_ASSIGN, gsv_to_domain(gsv));
+	printk(KERN_INFO "Reassigning vector %d to %d\n",
+	       gsv_to_vector(gsv), gsv_to_vector(new_gsv));
+	iosapic_move_gsv(gsv, new_gsv);
 }
 
 static struct iosapic_rte_info *iosapic_alloc_rte (void)
diff -puN arch/ia64/kernel/irq_ia64.c~vector-domain-ia64-migrate-irq-domain arch/ia64/kernel/irq_ia64.c
--- linux-2.6.13-rc1/arch/ia64/kernel/irq_ia64.c~vector-domain-ia64-migrate-irq-domain	2005-07-13 16:12:53.000000000 +0900
+++ linux-2.6.13-rc1-kanesige/arch/ia64/kernel/irq_ia64.c	2005-07-13 16:12:53.000000000 +0900
@@ -97,14 +97,21 @@ ia64_free_vector (unsigned int domain, u
 static unsigned long ia64_irq_mask[BITS_TO_LONGS(NR_IRQS)];
 
 static int
-ia64_alloc_irq (void)
+ia64_alloc_irq (int irq)
 {
-	int irq;
+	if (irq != AUTO_ASSIGN) {
+		if (!test_and_set_bit(irq, ia64_irq_mask))
+			return irq;
+		else
+			return -1;
+	}
+
 	do {
 		irq = find_first_zero_bit(ia64_irq_mask, NR_IRQS);
 		if (irq > NR_IRQS)
 			return -1;
 	} while (test_and_set_bit(irq, ia64_irq_mask));
+
 	return irq;
 }
 
@@ -126,7 +133,7 @@ assign_irq_gsv_domain (int irq, int doma
 	if ((vector = ia64_alloc_vector(domain)) < 0)
 		return -ENOSPC;
 
-	if ((irq = ia64_alloc_irq()) < 0) {
+	if ((irq = ia64_alloc_irq(irq)) < 0) {
 		ia64_free_vector(domain, vector);
 		return -ENOSPC;
 	}
@@ -178,6 +185,29 @@ free_irq_gsv (int gsv)
 }
 
 int
+reassign_irq_gsv (int irq, int domain)
+{
+	int new_vector, new_gsv, old_gsv, old_vector, old_domain;
+
+	new_vector = ia64_alloc_vector(domain);
+	if (new_vector < 0)
+		return -ENOSPC;
+
+	old_gsv = irq_to_gsv(irq);
+	new_gsv = domain_vector_to_gsv(domain, new_vector);
+
+	ia64_irq_to_gsv_map[irq] = new_gsv;
+	ia64_gsv_to_irq_map[new_gsv] = irq;
+	ia64_gsv_to_irq_map[old_gsv] = -1;
+
+	old_domain = gsv_to_domain(old_gsv);
+	old_vector = gsv_to_vector(old_gsv);
+	ia64_free_vector(old_domain, old_vector);
+
+	return new_gsv;
+}
+
+int
 assign_irq_vector (int irq)
 {
 	return gsv_to_vector(assign_irq_gsv(irq, 0));
diff -puN include/asm-ia64/hw_irq.h~vector-domain-ia64-migrate-irq-domain include/asm-ia64/hw_irq.h
--- linux-2.6.13-rc1/include/asm-ia64/hw_irq.h~vector-domain-ia64-migrate-irq-domain	2005-07-13 16:12:53.000000000 +0900
+++ linux-2.6.13-rc1-kanesige/include/asm-ia64/hw_irq.h	2005-07-14 13:13:49.000000000 +0900
@@ -96,6 +96,7 @@ extern struct hw_interrupt_type irq_type
 extern int assign_irq_vector (int irq);	/* allocate a free vector */
 extern int assign_irq_gsv (int irq, int domain);
 extern void free_irq_gsv (int gsv);
+extern int reassign_irq_gsv (int irq, int domain);
 extern void ia64_send_ipi (int cpu, int vector, int delivery_mode, int redirect);
 extern void register_percpu_irq (ia64_vector vec, struct irqaction *action);
 extern void __init ia64_vector_domain_init(void);

_

