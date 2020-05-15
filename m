From: Christoph Hellwig <hch@lst.de>
Date: Fri, 15 May 2020 14:36:38 +0000
Subject: [PATCH 21/29] sh: implement flush_icache_user_range
Message-Id: <20200515143646.3857579-22-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200515143646.3857579-1-hch@lst.de>
In-Reply-To: <20200515143646.3857579-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Roman Zippel <zippel@linux-m68k.org>
Cc: Jessica Yu <jeyu@kernel.org>, Michal Simek <monstr@monstr.eu>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, openrisc@lists.librecores.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-um@lists.infradead.org, linux-xtensa@linux-xtensa.org, linux-fsdevel@vger.kernel.org

The SuperH implementation of flush_icache_range seems to be able to
cope with user addresses.  Just define flush_icache_user_range to
flush_icache_range.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/sh/include/asm/cacheflush.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/sh/include/asm/cacheflush.h b/arch/sh/include/asm/cacheflush.h
index b932e42ef0284..fe7400079b97b 100644
--- a/arch/sh/include/asm/cacheflush.h
+++ b/arch/sh/include/asm/cacheflush.h
@@ -46,6 +46,7 @@ extern void flush_cache_range(struct vm_area_struct *vma,
 #define ARCH_IMPLEMENTS_FLUSH_DCACHE_PAGE 1
 extern void flush_dcache_page(struct page *page);
 extern void flush_icache_range(unsigned long start, unsigned long end);
+#define flush_icache_user_range flush_icache_range
 extern void flush_icache_page(struct vm_area_struct *vma,
 				 struct page *page);
 extern void flush_cache_sigtramp(unsigned long address);
-- 
2.26.2
