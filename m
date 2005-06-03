From: Andy Whitcroft <apw@shadowen.org>
Date: Fri, 03 Jun 2005 14:53:28 +0000
Subject: Re: [PATCH] - SPARSEMEM - Change pfn to unsigned long
Message-Id: <20050603145328.GA19217@shadowen.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050601164102.GA15563@sgi.com>
In-Reply-To: <20050601164102.GA15563@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Seems we arn't using unsigned long everywhere in sparsemem.  Tested on
my test boxes.  Thanks to Jack for finding this.

Andrew please apply to -mm.

-apw

== 8< =The latest 2.6.12-rc5-mm2 will not boot on large SGI systems. "pfn"
was assigned to an "int". Large systems overflow an int.
Trivial fix & it works ok now.....


Signed-off-by: Jack Steiner <steiner@sgi.com>
Signed-off-by: Andy Whitcroft <apw@shadowen.org>

diffstat sparsemem-change-pfn-to-unsigned-long
---
 page_alloc.c |    4 ++--
 sparse.c     |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff -upN reference/mm/page_alloc.c current/mm/page_alloc.c
--- reference/mm/page_alloc.c
+++ current/mm/page_alloc.c
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
diff -upN reference/mm/sparse.c current/mm/sparse.c
--- reference/mm/sparse.c
+++ current/mm/sparse.c
@@ -124,7 +124,7 @@ void sparse_init(void)
  * set.  If this is <=0, then that means that the passed-in
  * map was not consumed and must be freed.
  */
-int sparse_add_one_section(int start_pfn, int nr_pages, struct page *map)
+int sparse_add_one_section(unsigned long start_pfn, int nr_pages, struct page *map)
 {
 	struct mem_section *ms = __pfn_to_section(start_pfn);
 
