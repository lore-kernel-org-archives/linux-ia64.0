From: Masami Hiramatsu <mhiramat@kernel.org>
Date: Fri, 18 Jun 2021 07:05:50 +0000
Subject: [PATCH -tip v8 03/13] kprobes: treewide: Remove trampoline_address from kretprobe_trampoline_handler
Message-Id: <162399994996.506599.17672270294950096639.stgit@devnote2>
List-Id: <linux-ia64.vger.kernel.org>
References: <162399992186.506599.8457763707951687195.stgit@devnote2>
In-Reply-To: <162399992186.506599.8457763707951687195.stgit@devnote2>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Steven Rostedt <rostedt@goodmis.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: X86 ML <x86@kernel.org>, Masami Hiramatsu <mhiramat@kernel.org>, Daniel Xu <dxu@dxuuu.xyz>, linux-kernel@vger.kernel.org, bpf@vger.kernel.org, kuba@kernel.org, mingo@redhat.com, ast@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@alien8.de>, Peter Zijlstra <peterz@infradead.org>, kernel-team@fb.com, yhs@fb.com, linux-ia64@vger.kernel.org, Abhishek Sagar <sagar.abhishek@gmail.com>, Andrii Nakryiko <andrii.nakryiko@gmail.com>

Remove trampoline_address from kretprobe_trampoline_handler().
Instead of passing the address, kretprobe_trampoline_handler()
can use new kretprobe_trampoline_addr().

Signed-off-by: Masami Hiramatsu <mhiramat@kernel.org>
Tested-by: Andrii Nakryik <andrii@kernel.org>
---
 Changes in v8:
   - Use dereference_kernel_function_descriptor() to
     get the kretprobe_trampoline address.
 Changes in v3:
   - Remove wrong kretprobe_trampoline declaration from
     arch/x86/include/asm/kprobes.h.
 Changes in v2:
   - Remove arch_deref_entry_point() from comment.
---
 arch/arc/kernel/kprobes.c          |    2 +-
 arch/arm/probes/kprobes/core.c     |    3 +--
 arch/arm64/kernel/probes/kprobes.c |    3 +--
 arch/csky/kernel/probes/kprobes.c  |    2 +-
 arch/ia64/kernel/kprobes.c         |    5 ++---
 arch/mips/kernel/kprobes.c         |    3 +--
 arch/parisc/kernel/kprobes.c       |    4 ++--
 arch/powerpc/kernel/kprobes.c      |    2 +-
 arch/riscv/kernel/probes/kprobes.c |    2 +-
 arch/s390/kernel/kprobes.c         |    2 +-
 arch/sh/kernel/kprobes.c           |    2 +-
 arch/sparc/kernel/kprobes.c        |    2 +-
 arch/x86/include/asm/kprobes.h     |    1 -
 arch/x86/kernel/kprobes/core.c     |    2 +-
 include/linux/kprobes.h            |   18 +++++++++++++-----
 kernel/kprobes.c                   |    3 +--
 16 files changed, 29 insertions(+), 27 deletions(-)

