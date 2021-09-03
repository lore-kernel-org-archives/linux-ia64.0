From: Weizhao Ouyang <o451686892@gmail.com>
Date: Fri, 03 Sep 2021 07:18:17 +0000
Subject: [PATCH] ftrace: Cleanup ftrace_dyn_arch_init()
Message-Id: <20210903071817.1162938-1-o451686892@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: rostedt@goodmis.org, mingo@redhat.com
Cc: linux@armlinux.org.uk, catalin.marinas@arm.com, will@kernel.org, guoren@kernel.org, monstr@monstr.eu, tsbogend@alpha.franken.de, nickhu@andestech.com, green.hu@gmail.com, deanbo422@gmail.com, James.Bottomley@HansenPartnership.com, deller@gmx.de, mpe@ellerman.id.au, benh@kernel.crashing.org, paulus@samba.org, paul.walmsley@sifive.com, palmer@dabbelt.com, aou@eecs.berkeley.edu, hca@linux.ibm.com, gor@linux.ibm.com, borntraeger@de.ibm.com, ysato@users.sourceforge.jp, dalias@libc.org, davem@davemloft.net, tglx@linutronix.de, bp@alien8.de, x86@kernel.org, hpa@zytor.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-csky@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, Weizhao Ouyang <o451686892@gmail.com>

Most ARCHs use empty ftrace_dyn_arch_init(), introduce a weak common
ftrace_dyn_arch_init() to cleanup them.

Signed-off-by: Weizhao Ouyang <o451686892@gmail.com>
---
 arch/arm/kernel/ftrace.c          | 5 -----
 arch/arm64/kernel/ftrace.c        | 5 -----
 arch/csky/kernel/ftrace.c         | 5 -----
 arch/ia64/kernel/ftrace.c         | 6 ------
 arch/microblaze/kernel/ftrace.c   | 5 -----
 arch/mips/include/asm/ftrace.h    | 2 ++
 arch/nds32/kernel/ftrace.c        | 5 -----
 arch/parisc/kernel/ftrace.c       | 5 -----
 arch/powerpc/include/asm/ftrace.h | 4 ++++
 arch/riscv/kernel/ftrace.c        | 5 -----
 arch/s390/kernel/ftrace.c         | 5 -----
 arch/sh/kernel/ftrace.c           | 5 -----
 arch/sparc/kernel/ftrace.c        | 5 -----
 arch/x86/kernel/ftrace.c          | 5 -----
 include/linux/ftrace.h            | 1 -
 kernel/trace/ftrace.c             | 5 +++++
 16 files changed, 11 insertions(+), 62 deletions(-)

diff --git a/arch/arm/kernel/ftrace.c b/arch/arm/kernel/ftrace.c
index 3c83b5d29697..a006585e1c09 100644
--- a/arch/arm/kernel/ftrace.c
+++ b/arch/arm/kernel/ftrace.c
@@ -193,11 +193,6 @@ int ftrace_make_nop(struct module *mod,
 
 	return ret;
 }
-
-int __init ftrace_dyn_arch_init(void)
-{
-	return 0;
-}
 #endif /* CONFIG_DYNAMIC_FTRACE */
 
 #ifdef CONFIG_FUNCTION_GRAPH_TRACER
diff --git a/arch/arm64/kernel/ftrace.c b/arch/arm64/kernel/ftrace.c
index 7f467bd9db7a..fc62dfe73f93 100644
--- a/arch/arm64/kernel/ftrace.c
+++ b/arch/arm64/kernel/ftrace.c
@@ -236,11 +236,6 @@ void arch_ftrace_update_code(int command)
 	command |= FTRACE_MAY_SLEEP;
 	ftrace_modify_all_code(command);
 }
-
-int __init ftrace_dyn_arch_init(void)
-{
-	return 0;
-}
 #endif /* CONFIG_DYNAMIC_FTRACE */
 
 #ifdef CONFIG_FUNCTION_GRAPH_TRACER
diff --git a/arch/csky/kernel/ftrace.c b/arch/csky/kernel/ftrace.c
index b4a7ec1517ff..50bfcf129078 100644
--- a/arch/csky/kernel/ftrace.c
+++ b/arch/csky/kernel/ftrace.c
@@ -133,11 +133,6 @@ int ftrace_update_ftrace_func(ftrace_func_t func)
 				(unsigned long)func, true, true);
 	return ret;
 }
