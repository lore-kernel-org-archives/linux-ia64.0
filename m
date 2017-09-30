From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Date: Sat, 30 Sep 2017 02:53:17 +0000
Subject: [PATCHv3 5/7] parisc64: Add .opd based function descriptor dereference
Message-Id: <20170930025319.987-6-sergey.senozhatsky@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170930025319.987-1-sergey.senozhatsky@gmail.com>
In-Reply-To: <20170930025319.987-1-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Petr Mladek <pmladek@suse.com>, Steven Rostedt <rostedt@goodmis.org>
Cc: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, James Bottomley <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Andrew Morton <akpm@linux-foundation.org>, Jessica Yu <jeyu@kernel.org>, Alexei Starovoitov <ast@kernel.org>, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

We are moving towards separate kernel and module function descriptor
dereference callbacks. This patch enables it for parisc64.

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
Signed-off-by: Helge Deller <deller@gmx.de>
Tested-by: Helge Deller <deller@gmx.de> # parisc64
Tested-by: Santosh Sivaraj <santosh@fossix.org> # powerpc64
Acked-by: Michael Ellerman <mpe@ellerman.id.au> # powerpc64
Tested-by: Tony Luck <tony.luck@intel.com> # ia64
---
 arch/parisc/boot/compressed/vmlinux.lds.S |  2 ++
 arch/parisc/include/asm/sections.h        |  2 ++
 arch/parisc/kernel/module.c               | 17 +++++++++++++++++
 arch/parisc/kernel/process.c              |  9 +++++++++
 arch/parisc/kernel/vmlinux.lds.S          |  2 ++
 5 files changed, 32 insertions(+)

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
index 59fbe0067112..845ddc9a3421 100644
--- a/arch/parisc/include/asm/sections.h
+++ b/arch/parisc/include/asm/sections.h
@@ -7,6 +7,8 @@
 #ifdef CONFIG_64BIT
 #undef dereference_function_descriptor
 unsigned long dereference_function_descriptor(unsigned long);
+#undef dereference_kernel_function_descriptor
+unsigned long dereference_kernel_function_descriptor(unsigned long);
 #endif
 
 #endif
diff --git a/arch/parisc/kernel/module.c b/arch/parisc/kernel/module.c
index f1a76935a314..28f89b3dcc11 100644
--- a/arch/parisc/kernel/module.c
+++ b/arch/parisc/kernel/module.c
@@ -66,6 +66,7 @@
 
 #include <asm/pgtable.h>
 #include <asm/unwind.h>
+#include <asm/sections.h>
 
 #if 0
 #define DEBUGP printk
@@ -954,3 +955,19 @@ void module_arch_cleanup(struct module *mod)
 {
 	deregister_unwind_table(mod);
 }
+
+#ifdef CONFIG_64BIT
+unsigned long dereference_module_function_descriptor(struct module *mod,
+						     unsigned long addr)
+{
+	unsigned long start_opd = (Elf64_Addr)mod->core_layout.base +
+				   mod->arch.fdesc_offset;
+	unsigned long end_opd = start_opd +
+				mod->arch.fdesc_count * sizeof(Elf64_Fdesc);
+
+	if (addr < start_opd || addr >= end_opd)
+		return addr;
+
+	return dereference_function_descriptor(addr);
+}
+#endif
diff --git a/arch/parisc/kernel/process.c b/arch/parisc/kernel/process.c
index d350aa913acc..423bbfe90e2b 100644
--- a/arch/parisc/kernel/process.c
+++ b/arch/parisc/kernel/process.c
@@ -276,6 +276,15 @@ unsigned long dereference_function_descriptor(unsigned long ptr)
 		ptr = (unsigned long)p;
 	return ptr;
 }
+
+unsigned long dereference_kernel_function_descriptor(unsigned long addr)
+{
+	if (addr < (unsigned long)__start_opd ||
+			addr >= (unsigned long)__end_opd)
+		return addr;
+
+	return dereference_function_descriptor(addr);
+}
 #endif
 
 static inline unsigned long brk_rnd(void)
diff --git a/arch/parisc/kernel/vmlinux.lds.S b/arch/parisc/kernel/vmlinux.lds.S
index ffe2cbf52d1a..ab030895dd1e 100644
--- a/arch/parisc/kernel/vmlinux.lds.S
+++ b/arch/parisc/kernel/vmlinux.lds.S
@@ -99,7 +99,9 @@ SECTIONS
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
2.14.2

