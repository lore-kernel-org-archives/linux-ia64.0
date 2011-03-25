From: Thomas Gleixner <tglx@linutronix.de>
Date: Fri, 25 Mar 2011 20:51:59 +0000
Subject: [patch 16/23] ia64: iosapic: Remove redundant mask from ack()
Message-Id: <20110325204516.025967122@linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The core code calls mask_ack() which calls irq_ack() and irq_mask()
for the case where an interrupt is disabled and marked pending. That
seems to be a leftover from the old __do_IRQ() mode.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
 arch/ia64/kernel/iosapic.c |    9 ---------
 1 file changed, 9 deletions(-)

Index: linux-2.6-tip/arch/ia64/kernel/iosapic.c
=================================--- linux-2.6-tip.orig/arch/ia64/kernel/iosapic.c
+++ linux-2.6-tip/arch/ia64/kernel/iosapic.c
@@ -450,18 +450,9 @@ static void
 iosapic_ack_edge_irq (struct irq_data *data)
 {
 	unsigned int irq = data->irq;
-	struct irq_desc *idesc = irq_desc + irq;
 
 	irq_complete_move(irq);
 	move_native_irq(irq);
-	/*
-	 * Once we have recorded IRQ_PENDING already, we can mask the
-	 * interrupt for real. This prevents IRQ storms from unhandled
-	 * devices.
-	 */
-	if ((idesc->status & (IRQ_PENDING|IRQ_DISABLED)) =
-	    (IRQ_PENDING|IRQ_DISABLED))
-		mask_irq(data);
 }
 
 #define iosapic_enable_edge_irq		unmask_irq


