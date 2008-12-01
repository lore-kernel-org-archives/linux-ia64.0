From: akpm@linux-foundation.org
Date: Mon, 01 Dec 2008 22:18:37 +0000
Subject: [patch 2/2] arch/ia64: eliminate NULL test and memset after alloc_bootmem
Message-Id: <200812012218.mB1MIbeB011624@imap1.linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

From: Julia Lawall <julia@diku.dk>

As noted by Akinobu Mita in patch b1fceac2b9e04d278316b2faddf276015fc06e3b,
alloc_bootmem and related functions never return NULL and always return a
zeroed region of memory.  Thus a NULL test or memset after calls to these
functions is unnecessary.

This was fixed using the following semantic patch.
(http://www.emn.fr/x-info/coccinelle/)

// <smpl>
@@
expression E;
statement S;
@@

E = \(alloc_bootmem\|alloc_bootmem_low\|alloc_bootmem_pages\|alloc_bootmem_low_pages\|alloc_bootmem_node\|alloc_bootmem_low_pages_node\|alloc_bootmem_pages_node\)(...)
... when != E
(
- BUG_ON (E = NULL);
|
- if (E = NULL) S
)

@@
expression E,E1;
@@

E = \(alloc_bootmem\|alloc_bootmem_low\|alloc_bootmem_pages\|alloc_bootmem_low_pages\|alloc_bootmem_node\|alloc_bootmem_low_pages_node\|alloc_bootmem_pages_node\)(...)
... when != E
- memset(E,0,E1);
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>
Cc: "Luck, Tony" <tony.luck@intel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 arch/ia64/sn/kernel/setup.c |    5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff -puN arch/ia64/sn/kernel/setup.c~arch-ia64-eliminate-null-test-and-memset-after-alloc_bootmem arch/ia64/sn/kernel/setup.c
--- a/arch/ia64/sn/kernel/setup.c~arch-ia64-eliminate-null-test-and-memset-after-alloc_bootmem
+++ a/arch/ia64/sn/kernel/setup.c
@@ -512,7 +512,6 @@ static void __init sn_init_pdas(char **c
 	for_each_online_node(cnode) {
 		nodepdaindr[cnode]  		    alloc_bootmem_node(NODE_DATA(cnode), sizeof(nodepda_t));
-		memset(nodepdaindr[cnode], 0, sizeof(nodepda_t));
 		memset(nodepdaindr[cnode]->phys_cpuid, -1,
 		    sizeof(nodepdaindr[cnode]->phys_cpuid));
 		spin_lock_init(&nodepdaindr[cnode]->ptc_lock);
@@ -521,11 +520,9 @@ static void __init sn_init_pdas(char **c
 	/*
 	 * Allocate & initialize nodepda for TIOs.  For now, put them on node 0.
 	 */
-	for (cnode = num_online_nodes(); cnode < num_cnodes; cnode++) {
+	for (cnode = num_online_nodes(); cnode < num_cnodes; cnode++)
 		nodepdaindr[cnode]  		    alloc_bootmem_node(NODE_DATA(0), sizeof(nodepda_t));
-		memset(nodepdaindr[cnode], 0, sizeof(nodepda_t));
-	}
 
 	/*
 	 * Now copy the array of nodepda pointers to each nodepda.
_
