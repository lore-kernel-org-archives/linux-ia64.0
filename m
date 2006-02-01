From: cpw@sgi.com (Cliff Wickman)
Date: Wed, 01 Feb 2006 19:57:16 +0000
Subject: [PATCH 1/1] ia64: perfmon.c trips BUG_ON in put_page_testzero
Message-Id: <43E1129C.mailxEOB11K2KM@eag09.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



The problem occurs during exit processing when a task has
done a pfm_context_create() (and pfm_smpl_buffer_alloc()).

To trigger the problem requires:
 - that the task be interrupted (so that it does not unmap its smpl buffer)
 - that there is another process accessing its mm_struct

At exit:
  - sets its task->mm to null
  - calls mmput(). But the task's vmas are not unmapped because the mm_users
    count is still 1
    though pfm_flush() is unable to unmap the buffer vma, but it does
    "put" the buffer pages when it frees the kernel mapping (vm_struct).
  - closes the pfm file with pfm_flush() and pfm_close(), which un-reserve
    the smpl buffer pages, but the buffer vma is not released.

When that external task does the final mmput() on this mm_struct,
  the sampling buffer's vma is unmapped. This does the second put on its
  pages and trips the BUG_ON(page_count(p) = 0) in put_page_testzero(p)

This patch maintains a list of active pfm tasks and their mm_structs.
The list allows pfm_flush() to locate the exiting task's mm_struct so that
it can unmap the vma.
(this could be done without a list, but would require another field in the
 task_struct)
