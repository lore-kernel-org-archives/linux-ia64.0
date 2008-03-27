From: Christoph Lameter <clameter@sgi.com>
Date: Thu, 27 Mar 2008 04:00:16 +0000
Subject: Untangle IA64 sync_icache_dcache() page size determination
Message-Id: <Pine.LNX.4.64.0803262059100.2637@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

From: Christoph Lameter <clameter@sgi.com>
Subject: Untangle IA64 sync_icache_dcache() page size determination

Untangle the chaos of page size determination in this function by
simply using PAGE_SIZE << compound_order().

Cc: linux-ia64@vger.kernel.org
Cc: tony.luck@intel.com
Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 arch/ia64/mm/init.c |    7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

Index: linux-2.6.25-rc5-mm1/arch/ia64/mm/init.c
=================================--- linux-2.6.25-rc5-mm1.orig/arch/ia64/mm/init.c	2008-03-26 20:10:58.396670095 -0700
+++ linux-2.6.25-rc5-mm1/arch/ia64/mm/init.c	2008-03-26 20:11:33.509168639 -0700
@@ -66,12 +66,7 @@ __ia64_sync_icache_dcache (pte_t pte)
 	if (test_bit(PG_arch_1, &page->flags))
 		return;				/* i-cache is already coherent with d-cache */
 
-	if (PageCompound(page)) {
-		order = compound_order(page);
-		flush_icache_range(addr, addr + (1UL << order << PAGE_SHIFT));
-	}
-	else
-		flush_icache_range(addr, addr + PAGE_SIZE);
+	flush_icache_range(addr, addr + (PAGE_SIZE << compound_order(page)));
 	set_bit(PG_arch_1, &page->flags);	/* mark page as clean */
 }
 
