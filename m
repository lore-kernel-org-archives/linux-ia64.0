From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 31 Jul 2007 02:38:37 +0000
Subject: [PATCH] flush icache before set_pte take6. [1/4] migration fix
Message-Id: <20070731113837.0226bfaa.kamezawa.hiroyu@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070731113543.93ffd964.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070731113543.93ffd964.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "tony.luck@intel.com" <tony.luck@intel.com>, "Zoltan.Menyhart@bull.net" <Zoltan.Menyhart@bull.net>, Christoph Lameter <clameter@sgi.com>

In migration, a new page should be cache flushed before set_pte()
in some archs which have virtually-tagged cache..

V5 -> V6:
   * no changes (added new patches to the patch set)
V4 -> V5:
   * changed flush_icache_page to flush_cache_page.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

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

