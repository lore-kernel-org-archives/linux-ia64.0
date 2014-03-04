From: tip-bot for Thomas Gleixner <tipbot@zytor.com>
Date: Tue, 04 Mar 2014 16:42:25 +0000
Subject: [tip:irq/core] ia64: Use the core irq stats function
Message-Id: <tip-3611587aa15f4ff75a2af3483d6a02accada8ec8@git.kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20140223212738.099977064@linutronix.de>
In-Reply-To: <20140223212738.099977064@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-tip-commits@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, hpa@zytor.com, mingo@kernel.org, peterz@infradead.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, fenghua.yu@intel.com, tglx@linutronix.de

Commit-ID:  3611587aa15f4ff75a2af3483d6a02accada8ec8
Gitweb:     http://git.kernel.org/tip/3611587aa15f4ff75a2af3483d6a02accada8ec8
Author:     Thomas Gleixner <tglx@linutronix.de>
AuthorDate: Sun, 23 Feb 2014 21:40:17 +0000
Committer:  Thomas Gleixner <tglx@linutronix.de>
CommitDate: Tue, 4 Mar 2014 17:37:54 +0100

ia64: Use the core irq stats function

Let the core do the irq_desc resolution.

No functional change.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: ia64 <linux-ia64@vger.kernel.org>
Link: http://lkml.kernel.org/r/20140223212738.099977064@linutronix.de
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>

---
 arch/ia64/kernel/irq_ia64.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/arch/ia64/kernel/irq_ia64.c b/arch/ia64/kernel/irq_ia64.c
index 1034884..c8a576b 100644
--- a/arch/ia64/kernel/irq_ia64.c
+++ b/arch/ia64/kernel/irq_ia64.c
@@ -489,14 +489,13 @@ ia64_handle_irq (ia64_vector vector, struct pt_regs *regs)
 	ia64_srlz_d();
 	while (vector != IA64_SPURIOUS_INT_VECTOR) {
 		int irq = local_vector_to_irq(vector);
-		struct irq_desc *desc = irq_to_desc(irq);
 
 		if (unlikely(IS_LOCAL_TLB_FLUSH(vector))) {
 			smp_local_flush_tlb();
-			kstat_incr_irqs_this_cpu(irq, desc);
+			kstat_incr_irq_this_cpu(irq);
 		} else if (unlikely(IS_RESCHEDULE(vector))) {
 			scheduler_ipi();
-			kstat_incr_irqs_this_cpu(irq, desc);
+			kstat_incr_irq_this_cpu(irq);
 		} else {
 			ia64_setreg(_IA64_REG_CR_TPR, vector);
 			ia64_srlz_d();
@@ -549,13 +548,12 @@ void ia64_process_pending_intr(void)
 	  */
 	while (vector != IA64_SPURIOUS_INT_VECTOR) {
 		int irq = local_vector_to_irq(vector);
-		struct irq_desc *desc = irq_to_desc(irq);
 
 		if (unlikely(IS_LOCAL_TLB_FLUSH(vector))) {
 			smp_local_flush_tlb();
-			kstat_incr_irqs_this_cpu(irq, desc);
+			kstat_incr_irq_this_cpu(irq);
 		} else if (unlikely(IS_RESCHEDULE(vector))) {
-			kstat_incr_irqs_this_cpu(irq, desc);
+			kstat_incr_irq_this_cpu(irq);
 		} else {
 			struct pt_regs *old_regs = set_irq_regs(NULL);
 
