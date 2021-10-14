From: Christophe Leroy <christophe.leroy@csgroup.eu>
Date: Thu, 14 Oct 2021 05:49:52 +0000
Subject: [PATCH v2 03/13] powerpc: Remove func_descr_t
Message-Id: <16eef6afbf7322d0c07760ebf827b8f9f50f7c6e.1634190022.git.christophe.leroy@csgroup.eu>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1634190022.git.christophe.leroy@csgroup.eu>
In-Reply-To: <cover.1634190022.git.christophe.leroy@csgroup.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, Arnd Bergmann <arnd@arndb.de>, Kees Cook <keescook@chromium.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Christophe Leroy <christophe.leroy@csgroup.eu>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

'func_descr_t' is redundant with 'struct ppc64_opd_entry'

Remove it.

Signed-off-by: Christophe Leroy <christophe.leroy@csgroup.eu>
---
 arch/powerpc/include/asm/code-patching.h | 2 +-
 arch/powerpc/include/asm/types.h         | 6 ------
 arch/powerpc/kernel/signal_64.c          | 8 ++++----
 3 files changed, 5 insertions(+), 11 deletions(-)

diff --git a/arch/powerpc/include/asm/code-patching.h b/arch/powerpc/include/asm/code-patching.h
index 4ba834599c4d..f3445188d319 100644
--- a/arch/powerpc/include/asm/code-patching.h
+++ b/arch/powerpc/include/asm/code-patching.h
@@ -110,7 +110,7 @@ static inline unsigned long ppc_function_entry(void *func)
 	 * function's descriptor. The first entry in the descriptor is the
 	 * address of the function text.
 	 */
-	return ((func_descr_t *)func)->entry;
+	return ((struct ppc64_opd_entry *)func)->addr;
 #else
 	return (unsigned long)func;
 #endif
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
index 1831bba0582e..63ddbe7b108c 100644
--- a/arch/powerpc/kernel/signal_64.c
+++ b/arch/powerpc/kernel/signal_64.c
@@ -933,11 +933,11 @@ int handle_rt_signal64(struct ksignal *ksig, sigset_t *set,
 		 * descriptor is the entry address of signal and the second
 		 * entry is the TOC value we need to use.
 		 */
-		func_descr_t __user *funct_desc_ptr -			(func_descr_t __user *) ksig->ka.sa.sa_handler;
+		struct ppc64_opd_entry __user *funct_desc_ptr +			(struct ppc64_opd_entry __user *)ksig->ka.sa.sa_handler;
 
-		err |= get_user(regs->ctr, &funct_desc_ptr->entry);
-		err |= get_user(regs->gpr[2], &funct_desc_ptr->toc);
+		err |= get_user(regs->ctr, &funct_desc_ptr->addr);
+		err |= get_user(regs->gpr[2], &funct_desc_ptr->r2);
 	}
 
 	/* enter the signal handler in native-endian mode */
-- 
2.31.1
