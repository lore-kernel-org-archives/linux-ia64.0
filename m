From: Christoph Hellwig <hch@lst.de>
Date: Sat, 17 Aug 2019 07:32:40 +0000
Subject: [PATCH 13/26] xtensa: clean up ioremap
Message-Id: <20190817073253.27819-14-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190817073253.27819-1-hch@lst.de>
In-Reply-To: <20190817073253.27819-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>, Guo Ren <guoren@kernel.org>, Michal Simek <monstr@monstr.eu>, Greentime Hu <green.hu@gmail.com>, Vincent Chen <deanbo422@gmail.com>, Guan Xuetao <gxt@pku.edu.cn>, x86@kernel.org
Cc: linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, nios2-dev@lists.rocketboards.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-mtd@lists.infradead.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

Use ioremap as the main implemented function, and defined
ioremap_nocache to it as a deprecated alias.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/xtensa/include/asm/io.h | 14 ++++----------
 1 file changed, 4 insertions(+), 10 deletions(-)

diff --git a/arch/xtensa/include/asm/io.h b/arch/xtensa/include/asm/io.h
index da3e783f896b..ffadc99c8601 100644
--- a/arch/xtensa/include/asm/io.h
+++ b/arch/xtensa/include/asm/io.h
@@ -31,8 +31,7 @@ void xtensa_iounmap(volatile void __iomem *addr);
 /*
  * Return the virtual address for the specified bus memory.
  */
-static inline void __iomem *ioremap_nocache(unsigned long offset,
-		unsigned long size)
+static inline void __iomem *ioremap(unsigned long offset, unsigned long size)
 {
 	if (offset >= XCHAL_KIO_PADDR
 	    && offset - XCHAL_KIO_PADDR < XCHAL_KIO_SIZE)
@@ -51,15 +50,10 @@ static inline void __iomem *ioremap_cache(unsigned long offset,
 		return xtensa_ioremap_cache(offset, size);
 }
 #define ioremap_cache ioremap_cache
-#define ioremap_nocache ioremap_nocache
-
-#define ioremap_wc ioremap_nocache
-#define ioremap_wt ioremap_nocache
 
-static inline void __iomem *ioremap(unsigned long offset, unsigned long size)
-{
-	return ioremap_nocache(offset, size);
-}
+#define ioremap_nocache ioremap
+#define ioremap_wc ioremap
+#define ioremap_wt ioremap
 
 static inline void iounmap(volatile void __iomem *addr)
 {
-- 
2.20.1
