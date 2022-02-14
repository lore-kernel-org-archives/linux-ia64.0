From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Date: Mon, 14 Feb 2022 16:54:47 +0000
Subject: Re: [PATCH 7/8] kernel/fork: Only cache the VMAP stack in finish_task_switch().
Message-Id: <YgqJV0LREU9IDJxl@linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220125152652.1963111-1-bigeasy@linutronix.de>
 <20220125152652.1963111-8-bigeasy@linutronix.de>
 <00f9c7a6-2d1d-f871-e9bc-00e2217f40f9@kernel.org>
 <YgpGnFlTS+2Ugfw4@linutronix.de>
 <YgpJ41q35k+KCsk4@linutronix.de>
In-Reply-To: <YgpJ41q35k+KCsk4@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andy Lutomirski <luto@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Ben Segall <bsegall@google.com>, Daniel Bristot de Oliveira <bristot@redhat.com>, Dietmar Eggemann <dietmar.eggemann@arm.com>, Ingo Molnar <mingo@redhat.com>, Juri Lelli <juri.lelli@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Thomas Gleixner <tglx@linutronix.de>, Vincent Guittot <vincent.guittot@linaro.org>

On 2022-02-14 13:24:05 [+0100], To Andy Lutomirski wrote:
> task::stack_vm_area and ::stack. Now I remember why I went for that bit.
> But I do have (hopefully) a better idea now.

Need to update the patch description but that should work then:

diff --git a/include/linux/sched/task_stack.h b/include/linux/sched/task_stack.h
index 892562ebbd3aa..12b3f472b1358 100644
--- a/include/linux/sched/task_stack.h
+++ b/include/linux/sched/task_stack.h
@@ -70,6 +70,7 @@ static inline void *try_get_task_stack(struct task_struct *tsk)
 }
 
 extern void put_task_stack(struct task_struct *tsk);
+extern void put_task_stack_sched(struct task_struct *tsk);
 #else
 static inline void *try_get_task_stack(struct task_struct *tsk)
 {
@@ -77,6 +78,7 @@ static inline void *try_get_task_stack(struct task_struct *tsk)
 }
 
 static inline void put_task_stack(struct task_struct *tsk) {}
+static inline void put_task_stack_sched(struct task_struct *tsk) {}
 #endif
 
 void exit_task_stack_account(struct task_struct *tsk);
diff --git a/kernel/fork.c b/kernel/fork.c
index 5f4e659a922e1..d7e118c86f9e6 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -193,6 +193,44 @@ static inline void free_task_struct(struct task_struct *tsk)
 #define NR_CACHED_STACKS 2
 static DEFINE_PER_CPU(struct vm_struct *, cached_stacks[NR_CACHED_STACKS]);
 
+struct vm_stack {
+	struct rcu_head rcu;
+	struct vm_struct *stack_vm_area;
+};
+
+static bool try_release_thread_stack_to_cache(struct vm_struct *vm)
+{
+	unsigned int i;
+
+	for (i = 0; i < NR_CACHED_STACKS; i++) {
+		if (this_cpu_cmpxchg(cached_stacks[i], NULL, vm) != NULL)
+			continue;
+		return true;
+	}
+	return false;
+}
+
+static void thread_stack_free_rcu(struct rcu_head *rh)
+{
+	struct vm_stack *vm_stack = container_of(rh, struct vm_stack, rcu);
+
+	if (try_release_thread_stack_to_cache(vm_stack->stack_vm_area))
+		return;
+
+	vfree(vm_stack);
+}
+
+static void thread_stack_delayed_free(struct task_struct *tsk)
+{
+	struct vm_stack *vm_stack = tsk->stack;
+
+	vm_stack->stack_vm_area = tsk->stack_vm_area;
+	call_rcu(&vm_stack->rcu, thread_stack_free_rcu);
+
+	tsk->stack = NULL;
+	tsk->stack_vm_area = NULL;
+}
+
 static int free_vm_stack_cache(unsigned int cpu)
 {
 	struct vm_struct **cached_vm_stacks = per_cpu_ptr(cached_stacks, cpu);
@@ -294,26 +332,39 @@ static int alloc_thread_stack_node(struct task_struct *tsk, int node)
 	return 0;
 }
 
