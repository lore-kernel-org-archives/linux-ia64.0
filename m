From: Christophe Leroy <christophe.leroy@csgroup.eu>
Date: Tue, 15 Feb 2022 12:40:57 +0000
Subject: [PATCH v4 02/13] powerpc: Move and rename func_descr_t
Message-Id: <529b2ba1d001e8f628ef0d30e8044c9b3d0a4921.1644928018.git.christophe.leroy@csgroup.eu>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1644928018.git.christophe.leroy@csgroup.eu>
In-Reply-To: <cover.1644928018.git.christophe.leroy@csgroup.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, Arnd Bergmann <arnd@arndb.de>, Kees Cook <keescook@chromium.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Christophe Leroy <christophe.leroy@csgroup.eu>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Nicholas Piggin <npiggin@gmail.com>

There are three architectures with function descriptors, try to
have common names for the address they contain in order to
refactor some functions into generic functions later.

powerpc has 'entry'
ia64 has 'ip'
parisc has 'addr'

Vote for 'addr' and update 'func_descr_t' accordingly.

Move it in asm/elf.h to have it at the same place on all
three architectures, remove the typedef which hides its real
type, and change it to a smoother name 'struct func_desc'.

Signed-off-by: Christophe Leroy <christophe.leroy@csgroup.eu>
Reviewed-by: Nicholas Piggin <npiggin@gmail.com>
Reviewed-by: Kees Cook <keescook@chromium.org>
---
 arch/powerpc/include/asm/code-patching.h | 2 +-
 arch/powerpc/include/asm/elf.h           | 6 ++++++
 arch/powerpc/include/asm/types.h         | 6 ------
 arch/powerpc/kernel/signal_64.c          | 8 ++++----
 4 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/arch/powerpc/include/asm/code-patching.h b/arch/powerpc/include/asm/code-patching.h
index e26080539c31..409483b2d0ce 100644
--- a/arch/powerpc/include/asm/code-patching.h
+++ b/arch/powerpc/include/asm/code-patching.h
@@ -118,7 +118,7 @@ static inline unsigned long ppc_function_entry(void *func)
 	 * function's descriptor. The first entry in the descriptor is the
 	 * address of the function text.
 	 */
-	return ((func_descr_t *)func)->entry;
+	return ((struct func_desc *)func)->addr;
 #else
 	return (unsigned long)func;
 #endif
diff --git a/arch/powerpc/include/asm/elf.h b/arch/powerpc/include/asm/elf.h
index b8425e3cfd81..971589a21bc0 100644
--- a/arch/powerpc/include/asm/elf.h
+++ b/arch/powerpc/include/asm/elf.h
@@ -176,4 +176,10 @@ do {									\
 /* Relocate the kernel image to @final_address */
 void relocate(unsigned long final_address);
 
+struct func_desc {
+	unsigned long addr;
+	unsigned long toc;
+	unsigned long env;
+};
+
 #endif /* _ASM_POWERPC_ELF_H */
diff --git a/arch/powerpc/include/asm/types.h b/arch/powerpc/include/asm/types.h
index f1630c553efe..97da77bc48c9 100644
--- a/arch/powerpc/include/asm/types.h
+++ b/arch/powerpc/include/asm/types.h
@@ -23,12 +23,6 @@
 
 typedef __vector128 vector128;
 
-typedef struct {
-	unsigned long entry;
-	unsigned long toc;
-	unsigned long env;
-} func_descr_t;
-
 #endif /* __ASSEMBLY__ */
 
 #endif /* _ASM_POWERPC_TYPES_H */
diff --git a/arch/powerpc/kernel/signal_64.c b/arch/powerpc/kernel/signal_64.c
index d1e1fc0acbea..73d483b07ff3 100644
--- a/arch/powerpc/kernel/signal_64.c
+++ b/arch/powerpc/kernel/signal_64.c
@@ -936,11 +936,11 @@ int handle_rt_signal64(struct ksignal *ksig, sigset_t *set,
 		 * descriptor is the entry address of signal and the second
 		 * entry is the TOC value we need to use.
 		 */
-		func_descr_t __user *funct_desc_ptr -			(func_descr_t __user *) ksig->ka.sa.sa_handler;
+		struct func_desc __user *ptr +			(struct func_desc __user *)ksig->ka.sa.sa_handler;
 
-		err |= get_user(regs->ctr, &funct_desc_ptr->entry);
-		err |= get_user(regs->gpr[2], &funct_desc_ptr->toc);
+		err |= get_user(regs->ctr, &ptr->addr);
+		err |= get_user(regs->gpr[2], &ptr->toc);
 	}
 
 	/* enter the signal handler in native-endian mode */
-- 
2.34.1
