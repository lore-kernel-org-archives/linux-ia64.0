From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Date: Sat, 20 Dec 2014 17:07:02 +0000
Subject: [PATCH] arch: ia64: kernel: irq_ia64.c:  Remove unused function
Message-Id: <1419095222-9942-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>, Thomas Gleixner <tglx@linutronix.de>, Grant Likely <grant.likely@linaro.org>, Christoph Lameter <cl@linux.com>, Tejun Heo <tj@kernel.org>, Michael Opdenacker <michael.opdenacker@free-electrons.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Remove the function ia64_handle_irq() that is not used anywhere.

This was partially found by using a static code analysis program called cppcheck.

Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
---
 arch/ia64/kernel/irq_ia64.c |   83 -------------------------------------------
 1 file changed, 83 deletions(-)

diff --git a/arch/ia64/kernel/irq_ia64.c b/arch/ia64/kernel/irq_ia64.c
index 698d8fe..1b64f10 100644
--- a/arch/ia64/kernel/irq_ia64.c
+++ b/arch/ia64/kernel/irq_ia64.c
@@ -432,89 +432,6 @@ void destroy_irq(unsigned int irq)
 #	define IS_RESCHEDULE(vec)	(0)
 #	define IS_LOCAL_TLB_FLUSH(vec)	(0)
 #endif
-/*
- * That's where the IVT branches when we get an external
- * interrupt. This branches to the correct hardware IRQ handler via
- * function ptr.
- */
-void
-ia64_handle_irq (ia64_vector vector, struct pt_regs *regs)
-{
-	struct pt_regs *old_regs = set_irq_regs(regs);
-	unsigned long saved_tpr;
-
-#if IRQ_DEBUG
-	{
-		unsigned long bsp, sp;
-
-		/*
-		 * Note: if the interrupt happened while executing in
-		 * the context switch routine (ia64_switch_to), we may
-		 * get a spurious stack overflow here.  This is
-		 * because the register and the memory stack are not
-		 * switched atomically.
-		 */
-		bsp = ia64_getreg(_IA64_REG_AR_BSP);
-		sp = ia64_getreg(_IA64_REG_SP);
-
-		if ((sp - bsp) < 1024) {
-			static DEFINE_RATELIMIT_STATE(ratelimit, 5 * HZ, 5);
-
-			if (__ratelimit(&ratelimit)) {
-				printk("ia64_handle_irq: DANGER: less than "
-				       "1KB of free stack space!!\n"
-				       "(bsp=0x%lx, sp=%lx)\n", bsp, sp);
-			}
-		}
-	}
-#endif /* IRQ_DEBUG */
-
-	/*
-	 * Always set TPR to limit maximum interrupt nesting depth to
-	 * 16 (without this, it would be ~240, which could easily lead
-	 * to kernel stack overflows).
-	 */
-	irq_enter();
-	saved_tpr = ia64_getreg(_IA64_REG_CR_TPR);
-	ia64_srlz_d();
-	while (vector != IA64_SPURIOUS_INT_VECTOR) {
-		int irq = local_vector_to_irq(vector);
-
-		if (unlikely(IS_LOCAL_TLB_FLUSH(vector))) {
-			smp_local_flush_tlb();
-			kstat_incr_irq_this_cpu(irq);
-		} else if (unlikely(IS_RESCHEDULE(vector))) {
-			scheduler_ipi();
-			kstat_incr_irq_this_cpu(irq);
-		} else {
-			ia64_setreg(_IA64_REG_CR_TPR, vector);
-			ia64_srlz_d();
-
-			if (unlikely(irq < 0)) {
-				printk(KERN_ERR "%s: Unexpected interrupt "
-				       "vector %d on CPU %d is not mapped "
-				       "to any IRQ!\n", __func__, vector,
-				       smp_processor_id());
-			} else
-				generic_handle_irq(irq);
-
-			/*
-			 * Disable interrupts and send EOI:
-			 */
-			local_irq_disable();
-			ia64_setreg(_IA64_REG_CR_TPR, saved_tpr);
-		}
-		ia64_eoi();
-		vector = ia64_get_ivr();
-	}
-	/*
-	 * This must be done *after* the ia64_eoi().  For example, the keyboard softirq
-	 * handler needs to be able to wait for further keyboard interrupts, which can't
-	 * come through until ia64_eoi() has been done.
-	 */
-	irq_exit();
-	set_irq_regs(old_regs);
-}
 
 #ifdef CONFIG_HOTPLUG_CPU
 /*
-- 
1.7.10.4

