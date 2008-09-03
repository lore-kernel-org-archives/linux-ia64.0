From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Wed, 03 Sep 2008 20:18:57 +0000
Subject: [PATCH] Correct printk %pF to work on all architectures
Message-Id: <1220473137.3254.29.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-arch@vger.kernel.org, Parisc List <linux-parisc@vger.kernel.org>, linux-ia64@vger.kernel.org, linuxppc-dev@ozlabs.org

It was introduced by 

commit 0fe1ef24f7bd0020f29ffe287dfdb9ead33ca0b2
Author: Linus Torvalds <torvalds@linux-foundation.org>
Date:   Sun Jul 6 16:43:12 2008 -0700

    vsprintf: add support for '%pS' and '%pF' pointer formats


However, the current way its coded doesn't work on parisc64.  For two
reasons:  1) parisc isn't in the #ifdef and 2) parisc has a different
format for function descriptors

Make dereference_function_descriptor() more accommodating by allowing
architecture overrides.  I put the three overrides (for parisc64, ppc64
and ia64) in arch/kernel/module.c because that's where the kernel
internal linker which knows how to deal with function descriptors sits.

Signed-off-by: James Bottomley <James.Bottomley@HansenPartnership.com>
---
 arch/ia64/kernel/module.c       |    9 +++++++++
 arch/parisc/kernel/module.c     |   13 +++++++++++++
 arch/powerpc/kernel/module_64.c |    9 +++++++++
 include/linux/kernel.h          |    3 +++
 lib/vsprintf.c                  |   12 ++++++------
 5 files changed, 40 insertions(+), 6 deletions(-)

diff --git a/arch/ia64/kernel/module.c b/arch/ia64/kernel/module.c
index 29aad34..596a862 100644
--- a/arch/ia64/kernel/module.c
+++ b/arch/ia64/kernel/module.c
@@ -31,6 +31,7 @@
 #include <linux/elf.h>
 #include <linux/moduleloader.h>
 #include <linux/string.h>
+#include <linux/uaccess.h>
 #include <linux/vmalloc.h>
 
 #include <asm/patch.h>
@@ -941,3 +942,11 @@ module_arch_cleanup (struct module *mod)
 	if (mod->arch.core_unw_table)
 		unw_remove_unwind_table(mod->arch.core_unw_table);
 }
+
+void *dereference_function_descriptor(void *ptr)
+{
+	void *p = NULL;
+	if (!probe_kernel_address(ptr, p))
+		ptr = p;
+	return p;
+}
diff --git a/arch/parisc/kernel/module.c b/arch/parisc/kernel/module.c
index fdacdd4..4ad80a5 100644
--- a/arch/parisc/kernel/module.c
+++ b/arch/parisc/kernel/module.c
@@ -47,6 +47,7 @@
 #include <linux/string.h>
 #include <linux/kernel.h>
 #include <linux/bug.h>
+#include <linux/uaccess.h>
 
 #include <asm/unwind.h>
 
@@ -860,3 +861,15 @@ void module_arch_cleanup(struct module *mod)
 	deregister_unwind_table(mod);
 	module_bug_cleanup(mod);
 }
+
+#ifdef CONFIG_64BIT
+void *dereference_function_descriptor(void *ptr)
+{
+	Elf64_Fdesc *desc = ptr;
+	void *p = NULL;
+
+	if (!probe_kernel_address(&desc->addr, p))
+		ptr = p;
+	return p;
+}
+#endif
diff --git a/arch/powerpc/kernel/module_64.c b/arch/powerpc/kernel/module_64.c
index ee6a298..60e9749 100644
--- a/arch/powerpc/kernel/module_64.c
+++ b/arch/powerpc/kernel/module_64.c
@@ -21,6 +21,7 @@
 #include <linux/err.h>
 #include <linux/vmalloc.h>
 #include <linux/bug.h>
+#include <linux/uaccess.h>
 #include <asm/module.h>
 #include <asm/uaccess.h>
 #include <asm/firmware.h>
@@ -451,3 +452,11 @@ int apply_relocate_add(Elf64_Shdr *sechdrs,
 
 	return 0;
 }
+
+void *dereference_function_descriptor(void *ptr)
+{
+	void *p = NULL;
+	if (!probe_kernel_address(ptr, p))
+		ptr = p;
+	return p;
+}
diff --git a/include/linux/kernel.h b/include/linux/kernel.h
index 2651f80..8ff19b3 100644
--- a/include/linux/kernel.h
+++ b/include/linux/kernel.h
@@ -189,6 +189,9 @@ extern int __kernel_text_address(unsigned long addr);
 extern int kernel_text_address(unsigned long addr);
 struct pid;
 extern struct pid *session_of_pgrp(struct pid *pgrp);
+/* function descriptor handling (if any) */
+extern void *dereference_function_descriptor(void *ptr);
+
 
 #ifdef CONFIG_PRINTK
 asmlinkage int vprintk(const char *fmt, va_list args)
diff --git a/lib/vsprintf.c b/lib/vsprintf.c
index d8d1d11..cffcd95 100644
--- a/lib/vsprintf.c
+++ b/lib/vsprintf.c
@@ -513,13 +513,13 @@ static char *string(char *buf, char *end, char *s, int field_width, int precisio
 	return buf;
 }
 
-static inline void *dereference_function_descriptor(void *ptr)
+/*
+ * Some architectures need special handling for pointers
+ * to functions, which are done via function descriptors
+ * Do a non weak override of this function for them
+ */
+void __weak *dereference_function_descriptor(void *ptr)
 {
-#if defined(CONFIG_IA64) || defined(CONFIG_PPC64)
-	void *p;
-	if (!probe_kernel_address(ptr, p))
-		ptr = p;
-#endif
 	return ptr;
 }
 
-- 
1.5.6.5



