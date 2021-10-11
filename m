From: Christophe Leroy <christophe.leroy@csgroup.eu>
Date: Mon, 11 Oct 2021 15:25:32 +0000
Subject: [PATCH v1 05/10] asm-generic: Define 'funct_descr_t' to commonly describe function descriptors
Message-Id: <02224551451ab9c37055499fc621c41246c81125.1633964380.git.christophe.leroy@csgroup.eu>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1633964380.git.christophe.leroy@csgroup.eu>
In-Reply-To: <cover.1633964380.git.christophe.leroy@csgroup.eu>
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

Signed-off-by: Christophe Leroy <christophe.leroy@csgroup.eu>
---
 arch/ia64/include/asm/sections.h    | 1 +
 arch/parisc/include/asm/sections.h  | 1 +
 arch/powerpc/include/asm/sections.h | 1 +
 include/asm-generic/sections.h      | 3 +++
 4 files changed, 6 insertions(+)

diff --git a/arch/ia64/include/asm/sections.h b/arch/ia64/include/asm/sections.h
index 80f5868afb06..929b5c535620 100644
--- a/arch/ia64/include/asm/sections.h
+++ b/arch/ia64/include/asm/sections.h
@@ -8,6 +8,7 @@
  */
 
 #define HAVE_DEREFERENCE_FUNCTION_DESCRIPTOR 1
+typedef struct fdesc funct_descr_t;
 
 #include <linux/elf.h>
 #include <linux/uaccess.h>
diff --git a/arch/parisc/include/asm/sections.h b/arch/parisc/include/asm/sections.h
index 2e781ee19b66..329e80f7af0a 100644
--- a/arch/parisc/include/asm/sections.h
+++ b/arch/parisc/include/asm/sections.h
@@ -4,6 +4,7 @@
 
 #ifdef CONFIG_64BIT
 #define HAVE_DEREFERENCE_FUNCTION_DESCRIPTOR 1
+typedef Elf64_Fdesc funct_descr_t;
 #endif
 
 /* nothing to see, move along */
diff --git a/arch/powerpc/include/asm/sections.h b/arch/powerpc/include/asm/sections.h
index b7f1ba04e756..d0d5287fa568 100644
--- a/arch/powerpc/include/asm/sections.h
+++ b/arch/powerpc/include/asm/sections.h
@@ -10,6 +10,7 @@
 
 #ifdef PPC64_ELF_ABI_v1
 #define HAVE_DEREFERENCE_FUNCTION_DESCRIPTOR 1
+typedef struct ppc64_opd_entry funct_descr_t;
 #endif
 
 #include <asm-generic/sections.h>
diff --git a/include/asm-generic/sections.h b/include/asm-generic/sections.h
index 1db5cfd69817..436412d94054 100644
--- a/include/asm-generic/sections.h
+++ b/include/asm-generic/sections.h
@@ -63,6 +63,9 @@ extern __visible const void __nosave_begin, __nosave_end;
 #else
 #define dereference_function_descriptor(p) ((void *)(p))
 #define dereference_kernel_function_descriptor(p) ((void *)(p))
+typedef struct {
+	unsigned long addr;
+} funct_descr_t;
 #endif
 
 /* random extra sections (if any).  Override
-- 
2.31.1
