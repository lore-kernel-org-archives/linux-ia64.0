From: Bob Picco <bob.picco@hp.com>
Date: Sat, 29 Oct 2005 21:23:05 +0000
Subject: [PATCH] fix memory less node allocation
Message-Id: <20051029212305.GA6019@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony:

The original memory less node allocation attempted to use NODEDATA_ALIGN for
alignment.  The bootmem allocator only allows a power of two alignments. This
causes a BUG_ON for some nodes. For cpu only nodes just allocate with a
PERCPU_PAGE_SIZE alignment.

Some older firmware reports SLIT distances of 0xff and results in bestnode
not being computed. This is now treated correctly.

The failed allocation check was removed because it's redundant.  The
bootmem allocator already makes this check.

This fix has been boot tested on 4 node machine which has 4 cpu only nodes
and 1 memory node.  Thanks to Pete Keilty for reporting this and helping me
test it.  

thanks,

bob

Signed-off-by: Bob Picco <bob.picco@hp.com>

 arch/ia64/mm/discontig.c |   19 +++++++++----------
 1 files changed, 9 insertions(+), 10 deletions(-)

Index: linux-2.6.14-rc3/arch/ia64/mm/discontig.c
=================================--- linux-2.6.14-rc3.orig/arch/ia64/mm/discontig.c	2005-10-26 17:44:36.000000000 -0400
+++ linux-2.6.14-rc3/arch/ia64/mm/discontig.c	2005-10-27 16:44:29.000000000 -0400
@@ -350,14 +350,12 @@ static void __init initialize_pernode_da
  *	for best.
  * @nid: node id
  * @pernodesize: size of this node's pernode data
- * @align: alignment to use for this node's pernode data
  */
-static void __init *memory_less_node_alloc(int nid, unsigned long pernodesize,
-	unsigned long align)
+static void __init *memory_less_node_alloc(int nid, unsigned long pernodesize)
 {
 	void *ptr = NULL;
 	u8 best = 0xff;
-	int bestnode = -1, node;
+	int bestnode = -1, node, anynode = 0;
 
 	for_each_online_node(node) {
 		if (node_isset(node, memory_less_mask))
@@ -366,13 +364,15 @@ static void __init *memory_less_node_all
 			best = node_distance(nid, node);
 			bestnode = node;
 		}
+		anynode = node;
 	}
 
-	ptr = __alloc_bootmem_node(mem_data[bestnode].pgdat,
-		pernodesize, align, __pa(MAX_DMA_ADDRESS));
+	if (bestnode = -1)
+		bestnode = anynode;
+
+	ptr = __alloc_bootmem_node(mem_data[bestnode].pgdat, pernodesize,
+		PERCPU_PAGE_SIZE, __pa(MAX_DMA_ADDRESS));
 
-	if (!ptr)
-		panic("NO memory for memory less node\n");
 	return ptr;
 }
 
@@ -413,8 +413,7 @@ static void __init memory_less_nodes(voi
 
 	for_each_node_mask(node, memory_less_mask) {
 		pernodesize = compute_pernodesize(node);
-		pernode = memory_less_node_alloc(node, pernodesize,
-			(node) ? (node * PERCPU_PAGE_SIZE) : (1024*1024));
+		pernode = memory_less_node_alloc(node, pernodesize);
 		fill_pernode(node, __pa(pernode), pernodesize);
 	}
 

