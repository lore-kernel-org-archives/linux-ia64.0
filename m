From: Vlastimil Babka <vbabka@suse.cz>
Date: Thu, 20 Aug 2015 11:43:21 +0000
Subject: [PATCH 2/3] mm: unify checks in alloc_pages_node() and __alloc_pages_node()
Message-Id: <1440071002-19085-2-git-send-email-vbabka@suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <1440071002-19085-1-git-send-email-vbabka@suse.cz>
In-Reply-To: <1440071002-19085-1-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Greg Thelen <gthelen@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, cbe-oss-dev@lists.ozlabs.org, kvm@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>

Perform the same debug checks in alloc_pages_node() as are done in
__alloc_pages_node(), by making the former function a wrapper of the latter
one.

In addition to better diagnostics in DEBUG_VM builds for situations which
have been already fatal (e.g. out-of-bounds node id), there are two visible
changes for potential existing buggy callers of alloc_pages_node():

- calling alloc_pages_node() with any negative nid (e.g. due to arithmetic
  overflow) was treated as passing NUMA_NO_NODE and fallback to local node was
  applied. This will now be fatal.
- calling alloc_pages_node() with an offline node will now be checked for
  DEBUG_VM builds. Since it's not fatal if the node has been previously online,
  and this patch may expose some existing buggy callers, change the VM_BUG_ON
  in __alloc_pages_node() to VM_WARN_ON.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: David Rientjes <rientjes@google.com>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Christoph Lameter <cl@linux.com>
---
 include/linux/gfp.h | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index d2c142b..4a12cae2 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -310,23 +310,23 @@ __alloc_pages(gfp_t gfp_mask, unsigned int order,
 static inline struct page *
 __alloc_pages_node(int nid, gfp_t gfp_mask, unsigned int order)
 {
-	VM_BUG_ON(nid < 0 || nid >= MAX_NUMNODES || !node_online(nid));
+	VM_BUG_ON(nid < 0 || nid >= MAX_NUMNODES);
+	VM_WARN_ON(!node_online(nid));
 
 	return __alloc_pages(gfp_mask, order, node_zonelist(nid, gfp_mask));
 }
 
 /*
  * Allocate pages, preferring the node given as nid. When nid = NUMA_NO_NODE,
- * prefer the current CPU's node.
+ * prefer the current CPU's node. Otherwise node must be valid and online.
  */
 static inline struct page *alloc_pages_node(int nid, gfp_t gfp_mask,
 						unsigned int order)
 {
-	/* Unknown node is current node */
-	if (nid < 0)
+	if (nid = NUMA_NO_NODE)
 		nid = numa_node_id();
 
-	return __alloc_pages(gfp_mask, order, node_zonelist(nid, gfp_mask));
+	return __alloc_pages_node(nid, gfp_mask, order);
 }
 
 #ifdef CONFIG_NUMA
-- 
2.5.0

