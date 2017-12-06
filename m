From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Date: Wed, 06 Dec 2017 04:36:49 +0000
Subject: Re: [PATCHv4 5/6] symbol lookup: introduce dereference_symbol_descriptor()
Message-Id: <20171206043649.GB15885@jagdpanzerIV>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171109234830.5067-1-sergey.senozhatsky@gmail.com>
 <20171109234830.5067-6-sergey.senozhatsky@gmail.com>
In-Reply-To: <20171109234830.5067-6-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Helge Deller <deller@gmx.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, James Bottomley <jejb@parisc-linux.org>, Andrew Morton <akpm@linux-foundation.org>, Jessica Yu <jeyu@kernel.org>, Steven Rostedt <rostedt@goodmis.org>, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

Hello,

	so we got a number of build-error reports [somehow I
thought 0day has compile tested the patches already; well, I
was wrong] basically on congifs that have no KALLSYMS.


Petr, can we replace 0006 with the following patch?

8<--- --- ---

From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [PATCH] symbol lookup: introduce dereference_symbol_descriptor()

dereference_symbol_descriptor() invokes appropriate ARCH specific
function descriptor dereference callbacks:
- dereference_kernel_function_descriptor() if the pointer is a
  kernel symbol;

- dereference_module_function_descriptor() if the pointer is a
  module symbol.

This is the last step needed to make '%pS/%ps' smart enough to
handle function descriptor dereference on affected ARCHs and
to retire '%pF/%pf'.

To refresh it:
  Some architectures (ia64, ppc64, parisc64) use an indirect pointer
  for C function pointers - the function pointer points to a function
  descriptor and we need to dereference it to get the actual function
  pointer.

  Function descriptors live in .opd elf section and all affected
  ARCHs (ia64, ppc64, parisc64) handle it properly for kernel and
  modules. So we, technically, can decide if the dereference is
  needed by simply looking at the pointer: if it belongs to .opd
  section then we need to dereference it.

  The kernel and modules have their own .opd sections, obviously,
  that's why we need to split dereference_function_descriptor()
  and use separate kernel and module dereference arch callbacks.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
---
 Documentation/printk-formats.txt | 42 ++++++++++++-------------------
 include/linux/kallsyms.h         | 53 ++++++++++++++++++++++++++++++++++++++++
 kernel/kallsyms.c                | 33 -------------------------
 lib/vsprintf.c                   |  5 ++--
 4 files changed, 71 insertions(+), 62 deletions(-)

diff --git a/Documentation/printk-formats.txt b/Documentation/printk-formats.txt
index aa0a776c817a..02745028e909 100644
--- a/Documentation/printk-formats.txt
+++ b/Documentation/printk-formats.txt
@@ -61,41 +61,31 @@ Symbols/Function Pointers
 
 ::
 
-	%pF	versatile_init+0x0/0x110
-	%pf	versatile_init
-	%pS	versatile_init+0x0/0x110
-	%pSR	versatile_init+0x9/0x110
+	%pS     versatile_init+0x0/0x110
+	%ps     versatile_init
+	%pF     versatile_init+0x0/0x110
+	%pf     versatile_init
+	%pSR    versatile_init+0x9/0x110
 		(with __builtin_extract_return_addr() translation)
-	%ps	versatile_init
-	%pB	prev_fn_of_versatile_init+0x88/0x88
+	%pB     prev_fn_of_versatile_init+0x88/0x88
 
-The ``F`` and ``f`` specifiers are for printing function pointers,
-for example, f->func, &gettimeofday. They have the same result as
-``S`` and ``s`` specifiers. But they do an extra conversion on
-ia64, ppc64 and parisc64 architectures where the function pointers
-are actually function descriptors.
+The ``S`` and ``s`` specifiers are used for printing a pointer in symbolic
+format. They result in the symbol name with (``S``) or without (``s``)
+offsets. If KALLSYMS are disabled then the symbol address is printed instead.
 
-The ``S`` and ``s`` specifiers can be used for printing symbols
-from direct addresses, for example, __builtin_return_address(0),
-(void *)regs->ip. They result in the symbol name with (``S``) or
-without (``s``) offsets. If KALLSYMS are disabled then the symbol
-address is printed instead.
+Note, that the ``F`` and ``f`` specifiers are identical to ``S`` (``s``)
+and thus deprecated. We have ``F`` and ``f`` because on ia64, ppc64 and
+parisc64 function pointers are indirect and, in fact, are function
+descriptors, which require additional dereferencing before we can lookup
+the symbol. As of now, ``S`` and ``s`` perform dereferencing on those
+platforms (when needed), so ``F`` and ``f`` exist for compatibility
+reasons only.
 
 The ``B`` specifier results in the symbol name with offsets and should be
 used when printing stack backtraces. The specifier takes into
 consideration the effect of compiler optimisations which may occur
 when tail-call``s are used and marked with the noreturn GCC attribute.
 
-Examples::
-
-	printk("Going to call: %pF\n", gettimeofday);
-	printk("Going to call: %pF\n", p->func);
-	printk("%s: called from %pS\n", __func__, (void *)_RET_IP_);
-	printk("%s: called from %pS\n", __func__,
-				(void *)__builtin_return_address(0));
-	printk("Faulted at %pS\n", (void *)regs->ip);
-	printk(" %s%pB\n", (reliable ? "" : "? "), (void *)*stack);
-
 Kernel Pointers
 ======= 
