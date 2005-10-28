From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 28 Oct 2005 18:06:28 +0000
Subject: RE:  ia64 get_mmu_context patch
Message-Id: <200510281806.j9SI6Sg23377@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200510271728.j9RHScS0002221922@kitche.zk3.dec.com>
In-Reply-To: <200510271728.j9RHScS0002221922@kitche.zk3.dec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Chen, Kenneth W wrote on Thursday, October 27, 2005 8:09 PM
> Here is the patch, on top of Peter's patch: Add a flush bitmap to
> track which rid can be recycled when wrap happens.  This optimization
> allows kernel to only wrap and flush tlb when the entire rid space is
> exhausted.  It should dramatically reduce number of rid wrap frequency
> compare to current implementation.
> 
> Lightly tested, I will do more thorough testing.  Also, I have a few
> things want to look at, especially in the area of setting the flushmap
> bit.  There are a few other areas to fine tune Peter's original patch
> as well.
> 
> --- ./include/asm-ia64/tlbflush.h.orig	2005-10-27 
> +++ ./include/asm-ia64/tlbflush.h	2005-10-27
> @@ -51,7 +51,8 @@ flush_tlb_mm (struct mm_struct *mm)
>  	if (!mm)
>  		return;
>  
> -	clear_bit(mm->context, ia64_ctx.bitmap);
> +	/* fix me: should we hold ia64_ctx.lock? */
> +	set_bit(mm->context, ia64_ctx.flushmap);
>  	mm->context = 0;

I convinced myself that I really need a lock here. Otherwise, It will
have write-after-write race with flushmap and cause ctx_id to leak.
Spin lock is the wrong kind of lock to use here because it should
allow concurrent updates between wrap_mmu_context().


Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>

--- ./arch/ia64/mm/tlb.c.orig	2005-10-28 01:13:23.083525760 -0700
+++ ./arch/ia64/mm/tlb.c	2005-10-28 01:51:13.934083880 -0700
@@ -35,6 +35,7 @@ static struct {
 
 struct ia64_ctx ia64_ctx = {
 	.lock =		SPIN_LOCK_UNLOCKED,
+	.flushmap_rwlock = RW_LOCK_UNLOCKED,
 	.next =		1,
 	.max_ctx =	~0U
 };
@@ -73,9 +74,12 @@ wrap_mmu_context (struct mm_struct *mm)
 {
 	int i;
 
+	write_lock(&ia64_ctx.flushmap_rwlock);
 	bitmap_xor(ia64_ctx.bitmap, ia64_ctx.bitmap,
 		   ia64_ctx.flushmap, ia64_ctx.max_ctx);
 	bitmap_zero(ia64_ctx.flushmap, ia64_ctx.max_ctx);
+	write_unlock(&ia64_ctx.flushmap_rwlock);
+
 	/* use offset at 300 to skip daemons */
 	ia64_ctx.next = find_next_zero_bit(ia64_ctx.bitmap,
 				ia64_ctx.max_ctx, 300);
--- ./include/asm-ia64/mmu_context.h.orig	2005-10-28 01:09:18.186067823 -0700
+++ ./include/asm-ia64/mmu_context.h	2005-10-28 01:49:44.337405290 -0700
@@ -31,11 +31,12 @@
 
 struct ia64_ctx {
 	spinlock_t lock;
+	rwlock_t   flushmap_rwlock;
 	unsigned int next;	/* next context number to use */
 	unsigned int max_ctx;	/* max. context value supported by all CPUs */
 				/* next > max_ctx => must call wrap_mmu_context() */
 	unsigned long *bitmap;	/* bitmap size is max_ctx+1 */
-	unsigned long *flushmap;/* pending rid to be flushed */
+	unsigned long *flushmap;/* pending ctx id to be flushed */
 };
 
 extern struct ia64_ctx ia64_ctx;
--- ./include/asm-ia64/tlbflush.h.orig	2005-10-28 01:08:49.198763490 -0700
+++ ./include/asm-ia64/tlbflush.h	2005-10-28 01:08:57.562044638 -0700
@@ -52,8 +52,9 @@ flush_tlb_mm (struct mm_struct *mm)
 	if (!mm)
 		return;
 
-	/* fix me: should we hold ia64_ctx.lock? */
-	set_bit(mm->context, ia64_ctx.flushmap);
+	read_lock(&ia64_ctx.flushmap_rwlock);
+	set_bit(mm->context, ia64_ctx.flushmap);
+	read_unlock(&ia64_ctx.flushmap_rwlock);
 	mm->context = 0;
 
 	if (atomic_read(&mm->mm_users) = 0)

