From: Thomas Gleixner <tglx@linutronix.de>
Date: Fri, 25 Mar 2011 20:51:52 +0000
Subject: [patch 06/23] ia64: hp-sim: Cleanup direct access to irq_desc
Message-Id: <20110325204515.067275408@linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Use accessor functions instead of open coded access.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
 arch/ia64/hp/sim/hpsim_irq.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

Index: linux-2.6-tip/arch/ia64/hp/sim/hpsim_irq.c
=================================--- linux-2.6-tip.orig/arch/ia64/hp/sim/hpsim_irq.c
+++ linux-2.6-tip/arch/ia64/hp/sim/hpsim_irq.c
@@ -40,12 +40,12 @@ static struct irq_chip irq_type_hp_sim  void __init
 hpsim_irq_init (void)
 {
-	struct irq_desc *idesc;
 	int i;
 
-	for (i = 0; i < NR_IRQS; ++i) {
-		idesc = irq_desc + i;
-		if (idesc->chip = &no_irq_chip)
-			idesc->chip = &irq_type_hp_sim;
+	for_each_active_irq(i) {
+		struct irq_chip *chip = get_irq_chip(i);
+
+		if (chip = &no_irq_chip)
+			set_irq_chip(i, &irq_type_hp_sim);
 	}
 }


