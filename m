From: Baoquan He <bhe@redhat.com>
Date: Sun, 09 Oct 2022 10:31:09 +0000
Subject: [PATCH v3 06/11] ia64: mm: Convert to GENERIC_IOREMAP
Message-Id: <20221009103114.149036-7-bhe@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20221009103114.149036-1-bhe@redhat.com>
In-Reply-To: <20221009103114.149036-1-bhe@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, hch@infradead.org, agordeev@linux.ibm.com, wangkefeng.wang@huawei.com, christophe.leroy@csgroup.eu, schnelle@linux.ibm.com, David.Laight@ACULAB.COM, shorne@gmail.com, bhe@redhat.com, linux-ia64@vger.kernel.org

By taking GENERIC_IOREMAP method, the generic ioremap_prot() and
iounmap() are visible and available to arch. Arch only needs to
provide implementation of arch_ioremap() or arch_iounmap() if there's
arch specific handling needed in its ioremap() or iounmap(). This
change will simplify implementation by removing duplicated codes with
generic ioremap() and iounmap(), and has the equivalent functioality
as before.

Here add hooks arch_ioremap() and arch_iounmap() for ia64's special
operation when ioremap() and iounmap(), then ioremap_cache() is
converted to use ioremap_prot() from GENERIC_IOREMAP.

The old ioremap_uc() is kept and add its macro definittion.

Signed-off-by: Baoquan He <bhe@redhat.com>
Cc: linux-ia64@vger.kernel.org
---
 arch/ia64/Kconfig          |  1 +
 arch/ia64/include/asm/io.h | 26 ++++++++++++--------
 arch/ia64/mm/ioremap.c     | 50 +++++++++-----------------------------
 3 files changed, 28 insertions(+), 49 deletions(-)

diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 26ac8ea15a9e..1ca18be5dc30 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -45,6 +45,7 @@ config IA64
 	select GENERIC_IRQ_LEGACY
 	select ARCH_HAVE_NMI_SAFE_CMPXCHG
 	select GENERIC_IOMAP
+	select GENERIC_IOREMAP
 	select GENERIC_SMP_IDLE_THREAD
 	select ARCH_TASK_STRUCT_ON_STACK
 	select ARCH_TASK_STRUCT_ALLOCATOR
diff --git a/arch/ia64/include/asm/io.h b/arch/ia64/include/asm/io.h
index ce66dfc0e719..54378cea4b36 100644
--- a/arch/ia64/include/asm/io.h
+++ b/arch/ia64/include/asm/io.h
@@ -247,17 +247,23 @@ static inline void outsl(unsigned long port, const void *src,
 
 # ifdef __KERNEL__
 
-extern void __iomem * ioremap(unsigned long offset, unsigned long size);
-extern void __iomem * ioremap_uc(unsigned long offset, unsigned long size);
-extern void iounmap (volatile void __iomem *addr);
-static inline void __iomem * ioremap_cache (unsigned long phys_addr, unsigned long size)
-{
-	return ioremap(phys_addr, size);
-}
-#define ioremap ioremap
-#define ioremap_cache ioremap_cache
+/*
+ * I/O memory mapping functions.
+ */
+void __iomem *
+arch_ioremap(phys_addr_t *paddr, size_t size, unsigned long *prot_val);
+#define arch_ioremap arch_ioremap
+
+bool arch_iounmap(void __iomem *addr);
+#define arch_iounmap arch_iounmap
+
+#define _PAGE_IOREMAP pgprot_val(PAGE_KERNEL)
+
+#define ioremap_cache(addr, size)  \
+	ioremap_prot((addr), (size), pgprot_val(PAGE_KERNEL))
+
+void __iomem *ioremap_uc(unsigned long offset, unsigned long size);
 #define ioremap_uc ioremap_uc
-#define iounmap iounmap
 
 /*
  * String version of IO memory access ops:
diff --git a/arch/ia64/mm/ioremap.c b/arch/ia64/mm/ioremap.c
index 55fd3eb753ff..a290c7dc7f1e 100644
--- a/arch/ia64/mm/ioremap.c
+++ b/arch/ia64/mm/ioremap.c
@@ -30,15 +30,12 @@ early_ioremap (unsigned long phys_addr, unsigned long size)
 }
 
 void __iomem *
-ioremap (unsigned long phys_addr, unsigned long size)
+arch_ioremap(phys_addr_t *paddr, size_t size, unsigned long *prot_val)
 {
-	void __iomem *addr;
-	struct vm_struct *area;
-	unsigned long offset;
-	pgprot_t prot;
-	u64 attr;
+	phys_addr_t phys_addr = *paddr;
 	unsigned long gran_base, gran_size;
 	unsigned long page_base;
+	u64 attr;
 
 	/*
 	 * For things in kern_memmap, we must use the same attribute
@@ -69,35 +66,18 @@ ioremap (unsigned long phys_addr, unsigned long size)
 	page_base = phys_addr & PAGE_MASK;
 	size = PAGE_ALIGN(phys_addr + size) - page_base;
 	if (efi_mem_attribute(page_base, size) & EFI_MEMORY_WB) {
-		prot = PAGE_KERNEL;
-
-		/*
-		 * Mappings have to be page-aligned
-		 */
-		offset = phys_addr & ~PAGE_MASK;
-		phys_addr &= PAGE_MASK;
-
-		/*
-		 * Ok, go for it..
-		 */
-		area = get_vm_area(size, VM_IOREMAP);
-		if (!area)
-			return NULL;
-
-		area->phys_addr = phys_addr;
-		addr = (void __iomem *) area->addr;
-		if (ioremap_page_range((unsigned long) addr,
-				(unsigned long) addr + size, phys_addr, prot)) {
-			vunmap((void __force *) addr);
-			return NULL;
-		}
-
-		return (void __iomem *) (offset + (char __iomem *)addr);
+		return NULL;
 	}
 
 	return __ioremap_uc(phys_addr);
 }
-EXPORT_SYMBOL(ioremap);
+
+bool arch_iounmap(void __iomem *addr)
+{
+	if (REGION_NUMBER(addr) != RGN_GATE)
+		return false;
+	return true;
+}
 
 void __iomem *
 ioremap_uc(unsigned long phys_addr, unsigned long size)
@@ -113,11 +93,3 @@ void
 early_iounmap (volatile void __iomem *addr, unsigned long size)
 {
 }
-
-void
-iounmap (volatile void __iomem *addr)
-{
-	if (REGION_NUMBER(addr) = RGN_GATE)
-		vunmap((void *) ((unsigned long) addr & PAGE_MASK));
-}
-EXPORT_SYMBOL(iounmap);
-- 
2.34.1
