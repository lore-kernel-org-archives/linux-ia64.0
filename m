From: Pat Gefre <pfg@sgi.com>
Date: Thu, 17 Jun 2004 15:46:02 +0000
Subject: [PATCH] fix interrupt rerouting for Altix
Message-Id: <200406171546.i5HFk3wF407364@fsgi900.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Patch to fix our interrupt re-routing.


-- Pat




Signed-off-by: Patrick Gefre <pfg@sgi.com>


# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/06/17 10:40:46-05:00 pfg@sgi.com 
#   Patch to fix interrupt re-routing.
# 
# arch/ia64/sn/kernel/irq.c
#   2004/06/17 10:40:38-05:00 pfg@sgi.com +17 -0
# 
# arch/ia64/sn/io/sn2/ml_iograph.c
#   2004/06/17 10:40:38-05:00 pfg@sgi.com +8 -8
#    
# 
diff -Nru a/arch/ia64/sn/io/sn2/ml_iograph.c b/arch/ia64/sn/io/sn2/ml_iograph.c
--- a/arch/ia64/sn/io/sn2/ml_iograph.c	2004-06-17 10:42:20 -05:00
+++ b/arch/ia64/sn/io/sn2/ml_iograph.c	2004-06-17 10:42:20 -05:00
@@ -518,6 +518,14 @@
 	ASSERT(hubv != GRAPH_VERTEX_NONE);
 
 	/* 
+	 * attach our hub_provider information to hubv,
+	 * so we can use it as a crosstalk provider "master"
+	 * vertex.
+	 */
+	xtalk_provider_register(hubv, &hub_provider);
+	xtalk_provider_startup(hubv);
+
+	/* 
 	 * If nothing connected to this hub's xtalk port, we're done.
 	 */
 	early_probe_for_widget(hubv, &hwid);
@@ -526,14 +534,6 @@
 		return;
 		/* NOTREACHED */
 	}
-
-	/* 
-	 * attach our hub_provider information to hubv,
-	 * so we can use it as a crosstalk provider "master"
-	 * vertex.
-	 */
-	xtalk_provider_register(hubv, &hub_provider);
-	xtalk_provider_startup(hubv);
 
 	/*
 	 * Create a vertex to represent the crosstalk bus
diff -Nru a/arch/ia64/sn/kernel/irq.c b/arch/ia64/sn/kernel/irq.c
--- a/arch/ia64/sn/kernel/irq.c	2004-06-17 10:42:20 -05:00
+++ b/arch/ia64/sn/kernel/irq.c	2004-06-17 10:42:20 -05:00
@@ -41,6 +41,7 @@
 extern void pcibr_force_interrupt(pcibr_intr_t intr);
 extern int sn_force_interrupt_flag;
 struct irq_desc * sn_irq_desc(unsigned int irq);
+extern cpumask_t    __cacheline_aligned pending_irq_cpumask[NR_IRQS];
 
 struct sn_intr_list_t {
 	struct sn_intr_list_t *next;
@@ -71,6 +72,21 @@
 {
 }
 
+static inline void move_irq(int irq)
+{
+	/* note - we hold desc->lock */
+	cpumask_t tmp;
+	irq_desc_t *desc = irq_descp(irq);
+
+	if (!cpus_empty(pending_irq_cpumask[irq])) {
+		cpus_and(tmp, pending_irq_cpumask[irq], cpu_online_map);
+		if (unlikely(!cpus_empty(tmp))) {
+			desc->handler->set_affinity(irq, pending_irq_cpumask[irq]);
+		}
+		cpus_clear(pending_irq_cpumask[irq]);
+	}
+}
+
 static void
 sn_ack_irq(unsigned int irq)
 {
@@ -94,6 +110,7 @@
 	}
 	HUB_S((unsigned long *)GLOBAL_MMR_ADDR(nasid, SH_EVENT_OCCURRED_ALIAS), mask );
 	__set_bit(irq, (volatile void *)pda->sn_in_service_ivecs);
+	move_irq(irq);
 }
 
 static void