-static void free_thread_stack(struct task_struct *tsk)
+static void free_thread_stack(struct task_struct *tsk, bool delayed_free)
 {
-	int i;
-
-	for (i = 0; i < NR_CACHED_STACKS; i++) {
-		if (this_cpu_cmpxchg(cached_stacks[i], NULL,
-				     tsk->stack_vm_area) != NULL)
-			continue;
-
+	if (try_release_thread_stack_to_cache(tsk->stack_vm_area)) {
 		tsk->stack = NULL;
 		tsk->stack_vm_area = NULL;
 		return;
 	}
-	vfree_atomic(tsk->stack);
+
+	if (delayed_free) {
+		thread_stack_delayed_free(tsk);
+		return;
+	}
+
+	vfree(tsk->stack);
 	tsk->stack = NULL;
 	tsk->stack_vm_area = NULL;
 }
 
 #  else /* !CONFIG_VMAP_STACK */
 
+static void thread_stack_free_rcu(struct rcu_head *rh)
+{
+	__free_pages(virt_to_page(rh), THREAD_SIZE_ORDER);
+}
+
+static void thread_stack_delayed_free(struct task_struct *tsk)
+{
+	struct rcu_head *rh = tsk->stack;
+
+	call_rcu(rh, thread_stack_free_rcu);
+	tsk->stack = NULL;
+}
+
 static int alloc_thread_stack_node(struct task_struct *tsk, int node)
 {
 	struct page *page = alloc_pages_node(node, THREADINFO_GFP,
@@ -326,8 +377,12 @@ static int alloc_thread_stack_node(struct task_struct *tsk, int node)
 	return -ENOMEM;
 }
 
-static void free_thread_stack(struct task_struct *tsk)
+static void free_thread_stack(struct task_struct *tsk, bool delayed_free)
 {
+	if (delayed_free) {
+		thread_stack_delayed_free(tsk);
+		return;
+	}
 	__free_pages(virt_to_page(tsk->stack), THREAD_SIZE_ORDER);
 	tsk->stack = NULL;
 }
@@ -337,6 +392,19 @@ static void free_thread_stack(struct task_struct *tsk)
 
 static struct kmem_cache *thread_stack_cache;
 
+static void thread_stack_free_rcu(struct rcu_head *rh)
+{
+	kmem_cache_free(thread_stack_cache, rh);
+}
+
+static void thread_stack_delayed_free(struct task_struct *tsk)
+{
+	struct rcu_head *rh = tsk->stack;
+
+	call_rcu(rh, thread_stack_free_rcu);
+	tsk->stack = NULL;
+}
+
 static int alloc_thread_stack_node(struct task_struct *tsk, int node)
 {
 	unsigned long *stack;
@@ -346,8 +414,12 @@ static int alloc_thread_stack_node(struct task_struct *tsk, int node)
 	return stack ? 0 : -ENOMEM;
 }
 
-static void free_thread_stack(struct task_struct *tsk)
+static void free_thread_stack(struct task_struct *tsk, bool delayed_free)
 {
+	if (delayed_free) {
+		thread_stack_delayed_free(tsk);
+		return;
+	}
 	kmem_cache_free(thread_stack_cache, tsk->stack);
 	tsk->stack = NULL;
 }
@@ -372,7 +444,7 @@ static int alloc_thread_stack_node(struct task_struct *tsk, int node)
 	return stack ? 0 : -ENOMEM;
 }
 
-static void free_thread_stack(struct task_struct *tsk, bool cache_only)
+static void free_thread_stack(struct task_struct *tsk, bool delayed_free)
 {
 	arch_free_thread_stack(tsk);
 }
@@ -464,19 +536,25 @@ void exit_task_stack_account(struct task_struct *tsk)
 	}
 }
 
-static void release_task_stack(struct task_struct *tsk)
+static void release_task_stack(struct task_struct *tsk, bool delayed_free)
 {
 	if (WARN_ON(READ_ONCE(tsk->__state) != TASK_DEAD))
 		return;  /* Better to leak the stack than to free prematurely */
 
-	free_thread_stack(tsk);
+	free_thread_stack(tsk, delayed_free);
 }
 
 #ifdef CONFIG_THREAD_INFO_IN_TASK
 void put_task_stack(struct task_struct *tsk)
 {
 	if (refcount_dec_and_test(&tsk->stack_refcount))
-		release_task_stack(tsk);
+		release_task_stack(tsk, false);
+}
+
+void put_task_stack_sched(struct task_struct *tsk)
+{
+	if (refcount_dec_and_test(&tsk->stack_refcount))
+		release_task_stack(tsk, true);
 }
 #endif
 
@@ -490,7 +568,7 @@ void free_task(struct task_struct *tsk)
 	 * The task is finally done with both the stack and thread_info,
 	 * so free both.
 	 */
-	release_task_stack(tsk);
+	release_task_stack(tsk, false);
 #else
 	/*
 	 * If the task had a separate stack allocation, it should be gone
@@ -990,7 +1068,7 @@ static struct task_struct *dup_task_struct(struct task_struct *orig, int node)
 
 free_stack:
 	exit_task_stack_account(tsk);
-	free_thread_stack(tsk);
+	free_thread_stack(tsk, false);
 free_tsk:
 	free_task_struct(tsk);
 	return NULL;
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index fcf0c180617c2..defe31036930a 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -4895,8 +4895,11 @@ static struct rq *finish_task_switch(struct task_struct *prev)
 		if (prev->sched_class->task_dead)
 			prev->sched_class->task_dead(prev);
 
-		/* Task is done with its stack. */
-		put_task_stack(prev);
+		/*
+		 * Task is done with its stack. Try to cache VMAP stack and
+		 * delay free it otherwise.
+		 */
+		put_task_stack_sched(prev);
 
 		put_task_struct_rcu_user(prev);
 	}
-- 
2.34.1


> > > --Andy
> 
Sebastian
