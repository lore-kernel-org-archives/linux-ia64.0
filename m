From: Wang Nan <wangnan0@huawei.com>
Date: Fri, 18 Jul 2014 07:55:59 +0000
Subject: [PATCH 1/5] memory-hotplug: x86_64: suitable memory should go to ZONE_MOVABLE
Message-Id: <1405670163-53747-2-git-send-email-wangnan0@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1405670163-53747-1-git-send-email-wangnan0@huawei.com>
In-Reply-To: <1405670163-53747-1-git-send-email-wangnan0@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@redhat.com>, Yinghai Lu <yinghai@kernel.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>
Cc: Pei Feiyue <peifeiyue@huawei.com>, linux-mm@kvack.org, x86@kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, linux-kernel@vger.kernel.org

This patch add new memory to ZONE_MOVABLE if movable zone is setup
and lower than newly added memory for x86_64.

Signed-off-by: Wang Nan <wangnan0@huawei.com>
---
 arch/x86/mm/init_64.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index df1a992..825915e 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -685,17 +685,23 @@ static void  update_end_of_memory_vars(u64 start, u64 size)
 }
 
 /*
- * Memory is added always to NORMAL zone. This means you will never get
- * additional DMA/DMA32 memory.
+ * Memory is added always to NORMAL or MOVABLE zone. This means you
+ * will never get additional DMA/DMA32 memory.
  */
 int arch_add_memory(int nid, u64 start, u64 size)
 {
 	struct pglist_data *pgdat = NODE_DATA(nid);
 	struct zone *zone = pgdat->node_zones + ZONE_NORMAL;
+	struct zone *movable_zone = pgdat->node_zones + ZONE_MOVABLE;
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 	int ret;
 
+	if (!zone_is_empty(movable_zone))
+		if (zone_spans_pfn(movable_zone, start_pfn) ||
+				(zone_end_pfn(movable_zone) <= start_pfn))
+			zone = movable_zone;
+
 	init_memory_mapping(start, start + size);
 
 	ret = __add_pages(nid, zone, start_pfn, nr_pages);
-- 
1.8.4

