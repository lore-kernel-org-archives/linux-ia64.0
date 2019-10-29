From: Christoph Hellwig <hch@lst.de>
Date: Tue, 29 Oct 2019 06:48:30 +0000
Subject: [PATCH 17/21] lib: provide a simple generic ioremap implementation
Message-Id: <20191029064834.23438-18-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191029064834.23438-1-hch@lst.de>
In-Reply-To: <20191029064834.23438-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>, Guo Ren <guoren@kernel.org>, Michal Simek <monstr@monstr.eu>, Greentime Hu <green.hu@gmail.com>, Vincent Chen <deanbo422@gmail.com>, Guan Xuetao <gxt@pku.edu.cn>, x86@kernel.org
Cc: linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, nios2-dev@lists.rocketboards.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-mtd@lists.infradead.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

A lot of architectures reuse the same simple ioremap implementation, so
start lifting the most simple variant to lib/ioremap.c.  It provides
ioremap_prot and iounmap, plus a default ioremap that uses prot_noncached,
although that can be overridden by asm/io.h.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 include/asm-generic/io.h | 20 ++++++++++++++++----
 lib/Kconfig              |  3 +++
 lib/ioremap.c            | 39 +++++++++++++++++++++++++++++++++++++++
 3 files changed, 58 insertions(+), 4 deletions(-)

diff --git a/include/asm-generic/io.h b/include/asm-generic/io.h
index 4e45e1cb6560..4a661fdd1937 100644
--- a/include/asm-generic/io.h
+++ b/include/asm-generic/io.h
@@ -923,9 +923,10 @@ static inline void *phys_to_virt(unsigned long address)
  * DOC: ioremap() and ioremap_*() variants
  *
  * Architectures with an MMU are expected to provide ioremap() and iounmap()
- * themselves.  For NOMMU architectures we provide a default nop-op
- * implementation that expect that the physical address used for MMIO are
- * already marked as uncached, and can be used as kernel virtual addresses.
+ * themselves or rely on GENERIC_IOREMAP.  For NOMMU architectures we provide
+ * a default nop-op implementation that expect that the physical address used
+ * for MMIO are already marked as uncached, and can be used as kernel virtual
+ * addresses.
  *
  * ioremap_wc() and ioremap_wt() can provide more relaxed caching attributes
  * for specific drivers if the architecture choses to implement them.  If they
@@ -946,7 +947,18 @@ static inline void iounmap(void __iomem *addr)
 {
 }
 #endif
-#endif /* CONFIG_MMU */
+#elif defined(CONFIG_GENERIC_IOREMAP)
+#include <asm/pgtable.h>
+
+void __iomem *ioremap_prot(phys_addr_t addr, size_t size, unsigned long prot);
+void iounmap(volatile void __iomem *addr);
+
+static inline void __iomem *ioremap(phys_addr_t addr, size_t size)
+{
+	/* _PAGE_IOREMAP needs to be supplied by the architecture */
+	return ioremap_prot(addr, size, _PAGE_IOREMAP);
+}
+#endif /* !CONFIG_MMU || CONFIG_GENERIC_IOREMAP */
 
 #ifndef ioremap_nocache
 #define ioremap_nocache ioremap
diff --git a/lib/Kconfig b/lib/Kconfig
index 183f92a297ca..afc78aaf2b25 100644
--- a/lib/Kconfig
+++ b/lib/Kconfig
@@ -638,6 +638,9 @@ config STRING_SELFTEST
 
 endmenu
 
+config GENERIC_IOREMAP
+	bool
+
 config GENERIC_LIB_ASHLDI3
 	bool
 
diff --git a/lib/ioremap.c b/lib/ioremap.c
index 0a2ffadc6d71..3f0e18543de8 100644
--- a/lib/ioremap.c
+++ b/lib/ioremap.c
@@ -231,3 +231,42 @@ int ioremap_page_range(unsigned long addr,
 
 	return err;
 }
+
+#ifdef CONFIG_GENERIC_IOREMAP
+void __iomem *ioremap_prot(phys_addr_t addr, size_t size, unsigned long prot)
+{
+	unsigned long offset, vaddr;
+	phys_addr_t last_addr;
+	struct vm_struct *area;
+
+	/* Disallow wrap-around or zero size */
+	last_addr = addr + size - 1;
+	if (!size || last_addr < addr)
+		return NULL;
+
+	/* Page-align mappings */
+	offset = addr & (~PAGE_MASK);
+	addr -= offset;
+	size = PAGE_ALIGN(size + offset);
+
+	area = get_vm_area_caller(size, VM_IOREMAP,
+			__builtin_return_address(0));
+	if (!area)
+		return NULL;
+	vaddr = (unsigned long)area->addr;
+
+	if (ioremap_page_range(vaddr, vaddr + size, addr, __pgprot(prot))) {
+		free_vm_area(area);
+		return NULL;
+	}
+
+	return (void __iomem *)(vaddr + offset);
+}
+EXPORT_SYMBOL(ioremap_prot);
+
+void iounmap(volatile void __iomem *addr)
+{
+	vunmap((void *)((unsigned long)addr & PAGE_MASK));
+}
+EXPORT_SYMBOL(iounmap);
+#endif /* CONFIG_GENERIC_IOREMAP */
-- 
2.20.1
