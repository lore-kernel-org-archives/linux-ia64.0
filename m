From: Andrea Gelmini <andrea.gelmini@gelma.net>
Date: Sat, 21 May 2016 11:55:58 +0000
Subject: [PATCH 0150/1529] Fix typo
Message-Id: <20160521115558.7319-1-andrea.gelmini@gelma.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Signed-off-by: Andrea Gelmini <andrea.gelmini@gelma.net>
---
 arch/ia64/include/asm/mmu_context.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/ia64/include/asm/mmu_context.h b/arch/ia64/include/asm/mmu_context.h
index 7f2a456..f509ab9 100644
--- a/arch/ia64/include/asm/mmu_context.h
+++ b/arch/ia64/include/asm/mmu_context.h
@@ -12,7 +12,7 @@
  * due to context switches.  Context numbers are implemented using ia-64
  * region ids.  Since the IA-64 TLB does not consider the region number when
  * performing a TLB lookup, we need to assign a unique region id to each
- * region in a process.  We use the least significant three bits in aregion
+ * region in a process.  We use the least significant three bits in a region
  * id for this purpose.
  */
 
-- 
2.8.2.534.g1f66975