diff --git a/include/linux/kallsyms.h b/include/linux/kallsyms.h
index bd118a6c60cb..1bcfe221e62c 100644
--- a/include/linux/kallsyms.h
+++ b/include/linux/kallsyms.h
@@ -9,6 +9,9 @@
 #include <linux/errno.h>
 #include <linux/kernel.h>
 #include <linux/stddef.h>
+#include <linux/mm.h>
+
+#include <asm/sections.h>
 
 #define KSYM_NAME_LEN 128
 #define KSYM_SYMBOL_LEN (sizeof("%s+%#lx/%#lx [%s]") + (KSYM_NAME_LEN - 1) + \
@@ -16,6 +19,56 @@
 
 struct module;
 
+static inline int is_kernel_inittext(unsigned long addr)
+{
+	if (addr >= (unsigned long)_sinittext
+	    && addr <= (unsigned long)_einittext)
+		return 1;
+	return 0;
+}
+
+static inline int is_kernel_text(unsigned long addr)
+{
+	if ((addr >= (unsigned long)_stext && addr <= (unsigned long)_etext) ||
+	    arch_is_kernel_text(addr))
+		return 1;
+	return in_gate_area_no_mm(addr);
+}
+
+static inline int is_kernel(unsigned long addr)
+{
+	if (addr >= (unsigned long)_stext && addr <= (unsigned long)_end)
+		return 1;
+	return in_gate_area_no_mm(addr);
+}
+
+static inline int is_ksym_addr(unsigned long addr)
+{
+	if (IS_ENABLED(CONFIG_KALLSYMS_ALL))
+		return is_kernel(addr);
+
+	return is_kernel_text(addr) || is_kernel_inittext(addr);
+}
+
+static inline void *dereference_symbol_descriptor(void *ptr)
+{
+#ifdef HAVE_DEREFERENCE_FUNCTION_DESCRIPTOR
+	struct module *mod;
+
+	ptr = dereference_kernel_function_descriptor(ptr);
+	if (is_ksym_addr((unsigned long)ptr))
+		return ptr;
+
+	preempt_disable();
+	mod = __module_address((unsigned long)ptr);
+	preempt_enable();
+
+	if (mod)
+		ptr = dereference_module_function_descriptor(mod, ptr);
+#endif
+	return ptr;
+}
+
 #ifdef CONFIG_KALLSYMS
 /* Lookup the address for a symbol. Returns 0 if not found. */
 unsigned long kallsyms_lookup_name(const char *name);
diff --git a/kernel/kallsyms.c b/kernel/kallsyms.c
index d5fa4116688a..4a79598e92c7 100644
--- a/kernel/kallsyms.c
+++ b/kernel/kallsyms.c
@@ -27,8 +27,6 @@
 #include <linux/ftrace.h>
 #include <linux/compiler.h>
 
-#include <asm/sections.h>
-
 /*
  * These will be re-linked against their real values
  * during the second link stage.
@@ -52,37 +50,6 @@ extern const u16 kallsyms_token_index[] __weak;
 
 extern const unsigned long kallsyms_markers[] __weak;
 
-static inline int is_kernel_inittext(unsigned long addr)
-{
-	if (addr >= (unsigned long)_sinittext
-	    && addr <= (unsigned long)_einittext)
-		return 1;
-	return 0;
-}
-
-static inline int is_kernel_text(unsigned long addr)
-{
-	if ((addr >= (unsigned long)_stext && addr <= (unsigned long)_etext) ||
-	    arch_is_kernel_text(addr))
-		return 1;
-	return in_gate_area_no_mm(addr);
-}
-
-static inline int is_kernel(unsigned long addr)
-{
-	if (addr >= (unsigned long)_stext && addr <= (unsigned long)_end)
-		return 1;
-	return in_gate_area_no_mm(addr);
-}
-
-static int is_ksym_addr(unsigned long addr)
-{
-	if (IS_ENABLED(CONFIG_KALLSYMS_ALL))
-		return is_kernel(addr);
-
-	return is_kernel_text(addr) || is_kernel_inittext(addr);
-}
-
 /*
  * Expand a compressed symbol data into the resulting uncompressed string,
  * if uncompressed string is too long (>= maxlen), it will be truncated,
diff --git a/lib/vsprintf.c b/lib/vsprintf.c
index 01c3957b2de6..03950269f35d 100644
--- a/lib/vsprintf.c
+++ b/lib/vsprintf.c
@@ -42,7 +42,6 @@
 #include "../mm/internal.h"	/* For the trace_print_flags arrays */
 
 #include <asm/page.h>		/* for PAGE_SIZE */
-#include <asm/sections.h>	/* for dereference_function_descriptor() */
 #include <asm/byteorder.h>	/* cpu_to_le16 */
 
 #include <linux/string_helpers.h>
@@ -1862,10 +1861,10 @@ char *pointer(const char *fmt, char *buf, char *end, void *ptr,
 	switch (*fmt) {
 	case 'F':
 	case 'f':
-		ptr = dereference_function_descriptor(ptr);
-		/* Fallthrough */
 	case 'S':
 	case 's':
+		ptr = dereference_symbol_descriptor(ptr);
+		/* Fallthrough */
 	case 'B':
 		return symbol_string(buf, end, ptr, spec, fmt);
 	case 'R':
-- 
2.15.1

