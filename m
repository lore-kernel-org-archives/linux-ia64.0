From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Date: Sat, 16 Sep 2017 03:53:44 +0000
Subject: [PATCH 2/5] ia64: Add .opd based function descriptor dereference
Message-Id: <20170916035347.19705-3-sergey.senozhatsky@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170916035347.19705-1-sergey.senozhatsky@gmail.com>
In-Reply-To: <20170916035347.19705-1-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, "James E . J . Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>
Cc: Petr Mladek <pmladek@suse.com>, Steven Rostedt <rostedt@goodmis.org>, Andrew Morton <akpm@linux-foundation.org>, Jessica Yu <jeyu@kernel.org>, Alexei Starovoitov <ast@kernel.org>, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

We are moving towards separate kernel and module function descriptor
dereference callbacks. This patch enables it for IA64.

For pointers that belong to the kernel
-  Added __start_opd and __end_opd pointers, to track the kernel
   .opd section address range;

-  Added dereference_kernel_function_descriptor(). Now we
   will dereference only function pointers that are within
   [__start_opd, __end_opd];

For pointers that belong to a module
-  Added dereference_module_function_descriptor() to handle module
   function descriptor dereference. Now we will dereference only
   pointers that are within [module->opd.start, module->opd.end].

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
---
 arch/ia64/include/asm/sections.h | 14 +++++++++++++-
 arch/ia64/kernel/module.c        | 13 +++++++++++++
 arch/ia64/kernel/vmlinux.lds.S   |  2 ++
 3 files changed, 28 insertions(+), 1 deletion(-)

diff --git a/arch/ia64/include/asm/sections.h b/arch/ia64/include/asm/sections.h
index 2ab2003698ef..bff3f3535609 100644
--- a/arch/ia64/include/asm/sections.h
+++ b/arch/ia64/include/asm/sections.h
@@ -25,8 +25,11 @@ extern char __start_gate_fsyscall_patchlist[], __end_gate_fsyscall_patchlist[];
 extern char __start_gate_brl_fsys_bubble_down_patchlist[], __end_gate_brl_fsys_bubble_down_patchlist[];
 extern char __start_unwind[], __end_unwind[];
 extern char __start_ivt_text[], __end_ivt_text[];
+extern char __start_opd[], __end_opd[];
 
 #undef dereference_function_descriptor
+#undef dereference_kernel_function_descriptor
+
 static inline void *dereference_function_descriptor(void *ptr)
 {
 	struct fdesc *desc = ptr;
@@ -37,6 +40,15 @@ static inline void *dereference_function_descriptor(void *ptr)
 	return ptr;
 }
 
+static inline void *dereference_kernel_function_descriptor(void *ptr)
+{
+	/*
+	 * Check if the ptr is a function descriptor and thus needs to
+	 * be dereferenced.
+	 */
+	if (ptr < (void *)__start_opd || (void *)__end_opd < ptr)
+		return ptr;
+	return dereference_function_descriptor(ptr);
+}
 
 #endif /* _ASM_IA64_SECTIONS_H */
-
diff --git a/arch/ia64/kernel/module.c b/arch/ia64/kernel/module.c
index d1d945c6bd05..d42f1e19d75d 100644
--- a/arch/ia64/kernel/module.c
+++ b/arch/ia64/kernel/module.c
@@ -35,6 +35,7 @@
 
 #include <asm/patch.h>
 #include <asm/unaligned.h>
+#include <asm/sections.h>
 
 #define ARCH_MODULE_DEBUG 0
 
@@ -917,3 +918,15 @@ module_arch_cleanup (struct module *mod)
 	if (mod->arch.core_unw_table)
 		unw_remove_unwind_table(mod->arch.core_unw_table);
 }
+
+unsigned long dereference_module_function_descriptor(struct module *mod,
+					     unsigned long addr)
+{
+	Elf64_Shdr *opd = mod->arch.opd;
+
+	if (addr < opd->sh_addr ||
+			(opd->sh_addr + opd->sh_size) < addr)
+		return addr;
+
+	return dereference_function_descriptor(addr);
+}
diff --git a/arch/ia64/kernel/vmlinux.lds.S b/arch/ia64/kernel/vmlinux.lds.S
index 798026dde52e..f872ba5ff82a 100644
--- a/arch/ia64/kernel/vmlinux.lds.S
+++ b/arch/ia64/kernel/vmlinux.lds.S
@@ -107,7 +107,9 @@ SECTIONS {
 	RODATA
 
 	.opd : AT(ADDR(.opd) - LOAD_OFFSET) {
+		__start_opd = .;
 		*(.opd)
+		__end_opd = .;
 	}
 
 	/*
-- 
2.14.1

