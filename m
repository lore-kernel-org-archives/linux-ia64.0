From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 22 Mar 2006 18:49:00 +0000
Subject: [patch] fix ia64 is_hugepage_only_range
Message-Id: <200603221848.k2MImlg13368@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Bunch of commits related to hugetlb went into Linus's git tree. however,
the following ia64 patch fall through the crack. Re-post here for upstream
merging.  Please refer to earlier discussion:
http://marc.theaimsgroup.com/?l=linux-ia64&m4132861021608&w=2

Tony, please apply.  Thanks.



[patch] ia64: fix is_hugepage_only_range() definition to be overlaps
        instead of within architectural restricted hugetlb address
        range.  And fix all affected usages.

Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>

--- ./include/asm-ia64/page.h.orig	2006-03-02 12:16:00.636688455 -0800
+++ ./include/asm-ia64/page.h	2006-03-02 12:23:30.151331386 -0800
@@ -147,7 +147,7 @@ typedef union ia64_va {
 				 | (REGION_OFFSET(x) >> (HPAGE_SHIFT-PAGE_SHIFT)))
 # define HUGETLB_PAGE_ORDER	(HPAGE_SHIFT - PAGE_SHIFT)
 # define is_hugepage_only_range(mm, addr, len)		\
-	 (REGION_NUMBER(addr) = RGN_HPAGE &&	\
+	 (REGION_NUMBER(addr) = RGN_HPAGE ||	\
 	  REGION_NUMBER((addr)+(len)-1) = RGN_HPAGE)
 extern unsigned int hpage_shift;
 #endif
--- ./arch/ia64/mm/hugetlbpage.c.orig	2006-03-02 12:31:12.020466353 -0800
+++ ./arch/ia64/mm/hugetlbpage.c	2006-03-02 12:31:02.944294589 -0800
@@ -112,8 +112,7 @@ void hugetlb_free_pgd_range(struct mmu_g
 			unsigned long floor, unsigned long ceiling)
 {
 	/*
-	 * This is called only when is_hugepage_only_range(addr,),
-	 * and it follows that is_hugepage_only_range(end,) also.
+	 * This is called to free hugetlb page tables.
 	 *
 	 * The offset of these addresses from the base of the hugetlb
 	 * region must be scaled down by HPAGE_SIZE/PAGE_SIZE so that
@@ -125,9 +124,9 @@ void hugetlb_free_pgd_range(struct mmu_g
 
 	addr = htlbpage_to_page(addr);
 	end  = htlbpage_to_page(end);
-	if (is_hugepage_only_range(tlb->mm, floor, HPAGE_SIZE))
+	if (REGION_NUMBER(floor) = RGN_HPAGE)
 		floor = htlbpage_to_page(floor);
-	if (is_hugepage_only_range(tlb->mm, ceiling, HPAGE_SIZE))
+	if (REGION_NUMBER(ceiling) = RGN_HPAGE)
 		ceiling = htlbpage_to_page(ceiling);
 
 	free_pgd_range(tlb, addr, end, floor, ceiling);

