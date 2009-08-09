From: Jaswinder Singh Rajput <jaswinder@kernel.org>
Date: Sun, 09 Aug 2009 15:39:27 +0000
Subject: [PATCH] IA64: includecheck fix: ia64, pgtable.h
Message-Id: <1249831647.2957.29.camel@ht.satnam>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


fix the following 'make includecheck' warning:

  arch/ia64/include/asm/pgtable.h: asm/processor.h is included more than once.

Signed-off-by: Jaswinder Singh Rajput <jaswinderrajput@gmail.com>
---
 arch/ia64/include/asm/pgtable.h |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/arch/ia64/include/asm/pgtable.h b/arch/ia64/include/asm/pgtable.h
index 0a9cc73..8840a69 100644
--- a/arch/ia64/include/asm/pgtable.h
+++ b/arch/ia64/include/asm/pgtable.h
@@ -155,7 +155,6 @@
 #include <linux/bitops.h>
 #include <asm/cacheflush.h>
 #include <asm/mmu_context.h>
-#include <asm/processor.h>
 
 /*
  * Next come the mappings that determine how mmap() protection bits
-- 
1.6.0.6


