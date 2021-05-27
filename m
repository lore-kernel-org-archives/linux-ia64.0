From: Masami Hiramatsu <mhiramat@kernel.org>
Date: Thu, 27 May 2021 06:41:07 +0000
Subject: [PATCH -tip v7 13/13] x86/kprobes: Fixup return address in generic trampoline handler
Message-Id: <162209766692.436794.8217254931414018689.stgit@devnote2>
List-Id: <linux-ia64.vger.kernel.org>
References: <162209754288.436794.3904335049560916855.stgit@devnote2>
In-Reply-To: <162209754288.436794.3904335049560916855.stgit@devnote2>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@kernel.org>
Cc: X86 ML <x86@kernel.org>, Masami Hiramatsu <mhiramat@kernel.org>, Daniel Xu <dxu@dxuuu.xyz>, linux-kernel@vger.kernel.org, bpf@vger.kernel.org, kuba@kernel.org, mingo@redhat.com, ast@kernel.org, tglx@linutronix.de, kernel-team@fb.com, yhs@fb.com, Josh Poimboeuf <jpoimboe@redhat.com>, linux-ia64@vger.kernel.org, Abhishek Sagar <sagar.abhishek@gmail.com>, Andrii Nakryiko <andrii.nakryiko@gmail.com>

In x86, kretprobe trampoline address on the stack frame will
be replaced with the real return address after returning from
trampoline_handler. Before fixing the return address, the real
return address can be found in the current->kretprobe_instances.

However, since there is a window between updating the
current->kretprobe_instances and fixing the address on the stack,
if an interrupt caused at that timing and the interrupt handler
does stacktrace, it may fail to unwind because it can not get
the correct return address from current->kretprobe_instances.

This will minimize that window by fixing the return address
right before updating current->kretprobe_instances.

Signed-off-by: Masami Hiramatsu <mhiramat@kernel.org>
Tested-by: Andrii Nakryik <andrii@kernel.org>
---
 Changes in v7:
  - Add a prototype for arch_kretprobe_fixup_return()
---
 arch/x86/kernel/kprobes/core.c |   15 +++++++++++++--
 include/linux/kprobes.h        |    3 +++
 kernel/kprobes.c               |    8 ++++++++
 3 files changed, 24 insertions(+), 2 deletions(-)

diff --git a/arch/x86/kernel/kprobes/core.c b/arch/x86/kernel/kprobes/core.c
index 4f3567a9974f..3dec85ca5d9e 100644
--- a/arch/x86/kernel/kprobes/core.c
+++ b/arch/x86/kernel/kprobes/core.c
@@ -1032,6 +1032,7 @@ STACK_FRAME_NON_STANDARD(kretprobe_trampoline);
 #undef UNWIND_HINT_FUNC
 #define UNWIND_HINT_FUNC
 #endif
+
 /*
  * When a retprobed function returns, this code saves registers and
  * calls trampoline_handler() runs, which calls the kretprobe's handler.
@@ -1073,6 +1074,17 @@ asm(
 );
 NOKPROBE_SYMBOL(kretprobe_trampoline);
 
+void arch_kretprobe_fixup_return(struct pt_regs *regs,
+				 unsigned long correct_ret_addr)
+{
+	unsigned long *frame_pointer;
+
+	frame_pointer = ((unsigned long *)&regs->sp) + 1;
+
+	/* Replace fake return address with real one. */
+	*frame_pointer = correct_ret_addr;
+}
+
 /*
  * Called from kretprobe_trampoline
  */
@@ -1090,8 +1102,7 @@ __used __visible void trampoline_handler(struct pt_regs *regs)
 	regs->sp += sizeof(long);
 	frame_pointer = ((unsigned long *)&regs->sp) + 1;
 
-	/* Replace fake return address with real one. */
-	*frame_pointer = kretprobe_trampoline_handler(regs, frame_pointer);
+	kretprobe_trampoline_handler(regs, frame_pointer);
 	/*
 	 * Move flags to sp so that kretprobe_trapmoline can return
 	 * right after popf.
diff --git a/include/linux/kprobes.h b/include/linux/kprobes.h
index f530f82a046d..c2017f1cdf81 100644
--- a/include/linux/kprobes.h
+++ b/include/linux/kprobes.h
@@ -205,6 +205,9 @@ extern void arch_prepare_kretprobe(struct kretprobe_instance *ri,
 				   struct pt_regs *regs);
 extern int arch_trampoline_kprobe(struct kprobe *p);
 
+void arch_kretprobe_fixup_return(struct pt_regs *regs,
+				 unsigned long correct_ret_addr);
+
 void kretprobe_trampoline(void);
 /*
  * Since some architecture uses structured function pointer,
diff --git a/kernel/kprobes.c b/kernel/kprobes.c
index 1598aca375c9..d5869664bb61 100644
--- a/kernel/kprobes.c
+++ b/kernel/kprobes.c
@@ -1899,6 +1899,12 @@ unsigned long kretprobe_find_ret_addr(struct task_struct *tsk, void *fp,
 }
 NOKPROBE_SYMBOL(kretprobe_find_ret_addr);
 
+void __weak arch_kretprobe_fixup_return(struct pt_regs *regs,
+					unsigned long correct_ret_addr)
+{
+	/* Do nothing by default. */
+}
+
 unsigned long __kretprobe_trampoline_handler(struct pt_regs *regs,
 					     void *frame_pointer)
 {
@@ -1940,6 +1946,8 @@ unsigned long __kretprobe_trampoline_handler(struct pt_regs *regs,
 		first = first->next;
 	}
 
+	arch_kretprobe_fixup_return(regs, (unsigned long)correct_ret_addr);
+
 	/* Unlink all nodes for this frame. */
 	first = current->kretprobe_instances.first;
 	current->kretprobe_instances.first = node->next;
