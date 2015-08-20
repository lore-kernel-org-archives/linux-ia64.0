From: Vlastimil Babka <vbabka@suse.cz>
Date: Thu, 20 Aug 2015 11:43:22 +0000
Subject: [PATCH 3/3] mm: use numa_mem_id() in alloc_pages_node()
Message-Id: <1440071002-19085-3-git-send-email-vbabka@suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <1440071002-19085-1-git-send-email-vbabka@suse.cz>
In-Reply-To: <1440071002-19085-1-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Greg Thelen <gthelen@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, cbe-oss-dev@lists.ozlabs.org, kvm@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>

alloc_pages_node() might fail when called with NUMA_NO_NODE and
__GFP_THISNODE on a CPU belonging to a memoryless node. To make the
local-node fallback more robust and prevent such situations, use
numa_mem_id(), which was introduced for similar scenarios in the slab
context.

Suggested-by: Christoph Lameter <cl@linux.com>
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: David Rientjes <rientjes@google.com>
Acked-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: Christoph Lameter <cl@linux.com>
---
 v3: better commit message

 include/linux/gfp.h | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 4a12cae2..f92cbd2 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -318,13 +318,14 @@ __alloc_pages_node(int nid, gfp_t gfp_mask, unsigned int order)
 
 /*
  * Allocate pages, preferring the node given as nid. When nid = NUMA_NO_NODE,
- * prefer the current CPU's node. Otherwise node must be valid and online.
+ * prefer the current CPU's closest node. Otherwise node must be valid and
+ * online.
  */
 static inline struct page *alloc_pages_node(int nid, gfp_t gfp_mask,
 						unsigned int order)
 {
 	if (nid = NUMA_NO_NODE)
-		nid = numa_node_id();
+		nid = numa_mem_id();
 
 	return __alloc_pages_node(nid, gfp_mask, order);
 }
-- 
2.5.0

