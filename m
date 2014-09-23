From: Peter Zijlstra <peterz@infradead.org>
Date: Tue, 23 Sep 2014 15:06:41 +0000
Subject: [RFC][PATCH] sched,mips,ia64: Remove __ARCH_WANT_UNLOCKED_CTXSW
Message-Id: <20140923150641.GH3312@worktop.programming.kicks-ass.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20140922183612.11015.64200.stgit@localhost>
 <20140922183618.11015.95007.stgit@localhost>
In-Reply-To: <20140922183618.11015.95007.stgit@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kirill Tkhai <tkhai@yandex.ru>
Cc: linux-kernel@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, Kirill Tkhai <ktkhai@parallels.com>, oleg@redhat.com, linux@roeck-us.net, ralf@linux-mips.org, tony.luck@intel.com, linux-mips@linux-mips.org, linux-ia64@vger.kernel.org

On Mon, Sep 22, 2014 at 10:36:18PM +0400, Kirill Tkhai wrote:
> From: Kirill Tkhai <ktkhai@parallels.com>
> 
> Architectures, which define __ARCH_WANT_UNLOCKED_CTXSW,
> may pull a task when it's in the middle of schedule().
> 
> CPU1(task1 calls schedule)            CPU2
> ...                                   schedule()
> ...                                      idle_balance()
> ...                                         load_balance()
> ...                                            ...
> schedule()                                     ...
>    prepare_lock_switch()                       ...
>       raw_spin_unlock(&rq1->lock)              ...
>       ...                                      raw_spin_lock(&rq1->lock)
>       ...                                         detach_tasks();
>       ...                                            can_migrate_task(task1)
>       ...                                         attach_tasks(); <--- move task1 to rq2
>       ...                                      raw_spin_unlock(&rq1->lock)
>       ...                                context_switch() <--- switch to task1's stack
>       ...                                ...
>    (using task1's stack)                 (using task1's stack)
>    ...                                   ...
>    context_switch()                      ...
> 
> 
> Parallel use of a single stack is not a good idea.

Indeed it is, but how about we do this instead?

---
Subject: sched,mips,ia64: Remove __ARCH_WANT_UNLOCKED_CTXSW

Kirill found that there's a subtle race in the
__ARCH_WANT_UNLOCKED_CTXSW code, and instead of fixing it, remove the
entire exception because neither arch that uses it seems to actually
still require it.

Boot tested on mips64el (qemu) only.

Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Guenter Roeck <linux@roeck-us.net>
Cc: Ralf Baechle <ralf@linux-mips.org>
Cc: Tony Luck <tony.luck@intel.com>
Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 arch/ia64/include/asm/processor.h |  1 -
 arch/mips/include/asm/processor.h |  6 ------
 kernel/sched/core.c               |  6 ------
 kernel/sched/sched.h              | 30 ------------------------------
 4 files changed, 43 deletions(-)

diff --git a/arch/ia64/include/asm/processor.h b/arch/ia64/include/asm/processor.h
index c736713..ce53c50 100644
--- a/arch/ia64/include/asm/processor.h
+++ b/arch/ia64/include/asm/processor.h
@@ -19,7 +19,6 @@
 #include <asm/ptrace.h>
 #include <asm/ustack.h>
 
-#define __ARCH_WANT_UNLOCKED_CTXSW
 #define ARCH_HAS_PREFETCH_SWITCH_STACK
 
 #define IA64_NUM_PHYS_STACK_REG	96
diff --git a/arch/mips/include/asm/processor.h b/arch/mips/include/asm/processor.h
index 05f0843..f1df4cb 100644
--- a/arch/mips/include/asm/processor.h
+++ b/arch/mips/include/asm/processor.h
@@ -397,12 +397,6 @@ unsigned long get_wchan(struct task_struct *p);
 #define ARCH_HAS_PREFETCHW
 #define prefetchw(x) __builtin_prefetch((x), 1, 1)
 
-/*
- * See Documentation/scheduler/sched-arch.txt; prevents deadlock on SMP
- * systems.
- */
-#define __ARCH_WANT_UNLOCKED_CTXSW
-
 #endif
 
 #endif /* _ASM_PROCESSOR_H */
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 2a93b87..ccbafb0 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -2304,10 +2304,6 @@ asmlinkage __visible void schedule_tail(struct task_struct *prev)
 	 */
 	post_schedule(rq);
 
-#ifdef __ARCH_WANT_UNLOCKED_CTXSW
-	/* In this case, finish_task_switch does not reenable preemption */
-	preempt_enable();
-#endif
 	if (current->set_child_tid)
 		put_user(task_pid_vnr(current), current->set_child_tid);
 }
@@ -2350,9 +2346,7 @@ context_switch(struct rq *rq, struct task_struct *prev,
 	 * of the scheduler it's an obvious special-case), so we
 	 * do an early lockdep release here:
 	 */
-#ifndef __ARCH_WANT_UNLOCKED_CTXSW
 	spin_release(&rq->lock.dep_map, 1, _THIS_IP_);
-#endif
 
 	context_tracking_task_switch(prev, next);
 	/* Here we just switch the register state and the stack. */
diff --git a/kernel/sched/sched.h b/kernel/sched/sched.h
index 1bc6aad..d87f122 100644
--- a/kernel/sched/sched.h
+++ b/kernel/sched/sched.h
@@ -966,7 +966,6 @@ static inline int task_on_rq_migrating(struct task_struct *p)
 # define finish_arch_post_lock_switch()	do { } while (0)
 #endif
 
-#ifndef __ARCH_WANT_UNLOCKED_CTXSW
 static inline void prepare_lock_switch(struct rq *rq, struct task_struct *next)
 {
 #ifdef CONFIG_SMP
@@ -1004,35 +1003,6 @@ static inline void finish_lock_switch(struct rq *rq, struct task_struct *prev)
 	raw_spin_unlock_irq(&rq->lock);
 }
 
-#else /* __ARCH_WANT_UNLOCKED_CTXSW */
-static inline void prepare_lock_switch(struct rq *rq, struct task_struct *next)
-{
-#ifdef CONFIG_SMP
-	/*
-	 * We can optimise this out completely for !SMP, because the
-	 * SMP rebalancing from interrupt is the only thing that cares
-	 * here.
-	 */
-	next->on_cpu = 1;
-#endif
-	raw_spin_unlock(&rq->lock);
-}
-
-static inline void finish_lock_switch(struct rq *rq, struct task_struct *prev)
-{
-#ifdef CONFIG_SMP
-	/*
-	 * After ->on_cpu is cleared, the task can be moved to a different CPU.
-	 * We must ensure this doesn't happen until the switch is completely
-	 * finished.
-	 */
-	smp_wmb();
-	prev->on_cpu = 0;
-#endif
-	local_irq_enable();
-}
-#endif /* __ARCH_WANT_UNLOCKED_CTXSW */
-
 /*
  * wake flags
  */
