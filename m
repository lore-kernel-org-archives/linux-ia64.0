From: Christoph Hellwig <hch@lst.de>
Date: Fri, 30 Aug 2019 16:12:35 +0000
Subject: [PATCH 1/3] m68k: remove ioremap_fullcache
Message-Id: <20190830161237.23033-2-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190830161237.23033-1-hch@lst.de>
In-Reply-To: <20190830161237.23033-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Michal Simek <monstr@monstr.eu>, Tony Luck <tony.luck@intel.com>, Geert Uytterhoeven <geert@linux-m68k.org>
Cc: linux-m68k@lists.linux-m68k.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

No callers of this function.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Acked-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 arch/m68k/include/asm/kmap.h | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/arch/m68k/include/asm/kmap.h b/arch/m68k/include/asm/kmap.h
index aac7f045f7f0..03d904fe6087 100644
--- a/arch/m68k/include/asm/kmap.h
+++ b/arch/m68k/include/asm/kmap.h
@@ -43,13 +43,6 @@ static inline void __iomem *ioremap_wt(unsigned long physaddr,
 	return __ioremap(physaddr, size, IOMAP_WRITETHROUGH);
 }
 
-#define ioremap_fullcache ioremap_fullcache
-static inline void __iomem *ioremap_fullcache(unsigned long physaddr,
-					      unsigned long size)
-{
-	return __ioremap(physaddr, size, IOMAP_FULL_CACHING);
-}
-
 #define memset_io memset_io
 static inline void memset_io(volatile void __iomem *addr, unsigned char val,
 			     int count)
-- 
2.20.1
