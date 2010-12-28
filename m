From: Dimitri Sivanich <sivanich@sgi.com>
Date: Tue, 28 Dec 2010 19:34:42 +0000
Subject: [PATCH] IA64: eliminate race condition in smp_flush_tlb_mm
Message-Id: <20101228193442.GA28269@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

A race condition exists within smp_call_function_many() when called from
smp_flush_tlb_mm().  On rare occasions the cpu_vm_mask can be cleared
while smp_call_function_many is executing, occasionally resulting in a
hung process.

Make a copy of the mask prior to calling smp_call_function_many().

Signed-off-by: Dimitri Sivanich <sivanich@sgi.com>

---
 arch/ia64/kernel/smp.c |   13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

Index: linux-2.6.36.2/arch/ia64/kernel/smp.c
=================================--- linux-2.6.36.2.orig/arch/ia64/kernel/smp.c	2010-12-28 13:13:16.261122111 -0600
+++ linux-2.6.36.2/arch/ia64/kernel/smp.c	2010-12-28 13:30:17.504590090 -0600
@@ -293,6 +293,7 @@ smp_flush_tlb_all (void)
 void
 smp_flush_tlb_mm (struct mm_struct *mm)
 {
+	cpumask_var_t cpus;
 	preempt_disable();
 	/* this happens for the common case of a single-threaded fork():  */
 	if (likely(mm = current->active_mm && atomic_read(&mm->mm_users) = 1))
@@ -301,9 +302,15 @@ smp_flush_tlb_mm (struct mm_struct *mm)
 		preempt_enable();
 		return;
 	}
-
-	smp_call_function_many(mm_cpumask(mm),
-		(void (*)(void *))local_finish_flush_tlb_mm, mm, 1);
+	if (!alloc_cpumask_var(&cpus, GFP_ATOMIC)) {
+		smp_call_function((void (*)(void *))local_finish_flush_tlb_mm,
+			mm, 1);
+	} else {
+		cpumask_copy(cpus, mm_cpumask(mm));
+		smp_call_function_many(cpus,
+			(void (*)(void *))local_finish_flush_tlb_mm, mm, 1);
+		free_cpumask_var(cpus);
+	}
 	local_irq_disable();
 	local_finish_flush_tlb_mm(mm);
 	local_irq_enable();
