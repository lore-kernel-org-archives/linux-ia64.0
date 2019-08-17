From: Christoph Hellwig <hch@lst.de>
Date: Sat, 17 Aug 2019 07:32:44 +0000
Subject: [PATCH 17/26] arch: rely on asm-generic/io.h for default ioremap_* definitions
Message-Id: <20190817073253.27819-18-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190817073253.27819-1-hch@lst.de>
In-Reply-To: <20190817073253.27819-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>, Guo Ren <guoren@kernel.org>, Michal Simek <monstr@monstr.eu>, Greentime Hu <green.hu@gmail.com>, Vincent Chen <deanbo422@gmail.com>, Guan Xuetao <gxt@pku.edu.cn>, x86@kernel.org
Cc: linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, nios2-dev@lists.rocketboards.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-mtd@lists.infradead.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

Various architectures that use asm-generic/io.h still defined their
own default versions of ioremap_nocache, ioremap_wt and ioremap_wc
that point back to plain ioremap directly or indirectly.  Remove these
definitions and rely on asm-generic/io.h instead.  For this to work
the backup ioremap_* defintions needs to be changed to purely cpp
macros instea of inlines to cover for architectures like openrisc
that only define ioremap after including <asm-generic/io.h>.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/arc/include/asm/io.h        |  4 ----
 arch/arm/include/asm/io.h        |  1 -
 arch/arm64/include/asm/io.h      |  2 --
 arch/csky/include/asm/io.h       |  4 ----
 arch/ia64/include/asm/io.h       |  1 -
 arch/microblaze/include/asm/io.h |  3 ---
 arch/nios2/include/asm/io.h      |  4 ----
 arch/openrisc/include/asm/io.h   |  1 -
 arch/riscv/include/asm/io.h      | 10 ----------
 arch/s390/include/asm/io.h       |  4 ----
 arch/x86/include/asm/io.h        |  1 -
 arch/xtensa/include/asm/io.h     |  4 ----
 include/asm-generic/io.h         | 18 +++---------------
 13 files changed, 3 insertions(+), 54 deletions(-)

diff --git a/arch/arc/include/asm/io.h b/arch/arc/include/asm/io.h
index 72f7929736f8..8f777d6441a5 100644
--- a/arch/arc/include/asm/io.h
+++ b/arch/arc/include/asm/io.h
@@ -34,10 +34,6 @@ static inline void ioport_unmap(void __iomem *addr)
 
 extern void iounmap(const void __iomem *addr);
 
-#define ioremap_nocache(phy, sz)	ioremap(phy, sz)
-#define ioremap_wc(phy, sz)		ioremap(phy, sz)
-#define ioremap_wt(phy, sz)		ioremap(phy, sz)
-
 /*
  * io{read,write}{16,32}be() macros
  */
