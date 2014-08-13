From: Thierry Reding <thierry.reding@gmail.com>
Date: Wed, 13 Aug 2014 10:28:56 +0000
Subject: [PATCH v4 6/8] asm-generic/io.h: Implement generic {read,write}s*()
Message-Id: <1407925738-26170-7-git-send-email-thierry.reding@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1407925738-26170-1-git-send-email-thierry.reding@gmail.com>
In-Reply-To: <1407925738-26170-1-git-send-email-thierry.reding@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>
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

While at it, also make sure that any of the functions provided as
fallback for architectures that don't override them can't be overridden
subsequently. At the same time, replace all macros by static inline
functions for better type checking and reorder functions by logical
groups.

Signed-off-by: Thierry Reding <treding@nvidia.com>
---
Changes in v4:
- reorder functions to form logical groups (Sam Ravnborg)
- convert functions to static inlines for type checking
- provide {,un}xlate_dev{kmem,mem}_ptr()

Changes in v3:
- allow architectures to override io{read,write}{16,32}be()
- explain the reasons for this change in the commit message

Changes in v2:
- respect IO_SPACE_LIMIT in ioport_map()

 include/asm-generic/io.h | 683 ++++++++++++++++++++++++++++++++++++++---------
 1 file changed, 555 insertions(+), 128 deletions(-)

diff --git a/include/asm-generic/io.h b/include/asm-generic/io.h
index 975e1cc75edb..508a57257de5 100644
--- a/include/asm-generic/io.h
+++ b/include/asm-generic/io.h
@@ -24,250 +24,622 @@
 #define mmiowb() do {} while (0)
 #endif
 
-/*****************************************************************************/
 /*
- * readX/writeX() are used to access memory mapped devices. On some
- * architectures the memory mapped IO stuff needs to be accessed
- * differently. On the simple architectures, we just read/write the
- * memory location directly.
+ * __raw_{read,write}{b,w,l,q}() access memory in native endianness.
+ *
+ * On some architectures memory mapped IO needs to be accessed differently.
+ * On the simple architectures, we just read/write the memory location
+ * directly.
  */
+
 #ifndef __raw_readb
+#define __raw_readb __raw_readb
 static inline u8 __raw_readb(const volatile void __iomem *addr)
 {
-	return *(const volatile u8 __force *) addr;
+	return *(const volatile u8 __force *)addr;
 }
 #endif
 
 #ifndef __raw_readw
+#define __raw_readw __raw_readw
 static inline u16 __raw_readw(const volatile void __iomem *addr)
 {
-	return *(const volatile u16 __force *) addr;
+	return *(const volatile u16 __force *)addr;
 }
 #endif
 
 #ifndef __raw_readl
+#define __raw_readl __raw_readl
 static inline u32 __raw_readl(const volatile void __iomem *addr)
 {
-	return *(const volatile u32 __force *) addr;
+	return *(const volatile u32 __force *)addr;
 }
 #endif
 
-#define readb __raw_readb
-
-#define readw readw
-static inline u16 readw(const volatile void __iomem *addr)
-{
-	return __le16_to_cpu(__raw_readw(addr));
-}
-
-#define readl readl
-static inline u32 readl(const volatile void __iomem *addr)
+#ifdef CONFIG_64BIT
+#ifndef __raw_readq
+#define __raw_readq __raw_readq
+static inline u64 __raw_readq(const volatile void __iomem *addr)
 {
-	return __le32_to_cpu(__raw_readl(addr));
+	return *(const volatile u64 __force *)addr;
 }
+#endif
+#endif /* CONFIG_64BIT */
 
 #ifndef __raw_writeb
-static inline void __raw_writeb(u8 b, volatile void __iomem *addr)
+#define __raw_writeb __raw_writeb
+static inline void __raw_writeb(u8 value, volatile void __iomem *addr)
 {
-	*(volatile u8 __force *) addr = b;
+	*(volatile u8 __force *)addr = value;
 }
 #endif
 
 #ifndef __raw_writew
-static inline void __raw_writew(u16 b, volatile void __iomem *addr)
+#define __raw_writew __raw_writew
+static inline void __raw_writew(u16 value, volatile void __iomem *addr)
 {
-	*(volatile u16 __force *) addr = b;
+	*(volatile u16 __force *)addr = value;
 }
 #endif
 
 #ifndef __raw_writel
