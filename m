From: Christoph Lameter <clameter@sgi.com>
Date: Wed, 01 Dec 2004 23:49:21 +0000
Subject: [archive] sloppy rss
Message-Id: <Pine.LNX.4.58.0412011546090.5721@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This is the sloppy rss patch that used to be part of the page fault
scalability patches. It simply ignores races for rss updates since
the typically introduced error was less than 1%. The patch was judged to
be unsatisfactory since situations (such as extensive) swapping may
cause the rss counter to become wildly inaccurate. The inaccuracy caused
uneasy feelings all around.

Index: linux-2.6.9/include/linux/sched.h
=================================--- linux-2.6.9.orig/include/linux/sched.h	2004-11-29 12:18:11.000000000 -0800
+++ linux-2.6.9/include/linux/sched.h	2004-11-30 09:59:23.000000000 -0800
@@ -216,7 +216,7 @@
 	atomic_t mm_count;			/* How many references to "struct mm_struct" (users count as 1) */
 	int map_count;				/* number of VMAs */
 	struct rw_semaphore mmap_sem;
-	spinlock_t page_table_lock;		/* Protects page tables, mm->rss, mm->anon_rss */
+	spinlock_t page_table_lock;		/* Protects page tables */

 	struct list_head mmlist;		/* List of maybe swapped mm's.  These are globally strung
 						 * together off init_mm.mmlist, and are protected
@@ -252,6 +252,21 @@
 	struct kioctx		default_kioctx;
 };

+/*
+ * rss and anon_rss are incremented and decremented in some locations without
+ * proper locking. This function insures that these values do not become negative.
+ */
+static long inline get_rss(struct mm_struct *mm)
+{
+	long rss = mm->rss;
+
+	if (rss < 0)
+		 mm->rss = rss = 0;
+	if ((long)mm->anon_rss < 0)
+		mm->anon_rss = 0;
+	return rss;
+}
+
 struct sighand_struct {
 	atomic_t		count;
 	struct k_sigaction	action[_NSIG];
Index: linux-2.6.9/fs/proc/task_mmu.c
=================================--- linux-2.6.9.orig/fs/proc/task_mmu.c	2004-11-29 12:18:10.000000000 -0800
+++ linux-2.6.9/fs/proc/task_mmu.c	2004-11-30 09:59:23.000000000 -0800
@@ -22,7 +22,7 @@
 		"VmPTE:\t%8lu kB\n",
 		(mm->total_vm - mm->reserved_vm) << (PAGE_SHIFT-10),
 		mm->locked_vm << (PAGE_SHIFT-10),
-		mm->rss << (PAGE_SHIFT-10),
+		get_rss(mm) << (PAGE_SHIFT-10),
 		data << (PAGE_SHIFT-10),
 		mm->stack_vm << (PAGE_SHIFT-10), text, lib,
 		(PTRS_PER_PTE*sizeof(pte_t)*mm->nr_ptes) >> 10);
@@ -37,7 +37,9 @@
 int task_statm(struct mm_struct *mm, int *shared, int *text,
 	       int *data, int *resident)
 {
-	*shared = mm->rss - mm->anon_rss;
+	*shared = get_rss(mm) - mm->anon_rss;
+	if (*shared <0)
+		*shared = 0;
 	*text = (PAGE_ALIGN(mm->end_code) - (mm->start_code & PAGE_MASK))
 								>> PAGE_SHIFT;
 	*data = mm->total_vm - mm->shared_vm;
Index: linux-2.6.9/fs/proc/array.c
=================================--- linux-2.6.9.orig/fs/proc/array.c	2004-11-29 12:18:10.000000000 -0800
+++ linux-2.6.9/fs/proc/array.c	2004-11-30 09:59:23.000000000 -0800
@@ -420,7 +420,7 @@
 		jiffies_to_clock_t(task->it_real_value),
 		start_time,
 		vsize,
-		mm ? mm->rss : 0, /* you might want to shift this left 3 */
+		mm ? get_rss(mm) : 0, /* you might want to shift this left 3 */
 	        rsslim,
 		mm ? mm->start_code : 0,
 		mm ? mm->end_code : 0,
Index: linux-2.6.9/mm/rmap.c
=================================--- linux-2.6.9.orig/mm/rmap.c	2004-11-29 20:46:14.000000000 -0800
+++ linux-2.6.9/mm/rmap.c	2004-11-30 09:59:23.000000000 -0800
@@ -263,8 +263,6 @@
 	pte_t *pte;
 	int referenced = 0;

-	if (!mm->rss)
-		goto out;
 	address = vma_address(page, vma);
 	if (address = -EFAULT)
 		goto out;
@@ -510,8 +508,6 @@
 	pte_t pteval;
 	int ret = SWAP_AGAIN;

-	if (!mm->rss)
-		goto out;
 	address = vma_address(page, vma);
 	if (address = -EFAULT)
 		goto out;
@@ -799,8 +795,7 @@
 			if (vma->vm_flags & (VM_LOCKED|VM_RESERVED))
 				continue;
 			cursor = (unsigned long) vma->vm_private_data;
-			while (vma->vm_mm->rss &&
-				cursor < max_nl_cursor &&
+			while (cursor < max_nl_cursor &&
 				cursor < vma->vm_end - vma->vm_start) {
 				try_to_unmap_cluster(cursor, &mapcount, vma);
 				cursor += CLUSTER_SIZE;
