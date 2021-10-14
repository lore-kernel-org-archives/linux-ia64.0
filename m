From: Christophe Leroy <christophe.leroy@csgroup.eu>
Date: Thu, 14 Oct 2021 05:49:56 +0000
Subject: [PATCH v2 07/13] asm-generic: Define 'func_desc_t' to commonly describe function descriptors
Message-Id: <dbc9a149826eaa18f524635e64c207c85560c2aa.1634190022.git.christophe.leroy@csgroup.eu>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1634190022.git.christophe.leroy@csgroup.eu>
In-Reply-To: <cover.1634190022.git.christophe.leroy@csgroup.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, Arnd Bergmann <arnd@arndb.de>, Kees Cook <keescook@chromium.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Christophe Leroy <christophe.leroy@csgroup.eu>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

We have three architectures using function descriptors, each with its
own name.

Add a common typedef that can be used in generic code.

Also add a stub typedef for architecture without function descriptors,
to avoid a forest of #ifdefs.

It replaces the similar func_desc_t previously defined in
arch/powerpc/kernel/module_64.c

Reviewed-by: Kees Cook <keescook@chromium.org>
Signed-off-by: Christophe Leroy <christophe.leroy@csgroup.eu>
---
 arch/ia64/include/asm/sections.h    | 1 +
 arch/parisc/include/asm/sections.h  | 2 ++
 arch/powerpc/include/asm/sections.h | 1 +
 arch/powerpc/kernel/module_64.c     | 8 --------
 include/asm-generic/sections.h      | 3 +++
 5 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/arch/ia64/include/asm/sections.h b/arch/ia64/include/asm/sections.h
index 6e55e545bf02..1aaed8882294 100644
--- a/arch/ia64/include/asm/sections.h
+++ b/arch/ia64/include/asm/sections.h
@@ -11,6 +11,7 @@
 #include <linux/uaccess.h>
 
 #define HAVE_FUNCTION_DESCRIPTORS 1
+typedef struct fdesc func_desc_t;
 
 #include <asm-generic/sections.h>
 
diff --git a/arch/parisc/include/asm/sections.h b/arch/parisc/include/asm/sections.h
index 85149a89ff3e..37b34b357cb5 100644
--- a/arch/parisc/include/asm/sections.h
+++ b/arch/parisc/include/asm/sections.h
@@ -3,7 +3,9 @@
 #define _PARISC_SECTIONS_H
 
 #ifdef CONFIG_64BIT
+#include <asm/elf.h>
 #define HAVE_FUNCTION_DESCRIPTORS 1
+typedef Elf64_Fdesc func_desc_t;
 #endif
 
 /* nothing to see, move along */
diff --git a/arch/powerpc/include/asm/sections.h b/arch/powerpc/include/asm/sections.h
index bba97b8c38cf..1322d7b2f1a3 100644
--- a/arch/powerpc/include/asm/sections.h
+++ b/arch/powerpc/include/asm/sections.h
@@ -10,6 +10,7 @@
 
 #ifdef PPC64_ELF_ABI_v1
 #define HAVE_FUNCTION_DESCRIPTORS 1
+typedef struct ppc64_opd_entry func_desc_t;
 #endif
 
 #include <asm-generic/sections.h>
diff --git a/arch/powerpc/kernel/module_64.c b/arch/powerpc/kernel/module_64.c
index dc99a3f6cee2..affda7698242 100644
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
 	return (func_desc_t){addr};
@@ -57,9 +52,6 @@ static unsigned int local_entry_offset(const Elf64_Sym *sym)
 }
 #else
 
-/* An address is address of the OPD entry, which contains address of fn. */
-typedef struct ppc64_opd_entry func_desc_t;
-
 static func_desc_t func_desc(unsigned long addr)
 {
 	return *(func_desc_t *)addr;
diff --git a/include/asm-generic/sections.h b/include/asm-generic/sections.h
index b677e926e6b3..cbec7d5f1678 100644
--- a/include/asm-generic/sections.h
+++ b/include/asm-generic/sections.h
@@ -63,6 +63,9 @@ extern __visible const void __nosave_begin, __nosave_end;
 #else
 #define dereference_function_descriptor(p) ((void *)(p))
 #define dereference_kernel_function_descriptor(p) ((void *)(p))
+typedef struct {
+	unsigned long addr;
+} func_desc_t;
 #endif
 
 /* random extra sections (if any).  Override
-- 
2.31.1
