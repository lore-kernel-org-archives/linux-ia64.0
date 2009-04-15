From: Dimitri Sivanich <sivanich@sgi.com>
Date: Wed, 15 Apr 2009 15:56:25 +0000
Subject: [PATCH] ia64: smp_flush_tlb_mm() should only send IPI's to cpus in
Message-Id: <20090415155625.GA26750@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Having flush_tlb_mm->smp_flush_tlb_mm() send an IPI to every cpu on the
system is occasionally triggering spin_lock contention in
generic_smp_call_function_interrupt().

The x86 arch only sends IPIs to the cpus in mm->cpu_vm_mask.  Does anybody
see any reason why ia64 shouldn't do this as well?

I have noticed significant improvement in this contention issue with the
following patch.

Signed-off-by: Dimitri Sivanich <sivanich@sgi.com>

---
 arch/ia64/kernel/smp.c |   13 +++++--------
 1 files changed, 5 insertions(+), 8 deletions(-)

diff --git a/arch/ia64/kernel/smp.c b/arch/ia64/kernel/smp.c
index 2ea4199..5c1787b 100644
--- a/arch/ia64/kernel/smp.c
+++ b/arch/ia64/kernel/smp.c
@@ -300,15 +300,12 @@ smp_flush_tlb_mm (struct mm_struct *mm)
 		return;
 	}
 
+	smp_call_function_mask(mm->cpu_vm_mask,
+		(void (*)(void *))local_finish_flush_tlb_mm, mm, 1);
+	local_irq_disable();
+	local_finish_flush_tlb_mm(mm);
+	local_irq_enable();
 	preempt_enable();
-	/*
-	 * We could optimize this further by using mm->cpu_vm_mask to track which CPUs
-	 * have been running in the address space.  It's not clear that this is worth the
-	 * trouble though: to avoid races, we have to raise the IPI on the target CPU
-	 * anyhow, and once a CPU is interrupted, the cost of local_flush_tlb_all() is
-	 * rather trivial.
-	 */
-	on_each_cpu((void (*)(void *))local_finish_flush_tlb_mm, mm, 1);
 }
 
 void arch_send_call_function_single_ipi(int cpu)
-- 
1.5.4.rc3

