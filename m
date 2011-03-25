From: Thomas Gleixner <tglx@linutronix.de>
Date: Fri, 25 Mar 2011 20:51:50 +0000
Subject: [patch 04/23] ia64: Remove stale irq_chip.end
Message-Id: <20110325204514.879162355@linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

irq_chip.end got obsolete with the removal of __do_IRQ().

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Tony Luck <tony.luck@intel.com>
LKML-Reference: <20110203004210.143127544@linutronix.de>
---
 arch/ia64/hp/sim/hpsim_irq.c  |    1 -
 arch/ia64/kernel/iosapic.c    |    2 --
 arch/ia64/kernel/irq_lsapic.c |    1 -
 arch/ia64/sn/kernel/irq.c     |   23 -----------------------
 4 files changed, 27 deletions(-)

Index: linux-2.6-tip/arch/ia64/hp/sim/hpsim_irq.c
=================================--- linux-2.6-tip.orig/arch/ia64/hp/sim/hpsim_irq.c
+++ linux-2.6-tip/arch/ia64/hp/sim/hpsim_irq.c
@@ -34,7 +34,6 @@ static struct irq_chip irq_type_hp_sim  	.enable =	hpsim_irq_noop,
 	.disable =	hpsim_irq_noop,
 	.ack =		hpsim_irq_noop,
-	.end =		hpsim_irq_noop,
 	.set_affinity =	hpsim_set_affinity_noop,
 };
 
Index: linux-2.6-tip/arch/ia64/kernel/iosapic.c
=================================--- linux-2.6-tip.orig/arch/ia64/kernel/iosapic.c
+++ linux-2.6-tip/arch/ia64/kernel/iosapic.c
@@ -460,7 +460,6 @@ iosapic_ack_edge_irq (unsigned int irq)
 
 #define iosapic_enable_edge_irq		unmask_irq
 #define iosapic_disable_edge_irq	nop
-#define iosapic_end_edge_irq		nop
 
 static struct irq_chip irq_type_iosapic_edge = {
 	.name =		"IO-SAPIC-edge",
@@ -469,7 +468,6 @@ static struct irq_chip irq_type_iosapic_
 	.enable =	iosapic_enable_edge_irq,
 	.disable =	iosapic_disable_edge_irq,
 	.ack =		iosapic_ack_edge_irq,
-	.end =		iosapic_end_edge_irq,
 	.mask =		mask_irq,
 	.unmask =	unmask_irq,
 	.set_affinity =	iosapic_set_affinity
Index: linux-2.6-tip/arch/ia64/kernel/irq_lsapic.c
=================================--- linux-2.6-tip.orig/arch/ia64/kernel/irq_lsapic.c
+++ linux-2.6-tip/arch/ia64/kernel/irq_lsapic.c
@@ -40,6 +40,5 @@ struct irq_chip irq_type_ia64_lsapic = {
 	.enable =	lsapic_noop,
 	.disable =	lsapic_noop,
 	.ack =		lsapic_noop,
-	.end =		lsapic_noop,
 	.retrigger =	lsapic_retrigger,
 };
Index: linux-2.6-tip/arch/ia64/sn/kernel/irq.c
=================================--- linux-2.6-tip.orig/arch/ia64/sn/kernel/irq.c
+++ linux-2.6-tip/arch/ia64/sn/kernel/irq.c
@@ -114,28 +114,6 @@ static void sn_ack_irq(unsigned int irq)
 	move_native_irq(irq);
 }
 
-static void sn_end_irq(unsigned int irq)
-{
-	int ivec;
-	u64 event_occurred;
-
-	ivec = irq & 0xff;
-	if (ivec = SGI_UART_VECTOR) {
-		event_occurred = HUB_L((u64*)LOCAL_MMR_ADDR (SH_EVENT_OCCURRED));
-		/* If the UART bit is set here, we may have received an
-		 * interrupt from the UART that the driver missed.  To
-		 * make sure, we IPI ourselves to force us to look again.
-		 */
-		if (event_occurred & SH_EVENT_OCCURRED_UART_INT_MASK) {
-			platform_send_ipi(smp_processor_id(), SGI_UART_VECTOR,
-					  IA64_IPI_DM_INT, 0);
-		}
-	}
-	__clear_bit(ivec, (volatile void *)pda->sn_in_service_ivecs);
-	if (sn_force_interrupt_flag)
-		force_interrupt(irq);
-}
-
 static void sn_irq_info_free(struct rcu_head *head);
 
 struct sn_irq_info *sn_retarget_vector(struct sn_irq_info *sn_irq_info,
@@ -275,7 +253,6 @@ struct irq_chip irq_type_sn = {
 	.enable		= sn_enable_irq,
 	.disable	= sn_disable_irq,
 	.ack		= sn_ack_irq,
-	.end		= sn_end_irq,
 	.mask		= sn_mask_irq,
 	.unmask		= sn_unmask_irq,
 	.set_affinity	= sn_set_affinity_irq