-static inline void __raw_writel(u32 b, volatile void __iomem *addr)
+#define __raw_writel __raw_writel
+static inline void __raw_writel(u32 value, volatile void __iomem *addr)
 {
-	*(volatile u32 __force *) addr = b;
+	*(volatile u32 __force *)addr = value;
 }
 #endif
 
-#define writeb __raw_writeb
-#define writew(b,addr) __raw_writew(__cpu_to_le16(b),addr)
-#define writel(b,addr) __raw_writel(__cpu_to_le32(b),addr)
-
 #ifdef CONFIG_64BIT
-#ifndef __raw_readq
-static inline u64 __raw_readq(const volatile void __iomem *addr)
+#ifndef __raw_writeq
+#define __raw_writeq __raw_writeq
+static inline void __raw_writeq(u64 value, volatile void __iomem *addr)
 {
-	return *(const volatile u64 __force *) addr;
+	*(volatile u64 __force *)addr = value;
 }
 #endif
+#endif /* CONFIG_64BIT */
 
-#define readq readq
-static inline u64 readq(const volatile void __iomem *addr)
-{
-	return __le64_to_cpu(__raw_readq(addr));
-}
+/*
+ * {read,write}{b,w,l,q}() access little endian memory and return result in
+ * native endianness.
+ */
 
-#ifndef __raw_writeq
-static inline void __raw_writeq(u64 b, volatile void __iomem *addr)
+#ifndef readb
+#define readb readb
+static inline u8 readb(const void __iomem *addr)
 {
-	*(volatile u64 __force *) addr = b;
+	return __raw_readb(addr);
 }
 #endif
 
-#define writeq(b, addr) __raw_writeq(__cpu_to_le64(b), addr)
-#endif /* CONFIG_64BIT */
-
-#ifndef PCI_IOBASE
-#define PCI_IOBASE ((void __iomem *) 0)
+#ifndef readw
+#define readw readw
+static inline u16 readw(const void __iomem *addr)
+{
+	return __le16_to_cpu(__raw_readw(addr));
+}
 #endif
 
-/*****************************************************************************/
-/*
- * traditional input/output functions
- */
-
-static inline u8 inb(unsigned long addr)
+#ifndef readl
+#define readl readl
+static inline u32 readl(const void __iomem *addr)
 {
-	return readb(addr + PCI_IOBASE);
+	return __le32_to_cpu(__raw_readl(addr));
 }
+#endif
 
-static inline u16 inw(unsigned long addr)
+#ifdef CONFIG_64BIT
+#ifndef readq
+#define readq readq
+static inline u64 readq(const void __iomem *addr)
 {
-	return readw(addr + PCI_IOBASE);
+	return __le64_to_cpu(__raw_readq(addr));
 }
+#endif
+#endif /* CONFIG_64BIT */
 
-static inline u32 inl(unsigned long addr)
+#ifndef writeb
+#define writeb writeb
+static inline void writeb(u8 value, void __iomem *addr)
 {
-	return readl(addr + PCI_IOBASE);
+	__raw_writeb(value, addr);
 }
+#endif
 
-static inline void outb(u8 b, unsigned long addr)
+#ifndef writew
+#define writew writew
+static inline void writew(u16 value, void __iomem *addr)
 {
-	writeb(b, addr + PCI_IOBASE);
+	__raw_writew(cpu_to_le16(value), addr);
 }
+#endif
 
-static inline void outw(u16 b, unsigned long addr)
+#ifndef writel
+#define writel writel
+static inline void writel(u32 value, void __iomem *addr)
 {
-	writew(b, addr + PCI_IOBASE);
+	__raw_writel(__cpu_to_le32(value), addr);
 }
+#endif
 
-static inline void outl(u32 b, unsigned long addr)
+#ifdef CONFIG_64BIT
+#ifndef writeq
+#define writeq writeq
+static inline void writeq(u64 value, void __iomem *addr)
 {
-	writel(b, addr + PCI_IOBASE);
+	__raw_writeq(__cpu_to_le64(value), addr);
 }
+#endif
+#endif /* CONFIG_64BIT */
 
