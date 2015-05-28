From: Dominik Dingel <dingel@linux.vnet.ibm.com>
Date: Thu, 28 May 2015 11:52:34 +0000
Subject: [PATCH 2/5] mm/hugetlb: remove unused arch hook prepare/release_hugepage
Message-Id: <1432813957-46874-3-git-send-email-dingel@linux.vnet.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1432813957-46874-1-git-send-email-dingel@linux.vnet.ibm.com>
In-Reply-To: <1432813957-46874-1-git-send-email-dingel@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

With s390 dropping support for emulated hugepages, the last user of
arch_prepare_hugepage and arch_release_hugepage is gone.

Acked-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
Signed-off-by: Dominik Dingel <dingel@linux.vnet.ibm.com>
---
 mm/hugetlb.c | 10 ----------
 1 file changed, 10 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 290984b..a97958e 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -917,7 +917,6 @@ static void update_and_free_page(struct hstate *h, struct page *page)
 		destroy_compound_gigantic_page(page, huge_page_order(h));
 		free_gigantic_page(page, huge_page_order(h));
 	} else {
-		arch_release_hugepage(page);
 		__free_pages(page, huge_page_order(h));
 	}
 }
@@ -1102,10 +1101,6 @@ static struct page *alloc_fresh_huge_page_node(struct hstate *h, int nid)
 						__GFP_REPEAT|__GFP_NOWARN,
 		huge_page_order(h));
 	if (page) {
-		if (arch_prepare_hugepage(page)) {
-			__free_pages(page, huge_page_order(h));
-			return NULL;
-		}
 		prep_new_huge_page(h, page, nid);
 	}
 
@@ -1257,11 +1252,6 @@ static struct page *alloc_buddy_huge_page(struct hstate *h, int nid)
 			htlb_alloc_mask(h)|__GFP_COMP|__GFP_THISNODE|
 			__GFP_REPEAT|__GFP_NOWARN, huge_page_order(h));
 
-	if (page && arch_prepare_hugepage(page)) {
-		__free_pages(page, huge_page_order(h));
-		page = NULL;
-	}
-
 	spin_lock(&hugetlb_lock);
 	if (page) {
 		INIT_LIST_HEAD(&page->lru);
-- 
2.3.7

