From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Fri, 05 May 2006 08:52:47 +0000
Subject: Small hugetlbpage.c fix
Message-Id: <445B125F.3040405@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

--- linux-2.6.16.9-save/arch/ia64/mm/hugetlbpage.c	2006-04-21 09:58:55.000000000 +0200
+++ linux-2.6.16.9/arch/ia64/mm/hugetlbpage.c	2006-05-05 10:35:14.000000000 +0200
@@ -125,9 +125,9 @@
 
 	addr = htlbpage_to_page(addr);
 	end  = htlbpage_to_page(end);
-	if (is_hugepage_only_range(tlb->mm, floor, HPAGE_SIZE))
+	if (is_hugepage_only_range((*tlb)->mm, floor, HPAGE_SIZE))
 		floor = htlbpage_to_page(floor);
-	if (is_hugepage_only_range(tlb->mm, ceiling, HPAGE_SIZE))
+	if (is_hugepage_only_range((*tlb)->mm, ceiling, HPAGE_SIZE))
 		ceiling = htlbpage_to_page(ceiling);
 
 	free_pgd_range(tlb, addr, end, floor, ceiling);
