From: Christophe Leroy <christophe.leroy@csgroup.eu>
Date: Sun, 17 Oct 2021 12:38:15 +0000
Subject: [PATCH v3 02/12] powerpc: Use 'struct func_desc' instead of 'struct ppc64_opd_entry'
Message-Id: <4a912da3c89569bf5bff897d2588538e74198f35.1634457599.git.christophe.leroy@csgroup.eu>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1634457599.git.christophe.leroy@csgroup.eu>
In-Reply-To: <cover.1634457599.git.christophe.leroy@csgroup.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, Arnd Bergmann <arnd@arndb.de>, Kees Cook <keescook@chromium.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Christophe Leroy <christophe.leroy@csgroup.eu>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Daniel Axtens <dja@axtens.net>, Nicholas Piggin <npiggin@gmail.com>

'struct ppc64_opd_entry' is somehow redundant with 'struct func_desc',
the later is more correct/complete as it includes the third
field which is unused.

So use 'struct func_desc' instead of 'struct ppc64_opd_entry'

Reviewed-by: Kees Cook <keescook@chromium.org>
Reviewed-by: Daniel Axtens <dja@axtens.net>
Reviewed-by: Nicholas Piggin <npiggin@gmail.com>
Signed-off-by: Christophe Leroy <christophe.leroy@csgroup.eu>
---
 arch/powerpc/include/asm/sections.h |  4 ++--
 arch/powerpc/kernel/module_64.c     | 10 +++++-----
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/arch/powerpc/include/asm/sections.h b/arch/powerpc/include/asm/sections.h
index 6e4af4492a14..abd2e5213197 100644
--- a/arch/powerpc/include/asm/sections.h
+++ b/arch/powerpc/include/asm/sections.h
@@ -74,10 +74,10 @@ static inline int overlaps_kernel_text(unsigned long start, unsigned long end)
 #undef dereference_function_descriptor
 static inline void *dereference_function_descriptor(void *ptr)
 {
-	struct ppc64_opd_entry *desc = ptr;
+	struct func_desc *desc = ptr;
 	void *p;
 
-	if (!get_kernel_nofault(p, (void *)&desc->funcaddr))
+	if (!get_kernel_nofault(p, (void *)&desc->addr))
 		ptr = p;
 	return ptr;
 }
diff --git a/arch/powerpc/kernel/module_64.c b/arch/powerpc/kernel/module_64.c
index 6baa676e7cb6..a89da0ee25e2 100644
--- a/arch/powerpc/kernel/module_64.c
+++ b/arch/powerpc/kernel/module_64.c
@@ -64,19 +64,19 @@ static unsigned int local_entry_offset(const Elf64_Sym *sym)
 #else
 
 /* An address is address of the OPD entry, which contains address of fn. */
-typedef struct ppc64_opd_entry func_desc_t;
+typedef struct func_desc func_desc_t;
 
 static func_desc_t func_desc(unsigned long addr)
 {
-	return *(struct ppc64_opd_entry *)addr;
+	return *(struct func_desc *)addr;
 }
 static unsigned long func_addr(unsigned long addr)
 {
-	return func_desc(addr).funcaddr;
+	return func_desc(addr).addr;
 }
 static unsigned long stub_func_addr(func_desc_t func)
 {
-	return func.funcaddr;
+	return func.addr;
 }
 static unsigned int local_entry_offset(const Elf64_Sym *sym)
 {
@@ -187,7 +187,7 @@ static int relacmp(const void *_x, const void *_y)
 static unsigned long get_stubs_size(const Elf64_Ehdr *hdr,
 				    const Elf64_Shdr *sechdrs)
 {
-	/* One extra reloc so it's always 0-funcaddr terminated */
+	/* One extra reloc so it's always 0-addr terminated */
 	unsigned long relocs = 1;
 	unsigned i;
 
-- 
2.31.1
