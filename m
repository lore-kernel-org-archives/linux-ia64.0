From: Thomas Gleixner <tglx@linutronix.de>
Date: Fri, 25 Mar 2011 20:51:51 +0000
Subject: [patch 05/23] ia64: Convert hp-sim to new irq_chip functions
Message-Id: <20110325204514.971262930@linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
 arch/ia64/hp/sim/hpsim_irq.c |   20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

Index: linux-2.6-tip/arch/ia64/hp/sim/hpsim_irq.c
=================================--- linux-2.6-tip.orig/arch/ia64/hp/sim/hpsim_irq.c
+++ linux-2.6-tip/arch/ia64/hp/sim/hpsim_irq.c
@@ -11,30 +11,30 @@
 #include <linux/irq.h>
 
 static unsigned int
-hpsim_irq_startup (unsigned int irq)
+hpsim_irq_startup(struct irq_data *data)
 {
 	return 0;
 }
 
 static void
-hpsim_irq_noop (unsigned int irq)
+hpsim_irq_noop(struct irq_data *data)
 {
 }
 
 static int
-hpsim_set_affinity_noop(unsigned int a, const struct cpumask *b)
+hpsim_set_affinity_noop(struct irq_data *d, const struct cpumask *b, bool f)
 {
 	return 0;
 }
 
 static struct irq_chip irq_type_hp_sim = {
-	.name =		"hpsim",
-	.startup =	hpsim_irq_startup,
-	.shutdown =	hpsim_irq_noop,
-	.enable =	hpsim_irq_noop,
-	.disable =	hpsim_irq_noop,
-	.ack =		hpsim_irq_noop,
-	.set_affinity =	hpsim_set_affinity_noop,
+	.name =			"hpsim",
+	.irq_startup =		hpsim_irq_startup,
+	.irq_shutdown =		hpsim_irq_noop,
+	.irq_enable =		hpsim_irq_noop,
+	.irq_disable =		hpsim_irq_noop,
+	.irq_ack =		hpsim_irq_noop,
+	.irq_set_affinity =	hpsim_set_affinity_noop,
 };
 
 void __init


