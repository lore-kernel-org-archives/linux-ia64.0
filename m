From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Date: Mon, 23 Jul 2018 05:56:56 +0000
Subject: [PATCH 2/4] ia64: remove unused num_dma_physpages member from 'struct early_node_data'
Message-Id: <1532325418-22617-3-git-send-email-rppt@linux.vnet.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1532325418-22617-1-git-send-email-rppt@linux.vnet.ibm.com>
In-Reply-To: <1532325418-22617-1-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-ia64@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Since commit 05e0caad3b7b ("[PATCH] Have ia64 use add_active_range() and
free_area_init_nodes") the num_dma_physpages member of 'struct
early_node_data' is calculated but never used. Remove it.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 arch/ia64/mm/discontig.c | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/arch/ia64/mm/discontig.c b/arch/ia64/mm/discontig.c
index 7d9bd20..6148ea8 100644
--- a/arch/ia64/mm/discontig.c
+++ b/arch/ia64/mm/discontig.c
@@ -38,9 +38,6 @@ struct early_node_data {
 	struct ia64_node_data *node_data;
 	unsigned long pernode_addr;
 	unsigned long pernode_size;
-#ifdef CONFIG_ZONE_DMA32
-	unsigned long num_dma_physpages;
-#endif
 	unsigned long min_pfn;
 	unsigned long max_pfn;
 };
@@ -669,11 +666,6 @@ static __init int count_node_pages(unsigned long start, unsigned long len, int n
 {
 	unsigned long end = start + len;
 
-#ifdef CONFIG_ZONE_DMA32
-	if (start <= __pa(MAX_DMA_ADDRESS))
-		mem_data[node].num_dma_physpages +-			(min(end, __pa(MAX_DMA_ADDRESS)) - start) >>PAGE_SHIFT;
-#endif
 	start = GRANULEROUNDDOWN(start);
 	end = GRANULEROUNDUP(end);
 	mem_data[node].max_pfn = max(mem_data[node].max_pfn,
-- 
2.7.4

