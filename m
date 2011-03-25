From: Thomas Gleixner <tglx@linutronix.de>
Date: Fri, 25 Mar 2011 20:51:56 +0000
Subject: [patch 12/23] ia64: sn: Drop unused function
Message-Id: <20110325204515.641974350@linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Leftover from the irq chip conversion.

Reported-by: Tony Luck <tony.luck@intel.com>
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
 arch/ia64/sn/kernel/irq.c |   16 ----------------
 1 file changed, 16 deletions(-)

Index: linux-2.6-tip/arch/ia64/sn/kernel/irq.c
=================================--- linux-2.6-tip.orig/arch/ia64/sn/kernel/irq.c
+++ linux-2.6-tip/arch/ia64/sn/kernel/irq.c
@@ -23,11 +23,9 @@
 #include <asm/sn/sn_sal.h>
 #include <asm/sn/sn_feature_sets.h>
 
-static void force_interrupt(int irq);
 static void register_intr_pda(struct sn_irq_info *sn_irq_info);
 static void unregister_intr_pda(struct sn_irq_info *sn_irq_info);
 
-int sn_force_interrupt_flag = 1;
 extern int sn_ioif_inited;
 struct list_head **sn_irq_lh;
 static DEFINE_SPINLOCK(sn_irq_info_lock); /* non-IRQ lock */
@@ -423,20 +421,6 @@ sn_call_force_intr_provider(struct sn_ir
 		(*pci_provider->force_interrupt)(sn_irq_info);
 }
 
-static void force_interrupt(int irq)
-{
-	struct sn_irq_info *sn_irq_info;
-
-	if (!sn_ioif_inited)
-		return;
-
-	rcu_read_lock();
-	list_for_each_entry_rcu(sn_irq_info, sn_irq_lh[irq], list)
-		sn_call_force_intr_provider(sn_irq_info);
-
-	rcu_read_unlock();
-}
-
 /*
  * Check for lost interrupts.  If the PIC int_status reg. says that
  * an interrupt has been sent, but not handled, and the interrupt


