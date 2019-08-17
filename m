From: Christoph Hellwig <hch@lst.de>
Date: Sat, 17 Aug 2019 07:32:29 +0000
Subject: [PATCH 02/26] arm, unicore32: remove ioremap_cached
Message-Id: <20190817073253.27819-3-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190817073253.27819-1-hch@lst.de>
In-Reply-To: <20190817073253.27819-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>, Guo Ren <guoren@kernel.org>, Michal Simek <monstr@monstr.eu>, Greentime Hu <green.hu@gmail.com>, Vincent Chen <deanbo422@gmail.com>, Guan Xuetao <gxt@pku.edu.cn>, x86@kernel.org
Cc: linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-sh@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-mips@vger.kernel.org, linux-kernel@vger.kernel.org, linux-m68k@lists.linux-m68k.org, openrisc@lists.librecores.org, linux-mtd@lists.infradead.org, linux-alpha@vger.kernel.org, sparclinux@vger.kernel.org, nios2-dev@lists.rocketboards.org, linux-riscv@lists.infradead.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org

No users of ioremap_cached are left, remove it.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/arm/include/asm/io.h       | 6 ------
 arch/arm/mm/ioremap.c           | 4 ----
 arch/arm/mm/mmu.c               | 2 +-
 arch/arm/mm/nommu.c             | 4 ----
 arch/unicore32/include/asm/io.h | 4 +---
 arch/unicore32/mm/ioremap.c     | 8 --------
 6 files changed, 2 insertions(+), 26 deletions(-)

diff --git a/arch/arm/include/asm/io.h b/arch/arm/include/asm/io.h
index 7a0596fcb2e7..924f9dd502ed 100644
--- a/arch/arm/include/asm/io.h
+++ b/arch/arm/include/asm/io.h
@@ -400,12 +400,6 @@ void __iomem *ioremap(resource_size_t res_cookie, size_t size);
 void __iomem *ioremap_cache(resource_size_t res_cookie, size_t size);
 #define ioremap_cache ioremap_cache
 
-/*
- * Do not use ioremap_cached in new code. Provided for the benefit of
- * the pxa2xx-flash MTD driver only.
- */
-void __iomem *ioremap_cached(resource_size_t res_cookie, size_t size);
-
 void __iomem *ioremap_wc(resource_size_t res_cookie, size_t size);
 #define ioremap_wc ioremap_wc
 #define ioremap_wt ioremap_wc
diff --git a/arch/arm/mm/ioremap.c b/arch/arm/mm/ioremap.c
index d42b93316183..72286f9a4d30 100644
--- a/arch/arm/mm/ioremap.c
+++ b/arch/arm/mm/ioremap.c
@@ -382,15 +382,11 @@ void __iomem *ioremap(resource_size_t res_cookie, size_t size)
 EXPORT_SYMBOL(ioremap);
 
 void __iomem *ioremap_cache(resource_size_t res_cookie, size_t size)
-	__alias(ioremap_cached);
-
-void __iomem *ioremap_cached(resource_size_t res_cookie, size_t size)
 {
 	return arch_ioremap_caller(res_cookie, size, MT_DEVICE_CACHED,
 				   __builtin_return_address(0));
 }
 EXPORT_SYMBOL(ioremap_cache);
-EXPORT_SYMBOL(ioremap_cached);
 
 void __iomem *ioremap_wc(resource_size_t res_cookie, size_t size)
 {
diff --git a/arch/arm/mm/mmu.c b/arch/arm/mm/mmu.c
index d9a0038774a6..ed08afc3f5e5 100644
--- a/arch/arm/mm/mmu.c
+++ b/arch/arm/mm/mmu.c
@@ -259,7 +259,7 @@ static struct mem_type mem_types[] __ro_after_init = {
 		.prot_sect	= PROT_SECT_DEVICE,
 		.domain		= DOMAIN_IO,
 	},
-	[MT_DEVICE_CACHED] = {	  /* ioremap_cached */
+	[MT_DEVICE_CACHED] = {	  /* ioremap_cache */
 		.prot_pte	= PROT_PTE_DEVICE | L_PTE_MT_DEV_CACHED,
 		.prot_l1	= PMD_TYPE_TABLE,
 		.prot_sect	= PROT_SECT_DEVICE | PMD_SECT_WB,
diff --git a/arch/arm/mm/nommu.c b/arch/arm/mm/nommu.c
index 24ecf8d30a1e..8b3d7191e2b8 100644
--- a/arch/arm/mm/nommu.c
+++ b/arch/arm/mm/nommu.c
@@ -206,15 +206,11 @@ void __iomem *ioremap(resource_size_t res_cookie, size_t size)
 EXPORT_SYMBOL(ioremap);
 
 void __iomem *ioremap_cache(resource_size_t res_cookie, size_t size)
-	__alias(ioremap_cached);
-
-void __iomem *ioremap_cached(resource_size_t res_cookie, size_t size)
 {
 	return __arm_ioremap_caller(res_cookie, size, MT_DEVICE_CACHED,
 				    __builtin_return_address(0));
 }
 EXPORT_SYMBOL(ioremap_cache);
-EXPORT_SYMBOL(ioremap_cached);
 
 void __iomem *ioremap_wc(resource_size_t res_cookie, size_t size)
 {
diff --git a/arch/unicore32/include/asm/io.h b/arch/unicore32/include/asm/io.h
index c71aa4b95996..4b460e01acfa 100644
--- a/arch/unicore32/include/asm/io.h
+++ b/arch/unicore32/include/asm/io.h
@@ -18,10 +18,9 @@
 #include <asm-generic/io.h>
 
 /*
- * __uc32_ioremap and __uc32_ioremap_cached takes CPU physical address.
+ * __uc32_ioremap takes CPU physical address.
  */
 extern void __iomem *__uc32_ioremap(unsigned long, size_t);
-extern void __iomem *__uc32_ioremap_cached(unsigned long, size_t);
 extern void __uc32_iounmap(volatile void __iomem *addr);
 
 /*
@@ -32,7 +31,6 @@ extern void __uc32_iounmap(volatile void __iomem *addr);
  *
  */
 #define ioremap(cookie, size)		__uc32_ioremap(cookie, size)
-#define ioremap_cached(cookie, size)	__uc32_ioremap_cached(cookie, size)
 #define ioremap_nocache(cookie, size)	__uc32_ioremap(cookie, size)
 #define iounmap(cookie)			__uc32_iounmap(cookie)
 
diff --git a/arch/unicore32/mm/ioremap.c b/arch/unicore32/mm/ioremap.c
index cf6d656f240c..46a64bd6156a 100644
--- a/arch/unicore32/mm/ioremap.c
+++ b/arch/unicore32/mm/ioremap.c
@@ -220,14 +220,6 @@ __uc32_ioremap(unsigned long phys_addr, size_t size)
 }
 EXPORT_SYMBOL(__uc32_ioremap);
 
-void __iomem *
-__uc32_ioremap_cached(unsigned long phys_addr, size_t size)
-{
-	return __uc32_ioremap_caller(phys_addr, size, MT_DEVICE_CACHED,
-			__builtin_return_address(0));
-}
-EXPORT_SYMBOL(__uc32_ioremap_cached);
-
 void __uc32_iounmap(volatile void __iomem *io_addr)
 {
 	void *addr = (void *)(PAGE_MASK & (unsigned long)io_addr);
-- 
2.20.1
