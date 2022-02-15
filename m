From: Christophe Leroy <christophe.leroy@csgroup.eu>
Date: Tue, 15 Feb 2022 12:41:02 +0000
Subject: [PATCH v4 07/13] asm-generic: Define CONFIG_HAVE_FUNCTION_DESCRIPTORS
Message-Id: <4a0f11fb0ea74a3197bc44dd7ba25e53a24fd03d.1644928018.git.christophe.leroy@csgroup.eu>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1644928018.git.christophe.leroy@csgroup.eu>
In-Reply-To: <cover.1644928018.git.christophe.leroy@csgroup.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, Arnd Bergmann <arnd@arndb.de>, Kees Cook <keescook@chromium.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Christophe Leroy <christophe.leroy@csgroup.eu>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Nicholas Piggin <npiggin@gmail.com>

Replace HAVE_DEREFERENCE_FUNCTION_DESCRIPTOR by a config option
named CONFIG_HAVE_FUNCTION_DESCRIPTORS and use it instead of
'dereference_function_descriptor' macro to know whether an
arch has function descriptors.

To limit churn in one of the following patches, use
an #ifdef/#else construct with empty first part
instead of an #ifndef in asm-generic/sections.h

On powerpc, make sure the config option matches the ABI used
by the compiler with a BUILD_BUG_ON() and add missing _CALL_ELF=2
when calling 'sparse' so that sparse sees the same piece of
code as GCC.

And include a helper to check whether an arch has function
descriptors or not : have_function_descriptors()

Reviewed-by: Kees Cook <keescook@chromium.org>
Reviewed-by: Nicholas Piggin <npiggin@gmail.com>
Signed-off-by: Christophe Leroy <christophe.leroy@csgroup.eu>
Acked-by: Helge Deller <deller@gmx.de>
---
 arch/Kconfig                        | 3 +++
 arch/ia64/Kconfig                   | 1 +
 arch/ia64/include/asm/sections.h    | 2 --
 arch/parisc/Kconfig                 | 1 +
 arch/parisc/include/asm/sections.h  | 2 --
 arch/powerpc/Kconfig                | 1 +
 arch/powerpc/include/asm/sections.h | 2 --
 arch/powerpc/kernel/ptrace/ptrace.c | 6 ++++++
 include/asm-generic/sections.h      | 8 +++++++-
 include/linux/kallsyms.h            | 2 +-
 10 files changed, 20 insertions(+), 8 deletions(-)

diff --git a/arch/Kconfig b/arch/Kconfig
index 678a80713b21..fe24174cb63c 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -205,6 +205,9 @@ config HAVE_FUNCTION_ERROR_INJECTION
 config HAVE_NMI
 	bool
 
+config HAVE_FUNCTION_DESCRIPTORS
+	bool
+
 config TRACE_IRQFLAGS_SUPPORT
 	bool
 
diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index a7e01573abd8..da85c3b23b16 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -35,6 +35,7 @@ config IA64
 	select HAVE_SETUP_PER_CPU_AREA
 	select TTY
 	select HAVE_ARCH_TRACEHOOK
+	select HAVE_FUNCTION_DESCRIPTORS
 	select HAVE_VIRT_CPU_ACCOUNTING
 	select HUGETLB_PAGE_SIZE_VARIABLE if HUGETLB_PAGE
 	select VIRT_TO_BUS
diff --git a/arch/ia64/include/asm/sections.h b/arch/ia64/include/asm/sections.h
index 35f24e52149a..2460d365a057 100644
--- a/arch/ia64/include/asm/sections.h
+++ b/arch/ia64/include/asm/sections.h
@@ -27,8 +27,6 @@ extern char __start_gate_brl_fsys_bubble_down_patchlist[], __end_gate_brl_fsys_b
 extern char __start_unwind[], __end_unwind[];
 extern char __start_ivt_text[], __end_ivt_text[];
 
