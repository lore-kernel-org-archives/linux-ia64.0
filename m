From: Russ Anderson <rja@sgi.com>
Date: Sat, 15 Jan 2005 22:49:06 +0000
Subject: [patch] Remove limit on MCA recoveries
Message-Id: <200501152249.j0FMn6JH2857539@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The MCA recovery driver saves addresses memory errors
in an array.  The array has 32 entries.  The effect is 
that after 32 recoveries, the driver stops recovering.

This patch removes the page_isolate array.  Since the array
was only used to see if the page is already marked reserved,
check the reserved bit instead of the array.

Signed-off-by: Russ Anderson

-----------------------------------------
Index: 2.6.11/arch/ia64/kernel/mca_drv.c
=================================--- 2.6.11.orig/arch/ia64/kernel/mca_drv.c	2005-01-10 15:39:35.746124749 -0600
+++ 2.6.11/arch/ia64/kernel/mca_drv.c	2005-01-14 15:31:25.290081483 -0600
@@ -52,10 +52,6 @@
 	MCA_IS_GLOBAL = 1
 } mca_type_t;
 
-#define MAX_PAGE_ISOLATE 32
-
-static struct page *page_isolate[MAX_PAGE_ISOLATE];
-static int num_page_isolate = 0;
 
 typedef enum {
 	ISOLATE_NG = 0,
@@ -82,7 +78,6 @@
 static isolate_status_t
 mca_page_isolate(unsigned long paddr)
 {
-	int i;
 	struct page *p;
 
 	/* whether physical address is valid or not */
@@ -93,21 +88,15 @@
 	p = pfn_to_page(paddr>>PAGE_SHIFT);
 
 	/* check whether a page number have been already registered or not */
-	for( i = 0; i < num_page_isolate; i++ )
-		if( page_isolate[i] = p )
-			return ISOLATE_OK; /* already listed */
-
-	/* limitation check */
-	if( num_page_isolate = MAX_PAGE_ISOLATE ) 
-		return ISOLATE_NG;
+	if( PageReserved(p) )
+		return ISOLATE_OK; /* already listed */
 
 	/* kick pages having attribute 'SLAB' or 'Reserved' */
-	if( PageSlab(p) || PageReserved(p) ) 
+	if( PageSlab(p) ) 
 		return ISOLATE_NG;
 
 	/* add attribute 'Reserved' and register the page */
 	SetPageReserved(p);
-	page_isolate[num_page_isolate++] = p;
 
 	return ISOLATE_OK;
 }
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
