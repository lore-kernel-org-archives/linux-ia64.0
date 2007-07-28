From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Sat, 28 Jul 2007 06:14:49 +0000
Subject: [PATCH] flush icache before set_pte() take 5. [1/2] cache flush in
Message-Id: <20070728151449.f3ec0ebe.kamezawa.hiroyu@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070728150319.d19f531f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070728150319.d19f531f.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "tony.luck@intel.com" <tony.luck@intel.com>, Zoltan.Menyhart@bull.net, "nickpiggin@yahoo.com.au" <nickpiggin@yahoo.com.au>, Christoph Lameter <clameter@sgi.com>

In migration, a new page should be cache flushed before set_pte()
in some archs which have virtually-tagged cache..

V4 -> V5:
   * changed flush_icache_page to flush_cache_page.

Signed-Off-By: KAMEZAWA Hiruyoki <kamezawa.hiroyu@jp.fujitsu.com>

---
 mm/migrate.c |    1 +
 1 file changed, 1 insertion(+)

Index: linux-2.6.23-rc1.test/mm/migrate.c
=================================--- linux-2.6.23-rc1.test.orig/mm/migrate.c
+++ linux-2.6.23-rc1.test/mm/migrate.c
@@ -172,6 +172,7 @@ static void remove_migration_pte(struct 
 	pte = pte_mkold(mk_pte(new, vma->vm_page_prot));
 	if (is_write_migration_entry(entry))
 		pte = pte_mkwrite(pte);
+	flush_cache_page(vma, addr, pte_pfn(pte));
 	set_pte_at(mm, addr, ptep, pte);
 
 	if (PageAnon(new))

