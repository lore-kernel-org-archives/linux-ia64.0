From: Thierry Reding <thierry.reding@gmail.com>
Date: Mon, 06 Oct 2014 13:52:39 +0000
Subject: [PATCH 7/9] asm-generic/io.h: Implement generic {read,write}s*()
Message-Id: <1412603561-27653-8-git-send-email-thierry.reding@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1412603561-27653-1-git-send-email-thierry.reding@gmail.com>
In-Reply-To: <1412603561-27653-1-git-send-email-thierry.reding@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>, Olof Johansson <olof@lixom.net>, Fengguang Wu <fengguang.wu@intel.com>
Cc: Russell King <linux@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Stephen Boyd <sboyd@codeaurora.org>, Sam Ravnborg <sam@ravnborg.org>, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, x86@kernel.org, linux-serial@vger.kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

From: Thierry Reding <treding@nvidia.com>

Currently driver writers need to use io{read,write}{8,16,32}_rep() when
accessing FIFO registers portably. This is bad for two reasons: it is
inconsistent with how other registers are accessed using the standard
{read,write}{b,w,l}() functions, which can lead to confusion. On some
architectures the io{read,write}*() functions also need to perform some
extra checks to determine whether an address is memory-mapped or refers
to I/O space. Drivers which can be expected to never use I/O can safely
use the {read,write}s{b,w,l,q}(), just like they use their non-string
variants and there's no need for these extra checks.

This patch implements generic versions of readsb(), readsw(), readsl(),
readsq(), writesb(), writesw(), writesl() and writesq(). Variants of
these string functions for I/O accesses (ins*() and outs*() as well as
ioread*_rep() and iowrite*_rep()) are now implemented in terms of the
new functions.

Going forward, {read,write}{,s}{b,w,l,q}() should be used consistently
by drivers for devices that will only ever be memory-mapped and hence
don't need to access I/O space, whereas io{read,write}{8,16,32}_rep()
should be used by drivers for devices that can be either memory-mapped
or I/O-mapped.

Signed-off-by: Thierry Reding <treding@nvidia.com>
---
Changes in v5:
- split off from reconciliation patch

 include/asm-generic/io.h | 271 +++++++++++++++++++++++++++++++++++++++++------
 1 file changed, 238 insertions(+), 33 deletions(-)

diff --git a/include/asm-generic/io.h b/include/asm-generic/io.h
index fb62c621acf9..00483d769d86 100644
--- a/include/asm-generic/io.h
+++ b/include/asm-generic/io.h
@@ -174,96 +174,137 @@ static inline void writeq(u64 value, volatile void __iomem *addr)
 #endif
 #endif /* CONFIG_64BIT */
 
-#ifndef insb
-static inline void insb(unsigned long addr, void *buffer, int count)
+/*
+ * {read,write}s{b,w,l,q}() repeatedly access the same memory address in
+ * native endianness in 8-, 16-, 32- or 64-bit chunks (@count times).
+ */
+#ifndef readsb
+#define readsb readsb
+static inline void readsb(const volatile void __iomem *addr, void *buffer,
+			  unsigned int count)
 {
 	if (count) {
 		u8 *buf = buffer;
+
 		do {
-			u8 x = __raw_readb(addr + PCI_IOBASE);
+			u8 x = __raw_readb(addr);
 			*buf++ = x;
 		} while (--count);
 	}
 }
 #endif
 
-#ifndef insw
-static inline void insw(unsigned long addr, void *buffer, int count)
+#ifndef readsw
+#define readsw readsw
+static inline void readsw(const volatile void __iomem *addr, void *buffer,
+			  unsigned int count)
 {
 	if (count) {
 		u16 *buf = buffer;
+
 		do {
-			u16 x = __raw_readw(addr + PCI_IOBASE);
+			u16 x = __raw_readw(addr);
 			*buf++ = x;
 		} while (--count);
 	}
 }
 #endif
 
-#ifndef insl
-static inline void insl(unsigned long addr, void *buffer, int count)
+#ifndef readsl
+#define readsl readsl
+static inline void readsl(const volatile void __iomem *addr, void *buffer,
+			  unsigned int count)
 {
 	if (count) {
 		u32 *buf = buffer;
+
 		do {
-			u32 x = __raw_readl(addr + PCI_IOBASE);
+			u32 x = __raw_readl(addr);
 			*buf++ = x;
 		} while (--count);
 	}
 }
 #endif
 
