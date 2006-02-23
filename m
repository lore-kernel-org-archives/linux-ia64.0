From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Date: Thu, 23 Feb 2006 03:07:20 +0000
Subject: [PATCH] lazy_mmu_prot_update needs to be aware of huge pages
Message-Id: <1140664039.12944.15.camel@ymzhang-perf.sh.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

From: Zhang, Yanmin <yanmin.zhang@intel.com>

Function lazy_mmu_prot_update is also used on huge pages when it is called
by set_huge_ptep_writable, but it isn=FFt aware of huge pages.

The patch against 2.6.16-rc4 fixes it. Thank Ken for good suggestions.

Signed-off-by: Zhang Yanmin <yanmin.zhang@intel.com>=20

---

diff -Nraup linux-2.6.16-rc4/arch/ia64/mm/init.c linux-2.6.16-rc4_lazy_mmu/=
arch/ia64/mm/init.c
--- linux-2.6.16-rc4/arch/ia64/mm/init.c	2006-02-22 19:19:02.000000000 +0800
+++ linux-2.6.16-rc4_lazy_mmu/arch/ia64/mm/init.c	2006-02-23 18:29:00.00000=
0000 +0800
@@ -109,6 +109,7 @@ lazy_mmu_prot_update (pte_t pte)
 {
 	unsigned long addr;
 	struct page *page;
+	unsigned long order;
=20
 	if (!pte_exec(pte))
 		return;				/* not an executable page... */
@@ -119,7 +120,12 @@ lazy_mmu_prot_update (pte_t pte)
 	if (test_bit(PG_arch_1, &page->flags))
 		return;				/* i-cache is already coherent with d-cache */
=20
-	flush_icache_range(addr, addr + PAGE_SIZE);
+	if (PageCompound(page)) {
+		order =3D (unsigned long) (page[1].lru.prev);
+		flush_icache_range(addr, addr + (1UL << order << PAGE_SHIFT));
+	}
+	else
+		flush_icache_range(addr, addr + PAGE_SIZE);
 	set_bit(PG_arch_1, &page->flags);	/* mark page as clean */
 }
=20


