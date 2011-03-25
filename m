From: Thomas Gleixner <tglx@linutronix.de>
Date: Fri, 25 Mar 2011 20:52:00 +0000
Subject: [patch 18/23] ia64: sn: Use irq_move_irq()
Message-Id: <20110325204516.214699402@linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This replaces the old move_native_irq() function which is going away.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
 arch/ia64/sn/kernel/irq.c    |    2 +-
 arch/ia64/sn/kernel/msi_sn.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

Index: linux-2.6-tip/arch/ia64/sn/kernel/irq.c
=================================--- linux-2.6-tip.orig/arch/ia64/sn/kernel/irq.c
+++ linux-2.6-tip/arch/ia64/sn/kernel/irq.c
@@ -110,7 +110,7 @@ static void sn_ack_irq(struct irq_data *
 	HUB_S((u64*)LOCAL_MMR_ADDR(SH_EVENT_OCCURRED_ALIAS), mask);
 	__set_bit(irq, (volatile void *)pda->sn_in_service_ivecs);
 
-	move_native_irq(irq);
+	irq_move_irq(data);
 }
 
 static void sn_irq_info_free(struct rcu_head *head);
Index: linux-2.6-tip/arch/ia64/sn/kernel/msi_sn.c
=================================--- linux-2.6-tip.orig/arch/ia64/sn/kernel/msi_sn.c
+++ linux-2.6-tip/arch/ia64/sn/kernel/msi_sn.c
@@ -214,7 +214,7 @@ static int sn_set_msi_irq_affinity(struc
 
 static void sn_ack_msi_irq(struct irq_data *data)
 {
-	move_native_irq(data->irq);
+	irq_move_irq(data);
 	ia64_eoi();
 }
 


