From: Masami Hiramatsu <mhiramat@kernel.org>
Date: Tue, 14 Sep 2021 14:42:12 +0000
Subject: [PATCH -tip v11 23/27] kprobes: Enable stacktrace from pt_regs in kretprobe handler
Message-Id: <163163053237.489837.4272653874525136832.stgit@devnote2>
List-Id: <linux-ia64.vger.kernel.org>
References: <163163030719.489837.2236069935502195491.stgit@devnote2>
In-Reply-To: <163163030719.489837.2236069935502195491.stgit@devnote2>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Steven Rostedt <rostedt@goodmis.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: X86 ML <x86@kernel.org>, Masami Hiramatsu <mhiramat@kernel.org>, Daniel Xu <dxu@dxuuu.xyz>, linux-kernel@vger.kernel.org, bpf@vger.kernel.org, kuba@kernel.org, mingo@redhat.com, ast@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@alien8.de>, Peter Zijlstra <peterz@infradead.org>, kernel-team@fb.com, yhs@fb.com, linux-ia64@vger.kernel.org, Abhishek Sagar <sagar.abhishek@gmail.com>, Andrii Nakryiko <andrii.nakryiko@gmail.com>, Paul McKenney <paulmck@kernel.org>

Since the ORC unwinder from pt_regs requires setting up regs->ip
correctly, set the correct return address to the regs->ip before
calling user kretprobe handler.

This allows the kretrprobe handler to trace stack from the
kretprobe's pt_regs by stack_trace_save_regs() (eBPF will do
this), instead of stack tracing from the handler context by
stack_trace_save() (ftrace will do this).

Suggested-by: Josh Poimboeuf <jpoimboe@redhat.com>
Signed-off-by: Masami Hiramatsu <mhiramat@kernel.org>
Tested-by: Andrii Nakryiko <andrii@kernel.org>
Acked-by: Josh Poimboeuf <jpoimboe@redhat.com>
---
 Changes in v9:
  - Update comment to explain specifically why this is necessary.
 Changes in v8:
  - Update comment to clarify why this is needed.
 Changes in v3:
  - Cast the correct_ret_addr to unsigned long.
---
 kernel/kprobes.c |    7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/kernel/kprobes.c b/kernel/kprobes.c
index 833f07f33115..ebc587b9a346 100644
--- a/kernel/kprobes.c
+++ b/kernel/kprobes.c
@@ -1937,6 +1937,13 @@ unsigned long __kretprobe_trampoline_handler(struct pt_regs *regs,
 		BUG_ON(1);
 	}
 
+	/*
+	 * Set the return address as the instruction pointer, because if the
+	 * user handler calls stack_trace_save_regs() with this 'regs',
+	 * the stack trace will start from the instruction pointer.
+	 */
+	instruction_pointer_set(regs, (unsigned long)correct_ret_addr);
+
 	/* Run the user handler of the nodes. */
 	first = current->kretprobe_instances.first;
 	while (first) {
