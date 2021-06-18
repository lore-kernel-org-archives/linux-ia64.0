From: Masami Hiramatsu <mhiramat@kernel.org>
Date: Fri, 18 Jun 2021 07:05:59 +0000
Subject: [PATCH -tip v8 04/13] kprobes: Add kretprobe_find_ret_addr() for searching return address
Message-Id: <162399995900.506599.7731349506430654425.stgit@devnote2>
List-Id: <linux-ia64.vger.kernel.org>
References: <162399992186.506599.8457763707951687195.stgit@devnote2>
In-Reply-To: <162399992186.506599.8457763707951687195.stgit@devnote2>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Steven Rostedt <rostedt@goodmis.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: X86 ML <x86@kernel.org>, Masami Hiramatsu <mhiramat@kernel.org>, Daniel Xu <dxu@dxuuu.xyz>, linux-kernel@vger.kernel.org, bpf@vger.kernel.org, kuba@kernel.org, mingo@redhat.com, ast@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@alien8.de>, Peter Zijlstra <peterz@infradead.org>, kernel-team@fb.com, yhs@fb.com, linux-ia64@vger.kernel.org, Abhishek Sagar <sagar.abhishek@gmail.com>, Andrii Nakryiko <andrii.nakryiko@gmail.com>

Add kretprobe_find_ret_addr() for searching correct return address
from kretprobe instance list.

Signed-off-by: Masami Hiramatsu <mhiramat@kernel.org>
Tested-by: Andrii Nakryik <andrii@kernel.org>
---
 Changes in v6:
  - Replace BUG_ON() with WARN_ON_ONCE() in __kretprobe_trampoline_handler().
 Changes in v3:
  - Remove generic stacktrace fixup. Instead, it should be solved in
    each unwinder. This just provide the generic interface.
 Changes in v2:
  - Add is_kretprobe_trampoline() for checking address outside of
    kretprobe_find_ret_addr()
  - Remove unneeded addr from kretprobe_find_ret_addr()
  - Rename fixup_kretprobe_tramp_addr() to fixup_kretprobe_trampoline()
---
 include/linux/kprobes.h |   22 +++++++++++
 kernel/kprobes.c        |   91 ++++++++++++++++++++++++++++++++++-------------
 2 files changed, 87 insertions(+), 26 deletions(-)

diff --git a/include/linux/kprobes.h b/include/linux/kprobes.h
index 5ce677819a25..08d3415e4418 100644
--- a/include/linux/kprobes.h
+++ b/include/linux/kprobes.h
@@ -207,6 +207,14 @@ static nokprobe_inline void *kretprobe_trampoline_addr(void)
 	return dereference_kernel_function_descriptor(kretprobe_trampoline);
 }
 
+static nokprobe_inline bool is_kretprobe_trampoline(unsigned long addr)
+{
+	return (void *)addr = kretprobe_trampoline_addr();
+}
+
+unsigned long kretprobe_find_ret_addr(struct task_struct *tsk, void *fp,
+				      struct llist_node **cur);
+
 /* If the trampoline handler called from a kprobe, use this version */
 unsigned long __kretprobe_trampoline_handler(struct pt_regs *regs,
 					     void *frame_pointer);
@@ -506,6 +514,20 @@ static inline bool is_kprobe_optinsn_slot(unsigned long addr)
 }
 #endif
 
+#if !defined(CONFIG_KRETPROBES)
+static nokprobe_inline bool is_kretprobe_trampoline(unsigned long addr)
+{
+	return false;
+}
+
+static nokprobe_inline
+unsigned long kretprobe_find_ret_addr(struct task_struct *tsk, void *fp,
+				      struct llist_node **cur)
+{
+	return 0;
+}
+#endif
+
 /* Returns true if kprobes handled the fault */
 static nokprobe_inline bool kprobe_page_fault(struct pt_regs *regs,
 					      unsigned int trap)
