From: Masami Hiramatsu <mhiramat@kernel.org>
Date: Tue, 14 Sep 2021 14:39:55 +0000
Subject: [PATCH -tip v11 09/27] kprobes: Add assertions for required lock
Message-Id: <163163039572.489837.18011973177537476885.stgit@devnote2>
List-Id: <linux-ia64.vger.kernel.org>
References: <163163030719.489837.2236069935502195491.stgit@devnote2>
In-Reply-To: <163163030719.489837.2236069935502195491.stgit@devnote2>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Steven Rostedt <rostedt@goodmis.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: X86 ML <x86@kernel.org>, Masami Hiramatsu <mhiramat@kernel.org>, Daniel Xu <dxu@dxuuu.xyz>, linux-kernel@vger.kernel.org, bpf@vger.kernel.org, kuba@kernel.org, mingo@redhat.com, ast@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@alien8.de>, Peter Zijlstra <peterz@infradead.org>, kernel-team@fb.com, yhs@fb.com, linux-ia64@vger.kernel.org, Abhishek Sagar <sagar.abhishek@gmail.com>, Andrii Nakryiko <andrii.nakryiko@gmail.com>, Paul McKenney <paulmck@kernel.org>

Add assertions for required locks instead of comment it
so that the lockdep can inspect locks automatically.

Signed-off-by: Masami Hiramatsu <mhiramat@kernel.org>
---
 kernel/kprobes.c |   19 ++++++++++++-------
 1 file changed, 12 insertions(+), 7 deletions(-)

diff --git a/kernel/kprobes.c b/kernel/kprobes.c
index ad39eeaa4371..ec3d97fd8c6b 100644
--- a/kernel/kprobes.c
+++ b/kernel/kprobes.c
@@ -959,11 +959,13 @@ int proc_kprobes_optimization_handler(struct ctl_table *table, int write,
 }
 #endif /* CONFIG_SYSCTL */
 
-/* Put a breakpoint for a probe. Must be called with 'text_mutex' locked. */
+/* Put a breakpoint for a probe. */
 static void __arm_kprobe(struct kprobe *p)
 {
 	struct kprobe *_p;
 
+	lockdep_assert_held(&text_mutex);
+
 	/* Find the overlapping optimized kprobes. */
 	_p = get_optimized_kprobe((unsigned long)p->addr);
 	if (unlikely(_p))
@@ -974,11 +976,13 @@ static void __arm_kprobe(struct kprobe *p)
 	optimize_kprobe(p);	/* Try to optimize (add kprobe to a list) */
 }
 
-/* Remove the breakpoint of a probe. Must be called with 'text_mutex' locked. */
+/* Remove the breakpoint of a probe. */
 static void __disarm_kprobe(struct kprobe *p, bool reopt)
 {
 	struct kprobe *_p;
 
+	lockdep_assert_held(&text_mutex);
+
 	/* Try to unoptimize */
 	unoptimize_kprobe(p, kprobes_all_disarmed);
 
@@ -1047,12 +1051,13 @@ static struct ftrace_ops kprobe_ipmodify_ops __read_mostly = {
 static int kprobe_ipmodify_enabled;
 static int kprobe_ftrace_enabled;
 
-/* Caller must lock 'kprobe_mutex' */
 static int __arm_kprobe_ftrace(struct kprobe *p, struct ftrace_ops *ops,
 			       int *cnt)
 {
 	int ret = 0;
 
+	lockdep_assert_held(&kprobe_mutex);
+
 	ret = ftrace_set_filter_ip(ops, (unsigned long)p->addr, 0, 0);
 	if (WARN_ONCE(ret < 0, "Failed to arm kprobe-ftrace at %pS (error %d)\n", p->addr, ret))
 		return ret;
@@ -1084,12 +1089,13 @@ static int arm_kprobe_ftrace(struct kprobe *p)
 		ipmodify ? &kprobe_ipmodify_enabled : &kprobe_ftrace_enabled);
 }
 
-/* Caller must lock 'kprobe_mutex'. */
 static int __disarm_kprobe_ftrace(struct kprobe *p, struct ftrace_ops *ops,
 				  int *cnt)
 {
 	int ret = 0;
 
+	lockdep_assert_held(&kprobe_mutex);
+
 	if (*cnt = 1) {
 		ret = unregister_ftrace_function(ops);
 		if (WARN(ret < 0, "Failed to unregister kprobe-ftrace (error %d)\n", ret))
@@ -1133,7 +1139,6 @@ static int prepare_kprobe(struct kprobe *p)
 	return arch_prepare_kprobe(p);
 }
 
-/* Arm a kprobe with 'text_mutex'. */
 static int arm_kprobe(struct kprobe *kp)
 {
 	if (unlikely(kprobe_ftrace(kp)))
@@ -1148,7 +1153,6 @@ static int arm_kprobe(struct kprobe *kp)
 	return 0;
 }
 
-/* Disarm a kprobe with 'text_mutex'. */
 static int disarm_kprobe(struct kprobe *kp, bool reopt)
 {
 	if (unlikely(kprobe_ftrace(kp)))
@@ -1691,12 +1695,13 @@ static int aggr_kprobe_disabled(struct kprobe *ap)
 	return 1;
 }
 
-/* Disable one kprobe: Make sure called under 'kprobe_mutex' is locked. */
 static struct kprobe *__disable_kprobe(struct kprobe *p)
 {
 	struct kprobe *orig_p;
 	int ret;
 
+	lockdep_assert_held(&kprobe_mutex);
+
 	/* Get an original kprobe for return */
 	orig_p = __get_valid_kprobe(p);
 	if (unlikely(orig_p = NULL))
