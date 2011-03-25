From: Thomas Gleixner <tglx@linutronix.de>
Date: Fri, 25 Mar 2011 20:51:58 +0000
Subject: [patch 14/23] ia64: xen: Use irq accessor functions
Message-Id: <20110325204515.832350950@linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
 arch/ia64/xen/irq_xen.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

Index: linux-2.6-tip/arch/ia64/xen/irq_xen.c
=================================--- linux-2.6-tip.orig/arch/ia64/xen/irq_xen.c
+++ linux-2.6-tip/arch/ia64/xen/irq_xen.c
@@ -138,7 +138,6 @@ static void
 __xen_register_percpu_irq(unsigned int cpu, unsigned int vec,
 			struct irqaction *action, int save)
 {
-	struct irq_desc *desc;
 	int irq = 0;
 
 	if (xen_slab_ready) {
@@ -223,8 +222,7 @@ __xen_register_percpu_irq(unsigned int c
 			 * mark the interrupt for migrations and trigger it
 			 * on cpu hotplug.
 			 */
-			desc = irq_desc + irq;
-			desc->status |= IRQ_PER_CPU;
+			irq_set_status_flags(irq, IRQ_PER_CPU);
 		}
 	}
 


