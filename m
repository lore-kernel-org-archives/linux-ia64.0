From: Christoph Hellwig <hch@lst.de>
Date: Thu, 17 Oct 2019 17:45:54 +0000
Subject: [PATCH 21/21] csky: use generic ioremap
Message-Id: <20191017174554.29840-22-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191017174554.29840-1-hch@lst.de>
In-Reply-To: <20191017174554.29840-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>, Guo Ren <guoren@kernel.org>, Michal Simek <monstr@monstr.eu>, Greentime Hu <green.hu@gmail.com>, Vincent Chen <deanbo422@gmail.com>, Guan Xuetao <gxt@pku.edu.cn>, x86@kernel.org
Cc: linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, nios2-dev@lists.rocketboards.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-mtd@lists.infradead.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

Use the generic ioremap_prot and iounmap helpers.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/csky/Kconfig               |  1 +
 arch/csky/include/asm/io.h      |  8 +++---
 arch/csky/include/asm/pgtable.h |  4 +++
 arch/csky/mm/ioremap.c          | 45 ---------------------------------
 4 files changed, 8 insertions(+), 50 deletions(-)

diff --git a/arch/csky/Kconfig b/arch/csky/Kconfig
index 3973847b5f42..da09c884cc30 100644
--- a/arch/csky/Kconfig
+++ b/arch/csky/Kconfig
@@ -17,6 +17,7 @@ config CSKY
 	select IRQ_DOMAIN
 	select HANDLE_DOMAIN_IRQ
 	select DW_APB_TIMER_OF
+	select GENERIC_IOREMAP
 	select GENERIC_LIB_ASHLDI3
 	select GENERIC_LIB_ASHRDI3
 	select GENERIC_LIB_LSHRDI3
diff --git a/arch/csky/include/asm/io.h b/arch/csky/include/asm/io.h
index f572605d5ad5..332f51bc68fb 100644
--- a/arch/csky/include/asm/io.h
+++ b/arch/csky/include/asm/io.h
@@ -36,11 +36,9 @@
 /*
  * I/O memory mapping functions.
  */
-extern void __iomem *__ioremap(phys_addr_t addr, size_t size, pgprot_t prot);
-extern void iounmap(void *addr);
-
-#define ioremap(addr, size)		__ioremap((addr), (size), pgprot_noncached(PAGE_KERNEL))
-#define ioremap_wc(addr, size)		__ioremap((addr), (size), pgprot_writecombine(PAGE_KERNEL))
+#define ioremap_wc(addr, size) \
+	ioremap_prot((addr), (size), \
+		(_PAGE_IOREMAP & ~_CACHE_MASK) | _CACHE_UNCACHED)
 
 #include <asm-generic/io.h>
 
diff --git a/arch/csky/include/asm/pgtable.h b/arch/csky/include/asm/pgtable.h
index 7c21985c60dc..4b2a41e15f2e 100644
--- a/arch/csky/include/asm/pgtable.h
+++ b/arch/csky/include/asm/pgtable.h
@@ -86,6 +86,10 @@
 #define PAGE_USERIO	__pgprot(_PAGE_PRESENT | _PAGE_READ | _PAGE_WRITE | \
 				_CACHE_CACHED)
 
+#define _PAGE_IOREMAP \
+	(_PAGE_PRESENT | __READABLE | __WRITEABLE | _PAGE_GLOBAL | \
+	 _CACHE_UNCACHED | _PAGE_SO)
+
 #define __P000	PAGE_NONE
 #define __P001	PAGE_READONLY
 #define __P010	PAGE_COPY
diff --git a/arch/csky/mm/ioremap.c b/arch/csky/mm/ioremap.c
index ae78256a56fd..70c8268d3b2b 100644
--- a/arch/csky/mm/ioremap.c
+++ b/arch/csky/mm/ioremap.c
@@ -3,53 +3,8 @@
 
 #include <linux/export.h>
 #include <linux/mm.h>
-#include <linux/vmalloc.h>
 #include <linux/io.h>
 
-#include <asm/pgtable.h>
-
-static void __iomem *__ioremap_caller(phys_addr_t addr, size_t size,
-				      pgprot_t prot, void *caller)
-{
-	phys_addr_t last_addr;
-	unsigned long offset, vaddr;
-	struct vm_struct *area;
-
-	last_addr = addr + size - 1;
-	if (!size || last_addr < addr)
-		return NULL;
-
-	offset = addr & (~PAGE_MASK);
-	addr &= PAGE_MASK;
-	size = PAGE_ALIGN(size + offset);
-
-	area = get_vm_area_caller(size, VM_IOREMAP, caller);
-	if (!area)
-		return NULL;
-
-	vaddr = (unsigned long)area->addr;
-
-	if (ioremap_page_range(vaddr, vaddr + size, addr, prot)) {
-		free_vm_area(area);
-		return NULL;
-	}
-
-	return (void __iomem *)(vaddr + offset);
-}
-
-void __iomem *__ioremap(phys_addr_t phys_addr, size_t size, pgprot_t prot)
-{
-	return __ioremap_caller(phys_addr, size, prot,
-				__builtin_return_address(0));
-}
-EXPORT_SYMBOL(__ioremap);
-
-void iounmap(void __iomem *addr)
-{
-	vunmap((void *)((unsigned long)addr & PAGE_MASK));
-}
-EXPORT_SYMBOL(iounmap);
-
 pgprot_t phys_mem_access_prot(struct file *file, unsigned long pfn,
 			      unsigned long size, pgprot_t vma_prot)
 {
-- 
2.20.1
