From: Ashok Raj <ashok.raj@intel.com>
Date: Wed, 28 Apr 2004 01:04:23 +0000
Subject: Updated CPU hotplug patches for IA64 [Patch 4/7]
Message-Id: <20040427180423.E29377@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040427180033.B29377@unix-os.sc.intel.com>
In-Reply-To: <20040427180033.B29377@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



Name: ia64_irq_affinity_fix.patch
Author: Ashok Raj (Intel Corporation)
Status: Tested with Hotplug CPU Code

D: irq affinity setting via /proc was forcing iosapic rte programming
D: by force. The correct way to do this is to perform this when a interrupt
D: is pending.


---

 linux-2.6.5-lhcs-root/arch/ia64/kernel/iosapic.c |   19 +++++++++++++++++++
 linux-2.6.5-lhcs-root/arch/ia64/kernel/irq.c     |   12 +++++++++---
 2 files changed, 28 insertions(+), 3 deletions(-)

diff -puN arch/ia64/kernel/irq.c~ia64_irq_affinity_fix arch/ia64/kernel/irq.c
--- linux-2.6.5-lhcs/arch/ia64/kernel/irq.c~ia64_irq_affinity_fix	2004-04-27 17:43:36.398860154 -0700
+++ linux-2.6.5-lhcs-root/arch/ia64/kernel/irq.c	2004-04-27 17:43:36.402766406 -0700
@@ -46,7 +46,7 @@
 #include <asm/delay.h>
 #include <asm/irq.h>
 
-
+extern cpumask_t    __cacheline_aligned pending_irq_cpumask[NR_IRQS];
 
 /*
  * Linux has a controller-independent x86 interrupt architecture.
@@ -938,7 +938,9 @@ void set_irq_affinity_info (unsigned int
 static int irq_affinity_read_proc (char *page, char **start, off_t off,
 			int count, int *eof, void *data)
 {
-	int len = cpumask_scnprintf(page, count, irq_affinity[(long)data]);
+	int len = sprintf(page, "%s", irq_redir[(long)data] ? "r " : "");
+
+	len += cpumask_scnprintf(page+len, count, irq_affinity[(long)data]);
 	if (count - len < 2)
 		return -EINVAL;
 	len += sprintf(page + len, "\n");
@@ -956,6 +958,7 @@ static int irq_affinity_write_proc (stru
 	int rlen;
 	int prelen;
 	irq_desc_t *desc = irq_descp(irq);
+	unsigned long flags;
 
 	if (!desc->handler->set_affinity)
 		return -EIO;
@@ -994,7 +997,10 @@ static int irq_affinity_write_proc (stru
 	if (cpus_empty(tmp))
 		return -EINVAL;
 
-	desc->handler->set_affinity(irq, new_value);
+	spin_lock_irqsave(&desc->lock, flags);
+	pending_irq_cpumask[irq] = new_value;
+	spin_unlock_irqrestore(&desc->lock, flags);
+
 	return full_count;
 }
 
diff -puN arch/ia64/kernel/iosapic.c~ia64_irq_affinity_fix arch/ia64/kernel/iosapic.c
--- linux-2.6.5-lhcs/arch/ia64/kernel/iosapic.c~ia64_irq_affinity_fix	2004-04-27 17:43:36.400813280 -0700
+++ linux-2.6.5-lhcs-root/arch/ia64/kernel/iosapic.c	2004-04-27 17:43:36.402766406 -0700
@@ -98,6 +98,7 @@
 #endif
 
 static spinlock_t iosapic_lock = SPIN_LOCK_UNLOCKED;
+cpumask_t	__cacheline_aligned pending_irq_cpumask[NR_IRQS];
 
 /* These tables map IA-64 vectors to the IOSAPIC pin that generates this vector. */
 
@@ -327,6 +328,21 @@ iosapic_set_affinity (unsigned int irq, 
 #endif
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
 /*
  * Handlers for level-triggered interrupts.
  */
@@ -343,6 +359,7 @@ iosapic_end_level_irq (unsigned int irq)
 {
 	ia64_vector vec = irq_to_vector(irq);
 
+	move_irq(irq);
 	writel(vec, iosapic_intr_info[vec].addr + IOSAPIC_EOI);
 }
 
@@ -382,6 +399,8 @@ static void
 iosapic_ack_edge_irq (unsigned int irq)
 {
 	irq_desc_t *idesc = irq_descp(irq);
+
+	move_irq(irq);
 	/*
 	 * Once we have recorded IRQ_PENDING already, we can mask the
 	 * interrupt for real. This prevents IRQ storms from unhandled

_
