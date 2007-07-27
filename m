From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 27 Jul 2007 04:38:43 +0000
Subject: [PATCH] flush cache fixes for ia64 [1/2] migration fix
Message-Id: <20070727133843.6cd3f57a.kamezawa.hiroyu@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070727133657.8c9c6803.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070727133657.8c9c6803.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "tony.luck@intel.com" <tony.luck@intel.com>, "nickpiggin@yahoo.com.au" <nickpiggin@yahoo.com.au>, Zoltan.Menyhart@bull.net, Christoph Lameter <clameter@sgi.com>

In migration, a new page should be cache flushed before set_pte()
in some archs.

Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

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
+	flush_icache_page(vma, new);
 	set_pte_at(mm, addr, ptep, pte);
 
 	if (PageAnon(new))

