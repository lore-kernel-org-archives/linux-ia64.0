From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Fri, 04 Jun 2004 02:43:18 +0000
Subject: [PATCH] consolidate architecture context switch locking
Message-Id: <40BFE1C6.70706@yahoo.com.au>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------050802010209070903020804"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------050802010209070903020804
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

I have a patch to simplify and consolidate architecture context switch
locking. Russell King's requirement that ARM have interrupts on during
context switch prompted me: there are now 3 different ctxsw locking
implementations throughout different arch files.

It didn't get a great deal of feedback from linux-arch, so I thought I
should ask if anyone could test on an architecture that is affected.

All ia64 has to do now is define __ARCH_WANT_UNLOCKED_CTXSW (which I
have done in the patch, of course). The unlocked context switch
implementation is also (hopefully) improved, with switch_lock replaced
by simple stores to a variable.

If anyone could test this on an ia64 would be great. I have tested
various combinations on an ia32 NUMAQ and it is stable there...

If you are interested in performance, lat_ctx or hackbench on a SMP
kernel running with maxcpus=1 would be a good test (the UP compiled
kernel will be slightly suboptimal with the patch, but that can easily
be fixed).

Stability wise, you'd need to test with an SMP system, the larger the
better.

It is diffed against 2.6.7-rc2-mm2, but should apply to any recent
-mm or -linus kernel.

Thanks
Nick

--------------050802010209070903020804
Content-Type: text/x-patch;
 name="task-running-flag.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="task-running-flag.patch"

 linux-2.6-npiggin/include/asm-arm/system.h     |   30 +-------
 linux-2.6-npiggin/include/asm-ia64/system.h    |   10 --
 linux-2.6-npiggin/include/asm-mips/system.h    |   10 --
 linux-2.6-npiggin/include/asm-s390/system.h    |    5 -
 linux-2.6-npiggin/include/asm-sparc/system.h   |    4 -
 linux-2.6-npiggin/include/asm-sparc64/system.h |   14 +---
 linux-2.6-npiggin/include/linux/init_task.h    |    1 
 linux-2.6-npiggin/include/linux/sched.h        |   10 ++
 linux-2.6-npiggin/kernel/sched.c               |   86 ++++++++++++++++++++-----
 9 files changed, 90 insertions(+), 80 deletions(-)

