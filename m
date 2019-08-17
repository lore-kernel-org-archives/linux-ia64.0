From: Christoph Hellwig <hch@lst.de>
Date: Sat, 17 Aug 2019 07:32:35 +0000
Subject: [PATCH 08/26] m68k: simplify ioremap_nocache
Message-Id: <20190817073253.27819-9-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190817073253.27819-1-hch@lst.de>
In-Reply-To: <20190817073253.27819-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>, Guo Ren <guoren@kernel.org>, Michal Simek <monstr@monstr.eu>, Greentime Hu <green.hu@gmail.com>, Vincent Chen <deanbo422@gmail.com>, Guan Xuetao <gxt@pku.edu.cn>, x86@kernel.org
Cc: linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, nios2-dev@lists.rocketboards.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-mtd@lists.infradead.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

Just define ioremap_nocache to ioremap instead of duplicating the
inline.  Also defined ioremap_uc in terms of ioremap instead of
the using a double indirection.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/m68k/include/asm/kmap.h | 10 ++--------
 1 file changed, 2 insertions(+), 8 deletions(-)

diff --git a/arch/m68k/include/asm/kmap.h b/arch/m68k/include/asm/kmap.h
index 03d904fe6087..421b6c9c769d 100644
--- a/arch/m68k/include/asm/kmap.h
+++ b/arch/m68k/include/asm/kmap.h
@@ -28,14 +28,8 @@ static inline void __iomem *ioremap(unsigned long physaddr, unsigned long size)
 	return __ioremap(physaddr, size, IOMAP_NOCACHE_SER);
 }
 
-#define ioremap_nocache ioremap_nocache
-static inline void __iomem *ioremap_nocache(unsigned long physaddr,
-					    unsigned long size)
-{
-	return __ioremap(physaddr, size, IOMAP_NOCACHE_SER);
-}
-
-#define ioremap_uc ioremap_nocache
+#define ioremap_nocache ioremap
+#define ioremap_uc ioremap
 #define ioremap_wt ioremap_wt
 static inline void __iomem *ioremap_wt(unsigned long physaddr,
 				       unsigned long size)
-- 
2.20.1
