From: Thierry Reding <thierry.reding@gmail.com>
Date: Wed, 13 Aug 2014 10:28:57 +0000
Subject: [PATCH v4 7/8] ARM: Use include/asm-generic/io.h
Message-Id: <1407925738-26170-8-git-send-email-thierry.reding@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1407925738-26170-1-git-send-email-thierry.reding@gmail.com>
In-Reply-To: <1407925738-26170-1-git-send-email-thierry.reding@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>
Cc: Russell King <linux@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Stephen Boyd <sboyd@codeaurora.org>, Sam Ravnborg <sam@ravnborg.org>, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, x86@kernel.org, linux-serial@vger.kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

From: Thierry Reding <treding@nvidia.com>

Include the generic I/O header file so that duplicate implementations
can be removed. This will also help to establish consistency across more
architectures regarding which accessors they support.

Signed-off-by: Thierry Reding <treding@nvidia.com>
---
Changes in v4:
- define xlate_dev_{kmem,mem}_ptr() before asm-generic/io.h include

Changes in v3:
- override io{read,write}{16,32}be() since the generic ones don't have
  the required memory barriers

 arch/arm/include/asm/io.h     | 75 ++++++++++++++++---------------------------
 arch/arm/include/asm/memory.h |  2 ++
 2 files changed, 29 insertions(+), 48 deletions(-)

diff --git a/arch/arm/include/asm/io.h b/arch/arm/include/asm/io.h
index 3d23418cbddd..d45cb6b9459a 100644
--- a/arch/arm/include/asm/io.h
+++ b/arch/arm/include/asm/io.h
@@ -69,6 +69,7 @@ extern void __raw_readsl(const void __iomem *addr, void *data, int longlen);
  * writeback addressing modes as these incur a significant performance
  * overhead (the address generation must be emulated in software).
  */
+#define __raw_writew __raw_writew
 static inline void __raw_writew(u16 val, volatile void __iomem *addr)
 {
 	asm volatile("strh %1, %0"
@@ -76,6 +77,7 @@ static inline void __raw_writew(u16 val, volatile void __iomem *addr)
 		     : "r" (val));
 }
 
+#define __raw_readw __raw_readw
 static inline u16 __raw_readw(const volatile void __iomem *addr)
 {
 	u16 val;
@@ -86,6 +88,7 @@ static inline u16 __raw_readw(const volatile void __iomem *addr)
 }
 #endif
 
+#define __raw_writeb __raw_writeb
 static inline void __raw_writeb(u8 val, volatile void __iomem *addr)
 {
 	asm volatile("strb %1, %0"
@@ -93,6 +96,7 @@ static inline void __raw_writeb(u8 val, volatile void __iomem *addr)
 		     : "r" (val));
 }
 
+#define __raw_writel __raw_writel
 static inline void __raw_writel(u32 val, volatile void __iomem *addr)
 {
 	asm volatile("str %1, %0"
@@ -100,6 +104,7 @@ static inline void __raw_writel(u32 val, volatile void __iomem *addr)
 		     : "r" (val));
 }
 
+#define __raw_readb __raw_readb
 static inline u8 __raw_readb(const volatile void __iomem *addr)
 {
 	u8 val;
@@ -109,6 +114,7 @@ static inline u8 __raw_readb(const volatile void __iomem *addr)
 	return val;
 }
 
