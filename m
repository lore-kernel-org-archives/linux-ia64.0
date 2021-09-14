From: Masami Hiramatsu <mhiramat@kernel.org>
Date: Tue, 14 Sep 2021 14:40:16 +0000
Subject: [PATCH -tip v11 11/27] kprobes: Use bool type for functions which returns boolean value
Message-Id: <163163041649.489837.17311187321419747536.stgit@devnote2>
List-Id: <linux-ia64.vger.kernel.org>
References: <163163030719.489837.2236069935502195491.stgit@devnote2>
In-Reply-To: <163163030719.489837.2236069935502195491.stgit@devnote2>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Steven Rostedt <rostedt@goodmis.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: X86 ML <x86@kernel.org>, Masami Hiramatsu <mhiramat@kernel.org>, Daniel Xu <dxu@dxuuu.xyz>, linux-kernel@vger.kernel.org, bpf@vger.kernel.org, kuba@kernel.org, mingo@redhat.com, ast@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@alien8.de>, Peter Zijlstra <peterz@infradead.org>, kernel-team@fb.com, yhs@fb.com, linux-ia64@vger.kernel.org, Abhishek Sagar <sagar.abhishek@gmail.com>, Andrii Nakryiko <andrii.nakryiko@gmail.com>, Paul McKenney <paulmck@kernel.org>

Use the 'bool' type instead of 'int' for the functions which
returns a boolean value, because this makes clear that those
functions don't return any error code.

Signed-off-by: Masami Hiramatsu <mhiramat@kernel.org>
---
 Changes in v2:
  - Fix trace_kprobe's kprobe_gone() too.
---
 include/linux/kprobes.h     |    8 ++++----
 kernel/kprobes.c            |   26 +++++++++++++-------------
 kernel/trace/trace_kprobe.c |    2 +-
 3 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/include/linux/kprobes.h b/include/linux/kprobes.h
index 6a5995f334a0..0ba3f9e316d4 100644
--- a/include/linux/kprobes.h
+++ b/include/linux/kprobes.h
@@ -104,25 +104,25 @@ struct kprobe {
 #define KPROBE_FLAG_FTRACE	8 /* probe is using ftrace */
 
 /* Has this kprobe gone ? */
-static inline int kprobe_gone(struct kprobe *p)
+static inline bool kprobe_gone(struct kprobe *p)
 {
 	return p->flags & KPROBE_FLAG_GONE;
 }
 
 /* Is this kprobe disabled ? */
-static inline int kprobe_disabled(struct kprobe *p)
+static inline bool kprobe_disabled(struct kprobe *p)
 {
 	return p->flags & (KPROBE_FLAG_DISABLED | KPROBE_FLAG_GONE);
 }
 
 /* Is this kprobe really running optimized path ? */
-static inline int kprobe_optimized(struct kprobe *p)
+static inline bool kprobe_optimized(struct kprobe *p)
 {
 	return p->flags & KPROBE_FLAG_OPTIMIZED;
 }
 
 /* Is this kprobe uses ftrace ? */
-static inline int kprobe_ftrace(struct kprobe *p)
+static inline bool kprobe_ftrace(struct kprobe *p)
 {
 	return p->flags & KPROBE_FLAG_FTRACE;
 }
diff --git a/kernel/kprobes.c b/kernel/kprobes.c
index b6f1dcf4bff3..8021bccb7770 100644
--- a/kernel/kprobes.c
+++ b/kernel/kprobes.c
@@ -198,8 +198,8 @@ kprobe_opcode_t *__get_insn_slot(struct kprobe_insn_cache *c)
 	return slot;
 }
 
-/* Return 1 if all garbages are collected, otherwise 0. */
-static int collect_one_slot(struct kprobe_insn_page *kip, int idx)
+/* Return true if all garbages are collected, otherwise false. */
+static bool collect_one_slot(struct kprobe_insn_page *kip, int idx)
 {
 	kip->slot_used[idx] = SLOT_CLEAN;
 	kip->nused--;
@@ -223,9 +223,9 @@ static int collect_one_slot(struct kprobe_insn_page *kip, int idx)
 			kip->cache->free(kip->insns);
 			kfree(kip);
 		}
-		return 1;
+		return true;
 	}
-	return 0;
+	return false;
 }
 
 static int collect_garbage_slots(struct kprobe_insn_cache *c)
@@ -389,13 +389,13 @@ NOKPROBE_SYMBOL(get_kprobe);
 static int aggr_pre_handler(struct kprobe *p, struct pt_regs *regs);
 
 /* Return true if 'p' is an aggregator */
-static inline int kprobe_aggrprobe(struct kprobe *p)
+static inline bool kprobe_aggrprobe(struct kprobe *p)
 {
 	return p->pre_handler = aggr_pre_handler;
 }
 
 /* Return true if 'p' is unused */
-static inline int kprobe_unused(struct kprobe *p)
+static inline bool kprobe_unused(struct kprobe *p)
 {
 	return kprobe_aggrprobe(p) && kprobe_disabled(p) &&
 	       list_empty(&p->list);
@@ -455,7 +455,7 @@ static inline int kprobe_optready(struct kprobe *p)
 }
 
 /* Return true if the kprobe is disarmed. Note: p must be on hash list */
-static inline int kprobe_disarmed(struct kprobe *p)
+static inline bool kprobe_disarmed(struct kprobe *p)
 {
 	struct optimized_kprobe *op;
 
@@ -469,16 +469,16 @@ static inline int kprobe_disarmed(struct kprobe *p)
 }
 
 /* Return true if the probe is queued on (un)optimizing lists */
-static int kprobe_queued(struct kprobe *p)
+static bool kprobe_queued(struct kprobe *p)
 {
 	struct optimized_kprobe *op;
 
 	if (kprobe_aggrprobe(p)) {
 		op = container_of(p, struct optimized_kprobe, kp);
 		if (!list_empty(&op->list))
-			return 1;
+			return true;
 	}
-	return 0;
+	return false;
 }
 
 /*
@@ -1678,7 +1678,7 @@ int register_kprobe(struct kprobe *p)
 EXPORT_SYMBOL_GPL(register_kprobe);
 
 /* Check if all probes on the 'ap' are disabled. */
-static int aggr_kprobe_disabled(struct kprobe *ap)
+static bool aggr_kprobe_disabled(struct kprobe *ap)
 {
 	struct kprobe *kp;
 
@@ -1690,9 +1690,9 @@ static int aggr_kprobe_disabled(struct kprobe *ap)
 			 * Since there is an active probe on the list,
 			 * we can't disable this 'ap'.
 			 */
-			return 0;
+			return false;
 
-	return 1;
+	return true;
 }
 
 static struct kprobe *__disable_kprobe(struct kprobe *p)
diff --git a/kernel/trace/trace_kprobe.c b/kernel/trace/trace_kprobe.c
index 3a64ba4bbad6..0e1e7ce5f7ed 100644
--- a/kernel/trace/trace_kprobe.c
+++ b/kernel/trace/trace_kprobe.c
@@ -97,7 +97,7 @@ static nokprobe_inline unsigned long trace_kprobe_offset(struct trace_kprobe *tk
 
 static nokprobe_inline bool trace_kprobe_has_gone(struct trace_kprobe *tk)
 {
-	return !!(kprobe_gone(&tk->rp.kp));
+	return kprobe_gone(&tk->rp.kp);
 }
 
 static nokprobe_inline bool trace_kprobe_within_module(struct trace_kprobe *tk,
