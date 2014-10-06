From: Thierry Reding <thierry.reding@gmail.com>
Date: Mon, 06 Oct 2014 13:52:41 +0000
Subject: [PATCH 9/9] arm64: Use include/asm-generic/io.h
Message-Id: <1412603561-27653-10-git-send-email-thierry.reding@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1412603561-27653-1-git-send-email-thierry.reding@gmail.com>
In-Reply-To: <1412603561-27653-1-git-send-email-thierry.reding@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>, Olof Johansson <olof@lixom.net>, Fengguang Wu <fengguang.wu@intel.com>
Cc: Russell King <linux@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Stephen Boyd <sboyd@codeaurora.org>, Sam Ravnborg <sam@ravnborg.org>, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, x86@kernel.org, linux-serial@vger.kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

From: Thierry Reding <treding@nvidia.com>

Include the generic I/O header file so that duplicate implementations
can be removed. This will also help to establish consistency across more
architectures regarding which accessors they support.

Acked-by: Catalin Marinas <catalin.marinas@arm.com>
Signed-off-by: Thierry Reding <treding@nvidia.com>
---
Changes in v4:
- define xlate_dev_{kmem,mem}_ptr() before asm-generic/io.h include

Changes in v3:
- add io{read,write}{16,32}be() to match what 32-bit ARM does

 arch/arm64/Kconfig              |   1 -
 arch/arm64/include/asm/io.h     | 122 ++++++++--------------------------------
 arch/arm64/include/asm/memory.h |   2 +
 3 files changed, 27 insertions(+), 98 deletions(-)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index c55b1f3fa006..f5ed3332af6d 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -23,7 +23,6 @@ config ARM64
 	select GENERIC_CLOCKEVENTS_BROADCAST if SMP
 	select GENERIC_CPU_AUTOPROBE
 	select GENERIC_EARLY_IOREMAP
-	select GENERIC_IOMAP
 	select GENERIC_IRQ_PROBE
 	select GENERIC_IRQ_SHOW
 	select GENERIC_SCHED_CLOCK
diff --git a/arch/arm64/include/asm/io.h b/arch/arm64/include/asm/io.h
index f998d90bc389..a57b2d5a5889 100644
--- a/arch/arm64/include/asm/io.h
+++ b/arch/arm64/include/asm/io.h
@@ -34,26 +34,31 @@
 /*
  * Generic IO read/write.  These perform native-endian accesses.
  */
+#define __raw_writeb __raw_writeb
 static inline void __raw_writeb(u8 val, volatile void __iomem *addr)
 {
 	asm volatile("strb %w0, [%1]" : : "r" (val), "r" (addr));
 }
 
+#define __raw_writew __raw_writew
 static inline void __raw_writew(u16 val, volatile void __iomem *addr)
 {
 	asm volatile("strh %w0, [%1]" : : "r" (val), "r" (addr));
 }
 
+#define __raw_writel __raw_writel
 static inline void __raw_writel(u32 val, volatile void __iomem *addr)
 {
 	asm volatile("str %w0, [%1]" : : "r" (val), "r" (addr));
 }
 
+#define __raw_writeq __raw_writeq
 static inline void __raw_writeq(u64 val, volatile void __iomem *addr)
 {
 	asm volatile("str %0, [%1]" : : "r" (val), "r" (addr));
 }
 
+#define __raw_readb __raw_readb
 static inline u8 __raw_readb(const volatile void __iomem *addr)
 {
 	u8 val;
@@ -61,6 +66,7 @@ static inline u8 __raw_readb(const volatile void __iomem *addr)
 	return val;
 }
 
+#define __raw_readw __raw_readw
 static inline u16 __raw_readw(const volatile void __iomem *addr)
 {
 	u16 val;
@@ -68,6 +74,7 @@ static inline u16 __raw_readw(const volatile void __iomem *addr)
 	return val;
 }
 
+#define __raw_readl __raw_readl
 static inline u32 __raw_readl(const volatile void __iomem *addr)
 {
 	u32 val;
@@ -75,6 +82,7 @@ static inline u32 __raw_readl(const volatile void __iomem *addr)
 	return val;
 }
 
