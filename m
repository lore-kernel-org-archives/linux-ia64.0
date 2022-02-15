From: Christophe Leroy <christophe.leroy@csgroup.eu>
Date: Tue, 15 Feb 2022 12:41:03 +0000
Subject: [PATCH v4 08/13] asm-generic: Define 'func_desc_t' to commonly describe function descriptors
Message-Id: <f1f91b142b3c1082bdc1586ce71c9bac1e75213c.1644928018.git.christophe.leroy@csgroup.eu>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1644928018.git.christophe.leroy@csgroup.eu>
In-Reply-To: <cover.1644928018.git.christophe.leroy@csgroup.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, Arnd Bergmann <arnd@arndb.de>, Kees Cook <keescook@chromium.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Christophe Leroy <christophe.leroy@csgroup.eu>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

We have three architectures using function descriptors, each with its
own type and name.

Add a common typedef that can be used in generic code.

Also add a stub typedef for architecture without function descriptors,
to avoid a forest of #ifdefs.

It replaces the similar 'func_desc_t' previously defined in
arch/powerpc/kernel/module_64.c

Reviewed-by: Kees Cook <keescook@chromium.org>
Acked-by: Arnd Bergmann <arnd@arndb.de>
Signed-off-by: Christophe Leroy <christophe.leroy@csgroup.eu>
Acked-by: Helge Deller <deller@gmx.de>
---
 arch/ia64/include/asm/sections.h    | 3 +++
 arch/parisc/include/asm/sections.h  | 5 +++++
 arch/powerpc/include/asm/sections.h | 4 ++++
 arch/powerpc/kernel/module_64.c     | 8 --------
 include/asm-generic/sections.h      | 5 +++++
 5 files changed, 17 insertions(+), 8 deletions(-)

diff --git a/arch/ia64/include/asm/sections.h b/arch/ia64/include/asm/sections.h
index 2460d365a057..3abe0562b01a 100644
--- a/arch/ia64/include/asm/sections.h
+++ b/arch/ia64/include/asm/sections.h
@@ -9,6 +9,9 @@
 
 #include <linux/elf.h>
 #include <linux/uaccess.h>
+
+typedef struct fdesc func_desc_t;
+
 #include <asm-generic/sections.h>
 
 extern char __phys_per_cpu_start[];
diff --git a/arch/parisc/include/asm/sections.h b/arch/parisc/include/asm/sections.h
index c8092e4d94de..ace1d4047a0b 100644
--- a/arch/parisc/include/asm/sections.h
+++ b/arch/parisc/include/asm/sections.h
@@ -2,6 +2,11 @@
 #ifndef _PARISC_SECTIONS_H
 #define _PARISC_SECTIONS_H
 
+#ifdef CONFIG_HAVE_FUNCTION_DESCRIPTORS
+#include <asm/elf.h>
+typedef Elf64_Fdesc func_desc_t;
+#endif
+
 /* nothing to see, move along */
 #include <asm-generic/sections.h>
 
diff --git a/arch/powerpc/include/asm/sections.h b/arch/powerpc/include/asm/sections.h
index 7728a7a146c3..fddfb3937868 100644
--- a/arch/powerpc/include/asm/sections.h
+++ b/arch/powerpc/include/asm/sections.h
@@ -6,6 +6,10 @@
 #include <linux/elf.h>
 #include <linux/uaccess.h>
 
+#ifdef CONFIG_HAVE_FUNCTION_DESCRIPTORS
+typedef struct func_desc func_desc_t;
+#endif
+
 #include <asm-generic/sections.h>
 
 extern char __head_end[];
diff --git a/arch/powerpc/kernel/module_64.c b/arch/powerpc/kernel/module_64.c
index ff93ef4cb5a2..9abc0e783e36 100644
--- a/arch/powerpc/kernel/module_64.c
+++ b/arch/powerpc/kernel/module_64.c
@@ -32,11 +32,6 @@
 
 #ifdef PPC64_ELF_ABI_v2
 
-/* An address is simply the address of the function. */
-typedef struct {
-	unsigned long addr;
-} func_desc_t;
-
 static func_desc_t func_desc(unsigned long addr)
 {
 	func_desc_t desc = {
@@ -61,9 +56,6 @@ static unsigned int local_entry_offset(const Elf64_Sym *sym)
 }
 #else
 
-/* An address is address of the OPD entry, which contains address of fn. */
-typedef struct func_desc func_desc_t;
-
 static func_desc_t func_desc(unsigned long addr)
 {
 	return *(struct func_desc *)addr;
diff --git a/include/asm-generic/sections.h b/include/asm-generic/sections.h
index 3ef83e1aebee..bbf97502470c 100644
--- a/include/asm-generic/sections.h
+++ b/include/asm-generic/sections.h
@@ -63,6 +63,11 @@ extern __visible const void __nosave_begin, __nosave_end;
 #else
 #define dereference_function_descriptor(p) ((void *)(p))
 #define dereference_kernel_function_descriptor(p) ((void *)(p))
+
+/* An address is simply the address of the function. */
+typedef struct {
+	unsigned long addr;
+} func_desc_t;
 #endif
 
 static inline bool have_function_descriptors(void)
-- 
2.34.1
