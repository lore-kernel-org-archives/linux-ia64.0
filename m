From: Christoph Lameter <clameter@sgi.com>
Date: Wed, 01 Dec 2004 23:58:17 +0000
Subject: [archive] deferred rss calculation
Message-Id: <Pine.LNX.4.58.0412011555150.5721@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch defers rss calculation by first incrementing rss in the
task structure and then during the timer interrupt transfers the value
the value into mm->rss thereby avoiding locks and atomic operations.

However, as pointed out by Andrew, the timer interrupt may
not always occur when a process runs and thus significant inaccuracies
may result. Patch was abandoned and never became part of the page fault
scalablity patchset.

Index: linux-2.6.9/include/linux/sched.h
=================================--- linux-2.6.9.orig/include/linux/sched.h	2004-11-15 11:13:39.000000000 -0800
+++ linux-2.6.9/include/linux/sched.h	2004-11-22 14:18:25.000000000 -0800
@@ -584,6 +584,10 @@
 	unsigned long it_real_incr, it_prof_incr, it_virt_incr;
 	struct timer_list real_timer;
 	unsigned long utime, stime;
+	long rss;	/* rss counter when mm->rss is not usable. mm->page_table_lock
+			 * not held but mm->mmap_sem must be held for sync with
+			 * the timer interrupt which clears rss and updates mm->rss.
+			 */
 	unsigned long nvcsw, nivcsw; /* context switch counts */
 	struct timespec start_time;
 /* mm fault and swap info: this can arguably be seen as either mm-specific or thread-specific */
Index: linux-2.6.9/mm/rmap.c
=================================--- linux-2.6.9.orig/mm/rmap.c	2004-11-22 09:51:58.000000000 -0800
+++ linux-2.6.9/mm/rmap.c	2004-11-22 14:18:25.000000000 -0800
@@ -263,8 +263,6 @@
 	pte_t *pte;
 	int referenced = 0;

-	if (!mm->rss)
-		goto out;
 	address = vma_address(page, vma);
 	if (address = -EFAULT)
 		goto out;
@@ -507,8 +505,6 @@
 	pte_t pteval;
 	int ret = SWAP_AGAIN;

-	if (!mm->rss)
-		goto out;
 	address = vma_address(page, vma);
 	if (address = -EFAULT)
 		goto out;
@@ -791,8 +787,7 @@
 			if (vma->vm_flags & (VM_LOCKED|VM_RESERVED))
 				continue;
 			cursor = (unsigned long) vma->vm_private_data;
-			while (vma->vm_mm->rss &&
-				cursor < max_nl_cursor &&
+			while (cursor < max_nl_cursor &&
 				cursor < vma->vm_end - vma->vm_start) {
 				try_to_unmap_cluster(cursor, &mapcount, vma);
 				cursor += CLUSTER_SIZE;
Index: linux-2.6.9/kernel/fork.c
=================================--- linux-2.6.9.orig/kernel/fork.c	2004-11-22 09:51:58.000000000 -0800
+++ linux-2.6.9/kernel/fork.c	2004-11-22 14:18:25.000000000 -0800
@@ -876,6 +876,7 @@
 	p->io_context = NULL;
 	p->io_wait = NULL;
 	p->audit_context = NULL;
+	p->rss = 0;
 #ifdef CONFIG_NUMA
  	p->mempolicy = mpol_copy(p->mempolicy);
  	if (IS_ERR(p->mempolicy)) {
Index: linux-2.6.9/kernel/exit.c
=================================--- linux-2.6.9.orig/kernel/exit.c	2004-11-22 09:51:58.000000000 -0800
+++ linux-2.6.9/kernel/exit.c	2004-11-22 14:19:30.000000000 -0800
@@ -501,6 +501,10 @@
 	/* more a memory barrier than a real lock */
 	task_lock(tsk);
 	tsk->mm = NULL;
+	spin_lock(&mm->page_table_lock);
+	mm->rss += tsk->rss;
+	tsk->rss = 0;
+	spin_unlock(&mm->page_table_lock);
 	up_read(&mm->mmap_sem);
 	enter_lazy_tlb(mm, current);
 	task_unlock(tsk);
Index: linux-2.6.9/kernel/timer.c
=================================--- linux-2.6.9.orig/kernel/timer.c	2004-11-22 09:51:58.000000000 -0800
+++ linux-2.6.9/kernel/timer.c	2004-11-22 14:18:25.000000000 -0800
@@ -815,6 +815,15 @@
 		if (psecs / HZ >= p->signal->rlim[RLIMIT_CPU].rlim_max)
 			send_sig(SIGKILL, p, 1);
 	}
+	/* Update mm->rss if necessary */
+	if (p->rss && p->mm && down_write_trylock(&p->mm->mmap_sem)) {
+		if (spin_trylock(&p->mm->page_table_lock)) {
+			p->mm->rss += p->rss;
+			p->rss = 0;
+			spin_unlock(&p->mm->page_table_lock);
+		}
+		up_write(&p->mm->mmap_sem);
+	}
 }

 static inline void do_it_virt(struct task_struct * p, unsigned long ticks)
