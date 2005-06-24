From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Fri, 24 Jun 2005 04:14:14 +0000
Subject: Fix another IA64 preemption problem
Message-Id: <17083.34966.808455.428454@berry.gelato.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


There's another problem shown up by MIngo's recent patch to make
smp_processor_id() complain if it's called with preemption enabled.
local_finish_flush_tlb_mm() calls activate_context() in a situation
where it could be rescheduled to another processor.  This patch
disables preemption around the call.

Signed-off-by: Peter Chubb <peterc@gelato.unsw.edu.au>


Index: arch/ia64/kernel/smp.c
=================================--- fc736377c5c7e23ee78569392ed31a6030289e44/arch/ia64/kernel/smp.c  (mode:100644)
+++ uncommitted/arch/ia64/kernel/smp.c  (mode:100644)
@@ -231,13 +231,16 @@
 void
 smp_flush_tlb_mm (struct mm_struct *mm)
 {
+	preempt_disable();
 	/* this happens for the common case of a single-threaded fork():  */
 	if (likely(mm = current->active_mm && atomic_read(&mm->mm_users) = 1))
 	{
 		local_finish_flush_tlb_mm(mm);
+		preempt_enable();
 		return;
 	}
 
+	preempt_enable();
 	/*
 	 * We could optimize this further by using mm->cpu_vm_mask to track which CPUs
 	 * have been running in the address space.  It's not clear that this is worth the
Index: include/asm-ia64/mmu_context.h
=================================--- fc736377c5c7e23ee78569392ed31a6030289e44/include/asm-ia64/mmu_context.h  (mode:100644)
+++ uncommitted/include/asm-ia64/mmu_context.h  (mode:100644)
@@ -132,6 +132,9 @@
 	ia64_srlz_i();			/* srlz.i implies srlz.d */
 }
 
+/*
+ * Must be called with preemption off
+ */
 static inline void
 activate_context (struct mm_struct *mm)
 {
