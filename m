From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Tue, 09 Sep 2008 14:12:41 +0000
Subject: RE: [PATCH] Correct printk %pF to work on all architectures
Message-Id: <1220969561.3334.7.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <1220473137.3254.29.camel@localhost.localdomain>
	 <alpine.LFD.1.10.0809031419560.3515@nehalem.linux-foundation.org>
	 <1220481754.3254.42.camel@localhost.localdomain>
	 <alpine.LFD.1.10.0809031546310.3515@nehalem.linux-foundation.org>
	 <1220482853.3254.47.camel@localhost.localdomain>
	 <alpine.LFD.1.10.0809031602270.3515@nehalem.linux-foundation.org>
	 <1220484812.3254.59.camel@localhost.localdomain>
	 <alpine.LFD.1.10.0809031636320.3515@nehalem.linux-foundation.org>
	 <1220492616.3254.64.camel@localhost.localdomain>
	 <1220567811.4879.85.camel@pasglop>
	 <57C9024A16AD2D4C97DC78E552063EA30A0DC383@orsmsx505.amr.corp.intel.com>
In-Reply-To: <57C9024A16AD2D4C97DC78E552063EA30A0DC383@orsmsx505.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Luck, Tony" <tony.luck@intel.com>, "benh@kernel.crashing.org" <benh@kernel.crashing.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linuxppc-dev@ozlabs.org" <linuxppc-dev@ozlabs.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Parisc List <linux-parisc@vger.kernel.org>

OK, so could we get this in to -rc5 please?  It's a bug fix for parisc
since we're currently printing rubbish.

James

---
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Wed, 3 Sep 2008 20:43:36 -0500
Subject: lib: Correct printk %pF to work on all architectures

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
Acked-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Acked-by: Tony Luck <tony.luck@intel.com>
---
 arch/ia64/include/asm/sections.h    |    3 +++
 arch/ia64/kernel/module.c           |   12 ++++++++++++
 arch/parisc/kernel/module.c         |   14 ++++++++++++++
 arch/powerpc/include/asm/sections.h |    3 +++
 arch/powerpc/kernel/module_64.c     |   13 ++++++++++++-
 include/asm-generic/sections.h      |    6 ++++++
 include/asm-parisc/sections.h       |    5 +++++
 lib/vsprintf.c                      |   11 +----------
 8 files changed, 56 insertions(+), 11 deletions(-)

diff --git a/arch/ia64/include/asm/sections.h b/arch/ia64/include/asm/sections.h
index 7286e4a..a7acad2 100644
--- a/arch/ia64/include/asm/sections.h
+++ b/arch/ia64/include/asm/sections.h
@@ -21,5 +21,8 @@ extern char __start_gate_brl_fsys_bubble_down_patchlist[], __end_gate_brl_fsys_b
 extern char __start_unwind[], __end_unwind[];
 extern char __start_ivt_text[], __end_ivt_text[];
 
+#undef dereference_function_descriptor
+void *dereference_function_descriptor(void *);
+
 #endif /* _ASM_IA64_SECTIONS_H */
 
diff --git a/arch/ia64/kernel/module.c b/arch/ia64/kernel/module.c
index 29aad34..545626f 100644
--- a/arch/ia64/kernel/module.c
+++ b/arch/ia64/kernel/module.c
@@ -31,9 +31,11 @@
 #include <linux/elf.h>
 #include <linux/moduleloader.h>
 #include <linux/string.h>
+#include <linux/uaccess.h>
 #include <linux/vmalloc.h>
 
 #include <asm/patch.h>
+#include <asm/sections.h>
 #include <asm/unaligned.h>
 
 #define ARCH_MODULE_DEBUG 0
@@ -941,3 +943,13 @@ module_arch_cleanup (struct module *mod)
 	if (mod->arch.core_unw_table)
 		unw_remove_unwind_table(mod->arch.core_unw_table);
 }
+
+void *dereference_function_descriptor(void *ptr)
+{
+	struct fdesc *desc = ptr;
+	void *p;
+
+	if (!probe_kernel_address(&desc->ip, p))
+		ptr = p;
+	return ptr;
+}
diff --git a/arch/parisc/kernel/module.c b/arch/parisc/kernel/module.c
index fdacdd4..44138c3 100644
--- a/arch/parisc/kernel/module.c
+++ b/arch/parisc/kernel/module.c
@@ -47,7 +47,9 @@
 #include <linux/string.h>
 #include <linux/kernel.h>
 #include <linux/bug.h>
