From: Christophe Leroy <christophe.leroy@csgroup.eu>
Date: Mon, 11 Oct 2021 15:25:31 +0000
Subject: [PATCH v1 04/10] asm-generic: Use HAVE_DEREFERENCE_FUNCTION_DESCRIPTOR to define associated stubs
Message-Id: <8db2a3ca2b26a8325c671baa3e0492914597f079.1633964380.git.christophe.leroy@csgroup.eu>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1633964380.git.christophe.leroy@csgroup.eu>
In-Reply-To: <cover.1633964380.git.christophe.leroy@csgroup.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, Arnd Bergmann <arnd@arndb.de>, Kees Cook <keescook@chromium.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Christophe Leroy <christophe.leroy@csgroup.eu>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

Use HAVE_DEREFERENCE_FUNCTION_DESCRIPTOR instead of 'dereference_function_descriptor'
to know whether arch has function descriptors.

Signed-off-by: Christophe Leroy <christophe.leroy@csgroup.eu>
---
 arch/ia64/include/asm/sections.h    | 4 ++--
 arch/parisc/include/asm/sections.h  | 6 ++++--
 arch/powerpc/include/asm/sections.h | 6 ++++--
 include/asm-generic/sections.h      | 3 ++-
 4 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/arch/ia64/include/asm/sections.h b/arch/ia64/include/asm/sections.h
index 35f24e52149a..80f5868afb06 100644
--- a/arch/ia64/include/asm/sections.h
+++ b/arch/ia64/include/asm/sections.h
@@ -7,6 +7,8 @@
  *	David Mosberger-Tang <davidm@hpl.hp.com>
  */
 
+#define HAVE_DEREFERENCE_FUNCTION_DESCRIPTOR 1
+
 #include <linux/elf.h>
 #include <linux/uaccess.h>
 #include <asm-generic/sections.h>
@@ -27,8 +29,6 @@ extern char __start_gate_brl_fsys_bubble_down_patchlist[], __end_gate_brl_fsys_b
 extern char __start_unwind[], __end_unwind[];
 extern char __start_ivt_text[], __end_ivt_text[];
 
-#define HAVE_DEREFERENCE_FUNCTION_DESCRIPTOR 1
-
 #undef dereference_function_descriptor
 static inline void *dereference_function_descriptor(void *ptr)
 {
diff --git a/arch/parisc/include/asm/sections.h b/arch/parisc/include/asm/sections.h
index bb52aea0cb21..2e781ee19b66 100644
--- a/arch/parisc/include/asm/sections.h
+++ b/arch/parisc/include/asm/sections.h
@@ -2,6 +2,10 @@
 #ifndef _PARISC_SECTIONS_H
 #define _PARISC_SECTIONS_H
 
+#ifdef CONFIG_64BIT
+#define HAVE_DEREFERENCE_FUNCTION_DESCRIPTOR 1
+#endif
+
 /* nothing to see, move along */
 #include <asm-generic/sections.h>
 
@@ -9,8 +13,6 @@ extern char __alt_instructions[], __alt_instructions_end[];
 
 #ifdef CONFIG_64BIT
 
-#define HAVE_DEREFERENCE_FUNCTION_DESCRIPTOR 1
-
 #undef dereference_function_descriptor
 void *dereference_function_descriptor(void *);
 
diff --git a/arch/powerpc/include/asm/sections.h b/arch/powerpc/include/asm/sections.h
index 32e7035863ac..b7f1ba04e756 100644
--- a/arch/powerpc/include/asm/sections.h
+++ b/arch/powerpc/include/asm/sections.h
@@ -8,6 +8,10 @@
 
 #define arch_is_kernel_initmem_freed arch_is_kernel_initmem_freed
 
+#ifdef PPC64_ELF_ABI_v1
+#define HAVE_DEREFERENCE_FUNCTION_DESCRIPTOR 1
+#endif
+
 #include <asm-generic/sections.h>
 
 extern bool init_mem_is_free;
@@ -69,8 +73,6 @@ static inline int overlaps_kernel_text(unsigned long start, unsigned long end)
 
 #ifdef PPC64_ELF_ABI_v1
 
-#define HAVE_DEREFERENCE_FUNCTION_DESCRIPTOR 1
-
 #undef dereference_function_descriptor
 static inline void *dereference_function_descriptor(void *ptr)
 {
diff --git a/include/asm-generic/sections.h b/include/asm-generic/sections.h
index d16302d3eb59..1db5cfd69817 100644
--- a/include/asm-generic/sections.h
+++ b/include/asm-generic/sections.h
@@ -59,7 +59,8 @@ extern char __noinstr_text_start[], __noinstr_text_end[];
 extern __visible const void __nosave_begin, __nosave_end;
 
 /* Function descriptor handling (if any).  Override in asm/sections.h */
-#ifndef dereference_function_descriptor
+#ifdef HAVE_DEREFERENCE_FUNCTION_DESCRIPTOR
+#else
 #define dereference_function_descriptor(p) ((void *)(p))
 #define dereference_kernel_function_descriptor(p) ((void *)(p))
 #endif
-- 
2.31.1
