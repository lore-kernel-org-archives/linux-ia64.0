From: Christophe Leroy <christophe.leroy@csgroup.eu>
Date: Tue, 15 Feb 2022 12:41:04 +0000
Subject: [PATCH v4 09/13] asm-generic: Refactor dereference_[kernel]_function_descriptor()
Message-Id: <449db09b2eba57f4ab05f80102a67d8675bc8bcd.1644928018.git.christophe.leroy@csgroup.eu>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1644928018.git.christophe.leroy@csgroup.eu>
In-Reply-To: <cover.1644928018.git.christophe.leroy@csgroup.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, Arnd Bergmann <arnd@arndb.de>, Kees Cook <keescook@chromium.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Christophe Leroy <christophe.leroy@csgroup.eu>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

dereference_function_descriptor() and
dereference_kernel_function_descriptor() are identical on the
three architectures implementing them.

Make them common and put them out-of-line in kernel/extable.c
which is one of the users and has similar type of functions.

Reviewed-by: Kees Cook <keescook@chromium.org>
Reviewed-by: Arnd Bergmann <arnd@arndb.de>
Signed-off-by: Christophe Leroy <christophe.leroy@csgroup.eu>
Acked-by: Helge Deller <deller@gmx.de>
---
 arch/ia64/include/asm/sections.h    | 19 -------------------
 arch/parisc/include/asm/sections.h  |  9 ---------
 arch/parisc/kernel/process.c        | 21 ---------------------
 arch/powerpc/include/asm/sections.h | 23 -----------------------
 include/asm-generic/sections.h      |  2 ++
 kernel/extable.c                    | 23 ++++++++++++++++++++++-
 6 files changed, 24 insertions(+), 73 deletions(-)

diff --git a/arch/ia64/include/asm/sections.h b/arch/ia64/include/asm/sections.h
index 3abe0562b01a..8e0875cf6071 100644
--- a/arch/ia64/include/asm/sections.h
+++ b/arch/ia64/include/asm/sections.h
@@ -30,23 +30,4 @@ extern char __start_gate_brl_fsys_bubble_down_patchlist[], __end_gate_brl_fsys_b
 extern char __start_unwind[], __end_unwind[];
 extern char __start_ivt_text[], __end_ivt_text[];
 
-#undef dereference_function_descriptor
-static inline void *dereference_function_descriptor(void *ptr)
-{
-	struct fdesc *desc = ptr;
-	void *p;
-
-	if (!get_kernel_nofault(p, (void *)&desc->addr))
-		ptr = p;
-	return ptr;
-}
-
-#undef dereference_kernel_function_descriptor
-static inline void *dereference_kernel_function_descriptor(void *ptr)
-{
-	if (ptr < (void *)__start_opd || ptr >= (void *)__end_opd)
-		return ptr;
-	return dereference_function_descriptor(ptr);
-}
-
 #endif /* _ASM_IA64_SECTIONS_H */
diff --git a/arch/parisc/include/asm/sections.h b/arch/parisc/include/asm/sections.h
index ace1d4047a0b..33df42b5cc6d 100644
--- a/arch/parisc/include/asm/sections.h
+++ b/arch/parisc/include/asm/sections.h
@@ -12,13 +12,4 @@ typedef Elf64_Fdesc func_desc_t;
 
 extern char __alt_instructions[], __alt_instructions_end[];
 
-#ifdef CONFIG_64BIT
-
-#undef dereference_function_descriptor
-void *dereference_function_descriptor(void *);
-
-#undef dereference_kernel_function_descriptor
-void *dereference_kernel_function_descriptor(void *);
-#endif
-
 #endif
diff --git a/arch/parisc/kernel/process.c b/arch/parisc/kernel/process.c
index ea3d83b6fb62..2030c77592d3 100644
--- a/arch/parisc/kernel/process.c
+++ b/arch/parisc/kernel/process.c
@@ -263,27 +263,6 @@ __get_wchan(struct task_struct *p)
 	return 0;
 }
 
