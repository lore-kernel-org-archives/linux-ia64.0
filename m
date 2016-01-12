From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Tue, 12 Jan 2016 13:22:45 +0000
Subject: [PATCH v2 1/2] ia64: split off early_ioremap() declarations into asm/early_ioremap.h
Message-Id: <1452604966-9905-1-git-send-email-ard.biesheuvel@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, linux-efi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, matt-mF/unelCI9GS6iBeEJttW/XRex20P6io@public.gmane.org, fenghua.yu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
Cc: will.deacon-5wv7dgnIgG8@public.gmane.org, Ard Biesheuvel <ard.biesheuvel-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>

Unlike x86, arm64 and ARM, ia64 does not declare its implementations
of early_ioremap/early_iounmap/early_memremap/early_memunmap in a header
file called <asm/early_ioremap.h>

This complicates the use of these functions in generic code, since the
header cannot be included directly, and we have to rely on transitive
includes, which is fragile.

So create a <asm/early_ioremap.h> for ia64, and move the existing
definitions into it.

Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
---
 arch/ia64/include/asm/early_ioremap.h | 10 ++++++++++
 arch/ia64/include/asm/io.h            |  5 +----
 2 files changed, 11 insertions(+), 4 deletions(-)
 create mode 100644 arch/ia64/include/asm/early_ioremap.h

diff --git a/arch/ia64/include/asm/early_ioremap.h b/arch/ia64/include/asm/early_ioremap.h
new file mode 100644
index 000000000000..eec9e1d1b833
--- /dev/null
+++ b/arch/ia64/include/asm/early_ioremap.h
@@ -0,0 +1,10 @@
+#ifndef _ASM_IA64_EARLY_IOREMAP_H
+#define _ASM_IA64_EARLY_IOREMAP_H
+
+extern void __iomem * early_ioremap (unsigned long phys_addr, unsigned long size);
+#define early_memremap(phys_addr, size)        early_ioremap(phys_addr, size)
+
+extern void early_iounmap (volatile void __iomem *addr, unsigned long size);
+#define early_memunmap(addr, size)             early_iounmap(addr, size)
+
+#endif
diff --git a/arch/ia64/include/asm/io.h b/arch/ia64/include/asm/io.h
index 9041bbe2b7b4..a865d2a04f75 100644
--- a/arch/ia64/include/asm/io.h
+++ b/arch/ia64/include/asm/io.h
@@ -20,6 +20,7 @@
  */
 
 #include <asm/unaligned.h>
+#include <asm/early_ioremap.h>
 
 /* We don't use IO slowdowns on the ia64, but.. */
 #define __SLOW_DOWN_IO	do { } while (0)
@@ -427,10 +428,6 @@ __writeq (unsigned long val, volatile void __iomem *addr)
 extern void __iomem * ioremap(unsigned long offset, unsigned long size);
 extern void __iomem * ioremap_nocache (unsigned long offset, unsigned long size);
 extern void iounmap (volatile void __iomem *addr);
-extern void __iomem * early_ioremap (unsigned long phys_addr, unsigned long size);
-#define early_memremap(phys_addr, size)        early_ioremap(phys_addr, size)
-extern void early_iounmap (volatile void __iomem *addr, unsigned long size);
-#define early_memunmap(addr, size)             early_iounmap(addr, size)
 static inline void __iomem * ioremap_cache (unsigned long phys_addr, unsigned long size)
 {
 	return ioremap(phys_addr, size);
-- 
2.5.0

