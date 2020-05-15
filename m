From: Christoph Hellwig <hch@lst.de>
Date: Fri, 15 May 2020 14:36:26 +0000
Subject: [PATCH 09/29] arm64: use asm-generic/cacheflush.h
Message-Id: <20200515143646.3857579-10-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200515143646.3857579-1-hch@lst.de>
In-Reply-To: <20200515143646.3857579-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Roman Zippel <zippel@linux-m68k.org>
Cc: Jessica Yu <jeyu@kernel.org>, Michal Simek <monstr@monstr.eu>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, openrisc@lists.librecores.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-um@lists.infradead.org, linux-xtensa@linux-xtensa.org, linux-fsdevel@vger.kernel.org

ARM64 needs almost no cache flushing routines of its own.  Rely on
asm-generic/cacheflush.h for the defaults.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/arm64/include/asm/cacheflush.h | 46 ++++-------------------------
 1 file changed, 5 insertions(+), 41 deletions(-)

diff --git a/arch/arm64/include/asm/cacheflush.h b/arch/arm64/include/asm/cacheflush.h
index e6cca3d4acf70..03a5a187163ab 100644
--- a/arch/arm64/include/asm/cacheflush.h
+++ b/arch/arm64/include/asm/cacheflush.h
@@ -94,20 +94,7 @@ static inline void flush_icache_range(unsigned long start, unsigned long end)
 #endif
 	kick_all_cpus_sync();
 }
-
-static inline void flush_cache_mm(struct mm_struct *mm)
-{
-}
-
-static inline void flush_cache_page(struct vm_area_struct *vma,
-				    unsigned long user_addr, unsigned long pfn)
-{
-}
-
-static inline void flush_cache_range(struct vm_area_struct *vma,
-				     unsigned long start, unsigned long end)
-{
-}
+#define flush_icache_range flush_icache_range
 
 /*
  * Cache maintenance functions used by the DMA API. No to be used directly.
@@ -123,12 +110,7 @@ extern void __dma_flush_area(const void *, size_t);
  */
 extern void copy_to_user_page(struct vm_area_struct *, struct page *,
 	unsigned long, void *, const void *, unsigned long);
-#define copy_from_user_page(vma, page, vaddr, dst, src, len) \
-	do {							\
-		memcpy(dst, src, len);				\
-	} while (0)
-
-#define flush_cache_dup_mm(mm) flush_cache_mm(mm)
+#define copy_to_user_page copy_to_user_page
 
 /*
  * flush_dcache_page is used when the kernel has written to the page
@@ -154,29 +136,11 @@ static __always_inline void __flush_icache_all(void)
 	dsb(ish);
 }
 
-#define flush_dcache_mmap_lock(mapping)		do { } while (0)
-#define flush_dcache_mmap_unlock(mapping)	do { } while (0)
-
-/*
- * We don't appear to need to do anything here.  In fact, if we did, we'd
- * duplicate cache flushing elsewhere performed by flush_dcache_page().
- */
-#define flush_icache_page(vma,page)	do { } while (0)
-
-/*
- * Not required on AArch64 (PIPT or VIPT non-aliasing D-cache).
- */
-static inline void flush_cache_vmap(unsigned long start, unsigned long end)
-{
-}
-
-static inline void flush_cache_vunmap(unsigned long start, unsigned long end)
-{
-}
-
 int set_memory_valid(unsigned long addr, int numpages, int enable);
 
 int set_direct_map_invalid_noflush(struct page *page);
 int set_direct_map_default_noflush(struct page *page);
 
-#endif
+#include <asm-generic/cacheflush.h>
+
+#endif /* __ASM_CACHEFLUSH_H */
-- 
2.26.2
