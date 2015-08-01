From: Guenter Roeck <linux@roeck-us.net>
Date: Sat, 01 Aug 2015 02:36:04 +0000
Subject: [PATCH -next] ia64: Define ioremap_uc and ioremap_wc
Message-Id: <1438396564-23475-1-git-send-email-linux@roeck-us.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>, Paul Gortmaker <paul.gortmaker@windriver.com>, "Luis R. Rodriguez" <mcgrof@suse.com>

Commit 3cc2dac5be3f ("drivers/video/fbdev/atyfb: Replace MTRR UC hole
with strong UC") introduces calls to ioremap_wc and ioremap_uc. This
causes build failures with ia64:allmodconfig. Map the missing
functions to ioremap_nocache.

Fixes: 3cc2dac5be3f ("drivers/video/fbdev/atyfb:
	Replace MTRR UC hole with strong UC")
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>
Cc: Luis R. Rodriguez <mcgrof@suse.com>
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 arch/ia64/include/asm/io.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/arch/ia64/include/asm/io.h b/arch/ia64/include/asm/io.h
index 80a7e34be009..36b65939b6b4 100644
--- a/arch/ia64/include/asm/io.h
+++ b/arch/ia64/include/asm/io.h
@@ -426,6 +426,8 @@ __writeq (unsigned long val, volatile void __iomem *addr)
 
 extern void __iomem * ioremap(unsigned long offset, unsigned long size);
 extern void __iomem * ioremap_nocache (unsigned long offset, unsigned long size);
+#define ioremap_wc	ioremap_nocache
+#define ioremap_uc	ioremap_nocache
 extern void iounmap (volatile void __iomem *addr);
 extern void __iomem * early_ioremap (unsigned long phys_addr, unsigned long size);
 #define early_memremap(phys_addr, size)        early_ioremap(phys_addr, size)
@@ -436,7 +438,6 @@ static inline void __iomem * ioremap_cache (unsigned long phys_addr, unsigned lo
 	return ioremap(phys_addr, size);
 }
 
-
 /*
  * String version of IO memory access ops:
  */
-- 
2.1.4

