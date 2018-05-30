From: Li Qiang <liq3ea@gmail.com>
Date: Wed, 30 May 2018 06:03:14 +0000
Subject: [PATCH] ia64: pgtable.h: fix a comment typo
Message-Id: <1527660194-4265-1-git-send-email-liq3ea@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com, fenghua.yu@intel.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Li Qiang <liq3ea@gmail.com>

Signed-off-by: Li Qiang <liq3ea@gmail.com>
---
 arch/ia64/include/asm/pgtable.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/ia64/include/asm/pgtable.h b/arch/ia64/include/asm/pgtable.h
index 165827774bea..2cccfbb23c2d 100644
--- a/arch/ia64/include/asm/pgtable.h
+++ b/arch/ia64/include/asm/pgtable.h
@@ -336,7 +336,7 @@ static inline void set_pte(pte_t *ptep, pte_t pteval)
 	if (pte_present_exec_user(pteval) &&
 	    (!pte_present(*ptep) ||
 		pte_pfn(*ptep) != pte_pfn(pteval)))
-		/* load_module() calles flush_icache_range() explicitly*/
+		/* load_module() calls flush_icache_range() explicitly*/
 		__ia64_sync_icache_dcache(pteval);
 	*ptep = pteval;
 }
-- 
2.11.0

