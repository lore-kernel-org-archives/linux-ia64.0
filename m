From: Peter Keilty <peter.keilty@hp.com>
Date: Mon, 31 Oct 2005 21:44:47 +0000
Subject: RE: ctx_bitmap.patch_v3
Message-Id: <1130795087.3869.12.camel@rambler.zko.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony,

Corrects the very inefficent method of finding free context_ids in
get_mmu_context().
Instead of walking the task_list of all processes, 2 bitmaps are used to
efficently
store and lookup state, inuse and needs flushing. The entire rid address
space is now 
used before calling wrap_mmu_context and global tlb flushing.

Special thanks to Ken and Rohit for there review and modifications in
using a bit 
flushmap. 

Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>
Signed-off-by: Rohit Seth <rohit.seth@intel.com>
Signed-off-by: Peter Keilty <peter.keilty@hp.com>

--- linux-2.6.14-rc3_base/arch/ia64/mm/tlb.c	2005-08-28
19:41:01.000000000 -0400
+++ linux-2.6.14-rc3/arch/ia64/mm/tlb.c	2005-10-31 13:03:28.000000000
-0500
@@ -8,6 +8,8 @@
  *		Modified RID allocation for SMP
  *          Goutham Rao <goutham.rao@intel.com>
  *              IPI based ptc implementation and A-step IPI
implementation.
+ * Rohit Seth <rohit.seth@intel.com>
+ * Ken Chen <kenneth.w.chen@intel.com>
  */
 #include <linux/config.h>
 #include <linux/module.h>
@@ -16,12 +18,14 @@
 #include <linux/sched.h>
 #include <linux/smp.h>
 #include <linux/mm.h>
+#include <linux/bootmem.h>
 
 #include <asm/delay.h>
 #include <asm/mmu_context.h>
 #include <asm/pgalloc.h>
 #include <asm/pal.h>
 #include <asm/tlbflush.h>