+#define __raw_readq __raw_readq
 static inline u64 __raw_readq(const volatile void __iomem *addr)
 {
 	u64 val;
@@ -125,94 +133,6 @@ static inline u64 __raw_readq(const volatile void __iomem *addr)
 #define IO_SPACE_LIMIT		(SZ_32M - 1)
 #define PCI_IOBASE		((void __iomem *)(MODULES_VADDR - SZ_32M))
 
-static inline u8 inb(unsigned long addr)
-{
-	return readb(addr + PCI_IOBASE);
-}
-
-static inline u16 inw(unsigned long addr)
-{
-	return readw(addr + PCI_IOBASE);
-}
-
-static inline u32 inl(unsigned long addr)
-{
-	return readl(addr + PCI_IOBASE);
-}
-
-static inline void outb(u8 b, unsigned long addr)
-{
-	writeb(b, addr + PCI_IOBASE);
-}
-
-static inline void outw(u16 b, unsigned long addr)
-{
-	writew(b, addr + PCI_IOBASE);
-}
-
-static inline void outl(u32 b, unsigned long addr)
-{
-	writel(b, addr + PCI_IOBASE);
-}
-
-#define inb_p(addr)	inb(addr)
-#define inw_p(addr)	inw(addr)
-#define inl_p(addr)	inl(addr)
-
-#define outb_p(x, addr)	outb((x), (addr))
-#define outw_p(x, addr)	outw((x), (addr))
-#define outl_p(x, addr)	outl((x), (addr))
-
-static inline void insb(unsigned long addr, void *buffer, int count)
-{
-	u8 *buf = buffer;
-	while (count--)
-		*buf++ = __raw_readb(addr + PCI_IOBASE);
-}
-
-static inline void insw(unsigned long addr, void *buffer, int count)
-{
-	u16 *buf = buffer;
-	while (count--)
-		*buf++ = __raw_readw(addr + PCI_IOBASE);
-}
-
-static inline void insl(unsigned long addr, void *buffer, int count)
-{
-	u32 *buf = buffer;
-	while (count--)
-		*buf++ = __raw_readl(addr + PCI_IOBASE);
-}
-
-static inline void outsb(unsigned long addr, const void *buffer, int count)
-{
-	const u8 *buf = buffer;
-	while (count--)
-		__raw_writeb(*buf++, addr + PCI_IOBASE);
-}
-
-static inline void outsw(unsigned long addr, const void *buffer, int count)
-{
-	const u16 *buf = buffer;
-	while (count--)
-		__raw_writew(*buf++, addr + PCI_IOBASE);
-}
-
-static inline void outsl(unsigned long addr, const void *buffer, int count)
-{
-	const u32 *buf = buffer;
-	while (count--)
-		__raw_writel(*buf++, addr + PCI_IOBASE);
-}
-
-#define insb_p(port,to,len)	insb(port,to,len)
-#define insw_p(port,to,len)	insw(port,to,len)
-#define insl_p(port,to,len)	insl(port,to,len)
-
-#define outsb_p(port,from,len)	outsb(port,from,len)
-#define outsw_p(port,from,len)	outsw(port,from,len)
-#define outsl_p(port,from,len)	outsl(port,from,len)
-
 /*
  * String version of I/O memory access operations.
  */
@@ -236,18 +156,14 @@ extern void __iomem *ioremap_cache(phys_addr_t phys_addr, size_t size);
 #define ioremap_wc(addr, size)		__ioremap((addr), (size), __pgprot(PROT_NORMAL_NC))
 #define iounmap				__iounmap
 
-#define ARCH_HAS_IOREMAP_WC
-#include <asm-generic/iomap.h>
-
 /*
- * More restrictive address range checking than the default implementation
- * (PHYS_OFFSET and PHYS_MASK taken into account).
+ * io{read,write}{16,32}be() macros
  */
-#define ARCH_HAS_VALID_PHYS_ADDR_RANGE
-extern int valid_phys_addr_range(unsigned long addr, size_t size);
-extern int valid_mmap_phys_addr_range(unsigned long pfn, size_t size);
+#define ioread16be(p)		({ __u16 __v = be16_to_cpu((__force __be16)__raw_readw(p)); __iormb(); __v; })
+#define ioread32be(p)		({ __u32 __v = be32_to_cpu((__force __be32)__raw_readl(p)); __iormb(); __v; })
 
-extern int devmem_is_allowed(unsigned long pfn);
+#define iowrite16be(v,p)	({ __iowmb(); __raw_writew((__force __u16)cpu_to_be16(v), p); })
+#define iowrite32be(v,p)	({ __iowmb(); __raw_writew((__force __u32)cpu_to_be32(v), p); })
 
 /*
  * Convert a physical pointer to a virtual kernel pointer for /dev/mem
@@ -260,6 +176,18 @@ extern int devmem_is_allowed(unsigned long pfn);
  */
 #define xlate_dev_kmem_ptr(p)	p
 
+#include <asm-generic/io.h>
+
+/*
+ * More restrictive address range checking than the default implementation
+ * (PHYS_OFFSET and PHYS_MASK taken into account).
+ */
+#define ARCH_HAS_VALID_PHYS_ADDR_RANGE
+extern int valid_phys_addr_range(unsigned long addr, size_t size);
+extern int valid_mmap_phys_addr_range(unsigned long pfn, size_t size);
+
+extern int devmem_is_allowed(unsigned long pfn);
+
 struct bio_vec;
 extern bool xen_biovec_phys_mergeable(const struct bio_vec *vec1,
 				      const struct bio_vec *vec2);
diff --git a/arch/arm64/include/asm/memory.h b/arch/arm64/include/asm/memory.h
index ccc7087d3c4e..a40a4d7e830f 100644
--- a/arch/arm64/include/asm/memory.h
+++ b/arch/arm64/include/asm/memory.h
@@ -120,11 +120,13 @@ extern phys_addr_t		memstart_addr;
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
 	return (void *)(__phys_to_virt(x));
-- 
2.1.0

