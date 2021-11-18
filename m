From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Date: Thu, 18 Nov 2021 14:34:45 +0000
Subject: [PATCH 1/8] kernel/fork: Redo ifdefs around task's handling.
Message-Id: <20211118143452.136421-2-bigeasy@linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20211118143452.136421-1-bigeasy@linutronix.de>
In-Reply-To: <20211118143452.136421-1-bigeasy@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org
Cc: Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andy Lutomirski <luto@kernel.org>, Juri Lelli <juri.lelli@redhat.com>, Vincent Guittot <vincent.guittot@linaro.org>, Dietmar Eggemann <dietmar.eggemann@arm.com>, Steven Rostedt <rostedt@goodmis.org>, Ben Segall <bsegall@google.com>, Daniel Bristot de Oliveira <bristot@redhat.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>

The use of ifdef CONFIG_VMAP_STACK is confusing in terms what is
actually happenning and what can happen.
For instance from reading free_thread_stack() it appears that in the
CONFIG_VMAP_STACK case we may receive a non-NULL vm pointer but it may
also be NULL in which case __free_pages() is used to free the stack.
This is however not the case because in the VMAP case a non-NULL pointer
is always returned here.
Since it looks like this might happen, the compiler creates the correct
dead code with the invocation to __free_pages() and everything around
it. Twice.

Add spaces between the ifdef and the identifer to recognize the ifdef
level that we are currently in.
Add the current identifer as a comment behind #else and #endif.
Move the code within free_thread_stack() and alloc_thread_stack_node()
into the relavant ifdef block.

Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 kernel/fork.c | 74 +++++++++++++++++++++++++++------------------------
 1 file changed, 39 insertions(+), 35 deletions(-)

diff --git a/kernel/fork.c b/kernel/fork.c
index 3244cc56b697d..bb3f2980f94fb 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -184,7 +184,7 @@ static inline void free_task_struct(struct task_struct *tsk)
  */
 # if THREAD_SIZE >= PAGE_SIZE || defined(CONFIG_VMAP_STACK)
 
-#ifdef CONFIG_VMAP_STACK
+#  ifdef CONFIG_VMAP_STACK
 /*
  * vmalloc() is a bit slow, and calling vfree() enough times will force a TLB
  * flush.  Try to minimize the number of calls by caching stacks.
@@ -209,11 +209,9 @@ static int free_vm_stack_cache(unsigned int cpu)
 
 	return 0;
 }
-#endif
 
 static unsigned long *alloc_thread_stack_node(struct task_struct *tsk, int node)
 {
-#ifdef CONFIG_VMAP_STACK
 	void *stack;
 	int i;
 
@@ -257,7 +255,34 @@ static unsigned long *alloc_thread_stack_node(struct task_struct *tsk, int node)
 		tsk->stack = stack;
 	}
 	return stack;
-#else
+}
+
+static void free_thread_stack(struct task_struct *tsk)
+{
+	struct vm_struct *vm = task_stack_vm_area(tsk);
+	int i;
+
+	for (i = 0; i < THREAD_SIZE / PAGE_SIZE; i++)
+		memcg_kmem_uncharge_page(vm->pages[i], 0);
+
+	for (i = 0; i < NR_CACHED_STACKS; i++) {
+		if (this_cpu_cmpxchg(cached_stacks[i], NULL,
+				     tsk->stack_vm_area) != NULL)
+			continue;
+
+		tsk->stack = NULL;
+		tsk->stack_vm_area = NULL;
+		return;
+	}
+	vfree_atomic(tsk->stack);
+	tsk->stack = NULL;
+	tsk->stack_vm_area = NULL;
+}
+
+#  else /* !CONFIG_VMAP_STACK */
+
+static unsigned long *alloc_thread_stack_node(struct task_struct *tsk, int node)
+{
 	struct page *page = alloc_pages_node(node, THREADINFO_GFP,
 					     THREAD_SIZE_ORDER);
 
@@ -266,36 +291,17 @@ static unsigned long *alloc_thread_stack_node(struct task_struct *tsk, int node)
 		return tsk->stack;
 	}
 	return NULL;
-#endif
 }
 
-static inline void free_thread_stack(struct task_struct *tsk)
+static void free_thread_stack(struct task_struct *tsk)
 {
-#ifdef CONFIG_VMAP_STACK
-	struct vm_struct *vm = task_stack_vm_area(tsk);
-
-	if (vm) {
-		int i;
-
-		for (i = 0; i < THREAD_SIZE / PAGE_SIZE; i++)
-			memcg_kmem_uncharge_page(vm->pages[i], 0);
-
-		for (i = 0; i < NR_CACHED_STACKS; i++) {
-			if (this_cpu_cmpxchg(cached_stacks[i],
-					NULL, tsk->stack_vm_area) != NULL)
-				continue;
-
-			return;
-		}
-
-		vfree_atomic(tsk->stack);
-		return;
-	}
-#endif
-
 	__free_pages(virt_to_page(tsk->stack), THREAD_SIZE_ORDER);
+	tsk->stack = NULL;
 }
-# else
+
+#  endif /* CONFIG_VMAP_STACK */
+# else /* !(THREAD_SIZE >= PAGE_SIZE || defined(CONFIG_VMAP_STACK)) */
+
 static struct kmem_cache *thread_stack_cache;
 
 static unsigned long *alloc_thread_stack_node(struct task_struct *tsk,
@@ -311,6 +317,7 @@ static unsigned long *alloc_thread_stack_node(struct task_struct *tsk,
 static void free_thread_stack(struct task_struct *tsk)
 {
 	kmem_cache_free(thread_stack_cache, tsk->stack);
+	tsk->stack = NULL;
 }
 
 void thread_stack_cache_init(void)
@@ -320,8 +327,9 @@ void thread_stack_cache_init(void)
 					THREAD_SIZE, NULL);
 	BUG_ON(thread_stack_cache == NULL);
 }
-# endif
-#endif
+
+# endif /* THREAD_SIZE >= PAGE_SIZE || defined(CONFIG_VMAP_STACK) */
+#endif /* !CONFIG_ARCH_THREAD_STACK_ALLOCATOR */
 
 /* SLAB cache for signal_struct structures (tsk->signal) */
 static struct kmem_cache *signal_cachep;
@@ -429,10 +437,6 @@ static void release_task_stack(struct task_struct *tsk)
 
 	account_kernel_stack(tsk, -1);
 	free_thread_stack(tsk);
-	tsk->stack = NULL;
-#ifdef CONFIG_VMAP_STACK
-	tsk->stack_vm_area = NULL;
-#endif
 }
 
 #ifdef CONFIG_THREAD_INFO_IN_TASK
-- 
2.33.1
