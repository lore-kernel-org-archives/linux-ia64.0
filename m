From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 28 Apr 2005 08:22:02 +0000
Subject: [RFC] [PATCH] naming reserved pages and remove PG_uncached [3/3]
Message-Id: <42709D2A.7090901@jp.fujitsu.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------090104000408060804080509"
List-Id: <linux-ia64.vger.kernel.org>
References: <42709BDD.3040805@jp.fujitsu.com>
In-Reply-To: <42709BDD.3040805@jp.fujitsu.com>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------090104000408060804080509
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

removing PG_uncached
-- Kame

--------------090104000408060804080509
Content-Type: text/plain;
 name="uncached_rsvd_page.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="uncached_rsvd_page.patch"


Now, PG_uncached is used to remember that a page is uncached.

PG_uncached pages is not freed or allocated while it is uncached.
So, PageReserved(page) && ( page->private = reserved_uncached)
can work enough, I think.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>



---

 linux-2.6.12-rc2-mm3-kamezawa/include/asm-ia64/uaccess.h |    4 +-
 linux-2.6.12-rc2-mm3-kamezawa/include/linux/mm.h         |   21 ++++++++++++---
 linux-2.6.12-rc2-mm3-kamezawa/include/linux/page-flags.h |    3 --
 3 files changed, 20 insertions(+), 8 deletions(-)

diff -puN include/linux/mm.h~uncached_rsvd_page include/linux/mm.h
--- linux-2.6.12-rc2-mm3/include/linux/mm.h~uncached_rsvd_page	2005-04-28 16:28:58.000000000 +0900
+++ linux-2.6.12-rc2-mm3-kamezawa/include/linux/mm.h	2005-04-28 16:28:58.000000000 +0900
@@ -358,10 +358,11 @@ static inline void put_page(struct page 
  */
 enum page_type {
 	page_common = 0,
-	reserved_unknown = 1,
-	reserved_at_boot,
+	page_reserved_unknown = 1,
+	page_reserved_at_boot,
+	page_reserved_uncached,
 	max_reserved_types,
-	invalid_page_type = 0xff,
+	page_invalid_type = 0xff,
 };
 
 /*
@@ -376,6 +377,12 @@ static inline void set_page_reserved(str
 	page->private = (unsigned long)type;
 }
 
+static inline void clear_page_reserved(struct page *page)
+{
+	page->private = 0;
+	ClearPageReserved(page);
+}
+
 static inline unsigned char reserved_page_type(struct page *page)
 {
 	if (!PageReserved(page))
@@ -383,6 +390,14 @@ static inline unsigned char reserved_pag
 	return (unsigned char) page->private;
 }
 
+#define set_page_uncached(page) \
+	set_page_reserved((page), page_reserved_uncached)
+#define clr_page_uncahced(page)\
+	clear_page_reserved(page);
+#define page_is_uncached(page)\
+	(reserved_page_type(page) == page_reserved_uncached)
+
+
 /*
  * Multiple processes may "see" the same page. E.g. for untouched
  * mappings of /dev/null, all processes see the same page full of
diff -puN include/linux/page-flags.h~uncached_rsvd_page include/linux/page-flags.h
--- linux-2.6.12-rc2-mm3/include/linux/page-flags.h~uncached_rsvd_page	2005-04-28 16:28:58.000000000 +0900
+++ linux-2.6.12-rc2-mm3-kamezawa/include/linux/page-flags.h	2005-04-28 16:28:58.000000000 +0900
@@ -302,9 +302,6 @@ extern void __mod_page_state(unsigned of
 #define PageSwapCache(page)	0
 #endif
 
-#define PageUncached(page)	test_bit(PG_uncached, &(page)->flags)
-#define SetPageUncached(page)	set_bit(PG_uncached, &(page)->flags)
-#define ClearPageUncached(page)	clear_bit(PG_uncached, &(page)->flags)
 
 struct page;	/* forward declaration */
 
diff -puN include/asm-ia64/uaccess.h~uncached_rsvd_page include/asm-ia64/uaccess.h
--- linux-2.6.12-rc2-mm3/include/asm-ia64/uaccess.h~uncached_rsvd_page	2005-04-28 16:28:58.000000000 +0900
+++ linux-2.6.12-rc2-mm3-kamezawa/include/asm-ia64/uaccess.h	2005-04-28 16:28:58.000000000 +0900
@@ -379,7 +379,7 @@ xlate_dev_mem_ptr (unsigned long p)
 	char * ptr;
 
 	page = pfn_to_page(p >> PAGE_SHIFT);
-	if (PageUncached(page))
+	if (page_is_uncached(page))
 		ptr = (char *)p + __IA64_UNCACHED_OFFSET;
 	else
 		ptr = __va(p);
@@ -397,7 +397,7 @@ xlate_dev_kmem_ptr (char * p)
 	char * ptr;
 
 	page = virt_to_page((unsigned long)p >> PAGE_SHIFT);
-	if (PageUncached(page))
+	if (page_is_uncached(page))
 		ptr = (char *)__pa(p) + __IA64_UNCACHED_OFFSET;
 	else
 		ptr = p;

_

--------------090104000408060804080509--

