From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 21 Aug 2007 11:15:07 +0000
Subject: [PATCH][2.6.23-rc2-mm2] small fix for ia64 icache sync patch
Message-Id: <20070821201507.36641d76.kamezawa.hiroyu@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: LKML <linux-kernel@vger.kernel.org>
Cc: "tony.luck@intel.com" <tony.luck@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

Fixing 2 small issues pointed by Tony Luck.

* removing redundant BUG_ON in __ia64_sync_icache_dcache().
* check pte_present() first.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 arch/ia64/mm/init.c        |    2 --
 include/asm-ia64/pgtable.h |    4 ++--
 2 files changed, 2 insertions(+), 4 deletions(-)

Index: linux-2.6.23-rc2-mm2/include/asm-ia64/pgtable.h
=================================--- linux-2.6.23-rc2-mm2.orig/include/asm-ia64/pgtable.h
+++ linux-2.6.23-rc2-mm2/include/asm-ia64/pgtable.h
@@ -327,8 +327,8 @@ ia64_phys_addr_valid (unsigned long addr
 extern void __ia64_sync_icache_dcache(pte_t pteval);
 static inline void set_pte(pte_t *ptep, pte_t pteval)
 {
-	if (pte_exec(pteval) &&    // flush only new executable page.
-	    pte_present(pteval) && // swap out ?
+	if (pte_present(pteval) &&// swap out ?
+	    pte_exec(pteval) &&    // flush only new executable page.
 	    pte_user(pteval) &&    // ignore kernel page
 	    (!pte_present(*ptep) ||// do_no_page or swap in, migration,
 		pte_pfn(*ptep) != pte_pfn(pteval))) // do_wp_page(), page copy
Index: linux-2.6.23-rc2-mm2/arch/ia64/mm/init.c
=================================--- linux-2.6.23-rc2-mm2.orig/arch/ia64/mm/init.c
+++ linux-2.6.23-rc2-mm2/arch/ia64/mm/init.c
@@ -60,8 +60,6 @@ __ia64_sync_icache_dcache (pte_t pte)
 	struct page *page;
 	unsigned long order;
 
-	BUG_ON(!pte_exec(pte));
-
 	page = pte_page(pte);
 	addr = (unsigned long) page_address(page);
 

