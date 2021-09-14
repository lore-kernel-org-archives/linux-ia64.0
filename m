From: Masami Hiramatsu <mhiramat@kernel.org>
Date: Tue, 14 Sep 2021 14:39:06 +0000
Subject: [PATCH -tip v11 04/27] csky: ftrace: Drop duplicate implementation of arch_check_ftrace_location()
Message-Id: <163163034617.489837.7789033031868135258.stgit@devnote2>
List-Id: <linux-ia64.vger.kernel.org>
References: <163163030719.489837.2236069935502195491.stgit@devnote2>
In-Reply-To: <163163030719.489837.2236069935502195491.stgit@devnote2>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Steven Rostedt <rostedt@goodmis.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: X86 ML <x86@kernel.org>, Masami Hiramatsu <mhiramat@kernel.org>, Daniel Xu <dxu@dxuuu.xyz>, linux-kernel@vger.kernel.org, bpf@vger.kernel.org, kuba@kernel.org, mingo@redhat.com, ast@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@alien8.de>, Peter Zijlstra <peterz@infradead.org>, kernel-team@fb.com, yhs@fb.com, linux-ia64@vger.kernel.org, Abhishek Sagar <sagar.abhishek@gmail.com>, Andrii Nakryiko <andrii.nakryiko@gmail.com>, Paul McKenney <paulmck@kernel.org>

From: Punit Agrawal <punitagrawal@gmail.com>

The csky specific arch_check_ftrace_location() shadows a weak
implementation of the function in core code that offers the same
functionality but with additional error checking.

Drop the architecture specific function as a step towards further
cleanup in core code.

Signed-off-by: Punit Agrawal <punitagrawal@gmail.com>
Acked-by: Guo Ren <guoren@kernel.org>
Acked-by: Masami Hiramatsu <mhiramat@kernel.org>
Signed-off-by: Masami Hiramatsu <mhiramat@kernel.org>
---
 arch/csky/kernel/probes/ftrace.c |    7 -------
 1 file changed, 7 deletions(-)

diff --git a/arch/csky/kernel/probes/ftrace.c b/arch/csky/kernel/probes/ftrace.c
index ef2bb9bd9605..b388228abbf2 100644
--- a/arch/csky/kernel/probes/ftrace.c
+++ b/arch/csky/kernel/probes/ftrace.c
@@ -2,13 +2,6 @@
 
 #include <linux/kprobes.h>
 
-int arch_check_ftrace_location(struct kprobe *p)
-{
-	if (ftrace_location((unsigned long)p->addr))
-		p->flags |= KPROBE_FLAG_FTRACE;
-	return 0;
-}
-
 /* Ftrace callback handler for kprobes -- called under preepmt disabled */
 void kprobe_ftrace_handler(unsigned long ip, unsigned long parent_ip,
 			   struct ftrace_ops *ops, struct ftrace_regs *fregs)
