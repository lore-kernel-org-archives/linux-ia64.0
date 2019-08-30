From: Christoph Hellwig <hch@lst.de>
Date: Fri, 30 Aug 2019 16:12:36 +0000
Subject: [PATCH 2/3] microblaze: remove ioremap_fullcache
Message-Id: <20190830161237.23033-3-hch@lst.de>
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
---
 arch/microblaze/include/asm/io.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/arch/microblaze/include/asm/io.h b/arch/microblaze/include/asm/io.h
index c7968139486f..86c95b2a1ce1 100644
--- a/arch/microblaze/include/asm/io.h
+++ b/arch/microblaze/include/asm/io.h
@@ -40,7 +40,6 @@ extern void iounmap(volatile void __iomem *addr);
 
 extern void __iomem *ioremap(phys_addr_t address, unsigned long size);
 #define ioremap_nocache(addr, size)		ioremap((addr), (size))
-#define ioremap_fullcache(addr, size)		ioremap((addr), (size))
 #define ioremap_wc(addr, size)			ioremap((addr), (size))
 #define ioremap_wt(addr, size)			ioremap((addr), (size))
 
-- 
2.20.1
