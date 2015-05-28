From: Dominik Dingel <dingel@linux.vnet.ibm.com>
Date: Thu, 28 May 2015 11:52:37 +0000
Subject: [PATCH 5/5] s390/mm: forward check for huge pmds to pmd_large()
Message-Id: <1432813957-46874-6-git-send-email-dingel@linux.vnet.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1432813957-46874-1-git-send-email-dingel@linux.vnet.ibm.com>
In-Reply-To: <1432813957-46874-1-git-send-email-dingel@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

We already do the check in pmd_large, so we can just forward the call.

Acked-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
Signed-off-by: Dominik Dingel <dingel@linux.vnet.ibm.com>
---
 arch/s390/mm/hugetlbpage.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/arch/s390/mm/hugetlbpage.c b/arch/s390/mm/hugetlbpage.c
index 999616b..a4b2f5e 100644
--- a/arch/s390/mm/hugetlbpage.c
+++ b/arch/s390/mm/hugetlbpage.c
@@ -135,10 +135,7 @@ pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr)
 
 int pmd_huge(pmd_t pmd)
 {
-	if (!MACHINE_HAS_HPAGE)
-		return 0;
-
-	return !!(pmd_val(pmd) & _SEGMENT_ENTRY_LARGE);
+	return pmd_large(pmd);
 }
 
 int pud_huge(pud_t pud)
-- 
2.3.7

