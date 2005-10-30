From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Sun, 30 Oct 2005 01:47:04 +0000
Subject: [patch] make mmu_context.h and tlb.c 80-column friendly
Message-Id: <200510300147.j9U1l5g11142@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

wrap_mmu_context(), delayed_tlb_flush(), get_mmu_context() all
have an extra { } block which cause one extra indentation.
get_mmu_context() is particularly bad with 5 indentations to
the most inner "if".  It finally gets on my nerve that I can't
keep the code within 80 columns.  Remove the extra { } block
and while I'm at it, reformat all the comments to 80-column
friendly.  No functional change at all with this patch.

patch is relative to linus-git tree as of Oct-29 17:20 PST +
Peter's mmu context bitmap patch + my v2 get_mmu_context.patch.


Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>

--- ./arch/ia64/mm/tlb.c.orig	2005-10-29 17:19:14.000000000 -0700
+++ ./arch/ia64/mm/tlb.c	2005-10-29 17:25:24.000000000 -0700
@@ -30,7 +30,7 @@
 
 static struct {
 	unsigned long mask;	/* mask of supported purge page-sizes */
-	unsigned long max_bits;	/* log2() of largest supported purge page-size */
+	unsigned long max_bits;	/* log2 of largest supported purge page-size */
 } purge;
 
 struct ia64_ctx ia64_ctx = {
@@ -59,7 +59,7 @@ mmu_context_init (void)
 void
 wrap_mmu_context (struct mm_struct *mm)
 {
-	int i;
+	int i, cpu;
 	unsigned long flush_bit;
 
 	for (i=0; i <= ia64_ctx.max_ctx / BITS_PER_LONG; i++) {
@@ -73,20 +73,21 @@ wrap_mmu_context (struct mm_struct *mm)
 	ia64_ctx.limit = find_next_bit(ia64_ctx.bitmap,
 				ia64_ctx.max_ctx, ia64_ctx.next);
 
-	/* can't call flush_tlb_all() here because of race condition with O(1) scheduler [EF] */
-	{
-		int cpu = get_cpu(); /* prevent preemption/migration */
-		for_each_online_cpu(i) {
-			if (i != cpu)
-				per_cpu(ia64_need_tlb_flush, i) = 1;
-		}
-		put_cpu();
-	}
+	/*
+	 * can't call flush_tlb_all() here because of race condition
+	 * with O(1) scheduler [EF]
+	 */
+	cpu = get_cpu(); /* prevent preemption/migration */
+	for_each_online_cpu(i)
+		if (i != cpu)
+			per_cpu(ia64_need_tlb_flush, i) = 1;
+	put_cpu();
 	local_flush_tlb_all();
 }
 
 void
-ia64_global_tlb_purge (struct mm_struct *mm, unsigned long start, unsigned long end, unsigned long nbits)
+ia64_global_tlb_purge (struct mm_struct *mm, unsigned long start,
+		       unsigned long end, unsigned long nbits)
 {
 	static DEFINE_SPINLOCK(ptcg_lock);
 
@@ -134,7 +135,8 @@ local_flush_tlb_all (void)
 }
 
 void
-flush_tlb_range (struct vm_area_struct *vma, unsigned long start, unsigned long end)
+flush_tlb_range (struct vm_area_struct *vma, unsigned long start,
+		 unsigned long end)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	unsigned long size = end - start;
@@ -148,7 +150,8 @@ flush_tlb_range (struct vm_area_struct *
 #endif
 
 	nbits = ia64_fls(size + 0xfff);
-	while (unlikely (((1UL << nbits) & purge.mask) = 0) && (nbits < purge.max_bits))
+	while (unlikely (((1UL << nbits) & purge.mask) = 0) &&
+			(nbits < purge.max_bits))
 		++nbits;
 	if (nbits > purge.max_bits)
 		nbits = purge.max_bits;
@@ -188,5 +191,5 @@ ia64_tlb_init (void)
 	local_cpu_data->ptce_stride[0] = ptce_info.stride[0];
 	local_cpu_data->ptce_stride[1] = ptce_info.stride[1];
 
-	local_flush_tlb_all();		/* nuke left overs from bootstrapping... */
+	local_flush_tlb_all();	/* nuke left overs from bootstrapping... */
 }
--- ./include/asm-ia64/mmu_context.h.orig	2005-10-29 17:06:59.000000000 -0700
+++ ./include/asm-ia64/mmu_context.h	2005-10-29 17:18:54.000000000 -0700
@@ -7,12 +7,13 @@
  */
 
 /*
- * Routines to manage the allocation of task context numbers.  Task context numbers are
- * used to reduce or eliminate the need to perform TLB flushes due to context switches.
- * Context numbers are implemented using ia-64 region ids.  Since the IA-64 TLB does not
- * consider the region number when performing a TLB lookup, we need to assign a unique
- * region id to each region in a process.  We use the least significant three bits in a
- * region id for this purpose.
+ * Routines to manage the allocation of task context numbers.  Task context
+ * numbers are used to reduce or eliminate the need to perform TLB flushes
+ * due to context switches.  Context numbers are implemented using ia-64
+ * region ids.  Since the IA-64 TLB does not consider the region number when
+ * performing a TLB lookup, we need to assign a unique region id to each
+ * region in a process.  We use the least significant three bits in aregion
+ * id for this purpose.
  */
 
 #define IA64_REGION_ID_KERNEL	0 /* the kernel's region id (tlb.c depends on this being 0) */
@@ -51,10 +52,10 @@ enter_lazy_tlb (struct mm_struct *mm, st
 }
 
 /*
- * When the context counter wraps around all TLBs need to be flushed because an old
- * context number might have been reused. This is signalled by the ia64_need_tlb_flush
- * per-CPU variable, which is checked in the routine below. Called by activate_mm().
- * <efocht@ess.nec.de>
+ * When the context counter wraps around all TLBs need to be flushed because
+ * an old context number might have been reused. This is signalled by the
+ * ia64_need_tlb_flush per-CPU variable, which is checked in the routine
+ * below. Called by activate_mm(). <efocht@ess.nec.de>
  */
 static inline void
 delayed_tlb_flush (void)
@@ -64,11 +65,9 @@ delayed_tlb_flush (void)
 
 	if (unlikely(__ia64_per_cpu_var(ia64_need_tlb_flush))) {
 		spin_lock_irqsave(&ia64_ctx.lock, flags);
-		{
-			if (__ia64_per_cpu_var(ia64_need_tlb_flush)) {
-				local_flush_tlb_all();
-				__ia64_per_cpu_var(ia64_need_tlb_flush) = 0;
-			}
+		if (__ia64_per_cpu_var(ia64_need_tlb_flush)) {
+			local_flush_tlb_all();
+			__ia64_per_cpu_var(ia64_need_tlb_flush) = 0;
 		}
 		spin_unlock_irqrestore(&ia64_ctx.lock, flags);
 	}
@@ -80,27 +79,27 @@ get_mmu_context (struct mm_struct *mm)
 	unsigned long flags;
 	nv_mm_context_t context = mm->context;
 
-	if (unlikely(!context)) {
-		spin_lock_irqsave(&ia64_ctx.lock, flags);
-		{
-			/* re-check, now that we've got the lock: */
-			context = mm->context;
-			if (context = 0) {
-				cpus_clear(mm->cpu_vm_mask);
-				if (ia64_ctx.next >= ia64_ctx.limit) {
-					ia64_ctx.next = find_next_zero_bit(ia64_ctx.bitmap,
-							ia64_ctx.max_ctx, ia64_ctx.next);
-					ia64_ctx.limit = find_next_bit(ia64_ctx.bitmap,
-	                                                ia64_ctx.max_ctx, ia64_ctx.next);
-					if (ia64_ctx.next >= ia64_ctx.max_ctx)
-						wrap_mmu_context(mm);
-				}
-				mm->context = context = ia64_ctx.next++;
- 				__set_bit(context, ia64_ctx.bitmap);
-			}
+	if (likely(context))
+		goto out;
+
+	spin_lock_irqsave(&ia64_ctx.lock, flags);
+	/* re-check, now that we've got the lock: */
+	context = mm->context;
+	if (context = 0) {
+		cpus_clear(mm->cpu_vm_mask);
+		if (ia64_ctx.next >= ia64_ctx.limit) {
+			ia64_ctx.next = find_next_zero_bit(ia64_ctx.bitmap,
+					ia64_ctx.max_ctx, ia64_ctx.next);
+			ia64_ctx.limit = find_next_bit(ia64_ctx.bitmap,
+					 ia64_ctx.max_ctx, ia64_ctx.next);
+			if (ia64_ctx.next >= ia64_ctx.max_ctx)
+				wrap_mmu_context(mm);
 		}
-		spin_unlock_irqrestore(&ia64_ctx.lock, flags);
+		mm->context = context = ia64_ctx.next++;
+ 		__set_bit(context, ia64_ctx.bitmap);
 	}
+	spin_unlock_irqrestore(&ia64_ctx.lock, flags);
+out:
 	/*
 	 * Ensure we're not starting to use "context" before any old
 	 * uses of it are gone from our TLB.
@@ -111,8 +110,8 @@ get_mmu_context (struct mm_struct *mm)
 }
 
 /*
- * Initialize context number to some sane value.  MM is guaranteed to be a brand-new
- * address-space, so no TLB flushing is needed, ever.
+ * Initialize context number to some sane value.  MM is guaranteed to be a
+ * brand-new address-space, so no TLB flushing is needed, ever.
  */
 static inline int
 init_new_context (struct task_struct *p, struct mm_struct *mm)
@@ -173,7 +172,10 @@ activate_context (struct mm_struct *mm)
 		if (!cpu_isset(smp_processor_id(), mm->cpu_vm_mask))
 			cpu_set(smp_processor_id(), mm->cpu_vm_mask);
 		reload_context(context);
-		/* in the unlikely event of a TLB-flush by another thread, redo the load: */
+		/*
+		 * in the unlikely event of a TLB-flush by another thread,
+		 * redo the load.
+		 */
 	} while (unlikely(context != mm->context));
 }
 
@@ -186,8 +188,8 @@ static inline void
 activate_mm (struct mm_struct *prev, struct mm_struct *next)
 {
 	/*
-	 * We may get interrupts here, but that's OK because interrupt handlers cannot
-	 * touch user-space.
+	 * We may get interrupts here, but that's OK because interrupt
+	 * handlers cannot touch user-space.
 	 */
 	ia64_set_kr(IA64_KR_PT_BASE, __pa(next->pgd));
 	activate_context(next);

