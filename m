From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Date: Tue, 25 Jan 2022 15:26:48 +0000
Subject: [PATCH 4/8] kernel/fork: Don't assign the stack pointer in dup_task_struct().
Message-Id: <20220125152652.1963111-5-bigeasy@linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220125152652.1963111-1-bigeasy@linutronix.de>
In-Reply-To: <20220125152652.1963111-1-bigeasy@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org
Cc: Andy Lutomirski <luto@kernel.org>, Ben Segall <bsegall@google.com>, Daniel Bristot de Oliveira <bristot@redhat.com>, Dietmar Eggemann <dietmar.eggemann@arm.com>, Ingo Molnar <mingo@redhat.com>, Juri Lelli <juri.lelli@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Thomas Gleixner <tglx@linutronix.de>, Vincent Guittot <vincent.guittot@linaro.org>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>

All four versions of alloc_thread_stack_node() assign now
task_struct::stack in case the allocation was successful.

Let alloc_thread_stack_node() return an error code instead of the stack
pointer and remove the stack assignment in dup_task_struct().

Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 kernel/fork.c | 47 ++++++++++++++++-------------------------------
 1 file changed, 16 insertions(+), 31 deletions(-)

diff --git a/kernel/fork.c b/kernel/fork.c
index a0d58ae6fac76..e6337b3c34ff7 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -211,7 +211,7 @@ static int free_vm_stack_cache(unsigned int cpu)
 	return 0;
 }
 
-static unsigned long *alloc_thread_stack_node(struct task_struct *tsk, int node)
+static int alloc_thread_stack_node(struct task_struct *tsk, int node)
 {
 	void *stack;
 	int i;
@@ -232,7 +232,7 @@ static unsigned long *alloc_thread_stack_node(struct task_struct *tsk, int node)
 
 		tsk->stack_vm_area = s;
 		tsk->stack = s->addr;
-		return s->addr;
+		return 0;
 	}
 
 	/*
@@ -245,17 +245,16 @@ static unsigned long *alloc_thread_stack_node(struct task_struct *tsk, int node)
 				     THREADINFO_GFP & ~__GFP_ACCOUNT,
 				     PAGE_KERNEL,
 				     0, node, __builtin_return_address(0));
-
+	if (!stack)
+		return -ENOMEM;
 	/*
 	 * We can't call find_vm_area() in interrupt context, and
 	 * free_thread_stack() can be called in interrupt context,
 	 * so cache the vm_struct.
 	 */
-	if (stack) {
-		tsk->stack_vm_area = find_vm_area(stack);
-		tsk->stack = stack;
-	}
-	return stack;
+	tsk->stack_vm_area = find_vm_area(stack);
+	tsk->stack = stack;
+	return 0;
 }
 
 static void free_thread_stack(struct task_struct *tsk)
@@ -282,16 +281,16 @@ static void free_thread_stack(struct task_struct *tsk)
 
 #  else /* !CONFIG_VMAP_STACK */
 
-static unsigned long *alloc_thread_stack_node(struct task_struct *tsk, int node)
+static int alloc_thread_stack_node(struct task_struct *tsk, int node)
 {
 	struct page *page = alloc_pages_node(node, THREADINFO_GFP,
 					     THREAD_SIZE_ORDER);
 
 	if (likely(page)) {
 		tsk->stack = kasan_reset_tag(page_address(page));
-		return tsk->stack;
+		return 0;
 	}
-	return NULL;
+	return -ENOMEM;
 }
 
 static void free_thread_stack(struct task_struct *tsk)
@@ -305,14 +304,13 @@ static void free_thread_stack(struct task_struct *tsk)
 
 static struct kmem_cache *thread_stack_cache;
 
-static unsigned long *alloc_thread_stack_node(struct task_struct *tsk,
-						  int node)
+static int alloc_thread_stack_node(struct task_struct *tsk, int node)
 {
 	unsigned long *stack;
 	stack = kmem_cache_alloc_node(thread_stack_cache, THREADINFO_GFP, node);
 	stack = kasan_reset_tag(stack);
 	tsk->stack = stack;
-	return stack;
+	return stack ? 0 : -ENOMEM;
 }
 
 static void free_thread_stack(struct task_struct *tsk)
@@ -332,13 +330,13 @@ void thread_stack_cache_init(void)
 # endif /* THREAD_SIZE >= PAGE_SIZE || defined(CONFIG_VMAP_STACK) */
 #else /* CONFIG_ARCH_THREAD_STACK_ALLOCATOR */
 
-static unsigned long *alloc_thread_stack_node(struct task_struct *tsk, int node)
+static int alloc_thread_stack_node(struct task_struct *tsk, int node)
 {
 	unsigned long *stack;
 
 	stack = arch_alloc_thread_stack_node(tsk, node);
 	tsk->stack = stack;
-	return stack;
+	return stack ? 0 : -ENOMEM;
 }
 
 static void free_thread_stack(struct task_struct *tsk, bool cache_only)
@@ -894,8 +892,6 @@ void set_task_stack_end_magic(struct task_struct *tsk)
 static struct task_struct *dup_task_struct(struct task_struct *orig, int node)
 {
 	struct task_struct *tsk;
-	unsigned long *stack;
-	struct vm_struct *stack_vm_area __maybe_unused;
 	int err;
 
 	if (node == NUMA_NO_NODE)
@@ -908,24 +904,13 @@ static struct task_struct *dup_task_struct(struct task_struct *orig, int node)
 	if (err)
 		goto free_tsk;
 
-	stack = alloc_thread_stack_node(tsk, node);
-	if (!stack)
+	err = alloc_thread_stack_node(tsk, node);
+	if (err)
 		goto free_tsk;
 
 	if (memcg_charge_kernel_stack(tsk))
 		goto free_stack;
 
-	stack_vm_area = task_stack_vm_area(tsk);
-
-	/*
-	 * arch_dup_task_struct() clobbers the stack-related fields.  Make
-	 * sure they're properly initialized before using any stack-related
-	 * functions again.
-	 */
-	tsk->stack = stack;
-#ifdef CONFIG_VMAP_STACK
-	tsk->stack_vm_area = stack_vm_area;
-#endif
 #ifdef CONFIG_THREAD_INFO_IN_TASK
 	refcount_set(&tsk->stack_refcount, 1);
 #endif
-- 
2.34.1
