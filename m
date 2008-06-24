From: Julia Lawall <julia@diku.dk>
Date: Tue, 24 Jun 2008 08:22:05 +0000
Subject: [PATCH 3/14] arch/ia64: Eliminate NULL test and memset after
Message-Id: <Pine.LNX.4.64.0806241021360.26777@ask.diku.dk>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: akinobu.mita@gmail.com, tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org

From: Julia Lawall <julia@diku.dk>

As noted by Akinobu Mita in patch b1fceac2b9e04d278316b2faddf276015fc06e3b,
alloc_bootmem and related functions never return NULL and always return a
zeroed region of memory.  Thus a NULL test or memset after calls to these
functions is unnecessary.

 arch/ia64/kernel/iosapic.c |    2 --
 1 file changed, 2 deletions(-)

This was fixed using the following semantic patch.
(http://www.emn.fr/x-info/coccinelle/)

// <smpl>
@@
expression E;
statement S;
@@

E = \(alloc_bootmem\|alloc_bootmem_low\|alloc_bootmem_pages\|alloc_bootmem_low_pages\)(...)
... when != E
(
- BUG_ON (E = NULL);
|
- if (E = NULL) S
)

@@
expression E,E1;
@@

E = \(alloc_bootmem\|alloc_bootmem_low\|alloc_bootmem_pages\|alloc_bootmem_low_pages\)(...)
... when != E
- memset(E,0,E1);
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>
---

diff -u -p a/arch/ia64/kernel/iosapic.c b/arch/ia64/kernel/iosapic.c
--- a/arch/ia64/kernel/iosapic.c
+++ b/arch/ia64/kernel/iosapic.c
@@ -558,8 +558,6 @@ static struct iosapic_rte_info * __init_
 	if (!iosapic_kmalloc_ok && list_empty(&free_rte_list)) {
 		rte = alloc_bootmem(sizeof(struct iosapic_rte_info) *
 				    NR_PREALLOCATE_RTE_ENTRIES);
-		if (!rte)
-			return NULL;
 		for (i = 0; i < NR_PREALLOCATE_RTE_ENTRIES; i++, rte++)
 			list_add(&rte->rte_list, &free_rte_list);
 	}
