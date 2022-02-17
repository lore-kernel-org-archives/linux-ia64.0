From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Date: Thu, 17 Feb 2022 10:24:00 +0000
Subject: [PATCH v2 2/8] kernel/fork: Duplicate task_struct before stack allocation.
Message-Id: <20220217102406.3697941-3-bigeasy@linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220217102406.3697941-1-bigeasy@linutronix.de>
In-Reply-To: <20220217102406.3697941-1-bigeasy@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org
Cc: Andy Lutomirski <luto@kernel.org>, Ben Segall <bsegall@google.com>, Daniel Bristot de Oliveira <bristot@redhat.com>, Dietmar Eggemann <dietmar.eggemann@arm.com>, Ingo Molnar <mingo@redhat.com>, Juri Lelli <juri.lelli@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Thomas Gleixner <tglx@linutronix.de>, Vincent Guittot <vincent.guittot@linaro.org>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>

alloc_thread_stack_node() already populates the task_struct::stack
member except on IA64. The stack pointer is saved and populated again
because IA64 needs it and arch_dup_task_struct() overwrites it.

Allocate thread's stack after task_struct has been duplicated as a
preparation.

Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 kernel/fork.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/kernel/fork.c b/kernel/fork.c
index f63c0af6002da..c47dcba5d66d2 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -888,6 +888,10 @@ static struct task_struct *dup_task_struct(struct task_struct *orig, int node)
 	if (!tsk)
 		return NULL;
 
+	err = arch_dup_task_struct(tsk, orig);
+	if (err)
+		goto free_tsk;
+
 	stack = alloc_thread_stack_node(tsk, node);
 	if (!stack)
 		goto free_tsk;
@@ -897,8 +901,6 @@ static struct task_struct *dup_task_struct(struct task_struct *orig, int node)
 
 	stack_vm_area = task_stack_vm_area(tsk);
 
-	err = arch_dup_task_struct(tsk, orig);
-
 	/*
 	 * arch_dup_task_struct() clobbers the stack-related fields.  Make
 	 * sure they're properly initialized before using any stack-related
@@ -912,9 +914,6 @@ static struct task_struct *dup_task_struct(struct task_struct *orig, int node)
 	refcount_set(&tsk->stack_refcount, 1);
 #endif
 
-	if (err)
-		goto free_stack;
-
 	err = scs_prepare(tsk, node);
 	if (err)
 		goto free_stack;
-- 
2.34.1
