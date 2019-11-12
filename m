From: Christoph Hellwig <hch@lst.de>
Date: Tue, 12 Nov 2019 10:55:07 +0000
Subject: Re: [PATCH] video: fbdev: atyfb: only use ioremap_uc() on i386 and ia64
Message-Id: <20191112105507.GA7122@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191111192258.2234502-1-arnd@arndb.de>
In-Reply-To: <20191111192258.2234502-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>
Cc: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Christoph Hellwig <hch@lst.de>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Maarten Lankhorst <maarten.lankhorst@linux.intel.com>, Daniel Vetter <daniel.vetter@ffwll.ch>, Souptick Joarder <jrdr.linux@gmail.com>, dri-devel@lists.freedesktop.org, linux-fbdev@vger.kernel.org, linux-kernel@vger.kernel.org, Luis Chamberlain <mcgrof@kernel.org>

On Mon, Nov 11, 2019 at 08:22:50PM +0100, Arnd Bergmann wrote:
> ioremap_uc() is only meaningful on old x86-32 systems with the PAT
> extension, and on ia64 with its slightly unconventional ioremap()
> behavior, everywhere else this is the same as ioremap() anyway.
> 
> Change the only driver that still references ioremap_uc() to only do so
> on x86-32/ia64 in order to allow removing that interface at some
> point in the future for the other architectures.
> 
> On some architectures, ioremap_uc() just returns NULL, changing
> the driver to call ioremap() means that they now have a chance
> of working correctly.

So this whole area is a bit of a mess.  ioremap_uc on ia64 is brand
new in this cycle, for ia64-internal users that were previously
using ioremap_nocache.  And ioremap_nocache was identical to ioremap
everywhere but ia64.  So I think we can safely skip ia64 in the ifdef
if we go down that route.