-#ifndef outsb
-static inline void outsb(unsigned long addr, const void *buffer, int count)
+#ifdef CONFIG_64BIT
+#ifndef readsq
+#define readsq readsq
+static inline void readsq(const volatile void __iomem *addr, void *buffer,
+			  unsigned int count)
+{
+	if (count) {
+		u64 *buf = buffer;
+
+		do {
+			u64 x = __raw_readq(addr);
+			*buf++ = x;
+		} while (--count);
+	}
+}
+#endif
+#endif /* CONFIG_64BIT */
+
+#ifndef writesb
+#define writesb writesb
+static inline void writesb(volatile void __iomem *addr, const void *buffer,
+			   unsigned int count)
 {
 	if (count) {
 		const u8 *buf = buffer;
+
 		do {
-			__raw_writeb(*buf++, addr + PCI_IOBASE);
+			__raw_writeb(*buf++, addr);
 		} while (--count);
 	}
 }
 #endif
 
-#ifndef outsw
-static inline void outsw(unsigned long addr, const void *buffer, int count)
+#ifndef writesw
+#define writesw writesw
+static inline void writesw(volatile void __iomem *addr, const void *buffer,
+			   unsigned int count)
 {
 	if (count) {
 		const u16 *buf = buffer;
+
 		do {
-			__raw_writew(*buf++, addr + PCI_IOBASE);
+			__raw_writew(*buf++, addr);
 		} while (--count);
 	}
 }
 #endif
 
-#ifndef outsl
-static inline void outsl(unsigned long addr, const void *buffer, int count)
+#ifndef writesl
+#define writesl writesl
+static inline void writesl(volatile void __iomem *addr, const void *buffer,
+			   unsigned int count)
 {
 	if (count) {
 		const u32 *buf = buffer;
+
 		do {
-			__raw_writel(*buf++, addr + PCI_IOBASE);
+			__raw_writel(*buf++, addr);
 		} while (--count);
 	}
 }
 #endif
 
-#ifndef CONFIG_GENERIC_IOMAP
-#define ioread8_rep(p, dst, count) \
-	insb((unsigned long) (p), (dst), (count))
-#define ioread16_rep(p, dst, count) \
-	insw((unsigned long) (p), (dst), (count))
-#define ioread32_rep(p, dst, count) \
-	insl((unsigned long) (p), (dst), (count))
-
-#define iowrite8_rep(p, src, count) \
-	outsb((unsigned long) (p), (src), (count))
-#define iowrite16_rep(p, src, count) \
-	outsw((unsigned long) (p), (src), (count))
-#define iowrite32_rep(p, src, count) \
-	outsl((unsigned long) (p), (src), (count))
-#endif /* CONFIG_GENERIC_IOMAP */
+#ifdef CONFIG_64BIT
+#ifndef writesq
+#define writesq writesq
+static inline void writesq(volatile void __iomem *addr, const void *buffer,
+			   unsigned int count)
+{
+	if (count) {
+		const u64 *buf = buffer;
+
+		do {
+			__raw_writeq(*buf++, addr);
+		} while (--count);
+	}
+}
+#endif
+#endif /* CONFIG_64BIT */
 
 #ifndef PCI_IOBASE
 #define PCI_IOBASE ((void __iomem *)0)
@@ -375,6 +416,113 @@ static inline void outl_p(u32 value, unsigned long addr)
 }
 #endif
 
