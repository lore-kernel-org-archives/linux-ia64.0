From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Wed, 03 Sep 2008 22:42:34 +0000
Subject: Re: [PATCH] Correct printk %pF to work on all architectures
Message-Id: <1220481754.3254.42.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <1220473137.3254.29.camel@localhost.localdomain>
	 <alpine.LFD.1.10.0809031419560.3515@nehalem.linux-foundation.org>
In-Reply-To: <alpine.LFD.1.10.0809031419560.3515@nehalem.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-arch@vger.kernel.org, Parisc List <linux-parisc@vger.kernel.org>, linux-ia64@vger.kernel.org, linuxppc-dev@ozlabs.org

On Wed, 2008-09-03 at 14:22 -0700, Linus Torvalds wrote:
> 
> On Wed, 3 Sep 2008, James Bottomley wrote:
> > 
> > Make dereference_function_descriptor() more accommodating by allowing
> > architecture overrides.
> 
> Don't do it like this.
> 
> We don't want some stupid useless weak function that is empty on all sane 
> platforms.
> 
> Just do
> 
> 	.. declare or create an inline 'parisc_function_descriptor()' ..
> 
> 	#define dereference_function_descriptor(p) parisc_function_descriptor(p)
> 
> in some arch header file. And then use
> 
> 	#ifndef dereference_function_descriptor
> 	#define dereference_function_descriptor(p) (p)
> 	#endif
> 
> in the generic code, so that sane architectures don't need to do anything 
> at all.

Is that finally final?  because the last time I tried to do the above
for a voyager override I was told weak functions were the preferred
method ...

Anyway, it's easy to do (if a slightly larger diff) ... I have to move
the prototype from include/kernel.h to include/module.h because I need
an assured asm/xxx include before it to get the override.

It was also pointed out that I should be returning the passed in ptr,
not NULL on failure and that the return should be ptr not p.

James

---

The current way its coded doesn't work on parisc64.  For two
reasons:  1) parisc isn't in the #ifdef and 2) parisc has a different
format for function descriptors

Make dereference_function_descriptor() more accommodating by allowing
architecture overrides.

Signed-off-by: James Bottomley <James.Bottomley@HansenPartnership.com>
---
 arch/ia64/include/asm/module.h    |    4 ++++
 arch/ia64/kernel/module.c         |    9 +++++++++
 arch/parisc/kernel/module.c       |   13 +++++++++++++
 arch/powerpc/include/asm/module.h |    6 ++++++
 arch/powerpc/kernel/module_64.c   |    9 +++++++++
 include/asm-parisc/module.h       |    6 ++++++
 include/linux/module.h            |    5 +++++
 lib/vsprintf.c                    |   10 ----------
 8 files changed, 52 insertions(+), 10 deletions(-)

diff --git a/arch/ia64/include/asm/module.h b/arch/ia64/include/asm/module.h
index d2da61e..d0328be 100644
--- a/arch/ia64/include/asm/module.h
+++ b/arch/ia64/include/asm/module.h
@@ -33,4 +33,8 @@ struct mod_arch_specific {
 
 #define ARCH_SHF_SMALL	SHF_IA_64_SHORT
 
+void *ia64_dereference_function_descriptor(void *);
+#define dereference_function_descriptor(p) \
+	ia64_dereference_function_descriptor(p)
+
 #endif /* _ASM_IA64_MODULE_H */
diff --git a/arch/ia64/kernel/module.c b/arch/ia64/kernel/module.c
index 29aad34..4aca326 100644
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
+void *ia64_dereference_function_descriptor(void *ptr)
+{
+	void *p;
+	if (!probe_kernel_address(ptr, p))
+		ptr = p;
+	return ptr;
+}
diff --git a/arch/parisc/kernel/module.c b/arch/parisc/kernel/module.c
index fdacdd4..6ec3b07 100644
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
+void *parisc_dereference_function_descriptor(void *ptr)
+{
+	Elf64_Fdesc *desc = ptr;
+	void *p;
+
+	if (!probe_kernel_address(&desc->addr, p))
+		ptr = p;
+	return ptr;
+}
+#endif
diff --git a/arch/powerpc/include/asm/module.h b/arch/powerpc/include/asm/module.h
index e5f14b1..a861b2c 100644
--- a/arch/powerpc/include/asm/module.h
+++ b/arch/powerpc/include/asm/module.h
@@ -73,5 +73,11 @@ struct exception_table_entry;
 void sort_ex_table(struct exception_table_entry *start,
 		   struct exception_table_entry *finish);
 
+#ifdef __powerpc64__
+void *powerpc64_dereference_function_descriptor(void *);
+#define dereference_function_descriptor(p) \
+	powerpc64_dereference_function_descriptor(p)
+#endif
+
 #endif /* __KERNEL__ */
 #endif	/* _ASM_POWERPC_MODULE_H */
diff --git a/arch/powerpc/kernel/module_64.c b/arch/powerpc/kernel/module_64.c
index ee6a298..e814c2a 100644
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
+void *powerpc64_dereference_function_descriptor(void *ptr)
+{
+	void *p;
+	if (!probe_kernel_address(ptr, p))
+		ptr = p;
+	return ptr;
+}
diff --git a/include/asm-parisc/module.h b/include/asm-parisc/module.h
index c2cb49e..f5f971b 100644
--- a/include/asm-parisc/module.h
+++ b/include/asm-parisc/module.h
@@ -29,4 +29,10 @@ struct mod_arch_specific
 	struct unwind_table *unwind;
 };
 
+#ifdef CONFIG_64BIT
+void *parisc_dereference_function_descriptor(void *);
+#define dereference_function_descriptor(p) \
+	parisc_dereference_function_descriptor(p)
+#endif
+
 #endif /* _ASM_PARISC_MODULE_H */
diff --git a/include/linux/module.h b/include/linux/module.h
index 68e0955..a549f89 100644
--- a/include/linux/module.h
+++ b/include/linux/module.h
@@ -76,6 +76,11 @@ void sort_extable(struct exception_table_entry *start,
 		  struct exception_table_entry *finish);
 void sort_main_extable(void);
 
+/* function descriptor handling (if any) */
+#ifndef dereference_function_descriptor
+#define dereference_function_descriptor(p) (p)
+#endif
+
 #ifdef MODULE
 #define MODULE_GENERIC_TABLE(gtype,name)			\
 extern const struct gtype##_id __mod_##gtype##_table		\
diff --git a/lib/vsprintf.c b/lib/vsprintf.c
index d8d1d11..0c47629 100644
--- a/lib/vsprintf.c
+++ b/lib/vsprintf.c
@@ -513,16 +513,6 @@ static char *string(char *buf, char *end, char *s, int field_width, int precisio
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
1.5.6.5