-
-int __init ftrace_dyn_arch_init(void)
-{
-	return 0;
-}
 #endif /* CONFIG_DYNAMIC_FTRACE */
 
 #ifdef CONFIG_DYNAMIC_FTRACE_WITH_REGS
diff --git a/arch/ia64/kernel/ftrace.c b/arch/ia64/kernel/ftrace.c
index b2ab2d58fb30..d6360fd404ab 100644
--- a/arch/ia64/kernel/ftrace.c
+++ b/arch/ia64/kernel/ftrace.c
@@ -194,9 +194,3 @@ int ftrace_update_ftrace_func(ftrace_func_t func)
 	flush_icache_range(addr, addr + 16);
 	return 0;
 }
-
-/* run from kstop_machine */
-int __init ftrace_dyn_arch_init(void)
-{
-	return 0;
-}
diff --git a/arch/microblaze/kernel/ftrace.c b/arch/microblaze/kernel/ftrace.c
index 224eea40e1ee..188749d62709 100644
--- a/arch/microblaze/kernel/ftrace.c
+++ b/arch/microblaze/kernel/ftrace.c
@@ -163,11 +163,6 @@ int ftrace_make_call(struct dyn_ftrace *rec, unsigned long addr)
 	return ret;
 }
 
-int __init ftrace_dyn_arch_init(void)
-{
-	return 0;
-}
-
 int ftrace_update_ftrace_func(ftrace_func_t func)
 {
 	unsigned long ip = (unsigned long)(&ftrace_call);
diff --git a/arch/mips/include/asm/ftrace.h b/arch/mips/include/asm/ftrace.h
index b463f2aa5a61..ed013e767390 100644
--- a/arch/mips/include/asm/ftrace.h
+++ b/arch/mips/include/asm/ftrace.h
@@ -76,6 +76,8 @@ do {						\
 
 
 #ifdef CONFIG_DYNAMIC_FTRACE
+int __init ftrace_dyn_arch_init(void);
+
 static inline unsigned long ftrace_call_adjust(unsigned long addr)
 {
 	return addr;
diff --git a/arch/nds32/kernel/ftrace.c b/arch/nds32/kernel/ftrace.c
index 0e23e3a8df6b..f0ef4842d191 100644
--- a/arch/nds32/kernel/ftrace.c
+++ b/arch/nds32/kernel/ftrace.c
@@ -84,11 +84,6 @@ void _ftrace_caller(unsigned long parent_ip)
 	/* restore all state needed by the compiler epilogue */
 }
 
-int __init ftrace_dyn_arch_init(void)
-{
-	return 0;
-}
-
 static unsigned long gen_sethi_insn(unsigned long addr)
 {
 	unsigned long opcode = 0x46000000;
diff --git a/arch/parisc/kernel/ftrace.c b/arch/parisc/kernel/ftrace.c
index 0a1e75af5382..01581f715737 100644
--- a/arch/parisc/kernel/ftrace.c
+++ b/arch/parisc/kernel/ftrace.c
@@ -94,11 +94,6 @@ int ftrace_disable_ftrace_graph_caller(void)
 #endif
 
 #ifdef CONFIG_DYNAMIC_FTRACE
-
-int __init ftrace_dyn_arch_init(void)
-{
-	return 0;
-}
 int ftrace_update_ftrace_func(ftrace_func_t func)
 {
 	return 0;
diff --git a/arch/powerpc/include/asm/ftrace.h b/arch/powerpc/include/asm/ftrace.h
index debe8c4f7062..4db83cf4283f 100644
--- a/arch/powerpc/include/asm/ftrace.h
+++ b/arch/powerpc/include/asm/ftrace.h
@@ -61,6 +61,10 @@ struct dyn_arch_ftrace {
 };
 #endif /* __ASSEMBLY__ */
 
+#ifdef CONFIG_DYNAMIC_FTRACE_WITH_REGS
+int __init ftrace_dyn_arch_init(void);
+#endif
+
 #ifdef CONFIG_DYNAMIC_FTRACE_WITH_REGS
 #define ARCH_SUPPORTS_FTRACE_OPS 1
 #endif
diff --git a/arch/riscv/kernel/ftrace.c b/arch/riscv/kernel/ftrace.c
index 7f1e5203de88..4716f4cdc038 100644
--- a/arch/riscv/kernel/ftrace.c
+++ b/arch/riscv/kernel/ftrace.c
@@ -154,11 +154,6 @@ int ftrace_update_ftrace_func(ftrace_func_t func)
 
 	return ret;
 }
-
-int __init ftrace_dyn_arch_init(void)
-{
-	return 0;
-}
 #endif
 
 #ifdef CONFIG_DYNAMIC_FTRACE_WITH_REGS
diff --git a/arch/s390/kernel/ftrace.c b/arch/s390/kernel/ftrace.c
index 0a464d328467..3fd80397ff52 100644
--- a/arch/s390/kernel/ftrace.c
+++ b/arch/s390/kernel/ftrace.c
@@ -262,11 +262,6 @@ int ftrace_update_ftrace_func(ftrace_func_t func)
 	return 0;
 }
 
-int __init ftrace_dyn_arch_init(void)
-{
-	return 0;
-}
-
 void arch_ftrace_update_code(int command)
 {
 	if (ftrace_shared_hotpatch_trampoline(NULL))
diff --git a/arch/sh/kernel/ftrace.c b/arch/sh/kernel/ftrace.c
index 295c43315bbe..930001bb8c6a 100644
--- a/arch/sh/kernel/ftrace.c
+++ b/arch/sh/kernel/ftrace.c
@@ -252,11 +252,6 @@ int ftrace_make_call(struct dyn_ftrace *rec, unsigned long addr)
 
 	return ftrace_modify_code(rec->ip, old, new);
 }
-
-int __init ftrace_dyn_arch_init(void)
-{
-	return 0;
-}
 #endif /* CONFIG_DYNAMIC_FTRACE */
 
 #ifdef CONFIG_FUNCTION_GRAPH_TRACER
diff --git a/arch/sparc/kernel/ftrace.c b/arch/sparc/kernel/ftrace.c
index 684b84ce397f..eaead3da8e03 100644
--- a/arch/sparc/kernel/ftrace.c
+++ b/arch/sparc/kernel/ftrace.c
@@ -82,11 +82,6 @@ int ftrace_update_ftrace_func(ftrace_func_t func)
 	new = ftrace_call_replace(ip, (unsigned long)func);
 	return ftrace_modify_code(ip, old, new);
 }
-
-int __init ftrace_dyn_arch_init(void)
-{
-	return 0;
-}
 #endif
 
 #ifdef CONFIG_FUNCTION_GRAPH_TRACER
diff --git a/arch/x86/kernel/ftrace.c b/arch/x86/kernel/ftrace.c
index 1b3ce3b4a2a2..23d221a9a3cd 100644
--- a/arch/x86/kernel/ftrace.c
+++ b/arch/x86/kernel/ftrace.c
@@ -252,11 +252,6 @@ void arch_ftrace_update_code(int command)
 	ftrace_modify_all_code(command);
 }
 
