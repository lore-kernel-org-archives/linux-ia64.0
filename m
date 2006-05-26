From: Hugh Dickins <hugh@veritas.com>
Date: Fri, 26 May 2006 18:28:14 +0000
Subject: [PATCH] fix update_mmu_cache in fremap.c
Message-Id: <Pine.LNX.4.64.0605261926350.24818@blonde.wat.veritas.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

There are two calls to update_mmu_cache in fremap.c, both defective.
The one in install_page needs to be accompanied by lazy_mmu_prot_update
(some other cleanup time, move that into ia64 update_mmu_cache itself); and
the one in install_file_pte should be removed since the pte is not present.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---
 mm/fremap.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- 2.6.17-rc5/mm/fremap.c	2006-01-03 03:21:10.000000000 +0000
+++ linux/mm/fremap.c	2006-05-26 17:55:29.000000000 +0100
@@ -83,6 +83,7 @@ int install_page(struct mm_struct *mm, s
 	page_add_file_rmap(page);
 	pte_val = *pte;
 	update_mmu_cache(vma, addr, pte_val);
+	lazy_mmu_prot_update(pte_val);
 	err = 0;
 unlock:
 	pte_unmap_unlock(pte, ptl);
@@ -114,7 +115,6 @@ int install_file_pte(struct mm_struct *m
 
 	set_pte_at(mm, addr, pte, pgoff_to_pte(pgoff));
 	pte_val = *pte;
-	update_mmu_cache(vma, addr, pte_val);
 	pte_unmap_unlock(pte, ptl);
 	err = 0;
 out:
