From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 22 Aug 2007 02:31:04 +0000
Subject: Re: [PATCH][2.6.23-rc2-mm2] small fix for ia64 icache sync patch
Message-Id: <20070822113104.3450d203.kamezawa.hiroyu@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070821201507.36641d76.kamezawa.hiroyu@jp.fujitsu.com>
	<617E1C2C70743745A92448908E030B2A023B2254@scsmsx411.amr.corp.intel.com>
In-Reply-To: <617E1C2C70743745A92448908E030B2A023B2254@scsmsx411.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-ia64@vger.kernel.org

This is updated version. 

Andrew, could you repleace ?

-Kame
=
Fixing 2 small issues pointed by Tony Luck.

Changelog v1 -> v2
* add pte_present_exec_user()
* remove pte_user
* fixed comments.

v1.
* removing redundant BUG_ON in __ia64_sync_icache_dcache().
* check pte_present() first.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 arch/ia64/mm/init.c        |    2 --
 include/asm-ia64/pgtable.h |   17 +++++++++++------
 2 files changed, 11 insertions(+), 8 deletions(-)

Index: linux-2.6.23-rc2-mm2/include/asm-ia64/pgtable.h
=================================--- linux-2.6.23-rc2-mm2.orig/include/asm-ia64/pgtable.h
+++ linux-2.6.23-rc2-mm2/include/asm-ia64/pgtable.h
@@ -297,7 +297,6 @@ ia64_phys_addr_valid (unsigned long addr
 /*
  * The following have defined behavior only work if pte_present() is true.
  */
-#define pte_user(pte)	((pte_val(pte) & _PAGE_PL_MASK) = _PAGE_PL_3)
 #define pte_write(pte)	((unsigned) (((pte_val(pte) & _PAGE_AR_MASK) >> _PAGE_AR_SHIFT) - 2) <= 4)
 #define pte_exec(pte)		((pte_val(pte) & _PAGE_AR_RX) != 0)
 #define pte_dirty(pte)		((pte_val(pte) & _PAGE_D) != 0)
@@ -324,14 +323,20 @@ ia64_phys_addr_valid (unsigned long addr
  *  set_pte() is also called by the kernel, but we can expect that the kernel
  *  flushes icache explicitly if necessary.
  */
+#define pte_present_exec_user(pte)\
+	((pte_val(pte) & (_PAGE_P | _PAGE_PL_MASK | _PAGE_AR_RX)) = \
+		(_PAGE_P | _PAGE_PL_3 | _PAGE_AR_RX))
+
 extern void __ia64_sync_icache_dcache(pte_t pteval);
 static inline void set_pte(pte_t *ptep, pte_t pteval)
 {
-	if (pte_exec(pteval) &&    // flush only new executable page.
-	    pte_present(pteval) && // swap out ?
-	    pte_user(pteval) &&    // ignore kernel page
-	    (!pte_present(*ptep) ||// do_no_page or swap in, migration,
-		pte_pfn(*ptep) != pte_pfn(pteval))) // do_wp_page(), page copy
+	/* page is present && page is user  && page is executable
+	 * && (page swapin or new page or page migraton
+	 *	|| copy_on_write with page copying.)
+	 */
+	if (pte_present_exec_user(pteval) &&
+	    (!pte_present(*ptep) ||
+		pte_pfn(*ptep) != pte_pfn(pteval)))
 		/* load_module() calles flush_icache_range() explicitly*/
 		__ia64_sync_icache_dcache(pteval);
 	*ptep = pteval;
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
 

