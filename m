From: Wang Nan <wangnan0@huawei.com>
Date: Fri, 18 Jul 2014 07:56:03 +0000
Subject: [PATCH 5/5] memory-hotplug: powerpc: suitable memory should go to ZONE_MOVABLE
Message-Id: <1405670163-53747-6-git-send-email-wangnan0@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1405670163-53747-1-git-send-email-wangnan0@huawei.com>
In-Reply-To: <1405670163-53747-1-git-send-email-wangnan0@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@redhat.com>, Yinghai Lu <yinghai@kernel.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>
Cc: Pei Feiyue <peifeiyue@huawei.com>, linux-mm@kvack.org, x86@kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, linux-kernel@vger.kernel.org

This patch add new memory to ZONE_MOVABLE if movable zone is setup
and lower than newly added memory for powerpc.

Signed-off-by: Wang Nan <wangnan0@huawei.com>
---
 arch/powerpc/mm/mem.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
index 2c8e90f..2d869ef 100644
--- a/arch/powerpc/mm/mem.c
+++ b/arch/powerpc/mm/mem.c
@@ -118,6 +118,7 @@ int arch_add_memory(int nid, u64 start, u64 size)
 {
 	struct pglist_data *pgdata;
 	struct zone *zone;
+	struct zone *movable_zone;
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 
@@ -129,6 +130,11 @@ int arch_add_memory(int nid, u64 start, u64 size)
 
 	/* this should work for most non-highmem platforms */
 	zone = pgdata->node_zones;
+	movable_zone = pgdat->node_zones + ZONE_MOVABLE;
+	if (!zone_is_empty(movable_zone))
+		if (zone_spans_pfn(movable_zone, start_pfn) ||
+				(zone_end_pfn(movable_zone) <= start_pfn))
+			zone = movable_zone;
 
 	return __add_pages(nid, zone, start_pfn, nr_pages);
 }
-- 
1.8.4