But also on x86 I'd actually rather prefer killing off this only mainline
user of ioremap_uc.  It was added by Luis in commit 3cc2dac5be3f
("drivers/video/fbdev/atyfb: Replace MTRR UC hole with strong UC",
which looks like an optimization of MTRR usage.  I feel like I really
don't understand the point there, but it also seems a pity to keep
the API around just for that.

That being said linux-next added another call to ioremap_uc in
drivers/mfd/intel-lpss.c, so it looks like the API might have to stay.

So I guess modulo excluding ia64 your patch looks fine, and should go
along something like the one below.  I'll happily carry them in the
ioremap tree with the right ACKs.

---
From 81243b2aa78babcc5f97b2c2a29957fcf3fd3664 Mon Sep 17 00:00:00 2001
From: Christoph Hellwig <hch@lst.de>
Date: Tue, 12 Nov 2019 11:52:25 +0100
Subject: ioremap: remove ioremap_uc except on x86 and ia64

ioremap_uc is a special API to work around caching oddities on
Intel platforms.  Remove it from all other architectures now that
only x86 and ia64-specific callers are left.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/alpha/include/asm/io.h    |  1 -
 arch/m68k/include/asm/kmap.h   |  1 -
 arch/mips/include/asm/io.h     |  1 -
 arch/parisc/include/asm/io.h   |  1 -
 arch/powerpc/include/asm/io.h  |  1 -
 arch/sh/include/asm/io.h       |  1 -
 arch/sparc/include/asm/io_64.h |  1 -
 include/asm-generic/io.h       | 15 ---------------
 include/linux/io.h             |  2 ++
 lib/devres.c                   |  4 ++++
 10 files changed, 6 insertions(+), 22 deletions(-)

diff --git a/arch/alpha/include/asm/io.h b/arch/alpha/include/asm/io.h
index 1989b946a28d..11fdcade3c5c 100644
--- a/arch/alpha/include/asm/io.h
+++ b/arch/alpha/include/asm/io.h
@@ -290,7 +290,6 @@ static inline void __iomem * ioremap_nocache(unsigned long offset,
 }
 
 #define ioremap_wc ioremap_nocache
-#define ioremap_uc ioremap_nocache
 
 static inline void iounmap(volatile void __iomem *addr)
 {
diff --git a/arch/m68k/include/asm/kmap.h b/arch/m68k/include/asm/kmap.h
index 559cb91bede1..22b5ea4fc8b8 100644
--- a/arch/m68k/include/asm/kmap.h
+++ b/arch/m68k/include/asm/kmap.h
@@ -28,7 +28,6 @@ static inline void __iomem *ioremap(unsigned long physaddr, unsigned long size)
 }
 
 #define ioremap_nocache ioremap
-#define ioremap_uc ioremap
 #define ioremap_wt ioremap_wt
 static inline void __iomem *ioremap_wt(unsigned long physaddr,
 				       unsigned long size)
diff --git a/arch/mips/include/asm/io.h b/arch/mips/include/asm/io.h
index 3f6ce74335b4..9195ded1d6a7 100644
--- a/arch/mips/include/asm/io.h
+++ b/arch/mips/include/asm/io.h
@@ -249,7 +249,6 @@ static inline void __iomem *ioremap_prot(phys_addr_t offset,
  */
 #define ioremap_nocache(offset, size)					\
 	__ioremap_mode((offset), (size), _CACHE_UNCACHED)
-#define ioremap_uc ioremap_nocache
 
 /*
  * ioremap_cache -	map bus memory into CPU space
diff --git a/arch/parisc/include/asm/io.h b/arch/parisc/include/asm/io.h
index 46212b52c23e..0674f5cd3045 100644
--- a/arch/parisc/include/asm/io.h
+++ b/arch/parisc/include/asm/io.h
@@ -130,7 +130,6 @@ static inline void gsc_writeq(unsigned long long val, unsigned long addr)
 void __iomem *ioremap(unsigned long offset, unsigned long size);
 #define ioremap_nocache(off, sz)	ioremap((off), (sz))
 #define ioremap_wc			ioremap_nocache
-#define ioremap_uc			ioremap_nocache
 
 extern void iounmap(const volatile void __iomem *addr);
 
diff --git a/arch/powerpc/include/asm/io.h b/arch/powerpc/include/asm/io.h
index a63ec938636d..119bcbe3e328 100644
--- a/arch/powerpc/include/asm/io.h
+++ b/arch/powerpc/include/asm/io.h
@@ -716,7 +716,6 @@ extern void __iomem *ioremap_wc(phys_addr_t address, unsigned long size);
 void __iomem *ioremap_wt(phys_addr_t address, unsigned long size);
 void __iomem *ioremap_coherent(phys_addr_t address, unsigned long size);
 #define ioremap_nocache(addr, size)	ioremap((addr), (size))
-#define ioremap_uc(addr, size)		ioremap((addr), (size))
 #define ioremap_cache(addr, size) \
 	ioremap_prot((addr), (size), pgprot_val(PAGE_KERNEL))
 
diff --git a/arch/sh/include/asm/io.h b/arch/sh/include/asm/io.h
index 1495489225ac..30bbe787f1ef 100644
--- a/arch/sh/include/asm/io.h
+++ b/arch/sh/include/asm/io.h
@@ -368,7 +368,6 @@ static inline int iounmap_fixed(void __iomem *addr) { return -EINVAL; }
 #endif
 
 #define ioremap_nocache	ioremap
-#define ioremap_uc	ioremap
 
 /*
  * Convert a physical pointer to a virtual kernel pointer for /dev/mem
diff --git a/arch/sparc/include/asm/io_64.h b/arch/sparc/include/asm/io_64.h
index f4afa301954a..688911051b44 100644
--- a/arch/sparc/include/asm/io_64.h
+++ b/arch/sparc/include/asm/io_64.h
@@ -407,7 +407,6 @@ static inline void __iomem *ioremap(unsigned long offset, unsigned long size)
 }
 
 #define ioremap_nocache(X,Y)		ioremap((X),(Y))
-#define ioremap_uc(X,Y)			ioremap((X),(Y))
 #define ioremap_wc(X,Y)			ioremap((X),(Y))
 #define ioremap_wt(X,Y)			ioremap((X),(Y))
 
diff --git a/include/asm-generic/io.h b/include/asm-generic/io.h
index 325fc98cc9ff..357e8638040c 100644
--- a/include/asm-generic/io.h
+++ b/include/asm-generic/io.h
@@ -972,21 +972,6 @@ static inline void __iomem *ioremap(phys_addr_t addr, size_t size)
 #define ioremap_wt ioremap
 #endif
 
-/*
- * ioremap_uc is special in that we do require an explicit architecture
- * implementation.  In general you do not want to use this function in a
- * driver and use plain ioremap, which is uncached by default.  Similarly
- * architectures should not implement it unless they have a very good
- * reason.
- */
-#ifndef ioremap_uc
-#define ioremap_uc ioremap_uc
-static inline void __iomem *ioremap_uc(phys_addr_t offset, size_t size)
-{
-	return NULL;
-}
-#endif
-
 #ifdef CONFIG_HAS_IOPORT_MAP
 #ifndef CONFIG_GENERIC_IOMAP
 #ifndef ioport_map
diff --git a/include/linux/io.h b/include/linux/io.h
index a59834bc0a11..6574bb0f28e6 100644
--- a/include/linux/io.h
+++ b/include/linux/io.h
@@ -64,8 +64,10 @@ static inline void devm_ioport_unmap(struct device *dev, void __iomem *addr)
 
 void __iomem *devm_ioremap(struct device *dev, resource_size_t offset,
 			   resource_size_t size);
+#ifdef ioremap_uc
 void __iomem *devm_ioremap_uc(struct device *dev, resource_size_t offset,
 				   resource_size_t size);
+#endif
 void __iomem *devm_ioremap_nocache(struct device *dev, resource_size_t offset,
 				   resource_size_t size);
 void __iomem *devm_ioremap_wc(struct device *dev, resource_size_t offset,
diff --git a/lib/devres.c b/lib/devres.c
index f56070cf970b..0299279ddf02 100644
--- a/lib/devres.c
+++ b/lib/devres.c
@@ -40,9 +40,11 @@ static void __iomem *__devm_ioremap(struct device *dev, resource_size_t offset,
 	case DEVM_IOREMAP_NC:
 		addr = ioremap_nocache(offset, size);
 		break;
+#ifdef ioremap_uc
 	case DEVM_IOREMAP_UC:
 		addr = ioremap_uc(offset, size);
 		break;
+#endif
 	case DEVM_IOREMAP_WC:
 		addr = ioremap_wc(offset, size);
 		break;
@@ -72,6 +74,7 @@ void __iomem *devm_ioremap(struct device *dev, resource_size_t offset,
 }
 EXPORT_SYMBOL(devm_ioremap);
 
+#ifdef ioremap_uc
 /**
  * devm_ioremap_uc - Managed ioremap_uc()
  * @dev: Generic device to remap IO address for
@@ -86,6 +89,7 @@ void __iomem *devm_ioremap_uc(struct device *dev, resource_size_t offset,
 	return __devm_ioremap(dev, offset, size, DEVM_IOREMAP_UC);
 }
 EXPORT_SYMBOL_GPL(devm_ioremap_uc);
+#endif /* ioremap_uc */
 
 /**
  * devm_ioremap_nocache - Managed ioremap_nocache()
-- 
2.20.1
