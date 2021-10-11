From: Christophe Leroy <christophe.leroy@csgroup.eu>
Date: Mon, 11 Oct 2021 15:25:28 +0000
Subject: [PATCH v1 01/10] powerpc: Move 'struct ppc64_opd_entry' back into asm/elf.h
Message-Id: <8ff3ec195d695033b652e9971fba2dc5528f7151.1633964380.git.christophe.leroy@csgroup.eu>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1633964380.git.christophe.leroy@csgroup.eu>
In-Reply-To: <cover.1633964380.git.christophe.leroy@csgroup.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, Arnd Bergmann <arnd@arndb.de>, Kees Cook <keescook@chromium.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Christophe Leroy <christophe.leroy@csgroup.eu>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

'struct ppc64_opd_entry' doesn't belong to uapi/asm/elf.h

It was initially in module_64.c and commit 2d291e902791 ("Fix compile
failure with non modular builds") moved it into asm/elf.h

But it was by mistake added outside of __KERNEL__ section,
therefore commit c3617f72036c ("UAPI: (Scripted) Disintegrate
arch/powerpc/include/asm") moved it to uapi/asm/elf.h

Move it back into asm/elf.h, this brings it back in line with
IA64 and PARISC architectures.

Fixes: 2d291e902791 ("Fix compile failure with non modular builds")
Signed-off-by: Christophe Leroy <christophe.leroy@csgroup.eu>
---
 arch/powerpc/include/asm/elf.h      | 7 +++++++
 arch/powerpc/include/uapi/asm/elf.h | 8 --------
 2 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/arch/powerpc/include/asm/elf.h b/arch/powerpc/include/asm/elf.h
index b8425e3cfd81..64b523848cd7 100644
--- a/arch/powerpc/include/asm/elf.h
+++ b/arch/powerpc/include/asm/elf.h
@@ -176,4 +176,11 @@ do {									\
 /* Relocate the kernel image to @final_address */
 void relocate(unsigned long final_address);
 
+/* There's actually a third entry here, but it's unused */
+struct ppc64_opd_entry
+{
+	unsigned long funcaddr;
+	unsigned long r2;
+};
+
 #endif /* _ASM_POWERPC_ELF_H */
diff --git a/arch/powerpc/include/uapi/asm/elf.h b/arch/powerpc/include/uapi/asm/elf.h
index 860c59291bfc..308857123a08 100644
--- a/arch/powerpc/include/uapi/asm/elf.h
+++ b/arch/powerpc/include/uapi/asm/elf.h
@@ -289,12 +289,4 @@ typedef elf_fpreg_t elf_vsrreghalf_t32[ELF_NVSRHALFREG];
 /* Keep this the last entry.  */
 #define R_PPC64_NUM		253
 
-/* There's actually a third entry here, but it's unused */
-struct ppc64_opd_entry
-{
-	unsigned long funcaddr;
-	unsigned long r2;
-};
-
-
 #endif /* _UAPI_ASM_POWERPC_ELF_H */
-- 
2.31.1
