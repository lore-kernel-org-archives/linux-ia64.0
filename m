From: Josh Poimboeuf <jpoimboe@kernel.org>
Date: Tue, 14 Feb 2023 07:05:57 +0000
Subject: [PATCH v2 23/24] init: Make arch_call_rest_init() and rest_init() __noreturn
Message-Id: <8e901950d98b940972920578654ce186b714e74b.1676358308.git.jpoimboe@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1676358308.git.jpoimboe@kernel.org>
In-Reply-To: <cover.1676358308.git.jpoimboe@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: jgross@suse.com, richard.henderson@linaro.org, ink@jurassic.park.msu.ru, mattst88@gmail.com, linux-alpha@vger.kernel.org, linux@armlinux.org.uk, linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, will@kernel.org, guoren@kernel.org, linux-csky@vger.kernel.org, linux-ia64@vger.kernel.org, chenhuacai@kernel.org, kernel@xen0n.name, loongarch@lists.linux.dev, f.fainelli@gmail.com, bcm-kernel-feedback-list@broadcom.com, tsbogend@alpha.franken.de, linux-mips@vger.kernel.org, jiaxun.yang@flygoat.com, mpe@ellerman.id.au, npiggin@gmail.com, christophe.leroy@csgroup.eu, linuxppc-dev@lists.ozlabs.org, ysato@users.sourceforge.jp, dalias@libc.org, linux-sh@vger.kernel.org, davem@davemloft.net, sparclinux@vger.kernel.org, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, dave.hansen@linux.intel.com, x86@kernel.org, hpa@zytor.com, chris@zankel.net, jcmvbkbc@gmail.com, linux-xtensa@linux-xtensa.org, peterz@infradead.org, juri.lelli@redhat.com, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, rostedt@goodmis.org, bsegall@google.com, mgorman@suse.de, bristot@redhat.com, vschneid@redhat.com, paulmck@kernel.org

arch_call_rest_init() and rest_init() don't return.  Annotate them as
such.

Fixes the following warning:

  init/main.o: warning: objtool: start_kernel+0x4ad: unreachable instruction

Signed-off-by: Josh Poimboeuf <jpoimboe@kernel.org>
---
 arch/s390/kernel/setup.c     | 2 +-
 include/linux/start_kernel.h | 4 ++--
 init/main.c                  | 4 ++--
 tools/objtool/check.c        | 2 ++
 4 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/arch/s390/kernel/setup.c b/arch/s390/kernel/setup.c
index 696c9e007a36..85abff362f29 100644
--- a/arch/s390/kernel/setup.c
+++ b/arch/s390/kernel/setup.c
@@ -393,7 +393,7 @@ int __init arch_early_irq_init(void)
 	return 0;
 }
 
-void __init arch_call_rest_init(void)
+void __init __noreturn arch_call_rest_init(void)
 {
 	unsigned long stack;
 
diff --git a/include/linux/start_kernel.h b/include/linux/start_kernel.h
index 8b369a41c03c..864921e54c92 100644
--- a/include/linux/start_kernel.h
+++ b/include/linux/start_kernel.h
@@ -9,7 +9,7 @@
    up something else. */
 
 extern asmlinkage void __init start_kernel(void);
-extern void __init arch_call_rest_init(void);
-extern void __ref rest_init(void);
+extern void __init __noreturn arch_call_rest_init(void);
+extern void __ref __noreturn rest_init(void);
 
 #endif /* _LINUX_START_KERNEL_H */
diff --git a/init/main.c b/init/main.c
index e1c3911d7c70..ef71a9902e47 100644
--- a/init/main.c
+++ b/init/main.c
@@ -683,7 +683,7 @@ static void __init setup_command_line(char *command_line)
 
 static __initdata DECLARE_COMPLETION(kthreadd_done);
 
-noinline void __ref rest_init(void)
+noinline void __ref __noreturn rest_init(void)
 {
 	struct task_struct *tsk;
 	int pid;
@@ -889,7 +889,7 @@ static int __init early_randomize_kstack_offset(char *buf)
 early_param("randomize_kstack_offset", early_randomize_kstack_offset);
 #endif
 
-void __init __weak arch_call_rest_init(void)
+void __init __weak __noreturn arch_call_rest_init(void)
 {
 	rest_init();
 }
diff --git a/tools/objtool/check.c b/tools/objtool/check.c
index 0a1cf867d9b2..f79baae3e338 100644
--- a/tools/objtool/check.c
+++ b/tools/objtool/check.c
@@ -167,6 +167,7 @@ static bool __dead_end_function(struct objtool_file *file, struct symbol *func,
 		"__reiserfs_panic",
 		"__stack_chk_fail",
 		"__ubsan_handle_builtin_unreachable",
+		"arch_call_rest_init",
 		"cpu_bringup_and_idle",
 		"cpu_startup_entry",
 		"do_exit",
@@ -181,6 +182,7 @@ static bool __dead_end_function(struct objtool_file *file, struct symbol *func,
 		"machine_real_restart",
 		"make_task_dead",
 		"panic",
+		"rest_init",
 		"rewind_stack_and_make_dead",
 		"sev_es_terminate",
 		"snp_abort",
-- 
2.39.1
