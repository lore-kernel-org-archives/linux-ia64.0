From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Date: Thu, 18 Nov 2021 14:34:47 +0000
Subject: [PATCH 3/8] kernel/fork, IA64: Provide a alloc_thread_stack_node() for IA64.
Message-Id: <20211118143452.136421-4-bigeasy@linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20211118143452.136421-1-bigeasy@linutronix.de>
In-Reply-To: <20211118143452.136421-1-bigeasy@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org
Cc: Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andy Lutomirski <luto@kernel.org>, Juri Lelli <juri.lelli@redhat.com>, Vincent Guittot <vincent.guittot@linaro.org>, Dietmar Eggemann <dietmar.eggemann@arm.com>, Steven Rostedt <rostedt@goodmis.org>, Ben Segall <bsegall@google.com>, Daniel Bristot de Oliveira <bristot@redhat.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>

Provide a generic alloc_thread_stack_node() for IA64/
CONFIG_ARCH_THREAD_STACK_ALLOCATOR which returns stack pointer and sets
task_struct::stack so it behaves exactly like the other implementations.

Rename IA64's alloc_thread_stack_node() and add the generic version to
the fork code so it is in one place _and_ to drastically lower chances
of fat fingering the IA64 code.
Do the same for free_thread_stack().

Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 arch/ia64/include/asm/thread_info.h |  6 +++---
 kernel/fork.c                       | 16 ++++++++++++++++
 2 files changed, 19 insertions(+), 3 deletions(-)

diff --git a/arch/ia64/include/asm/thread_info.h b/arch/ia64/include/asm/thread_info.h
index 51d20cb377062..1684716f08201 100644
--- a/arch/ia64/include/asm/thread_info.h
+++ b/arch/ia64/include/asm/thread_info.h
@@ -55,15 +55,15 @@ struct thread_info {
 #ifndef ASM_OFFSETS_C
 /* how to get the thread information struct from C */
 #define current_thread_info()	((struct thread_info *) ((char *) current + IA64_TASK_SIZE))
-#define alloc_thread_stack_node(tsk, node)	\
+#define arch_alloc_thread_stack_node(tsk, node)	\
 		((unsigned long *) ((char *) (tsk) + IA64_TASK_SIZE))
 #define task_thread_info(tsk)	((struct thread_info *) ((char *) (tsk) + IA64_TASK_SIZE))
 #else
 #define current_thread_info()	((struct thread_info *) 0)
-#define alloc_thread_stack_node(tsk, node)	((unsigned long *) 0)
+#define arch_alloc_thread_stack_node(tsk, node)	((unsigned long *) 0)
 #define task_thread_info(tsk)	((struct thread_info *) 0)
 #endif
-#define free_thread_stack(tsk)	/* nothing */
+#define arch_free_thread_stack(tsk)	/* nothing */
 #define task_stack_page(tsk)	((void *)(tsk))
 
 #define __HAVE_THREAD_FUNCTIONS
diff --git a/kernel/fork.c b/kernel/fork.c
index ce320d4b8e1f4..d1681a415cdf1 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -329,6 +329,22 @@ void thread_stack_cache_init(void)
 }
 
 # endif /* THREAD_SIZE >= PAGE_SIZE || defined(CONFIG_VMAP_STACK) */
+#else /* CONFIG_ARCH_THREAD_STACK_ALLOCATOR */
+
+static unsigned long *alloc_thread_stack_node(struct task_struct *tsk, int node)
+{
+	unsigned long *stack;
+
+	stack = arch_alloc_thread_stack_node(tsk, node);
+	tsk->stack = stack;
+	return stack;
+}
+
+static void free_thread_stack(struct task_struct *tsk, bool cache_only)
+{
+	arch_free_thread_stack(tsk);
+}
+
 #endif /* !CONFIG_ARCH_THREAD_STACK_ALLOCATOR */
 
 /* SLAB cache for signal_struct structures (tsk->signal) */
-- 
2.33.1
