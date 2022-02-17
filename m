From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Date: Thu, 17 Feb 2022 10:24:03 +0000
Subject: [PATCH v2 5/8] kernel/fork: Move memcg_charge_kernel_stack() into CONFIG_VMAP_STACK.
Message-Id: <20220217102406.3697941-6-bigeasy@linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220217102406.3697941-1-bigeasy@linutronix.de>
In-Reply-To: <20220217102406.3697941-1-bigeasy@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org
Cc: Andy Lutomirski <luto@kernel.org>, Ben Segall <bsegall@google.com>, Daniel Bristot de Oliveira <bristot@redhat.com>, Dietmar Eggemann <dietmar.eggemann@arm.com>, Ingo Molnar <mingo@redhat.com>, Juri Lelli <juri.lelli@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Thomas Gleixner <tglx@linutronix.de>, Vincent Guittot <vincent.guittot@linaro.org>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>

memcg_charge_kernel_stack() is only used in the CONFIG_VMAP_STACK case.

Move memcg_charge_kernel_stack() into the CONFIG_VMAP_STACK block and
invoke it from within alloc_thread_stack_node().

Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 kernel/fork.c | 69 +++++++++++++++++++++++++++------------------------
 1 file changed, 36 insertions(+), 33 deletions(-)

diff --git a/kernel/fork.c b/kernel/fork.c
index 546bea2e3b28a..919bdcf21b8e5 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -211,6 +211,32 @@ static int free_vm_stack_cache(unsigned int cpu)
 	return 0;
 }
 
+static int memcg_charge_kernel_stack(struct task_struct *tsk)
+{
+	struct vm_struct *vm = task_stack_vm_area(tsk);
+	int i;
+	int ret;
+
+	BUILD_BUG_ON(IS_ENABLED(CONFIG_VMAP_STACK) && PAGE_SIZE % 1024 != 0);
+	BUG_ON(vm->nr_pages != THREAD_SIZE / PAGE_SIZE);
+
+	for (i = 0; i < THREAD_SIZE / PAGE_SIZE; i++) {
+		ret = memcg_kmem_charge_page(vm->pages[i], GFP_KERNEL, 0);
+		if (ret)
+			goto err;
+	}
+	return 0;
+err:
+	/*
+	 * If memcg_kmem_charge_page() fails, page's memory cgroup pointer is
+	 * NULL, and memcg_kmem_uncharge_page() in free_thread_stack() will
+	 * ignore this page.
+	 */
+	for (i = 0; i < THREAD_SIZE / PAGE_SIZE; i++)
+		memcg_kmem_uncharge_page(vm->pages[i], 0);
+	return ret;
+}
+
 static int alloc_thread_stack_node(struct task_struct *tsk, int node)
 {
 	void *stack;
@@ -230,6 +256,11 @@ static int alloc_thread_stack_node(struct task_struct *tsk, int node)
 		/* Clear stale pointers from reused stack. */
 		memset(s->addr, 0, THREAD_SIZE);
 
+		if (memcg_charge_kernel_stack(tsk)) {
+			vfree(s->addr);
+			return -ENOMEM;
+		}
+
 		tsk->stack_vm_area = s;
 		tsk->stack = s->addr;
 		return 0;
@@ -247,6 +278,11 @@ static int alloc_thread_stack_node(struct task_struct *tsk, int node)
 				     0, node, __builtin_return_address(0));
 	if (!stack)
 		return -ENOMEM;
+
+	if (memcg_charge_kernel_stack(tsk)) {
+		vfree(stack);
+		return -ENOMEM;
+	}
 	/*
 	 * We can't call find_vm_area() in interrupt context, and
 	 * free_thread_stack() can be called in interrupt context,
@@ -418,36 +454,6 @@ static void account_kernel_stack(struct task_struct *tsk, int account)
 	}
 }
 
-static int memcg_charge_kernel_stack(struct task_struct *tsk)
-{
-#ifdef CONFIG_VMAP_STACK
-	struct vm_struct *vm = task_stack_vm_area(tsk);
-	int ret;
-
-	BUILD_BUG_ON(IS_ENABLED(CONFIG_VMAP_STACK) && PAGE_SIZE % 1024 != 0);
-
-	if (vm) {
-		int i;
-
-		BUG_ON(vm->nr_pages != THREAD_SIZE / PAGE_SIZE);
-
-		for (i = 0; i < THREAD_SIZE / PAGE_SIZE; i++) {
-			/*
-			 * If memcg_kmem_charge_page() fails, page's
-			 * memory cgroup pointer is NULL, and
-			 * memcg_kmem_uncharge_page() in free_thread_stack()
-			 * will ignore this page.
-			 */
-			ret = memcg_kmem_charge_page(vm->pages[i], GFP_KERNEL,
-						     0);
-			if (ret)
-				return ret;
-		}
-	}
-#endif
-	return 0;
-}
-
 static void release_task_stack(struct task_struct *tsk)
 {
 	if (WARN_ON(READ_ONCE(tsk->__state) != TASK_DEAD))
@@ -909,9 +915,6 @@ static struct task_struct *dup_task_struct(struct task_struct *orig, int node)
 	if (err)
 		goto free_tsk;
 
-	if (memcg_charge_kernel_stack(tsk))
-		goto free_stack;
-
 #ifdef CONFIG_THREAD_INFO_IN_TASK
 	refcount_set(&tsk->stack_refcount, 1);
 #endif
-- 
2.34.1
