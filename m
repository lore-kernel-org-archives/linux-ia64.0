From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Fri, 07 Jan 2005 00:21:12 +0000
Subject: [PATCH] long line & codingstyle cleanup for tlb.c
Message-Id: <200501061621.12475.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_4Xd3BlT2JW8CRHN"
List-Id: <linux-ia64.vger.kernel.org>
References: <200501061617.51354.jbarnes@engr.sgi.com>
In-Reply-To: <200501061617.51354.jbarnes@engr.sgi.com>
To: linux-ia64@vger.kernel.org

--Boundary-00=_4Xd3BlT2JW8CRHN
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Fixup long lines and coding style in tlb.c.

Signed-off-by: Jesse Barnes <jbarnes@sgi.com>

Thanks,
Jesse

--Boundary-00=_4Xd3BlT2JW8CRHN
Content-Type: text/plain;
  charset="us-ascii";
  name="tlb-cleanup.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="tlb-cleanup.patch"

===== arch/ia64/mm/tlb.c 1.23 vs edited =====
--- 1.23/arch/ia64/mm/tlb.c	2004-10-05 11:24:11 -07:00
+++ edited/arch/ia64/mm/tlb.c	2005-01-06 16:11:49 -08:00
@@ -16,7 +16,6 @@
 #include <linux/sched.h>
 #include <linux/smp.h>
 #include <linux/mm.h>
-
 #include <asm/delay.h>
 #include <asm/mmu_context.h>
 #include <asm/pgalloc.h>
@@ -25,13 +24,15 @@
 
 static struct {
 	unsigned long mask;	/* mask of supported purge page-sizes */
-	unsigned long max_bits;	/* log2() of largest supported purge page-size */
+	unsigned long max_bits;	/* log2() of largest supported purge
+				   page-size */
 } purge;
 
 struct ia64_ctx ia64_ctx = {
 	.lock =		SPIN_LOCK_UNLOCKED,
 	.next =		1,
-	.limit =	(1 << 15) - 1,		/* start out with the safe (architected) limit */
+	.limit =	(1 << 15) - 1, /* start out with the safe
+					  (architected) limit */
 	.max_ctx =	~0U
 };
 
@@ -40,12 +41,11 @@
 /*
  * Acquire the ia64_ctx.lock before calling this function!
  */
-void
-wrap_mmu_context (struct mm_struct *mm)
+void wrap_mmu_context(struct mm_struct *mm)
 {
 	unsigned long tsk_context, max_ctx = ia64_ctx.max_ctx;
 	struct task_struct *tsk;
-	int i;
+	int i, cpu;
 
 	if (ia64_ctx.next > max_ctx)
 		ia64_ctx.next = 300;	/* skip daemons */
@@ -54,7 +54,6 @@
 	/*
 	 * Scan all the task's mm->context and set proper safe range
 	 */
-
 	read_lock(&tasklist_lock);
   repeat:
 	for_each_process(tsk) {
@@ -63,30 +62,33 @@
 		tsk_context = tsk->mm->context;
 		if (tsk_context == ia64_ctx.next) {
 			if (++ia64_ctx.next >= ia64_ctx.limit) {
-				/* empty range: reset the range limit and start over */
+				/* empty range: reset the range limit and
+				   start over */
 				if (ia64_ctx.next > max_ctx)
 					ia64_ctx.next = 300;
 				ia64_ctx.limit = max_ctx + 1;
 				goto repeat;
 			}
 		}
-		if ((tsk_context > ia64_ctx.next) && (tsk_context < ia64_ctx.limit))
+		if ((tsk_context > ia64_ctx.next) &&
+		    (tsk_context < ia64_ctx.limit))
 			ia64_ctx.limit = tsk_context;
 	}
 	read_unlock(&tasklist_lock);
-	/* can't call flush_tlb_all() here because of race condition with O(1) scheduler [EF] */
-	{
-		int cpu = get_cpu(); /* prevent preemption/migration */
-		for (i = 0; i < NR_CPUS; ++i)
-			if (cpu_online(i) && (i != cpu))
-				per_cpu(ia64_need_tlb_flush, i) = 1;
-		put_cpu();
-	}
+	/*
+	 * can't call flush_tlb_all() here because of race condition with
+	 * O(1) scheduler [EF]
+	 */
+	cpu = get_cpu(); /* prevent preemption/migration */
+	for (i = 0; i < NR_CPUS; ++i)
+		if (cpu_online(i) && (i != cpu))
+			per_cpu(ia64_need_tlb_flush, i) = 1;
+	put_cpu();
 	local_flush_tlb_all();
 }
 
