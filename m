From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 28 Apr 2005 08:19:12 +0000
Subject: [RFC] [PATCH] naming reserved pages and remove PG_uncached [1/3]
Message-Id: <42709C80.6030607@jp.fujitsu.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------060408050902080303080903"
List-Id: <linux-ia64.vger.kernel.org>
References: <42709BDD.3040805@jp.fujitsu.com>
In-Reply-To: <42709BDD.3040805@jp.fujitsu.com>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------060408050902080303080903
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

inline functions for naming reserved pages.
-- Kame

--------------060408050902080303080903
Content-Type: text/plain;
 name="name_reserved.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="name_reserved.patch"


This patch add additonal information to 'Reserved' pages.
Information is stored in page->private.
Now, PG_reserved is used for many purpose and we cannot find
why it is reserved easily.

I'm now thinking of distinguishing
a) Memory Hole
b) isolated by MCA
c) Reserved by drivers
d) others
,which are all "Reserved". 
Further more investigation will be needed.

By the way there are two way to isolate pages,
(i)  set PG_reserved
(ii) allocate and never free.

Using (i) and setting page->private correctly looks clearer way and 
wiil help memory-hotplug (and other stuffs).

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>




---

 linux-2.6.12-rc2-mm3-kamezawa/include/linux/mm.h |   31 +++++++++++++++++++++++
 1 files changed, 31 insertions(+)

diff -puN include/linux/mm.h~name_reserved include/linux/mm.h
--- linux-2.6.12-rc2-mm3/include/linux/mm.h~name_reserved	2005-04-28 15:11:23.000000000 +0900
+++ linux-2.6.12-rc2-mm3-kamezawa/include/linux/mm.h	2005-04-28 16:28:41.000000000 +0900
@@ -353,6 +353,37 @@ static inline void put_page(struct page 
 #endif		/* CONFIG_HUGETLB_PAGE */
 
 /*
+ * types of pages
+ * value range is 0-255.
+ */
+enum page_type {
+	page_common = 0,
+	reserved_unknown = 1,
+	reserved_at_boot,
+	max_reserved_types,
+	invalid_page_type = 0xff,
+};
+
+/*
+ * Basically, page->private has no meaning without PG_private.
+ * Here, we use page->private for PG_reserved pages to record a type of a page.
+ * Because a page is reserved, anyone will not modify page->private.
+ * When it is freed, page->private will be overwritten by some code.
+ */
+static inline void set_page_reserved(struct page *page, enum page_type type)
+{
+	SetPageReserved(page);
+	page->private = (unsigned long)type;
+}
+
+static inline unsigned char reserved_page_type(struct page *page)
+{
+	if (!PageReserved(page))
+		return 0;
+	return (unsigned char) page->private;
+}
+
+/*
  * Multiple processes may "see" the same page. E.g. for untouched
  * mappings of /dev/null, all processes see the same page full of
  * zeroes, and text pages of executables and shared libraries have

_

--------------060408050902080303080903--

