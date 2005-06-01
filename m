From: Jack Steiner <steiner@sgi.com>
Date: Wed, 01 Jun 2005 16:41:03 +0000
Subject: [PATCH] - SPARSEMEM - Change pfn to unsigned long
Message-Id: <20050601164102.GA15563@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


The latest 2.6.12-rc5-mm2 will not boot on large SGI systems. "pfn"
was assigned to an "int". Large systems overflow an int.
Trivial fix & it works ok now.....


	Signed-off-by: Jack Steiner <steiner@sgi.com>


Index: linux/mm/page_alloc.c
=================================--- linux.orig/mm/page_alloc.c	2005-05-26 10:32:26.804141634 -0500
+++ linux/mm/page_alloc.c	2005-06-01 11:28:43.338491345 -0500
@@ -1731,8 +1731,8 @@ void __init memmap_init_zone(unsigned lo
 		unsigned long start_pfn)
 {
 	struct page *page;
-	int end_pfn = start_pfn + size;
-	int pfn;
+	unsigned long end_pfn = start_pfn + size;
+	unsigned long pfn;
 
 	for (pfn = start_pfn; pfn < end_pfn; pfn++, page++) {
 		if (!early_pfn_valid(pfn))
Index: linux/mm/sparse.c
=================================--- linux.orig/mm/sparse.c	2005-05-26 10:32:26.816836797 -0500
+++ linux/mm/sparse.c	2005-06-01 10:29:24.435883417 -0500
@@ -124,7 +124,7 @@ void sparse_init(void)
  * set.  If this is <=0, then that means that the passed-in
  * map was not consumed and must be freed.
  */
-int sparse_add_one_section(int start_pfn, int nr_pages, struct page *map)
+int sparse_add_one_section(unsigned long start_pfn, int nr_pages, struct page *map)
 {
 	struct mem_section *ms = __pfn_to_section(start_pfn);
 
-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


