From: Jack Steiner <steiner@sgi.com>
Date: Wed, 26 Nov 2003 15:43:01 +0000
Subject: TLB flushing on SGI platforms
Message-Id: <marc-linux-ia64-106986141016689@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


The SGI NUMA platform does not use the hardware "ptc" instruction
to flush TLBs. Instead, it has to write an MMR on the chipset on each
node to cause a TLB flush transaction to be placed on the bus. On
large systems, the overhead to broadcast the TLB flush to every node
in the system is one of the hot spots in the kernel.

In most cases, the TLB context being flushed has been loaded into
a small subset of the nodes. Flushing every node is unnecessary.

I'm looking for suggestions on the best way to limit TLB flushing so
that only the necessary nodes are flushed. Here is patch that
I believe will work. I added a bitmask to the mm_context_t to
track nodes where the context has been loaded. The TLB flush routine
issues the TLB flush requests only to these nodes.

Are there other/better ways that I can do this??


------------------------------------------------------------------------------



diff -Naur linux_base/arch/ia64/mm/tlb.c linux/arch/ia64/mm/tlb.c
--- linux_base/arch/ia64/mm/tlb.c	Tue Nov 25 10:03:46 2003
+++ linux/arch/ia64/mm/tlb.c	Tue Nov 25 10:41:25 2003
@@ -59,7 +59,7 @@
 	for_each_process(tsk) {
 		if (!tsk->mm)
 			continue;
-		tsk_context = tsk->mm->context;
+		tsk_context = tsk->mm->context.ctx;
 		if (tsk_context = ia64_ctx.next) {
 			if (++ia64_ctx.next >= ia64_ctx.limit) {
 				/* empty range: reset the range limit and start over */


diff -Naur linux_base/arch/ia64/sn/kernel/sn2/sn2_smp.c linux/arch/ia64/sn/kernel/sn2/sn2_smp.c
--- linux_base/arch/ia64/sn/kernel/sn2/sn2_smp.c	Tue Nov 25 10:03:46 2003
+++ linux/arch/ia64/sn/kernel/sn2/sn2_smp.c	Tue Nov 25 10:42:34 2003
@@ -98,6 +99,7 @@
 	int			cnode, mycnode, nasid, flushed=0;
 	volatile unsigned	long	*ptc0, *ptc1;
 	unsigned long		flags=0, data0, data1;
+	struct mm_struct	*mm=current->active_mm;
 
 	data0 = (1UL<<SH_PTC_0_A_SHFT) |
 		(nbits<<SH_PTC_0_PS_SHFT) |
@@ -113,9 +115,8 @@
 
 	do {
 		data1 = start | (1UL<<SH_PTC_1_START_SHFT);
-		for (cnode = 0; cnode < numnodes; cnode++) {
-			if (is_headless_node(cnode))
-				continue;
+		for (cnode=find_first_bit(&mm->context.node_history, numnodes); cnode < numnodes; 
+				cnode=find_next_bit(&mm->context.node_history, numnodes, ++cnode)) {
 			if (cnode = mycnode) {
 				asm volatile ("ptc.ga %0,%1;;srlz.i;;" :: "r"(start), "r"(nbits<<2) : "memory");
 			} else {


diff -Naur linux_base/include/asm-ia64/mmu.h linux/include/asm-ia64/mmu.h
--- linux_base/include/asm-ia64/mmu.h	Tue Nov 25 10:03:47 2003
+++ linux/include/asm-ia64/mmu.h	Tue Nov 25 10:45:19 2003
@@ -1,11 +1,20 @@
 #ifndef __MMU_H
 #define __MMU_H
 
+#ifdef CONFIG_NUMA
+#include <linux/cpumask.h>
+#endif
+
 /*
  * Type for a context number.  We declare it volatile to ensure proper ordering when it's
  * accessed outside of spinlock'd critical sections (e.g., as done in activate_mm() and
  * init_new_context()).
  */
-typedef volatile unsigned long mm_context_t;
+typedef struct {
+	volatile unsigned long ctx;
+#ifdef CONFIG_NUMA
+	cpumask_t node_history;			/* ZZZ change to nodemask_t when avail */
+#endif
+} mm_context_t;
 
 #endif


diff -Naur linux_base/include/asm-ia64/mmu_context.h linux/include/asm-ia64/mmu_context.h
--- linux_base/include/asm-ia64/mmu_context.h	Tue Nov 25 10:03:47 2003
+++ linux/include/asm-ia64/mmu_context.h	Tue Nov 25 11:03:41 2003
@@ -75,6 +75,12 @@
 {
 }
 
+static inline void
+clear_mm_context(struct mm_struct *mm)
+{
+	memset(&mm->context, 0, sizeof(mm->context));
+}
+
 /*
  * When the context counter wraps around all TLBs need to be flushed because an old
  * context number might have been reused. This is signalled by the ia64_need_tlb_flush
@@ -92,26 +98,27 @@
 	}
 }
 
-static inline mm_context_t
+static inline unsigned long
 get_mmu_context (struct mm_struct *mm)
 {
-	mm_context_t context = mm->context;
+	mm_context_t *context = &mm->context;
+	unsigned long ctx = context->ctx;
 
-	if (context)
-		return context;
+	if (ctx)
+		return ctx;
 
 	spin_lock(&ia64_ctx.lock);
 	{
 		/* re-check, now that we've got the lock: */
-		context = mm->context;
-		if (context = 0) {
+		ctx = context->ctx;
+		if (ctx = 0) {
 			if (ia64_ctx.next >= ia64_ctx.limit)
 				wrap_mmu_context(mm);
-			mm->context = context = ia64_ctx.next++;
+			context->ctx = ctx = ia64_ctx.next++;
 		}
 	}
 	spin_unlock(&ia64_ctx.lock);
-	return context;
+	return ctx;
 }
 
 /*
@@ -122,7 +129,7 @@
 init_new_context (struct task_struct *p, struct mm_struct *mm)
 {
 	MMU_TRACE('N', smp_processor_id(), mm, 0);
-	mm->context = 0;
+	clear_mm_context(mm);
 	return 0;
 }
 
@@ -134,7 +141,7 @@
 }
 
 static inline void
-reload_context (mm_context_t context)
+reload_context (unsigned int context)
 {
 	unsigned long rid;
 	unsigned long rid_incr = 0;
@@ -164,15 +171,18 @@
 static inline void
 activate_context (struct mm_struct *mm)
 {
-	mm_context_t context;
+	unsigned long ctx;
 
+#ifdef CONFIG_NUMA
+	set_bit(numa_node_id(), &mm->context.node_history);
+#endif
 	do {
-		context = get_mmu_context(mm);
+		ctx = get_mmu_context(mm);
 		MMU_TRACE('A', smp_processor_id(), mm, context);
-		reload_context(context);
+		reload_context(ctx);
 		MMU_TRACE('a', smp_processor_id(), mm, context);
 		/* in the unlikely event of a TLB-flush by another thread, redo the load: */
-	} while (unlikely(context != mm->context));
+	} while (unlikely(ctx != mm->context.ctx));
 }
 
 #define deactivate_mm(tsk,mm)					\



diff -Naur linux_base/include/asm-ia64/tlbflush.h linux/include/asm-ia64/tlbflush.h
--- linux_base/include/asm-ia64/tlbflush.h	Tue Nov 25 10:03:47 2003
+++ linux/include/asm-ia64/tlbflush.h	Tue Nov 25 10:47:48 2003
@@ -52,7 +52,7 @@
 	if (!mm)
 		goto out;
 
-	mm->context = 0;
+	clear_mm_context(mm);
 
 	if (atomic_read(&mm->mm_users) = 0)
 		goto out;		/* happens as a result of exit_mmap() */


diff -Naur linux_base/mm/memory.c linux/mm/memory.c
--- linux_base/mm/memory.c	Tue Nov 25 10:03:50 2003
+++ linux/mm/memory.c	Tue Nov 25 10:55:00 2003
@@ -572,9 +572,10 @@
 			if ((long)zap_bytes > 0)
 				continue;
 			if (need_resched()) {
+				int fullmm = (*tlbp)->fullmm;
 				tlb_finish_mmu(*tlbp, tlb_start, start);
 				cond_resched_lock(&mm->page_table_lock);
-				*tlbp = tlb_gather_mmu(mm, 0);
+				*tlbp = tlb_gather_mmu(mm, fullmm);
 				tlb_start_valid = 0;
 			}
 			zap_bytes = ZAP_BLOCK_SIZE;
-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


