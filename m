From: Masami Hiramatsu <mhiramat@kernel.org>
Date: Sun, 11 Jul 2021 13:36:14 +0000
Subject: [PATCH -tip v9 09/14] arm: kprobes: Make space for instruction pointer on stack
Message-Id: <162601057463.1318837.12052634205343013760.stgit@devnote2>
List-Id: <linux-ia64.vger.kernel.org>
References: <162601048053.1318837.1550594515476777588.stgit@devnote2>
In-Reply-To: <162601048053.1318837.1550594515476777588.stgit@devnote2>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Steven Rostedt <rostedt@goodmis.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: X86 ML <x86@kernel.org>, Masami Hiramatsu <mhiramat@kernel.org>, Daniel Xu <dxu@dxuuu.xyz>, linux-kernel@vger.kernel.org, bpf@vger.kernel.org, kuba@kernel.org, mingo@redhat.com, ast@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@alien8.de>, Peter Zijlstra <peterz@infradead.org>, kernel-team@fb.com, yhs@fb.com, linux-ia64@vger.kernel.org, Abhishek Sagar <sagar.abhishek@gmail.com>, Andrii Nakryiko <andrii.nakryiko@gmail.com>

Since arm's __kretprobe_trampoline() saves partial 'pt_regs' on the
stack, 'regs->ARM_pc' (instruction pointer) is not accessible from
the kretprobe handler. This means if instruction_pointer_set() is
used from kretprobe handler, it will break the data on the stack.

Make space for instruction pointer (ARM_pc) on the stack in the
__kretprobe_trampoline() for fixing this problem.

Signed-off-by: Masami Hiramatsu <mhiramat@kernel.org>
---
 Changes in v9:
  - Update changelog.
---
 arch/arm/probes/kprobes/core.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/arm/probes/kprobes/core.c b/arch/arm/probes/kprobes/core.c
index 67ce7eb8f285..95f23b47ba27 100644
--- a/arch/arm/probes/kprobes/core.c
+++ b/arch/arm/probes/kprobes/core.c
@@ -376,11 +376,13 @@ int __kprobes kprobe_exceptions_notify(struct notifier_block *self,
 void __naked __kprobes __kretprobe_trampoline(void)
 {
 	__asm__ __volatile__ (
+		"sub	sp, sp, #16		\n\t"
 		"stmdb	sp!, {r0 - r11}		\n\t"
 		"mov	r0, sp			\n\t"
 		"bl	trampoline_handler	\n\t"
 		"mov	lr, r0			\n\t"
 		"ldmia	sp!, {r0 - r11}		\n\t"
+		"add	sp, sp, #16		\n\t"
 #ifdef CONFIG_THUMB2_KERNEL
 		"bx	lr			\n\t"
 #else
