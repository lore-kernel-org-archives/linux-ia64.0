From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 28 Apr 2005 08:20:30 +0000
Subject: [RFC] [PATCH] naming reserved pages and remove PG_uncached [2/3]
Message-Id: <42709CCE.6060107@jp.fujitsu.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------030106000502060108050905"
List-Id: <linux-ia64.vger.kernel.org>
References: <42709BDD.3040805@jp.fujitsu.com>
In-Reply-To: <42709BDD.3040805@jp.fujitsu.com>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------030106000502060108050905
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

set reserved_at_boot
-- Kame

--------------030106000502060108050905
Content-Type: text/plain;
 name="set_rsvd_at_boot.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="set_rsvd_at_boot.patch"


set reserved_at_boot in page->private at the boot time.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


---

 linux-2.6.12-rc2-mm3-kamezawa/mm/page_alloc.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN mm/page_alloc.c~set_rsvd_at_boot mm/page_alloc.c
--- linux-2.6.12-rc2-mm3/mm/page_alloc.c~set_rsvd_at_boot	2005-04-28 16:28:54.000000000 +0900
+++ linux-2.6.12-rc2-mm3-kamezawa/mm/page_alloc.c	2005-04-28 16:28:54.000000000 +0900
@@ -1641,7 +1641,7 @@ void __init memmap_init_zone(unsigned lo
 		set_page_links(page, zone, nid);
 		set_page_count(page, 0);
 		reset_page_mapcount(page);
-		SetPageReserved(page);
+		set_page_reserved(page, reserved_at_boot);
 		INIT_LIST_HEAD(&page->lru);
 #ifdef WANT_PAGE_VIRTUAL
 		/* The shift won't overflow because ZONE_NORMAL is below 4G. */

_

--------------030106000502060108050905--

