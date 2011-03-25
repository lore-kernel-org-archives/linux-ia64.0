From: Thomas Gleixner <tglx@linutronix.de>
Date: Fri, 25 Mar 2011 20:52:00 +0000
Subject: [patch 17/23] ia64: iosapic: Use new irq_move_* functions
Message-Id: <20110325204516.122336497@linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The current functions are going away.

Also use the accessor for pending setaffinity in irq_data instead of
the open coded irq_desc access.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
 arch/ia64/kernel/iosapic.c |   10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

Index: linux-2.6-tip/arch/ia64/kernel/iosapic.c
=================================--- linux-2.6-tip.orig/arch/ia64/kernel/iosapic.c
+++ linux-2.6-tip/arch/ia64/kernel/iosapic.c
@@ -398,7 +398,7 @@ iosapic_unmask_level_irq (struct irq_dat
 	int do_unmask_irq = 0;
 
 	irq_complete_move(irq);
-	if (unlikely(irq_desc[irq].status & IRQ_MOVE_PENDING)) {
+	if (unlikely(irqd_is_setaffinity_pending(data))) {
 		do_unmask_irq = 1;
 		mask_irq(data);
 	} else
@@ -408,7 +408,7 @@ iosapic_unmask_level_irq (struct irq_dat
 		iosapic_eoi(rte->iosapic->addr, vec);
 
 	if (unlikely(do_unmask_irq)) {
-		move_masked_irq(irq);
+		irq_move_masked_irq(data);
 		unmask_irq(data);
 	}
 }
@@ -449,10 +449,8 @@ iosapic_startup_edge_irq (struct irq_dat
 static void
 iosapic_ack_edge_irq (struct irq_data *data)
 {
-	unsigned int irq = data->irq;
-
-	irq_complete_move(irq);
-	move_native_irq(irq);
+	irq_complete_move(data->irq);
+	irq_move_irq(data);
 }
 
 #define iosapic_enable_edge_irq		unmask_irq


