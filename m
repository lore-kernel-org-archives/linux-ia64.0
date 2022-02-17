From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Date: Thu, 17 Feb 2022 10:24:06 +0000
Subject: [PATCH v2 8/8] kernel/fork: Use IS_ENABLED() in account_kernel_stack().
Message-Id: <20220217102406.3697941-9-bigeasy@linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220217102406.3697941-1-bigeasy@linutronix.de>
In-Reply-To: <20220217102406.3697941-1-bigeasy@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org
Cc: Andy Lutomirski <luto@kernel.org>, Ben Segall <bsegall@google.com>, Daniel Bristot de Oliveira <bristot@redhat.com>, Dietmar Eggemann <dietmar.eggemann@arm.com>, Ingo Molnar <mingo@redhat.com>, Juri Lelli <juri.lelli@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Thomas Gleixner <tglx@linutronix.de>, Vincent Guittot <vincent.guittot@linaro.org>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>

Not strickly needed but checking CONFIG_VMAP_STACK instead of
task_stack_vm_area()' result allows the compiler the remove the else
path in the CONFIG_VMAP_STACK case where the pointer can't be NULL.

Check for CONFIG_VMAP_STACK in order to use the proper path.

Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 kernel/fork.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/kernel/fork.c b/kernel/fork.c
index aa17ed2a2afc7..4c97e0b5fb62a 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -485,16 +485,16 @@ void vm_area_free(struct vm_area_struct *vma)
 
 static void account_kernel_stack(struct task_struct *tsk, int account)
 {
-	void *stack = task_stack_page(tsk);
-	struct vm_struct *vm = task_stack_vm_area(tsk);
-
-	if (vm) {
+	if (IS_ENABLED(CONFIG_VMAP_STACK)) {
+		struct vm_struct *vm = task_stack_vm_area(tsk);
 		int i;
 
 		for (i = 0; i < THREAD_SIZE / PAGE_SIZE; i++)
 			mod_lruvec_page_state(vm->pages[i], NR_KERNEL_STACK_KB,
 					      account * (PAGE_SIZE / 1024));
 	} else {
+		void *stack = task_stack_page(tsk);
+
 		/* All stack pages are in the same node. */
 		mod_lruvec_kmem_state(stack, NR_KERNEL_STACK_KB,
 				      account * (THREAD_SIZE / 1024));
-- 
2.34.1