(this fix is not necessary for Stephane Eranian's perfmon2)

Diffed against 2.6.15-rc6

Signed-off-by: Cliff Wickman <cpw@sgi.com>
---

 arch/ia64/kernel/perfmon.c |  138 +++++++++++++++++++++++++++++++++++++++++----
 kernel/exit.c              |   10 +++
 2 files changed, 137 insertions(+), 11 deletions(-)

Index: linux-2.6.15-rc6/kernel/exit.c
=================================--- linux-2.6.15-rc6.orig/kernel/exit.c
+++ linux-2.6.15-rc6/kernel/exit.c
@@ -38,6 +38,11 @@
 extern void sem_exit (void);
 extern struct task_struct *child_reaper;
 
+#ifdef CONFIG_PERFMON
+void pfm_remove_task_from_list(struct task_struct *);
+extern int pfm_check_list;
+#endif
+
 int getrusage(struct task_struct *, int, struct rusage __user *);
 
 static void exit_mm(struct task_struct * tsk);
@@ -527,6 +532,11 @@ static void exit_mm(struct task_struct *
 	up_read(&mm->mmap_sem);
 	enter_lazy_tlb(mm, current);
 	task_unlock(tsk);
+#ifdef CONFIG_PERFMON
+	if (atomic_read(&mm->mm_users) = 1 && pfm_check_list) {
+		pfm_remove_task_from_list(current);
+	}
+#endif
 	mmput(mm);
 }
 
Index: linux-2.6.15-rc6/arch/ia64/kernel/perfmon.c
=================================--- linux-2.6.15-rc6.orig/arch/ia64/kernel/perfmon.c
+++ linux-2.6.15-rc6/arch/ia64/kernel/perfmon.c
@@ -535,6 +535,21 @@ static int pfm_flush(struct file *filp);
 #define pfm_get_cpu_var(v)		__ia64_per_cpu_var(v)
 #define pfm_get_cpu_data(a,b)		per_cpu(a, b)
 
+struct mm_struct	*pfm_lookup_mm(void);
+void			pfm_remove_task_from_list(struct task_struct *);
+void			pfm_record_tm(struct task_struct *);
+/* global:  for exit_mmap() to call us back when the mm_struct is removed */
+int			pfm_check_list=0;
+int			pfm_num_in_list;
+EXPORT_SYMBOL(pfm_check_list);
+struct pfm_task_mm {
+	struct list_head	pfm_tm_list;
+	struct task_struct	*pfm_taskp;
+ 	struct mm_struct	*pfm_mm;
+};
+rwlock_t		pfm_tmlist_lock;
+struct list_head	pfm_tm_list_head;
+
 static inline void
 pfm_put_task(struct task_struct *task)
 {
@@ -1394,13 +1409,13 @@ pfm_unreserve_session(pfm_context_t *ctx
  * a PROTECT_CTX() section.
  */
 static int
-pfm_remove_smpl_mapping(struct task_struct *task, void *vaddr, unsigned long size)
+pfm_remove_smpl_mapping(struct task_struct *task, struct mm_struct *mm, void *vaddr, unsigned long size)
 {
 	int r;
 
 	/* sanity checks */
-	if (task->mm = NULL || size = 0UL || vaddr = NULL) {
-		printk(KERN_ERR "perfmon: pfm_remove_smpl_mapping [%d] invalid context mm=%p\n", task->pid, task->mm);
+	if (mm = NULL || size = 0UL || vaddr = NULL) {
+		printk(KERN_ERR "perfmon: pfm_remove_smpl_mapping [%d] invalid context mm=%p\n", task->pid, mm);
 		return -EINVAL;
 	}
 
@@ -1409,13 +1424,13 @@ pfm_remove_smpl_mapping(struct task_stru
 	/*
 	 * does the actual unmapping
 	 */
-	down_write(&task->mm->mmap_sem);
+	down_write(&mm->mmap_sem);
 
 	DPRINT(("down_write done smpl_vaddr=%p size=%lu\n", vaddr, size));
 
-	r = pfm_do_munmap(task->mm, (unsigned long)vaddr, size, 0);
+	r = pfm_do_munmap(mm, (unsigned long)vaddr, size, 0);
 
-	up_write(&task->mm->mmap_sem);
+	up_write(&mm->mmap_sem);
 	if (r !=0) {
 		printk(KERN_ERR "perfmon: [%d] unable to unmap sampling buffer @%p size=%lu\n", task->pid, vaddr, size);
 	}
@@ -1493,6 +1508,12 @@ init_pfm_fs(void)
 		else
 			err = 0;
 	}
+
+	/* initialize task/mm list */
+	rwlock_init(&pfm_tmlist_lock);
+	INIT_LIST_HEAD(&pfm_tm_list_head);
+	pfm_num_in_list = 0;
+
 	return err;
 }
 
@@ -1773,6 +1794,7 @@ pfm_flush(struct file *filp)
 {
 	pfm_context_t *ctx;
 	struct task_struct *task;
+	struct mm_struct *mm;
 	struct pt_regs *regs;
 	unsigned long flags;
 	unsigned long smpl_buf_size = 0UL;
@@ -1876,11 +1898,14 @@ pfm_flush(struct file *filp)
 	 * ctx_smpl_vaddr must never be cleared because it is needed
 	 * by every task with access to the context
 	 *
-	 * When called from do_exit(), the mm context is gone already, therefore
-	 * mm is NULL, i.e., the VMA is already gone  and we do not have to
-	 * do anything here
+	 * When called from do_exit(), the mm context may still be present
+	 * if mm_users is not zero.  But the task mm pointer is set to null
+	 * at exit, so we have to use active_mm here.
+	 * (we are depending on the assumption that active_mm is not cleared
+	 *  at exit)
 	 */
-	if (ctx->ctx_smpl_vaddr && current->mm) {
+	mm = pfm_lookup_mm();
+	if (ctx->ctx_smpl_vaddr && mm && current->active_mm=mm) {
 		smpl_buf_vaddr = ctx->ctx_smpl_vaddr;
 		smpl_buf_size  = ctx->ctx_smpl_size;
 	}
@@ -1893,7 +1918,7 @@ pfm_flush(struct file *filp)
 	 * because some VM function reenables interrupts.
 	 *
 	 */
-	if (smpl_buf_vaddr) pfm_remove_smpl_mapping(current, smpl_buf_vaddr, smpl_buf_size);
+	if (smpl_buf_vaddr) pfm_remove_smpl_mapping(current, mm, smpl_buf_vaddr, smpl_buf_size);
 
 	return 0;
 }
@@ -1931,6 +1956,12 @@ pfm_close(struct inode *inode, struct fi
 		DPRINT(("bad magic\n"));
 		return -EBADF;
 	}
+
+	/* It is possible that this task went thru do_exit with
+	   mm_users > 1, in which case this task was not removed from
+           the list of pfm tasks with valid mm_struct's.  So make sure the
+	   task is removed from the list. */
+	pfm_remove_task_from_list(current);
 	
 	ctx = (pfm_context_t *)filp->private_data;
 	if (ctx = NULL) {
@@ -4333,6 +4364,9 @@ pfm_context_load(pfm_context_t *ctx, voi
 	 */
 	ctx->ctx_task = task;
 
+	/* record the task/mm for this task, as it now has a context */
+	pfm_record_tm(task);
+
 	if (is_system) {
 		/*
 		 * we load as stopped
@@ -6837,6 +6871,88 @@ pfm_inherit(struct task_struct *task, st
 	 * the psr bits are already set properly in copy_threads()
 	 */
 }
+
+/*
+ * record task_struct and mm_struct in the list of valid pfm mm_structs
+ */
+void
+pfm_record_tm(struct task_struct *task)
+{
+	struct pfm_task_mm *tm;
+	struct list_head *this, *next;
+
+	read_lock(&pfm_tmlist_lock);
+	list_for_each_safe(this, next, &pfm_tm_list_head) {
+		tm = list_entry(this, struct pfm_task_mm, pfm_tm_list);
+		if (tm->pfm_taskp = task) {
+			/* don't record it twice */
+			read_unlock(&pfm_tmlist_lock);
+			return;
+		}
+	}
+
+	tm = kmalloc(sizeof(struct pfm_task_mm), GFP_KERNEL);
+	if (!tm) {
+		read_unlock(&pfm_tmlist_lock);
+		return;
+	}
+	tm->pfm_taskp = task;
+	tm->pfm_mm = task->mm;
+	list_add_tail(&tm->pfm_tm_list, &pfm_tm_list_head);
+	pfm_num_in_list++;
+	read_unlock(&pfm_tmlist_lock);
+	return;
+}
+
+/*
+ * look up the current task in the list of valid pfm mm_structs
+ */
+struct mm_struct *
+pfm_lookup_mm()
+{
+	struct pfm_task_mm *tm;
+	struct list_head *this, *next;
+
+	read_lock(&pfm_tmlist_lock);
+	list_for_each_safe(this, next, &pfm_tm_list_head) {
+		tm = list_entry(this, struct pfm_task_mm, pfm_tm_list);
+		if (current = tm->pfm_taskp) {
+			read_unlock(&pfm_tmlist_lock);
+			return tm->pfm_mm;
+		}
+	}
+	read_unlock(&pfm_tmlist_lock);
+	return NULL;
+}
+
+/*
+ * called from exit_mmap when the task's mm_struct is removed
+ * (so that we do not use active_mm when it might point a freed mm_struct
+ *  (or another task's mm_struct))
+ */
+void
+pfm_remove_task_from_list(struct task_struct *task)
+{
+	struct pfm_task_mm *tm;
+	struct list_head *this, *next;
+
+	write_lock(&pfm_tmlist_lock);
+	list_for_each_safe(this, next, &pfm_tm_list_head) {
+		tm = list_entry(this, struct pfm_task_mm, pfm_tm_list);
+		if (current = tm->pfm_taskp) {
+			list_del(this);
+			kfree(tm);
+			pfm_num_in_list--;
+			/* clear the flag when all have been removed */
+			if (pfm_num_in_list = 0)
+				pfm_check_list=0;
+			write_unlock(&pfm_tmlist_lock);
+			return;
+		}
+	}
+	write_unlock(&pfm_tmlist_lock);
+	return;
+}
 #else  /* !CONFIG_PERFMON */
 asmlinkage long
 sys_perfmonctl (int fd, int cmd, void *arg, int count)
