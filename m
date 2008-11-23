From: Julia Lawall <julia@diku.dk>
Date: Sun, 23 Nov 2008 10:48:14 +0000
Subject: [PATCH 3/5] arch/ia64: Eliminate NULL test and memset after
Message-Id: <Pine.LNX.4.64.0811231147000.28343@ask.diku.dk>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org

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
---

 arch/ia64/sn/kernel/setup.c         |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/arch/ia64/sn/kernel/setup.c b/arch/ia64/sn/kernel/setup.c
index bb1d249..b683eb3 100644
--- a/arch/ia64/sn/kernel/setup.c
+++ b/arch/ia64/sn/kernel/setup.c
@@ -512,7 +512,6 @@ static void __init sn_init_pdas(char **cmdline_p)
 	for_each_online_node(cnode) {
 		nodepdaindr[cnode]  		    alloc_bootmem_node(NODE_DATA(cnode), sizeof(nodepda_t));
-		memset(nodepdaindr[cnode], 0, sizeof(nodepda_t));
 		memset(nodepdaindr[cnode]->phys_cpuid, -1,
 		    sizeof(nodepdaindr[cnode]->phys_cpuid));
 		spin_lock_init(&nodepdaindr[cnode]->ptc_lock);
@@ -521,11 +520,9 @@ static void __init sn_init_pdas(char **cmdline_p)
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
