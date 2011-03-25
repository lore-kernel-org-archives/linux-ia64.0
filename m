From: Thomas Gleixner <tglx@linutronix.de>
Date: Fri, 25 Mar 2011 20:51:55 +0000
Subject: [patch 10/23] ia64: Convert lsapic to new irq_chip functions
Message-Id: <20110325204515.450958280@linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
 arch/ia64/kernel/irq_lsapic.c |   22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

Index: linux-2.6-tip/arch/ia64/kernel/irq_lsapic.c
=================================--- linux-2.6-tip.orig/arch/ia64/kernel/irq_lsapic.c
+++ linux-2.6-tip/arch/ia64/kernel/irq_lsapic.c
@@ -15,30 +15,30 @@
 #include <linux/irq.h>
 
 static unsigned int
-lsapic_noop_startup (unsigned int irq)
+lsapic_noop_startup (struct irq_data *data)
 {
 	return 0;
 }
 
 static void
-lsapic_noop (unsigned int irq)
+lsapic_noop (struct irq_data *data)
 {
 	/* nothing to do... */
 }
 
-static int lsapic_retrigger(unsigned int irq)
+static int lsapic_retrigger(struct irq_data *data)
 {
-	ia64_resend_irq(irq);
+	ia64_resend_irq(data->irq);
 
 	return 1;
 }
 
 struct irq_chip irq_type_ia64_lsapic = {
-	.name =		"LSAPIC",
-	.startup =	lsapic_noop_startup,
-	.shutdown =	lsapic_noop,
-	.enable =	lsapic_noop,
-	.disable =	lsapic_noop,
-	.ack =		lsapic_noop,
-	.retrigger =	lsapic_retrigger,
+	.name =			"LSAPIC",
+	.irq_startup =		lsapic_noop_startup,
+	.irq_shutdown =		lsapic_noop,
+	.irq_enable =		lsapic_noop,
+	.irq_disable =		lsapic_noop,
+	.irq_ack =		lsapic_noop,
+	.irq_retrigger =	lsapic_retrigger,
 };