+/*
+ * {in,out}s{b,w,l}{,_p}() are variants of the above that repeatedly access a
+ * single I/O port multiple times.
+ */
+
+#ifndef insb
+#define insb insb
+static inline void insb(unsigned long addr, void *buffer, unsigned int count)
+{
+	readsb(PCI_IOBASE + addr, buffer, count);
+}
+#endif
+
+#ifndef insw
+#define insw insw
+static inline void insw(unsigned long addr, void *buffer, unsigned int count)
+{
+	readsw(PCI_IOBASE + addr, buffer, count);
+}
+#endif
+
+#ifndef insl
+#define insl insl
+static inline void insl(unsigned long addr, void *buffer, unsigned int count)
+{
+	readsl(PCI_IOBASE + addr, buffer, count);
+}
+#endif
+
+#ifndef outsb
+#define outsb outsb
+static inline void outsb(unsigned long addr, const void *buffer,
+			 unsigned int count)
+{
+	writesb(PCI_IOBASE + addr, buffer, count);
+}
+#endif
+
+#ifndef outsw
+#define outsw outsw
+static inline void outsw(unsigned long addr, const void *buffer,
+			 unsigned int count)
+{
+	writesw(PCI_IOBASE + addr, buffer, count);
+}
+#endif
+
+#ifndef outsl
+#define outsl outsl
+static inline void outsl(unsigned long addr, const void *buffer,
+			 unsigned int count)
+{
+	writesl(PCI_IOBASE + addr, buffer, count);
+}
+#endif
+
+#ifndef insb_p
+#define insb_p insb_p
+static inline void insb_p(unsigned long addr, void *buffer, unsigned int count)
+{
+	insb(addr, buffer, count);
+}
+#endif
+
+#ifndef insw_p
+#define insw_p insw_p
+static inline void insw_p(unsigned long addr, void *buffer, unsigned int count)
+{
+	insw(addr, buffer, count);
+}
+#endif
+
+#ifndef insl_p
+#define insl_p insl_p
+static inline void insl_p(unsigned long addr, void *buffer, unsigned int count)
+{
+	insl(addr, buffer, count);
+}
+#endif
+
+#ifndef outsb_p
+#define outsb_p outsb_p
+static inline void outsb_p(unsigned long addr, const void *buffer,
+			   unsigned int count)
+{
+	outsb(addr, buffer, count);
+}
+#endif
+
+#ifndef outsw_p
+#define outsw_p outsw_p
+static inline void outsw_p(unsigned long addr, const void *buffer,
+			   unsigned int count)
+{
+	outsw(addr, buffer, count);
+}
+#endif
+
+#ifndef outsl_p
+#define outsl_p outsl_p
+static inline void outsl_p(unsigned long addr, const void *buffer,
+			   unsigned int count)
+{
+	outsl(addr, buffer, count);
+}
+#endif
+
 #ifndef CONFIG_GENERIC_IOMAP
 #ifndef ioread8
 #define ioread8 ioread8
@@ -455,6 +603,63 @@ static inline void iowrite32be(u32 value, volatile void __iomem *addr)
 	__raw_writel(__cpu_to_be32(value), addr);
 }
 #endif
+
+#ifndef ioread8_rep
+#define ioread8_rep ioread8_rep
+static inline void ioread8_rep(const volatile void __iomem *addr, void *buffer,
+			       unsigned int count)
+{
+	readsb(addr, buffer, count);
+}
+#endif
+
+#ifndef ioread16_rep
+#define ioread16_rep ioread16_rep
+static inline void ioread16_rep(const volatile void __iomem *addr,
+				void *buffer, unsigned int count)
+{
+	readsw(addr, buffer, count);
+}
+#endif
+
+#ifndef ioread32_rep
+#define ioread32_rep ioread32_rep
+static inline void ioread32_rep(const volatile void __iomem *addr,
+				void *buffer, unsigned int count)
+{
+	readsl(addr, buffer, count);
+}
+#endif
+
+#ifndef iowrite8_rep
+#define iowrite8_rep iowrite8_rep
+static inline void iowrite8_rep(volatile void __iomem *addr,
+				const void *buffer,
+				unsigned int count)
+{
+	writesb(addr, buffer, count);
+}
+#endif
+
+#ifndef iowrite16_rep
+#define iowrite16_rep iowrite16_rep
+static inline void iowrite16_rep(volatile void __iomem *addr,
+				 const void *buffer,
+				 unsigned int count)
+{
+	writesw(addr, buffer, count);
+}
+#endif
+
+#ifndef iowrite32_rep
+#define iowrite32_rep iowrite32_rep
+static inline void iowrite32_rep(volatile void __iomem *addr,
+				 const void *buffer,
+				 unsigned int count)
+{
+	writesl(addr, buffer, count);
+}
+#endif
 #endif /* CONFIG_GENERIC_IOMAP */
 
 #ifdef __KERNEL__
-- 
2.1.0

