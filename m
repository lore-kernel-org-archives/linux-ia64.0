From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 28 Oct 2005 03:09:11 +0000
Subject: RE:  ia64 get_mmu_context patch
Message-Id: <200510280309.j9S39Cg12482@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200510271728.j9RHScS0002221922@kitche.zk3.dec.com>
In-Reply-To: <200510271728.j9RHScS0002221922@kitche.zk3.dec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Chen, Kenneth W wrote on Thursday, October 27, 2005 7:55 PM
> I like the bitmap thing.  But what's up with all this old range
> finding code doing here?  You have a full bitmap that tracks used
> ctx_id, one more bitmap can be added to track pending flush. Then
> at the time of wrap, we can simply xor them to get full reusable
> rid.  With that, kernel will only wrap when entire rid space is
> exhausted.  I will post a patch.


Here is the patch, on top of Peter's patch: Add a flush bitmap to
track which rid can be recycled when wrap happens.  This optimization
allows kernel to only wrap and flush tlb when the entire rid space is
exhausted.  It should dramatically reduce number of rid wrap frequency
compare to current implementation.

Lightly tested, I will do more thorough testing.  Also, I have a few
things want to look at, especially in the area of setting the flushmap
bit.  There are a few other areas to fine tune Peter's original patch
as well.


Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>
Signed-off-by: Rohit Seth <rohit.seth@intel.com>

--- ./arch/ia64/mm/tlb.c.orig	2005-10-27 18:18:45.334807075 -0700
+++ ./arch/ia64/mm/tlb.c	2005-10-27 20:00:11.380630958 -0700
@@ -4,10 +4,13 @@
  * Copyright (C) 1998-2001, 2003 Hewlett-Packard Co
  *	David Mosberger-Tang <davidm@hpl.hp.com>
  *
+ * Copyright (C) 2000, 2002-2003, 2005 Intel Co
  * 08/02/00 A. Mallick <asit.k.mallick@intel.com>
  *		Modified RID allocation for SMP
  *          Goutham Rao <goutham.rao@intel.com>
  *              IPI based ptc implementation and A-step IPI implementation.
+ * Rohit Seth <rohit.seth@intel.com>
+ * Ken Chen <kenneth.w.chen@intel.com>
  */
 #include <linux/config.h>
 #include <linux/module.h>
@@ -33,7 +36,6 @@ static struct {
 struct ia64_ctx ia64_ctx = {
 	.lock =		SPIN_LOCK_UNLOCKED,
 	.next =		1,
-	.limit =	(1 << 15) - 1,		/* start out with the safe (architected) limit */
 	.max_ctx =	~0U
 };
 
@@ -55,6 +57,10 @@ mmu_context_init (void)
 							(ia64_ctx.max_ctx+1)>>3,
 							PAGE_SIZE,
 							__pa(MAX_DMA_ADDRESS));
+		ia64_ctx.flushmap = (unsigned long *)__alloc_bootmem(
+							(ia64_ctx.max_ctx+1)>>3,
+							PAGE_SIZE,
+							__pa(MAX_DMA_ADDRESS));
 	}
 	spin_unlock_irqrestore(&ia64_ctx.lock, flags);
 }
@@ -65,30 +71,14 @@ mmu_context_init (void)
 void
 wrap_mmu_context (struct mm_struct *mm)
 {
-	unsigned int next_ctx, max_ctx = ia64_ctx.max_ctx;
 	int i;
 
-	if (ia64_ctx.next > max_ctx)
-		ia64_ctx.next = 300;	/* skip daemons */
-	ia64_ctx.limit = max_ctx + 1;
-
-	/*
-	 * Scan the ia64_ctx bitmap and set proper safe range
-	 */
-repeat:
-	next_ctx = find_next_zero_bit(ia64_ctx.bitmap, ia64_ctx.limit, ia64_ctx.next);
-	if (next_ctx >= ia64_ctx.limit) {
-		smp_mb();
-		ia64_ctx.next = 300;	/* skip daemons */
-		goto repeat;
-	}
-	ia64_ctx.next = next_ctx;
-
-	next_ctx = find_next_bit(ia64_ctx.bitmap, ia64_ctx.limit, ia64_ctx.next);
-	if (next_ctx >= ia64_ctx.limit) {
-		next_ctx = ia64_ctx.limit;
-	}
-	ia64_ctx.limit = next_ctx;
+	bitmap_xor(ia64_ctx.bitmap, ia64_ctx.bitmap,
+		   ia64_ctx.flushmap, ia64_ctx.max_ctx);
+	bitmap_zero(ia64_ctx.flushmap, ia64_ctx.max_ctx);
+	/* use offset at 300 to skip daemons */
+	ia64_ctx.next = find_next_zero_bit(ia64_ctx.bitmap,
+				ia64_ctx.max_ctx, 300);
 
 	/* can't call flush_tlb_all() here because of race condition with O(1) scheduler [EF] */
 	{
--- ./include/asm-ia64/mmu_context.h.orig	2005-10-27 18:18:45.333830512 -0700
+++ ./include/asm-ia64/mmu_context.h	2005-10-27 19:59:00.928483384 -0700
@@ -32,9 +32,10 @@
 struct ia64_ctx {
 	spinlock_t lock;
 	unsigned int next;	/* next context number to use */
-	unsigned int limit;	/* next >= limit => must call wrap_mmu_context() */
 	unsigned int max_ctx;	/* max. context value supported by all CPUs */
+				/* next > max_ctx => must call wrap_mmu_context() */
 	unsigned long *bitmap;	/* bitmap size is max_ctx+1 */
+	unsigned long *flushmap;/* pending rid to be flushed */
 };
 
 extern struct ia64_ctx ia64_ctx;
@@ -85,7 +86,9 @@ get_mmu_context (struct mm_struct *mm)
 			context = mm->context;
 			if (context = 0) {
 				cpus_clear(mm->cpu_vm_mask);
-				if (ia64_ctx.next >= ia64_ctx.limit)
+				ia64_ctx.next = find_next_zero_bit(ia64_ctx.bitmap,
+						ia64_ctx.max_ctx, ia64_ctx.next);
+				if (ia64_ctx.next >= ia64_ctx.max_ctx)
 					wrap_mmu_context(mm);
 				mm->context = context = ia64_ctx.next++;
 	 			set_bit(context, ia64_ctx.bitmap);
--- ./include/asm-ia64/tlbflush.h.orig	2005-10-27 18:18:45.333830512 -0700
+++ ./include/asm-ia64/tlbflush.h	2005-10-27 19:59:39.373795413 -0700
@@ -51,7 +51,8 @@ flush_tlb_mm (struct mm_struct *mm)
 	if (!mm)
 		return;
 
-	clear_bit(mm->context, ia64_ctx.bitmap);
+	/* fix me: should we hold ia64_ctx.lock? */
+	set_bit(mm->context, ia64_ctx.flushmap);
 	mm->context = 0;
 
 	if (atomic_read(&mm->mm_users) = 0)


