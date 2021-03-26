From: Masami Hiramatsu <mhiramat@kernel.org>
Date: Fri, 26 Mar 2021 12:30:42 +0000
Subject: [PATCH -tip v5 12/12] tracing: Show kretprobe unknown indicator only for kretprobe_trampoline
Message-Id: <161676184261.330141.6575911414561853358.stgit@devnote2>
List-Id: <linux-ia64.vger.kernel.org>
References: <161676170650.330141.6214727134265514123.stgit@devnote2>
In-Reply-To: <161676170650.330141.6214727134265514123.stgit@devnote2>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@kernel.org>
Cc: X86 ML <x86@kernel.org>, Masami Hiramatsu <mhiramat@kernel.org>, Daniel Xu <dxu@dxuuu.xyz>, linux-kernel@vger.kernel.org, bpf@vger.kernel.org, kuba@kernel.org, mingo@redhat.com, ast@kernel.org, tglx@linutronix.de, kernel-team@fb.com, yhs@fb.com, Josh Poimboeuf <jpoimboe@redhat.com>, linux-ia64@vger.kernel.org, Abhishek Sagar <sagar.abhishek@gmail.com>

ftrace shows "[unknown/kretprobe'd]" indicator all addresses in the
kretprobe_trampoline, but the modified address by kretprobe should
be only kretprobe_trampoline+0.

Signed-off-by: Masami Hiramatsu <mhiramat@kernel.org>
Acked-by: Steven Rostedt (VMware) <rostedt@goodmis.org>
---
 kernel/trace/trace_output.c |   17 ++++-------------
 1 file changed, 4 insertions(+), 13 deletions(-)

diff --git a/kernel/trace/trace_output.c b/kernel/trace/trace_output.c
index 61255bad7e01..e12437388686 100644
--- a/kernel/trace/trace_output.c
+++ b/kernel/trace/trace_output.c
@@ -8,6 +8,7 @@
 #include <linux/module.h>
 #include <linux/mutex.h>
 #include <linux/ftrace.h>
+#include <linux/kprobes.h>
 #include <linux/sched/clock.h>
 #include <linux/sched/mm.h>
 
@@ -346,22 +347,12 @@ int trace_output_call(struct trace_iterator *iter, char *name, char *fmt, ...)
 }
 EXPORT_SYMBOL_GPL(trace_output_call);
 
-#ifdef CONFIG_KRETPROBES
-static inline const char *kretprobed(const char *name)
+static inline const char *kretprobed(const char *name, unsigned long addr)
 {
-	static const char tramp_name[] = "kretprobe_trampoline";
-	int size = sizeof(tramp_name);
-
-	if (strncmp(tramp_name, name, size) = 0)
+	if (is_kretprobe_trampoline(addr))
 		return "[unknown/kretprobe'd]";
 	return name;
 }
-#else
-static inline const char *kretprobed(const char *name)
-{
-	return name;
-}
-#endif /* CONFIG_KRETPROBES */
 
 void
 trace_seq_print_sym(struct trace_seq *s, unsigned long address, bool offset)
@@ -374,7 +365,7 @@ trace_seq_print_sym(struct trace_seq *s, unsigned long address, bool offset)
 		sprint_symbol(str, address);
 	else
 		kallsyms_lookup(address, NULL, NULL, NULL, str);
-	name = kretprobed(str);
+	name = kretprobed(str, address);
 
 	if (name && strlen(name)) {
 		trace_seq_puts(s, name);
