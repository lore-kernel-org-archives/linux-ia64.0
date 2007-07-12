From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 12 Jul 2007 22:18:55 +0000
Subject: RE: [PATCH 8/12]  Add mapping table between irq and vector
Message-Id: <617E1C2C70743745A92448908E030B2A01EA59B9@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <46417E7C.7030402@jp.fujitsu.com>
In-Reply-To: <46417E7C.7030402@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I found why my machine sometimes crashes during boot with the
vector domain patch applied.  The problem is a spurious interrupt
that causes a wild pointer reference, and thus a crash.

The problem occurs because unused entries in the percpu vector_irq
array are filled with VECTOR_IRQ_UNASSIGNED (-1).  When a
spurious interrupt occurs ia64_handle_irq() calls:

 generic_handle_irq(local_vector_to_irq(vector))

and the  local_vector_to_irq(vector) part return -1, which is all bad.

If we initialize the unused entried to IA64_SPURIOUS_INT_VECTOR
instead, then we get the orginal behaviour: a message is printed and
the vector/irq is disabled.

As a bonus we can delete the VECTOR_IRQ_UNASSIGNED define
altogether (which is all too easy to confuse with IRQ_VECTOR_UNASSIGNED).

So I applied this patch onto the end of your sequence (but you should
merge it into patch8/12).

-Tony

diff --git a/arch/ia64/kernel/irq_ia64.c b/arch/ia64/kernel/irq_ia64.c
index 91abd1b..ea19ccd 100644
--- a/arch/ia64/kernel/irq_ia64.c
+++ b/arch/ia64/kernel/irq_ia64.c
@@ -47,7 +47,6 @@
 #define IRQ_DEBUG	0
 
 #define IRQ_VECTOR_UNASSIGNED	(0)
-#define VECTOR_IRQ_UNASSIGNED	(-1)
 
 #define IRQ_UNUSED		(0)
 #define IRQ_USED		(1)
@@ -83,7 +82,7 @@ struct irq_cfg irq_cfg[NR_IRQS] __read_mostly = {
 };
 
 DEFINE_PER_CPU(int[IA64_NUM_VECTORS], vector_irq) = {
-	[0 ... IA64_NUM_VECTORS - 1] = VECTOR_IRQ_UNASSIGNED
+	[0 ... IA64_NUM_VECTORS - 1] = IA64_SPURIOUS_INT_VECTOR
 };
 
 static cpumask_t vector_table[IA64_MAX_DEVICE_VECTORS] = {
@@ -168,7 +167,7 @@ static void __clear_irq_vector(int irq)
 	domain = irq_cfg[irq].domain;
 	cpus_and(mask, irq_cfg[irq].domain, cpu_online_map);
 	for_each_cpu_mask(cpu, mask)
-		per_cpu(vector_irq, cpu)[vector] = VECTOR_IRQ_UNASSIGNED;
+		per_cpu(vector_irq, cpu)[vector] = IA64_SPURIOUS_INT_VECTOR;
 	irq_cfg[irq].vector = IRQ_VECTOR_UNASSIGNED;
 	irq_cfg[irq].domain = CPU_MASK_NONE;
 	irq_status[irq] = IRQ_UNUSED;
@@ -238,7 +237,7 @@ void __setup_vector_irq(int cpu)
 
 	/* Clear vector_irq */
 	for (vector = 0; vector < IA64_NUM_VECTORS; ++vector)
-		per_cpu(vector_irq, cpu)[vector] = VECTOR_IRQ_UNASSIGNED;
+		per_cpu(vector_irq, cpu)[vector] = IA64_SPURIOUS_INT_VECTOR;
 	/* Mark the inuse vectors */
 	for (irq = 0; irq < NR_IRQS; ++irq) {
 		if (!cpu_isset(cpu, irq_cfg[irq].domain))