+#include <asm/dma.h>
 
 static struct {
 	unsigned long mask;	/* mask of supported purge page-sizes */
@@ -31,49 +35,43 @@
 struct ia64_ctx ia64_ctx = {
 	.lock =		SPIN_LOCK_UNLOCKED,
 	.next =		1,
-	.limit =	(1 << 15) - 1,		/* start out with the safe (architected)
limit */
 	.max_ctx =	~0U
 };
 
 DEFINE_PER_CPU(u8, ia64_need_tlb_flush);
 
 /*
+ * Initializes the ia64_ctx.bitmap array based on max_ctx+1.
+ * Called after cpu_init() has setup ia64_ctx.max_ctx based on
+ * maximum RID that is supported by boot CPU.
+ */
+void __init
+mmu_context_init (void)
+{
+	ia64_ctx.bitmap = alloc_bootmem((ia64_ctx.max_ctx+1)>>3);
+	ia64_ctx.flushmap = alloc_bootmem((ia64_ctx.max_ctx+1)>>3);
+}
+
+/*
  * Acquire the ia64_ctx.lock before calling this function!
  */
 void
 wrap_mmu_context (struct mm_struct *mm)
 {
-	unsigned long tsk_context, max_ctx = ia64_ctx.max_ctx;
-	struct task_struct *tsk;
 	int i;
+	unsigned long flush_bit;
+
+	for (i=0; i <= ia64_ctx.max_ctx / BITS_PER_LONG; i++) {
+		flush_bit = xchg(&ia64_ctx.flushmap[i], 0);
+		ia64_ctx.bitmap[i] ^= flush_bit;
+	}
+ 
+	/* use offset at 300 to skip daemons */
+	ia64_ctx.next = find_next_zero_bit(ia64_ctx.bitmap,
+				ia64_ctx.max_ctx, 300);
+	ia64_ctx.limit = find_next_bit(ia64_ctx.bitmap,
+				ia64_ctx.max_ctx, ia64_ctx.next);
 
-	if (ia64_ctx.next > max_ctx)
-		ia64_ctx.next = 300;	/* skip daemons */
-	ia64_ctx.limit = max_ctx + 1;
-
-	/*
-	 * Scan all the task's mm->context and set proper safe range
-	 */
-
-	read_lock(&tasklist_lock);
-  repeat:
-	for_each_process(tsk) {
-		if (!tsk->mm)
-			continue;
-		tsk_context = tsk->mm->context;
-		if (tsk_context = ia64_ctx.next) {
-			if (++ia64_ctx.next >= ia64_ctx.limit) {
-				/* empty range: reset the range limit and start over */
-				if (ia64_ctx.next > max_ctx)
-					ia64_ctx.next = 300;
-				ia64_ctx.limit = max_ctx + 1;
-				goto repeat;
-			}
-		}
-		if ((tsk_context > ia64_ctx.next) && (tsk_context < ia64_ctx.limit))
-			ia64_ctx.limit = tsk_context;
-	}
-	read_unlock(&tasklist_lock);
 	/* can't call flush_tlb_all() here because of race condition with O(1)
scheduler [EF] */
 	{
 		int cpu = get_cpu(); /* prevent preemption/migration */
--- linux-2.6.14-rc3_base/arch/ia64/kernel/setup.c	2005-10-26
10:54:06.000000000 -0400
+++ linux-2.6.14-rc3/arch/ia64/kernel/setup.c	2005-10-31
12:58:29.000000000 -0500
@@ -419,6 +419,7 @@
 #endif
 
 	cpu_init();	/* initialize the bootstrap CPU */
+	mmu_context_init();	/* initialize context_id bitmap */
 
 #ifdef CONFIG_ACPI
 	acpi_boot_init();
--- linux-2.6.14-rc3_base/include/asm-ia64/mmu_context.h	2005-10-26
10:54:53.000000000 -0400
+++ linux-2.6.14-rc3/include/asm-ia64/mmu_context.h	2005-10-31
13:25:02.000000000 -0500
@@ -32,13 +32,17 @@
 struct ia64_ctx {
 	spinlock_t lock;
 	unsigned int next;	/* next context number to use */
-	unsigned int limit;	/* next >= limit => must call wrap_mmu_context()
*/
-	unsigned int max_ctx;	/* max. context value supported by all CPUs */
+	unsigned int limit;     /* available free range */
+	unsigned int max_ctx;   /* max. context value supported by all CPUs */
+				/* call wrap_mmu_context when next >= max */
+	unsigned long *bitmap;  /* bitmap size is max_ctx+1 */
+	unsigned long *flushmap;/* pending rid to be flushed */
 };
 
 extern struct ia64_ctx ia64_ctx;
 DECLARE_PER_CPU(u8, ia64_need_tlb_flush);
 
+extern void mmu_context_init (void);
 extern void wrap_mmu_context (struct mm_struct *mm);
 
 static inline void
@@ -83,9 +87,16 @@
 			context = mm->context;
 			if (context = 0) {
 				cpus_clear(mm->cpu_vm_mask);
-				if (ia64_ctx.next >= ia64_ctx.limit)
-					wrap_mmu_context(mm);
+				if (ia64_ctx.next >= ia64_ctx.limit) {
+					ia64_ctx.next = find_next_zero_bit(ia64_ctx.bitmap,
+							ia64_ctx.max_ctx, ia64_ctx.next);
+					ia64_ctx.limit = find_next_bit(ia64_ctx.bitmap,
+							ia64_ctx.max_ctx, ia64_ctx.next);
+					if (ia64_ctx.next >= ia64_ctx.max_ctx)
+						wrap_mmu_context(mm);
+				}
 				mm->context = context = ia64_ctx.next++;
+				__set_bit(context, ia64_ctx.bitmap);
 			}
 		}
 		spin_unlock_irqrestore(&ia64_ctx.lock, flags);
--- linux-2.6.14-rc3_base/include/asm-ia64/tlbflush.h	2005-08-28
19:41:01.000000000 -0400
+++ linux-2.6.14-rc3/include/asm-ia64/tlbflush.h	2005-10-31
10:56:44.000000000 -0500
@@ -51,6 +51,7 @@
 	if (!mm)
 		return;
 
+	set_bit(mm->context, ia64_ctx.flushmap);
 	mm->context = 0;
 
 	if (atomic_read(&mm->mm_users) = 0)