-#define inb_p(addr)	inb(addr)
-#define inw_p(addr)	inw(addr)
-#define inl_p(addr)	inl(addr)
-#define outb_p(x, addr)	outb((x), (addr))
-#define outw_p(x, addr)	outw((x), (addr))
-#define outl_p(x, addr)	outl((x), (addr))
-
-#ifndef insb
-static inline void insb(unsigned long addr, void *buffer, int count)
+/*
+ * {read,write}s{b,w,l,q}() repeatedly access the same memory address in
+ * native endianness in 8-, 16-, 32- or 64-bit chunks (@count times).
+ */
+#ifndef readsb
+#define readsb readsb
+static inline void readsb(const void __iomem *addr, void *buffer,
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
+static inline void readsw(const void __iomem *addr, void *buffer,
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
+static inline void readsl(const void __iomem *addr, void *buffer,
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
+static inline void readsq(const void __iomem *addr, void *buffer,
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
+static inline void writesb(void __iomem *addr, const void *buffer,
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
+static inline void writesw(void __iomem *addr, const void *buffer,
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
+static inline void writesl(void __iomem *addr, const void *buffer,
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
-#define ioread8(addr)		readb(addr)
-#define ioread16(addr)		readw(addr)
-#define ioread16be(addr)	__be16_to_cpu(__raw_readw(addr))
-#define ioread32(addr)		readl(addr)
-#define ioread32be(addr)	__be32_to_cpu(__raw_readl(addr))
-
-#define iowrite8(v, addr)	writeb((v), (addr))
-#define iowrite16(v, addr)	writew((v), (addr))
-#define iowrite16be(v, addr)	__raw_writew(__cpu_to_be16(v), addr)
-#define iowrite32(v, addr)	writel((v), (addr))
-#define iowrite32be(v, addr)	__raw_writel(__cpu_to_be32(v), addr)
-
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
+static inline void writesq(void __iomem *addr, const void *buffer,
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
+
+#ifndef PCI_IOBASE
+#define PCI_IOBASE ((void __iomem *)0)
+#endif
 
 #ifndef IO_SPACE_LIMIT
 #define IO_SPACE_LIMIT 0xffff
 #endif
 
+/*
+ * {in,out}{b,w,l}() access little endian I/O. {in,out}{b,w,l}_p() can be
+ * implemented on hardware that needs an additional delay for I/O accesses to
+ * take effect.
+ */
+
+#ifndef inb
+#define inb inb
+static inline u8 inb(unsigned long addr)
+{
+	return readb(PCI_IOBASE + addr);
+}
+#endif
+
+#ifndef inw
+#define inw inw
+static inline u16 inw(unsigned long addr)
+{
+	return readw(PCI_IOBASE + addr);
+}
+#endif
+
+#ifndef inl
+#define inl inl
+static inline u32 inl(unsigned long addr)
+{
+	return readl(PCI_IOBASE + addr);
+}
+#endif
+
+#ifndef outb
+#define outb outb
+static inline void outb(u8 value, unsigned long addr)
+{
+	writeb(value, PCI_IOBASE + addr);
+}
+#endif
+
+#ifndef outw
+#define outw outw
+static inline void outw(u16 value, unsigned long addr)
+{
+	writew(value, PCI_IOBASE + addr);
+}
+#endif
+
+#ifndef outl
+#define outl outl
+static inline void outl(u32 value, unsigned long addr)
+{
+	writel(value, PCI_IOBASE + addr);
+}
+#endif
+
+#ifndef inb_p
+#define inb_p inb_p
+static inline u8 inb_p(unsigned long addr)
+{
+	return inb(addr);
+}
+#endif
+
+#ifndef inw_p
+#define inw_p inw_p
+static inline u16 inw_p(unsigned long addr)
+{
+	return inw(addr);
+}
+#endif
+
+#ifndef inl_p
+#define inl_p inl_p
+static inline u32 inl_p(unsigned long addr)
+{
+	return inl(addr);
+}
+#endif
+
+#ifndef outb_p
+#define outb_p outb_p
+static inline void outb_p(u8 value, unsigned long addr)
+{
+	outb(value, addr);
+}
+#endif
+
+#ifndef outw_p
+#define outw_p outw_p
+static inline void outw_p(u16 value, unsigned long addr)
+{
+	outw(value, addr);
+}
+#endif
+
+#ifndef outl_p
+#define outl_p outl_p
+static inline void outl_p(u32 value, unsigned long addr)
+{
+	outl(value, addr);
+}
+#endif
+
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
+#ifndef CONFIG_GENERIC_IOMAP
+static inline u8 ioread8(const void __iomem *addr)
+{
+	return readb(addr);
+}
+
+static inline u16 ioread16(const void __iomem *addr)
+{
+	return readw(addr);
+}
+
+static inline u32 ioread32(const void __iomem *addr)
+{
+	return readl(addr);
+}
+
+static inline void iowrite8(u8 value, void __iomem *addr)
+{
+	writeb(value, addr);
+}
+
+static inline void iowrite16(u16 value, void __iomem *addr)
+{
+	writew(value, addr);
+}
+
+static inline void iowrite32(u32 value, void __iomem *addr)
+{
+	writel(value, addr);
+}
+
+#ifndef ioread16be
+#define ioread16be ioread16be
+static inline u16 ioread16be(const void __iomem *addr)
+{
+	return __be16_to_cpu(__raw_readw(addr));
+}
+#endif
+
+#ifndef ioread32be
+#define ioread32be ioread32be
+static inline u32 ioread32be(const void __iomem *addr)
+{
+	return __be32_to_cpu(__raw_readl(addr));
+}
+#endif
+
+#ifndef iowrite16be
+#define iowrite16be iowrite16be
+static inline void iowrite16be(u16 value, void __iomem *addr)
+{
+	__raw_writew(__cpu_to_be16(value), addr);
+}
+#endif
+
+#ifndef iowrite32be
+#define iowrite32be iowrite32be
+static inline void iowrite32be(u32 value, void __iomem *addr)
+{
+	__raw_writel(__cpu_to_be32(value), addr);
+}
+#endif
+
+#ifndef ioread8_rep
+#define ioread8_rep ioread8_rep
+static inline void ioread8_rep(const void __iomem *addr, void *buffer,
+			       unsigned int count)
+{
+	readsb(addr, buffer, count);
+}
+#endif
+
+#ifndef ioread16_rep
+#define ioread16_rep ioread16_rep
+static inline void ioread16_rep(const void __iomem *addr, void *buffer,
+				unsigned int count)
+{
+	readsw(addr, buffer, count);
+}
+#endif
+
+#ifndef ioread32_rep
+#define ioread32_rep ioread32_rep
+static inline void ioread32_rep(const void __iomem *addr, void *buffer,
+				unsigned int count)
+{
+	readsl(addr, buffer, count);
+}
+#endif
+
+#ifndef iowrite8_rep
+#define iowrite8_rep iowrite8_rep
+static inline void iowrite8_rep(void __iomem *addr, const void *buffer,
+				unsigned int count)
+{
+	writesb(addr, buffer, count);
+}
+#endif
+
+#ifndef iowrite16_rep
+#define iowrite16_rep iowrite16_rep
+static inline void iowrite16_rep(void __iomem *addr, const void *buffer,
+				 unsigned int count)
+{
+	writesw(addr, buffer, count);
+}
+#endif
+
+#ifndef iowrite32_rep
+#define iowrite32_rep iowrite32_rep
+static inline void iowrite32_rep(void __iomem *addr, const void *buffer,
+				 unsigned int count)
+{
+	writesl(addr, buffer, count);
+}
+#endif
+#endif /* CONFIG_GENERIC_IOMAP */
+
 #ifdef __KERNEL__
 
 #include <linux/vmalloc.h>
@@ -278,6 +650,7 @@ struct pci_dev;
 extern void __iomem *pci_iomap(struct pci_dev *dev, int bar, unsigned long max);
 
 #ifndef pci_iounmap
+#define pci_iounmap pci_iounmap
 static inline void pci_iounmap(struct pci_dev *dev, void __iomem *p)
 {
 }
@@ -289,11 +662,15 @@ static inline void pci_iounmap(struct pci_dev *dev, void __iomem *p)
  * These are pretty trivial
  */
 #ifndef virt_to_phys
+#define virt_to_phys virt_to_phys
 static inline unsigned long virt_to_phys(volatile void *address)
 {
 	return __pa((unsigned long)address);
 }
+#endif
 
+#ifndef phys_to_virt
+#define phys_to_virt phys_to_virt
 static inline void *phys_to_virt(unsigned long address)
 {
 	return __va(address);
@@ -306,20 +683,33 @@ static inline void *phys_to_virt(unsigned long address)
  * This implementation is for the no-MMU case only... if you have an MMU
  * you'll need to provide your own definitions.
  */
+
 #ifndef CONFIG_MMU
-static inline void __iomem *ioremap(phys_addr_t offset, unsigned long size)
+static inline void __iomem *ioremap(phys_addr_t offset, size_t size)
 {
-	return (void __iomem*) (unsigned long)offset;
+	return (void __iomem *)(unsigned long)offset;
 }
 
-#define __ioremap(offset, size, flags)	ioremap(offset, size)
+static inline void __iomem *__ioremap(phys_addr_t offset, size_t size,
+				      unsigned long flags)
+{
+	return ioremap(offset, size);
+}
 
 #ifndef ioremap_nocache
-#define ioremap_nocache ioremap
+#define ioremap_nocache ioremap_nocache
+static inline void __iomem *ioremap_nocache(phys_addr_t offset, size_t size)
+{
+	return ioremap(offset, size);
+}
 #endif
 
 #ifndef ioremap_wc
-#define ioremap_wc ioremap_nocache
+#define ioremap_wc ioremap_wc
+static inline void __iomem *ioremap_wc(phys_addr_t offset, size_t size)
+{
+	return ioremap_nocache(offset, size);
+}
 #endif
 
 static inline void iounmap(void __iomem *addr)
@@ -329,14 +719,20 @@ static inline void iounmap(void __iomem *addr)
 
 #ifdef CONFIG_HAS_IOPORT_MAP
 #ifndef CONFIG_GENERIC_IOMAP
+#ifndef ioport_map
+#define ioport_map ioport_map
 static inline void __iomem *ioport_map(unsigned long port, unsigned int nr)
 {
-	return (void __iomem *) port;
+	return PCI_IOBASE + (port & IO_SPACE_LIMIT);
 }
+#endif
 
+#ifndef ioport_unmap
+#define ioport_unmap ioport_unmap
 static inline void ioport_unmap(void __iomem *p)
 {
 }
+#endif
 #else /* CONFIG_GENERIC_IOMAP */
 extern void __iomem *ioport_map(unsigned long port, unsigned int nr);
 extern void ioport_unmap(void __iomem *p);
@@ -344,35 +740,66 @@ extern void ioport_unmap(void __iomem *p);
 #endif /* CONFIG_HAS_IOPORT_MAP */
 
 #ifndef xlate_dev_kmem_ptr
-#define xlate_dev_kmem_ptr(p)	p
+#define xlate_dev_kmem_ptr xlate_dev_kmem_ptr
+static inline void *xlate_dev_kmem_ptr(void *addr)
+{
+	return addr;
+}
 #endif
+
 #ifndef xlate_dev_mem_ptr
-#define xlate_dev_mem_ptr(p)	__va(p)
+#define xlate_dev_mem_ptr xlate_dev_mem_ptr
+static inline void *xlate_dev_mem_ptr(phys_addr_t addr)
+{
+	return __va(addr);
+}
+#endif
+
+#ifndef unxlate_dev_mem_ptr
+#define unxlate_dev_mem_ptr unxlate_dev_mem_ptr
+static inline void unxlate_dev_mem_ptr(phys_addr_t phys, void *addr)
+{
+}
 #endif
 
 #ifdef CONFIG_VIRT_TO_BUS
 #ifndef virt_to_bus
-static inline unsigned long virt_to_bus(volatile void *address)
+static inline unsigned long virt_to_bus(void *address)
 {
-	return ((unsigned long) address);
+	return (unsigned long)address;
 }
 
 static inline void *bus_to_virt(unsigned long address)
 {
-	return (void *) address;
+	return (void *)address;
 }
 #endif
 #endif
 
 #ifndef memset_io
-#define memset_io(a, b, c)	memset(__io_virt(a), (b), (c))
+#define memset_io memset_io
+static inline void memset_io(void __iomem *addr, int value, size_t size)
+{
+	memset(__io_virt(addr), value, size);
+}
 #endif
 
 #ifndef memcpy_fromio
-#define memcpy_fromio(a, b, c)	memcpy((a), __io_virt(b), (c))
+#define memcpy_fromio memcpy_fromio
+static inline void memcpy_fromio(void *buffer, const void __iomem *addr,
+				 size_t size)
+{
+	memcpy(buffer, __io_virt(addr), size);
+}
 #endif
+
 #ifndef memcpy_toio
-#define memcpy_toio(a, b, c)	memcpy(__io_virt(a), (b), (c))
+#define memcpy_toio memcpy_toio
+static inline void memcpy_toio(void __iomem *addr, const void *buffer,
+			       size_t size)
+{
+	memcpy(__io_virt(addr), buffer, size);
+}
 #endif
 
 #endif /* __KERNEL__ */
-- 
2.0.4

