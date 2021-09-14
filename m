From: Masami Hiramatsu <mhiramat@kernel.org>
Date: Tue, 14 Sep 2021 14:42:51 +0000
Subject: [PATCH -tip v11 27/27] x86/kprobes: Fixup return address in generic trampoline handler
Message-Id: <163163057094.489837.9044470370440745866.stgit@devnote2>
List-Id: <linux-ia64.vger.kernel.org>
References: <163163030719.489837.2236069935502195491.stgit@devnote2>
In-Reply-To: <163163030719.489837.2236069935502195491.stgit@devnote2>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Steven Rostedt <rostedt@goodmis.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: X86 ML <x86@kernel.org>, Masami Hiramatsu <mhiramat@kernel.org>, Daniel Xu <dxu@dxuuu.xyz>, linux-kernel@vger.kernel.org, bpf@vger.kernel.org, kuba@kernel.org, mingo@redhat.com, ast@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@alien8.de>, Peter Zijlstra <peterz@infradead.org>, kernel-team@fb.com, yhs@fb.com, linux-ia64@vger.kernel.org, Abhishek Sagar <sagar.abhishek@gmail.com>, Andrii Nakryiko <andrii.nakryiko@gmail.com>, Paul McKenney <paulmck@kernel.org>

In x86, the fake return address on the stack saved by
__kretprobe_trampoline() will be replaced with the real return
address after returning from trampoline_handler(). Before fixing
the return address, the real return address can be found in the
'current->kretprobe_instances'.

However, since there is a window between updating the
'current->kretprobe_instances' and fixing the address on the stack,
if an interrupt happens at that timing and the interrupt handler
does stacktrace, it may fail to unwind because it can not get
the correct return address from 'current->kretprobe_instances'.

This will eliminate that window by fixing the return address
right before updating 'current->kretprobe_instances'.

Signed-off-by: Masami Hiramatsu <mhiramat@kernel.org>
Tested-by: Andrii Nakryiko <andrii@kernel.org>
---
 Changes in v9:
  - Fixes the changelog. This can eliminate the window.
  - Add more comment how it works.
 Changes in v7:
  - Add a prototype for arch_kretprobe_fixup_return()
---
 arch/x86/kernel/kprobes/core.c |   18 ++++++++++++++++--
 include/linux/kprobes.h        |    3 +++
 kernel/kprobes.c               |   11 +++++++++++
 3 files changed, 30 insertions(+), 2 deletions(-)

diff --git a/arch/x86/kernel/kprobes/core.c b/arch/x86/kernel/kprobes/core.c
index 7e1111c19605..fce99e249d61 100644
--- a/arch/x86/kernel/kprobes/core.c
+++ b/arch/x86/kernel/kprobes/core.c
@@ -1065,6 +1065,16 @@ NOKPROBE_SYMBOL(__kretprobe_trampoline);
  */
 STACK_FRAME_NON_STANDARD_FP(__kretprobe_trampoline);
 
+/* This is called from kretprobe_trampoline_handler(). */
+void arch_kretprobe_fixup_return(struct pt_regs *regs,
+				 kprobe_opcode_t *correct_ret_addr)
+{
+	unsigned long *frame_pointer = &regs->sp + 1;
+
+	/* Replace fake return address with real one. */
+	*frame_pointer = (unsigned long)correct_ret_addr;
+}
+
 /*
  * Called from __kretprobe_trampoline
  */
@@ -1082,8 +1092,12 @@ __used __visible void trampoline_handler(struct pt_regs *regs)
 	regs->sp += sizeof(long);
 	frame_pointer = &regs->sp + 1;
 
-	/* Replace fake return address with real one. */
-	*frame_pointer = kretprobe_trampoline_handler(regs, frame_pointer);
+	/*
+	 * The return address at 'frame_pointer' is recovered by the
+	 * arch_kretprobe_fixup_return() which called from the
+	 * kretprobe_trampoline_handler().
+	 */
+	kretprobe_trampoline_handler(regs, frame_pointer);
 
 	/*
 	 * Copy FLAGS to 'pt_regs::sp' so that __kretprobe_trapmoline()
diff --git a/include/linux/kprobes.h b/include/linux/kprobes.h
index 6d47a9da1e0a..e974caf39d3e 100644
--- a/include/linux/kprobes.h
+++ b/include/linux/kprobes.h
@@ -188,6 +188,9 @@ extern void arch_prepare_kretprobe(struct kretprobe_instance *ri,
 				   struct pt_regs *regs);
 extern int arch_trampoline_kprobe(struct kprobe *p);
 
+void arch_kretprobe_fixup_return(struct pt_regs *regs,
+				 kprobe_opcode_t *correct_ret_addr);
+
 void __kretprobe_trampoline(void);
 /*
  * Since some architecture uses structured function pointer,
diff --git a/kernel/kprobes.c b/kernel/kprobes.c
index ebc587b9a346..b62af9fc3607 100644
--- a/kernel/kprobes.c
+++ b/kernel/kprobes.c
@@ -1922,6 +1922,15 @@ unsigned long kretprobe_find_ret_addr(struct task_struct *tsk, void *fp,
 }
 NOKPROBE_SYMBOL(kretprobe_find_ret_addr);
 
+void __weak arch_kretprobe_fixup_return(struct pt_regs *regs,
+					kprobe_opcode_t *correct_ret_addr)
+{
+	/*
+	 * Do nothing by default. Please fill this to update the fake return
+	 * address on the stack with the correct one on each arch if possible.
+	 */
+}
+
 unsigned long __kretprobe_trampoline_handler(struct pt_regs *regs,
 					     void *frame_pointer)
 {
@@ -1967,6 +1976,8 @@ unsigned long __kretprobe_trampoline_handler(struct pt_regs *regs,
 		first = first->next;
 	}
 
+	arch_kretprobe_fixup_return(regs, correct_ret_addr);
+
 	/* Unlink all nodes for this frame. */
 	first = current->kretprobe_instances.first;
 	current->kretprobe_instances.first = node->next;