-void
-ia64_global_tlb_purge (unsigned long start, unsigned long end, unsigned long nbits)
+void ia64_global_tlb_purge(unsigned long start, unsigned long end,
+			   unsigned long nbits)
 {
 	static spinlock_t ptcg_lock = SPIN_LOCK_UNLOCKED;
 
@@ -105,8 +107,7 @@
 	spin_unlock(&ptcg_lock);
 }
 
-void
-local_flush_tlb_all (void)
+void local_flush_tlb_all(void)
 {
 	unsigned long i, j, flags, count0, count1, stride0, stride1, addr;
 
@@ -129,15 +130,16 @@
 }
 EXPORT_SYMBOL(local_flush_tlb_all);
 
-void
-flush_tlb_range (struct vm_area_struct *vma, unsigned long start, unsigned long end)
+void flush_tlb_range(struct vm_area_struct *vma, unsigned long start,
+		     unsigned long end)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	unsigned long size = end - start;
 	unsigned long nbits;
 
 	if (mm != current->active_mm) {
-		/* this does happen, but perhaps it's not worth optimizing for? */
+		/* this does happen, but perhaps it's not worth optimizing
+		   for? */
 #ifdef CONFIG_SMP
 		flush_tlb_all();
 #else
@@ -147,27 +149,27 @@
 	}
 
 	nbits = ia64_fls(size + 0xfff);
-	while (unlikely (((1UL << nbits) & purge.mask) == 0) && (nbits < purge.max_bits))
+	while (unlikely (((1UL << nbits) & purge.mask) == 0) &&
+	       (nbits < purge.max_bits))
 		++nbits;
 	if (nbits > purge.max_bits)
 		nbits = purge.max_bits;
 	start &= ~((1UL << nbits) - 1);
 
-# ifdef CONFIG_SMP
+#ifdef CONFIG_SMP
 	platform_global_tlb_purge(start, end, nbits);
-# else
+#else
 	do {
 		ia64_ptcl(start, (nbits<<2));
 		start += (1UL << nbits);
 	} while (start < end);
-# endif
+#endif
 
 	ia64_srlz_i();			/* srlz.i implies srlz.d */
 }
 EXPORT_SYMBOL(flush_tlb_range);
 
-void __devinit
-ia64_tlb_init (void)
+void __devinit ia64_tlb_init(void)
 {
 	ia64_ptce_info_t ptce_info;
 	unsigned long tr_pgbits;
@@ -175,7 +177,8 @@
 
 	if ((status = ia64_pal_vm_page_size(&tr_pgbits, &purge.mask)) != 0) {
 		printk(KERN_ERR "PAL_VM_PAGE_SIZE failed with status=%ld;"
-		       "defaulting to architected purge page-sizes.\n", status);
+		       "defaulting to architected purge page-sizes.\n",
+		       status);
 		purge.mask = 0x115557000UL;
 	}
 	purge.max_bits = ia64_fls(purge.mask);
@@ -187,5 +190,5 @@
 	local_cpu_data->ptce_stride[0] = ptce_info.stride[0];
 	local_cpu_data->ptce_stride[1] = ptce_info.stride[1];
 
-	local_flush_tlb_all();		/* nuke left overs from bootstrapping... */
+	local_flush_tlb_all(); /* nuke left overs from bootstrapping... */
 }

--Boundary-00=_4Xd3BlT2JW8CRHN--