diff --git a/arch/arm/include/asm/io.h b/arch/arm/include/asm/io.h
index 924f9dd502ed..aefdabdbeb84 100644
--- a/arch/arm/include/asm/io.h
+++ b/arch/arm/include/asm/io.h
@@ -392,7 +392,6 @@ static inline void memcpy_toio(volatile void __iomem *to, const void *from,
  */
 void __iomem *ioremap(resource_size_t res_cookie, size_t size);
 #define ioremap ioremap
-#define ioremap_nocache ioremap
 
 /*
  * Do not use ioremap_cache for mapping memory. Use memremap instead.
diff --git a/arch/arm64/include/asm/io.h b/arch/arm64/include/asm/io.h
index 7ed92626949d..a61b1469f7d9 100644
--- a/arch/arm64/include/asm/io.h
+++ b/arch/arm64/include/asm/io.h
@@ -169,9 +169,7 @@ extern void __iounmap(volatile void __iomem *addr);
 extern void __iomem *ioremap_cache(phys_addr_t phys_addr, size_t size);
 
 #define ioremap(addr, size)		__ioremap((addr), (size), __pgprot(PROT_DEVICE_nGnRE))
-#define ioremap_nocache(addr, size)	__ioremap((addr), (size), __pgprot(PROT_DEVICE_nGnRE))
 #define ioremap_wc(addr, size)		__ioremap((addr), (size), __pgprot(PROT_NORMAL_NC))
-#define ioremap_wt(addr, size)		__ioremap((addr), (size), __pgprot(PROT_DEVICE_nGnRE))
 #define iounmap				__iounmap
 
 /*
diff --git a/arch/csky/include/asm/io.h b/arch/csky/include/asm/io.h
index c1dfa9c10e36..800985af1c44 100644
--- a/arch/csky/include/asm/io.h
+++ b/arch/csky/include/asm/io.h
@@ -40,10 +40,6 @@ extern int remap_area_pages(unsigned long address, phys_addr_t phys_addr,
 #define writel(v,c)		({ wmb(); writel_relaxed((v),(c)); mb(); })
 #endif
 
-#define ioremap_nocache(phy, sz)	ioremap(phy, sz)
-#define ioremap_wc ioremap_nocache
-#define ioremap_wt ioremap_nocache
-
 #include <asm-generic/io.h>
 
 #endif /* __ASM_CSKY_IO_H */
diff --git a/arch/ia64/include/asm/io.h b/arch/ia64/include/asm/io.h
index febd2c6ea0b4..7faf50e45ac8 100644
--- a/arch/ia64/include/asm/io.h
+++ b/arch/ia64/include/asm/io.h
@@ -419,7 +419,6 @@ static inline void __iomem * ioremap_cache (unsigned long phys_addr, unsigned lo
 	return ioremap(phys_addr, size);
 }
 #define ioremap ioremap
-#define ioremap_nocache ioremap
 #define ioremap_cache ioremap_cache
 #define ioremap_uc ioremap_uc
 #define iounmap iounmap
diff --git a/arch/microblaze/include/asm/io.h b/arch/microblaze/include/asm/io.h
index 86c95b2a1ce1..d33c61737b8b 100644
--- a/arch/microblaze/include/asm/io.h
+++ b/arch/microblaze/include/asm/io.h
@@ -39,9 +39,6 @@ extern resource_size_t isa_mem_base;
 extern void iounmap(volatile void __iomem *addr);
 
 extern void __iomem *ioremap(phys_addr_t address, unsigned long size);
-#define ioremap_nocache(addr, size)		ioremap((addr), (size))
-#define ioremap_wc(addr, size)			ioremap((addr), (size))
-#define ioremap_wt(addr, size)			ioremap((addr), (size))
 
 #endif /* CONFIG_MMU */
 
diff --git a/arch/nios2/include/asm/io.h b/arch/nios2/include/asm/io.h
index 74ab34aa6731..d108937c321e 100644
--- a/arch/nios2/include/asm/io.h
+++ b/arch/nios2/include/asm/io.h
@@ -33,10 +33,6 @@ static inline void iounmap(void __iomem *addr)
 	__iounmap(addr);
 }
 
-#define ioremap_nocache ioremap
-#define ioremap_wc ioremap
-#define ioremap_wt ioremap
-
 /* Pages to physical address... */
 #define page_to_phys(page)	virt_to_phys(page_to_virt(page))
 
diff --git a/arch/openrisc/include/asm/io.h b/arch/openrisc/include/asm/io.h
index 5b81a96ab85e..e18f038b2a6d 100644
--- a/arch/openrisc/include/asm/io.h
+++ b/arch/openrisc/include/asm/io.h
@@ -25,7 +25,6 @@
 #define PIO_OFFSET		0
 #define PIO_MASK		0
 
-#define ioremap_nocache ioremap
 #include <asm-generic/io.h>
 #include <asm/pgtable.h>
 
diff --git a/arch/riscv/include/asm/io.h b/arch/riscv/include/asm/io.h
index fc1189ad3777..c1de6875cc77 100644
--- a/arch/riscv/include/asm/io.h
+++ b/arch/riscv/include/asm/io.h
@@ -15,16 +15,6 @@
 #include <asm/mmiowb.h>
 
 extern void __iomem *ioremap(phys_addr_t offset, unsigned long size);