+#define __raw_readl __raw_readl
 static inline u32 __raw_readl(const volatile void __iomem *addr)
 {
 	u32 val;
@@ -266,20 +272,6 @@ extern int pci_ioremap_io(unsigned int offset, phys_addr_t phys_addr);
 #define insl(p,d,l)		__raw_readsl(__io(p),d,l)
 #endif
 
-#define outb_p(val,port)	outb((val),(port))
-#define outw_p(val,port)	outw((val),(port))
-#define outl_p(val,port)	outl((val),(port))
-#define inb_p(port)		inb((port))
-#define inw_p(port)		inw((port))
-#define inl_p(port)		inl((port))
-
-#define outsb_p(port,from,len)	outsb(port,from,len)
-#define outsw_p(port,from,len)	outsw(port,from,len)
-#define outsl_p(port,from,len)	outsl(port,from,len)
-#define insb_p(port,to,len)	insb(port,to,len)
-#define insw_p(port,to,len)	insw(port,to,len)
-#define insl_p(port,to,len)	insl(port,to,len)
-
 /*
  * String version of IO memory access ops:
  */
@@ -346,40 +338,38 @@ extern void _memset_io(volatile void __iomem *, int, size_t);
 #define iounmap				__arm_iounmap
 
 /*
- * io{read,write}{8,16,32} macros
+ * io{read,write}{16,32}be() macros
  */
-#ifndef ioread8
-#define ioread8(p)	({ unsigned int __v = __raw_readb(p); __iormb(); __v; })
-#define ioread16(p)	({ unsigned int __v = le16_to_cpu((__force __le16)__raw_readw(p)); __iormb(); __v; })
-#define ioread32(p)	({ unsigned int __v = le32_to_cpu((__force __le32)__raw_readl(p)); __iormb(); __v; })
-
-#define ioread16be(p)	({ unsigned int __v = be16_to_cpu((__force __be16)__raw_readw(p)); __iormb(); __v; })
-#define ioread32be(p)	({ unsigned int __v = be32_to_cpu((__force __be32)__raw_readl(p)); __iormb(); __v; })
-
-#define iowrite8(v,p)	({ __iowmb(); __raw_writeb(v, p); })
-#define iowrite16(v,p)	({ __iowmb(); __raw_writew((__force __u16)cpu_to_le16(v), p); })
-#define iowrite32(v,p)	({ __iowmb(); __raw_writel((__force __u32)cpu_to_le32(v), p); })
+#define ioread16be(p)		({ __u16 __v = be16_to_cpu((__force __be16)__raw_readw(p)); __iormb(); __v; })
+#define ioread32be(p)		({ __u32 __v = be32_to_cpu((__force __be32)__raw_readl(p)); __iormb(); __v; })
 
-#define iowrite16be(v,p) ({ __iowmb(); __raw_writew((__force __u16)cpu_to_be16(v), p); })
-#define iowrite32be(v,p) ({ __iowmb(); __raw_writel((__force __u32)cpu_to_be32(v), p); })
-
-#define ioread8_rep(p,d,c)	__raw_readsb(p,d,c)
-#define ioread16_rep(p,d,c)	__raw_readsw(p,d,c)
-#define ioread32_rep(p,d,c)	__raw_readsl(p,d,c)
-
-#define iowrite8_rep(p,s,c)	__raw_writesb(p,s,c)
-#define iowrite16_rep(p,s,c)	__raw_writesw(p,s,c)
-#define iowrite32_rep(p,s,c)	__raw_writesl(p,s,c)
+#define iowrite16be(v,p)	({ __iowmb(); __raw_writew((__force __u16)cpu_to_be16(v), p); })
+#define iowrite32be(v,p)	({ __iowmb(); __raw_writew((__force __u32)cpu_to_be32(v), p); })
 
+#define ioport_map ioport_map
 extern void __iomem *ioport_map(unsigned long port, unsigned int nr);
+#define ioport_unmap ioport_unmap
 extern void ioport_unmap(void __iomem *addr);
-#endif
 
 struct pci_dev;
 
+#define pci_iounmap pci_iounmap
 extern void pci_iounmap(struct pci_dev *dev, void __iomem *addr);
 
 /*
+ * Convert a physical pointer to a virtual kernel pointer for /dev/mem
+ * access
+ */
+#define xlate_dev_mem_ptr(p)	__va(p)
+
+/*
+ * Convert a virtual cached pointer to an uncached pointer
+ */
+#define xlate_dev_kmem_ptr(p)	p
+
+#include <asm-generic/io.h>
+
+/*
  * can the hardware map this into one segment or not, given no other
  * constraints.
  */
@@ -401,17 +391,6 @@ extern int devmem_is_allowed(unsigned long pfn);
 #endif
 
 /*
- * Convert a physical pointer to a virtual kernel pointer for /dev/mem
- * access
- */
-#define xlate_dev_mem_ptr(p)	__va(p)
-
-/*
- * Convert a virtual cached pointer to an uncached pointer
- */
-#define xlate_dev_kmem_ptr(p)	p
-
-/*
  * Register ISA memory and port locations for glibc iopl/inb/outb
  * emulation.
  */
diff --git a/arch/arm/include/asm/memory.h b/arch/arm/include/asm/memory.h
index e731018869a7..1c187611d3c7 100644
--- a/arch/arm/include/asm/memory.h
+++ b/arch/arm/include/asm/memory.h
@@ -274,11 +274,13 @@ static inline unsigned long __phys_to_virt(phys_addr_t x)
  * translation for translating DMA addresses.  Use the driver
  * DMA support - see dma-mapping.h.
  */
+#define virt_to_phys virt_to_phys
 static inline phys_addr_t virt_to_phys(const volatile void *x)
 {
 	return __virt_to_phys((unsigned long)(x));
 }
 
+#define phys_to_virt phys_to_virt
 static inline void *phys_to_virt(phys_addr_t x)
 {
 	return (void *)__phys_to_virt(x);
-- 
2.0.4

