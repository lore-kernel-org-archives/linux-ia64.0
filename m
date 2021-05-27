From: Masami Hiramatsu <mhiramat@kernel.org>
Date: Thu, 27 May 2021 06:40:29 +0000
Subject: [PATCH -tip v7 09/13] kprobes: Setup instruction pointer in __kretprobe_trampoline_handler
Message-Id: <162209762943.436794.874947392889792501.stgit@devnote2>
List-Id: <linux-ia64.vger.kernel.org>
References: <162209754288.436794.3904335049560916855.stgit@devnote2>
In-Reply-To: <162209754288.436794.3904335049560916855.stgit@devnote2>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@kernel.org>
Cc: X86 ML <x86@kernel.org>, Masami Hiramatsu <mhiramat@kernel.org>, Daniel Xu <dxu@dxuuu.xyz>, linux-kernel@vger.kernel.org, bpf@vger.kernel.org, kuba@kernel.org, mingo@redhat.com, ast@kernel.org, tglx@linutronix.de, kernel-team@fb.com, yhs@fb.com, Josh Poimboeuf <jpoimboe@redhat.com>, linux-ia64@vger.kernel.org, Abhishek Sagar <sagar.abhishek@gmail.com>, Andrii Nakryiko <andrii.nakryiko@gmail.com>

To simplify the stacktrace with pt_regs from kretprobe handler,
set the correct return address to the instruction pointer in
the pt_regs before calling kretprobe handlers.

Suggested-by: Josh Poimboeuf <jpoimboe@redhat.com>
Signed-off-by: Masami Hiramatsu <mhiramat@kernel.org>
Tested-by: Andrii Nakryik <andrii@kernel.org>
---
 Changes in v3:
  - Cast the correct_ret_addr to unsigned long.
---
 kernel/kprobes.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/kernel/kprobes.c b/kernel/kprobes.c
index 54e5b89aad67..1598aca375c9 100644
--- a/kernel/kprobes.c
+++ b/kernel/kprobes.c
@@ -1914,6 +1914,9 @@ unsigned long __kretprobe_trampoline_handler(struct pt_regs *regs,
 		BUG_ON(1);
 	}
 
+	/* Set the instruction pointer to the correct address */
+	instruction_pointer_set(regs, (unsigned long)correct_ret_addr);
+
 	/* Run them. */
 	first = current->kretprobe_instances.first;
 	while (first) {
