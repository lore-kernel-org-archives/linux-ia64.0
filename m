From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Tue, 11 Mar 2003 03:44:14 +0000
Subject: [Linux-ia64] Memory leak in 2.5.64
Message-Id: <marc-linux-ia64-105590709806020@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi David,
   The way that tasks need to be freed has changed since 2.5.61 --- I
think we need to do something like the attached patch (keep
__put_task_struct() in kernel/fork.c; have ia64-specific
free_task_struct() in arch/ia64/kernel/process.c)
otherwise the user_struct will never have its reference count deleted
and so will not be freed.


diff -Nur --exclude=RCS --exclude=CVS --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet linux-2.5.64-davidm/arch/ia64/kernel/process.c linux-2.5-EXPORT/arch/ia64/kernel/process.c
--- linux-2.5.64-davidm/arch/ia64/kernel/process.c	Mon Mar 10 19:27:27 2003
+++ linux-2.5-EXPORT/arch/ia64/kernel/process.c	Tue Mar 11 11:03:25 2003
@@ -751,7 +751,7 @@
 }
 
 void
-__put_task_struct (struct task_struct *tsk)
+free_task_struct(struct task_struct *tsk)
 {
-	free_pages((unsigned long) tsk, KERNEL_STACK_SIZE_ORDER);
+	free_pages((unsigned long)tsk, KERNEL_STACK_SIZE_ORDER);
 }
diff -Nur --exclude=RCS --exclude=CVS --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet linux-2.5.64-davidm/kernel/fork.c linux-2.5-EXPORT/kernel/fork.c
--- linux-2.5.64-davidm/kernel/fork.c	Mon Mar 10 19:28:27 2003
+++ linux-2.5-EXPORT/kernel/fork.c	Tue Mar 11 10:38:37 2003
@@ -38,7 +38,9 @@
 #include <asm/cacheflush.h>
 #include <asm/tlbflush.h>
 
+#ifndef CONFIG_IA64
 static kmem_cache_t *task_struct_cachep;
+#endif
 
 extern int copy_semundo(unsigned long clone_flags, struct task_struct *tsk);
 extern void exit_semundo(struct task_struct *tsk);
@@ -53,13 +55,6 @@
 
 rwlock_t tasklist_lock __cacheline_aligned = RW_LOCK_UNLOCKED;  /* outer */
 
-/*
- * A per-CPU task cache - this relies on the fact that
- * the very last portion of sys_exit() is executed with
- * preemption turned off.
- */
-static task_t *task_cache[NR_CPUS] __cacheline_aligned;
-
 int nr_processes(void)
 {
 	int cpu;
@@ -72,6 +67,14 @@
 	return total;
 }
 
+#ifndef CONFIG_IA64
+/*
+ * A per-CPU task cache - this relies on the fact that
+ * the very last portion of sys_exit() is executed with
+ * preemption turned off.
+ */
+task_t *task_cache[NR_CPUS] __cacheline_aligned;
+
 static void free_task_struct(struct task_struct *tsk)
 {
 	/*
@@ -95,8 +98,10 @@
 		put_cpu();
 	}
 }
+#else
+extern void free_task_struct(struct task_struct *tsk);
+#endif
 
-#if 0
 void __put_task_struct(struct task_struct *tsk)
 {
 	WARN_ON(!(tsk->state & (TASK_DEAD | TASK_ZOMBIE)));
@@ -107,7 +112,6 @@
 	free_uid(tsk->user);
 	free_task_struct(tsk);
 }
-#endif
 
 void add_wait_queue(wait_queue_head_t *q, wait_queue_t * wait)
 {
@@ -187,13 +191,14 @@
 void __init fork_init(unsigned long mempages)
 {
 	/* create a slab on which task_structs can be allocated */
+#ifndef CONFIG_IA64
 	task_struct_cachep  		kmem_cache_create("task_struct",
 				  sizeof(struct task_struct),0,
 				  SLAB_HWCACHE_ALIGN, NULL, NULL);
 	if (!task_struct_cachep)
 		panic("fork_init(): cannot create task_struct SLAB cache");
-
+#endif
 	/*
 	 * The default maximum number of threads is set to a safe
 	 * value: the thread structures can take up at most half
@@ -210,7 +215,7 @@
 	init_task.rlim[RLIMIT_NPROC].rlim_max = max_threads/2;
 }
 
-#if 1
+#ifdef CONFIG_IA64
 extern struct task_struct *dup_task_struct (struct task_struct *orig);
 #else
 
@@ -247,7 +252,6 @@
 }
 
 #endif
-
 #ifdef CONFIG_MMU
 static inline int dup_mmap(struct mm_struct * mm, struct mm_struct * oldmm)
 {

