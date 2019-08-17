From: Christoph Hellwig <hch@lst.de>
Date: Sat, 17 Aug 2019 07:32:41 +0000
Subject: [PATCH 14/26] asm-generic: don't provide __ioremap
Message-Id: <20190817073253.27819-15-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190817073253.27819-1-hch@lst.de>
In-Reply-To: <20190817073253.27819-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>, Guo Ren <guoren@kernel.org>, Michal Simek <monstr@monstr.eu>, Greentime Hu <green.hu@gmail.com>, Vincent Chen <deanbo422@gmail.com>, Guan Xuetao <gxt@pku.edu.cn>, x86@kernel.org
Cc: linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, nios2-dev@lists.rocketboards.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-mtd@lists.infradead.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

__ioremap is not a kernel API, but used for helpers with differing
semantics in arch code.  We should not provide it in as-generic.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 include/asm-generic/io.h | 9 ---------
 1 file changed, 9 deletions(-)

diff --git a/include/asm-generic/io.h b/include/asm-generic/io.h
index b83e2802c969..d02806513670 100644
--- a/include/asm-generic/io.h
+++ b/include/asm-generic/io.h
@@ -963,15 +963,6 @@ static inline void __iomem *ioremap(phys_addr_t offset, size_t size)
 }
 #endif
 
-#ifndef __ioremap
-#define __ioremap __ioremap
-static inline void __iomem *__ioremap(phys_addr_t offset, size_t size,
-				      unsigned long flags)
-{
-	return ioremap(offset, size);
-}
-#endif
-
 #ifndef iounmap
 #define iounmap iounmap
 
-- 
2.20.1
