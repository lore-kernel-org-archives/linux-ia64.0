From: Jianguo Wu <wujianguo@huawei.com>
Date: Fri, 30 Aug 2013 03:42:31 +0000
Subject: [PATCH 4/5] mm/ia64: use N_MEMORY instead of N_HIGH_MEMORY
Message-Id: <522014A7.3040002@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com, laijs@cn.fujitsu.com
Cc: fenghua.yu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Since commit 8219fc48a(mm: node_states: introduce N_MEMORY),
we introduced N_MEMORY, now N_MEMORY stands for the nodes that has any memory,
and N_HIGH_MEMORY stands for the nodes that has normal or high memory.

The code here need to handle with the nodes which have memory,
we should use N_MEMORY instead.

Signed-off-by: Jianguo Wu <wujianguo@huawei.com>
---
 arch/ia64/kernel/uncached.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/arch/ia64/kernel/uncached.c b/arch/ia64/kernel/uncached.c
index a96bcf8..d2e5545 100644
--- a/arch/ia64/kernel/uncached.c
+++ b/arch/ia64/kernel/uncached.c
@@ -196,7 +196,7 @@ unsigned long uncached_alloc_page(int starting_nid, int n_pages)
 	nid = starting_nid;
 
 	do {
-		if (!node_state(nid, N_HIGH_MEMORY))
+		if (!node_state(nid, N_MEMORY))
 			continue;
 		uc_pool = &uncached_pools[nid];
 		if (uc_pool->pool = NULL)
-- 
1.7.1