-#define HAVE_DEREFERENCE_FUNCTION_DESCRIPTOR 1
-
 #undef dereference_function_descriptor
 static inline void *dereference_function_descriptor(void *ptr)
 {
diff --git a/arch/parisc/Kconfig b/arch/parisc/Kconfig
index 43c1c880def6..82e7ab1a9764 100644
--- a/arch/parisc/Kconfig
+++ b/arch/parisc/Kconfig
@@ -69,6 +69,7 @@ config PARISC
 	select HAVE_DYNAMIC_FTRACE_WITH_REGS
 	select HAVE_SOFTIRQ_ON_OWN_STACK if IRQSTACKS
 	select TRACE_IRQFLAGS_SUPPORT
+	select HAVE_FUNCTION_DESCRIPTORS if 64BIT
 
 	help
 	  The PA-RISC microprocessor is designed by Hewlett-Packard and used
diff --git a/arch/parisc/include/asm/sections.h b/arch/parisc/include/asm/sections.h
index bb52aea0cb21..c8092e4d94de 100644
--- a/arch/parisc/include/asm/sections.h
+++ b/arch/parisc/include/asm/sections.h
@@ -9,8 +9,6 @@ extern char __alt_instructions[], __alt_instructions_end[];
 
 #ifdef CONFIG_64BIT
 
-#define HAVE_DEREFERENCE_FUNCTION_DESCRIPTOR 1
-
 #undef dereference_function_descriptor
 void *dereference_function_descriptor(void *);
 
diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index 28e4047e99e8..23ce71367467 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -207,6 +207,7 @@ config PPC
 	select HAVE_EFFICIENT_UNALIGNED_ACCESS	if !(CPU_LITTLE_ENDIAN && POWER7_CPU)
 	select HAVE_FAST_GUP
 	select HAVE_FTRACE_MCOUNT_RECORD
+	select HAVE_FUNCTION_DESCRIPTORS	if PPC64 && !CPU_LITTLE_ENDIAN
 	select HAVE_FUNCTION_ERROR_INJECTION
 	select HAVE_FUNCTION_GRAPH_TRACER
 	select HAVE_FUNCTION_TRACER
diff --git a/arch/powerpc/include/asm/sections.h b/arch/powerpc/include/asm/sections.h
index baca39f4c6d3..7728a7a146c3 100644
--- a/arch/powerpc/include/asm/sections.h
+++ b/arch/powerpc/include/asm/sections.h
@@ -56,8 +56,6 @@ static inline int overlaps_kernel_text(unsigned long start, unsigned long end)
 
 #ifdef PPC64_ELF_ABI_v1
 
-#define HAVE_DEREFERENCE_FUNCTION_DESCRIPTOR 1
-
 #undef dereference_function_descriptor
 static inline void *dereference_function_descriptor(void *ptr)
 {
diff --git a/arch/powerpc/kernel/ptrace/ptrace.c b/arch/powerpc/kernel/ptrace/ptrace.c
index c43f77e2ac31..1212a812a7ab 100644
--- a/arch/powerpc/kernel/ptrace/ptrace.c
+++ b/arch/powerpc/kernel/ptrace/ptrace.c
@@ -445,4 +445,10 @@ void __init pt_regs_check(void)
 	 * real registers.
 	 */
 	BUILD_BUG_ON(PT_DSCR < sizeof(struct user_pt_regs) / sizeof(unsigned long));
+
+#ifdef PPC64_ELF_ABI_v1
+	BUILD_BUG_ON(!IS_ENABLED(CONFIG_HAVE_FUNCTION_DESCRIPTORS));
+#else
+	BUILD_BUG_ON(IS_ENABLED(CONFIG_HAVE_FUNCTION_DESCRIPTORS));
+#endif
 }
diff --git a/include/asm-generic/sections.h b/include/asm-generic/sections.h
index 690f741764e1..3ef83e1aebee 100644
--- a/include/asm-generic/sections.h
+++ b/include/asm-generic/sections.h
@@ -59,11 +59,17 @@ extern char __noinstr_text_start[], __noinstr_text_end[];
 extern __visible const void __nosave_begin, __nosave_end;
 
 /* Function descriptor handling (if any).  Override in asm/sections.h */
-#ifndef dereference_function_descriptor
+#ifdef CONFIG_HAVE_FUNCTION_DESCRIPTORS
+#else
 #define dereference_function_descriptor(p) ((void *)(p))
 #define dereference_kernel_function_descriptor(p) ((void *)(p))
 #endif
 
+static inline bool have_function_descriptors(void)
+{
+	return IS_ENABLED(CONFIG_HAVE_FUNCTION_DESCRIPTORS);
+}
+
 /**
  * memory_contains - checks if an object is contained within a memory region
  * @begin: virtual address of the beginning of the memory region
diff --git a/include/linux/kallsyms.h b/include/linux/kallsyms.h
index 4176c7eca7b5..ce1bd2fbf23e 100644
--- a/include/linux/kallsyms.h
+++ b/include/linux/kallsyms.h
@@ -48,7 +48,7 @@ static inline int is_ksym_addr(unsigned long addr)
 
 static inline void *dereference_symbol_descriptor(void *ptr)
 {
-#ifdef HAVE_DEREFERENCE_FUNCTION_DESCRIPTOR
+#ifdef CONFIG_HAVE_FUNCTION_DESCRIPTORS
 	struct module *mod;
 
 	ptr = dereference_kernel_function_descriptor(ptr);
-- 
2.34.1
