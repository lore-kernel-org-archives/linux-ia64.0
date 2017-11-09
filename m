From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Date: Thu, 09 Nov 2017 23:48:28 +0000
Subject: [PATCHv4 4/6] parisc64: Add .opd based function descriptor dereference
Message-Id: <20171109234830.5067-5-sergey.senozhatsky@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171109234830.5067-1-sergey.senozhatsky@gmail.com>
In-Reply-To: <20171109234830.5067-1-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Helge Deller <deller@gmx.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, James Bottomley <jejb@parisc-linux.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jessica Yu <jeyu@kernel.org>, Petr Mladek <pmladek@suse.com>, Steven Rostedt <rostedt@goodmis.org>, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

We are moving towards separate kernel and module function descriptor
dereference callbacks. This patch enables it for parisc64.

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
Signed-off-by: Helge Deller <deller@gmx.de>
---
 arch/parisc/boot/compressed/vmlinux.lds.S |  2 ++
 arch/parisc/include/asm/sections.h        |  6 ++++++
 arch/parisc/kernel/module.c               | 16 ++++++++++++++++
 arch/parisc/kernel/process.c              |  9 +++++++++
 arch/parisc/kernel/vmlinux.lds.S          |  2 ++
 5 files changed, 35 insertions(+)

diff --git a/arch/parisc/boot/compressed/vmlinux.lds.S b/arch/parisc/boot/compressed/vmlinux.lds.S
index a4ce3314e78e..4ebd4e65524c 100644
--- a/arch/parisc/boot/compressed/vmlinux.lds.S
+++ b/arch/parisc/boot/compressed/vmlinux.lds.S
@@ -29,7 +29,9 @@ SECTIONS
 	. = ALIGN(16);
 	/* Linkage tables */
 	.opd : {
+		__start_opd = .;
 		*(.opd)
+		__end_opd = .;
 	} PROVIDE (__gp = .);
 	.plt : {
 		*(.plt)
diff --git a/arch/parisc/include/asm/sections.h b/arch/parisc/include/asm/sections.h
index accdf40aa5b7..5a40b51df80c 100644
--- a/arch/parisc/include/asm/sections.h
+++ b/arch/parisc/include/asm/sections.h
@@ -6,8 +6,14 @@
 #include <asm-generic/sections.h>
 
 #ifdef CONFIG_64BIT
+
+#define HAVE_DEREFERENCE_FUNCTION_DESCRIPTOR 1
+
 #undef dereference_function_descriptor
 void *dereference_function_descriptor(void *);
+
+#undef dereference_kernel_function_descriptor
+void *dereference_kernel_function_descriptor(void *);
 #endif
 
 #endif
diff --git a/arch/parisc/kernel/module.c b/arch/parisc/kernel/module.c
index f1a76935a314..b5b3cb00f1fb 100644
--- a/arch/parisc/kernel/module.c
+++ b/arch/parisc/kernel/module.c
@@ -66,6 +66,7 @@
 
 #include <asm/pgtable.h>
 #include <asm/unwind.h>
+#include <asm/sections.h>
 
 #if 0
 #define DEBUGP printk
@@ -954,3 +955,18 @@ void module_arch_cleanup(struct module *mod)
 {
 	deregister_unwind_table(mod);
 }
+
+#ifdef CONFIG_64BIT
+void *dereference_module_function_descriptor(struct module *mod, void *ptr)
+{
+	unsigned long start_opd = (Elf64_Addr)mod->core_layout.base +
+				   mod->arch.fdesc_offset;
+	unsigned long end_opd = start_opd +
+				mod->arch.fdesc_count * sizeof(Elf64_Fdesc);
+
+	if (ptr < (void *)start_opd || ptr >= (void *)end_opd)
+		return ptr;
+
+	return dereference_function_descriptor(ptr);
+}
+#endif
diff --git a/arch/parisc/kernel/process.c b/arch/parisc/kernel/process.c
index 30f92391a93e..6c4585103a91 100644
--- a/arch/parisc/kernel/process.c
+++ b/arch/parisc/kernel/process.c
@@ -276,6 +276,15 @@ void *dereference_function_descriptor(void *ptr)
 		ptr = p;
 	return ptr;
 }
+
+void *dereference_kernel_function_descriptor(void *ptr)
+{
+	if (ptr < (void *)__start_opd ||
+			ptr >= (void *)__end_opd)
+		return ptr;
+
+	return dereference_function_descriptor(ptr);
+}
 #endif
 
 static inline unsigned long brk_rnd(void)
diff --git a/arch/parisc/kernel/vmlinux.lds.S b/arch/parisc/kernel/vmlinux.lds.S
index 159a2ec0b4e0..da2e31190efa 100644
--- a/arch/parisc/kernel/vmlinux.lds.S
+++ b/arch/parisc/kernel/vmlinux.lds.S
@@ -100,7 +100,9 @@ SECTIONS
 	. = ALIGN(16);
 	/* Linkage tables */
 	.opd : {
+		__start_opd = .;
 		*(.opd)
+		__end_opd = .;
 	} PROVIDE (__gp = .);
 	.plt : {
 		*(.plt)
-- 
2.15.0