-#ifdef CONFIG_64BIT
-void *dereference_function_descriptor(void *ptr)
-{
-	Elf64_Fdesc *desc = ptr;
-	void *p;
-
-	if (!get_kernel_nofault(p, (void *)&desc->addr))
-		ptr = p;
-	return ptr;
-}
-
-void *dereference_kernel_function_descriptor(void *ptr)
-{
-	if (ptr < (void *)__start_opd ||
-			ptr >= (void *)__end_opd)
-		return ptr;
-
-	return dereference_function_descriptor(ptr);
-}
-#endif
-
 static inline unsigned long brk_rnd(void)
 {
 	return (get_random_int() & BRK_RND_MASK) << PAGE_SHIFT;
diff --git a/arch/powerpc/include/asm/sections.h b/arch/powerpc/include/asm/sections.h
index fddfb3937868..8be2c491c733 100644
--- a/arch/powerpc/include/asm/sections.h
+++ b/arch/powerpc/include/asm/sections.h
@@ -58,29 +58,6 @@ static inline int overlaps_kernel_text(unsigned long start, unsigned long end)
 		(unsigned long)_stext < end;
 }
 
-#ifdef PPC64_ELF_ABI_v1
-
-#undef dereference_function_descriptor
-static inline void *dereference_function_descriptor(void *ptr)
-{
-	struct func_desc *desc = ptr;
-	void *p;
-
-	if (!get_kernel_nofault(p, (void *)&desc->addr))
-		ptr = p;
-	return ptr;
-}
-
-#undef dereference_kernel_function_descriptor
-static inline void *dereference_kernel_function_descriptor(void *ptr)
-{
-	if (ptr < (void *)__start_opd || ptr >= (void *)__end_opd)
-		return ptr;
-
-	return dereference_function_descriptor(ptr);
-}
-#endif /* PPC64_ELF_ABI_v1 */
-
 #endif
 
 #endif /* __KERNEL__ */
diff --git a/include/asm-generic/sections.h b/include/asm-generic/sections.h
index bbf97502470c..d0f7bdd2fdf2 100644
--- a/include/asm-generic/sections.h
+++ b/include/asm-generic/sections.h
@@ -60,6 +60,8 @@ extern __visible const void __nosave_begin, __nosave_end;
 
 /* Function descriptor handling (if any).  Override in asm/sections.h */
 #ifdef CONFIG_HAVE_FUNCTION_DESCRIPTORS
+void *dereference_function_descriptor(void *ptr);
+void *dereference_kernel_function_descriptor(void *ptr);
 #else
 #define dereference_function_descriptor(p) ((void *)(p))
 #define dereference_kernel_function_descriptor(p) ((void *)(p))
diff --git a/kernel/extable.c b/kernel/extable.c
index b6f330f0fe74..394c39b86e38 100644
--- a/kernel/extable.c
+++ b/kernel/extable.c
@@ -3,6 +3,7 @@
    Copyright (C) 2001 Rusty Russell, 2002 Rusty Russell IBM.
 
 */
+#include <linux/elf.h>
 #include <linux/ftrace.h>
 #include <linux/memory.h>
 #include <linux/extable.h>
@@ -132,12 +133,32 @@ int kernel_text_address(unsigned long addr)
 }
 
 /*
- * On some architectures (PPC64, IA64) function pointers
+ * On some architectures (PPC64, IA64, PARISC) function pointers
  * are actually only tokens to some data that then holds the
  * real function address. As a result, to find if a function
  * pointer is part of the kernel text, we need to do some
  * special dereferencing first.
  */
+#ifdef CONFIG_HAVE_FUNCTION_DESCRIPTORS
+void *dereference_function_descriptor(void *ptr)
+{
+	func_desc_t *desc = ptr;
+	void *p;
+
+	if (!get_kernel_nofault(p, (void *)&desc->addr))
+		ptr = p;
+	return ptr;
+}
+
+void *dereference_kernel_function_descriptor(void *ptr)
+{
+	if (ptr < (void *)__start_opd || ptr >= (void *)__end_opd)
+		return ptr;
+
+	return dereference_function_descriptor(ptr);
+}
+#endif
+
 int func_ptr_is_kernel_text(void *ptr)
 {
 	unsigned long addr;
-- 
2.34.1
