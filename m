From: Thomas Gleixner <tglx@linutronix.de>
Date: Fri, 25 Mar 2011 20:51:55 +0000
Subject: [patch 11/23] ia64: Convert iosapic to new irq_chip functions
Message-Id: <20110325204515.544939193@linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
 arch/ia64/kernel/iosapic.c |   70 ++++++++++++++++++++++++---------------------
 1 file changed, 38 insertions(+), 32 deletions(-)

Index: linux-2.6-tip/arch/ia64/kernel/iosapic.c
=================================--- linux-2.6-tip.orig/arch/ia64/kernel/iosapic.c
+++ linux-2.6-tip/arch/ia64/kernel/iosapic.c
@@ -257,7 +257,7 @@ set_rte (unsigned int gsi, unsigned int 
 }
 
 static void
-nop (unsigned int irq)
+nop (struct irq_data *data)
 {
 	/* do nothing... */
 }
@@ -287,8 +287,9 @@ kexec_disable_iosapic(void)
 #endif
 
 static void
-mask_irq (unsigned int irq)
+mask_irq (struct irq_data *data)
 {
+	unsigned int irq = data->irq;
 	u32 low32;
 	int rte_index;
 	struct iosapic_rte_info *rte;
@@ -305,8 +306,9 @@ mask_irq (unsigned int irq)
 }
 
 static void
-unmask_irq (unsigned int irq)
+unmask_irq (struct irq_data *data)
 {
+	unsigned int irq = data->irq;
 	u32 low32;
 	int rte_index;
 	struct iosapic_rte_info *rte;
@@ -323,9 +325,11 @@ unmask_irq (unsigned int irq)
 
 
 static int
-iosapic_set_affinity(unsigned int irq, const struct cpumask *mask)
+iosapic_set_affinity(struct irq_data *data, const struct cpumask *mask,
+		     bool force)
 {
 #ifdef CONFIG_SMP
+	unsigned int irq = data->irq;
 	u32 high32, low32;
 	int cpu, dest, rte_index;
 	int redir = (irq & IA64_IRQ_REDIRECTED) ? 1 : 0;
@@ -379,15 +383,16 @@ iosapic_set_affinity(unsigned int irq, c
  */
 
 static unsigned int
-iosapic_startup_level_irq (unsigned int irq)
+iosapic_startup_level_irq (struct irq_data *data)
 {
-	unmask_irq(irq);
+	unmask_irq(data);
 	return 0;
 }
 
 static void
-iosapic_unmask_level_irq (unsigned int irq)
+iosapic_unmask_level_irq (struct irq_data *data)
 {
+	unsigned int irq = data->irq;
 	ia64_vector vec = irq_to_vector(irq);
 	struct iosapic_rte_info *rte;
 	int do_unmask_irq = 0;
@@ -395,16 +400,16 @@ iosapic_unmask_level_irq (unsigned int i
 	irq_complete_move(irq);
 	if (unlikely(irq_desc[irq].status & IRQ_MOVE_PENDING)) {
 		do_unmask_irq = 1;
-		mask_irq(irq);
+		mask_irq(data);
 	} else
-		unmask_irq(irq);
+		unmask_irq(data);
 
 	list_for_each_entry(rte, &iosapic_intr_info[irq].rtes, rte_list)
 		iosapic_eoi(rte->iosapic->addr, vec);
 
 	if (unlikely(do_unmask_irq)) {
 		move_masked_irq(irq);
-		unmask_irq(irq);
+		unmask_irq(data);
 	}
 }
 
@@ -414,15 +419,15 @@ iosapic_unmask_level_irq (unsigned int i
 #define iosapic_ack_level_irq		nop
 
 static struct irq_chip irq_type_iosapic_level = {
-	.name =		"IO-SAPIC-level",
-	.startup =	iosapic_startup_level_irq,
-	.shutdown =	iosapic_shutdown_level_irq,
-	.enable =	iosapic_enable_level_irq,
-	.disable =	iosapic_disable_level_irq,
-	.ack =		iosapic_ack_level_irq,
-	.mask =		mask_irq,
-	.unmask =	iosapic_unmask_level_irq,
-	.set_affinity =	iosapic_set_affinity
+	.name =			"IO-SAPIC-level",
+	.irq_startup =		iosapic_startup_level_irq,
+	.irq_shutdown =		iosapic_shutdown_level_irq,
+	.irq_enable =		iosapic_enable_level_irq,
+	.irq_disable =		iosapic_disable_level_irq,
+	.irq_ack =		iosapic_ack_level_irq,
+	.irq_mask =		mask_irq,
+	.irq_unmask =		iosapic_unmask_level_irq,
+	.irq_set_affinity =	iosapic_set_affinity
 };
 
 /*
@@ -430,9 +435,9 @@ static struct irq_chip irq_type_iosapic_
  */
 
 static unsigned int
-iosapic_startup_edge_irq (unsigned int irq)
+iosapic_startup_edge_irq (struct irq_data *data)
 {
-	unmask_irq(irq);
+	unmask_irq(data);
 	/*
 	 * IOSAPIC simply drops interrupts pended while the
 	 * corresponding pin was masked, so we can't know if an
@@ -442,8 +447,9 @@ iosapic_startup_edge_irq (unsigned int i
 }
 
 static void
-iosapic_ack_edge_irq (unsigned int irq)
+iosapic_ack_edge_irq (struct irq_data *data)
 {
+	unsigned int irq = data->irq;
 	struct irq_desc *idesc = irq_desc + irq;
 
 	irq_complete_move(irq);
@@ -455,22 +461,22 @@ iosapic_ack_edge_irq (unsigned int irq)
 	 */
 	if ((idesc->status & (IRQ_PENDING|IRQ_DISABLED)) =
 	    (IRQ_PENDING|IRQ_DISABLED))
-		mask_irq(irq);
+		mask_irq(data);
 }
 
 #define iosapic_enable_edge_irq		unmask_irq
 #define iosapic_disable_edge_irq	nop
 
 static struct irq_chip irq_type_iosapic_edge = {
-	.name =		"IO-SAPIC-edge",
-	.startup =	iosapic_startup_edge_irq,
-	.shutdown =	iosapic_disable_edge_irq,
-	.enable =	iosapic_enable_edge_irq,
-	.disable =	iosapic_disable_edge_irq,
-	.ack =		iosapic_ack_edge_irq,
-	.mask =		mask_irq,
-	.unmask =	unmask_irq,
-	.set_affinity =	iosapic_set_affinity
+	.name =			"IO-SAPIC-edge",
+	.irq_startup =		iosapic_startup_edge_irq,
+	.irq_shutdown =		iosapic_disable_edge_irq,
+	.irq_enable =		iosapic_enable_edge_irq,
+	.irq_disable =		iosapic_disable_edge_irq,
+	.irq_ack =		iosapic_ack_edge_irq,
+	.irq_mask =		mask_irq,
+	.irq_unmask =		unmask_irq,
+	.irq_set_affinity =	iosapic_set_affinity
 };
 
 static unsigned int


