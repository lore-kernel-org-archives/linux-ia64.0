From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Date: Thu, 09 Nov 2017 23:48:26 +0000
Subject: [PATCHv4 2/6] ia64: Add .opd based function descriptor dereference
Message-Id: <20171109234830.5067-3-sergey.senozhatsky@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171109234830.5067-1-sergey.senozhatsky@gmail.com>
In-Reply-To: <20171109234830.5067-1-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Helge Deller <deller@gmx.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, James Bottomley <jejb@parisc-linux.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jessica Yu <jeyu@kernel.org>, Petr Mladek <pmladek@suse.com>, Steven Rostedt <rostedt@goodmis.org>, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

We are moving towards separate kernel and module function descriptor
dereference callbacks. This patch enables it for IA64.

For pointers that belong to the kernel
-  Added __start_opd and __end_opd pointers, to track the kernel
   .opd section address range;

-  Added dereference_kernel_function_descriptor(). Now we
   will dereference only function pointers that are within
   [__start_opd, __end_opd);

For pointers that belong to a module
-  Added dereference_module_function_descriptor() to handle module
   function descriptor dereference. Now we will dereference only
   pointers that are within [module->opd.start, module->opd.end).

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
---
 arch/ia64/include/asm/sections.h | 10 +++++++++-
 arch/ia64/kernel/module.c        | 12 ++++++++++++
 arch/ia64/kernel/vmlinux.lds.S   |  2 ++
 3 files changed, 23 insertions(+), 1 deletion(-)

diff --git a/arch/ia64/include/asm/sections.h b/arch/ia64/include/asm/sections.h
index f3481408594e..cea15f2dd38d 100644
--- a/arch/ia64/include/asm/sections.h
+++ b/arch/ia64/include/asm/sections.h
@@ -27,6 +27,8 @@ extern char __start_gate_brl_fsys_bubble_down_patchlist[], __end_gate_brl_fsys_b
 extern char __start_unwind[], __end_unwind[];
 extern char __start_ivt_text[], __end_ivt_text[];
 
+#define HAVE_DEREFERENCE_FUNCTION_DESCRIPTOR 1
+
 #undef dereference_function_descriptor
 static inline void *dereference_function_descriptor(void *ptr)
 {
@@ -38,6 +40,12 @@ static inline void *dereference_function_descriptor(void *ptr)
 	return ptr;
 }
 
+#undef dereference_kernel_function_descriptor
+static inline void *dereference_kernel_function_descriptor(void *ptr)
+{
+	if (ptr < (void *)__start_opd || ptr >= (void *)__end_opd)
+		return ptr;
+	return dereference_function_descriptor(ptr);
+}
 
 #endif /* _ASM_IA64_SECTIONS_H */
-
diff --git a/arch/ia64/kernel/module.c b/arch/ia64/kernel/module.c
index 853b5611a894..326448f9df16 100644
--- a/arch/ia64/kernel/module.c
+++ b/arch/ia64/kernel/module.c
@@ -36,6 +36,7 @@
 
 #include <asm/patch.h>
 #include <asm/unaligned.h>
+#include <asm/sections.h>
 
 #define ARCH_MODULE_DEBUG 0
 
@@ -918,3 +919,14 @@ module_arch_cleanup (struct module *mod)
 	if (mod->arch.core_unw_table)
 		unw_remove_unwind_table(mod->arch.core_unw_table);
 }
+
+void *dereference_module_function_descriptor(struct module *mod, void *ptr)
+{
+	Elf64_Shdr *opd = mod->arch.opd;
+
+	if (ptr < (void *)opd->sh_addr ||
+			ptr >= (void *)(opd->sh_addr + opd->sh_size))
+		return ptr;
+
+	return dereference_function_descriptor(ptr);
+}
diff --git a/arch/ia64/kernel/vmlinux.lds.S b/arch/ia64/kernel/vmlinux.lds.S
index 58db59da0bd8..31e688981b4b 100644
--- a/arch/ia64/kernel/vmlinux.lds.S
+++ b/arch/ia64/kernel/vmlinux.lds.S
@@ -108,7 +108,9 @@ SECTIONS {
 	RODATA
 
 	.opd : AT(ADDR(.opd) - LOAD_OFFSET) {
+		__start_opd = .;
 		*(.opd)
+		__end_opd = .;
 	}
 
 	/*
-- 
2.15.0

