From: Thomas Gleixner <tglx@linutronix.de>
Date: Fri, 25 Mar 2011 20:52:01 +0000
Subject: [patch 19/23] ia64: msi: Use irq_move_irq()
Message-Id: <20110325204516.311906277@linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This replaces the old move_native_irq() function which is going away.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
 arch/ia64/kernel/msi_ia64.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6-tip/arch/ia64/kernel/msi_ia64.c
=================================--- linux-2.6-tip.orig/arch/ia64/kernel/msi_ia64.c
+++ linux-2.6-tip/arch/ia64/kernel/msi_ia64.c
@@ -88,7 +88,7 @@ void ia64_teardown_msi_irq(unsigned int 
 static void ia64_ack_msi_irq(struct irq_data *data)
 {
 	irq_complete_move(data->irq);
-	move_native_irq(data->irq);
+	irq_move_irq(data);
 	ia64_eoi();
 }
 


