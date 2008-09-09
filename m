From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Tue, 09 Sep 2008 22:56:47 +0000
Subject: [PATCH] fix compile failure with non modular builds
Message-Id: <1221001008.23271.12.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

commit deac93df26b20cf8438339b5935b5f5643bc30c9
Author: James Bottomley <James.Bottomley@HansenPartnership.com>
Date:   Wed Sep 3 20:43:36 2008 -0500

    lib: Correct printk %pF to work on all architectures

Broke the non modular builds by moving an essential function into
modules.c.  Fix this by moving it out again and into asm/sections.h as
an inline.  To do this, the definitions of struct fdesc and struct
got_val have been lifted out of modules.c and put in asm/elf.h where
they belong.

Signed-off-by: James Bottomley <James.Bottomley@HansenPartnership.com>

---
diff --git a/arch/ia64/include/asm/elf.h b/arch/ia64/include/asm/elf.h
index 5e0c1a6..6745869 100644
--- a/arch/ia64/include/asm/elf.h
+++ b/arch/ia64/include/asm/elf.h
@@ -266,4 +266,19 @@ do {									\
 	}								\
 } while (0)
 
+/*
+ * format for entries in the Global Offset Table 
+ */
+struct got_entry {
+	uint64_t val;
+};
+
+/*
+ * Layout of the Function Descriptor
+ */
+struct fdesc {
+	uint64_t ip;
+	uint64_t gp;
+};
+
 #endif /* _ASM_IA64_ELF_H */
diff --git a/arch/ia64/include/asm/sections.h b/arch/ia64/include/asm/sections.h
index a7acad2..f667998 100644
--- a/arch/ia64/include/asm/sections.h
+++ b/arch/ia64/include/asm/sections.h
@@ -6,6 +6,8 @@
  *	David Mosberger-Tang <davidm@hpl.hp.com>
  */
 
+#include <linux/elf.h>
+#include <linux/uaccess.h>
 #include <asm-generic/sections.h>
 
 extern char __per_cpu_start[], __per_cpu_end[], __phys_per_cpu_start[];
@@ -22,7 +24,16 @@ extern char __start_unwind[], __end_unwind[];
 extern char __start_ivt_text[], __end_ivt_text[];
 
 #undef dereference_function_descriptor
-void *dereference_function_descriptor(void *);
+static inline void *dereference_function_descriptor(void *ptr)
+{
+	struct fdesc *desc = ptr;
+	void *p;
+
+	if (!probe_kernel_address(&desc->ip, p))
+		ptr = p;
+	return ptr;
+}
+
 
 #endif /* _ASM_IA64_SECTIONS_H */
 
diff --git a/arch/ia64/kernel/module.c b/arch/ia64/kernel/module.c
index 545626f..aaa7d90 100644
--- a/arch/ia64/kernel/module.c
+++ b/arch/ia64/kernel/module.c
@@ -31,11 +31,9 @@
 #include <linux/elf.h>
 #include <linux/moduleloader.h>
 #include <linux/string.h>
-#include <linux/uaccess.h>
 #include <linux/vmalloc.h>
 
 #include <asm/patch.h>
-#include <asm/sections.h>
 #include <asm/unaligned.h>
 
 #define ARCH_MODULE_DEBUG 0
@@ -137,15 +135,6 @@ static const char *reloc_name[256] = {
 
 #undef N
 
-struct got_entry {
-	uint64_t val;
-};
-
-struct fdesc {
-	uint64_t ip;
-	uint64_t gp;
-};
-
 /* Opaque struct for insns, to protect against derefs. */
 struct insn;
 
@@ -943,13 +932,3 @@ module_arch_cleanup (struct module *mod)
 	if (mod->arch.core_unw_table)
 		unw_remove_unwind_table(mod->arch.core_unw_table);
 }
-
-void *dereference_function_descriptor(void *ptr)
-{
-	struct fdesc *desc = ptr;
-	void *p;
-
-	if (!probe_kernel_address(&desc->ip, p))
-		ptr = p;
-	return ptr;
-}


