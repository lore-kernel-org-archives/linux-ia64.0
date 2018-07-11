From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 11 Jul 2018 12:08:06 +0000
Subject: [PATCH 2/2] sparc64: add reads{b,w,l}/writes{b,w,l}
Message-Id: <20180711120824.3882108-2-arnd@arndb.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180711120824.3882108-1-arnd@arndb.de>
In-Reply-To: <20180711120824.3882108-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>, Arnd Bergmann <arnd@arndb.de>
Cc: Boris Brezillon <boris.brezillon@bootlin.com>, linux-ia64@vger.kernel.org, linux-alpha@vger.kernel.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org

Some drivers need these for compile-testing. On most architectures
they come from asm-generic/io.h, but not on sparc64, which has its
own definitions.

Since we already have ioread*_rep()/iowrite*_rep() that have the
same behavior on sparc64 (i.e. all PCI I/O space is memory mapped),
we can rename the existing helpers and add macros to define them
to the same implementation.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 arch/sparc/include/asm/io_64.h | 19 +++++++++++++------
 1 file changed, 13 insertions(+), 6 deletions(-)

diff --git a/arch/sparc/include/asm/io_64.h b/arch/sparc/include/asm/io_64.h
index 9a1e9cbc7e6d..b162c23ae8c2 100644
--- a/arch/sparc/include/asm/io_64.h
+++ b/arch/sparc/include/asm/io_64.h
@@ -243,35 +243,42 @@ void insb(unsigned long, void *, unsigned long);
 void insw(unsigned long, void *, unsigned long);
 void insl(unsigned long, void *, unsigned long);
 
-static inline void ioread8_rep(void __iomem *port, void *buf, unsigned long count)
+static inline void readsb(void __iomem *port, void *buf, unsigned long count)
 {
 	insb((unsigned long __force)port, buf, count);
 }
-static inline void ioread16_rep(void __iomem *port, void *buf, unsigned long count)
+static inline void readsw(void __iomem *port, void *buf, unsigned long count)
 {
 	insw((unsigned long __force)port, buf, count);
 }
 
-static inline void ioread32_rep(void __iomem *port, void *buf, unsigned long count)
+static inline void readsl(void __iomem *port, void *buf, unsigned long count)
 {
 	insl((unsigned long __force)port, buf, count);
 }
 
-static inline void iowrite8_rep(void __iomem *port, const void *buf, unsigned long count)
+static inline void writesb(void __iomem *port, const void *buf, unsigned long count)
 {
 	outsb((unsigned long __force)port, buf, count);
 }
 
-static inline void iowrite16_rep(void __iomem *port, const void *buf, unsigned long count)
+static inline void writesw(void __iomem *port, const void *buf, unsigned long count)
 {
 	outsw((unsigned long __force)port, buf, count);
 }
 
-static inline void iowrite32_rep(void __iomem *port, const void *buf, unsigned long count)
+static inline void writesl(void __iomem *port, const void *buf, unsigned long count)
 {
 	outsl((unsigned long __force)port, buf, count);
 }
 
+#define ioread8_rep(p,d,l)	readsb(p,d,l)
+#define ioread16_rep(p,d,l)	readsw(p,d,l)
+#define ioread32_rep(p,d,l)	readsl(p,d,l)
+#define iowrite8_rep(p,d,l)	writesb(p,d,l)
+#define iowrite16_rep(p,d,l)	writesw(p,d,l)
+#define iowrite32_rep(p,d,l)	writesl(p,d,l)
+
 /* Valid I/O Space regions are anywhere, because each PCI bus supported
  * can live in an arbitrary area of the physical address range.
  */
-- 
2.9.0

