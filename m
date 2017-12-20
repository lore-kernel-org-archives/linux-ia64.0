From: Corentin Labbe <clabbe.montjoie@gmail.com>
Date: Wed, 20 Dec 2017 19:16:13 +0000
Subject: [PATCH] ia64: agp: Replace empty define with do while
Message-Id: <20171220191613.7827-1-clabbe.montjoie@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: fenghua.yu@intel.com, tony.luck@intel.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Corentin Labbe <clabbe.montjoie@gmail.com>

It's dangerous to use empty code define.
Furthermore it lead to the following warning:
drivers/char/agp/generic.c: In function « agp_generic_destroy_page »:
drivers/char/agp/generic.c:1266:28: attention : suggest braces around empty body in an « if » statement [-Wempty-body]

So let's replace emptyness by "do {} while(0)"

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 arch/ia64/include/asm/agp.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/ia64/include/asm/agp.h b/arch/ia64/include/asm/agp.h
index 2b451c4496da..0261507dc264 100644
--- a/arch/ia64/include/asm/agp.h
+++ b/arch/ia64/include/asm/agp.h
@@ -14,8 +14,8 @@
  * in coherent mode, which lets us map the AGP memory as normal (write-back) memory
  * (unlike x86, where it gets mapped "write-coalescing").
  */
-#define map_page_into_agp(page)		/* nothing */
-#define unmap_page_from_agp(page)	/* nothing */
+#define map_page_into_agp(page)		do { } while (0)
+#define unmap_page_from_agp(page)	do { } while (0)
 #define flush_agp_cache()		mb()
 
 /* GATT allocation. Returns/accepts GATT kernel virtual address. */
-- 
2.13.6

