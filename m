From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Sun, 26 Jun 2022 02:33:14 +0000
Subject: [PATCH] ia64: old_rr4 added under CONFIG_HUGETLB_PAGE
Message-Id: <20220626022114.4020-1-jrdr.linux@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, "Souptick Joarder (HPE)" <jrdr.linux@gmail.com>, kernel test robot <lkp@intel.com>

From: "Souptick Joarder (HPE)" <jrdr.linux@gmail.com>

kernel test robot throws below warning ->

arch/ia64/include/asm/mmu_context.h: In function 'reload_context':
   arch/ia64/include/asm/mmu_context.h:127:48: warning: variable
'old_rr4' set but not used [-Wunused-but-set-variable]
     127 |         unsigned long rr0, rr1, rr2, rr3, rr4, old_rr4;

Added it under CONFIG_HUGETLB_PAGE

Reported-by: kernel test robot <lkp@intel.com>
Signed-off-by: Souptick Joarder (HPE) <jrdr.linux@gmail.com>
---
 arch/ia64/include/asm/mmu_context.h | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/arch/ia64/include/asm/mmu_context.h b/arch/ia64/include/asm/mmu_context.h
index 87a0d5bc11ef..06257e355d00 100644
--- a/arch/ia64/include/asm/mmu_context.h
+++ b/arch/ia64/include/asm/mmu_context.h
@@ -124,9 +124,12 @@ reload_context (nv_mm_context_t context)
 {
 	unsigned long rid;
 	unsigned long rid_incr = 0;
-	unsigned long rr0, rr1, rr2, rr3, rr4, old_rr4;
+	unsigned long rr0, rr1, rr2, rr3, rr4;
 
+#ifdef CONFIG_HUGETLB_PAGE
+	unsigned long old_rr4;
 	old_rr4 = ia64_get_rr(RGN_BASE(RGN_HPAGE));
+#endif
 	rid = context << 3;	/* make space for encoding the region number */
 	rid_incr = 1 << 8;
 
-- 
2.25.1
