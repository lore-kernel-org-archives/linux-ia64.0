From: Jack Steiner <steiner@sgi.com>
Date: Mon, 05 Dec 2005 19:56:50 +0000
Subject: [PATCH] - Limit the maximum NODEDATA_ALIGN() offset
Message-Id: <20051205195650.GA3069@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


The per-node data structures are allocated with strided offsets that are a
function of the node number. This prevents excessive cache-aliasing from
occurring. 

On systems with a large number of nodes, the strided offset becomes
too large. This patch restricts the maximum offset to 32MB. This is far larger
than the size of any current L3 cache.


	Signed-off-by: Jack Steiner <steiner@sgi.com>




Index: linux/arch/ia64/mm/discontig.c
=================================--- linux.orig/arch/ia64/mm/discontig.c	2005-12-01 11:41:02.372089800 -0600
+++ linux/arch/ia64/mm/discontig.c	2005-12-05 13:47:54.789625199 -0600
@@ -50,8 +50,10 @@ static nodemask_t memory_less_mask __ini
  * To prevent cache aliasing effects, align per-node structures so that they
  * start at addresses that are strided by node number.
  */
+#define MAX_NODE_ALIGN_OFFSET	(32 * 1024 * 1024)
 #define NODEDATA_ALIGN(addr, node)						\
-	((((addr) + 1024*1024-1) & ~(1024*1024-1)) + (node)*PERCPU_PAGE_SIZE)
+	((((addr) + 1024*1024-1) & ~(1024*1024-1)) + 				\
+	     (((node)*PERCPU_PAGE_SIZE) & (MAX_NODE_ALIGN_OFFSET - 1)))
 
 /**
  * build_node_maps - callback to setup bootmem structs for each node
