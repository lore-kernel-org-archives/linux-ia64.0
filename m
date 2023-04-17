From: Hugh Dickins <hughd@google.com>
Date: Mon, 17 Apr 2023 05:17:05 +0000
Subject: [PATCH] ia64: fix an addr to taddr in huge_pte_offset()
Message-Id: <732eae88-3beb-246-2c72-281de786740@google.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mike Rapoport <rppt@linux.ibm.com>, Mike Kravetz <mike.kravetz@oracle.com>, Ard Biesheuvel <ardb@kernel.org>, linux-ia64@vger.kernel.org, linux-mm@kvack.org

I know nothing of ia64 htlbpage_to_page(), but guess that the p4d
line should be using taddr rather than addr, like everywhere else.

Fixes: c03ab9e32a2c ("ia64: add support for folded p4d page tables")
Signed-off-by: Hugh Dickins <hughd@google.com
---
Just something noticed when visiting recently in the source:
thought we might fix it before ia64 is consigned to history;
I'm unable to say anything about the user-visible effects!

 arch/ia64/mm/hugetlbpage.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- 6.3-rc7/arch/ia64/mm/hugetlbpage.c
+++ linux/arch/ia64/mm/hugetlbpage.c
@@ -58,7 +58,7 @@ huge_pte_offset (struct mm_struct *mm, unsigned long addr, unsigned long sz)
 
 	pgd = pgd_offset(mm, taddr);
 	if (pgd_present(*pgd)) {
-		p4d = p4d_offset(pgd, addr);
+		p4d = p4d_offset(pgd, taddr);
 		if (p4d_present(*p4d)) {
 			pud = pud_offset(p4d, taddr);
 			if (pud_present(*pud)) {