+#include <linux/uaccess.h>
 
+#include <asm/sections.h>
 #include <asm/unwind.h>
 
 #if 0
@@ -860,3 +862,15 @@ void module_arch_cleanup(struct module *mod)
 	deregister_unwind_table(mod);
 	module_bug_cleanup(mod);
 }
+
+#ifdef CONFIG_64BIT
+void *dereference_function_descriptor(void *ptr)
+{
+	Elf64_Fdesc *desc = ptr;
+	void *p;
+
+	if (!probe_kernel_address(&desc->addr, p))
+		ptr = p;
+	return ptr;
+}
+#endif
diff --git a/arch/powerpc/include/asm/sections.h b/arch/powerpc/include/asm/sections.h
index 916018e..7710e9e 100644
--- a/arch/powerpc/include/asm/sections.h
+++ b/arch/powerpc/include/asm/sections.h
@@ -16,6 +16,9 @@ static inline int in_kernel_text(unsigned long addr)
 	return 0;
 }
 
+#undef dereference_function_descriptor
+void *dereference_function_descriptor(void *);
+
 #endif
 
 #endif /* __KERNEL__ */
diff --git a/arch/powerpc/kernel/module_64.c b/arch/powerpc/kernel/module_64.c
index ee6a298..ad79de2 100644
--- a/arch/powerpc/kernel/module_64.c
+++ b/arch/powerpc/kernel/module_64.c
@@ -21,8 +21,9 @@
 #include <linux/err.h>
 #include <linux/vmalloc.h>
 #include <linux/bug.h>
+#include <linux/uaccess.h>
 #include <asm/module.h>
-#include <asm/uaccess.h>
+#include <asm/sections.h>
 #include <asm/firmware.h>
 #include <asm/code-patching.h>
 #include <linux/sort.h>
@@ -451,3 +452,13 @@ int apply_relocate_add(Elf64_Shdr *sechdrs,
 
 	return 0;
 }
+
+void *dereference_function_descriptor(void *ptr)
+{
+	struct ppc64_opd_entry *desc = ptr;
+	void *p;
+
+	if (!probe_kernel_address(&desc->funcaddr, p))
+		ptr = p;
+	return ptr;
+}
diff --git a/include/asm-generic/sections.h b/include/asm-generic/sections.h
index 8feeae1..79a7ff9 100644
--- a/include/asm-generic/sections.h
+++ b/include/asm-generic/sections.h
@@ -14,4 +14,10 @@ extern char __kprobes_text_start[], __kprobes_text_end[];
 extern char __initdata_begin[], __initdata_end[];
 extern char __start_rodata[], __end_rodata[];
 
+/* function descriptor handling (if any).  Override
+ * in asm/sections.h */
+#ifndef dereference_function_descriptor
+#define dereference_function_descriptor(p) (p)
+#endif
+
 #endif /* _ASM_GENERIC_SECTIONS_H_ */
diff --git a/include/asm-parisc/sections.h b/include/asm-parisc/sections.h
index fdd43ec..9d13c35 100644
--- a/include/asm-parisc/sections.h
+++ b/include/asm-parisc/sections.h
@@ -4,4 +4,9 @@
 /* nothing to see, move along */
 #include <asm-generic/sections.h>
 
+#ifdef CONFIG_64BIT
+#undef dereference_function_descriptor
+void *dereference_function_descriptor(void *);
+#endif
+
 #endif
diff --git a/lib/vsprintf.c b/lib/vsprintf.c
index d8d1d11..c399bc1 100644
--- a/lib/vsprintf.c
+++ b/lib/vsprintf.c
@@ -27,6 +27,7 @@
 
 #include <asm/page.h>		/* for PAGE_SIZE */
 #include <asm/div64.h>
+#include <asm/sections.h>	/* for dereference_function_descriptor() */
 
 /* Works only for digits and letters, but small and fast */
 #define TOLOWER(x) ((x) | 0x20)
@@ -513,16 +514,6 @@ static char *string(char *buf, char *end, char *s, int field_width, int precisio
 	return buf;
 }
 
-static inline void *dereference_function_descriptor(void *ptr)
-{
-#if defined(CONFIG_IA64) || defined(CONFIG_PPC64)
-	void *p;
-	if (!probe_kernel_address(ptr, p))
-		ptr = p;
-#endif
-	return ptr;
-}
-
 static char *symbol_string(char *buf, char *end, void *ptr, int field_width, int precision, int flags)
 {
 	unsigned long value = (unsigned long) ptr;
-- 
1.5.5.1



