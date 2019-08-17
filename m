From: Christoph Hellwig <hch@lst.de>
Date: Sat, 17 Aug 2019 07:32:39 +0000
Subject: [PATCH 12/26] x86: clean up ioremap
Message-Id: <20190817073253.27819-13-hch@lst.de>
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
 arch/x86/include/asm/io.h | 8 ++------
 arch/x86/mm/ioremap.c     | 8 ++++----
 arch/x86/mm/pageattr.c    | 4 ++--
 3 files changed, 8 insertions(+), 12 deletions(-)

diff --git a/arch/x86/include/asm/io.h b/arch/x86/include/asm/io.h
index 6bed97ff6db2..6b5cc41319a7 100644
--- a/arch/x86/include/asm/io.h
+++ b/arch/x86/include/asm/io.h
@@ -180,8 +180,6 @@ static inline unsigned int isa_virt_to_bus(volatile void *address)
  * The default ioremap() behavior is non-cached; if you need something
  * else, you probably want one of the following.
  */
-extern void __iomem *ioremap_nocache(resource_size_t offset, unsigned long size);
-#define ioremap_nocache ioremap_nocache
 extern void __iomem *ioremap_uc(resource_size_t offset, unsigned long size);
 #define ioremap_uc ioremap_uc
 extern void __iomem *ioremap_cache(resource_size_t offset, unsigned long size);
@@ -205,11 +203,9 @@ extern void __iomem *ioremap_encrypted(resource_size_t phys_addr, unsigned long
  * If the area you are trying to map is a PCI BAR you should have a
  * look at pci_iomap().
  */
-static inline void __iomem *ioremap(resource_size_t offset, unsigned long size)
-{
-	return ioremap_nocache(offset, size);
-}
+void __iomem *ioremap(resource_size_t offset, unsigned long size);
 #define ioremap ioremap
+#define ioremap_nocache ioremap
 
 extern void iounmap(volatile void __iomem *addr);
 #define iounmap iounmap
diff --git a/arch/x86/mm/ioremap.c b/arch/x86/mm/ioremap.c
index 63e99f15d7cf..c9e90211bddb 100644
--- a/arch/x86/mm/ioremap.c
+++ b/arch/x86/mm/ioremap.c
@@ -279,11 +279,11 @@ __ioremap_caller(resource_size_t phys_addr, unsigned long size,
 }
 
 /**
- * ioremap_nocache     -   map bus memory into CPU space
+ * ioremap     -   map bus memory into CPU space
  * @phys_addr:    bus address of the memory
  * @size:      size of the resource to map
  *
- * ioremap_nocache performs a platform specific sequence of operations to
+ * ioremap performs a platform specific sequence of operations to
  * make bus memory CPU accessible via the readb/readw/readl/writeb/
  * writew/writel functions and the other mmio helpers. The returned
  * address is not guaranteed to be usable directly as a virtual
@@ -299,7 +299,7 @@ __ioremap_caller(resource_size_t phys_addr, unsigned long size,
  *
  * Must be freed with iounmap.
  */
-void __iomem *ioremap_nocache(resource_size_t phys_addr, unsigned long size)
+void __iomem *ioremap(resource_size_t phys_addr, unsigned long size)
 {
 	/*
 	 * Ideally, this should be:
@@ -314,7 +314,7 @@ void __iomem *ioremap_nocache(resource_size_t phys_addr, unsigned long size)
 	return __ioremap_caller(phys_addr, size, pcm,
 				__builtin_return_address(0), false);
 }
-EXPORT_SYMBOL(ioremap_nocache);
+EXPORT_SYMBOL(ioremap);
 
 /**
  * ioremap_uc     -   map bus memory into CPU space as strongly uncachable
diff --git a/arch/x86/mm/pageattr.c b/arch/x86/mm/pageattr.c
index 6a9a77a403c9..5b7a9231b85b 100644
--- a/arch/x86/mm/pageattr.c
+++ b/arch/x86/mm/pageattr.c
@@ -1774,7 +1774,7 @@ static inline int cpa_clear_pages_array(struct page **pages, int numpages,
 int _set_memory_uc(unsigned long addr, int numpages)
 {
 	/*
-	 * for now UC MINUS. see comments in ioremap_nocache()
+	 * for now UC MINUS. see comments in ioremap()
 	 * If you really need strong UC use ioremap_uc(), but note
 	 * that you cannot override IO areas with set_memory_*() as
 	 * these helpers cannot work with IO memory.
@@ -1789,7 +1789,7 @@ int set_memory_uc(unsigned long addr, int numpages)
 	int ret;
 
 	/*
-	 * for now UC MINUS. see comments in ioremap_nocache()
+	 * for now UC MINUS. see comments in ioremap()
 	 */
 	ret = reserve_memtype(__pa(addr), __pa(addr) + numpages * PAGE_SIZE,
 			      _PAGE_CACHE_MODE_UC_MINUS, NULL);
-- 
2.20.1
