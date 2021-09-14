From: Masami Hiramatsu <mhiramat@kernel.org>
Date: Tue, 14 Sep 2021 14:39:16 +0000
Subject: [PATCH -tip v11 05/27] kprobes: Make arch_check_ftrace_location static
Message-Id: <163163035673.489837.2367816318195254104.stgit@devnote2>
List-Id: <linux-ia64.vger.kernel.org>
References: <163163030719.489837.2236069935502195491.stgit@devnote2>
In-Reply-To: <163163030719.489837.2236069935502195491.stgit@devnote2>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Steven Rostedt <rostedt@goodmis.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: X86 ML <x86@kernel.org>, Masami Hiramatsu <mhiramat@kernel.org>, Daniel Xu <dxu@dxuuu.xyz>, linux-kernel@vger.kernel.org, bpf@vger.kernel.org, kuba@kernel.org, mingo@redhat.com, ast@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@alien8.de>, Peter Zijlstra <peterz@infradead.org>, kernel-team@fb.com, yhs@fb.com, linux-ia64@vger.kernel.org, Abhishek Sagar <sagar.abhishek@gmail.com>, Andrii Nakryiko <andrii.nakryiko@gmail.com>, Paul McKenney <paulmck@kernel.org>

From: Punit Agrawal <punitagrawal@gmail.com>

arch_check_ftrace_location() was introduced as a weak function in
commit f7f242ff004499 ("kprobes: introduce weak
arch_check_ftrace_location() helper function") to allow architectures
to handle kprobes call site on their own.

Recently, the only architecture (csky) to implement
arch_check_ftrace_location() was migrated to using the common
version.

As a result, further cleanup the code to drop the weak attribute and
rename the function to remove the architecture specific
implementation.

Signed-off-by: Punit Agrawal <punitagrawal@gmail.com>
Acked-by: Masami Hiramatsu <mhiramat@kernel.org>
Signed-off-by: Masami Hiramatsu <mhiramat@kernel.org>
---
 include/linux/kprobes.h |    2 --
 kernel/kprobes.c        |    4 ++--
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/include/linux/kprobes.h b/include/linux/kprobes.h
index 0b75549b2815..8a9412bb0d5e 100644
--- a/include/linux/kprobes.h
+++ b/include/linux/kprobes.h
@@ -361,8 +361,6 @@ static inline int arch_prepare_kprobe_ftrace(struct kprobe *p)
 }
 #endif
 
-int arch_check_ftrace_location(struct kprobe *p);
-
 /* Get the kprobe at this addr (if any) - called with preemption disabled */
 struct kprobe *get_kprobe(void *addr);
 
diff --git a/kernel/kprobes.c b/kernel/kprobes.c
index cfa9d3c263eb..30199bfcc74a 100644
--- a/kernel/kprobes.c
+++ b/kernel/kprobes.c
@@ -1524,7 +1524,7 @@ static inline int warn_kprobe_rereg(struct kprobe *p)
 	return ret;
 }
 
-int __weak arch_check_ftrace_location(struct kprobe *p)
+static int check_ftrace_location(struct kprobe *p)
 {
 	unsigned long ftrace_addr;
 
@@ -1547,7 +1547,7 @@ static int check_kprobe_address_safe(struct kprobe *p,
 {
 	int ret;
 
-	ret = arch_check_ftrace_location(p);
+	ret = check_ftrace_location(p);
 	if (ret)
 		return ret;
 	jump_label_lock();