diff -puN kernel/sched.c~task-running-flag kernel/sched.c
--- linux-2.6/kernel/sched.c~task-running-flag	2004-06-04 12:28:05.000000000 +1000
+++ linux-2.6-npiggin/kernel/sched.c	2004-06-04 12:28:05.000000000 +1000
@@ -265,15 +265,59 @@ static DEFINE_PER_CPU(struct runqueue, r
 #define task_rq(p)		cpu_rq(task_cpu(p))
 #define cpu_curr(cpu)		(cpu_rq(cpu)->curr)
 
-/*
- * Default context-switch locking:
- */
 #ifndef prepare_arch_switch
-# define prepare_arch_switch(rq, next)	do { } while (0)
-# define finish_arch_switch(rq, next)	spin_unlock_irq(&(rq)->lock)
-# define task_running(rq, p)		((rq)->curr == (p))
+# define prepare_arch_switch(next)	do { } while (0)
+#endif
+#ifndef finish_arch_switch
+# define finish_arch_switch(prev)	do { } while (0)
 #endif
 
+#ifndef __ARCH_WANT_UNLOCKED_CTXSW
+static inline int task_running(runqueue_t *rq, task_t *p)
+{
+	return rq->curr == p;
+}
+
+static inline void prepare_lock_switch(runqueue_t *rq, task_t *next)
+{
+}
+
+static inline void finish_lock_switch(runqueue_t *rq, task_t *prev)
+{
+	spin_unlock_irq(&rq->lock);
+}
+
+#else /* __ARCH_WANT_UNLOCKED_CTXSW */
+static inline int task_running(runqueue_t *rq, task_t *p)
+{
+	return p->oncpu;
+}
+
+static inline void prepare_lock_switch(runqueue_t *rq, task_t *next)
+{
+	next->oncpu = 1;
+#ifdef __ARCH_WANT_INTERRUPTS_ON_CTXSW
+	spin_unlock_irq(&rq->lock);
+#else
+	spin_unlock(&rq->lock);
+#endif
+}
+
+static inline void finish_lock_switch(runqueue_t *rq, task_t *prev)
+{
+	/*
+	 * After ->oncpu is cleared, the task can be moved to a different CPU.
+	 * We must ensure this doesn't happen until the switch is completely
+	 * finished.
+	 */
+	smp_wmb();
+	prev->oncpu = 0;
+#ifndef __ARCH_WANT_INTERRUPTS_ON_CTXSW
+	local_irq_enable();
+#endif
+}
+#endif /* __ARCH_WANT_UNLOCKED_CTXSW */
+
 /*
  * task_rq_lock - lock the runqueue a given task resides on and disable
  * interrupts.  Note the ordering: we can safely lookup the task_rq without
@@ -1006,16 +1050,14 @@ void fastcall sched_fork(task_t *p)
 	p->state = TASK_RUNNING;
 	INIT_LIST_HEAD(&p->run_list);
 	p->array = NULL;
-	spin_lock_init(&p->switch_lock);
+#ifdef __ARCH_WANT_UNLOCKED_CTXSW
+	p->oncpu = 0;
+#endif
 #ifdef CONFIG_PREEMPT
-	/*
-	 * During context-switch we hold precisely one spinlock, which
-	 * schedule_tail drops. (in the common case it's this_rq()->lock,
-	 * but it also can be p->switch_lock.) So we compensate with a count
-	 * of 1. Also, we want to start with kernel preemption disabled.
-	 */
+	/* Want to start with kernel preemption disabled. */
 	p->thread_info->preempt_count = 1;
 #endif
+
 	/*
 	 * Share the timeslice between parent and child, thus the
 	 * total amount of pending timeslices in the system doesn't change,
@@ -1152,7 +1194,8 @@ static void finish_task_switch(task_t *p
 	 *		Manfred Spraul <manfred@colorfullife.com>
 	 */
 	prev_task_flags = prev->flags;
-	finish_arch_switch(rq, prev);
+	finish_arch_switch(prev);
+	finish_lock_switch(rq, prev);
 	if (mm)
 		mmdrop(mm);
 	if (unlikely(prev_task_flags & PF_DEAD))
@@ -1166,7 +1209,10 @@ static void finish_task_switch(task_t *p
 asmlinkage void schedule_tail(task_t *prev)
 {
 	finish_task_switch(prev);
-
+#ifdef __ARCH_WANT_UNLOCKED_CTXSW
+	/* In this case, finish_task_switch does not reenable preemption */
+	preempt_enable();
+#endif
 	if (current->set_child_tid)
 		put_user(current->pid, current->set_child_tid);
 }
@@ -2464,10 +2510,10 @@ switch_tasks:
 		rq->curr = next;
 		++*switch_count;
 
-		prepare_arch_switch(rq, next);
+		prepare_lock_switch(rq, next);
+		prepare_arch_switch(next);
 		prev = context_switch(rq, prev, next);
 		barrier();
-
 		finish_task_switch(prev);
 	} else
 		spin_unlock_irq(&rq->lock);
@@ -3429,6 +3475,9 @@ void __devinit init_idle(task_t *idle, i
 	double_rq_lock(idle_rq, rq);
 
 	idle_rq->curr = idle_rq->idle = idle;
+#ifdef __ARCH_WANT_UNLOCKED_CTXSW
+	idle->oncpu = 1;
+#endif
 	deactivate_task(idle, rq);
 	idle->array = NULL;
 	idle->prio = MAX_PRIO;
@@ -4124,6 +4173,9 @@ void __init sched_init(void)
 	rq = this_rq();
 	rq->curr = current;
 	rq->idle = current;
+#ifdef __ARCH_WANT_UNLOCKED_CTXSW
+	current->oncpu = 1;
+#endif
 	set_task_cpu(current, smp_processor_id());
 	wake_up_forked_process(current);
 
diff -puN include/linux/sched.h~task-running-flag include/linux/sched.h
--- linux-2.6/include/linux/sched.h~task-running-flag	2004-06-04 12:28:05.000000000 +1000
+++ linux-2.6-npiggin/include/linux/sched.h	2004-06-04 12:28:05.000000000 +1000
@@ -315,6 +315,11 @@ struct signal_struct {
 
 #define rt_task(p)		((p)->prio < MAX_RT_PRIO)
 
+/* Context switch must be unlocked if interrupts are to be enabled */
+#ifdef __ARCH_WANT_INTERRUPTS_ON_CTXSW
+# define __ARCH_WANT_UNLOCKED_CTXSW
+#endif
+
 /*
  * Some day this will be a full-fledged user tracking system..
  */
@@ -406,6 +411,9 @@ struct task_struct {
 
 	int lock_depth;		/* Lock depth */
 
+#ifdef __ARCH_WANT_UNLOCKED_CTXSW
+	int oncpu;
+#endif
 	int prio, static_prio;
 	struct list_head run_list;
 	prio_array_t *array;
@@ -508,8 +516,6 @@ struct task_struct {
 	spinlock_t alloc_lock;
 /* Protection of proc_dentry: nesting proc_lock, dcache_lock, write_lock_irq(&tasklist_lock); */
 	spinlock_t proc_lock;
-/* context-switch lock */
-	spinlock_t switch_lock;
 
 /* journalling filesystem info */
 	void *journal_info;
diff -puN include/linux/init_task.h~task-running-flag include/linux/init_task.h
--- linux-2.6/include/linux/init_task.h~task-running-flag	2004-06-04 12:28:05.000000000 +1000
+++ linux-2.6-npiggin/include/linux/init_task.h	2004-06-04 12:28:05.000000000 +1000
@@ -110,7 +110,6 @@ extern struct group_info init_groups;
 	.blocked	= {{0}},					\
 	.alloc_lock	= SPIN_LOCK_UNLOCKED,				\
 	.proc_lock	= SPIN_LOCK_UNLOCKED,				\
-	.switch_lock	= SPIN_LOCK_UNLOCKED,				\
 	.journal_info	= NULL,						\
 }
 
diff -puN include/asm-ia64/system.h~task-running-flag include/asm-ia64/system.h
--- linux-2.6/include/asm-ia64/system.h~task-running-flag	2004-06-04 12:28:05.000000000 +1000
+++ linux-2.6-npiggin/include/asm-ia64/system.h	2004-06-04 12:28:05.000000000 +1000
@@ -183,8 +183,6 @@ do {								\
 
 #ifdef __KERNEL__
 
-#define prepare_to_switch()    do { } while(0)
-
 #ifdef CONFIG_IA32_SUPPORT
 # define IS_IA32_PROCESS(regs)	(ia64_psr(regs)->is != 0)
 #else
@@ -274,13 +272,7 @@ extern void ia64_load_extra (struct task
  * of that CPU which will not be released, because there we wait for the
  * tasklist_lock to become available.
  */
-#define prepare_arch_switch(rq, next)		\
-do {						\
-	spin_lock(&(next)->switch_lock);	\
-	spin_unlock(&(rq)->lock);		\
-} while (0)
-#define finish_arch_switch(rq, prev)	spin_unlock_irq(&(prev)->switch_lock)
-#define task_running(rq, p) 		((rq)->curr == (p) || spin_is_locked(&(p)->switch_lock))
+#define __ARCH_WANT_UNLOCKED_CTXSW
 
 #define ia64_platform_is(x) (strcmp(x, platform_name) == 0)
 
diff -puN include/asm-mips/system.h~task-running-flag include/asm-mips/system.h
--- linux-2.6/include/asm-mips/system.h~task-running-flag	2004-06-04 12:28:05.000000000 +1000
+++ linux-2.6-npiggin/include/asm-mips/system.h	2004-06-04 12:28:05.000000000 +1000
@@ -491,15 +491,9 @@ static __inline__ int con_is_present(voi
 }
 
 /*
- * Taken from include/asm-ia64/system.h; prevents deadlock on SMP
+ * See include/asm-ia64/system.h; prevents deadlock on SMP
  * systems.
  */
-#define prepare_arch_switch(rq, next)		\
-do {						\
-	spin_lock(&(next)->switch_lock);	\
-	spin_unlock(&(rq)->lock);		\
-} while (0)
-#define finish_arch_switch(rq, prev)	spin_unlock_irq(&(prev)->switch_lock)
-#define task_running(rq, p) 		((rq)->curr == (p) || spin_is_locked(&(p)->switch_lock))
+#define __ARCH_WANT_UNLOCKED_CTXSW
 
 #endif /* _ASM_SYSTEM_H */
diff -puN include/asm-s390/system.h~task-running-flag include/asm-s390/system.h
--- linux-2.6/include/asm-s390/system.h~task-running-flag	2004-06-04 12:28:05.000000000 +1000
+++ linux-2.6-npiggin/include/asm-s390/system.h	2004-06-04 12:28:05.000000000 +1000
@@ -103,11 +103,8 @@ static inline void restore_access_regs(u
 	prev = __switch_to(prev,next);					     \
 } while (0)
 
-#define prepare_arch_switch(rq, next)	do { } while(0)
-#define task_running(rq, p)		((rq)->curr == (p))
-#define finish_arch_switch(rq, prev) do {				     \
+#define finish_arch_switch(prev) do {					     \
 	set_fs(current->thread.mm_segment);				     \
-	spin_unlock_irq(&(rq)->lock);					     \
 } while (0)
 
 #define nop() __asm__ __volatile__ ("nop")
diff -puN include/asm-sparc/system.h~task-running-flag include/asm-sparc/system.h
--- linux-2.6/include/asm-sparc/system.h~task-running-flag	2004-06-04 12:28:05.000000000 +1000
+++ linux-2.6-npiggin/include/asm-sparc/system.h	2004-06-04 12:28:05.000000000 +1000
@@ -101,7 +101,7 @@ extern void fpsave(unsigned long *fpregs
  * SWITCH_ENTER and SWITH_DO_LAZY_FPU do not work yet (e.g. SMP does not work)
  * XXX WTF is the above comment? Found in late teen 2.4.x.
  */
-#define prepare_arch_switch(rq, next) do { \
+#define prepare_arch_switch(next) do { \
 	__asm__ __volatile__( \
 	".globl\tflush_patch_switch\nflush_patch_switch:\n\t" \
 	"save %sp, -0x40, %sp; save %sp, -0x40, %sp; save %sp, -0x40, %sp\n\t" \
@@ -109,8 +109,6 @@ extern void fpsave(unsigned long *fpregs
 	"save %sp, -0x40, %sp\n\t" \
 	"restore; restore; restore; restore; restore; restore; restore"); \
 } while(0)
-#define finish_arch_switch(rq, next)	spin_unlock_irq(&(rq)->lock)
-#define task_running(rq, p)		((rq)->curr == (p))
 
 	/* Much care has gone into this code, do not touch it.
 	 *
diff -puN include/asm-sparc64/system.h~task-running-flag include/asm-sparc64/system.h
--- linux-2.6/include/asm-sparc64/system.h~task-running-flag	2004-06-04 12:28:05.000000000 +1000
+++ linux-2.6-npiggin/include/asm-sparc64/system.h	2004-06-04 12:28:05.000000000 +1000
@@ -139,19 +139,13 @@ extern void __flushw_user(void);
 #define flush_user_windows flushw_user
 #define flush_register_windows flushw_all
 
-#define prepare_arch_switch(rq, next)		\
-do {	spin_lock(&(next)->switch_lock);	\
-	spin_unlock(&(rq)->lock);		\
+/* Don't hold the runqueue lock over context switch */
+#define __ARCH_WANT_UNLOCKED_CTXSW
+#define prepare_arch_switch(next)		\
+do {						\
 	flushw_all();				\
 } while (0)
 
-#define finish_arch_switch(rq, prev)		\
-do {	spin_unlock_irq(&(prev)->switch_lock);	\
-} while (0)
-
-#define task_running(rq, p) \
-	((rq)->curr == (p) || spin_is_locked(&(p)->switch_lock))
-
 	/* See what happens when you design the chip correctly?
 	 *
 	 * We tell gcc we clobber all non-fixed-usage registers except
diff -puN include/asm-arm/system.h~task-running-flag include/asm-arm/system.h
--- linux-2.6/include/asm-arm/system.h~task-running-flag	2004-06-04 12:28:05.000000000 +1000
+++ linux-2.6-npiggin/include/asm-arm/system.h	2004-06-04 12:28:05.000000000 +1000
@@ -137,34 +137,12 @@ extern unsigned int user_debug;
 #define set_wmb(var, value) do { var = value; wmb(); } while (0)
 #define nop() __asm__ __volatile__("mov\tr0,r0\t@ nop\n\t");
 
-#ifdef CONFIG_SMP
 /*
- * Define our own context switch locking.  This allows us to enable
- * interrupts over the context switch, otherwise we end up with high
- * interrupt latency.  The real problem area is switch_mm() which may
- * do a full cache flush.
+ * switch_mm() may do a full cache flush over the context switch,
+ * so enable interrupts over the context switch to avoid high
+ * latency.
  */
-#define prepare_arch_switch(rq,next)					\
-do {									\
-	spin_lock(&(next)->switch_lock);				\
-	spin_unlock_irq(&(rq)->lock);					\
-} while (0)
-
-#define finish_arch_switch(rq,prev)					\
-	spin_unlock(&(prev)->switch_lock)
-
-#define task_running(rq,p)						\
-	((rq)->curr == (p) || spin_is_locked(&(p)->switch_lock))
-#else
-/*
- * Our UP-case is more simple, but we assume knowledge of how
- * spin_unlock_irq() and friends are implemented.  This avoids
- * us needlessly decrementing and incrementing the preempt count.
- */
-#define prepare_arch_switch(rq,next)	local_irq_enable()
-#define finish_arch_switch(rq,prev)	spin_unlock(&(rq)->lock)
-#define task_running(rq,p)		((rq)->curr == (p))
-#endif
+#define __ARCH_WANT_INTERRUPTS_ON_CTXSW
 
 /*
  * switch_to(prev, next) should switch from task `prev' to `next'

_

--------------050802010209070903020804--