-int __init ftrace_dyn_arch_init(void)
-{
-	return 0;
-}
-
 /* Currently only x86_64 supports dynamic trampolines */
 #ifdef CONFIG_X86_64
 
diff --git a/include/linux/ftrace.h b/include/linux/ftrace.h
index 832e65f06754..f1eca123d89d 100644
--- a/include/linux/ftrace.h
+++ b/include/linux/ftrace.h
@@ -573,7 +573,6 @@ ftrace_set_early_filter(struct ftrace_ops *ops, char *buf, int enable);
 
 /* defined in arch */
 extern int ftrace_ip_converted(unsigned long ip);
-extern int ftrace_dyn_arch_init(void);
 extern void ftrace_replace_code(int enable);
 extern int ftrace_update_ftrace_func(ftrace_func_t func);
 extern void ftrace_caller(void);
diff --git a/kernel/trace/ftrace.c b/kernel/trace/ftrace.c
index 7efbc8aaf7f6..4c090323198d 100644
--- a/kernel/trace/ftrace.c
+++ b/kernel/trace/ftrace.c
@@ -6846,6 +6846,11 @@ void __init ftrace_free_init_mem(void)
 	ftrace_free_mem(NULL, start, end);
 }
 
+int __init __weak ftrace_dyn_arch_init(void)
+{
+	return 0;
+}
+
 void __init ftrace_init(void)
 {
 	extern unsigned long __start_mcount_loc[];
-- 
2.30.2
