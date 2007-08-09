From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 09 Aug 2007 04:56:08 +0000
Subject: [PATCH] flush icache before set_pte() on ia64  take9 [1/2]
Message-Id: <20070809135608.ff3b0373.kamezawa.hiroyu@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070809135311.0676a947.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070809135311.0676a947.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, "tony.luck@intel.com" <tony.luck@intel.com>, davem@davemloft.net, "Zoltan.Menyhart@bull.net" <Zoltan.Menyhart@bull.net>, "nickpiggin@yahoo.com.au" <nickpiggin@yahoo.com.au>

In migration, a new page should be cache flushed before set_pte()
in some archs which have virtually-tagged cache..
I'll separate this from patch set in the next time.


Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 mm/migrate.c |    1 +
 1 file changed, 1 insertion(+)

Index: linux-2.6.23-rc2.test/mm/migrate.c
=================================--- linux-2.6.23-rc2.test.orig/mm/migrate.c
+++ linux-2.6.23-rc2.test/mm/migrate.c
@@ -171,6 +171,7 @@ static void remove_migration_pte(struct 
 	pte = pte_mkold(mk_pte(new, vma->vm_page_prot));
 	if (is_write_migration_entry(entry))
 		pte = pte_mkwrite(pte);
+	flush_cache_page(vma, addr, pte_pfn(pte));
 	set_pte_at(mm, addr, ptep, pte);
 
 	if (PageAnon(new))