-
-/*
- * The RISC-V ISA doesn't yet specify how to query or modify PMAs, so we can't
- * change the properties of memory regions.  This should be fixed by the
- * upcoming platform spec.
- */
-#define ioremap_nocache(addr, size) ioremap((addr), (size))
-#define ioremap_wc(addr, size) ioremap((addr), (size))
-#define ioremap_wt(addr, size) ioremap((addr), (size))
-
 extern void iounmap(volatile void __iomem *addr);
 
 /* Generic IO read/write.  These perform native-endian accesses. */
diff --git a/arch/s390/include/asm/io.h b/arch/s390/include/asm/io.h
index ca421614722f..5a16f500515a 100644
--- a/arch/s390/include/asm/io.h
+++ b/arch/s390/include/asm/io.h
@@ -26,10 +26,6 @@ void unxlate_dev_mem_ptr(phys_addr_t phys, void *addr);
 
 #define IO_SPACE_LIMIT 0
 
-#define ioremap_nocache(addr, size)	ioremap(addr, size)
-#define ioremap_wc			ioremap_nocache
-#define ioremap_wt			ioremap_nocache
-
 void __iomem *ioremap(unsigned long offset, unsigned long size);
 void iounmap(volatile void __iomem *addr);
 
diff --git a/arch/x86/include/asm/io.h b/arch/x86/include/asm/io.h
index 6b5cc41319a7..9997521fc5cd 100644
--- a/arch/x86/include/asm/io.h
+++ b/arch/x86/include/asm/io.h
@@ -205,7 +205,6 @@ extern void __iomem *ioremap_encrypted(resource_size_t phys_addr, unsigned long
  */
 void __iomem *ioremap(resource_size_t offset, unsigned long size);
 #define ioremap ioremap
-#define ioremap_nocache ioremap
 
 extern void iounmap(volatile void __iomem *addr);
 #define iounmap iounmap
diff --git a/arch/xtensa/include/asm/io.h b/arch/xtensa/include/asm/io.h
index ffadc99c8601..108c0d61d066 100644
--- a/arch/xtensa/include/asm/io.h
+++ b/arch/xtensa/include/asm/io.h
@@ -51,10 +51,6 @@ static inline void __iomem *ioremap_cache(unsigned long offset,
 }
 #define ioremap_cache ioremap_cache
 
-#define ioremap_nocache ioremap
-#define ioremap_wc ioremap
-#define ioremap_wt ioremap
-
 static inline void iounmap(volatile void __iomem *addr)
 {
 	unsigned long va = (unsigned long) addr;
diff --git a/include/asm-generic/io.h b/include/asm-generic/io.h
index 6a5edc23afe2..4e45e1cb6560 100644
--- a/include/asm-generic/io.h
+++ b/include/asm-generic/io.h
@@ -949,27 +949,15 @@ static inline void iounmap(void __iomem *addr)
 #endif /* CONFIG_MMU */
 
 #ifndef ioremap_nocache
-#define ioremap_nocache ioremap_nocache
-static inline void __iomem *ioremap_nocache(phys_addr_t offset, size_t size)
-{
-	return ioremap(offset, size);
-}
+#define ioremap_nocache ioremap
 #endif
 
 #ifndef ioremap_wc
-#define ioremap_wc ioremap_wc
-static inline void __iomem *ioremap_wc(phys_addr_t offset, size_t size)
-{
-	return ioremap_nocache(offset, size);
-}
+#define ioremap_wc ioremap
 #endif
 
 #ifndef ioremap_wt
-#define ioremap_wt ioremap_wt
-static inline void __iomem *ioremap_wt(phys_addr_t offset, size_t size)
-{
-	return ioremap_nocache(offset, size);
-}
+#define ioremap_wt ioremap
 #endif
 
 /*
-- 
2.20.1