diff --git a/arch/arc/kernel/kprobes.c b/arch/arc/kernel/kprobes.c
index 5f0415fc7328..3cee75c87f97 100644
--- a/arch/arc/kernel/kprobes.c
+++ b/arch/arc/kernel/kprobes.c
@@ -381,7 +381,7 @@ void __kprobes arch_prepare_kretprobe(struct kretprobe_instance *ri,
 static int __kprobes trampoline_probe_handler(struct kprobe *p,
 					      struct pt_regs *regs)
 {
-	regs->ret = __kretprobe_trampoline_handler(regs, &kretprobe_trampoline, NULL);
+	regs->ret = __kretprobe_trampoline_handler(regs, NULL);
 
 	/* By returning a non zero value, we are telling the kprobe handler
 	 * that we don't want the post_handler to run
diff --git a/arch/arm/probes/kprobes/core.c b/arch/arm/probes/kprobes/core.c
index 27e0af78e88b..583f6b1a2a6f 100644
--- a/arch/arm/probes/kprobes/core.c
+++ b/arch/arm/probes/kprobes/core.c
@@ -390,8 +390,7 @@ void __naked __kprobes kretprobe_trampoline(void)
 /* Called from kretprobe_trampoline */
 static __used __kprobes void *trampoline_handler(struct pt_regs *regs)
 {
-	return (void *)kretprobe_trampoline_handler(regs, &kretprobe_trampoline,
-						    (void *)regs->ARM_fp);
+	return (void *)kretprobe_trampoline_handler(regs, (void *)regs->ARM_fp);
 }
 
 void __kprobes arch_prepare_kretprobe(struct kretprobe_instance *ri,
diff --git a/arch/arm64/kernel/probes/kprobes.c b/arch/arm64/kernel/probes/kprobes.c
index 004b86eff9c2..649c970e65a2 100644
--- a/arch/arm64/kernel/probes/kprobes.c
+++ b/arch/arm64/kernel/probes/kprobes.c
@@ -396,8 +396,7 @@ int __init arch_populate_kprobe_blacklist(void)
 
 void __kprobes __used *trampoline_probe_handler(struct pt_regs *regs)
 {
-	return (void *)kretprobe_trampoline_handler(regs, &kretprobe_trampoline,
-					(void *)kernel_stack_pointer(regs));
+	return (void *)kretprobe_trampoline_handler(regs, (void *)kernel_stack_pointer(regs));
 }
 
 void __kprobes arch_prepare_kretprobe(struct kretprobe_instance *ri,
diff --git a/arch/csky/kernel/probes/kprobes.c b/arch/csky/kernel/probes/kprobes.c
index 68b22b499aeb..cc9dde2e4341 100644
--- a/arch/csky/kernel/probes/kprobes.c
+++ b/arch/csky/kernel/probes/kprobes.c
@@ -387,7 +387,7 @@ int __init arch_populate_kprobe_blacklist(void)
 
 void __kprobes __used *trampoline_probe_handler(struct pt_regs *regs)
 {
-	return (void *)kretprobe_trampoline_handler(regs, &kretprobe_trampoline, NULL);
+	return (void *)kretprobe_trampoline_handler(regs, NULL);
 }
 
 void __kprobes arch_prepare_kretprobe(struct kretprobe_instance *ri,
diff --git a/arch/ia64/kernel/kprobes.c b/arch/ia64/kernel/kprobes.c
index 0f8573bbf520..44c84c20b626 100644
--- a/arch/ia64/kernel/kprobes.c
+++ b/arch/ia64/kernel/kprobes.c
@@ -392,14 +392,13 @@ static void __kprobes set_current_kprobe(struct kprobe *p,
 	__this_cpu_write(current_kprobe, p);
 }
 
-static void kretprobe_trampoline(void)
+void kretprobe_trampoline(void)
 {
 }
 
 int __kprobes trampoline_probe_handler(struct kprobe *p, struct pt_regs *regs)
 {
-	regs->cr_iip = __kretprobe_trampoline_handler(regs,
-		dereference_function_descriptor(kretprobe_trampoline), NULL);
+	regs->cr_iip = __kretprobe_trampoline_handler(regs, NULL);
 	/*
 	 * By returning a non-zero value, we are telling
 	 * kprobe_handler() that we don't want the post_handler
diff --git a/arch/mips/kernel/kprobes.c b/arch/mips/kernel/kprobes.c
index 75bff0f77319..21a4fda1e2cb 100644
--- a/arch/mips/kernel/kprobes.c
+++ b/arch/mips/kernel/kprobes.c
@@ -486,8 +486,7 @@ void __kprobes arch_prepare_kretprobe(struct kretprobe_instance *ri,
 static int __kprobes trampoline_probe_handler(struct kprobe *p,
 						struct pt_regs *regs)
 {
-	instruction_pointer(regs) = __kretprobe_trampoline_handler(regs,
-						kretprobe_trampoline, NULL);
+	instruction_pointer(regs) = __kretprobe_trampoline_handler(regs, NULL);
 	/*
 	 * By returning a non-zero value, we are telling
 	 * kprobe_handler() that we don't want the post_handler
diff --git a/arch/parisc/kernel/kprobes.c b/arch/parisc/kernel/kprobes.c
index 6d21a515eea5..4a35ac6e2ca2 100644
--- a/arch/parisc/kernel/kprobes.c
+++ b/arch/parisc/kernel/kprobes.c
@@ -175,7 +175,7 @@ int __kprobes parisc_kprobe_ss_handler(struct pt_regs *regs)
 	return 1;
 }
 
-static inline void kretprobe_trampoline(void)
+void kretprobe_trampoline(void)
 {
 	asm volatile("nop");
 	asm volatile("nop");
@@ -193,7 +193,7 @@ static int __kprobes trampoline_probe_handler(struct kprobe *p,
 {
 	unsigned long orig_ret_address;
 
-	orig_ret_address = __kretprobe_trampoline_handler(regs, trampoline_p.addr, NULL);
+	orig_ret_address = __kretprobe_trampoline_handler(regs, NULL);
 	instruction_pointer_set(regs, orig_ret_address);
 
 	return 1;
diff --git a/arch/powerpc/kernel/kprobes.c b/arch/powerpc/kernel/kprobes.c
index 24472f2c2cfc..025a9f83ae88 100644
--- a/arch/powerpc/kernel/kprobes.c
+++ b/arch/powerpc/kernel/kprobes.c
@@ -399,7 +399,7 @@ static int trampoline_probe_handler(struct kprobe *p, struct pt_regs *regs)
 {
 	unsigned long orig_ret_address;
 
-	orig_ret_address = __kretprobe_trampoline_handler(regs, &kretprobe_trampoline, NULL);
+	orig_ret_address = __kretprobe_trampoline_handler(regs, NULL);
 	/*
 	 * We get here through one of two paths:
 	 * 1. by taking a trap -> kprobe_handler() -> here
diff --git a/arch/riscv/kernel/probes/kprobes.c b/arch/riscv/kernel/probes/kprobes.c
index 247e33fa5bc7..07bc8804643e 100644
--- a/arch/riscv/kernel/probes/kprobes.c
+++ b/arch/riscv/kernel/probes/kprobes.c
@@ -370,7 +370,7 @@ int __init arch_populate_kprobe_blacklist(void)
 
 void __kprobes __used *trampoline_probe_handler(struct pt_regs *regs)
 {
-	return (void *)kretprobe_trampoline_handler(regs, &kretprobe_trampoline, NULL);
+	return (void *)kretprobe_trampoline_handler(regs, NULL);
 }
 
 void __kprobes arch_prepare_kretprobe(struct kretprobe_instance *ri,
diff --git a/arch/s390/kernel/kprobes.c b/arch/s390/kernel/kprobes.c
index 74b0bd2c24d4..1e6600765553 100644
--- a/arch/s390/kernel/kprobes.c
+++ b/arch/s390/kernel/kprobes.c
@@ -351,7 +351,7 @@ static void __used kretprobe_trampoline_holder(void)
  */
 static int trampoline_probe_handler(struct kprobe *p, struct pt_regs *regs)
 {
-	regs->psw.addr = __kretprobe_trampoline_handler(regs, &kretprobe_trampoline, NULL);
+	regs->psw.addr = __kretprobe_trampoline_handler(regs, NULL);
 	/*
 	 * By returning a non-zero value, we are telling
 	 * kprobe_handler() that we don't want the post_handler
diff --git a/arch/sh/kernel/kprobes.c b/arch/sh/kernel/kprobes.c
index 1c7f358ef0be..8e76a35e6e33 100644
--- a/arch/sh/kernel/kprobes.c
+++ b/arch/sh/kernel/kprobes.c
@@ -303,7 +303,7 @@ static void __used kretprobe_trampoline_holder(void)
  */
 int __kprobes trampoline_probe_handler(struct kprobe *p, struct pt_regs *regs)
 {
-	regs->pc = __kretprobe_trampoline_handler(regs, &kretprobe_trampoline, NULL);
+	regs->pc = __kretprobe_trampoline_handler(regs, NULL);
 
 	return 1;
 }
diff --git a/arch/sparc/kernel/kprobes.c b/arch/sparc/kernel/kprobes.c
index 4c05a4ee6a0e..401534236c2e 100644
--- a/arch/sparc/kernel/kprobes.c
+++ b/arch/sparc/kernel/kprobes.c
@@ -451,7 +451,7 @@ static int __kprobes trampoline_probe_handler(struct kprobe *p,
 {
 	unsigned long orig_ret_address = 0;
 
-	orig_ret_address = __kretprobe_trampoline_handler(regs, &kretprobe_trampoline, NULL);
+	orig_ret_address = __kretprobe_trampoline_handler(regs, NULL);
 	regs->tpc = orig_ret_address;
 	regs->tnpc = orig_ret_address + 4;
 
diff --git a/arch/x86/include/asm/kprobes.h b/arch/x86/include/asm/kprobes.h
index bd7f5886a789..71ea2eab43d5 100644
--- a/arch/x86/include/asm/kprobes.h
+++ b/arch/x86/include/asm/kprobes.h
@@ -49,7 +49,6 @@ extern __visible kprobe_opcode_t optprobe_template_end[];
 extern const int kretprobe_blacklist_size;
 
 void arch_remove_kprobe(struct kprobe *p);
-asmlinkage void kretprobe_trampoline(void);
 
 extern void arch_kprobe_override_function(struct pt_regs *regs);
 
diff --git a/arch/x86/kernel/kprobes/core.c b/arch/x86/kernel/kprobes/core.c
index c492ad3001ca..2dccb4347453 100644
--- a/arch/x86/kernel/kprobes/core.c
+++ b/arch/x86/kernel/kprobes/core.c
@@ -1070,7 +1070,7 @@ __used __visible void *trampoline_handler(struct pt_regs *regs)
 	regs->ip = (unsigned long)&kretprobe_trampoline;
 	regs->orig_ax = ~0UL;
 
-	return (void *)kretprobe_trampoline_handler(regs, &kretprobe_trampoline, &regs->sp);
+	return (void *)kretprobe_trampoline_handler(regs, &regs->sp);
 }
 NOKPROBE_SYMBOL(trampoline_handler);
 
diff --git a/include/linux/kprobes.h b/include/linux/kprobes.h
index 713c3a683011..5ce677819a25 100644
--- a/include/linux/kprobes.h
+++ b/include/linux/kprobes.h
@@ -197,15 +197,23 @@ extern void arch_prepare_kretprobe(struct kretprobe_instance *ri,
 				   struct pt_regs *regs);
 extern int arch_trampoline_kprobe(struct kprobe *p);
 
+void kretprobe_trampoline(void);
+/*
+ * Since some architecture uses structured function pointer,
+ * use dereference_function_descriptor() to get real function address.
+ */
+static nokprobe_inline void *kretprobe_trampoline_addr(void)
+{
+	return dereference_kernel_function_descriptor(kretprobe_trampoline);
+}
+
 /* If the trampoline handler called from a kprobe, use this version */
 unsigned long __kretprobe_trampoline_handler(struct pt_regs *regs,
-				void *trampoline_address,
-				void *frame_pointer);
+					     void *frame_pointer);
 
 static nokprobe_inline
 unsigned long kretprobe_trampoline_handler(struct pt_regs *regs,
-				void *trampoline_address,
-				void *frame_pointer)
+					   void *frame_pointer)
 {
 	unsigned long ret;
 	/*
@@ -214,7 +222,7 @@ unsigned long kretprobe_trampoline_handler(struct pt_regs *regs,
 	 * be running at this point.
 	 */
 	kprobe_busy_begin();
-	ret = __kretprobe_trampoline_handler(regs, trampoline_address, frame_pointer);
+	ret = __kretprobe_trampoline_handler(regs, frame_pointer);
 	kprobe_busy_end();
 
 	return ret;
diff --git a/kernel/kprobes.c b/kernel/kprobes.c
index f8fe9d077b41..ad7a8c81ab06 100644
--- a/kernel/kprobes.c
+++ b/kernel/kprobes.c
@@ -1841,7 +1841,6 @@ static struct notifier_block kprobe_exceptions_nb = {
 #ifdef CONFIG_KRETPROBES
 
 unsigned long __kretprobe_trampoline_handler(struct pt_regs *regs,
-					     void *trampoline_address,
 					     void *frame_pointer)
 {
 	kprobe_opcode_t *correct_ret_addr = NULL;
@@ -1856,7 +1855,7 @@ unsigned long __kretprobe_trampoline_handler(struct pt_regs *regs,
 
 		BUG_ON(ri->fp != frame_pointer);
 
-		if (ri->ret_addr != trampoline_address) {
+		if (ri->ret_addr != kretprobe_trampoline_addr()) {
 			correct_ret_addr = ri->ret_addr;
 			/*
 			 * This is the real return address. Any other
