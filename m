From: Christoph Hellwig <hch@lst.de>
Date: Thu, 17 Oct 2019 17:45:53 +0000
Subject: [PATCH 20/21] csky: remove ioremap_cache
Message-Id: <20191017174554.29840-21-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191017174554.29840-1-hch@lst.de>
In-Reply-To: <20191017174554.29840-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>, Guo Ren <guoren@kernel.org>, Michal Simek <monstr@monstr.eu>, Greentime Hu <green.hu@gmail.com>, Vincent Chen <deanbo422@gmail.com>, Guan Xuetao <gxt@pku.edu.cn>, x86@kernel.org
Cc: linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, nios2-dev@lists.rocketboards.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-mtd@lists.infradead.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

No driver that can be used on csky uses ioremap_cache, and this
interface has been deprecated in favor of memremap.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/csky/include/asm/io.h | 2 --
 arch/csky/mm/ioremap.c     | 7 -------
 2 files changed, 9 deletions(-)

diff --git a/arch/csky/include/asm/io.h b/arch/csky/include/asm/io.h
index a4b9fb616faa..f572605d5ad5 100644
--- a/arch/csky/include/asm/io.h
+++ b/arch/csky/include/asm/io.h
@@ -36,13 +36,11 @@
 /*
  * I/O memory mapping functions.
  */
-extern void __iomem *ioremap_cache(phys_addr_t addr, size_t size);
 extern void __iomem *__ioremap(phys_addr_t addr, size_t size, pgprot_t prot);
 extern void iounmap(void *addr);
 
 #define ioremap(addr, size)		__ioremap((addr), (size), pgprot_noncached(PAGE_KERNEL))
 #define ioremap_wc(addr, size)		__ioremap((addr), (size), pgprot_writecombine(PAGE_KERNEL))
-#define ioremap_cache			ioremap_cache
 
 #include <asm-generic/io.h>
 
diff --git a/arch/csky/mm/ioremap.c b/arch/csky/mm/ioremap.c
index e13cd3497628..ae78256a56fd 100644
--- a/arch/csky/mm/ioremap.c
+++ b/arch/csky/mm/ioremap.c
@@ -44,13 +44,6 @@ void __iomem *__ioremap(phys_addr_t phys_addr, size_t size, pgprot_t prot)
 }
 EXPORT_SYMBOL(__ioremap);
 
-void __iomem *ioremap_cache(phys_addr_t phys_addr, size_t size)
-{
-	return __ioremap_caller(phys_addr, size, PAGE_KERNEL,
-				__builtin_return_address(0));
-}
-EXPORT_SYMBOL(ioremap_cache);
-
 void iounmap(void __iomem *addr)
 {
 	vunmap((void *)((unsigned long)addr & PAGE_MASK));
-- 
2.20.1