diff --git a/kernel/kprobes.c b/kernel/kprobes.c
index ad7a8c81ab06..650cbe738666 100644
--- a/kernel/kprobes.c
+++ b/kernel/kprobes.c
@@ -1840,45 +1840,69 @@ static struct notifier_block kprobe_exceptions_nb = {
 
 #ifdef CONFIG_KRETPROBES
 
-unsigned long __kretprobe_trampoline_handler(struct pt_regs *regs,
-					     void *frame_pointer)
+/* This assumes the tsk is current or the task which is not running. */
+static unsigned long __kretprobe_find_ret_addr(struct task_struct *tsk,
+					       struct llist_node **cur)
 {
-	kprobe_opcode_t *correct_ret_addr = NULL;
 	struct kretprobe_instance *ri = NULL;
-	struct llist_node *first, *node;
-	struct kretprobe *rp;
+	struct llist_node *node = *cur;
+
+	if (!node)
+		node = tsk->kretprobe_instances.first;
+	else
+		node = node->next;
 
-	/* Find all nodes for this frame. */
-	first = node = current->kretprobe_instances.first;
 	while (node) {
 		ri = container_of(node, struct kretprobe_instance, llist);
-
-		BUG_ON(ri->fp != frame_pointer);
-
 		if (ri->ret_addr != kretprobe_trampoline_addr()) {
-			correct_ret_addr = ri->ret_addr;
-			/*
-			 * This is the real return address. Any other
-			 * instances associated with this task are for
-			 * other calls deeper on the call stack
-			 */
-			goto found;
+			*cur = node;
+			return (unsigned long)ri->ret_addr;
 		}
-
 		node = node->next;
 	}
-	pr_err("Oops! Kretprobe fails to find correct return address.\n");
-	BUG_ON(1);
+	return 0;
+}
+NOKPROBE_SYMBOL(__kretprobe_find_ret_addr);
 
-found:
-	/* Unlink all nodes for this frame. */
-	current->kretprobe_instances.first = node->next;
-	node->next = NULL;
+unsigned long kretprobe_find_ret_addr(struct task_struct *tsk, void *fp,
+				      struct llist_node **cur)
+{
+	struct kretprobe_instance *ri = NULL;
+	unsigned long ret;
+
+	do {
+		ret = __kretprobe_find_ret_addr(tsk, cur);
+		if (!ret)
+			return ret;
+		ri = container_of(*cur, struct kretprobe_instance, llist);
+	} while (ri->fp != fp);
+
+	return ret;
+}
+NOKPROBE_SYMBOL(kretprobe_find_ret_addr);
 
-	/* Run them..  */
+unsigned long __kretprobe_trampoline_handler(struct pt_regs *regs,
+					     void *frame_pointer)
+{
+	kprobe_opcode_t *correct_ret_addr = NULL;
+	struct kretprobe_instance *ri = NULL;
+	struct llist_node *first, *node = NULL;
+	struct kretprobe *rp;
+
+	/* Find correct address and all nodes for this frame. */
+	correct_ret_addr = (void *)__kretprobe_find_ret_addr(current, &node);
+	if (!correct_ret_addr) {
+		pr_err("Oops! Kretprobe fails to find correct return address.\n");
+		BUG_ON(1);
+	}
+
+	/* Run them. */
+	first = current->kretprobe_instances.first;
 	while (first) {
 		ri = container_of(first, struct kretprobe_instance, llist);
-		first = first->next;
+
+		if (WARN_ON_ONCE(ri->fp != frame_pointer))
+			break;
 
 		rp = get_kretprobe(ri);
 		if (rp && rp->handler) {
@@ -1889,6 +1913,21 @@ unsigned long __kretprobe_trampoline_handler(struct pt_regs *regs,
 			rp->handler(ri, regs);
 			__this_cpu_write(current_kprobe, prev);
 		}
+		if (first = node)
+			break;
+
+		first = first->next;
+	}
+
+	/* Unlink all nodes for this frame. */
+	first = current->kretprobe_instances.first;
+	current->kretprobe_instances.first = node->next;
+	node->next = NULL;
+
+	/* Recycle them.  */
+	while (first) {
+		ri = container_of(first, struct kretprobe_instance, llist);
+		first = first->next;
 
 		recycle_rp_inst(ri);
 	}
