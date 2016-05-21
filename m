From: Andrea Gelmini <andrea.gelmini@gelma.net>
Date: Sat, 21 May 2016 11:56:20 +0000
Subject: [PATCH 0153/1529] Fix typo
Message-Id: <20160521115620.7477-1-andrea.gelmini@gelma.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Signed-off-by: Andrea Gelmini <andrea.gelmini@gelma.net>
---
 arch/ia64/include/asm/pal.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/ia64/include/asm/pal.h b/arch/ia64/include/asm/pal.h
index 2e69284..75b3d46 100644
--- a/arch/ia64/include/asm/pal.h
+++ b/arch/ia64/include/asm/pal.h
@@ -920,7 +920,7 @@ ia64_pal_cache_config_info (u64 cache_level, u64 cache_type, pal_cache_config_in
 
 }
 
-/* Get detailed cche protection information */
+/* Get detailed cache protection information */
 static inline s64
 ia64_pal_cache_prot_info (u64 cache_level, u64 cache_type, pal_cache_protection_info_t *prot)
 {
-- 
2.8.2.534.g1f66975

