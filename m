From: Masami Hiramatsu <mhiramat@kernel.org>
Date: Tue, 14 Sep 2021 14:39:46 +0000
Subject: [PATCH -tip v11 08/27] kprobes: Use IS_ENABLED() instead of kprobes_built_in()
Message-Id: <163163038581.489837.2805250706507372658.stgit@devnote2>
List-Id: <linux-ia64.vger.kernel.org>
References: <163163030719.489837.2236069935502195491.stgit@devnote2>
In-Reply-To: <163163030719.489837.2236069935502195491.stgit@devnote2>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Steven Rostedt <rostedt@goodmis.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: X86 ML <x86@kernel.org>, Masami Hiramatsu <mhiramat@kernel.org>, Daniel Xu <dxu@dxuuu.xyz>, linux-kernel@vger.kernel.org, bpf@vger.kernel.org, kuba@kernel.org, mingo@redhat.com, ast@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@alien8.de>, Peter Zijlstra <peterz@infradead.org>, kernel-team@fb.com, yhs@fb.com, linux-ia64@vger.kernel.org, Abhishek Sagar <sagar.abhishek@gmail.com>, Andrii Nakryiko <andrii.nakryiko@gmail.com>, Paul McKenney <paulmck@kernel.org>

Use IS_ENABLED(CONFIG_KPROBES) instead of kprobes_built_in().
This inline function is introduced only for avoiding #ifdef.
But since now we have IS_ENABLED(), it is no longer needed.

Signed-off-by: Masami Hiramatsu <mhiramat@kernel.org>
---
 include/linux/kprobes.h |   14 +-------------
 1 file changed, 1 insertion(+), 13 deletions(-)

diff --git a/include/linux/kprobes.h b/include/linux/kprobes.h
index 756d3d23ce37..9c28fbb18e74 100644
--- a/include/linux/kprobes.h
+++ b/include/linux/kprobes.h
@@ -180,14 +180,6 @@ struct kprobe_blacklist_entry {
 DECLARE_PER_CPU(struct kprobe *, current_kprobe);
 DECLARE_PER_CPU(struct kprobe_ctlblk, kprobe_ctlblk);
 
-/*
- * For #ifdef avoidance:
- */
-static inline int kprobes_built_in(void)
-{
-	return 1;
-}
-
 extern void kprobe_busy_begin(void);
 extern void kprobe_busy_end(void);
 
@@ -417,10 +409,6 @@ int arch_kprobe_get_kallsym(unsigned int *symnum, unsigned long *value,
 			    char *type, char *sym);
 #else /* !CONFIG_KPROBES: */
 
-static inline int kprobes_built_in(void)
-{
-	return 0;
-}
 static inline int kprobe_fault_handler(struct pt_regs *regs, int trapnr)
 {
 	return 0;
@@ -514,7 +502,7 @@ static inline bool is_kprobe_optinsn_slot(unsigned long addr)
 static nokprobe_inline bool kprobe_page_fault(struct pt_regs *regs,
 					      unsigned int trap)
 {
-	if (!kprobes_built_in())
+	if (!IS_ENABLED(CONFIG_KPROBES))
 		return false;
 	if (user_mode(regs))
 		return false;
